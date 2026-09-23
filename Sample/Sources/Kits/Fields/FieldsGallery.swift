//
//  FieldsGallery.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Every KitoFields sample, searchable, pushed from the DevKit catalog. Adapted from the
/// KitoFields example app: no NavigationStack of its own, since the catalog already provides one.
struct FieldsGallery: View {
    @State private var query = ""

    private var filtered: [FieldSample] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return FieldSampleCatalog.all }
        return FieldSampleCatalog.all.filter {
            $0.title.localizedCaseInsensitiveContains(q)
                || $0.subtitle.localizedCaseInsensitiveContains(q)
                || $0.category.rawValue.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        List {
            ForEach(FieldCategory.allCases) { category in
                let items = filtered.filter { $0.category == category }
                if !items.isEmpty {
                    Section {
                        ForEach(items) { sample in
                            NavigationLink { FieldSampleDetail(sample: sample) } label: {
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
        .searchable(text: $query, prompt: "Search \(FieldSampleCatalog.all.count) samples")
        .overlay { if filtered.isEmpty { GalleryNoResults(query: query) } }
        .navigationTitle("KitoFields")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FieldSampleDetail: View {
    let sample: FieldSample

    var body: some View {
        GallerySampleDetail(
            title: sample.title,
            subtitle: sample.subtitle,
            code: sample.code,
            footnote: "Requires `import KitoFields`."
        ) {
            sample.view()
        }
    }
}
