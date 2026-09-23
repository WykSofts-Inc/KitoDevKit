//
//  KitoAppShortcuts.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//
//  App Shortcuts must be declared in the app target — the system only reads them from the app's
//  own binary, never from a package. The intents themselves come from KitoWidgets.

import AppIntents
import KitoWidgets

/// Lets the system find KitoWidgets' intents in the app.
struct KitoSampleIntents: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] { [KitoWidgetsIntents.self] }
}

/// Siri, Spotlight and the Shortcuts app pick these up on install — no setup by the user.
struct KitoAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: KitoIncrementCounterIntent(counterKey: "kito.sample.water", amount: 1),
            phrases: [
                "Log a glass of water in \(.applicationName)",
                "Add water in \(.applicationName)",
            ],
            shortTitle: "Log Water",
            systemImageName: "drop.fill"
        )
        AppShortcut(
            intent: KitoOpenShortcutIntent(),
            phrases: [
                "Open \(\.$item) in \(.applicationName)",
                "Go to \(\.$item) in \(.applicationName)",
            ],
            shortTitle: "Open",
            systemImageName: "arrow.up.forward.app"
        )
    }

    static var shortcutTileColor: ShortcutTileColor { .navy }
}
