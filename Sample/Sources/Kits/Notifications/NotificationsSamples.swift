//
//  NotificationsSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoNotifications
import UserNotifications

/// App-wide notification setup, called once from `KitoSampleApp.init()`: installs
/// KitoNotifications' delegate so local notifications scheduled anywhere in the app (these
/// samples, KitoOrderTracking's scheduler) show a banner, sound and badge while the app is open,
/// and registers the action sets the samples use.
enum NotificationsSampleSetup {
    @MainActor
    static func install() {
        let center = KitoNotificationCenter.shared
        center.install()
        center.setCategories([
            KitoNotificationCategory("message", actions: [.reply(placeholder: "Reply to Grace"), KitoNotificationAction("mute", title: "Mute for 1 hour", systemImage: "bell.slash")]),
            KitoNotificationCategory("order", actions: [KitoNotificationAction("track", title: "Track rider", systemImage: "location.fill", opensApp: true)]),
            KitoNotificationCategory("payment", actions: [KitoNotificationAction("receipt", title: "View receipt", systemImage: "doc.text.fill", opensApp: true)]),
        ])
    }
}

// MARK: - Data

private func notifAgo(_ minutes: Double) -> Date { Date().addingTimeInterval(-minutes * 60) }

private let notifGreen = Color(red: 0.12, green: 0.68, blue: 0.42)

private func notifInboxItems() -> [KitoInboxNotification] {
    [
        KitoInboxNotification(kind: .order, title: "Your rider is 3 min away", body: "Brian is on a red boda with your Mama's Kitchen order. Have KSh 1,540 ready.", date: notifAgo(2), avatar: .initials("BO", .orange), actionTitle: "Track rider"),
        KitoInboxNotification(kind: .payment, title: "KSh 12,000 received", body: "From Amina Wanjiru via M-Pesa. New balance KSh 48,250.", date: notifAgo(18), avatar: .symbol("arrow.down.left", notifGreen), actionTitle: "View receipt"),
        KitoInboxNotification(kind: .message, title: "Grace Achieng", body: "Tupatane Java House saa nane? I'll bring the chama book.", date: notifAgo(46), avatar: .initials("GA", .purple), actionTitle: "Reply"),
        KitoInboxNotification(kind: .social, title: "Wanjiku liked your photo", body: "“Sunset at Karura” — and 23 others.", date: notifAgo(95), isRead: true, avatar: .initials("WK", .pink)),
        KitoInboxNotification(kind: .security, title: "New sign-in on iPad", body: "Nairobi, Kenya · Safari. Not you? Secure your account.", date: notifAgo(180), avatar: .symbol("lock.shield.fill", .red)),
        KitoInboxNotification(kind: .reminder, title: "KPLC bill due tomorrow", body: "KSh 2,340 for account 1234567. Pay now to avoid disconnection.", date: notifAgo(60 * 20), isRead: true, avatar: .symbol("bolt.fill", Color(red: 0.58, green: 0.36, blue: 0.96)), actionTitle: "Pay"),
        KitoInboxNotification(kind: .order, title: "Delivered", body: "Your Naivas order (12 items) was left with the askari at Kileleshwa.", date: notifAgo(60 * 26), isRead: true, avatar: .symbol("shippingbox.fill", .orange)),
        KitoInboxNotification(kind: .promo, title: "50% off at Artcaffé", body: "This weekend only, on breakfast for two.", date: notifAgo(60 * 50), avatar: .symbol("tag.fill", Color(red: 0.95, green: 0.72, blue: 0.10))),
        KitoInboxNotification(kind: .system, title: "Kito 2.0 is here", body: "New galleries for permissions, keychain and notifications.", date: notifAgo(60 * 24 * 4), isRead: true),
        KitoInboxNotification(kind: .payment, title: "Paid KSh 3,120 to Naivas", body: "Till 552210 · Ref SJK4M2X9QP", date: notifAgo(60 * 24 * 9), isRead: true, avatar: .symbol("cart.fill", notifGreen)),
    ]
}

