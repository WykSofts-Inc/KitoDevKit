//
//  SignatureSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoSignature

// MARK: - Sample data

private enum SignatureData {
    /// A cursive-looking signature: a looping name, an underline flourish and a dot.
    static let saved: KitoSignatureData = {
        var strokes: [KitoSignatureStroke] = []
        strokes.append(KitoSignatureStroke(points: loops(), ink: .automatic))
        strokes.append(KitoSignatureStroke(points: flourish(start: 2.1), ink: .automatic))
        strokes.append(KitoSignatureStroke(points: [KitoSignaturePoint(x: 128, y: 34, t: 2.9)], ink: .automatic))
        return KitoSignatureData(strokes: strokes, canvasSize: CGSize(width: 320, height: 150))
    }()

    static let captured = KitoCapturedSignature(content: .drawn(saved), signerName: "Wycliff Njenga",
                                                consent: "I agree this is my signature")

    private static func loops() -> [KitoSignaturePoint] {
        (0..<150).map { index in
            let t = Double(index) * 0.1
            let x = 24 + 15 * t + 11 * cos(t * 1.7)
            let y = 78 - 26 * sin(t * 1.7) * envelope(t) - 6 * sin(t * 0.45)
            let speed = 0.011 + 0.006 * (1 + sin(t * 1.7))
            return KitoSignaturePoint(x: x, y: y, t: Double(index) * speed)
        }
    }

    private static func flourish(start: Double) -> [KitoSignaturePoint] {
        (0..<60).map { index in
            let u = Double(index) / 59
            let x = 40 + 230 * u
            let y = 112 + 7 * sin(u * .pi * 2) - 10 * u * u
            return KitoSignaturePoint(x: x, y: y, t: start + u * 0.45)
        }
    }

    private static func envelope(_ t: Double) -> Double {
        0.55 + 0.45 * abs(sin(t * 0.33))
    }

    /// A parcel on a doorstep, drawn in code so the sample has no assets.
    static let parcelPhoto: UIImage = {
        let size = CGSize(width: 1200, height: 900)
        return UIGraphicsImageRenderer(size: size).image { context in
            let cg = context.cgContext
            let floor = [UIColor(red: 0.78, green: 0.74, blue: 0.68, alpha: 1).cgColor,
                         UIColor(red: 0.55, green: 0.51, blue: 0.46, alpha: 1).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: floor, locations: [0, 1]) {
                cg.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }
            UIColor(red: 0.42, green: 0.31, blue: 0.22, alpha: 1).setFill()
            cg.fill(CGRect(x: 0, y: 0, width: size.width, height: 260))
            UIColor.black.withAlphaComponent(0.18).setFill()
            cg.fillEllipse(in: CGRect(x: 300, y: 690, width: 640, height: 90))
            drawBox(in: cg)
        }
    }()

