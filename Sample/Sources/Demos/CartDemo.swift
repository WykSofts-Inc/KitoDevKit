//
//  CartDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCart
import KitoHaptics

private struct DemoProduct: Identifiable {
    let id: String
    let name: String
    let price: Decimal
    let icon: String
}

struct CartDemo: View {
    @State private var cart = KitoCartViewModel()
    @State private var flight = KitoCartFlightCoordinator()

    private let products: [DemoProduct] = [
        DemoProduct(id: "burger", name: "Burger", price: 8.50, icon: "takeoutbag.and.cup.and.straw.fill"),
        DemoProduct(id: "fries", name: "Fries", price: 3.00, icon: "carrot.fill"),
        DemoProduct(id: "soda", name: "Soda", price: 2.25, icon: "cup.and.saucer.fill"),
        DemoProduct(id: "salad", name: "Salad", price: 6.75, icon: "leaf.fill"),
    ]

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
        }
        .navigationTitle("Cart")
        .kitoCartFlightHost(flight)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                KitoCartBadge(count: cart.totalQuantity)
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
