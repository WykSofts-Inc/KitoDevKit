# Dependency graph

_KitoDevKit · Wycliff · wyksoftsinc.com · 9/21/26_

Every kit installs independently. **You never have to take `KitoDevKit`
(or any umbrella) to use one kit** — `.package(url: ".../KitoToasts.git", ...)`
on its own resolves and builds with nothing else Kito-flavored required
except what that one kit genuinely needs. This page states exactly what
that is, per kit, so there's no guessing.

## The rule

- **16 of 17 packages depend on nothing but `KitoCore`, or nothing at all.**
  Taking one kit never silently pulls in three others.
- **Two kits depend on `KitoLoaders`** (`KitoEmptyStates`, `KitoMediaPicker`)
  because they render a spinner while content loads — that's a real,
  declared need, not incidental umbrella coupling.
- **Zero kits depend on `KitoScreens`, `KitoButtons`, or `KitoFields`.** The
  new kits built in this pass (Charts, Loaders, Toasts, Modals, EmptyStates,
  Haptics, Validation, Navigation, Permissions, Biometrics, MediaPicker,
  Onboarding, NetKit, FillKit) are all usable in a project that has never
  heard of the original three UI kits.
- **Only the umbrellas (`KitoDevKit`, `KitoDevKitDebug`) touch everything.**
  That's their entire job — see [VERSIONING.md](VERSIONING.md).

## Full graph

```
KitoCore            → (nothing — the foundation)
KitoHaptics         → (nothing — pure UIKit wrapper)
KitoValidation       → (nothing — pure value types)
KitoFillKit          → (nothing — pure value types, DEBUG-only)

KitoCharts           → KitoCore
KitoLoaders          → KitoCore
KitoToasts           → KitoCore
KitoModals           → KitoCore
KitoNavigation       → KitoCore
KitoPermissions      → KitoCore
KitoBiometrics       → KitoCore
KitoOnboarding       → KitoCore
KitoNetKit           → KitoCore   (DEBUG-only)

KitoEmptyStates      → KitoCore, KitoLoaders
KitoMediaPicker      → KitoCore, KitoLoaders

KitoDevKit           → KitoCore, KitoButtons, KitoFields, KitoScreens,
                        KitoCharts, KitoLoaders, KitoToasts, KitoModals,
                        KitoEmptyStates, KitoHaptics, KitoValidation,
                        KitoNavigation, KitoPermissions, KitoBiometrics,
                        KitoMediaPicker, KitoOnboarding
                        (everything release-safe — that's the point of an umbrella)

KitoDevKitDebug      → KitoNetKit, KitoFillKit
                        (everything debug-only — kept separate from KitoDevKit, see VERSIONING.md)
```

## What this means practically

Want just a status dialog for a payment flow, nothing else?

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoModals.git", from: "1.0.0"),
```

pulls in `KitoModals` + `KitoCore` (for theming) — two packages, not sixteen.

Want charts in a dashboard app with no forms, no auth, no navigation kit?

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoCharts.git", from: "1.0.0"),
```

Same deal — `KitoCharts` + `KitoCore`, full stop.

The umbrella (`KitoDevKit`) exists for the opposite case: you want everything
and don't want to manage sixteen version numbers by hand. It's a convenience
on top of independent kits, never a requirement to use any one of them. See
[README.md](../README.md#one-kit-at-a-time) for the install snippet either way.
