//
//  SettingsKitSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoSettings

// MARK: - Shared data

private let settingsKitEmail = "wycliff@wyksoftsinc.com"
private let settingsKitSite = URL(string: "https://wyksoftsinc.com")!

private let settingsKitLicenses: [KitoLicense] = [
    KitoLicense("KitoCore", license: "MIT", url: URL(string: "https://github.com/WykSofts-Inc/KitoCore"),
                text: "MIT License\n\nCopyright (c) 2025-2026 wyksoftsinc.com\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software…"),
    KitoLicense("KitoSettings", license: "MIT", url: URL(string: "https://github.com/WykSofts-Inc/KitoSettings")),
    KitoLicense("KitoSearch", license: "MIT", url: URL(string: "https://github.com/WykSofts-Inc/KitoSearch")),
    KitoLicense("swift-collections", license: "Apache 2.0", url: URL(string: "https://github.com/apple/swift-collections")),
]

private let settingsKitTopics: [KitoNotificationTopic] = [
    KitoNotificationTopic("orders", title: "Order updates", subtitle: "Packed, on the way, delivered",
                          systemImage: "shippingbox.fill", color: .orange, channels: [.push, .sms]),
    KitoNotificationTopic("messages", title: "Messages", systemImage: "bubble.left.and.bubble.right.fill",
                          color: .green, channels: [.push]),
    KitoNotificationTopic("offers", title: "Offers and news", systemImage: "tag.fill", color: .pink,
                          isOn: false, channels: [.email]),
    KitoNotificationTopic("security", title: "Security alerts", subtitle: "New sign-ins, password changes",
                          systemImage: "lock.shield.fill", color: .blue, channels: [.push, .email]),
]

private let settingsKitPrivacy: [KitoPrivacyToggle] = [
    KitoPrivacyToggle("ads", title: "Personalised ads", subtitle: "Use what you browse to pick ads",
                      systemImage: "megaphone.fill", color: .orange),
    KitoPrivacyToggle("analytics", title: "Share usage data", subtitle: "Anonymous, helps us fix bugs",
                      systemImage: "chart.bar.fill", color: .blue, isOn: true),
    KitoPrivacyToggle("location", title: "Precise location", subtitle: "For faster delivery estimates",
                      systemImage: "location.fill", color: .green, isOn: true),
    KitoPrivacyToggle("status", title: "Show when I'm online", systemImage: "circle.fill", color: .teal),
]

private let settingsKitIcons: [KitoAppIconOption] = [
    KitoAppIconOption("Default", alternateIconName: nil, colors: [.blue, .indigo], systemImage: "square.stack.3d.up.fill"),
    KitoAppIconOption("Sunset", alternateIconName: "AppIcon-Sunset", colors: [.orange, .pink], systemImage: "sun.horizon.fill"),
    KitoAppIconOption("Savannah", alternateIconName: "AppIcon-Savannah", colors: [.yellow, .green], systemImage: "leaf.fill"),
    KitoAppIconOption("Night", alternateIconName: "AppIcon-Night", colors: [Color(white: 0.25), .black], systemImage: "moon.stars.fill"),
]

/// A preview-sized frame for a full, scrolling settings list inside the gallery's scroll view.
private struct SettingsKitFrame<Content: View>: View {
    var height: CGFloat = 520
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack { content() }
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.primary.opacity(0.12), lineWidth: 1))
    }
}

// MARK: - Lists and styles

private struct SettingsKitFullScreen: View {
    @State private var haptics = true
    @State private var sounds = false
    @State private var mode = KitoAppearanceMode.system
    @State private var accent = "blue"
    @State private var language = "sw"
    @State private var topics = settingsKitTopics
    @State private var quiet = KitoSettingsQuietHours()

