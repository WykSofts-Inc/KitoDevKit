//
//  ConnectivitySamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoConnectivity

// Most samples drive a simulated monitor (`KitoConnectivityMonitor(simulatedOnline:)`) so every
// state can be shown without touching your network. Samples marked "Live" use the real signal.

// MARK: - Stages

/// A feed screen with an Airplane switch: offline shows the banner, back online flashes "Back
/// online", and a slow line shows "Slow connection".
private struct ConnFeedStage: View {
    let style: KitoConnectivityBannerStyle
    @State private var monitor = KitoConnectivityMonitor(simulatedOnline: true, latency: 0.05)
    @State private var mode = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Feed").font(.largeTitle.bold())
                    Spacer()
                    KitoNetworkQualityIndicator(monitor: monitor, style: .bars)
                }
                .padding(.top, 56)
                Picker("Network", selection: $mode) {
                    Text("Online").tag(0)
                    Text("Slow").tag(1)
                    Text("Offline").tag(2)
                }
                .pickerStyle(.segmented)
                ForEach(ConnFeedPost.samples) { post in ConnFeedCard(post: post, dimmed: !monitor.isOnline) }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
        .kitoConnectivityBanner(monitor, style: style) { mode = 0 }
        .onChange(of: mode) { _, value in
            switch value {
            case 0: monitor.simulate(isOnline: true, latency: 0.05)
            case 1: monitor.simulate(isOnline: true, connectionType: .cellular, latency: 1.4)
            default: monitor.simulate(isOnline: false)
            }
        }
    }
}

private struct ConnFeedPost: Identifiable {
    let id = UUID()
    let author: String
    let initials: String
    let tint: Color
    let text: String
    let time: String

    static let samples = [
        ConnFeedPost(author: "Amina Wanjiru", initials: "AW", tint: .orange, text: "Sunset at Karura was unreal today 🌅", time: "12m"),
        ConnFeedPost(author: "Brian Otieno", initials: "BO", tint: .blue, text: "Who's in for nyama choma at Carnivore on Saturday?", time: "1h"),
        ConnFeedPost(author: "Grace Achieng", initials: "GA", tint: .purple, text: "Matatu art on Ngong Road keeps getting better.", time: "3h"),
    ]
}

private struct ConnFeedCard: View {
    let post: ConnFeedPost
    let dimmed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(post.initials).font(.subheadline.bold()).foregroundStyle(.white).frame(width: 38, height: 38).background(Circle().fill(post.tint.gradient))
                VStack(alignment: .leading, spacing: 0) {
                    Text(post.author).font(.subheadline.weight(.semibold))
                    Text(post.time).font(.caption).foregroundStyle(.secondary)
                }
            }
            Text(post.text).font(.body)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(colors: [post.tint.opacity(0.5), post.tint.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 120)
                .overlay {
                    if dimmed { Label("Saved copy", systemImage: "arrow.down.circle").font(.caption.weight(.semibold)).padding(8).background(.ultraThinMaterial, in: Capsule()) }
                }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(.secondarySystemBackground)))
        .saturation(dimmed ? 0.4 : 1)
        .animation(.easeInOut(duration: 0.3), value: dimmed)
    }
}

/// One banner, standalone.
private struct ConnBannerPreview: View {
    let state: KitoConnectivityBannerState
    let style: KitoConnectivityBannerStyle
    var retry = false

    var body: some View {
        KitoConnectivityBanner(state, style: style, onRetry: retry ? {} : nil)
            .clipShape(RoundedRectangle(cornerRadius: style == .bar ? 12 : 0, style: .continuous))
    }
}

/// Pick any state and style.
private struct ConnBannerPlayground: View {
    @State private var state: KitoConnectivityBannerState? = .offline
    @State private var style: KitoConnectivityBannerStyle = .floating

