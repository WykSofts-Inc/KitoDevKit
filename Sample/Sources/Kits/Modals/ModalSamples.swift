//
//  ModalSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoModals
import KitoButtons
import KitoFields

private func trigger(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) -> some View {
    KitoButton(title, systemImage: systemImage) { action() }.fullWidth()
}

// MARK: - Sheets

private struct SheetSample<Body: View>: View {
    let configuration: KitoSheetConfiguration
    var tint: Color = .indigo
    var title = "Home"
    var opensOnAppear = true
    @ViewBuilder let sheet: (Binding<Bool>) -> Body
    @State private var isPresented = false

    var body: some View {
        MockAppScreen(title: title, tint: tint) { trigger("Open sheet", systemImage: "rectangle.bottomhalf.inset.filled") { isPresented = true } }
            .kitoSheet(isPresented: $isPresented, configuration: configuration) { sheet($isPresented) }
            .onAppear { if opensOnAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isPresented = true } } }
    }
}

private struct InfoSheet: View {
    @Binding var isPresented: Bool
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles").font(.system(size: 34)).foregroundStyle(.indigo)
            Text("What's new").font(.title2.bold())
            Text("Swipe down, tap outside, or drag up for more.").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            KitoButton("Got it") { isPresented = false }.fullWidth()
        }
        .padding(24)
    }
}

private struct DetentSheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nearby").font(.title2.bold())
            Text("Drag up to see all 12 places; drag down to peek.").font(.subheadline).foregroundStyle(.secondary)
            ForEach(["Java House", "Artcaffé", "Mama Oliech", "Talisman", "Cultiva", "Fogo Gaucho"], id: \.self) { place in
                HStack(spacing: 12) {
                    Image(systemName: "fork.knife").frame(width: 40, height: 40).background(Circle().fill(Color.orange.opacity(0.18))).foregroundStyle(.orange)
                    VStack(alignment: .leading) { Text(place).font(.headline); Text("0.8 km · Open").font(.caption).foregroundStyle(.secondary) }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 20)
    }
}

private struct FiltersSheet: View {
    @Binding var isPresented: Bool
    @State private var selected: Set<String> = ["Free delivery"]
    @State private var price = 2_000.0
    private let chips = ["Free delivery", "Top rated", "Under 30 min", "Vegan", "Offers", "New"]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack { Text("Filters").font(.title2.bold()); Spacer(); Button("Reset") { selected = []; price = 2_000 }.font(.subheadline.weight(.semibold)) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                ForEach(chips, id: \.self) { chip in
                    let on = selected.contains(chip)
                    Button { if on { selected.remove(chip) } else { selected.insert(chip) } } label: {
                        Text(chip).font(.subheadline.weight(.medium)).frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(Capsule().fill(on ? Color.primary : Color.primary.opacity(0.07)))
                            .foregroundStyle(on ? Color(.systemBackground) : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack { Text("Max price"); Spacer(); Text("KSh \(Int(price))").monospacedDigit() }.font(.subheadline.weight(.semibold))
                Slider(value: $price, in: 200...5_000, step: 100).tint(.primary)
            }
            KitoButton("Show 42 places") { isPresented = false }.fullWidth()
        }
        .padding(22)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selected)
    }
}

