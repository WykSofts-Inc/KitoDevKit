//
//  IslandBarDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoIslandBar

struct IslandBarDemo: View {
    @Environment(\.kitoTheme) private var theme
    @State private var battery = KitoBatteryMonitor()
    @State private var manualState: KitoIslandBarState = .hidden

    var body: some View {
        Form {
            Section {
                Text("iOS never lets a third-party app recolor the real notch or Dynamic Island — that's system chrome. This is the honest alternative: a real pill this app draws and colors itself, positioned where the Island sits.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Real battery level") {
                if let level = battery.level {
                    LabeledContent("Level", value: "\(Int((level * 100).rounded()))%")
                    LabeledContent("State", value: batteryStateLabel)
                    Button("Show in island bar") { manualState = battery.islandBarState() }
                } else {
                    Text("This Simulator has no real battery hardware — run on a device to see a live percentage.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Compact") {
                Button("Charging glyph, blue") { manualState = .compact(systemImage: "bolt.fill", color: .blue) }
                Button("Recording glyph, red") { manualState = .compact(systemImage: "record.circle", color: .red) }
            }

            Section("Progress") {
                Button("Upload — 35%, orange") { manualState = .progress(fraction: 0.35, color: .orange, label: "35%") }
                Button("Sync — 80%, green") { manualState = .progress(fraction: 0.8, color: .green, label: "80%") }
            }

            Section("Expanded") {
                Button("Low battery alert") { manualState = .expanded(title: "Low battery", message: "12% remaining", color: .red) }
                Button("Download complete") { manualState = .expanded(title: "Download complete", message: "episode.mp4", color: theme.colors.primary) }
            }

            Section {
                Button("Hide", role: .destructive) { manualState = .hidden }
            }
        }
        .navigationTitle("Island Bar")
        .kitoIslandBar(manualState)
    }

    private var batteryStateLabel: String {
        switch battery.state {
        case .charging: return "Charging"
        case .full: return "Full"
        case .unplugged: return "Unplugged"
        case .unknown: return "Unknown"
        @unknown default: return "Unknown"
        }
    }
}
