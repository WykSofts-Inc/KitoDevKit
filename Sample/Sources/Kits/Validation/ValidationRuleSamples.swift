//
//  ValidationRuleSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoValidation

// Samples built on KitoValidation alone: plain rules you can run on any string, in any UI.

/// A field and a live checklist of its rules: each ticks as it passes, and the field's border
/// shows the first failure's colour.
struct RuleTester: View {
    let rules: [KitoValidator]
    let placeholder: String
    var keyboard: UIKeyboardType = .default
    var capitalization: TextInputAutocapitalization = .never
    var secure = false

    @State private var text: String
    @FocusState private var focused: Bool

    init(_ rules: [KitoValidator], placeholder: String, initial: String = "", keyboard: UIKeyboardType = .default,
         capitalization: TextInputAutocapitalization = .never, secure: Bool = false) {
        self.rules = rules
        self.placeholder = placeholder
        self.keyboard = keyboard
        self.capitalization = capitalization
        self.secure = secure
        _text = State(initialValue: initial)
    }

    private var results: [KitoRuleResult] { kitoEvaluate(text, rules: rules) }
    private var isValid: Bool { results.allSatisfy(\.passed) }
    private var borderColor: Color { text.isEmpty ? Color.primary.opacity(focused ? 0.5 : 0.15) : (isValid ? .green : .red) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Group {
                    if secure { SecureField(placeholder, text: $text) } else { TextField(placeholder, text: $text) }
                }
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled()
                .focused($focused)
                if !text.isEmpty {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isValid ? .green : .red)
                        .transition(.scale.combined(with: .opacity))
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.primary.opacity(0.05)))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(borderColor, lineWidth: 1.5))
            .modifier(Shake(trigger: !text.isEmpty && !isValid && !focused))

            RuleChecklist(results: results, isEmpty: text.isEmpty)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: results)
    }
}

/// Every rule with a tick or a cross, in order.
struct RuleChecklist: View {
    let results: [KitoRuleResult]
    var isEmpty = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(results) { result in
                HStack(spacing: 8) {
                    Image(systemName: isEmpty ? "circle" : (result.passed ? "checkmark.circle.fill" : "xmark.circle.fill"))
                        .foregroundStyle(isEmpty ? .secondary : (result.passed ? Color.green : .red))
                        .contentTransition(.symbolEffect(.replace))
                    Text(result.message)
                        .font(.subheadline)
                        .foregroundStyle(result.passed && !isEmpty ? .secondary : .primary)
                        .strikethrough(result.passed && !isEmpty, color: .secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityValue(isEmpty ? "Not checked" : (result.passed ? "Passed" : "Failed"))
            }
        }
    }
}

/// A short horizontal shake, played when `trigger` becomes true.
struct Shake: ViewModifier {
    let trigger: Bool
    @State private var count = 0

    func body(content: Content) -> some View {
        content
            .keyframeAnimator(initialValue: 0.0, trigger: count) { view, x in view.offset(x: x) } keyframes: { _ in
                KeyframeTrack { SpringKeyframe(-8, duration: 0.07); SpringKeyframe(8, duration: 0.07); SpringKeyframe(-5, duration: 0.07); SpringKeyframe(0, duration: 0.1) }
            }
            .onChange(of: trigger) { _, now in if now { count += 1 } }
    }
}

// MARK: - Password meter

/// A five-segment meter that fills and changes colour with the score, plus tips.
struct PasswordStrengthSample: View {
    var showsTips = true
    @State private var password = ""

