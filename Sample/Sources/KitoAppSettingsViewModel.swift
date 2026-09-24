//
//  KitoAppSettingsViewModel.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Drives a live theme editor over the whole app — every kit reads its
/// colors/fonts from `@Environment(\.kitoTheme)`, so changing these values
/// here re-themes every screen in the catalog at once. This is the concrete
/// proof that Kito's "one theme, everywhere" architecture actually works.
@Observable
final class KitoAppSettingsViewModel {
    enum ThemeMode: String, CaseIterable, Identifiable {
        case system, light, dark, neon
        var id: Self { self }
        var label: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            case .neon: return "Neon"
            }
        }
    }

    /// Defaults to the "dark glass + neon" look — KitoDevKit's flagship
    /// skin — but every value here stays a live, user-editable setting
    /// (the customization principle applies to the default theme too).
    var themeMode: ThemeMode = .neon
    var primaryColor: Color = KitoColors.neon.primary
    /// Multiplies every base font size. KitoThemeTypography stores opaque `Font`
    /// values (not raw point sizes), so scaling means rebuilding it from the
    /// same base sizes KitoThemeTypography.default uses, not adjusting in place.
    var fontScale: Double = 1.0
    var cornerRadiusScale: Double = 1.0

    /// Forces the whole app into left-to-right or right-to-left layout, so
    /// every kit can be checked for RTL (Arabic, Hebrew, Urdu) without
    /// changing the device language.
    enum LayoutDirectionMode: String, CaseIterable, Identifiable {
        case system, leftToRight, rightToLeft
        var id: Self { self }
        var label: String {
            switch self {
            case .system: return "System"
            case .leftToRight: return "Left to right"
            case .rightToLeft: return "Right to left"
            }
        }
        var direction: LayoutDirection? {
            switch self {
            case .system: return nil
            case .leftToRight: return .leftToRight
            case .rightToLeft: return .rightToLeft
            }
        }
    }

    var layoutDirectionMode: LayoutDirectionMode = .system
    /// Swaps the environment locale for Arabic so numbers, dates, currency
    /// and plurals format the way an RTL user would see them. It does not
    /// translate strings; for double-length pseudo-strings, run the app with
    /// Xcode's "Double-Length Pseudolanguage" (Edit Scheme > Run > Options).
    var pseudoLanguage: Bool = false
    static let pseudoLocale = Locale(identifier: "ar")

    var preferredColorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark, .neon: return .dark
        }
    }

    func theme(resolvedScheme: ColorScheme) -> KitoTheme {
        var colors = themeMode == .neon ? KitoColors.neon : (resolvedScheme == .dark ? KitoColors.dark : KitoColors.light)
        colors.primary = primaryColor
        return KitoTheme(
            colors: colors,
            spacing: .default,
            typography: scaledTypography,
            radii: scaledRadii
        )
    }

    private var scaledTypography: KitoThemeTypography {
        KitoThemeTypography(
            displayLarge: .system(size: 34 * fontScale, weight: .bold),
            displayMedium: .system(size: 28 * fontScale, weight: .semibold),
            titleLarge: .system(size: 22 * fontScale, weight: .semibold),
            titleMedium: .system(size: 18 * fontScale, weight: .semibold),
            body: .system(size: 16 * fontScale, weight: .regular),
            bodyEmphasized: .system(size: 16 * fontScale, weight: .medium),
            label: .system(size: 14 * fontScale, weight: .medium),
            caption: .system(size: 12 * fontScale, weight: .regular),
            button: .system(size: 16 * fontScale, weight: .semibold)
        )
    }

    private var scaledRadii: KitoRadii {
        let base = KitoRadii.default
        return KitoRadii(
            none: 0,
            sm: base.sm * cornerRadiusScale,
            md: base.md * cornerRadiusScale,
            lg: base.lg * cornerRadiusScale,
            xl: base.xl * cornerRadiusScale,
            pill: base.pill
        )
    }

    func reset() {
        themeMode = .neon
        primaryColor = KitoColors.neon.primary
        fontScale = 1.0
        cornerRadiusScale = 1.0
        layoutDirectionMode = .system
        pseudoLanguage = false
    }
}

/// Resolves `themeMode` against the actual system appearance and applies
/// the resulting theme — a plain `App` struct has no `@Environment` access
/// before the view hierarchy exists, so this wrapper is where that
/// resolution has to happen.
struct KitoThemedRoot<Content: View>: View {
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.layoutDirection) private var systemLayoutDirection
    @Environment(\.locale) private var systemLocale
    let settings: KitoAppSettingsViewModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        let resolved: ColorScheme = {
            switch settings.themeMode {
            case .system: return systemColorScheme
            case .light: return .light
            case .dark, .neon: return .dark
            }
        }()

        content()
            .kitoTheme(settings.theme(resolvedScheme: resolved))
            .preferredColorScheme(settings.preferredColorScheme)
            .environment(\.layoutDirection, settings.layoutDirectionMode.direction ?? systemLayoutDirection)
            .environment(\.locale, settings.pseudoLanguage ? KitoAppSettingsViewModel.pseudoLocale : systemLocale)
    }
}
