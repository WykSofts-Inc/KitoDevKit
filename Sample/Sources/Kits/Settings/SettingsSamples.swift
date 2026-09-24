//
//  SettingsSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import UIKit
import KitoCore

// MARK: - Shared pieces

/// A rounded group of rows, like an inset grouped list, that works inside a scroll view.
private struct SetGroup<Content: View>: View {
    var title: String? = nil
    var footer: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title).font(.footnote.weight(.semibold)).foregroundStyle(.secondary).textCase(.uppercase).padding(.leading, 16)
            }
            VStack(spacing: 0) { content() }
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            if let footer {
                Text(footer).font(.caption).foregroundStyle(.secondary).padding(.horizontal, 16)
            }
        }
    }
}

private struct SetIcon: View {
    let symbol: String
    let color: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 30, height: 30)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct SetRow<Accessory: View>: View {
    let symbol: String
    let color: Color
    let title: String
    var showsDivider = true
    @ViewBuilder let accessory: () -> Accessory

    var body: some View {
        HStack(spacing: 14) {
            SetIcon(symbol: symbol, color: color)
            Text(title).font(.body)
            Spacer(minLength: 8)
            accessory()
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            if showsDivider { Divider().padding(.leading, 60) }
        }
        .contentShape(Rectangle())
    }
}

private struct SetChevron: View {
    var value: String? = nil
    var body: some View {
        HStack(spacing: 6) {
            if let value { Text(value).foregroundStyle(.secondary) }
            Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
        }
    }
}

private let setPresetColors: [Color] = [.blue, .indigo, .purple, .pink, .red, .orange, .green, .teal]

/// `Color` isn't reliably `Equatable` across dynamic colours, so compare resolved components.
private func setColorsMatch(_ a: Color, _ b: Color) -> Bool {
    UIColor(a).cgColor.components == UIColor(b).cgColor.components
}

// MARK: - This app's settings (live)

private struct SetThemeSample: View {
    @Environment(KitoAppSettingsViewModel.self) private var settings
    @Environment(\.kitoTheme) private var theme

