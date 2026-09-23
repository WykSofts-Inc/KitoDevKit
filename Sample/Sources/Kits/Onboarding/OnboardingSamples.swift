//
//  OnboardingSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoOnboarding

private func code(_ styleArgs: [String], page: String = "KitoOnboardingPage(systemImage: \"bolt.fill\", title: \"Fast\", message: \"…\")") -> String {
    let style = styleArgs.isEmpty ? "" : ", style: KitoOnboardingStyle(\n    " + styleArgs.joined(separator: ",\n    ") + "\n)"
    return """
    @State private var onboarding = KitoOnboardingViewModel(
        pages: [
            \(page.replacingOccurrences(of: "\n", with: "\n        ")),
            // …
        ],
        onFinish: { hasSeenOnboarding = true }
    )

    KitoOnboardingView(viewModel: onboarding\(style))
    """
}

private enum Palette {
    static let cream = Color(red: 0.99, green: 0.96, blue: 0.91)
    static let sun = Color(red: 0.99, green: 0.76, blue: 0.1)
    static let tangerine = Color(red: 0.98, green: 0.45, blue: 0.1)
    static let ink = Color(red: 0.07, green: 0.07, blue: 0.08)
    static let lime = Color(red: 0.73, green: 0.93, blue: 0.3)
    static let lavender = Color(red: 0.62, green: 0.58, blue: 0.97)
    static let night = Color(red: 0.06, green: 0.07, blue: 0.16)
}

enum OnboardingSamples {
    static let sections: [KitSection] = [layouts, backgrounds, buttons, indicators, transitions, motion, content, apps]

    // MARK: Shared page sets

    static let basics = [
        KitoOnboardingPage(systemImage: "bolt.fill", title: "Fast", message: "Everything loads instantly, even on a slow connection."),
        KitoOnboardingPage(systemImage: "lock.fill", title: "Secure", message: "Your data is encrypted and stays yours."),
        KitoOnboardingPage(systemImage: "checkmark.seal.fill", title: "Simple", message: "No clutter, just what you need."),
    ]

    static func illustrated(_ tints: [Color] = [.orange, .blue, .green]) -> [KitoOnboardingPage] {
        [
            KitoOnboardingPage(eyebrow: "Discover", title: "Find what you love", message: "Thousands of picks, sorted for you.", accent: tints[0]) {
                ConfettiIllustration(symbol: "sparkle.magnifyingglass", tint: tints[0], blob: tints[0].opacity(0.15))
            },
            KitoOnboardingPage(eyebrow: "Connect", title: "Everything in one place", message: "Messages, payments and orders, synced.", accent: tints[1]) {
                OrbitIllustration(center: "iphone", satellites: ["message.fill", "creditcard.fill", "shippingbox.fill", "bell.fill"], tint: tints[1])
            },
            KitoOnboardingPage(eyebrow: "Go", title: "Ready when you are", message: "Set up takes less than a minute.", accent: tints[2]) {
                ConfettiIllustration(symbol: "paperplane.fill", tint: tints[2], blob: tints[2].opacity(0.15))
            },
        ]
    }

    static let photos = [
        KitoOnboardingPage(artwork: .none, eyebrow: "Explore", title: "See the world differently", message: "Guides from people who live there.",
                           background: .image(.url(OnboardingPhotos.url("travel-1")), overlayTint: .black.opacity(0.15)), accent: .white, onAccent: .black),
        KitoOnboardingPage(artwork: .none, eyebrow: "Plan", title: "Trips that plan themselves", message: "Flights, stays and tables in one itinerary.",
                           background: .image(.url(OnboardingPhotos.url("travel-2")), overlayTint: .black.opacity(0.15)), accent: .white, onAccent: .black),
        KitoOnboardingPage(artwork: .none, eyebrow: "Go", title: "Pack light. Go far.", message: "Offline maps and tickets, wherever you land.",
                           background: .image(.url(OnboardingPhotos.url("travel-3")), overlayTint: .black.opacity(0.15)), accent: .white, onAccent: .black),
    ]

    // MARK: Layouts

