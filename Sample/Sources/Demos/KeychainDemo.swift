//
//  KeychainDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoKeychain

struct KeychainDemo: View {
    private let keychain = KitoKeychain(service: "com.wyksoftsinc.kitosample.demo")
    @State private var input = "hunter2"
    @State private var stored: String?
    @State private var log = "—"

    var body: some View {
        Form {
            Section("Value") {
                TextField("Value to store", text: $input)
            }
            Section("Actions") {
                Button("Save") {
                    do { try keychain.set(input, for: "demoToken"); log = "Saved." }
                    catch { log = "Error: \(error.localizedDescription)" }
                }
                Button("Read") {
                    do { stored = try keychain.string(for: "demoToken"); log = "Read: \(stored ?? "nil")" }
                    catch { log = "Error: \(error.localizedDescription)" }
                }
                Button("Remove", role: .destructive) {
                    do { try keychain.remove("demoToken"); stored = nil; log = "Removed." }
                    catch { log = "Error: \(error.localizedDescription)" }
                }
            }
            Section("Result") {
                Text(log).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Keychain")
    }
}