    var body: some View {
        @Bindable var settings = settings
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                ForEach(KitoAppSettingsViewModel.ThemeMode.allCases) { mode in
                    Button { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { settings.themeMode = mode } } label: {
                        VStack(spacing: 8) {
                            themePreview(mode)
                                .frame(height: 96)
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(settings.themeMode == mode ? theme.colors.primary : Color.primary.opacity(0.12), lineWidth: settings.themeMode == mode ? 3 : 1))
                            Text(mode.label).font(.caption.weight(settings.themeMode == mode ? .bold : .medium))
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(mode.label) theme")
                    .accessibilityAddTraits(settings.themeMode == mode ? .isSelected : [])
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Primary colour").font(.subheadline.weight(.semibold))
                HStack(spacing: 10) {
                    ForEach(setPresetColors, id: \.self) { color in
                        Button { withAnimation(.spring) { settings.primaryColor = color } } label: {
                            Circle().fill(color.gradient).frame(width: 32, height: 32)
                                .overlay {
                                    if setColorsMatch(settings.primaryColor, color) {
                                        Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white)
                                    }
                                }
                                .overlay(Circle().stroke(Color.primary.opacity(setColorsMatch(settings.primaryColor, color) ? 0.8 : 0), lineWidth: 2).padding(-4))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Colour \(setPresetColors.firstIndex(of: color).map { $0 + 1 } ?? 0)")
                    }
                }
                ColorPicker("Any colour", selection: $settings.primaryColor, supportsOpacity: false)
                    .font(.subheadline)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            Label("Changes re-theme every kit in the app at once.", systemImage: "paintbrush.pointed.fill")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private func themePreview(_ mode: KitoAppSettingsViewModel.ThemeMode) -> some View {
        let background: [Color] = {
            switch mode {
            case .system: return [Color.white, Color(white: 0.1)]
            case .light: return [Color.white, Color(white: 0.94)]
            case .dark: return [Color(white: 0.16), Color(white: 0.08)]
            case .neon: return [Color(red: 0.08, green: 0.05, blue: 0.2), Color(red: 0.02, green: 0.02, blue: 0.08)]
            }
        }()
        let ink = mode == .light ? Color.black.opacity(0.7) : Color.white.opacity(0.8)
        return ZStack(alignment: .topLeading) {
            if mode == .system {
                HStack(spacing: 0) { Color.white; Color(white: 0.1) }
            } else {
                LinearGradient(colors: background, startPoint: .top, endPoint: .bottom)
            }
            VStack(alignment: .leading, spacing: 5) {
                Capsule().fill(mode == .neon ? KitoColors.neon.primary : settings.primaryColor).frame(width: 30, height: 6)
                Capsule().fill(ink.opacity(0.5)).frame(width: 40, height: 4)
                Capsule().fill(ink.opacity(0.3)).frame(width: 26, height: 4)
                Spacer()
                RoundedRectangle(cornerRadius: 4).fill(mode == .neon ? KitoColors.neon.primary.opacity(0.8) : settings.primaryColor.opacity(0.8)).frame(height: 12)
                    .shadow(color: mode == .neon ? KitoColors.neon.primary : .clear, radius: 6)
            }
            .padding(9)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct SetTextAndShapeSample: View {
    @Environment(KitoAppSettingsViewModel.self) private var settings
    @Environment(\.kitoTheme) private var theme

    var body: some View {
        @Bindable var settings = settings
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Text size").font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(Int(settings.fontScale * 100))%").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary).contentTransition(.numericText())
                }
                Slider(value: $settings.fontScale, in: 0.8...1.5, step: 0.05) { Text("Text size") } minimumValueLabel: {
                    Text("A").font(.caption)
                } maximumValueLabel: {
                    Text("A").font(.title2)
                }
                .tint(theme.colors.primary)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Habari, Wycliff").font(theme.typography.titleLarge)
                    Text("This is body text at the current size, across every kit.").font(theme.typography.body).foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Roundness").font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(String(format: "%.1f×", settings.cornerRadiusScale)).font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                }
                Slider(value: $settings.cornerRadiusScale, in: 0...2, step: 0.1).tint(theme.colors.primary)
                HStack(spacing: 12) {
                    ForEach(Array([theme.radii.sm, theme.radii.md, theme.radii.lg, theme.radii.xl].enumerated()), id: \.offset) { _, radius in
                        RoundedRectangle(cornerRadius: radius, style: .continuous).fill(theme.colors.primary.gradient).frame(height: 48)
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: settings.cornerRadiusScale)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            Button(role: .destructive) { withAnimation(.spring) { settings.reset() } } label: {
                Label("Reset to defaults", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct SetAboutSample: View {
    @Environment(\.kitoTheme) private var theme

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 10) {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 76, height: 76)
                    .background(theme.colors.primary.gradient, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: theme.colors.primary.opacity(0.4), radius: 14, y: 6)
                Text("KitoDevKit").font(.title2.weight(.heavy))
                Text("Every Kito kit, live, with the code behind it.").font(.subheadline).foregroundStyle(.secondary)
            }
            SetGroup {
                SetRow(symbol: "shippingbox.fill", color: .indigo, title: "Kito version") { Text(Kito.version).foregroundStyle(.secondary).monospacedDigit() }
                SetRow(symbol: "square.grid.2x2.fill", color: .orange, title: "Architecture") { Text("MVVM").foregroundStyle(.secondary) }
                SetRow(symbol: "iphone", color: .blue, title: "Requires") { Text("iOS 17").foregroundStyle(.secondary) }
                SetRow(symbol: "person.fill", color: .green, title: "Made by", showsDivider: false) { Text("WykSofts, Nairobi").foregroundStyle(.secondary) }
            }
        }
    }
}

// MARK: - Settings screen designs

private struct SetProfileHeaderSample: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Text("WN")
                    .font(.title2.weight(.bold)).foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.fill").font(.caption2.weight(.bold)).foregroundStyle(.white)
                            .frame(width: 26, height: 26).background(Color.black, in: Circle())
                            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                    }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Wycliff N").font(.title3.weight(.bold))
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(.blue)
                    }
                    Text("wycliff@wyksoftsinc.com").font(.subheadline).foregroundStyle(.secondary)
                    Text("PRO").font(.caption2.weight(.heavy)).kerning(0.8).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing), in: Capsule())
                }
                Spacer()
            }
            HStack(spacing: 10) {
                stat("128", "Orders")
                stat("4.9", "Rating")
                stat("KES 12K", "Saved")
            }
            Button {} label: { Text("Edit profile").frame(maxWidth: .infinity) }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .padding(18)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline.monospacedDigit())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct SetGroupedSample: View {
    @State private var airplane = false
    @State private var notifications = true
    @State private var lowData = false

    var body: some View {
        VStack(spacing: 20) {
            SetGroup {
                SetRow(symbol: "airplane", color: .orange, title: "Airplane mode") { Toggle("", isOn: $airplane).labelsHidden() }
                SetRow(symbol: "wifi", color: .blue, title: "Wi-Fi") { SetChevron(value: airplane ? "Off" : "Nyumbani_5G") }
                SetRow(symbol: "antenna.radiowaves.left.and.right", color: .green, title: "Mobile data", showsDivider: false) { SetChevron(value: airplane ? "Off" : "Safari-Net") }
            }
            SetGroup(title: "App", footer: "Low data mode loads smaller images and pauses video autoplay.") {
                SetRow(symbol: "bell.badge.fill", color: .red, title: "Notifications") { Toggle("", isOn: $notifications).labelsHidden() }
                SetRow(symbol: "arrow.down.circle.fill", color: .teal, title: "Low data mode") { Toggle("", isOn: $lowData).labelsHidden() }
                SetRow(symbol: "globe", color: .indigo, title: "Language") { SetChevron(value: "Kiswahili") }
                SetRow(symbol: "banknote.fill", color: .green, title: "Currency", showsDivider: false) { SetChevron(value: "KES") }
            }
        }
        .animation(.snappy, value: airplane)
    }
}

