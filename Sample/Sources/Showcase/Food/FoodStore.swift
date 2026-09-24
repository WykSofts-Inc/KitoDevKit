//
//  FoodStore.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Observation
import CoreLocation
import KitoCart
import KitoCheckout
import KitoOrderTracking
import KitoMaps
import KitoChat
import KitoToasts
import KitoNotifications
import KitoIslandBar
import KitoHaptics

extension FoodShowcase {

    enum FoodTab: String {
        case home, search, orders, account
    }

    /// A delivered order in the history.
    struct FoodPastOrder: Identifiable, Equatable {
        var id: String
        var restaurantID: String
        var date: Date
        var items: [KitoCartItem]
        var lines: [String: FoodCartLine]
        var total: Decimal
        var paymentTitle: String
        var rating: Int?

        var restaurant: FoodRestaurant? { FoodData.restaurant(id: restaurantID) }
        var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }

        var summary: String {
            let names = items.prefix(2).map { "\($0.quantity)× \($0.name)" }
            let more = items.count > 2 ? " +\(items.count - 2) more" : ""
            return names.joined(separator: ", ") + more
        }
    }

    /// The order being delivered right now. The simulation runs in real time but everything
    /// the user reads — ETA, event times — is shown at `demoScale`× so a two-minute demo reads
    /// like a real fifteen-minute delivery.
    @MainActor
    @Observable
    final class FoodActiveOrder: Identifiable {
        static let demoScale: Double = 8
        /// Real seconds from placing to the rider setting off.
        static let pickupDelay: TimeInterval = 22
        /// Real seconds the ride takes.
        static let rideDuration: TimeInterval = 75

        let id: String
        let restaurant: FoodRestaurant
        let items: [KitoCartItem]
        let lines: [String: FoodCartLine]
        let total: Decimal
        let paymentTitle: String
        let destination: FoodAddress
        let placedAt: Date
        let deliveryCode: String
        let tracker: KitoLiveTracker
        let courier = KitoCourier(name: FoodData.riderName, phone: FoodData.riderPhone, vehicle: .motorbike,
                                  plate: FoodData.riderPlate, rating: 4.9, deliveries: 1_284)

        private(set) var stage: KitoOrderStage = .placed
        private(set) var stageTimes: [KitoOrderStage: Date] = [:]
        var messages: [KitoChatMessage] = []
        var isRated = false
        var announcedNearby = false

        init(id: String, restaurant: FoodRestaurant, items: [KitoCartItem], lines: [String: FoodCartLine], total: Decimal,
             paymentTitle: String, destination: FoodAddress, placedAt: Date = Date()) {
            self.id = id
            self.restaurant = restaurant
            self.items = items
            self.lines = lines
            self.total = total
            self.paymentTitle = paymentTitle
            self.destination = destination
            self.placedAt = placedAt
            self.deliveryCode = String(Int.random(in: 1_000...9_999))
            let path = FoodData.route(from: restaurant.coordinate, to: destination.coordinate)
            self.tracker = KitoLiveTracker(
                route: path, duration: Self.rideDuration,
                pin: KitoMapPin(id: "rider", coordinate: path[0], title: FoodData.riderName, subtitle: "Your rider",
                                style: .pulse, tint: FoodPalette.pepper, systemImage: "scooter"))
            self.stageTimes[.placed] = placedAt
        }

        var isFinished: Bool { stage == .delivered || stage == .cancelled }
        var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }

        func advance(to next: KitoOrderStage, at date: Date = Date()) {
            guard next > stage else { return }
            stage = next
            stageTimes[next] = date
        }

        // MARK: Demo time

        /// A real moment shown on the demo clock.
        func demoTime(_ date: Date) -> Date {
            placedAt.addingTimeInterval(date.timeIntervalSince(placedAt) * Self.demoScale)
        }

        /// Demo seconds until the door.
        var remainingDemoSeconds: TimeInterval {
            let real: TimeInterval
            switch stage {
            case .delivered, .cancelled:
                real = 0
            case .outForDelivery:
                real = tracker.remainingTime
            default:
                let untilPickup = max(Self.pickupDelay - Date().timeIntervalSince(placedAt), 0)
                real = untilPickup + Self.rideDuration
            }
            return real * Self.demoScale
        }

        var totalDemoSeconds: TimeInterval { (Self.pickupDelay + Self.rideDuration) * Self.demoScale }

        /// Arrival on the demo clock, for `KitoETACountdown`.
        var demoETA: Date { Date().addingTimeInterval(remainingDemoSeconds) }
        var demoStart: Date { demoETA.addingTimeInterval(-totalDemoSeconds) }

        var minutesAway: Int { max(Int((remainingDemoSeconds / 60).rounded(.up)), 0) }

        /// 0…1 over the whole order, for progress tracks.
        var overallProgress: Double {
            switch stage {
            case .placed: return 0.06
            case .confirmed: return 0.2
            case .preparing: return 0.38
            case .outForDelivery: return 0.45 + 0.55 * tracker.progress
            case .delivered, .cancelled: return 1
            }
        }

        var headline: String {
            switch stage {
            case .placed: return "Sending your order to \(restaurant.name)"
            case .confirmed: return "\(restaurant.name) accepted your order"
            case .preparing: return "\(restaurant.chef) is cooking your food"
            case .outForDelivery: return tracker.progress > 0.75 ? "\(firstName) is almost there" : "\(firstName) is on the way"
            case .delivered: return "Delivered — enjoy your meal!"
            case .cancelled: return "Order cancelled"
            }
        }

        var firstName: String { courier.name.split(separator: " ").first.map(String.init) ?? courier.name }

        var update: KitoOrderUpdate {
            KitoOrderUpdate(stage: stage, headline: headline,
                            detail: stage == .delivered ? "Code \(deliveryCode)" : "Arriving in \(minutesAway) min",
                            estimatedArrival: demoETA, progress: overallProgress, courierName: courier.name)
        }

        var events: [KitoOrderEvent] {
            let order: [KitoOrderStage] = [.placed, .confirmed, .preparing, .outForDelivery, .delivered]
            return order.map { stage in
                let time = stageTimes[stage].map(demoTime)
                switch stage {
                case .placed:
                    return KitoOrderEvent(stage: stage, title: "Order placed", detail: "Paid with \(paymentTitle)", time: time)
                case .confirmed:
                    return KitoOrderEvent(stage: stage, title: "Accepted", detail: "\(restaurant.name) has your order", time: time)
                case .preparing:
                    return KitoOrderEvent(stage: stage, title: "Preparing", detail: "Cooked fresh by \(restaurant.chef)", time: time,
                                          location: restaurant.area)
                case .outForDelivery:
                    return KitoOrderEvent(stage: stage, title: "Picked up", detail: "\(firstName) · \(courier.plate ?? "")", time: time)
                default:
                    return KitoOrderEvent(stage: stage, title: "Delivered", detail: "Handed over at \(destination.area)", time: time,
                                          location: destination.line)
                }
            }
        }
    }
}

