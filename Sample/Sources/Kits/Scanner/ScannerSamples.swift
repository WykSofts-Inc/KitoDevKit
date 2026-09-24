//
//  ScannerSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import UIKit
import KitoScanner

/// The Scanner kit's gallery: live scanning, result cards, QR generation, documents and cards.
/// Everything runs in the Simulator too: without a camera the scanners offer sample codes,
/// sample pages and a sample card.
struct ScannerGallery: View {
    static var count: Int { KitGallery.count(ScannerSamples.sections) }

    var body: some View {
        KitGallery(title: "Scanner", sections: ScannerSamples.sections, footnote: "Requires `import KitoScanner`.",
                   searchHint: "Try “pay”, “Wi-Fi”, “barcode”, “PDF” or “card”.")
    }
}

enum ScannerSamples {
    static let sections: [KitSection] = [
        KitSection("Live scanning", symbol: "qrcode.viewfinder", [
            KitSample("Scan anything", "QR codes and barcodes, with animated corner brackets. Stops on the first code and shows what's in it.", code: """
            KitoCodeScanner { code in
                print(code.payload)
            }
            """) {
                ModalStage { KitoCodeScanner() }
            },
            KitSample("Laser sweep", "A glowing line sweeps the window; it rests in the middle with Reduce Motion on.", code: """
            KitoCodeScanner(overlay: .laser) { code in
                handle(code)
            }
            """) {
                ModalStage { KitoCodeScanner(overlay: .laser) }
            },
            KitSample("Dimmed frame", "A rounded cut-out with the rest of the feed dimmed, tinted to your brand.", code: """
            KitoCodeScanner(overlay: .frame, tint: .green) { code in
                handle(code)
            }
            """) {
                ModalStage { KitoCodeScanner(overlay: .frame, tint: ScannerPalette.mpesa) }
            },
            KitSample("Whole-screen minimal", "Just a reticle; the whole camera feed scans.", code: """
            KitoCodeScanner(overlay: .minimal)
            """) {
                ModalStage { KitoCodeScanner(overlay: .minimal) }
            },
            KitSample("Continuous with recent scans", "Keeps scanning. Each new code joins a tray you can tap back into; repeats are ignored for a moment.", code: """
            KitoCodeScanner(mode: .continuous) { code in
                inventory.add(code)
            }
            """) {
                ModalStage { KitoCodeScanner(mode: .continuous, tint: .indigo) }
            },
            KitSample("Supermarket barcodes", "EAN-13, UPC-A, EAN-8 and UPC-E only, with a wide window and the check digit verified.", code: """
            KitoCodeScanner(symbologies: KitoSymbology.retail,
                            overlay: .laser, mode: .continuous) { code in
                if case .product(let product) = code.payload, product.isValid {
                    basket.add(product.digits)
                }
            }
            """) {
                ModalStage { KitoCodeScanner(symbologies: KitoSymbology.retail, overlay: .laser, mode: .continuous, tint: .orange) }
            },
            KitSample("Scan to pay", "Reads a till QR code and hands the request to your checkout from the Pay button.", code: """
            KitoCodeScanner(symbologies: [.qr], overlay: .frame,
                            onPay: { request in
                                startPayment(till: request.number, amount: request.amount)
                            },
                            onClose: { dismiss() })
            """) {
                ModalStage { ScannerCheckoutDemo() }
            },
            KitSample("From a photo", "No camera needed: pick a screenshot or photo and the codes in it are found and highlighted.", code: """
            KitoCodeScanner(engine: .photos) { code in
                handle(code)
            }
            """) {
                ModalStage { KitoCodeScanner(engine: .photos, tint: .teal) }
            },
        ]),
        KitSection("What's in the code", symbol: "rectangle.stack.fill", [
            KitSample("Payment request", "A Buy Goods till with amount and merchant, and a Pay button.", code: """
            let code = KitoScannedCode(raw: "kitopay://till/832910?amount=450&name=Mama%20Mboga%20Greens")
            KitoScanResultCard(code: code, onPay: { request in
                checkout(request)
            })
            """) {
                ScannerResultPreview(raw: KitoScannerSamples.payment.payload, symbology: .qr, payable: true)
            },
            KitSample("Wi-Fi network", "Join with the Hotspot Configuration capability; otherwise the password is copied with directions.", code: """
            KitoScanResultCard(code: KitoScannedCode(raw: "WIFI:S:Kahawa House Guest;T:WPA;P:karibu2026;;"))
            """) {
                ScannerResultPreview(raw: KitoScannerSamples.wifi.payload, symbology: .qr)
            },
            KitSample("Contact card", "vCard or MECARD, with Add contact, Call and Email.", code: """
            let card = KitoContactCard(name: "Achieng Owuor", organization: "Safari Tech",
                                       phones: ["+254 712 345 678"], emails: ["achieng@example.co.ke"])
            KitoScanResultCard(code: KitoScannedCode(raw: card.vCard))
            """) {
                ScannerResultPreview(raw: KitoScannerSamples.contact.vCard, symbology: .qr)
            },
            KitSample("Event", "A VEVENT with a date badge and Add to calendar.", code: """
            KitoScanResultCard(code: KitoScannedCode(raw: \"\"\"
            BEGIN:VEVENT
            SUMMARY:Nairobi Tech Week
            DTSTART:20261014T060000Z
            DTEND:20261014T140000Z
            LOCATION:KICC\\\\, Nairobi
            END:VEVENT
            \"\"\"))
            """) {
                ScannerResultPreview(raw: KitoScannerSamples.event.payload, symbology: .qr)
            },
            KitSample("Place", "A geo: code with a map preview and Open in Maps.", code: """
            KitoScanResultCard(code: KitoScannedCode(raw: "geo:-1.28638,36.81723?q=Kenyatta%20Avenue"))
            """) {
                ScannerResultPreview(raw: KitoScannerSamples.place.payload, symbology: .qr)
            },
            KitSample("Product barcode", "EAN-13 redrawn, check digit verified and the GS1 region named.", code: """
            KitoScanResultCard(code: KitoScannedCode(raw: "6161001234567", symbology: .ean13))
            """) {
                ScannerResultPreview(raw: KitoScannerSamples.product, symbology: .ean13)
            },
            KitSample("Parse any payload", "Type or pick a payload and watch it parse live.", code: """
            let payload = KitoCodeParser.parse(text)
            switch payload {
            case .wifi(let network): join(network)
            case .payment(let request): pay(request)
            default: show(payload.summary)
            }
            """) {
                ScannerParsePlayground()
            },
        ]),
        KitSection("QR codes", symbol: "qrcode", [
            KitSample("Four styles", "Plain, dots, rounded and gradient, generated on device and drawn as vectors.", code: """
            KitoQRCodeView(link)
            KitoQRCodeView(link, style: .dots)
            KitoQRCodeView(link, style: .rounded)
            KitoQRCodeView(link, style: .gradient([.teal, .indigo]))
            """) {
                ScannerQRStyles()
            },
            KitSample("Logo in the middle", "Error correction goes up to High automatically so it still scans.", code: """
            KitoQRCodeView("https://wyksoftsinc.com",
                           style: .gradient([.orange, .red]),
                           logo: Image(systemName: "leaf.fill"))
            """) {
                KitoQRCodeView("https://wyksoftsinc.com", style: .gradient([Color(red: 0.9, green: 0.45, blue: 0.1), Color(red: 0.7, green: 0.12, blue: 0.2)]),
                               logo: Image(systemName: "leaf.fill"))
                    .frame(width: 240)
            },
            KitSample("Scan-to-pay poster", "Title, caption and Share; Save appears when the app can add to Photos.", code: """
            let till = KitoPaymentRequest(kind: .till, number: "832910",
                                          amount: 450, merchant: "Mama Mboga Greens")
            KitoQRCodeCard(till.payload, title: "Mama Mboga Greens",
                           subtitle: "Till 832910 · KES 450", caption: "Scan to pay")
            """) {
                KitoQRCodeCard(KitoScannerSamples.payment.payload, title: "Mama Mboga Greens", subtitle: "Till 832910 · KES 450",
                               caption: "Scan to pay", tint: ScannerPalette.mpesa)
            },
            KitSample("Wi-Fi sign", "Type a network and password; the sign updates as you go.", code: """
            let network = KitoWiFiNetwork(ssid: ssid, password: password)
            KitoQRCodeCard(network.payload, title: ssid,
                           caption: "Scan to join", style: .rounded)
            """) {
                ScannerWiFiSign()
            },
            KitSample("EAN-13 barcode", "Product barcodes drawn from their digits, with a check digit added to 12-digit bodies.", code: """
            KitoBarcodeView(ean13: "616100123456")   // → 6161001234567
            """) {
                ScannerBarcodeLabel()
            },
        ]),
        KitSection("Documents and cards", symbol: "doc.viewfinder", [
            KitSample("Document scanner", "Scan pages with the VisionKit document camera, or import photos or samples where it isn't available.", code: """
            KitoDocumentScanner(title: "Receipt") { document in
                upload(document.pdfData())
            }
            """) {
                ModalStage { KitoDocumentScanner(title: "Receipt") }
            },
            KitSample("Review and export", "Crop-style preview, page strip, Colour / Greyscale / B&W and PDF export.", code: """
            KitoDocumentScanner(title: "Kilimani Heights invoice",
                                pages: scannedPages) { document in
                save(document.pdfData())
            }
            """) {
                ModalStage { ScannerDocumentReview() }
            },
            KitSample("Card scanner", "Reads number, expiry and name on device. Only the last four digits are kept.", code: """
            KitoCardScanner { details in
                form.last4 = details.last4
                form.expiry = details.expiry
                form.name = details.holderName
            }
            """) {
                ModalStage { KitoCardScanner(tint: .indigo) }
            },
            KitSample("Card text parsing", "The pure parsing behind the card scanner: Luhn, expiry and name from OCR lines.", code: """
            let details = KitoCardTextParser.details(from: [
                "KITO BANK", "4242 4242 4242 4242", "VALID THRU 08/29", "ACHIENG W OWUOR",
            ])
            details?.maskedNumber   // "•••• •••• •••• 4242"
            details?.expiry         // 08/29
            """) {
                ScannerCardParsing()
            },
        ]),
    ]
}

