//
//  BiometricsSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoBiometrics

// The simulator has no enrolled face, so most samples use a simulated authenticator that
// answers on cue. Samples marked "Live" use the device's real Face ID / Touch ID.

private let bioWycliff = "Wycliff N"

// MARK: - Stages

/// A lock screen that, once unlocked, shows a wallet home with a Lock again button.
private struct BioLockStage: View {
    let style: KitoBiometricLockStyle
    var title = "Locked"
    var message: String?
    var passcode: String?
    let makeAuthenticator: () -> any KitoBiometricAuthenticating
    @State private var authenticator: any KitoBiometricAuthenticating
    @State private var isUnlocked = false
    @State private var run = 0

    init(style: KitoBiometricLockStyle, title: String = "Locked", message: String? = nil, passcode: String? = nil, makeAuthenticator: @escaping () -> any KitoBiometricAuthenticating) {
        self.style = style
        self.title = title
        self.message = message
        self.passcode = passcode
        self.makeAuthenticator = makeAuthenticator
        _authenticator = State(initialValue: makeAuthenticator())
    }

    var body: some View {
        ZStack {
            if isUnlocked {
                BioUnlockedHome {
                    authenticator = makeAuthenticator()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { isUnlocked = false; run += 1 }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
            } else {
                KitoBiometricLockScreen(style: style, title: title, message: message, reason: "Unlock Kito Wallet", userName: bioWycliff, passcode: passcode, authenticator: authenticator) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { isUnlocked = true }
                }
                .id(run)
                .transition(.opacity)
            }
        }
    }
}

/// What's behind the lock.
private struct BioUnlockedHome: View {
    let relock: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Habari, Wycliff").font(.title2.bold())
                    Text("Unlocked just now").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: relock) { Label("Lock", systemImage: "lock.fill") }
                    .buttonStyle(GalleryPrimaryButtonStyle())
            }
            .padding(.top, 50)
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.05, green: 0.45, blue: 0.30), Color(red: 0.02, green: 0.20, blue: 0.16)], startPoint: .topLeading, endPoint: .bottomTrailing))
                VStack(alignment: .leading, spacing: 6) {
                    Text("M-PESA BALANCE").font(.caption.weight(.bold)).kerning(1).foregroundStyle(.white.opacity(0.7))
                    Text("KSh 48,250.00").font(.system(size: 32, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    Text("Fuliza available · KSh 5,000").font(.footnote).foregroundStyle(.white.opacity(0.75))
                }
                .padding(22)
            }
            .frame(height: 170)
            ForEach([("Sent to Amina Wanjiru", "−KSh 2,500", "arrow.up.right"), ("KPLC tokens", "−KSh 1,000", "bolt.fill"), ("Received from Brian Otieno", "+KSh 7,800", "arrow.down.left")], id: \.0) { row in
                HStack(spacing: 12) {
                    Image(systemName: row.2).font(.subheadline.weight(.bold)).frame(width: 40, height: 40).background(Circle().fill(Color.primary.opacity(0.07)))
                    Text(row.0).font(.subheadline.weight(.medium))
                    Spacer()
                    Text(row.1).font(.subheadline.monospacedDigit()).foregroundStyle(row.1.hasPrefix("+") ? .green : .primary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
    }
}

/// Every glyph state in a grid, plus Touch ID.
private struct BioGlyphStatesPreview: View {
    var body: some View {
        VStack(spacing: 22) {
            HStack(spacing: 18) {
                ForEach([KitoBiometricGlyphState.idle, .scanning, .success, .failure], id: \.self) { state in
                    VStack(spacing: 8) {
                        KitoBiometricGlyph(type: .faceID, state: state, size: 54)
                        Text(String(describing: state).capitalized).font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            HStack(spacing: 18) {
                ForEach([KitoBiometricGlyphState.idle, .scanning, .success, .failure], id: \.self) { state in
                    KitoBiometricGlyph(type: .touchID, state: state, size: 54).frame(maxWidth: .infinity)
                }
            }
        }
    }
}

/// Tap to run a full check; alternates success and failure.
private struct BioGlyphPlayground: View {
    @State private var state: KitoBiometricGlyphState = .idle
    @State private var succeeds = true
    @State private var type: KitoBiometricType = .faceID

    var body: some View {
        VStack(spacing: 22) {
            KitoBiometricGlyph(type: type, state: state, size: 110)
                .frame(height: 130)
            Picker("Type", selection: $type) {
                Text("Face ID").tag(KitoBiometricType.faceID)
                Text("Touch ID").tag(KitoBiometricType.touchID)
            }
            .pickerStyle(.segmented)
            Button {
                Task {
                    state = .scanning
                    try? await Task.sleep(for: .milliseconds(1_300))
                    state = succeeds ? .success : .failure
                    succeeds.toggle()
                    try? await Task.sleep(for: .milliseconds(1_200))
                    state = .idle
                }
            } label: { Label(succeeds ? "Run a check (passes)" : "Run a check (fails)", systemImage: "play.fill").frame(maxWidth: .infinity) }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(state != .idle)
        }
    }
}

/// Tinted glyphs on brand colours.
private struct BioGlyphTintsPreview: View {
    private let swatches: [(Color, Color)] = [(.white, Color(red: 0.05, green: 0.40, blue: 0.28)), (.black, Color(red: 0.98, green: 0.80, blue: 0.20)), (.white, Color(red: 0.35, green: 0.20, blue: 0.85)), (Color(red: 0.93, green: 0.76, blue: 0.42), .black)]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(swatches.enumerated()), id: \.offset) { _, swatch in
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(swatch.1)
                    .frame(height: 96)
                    .overlay(KitoBiometricGlyph(type: .faceID, state: .idle, size: 44, tint: swatch.0))
            }
        }
    }
}

/// A balance hidden until Face ID confirms.
private struct BioRevealBalance: View {
    let authenticator: any KitoBiometricAuthenticating
    @State private var shows = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("M-PESA BALANCE").font(.caption.weight(.bold)).kerning(1).foregroundStyle(.white.opacity(0.7))
            HStack {
                Text(shows ? "KSh 48,250.00" : "KSh ••••••")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                Spacer()
                Image(systemName: shows ? "eye.slash.fill" : "eye.fill").foregroundStyle(.white.opacity(0.8))
            }
            .padding(12)
            .kitoProtectedAction(reason: "Show your balance", authenticator: authenticator) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { shows = true }
            }
            if shows {
                Button("Hide") { withAnimation { shows = false } }.font(.footnote.weight(.semibold)).foregroundStyle(.white)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(LinearGradient(colors: [Color(red: 0.05, green: 0.45, blue: 0.30), Color(red: 0.02, green: 0.20, blue: 0.16)], startPoint: .topLeading, endPoint: .bottomTrailing)))
    }
}

