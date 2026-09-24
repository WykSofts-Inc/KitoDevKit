//
//  FoodCartView.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoCheckout
import KitoModals
import KitoHaptics

extension FoodShowcase {

    /// The basket (KitoCart) and, pushed on top of it, the checkout (KitoCheckout).
    struct FoodCartScreen: View {
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme
        @Environment(\.dismiss) private var dismiss
        @State private var checkout: KitoCheckoutModel?
        @State private var showsCheckout = false
        @State private var confirmation: KitoConfirmation?

        static let freeDeliveryThreshold: Decimal = 2_500

        private var fee: Decimal { store.cartRestaurant?.deliveryFee ?? 99 }

        var body: some View {
            NavigationStack {
                KitoCartView(cart: store.cart,
                             rules: KitoCartPricingRules(deliveryFee: fee, freeDeliveryThreshold: Self.freeDeliveryThreshold, serviceFeeRate: 0.02),
                             checkoutTitle: "Go to checkout",
                             onCheckout: { _ in startCheckout() },
                             onBrowse: { dismiss() },
                             emptyTitle: "Your basket is empty",
                             emptyMessage: "Browse the menu and add something you love.",
                             emptyActionTitle: "Keep browsing") { item in
                    FoodCartThumbnail(item: item)
                }
                .navigationTitle(store.cartRestaurant?.name ?? "Your basket")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") { dismiss() }
                    }
                    if !store.cart.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Clear", role: .destructive) {
                                confirmation = KitoConfirmation(title: "Empty your basket?", message: "Everything in it will be removed.",
                                                                confirmTitle: "Empty basket", isDestructive: true) {
                                    store.clearBasket()
                                }
                            }
                        }
                    }
                }
                .navigationDestination(isPresented: $showsCheckout) {
                    if let checkout {
                        FoodCheckoutFlow(model: checkout) { showsCheckout = false }
                            .toolbar(.hidden, for: .navigationBar)
                    }
                }
                .kitoConfirmation($confirmation)
            }
            .presentationDragIndicator(.visible)
        }

        private func startCheckout() {
            guard let restaurant = store.cartRestaurant else { return }
            checkout = FoodCheckoutFactory.model(for: restaurant, store: store)
            showsCheckout = true
            KitoHaptics.impact(.light)
        }
    }

    enum FoodCheckoutFactory {
        @MainActor
        static func model(for restaurant: FoodRestaurant, store: FoodStore) -> KitoCheckoutModel {
            let address = store.address
            let home = KitoAddress(id: "home", label: .home, recipient: "Wycliff N", phone: "0712345678", street: address.line,
                                   building: "Mvuli Court, Block B, 4th floor", area: address.area, town: "Nairobi", county: "Nairobi",
                                   landmark: "Opposite the petrol station", instructions: "Call when you reach the gate",
                                   isDefault: true, latitude: address.latitude, longitude: address.longitude)
            let work = KitoAddress(id: "work", label: .work, recipient: "Wycliff N", phone: "0712345678", street: "Waiyaki Way",
                                   building: "Mawe Towers, 7th floor", area: "Westlands", town: "Nairobi", county: "Nairobi",
                                   landmark: "Reception on the ground floor", latitude: -1.2640, longitude: 36.8030)
            let kitchen = KitoPickupPoint(id: restaurant.id, name: restaurant.name, address: "\(restaurant.area), Nairobi",
                                          hours: "Ready in 15–20 min",
                                          distanceKm: FoodDistance.kilometres(from: address, to: restaurant))
            let options = [
                KitoDeliveryOption(id: "now", kind: .express, title: "Deliver now", subtitle: "Straight from the kitchen",
                                   price: restaurant.deliveryFee, eta: .minutes(restaurant.minutes), badge: "Fastest"),
                KitoDeliveryOption(id: "later", kind: .scheduled, title: "Schedule for later", subtitle: "Pick a lunch or dinner slot",
                                   price: restaurant.deliveryFee, eta: .text("At the time you choose"), usesTimeSlots: true),
                KitoDeliveryOption(id: "pickup", kind: .pickup, title: "Pick up yourself", subtitle: "Skip the delivery fee",
                                   price: 0, eta: .minutes(15...20), badge: "No fee", pickupPoints: [kitchen]),
            ]
            let schedule = KitoDeliverySchedule(rules: KitoSlotRules(
                windows: [KitoTimeWindow(12, 13), KitoTimeWindow(13, 14), KitoTimeWindow(18, 19), KitoTimeWindow(19, 20), KitoTimeWindow(20, 21)],
                daysAhead: 3, leadTime: 45 * 60, capacity: 8, fewLeftThreshold: 2))
            return KitoCheckoutModel(
                cart: store.cart,
                steps: [.delivery, .payment, .review],
                addresses: [home, work],
                deliveryOptions: options,
                schedule: schedule,
                paymentMethods: [.mpesa(phone: "0712345678"), .card(.visa, last4: "4242", expiry: "08/29"), .cashOnDelivery(limit: 5_000)],
                rules: KitoCheckoutPricingRules(serviceFee: .percent(2, minimum: 20), vat: .kenya,
                                                freeDeliveryThreshold: FoodCartScreen.freeDeliveryThreshold),
                promoValidator: KitoPromoValidator(codes: [
                    KitoPromoCode(code: "KARIBU20", kind: .percent(20, cap: 500), title: "20% off your first order"),
                    KitoPromoCode(code: "CHAKULA", kind: .fixed(150), minimumSubtotal: 1_000, title: "KES 150 off"),
                    KitoPromoCode(code: "FREEDEL", kind: .freeDelivery, title: "Free delivery"),
                ]),
                offersTip: true)
        }
    }

    /// Distances for the pickup row.
    enum FoodDistance {
        static func kilometres(from address: FoodAddress, to restaurant: FoodRestaurant) -> Double {
            let latitude = (address.latitude - restaurant.latitude) * 111.0
            let longitude = (address.longitude - restaurant.longitude) * 111.0 * cos(address.latitude * .pi / 180)
            return ((latitude * latitude + longitude * longitude).squareRoot() * 10).rounded() / 10
        }
    }

    /// KitoCheckoutFlow with a mock M-Pesa STK push and a status dialog while it "charges".
    struct FoodCheckoutFlow: View {
        @Bindable var model: KitoCheckoutModel
        /// Back to the basket from the first step.
        let back: () -> Void
        @Environment(FoodStore.self) private var store
        @State private var payment: KitoStatusDialogState?

        var body: some View {
            KitoCheckoutFlow(model: model, title: "Checkout", progressStyle: .segmented,
                             onClose: { if model.step == .done { store.showsCart = false } else { back() } },
                             onTrackOrder: { _ in
                                 store.pendingTracking = true
                                 store.showsCart = false
                             },
                             onContinueShopping: { store.showsCart = false },
                             onPlaceOrder: place) { item in
                FoodCartThumbnail(item: item)
            }
            .kitoStatusDialog($payment)
        }

        private func place(_ order: KitoCheckoutOrder) async throws -> KitoPlacedOrder {
            let amount = KitoCartMoney.string(order.totals.total)
            switch order.paymentMethod.kind {
            case .mpesa:
                payment = .pending(message: "Check your phone and enter your M-Pesa PIN to pay \(amount)")
            case .cashOnDelivery:
                payment = .pending(message: "Sending your order to the kitchen…")
            default:
                payment = .pending(message: "Charging \(order.paymentMethod.title)…")
            }
            do {
                let placed = try await store.placeOrder(order)
                if case .cashOnDelivery = order.paymentMethod.kind {
                    payment = .success(message: "Order placed — pay \(amount) on arrival")
                } else {
                    payment = .success(message: "Paid \(amount)")
                }
                return placed
            } catch {
                payment = .failure(message: "Payment didn't go through")
                throw error
            }
        }
    }
}
