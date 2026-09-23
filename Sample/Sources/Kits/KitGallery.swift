//
//  KitGallery.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// One sample in a kit's gallery: a live preview, the code behind it, and where it's filed.
struct KitSample: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let code: String
    let view: () -> AnyView

    init<V: View>(_ title: String, _ subtitle: String, code: String, @ViewBuilder view: @escaping () -> V) {
        self.title = title; self.subtitle = subtitle; self.code = code
        self.view = { AnyView(view()) }
    }
}

struct KitSection: Identifiable {
    let title: String
    let symbol: String
    let samples: [KitSample]
    var id: String { title }

    init(_ title: String, symbol: String, _ samples: [KitSample]) {
        self.title = title; self.symbol = symbol; self.samples = samples
    }
}

/// A searchable, sectioned list of samples, each opening on its own screen. Shared by every kit
/// gallery that doesn't need a bespoke layout.
struct KitGallery: View {
    let title: String
    let sections: [KitSection]
    /// Shown under each sample's code, e.g. "Requires `import KitoCharts`."
    let footnote: String
    var searchHint = "Try a use case, a component or a behaviour."

    @State private var query = ""

    static func count(_ sections: [KitSection]) -> Int { sections.reduce(0) { $0 + $1.samples.count } }

    private func matches(_ sample: KitSample, in section: KitSection) -> Bool {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return true }
        return sample.title.localizedCaseInsensitiveContains(q)
            || sample.subtitle.localizedCaseInsensitiveContains(q)
            || section.title.localizedCaseInsensitiveContains(q)
    }

    private var hasResults: Bool {
        sections.contains { section in section.samples.contains { matches($0, in: section) } }
    }

    var body: some View {
        List {
            ForEach(sections) { section in
                let items = section.samples.filter { matches($0, in: section) }
                if !items.isEmpty {
                    Section {
                        ForEach(items) { sample in
                            NavigationLink {
                                GallerySampleDetail(title: sample.title, subtitle: sample.subtitle, code: sample.code, footnote: footnote) {
                                    sample.view()
                                }
                            } label: {
                                GallerySampleRow(title: sample.title, subtitle: sample.subtitle)
                            }
                        }
                    } header: {
                        GallerySectionHeader(title: section.title, systemImage: section.symbol)
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $query, prompt: "Search \(Self.count(sections)) samples")
        .overlay { if !hasResults { GalleryNoResults(query: query, hint: searchHint) } }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
