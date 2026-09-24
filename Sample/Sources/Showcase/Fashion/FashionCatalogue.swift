//
//  FashionCatalogue.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoProduct

// MARK: - Models

enum FashionCategory: String, CaseIterable, Identifiable, Hashable {
    case dresses, outerwear, shoes, bags, accessories

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dresses: "Dresses"
        case .outerwear: "Outerwear"
        case .shoes: "Shoes"
        case .bags: "Bags"
        case .accessories: "Accessories"
        }
    }

    var systemImage: String {
        switch self {
        case .dresses: "figure.stand.dress"
        case .outerwear: "tshirt.fill"
        case .shoes: "shoeprints.fill"
        case .bags: "handbag.fill"
        case .accessories: "sunglasses.fill"
        }
    }
}

struct FashionDesigner: Identifiable, Hashable {
    let id: String
    let name: String
    let discipline: String
    let city: String
    let bio: String
    let initials: String
    let colors: [Color]
}

struct FashionItem: Identifiable, Hashable {
    var id: String { product.id }
    let product: KitoProduct
    let category: FashionCategory
    let designerID: String
    let isNew: Bool
    /// Higher sells more; drives "Trending" and the "Most popular" sort.
    let popularity: Int

    var designer: FashionDesigner { FashionCatalogue.designer(designerID) }
    var heroArtwork: KitoProductMedia { product.media.first ?? .artwork(.tote(primary: .gray, accent: .white)) }
    var priceValue: Double { NSDecimalNumber(decimal: product.price).doubleValue }
}

/// A styled story told with a few pieces: the lookbook on Home.
struct FashionLook: Identifiable, Hashable {
    let id: String
    let title: String
    let place: String
    let note: String
    let artwork: KitoProductArtwork
    let productIDs: [String]
}

/// One slide of the editorial hero.
struct FashionEditorial: Identifiable, Hashable {
    let id: String
    let kicker: String
    let title: String
    let subtitle: String
    let artwork: KitoProductArtwork
    let destination: FashionRoute
}

// MARK: - Catalogue

enum FashionCatalogue {
    static let designers: [FashionDesigner] = [
        FashionDesigner(id: "wanjiru", name: "Wanjiru Kamau", discipline: "Tailoring", city: "Nairobi",
                        bio: "Sharp shoulders, soft wool and a cut learned on River Road. Wanjiru founded the atelier in 2014.",
                        initials: "WK", colors: [FashionPalette.ink, FashionPalette.charcoal]),
        FashionDesigner(id: "salim", name: "Salim Mbarak", discipline: "Resort", city: "Lamu",
                        bio: "Silk that moves like a dhow sail. Salim works from a courtyard studio in Shela.",
                        initials: "SM", colors: [FashionPalette.ocean, FashionPalette.sand]),
        FashionDesigner(id: "nia", name: "Nia Oduya", discipline: "Leather & accessories", city: "Zanzibar",
                        bio: "Hand-stitched leather, tortoiseshell frames and fragrances blended in Stone Town.",
                        initials: "NO", colors: [FashionPalette.cognac, FashionPalette.gold]),
    ]

    static func designer(_ id: String) -> FashionDesigner {
        designers.first { $0.id == id } ?? designers[0]
    }

    static let items: [FashionItem] = dresses + outerwear + shoes + bags + accessories

    static func item(_ id: String) -> FashionItem? {
        items.first { $0.id == id }
    }

    /// The catalogue item behind a bag line. Bag lines use variant ids that start with the product id.
    static func item(forCartID id: String) -> FashionItem? {
        items.first { id == $0.id || id.hasPrefix($0.id + "~") }
    }

    static func items(in category: FashionCategory) -> [FashionItem] {
        items.filter { $0.category == category }
    }

    static func items(by designerID: String) -> [FashionItem] {
        items.filter { $0.designerID == designerID }
    }

    static var newIn: [FashionItem] { items.filter(\.isNew) }
    static var trending: [FashionItem] { items.sorted { $0.popularity > $1.popularity } }
    static var products: [KitoProduct] { items.map(\.product) }

    /// Pieces from other categories that finish an outfit.
    static func completeTheLook(for item: FashionItem) -> [KitoProduct] {
        if let look = looks.first(where: { $0.productIDs.contains(item.id) }) {
            let others = look.productIDs.filter { $0 != item.id }.compactMap { self.item($0)?.product }
            if others.count >= 3 { return others }
        }
        let others = FashionCategory.allCases.filter { $0 != item.category }
        return others.compactMap { category in trending.first { $0.category == category }?.product }
    }

    static func sizeGuide(for category: FashionCategory) -> KitoSizeGuide? {
        switch category {
        case .dresses, .outerwear: apparelGuide
        case .shoes: shoeGuide
        case .bags, .accessories: nil
        }
    }
}