private struct ShareSheet: View {
    @Binding var isPresented: Bool
    private let people = [("WN", Color.indigo), ("BK", .orange), ("CA", .green), ("DM", .pink), ("EO", .teal)]
    private let apps = [("Messages", "message.fill", Color.green), ("Mail", "envelope.fill", .blue), ("Copy link", "link", .gray), ("Save", "square.and.arrow.down", .purple)]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)).frame(width: 52, height: 52)
                VStack(alignment: .leading) { Text("Weekend in Diani").font(.headline); Text("kito.app/trip/diani").font(.caption).foregroundStyle(.secondary) }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(people, id: \.0) { initials, color in
                        VStack(spacing: 6) {
                            Circle().fill(color.gradient).frame(width: 58, height: 58).overlay(Text(initials).font(.headline).foregroundStyle(.white))
                            Text(initials).font(.caption)
                        }
                    }
                }
            }
            HStack {
                ForEach(apps, id: \.0) { name, symbol, color in
                    Button { isPresented = false } label: {
                        VStack(spacing: 6) {
                            Image(systemName: symbol).font(.title3).foregroundStyle(.white).frame(width: 56, height: 56)
                                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(color))
                            Text(name).font(.caption).foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(22)
    }
}

private struct CheckoutSheet: View {
    @Binding var isPresented: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Confirm order").font(.title2.bold())
            ForEach([("Grilled chicken breast", "KSh 890"), ("Crunchy taco", "KSh 650"), ("Delivery", "Free")], id: \.0) { item, price in
                HStack { Text(item); Spacer(); Text(price).monospacedDigit().foregroundStyle(.secondary) }.font(.subheadline)
            }
            Divider()
            HStack { Text("Total").font(.headline); Spacer(); Text("KSh 1,540").font(.headline.monospacedDigit()) }
            KitoSlideToConfirm("Slide to pay KSh 1,540", systemImage: "creditcard.fill", tint: .green) {
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                try? await Task.sleep(nanoseconds: 700_000_000)
                isPresented = false
            }
        }
        .padding(22)
    }
}

private struct PaywallSheet: View {
    @Binding var isPresented: Bool
    @State private var plan = 1
    private let plans = [("Monthly", "KSh 499 / month", ""), ("Yearly", "KSh 3,999 / year", "Save 33%"), ("Lifetime", "KSh 9,999 once", "")]

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                LinearGradient(colors: [.purple, .pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                VStack(spacing: 6) {
                    Image(systemName: "crown.fill").font(.system(size: 40)).foregroundStyle(.yellow).shadow(radius: 8)
                    Text("Kito Pro").font(.largeTitle.bold()).foregroundStyle(.white)
                    Text("Every kit, every template, forever updated.").font(.subheadline).foregroundStyle(.white.opacity(0.85))
                }
            }
            .frame(height: 190)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            ForEach(Array(plans.enumerated()), id: \.offset) { index, item in
                Button { plan = index } label: {
                    HStack {
                        Image(systemName: plan == index ? "checkmark.circle.fill" : "circle").font(.title3).foregroundStyle(plan == index ? .purple : .secondary)
                        VStack(alignment: .leading) { Text(item.0).font(.headline); Text(item.1).font(.caption).foregroundStyle(.secondary) }
                        Spacer()
                        if !item.2.isEmpty { Text(item.2).font(.caption.bold()).padding(.horizontal, 8).padding(.vertical, 4).background(Capsule().fill(.purple)).foregroundStyle(.white) }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(plan == index ? Color.purple : Color.primary.opacity(0.12), lineWidth: plan == index ? 2 : 1))
                }
                .buttonStyle(.plain)
            }
            KitoButton("Start free trial") { try await Task.sleep(nanoseconds: 800_000_000); isPresented = false }.fullWidth()
            Text("7 days free, then \(plans[plan].1). Cancel anytime.").font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: plan)
    }
}

private struct RatingSheet: View {
    @Binding var isPresented: Bool
    @State private var stars = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Enjoying Kito?").font(.title2.bold())
            Text("Tap a star to rate.").font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= stars ? "star.fill" : "star")
                        .font(.system(size: 36))
                        .foregroundStyle(index <= stars ? .yellow : .secondary)
                        .scaleEffect(index == stars ? 1.2 : 1)
                        .symbolEffect(.bounce, value: stars == index)
                        .onTapGesture { withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { stars = index } }
                        .accessibilityLabel("\(index) star\(index == 1 ? "" : "s")")
                }
            }
            if stars > 0 {
                Text(stars >= 4 ? "Thank you! 🎉" : "Tell us how we can do better.").font(.subheadline.weight(.semibold)).transition(.opacity)
            }
            KitoButton(stars == 0 ? "Not now" : "Submit") { isPresented = false }.variant(stars == 0 ? .ghost : .primary).fullWidth()
        }
        .padding(24)
    }
}

private struct CookieSheet: View {
    @Binding var isPresented: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("We value your privacy", systemImage: "hand.raised.fill").font(.headline)
            Text("We use essential cookies to run the app, and optional ones to understand usage. You can change this in Settings.").font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 10) {
                KitoButton("Essential only") { isPresented = false }.variant(.outlined).fullWidth()
                KitoButton("Accept all") { isPresented = false }.fullWidth()
            }
        }
        .padding(20)
    }
}

