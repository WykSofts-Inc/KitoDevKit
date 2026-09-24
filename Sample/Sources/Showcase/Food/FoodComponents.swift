//
//  FoodComponents.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart

extension FoodShowcase {

    /// Where a tab's navigation stack can go.
    enum FoodRoute: Hashable {
        case restaurant(String)
        case reviews(String)
    }

    // MARK: - Artwork

    /// A gradient tile with the dish or restaurant symbol and a faint scattered pattern.
    struct FoodArtView: View {
        let art: FoodArt
        var symbolScale: CGFloat = 0.42
        var showsPattern = true

        private static let spots: [(x: CGFloat, y: CGFloat, size: CGFloat, angle: Double)] = [
            (0.12, 0.2, 0.16, -18), (0.86, 0.16, 0.12, 22), (0.18, 0.84, 0.13, 12),
            (0.9, 0.78, 0.18, -26), (0.52, 0.08, 0.09, 40), (0.62, 0.92, 0.1, -8),
        ]

        var body: some View {
            GeometryReader { proxy in
                let side = min(proxy.size.width, proxy.size.height)
                ZStack {
                    LinearGradient(colors: art.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    RadialGradient(colors: [.white.opacity(0.3), .clear], center: .topLeading, startRadius: 0,
                                   endRadius: max(proxy.size.width, proxy.size.height) * 0.9)
                    if showsPattern {
                        ForEach(Self.spots.indices, id: \.self) { index in
                            let spot = Self.spots[index]
                            Image(systemName: art.accent ?? art.symbol)
                                .font(.system(size: side * spot.size, weight: .bold))
                                .foregroundStyle(.white.opacity(0.13))
                                .rotationEffect(.degrees(spot.angle))
                                .position(x: proxy.size.width * spot.x, y: proxy.size.height * spot.y)
                        }
                    }
                    Image(systemName: art.symbol)
                        .font(.system(size: side * symbolScale, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: side * 0.05, y: side * 0.03)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .accessibilityHidden(true)
        }
    }

    // MARK: - Small pieces

    struct FoodRatingPill: View {
        let rating: Double
        var count: Int?
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            HStack(spacing: 3) {
                Image(systemName: "star.fill").foregroundStyle(FoodPalette.star)
                Text(String(format: "%.1f", rating)).fontWeight(.bold)
                if let count {
                    Text("(\(count >= 1_000 ? String(format: "%.1fk", Double(count) / 1_000) : "\(count)"))")
                        .foregroundStyle(theme.colors.onSurface.opacity(0.55))
                }
            }
            .font(.footnote)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(theme.colors.surfaceMuted, in: Capsule())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rated \(String(format: "%.1f", rating)) out of 5" + (count.map { ", \($0) ratings" } ?? ""))
        }
    }

    struct FoodTag: View {
        let text: String
        var systemImage: String?
        var tint: Color = FoodPalette.pepper

        var body: some View {
            HStack(spacing: 4) {
                if let systemImage { Image(systemName: systemImage) }
                Text(text)
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(tint, in: Capsule())
        }
    }

    /// A round glass button for over artwork and maps.
    struct FoodCircleButton: View {
        let systemImage: String
        let label: String
        var tint: Color?
        let action: () -> Void
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            Button(action: action) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(tint ?? theme.colors.onSurface)
                    .frame(width: 42, height: 42)
                    .background(.regularMaterial, in: Circle())
                    .overlay(Circle().strokeBorder(theme.colors.border.opacity(0.6), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
            }
            .buttonStyle(FoodPressStyle())
            .accessibilityLabel(label)
        }
    }

    /// The visible way out of the demo.
    struct FoodExitButton: View {
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            Button { store.onExit() } label: {
                Label("Exit demo", systemImage: "xmark")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(theme.colors.onSurface)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(.regularMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(theme.colors.border.opacity(0.7), lineWidth: 0.5))
            }
            .buttonStyle(FoodPressStyle())
            .accessibilityHint("Closes the Chakula showcase")
        }
    }

    struct FoodPressStyle: ButtonStyle {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
                .opacity(configuration.isPressed ? 0.9 : 1)
                .animation(reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
        }
    }

    struct FoodSectionHeader: View {
        let title: String
        var subtitle: String?
        var actionTitle: String?
        var action: (() -> Void)?
        @Environment(\.kitoTheme) private var theme

        var body: some View {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.title3.weight(.bold)).foregroundStyle(theme.colors.onBackground)
                    if let subtitle {
                        Text(subtitle).font(.footnote).foregroundStyle(theme.colors.onBackground.opacity(0.55))
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)
                Spacer()
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.colors.onBackground)
                }
            }
        }
    }

    // MARK: - Restaurant card

    struct FoodRestaurantCard: View {
        let restaurant: FoodRestaurant
        var height: CGFloat = 160
        let open: () -> Void
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme

        private var isFavourite: Bool { store.favourites.contains(restaurant.id) }

        var body: some View {
            ZStack(alignment: .topTrailing) {
                Button(action: open) {
                    VStack(alignment: .leading, spacing: 10) {
                        FoodArtView(art: restaurant.art, symbolScale: 0.4)
                            .frame(height: height)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(alignment: .topLeading) {
                                if let promo = restaurant.promo {
                                    FoodTag(text: promo, systemImage: "tag.fill").padding(12)
                                }
                            }
                            .overlay(alignment: .bottomTrailing) {
                                Text(restaurant.minutesText)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(theme.colors.onSurface)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.regularMaterial, in: Capsule())
                                    .padding(12)
                            }
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(restaurant.name)
                                    .font(.headline)
                                    .foregroundStyle(theme.colors.onBackground)
                                Text("\(restaurant.cuisine.rawValue) · \(restaurant.area) · \(store.distanceText(to: restaurant))")
                                    .font(.subheadline)
                                    .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                                Label(restaurant.feeText, systemImage: "scooter")
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(restaurant.deliveryFee == 0 ? theme.colors.success : theme.colors.onBackground.opacity(0.6))
                            }
                            Spacer(minLength: 8)
                            FoodRatingPill(rating: restaurant.rating, count: restaurant.ratingCount)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(FoodPressStyle())
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(restaurant.name), \(restaurant.cuisine.rawValue) in \(restaurant.area), rated \(restaurant.ratingText), \(restaurant.minutesText), \(restaurant.feeText)")
                .accessibilityHint("Opens the menu")

                FoodCircleButton(systemImage: isFavourite ? "heart.fill" : "heart",
                                 label: isFavourite ? "Remove from favourites" : "Save to favourites",
                                 tint: isFavourite ? FoodPalette.pepper : nil) {
                    store.toggleFavourite(restaurant)
                }
                .padding(10)
            }
        }
    }

    /// The thumbnail the cart and checkout show for a line.
    struct FoodCartThumbnail: View {
        let item: KitoCartItem
        @Environment(FoodStore.self) private var store

        var body: some View {
            FoodArtView(art: store.dish(for: item.id)?.art ?? FoodArt("fork.knife", [FoodPalette.pepper, FoodPalette.pepperDeep]),
                        symbolScale: 0.46, showsPattern: false)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
