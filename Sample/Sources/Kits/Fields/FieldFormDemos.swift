//
//  FieldFormDemos.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoFields
import KitoButtons

// Ported from the KitoFields example app. The originals read the country picker's locale from
// that app's AppearanceModel environment object, which DevKit never injects — so they'd compile
// and then crash on first open. Dropped here; the picker follows the device locale by default.

struct SignUpFormDemo: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phone: KitoPhoneNumber?
    @State private var password = ""
    @State private var confirm = ""
    @State private var nameValid = false
    @State private var emailValid = false
    @State private var phoneValid = false
    @State private var passwordValid = false
    @State private var confirmValid = false
    @State private var serverError: String?
    @State private var submitted = false
    @State private var isSubmitting = false

    private var formIsValid: Bool { nameValid && emailValid && phoneValid && passwordValid && confirmValid }

    var body: some View {
        ScrollView {
            Group {
                VStack(spacing: 18) {
                    KitoTextField("Full name", text: $name, prompt: "Jane Doe")
                        .leadingIcon("person")
                        .required()
                        .contentType(.name)
                        .autocapitalization(.words)
                        .validation(.minLength(2))
                        .isValid($nameValid)

                    KitoEmailField(text: $email)
                        .leadingIcon("envelope")
                        .required()
                        .errorMessage(serverError)
                        .validationIndicators()
                        .isValid($emailValid)

                    KitoPhoneField("Mobile number", phoneNumber: $phone)
                        .required()
                        .countries(preferred: ["KE", "UG", "TZ", "US", "GB"])
                        .helperText("We'll text you a verification code")
                        .validationIndicators()
                        .isValid($phoneValid)

                    KitoPasswordField(text: $password)
                        .newPassword()
                        .required()
                        .strengthMeter()
                        .requirements(KitoRule.strongPassword())
                        .isValid($passwordValid)

                    KitoPasswordField("Confirm password", text: $confirm, prompt: "Re-enter your password")
                        .required()
                        .mustMatch($password)
                        .validationTrigger(.live)
                        .isValid($confirmValid)

                    Button {
                        Task {
                            isSubmitting = true
                            try? await Task.sleep(nanoseconds: 1_200_000_000)
                            serverError = email.hasSuffix("@taken.com") ? "That email is already registered" : nil
                            submitted = serverError == nil
                            isSubmitting = false
                        }
                    } label: {
                        Group {
                            if isSubmitting { ProgressView().tint(.white) } else { Text("Create account").bold() }
                        }
                        .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!formIsValid || isSubmitting)

                    if submitted {
                        Label("Account created for \(phone?.international ?? "")", systemImage: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    }
                    Text("Tip: use an @taken.com address to see a server-side error.")
                        .font(.footnote).foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle("Sign up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct KitoFormDemo: View {
    private enum Field: Hashable { case name, email, phone, password, confirm }
    @StateObject private var form = KitoFormController()
    @FocusState private var focus: Field?

    @State private var name = ""
    @State private var email = ""
    @State private var phone: KitoPhoneNumber?
    @State private var password = ""
    @State private var confirm = ""
    @State private var serverError: String?
    @State private var submitted = false
    @State private var isSubmitting = false

    var body: some View {
        ScrollView {
            Group {
                VStack(spacing: 18) {
                    KitoTextField("Full name", text: $name, prompt: "Jane Doe")
                        .leadingIcon("person")
                        .required()
                        .contentType(.name)
                        .autocapitalization(.words)
                        .validation(.minLength(2))
                        .kitoFormField(Field.name, form: form, focus: $focus, equals: .name)

                    KitoEmailField(text: $email)
                        .leadingIcon("envelope")
                        .required()
                        .errorMessage(serverError)
                        .validationIndicators()
                        .kitoFormField(Field.email, form: form, focus: $focus, equals: .email)

                    KitoPhoneField("Mobile number", phoneNumber: $phone)
                        .required()
                        .countries(preferred: ["KE", "UG", "TZ", "US", "GB"])
                        .helperText("We'll text you a verification code")
                        .validationIndicators()
                        .kitoFormField(Field.phone, form: form, focus: $focus, equals: .phone)

                    KitoPasswordField(text: $password)
                        .newPassword()
                        .required()
                        .strengthMeter()
                        .requirements(KitoRule.strongPassword())
                        .kitoFormField(Field.password, form: form, focus: $focus, equals: .password)

                    KitoPasswordField("Confirm password", text: $confirm, prompt: "Re-enter your password")
                        .required()
                        .mustMatch($password)
                        .validationTrigger(.live)
                        .kitoFormField(Field.confirm, form: form, focus: $focus, equals: .confirm)

                    Button {
                        guard form.validate() else { return }
                        Task {
                            isSubmitting = true
                            try? await Task.sleep(nanoseconds: 1_200_000_000)
                            serverError = email.hasSuffix("@taken.com") ? "That email is already registered" : nil
                            submitted = serverError == nil
                            isSubmitting = false
                        }
                    } label: {
                        Group {
                            if isSubmitting { ProgressView().tint(.white) } else { Text("Create account").bold() }
                        }
                        .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isSubmitting)

                    if submitted {
                        Label("Account created for \(phone?.international ?? "")", systemImage: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    }
                    Text("Leave a field blank or too short, then tap Create account: the keyboard jumps straight to it.")
                        .font(.footnote).foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle("Sign up (KitoForm)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
