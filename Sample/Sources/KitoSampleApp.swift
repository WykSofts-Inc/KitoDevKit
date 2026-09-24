//
//  KitoSampleApp.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoToasts

@main
struct KitoSampleApp: App {
    @State private var toasts = KitoToastCenter()
    @State private var settings = KitoAppSettingsViewModel()
    init() { NotificationsSampleSetup.install() }

    var body: some Scene {
        WindowGroup {
            // .kitoToastHost is applied INSIDE the closure, not after
            // KitoThemedRoot, so the toast overlay renders within the
            // custom-themed subtree and picks up live theme edits too.
            KitoThemedRoot(settings: settings) {
                ContentView()
                    .kitoToastHost(toasts)
            }
            .environment(toasts)
            .environment(settings)
        }
    }
}
