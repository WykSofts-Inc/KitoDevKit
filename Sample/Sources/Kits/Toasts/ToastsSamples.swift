//
//  ToastsSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoToasts

// MARK: - Stage

/// A button in a toast sample's phone screen. The first one fires on appear.
private struct ToastsTrigger {
    let title: String
    let symbol: String
    let fire: @MainActor (KitoToastCenter) -> Void

    init(_ title: String, symbol: String, fire: @escaping @MainActor (KitoToastCenter) -> Void) {
        self.title = title
        self.symbol = symbol
        self.fire = fire
    }
}

/// The app behind the toasts.
private enum ToastsScene {
    case wallet, shop, chat

    var title: String {
        switch self {
        case .wallet: return "Kito Pay"
        case .shop: return "Duka"
        case .chat: return "Messages"
        }
    }

    var greeting: String {
        switch self {
        case .wallet: return "Habari, Wycliff"
        case .shop: return "Fresh from Marikiti"
        case .chat: return "3 unread"
        }
    }

    var colors: [Color] {
        switch self {
        case .wallet: return [Color(red: 0.16, green: 0.2, blue: 0.55), Color(red: 0.42, green: 0.25, blue: 0.8)]
        case .shop: return [Color(red: 1.0, green: 0.52, blue: 0.2), Color(red: 0.93, green: 0.25, blue: 0.4)]
        case .chat: return [Color(red: 0.1, green: 0.6, blue: 0.45), Color(red: 0.1, green: 0.45, blue: 0.75)]
        }
    }

    var hero: (label: String, value: String, symbol: String) {
        switch self {
        case .wallet: return ("Balance", "KSh 48,250.00", "creditcard.fill")
        case .shop: return ("Your basket", "6 items · KSh 2,340", "basket.fill")
        case .chat: return ("Safari Crew", "Diani trip this weekend 🏖️", "person.3.fill")
        }
    }

    var rows: [(symbol: String, title: String, detail: String, trailing: String)] {
        switch self {
        case .wallet:
            return [("arrow.up.right", "Achieng Odhiambo", "Sent · 09:41", "−2,500"),
                    ("bolt.fill", "KPLC Tokens", "Paybill 888880", "−1,000"),
                    ("arrow.down.left", "Baraka Otieno", "Received · Yesterday", "+4,000"),
                    ("cart.fill", "Naivas Westlands", "Till 5120346", "−3,160")]
        case .shop:
            return [("carrot.fill", "Sukuma wiki", "2 bunches", "80"),
                    ("leaf.fill", "Avocado (Hass)", "4 pieces", "200"),
                    ("drop.fill", "Fresh milk", "Brookside 1L", "130"),
                    ("birthday.cake.fill", "Mandazi", "Dozen", "240")]
        case .chat:
            return [("person.fill", "Amani Wanjiru", "Tuonane saa saba?", "09:40"),
                    ("person.fill", "Chebet Kiprono", "Nimetuma location 📍", "08:12"),
                    ("person.fill", "Juma Hassan", "Voice note · 0:14", "Yesterday"),
                    ("person.fill", "Njeri Kamau", "Asante sana!", "Mon")]
        }
    }
}

/// A phone-framed screen with its own toast center, so positions and stacks play out
/// inside the frame rather than over the whole DevKit.
private struct ToastsStage: View {
    var scene: ToastsScene = .wallet
    var position: KitoToastPosition = .top
    var presentation: KitoToastPresentation = .single
    var appearance: KitoToastAppearance = .default
    let triggers: [ToastsTrigger]

    var body: some View {
        ModalStage {
            ToastsPhone(scene: scene, position: position, presentation: presentation, appearance: appearance, triggers: triggers)
        }
    }
}

private struct ToastsPhone: View {
    let scene: ToastsScene
    let appearance: KitoToastAppearance
    let triggers: [ToastsTrigger]
    @State private var center: KitoToastCenter

    init(scene: ToastsScene, position: KitoToastPosition, presentation: KitoToastPresentation, appearance: KitoToastAppearance, triggers: [ToastsTrigger]) {
        self.scene = scene
        self.appearance = appearance
        self.triggers = triggers
        _center = State(initialValue: KitoToastCenter(position: position, presentation: presentation))
    }

