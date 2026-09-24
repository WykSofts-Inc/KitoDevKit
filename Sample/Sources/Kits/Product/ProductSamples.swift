//
//  ProductSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoProduct

// MARK: - Sample data

private enum ProductData {
    static let runner = KitoProductSamples.runner
    static let dress = KitoProductSamples.dress
    static let tote = KitoProductSamples.tote
    static let jacket = KitoProductSamples.jacket
    static let scent = KitoProductSamples.scent
    static let all = KitoProductSamples.all
    static let looks = KitoProductSamples.looks

    static let ink = Color(red: 0.10, green: 0.10, blue: 0.12)
    static let ember = Color(red: 0.95, green: 0.45, blue: 0.20)

    static let artworks: [KitoProductArtwork] = [
        .sneaker(primary: ink, accent: ember),
        .tote(primary: Color(red: 0.62, green: 0.40, blue: 0.24), accent: Color(red: 0.85, green: 0.70, blue: 0.36)),
        .dress(primary: Color(red: 0.55, green: 0.12, blue: 0.20), accent: Color(red: 0.2, green: 0.08, blue: 0.1)),
        .jacket(primary: Color(red: 0.36, green: 0.40, blue: 0.26), accent: Color(red: 0.62, green: 0.40, blue: 0.24)),
        .sunglasses(primary: Color(red: 0.30, green: 0.18, blue: 0.10), accent: Color(red: 0.3, green: 0.25, blue: 0.2)),
        .bottle(primary: Color(white: 0.25), accent: Color(red: 0.85, green: 0.70, blue: 0.36)),
    ]
}

private struct ProductNote: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Product pages

private struct ProductSneakerPage: View {
    @State private var bag: [String] = []

    var body: some View {
        KitoProductDetailView(product: ProductData.runner, related: ProductData.looks,
                              sizeGuide: KitoProductSamples.shoeGuide,
                              onAddToBag: { product, variant in bag.append(variant.id) })
    }
}

private struct ProductDressPage: View {
    var body: some View {
        KitoProductDetailView(product: ProductData.dress, related: [ProductData.tote, KitoProductSamples.sunglasses],
                              sizeGuide: KitoProductSamples.apparelGuide,
                              delivery: KitoDeliveryEstimator(minDays: 2, maxDays: 4, cutoffHour: 12),
                              deliveryDetail: "Free returns within 30 days")
    }
}

private struct ProductTotePage: View {
    var body: some View {
        KitoProductDetailView(product: ProductData.tote, related: [ProductData.jacket, ProductData.dress],
                              instalments: 3, tint: Color(red: 0.62, green: 0.40, blue: 0.24))
    }
}

private struct ProductSoldOutPage: View {
    var body: some View {
        KitoProductDetailView(product: ProductData.scent, delivery: nil)
    }
}

// MARK: - Gallery

private struct ProductPagerSample: View {
    @State private var page = 0

    var body: some View {
        VStack(spacing: 12) {
            KitoProductGallery(ProductData.runner.media(for: "black"), selection: $page, cornerRadius: 20)
            ProductNote(text: "Photo \(page + 1). Swipe, pinch to peek, tap for full screen.")
        }
    }
}

private struct ProductThumbnailsSample: View {
    var body: some View {
        KitoProductGallery(ProductData.runner.media(for: "sand"), indicator: .thumbnails, cornerRadius: 20)
    }
}

private struct ProductCounterSample: View {
    var body: some View {
        KitoProductGallery(ProductData.jacket.media, indicator: .counter, aspectRatio: 3 / 4, cornerRadius: 28)
    }
}

private struct ProductHeroViewerScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                KitoProductGallery(ProductData.dress.media, indicator: .dots)
                VStack(alignment: .leading, spacing: 6) {
                    Text("ATELIER LUMO").font(.caption.weight(.semibold)).tracking(1.4).foregroundStyle(.secondary)
                    Text("Tap the photo: it grows into the viewer. Double-tap to zoom, drag down to close.")
                        .font(.subheadline)
                }
                .padding(.horizontal)
            }
        }
        .kitoProductViewerHost()
    }
}

