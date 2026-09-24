//
//  SearchSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoSearch

// MARK: - Sample data

private struct SearchRestaurant: Identifiable, Hashable {
    let name: String
    let cuisine: String
    let area: String
    let price: Double
    let rating: Double
    let distance: Double
    let isOpen: Bool
    let delivers: Bool
    let vegetarian: Bool
    let symbol: String

    var id: String { name }
    var priceText: String { "KSh \(Int(price).formatted()) pp" }
    var distanceText: String { "\(distance.formatted(.number.precision(.fractionLength(1)))) km" }
    var searchText: String { "\(name) \(cuisine) \(area)" }
}

private struct SearchProduct: Identifiable, Hashable {
    let name: String
    let category: String
    let price: Double
    let rating: Double
    let symbol: String

    var id: String { name }
    var priceText: String { "KSh \(Int(price).formatted())" }
}

private struct SearchPlace: Identifiable, Hashable {
    let name: String
    let area: String
    let kind: String
    let symbol: String

    var id: String { name }
}

private struct SearchPerson: Identifiable, Hashable {
    let name: String
    let role: String
    let team: String

    var id: String { name }
}

private struct SearchListing: Identifiable, Hashable {
    let id: Int
    let title: String
    let area: String
    let rent: Double
    let symbol: String
}

private enum SearchData {
    static let restaurants: [SearchRestaurant] = [
        SearchRestaurant(name: "Kilimani Grill House", cuisine: "Kenyan", area: "Kilimani", price: 1_400, rating: 4.6, distance: 1.2, isOpen: true, delivers: true, vegetarian: false, symbol: "flame.fill"),
        SearchRestaurant(name: "Choma Zone", cuisine: "Kenyan", area: "Kileleshwa", price: 1_100, rating: 4.4, distance: 2.3, isOpen: true, delivers: false, vegetarian: false, symbol: "flame.fill"),
        SearchRestaurant(name: "Pilau Palace", cuisine: "Swahili", area: "CBD", price: 600, rating: 4.3, distance: 4.1, isOpen: true, delivers: true, vegetarian: true, symbol: "takeoutbag.and.cup.and.straw.fill"),
        SearchRestaurant(name: "Swahili Plate", cuisine: "Swahili", area: "Westlands", price: 1_800, rating: 4.7, distance: 3.4, isOpen: false, delivers: true, vegetarian: true, symbol: "fish.fill"),
        SearchRestaurant(name: "Ethio Kitchen", cuisine: "Ethiopian", area: "Kilimani", price: 1_200, rating: 4.5, distance: 0.8, isOpen: true, delivers: true, vegetarian: true, symbol: "leaf.fill"),
        SearchRestaurant(name: "Habesha Corner", cuisine: "Ethiopian", area: "Parklands", price: 900, rating: 4.2, distance: 5.6, isOpen: false, delivers: false, vegetarian: true, symbol: "leaf.fill"),
        SearchRestaurant(name: "Lavington Pizzeria", cuisine: "Italian", area: "Lavington", price: 1_900, rating: 4.4, distance: 3.9, isOpen: true, delivers: true, vegetarian: true, symbol: "circle.grid.2x2.fill"),
        SearchRestaurant(name: "Karen Pasta Bar", cuisine: "Italian", area: "Karen", price: 2_600, rating: 4.8, distance: 12.5, isOpen: true, delivers: false, vegetarian: true, symbol: "fork.knife"),
        SearchRestaurant(name: "Westlands Sushi Bar", cuisine: "Asian", area: "Westlands", price: 3_200, rating: 4.6, distance: 3.1, isOpen: true, delivers: true, vegetarian: false, symbol: "fish.fill"),
        SearchRestaurant(name: "Dragon Garden", cuisine: "Asian", area: "Kileleshwa", price: 1_700, rating: 4.0, distance: 2.7, isOpen: false, delivers: true, vegetarian: true, symbol: "takeoutbag.and.cup.and.straw.fill"),
        SearchRestaurant(name: "Masala Junction", cuisine: "Indian", area: "Parklands", price: 1_300, rating: 4.7, distance: 5.2, isOpen: true, delivers: true, vegetarian: true, symbol: "flame.fill"),
        SearchRestaurant(name: "Samaki Bay", cuisine: "Seafood", area: "Gigiri", price: 2_900, rating: 4.5, distance: 9.8, isOpen: true, delivers: false, vegetarian: false, symbol: "fish.fill"),
        SearchRestaurant(name: "Tamu Tamu Café", cuisine: "Coffee", area: "Kilimani", price: 700, rating: 4.3, distance: 0.5, isOpen: true, delivers: true, vegetarian: true, symbol: "cup.and.saucer.fill"),
        SearchRestaurant(name: "Kahawa Roasters", cuisine: "Coffee", area: "Westlands", price: 650, rating: 4.9, distance: 3.0, isOpen: true, delivers: false, vegetarian: true, symbol: "cup.and.saucer.fill"),
        SearchRestaurant(name: "Karen Tea Room", cuisine: "Coffee", area: "Karen", price: 900, rating: 4.6, distance: 13.1, isOpen: false, delivers: false, vegetarian: true, symbol: "cup.and.saucer.fill"),
        SearchRestaurant(name: "Karura Garden Bistro", cuisine: "Kenyan", area: "Gigiri", price: 2_200, rating: 4.5, distance: 8.4, isOpen: true, delivers: false, vegetarian: true, symbol: "leaf.fill"),
        SearchRestaurant(name: "Taco Mtaani", cuisine: "Mexican", area: "Kilimani", price: 1_000, rating: 4.1, distance: 1.6, isOpen: true, delivers: true, vegetarian: true, symbol: "takeoutbag.and.cup.and.straw.fill"),
        SearchRestaurant(name: "Uhuru Vegan Kitchen", cuisine: "Vegan", area: "CBD", price: 800, rating: 4.4, distance: 4.5, isOpen: true, delivers: true, vegetarian: true, symbol: "carrot.fill"),
        SearchRestaurant(name: "Rongai Wings", cuisine: "American", area: "Rongai", price: 950, rating: 3.8, distance: 17.2, isOpen: true, delivers: true, vegetarian: false, symbol: "flame.fill"),
        SearchRestaurant(name: "Mkate Bakery", cuisine: "Bakery", area: "Lavington", price: 500, rating: 4.6, distance: 3.6, isOpen: false, delivers: true, vegetarian: true, symbol: "birthday.cake.fill"),
    ]

