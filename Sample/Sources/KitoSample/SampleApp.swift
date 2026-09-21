//
//  SampleApp.swift
//  KitoDevKit
//
//  Created by Wycliff on 12/9/25.
//  Copyright © 2025 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoDevKit

// This file's job is to exercise every kit the umbrella re-exports.
// It doesn't need to look pretty. If it compiles, the umbrella is intact.

@available(iOS 16.0, *)
public struct KitoSampleApp: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Theme (KitoCore)") {
                    Text("Version \(Kito.version)")
                        .font(KitoTheme.light.typography.caption)
                }
                Section("Kits reachable through one import") {
                    NavigationLink("Buttons demo") { ButtonsDemo() }
                    NavigationLink("Fields demo")  { FieldsDemo() }
                    NavigationLink("Screens demo") { ScreensDemo() }
                }
            }
            .navigationTitle("KitoDevKit sample")
        }
        .autoKitoTheme()
    }
}

// The concrete demo views live in each kit. These are placeholders so this file
// stays honest while the individual kits stabilize their public APIs. Replace
// with real screens (SignInScreen, CardCheckoutScreen, etc.) as they land.

private struct ButtonsDemo: View {
    var body: some View { Text("Buttons demo — replace with KitoButtons showcase") }
}
private struct FieldsDemo: View {
    var body: some View { Text("Fields demo — replace with KitoFields showcase") }
}
private struct ScreensDemo: View {
    var body: some View { Text("Screens demo — replace with KitoScreens showcase") }
}