private struct ProductSpinSample: View {
    var body: some View {
        KitoProductSpinViewer(frames: ProductData.runner.spinFrames)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Variants

private struct ProductSwatchesSample: View {
    @State private var colorID: String? = "black"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            KitoColorSwatches(product: ProductData.runner, selection: $colorID)
            KitoColorSwatches(product: KitoProductSamples.sunglasses, selection: .constant("tortoise"), size: 24)
            ProductNote(text: "Olive is sold out, so it's slashed. Two-tone swatches split on the diagonal.")
        }
    }
}

private struct ProductSizeGridSample: View {
    @State private var sizeID: String?
    @State private var error: String?
    @State private var attempts = 0

    private let matrix = KitoVariantMatrix(ProductData.runner)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KitoSizePicker(matrix.sizeOptions(for: "black"), selection: $sizeID, error: error,
                           shakeTrigger: attempts, onSizeGuide: {})
            Button("Add to bag") {
                if sizeID == nil {
                    error = KitoSelectionIssue.chooseSize.message
                    attempts += 1
                }
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .onChange(of: sizeID) { _, _ in error = nil }
    }
}

private struct ProductSizeChipsSample: View {
    @State private var sizeID: String? = "UK 10"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KitoSizePicker(KitoVariantMatrix(ProductData.runner).sizeOptions(for: "sand"),
                           selection: $sizeID, style: .chips)
            ProductNote(text: "UK 11 isn't made in sand. UK 10 is sold out: try Notify me.")
        }
    }
}

private struct ProductSizeGuideScreen: View {
    @State private var showsGuide = false
    @State private var sizeID: String? = "M"

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Chosen size: \(sizeID ?? "none")").font(.headline)
            Button("Open size guide") { showsGuide = true }
                .buttonStyle(GalleryPrimaryButtonStyle())
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showsGuide) {
            KitoSizeGuideSheet(guide: KitoProductSamples.apparelGuide, selection: $sizeID)
                .presentationDetents([.medium, .large])
        }
    }
}

private struct ProductFitSample: View {
    var body: some View {
        VStack(spacing: 14) {
            KitoFitFeedbackBar(KitoFitFeedback(value: 0.35, reviewCount: 214))
            KitoFitFeedbackBar(KitoFitFeedback(votes: [-1, -1, 0, -1, 0]))
        }
    }
}

// MARK: - Price and messages

private struct ProductPricesSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            KitoPriceTag(price: 9_900, compareAt: 13_200, instalments: 4, size: .large)
            KitoPriceTag(price: 18_500, instalments: 3)
            KitoPriceTag(price: 21_000, compareAt: 26_000, size: .small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProductStockSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KitoStockIndicator(stock: 24)
            KitoStockIndicator(stock: 7)
            KitoStockIndicator(stock: 2)
            KitoStockIndicator(stock: 1, style: .bar)
            KitoStockIndicator(stock: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProductDeliverySample: View {
    var body: some View {
        VStack(spacing: 16) {
            KitoDeliveryEstimateRow(estimator: KitoDeliveryEstimator(minDays: 1, maxDays: 2, cutoffHour: 14),
                                    detail: "Free delivery over KES 5,000")
            KitoDeliveryEstimateRow(estimator: KitoDeliveryEstimator(minDays: 0, cutoffHour: 12),
                                    detail: "Same-day in Nairobi", systemImage: "bicycle")
        }
    }
}

private struct ProductBadgesSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KitoProductBadges([.new, .bestseller, .lowStock, .eco])
            KitoProductBadges([.sale(percent: 25), .exclusive, KitoProductBadge("Online only")])
            KitoProductRatingLine(rating: 4.6, reviewCount: 214) {}
            KitoProductRatingLine(rating: 3.5, reviewCount: 1, starSize: 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProductAccordionSample: View {
    var body: some View {
        KitoProductAccordion(ProductData.runner.sections, initiallyExpanded: "Details")
    }
}

private struct ProductBagBarSample: View {
    @State private var state: KitoAddToBagState = .idle
    @State private var saved = false

    var body: some View {
        VStack(spacing: 16) {
            KitoAddToBagBar(price: "KES 9,900", state: state, isWishlisted: $saved) { run() }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            KitoAddToBagButton(state: .soldOut) {}
        }
    }

    private func run() {
        state = .adding
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            state = .added
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            state = .idle
        }
    }
}

private struct ProductWishlistSample: View {
    @State private var plain = false
    @State private var glass = true
    @State private var outlined = false

    var body: some View {
        HStack(spacing: 24) {
            KitoWishlistButton(isOn: $plain, size: 26)
            KitoWishlistButton(isOn: $glass, style: .glass)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.orange.gradient))
            KitoWishlistButton(isOn: $outlined, style: .outlined)
        }
    }
}

