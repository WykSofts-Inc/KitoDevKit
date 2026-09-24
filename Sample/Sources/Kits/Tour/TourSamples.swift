//
//  TourSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoTour

// MARK: - Sample data

private enum TourData {
    /// Keeps the gallery's "seen" flags apart from the rest of the app.
    static let store = KitoSeenStore(prefix: "kitosample.")

    static func bank(_ id: String) -> KitoTour {
        KitoTour(id, title: "Get to know Pesa", steps: [
            KitoTourStep("balance", title: "Your balance",
                         message: "Tap the eye to hide it when you're out in public.",
                         systemImage: "eye.slash.fill", spotlight: .roundedRect(cornerRadius: 24)),
            KitoTourStep("send", title: "Send money",
                         message: "Pay anyone in seconds with just their phone number.",
                         systemImage: "paperplane.fill", spotlight: .circle),
            KitoTourStep("scan", title: "Scan to pay",
                         message: "Point your camera at any till or paybill QR code.",
                         systemImage: "qrcode.viewfinder", spotlight: .circle),
            KitoTourStep("tab.Insights", title: "Insights",
                         message: "See where your money went this month.",
                         systemImage: "chart.pie.fill", placement: .top, spotlight: .capsule),
            KitoTourStep("profile", title: "Your profile",
                         message: "Limits, statements and security settings live here.",
                         systemImage: "person.crop.circle", spotlight: .circle, actionTitle: "Let's go"),
        ])
    }

    static let bankTapThrough = KitoTour("bank.tap", steps: [
        KitoTourStep("send", title: "Tap Send",
                     message: "Go on, tap the real button. The tour moves on by itself.",
                     systemImage: "hand.tap.fill", spotlight: .circle, advancesOnTargetTap: true),
        KitoTourStep("scan", title: "Now Scan",
                     message: "The button still does its job; the tour just follows along.",
                     systemImage: "qrcode.viewfinder", spotlight: .circle, advancesOnTargetTap: true),
        KitoTourStep("tab.Insights", title: "Last one",
                     message: "Tap Insights to finish.", systemImage: "chart.pie.fill",
                     placement: .top, spotlight: .capsule, advancesOnTargetTap: true),
    ])

    static func delivery(_ id: String) -> KitoTour {
        KitoTour(id, title: "Getting started", steps: [
            KitoTourStep("address", title: "Set your address",
                         message: "Choose where your food goes. We remember your favourites.",
                         systemImage: "mappin.and.ellipse", spotlight: .capsule),
            KitoTourStep("search", title: "Find food",
                         message: "Search restaurants, dishes or shops near you.",
                         systemImage: "magnifyingglass", spotlight: .capsule),
            KitoTourStep("filters", title: "Filter the list",
                         message: "Sort by distance, price or rating.",
                         systemImage: "slider.horizontal.3", spotlight: .circle),
            KitoTourStep("promo", title: "Grab a deal",
                         message: "Today's offers from places nearby.",
                         systemImage: "tag.fill", spotlight: .roundedRect(cornerRadius: 20)),
            KitoTourStep("cart", title: "Check out",
                         message: "Review your order and pay with M-Pesa or card.",
                         systemImage: "bag.fill", spotlight: .circle),
        ])
    }

    static func photo(_ id: String) -> KitoTour {
        KitoTour(id, steps: [
            KitoTourStep("magic", title: "One-tap magic",
                         message: "Fixes light and colour in one go.",
                         systemImage: "wand.and.stars", spotlight: .circle),
            KitoTourStep("photo", title: "Compare",
                         message: "Press and hold the photo to see the original.",
                         systemImage: "hand.tap.fill", spotlight: .roundedRect(cornerRadius: 28), spotlightPadding: 4),
            KitoTourStep("tool.Filters", title: "Filters",
                         message: "Twelve looks, each with its own strength.",
                         systemImage: "camera.filters", spotlight: .capsule),
            KitoTourStep("tool.Crop", title: "Crop and rotate",
                         message: "Square, portrait or story, and straighten the horizon.",
                         systemImage: "crop.rotate", spotlight: .capsule),
            KitoTourStep("export", title: "Share it",
                         message: "Save to Photos or send it straight to a chat.",
                         systemImage: "square.and.arrow.up", spotlight: .capsule, actionTitle: "Got it"),
        ])
    }

    static func whatsNew(_ version: String, id: String = "sample") -> KitoWhatsNew {
        KitoWhatsNew(version: version, title: "What's new in Pesa",
                     subtitle: "A faster way to pay, split and save.",
                     features: [
                        KitoWhatsNewFeature("Split bills", message: "Share a bill with friends in two taps. They pay you back with one.",
                                            systemImage: "person.2.fill", tint: .orange),
                        KitoWhatsNewFeature("Savings goals", message: "Put a little aside every payday, automatically.",
                                            systemImage: "target", tint: .green),
                        KitoWhatsNewFeature("Scan any QR", message: "Tills, paybills and friends' codes, all in one scanner.",
                                            systemImage: "qrcode.viewfinder", tint: .blue),
                        KitoWhatsNewFeature("Dark mode", message: "Easy on the eyes when you're paying for nyama choma at night.",
                                            systemImage: "moon.stars.fill", tint: .indigo),
                     ],
                     buttonTitle: "Continue", id: id)
    }
}