    var body: some View {
        NavigationStack {
            KitoSettingsList(style: .insetGrouped) {
                KitoSettingsProfileHeader(name: "Wycliff N", detail: settingsKitEmail, plan: "Kito Pro",
                                          isVerified: true, onEdit: {})
            } sections: {
                KitoSettingsSection("General") {
                    KitoNavigationRow("Appearance", systemImage: "paintbrush.fill", color: .purple, value: mode.title) {
                        KitoAppearanceSettings(mode: $mode, accent: $accent)
                    }
                    .keywords("dark", "theme", "colour")
                    KitoNavigationRow("Notifications", systemImage: "bell.badge.fill", color: .red) {
                        KitoNotificationSettings(topics: $topics, quietHours: $quiet)
                    }
                    .badge(.count(3))
                    KitoNavigationRow("Language", systemImage: "globe", color: .indigo,
                                      value: KitoLanguage.common.first { $0.code == language }?.nativeName) {
                        KitoLanguagePicker(selection: $language)
                    }
                }
                KitoSettingsSection("Feel") {
                    KitoToggleRow("Haptics", systemImage: "hand.tap.fill", color: .pink, isOn: $haptics)
                        .keywords("vibration")
                    KitoToggleRow("Sounds", systemImage: "speaker.wave.2.fill", color: .orange, isOn: $sounds)
                }
                KitoSettingsSection("Support") {
                    KitoLinkRow("Help centre", systemImage: "questionmark.circle.fill", color: .teal, url: settingsKitSite)
                    KitoNavigationRow("About", systemImage: "info.circle.fill", color: .gray) {
                        KitoAboutScreen(appName: "Kito", tagline: "Every kit, live.", iconSymbol: "square.stack.3d.up.fill",
                                        version: KitoAppVersion(version: "1.4.2", build: "318"),
                                        licenses: settingsKitLicenses, copyright: "© 2026 WykSofts")
                    }
                }
                KitoSettingsSection.account(email: settingsKitEmail, onSignOut: {}, onDeleteAccount: {})
            }
            .navigationTitle("Settings")
        }
    }
}

private struct SettingsKitStyleSwitcher: View {
    @State private var style = KitoSettingsStyle.bold
    @State private var wifi = true
    @State private var bluetooth = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("Style", selection: $style.animation(.snappy)) {
                ForEach(KitoSettingsStyle.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            KitoSettingsSection("Connections") {
                KitoToggleRow("Wi-Fi", systemImage: "wifi", color: .blue, subtitle: "Home 5G", isOn: $wifi)
                KitoToggleRow("Bluetooth", systemImage: "wave.3.right", color: .indigo, isOn: $bluetooth)
                KitoNavigationRow("Mobile data", systemImage: "antenna.radiowaves.left.and.right", color: .green,
                                  value: "Safaricom") { Text("Mobile data") }
            }
            KitoSettingsSection("Money", footer: "Payments are protected with Face ID.") {
                KitoNavigationRow("M-Pesa", systemImage: "banknote.fill", color: .green, value: "Linked") { Text("M-Pesa") }
                KitoNavigationRow("Cards", systemImage: "creditcard.fill", color: .orange, value: "2") { Text("Cards") }
            }
        }
        .kitoSettingsStyle(style)
    }
}

private struct SettingsKitSearchSample: View {
    @State private var dark = false
    @State private var saver = true

