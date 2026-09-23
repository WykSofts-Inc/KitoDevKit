//
//  WalletSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoWalletCards

// Fictional issuers only: the DevKit ships on the App Store, so no real card-network logos.

enum WalletData {
    static let videoCards = [
        KitoWalletCard(id: "strip", name: "Travel", mark: .wordmark("orbit"), last4: "0016", holder: "Amina Mwangi", expiry: "11/28", balance: 2_850, style: .sunset),
        KitoWalletCard(id: "aqua", name: "Savings", mark: .symbol("drop.fill"), last4: "4916", holder: "Amina Mwangi", expiry: "04/29", balance: 4_700, style: .aqua),
        KitoWalletCard(id: "ocean", name: "Everyday", mark: .wordmark("NOVA", italic: true), last4: "4120", holder: "Amina Mwangi", expiry: "09/29", balance: 7_650, style: .ocean),
    ]

    static let pastelCards = [
        KitoWalletCard(id: "s", name: "Shopping", mark: .wordmark("S"), last4: "2201", holder: "Justin Otieno", expiry: "02/28", balance: 27_485, style: .lavender),
        KitoWalletCard(id: "q", name: "Business", mark: .wordmark("q"), last4: "8830", holder: "Justin Otieno", expiry: "06/29", balance: 65_324, style: .lime),
        KitoWalletCard(id: "pp", name: "Main", mark: .circles(.indigo, .blue), last4: "9743", holder: "Justin Otieno", expiry: "02/30", balance: 413_176, style: .pearl),
    ]

    static let allStyles: [KitoWalletCard] = [
        ("Ocean", KitoWalletCardStyle.ocean, KitoWalletCardMark.wordmark("NOVA", italic: true)),
        ("Sunset", .sunset, .wordmark("orbit")),
        ("Aqua", .aqua, .symbol("drop.fill")),
        ("Midnight", .midnight, .circles(.red, .orange)),
        ("Lavender", .lavender, .wordmark("lumen")),
        ("Lime", .lime, .symbol("leaf.fill")),
        ("Pearl", .pearl, .circles(.indigo, .blue)),
        ("Gold", .gold, .wordmark("AURUM")),
    ].enumerated().map { index, item in
        KitoWalletCard(id: item.0, name: item.0, mark: item.2, last4: String(format: "%04d", 1_000 + index * 1_234), holder: "Amina Mwangi", expiry: "0\(index + 1)/29", balance: Double(1_200 + index * 2_750), style: item.1)
    }

    static let fiveCards = allStyles.prefix(5).map { $0 }
}

// MARK: - Pocket

private struct PocketSample: View {
    let cards: [KitoWalletCard]
    var style: KitoWalletPocketStyle = .midnight
    var background: [Color] = [Color(red: 0.08, green: 0.09, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.12)]
    var revealsOnAppear = false
    @State private var isRevealed = false

