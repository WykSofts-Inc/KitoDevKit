//
//  FoodModels.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import CoreLocation
import KitoCore
import KitoCart

// Everything the showcase shares lives inside the `FoodShowcase` namespace, so the only
// top-level names this folder adds are `FoodShowcase` and `FoodShowcaseApp`.
extension FoodShowcase {

    // MARK: - Palette and theme

    /// Chakula's colours. Primary is black in light mode and white in dark (the Kito default);
    /// the pepper orange is kept for pins, promos and the live order.
    enum FoodPalette {
        static let pepper = Color(red: 0.96, green: 0.36, blue: 0.16)
        static let pepperDeep = Color(red: 0.80, green: 0.22, blue: 0.10)
        static let mpesa = Color(red: 0.20, green: 0.66, blue: 0.29)
        static let star = Color(red: 0.98, green: 0.72, blue: 0.12)

        static func theme(for scheme: ColorScheme) -> KitoTheme {
            scheme == .dark ? dark : light
        }

        static let light = KitoTheme(colors: KitoColors(
            primary: Color(red: 0.07, green: 0.07, blue: 0.08),
            onPrimary: .white,
            secondary: Color(red: 0.96, green: 0.36, blue: 0.16),
            onSecondary: .white,
            background: Color(red: 0.98, green: 0.975, blue: 0.965),
            onBackground: Color(red: 0.07, green: 0.07, blue: 0.08),
            surface: .white,
            onSurface: Color(red: 0.07, green: 0.07, blue: 0.08),
            surfaceMuted: Color(red: 0.95, green: 0.94, blue: 0.925),
            border: Color(red: 0.89, green: 0.88, blue: 0.86),
            danger: Color(red: 0.88, green: 0.22, blue: 0.24),
            success: Color(red: 0.14, green: 0.62, blue: 0.36),
            warning: Color(red: 0.96, green: 0.64, blue: 0.12)
        ))

        static let dark = KitoTheme(colors: KitoColors(
            primary: .white,
            onPrimary: Color(red: 0.06, green: 0.06, blue: 0.07),
            secondary: Color(red: 1.0, green: 0.48, blue: 0.28),
            onSecondary: Color(red: 0.06, green: 0.06, blue: 0.07),
            background: Color(red: 0.055, green: 0.055, blue: 0.065),
            onBackground: Color(red: 0.95, green: 0.95, blue: 0.96),
            surface: Color(red: 0.11, green: 0.11, blue: 0.125),
            onSurface: Color(red: 0.95, green: 0.95, blue: 0.96),
            surfaceMuted: Color(red: 0.16, green: 0.16, blue: 0.18),
            border: Color(red: 0.23, green: 0.23, blue: 0.26),
            danger: Color(red: 1.0, green: 0.42, blue: 0.44),
            success: Color(red: 0.32, green: 0.80, blue: 0.52),
            warning: Color(red: 1.0, green: 0.76, blue: 0.30)
        ))
    }

    // MARK: - Artwork

    /// Generated food artwork: a two-colour gradient with a symbol, so the demo needs no images.
    struct FoodArt: Hashable, Sendable {
        var symbol: String
        var colors: [Color]
        /// A second, smaller symbol scattered behind the main one.
        var accent: String?

        init(_ symbol: String, _ colors: [Color], accent: String? = nil) {
            self.symbol = symbol
            self.colors = colors
            self.accent = accent
        }
    }

    // MARK: - Menu

    /// A size or an extra, with what it adds to the price.
    struct FoodChoice: Identifiable, Hashable, Sendable {
        var id: String { name }
        var name: String
        var price: Decimal

        init(_ name: String, _ price: Decimal = 0) {
            self.name = name
            self.price = price
        }
    }

    struct FoodDish: Identifiable, Hashable, Sendable {
        var id: String
        var name: String
        var detail: String
        var price: Decimal
        var art: FoodArt
        var isPopular = false
        var isSpicy = false
        var isVegetarian = false
        /// Sizes to pick from; empty means one size.
        var sizes: [FoodChoice] = []
        /// Extras to add; empty hides the section.
        var extras: [FoodChoice] = []