    var body: some View {
        ToastsMockScreen(scene: scene) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(triggers.enumerated()), id: \.offset) { index, trigger in
                        Button { trigger.fire(center) } label: {
                            Label(trigger.title, systemImage: trigger.symbol)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .frame(minHeight: 40)
                                .background(Capsule().fill(index == 0 ? Color.primary : Color.primary.opacity(0.08)))
                                .foregroundStyle(index == 0 ? Color(.systemBackground) : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .kitoToastHost(center)
        .kitoToastAppearance(appearance)
        .task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            triggers.first?.fire(center)
        }
        .onDisappear { center.dismissAll() }
    }
}

private struct ToastsMockScreen<Controls: View>: View {
    let scene: ToastsScene
    @ViewBuilder let controls: () -> Controls

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(scene.greeting).font(.subheadline).foregroundStyle(.secondary)
                    Text(scene.title).font(.largeTitle.bold())
                }
                .padding(.horizontal, 20)
                .padding(.top, 64)

                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: scene.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    Circle().fill(.white.opacity(0.12)).frame(width: 180).offset(x: 200, y: -60)
                    Circle().fill(.white.opacity(0.08)).frame(width: 120).offset(x: 250, y: 30)
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: scene.hero.symbol).font(.title3).foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        Text(scene.hero.label).font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.75))
                        Text(scene.hero.value).font(.title2.bold()).foregroundStyle(.white)
                    }
                    .padding(18)
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: scene.colors[0].opacity(0.35), radius: 16, y: 10)
                .padding(.horizontal, 20)

                controls()

                VStack(spacing: 0) {
                    ForEach(Array(scene.rows.enumerated()), id: \.offset) { index, row in
                        HStack(spacing: 12) {
                            Image(systemName: row.symbol)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(scene.colors[index % 2])
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(scene.colors[index % 2].opacity(0.14)))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(row.title).font(.subheadline.weight(.semibold))
                                Text(row.detail).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(row.trailing).font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        if index < scene.rows.count - 1 { Divider().padding(.leading, 52) }
                    }
                }
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
                .padding(.horizontal, 20)
                Spacer(minLength: 0)
            }
        }
    }
}

private struct ToastsDemoError: LocalizedError {
    var errorDescription: String? { "Airtel Money isn't responding. Try again in a minute." }
}

// MARK: - Toasts used by several samples

private enum ToastsLibrary {
    static let sent = KitoToast(title: "Payment sent", message: "KSh 2,500 to Achieng Odhiambo", style: .success)

    static func layout(_ layout: KitoToastLayout) -> ToastsTrigger {
        ToastsTrigger("Show toast", symbol: "bubble.left.fill") { center in
            switch layout {
            case .pill:
                center.show(KitoToast(message: "Copied till number 5120346", style: .success, icon: .custom("doc.on.doc.fill"), layout: .pill))
            case .banner:
                center.show(KitoToast(title: "You're offline", message: "We'll send your KSh 1,200 as soon as you're back.", style: .warning, icon: .custom("wifi.slash"), layout: .banner))
            case .glass:
                center.show(KitoToast(title: "Saved to Trips", message: "Diani Beach · 3 nights", style: .info, icon: .custom("bookmark.fill"), accentColor: .teal, layout: .glass))
            case .island:
                center.show(KitoToast(title: "Rider arriving", message: "Juma · KMFX 204C · 2 min", style: .info, icon: .custom("bicycle"), layout: .island))
            case .card:
                center.show(sent)
            }
        }
    }

    @MainActor
    static func upload(_ center: KitoToastCenter) {
        let id = UUID()
        center.show(KitoToast(id: id, title: "Uploading receipt", message: "naivas-westlands.pdf", icon: .custom("arrow.up.doc.fill"), progress: KitoToastProgress(fraction: 0)))
        Task { @MainActor in
            for step in 1...20 {
                try? await Task.sleep(nanoseconds: 110_000_000)
                center.updateProgress(id: id, fraction: Double(step) / 20)
            }
            center.complete(id: id, style: .success, title: "Receipt uploaded", message: "Shared with Finance · Kito Books")
        }
    }
}

// MARK: - Code

private let showCode = """
@Environment(KitoToastCenter.self) private var toasts

toasts.show(KitoToast(
    title: "Payment sent",
    message: "KSh 2,500 to Achieng Odhiambo",
    style: .success
))
"""

private func layoutCode(_ name: String, _ extra: String) -> String {
    """
    toasts.show(KitoToast(
        \(extra),
        layout: .\(name)
    ))
    """
}