private struct SignInSheet: View {
    @Binding var isPresented: Bool
    @State private var email = ""

    var body: some View {
        VStack(spacing: 14) {
            Text("Sign in").font(.title2.bold())
            KitoEmailField(text: $email)
            KitoButton("Continue with email", systemImage: "envelope.fill") { try await Task.sleep(nanoseconds: 700_000_000); isPresented = false }.fullWidth()
            HStack { Rectangle().frame(height: 1).opacity(0.15); Text("or").font(.caption).foregroundStyle(.secondary); Rectangle().frame(height: 1).opacity(0.15) }
            KitoButton("Continue with phone", systemImage: "phone.fill") { isPresented = false }.variant(.outlined).fullWidth()
            KitoButton("Continue with passkey", systemImage: "person.badge.key.fill") { isPresented = false }.variant(.tonal).fullWidth()
        }
        .padding(22)
    }
}

// MARK: - Alerts

private struct AlertSample: View {
    let make: () -> KitoAlert
    var tint: Color = .indigo
    @State private var alert: KitoAlert?

    var body: some View {
        MockAppScreen(title: "Account", tint: tint) { trigger("Show alert", systemImage: "exclamationmark.bubble") { alert = make() } }
            .kitoAlert($alert)
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { alert = make() } }
    }
}

// MARK: - Menus, tips, status

private struct ActionMenuSample: View {
    var title: String?
    var message: String?
    @State private var isPresented = false
    @State private var last = "Nothing chosen yet"

    var body: some View {
        MockAppScreen(title: "Profile", tint: .teal) {
            VStack(spacing: 10) {
                Text(last).font(.caption).foregroundStyle(.secondary)
                trigger("Change photo", systemImage: "camera") { isPresented = true }
            }
        }
        .kitoActionMenu(isPresented: $isPresented, title: title, message: message, actions: [
            KitoMenuAction("Take photo", systemImage: "camera") { last = "Take photo" },
            KitoMenuAction("Choose from library", systemImage: "photo.on.rectangle") { last = "Choose from library" },
            KitoMenuAction("Use an avatar", systemImage: "face.smiling") { last = "Use an avatar" },
            KitoMenuAction("Remove photo", systemImage: "trash", isDestructive: true) { last = "Remove photo" },
        ])
    }
}

private struct TooltipSample: View {
    let edge: VerticalEdge
    @State private var shown = true

    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: edge == .top ? 80 : 0)
            Button { shown.toggle() } label: {
                Image(systemName: "plus").font(.title2.bold()).foregroundStyle(.white).frame(width: 64, height: 64).background(Circle().fill(.indigo))
            }
            .kitoTooltip(isPresented: $shown, "Create your first list", systemImage: "hand.point.up.left.fill", edge: edge)
            Spacer(minLength: edge == .bottom ? 80 : 0)
            Text("Tap the button to toggle the tip.").font(.caption).foregroundStyle(.secondary)
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
    }
}

private struct CoachMarksSample: View {
    @State private var step = 0
    private let tips = ["Search anything", "Filter results", "Your saved items"]

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 40) {
                ForEach(Array(["magnifyingglass", "line.3.horizontal.decrease", "heart"].enumerated()), id: \.offset) { index, symbol in
                    Image(systemName: symbol).font(.title2).frame(width: 52, height: 52).background(Circle().fill(Color.primary.opacity(step == index ? 0.12 : 0.05)))
                        .kitoTooltip(isPresented: Binding(get: { step == index }, set: { if !$0 { step += 1 } }), "\(index + 1)/3 · \(tips[index])", edge: .bottom)
                }
            }
            .padding(.top, 10)
            Spacer(minLength: 70)
            Button(step >= tips.count ? "Replay tour" : "Next tip") { withAnimation { step = step >= tips.count ? 0 : step + 1 } }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .frame(height: 260)
    }
}

private struct StatusSample: View {
    let fails: Bool
    @State private var status: KitoStatusDialogState?

