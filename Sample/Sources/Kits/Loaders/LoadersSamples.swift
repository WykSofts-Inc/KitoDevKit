//
//  LoadersSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoLoaders

// MARK: - Building blocks

/// A soft tile a loader sits on, with a caption under it.
private struct LoadersTile<Content: View>: View {
    var caption: String? = nil
    var dark = false
    var height: CGFloat = 130
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if dark {
                    LinearGradient(colors: [Color(red: 0.07, green: 0.08, blue: 0.16), Color(red: 0.14, green: 0.1, blue: 0.28)], startPoint: .topLeading, endPoint: .bottomTrailing)
                } else {
                    LinearGradient(colors: [Color.primary.opacity(0.03), Color.primary.opacity(0.07)], startPoint: .top, endPoint: .bottom)
                }
                content()
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.primary.opacity(dark ? 0 : 0.06), lineWidth: 1))
            if let caption {
                Text(caption).font(.caption.weight(.medium)).foregroundStyle(.secondary)
            }
        }
    }
}

private struct LoadersPair<A: View, B: View>: View {
    let first: String
    let second: String
    var dark = false
    @ViewBuilder let a: () -> A
    @ViewBuilder let b: () -> B

    var body: some View {
        HStack(spacing: 12) {
            LoadersTile(caption: first, dark: dark, content: a)
            LoadersTile(caption: second, dark: dark, content: b)
        }
    }
}

/// Recent transactions, the real content behind several skeletons.
private struct LoadersTransactions: View {
    private let rows: [(String, String, String, Color)] = [
        ("AO", "Achieng Odhiambo", "−KSh 2,500", .orange),
        ("KP", "KPLC Prepaid", "−KSh 1,000", .yellow),
        ("BO", "Baraka Otieno", "+KSh 4,000", .green),
        ("NW", "Naivas Westlands", "−KSh 3,160", .red),
    ]

    var body: some View {
        VStack(spacing: 20) {
            ForEach(rows, id: \.1) { initials, name, amount, color in
                HStack(spacing: 14) {
                    Text(initials).font(.subheadline.bold()).foregroundStyle(.white)
                        .frame(width: 46, height: 46).background(Circle().fill(color.gradient))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name).font(.subheadline.weight(.semibold))
                        Text("Today · 09:41").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(amount).font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(amount.hasPrefix("+") ? .green : .primary)
                }
            }
        }
    }
}

// MARK: - Samples with state

private struct LoadersSkeletonSwap: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .top) {
                if isLoading {
                    KitoSkeletonView(.listRow, count: 4).transition(.opacity)
                } else {
                    LoadersTransactions().transition(.opacity.combined(with: .offset(y: 6)))
                }
            }
            .frame(minHeight: 260, alignment: .top)
            Button { Task { await load() } } label: {
                Label(isLoading ? "Loading…" : "Reload", systemImage: "arrow.clockwise").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(isLoading)
        }
        .task { await load() }
    }

    private func load() async {
        withAnimation(.easeInOut(duration: 0.3)) { isLoading = true }
        try? await Task.sleep(nanoseconds: 2_200_000_000)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { isLoading = false }
    }
}

private struct LoadersRedactedCard: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill").font(.title3).foregroundStyle(.white)
                        .frame(width: 48, height: 48).background(RoundedRectangle(cornerRadius: 14).fill(Color.orange.gradient))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Mama Oliech Restaurant").font(.headline)
                        Text("Order #KE-2041 · Kilimani").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Text("Pilau, kachumbari and two chapati. Rider Juma picks it up in 8 minutes.")
                    .font(.subheadline).foregroundStyle(.secondary)
                HStack {
                    Text("KSh 850").font(.title3.bold().monospacedDigit())
                    Spacer()
                    Text("Track order").font(.subheadline.weight(.semibold)).padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().fill(Color.primary)).foregroundStyle(Color(.systemBackground))
                }
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.primary.opacity(0.04)))
            .kitoRedacted(isLoading: isLoading)

            Toggle("Loading", isOn: $isLoading.animation()).tint(.primary)
        }
    }
}