private let hostCode = """
@State private var toasts = KitoToastCenter(position: .top, presentation: .stacked)

var body: some Scene {
    WindowGroup {
        ContentView()
            .kitoToastHost(toasts)
            .environment(toasts)
    }
}
"""

// MARK: - Catalogue

enum ToastsSamples {
    static let sections: [KitSection] = [layouts, styles, people, actions, progress, stacking, custom]

    static let layouts = KitSection("Layouts", symbol: "rectangle.stack", [
        KitSample("Card", "The default: accent bar, icon, title and message.", code: showCode) {
            ToastsStage(triggers: [ToastsLibrary.layout(.card)])
        },
        KitSample("Pill", "A compact capsule for quick confirmations.", code: layoutCode("pill", "message: \"Copied till number 5120346\", style: .success,\n    icon: .custom(\"doc.on.doc.fill\")")) {
            ToastsStage(scene: .shop, triggers: [ToastsLibrary.layout(.pill)])
        },
        KitSample("Banner", "Edge to edge in the accent colour, for things that matter.", code: layoutCode("banner", "title: \"You're offline\", message: \"We'll send it when you're back.\",\n    style: .warning, icon: .custom(\"wifi.slash\")")) {
            ToastsStage(triggers: [ToastsLibrary.layout(.banner)])
        },
        KitSample("Glass", "Frosted, with a soft glow in the accent colour.", code: layoutCode("glass", "title: \"Saved to Trips\", message: \"Diani Beach · 3 nights\",\n    icon: .custom(\"bookmark.fill\"), accentColor: .teal")) {
            ToastsStage(scene: .chat, triggers: [ToastsLibrary.layout(.glass)])
        },
        KitSample("Dynamic Island", "Grows out of the island at the top of the screen.", code: layoutCode("island", "title: \"Rider arriving\", message: \"Juma · KMFX 204C · 2 min\",\n    icon: .custom(\"bicycle\")")) {
            ToastsStage(scene: .shop, triggers: [ToastsLibrary.layout(.island)])
        },
    ])

    static let styles = KitSection("Styles", symbol: "paintpalette", [
        KitSample("Success", "Green, with a success haptic.", code: "toasts.show(\"Payment sent to Achieng\", style: .success)") {
            ToastsStage(triggers: [ToastsTrigger("Success", symbol: "checkmark.circle.fill") { $0.show(ToastsLibrary.sent) }])
        },
        KitSample("Error", "Red, with an error haptic.", code: "toasts.show(KitoToast(title: \"Payment failed\",\n    message: \"Your M-Pesa PIN was incorrect.\", style: .error))") {
            ToastsStage(triggers: [ToastsTrigger("Error", symbol: "xmark.octagon.fill") {
                $0.show(KitoToast(title: "Payment failed", message: "Your M-Pesa PIN was incorrect. 2 tries left.", style: .error))
            }])
        },
        KitSample("Warning", "Amber, for heads-ups.", code: "toasts.show(KitoToast(title: \"Low balance\",\n    message: \"KSh 320 left after this payment.\", style: .warning))") {
            ToastsStage(triggers: [ToastsTrigger("Warning", symbol: "exclamationmark.triangle.fill") {
                $0.show(KitoToast(title: "Low balance", message: "KSh 320 left after this payment.", style: .warning))
            }])
        },
        KitSample("Info", "Neutral, for news.", code: "toasts.show(KitoToast(title: \"Statement ready\",\n    message: \"Your September statement is ready.\", style: .info))") {
            ToastsStage(triggers: [ToastsTrigger("Info", symbol: "info.circle.fill") {
                $0.show(KitoToast(title: "Statement ready", message: "Your September statement is ready to download.", style: .info, icon: .custom("doc.richtext.fill")))
            }])
        },
    ])

