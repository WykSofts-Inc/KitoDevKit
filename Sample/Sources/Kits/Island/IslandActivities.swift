//
//  IslandActivities.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Combine
import KitoIslandBar

// Each activity owns its state and drives an IslandStage. Timers tick once a second while the
// sample is on screen.

private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

private func clock(_ seconds: Int) -> String { String(format: "%d:%02d", seconds / 60, seconds % 60) }

// MARK: - Music

struct MusicIslandSample: View {
    static let tracks = [
        KitoNowPlayingItem(title: "Midnight Drive", artist: "Neon Coast", artwork: .gradient([.pink, .purple], symbol: "music.note"), duration: 214),
        KitoNowPlayingItem(title: "Savannah Sun", artist: "Kito Collective", artwork: .gradient([.orange, .red], symbol: "sun.max.fill"), duration: 187),
        KitoNowPlayingItem(title: "Blue Hour", artist: "Lake Victoria", artwork: .gradient([.cyan, .blue], symbol: "moon.stars.fill"), duration: 241),
    ]

    @State private var presentation = KitoIslandPresentation.compact
    @State private var index = 0
    @State private var isPlaying = true
    @State private var elapsed: TimeInterval = 42

    private var item: KitoNowPlayingItem { Self.tracks[index] }

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [Color(red: 0.25, green: 0.05, blue: 0.2), .purple, .pink], hint: "Tap the island to expand it; swipe up to shrink") {
            KitoNowPlayingArtworkView(artwork: item.artwork, cornerRadius: 7).frame(width: 26, height: 26)
        } trailing: {
            KitoWaveform(isPlaying: isPlaying, tint: item.artwork.tint).frame(width: 24, height: 16)
        } expanded: {
            KitoNowPlayingExpanded(item: item, isPlaying: $isPlaying, elapsed: $elapsed, onPrevious: { skip(-1) }, onNext: { skip(1) })
        }
        .onReceive(ticker) { _ in
            guard isPlaying else { return }
            if elapsed + 1 >= item.duration { skip(1) } else { elapsed += 1 }
        }
    }

    private func skip(_ step: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            index = (index + step + Self.tracks.count) % Self.tracks.count
            elapsed = 0
        }
    }
}

// MARK: - Timer

struct TimerIslandSample: View {
    @State private var presentation = KitoIslandPresentation.compact
    @State private var remaining = 5 * 60
    @State private var isRunning = true
    private let total = 5 * 60

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [.black, Color(red: 0.3, green: 0.15, blue: 0)]) {
            Image(systemName: "timer").font(.system(size: 15, weight: .bold)).foregroundStyle(.orange)
        } trailing: {
            Text(clock(remaining)).font(.system(size: 14, weight: .semibold).monospacedDigit()).foregroundStyle(.orange).contentTransition(.numericText(countsDown: true))
        } expanded: {
            HStack(spacing: 14) {
                IslandRoundButton(symbol: isRunning ? "pause.fill" : "play.fill", color: .orange.opacity(0.3), foreground: .orange, label: isRunning ? "Pause" : "Resume") { isRunning.toggle() }
                IslandRoundButton(symbol: "xmark", label: "Cancel") { remaining = total; isRunning = false }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Timer").font(.caption).foregroundStyle(.orange)
                    Text(clock(remaining)).font(.system(size: 44, weight: .semibold, design: .rounded).monospacedDigit()).foregroundStyle(.orange)
                        .contentTransition(.numericText(countsDown: true))
                }
            }
        }
        .onReceive(ticker) { _ in
            guard isRunning, remaining > 0 else { return }
            withAnimation { remaining -= 1 }
        }
    }
}

// MARK: - Call