// MARK: - Shared

private enum ScannerPalette {
    static let mpesa = Color(red: 0.05, green: 0.55, blue: 0.3)
}

/// A result card on a soft backdrop, as it would sit under a camera.
private struct ScannerResultPreview: View {
    let raw: String
    let symbology: KitoSymbology
    var payable = false
    @State private var paid: String?

    var body: some View {
        VStack(spacing: 14) {
            KitoScanResultCard(code: KitoScannedCode(raw: raw, symbology: symbology),
                               onPay: payable ? { request in paid = request.formattedAmount ?? request.number } : nil)
            if let paid {
                Label("Payment of \(paid) started", systemImage: "checkmark.circle.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(ScannerPalette.mpesa)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.spring(duration: 0.35), value: paid)
    }
}

// MARK: - Live scanning

private struct ScannerCheckoutDemo: View {
    @State private var receipt: KitoPaymentRequest?

    var body: some View {
        KitoCodeScanner(symbologies: [.qr], overlay: .frame, tint: ScannerPalette.mpesa,
                        onPay: { request in receipt = request })
            .alert("Payment started", isPresented: Binding(get: { receipt != nil }, set: { if !$0 { receipt = nil } })) {
                Button("Done") { receipt = nil }
            } message: {
                if let receipt {
                    Text("\(receipt.formattedAmount ?? "Payment") to \(receipt.merchant ?? receipt.number). Confirm with your PIN.")
                }
            }
    }
}

// MARK: - Results

private struct ScannerParsePlayground: View {
    private static let presets: [(String, String)] = [
        ("Pay", KitoScannerSamples.payment.payload),
        ("Paybill", KitoScannerSamples.paybill.payload),
        ("Wi-Fi", KitoScannerSamples.wifi.payload),
        ("MECARD", "MECARD:N:Mwangi,Baraka;TEL:+254733000111;EMAIL:baraka@example.co.ke;;"),
        ("SMS", "SMSTO:+254712345678:Nimefika, niko gate"),
        ("Geo", "geo:-4.0435,39.6682?q=Fort%20Jesus"),
        ("UPC", "036000291452"),
        ("Link", "www.example.co.ke"),
    ]

    @State private var text = KitoScannerSamples.wifi.payload

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Self.presets, id: \.0) { preset in
                        Button(preset.0) { text = preset.1 }
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 12)
                            .frame(minHeight: 34)
                            .background(Capsule().fill(text == preset.1 ? Color.primary : Color.primary.opacity(0.08)))
                            .foregroundStyle(text == preset.1 ? Color(.systemBackground) : Color.primary)
                            .buttonStyle(.plain)
                    }
                }
            }
            TextField("Paste a payload", text: $text, axis: .vertical)
                .font(.system(.footnote, design: .monospaced))
                .lineLimit(2...5)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
            KitoScanResultCard(code: KitoScannedCode(raw: text))
                .id(text)
                .transition(.opacity)
        }
        .animation(.snappy, value: text)
    }
}

