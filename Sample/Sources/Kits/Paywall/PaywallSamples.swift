//
//  PaywallSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoPaywall

// MARK: - Shared pieces

/// Offline plans, so every layout works without App Store Connect.
private enum PaywallMockPlans {
    static let standard = KitoPaywallPlan.previewPlans

    static let trio = KitoPaywallPlan.arranged([
        KitoPaywallPlan(id: "mock.monthly", price: 9.99, period: .monthly, trial: .weekly),
        KitoPaywallPlan(id: "mock.yearly", price: 59.99, period: .yearly, trial: .weekly),
        KitoPaywallPlan(id: "mock.lifetime", price: 149.99, period: nil),
    ], mostPopular: "mock.yearly")

    static let pair = KitoPaywallPlan.arranged([
        KitoPaywallPlan(id: "mock.monthly", price: 9.99, period: .monthly, trial: .weekly),
        KitoPaywallPlan(id: "mock.yearly", price: 59.99, period: .yearly, trial: .weekly),
    ], mostPopular: "mock.yearly")

    static let single = [KitoPaywallPlan(id: "mock.yearly", price: 59.99, period: .yearly, trial: .weekly)]

    static let shillings = KitoPaywallPlan.arranged([
        KitoPaywallPlan(id: "ke.weekly", price: 49, currencyCode: "KES", period: .weekly),
        KitoPaywallPlan(id: "ke.monthly", price: 99, currencyCode: "KES", period: .monthly, trial: .weekly),
        KitoPaywallPlan(id: "ke.yearly", price: 429, currencyCode: "KES", period: .yearly, trial: .weekly),
    ], mostPopular: "ke.yearly")
}

/// The real products in KitoSample.storekit.
private enum PaywallSampleProducts {
    static let weekly = "com.wyksoftsinc.kitosample.pro.weekly"
    static let monthly = "com.wyksoftsinc.kitosample.pro.monthly"
    static let yearly = "com.wyksoftsinc.kitosample.pro.yearly"
    static let lifetime = "com.wyksoftsinc.kitosample.lifetime"
    static let all = [weekly, monthly, yearly, lifetime]
}

private extension KitoPaywallContent {
    static let sample = KitoPaywallContent(
        termsURL: URL(string: "https://wyksoftsinc.com/terms"),
        privacyURL: URL(string: "https://wyksoftsinc.com/privacy")
    )

    static let design = KitoPaywallContent(
        title: "Design without limits",
        subtitle: "Every tool, every template, every export.",
        symbol: "paintbrush.pointed.fill",
        features: [
            KitoPaywallFeature("Unlimited projects", detail: "Start as many as you like.", symbol: "folder.fill", free: .limited("3")),
            KitoPaywallFeature("4K export", detail: "Crisp on every screen.", symbol: "arrow.up.right.square.fill", free: .limited("1080p")),
            KitoPaywallFeature("Premium templates", detail: "Hundreds, updated weekly.", symbol: "square.grid.2x2.fill"),
            KitoPaywallFeature("Brand kits", detail: "Your fonts and colours, everywhere.", symbol: "paintpalette.fill"),
            KitoPaywallFeature("Cloud sync", detail: "Pick up on any device.", symbol: "icloud.fill", free: .included),
        ],
        termsURL: URL(string: "https://wyksoftsinc.com/terms"),
        privacyURL: URL(string: "https://wyksoftsinc.com/privacy")
    )

    static let fitness = KitoPaywallContent(
        title: "Train without limits",
        subtitle: "Plans that adapt to you, every single week.",
        symbol: "figure.run",
        features: [
            KitoPaywallFeature("Personal plans", detail: "Built around your goals.", symbol: "target"),
            KitoPaywallFeature("500+ workouts", detail: "From 5-minute stretches to HIIT.", symbol: "flame.fill"),
            KitoPaywallFeature("Apple Watch", detail: "Heart rate zones, live.", symbol: "applewatch"),
            KitoPaywallFeature("Progress insights", detail: "See how far you've come.", symbol: "chart.line.uptrend.xyaxis"),
        ],
        planPicker: .chips,
        celebrationTitle: "Let's go!",
        celebrationMessage: "Your personal plan is ready."
    )