    var body: some View {
        VStack(spacing: 16) {
            Picker("Style", selection: $style) {
                ForEach(KitoConnectivityBannerStyle.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
            }
            .pickerStyle(.segmented)
            HStack(spacing: 8) {
                ForEach(KitoConnectivityBannerState.allCases, id: \.self) { value in
                    Button(label(value)) { state = state == value ? nil : value }
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .frame(minHeight: 34)
                        .background(Capsule().fill(state == value ? Color.primary : Color.primary.opacity(0.07)))
                        .foregroundStyle(state == value ? Color(.systemBackground) : .primary)
                        .buttonStyle(.plain)
                }
            }
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 170)
                .overlay(Text("Your screen").font(.subheadline).foregroundStyle(.secondary))
                .kitoConnectivityBanner(state: state, style: style, onRetry: {})
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    private func label(_ state: KitoConnectivityBannerState) -> String {
        switch state {
        case .offline: return "Offline"
        case .backOnline: return "Back online"
        case .slow: return "Slow"
        }
    }
}

/// Every quality, as bars and pills.
private struct ConnQualityLadder: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(KitoNetworkQuality.allCases.reversed(), id: \.self) { quality in
                HStack(spacing: 16) {
                    KitoNetworkQualityIndicator(quality, style: .bars)
                        .frame(width: 40, alignment: .leading)
                    KitoNetworkQualityIndicator(quality, style: .pill, latency: latency(for: quality))
                    Spacer()
                }
            }
        }
    }

    private func latency(for quality: KitoNetworkQuality) -> TimeInterval? {
        switch quality {
        case .offline: return nil
        case .poor: return 1.8
        case .fair: return 0.34
        case .good: return 0.12
        case .excellent: return 0.03
        }
    }
}

/// Drag the round trip; the gauge grades it.
private struct ConnGaugePlayground: View {
    @State private var latency = 0.12
    @State private var lowData = false

    private var quality: KitoNetworkQuality { KitoNetworkQuality(isOnline: true, latency: latency, isConstrained: lowData) }

    var body: some View {
        VStack(spacing: 18) {
            KitoNetworkQualityIndicator(quality, style: .gauge, latency: latency)
            VStack(alignment: .leading, spacing: 6) {
                Text("Round trip").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Slider(value: $latency, in: 0.01...2.0).tint(.primary)
            }
            Toggle("Low Data Mode", isOn: $lowData).font(.subheadline.weight(.medium))
        }
    }
}

/// The real network signal.
private struct ConnLiveStatus: View {
    @State private var monitor = KitoConnectivityMonitor()
    @State private var measuring = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: monitor.isOnline ? monitor.connectionType.systemImage : "wifi.slash")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(monitor.isOnline ? Color.green.gradient : Color.red.gradient))
                    .contentTransition(.symbolEffect(.replace))
                VStack(alignment: .leading, spacing: 2) {
                    Text(monitor.isOnline ? "Online" : "Offline").font(.title3.bold())
                    Text(monitor.isOnline ? monitor.connectionType.displayName : "No connection").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                KitoNetworkQualityIndicator(monitor: monitor, style: .bars)
            }
            HStack(spacing: 8) {
                ConnFlag(title: "Expensive", isOn: monitor.isExpensive)
                ConnFlag(title: "Low Data", isOn: monitor.isConstrained)
                ConnFlag(title: monitor.latency.map { "\(Int($0 * 1000)) ms" } ?? "Not measured", isOn: monitor.latency != nil)
            }
            Button {
                measuring = true
                Task { await monitor.measureQuality(); measuring = false }
            } label: {
                Label(measuring ? "Measuring…" : "Measure quality", systemImage: "speedometer").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(measuring)
            KitoNetworkQualityIndicator(monitor: monitor, style: .pill)
        }
    }
}

private struct ConnFlag: View {
    let title: String
    let isOn: Bool

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(isOn ? Color.primary : Color.primary.opacity(0.07)))
            .foregroundStyle(isOn ? Color(.systemBackground) : .secondary)
    }
}

