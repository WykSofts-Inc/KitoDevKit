//
//  PesaSendFlow.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Observation
import KitoNavigation
import KitoFields
import KitoButtons
import KitoModals
import KitoBiometrics
import KitoFormatting
import KitoHaptics

extension WalletShowcase {
    /// What's being sent, shared by the steps of the send flow.
    @Observable
    @MainActor
    final class PesaSendDraft {
        var contact: PesaContact?
        var amountText = ""
        var note = ""
        var cardID: String

        init(cardID: String) { self.cardID = cardID }

        var amount: Double { Double(amountText) ?? 0 }
    }

    private enum PesaSendStep: Hashable { case amount, review }

    /// Send money: pick a person, key in an amount, review, slide to confirm, Face ID, confetti,
    /// and a PDF receipt to share.
    struct PesaSendFlow: View {
        @Bindable var store: PesaStore

        @Environment(\.dismiss) private var dismiss
        @State private var draft: PesaSendDraft
        @State private var path: [PesaSendStep] = []
        @State private var alert: KitoAlert?
        @State private var receipt: PesaReceipt?

        init(store: PesaStore) {
            self.store = store
            _draft = State(initialValue: PesaSendDraft(cardID: store.mainCard.id))
        }

        var body: some View {
            NavigationStack(path: $path) {
                PesaContactPicker(store: store) { contact in
                    draft.contact = contact
                    path.append(.amount)
                }
                .navigationTitle("Send money")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                }
                .navigationDestination(for: PesaSendStep.self) { step in
                    switch step {
                    case .amount: PesaAmountStep(store: store, draft: draft) { path.append(.review) }
                    case .review: PesaReviewStep(store: store, draft: draft) { sent($0) }
                    }
                }
            }
            .kitoAlert($alert)
            .sheet(item: $receipt, onDismiss: { dismiss() }) { PesaReceiptSheet(receipt: $0) }
        }