private let notifBannerQueue: [KitoInboxNotification] = [
    KitoInboxNotification(kind: .payment, title: "KSh 12,000 received", body: "From Amina Wanjiru via M-Pesa", avatar: .symbol("arrow.down.left", notifGreen)),
    KitoInboxNotification(kind: .order, title: "Your rider is 3 min away", body: "Brian is on a red boda — have KSh 1,540 ready.", avatar: .initials("BO", .orange), actionTitle: "Track rider"),
    KitoInboxNotification(kind: .message, title: "Grace Achieng", body: "Tupatane Java House saa nane?", avatar: .initials("GA", .purple)),
    KitoInboxNotification(kind: .security, title: "New sign-in on iPad", body: "Nairobi, Kenya · just now", avatar: .symbol("lock.shield.fill", .red)),
]

// MARK: - Stages

/// The inbox inside the phone frame.
private struct NotifInboxStage: View {
    @State private var items: [KitoInboxNotification]
    let grouping: KitoInboxGrouping
    @State private var opened: KitoInboxNotification?

    init(_ items: [KitoInboxNotification], grouping: KitoInboxGrouping = .todayAndEarlier) {
        _items = State(initialValue: items)
        self.grouping = grouping
    }

    var body: some View {
        KitoNotificationInbox($items, grouping: grouping, onOpen: { opened = $0 }, onAction: { opened = $0 })
            .safeAreaPadding(.top, 40)
            .sheet(item: $opened) { item in
                VStack(spacing: 14) {
                    KitoNotificationAvatarView(item.avatar, kind: item.kind, size: 64)
                    Text(item.title).font(.title3.bold())
                    Text(item.body).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    Button("Done") { opened = nil }.buttonStyle(GalleryPrimaryButtonStyle())
                }
                .padding(28)
                .presentationDetents([.medium])
            }
    }
}

/// Rows in every flavour.
private struct NotifRowsPreview: View {
    private let items = Array(notifInboxItems().prefix(5))

    var body: some View {
        VStack(spacing: 4) {
            ForEach(items) { item in
                KitoNotificationRow(item)
                if item.id != items.last?.id { Divider().padding(.leading, 58) }
            }
        }
    }
}

/// A mock screen with a button that drops an in-app banner.
private struct NotifBannerStage: View {
    let style: KitoNotificationBannerStyle
    @State private var item: KitoInboxNotification?
    @State private var index = 0
    @State private var tapped: String?

    var body: some View {
        MockAppScreen(title: "Wallet", tint: style == .island ? .black : .green) {
            VStack(spacing: 8) {
                if let tapped { Text("Opened: \(tapped)").font(.footnote.weight(.semibold)).foregroundStyle(.secondary) }
                Button {
                    item = notifBannerQueue[index % notifBannerQueue.count]
                    index += 1
                } label: { Label("Simulate a notification", systemImage: "bell.badge.fill").frame(maxWidth: .infinity) }
                .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
        .kitoNotificationBanner($item, style: style) { tapped = $0.title }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { item = notifBannerQueue[0]; index = 1 } }
    }
}

/// Three banners one after another.
private struct NotifBannerBurst: View {
    @State private var item: KitoInboxNotification?
    @State private var running = false

