//
//  AuthSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoAuth

// MARK: - Mock server

/// Stands in for a real backend: "123456" (or "1234" for 4 digits) is the right code,
/// "1234" is the PIN, and every call takes a moment.
private enum MockAuth {
    static let user = "Wycliff N"
    static let email = "wycliff@example.com"
    static let phone = "+254 712 345 678"
    static let pin = "1234"

    static func pause(_ seconds: Double = 0.8) async {
        try? await Task.sleep(for: .seconds(seconds))
    }

    static func verify(_ code: String) async -> KitoAuthResult {
        await pause()
        return code == "123456" || code == "1234" ? .success : .failure(message: "That code isn’t right. Try 123456.")
    }

    static func send() async -> KitoAuthResult {
        await pause(0.6)
        return .success
    }

    static func checkPIN(_ pin: String) async -> KitoAuthResult {
        await pause(0.25)
        return pin == Self.pin ? .success : .failure(message: "Wrong passcode")
    }
}

/// A generated landscape for the photo welcome style, so the sample needs no assets.
@MainActor
private enum SamplePhoto {
    static let image: Image = {
        let scene = ZStack(alignment: .bottom) {
            LinearGradient(colors: [Color(red: 0.98, green: 0.62, blue: 0.38), Color(red: 0.86, green: 0.36, blue: 0.47),
                                    Color(red: 0.29, green: 0.2, blue: 0.47)], startPoint: .top, endPoint: .bottom)
            Circle().fill(Color(red: 1, green: 0.86, blue: 0.6)).frame(width: 220).offset(y: -420).blur(radius: 2)
            Mountains(peaks: [0.45, 0.2, 0.55, 0.3, 0.5]).fill(Color(red: 0.36, green: 0.18, blue: 0.38).opacity(0.8)).frame(height: 520)
            Mountains(peaks: [0.3, 0.6, 0.25, 0.5, 0.35]).fill(Color(red: 0.16, green: 0.1, blue: 0.24)).frame(height: 380)
        }
        .frame(width: 800, height: 1400)
        let renderer = ImageRenderer(content: scene)
        renderer.scale = 1
        guard let uiImage = renderer.uiImage else { return Image(systemName: "photo") }
        return Image(uiImage: uiImage)
    }()

    private struct Mountains: Shape {
        let peaks: [CGFloat]
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            let step = rect.width / CGFloat(max(1, peaks.count - 1))
            for (index, peak) in peaks.enumerated() {
                path.addLine(to: CGPoint(x: CGFloat(index) * step, y: rect.minY + rect.height * peak))
            }
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}

/// A small banner that says which callback fired.
private struct EventBanner: View {
    let text: String?

    var body: some View {
        Group {
            if let text {
                Text(text)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.systemBackground))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.primary))
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.35), value: text)
        .padding(.top, 12)
    }
}

/// Shows a banner for a moment.
@MainActor
@Observable
private final class Events {
    var text: String?
    func show(_ message: String) {
        text = message
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.6))
            if self.text == message { self.text = nil }
        }
    }
}

// MARK: - Welcome

private struct WelcomeDemo: View {
    let style: KitoWelcomeStyle
    var providers: [KitoAuthProvider] = [.apple, .google, .email, .phone]
    var title = "Kito"
    var subtitle = "Plan trips with friends and split every bill."
    @State private var events = Events()

    var body: some View {
        KitoWelcomeScreen(title: title, subtitle: subtitle, style: style, providers: providers,
                          logo: Image(systemName: "paperplane.fill")) { provider in
            events.show("Tapped \(provider.rawValue.capitalized)")
        } onSignIn: {
            events.show("Sign in tapped")
        }
        .overlay(alignment: .top) { EventBanner(text: events.text) }
    }
}

private struct PhotoWelcomeDemo: View {
    var body: some View {
        WelcomeDemo(style: .photo(SamplePhoto.image), subtitle: "Golden hour, every trip.")
    }
}