// MARK: - Store

extension FoodShowcase {

    /// The whole app's state: where to deliver, the basket, the live order and the history.
    @MainActor
    @Observable
    final class FoodStore {
        // Navigation
        var tab: FoodTab = .home
        var hasPickedLocation = false
        var showsCart = false
        var trackedOrder: FoodActiveOrder?
        var ratingOrder: FoodPastOrder?

        // Delivery
        var address = FoodData.defaultAddress

        // Basket
        let cart = KitoCartViewModel()
        let flight = KitoCartFlightCoordinator()
        private(set) var cartRestaurantID: String?
        private(set) var lines: [String: FoodCartLine] = [:]
        var justAdded: KitoCartItem?

        // Orders
        private(set) var activeOrder: FoodActiveOrder?
        private(set) var history: [FoodPastOrder] = []
        private var orderSequence = 41
        private var simulation: Task<Void, Never>?
        /// Set when checkout succeeds, so the basket empties once the checkout closes.
        var placedWhileInCheckout = false

        // Feedback
        let toasts = KitoToastCenter(position: .top)
        var banner: KitoInboxNotification?
        var inbox: [KitoInboxNotification] = []
        var island: KitoIslandPresentation = .compact
        var favourites: Set<String> = ["mama-zuri", "tamu-tamu"]
        var riderTyping = false
        /// Open tracking once the basket sheet has finished closing.
        var pendingTracking = false
        /// Closes the whole showcase; set by `FoodShowcaseApp`.
        @ObservationIgnored var onExit: () -> Void = {}

        // Preferences
        var orderUpdates = true
        var offers = true