    static let calm = KitoPaywallContent(
        title: "Breathe easier",
        subtitle: "Try every meditation free for a week.",
        symbol: "leaf.fill",
        features: [
            KitoPaywallFeature("Sleep stories", symbol: "moon.stars.fill"),
            KitoPaywallFeature("Guided courses", symbol: "figure.mind.and.body"),
            KitoPaywallFeature("Offline listening", symbol: "arrow.down.circle.fill"),
        ],
        celebrationTitle: "Welcome in",
        celebrationMessage: "Take a deep breath. Everything is unlocked."
    )
}

/// A paywall on its own preview store: purchases "succeed" after a moment, no App Store needed.
private struct PaywallPreviewScreen: View {
    let style: KitoPaywallStyle
    let content: KitoPaywallContent
    let tint: Color?
    @State private var store: KitoStore

    init(_ style: KitoPaywallStyle, plans: [KitoPaywallPlan] = PaywallMockPlans.standard, content: KitoPaywallContent = .sample, tint: Color? = nil) {
        self.style = style
        self.content = content
        self.tint = tint
        _store = State(initialValue: KitoStore.preview(plans: plans))
    }

    var body: some View {
        KitoPaywall(store: store, style: style, content: content, tint: tint)
    }
}

/// A plausible app screen with a button that opens the paywall.
private struct PaywallMockScreen<Trigger: View>: View {
    var title = "Journal"
    var tint: Color = .indigo
    @ViewBuilder let trigger: () -> Trigger

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [tint.opacity(0.22), Color(.systemBackground)], startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 14) {
                Text(title).font(.largeTitle.bold()).padding(.top, 56)
                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(tint.gradient).frame(height: 140)
                    .overlay(alignment: .bottomLeading) {
                        Text("Today's entry").font(.title3.bold()).foregroundStyle(.white).padding(16)
                    }
                ForEach(0..<3, id: \.self) { index in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12).fill(tint.opacity(0.2 + Double(index) * 0.15)).frame(width: 46, height: 46)
                        VStack(alignment: .leading, spacing: 6) {
                            Capsule().fill(Color.primary.opacity(0.18)).frame(width: 150, height: 9)
                            Capsule().fill(Color.primary.opacity(0.09)).frame(width: 90, height: 7)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            trigger().padding(.horizontal, 20).padding(.bottom, 36)
        }
    }
}

// MARK: - Plan pickers

private struct PaywallPickerDemo: View {
    let plans: [KitoPaywallPlan]
    let style: KitoPlanPickerStyle
    var tint: Color? = nil
    var showsPerWeek = false
    @State private var selection: String?

    private var selected: KitoPaywallPlan? {
        plans.first { $0.id == selection } ?? KitoPaywallPlan.defaultSelection(in: plans)
    }

    var body: some View {
        VStack(spacing: 18) {
            KitoPlanPicker(plans: plans, selection: $selection, style: style, tint: tint)
            if let plan = selected {
                VStack(spacing: 4) {
                    if showsPerWeek, let perWeek = plan.pricePerWeekText {
                        Text(perWeek).font(.title3.bold().monospacedDigit()).contentTransition(.numericText())
                    }
                    Text(plan.terms).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }
                .animation(.snappy, value: plan.id)
            }
        }
        .padding(.top, 8)
        .onAppear { if selection == nil { selection = KitoPaywallPlan.defaultSelection(in: plans)?.id } }
    }
}

// MARK: - Building blocks

private struct PaywallButtonDemo: View {
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            KitoPaywallButton("Start 7-day free trial", subtitle: "then $59.99/year", isLoading: isLoading, tint: .indigo) {
                isLoading = true
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    isLoading = false
                }
            }
            KitoPaywallButton("Continue", tint: .pink) {}
            KitoPaywallButton("Unlock lifetime", tint: Color(red: 0.87, green: 0.72, blue: 0.43)) {}
            KitoPaywallButton("Unavailable", tint: .gray) {}.disabled(true)
        }
    }
}