struct CallIslandSample: View {
    @State private var presentation = KitoIslandPresentation.expanded
    @State private var connected = false
    @State private var seconds = 0
    @State private var muted = false

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [Color(red: 0, green: 0.2, blue: 0.1), .black], hint: "Accept to see the compact call timer") {
            Image(systemName: "phone.fill").font(.system(size: 14, weight: .bold)).foregroundStyle(.green)
        } trailing: {
            Text(connected ? clock(seconds) : "Ringing").font(.system(size: 13, weight: .semibold).monospacedDigit()).foregroundStyle(.green)
        } expanded: {
            HStack(spacing: 12) {
                Circle().fill(LinearGradient(colors: [.teal, .blue], startPoint: .top, endPoint: .bottom)).frame(width: 46, height: 46)
                    .overlay(Text("WN").font(.headline).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 2) {
                    Text(connected ? clock(seconds) : "mobile").font(.caption).foregroundStyle(.white.opacity(0.6)).monospacedDigit()
                    Text("Wycliff N").font(.headline).foregroundStyle(.white)
                }
                Spacer()
                if connected {
                    IslandRoundButton(symbol: muted ? "mic.slash.fill" : "mic.fill", color: muted ? .white : .white.opacity(0.18), foreground: muted ? .black : .white, label: "Mute") { muted.toggle() }
                    IslandRoundButton(symbol: "phone.down.fill", color: .red, label: "End") { connected = false; seconds = 0; presentation = .idle }
                } else {
                    IslandRoundButton(symbol: "phone.down.fill", color: .red, label: "Decline") { presentation = .idle }
                    IslandRoundButton(symbol: "phone.fill", color: .green, label: "Accept") { connected = true; presentation = .compact }
                }
            }
        }
        .onReceive(ticker) { _ in if connected { seconds += 1 } }
    }
}

// MARK: - Ride

struct RideIslandSample: View {
    @State private var presentation = KitoIslandPresentation.compact
    @State private var minutes = 6
    @State private var progress = 0.25

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [Color(red: 0.05, green: 0.1, blue: 0.2), Color(red: 0.1, green: 0.3, blue: 0.4)]) {
            Image(systemName: "car.fill").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
        } trailing: {
            Text("\(minutes) min").font(.system(size: 13, weight: .semibold).monospacedDigit()).foregroundStyle(.mint)
        } expanded: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Brian is \(minutes) min away").font(.headline).foregroundStyle(.white)
                        Text("White Toyota Axio · KDA 482K").font(.caption).foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "car.side.fill").font(.system(size: 30)).foregroundStyle(.mint)
                }
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.18)).frame(height: 6)
                        Capsule().fill(.mint).frame(width: geometry.size.width * progress, height: 6)
                        Image(systemName: "car.fill").font(.system(size: 13)).foregroundStyle(.white)
                            .offset(x: geometry.size.width * progress - 8, y: -12)
                        Image(systemName: "mappin.circle.fill").foregroundStyle(.white).offset(x: geometry.size.width - 12)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(height: 30)
            }
        }
        .onReceive(ticker) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                progress = progress >= 0.95 ? 0.25 : progress + 0.05
                minutes = max(1, Int(((1 - progress) * 8).rounded()))
            }
        }
    }
}

// MARK: - Delivery

struct DeliveryIslandSample: View {
    @State private var presentation = KitoIslandPresentation.expanded
    @State private var step = 1
    private let steps = ["Confirmed", "Preparing", "On the way", "Delivered"]

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [Color(red: 0.3, green: 0.1, blue: 0), .orange]) {
            Image(systemName: "bag.fill").font(.system(size: 14, weight: .bold)).foregroundStyle(.orange)
        } trailing: {
            Text(step == 3 ? "Here" : "\(12 - step * 3) min").font(.system(size: 13, weight: .semibold)).foregroundStyle(.orange)
        } expanded: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Mama's Kitchen").font(.headline).foregroundStyle(.white)
                    Spacer()
                    Text(steps[step]).font(.subheadline.weight(.semibold)).foregroundStyle(.orange).contentTransition(.opacity)
                }
                HStack(spacing: 6) {
                    ForEach(steps.indices, id: \.self) { index in
                        Capsule().fill(index <= step ? Color.orange : .white.opacity(0.18)).frame(height: 5)
                    }
                }
                HStack {
                    Image(systemName: "fork.knife")
                    Spacer()
                    Image(systemName: "bicycle")
                    Spacer()
                    Image(systemName: "house.fill")
                }
                .font(.caption).foregroundStyle(.white.opacity(0.6))
            }
        }
        .onReceive(ticker) { tick in
            if Int(tick.timeIntervalSince1970) % 3 == 0 { withAnimation(.spring) { step = (step + 1) % steps.count } }
        }
    }
}

// MARK: - Upload

