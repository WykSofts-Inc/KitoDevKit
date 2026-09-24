//
//  GlobalSearch.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// One searchable sample from any gallery, with the screen it opens.
struct SampleSearchHit: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let kit: String
    let symbol: String
    let destination: () -> AnyView
}

/// Every sample in every gallery, for the home screen's search.
enum GlobalSampleIndex {
    static let all: [SampleSearchHit] = {
        var hits: [SampleSearchHit] = []
        hits += SampleCatalog.all.map { sample in
            SampleSearchHit(title: sample.title, subtitle: sample.subtitle, kit: "Buttons", symbol: "hand.tap.fill") { AnyView(ButtonSampleDetail(sample: sample)) }
        }
        hits += FieldSampleCatalog.all.map { sample in
            SampleSearchHit(title: sample.title, subtitle: sample.subtitle, kit: "Fields", symbol: "character.cursor.ibeam") { AnyView(FieldSampleDetail(sample: sample)) }
        }
        hits += kit("Charts", symbol: "chart.xyaxis.line", footnote: "Requires `import KitoCharts`.", ChartsGallery.sections)
        hits += Chart3DSampleCatalog.all.map { sample in
            SampleSearchHit(title: sample.title, subtitle: sample.subtitle, kit: "3D Charts", symbol: "cube.fill") { AnyView(Chart3DSampleDetail(sample: sample)) }
        }
        hits += kit("Onboarding", symbol: "sparkles", footnote: "Requires `import KitoOnboarding`.", OnboardingSamples.sections)
        hits += kit("Dynamic Island", symbol: "capsule.portrait", footnote: "Requires `import KitoIslandBar`.", IslandSamples.sections)
        hits += kit("Validation", symbol: "checkmark.shield", footnote: "Rules come from `import KitoValidation`; fields from `import KitoFields`.", ValidationGallery.sections)
        hits += kit("Wallet & Cards", symbol: "wallet.pass.fill", footnote: "Requires `import KitoWalletCards`.", WalletSamples.sections)
        hits += kit("Modals", symbol: "rectangle.portrait.bottomthird.inset.filled", footnote: "Requires `import KitoModals`.", ModalSamples.sections)
        hits += kit("Photo Editor", symbol: "camera.filters", footnote: "Requires `import KitoPhotoEditor`.", PhotoSamples.sections)
        hits += kit("Side Menus & Tab Bars", symbol: "sidebar.left", footnote: "Requires `import KitoNavigation`.", NavigationSamples.sections)
        hits += kit("Toasts", symbol: "bubble.left.fill", footnote: "Requires `import KitoToasts`.", ToastsSamples.sections)
        hits += kit("Loaders", symbol: "arrow.triangle.2.circlepath", footnote: "Requires `import KitoLoaders`.", LoadersSamples.sections)
        hits += kit("Empty States", symbol: "tray", footnote: "Requires `import KitoEmptyStates`.", EmptyStatesSamples.sections)
        hits += kit("Haptics", symbol: "waveform", footnote: "Requires `import KitoHaptics`.", HapticsSamples.sections)
        hits += kit("Carousels & Stories", symbol: "rectangle.stack.fill", footnote: "Requires `import KitoCarousel`.", CarouselSamples.sections)
        hits += kit("Reviews & Ratings", symbol: "star.bubble.fill", footnote: "Requires `import KitoReviews`.", ReviewsSamples.sections)
        hits += kit("Calendar", symbol: "calendar", footnote: "Requires `import KitoCalendar`.", CalendarSamples.sections)
        hits += kit("Media Player", symbol: "play.rectangle.fill", footnote: "Requires `import KitoMediaPlayer`.", MediaPlayerSamples.sections)
        hits += kit("Chat", symbol: "bubble.left.and.bubble.right.fill", footnote: "Requires `import KitoChat`.", ChatSamples.sections)
        hits += kit("Auth", symbol: "person.badge.key.fill", footnote: "Requires `import KitoAuth`.", AuthSamples.sections)
        hits += kit("Maps", symbol: "map.fill", footnote: "Requires `import KitoMaps`.", MapsSamples.sections)
        hits += kit("Widgets & Intents", symbol: "square.grid.2x2.fill", footnote: "Requires `import KitoWidgets`.", WidgetsSamples.sections)
        hits += kit("Paywall", symbol: "crown.fill", footnote: "Requires `import KitoPaywall`.", PaywallSamples.sections)
        hits += kit("Media Picker", symbol: "photo.on.rectangle.angled", footnote: "Requires `import KitoMediaPicker`.", MediaSamples.sections)
        return hits
    }()

    private static func kit(_ name: String, symbol: String, footnote: String, _ sections: [KitSection]) -> [SampleSearchHit] {
        sections.flatMap { section in
            section.samples.map { sample in
                SampleSearchHit(title: sample.title, subtitle: "\(section.title) · \(sample.subtitle)", kit: name, symbol: symbol) {
                    AnyView(GallerySampleDetail(title: sample.title, subtitle: sample.subtitle, code: sample.code, footnote: footnote) { sample.view() })
                }
            }
        }
    }

    /// Hits whose title, subtitle or kit contains every word of `query`, best matches first:
    /// title matches ahead of subtitle-only ones.
    static func search(_ query: String, limit: Int = 60) -> [SampleSearchHit] {
        let words = query.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
        guard !words.isEmpty else { return [] }
        let matches = all.filter { hit in
            let haystack = "\(hit.title) \(hit.subtitle) \(hit.kit)".lowercased()
            return words.allSatisfy(haystack.contains)
        }
        let ranked = matches.sorted { lhs, rhs in
            let l = words.allSatisfy(lhs.title.lowercased().contains), r = words.allSatisfy(rhs.title.lowercased().contains)
            return l && !r
        }
        return Array(ranked.prefix(limit))
    }
}

/// A result row on the home screen's search.
struct SampleSearchRow: View {
    @Environment(\.kitoTheme) private var theme
    let hit: SampleSearchHit

    var body: some View {
        NavigationLink(destination: hit.destination()) {
            HStack(spacing: 12) {
                Image(systemName: hit.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(theme.colors.primary.opacity(0.16)))
                    .foregroundStyle(theme.colors.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(hit.title).font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
                    Text("\(hit.kit) · \(hit.subtitle)").font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
