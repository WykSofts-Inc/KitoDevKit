//
//  HapticsSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoHaptics

// MARK: - Building blocks

/// Says whether the pattern can be felt here, since the simulator has no Taptic Engine.
private struct HapticsDeviceBadge: View {
    var body: some View {
        let felt = KitoHaptics.supportsCoreHaptics
        Label(felt ? "Taptic Engine" : "No haptics here · watch the playhead", systemImage: felt ? "iphone.radiowaves.left.and.right" : "eye")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(Color.primary.opacity(0.06)))
            .foregroundStyle(.secondary)
    }
}

/// A preset on a card: what it's for, what it looks like, and a play button.
private struct HapticsPatternCard: View {
    let pattern: KitoHapticPattern
    let context: String
    let symbol: String
    let colors: [Color]
    var style: KitoHapticVisualizer.Style = .bars
    @State private var playedAt: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: symbol).font(.title3.weight(.semibold)).foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)))
                    .shadow(color: colors[0].opacity(0.35), radius: 8, y: 4)
                VStack(alignment: .leading, spacing: 2) {
                    Text(pattern.name).font(.headline)
                    Text(context).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: play) {
                    Image(systemName: "play.fill").font(.body.weight(.bold)).foregroundStyle(Color(.systemBackground))
                        .frame(width: 44, height: 44).background(Circle().fill(Color.primary))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Play \(pattern.name)")
            }
            KitoHapticVisualizer(pattern, playedAt: playedAt, style: style, softColor: colors.last, sharpColor: colors.first)
                .frame(height: 100)
            HStack(spacing: 8) {
                Text("\(pattern.events.count) beats").font(.caption2.weight(.semibold).monospacedDigit())
                    .padding(.horizontal, 10).padding(.vertical, 5).background(Capsule().fill(Color.primary.opacity(0.06)))
                Text(String(format: "%.2f s", pattern.duration)).font(.caption2.weight(.semibold).monospacedDigit())
                    .padding(.horizontal, 10).padding(.vertical, 5).background(Capsule().fill(Color.primary.opacity(0.06)))
                Spacer(minLength: 0)
                HapticsDeviceBadge()
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(colors[0].opacity(0.07)))
        .task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            play()
        }
    }

    private func play() {
        KitoHaptics.play(pattern)
        playedAt = .now
    }
}

/// A ring that bursts outwards each time `trigger` changes — the visible stand-in for a tap.
private struct HapticsRipple: View {
    let trigger: Int
    let color: Color
    var strength: Double = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1
    @State private var opacity = 0.0

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 3 + 3 * strength)
            .scaleEffect(scale)
            .opacity(opacity)
            .onChange(of: trigger) { _, _ in
                scale = 1
                opacity = 0.9
                withAnimation(.easeOut(duration: 0.55)) {
                    if !reduceMotion { scale = 1 + 0.5 * strength }
                    opacity = 0
                }
            }
            .allowsHitTesting(false)
    }
}

// MARK: - Samples with state

private struct HapticsHoldToConfirm: View {
    @State private var isPressing = false
    @State private var progress: CGFloat = 0
    @State private var confirmed = false
    @State private var playedAt: Date?

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Send KSh 5,000 to Baraka").font(.headline)
                Text("Hold to confirm · feel it build").font(.caption).foregroundStyle(.secondary)
            }
            ZStack(alignment: .leading) {
                Capsule().fill(Color.primary.opacity(0.08))
                GeometryReader { geometry in
                    Capsule().fill(confirmed ? Color.green : Color.primary)
                        .frame(width: max(geometry.size.height, geometry.size.width * progress))
                }
                Label(confirmed ? "Sent" : (isPressing ? "Keep holding…" : "Hold to send"), systemImage: confirmed ? "checkmark" : "paperplane.fill")
                    .font(.headline)
                    .foregroundStyle(progress > 0.5 || confirmed ? Color(.systemBackground) : .primary)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 60)
            .clipShape(Capsule())
            .onLongPressGesture(minimumDuration: 1.2, maximumDistance: 40) {
                confirmed = true
                KitoHaptics.play(.successChime)
                playedAt = .now
            } onPressingChanged: { pressing in
                guard !confirmed else { return }
                isPressing = pressing
                if pressing {
                    KitoHaptics.play(.rampUp)
                    playedAt = .now
                    withAnimation(.linear(duration: 1.2)) { progress = 1 }
                } else {
                    KitoHaptics.stopPattern()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { progress = confirmed ? 1 : 0 }
                }
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { confirmed = true; progress = 1; KitoHaptics.play(.successChime) }

            KitoHapticVisualizer(confirmed ? .successChime : .rampUp, playedAt: playedAt).frame(height: 70)
            if confirmed {
                Button("Reset") { withAnimation { confirmed = false; progress = 0; playedAt = nil } }.font(.footnote.weight(.semibold))
            }
        }
    }
}

