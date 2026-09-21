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
        KitoCatalogSection(title: "Commerce", entries: [
            KitoCatalogEntry("Cart", "Fly-to-cart animation, cart state", systemImage: "cart.fill") { CartDemo() },
            KitoCatalogEntry("Order Tracking", "Self-refreshing status + simulator", systemImage: "shippingbox.fill") { OrderTrackingDemo() },
        ]),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Kito").font(theme.typography.displayMedium)
                        Text("Every kit in this ecosystem, live and interactive.")
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                    }
                    .padding(.vertical, theme.spacing.xs)
                }
                ForEach(sections) { section in
                    Section(section.title) {
                        ForEach(section.entries) { entry in
                            NavigationLink(destination: entry.destination) {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(entry.title).font(theme.typography.bodyEmphasized)
                                        Text(entry.subtitle)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                                    }
                                } icon: {
                                    Image(systemName: entry.systemImage)
                                        .foregroundStyle(theme.colors.primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("KitoSample")
        }
    }
}

#Preview {
    ContentView().autoKitoTheme()
}
