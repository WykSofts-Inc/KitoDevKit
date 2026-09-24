//
//  CartSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoButtons
import KitoHaptics

// MARK: - Menu data

private struct CartDish: Identifiable {
    let id: String
    let name: String
    let detail: String
    let price: Decimal
    let symbol: String
    let colors: [Color]

    var item: KitoCartItem { KitoCartItem(id: id, name: name, unitPrice: price, subtitle: detail) }
}

private enum CartMenu {
    static let dishes: [CartDish] = [
        CartDish(id: "pilau", name: "Beef pilau", detail: "Kachumbari on the side", price: 650, symbol: "fork.knife", colors: [Color(red: 0.95, green: 0.6, blue: 0.25), Color(red: 0.8, green: 0.32, blue: 0.18)]),
        CartDish(id: "chapati", name: "Chapati", detail: "Soft, layered · 2 pcs", price: 60, symbol: "circle.hexagongrid.fill", colors: [Color(red: 0.98, green: 0.8, blue: 0.4), Color(red: 0.9, green: 0.55, blue: 0.2)]),
        CartDish(id: "choma", name: "Nyama choma", detail: "Goat, ½ kg", price: 900, symbol: "flame.fill", colors: [Color(red: 0.95, green: 0.35, blue: 0.3), Color(red: 0.6, green: 0.12, blue: 0.2)]),
        CartDish(id: "tilapia", name: "Tilapia fry", detail: "With ugali and sukuma", price: 850, symbol: "fish.fill", colors: [Color(red: 0.35, green: 0.65, blue: 0.95), Color(red: 0.15, green: 0.35, blue: 0.7)]),
        CartDish(id: "mandazi", name: "Mandazi", detail: "Coconut · 4 pcs", price: 120, symbol: "triangle.fill", colors: [Color(red: 0.9, green: 0.7, blue: 0.45), Color(red: 0.7, green: 0.45, blue: 0.25)]),
        CartDish(id: "chai", name: "Chai masala", detail: "Large · ginger", price: 150, symbol: "cup.and.saucer.fill", colors: [Color(red: 0.7, green: 0.5, blue: 0.35), Color(red: 0.4, green: 0.25, blue: 0.15)]),
        CartDish(id: "juice", name: "Mango juice", detail: "Fresh · 500 ml", price: 250, symbol: "waterbottle.fill", colors: [Color(red: 1.0, green: 0.75, blue: 0.2), Color(red: 0.95, green: 0.45, blue: 0.15)]),
        CartDish(id: "samosa", name: "Beef samosa", detail: "Crispy · 3 pcs", price: 180, symbol: "triangle.lefthalf.filled", colors: [Color(red: 0.85, green: 0.55, blue: 0.3), Color(red: 0.55, green: 0.3, blue: 0.15)]),
    ]

    static func dish(_ id: String) -> CartDish { dishes.first { $0.id == id } ?? dishes[0] }

    static func filledCart() -> KitoCartViewModel {
        KitoCartViewModel(items: [
            KitoCartItem(id: "pilau", name: "Beef pilau", unitPrice: 650, quantity: 1, subtitle: "Kachumbari on the side"),
            KitoCartItem(id: "chapati", name: "Chapati", unitPrice: 60, quantity: 3, subtitle: "Soft, layered · 2 pcs"),
            KitoCartItem(id: "chai", name: "Chai masala", unitPrice: 150, quantity: 2, subtitle: "Large · ginger"),
        ])
    }

    static let rules = KitoCartPricingRules(deliveryFee: 150, freeDeliveryThreshold: 2_000)

    static let validator = KitoPromoValidator(codes: [
        KitoPromoCode(code: "KARIBU10", kind: .percent(10, cap: 300), title: "10% off, up to KES 300"),
        KitoPromoCode(code: "FREESHIP", kind: .freeDelivery),
        KitoPromoCode(code: "SAVE200", kind: .fixed(200), minimumSubtotal: 1_500, title: "KES 200 off orders over KES 1,500"),
        KitoPromoCode(code: "MAMBO", kind: .percent(20), expiresAt: Date(timeIntervalSince1970: 1_700_000_000)),
    ])
}

