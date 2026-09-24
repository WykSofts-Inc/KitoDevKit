//
//  ConnectivityDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Every connectivity sample.
struct ConnectivityDemo: View {
    static var count: Int { KitGallery.count(ConnectivitySamples.sections) }

    var body: some View {
        KitGallery(
            title: "Connectivity",
            sections: ConnectivitySamples.sections,
            footnote: "Requires `import KitoConnectivity`. Samples drive a simulated monitor so every state shows on demand; ones marked Live use the real network signal.",
            searchHint: "Try “offline”, “slow”, “retry”, “gauge” or “pill”."
        )
    }
}
