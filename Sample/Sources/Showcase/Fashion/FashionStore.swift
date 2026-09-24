//
//  FashionStore.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Observation
import KitoCart
import KitoCheckout
import KitoNavigation
import KitoOrderTracking
import KitoPaywall
import KitoProduct
import KitoToasts

// MARK: - Routes and tabs

enum FashionRoute: KitoRoute {
    case product(String)
    case category(FashionCategory)
    case look(String)
    case designer(String)
    case orders
    case tracking(String)
}

enum FashionTab: String, CaseIterable {
    case home, search, wishlist, bag, account
}

enum FashionLaunchPhase: Equatable {
    case splash, welcome, shopping
}

struct FashionUser: Equatable {
    var name: String
    var email: String
    var initials: String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined()
    }
}

// MARK: - Orders

struct FashionOrder: Identifiable, Equatable {
    let id: String
    let placedAt: Date
    let items: [KitoCartItem]
    let total: Decimal
    let destination: String
    let deliveryTitle: String
    /// Past orders are already delivered; new ones move along a stage every `stageSeconds`.
    let isHistoric: Bool

    static let stageSeconds: TimeInterval = 25
    static let flow: [KitoOrderStage] = [.placed, .confirmed, .preparing, .outForDelivery, .delivered]

    func stage(at now: Date = Date()) -> KitoOrderStage {
        if isHistoric { return .delivered }
        let step = Int(now.timeIntervalSince(placedAt) / Self.stageSeconds)
        return Self.flow[min(max(step, 0), Self.flow.count - 1)]
    }

    /// When the courier should arrive, for the countdown.
    var eta: Date { placedAt.addingTimeInterval(Self.stageSeconds * Double(Self.flow.count - 1)) }

    var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }
}

// MARK: - Store

/// Everything the tabs share: the bag, the wishlist, orders, the signed-in customer and navigation.
@MainActor
@Observable
final class FashionStore {
    let cart = KitoCartViewModel()
    let router = KitoRouter<FashionRoute>()
    let toasts = KitoToastCenter()
    let checkout: KitoCheckoutModel
    let prive: KitoStore

    var phase: FashionLaunchPhase = .splash
    var user: FashionUser?
    var appearance: FashionAppearance = .system
    var wishlist: Set<String> = ["amani-tote", "shela-slip", "diani-cateye"]
    var orders: [FashionOrder] = [FashionStore.pastOrder]
    private(set) var tabs: KitoTabBarViewModel
    /// Set when "Search" is opened with a category or a query already chosen.
    var pendingSearch: String?

    init() {
        checkout = FashionCheckoutSetup.model(cart: cart)
        prive = KitoStore.preview(plans: FashionCheckoutSetup.privePlans, mostPopular: "prive.yearly")
        tabs = KitoTabBarViewModel(items: FashionStore.tabItems(bag: 0))
        rebuildTabs()
    }

    // MARK: Tabs

    private static func tabItems(bag: Int) -> [KitoTabItem] {
        [
            KitoTabItem(id: FashionTab.home.rawValue, title: "Home", systemImage: "house", selectedSystemImage: "house.fill"),
            KitoTabItem(id: FashionTab.search.rawValue, title: "Search", systemImage: "magnifyingglass"),
            KitoTabItem(id: FashionTab.wishlist.rawValue, title: "Wishlist", systemImage: "heart", selectedSystemImage: "heart.fill"),
            KitoTabItem(id: FashionTab.bag.rawValue, title: "Bag", systemImage: "bag", selectedSystemImage: "bag.fill", badgeCount: bag),
            KitoTabItem(id: FashionTab.account.rawValue, title: "Account", systemImage: "person", selectedSystemImage: "person.fill"),
        ]
    }

    /// `KitoTabBarViewModel.items` can't change, so a new bag count means a new view model that keeps the selection.
    func rebuildTabs() {
        let selected = tabs.selectedID
        tabs = KitoTabBarViewModel(items: Self.tabItems(bag: cart.totalQuantity), selectedID: selected) { [weak self] _ in
            self?.router.popToRoot()
        }
    }

    var selectedTab: FashionTab { FashionTab(rawValue: tabs.selectedID) ?? .home }

