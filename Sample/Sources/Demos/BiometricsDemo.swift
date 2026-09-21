//
//  BiometricsDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoBiometrics

struct BiometricsDemo: View {
    @State private var resultText = "Not attempted"
    private let authenticator = KitoBiometricAuthenticator()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: authenticator.availableBiometricType == .faceID ? "faceid" : "touchid")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("Available: \(biometricLabel)")
                .font(.subheadline)

            Button("Authenticate") {
                Task {
                    switch await authenticator.authenticate(reason: "Confirm it's you") {
                    case .success: resultText = "Success"
                    case .failed(let reason): resultText = "Failed: \(reason)"
                    case .unavailable(let reason): resultText = "Unavailable: \(reason)"
                    case .userCancelled: resultText = "Cancelled"
                    }
                }
            }

            Text(resultText).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Biometrics")
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