/// Send money, confirmed with Face ID.
private struct BioSendMoney: View {
    let authenticator: any KitoBiometricAuthenticating
    @State private var sent = false
    @State private var failed = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Text("AW").font(.headline).foregroundStyle(.white).frame(width: 48, height: 48).background(Circle().fill(Color.orange.gradient))
                VStack(alignment: .leading) {
                    Text("Amina Wanjiru").font(.headline)
                    Text("0712 ••• 489").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Text("KSh 2,500").font(.title3.bold().monospacedDigit())
            }
            Label(sent ? "Sent · Ref SJK4M2X9QP" : failed ? "Not sent — Face ID didn't match" : "Send KSh 2,500", systemImage: sent ? "checkmark.circle.fill" : "faceid")
                .font(.headline)
                .foregroundStyle(Color(.systemBackground))
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(Capsule().fill(sent ? Color.green : failed ? Color.red : Color.primary))
                .kitoProtectedAction(reason: "Send KSh 2,500 to Amina", authenticator: authenticator, onFailure: { _ in withAnimation { failed = true } }) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { sent = true; failed = false }
                }
            if sent || failed {
                Button("Reset") { withAnimation { sent = false; failed = false } }.font(.footnote.weight(.semibold))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}

/// A card number revealed behind Face ID.
private struct BioCardNumber: View {
    let authenticator: any KitoBiometricAuthenticating
    @State private var shows = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.12, green: 0.12, blue: 0.16), Color(red: 0.30, green: 0.22, blue: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Equity · Visa").font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "wave.3.right").font(.subheadline)
                }
                Text(shows ? "4242 8810 2291 4821" : "•••• •••• •••• 4821")
                    .font(.system(size: 21, weight: .semibold, design: .monospaced))
                    .contentTransition(.interpolate)
                    .kitoProtectedAction(reason: "Show card number", authenticator: authenticator) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { shows.toggle() }
                    }
                HStack {
                    Text("WYCLIFF N").font(.caption.weight(.semibold)).kerning(1)
                    Spacer()
                    Text(shows ? "CVV 318 · 09/29" : "Tap the number").font(.caption.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .padding(22)
        }
        .frame(height: 200)
    }
}

