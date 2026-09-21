//
//  BiometricsDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoBiometrics

struct BiometricsDemo: View {
    var body: some View {
        List {
            NavigationLink("Direct authenticate call") { DirectAuthDemo() }
            NavigationLink("Drop-in lock screen") { LockScreenDemo() }
        }
        .navigationTitle("Biometrics")
    }
}

private struct DirectAuthDemo: View {
    @State private var resultText = "Not attempted"
    private let authenticator = KitoBiometricAuthenticator()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: authenticator.availableBiometricType == .faceID ? "faceid" : "touchid")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
            Text("Available: \(biometricLabel)").font(.subheadline)
            Button("Authenticate — generic reason") {
                Task { resultText = await run(reason: "Confirm it's you") }
            }
            Button("Authenticate — payment-specific reason") {
                Task { resultText = await run(reason: "Confirm your $42.00 purchase") }
            }
            Text(resultText).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Direct call")
    }

    private func run(reason: String) async -> String {
        switch await authenticator.authenticate(reason: reason) {
        case .success: return "Success"
        case .failed(let reason): return "Failed: \(reason)"
        case .unavailable(let reason): return "Unavailable: \(reason)"
        case .userCancelled: return "Cancelled"
        }
    }

    private var biometricLabel: String {
        switch authenticator.availableBiometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none: return "None (passcode fallback)"
        }
    }
}

private struct LockScreenDemo: View {
    var body: some View {
        KitoBiometricLockView(reason: "Unlock to view your card") {
            VStack(spacing: 16) {
                Image(systemName: "creditcard.fill").font(.system(size: 48)).foregroundStyle(.green)
                Text("4242 4242 4242 4242").font(.title3.monospaced())
                Text("This content only appears after a successful biometric check.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Lock screen")
    }
}
