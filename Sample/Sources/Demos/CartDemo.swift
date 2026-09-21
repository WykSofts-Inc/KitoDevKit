//
//  CartDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCart
import KitoHaptics
import KitoEmptyStates

private struct DemoProduct: Identifiable {
    let id: String
    let name: String
    let price: Decimal
    let icon: String
}

private let products: [DemoProduct] = [
    DemoProduct(id: "burger", name: "Burger", price: 8.50, icon: "takeoutbag.and.cup.and.straw.fill"),
    DemoProduct(id: "fries", name: "Fries", price: 3.00, icon: "carrot.fill"),
    DemoProduct(id: "soda", name: "Soda", price: 2.25, icon: "cup.and.saucer.fill"),
    DemoProduct(id: "salad", name: "Salad", price: 6.75, icon: "leaf.fill"),
    DemoProduct(id: "pizza", name: "Pizza", price: 12.00, icon: "circle.grid.2x2.fill"),
    DemoProduct(id: "coffee", name: "Coffee", price: 4.50, icon: "cup.and.saucer"),
]

struct CartDemo: View {
    @State private var cart = KitoCartViewModel()
    @State private var flight = KitoCartFlightCoordinator()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                ForEach(products) { product in
                    VStack(spacing: 8) {
                        Image(systemName: product.icon).font(.system(size: 32))
                        Text(product.name).font(.headline)
                        Text(product.price, format: .currency(code: "USD"))
                            .font(.caption).foregroundStyle(.secondary)
                        Button("Add") {
                            flight.fly(from: product.id, symbol: "cart.fill") {
                                cart.add(KitoCartItem(id: product.id, name: product.name, unitPrice: product.price))
                                KitoHaptics.success()
                            }
                        }
                        .kitoCartFlightSource(id: product.id, in: flight)
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()

            NavigationLink("View cart (\(cart.totalQuantity) items) →") { CartDetailScreen(cart: cart) }
                .padding()
        }
        .navigationTitle("Cart")
        .kitoCartFlightHost(flight)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: CartDetailScreen(cart: cart)) {
                    KitoCartBadge(count: cart.totalQuantity)
                }
                .kitoCartAnchor(flight)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !cart.isEmpty {
                HStack {
                    Text("\(cart.totalQuantity) items").font(.subheadline)
                    Spacer()
                    Text(cart.subtotal, format: .currency(code: "USD")).font(.headline)
                }
                .padding()
                .background(.bar)
            }
        }
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
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
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
                            Text(item.lineTotal, format: .currency(code: "USD"))
                                .font(.subheadline.bold())
                                .frame(width: 70, alignment: .trailing)
                        }
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
            }
        }
        .navigationTitle("Cart")
    }
}