    func show(_ tab: FashionTab) {
        router.popToRoot()
        if tabs.selectedID != tab.rawValue { tabs.select(tab.rawValue) }
    }

    // MARK: Navigation

    func open(_ route: FashionRoute) { router.push(route) }
    func open(product id: String) { router.push(.product(id)) }

    // MARK: Bag

    func add(_ product: KitoProduct, _ variant: KitoProductVariant, announce: Bool = true) {
        let item = product.cartItem(for: variant)
        cart.add(item)
        rebuildTabs()
        guard announce else { return }
        toasts.show(KitoToast(
            title: "Added to your bag",
            message: [product.name, item.subtitle].compactMap { $0 }.joined(separator: " · "),
            style: .success, icon: .custom("bag.fill"),
            accentColor: FashionPalette.gold,
            actions: [KitoToastAction(title: "View bag") { [weak self] in self?.show(.bag) }],
            duration: 3.5))
    }

    // MARK: Wishlist

    func isSaved(_ id: String) -> Bool { wishlist.contains(id) }

    func setSaved(_ id: String, _ saved: Bool) {
        guard saved != wishlist.contains(id) else { return }
        if saved { wishlist.insert(id) } else { wishlist.remove(id) }
        if saved, let item = FashionCatalogue.item(id) {
            toasts.show(KitoToast(message: "\(item.product.name) saved to your wishlist", icon: .custom("heart.fill"),
                                  accentColor: FashionPalette.gold, duration: 2, layout: .pill))
        }
    }

    func savedBinding(_ id: String) -> Binding<Bool> {
        Binding(get: { [weak self] in self?.isSaved(id) ?? false },
                set: { [weak self] in self?.setSaved(id, $0) })
    }

    var wishlistBinding: Binding<Set<String>> {
        Binding(get: { [weak self] in self?.wishlist ?? [] },
                set: { [weak self] in self?.wishlist = $0 })
    }

    // MARK: Checkout

    /// Starts checkout from the bag, carrying over the bag's promo code.
    func beginCheckout(promo: KitoPromoCode?) {
        checkout.reset()
        checkout.promo = promo
    }

    func place(_ order: KitoCheckoutOrder) async throws -> KitoPlacedOrder {
        try await Task.sleep(nanoseconds: 1_400_000_000)
        let number = KitoOrderNumber.dated(Int.random(in: 300...980), prefix: "MA", date: Date())
        let destination = order.address?.formatted(.short) ?? order.pickupPoint?.name ?? "Nairobi"
        orders.insert(FashionOrder(id: number, placedAt: Date(), items: order.items, total: order.totals.total,
                                   destination: destination, deliveryTitle: order.deliveryOption.title, isHistoric: false), at: 0)
        return order.confirmed(number: number)
    }

    /// After the confirmation: empty the bag and go to the order.
    func finishCheckout(track: Bool) {
        cart.clear()
        rebuildTabs()
        checkout.reset()
        if track, let latest = orders.first {
            show(.account)
            router.push(.orders)
            router.push(.tracking(latest.id))
        } else {
            show(.home)
        }
    }

    var activeOrder: FashionOrder? {
        orders.first { !$0.isHistoric && $0.stage() != .delivered }
    }

    func order(_ id: String) -> FashionOrder? { orders.first { $0.id == id } }

    // MARK: Sign in

    func signIn(name: String, email: String) {
        user = FashionUser(name: name, email: email)
    }

    func signOut() {
        user = nil
        phase = .welcome
    }

    // MARK: Seed data

    private static var pastOrder: FashionOrder {
        let tote = FashionCatalogue.item("amani-tote")?.product
        let scent = FashionCatalogue.item("oud-kahawa")?.product
        var items: [KitoCartItem] = []
        if let tote, let variant = tote.variants.first { items.append(tote.cartItem(for: variant)) }
        if let scent, let variant = scent.variants.first { items.append(scent.cartItem(for: variant)) }
        return FashionOrder(id: "MA-260911-0217", placedAt: Date().addingTimeInterval(-13 * 86_400), items: items,
                            total: items.reduce(0) { $0 + $1.lineTotal }, destination: "Mvuli Court, Kilimani",
                            deliveryTitle: "Standard delivery", isHistoric: true)
    }
}