private struct HapticsTipSlider: View {
    @State private var tip = 100.0
    @State private var ticks = 0
    private let tick = KitoHapticPattern.custom([.tap(at: 0, intensity: 0.6, sharpness: 1)], name: "Tick")

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                Circle().fill(LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)).frame(width: 52, height: 52)
                    .overlay(Text("JH").font(.headline).foregroundStyle(.white))
                    .overlay(HapticsRipple(trigger: ticks, color: .green, strength: 0.4))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tip your rider").font(.caption).foregroundStyle(.secondary)
                    Text("Juma Hassan").font(.headline)
                }
                Spacer()
                Text("KSh \(Int(tip))").font(.title2.bold().monospacedDigit()).contentTransition(.numericText(value: tip))
            }
            Slider(value: $tip, in: 0...500, step: 50).tint(.green)
                .onChange(of: tip) { _, _ in
                    KitoHaptics.play(tick)
                    withAnimation(.snappy) { ticks += 1 }
                }
            HStack {
                ForEach([0, 100, 200, 300, 400, 500], id: \.self) { value in
                    Text("\(value)").font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
                    if value != 500 { Spacer() }
                }
            }
        }
    }
}

private struct HapticsPinPad: View {
    @State private var digits: [Int] = []
    @State private var shake = 0
    @State private var status: Bool?
    @State private var playedAt: Date?
    private let correct = [2, 5, 8, 0]

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 4) {
                Text("Enter your Kito PIN").font(.headline)
                Text(status == true ? "Welcome back, Wycliff" : "Try a wrong PIN, then 2580").font(.caption).foregroundStyle(status == true ? .green : .secondary)
            }
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < digits.count ? (status == false ? Color.red : status == true ? Color.green : Color.primary) : Color.primary.opacity(0.12))
                        .frame(width: 16, height: 16)
                }
            }
            .modifier(HapticsShake(animatableData: CGFloat(shake)))
            KitoHapticVisualizer(status == true ? .successChime : .failure, playedAt: playedAt).frame(height: 56)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 12) {
                ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, -1, 0, -2], id: \.self) { key in
                    if key == -1 {
                        Color.clear.frame(height: 52)
                    } else {
                        Button { press(key) } label: {
                            Group {
                                if key == -2 { Image(systemName: "delete.left") } else { Text("\(key)") }
                            }
                            .font(.title2.weight(.medium))
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(Circle().fill(Color.primary.opacity(0.06)).frame(width: 60, height: 60))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(key == -2 ? "Delete" : "\(key)")
                    }
                }
            }
        }
    }

    private func press(_ key: Int) {
        if status != nil { digits = []; status = nil }
        if key == -2 { _ = digits.popLast(); KitoHaptics.impact(.light); return }
        guard digits.count < 4 else { return }
        KitoHaptics.impact(.soft)
        digits.append(key)
        guard digits.count == 4 else { return }
        let ok = digits == correct
        playedAt = .now
        if ok {
            status = true
            KitoHaptics.play(.successChime)
        } else {
            status = false
            KitoHaptics.play(.failure)
            withAnimation(.linear(duration: 0.45)) { shake += 1 }
        }
    }
}

/// Shakes side to side once per whole step of `animatableData`.
private struct HapticsShake: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(animatableData * .pi * 6), y: 0))
    }
}

