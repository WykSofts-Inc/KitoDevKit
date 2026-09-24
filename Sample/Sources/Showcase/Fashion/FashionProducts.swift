//
//  FashionProducts.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoProduct

// MARK: - Builder

private struct FashionColorway {
    let id: String
    let name: String
    let primary: Color
    let accent: Color

    init(_ id: String, _ name: String, _ primary: Color, _ accent: Color) {
        self.id = id
        self.name = name
        self.primary = primary
        self.accent = accent
    }
}

private extension FashionCategory {
    var artworkKind: KitoProductArtwork.Kind {
        switch self {
        case .dresses: .dress
        case .outerwear: .jacket
        case .shoes: .sneaker
        case .bags: .tote
        case .accessories: .sunglasses
        }
    }

    var backdrop: Color {
        switch self {
        case .dresses: Color(red: 0.94, green: 0.91, blue: 0.87)
        case .outerwear: Color(red: 0.92, green: 0.91, blue: 0.89)
        case .shoes: Color(red: 0.93, green: 0.93, blue: 0.92)
        case .bags: Color(red: 0.94, green: 0.90, blue: 0.85)
        case .accessories: Color(red: 0.91, green: 0.93, blue: 0.93)
        }
    }
}

private enum FashionSizes {
    static let apparel = ["XS", "S", "M", "L", "XL"]
    static let shoes = ["EU 37", "EU 38", "EU 39", "EU 40", "EU 41", "EU 42", "EU 43", "EU 44"]
    static let scent = ["50 ml", "100 ml"]
}

private func fashionItem(
    _ id: String, _ name: String, category: FashionCategory, designer: String,
    kind: KitoProductArtwork.Kind? = nil, price: Decimal, was: Decimal? = nil,
    rating: Double, reviews: Int, badges: [KitoProductBadge] = [], isNew: Bool = false, popularity: Int,
    colors: [FashionColorway], sizes: [String], low: Set<String> = [], soldOut: Set<String> = [],
    sizePrices: [String: Decimal] = [:], summary: String, details: String, materials: [String]
) -> FashionItem {
    let kind = kind ?? category.artworkKind
    var media: [KitoProductMedia] = []
    for colour in colors {
        let art = KitoProductArtwork(kind, primary: colour.primary, accent: colour.accent, backdrop: category.backdrop)
        media.append(.artwork(art, colorID: colour.id, accessibilityLabel: "\(name) in \(colour.name)"))
        media.append(.artwork(art.framed(.closeUp), colorID: colour.id, accessibilityLabel: "Detail of the \(colour.name.lowercased()) \(name)"))
        media.append(.artwork(art.framed(.angled), colorID: colour.id, accessibilityLabel: "Campaign shot in \(colour.name.lowercased())"))
    }

    var variants: [KitoProductVariant] = []
    for (colourIndex, colour) in colors.enumerated() {
        if sizes.isEmpty {
            variants.append(KitoProductVariant(id: "\(id)~\(colour.id)", colorID: colour.id, stock: 12))
            continue
        }
        for (sizeIndex, size) in sizes.enumerated() {
            let isFirst = colourIndex == 0
            let stock: Int
            if isFirst, soldOut.contains(size) { stock = 0 }
            else if isFirst, low.contains(size) { stock = 2 }
            else { stock = 4 + (sizeIndex * 3 + colourIndex * 5) % 9 }
            variants.append(KitoProductVariant(id: "\(id)~\(colour.id)~\(size)", colorID: colour.id, sizeID: size,
                                               stock: stock, price: sizePrices[size]))
        }
    }

    var allBadges = badges
    if let was, was > price {
        let percent = NSDecimalNumber(decimal: (was - price) / was * 100).intValue
        allBadges.append(.sale(percent: percent))
    }

    let designerBio = FashionCatalogue.designer(designer)
    let first = colors[0]
    let spinArt = KitoProductArtwork(kind, primary: first.primary, accent: first.accent, backdrop: category.backdrop)
    let spins = category == .shoes || category == .bags

    let product = KitoProduct(
        id: id, name: name, brand: designerBio.name,
        price: price, compareAtPrice: was, currencyCode: "KES", rating: rating, reviewCount: reviews,
        badges: allBadges, media: media, spinFrames: spins ? spinArt.spin(frames: 24) : [],
        colors: colors.map { KitoProductColor($0.id, name: $0.name, swatch: $0.primary, secondarySwatch: $0.accent) },
        sizes: sizes.isEmpty ? [] : KitoProductSize.range(sizes),
        variants: variants, summary: summary,
        sections: [
            KitoProductInfoSection("Details", body: details, systemImage: "text.alignleft"),
            KitoProductInfoSection("Materials & care", bullets: materials, systemImage: "leaf"),
            KitoProductInfoSection("The atelier", body: "Designed by \(designerBio.name) in \(designerBio.city). \(designerBio.bio)",
                                   systemImage: "scissors"),
            KitoProductInfoSection("Delivery & returns",
                                   body: "Complimentary delivery on orders over KES 25,000. Free returns within 30 days, collected from your door in Nairobi, Mombasa and Kisumu.",
                                   systemImage: "shippingbox"),
        ])
    return FashionItem(product: product, category: category, designerID: designer, isNew: isNew, popularity: popularity)
}

