//
//  FashionShowcaseApp.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoNavigation
import KitoToasts

/// How the DevKit home lists the Maison demo.
enum FashionShowcase {
    static let title = "Maison"
    static let subtitle = "Luxury fashion store"
    static let systemImage = "bag.fill"
}

/// Maison Amani, a luxury fashion store built from Kito packages. Present it full screen.
struct FashionShowcaseApp: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = FashionStore()

    var body: some View {
        FashionThemed(appearance: store.appearance) {
            FashionPhaseView()
                .kitoToastHost(store.toasts)
        }
        .environment(store)
        .environment(store.toasts)
        .environment(\.fashionExit, { dismiss() })
    }
}

/// Splash, then the welcome screen, then the shop.
private struct FashionPhaseView: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            switch store.phase {
            case .splash:
                FashionSplash { store.phase = store.user == nil ? .welcome : .shopping }
                    .transition(.opacity)
            case .welcome:
                FashionWelcome()
                    .transition(.opacity)
            case .shopping:
                FashionRootView()
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .easeInOut(duration: 0.5), value: store.phase)
    }
}

/// One navigation stack over the tab bar, so product pages and checkout cover the tabs.
private struct FashionRootView: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.kitoTheme) private var theme

    var body: some View {
        KitoRouterView(router: store.router) {
            KitoTabContainerView(viewModel: store.tabs, style: .underline, tint: theme.colors.primary) { id in
                switch FashionTab(rawValue: id) ?? .home {
                case .home: FashionHomeScreen()
                case .search: FashionSearchScreen()
                case .wishlist: FashionWishlistScreen()
                case .bag: FashionBagScreen()
                case .account: FashionAccountScreen()
                }
            }
            .background(theme.colors.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        } destination: { route in
            FashionDestination(route: route)
        }
        .onChange(of: store.cart.totalQuantity) { _, _ in store.rebuildTabs() }
    }
}

private struct FashionDestination: View {
    @Environment(FashionStore.self) private var store
    let route: FashionRoute

    var body: some View {
        switch route {
        case .product(let id):
            if let item = FashionCatalogue.item(id) {
                FashionProductScreen(item: item, store: store)
            }
        case .category(let category):
            FashionCategoryScreen(category: category)
        case .look(let id):
            if let look = FashionCatalogue.look(id) { FashionLookScreen(look: look) }
        case .designer(let id):
            FashionDesignerScreen(designer: FashionCatalogue.designer(id))
        case .orders:
            FashionOrdersScreen()
        case .tracking(let id):
            if let order = store.order(id) { FashionTrackingScreen(order: order) }
        }
    }
}