// MARK: - QR codes

private struct ScannerQRStyles: View {
    private let link = "https://wyksoftsinc.com"

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
            tile("Plain", KitoQRCodeView(link))
            tile("Dots", KitoQRCodeView(link, style: .dots))
            tile("Rounded", KitoQRCodeView(link, style: .rounded, tint: Color(red: 0.1, green: 0.2, blue: 0.45)))
            tile("Gradient", KitoQRCodeView(link, style: .gradient([.teal, .indigo])))
        }
    }

    private func tile(_ title: String, _ code: KitoQRCodeView) -> some View {
        VStack(spacing: 8) {
            code
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            Text(title).font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
        }
    }
}

private struct ScannerWiFiSign: View {
    @State private var ssid = "Kahawa House Guest"
    @State private var password = "karibu2026"

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                field("Network", text: $ssid, symbol: "wifi")
                field("Password", text: $password, symbol: "key.fill")
            }
            KitoQRCodeCard(network.payload, title: ssid.isEmpty ? "Wi-Fi" : ssid,
                           subtitle: password.isEmpty ? "Open network" : "Password: \(password)",
                           caption: "Scan to join", style: .rounded, tint: Color(red: 0.42, green: 0.26, blue: 0.16))
        }
    }

    private var network: KitoWiFiNetwork {
        KitoWiFiNetwork(ssid: ssid, password: password.isEmpty ? nil : password)
    }

    private func field(_ title: String, text: Binding<String>, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).foregroundStyle(.secondary).frame(width: 22)
            TextField(title, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
    }
}

