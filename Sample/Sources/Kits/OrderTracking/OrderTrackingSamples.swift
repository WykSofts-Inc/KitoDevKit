//
//  OrderTrackingSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoOrderTracking

// MARK: - Sample data

private enum OrdData {
    static let merchant = "Mama Akinyi's Kitchen"
    static let courier = KitoCourier(name: "Amara Mwangi", phone: "+254712345678", vehicle: .motorbike, plate: "KMFB 214C", rating: 4.9, deliveries: 1_284)

    static func update(for stage: KitoOrderStage, eta: Date = Date().addingTimeInterval(14 * 60)) -> KitoOrderUpdate {
        switch stage {
        case .placed: return KitoOrderUpdate(stage: .placed, detail: "We've sent your order to the kitchen.")
        case .confirmed: return KitoOrderUpdate(stage: .confirmed, detail: "\(merchant) accepted your order.", estimatedArrival: eta.addingTimeInterval(10 * 60))
        case .preparing: return KitoOrderUpdate(stage: .preparing, detail: "Pilau and chapati on the fire.", estimatedArrival: eta.addingTimeInterval(6 * 60))
        case .outForDelivery: return KitoOrderUpdate(stage: .outForDelivery, detail: "Amara is on Argwings Kodhek Rd.", estimatedArrival: eta, courierName: "Amara M.")
        case .delivered: return KitoOrderUpdate(stage: .delivered, detail: "Delivered to Wycliff N. Enjoy!", courierName: "Amara M.")
        case .cancelled: return KitoOrderUpdate(stage: .cancelled, detail: "Refund of KES 1,450 is on its way to M-Pesa.")
        }
    }

    static let flow: [KitoOrderStage] = [.placed, .confirmed, .preparing, .outForDelivery, .delivered]
    static let everyStage: [KitoOrderStage] = flow + [.cancelled]

    static func history(_ stage: KitoOrderStage) -> [KitoOrderEvent] {
        KitoOrderEvent.sampleHistory(upTo: stage, merchant: merchant, courier: "Amara")
    }
}

/// A row of stage chips to jump the sample to any stage.
private struct OrdStagePicker: View {
    @Binding var stage: KitoOrderStage
    var stages: [KitoOrderStage] = OrdData.everyStage

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(stages, id: \.self) { option in
                    Button(option.defaultLabel) { withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { stage = option } }
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .foregroundStyle(option == stage ? Color(.systemBackground) : .primary)
                        .background(option == stage ? Color.primary : Color.primary.opacity(0.07), in: Capsule())
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(option == stage ? .isSelected : [])
                }
            }
        }
    }
}

private struct OrdCard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var body: some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

/// A stylised street map with the courier's route.
private struct OrdMapBackdrop: View {
    @Environment(\.colorScheme) private var scheme
    var progress: CGFloat = 0.6

    var body: some View {
        Canvas { context, size in
            let land = scheme == .dark ? Color(white: 0.14) : Color(red: 0.93, green: 0.94, blue: 0.9)
            let road = scheme == .dark ? Color(white: 0.24) : Color.white
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(land))
            var park = Path(roundedRect: CGRect(x: size.width * 0.58, y: size.height * 0.12, width: size.width * 0.3, height: size.height * 0.28), cornerRadius: 18)
            context.fill(park, with: .color(.green.opacity(scheme == .dark ? 0.22 : 0.18)))
            park = Path(roundedRect: CGRect(x: size.width * 0.06, y: size.height * 0.62, width: size.width * 0.22, height: size.height * 0.2), cornerRadius: 14)
            context.fill(park, with: .color(.blue.opacity(0.14)))
            for index in 0..<6 {
                var h = Path()
                let y = size.height * (0.1 + Double(index) * 0.17)
                h.move(to: CGPoint(x: 0, y: y))
                h.addLine(to: CGPoint(x: size.width, y: y + size.height * 0.04))
                context.stroke(h, with: .color(road), lineWidth: index == 2 ? 12 : 7)
                var v = Path()
                let x = size.width * (0.12 + Double(index) * 0.18)
                v.move(to: CGPoint(x: x, y: 0))
                v.addLine(to: CGPoint(x: x - size.width * 0.05, y: size.height))
                context.stroke(v, with: .color(road), lineWidth: index == 3 ? 12 : 7)
            }
        }
        .overlay {
            GeometryReader { proxy in
                let size = proxy.size
                let route = Path { path in
                    path.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.8))
                    path.addCurve(to: CGPoint(x: size.width * 0.8, y: size.height * 0.22), control1: CGPoint(x: size.width * 0.3, y: size.height * 0.3), control2: CGPoint(x: size.width * 0.6, y: size.height * 0.7))
                }
                ZStack {
                    route.stroke(Color.primary.opacity(0.18), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    route.trim(from: 0, to: progress).stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    pin("house.fill", .blue).position(x: size.width * 0.8, y: size.height * 0.22)
                    pin("fork.knife", .orange).position(x: size.width * 0.18, y: size.height * 0.8)
                    if let point = route.trimmedPath(from: 0, to: max(progress, 0.001)).currentPoint {
                        Image(systemName: "scooter")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.primary, in: Circle())
                            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 3))
                            .shadow(radius: 6)
                            .position(point)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func pin(_ symbol: String, _ color: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(color, in: Circle())
            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 3))
    }
}

