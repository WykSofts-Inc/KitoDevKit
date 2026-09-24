//
//  FoodData.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import CoreLocation

// Offline data for the showcase: eight invented Nairobi restaurants with menus, reviews and
// coordinates, plus promos and past orders. No real restaurant or brand names.
extension FoodShowcase {
    enum FoodData {
        fileprivate static func rgb(_ r: Double, _ g: Double, _ b: Double) -> Color { Color(red: r, green: g, blue: b) }

        /// Kilimani — where the location picker starts.
        static let kilimani = CLLocationCoordinate2D(latitude: -1.2925, longitude: 36.7870)

        static let defaultAddress = FoodAddress(area: "Kilimani", line: "Argwings Kodhek Road", latitude: -1.2925, longitude: 36.7870)

        /// Neighbourhood centres, for naming a picked point offline.
        static let neighbourhoods: [(name: String, latitude: Double, longitude: Double)] = [
            ("Kilimani", -1.2925, 36.7870), ("Westlands", -1.2650, 36.8040), ("Karen", -1.3190, 36.7080),
            ("Kileleshwa", -1.2820, 36.7830), ("Lavington", -1.2790, 36.7690), ("Parklands", -1.2610, 36.8160),
            ("Upper Hill", -1.2990, 36.8150), ("Hurlingham", -1.2960, 36.7960), ("Riverside", -1.2700, 36.7980),
            ("CBD", -1.2860, 36.8230), ("Langata", -1.3350, 36.7800), ("Gigiri", -1.2340, 36.8030),
        ]

        static func neighbourhood(near coordinate: CLLocationCoordinate2D) -> String {
            neighbourhoods.min { a, b in
                let da = pow(a.latitude - coordinate.latitude, 2) + pow(a.longitude - coordinate.longitude, 2)
                let db = pow(b.latitude - coordinate.latitude, 2) + pow(b.longitude - coordinate.longitude, 2)
                return da < db
            }?.name ?? "Nairobi"
        }

        static let cuisines: [String] = ["All"] + FoodCuisine.allCases.map(\.rawValue)

        static func restaurant(id: String) -> FoodRestaurant? { restaurants.first { $0.id == id } }

        // MARK: Shared choices

        static let mainSizes = [FoodChoice("Regular"), FoodChoice("Large", 250)]
        static let pizzaSizes = [FoodChoice("Medium · 9\""), FoodChoice("Large · 12\"", 450), FoodChoice("Family · 15\"", 900)]
        static let drinkSizes = [FoodChoice("300 ml"), FoodChoice("500 ml", 100)]

        static let restaurants: [FoodRestaurant] = [mamaZuri, nyamaCorner, pwaniGrill, karenFire, tamuTamu, spiceRoute, greenBowl, burgerMtaani]

        // MARK: 1. Mama Zuri's Kitchen

