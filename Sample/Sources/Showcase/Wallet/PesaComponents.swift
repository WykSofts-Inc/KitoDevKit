//
//  PesaComponents.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoNavigation
import KitoFormatting
import KitoHaptics

extension WalletShowcase {
    /// "Exit demo", shown on the lock screen and in every tab's toolbar.
    struct PesaExitButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Label("Exit demo", systemImage: "xmark")
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Exit the Pesa demo")
        }
    }

    /// Adds the Exit demo button to a tab's navigation bar.
    struct PesaExitToolbar: ViewModifier {
        @Environment(\.pesaExit) private var exit

        func body(content: Content) -> some View {
            content.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { exit() } label: {
                        Label("Exit demo", systemImage: "xmark.circle.fill")
                            .labelStyle(.titleAndIcon)
                            .font(.subheadline.weight(.semibold))
                    }
                    .tint(.primary)
                    .accessibilityLabel("Exit the Pesa demo")
                }
            }
        }
    }

    /// A rounded surface that reads on grouped backgrounds in light and dark.
    struct PesaCardBackground: ViewModifier {
        var padding: CGFloat = 16

        func body(content: Content) -> some View {
            content
                .padding(padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: PesaStyle.cardCorner, style: .continuous))
        }
    }

    struct PesaSectionHeader: View {
        let title: String
        var actionTitle: String?
        var action: (() -> Void)?

        var body: some View {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .font(.subheadline.weight(.semibold))
                        .tint(.secondary)
                }
            }
        }
    }

    /// A person's initials, or a category symbol on a tinted tile.
    struct PesaTransactionIcon: View {
        let transaction: PesaTransaction
        let contact: PesaContact?
        var size: CGFloat = 44

        var body: some View {
            if let contact {
                KitoAvatar(initials: contact.initials, colors: [contact.color, contact.color.opacity(0.65)], size: size)
            } else {
                Image(systemName: transaction.symbol)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(transaction.category.color)
                    .frame(width: size, height: size)
                    .background(transaction.category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
            }
        }
    }

    struct PesaTransactionRow: View {
        let transaction: PesaTransaction
        let contact: PesaContact?
        var isHidden = false

        var body: some View {
            HStack(spacing: 12) {
                PesaTransactionIcon(transaction: transaction, contact: contact)
                VStack(alignment: .leading, spacing: 2) {
                    Text(transaction.title)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                Text(isHidden ? "••••" : PesaMoney.signed(transaction.amount))
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(transaction.isIncoming ? PesaStyle.positive : .primary)
            }
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(transaction.title), \(transaction.category.title), \(KitoDateFormatting.dayLabel(transaction.date))")
            .accessibilityValue(isHidden ? "Amount hidden" : PesaMoney.signed(transaction.amount))
        }

        private var subtitle: String {
            "\(transaction.category.title) · \(KitoDateFormatting.dayLabel(transaction.date)), \(KitoDateFormatting.shortTime(transaction.date))"
        }
    }

    /// A progress ring that fills in when it appears, or at once with Reduce Motion.
    struct PesaRing: View {
        let progress: Double
        var color: Color
        var lineWidth: CGFloat = 10

        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var shown: Double = 0

        var body: some View {
            ZStack {
                Circle().stroke(color.opacity(0.15), lineWidth: lineWidth)
                Circle()
                    .trim(from: 0, to: shown)
                    .stroke(AngularGradient(colors: [color.opacity(0.7), color], center: .center),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .onAppear { animate(to: progress) }
            .onChange(of: progress) { _, value in animate(to: value) }
            .accessibilityHidden(true)
        }

        private func animate(to value: Double) {
            if reduceMotion { shown = value } else {
                withAnimation(.spring(response: 1.1, dampingFraction: 0.85).delay(0.15)) { shown = value }
            }
        }
    }

    /// A thin bar showing how much of a limit is used; turns red past it.
    struct PesaProgressBar: View {
        let fraction: Double
        var color: Color

        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var shown: Double = 0

        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.08))
                    Capsule()
                        .fill(fraction > 1 ? Color.red : color)
                        .frame(width: geometry.size.width * min(shown, 1))
                }
            }
            .frame(height: 8)
            .onAppear { update(fraction) }
            .onChange(of: fraction) { _, value in update(value) }
            .accessibilityHidden(true)
        }

        private func update(_ value: Double) {
            if reduceMotion { shown = value } else { withAnimation(.easeOut(duration: 0.8)) { shown = value } }
        }
    }

    /// A round quick action: an icon in a circle with a caption.
    struct PesaQuickAction: View {
        let title: String
        let systemImage: String
        let action: () -> Void

        var body: some View {
            Button {
                KitoHaptics.impact(.light)
                action()
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 56, height: 56)
                        .background(Color(.secondarySystemGroupedBackground), in: Circle())
                        .overlay(Circle().strokeBorder(Color.primary.opacity(0.06)))
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PesaPressStyle())
            .accessibilityLabel(title)
        }
    }

    /// Shrinks a little under the finger.
    struct PesaPressStyle: ButtonStyle {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed && !reduceMotion ? 0.94 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
        }
    }

    /// Frost that spreads over a frozen card: an icy wash, a crystalline edge and drifting flakes.
    struct PesaFrostOverlay: View {
        let isFrozen: Bool

        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var spread: CGFloat = 0

        var body: some View {
            GeometryReader { geometry in
                let size = geometry.size
                ZStack {
                    LinearGradient(colors: [.white.opacity(0.85), Color(red: 0.75, green: 0.9, blue: 1).opacity(0.7), .white.opacity(0.55)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    PesaFrostCrystals()
                        .stroke(.white.opacity(0.8), lineWidth: 1)
                        .blendMode(.overlay)
                    if !reduceMotion {
                        TimelineView(.animation(minimumInterval: 1 / 30, paused: !isFrozen)) { context in
                            PesaSnowfall(time: context.date.timeIntervalSinceReferenceDate, size: size)
                        }
                    }
                    Image(systemName: "snowflake")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(Color(red: 0.2, green: 0.45, blue: 0.75))
                        .shadow(color: .white, radius: 6)
                        .scaleEffect(spread)
                        .rotationEffect(.degrees(Double(spread) * 90))
                }
                .mask {
                    Circle()
                        .frame(width: max(size.width, size.height) * 2.4 * spread)
                        .position(x: size.width * 0.15, y: size.height * 0.2)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .allowsHitTesting(false)
            .onAppear { spread = isFrozen ? 1 : 0 }
            .onChange(of: isFrozen) { _, frozen in
                if reduceMotion {
                    withAnimation(.easeInOut(duration: 0.2)) { spread = frozen ? 1 : 0 }
                } else {
                    withAnimation(frozen ? .easeOut(duration: 0.9) : .easeIn(duration: 0.5)) { spread = frozen ? 1 : 0 }
                }
            }
            .accessibilityHidden(true)
        }
    }

    private struct PesaFrostCrystals: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let branches = [(0.08, 0.15), (0.3, 0.05), (0.55, 0.12), (0.82, 0.08), (0.92, 0.6), (0.7, 0.9), (0.4, 0.85), (0.1, 0.7)]
            for (index, point) in branches.enumerated() {
                let origin = CGPoint(x: rect.width * point.0, y: rect.height * point.1)
                let length = rect.width * (0.08 + Double(index % 3) * 0.03)
                for spoke in 0..<6 {
                    let angle = Double(spoke) * .pi / 3 + Double(index) * 0.4
                    let end = CGPoint(x: origin.x + cos(angle) * length, y: origin.y + sin(angle) * length)
                    path.move(to: origin)
                    path.addLine(to: end)
                    let mid = CGPoint(x: (origin.x + end.x) / 2, y: (origin.y + end.y) / 2)
                    for side in [-1.0, 1.0] {
                        path.move(to: mid)
                        path.addLine(to: CGPoint(x: mid.x + cos(angle + side * 0.7) * length * 0.35,
                                                 y: mid.y + sin(angle + side * 0.7) * length * 0.35))
                    }
                }
            }
            return path
        }
    }

    private struct PesaSnowfall: View {
        let time: TimeInterval
        let size: CGSize

        var body: some View {
            Canvas { context, canvasSize in
                for index in 0..<26 {
                    let seed = Double(index) * 12.9898
                    let speed = 10 + (sin(seed) + 1) * 9
                    let x = (sin(seed * 3.1) + 1) / 2 * canvasSize.width + sin(time + seed) * 6
                    let y = (time * speed + seed * 37).truncatingRemainder(dividingBy: canvasSize.height + 10) - 5
                    let radius = 1 + (cos(seed) + 1) * 1.1
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)), with: .color(.white.opacity(0.9)))
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }
}

extension View {
    func pesaSurface(padding: CGFloat = 16) -> some View {
        modifier(WalletShowcase.PesaCardBackground(padding: padding))
    }

    func pesaExitToolbar() -> some View {
        modifier(WalletShowcase.PesaExitToolbar())
    }
}
