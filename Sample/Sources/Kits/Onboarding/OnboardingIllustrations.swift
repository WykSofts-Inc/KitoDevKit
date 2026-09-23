//
//  OnboardingIllustrations.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCharts

// Drawn in SwiftUI rather than shipped as images, so they scale, theme and animate.

/// A big symbol on a soft blob, with confetti shapes drifting around it: the flat, playful
/// illustration style of most onboarding flows.
struct ConfettiIllustration: View {
    let symbol: String
    var tint: Color = .orange
    var blob: Color = Color.orange.opacity(0.15)
    var ink: Color = .primary

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drift = false

    private struct Piece: Identifiable {
        let id = UUID()
        let kind: Int
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let rotation: Double
    }

    private let pieces: [Piece] = [
        Piece(kind: 0, x: -0.38, y: -0.34, size: 18, rotation: 12),
        Piece(kind: 1, x: 0.36, y: -0.4, size: 20, rotation: 45),
        Piece(kind: 2, x: 0.42, y: 0.18, size: 14, rotation: 0),
        Piece(kind: 3, x: -0.44, y: 0.26, size: 8, rotation: 0),
        Piece(kind: 0, x: 0.1, y: 0.46, size: 12, rotation: -20),
        Piece(kind: 3, x: -0.12, y: -0.48, size: 6, rotation: 0),
        Piece(kind: 2, x: -0.3, y: 0.48, size: 10, rotation: 0),
        Piece(kind: 1, x: 0.46, y: -0.08, size: 10, rotation: 30),
    ]

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            ZStack {
                Circle().fill(blob).frame(width: side * 0.72, height: side * 0.72)
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(tint)
                    .frame(width: side * 0.4, height: side * 0.4)
                ForEach(pieces) { piece in
                    shape(piece)
                        .frame(width: piece.size, height: piece.size)
                        .rotationEffect(.degrees(piece.rotation + (drift ? 25 : 0)))
                        .offset(x: piece.x * side, y: piece.y * side + (drift ? -6 : 6))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { drift = true }
        }
    }

    @ViewBuilder
    private func shape(_ piece: Piece) -> some View {
        switch piece.kind {
        case 0: RoundedRectangle(cornerRadius: 3).stroke(tint, lineWidth: 3)
        case 1: Rectangle().stroke(ink.opacity(0.7), lineWidth: 2.5).rotationEffect(.degrees(45))
        case 2: Circle().stroke(ink.opacity(0.6), lineWidth: 2.5)
        default: Circle().fill(tint)
        }
    }
}

/// Small symbols orbiting a central one: for "connect", "sync" or "everything in one place".
struct OrbitIllustration: View {
    let center: String
    let satellites: [String]
    var tint: Color = .blue

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var angle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let radius = side * 0.36
            ZStack {
                Circle().stroke(tint.opacity(0.18), style: StrokeStyle(lineWidth: 1.5, dash: [4, 6])).frame(width: radius * 2, height: radius * 2)
                Circle().fill(tint.opacity(0.14)).frame(width: side * 0.36, height: side * 0.36)
                Image(systemName: center).font(.system(size: side * 0.16, weight: .semibold)).foregroundStyle(tint)
                ForEach(Array(satellites.enumerated()), id: \.offset) { index, name in
                    let theta = (Double(index) / Double(max(satellites.count, 1))) * 2 * .pi + angle
                    Image(systemName: name)
                        .font(.system(size: side * 0.07, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: side * 0.15, height: side * 0.15)
                        .background(Circle().fill(tint))
                        .shadow(color: tint.opacity(0.4), radius: 8, y: 4)
                        .offset(x: cos(theta) * radius, y: sin(theta) * radius)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 24).repeatForever(autoreverses: false)) { angle = 2 * .pi }
        }
    }
}

/// A fanned stack of payment cards.
struct CardStackIllustration: View {
    var colors: [Color] = [Color(red: 0.6, green: 0.55, blue: 0.95), Color(red: 0.62, green: 0.85, blue: 0.4), Color(white: 0.92)]

