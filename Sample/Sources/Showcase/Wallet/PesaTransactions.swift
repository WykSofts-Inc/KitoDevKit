//
//  PesaTransactions.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoFormatting
import KitoButtons
import KitoToasts
import KitoHaptics

extension WalletShowcase {
    /// Every transaction, grouped by day, with search and category chips.
    struct PesaTransactionsScreen: View {
        @Bindable var store: PesaStore
        let open: (PesaTransaction) -> Void

        @State private var query = ""
        @State private var category: PesaCategory?

        private var filtered: [PesaTransaction] {
            store.transactions.filter { transaction in
                (category == nil || transaction.category == category)
                    && (query.isEmpty || transaction.title.localizedCaseInsensitiveContains(query)
                        || (transaction.note?.localizedCaseInsensitiveContains(query) ?? false))
            }
        }

        private var days: [(day: Date, items: [PesaTransaction])] {
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.date) }
            return grouped.keys.sorted(by: >).map { ($0, grouped[$0] ?? []) }
        }

        var body: some View {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            chip(nil, title: "All")
                            ForEach(PesaCategory.allCases) { chip($0, title: $0.title) }
                        }
                        .padding(.horizontal, 16)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                if days.isEmpty {
                    ContentUnavailableView.search(text: query)
                        .listRowBackground(Color.clear)
                }
                ForEach(days, id: \.day) { day in
                    Section {
                        ForEach(day.items) { transaction in
                            Button { open(transaction) } label: {
                                PesaTransactionRow(transaction: transaction, contact: store.contact(transaction.contactID),
                                                   isHidden: store.isBalanceHidden)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        HStack {
                            Text(KitoDateFormatting.dayLabel(day.day))
                            Spacer()
                            let net = day.items.map(\.amount).reduce(0, +)
                            if !store.isBalanceHidden {
                                Text(PesaMoney.signed(net)).monospacedDigit()
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $query, prompt: "Search merchants and people")
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
        }

        private func chip(_ value: PesaCategory?, title: String) -> some View {
            let isOn = category == value
            return Button {
                KitoHaptics.selectionChanged()
                withAnimation(.snappy) { category = value }
            } label: {
                Label(title, systemImage: value?.systemImage ?? "line.3.horizontal.decrease")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .foregroundStyle(isOn ? Color(.systemBackground) : .primary)
                    .background(isOn ? Color.primary : Color(.secondarySystemGroupedBackground), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isOn ? .isSelected : [])
        }
    }

    /// One transaction: a big amount, the details, and a PDF receipt to share.
    struct PesaTransactionDetail: View {
        @Bindable var store: PesaStore
        let transaction: PesaTransaction

        @Environment(KitoToastCenter.self) private var toasts
        @State private var receipt: PesaReceipt?

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        PesaTransactionIcon(transaction: transaction, contact: store.contact(transaction.contactID), size: 72)
                        Text(transaction.title)
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                        Text(PesaMoney.signed(transaction.amount))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(transaction.isIncoming ? PesaStyle.positive : .primary)
                        Label("Completed", systemImage: "checkmark.seal.fill")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(PesaStyle.positive)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(PesaStyle.positive.opacity(0.12), in: Capsule())
                    }
                    .padding(.top, 12)
                    .accessibilityElement(children: .combine)

                    VStack(spacing: 0) {
                        detailRow("Date", KitoDateFormatting.full(transaction.date))
                        Divider()
                        detailRow("Category", transaction.category.title, symbol: transaction.category.systemImage)
                        Divider()
                        detailRow("Card", store.card(transaction.cardID).map { "\($0.name) \($0.face.maskedNumber)" } ?? "Everyday")
                        if let note = transaction.note {
                            Divider()
                            detailRow("Note", note)
                        }
                        Divider()
                        HStack {
                            Text("Reference").foregroundStyle(.secondary)
                            Spacer()
                            Text(transaction.reference).font(.body.monospaced())
                            Button {
                                UIPasteboard.general.string = transaction.reference
                                KitoHaptics.success()
                                toasts.show("Reference copied", style: .success)
                            } label: { Image(systemName: "doc.on.doc") }
                                .accessibilityLabel("Copy reference")
                        }
                        .padding(.vertical, 12)
                    }
                    .pesaSurface(padding: 16)

                    VStack(spacing: 12) {
                        KitoButton("Receipt", systemImage: "doc.richtext") {
                            receipt = PesaReceipt(transaction: transaction, card: store.card(transaction.cardID))
                        }
                        .fullWidth()
                        .size(.large)
                        KitoButton("Report a problem", systemImage: "exclamationmark.bubble") {
                            toasts.show(KitoToast(title: "We’re on it", message: "Support will reply in the app within an hour. (Demo, nothing is sent.)", style: .info))
                        }
                        .variant(.ghost)
                        .fullWidth()
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $receipt) { PesaReceiptSheet(receipt: $0) }
        }

        private func detailRow(_ title: String, _ value: String, symbol: String? = nil) -> some View {
            HStack(alignment: .firstTextBaseline) {
                Text(title).foregroundStyle(.secondary)
                Spacer(minLength: 16)
                if let symbol { Image(systemName: symbol).foregroundStyle(.secondary) }
                Text(value).multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 12)
            .accessibilityElement(children: .combine)
        }
    }
}
