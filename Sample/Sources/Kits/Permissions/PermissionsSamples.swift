//
//  PermissionsSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoPermissions

// Most samples use `.simulated(…)` so every state — including "denied" — can be shown on demand
// without spending the one real system prompt. Samples marked "Live" ask the system for real.
// App Tracking is never requested: the app doesn't link KitoPermissionsTracking.

// MARK: - Stages

/// A plausible app screen with a button that presents a primer over it.
private struct PermPrimingStage: View {
    let kind: KitoPermissionKind
    let style: KitoPermissionPrimingStyle
    var title = "Home"
    var tint: Color = .indigo
    var trigger = "Continue"
    var content: KitoPermissionPrimingContent?
    @State private var requester: KitoPermissionRequester
    @State private var isPresented = false
    @State private var result: KitoPermissionStatus?

    init(kind: KitoPermissionKind, style: KitoPermissionPrimingStyle, title: String = "Home", tint: Color = .indigo, trigger: String = "Continue", content: KitoPermissionPrimingContent? = nil, requester: KitoPermissionRequester = .simulated()) {
        self.kind = kind
        self.style = style
        self.title = title
        self.tint = tint
        self.trigger = trigger
        self.content = content
        _requester = State(initialValue: requester)
    }

    var body: some View {
        MockAppScreen(title: title, tint: tint) {
            VStack(spacing: 10) {
                if let result {
                    KitoPermissionStatusBadge(status: result).transition(.scale.combined(with: .opacity))
                }
                Button { isPresented = true } label: {
                    Label(trigger, systemImage: kind.systemImage).frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: result)
        }
        .kitoPermissionPriming(isPresented: $isPresented, kind: kind, style: style, content: content, requester: requester) { result = $0 }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isPresented = true } }
    }
}

/// A full-screen primer inside the phone frame, with a Replay button when it's dismissed.
private struct PermFullScreenStage: View {
    let kind: KitoPermissionKind
    var content: KitoPermissionPrimingContent?
    @State private var requester: KitoPermissionRequester
    @State private var shows = true
    @State private var run = 0

    init(kind: KitoPermissionKind, content: KitoPermissionPrimingContent? = nil, requester: KitoPermissionRequester = .simulated()) {
        self.kind = kind
        self.content = content
        _requester = State(initialValue: requester)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
            if shows {
                KitoPermissionPrimer(kind: kind, style: .illustration, content: content, requester: requester, onDismiss: { withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { shows = false } })
                    .id(run)
                    .transition(.move(edge: .bottom))
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 44)).foregroundStyle(.green)
                    Text("Primer dismissed").font(.headline)
                    Button("Replay") { run += 1; withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { shows = true } }
                        .buttonStyle(GalleryPrimaryButtonStyle())
                }
            }
        }
    }
}

/// A feed screen with an inline banner primer at the top.
private struct PermBannerStage: View {
    let kind: KitoPermissionKind
    let title: String
    let rows: [(String, String, String)]
    var tint: Color = .orange
    var content: KitoPermissionPrimingContent?
    @State private var requester: KitoPermissionRequester
    @State private var showsBanner = true

    init(kind: KitoPermissionKind, title: String, rows: [(String, String, String)], tint: Color = .orange, content: KitoPermissionPrimingContent? = nil, requester: KitoPermissionRequester = .simulated()) {
        self.kind = kind
        self.title = title
        self.rows = rows
        self.tint = tint
        self.content = content
        _requester = State(initialValue: requester)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title).font(.largeTitle.bold()).padding(.top, 50)
                if showsBanner {
                    KitoPermissionPrimer(kind: kind, style: .banner, content: content, requester: requester, onDismiss: { withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { showsBanner = false } })
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                ForEach(rows, id: \.0) { row in
                    HStack(spacing: 14) {
                        Image(systemName: row.2)
                            .font(.headline)
                            .foregroundStyle(tint)
                            .frame(width: 46, height: 46)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(tint.opacity(0.14)))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(row.0).font(.headline)
                            Text(row.1).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.secondarySystemBackground)))
                }
                if !showsBanner {
                    Button("Show the banner again") { withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { showsBanner = true } }
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
    }
}

/// Every banner state side by side.
private struct PermBannerStatesPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            KitoPermissionPrimer(kind: .notifications, style: .banner, requester: .simulated(), onDismiss: {})
            KitoPermissionPrimer(kind: .locationWhenInUse, style: .banner, requester: .simulated([.locationWhenInUse: .granted]))
            KitoPermissionPrimer(kind: .camera, style: .banner, requester: .simulated([.camera: .denied]), onDismiss: {})
        }
    }
}