private struct PaywallTimelineDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How your free trial works").font(.headline)
            KitoTrialTimelineView(timeline: KitoTrialTimeline(trial: .weekly), priceText: "$59.99/year", tint: .teal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PaywallCelebrationScreen: View {
    @State private var celebrates = false

    var body: some View {
        PaywallMockScreen(title: "Studio", tint: .orange) {
            Button { celebrates = true } label: {
                Label("Celebrate", systemImage: "party.popper.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .kitoCelebration(isPresented: $celebrates, tint: .orange)
    }
}

// MARK: - Presenting and gating

private struct PaywallPresentingScreen: View {
    @State private var store = KitoStore.preview(plans: PaywallMockPlans.trio)
    @State private var showsPaywall = false

    var body: some View {
        PaywallMockScreen(title: store.isPro ? "Journal Pro" : "Journal") {
            Button { showsPaywall = true } label: {
                Label(store.isPro ? "You're Pro" : "Go Pro", systemImage: "crown.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(store.isPro)
        }
        .kitoPaywall(isPresented: $showsPaywall, store: store, style: .hero, content: .sample)
    }
}

private struct PaywallGateDemo: View {
    @State private var store = KitoStore.preview(plans: PaywallMockPlans.trio)

    var body: some View {
        VStack(spacing: 16) {
            KitoProGate(store: store, paywall: .comparison, content: .design, tint: .purple) {
                PaywallInsightsCard(isLocked: false)
            } locked: {
                PaywallInsightsCard(isLocked: true)
            }
            if store.isPro {
                Button("Lock it again") { store = KitoStore.preview(plans: PaywallMockPlans.trio) }
                    .font(.footnote.weight(.semibold))
            }
        }
    }
}

private struct PaywallInsightsCard: View {
    let isLocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Weekly insights", systemImage: "chart.bar.xaxis").font(.headline)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach([0.4, 0.7, 0.5, 0.9, 0.65, 1.0, 0.8], id: \.self) { value in
                    RoundedRectangle(cornerRadius: 5).fill(Color.purple.gradient).frame(height: 90 * value)
                }
            }
            .frame(height: 90, alignment: .bottom)
            Text("You focused 38% longer than last week.").font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(18)
        .blur(radius: isLocked ? 7 : 0)
        .overlay {
            if isLocked {
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill").font(.title2.bold())
                    Text("Unlock insights with Pro").font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18).padding(.vertical, 14)
                .background(Capsule().fill(Color.purple.gradient))
            }
        }
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.purple.opacity(0.08)))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct PaywallLockedRowsDemo: View {
    @State private var store = KitoStore.preview(plans: PaywallMockPlans.trio)
    private struct Row: Identifiable {
        let title: String
        let symbol: String
        let isPro: Bool
        var id: String { title }
    }

    private let rows = [
        Row(title: "Reminders", symbol: "bell.fill", isPro: false),
        Row(title: "Custom themes", symbol: "paintpalette.fill", isPro: true),
        Row(title: "Export to PDF", symbol: "doc.richtext.fill", isPro: true),
        Row(title: "Face ID lock", symbol: "faceid", isPro: false),
        Row(title: "Unlimited history", symbol: "clock.arrow.circlepath", isPro: true),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                if row.isPro {
                    KitoProGate(store: store, paywall: .minimal, content: .sample) {
                        PaywallSettingsRow(title: row.title, symbol: row.symbol, trailing: "On")
                    } locked: {
                        PaywallSettingsRow(title: row.title, symbol: row.symbol, trailing: nil)
                    }
                } else {
                    PaywallSettingsRow(title: row.title, symbol: row.symbol, trailing: "On")
                }
                if row.id != rows.last?.id { Divider().padding(.leading, 52) }
            }
        }
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.primary.opacity(0.05)))
    }
}