private struct HapticsOrderDelivered: View {
    @State private var step = 0
    @State private var playedAt: Date?
    private let steps = [("Order placed", "bag.fill"), ("Rider picked up", "bicycle"), ("Nearby", "location.fill"), ("Delivered", "checkmark.seal.fill")]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mama Oliech · #KE-2041").font(.caption).foregroundStyle(.secondary)
                    Text(steps[step].0).font(.title3.bold()).contentTransition(.opacity)
                }
                Spacer()
                Image(systemName: steps[step].1).font(.title2).foregroundStyle(step == 3 ? .green : .orange)
                    .frame(width: 52, height: 52).background(Circle().fill((step == 3 ? Color.green : Color.orange).opacity(0.14)))
                    .overlay(HapticsRipple(trigger: step, color: step == 3 ? .green : .orange))
                    .contentTransition(.symbolEffect(.replace))
            }
            HStack(spacing: 6) {
                ForEach(steps.indices, id: \.self) { index in
                    Capsule().fill(index <= step ? (step == 3 ? Color.green : Color.orange) : Color.primary.opacity(0.1)).frame(height: 6)
                }
            }
            KitoHapticVisualizer(step == 3 ? .successChime : .nudge, playedAt: playedAt).frame(height: 60)
            Text("`.kitoHapticPattern(.successChime, trigger: isDelivered)` plays the chime the moment the status flips.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .kitoHapticPattern(.successChime, trigger: step == 3)
        .onChange(of: step) { _, _ in playedAt = .now; if step < 3 { KitoHaptics.play(.nudge) } }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { step = (step + 1) % steps.count }
            }
        }
    }
}

private struct HapticsNotificationButtons: View {
    @State private var counts = [0, 0, 0]
    private let items: [(String, String, Color, () -> Void)] = [
        ("Success", "checkmark.circle.fill", .green, { KitoHaptics.success() }),
        ("Warning", "exclamationmark.triangle.fill", .orange, { KitoHaptics.warning() }),
        ("Error", "xmark.octagon.fill", .red, { KitoHaptics.error() }),
    ]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                Button {
                    item.3()
                    counts[index] += 1
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: item.1).font(.title).foregroundStyle(item.2)
                            .frame(width: 64, height: 64)
                            .background(Circle().fill(item.2.opacity(0.12)))
                            .overlay(HapticsRipple(trigger: counts[index], color: item.2))
                        Text(item.0).font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.primary.opacity(0.04)))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct HapticsImpactWeights: View {
    @State private var counts = Array(repeating: 0, count: 5)
    private let weights: [(String, KitoHaptics.ImpactStyle, Double)] = [
        ("Soft", .soft, 0.3), ("Light", .light, 0.45), ("Medium", .medium, 0.65), ("Heavy", .heavy, 0.85), ("Rigid", .rigid, 1),
    ]

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(weights.indices, id: \.self) { index in
                    let weight = weights[index]
                    Button {
                        KitoHaptics.impact(weight.1)
                        counts[index] += 1
                    } label: {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom).opacity(0.35 + 0.65 * weight.2))
                                .frame(width: 26 + 30 * weight.2, height: 26 + 30 * weight.2)
                                .overlay(HapticsRipple(trigger: counts[index], color: .purple, strength: weight.2))
                                .keyframeAnimator(initialValue: 1.0, trigger: counts[index]) { view, scale in
                                    view.scaleEffect(scale)
                                } keyframes: { _ in
                                    SpringKeyframe(1 - 0.25 * weight.2, duration: 0.08)
                                    SpringKeyframe(1, duration: 0.35, spring: .bouncy)
                                }
                            Text(weight.0).font(.caption.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            Text("Heavier weights squash harder; rigid is the crispest.").font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

private struct HapticsSelection: View {
    @State private var ride = "Boda"
    private let rides = [("Boda", "bicycle"), ("Tuk-tuk", "car.side"), ("Matatu", "bus.fill"), ("Car", "car.fill")]

    var body: some View {
        VStack(spacing: 18) {
            Picker("Ride", selection: $ride) {
                ForEach(rides, id: \.0) { Text($0.0).tag($0.0) }
            }
            .pickerStyle(.segmented)
            .kitoHaptic(ride) { KitoHaptics.selectionChanged() }
            Image(systemName: rides.first { $0.0 == ride }?.1 ?? "car")
                .font(.system(size: 54)).foregroundStyle(.orange)
                .frame(height: 80)
                .contentTransition(.symbolEffect(.replace))
            Text("Each change fires `selectionChanged()` through `.kitoHaptic(_:_:)`.").font(.caption).foregroundStyle(.secondary)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: ride)
    }
}

private struct HapticsComposer: View {
    @State private var events: [KitoHapticEvent] = [.tap(at: 0, intensity: 0.8, sharpness: 0.5), .tap(at: 0.3, intensity: 0.5, sharpness: 0.5)]
    @State private var crisp = true
    @State private var playedAt: Date?
    private let length = 1.2

    private var pattern: KitoHapticPattern { .custom(events, name: "My pattern") }

    var body: some View {
        VStack(spacing: 14) {
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.primary.opacity(0.04))
                    RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Color.primary.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    // A silent hold keeps the drawn timeline as long as the pad.
                    KitoHapticVisualizer(.custom(events + [.hold(at: 0, duration: length, intensity: 0)], name: "My pattern"), playedAt: playedAt)
                        .padding(8)
                    if events.isEmpty {
                        Text("Tap anywhere: left to right is time, higher is stronger")
                            .font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    let time = min(max(Double(location.x / geometry.size.width) * length, 0), length)
                    let intensity = min(max(1 - Double(location.y / geometry.size.height), 0.1), 1)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        events.append(.tap(at: time, intensity: intensity, sharpness: crisp ? 0.9 : 0.2))
                    }
                    KitoHaptics.impact(crisp ? .rigid : .soft)
                }
            }
            .frame(height: 150)
            HStack(spacing: 10) {
                Picker("Feel", selection: $crisp) {
                    Text("Crisp").tag(true)
                    Text("Soft").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 150)
                Spacer()
                Button("Clear") { withAnimation { events = [] } }.font(.subheadline.weight(.semibold)).disabled(events.isEmpty)
                Button {
                    KitoHaptics.play(pattern)
                    playedAt = .now
                } label: { Label("Play", systemImage: "play.fill") }
                    .buttonStyle(GalleryPrimaryButtonStyle())
                    .disabled(events.isEmpty)
            }
            Text("\(events.count) taps").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
    }
}