    static let restaurantTrending = ["Nyama choma", "Pilau", "Sushi", "Coffee", "Pizza", "Vegan"]

    static let foodCategories = [
        KitoSearchCategory("Kenyan", systemImage: "flame.fill", color: .orange),
        KitoSearchCategory("Ethiopian", systemImage: "leaf.fill", color: .green),
        KitoSearchCategory("Italian", systemImage: "fork.knife", color: .red),
        KitoSearchCategory("Asian", systemImage: "fish.fill", color: .indigo),
        KitoSearchCategory("Coffee", systemImage: "cup.and.saucer.fill", color: .brown),
        KitoSearchCategory("Seafood", systemImage: "water.waves", color: .teal),
    ]

    static let products: [SearchProduct] = [
        SearchProduct(name: "Tembo Runner Sneakers", category: "Shoes", price: 6_500, rating: 4.6, symbol: "shoeprints.fill"),
        SearchProduct(name: "Safari Chelsea Boots", category: "Shoes", price: 9_800, rating: 4.4, symbol: "shoeprints.fill"),
        SearchProduct(name: "Leather Sandals", category: "Shoes", price: 2_400, rating: 4.2, symbol: "shoeprints.fill"),
        SearchProduct(name: "Kitenge Shirt", category: "Clothing", price: 3_200, rating: 4.7, symbol: "tshirt.fill"),
        SearchProduct(name: "Linen Kanzu", category: "Clothing", price: 4_500, rating: 4.5, symbol: "tshirt.fill"),
        SearchProduct(name: "Kikoi Beach Towel", category: "Home", price: 1_800, rating: 4.8, symbol: "sun.max.fill"),
        SearchProduct(name: "Ceramic Kahawa Mug", category: "Home", price: 950, rating: 4.3, symbol: "cup.and.saucer.fill"),
        SearchProduct(name: "Soapstone Bowl", category: "Home", price: 1_400, rating: 4.6, symbol: "circle.bottomhalf.filled"),
        SearchProduct(name: "Kiondo Tote", category: "Bags", price: 2_900, rating: 4.9, symbol: "bag.fill"),
        SearchProduct(name: "Sisal Market Basket", category: "Bags", price: 1_600, rating: 4.4, symbol: "basket.fill"),
        SearchProduct(name: "Maasai Beaded Bracelet", category: "Accessories", price: 800, rating: 4.7, symbol: "circle.hexagongrid.fill"),
        SearchProduct(name: "Kenyan AA Coffee 500g", category: "Groceries", price: 1_200, rating: 4.9, symbol: "leaf.fill"),
        SearchProduct(name: "Chai Masala Blend", category: "Groceries", price: 450, rating: 4.5, symbol: "leaf.fill"),
        SearchProduct(name: "Macadamia Nuts 1kg", category: "Groceries", price: 2_100, rating: 4.6, symbol: "leaf.fill"),
        SearchProduct(name: "Solar Lantern", category: "Electronics", price: 3_500, rating: 4.3, symbol: "lightbulb.fill"),
        SearchProduct(name: "Wireless Earbuds", category: "Electronics", price: 5_900, rating: 4.1, symbol: "earbuds"),
    ]

    static let productCategories = [
        KitoSearchCategory("Shoes", systemImage: "shoeprints.fill", color: .purple),
        KitoSearchCategory("Clothing", systemImage: "tshirt.fill", color: .pink),
        KitoSearchCategory("Home", systemImage: "house.fill", color: .orange),
        KitoSearchCategory("Groceries", systemImage: "basket.fill", color: .green),
    ]

    static let places: [SearchPlace] = [
        SearchPlace(name: "Karura Forest", area: "Gigiri", kind: "Park", symbol: "tree.fill"),
        SearchPlace(name: "Nairobi National Park", area: "Lang'ata", kind: "Park", symbol: "pawprint.fill"),
        SearchPlace(name: "Giraffe Centre", area: "Karen", kind: "Attraction", symbol: "binoculars.fill"),
        SearchPlace(name: "Nairobi Arboretum", area: "Kileleshwa", kind: "Park", symbol: "tree.fill"),
        SearchPlace(name: "Uhuru Gardens", area: "Lang'ata", kind: "Park", symbol: "leaf.fill"),
        SearchPlace(name: "Ngong Hills", area: "Ngong", kind: "Hike", symbol: "mountain.2.fill"),
        SearchPlace(name: "Bomas Cultural Centre", area: "Lang'ata", kind: "Attraction", symbol: "music.note.house.fill"),
        SearchPlace(name: "City Market", area: "CBD", kind: "Market", symbol: "basket.fill"),
        SearchPlace(name: "Maasai Market", area: "CBD", kind: "Market", symbol: "bag.fill"),
        SearchPlace(name: "Two Rivers Mall", area: "Ruaka", kind: "Mall", symbol: "building.2.fill"),
        SearchPlace(name: "Sarit Centre", area: "Westlands", kind: "Mall", symbol: "building.2.fill"),
        SearchPlace(name: "Village Market", area: "Gigiri", kind: "Mall", symbol: "building.2.fill"),
        SearchPlace(name: "Junction Mall", area: "Ngong Road", kind: "Mall", symbol: "building.2.fill"),
        SearchPlace(name: "Convention Centre", area: "CBD", kind: "Landmark", symbol: "building.columns.fill"),
        SearchPlace(name: "Jomo Kenyatta Airport", area: "Embakasi", kind: "Airport", symbol: "airplane"),
        SearchPlace(name: "Wilson Airport", area: "Lang'ata", kind: "Airport", symbol: "airplane"),
    ]

