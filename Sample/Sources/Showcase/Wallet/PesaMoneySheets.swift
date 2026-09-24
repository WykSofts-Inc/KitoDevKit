//
//  PesaMoneySheets.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoFields
import KitoButtons
import KitoModals
import KitoNavigation
import KitoScanner
import KitoToasts
import KitoHaptics

extension WalletShowcase {
    // MARK: - Request

    struct PesaRequestSheet: View {
        let store: PesaStore

        @Environment(\.dismiss) private var dismiss
        @Environment(KitoToastCenter.self) private var toasts
        @State private var amount: Double?
        @State private var note = ""
        @State private var selected: Set<String> = []

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        KitoCurrencyField("Amount each", value: $amount, currencyCode: "KES", prompt: "0")
                        KitoTextField("What’s it for?", text: $note, prompt: "Dinner at Kahawa House")
                            .leadingIcon("text.bubble")

                        Text("Ask").font(.headline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 12)], spacing: 16) {
                            ForEach(store.contacts.prefix(8)) { contact in
                                let isOn = selected.contains(contact.id)
                                Button {
                                    KitoHaptics.selectionChanged()
                                    withAnimation(.snappy) {
                                        if isOn { selected.remove(contact.id) } else { selected.insert(contact.id) }
                                    }
                                } label: {
                                    VStack(spacing: 6) {
                                        KitoAvatar(initials: contact.initials, colors: [contact.color, contact.color.opacity(0.6)], size: 56)
                                            .overlay(alignment: .bottomTrailing) {
                                                if isOn {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.title3)
                                                        .foregroundStyle(.white, PesaStyle.positive)
                                                        .transition(.scale.combined(with: .opacity))
                                                }
                                            }
                                            .opacity(isOn || selected.isEmpty ? 1 : 0.55)
                                        Text(contact.firstName).font(.caption.weight(.semibold)).lineLimit(1)
                                    }
                                }
                                .buttonStyle(PesaPressStyle())
                                .accessibilityLabel(contact.name)
                                .accessibilityAddTraits(isOn ? .isSelected : [])
                            }
                        }

                        if let amount, amount > 0, !selected.isEmpty {
                            Text("You’ll get \(PesaMoney.string(amount * Double(selected.count))) in total.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom) {
                    KitoButton("Send request", systemImage: "paperplane.fill") {
                        try await Task.sleep(for: .milliseconds(700))
                        let names = store.contacts.filter { selected.contains($0.id) }.map(\.firstName)
                        toasts.show(KitoToast(title: "Request sent", message: "Asked \(ListFormatter.localizedString(byJoining: names)) for \(PesaMoney.string(amount ?? 0)) each.",
                                              style: .success, icon: .custom("arrow.down.left")))
                        dismiss()
                    }
                    .fullWidth()
                    .size(.large)
                    .disabled((amount ?? 0) <= 0 || selected.isEmpty)
                    .padding(16)
                    .background(.bar)
                }
                .navigationTitle("Request money")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
            }
        }
    }

    // MARK: - Top up

    struct PesaTopUpSheet: View {
        let store: PesaStore

        @Environment(\.dismiss) private var dismiss
        @Environment(KitoToastCenter.self) private var toasts
        @State private var amount: Double?
        @State private var cardID: String

        init(store: PesaStore) {
            self.store = store
            _cardID = State(initialValue: store.mainCard.id)
        }

        var body: some View {
            NavigationStack {
                Form {
                    Section {
                        KitoCurrencyField("Amount", value: $amount, currencyCode: "KES", prompt: "0")
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        HStack(spacing: 8) {
                            ForEach([1_000.0, 5_000, 10_000, 20_000], id: \.self) { value in
                                Button(PesaMoney.compact(value).replacingOccurrences(of: "KES ", with: "")) {
                                    KitoHaptics.selectionChanged()
                                    amount = value
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .tint(.primary)
                                .accessibilityLabel(PesaMoney.string(value))
                            }
                        }
                    }
                    Section("Into") {
                        Picker("Pocket", selection: $cardID) {
                            ForEach(store.cards) { card in
                                Text("\(card.name) · \(PesaMoney.string(card.balance, cents: .never))").tag(card.id)
                            }
                        }
                    }
                    Section {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Umoja Savings ••4410")
                                Text("Linked bank account · arrives in seconds").font(.footnote).foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "building.columns.fill")
                        }
                    } header: {
                        Text("From")
                    } footer: {
                        Text("Demo only: no bank is contacted and no money moves.")
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    KitoButton("Top up", systemImage: "plus") {
                        try await Task.sleep(for: .milliseconds(900))
                        let value = amount ?? 0
                        withAnimation(.snappy) { _ = store.topUp(value, into: cardID) }
                        toasts.show(KitoToast(title: "Topped up", message: "\(PesaMoney.string(value)) is in \(store.card(cardID)?.name ?? "your pocket").",
                                              style: .success))
                        dismiss()
                    }
                    .successTitle("Done")
                    .fullWidth()
                    .size(.large)
                    .disabled((amount ?? 0) <= 0)
                    .padding(16)
                    .background(.bar)
                }
                .navigationTitle("Top up")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
            }
        }
    }

    // MARK: - Pay bill

    struct PesaPayBillSheet: View {
        let store: PesaStore

        @Environment(\.dismiss) private var dismiss
        @State private var path: [PesaBillRoute] = []
        @State private var paybill = ""
        @State private var account = ""

        var body: some View {
            NavigationStack(path: $path) {
                List {
                    Section("Saved billers") {
                        ForEach(store.billers) { biller in
                            Button { path.append(.pay(biller.request)) } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: biller.systemImage)
                                        .font(.headline)
                                        .foregroundStyle(biller.color)
                                        .frame(width: 40, height: 40)
                                        .background(biller.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(biller.name).font(.body.weight(.semibold))
                                        Text("Paybill \(biller.request.number) · \(biller.request.account ?? "")")
                                            .font(.footnote).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if let due = biller.request.formattedAmount {
                                        Text(due).font(.subheadline.weight(.semibold)).monospacedDigit()
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Section("Someone new") {
                        KitoTextField("Paybill number", text: $paybill, prompt: "e.g. 400200")
                            .keyboard(.numberPad)
                        KitoTextField("Account number", text: $account, prompt: "As on your bill")
                        Button("Continue") {
                            path.append(.pay(KitoPaymentRequest(kind: .paybill, number: paybill, account: account.isEmpty ? nil : account)))
                        }
                        .disabled(paybill.count < 5)
                    }
                }
                .navigationTitle("Pay a bill")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
                .navigationDestination(for: PesaBillRoute.self) { route in
                    switch route {
                    case .pay(let request): PesaPayConfirm(store: store, request: request) { dismiss() }
                    }
                }
            }
        }
    }

    private enum PesaBillRoute: Hashable { case pay(KitoPaymentRequest) }

    // MARK: - Confirm a payment

    /// Pays a till, paybill or phone from a scanned code or a saved biller: amount, pocket,
    /// slide to pay, Face ID, then confetti and a receipt.
    struct PesaPayConfirm: View {
        @Bindable var store: PesaStore
        let request: KitoPaymentRequest
        let finish: () -> Void

        @Environment(KitoToastCenter.self) private var toasts
        @StateObject private var gate = PesaBiometricGate()
        @State private var amount: Double?
        @State private var cardID: String = PesaSeed.everydayID
        @State private var alert: KitoAlert?
        @State private var receipt: PesaReceipt?

        private var card: PesaCard { store.card(cardID) ?? store.mainCard }
        private var value: Double { amount ?? 0 }
        private var canPay: Bool { value > 0 && value <= card.balance && !card.isFrozen }
        private var title: String { request.merchant ?? "\(request.kind.title) \(request.number)" }

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: request.kind == .paybill ? "doc.text.fill" : (request.kind == .till ? "storefront.fill" : "iphone"))
                            .font(.system(size: 28, weight: .semibold))
                            .frame(width: 72, height: 72)
                            .background(Color(.secondarySystemGroupedBackground), in: Circle())
                        Text(title).font(.title3.weight(.bold)).multilineTextAlignment(.center)
                        Text([request.kind.title + " " + request.number, request.account.map { "Account \($0)" }].compactMap { $0 }.joined(separator: " · "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let note = request.note {
                            Text(note).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityElement(children: .combine)

                    VStack(alignment: .leading, spacing: 16) {
                        KitoCurrencyField("Amount", value: $amount, currencyCode: "KES", prompt: "0")
                        Picker("Pay from", selection: $cardID) {
                            ForEach(store.cards) { option in
                                Text("\(option.name) · \(PesaMoney.string(option.balance, cents: .never))").tag(option.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.primary)
                        if card.isFrozen {
                            Label("\(card.name) is frozen. Unfreeze it in Cards or pick another pocket.", systemImage: "snowflake")
                                .font(.footnote).foregroundStyle(.red)
                        } else if value > card.balance {
                            Label("That’s more than \(card.name) has.", systemImage: "exclamationmark.triangle.fill")
                                .font(.footnote).foregroundStyle(.red)
                        }
                    }
                    .pesaSurface()
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                KitoSlideToConfirm("Slide to pay", systemImage: "arrow.right", tint: .primary) { try await pay() }
                    .frame(height: 64)
                    .disabled(!canPay)
                    .opacity(canPay ? 1 : 0.4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            .overlay { PesaBiometricOverlay(gate: gate) }
            .navigationTitle("Pay")
            .navigationBarTitleDisplayMode(.inline)
            .kitoAlert($alert)
            .sheet(item: $receipt, onDismiss: finish) { PesaReceiptSheet(receipt: $0) }
            .onAppear {
                if amount == nil, let preset = request.amount { amount = NSDecimalNumber(decimal: preset).doubleValue }
            }
        }

        /// Throws when Face ID fails, so the slider shows a cross and slides back for another go.
        private func pay() async throws {
            if store.confirmsWithBiometrics {
                guard await gate.confirm(reason: "Pay \(PesaMoney.string(value)) to \(title)") else {
                    toasts.show("Payment cancelled", style: .warning)
                    throw PesaNotConfirmed()
                }
            } else {
                try? await Task.sleep(for: .milliseconds(700))
            }
            let transaction = withAnimation(.snappy) { store.pay(request, amount: value, from: card.id) }
            try? await Task.sleep(for: .milliseconds(450))
            alert = KitoAlert(systemImage: "checkmark", tint: PesaStyle.positive,
                              title: "Paid \(PesaMoney.string(value))",
                              message: "\(title) has been paid. Reference \(transaction.reference).",
                              actions: [
                                  KitoAlertAction("Receipt", role: .secondary) {
                                      receipt = PesaReceipt(transaction: transaction, card: store.card(transaction.cardID))
                                  },
                                  KitoAlertAction("Done") { finish() },
                              ],
                              celebrates: true)
        }
    }
}