// MARK: - Live tracking

/// Every stage one tap away, with the Live Activity following along on the Lock Screen and in
/// the Dynamic Island (via the sample's widget extension).
private struct OrdLiveActivitySample: View {
    @State private var viewModel = KitoOrderTrackingViewModel(
        orderID: "gallery-manual",
        merchantName: OrdData.merchant,
        initial: OrdData.update(for: .placed),
        refreshInterval: 999_999,
        fetchUpdate: { OrdData.update(for: .placed) }
    )

    var body: some View {
        VStack(spacing: 12) {
            OrdStagePicker(stage: Binding(get: { viewModel.update.stage }, set: { viewModel.setUpdate(OrdData.update(for: $0)) }))
            KitoOrderTrackingScreen(viewModel: viewModel, startsTrackingOnAppear: false)
                .frame(height: 460)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            Label(viewModel.isLiveActivityActive ? "Live Activity running: lock the phone to see it" : "Live Activities are off for this app, the screen still updates", systemImage: "dot.radiowaves.left.and.right")
                .font(.caption).foregroundStyle(.secondary)
        }
        .onAppear { viewModel.startLiveActivityOnly() }
        .onDisappear { viewModel.stopTracking() }
    }
}

private struct OrdAutoRefreshSample: View {
    @State private var viewModel: KitoOrderTrackingViewModel

    init() {
        let simulator = KitoOrderTrackingSimulator(merchantName: OrdData.merchant, courierName: "Amara M.", stageDuration: 4)
        _viewModel = State(initialValue: KitoOrderTrackingViewModel(
            orderID: "gallery-auto",
            merchantName: simulator.merchantName,
            initial: simulator.script[0],
            refreshInterval: simulator.stageDuration,
            fetchUpdate: simulator.nextUpdate
        ))
    }

    var body: some View {
        VStack(spacing: 10) {
            KitoOrderTrackingScreen(viewModel: viewModel)
                .frame(height: 460)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            Label("Advances every four seconds from KitoOrderTrackingSimulator", systemImage: "timer").font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct OrdDeliveryScreenSample: View {
    @State private var stage: KitoOrderStage = .outForDelivery
    private let eta = Date().addingTimeInterval(12 * 60)

    var body: some View {
        ZStack(alignment: .bottom) {
            OrdMapBackdrop(progress: stage == .outForDelivery ? 0.62 : (stage == .delivered ? 1 : 0.02))
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1), value: stage)
            VStack(alignment: .leading, spacing: 16) {
                Capsule().fill(Color.primary.opacity(0.2)).frame(width: 40, height: 5).frame(maxWidth: .infinity)
                HStack(alignment: .top) {
                    if stage == .delivered {
                        Text("Delivered").font(.title2.weight(.heavy))
                    } else {
                        KitoETACountdown(eta: eta, style: .headline)
                    }
                    Spacer()
                    KitoOrderStatusChip(stage: stage)
                }
                KitoOrderProgressTrack(stage: stage, vehicle: .motorbike)
                KitoCourierCard(courier: OrdData.courier, style: .compact, onChat: {})
                OrdStagePicker(stage: $stage, stages: [.preparing, .outForDelivery, .delivered])
            }
            .padding(20)
            .background(.regularMaterial, in: UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30, style: .continuous))
        }
    }
}

// MARK: - Timelines

private struct OrdLayoutSample: View {
    let layout: KitoOrderTimelineLayout
    var accent: Color? = nil
    @State private var stage: KitoOrderStage = .preparing

