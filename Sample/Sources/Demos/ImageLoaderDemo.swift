//
//  ImageLoaderDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoImageLoader

private let samplePresets: [(name: String, url: String)] = [
    ("Landscape", "https://picsum.photos/seed/kito-landscape/800/600"),
    ("Portrait", "https://picsum.photos/seed/kito-portrait/600/900"),
    ("Square", "https://picsum.photos/seed/kito-square/700/700"),
]

struct ImageLoaderDemo: View {
    @Environment(\.kitoTheme) private var theme
    @State private var urlText = samplePresets[0].url
    @State private var placeholderStyle: KitoImagePlaceholderStyle = .progressRing
    @State private var reloadToken = UUID()

    private var url: URL? { URL(string: urlText) }

    var body: some View {
        Form {
            Section("Paste a link") {
                TextField("https://...", text: $urlText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                HStack {
                    ForEach(samplePresets, id: \.name) { preset in
                        Button(preset.name) { urlText = preset.url; reloadToken = UUID() }
                            .font(.caption)
                            .buttonStyle(.bordered)
                    }
                }
                Button("Replay load — instant if cached, pair with Clear Cache below to see a real fetch") { reloadToken = UUID() }
                    .font(.caption)
            }

            Section("Loading placeholder style") {
                Picker("Style", selection: $placeholderStyle) {
                    ForEach(KitoImagePlaceholderStyle.allCases, id: \.self) { style in
                        Text(style.label).tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Result — KitoImageView, memory+disk cached") {
                if let url {
                    KitoImageView(url: url, placeholderStyle: placeholderStyle) { image in
                        image.resizable().scaledToFill()
                    }
                    .id(reloadToken)
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: theme.radii.lg))
                } else {
                    Text("Enter a valid URL above.").foregroundStyle(.secondary)
                }
                Text("Scroll away and back, or revisit this screen — the same URL loads from cache instantly instead of re-downloading, unlike AsyncImage.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Section("Cache") {
                Button("Clear memory cache") { KitoImageLoader.shared.clearMemoryCache() }
                Button("Clear disk cache", role: .destructive) {
                    Task { await KitoImageLoader.shared.clearDiskCache() }
                }
            }
        }
        .navigationTitle("Image Loader")
    }
}