private struct PaywallSettingsRow: View {
    let title: String
    let symbol: String
    let trailing: String?

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.indigo.gradient))
            Text(title).foregroundStyle(.primary)
            Spacer()
            if let trailing {
                Text(trailing).foregroundStyle(.secondary)
            } else {
                Label("PRO", systemImage: "crown.fill")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

// MARK: - Real StoreKit

private struct PaywallStoreKitDemo: View {
    @State private var store = KitoStore(productIDs: PaywallSampleProducts.all, mostPopular: PaywallSampleProducts.yearly)

    var body: some View {
        ModalStage {
            KitoPaywall(store: store, style: .hero, content: .sample)
        }
    }
}

private struct PaywallStatusDemo: View {
    @State private var store = KitoStore(productIDs: PaywallSampleProducts.all, mostPopular: PaywallSampleProducts.yearly)
    @State private var isWorking = false
    @State private var outcome: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            row("Products", store.isLoading ? "Loading…" : "\(store.products.count) loaded")
            row("Pro", store.isPro ? "Yes" : "No")
            row("Owns", store.purchasedProductIDs.isEmpty ? "Nothing yet" : store.purchasedProductIDs.map(shortName).sorted().joined(separator: ", "))
            if let active = store.activeSubscription {
                row("Plan", shortName(active.productID) + (active.isInTrial ? " (trial)" : ""))
                if let expiry = active.expirationDate {
                    row(active.willAutoRenew ? "Renews" : "Ends", expiry.formatted(date: .abbreviated, time: .shortened))
                }
                row("State", "\(active.state)")
            }
            row("Free week", store.isEligibleForIntroOffer(PaywallSampleProducts.yearly) ? "Available" : "Used")
            if let error = store.errorMessage {
                Text(error).font(.footnote).foregroundStyle(.red)
            }
            if let outcome {
                Text(outcome).font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(store.plans) { plan in
                    Button {
                        run {
                            let outcome = await store.purchase(plan)
                            return "\(outcome)"
                        }
                    } label: {
                        Text("Buy \(plan.period?.adjective.lowercased() ?? "lifetime")").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isWorking || store.isEntitled(plan.id))
                }
            }
            Button {
                run {
                    let outcome = await store.restore()
                    return "\(outcome)"
                }
            } label: {
                Label("Restore purchases", systemImage: "arrow.clockwise").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(isWorking)
        }
        .task { await store.load() }
    }

    private func run(_ work: @escaping () async -> String) {
        isWorking = true
        Task {
            let result = await work()
            withAnimation { outcome = "Result: \(result)" }
            isWorking = false
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold)).multilineTextAlignment(.trailing)
        }
    }

    private func shortName(_ id: String) -> String {
        id.split(separator: ".").last.map(String.init)?.capitalized ?? id
    }
}

// MARK: - Samples

enum PaywallSamples {
    static let layouts = KitSection("Layouts", symbol: "rectangle.stack.fill", [
        KitSample("Hero", "A drifting gradient, a floating badge, feature bullets and plan cards.", code: """
        @State private var store = KitoStore(productIDs: ["pro.weekly", "pro.monthly", "pro.yearly", "pro.lifetime"],
                                             mostPopular: "pro.yearly")

        KitoPaywall(store: store, style: .hero)
        """) {
            ModalStage { PaywallPreviewScreen(.hero) }
        },
        KitSample("Comparison", "Free vs Pro, the Pro ticks popping in row by row.", code: """
        KitoPaywall(store: store, style: .comparison, content: KitoPaywallContent(
            title: "Design without limits",
            features: [
                KitoPaywallFeature("Unlimited projects", symbol: "folder.fill", free: .limited("3")),
                KitoPaywallFeature("Premium templates", symbol: "square.grid.2x2.fill"),
                KitoPaywallFeature("Cloud sync", symbol: "icloud.fill", free: .included),
            ]
        ))
        """) {
            ModalStage { PaywallPreviewScreen(.comparison, plans: PaywallMockPlans.trio, content: .design, tint: .purple) }
        },
        KitSample("Trial timeline", "Today, Day 5, Day 7: when the reminder and the first charge land.", code: """
        KitoPaywall(store: store, style: .trialTimeline)   // reminderDaysBefore: 2 by default
        """) {
            ModalStage { PaywallPreviewScreen(.trialTimeline, plans: PaywallMockPlans.pair, tint: .teal) }
        },
        KitSample("Carousel", "One feature per page, swiped or auto-advancing, the colour drifting along.", code: """
        KitoPaywall(store: store, style: .carousel, tint: .pink)
        """) {
            ModalStage { PaywallPreviewScreen(.carousel, plans: PaywallMockPlans.trio, tint: .pink) }
        },
        KitSample("Minimal", "One plan, one price, one big button.", code: """
        KitoPaywall(store: KitoStore(productIDs: ["pro.yearly"]), style: .minimal)
        """) {
            ModalStage { PaywallPreviewScreen(.minimal, plans: PaywallMockPlans.single, tint: .indigo) }
        },
        KitSample("Luxe", "Near-black and champagne gold, whatever the system appearance.", code: """
        KitoPaywall(store: store, style: .luxe)   // gold unless you pass a tint
        """) {
            ModalStage { PaywallPreviewScreen(.luxe, plans: PaywallMockPlans.trio) }
        },
    ])