private let carouselPages = [
    KitoWelcomePage(systemImage: "map.fill", title: "Plan together", message: "Share one itinerary and vote on every stop."),
    KitoWelcomePage(systemImage: "creditcard.fill", title: "Split fairly", message: "Log costs as you go. Kito settles up in shillings or dollars."),
    KitoWelcomePage(systemImage: "bell.badge.fill", title: "Never miss a flight", message: "Gate changes and check-in reminders, on time."),
]

private struct ProviderStack: View {
    @State private var events = Events()

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                ForEach(KitoAuthProvider.allCases) { provider in
                    KitoProviderButton(provider) { events.show(provider.title) }
                }
            }
            VStack(spacing: 10) {
                ForEach(KitoAuthProvider.allCases) { provider in
                    KitoProviderButton(provider, onDark: true) { events.show(provider.title) }
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color(red: 0.12, green: 0.1, blue: 0.24).gradient))
        }
        .overlay(alignment: .top) { EventBanner(text: events.text).offset(y: -40) }
    }
}

// MARK: - Apple and passkeys

private struct AppleButtons: View {
    @State private var signedIn: String?

    var body: some View {
        VStack(spacing: 14) {
            KitoAppleSignInButton(.black) { credential in
                signedIn = credential.displayName ?? credential.email ?? "Apple ID \(credential.userID.prefix(6))…"
                return .success
            }
            KitoAppleSignInButton(.white, label: .signUp) { _ in .success }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.black))
            KitoAppleSignInButton(.outline, label: .signIn) { _ in .success }
            if let signedIn {
                Label("Signed in as \(signedIn)", systemImage: "checkmark.seal.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.green)
            }
        }
    }
}

private struct PasskeyDemo: View {
    let mode: KitoPasskeyButton.Mode
    private let passkeys = KitoPasskeys(relyingParty: "example.com")

    var body: some View {
        VStack(spacing: 12) {
            KitoPasskeyButton(mode) {
                let challenge = KitoPasskeys.sampleChallenge()      // from your server in real life
                switch mode {
                case .signIn:
                    _ = try await passkeys.signIn(challenge: challenge)
                case .create:
                    _ = try await passkeys.register(challenge: challenge, userID: Data("user-42".utf8), userName: MockAuth.email)
                }
                return .success
            }
            Text("example.com isn’t this app’s Associated Domain, so the system refuses and the button explains how to set it up.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct SignInSheet: View {
    @State private var events = Events()

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 14) {
                Spacer()
                Image(systemName: "paperplane.circle.fill").font(.system(size: 56)).foregroundStyle(.primary)
                Text("Welcome back").font(.title.bold())
                Text("Sign in to see your trips.").foregroundStyle(.secondary)
                Spacer()
                KitoAppleSignInButton(.black, label: .signIn) { _ in
                    await MockAuth.pause()
                    return .success
                }
                KitoPasskeyButton {
                    await MockAuth.pause()
                    return .success                                  // pretend the server accepted it
                }
                KitoProviderButton(.google) { events.show("Google tapped") }
                KitoProviderButton(.email) { events.show("Email tapped") }
            }
            .padding(24)
            EventBanner(text: events.text)
        }
    }
}

// MARK: - Codes

private struct CodeFieldStates: View {
    @State private var code = ""
    @State private var state: KitoCodeFieldState = .editing

    var body: some View {
        VStack(spacing: 18) {
            KitoCodeField(code: $code, length: 6, state: state, autoFocus: false) { value in
                state = value == "123456" ? .success : .error
            }
            Picker("State", selection: $state) {
                Text("Editing").tag(KitoCodeFieldState.editing)
                Text("Error").tag(KitoCodeFieldState.error)
                Text("Success").tag(KitoCodeFieldState.success)
            }
            .pickerStyle(.segmented)
            Button("Reset") {
                code = ""
                state = .editing
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            Text("Long-press to paste a whole SMS such as “Your code is 123-456”.")
                .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .onChange(of: code) { _, newValue in if newValue.count < 6 && state != .editing { state = .editing } }
    }
}

private struct PINCodeField: View {
    @State private var code = ""
    @State private var state: KitoCodeFieldState = .editing

    var body: some View {
        VStack(spacing: 14) {
            KitoCodeField(code: $code, length: 4, state: state, isSecure: true, autoFocus: false) { value in
                state = value == MockAuth.pin ? .success : .error
            }
            .frame(maxWidth: 260)
            Text(state == .success ? "Unlocked" : "PIN is 1234").font(.footnote).foregroundStyle(.secondary)
        }
        .onChange(of: code) { _, newValue in if newValue.count < 4 { state = .editing } }
    }
}

// MARK: - Passwords

private struct StrengthMeterDemo: View {
    @State private var password = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SecureField("New password", text: $password)
                .textContentType(.newPassword)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.primary.opacity(0.05)))
            KitoPasswordStrengthMeter(password: password, policy: .standard)
            HStack {
                ForEach(["password1", "Kitoridge7", "Kitoridge7!mango"], id: \.self) { sample in
                    Button(sample) { password = sample }
                        .font(.caption.monospaced())
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                }
            }
        }
    }
}