    var body: some View {
        MockAppScreen(title: "Transfer", tint: fails ? .red : .green) {
            trigger(fails ? "Send (will fail)" : "Send KSh 2,000", systemImage: "paperplane.fill") {
                status = .pending(message: "Sending…")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { status = fails ? .failure(message: "Insufficient balance") : .success(message: "Sent to Wycliff N") }
            }
        }
        .kitoStatusDialog($status)
    }
}

private struct SlideSample: View {
    let title: String
    let symbol: String
    let tint: Color
    @State private var id = UUID()

    var body: some View {
        VStack(spacing: 14) {
            KitoSlideToConfirm(title, systemImage: symbol, tint: tint) { try? await Task.sleep(nanoseconds: 1_200_000_000) }
                .id(id)
            Button("Reset") { id = UUID() }.font(.subheadline.weight(.semibold))
        }
    }
}

// MARK: - Hero

private struct HeroStory: Identifiable {
    let id: String
    let eyebrow: String
    let title: String
    let colors: [Color]
    let symbol: String
}

private struct TodaySample: View {
    private let stories = [
        HeroStory(id: "a", eyebrow: "APP OF THE DAY", title: "Build faster with Kito", colors: [.indigo, .purple], symbol: "hammer.fill"),
        HeroStory(id: "b", eyebrow: "GET STARTED", title: "Ten charts in ten minutes", colors: [.orange, .pink], symbol: "chart.xyaxis.line"),
        HeroStory(id: "c", eyebrow: "BEHIND THE DESIGN", title: "The wallet that pops", colors: [.teal, .blue], symbol: "wallet.pass.fill"),
    ]

    var body: some View {
        KitoHeroContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TUESDAY 23 SEPTEMBER").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        Text("Today").font(.largeTitle.bold())
                    }
                    .padding(.top, 50)
                    ForEach(stories) { story in
                        KitoHeroCard(id: story.id, height: 360) {
                            face(story)
                        } expanded: {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Every Kito kit ships with a gallery of live samples, the code behind each one, and a design you can drop straight into an app.")
                                    .font(.title3)
                                ForEach(0..<4, id: \.self) { _ in
                                    Text("Tap a card to open its story, scroll through it, then close it and watch it shrink back into place. The card and the story share one shape, so the move feels like the same object growing.")
                                        .font(.body).foregroundStyle(.secondary)
                                }
                            }
                            .padding(22)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }

    private func face(_ story: HeroStory) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: story.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: story.symbol).font(.system(size: 120)).foregroundStyle(.white.opacity(0.25)).frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(alignment: .leading, spacing: 4) {
                Text(story.eyebrow).font(.caption.weight(.bold)).foregroundStyle(.white.opacity(0.8))
                Text(story.title).font(.title.bold()).foregroundStyle(.white)
            }
            .padding(22)
        }
    }
}

// MARK: - Catalog

private let sheetCode = """
@State private var isPresented = false

ContentView()
    .kitoSheet(isPresented: $isPresented, configuration: KitoSheetConfiguration(
        detents: [.fit, .large], style: .floating
    )) {
        FiltersView()
    }
"""

private let alertCode = """
@State private var alert: KitoAlert?

ContentView().kitoAlert($alert)

alert = KitoAlert(systemImage: "trash.fill", title: "Delete account?",
                  message: "This can't be undone.",
                  actions: [.cancel(), KitoAlertAction("Delete", role: .destructive) { delete() }])
"""

enum ModalSamples {
    static let sections: [KitSection] = [sheets, templates, alerts, menus, confirm, hero]

