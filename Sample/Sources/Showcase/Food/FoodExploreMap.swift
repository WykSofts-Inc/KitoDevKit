//
//  FoodExploreMap.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoMaps

extension FoodShowcase {

    /// Home's map mode: every restaurant as a delivery-fee bubble with its rating on the corner,
    /// and a card carousel that follows the selected pin.
    struct FoodRestaurantsMap: View {
        let restaurants: [FoodRestaurant]
        let open: (FoodRestaurant) -> Void
        @Environment(FoodStore.self) private var store
        @State private var selection: String?

        private var pins: [KitoMapPin] {
            restaurants.map { restaurant in
                KitoMapPin(id: restaurant.id, coordinate: restaurant.coordinate, title: restaurant.name,
                           subtitle: "\(restaurant.cuisine.rawValue) · \(restaurant.minutesText)",
                           style: .bubble(restaurant.deliveryFee == 0 ? "Free" : KitoCartMoney.string(restaurant.deliveryFee)),
                           tint: FoodPalette.pepper, badge: "★ \(restaurant.ratingText)", systemImage: restaurant.cuisine.systemImage)
            } + [
                KitoMapPin(id: "home", coordinate: store.address.coordinate, title: "You", subtitle: store.address.line,
                           style: .teardrop, tint: .indigo, systemImage: "house.fill"),
            ]
        }

        var body: some View {
            KitoMapView(pins: pins, selection: $selection, style: .muted) { pin in
                if let restaurant = FoodData.restaurant(id: pin.id) {
                    FoodMapCard(restaurant: restaurant) { open(restaurant) }
                } else {
                    KitoMapPinCard(pin: pin, detail: "Your delivery address")
                }
            }
            .controls([.fitAll])
            .fitPadding(EdgeInsets(top: 60, leading: 40, bottom: 190, trailing: 60))
            .onAppear { if selection == nil { selection = restaurants.first?.id } }
        }
    }

    struct FoodMapCard: View {
        let restaurant: FoodRestaurant
        let open: () -> Void
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            Button(action: open) {
                HStack(spacing: 12) {
                    FoodArtView(art: restaurant.art, symbolScale: 0.44, showsPattern: false)
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(restaurant.name)
                            .font(.headline)
                            .foregroundStyle(theme.colors.onSurface)
                            .lineLimit(1)
                        Text("\(restaurant.cuisine.rawValue) · \(restaurant.area) · \(store.distanceText(to: restaurant))")
                            .font(.caption)
                            .foregroundStyle(theme.colors.onSurface.opacity(0.6))
                            .lineLimit(1)
                        HStack(spacing: 8) {
                            FoodRatingPill(rating: restaurant.rating)
                            Label(restaurant.minutesText, systemImage: "clock")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(theme.colors.onSurface.opacity(0.7))
                        }
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(theme.colors.onSurface.opacity(0.4))
                }
                .padding(12)
                .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.14), radius: 16, y: 6)
            }
            .buttonStyle(FoodPressStyle())
            .accessibilityElement(children: .combine)
            .accessibilityHint("Opens the menu")
        }
    }
}