    var body: some View {
        MockAppScreen(title: "Orders", tint: .orange) {
            Button {
                running = true
                Task {
                    for next in notifBannerQueue.prefix(3) {
                        item = next
                        try? await Task.sleep(for: .seconds(2.2))
                    }
                    running = false
                }
            } label: { Label(running ? "Delivering…" : "Play a delivery", systemImage: "play.fill").frame(maxWidth: .infinity) }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(running)
        }
        .kitoNotificationBanner($item, style: .card, duration: .seconds(2))
    }
}

/// Asks (if needed), then schedules a real local notification a few seconds out.
private struct NotifScheduleSample: View {
    private let center = KitoNotificationCenter.shared
    let title: String
    let notification: () -> KitoLocalNotification
    @State private var status = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(center.authorization.label, systemImage: center.authorization.canNotify ? "bell.fill" : "bell.slash")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(center.authorization.canNotify ? Color.green.opacity(0.15) : Color.primary.opacity(0.07)))
                Spacer()
                Label(center.isInstalled ? "Foreground delegate on" : "Delegate not installed", systemImage: center.isInstalled ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(center.isInstalled ? .green : .orange)
            }
            Button {
                Task {
                    if !center.authorization.canNotify { await center.requestAuthorization() }
                    guard center.authorization.canNotify else { status = "Notifications are off for this app. Turn them on in Settings."; return }
                    let request = notification()
                    do {
                        try await center.schedule(request)
                        status = "Scheduled: \(request.trigger.summary). Stay in the app — it still shows."
                    } catch {
                        status = error.localizedDescription
                    }
                }
            } label: { Label(title, systemImage: "bell.badge.fill").frame(maxWidth: .infinity) }
            .buttonStyle(GalleryPrimaryButtonStyle())
            if !status.isEmpty { Text(status).font(.footnote).foregroundStyle(.secondary) }
            if let event = center.lastForegroundEvent {
                Label("Last shown in the app: \(event.title)", systemImage: "rectangle.topthird.inset.filled")
                    .font(.footnote.weight(.semibold))
            }
            if let response = center.lastResponse {
                Label(response.text.map { "Replied: “\($0)”" } ?? "Tapped: \(response.actionID ?? "notification")", systemImage: "hand.tap.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.blue)
            }
        }
        .task { await center.refreshAuthorization() }
    }
}

/// A daily reminder at a chosen time, with the pending list.
private struct NotifDailyReminder: View {
    private let center = KitoNotificationCenter.shared
    @State private var time = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            DatePicker("Remind me at", selection: $time, displayedComponents: .hourAndMinute)
                .font(.subheadline.weight(.medium))
            Button {
                Task {
                    if !center.authorization.canNotify { await center.requestAuthorization() }
                    let parts = Calendar.current.dateComponents([.hour, .minute], from: time)
                    try? await center.schedule(KitoLocalNotification(id: "daily-chama", title: "Chama contribution", body: "Send your KSh 1,000 to the Umoja chama before 9 pm.", trigger: .daily(hour: parts.hour ?? 7, minute: parts.minute ?? 30), categoryID: "payment"))
                }
            } label: { Label("Schedule daily reminder", systemImage: "alarm.fill").frame(maxWidth: .infinity) }
            .buttonStyle(GalleryPrimaryButtonStyle())
            NotifPendingList()
        }
        .task { await center.refresh() }
    }
}

/// Pending and delivered notifications, with cancel and clear.
private struct NotifPendingList: View {
    private let center = KitoNotificationCenter.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Pending · \(center.pending.count)").font(.headline)
                Spacer()
                if !center.pending.isEmpty { Button("Cancel all") { Task { await center.cancelAll() } }.font(.subheadline.weight(.semibold)) }
            }
            if center.pending.isEmpty {
                Text("Nothing scheduled.").font(.footnote).foregroundStyle(.secondary)
            }
            ForEach(center.pending) { item in
                HStack {
                    Image(systemName: item.repeats ? "repeat" : "clock").foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.title).font(.subheadline.weight(.semibold))
                        Text(item.nextFireDate.map { $0.formatted(date: .abbreviated, time: .shortened) } ?? "—").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button { Task { await center.cancel([item.id]) } } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Cancel \(item.title)")
                }
            }
            Divider()
            HStack {
                Text("Delivered · \(center.delivered.count)").font(.headline)
                Spacer()
                if !center.delivered.isEmpty { Button("Clear") { Task { await center.removeAllDelivered() } }.font(.subheadline.weight(.semibold)) }
            }
            ForEach(center.delivered.prefix(4)) { item in
                Label(item.title, systemImage: "checkmark.circle.fill").font(.subheadline).foregroundStyle(.green)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: center.pending)
        .task { await center.refresh() }
    }
}