/// Send money that waits for the network, then retries with backoff.
private struct ConnRetryStage: View {
    @State private var monitor = KitoConnectivityMonitor(simulatedOnline: false)
    @State private var log: [String] = []
    @State private var status = "Ready"
    @State private var running = false
    @State private var failuresLeft = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Send KSh 500 to Brian").font(.headline)
                Spacer()
                KitoNetworkQualityIndicator(monitor: monitor, style: .bars)
            }
            Toggle("Network", isOn: Binding(get: { monitor.isOnline }, set: { monitor.simulate(isOnline: $0) }))
                .font(.subheadline.weight(.medium))
            Button {
                run()
            } label: {
                Label(running ? status : "Send", systemImage: running ? "hourglass" : "paperplane.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(running)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(log.enumerated()), id: \.offset) { _, line in
                    Text(line).font(.caption.monospaced()).foregroundStyle(.secondary).transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: log)
        }
        .kitoConnectivityBanner(monitor, style: .pill)
    }

    private func run() {
        running = true
        failuresLeft = 1
        log = monitor.isOnline ? [] : ["Offline — waiting for the network…"]
        status = monitor.isOnline ? "Sending…" : "Waiting for network…"
        Task {
            do {
                let ref = try await monitor.retryWhenOnline(policy: KitoRetryPolicy(maxAttempts: 3, initialDelay: .seconds(1)), onAttempt: { attempt in
                    log.append("Attempt \(attempt)…")
                    status = "Sending (attempt \(attempt))…"
                }) { () async throws -> String in
                    try await Task.sleep(for: .milliseconds(600))
                    if failuresLeft > 0 {
                        failuresLeft -= 1
                        log.append("Timed out — retrying in 1 s")
                        throw URLError(.timedOut)
                    }
                    return "SJK4M2X9QP"
                }
                log.append("Sent ✓ Ref \(ref)")
            } catch {
                log.append("Gave up: \(error.localizedDescription)")
            }
            running = false
        }
    }
}

/// The backoff schedule for a policy.
private struct ConnBackoffTimeline: View {
    @State private var multiplier = 2.0
    private var policy: KitoRetryPolicy { KitoRetryPolicy(maxAttempts: 6, initialDelay: .seconds(1), multiplier: multiplier, maxDelay: .seconds(20)) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(1..<policy.maxAttempts, id: \.self) { attempt in
                let seconds = Double(policy.delay(afterAttempt: attempt).components.seconds)
                HStack(spacing: 10) {
                    Text("after \(attempt)").font(.caption.monospaced()).foregroundStyle(.secondary).frame(width: 58, alignment: .leading)
                    Capsule()
                        .fill(LinearGradient(colors: [.teal, .blue], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(12, 200 * seconds / 20), height: 12)
                    Text("\(Int(seconds)) s").font(.caption.monospaced().weight(.semibold))
                }
            }
            HStack {
                Text("Multiplier").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Slider(value: $multiplier, in: 1...3, step: 0.5).tint(.primary)
                Text(String(format: "×%.1f", multiplier)).font(.caption.monospaced())
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: multiplier)
    }
}

/// Offline edits queue up, then flush once `waitUntilOnline()` returns.
private struct ConnSyncQueue: View {
    @State private var monitor = KitoConnectivityMonitor(simulatedOnline: false)
    @State private var pending: [String] = ["Photo: Maasai Market haul", "Note: Chama contributions", "Receipt: Naivas KSh 3,120"]
    @State private var synced: [String] = []
    @State private var waiting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Network", isOn: Binding(get: { monitor.isOnline }, set: { monitor.simulate(isOnline: $0) }))
                .font(.subheadline.weight(.medium))
            ForEach(pending, id: \.self) { item in
                Label(item, systemImage: "clock.arrow.circlepath").font(.subheadline).foregroundStyle(.orange)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            ForEach(synced, id: \.self) { item in
                Label(item, systemImage: "checkmark.icloud.fill").font(.subheadline).foregroundStyle(.green)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
            Text(waiting ? "Waiting for the network…" : pending.isEmpty ? "All synced" : "")
                .font(.caption).foregroundStyle(.secondary)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: pending)
        .task {
            waiting = true
            await monitor.waitUntilOnline()
            waiting = false
            for item in pending {
                try? await Task.sleep(for: .milliseconds(450))
                pending.removeAll { $0 == item }
                synced.append(item)
            }
        }
    }
}

/// Defers big downloads on an expensive or Low Data path.
private struct ConnDataSaver: View {
    @State private var monitor = KitoConnectivityMonitor(simulatedOnline: true, connectionType: .cellular, latency: 0.2)
    @State private var onWiFi = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Path", selection: $onWiFi) {
                Text("Mobile data").tag(false)
                Text("Wi-Fi").tag(true)
            }
            .pickerStyle(.segmented)
            .onChange(of: onWiFi) { _, wifi in monitor.simulate(isOnline: true, connectionType: wifi ? .wifi : .cellular, latency: wifi ? 0.04 : 0.2) }
            HStack(spacing: 14) {
                Image(systemName: "play.rectangle.fill").font(.title).foregroundStyle(.white).frame(width: 64, height: 64)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.purple.gradient))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Safari Rally highlights").font(.headline)
                    Text("1.2 GB · 4K").font(.subheadline).foregroundStyle(.secondary)
                    Label(monitor.isExpensive ? "Waiting for Wi-Fi" : "Downloading…", systemImage: monitor.isExpensive ? "wifi.exclamationmark" : "arrow.down.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(monitor.isExpensive ? .orange : .green)
                        .contentTransition(.opacity)
                }
            }
            KitoNetworkQualityIndicator(monitor: monitor, style: .pill)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: monitor.isExpensive)
        .onAppear { monitor.simulate(isOnline: true, connectionType: onWiFi ? .wifi : .cellular, latency: onWiFi ? 0.04 : 0.2) }
    }
}