// MARK: - Shared pieces

private struct TourReplayButton: View {
    var title = "Replay tour"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "arrow.counterclockwise")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(.thinMaterial))
                .overlay(Capsule().stroke(Color.primary.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct TourStatusPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(.regularMaterial))
            .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 1))
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: text)
    }
}

// MARK: - Banking app

private struct TourBankScreen: View {
    var tint: Color = .indigo
    var replayTitle = "Replay tour"
    let onReplay: () -> Void
    var onAction: (String) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            balance
            actions
            recent
            Spacer(minLength: 0)
            tabBar
        }
        .padding(.top, 54)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Habari, Amina").font(.title2.bold())
                Text("Pesa wallet").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            TourReplayButton(title: replayTitle, action: onReplay)
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(tint)
                .kitoTourAnchor("profile")
        }
        .padding(.horizontal, 20)
    }

    private var balance: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Balance").font(.subheadline.weight(.medium)).foregroundStyle(.white.opacity(0.8))
                Spacer()
                Image(systemName: "eye.fill").foregroundStyle(.white)
            }
            Text("KES 48,250.00").font(.system(size: 32, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text("+ KES 3,400 this week").font(.footnote.weight(.semibold)).foregroundStyle(.white.opacity(0.85))
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(tint.gradient))
        .shadow(color: tint.opacity(0.3), radius: 14, y: 8)
        .kitoTourAnchor("balance")
        .padding(.horizontal, 20)
    }

    private var actions: some View {
        HStack {
            TourBankAction(title: "Send", symbol: "paperplane.fill", tint: tint, onTap: onAction)
            Spacer()
            TourBankAction(title: "Pay", symbol: "creditcard.fill", tint: tint, onTap: onAction)
            Spacer()
            TourBankAction(title: "Withdraw", symbol: "banknote.fill", tint: tint, onTap: onAction)
            Spacer()
            TourBankAction(title: "Scan", symbol: "qrcode.viewfinder", tint: tint, onTap: onAction)
        }
        .padding(.horizontal, 28)
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent").font(.headline)
            TourBankRow(name: "Java House", detail: "Coffee · Today", amount: "- KES 450", symbol: "cup.and.saucer.fill")
            TourBankRow(name: "Wanjiku M.", detail: "Received · Yesterday", amount: "+ KES 2,000", symbol: "arrow.down.left")
            TourBankRow(name: "KPLC Tokens", detail: "Electricity · Mon", amount: "- KES 1,200", symbol: "bolt.fill")
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
        .padding(.horizontal, 20)
    }

    private var tabBar: some View {
        HStack {
            TourTabItem(title: "Home", symbol: "house.fill", selected: true, tint: tint, onTap: onAction)
            TourTabItem(title: "Cards", symbol: "creditcard", selected: false, tint: tint, onTap: onAction)
            TourTabItem(title: "Insights", symbol: "chart.pie", selected: false, tint: tint, onTap: onAction)
            TourTabItem(title: "Settings", symbol: "gearshape", selected: false, tint: tint, onTap: onAction)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 26)
        .background(.bar)
    }
}

private struct TourBankAction: View {
    let title: String
    let symbol: String
    let tint: Color
    let onTap: (String) -> Void

    var body: some View {
        VStack(spacing: 6) {
            Button { onTap(title) } label: {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(tint.opacity(0.14)))
            }
            .buttonStyle(.plain)
            .kitoTourAnchor(title.lowercased())
            Text(title).font(.caption.weight(.medium))
        }
    }
}

private struct TourBankRow: View {
    let name: String
    let detail: String
    let amount: String
    let symbol: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.primary.opacity(0.07)))
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(amount).font(.subheadline.weight(.semibold).monospacedDigit())
        }
    }
}

private struct TourTabItem: View {
    let title: String
    let symbol: String
    let selected: Bool
    let tint: Color
    let onTap: (String) -> Void

