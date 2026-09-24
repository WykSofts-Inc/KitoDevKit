//
//  PesaCards.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoWalletCards
import KitoKeychain
import KitoScanner
import KitoSettings
import KitoToasts
import KitoHaptics

extension WalletShowcase {
    /// Cards: a swipeable carousel, freeze with frost, reveal details behind Face ID, a spending
    /// limit, card controls and adding a card by scanning it.
    struct PesaCardsTab: View {
        @Bindable var store: PesaStore

        @Environment(KitoToastCenter.self) private var toasts
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @StateObject private var gate = PesaBiometricGate()
        @State private var selection: String? = PesaSeed.everydayID
        @State private var flippedID: String?
        @State private var showsScanner = false
        @State private var flipBack: Task<Void, Never>?

        private let keychain = KitoKeychain(service: "com.wyksoftsinc.kitosample.pesa")

        private var card: PesaCard { store.card(selection ?? "") ?? store.mainCard }

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        pager
                        dots
                        actions
                        details
                        limit
                        controls
                    }
                    .padding(.bottom, 32)
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle("Cards")
                .pesaExitToolbar()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showsScanner = true } label: { Image(systemName: "plus") }
                            .accessibilityLabel("Add a card")
                    }
                }
                .overlay { PesaBiometricOverlay(gate: gate) }
                .sheet(isPresented: $showsScanner) { PesaAddCardSheet(store: store) { selection = $0 } }
                .onAppear(perform: storeDemoNumbers)
            }
        }

        // MARK: Carousel

        private var pager: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(store.cards) { item in
                        PesaCardFace(card: item, isFlipped: flippedID == item.id)
                            .containerRelativeFrame(.horizontal)
                            .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                                view
                                    .scaleEffect(1 - min(abs(phase.value), 1) * 0.08)
                                    .opacity(1 - min(abs(phase.value), 1) * 0.35)
                            }
                            .id(item.id)
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 12)
            }
            .safeAreaPadding(.horizontal, 28)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selection)
            .onChange(of: selection) { _, _ in
                KitoHaptics.selectionChanged()
                flippedID = nil
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Cards")
        }

        private var dots: some View {
            HStack(spacing: 6) {
                ForEach(store.cards) { item in
                    Capsule()
                        .fill(item.id == card.id ? Color.primary : Color.primary.opacity(0.2))
                        .frame(width: item.id == card.id ? 18 : 6, height: 6)
                }
            }
            .animation(reduceMotion ? nil : .snappy, value: card.id)
            .accessibilityElement()
            .accessibilityLabel("Card \((store.cards.firstIndex { $0.id == card.id } ?? 0) + 1) of \(store.cards.count)")
        }

        private var actions: some View {
            HStack(spacing: 8) {
                PesaQuickAction(title: card.isFrozen ? "Unfreeze" : "Freeze", systemImage: card.isFrozen ? "sun.max.fill" : "snowflake") {
                    toggleFreeze()
                }
                PesaQuickAction(title: flippedID == card.id ? "Hide CVV" : "Show CVV", systemImage: flippedID == card.id ? "eye.slash.fill" : "eye.fill") {
                    Task { await flip() }
                }
                PesaQuickAction(title: "Add card", systemImage: "camera.viewfinder") { showsScanner = true }
            }
            .padding(.horizontal, 16)
        }

        // MARK: Details

        private var details: some View {
            VStack(alignment: .leading, spacing: 12) {
                PesaSectionHeader(title: "Card details")
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label(card.isVirtual ? "Virtual card" : "Physical card", systemImage: card.isVirtual ? "globe" : "creditcard.fill")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(card.isFrozen ? "Frozen" : "Active")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(card.isFrozen ? Color.blue : PesaStyle.positive)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((card.isFrozen ? Color.blue : PesaStyle.positive).opacity(0.12), in: Capsule())
                    }
                    KitoRevealableSecret("Card number", mask: .lastFour, reason: "Show your \(card.name) card number") {
                        try? keychain.string(for: numberKey(card))
                    }
                    .id("number-\(card.id)")
                    KitoRevealableSecret("CVV", mask: .dots, reason: "Show your \(card.name) card’s CVV", autoHide: .seconds(15), copyable: false) {
                        try? keychain.string(for: cvvKey(card))
                    }
                    .id("cvv-\(card.id)")
                    HStack {
                        Text("Expires").foregroundStyle(.secondary)
                        Spacer()
                        Text(card.face.expiry).monospacedDigit()
                    }
                    .font(.subheadline)
                }
                .pesaSurface()
            }
            .padding(.horizontal, 16)
        }

        private var limit: some View {
            let spent = store.spent(on: card)
            return VStack(alignment: .leading, spacing: 12) {
                PesaSectionHeader(title: "Monthly limit")
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(PesaMoney.string(card.monthlyLimit, cents: .never))
                            .font(.title2.weight(.bold))
                            .monospacedDigit()
                            .contentTransition(.numericText(value: card.monthlyLimit))
                        Spacer()
                        Text("\(PesaMoney.string(spent, cents: .never)) spent")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    PesaProgressBar(fraction: card.monthlyLimit > 0 ? spent / card.monthlyLimit : 0, color: .primary)
                    Slider(value: binding(\.monthlyLimit), in: 5_000...200_000, step: 1_000) {
                        Text("Monthly limit")
                    } minimumValueLabel: {
                        Text("5K").font(.caption).foregroundStyle(.secondary)
                    } maximumValueLabel: {
                        Text("200K").font(.caption).foregroundStyle(.secondary)
                    } onEditingChanged: { editing in
                        if !editing { KitoHaptics.selectionChanged() }
                    }
                    .tint(.primary)
                    .accessibilityValue(PesaMoney.string(card.monthlyLimit, cents: .never))
                    Text("Payments over the limit are declined until next month. You can change it any time.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .pesaSurface()
            }
            .padding(.horizontal, 16)
        }

        private var controls: some View {
            KitoSettingsSection("Controls", footer: "Changes apply straight away, on this card only.") {
                KitoToggleRow("Online payments", systemImage: "globe", color: .blue, isOn: binding(\.onlinePayments))
                KitoToggleRow("Contactless", systemImage: "wave.3.right", color: .green, isOn: binding(\.contactless))
                KitoToggleRow("Cash withdrawals", systemImage: "banknote.fill", color: .orange, isOn: binding(\.withdrawals))
            }
            .padding(.horizontal, 16)
            .kitoSettingsTint(.primary)
        }

        // MARK: Actions

        private func toggleFreeze() {
            let frozen = !card.isFrozen
            withAnimation(reduceMotion ? nil : .snappy) { store.toggleFreeze(card.id) }
            if frozen { KitoHaptics.play(.ticks(count: 6, interval: 0.05)) } else { KitoHaptics.success() }
            toasts.show(KitoToast(title: frozen ? "\(card.name) card frozen" : "\(card.name) card is back on",
                                  message: frozen ? "Payments are blocked until you unfreeze it." : "You can pay with it again.",
                                  style: frozen ? .info : .success, icon: .custom(frozen ? "snowflake" : "sun.max.fill")))
        }

        private func flip() async {
            flipBack?.cancel()
            if flippedID == card.id {
                withAnimation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.8)) { flippedID = nil }
                return
            }
            let id = card.id
            guard await gate.confirm(reason: "Show your \(card.name) card’s CVV") else { return }
            withAnimation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.8)) { flippedID = id }
            flipBack = Task {
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled else { return }
                withAnimation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.8)) { if flippedID == id { flippedID = nil } }
            }
        }

        private func binding<Value>(_ keyPath: WritableKeyPath<PesaCard, Value>) -> Binding<Value> {
            Binding {
                card[keyPath: keyPath]
            } set: { value in
                var updated = card
                updated[keyPath: keyPath] = value
                store.update(updated)
            }
        }

        private func numberKey(_ card: PesaCard) -> String { "card.\(card.id).number" }
        private func cvvKey(_ card: PesaCard) -> String { "card.\(card.id).cvv" }

        /// The made-up card numbers go into the keychain, so the reveal reads them back the way a
        /// real app would read a token.
        private func storeDemoNumbers() {
            for card in store.cards {
                try? keychain.set(card.demoNumber, for: numberKey(card))
                try? keychain.set(card.demoCVV, for: cvvKey(card))
            }
        }
    }

    /// A card face with the frost overlay and a "Frozen" tag.
    private struct PesaCardFace: View {
        let card: PesaCard
        let isFlipped: Bool

        var body: some View {
            KitoWalletCardView(card: card.face, showsBalance: !isFlipped, isFlipped: isFlipped, cvv: isFlipped ? card.demoCVV : nil)
                .overlay { PesaFrostOverlay(isFrozen: card.isFrozen) }
                .overlay(alignment: .topTrailing) {
                    if card.isFrozen {
                        Label("Frozen", systemImage: "snowflake")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(red: 0.15, green: 0.35, blue: 0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.85), in: Capsule())
                            .padding(12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .kitoCardTilt()
                .shadow(color: .black.opacity(0.22), radius: 14, y: 8)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(card.name) card, \(card.face.maskedNumber)\(card.isFrozen ? ", frozen" : "")")
                .accessibilityValue(PesaMoney.string(card.balance, cents: .never))
        }
    }

    /// Scan a card with the camera (or the sample card in the Simulator) and add it.
    private struct PesaAddCardSheet: View {
        let store: PesaStore
        let added: (String) -> Void

        @Environment(\.dismiss) private var dismiss
        @Environment(KitoToastCenter.self) private var toasts

        var body: some View {
            NavigationStack {
                ScrollView {
                    KitoCardScanner(tint: .primary) { details in
                        let card = store.addCard(last4: details.last4, holder: details.holderName, expiry: details.expiry?.formatted)
                        toasts.show(KitoToast(title: "Card added", message: "Card ending \(details.last4) is ready to use.", style: .success,
                                              icon: .custom("creditcard.fill")))
                        added(card.id)
                        dismiss()
                    }
                    .padding(16)
                }
                .navigationTitle("Add a card")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
            }
        }
    }
}