/// A checkout that can't pay offline.
private struct ConnCheckoutStage: View {
    @State private var monitor = KitoConnectivityMonitor(simulatedOnline: false)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Checkout").font(.largeTitle.bold()).padding(.top, 56)
            ForEach([("Grilled tilapia", "KSh 950"), ("Ugali & sukuma", "KSh 250"), ("Delivery", "KSh 150")], id: \.0) { item in
                HStack { Text(item.0); Spacer(); Text(item.1).monospacedDigit().foregroundStyle(.secondary) }
            }
            Divider()
            HStack { Text("Total").font(.headline); Spacer(); Text("KSh 1,350").font(.headline.monospacedDigit()) }
            Spacer()
            Toggle("Network", isOn: Binding(get: { monitor.isOnline }, set: { monitor.simulate(isOnline: $0) }))
            Button { } label: {
                Label(monitor.isOnline ? "Pay with M-Pesa" : "Waiting for network", systemImage: monitor.isOnline ? "iphone.gen3" : "wifi.slash").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(!monitor.isOnline)
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .kitoConnectivityBanner(monitor, style: .bar)
    }
}

/// The 1.0 offline banner, still supported — on the real signal.
private struct ConnLegacyStage: View {
    @State private var monitor = KitoConnectivityMonitor()

    var body: some View {
        MockAppScreen(title: "Home", tint: .red) {
            Text(monitor.isOnline ? "Online — turn on Airplane Mode to see the banner" : "Offline").font(.footnote).foregroundStyle(.secondary)
        }
        .kitoOfflineBanner(monitor)
    }
}

// MARK: - Code

private let bannerCode = """
@State private var connectivity = KitoConnectivityMonitor()

FeedScreen()
    .kitoConnectivityBanner(connectivity, style: .floating) {
        Task { await feed.reload() }
    }
"""

private let retryCode = """
let receipt = try await connectivity.retryWhenOnline(policy: .standard) {
    try await mpesa.send(amount: 500, to: brian)
}
"""

// MARK: - Samples

enum ConnectivitySamples {
    static let sections: [KitSection] = [automatic, banners, quality, retry, live]

