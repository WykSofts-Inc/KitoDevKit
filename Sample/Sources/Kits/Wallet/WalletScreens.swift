//
//  WalletScreens.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoWalletCards
import KitoFields
import KitoButtons
import KitoCharts

private enum Lime {
    static let lime = Color(red: 0.75, green: 0.94, blue: 0.3)
    static let sun = Color(red: 0.98, green: 0.86, blue: 0.2)
    static let ink = Color(red: 0.08, green: 0.1, blue: 0.2)
    static let paper = Color(red: 0.95, green: 0.97, blue: 0.93)
}

/// A light, lime-accented screen card, like the reference designs.
private struct LimeScreen<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 18, content: content)
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 30, style: .continuous).fill(Lime.paper))
            .foregroundStyle(Lime.ink)
            .environment(\.colorScheme, .light)
    }
}

// MARK: - Home

struct WalletHomeScreen: View {
    @State private var selection: KitoWalletCard.ID?
    private let actions = [("Deposit", "arrow.down.circle"), ("Transfer", "arrow.left.arrow.right.circle"), ("Withdraw", "arrow.up.circle"), ("More", "square.grid.2x2")]

    var body: some View {
        LimeScreen {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hi, Justin").font(.subheadline)
                    Text("Welcome back!").font(.title2.bold())
                }
                Spacer()
                Circle().fill(LinearGradient(colors: [Lime.sun, Lime.lime], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 48, height: 48)
                    .overlay(Text("JO").font(.headline))
            }

            KitoWalletCardStack(cards: WalletData.pastelCards, selection: $selection, peek: 54)
                .frame(height: 320)

            HStack(spacing: 10) {
                ForEach(actions, id: \.0) { title, symbol in
                    VStack(spacing: 6) {
                        Image(systemName: symbol).font(.title3)
                        Text(title).font(.caption.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.white))
                }
            }

            HStack {
                Text("All transactions").font(.title3.bold())
                Spacer()
                Menu("Today") { Button("Today") {}; Button("This week") {}; Button("This month") {} }.font(.subheadline)
            }
            TransactionsList(card: WalletData.pastelCards[2])
        }
    }
}

// MARK: - Add a card

struct AddCardScreen: View {
    @State private var number = ""
    @State private var expiry = ""
    @State private var cvv = ""
    @State private var holder = ""
    @State private var country = "KE"
    @State private var brand: KitoCardBrand = .unknown
    @State private var saved = false
    @State private var flipped = false

    private var preview: KitoWalletCard {
        let digits = number.filter(\.isNumber)
        let last4 = digits.count >= 4 ? String(digits.suffix(4)) : String(repeating: "•", count: 4 - digits.count) + digits
        return KitoWalletCard(id: "preview", name: brand == .unknown ? "New card" : brand.displayName,
                              mark: brand == .unknown ? .symbol("creditcard.fill") : .wordmark(brand.badge, italic: true),
                              last4: last4, holder: holder.isEmpty ? "Your name" : holder, expiry: expiry.isEmpty ? "MM/YY" : expiry,
                              balance: 0, style: KitoWalletCardStyle(colors: [Lime.lime, Color(red: 0.62, green: 0.86, blue: 0.2)], foreground: Lime.ink, pattern: .dots))
    }

    var body: some View {
        LimeScreen {
            Text("New Card").font(.title2.bold()).frame(maxWidth: .infinity)
            KitoWalletCardView(card: preview, isFlipped: flipped, cvv: cvv.isEmpty ? "•••" : cvv)
                .shadow(color: .black.opacity(0.15), radius: 14, y: 8)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: preview)

            Text("Card detail").font(.headline)
            KitoCardNumberField(number: $number).onBrandChange { brand = $0 }
            HStack(alignment: .top, spacing: 12) {
                KitoCardExpiryField(text: $expiry)
                KitoCVVField(text: $cvv)
                    .onFocusChange { focused in withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) { flipped = focused } }
            }
            KitoNameField("Card holder", text: $holder)
            KitoCountryField("Country", isoCode: $country)

            KitoButton(saved ? "Card saved" : "Save", systemImage: saved ? "checkmark" : nil) {
                try await Task.sleep(nanoseconds: 900_000_000)
                saved = true
            }
            .fullWidth()
            .disabled(number.filter(\.isNumber).count < 12 || expiry.count < 5 || cvv.count < 3 || holder.isEmpty)
            Text("The card flips while you type the CVV.").font(.caption).foregroundStyle(Lime.ink.opacity(0.6))
        }
    }
}

// MARK: - Activity

struct ActivityScreen: View {
    private let months = ["Feb", "Mar", "Apr", "May", "Jun", "Jul"]
    private var points: [ChartDataPoint] {
        ChartsData.series(months, [1_100, 1_600, 2_400, 1_300, 2_000, 1_700], category: "Income")
            + ChartsData.series(months, [800, 1_000, 1_500, 1_700, 1_900, 1_800], category: "Expense")
    }
    private let categories = [("Investments", "building.columns", "$3,607.00"), ("Travelling", "car", "$4,207.01"), ("Subscriptions", "crown", "$412.90")]

    var body: some View {
        LimeScreen {
            Text("Activity").font(.title2.bold()).frame(maxWidth: .infinity)
            VStack(spacing: 2) {
                Text("Total Spending").font(.subheadline).foregroundStyle(Lime.ink.opacity(0.6))
                Text("$1,376.90").font(.system(size: 34, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .trailing, spacing: 8) {
                Menu {
                    Button("Week") {}; Button("Month") {}; Button("Year") {}
                } label: {
                    Label("Month", systemImage: "chevron.down").font(.caption.weight(.semibold)).padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Capsule().fill(Lime.sun)).foregroundStyle(Lime.ink)
                }
                BarHost(points, cornerRadius: 4, height: 190, format: { "$\(Int($0 / 1000))k" })
                    .kitoChartTheme(KitoChartTheme(categoricalPalette: [Lime.sun, Lime.lime], gridlineColor: .white.opacity(0.08), axisLabelColor: .white.opacity(0.6)))
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Lime.ink))

            HStack(spacing: 12) {
                tile("Income", "$3,607.00", color: Lime.sun, symbol: "arrow.up")
                tile("Expense", "$1,807.00", color: Lime.lime, symbol: "arrow.up.right")
            }

            HStack {
                Text("Categories").font(.title3.bold())
                Spacer()
                Menu("Expense") { Button("Expense") {}; Button("Income") {} }.font(.subheadline)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.0) { name, symbol, amount in
                        VStack(alignment: .leading, spacing: 18) {
                            Image(systemName: symbol).font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(name).font(.caption).foregroundStyle(Lime.ink.opacity(0.6))
                                Text(amount).font(.subheadline.bold())
                            }
                        }
                        .padding(14)
                        .frame(width: 130, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white))
                    }
                }
            }
        }
    }

    private func tile(_ title: String, _ amount: String, color: Color, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).font(.subheadline.bold()).frame(width: 34, height: 34).background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.6)))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption)
                Text(amount).font(.subheadline.bold().monospacedDigit())
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(color))
    }
}