        static let mamaZuri = FoodRestaurant(
            id: "mama-zuri", name: "Mama Zuri's Kitchen", cuisine: .kenyan,
            tagline: "Home-style Kenyan cooking, slow and generous", area: "Kilimani",
            latitude: -1.2898, longitude: 36.7835, rating: 4.8, ratingCount: 2_140, minutes: 20...30,
            deliveryFee: 99, priceLevel: 1,
            art: FoodArt("fork.knife", [rgb(0.96, 0.52, 0.18), rgb(0.80, 0.22, 0.10)], accent: "leaf.fill"),
            promo: "20% off with KARIBU20", chef: "Mama Zuri",
            menu: [
                FoodMenuSection(title: "Popular", dishes: [
                    FoodDish(id: "mz-pilau", name: "Beef pilau", detail: "Spiced rice slow-cooked with tender beef, served with kachumbari.",
                             price: 650, art: FoodArt("frying.pan.fill", [rgb(0.85, 0.55, 0.22), rgb(0.62, 0.30, 0.10)]),
                             isPopular: true, sizes: mainSizes,
                             extras: [FoodChoice("Extra kachumbari", 80), FoodChoice("Avocado", 120), FoodChoice("Pili pili sauce", 50)]),
                    FoodDish(id: "mz-stew", name: "Beef stew & chapati", detail: "Rich tomato beef stew with two soft layered chapatis.",
                             price: 720, art: FoodArt("flame.fill", [rgb(0.86, 0.32, 0.16), rgb(0.55, 0.14, 0.08)]),
                             isPopular: true, sizes: mainSizes, extras: [FoodChoice("Extra chapati", 60), FoodChoice("Avocado", 120)]),
                ]),
                FoodMenuSection(title: "Mains", dishes: [
                    FoodDish(id: "mz-ugali", name: "Ugali, sukuma & nyama", detail: "Firm ugali, sautéed sukuma wiki and fried beef.",
                             price: 580, art: FoodArt("leaf.fill", [rgb(0.40, 0.66, 0.26), rgb(0.18, 0.42, 0.14)]),
                             extras: [FoodChoice("Extra sukuma", 60), FoodChoice("Mala (sour milk)", 90)]),
                    FoodDish(id: "mz-githeri", name: "Githeri special", detail: "Maize and beans stewed with potatoes and carrots.",
                             price: 450, art: FoodArt("carrot.fill", [rgb(0.94, 0.66, 0.20), rgb(0.72, 0.40, 0.12)]),
                             isVegetarian: true, sizes: mainSizes),
                    FoodDish(id: "mz-matumbo", name: "Matumbo fry", detail: "Well-cleaned tripe fried with onions, tomatoes and dhania.",
                             price: 520, art: FoodArt("frying.pan.fill", [rgb(0.70, 0.40, 0.22), rgb(0.42, 0.20, 0.10)]), isSpicy: true),
                ]),
                FoodMenuSection(title: "Snacks", dishes: [
                    FoodDish(id: "mz-mandazi", name: "Mandazi (4 pcs)", detail: "Soft coconut mandazi, lightly sweet.",
                             price: 150, art: FoodArt("circle.hexagongrid.fill", [rgb(0.96, 0.78, 0.40), rgb(0.82, 0.52, 0.18)]), isVegetarian: true),
                    FoodDish(id: "mz-samosa", name: "Beef samosa (3 pcs)", detail: "Crisp pastry, minced beef, green chilli.",
                             price: 210, art: FoodArt("triangle.fill", [rgb(0.94, 0.62, 0.22), rgb(0.70, 0.34, 0.10)]), isSpicy: true),
                ]),
                FoodMenuSection(title: "Drinks", dishes: [
                    FoodDish(id: "mz-chai", name: "Masala chai", detail: "Milky tea brewed with ginger, cardamom and cinnamon.",
                             price: 120, art: FoodArt("cup.and.saucer.fill", [rgb(0.72, 0.48, 0.30), rgb(0.46, 0.28, 0.16)]), sizes: drinkSizes),
                    FoodDish(id: "mz-passion", name: "Fresh passion juice", detail: "Squeezed this morning.",
                             price: 180, art: FoodArt("waterbottle.fill", [rgb(0.98, 0.72, 0.18), rgb(0.86, 0.42, 0.10)]), sizes: drinkSizes),
                ]),
            ],
            reviews: [
                FoodReviewSeed(author: "Achieng O.", subtitle: "Kilimani · 34 orders", rating: 5, title: "Tastes like Sunday at home",
                               body: "The pilau is exactly how my grandmother made it — fragrant, not oily, and the beef falls apart. Arrived hot in 22 minutes.",
                               daysAgo: 3, tags: ["Great taste", "Hot on arrival"], helpful: 41, reply: "Asante sana Achieng! See you next Sunday."),
                FoodReviewSeed(author: "Brian K.", subtitle: "Hurlingham · 12 orders", rating: 5, title: nil,
                               body: "Beef stew and chapati is the best lunch in Kilimani. Big portions for the price.",
                               daysAgo: 9, tags: ["Great value"], helpful: 18),
                FoodReviewSeed(author: "Wanjiku M.", subtitle: "Kileleshwa · 7 orders", rating: 4, title: "Solid githeri",
                               body: "Well seasoned and filling. Would love a spicier option on the menu.", daysAgo: 16, helpful: 6),
                FoodReviewSeed(author: "Kevin M.", subtitle: "Lavington · 3 orders", rating: 5, title: nil,
                               body: "Mandazi were still warm. The rider called ahead too — lovely touch.", daysAgo: 28, tags: ["Friendly rider"], helpful: 9),
            ])

        // MARK: 2. Nyama Choma Corner