    static let people = KitSection("People & brands", symbol: "person.crop.circle", [
        KitSample("Money received", "An avatar in place of the icon.", code: """
        toasts.show(KitoToast(
            title: "Achieng sent you KSh 2,000",
            message: "“Lunch ya jana 🙏🏾”",
            style: .success,
            layout: .glass,
            avatar: KitoToastAvatar(initials: "AO", colors: [.orange, .pink])
        ))
        """) {
            ToastsStage(triggers: [ToastsTrigger("Receive", symbol: "arrow.down.left") {
                $0.show(KitoToast(title: "Achieng sent you KSh 2,000", message: "“Lunch ya jana 🙏🏾”", style: .success, layout: .glass,
                                  avatar: KitoToastAvatar(initials: "AO", colors: [.orange, .pink])))
            }])
        },
        KitSample("New message", "An avatar with a reply action, in the island.", code: """
        KitoToast(title: "Amani Wanjiru", message: "Tuonane Java House saa saba?",
                  actions: [KitoToastAction(title: "Reply", icon: "arrowshape.turn.up.left.fill", content: .iconAndTitle) { reply() }],
                  layout: .island,
                  avatar: KitoToastAvatar(initials: "AW", colors: [.teal, .blue]))
        """) {
            ToastsStage(scene: .chat, triggers: [ToastsTrigger("Message", symbol: "bubble.left.fill") { center in
                center.show(KitoToast(title: "Amani Wanjiru", message: "Tuonane Java House saa saba?",
                                      actions: [KitoToastAction(title: "Reply", icon: "arrowshape.turn.up.left.fill", content: .iconAndTitle) {
                                          center.show(KitoToast(message: "Reply sent", style: .success, layout: .pill))
                                      }],
                                      duration: 5, layout: .island, avatar: KitoToastAvatar(initials: "AW", colors: [.teal, .blue])))
            }])
        },
        KitSample("Brand", "A symbol avatar for a merchant or service.", code: "KitoToast(title: \"Kito Eats\", message: \"Your pilau is on its way\",\n    avatar: KitoToastAvatar(initials: \"KE\", colors: [.orange, .red], systemImage: \"takeoutbag.and.cup.and.straw.fill\"))") {
            ToastsStage(scene: .shop, triggers: [ToastsTrigger("Order update", symbol: "takeoutbag.and.cup.and.straw.fill") {
                $0.show(KitoToast(title: "Kito Eats", message: "Your pilau from Mama Oliech is on its way", style: .info,
                                  avatar: KitoToastAvatar(initials: "KE", colors: [.orange, .red], systemImage: "takeoutbag.and.cup.and.straw.fill")))
            }])
        },
    ])

    static let actions = KitSection("Actions", symbol: "hand.tap", [
        KitSample("Undo with a countdown", "A ring empties beside Undo, then the toast goes.", code: """
        toasts.show(KitoToast(
            message: "Sukuma wiki removed",
            icon: .custom("trash.fill"),
            actions: [KitoToastAction(title: "Undo") { restore() }],
            duration: 5,
            layout: .pill,
            showsCountdown: true
        ))
        """) {
            ToastsStage(scene: .shop, position: .bottom, triggers: [ToastsTrigger("Remove item", symbol: "trash") { center in
                center.show(KitoToast(message: "Sukuma wiki removed from basket", icon: .custom("trash.fill"),
                                      actions: [KitoToastAction(title: "Undo") { center.show(KitoToast(message: "Restored", style: .success, layout: .pill)) }],
                                      duration: 5, layout: .pill, showsCountdown: true))
            }])
        },
        KitSample("Icon and title buttons", "Two actions; it waits for you.", code: """
        KitoToast(title: "Friend request", message: "Baraka Otieno wants to split bills with you",
                  actions: [
                      KitoToastAction(title: "Accept", icon: "checkmark", content: .iconAndTitle) { accept() },
                      KitoToastAction(title: "Ignore", icon: "xmark", content: .iconAndTitle, role: .cancel) { },
                  ])
        """) {
            ToastsStage(scene: .chat, triggers: [ToastsTrigger("Request", symbol: "person.badge.plus") { center in
                center.show(KitoToast(title: "Friend request", message: "Baraka Otieno wants to split bills with you",
                                      icon: .custom("person.2.fill"),
                                      actions: [KitoToastAction(title: "Accept", icon: "checkmark", content: .iconAndTitle) {
                                                    center.show(KitoToast(message: "You and Baraka are now connected", style: .success, layout: .pill))
                                                },
                                                KitoToastAction(title: "Ignore", icon: "xmark", content: .iconAndTitle, role: .cancel) {}]))
            }])
        },
        KitSample("Icon-only buttons", "Compact controls for media.", code: "actions: [\n    KitoToastAction(title: \"Play\", icon: \"play.fill\", content: .iconOnly) { play() },\n    KitoToastAction(title: \"Remove\", icon: \"trash\", content: .iconOnly, role: .destructive) { remove() },\n]") {
            ToastsStage(triggers: [ToastsTrigger("Queue song", symbol: "music.note") {
                $0.show(KitoToast(title: "Added to queue", message: "Sauti Sol · Suzanna", icon: .custom("music.note"),
                                  actions: [KitoToastAction(title: "Play now", icon: "play.fill", content: .iconOnly) {},
                                            KitoToastAction(title: "Remove", icon: "trash", content: .iconOnly, role: .destructive) {}]))
            }])
        },
        KitSample("Destructive", "A red action on a warning.", code: "KitoToast(title: \"Session expiring\", message: \"…\", style: .warning,\n    actions: [KitoToastAction(title: \"Sign out\", role: .destructive) { signOut() }])") {
            ToastsStage(triggers: [ToastsTrigger("Expiring", symbol: "clock.badge.exclamationmark") { center in
                center.show(KitoToast(title: "Session expiring", message: "You'll be signed out in 2 minutes for your security.", style: .warning,
                                      actions: [KitoToastAction(title: "Stay signed in") { center.dismissAll() },
                                                KitoToastAction(title: "Sign out", role: .destructive) {}]))
            }])
        },
    ])

