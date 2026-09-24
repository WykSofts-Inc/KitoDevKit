//
//  PesaDocuments.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoFileViewer
import KitoFormatting

extension WalletShowcase {
    struct PesaReceipt: Identifiable {
        let id = UUID()
        let transaction: PesaTransaction
        let card: PesaCard?
    }

    /// Receipts and statements drawn with SwiftUI and written as vector PDFs to a temporary folder.
    @MainActor
    enum PesaDocuments {
        static func receiptPDF(_ receipt: PesaReceipt) -> URL? {
            render(PesaReceiptPage(receipt: receipt), name: "Pesa receipt \(receipt.transaction.reference).pdf")
        }

        static func statementPDF(month: Date, transactions: [PesaTransaction]) -> URL? {
            let title = month.formatted(.dateTime.month(.wide).year())
            return render(PesaStatementPage(month: month, transactions: transactions.sorted { $0.date < $1.date }),
                          name: "Pesa statement \(title).pdf")
        }

        private static func render<Page: View>(_ page: Page, name: String) -> URL? {
            let renderer = ImageRenderer(content: page.environment(\.colorScheme, .light).frame(width: 595))
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            var didRender = false
            renderer.render { size, draw in
                var box = CGRect(origin: .zero, size: size)
                guard let context = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
                context.beginPDFPage(nil)
                draw(context)
                context.endPDFPage()
                context.closePDF()
                didRender = true
            }
            return didRender ? url : nil
        }
    }

    /// Shows a transaction's receipt as a PDF with Share.
    struct PesaReceiptSheet: View {
        let receipt: PesaReceipt

        @Environment(\.dismiss) private var dismiss
        @State private var url: URL?

        var body: some View {
            NavigationStack {
                Group {
                    if let url {
                        KitoPDFViewer(url: url, showsThumbnails: false, showsShareButton: false)
                    } else {
                        ProgressView("Preparing your receipt…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .navigationTitle("Receipt")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
                }
                .safeAreaInset(edge: .bottom) {
                    if let url {
                        KitoShareButton("Share receipt", urls: [url])
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }
                }
            }
            .task { url = PesaDocuments.receiptPDF(receipt) }
        }
    }

    private struct PesaWordmark: View {
        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.black, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text("Pesa").font(.system(size: 22, weight: .heavy, design: .rounded))
            }
        }
    }

    private struct PesaReceiptPage: View {
        let receipt: PesaReceipt

        private var transaction: PesaTransaction { receipt.transaction }

        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    PesaWordmark()
                    Spacer()
                    Text(transaction.isIncoming ? "Money received" : "Payment receipt")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.gray)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(transaction.isIncoming ? "From \(transaction.title)" : "To \(transaction.title)")
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                    Text(PesaMoney.string(abs(transaction.amount), cents: .always))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    Label("Completed", systemImage: "checkmark.seal.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(PesaStyle.positive)
                }
                VStack(spacing: 0) {
                    line("Date", KitoDateFormatting.full(transaction.date))
                    line("Reference", transaction.reference)
                    line("Category", transaction.category.title)
                    if let card = receipt.card { line("Paid with", "\(card.name) card \(card.face.maskedNumber)") }
                    if let note = transaction.note { line("Note", note) }
                    line("Fee", PesaMoney.string(0, cents: .always))
                }
                Spacer(minLength: 24)
                Text("Pesa is a demo app from the Kito DevKit. No money moved; every name and number on this receipt is made up.")
                    .font(.system(size: 11))
                    .foregroundStyle(.gray)
            }
            .padding(40)
            .frame(width: 595, height: 620, alignment: .topLeading)
            .background(.white)
            .foregroundStyle(.black)
        }

        private func line(_ title: String, _ value: String) -> some View {
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title).foregroundStyle(.gray)
                    Spacer(minLength: 24)
                    Text(value).multilineTextAlignment(.trailing)
                }
                .font(.system(size: 14))
                .padding(.vertical, 10)
                Rectangle().fill(Color.gray.opacity(0.25)).frame(height: 0.5)
            }
        }
    }

    private struct PesaStatementPage: View {
        let month: Date
        let transactions: [PesaTransaction]

        private var moneyIn: Double { transactions.filter(\.isIncoming).map(\.amount).reduce(0, +) }
        private var moneyOut: Double { transactions.filter { !$0.isIncoming }.map { -$0.amount }.reduce(0, +) }

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    PesaWordmark()
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Account statement").font(.system(size: 13, weight: .semibold))
                        Text(month.formatted(.dateTime.month(.wide).year())).font(.system(size: 13)).foregroundStyle(.gray)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(PesaStore.ownerName).font(.system(size: 15, weight: .semibold))
                    Text("Everyday account · 0100 4417 4120").font(.system(size: 12)).foregroundStyle(.gray)
                }
                HStack(spacing: 12) {
                    summary("Money in", PesaMoney.string(moneyIn, cents: .always), color: PesaStyle.positive)
                    summary("Money out", PesaMoney.string(moneyOut, cents: .always), color: .black)
                    summary("Net", PesaMoney.signed(moneyIn - moneyOut), color: .black)
                }
                VStack(spacing: 0) {
                    HStack {
                        Text("Date").frame(width: 70, alignment: .leading)
                        Text("Description")
                        Spacer()
                        Text("Amount")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.gray)
                    .padding(.vertical, 6)
                    ForEach(transactions) { transaction in
                        HStack(alignment: .firstTextBaseline) {
                            Text(transaction.date.formatted(.dateTime.day().month(.abbreviated))).frame(width: 70, alignment: .leading)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(transaction.title)
                                Text("\(transaction.category.title) · \(transaction.reference)").font(.system(size: 9)).foregroundStyle(.gray)
                            }
                            Spacer()
                            Text(PesaMoney.signed(transaction.amount))
                                .foregroundStyle(transaction.isIncoming ? PesaStyle.positive : .black)
                        }
                        .font(.system(size: 11))
                        .padding(.vertical, 5)
                        Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 0.5)
                    }
                }
                Text("Demo statement from the Kito DevKit. No real account, card or money is involved.")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
            }
            .padding(40)
            .frame(width: 595, alignment: .topLeading)
            .frame(minHeight: 842, alignment: .top)
            .background(.white)
            .foregroundStyle(.black)
        }

        private func summary(_ title: String, _ value: String, color: Color) -> some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 11)).foregroundStyle(.gray)
                Text(value).font(.system(size: 15, weight: .bold)).foregroundStyle(color)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
