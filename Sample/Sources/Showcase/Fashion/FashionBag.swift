//
//  FashionBag.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoCheckout
import KitoProduct

/// The bag: KitoCart's page with free-delivery progress and promo codes, then KitoCheckout full screen.
struct FashionBagScreen: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.kitoTheme) private var theme
    @State private var showsCheckout = false

    var body: some View {
        VStack(spacing: 0) {
            header
            if let order = store.activeOrder {
                FashionTrackingCard(order: order) { store.open(.tracking(order.id)) }
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.bottom, theme.spacing.sm)
            }
            if store.cart.isEmpty {
                // KitoCartView's own empty state talks about a menu, so the bag draws its own.
                ScrollView {
                    KitoEmptyCartView(title: "Your bag is empty",
                                      message: "Pieces you add from any tab land here, ready for checkout.",
                                      actionTitle: "Discover new in") { store.show(.home) }
                        .padding(.top, theme.spacing.xxl)
                        .frame(maxWidth: .infinity)
                }
                .kitoCartUndoBar(store.cart)
            } else {
                KitoCartView(cart: store.cart, rules: FashionCheckoutSetup.cartRules,
                             promoValidator: FashionCheckoutSetup.promos, checkoutTitle: "Checkout",
                             onCheckout: { pricing in
                                 store.beginCheckout(promo: pricing.promo)
                                 showsCheckout = true
                             },
                             onBrowse: { store.show(.home) }) { item in
                    FashionCartThumbnail(item: item)
                }
            }
        }
        .background(theme.colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showsCheckout) {
            FashionCheckoutCover(isPresented: $showsCheckout)
                .environment(store)
        }
    }

    private var header: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("Bag")
                .font(theme.typography.displayLarge)
                .foregroundStyle(theme.colors.onBackground)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if !store.cart.isEmpty {
                FashionKicker(store.cart.totalQuantity == 1 ? "1 piece" : "\(store.cart.totalQuantity) pieces")
            }
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.top, theme.spacing.md)
        .padding(.bottom, theme.spacing.sm)
    }
}

/// The product artwork for a bag line, in the colour that was chosen.
struct FashionCartThumbnail: View {
    @Environment(\.kitoTheme) private var theme
    let item: KitoCartItem

    private var media: KitoProductMedia? {
        guard let product = FashionCatalogue.item(forCartID: item.id)?.product else { return nil }
        let parts = item.id.components(separatedBy: "~")
        let colorID = parts.count > 1 ? parts[1] : nil
        return product.media(for: colorID).first
    }

    var body: some View {
        Group {
            if let media {
                KitoProductMediaView(media)
            } else {
                theme.colors.surfaceMuted.overlay(Image(systemName: "bag").foregroundStyle(.secondary))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: theme.radii.md, style: .continuous))
        .accessibilityHidden(true)
    }
}

// MARK: - Checkout

private struct FashionCheckoutCover: View {
    @Environment(FashionStore.self) private var store
    @Binding var isPresented: Bool

    var body: some View {
        FashionThemed(appearance: store.appearance) {
            KitoCheckoutFlow(model: store.checkout, title: "Checkout", progressStyle: .segmented,
                             onClose: { isPresented = false },
                             onTrackOrder: { _ in finish(track: true) },
                             onContinueShopping: { finish(track: false) },
                             onPlaceOrder: { order in try await store.place(order) }) { item in
                FashionCartThumbnail(item: item)
            }
        }
    }

    private func finish(track: Bool) {
        isPresented = false
        store.finishCheckout(track: track)
    }
}