    static let pickers = KitSection("Plan pickers", symbol: "list.bullet.rectangle.portrait.fill", [
        KitSample("Cards", "Stacked rows; the ring and dot spring to the plan you tap.", code: """
        @State private var selection: String?

        KitoPlanPicker(plans: store.plans, selection: $selection, style: .cards)
        """) {
            PaywallPickerDemo(plans: PaywallMockPlans.standard, style: .cards)
        },
        KitSample("Chips", "Side-by-side tiles with savings ribbons.", code: """
        KitoPlanPicker(plans: store.plans, selection: $selection, style: .chips, tint: .orange)
        """) {
            PaywallPickerDemo(plans: PaywallMockPlans.trio, style: .chips, tint: .orange)
        },
        KitSample("Monthly or yearly", "A sliding switch; the price rolls from one to the other.", code: """
        KitoPlanPicker(plans: store.plans, selection: $selection, style: .toggle)
        """) {
            PaywallPickerDemo(plans: PaywallMockPlans.pair, style: .toggle, tint: .teal)
        },
        KitSample("Local currency", "Kenyan shillings, with the weekly price worked out for you.", code: """
        let yearly = KitoPaywallPlan(id: "pro.yearly", price: 429, currencyCode: "KES", period: .yearly)
        yearly.pricePerWeekText        // "KES 8.25/week"
        yearly.savingsPercent(comparedTo: monthly)   // 64
        """) {
            PaywallPickerDemo(plans: PaywallMockPlans.shillings, style: .chips, tint: .green, showsPerWeek: true)
        },
    ])

    static let pieces = KitSection("Building blocks", symbol: "square.stack.3d.up.fill", [
        KitSample("Purchase button", "A light sweep, a breathing glow and a spinner while it works.", code: """
        KitoPaywallButton("Start 7-day free trial", subtitle: "then $59.99/year", isLoading: isBuying, tint: .indigo) {
            Task { await store.purchase(plan) }
        }
        """) {
            PaywallButtonDemo()
        },
        KitSample("Trial timeline", "The track fills in from today to the first charge.", code: """
        KitoTrialTimelineView(timeline: KitoTrialTimeline(trial: .weekly), priceText: "$59.99/year", tint: .teal)
        """) {
            PaywallTimelineDemo()
        },
        KitSample("Welcome to Pro", "Confetti from both corners and a success haptic.", code: """
        SomeScreen()
            .kitoCelebration(isPresented: $celebrates, title: "Welcome to Pro", tint: .orange)
        """) {
            ModalStage { PaywallCelebrationScreen() }
        },
        KitSample("Delayed close", "The close button fades in after five seconds.", code: """
        KitoPaywall(store: store, style: .minimal, content: KitoPaywallContent(closeButtonDelay: 5))
        """) {
            ModalStage {
                PaywallPreviewScreen(.minimal, plans: PaywallMockPlans.single, content: KitoPaywallContent(closeButtonDelay: 5), tint: .orange)
            }
        },
    ])