    static let people: [SearchPerson] = [
        SearchPerson(name: "Wanjiru Kamau", role: "Product Designer", team: "Design"),
        SearchPerson(name: "Otieno Odhiambo", role: "iOS Engineer", team: "Engineering"),
        SearchPerson(name: "Achieng Atieno", role: "Engineering Manager", team: "Engineering"),
        SearchPerson(name: "Kiprotich Rotich", role: "Account Executive", team: "Sales"),
        SearchPerson(name: "Amina Hassan", role: "Data Scientist", team: "Engineering"),
        SearchPerson(name: "Mwangi Njoroge", role: "Backend Engineer", team: "Engineering"),
        SearchPerson(name: "Zawadi Mutua", role: "UX Researcher", team: "Design"),
        SearchPerson(name: "Baraka Kiprono", role: "Sales Lead", team: "Sales"),
        SearchPerson(name: "Njeri Wambui", role: "Brand Designer", team: "Design"),
        SearchPerson(name: "Juma Omondi", role: "Android Engineer", team: "Engineering"),
        SearchPerson(name: "Faith Chebet", role: "Customer Success", team: "Sales"),
        SearchPerson(name: "Brian Kariuki", role: "Staff Engineer", team: "Engineering"),
    ]

    static let teamScopes = [
        KitoSearchScope("all", title: "All"),
        KitoSearchScope("engineering", title: "Engineering"),
        KitoSearchScope("design", title: "Design"),
        KitoSearchScope("sales", title: "Sales"),
    ]

    static let listings: [SearchListing] = {
        let areas = ["Kilimani", "Westlands", "Kileleshwa", "Lavington", "Karen", "Parklands", "Ruaka", "South B"]
        let kinds = [("Studio", "bed.double.fill", 28_000.0), ("1-bed apartment", "building.fill", 45_000.0),
                     ("2-bed apartment", "building.2.fill", 70_000.0), ("3-bed maisonette", "house.fill", 120_000.0)]
        var result: [SearchListing] = []
        for round in 0..<8 {
            for (areaIndex, area) in areas.enumerated() {
                let kind = kinds[(round + areaIndex) % kinds.count]
                let rent = kind.2 + Double((round * 7 + areaIndex * 3) % 10) * 2_500
                result.append(SearchListing(id: result.count, title: "\(kind.0), \(area)", area: area, rent: rent, symbol: kind.1))
            }
        }
        return result
    }()

    static var restaurantFilters: KitoFilterConfiguration<SearchRestaurant> {
        let cuisines = ["Kenyan", "Swahili", "Ethiopian", "Italian", "Asian", "Coffee"]
        return KitoFilterConfiguration(
            facetsTitle: "Cuisine",
            facets: cuisines.map { cuisine in KitoFilterFacet(cuisine.lowercased(), title: cuisine) { $0.cuisine == cuisine } },
            toggles: [
                KitoFilterFacet("open", title: "Open now", systemImage: "clock.fill") { $0.isOpen },
                KitoFilterFacet("delivery", title: "Delivers", systemImage: "bicycle") { $0.delivers },
                KitoFilterFacet("veg", title: "Vegetarian options", systemImage: "leaf.fill") { $0.vegetarian },
            ],
            price: { $0.price },
            priceBounds: 0...3_500,
            priceStep: 100,
            currencyCode: "KES",
            rating: { $0.rating },
            distance: { $0.distance },
            distanceBounds: 1...20,
            sorts: [
                KitoSortOption("rating", title: "Top rated", systemImage: "star.fill") { $0.rating > $1.rating },
                KitoSortOption("nearest", title: "Nearest", systemImage: "location.fill") { $0.distance < $1.distance },
                KitoSortOption("cheapest", title: "Price: low to high", systemImage: "arrow.up") { $0.price < $1.price },
            ]
        )
    }
}

private struct SearchOfflineError: LocalizedError {
    var errorDescription: String? { "You're offline. Check your connection, then try again." }
}

/// Lets the flaky-backend sample switch the pretend network off and on.
@MainActor
@Observable
private final class SearchNetworkSwitch {
    var offline = false
}

private func searchRestaurantRow(_ restaurant: SearchRestaurant, query: String, style: KitoSearchResultRowStyle = .card) -> KitoSearchResultRow {
    KitoSearchResultRow(
        title: restaurant.name,
        subtitle: "\(restaurant.cuisine) · \(restaurant.area)",
        detail: style == .list ? restaurant.distanceText : "\(restaurant.distanceText) · \(restaurant.priceText)",
        badge: restaurant.isOpen ? "Open" : "Closed",
        systemImage: restaurant.symbol,
        rating: restaurant.rating,
        query: query,
        style: style
    )
}

// MARK: - Field samples

