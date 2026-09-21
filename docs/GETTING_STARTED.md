# Getting started

_KitoDevKit · Wycliff · wyksoftsinc.com · 9/21/26_

## 1. Pick an install shape

**Everything, one dependency** (recommended for a new app):

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoDevKit.git", from: "1.0.0"),
```

**Just what you need** — see [DEPENDENCY_GRAPH.md](DEPENDENCY_GRAPH.md) for
exactly what each kit pulls in (almost always just `KitoCore`, nothing more):

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoModals.git", from: "1.0.0"),
.package(url: "https://github.com/WykSofts-Inc/KitoToasts.git", from: "1.0.0"),
```

**Debug/QA tooling** (network simulation, synthetic form data) is a
*separate* dependency, gated with `#if DEBUG` at both the package
declaration and every import site — see
[KitoDevKitDebug's README](https://github.com/WykSofts-Inc/KitoDevKitDebug)
for exactly why SPM requires that double gate:

```swift
#if DEBUG
.package(url: "https://github.com/WykSofts-Inc/KitoDevKitDebug.git", from: "1.0.0"),
#endif
```

## 2. Set a theme once, at the root

Every kit reads presentation values from `@Environment(\.kitoTheme)`. Set it
once and every kit in the tree — buttons, charts, toasts, dialogs — follows:

```swift
import SwiftUI
import KitoDevKit

@main
struct MyApp: App {
    @State private var toasts = KitoToastCenter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .autoKitoTheme()          // follows system light/dark
                .kitoToastHost(toasts)     // one host for the whole app
                .environment(toasts)
        }
    }
}
```

Prefer a fixed theme regardless of system appearance?

```swift
RootView()
    .kitoTheme(.dark)
    .preferredColorScheme(.dark)
```

Custom brand colors — override once, every kit follows:

```swift
let brandTheme = KitoTheme(colors: KitoColors(
    primary: Color(red: 0.0, green: 0.6, blue: 0.4),   // your brand green
    onPrimary: .white,
    secondary: .black, onSecondary: .white,
    background: .white, onBackground: .black,
    surface: .white, onSurface: .black,
    surfaceMuted: Color(white: 0.95),
    border: Color(white: 0.85),
    danger: .red, success: .green, warning: .orange
))

RootView().kitoTheme(brandTheme)
```

## 3. A minimal end-to-end screen

Ten lines, three kits, already themed:

```swift
import SwiftUI
import KitoDevKit

struct MinimalScreen: View {
    @State private var toasts = KitoToastCenter()
    @State private var chart = LineChartViewModel(points: [
        ChartDataPoint(label: "Mon", value: 120),
        ChartDataPoint(label: "Tue", value: 200),
        ChartDataPoint(label: "Wed", value: 150),
    ])

    var body: some View {
        VStack {
            LineChartView(viewModel: chart)
            Button("Notify me") { toasts.show("Hello from Kito", style: .success) }
        }
        .kitoToastHost(toasts)
    }
}
```

## 4. Where to go next

- [COOKBOOK.md](COOKBOOK.md) — full, realistic screens composing several
  kits together: sign-up, checkout with biometrics, a dashboard, an app
  shell with tabs and a side menu, profile editing.
- [DEPENDENCY_GRAPH.md](DEPENDENCY_GRAPH.md) — exactly what each kit
  requires, so you know the footprint before you add it.
- [../../KitoCore/docs/ENGINEERING_STANDARDS.md](../../KitoCore/docs/ENGINEERING_STANDARDS.md) —
  the crash-safety, device-support, and worldwide-readiness rules every kit
  follows, and the open decisions (iOS 17 minimum) worth knowing about
  before you build on top of Kito.
- Each kit's own README — task-focused samples for that kit alone.
