//
//  ValidationDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoValidation

struct ValidationDemo: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var phone = ""
    @State private var username = ""
    @State private var bio = ""

    private var emailError: String? { email.isEmpty ? nil : kitoValidate(email, rules: [.required(), .email()]) }
    private var passwordError: String? { password.isEmpty ? nil : kitoValidate(password, rules: [.required(), .minLength(8)]) }
    private var confirmError: String? { confirmPassword.isEmpty ? nil : kitoValidate(confirmPassword, rules: [.matches(password)]) }
    private var phoneError: String? { phone.isEmpty ? nil : kitoValidate(phone, rules: [.phone()]) }
    private var usernameError: String? { username.isEmpty ? nil : kitoValidate(username, rules: [.required(), .minLength(3), .maxLength(20)]) }
    private var bioError: String? { kitoValidate(bio, rules: [.maxLength(140)]) }
    private var strength: KitoPasswordStrength { .evaluate(password) }

    var body: some View {
        Form {
            Section("Email — .required() + .email()") {
                TextField("you@example.com", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                errorText(emailError)
            }

            Section("Password — .required() + .minLength(8), with strength meter") {
                SecureField("At least 8 characters", text: $password)
                errorText(passwordError)
                if !password.isEmpty {
                    ProgressView(value: Double(strength.rawValue), total: 4)
                    Text(strength.label).font(.caption2).foregroundStyle(.secondary)
                }
            }

            Section("Confirm password — .matches(password)") {
                SecureField("Re-enter password", text: $confirmPassword)
                errorText(confirmError)
            }

            Section("Phone — .phone()") {
                TextField("+254 700 000 000", text: $phone)
                    .keyboardType(.phonePad)
                errorText(phoneError)
            }

            Section("Username — .minLength(3) + .maxLength(20)") {
                TextField("Pick a username", text: $username)
                    .textInputAutocapitalization(.never)
                errorText(usernameError)
            }

            Section("Bio — .maxLength(140), live character count") {
                TextField("Tell us about yourself", text: $bio, axis: .vertical)
                    .lineLimit(3...6)
                HStack {
                    errorText(bioError)
                    Spacer()
                    Text("\(bio.count)/140").font(.caption2).foregroundStyle(.secondary)
                }
            }

            Section("Custom validator — must contain a number") {
                let customRules: [KitoValidator] = [.required(), .custom(message: "Must contain a number") { $0.contains { $0.isNumber } }]
                TextField("Type something with a digit", text: $customField)
                errorText(customField.isEmpty ? nil : kitoValidate(customField, rules: customRules))
            }
        }
        .navigationTitle("Validation")
    }

    @State private var customField = ""

    @ViewBuilder
    private func errorText(_ message: String?) -> some View {
        if let message {
            Text(message).font(.caption).foregroundStyle(.red)
        }
    }
}
