//
//  PesaConfirm.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoModals
import KitoBiometrics
import KitoNavigation
import KitoToasts
import KitoHaptics

extension WalletShowcase {
    /// Face ID before money moves. Where there is no enrolled face (the Simulator) it plays a
    /// simulated scan instead, so the demo still shows the moment.
    @MainActor
    final class PesaBiometricGate: ObservableObject {
        @Published var state: KitoBiometricGlyphState = .idle
        @Published var isShowing = false

        func confirm(reason: String) async -> Bool {
            withAnimation(.snappy) { isShowing = true; state = .scanning }
            var result = await KitoBiometricAuthenticator().authenticate(reason: reason)
            if case .unavailable = result {
                result = await KitoSimulatedBiometricAuthenticator(type: .faceID, result: .success).authenticate(reason: reason)
            }
            let passed: Bool
            if case .success = result { passed = true } else { passed = false }
            withAnimation(.snappy) { state = passed ? .success : .failure }
            if passed { KitoHaptics.success() } else { KitoHaptics.error() }
            try? await Task.sleep(for: .milliseconds(passed ? 650 : 900))
            withAnimation(.snappy) { isShowing = false; state = .idle }
            return passed
        }
    }

    /// The Face ID glyph on a frosted card while the gate checks.
    struct PesaBiometricOverlay: View {
        @ObservedObject var gate: PesaBiometricGate

        var body: some View {
            if gate.isShowing {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
                    VStack(spacing: 16) {
                        KitoBiometricGlyph(type: .faceID, state: gate.state, size: 84)
                        Text(title).font(.headline)
                    }
                    .padding(32)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .accessibilityElement(children: .combine)
                }
                .transition(.opacity)
            }
        }

        private var title: String {
            switch gate.state {
            case .success: "Confirmed"
            case .failure: "Face not recognised"
            default: "Confirm with Face ID"
            }
        }
    }

    // MARK: - Review

    struct PesaReviewStep: View {
        @Bindable var store: PesaStore
        @Bindable var draft: PesaSendDraft
        let sent: (PesaTransaction) -> Void

        @Environment(KitoToastCenter.self) private var toasts
        @StateObject private var gate = PesaBiometricGate()
        @State private var attempt = 0

        private var card: PesaCard { store.card(draft.cardID) ?? store.mainCard }

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    if let contact = draft.contact {
                        VStack(spacing: 10) {
                            KitoAvatar(initials: contact.initials, colors: [contact.color, contact.color.opacity(0.6)], size: 72, showsRing: true)
                            Text("You’re sending").font(.subheadline).foregroundStyle(.secondary)
                            Text(PesaMoney.string(draft.amount))
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .monospacedDigit()
                            Text("to \(contact.name)").font(.headline)
                        }
                        .accessibilityElement(children: .combine)
                        .padding(.top, 8)
                    }

                    VStack(spacing: 0) {
                        row("From", "\(card.name) \(card.face.maskedNumber)")
                        Divider()
                        row("To", draft.contact?.maskedPhone ?? "")
                        Divider()
                        row("Fee", "Free")
                        Divider()
                        row("Arrives", "Instantly")
                        if !draft.note.trimmingCharacters(in: .whitespaces).isEmpty {
                            Divider()
                            row("Note", draft.note)
                        }
                        Divider()
                        row("Balance after", PesaMoney.string(card.balance - draft.amount))
                    }
                    .pesaSurface()

                    Label(store.confirmsWithBiometrics ? "You’ll confirm with Face ID" : "Face ID is off for payments in Profile",
                          systemImage: store.confirmsWithBiometrics ? "faceid" : "lock.open")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                KitoSlideToConfirm("Slide to send", systemImage: "arrow.right", tint: .primary) { await confirm() }
                    .frame(height: 64)
                    .id(attempt)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            .overlay { PesaBiometricOverlay(gate: gate) }
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(gate.isShowing)
        }

        private func confirm() async {
            guard let contact = draft.contact else { return }
            if store.confirmsWithBiometrics {
                let passed = await gate.confirm(reason: "Send \(PesaMoney.string(draft.amount)) to \(contact.firstName)")
                guard passed else {
                    attempt += 1
                    toasts.show("Not sent. Try again when you’re ready.", style: .warning)
                    return
                }
            } else {
                try? await Task.sleep(for: .milliseconds(700))
            }
            let transaction = withAnimation(.snappy) {
                store.send(draft.amount, to: contact, note: draft.note.isEmpty ? nil : draft.note, from: card.id)
            }
            try? await Task.sleep(for: .milliseconds(450))
            sent(transaction)
        }

        private func row(_ title: String, _ value: String) -> some View {
            HStack(alignment: .firstTextBaseline) {
                Text(title).foregroundStyle(.secondary)
                Spacer(minLength: 16)
                Text(value).multilineTextAlignment(.trailing).monospacedDigit()
            }
            .padding(.vertical, 12)
            .accessibilityElement(children: .combine)
        }
    }
}
