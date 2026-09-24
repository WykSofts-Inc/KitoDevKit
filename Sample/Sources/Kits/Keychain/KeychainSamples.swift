//
//  KeychainSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoKeychain

// Vault samples keep their secrets in memory and use a simulated Face ID gate, so they work in
// the simulator and never touch your real keychain. Samples marked "Live" use this app's keychain.

private let kcDemoEntries: [(title: String, kind: KitoSecureItem.Kind, secret: String, detail: String?)] = [
    ("M-Pesa PIN", .pin, "4821", "Safaricom · 0712 ••• 489"),
    ("KRA iTax password", .password, "Karibu#2026!", "PIN A012345678Z"),
    ("Equity Visa", .card, "4242881022914821", "Expires 09/29"),
    ("Daraja API key", .apiKey, "sk_live_9f2aB71cQx0mZ44d", "Production · Lipa na M-Pesa"),
    ("Recovery codes", .recoveryCode, "8H2K-QP4M  T7XW-9D3L  ZC6R-1NFB", "Google · 10 left"),
    ("Wi-Fi at home", .note, "Network: Njenga_5G\nPassword: chai-na-mandazi", "Kileleshwa"),
]

private let kcTokenEntries: [(title: String, kind: KitoSecureItem.Kind, secret: String, detail: String?)] = [
    ("Access token", .token, "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ3eWNsaWZmIn0.Qm9kYQ", "Expires in 14 min"),
    ("Refresh token", .token, "rt_7Qx2mK9pL4sV8wZ1cB6n", "Expires 12 Oct"),
    ("GitHub token", .token, "ghp_W7cL2xQ9mV4pK8sZ1bN6tR3y", "WykSofts-Inc · repo, workflow"),
    ("Stripe key", .apiKey, "pk_live_51HxQ2L9mVz", "Publishable"),
]

// MARK: - Stages

/// A vault screen over an in-memory store.
private struct KcVaultStage: View {
    @State private var vault: KitoSecureVault
    let title: String
    let gate: KitoRevealGate

    init(_ entries: [(title: String, kind: KitoSecureItem.Kind, secret: String, detail: String?)], title: String = "Vault", gate: KitoRevealGate = .simulated()) {
        _vault = State(initialValue: KitoSecureVault.preview(entries))
        self.title = title
        self.gate = gate
    }

    var body: some View {
        KitoSecureVaultView(vault: vault, title: title, gate: gate)
            .safeAreaPadding(.top, 40)
    }
}

/// A vault in this app's real keychain.
private struct KcLiveVaultStage: View {
    @State private var vault = KitoSecureVault(service: "com.wyksoftsinc.kitosample.vault")

    var body: some View {
        KitoSecureVaultView(vault: vault, title: "My vault")
            .safeAreaPadding(.top, 40)
    }
}

/// A card of revealable secrets with a heading.
private struct KcSecretsCard<Content: View>: View {
    let title: String
    let symbol: String
    let tint: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .foregroundStyle(tint)
            content()
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}

private struct KcSecretField: View {
    let label: String
    let value: String
    var mask: KitoSecretMask = .dots
    var gate: KitoRevealGate = .simulated()
    var autoHide: Duration = .seconds(20)

    var body: some View {
        KitoRevealableSecret(label, value: value, mask: mask, gate: gate, reason: "Reveal \(label)", autoHide: autoHide)
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.systemBackground)))
    }
}

/// Every mask side by side.
private struct KcMasksPreview: View {
    private let secret = "sk_live_9f2aB71cQx0mZ44d"
    private let card = "4242881022914821"

    var body: some View {
        VStack(spacing: 0) {
            row(".dots", KitoSecretMask.dots.apply(to: secret))
            Divider()
            row(".lastFour", KitoSecretMask.lastFour.apply(to: card))
            Divider()
            row(".partial(prefix: 4, suffix: 4)", KitoSecretMask.partial(prefix: 4, suffix: 4).apply(to: secret))
            Divider()
            row(".partial(prefix: 8, suffix: 0)", KitoSecretMask.partial(prefix: 8, suffix: 0).apply(to: secret))
        }
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.secondarySystemBackground)))
    }

    private func row(_ name: String, _ masked: String) -> some View {
        HStack {
            Text(name).font(.caption.monospaced()).foregroundStyle(.secondary)
            Spacer()
            Text(masked).font(.subheadline.monospaced().weight(.medium))
        }
        .padding(14)
    }
}