        static let nyamaCorner = FoodRestaurant(
            id: "nyama-corner", name: "Nyama Choma Corner", cuisine: .grill,
            tagline: "Goat and beef roasted over charcoal, the Friday way", area: "Westlands",
            latitude: -1.2668, longitude: 36.8062, rating: 4.7, ratingCount: 1_860, minutes: 30...40,
            deliveryFee: 149, priceLevel: 2,
            art: FoodArt("flame.fill", [rgb(0.84, 0.26, 0.12), rgb(0.36, 0.08, 0.06)], accent: "flame"),
            promo: "Free kachumbari on orders over KES 1,500", chef: "Otieno",
            menu: [
                FoodMenuSection(title: "Choma", dishes: [
                    FoodDish(id: "nc-goat", name: "Goat choma · ½ kg", detail: "Charcoal-roasted goat, salted just right, with kachumbari.",
                             price: 1_100, art: FoodArt("flame.fill", [rgb(0.80, 0.30, 0.14), rgb(0.44, 0.12, 0.06)]),
                             isPopular: true, sizes: [FoodChoice("½ kg"), FoodChoice("1 kg", 1_000)],
                             extras: [FoodChoice("Ugali", 80), FoodChoice("Mukimo", 150), FoodChoice("Extra kachumbari", 80)]),
                    FoodDish(id: "nc-beef", name: "Beef choma · ½ kg", detail: "Prime beef ribs over charcoal.",
                             price: 950, art: FoodArt("flame", [rgb(0.74, 0.24, 0.12), rgb(0.40, 0.10, 0.06)]),
                             sizes: [FoodChoice("½ kg"), FoodChoice("1 kg", 850)], extras: [FoodChoice("Ugali", 80), FoodChoice("Chips", 150)]),
                    FoodDish(id: "nc-chicken", name: "Kienyeji chicken", detail: "Free-range chicken, grilled whole or quartered.",
                             price: 1_300, art: FoodArt("bird.fill", [rgb(0.92, 0.58, 0.20), rgb(0.66, 0.28, 0.08)]),
                             isPopular: true, sizes: [FoodChoice("Quarter", -700), FoodChoice("Half"), FoodChoice("Whole", 1_100)]),
                ]),
                FoodMenuSection(title: "Sides", dishes: [
                    FoodDish(id: "nc-mukimo", name: "Mukimo", detail: "Mashed potatoes, peas, maize and pumpkin leaves.",
                             price: 250, art: FoodArt("leaf.circle.fill", [rgb(0.40, 0.62, 0.28), rgb(0.20, 0.40, 0.14)]), isVegetarian: true),
                    FoodDish(id: "nc-chips", name: "Chips masala", detail: "Crisp fries tossed in a tangy, spicy tomato sauce.",
                             price: 350, art: FoodArt("takeoutbag.and.cup.and.straw.fill", [rgb(0.96, 0.52, 0.16), rgb(0.80, 0.22, 0.10)]),
                             isSpicy: true, isVegetarian: true),
                    FoodDish(id: "nc-kachumbari", name: "Kachumbari", detail: "Tomato, onion, dhania and chilli.",
                             price: 120, art: FoodArt("carrot.fill", [rgb(0.90, 0.30, 0.24), rgb(0.60, 0.14, 0.12)]), isVegetarian: true),
                ]),
                FoodMenuSection(title: "Drinks", dishes: [
                    FoodDish(id: "nc-soda", name: "Soda", detail: "Chilled, in a glass bottle.",
                             price: 100, art: FoodArt("waterbottle.fill", [rgb(0.30, 0.44, 0.80), rgb(0.12, 0.20, 0.50)]), sizes: drinkSizes),
                    FoodDish(id: "nc-dawa", name: "Dawa mocktail", detail: "Lime, honey and ginger over crushed ice.",
                             price: 280, art: FoodArt("wineglass.fill", [rgb(0.62, 0.84, 0.30), rgb(0.30, 0.60, 0.20)])),
                ]),
            ],
            reviews: [
                FoodReviewSeed(author: "Otieno J.", subtitle: "Westlands · 22 orders", rating: 5, title: "Proper choma",
                               body: "Smoky, juicy and the kachumbari has just the right bite. Better than some places I've sat down at.",
                               daysAgo: 2, tags: ["Great taste", "Big portions"], helpful: 33),
                FoodReviewSeed(author: "Fatuma A.", subtitle: "Parklands · 9 orders", rating: 4, title: nil,
                               body: "Chicken was excellent, delivery took a bit longer on a Friday night but worth the wait.",
                               daysAgo: 6, helpful: 12, reply: "Thank you Fatuma — Fridays are busy, we've added two more riders."),
                FoodReviewSeed(author: "Njeri W.", subtitle: "Riverside · 4 orders", rating: 5, title: "Mukimo!",
                               body: "The mukimo alone is worth ordering. Soft and full of flavour.", daysAgo: 20, helpful: 7),
            ])

        // MARK: 3. Pwani Grill

