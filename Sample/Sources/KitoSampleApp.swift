//
//  KitoSampleApp.swift
//  KitoSample
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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(toasts)
                .kitoToastHost(toasts)
                .autoKitoTheme()
        }
    }
}