private struct SearchCapsuleFieldSample: View {
    @State private var text = ""
    @State private var submitted: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            KitoSearchField(text: $text, prompt: "Search restaurants", onSubmit: { submitted = $0 })
            Text(submitted.map { "Searched for “\($0)”" } ?? "Tap the field: it lifts, a ring grows and Cancel slides in.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)
                .animation(.snappy, value: submitted)
        }
    }
}

private struct SearchGlassFieldSample: View {
    @State private var text = ""

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [.teal, .indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(.white.opacity(0.18)).frame(width: 160).offset(x: 110, y: 90)
            Circle().fill(.orange.opacity(0.35)).frame(width: 120).offset(x: -120, y: 130)
            VStack(alignment: .leading, spacing: 12) {
                Text("Diani Beach")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                KitoSearchField(text: $text, prompt: "Villas, boat trips, food", style: .glass, tint: .white)
            }
            .padding(20)
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct SearchUnderlinedFieldSample: View {
    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Find a colleague").font(.title2.bold())
            KitoSearchField(text: $text, prompt: "Name, role or team", style: .underlined, showsCancelButton: false)
            Text("The line fills with colour from the centre when the field has focus.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SearchHeroFieldSample: View {
    @State private var text = ""
    @State private var listening = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Karibu, Wanjiru").font(.title.bold())
                Text("What are you craving tonight?").foregroundStyle(.secondary)
            }
            KitoSearchField(text: $text, prompt: "Nyama choma, sushi, pilau…", style: .prominent) {
                KitoVoiceSearchButton(isListening: listening) { listening.toggle() }
            }
            HStack(spacing: 8) {
                ForEach(["Near me", "Open now", "Delivery"], id: \.self) { chip in
                    Text(chip)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.primary.opacity(0.07)))
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Color.orange.opacity(0.22), Color.pink.opacity(0.12), .clear], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
    }
}

private struct SearchTokenFieldSample: View {
    @State private var text = ""
    @State private var tokens = [KitoSearchToken(value: "Restaurants", systemImage: "fork.knife")]
    private let available = [
        KitoSearchToken(value: "Restaurants", systemImage: "fork.knife"),
        KitoSearchToken(label: "near", value: "Westlands", systemImage: "mappin"),
        KitoSearchToken(label: "", value: "Open now", systemImage: "clock"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            KitoSearchField(text: $text, prompt: "Search Nairobi", tokens: $tokens)
            Text("Add a token").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(available) { token in
                    Button(token.text) {
                        withAnimation(.snappy) {
                            if !tokens.contains(token) { tokens.append(token) }
                        }
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                    .disabled(tokens.contains(token))
                }
            }
        }
    }
}

private struct SearchScopeFieldSample: View {
    @State private var text = ""
    @State private var scope: String?

    private var matches: [SearchPerson] {
        let inScope = SearchData.people.filter { scope == nil || scope == "all" || $0.team.lowercased() == scope }
        return KitoFuzzy.filter(inScope, query: text) { "\($0.name) \($0.role)" }.map(\.item)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KitoSearchField(text: $text, prompt: "Search the team", scopes: SearchData.teamScopes, scope: $scope)
            ForEach(matches.prefix(4)) { person in
                KitoSearchResultRow(title: person.name, subtitle: person.role, detail: person.team, systemImage: "person.fill", query: text)
            }
            Text("\(matches.count) people").font(.footnote).foregroundStyle(.secondary)
        }
        .animation(.snappy, value: matches)
    }
}

private struct SearchVoiceFieldSample: View {
    @State private var text = ""
    @State private var listening = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            KitoSearchField(text: $text, prompt: "Ask for anything") {
                KitoVoiceSearchButton(isListening: listening) { listening.toggle() }
            }
            Text(listening ? "Listening…" : "Tap the microphone. This demo “hears” a phrase after a moment.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .task(id: listening) {
            guard listening else { return }
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled else { return }
            text = "nyama choma near Kilimani"
            listening = false
        }
    }
}

// MARK: - Screen samples

private struct SearchRestaurantScreen: View {
    @State private var model = KitoSearchModel.local(
        SearchData.restaurants,
        text: { $0.searchText },
        token: { restaurant, token in restaurant.cuisine == token.value },
        latency: .milliseconds(450),
        recentsKey: "kito.sample.search.restaurants",
        trending: SearchData.restaurantTrending,
        suggestions: SearchData.restaurants.map(\.name)
    )

    var body: some View {
        KitoSearchScreen(
            model: model,
            prompt: "Restaurants, dishes, areas",
            categories: SearchData.foodCategories,
            skeletonStyle: .card,
            section: { $0.area }
        ) { restaurant, query in
            searchRestaurantRow(restaurant, query: query)
        }
    }
}

private struct SearchShopScreen: View {
    @State private var model = KitoSearchModel.local(
        SearchData.products,
        text: { "\($0.name) \($0.category)" },
        token: { product, token in product.category == token.value },
        pageSize: 30,
        latency: .milliseconds(350),
        recentsKey: "kito.sample.search.shop",
        trending: ["Sneakers", "Kikoi", "Coffee", "Tote", "Earbuds"]
    )

    var body: some View {
        KitoSearchScreen(
            model: model,
            prompt: "Search the shop",
            fieldStyle: .glass,
            categories: SearchData.productCategories,
            tint: .purple,
            section: { $0.category }
        ) { product, query in
            KitoSearchResultRow(title: product.name, subtitle: product.category, detail: product.priceText,
                                systemImage: product.symbol, rating: product.rating, query: query, tint: .purple)
        }
    }
}

