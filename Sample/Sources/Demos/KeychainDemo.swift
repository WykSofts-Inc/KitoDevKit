//
//  KeychainDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Every keychain sample.
struct KeychainDemo: View {
    static var count: Int { KitGallery.count(KeychainSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Keychain",
            sections: KeychainSamples.sections,
            footnote: "Requires `import KitoKeychain`. Vault samples keep secrets in memory behind a simulated Face ID; ones marked Live use this app's keychain.",
            searchHint: "Try “vault”, “token”, “reveal”, “card” or “sign out”."
        )
    }
}