// MARK: - Dresses and outerwear

extension FashionCatalogue {
    private typealias P = FashionPalette

    static let dresses: [FashionItem] = [
        fashionItem("shela-slip", "Shela Silk Slip Dress", category: .dresses, designer: "salim",
                    price: 28_500, rating: 4.8, reviews: 126, badges: [.new, .exclusive], isNew: true, popularity: 95,
                    colors: [FashionColorway("sand", "Sand", P.sand, P.gold), FashionColorway("ocean", "Ocean", P.ocean, P.bone)],
                    sizes: FashionSizes.apparel, low: ["S"],
                    summary: "Bias-cut silk that pools at the ankle, made for long evenings on the Shela waterfront.",
                    details: "A bias-cut slip with fine adjustable straps and a cowl neck. Falls to the ankle.",
                    materials: ["100% mulberry silk", "Dry clean only", "Made in Lamu"]),
        fashionItem("kanga-wrap", "Kanga Wrap Midi Dress", category: .dresses, designer: "salim",
                    price: 21_900, was: 27_400, rating: 4.6, reviews: 88, popularity: 80,
                    colors: [FashionColorway("terracotta", "Terracotta", P.terracotta, P.sand), FashionColorway("indigo", "Indigo", P.indigo, P.bone)],
                    sizes: FashionSizes.apparel,
                    summary: "A true wrap in printed cotton voile, cut from a vintage kanga border.",
                    details: "Wraps and ties at the waist. Flutter sleeves and a midi hem.",
                    materials: ["100% cotton voile", "Cool hand wash", "Printed in Mombasa"]),
        fashionItem("dhow-maxi", "Dhow Pleated Maxi Dress", category: .dresses, designer: "salim",
                    price: 34_000, rating: 4.7, reviews: 54, badges: [.new], isNew: true, popularity: 70,
                    colors: [FashionColorway("bone", "Bone", P.bone, P.gold), FashionColorway("claret", "Claret", P.claret, P.blush)],
                    sizes: FashionSizes.apparel, low: ["M"],
                    summary: "Knife pleats that open like a sail as you walk.",
                    details: "Sunray pleats from a fitted yoke, hidden side zip, floor length.",
                    materials: ["Recycled polyester georgette", "Machine wash cold", "Made in Nairobi"]),
        fashionItem("indigo-column", "Indigo Column Gown", category: .dresses, designer: "wanjiru",
                    price: 42_000, rating: 4.9, reviews: 31, badges: [.exclusive], popularity: 60,
                    colors: [FashionColorway("indigo", "Indigo", P.indigo, P.gold), FashionColorway("ink", "Ink", P.ink, P.gold)],
                    sizes: FashionSizes.apparel, soldOut: ["XS"],
                    summary: "A strict column with a single gold seam, for black-tie nights in Karen.",
                    details: "High neck, open back with a hook and eye, and a gold-thread seam down the front.",
                    materials: ["Wool crepe", "Silk lining", "Dry clean only"]),
    ]