private struct HapticsWaveformBrowser: View {
    @State private var selected = KitoHapticPattern.heartbeat
    @State private var playedAt: Date?

    var body: some View {
        VStack(spacing: 16) {
            KitoHapticVisualizer(selected, playedAt: playedAt, style: .waveform)
                .frame(height: 120)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color(red: 0.07, green: 0.08, blue: 0.14)))
                .environment(\.colorScheme, .dark)
                .environment(\.kitoTheme, .dark)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(KitoHapticPattern.presets) { pattern in
                        Button {
                            selected = pattern
                            KitoHaptics.play(pattern)
                            playedAt = .now
                        } label: {
                            Text(pattern.name).font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(Capsule().fill(selected == pattern ? Color.primary : Color.primary.opacity(0.07)))
                                .foregroundStyle(selected == pattern ? Color(.systemBackground) : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            KitoHaptics.play(selected)
            playedAt = .now
        }
    }
}

private struct HapticsBarsAndWave: View {
    @State private var playedAt: Date?
    private let pattern = KitoHapticPattern.rumble

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Bars").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            KitoHapticVisualizer(pattern, playedAt: playedAt, style: .bars).frame(height: 80)
            Text("Waveform").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            KitoHapticVisualizer(pattern, playedAt: playedAt, style: .waveform).frame(height: 80)
            Button {
                KitoHaptics.play(pattern)
                playedAt = .now
            } label: { Label("Play rumble", systemImage: "play.fill").frame(maxWidth: .infinity) }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct HapticsGlobalSwitch: View {
    @State private var isEnabled = KitoHaptics.isEnabled
    @State private var playedAt: Date?

    var body: some View {
        VStack(spacing: 16) {
            Toggle(isOn: $isEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Haptic feedback").font(.headline)
                    Text("Settings › Sounds & Haptics").font(.caption).foregroundStyle(.secondary)
                }
            }
            .tint(.green)
            .onChange(of: isEnabled) { _, value in KitoHaptics.isEnabled = value }
            KitoHapticVisualizer(.knock, playedAt: isEnabled ? playedAt : nil).frame(height: 60).opacity(isEnabled ? 1 : 0.35)
            Button {
                KitoHaptics.play(.knock)
                playedAt = .now
            } label: { Label(isEnabled ? "Knock knock" : "Muted", systemImage: isEnabled ? "hand.tap.fill" : "speaker.slash.fill").frame(maxWidth: .infinity) }
                .buttonStyle(GalleryPrimaryButtonStyle())
            Text("One switch silences every KitoHaptics call and pattern in the app.").font(.caption).foregroundStyle(.secondary)
        }
        .onDisappear { KitoHaptics.isEnabled = true }
    }
}

// MARK: - Code

private func playCode(_ preset: String) -> String {
    """
    @State private var playedAt: Date?

    KitoHapticVisualizer(.\(preset), playedAt: playedAt)
        .frame(height: 100)

    Button("Play") {
        KitoHaptics.play(.\(preset))
        playedAt = .now
    }
    """
}

// MARK: - Catalogue

enum HapticsSamples {
    static let sections: [KitSection] = [patterns, context, semantic, compose, visualizer, settings]

