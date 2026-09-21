//
//  HapticsDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoHaptics

struct HapticsDemo: View {
    @State private var isEnabled = true
    @State private var selection = 0
    @State private var reactiveFlag = false

    var body: some View {
        Form {
            Section("Semantic") {
                Button("Success") { KitoHaptics.success() }
                Button("Warning") { KitoHaptics.warning() }
                Button("Error") { KitoHaptics.error() }
                Button("Selection changed (drag the picker below)") {}
                Picker("", selection: $selection) {
                    Text("A").tag(0); Text("B").tag(1); Text("C").tag(2)
                }
                .pickerStyle(.segmented)
                .onChange(of: selection) { _, _ in KitoHaptics.selectionChanged() }
            }
            Section("Impact — every weight") {
                Button("Light") { KitoHaptics.impact(.light) }
                Button("Medium (default)") { KitoHaptics.impact(.medium) }
                Button("Heavy") { KitoHaptics.impact(.heavy) }
                Button("Soft") { KitoHaptics.impact(.soft) }
                Button("Rigid") { KitoHaptics.impact(.rigid) }
            }
            Section("Reactive — fires on state change, not a tap") {
                Toggle("Flag (fires .selectionChanged on toggle)", isOn: $reactiveFlag)
                    .kitoHaptic(reactiveFlag) { KitoHaptics.selectionChanged() }
            }
            Section("Global switch") {
                Toggle("Haptics enabled", isOn: $isEnabled)
                    .onChange(of: isEnabled) { _, newValue in KitoHaptics.isEnabled = newValue }
                Text("Every button above is a no-op while this is off — try toggling it and tapping Success again.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Haptics")
    }
}