        static let pwaniGrill = FoodRestaurant(
            id: "pwani-grill", name: "Pwani Grill", cuisine: .swahili,
            tagline: "Coastal Swahili flavours — coconut, tamarind and the sea", area: "Kileleshwa",
            latitude: -1.2808, longitude: 36.7808, rating: 4.6, ratingCount: 980, minutes: 25...35,
            deliveryFee: 0, priceLevel: 2,
            art: FoodArt("fish.fill", [rgb(0.10, 0.62, 0.66), rgb(0.04, 0.30, 0.42)], accent: "water.waves"),
            promo: "Free delivery all week", chef: "Bi Mwanaisha",
            menu: [
                FoodMenuSection(title: "Popular", dishes: [
                    FoodDish(id: "pg-biryani", name: "Chicken biryani", detail: "Mombasa-style biryani with fried onions and raisins.",
                             price: 850, art: FoodArt("frying.pan.fill", [rgb(0.94, 0.62, 0.18), rgb(0.70, 0.30, 0.10)]),
                             isPopular: true, isSpicy: true, sizes: mainSizes,
                             extras: [FoodChoice("Kachumbari", 80), FoodChoice("Boiled egg", 60), FoodChoice("Extra raita", 70)]),
                    FoodDish(id: "pg-samaki", name: "Samaki wa kupaka", detail: "Grilled tilapia in a tamarind and coconut sauce.",
                             price: 1_250, art: FoodArt("fish.fill", [rgb(0.12, 0.60, 0.64), rgb(0.06, 0.32, 0.40)]),
                             isPopular: true, extras: [FoodChoice("Coconut rice", 150), FoodChoice("Chapati", 60)]),
                ]),
                FoodMenuSection(title: "Street food", dishes: [
                    FoodDish(id: "pg-viazi", name: "Viazi karai", detail: "Battered potatoes with tamarind chutney.",
                             price: 250, art: FoodArt("circle.grid.2x2.fill", [rgb(0.96, 0.74, 0.24), rgb(0.80, 0.46, 0.12)]), isVegetarian: true),
                    FoodDish(id: "pg-mahamri", name: "Mahamri & mbaazi", detail: "Cardamom mahamri with pigeon peas in coconut.",
                             price: 320, art: FoodArt("triangle.fill", [rgb(0.92, 0.70, 0.36), rgb(0.66, 0.40, 0.16)]), isVegetarian: true),
                    FoodDish(id: "pg-urojo", name: "Urojo bowl", detail: "Tangy Zanzibar mix soup with bhajia and kachori.",
                             price: 450, art: FoodArt("drop.fill", [rgb(0.96, 0.58, 0.16), rgb(0.74, 0.30, 0.08)]), isSpicy: true),
                ]),
                FoodMenuSection(title: "Drinks", dishes: [
                    FoodDish(id: "pg-madafu", name: "Madafu", detail: "Fresh young coconut, opened for you.",
                             price: 200, art: FoodArt("drop.circle.fill", [rgb(0.54, 0.76, 0.40), rgb(0.26, 0.50, 0.22)])),
                    FoodDish(id: "pg-tangawizi", name: "Tangawizi juice", detail: "Fiery ginger and lemon.",
                             price: 180, art: FoodArt("waterbottle.fill", [rgb(0.96, 0.82, 0.30), rgb(0.80, 0.58, 0.14)]), sizes: drinkSizes),
                ]),
            ],
            reviews: [
                FoodReviewSeed(author: "Amina S.", subtitle: "Kileleshwa · 15 orders", rating: 5, title: "Just like Old Town",
                               body: "The biryani took me straight back to Mombasa. Generous portions and the raita is lovely.",
                               daysAgo: 4, tags: ["Great taste"], helpful: 22),
                FoodReviewSeed(author: "David O.", subtitle: "Kilimani · 6 orders", rating: 4, title: nil,
                               body: "Samaki wa kupaka was delicious; I'd order coconut rice with it next time.", daysAgo: 11, helpful: 5),
                FoodReviewSeed(author: "Grace N.", subtitle: "Lavington · 2 orders", rating: 5, title: nil,
                               body: "Viazi karai + tamarind = perfection. Free delivery too.", daysAgo: 19, tags: ["Great value"], helpful: 8),
            ])

        // MARK: 4. Karen Wood-Fired