    static let outerwear: [FashionItem] = [
        fashionItem("karen-trench", "Karen Cotton Trench", category: .outerwear, designer: "wanjiru",
                    price: 38_500, rating: 4.8, reviews: 203, badges: [.bestseller], popularity: 98,
                    colors: [FashionColorway("camel", "Camel", P.camel, P.ink), FashionColorway("olive", "Olive", P.olive, P.sand)],
                    sizes: FashionSizes.apparel, low: ["L"],
                    summary: "The long-rains trench: water-repellent gabardine with a storm flap.",
                    details: "Double-breasted with a belted waist, epaulettes and a deep back vent.",
                    materials: ["Cotton gabardine", "Water-repellent finish", "Horn buttons"]),
        fashionItem("ngong-blazer", "Ngong Wool Blazer", category: .outerwear, designer: "wanjiru",
                    price: 32_000, rating: 4.7, reviews: 97, badges: [.new], isNew: true, popularity: 85,
                    colors: [FashionColorway("ink", "Ink", P.ink, P.gold), FashionColorway("charcoal", "Charcoal", P.charcoal, P.bone)],
                    sizes: FashionSizes.apparel,
                    summary: "Strong shoulders, a nipped waist and a single covered button.",
                    details: "Single-breasted, peak lapels, jetted pockets, fully lined.",
                    materials: ["Virgin wool", "Cupro lining", "Dry clean only"]),
        fashionItem("savannah-suede", "Savannah Suede Jacket", category: .outerwear, designer: "nia",
                    price: 45_500, was: 52_000, rating: 4.5, reviews: 64, popularity: 66,
                    colors: [FashionColorway("cognac", "Cognac", P.cognac, P.sand), FashionColorway("olive", "Olive", P.olive, P.cognac)],
                    sizes: FashionSizes.apparel,
                    summary: "Buttery suede, cut boxy, softened by hand in Stone Town.",
                    details: "Snap front, two patch pockets and a cropped hem.",
                    materials: ["Goat suede", "Cotton lining", "Specialist leather clean"]),
        fashionItem("tsavo-utility", "Tsavo Utility Jacket", category: .outerwear, designer: "wanjiru",
                    price: 24_500, rating: 4.4, reviews: 41, badges: [.eco], popularity: 55,
                    colors: [FashionColorway("sage", "Sage", P.sage, P.bone), FashionColorway("sand", "Sand", P.sand, P.olive)],
                    sizes: FashionSizes.apparel,
                    summary: "Four bellows pockets and a drawstring waist, in organic canvas.",
                    details: "Stand collar, zip and snap front, adjustable cuffs.",
                    materials: ["Organic cotton canvas", "Machine wash 30°", "Made in Nairobi"]),
    ]
}

// MARK: - Shoes and bags

extension FashionCatalogue {
    static let shoes: [FashionItem] = [
        fashionItem("kilimani-sneaker", "Kilimani Leather Sneaker", category: .shoes, designer: "nia",
                    price: 16_500, rating: 4.7, reviews: 312, badges: [.bestseller], popularity: 99,
                    colors: [FashionColorway("bone", "Bone", P.bone, P.gold), FashionColorway("ink", "Ink", P.ink, P.bone)],
                    sizes: FashionSizes.shoes, low: ["EU 42"], soldOut: ["EU 44"],
                    summary: "A clean court shape in full-grain leather, with a gold heel tab.",
                    details: "Cup sole stitched to the upper, padded collar, waxed cotton laces.",
                    materials: ["Full-grain leather upper", "Natural rubber sole", "Wipe clean"]),
        fashionItem("stonetown-court", "Stone Town Court Sneaker", category: .shoes, designer: "nia",
                    price: 14_900, was: 18_600, rating: 4.5, reviews: 118, popularity: 77,
                    colors: [FashionColorway("bone", "Bone & terracotta", P.bone, P.terracotta), FashionColorway("sand", "Sand", P.sand, P.cognac)],
                    sizes: FashionSizes.shoes, soldOut: ["EU 37"],
                    summary: "Terracotta panels borrowed from the carved doors of Stone Town.",
                    details: "Suede overlays on a leather base, perforated toe, cushioned insole.",
                    materials: ["Leather and suede", "Rubber sole", "Brush suede to clean"]),
        fashionItem("malindi-runner", "Malindi Runner", category: .shoes, designer: "nia",
                    price: 13_500, rating: 4.3, reviews: 76, badges: [.new, .eco], isNew: true, popularity: 72,
                    colors: [FashionColorway("ocean", "Ocean", P.ocean, P.bone), FashionColorway("sage", "Sage", P.sage, P.ink)],
                    sizes: FashionSizes.shoes,
                    summary: "A light runner knitted from recycled ocean plastic collected at Watamu.",
                    details: "Sock-fit knit upper, foam midsole, pull tab at the heel.",
                    materials: ["Recycled polyester knit", "Sugarcane foam sole", "Machine wash cold"]),
        fashionItem("nanyuki-trainer", "Nanyuki Suede Trainer", category: .shoes, designer: "nia",
                    price: 17_800, rating: 4.6, reviews: 58, badges: [.new], isNew: true, popularity: 64,
                    colors: [FashionColorway("camel", "Camel", P.camel, P.bone), FashionColorway("charcoal", "Charcoal", P.charcoal, P.gold)],
                    sizes: FashionSizes.shoes, low: ["EU 39"],
                    summary: "Highland suede trainers with a gum sole for cold Nanyuki mornings.",
                    details: "Suede upper, leather lining, gum rubber sole.",
                    materials: ["Cow suede", "Leather lining", "Gum rubber sole"]),
    ]