    var body: some View {
        Button { onTap(title) } label: {
            VStack(spacing: 3) {
                Image(systemName: symbol).font(.system(size: 18, weight: .semibold))
                Text(title).font(.caption2.weight(.medium))
            }
            .foregroundStyle(selected ? tint : Color.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .kitoTourAnchor("tab.\(title)")
        .frame(maxWidth: .infinity)
    }
}

/// A banking screen running a tour in any style.
private struct TourBankSample: View {
    let style: KitoTourStyle
    var tint: Color?

    @State private var controller: KitoTourController

    init(style: KitoTourStyle, id: String, tint: Color? = nil) {
        self.style = style
        self.tint = tint
        _controller = State(initialValue: KitoTourController(TourData.bank(id), store: TourData.store))
    }

    var body: some View {
        TourBankScreen(tint: tint ?? .indigo) { controller.start() }
            .kitoTour(controller, style: style, tint: tint)
            .task {
                try? await Task.sleep(for: .milliseconds(600))
                controller.startIfNeeded()
            }
    }
}

/// Steps that move on when the real button is tapped.
private struct TourTapThroughSample: View {
    @State private var controller = KitoTourController(TourData.bankTapThrough, store: TourData.store)
    @State private var lastTap = "Tap the highlighted button"

    var body: some View {
        TourBankScreen(tint: .teal, onReplay: { controller.start() }, onAction: { lastTap = "You tapped \($0)" })
            .overlay(alignment: .bottom) { TourStatusPill(text: lastTap).padding(.bottom, 92) }
            .kitoTour(controller, style: .spotlight, tint: .teal)
            .task {
                try? await Task.sleep(for: .milliseconds(600))
                controller.startIfNeeded()
            }
    }
}

// MARK: - Delivery app

private struct TourDeliveryScreen: View {
    var replayTitle = "Replay tour"
    let onReplay: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            search
            chips
            promo
            TourRestaurantRow(name: "Mama Oliech", detail: "Fish · 1.2 km · 25 min", rating: "4.8", colours: [.orange, .red])
            TourRestaurantRow(name: "Kilimanjaro Jamia", detail: "Swahili · 2.0 km · 30 min", rating: "4.6", colours: [.green, .teal])
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 54)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
    }

    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Deliver to").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Text("Kilimani, Nairobi").font(.headline)
                    Image(systemName: "chevron.down").font(.caption.weight(.bold))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.orange.opacity(0.12)))
            .kitoTourAnchor("address")
            Spacer()
            TourReplayButton(title: replayTitle, action: onReplay)
            cart
        }
    }

    private var cart: some View {
        Image(systemName: "bag.fill")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 42, height: 42)
            .background(Circle().fill(Color.orange.gradient))
            .overlay(alignment: .topTrailing) {
                Text("2").font(.caption2.bold()).foregroundStyle(.white)
                    .frame(width: 18, height: 18).background(Circle().fill(.red)).offset(x: 4, y: -4)
            }
            .kitoTourAnchor("cart")
    }

    private var search: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                Text("Restaurants, dishes, shops").foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Capsule().fill(Color.primary.opacity(0.06)))
            .kitoTourAnchor("search")
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 17, weight: .semibold))
                .frame(width: 46, height: 46)
                .background(Circle().fill(Color.primary.opacity(0.06)))
                .kitoTourAnchor("filters")
        }
    }

    private var chips: some View {
        HStack(spacing: 8) {
            ForEach(["Kenyan", "Pizza", "Grocery", "Coffee"], id: \.self) { chip in
                Text(chip)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().stroke(Color.primary.opacity(0.14), lineWidth: 1))
            }
        }
    }

    private var promo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("50% off your first order").font(.headline).foregroundStyle(.white)
                Text("At 120 places near you").font(.subheadline).foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "tag.fill").font(.largeTitle).foregroundStyle(.white.opacity(0.9))
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)))
        .kitoTourAnchor("promo")
    }
}

private struct TourRestaurantRow: View {
    let name: String
    let detail: String
    let rating: String
    let colours: [Color]

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: colours, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 64, height: 64)
                .overlay(Image(systemName: "fork.knife").foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 3) {
                Text(name).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Label(rating, systemImage: "star.fill").font(.caption.weight(.semibold)).foregroundStyle(.orange)
        }
    }
}

/// A delivery screen running a tour in any style.
private struct TourDeliverySample: View {
    let style: KitoTourStyle

    @State private var controller: KitoTourController

    init(style: KitoTourStyle, id: String) {
        self.style = style
        _controller = State(initialValue: KitoTourController(TourData.delivery(id), store: TourData.store))
    }

    var body: some View {
        TourDeliveryScreen(replayTitle: style == .checklist ? "Show checklist" : "Replay tour") { controller.start() }
            .kitoTour(controller, style: style, tint: .orange)
            .task {
                try? await Task.sleep(for: .milliseconds(600))
                controller.startIfNeeded()
            }
    }
}

/// The `isPresented` form, reporting each step as it's shown.
private struct TourBoundSample: View {
    @State private var showTour = false
    @State private var status = "Tap “Show tour” to start"

    var body: some View {
        TourDeliveryScreen(replayTitle: "Show tour") { showTour = true }
            .overlay(alignment: .bottom) { TourStatusPill(text: status).padding(.bottom, 28) }
            .kitoTour(TourData.delivery("delivery.bound"), isPresented: $showTour, style: .spotlight, tint: .orange,
                      store: TourData.store,
                      onStepChange: { step in status = "Showing: \(step.title)" },
                      onFinish: { outcome in status = outcome == .completed ? "Finished the tour" : "Skipped the tour" })
    }
}

// MARK: - Photo app