        static let karenFire = FoodRestaurant(
            id: "karen-fire", name: "Karen Wood-Fired", cuisine: .pizza,
            tagline: "Sourdough pizza from a clay oven under the jacarandas", area: "Karen",
            latitude: -1.3168, longitude: 36.7112, rating: 4.5, ratingCount: 1_320, minutes: 35...50,
            deliveryFee: 199, priceLevel: 3,
            art: FoodArt("chart.pie.fill", [rgb(0.92, 0.34, 0.22), rgb(0.54, 0.12, 0.10)], accent: "leaf.fill"),
            promo: nil, chef: "Chef Lorna",
            menu: [
                FoodMenuSection(title: "Pizza", dishes: [
                    FoodDish(id: "kf-margherita", name: "Margherita", detail: "San Marzano-style tomato, fior di latte, basil.",
                             price: 950, art: FoodArt("chart.pie.fill", [rgb(0.90, 0.30, 0.22), rgb(0.60, 0.12, 0.10)]),
                             isPopular: true, isVegetarian: true, sizes: pizzaSizes,
                             extras: [FoodChoice("Extra mozzarella", 200), FoodChoice("Rocket", 120), FoodChoice("Chilli oil", 80)]),
                    FoodDish(id: "kf-mishkaki", name: "Mishkaki pizza", detail: "Grilled beef skewer pieces, red onion, pilipili.",
                             price: 1_250, art: FoodArt("chart.pie.fill", [rgb(0.74, 0.28, 0.14), rgb(0.40, 0.10, 0.06)]),
                             isPopular: true, isSpicy: true, sizes: pizzaSizes, extras: [FoodChoice("Extra beef", 250), FoodChoice("Jalapeños", 100)]),
                    FoodDish(id: "kf-sukuma", name: "Sukuma & feta", detail: "Garlic sukuma wiki, feta, caramelised onion.",
                             price: 1_050, art: FoodArt("leaf.fill", [rgb(0.36, 0.60, 0.28), rgb(0.16, 0.36, 0.14)]),
                             isVegetarian: true, sizes: pizzaSizes),
                ]),
                FoodMenuSection(title: "Starters", dishes: [
                    FoodDish(id: "kf-bread", name: "Garlic sourdough", detail: "Wood-fired bread with herb butter.",
                             price: 450, art: FoodArt("oval.fill", [rgb(0.90, 0.70, 0.40), rgb(0.64, 0.42, 0.20)]), isVegetarian: true),
                    FoodDish(id: "kf-wings", name: "Honey chilli wings", detail: "Six wings, sticky and hot.",
                             price: 700, art: FoodArt("flame.fill", [rgb(0.94, 0.46, 0.14), rgb(0.70, 0.20, 0.08)]), isSpicy: true),
                ]),
                FoodMenuSection(title: "Desserts", dishes: [
                    FoodDish(id: "kf-tiramisu", name: "Coffee tiramisu", detail: "Made with Kenyan AA espresso.",
                             price: 550, art: FoodArt("birthday.cake.fill", [rgb(0.56, 0.38, 0.26), rgb(0.30, 0.18, 0.12)])),
                ]),
            ],
            reviews: [
                FoodReviewSeed(author: "Lucy W.", subtitle: "Karen · 18 orders", rating: 5, title: "Best crust in Nairobi",
                               body: "Blistered, chewy and light. The mishkaki pizza is a must.", daysAgo: 5, tags: ["Great taste"], helpful: 27),
                FoodReviewSeed(author: "Tom B.", subtitle: "Langata · 5 orders", rating: 4, title: nil,
                               body: "Great pizza, a bit pricey for delivery but the family size feeds four.", daysAgo: 12, helpful: 4),
                FoodReviewSeed(author: "Mercy K.", subtitle: "Karen · 1 order", rating: 4, title: nil,
                               body: "Arrived warm, box was well sealed. Tiramisu was lovely.", daysAgo: 25, helpful: 2),
            ])
    }
}

extension FoodShowcase.FoodData {
    typealias FoodRestaurant = FoodShowcase.FoodRestaurant
    typealias FoodMenuSection = FoodShowcase.FoodMenuSection
    typealias FoodDish = FoodShowcase.FoodDish
    typealias FoodArt = FoodShowcase.FoodArt
    typealias FoodChoice = FoodShowcase.FoodChoice
    typealias FoodReviewSeed = FoodShowcase.FoodReviewSeed

    // MARK: 5. Tamu Tamu Bakery

    static let tamuTamu = FoodRestaurant(
        id: "tamu-tamu", name: "Tamu Tamu Bakery", cuisine: .bakery,
        tagline: "Cakes, croissants and the softest cinnamon rolls", area: "Lavington",
        latitude: -1.2785, longitude: 36.7702, rating: 4.9, ratingCount: 760, minutes: 15...25,
        deliveryFee: 79, priceLevel: 2,
        art: FoodArt("birthday.cake.fill", [rgb(0.96, 0.56, 0.66), rgb(0.70, 0.26, 0.44)], accent: "heart.fill"),
        promo: "Buy 2 cinnamon rolls, get 1 free", chef: "Baker Wairimu",
        menu: [
            FoodMenuSection(title: "Cakes", dishes: [
                FoodDish(id: "tt-redvelvet", name: "Red velvet slice", detail: "Cream cheese frosting, not too sweet.",
                         price: 380, art: FoodArt("birthday.cake.fill", [rgb(0.86, 0.22, 0.30), rgb(0.54, 0.10, 0.18)]), isPopular: true),
                FoodDish(id: "tt-carrot", name: "Carrot & walnut cake", detail: "Spiced sponge, orange zest icing.",
                         price: 350, art: FoodArt("carrot.fill", [rgb(0.96, 0.58, 0.20), rgb(0.74, 0.32, 0.10)]), isVegetarian: true),
                FoodDish(id: "tt-whole", name: "Whole celebration cake", detail: "Vanilla or chocolate, with a message on top.",
                         price: 2_800, art: FoodArt("gift.fill", [rgb(0.62, 0.40, 0.86), rgb(0.36, 0.18, 0.60)]),
                         sizes: [FoodChoice("1 kg"), FoodChoice("2 kg", 2_400)],
                         extras: [FoodChoice("Candles", 150), FoodChoice("Chocolate drip", 300), FoodChoice("Fresh berries", 450)]),
            ]),
            FoodMenuSection(title: "Pastries", dishes: [
                FoodDish(id: "tt-cinnamon", name: "Cinnamon roll", detail: "Baked every two hours, glazed warm.",
                         price: 250, art: FoodArt("hurricane", [rgb(0.86, 0.58, 0.32), rgb(0.60, 0.34, 0.16)]), isPopular: true),
                FoodDish(id: "tt-croissant", name: "Butter croissant", detail: "72-hour laminated dough.",
                         price: 220, art: FoodArt("moon.fill", [rgb(0.94, 0.74, 0.38), rgb(0.72, 0.48, 0.18)]),
                         extras: [FoodChoice("Almond filling", 90), FoodChoice("Ham & cheese", 180)]),
            ]),
            FoodMenuSection(title: "Coffee", dishes: [
                FoodDish(id: "tt-latte", name: "Kenyan latte", detail: "Single-origin Nyeri beans.",
                         price: 300, art: FoodArt("mug.fill", [rgb(0.62, 0.44, 0.32), rgb(0.36, 0.22, 0.14)]),
                         sizes: [FoodChoice("Regular"), FoodChoice("Large", 80)],
                         extras: [FoodChoice("Oat milk", 60), FoodChoice("Extra shot", 70), FoodChoice("Caramel", 50)]),
            ]),
        ],
        reviews: [
            FoodReviewSeed(author: "Sharon A.", subtitle: "Lavington · 26 orders", rating: 5, title: "Dangerous",
                           body: "The cinnamon rolls arrive warm. I have no self control any more.", daysAgo: 1, tags: ["Great taste"], helpful: 44),
            FoodReviewSeed(author: "Peter M.", subtitle: "Kilimani · 8 orders", rating: 5, title: nil,
                           body: "Ordered a birthday cake with a message, it was perfect and on time.", daysAgo: 8, tags: ["On time"], helpful: 13),
            FoodReviewSeed(author: "Irene C.", subtitle: "Kileleshwa · 3 orders", rating: 5, title: nil,
                           body: "Croissants as good as anywhere. Lovely packaging.", daysAgo: 21, helpful: 5),
        ])