private struct SearchPlacesScreen: View {
    @State private var model = KitoSearchModel.local(
        SearchData.places,
        text: { "\($0.name) \($0.area) \($0.kind)" },
        trigger: .onSubmit,
        recentsKey: "kito.sample.search.places",
        trending: ["Karura Forest", "Giraffe Centre", "Maasai Market", "Airport"],
        suggestions: SearchData.places.map(\.name)
    )

    var body: some View {
        KitoSearchScreen(model: model, prompt: "Parks, malls, landmarks", fieldStyle: .prominent, tint: .green) { place, query in
            KitoSearchResultRow(title: place.name, subtitle: "\(place.kind) · \(place.area)", systemImage: place.symbol,
                                query: query, style: .list, tint: .green)
        }
    }
}

private struct SearchPeopleScreen: View {
    @State private var model = KitoSearchModel.local(
        SearchData.people,
        text: { "\($0.name) \($0.role)" },
        scope: { person, scope in scope == "all" || person.team.lowercased() == scope },
        trending: ["Designer", "iOS", "Sales"],
        suggestions: SearchData.people.map(\.name)
    )

    var body: some View {
        KitoSearchScreen(model: model, prompt: "Name or role", scopes: SearchData.teamScopes, section: { $0.team }) { person, query in
            KitoSearchResultRow(title: person.name, subtitle: person.role, systemImage: "person.fill", query: query, highlight: .marker)
        }
    }
}

private struct SearchFlakyScreen: View {
    @State private var network: SearchNetworkSwitch
    @State private var model: KitoSearchModel<SearchRestaurant>

    init() {
        let network = SearchNetworkSwitch()
        _network = State(initialValue: network)
        _model = State(initialValue: KitoSearchModel<SearchRestaurant>(
            debounce: .milliseconds(350),
            recentsKey: nil,
            trending: ["Pizza", "Coffee", "Sushi in Ruaka"]
        ) { request in
            try await Task.sleep(for: .milliseconds(1_100))
            if network.offline { throw SearchOfflineError() }
            let hits = KitoFuzzy.filter(SearchData.restaurants, query: request.query) { $0.name }.map(\.item)
            return KitoSearchPage(items: hits, hasMore: false, totalCount: hits.count)
        })
    }

    var body: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $network.offline) {
                Label("Pretend we're offline", systemImage: "wifi.slash").font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 20)
            .padding(.top, 54)
            .padding(.bottom, 4)
            KitoSearchScreen(model: model, prompt: "Try “zzz” or go offline", skeletonStyle: .card) { restaurant, query in
                searchRestaurantRow(restaurant, query: query)
            }
        }
    }
}

private struct SearchEndlessScreen: View {
    @State private var model = KitoSearchModel.local(
        SearchData.listings,
        text: { $0.title },
        pageSize: 12,
        latency: .milliseconds(700),
        trending: ["Apartment", "Kilimani", "Studio", "Maisonette"]
    )

    var body: some View {
        KitoSearchScreen(model: model, prompt: "Try “apartment”", tint: .teal) { listing, query in
            KitoSearchResultRow(title: listing.title, subtitle: "Unfurnished · \(listing.area)",
                                detail: "KSh \(Int(listing.rent).formatted())/mo", systemImage: listing.symbol,
                                query: query, tint: .teal)
        }
    }
}

// MARK: - Filter samples

private struct SearchChipsSample: View {
    @State private var state = KitoFilterState()
    private let configuration = SearchData.restaurantFilters

    private var results: [SearchRestaurant] { configuration.apply(state, to: SearchData.restaurants) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KitoFilterChips(configuration.options(for: state, in: SearchData.restaurants), selection: $state.facets,
                            activeFilters: state.activeCount)
                .padding(.horizontal, -16)
            Toggle("Open now", isOn: toggleBinding("open"))
                .font(.subheadline.weight(.semibold))
            Text("\(results.count) restaurants")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
            ForEach(results.prefix(3)) { restaurant in
                searchRestaurantRow(restaurant, query: "", style: .list)
            }
        }
        .animation(.snappy, value: state)
    }

    private func toggleBinding(_ id: String) -> Binding<Bool> {
        Binding(get: { state.toggles.contains(id) }, set: { _ in state.reduce(.toggle(id)) })
    }
}

private struct SearchFilterSheetScreen: View {
    @State private var state = KitoFilterState(toggles: ["open"])
    @State private var showFilters = false
    private let configuration = SearchData.restaurantFilters

    private var results: [SearchRestaurant] { configuration.apply(state, to: SearchData.restaurants) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Restaurants").font(.largeTitle.bold()).padding(.horizontal, 20).padding(.top, 56)
            KitoFilterChips(configuration.options(for: state, in: SearchData.restaurants), selection: $state.facets,
                            activeFilters: state.activeCount) { showFilters = true }
            KitoAppliedFilterPills(configuration.appliedFilters(for: state),
                                   onRemove: { state.reduce(.remove($0.kind)) },
                                   onClearAll: { state.reduce(.clearAll) })
            List(results) { restaurant in
                searchRestaurantRow(restaurant, query: "")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
        }
        .animation(.snappy, value: state)
        .sheet(isPresented: $showFilters) {
            KitoFilterSheet(state: $state, configuration: configuration, items: SearchData.restaurants)
        }
    }
}

private struct SearchPillsSample: View {
    private static let start = KitoFilterState(facets: ["kenyan", "ethiopian"], toggles: ["open", "delivery"],
                                               price: 500...2_000, minimumRating: 4, maximumDistance: 5)
    @State private var state = start
    private let configuration = SearchData.restaurantFilters

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            KitoAppliedFilterPills(configuration.appliedFilters(for: state),
                                   onRemove: { state.reduce(.remove($0.kind)) },
                                   onClearAll: { state.reduce(.clearAll) })
                .padding(.horizontal, -16)
            HStack {
                Text("\(configuration.count(state, in: SearchData.restaurants)) of \(SearchData.restaurants.count) restaurants")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                Spacer()
                Button("Reset") { withAnimation(.snappy) { state = Self.start } }
                    .font(.footnote.weight(.semibold))
                    .disabled(state == Self.start)
            }
        }
        .animation(.snappy, value: state)
    }
}