private struct PolicyComparison: View {
    @State private var password = "Kitoridge7"

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            TextField("Password", text: $password)
                .font(.body.monospaced())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.primary.opacity(0.05)))
            ForEach(["Relaxed", "Standard", "Strict"], id: \.self) { name in
                let policy = Self.policy(named: name)
                let evaluation = policy.evaluate(password)
                HStack {
                    Text(name).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(evaluation.strength.title.isEmpty ? "—" : evaluation.strength.title).foregroundStyle(.secondary)
                    Image(systemName: evaluation.isAcceptable ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(evaluation.isAcceptable ? .green : .red)
                        .contentTransition(.symbolEffect(.replace))
                }
                KitoPasswordStrengthMeter(password: password, policy: policy, showsChecklist: false)
            }
        }
    }

    private static func policy(named name: String) -> KitoPasswordPolicy {
        switch name {
        case "Relaxed": return .relaxed
        case "Strict": return .strict
        default: return .standard
        }
    }
}

// MARK: - App lock

private struct LockDemo: View {
    var configuration = KitoAppLockConfiguration(userName: MockAuth.user, storageKey: nil)
    @State private var locked = true

    var body: some View {
        ZStack {
            if locked {
                KitoAppLockScreen(configuration: configuration, verifyPIN: MockAuth.checkPIN) {
                    withAnimation(.spring(duration: 0.5)) { locked = false }
                }
                .forgotPasscode {}
                .transition(.opacity.combined(with: .scale(scale: 1.05)))
            } else {
                MockHome { withAnimation(.spring(duration: 0.5)) { locked = true } }
                    .transition(.opacity)
            }
        }
    }
}

private struct MockHome: View {
    let lock: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Trips").font(.largeTitle.bold()).padding(.top, 40)
            ForEach(["Diani, Dec 20", "Zanzibar, Feb 14", "Kigali, Apr 2"], id: \.self) { trip in
                HStack {
                    Image(systemName: "airplane").frame(width: 36, height: 36).background(Circle().fill(Color.primary.opacity(0.08)))
                    Text(trip).font(.body.weight(.medium))
                    Spacer()
                    Text("KES 48,200").font(.footnote.monospacedDigit()).foregroundStyle(.secondary)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.primary.opacity(0.04)))
            }
            Spacer()
            Button(action: lock) { Label("Lock now", systemImage: "lock.fill").frame(maxWidth: .infinity) }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
    }
}

private struct AppLockModifierDemo: View {
    @State private var locked = false

    var body: some View {
        MockHome { withAnimation { locked = true } }
            .kitoAppLock(isLocked: $locked, timeout: 0,
                         configuration: KitoAppLockConfiguration(userName: MockAuth.user, storageKey: nil),
                         verifyPIN: MockAuth.checkPIN)
    }
}

// MARK: - Two-factor

private struct TwoFactorDemo: View {
    @State private var finished = false