/// The app icon badge.
private struct NotifBadgeSample: View {
    private let center = KitoNotificationCenter.shared
    @State private var count = 3

    var body: some View {
        VStack(spacing: 18) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [.black, Color(white: 0.25)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 88, height: 88)
                    .overlay(Text("K").font(.system(size: 44, weight: .bold, design: .rounded)).foregroundStyle(.white))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .frame(minWidth: 28, minHeight: 28)
                        .background(Capsule().fill(Color.red))
                        .offset(x: 10, y: -10)
                        .contentTransition(.numericText())
                        .transition(.scale)
                }
            }
            Stepper("Badge: \(count)", value: $count, in: 0...99)
                .font(.subheadline.weight(.medium))
            HStack(spacing: 8) {
                Button("Set on app icon") { Task { if !center.authorization.canNotify { await center.requestAuthorization() }; await center.setBadge(count) } }
                Button("Clear") { count = 0; Task { await center.clearBadge() } }
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: count)
    }
}

/// Foreground notifications as KitoNotifications' own in-app banner instead of the system one.
private struct NotifCenterBannersSample: View {
    private let center = KitoNotificationCenter.shared
    @State private var previous: UNNotificationPresentationOptions?

    var body: some View {
        MockAppScreen(title: "Chats", tint: .purple) {
            NotifScheduleSample(title: "Send a message in 3 s") {
                KitoLocalNotification(title: "Grace Achieng", body: "Tupatane Java House saa nane?", trigger: .after(3), categoryID: "message", userInfo: ["kind": "message"])
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.regularMaterial))
        }
        .kitoNotificationBanners(from: center, style: .island)
        .onAppear {
            previous = center.foregroundPresentation
            center.foregroundPresentation = [.list, .sound, .badge]
        }
        .onDisappear {
            if let previous { center.foregroundPresentation = previous }
        }
    }
}

/// The priming page, with a simulated answer.
private struct NotifPrimingStage: View {
    let outcome: KitoNotificationAuthorization
    var current: KitoNotificationAuthorization = .notDetermined
    var live = false
    @State private var finished: KitoNotificationAuthorization?
    @State private var run = 0

