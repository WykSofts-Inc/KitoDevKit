//
//  FoodOrdersView.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoButtons
import KitoOrderTracking
import KitoReviews
import KitoEmptyStates
import KitoFormatting
import KitoModals

extension FoodShowcase {

    // MARK: - Orders tab

    /// The order on its way, then the history: reorder in one tap or rate what you ate.
    struct FoodOrdersTab: View {
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme
        @State private var path: [FoodRoute] = []
        @State private var confirmation: KitoConfirmation?

        var body: some View {
            NavigationStack(path: $path) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Orders")
                                .font(.largeTitle.weight(.bold))
                                .foregroundStyle(theme.colors.onBackground)
                                .accessibilityAddTraits(.isHeader)
                            Spacer()
                            FoodExitButton()
                        }
                        if let order = store.activeOrder, !order.isFinished {
                            FoodSectionHeader(title: "On its way")
                            FoodLiveOrderCard(order: order)
                        }
                        FoodSectionHeader(title: "Past orders",
                                          subtitle: store.history.isEmpty ? nil : "\(store.history.count) orders delivered to you")
                        if store.history.isEmpty {
                            KitoEmptyStateView(systemImage: "bag", title: "No orders yet",
                                               message: "When you order, it shows up here so you can get it again in one tap.",
                                               action: KitoEmptyStateAction(title: "Find something to eat") { store.tab = .home })
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(store.history) { order in
                                    FoodPastOrderCard(order: order,
                                                      open: { path.append(.restaurant(order.restaurantID)) },
                                                      reorder: { reorder(order) },
                                                      rate: { store.ratingOrder = order })
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                }
                .background(theme.colors.background.ignoresSafeArea())
                .safeAreaInset(edge: .bottom, spacing: 0) { FoodMiniCart().padding(.bottom, 8) }
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: FoodRoute.self) { route in
                    FoodRouteDestination(route: route)
                }
                .kitoConfirmation($confirmation)
            }
        }

        private func reorder(_ order: FoodPastOrder) {
            guard let restaurant = order.restaurant, store.needsNewBasket(for: restaurant), let current = store.cartRestaurant else {
                return store.reorder(order)
            }
            confirmation = KitoConfirmation(title: "Replace your basket?",
                                            message: "Your basket has items from \(current.name). Reordering from \(restaurant.name) clears it.",
                                            confirmTitle: "Replace basket", isDestructive: true) {
                store.reorder(order)
            }
        }
    }

    struct FoodPastOrderCard: View {
        let order: FoodPastOrder
        let open: () -> Void
        let reorder: () -> Void
        let rate: () -> Void
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                Button(action: open) {
                    HStack(spacing: 12) {
                        if let restaurant = order.restaurant {
                            FoodArtView(art: restaurant.art, symbolScale: 0.46, showsPattern: false)
                                .frame(width: 52, height: 52)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(order.restaurant?.name ?? "Order")
                                .font(.headline)
                                .foregroundStyle(theme.colors.onSurface)
                            Text("\(KitoDateFormatting.dayLabel(order.date)) · \(order.itemCount) items · \(KitoCartMoney.string(order.total))")
                                .font(.caption)
                                .foregroundStyle(theme.colors.onSurface.opacity(0.6))
                        }
                        Spacer(minLength: 4)
                        KitoOrderStatusChip(stage: .delivered, style: .solid)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(FoodPressStyle())
                .accessibilityElement(children: .combine)
                .accessibilityHint("Opens the menu")
                Text(order.summary)
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.onSurface.opacity(0.8))
                    .lineLimit(2)
                HStack(spacing: 12) {
                    if let rating = order.rating {
                        HStack(spacing: 6) {
                            KitoStarRating(value: Double(rating), size: .small, tint: FoodPalette.star)
                            Text("You rated it").font(.caption).foregroundStyle(theme.colors.onSurface.opacity(0.6))
                        }
                        .accessibilityElement(children: .combine)
                    } else {
                        KitoButton("Rate", systemImage: "star") { rate() }
                            .variant(.outlined)
                            .size(.small)
                    }
                    Spacer()
                    KitoButton("Reorder", systemImage: "arrow.clockwise") { reorder() }
                        .size(.small)
                }
            }
            .padding(16)
            .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(theme.colors.border, lineWidth: 0.5))
        }
    }
}