private struct LoadersUpload: View {
    @State private var fraction = 0.0

    var body: some View {
        VStack(spacing: 22) {
            HStack(spacing: 12) {
                Image(systemName: "doc.fill").font(.title2).foregroundStyle(.red)
                    .frame(width: 48, height: 48).background(RoundedRectangle(cornerRadius: 14).fill(Color.red.opacity(0.12)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("KRA PIN certificate.pdf").font(.subheadline.weight(.semibold))
                    Text(String(format: "%.1f of 2.4 MB", fraction * 2.4)).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                }
                Spacer()
            }
            KitoLinearProgress(fraction: fraction, height: 8, label: fraction >= 1 ? "Uploaded" : "Uploading", showsPercentage: true)
            KitoLinearProgress(fraction: fraction, height: 4, color: .green)
        }
        .task {
            while !Task.isCancelled {
                fraction = 0
                for step in 1...25 {
                    try? await Task.sleep(nanoseconds: 140_000_000)
                    fraction = Double(step) / 25
                }
                try? await Task.sleep(nanoseconds: 1_400_000_000)
            }
        }
    }
}

private struct LoadersCheckoutSteps: View {
    @State private var step = 1
    private let steps = ["Basket", "Delivery", "Payment", "Done"]

    var body: some View {
        VStack(spacing: 26) {
            KitoStepProgress(steps: steps, current: step)
            Text(step < steps.count ? "Step \(step + 1): \(steps[step])" : "Order placed 🎉")
                .font(.headline)
                .contentTransition(.opacity)
            HStack(spacing: 10) {
                Button("Back") { withAnimation { step = max(step - 1, 0) } }
                    .buttonStyle(.bordered).tint(.primary).disabled(step == 0)
                Button(step >= steps.count - 1 ? "Finish" : "Next") { withAnimation { step = min(step + 1, steps.count) } }
                    .buttonStyle(GalleryPrimaryButtonStyle()).disabled(step >= steps.count)
            }
            if step >= steps.count {
                Button("Start again") { withAnimation { step = 0 } }.font(.footnote.weight(.semibold))
            }
        }
    }
}

/// White-on-photo segments: a translucent track under white fills.
private let loadersStoryTheme: KitoTheme = {
    var theme = KitoTheme.dark
    theme.colors.surfaceMuted = .white.opacity(0.35)
    theme.colors.onBackground = .white
    return theme
}()

private struct LoadersStories: View {
    @State private var current = 0
    @State private var fraction = 0.0
    private let towns = ["Nairobi", "Naivasha", "Nakuru", "Kisumu"]

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [Color(red: 0.98, green: 0.55, blue: 0.3), Color(red: 0.55, green: 0.25, blue: 0.6)], startPoint: .top, endPoint: .bottom)
            Image(systemName: ["building.2.fill", "water.waves", "mountain.2.fill", "sun.horizon.fill"][current % 4])
                .font(.system(size: 90)).foregroundStyle(.white.opacity(0.3))
                .frame(maxHeight: .infinity)
                .contentTransition(.symbolEffect(.replace))
            VStack(alignment: .leading, spacing: 10) {
                KitoStepProgress(steps: towns, current: current, stepFraction: fraction, style: .segments, color: .white)
                    .environment(\.kitoTheme, loadersStoryTheme)
                HStack(spacing: 8) {
                    Circle().fill(.white).frame(width: 28, height: 28).overlay(Text("WN").font(.caption2.bold()).foregroundStyle(.orange))
                    Text("Wycliff N · Road trip").font(.caption.weight(.semibold)).foregroundStyle(.white)
                }
            }
            .padding(14)
        }
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .task {
            while !Task.isCancelled {
                for index in towns.indices {
                    current = index
                    for tick in 0...30 {
                        fraction = Double(tick) / 30
                        try? await Task.sleep(nanoseconds: 60_000_000)
                    }
                }
            }
        }
    }
}

private struct LoadersRing: View {
    @State private var fraction = 0.0