private struct TourPhotoScreen: View {
    let onReplay: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            topBar
            photo
            tools
        }
        .padding(.horizontal, 16)
        .padding(.top, 54)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .foregroundStyle(.white)
        .environment(\.colorScheme, .dark)
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "chevron.left").font(.headline)
            Text("Edit").font(.headline)
            Spacer()
            TourReplayButton(action: onReplay)
            Text("Export")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(.white))
                .kitoTourAnchor("export")
        }
    }

    private var photo: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .top, endPoint: .bottom))
            .overlay {
                Image(systemName: "sun.horizon.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .kitoTourAnchor("photo")
            .overlay(alignment: .bottomTrailing) { magic }
    }

    private var magic: some View {
        Image(systemName: "wand.and.stars")
            .font(.system(size: 20, weight: .semibold))
            .frame(width: 50, height: 50)
            .background(Circle().fill(.ultraThinMaterial))
            .kitoTourAnchor("magic")
            .padding(14)
    }

    private var tools: some View {
        HStack {
            TourPhotoTool(title: "Filters", symbol: "camera.filters")
            TourPhotoTool(title: "Adjust", symbol: "slider.horizontal.3")
            TourPhotoTool(title: "Crop", symbol: "crop.rotate")
            TourPhotoTool(title: "Text", symbol: "textformat")
        }
    }
}

private struct TourPhotoTool: View {
    let title: String
    let symbol: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol).font(.system(size: 20, weight: .medium))
            Text(title).font(.caption.weight(.medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .kitoTourAnchor("tool.\(title)")
        .frame(maxWidth: .infinity)
    }
}

/// A photo editor running a tour in any style.
private struct TourPhotoSample: View {
    let style: KitoTourStyle
    var tint: Color?

    @State private var controller: KitoTourController

    init(style: KitoTourStyle, id: String, tint: Color? = nil) {
        self.style = style
        self.tint = tint
        _controller = State(initialValue: KitoTourController(TourData.photo(id), store: TourData.store))
    }

    var body: some View {
        TourPhotoScreen { controller.start() }
            .kitoTour(controller, style: style, tint: tint)
            .task {
                try? await Task.sleep(for: .milliseconds(600))
                controller.startIfNeeded()
            }
    }
}

// MARK: - Tooltips

/// Four buttons in the corners: each tip flips to stay inside the box.
private struct TourFlipTooltipSample: View {
    @State private var shown: Int? = 0

    private let corners: [(alignment: Alignment, symbol: String, message: String)] = [
        (.topLeading, "bell.fill", "Top corner: the tip drops below."),
        (.topTrailing, "gearshape.fill", "Pushed in from the edge, the arrow still points here."),
        (.bottomLeading, "heart.fill", "Near the bottom, the tip flips above."),
        (.bottomTrailing, "plus", "Tap another button to move the tip."),
    ]

    var body: some View {
        ZStack {
            ForEach(corners.indices, id: \.self) { index in
                corner(index)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: corners[index].alignment)
                    .zIndex(shown == index ? 1 : 0)
            }
        }
        .padding(12)
        .frame(height: 320)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.primary.opacity(0.04)))
        .kitoTooltipBounds()
    }

    private func corner(_ index: Int) -> some View {
        Button { shown = shown == index ? nil : index } label: {
            Image(systemName: corners[index].symbol)
                .font(.headline)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Color.primary.opacity(0.08)))
        }
        .buttonStyle(.plain)
        .kitoTooltip(isPresented: binding(index), message: corners[index].message)
    }

    private func binding(_ index: Int) -> Binding<Bool> {
        Binding(get: { shown == index }, set: { shown = $0 ? index : nil })
    }
}

/// One button, a tip on the side you pick.
private struct TourPlacementTooltipSample: View {
    @State private var placement: KitoTourPlacement = .top
    @State private var shown = true

    var body: some View {
        VStack(spacing: 16) {
            Picker("Placement", selection: $placement) {
                ForEach(KitoTourPlacement.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
            }
            .pickerStyle(.segmented)
            ZStack {
                Button { shown.toggle() } label: {
                    Label("Filters", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
                .kitoTooltip(isPresented: $shown, title: "New filters", message: "Sort by distance and price.",
                             systemImage: "sparkles", placement: placement)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.primary.opacity(0.04)))
            .kitoTooltipBounds()
        }
        .onChange(of: placement) { _, _ in shown = true }
    }
}

/// A tip with a Got it button, and one that closes itself.
private struct TourDismissTooltipSample: View {
    @State private var first = true
    @State private var second = false

    var body: some View {
        VStack(spacing: 150) {
            Button("Show again") { first = true }
                .buttonStyle(GalleryPrimaryButtonStyle())
                .kitoTooltip(isPresented: $first, title: "Save for later",
                             message: "Bookmark any restaurant to find it again.",
                             systemImage: "bookmark.fill", placement: .bottom, dismissButtonTitle: "Got it",
                             tint: .orange)
                .zIndex(1)
            Button("Tip for 4 seconds") { second = true }
                .buttonStyle(GalleryPrimaryButtonStyle())
                .kitoTooltip(isPresented: $second, message: "This one closes by itself.",
                             placement: .top, autoDismiss: .seconds(4))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .kitoTooltipBounds()
    }
}

// MARK: - Badges and What's New

private struct TourBadgeTile: View {
    let title: String
    let symbol: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .semibold))
                .frame(width: 58, height: 58)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.primary.opacity(0.07)))
            Text(title).font(.caption.weight(.medium))
        }
    }
}

