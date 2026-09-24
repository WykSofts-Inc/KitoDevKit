//
//  FoodRestaurantView.swift
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
import KitoModals
import KitoReviews
import KitoHaptics

extension FoodShowcase {

    /// The dish a customisation sheet is open for.
    struct FoodDishRoute: KitoSheetRoute {
        let dishID: String
        var id: String { dishID }
    }

    /// Section header positions, for the category tabs to follow the scroll.
    fileprivate struct FoodSectionOffsetKey: PreferenceKey {
        static var defaultValue: [String: CGFloat] = [:]
        static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
            value.merge(nextValue()) { $1 }
        }
    }

    // MARK: - Restaurant

    /// A stretchy hero header, sticky category tabs, the menu and reviews.
    struct FoodRestaurantScreen: View {
        let restaurant: FoodRestaurant
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme
        @Environment(\.dismiss) private var dismiss
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var sheets = KitoSheetPresenter<FoodDishRoute>()
        @State private var confirmation: KitoConfirmation?
        @State private var section: String
        @State private var tabsPinned = false
        @State private var followsScroll = true

        private static let reviewsTitle = "Reviews"

        init(restaurant: FoodRestaurant) {
            self.restaurant = restaurant
            _section = State(initialValue: restaurant.menu.first?.title ?? Self.reviewsTitle)
        }

        private var titles: [String] { restaurant.menu.map(\.title) + [Self.reviewsTitle] }

        var body: some View {
            @Bindable var store = store
            GeometryReader { outer in
                let topInset = outer.safeAreaInsets.top
                let pinLine = outer.frame(in: .global).minY + 44
                ScrollViewReader { proxy in
                    KitoParallaxHeader(title: restaurant.name, subtitle: "\(restaurant.cuisine.rawValue) · \(restaurant.area)", height: 300) {
                        FoodArtView(art: restaurant.art, symbolScale: 0.3)
                    } content: {
                        VStack(alignment: .leading, spacing: 0) {
                            FoodRestaurantInfo(restaurant: restaurant)
                                .padding(.horizontal, 16)
                                .padding(.top, 18)
                                .padding(.bottom, 8)
                            tabs(proxy: proxy)
                                .background {
                                    GeometryReader { geometry in
                                        Color.clear.onChange(of: geometry.frame(in: .global).minY, initial: true) { _, minY in
                                            let pinned = minY < pinLine
                                            if pinned != tabsPinned { tabsPinned = pinned }
                                        }
                                    }
                                }
                            ForEach(restaurant.menu) { menuSection in
                                FoodMenuSectionView(section: menuSection, restaurant: restaurant,
                                                    anchorHeight: topInset + 44 + 56, open: openSheet, quickAdd: quickAdd)
                            }
                            reviews(anchorHeight: topInset + 44 + 56)
                        }
                        .padding(.bottom, 40)
                        .onPreferenceChange(FoodSectionOffsetKey.self) { offsets in
                            follow(offsets, line: pinLine + 60)
                        }
                    }
                    .overlay(alignment: .top) {
                        if tabsPinned {
                            tabs(proxy: proxy)
                                .background(.regularMaterial)
                                .overlay(alignment: .bottom) { Rectangle().fill(theme.colors.border).frame(height: 0.5) }
                                .padding(.top, 44)
                                .transition(.opacity)
                        }
                    }
                }
            }
            .overlay(alignment: .top) { topButtons }
            .safeAreaInset(edge: .bottom, spacing: 0) { FoodMiniCart().padding(.bottom, 8) }
            .toolbar(.hidden, for: .navigationBar)
            .kitoBottomSheet(presenter: sheets, detents: [.large]) { route in
                if let dish = restaurant.dish(id: route.dishID) {
                    FoodDishSheet(dish: dish, restaurant: restaurant) { size, extras, note, quantity in
                        confirmBasket { add(dish, size: size, extras: extras, note: note, quantity: quantity) }
                    }
                    .environment(store)
                    .kitoTheme(theme)
                }
            }
            .kitoConfirmation($confirmation)
            .kitoAddedToCartToast(item: $store.justAdded, style: .pill) { store.showsCart = true }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: tabsPinned)
        }

        // MARK: Pieces

        private func tabs(proxy: ScrollViewProxy) -> some View {
            KitoTopTabs(titles, selection: Binding(get: { section }, set: { jump(to: $0, proxy: proxy) }), style: .underline)
                .background(theme.colors.background.opacity(tabsPinned ? 0 : 1))
        }

        private var topButtons: some View {
            HStack(spacing: 10) {
                FoodCircleButton(systemImage: "chevron.left", label: "Back") { dismiss() }
                Spacer()
                FoodCircleButton(systemImage: store.favourites.contains(restaurant.id) ? "heart.fill" : "heart",
                                 label: store.favourites.contains(restaurant.id) ? "Remove from favourites" : "Save to favourites",
                                 tint: store.favourites.contains(restaurant.id) ? FoodPalette.pepper : nil) {
                    store.toggleFavourite(restaurant)
                }
                Button { store.showsCart = true } label: {
                    KitoCartBadge(count: store.cart.totalQuantity, systemImage: "bag.fill")
                        .frame(width: 42, height: 42)
                        .background(.regularMaterial, in: Circle())
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
                }
                .buttonStyle(FoodPressStyle())
                .kitoCartAnchor(store.flight)
                .accessibilityLabel("Basket, \(store.cart.totalQuantity) items")
            }
            .padding(.horizontal, 16)
            .padding(.top, 1)
        }

        @ViewBuilder
        private func reviews(anchorHeight: CGFloat) -> some View {
            FoodRestaurantReviews(restaurant: restaurant)
                .padding(.top, 28)
                .background(alignment: .bottom) {
                    Color.clear.frame(height: 1).id(Self.reviewsTitle)
                }
                .background(alignment: .top) {
                    GeometryReader { geometry in
                        Color.clear.preference(key: FoodSectionOffsetKey.self,
                                               value: [Self.reviewsTitle: geometry.frame(in: .global).minY])
                    }
                }
        }

        // MARK: Behaviour

        private func jump(to title: String, proxy: ScrollViewProxy) {
            followsScroll = false
            section = title
            KitoHaptics.selectionChanged()
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.4)) {
                proxy.scrollTo(title, anchor: title == Self.reviewsTitle ? .bottom : .top)
            }
            Task {
                try? await Task.sleep(nanoseconds: 600_000_000)
                followsScroll = true
            }
        }

        /// The last section whose header has passed under the tabs is the current one.
        private func follow(_ offsets: [String: CGFloat], line: CGFloat) {
            guard followsScroll else { return }
            let passed = titles.filter { (offsets[$0] ?? .infinity) <= line }
            let current = passed.last ?? titles.first ?? section
            if current != section { section = current }
        }

        private func openSheet(_ dish: FoodDish) {
            sheets.present(FoodDishRoute(dishID: dish.id))
        }

        private func quickAdd(_ dish: FoodDish) {
            guard !dish.isCustomisable else { return openSheet(dish) }
            confirmBasket {
                store.flight.fly(from: dish.id, symbol: dish.art.symbol, color: FoodPalette.pepper, style: .arc) {
                    add(dish, size: nil, extras: [], note: "", quantity: 1)
                }
            }
        }

        private func add(_ dish: FoodDish, size: FoodChoice?, extras: [FoodChoice], note: String, quantity: Int) {
            let item = store.add(dish, from: restaurant, size: size, extras: extras, note: note, quantity: quantity)
            KitoHaptics.success()
            store.justAdded = item
        }

        /// Asks before replacing a basket from another restaurant.
        private func confirmBasket(_ proceed: @escaping () -> Void) {
            guard store.needsNewBasket(for: restaurant), let current = store.cartRestaurant else { return proceed() }
            confirmation = KitoConfirmation(
                title: "Start a new basket?",
                message: "Your basket has items from \(current.name). Adding from \(restaurant.name) clears it.",
                confirmTitle: "New basket", isDestructive: true) {
                    store.clearBasket()
                    proceed()
                }
        }
    }
}

