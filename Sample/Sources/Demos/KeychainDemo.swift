//
//  KeychainDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoKeychain

struct KeychainDemo: View {
    private let authKeychain = KitoKeychain(service: "com.wyksoftsinc.kitosample.demo.auth")
    private let settingsKeychain = KitoKeychain(service: "com.wyksoftsinc.kitosample.demo.settings")

    @State private var input = "hunter2"
    @State private var log = "—"

    var body: some View {
        Form {
            Section("Basic round-trip") {
                TextField("Value to store", text: $input)
                Button("Save") { run { try authKeychain.set(input, for: "demoToken") } message: { "Saved." } }
                Button("Read") {
                    do {
                        let value = try authKeychain.string(for: "demoToken")
                        log = "Read: \(value ?? "nil")"
                    } catch { log = "Error: \(error.localizedDescription)" }
                }
                Button("Remove", role: .destructive) {
                    run { try authKeychain.remove("demoToken") } message: { "Removed." }
                }
            }

            Section("Custom accessibility") {
                Button("Save with .afterFirstUnlockThisDeviceOnly") {
                    run { try authKeychain.set(input, for: "backgroundToken", accessibility: .afterFirstUnlockThisDeviceOnly) } message: { "Saved (readable after first unlock, even in background)." }
                }
            }

            Section("Multiple keys, one service") {
                Button("Save 3 keys at once") {
                    run {
                        try authKeychain.set("access-abc", for: "accessToken")
                        try authKeychain.set("refresh-xyz", for: "refreshToken")
                        try authKeychain.set("user-42", for: "userID")
                    } message: { "Saved accessToken, refreshToken, userID." }
                }
                Button("Remove all (sign-out simulation)", role: .destructive) {
                    run { try authKeychain.removeAll() } message: { "All items in this service removed." }
                }
            }

            Section("Isolated namespaces") {
                Text("authKeychain and settingsKeychain are separate services — removing one never touches the other.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Save to settingsKeychain") {
                    run { try settingsKeychain.set("dark", for: "theme") } message: { "Saved to the settings namespace." }
                }
                Button("removeAll() on authKeychain only") {
                    run { try authKeychain.removeAll() } message: { "Auth cleared — check settingsKeychain still has 'theme' below." }
                }
                Button("Read settingsKeychain.theme") {
                    do {
                        let value = try settingsKeychain.string(for: "theme")
                        log = "settingsKeychain.theme = \(value ?? "nil")"
                    } catch { log = "Error: \(error.localizedDescription)" }
                }
            }

            Section("Result") {
                Text(log).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Keychain")
    }

    private func run(_ action: () throws -> Void, message: () -> String) {
        do {
            try action()
            log = message()
        } catch {
            log = "Error: \(error.localizedDescription)"
        }
    }
}