/// A settings row that turns the app lock on, and a screen locked behind it.
private struct BioAppLockStage: View {
    @State private var isEnabled = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $isEnabled) { Label("Require Face ID", systemImage: "faceid") }
                } footer: {
                    Text("Locks when the app goes to the background and blurs it in the app switcher. Open full screen and swipe home to try it.")
                }
                Section("Recent") {
                    Label("Paid Naivas · KSh 3,120", systemImage: "cart.fill")
                    Label("Received from Brian · KSh 7,800", systemImage: "arrow.down.left")
                }
            }
            .navigationTitle("Security")
        }
        .kitoBiometricAppLock(isEnabled: isEnabled, style: .glass, reason: "Unlock Kito Wallet", userName: bioWycliff, authenticator: KitoSimulatedBiometricAuthenticator())
    }
}

/// The 1.0 wrapper with a style.
private struct BioWrappedCard: View {
    @State private var run = 0

    var body: some View {
        KitoBiometricLockView(reason: "Unlock to view your card", style: .vault, authenticator: KitoSimulatedBiometricAuthenticator(delay: .milliseconds(1_400))) {
            VStack(spacing: 18) {
                BioCardNumber(authenticator: KitoSimulatedBiometricAuthenticator(delay: .milliseconds(600)))
                Text("Only shown after a successful check.").font(.footnote).foregroundStyle(.secondary)
                Button("Lock again") { run += 1 }.buttonStyle(GalleryPrimaryButtonStyle())
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .id(run)
    }
}

/// The real authenticator, called directly.
private struct BioDirectCall: View {
    @State private var result = "Not tried yet"
    private let authenticator = KitoBiometricAuthenticator()

    var body: some View {
        VStack(spacing: 16) {
            KitoBiometricGlyph(type: authenticator.availableBiometricType == .none ? .faceID : authenticator.availableBiometricType, state: .idle, size: 64)
            Text("This device: \(authenticator.availableBiometricType.displayName)").font(.subheadline.weight(.semibold))
            Button { Task { result = await describe(authenticator.authenticate(reason: "Confirm it's you")) } } label: {
                Text("Authenticate").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            Text(result).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
    }

    private func describe(_ result: KitoBiometricResult) -> String {
        switch result {
        case .success: return "Success"
        case .failed(let reason): return "Failed: \(reason)"
        case .unavailable(let reason): return "Unavailable: \(reason)"
        case .userCancelled: return "Cancelled"
        }
    }
}

// MARK: - Code

private let lockCode = """
KitoBiometricLockScreen(style: .glass, userName: "Wycliff N",
                        reason: "Unlock Kito Wallet") {
    isUnlocked = true
}
"""

private let protectCode = """
Text(showsBalance ? "KSh 48,250.00" : "KSh ••••••")
    .kitoProtectedAction(reason: "Show your balance") {
        showsBalance = true
    }
"""

private let appLockCode = """
RootView()
    .kitoBiometricAppLock(isEnabled: settings.requiresFaceID,
                          style: .glass, userName: "Wycliff N")
"""

// MARK: - Samples

enum BiometricsSamples {
    static let sections: [KitSection] = [locks, glyphs, protect, appLock, basics]

    static let locks = KitSection("Lock screens", symbol: "lock.rectangle.stack.fill", [
        KitSample("Minimal", "The glyph, a title and one button.", code: lockCode.replacingOccurrences(of: ".glass", with: ".minimal")) {
            ModalStage { BioLockStage(style: .minimal, title: "Kito Wallet", makeAuthenticator: { KitoSimulatedBiometricAuthenticator() }) }
        },
        KitSample("Glass", "Initials on a frosted card over drifting colour.", code: lockCode) {
            ModalStage { BioLockStage(style: .glass, makeAuthenticator: { KitoSimulatedBiometricAuthenticator() }) }
        },
        KitSample("Passcode keypad", "Six digits, with Face ID on the keypad. Try 240926.", code: lockCode.replacingOccurrences(of: ".glass", with: ".passcode").replacingOccurrences(of: "userName: \"Wycliff N\",", with: "passcode: storedPasscode,")) {
            ModalStage { BioLockStage(style: .passcode, passcode: "240926", makeAuthenticator: { KitoSimulatedBiometricAuthenticator() }) }
        },
        KitSample("Vault", "Dark, with a dial that spins while it checks.", code: lockCode.replacingOccurrences(of: ".glass", with: ".vault")) {
            ModalStage { BioLockStage(style: .vault, title: "Savings vault", message: "KSh 250,000 goal · Face ID to open", makeAuthenticator: { KitoSimulatedBiometricAuthenticator(delay: .milliseconds(1_500)) }) }
        },
        KitSample("Not recognised, then yes", "The first try fails and shakes; tap to try again.", code: "KitoBiometricLockScreen(style: .minimal) { … }\n// failures shake and explain; after three, passcode takes over") {
            ModalStage { BioLockStage(style: .minimal, title: "Kito Wallet", makeAuthenticator: { KitoFlakyBiometricAuthenticator(failures: 1) }) }
        },
        KitSample("Three strikes → passcode", "After three failures the keypad takes over.", code: "KitoBiometricLockScreen(style: .glass, passcode: storedPasscode) { … }") {
            ModalStage { BioLockStage(style: .glass, passcode: "240926", makeAuthenticator: { KitoFlakyBiometricAuthenticator(failures: 3, delay: .milliseconds(700)) }) }
        },
        KitSample("Live Face ID", "The device's real biometrics (the simulator unlocks straight away).", code: lockCode.replacingOccurrences(of: ".glass", with: ".minimal")) {
            ModalStage { BioLockStage(style: .minimal, title: "Kito Wallet", makeAuthenticator: { KitoBiometricAuthenticator() }) }
        },
    ])

    static let glyphs = KitSection("Animated glyph", symbol: "faceid", [
        KitSample("Every state", "Idle, scanning, success and failure, for Face ID and Touch ID.", code: "KitoBiometricGlyph(type: .faceID, state: .scanning)") { BioGlyphStatesPreview() },
        KitSample("Playground", "Run a check that passes, then one that fails.", code: "KitoBiometricGlyph(type: type, state: state, size: 110)") { BioGlyphPlayground() },
        KitSample("On brand colours", "Tinted to sit on any surface.", code: "KitoBiometricGlyph(state: .idle, size: 44, tint: .white)") { BioGlyphTintsPreview() },
    ])

    static let protect = KitSection("Protect an action", symbol: "hand.raised.fingers.spread.fill", [
        KitSample("Show balance", "Tap the balance; it frosts over while Face ID checks.", code: protectCode) {
            BioRevealBalance(authenticator: KitoSimulatedBiometricAuthenticator())
        },
        KitSample("Send money", "Confirm KSh 2,500 to Amina.", code: protectCode.replacingOccurrences(of: "Show your balance", with: "Send KSh 2,500 to Amina")) {
            BioSendMoney(authenticator: KitoSimulatedBiometricAuthenticator())
        },
        KitSample("Face doesn't match", "The check fails: the button shakes and nothing is sent.", code: ".kitoProtectedAction(reason: \"…\", onFailure: { result in showError(result) }) { send() }") {
            BioSendMoney(authenticator: KitoSimulatedBiometricAuthenticator(result: .failed(reason: "Face not recognised")))
        },
        KitSample("Reveal card number", "Tap the number to show or hide it.", code: protectCode.replacingOccurrences(of: "Show your balance", with: "Show card number")) {
            BioCardNumber(authenticator: KitoSimulatedBiometricAuthenticator(delay: .milliseconds(800)))
        },
    ])

    static let appLock = KitSection("App lock", symbol: "lock.app.dashed", [
        KitSample("Lock on launch and background", "A settings toggle drives it; blurred in the app switcher.", code: appLockCode) {
            ModalStage { BioAppLockStage() }
        },
    ])

    static let basics = KitSection("Wrap content & direct calls", symbol: "curlybraces", [
        KitSample("Wrap sensitive content", "KitoBiometricLockView with the vault style.", code: "KitoBiometricLockView(reason: \"Unlock to view your card\", style: .vault) {\n    CardDetailsView(card: card)\n}") {
            ModalStage { BioWrappedCard() }
        },
        KitSample("Direct call", "The real authenticator and its four results.", code: """
        switch await KitoBiometricAuthenticator().authenticate(reason: "Confirm it's you") {
        case .success: unlock()
        case .failed(let reason): showError(reason)
        case .unavailable: fallBackToPasscode()
        case .userCancelled: break
        }
        """) { BioDirectCall() },
    ])
}