    static let progress = KitSection("Progress & promises", symbol: "arrow.triangle.2.circlepath", [
        KitSample("Upload progress", "A bar fills in place, then the same toast turns into a success.", code: """
        let id = UUID()
        toasts.show(KitoToast(id: id, title: "Uploading receipt", message: "naivas.pdf",
                              progress: KitoToastProgress(fraction: 0)))
        for try await fraction in upload.progress {
            toasts.updateProgress(id: id, fraction: fraction)
        }
        toasts.complete(id: id, style: .success, title: "Receipt uploaded")
        """) {
            ToastsStage(triggers: [ToastsTrigger("Upload", symbol: "arrow.up.doc", fire: ToastsLibrary.upload)])
        },
        KitSample("Promise: success", "A spinner while the work runs, then success.", code: """
        try await toasts.promise(loading: "Sending KSh 1,200 to Baraka…",
                                 success: "Sent. New balance KSh 47,050",
                                 layout: .pill) {
            try await wallet.send(1_200, to: baraka)
        }
        """) {
            ToastsStage(triggers: [ToastsTrigger("Send money", symbol: "paperplane.fill") { center in
                Task { try? await center.promise(loading: "Sending KSh 1,200 to Baraka…", success: "Sent. New balance KSh 47,050", layout: .pill) {
                    try await Task.sleep(nanoseconds: 1_800_000_000)
                } }
            }])
        },
        KitSample("Promise: failure", "The error's message becomes the toast.", code: """
        do {
            try await toasts.promise(loading: "Buying airtime…", success: "Airtime sent") {
                try await airtime.buy(100)
            }
        } catch { /* already shown */ }
        """) {
            ToastsStage(triggers: [ToastsTrigger("Buy airtime", symbol: "antenna.radiowaves.left.and.right") { center in
                Task { try? await center.promise(loading: "Buying KSh 100 airtime…", success: "Airtime sent") {
                    try await Task.sleep(nanoseconds: 1_600_000_000)
                    throw ToastsDemoError()
                } }
            }])
        },
    ])