    var body: some View {
        HStack(spacing: 20) {
            KitoProgressRing(fraction: fraction, size: 84, lineWidth: 9, color: .teal)
            VStack(alignment: .leading, spacing: 4) {
                Text("Offline map").font(.headline)
                Text("Nairobi & environs · 86 MB").font(.caption).foregroundStyle(.secondary)
                Text(fraction >= 1 ? "Ready to use offline" : "Downloading…").font(.caption.weight(.semibold)).foregroundStyle(.teal)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.teal.opacity(0.08)))
        .task {
            while !Task.isCancelled {
                fraction = 0
                for step in 1...40 {
                    try? await Task.sleep(nanoseconds: 90_000_000)
                    fraction = Double(step) / 40
                }
                try? await Task.sleep(nanoseconds: 1_500_000_000)
            }
        }
    }
}

private struct LoadersTypingThread: View {
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Circle().fill(LinearGradient(colors: [.teal, .blue], startPoint: .top, endPoint: .bottom)).frame(width: 38, height: 38)
                    .overlay(Text("AW").font(.caption.bold()).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Amani Wanjiru").font(.subheadline.weight(.semibold))
                    HStack(spacing: 5) {
                        Text("typing").font(.caption).foregroundStyle(.green)
                        KitoTypingIndicator(dotSize: 4, dotColor: .green, showsBubble: false)
                    }
                }
                Spacer()
            }
            Divider()
            VStack(spacing: 8) {
                bubble("Umefika Naivasha salama?", mine: false)
                bubble("Eeh! Tumefika saa kumi 😍", mine: true)
                bubble("Tuonane lunch kesho?", mine: false)
            }
            HStack {
                KitoTypingIndicator()
                Spacer()
            }
        }
    }

    private func bubble(_ text: String, mine: Bool) -> some View {
        HStack {
            if mine { Spacer(minLength: 50) }
            Text(text).font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(mine ? Color.blue : Color.primary.opacity(0.07)))
                .foregroundStyle(mine ? .white : .primary)
            if !mine { Spacer(minLength: 50) }
        }
    }
}

private struct LoadersOverlayCheckout: View {
    @State private var phase = 0 // 0 idle, 1 confirming, 2 paid

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                Text("Checkout").font(.largeTitle.bold()).padding(.top, 60)
                VStack(spacing: 12) {
                    ForEach([("Nyama choma (1 kg)", "KSh 1,400"), ("Ugali & kachumbari", "KSh 300"), ("Delivery · Westlands", "KSh 150")], id: \.0) { item, price in
                        HStack { Text(item); Spacer(); Text(price).monospacedDigit().foregroundStyle(.secondary) }.font(.subheadline)
                    }
                    Divider()
                    HStack { Text("Total").font(.headline); Spacer(); Text("KSh 1,850").font(.headline.monospacedDigit()) }
                }
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
                HStack(spacing: 12) {
                    Image(systemName: "iphone.gen3").font(.title3).foregroundStyle(.green)
                        .frame(width: 44, height: 44).background(Circle().fill(Color.green.opacity(0.14)))
                    VStack(alignment: .leading) { Text("M-Pesa").font(.subheadline.weight(.semibold)); Text("0712 ••• 678").font(.caption).foregroundStyle(.secondary) }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
                if phase == 2 {
                    Label("Paid · receipt RKT4H2L9QX", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            Button { Task { await pay() } } label: {
                Text(phase == 2 ? "Pay again" : "Pay KSh 1,850").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .padding(.horizontal, 20).padding(.bottom, 36)
        }
        .kitoLoadingOverlay(isPresented: phase == 1, message: "Confirming payment", detail: "Check your phone for the M-Pesa prompt")
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: phase)
    }

    private func pay() async {
        phase = 1
        try? await Task.sleep(nanoseconds: 2_600_000_000)
        phase = 2
    }
}

private struct LoadersRefreshList: View {
    @State private var arrivals: [(route: String, stage: String, minutes: Int)] = [
        ("46", "Kencom → Kawangware", 3), ("111", "Ngong Road → Karen", 7), ("23", "Odeon → Githurai 45", 9),
        ("58", "Ambassadeur → Buruburu", 12), ("125", "Railways → Rongai", 15), ("33", "Kencom → Embakasi", 18),
    ]
    @State private var updated = "Just now"