private struct SearchWithFiltersScreen: View {
    @State private var model = KitoSearchModel.local(
        SearchData.restaurants,
        text: { $0.searchText },
        filters: SearchData.restaurantFilters,
        latency: .milliseconds(300),
        trending: SearchData.restaurantTrending,
        suggestions: SearchData.restaurants.map(\.name)
    )
    @State private var showFilters = false
    private let configuration = SearchData.restaurantFilters

    var body: some View {
        KitoSearchScreen(model: model, prompt: "Search, then filter", skeletonStyle: .card, tint: .orange) { restaurant, query in
            searchRestaurantRow(restaurant, query: query)
        } header: {
            VStack(spacing: 4) {
                KitoFilterChips(configuration.options(for: model.filters, in: SearchData.restaurants),
                                selection: $model.filters.facets, tint: .orange,
                                activeFilters: model.filters.activeCount) { showFilters = true }
                KitoAppliedFilterPills(configuration.appliedFilters(for: model.filters), tint: .orange,
                                       onRemove: { model.filters.reduce(.remove($0.kind)) },
                                       onClearAll: { model.filters.reduce(.clearAll) })
            }
            .padding(.bottom, 6)
        }
        .sheet(isPresented: $showFilters) {
            KitoFilterSheet(state: $model.filters, configuration: configuration, items: SearchData.restaurants, tint: .orange)
        }
    }
}

// MARK: - Building block samples

private struct SearchHighlightSample: View {
    @State private var query = "kil"
    private let names = ["Kilimani Grill House", "Karura Garden Bistro", "Kahawa Roasters", "Masala Junction"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField("Query", text: $query)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            ForEach(names, id: \.self) { name in
                VStack(alignment: .leading, spacing: 4) {
                    KitoHighlightedText(name, matching: query, style: .bold)
                    KitoHighlightedText(name, matching: query, style: .tint)
                    KitoHighlightedText(name, matching: query, style: .marker)
                }
            }
            Text("Bold, tint and marker. Try “grl hse” or “kahwa”.").font(.footnote).foregroundStyle(.secondary)
        }
    }
}

private struct SearchFuzzySample: View {
    @State private var query = "resturant"
    private let names = SearchData.restaurants.map(\.name) + SearchData.places.map(\.name) + ["Restaurant Week", "Nyama Mama"]

    private var results: [KitoFuzzyResult<String>] {
        Array(KitoFuzzy.filter(names, query: query) { $0 }.prefix(5))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KitoSearchField(text: $query, prompt: "Type with a typo", showsCancelButton: false)
            HStack(spacing: 8) {
                ForEach(["nyamma", "swahli", "grd bistro", "jomo airprt"], id: \.self) { preset in
                    Button(preset) { query = preset }
                        .font(.caption.weight(.semibold))
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .controlSize(.mini)
                }
            }
            ForEach(results, id: \.item) { result in
                HStack(spacing: 10) {
                    KitoHighlightedText(result.item, ranges: result.match.ranges, style: .tint)
                    Spacer()
                    ProgressView(value: result.match.score).frame(width: 60)
                    Text(result.match.score.formatted(.number.precision(.fractionLength(2))))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            if results.isEmpty {
                Text("No match").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .animation(.snappy, value: query)
    }
}

private struct SearchRowStylesSample: View {
    private let restaurant = SearchData.restaurants[0]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(KitoSearchResultRowStyle.allCases, id: \.self) { style in
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(describing: style).capitalized).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    searchRestaurantRow(restaurant, query: "grill", style: style)
                }
            }
        }
    }
}

private struct SearchRecentsSample: View {
    private let store = KitoRecentSearchStore(key: "kito.sample.search.recents.demo")
    @State private var recents = KitoRecentSearches(["Pilau", "Karura Forest", "Kiondo tote"], limit: 5)
    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KitoSearchField(text: $text, prompt: "Search, then press Return", showsCancelButton: false, onSubmit: add)
            HStack {
                Text("Recent · newest first, max 5").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                Spacer()
                Button("Clear all") { update { $0.removeAll() } }
                    .font(.footnote.weight(.semibold))
                    .disabled(recents.isEmpty)
            }
            ForEach(recents.items, id: \.self) { recent in
                HStack {
                    Image(systemName: "clock.arrow.circlepath").foregroundStyle(.secondary)
                    Text(recent)
                    Spacer()
                    Button { update { $0.remove(recent) } } label: {
                        Image(systemName: "xmark").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(recent)")
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: recents)
        .onAppear {
            let saved = store.load(limit: 5)
            if !saved.isEmpty { recents = saved }
        }
    }

    private func add(_ query: String) {
        update { $0.add(query) }
        text = ""
    }

    private func update(_ change: (inout KitoRecentSearches) -> Void) {
        change(&recents)
        store.save(recents)
    }
}

private struct SearchSkeletonSample: View {
    var body: some View {
        VStack(spacing: 14) {
            KitoSearchSkeletonRow(style: .list)
            KitoSearchSkeletonRow(style: .card)
            KitoSearchSkeletonRow(style: .media)
        }
    }
}

private struct SearchStatesSample: View {
    @State private var showError = false