    var body: some View {
        ZStack {
            if let finished {
                VStack(spacing: 14) {
                    Image(systemName: finished.canNotify ? "bell.badge.fill" : "bell.slash.fill").font(.system(size: 44)).foregroundStyle(finished.canNotify ? .green : .secondary)
                    Text("Finished: \(finished.label)").font(.headline)
                    Button("Replay") { self.finished = nil; run += 1 }.buttonStyle(GalleryPrimaryButtonStyle())
                }
            } else if live {
                KitoNotificationPrimingView { finished = $0 }.id(run)
            } else {
                KitoNotificationPrimingView(
                    authorize: { provisional in
                        try? await Task.sleep(for: .milliseconds(800))
                        return provisional ? .provisional : outcome
                    },
                    currentStatus: { current },
                    onFinish: { finished = $0 }
                )
                .id(run)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

/// The settings screen with a given system status.
private struct NotifSettingsStage: View {
    @State private var preferences = KitoNotificationPreferences.standard
    var authorization: KitoNotificationAuthorization? = nil

    var body: some View {
        KitoNotificationSettingsView($preferences, authorization: authorization)
            .safeAreaPadding(.top, 40)
    }
}

/// The quiet hours dial, driven by two sliders.
private struct NotifQuietDialPlayground: View {
    @State private var start = 22.0
    @State private var end = 7.0

    private var quiet: KitoQuietHours { KitoQuietHours(start: .init(hour: Int(start)), end: .init(hour: Int(end))) }

    var body: some View {
        VStack(spacing: 18) {
            KitoQuietHoursDial(quietHours: quiet).frame(width: 170, height: 170)
            Text(quiet.summary()).font(.headline).contentTransition(.opacity)
            VStack(spacing: 6) {
                HStack { Label("From", systemImage: "moon.stars.fill"); Spacer(); Text(quiet.start.label).monospacedDigit() }.font(.subheadline)
                Slider(value: $start, in: 0...23, step: 1).tint(.indigo)
                HStack { Label("Until", systemImage: "sun.max.fill"); Spacer(); Text(quiet.end.label).monospacedDigit() }.font(.subheadline)
                Slider(value: $end, in: 0...23, step: 1).tint(.orange)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: start)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: end)
    }
}

// MARK: - Code

private let inboxCode = """
@State private var items: [KitoInboxNotification] = store.notifications

KitoNotificationInbox($items, grouping: .todayAndEarlier) { item in
    router.open(item)
}
"""

private let bannerCode = """
@State private var incoming: KitoInboxNotification?

WalletScreen()
    .kitoNotificationBanner($incoming, style: .system) { item in router.open(item) }

incoming = KitoInboxNotification(kind: .payment, title: "KSh 12,000 received",
                                 body: "From Amina Wanjiru via M-Pesa")
"""

private let scheduleCode = """
// Once, at launch — without it iOS drops notifications while the app is open:
init() { KitoNotificationCenter.shared.install() }

await center.requestAuthorization()
try await center.schedule(KitoLocalNotification(
    title: "Mama's Kitchen", body: "Your rider is 3 min away",
    trigger: .after(5), categoryID: "order"))
"""

private let primingCode = """
KitoNotificationPrimingView { status in
    onboarding.finish(notifications: status)
}
"""

private let settingsCode = """
@State private var preferences = KitoNotificationPreferences.standard

KitoNotificationSettingsView($preferences, authorization: center.authorization)

center.preferences = preferences   // foreground notifications respect channels and quiet hours
"""

// MARK: - Samples

enum NotificationsSamples {
    static let sections: [KitSection] = [inbox, banners, local, priming, settings]

    static let inbox = KitSection("Notification centre", symbol: "tray.full.fill", [
        KitSample("Inbox", "Today and Earlier, unread dots, filters; swipe to read or delete.", code: inboxCode) {
            ModalStage { NotifInboxStage(notifInboxItems()) }
        },
        KitSample("Grouped by day", "Today, Yesterday, This week and Earlier.", code: inboxCode.replacingOccurrences(of: ".todayAndEarlier", with: ".byDay")) {
            ModalStage { NotifInboxStage(notifInboxItems(), grouping: .byDay) }
        },
        KitSample("Orders and payments", "Filter chips only for the kinds present.", code: inboxCode) {
            ModalStage { NotifInboxStage(notifInboxItems().filter { $0.kind == .order || $0.kind == .payment }) }
        },
        KitSample("All caught up", "The empty state: a sleeping bell.", code: inboxCode) {
            ModalStage { NotifInboxStage([]) }
        },
        KitSample("Rows", "Initials, brand tiles, kind badges and inline actions.", code: "KitoNotificationRow(item) { handleAction(item) }") { NotifRowsPreview() },
    ])

    static let banners = KitSection("In-app banners", symbol: "rectangle.topthird.inset.filled", [
        KitSample("System style", "Frosted, like iOS's own; swipe up to dismiss.", code: bannerCode) {
            ModalStage { NotifBannerStage(style: .system) }
        },
        KitSample("Card", "A coloured edge and a glow in the kind's colour.", code: bannerCode.replacingOccurrences(of: ".system", with: ".card")) {
            ModalStage { NotifBannerStage(style: .card) }
        },
        KitSample("Island", "A dark capsule that grows out of the top.", code: bannerCode.replacingOccurrences(of: ".system", with: ".island")) {
            ModalStage { NotifBannerStage(style: .island) }
        },
        KitSample("A delivery in three beats", "Banners one after another, each counting down.", code: bannerCode.replacingOccurrences(of: ".system", with: ".card")) {
            ModalStage { NotifBannerBurst() }
        },
    ])

    static let local = KitSection("Local notifications", symbol: "bell.and.waves.left.and.right.fill", [
        KitSample("Shows while the app is open", "Schedule one for 5 s and stay here: the banner still appears.", code: scheduleCode) {
            NotifScheduleSample(title: "Notify me in 5 seconds") {
                KitoLocalNotification(title: "Mama's Kitchen", subtitle: "Order #4821", body: "Your rider is 3 min away — have KSh 1,540 ready.", trigger: .after(5), categoryID: "order", userInfo: ["kind": "order"])
            }
        },
        KitSample("Reply from the notification", "Long-press it and reply; the text comes back here.", code: """
        center.setCategories([KitoNotificationCategory("message", actions: [.reply(placeholder: "Reply to Grace")])])
        center.onAction("reply") { response in chat.send(response.text) }
        """) {
            NotifScheduleSample(title: "Message me in 5 seconds") {
                KitoLocalNotification(title: "Grace Achieng", body: "Tupatane Java House saa nane?", trigger: .after(5), categoryID: "message", threadID: "grace", userInfo: ["kind": "message"])
            }
        },
        KitSample("Daily reminder", "A repeating calendar trigger, with the pending list.", code: "try await center.schedule(KitoLocalNotification(\n    title: \"Chama contribution\", body: \"…\",\n    trigger: .daily(hour: 7, minute: 30)))") { NotifDailyReminder() },
        KitSample("Pending and delivered", "What's scheduled and what's arrived; cancel or clear.", code: "await center.refresh()\ncenter.pending      // next fire date, repeats\ncenter.delivered\nawait center.cancel([id])") { NotifPendingList() },
        KitSample("App icon badge", "Set or clear the count.", code: "await center.setBadge(3)\nawait center.clearBadge()") { NotifBadgeSample() },
        KitSample("Own banner in the foreground", "Swap the system banner for the island banner.", code: "center.foregroundPresentation = [.list, .sound, .badge]\n\nRootView()\n    .kitoNotificationBanners(from: center, style: .island)") {
            ModalStage { NotifCenterBannersSample() }
        },
    ])

    static let priming = KitSection("Permission priming", symbol: "hand.raised.fill", [
        KitSample("Turn on notifications", "Floating sample notifications, then the ask.", code: primingCode) {
            ModalStage { NotifPrimingStage(outcome: .authorized) }
        },
        KitSample("Deliver quietly", "Provisional: no prompt, straight to Notification Centre.", code: "await center.requestAuthorization(provisional: true)") {
            ModalStage { NotifPrimingStage(outcome: .provisional) }
        },
        KitSample("Already turned off", "Offers Settings instead of a prompt that won't show.", code: primingCode) {
            ModalStage { NotifPrimingStage(outcome: .denied, current: .denied) }
        },
        KitSample("Live", "Asks the system for real.", code: primingCode) {
            ModalStage { NotifPrimingStage(outcome: .authorized, live: true) }
        },
    ])

    static let settings = KitSection("Settings", symbol: "slider.horizontal.3", [
        KitSample("Notification settings", "Channels, quiet hours on a 24-hour dial, display options.", code: settingsCode) {
            ModalStage { NotifSettingsStage() }
        },
        KitSample("Notifications are off", "A status card that leads to Settings.", code: settingsCode) {
            ModalStage { NotifSettingsStage(authorization: .denied) }
        },
        KitSample("Delivered quietly", "Provisional, with a way to turn alerts on.", code: settingsCode) {
            ModalStage { NotifSettingsStage(authorization: .provisional) }
        },
        KitSample("Quiet hours dial", "Drag the window; it wraps past midnight.", code: "KitoQuietHoursDial(quietHours: KitoQuietHours(start: .init(hour: 22), end: .init(hour: 7)))") {
            NotifQuietDialPlayground()
        },
    ])
}

/// Every notifications sample.
struct NotificationsGallery: View {
    static var count: Int { KitGallery.count(NotificationsSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Notifications",
            sections: NotificationsSamples.sections,
            footnote: "Requires `import KitoNotifications`. Local notification samples use the real notification centre; the rest run on sample data.",
            searchHint: "Try “inbox”, “banner”, “reply”, “quiet hours” or “badge”."
        )
    }
}