        private func sent(_ transaction: PesaTransaction) {
            let name = draft.contact?.firstName ?? "They"
            alert = KitoAlert(systemImage: "checkmark", tint: PesaStyle.positive,
                              title: "\(PesaMoney.string(-transaction.amount)) sent",
                              message: "\(name) has it already. Reference \(transaction.reference).",
                              actions: [
                                  KitoAlertAction("Receipt", role: .secondary) {
                                      receipt = PesaReceipt(transaction: transaction, card: store.card(transaction.cardID))
                                  },
                                  KitoAlertAction("Done") { dismiss() },
                              ],
                              celebrates: true)
        }
    }

    // MARK: - Contacts

    private struct PesaContactPicker: View {
        let store: PesaStore
        let pick: (PesaContact) -> Void

        @State private var query = ""

        private var matches: [PesaContact] {
            query.isEmpty ? store.contacts : store.contacts.filter {
                $0.name.localizedCaseInsensitiveContains(query) || $0.phone.filter(\.isNumber).contains(query.filter(\.isNumber).isEmpty ? "#" : query.filter(\.isNumber))
            }
        }

        /// A typed number that isn't in contacts yet.
        private var newNumber: PesaContact? {
            guard let phone = KitoKenyanPhoneNumber(query), !store.contacts.contains(where: { KitoKenyanPhoneNumber($0.phone) == phone }) else { return nil }
            return PesaContact(id: "new-\(phone.e164)", name: phone.international, phone: phone.international, color: .gray, isFavourite: false)
        }

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    KitoSearchField(text: $query, prompt: "Name or phone number")

                    if let newNumber {
                        Button { pick(newNumber) } label: {
                            row(newNumber, detail: "Send to a new number")
                        }
                        .buttonStyle(.plain)
                        .pesaSurface(padding: 12)
                    }

                    if query.isEmpty {
                        Text("Favourites").font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(store.favourites) { contact in
                                    Button { pick(contact) } label: {
                                        VStack(spacing: 6) {
                                            KitoAvatar(initials: contact.initials, colors: [contact.color, contact.color.opacity(0.6)], size: 60, showsRing: true)
                                            Text(contact.firstName).font(.caption.weight(.semibold)).lineLimit(1)
                                        }
                                        .frame(width: 68)
                                    }
                                    .buttonStyle(PesaPressStyle())
                                    .accessibilityLabel("Send to \(contact.name)")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Text(query.isEmpty ? "Everyone" : "Results").font(.headline)
                    VStack(spacing: 0) {
                        ForEach(matches) { contact in
                            Button { pick(contact) } label: { row(contact, detail: contact.maskedPhone) }
                                .buttonStyle(.plain)
                            if contact.id != matches.last?.id { Divider().padding(.leading, 60) }
                        }
                        if matches.isEmpty && newNumber == nil {
                            Text("No one called “\(query)”. Type a number like 0712 345 678 to send to someone new.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 12)
                        }
                    }
                    .pesaSurface(padding: 12)
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
        }

        private func row(_ contact: PesaContact, detail: String) -> some View {
            HStack(spacing: 12) {
                KitoAvatar(initials: contact.initials.isEmpty ? "#" : contact.initials, colors: [contact.color, contact.color.opacity(0.6)], size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.name).font(.body.weight(.semibold))
                    Text(detail).font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
        }
    }

    // MARK: - Amount

    private struct PesaAmountStep: View {
        @Bindable var store: PesaStore
        @Bindable var draft: PesaSendDraft
        let next: () -> Void

        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var shakes = 0

        private var card: PesaCard { store.card(draft.cardID) ?? store.mainCard }
        private var isOverBalance: Bool { draft.amount > card.balance }
        private var canContinue: Bool { draft.amount >= 10 && !isOverBalance && !card.isFrozen }

        var body: some View {
            VStack(spacing: 16) {
                if let contact = draft.contact {
                    HStack(spacing: 10) {
                        KitoAvatar(initials: contact.initials, colors: [contact.color, contact.color.opacity(0.6)], size: 36)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("To \(contact.name)").font(.subheadline.weight(.semibold))
                            Text(contact.maskedPhone).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .accessibilityElement(children: .combine)
                }

                VStack(spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("KES").font(.title3.weight(.semibold)).foregroundStyle(.secondary)
                        Text(display)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(reduceMotion ? .identity : .numericText())
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(draft.amountText.isEmpty ? .tertiary : .primary)
                    }
                    .modifier(PesaShake(shakes: shakes))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Amount")
                    .accessibilityValue(draft.amountText.isEmpty ? "None" : PesaMoney.string(draft.amount))

                    Menu {
                        ForEach(store.cards) { option in
                            Button { draft.cardID = option.id } label: {
                                Label("\(option.name) · \(PesaMoney.string(option.balance, cents: .never))",
                                      systemImage: option.isFrozen ? "snowflake" : "creditcard")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(isOverBalance ? "More than \(card.name) has" : "From \(card.name) · \(PesaMoney.string(card.balance, cents: .never))")
                            Image(systemName: "chevron.up.chevron.down")
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(isOverBalance || card.isFrozen ? .red : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.secondarySystemGroupedBackground), in: Capsule())
                    }
                    .accessibilityLabel("Pay from \(card.name)")
                }
                .frame(maxHeight: .infinity)

                HStack(spacing: 8) {
                    ForEach([500, 1_000, 2_500, 5_000], id: \.self) { value in
                        Button {
                            KitoHaptics.selectionChanged()
                            withAnimation(.snappy) { draft.amountText = String(value) }
                        } label: {
                            Text(KitoNumberFormatting.grouped(Double(value)))
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemGroupedBackground), in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("KES \(value)")
                    }
                }

                KitoTextField("Note", text: $draft.note, prompt: "What’s it for? (optional)")
                    .leadingIcon("text.bubble")

                PesaKeypad { key in press(key) }

                KitoButton("Review", systemImage: "arrow.right", iconPlacement: .trailing) { next() }
                    .fullWidth()
                    .size(.large)
                    .disabled(!canContinue)
            }
            .padding(16)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Amount")
            .navigationBarTitleDisplayMode(.inline)
        }

        private var display: String {
            guard !draft.amountText.isEmpty else { return "0" }
            let parts = draft.amountText.split(separator: ".", omittingEmptySubsequences: false)
            let whole = KitoNumberFormatting.grouped(Double(parts[0]) ?? 0)
            return parts.count > 1 ? "\(whole).\(parts[1])" : whole
        }

        private func press(_ key: PesaKey) {
            var text = draft.amountText
            switch key {
            case .digit(let digit):
                if text == "0" { text = "" }
                if let dot = text.firstIndex(of: "."), text.distance(from: dot, to: text.endIndex) > 2 { return reject() }
                text.append(String(digit))
            case .dot:
                guard !text.contains(".") else { return reject() }
                text = (text.isEmpty ? "0" : text) + "."
            case .delete:
                guard !text.isEmpty else { return reject() }
                text.removeLast()
            }
            guard (Double(text) ?? 0) <= 999_999 else { return reject() }
            KitoHaptics.selectionChanged()
            withAnimation(reduceMotion ? nil : .snappy(duration: 0.2)) { draft.amountText = text }
            if (Double(text) ?? 0) > card.balance { KitoHaptics.warning() }
        }

        private func reject() {
            KitoHaptics.error()
            withAnimation(reduceMotion ? nil : .default) { shakes += 1 }
        }
    }

    enum PesaKey: Hashable { case digit(Int), dot, delete }

    /// A big, calm number pad.
    struct PesaKeypad: View {
        let press: (PesaKey) -> Void

        private let keys: [[PesaKey]] = [
            [.digit(1), .digit(2), .digit(3)],
            [.digit(4), .digit(5), .digit(6)],
            [.digit(7), .digit(8), .digit(9)],
            [.dot, .digit(0), .delete],
        ]

        var body: some View {
            Grid(horizontalSpacing: 8, verticalSpacing: 6) {
                ForEach(keys, id: \.self) { row in
                    GridRow {
                        ForEach(row, id: \.self) { key in
                            Button { press(key) } label: {
                                label(for: key)
                                    .font(.system(size: 26, weight: .medium, design: .rounded))
                                    .frame(maxWidth: .infinity, minHeight: 52)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PesaKeyStyle())
                            .accessibilityLabel(accessibilityLabel(for: key))
                        }
                    }
                }
            }
        }

        @ViewBuilder private func label(for key: PesaKey) -> some View {
            switch key {
            case .digit(let digit): Text("\(digit)")
            case .dot: Text(".")
            case .delete: Image(systemName: "delete.left")
            }
        }

        private func accessibilityLabel(for key: PesaKey) -> String {
            switch key {
            case .digit(let digit): "\(digit)"
            case .dot: "Decimal point"
            case .delete: "Delete"
            }
        }
    }

    private struct PesaKeyStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(Color.primary.opacity(configuration.isPressed ? 0.08 : 0), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    struct PesaShake: GeometryEffect {
        var shakes: Int
        var animatableData: CGFloat

        init(shakes: Int) {
            self.shakes = shakes
            animatableData = CGFloat(shakes)
        }

        func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(CGAffineTransform(translationX: 8 * sin(animatableData * .pi * 4), y: 0))
        }
    }
}