    var body: some View {
        ZStack {
            if finished {
                VStack(spacing: 14) {
                    Image(systemName: "checkmark.shield.fill").font(.system(size: 56)).foregroundStyle(.green)
                    Text("Two-factor is on").font(.title2.bold())
                    Button("Set up again") { withAnimation { finished = false } }.buttonStyle(GalleryPrimaryButtonStyle())
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                KitoTwoFactorSetup(issuer: "Kito", account: MockAuth.email) { code in
                    await MockAuth.pause(0.6)
                    return code == "123456" ? .success : .failure(message: "That code didn’t match. Try 123456.")
                }
                .onFinish { withAnimation(.spring) { finished = true } }
                .transition(.opacity)
            }
        }
    }
}

private struct OTPAuthQR: View {
    private let link = KitoOTPAuthURL(issuer: "Kito", account: MockAuth.email, secret: "JBSWY3DPEHPK3PXP")
    @State private var now = Date()

    var body: some View {
        VStack(spacing: 14) {
            if let image = KitoQRCode.image(for: link.string) {
                Image(uiImage: image).interpolation(.none).resizable().scaledToFit().frame(width: 180, height: 180)
                    .padding(12).background(RoundedRectangle(cornerRadius: 20).fill(.white))
            }
            Text(KitoBase32.group(link.secret).joined(separator: " ")).font(.body.monospaced().weight(.semibold))
            Text(link.string).font(.caption2.monospaced()).foregroundStyle(.secondary).multilineTextAlignment(.center)
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Label("Current code \(KitoTOTP.code(secret: link.secret, at: context.date) ?? "—")", systemImage: "clock")
                    .font(.footnote.monospacedDigit())
            }
        }
    }
}

// MARK: - Gallery

enum AuthSamples {
    private static let welcome = KitSection("Welcome", symbol: "hand.wave.fill", [
        KitSample("Gradient", "A drifting mesh gradient behind the provider buttons.", code: """
        KitoWelcomeScreen(title: "Kito", subtitle: "Plan trips with friends.", style: .gradient,
                          providers: [.apple, .google, .email, .phone], logo: Image("logo")) { provider in
            signIn(with: provider)
        } onSignIn: { showSignIn = true }
        """) {
            ModalStage { WelcomeDemo(style: .gradient) }
        },
        KitSample("Photo", "A full-bleed photo with a slow zoom and a scrim.", code: """
        KitoWelcomeScreen(title: "Kito", subtitle: "Plan trips with friends.", style: .photo(Image("hero"))) { provider in
            signIn(with: provider)
        } onSignIn: { showSignIn = true }
        """) {
            ModalStage { PhotoWelcomeDemo() }
        },
        KitSample("Carousel", "Value-prop pages that advance on their own until touched.", code: """
        KitoWelcomeScreen(title: "Kito", style: .carousel([
            KitoWelcomePage(systemImage: "map.fill", title: "Plan together", message: "Share one itinerary."),
            KitoWelcomePage(systemImage: "creditcard.fill", title: "Split fairly", message: "Settle up in shillings."),
        ]), providers: [.apple, .email]) { provider in signIn(with: provider) } onSignIn: { showSignIn = true }
        """) {
            ModalStage { WelcomeDemo(style: .carousel(carouselPages), providers: [.apple, .email]) }
        },
        KitSample("Minimal", "Logo, title and buttons on the theme background.", code: """
        KitoWelcomeScreen(title: "Kito", subtitle: "Sign in to continue.", style: .minimal,
                          providers: [.apple, .google, .phone]) { provider in signIn(with: provider) }
        """) {
            ModalStage { WelcomeDemo(style: .minimal, providers: [.apple, .google, .phone], subtitle: "Sign in to continue.") }
        },
        KitSample("Provider buttons", "Apple, Google, email and phone, on light and on dark.", code: """
        KitoProviderButton(.google) { googleSignIn() }            // styled button only, bring your own SDK
        KitoProviderButton(.apple, onDark: true) { … }
        """) { ProviderStack() },
    ])