    private var strength: KitoPasswordStrength { .evaluate(password) }
    private var color: Color {
        switch strength {
        case .veryWeak: return .red
        case .weak: return .orange
        case .medium: return .yellow
        case .strong: return .mint
        case .veryStrong: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SecureField("Choose a password", text: $password)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.primary.opacity(0.05)))
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    Capsule()
                        .fill(!password.isEmpty && index <= strength.rawValue ? color : Color.primary.opacity(0.1))
                        .frame(height: 6)
                }
            }
            HStack {
                Text(password.isEmpty ? "Strength" : strength.label).font(.subheadline.weight(.semibold)).foregroundStyle(password.isEmpty ? .secondary : color)
                    .contentTransition(.interpolate)
                Spacer()
                Text("\(password.count) characters").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            if showsTips, !password.isEmpty {
                let tips = KitoPasswordStrength.suggestions(for: password)
                if tips.isEmpty {
                    Label("Great password", systemImage: "hand.thumbsup.fill").font(.subheadline).foregroundStyle(.green)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(tips, id: \.self) { tip in
                            Label(tip, systemImage: "lightbulb").font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: strength)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: password.isEmpty)
    }
}

// MARK: - Playground

/// Switch rules on and off and watch the same input pass or fail each one.
struct RulePlayground: View {
    private struct Option: Identifiable {
        let id: String
        let rule: KitoValidator
    }

    private let options: [Option] = [
        Option(id: "Required", rule: .required()),
        Option(id: "Email", rule: .email()),
        Option(id: "Min 8", rule: .minLength(8)),
        Option(id: "Max 20", rule: .maxLength(20)),
        Option(id: "Uppercase", rule: .containsUppercase()),
        Option(id: "Number", rule: .containsDigit()),
        Option(id: "Symbol", rule: .containsSymbol()),
        Option(id: "No spaces", rule: .noWhitespace()),
        Option(id: "Letters & digits", rule: .alphanumeric()),
        Option(id: "URL", rule: .url()),
    ]

    @State private var enabled: Set<String> = ["Required", "Min 8", "Number"]
    @State private var text = "kito2026"