    static let bags: [FashionItem] = [
        fashionItem("amani-tote", "Amani Leather Tote", category: .bags, designer: "nia",
                    price: 36_000, rating: 4.9, reviews: 241, badges: [.bestseller], popularity: 97,
                    colors: [FashionColorway("cognac", "Cognac", P.cognac, P.gold), FashionColorway("ink", "Ink", P.ink, P.gold)],
                    sizes: [],
                    summary: "The house tote: vegetable-tanned leather that darkens beautifully with time.",
                    details: "Fits a 14-inch laptop. Inside zip pocket, magnetic closure, brass feet.",
                    materials: ["Vegetable-tanned leather", "Brass hardware", "Condition twice a year"]),
        fashionItem("lamu-basket", "Lamu Raffia Basket Tote", category: .bags, designer: "salim",
                    price: 12_800, rating: 4.6, reviews: 102, badges: [.new, .eco], isNew: true, popularity: 83,
                    colors: [FashionColorway("sand", "Natural", P.sand, P.cognac), FashionColorway("bone", "Bone & ocean", P.bone, P.ocean)],
                    sizes: [],
                    summary: "Woven by a women's co-operative on Lamu island, trimmed in leather.",
                    details: "Open top, leather handles, cotton pouch inside.",
                    materials: ["Hand-woven raffia", "Leather trim", "Keep dry"]),
        fashionItem("zanzibar-carryall", "Zanzibar Weekender", category: .bags, designer: "nia",
                    price: 48_000, rating: 4.7, reviews: 39, badges: [.exclusive], popularity: 50,
                    colors: [FashionColorway("olive", "Olive", P.olive, P.cognac), FashionColorway("claret", "Claret", P.claret, P.gold)],
                    sizes: [],
                    summary: "Two nights in Paje, carry-on sized.",
                    details: "Waxed canvas body, leather handles, detachable shoulder strap.",
                    materials: ["Waxed cotton canvas", "Leather trims", "Wipe clean"]),
        fashionItem("riverside-mini", "Riverside Mini Tote", category: .bags, designer: "nia",
                    price: 19_500, was: 24_000, rating: 4.4, reviews: 66, popularity: 69,
                    colors: [FashionColorway("blush", "Blush", P.blush, P.gold), FashionColorway("charcoal", "Charcoal", P.charcoal, P.bone)],
                    sizes: [],
                    summary: "The Amani tote, shrunk to hold a phone, keys and a lipstick.",
                    details: "Top handles and a crossbody strap. Snap closure.",
                    materials: ["Pebbled leather", "Gold-tone hardware", "Wipe clean"]),
    ]
}

// MARK: - Accessories