// MARK: - Cards

private struct ProductCardStylesSample: View {
    @State private var saved: Set<String> = ["soko-tote"]
    @State private var added: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 12) {
                KitoProductCard(ProductData.runner, style: .grid, isWishlisted: binding("runner-01"),
                                onQuickAdd: { product, variant in added = product.variantDescription(variant) ?? product.name })
                KitoProductCard(ProductData.tote, style: .editorial, isWishlisted: binding("soko-tote"),
                                onQuickAdd: { product, _ in added = product.name })
            }
            KitoProductCard(ProductData.jacket, style: .horizontal, isWishlisted: binding("field-jacket"),
                            onQuickAdd: { product, variant in added = product.variantDescription(variant) ?? product.name })
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(ProductData.looks) { KitoProductCard($0, style: .compact) }
                }
            }
            ProductNote(text: added.map { "Added \($0)" } ?? "Tap + for quick add. Products with sizes show a size strip.")
        }
    }

    private func binding(_ id: String) -> Binding<Bool> {
        Binding(get: { saved.contains(id) },
                set: { isOn in if isOn { saved.insert(id) } else { saved.remove(id) } })
    }
}

private struct ProductGridScreen: View {
    @State private var saved: Set<String> = []

    var body: some View {
        ScrollView {
            KitoProductGrid(ProductData.all + ProductData.looks.reversed(), wishlist: $saved, onQuickAdd: { _, _ in })
                .padding()
        }
    }
}

private struct ProductLookbookScreen: View {
    var body: some View {
        ScrollView {
            KitoProductGrid(ProductData.all, style: .editorial, layout: .staggered)
                .padding()
        }
    }
}

// MARK: - Artwork

