//
//  FoodDishSheet.swift
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

extension FoodShowcase {

    /// Sizes, extras and a note for the kitchen, then "Add 2 to basket · KES 1,300".
    struct FoodDishSheet: View {
        let dish: FoodDish
        let restaurant: FoodRestaurant
        let onAdd: (_ size: FoodChoice?, _ extras: [FoodChoice], _ note: String, _ quantity: Int) -> Void
        @Environment(\.dismiss) private var dismiss
        @Environment(\.kitoTheme) private var theme
        @State private var size: FoodChoice?
        @State private var extras: Set<String> = []
        @State private var note = ""
        @State private var quantity = 1
        @FocusState private var noteFocused: Bool

        init(dish: FoodDish, restaurant: FoodRestaurant,
             onAdd: @escaping (_ size: FoodChoice?, _ extras: [FoodChoice], _ note: String, _ quantity: Int) -> Void) {
            self.dish = dish
            self.restaurant = restaurant
            self.onAdd = onAdd
            _size = State(initialValue: dish.sizes.first)
        }

        private var chosenExtras: [FoodChoice] { dish.extras.filter { extras.contains($0.name) } }
        private var unitPrice: Decimal { dish.price + (size?.price ?? 0) + chosenExtras.reduce(Decimal(0)) { $0 + $1.price } }
        private var total: Decimal { unitPrice * Decimal(quantity) }

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    FoodArtView(art: dish.art, symbolScale: 0.36)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(alignment: .topTrailing) {
                            FoodCircleButton(systemImage: "xmark", label: "Close") { dismiss() }.padding(12)
                        }
                    header
                    if !dish.sizes.isEmpty {
                        group(title: "Choose a size", caption: "Required") {
                            ForEach(dish.sizes) { choice in
                                row(choice, isSelected: size == choice, isRadio: true) {
                                    size = choice
                                    KitoHaptics.selectionChanged()
                                }
                            }
                        }
                    }
                    if !dish.extras.isEmpty {
                        group(title: "Add extras", caption: "Optional · choose any") {
                            ForEach(dish.extras) { choice in
                                row(choice, isSelected: extras.contains(choice.name), isRadio: false) {
                                    if extras.contains(choice.name) { extras.remove(choice.name) } else { extras.insert(choice.name) }
                                    KitoHaptics.selectionChanged()
                                }
                            }
                        }
                    }
                    noteField
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(theme.colors.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) { addBar }
        }

        private var header: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    if dish.isPopular { FoodTag(text: "Popular", systemImage: "flame.fill") }
                    if dish.isSpicy { FoodTag(text: "Spicy", systemImage: "flame", tint: .red) }
                    if dish.isVegetarian { FoodTag(text: "Vegetarian", systemImage: "leaf.fill", tint: .green) }
                }
                Text(dish.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(theme.colors.onBackground)
                    .accessibilityAddTraits(.isHeader)
                Text(dish.detail)
                    .font(.body)
                    .foregroundStyle(theme.colors.onBackground.opacity(0.65))
                Text("\(KitoCartMoney.string(dish.price + (dish.sizes.first?.price ?? 0))) · from \(restaurant.name)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.colors.onBackground.opacity(0.8))
            }
        }

        private func group<Content: View>(title: String, caption: String, @ViewBuilder content: () -> Content) -> some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title).font(.headline).foregroundStyle(theme.colors.onBackground)
                    Spacer()
                    Text(caption)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.onBackground.opacity(0.55))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(theme.colors.surfaceMuted, in: Capsule())
                }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)
                VStack(spacing: 0) { content() }
                    .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(theme.colors.border, lineWidth: 0.5))
            }
        }

        private func row(_ choice: FoodChoice, isSelected: Bool, isRadio: Bool, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: isRadio ? (isSelected ? "largecircle.fill.circle" : "circle")
                                              : (isSelected ? "checkmark.square.fill" : "square"))
                        .font(.title3)
                        .foregroundStyle(isSelected ? theme.colors.primary : theme.colors.onSurface.opacity(0.35))
                        .contentTransition(.symbolEffect(.replace))
                    Text(choice.name)
                        .font(.body)
                        .foregroundStyle(theme.colors.onSurface)
                    Spacer()
                    if choice.price != 0 {
                        Text((choice.price > 0 ? "+" : "−") + KitoCartMoney.string(abs(choice.price)))
                            .font(.subheadline.weight(.medium).monospacedDigit())
                            .foregroundStyle(theme.colors.onSurface.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 52)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        }

        private var noteField: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Note for the kitchen").font(.headline).foregroundStyle(theme.colors.onBackground)
                TextField("e.g. No onions, extra pili pili", text: $note, axis: .vertical)
                    .lineLimit(2...4)
                    .focused($noteFocused)
                    .padding(14)
                    .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(noteFocused ? theme.colors.primary : theme.colors.border, lineWidth: noteFocused ? 1.5 : 0.5))
            }
        }

        private var addBar: some View {
            HStack(spacing: 12) {
                KitoQuantityStepper(value: $quantity, range: 1...20, style: .capsule,
                                    tint: theme.colors.surfaceMuted, tintForeground: theme.colors.onSurface)
                KitoButton("Add \(quantity) · \(KitoCartMoney.string(total))", systemImage: "bag.fill") {
                    onAdd(size, chosenExtras, note, quantity)
                    dismiss()
                }
                .fullWidth()
                .accessibilityHint("Adds \(quantity) \(dish.name) to your basket")
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.bar)
        }
    }
}