        init() {
            history = FoodData.pastOrders.enumerated().compactMap { index, seed in
                guard let restaurant = FoodData.restaurant(id: seed.restaurantID) else { return nil }
                var items: [KitoCartItem] = []
                var lines: [String: FoodCartLine] = [:]
                for line in seed.lines {
                    guard let dish = restaurant.dish(id: line.dishID) else { continue }
                    items.append(KitoCartItem(id: dish.id, name: dish.name, unitPrice: dish.price, quantity: line.quantity))
                    lines[dish.id] = FoodCartLine(dishID: dish.id, restaurantID: restaurant.id, size: nil, extras: [], note: "")
                }
                let subtotal = items.reduce(Decimal(0)) { $0 + $1.lineTotal }
                return FoodPastOrder(id: "CH-2609\(20 - index)-00\(38 - index)", restaurantID: restaurant.id,
                                     date: Date().addingTimeInterval(-seed.daysAgo * 86_400 - 3_600 * Double(index + 2)),
                                     items: items, lines: lines, total: subtotal + restaurant.deliveryFee,
                                     paymentTitle: index == 1 ? "Visa •••• 4242" : "M-Pesa", rating: seed.rating)
            }
            inbox = [
                KitoInboxNotification(kind: .promo, title: "KARIBU20 is waiting", body: "20% off your next order, on us.",
                                      date: Date().addingTimeInterval(-3 * 3_600), avatar: .symbol("gift.fill", FoodPalette.pepper)),
                KitoInboxNotification(kind: .order, title: "Delivered from Mama Zuri's Kitchen", body: "Rated 5 stars — thank you!",
                                      date: Date().addingTimeInterval(-2 * 86_400), isRead: true,
                                      avatar: .symbol("checkmark.circle.fill", .green)),
            ]
        }

        // MARK: Location

        func setAddress(_ picked: KitoPickedLocation) {
            let area = FoodData.neighbourhood(near: picked.coordinate)
            let looksLikeCoordinates = picked.name.contains("°") || picked.name.first?.isNumber == true || picked.name.first == "-"
            let line = looksLikeCoordinates || picked.name.isEmpty ? "Pinned location, \(area)" : picked.name
            address = FoodAddress(area: area, line: line, latitude: picked.coordinate.latitude, longitude: picked.coordinate.longitude)
        }

        func distanceText(to restaurant: FoodRestaurant) -> String {
            KitoMapFormat.distance(KitoMapGeometry.distance(from: address.coordinate, to: restaurant.coordinate))
        }

        // MARK: Basket

        var cartRestaurant: FoodRestaurant? { cartRestaurantID.flatMap(FoodData.restaurant(id:)) }

        /// Adding from another restaurant needs a fresh basket.
        func needsNewBasket(for restaurant: FoodRestaurant) -> Bool {
            !cart.isEmpty && cartRestaurantID != nil && cartRestaurantID != restaurant.id
        }

        func line(for itemID: String) -> FoodCartLine? { lines[itemID] }

        func dish(for itemID: String) -> FoodDish? {
            guard let line = lines[itemID] else { return nil }
            return FoodData.restaurant(id: line.restaurantID)?.dish(id: line.dishID)
        }

        @discardableResult
        func add(_ dish: FoodDish, from restaurant: FoodRestaurant, size: FoodChoice? = nil, extras: [FoodChoice] = [],
                 note: String = "", quantity: Int = 1) -> KitoCartItem {
            if needsNewBasket(for: restaurant) { clearBasket() }
            let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
            let extraNames = extras.map(\.name).sorted()
            let id = [dish.id, size?.name ?? "", extraNames.joined(separator: "+"), trimmed].joined(separator: "|")
            let price = dish.price + (size?.price ?? 0) + extras.reduce(Decimal(0)) { $0 + $1.price }
            var details: [String] = []
            if let size, dish.sizes.first?.name != size.name { details.append(size.name) }
            if !extraNames.isEmpty { details.append(extraNames.joined(separator: ", ")) }
            if !trimmed.isEmpty { details.append("“\(trimmed)”") }
            let item = KitoCartItem(id: id, name: dish.name, unitPrice: price, quantity: quantity,
                                    subtitle: details.isEmpty ? nil : details.joined(separator: " · "))
            cart.add(item)
            lines[id] = FoodCartLine(dishID: dish.id, restaurantID: restaurant.id, size: size?.name, extras: extraNames, note: trimmed)
            cartRestaurantID = restaurant.id
            return item
        }