// MARK: - Menu

extension FoodShowcase {

    struct FoodRestaurantInfo: View {
        let restaurant: FoodRestaurant
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                Text(restaurant.tagline)
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.onBackground.opacity(0.7))
                HStack(spacing: 0) {
                    fact(value: restaurant.ratingText, caption: "\(restaurant.ratingCount.formatted()) ratings", systemImage: "star.fill",
                         tint: FoodPalette.star)
                    divider
                    fact(value: restaurant.minutesText, caption: "Delivery", systemImage: "clock.fill", tint: nil)
                    divider
                    fact(value: restaurant.deliveryFee == 0 ? "Free" : KitoCartMoney.string(restaurant.deliveryFee),
                         caption: store.distanceText(to: restaurant), systemImage: "scooter", tint: nil)
                }
                .padding(.vertical, 12)
                .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(theme.colors.border, lineWidth: 0.5))
                if let promo = restaurant.promo {
                    Label(promo, systemImage: "tag.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(FoodPalette.pepper)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(FoodPalette.pepper.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }

        private var divider: some View {
            Rectangle().fill(theme.colors.border).frame(width: 0.5, height: 34)
        }

        private func fact(value: String, caption: String, systemImage: String, tint: Color?) -> some View {
            VStack(spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: systemImage).font(.caption).foregroundStyle(tint ?? theme.colors.onSurface)
                    Text(value).font(.subheadline.weight(.bold)).foregroundStyle(theme.colors.onSurface)
                }
                Text(caption).font(.caption).foregroundStyle(theme.colors.onSurface.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
        }
    }

    struct FoodMenuSectionView: View {
        let section: FoodMenuSection
        let restaurant: FoodRestaurant
        /// How far above the header a jump should land, so it clears the pinned tabs.
        let anchorHeight: CGFloat
        let open: (FoodDish) -> Void
        let quickAdd: (FoodDish) -> Void
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(section.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(theme.colors.onBackground)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal, 16)
                    .padding(.top, 26)
                    .padding(.bottom, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(alignment: .bottom) {
                        Color.clear.frame(height: anchorHeight).id(section.title)
                    }
                    .background {
                        GeometryReader { geometry in
                            Color.clear.preference(key: FoodSectionOffsetKey.self, value: [section.title: geometry.frame(in: .global).minY])
                        }
                    }
                ForEach(section.dishes) { dish in
                    FoodDishRow(dish: dish, restaurant: restaurant, open: { open(dish) }, add: { quickAdd(dish) })
                    if dish.id != section.dishes.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
    }

    struct FoodDishRow: View {
        let dish: FoodDish
        let restaurant: FoodRestaurant
        let open: () -> Void
        let add: () -> Void
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        private var inBasket: Int {
            store.cart.items.filter { store.line(for: $0.id)?.dishID == dish.id }.reduce(0) { $0 + $1.quantity }
        }

        private var priceText: String {
            let base = dish.price + (dish.sizes.first?.price ?? 0)
            return (dish.sizes.count > 1 ? "From " : "") + KitoCartMoney.string(base)
        }

        var body: some View {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        if dish.isPopular { FoodTag(text: "Popular", systemImage: "flame.fill") }
                        if dish.isSpicy {
                            Image(systemName: "flame").foregroundStyle(.red).accessibilityLabel("Spicy")
                        }
                        if dish.isVegetarian {
                            Image(systemName: "leaf.fill").foregroundStyle(.green).accessibilityLabel("Vegetarian")
                        }
                    }
                    .font(.caption)
                    Text(dish.name)
                        .font(.headline)
                        .foregroundStyle(theme.colors.onBackground)
                    Text(dish.detail)
                        .font(.subheadline)
                        .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                        .lineLimit(2)
                    Text(priceText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(theme.colors.onBackground)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                ZStack(alignment: .bottomTrailing) {
                    FoodArtView(art: dish.art, symbolScale: 0.42)
                        .frame(width: 104, height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    Button(action: add) {
                        Group {
                            if inBasket > 0 {
                                Text("\(inBasket)")
                                    .font(.subheadline.weight(.heavy).monospacedDigit())
                                    .contentTransition(.numericText())
                            } else {
                                Image(systemName: "plus").font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundStyle(theme.colors.onPrimary)
                        .frame(width: 38, height: 38)
                        .background(theme.colors.primary, in: Circle())
                        .overlay(Circle().strokeBorder(theme.colors.background, lineWidth: 3))
                    }
                    .buttonStyle(FoodPressStyle())
                    .kitoCartFlightSource(id: dish.id, in: store.flight)
                    .offset(x: 6, y: 6)
                    .accessibilityLabel(dish.isCustomisable ? "Choose options for \(dish.name)" : "Add \(dish.name) to basket")
                    .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6), value: inBasket)
                }
                .padding(.trailing, 6)
                .padding(.bottom, 6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture(perform: open)
            .accessibilityElement(children: .contain)
            .accessibilityAction(named: "Show options") { open() }
        }
    }
}

// MARK: - Reviews

extension FoodShowcase.FoodRestaurant {
    /// The seeded reviews as KitoReviews values.
    var kitoReviews: [KitoReview] {
        reviews.enumerated().map { index, seed in
            KitoReview(id: "\(id)-review-\(index)", author: KitoReviewer(seed.author, subtitle: seed.subtitle),
                       rating: seed.rating, title: seed.title, body: seed.body,
                       date: Date().addingTimeInterval(-Double(seed.daysAgo) * 86_400), tags: seed.tags,
                       helpfulCount: seed.helpful, isVerified: true,
                       ownerReply: seed.reply.map { KitoOwnerReply(name: chef, body: $0) })
        }
    }

    /// A histogram that averages to the restaurant's rating: the lower stars keep fixed shares
    /// (averaging 3.39) and five stars takes whatever lifts the mean to `rating`.
    var ratingStats: KitoRatingStats {
        let five = min(max((rating - 3.39) / 1.61, 0), 1)
        let rest = 1 - five
        let shares = [five, rest * 0.62, rest * 0.22, rest * 0.09, rest * 0.07]
        return KitoRatingStats(fiveToOne: shares.map { Int(($0 * Double(ratingCount)).rounded()) })
    }
}

extension FoodShowcase {

    struct FoodRestaurantReviews: View {
        let restaurant: FoodRestaurant
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink(value: FoodRoute.reviews(restaurant.id)) {
                    HStack {
                        Text("Reviews")
                            .font(.title3.weight(.bold))
                            .accessibilityAddTraits(.isHeader)
                        Spacer()
                        Text("See all").font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.right").font(.caption.weight(.bold))
                    }
                    .foregroundStyle(theme.colors.onBackground)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                KitoRatingSummary(stats: restaurant.ratingStats, categories: [
                    KitoCategoryScore("Taste", score: min(restaurant.rating + 0.1, 5), systemImage: "fork.knife"),
                    KitoCategoryScore("Portions", score: max(restaurant.rating - 0.1, 0), systemImage: "takeoutbag.and.cup.and.straw.fill"),
                    KitoCategoryScore("On time", score: max(restaurant.rating - 0.2, 0), systemImage: "clock.fill"),
                ], badge: restaurant.rating >= 4.7 ? "Local favourite" : nil)
                .padding(18)
                .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(restaurant.kitoReviews) { review in
                            KitoReviewCard(review, style: .carouselCard, lineLimit: 4)
                                .frame(width: 290)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    struct FoodAllReviewsScreen: View {
        let restaurant: FoodRestaurant
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            KitoReviewList(reviews: restaurant.kitoReviews, stats: restaurant.ratingStats)
                .background(theme.colors.background.ignoresSafeArea())
                .navigationTitle("\(restaurant.name) reviews")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.visible, for: .navigationBar)
        }
    }
}