/// A sign-in session: tokens in the keychain, wiped on sign-out.
private struct KcSessionStage: View {
    @State private var vault = KitoSecureVault.preview([
        ("Access token", .token, "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ3eWNsaWZmIn0.Qm9kYQ", "Expires in 14 min"),
        ("Refresh token", .token, "rt_7Qx2mK9pL4sV8wZ1cB6n", "Expires 12 Oct"),
    ])

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Text("WN").font(.headline).foregroundStyle(.white).frame(width: 50, height: 50).background(Circle().fill(Color.indigo.gradient))
                VStack(alignment: .leading) {
                    Text("Wycliff N").font(.headline)
                    Text(vault.items.isEmpty ? "Signed out" : "Signed in · \(vault.items.count) tokens stored").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            ForEach(vault.items) { item in
                KitoRevealableSecret(item.title, mask: item.kind.defaultMask, gate: .simulated()) { vault.secret(for: item) }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground)))
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    if vault.items.isEmpty {
                        vault.add("Access token", kind: .token, secret: "eyJhbGciOiJIUzI1NiJ9.new", detail: "Expires in 15 min")
                        vault.add("Refresh token", kind: .token, secret: "rt_new_Z1cB6n", detail: "Expires in 30 days")
                    } else {
                        vault.deleteAll()
                    }
                }
            } label: {
                Label(vault.items.isEmpty ? "Sign in again" : "Sign out (wipes tokens)", systemImage: vault.items.isEmpty ? "person.fill.checkmark" : "rectangle.portrait.and.arrow.right").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

/// Save, read and remove against this app's real keychain.
private struct KcRoundTrip: View {
    private let keychain = KitoKeychain(service: "com.wyksoftsinc.kitosample.demo.auth")
    @State private var input = "chai-na-mandazi"
    @State private var log = "Nothing yet"
    @State private var ok = true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField("Value to store", text: $input)
                .font(.body.monospaced())
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemBackground)))
            HStack(spacing: 8) {
                Button("Save") { run("Saved “\(input)”.") { try keychain.set(input, for: "demoToken") } }
                Button("Read") { run(nil) { log = "Read: \(try keychain.string(for: "demoToken") ?? "nothing stored")" } }
                Button("Remove") { run("Removed.") { try keychain.remove("demoToken") } }
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            Label(log, systemImage: ok ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .font(.footnote)
                .foregroundStyle(ok ? Color.green : Color.red)
                .contentTransition(.opacity)
        }
        .animation(.easeInOut(duration: 0.2), value: log)
    }

    private func run(_ message: String?, _ work: () throws -> Void) {
        do {
            try work()
            ok = true
            if let message { log = message }
        } catch {
            ok = false
            log = error.localizedDescription
        }
    }
}

/// Separate services never touch each other.
private struct KcNamespaces: View {
    private let auth = KitoKeychain(service: "com.wyksoftsinc.kitosample.demo.auth")
    private let settings = KitoKeychain(service: "com.wyksoftsinc.kitosample.demo.settings")
    @State private var authValue: String?
    @State private var settingsValue: String?

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                box("auth", value: authValue, tint: .indigo)
                box("settings", value: settingsValue, tint: .teal)
            }
            HStack(spacing: 8) {
                Button("Fill both") {
                    try? auth.set("access-abc", for: "accessToken")
                    try? settings.set("dark", for: "theme")
                    reload()
                }
                Button("auth.removeAll()") { try? auth.removeAll(); reload() }
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .onAppear(perform: reload)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: authValue)
    }

    private func reload() {
        authValue = try? auth.string(for: "accessToken")
        settingsValue = try? settings.string(for: "theme")
    }

    private func box(_ name: String, value: String?, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name).font(.caption.monospaced().weight(.semibold)).foregroundStyle(tint)
            Text(value ?? "empty").font(.subheadline.monospaced()).foregroundStyle(value == nil ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(tint.opacity(0.1)))
    }
}