private struct SetSecuritySample: View {
    @State private var faceID = true
    @State private var twoFactor = true
    @State private var passkey = false

    private var score: Double { (faceID ? 0.3 : 0) + (twoFactor ? 0.4 : 0) + (passkey ? 0.3 : 0) }
    private var tint: Color { score > 0.8 ? .green : (score > 0.4 ? .orange : .red) }

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().stroke(Color.primary.opacity(0.08), lineWidth: 10)
                    Circle().trim(from: 0, to: score).stroke(tint, style: StrokeStyle(lineWidth: 10, lineCap: .round)).rotationEffect(.degrees(-90))
                    Image(systemName: score > 0.8 ? "lock.shield.fill" : "exclamationmark.shield.fill").font(.title2).foregroundStyle(tint)
                        .contentTransition(.symbolEffect(.replace))
                }
                .frame(width: 76, height: 76)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Security score").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Text("\(Int(score * 100))%").font(.title.weight(.heavy).monospacedDigit()).contentTransition(.numericText())
                    Text(score > 0.8 ? "Your account is well protected" : "Turn on more protection").font(.caption).foregroundStyle(tint)
                }
                Spacer()
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: score)

            SetGroup(title: "Sign-in") {
                SetRow(symbol: "faceid", color: .green, title: "Face ID") { Toggle("", isOn: $faceID).labelsHidden() }
                SetRow(symbol: "key.fill", color: .blue, title: "Two-step via SMS") { Toggle("", isOn: $twoFactor).labelsHidden() }
                SetRow(symbol: "person.badge.key.fill", color: .purple, title: "Passkey", showsDivider: false) { Toggle("", isOn: $passkey).labelsHidden() }
            }
            SetGroup(title: "Devices") {
                SetRow(symbol: "iphone", color: .gray, title: "iPhone 17 Pro · this one") { Text("Now").foregroundStyle(.secondary) }
                SetRow(symbol: "laptopcomputer", color: .gray, title: "MacBook · Nairobi", showsDivider: false) { Text("2d ago").foregroundStyle(.secondary) }
            }
        }
    }
}

private struct SetNotificationsSample: View {
    @State private var orders = true
    @State private var offers = false
    @State private var quietHours = true
    @State private var quietStart = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var quietEnd = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var channel = 0