    static let layouts = KitSection("Layouts", symbol: "rectangle.3.group", [
        KitSample("Classic centred", "Symbol, title and message in the middle.", code: code([])) {
            OnboardingSampleHost(pages: { basics })
        },
        KitSample("Hero top", "Large illustration up top, leading text below.", code: code(["layout: .heroTop", "indicator: .dots"], page: """
        KitoOnboardingPage(eyebrow: "Discover", title: "Find what you love", message: "…") {
            ConfettiIllustration(symbol: "sparkle.magnifyingglass", tint: .orange)
        }
        """)) {
            OnboardingSampleHost(style: KitoOnboardingStyle(layout: .heroTop, indicator: .dots)) { illustrated() }
        },
        KitSample("Full-bleed photos", "Photo backgrounds with text over a scrim.", code: code(["layout: .fullBleed", "buttonPlacement: .progressRing"], page: """
        KitoOnboardingPage(
            artwork: .none, title: "See the world differently", message: "…",
            background: .image(.url(photoURL), overlayTint: .black.opacity(0.15)),
            accent: .white, onAccent: .black
        )
        """)) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .progressRing, layout: .fullBleed)) { photos }
        },
        KitSample("Card sheet", "Artwork on colour, text on a rounded card.", code: code(["layout: .card", "cardColor: .white", "cardForeground: .black"], page: """
        KitoOnboardingPage(title: "Your order has been placed", message: "…", background: .color(.yellow)) {
            ConfettiIllustration(symbol: "gift.fill", tint: .black)
        }
        """)) {
            OnboardingSampleHost(style: KitoOnboardingStyle(layout: .card, indicator: .dots, cardColor: .white, cardForeground: Palette.ink)) {
                [
                    KitoOnboardingPage(title: "Your order has been placed", message: "Track the order details in the app.", background: .color(Palette.sun), foreground: Palette.ink, accent: Palette.ink, onAccent: .white) {
                        ConfettiIllustration(symbol: "gift.fill", tint: Palette.ink, blob: .white.opacity(0.45), ink: Palette.ink)
                    },
                    KitoOnboardingPage(title: "Delivered in a day", message: "Same-day delivery in most cities.", background: .color(Palette.tangerine), foreground: Palette.ink, accent: Palette.ink, onAccent: .white) {
                        ConfettiIllustration(symbol: "box.truck.fill", tint: Palette.ink, blob: .white.opacity(0.35), ink: Palette.ink)
                    },
                    KitoOnboardingPage(title: "Returns are free", message: "Changed your mind? Send it back, on us.", background: .color(Palette.lime), foreground: Palette.ink, accent: Palette.ink, onAccent: .white) {
                        ConfettiIllustration(symbol: "arrow.uturn.backward.circle.fill", tint: Palette.ink, blob: .white.opacity(0.4), ink: Palette.ink)
                    },
                ]
            }
        },
        KitSample("Text first", "A big title leads, the artwork fills below.", code: code(["layout: .textFirst", "buttonPlacement: .bottomTrailingCompact"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .bottomTrailingCompact, layout: .textFirst, indicator: .numbered)) {
                [
                    KitoOnboardingPage(title: "Money,\nsorted.", message: "See every account in one place.", accent: .green) { CardStackIllustration() },
                    KitoOnboardingPage(title: "Watch it\ngrow.", message: "Track your savings week by week.", accent: .green) { TrendCardIllustration() },
                    KitoOnboardingPage(title: "Built for\nyour phone.", message: "Fast, private, and offline-ready.", accent: .green) { PhoneMockIllustration(tint: .green) },
                ]
            }
        },
    ])

    // MARK: Backgrounds

    static let backgrounds = KitSection("Backgrounds", symbol: "photo.on.rectangle", [
        KitSample("Solid colour per page", "Each page brings its own colour; the buttons follow it.", code: code(["indicator: .dots"], page: "KitoOnboardingPage(artwork: .symbol(\"sun.max.fill\"), title: \"Morning\", message: \"…\",\n    background: .color(.yellow), foreground: .black, accent: .black, onAccent: .yellow)")) {
            OnboardingSampleHost(style: KitoOnboardingStyle(indicator: .dots)) {
                [
                    KitoOnboardingPage(artwork: .symbol("sun.max.fill"), title: "Morning", message: "Start the day with a plan.", background: .color(Palette.sun), foreground: Palette.ink, accent: Palette.ink, onAccent: Palette.sun),
                    KitoOnboardingPage(artwork: .symbol("flame.fill"), title: "Afternoon", message: "Stay in the zone.", background: .color(Palette.tangerine), foreground: .white, accent: .white, onAccent: Palette.tangerine),
                    KitoOnboardingPage(artwork: .symbol("moon.stars.fill"), title: "Night", message: "Wind down and reflect.", background: .color(Palette.night), foreground: .white, accent: Palette.lavender, onAccent: .white),
                ]
            }
        },
        KitSample("Linear gradients", "A diagonal gradient per page.", code: code([], page: "KitoOnboardingPage(systemImage: \"sparkles\", title: \"Discover\", message: \"…\",\n    background: .gradient(.linear(.purple, .indigo)))")) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .fade)) {
                [
                    KitoOnboardingPage(artwork: .symbol("sparkles"), title: "Discover", message: "Find something new every day.", background: .gradient(.linear(.purple, .indigo)), foreground: .white, accent: .white, onAccent: .purple),
                    KitoOnboardingPage(artwork: .symbol("heart.fill"), title: "Connect", message: "Stay close to what matters.", background: .gradient(.linear(.pink, .orange)), foreground: .white, accent: .white, onAccent: .pink),
                    KitoOnboardingPage(artwork: .symbol("star.fill"), title: "Grow", message: "Build something great.", background: .gradient(.linear(.teal, .blue)), foreground: .white, accent: .white, onAccent: .blue),
                ]
            }
        },
        KitSample("Radial glow", "A pool of light on a dark page.", code: code(["artworkMotion: .pulse"], page: "KitoOnboardingPage(artwork: .symbol(\"moon.stars.fill\"), title: \"Breathe\", message: \"…\",\n    background: .gradient(KitoGradient(colors: [.indigo, .black], shape: .radial(center: .center, startRadius: 10, endRadius: 420))))")) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .fade, artworkMotion: .pulse)) {
                [("moon.stars.fill", "Breathe", "Four minutes to a calmer day.", Color.indigo), ("leaf.fill", "Unwind", "Sleep stories and soundscapes.", Color.teal), ("sparkles", "Focus", "Music that keeps you in flow.", Color.purple)].map { symbol, title, message, color in
                    KitoOnboardingPage(artwork: .symbol(symbol), title: title, message: message,
                                       background: .gradient(KitoGradient(colors: [color, .black], shape: .radial(center: .center, startRadius: 10, endRadius: 420))),
                                       foreground: .white, accent: .white, onAccent: color)
                }
            }
        },
        KitSample("Angular gradient", "A sweep of colour around the centre.", code: code([], page: "background: .gradient(KitoGradient(colors: [.pink, .purple, .blue, .pink],\n    shape: .angular(center: .center, startAngle: .zero, endAngle: .degrees(360))))")) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .scaleFade)) {
                basics.map { base in
                    KitoOnboardingPage(artwork: base.artwork, title: base.title, message: base.message,
                                       background: .gradient(KitoGradient(colors: [.pink, .purple, .blue, .pink], shape: .angular(center: .center, startAngle: .zero, endAngle: .degrees(360)))),
                                       foreground: .white, accent: .white, onAccent: .purple)
                }
            }
        },
        KitSample("Photo backgrounds", "Remote photos, tinted for legibility.", code: code(["layout: .fullBleed"], page: "KitoOnboardingPage(artwork: .none, title: \"…\", message: \"…\",\n    background: .image(.url(photoURL), overlayTint: .black.opacity(0.15)))")) {
            OnboardingSampleHost(style: KitoOnboardingStyle(layout: .fullBleed, indicator: .progressBar)) { photos }
        },
        KitSample("Photos with parallax", "The photo moves slower than the page as you swipe.", code: code(["pageTransition: .parallax", "layout: .fullBleed"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .progressRing, pageTransition: .parallax, layout: .fullBleed)) { photos }
        },
        KitSample("All black", "White on black with line illustrations.", code: code(["buttonPlacement: .bottomTrailingCompact"], page: "KitoOnboardingPage(title: \"Simple as it is\", message: \"…\", background: .color(.black),\n    foreground: .white, accent: .white, onAccent: .black) { ConfettiIllustration(…) }")) {
            OnboardingSampleHost(colorScheme: .dark) { fashionPages }
        },
    ])

    // MARK: Buttons

    static let buttons = KitSection("Buttons", symbol: "button.horizontal", [
        KitSample("Full-width button", "The default: a capsule across the bottom.", code: code(["buttonPlacement: .bottomFullWidth"])) {
            OnboardingSampleHost { basics }
        },
        KitSample("Compact trailing", "A pill beside the indicator; full width on the last page.", code: code(["buttonPlacement: .bottomTrailingCompact"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .bottomTrailingCompact)) { basics }
        },
        KitSample("Top arrow", "An arrow up top; Skip moves to the bottom.", code: code(["buttonPlacement: .topTrailingCompact"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .topTrailingCompact)) { basics }
        },
        KitSample("Progress ring", "A ring fills as you go, then stretches into Get started.", code: code(["buttonPlacement: .progressRing"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .progressRing, layout: .heroTop)) { illustrated([.pink, .pink, .pink]) }
        },
        KitSample("Back button", "A chevron to step back after the first page.", code: code(["showsBackButton: true"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(showsBackButton: true)) { basics }
        },
        KitSample("No Skip", "For flows that must be completed.", code: code(["showsSkip: false"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(showsSkip: false)) { basics }
        },
    ])

    // MARK: Indicators

    static let indicators = KitSection("Indicators", symbol: "ellipsis", [
        KitSample("Capsules", "The current page stretches.", code: code(["indicator: .capsules"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(indicator: .capsules)) { basics }
        },
        KitSample("Dots", "Round dots; the current one grows.", code: code(["indicator: .dots"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(indicator: .dots)) { basics }
        },
        KitSample("Numbered", "“2 / 3” with a rolling digit.", code: code(["indicator: .numbered"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .bottomTrailingCompact, indicator: .numbered)) { basics }
        },
        KitSample("Stories bar", "Segmented bars along the top.", code: code(["indicator: .progressBar"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(layout: .fullBleed, indicator: .progressBar)) { photos }
        },
        KitSample("No indicator", "Just the button.", code: code(["indicator: .none"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(indicator: .none)) { basics }
        },
    ])

    // MARK: Transitions

    static let transitions = KitSection("Page transitions", symbol: "rectangle.portrait.on.rectangle.portrait.angled", [
        KitSample("Slide", "Pages slide; the default.", code: code(["pageTransition: .slide"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(layout: .heroTop)) { illustrated() }
        },
        KitSample("Fade", "Pages fade as they leave.", code: code(["pageTransition: .fade"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .fade, layout: .heroTop)) { illustrated() }
        },
        KitSample("Scale & fade", "A shallow carousel depth.", code: code(["pageTransition: .scaleFade"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .scaleFade, layout: .heroTop)) { illustrated() }
        },
        KitSample("Parallax", "Artwork moves at a different speed from the text.", code: code(["pageTransition: .parallax"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .parallax, layout: .heroTop)) { illustrated() }
        },
        KitSample("Cube", "Pages turn like the faces of a cube.", code: code(["pageTransition: .cube"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .cube)) {
                [("sparkles", Color.purple), ("heart.fill", Color.pink), ("star.fill", Color.orange)].enumerated().map { index, item in
                    KitoOnboardingPage(artwork: .symbol(item.0), title: ["Discover", "Connect", "Grow"][index], message: "Swipe slowly to watch the faces turn.",
                                       background: .gradient(.linear(item.1, item.1.opacity(0.6))), foreground: .white, accent: .white, onAccent: item.1)
                }
            }
        },
        KitSample("Zoom", "The leaving page zooms toward you.", code: code(["pageTransition: .zoom"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .zoom, layout: .heroTop)) { illustrated() }
        },
    ])

    // MARK: Motion

    static let motion = KitSection("Artwork motion", symbol: "wind", [
        KitSample("Float", "Artwork drifts gently.", code: code(["artworkMotion: .float"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(artworkMotion: .float)) { basics }
        },
        KitSample("Bounce", "Artwork bounces as its page arrives.", code: code(["artworkMotion: .bounce"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(artworkMotion: .bounce)) { basics }
        },
        KitSample("Pulse", "Artwork breathes in and out.", code: code(["artworkMotion: .pulse"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(artworkMotion: .pulse)) { basics }
        },
        KitSample("Live illustrations", "Orbiting icons, filling rings and drifting confetti.", code: code(["layout: .heroTop"], page: "KitoOnboardingPage(title: \"Close your rings\", message: \"…\") {\n    RingIllustration(progress: 0.72)\n}")) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .progressRing, layout: .heroTop)) {
                [
                    KitoOnboardingPage(title: "Close your rings", message: "Move, exercise and stand every day.", accent: .pink) { RingIllustration() },
                    KitoOnboardingPage(title: "Sync everything", message: "Your watch, phone and scale, together.", accent: .blue) {
                        OrbitIllustration(center: "applewatch", satellites: ["iphone", "scalemass.fill", "heart.fill"], tint: .blue)
                    },
                    KitoOnboardingPage(title: "Celebrate streaks", message: "Badges for every milestone.", accent: .orange) {
                        ConfettiIllustration(symbol: "trophy.fill", tint: .orange)
                    },
                ]
            }
        },
    ])

    // MARK: Content

    static let content = KitSection("Content & copy", symbol: "text.alignleft", [
        KitSample("What's new", "An eyebrow, a headline and checked feature lines.", code: code(["layout: .heroTop"], page: """
        KitoOnboardingPage(
            artwork: .symbol("wand.and.stars"),
            eyebrow: "New in 2.0",
            title: "Smarter than ever",
            message: "…",
            bullets: ["Auto-categorised spending", "Shared budgets", "Widgets"]
        )
        """)) {
            OnboardingSampleHost(style: KitoOnboardingStyle(layout: .heroTop, indicator: .dots, artworkMotion: .float)) {
                [
                    KitoOnboardingPage(artwork: .symbol("wand.and.stars"), eyebrow: "New in 2.0", title: "Smarter than ever", message: "A few of our favourite additions:",
                                       bullets: ["Auto-categorised spending", "Shared budgets with family", "Home screen widgets"], accent: .purple),
                    KitoOnboardingPage(artwork: .symbol("person.2.fill"), eyebrow: "New in 2.0", title: "Better together", message: "Invite anyone with a link.",
                                       bullets: ["Split bills instantly", "Settle up in one tap"], accent: .purple),
                ]
            }
        },
        KitSample("Your own words", "Custom button labels, in Swahili.", code: code([
            "labels: KitoOnboardingLabels(next: \"Endelea\", getStarted: \"Anza sasa\", skip: \"Ruka\", back: \"Rudi\")",
            "showsBackButton: true",
        ])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(labels: KitoOnboardingLabels(next: "Endelea", getStarted: "Anza sasa", skip: "Ruka", back: "Rudi"), showsBackButton: true)) {
                [
                    KitoOnboardingPage(systemImage: "hand.wave.fill", title: "Karibu", message: "Tuanze pamoja."),
                    KitoOnboardingPage(systemImage: "phone.fill", title: "Thibitisha nambari", message: "Tutakutumia msimbo."),
                    KitoOnboardingPage(systemImage: "checkmark.circle.fill", title: "Uko tayari", message: "Kila kitu kimewekwa."),
                ]
            }
        },
        KitSample("Two pages", "The shortest useful flow.", code: code([])) {
            OnboardingSampleHost {
                [
                    KitoOnboardingPage(systemImage: "hand.wave.fill", title: "Welcome", message: "Let's get you set up."),
                    KitoOnboardingPage(systemImage: "arrow.right.circle.fill", title: "Ready", message: "You're all set."),
                ]
            }
        },
        KitSample("Five-step setup", "Numbered steps with a stories bar.", code: code(["indicator: .progressBar", "showsBackButton: true"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(indicator: .progressBar, artworkMotion: .bounce, showsBackButton: true)) {
                ["Create your account", "Verify your phone", "Add a payment method", "Set your preferences", "You're ready"].enumerated().map { index, title in
                    KitoOnboardingPage(artwork: .symbol(index == 4 ? "checkmark.circle.fill" : "\(index + 1).circle.fill"), eyebrow: "Step \(index + 1) of 5", title: title, message: "About a minute each.")
                }
            }
        },
        KitSample("Permission priming", "Explain why before the system asks.", code: code(["layout: .heroTop"], page: "KitoOnboardingPage(artwork: .symbol(\"bell.badge.fill\"), eyebrow: \"Notifications\",\n    title: \"Know when it ships\", message: \"…\")")) {
            OnboardingSampleHost(style: KitoOnboardingStyle(layout: .heroTop, artworkMotion: .bounce, labels: KitoOnboardingLabels(next: "Continue", getStarted: "Allow and continue"))) {
                [
                    KitoOnboardingPage(artwork: .symbol("bell.badge.fill"), eyebrow: "Notifications", title: "Know when it ships", message: "We'll only notify you about your orders. No marketing.", accent: .red),
                    KitoOnboardingPage(artwork: .symbol("location.fill"), eyebrow: "Location", title: "Faster delivery estimates", message: "Used while the app is open, never shared.", accent: .blue),
                    KitoOnboardingPage(artwork: .symbol("camera.fill"), eyebrow: "Camera", title: "Scan cards and receipts", message: "Photos stay on your device.", accent: .green),
                ]
            }
        },
    ])

    // MARK: Real-world flows

    static let fashionPages = [
        KitoOnboardingPage(title: "Simple as it is", message: "No more long sign ups in multiple online stores and spam messages.",
                           background: .color(.black), foreground: .white, accent: .white, onAccent: .black) {
            ConfettiIllustration(symbol: "hanger", tint: Palette.tangerine, blob: .white.opacity(0.08), ink: .white)
        },
        KitoOnboardingPage(title: "Curated luxury", message: "Hand-picked pieces from the houses you love.",
                           background: .color(.black), foreground: .white, accent: .white, onAccent: .black) {
            ShoppingIllustration(tint: .white, accent: Palette.tangerine)
        },
        KitoOnboardingPage(title: "Delivered to your door", message: "Track every order, return for free.",
                           background: .color(.black), foreground: .white, accent: Palette.tangerine, onAccent: .white) {
            ConfettiIllustration(symbol: "shippingbox.fill", tint: Palette.sun, blob: .white.opacity(0.08), ink: .white)
        },
    ]

    static let apps = KitSection("Real-world flows", symbol: "iphone.gen3", [
        KitSample("Luxury fashion store", "Black pages, line confetti, a white Next pill.", code: code(["buttonPlacement: .bottomTrailingCompact", "artworkMotion: .float"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .bottomTrailingCompact, pageTransition: .parallax, artworkMotion: .float), colorScheme: .dark) { fashionPages }
        },
        KitSample("Food delivery", "Warm colours, card layout, a progress ring.", code: code(["buttonPlacement: .progressRing", "layout: .card", "cardColor: .white"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .progressRing, layout: .card, artworkMotion: .bounce, cardColor: .white, cardForeground: Palette.ink)) {
                [
                    KitoOnboardingPage(eyebrow: "Hungry?", title: "Your favourite food, fast", message: "From local kitchens in 20–25 minutes.", background: .color(Palette.cream), foreground: Palette.ink, accent: Palette.tangerine, onAccent: .white) {
                        ConfettiIllustration(symbol: "fork.knife", tint: Palette.tangerine, blob: Palette.tangerine.opacity(0.15), ink: Palette.ink)
                    },
                    KitoOnboardingPage(eyebrow: "Live tracking", title: "Watch it arrive", message: "Chat or call your rider any time.", background: .color(Palette.cream), foreground: Palette.ink, accent: Palette.tangerine, onAccent: .white) {
                        OrbitIllustration(center: "bicycle", satellites: ["mappin.and.ellipse", "phone.fill", "message.fill"], tint: Palette.tangerine)
                    },
                    KitoOnboardingPage(eyebrow: "Free delivery", title: "On your first three orders", message: "Promo applied at checkout.", background: .color(Palette.cream), foreground: Palette.ink, accent: Palette.tangerine, onAccent: .white) {
                        ConfettiIllustration(symbol: "gift.fill", tint: Palette.tangerine, blob: Palette.sun.opacity(0.25), ink: Palette.ink)
                    },
                ]
            }
        },
        KitSample("Wallet & cards", "Card stack, trend card, pastel accents.", code: code(["layout: .textFirst", "indicator: .dots"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .bottomTrailingCompact, pageTransition: .scaleFade, layout: .textFirst, indicator: .dots)) {
                [
                    KitoOnboardingPage(title: "All your cards,\none wallet.", message: "Add cards from any bank in seconds.", accent: Palette.lavender, onAccent: .black) { CardStackIllustration() },
                    KitoOnboardingPage(title: "Know where\nit goes.", message: "Every payment, sorted automatically.", accent: Palette.lime, onAccent: .black) { TrendCardIllustration(tint: .green) },
                    KitoOnboardingPage(title: "Pay with\na glance.", message: "Face ID on every payment.", accent: Palette.ink, onAccent: .white) {
                        ConfettiIllustration(symbol: "faceid", tint: Palette.ink, blob: Palette.lime.opacity(0.35))
                    },
                ]
            }
        },
        KitSample("Fitness", "Activity rings and a bounce on every page.", code: code(["buttonPlacement: .progressRing", "layout: .heroTop", "artworkMotion: .bounce"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .progressRing, layout: .heroTop, artworkMotion: .bounce), colorScheme: .dark) {
                [
                    KitoOnboardingPage(title: "Move more", message: "A daily goal that adapts to you.", background: .color(.black), foreground: .white, accent: .pink) { RingIllustration(progress: 0.72, colors: [.pink, .red]) },
                    KitoOnboardingPage(title: "Train smarter", message: "Plans built from your heart rate.", background: .color(.black), foreground: .white, accent: .green) { RingIllustration(progress: 0.45, colors: [.green, .mint], symbol: "heart.fill") },
                    KitoOnboardingPage(title: "Rest well", message: "Recovery scores every morning.", background: .color(.black), foreground: .white, accent: .cyan) { RingIllustration(progress: 0.9, colors: [.cyan, .blue], symbol: "bed.double.fill") },
                ]
            }
        },
        KitSample("Travel", "Full-bleed photos, parallax and a stories bar.", code: code(["pageTransition: .parallax", "layout: .fullBleed", "indicator: .progressBar"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .progressRing, pageTransition: .parallax, layout: .fullBleed, indicator: .progressBar)) { photos }
        },
        KitSample("Meditation", "Radial glows, fades and a breathing symbol.", code: code(["pageTransition: .fade", "artworkMotion: .pulse", "indicator: .none"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .fade, indicator: .none, artworkMotion: .pulse, labels: KitoOnboardingLabels(next: "Breathe in", getStarted: "Begin"))) {
                [("wind", "Slow down", Color.teal), ("moon.fill", "Sleep deeper", Color.indigo), ("sun.haze.fill", "Wake gently", Color.orange)].map { symbol, title, color in
                    KitoOnboardingPage(artwork: .symbol(symbol), title: title, message: "Guided sessions from two to twenty minutes.",
                                       background: .gradient(KitoGradient(colors: [color.opacity(0.9), .black], shape: .radial(center: .center, startRadius: 20, endRadius: 460))),
                                       foreground: .white, accent: .white, onAccent: color)
                }
            }
        },
        KitSample("Music", "Neon on black with the cube turn.", code: code(["pageTransition: .cube", "indicator: .numbered"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(buttonPlacement: .bottomTrailingCompact, pageTransition: .cube, indicator: .numbered), colorScheme: .dark) {
                [("music.note", "Every song", Color.pink), ("waveform", "Lossless audio", Color.cyan), ("headphones", "Spatial sound", Color.purple)].map { symbol, title, color in
                    KitoOnboardingPage(artwork: .symbol(symbol), title: title, message: "Over 100 million tracks, ad-free.",
                                       background: .gradient(.linear(Palette.night, .black)), foreground: .white, accent: color, onAccent: .black)
                }
            }
        },
        KitSample("Kids & playful", "Bright colours, bounces and dots.", code: code(["indicator: .dots", "artworkMotion: .bounce"])) {
            OnboardingSampleHost(style: KitoOnboardingStyle(pageTransition: .scaleFade, indicator: .dots, artworkMotion: .bounce)) {
                [("teddybear.fill", "Learn with Teddy", Palette.sun), ("paintpalette.fill", "Draw and create", Palette.tangerine), ("star.fill", "Earn stars", Palette.lavender)].map { symbol, title, color in
                    KitoOnboardingPage(title: title, message: "Games that grow with your child.", background: .color(color.opacity(0.25)), accent: color, onAccent: Palette.ink) {
                        ConfettiIllustration(symbol: symbol, tint: color, blob: .white.opacity(0.6), ink: Palette.ink)
                    }
                }
            }
        },
    ])
}

/// Every onboarding sample.
struct OnboardingGallery: View {
    static var count: Int { KitGallery.count(OnboardingSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Onboarding",
            sections: OnboardingSamples.sections,
            footnote: "Requires `import KitoOnboarding`. Swipe the preview, or open it full screen. Photo samples load images from picsum.photos.",
            searchHint: "Try a layout (“card”), a transition (“cube”) or an app (“fashion”)."
        )
    }
}