    static let patterns = KitSection("Patterns", symbol: "waveform.path", [
        KitSample("Heartbeat", "Lub-dub, twice: a health check, a live pulse.", code: playCode("heartbeat")) {
            HapticsPatternCard(pattern: .heartbeat, context: "Resting heart rate · Kito Fit", symbol: "heart.fill", colors: [.red, .pink])
        },
        KitSample("Success chime", "Three rising taps: payment confirmed.", code: playCode("successChime")) {
            HapticsPatternCard(pattern: .successChime, context: "KSh 2,500 sent to Achieng", symbol: "checkmark.seal.fill", colors: [.green, .teal])
        },
        KitSample("Ticks", "Crisp, even clicks, like a dial.", code: playCode("ticks") + "\n\n// or your own count\nKitoHaptics.play(.ticks(count: 12, interval: 0.05))") {
            HapticsPatternCard(pattern: .ticks, context: "Choosing a delivery time", symbol: "dial.medium.fill", colors: [.blue, .cyan])
        },
        KitSample("Rumble", "A heavy, low buzz with bumps.", code: playCode("rumble")) {
            HapticsPatternCard(pattern: .rumble, context: "Your boda boda is arriving", symbol: "bicycle", colors: [.orange, .brown])
        },
        KitSample("Knock", "Two firm taps: someone's at the gate.", code: playCode("knock")) {
            HapticsPatternCard(pattern: .knock, context: "Visitor at Gate B · Kilimani", symbol: "door.left.hand.closed", colors: [.brown, .orange])
        },
        KitSample("Ramp up", "Swells from nothing to a snap.", code: playCode("rampUp")) {
            HapticsPatternCard(pattern: .rampUp, context: "Hold to send", symbol: "arrow.up.right", colors: [.purple, .indigo])
        },
        KitSample("Ramp down", "Starts strong, fades away.", code: playCode("rampDown")) {
            HapticsPatternCard(pattern: .rampDown, context: "Ride cancelled", symbol: "arrow.down.right", colors: [.indigo, .gray])
        },
        KitSample("Failure", "A sharp double buzz and a thud.", code: playCode("failure")) {
            HapticsPatternCard(pattern: .failure, context: "Wrong M-Pesa PIN", symbol: "xmark.octagon.fill", colors: [.red, .orange])
        },
        KitSample("Nudge", "A soft double tap on the shoulder.", code: playCode("nudge")) {
            HapticsPatternCard(pattern: .nudge, context: "Reminder: chama contribution due", symbol: "hand.point.up.left.fill", colors: [.teal, .mint])
        },
    ])

    static let context = KitSection("In context", symbol: "iphone.gen3", [
        KitSample("Hold to confirm", "A ramp while you hold, a chime when it sends.", code: """
        .onLongPressGesture(minimumDuration: 1.2) {
            KitoHaptics.play(.successChime)
            send()
        } onPressingChanged: { pressing in
            pressing ? KitoHaptics.play(.rampUp) : KitoHaptics.stopPattern()
        }
        """) { HapticsHoldToConfirm() },
        KitSample("Tip slider", "A crisp tick on every step.", code: """
        let tick = KitoHapticPattern.custom([.tap(at: 0, intensity: 0.6, sharpness: 1)])

        Slider(value: $tip, in: 0...500, step: 50)
            .onChange(of: tip) { _, _ in KitoHaptics.play(tick) }
        """) { HapticsTipSlider() },
        KitSample("Wrong PIN", "A failure pattern and a shake; the right PIN chimes.", code: """
        if pin == stored {
            KitoHaptics.play(.successChime)
        } else {
            KitoHaptics.play(.failure)
            withAnimation { shakes += 1 }
        }
        """) { HapticsPinPad() },
        KitSample("Order delivered", "Plays when the status flips, not on a tap.", code: """
        OrderStatusCard(order)
            .kitoHapticPattern(.successChime, trigger: order.isDelivered)
        """) { HapticsOrderDelivered() },
    ])