    private static func drawBox(in cg: CGContext) {
        let front = UIBezierPath()
        front.move(to: CGPoint(x: 330, y: 420))
        front.addLine(to: CGPoint(x: 700, y: 470))
        front.addLine(to: CGPoint(x: 700, y: 740))
        front.addLine(to: CGPoint(x: 330, y: 690))
        front.close()
        UIColor(red: 0.80, green: 0.62, blue: 0.40, alpha: 1).setFill()
        front.fill()
        let side = UIBezierPath()
        side.move(to: CGPoint(x: 700, y: 470))
        side.addLine(to: CGPoint(x: 910, y: 400))
        side.addLine(to: CGPoint(x: 910, y: 660))
        side.addLine(to: CGPoint(x: 700, y: 740))
        side.close()
        UIColor(red: 0.69, green: 0.52, blue: 0.33, alpha: 1).setFill()
        side.fill()
        let top = UIBezierPath()
        top.move(to: CGPoint(x: 330, y: 420))
        top.addLine(to: CGPoint(x: 560, y: 360))
        top.addLine(to: CGPoint(x: 910, y: 400))
        top.addLine(to: CGPoint(x: 700, y: 470))
        top.close()
        UIColor(red: 0.88, green: 0.72, blue: 0.50, alpha: 1).setFill()
        top.fill()
        let tape = UIBezierPath()
        tape.move(to: CGPoint(x: 430, y: 395))
        tape.addLine(to: CGPoint(x: 480, y: 382))
        tape.addLine(to: CGPoint(x: 805, y: 425))
        tape.addLine(to: CGPoint(x: 760, y: 438))
        tape.close()
        UIColor(red: 0.93, green: 0.86, blue: 0.70, alpha: 1).setFill()
        tape.fill()
        let label = UIBezierPath(rect: CGRect(x: 400, y: 520, width: 170, height: 100))
        UIColor.white.setFill()
        label.fill()
        UIColor.black.withAlphaComponent(0.55).setFill()
        for row in 0..<4 {
            cg.fill(CGRect(x: 415, y: 538 + row * 20, width: row == 0 ? 110 : 140, height: 7))
        }
        UIColor(red: 0.45, green: 0.30, blue: 0.18, alpha: 0.7).setStroke()
        let dent = UIBezierPath()
        dent.move(to: CGPoint(x: 760, y: 560))
        dent.addQuadCurve(to: CGPoint(x: 850, y: 600), controlPoint: CGPoint(x: 800, y: 540))
        dent.lineWidth = 6
        dent.stroke()
    }
}

/// A card that frames each sample.
private struct SignatureCard<Content: View>: View {
    var title: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary).textCase(.uppercase)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}

// MARK: - Pad samples

private struct SignaturePadSample: View {
    @State private var model = KitoSignatureModel()

    var body: some View {
        SignatureCard {
            KitoSignaturePad(model: model)
            Text(model.isEmpty ? "Try a fast flick, then a slow curve." : "\(model.strokes.count) strokes · \(Int(model.data.inkLength)) pt of ink")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
    }
}

private struct SignatureCaptionSample: View {
    @State private var model = KitoSignatureModel()

    var body: some View {
        SignatureCard {
            KitoSignaturePad(model: model, caption: KitoSignatureCaption(signerName: "Wycliff Njenga"), tint: .indigo)
        }
    }
}

private struct SignaturePensSample: View {
    @State private var model = KitoSignatureModel(ink: .royalBlue)
    @State private var pen = "Fountain"

    private let pens: [(String, KitoPenStyle)] = [("Fountain", .fountain), ("Ballpoint", .ballpoint), ("Fineliner", .fineliner)]