    var body: some View {
        KitoRefreshableScrollView(color: .orange, onRefresh: refresh) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Matatu arrivals").font(.largeTitle.bold())
                    Text("Pull down to refresh · updated \(updated)").font(.caption).foregroundStyle(.secondary)
                }
                .padding(.top, 60)
                ForEach(arrivals, id: \.route) { arrival in
                    HStack(spacing: 14) {
                        Text(arrival.route).font(.headline.monospacedDigit()).foregroundStyle(.white)
                            .frame(width: 52, height: 40).background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.gradient))
                        Text(arrival.stage).font(.subheadline.weight(.medium))
                        Spacer()
                        Text("\(arrival.minutes) min").font(.subheadline.monospacedDigit().weight(.semibold)).foregroundStyle(.orange)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func refresh() async {
        try? await Task.sleep(nanoseconds: 1_600_000_000)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            arrivals = arrivals
                .map { (route: $0.route, stage: $0.stage, minutes: max(1, $0.minutes + Int.random(in: -2...2))) }
                .sorted { $0.minutes < $1.minutes }
            updated = Date.now.formatted(date: .omitted, time: .shortened)
        }
    }
}

private struct LoadersKindPicker: View {
    @State private var index = 0
    private let kinds: [(String, KitoLoaderKind)] = [
        ("Spinner", .spinner), ("Dots", .dots), ("Pulse", .pulse), ("Ring", .progressRing(fraction: 0.64)), ("Skeleton", .skeleton),
        ("Bars", .bars), ("Wave", .wave), ("Ripple", .ripple), ("Orbit", .orbit), ("Gradient", .gradientRing),
    ]