    var body: some View {
        ZStack {
            ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                let fromTop = Double(colors.count - 1 - index)
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(color)
                    .overlay(alignment: .topLeading) {
                        Image(systemName: ["creditcard.fill", "wave.3.right", "banknote.fill"][index % 3])
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.black.opacity(0.55))
                            .padding(18)
                    }
                    .overlay(alignment: .bottomLeading) {
                        Text("•••• \(4_210 + index * 1_137)")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundStyle(.black.opacity(0.6))
                            .padding(18)
                    }
                    .frame(width: 240, height: 150)
                    .rotationEffect(.degrees(-8 + fromTop * 7))
                    .offset(x: fromTop * -18, y: fromTop * -26)
                    .shadow(color: .black.opacity(0.18), radius: 14, y: 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A trend card built from KitoCharts, for finance and analytics flows.
struct TrendCardIllustration: View {
    var tint: Color = .green

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Portfolio").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            Text("$12,480").font(.title.bold().monospacedDigit())
            Text("▲ 8.2% this month").font(.caption.bold()).foregroundStyle(tint)
            LineHost(ChartsData.walk(count: 30, start: 60, volatility: 5, drift: 1, seed: 77), style: .sparkline, height: 90)
                .kitoChartTheme(KitoChartTheme(categoricalPalette: [tint]))
        }
        .padding(20)
        .frame(width: 260)
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.15), radius: 24, y: 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// An activity ring filling up, for fitness and goal flows.
struct RingIllustration: View {
    var progress: Double = 0.72
    var colors: [Color] = [.pink, .orange]
    var symbol = "figure.run"

    @State private var shown = false

    var body: some View {
        ZStack {
            Circle().stroke(colors[0].opacity(0.18), lineWidth: 22)
            Circle()
                .trim(from: 0, to: shown ? progress : 0.02)
                .stroke(AngularGradient(colors: colors + [colors[0]], center: .center), style: StrokeStyle(lineWidth: 22, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: symbol).font(.system(size: 54, weight: .semibold)).foregroundStyle(colors[0])
        }
        .padding(24)
        .aspectRatio(1, contentMode: .fit)
        .onAppear { withAnimation(.spring(response: 1.4, dampingFraction: 0.8).delay(0.2)) { shown = true } }
    }
}

/// A phone showing a skeleton of the app, for "here's how it works" pages.
struct PhoneMockIllustration: View {
    var tint: Color = .indigo

    var body: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(Color(.systemBackground))
            .overlay {
                VStack(alignment: .leading, spacing: 12) {
                    Capsule().fill(Color.primary.opacity(0.12)).frame(width: 70, height: 8)
                    RoundedRectangle(cornerRadius: 16).fill(tint.gradient).frame(height: 90)
                        .overlay(alignment: .bottomLeading) {
                            Text("Good morning").font(.subheadline.bold()).foregroundStyle(.white).padding(12)
                        }
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 10) {
                            Circle().fill(tint.opacity(0.25 + Double(row) * 0.15)).frame(width: 30, height: 30)
                            VStack(alignment: .leading, spacing: 5) {
                                Capsule().fill(Color.primary.opacity(0.14)).frame(width: 110, height: 8)
                                Capsule().fill(Color.primary.opacity(0.08)).frame(width: 70, height: 6)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(16)
            }
            .overlay(RoundedRectangle(cornerRadius: 34, style: .continuous).stroke(Color.primary.opacity(0.15), lineWidth: 6))
            .frame(width: 190, height: 330)
            .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Product chips floating around a bag: for shopping flows.
struct ShoppingIllustration: View {
    var tint: Color = .black
    var accent: Color = .orange

    var body: some View {
        ZStack {
            ConfettiIllustration(symbol: "bag.fill", tint: tint, blob: accent.opacity(0.18), ink: tint)
            tag("tshirt.fill", "$24").offset(x: -92, y: -70)
            tag("shoeprint.fill", "$89").offset(x: 96, y: -30)
            tag("eyeglasses", "$140").offset(x: -70, y: 96)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func tag(_ symbol: String, _ price: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
            Text(price).font(.caption.bold())
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
        .background(Capsule().fill(.ultraThinMaterial))
        .background(Capsule().fill(accent.opacity(0.18)))
        .overlay(Capsule().stroke(tint.opacity(0.25), lineWidth: 1))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        .foregroundStyle(tint)
    }
}

/// Deterministic photo backgrounds from Lorem Picsum (Unsplash-licensed images): the same seed
/// always gives the same photo, so the samples look identical on every launch.
enum OnboardingPhotos {
    static func url(_ seed: String) -> URL {
        URL(string: "https://picsum.photos/seed/kito-\(seed)/900/1800")!
    }
}