private struct TourBadgesSample: View {
    private let ids = ["sample.insights", "sample.budgets", "sample.split"]

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 28) {
                TourBadgeTile(title: "Insights", symbol: "chart.bar.xaxis")
                    .kitoFeatureBadge(ids[0], style: .dot, store: TourData.store)
                TourBadgeTile(title: "Budgets", symbol: "chart.pie.fill")
                    .kitoFeatureBadge(ids[1], style: .new, store: TourData.store)
                TourBadgeTile(title: "Split", symbol: "person.2.fill")
                    .kitoFeatureBadge(ids[2], style: .label("Beta"), tint: .purple, store: TourData.store)
            }
            Text("Tap a tile to mark it seen.").font(.footnote).foregroundStyle(.secondary)
            Button("Reset badges") { ids.forEach { KitoFeatureBadge.reset($0, store: TourData.store) } }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct TourBadgeClearingSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            row("On tap", "Clears when the row is tapped.", id: "sample.clear.tap", clearing: .onTap)
            row("After 3 seconds", "Clears once it's been on screen a while.", id: "sample.clear.shown",
                clearing: .afterShown(.seconds(3)))
            row("In code", "Clears when you call markSeen.", id: "sample.clear.manual", clearing: .manually)
            HStack {
                Button("Mark “In code” seen") { KitoFeatureBadge.markSeen("sample.clear.manual", store: TourData.store) }
                Spacer()
                Button("Reset", action: reset)
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    private func row(_ title: String, _ detail: String, id: String, clearing: KitoFeatureBadgeClearing) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.primary.opacity(0.07)))
                .kitoFeatureBadge(id, style: .dot, clearsOn: clearing, store: TourData.store)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }

    private func reset() {
        ["sample.clear.tap", "sample.clear.shown", "sample.clear.manual"].forEach {
            KitoFeatureBadge.reset($0, store: TourData.store)
        }
    }
}

private struct TourWhatsNewScreen: View {
    @State private var showNews = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "gift.fill")
                .font(.system(size: 54))
                .foregroundStyle(Color.indigo.gradient)
            Text("Pesa 2.4").font(.largeTitle.bold())
            Text("You've just updated.").foregroundStyle(.secondary)
            Button("See what's new") { showNews = true }
                .buttonStyle(GalleryPrimaryButtonStyle())
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: [Color.indigo.opacity(0.2), Color(.systemBackground)], startPoint: .top, endPoint: .center))
        .kitoWhatsNew(TourData.whatsNew("2.4"), isPresented: $showNews, tint: .indigo, store: TourData.store)
    }
}

private struct TourWhatsNewOnceScreen: View {
    @State private var release = "2.4"
    @State private var attempt = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Installed version").font(.headline)
            Picker("Version", selection: $release) {
                ForEach(["2.4", "2.5", "3.0"], id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.segmented)
            Text("The sheet opens by itself when the installed version is newer than the last one seen. Pick an older version and nothing happens.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Forget seen versions") {
                TourData.store.reset(TourData.whatsNew(release, id: "sample.once").seenKey)
                attempt += 1
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            Spacer()
        }
        .padding(24)
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .kitoWhatsNew(TourData.whatsNew(release, id: "sample.once"), tint: .indigo, store: TourData.store)
        .id(attempt)
    }
}

// MARK: - Building blocks

/// Drag the dot: `KitoTooltipLayout` picks a side and keeps the bubble inside the box.
private struct TourPlacementMathsSample: View {
    @State private var target = CGPoint(x: 160, y: 70)
    private let bubble = CGSize(width: 180, height: 64)

    var body: some View {
        GeometryReader { proxy in
            canvas(in: CGRect(origin: .zero, size: proxy.size))
        }
        .frame(height: 340)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.primary.opacity(0.04)))
        .coordinateSpace(name: "tour.maths")
    }

    private func canvas(in box: CGRect) -> some View {
        let layout = solve(in: box)
        return ZStack {
            bubbleView(layout)
            handle(in: box)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: layout)
    }

    private func solve(in box: CGRect) -> KitoTooltipLayout {
        let frame = CGRect(x: target.x - 22, y: target.y - 22, width: 44, height: 44)
        return KitoTooltipLayout.solve(target: frame, bubble: bubble, in: box.insetBy(dx: 10, dy: 10), gap: 12)
    }

    private func bubbleView(_ layout: KitoTooltipLayout) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("side: \(layout.side.rawValue)").font(.subheadline.weight(.semibold))
            Text("arrow at \(Int(layout.arrowOffset)) pt").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .frame(width: bubble.width, height: bubble.height, alignment: .leading)
        .background {
            KitoTooltipBubbleShape(arrowEdge: layout.arrowEdge, arrowOffset: layout.arrowOffset, cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
        }
        .position(x: layout.frame.midX, y: layout.frame.midY)
    }

    private func handle(in box: CGRect) -> some View {
        Circle()
            .fill(Color.indigo.gradient)
            .frame(width: 44, height: 44)
            .overlay(Image(systemName: "hand.draw.fill").foregroundStyle(.white))
            .position(target)
            .gesture(DragGesture(coordinateSpace: .named("tour.maths")).onChanged { value in
                target = clamp(value.location, in: box.insetBy(dx: 22, dy: 22))
            })
            .accessibilityLabel("Target. Drag to move.")
    }

    private func clamp(_ point: CGPoint, in box: CGRect) -> CGPoint {
        CGPoint(x: min(max(point.x, box.minX), box.maxX), y: min(max(point.y, box.minY), box.maxY))
    }
}