    private var activeRules: [KitoValidator] { options.filter { enabled.contains($0.id) }.map(\.rule) }
    private var results: [KitoRuleResult] { kitoEvaluate(text, rules: activeRules) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Type anything", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.primary.opacity(0.05)))

            FlowTags(options: options.map(\.id), selected: $enabled)

            if activeRules.isEmpty {
                Text("Turn on a rule to check the text.").font(.subheadline).foregroundStyle(.secondary)
            } else {
                RuleChecklist(results: results)
                let first = kitoValidate(text, rules: activeRules)
                Label(first ?? "Valid", systemImage: first == nil ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(first == nil ? .green : .orange)
                Text("kitoValidate returns the first failure; kitoEvaluate reports every rule.").font(.caption).foregroundStyle(.secondary)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: enabled)
    }
}

/// Toggleable capsule tags that wrap.
struct FlowTags: View {
    let options: [String]
    @Binding var selected: Set<String>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
            ForEach(options, id: \.self) { option in
                let isOn = selected.contains(option)
                Button {
                    if isOn { selected.remove(option) } else { selected.insert(option) }
                } label: {
                    Text(option)
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(isOn ? Color.primary : Color.primary.opacity(0.06)))
                        .foregroundStyle(isOn ? Color(.systemBackground) : .primary)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
    }
}

private func ruleCode(_ rules: String) -> String {
    """
    import KitoValidation

    let rules: [KitoValidator] = \(rules)

    kitoValidate(text, rules: rules)   // first failure, or nil
    kitoEvaluate(text, rules: rules)   // every rule, passed or not
    """
}

enum ValidationRuleSamples {
    static let rules = KitSection("Rules", symbol: "checklist", [
        KitSample("Required", "Blank or whitespace-only fails.", code: ruleCode("[.required()]")) {
            RuleTester([.required()], placeholder: "Anything at all")
        },
        KitSample("Email", "Something @ something . something.", code: ruleCode("[.required(), .email()]")) {
            RuleTester([.required(), .email()], placeholder: "you@example.com", initial: "amina@kito", keyboard: .emailAddress)
        },
        KitSample("Phone", "9 to 15 digits, formatting ignored.", code: ruleCode("[.phone()]")) {
            RuleTester([.phone()], placeholder: "+254 712 345 678", keyboard: .phonePad)
        },
        KitSample("Web address", "http or https with a real host.", code: ruleCode("[.url()]")) {
            RuleTester([.url()], placeholder: "https://example.com", initial: "wyksoftsinc.com", keyboard: .URL)
        },
        KitSample("Length limits", "Between 3 and 20 characters.", code: ruleCode("[.minLength(3), .maxLength(20)]")) {
            RuleTester([.minLength(3), .maxLength(20)], placeholder: "Pick a username")
        },
        KitSample("Exact length", "A 6-digit code.", code: ruleCode("[.exactLength(6), .numeric()]")) {
            RuleTester([.exactLength(6), .numeric()], placeholder: "123456", keyboard: .numberPad)
        },
        KitSample("Letters and numbers", "No symbols or spaces.", code: ruleCode("[.alphanumeric(), .noWhitespace()]")) {
            RuleTester([.alphanumeric(), .noWhitespace()], placeholder: "Kito2026", initial: "kito_2026")
        },
        KitSample("Number range", "An age from 18 to 120.", code: ruleCode("[.number(in: 18...120)]")) {
            RuleTester([.number(in: 18...120)], placeholder: "Your age", initial: "16", keyboard: .numberPad)
        },
        KitSample("Card number", "Passes the Luhn checksum. Try 4111 1111 1111 1111.", code: ruleCode("[.required(), .luhn()]")) {
            RuleTester([.required(), .luhn()], placeholder: "Card number", initial: "4111 1111 1111 1112", keyboard: .numberPad)
        },
        KitSample("Blocked words", "Reserved usernames, any case.", code: ruleCode("[.notOneOf([\"admin\", \"root\", \"support\"])]")) {
            RuleTester([.minLength(3), .notOneOf(["admin", "root", "support"], message: "That username is reserved")], placeholder: "Username", initial: "Admin")
        },
        KitSample("Allow list", "Only known promo codes.", code: ruleCode("[.oneOf([\"SAVE20\", \"KITO10\"])]")) {
            RuleTester([.oneOf(["SAVE20", "KITO10"], message: "That code isn't valid")], placeholder: "Promo code", initial: "SAVE30", capitalization: .characters)
        },
        KitSample("Pattern", "A Kenyan number plate, like KDA 482K.", code: ruleCode("[.regex(#\"^K[A-Z]{2} ?\\d{3}[A-Z]$\"#, message: \"Format: KDA 482K\")]")) {
            RuleTester([.regex(#"^K[A-Z]{2} ?\d{3}[A-Z]$"#, message: "Format: KDA 482K")], placeholder: "KDA 482K", capitalization: .characters)
        },
        KitSample("Custom rule", "Any predicate: here, a company email.", code: ruleCode("[.email(), .custom(message: \"Use your @kito.co email\") { $0.hasSuffix(\"@kito.co\") }]")) {
            RuleTester([.email(), .custom(message: "Use your @kito.co email") { $0.lowercased().hasSuffix("@kito.co") }], placeholder: "name@kito.co", initial: "amina@gmail.com", keyboard: .emailAddress)
        },
    ])

    static let passwords = KitSection("Passwords", symbol: "lock", [
        KitSample("Strength meter", "Five segments that fill and change colour.", code: """
        let strength = KitoPasswordStrength.evaluate(password)   // .veryWeak … .veryStrong
        strength.label                                          // "Strong"
        strength.fraction                                       // 0.8
        """) { PasswordStrengthSample(showsTips: false) },
        KitSample("Meter with tips", "Suggestions for what would make it stronger.", code: """
        KitoPasswordStrength.suggestions(for: password)
        // ["Add a number", "Add a symbol like ! or #"]
        """) { PasswordStrengthSample() },
        KitSample("Requirement checklist", "Each requirement ticks off as you type.", code: ruleCode("KitoValidator.strongPassword(minLength: 8)")) {
            RuleTester(KitoValidator.strongPassword(), placeholder: "Password", secure: true)
        },
    ])

    static let playground = KitSection("Playground", symbol: "slider.horizontal.3", [
        KitSample("Rule playground", "Toggle rules and watch one input pass or fail each.", code: ruleCode("[.required(), .minLength(8), .containsDigit()]")) {
            RulePlayground()
        },
    ])
}
