//
//  FoodSearchView.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoSearch

extension FoodShowcase {

    /// One thing search can find: a restaurant or a dish on its menu.
    struct FoodSearchItem: Identifiable, Hashable, Sendable {
        enum Kind: Sendable { case restaurant, dish }

        var id: String
        var kind: Kind
        var title: String
        var subtitle: String
        var detail: String
        var symbol: String
        var cuisine: String
        var rating: Double?
        var restaurantID: String

        /// Everything search matches on.
        var searchText: String { "\(title) \(subtitle) \(cuisine)" }

        static let all: [FoodSearchItem] = FoodData.restaurants.flatMap { restaurant in
            [FoodSearchItem(id: restaurant.id, kind: .restaurant, title: restaurant.name,
                            subtitle: "\(restaurant.cuisine.rawValue) · \(restaurant.area)", detail: restaurant.minutesText,
                            symbol: restaurant.cuisine.systemImage, cuisine: restaurant.cuisine.rawValue, rating: restaurant.rating,
                            restaurantID: restaurant.id)]
            + restaurant.dishes.map { dish in
                FoodSearchItem(id: dish.id, kind: .dish, title: dish.name, subtitle: restaurant.name,
                               detail: KitoCartMoney.string(dish.price), symbol: dish.art.symbol, cuisine: restaurant.cuisine.rawValue,
                               rating: nil, restaurantID: restaurant.id)
            }
        }
    }

    /// KitoSearch's full screen over every restaurant and dish: recents, trending, cuisine
    /// categories that become tokens, typo-tolerant matching and grouped results.
    struct FoodSearchTab: View {
        @Environment(\.kitoTheme) private var theme
        @State private var path: [FoodRoute] = []
        @State private var search = KitoSearchModel<FoodSearchItem>.local(
            FoodSearchItem.all,
            text: { $0.searchText },
            token: { item, token in item.cuisine == token.value },
            trending: ["Pilau", "Nyama choma", "Biryani", "Cinnamon roll", "Smash burger"],
            suggestions: ["Chapati", "Samosa", "Mandazi", "Chips masala", "Madafu", "Butter chicken", "Margherita"])

        var body: some View {
            NavigationStack(path: $path) {
                VStack(spacing: 0) {
                    HStack {
                        Text("Search")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(theme.colors.onBackground)
                            .accessibilityAddTraits(.isHeader)
                        Spacer()
                        FoodExitButton()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    KitoSearchScreen(model: search, prompt: "Restaurants, dishes, cuisines",
                                     categories: FoodCuisine.allCases.map { KitoSearchCategory($0.rawValue, systemImage: $0.systemImage, color: $0.color) },
                                     section: { $0.kind == .restaurant ? "Restaurants" : "Dishes" },
                                     onSelect: { path.append(.restaurant($0.restaurantID)) }) { item, query in
                        KitoSearchResultRow(title: item.title, subtitle: item.subtitle, detail: item.detail,
                                            badge: item.kind == .restaurant ? nil : "Dish", systemImage: item.symbol,
                                            rating: item.rating, query: query)
                    }
                }
                .background(theme.colors.background.ignoresSafeArea())
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: FoodRoute.self) { route in
                    FoodRouteDestination(route: route)
                }
            }
        }
    }
}
