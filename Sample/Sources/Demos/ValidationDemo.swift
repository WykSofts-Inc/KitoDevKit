//
//  ValidationDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoValidation

struct ValidationDemo: View {
    @State private var email = ""
    @State private var password = ""

    private var emailError: String? { email.isEmpty ? nil : kitoValidate(email, rules: [.required(), .email()]) }
    private var passwordError: String? { password.isEmpty ? nil : kitoValidate(password, rules: [.required(), .minLength(8)]) }
    private var strength: KitoPasswordStrength { .evaluate(password) }

    var body: some View {
        Form {
            Section("Email") {
                TextField("you@example.com", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                if let emailError { Text(emailError).font(.caption).foregroundStyle(.red) }
            }
            Section("Password") {
                SecureField("At least 8 characters", text: $password)
                if let passwordError { Text(passwordError).font(.caption).foregroundStyle(.red) }
                if !password.isEmpty {
                    ProgressView(value: Double(strength.rawValue), total: 4)
                    Text(strength.label).font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Validation")
    }
}