private struct ScannerBarcodeLabel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pure Highland Honey").font(.headline)
                    Text("500 g · Product of Kenya").font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                Text("KES 890").font(.title3.bold())
            }
            KitoBarcodeView(ean13: "616100123456")
                .frame(maxWidth: 260)
                .frame(maxWidth: .infinity)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(red: 1, green: 0.96, blue: 0.86)))
        .foregroundStyle(Color.black)
        .environment(\.colorScheme, .light)
    }
}

// MARK: - Documents and cards

private struct ScannerDocumentReview: View {
    @State private var pages: [UIImage]?

    var body: some View {
        Group {
            if let pages {
                KitoDocumentScanner(title: "Kilimani Heights invoice", pages: pages, tint: .indigo)
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { if pages == nil { pages = KitoScannerSamples.documentPages() } }
    }
}

private struct ScannerCardParsing: View {
    private static let samples: [(String, [String])] = [
        ("Debit", ["KITO BANK", "DEBIT", "4242 4242 4242 4242", "VALID THRU 08/29", "ACHIENG W OWUOR"]),
        ("OCR slips", ["5555 5555 SSSS 4444", "VALID FROM 01/24 THRU 01/28", "BARAKA MWANGI"]),
        ("Amex", ["AMERICAN EXPRESS", "3782 822463 10005", "12/2030", "ZAWADI NJERI"]),
        ("Invalid", ["4242 4242 4242 4241", "09/27", "WANJIRU KAMAU"]),
    ]

    @State private var index = 0

    var body: some View {
        let lines = Self.samples[index].1
        let details = KitoCardTextParser.details(from: lines)
        VStack(alignment: .leading, spacing: 14) {
            Picker("Sample", selection: $index) {
                ForEach(Self.samples.indices, id: \.self) { Text(Self.samples[$0].0).tag($0) }
            }
            .pickerStyle(.segmented)
            VStack(alignment: .leading, spacing: 4) {
                Text("Recognised text").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                ForEach(lines, id: \.self) { Text($0).font(.system(.footnote, design: .monospaced)) }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
            if let details {
                ScannerCardResult(details: details)
            } else {
                Label("No Luhn-valid number, so nothing is returned.", systemImage: "xmark.seal.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.red)
            }
        }
        .animation(.snappy, value: index)
    }
}

private struct ScannerCardResult: View {
    let details: KitoCardDetails

    var body: some View {
        VStack(spacing: 0) {
            row("Brand", details.brand.title)
            row("Number", details.maskedNumber, monospaced: true)
            row("Expiry", details.expiry?.formatted ?? "—", monospaced: true)
            row("Name", details.holderName ?? "—")
            row("Luhn", details.isNumberValid ? "Passes" : "Fails")
        }
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.12)))
    }

    private func row(_ label: String, _ value: String, monospaced: Bool = false) -> some View {
        HStack {
            Text(label).font(.footnote).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(monospaced ? .system(.footnote, design: .monospaced).weight(.semibold) : .footnote.weight(.semibold))
        }
        .padding(.vertical, 9)
    }
}