    static let sheets = KitSection("Sheets", symbol: "rectangle.bottomhalf.inset.filled", [
        KitSample("Fits its content", "Exactly as tall as what's inside.", code: sheetCode) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration()) { InfoSheet(isPresented: $0) } }
        },
        KitSample("Detents", "Peek, half, full: drag between them; it rubber-bands past the top.", code: sheetCode.replacingOccurrences(of: "detents: [.fit, .large], style: .floating", with: "detents: [.fraction(0.3), .fraction(0.6), .large]")) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(detents: [.fraction(0.3), .fraction(0.6), .large]), tint: .orange, title: "Explore") { _ in DetentSheet() } }
        },
        KitSample("Floating card", "Inset from the edges, rounded all round.", code: sheetCode) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(style: .floating)) { InfoSheet(isPresented: $0) } }
        },
        KitSample("Glass", "Translucent material over the screen.", code: sheetCode.replacingOccurrences(of: "style: .floating", with: "style: .glass")) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(style: .glass, backdropOpacity: 0.1), tint: .pink) { InfoSheet(isPresented: $0) } }
        },
        KitSample("Blurred backdrop", "The screen behind softens.", code: "KitoSheetConfiguration(blursBackdrop: true)") {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(blursBackdrop: true), tint: .teal) { InfoSheet(isPresented: $0) } }
        },
        KitSample("Must choose", "No tap-outside or drag-down dismiss.", code: "KitoSheetConfiguration(dismissesOnBackdropTap: false, dismissesOnDrag: false)") {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(showsGrabber: false, dismissesOnBackdropTap: false, dismissesOnDrag: false)) { CookieSheet(isPresented: $0) } }
        },
    ])

    static let templates = KitSection("Ready-made sheets", symbol: "square.stack.3d.up", [
        KitSample("Filters", "Chips, a price slider and an apply button.", code: sheetCode) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(style: .floating), tint: .orange, title: "Food") { FiltersSheet(isPresented: $0) } }
        },
        KitSample("Share", "People and apps.", code: sheetCode) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(), tint: .pink, title: "Trips") { ShareSheet(isPresented: $0) } }
        },
        KitSample("Checkout with slide to pay", "Order summary and a slide-to-confirm.", code: sheetCode + "\n\nKitoSlideToConfirm(\"Slide to pay\", tint: .green) { try await pay() }") {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(), tint: .green, title: "Cart") { CheckoutSheet(isPresented: $0) } }
        },
        KitSample("Paywall", "Gradient header, plans, free trial.", code: sheetCode.replacingOccurrences(of: "detents: [.fit, .large], style: .floating", with: "detents: [.large]")) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(detents: [.large]), tint: .purple) { PaywallSheet(isPresented: $0) } }
        },
        KitSample("Rate the app", "Stars that bounce as you pick.", code: sheetCode) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(style: .floating)) { RatingSheet(isPresented: $0) } }
        },
        KitSample("Cookie consent", "Essential only or accept all.", code: sheetCode) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration(style: .floating, showsGrabber: false, dismissesOnBackdropTap: false)) { CookieSheet(isPresented: $0) } }
        },
        KitSample("Sign in", "KitoFields email and KitoButtons choices.", code: sheetCode) {
            ModalStage { SheetSample(configuration: KitoSheetConfiguration()) { SignInSheet(isPresented: $0) } }
        },
    ])

    static let alerts = KitSection("Alerts", symbol: "exclamationmark.bubble", [
        KitSample("Simple", "An icon, a title and OK.", code: alertCode) {
            ModalStage { AlertSample(make: { KitoAlert(systemImage: "bell.badge.fill", title: "Notifications on", message: "We'll let you know when your order ships.") }) }
        },
        KitSample("Delete account", "Destructive, side-by-side actions.", code: alertCode) {
            ModalStage { AlertSample(make: { KitoAlert(systemImage: "trash.fill", title: "Delete account?", message: "Your wallet, cards and history will be removed. This can't be undone.", actions: [.cancel(), KitoAlertAction("Delete", role: .destructive)]) }, tint: .red) }
        },
        KitSample("Several choices", "Stacked when there are more than two.", code: alertCode) {
            ModalStage { AlertSample(make: { KitoAlert(systemImage: "location.fill", tint: .blue, title: "Share your location?", message: "For faster delivery estimates.", actions: [KitoAlertAction("While using the app"), KitoAlertAction("Only once", role: .secondary), .cancel("Don't allow")]) }, tint: .blue) }
        },
        KitSample("Celebration", "Confetti for a big moment.", code: alertCode.replacingOccurrences(of: "actions: [.cancel(), KitoAlertAction(\"Delete\", role: .destructive) { delete() }])", with: "celebrates: true)")) {
            ModalStage { AlertSample(make: { KitoAlert(systemImage: "party.popper.fill", tint: .orange, title: "Order placed!", message: "Mama's Kitchen is preparing it now.", actions: [KitoAlertAction("Track order")], celebrates: true) }, tint: .orange) }
        },
        KitSample("Update available", "A version note and two paths.", code: alertCode) {
            ModalStage { AlertSample(make: { KitoAlert(systemImage: "arrow.down.circle.fill", tint: .green, title: "Kito 2.0 is here", message: "New galleries, a wallet and a photo editor.", actions: [KitoAlertAction("Later", role: .cancel), KitoAlertAction("Update")]) }, tint: .green) }
        },
    ])

    static let menus = KitSection("Menus, tips & status", symbol: "list.bullet.rectangle", [
        KitSample("Action menu", "Icon rows and a separate Cancel.", code: "ContentView().kitoActionMenu(isPresented: $shows, actions: [\n    KitoMenuAction(\"Take photo\", systemImage: \"camera\") { … },\n    KitoMenuAction(\"Remove photo\", systemImage: \"trash\", isDestructive: true) { … },\n])") {
            ModalStage { ActionMenuSample() }
        },
        KitSample("Action menu with a title", "A header explains the choice.", code: ".kitoActionMenu(isPresented: $shows, title: \"Profile photo\", message: \"Shown on your receipts\", actions: …)") {
            ModalStage { ActionMenuSample(title: "Profile photo", message: "Shown to people you pay and on your receipts.") }
        },
        KitSample("Tooltip above", "A bubble pointing down at the button.", code: "Button { … }\n    .kitoTooltip(isPresented: $shows, \"Create your first list\", edge: .top)") { TooltipSample(edge: .top) },
        KitSample("Tooltip below", "Pointing up, for toolbar items.", code: ".kitoTooltip(isPresented: $shows, \"…\", edge: .bottom)") { TooltipSample(edge: .bottom) },
        KitSample("Coach marks", "A three-step tour across a toolbar.", code: "ForEach(tips.indices) { i in\n    item(i).kitoTooltip(isPresented: .constant(step == i), tips[i], edge: .bottom)\n}") { CoachMarksSample() },
        KitSample("Sending money", "Pending, then success.", code: "@State private var status: KitoStatusDialogState?\n\n.kitoStatusDialog($status)\nstatus = .pending(message: \"Sending…\")\nstatus = .success(message: \"Sent\")") { ModalStage { StatusSample(fails: false) } },
        KitSample("A failed payment", "Pending, then failure.", code: "status = .failure(message: \"Insufficient balance\")") { ModalStage { StatusSample(fails: true) } },
    ])

    static let confirm = KitSection("Slide to confirm", symbol: "arrow.right.circle", [
        KitSample("Slide to pay", "Drag the knob to the end.", code: "KitoSlideToConfirm(\"Slide to pay\", systemImage: \"creditcard.fill\", tint: .green) {\n    try await pay()\n}") { SlideSample(title: "Slide to pay KSh 1,540", symbol: "creditcard.fill", tint: .green) },
        KitSample("Slide to unlock", "Brand-coloured.", code: "KitoSlideToConfirm(\"Slide to unlock\", systemImage: \"lock.open.fill\")") { SlideSample(title: "Slide to unlock", symbol: "lock.open.fill", tint: .indigo) },
        KitSample("Slide to delete", "For irreversible actions.", code: "KitoSlideToConfirm(\"Slide to delete\", systemImage: \"trash.fill\", tint: .red)") { SlideSample(title: "Slide to delete account", symbol: "trash.fill", tint: .red) },
    ])

    static let hero = KitSection("Hero cards", symbol: "rectangle.expand.vertical", [
        KitSample("Today cards", "Tap a card: it grows into its story; close it and it shrinks back.", code: """
        KitoHeroContainer {
            ScrollView {
                ForEach(stories) { story in
                    KitoHeroCard(id: story.id, height: 360) {
                        StoryFace(story)
                    } expanded: {
                        StoryBody(story)
                    }
                }
            }
        }
        """) { ModalStage { TodaySample() } },
    ])
}

/// Every modal sample.
struct ModalsGallery: View {
    static var count: Int { KitGallery.count(ModalSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Modals",
            sections: ModalSamples.sections,
            footnote: "Requires `import KitoModals`. Samples open inside the frame; Open full screen shows them for real.",
            searchHint: "Try “sheet”, “paywall”, “alert”, “tooltip” or “slide”."
        )
    }
}