    static let stacking = KitSection("Stacking & position", symbol: "square.stack.3d.down.right", [
        KitSample("Stacked", "New toasts land on top; tap the stack to fan it out.", code: hostCode) {
            ToastsStage(scene: .chat, presentation: .stacked, triggers: [ToastsTrigger("Three at once", symbol: "square.stack.fill") { center in
                center.show(KitoToast(title: "Chebet Kiprono", message: "Nimetuma location 📍", duration: 8, avatar: KitoToastAvatar(initials: "CK", colors: [.purple, .pink])))
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 350_000_000)
                    center.show(KitoToast(title: "Juma Hassan", message: "Voice note · 0:14", duration: 8, avatar: KitoToastAvatar(initials: "JH", colors: [.green, .teal])))
                    try? await Task.sleep(nanoseconds: 350_000_000)
                    center.show(KitoToast(title: "Njeri Kamau", message: "Asante sana! 🙏🏾", duration: 8, avatar: KitoToastAvatar(initials: "NK", colors: [.orange, .yellow])))
                }
            }, ToastsTrigger("One more", symbol: "plus") {
                $0.show(KitoToast(title: "Safari Crew", message: "Baraka: SGR tickets booked 🚆", duration: 8, avatar: KitoToastAvatar(initials: "SC", colors: [.indigo, .blue])))
            }])
        },
        KitSample("Bottom", "Rises from the bottom edge, near the thumb.", code: "KitoToastCenter(position: .bottom)") {
            ToastsStage(scene: .shop, position: .bottom, triggers: [ToastsTrigger("Add to basket", symbol: "basket.fill") {
                $0.show(KitoToast(message: "Avocado (Hass) added · KSh 200", style: .success, icon: .custom("basket.fill"), layout: .pill))
            }])
        },
        KitSample("Queue", "One at a time; the rest wait their turn.", code: "toasts.show(\"Syncing M-Pesa statement\")\ntoasts.show(\"42 new transactions\")\ntoasts.show(\"All caught up\", style: .success)") {
            ToastsStage(triggers: [ToastsTrigger("Queue three", symbol: "list.number") { center in
                center.show(KitoToast(message: "Syncing M-Pesa statement", icon: .custom("arrow.triangle.2.circlepath"), duration: 1.6))
                center.show(KitoToast(message: "42 new transactions", icon: .custom("list.bullet.rectangle.fill"), duration: 1.6))
                center.show(KitoToast(message: "All caught up", style: .success, duration: 1.6))
            }])
        },
        KitSample("Stacked at the bottom", "A stack that grows upwards.", code: "KitoToastCenter(position: .bottom, presentation: .stack(maxVisible: 4))") {
            ToastsStage(scene: .shop, position: .bottom, presentation: .stack(maxVisible: 4), triggers: [ToastsTrigger("Add item", symbol: "plus") { center in
                let items = ["Sukuma wiki", "Mandazi", "Fresh milk", "Avocado", "Chapati"]
                center.show(KitoToast(message: "\(items.randomElement() ?? "Item") added", style: .success, icon: .custom("basket.fill"), duration: 6, layout: .pill))
            }])
        },
    ])

    static let custom = KitSection("Custom look", symbol: "wand.and.stars", [
        KitSample("Gradient background", "One celebratory toast with its own background.", code: """
        KitoToast(title: "Level up!", message: "You've saved KSh 50,000 this year 🎉",
                  icon: .custom("trophy.fill"),
                  backgroundStyle: .gradient(.linear(.purple, .pink, .orange)))
        """) {
            ToastsStage(triggers: [ToastsTrigger("Celebrate", symbol: "trophy.fill") {
                $0.show(KitoToast(title: "Level up!", message: "You've saved KSh 50,000 this year 🎉", icon: .custom("trophy.fill"), titleStyle: .large, isBold: true,
                                  backgroundStyle: .gradient(.linear(.purple, .pink, .orange))))
            }])
        },
        KitSample("App-wide appearance", "Fonts, corners, accent bar and width, set once at the root.", code: """
        ContentView()
            .kitoToastAppearance(KitoToastAppearance(
                mediumTitleFont: .system(size: 17, weight: .bold, design: .rounded),
                cornerRadius: 26,
                showsAccentBar: false,
                iconSize: 22,
                backgroundStyle: .color(Color(white: 0.1))
            ))
        """) {
            ToastsStage(appearance: KitoToastAppearance(mediumTitleFont: .system(size: 17, weight: .bold, design: .rounded),
                                                        messageFont: .system(size: 14, weight: .medium, design: .rounded),
                                                        cornerRadius: 26, showsAccentBar: false, iconSize: 22,
                                                        backgroundStyle: .color(Color(white: 0.1))),
                        triggers: [ToastsTrigger("Show", symbol: "paintbrush.fill") {
                $0.show(KitoToast(title: "Tokens bought", message: "KPLC · 34.2 kWh · 4521 8890 1123", style: .success, icon: .custom("bolt.fill")))
            }])
        },
    ])
}

/// Every toast sample. Keeps the home screen's entry name.
struct ToastsDemo: View {
    static var count: Int { KitGallery.count(ToastsSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Toasts",
            sections: ToastsSamples.sections,
            footnote: "Requires `import KitoToasts`. Samples play inside the frame; Open full screen shows them for real.",
            searchHint: "Try “undo”, “stack”, “island”, “upload” or “avatar”."
        )
    }
}