extension FashionCatalogue {
    static let accessories: [FashionItem] = [
        fashionItem("diani-cateye", "Diani Cat-Eye Sunglasses", category: .accessories, designer: "nia",
                    price: 11_900, rating: 4.6, reviews: 147, badges: [.new], isNew: true, popularity: 88,
                    colors: [FashionColorway("tortoise", "Tortoise", P.cognac, P.gold), FashionColorway("ink", "Ink", P.ink, P.gold)],
                    sizes: [],
                    summary: "A lifted cat-eye in hand-polished acetate, made for Diani glare.",
                    details: "UV400 lenses, five-barrel hinges, comes in a kikoi pouch.",
                    materials: ["Bio-acetate frame", "UV400 lenses", "Clean with the pouch"]),
        fashionItem("watamu-aviator", "Watamu Aviator Sunglasses", category: .accessories, designer: "nia",
                    price: 13_200, rating: 4.5, reviews: 73, popularity: 62,
                    colors: [FashionColorway("gold", "Gold & ocean", P.gold, P.ocean), FashionColorway("charcoal", "Gunmetal", P.charcoal, P.ink)],
                    sizes: [],
                    summary: "A slim metal aviator with gradient lenses.",
                    details: "Adjustable nose pads, spring hinges, polarised lenses.",
                    materials: ["Titanium frame", "Polarised lenses", "Hard case included"]),
        fashionItem("oud-kahawa", "Oud Kahawa Eau de Parfum", category: .accessories, designer: "nia", kind: .bottle,
                    price: 9_800, rating: 4.8, reviews: 189, badges: [.bestseller], popularity: 90,
                    colors: [FashionColorway("amber", "Amber", P.cognac, P.gold)],
                    sizes: FashionSizes.scent, sizePrices: ["50 ml": 9_800, "100 ml": 14_500],
                    summary: "Roasted Kenyan coffee, oud and a trail of vanilla.",
                    details: "Blended in Stone Town. Lasts eight hours or more on skin.",
                    materials: ["Eau de parfum, 18% concentration", "Recyclable glass", "Keep out of sunlight"]),
        fashionItem("forodhani-jasmine", "Forodhani Jasmine Eau de Parfum", category: .accessories, designer: "salim", kind: .bottle,
                    price: 8_900, rating: 4.7, reviews: 94, badges: [.new], isNew: true, popularity: 74,
                    colors: [FashionColorway("pearl", "Pearl", P.blush, P.gold)],
                    sizes: FashionSizes.scent, sizePrices: ["50 ml": 8_900, "100 ml": 13_200],
                    summary: "Night jasmine and sea salt from the Forodhani gardens at dusk.",
                    details: "A soft floral that stays close to the skin.",
                    materials: ["Eau de parfum, 15% concentration", "Recyclable glass", "Keep out of sunlight"]),
    ]
}

// MARK: - Size guides, looks and editorials

extension FashionCatalogue {
    static let apparelGuide = KitoSizeGuide(
        title: "Maison size guide",
        measurements: ["Bust", "Waist", "Hip"],
        rows: [
            KitoSizeGuideRow("XS", values: [80, 62, 88]),
            KitoSizeGuideRow("S", values: [84, 66, 92]),
            KitoSizeGuideRow("M", values: [88, 70, 96]),
            KitoSizeGuideRow("L", values: [94, 76, 102]),
            KitoSizeGuideRow("XL", values: [100, 82, 108]),
        ],
        howToMeasure: [
            KitoMeasureStep("Bust", detail: "Around the fullest part, keeping the tape level.", systemImage: "circle.dashed"),
            KitoMeasureStep("Waist", detail: "Around the narrowest part of your natural waist.", systemImage: "arrow.left.and.right"),
            KitoMeasureStep("Hip", detail: "Around the fullest part, feet together.", systemImage: "ruler"),
        ],
        fit: KitoFitFeedback(value: -0.15, reviewCount: 412))

