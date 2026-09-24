//
//  FashionTheme.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

// MARK: - Theme

/// Maison's look: ink on ivory in light mode, ivory on espresso in dark mode, serif headlines.
enum FashionPalette {
    static let ink = Color(red: 0.07, green: 0.07, blue: 0.07)
    static let ivory = Color(red: 0.97, green: 0.95, blue: 0.91)
    static let gold = Color(red: 0.78, green: 0.63, blue: 0.36)
    static let espresso = Color(red: 0.07, green: 0.06, blue: 0.06)

    static let sand = Color(red: 0.86, green: 0.78, blue: 0.64)
    static let camel = Color(red: 0.74, green: 0.58, blue: 0.40)
    static let cognac = Color(red: 0.58, green: 0.36, blue: 0.21)
    static let olive = Color(red: 0.36, green: 0.40, blue: 0.26)
    static let terracotta = Color(red: 0.74, green: 0.38, blue: 0.27)
    static let indigo = Color(red: 0.16, green: 0.20, blue: 0.38)
    static let claret = Color(red: 0.50, green: 0.12, blue: 0.19)
    static let sage = Color(red: 0.62, green: 0.69, blue: 0.60)
    static let bone = Color(red: 0.95, green: 0.93, blue: 0.88)
    static let ocean = Color(red: 0.18, green: 0.45, blue: 0.52)
    static let blush = Color(red: 0.89, green: 0.72, blue: 0.69)
    static let charcoal = Color(red: 0.22, green: 0.22, blue: 0.23)
}

extension KitoTheme {
    static func fashionMaison(_ scheme: ColorScheme) -> KitoTheme {
        let colors: KitoColors
        if scheme == .dark {
            colors = KitoColors(
                primary: FashionPalette.ivory, onPrimary: FashionPalette.ink,
                secondary: Color(red: 0.80, green: 0.77, blue: 0.72), onSecondary: FashionPalette.ink,
                background: FashionPalette.espresso, onBackground: FashionPalette.ivory,
                surface: Color(red: 0.12, green: 0.11, blue: 0.10), onSurface: FashionPalette.ivory,
                surfaceMuted: Color(red: 0.17, green: 0.16, blue: 0.15), border: Color(red: 0.26, green: 0.24, blue: 0.22),
                danger: Color(red: 0.95, green: 0.45, blue: 0.42), success: Color(red: 0.45, green: 0.78, blue: 0.56),
                warning: FashionPalette.gold)
        } else {
            colors = KitoColors(
                primary: FashionPalette.ink, onPrimary: .white,
                secondary: Color(red: 0.30, green: 0.28, blue: 0.26), onSecondary: .white,
                background: Color(red: 0.985, green: 0.975, blue: 0.96), onBackground: FashionPalette.ink,
                surface: .white, onSurface: FashionPalette.ink,
                surfaceMuted: Color(red: 0.95, green: 0.935, blue: 0.91), border: Color(red: 0.88, green: 0.86, blue: 0.82),
                danger: Color(red: 0.72, green: 0.18, blue: 0.20), success: Color(red: 0.18, green: 0.52, blue: 0.34),
                warning: Color(red: 0.70, green: 0.52, blue: 0.20))
        }
        let type = KitoThemeTypography(
            displayLarge: .system(size: 34, weight: .regular, design: .serif),
            displayMedium: .system(size: 28, weight: .regular, design: .serif),
            titleLarge: .system(size: 24, weight: .regular, design: .serif),
            titleMedium: .system(size: 19, weight: .medium, design: .serif))
        return KitoTheme(colors: colors, typography: type,
                         radii: KitoRadii(sm: 4, md: 8, lg: 12, xl: 16))
    }
}

/// Applies the Maison theme for the current (or forced) colour scheme.
struct FashionThemed<Content: View>: View {
    let appearance: FashionAppearance
    @ViewBuilder let content: () -> Content

    var body: some View {
        FashionThemeReader(content: content)
            .preferredColorScheme(appearance.scheme)
    }
}

private struct FashionThemeReader<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    let content: () -> Content

    var body: some View {
        content()
            .kitoTheme(.fashionMaison(scheme))
            .tint(scheme == .dark ? FashionPalette.ivory : FashionPalette.ink)
    }
}

enum FashionAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
    var scheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

// MARK: - Exit

private struct FashionExitKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    /// Leaves the Maison demo and returns to the DevKit.
    var fashionExit: () -> Void {
        get { self[FashionExitKey.self] }
        set { self[FashionExitKey.self] = newValue }
    }
}

// MARK: - Shared pieces

/// A spaced, uppercase kicker above serif section titles: "NEW IN".
struct FashionKicker: View {
    @Environment(\.kitoTheme) private var theme
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .tracking(2.2)
            .foregroundStyle(theme.colors.onBackground.opacity(0.55))
    }
}

/// A serif section header with an optional trailing link.
struct FashionSectionHeader: View {
    @Environment(\.kitoTheme) private var theme
    let kicker: String?
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                if let kicker { FashionKicker(kicker) }
                Text(title)
                    .font(theme.typography.titleLarge)
                    .foregroundStyle(theme.colors.onBackground)
                    .accessibilityAddTraits(.isHeader)
            }
            Spacer(minLength: 12)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .underline()
                        .foregroundStyle(theme.colors.onBackground)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, theme.spacing.lg)
    }
}

/// The "MAISON AMANI" wordmark.
struct FashionWordmark: View {
    @Environment(\.kitoTheme) private var theme
    var size: CGFloat = 20
    var color: Color? = nil

    var body: some View {
        Text("MAISON AMANI")
            .font(.system(size: size, weight: .regular, design: .serif))
            .tracking(size * 0.28)
            .foregroundStyle(color ?? theme.colors.onBackground)
            .accessibilityLabel("Maison Amani")
    }
}

/// A round, glassy icon button for headers.
struct FashionCircleButton: View {
    @Environment(\.kitoTheme) private var theme
    let systemImage: String
    let label: String
    var badge: Int = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(theme.colors.onBackground)
                .frame(width: 40, height: 40)
                .background(theme.colors.surfaceMuted, in: Circle())
                .overlay(alignment: .topTrailing) {
                    if badge > 0 {
                        Text("\(badge)")
                            .font(.system(size: 10, weight: .bold).monospacedDigit())
                            .foregroundStyle(theme.colors.onPrimary)
                            .frame(minWidth: 17, minHeight: 17)
                            .background(theme.colors.primary, in: Capsule())
                            .offset(x: 3, y: -3)
                    }
                }
        }
        .buttonStyle(FashionPressStyle())
        .accessibilityLabel(badge > 0 ? "\(label), \(badge)" : label)
    }
}

/// A gentle press: scales a touch and dims, off under Reduce Motion.
struct FashionPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(reduceMotion ? nil : .spring(duration: 0.25, bounce: 0.3), value: configuration.isPressed)
    }
}

enum FashionMotion {
    static func spring(_ reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85)
    }
}