    var body: some View {
        VStack(spacing: 18) {
            LoadersTile(height: 150) {
                KitoLoaderView(style: KitoLoaderStyle(kind: kinds[index].1, size: 40, lineWidth: 4))
                    .id(index)
                    .transition(.scale.combined(with: .opacity))
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(kinds.indices, id: \.self) { item in
                        Button { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { index = item } } label: {
                            Text(kinds[item].0).font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(Capsule().fill(index == item ? Color.primary : Color.primary.opacity(0.07)))
                                .foregroundStyle(index == item ? Color(.systemBackground) : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Catalogue

enum LoadersSamples {
    static let sections: [KitSection] = [spinners, playful, chat, skeletons, progress, overlays, configuration]

    static let spinners = KitSection("Spinners", symbol: "circle.dashed", [
        KitSample("Spinner", "The classic arc, in any size or colour.", code: "KitoSpinner()\nKitoSpinner(size: 40, lineWidth: 4, color: .orange)") {
            LoadersPair(first: "Default sizes", second: "On dark", a: {
                HStack(spacing: 22) { KitoSpinner(size: 18); KitoSpinner(size: 28); KitoSpinner(size: 40, lineWidth: 4, color: .orange) }
            }, b: {
                KitoSpinner(size: 40, lineWidth: 4, color: .white)
            })
        },
        KitSample("Gradient ring", "A spinning ring that fades into its colour.", code: "KitoGradientRingLoader(size: 56, lineWidth: 5)\nKitoGradientRingLoader(size: 56, colors: [.clear, .purple, .pink])") {
            LoadersPair(first: "Theme colour", second: "Custom gradient", dark: true, a: {
                KitoGradientRingLoader(size: 56, lineWidth: 5)
            }, b: {
                KitoGradientRingLoader(size: 56, lineWidth: 6, colors: [.clear, .purple, .pink, .orange])
            })
        },
        KitSample("Orbit and ripple", "Background activity: finding a rider, scanning for devices.", code: "KitoOrbitLoader(size: 40)\nKitoRippleLoader(size: 90, ringCount: 4, color: .green)") {
            VStack(spacing: 12) {
                LoadersTile(caption: "Finding a rider near Westlands…", dark: true, height: 180) {
                    ZStack {
                        KitoRippleLoader(size: 150, ringCount: 4, color: .green)
                        Image(systemName: "bicycle").font(.title2.bold()).foregroundStyle(.white)
                            .frame(width: 48, height: 48).background(Circle().fill(Color.green.gradient))
                    }
                }
                LoadersTile(caption: "Orbit", content: { KitoOrbitLoader(size: 40, dotCount: 4) })
            }
        },
        KitSample("Pulse", "A live dot for low-attention status.", code: "HStack {\n    KitoPulseLoader(size: 8, color: .red)\n    Text(\"Live\")\n}") {
            LoadersTile(caption: "Tracking your matatu", height: 110) {
                HStack(spacing: 10) {
                    KitoPulseLoader(size: 9, color: .red)
                    Text("LIVE").font(.caption.bold()).foregroundStyle(.red)
                    Text("Route 46 · 3 stops away").font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(Capsule().fill(Color(.systemBackground)))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
            }
        },
    ])

    static let playful = KitSection("Playful", symbol: "sparkles", [
        KitSample("Dots and wave", "Bouncing in turn, or riding a wave.", code: "KitoDotsLoader(dotSize: 10)\nKitoWaveLoader(dotCount: 5, dotSize: 8)") {
            LoadersPair(first: "Dots", second: "Wave", a: { KitoDotsLoader(dotSize: 11) }, b: { KitoWaveLoader(dotCount: 5, dotSize: 9, color: .pink) })
        },
        KitSample("Equalizer bars", "Reads as “working”, perfect for audio.", code: "KitoBarsLoader(barCount: 5, barWidth: 5, maxHeight: 28, color: .white)") {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14).fill(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64).overlay(Image(systemName: "music.note").font(.title2).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Melanin").font(.headline).foregroundStyle(.white)
                    Text("Sauti Sol · Buffering").font(.caption).foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                KitoBarsLoader(barCount: 5, barWidth: 4, maxHeight: 26, color: .white)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color(red: 0.12, green: 0.1, blue: 0.2)))
        },
        KitSample("Morphing shapes", "Circle, triangle, square, star: one blob flowing between them.", code: "KitoMorphingLoader(size: 64)\nKitoMorphingLoader(size: 64, forms: [.circle, .star], colors: [.orange, .pink])") {
            LoadersPair(first: "Theme", second: "Custom forms", dark: true, a: {
                KitoMorphingLoader(size: 60)
            }, b: {
                KitoMorphingLoader(size: 60, forms: [.circle, .star, .hexagon], colors: [.orange, .pink, .yellow])
            })
        },
        KitSample("Heartbeat", "An ECG trace with a beating heart, for health and fitness.", code: "KitoHeartbeatLoader(width: 170, showsHeart: true)") {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Heart rate", systemImage: "waveform.path.ecg").font(.subheadline.weight(.semibold)).foregroundStyle(.red)
                    Spacer()
                    Text("Measuring…").font(.caption).foregroundStyle(.secondary)
                }
                KitoHeartbeatLoader(width: 190, height: 50, beatsPerMinute: 72, showsHeart: true)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("72").font(.system(size: 40, weight: .bold, design: .rounded))
                    Text("BPM").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                }
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.red.opacity(0.07)))
        },
    ])

    static let chat = KitSection("Chat", symbol: "bubble.left.and.bubble.right", [
        KitSample("Typing indicator", "A bubble with hopping dots, or just the dots inline.", code: "KitoTypingIndicator()\nKitoTypingIndicator(dotSize: 4, dotColor: .green, showsBubble: false)") {
            LoadersTypingThread()
        },
    ])

    static let skeletons = KitSection("Skeletons", symbol: "rectangle.dashed", [
        KitSample("List, then content", "Placeholder rows that give way to the real list.", code: """
        if viewModel.isLoading {
            KitoSkeletonView(.listRow, count: 4)
        } else {
            TransactionsList(viewModel.transactions)
        }
        """) { LoadersSkeletonSwap() },
        KitSample("Feed post", "Header, text, photo and actions.", code: "KitoSkeletonView(.feedPost)") { KitoSkeletonView(.feedPost) },
        KitSample("Profile", "Avatar, name, stats and a button.", code: "KitoSkeletonView(.profile)") { KitoSkeletonView(.profile) },
        KitSample("Product grid", "Two columns of tiles for a catalogue.", code: "KitoSkeletonView(.grid, count: 2)") { KitoSkeletonView(.grid, count: 2) },
        KitSample("Chat thread", "Bubbles on both sides.", code: "KitoSkeletonView(.chat, count: 6, spacing: 12)") { KitoSkeletonView(.chat, count: 6, spacing: 12) },
        KitSample("Article", "Headline, byline, hero image and paragraphs.", code: "KitoSkeletonView(.article)") { KitoSkeletonView(.article) },
        KitSample("Redact real content", "The real card, redacted and shimmering while it loads.", code: "OrderCard(order)\n    .kitoRedacted(isLoading: viewModel.isLoading)") { LoadersRedactedCard() },
    ])

    static let progress = KitSection("Progress", symbol: "chart.bar.fill", [
        KitSample("Indeterminate bar", "Two segments chasing across the track.", code: "KitoLinearProgress()\nKitoLinearProgress(height: 3, color: .orange)") {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Connecting to KPLC…").font(.subheadline.weight(.semibold))
                    KitoLinearProgress()
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Checking your Fuliza limit").font(.subheadline.weight(.semibold))
                    KitoLinearProgress(height: 3, color: .orange)
                }
            }
        },
        KitSample("Upload with percentage", "A determinate bar with a sheen and a live percentage.", code: "KitoLinearProgress(fraction: upload.fraction, label: \"Uploading\", showsPercentage: true)") { LoadersUpload() },
        KitSample("Checkout steps", "Numbered steps ticked off as you go.", code: "KitoStepProgress(steps: [\"Basket\", \"Delivery\", \"Payment\", \"Done\"], current: step)") { LoadersCheckoutSteps() },
        KitSample("Story segments", "Story-style capsules, the current one filling.", code: "KitoStepProgress(steps: towns, current: index, stepFraction: fraction,\n                 style: .segments, color: .white)") { LoadersStories() },
        KitSample("Progress ring", "A determinate ring with its percentage.", code: "KitoProgressRing(fraction: download.fraction, size: 84, lineWidth: 9, color: .teal)") { LoadersRing() },
    ])

