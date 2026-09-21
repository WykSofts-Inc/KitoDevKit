//
//  SettingsDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import UIKit
import KitoCore

private let presetColors: [Color] = [.blue, .indigo, .purple, .pink, .red, .orange, .green, .teal]

struct SettingsDemo: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(KitoAppSettingsViewModel.self) private var settings

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section("Appearance") {
                Picker("Theme", selection: $settings.themeMode) {
                    ForEach(KitoAppSettingsViewModel.ThemeMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Primary color") {
                ColorPicker("Custom color", selection: $settings.primaryColor, supportsOpacity: false)
                HStack(spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 32, height: 32)
                            .overlay {
                                if colorsMatch(settings.primaryColor, color) {
                                    Circle().stroke(.white, lineWidth: 2)
                                    Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white)
                                }
                            }
                            .onTapGesture { settings.primaryColor = color }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Font size") {
                Slider(value: $settings.fontScale, in: 0.8...1.5, step: 0.05) {
                    Text("Font scale")
                } minimumValueLabel: {
                    Text("A").font(.caption)
                } maximumValueLabel: {
                    Text("A").font(.title2)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Preview heading").font(theme.typography.titleLarge)
                    Text("This is what body text looks like at the current scale.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.onBackground.opacity(0.7))
                }
                .padding(.vertical, 4)
            }

            Section("Corner radius") {
                Slider(value: $settings.cornerRadiusScale, in: 0...2, step: 0.1)
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: theme.radii.sm).fill(theme.colors.primary).frame(width: 44, height: 44)
                    RoundedRectangle(cornerRadius: theme.radii.md).fill(theme.colors.primary).frame(width: 44, height: 44)
                    RoundedRectangle(cornerRadius: theme.radii.lg).fill(theme.colors.primary).frame(width: 44, height: 44)
                    RoundedRectangle(cornerRadius: theme.radii.xl).fill(theme.colors.primary).frame(width: 44, height: 44)
                }
                .padding(.vertical, 4)
            }

            Section {
                Button("Reset to defaults", role: .destructive) {
                    settings.reset()
                }
            }

            Section("About") {
                LabeledContent("Kito version", value: Kito.version)
                LabeledContent("Kits in this app", value: "18")
                LabeledContent("Architecture", value: "MVVM")
            }
        }
        .navigationTitle("Settings")
    }

    /// `Color` isn't reliably `Equatable` across dynamic/system colors, so
    /// compare resolved RGB components instead of `==`.
    private func colorsMatch(_ a: Color, _ b: Color) -> Bool {
        UIColor(a).cgColor.components == UIColor(b).cgColor.components
    }
}