    var body: some View {
        VStack(spacing: 20) {
            SetGroup(title: "Tell me about") {
                SetRow(symbol: "shippingbox.fill", color: .orange, title: "Order updates") { Toggle("", isOn: $orders).labelsHidden() }
                SetRow(symbol: "tag.fill", color: .pink, title: "Offers and promo codes", showsDivider: false) { Toggle("", isOn: $offers).labelsHidden() }
            }
            SetGroup(title: "How") {
                Picker("Channel", selection: $channel) {
                    Text("Push").tag(0)
                    Text("SMS").tag(1)
                    Text("WhatsApp").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(12)
            }
            SetGroup(title: "Quiet hours", footer: quietHours ? "Nothing but delivery updates between these times." : nil) {
                SetRow(symbol: "moon.fill", color: .indigo, title: "Quiet hours", showsDivider: quietHours) { Toggle("", isOn: $quietHours.animation(.spring)).labelsHidden() }
                if quietHours {
                    DatePicker("From", selection: $quietStart, displayedComponents: .hourAndMinute).padding(.horizontal, 16).frame(minHeight: 48)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    Divider().padding(.leading, 16)
                    DatePicker("Until", selection: $quietEnd, displayedComponents: .hourAndMinute).padding(.horizontal, 16).frame(minHeight: 48)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

private struct SetLanguageSample: View {
    @State private var selected = "sw"
    private let languages: [(String, String, String, String)] = [
        ("en", "🇬🇧", "English", "English"), ("sw", "🇰🇪", "Kiswahili", "Swahili"), ("fr", "🇫🇷", "Français", "French"),
        ("am", "🇪🇹", "አማርኛ", "Amharic"), ("so", "🇸🇴", "Soomaali", "Somali"), ("ar", "🇸🇦", "العربية", "Arabic"),
    ]

    var body: some View {
        SetGroup(title: "Language", footer: "The app restarts in the new language.") {
            ForEach(Array(languages.enumerated()), id: \.offset) { index, language in
                Button { withAnimation(.snappy) { selected = language.0 } } label: {
                    HStack(spacing: 14) {
                        Text(language.1).font(.title2)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(language.2).font(.body).foregroundStyle(.primary)
                            Text(language.3).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if selected == language.0 {
                            Image(systemName: "checkmark.circle.fill").font(.title3).foregroundStyle(.blue).transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(minHeight: 56)
                    .contentShape(Rectangle())
                    .overlay(alignment: .bottom) { if index < languages.count - 1 { Divider().padding(.leading, 56) } }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected == language.0 ? .isSelected : [])
            }
        }
    }
}

private struct SetStorageSample: View {
    @State private var cache = 1.4
    @State private var clearing = false
    private let photos = 3.2
    private let messages = 1.1
    private let capacity = 8.0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(format: "%.1f GB", photos + messages + cache)).font(.title.weight(.heavy).monospacedDigit()).contentTransition(.numericText(value: cache))
                Text("of \(Int(capacity)) GB used").foregroundStyle(.secondary)
            }
            GeometryReader { proxy in
                HStack(spacing: 2) {
                    segment(.orange, photos, proxy.size.width)
                    segment(.green, messages, proxy.size.width)
                    segment(.purple, cache, proxy.size.width)
                    Spacer(minLength: 0)
                }
                .background(Color.primary.opacity(0.08))
                .clipShape(Capsule())
            }
            .frame(height: 16)
            HStack(spacing: 14) {
                legend(.orange, "Photos")
                legend(.green, "Messages")
                legend(.purple, "Cache")
            }
            Button {
                clearing = true
                withAnimation(.spring(response: 0.8, dampingFraction: 0.85)) { cache = 0.05 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { clearing = false }
            } label: {
                Label(clearing ? "Clearing…" : "Clear cache (\(String(format: "%.1f GB", cache)))", systemImage: "trash").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(cache < 0.1)
            if cache < 0.1 {
                Button("Fill it up again") { withAnimation(.spring) { cache = 1.4 } }.font(.caption.weight(.semibold)).frame(maxWidth: .infinity)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func segment(_ color: Color, _ value: Double, _ width: CGFloat) -> some View {
        Rectangle().fill(color.gradient).frame(width: max(0, width * value / capacity - 2))
    }

    private func legend(_ color: Color, _ title: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct SetSubscriptionSample: View {
    @State private var yearly = true

    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Kito Pro", systemImage: "crown.fill").font(.headline)
                    Spacer()
                    Text("ACTIVE").font(.caption2.weight(.heavy)).kerning(0.8).padding(.horizontal, 8).padding(.vertical, 4)
                        .background(.white.opacity(0.2), in: Capsule())
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(yearly ? "KES 4,990 / year" : "KES 499 / month").font(.title2.weight(.heavy)).contentTransition(.numericText())
                    Text("Renews on 24 September 2027").font(.caption).opacity(0.8)
                }
                HStack(spacing: -8) {
                    ForEach(["sparkles", "bolt.fill", "icloud.fill", "person.2.fill"], id: \.self) { symbol in
                        Image(systemName: symbol).font(.caption.weight(.bold)).frame(width: 30, height: 30).background(.white.opacity(0.22), in: Circle())
                            .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                    }
                    Text("4 perks").font(.caption.weight(.semibold)).padding(.leading, 16)
                }
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(LinearGradient(colors: [Color(red: 0.45, green: 0.25, blue: 0.95), Color(red: 0.85, green: 0.3, blue: 0.6)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: .purple.opacity(0.3), radius: 18, y: 10)
            Picker("Billing", selection: $yearly.animation(.snappy)) {
                Text("Monthly").tag(false)
                Text("Yearly · save 17%").tag(true)
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct SetDangerZoneSample: View {
    @State private var confirmsDelete = false
    @State private var outcome: String?

    var body: some View {
        VStack(spacing: 14) {
            SetGroup {
                Button { outcome = "Signed out of this iPhone" } label: {
                    SetRow(symbol: "rectangle.portrait.and.arrow.right", color: .gray, title: "Sign out") { EmptyView() }
                }
                .buttonStyle(.plain)
                Button { confirmsDelete = true } label: {
                    SetRow(symbol: "trash.fill", color: .red, title: "Delete account", showsDivider: false) { EmptyView() }
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
            if let outcome {
                Label(outcome, systemImage: "checkmark.circle.fill").font(.caption).foregroundStyle(.secondary).transition(.opacity)
            }
        }
        .animation(.easeOut, value: outcome)
        .confirmationDialog("Delete your account?", isPresented: $confirmsDelete, titleVisibility: .visible) {
            Button("Delete account and data", role: .destructive) { outcome = "Deletion scheduled. You have 30 days to change your mind." }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your orders, saved addresses and M-Pesa receipts will be removed after 30 days.")
        }
    }
}

private struct SetSearchSample: View {
    @State private var query = ""
    private let all: [(String, String, Color, String)] = [
        ("bell.badge.fill", "Notifications", .red, "Alerts, sounds, badges"), ("lock.fill", "Privacy", .blue, "Location, tracking, contacts"),
        ("faceid", "Face ID & passcode", .green, "Unlock, payments"), ("globe", "Language", .indigo, "Kiswahili, English"),
        ("banknote.fill", "Payments", .green, "M-Pesa, cards"), ("moon.fill", "Appearance", .purple, "Dark mode, text size"),
        ("arrow.down.circle.fill", "Data saver", .teal, "Images, video"), ("questionmark.circle.fill", "Help", .orange, "Chat with support"),
    ]

    private var results: [(String, String, Color, String)] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return all }
        return all.filter { $0.1.localizedCaseInsensitiveContains(q) || $0.3.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search settings", text: $query).textInputAutocapitalization(.never).autocorrectionDisabled()
                if !query.isEmpty {
                    Button { query = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }.buttonStyle(.plain)
                        .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color(.secondarySystemBackground), in: Capsule())
            SetGroup {
                if results.isEmpty {
                    Text("No settings for “\(query)”").font(.subheadline).foregroundStyle(.secondary).frame(maxWidth: .infinity, minHeight: 80)
                }
                ForEach(Array(results.enumerated()), id: \.element.1) { index, row in
                    HStack(spacing: 14) {
                        SetIcon(symbol: row.0, color: row.2)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(highlighted(row.1))
                            Text(row.3).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 16)
                    .frame(minHeight: 56)
                    .overlay(alignment: .bottom) { if index < results.count - 1 { Divider().padding(.leading, 60) } }
                }
            }
            .animation(.snappy, value: results.map(\.1))
            HStack(spacing: 6) {
                ForEach(["pay", "dark", "face"], id: \.self) { hint in
                    Button(hint) { query = hint }.font(.caption.weight(.semibold)).buttonStyle(.bordered).tint(.primary)
                }
            }
        }
    }

    private func highlighted(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        let q = query.trimmingCharacters(in: .whitespaces)
        if !q.isEmpty, let range = attributed.range(of: q, options: .caseInsensitive) {
            attributed[range].font = .body.bold()
            attributed[range].foregroundColor = .blue
        }
        return attributed
    }
}

private struct SetNeonSample: View {
    @State private var glow = true
    @State private var sounds = false
    @State private var intensity = 0.7
    private let neon = KitoColors.neon

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Arcade").font(.title2.weight(.heavy)).foregroundStyle(neon.onBackground)
            VStack(spacing: 0) {
                neonRow("sparkles", "Glow effects", $glow)
                Divider().overlay(neon.primary.opacity(0.2))
                neonRow("speaker.wave.2.fill", "Retro sounds", $sounds)
                Divider().overlay(neon.primary.opacity(0.2))
                VStack(alignment: .leading, spacing: 8) {
                    Text("Intensity").font(.subheadline.weight(.semibold)).foregroundStyle(neon.onBackground)
                    Slider(value: $intensity).tint(neon.primary)
                }
                .padding(16)
            }
            .kitoGlassCard(cornerRadius: 22, tint: neon.primary.opacity(glow ? 0.6 : 0))
            .kitoGlow(glow ? neon.primary : .clear, radius: 20 * intensity, intensity: 0.5 * intensity)
            .animation(.easeInOut(duration: 0.4), value: glow)
        }
        .padding(20)
        .background(LinearGradient(colors: [neon.background, Color(red: 0.08, green: 0.03, blue: 0.18)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .environment(\.colorScheme, .dark)
    }

    private func neonRow(_ symbol: String, _ title: String, _ isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol).foregroundStyle(neon.primary).frame(width: 30)
            Text(title).foregroundStyle(neon.onBackground)
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(neon.primary)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 54)
    }
}

private struct SetQuickSheetSample: View {
    @State private var showsSheet = false
    @State private var dark = false
    @State private var dataSaver = true
    @State private var location = 1

    var body: some View {
        MockAppScreen(title: "Karibu", tint: .teal) {
            Button { showsSheet = true } label: { Label("Quick settings", systemImage: "slider.horizontal.3").frame(maxWidth: .infinity) }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .sheet(isPresented: $showsSheet) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Quick settings").font(.title3.weight(.bold))
                SetGroup {
                    SetRow(symbol: "moon.fill", color: .indigo, title: "Dark mode") { Toggle("", isOn: $dark).labelsHidden() }
                    SetRow(symbol: "arrow.down.circle.fill", color: .teal, title: "Data saver", showsDivider: false) { Toggle("", isOn: $dataSaver).labelsHidden() }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deliver to").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                    Picker("Deliver to", selection: $location) {
                        Text("Home").tag(0)
                        Text("Work").tag(1)
                        Text("Other").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                Spacer()
            }
            .padding(22)
            .presentationDetents([.height(340), .medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
        }
    }
}

// MARK: - Catalog

enum SettingsSamples {
    static let sections: [KitSection] = [app, identity, preferences, account, layouts]

    static let app = KitSection("This app's settings", symbol: "gearshape.fill", [
        KitSample("Theme and colour", "System, light, dark or neon, and the primary colour, for the whole app.", code: """
        @Environment(KitoAppSettingsViewModel.self) private var settings

        ForEach(KitoAppSettingsViewModel.ThemeMode.allCases) { mode in
            ThemeCard(mode, isSelected: settings.themeMode == mode) { settings.themeMode = mode }
        }
        ColorPicker("Any colour", selection: $settings.primaryColor)
        """) { SetThemeSample() },
        KitSample("Text size and roundness", "Scale every font and corner in every kit, with live previews.", code: """
        Slider(value: $settings.fontScale, in: 0.8...1.5, step: 0.05)
        Slider(value: $settings.cornerRadiusScale, in: 0...2, step: 0.1)
        Text("Habari, Wycliff").font(theme.typography.titleLarge)
        """) { SetTextAndShapeSample() },
        KitSample("About this app", "Version, architecture and who made it.", code: "Text(Kito.version)") { SetAboutSample() },
    ])

    static let identity = KitSection("Profile", symbol: "person.crop.circle", [
        KitSample("Profile header", "Avatar with a camera badge, verified name, a Pro badge and stats.", code: """
        HStack {
            Avatar("WN").overlay(alignment: .bottomTrailing) { CameraBadge() }
            VStack(alignment: .leading) { Text("Wycliff N"); Text(email); ProBadge() }
        }
        """) { SetProfileHeaderSample() },
        KitSample("Subscription", "The current plan with perks and a monthly or yearly switch.", code: "Text(yearly ? \"KES 4,990 / year\" : \"KES 499 / month\").contentTransition(.numericText())") { SetSubscriptionSample() },
    ])

    static let preferences = KitSection("Preferences", symbol: "slider.horizontal.3", [
        KitSample("Grouped rows with icons", "Coloured icons, toggles, values and chevrons.", code: """
        SettingsGroup(title: "App") {
            SettingsRow("bell.badge.fill", .red, "Notifications") { Toggle("", isOn: $notifications).labelsHidden() }
            SettingsRow("globe", .indigo, "Language") { Chevron(value: "Kiswahili") }
        }
        """) { SetGroupedSample() },
        KitSample("Notifications", "What to hear about, how, and quiet hours that expand when on.", code: """
        Toggle("", isOn: $quietHours.animation(.spring))
        if quietHours {
            DatePicker("From", selection: $start, displayedComponents: .hourAndMinute)
        }
        """) { SetNotificationsSample() },
        KitSample("Language", "East African languages with their own names, and a checkmark that springs in.", code: """
        ForEach(languages) { language in
            Button { selected = language.code } label: { LanguageRow(language, isSelected: selected == language.code) }
        }
        """) { SetLanguageSample() },
        KitSample("Search settings", "Filter as you type, with the match highlighted.", code: """
        var name = AttributedString(row.title)
        if let range = name.range(of: query, options: .caseInsensitive) { name[range].foregroundColor = .blue }
        """) { SetSearchSample() },
    ])

    static let account = KitSection("Account & data", symbol: "lock.shield", [
        KitSample("Security", "A score ring that rises as you turn on Face ID, two-step and passkeys.", code: """
        Circle().trim(from: 0, to: score).stroke(score > 0.8 ? .green : .orange, lineWidth: 10)
        Text("\\(Int(score * 100))%").contentTransition(.numericText())
        """) { SetSecuritySample() },
        KitSample("Storage", "A stacked usage bar; clearing the cache shrinks it.", code: """
        HStack(spacing: 2) {
            Segment(.orange, photos); Segment(.green, messages); Segment(.purple, cache)
        }
        .clipShape(Capsule())
        """) { SetStorageSample() },
        KitSample("Danger zone", "Sign out, and a delete that asks first.", code: """
        .confirmationDialog("Delete your account?", isPresented: $confirmsDelete, titleVisibility: .visible) {
            Button("Delete account and data", role: .destructive) { scheduleDeletion() }
        }
        """) { SetDangerZoneSample() },
    ])

    static let layouts = KitSection("Layouts", symbol: "rectangle.3.group", [
        KitSample("Neon settings", "Glass rows that glow in KitoColors.neon.", code: """
        VStack { rows }
            .kitoGlassCard(cornerRadius: 22, tint: KitoColors.neon.primary.opacity(0.6))
            .kitoGlow(KitoColors.neon.primary, radius: 14)
        """) { SetNeonSample() },
        KitSample("Quick settings sheet", "A short sheet of the settings people change most.", code: """
        .sheet(isPresented: $showsSettings) {
            QuickSettings()
                .presentationDetents([.height(340), .medium])
                .presentationBackground(.regularMaterial)
        }
        """) { ModalStage { SetQuickSheetSample() } },
    ])
}

/// The app's settings and settings-screen designs. Also opened from the home screen's gear.
struct SettingsDemo: View {
    static var count: Int { KitGallery.count(SettingsSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Settings",
            sections: SettingsSamples.sections,
            footnote: "Settings screens built with SwiftUI and `import KitoCore`; the first section changes this app's theme.",
            searchHint: "Try “theme”, “language”, “security” or “storage”."
        )
    }
}