    private static let apple = KitSection("Apple & passkeys", symbol: "person.badge.key.fill", [
        KitSample("Sign in with Apple", "Black, white and outline capsules; morphs to a tick on success.", code: """
        KitoAppleSignInButton(.black) { credential in
            try await api.signIn(appleToken: credential.identityToken, name: credential.name)
            return .success
        }
        KitoAppleSignInButton(.white, label: .signUp) { … }
        KitoAppleSignInButton(.outline, label: .signIn) { … }
        """) { AppleButtons() },
        KitSample("Passkey sign in", "Assertion from your server’s challenge, with a friendly setup error.", code: """
        let passkeys = KitoPasskeys(relyingParty: "example.com")
        KitoPasskeyButton {
            let assertion = try await passkeys.signIn(challenge: try await api.challenge())
            return try await api.verify(assertion) ? .success : .failure(message: "Passkey not recognised")
        }
        """) { PasskeyDemo(mode: .signIn) },
        KitSample("Create a passkey", "Register a new passkey for the signed-in account.", code: """
        KitoPasskeyButton(.create) {
            let registration = try await passkeys.register(challenge: challenge, userID: user.handle,
                                                           userName: user.email)
            try await api.store(registration)
            return .success
        }
        """) { PasskeyDemo(mode: .create) },
        KitSample("Sign-in sheet", "Apple, passkey, Google and email together; mock server.", code: """
        KitoAppleSignInButton(.black, label: .signIn) { credential in try await api.apple(credential) }
        KitoPasskeyButton { try await api.passkey() }
        KitoProviderButton(.google) { googleSignIn() }
        KitoProviderButton(.email) { path.append(.email) }
        """) {
            ModalStage { SignInSheet() }
        },
    ])

    private static let codes = KitSection("Codes & links", symbol: "number.square.fill", [
        KitSample("Verify by SMS", "Channel chips, resend ring, shake on a wrong code. Try 123456.", code: """
        KitoOTPScreen(destination: "+254 712 345 678") { code in
            try await api.verify(code) ? .success : .failure(message: "That code isn’t right")
        }
        .channels([.sms, .whatsApp, .email])
        .resend(after: 30) { channel in try await api.sendCode(via: channel); return .success }
        .changeDestination { dismiss() }
        .onVerified { router.push(.home) }
        """) {
            ModalStage {
                KitoOTPScreen(destination: MockAuth.phone, onVerify: MockAuth.verify)
                    .channels([.sms, .whatsApp, .email])
                    .resend(after: 30) { _ in await MockAuth.send() }
                    .changeDestination {}
            }
        },
        KitSample("Email code, 4 digits", "Shorter codes by email. Try 1234.", code: """
        KitoOTPScreen(destination: "wycliff@example.com", length: 4, onVerify: verify)
            .channels([.email])
            .resend(after: 20) { _ in try await api.resend(); return .success }
        """) {
            ModalStage {
                KitoOTPScreen(destination: MockAuth.email, length: 4, onVerify: MockAuth.verify)
                    .channels([.email])
                    .resend(after: 20) { _ in await MockAuth.send() }
                    .changeDestination {}
            }
        },
        KitSample("Code field", "Just the boxes: editing, error and success states.", code: """
        KitoCodeField(code: $code, length: 6, state: state) { code in
            state = code == expected ? .success : .error
        }
        """) { CodeFieldStates() },
        KitSample("Secure PIN field", "Dots instead of digits for a 4-digit PIN.", code: """
        KitoCodeField(code: $pin, length: 4, state: state, isSecure: true) { pin in check(pin) }
        """) { PINCodeField() },
        KitSample("Magic link", "An envelope that opens, Open Mail, and a resend countdown.", code: """
        KitoMagicLinkScreen(email: "wycliff@example.com") {
            try await api.sendMagicLink(to: email); return .success
        }
        .resendCooldown(60)
        .changeEmail { dismiss() }
        """) {
            ModalStage {
                KitoMagicLinkScreen(email: MockAuth.email, onResend: MockAuth.send)
                    .resendCooldown(15)
                    .changeEmail {}
            }
        },
    ])

