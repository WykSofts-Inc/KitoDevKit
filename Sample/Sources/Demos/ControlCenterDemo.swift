//
//  ControlCenterDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoHaptics
import KitoToasts

/// A Control Center-style module grid — glass tiles, toggle modules, a pair
/// of vertical "brightness/volume" style sliders — built entirely from
/// KitoCore's `kitoGlassCard`/`kitoGlow` and real app state (theme mode,
/// KitoHaptics' global switch, font/corner scale), not fake controls.
struct ControlCenterDemo: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(KitoAppSettingsViewModel.self) private var settings
    @Environment(KitoToastCenter.self) private var toasts

    @State private var simulatedOnline = true
    @State private var soundEnabled = true
    @State private var hapticsEnabled = KitoHaptics.isEnabled

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        @Bindable var settings = settings

        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                connectivityModule
                    .gridCellColumns(2)

                toggleModule(
                    title: "Neon Mode",
                    systemImage: "bolt.fill",
                    isOn: Binding(
                        get: { settings.themeMode == .neon },
                        set: { settings.themeMode = $0 ? .neon : .dark }
                    ),
                    tint: theme.colors.primary
                )

                toggleModule(title: "Haptics", systemImage: "waveform", isOn: $hapticsEnabled, tint: theme.colors.secondary)
                    .onChange(of: hapticsEnabled) { _, newValue in KitoHaptics.isEnabled = newValue }

                toggleModule(title: "Sound", systemImage: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill", isOn: $soundEnabled, tint: theme.colors.warning)

                VerticalControlSlider(value: $settings.fontScale, range: 0.8...1.5, title: "Text Size", systemImage: "textformat.size", tint: theme.colors.primary)
                    .kitoHaptic(roundedFontScale) { KitoHaptics.selectionChanged() }

                VerticalControlSlider(value: $settings.cornerRadiusScale, range: 0...2, title: "Roundness", systemImage: "square.on.circle", tint: theme.colors.secondary)
                    .kitoHaptic(roundedRadiusScale) { KitoHaptics.selectionChanged() }

                quickActions
                    .gridCellColumns(2)
            }
            .padding(16)
        }
        .background(
            LinearGradient(colors: [theme.colors.background, theme.colors.secondary.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationTitle("Control Center")
    }

    private var roundedFontScale: Int { Int((settings.fontScale * 20).rounded()) }
    private var roundedRadiusScale: Int { Int((settings.cornerRadiusScale * 20).rounded()) }

    private var connectivityModule: some View {
        Button {
            simulatedOnline.toggle()
            KitoHaptics.impact(.light)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill((simulatedOnline ? theme.colors.success : theme.colors.danger).opacity(0.18)).frame(width: 46, height: 46)
                    Image(systemName: simulatedOnline ? "wifi" : "wifi.slash")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(simulatedOnline ? theme.colors.success : theme.colors.danger)
                }
                .kitoGlow(simulatedOnline ? theme.colors.success : theme.colors.danger, radius: 12, intensity: 0.4)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Connectivity").font(.subheadline.weight(.semibold)).foregroundStyle(theme.colors.onBackground)
                    Text(simulatedOnline ? "Online — demo toggle" : "Offline — demo toggle")
                        .font(.caption2)
                        .foregroundStyle(theme.colors.onBackground.opacity(0.55))
                }
                Spacer()
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .kitoGlassCard(cornerRadius: theme.radii.lg, tint: simulatedOnline ? theme.colors.success : theme.colors.danger)
    }

    private func toggleModule(title: String, systemImage: String, isOn: Binding<Bool>, tint: Color) -> some View {
        Button {
            isOn.wrappedValue.toggle()
            KitoHaptics.impact(.light)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle().fill((isOn.wrappedValue ? tint : theme.colors.onBackground.opacity(0.12)).opacity(isOn.wrappedValue ? 0.2 : 1)).frame(width: 40, height: 40)
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isOn.wrappedValue ? tint : theme.colors.onBackground.opacity(0.4))
                }
                .kitoGlow(isOn.wrappedValue ? tint : .clear, radius: 10, intensity: 0.4)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.onBackground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
        .buttonStyle(.plain)
        .kitoGlassCard(cornerRadius: theme.radii.lg, tint: isOn.wrappedValue ? tint : .clear)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn.wrappedValue)
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("QUICK ACTIONS").font(.caption2.weight(.bold)).kerning(0.6).foregroundStyle(theme.colors.onBackground.opacity(0.5))
            HStack(spacing: 10) {
                Button("Success") { KitoHaptics.success(); toasts.show("All systems nominal", style: .success) }
                    .buttonStyle(.kito(.tonal, size: .small, fullWidth: true))
                Button("Warning") { KitoHaptics.warning(); toasts.show("Running low on battery", style: .warning) }
                    .buttonStyle(.kito(.tonal, size: .small, fullWidth: true))
                Button("Error") { KitoHaptics.error(); toasts.show("Connection lost", style: .error) }
                    .buttonStyle(.kito(.tonal, size: .small, fullWidth: true))
            }
        }
        .padding(16)
        .kitoGlassCard(cornerRadius: theme.radii.lg)
    }
}

/// A vertical "brightness/volume" style control: drag anywhere in the tile
/// to set `value` proportionally to how full the tile is, like iOS Control
/// Center's own sliders.
private struct VerticalControlSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String
    let systemImage: String
    let tint: Color

    @Environment(\.kitoTheme) private var theme

    private var fraction: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return (value - range.lowerBound) / span
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous)
                    .fill(theme.colors.onBackground.opacity(0.06))

                RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous)
                    .fill(tint.opacity(0.35))
                    .frame(height: max(8, proxy.size.height * fraction))
                    .kitoGlow(tint, radius: 14, intensity: 0.4)

                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: systemImage)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(theme.colors.onBackground)
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let raw = 1 - (drag.location.y / max(proxy.size.height, 1))
                        let clamped = min(max(raw, 0), 1)
                        value = range.lowerBound + clamped * (range.upperBound - range.lowerBound)
                    }
            )
        }
        .frame(height: 110)
        .kitoGlassCard(cornerRadius: theme.radii.lg)
        .overlay(alignment: .topLeading) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.onBackground)
                .padding(12)
        }
    }
}