/// The hole each spotlight shape cuts around an element, with padding.
private struct TourSpotlightShapesSample: View {
    @State private var padding: CGFloat = 8

    var body: some View {
        VStack(spacing: 28) {
            HStack(alignment: .center, spacing: 34) {
                element(CGSize(width: 96, height: 60), shape: .roundedRect(cornerRadius: 12), name: "Rounded")
                element(CGSize(width: 90, height: 36), shape: .capsule, name: "Capsule")
                element(CGSize(width: 44, height: 44), shape: .circle, name: "Circle")
            }
            .frame(height: 140)
            VStack(alignment: .leading) {
                Text("Padding \(Int(padding)) pt").font(.subheadline.weight(.semibold))
                Slider(value: $padding, in: 0...20, step: 1)
            }
        }
    }

    private func element(_ size: CGSize, shape: KitoSpotlightShape, name: String) -> some View {
        let cutout = KitoSpotlightCutout.around(CGRect(origin: .zero, size: size), shape: shape, padding: padding)
        return VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.1))
                .frame(width: size.width, height: size.height)
                .overlay {
                    RoundedRectangle(cornerRadius: cutout.cornerRadius)
                        .stroke(Color.indigo, style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                        .frame(width: cutout.rect.width, height: cutout.rect.height)
                }
                .frame(height: 90)
            Text("\(name) · r \(Int(cutout.cornerRadius))").font(.caption.weight(.medium)).foregroundStyle(.secondary)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: padding)
    }
}

/// `KitoTourNavigation` on its own: every button sends an event.
private struct TourNavigationSample: View {
    @State private var navigation = KitoTourNavigation(stepCount: 4)

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { index in dot(index) }
            }
            Text(phase).font(.headline.monospaced())
            Text("progress \(Int(navigation.progress * 100))% · checklist \(navigation.checklist.label)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                send("Start", .start)
                send("Back", .back)
                send("Next", .next)
                send("Skip", .skip)
            }
            HStack(spacing: 8) {
                send("Jump to 3", .jump(to: 2))
                send("Finish", .finish)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: navigation)
    }

    private var phase: String {
        switch navigation.phase {
        case .idle: "idle"
        case .active(let index): "active(\(index))"
        case .finished(let outcome): "finished(.\(outcome.rawValue))"
        }
    }

    private func dot(_ index: Int) -> some View {
        let done = navigation.completed.contains(index)
        let current = navigation.index == index
        return Circle()
            .fill(done ? Color.green : Color.primary.opacity(0.1))
            .overlay(Circle().stroke(current ? Color.indigo : .clear, lineWidth: 3))
            .overlay(Text("\(index + 1)").font(.caption.bold()).foregroundStyle(done ? .white : .primary))
            .frame(width: 36, height: 36)
    }

    private func send(_ title: String, _ event: KitoTourNavigation.Event) -> some View {
        Button(title) { navigation.handle(event) }
            .buttonStyle(.bordered)
            .font(.footnote.weight(.semibold))
    }
}

/// `KitoChecklistProgress` from a set of done items.
private struct TourChecklistProgressSample: View {
    @State private var done: Set<Int> = [0]
    private let items = ["Add money", "Verify your ID", "Set a PIN", "Invite a friend", "Pay a bill"]

    private var progress: KitoChecklistProgress { KitoChecklistProgress(completed: done.count, total: items.count) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ring
                VStack(alignment: .leading, spacing: 2) {
                    Text("Getting started \(progress.label)").font(.headline)
                    Text(nextUp).font(.caption).foregroundStyle(.secondary)
                }
            }
            ForEach(items.indices, id: \.self) { index in
                Toggle(items[index], isOn: binding(index)).font(.subheadline)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: done)
    }

    private var ring: some View {
        ZStack {
            Circle().stroke(Color.primary.opacity(0.1), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress.fraction)
                .stroke(progress.isComplete ? Color.green : Color.indigo, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(progress.remaining)").font(.subheadline.bold().monospacedDigit())
        }
        .frame(width: 48, height: 48)
    }

    private var nextUp: String {
        guard let next = KitoChecklistProgress.nextIndex(completed: done, total: items.count) else { return "All done" }
        return "Next up: \(items[next])"
    }

    private func binding(_ index: Int) -> Binding<Bool> {
        Binding(get: { done.contains(index) }, set: { isOn in
            if isOn { done.insert(index) } else { done.remove(index) }
        })
    }
}