struct UploadIslandSample: View {
    @State private var presentation = KitoIslandPresentation.compact
    @State private var progress = 0.1

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [.black, .indigo]) {
            ZStack {
                Circle().stroke(.white.opacity(0.25), lineWidth: 3)
                Circle().trim(from: 0, to: progress).stroke(.cyan, style: StrokeStyle(lineWidth: 3, lineCap: .round)).rotationEffect(.degrees(-90))
            }
            .frame(width: 20, height: 20)
        } trailing: {
            Text(progress.formatted(.percent.precision(.fractionLength(0)))).font(.system(size: 13, weight: .semibold).monospacedDigit()).foregroundStyle(.cyan)
        } expanded: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "doc.fill").font(.title2).foregroundStyle(.cyan)
                    VStack(alignment: .leading) {
                        Text("Holiday-video.mov").font(.headline).foregroundStyle(.white)
                        Text("\(Int(progress * 412)) of 412 MB").font(.caption).foregroundStyle(.white.opacity(0.6)).monospacedDigit()
                    }
                    Spacer()
                    IslandRoundButton(symbol: "xmark", size: 36, label: "Cancel upload") { progress = 0 }
                }
                ProgressView(value: progress).tint(.cyan)
            }
        }
        .onReceive(ticker) { _ in withAnimation(.easeInOut) { progress = progress >= 1 ? 0 : min(progress + 0.07, 1) } }
    }
}

// MARK: - Recording

struct RecordingIslandSample: View {
    @State private var presentation = KitoIslandPresentation.compact
    @State private var seconds = 0
    @State private var pulse = false

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [.black, Color(red: 0.3, green: 0, blue: 0)]) {
            Circle().fill(.red).frame(width: 10, height: 10).opacity(pulse ? 0.35 : 1)
        } trailing: {
            Text(clock(seconds)).font(.system(size: 13, weight: .semibold).monospacedDigit()).foregroundStyle(.red)
        } expanded: {
            HStack(spacing: 14) {
                IslandRoundButton(symbol: "stop.fill", color: .red, label: "Stop recording") { seconds = 0; presentation = .idle }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Voice memo").font(.headline).foregroundStyle(.white)
                    Text(clock(seconds)).font(.subheadline.monospacedDigit()).foregroundStyle(.red)
                }
                Spacer()
                KitoWaveform(isPlaying: true, tint: .red, barCount: 7).frame(width: 70, height: 30)
            }
        }
        .onAppear { withAnimation(.easeInOut(duration: 0.8).repeatForever()) { pulse = true } }
        .onReceive(ticker) { _ in seconds += 1 }
    }
}

// MARK: - Navigation

struct NavigationIslandSample: View {
    @State private var presentation = KitoIslandPresentation.compact
    @State private var metres = 400

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [Color(red: 0, green: 0.15, blue: 0.1), Color(red: 0.05, green: 0.35, blue: 0.2)]) {
            Image(systemName: "arrow.turn.up.right").font(.system(size: 16, weight: .bold)).foregroundStyle(.green)
        } trailing: {
            Text("\(metres) m").font(.system(size: 13, weight: .semibold).monospacedDigit()).foregroundStyle(.green)
        } expanded: {
            HStack(spacing: 14) {
                Image(systemName: "arrow.turn.up.right").font(.system(size: 40, weight: .bold)).foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(metres) m").font(.title2.bold().monospacedDigit()).foregroundStyle(.white)
                    Text("Turn right onto Kenyatta Ave").font(.subheadline).foregroundStyle(.white.opacity(0.7))
                    Text("Arrive 9:58 · 12 min").font(.caption).foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
            }
        }
        .onReceive(ticker) { _ in withAnimation { metres = metres <= 20 ? 400 : metres - 20 } }
    }
}

// MARK: - Sports

struct ScoreIslandSample: View {
    @State private var presentation = KitoIslandPresentation.compact
    @State private var home = 1
    @State private var away = 1
    @State private var minute = 67

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [Color(red: 0, green: 0.2, blue: 0), .black]) {
            HStack(spacing: 4) { badge("GOR", .green); Text("\(home)").font(.system(size: 14, weight: .bold).monospacedDigit()).foregroundStyle(.white) }
        } trailing: {
            HStack(spacing: 4) { Text("\(away)").font(.system(size: 14, weight: .bold).monospacedDigit()).foregroundStyle(.white); badge("AFC", .blue) }
        } expanded: {
            VStack(spacing: 8) {
                Text("Premier League · \(minute)'").font(.caption.weight(.semibold)).foregroundStyle(.green)
                HStack {
                    VStack { badge("GOR", .green, size: 40); Text("Gor Mahia").font(.caption).foregroundStyle(.white.opacity(0.7)) }
                    Spacer()
                    Text("\(home) – \(away)").font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit()).foregroundStyle(.white).contentTransition(.numericText())
                    Spacer()
                    VStack { badge("AFC", .blue, size: 40); Text("AFC Leopards").font(.caption).foregroundStyle(.white.opacity(0.7)) }
                }
            }
        }
        .onReceive(ticker) { tick in
            minute = minute >= 90 ? 1 : minute + 1
            if Int(tick.timeIntervalSince1970) % 7 == 0 { withAnimation(.spring) { if Bool.random() { home += 1 } else { away += 1 } } }
        }
    }

    private func badge(_ text: String, _ color: Color, size: CGFloat = 22) -> some View {
        Circle().fill(color).frame(width: size, height: size)
            .overlay(Text(text.prefix(1)).font(.system(size: size * 0.45, weight: .heavy)).foregroundStyle(.white))
    }
}

