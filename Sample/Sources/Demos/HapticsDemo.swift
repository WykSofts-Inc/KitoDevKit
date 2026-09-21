//
//  HapticsDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoHaptics

struct HapticsDemo: View {
    @State private var isEnabled = true

    var body: some View {
        Form {
            Section("Semantic") {
                Button("Success") { KitoHaptics.success() }
                Button("Warning") { KitoHaptics.warning() }
                Button("Error") { KitoHaptics.error() }
                Button("Selection changed") { KitoHaptics.selectionChanged() }
            }
            Section("Impact") {
                Button("Light") { KitoHaptics.impact(.light) }
                Button("Medium") { KitoHaptics.impact(.medium) }
                Button("Heavy") { KitoHaptics.impact(.heavy) }
            }
            Section("Global switch") {
                Toggle("Haptics enabled", isOn: $isEnabled)
                    .onChange(of: isEnabled) { _, newValue in KitoHaptics.isEnabled = newValue }
            }
        }
        .navigationTitle("Haptics")
    }
}
