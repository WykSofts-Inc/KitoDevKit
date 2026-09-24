//
//  FashionWishlist.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoEmptyStates
import KitoProduct

/// Saved pieces in a grid, or an animated empty state when there are none.
struct FashionWishlistScreen: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.kitoTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var saved: [FashionItem] {
        FashionCatalogue.items.filter { store.wishlist.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                VStack(alignment: .leading, spacing: 6) {
                    FashionKicker(saved.isEmpty ? "Nothing saved" : saved.count == 1 ? "1 piece" : "\(saved.count) pieces")
                    Text("Wishlist")
                        .font(theme.typography.displayLarge)
                        .foregroundStyle(theme.colors.onBackground)
                        .accessibilityAddTraits(.isHeader)
                }
                .padding(.horizontal, theme.spacing.lg)

                if saved.isEmpty {
                    KitoEmptyStateView(
                        media: .illustration(.favourites.tinted(FashionPalette.gold, FashionPalette.cognac)),
                        title: "Save what you love",
                        message: "Tap the heart on any piece and it will wait for you here, across every tab.",
                        actions: [
                            KitoEmptyStateAction(title: "Discover new in") { store.show(.home) },
                            KitoEmptyStateAction(title: "Search the collection", role: .secondary) { store.show(.search) },
                        ])
                        .padding(.top, theme.spacing.xl)
                        .transition(.opacity)
                } else {
                    FashionGrid(products: saved.map(\.product))
                        .transition(.opacity)
                    savedTotal
                }
            }
            .padding(.top, theme.spacing.md)
            .padding(.bottom, theme.spacing.xxl)
            .animation(FashionMotion.spring(reduceMotion), value: store.wishlist)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var savedTotal: some View {
        let total = saved.reduce(Decimal(0)) { $0 + $1.product.price }
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your wishlist").font(theme.typography.caption).foregroundStyle(theme.colors.onSurface.opacity(0.6))
                Text(KitoMoney.string(total, currencyCode: "KES"))
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundStyle(theme.colors.onSurface)
            }
            Spacer()
            Text(total >= FashionCheckoutSetup.freeDeliveryThreshold ? "Qualifies for free delivery" : "Free delivery over KES 25,000")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.onSurface.opacity(0.6))
                .multilineTextAlignment(.trailing)
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous).stroke(theme.colors.border))
        .padding(.horizontal, theme.spacing.lg)
        .accessibilityElement(children: .combine)
    }
}
