//
//  FashionHomeParts.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCarousel
import KitoProduct

// MARK: - Hero slide

/// One full-bleed editorial page with a campaign image and serif headline.
struct FashionHeroSlide: View {
    @Environment(\.kitoTheme) private var theme
    let slide: FashionEditorial
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                KitoProductMediaView(.artwork(slide.artwork))
                LinearGradient(colors: [.clear, .clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 8) {
                    Text(slide.kicker.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(2.4)
                        .foregroundStyle(.white.opacity(0.85))
                    Text(slide.title)
                        .font(.system(size: 40, weight: .regular, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    Text(slide.subtitle)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.85))
                    Text("Discover")
                        .font(.system(size: 13, weight: .semibold))
                        .underline()
                        .foregroundStyle(.white)
                        .padding(.top, 4)
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, 52)
            }
            .clipped()
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(slide.title). \(slide.subtitle)")
        .accessibilityHint("Opens the edit")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Look card

struct FashionLookCard: View {
    @Environment(\.kitoTheme) private var theme
    let look: FashionLook

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KitoProductMediaView(.artwork(look.artwork))
            LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text(look.place.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.8))
                Text(look.title)
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(.white)
                Text("Shop the look · \(look.productIDs.count) pieces")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(theme.spacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous))
    }
}

// MARK: - Designer stories

/// The designer spotlight as full-screen stories: three pieces from each designer's studio.
struct FashionDesignerStories: View {
    let startingAt: String?
    @Binding var seen: Set<String>
    let onClose: () -> Void

    private static let times = ["Today", "Yesterday", "2 days ago"]

    private func pieces(_ designer: FashionDesigner) -> [FashionItem] {
        Array(FashionCatalogue.items(by: designer.id).sorted { $0.popularity > $1.popularity }.prefix(3))
    }

    var body: some View {
        KitoStoryViewer(FashionCatalogue.designers, startingAt: startingAt,
                        segmentCount: { pieces($0).count },
                        title: { $0.name },
                        subtitle: { _, index in Self.times[min(index, Self.times.count - 1)] },
                        replyPlaceholder: "Ask the atelier",
                        tint: FashionPalette.gold,
                        onSeen: { designer, index in
                            if index == pieces(designer).count - 1 { seen.insert(designer.id) }
                        },
                        onDismiss: onClose) { designer, index in
            FashionStoryPage(designer: designer, item: pieces(designer)[min(index, pieces(designer).count - 1)])
        } avatar: { designer in
            FashionDesignerAvatar(designer: designer, size: 32)
        }
    }
}

private struct FashionStoryPage: View {
    let designer: FashionDesigner
    let item: FashionItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.black
            KitoProductMediaView(item.product.media.first(where: { $0.accessibilityLabel?.hasPrefix("Campaign") == true }) ?? item.heroArtwork)
                .ignoresSafeArea()
            LinearGradient(colors: [.black.opacity(0.35), .clear, .clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 8) {
                Text("FROM THE STUDIO · \(designer.city.uppercased())")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.8))
                Text(item.product.name)
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(.white)
                if let summary = item.product.summary {
                    Text(summary)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 120)
        }
        .accessibilityElement(children: .combine)
    }
}