private struct ProductArtworkSample: View {
    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(ProductData.artworks, id: \.cacheKey) { art in
                KitoProductMediaView(.artwork(art))
                    .aspectRatio(4 / 5, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            KitoProductArtworkView(ProductData.artworks[0].framed(.closeUp))
                .aspectRatio(4 / 5, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            KitoProductArtworkView(ProductData.artworks[1].framed(.angled))
                .aspectRatio(4 / 5, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            KitoProductArtworkView(ProductData.artworks[0].rotated(140))
                .aspectRatio(4 / 5, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - Gallery

enum ProductSamples {
    private static let pages = KitSection("Product pages", symbol: "bag", [
        KitSample("Sneaker page", "Gallery, 360°, swatches, sizes, size guide, delivery and a fly-to-bag add.", code: """
        KitoProductDetailView(
            product: runner, related: completeTheLook, sizeGuide: shoeGuide,
            delivery: KitoDeliveryEstimator(minDays: 1, maxDays: 3, cutoffHour: 14),
            onAddToBag: { product, variant in cart.add(product.cartItem(for: variant)) },
            onSelectRelated: { path.append($0) })
        """) { ModalStage { ProductSneakerPage() } },
        KitSample("Dress page", "Letter sizes, an inches switch in the size guide and a later cut-off.", code: """
        KitoProductDetailView(product: dress, related: [tote, sunglasses],
                              sizeGuide: apparelGuide,
                              delivery: KitoDeliveryEstimator(minDays: 2, maxDays: 4, cutoffHour: 12),
                              deliveryDetail: "Free returns within 30 days")
        """) { ModalStage { ProductDressPage() } },
        KitSample("No sizes, tinted", "A bag with two colours, three instalments and a brand tint.", code: """
        KitoProductDetailView(product: tote, related: looks, instalments: 3, tint: .brown)
        """) { ModalStage { ProductTotePage() } },
        KitSample("Sold out", "The bar says Sold out and can't be tapped.", code: """
        KitoProductDetailView(product: scent, delivery: nil)
        // restingState is .soldOut when no variant has stock
        """) { ModalStage { ProductSoldOutPage() } },
    ])

    private static let gallery = KitSection("Gallery", symbol: "photo.on.rectangle", [
        KitSample("Pager with dots", "Swipe, pinch to peek, tap to open the full-screen viewer.", code: """
        @State private var page = 0

        KitoProductGallery(product.media(for: colorID), selection: $page, cornerRadius: 20)
        """) { ProductPagerSample() },
        KitSample("Thumbnail strip", "A ring slides between thumbnails as you swipe.", code: """
        KitoProductGallery(product.media(for: "sand"), indicator: .thumbnails)
        """) { ProductThumbnailsSample() },
        KitSample("Counter, 3:4", "A “2 / 3” pill and rounded corners.", code: """
        KitoProductGallery(jacket.media, indicator: .counter, aspectRatio: 3 / 4, cornerRadius: 28)
        """) { ProductCounterSample() },
        KitSample("Hero viewer", "The photo grows out of the pager; double-tap zoom, drag down to close.", code: """
        ScrollView {
            KitoProductGallery(dress.media)
        }
        .kitoProductViewerHost()   // once, at the root of the screen
        """) { ModalStage { ProductHeroViewerScreen() } },
        KitSample("360° spin", "Drag to turn, fling to keep it spinning.", code: """
        KitoProductSpinViewer(frames: product.spinFrames)
        // or from artwork:
        KitoProductSpinViewer(frames: KitoProductArtwork.sneaker(primary: .black, accent: .orange).spin(frames: 24))
        """) { ProductSpinSample() },
    ])

    private static let variants = KitSection("Colours and sizes", symbol: "square.grid.3x2", [
        KitSample("Colour swatches", "A springy ring, two-tone swatches and a slash for sold out.", code: """
        @State private var colorID: String? = "black"

        KitoColorSwatches(product: runner, selection: $colorID)
        KitoColorSwatches(matrix.colorOptions(), selection: $colorID, size: 24)
        """) { ProductSwatchesSample() },
        KitSample("Size grid", "Low-stock dots, “Only 2 left”, and a shake for “Choose a size”.", code: """
        let matrix = KitoVariantMatrix(product)

        KitoSizePicker(matrix.sizeOptions(for: colorID), selection: $sizeID,
                       error: issue?.message, shakeTrigger: attempts,
                       onSizeGuide: { showGuide = true })

        if case .failure(let problem) = matrix.validate(selection) { issue = problem; attempts += 1 }
        """) { ProductSizeGridSample() },
        KitSample("Size chips", "Missing sizes struck through; sold-out sizes offer Notify me.", code: """
        KitoSizePicker(matrix.sizeOptions(for: "sand"), selection: $sizeID, style: .chips,
                       onNotifyMe: { size in alerts.subscribe(size.id) })
        """) { ProductSizeChipsSample() },
        KitSample("Size guide sheet", "Chart with cm/in, how to measure, and the fit bar.", code: """
        .sheet(isPresented: $showGuide) {
            KitoSizeGuideSheet(guide: apparelGuide, selection: $sizeID)
                .presentationDetents([.medium, .large])
        }
        """) { ModalStage { ProductSizeGuideScreen() } },
        KitSample("Fit feedback", "“Runs small” to “Runs large”, from reviews.", code: """
        KitoFitFeedbackBar(KitoFitFeedback(value: 0.35, reviewCount: 214))
        KitoFitFeedbackBar(KitoFitFeedback(votes: [-1, -1, 0, -1, 0]))   // "Runs slightly small"
        """) { ProductFitSample() },
    ])

    private static let buyBox = KitSection("Price, stock and delivery", symbol: "tag", [
        KitSample("Price tags", "Sale price, strike-through, discount and instalments.", code: """
        KitoPriceTag(price: 9_900, compareAt: 13_200, instalments: 4, size: .large)
        // KES 9,900  KES 13,200  −25%   or 4 × KES 2,475
        KitoPriceTag(product: product, size: .small)
        """) { ProductPricesSample() },
        KitSample("Stock levels", "In stock, selling fast, only 2 left, last one, sold out.", code: """
        KitoStockIndicator(stock: variant.stock)
        KitoStockIndicator(stock: 1, style: .bar)
        KitoStockLevel.level(for: 2, thresholds: KitoStockThresholds(low: 3, sellingFast: 10))   // .low(2)
        """) { ProductStockSample() },
        KitSample("Delivery estimate", "Skips weekends and holidays, with a cut-off countdown.", code: """
        KitoDeliveryEstimateRow(estimator: KitoDeliveryEstimator(minDays: 1, maxDays: 2, cutoffHour: 14),
                                detail: "Free delivery over KES 5,000")
        // "Get it Fri 25 – Mon 28 Sep" · "Order within 3 h 12 min"
        """) { ProductDeliverySample() },
        KitSample("Badges and rating", "New, Bestseller, Low stock, Eco, sale, and stars.", code: """
        KitoProductBadges([.new, .bestseller, .lowStock, .eco])
        KitoProductBadges([.sale(percent: 25), .exclusive, KitoProductBadge("Online only")])
        KitoProductRatingLine(rating: 4.6, reviewCount: 214) { showReviews = true }
        """) { ProductBadgesSample() },
        KitSample("Accordion", "Details, Materials & care, Shipping & returns.", code: """
        KitoProductAccordion(product.sections, initiallyExpanded: "Details")
        """) { ProductAccordionSample() },
        KitSample("Add-to-bag bar", "Morphs from Add to bag to a spinner to Added ✓.", code: """
        .safeAreaInset(edge: .bottom) {
            KitoAddToBagBar(price: "KES 9,900", state: state, isWishlisted: $saved) { add() }
        }
        // state: .idle → .adding → .added → .idle, or .soldOut
        """) { ProductBagBarSample() },
        KitSample("Wishlist heart", "Bounce and a burst of sparks when saved.", code: """
        KitoWishlistButton(isOn: $saved)
        KitoWishlistButton(isOn: $saved, style: .glass)      // over a photo
        KitoWishlistButton(isOn: $saved, style: .outlined)
        """) { ProductWishlistSample() },
    ])

    private static let cards = KitSection("Cards and grids", symbol: "rectangle.grid.2x2", [
        KitSample("Card styles", "Grid, editorial, horizontal and compact, with quick add.", code: """
        KitoProductCard(product, style: .grid, isWishlisted: $saved,   // .editorial, .compact, .horizontal
                        onQuickAdd: { product, variant in cart.add(product.cartItem(for: variant)) },
                        onSelect: { path.append(product) })
        """) { ProductCardStylesSample() },
        KitSample("Product grid", "Two columns; cards rise into place one after another.", code: """
        ScrollView {
            KitoProductGrid(products, wishlist: $saved,
                            onSelect: { path.append($0) },
                            onQuickAdd: { cart.add($0.cartItem(for: $1)) })
                .padding()
        }
        """) { ModalStage { ProductGridScreen() } },
        KitSample("Staggered lookbook", "Editorial cards with the right column dropped.", code: """
        KitoProductGrid(products, style: .editorial, layout: .staggered)
        """) { ModalStage { ProductLookbookScreen() } },
    ])

    private static let artwork = KitSection("Artwork", symbol: "paintpalette", [
        KitSample("Offline product photos", "Sneaker, tote, dress, jacket, sunglasses, bottle, drawn on the device.", code: """
        let art = KitoProductArtwork.sneaker(primary: .black, accent: .orange)
        KitoProductMediaView(.artwork(art))                 // cached bitmap
        KitoProductArtworkView(art.framed(.closeUp))        // .full, .angled
        art.renderedImage(size: CGSize(width: 400, height: 500))   // UIImage
        """) { ProductArtworkSample() },
    ])

    static let sections: [KitSection] = [pages, gallery, variants, buyBox, cards, artwork]
}

struct ProductGallery: View {
    static var count: Int { KitGallery.count(ProductSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Product",
            sections: ProductSamples.sections,
            footnote: "Requires `import KitoProduct`.",
            searchHint: "Try “gallery”, “360”, “size”, “price”, “delivery” or “card”."
        )
    }
}