    var body: some View {
        VStack(spacing: 16) {
            OrdCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Order #KE-2048").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                            Text(OrdData.merchant).font(.headline)
                        }
                        Spacer()
                        KitoOrderStatusChip(stage: stage)
                    }
                    KitoOrderStageTimelineView(currentStage: stage, style: KitoOrderTrackingStyle(accentColor: accent, timelineLayout: layout))
                }
            }
            OrdStagePicker(stage: $stage)
        }
    }
}

private struct OrdEventTimelineSample: View {
    @State private var stage: KitoOrderStage = .outForDelivery

    var body: some View {
        VStack(spacing: 16) {
            OrdCard {
                KitoOrderEventTimeline(events: OrdData.history(stage), currentStage: stage)
            }
            OrdStagePicker(stage: $stage)
        }
    }
}

private struct OrdProgressTrackSample: View {
    @State private var stage: KitoOrderStage = .preparing
    @State private var vehicle: KitoCourierVehicle = .motorbike

    var body: some View {
        VStack(spacing: 16) {
            OrdCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(stage.defaultLabel).font(.title3.weight(.heavy)).contentTransition(.opacity)
                        Spacer()
                        Image(systemName: vehicle.systemImage).foregroundStyle(.secondary)
                    }
                    KitoOrderProgressTrack(stage: stage, vehicle: vehicle)
                }
            }
            OrdStagePicker(stage: $stage)
            Picker("Vehicle", selection: $vehicle) {
                ForEach(KitoCourierVehicle.allCases, id: \.self) { Image(systemName: $0.systemImage).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct OrdChipsSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(KitoOrderChipStyle.allCases, id: \.self) { style in
                VStack(alignment: .leading, spacing: 8) {
                    Text(style.rawValue.capitalized).font(.caption.weight(.heavy)).foregroundStyle(.secondary)
                    FlowChips(style: style)
                }
            }
        }
    }

    private struct FlowChips: View {
        let style: KitoOrderChipStyle
        var body: some View {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8, alignment: .leading)], alignment: .leading, spacing: 8) {
                ForEach(OrdData.everyStage, id: \.self) { KitoOrderStatusChip(stage: $0, style: style) }
            }
        }
    }
}