    static let presenting = KitSection("Presenting and gating", symbol: "lock.fill", [
        KitSample("Present full screen", "One modifier, closed by the button or a finished purchase.", code: """
        JournalView()
            .kitoPaywall(isPresented: $showsPaywall, store: store, style: .hero)
        """) {
            ModalStage { PaywallPresentingScreen() }
        },
        KitSample("Pro gate", "A blurred teaser opens the paywall; the purchase reveals the real thing.", code: """
        KitoProGate(store: store, paywall: .comparison) {
            InsightsCard()
        } locked: {
            InsightsCard().blur(radius: 7).overlay { UnlockBadge() }
        }
        """) {
            PaywallGateDemo()
        },
        KitSample("Locked settings", "Pro rows carry a badge; unlocking one unlocks them all.", code: """
        KitoProGate(store: store, paywall: .minimal) {
            SettingsRow("Custom themes", value: "On")
        } locked: {
            SettingsRow("Custom themes", badge: "PRO")
        }
        """) {
            PaywallLockedRowsDemo()
        },
    ])

    static let storeKit = KitSection("Real StoreKit", symbol: "bag.fill", [
        KitSample("Local StoreKit paywall", "Real products from KitoSample.storekit: buy, restore, watch it unlock.", code: """
        @State private var store = KitoStore(
            productIDs: ["com.wyksoftsinc.kitosample.pro.weekly", "com.wyksoftsinc.kitosample.pro.monthly",
                         "com.wyksoftsinc.kitosample.pro.yearly", "com.wyksoftsinc.kitosample.lifetime"],
            mostPopular: "com.wyksoftsinc.kitosample.pro.yearly"
        )

        KitoPaywall(store: store, style: .hero)
        """) {
            PaywallStoreKitDemo()
        },
        KitSample("Subscription status", "Entitlements, trial, renewal date and intro-offer eligibility, live.", code: """
        store.isPro
        store.purchasedProductIDs
        store.activeSubscription?.isInTrial
        store.activeSubscription?.expirationDate
        store.activeSubscription?.willAutoRenew
        store.isEligibleForIntroOffer("pro.yearly")
        await store.purchase(plan)      // .purchased, .pending, .cancelled or .failed
        await store.restore()           // .restored, .nothingToRestore, .cancelled or .failed
        """) {
            PaywallStatusDemo()
        },
    ])

    static let theming = KitSection("Your brand", symbol: "paintpalette.fill", [
        KitSample("Fitness app", "Your tint, words and features on the hero layout, with chips.", code: """
        KitoPaywall(store: store, style: .hero, content: KitoPaywallContent(
            title: "Train without limits",
            symbol: "figure.run",
            features: [KitoPaywallFeature("500+ workouts", symbol: "flame.fill"), …],
            planPicker: .chips,
            celebrationTitle: "Let's go!"
        ), tint: .pink)
        """) {
            ModalStage { PaywallPreviewScreen(.hero, plans: PaywallMockPlans.trio, content: .fitness, tint: .pink) }
        },
        KitSample("Meditation app", "A calm trial timeline in green.", code: """
        KitoPaywall(store: store, style: .trialTimeline, content: KitoPaywallContent(
            title: "Breathe easier",
            symbol: "leaf.fill",
            celebrationTitle: "Welcome in"
        ), tint: .green)
        """) {
            ModalStage { PaywallPreviewScreen(.trialTimeline, plans: PaywallMockPlans.pair, content: .calm, tint: .green) }
        },
    ])

    static let sections: [KitSection] = [layouts, pickers, pieces, presenting, storeKit, theming]
}

struct PaywallGallery: View {
    static var count: Int { KitGallery.count(PaywallSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Paywall",
            sections: PaywallSamples.sections,
            footnote: "Requires `import KitoPaywall`.",
            searchHint: "Try “trial”, “comparison”, “toggle”, “gate” or “StoreKit”."
        )
    }
}