    // MARK: 6. Spice Route Curry House

    static let spiceRoute = FoodRestaurant(
        id: "spice-route", name: "Spice Route Curry House", cuisine: .indian,
        tagline: "North Indian curries and tandoor breads", area: "Parklands",
        latitude: -1.2622, longitude: 36.8148, rating: 4.6, ratingCount: 1_540, minutes: 30...45,
        deliveryFee: 149, priceLevel: 2,
        art: FoodArt("leaf.fill", [rgb(0.96, 0.70, 0.16), rgb(0.74, 0.30, 0.08)], accent: "flame.fill"),
        promo: "Free garlic naan over KES 2,000", chef: "Chef Harjit",
        menu: [
            FoodMenuSection(title: "Curries", dishes: [
                FoodDish(id: "sr-butter", name: "Butter chicken", detail: "Tandoori chicken in a silky tomato and butter sauce.",
                         price: 980, art: FoodArt("frying.pan.fill", [rgb(0.94, 0.52, 0.18), rgb(0.70, 0.24, 0.08)]),
                         isPopular: true, sizes: mainSizes, extras: [FoodChoice("Jeera rice", 200), FoodChoice("Garlic naan", 150)]),
                FoodDish(id: "sr-paneer", name: "Paneer tikka masala", detail: "Chargrilled paneer, peppers and onion.",
                         price: 880, art: FoodArt("square.grid.2x2.fill", [rgb(0.96, 0.62, 0.20), rgb(0.72, 0.34, 0.10)]),
                         isVegetarian: true, sizes: mainSizes, extras: [FoodChoice("Jeera rice", 200), FoodChoice("Butter naan", 130)]),
                FoodDish(id: "sr-dal", name: "Dal makhani", detail: "Black lentils simmered overnight.",
                         price: 650, art: FoodArt("drop.fill", [rgb(0.54, 0.30, 0.20), rgb(0.30, 0.14, 0.08)]), isVegetarian: true),
            ]),
            FoodMenuSection(title: "Breads", dishes: [
                FoodDish(id: "sr-naan", name: "Garlic naan", detail: "From the tandoor, brushed with garlic butter.",
                         price: 150, art: FoodArt("oval.fill", [rgb(0.92, 0.76, 0.46), rgb(0.70, 0.50, 0.24)]), isPopular: true, isVegetarian: true),
            ]),
            FoodMenuSection(title: "Drinks", dishes: [
                FoodDish(id: "sr-lassi", name: "Mango lassi", detail: "Thick, cold and sweet.",
                         price: 280, art: FoodArt("wineglass.fill", [rgb(0.98, 0.72, 0.20), rgb(0.86, 0.46, 0.10)])),
            ]),
        ],
        reviews: [
            FoodReviewSeed(author: "Rahul P.", subtitle: "Parklands · 31 orders", rating: 5, title: "Authentic",
                           body: "The dal makhani is the real thing — rich and smoky. Naan arrives soft.", daysAgo: 3, helpful: 19),
            FoodReviewSeed(author: "Esther N.", subtitle: "Westlands · 4 orders", rating: 4, title: nil,
                           body: "Butter chicken was lovely; I asked for mild and they got it right.", daysAgo: 14, helpful: 3),
        ])

