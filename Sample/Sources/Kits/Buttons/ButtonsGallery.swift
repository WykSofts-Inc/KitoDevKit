//
//  ButtonsGallery.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Every KitoButtons sample, searchable, pushed from the DevKit catalog. Adapted from the
/// KitoButtons example app: no NavigationStack of its own, since the catalog already provides one.
struct ButtonsGallery: View {
    @State private var query = ""

    private var filtered: [Sample] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return SampleCatalog.all }
        return SampleCatalog.all.filter {
            $0.title.localizedCaseInsensitiveContains(q)
                || $0.subtitle.localizedCaseInsensitiveContains(q)
                || $0.category.rawValue.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        List {
            ForEach(SampleCategory.allCases) { category in
                let items = filtered.filter { $0.category == category }
                if !items.isEmpty {
                    Section {
                        ForEach(items) { sample in
                            NavigationLink { ButtonSampleDetail(sample: sample) } label: {
                                GallerySampleRow(title: sample.title, subtitle: sample.subtitle)
                            }
                        }
                    } header: {
                        GallerySectionHeader(title: category.rawValue, systemImage: category.symbol)
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $query, prompt: "Search \(SampleCatalog.all.count) samples")
        .overlay { if filtered.isEmpty { GalleryNoResults(query: query) } }
        .navigationTitle("KitoButtons")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ButtonSampleDetail: View {
    let sample: Sample

    var body: some View {
        GallerySampleDetail(
            title: sample.title,
            subtitle: sample.subtitle,
            code: sample.code,
            footnote: "Requires `import KitoButtons`."
        ) {
            sample.view()
        }
    }
}
