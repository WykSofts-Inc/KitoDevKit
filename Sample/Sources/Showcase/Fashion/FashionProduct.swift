//
//  FashionProduct.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoProduct
import KitoToasts

/// The product page: KitoProduct's detail view wired to the shared bag and wishlist, with reviews in a sheet.
struct FashionProductScreen: View {
    @Environment(FashionStore.self) private var store
    let item: FashionItem
    @State private var model: KitoProductDetailModel
    @State private var showsReviews = false
    @State private var reviewCount: Int

    init(item: FashionItem, store: FashionStore) {
        self.item = item
        _model = State(initialValue: KitoProductDetailModel(item.product, isWishlisted: store.isSaved(item.id),
                                                            bagCount: store.cart.totalQuantity))
        _reviewCount = State(initialValue: item.product.reviewCount)
    }

    var body: some View {
        KitoProductDetailView(
            model: model,
            related: FashionCatalogue.completeTheLook(for: item),
            wishlist: wishlist,
            sizeGuide: FashionCatalogue.sizeGuide(for: item.category),
            delivery: KitoDeliveryEstimator(minDays: 1, maxDays: 2, cutoffHour: 15, closedWeekdays: [1]),
            deliveryDetail: "Complimentary delivery over KES 25,000 · 30-day returns",
            instalments: 3,
            onAddToBag: { product, variant in store.add(product, variant) },
            onSelectRelated: { store.open(product: $0.id) },
            onNotifyMe: { product, size in
                store.toasts.show(KitoToast(title: "We'll let you know",
                                            message: "You'll hear from us when \(product.name) is back in \(size.label).",
                                            icon: .custom("bell.fill"), accentColor: FashionPalette.gold))
            },
            onShowReviews: { showsReviews = true },
            onOpenBag: { store.show(.bag) })
        .navigationTitle(item.designer.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showsReviews = true } label: {
                    FashionCompactRating(rating: item.product.rating ?? 0, count: reviewCount)
                }
                .accessibilityLabel("Reviews, \(String(format: "%.1f", item.product.rating ?? 0)) stars from \(reviewCount) reviews")
            }
        }
        .sheet(isPresented: $showsReviews) {
            FashionReviewsSheet(productName: item.product.name, designerName: item.designer.name,
                                rating: item.product.rating ?? 4.5, reviewCount: reviewCount, seed: item.id,
                                authorName: store.user?.name) {
                reviewCount += 1
                store.toasts.show(KitoToast(message: "Thank you, your review is live", style: .success, layout: .pill))
            }
            .presentationDragIndicator(.visible)
        }
    }

    /// Every heart on the page, "Complete the look" included, saves to the shared wishlist
    /// through the store, so saving still shows the toast.
    private var wishlist: Binding<Set<String>> {
        Binding(get: { store.wishlist },
                set: { saved in
                    for id in saved.subtracting(store.wishlist) { store.setSaved(id, true) }
                    for id in store.wishlist.subtracting(saved) { store.setSaved(id, false) }
                })
    }
}