    var body: some View {
        SettingsKitFrame {
            KitoSettingsList(style: .cards, searchPrompt: "Try “pay”, “dark” or “vibration”") {
                KitoSettingsSection("Display") {
                    KitoToggleRow("Dark mode", systemImage: "moon.fill", color: .purple, isOn: $dark)
                    KitoNavigationRow("Text size", systemImage: "textformat.size", color: .blue, value: "Default") { Text("Text size") }
                        .keywords("font", "bigger")
                }
                KitoSettingsSection("Payments") {
                    KitoNavigationRow("M-Pesa", systemImage: "banknote.fill", color: .green) { Text("M-Pesa") }
                        .keywords("pay", "money", "mobile money")
                    KitoNavigationRow("Cards", systemImage: "creditcard.fill", color: .orange) { Text("Cards") }
                        .keywords("pay", "visa")
                }
                KitoSettingsSection("Data") {
                    KitoToggleRow("Data saver", systemImage: "arrow.down.circle.fill", color: .teal,
                                  subtitle: "Lighter images on mobile data", isOn: $saver)
                    KitoNavigationRow("Haptics", systemImage: "hand.tap.fill", color: .pink) { Text("Haptics") }
                        .keywords("vibration", "feel")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SettingsKitBadgesSample: View {
    var body: some View {
        KitoSettingsSection("Badges and values") {
            KitoNavigationRow("What's new", systemImage: "sparkles", color: .orange) { Text("What's new") }
                .badge(.new)
            KitoNavigationRow("Messages", systemImage: "bubble.left.fill", color: .green) { Text("Messages") }
                .badge(.count(12))
            KitoNavigationRow("Software update", systemImage: "gear.badge", color: .gray, value: "iOS 27.1") { Text("Update") }
                .badge(.dot)
            KitoNavigationRow("Labs", systemImage: "flask.fill", color: .purple) { Text("Labs") }
                .badge(.text("Beta"))
            KitoValueRow("Account ID", systemImage: "number", color: .blue, value: "WYK-0042", isCopyable: true)
            KitoNavigationRow("Family sharing", systemImage: "person.3.fill", color: .teal, subtitle: "Coming soon") { Text("") }
                .rowDisabled()
        }
    }
}

// MARK: - Rows

private struct SettingsKitPickersSample: View {
    private enum Units: String, CaseIterable { case metric, imperial }
    @State private var units = Units.metric
    @State private var currency = "KES"
    @State private var start = "home"
    @State private var map = "standard"

    var body: some View {
        VStack(spacing: 24) {
            KitoSettingsSection("Menu and sheet") {
                KitoPickerRow("Currency", systemImage: "banknote.fill", color: .green, selection: $currency,
                              options: [KitoPickerOption("Kenyan shilling", value: "KES"),
                                        KitoPickerOption("US dollar", value: "USD"),
                                        KitoPickerOption("Euro", value: "EUR")])
                KitoPickerRow("Open on", systemImage: "house.fill", color: .blue, selection: $start,
                              options: [KitoPickerOption("Home", value: "home", systemImage: "house"),
                                        KitoPickerOption("Search", value: "search", systemImage: "magnifyingglass"),
                                        KitoPickerOption("Orders", value: "orders", systemImage: "bag")],
                              style: .sheet)
            }
            KitoSettingsSection("Segmented") {
                KitoPickerRow("Units", systemImage: "ruler.fill", color: .orange, selection: $units,
                              options: Units.allCases.map { KitoPickerOption($0.rawValue.capitalized, value: $0) },
                              style: .segmented)
            }
            KitoSettingsSection("Inline") {
                KitoPickerRow("Map style", systemImage: "map.fill", color: .teal, selection: $map,
                              options: [KitoPickerOption("Standard", value: "standard", subtitle: "Roads and places"),
                                        KitoPickerOption("Satellite", value: "satellite", subtitle: "Photos from above"),
                                        KitoPickerOption("Hybrid", value: "hybrid", subtitle: "Both at once")],
                              style: .inline)
            }
        }
    }
}

private struct SettingsKitStepperSliderSample: View {
    @State private var reminders = 2
    @State private var volume = 0.6
    @State private var radius = 5.0

    var body: some View {
        KitoSettingsSection("Adjust") {
            KitoStepperRow("Daily reminders", systemImage: "bell.fill", color: .red, value: $reminders, in: 0...8) {
                $0 == 0 ? "Off" : "\($0)"
            }
            KitoSliderRow("Volume", systemImage: "speaker.wave.2.fill", color: .pink, value: $volume,
                          minimumSymbol: "speaker.fill", maximumSymbol: "speaker.wave.3.fill")
            KitoSliderRow("Delivery radius", systemImage: "scope", color: .indigo, value: $radius, in: 1...20, step: 1) {
                "\(Int($0)) km"
            }
        }
        .kitoSettingsStyle(.cards)
    }
}

private struct SettingsKitActionsSample: View {
    @State private var cleared = false

    var body: some View {
        VStack(spacing: 24) {
            KitoSettingsSection("Help") {
                KitoLinkRow("Help centre", systemImage: "questionmark.circle.fill", color: .teal, url: settingsKitSite)
                KitoLinkRow("Terms", systemImage: "doc.text.fill", color: .gray, value: "wyksoftsinc.com", url: settingsKitSite)
                KitoInfoRow("Links open in Safari.")
            }
            KitoSettingsSection("Storage", footer: cleared ? "Cache cleared." : nil) {
                KitoActionRow("Clear cache", systemImage: "sparkles", color: .purple,
                              confirmation: "Clear 1.4 GB of cached images?") { withAnimation { cleared = true } }
                KitoActionRow("Reset all settings", systemImage: "arrow.counterclockwise", role: .destructive,
                              confirmation: "Put every setting back to how it came?") {}
            }
        }
        .kitoSettingsStyle(.minimal)
    }
}

// MARK: - Profile and account

private struct SettingsKitProfileSample: View {
    let layout: KitoSettingsProfileHeader.Layout

    var body: some View {
        KitoSettingsProfileHeader(name: "Wycliff N", detail: settingsKitEmail, plan: "Kito Pro",
                                  isVerified: true, layout: layout, onEdit: {})
    }
}

private struct SettingsKitPlanSample: View {
    @State private var upgraded = false

    var body: some View {
        KitoPlanCard(plan: upgraded ? "Kito Pro" : "Kito Free",
                     price: upgraded ? "KES 499 / month" : "Free forever",
                     renewal: upgraded ? "Renews 24 October" : nil,
                     perks: upgraded ? ["Every kit, unlocked", "Priority support", "No ads"] : ["Core kits", "Community support"],
                     actionTitle: upgraded ? "Manage plan" : "Upgrade to Pro",
                     tint: upgraded ? .purple : .blue) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { upgraded.toggle() }
        }
    }
}

private struct SettingsKitAccountSample: View {
    @State private var signedOut = false

    var body: some View {
        VStack(spacing: 12) {
            KitoSettingsSection.account(email: settingsKitEmail, phone: "+254 712 345 678",
                                        onChangePassword: {}, onSignOut: { signedOut = true }, onDeleteAccount: {})
            if signedOut {
                Label("Signed out", systemImage: "checkmark.circle.fill").font(.caption).foregroundStyle(.secondary)
            }
        }
        .kitoSettingsStyle(.bold)
    }
}

// MARK: - Ready-made screens

private struct SettingsKitAppearanceScreen: View {
    @State private var mode = KitoAppearanceMode.system
    @State private var accent = "purple"
    @State private var textScale = 1.0

    var body: some View {
        NavigationStack {
            KitoAppearanceSettings(mode: $mode, accent: $accent, appIcons: settingsKitIcons, textScale: $textScale)
        }
    }
}

private struct SettingsKitNotificationsScreen: View {
    @State private var topics = settingsKitTopics
    @State private var quiet = KitoSettingsQuietHours()
    @State private var allowed = false

    var body: some View {
        NavigationStack {
            KitoNotificationSettings(topics: $topics, quietHours: $quiet, channels: [.push, .email, .sms],
                                     isSystemAllowed: allowed, onOpenSystemSettings: { withAnimation { allowed = true } })
        }
        .kitoSettingsStyle(.cards)
    }
}

private struct SettingsKitPrivacyScreen: View {
    @State private var toggles = settingsKitPrivacy
    @State private var deleting = false

    var body: some View {
        NavigationStack {
            KitoPrivacySettings(toggles: $toggles, policyURL: settingsKitSite,
                                onExportData: {
                                    try? await Task.sleep(for: .seconds(1.5))
                                    return settingsKitSite
                                },
                                onDeleteData: {}, onDeleteAccount: { deleting = true })
        }
        .sheet(isPresented: $deleting) {
            KitoDeleteAccountFlow(onDelete: { _ in try await Task.sleep(for: .seconds(1)) },
                                  onFinish: { deleting = false }, onCancel: { deleting = false })
        }
    }
}

private struct SettingsKitLanguageScreen: View {
    @State private var language = "sw"

    var body: some View {
        NavigationStack {
            KitoLanguagePicker(selection: $language, suggested: KitoLanguage.common.filter { ["sw", "en"].contains($0.code) },
                               footer: "The app switches language straight away.")
        }
        .kitoSettingsStyle(.insetGrouped)
    }
}

private struct SettingsKitAboutScreen: View {
    var body: some View {
        NavigationStack {
            KitoAboutScreen(appName: "Kito", tagline: "Every kit, live, with the code behind it.",
                            iconColors: [.indigo, .purple], iconSymbol: "square.stack.3d.up.fill",
                            version: KitoAppVersion(version: "1.4.2", build: "318"),
                            links: [KitoAboutLink("Website", systemImage: "globe", color: .blue, url: settingsKitSite),
                                    KitoAboutLink("Rate Kito", systemImage: "star.fill", color: .orange, url: settingsKitSite),
                                    KitoAboutLink("Contact support", systemImage: "envelope.fill", color: .green, url: settingsKitSite)],
                            licenses: settingsKitLicenses, copyright: "© 2026 WykSofts Inc.")
        }
    }
}

private struct SettingsKitDeleteScreen: View {
    @State private var runs = 0

    var body: some View {
        KitoDeleteAccountFlow(onDelete: { _ in try await Task.sleep(for: .seconds(1.2)) },
                              onFinish: { runs += 1 }, onCancel: { runs += 1 })
            .id(runs)
    }
}

// MARK: - Storage and logic

private extension KitoSettingKey where Value == Bool {
    static let settingsKitHaptics = KitoSettingKey("haptics", default: true)
}

private extension KitoSettingKey where Value == Int {
    static let settingsKitReminders = KitoSettingKey("reminders", default: 2)
}

private extension KitoSettingKey where Value == KitoAppearanceMode {
    static let settingsKitMode = KitoSettingKey("mode", default: .system)
}

private let settingsKitStore = KitoSettingsStore(namespace: "kito.devkit.settingsKit")

private struct SettingsKitStorageSample: View {
    @KitoSetting(.settingsKitHaptics, store: settingsKitStore) private var haptics
    @KitoSetting(.settingsKitReminders, store: settingsKitStore) private var reminders
    @KitoSetting(.settingsKitMode, store: settingsKitStore) private var mode

    var body: some View {
        VStack(spacing: 16) {
            KitoSettingsSection("Saved in UserDefaults", footer: "Leave and come back: the values stay.") {
                KitoToggleRow("Haptics", systemImage: "hand.tap.fill", color: .pink, isOn: $haptics)
                KitoStepperRow("Reminders", systemImage: "bell.fill", color: .red, value: $reminders, in: 0...8)
                KitoPickerRow("Appearance", systemImage: "circle.lefthalf.filled", color: .purple, selection: $mode,
                              options: KitoAppearanceMode.allCases.map { KitoPickerOption($0.title, value: $0) })
            }
            Button {
                withAnimation(.snappy) { settingsKitStore.resetAll() }
            } label: {
                Label("Reset to defaults", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct SettingsKitQuietHoursSample: View {
    @State private var quiet = KitoSettingsQuietHours(start: KitoTimeOfDay(hour: 22, minute: 30),
                                                      end: KitoTimeOfDay(hour: 6, minute: 45))

    var body: some View {
        KitoSettingsSection("Do not disturb") {
            KitoCustomRow("Quiet hours") { KitoQuietHoursEditor(quietHours: $quiet) }
        }
        .kitoSettingsTint(.indigo)
    }
}

// MARK: - Catalog

enum SettingsKitSamples {
    static let sections: [KitSection] = [lists, rows, identity, screens, storage]

    static let lists = KitSection("Lists and styles", symbol: "list.bullet.rectangle.fill", [
        KitSample("A whole settings screen", "Profile header, search, sections, badges and the ready-made screens behind each row.", code: """
        KitoSettingsList(style: .insetGrouped) {
            KitoSettingsProfileHeader(name: "Wycliff N", detail: email, plan: "Kito Pro", onEdit: {})
        } sections: {
            KitoSettingsSection("General") {
                KitoNavigationRow("Appearance", systemImage: "paintbrush.fill", color: .purple, value: mode.title) {
                    KitoAppearanceSettings(mode: $mode, accent: $accent)
                }
                KitoNavigationRow("Notifications", systemImage: "bell.badge.fill", color: .red) { … }
                    .badge(.count(3))
            }
            KitoSettingsSection.account(email: email, onSignOut: {}, onDeleteAccount: {})
        }
        """) { ModalStage { SettingsKitFullScreen() } },
        KitSample("Four styles", "Inset grouped, cards, minimal and bold, switched live on the same rows.", code: """
        KitoSettingsSection("Connections") {
            KitoToggleRow("Wi-Fi", systemImage: "wifi", color: .blue, subtitle: "Home 5G", isOn: $wifi)
            KitoNavigationRow("Mobile data", systemImage: "antenna.radiowaves.left.and.right",
                              color: .green, value: "Safaricom") { MobileData() }
        }
        .kitoSettingsStyle(.bold)   // .insetGrouped, .cards, .minimal
        """) { SettingsKitStyleSwitcher() },
        KitSample("Search with keywords", "Filters by titles, subtitles and hidden keywords; the match is highlighted.", code: """
        KitoSettingsList(style: .cards, searchPrompt: "Search settings") {
            KitoSettingsSection("Payments") {
                KitoNavigationRow("M-Pesa", systemImage: "banknote.fill", color: .green) { MPesa() }
                    .keywords("pay", "money", "mobile money")
            }
        }
        """) { SettingsKitSearchSample() },
        KitSample("Badges and values", "New, a count, a dot and a label; a copyable value; a disabled row.", code: """
        KitoNavigationRow("What's new", systemImage: "sparkles", color: .orange) { WhatsNew() }.badge(.new)
        KitoNavigationRow("Messages", systemImage: "bubble.left.fill", color: .green) { … }.badge(.count(12))
        KitoValueRow("Account ID", value: "WYK-0042", isCopyable: true)
        KitoNavigationRow("Family sharing", subtitle: "Coming soon") { … }.rowDisabled()
        """) { SettingsKitBadgesSample() },
    ])

    static let rows = KitSection("Rows", symbol: "slider.horizontal.3", [
        KitSample("Pickers", "A menu, a sheet, a sliding segmented control and inline checkmarks.", code: """
        KitoPickerRow("Currency", systemImage: "banknote.fill", color: .green, selection: $currency,
                      options: [KitoPickerOption("Kenyan shilling", value: "KES"), …])          // .menu
        KitoPickerRow("Open on", …, style: .sheet)
        KitoPickerRow("Units", …, style: .segmented)
        KitoPickerRow("Map style", …, style: .inline)
        """) { SettingsKitPickersSample() },
        KitSample("Stepper and sliders", "A capsule stepper with a rolling number, and sliders with their value.", code: """
        KitoStepperRow("Daily reminders", systemImage: "bell.fill", color: .red, value: $reminders, in: 0...8) {
            $0 == 0 ? "Off" : "\\($0)"
        }
        KitoSliderRow("Volume", systemImage: "speaker.wave.2.fill", value: $volume,
                      minimumSymbol: "speaker.fill", maximumSymbol: "speaker.wave.3.fill")
        """) { SettingsKitStepperSliderSample() },
        KitSample("Links, info and actions", "Links out, an info line, and actions that ask first, in the minimal style.", code: """
        KitoLinkRow("Help centre", systemImage: "questionmark.circle.fill", color: .teal, url: help)
        KitoInfoRow("Links open in Safari.")
        KitoActionRow("Reset all settings", systemImage: "arrow.counterclockwise", role: .destructive,
                      confirmation: "Put every setting back to how it came?") { reset() }
        """) { SettingsKitActionsSample() },
    ])

    static let identity = KitSection("Profile and account", symbol: "person.crop.circle.fill", [
        KitSample("Profile header", "Initials on a gradient, a camera badge, verified name, plan badge and Edit profile.", code: """
        KitoSettingsProfileHeader(name: "Wycliff N", detail: "wycliff@wyksoftsinc.com", plan: "Kito Pro",
                                  isVerified: true, onEdit: { editProfile() })
        """) { SettingsKitProfileSample(layout: .row) },
        KitSample("Centred profile", "The same header with a large avatar, for the top of a profile tab.", code: """
        KitoSettingsProfileHeader(name: "Wycliff N", detail: email, plan: "Kito Pro", layout: .centered, onEdit: {})
        """) { SettingsKitProfileSample(layout: .centered) },
        KitSample("Plan card", "The current plan with perks and a sheen; tap to upgrade and back.", code: """
        KitoPlanCard(plan: "Kito Pro", price: "KES 499 / month", renewal: "Renews 24 October",
                     perks: ["Every kit, unlocked", "Priority support", "No ads"], actionTitle: "Manage plan") { … }
        """) { SettingsKitPlanSample() },
        KitSample("Account rows", "Email, phone, change password, sign out (asks first) and delete, in the bold style.", code: """
        KitoSettingsSection.account(email: email, phone: "+254 712 345 678",
                                    onChangePassword: {}, onSignOut: { signOut() }, onDeleteAccount: {})
        """) { SettingsKitAccountSample() },
    ])
}

extension SettingsKitSamples {
    static let screens = KitSection("Ready-made screens", symbol: "rectangle.stack.fill", [
        KitSample("Appearance", "Light, dark or system on phone previews, accents, app icons and text size.", code: """
        KitoAppearanceSettings(mode: $mode, accent: $accent,
                               appIcons: [KitoAppIconOption("Default", alternateIconName: nil),
                                          KitoAppIconOption("Sunset", alternateIconName: "AppIcon-Sunset")],
                               textScale: $textScale)
        """) { ModalStage { SettingsKitAppearanceScreen() } },
        KitSample("Notifications", "Topics with channel chips, quiet hours on a dial, and an off-in-Settings banner.", code: """
        KitoNotificationSettings(topics: $topics, quietHours: $quietHours,
                                 channels: [.push, .email, .sms], isSystemAllowed: authorised)
        """) { ModalStage { SettingsKitNotificationsScreen() } },
        KitSample("Privacy", "Sharing switches, a data export that prepares then shares, and delete rows.", code: """
        KitoPrivacySettings(toggles: $privacy, policyURL: policy,
                            onExportData: { await api.exportData() },
                            onDeleteData: { … }, onDeleteAccount: { deleting = true })
        """) { ModalStage { SettingsKitPrivacyScreen() } },
        KitSample("Language", "Searchable, by each language's own name, suggested ones first.", code: """
        KitoLanguagePicker(selection: $language, footer: "The app switches language straight away.")
        """) { ModalStage { SettingsKitLanguageScreen() } },
        KitSample("About", "Icon, a tap-to-copy version, links, acknowledgements and Made in Nairobi.", code: """
        KitoAboutScreen(appName: "Kito", tagline: "Every kit, live.",
                        links: [KitoAboutLink("Website", systemImage: "globe", url: site)],
                        licenses: [KitoLicense("KitoCore", license: "MIT")], copyright: "© 2026 WykSofts Inc.")
        """) { ModalStage { SettingsKitAboutScreen() } },
        KitSample("Delete account", "A reason, then type DELETE letter by letter, then a warm goodbye.", code: """
        KitoDeleteAccountFlow(onDelete: { request in try await api.deleteAccount(reason: request.reason?.id) },
                              onFinish: { signOut() }, onCancel: { deleting = false })
        """) { ModalStage { SettingsKitDeleteScreen() } },
    ])

    static let storage = KitSection("Storage and logic", symbol: "externaldrive.fill", [
        KitSample("Saved settings", "@KitoSetting keeps typed values in UserDefaults; reset puts them all back.", code: """
        extension KitoSettingKey where Value == Bool {
            static let haptics = KitoSettingKey("haptics", default: true)
        }

        @KitoSetting(.haptics, store: store) private var haptics
        KitoToggleRow("Haptics", systemImage: "hand.tap.fill", color: .pink, isOn: $haptics)
        store.resetAll()
        """) { SettingsKitStorageSample() },
        KitSample("Quiet hours", "A 24-hour dial across midnight, with whether it's quiet right now.", code: """
        let quiet = KitoSettingsQuietHours(start: .init(hour: 22, minute: 30), end: .init(hour: 6, minute: 45))
        quiet.isQuiet(at: .now)          // true at 23:00 and 06:00
        KitoQuietHoursEditor(quietHours: $quiet)
        """) { SettingsKitQuietHoursSample() },
    ])
}

/// KitoSettings: settings lists, rows, profile and plan, and ready-made settings screens.
struct SettingsKitGallery: View {
    static var count: Int { KitGallery.count(SettingsKitSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Settings Screens",
            sections: SettingsKitSamples.sections,
            footnote: "Requires `import KitoSettings`.",
            searchHint: "Try “appearance”, “search”, “quiet hours” or “delete”."
        )
    }
}
