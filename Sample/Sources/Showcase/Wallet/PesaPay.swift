//
//  PesaPay.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoScanner
import KitoNavigation
import KitoFields
import KitoHaptics

extension WalletShowcase {
    private struct PesaPendingPayment: Identifiable {
        let id = UUID()
        let request: KitoPaymentRequest
    }

    /// Pay: scan a till, paybill or friend's code, or show your own code to get paid.
    struct PesaPayTab: View {
        @Bindable var store: PesaStore

        @State private var mode = "Pay"
        @State private var showsScanner = false
        @State private var scanned: KitoPaymentRequest?
        @State private var pending: PesaPendingPayment?
        @State private var showsBills = false
        @State private var askAmount: Double?

        private var myRequest: KitoPaymentRequest {
            KitoPaymentRequest(kind: .phone, number: PesaStore.ownerPhone, amount: askAmount.flatMap { $0 > 0 ? Decimal($0) : nil },
                               merchant: PesaStore.ownerName)
        }

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        KitoTopTabs(["Pay", "Get paid"], selection: $mode, style: .pill, tint: .primary)
                        if mode == "Pay" { pay } else { getPaid }
                    }
                    .padding(16)
                    .animation(.snappy, value: mode)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle("Pay")
                .pesaExitToolbar()
                .fullScreenCover(isPresented: $showsScanner, onDismiss: presentScanned) {
                    KitoCodeScanner(symbologies: [.qr], overlay: .laser, hint: "Point at a Pesa, till or paybill code", tint: .primary,
                                    onPay: { request in
                                        scanned = request
                                        showsScanner = false
                                    },
                                    onClose: { showsScanner = false })
                }
                .sheet(item: $pending) { payment in
                    NavigationStack {
                        PesaPayConfirm(store: store, request: payment.request) { pending = nil }
                            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { pending = nil } } }
                    }
                }
                .sheet(isPresented: $showsBills) { PesaPayBillSheet(store: store) }
            }
        }

        private var pay: some View {
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    KitoHaptics.impact(.medium)
                    showsScanner = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 34, weight: .semibold))
                            .frame(width: 64, height: 64)
                            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Scan to pay").font(.title3.weight(.bold))
                            Text("Tills, paybills and friends’ Pesa codes").font(.subheadline).opacity(0.75)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.headline)
                    }
                    .foregroundStyle(Color(.systemBackground))
                    .padding(20)
                    .background(Color.primary, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                }
                .buttonStyle(PesaPressStyle())

                Button { showsBills = true } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.fill").font(.headline).frame(width: 40, height: 40)
                            .background(Color.purple.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(.purple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pay a bill").font(.body.weight(.semibold))
                            Text("Power, water, fibre and rent").font(.footnote).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .pesaSurface(padding: 14)

                PesaSectionHeader(title: "Try a sample code")
                Text("No camera in the Simulator? Tap one of these, or choose Use sample code in the scanner.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        sample(KitoScannerSamples.payment, symbol: "storefront.fill")
                        sample(KitoScannerSamples.paybill, symbol: "drop.fill")
                        sample(KitoPaymentRequest(kind: .till, number: "552031", amount: 450, merchant: "Kahawa House", note: "Flat white"),
                               symbol: "cup.and.saucer.fill")
                    }
                }
            }
        }

        private func sample(_ request: KitoPaymentRequest, symbol: String) -> some View {
            Button {
                pending = PesaPendingPayment(request: request)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    KitoQRCodeView(request.payload, style: .dots)
                        .frame(width: 96, height: 96)
                    Label(request.merchant ?? request.number, systemImage: symbol)
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                    Text("\(request.kind.title) \(request.number)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 150, alignment: .leading)
                .pesaSurface(padding: 12)
            }
            .buttonStyle(PesaPressStyle())
            .accessibilityLabel("Pay \(request.merchant ?? request.number) with a sample code")
        }

        private var getPaid: some View {
            VStack(alignment: .leading, spacing: 20) {
                KitoQRCodeCard(myRequest.payload, title: PesaStore.ownerName,
                               subtitle: askAmount.map { $0 > 0 ? "Asking \(PesaMoney.string($0))" : "Pesa · 0712 ••• 678" } ?? "Pesa · 0712 ••• 678",
                               caption: "Scan to pay me", style: .dots, tint: .primary)
                    .frame(maxWidth: .infinity)
                    .id(myRequest.payload)
                    .transition(.opacity)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ask for a set amount").font(.headline)
                    KitoCurrencyField("Amount", value: $askAmount, currencyCode: "KES", prompt: "Any amount")
                    Text("The code updates as you type, so whoever scans it doesn’t have to.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .pesaSurface()
            }
        }

        private func presentScanned() {
            guard let scanned else { return }
            self.scanned = nil
            pending = PesaPendingPayment(request: scanned)
        }
    }
}