    var body: some View {
        KitoWalletPocket(cards: cards, isRevealed: $isRevealed, style: style)
            .padding(24)
            .background(LinearGradient(colors: background, startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .environment(\.colorScheme, .dark)
            .onAppear {
                guard revealsOnAppear else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { isRevealed = true }
            }
    }
}

// MARK: - Cards

private struct FlipSample: View {
    @State private var flipped = false
    let card = WalletData.videoCards[2]

    var body: some View {
        VStack(spacing: 16) {
            KitoWalletCardView(card: card, isFlipped: flipped, cvv: "284")
                .shadow(color: .black.opacity(0.25), radius: 16, y: 10)
                .onTapGesture { withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) { flipped.toggle() } }
            Label("Tap the card to flip it", systemImage: "hand.tap").font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct BalanceToggleSample: View {
    @State private var shows = true

    var body: some View {
        VStack(spacing: 14) {
            KitoWalletCardView(card: WalletData.allStyles[3], showsBalance: shows)
                .shadow(color: .black.opacity(0.25), radius: 16, y: 10)
            Toggle("Show balance", isOn: $shows.animation()).tint(.primary)
        }
    }
}

private struct AllStylesSample: View {
    var body: some View {
        VStack(spacing: 14) {
            ForEach(WalletData.allStyles) { card in
                KitoWalletCardView(card: card).shadow(color: .black.opacity(0.2), radius: 10, y: 6)
            }
        }
    }
}

private struct TiltSample: View {
    var body: some View {
        VStack(spacing: 16) {
            KitoWalletCardView(card: WalletData.allStyles[7], showsBalance: true)
                .shadow(color: .black.opacity(0.3), radius: 18, y: 12)
                .kitoCardTilt()
            Label("Drag across the card", systemImage: "hand.draw").font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Layouts

private struct StackSample: View {
    @State private var selection: KitoWalletCard.ID?

    var body: some View {
        KitoWalletCardStack(cards: WalletData.fiveCards, selection: $selection) { card in
            TransactionsList(card: card)
        }
        .frame(height: 560)
    }
}

private struct CarouselSample: View {
    @State private var selection: KitoWalletCard.ID? = WalletData.allStyles[0].id

    private var selected: KitoWalletCard? { WalletData.allStyles.first { $0.id == selection } }

    var body: some View {
        VStack(spacing: 18) {
            KitoWalletCardCarousel(cards: WalletData.allStyles, selection: $selection)
                .frame(height: 230)
                .padding(.horizontal, -24)
            if let selected {
                VStack(spacing: 4) {
                    Text(selected.name).font(.headline)
                    Text(selected.formattedBalance).font(.title.bold().monospacedDigit()).contentTransition(.numericText())
                }
                .animation(.spring, value: selection)
            }
        }
    }
}

private struct FanSample: View {
    @State private var selection: KitoWalletCard.ID?

    var body: some View {
        VStack {
            KitoWalletCardFan(cards: WalletData.fiveCards, selection: $selection)
                .frame(height: 360)
            Text(selection == nil ? "Tap a card to pull it out" : "Tap it again to put it back").font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct DeckSample: View {
    @State private var top = WalletData.allStyles[0].name

    var body: some View {
        VStack(spacing: 16) {
            KitoWalletCardDeck(cards: WalletData.allStyles) { top = $0.name }
            Text("On top: \(top)").font(.subheadline.weight(.semibold))
            Label("Swipe the top card away", systemImage: "hand.draw").font(.caption).foregroundStyle(.secondary)
        }
    }
}

/// Sample transactions under a selected card.
struct TransactionsList: View {
    let card: KitoWalletCard
    private let rows = [("Java House", "cup.and.saucer.fill", -640.0), ("Salary", "briefcase.fill", 84_000), ("Uber", "car.fill", -1_150), ("Naivas", "cart.fill", -3_420)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows, id: \.0) { name, symbol, amount in
                HStack(spacing: 12) {
                    Image(systemName: symbol).frame(width: 36, height: 36).background(Circle().fill(Color.primary.opacity(0.07)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name).font(.subheadline.weight(.semibold))
                        Text("\(card.name) · •••• \(card.last4)").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(amount.formatted(.currency(code: "KES").precision(.fractionLength(0)).sign(strategy: .always())))
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(amount > 0 ? .green : .primary)
                }
                .padding(.vertical, 10)
                Divider()
            }
        }
    }
}

// MARK: - Catalog

private let pocketCode = """
@State private var isRevealed = false

KitoWalletPocket(cards: cards, isRevealed: $isRevealed, style: .midnight)
"""

enum WalletSamples {
    static let sections: [KitSection] = [pocket, cards, layouts, screens]

    static let pocket = KitSection("The pocket", symbol: "wallet.pass", [
        KitSample("Show the balance", "Cards spring out of the pocket and fan; the total counts in.", code: pocketCode) {
            PocketSample(cards: WalletData.videoCards)
        },
        KitSample("Pastel cards", "Three bright cards and a slate pocket.", code: pocketCode.replacingOccurrences(of: ".midnight", with: ".slate")) {
            PocketSample(cards: WalletData.pastelCards, style: .slate, background: [Color(white: 0.95), Color(white: 0.88)])
        },
        KitSample("Leather", "A tan pocket on a warm background.", code: pocketCode.replacingOccurrences(of: ".midnight", with: ".tan")) {
            PocketSample(cards: WalletData.videoCards, style: .tan, background: [Color(red: 0.95, green: 0.9, blue: 0.82), Color(red: 0.85, green: 0.76, blue: 0.64)])
        },
        KitSample("Five cards", "The pocket grows to fit every card's strip.", code: pocketCode) {
            PocketSample(cards: WalletData.fiveCards)
        },
        KitSample("Reveals on its own", "Opens a moment after it appears.", code: pocketCode + "\n.onAppear { isRevealed = true }") {
            PocketSample(cards: WalletData.videoCards, revealsOnAppear: true)
        },
    ])

    static let cards = KitSection("Cards", symbol: "creditcard", [
        KitSample("Every style", "Eight built-in styles and five patterns.", code: "KitoWalletCardView(card: card)   // style: .ocean, .sunset, .aqua, .midnight, .lavender, .lime, .pearl, .gold") { AllStylesSample() },
        KitSample("Flip to the back", "Signature strip and CVV.", code: "KitoWalletCardView(card: card, isFlipped: flipped, cvv: \"284\")") { FlipSample() },
        KitSample("Balance on the card", "The name swaps for the balance.", code: "KitoWalletCardView(card: card, showsBalance: true)") { BalanceToggleSample() },
        KitSample("Tilt and sheen", "Follows your finger in 3D with a moving highlight.", code: "KitoWalletCardView(card: card).kitoCardTilt()") { TiltSample() },
    ])

    static let layouts = KitSection("Layouts", symbol: "rectangle.stack", [
        KitSample("Wallet stack", "Tap a card to bring it up with its transactions; drag it down to put it back.", code: "KitoWalletCardStack(cards: cards, selection: $selected) { card in\n    TransactionsList(card: card)\n}") { StackSample() },
        KitSample("Carousel", "Neighbours turn away as you scroll.", code: "KitoWalletCardCarousel(cards: cards, selection: $selected)") { CarouselSample() },
        KitSample("Fan", "A hand of cards; tap one to pull it out.", code: "KitoWalletCardFan(cards: cards, selection: $selected)") { FanSample() },
        KitSample("Deck", "Swipe the top card to the back.", code: "KitoWalletCardDeck(cards: cards) { top in … }") { DeckSample() },
    ])

    static let screens = KitSection("Real-world screens", symbol: "iphone.gen3", [
        KitSample("Wallet home", "Greeting, cards, quick actions and transactions.", code: "KitoWalletCardFan(…) + KitoButton actions + transactions") { WalletHomeScreen() },
        KitSample("Add a card", "The card preview fills in as you type.", code: """
        KitoWalletCardView(card: preview)            // updates live
        KitoCardNumberField(number: $number)
        HStack { KitoCardExpiryField(text: $expiry); KitoCVVField(text: $cvv) }
        KitoNameField("Card holder", text: $holder)
        KitoButton("Save card") { … }
        """) { AddCardScreen() },
        KitSample("Activity", "Spending chart, income and expense, categories.", code: "BarChartView(viewModel: BarChartViewModel(points: incomeAndExpense))") { ActivityScreen() },
    ])
}

/// Every wallet sample.
struct WalletGallery: View {
    static var count: Int { KitGallery.count(WalletSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Wallet & Cards",
            sections: WalletSamples.sections,
            footnote: "Requires `import KitoWalletCards`. Issuers here are fictional.",
            searchHint: "Try “pocket”, “flip”, “stack” or “add a card”."
        )
    }
}