        func clearBasket() {
            cart.clear()
            cart.clearRecentlyRemoved()
            lines = [:]
            cartRestaurantID = nil
        }

        func reorder(_ order: FoodPastOrder) {
            guard let restaurant = order.restaurant else { return }
            if needsNewBasket(for: restaurant) { clearBasket() }
            for item in order.items {
                cart.add(item)
                if let line = order.lines[item.id] { lines[item.id] = line }
            }
            cartRestaurantID = restaurant.id
            KitoHaptics.success()
            toasts.show(KitoToast(title: "Added to your basket", message: "\(order.itemCount) items from \(restaurant.name)",
                                  style: .success, icon: .custom("arrow.clockwise.circle.fill")))
        }

        func toggleFavourite(_ restaurant: FoodRestaurant) {
            if favourites.contains(restaurant.id) {
                favourites.remove(restaurant.id)
                toasts.show(KitoToast(message: "Removed \(restaurant.name) from favourites", icon: .custom("heart.slash"), duration: 2))
            } else {
                favourites.insert(restaurant.id)
                KitoHaptics.success()
                toasts.show(KitoToast(message: "Saved \(restaurant.name) to favourites", style: .success,
                                      icon: .custom("heart.fill"), accentColor: FoodPalette.pepper, duration: 2))
            }
        }
    }
}

// MARK: - Placing and simulating an order

extension FoodShowcase.FoodStore {
    typealias FoodActiveOrder = FoodShowcase.FoodActiveOrder
    typealias FoodPastOrder = FoodShowcase.FoodPastOrder
    typealias FoodData = FoodShowcase.FoodData
    typealias FoodPalette = FoodShowcase.FoodPalette

    static let me = KitoChatUser(id: "me", name: "Wycliff N")
    static let rider = KitoChatUser(id: "rider", name: FoodShowcase.FoodData.riderName,
                                    color: FoodShowcase.FoodPalette.pepper, isOnline: true)

    /// Called by the checkout: a mock M-Pesa STK push / card charge, then the live order starts.
    func placeOrder(_ order: KitoCheckoutOrder) async throws -> KitoPlacedOrder {
        try await Task.sleep(nanoseconds: 1_600_000_000)
        guard let restaurant = cartRestaurant else { throw FoodShowcase.FoodCheckoutError.emptyBasket }
        orderSequence += 1
        let number = KitoOrderNumber.dated(orderSequence, prefix: "CH", date: Date())
        let active = FoodActiveOrder(id: number, restaurant: restaurant, items: order.items, lines: lines,
                                     total: order.totals.total, paymentTitle: order.paymentMethod.title, destination: address)
        activeOrder = active
        placedWhileInCheckout = true
        island = .compact
        startSimulation()
        KitoHaptics.success()
        return order.confirmed(number: number, eta: "Arrives in about \(active.minutesAway) min")
    }

    /// The checkout closed: once an order went through, the basket starts empty again.
    func checkoutClosed() {
        guard placedWhileInCheckout else { return }
        placedWhileInCheckout = false
        clearBasket()
    }

    func track(_ order: FoodActiveOrder? = nil) {
        trackedOrder = order ?? activeOrder
    }