    static let shoeGuide = KitoSizeGuide(
        title: "Shoe size guide",
        measurements: ["UK", "Foot (cm)"],
        rows: [
            KitoSizeGuideRow("EU 37", values: [4, 23.5]),
            KitoSizeGuideRow("EU 38", values: [5, 24.1]),
            KitoSizeGuideRow("EU 39", values: [6, 24.8]),
            KitoSizeGuideRow("EU 40", values: [6.5, 25.4]),
            KitoSizeGuideRow("EU 41", values: [7.5, 26.0]),
            KitoSizeGuideRow("EU 42", values: [8, 26.7]),
            KitoSizeGuideRow("EU 43", values: [9, 27.3]),
            KitoSizeGuideRow("EU 44", values: [9.5, 28.0]),
        ],
        allowsInches: false,
        howToMeasure: [
            KitoMeasureStep("Stand on paper", detail: "Heel against a wall, weight on both feet.", systemImage: "figure.stand"),
            KitoMeasureStep("Mark your longest toe", detail: "Measure from the wall to the mark.", systemImage: "ruler"),
            KitoMeasureStep("Between sizes?", detail: "Take the larger one. Our leather softens with wear.", systemImage: "arrow.up.right"),
        ],
        fit: KitoFitFeedback(value: 0.3, reviewCount: 564))

    static let looks: [FashionLook] = [
        FashionLook(id: "lamu-dusk", title: "Lamu at dusk", place: "Shela, Lamu",
                    note: "Silk, raffia and gold light over the channel.",
                    artwork: KitoProductArtwork(.dress, primary: P.sand, accent: P.gold, backdrop: Color(red: 0.86, green: 0.74, blue: 0.62), framing: .angled),
                    productIDs: ["shela-slip", "lamu-basket", "diani-cateye", "forodhani-jasmine"]),
        FashionLook(id: "nairobi-rain", title: "Long rains", place: "Karen, Nairobi",
                    note: "A trench, a tote and leather that doesn't mind the weather.",
                    artwork: KitoProductArtwork(.jacket, primary: P.camel, accent: P.ink, backdrop: Color(red: 0.72, green: 0.74, blue: 0.72), framing: .angled),
                    productIDs: ["karen-trench", "amani-tote", "kilimani-sneaker", "oud-kahawa"]),
        FashionLook(id: "zanzibar-noon", title: "Stone Town noon", place: "Zanzibar",
                    note: "Terracotta, tortoiseshell and a weekender packed light.",
                    artwork: KitoProductArtwork(.tote, primary: P.olive, accent: P.cognac, backdrop: Color(red: 0.84, green: 0.66, blue: 0.54), framing: .angled),
                    productIDs: ["kanga-wrap", "zanzibar-carryall", "stonetown-court", "watamu-aviator"]),
    ]

    static func look(_ id: String) -> FashionLook? { looks.first { $0.id == id } }

    static let editorials: [FashionEditorial] = [
        FashionEditorial(id: "resort", kicker: "Resort 2026", title: "The Lamu edit",
                         subtitle: "Slip dresses and raffia for slow island days",
                         artwork: KitoProductArtwork(.dress, primary: P.ocean, accent: P.bone, backdrop: Color(red: 0.80, green: 0.72, blue: 0.62), framing: .angled),
                         destination: .look("lamu-dusk")),
        FashionEditorial(id: "tailoring", kicker: "The atelier", title: "New tailoring",
                         subtitle: "Wanjiru Kamau's sharpest season yet",
                         artwork: KitoProductArtwork(.jacket, primary: P.ink, accent: P.gold, backdrop: Color(red: 0.62, green: 0.60, blue: 0.57), framing: .angled),
                         destination: .category(.outerwear)),
        FashionEditorial(id: "leather", kicker: "Hand-stitched", title: "Leather goods",
                         subtitle: "Totes that grow better with every year",
                         artwork: KitoProductArtwork(.tote, primary: P.cognac, accent: P.gold, backdrop: Color(red: 0.78, green: 0.66, blue: 0.54), framing: .angled),
                         destination: .category(.bags)),
        FashionEditorial(id: "scent", kicker: "Stone Town", title: "Scents of the coast",
                         subtitle: "Coffee, oud and night jasmine",
                         artwork: KitoProductArtwork(.bottle, primary: P.cognac, accent: P.gold, backdrop: Color(red: 0.55, green: 0.45, blue: 0.40), framing: .angled),
                         destination: .category(.accessories)),
    ]
}
