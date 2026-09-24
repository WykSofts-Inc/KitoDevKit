//
//  BiometricsDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Every biometrics sample.
struct BiometricsDemo: View {
    static var count: Int { KitGallery.count(BiometricsSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Biometrics",
            sections: BiometricsSamples.sections,
            footnote: "Requires `import KitoBiometrics`. Samples use a simulated authenticator (the simulator has no enrolled face); ones marked Live use real Face ID.",
            searchHint: "Try “lock”, “passcode”, “vault”, “balance” or “glyph”."
        )
    }
}