// MARK: - Gallery

enum TourSamples {
    private static let tours = KitSection("Tours", symbol: "sparkles.rectangle.stack", [
        KitSample("Spotlight", "A banking app: the hole glides and morphs from card to circle to capsule.", code: """
        extension KitoTour {
            static let wallet = KitoTour("wallet", version: 1, steps: [
                KitoTourStep("balance", title: "Your balance", message: "Tap the eye to hide it.",
                             systemImage: "eye.slash.fill", spotlight: .roundedRect(cornerRadius: 24)),
                KitoTourStep("send", title: "Send money", message: "Pay anyone in seconds.",
                             systemImage: "paperplane.fill", spotlight: .circle),
                KitoTourStep("tab.Insights", title: "Insights", message: "Where your money went.",
                             systemImage: "chart.pie.fill", placement: .top, spotlight: .capsule),
            ])
        }

        @State private var tour = KitoTourController(.wallet)

        WalletScreen()                                  // views marked .kitoTourAnchor("send") …
            .kitoTour(tour, style: .spotlight)
            .onAppear { tour.startIfNeeded() }          // once per tour version

        Button("Replay tour") { tour.start() }
        """) { ModalStage { TourBankSample(style: .spotlight, id: "bank.spotlight") } },
        KitSample("Pulse", "A beacon on each element and a small tip; the screen stays usable.", code: """
        WalletScreen()
            .kitoTour(tour, style: .pulse)
        """) { ModalStage { TourBankSample(style: .pulse, id: "bank.pulse", tint: .pink) } },
        KitSample("Card", "A delivery app: a card that moves top or bottom and points at each element.", code: """
        DeliveryHome()
            .kitoTour(tour, style: .card, tint: .orange)
        """) { ModalStage { TourDeliverySample(style: .card, id: "delivery.card") } },
        KitSample("Checklist", "“Getting started 2/5” that expands; tap a row to be shown where it is.", code: """
        static let gettingStarted = KitoTour("getting-started", title: "Getting started", steps: [
            KitoTourStep("address", title: "Set your address", message: "…", systemImage: "mappin.and.ellipse"),
            KitoTourStep("search", title: "Find food", message: "…", systemImage: "magnifyingglass"),
            …
        ])

        DeliveryHome()
            .kitoTour(tour, style: .checklist, tint: .orange)

        tour.checklist.label        // "2/5"
        """) { ModalStage { TourDeliverySample(style: .checklist, id: "delivery.checklist") } },
        KitSample("Coach marks", "A photo editor: handwritten labels and arrows that draw themselves.", code: """
        PhotoEditor()
            .kitoTour(tour, style: .coachmark)      // tap anywhere to continue
        """) { ModalStage { TourPhotoSample(style: .coachmark, id: "photo.coachmark") } },
        KitSample("Spotlight with a tint", "The same editor with a pink accent on the ring and buttons.", code: """
        PhotoEditor()
            .kitoTour(tour, style: .spotlight, tint: .pink)
        """) { ModalStage { TourPhotoSample(style: .spotlight, id: "photo.spotlight", tint: .pink) } },
        KitSample("Tap the real button", "Steps that move on when the highlighted button itself is tapped.", code: """
        KitoTourStep("send", title: "Tap Send",
                     message: "Go on, tap the real button.",
                     spotlight: .circle, advancesOnTargetTap: true)
        // The button's own action still runs.
        """) { ModalStage { TourTapThroughSample() } },
        KitSample("Bound to isPresented", "Start with a binding and follow along with onStepChange.", code: """
        @State private var showTour = false

        DeliveryHome()
            .kitoTour(.delivery, isPresented: $showTour, style: .spotlight, tint: .orange,
                      onStepChange: { step in status = "Showing: " + step.title },
                      onFinish: { outcome in analytics.log(outcome) })   // .completed or .skipped
        """) { ModalStage { TourBoundSample() } },
    ])

    private static let tooltips = KitSection("Tooltips", symbol: "text.bubble", [
        KitSample("Tips that flip", "Each corner's tip picks the side with room and stays inside the box.", code: """
        Button { … } label: { Image(systemName: "gearshape.fill") }
            .kitoTooltip(isPresented: $showTip,
                         message: "Pushed in from the edge, the arrow still points here.")

        // Keep tips inside a container instead of the screen:
        Card { … }.kitoTooltipBounds()
        """) { TourFlipTooltipSample() },
        KitSample("Placements", "Top, bottom, leading or trailing, flipping only when there's no room.", code: """
        Button("Filters", systemImage: "slider.horizontal.3") { … }
            .kitoTooltip(isPresented: $shown, title: "New filters",
                         message: "Sort by distance and price.",
                         systemImage: "sparkles", placement: .leading)
        """) { TourPlacementTooltipSample() },
        KitSample("Got it and auto-dismiss", "A button that closes the tip, or a tip that closes itself.", code: """
        .kitoTooltip(isPresented: $first, title: "Save for later",
                     message: "Bookmark any restaurant to find it again.",
                     systemImage: "bookmark.fill", dismissButtonTitle: "Got it", tint: .orange)

        .kitoTooltip(isPresented: $second, message: "This one closes by itself.",
                     autoDismiss: .seconds(4))
        """) { TourDismissTooltipSample() },
    ])

