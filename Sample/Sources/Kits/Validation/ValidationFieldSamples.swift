//
//  ValidationFieldSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoFields
import KitoButtons
import KitoValidation

// Validation in real UI: KitoFields for the inputs, KitoButtons for actions, KitoValidation's
// KitoFormValidator for whole-form state.

// MARK: - Timing

private struct TriggerSample: View {
    let trigger: KitoValidationTrigger
    @State private var email = "amina@"

    var body: some View {
        KitoEmailField(text: $email)
            .required()
            .validationTrigger(trigger)
            .validationIndicators()
    }
}

// MARK: - Presentation

private struct PresentationSample: View {
    let presentation: KitoErrorPresentation
    @State private var text = "ab"

    var body: some View {
        KitoTextField("Username", text: $text, prompt: "At least 4 characters")
            .required()
            .validation(.minLength(4), trigger: .live)
            .errorPresentation(presentation)
            .padding(.top, presentation == .floating || presentation == .floatingWhenFocused ? 36 : 0)
    }
}

// MARK: - Cross-field

private struct DateRangeSample: View {
    @State private var start: Date? = Calendar.current.date(byAdding: .day, value: 7, to: .now)
    @State private var end: Date? = Calendar.current.date(byAdding: .day, value: 3, to: .now)

    private var rangeError: String? {
        guard let start, let end else { return nil }
        return end < start ? "Check-out must be after check-in" : nil
    }

    var body: some View {
        VStack(spacing: 14) {
            KitoDateField("Check-in", date: $start).future()
            KitoDateField("Check-out", date: $end).future().errorMessage(rangeError)
            if let start, let end, rangeError == nil {
                let nights = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
                Label("\(nights) night\(nights == 1 ? "" : "s")", systemImage: "moon.stars.fill").font(.subheadline.weight(.semibold)).foregroundStyle(.green)
            }
        }
    }
}

private struct PriceRangeSample: View {
    @State private var minimum = "5000"
    @State private var maximum = "2000"

    private var rangeError: String? {
        guard let low = Double(minimum.filter(\.isNumber)), let high = Double(maximum.filter(\.isNumber)) else { return nil }
        return high < low ? "Maximum must be at least the minimum" : nil
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            KitoTextField("Min price", text: $minimum, prompt: "0").keyboard(.numberPad)
            KitoTextField("Max price", text: $maximum, prompt: "Any").keyboard(.numberPad).errorMessage(rangeError)
        }
    }
}

// MARK: - Async

private struct PromoCodeSample: View {
    @State private var code = ""
    @State private var result: String?
    @State private var applied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                KitoTextField(text: $code, prompt: "Promo code")
                    .transform { $0.uppercased() }
                    .autocapitalization(.characters)
                    .errorMessage(applied ? nil : result)
                KitoButton("Apply") {
                    try await Task.sleep(nanoseconds: 900_000_000)
                    // Checked "on the server": only SAVE20 exists.
                    if code == "SAVE20" { applied = true; result = nil } else { applied = false; result = "That code isn't valid" }
                }
                .variant(.tonal)
            }
            if applied {
                Label("SAVE20 applied: 20% off", systemImage: "tag.fill").font(.subheadline.weight(.semibold)).foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            }
            Text("Try SAVE20.").font(.caption).foregroundStyle(.secondary)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: applied)
    }
}

// MARK: - Whole forms