/// A dashboard screen inside the phone frame.
private struct PermDashboardStage: View {
    let kinds: [KitoPermissionKind]
    var reasons: [KitoPermissionKind: String] = [:]
    var title = "App permissions"
    let requester: KitoPermissionRequester

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Privacy").font(.largeTitle.bold()).padding(.top, 50)
                KitoPermissionsDashboard(kinds, reasons: reasons, title: title, requester: requester)
                Text("Changes you make in Settings show up here when you come back.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
    }
}

/// Four status pills, plus the kinds' icon tiles.
private struct PermBadgesPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                ForEach([KitoPermissionStatus.granted, .denied, .notDetermined, .restricted], id: \.self) { KitoPermissionStatusBadge(status: $0) }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 14) {
                ForEach(KitoPermissionKind.allCases, id: \.self) { kind in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LinearGradient(colors: [kind.tint, kind.tint.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .overlay(Image(systemName: kind.systemImage).font(.title3.weight(.semibold)).foregroundStyle(.white))
                        Text(kind.displayName).font(.caption2).multilineTextAlignment(.center).lineLimit(2)
                    }
                }
            }
        }
    }
}

/// Live statuses for every permission the app can ask for, one tap to request.
private struct PermLiveStatusList: View {
    private let kinds: [KitoPermissionKind] = [.camera, .photoLibrary, .microphone, .locationWhenInUse, .notifications, .contacts, .calendar, .reminders, .speechRecognition, .bluetooth]
    @State private var statuses: [KitoPermissionKind: KitoPermissionStatus] = [:]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(kinds, id: \.self) { kind in
                HStack(spacing: 12) {
                    Image(systemName: kind.systemImage).foregroundStyle(kind.tint).frame(width: 24)
                    Text(kind.displayName).font(.subheadline.weight(.medium))
                    Spacer()
                    if let status = statuses[kind], status != .notDetermined {
                        KitoPermissionStatusBadge(status: status)
                    } else {
                        Button("Request") { Task { statuses[kind] = await KitoPermissionManager.shared.request(kind) } }
                            .font(.caption.weight(.semibold))
                            .buttonStyle(GalleryPrimaryButtonStyle())
                            .controlSize(.small)
                    }
                }
                .padding(.vertical, 8)
                if kind != kinds.last { Divider() }
            }
        }
        .task {
            for kind in kinds { statuses[kind] = await KitoPermissionManager.shared.status(for: kind) }
        }
    }
}

/// The 1.0 rationale view, still supported.
private struct PermLegacyRationaleStage: View {
    @State private var shows = true
    @State private var log = "Waiting…"

