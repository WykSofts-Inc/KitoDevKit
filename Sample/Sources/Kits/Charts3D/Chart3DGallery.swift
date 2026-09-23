//
//  Chart3DGallery.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Every 3D chart sample, searchable. Each opens on its own screen, so only one SceneKit view
/// renders at a time.
struct Chart3DGallery: View {
    @State private var query = ""

    private var filtered: [Chart3DSample] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return Chart3DSampleCatalog.all }
        return Chart3DSampleCatalog.all.filter {
            $0.title.localizedCaseInsensitiveContains(q)
                || $0.subtitle.localizedCaseInsensitiveContains(q)
                || $0.category.rawValue.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        List {
            ForEach(Chart3DCategory.allCases) { category in
                let items = filtered.filter { $0.category == category }
                if !items.isEmpty {
                    Section {
                        ForEach(items) { sample in
                            NavigationLink { Chart3DSampleDetail(sample: sample) } label: {
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
        .searchable(text: $query, prompt: "Search \(Chart3DSampleCatalog.all.count) samples")
        .overlay { if filtered.isEmpty { GalleryNoResults(query: query, hint: "Try a chart (“donut”), a use case (“budget”) or a behaviour (“slider”).") } }
        .navigationTitle("3D charts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Chart3DSampleDetail: View {
    let sample: Chart3DSample

    var body: some View {
        GallerySampleDetail(
            title: sample.title,
            subtitle: sample.subtitle,
            code: sample.code,
            footnote: "Requires `import KitoCharts`. Drag to orbit, pinch to zoom, two fingers to pan. After changing `points`, `theme` or a shape setting, call `rebuild()`."
        ) {
            sample.view()
        }
    }
}