/// A sign-up form: a progress line from KitoFormValidator, a Create button that stays disabled
/// until every field passes, and an error summary on a premature tap.
struct SignUpValidationSample: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var agreed = false
    @State private var showsSummary = false
    @State private var created = false

    private var form: KitoFormValidator {
        var form = KitoFormValidator()
        form.add("Name", value: { name }, rules: [.required(message: "Enter your name")])
        form.add("Email", value: { email }, rules: [.required(message: "Enter your email"), .email()])
        form.add("Password", value: { password }, rules: KitoValidator.strongPassword())
        form.add("Confirm password", value: { confirm }, rules: [.required(message: "Confirm your password"), .matches(password, message: "Passwords don't match")])
        form.add("Terms", value: { agreed ? "yes" : "" }, rules: [.required(message: "Accept the terms")])
        return form
    }

    var body: some View {
        let form = form
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(form.validCount) of \(form.fields.count) complete").font(.subheadline.weight(.semibold))
                    Spacer()
                    if form.isValid { Image(systemName: "checkmark.seal.fill").foregroundStyle(.green) }
                }
                ProgressView(value: Double(form.validCount), total: Double(form.fields.count)).tint(form.isValid ? .green : .primary)
            }

            KitoNameField(text: $name).required()
            KitoEmailField(text: $email).required().validationTrigger(.onBlur)
            KitoPasswordField(text: $password).newPassword().strengthMeter()
            KitoPasswordField("Confirm password", text: $confirm).mustMatch($password).validationTrigger(.live)
            Toggle("I agree to the terms", isOn: $agreed).tint(.primary)

            if showsSummary, !form.isValid {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Fix these to continue", systemImage: "exclamationmark.triangle.fill").font(.subheadline.weight(.semibold))
                    ForEach(form.fields.map(\.name).filter { form.errors[$0] != nil }, id: \.self) { field in
                        Text("• \(field): \(form.errors[field] ?? "")").font(.caption)
                    }
                }
                .foregroundStyle(.red)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.red.opacity(0.1)))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            KitoButton(created ? "Account created" : "Create account", systemImage: created ? "checkmark" : nil) {
                guard form.isValid else { showsSummary = true; return }
                try await Task.sleep(nanoseconds: 1_000_000_000)
                created = true
            }
            .fullWidth()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showsSummary)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: form.validCount)
    }
}

/// A card form: brand detection and a Luhn check on the number, expiry and CVV.
private struct CheckoutValidationSample: View {
    @State private var number = ""
    @State private var expiry = ""
    @State private var cvv = ""
    @State private var holder = ""
    @State private var paid = false

    private var isValid: Bool {
        kitoPassesLuhn(number) && expiry.count == 5 && cvv.count >= 3 && !holder.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 14) {
            KitoCardNumberField(number: $number)
            HStack(spacing: 12) {
                KitoCardExpiryField(text: $expiry)
                KitoCVVField(text: $cvv)
            }
            KitoNameField("Name on card", text: $holder)
            KitoButton(paid ? "Paid" : "Pay KSh 2,400", systemImage: paid ? "checkmark" : "lock.fill") {
                try await Task.sleep(nanoseconds: 1_200_000_000)
                paid = true
            }
            .fullWidth()
            .disabled(!isValid)
            Text(isValid ? "Ready to pay" : "Try 4111 1111 1111 1111, any future expiry, any 3 digits.").font(.caption).foregroundStyle(.secondary)
        }
    }
}

/// A long form that scrolls to the first invalid field when you submit.
private struct ScrollToErrorSample: View {
    @State private var values = Array(repeating: "", count: 6)
    @State private var submitted = false
    private let labels = ["First name", "Last name", "Street", "City", "Postcode", "Phone"]

    private var form: KitoFormValidator {
        var form = KitoFormValidator()
        for index in labels.indices {
            form.add(labels[index], value: { values[index] }, rules: index == 5 ? [.required(), .phone()] : [.required()])
        }
        return form
    }

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 12) {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(labels.indices, id: \.self) { index in
                            KitoTextField(labels[index], text: $values[index])
                                .errorMessage(submitted ? form.errors[labels[index]] : nil)
                                .id(labels[index])
                        }
                    }
                    .padding(4)
                }
                .frame(height: 300)
                KitoButton("Save address") {
                    submitted = true
                    if let first = form.firstInvalidField {
                        withAnimation { proxy.scrollTo(first, anchor: .top) }
                    }
                }
                .fullWidth()
            }
        }
    }
}

private func fieldCode(_ body: String) -> String {
    "import KitoFields\n\n" + body
}

enum ValidationFieldSamples {
    static let timing = KitSection("When to validate", symbol: "timer", [
        KitSample("Live", "Errors appear as you type.", code: fieldCode("KitoEmailField(text: $email)\n    .validationTrigger(.live)")) { TriggerSample(trigger: .live) },
        KitSample("On blur", "Errors wait until you leave the field.", code: fieldCode("KitoEmailField(text: $email)\n    .validationTrigger(.onBlur)")) { TriggerSample(trigger: .onBlur) },
        KitSample("On submit", "Errors wait for Return.", code: fieldCode("KitoEmailField(text: $email)\n    .validationTrigger(.onSubmit)")) { TriggerSample(trigger: .onSubmit) },
    ])

