//
//  ContentView.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

struct KitoCatalogEntry: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let destination: AnyView

    init<Content: View>(_ title: String, _ subtitle: String, systemImage: String, @ViewBuilder destination: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.destination = AnyView(destination())
    }
}

struct KitoCatalogSection: Identifiable {
    let id = UUID()
    let title: String
    let entries: [KitoCatalogEntry]
}

struct ContentView: View {
    @Environment(\.kitoTheme) private var theme
    @State private var appeared = false

    private let sections: [KitoCatalogSection] = [
        KitoCatalogSection(title: "Feedback", entries: [
            KitoCatalogEntry("Loaders", "Spinner, dots, pulse, progress ring, skeleton", systemImage: "arrow.triangle.2.circlepath") { LoadersDemo() },
            KitoCatalogEntry("Toasts", "Queued, swipeable, spring physics", systemImage: "bubble.left.fill") { ToastsDemo() },
            KitoCatalogEntry("Modals", "Bottom sheets, confirmations, status dialog", systemImage: "rectangle.portrait.bottomthird.inset.filled") { ModalsDemo() },
            KitoCatalogEntry("Empty States", "No data, no results, offline, error", systemImage: "tray") { EmptyStatesDemo() },
            KitoCatalogEntry("Haptics", "Semantic feedback for every interaction", systemImage: "waveform") { HapticsDemo() },
        ]),
        KitoCatalogSection(title: "Data & Charts", entries: [
            KitoCatalogEntry("Charts", "Line, bar, pie/donut, and 3D bars", systemImage: "chart.xyaxis.line") { ChartsDemo() },
            KitoCatalogEntry("Formatting", "Currency, compact numbers, dates", systemImage: "textformat.123") { FormattingDemo() },
        ]),
        KitoCatalogSection(title: "Navigation", entries: [
            KitoCatalogEntry("Tab Bar & Side Menu", "Custom tab bar and a swipeable drawer", systemImage: "sidebar.left") { NavigationDemo() },
            KitoCatalogEntry("Onboarding", "Paged, swipeable, skippable", systemImage: "sparkles") { OnboardingDemo() },
        ]),
        KitoCatalogSection(title: "Forms", entries: [
            KitoCatalogEntry("Validation", "Live email & password validation", systemImage: "checkmark.shield") { ValidationDemo() },
            KitoCatalogEntry("Media Picker", "Photos, camera, files, clipboard, URL", systemImage: "photo.on.rectangle.angled") { MediaPickerDemo() },
        ]),
        KitoCatalogSection(title: "Device", entries: [
            KitoCatalogEntry("Permissions", "One async API, themed rationale screen", systemImage: "hand.raised") { PermissionsDemo() },
            KitoCatalogEntry("Biometrics", "Face ID / Touch ID authentication", systemImage: "faceid") { BiometricsDemo() },
            KitoCatalogEntry("Keychain", "Secure token storage round-trip", systemImage: "key.fill") { KeychainDemo() },
            KitoCatalogEntry("Connectivity", "Live online/offline monitoring", systemImage: "wifi") { ConnectivityDemo() },
        ]),
        KitoCatalogSection(title: "System", entries: [
            KitoCatalogEntry("Control Center", "Glass modules, toggles, drag sliders", systemImage: "slider.horizontal.3") { ControlCenterDemo() },
            KitoCatalogEntry("Island Bar", "In-app Dynamic-Island-style status pill", systemImage: "capsule.portrait") { IslandBarDemo() },
        ]),
        KitoCatalogSection(title: "Networking", entries: [
            KitoCatalogEntry("Image Loader", "Cache-backed image loading, live from a URL", systemImage: "photo.badge.arrow.down") { ImageLoaderDemo() },
        ]),
        KitoCatalogSection(title: "Commerce", entries: [
            KitoCatalogEntry("Cart", "Choreographed add-to-cart, fly-to-badge", systemImage: "cart.fill") { CartDemo() },
            KitoCatalogEntry("Order Tracking", "Self-refreshing status + Live Activity", systemImage: "shippingbox.fill") { OrderTrackingDemo() },
        ]),
    ]

    private var flatEntries: [(section: KitoCatalogSection, entry: KitoCatalogEntry, globalIndex: Int)] {
        var index = 0
        return sections.flatMap { section in
            section.entries.map { entry in
                defer { index += 1 }
                return (section, entry, index)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 28) {
                    header

                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section.title.uppercased())
                                .font(.caption.weight(.bold))
                                .kerning(0.8)
                                .foregroundStyle(theme.colors.primary)
                                .padding(.horizontal, 4)

                            VStack(spacing: 10) {
                                ForEach(section.entries) { entry in
                                    row(entry, globalIndex: flatEntries.first { $0.entry.id == entry.id }?.globalIndex ?? 0)
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(backdrop)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsDemo()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(theme.colors.primary)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            }
        }
    }

    // MARK: Backdrop

    private var backdrop: some View {
        ZStack {
            theme.colors.background.ignoresSafeArea()
            Circle()
                .fill(theme.colors.primary.opacity(0.28))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: -140, y: -260)
            Circle()
                .fill(theme.colors.secondary.opacity(0.22))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: 160, y: 120)
        }
        .ignoresSafeArea()
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("KitoDevKit")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(theme.colors.onBackground)
                .kitoGlow(theme.colors.primary, radius: 14, intensity: 0.35)
            Text("Every kit in this ecosystem, live and interactive.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.onBackground.opacity(0.6))
        }
        .padding(.top, 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -8)
    }

    // MARK: Rows

    private func row(_ entry: KitoCatalogEntry, globalIndex: Int) -> some View {
        NavigationLink(destination: entry.destination) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(theme.colors.primary.opacity(0.16))
                        .frame(width: 44, height: 44)
                    Image(systemName: entry.systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(theme.colors.primary)
                }
                .kitoGlow(theme.colors.primary, radius: 12, intensity: 0.35)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.onBackground)
                    Text(entry.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.onBackground.opacity(0.55))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.onBackground.opacity(0.3))
            }
            .padding(14)
            .kitoGlassCard(cornerRadius: theme.radii.lg)
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(globalIndex) * 0.02), value: appeared)
    }
}

#Preview {
    ContentView().kitoTheme(.neon)
}
