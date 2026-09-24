//
//  FoodHomeView.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoCarousel
import KitoNavigation
import KitoSearch
import KitoEmptyStates
import KitoOrderTracking
import KitoToasts
import KitoHaptics

extension FoodShowcase {

    // MARK: - Home tab

    struct FoodHomeTab: View {
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var path: [FoodRoute] = []
        @State private var cuisine = "All"
        @State private var showsMap = false
        @State private var changesAddress = false

        private var restaurants: [FoodRestaurant] {
            let all = FoodData.restaurants.sorted { $0.rating * 1_000 + Double($0.ratingCount) / 10 > $1.rating * 1_000 + Double($1.ratingCount) / 10 }
            guard cuisine != "All" else { return all }
            return all.filter { $0.cuisine.rawValue == cuisine }
        }

        var body: some View {
            NavigationStack(path: $path) {
                VStack(spacing: 0) {
                    FoodAddressHeader { changesAddress = true }
                    ZStack {
                        if showsMap {
                            FoodRestaurantsMap(restaurants: restaurants) { path.append(.restaurant($0.id)) }
                                .transition(.opacity)
                        } else {
                            list.transition(.opacity)
                        }
                    }
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: showsMap)
                }
                .background(theme.colors.background.ignoresSafeArea())
                .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: FoodRoute.self) { route in
                    FoodRouteDestination(route: route)
                }
            }
            .fullScreenCover(isPresented: $changesAddress) {
                FoodLocationScreen { changesAddress = false }
                    .environment(store)
                    .kitoTheme(theme)
            }
        }

        private var list: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    FoodSearchBarButton { store.tab = .search }
                        .padding(.horizontal, 16)
                    if let order = store.activeOrder, !(order.isFinished && order.isRated) {
                        FoodLiveOrderCard(order: order)
                            .padding(.horizontal, 16)
                    }
                    KitoBannerCarousel(FoodData.promos, interval: 5, height: 164) { promo in
                        FoodPromoBanner(promo: promo) { open(promo) }
                    }
                    .padding(.horizontal, 16)
                    KitoTopTabs(FoodData.cuisines, selection: $cuisine, style: .chips)
                        .onChange(of: cuisine) { _, _ in KitoHaptics.selectionChanged() }
                    if cuisine == "All", !store.history.isEmpty {
                        orderAgain
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        FoodSectionHeader(title: cuisine == "All" ? "Popular near you" : "\(cuisine) near you",
                                          subtitle: "\(restaurants.count) places deliver to \(store.address.area)")
                        if restaurants.isEmpty {
                            KitoEmptyStateView(systemImage: "fork.knife", title: "Nothing here yet",
                                               message: "No \(cuisine.lowercased()) places deliver to \(store.address.area) right now.",
                                               action: KitoEmptyStateAction(title: "Show everything") { cuisine = "All" })
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                        } else {
                            LazyVStack(spacing: 26) {
                                ForEach(restaurants) { restaurant in
                                    FoodRestaurantCard(restaurant: restaurant) { path.append(.restaurant(restaurant.id)) }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 6)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }

        private var orderAgain: some View {
            VStack(alignment: .leading, spacing: 12) {
                FoodSectionHeader(title: "Order again", actionTitle: "See all") { store.tab = .orders }
                    .padding(.horizontal, 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.history.prefix(4)) { order in
                            if let restaurant = order.restaurant {
                                FoodOrderAgainChip(order: order, restaurant: restaurant) { store.reorder(order) }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }

        private var bottomBar: some View {
            VStack(spacing: 10) {
                Button {
                    showsMap.toggle()
                    KitoHaptics.selectionChanged()
                } label: {
                    Label(showsMap ? "List" : "Map", systemImage: showsMap ? "list.bullet" : "map.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(theme.colors.onPrimary)
                        .padding(.horizontal, 18)
                        .frame(height: 42)
                        .background(theme.colors.primary, in: Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
                }
                .buttonStyle(FoodPressStyle())
                .accessibilityLabel(showsMap ? "Show list" : "Show map")
                FoodMiniCart()
            }
            .padding(.bottom, 8)
        }

        private func open(_ promo: FoodPromo) {
            if let id = promo.restaurantID {
                path.append(.restaurant(id))
            } else if let code = promo.code {
                UIPasteboard.general.string = code
                KitoHaptics.success()
                store.toasts.show(KitoToast(title: "Code copied", message: "Paste \(code) in your basket for 20% off.",
                                            style: .success, icon: .custom("doc.on.doc.fill")))
            }
        }
    }

    /// Where a `FoodRoute` leads, shared by every tab's stack.
    struct FoodRouteDestination: View {
        let route: FoodRoute

        var body: some View {
            switch route {
            case .restaurant(let id):
                if let restaurant = FoodData.restaurant(id: id) { FoodRestaurantScreen(restaurant: restaurant) }
            case .reviews(let id):
                if let restaurant = FoodData.restaurant(id: id) { FoodAllReviewsScreen(restaurant: restaurant) }
            }
        }
    }
}

// MARK: - Home pieces

extension FoodShowcase {

    struct FoodAddressHeader: View {
        let change: () -> Void
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            HStack(spacing: 12) {
                Button(action: change) {
                    HStack(spacing: 10) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .background(FoodPalette.pepper, in: Circle())
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Deliver to")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(theme.colors.onBackground.opacity(0.55))
                            HStack(spacing: 4) {
                                Text(store.address.area).font(.headline)
                                Image(systemName: "chevron.down").font(.caption.weight(.bold))
                            }
                            .foregroundStyle(theme.colors.onBackground)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(FoodPressStyle())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Deliver to \(store.address.area), \(store.address.line)")
                .accessibilityHint("Changes the delivery address")
                .accessibilityAddTraits(.isButton)
                Spacer()
                FoodExitButton()
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
    }

    struct FoodSearchBarButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                KitoSearchField(text: .constant(""), prompt: "Search restaurants or dishes", style: .prominent,
                                showsCancelButton: false)
                    .allowsHitTesting(false)
            }
            .buttonStyle(FoodPressStyle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Search restaurants or dishes")
            .accessibilityAddTraits(.isButton)
        }
    }

    /// The order on its way, pinned to the top of Home.
    struct FoodLiveOrderCard: View {
        let order: FoodActiveOrder
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            Button { store.track(order) } label: {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        FoodArtView(art: order.restaurant.art, symbolScale: 0.46, showsPattern: false)
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 5) {
                            KitoOrderStatusChip(stage: order.stage, trackingStyle: FoodIsland.style)
                            Text(order.headline)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.colors.onSurface)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 4)
                        if order.isFinished {
                            Text(order.isRated ? "Rated" : "Rate it")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(FoodPalette.pepper)
                        } else {
                            TimelineView(.periodic(from: .now, by: 1)) { _ in
                                VStack(alignment: .trailing, spacing: 0) {
                                    Text("\(order.minutesAway)")
                                        .font(.title2.weight(.heavy).monospacedDigit())
                                        .contentTransition(.numericText(countsDown: true))
                                    Text("min").font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(theme.colors.onSurface)
                            }
                        }
                    }
                    KitoOrderProgressTrack(stage: order.stage, progress: order.overallProgress, vehicle: .motorbike, style: FoodIsland.style)
                }
                .padding(16)
                .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(FoodPalette.pepper.opacity(0.35), lineWidth: 1))
                .shadow(color: FoodPalette.pepper.opacity(0.12), radius: 16, y: 6)
            }
            .buttonStyle(FoodPressStyle())
            .accessibilityElement(children: .combine)
            .accessibilityHint("Opens live tracking")
        }
    }

    struct FoodPromoBanner: View {
        let promo: FoodPromo
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                ZStack(alignment: .leading) {
                    LinearGradient(colors: promo.art.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: promo.art.symbol)
                        .font(.system(size: 120, weight: .bold))
                        .foregroundStyle(.white.opacity(0.22))
                        .rotationEffect(.degrees(-12))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .offset(x: 24, y: 10)
                    if let accent = promo.art.accent {
                        Image(systemName: accent)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white.opacity(0.35))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(18)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(promo.eyebrow.uppercased())
                            .font(.caption2.weight(.heavy))
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.8))
                        Text(promo.title)
                            .font(.title2.weight(.heavy))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        Text(promo.detail)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)
                        Text(promo.code.map { "Copy \($0)" } ?? "Order now")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.white, in: Capsule())
                            .padding(.top, 4)
                    }
                    .padding(20)
                    .frame(maxWidth: 250, alignment: .leading)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(FoodPressStyle())
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(promo.eyebrow). \(promo.title). \(promo.detail)")
        }
    }

    struct FoodOrderAgainChip: View {
        let order: FoodPastOrder
        let restaurant: FoodRestaurant
        let reorder: () -> Void
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            HStack(spacing: 12) {
                FoodArtView(art: restaurant.art, symbolScale: 0.46, showsPattern: false)
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(restaurant.name).font(.subheadline.weight(.semibold)).lineLimit(1)
                    Text(order.summary).font(.caption).foregroundStyle(theme.colors.onSurface.opacity(0.6)).lineLimit(1)
                    Text(KitoCartMoney.string(order.total)).font(.caption.weight(.bold))
                }
                .foregroundStyle(theme.colors.onSurface)
                Spacer(minLength: 0)
                Button(action: reorder) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(theme.colors.onPrimary)
                        .frame(width: 34, height: 34)
                        .background(theme.colors.primary, in: Circle())
                }
                .buttonStyle(FoodPressStyle())
                .accessibilityLabel("Reorder from \(restaurant.name)")
            }
            .padding(12)
            .frame(width: 280)
            .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(theme.colors.border, lineWidth: 0.5))
        }
    }

    /// "View basket" along the bottom whenever there's something in it.
    struct FoodMiniCart: View {
        @Environment(FoodStore.self) private var store

        var body: some View {
            if !store.cart.isEmpty {
                KitoMiniCartBar(count: store.cart.totalQuantity, total: store.cart.subtotal,
                                title: store.cartRestaurant.map { "View basket · \($0.name)" } ?? "View basket") {
                    store.showsCart = true
                }
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