    static let presentation = KitSection("How errors look", symbol: "exclamationmark.bubble", [
        KitSample("Inline", "Text under the field.", code: fieldCode(".errorPresentation(.inline)")) { PresentationSample(presentation: .inline) },
        KitSample("Floating bubble", "A bubble above the field.", code: fieldCode(".errorPresentation(.floating)")) { PresentationSample(presentation: .floating) },
        KitSample("Bubble while focused", "Only while you're typing.", code: fieldCode(".errorPresentation(.floatingWhenFocused)")) { PresentationSample(presentation: .floatingWhenFocused) },
        KitSample("Border only", "Red border, no text.", code: fieldCode(".errorPresentation(.none)")) { PresentationSample(presentation: .none) },
    ])

    static let crossField = KitSection("Across fields", symbol: "arrow.left.arrow.right", [
        KitSample("Confirm password", "The second must match the first.", code: fieldCode("KitoPasswordField(\"Confirm\", text: $confirm)\n    .mustMatch($password)")) {
            ConfirmPasswordSample()
        },
        KitSample("Date range", "Check-out after check-in, with a nights count.", code: fieldCode("KitoDateField(\"Check-out\", date: $end)\n    .errorMessage(end < start ? \"Check-out must be after check-in\" : nil)")) { DateRangeSample() },
        KitSample("Price range", "Maximum at least the minimum.", code: fieldCode("KitoTextField(\"Max price\", text: $max)\n    .errorMessage(max < min ? \"Maximum must be at least the minimum\" : nil)")) { PriceRangeSample() },
    ])

    static let async = KitSection("Checked by a server", symbol: "network", [
        KitSample("Username availability", "Debounced check as you type: try “admin”.", code: fieldCode("KitoUsernameField(text: $username)\n    .availability { try await api.isAvailable($0) }")) {
            UsernameAvailabilitySample()
        },
        KitSample("Promo code", "Checked when you tap Apply, with a loading button.", code: fieldCode("KitoButton(\"Apply\") {\n    try await api.apply(code)   // shows a spinner meanwhile\n}")) { PromoCodeSample() },
    ])

    static let forms = KitSection("Whole forms", symbol: "doc.text", [
        KitSample("Sign-up", "Progress, a disabled-until-valid button and an error summary.", code: """
        var form = KitoFormValidator()
        form.add("Email", value: { email }, rules: [.required(), .email()])
        form.add("Password", value: { password }, rules: KitoValidator.strongPassword())

        form.validCount          // 1
        form.isValid             // false
        form.errors["Email"]     // "Enter a valid email address"
        """) { SignUpValidationSample() },
        KitSample("Card checkout", "Brand detection and the Luhn check.", code: fieldCode("KitoCardNumberField(number: $number)\nHStack { KitoCardExpiryField(text: $expiry); KitoCVVField(text: $cvv) }")) { CheckoutValidationSample() },
        KitSample("Scroll to the first error", "Submit an incomplete address.", code: """
        if let first = form.firstInvalidField {
            proxy.scrollTo(first, anchor: .top)
        }
        """) { ScrollToErrorSample() },
    ])
}

private struct ConfirmPasswordSample: View {
    @State private var password = "Kito#2026"
    @State private var confirm = "Kito#202"

    var body: some View {
        VStack(spacing: 14) {
            KitoPasswordField(text: $password)
            KitoPasswordField("Confirm password", text: $confirm).mustMatch($password).validationTrigger(.live).validationIndicators()
        }
    }
}

private struct UsernameAvailabilitySample: View {
    @State private var username = ""

    var body: some View {
        KitoUsernameField(text: $username).availability { name in
            try? await Task.sleep(nanoseconds: 700_000_000)
            return !["admin", "root", "support", "kito"].contains(name.lowercased())
        }
    }
}

/// Every validation sample.
struct ValidationGallery: View {
    static let sections = [ValidationRuleSamples.rules, ValidationRuleSamples.passwords, ValidationFieldSamples.timing,
                           ValidationFieldSamples.presentation, ValidationFieldSamples.crossField, ValidationFieldSamples.async,
                           ValidationFieldSamples.forms, ValidationRuleSamples.playground]
    static var count: Int { KitGallery.count(sections) }

    var body: some View {
        KitGallery(
            title: "Validation",
            sections: Self.sections,
            footnote: "Rules come from `import KitoValidation`; fields from `import KitoFields`.",
            searchHint: "Try a rule (“email”, “card”), a timing (“blur”) or a form (“sign-up”)."
        )
    }
}