    static let semantic = KitSection("Semantic feedback", symbol: "hand.tap", [
        KitSample("Notifications", "Success, warning and error, in one call each.", code: "KitoHaptics.success()\nKitoHaptics.warning()\nKitoHaptics.error()") {
            HapticsNotificationButtons()
        },
        KitSample("Impact weights", "Soft, light, medium, heavy and rigid.", code: "KitoHaptics.impact(.soft)\nKitoHaptics.impact(.heavy)\nKitoHaptics.impact(.rigid)") {
            HapticsImpactWeights()
        },
        KitSample("Selection changes", "A tick as the choice moves, straight from state.", code: "Picker(\"Ride\", selection: $ride) { … }\n    .kitoHaptic(ride) { KitoHaptics.selectionChanged() }") {
            HapticsSelection()
        },
    ])

    static let compose = KitSection("Build your own", symbol: "slider.horizontal.below.rectangle", [
        KitSample("Tap to compose", "Tap the pad to place beats, then play them back.", code: """
        let pattern = KitoHapticPattern.custom([
            .tap(at: 0, intensity: 0.8, sharpness: 0.9),
            .tap(at: 0.3, intensity: 0.5, sharpness: 0.2),
            .hold(at: 0.5, duration: 0.4, intensity: 0.2, endIntensity: 1),
        ], name: "My pattern")
        KitoHaptics.play(pattern)
        """) { HapticsComposer() },
        KitSample("Drumroll in code", "Events, a ramp, repeated and scaled.", code: """
        let drumroll = KitoHapticPattern.custom([
            .tap(at: 0, intensity: 0.6, sharpness: 0.8),
            .tap(at: 0.08, intensity: 0.7, sharpness: 0.8),
            .hold(at: 0.16, duration: 0.5, intensity: 0.2, sharpness: 0.5, endIntensity: 1),
        ], name: "Drumroll").repeated(2, gap: 0.15).scaled(by: 0.9)
        """) {
            HapticsPatternCard(
                pattern: KitoHapticPattern.custom([
                    .tap(at: 0, intensity: 0.6, sharpness: 0.8),
                    .tap(at: 0.08, intensity: 0.7, sharpness: 0.8),
                    .hold(at: 0.16, duration: 0.5, intensity: 0.2, sharpness: 0.5, endIntensity: 1),
                ], name: "Drumroll").repeated(2, gap: 0.15).scaled(by: 0.9),
                context: "Revealing your Kito Wrapped 2026", symbol: "music.quarternote.3", colors: [.pink, .purple])
        },
    ])

    static let visualizer = KitSection("Visualizer", symbol: "waveform", [
        KitSample("Waveform", "An audio-style envelope; pick a pattern to play it.", code: "KitoHapticVisualizer(pattern, playedAt: playedAt, style: .waveform)\n    .frame(height: 120)") {
            HapticsWaveformBrowser()
        },
        KitSample("Bars or waveform", "The same pattern, drawn both ways.", code: "KitoHapticVisualizer(.rumble, playedAt: playedAt, style: .bars)\nKitoHapticVisualizer(.rumble, playedAt: playedAt, style: .waveform)") {
            HapticsBarsAndWave()
        },
    ])

    static let settings = KitSection("Settings", symbol: "gearshape", [
        KitSample("Global switch", "Bind a settings toggle to KitoHaptics.isEnabled.", code: "Toggle(\"Haptic feedback\", isOn: Binding(\n    get: { KitoHaptics.isEnabled },\n    set: { KitoHaptics.isEnabled = $0 }\n))") {
            HapticsGlobalSwitch()
        },
    ])
}

/// Every haptics sample. Keeps the home screen's entry name.
struct HapticsDemo: View {
    static var count: Int { KitGallery.count(HapticsSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Haptics",
            sections: HapticsSamples.sections,
            footnote: "Requires `import KitoHaptics`. The simulator can't play haptics; every sample draws its pattern so you can watch it instead.",
            searchHint: "Try “heartbeat”, “PIN”, “hold”, “compose” or “waveform”."
        )
    }
}