    var body: some View {
        SignatureCard {
            Picker("Pen", selection: $pen) {
                ForEach(pens, id: \.0) { Text($0.0).tag($0.0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: pen) { _, name in
                model.pen = pens.first { $0.0 == name }?.1 ?? .fountain
            }
            KitoSignaturePad(model: model, inks: [.automatic, .royalBlue, .navy, .burgundy, .forest])
            Text("Each stroke keeps the pen and ink it was drawn with.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SignatureValidationSample: View {
    @State private var model = KitoSignatureModel()
    @State private var saved = false

    var body: some View {
        SignatureCard {
            KitoSignaturePad(model: model, showsToolbar: false, height: 170)
            HStack(spacing: 8) {
                Image(systemName: model.isValid ? "checkmark.circle.fill" : "info.circle")
                    .foregroundStyle(model.isValid ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
                Text(model.validation.message ?? "Looks like a signature.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Clear") { model.clear(); saved = false }
                    .font(.footnote.weight(.semibold))
                    .disabled(model.isEmpty)
            }
            Button { saved = true } label: {
                Label(saved ? "Saved" : "Save signature", systemImage: saved ? "checkmark" : "tray.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(!model.isValid)
            .opacity(model.isValid ? 1 : 0.4)
        }
        .animation(.snappy, value: model.isValid)
    }
}

private struct SignatureReplaySample: View {
    @State private var run = 0

    var body: some View {
        SignatureCard {
            KitoSignatureView(data: SignatureData.saved, replay: true)
                .id(run)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.systemBackground)))
            HStack {
                Text("\(SignatureData.saved.pointCount) points · \(SignatureData.saved.replayDuration.formatted(.number.precision(.fractionLength(1)))) s")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Button { run += 1 } label: { Label("Replay", systemImage: "play.fill") }
                    .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
    }
}

// MARK: - Typed samples

private struct SignatureTypedSample: View {
    @State private var value = KitoTypedSignatureValue(name: "Wycliff Njenga", style: .script)

    var body: some View {
        SignatureCard {
            KitoTypedSignature(value: $value, caption: KitoSignatureCaption(signerName: value.name))
        }
    }
}

private struct SignatureStylesSample: View {
    var body: some View {
        SignatureCard {
            ForEach(KitoTypedSignatureStyle.allCases) { style in
                HStack(spacing: 14) {
                    Text(style.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 64, alignment: .leading)
                    KitoSignatureView(typed: KitoTypedSignatureValue(name: "Amina Wanjiru", style: style, ink: .navy))
                        .frame(height: 40)
                }
                if style != KitoTypedSignatureStyle.allCases.last { Divider() }
            }
        }
    }
}

private struct SignatureAccessibleSample: View {
    @State private var model = KitoSignatureModel()
    @State private var typed = KitoTypedSignatureValue(name: "Grace Achieng")
    @State private var typing = false

    var body: some View {
        SignatureCard {
            Toggle("Sign by typing", isOn: $typing.animation(.snappy))
                .font(.subheadline.weight(.semibold))
            if typing {
                KitoTypedSignature(value: $typed, styles: [.script, .classic, .rounded], inks: [])
                    .transition(.opacity)
            } else {
                KitoSignaturePad(model: model, onTypeInstead: { typing = true })
                    .transition(.opacity)
            }
            Label("With VoiceOver on, the pad shows “Type your name instead” and the sheet opens on Type.",
                  systemImage: "accessibility")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Sheet and form screens

private struct SignatureDeliveryScreen: View {
    @State private var signing = false
    @State private var proof: KitoCapturedSignature?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SignatureCard(title: "Arriving now") {
                        HStack(spacing: 12) {
                            Image(systemName: "shippingbox.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.orange.gradient))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Order #KE-2291").font(.headline)
                                Text("3 items · Kilimani, Nairobi").font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        Label("Courier: Brian O. · Plate KDA 482P", systemImage: "person.crop.circle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    if let proof {
                        SignatureCard(title: "Proof of delivery") {
                            KitoSignatureView(proof, replay: true)
                                .frame(height: 80)
                            Text(proof.caption.text).font(.footnote).foregroundStyle(.secondary)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(16)
            }
            .safeAreaInset(edge: .bottom) {
                Button { signing = true } label: {
                    Label(proof == nil ? "Sign for parcel" : "Sign again", systemImage: "signature")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
                .padding(16)
                .background(.bar)
            }
            .navigationTitle("Delivery")
            .navigationBarTitleDisplayMode(.inline)
        }
        .kitoSignatureSheet(isPresented: $signing, title: "Sign for your parcel",
                            message: "Order #KE-2291 · 3 items", signerName: "Wycliff Njenga", tint: .orange) { signature in
            withAnimation(.snappy) { proof = signature }
        }
    }
}

private struct SignatureLeaseScreen: View {
    @State private var tenant: KitoCapturedSignature?
    @State private var landlord: KitoCapturedSignature? = SignatureData.captured

    private let terms = [
        ("Property", "Flat 4B, Riverside Drive, Westlands"),
        ("Term", "12 months from 1 Oct 2026"),
        ("Rent", "KSh 85,000 per month, due on the 1st"),
        ("Deposit", "Two months' rent, refundable"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Agreement") {
                    ForEach(terms, id: \.0) { term in
                        LabeledContent(term.0, value: term.1)
                    }
                }
                Section {
                    KitoSignatureField("Tenant", signature: $tenant, signerName: "Wycliff Njenga",
                                       sheetTitle: "Sign the lease", sheetMessage: "Flat 4B · 12 months",
                                       consentText: "I have read and agree to the terms of this lease",
                                       isRequired: true, tint: .teal)
                    KitoSignatureField("Landlord", signature: $landlord, signerName: "Wycliff Njenga",
                                       sheetTitle: "Countersign the lease", tint: .teal)
                }
                .listRowSeparator(.hidden)
                Section {
                    Button { } label: { Text("Send signed lease").frame(maxWidth: .infinity) }
                        .buttonStyle(GalleryPrimaryButtonStyle())
                        .disabled(tenant == nil || landlord == nil)
                        .opacity(tenant == nil || landlord == nil ? 0.4 : 1)
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Lease")
        }
    }
}

private struct SignatureConsentScreen: View {
    @State private var trip = true
    @State private var photos = false
    @State private var guardian: KitoCapturedSignature?
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Pupil", value: "Zawadi Mwangi · Grade 6")
                    LabeledContent("Trip", value: "Nairobi National Museum")
                    LabeledContent("Date", value: "Fri 9 Oct 2026")
                }
                Section("Permissions") {
                    Toggle("Attend the trip", isOn: $trip)
                    Toggle("Photos in the newsletter", isOn: $photos)
                }
                Section {
                    KitoSignatureField("Parent or guardian", signature: $guardian, signerName: "Amina Wanjiru",
                                       sheetTitle: "Sign the consent form",
                                       sheetMessage: "Nairobi National Museum · 9 Oct",
                                       consentText: "I'm Zawadi's parent or guardian and I give my consent",
                                       isRequired: true, tint: .green)
                }
                Section {
                    Button { withAnimation(.snappy) { submitted = true } } label: {
                        Label(submitted ? "Sent to school" : "Submit form", systemImage: submitted ? "checkmark" : "paperplane")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(GalleryPrimaryButtonStyle())
                    .disabled(guardian == nil)
                    .opacity(guardian == nil ? 0.4 : 1)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Consent form")
        }
    }
}

private struct SignatureFieldStatesSample: View {
    @State private var empty: KitoCapturedSignature?
    @State private var signed: KitoCapturedSignature? = SignatureData.captured
    @State private var typed: KitoCapturedSignature? = .typed(KitoTypedSignatureValue(name: "Grace Achieng", style: .casual, ink: .navy))

    var body: some View {
        SignatureCard {
            KitoSignatureField("Signature", signature: $empty, signerName: "Wycliff Njenga", isRequired: true)
            KitoSignatureField("Drawn", signature: $signed, signerName: "Wycliff Njenga")
            KitoSignatureField("Typed", signature: $typed, signerName: "Grace Achieng")
        }
    }
}

private struct SignatureDrawOnlySample: View {
    @State private var signing = false
    @State private var result: KitoCapturedSignature?

    var body: some View {
        SignatureCard {
            if let result {
                KitoSignatureView(result, replay: true).frame(height: 70)
            }
            Button { signing = true } label: {
                Label("Initial this page", systemImage: "pencil.and.scribble").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .kitoSignatureSheet(isPresented: $signing, title: "Your initials", consentText: nil, modes: [.draw]) {
            result = $0
        }
    }
}

// MARK: - Export samples

private struct SignatureExportSample: View {
    @State private var format = "PNG"
    private let signature = SignatureData.saved

    var body: some View {
        SignatureCard {
            Picker("Format", selection: $format) {
                ForEach(["PNG", "On white", "PDF", "SVG"], id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.segmented)
            preview
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            Text(detail).font(.footnote.monospacedDigit()).foregroundStyle(.secondary)
        }
        .animation(.snappy, value: format)
    }

    @ViewBuilder
    private var preview: some View {
        switch format {
        case "SVG":
            ScrollView {
                Text(String((signature.svg(precision: 1) ?? "").prefix(700)) + "…")
                    .font(.system(size: 10, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            }
            .background(Color(.systemBackground))
        case "On white":
            if let image = signature.image(size: CGSize(width: 480, height: 200), background: .white) {
                Image(uiImage: image).resizable().scaledToFit()
            }
        default:
            ZStack {
                SignatureCheckerboard()
                if let image = signature.image(size: CGSize(width: 480, height: 200)) {
                    Image(uiImage: image).resizable().scaledToFit()
                }
            }
        }
    }

    private var detail: String {
        switch format {
        case "SVG": return "\(signature.svg()?.count ?? 0) characters · one filled <path> per stroke"
        case "PDF": return "\(signature.pdfData()?.count ?? 0) bytes · vector, scales without blur"
        case "On white": return "\(signature.pngData(background: .white)?.count ?? 0) bytes · ready to print"
        default: return "\(signature.pngData()?.count ?? 0) bytes · transparent, lays over a document"
        }
    }
}

private struct SignatureCheckerboard: View {
    var body: some View {
        Canvas { context, size in
            let cell: CGFloat = 10
            for row in 0..<Int(size.height / cell) + 1 {
                for column in 0..<Int(size.width / cell) + 1 where (row + column).isMultiple(of: 2) {
                    let rect = CGRect(x: CGFloat(column) * cell, y: CGFloat(row) * cell, width: cell, height: cell)
                    context.fill(Path(rect), with: .color(.gray.opacity(0.18)))
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

private struct SignatureStoreSample: View {
    private let signature = SignatureData.saved

    var body: some View {
        SignatureCard {
            HStack(alignment: .bottom, spacing: 12) {
                ForEach([36.0, 60, 96], id: \.self) { height in
                    VStack(spacing: 6) {
                        KitoSignatureView(data: signature)
                            .frame(width: height * 2.2, height: height)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
                        Text("\(Int(height)) pt").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            Text(summary).font(.footnote.monospacedDigit()).foregroundStyle(.secondary)
        }
    }

    private var summary: String {
        let bytes = (try? signature.jsonData().count) ?? 0
        let box = signature.normalized().boundingBox
        return "JSON \(bytes) bytes · \(signature.strokes.count) strokes · normalised \(Double(box.width).formatted(.number.precision(.fractionLength(2)))) × \(Double(box.height).formatted(.number.precision(.fractionLength(2))))"
    }
}

// MARK: - Drawing samples

private struct SignaturePencilSample: View {
    @State private var controller = KitoDrawingController(background: .grid)
    @State private var exported: UIImage?

    var body: some View {
        SignatureCard {
            KitoDrawingCanvas(controller: controller)
                .frame(height: 380)
            HStack {
                if let exported {
                    Image(uiImage: exported).resizable().scaledToFit().frame(height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Spacer()
                Button { exported = controller.image(scale: 1) } label: { Label("Export", systemImage: "square.and.arrow.up") }
                    .buttonStyle(GalleryPrimaryButtonStyle())
                    .disabled(controller.isEmpty)
            }
        }
    }
}

private struct SignaturePaperSample: View {
    @State private var paper: KitoCanvasBackground = .lined

    var body: some View {
        SignatureCard {
            Picker("Paper", selection: $paper) {
                ForEach(KitoCanvasBackground.allCases) { Label($0.title, systemImage: $0.systemImage).tag($0) }
            }
            .pickerStyle(.segmented)
            KitoCanvasBackgroundView(paper)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(0.1)))
                .animation(.easeInOut, value: paper)
        }
    }
}

private struct SignatureSketchSample: View {
    @State private var model = KitoSignatureModel(pen: .ballpoint, validator: .lenient)

    var body: some View {
        SignatureCard {
            KitoSketchCanvas(model: model, background: .dotted, tint: .pink)
                .frame(height: 380)
            Text("No PencilKit — the same pen engine as the signature pad, with a stroke eraser.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SignatureAnnotateScreen: View {
    @State private var markup = KitoAnnotationModel(image: SignatureData.parcelPhoto)
    @State private var attached: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                KitoAnnotationView(model: markup, tint: .red)
                if let attached {
                    HStack(spacing: 10) {
                        Image(uiImage: attached).resizable().scaledToFill().frame(width: 54, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text("Attached to damage report").font(.footnote.weight(.semibold))
                        Spacer()
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                Button { withAnimation(.snappy) { attached = markup.flattenedImage() } } label: {
                    Label("Attach to report", systemImage: "paperclip").frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
                .disabled(markup.isEmpty)
                .opacity(markup.isEmpty ? 0.4 : 1)
            }
            .padding(16)
            .navigationTitle("Report damage")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Gallery

enum SignatureSamples {
    private static let pad = KitSection("Signature pad", symbol: "signature", [
        KitSample("Pen-like pad", "Thin when fast, thick when slow, smoothed into curves.", code: """
        @State private var signature = KitoSignatureModel()

        KitoSignaturePad(model: signature)
        """) { SignaturePadSample() },
        KitSample("Signed-by caption", "“Signed by Wycliff N · 24 Sep 2026” under the ink.", code: """
        KitoSignaturePad(model: signature,
                         caption: KitoSignatureCaption(signerName: "Wycliff Njenga"),
                         tint: .indigo)
        """) { SignatureCaptionSample() },
        KitSample("Pens and inks", "Fountain, ballpoint or fineliner, in legal-document inks.", code: """
        let signature = KitoSignatureModel(ink: .royalBlue)
        signature.pen = .ballpoint            // .fountain, .fineliner, .marker

        KitoSignaturePad(model: signature, inks: [.automatic, .royalBlue, .navy, .burgundy])
        """) { SignaturePensSample() },
        KitSample("Too short to count", "Validation for dots, ticks and tiny scribbles.", code: """
        KitoSignaturePad(model: signature, showsToolbar: false)
        Text(signature.validation.message ?? "Looks like a signature.")
        Button("Save") { save(signature.data) }.disabled(!signature.isValid)
        """) { SignatureValidationSample() },
        KitSample("Replay a saved signature", "Writes itself stroke by stroke at the speed it was signed.", code: """
        KitoSignatureView(data: saved, replay: true)
            .frame(height: 120)
        """) { SignatureReplaySample() },
    ])

    private static let typed = KitSection("Typed and accessible", symbol: "character.cursor.ibeam", [
        KitSample("Type your name", "Pick a handwriting style; it exports like a drawn one.", code: """
        @State private var typed = KitoTypedSignatureValue(name: "Wycliff Njenga", style: .script)

        KitoTypedSignature(value: $typed)
        """) { SignatureTypedSample() },
        KitSample("Six styles", "Script, Casual, Elegant, Classic, Modern and Rounded.", code: """
        ForEach(KitoTypedSignatureStyle.allCases) { style in
            KitoSignatureView(typed: KitoTypedSignatureValue(name: "Amina Wanjiru", style: style))
        }
        """) { SignatureStylesSample() },
        KitSample("VoiceOver alternative", "Typing instead of drawing, one tap away.", code: """
        KitoSignaturePad(model: signature, onTypeInstead: { mode = .type })
        // With VoiceOver on, the pad shows “Type your name instead”
        // and KitoSignatureSheet opens on the Type tab.
        """) { SignatureAccessibleSample() },
    ])

    private static let flows = KitSection("Sheets and forms", symbol: "doc.text", [
        KitSample("Delivery sign-off", "Courier hands over; the customer signs in a sheet.", code: """
        Button("Sign for parcel") { signing = true }
            .kitoSignatureSheet(isPresented: $signing, title: "Sign for your parcel",
                                message: "Order #KE-2291 · 3 items",
                                signerName: "Wycliff Njenga", tint: .orange) { signature in
                proof = signature
            }
        """) { ModalStage { SignatureDeliveryScreen() } },
        KitSample("Lease agreement", "Tenant and landlord fields with a custom consent line.", code: """
        KitoSignatureField("Tenant", signature: $tenant, signerName: "Wycliff Njenga",
                           sheetTitle: "Sign the lease",
                           consentText: "I have read and agree to the terms of this lease",
                           isRequired: true)
        """) { ModalStage { SignatureLeaseScreen() } },
        KitSample("School consent form", "A guardian signs before the form can be sent.", code: """
        KitoSignatureField("Parent or guardian", signature: $guardian,
                           signerName: "Amina Wanjiru", sheetTitle: "Sign the consent form",
                           consentText: "I'm Zawadi's parent or guardian and I give my consent",
                           isRequired: true, tint: .green)
        Button("Submit form") { submit() }.disabled(guardian == nil)
        """) { ModalStage { SignatureConsentScreen() } },
        KitSample("Field states", "Empty, drawn and typed — tap any to re-sign.", code: """
        @State private var signature: KitoCapturedSignature?

        KitoSignatureField("Signature", signature: $signature, signerName: "Wycliff Njenga")
        """) { SignatureFieldStatesSample() },
        KitSample("Draw only, no consent", "Initials: one tab, no checkbox.", code: """
        .kitoSignatureSheet(isPresented: $signing, title: "Your initials",
                            consentText: nil, modes: [.draw]) { initials = $0 }
        """) { SignatureDrawOnlySample() },
    ])

    private static let export = KitSection("Store and export", symbol: "square.and.arrow.up", [
        KitSample("PNG, PDF and SVG", "Transparent, on white, vector PDF or an SVG path.", code: """
        signature.pngData()                                  // transparent, cropped to the ink
        signature.image(size: CGSize(width: 480, height: 200), background: .white)
        signature.pdfData()
        signature.svg()
        """) { SignatureExportSample() },
        KitSample("Store and re-render", "Codable strokes that redraw crisply at any size.", code: """
        let json = try signature.data.jsonData()
        let saved = try KitoSignatureData(jsonData: json)

        KitoSignatureView(data: saved).frame(height: 36)
        saved.normalized()                                    // longer side 1
        saved.fitted(in: rect, padding: 8)
        """) { SignatureStoreSample() },
    ])

    private static let drawing = KitSection("Drawing and markup", symbol: "pencil.and.scribble", [
        KitSample("PencilKit canvas", "Tools, colours, undo/redo and Apple's tool picker.", code: """
        @State private var sketch = KitoDrawingController(background: .grid)

        KitoDrawingCanvas(controller: sketch)
        let image = sketch.image()
        """) { SignaturePencilSample() },
        KitSample("Paper styles", "Blank, grid, lined with a margin, or dotted.", code: """
        KitoCanvasBackgroundView(.lined)
        KitoDrawingController(background: .dotted)
        """) { SignaturePaperSample() },
        KitSample("Pure SwiftUI sketch", "No PencilKit: pen, marker and a stroke eraser.", code: """
        @State private var notes = KitoSignatureModel(pen: .ballpoint, validator: .lenient)

        KitoSketchCanvas(model: notes, background: .dotted)
        let image = notes.canvasImage(background: .dotted)
        """) { SignatureSketchSample() },
        KitSample("Annotate a parcel photo", "Circle the dent, add a note, attach the flattened photo.", code: """
        @State private var markup = KitoAnnotationModel(image: parcelPhoto)

        KitoAnnotationView(model: markup)        // pen, highlighter, arrow, text
        let proof = markup.flattenedImage()      // full resolution
        """) { ModalStage { SignatureAnnotateScreen() } },
    ])

    static let sections: [KitSection] = [pad, typed, flows, export, drawing]
}

struct SignatureGallery: View {
    static var count: Int { KitGallery.count(SignatureSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Signature & Drawing",
            sections: SignatureSamples.sections,
            footnote: "Requires `import KitoSignature`.",
            searchHint: "Try “delivery”, “lease”, “typed”, “replay”, “SVG” or “annotate”."
        )
    }
}
