//
//  CartDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoButtons
import KitoCart
import KitoHaptics
import KitoEmptyStates

private struct DemoProduct: Identifiable {
    let id: String
    let name: String
    let price: Decimal
    let icon: String
    let colors: [Color]
    let animation: KitoCartAnimation

    var gradient: KitoGradient { KitoGradient(colors: colors, shape: .linear(startPoint: .topLeading, endPoint: .bottomTrailing)) }
}

private let products: [DemoProduct] = [
    DemoProduct(id: "burger", name: "Burger", price: 8.50, icon: "takeoutbag.and.cup.and.straw.fill", colors: [Color(red: 1.0, green: 0.55, blue: 0.22), Color(red: 0.95, green: 0.25, blue: 0.18)], animation: .rollingCart),
    DemoProduct(id: "fries", name: "Fries", price: 3.00, icon: "carrot.fill", colors: [Color(red: 1.0, green: 0.78, blue: 0.18), Color(red: 1.0, green: 0.5, blue: 0.12)], animation: .bounceCart),
    DemoProduct(id: "soda", name: "Soda", price: 2.25, icon: "cup.and.saucer.fill", colors: [Color(red: 0.35, green: 0.55, blue: 1.0), Color(red: 0.55, green: 0.25, blue: 0.95)], animation: .dropIn),
    DemoProduct(id: "salad", name: "Salad", price: 6.75, icon: "leaf.fill", colors: [Color(red: 0.25, green: 0.8, blue: 0.5), Color(red: 0.1, green: 0.55, blue: 0.45)], animation: .fillSweep),
    DemoProduct(id: "pizza", name: "Pizza", price: 12.00, icon: "circle.grid.2x2.fill", colors: [Color(red: 1.0, green: 0.35, blue: 0.45), Color(red: 0.85, green: 0.15, blue: 0.55)], animation: .morphCircle),
    DemoProduct(id: "coffee", name: "Coffee", price: 4.50, icon: "cup.and.saucer", colors: [Color(red: 0.55, green: 0.38, blue: 0.28), Color(red: 0.3, green: 0.18, blue: 0.12)], animation: .burst),
]

/// The cart catalog, restyled around `KitoCartButton`'s choreographed add-to-cart
/// animations and `KitoFlightController`'s arc-to-badge motion — the same
/// components `KitoButtons` ships, not a bespoke look-alike.
struct CartDemo: View {
    @Environment(\.kitoTheme) private var theme
    @State private var cart = KitoCartViewModel()
    @StateObject private var flight = KitoFlightController(motion: .lively)
    @State private var showCart = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                ForEach(products) { product in
                    productCard(product)
                        .kitoFlightAnchor(product.id)
                }
            }
            .padding()

            Text("Each card uses a different KitoCartButton choreography — rolling cart, bounce, drop-in, fill sweep, morph-to-circle, burst.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 12)
        }
        .background(
            LinearGradient(colors: [theme.colors.background, theme.colors.primary.opacity(0.08)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationTitle("Cart")
        .kitoFlightLayer(flight)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                KitoBadgeButton(systemImage: "cart", count: cart.totalQuantity) { showCart = true }
                    .badgeColor(.red)
                    .bounces(on: flight.landings(on: "cart"))
                    .kitoFlightAnchor("cart")
            }
        }
        .navigationDestination(isPresented: $showCart) { CartDetailScreen(cart: cart) }
        .safeAreaInset(edge: .bottom) {
            if !cart.isEmpty {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(cart.totalQuantity) items").font(.caption).foregroundStyle(.secondary)
                        Text(cart.subtotal, format: .currency(code: "USD")).font(.title3.bold())
                    }
                    Spacer()
                    Button("Checkout") { showCart = true }
                        .buttonStyle(.kito(.primary, size: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .overlay(alignment: .top) { Divider() }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: cart.isEmpty)
    }

    private func productCard(_ product: DemoProduct) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .background(product.gradient.asView())
                    .clipShape(Circle())
                    .frame(width: 56, height: 56)
                Image(systemName: product.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .kitoGlow(product.colors[1], radius: 14, intensity: 0.45)

            VStack(spacing: 2) {
                Text(product.name).font(.headline)
                Text(product.price, format: .currency(code: "USD"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            KitoCartButton(animation: product.animation) {
                cart.add(KitoCartItem(id: product.id, name: product.name, unitPrice: product.price))
                KitoHaptics.success()
            }
            .size(.small)
            .fullWidth()
            .flies(to: "cart", with: flight, size: CGSize(width: 30, height: 30)) {
                Circle().fill(Color.clear)
                    .background(product.gradient.asView())
                    .clipShape(Circle())
                    .overlay(Image(systemName: product.icon).font(.system(size: 13, weight: .bold)).foregroundStyle(.white))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .kitoGlassCard(cornerRadius: 22)
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }
}

private struct CartDetailScreen: View {
    @Bindable var cart: KitoCartViewModel

    var body: some View {
        Group {
            if cart.isEmpty {
                KitoEmptyStateView(systemImage: "cart", title: "Your cart is empty", message: "Add something from the grid.")
            } else {
                List {
                    ForEach(cart.items) { item in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name).font(.subheadline.weight(.semibold))
                                Text(item.unitPrice, format: .currency(code: "USD"))
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Stepper(
                                "\(item.quantity)",
                                value: Binding(
                                    get: { item.quantity },
                                    set: { cart.setQuantity(id: item.id, quantity: $0) }
                                ),
                                in: 0...20
                            )
                            .fixedSize()
                            .kitoButtonBounce(trigger: item.quantity)
                            Text(item.lineTotal, format: .currency(code: "USD"))
                                .font(.subheadline.bold())
                                .frame(width: 70, alignment: .trailing)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        for index in indexSet { cart.remove(id: cart.items[index].id) }
                    }

                    Section {
                        HStack {
                            Text("Subtotal").font(.headline)
                            Spacer()
                            Text(cart.subtotal, format: .currency(code: "USD")).font(.headline)
                        }
                        Button("Clear cart", role: .destructive) { cart.clear() }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Button("Proceed to checkout") {}
                        .buttonStyle(.kito(.primary, fullWidth: true))
                        .padding()
                        .background(.ultraThinMaterial)
                }
            }
        }
        .navigationTitle("Cart")
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: cart.items.map(\.id))
    }
}