/// When a keychain item is readable.
private struct KcAccessibilityPreview: View {
    private let rows: [(String, String, String)] = [
        (".whenUnlockedThisDeviceOnly", "Default. Never syncs; unreadable while locked.", "lock.iphone"),
        (".afterFirstUnlockThisDeviceOnly", "Readable in background refresh after the first unlock.", "arrow.clockwise.icloud"),
        (".whenUnlocked", "Syncs with iCloud Keychain; unreadable while locked.", "icloud.fill"),
        (".afterFirstUnlock", "Syncs, and readable in the background.", "icloud.and.arrow.down"),
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(rows, id: \.0) { row in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: row.2).font(.headline).foregroundStyle(.indigo).frame(width: 36, height: 36).background(Circle().fill(Color.indigo.opacity(0.12)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.0).font(.caption.monospaced().weight(.semibold))
                        Text(row.1).font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

/// The add sheet on its own.
private struct KcComposerStage: View {
    @State private var saved: [String] = []
    @State private var shows = true

    var body: some View {
        MockAppScreen(title: "Vault", tint: .indigo) {
            VStack(spacing: 8) {
                ForEach(saved, id: \.self) { Label($0, systemImage: "lock.fill").font(.subheadline.weight(.semibold)) }
                Button { shows = true } label: { Label("New secret", systemImage: "plus").frame(maxWidth: .infinity) }
                    .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
        .sheet(isPresented: $shows) {
            KitoSecureItemComposer { title, kind, _, _ in saved.append("\(title) · \(kind.displayName)") }
                .presentationDetents([.large])
        }
    }
}

// MARK: - Code

private let vaultCode = """
@State private var vault = KitoSecureVault(service: "com.yourapp.vault")

KitoSecureVaultView(vault: vault, title: "Vault")
"""

private let revealCode = """
KitoRevealableSecret("Daraja API key", value: apiKey,
                     mask: .partial(prefix: 4, suffix: 4))

KitoRevealableSecret("M-Pesa PIN", mask: .dots) {
    vault.secret(for: pinItem)          // read only after Face ID passes
}
"""

// MARK: - Samples

enum KeychainSamples {
    static let sections: [KitSection] = [vaults, reveal, sessions, basics]

    static let vaults = KitSection("Secure vault", symbol: "lock.shield.fill", [
        KitSample("Secure notes vault", "PINs, passwords, cards and codes; Face ID to reveal.", code: vaultCode) {
            ModalStage { KcVaultStage(kcDemoEntries) }
        },
        KitSample("Token vault", "Access tokens and API keys, partially masked.", code: vaultCode) {
            ModalStage { KcVaultStage(kcTokenEntries, title: "Tokens") }
        },
        KitSample("Empty vault", "The first-run state with an add button.", code: vaultCode) {
            ModalStage { KcVaultStage([]) }
        },
        KitSample("Live keychain", "This app's real keychain, with real Face ID or passcode.", code: vaultCode) {
            ModalStage { KcLiveVaultStage() }
        },
        KitSample("Add a secret", "The composer: kind chips, a secure field and a note.", code: "KitoSecureItemComposer { title, kind, secret, detail in\n    vault.add(title, kind: kind, secret: secret, detail: detail)\n}") {
            ModalStage { KcComposerStage() }
        },
    ])

    static let reveal = KitSection("Reveal on Face ID", symbol: "eye.fill", [
        KitSample("API keys", "Prefix and suffix stay visible; the rest reveals.", code: revealCode) {
            KcSecretsCard(title: "Daraja", symbol: "chevron.left.forwardslash.chevron.right", tint: .green) {
                KcSecretField(label: "Consumer key", value: "sk_live_9f2aB71cQx0mZ44d", mask: .partial(prefix: 4, suffix: 4))
                KcSecretField(label: "Passkey", value: "bfb279f9aa9bdbcf158e97dd71a467cd", mask: .partial(prefix: 4, suffix: 4))
            }
        },
        KitSample("Card details", "Last four until it's really you.", code: revealCode.replacingOccurrences(of: ".partial(prefix: 4, suffix: 4)", with: ".lastFour")) {
            KcSecretsCard(title: "Equity Visa", symbol: "creditcard.fill", tint: .indigo) {
                KcSecretField(label: "Card number", value: "4242 8810 2291 4821", mask: .lastFour)
                KcSecretField(label: "CVV", value: "318")
            }
        },
        KitSample("Quick hide", "Hides itself after 5 seconds; watch the ring.", code: "KitoRevealableSecret(\"M-Pesa PIN\", value: pin, autoHide: .seconds(5))") {
            KcSecretsCard(title: "M-Pesa", symbol: "iphone.gen3", tint: .green) {
                KcSecretField(label: "M-Pesa PIN", value: "4821", autoHide: .seconds(5))
            }
        },
        KitSample("Face ID says no", "The gate refuses: the value stays hidden.", code: "KitoRevealableSecret(\"Recovery codes\", value: codes, gate: .deviceOwner)") {
            KcSecretsCard(title: "Google", symbol: "lifepreserver.fill", tint: .red) {
                KcSecretField(label: "Recovery codes", value: "8H2K-QP4M  T7XW-9D3L", gate: .simulated(allows: false))
            }
        },
        KitSample("Wi-Fi to share", "A multi-line secure note; copy it for a guest.", code: "KitoRevealableSecret(\"Home Wi-Fi\", value: note)\n// Copy is device-only and clears itself after a minute") {
            KcSecretsCard(title: "Home Wi-Fi", symbol: "wifi", tint: .blue) {
                KcSecretField(label: "Njenga_5G", value: "Network: Njenga_5G\nPassword: chai-na-mandazi")
            }
        },
        KitSample("Several at once", "A server's credentials, each revealed on its own.", code: revealCode) {
            KcSecretsCard(title: "Staging server", symbol: "server.rack", tint: .orange) {
                KcSecretField(label: "Host", value: "staging.wyksoftsinc.com", mask: .partial(prefix: 8, suffix: 4))
                KcSecretField(label: "User", value: "deploy", mask: .partial(prefix: 2, suffix: 0))
                KcSecretField(label: "Password", value: "Twiga-Kubwa-77")
            }
        },
        KitSample("Masks", "Dots, last four and partial.", code: "KitoSecretMask.partial(prefix: 4, suffix: 4).apply(to: key)   // sk_l••••••Z44d") { KcMasksPreview() },
    ])

    static let sessions = KitSection("Sessions", symbol: "person.badge.key.fill", [
        KitSample("Sign out wipes tokens", "Tokens live in the keychain until sign-out.", code: """
        vault.add("Access token", kind: .token, secret: accessToken, detail: "Expires in 15 min")
        // on sign-out
        vault.deleteAll()
        """) { KcSessionStage() },
    ])

    static let basics = KitSection("Keychain basics", symbol: "key.fill", [
        KitSample("Save, read, remove", "A round trip against the real keychain.", code: """
        let keychain = KitoKeychain(service: "com.yourapp.auth")
        try keychain.set(token, for: "accessToken")
        let token = try keychain.string(for: "accessToken")
        try keychain.remove("accessToken")
        """) { KcRoundTrip() },
        KitSample("Separate namespaces", "removeAll() on one service leaves the other alone.", code: """
        let auth = KitoKeychain(service: "com.yourapp.auth")
        let settings = KitoKeychain(service: "com.yourapp.settings")
        try auth.removeAll()        // settings keeps its items
        """) { KcNamespaces() },
        KitSample("When it's readable", "The four accessibility options.", code: "try keychain.set(refreshToken, for: \"refreshToken\",\n                 accessibility: .afterFirstUnlockThisDeviceOnly)") { KcAccessibilityPreview() },
    ])
}