    private static let passwords = KitSection("Passwords", symbol: "key.fill", [
        KitSample("Forgot password", "Email, code (123456), new password with a live checklist, done.", code: """
        KitoForgotPasswordFlow(email: typedEmail) { email in
            try await api.sendResetCode(to: email); return .success
        } verifyCode: { email, code in
            try await api.checkResetCode(code, for: email) ? .success : .failure(message: "Wrong code")
        } resetPassword: { reset in
            try await api.resetPassword(reset.newPassword, code: reset.code, email: reset.email)
            return .success
        }
        .onFinish { dismiss() }
        """) {
            ModalStage {
                KitoForgotPasswordFlow(email: MockAuth.email) { _ in
                    await MockAuth.send()
                } verifyCode: { _, code in
                    await MockAuth.verify(code)
                } resetPassword: { _ in
                    await MockAuth.pause()
                    return .success
                }
                .resendCooldown(20)
            }
        },
        KitSample("Strength meter", "Four segments and a checklist that ticks as you type.", code: """
        SecureField("New password", text: $password)
        KitoPasswordStrengthMeter(password: password, policy: .standard)
        """) { StrengthMeterDemo() },
        KitSample("Policies", "Relaxed, standard and strict against the same password.", code: """
        let evaluation = KitoPasswordPolicy.strict.evaluate(password)
        evaluation.strength       // .empty, .weak, .fair, .good, .strong
        evaluation.isAcceptable   // every rule met and strong enough
        """) { PolicyComparison() },
    ])

    private static let lock = KitSection("App lock", symbol: "lock.fill", [
        KitSample("Lock screen", "Face ID first, then a PIN pad. The PIN is 1234.", code: """
        KitoAppLockScreen(configuration: .init(userName: "Wycliff N")) { pin in
            pin == keychain.pin ? .success : .failure(message: "Wrong passcode")
        } onUnlock: { isLocked = false }
        """) {
            ModalStage { LockDemo() }
        },
        KitSample("Lockout", "Three wrong PINs lock the pad for 15 seconds, then longer.", code: """
        KitoAppLockConfiguration(lockout: KitoLockoutPolicy(maxAttempts: 3, lockoutDurations: [15, 60, 300]))
        """) {
            ModalStage {
                LockDemo(configuration: KitoAppLockConfiguration(userName: MockAuth.user, allowsBiometrics: false,
                                                                 lockout: KitoLockoutPolicy(maxAttempts: 3, lockoutDurations: [15, 60, 300]),
                                                                 storageKey: nil))
            }
        },
        KitSample("Lock the whole app", "Locks on background or after a timeout and blurs the app switcher.", code: """
        ContentView()
            .kitoAppLock(isLocked: $isLocked, timeout: 30) { pin in
                pin == keychain.pin ? .success : .failure(message: "Wrong passcode")
            }
        """) {
            ModalStage { AppLockModifierDemo() }
        },
    ])

    private static let twoFactor = KitSection("Two-factor", symbol: "lock.shield.fill", [
        KitSample("Authenticator setup", "QR code, key in groups, verify (123456), recovery codes.", code: """
        KitoTwoFactorSetup(issuer: "Kito", account: "wycliff@example.com", secret: server.secret,
                           recoveryCodes: server.recoveryCodes) { code in
            try await api.confirmTwoFactor(code) ? .success : .failure(message: "That code didn’t match")
        }
        .onFinish { dismiss() }
        """) {
            ModalStage { TwoFactorDemo() }
        },
        KitSample("Recovery codes", "A numbered grid with Copy all and Share.", code: """
        KitoRecoveryCodesView(codes: KitoRecoveryCodes.generate(count: 10))
        """) { KitoRecoveryCodesView(codes: KitoRecoveryCodes.generate(count: 8)) },
        KitSample("otpauth QR", "Build the URL, draw the QR, and compute the live code.", code: """
        let link = KitoOTPAuthURL(issuer: "Kito", account: "wycliff@example.com", secret: secret)
        let qr = KitoQRCode.image(for: link.string)
        let code = KitoTOTP.code(secret: secret)                  // "287082"
        KitoBase32.group(secret)                                  // ["JBSW", "Y3DP", "EHPK", "3PXP"]
        """) { OTPAuthQR() },
    ])

    static let sections: [KitSection] = [welcome, apple, codes, passwords, lock, twoFactor]
}

struct AuthGallery: View {
    static var count: Int { KitGallery.count(AuthSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Auth",
            sections: AuthSamples.sections,
            footnote: "Requires `import KitoAuth`.",
            searchHint: "Try “passkey”, “code”, “password”, “lock” or “QR”."
        )
    }
}
