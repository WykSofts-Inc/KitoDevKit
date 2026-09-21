# KitoDevKit

An iOS workspace of independently published SwiftUI libraries — themeable
building blocks (buttons, fields), prebuilt screens (sign in, sign up, edit
profile, M-Pesa, card checkout), and a shared theme foundation. Every kit
installs independently; **KitoDevKit** is the umbrella that pulls a curated,
compatible set of them in one dependency.

| Kit | Repo | What it does |
| --- | --- | --- |
| **KitoCore** | [KitoCore](https://github.com/WykSofts-Inc/KitoCore) | Theme tokens: semantic colors, spacing, typography, radii, and the `Kito.version` constant. Every other kit depends on this. |
| **KitoButtons** | [KitoButtons](https://github.com/WykSofts-Inc/KitoButtons) | Themeable SwiftUI button — variants, sizes, icons, loading state, async actions. |
| **KitoFields** | [KitoFields](https://github.com/WykSofts-Inc/KitoFields) | Customisable form inputs — text, email, password, phone with country picker, OTP. |
| **KitoScreens** | [KitoScreens](https://github.com/WykSofts-Inc/KitoScreens) | Prebuilt screens — sign in, sign up, edit profile, M-Pesa, card checkout — built on Buttons and Fields. |
| **KitoCharts** | [KitoCharts](https://github.com/WykSofts-Inc/KitoCharts) | MVVM charting — line, bar, pie/donut, 3D bars today; full DevKit-ChartKit-equivalent catalog on the roadmap. |
| **KitoLoaders** | [KitoLoaders](https://github.com/WykSofts-Inc/KitoLoaders) | Themeable loaders — spinner, dots, pulse, progress ring, skeleton placeholders. |
| **KitoToasts** | [KitoToasts](https://github.com/WykSofts-Inc/KitoToasts) | Queued toast/snackbar notifications — swipe to dismiss, actionable, spring physics. |
| **KitoModals** | [KitoModals](https://github.com/WykSofts-Inc/KitoModals) | Route-based bottom sheets, one-binding confirmation dialogs, animated pending/success/failure status dialog. |
| **KitoEmptyStates** | [KitoEmptyStates](https://github.com/WykSofts-Inc/KitoEmptyStates) | Empty/no-results/offline/error views, plus `KitoStateView` over `KitoLoadState`. |
| **KitoHaptics** | [KitoHaptics](https://github.com/WykSofts-Inc/KitoHaptics) | Semantic haptic feedback with a global enable/disable switch. |
| **KitoValidation** | [KitoValidation](https://github.com/WykSofts-Inc/KitoValidation) | Composable field validators and password-strength scoring. |
| **KitoNavigation** | [KitoNavigation](https://github.com/WykSofts-Inc/KitoNavigation) | Typed `NavigationStack` router — push/pop/popToRoot, full-screen cover slot. |
| **KitoPermissions** | [KitoPermissions](https://github.com/WykSofts-Inc/KitoPermissions) | One async API over camera/photos/mic/location/contacts/notifications, plus a rationale screen. |
| **KitoBiometrics** | [KitoBiometrics](https://github.com/WykSofts-Inc/KitoBiometrics) | Face ID / Touch ID async API and a drop-in lock screen. |
| **KitoMediaPicker** | [KitoMediaPicker](https://github.com/WykSofts-Inc/KitoMediaPicker) | Themed photo picker over `PhotosUI` with MVVM load/decode lifecycle. |
| **KitoOnboarding** | [KitoOnboarding](https://github.com/WykSofts-Inc/KitoOnboarding) | Paged, swipeable onboarding flow with animated page indicator. |
| **KitoCart** | [KitoCart](https://github.com/WykSofts-Inc/KitoCart) | Cart state management plus a "fly to cart" curved-path animation, integrates with your existing button kit. |
| **KitoOrderTracking** | [KitoOrderTracking](https://github.com/WykSofts-Inc/KitoOrderTracking) | Self-refreshing order tracking screen + Dynamic Island / Lock Screen Live Activity support. |
| **KitoFormatting** | [KitoFormatting](https://github.com/WykSofts-Inc/KitoFormatting) | Currency (KES/USD/+), compact number, percent, and date formatting. |
| **KitoConnectivity** | [KitoConnectivity](https://github.com/WykSofts-Inc/KitoConnectivity) | Real on-device online/offline monitoring (production counterpart to KitoNetKit). |
| **KitoKeychain** | [KitoKeychain](https://github.com/WykSofts-Inc/KitoKeychain) | A correct Keychain Services wrapper for tokens and secrets, pairs with KitoBiometrics. |

Debug/QA-only tooling ships separately, never in this umbrella — see
[KitoDevKitDebug](https://github.com/WykSofts-Inc/KitoDevKitDebug)
([KitoNetKit](https://github.com/WykSofts-Inc/KitoNetKit) +
[KitoFillKit](https://github.com/WykSofts-Inc/KitoFillKit)).

## Install

### One dependency, curated set (recommended)

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoDevKit.git", from: "1.0.0"),
```

Add `KitoDevKit` to your target. That's it — every kit above is now available
through one `import`:

```swift
import KitoDevKit

struct RootView: View {
    var body: some View {
        SignInScreen()      // KitoScreens
            .autoKitoTheme() // KitoCore
    }
}
```

### One kit at a time

If you only need buttons:

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoButtons.git", from: "1.0.0"),
```

```swift
import KitoButtons
```

## Documentation

- [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md) — install, theme setup, a minimal end-to-end screen
- [docs/COOKBOOK.md](docs/COOKBOOK.md) — full composed screens: sign-up, checkout with biometrics, a dashboard, an app shell with tabs + side menu, profile editing, onboarding into a permission request
- [docs/DEPENDENCY_GRAPH.md](docs/DEPENDENCY_GRAPH.md) — exactly what each kit requires (almost always just KitoCore)
- [docs/VERSIONING.md](docs/VERSIONING.md) · [docs/RELEASING.md](docs/RELEASING.md) · [docs/PUBLISHING.md](docs/PUBLISHING.md)
- [../KitoCore/docs/ENGINEERING_STANDARDS.md](https://github.com/WykSofts-Inc/KitoCore/blob/main/docs/ENGINEERING_STANDARDS.md) — crash-safety, device-support, and worldwide-readiness rules every kit follows

## Requirements

- iOS 17 or newer
- Swift 5.9 / Xcode 15+
- SwiftUI

## Versioning

KitoDevKit **is the BOM analog**. Each release pins exact versions of every child
kit in [Package.swift](Package.swift). A KitoDevKit tag is a promise that *this
set of versions was tested and released together*. See
[docs/VERSIONING.md](docs/VERSIONING.md).

Kits themselves version independently. If you consume kits directly, you pick
their versions yourself — the umbrella is a convenience, not a requirement.

## Release safety

`KitoDevKit` re-exports **only** release-safe kits. Developer/QA tooling
(KitoNetKit's network simulator, KitoFillKit's synthetic form data) ships
from a **separate** package, [KitoDevKitDebug](https://github.com/WykSofts-Inc/KitoDevKitDebug),
so a consumer typing the natural line — `import KitoDevKit` — can never end
up shipping a network interceptor to production. This split is the single
most load-bearing decision in the distribution model; see
`KitoDevKitDebug`'s README for why SPM specifically requires it to be a
separate package rather than a build-config flag.

## Contents of this repo

```
KitoDevKit/
├── Package.swift              # pins each child at an exact version
├── Sources/KitoDevKit/
│   └── Exports.swift          # @_exported import of every kit
├── Tests/KitoDevKitTests/     # compile-time check that every re-export lands
├── Sample/                    # a tiny SwiftUI app that only depends on KitoDevKit
└── docs/
    ├── VERSIONING.md
    ├── RELEASING.md
    └── PUBLISHING.md
```

## License

MIT