    var body: some View {
        VStack(spacing: 12) {
            Picker("State", selection: $showError) {
                Text("Empty").tag(false)
                Text("Error").tag(true)
            }
            .pickerStyle(.segmented)
            if showError {
                KitoSearchErrorState(message: "The request timed out.") {}
                    .transition(.opacity)
            } else {
                KitoSearchEmptyState(query: "sushi in Ruaka", correction: "Sushi", suggestions: ["Seafood", "Asian", "Westlands"],
                                     hasFilters: true, onClearFilters: {})
                    .transition(.opacity)
            }
        }
        .animation(.snappy, value: showError)
    }
}

// MARK: - Gallery

enum SearchSamples {
    private static let field = KitSection("Search field", symbol: "magnifyingglass", [
        KitSample("Capsule", "The everyday field: focus ring, clear and Cancel.", code: """
        @State private var query = ""

        KitoSearchField(text: $query, prompt: "Search restaurants",
                        onSubmit: { submitted in search(submitted) })
        """) { SearchCapsuleFieldSample() },
        KitSample("Glass", "Frosted material over colour or photos.", code: """
        KitoSearchField(text: $query, prompt: "Villas, boat trips, food",
                        style: .glass, tint: .white)
        """) { SearchGlassFieldSample() },
        KitSample("Underlined", "Just a line that fills with colour on focus.", code: """
        KitoSearchField(text: $query, prompt: "Name, role or team",
                        style: .underlined, showsCancelButton: false)
        """) { SearchUnderlinedFieldSample() },
        KitSample("Prominent hero", "A tall raised field for a home screen.", code: """
        KitoSearchField(text: $query, prompt: "Nyama choma, sushi, pilau…", style: .prominent) {
            KitoVoiceSearchButton(isListening: listening) { listening.toggle() }
        }
        """) { SearchHeroFieldSample() },
        KitSample("Tokens in the field", "Chips such as “in: Restaurants” that narrow the search.", code: """
        @State private var tokens = [KitoSearchToken(value: "Restaurants", systemImage: "fork.knife")]

        KitoSearchField(text: $query, prompt: "Search Nairobi", tokens: $tokens)
        tokens.append(KitoSearchToken(label: "near", value: "Westlands", systemImage: "mappin"))
        """) { SearchTokenFieldSample() },
        KitSample("Scopes", "A sliding segment row under the field.", code: """
        KitoSearchField(text: $query, prompt: "Search the team",
                        scopes: [KitoSearchScope("all", title: "All"),
                                 KitoSearchScope("engineering", title: "Engineering"),
                                 KitoSearchScope("design", title: "Design")],
                        scope: $scope)
        """) { SearchScopeFieldSample() },
        KitSample("Voice search", "A microphone in the accessory slot that turns into a waveform.", code: """
        KitoSearchField(text: $query, prompt: "Ask for anything") {
            KitoVoiceSearchButton(isListening: dictation.isListening) {
                dictation.toggle()   // your Speech framework code
            }
        }
        """) { SearchVoiceFieldSample() },
    ])

    private static let screens = KitSection("Search screens", symbol: "rectangle.stack", [
        KitSample("Nairobi restaurants", "Recents, trending, categories, then results by area.", code: """
        @State private var search = KitoSearchModel.local(
            restaurants,
            text: { "\\($0.name) \\($0.cuisine) \\($0.area)" },
            token: { place, token in place.cuisine == token.value },
            recentsKey: "food.recents",
            trending: ["Nyama choma", "Pilau", "Sushi"])

        KitoSearchScreen(model: search, prompt: "Restaurants, dishes, areas",
                         categories: [KitoSearchCategory("Kenyan", systemImage: "flame.fill")],
                         skeletonStyle: .card, section: { $0.area }) { place, query in
            KitoSearchResultRow(title: place.name, subtitle: place.cuisine, detail: place.distanceText,
                                badge: place.isOpen ? "Open" : "Closed", systemImage: "fork.knife",
                                rating: place.rating, query: query, style: .card)
        }
        """) { ModalStage { SearchRestaurantScreen() } },
        KitSample("Shop", "Glass field, category tokens and results by department.", code: """
        KitoSearchScreen(model: search, prompt: "Search the shop", fieldStyle: .glass,
                         categories: departments, tint: .purple, section: { $0.category }) { product, query in
            KitoSearchResultRow(title: product.name, subtitle: product.category,
                                detail: product.priceText, systemImage: product.symbol,
                                rating: product.rating, query: query)
        }
        """) { ModalStage { SearchShopScreen() } },
        KitSample("Suggestions as you type", "Search on Return; completions show the matched part in bold.", code: """
        @State private var search = KitoSearchModel.local(
            places, text: { $0.name }, trigger: .onSubmit,
            suggestions: places.map(\\.name))

        KitoSearchScreen(model: search, prompt: "Parks, malls, landmarks", fieldStyle: .prominent) { place, query in
            KitoSearchResultRow(title: place.name, subtitle: place.area, query: query)
        }
        """) { ModalStage { SearchPlacesScreen() } },
        KitSample("People and scopes", "Scopes filter by team; results are grouped by team.", code: """
        @State private var search = KitoSearchModel.local(
            people, text: { "\\($0.name) \\($0.role)" },
            scope: { person, scope in scope == "all" || person.team.lowercased() == scope })

        KitoSearchScreen(model: search, scopes: teams, section: { $0.team }) { person, query in
            KitoSearchResultRow(title: person.name, subtitle: person.role,
                                systemImage: "person.fill", query: query, highlight: .marker)
        }
        """) { ModalStage { SearchPeopleScreen() } },
        KitSample("Loading, empty and errors", "Skeletons, “No results for…”, and Retry after going offline.", code: """
        @State private var search = KitoSearchModel<Restaurant> { request in
            let page = try await api.search(request.query, page: request.page)
            return KitoSearchPage(items: page.items, hasMore: page.hasNext, totalCount: page.total)
        }
        // A thrown error shows the error state; Retry calls search.retry().
        // An empty page shows "No results for “x”" with "Did you mean …?".
        """) { ModalStage { SearchFlakyScreen() } },
        KitSample("Endless results", "Loads the next page as you reach the end.", code: """
        @State private var search = KitoSearchModel.local(listings, text: { $0.title },
                                                          pageSize: 12, latency: .milliseconds(700))
        // KitoSearchScreen calls search.loadMore() when the last row appears.
        // With your own backend, return KitoSearchPage(items:, hasMore:, totalCount:).
        """) { ModalStage { SearchEndlessScreen() } },
    ])