    static let overlays = KitSection("Overlays & refresh", symbol: "rectangle.on.rectangle", [
        KitSample("Blocking overlay", "Blurs the screen under a frosted card until the payment confirms.", code: """
        CheckoutView()
            .kitoLoadingOverlay(isPresented: isPaying,
                                message: "Confirming payment",
                                detail: "Check your phone for the M-Pesa prompt")
        """) { ModalStage { LoadersOverlayCheckout() } },
        KitSample("Pull to refresh", "A ring that draws as you pull, then spins.", code: """
        KitoRefreshableScrollView(color: .orange, onRefresh: { await arrivals.reload() }) {
            ForEach(arrivals) { ArrivalRow($0) }
        }
        """) { ModalStage { LoadersRefreshList() } },
    ])

    static let configuration = KitSection("From configuration", symbol: "slider.horizontal.3", [
        KitSample("Loader from a style", "Pick the kind once, as data; every KitoLoaderView follows.", code: "KitoLoaderView(style: KitoLoaderStyle(kind: .orbit, size: 40))") { LoadersKindPicker() },
    ])
}

/// Every loader sample. Keeps the home screen's entry name.
struct LoadersDemo: View {
    static var count: Int { KitGallery.count(LoadersSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Loaders",
            sections: LoadersSamples.sections,
            footnote: "Requires `import KitoLoaders`.",
            searchHint: "Try “skeleton”, “typing”, “overlay”, “steps” or “refresh”."
        )
    }
}