        var isCustomisable: Bool { !sizes.isEmpty || !extras.isEmpty }
    }

    struct FoodMenuSection: Identifiable, Hashable, Sendable {
        var id: String { title }
        var title: String
        var dishes: [FoodDish]
    }

    enum FoodCuisine: String, CaseIterable, Identifiable, Sendable {
        case kenyan = "Kenyan"
        case grill = "Grill"
        case swahili = "Swahili"
        case pizza = "Pizza"
        case bakery = "Bakery"
        case indian = "Indian"
        case healthy = "Healthy"
        case burgers = "Burgers"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .kenyan: return "fork.knife"
            case .grill: return "flame.fill"
            case .swahili: return "fish.fill"
            case .pizza: return "chart.pie.fill"
            case .bakery: return "birthday.cake.fill"
            case .indian: return "leaf.fill"
            case .healthy: return "carrot.fill"
            case .burgers: return "takeoutbag.and.cup.and.straw.fill"
            }
        }

        var color: Color {
            switch self {
            case .kenyan: return Color(red: 0.93, green: 0.45, blue: 0.16)
            case .grill: return Color(red: 0.78, green: 0.20, blue: 0.14)
            case .swahili: return Color(red: 0.08, green: 0.55, blue: 0.62)
            case .pizza: return Color(red: 0.90, green: 0.30, blue: 0.22)
            case .bakery: return Color(red: 0.86, green: 0.42, blue: 0.58)
            case .indian: return Color(red: 0.92, green: 0.62, blue: 0.10)
            case .healthy: return Color(red: 0.26, green: 0.62, blue: 0.30)
            case .burgers: return Color(red: 0.62, green: 0.36, blue: 0.18)
            }
        }
    }

    struct FoodReviewSeed: Hashable, Sendable {
        var author: String
        var subtitle: String
        var rating: Double
        var title: String?
        var body: String
        var daysAgo: Int
        var tags: [String] = []
        var helpful = 0
        var reply: String?
    }

    struct FoodRestaurant: Identifiable, Hashable, Sendable {
        var id: String
        var name: String
        var cuisine: FoodCuisine
        var tagline: String
        var area: String
        var latitude: Double
        var longitude: Double
        var rating: Double
        var ratingCount: Int
        var minutes: ClosedRange<Int>
        var deliveryFee: Decimal
        /// 1 to 3, shown as "$", "$$" or "$$$".
        var priceLevel: Int
        var art: FoodArt
        var promo: String?
        var chef: String
        var menu: [FoodMenuSection]
        var reviews: [FoodReviewSeed]

        var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
        var dishes: [FoodDish] { menu.flatMap(\.dishes) }
        var minutesText: String { "\(minutes.lowerBound)–\(minutes.upperBound) min" }
        var feeText: String { deliveryFee == 0 ? "Free delivery" : KitoCartMoney.string(deliveryFee) + " delivery" }
        var ratingText: String { String(format: "%.1f", rating) }
        var priceText: String { String(repeating: "$", count: priceLevel) }

        func dish(id: String) -> FoodDish? { dishes.first { $0.id == id } }

        static func == (lhs: FoodRestaurant, rhs: FoodRestaurant) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    struct FoodPromo: Identifiable, Hashable, Sendable {
        var id: String
        var eyebrow: String
        var title: String
        var detail: String
        var code: String?
        var art: FoodArt
        var restaurantID: String?
    }

    // MARK: - Address

    struct FoodAddress: Equatable, Sendable {
        /// The neighbourhood, e.g. "Kilimani".
        var area: String
        /// The street or building under the pin.
        var line: String
        var latitude: Double
        var longitude: Double

        var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    }

    // MARK: - Cart lines

    /// What the cart can't hold itself: which dish and restaurant a line came from.
    struct FoodCartLine: Hashable, Sendable {
        var dishID: String
        var restaurantID: String
        var size: String?
        var extras: [String]
        var note: String
    }
}