    private func startSimulation() {
        simulation?.cancel()
        simulation = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 400_000_000)
                guard let self, let order = self.activeOrder else { return }
                self.tick(order)
                if order.isFinished { return }
            }
        }
    }

    private func tick(_ order: FoodActiveOrder) {
        let elapsed = Date().timeIntervalSince(order.placedAt)
        switch order.stage {
        case .placed where elapsed >= 4:
            order.advance(to: .confirmed)
            notify("\(order.restaurant.name) accepted your order", "They're getting your \(order.itemCount) items ready.",
                   symbol: "checkmark.circle.fill")
        case .confirmed where elapsed >= 9:
            order.advance(to: .preparing)
            notify("Your food is being prepared", "\(order.restaurant.chef) is cooking it fresh.", symbol: "flame.fill")
        case .preparing where elapsed >= FoodActiveOrder.pickupDelay:
            pickUp(order)
        case .outForDelivery:
            if !order.announcedNearby, order.tracker.remainingTime * FoodActiveOrder.demoScale <= 150 {
                order.announcedNearby = true
                notify("Your rider is 2 minutes away", "\(order.firstName) is nearly at \(order.destination.area). Get ready!",
                       symbol: "scooter")
            }
            if order.tracker.hasArrived { deliver(order) }
        default:
            break
        }
    }

    private func pickUp(_ order: FoodActiveOrder) {
        order.advance(to: .outForDelivery)
        order.tracker.start()
        order.messages = [
            KitoChatMessage(author: Self.rider, kind: .system("\(order.firstName) picked up your order")),
            KitoChatMessage(author: Self.rider, text: "Habari! I've collected your food from \(order.restaurant.name) 🛵"),
            KitoChatMessage(author: Self.rider, text: "Coming to \(order.destination.line). I'll call when I reach the gate."),
        ]
        notify("\(order.firstName) picked up your order", "On a motorbike · \(FoodData.riderPlate). Track them live.", symbol: "bag.fill")
    }

    private func deliver(_ order: FoodActiveOrder) {
        order.advance(to: .delivered)
        history.insert(FoodPastOrder(id: order.id, restaurantID: order.restaurant.id, date: Date(), items: order.items,
                                     lines: order.lines, total: order.total, paymentTitle: order.paymentTitle, rating: nil), at: 0)
        notify("Delivered — enjoy your meal!", "Rate \(order.restaurant.name) to help others choose.", symbol: "house.fill")
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 6_000_000_000)
            self?.island = .idle
        }
    }

    /// Demo control: jump to the next interesting moment.
    func skipAhead() {
        guard let order = activeOrder else { return }
        switch order.stage {
        case .placed, .confirmed, .preparing:
            if order.stage < .confirmed { order.advance(to: .confirmed) }
            if order.stage < .preparing { order.advance(to: .preparing) }
            pickUp(order)
        case .outForDelivery:
            order.tracker.pause()
            order.tracker.update(progress: min(order.tracker.progress + 0.34, 1))
            order.tracker.start()
            if order.tracker.hasArrived { deliver(order) }
        default:
            break
        }
    }

    private func notify(_ title: String, _ body: String, symbol: String) {
        let item = KitoInboxNotification(kind: .order, title: title, body: body,
                                         avatar: .symbol(symbol, FoodPalette.pepper), actionTitle: "Track")
        inbox.insert(item, at: 0)
        guard orderUpdates else { return }
        banner = item
        KitoHaptics.success()
    }

    // MARK: Chat

    func send(_ message: KitoChatMessage, in order: FoodActiveOrder) {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            _ = order.messages.kitoUpdateStatus(of: message.id, to: .delivered)
            try? await Task.sleep(nanoseconds: 700_000_000)
            _ = order.messages.kitoUpdateStatus(of: message.id, to: .read)
            self?.riderTyping = true
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            self?.riderTyping = false
            order.messages.append(KitoChatMessage(author: Self.rider, text: Self.reply(to: message, in: order)))
        }
    }

    private static func reply(to message: KitoChatMessage, in order: FoodActiveOrder) -> String {
        var text = ""
        if case .text(let value) = message.kind { text = value.lowercased() }
        if text.contains("gate") || text.contains("where") || text.contains("house") {
            return "I'm following the pin you dropped in \(order.destination.area) — I'll call at the gate 👍"
        }
        if text.contains("asante") || text.contains("thank") {
            return "Karibu sana! Enjoy your food 😊"
        }
        if order.stage == .delivered {
            return "Enjoy! Please rate the order if you have a moment 🙏"
        }
        return ["Sawa, noted 👍", "Traffic is light, I'll be there in \(max(order.minutesAway, 1)) min.", "Almost there!"]
            .randomElement() ?? "Sawa 👍"
    }

    // MARK: Rating and reset

    func rate(orderID: String, rating: Int) {
        if let index = history.firstIndex(where: { $0.id == orderID }) { history[index].rating = rating }
        if activeOrder?.id == orderID { activeOrder?.isRated = true }
        toasts.show(KitoToast(title: "Thanks for your review", message: "It helps other people choose where to eat.",
                              style: .success, icon: .custom("star.fill"), accentColor: FoodPalette.star))
    }

    func resetDemo() {
        simulation?.cancel()
        activeOrder?.tracker.pause()
        activeOrder = nil
        trackedOrder = nil
        clearBasket()
        tab = .home
        hasPickedLocation = false
    }
}

extension FoodShowcase {
    enum FoodCheckoutError: LocalizedError {
        case emptyBasket
        var errorDescription: String? { "Your basket is empty — add something first." }
    }
}
