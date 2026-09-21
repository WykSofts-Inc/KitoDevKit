# KitoSample

A tiny SwiftUI package that depends on `KitoDevKit` and nothing else. It exists
for one reason: if this package builds, the umbrella honestly re-exports every
kit it claims to.

## Running against the local umbrella

While developing KitoDevKit, override the dependency to point at the parent
directory so you're testing what you've just changed:

```swift
dependencies: [
    .package(name: "KitoDevKit", path: ".."),
],
```

Then:

```bash
swift build
```

## Running against published tags

The default `Package.swift` here uses `from: "1.0.0"`. That's what a real
downstream consumer would type. Keep this as the shipped configuration; only
switch to `path: ".."` while working on the umbrella locally.

## Turning it into an app

Open in Xcode → File → New → Project → App, add the `KitoSample` package as a
local dependency, and use `KitoSampleApp()` from your `App` entry point:

```swift
@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup { KitoSampleApp() }
    }
}
```
