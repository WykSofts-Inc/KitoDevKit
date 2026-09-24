//
//  FashionSearch.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import UIKit
import KitoCore
import KitoProduct
import KitoSearch

/// Search over the offline catalogue: recents, trending, categories, typo-tolerant matching and filters.
struct FashionSearchScreen: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.kitoTheme) private var theme
    @State private var search = FashionSearchScreen.makeModel()
    @State private var showsFilters = false

    private static let filters = KitoFilterConfiguration<FashionItem>(
        facetsTitle: "Designers",
        facets: FashionCatalogue.designers.map { designer in
            KitoFilterFacet(designer.id, title: designer.name) { $0.designerID == designer.id }
        },
        toggles: [
            KitoFilterFacet("new", title: "New in", systemImage: "sparkles") { $0.isNew },
            KitoFilterFacet("sale", title: "On sale", systemImage: "tag") { $0.product.isOnSale },
            KitoFilterFacet("instock", title: "In stock", systemImage: "checkmark.circle") { ($0.product.totalStock ?? 1) > 0 },
        ],
        price: { $0.priceValue }, priceBounds: 0...50_000, priceStep: 500, currencyCode: "KES",
        rating: { $0.product.rating ?? 0 }, ratingSteps: [4, 4.5, 4.8],
        sorts: [
            KitoSortOption("popular", title: "Most popular", systemImage: "flame") { $0.popularity > $1.popularity },
            KitoSortOption("low", title: "Price: low to high", systemImage: "arrow.up") { $0.product.price < $1.product.price },
            KitoSortOption("high", title: "Price: high to low", systemImage: "arrow.down") { $0.product.price > $1.product.price },
            KitoSortOption("rating", title: "Top rated", systemImage: "star") { ($0.product.rating ?? 0) > ($1.product.rating ?? 0) },
        ])

    private static func makeModel() -> KitoSearchModel<FashionItem> {
        KitoSearchModel.local(
            FashionCatalogue.items,
            text: { "\($0.product.name) \($0.designer.name) \($0.category.title) \($0.product.colors.map(\.name).joined(separator: " "))" },
            filters: filters,
            token: { item, token in item.category.title == token.value },
            latency: .milliseconds(350),
            recentsKey: "maison.search.recents",
            trending: ["Silk dress", "Trench", "Leather tote", "Sneakers", "Oud"],
            suggestions: FashionCatalogue.items.map(\.product.name))
    }

    private var categories: [KitoSearchCategory] {
        FashionCategory.allCases.map { KitoSearchCategory($0.title, systemImage: $0.systemImage, color: FashionPalette.gold) }
    }

    var body: some View {
        KitoSearchScreen(model: search, prompt: "Dresses, designers, colours", fieldStyle: .capsule,
                         categories: categories, skeletonStyle: .card,
                         section: { $0.category.title },
                         onSelect: { store.open(product: $0.id) }) { item, query in
            KitoSearchResultRow(title: item.product.name, subtitle: item.designer.name,
                                detail: KitoMoney.string(item.product.price, currencyCode: "KES"),
                                badge: item.isNew ? "New" : (item.product.isOnSale ? "Sale" : nil),
                                image: FashionThumbnails.image(for: item),
                                rating: item.product.rating, query: query, style: .card)
        } header: {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                KitoFilterChips(Self.filters.options(for: search.filters, in: FashionCatalogue.items),
                                selection: $search.filters.facets,
                                activeFilters: search.filters.activeCount) { showsFilters = true }
                let applied = Self.filters.appliedFilters(for: search.filters)
                if !applied.isEmpty {
                    KitoAppliedFilterPills(applied,
                                           onRemove: { search.filters.reduce(.remove($0.kind)) },
                                           onClearAll: { search.filters.reduce(.clearAll) })
                }
            }
            .padding(.bottom, theme.spacing.sm)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsFilters) {
            KitoFilterSheet(state: $search.filters, configuration: Self.filters, items: FashionCatalogue.items)
                .presentationDragIndicator(.visible)
        }
        .onChange(of: store.pendingSearch) { _, pending in consume(pending) }
        .onAppear { consume(store.pendingSearch) }
    }

    private func consume(_ pending: String?) {
        guard let pending else { return }
        store.pendingSearch = nil
        if let category = FashionCategory.allCases.first(where: { $0.title == pending }) {
            search.tokens = [KitoSearchCategory(category.title, systemImage: category.systemImage).token]
        } else {
            search.search(pending)
        }
    }
}

/// Small bitmaps of product artwork for rows that take an `Image`.
@MainActor
enum FashionThumbnails {
    private static var cache: [String: UIImage] = [:]

    static func image(for item: FashionItem) -> Image? {
        if let hit = cache[item.id] { return Image(uiImage: hit) }
        guard case .artwork(let artwork) = item.heroArtwork.source,
              let rendered = artwork.framed(.full).renderedImage(size: CGSize(width: 120, height: 150)) else { return nil }
        cache[item.id] = rendered
        return Image(uiImage: rendered)
    }
}
