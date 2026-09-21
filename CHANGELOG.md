# Changelog

_Wycliff · wyksoftsinc.com · 12/5/25_

Follows [Keep a Changelog](https://keepachangelog.com/). See
[docs/VERSIONING.md](docs/VERSIONING.md) for what bumps this file's version.

## [Unreleased]

## [1.0.0] — pending first release

### Curated child matrix (release-safe umbrella)

- KitoCore 1.0.0
- KitoButtons 1.0.0
- KitoFields 1.0.0
- KitoScreens 1.0.0
- KitoCharts 1.0.0
- KitoLoaders 1.0.0
- KitoToasts 1.0.0
- KitoModals 1.0.0
- KitoEmptyStates 1.0.0
- KitoHaptics 1.0.0
- KitoValidation 1.0.0
- KitoNavigation 1.0.0
- KitoPermissions 1.0.0
- KitoBiometrics 1.0.0
- KitoMediaPicker 1.0.0
- KitoOnboarding 1.0.0

Debug/QA tooling (KitoNetKit, KitoFillKit) ships separately as
[KitoDevKitDebug](https://github.com/WykSofts-Inc/KitoDevKitDebug) 1.0.0 —
never in this umbrella. See [docs/VERSIONING.md](docs/VERSIONING.md).

### Added

- Umbrella target `KitoDevKit` re-exports every release-safe kit above.
- Sample SwiftUI app under `Sample/` proves the umbrella resolves cleanly.
- Documentation: VERSIONING, RELEASING, PUBLISHING.
