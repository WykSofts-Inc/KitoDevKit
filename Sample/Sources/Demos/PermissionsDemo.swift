//
//  PermissionsDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Every permissions sample.
struct PermissionsDemo: View {
    static var count: Int { KitGallery.count(PermissionsSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Permissions",
            sections: PermissionsSamples.sections,
            footnote: "Requires `import KitoPermissions`. Samples use a simulated requester so every state shows on demand; ones marked Live ask the system for real.",
            searchHint: "Try “camera”, “banner”, “denied”, “settings” or “dashboard”."
        )
    }
}