    // MARK: 7. Green Bowl Co.

    static let greenBowl = FoodRestaurant(
        id: "green-bowl", name: "Green Bowl Co.", cuisine: .healthy,
        tagline: "Bowls, wraps and cold-pressed juice", area: "Kilimani",
        latitude: -1.2948, longitude: 36.7902, rating: 4.4, ratingCount: 610, minutes: 15...25,
        deliveryFee: 99, priceLevel: 2,
        art: FoodArt("carrot.fill", [rgb(0.40, 0.74, 0.36), rgb(0.12, 0.44, 0.26)], accent: "leaf.fill"),
        promo: nil, chef: "Chef Nia",
        menu: [
            FoodMenuSection(title: "Bowls", dishes: [
                FoodDish(id: "gb-power", name: "Power bowl", detail: "Quinoa, avocado, roast sweet potato, greens, tahini.",
                         price: 850, art: FoodArt("leaf.fill", [rgb(0.42, 0.70, 0.34), rgb(0.18, 0.44, 0.20)]),
                         isPopular: true, isVegetarian: true,
                         extras: [FoodChoice("Grilled chicken", 250), FoodChoice("Boiled egg", 60), FoodChoice("Extra avocado", 120)]),
                FoodDish(id: "gb-tilapia", name: "Tilapia grain bowl", detail: "Lake tilapia, brown rice, pickled onion.",
                         price: 980, art: FoodArt("fish.fill", [rgb(0.26, 0.62, 0.60), rgb(0.10, 0.36, 0.38)])),
            ]),
            FoodMenuSection(title: "Juice", dishes: [
                FoodDish(id: "gb-green", name: "Green machine", detail: "Kale, cucumber, apple, ginger.",
                         price: 350, art: FoodArt("waterbottle.fill", [rgb(0.44, 0.76, 0.32), rgb(0.20, 0.50, 0.18)]), sizes: drinkSizes),
                FoodDish(id: "gb-beet", name: "Beet it", detail: "Beetroot, carrot, orange.",
                         price: 350, art: FoodArt("waterbottle.fill", [rgb(0.76, 0.18, 0.36), rgb(0.46, 0.08, 0.22)]), sizes: drinkSizes),
            ]),
        ],
        reviews: [
            FoodReviewSeed(author: "Joy M.", subtitle: "Kilimani · 12 orders", rating: 5, title: nil,
                           body: "My go-to lunch. The power bowl with chicken keeps me full till evening.", daysAgo: 2, helpful: 10),
            FoodReviewSeed(author: "Sam K.", subtitle: "Upper Hill · 2 orders", rating: 4, title: nil,
                           body: "Fresh and tasty, portions could be a little bigger.", daysAgo: 10, helpful: 2),
        ])

    // MARK: 8. Burger Mtaani

    static let burgerMtaani = FoodRestaurant(
        id: "burger-mtaani", name: "Burger Mtaani", cuisine: .burgers,
        tagline: "Smash burgers and loaded fries, open late", area: "Westlands",
        latitude: -1.2612, longitude: 36.8021, rating: 4.5, ratingCount: 2_380, minutes: 20...30,
        deliveryFee: 129, priceLevel: 2,
        art: FoodArt("takeoutbag.and.cup.and.straw.fill", [rgb(0.62, 0.36, 0.18), rgb(0.26, 0.14, 0.08)], accent: "flame.fill"),
        promo: "Late-night deals after 10 PM", chef: "Kamau",
        menu: [
            FoodMenuSection(title: "Burgers", dishes: [
                FoodDish(id: "bm-smash", name: "Double smash", detail: "Two beef patties, cheddar, pickles, house sauce.",
                         price: 950, art: FoodArt("takeoutbag.and.cup.and.straw.fill", [rgb(0.70, 0.40, 0.20), rgb(0.40, 0.20, 0.10)]),
                         isPopular: true, sizes: [FoodChoice("Burger only"), FoodChoice("Meal with fries & soda", 350)],
                         extras: [FoodChoice("Extra patty", 250), FoodChoice("Bacon", 180), FoodChoice("Jalapeños", 80), FoodChoice("Avocado", 120)]),
                FoodDish(id: "bm-chicken", name: "Crispy chicken", detail: "Buttermilk chicken, slaw, chilli mayo.",
                         price: 850, art: FoodArt("bird.fill", [rgb(0.94, 0.62, 0.22), rgb(0.70, 0.34, 0.10)]),
                         isSpicy: true, sizes: [FoodChoice("Burger only"), FoodChoice("Meal with fries & soda", 350)]),
                FoodDish(id: "bm-veggie", name: "Bean & halloumi", detail: "Spiced bean patty, grilled halloumi.",
                         price: 800, art: FoodArt("leaf.fill", [rgb(0.50, 0.66, 0.30), rgb(0.26, 0.42, 0.14)]), isVegetarian: true),
            ]),
            FoodMenuSection(title: "Sides", dishes: [
                FoodDish(id: "bm-fries", name: "Loaded fries", detail: "Cheese sauce, crispy onions, chives.",
                         price: 450, art: FoodArt("takeoutbag.and.cup.and.straw.fill", [rgb(0.96, 0.70, 0.20), rgb(0.80, 0.42, 0.10)]), isPopular: true),
            ]),
            FoodMenuSection(title: "Shakes", dishes: [
                FoodDish(id: "bm-shake", name: "Salted caramel shake", detail: "Thick, cold, with whipped cream.",
                         price: 420, art: FoodArt("cup.and.saucer.fill", [rgb(0.86, 0.60, 0.36), rgb(0.60, 0.34, 0.18)])),
            ]),
        ],
        reviews: [
            FoodReviewSeed(author: "Mike O.", subtitle: "Westlands · 40 orders", rating: 5, title: "Midnight saviour",
                           body: "Double smash at 1 AM, still hot. Crispy edges, great sauce.", daysAgo: 1, tags: ["Hot on arrival"], helpful: 52),
            FoodReviewSeed(author: "Aisha H.", subtitle: "Parklands · 6 orders", rating: 4, title: nil,
                           body: "Loaded fries are huge. Chicken burger could be spicier.", daysAgo: 7, helpful: 6),
        ])

}