    private static let filters = KitSection("Filters", symbol: "line.3.horizontal.decrease.circle", [
        KitSample("Filter chips", "Multi-select chips whose counts follow the other filters.", code: """
        let configuration = KitoFilterConfiguration<Restaurant>(
            facets: [KitoFilterFacet("kenyan", title: "Kenyan") { $0.cuisine == "Kenyan" }],
            toggles: [KitoFilterFacet("open", title: "Open now") { $0.isOpen }])

        KitoFilterChips(configuration.options(for: state, in: restaurants),
                        selection: $state.facets, activeFilters: state.activeCount)
        let visible = configuration.apply(state, to: restaurants)
        """) { SearchChipsSample() },
        KitSample("Filter sheet", "Sort, price over a histogram, rating, distance, toggles, live count.", code: """
        .sheet(isPresented: $showFilters) {
            KitoFilterSheet(state: $state, configuration: configuration, items: restaurants)
        }

        KitoFilterConfiguration<Restaurant>(
            price: { $0.price }, priceBounds: 0...3_500, priceStep: 100, currencyCode: "KES",
            rating: { $0.rating }, distance: { $0.distance }, distanceBounds: 1...20,
            sorts: [KitoSortOption("rating", title: "Top rated") { $0.rating > $1.rating }])
        """) { ModalStage { SearchFilterSheetScreen() } },
        KitSample("Applied filter pills", "Each filter that's on, with remove and Clear all.", code: """
        KitoAppliedFilterPills(configuration.appliedFilters(for: state),
                               onRemove: { state.reduce(.remove($0.kind)) },
                               onClearAll: { state.reduce(.clearAll) })
        """) { SearchPillsSample() },
        KitSample("Search with filters", "Chips and pills under the field, filters sent with every request.", code: """
        @State private var search = KitoSearchModel.local(restaurants, text: { $0.name },
                                                          filters: configuration)

        KitoSearchScreen(model: search) { place, query in
            KitoSearchResultRow(title: place.name, query: query, style: .card)
        } header: {
            KitoFilterChips(configuration.options(for: search.filters, in: restaurants),
                            selection: $search.filters.facets,
                            activeFilters: search.filters.activeCount) { showFilters = true }
        }
        """) { ModalStage { SearchWithFiltersScreen() } },
    ])

    private static let blocks = KitSection("Building blocks", symbol: "square.stack.3d.up", [
        KitSample("Highlighted text", "Bold, tint or marker on the characters that matched.", code: """
        KitoHighlightedText("Kilimani Grill House", matching: query, style: .marker)
        KitoHighlightedText(text, ranges: match.ranges, style: .bold)
        """) { SearchHighlightSample() },
        KitSample("Typo-tolerant matching", "Scores and ranges for typos, gaps and initials.", code: """
        KitoFuzzy.match("resturant", in: "Restaurant Week")   // ranges [0..<10]
        let best = KitoFuzzy.filter(names, query: query) { $0 }
        best.first?.match.score                                // 0…1
        """) { SearchFuzzySample() },
        KitSample("Result row styles", "List, card and media.", code: """
        KitoSearchResultRow(title: "Kilimani Grill House", subtitle: "Kenyan · Kilimani",
                            detail: "1.2 km", badge: "Open", systemImage: "flame.fill",
                            rating: 4.6, query: "grill", style: .card)   // .list, .media
        """) { SearchRowStylesSample() },
        KitSample("Recent searches", "Newest first, no repeats, capped, saved to UserDefaults.", code: """
        let store = KitoRecentSearchStore(key: "shop.recents")
        var recents = store.load(limit: 5)
        recents.add("Kiondo tote")        // trims, moves repeats to the front, drops the oldest
        recents.remove("Pilau")
        store.save(recents)
        """) { SearchRecentsSample() },
        KitSample("Skeleton rows", "Shimmering placeholders shaped like each row style.", code: """
        KitoSearchSkeletonRow(style: .card)
        """) { SearchSkeletonSample() },
        KitSample("Empty and error states", "Use them on their own, outside the screen.", code: """
        KitoSearchEmptyState(query: "sushi in Ruaka", correction: "Sushi",
                             suggestions: ["Seafood", "Asian"], hasFilters: true,
                             onSelect: { search.search($0) },
                             onClearFilters: { search.filters = KitoFilterState() })
        KitoSearchErrorState(message: error.localizedDescription) { search.retry() }
        """) { SearchStatesSample() },
    ])

    static let sections: [KitSection] = [field, screens, filters, blocks]
}

struct SearchGallery: View {
    static var count: Int { KitGallery.count(SearchSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Search",
            sections: SearchSamples.sections,
            footnote: "Requires `import KitoSearch`.",
            searchHint: "Try “field”, “tokens”, “suggestions”, “filters”, “typo” or “recents”."
        )
    }
}