private struct OrdHistoryListSample: View {
    private let orders: [(String, String, KitoOrderStage, String)] = [
        ("KE-2051", OrdData.merchant, .outForDelivery, "KES 1,450"), ("KE-2049", "Duka la Jirani", .preparing, "KES 3,210"),
        ("KE-2044", "Kahawa Corner", .delivered, "KES 640"), ("KE-2037", "Pharmacy Plus", .cancelled, "KES 980"),
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(orders, id: \.0) { order in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(order.1).font(.subheadline.weight(.bold))
                            Text("#\(order.0) · \(order.3)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                        }
                        Spacer()
                        KitoOrderStatusChip(stage: order.2)
                    }
                    if !order.2.isTerminal {
                        KitoOrderStageTimelineView(currentStage: order.2, style: KitoOrderTrackingStyle(timelineLayout: .compact))
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }
}

// MARK: - Courier & ETA

private struct OrdCourierSample: View {
    @State private var action: String?

    var body: some View {
        VStack(spacing: 12) {
            KitoCourierCard(courier: OrdData.courier, onCall: { action = "Calling Amara on +254 712 345 678…" }, onChat: { action = "Opening chat with Amara" })
            if let action {
                Text(action).font(.caption).foregroundStyle(.secondary).transition(.opacity)
            }
        }
        .animation(.easeOut, value: action)
    }
}

private struct OrdCourierMapSample: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            OrdMapBackdrop(progress: 0.55)
            KitoCourierCard(courier: KitoCourier(name: "Otieno Juma", phone: "+254733111222", vehicle: .car, plate: "KDA 482Q", rating: 4.8), style: .compact, onChat: {})
                .padding(12)
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct OrdETARingSample: View {
    private let start = Date().addingTimeInterval(-9 * 60)
    private let eta = Date().addingTimeInterval(13 * 60)

    var body: some View {
        VStack(spacing: 16) {
            KitoETACountdown(eta: eta, start: start, style: .ring)
            Text("Picked up 9 minutes ago; the ring fills as Amara gets closer.").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct OrdETAStylesSample: View {
    private let eta = Date().addingTimeInterval(7 * 60 + 25)

    var body: some View {
        VStack(spacing: 18) {
            OrdCard { KitoETACountdown(eta: eta, style: .digital).frame(maxWidth: .infinity) }
            OrdCard { KitoETACountdown(eta: eta, style: .headline) }
            HStack {
                Text("In a header").font(.subheadline.weight(.semibold))
                Spacer()
                KitoETACountdown(eta: eta, style: .pill)
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Delivered

private struct OrdProofSample: View {
    @State private var replay = 0

    var body: some View {
        VStack(spacing: 12) {
            KitoDeliveryProofView(proof: KitoDeliveryProof(recipientName: "Wycliff N", deliveredAt: Date().addingTimeInterval(-4 * 60), code: "4821", note: "Left with the askari at the gate."))
                .id(replay)
            Button { replay += 1 } label: { Label("Sign again", systemImage: "signature") }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct OrdSignSample: View {
    @State private var strokes: [[CGPoint]] = []
    @State private var confirmed = false

    var body: some View {
        VStack(spacing: 14) {
            if confirmed {
                KitoDeliveryProofView(proof: KitoDeliveryProof(recipientName: "Wycliff N", deliveredAt: Date(), signature: strokes, code: "7310"))
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                Button("Start over") { withAnimation(.spring) { strokes = []; confirmed = false } }
                    .buttonStyle(GalleryPrimaryButtonStyle())
            } else {
                Text("Recipient signature").font(.headline).frame(maxWidth: .infinity, alignment: .leading)
                KitoDeliverySignaturePad(strokes: $strokes).frame(height: 190)
                HStack {
                    Button("Clear") { strokes = [] }.buttonStyle(.bordered).tint(.primary).disabled(strokes.isEmpty)
                    Spacer()
                    Button { withAnimation(.spring) { confirmed = true } } label: { Label("Confirm delivery", systemImage: "checkmark") }
                        .buttonStyle(GalleryPrimaryButtonStyle())
                        .disabled(strokes.isEmpty)
                }
            }
        }
    }
}

private struct OrdTerminalSample: View {
    var body: some View {
        VStack(spacing: 12) {
            OrdCard {
                VStack(alignment: .leading, spacing: 8) {
                    KitoOrderStageTimelineView(currentStage: .delivered)
                    Text(OrdData.update(for: .delivered).detail ?? "").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            OrdCard {
                VStack(alignment: .leading, spacing: 8) {
                    KitoOrderStageTimelineView(currentStage: .cancelled)
                    Text(OrdData.update(for: .cancelled).detail ?? "").font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Live Activity previews

private struct OrdLockScreenPreviewSample: View {
    @State private var stage: KitoOrderStage = .outForDelivery

    var body: some View {
        VStack(spacing: 14) {
            KitoLiveActivityPreview(merchantName: OrdData.merchant, update: OrdData.update(for: stage), surface: .lockScreen)
            OrdStagePicker(stage: $stage, stages: OrdData.flow)
        }
    }
}

private struct OrdIslandPreviewSample: View {
    @State private var stage: KitoOrderStage = .outForDelivery

    var body: some View {
        VStack(spacing: 12) {
            ForEach([KitoLiveActivitySurface.islandCompact, .islandMinimal, .islandExpanded], id: \.self) { surface in
                VStack(alignment: .leading, spacing: 6) {
                    Text(surface.label).font(.caption.weight(.heavy)).foregroundStyle(.secondary)
                    KitoLiveActivityPreview(merchantName: OrdData.merchant, update: OrdData.update(for: stage), surface: surface, style: KitoOrderTrackingStyle(accentColor: .orange))
                }
            }
            OrdStagePicker(stage: $stage, stages: OrdData.flow)
        }
    }
}

private struct OrdBrandedStylesSample: View {
    @State private var choice = 0
    @State private var viewModel = KitoOrderTrackingViewModel(
        orderID: "gallery-styles",
        merchantName: OrdData.merchant,
        initial: OrdData.update(for: .outForDelivery),
        refreshInterval: 999_999,
        fetchUpdate: { OrdData.update(for: .outForDelivery) }
    )

    private let styles: [(String, KitoOrderTrackingStyle)] = [
        ("Rounded, orange", KitoOrderTrackingStyle(accentColor: .orange, headlineFont: .system(size: 22, weight: .heavy, design: .rounded), detailFont: .system(size: 14, weight: .medium), cornerRadius: 30)),
        ("Own words", KitoOrderTrackingStyle(accentColor: .purple, stageLabels: [.placed: "Order received", .confirmed: "Jikoni wameanza", .preparing: "Cooking now", .outForDelivery: "Rider en route", .delivered: "Karibu, enjoy!"], stageIcons: [.outForDelivery: "scooter"], timelineLayout: .stepper)),
        ("Quiet", KitoOrderTrackingStyle(accentColor: .teal, showsCourierRow: false, showsETA: false, timelineLayout: .horizontal)),
    ]

    var body: some View {
        VStack(spacing: 12) {
            Picker("Style", selection: $choice) {
                ForEach(styles.indices, id: \.self) { Text(styles[$0].0).tag($0) }
            }
            .pickerStyle(.segmented)
            KitoOrderTrackingScreen(viewModel: viewModel, style: styles[choice].1, startsTrackingOnAppear: false)
                .frame(height: 440)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .id(choice)
        }
    }
}

// MARK: - Catalog

enum OrderTrackingSamples {
    static let sections: [KitSection] = [live, timelines, courier, delivered, previews]

    static let live = KitSection("Live tracking", symbol: "dot.radiowaves.left.and.right", [
        KitSample("Live Activity, stage by stage", "Tap any stage; the screen, Lock Screen and Dynamic Island all follow.", code: """
        @State private var tracking = KitoOrderTrackingViewModel(orderID: "KE-2048", merchantName: "Mama Akinyi's Kitchen",
                                                                   initial: placed, refreshInterval: 15, fetchUpdate: api.latest)

        KitoOrderTrackingScreen(viewModel: tracking, startsTrackingOnAppear: false)
            .onAppear { tracking.startLiveActivityOnly() }
        …
        tracking.setUpdate(KitoOrderUpdate(stage: .outForDelivery, estimatedArrival: eta, courierName: "Amara M."))
        """) { OrdLiveActivitySample() },
        KitSample("Auto-refreshing simulator", "Walks every stage by itself, every four seconds.", code: """
        let simulator = KitoOrderTrackingSimulator(merchantName: "Mama Akinyi's Kitchen", stageDuration: 4)
        KitoOrderTrackingScreen(viewModel: KitoOrderTrackingViewModel(
            orderID: "demo", merchantName: simulator.merchantName, initial: simulator.script[0],
            refreshInterval: simulator.stageDuration, fetchUpdate: simulator.nextUpdate))
        """) { OrdAutoRefreshSample() },
        KitSample("Delivery screen", "Map, ETA, status chip, progress track and the courier in one sheet.", code: """
        ZStack(alignment: .bottom) {
            MapView(route: route)
            VStack(alignment: .leading, spacing: 16) {
                HStack { KitoETACountdown(eta: eta, style: .headline); Spacer(); KitoOrderStatusChip(stage: stage) }
                KitoOrderProgressTrack(stage: stage, vehicle: .motorbike)
                KitoCourierCard(courier: courier, style: .compact, onChat: openChat)
            }
            .background(.regularMaterial)
        }
        """) { ModalStage { OrdDeliveryScreenSample() } },
    ])

    static let timelines = KitSection("Timelines", symbol: "list.bullet.below.rectangle", [
        KitSample("Vertical timeline", "Connected stage icons down the side.", code: "KitoOrderStageTimelineView(currentStage: stage)") { OrdLayoutSample(layout: .vertical) },
        KitSample("Horizontal steps", "Left to right with labels below, for a card.", code: "KitoOrderStageTimelineView(currentStage: stage, style: KitoOrderTrackingStyle(timelineLayout: .horizontal))") { OrdLayoutSample(layout: .horizontal, accent: .indigo) },
        KitSample("Numbered stepper", "Numbers instead of icons.", code: "KitoOrderTrackingStyle(accentColor: .orange, timelineLayout: .stepper)") { OrdLayoutSample(layout: .stepper, accent: .orange) },
        KitSample("Detailed history", "Every event with its time and place; the current step pulses.", code: """
        KitoOrderEventTimeline(events: [
            KitoOrderEvent(stage: .placed, detail: "Order #KE-2048 · 3 items", time: placedAt, location: "Kilimani"),
            KitoOrderEvent(stage: .outForDelivery, detail: "Amara picked up your order", time: pickedUpAt),
        ], currentStage: update.stage)
        """) { OrdEventTimelineSample() },
        KitSample("Progress track", "The courier's vehicle rides the track between stages.", code: "KitoOrderProgressTrack(stage: update.stage, progress: update.progress, vehicle: .motorbike)") { OrdProgressTrackSample() },
        KitSample("Status chips", "Tinted, solid and outline, with a pulsing dot while in progress.", code: """
        KitoOrderStatusChip(stage: .outForDelivery)
        KitoOrderStatusChip(stage: .delivered, style: .solid)   // .tinted, .outline
        """) { OrdChipsSample() },
        KitSample("Order history", "A list of orders with chips and compact progress bars.", code: """
        HStack { Text(order.merchant); Spacer(); KitoOrderStatusChip(stage: order.stage) }
        KitoOrderStageTimelineView(currentStage: order.stage, style: KitoOrderTrackingStyle(timelineLayout: .compact))
        """) { OrdHistoryListSample() },
    ])

    static let courier = KitSection("Courier & ETA", symbol: "scooter", [
        KitSample("Courier card", "Rating, deliveries, vehicle, plate, call and chat.", code: """
        KitoCourierCard(
            courier: KitoCourier(name: "Amara Mwangi", phone: "+254712345678", vehicle: .motorbike,
                                 plate: "KMFB 214C", rating: 4.9, deliveries: 1_284),
            onChat: { showChat = true }   // leave onCall out to dial the phone number
        )
        """) { OrdCourierSample() },
        KitSample("Courier over a map", "The compact card floating on the route.", code: "KitoCourierCard(courier: courier, style: .compact, onChat: openChat)") { OrdCourierMapSample() },
        KitSample("ETA ring", "Minutes left in a ring that fills towards arrival, ticking every second.", code: "KitoETACountdown(eta: eta, start: pickedUpAt, style: .ring)") { OrdETARingSample() },
        KitSample("ETA styles", "Digital, headline and a header pill.", code: """
        KitoETACountdown(eta: eta, style: .digital)    // "07:25"
        KitoETACountdown(eta: eta, style: .headline)   // "Arriving in 8 min"
        KitoETACountdown(eta: eta, style: .pill)
        """) { OrdETAStylesSample() },
    ])

    static let delivered = KitSection("Delivered", symbol: "checkmark.seal", [
        KitSample("Proof of delivery", "Doorstep photo, the signature writing itself in, and the handover code.", code: """
        KitoDeliveryProofView(proof: KitoDeliveryProof(
            recipientName: "Wycliff N", deliveredAt: deliveredAt, photoURL: proof.photoURL,
            signature: proof.strokes, code: "4821", note: "Left with the askari at the gate."))
        """) { OrdProofSample() },
        KitSample("Sign for it", "Sign with a finger, confirm, and see it on the proof.", code: """
        @State private var strokes: [[CGPoint]] = []

        KitoDeliverySignaturePad(strokes: $strokes).frame(height: 190)
        KitoDeliveryProofView(proof: KitoDeliveryProof(recipientName: name, deliveredAt: .now, signature: strokes))
        """) { OrdSignSample() },
        KitSample("Delivered and cancelled", "Finished orders get their own clear row, whatever the layout.", code: "KitoOrderStageTimelineView(currentStage: .cancelled)") { OrdTerminalSample() },
    ])

    static let previews = KitSection("Live Activity previews", symbol: "iphone.gen3", [
        KitSample("Lock Screen", "The real Lock Screen view, over a wallpaper, for any stage.", code: "KitoLiveActivityPreview(merchantName: merchant, update: update, surface: .lockScreen)") { OrdLockScreenPreviewSample() },
        KitSample("Dynamic Island", "Compact, minimal and expanded, in an orange accent.", code: """
        KitoLiveActivityPreview(merchantName: merchant, update: update, surface: .islandExpanded,
                                style: KitoOrderTrackingStyle(accentColor: .orange))   // .islandCompact, .islandMinimal
        """) { OrdIslandPreviewSample() },
        KitSample("Branded styles", "Your fonts, colours, words and layout on the tracking screen.", code: """
        KitoOrderTrackingStyle(
            accentColor: .purple,
            stageLabels: [.confirmed: "Jikoni wameanza", .delivered: "Karibu, enjoy!"],
            stageIcons: [.outForDelivery: "scooter"],
            timelineLayout: .stepper
        )
        """) { OrdBrandedStylesSample() },
    ])
}

/// Every order tracking sample.
struct OrderTrackingDemo: View {
    static var count: Int { KitGallery.count(OrderTrackingSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Order Tracking",
            sections: OrderTrackingSamples.sections,
            footnote: "Requires `import KitoOrderTracking`. The Lock Screen and Dynamic Island need the sample's widget extension.",
            searchHint: "Try “courier”, “ETA”, “signature” or “island”."
        )
    }
}