// MARK: - Promos, rider and past orders

extension FoodShowcase.FoodData {
    typealias FoodPromo = FoodShowcase.FoodPromo

    static let promos: [FoodPromo] = [
        FoodPromo(id: "karibu", eyebrow: "New here?", title: "20% off your first order",
                  detail: "Use KARIBU20 at checkout", code: "KARIBU20",
                  art: FoodArt("gift.fill", [rgb(0.96, 0.40, 0.16), rgb(0.72, 0.14, 0.18)], accent: "sparkles"), restaurantID: nil),
        FoodPromo(id: "choma-friday", eyebrow: "Nyama Choma Corner", title: "Choma Friday",
                  detail: "Free kachumbari with every ½ kg", code: nil,
                  art: FoodArt("flame.fill", [rgb(0.30, 0.10, 0.08), rgb(0.78, 0.26, 0.12)], accent: "flame"), restaurantID: "nyama-corner"),
        FoodPromo(id: "pwani-free", eyebrow: "Pwani Grill", title: "Free delivery all week",
                  detail: "Biryani, samaki and madafu to your door", code: nil,
                  art: FoodArt("fish.fill", [rgb(0.04, 0.34, 0.46), rgb(0.10, 0.64, 0.64)], accent: "water.waves"), restaurantID: "pwani-grill"),
        FoodPromo(id: "tamu", eyebrow: "Tamu Tamu Bakery", title: "3 rolls for the price of 2",
                  detail: "Warm cinnamon rolls, glazed to order", code: nil,
                  art: FoodArt("birthday.cake.fill", [rgb(0.62, 0.22, 0.44), rgb(0.96, 0.54, 0.62)], accent: "heart.fill"), restaurantID: "tamu-tamu"),
    ]

    /// The promo codes the cart accepts.
    static let promoCodes = ["KARIBU20", "CHAKULA", "FREEDEL"]

    /// The rider on every demo order.
    static let riderName = "Otieno Kamau"
    static let riderPhone = "+254712345678"
    static let riderPlate = "KMFB 214C"

    /// A path along "streets" from the restaurant to the door: it heads out on one axis, turns,
    /// jogs and finishes on the other, so the courier visibly takes corners.
    static func route(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        let dLat = end.latitude - start.latitude
        let dLon = end.longitude - start.longitude
        func point(_ lat: Double, _ lon: Double) -> CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: start.latitude + dLat * lat, longitude: start.longitude + dLon * lon)
        }
        return [
            point(0, 0), point(0.18, 0.02), point(0.34, 0.05), point(0.36, 0.30), point(0.40, 0.52),
            point(0.62, 0.55), point(0.78, 0.60), point(0.80, 0.82), point(0.92, 0.90), point(1, 1),
        ]
    }

    struct FoodPastOrderSeed {
        var restaurantID: String
        var daysAgo: Double
        var lines: [(dishID: String, quantity: Int)]
        var rating: Int?
    }

    static let pastOrders: [FoodPastOrderSeed] = [
        FoodPastOrderSeed(restaurantID: "mama-zuri", daysAgo: 2, lines: [("mz-pilau", 2), ("mz-chai", 2), ("mz-mandazi", 1)], rating: 5),
        FoodPastOrderSeed(restaurantID: "burger-mtaani", daysAgo: 6, lines: [("bm-smash", 1), ("bm-fries", 1), ("bm-shake", 1)], rating: nil),
        FoodPastOrderSeed(restaurantID: "pwani-grill", daysAgo: 13, lines: [("pg-biryani", 1), ("pg-viazi", 2), ("pg-madafu", 1)], rating: 4),
    ]
}
