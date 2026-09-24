//
//  FoodShowcaseApp.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoMaps
import KitoNavigation
import KitoToasts
import KitoNotifications
import KitoIslandBar
import KitoOrderTracking
import KitoHaptics

/// Chakula — a food delivery app built almost entirely from Kito packages. Present it full screen.
enum FoodShowcase {
    static let title = "Chakula"
    static let subtitle = "Food delivery"
    static let systemImage = "fork.knife"
}

/// The Chakula showcase, full screen, with its own "Exit demo" control.
struct FoodShowcaseApp: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var store = FoodShowcase.FoodStore()

    var body: some View {
        FoodShowcase.FoodRoot()
            .environment(store)
            .kitoTheme(FoodShowcase.FoodPalette.theme(for: colorScheme))
            .onAppear { store.onExit = { dismiss() } }
    }
}

extension FoodShowcase {

    // MARK: - Root

    struct FoodRoot: View {
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            @Bindable var store = store
            ZStack {
                theme.colors.background.ignoresSafeArea()
                if store.hasPickedLocation {
                    FoodMainTabs()
                        .transition(.opacity)
                } else {
                    FoodLocationScreen()
                        .transition(.opacity)
                }
            }
            .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.5, dampingFraction: 0.88),
                       value: store.hasPickedLocation)
            .overlay { liveIsland }
            .kitoNotificationBanner($store.banner, style: .island) { _ in store.track() }
            .kitoToastHost(store.toasts)
            .kitoCartFlightHost(store.flight)
            .sheet(isPresented: $store.showsCart, onDismiss: basketClosed) {
                FoodCartScreen()
                    .environment(store)
                    .kitoTheme(theme)
            }
            .fullScreenCover(item: $store.trackedOrder) { order in
                FoodTrackingScreen(order: order)
                    .environment(store)
                    .kitoTheme(theme)
            }
            .sheet(item: $store.ratingOrder) { order in
                FoodRateSheet(order: order)
                    .environment(store)
                    .kitoTheme(theme)
            }
        }

        private func basketClosed() {
            store.checkoutClosed()
            if store.pendingTracking {
                store.pendingTracking = false
                store.track()
            }
        }

        /// While an order is on its way, a Dynamic Island–style pill follows you around the app.
        @ViewBuilder
        private var liveIsland: some View {
            @Bindable var store = store
            if let order = store.activeOrder, store.hasPickedLocation, store.island != .idle, store.trackedOrder == nil {
                Color.clear
                    .kitoDynamicIsland(presentation: $store.island) {
                        KitoOrderIslandCompactLeadingView(state: .init(from: order.update), style: FoodIsland.style)
                    } trailing: {
                        KitoOrderIslandCompactTrailingView(state: .init(from: order.update))
                    } expanded: {
                        FoodIsland.Expanded(order: order) { store.track(order) }
                    }
                    .transition(.opacity)
            }
        }
    }

    enum FoodIsland {
        static let style = KitoOrderTrackingStyle(accentColor: FoodPalette.pepper, stageIcons: [.outForDelivery: "scooter"])

        /// The grown island: the package's own Live Activity layout plus a way into tracking.
        struct Expanded: View {
            let order: FoodActiveOrder
            let open: () -> Void

            var body: some View {
                VStack(spacing: 12) {
                    KitoOrderIslandExpandedView(merchantName: order.restaurant.name, state: .init(from: order.update), style: style)
                    Button(action: open) {
                        Text("Track order")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(.white, in: Capsule())
                    }
                    .buttonStyle(FoodPressStyle())
                }
                .environment(\.colorScheme, .dark)
            }
        }
    }

    // MARK: - Tabs

    struct FoodMainTabs: View {
        @Environment(FoodStore.self) private var store
        @State private var tabs = KitoTabBarViewModel(items: [
            KitoTabItem(id: FoodTab.home.rawValue, title: "Home", systemImage: "house", selectedSystemImage: "house.fill"),
            KitoTabItem(id: FoodTab.search.rawValue, title: "Search", systemImage: "magnifyingglass"),
            KitoTabItem(id: FoodTab.orders.rawValue, title: "Orders", systemImage: "bag", selectedSystemImage: "bag.fill"),
            KitoTabItem(id: FoodTab.account.rawValue, title: "Account", systemImage: "person", selectedSystemImage: "person.fill"),
        ])

        var body: some View {
            KitoTabContainerView(viewModel: tabs, style: .pill) { id in
                switch FoodTab(rawValue: id) ?? .home {
                case .home: FoodHomeTab()
                case .search: FoodSearchTab()
                case .orders: FoodOrdersTab()
                case .account: FoodAccountTab()
                }
            }
            .onChange(of: tabs.selectedID) { _, id in
                if let tab = FoodTab(rawValue: id), tab != store.tab { store.tab = tab }
                KitoHaptics.selectionChanged()
            }
            .onChange(of: store.tab) { _, tab in
                if tabs.selectedID != tab.rawValue { tabs.selectedID = tab.rawValue }
            }
        }
    }

    // MARK: - Location

    /// The first screen: drag the map under the pin to choose where the food goes.
    struct FoodLocationScreen: View {
        /// When the picker is reopened from Home it closes itself instead of showing Exit.
        var onClose: (() -> Void)?
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    FoodWordmark()
                    Spacer()
                    if let onClose {
                        FoodCircleButton(systemImage: "xmark", label: "Close", action: onClose)
                    } else {
                        FoodExitButton()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Where should we deliver?")
                        .font(.title.weight(.bold))
                        .foregroundStyle(theme.colors.onBackground)
                        .accessibilityAddTraits(.isHeader)
                    Text("Drag the map to drop the pin on your gate. Riders find you faster.")
                        .font(.subheadline)
                        .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 14)
                KitoLocationPicker(initialCoordinate: store.address.coordinate, zoom: 16, title: "Deliver to",
                                   confirmTitle: "Deliver here", systemImage: "house.fill") { picked in
                    store.setAddress(picked)
                    KitoHaptics.success()
                    if let onClose {
                        onClose()
                    } else {
                        store.hasPickedLocation = true
                    }
                }
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous))
                .ignoresSafeArea(edges: .bottom)
            }
            .background(theme.colors.background.ignoresSafeArea())
        }
    }

    struct FoodWordmark: View {
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.title2)
                    .foregroundStyle(FoodPalette.pepper)
                Text("chakula")
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .foregroundStyle(theme.colors.onBackground)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Chakula")
        }
    }
}