    var body: some View {
        MockAppScreen(title: "Receipts", tint: .teal) {
            VStack(spacing: 8) {
                Text(log).font(.caption).foregroundStyle(.secondary)
                Button("Scan a receipt") { shows = true }.buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
        .sheet(isPresented: $shows) {
            KitoPermissionRationaleView(
                icon: "camera.fill",
                title: "Scan receipts instantly",
                message: "We use your camera only to scan receipts — nothing is uploaded without your say-so.",
                onContinue: { shows = false; log = "Continue tapped — this is where you'd call request(.camera)." },
                onSkip: { shows = false; log = "Skipped." }
            )
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Code

private let cardCode = """
@State private var asksForCamera = false

ScanToPayScreen()
    .kitoPermissionPriming(isPresented: $asksForCamera, kind: .camera, style: .card) { status in
        if status.isGranted { scanner.start() }
    }
"""

private let illustrationCode = """
KitoPermissionPrimer(kind: .locationWhenInUse, style: .illustration,
                     onDismiss: { dismiss() }) { status in
    if status.isGranted { deliveries.useCurrentLocation() }
}
"""

private let bannerCode = """
List {
    if showsPrimer {
        KitoPermissionPrimer(kind: .notifications, style: .banner,
                             onDismiss: { showsPrimer = false })
    }
    ForEach(orders) { OrderRow($0) }
}
"""

private let customCopyCode = """
KitoPermissionPrimingContent(
    title: "Send money by name",
    message: "Find Wycliff, Amina and the rest of your people without typing numbers.",
    benefits: ["Send to contacts in a tap", "Split bills with friends", "We never message anyone"],
    allowTitle: "Allow contacts",
    laterTitle: "Type numbers instead"
)
"""

private let deniedCode = """
// A primer that finds the permission already off skips straight to recovery:
// three steps and an Open Settings button (Notifications opens its own page).
KitoPermissionPrimer(kind: .camera, style: .card, onDismiss: { … })

KitoPermissionRecoverySteps(kind: .notifications)
KitoPermissionSettings.open(for: .notifications)
"""

private let dashboardCode = """
ScrollView {
    KitoPermissionsDashboard(
        [.camera, .photoLibrary, .microphone, .locationWhenInUse, .notifications, .contacts],
        reasons: [.camera: "Scan M-Pesa QR codes", .contacts: "Send money by name"]
    )
    .padding()
}
"""

private let simulatedCode = """
// Every state without touching real permissions — for previews, demos and tests.
KitoPermissionsDashboard(kinds, requester: .simulated(
    [.camera: .granted, .microphone: .denied, .photoLibrary: .granted],
    outcome: .granted
))
"""

// MARK: - Samples

enum PermissionsSamples {
    static let sections: [KitSection] = [cards, fullScreen, banners, recovery, dashboards, blocks]

    static let cards = KitSection("Priming cards", symbol: "rectangle.on.rectangle", [
        KitSample("Scan to pay", "Camera, explained before the one-shot prompt.", code: cardCode) {
            ModalStage { PermPrimingStage(kind: .camera, style: .card, title: "Lipa", tint: .green, trigger: "Scan QR to pay") }
        },
        KitSample("Delivery location", "Why an address pin beats typing one.", code: cardCode.replacingOccurrences(of: ".camera", with: ".locationWhenInUse")) {
            ModalStage { PermPrimingStage(kind: .locationWhenInUse, style: .card, title: "Deliver to", tint: .blue, trigger: "Use my location") }
        },
        KitSample("Send money by name", "Contacts with your own copy and benefits.", code: customCopyCode) {
            ModalStage {
                PermPrimingStage(kind: .contacts, style: .card, title: "Send", tint: .purple, trigger: "Choose from contacts",
                                 content: KitoPermissionPrimingContent(title: "Send money by name", message: "Find Wycliff, Amina and the rest of your people without typing numbers.",
                                                                       benefits: ["Send to contacts in a tap", "Split bills with friends", "We never message anyone"],
                                                                       allowTitle: "Allow contacts", laterTitle: "Type numbers instead"))
            }
        },
        KitSample("Live: camera", "Asks the system for real — once per install.", code: cardCode) {
            ModalStage { PermPrimingStage(kind: .camera, style: .card, title: "Receipts", tint: .teal, trigger: "Scan a receipt", requester: .live) }
        },
    ])

    static let fullScreen = KitSection("Full-screen illustration", symbol: "rectangle.portrait.fill", [
        KitSample("Find what's near you", "Orbiting icons around a big location badge.", code: illustrationCode) {
            ModalStage { PermFullScreenStage(kind: .locationWhenInUse) }
        },
        KitSample("Know the moment it ships", "Notifications during onboarding.", code: illustrationCode.replacingOccurrences(of: ".locationWhenInUse", with: ".notifications")) {
            ModalStage { PermFullScreenStage(kind: .notifications) }
        },
        KitSample("Voice notes", "Microphone, for chats and calls.", code: illustrationCode.replacingOccurrences(of: ".locationWhenInUse", with: ".microphone")) {
            ModalStage { PermFullScreenStage(kind: .microphone) }
        },
        KitSample("Share your best shots", "Photos, with limited access in mind.", code: illustrationCode.replacingOccurrences(of: ".locationWhenInUse", with: ".photoLibrary")) {
            ModalStage { PermFullScreenStage(kind: .photoLibrary) }
        },
    ])

    static let banners = KitSection("Inline banners", symbol: "rectangle.topthird.inset.filled", [
        KitSample("Order updates", "A gentle ask at the top of your orders.", code: bannerCode) {
            ModalStage {
                PermBannerStage(kind: .notifications, title: "Orders", rows: [
                    ("Mama's Kitchen", "Delivered · KSh 1,540", "takeoutbag.and.cup.and.straw.fill"),
                    ("Naivas Westlands", "On the way · 12 items", "cart.fill"),
                    ("Jumia", "Packed · arrives Friday", "shippingbox.fill"),
                ])
            }
        },
        KitSample("Nearby pickup points", "Location, asked where it helps.", code: bannerCode.replacingOccurrences(of: ".notifications", with: ".locationWhenInUse")) {
            ModalStage {
                PermBannerStage(kind: .locationWhenInUse, title: "Pickup", rows: [
                    ("Sarit Centre", "Westlands · open till 9 pm", "mappin.circle.fill"),
                    ("Two Rivers Mall", "Limuru Rd · open till 10 pm", "mappin.circle.fill"),
                    ("The Hub Karen", "Karen · open till 8 pm", "mappin.circle.fill"),
                ], tint: .blue)
            }
        },
        KitSample("Pair your earbuds", "Bluetooth, from a devices list.", code: bannerCode.replacingOccurrences(of: ".notifications", with: ".bluetooth")) {
            ModalStage {
                PermBannerStage(kind: .bluetooth, title: "Devices", rows: [
                    ("Galaxy Buds", "Last seen at home", "earbuds"),
                    ("JBL Flip", "Last seen in the car", "hifispeaker.fill"),
                    ("Mi Band", "Connected yesterday", "applewatch"),
                ], tint: .indigo)
            }
        },
        KitSample("Every banner state", "Asking, allowed and off.", code: bannerCode) { PermBannerStatesPreview() },
    ])

    static let recovery = KitSection("Denied → Settings", symbol: "gearshape.fill", [
        KitSample("Camera is off", "Finds it denied and goes straight to recovery.", code: deniedCode) {
            ModalStage { PermPrimingStage(kind: .camera, style: .card, title: "Lipa", tint: .green, trigger: "Scan QR to pay", requester: .simulated([.camera: .denied])) }
        },
        KitSample("Said no just now", "Tap Allow: the answer is no, and the card turns into steps.", code: deniedCode) {
            ModalStage { PermPrimingStage(kind: .microphone, style: .card, title: "Chats", tint: .pink, trigger: "Record a voice note", requester: .simulated(outcome: .denied)) }
        },
        KitSample("Notifications are off", "Full screen, opening the notification settings page.", code: deniedCode) {
            ModalStage { PermFullScreenStage(kind: .notifications, requester: .simulated([.notifications: .denied])) }
        },
        KitSample("Recovery steps", "The three steps on their own.", code: "KitoPermissionRecoverySteps(kind: .locationWhenInUse)") {
            VStack(spacing: 12) {
                KitoPermissionRecoverySteps(kind: .locationWhenInUse)
                KitoPermissionRecoverySteps(kind: .notifications)
            }
        },
    ])

    static let dashboards = KitSection("Dashboard", symbol: "list.bullet.rectangle.portrait", [
        KitSample("Live dashboard", "This app's real statuses; Allow asks for real.", code: dashboardCode) {
            ModalStage {
                PermDashboardStage(kinds: [.camera, .photoLibrary, .microphone, .locationWhenInUse, .notifications, .contacts, .calendar],
                                   reasons: [.camera: "Scan M-Pesa QR codes", .contacts: "Send money by name", .calendar: "Add bookings to your calendar"],
                                   requester: .live)
            }
        },
        KitSample("A mixed picture", "Allowed, off and not asked — plus App Tracking shown for illustration only.", code: simulatedCode) {
            ModalStage {
                PermDashboardStage(kinds: [.camera, .photoLibrary, .microphone, .locationWhenInUse, .notifications, .tracking],
                                   reasons: [.tracking: "Illustration only — this app doesn't track"],
                                   title: "Wycliff's phone",
                                   requester: .simulated([.camera: .granted, .photoLibrary: .granted, .microphone: .denied, .tracking: .restricted], outcome: .granted))
            }
        },
        KitSample("All set", "Everything on: the ring closes.", code: simulatedCode) {
            KitoPermissionsDashboard([.camera, .notifications, .locationWhenInUse],
                                     requester: .simulated([.camera: .granted, .notifications: .granted, .locationWhenInUse: .granted]))
        },
    ])

    static let blocks = KitSection("Building blocks", symbol: "square.stack.3d.up", [
        KitSample("Status pills and icons", "The status badge and every kind's tile.", code: "KitoPermissionStatusBadge(status: .granted)\nkind.displayName · kind.systemImage · kind.tint") { PermBadgesPreview() },
        KitSample("Check and request", "One async API over every permission — live.", code: """
        let status = await KitoPermissionManager.shared.status(for: .camera)
        if status.canPrompt {
            let result = await KitoPermissionManager.shared.request(.camera)
        }
        """) { PermLiveStatusList() },
        KitSample("Rationale sheet (1.0)", "The original view, still supported.", code: """
        .sheet(isPresented: $showsRationale) {
            KitoPermissionRationaleView(icon: "camera.fill", title: "Scan receipts instantly",
                                        message: "…", onContinue: { … }, onSkip: { … })
        }
        """) { ModalStage { PermLegacyRationaleStage() } },
    ])
}
