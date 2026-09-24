//
//  FashionBrowse.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoProduct
import KitoNavigation

// MARK: - Category

/// Every piece in a category, with a sort switch across the top.
struct FashionCategoryScreen: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.kitoTheme) private var theme
    let category: FashionCategory
    @State private var sort = "Featured"

    private static let sorts = ["Featured", "New in", "Price: low", "Price: high"]

    private var items: [FashionItem] {
        let all = FashionCatalogue.items(in: category)
        switch sort {
        case "New in": return all.sorted { ($0.isNew ? 1 : 0, $0.popularity) > ($1.isNew ? 1 : 0, $1.popularity) }
        case "Price: low": return all.sorted { $0.product.price < $1.product.price }
        case "Price: high": return all.sorted { $0.product.price > $1.product.price }
        default: return all.sorted { $0.popularity > $1.popularity }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                VStack(alignment: .leading, spacing: 6) {
                    FashionKicker("\(items.count) pieces")
                    Text(category.title)
                        .font(theme.typography.displayLarge)
                        .foregroundStyle(theme.colors.onBackground)
                        .accessibilityAddTraits(.isHeader)
                }
                .padding(.horizontal, theme.spacing.lg)
                KitoTopTabs(Self.sorts, selection: $sort, style: .chips)
                FashionGrid(products: items.map(\.product))
            }
            .padding(.top, theme.spacing.md)
            .padding(.bottom, theme.spacing.xxl)
        }
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Look

/// A lookbook story: the campaign image, a note and every piece in it.
struct FashionLookScreen: View {
    @Environment(\.kitoTheme) private var theme
    let look: FashionLook

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                KitoProductArtworkView(look.artwork)
                    .frame(height: 440)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            FashionKicker(look.place).foregroundStyle(.white.opacity(0.85))
                            Text(look.title)
                                .font(.system(size: 36, weight: .regular, design: .serif))
                                .foregroundStyle(.white)
                        }
                        .padding(theme.spacing.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(look.title), \(look.place)")
                Text(look.note)
                    .font(.system(size: 19, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(theme.colors.onBackground.opacity(0.8))
                    .padding(.horizontal, theme.spacing.lg)
                FashionSectionHeader(kicker: "Shop the look", title: "\(look.productIDs.count) pieces")
                FashionGrid(products: look.productIDs.compactMap { FashionCatalogue.item($0)?.product })
            }
            .padding(.bottom, theme.spacing.xxl)
        }
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle(look.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Designer

struct FashionDesignerScreen: View {
    @Environment(\.kitoTheme) private var theme
    let designer: FashionDesigner

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                HStack(spacing: theme.spacing.md) {
                    FashionDesignerAvatar(designer: designer, size: 72)
                    VStack(alignment: .leading, spacing: 4) {
                        FashionKicker("\(designer.discipline) · \(designer.city)")
                        Text(designer.name)
                            .font(theme.typography.displayMedium)
                            .foregroundStyle(theme.colors.onBackground)
                            .accessibilityAddTraits(.isHeader)
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                Text(designer.bio)
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundStyle(theme.colors.onBackground.opacity(0.8))
                    .padding(.horizontal, theme.spacing.lg)
                FashionGrid(products: FashionCatalogue.items(by: designer.id).map(\.product))
            }
            .padding(.top, theme.spacing.lg)
            .padding(.bottom, theme.spacing.xxl)
        }
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle(designer.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Initials on the designer's two colours.
struct FashionDesignerAvatar: View {
    let designer: FashionDesigner
    var size: CGFloat = 56

    var body: some View {
        Circle()
            .fill(LinearGradient(colors: designer.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Text(designer.initials)
                    .font(.system(size: size * 0.34, weight: .regular, design: .serif))
                    .foregroundStyle(.white)
            }
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

// MARK: - Grid

/// KitoProduct's staggered grid, wired to the shared wishlist and bag.
struct FashionGrid: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.kitoTheme) private var theme
    let products: [KitoProduct]

    var body: some View {
        KitoProductGrid(products, style: .grid, layout: .staggered, wishlist: store.wishlistBinding,
                        onSelect: { store.open(product: $0.id) },
                        onQuickAdd: { store.add($0, $1) })
            .padding(.horizontal, theme.spacing.lg)
    }
}