// MARK: - Flight

struct FlightIslandSample: View {
    @State private var presentation = KitoIslandPresentation.expanded

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [Color(red: 0.05, green: 0.1, blue: 0.3), Color(red: 0.3, green: 0.5, blue: 0.9)]) {
            Image(systemName: "airplane").font(.system(size: 14, weight: .bold)).foregroundStyle(.cyan)
        } trailing: {
            Text("B12").font(.system(size: 13, weight: .bold)).foregroundStyle(.cyan)
        } expanded: {
            VStack(spacing: 10) {
                HStack {
                    Text("KQ 100 · Boarding").font(.caption.weight(.semibold)).foregroundStyle(.cyan)
                    Spacer()
                    Text("Gate B12 · Seat 14A").font(.caption).foregroundStyle(.white.opacity(0.6))
                }
                HStack {
                    VStack(alignment: .leading) { Text("NBO").font(.title.bold()); Text("23:55").font(.caption) }
                    Spacer()
                    Image(systemName: "airplane").font(.title3).foregroundStyle(.cyan)
                    Spacer()
                    VStack(alignment: .trailing) { Text("LHR").font(.title.bold()); Text("06:15").font(.caption) }
                }
                .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Workout

struct WorkoutIslandSample: View {
    @State private var presentation = KitoIslandPresentation.compact
    @State private var heartRate = 128
    @State private var seconds = 1_284

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: [.black, Color(red: 0.3, green: 0, blue: 0.15)]) {
            Image(systemName: "figure.run").font(.system(size: 15, weight: .bold)).foregroundStyle(.green)
        } trailing: {
            HStack(spacing: 3) {
                Image(systemName: "heart.fill").font(.system(size: 10)).foregroundStyle(.red).symbolEffect(.pulse)
                Text("\(heartRate)").font(.system(size: 13, weight: .semibold).monospacedDigit()).foregroundStyle(.white)
            }
        } expanded: {
            HStack(spacing: 18) {
                ZStack {
                    ring(0.78, .red, 64); ring(0.55, .green, 46); ring(0.9, .cyan, 28)
                }
                .frame(width: 70, height: 70)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Outdoor Run").font(.headline).foregroundStyle(.green)
                    Text(clock(seconds)).font(.title2.bold().monospacedDigit()).foregroundStyle(.white)
                    Text("\(heartRate) BPM · 4.2 km").font(.caption).foregroundStyle(.white.opacity(0.6)).monospacedDigit()
                }
                Spacer()
            }
        }
        .onReceive(ticker) { _ in seconds += 1; heartRate = min(max(heartRate + Int.random(in: -3...3), 110), 170) }
    }

    private func ring(_ value: Double, _ color: Color, _ size: CGFloat) -> some View {
        ZStack {
            Circle().stroke(color.opacity(0.25), lineWidth: 7)
            Circle().trim(from: 0, to: value).stroke(color, style: StrokeStyle(lineWidth: 7, lineCap: .round)).rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Moments (short-lived)

/// A one-off moment the island plays and then settles from: connections, payments, toggles.
struct MomentIslandSample<Leading: View, Trailing: View, Expanded: View>: View {
    let trigger: String
    let settlesTo: KitoIslandPresentation
    var wallpaper: [Color]?
    @ViewBuilder let leading: () -> Leading
    @ViewBuilder let trailing: () -> Trailing
    @ViewBuilder let expanded: () -> Expanded

    @State private var presentation = KitoIslandPresentation.idle

    var body: some View {
        IslandStage(presentation: $presentation, wallpaper: wallpaper, leading: leading, trailing: trailing, expanded: expanded) {
            Button(trigger) { flash($presentation, to: settlesTo) }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(.primary)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { flash($presentation, to: settlesTo) }
        }
    }
}