    private static let announcements = KitSection("Badges and What's New", symbol: "gift", [
        KitSample("Feature badges", "A pulsing dot, “New” or your own label, until the feature is seen.", code: """
        TabButton("Insights").kitoFeatureBadge("insights")                    // .dot
        TabButton("Budgets").kitoFeatureBadge("budgets", style: .new)
        TabButton("Split").kitoFeatureBadge("split", style: .label("Beta"), tint: .purple)

        KitoFeatureBadge.reset("insights")      // show it again
        """) { TourBadgesSample() },
        KitSample("When badges clear", "On tap, after being on screen a while, or only from code.", code: """
        .kitoFeatureBadge("export", clearsOn: .onTap)
        .kitoFeatureBadge("budgets", clearsOn: .afterShown(.seconds(3)))
        .kitoFeatureBadge("sync", clearsOn: .manually)
        KitoFeatureBadge.markSeen("sync")
        """) { TourBadgeClearingSample() },
        KitSample("What's New sheet", "Version pill, feature rows that arrive one by one, Continue.", code: """
        let whatsNew = KitoWhatsNew(version: "2.4", title: "What's new in Pesa", features: [
            KitoWhatsNewFeature("Split bills", message: "Share a bill with friends in two taps.",
                                systemImage: "person.2.fill", tint: .orange),
            KitoWhatsNewFeature("Savings goals", message: "Put a little aside every payday.",
                                systemImage: "target", tint: .green),
        ])

        HomeScreen()
            .kitoWhatsNew(whatsNew, isPresented: $showNews, tint: .indigo)
        """) { ModalStage { TourWhatsNewScreen() } },
        KitSample("Once per version", "Opens by itself only when the version is newer than the last seen.", code: """
        ContentView()
            .kitoWhatsNew(KitoWhatsNew(version: appVersion, features: features))

        // "2.10" is newer than "2.9"
        KitoSeenRules.shouldShow(version: "2.10", lastSeen: "2.9")    // true
        """) { ModalStage { TourWhatsNewOnceScreen() } },
    ])

    private static let blocks = KitSection("Building blocks", symbol: "square.stack.3d.up", [
        KitSample("Placement maths", "Drag the dot: the side, the clamped frame and the arrow offset.", code: """
        let layout = KitoTooltipLayout.solve(target: buttonFrame,
                                             bubble: CGSize(width: 180, height: 64),
                                             in: safeArea, placement: .auto, gap: 12)
        layout.side          // .bottom, .top, .leading or .trailing
        layout.frame         // kept inside safeArea
        layout.arrowOffset   // still points at the button when pushed in from an edge

        bubble.background(KitoTooltipBubbleShape(arrowEdge: layout.arrowEdge,
                                                 arrowOffset: layout.arrowOffset))
        """) { TourPlacementMathsSample() },
        KitSample("Spotlight shapes", "The hole each shape cuts, grown by the step's padding.", code: """
        let hole = KitoSpotlightCutout.around(frame, shape: .roundedRect(cornerRadius: 12), padding: 8)
        hole.rect            // frame grown by 8 on every side
        hole.cornerRadius    // 20: grows with the padding so corners stay concentric

        KitoSpotlightCutout.around(frame, shape: .circle, padding: 8)    // square, radius = half
        """) { TourSpotlightShapesSample() },
        KitSample("Step state machine", "KitoTourNavigation as a plain value: send events, read the phase.", code: """
        var navigation = KitoTourNavigation(stepCount: 4)
        navigation.handle(.start)          // .active(0)
        navigation.handle(.next)           // .active(1), step 0 completed
        navigation.handle(.jump(to: 3))    // from a checklist
        navigation.handle(.skip)           // .finished(.skipped)
        navigation.progress                // 0...1
        """) { TourNavigationSample() },
        KitSample("Checklist progress", "“2/5”, the fraction for a ring, and what's next.", code: """
        let progress = KitoChecklistProgress(completed: 2, total: 5)
        progress.label        // "2/5"
        progress.fraction     // 0.4
        progress.remaining    // 3
        KitoChecklistProgress.nextIndex(completed: [0, 1, 3], total: 5)   // 2
        """) { TourChecklistProgressSample() },
    ])

    static let sections: [KitSection] = [tours, tooltips, announcements, blocks]
}

struct TourGallery: View {
    static var count: Int { KitGallery.count(TourSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Tours & Tips",
            sections: TourSamples.sections,
            footnote: "Requires `import KitoTour`.",
            searchHint: "Try “spotlight”, “checklist”, “coach”, “tooltip”, “badge” or “what's new”."
        )
    }
}