private struct CartThumb: View {
    let dish: CartDish
    var size: CGFloat? = nil

    var body: some View {
        ZStack {
            LinearGradient(colors: dish.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: dish.symbol)
                .font(.system(size: (size ?? 64) * 0.38, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
        .frame(width: size, height: size)
    }
}

private struct CartHint: View {
    let text: String
    var body: some View {
        Text(text).font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Cart pages

private struct CartPageSample: View {
    @State private var cart = CartMenu.filledCart()
    @State private var paid: Decimal?

    var body: some View {
        NavigationStack {
            KitoCartView(cart: cart, rules: CartMenu.rules, promoValidator: CartMenu.validator, checkoutTitle: "Pay with M-Pesa", onCheckout: { pricing in
                paid = pricing.total
            }, onBrowse: {
                for dish in CartMenu.dishes.prefix(3) { cart.add(dish.item) }
            }) { item in
                CartThumb(dish: CartMenu.dish(item.id))
            }
            .navigationTitle("Your cart")
            .navigationBarTitleDisplayMode(.inline)
            .alert("STK push sent", isPresented: Binding(get: { paid != nil }, set: { if !$0 { paid = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Check your phone to pay \(KitoCartMoney.string(paid ?? 0)) to Mama Akinyi's Kitchen.")
            }
        }
    }
}

private struct CartSheetSample: View {
    @State private var cart = CartMenu.filledCart()
    @State private var showsCart = false

    var body: some View {
        MockAppScreen(title: "Menu", tint: .orange) {
            KitoMiniCartBar(count: cart.totalQuantity, total: cart.subtotal, tint: .primary, tintForeground: Color(.systemBackground)) { showsCart = true }
        }
        .sheet(isPresented: $showsCart) {
            NavigationStack {
                KitoCartView(cart: cart, rules: CartMenu.rules, promoValidator: CartMenu.validator, onCheckout: { _ in showsCart = false }) { item in
                    CartThumb(dish: CartMenu.dish(item.id))
                }
                .navigationTitle("Cart")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

private struct CartEmptySample: View {
    @State private var tapped = 0

    var body: some View {
        VStack(spacing: 8) {
            KitoEmptyCartView(title: "Hakuna kitu hapa", message: "Your cart is empty. Find something tasty from Mama Akinyi's Kitchen.", actionTitle: "Browse the menu") { tapped += 1 }
            if tapped > 0 { Text("Opening the menu…").font(.caption).foregroundStyle(.secondary).transition(.opacity) }
        }
        .animation(.easeOut, value: tapped)
    }
}

private struct CartCheckoutSummarySample: View {
    @State private var promo: KitoPromoCode?
    private let subtotal: Decimal = 1_620

    var body: some View {
        let pricing = CartMenu.rules.pricing(subtotal: subtotal, promo: promo)
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill").font(.title2).foregroundStyle(.red)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Deliver to Home").font(.subheadline.weight(.bold))
                    Text("Argwings Kodhek Rd, Kilimani").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text("25–35 min").font(.caption.weight(.bold)).padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.primary.opacity(0.07), in: Capsule())
            }
            KitoPromoCodeField(applied: $promo, validator: CartMenu.validator, subtotal: subtotal)
            KitoPriceBreakdown(pricing: pricing)
                .padding(18)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            Button {} label: {
                HStack {
                    Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                    Text("Pay \(KitoCartMoney.string(pricing.total)) with M-Pesa")
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .animation(.snappy, value: pricing.total)
            CartHint(text: "Try KARIBU10, FREESHIP or SAVE200.")
        }
    }
}

// MARK: - Quantity

private struct CartStepperStylesSample: View {
    @State private var values: [Int] = [2, 0, 1, 3]

    var body: some View {
        VStack(spacing: 18) {
            ForEach(Array(KitoQuantityStepperStyle.allCases.enumerated()), id: \.offset) { index, style in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(style.label).font(.subheadline.weight(.semibold))
                        Text("Quantity \(values[index])").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    KitoQuantityStepper(value: $values[index], range: 0...10, style: style)
                }
                .padding(14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }
}

private struct CartMenuGridSample: View {
    @State private var cart = KitoCartViewModel()

    var body: some View {
        VStack(spacing: 14) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(CartMenu.dishes.prefix(4)) { dish in
                    VStack(alignment: .leading, spacing: 10) {
                        CartThumb(dish: dish)
                            .frame(height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(alignment: .bottomTrailing) {
                                KitoQuantityStepper(
                                    value: quantity(of: dish),
                                    range: 0...20,
                                    style: .expanding,
                                    tint: .primary,
                                    tintForeground: Color(.systemBackground)
                                )
                                .padding(8)
                            }
                        Text(dish.name).font(.subheadline.weight(.bold))
                        Text(KitoCartMoney.string(dish.price)).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    }
                }
            }
            HStack {
                Text("\(cart.totalQuantity) items").font(.subheadline.weight(.semibold))
                    .contentTransition(.numericText())
                Spacer()
                Text(KitoCartMoney.string(cart.subtotal)).font(.headline.monospacedDigit()).contentTransition(.numericText())
            }
            .animation(.snappy, value: cart.totalQuantity)
        }
    }

    private func quantity(of dish: CartDish) -> Binding<Int> {
        Binding {
            cart.quantity(of: dish.id)
        } set: { newValue in
            if cart.quantity(of: dish.id) == 0 {
                if newValue > 0 { cart.add(KitoCartItem(id: dish.id, name: dish.name, unitPrice: dish.price, quantity: newValue)) }
            } else {
                cart.setQuantity(id: dish.id, quantity: newValue)
            }
        }
    }
}

private struct CartTrashAtOneSample: View {
    @State private var quantity = 2
    @State private var removed = false

    var body: some View {
        VStack(spacing: 14) {
            if removed {
                Button { withAnimation(.spring) { removed = false; quantity = 1 } } label: { Label("Put it back", systemImage: "arrow.uturn.backward") }
                    .buttonStyle(GalleryPrimaryButtonStyle())
                    .transition(.scale.combined(with: .opacity))
            } else {
                KitoCartItemRow(item: KitoCartItem(id: "choma", name: "Nyama choma", unitPrice: 900, quantity: quantity, subtitle: "Goat, ½ kg"), quantity: $quantity, onRemove: {
                    withAnimation(.spring) { removed = true }
                }) { _ in CartThumb(dish: CartMenu.dish("choma")) }
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            CartHint(text: "Step down to one and minus turns into a red trash button.")
        }
    }
}

private struct CartGroceryTilesSample: View {
    @State private var counts: [String: Int] = ["juice": 2, "mandazi": 0, "samosa": 1]
    private let ids = ["juice", "mandazi", "samosa"]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(ids, id: \.self) { id in
                let dish = CartMenu.dish(id)
                VStack(spacing: 10) {
                    CartThumb(dish: dish, size: 64).clipShape(Circle())
                    Text(dish.name).font(.caption.weight(.bold)).lineLimit(1)
                    Text(KitoCartMoney.string(dish.price)).font(.caption2).foregroundStyle(.secondary)
                    KitoQuantityStepper(value: Binding(get: { counts[id] ?? 0 }, set: { counts[id] = $0 }), range: 0...9, style: .vertical)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        }
    }
}

// MARK: - Removing

private struct CartSwipeSample: View {
    @State private var cart = KitoCartViewModel(items: CartMenu.dishes.prefix(4).map(\.item))

    var body: some View {
        VStack(spacing: 10) {
            ForEach(cart.items) { item in
                KitoCartItemRow(
                    item: item,
                    quantity: Binding(get: { cart.quantity(of: item.id) }, set: { cart.setQuantity(id: item.id, quantity: $0) }),
                    onRemove: { withAnimation(.spring) { cart.remove(id: item.id) } }
                ) { item in CartThumb(dish: CartMenu.dish(item.id)) }
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .kitoSwipeToDelete(cornerRadius: 22) { withAnimation(.spring) { cart.remove(id: item.id) } }
                .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .opacity))
            }
            if cart.isEmpty {
                Button("Refill") { withAnimation(.spring) { CartMenu.dishes.prefix(4).forEach { cart.add($0.item) } } }
                    .buttonStyle(GalleryPrimaryButtonStyle())
            }
            CartHint(text: "Swipe a row left. Past halfway it deletes; release early to reveal the button.")
        }
        .frame(minHeight: 420, alignment: .top)
        .kitoCartUndoBar(cart)
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: cart.items.map(\.id))
    }
}

private struct CartUndoBarSample: View {
    @State private var message: String? = "Removed Beef pilau"
    @State private var undone = 0

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [Color.orange.opacity(0.25), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom))
                    .frame(height: 200)
                if let message {
                    KitoUndoBar(message, duration: 4) {
                        undone += 1
                        withAnimation(.spring) { self.message = nil }
                    } onTimeout: {
                        withAnimation(.spring) { self.message = nil }
                    }
                    .padding(14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            HStack {
                Text(undone > 0 ? "Undone \(undone)×" : "Waits four seconds").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Show again") { withAnimation(.spring) { message = "Removed \(CartMenu.dishes.randomElement()!.name)" } }
                    .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
    }
}

// MARK: - Pricing

private struct CartBreakdownSample: View {
    @State private var cart = CartMenu.filledCart()

    var body: some View {
        VStack(spacing: 14) {
            KitoPriceBreakdown(pricing: CartMenu.rules.pricing(subtotal: cart.subtotal))
                .padding(18)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            HStack(spacing: 8) {
                ForEach(["choma", "juice", "mandazi"], id: \.self) { id in
                    let dish = CartMenu.dish(id)
                    Button { withAnimation(.snappy) { cart.add(dish.item) } } label: {
                        Label(dish.name.components(separatedBy: " ").last ?? dish.name, systemImage: "plus").font(.caption.weight(.bold))
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }
                Button { withAnimation(.snappy) { cart.clear(); CartMenu.filledCart().items.forEach { cart.add($0) } } } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered).tint(.primary)
                .accessibilityLabel("Reset")
            }
            CartHint(text: "Add dishes: every amount rolls, and delivery turns free past KES 2,000.")
        }
    }
}

private struct CartPromoSample: View {
    @State private var promo: KitoPromoCode?
    private let subtotal: Decimal = 1_240

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KitoPromoCodeField(applied: $promo, validator: CartMenu.validator, subtotal: subtotal)
            KitoPriceBreakdown(pricing: CartMenu.rules.pricing(subtotal: subtotal, promo: promo))
                .padding(18)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            VStack(alignment: .leading, spacing: 8) {
                Text("Codes to try").font(.caption.weight(.heavy)).foregroundStyle(.secondary)
                ForEach([("KARIBU10", "10% off, capped"), ("FREESHIP", "free delivery"), ("SAVE200", "needs KES 1,500"), ("MAMBO", "expired"), ("HABARI", "doesn't exist")], id: \.0) { code in
                    HStack {
                        Text(code.0).font(.caption.weight(.bold).monospaced())
                        Text(code.1).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

private struct CartFreeDeliverySample: View {
    @State private var subtotal: Decimal = 1_150

    var body: some View {
        let pricing = CartMenu.rules.pricing(subtotal: subtotal)
        VStack(spacing: 16) {
            KitoFreeDeliveryProgress(pricing: pricing)
                .padding(18)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            HStack(spacing: 10) {
                Button { withAnimation { subtotal = max(0, subtotal - 250) } } label: { Label("Chai", systemImage: "minus") }
                    .buttonStyle(.bordered).tint(.primary)
                Button { withAnimation { subtotal += 250 } } label: { Label("Mango juice", systemImage: "plus") }
                    .buttonStyle(GalleryPrimaryButtonStyle())
            }
            Text("Subtotal \(KitoCartMoney.string(subtotal))").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
    }
}

private struct CartTaxSample: View {
    private let rules = KitoCartPricingRules(deliveryFee: 200, freeDeliveryThreshold: nil, serviceFeeRate: 0.025, taxRate: 0.16)

    var body: some View {
        VStack(spacing: 14) {
            KitoPriceBreakdown(pricing: rules.pricing(subtotal: 4_300, promo: KitoPromoCode(code: "WYK500", kind: .fixed(500))), totalLabel: "Total incl. VAT")
                .padding(18)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            CartHint(text: "Service fee 2.5% of the subtotal, VAT 16% on the discounted subtotal, rounded to cents.")
        }
    }
}

// MARK: - Feedback

private struct CartMiniBarSample: View {
    @State private var cart = KitoCartViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 10) {
                ForEach(CartMenu.dishes.prefix(4)) { dish in
                    HStack(spacing: 12) {
                        CartThumb(dish: dish, size: 52).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dish.name).font(.subheadline.weight(.bold))
                            Text(KitoCartMoney.string(dish.price)).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { cart.add(dish.item) } } label: {
                            Image(systemName: "plus").font(.subheadline.weight(.bold)).frame(width: 36, height: 36)
                                .foregroundStyle(Color(.systemBackground)).background(Color.primary, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Add \(dish.name)")
                    }
                }
                Spacer(minLength: 80)
            }
            if !cart.isEmpty {
                KitoMiniCartBar(count: cart.totalQuantity, total: cart.subtotal, tint: .primary, tintForeground: Color(.systemBackground)) { cart.clear() }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(minHeight: 380)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: cart.isEmpty)
    }
}

private struct CartToastSample: View {
    @State private var style: KitoAddedToCartStyle = .pill
    @State private var justAdded: KitoCartItem?
    @State private var count = 0

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                LinearGradient(colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.15), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                VStack(spacing: 12) {
                    CartThumb(dish: CartMenu.dish("tilapia"), size: 96).clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    Text("Tilapia fry").font(.title3.weight(.bold))
                    Button {
                        count += 1
                        justAdded = KitoCartItem(id: "tilapia-\(count)", name: "Tilapia fry", unitPrice: 850, subtitle: "With ugali and sukuma")
                    } label: { Label("Add to cart", systemImage: "bag.badge.plus") }
                        .buttonStyle(GalleryPrimaryButtonStyle())
                }
            }
            .frame(height: 380)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .kitoAddedToCartToast(item: $justAdded, style: style) { justAdded = nil }
            Picker("Style", selection: $style) {
                ForEach(KitoAddedToCartStyle.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct CartBadgeSample: View {
    @State private var count = 2

    var body: some View {
        VStack(spacing: 22) {
            HStack(spacing: 34) {
                KitoCartBadge(count: count)
                KitoCartBadge(count: count, systemImage: "bag.fill")
                KitoCartBadge(count: count * 37, systemImage: "basket.fill")
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            HStack(spacing: 10) {
                Button("Remove") { count = max(0, count - 1) }.buttonStyle(.bordered).tint(.primary)
                Button("Add one") { count += 1 }.buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
    }
}

private struct CartFlightSample: View {
    @State private var cart = KitoCartViewModel()
    @State private var flight = KitoCartFlightCoordinator()
    private let pairs: [(KitoCartFlightStyle, String)] = [(.arc, "pilau"), (.lob, "juice"), (.dart, "chai"), (.spin, "samosa")]

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Duka la Mama").font(.headline)
                    Text("Tap a style to send it flying").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                KitoCartBadge(count: cart.totalQuantity, systemImage: "bag.fill")
                    .padding(10)
                    .kitoCartAnchor(flight)
            }
            ForEach(pairs, id: \.0) { pair in
                let dish = CartMenu.dish(pair.1)
                HStack(spacing: 12) {
                    CartThumb(dish: dish, size: 48).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dish.name).font(.subheadline.weight(.bold))
                        Text(".\(pair.0.rawValue)").font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(pair.0.label) {
                        flight.fly(from: pair.0.rawValue, symbol: dish.symbol, color: dish.colors[1], style: pair.0) {
                            cart.add(dish.item)
                            KitoHaptics.success()
                        }
                    }
                    .font(.subheadline.weight(.bold))
                    .buttonStyle(GalleryPrimaryButtonStyle())
                    .kitoCartFlightSource(id: pair.0.rawValue, in: flight)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .kitoCartFlightHost(flight)
    }
}

// MARK: - KitoButtons choreography (the original catalogue)

private struct CartChoreoProduct: Identifiable {
    let id: String
    let name: String
    let price: Decimal
    let icon: String
    let colors: [Color]
    let animation: KitoCartAnimation

    var gradient: KitoGradient { KitoGradient(colors: colors, shape: .linear(startPoint: .topLeading, endPoint: .bottomTrailing)) }
}

private struct CartChoreographySample: View {
    @State private var cart = KitoCartViewModel()
    @StateObject private var flight = KitoFlightController(motion: .lively)

    private let products: [CartChoreoProduct] = [
        CartChoreoProduct(id: "pilau", name: "Pilau", price: 650, icon: "fork.knife", colors: [Color(red: 1.0, green: 0.55, blue: 0.22), Color(red: 0.95, green: 0.25, blue: 0.18)], animation: .rollingCart),
        CartChoreoProduct(id: "chapati", name: "Chapati", price: 60, icon: "circle.hexagongrid.fill", colors: [Color(red: 1.0, green: 0.78, blue: 0.18), Color(red: 1.0, green: 0.5, blue: 0.12)], animation: .bounceCart),
        CartChoreoProduct(id: "juice", name: "Juice", price: 250, icon: "waterbottle.fill", colors: [Color(red: 0.35, green: 0.55, blue: 1.0), Color(red: 0.55, green: 0.25, blue: 0.95)], animation: .dropIn),
        CartChoreoProduct(id: "sukuma", name: "Sukuma", price: 80, icon: "leaf.fill", colors: [Color(red: 0.25, green: 0.8, blue: 0.5), Color(red: 0.1, green: 0.55, blue: 0.45)], animation: .fillSweep),
        CartChoreoProduct(id: "choma", name: "Choma", price: 900, icon: "flame.fill", colors: [Color(red: 1.0, green: 0.35, blue: 0.45), Color(red: 0.85, green: 0.15, blue: 0.55)], animation: .morphCircle),
        CartChoreoProduct(id: "chai", name: "Chai", price: 150, icon: "cup.and.saucer.fill", colors: [Color(red: 0.55, green: 0.38, blue: 0.28), Color(red: 0.3, green: 0.18, blue: 0.12)], animation: .burst),
    ]

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Six choreographies").font(.headline)
                Spacer()
                KitoBadgeButton(systemImage: "cart", count: cart.totalQuantity) {}
                    .badgeColor(.red)
                    .bounces(on: flight.landings(on: "cart"))
                    .kitoFlightAnchor("cart")
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(products) { product in
                    card(product).kitoFlightAnchor(product.id)
                }
            }
        }
        .kitoFlightLayer(flight)
    }

    private func card(_ product: CartChoreoProduct) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(Color.clear).background(product.gradient.asView()).clipShape(Circle()).frame(width: 52, height: 52)
                Image(systemName: product.icon).font(.system(size: 22, weight: .semibold)).foregroundStyle(.white)
            }
            .kitoGlow(product.colors[1], radius: 14, intensity: 0.45)
            VStack(spacing: 2) {
                Text(product.name).font(.headline)
                Text(KitoCartMoney.string(product.price)).font(.caption).foregroundStyle(.secondary)
            }
            KitoCartButton(animation: product.animation) {
                cart.add(KitoCartItem(id: product.id, name: product.name, unitPrice: product.price))
                KitoHaptics.success()
            }
            .size(.small)
            .fullWidth()
            .flies(to: "cart", with: flight, size: CGSize(width: 30, height: 30)) {
                Circle().fill(Color.clear).background(product.gradient.asView()).clipShape(Circle())
                    .overlay(Image(systemName: product.icon).font(.system(size: 13, weight: .bold)).foregroundStyle(.white))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .kitoGlassCard(cornerRadius: 22)
    }
}

// MARK: - Catalog

enum CartSamples {
    static let sections: [KitSection] = [pages, quantity, removing, pricing, feedback]

    static let pages = KitSection("Cart pages", symbol: "cart.fill", [
        KitSample("Full cart page", "Free-delivery progress, swipeable lines, promo code, breakdown and checkout in one view.", code: """
        KitoCartView(
            cart: cart,
            rules: KitoCartPricingRules(deliveryFee: 150, freeDeliveryThreshold: 2_000),
            promoValidator: validator,
            checkoutTitle: "Pay with M-Pesa",
            onCheckout: { pricing in startSTKPush(pricing.total) }
        ) { item in
            DishThumbnail(item)
        }
        """) { ModalStage { CartPageSample() } },
        KitSample("Cart in a sheet", "A floating mini cart opens the full cart as a half-height sheet.", code: """
        KitoMiniCartBar(count: cart.totalQuantity, total: cart.subtotal) { showsCart = true }
            .sheet(isPresented: $showsCart) {
                KitoCartView(cart: cart, rules: rules, onCheckout: checkout) { DishThumbnail($0) }
                    .presentationDetents([.medium, .large])
            }
        """) { ModalStage { CartSheetSample() } },
        KitSample("Empty cart", "A floating cart with drifting items and a way back to the menu.", code: """
        KitoEmptyCartView(title: "Hakuna kitu hapa", message: "Your cart is empty.", actionTitle: "Browse the menu") {
            showMenu = true
        }
        """) { CartEmptySample() },
        KitSample("Checkout summary", "Address, promo code, breakdown and an M-Pesa button whose total rolls.", code: """
        KitoPromoCodeField(applied: $promo, validator: validator, subtotal: subtotal)
        KitoPriceBreakdown(pricing: rules.pricing(subtotal: subtotal, promo: promo))
        """) { CartCheckoutSummarySample() },
    ])

    static let quantity = KitSection("Quantity", symbol: "plusminus", [
        KitSample("Stepper styles", "Capsule, expanding, circles and vertical, each with a rolling number.", code: """
        KitoQuantityStepper(value: $quantity, style: .capsule)   // .expanding, .circles, .vertical
        """) { CartStepperStylesSample() },
        KitSample("Add button that grows", "A + on each dish that expands into − 1 + on tap.", code: """
        KitoQuantityStepper(value: $quantity, range: 0...20, style: .expanding,
                            tint: .primary, tintForeground: Color(.systemBackground))
        """) { CartMenuGridSample() },
        KitSample("Trash at one", "At quantity one, minus becomes a red trash button.", code: """
        KitoCartItemRow(item: item, quantity: $quantity, onRemove: { cart.remove(id: item.id) }) { item in
            DishThumbnail(item)
        }
        """) { CartTrashAtOneSample() },
        KitSample("Grocery tiles", "Tall vertical steppers under round thumbnails.", code: "KitoQuantityStepper(value: $count, range: 0...9, style: .vertical)") { CartGroceryTilesSample() },
    ])

    static let removing = KitSection("Removing", symbol: "trash", [
        KitSample("Swipe to delete, with undo", "Swipe a line away, then bring it back from the undo bar.", code: """
        ForEach(cart.items) { item in
            KitoCartItemRow(item: item, quantity: binding(for: item), onRemove: { cart.remove(id: item.id) }) { … }
                .kitoSwipeToDelete { cart.remove(id: item.id) }
        }
        .kitoCartUndoBar(cart)   // "Removed Beef pilau · Undo", puts it back in place
        """) { CartSwipeSample() },
        KitSample("Undo bar", "A dark snackbar whose ring empties as it times out.", code: """
        KitoUndoBar("Removed Beef pilau", duration: 4) {
            cart.undoRemoval()
        } onTimeout: {
            cart.clearRecentlyRemoved()
        }
        """) { CartUndoBarSample() },
    ])

    static let pricing = KitSection("Pricing", symbol: "tag", [
        KitSample("Animated price breakdown", "Subtotal, delivery and total roll as dishes are added.", code: """
        let rules = KitoCartPricingRules(deliveryFee: 150, freeDeliveryThreshold: 2_000)
        KitoPriceBreakdown(pricing: rules.pricing(subtotal: cart.subtotal))
        """) { CartBreakdownSample() },
        KitSample("Promo codes", "Checks the code, shakes when it's wrong, turns into a ticket when it applies.", code: """
        let validator = KitoPromoValidator(codes: [
            KitoPromoCode(code: "KARIBU10", kind: .percent(10, cap: 300)),
            KitoPromoCode(code: "FREESHIP", kind: .freeDelivery),
            KitoPromoCode(code: "SAVE200", kind: .fixed(200), minimumSubtotal: 1_500),
        ])
        KitoPromoCodeField(applied: $promo, validator: validator, subtotal: cart.subtotal)
        """) { CartPromoSample() },
        KitSample("Free delivery progress", "A scooter rides the bar towards free delivery.", code: """
        KitoFreeDeliveryProgress(pricing: rules.pricing(subtotal: cart.subtotal))
        // "Add KES 350 more for free delivery" → "You've unlocked free delivery"
        """) { CartFreeDeliverySample() },
        KitSample("Fees and VAT", "Service fee and 16% VAT on the discounted subtotal.", code: """
        let rules = KitoCartPricingRules(deliveryFee: 200, serviceFeeRate: 0.025, taxRate: 0.16)
        KitoPriceBreakdown(pricing: rules.pricing(subtotal: 4_300, promo: code), totalLabel: "Total incl. VAT")
        """) { CartTaxSample() },
    ])

    static let feedback = KitSection("Feedback & motion", symbol: "sparkles", [
        KitSample("Mini cart bar", "Appears with the first item and bounces with every one after.", code: """
        if !cart.isEmpty {
            KitoMiniCartBar(count: cart.totalQuantity, total: cart.subtotal) { showsCart = true }
        }
        """) { CartMiniBarSample() },
        KitSample("Added to cart", "Pill from the top, banner from the bottom, or a card in the middle.", code: """
        @State private var justAdded: KitoCartItem?

        content
            .kitoAddedToCartToast(item: $justAdded, style: .banner) { showsCart = true }   // .pill, .card
        """) { CartToastSample() },
        KitSample("Badge bounce", "The count badge bumps whenever it changes, capping at 99+.", code: "KitoCartBadge(count: cart.totalQuantity, systemImage: \"bag.fill\")") { CartBadgeSample() },
        KitSample("Fly to cart: four paths", "Arc, lob, dart and spin, each landing on the badge.", code: """
        cartFlight.fly(from: dish.id, symbol: dish.symbol, style: .lob) {   // .arc, .dart, .spin
            cart.add(dish.item)
        }
        …
        Button("Add") { … }.kitoCartFlightSource(id: dish.id, in: cartFlight)
        KitoCartBadge(count: cart.totalQuantity).kitoCartAnchor(cartFlight)
        screen.kitoCartFlightHost(cartFlight)
        """) { CartFlightSample() },
        KitSample("Add-to-cart buttons", "Six KitoButtons choreographies arcing to a bouncing badge.", code: """
        KitoCartButton(animation: .rollingCart) { cart.add(item) }   // .bounceCart, .dropIn, .fillSweep, .morphCircle, .burst
            .flies(to: "cart", with: flight, size: CGSize(width: 30, height: 30)) { DishDot() }
        """) { CartChoreographySample() },
    ])
}

/// Every cart sample.
struct CartDemo: View {
    static var count: Int { KitGallery.count(CartSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Cart",
            sections: CartSamples.sections,
            footnote: "Requires `import KitoCart`. The add-to-cart buttons also use `import KitoButtons`.",
            searchHint: "Try “promo”, “stepper”, “undo” or “fly”."
        )
    }
}