    static let automatic = KitSection("Automatic banners", symbol: "wifi.exclamationmark", [
        KitSample("Floating card", "Switch the network: offline, slow, then Back online.", code: bannerCode) {
            ModalStage { ConnFeedStage(style: .floating) }
        },
        KitSample("Full-width bar", "The strip across the top.", code: bannerCode.replacingOccurrences(of: ".floating", with: ".bar")) {
            ModalStage { ConnFeedStage(style: .bar) }
        },
        KitSample("Island pill", "A small dark capsule at the top.", code: bannerCode.replacingOccurrences(of: ".floating", with: ".pill")) {
            ModalStage { ConnFeedStage(style: .pill) }
        },
        KitSample("Checkout blocked offline", "The pay button waits for the network.", code: "CheckoutScreen()\n    .kitoConnectivityBanner(connectivity, style: .bar)\n\nButton(\"Pay\") { … }.disabled(!connectivity.isOnline)") {
            ModalStage { ConnCheckoutStage() }
        },
    ])

    static let banners = KitSection("Banners", symbol: "rectangle.topthird.inset.filled", [
        KitSample("You're offline", "Floating, with Retry.", code: "KitoConnectivityBanner(.offline, style: .floating) { retry() }") {
            ConnBannerPreview(state: .offline, style: .floating, retry: true)
        },
        KitSample("Back online", "A green bar that bounces in.", code: "KitoConnectivityBanner(.backOnline, style: .bar)") {
            ConnBannerPreview(state: .backOnline, style: .bar)
        },
        KitSample("Slow connection", "A pill with a searching signal.", code: "KitoConnectivityBanner(.slow, style: .pill)") {
            ConnBannerPreview(state: .slow, style: .pill)
        },
        KitSample("Every state and style", "Mix and match on a mock screen.", code: "ContentView()\n    .kitoConnectivityBanner(state: state, style: style)") {
            ConnBannerPlayground()
        },
    ])

    static let quality = KitSection("Network quality", symbol: "cellularbars", [
        KitSample("Quality ladder", "Offline to excellent, as bars and pills.", code: "KitoNetworkQualityIndicator(.good, style: .pill, latency: 0.12)") { ConnQualityLadder() },
        KitSample("Gauge", "Drag the round trip; Low Data Mode caps it at fair.", code: "KitoNetworkQuality(isOnline: true, latency: 0.34, isConstrained: lowDataMode)\nKitoNetworkQualityIndicator(quality, style: .gauge, latency: 0.34)") { ConnGaugePlayground() },
    ])

    static let retry = KitSection("Retry when online", symbol: "arrow.clockwise.circle.fill", [
        KitSample("Send when back online", "Tap Send offline, then switch the network on.", code: retryCode) { ConnRetryStage() },
        KitSample("Backoff schedule", "How long each retry waits.", code: "KitoRetryPolicy(maxAttempts: 6, initialDelay: .seconds(1), multiplier: 2, maxDelay: .seconds(20))\n    .delay(afterAttempt: 3)   // 4 s") { ConnBackoffTimeline() },
        KitSample("Sync queue", "Changes queue up offline and flush the moment you're back.", code: "await connectivity.waitUntilOnline()\ntry await sync.pushPendingChanges()") {
            ConnSyncQueue()
        },
        KitSample("Save mobile data", "Big downloads wait for Wi-Fi when the path is expensive.", code: "if connectivity.isExpensive || connectivity.isConstrained {\n    downloads.deferUntilWiFi()\n}") {
            ConnDataSaver()
        },
    ])

    static let live = KitSection("Live signal", symbol: "antenna.radiowaves.left.and.right", [
        KitSample("Live status", "The real path: type, expensive, Low Data and a measured round trip.", code: "@State private var connectivity = KitoConnectivityMonitor()\n\nawait connectivity.measureQuality()\nKitoNetworkQualityIndicator(monitor: connectivity, style: .pill)") { ConnLiveStatus() },
        KitSample("Offline banner (1.0)", "The original thin banner, on the real signal.", code: "RootView()\n    .kitoOfflineBanner(connectivity)") { ModalStage { ConnLegacyStage() } },
    ])
}
