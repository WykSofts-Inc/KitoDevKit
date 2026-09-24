//
//  FormattingSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoFormatting

// MARK: - Shared pieces

private enum FmtPalette {
    static let mint = [Color(red: 0.16, green: 0.78, blue: 0.58), Color(red: 0.05, green: 0.5, blue: 0.45)]
    static let dusk = [Color(red: 0.38, green: 0.3, blue: 0.95), Color(red: 0.12, green: 0.1, blue: 0.35)]
    static let sunset = [Color(red: 1.0, green: 0.55, blue: 0.3), Color(red: 0.88, green: 0.22, blue: 0.4)]
    static let ocean = [Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.1, green: 0.28, blue: 0.7)]
}

/// A soft card that reads well in light and dark.
private struct FmtCard<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct FmtRow: View {
    let label: String
    let value: String
    var mono = true

    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(mono ? .subheadline.weight(.semibold).monospacedDigit() : .subheadline.weight(.semibold))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
    }
}

private struct FmtIcon: View {
    let symbol: String
    let colors: [Color]
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
    }
}

private func kes(_ value: Double, cents: KitoCents = .auto) -> String {
    Decimal(value).kitoAmount(in: .kes, cents: cents)
}

// MARK: - Money

private struct FmtReceiptSample: View {
    private let lines: [(String, Decimal)] = [
        ("Nyama choma, 1 kg", 1_450), ("Ugali x2", 160), ("Kachumbari", 120), ("Passion juice x3", 750.5),
    ]
    @State private var cents: KitoCents = .auto

    private var total: Decimal { lines.reduce(0) { $0 + $1.1 } }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Image(systemName: "fork.knife.circle.fill").font(.system(size: 34)).foregroundStyle(.orange)
                    Text("Kuku & Choma, Westlands").font(.headline)
                    Text("Table 7 · Served by Achieng").font(.caption).foregroundStyle(.secondary)
                }
                .padding(.bottom, 14)
                ForEach(lines, id: \.0) { line in
                    FmtRow(label: line.0, value: line.1.kitoAmount(in: .kes, cents: cents))
                }
                Divider().padding(.vertical, 6)
                HStack {
                    Text("Total").font(.headline)
                    Spacer()
                    Text(total.kitoAmount(in: .kes, cents: cents)).font(.title3.weight(.heavy).monospacedDigit())
                        .contentTransition(.numericText())
                }
            }
            .padding(18)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .animation(.snappy, value: cents)

            Picker("Cents", selection: $cents) {
                Text("Auto").tag(KitoCents.auto)
                Text("Always").tag(KitoCents.always)
                Text("Never").tag(KitoCents.never)
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct FmtCompactTilesSample: View {
    private let tiles: [(String, Decimal, String, [Color])] = [
        ("Revenue", 1_248_300, "chart.bar.fill", FmtPalette.mint),
        ("M-Pesa float", 48_520, "iphone.gen3", FmtPalette.ocean),
        ("Payouts", 312_900, "arrow.up.right", FmtPalette.sunset),
        ("Tips", 7_450, "heart.fill", FmtPalette.dusk),
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(tiles, id: \.0) { tile in
                VStack(alignment: .leading, spacing: 14) {
                    Image(systemName: tile.2).font(.system(size: 15, weight: .bold))
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.22), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tile.1.kitoCompactAmount(in: .kes)).font(.title2.weight(.heavy).monospacedDigit())
                        Text(tile.0).font(.caption.weight(.semibold)).opacity(0.8)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(LinearGradient(colors: tile.3, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        }
    }
}

private struct FmtCurrenciesSample: View {
    @State private var display: KitoCurrencyDisplay = .code
    private let amount = Decimal(string: "24650.75")!

    var body: some View {
        VStack(spacing: 14) {
            Picker("Display", selection: $display) {
                Text("Code").tag(KitoCurrencyDisplay.code)
                Text("Symbol").tag(KitoCurrencyDisplay.symbol)
            }
            .pickerStyle(.segmented)
            FmtCard(padding: 6) {
                VStack(spacing: 0) {
                    ForEach(KitoCurrency.allCases, id: \.self) { currency in
                        HStack(spacing: 12) {
                            Text(currency.flag).font(.title2)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(currency.rawValue).font(.subheadline.weight(.bold))
                                Text("\(currency.minorUnits) decimals").font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(amount.kitoAmount(in: currency, display: display))
                                .font(.subheadline.weight(.semibold).monospacedDigit())
                                .contentTransition(.interpolate)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 9)
                        if currency != KitoCurrency.allCases.last { Divider().padding(.leading, 54) }
                    }
                }
            }
            .animation(.snappy, value: display)
        }
    }
}

private struct FmtTransactionsSample: View {
    private let rows: [(String, String, Decimal, String)] = [
        ("Received from Achieng O.", "Today, 09:14", 2_500, "arrow.down.left"),
        ("Mwangaza Supermarket", "Today, 08:02", -1_836.5, "cart.fill"),
        ("Electricity tokens", "Yesterday", -1_000, "bolt.fill"),
        ("Salary", "Sep 20", 185_000, "briefcase.fill"),
        ("Matatu fare", "Sep 20", -100, "bus.fill"),
    ]

    var body: some View {
        FmtCard(padding: 6) {
            VStack(spacing: 0) {
                ForEach(rows, id: \.0) { row in
                    HStack(spacing: 12) {
                        Image(systemName: row.3)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(row.2 > 0 ? .green : .primary)
                            .frame(width: 40, height: 40)
                            .background((row.2 > 0 ? Color.green : Color.primary).opacity(0.1), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.0).font(.subheadline.weight(.semibold)).lineLimit(1)
                            Text(row.1).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(KitoMoneyFormatting.signed(row.2, currency: .kes))
                            .font(.subheadline.weight(.bold).monospacedDigit())
                            .foregroundStyle(row.2 > 0 ? .green : .primary)
                    }
                    .padding(10)
                }
            }
        }
    }
}

private struct FmtLocalesSample: View {
    private let locales: [(String, String)] = [("en_KE", "English (Kenya)"), ("sw_KE", "Kiswahili (Kenya)"), ("en_US", "English (US)"), ("fr_FR", "Français"), ("de_DE", "Deutsch")]
    private let amount = Decimal(string: "1250500.5")!

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("The same KES amount, formatted for each region with `kitoFormatted(currency:locale:)`.")
                .font(.footnote).foregroundStyle(.secondary)
            FmtCard {
                VStack(spacing: 0) {
                    ForEach(locales, id: \.0) { locale in
                        FmtRow(label: locale.1, value: amount.kitoFormatted(currency: .kes, locale: Locale(identifier: locale.0)))
                    }
                }
            }
        }
    }
}

private struct FmtSplitBillSample: View {
    @State private var total = 6_480.0
    @State private var people = 4
    @State private var tip = 0.1

    private var each: Double { (total * (1 + tip)) / Double(people) }

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text("Each pays").font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.8))
                KitoAnimatedNumberText(each) { KitoMoneyFormatting.string(Decimal($0), currency: .kes, cents: .never) }
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("\(kes(total, cents: .never)) + \(KitoNumberFormatting.percent(tip)) tip, split \(people) ways")
                    .font(.caption.weight(.medium)).foregroundStyle(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 26)
            .background(LinearGradient(colors: FmtPalette.dusk, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 26, style: .continuous))

            FmtCard {
                VStack(spacing: 14) {
                    HStack {
                        Text("Bill").font(.subheadline.weight(.semibold))
                        Slider(value: $total, in: 500...20_000, step: 50).tint(.primary)
                    }
                    Stepper("People: \(people)", value: $people, in: 1...12).font(.subheadline.weight(.semibold))
                    Picker("Tip", selection: $tip) {
                        Text("No tip").tag(0.0)
                        Text("5%").tag(0.05)
                        Text("10%").tag(0.1)
                        Text("15%").tag(0.15)
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}

// MARK: - Animated numbers

private struct FmtRollingBalanceSample: View {
    @State private var balance = 48_250.0
    @State private var events: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("M-Wallet").font(.subheadline.weight(.bold))
                    Spacer()
                    Image(systemName: "wave.3.right").font(.subheadline.weight(.bold))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available balance").font(.caption.weight(.semibold)).opacity(0.75)
                    KitoAnimatedNumberText(balance) { KitoMoneyFormatting.string(Decimal($0), currency: .kes, cents: .always) }
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                }
                Text("Wycliff N · 0712 ••• 678").font(.caption.weight(.medium)).opacity(0.8)
            }
            .foregroundStyle(.white)
            .padding(22)
            .background(LinearGradient(colors: FmtPalette.mint, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: FmtPalette.mint[1].opacity(0.35), radius: 18, y: 10)

            HStack(spacing: 10) {
                Button { balance += 500; log("+ KES 500 from Achieng") } label: {
                    Label("Receive 500", systemImage: "arrow.down.left").frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
                Button { balance -= 1_200.5; log("− KES 1,200.50 to Mwangaza") } label: {
                    Label("Pay 1,200.50", systemImage: "arrow.up.right").frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
            }
            ForEach(events, id: \.self) { event in
                Text(event).font(.caption.monospacedDigit()).foregroundStyle(.secondary).transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: events)
    }

    private func log(_ text: String) {
        events.insert("\(Date().formatted(date: .omitted, time: .standard))  \(text)", at: 0)
        events = Array(events.prefix(3))
    }
}

private struct FmtCountingSample: View {
    @State private var replay = 0

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                stat("figure.walk", "Steps", 12_480, FmtPalette.ocean) { KitoNumberFormatting.grouped($0) }
                stat("banknote.fill", "Saved", 84_200, FmtPalette.mint) { KitoMoneyFormatting.compact(Decimal($0), currency: .kes) }
            }
            HStack(spacing: 12) {
                stat("clock.badge.checkmark.fill", "On time", 0.964, FmtPalette.sunset) { KitoNumberFormatting.percent($0, fractionDigits: 1) }
                stat("star.fill", "Reviews", 2_318, FmtPalette.dusk) { KitoNumberFormatting.compact($0) }
            }
            Button { replay += 1 } label: { Label("Count again", systemImage: "arrow.counterclockwise") }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .id(replay)
    }

    private func stat(_ symbol: String, _ title: String, _ value: Double, _ colors: [Color], format: @escaping (Double) -> String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            FmtIcon(symbol: symbol, colors: colors, size: 34)
            KitoCountingText(value, duration: 1.4, format: format)
                .font(.title2.weight(.heavy))
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct FmtLiveCounterSample: View {
    @State private var fares = 1_284_350.0
    @State private var trips = 8_431.0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Circle().fill(.red).frame(width: 8, height: 8)
                Text("LIVE · Nairobi routes today").font(.caption.weight(.heavy)).kerning(0.5)
            }
            .foregroundStyle(.red)
            VStack(alignment: .leading, spacing: 2) {
                KitoAnimatedNumberText(fares) { KitoMoneyFormatting.string(Decimal($0), currency: .kes, cents: .never) }
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                Text("fares collected").font(.subheadline).foregroundStyle(.secondary)
            }
            HStack {
                KitoAnimatedNumberText(trips).font(.title3.weight(.bold))
                Text("trips").foregroundStyle(.secondary)
                Spacer()
                KitoChangeBadge(0.082)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_300_000_000)
                fares += Double(Int.random(in: 3...12)) * 50
                trips += Double(Int.random(in: 0...3))
            }
        }
    }
}

private struct FmtScoreboardSample: View {
    @State private var home = 1
    @State private var away = 1

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 0) {
                team("Harambee", "KEN", FmtPalette.sunset, score: $home)
                Text(":").font(.system(size: 44, weight: .heavy, design: .rounded)).foregroundStyle(.white.opacity(0.6))
                team("Cranes", "UGA", FmtPalette.ocean, score: $away)
            }
            .padding(.vertical, 22)
            .background(LinearGradient(colors: [Color(white: 0.14), Color(white: 0.05)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            Text("Tap a team to score").font(.caption).foregroundStyle(.secondary)
        }
    }

    private func team(_ name: String, _ code: String, _ colors: [Color], score: Binding<Int>) -> some View {
        Button { score.wrappedValue += 1 } label: {
            VStack(spacing: 8) {
                Text(code).font(.caption.weight(.heavy))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom), in: Circle())
                KitoAnimatedNumberText(Double(score.wrappedValue))
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text(name).font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name), \(score.wrappedValue) goals. Add a goal")
    }
}

// MARK: - Changes & percentages

private struct FmtChangeBadgesSample: View {
    private let values: [Double] = [0.124, -0.031, 0.0, 0.587]

    var body: some View {
        FmtCard {
            VStack(spacing: 14) {
                HStack {
                    Text("Change").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                    Spacer()
                    ForEach(KitoChangeBadgeStyle.allCases, id: \.self) { style in
                        Text(String(describing: style).capitalized).font(.caption.weight(.bold)).foregroundStyle(.secondary).frame(width: 78)
                    }
                }
                ForEach(values, id: \.self) { value in
                    HStack {
                        Text(KitoNumberFormatting.signedPercent(value)).font(.subheadline.monospacedDigit())
                        Spacer()
                        ForEach(KitoChangeBadgeStyle.allCases, id: \.self) { style in
                            KitoChangeBadge(value, style: style).frame(width: 78)
                        }
                    }
                }
            }
        }
    }
}

private struct FmtSpark: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let minV = values.min(), let maxV = values.max(), values.count > 1 else { return path }
        let span = max(maxV - minV, 0.0001)
        for (index, value) in values.enumerated() {
            let point = CGPoint(x: rect.width * CGFloat(index) / CGFloat(values.count - 1), y: rect.height * (1 - CGFloat((value - minV) / span)))
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        return path
    }
}

private struct FmtPortfolioSample: View {
    private let holdings: [(String, String, Double, Double, [Double])] = [
        ("SVTC", "Savanna Tea Co.", 42.35, 0.064, [30, 32, 31, 35, 36, 38, 41, 42]),
        ("RVRL", "Rift Valley Rail", 18.9, -0.021, [21, 20.5, 20, 19.8, 20.1, 19.4, 19.2, 18.9]),
        ("LBEN", "Lake Basin Energy", 7.05, 0.0, [7, 7.1, 7.0, 6.95, 7.05, 7.0, 7.02, 7.05]),
        ("MSKM", "Mombasa Spice Mkt", 121.5, 0.138, [96, 99, 104, 101, 108, 113, 118, 121.5]),
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Portfolio").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Text(kes(1_842_600)).font(.title.weight(.heavy).monospacedDigit())
                }
                Spacer()
                KitoChangeBadge(0.047, style: .solid)
            }
            FmtCard(padding: 6) {
                VStack(spacing: 0) {
                    ForEach(holdings, id: \.0) { item in
                        HStack(spacing: 12) {
                            Text(item.0).font(.caption.weight(.heavy)).frame(width: 46, height: 46)
                                .background(Color.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.1).font(.subheadline.weight(.semibold)).lineLimit(1)
                                Text(kes(item.2)).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                            }
                            Spacer()
                            FmtSpark(values: item.4)
                                .stroke(KitoTrend(item.3) == .down ? Color.red : (KitoTrend(item.3) == .up ? Color.green : Color.secondary), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                .frame(width: 54, height: 24)
                            KitoChangeBadge(item.3).frame(width: 76, alignment: .trailing)
                        }
                        .padding(10)
                    }
                }
            }
        }
    }
}

private struct FmtSpendingSample: View {
    var body: some View {
        VStack(spacing: 12) {
            spendRow("Groceries", "cart.fill", 18_450, -0.082, FmtPalette.mint)
            spendRow("Transport", "bus.fill", 6_200, 0.15, FmtPalette.sunset)
            spendRow("Airtime & data", "antenna.radiowaves.left.and.right", 2_000, -0.25, FmtPalette.ocean)
            Text("Spending badges use `invertsColors: true`, so going down reads as good news.")
                .font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func spendRow(_ title: String, _ symbol: String, _ amount: Double, _ change: Double, _ colors: [Color]) -> some View {
        HStack(spacing: 12) {
            FmtIcon(symbol: symbol, colors: colors)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text("vs last month").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(kes(amount)).font(.subheadline.weight(.bold).monospacedDigit())
                KitoChangeBadge(change, style: .plain, invertsColors: true)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct FmtGoalSample: View {
    @State private var saved = 34_000.0
    private let goal = 50_000.0

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().stroke(Color.primary.opacity(0.08), lineWidth: 16)
                Circle()
                    .trim(from: 0, to: saved / goal)
                    .stroke(AngularGradient(colors: FmtPalette.mint + [FmtPalette.mint[0]], center: .center), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    KitoAnimatedNumberText(saved / goal) { KitoNumberFormatting.percent($0) }
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                    Text("of school fees").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                }
            }
            .frame(width: 180, height: 180)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: saved)
            Text("\(kes(saved)) saved of \(kes(goal))").font(.subheadline.weight(.semibold).monospacedDigit())
            Button { saved = min(goal, saved + 4_000) } label: { Label("Add KES 4,000", systemImage: "plus") }
                .buttonStyle(GalleryPrimaryButtonStyle())
                .disabled(saved >= goal)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Dates & durations

private struct FmtChatListSample: View {
    private let now = Date()
    private var chats: [(String, String, TimeInterval, Int)] {
        [("Achieng O.", "Uko wapi? We're at the café.", 20, 2), ("Kamau & Sons Hardware", "Your order is ready for pickup", 5 * 60, 0),
         ("Mum", "Umekula? Call me later", 3 * 3_600, 1), ("Chama ya Wikendi", "Otieno: contributions due Friday", 2 * 86_400, 12),
         ("Brian K.", "Sawa, tuonane Jumatatu", 40 * 86_400, 0)]
    }

    var body: some View {
        FmtCard(padding: 6) {
            VStack(spacing: 0) {
                ForEach(chats, id: \.0) { chat in
                    HStack(spacing: 12) {
                        Text(String(chat.0.prefix(1)))
                            .font(.headline).foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(LinearGradient(colors: [FmtPalette.ocean, FmtPalette.sunset, FmtPalette.mint, FmtPalette.dusk][chat.0.count % 4], startPoint: .top, endPoint: .bottom), in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(chat.0).font(.subheadline.weight(.semibold)).lineLimit(1)
                            Text(chat.1).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 5) {
                            Text(KitoDateFormatting.abbreviated(now.addingTimeInterval(-chat.2), now: now))
                                .font(.caption.weight(.semibold)).foregroundStyle(chat.3 > 0 ? .green : .secondary)
                            if chat.3 > 0 {
                                Text("\(chat.3)").font(.caption2.weight(.bold)).foregroundStyle(.white)
                                    .padding(.horizontal, 6).frame(minWidth: 20, minHeight: 20).background(.green, in: Capsule())
                            }
                        }
                    }
                    .padding(10)
                }
            }
        }
    }
}

private struct FmtGroupedDaysSample: View {
    private let now = Date()
    private var groups: [(Date, [(String, Double)])] {
        let day: TimeInterval = 86_400
        return [
            (now, [("Kahawa Café", -380), ("Received from Brian K.", 1_500)]),
            (now.addingTimeInterval(-day), [("Boda ride", -210), ("Duka la Jirani", -2_940)]),
            (now.addingTimeInterval(-3 * day), [("Chama contribution", -5_000)]),
            (now.addingTimeInterval(-12 * day), [("Rent, Kilimani", -45_000)]),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(groups, id: \.0) { group in
                VStack(alignment: .leading, spacing: 6) {
                    Text(KitoDateFormatting.dayLabel(group.0, now: now)).font(.footnote.weight(.heavy)).foregroundStyle(.secondary).textCase(.uppercase)
                    FmtCard(padding: 12) {
                        VStack(spacing: 8) {
                            ForEach(group.1, id: \.0) { row in
                                HStack {
                                    Text(row.0).font(.subheadline)
                                    Spacer()
                                    Text(KitoMoneyFormatting.signed(Decimal(row.1), currency: .kes))
                                        .font(.subheadline.weight(.semibold).monospacedDigit())
                                        .foregroundStyle(row.1 > 0 ? .green : .primary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct FmtDeliveryWindowsSample: View {
    @State private var selected = 1
    private var slots: [(Date, Date)] {
        let start = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        return (0..<6).map { index in
            let from = start.addingTimeInterval(Double(index) * 5_400)
            return (from, from.addingTimeInterval(5_400))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Delivery window").font(.headline)
                Spacer()
                Text(KitoDateFormatting.dayLabel(Date())).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
                    let on = index == selected
                    Button { withAnimation(.snappy) { selected = index } } label: {
                        VStack(spacing: 3) {
                            Text(KitoDateFormatting.timeRange(slot.0, slot.1)).font(.subheadline.weight(.bold))
                            Text(index == 0 ? "Fastest" : (index == 4 ? "KES 0 fee" : "KES 99 fee")).font(.caption2.weight(.medium)).opacity(0.7)
                        }
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .foregroundStyle(on ? Color(.systemBackground) : Color.primary)
                        .background(on ? Color.primary : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        }
    }
}

private struct FmtDurationsSample: View {
    private let items: [(String, String, TimeInterval)] = [
        ("Voice note", "waveform", 42), ("Podcast · Tech Kenya", "headphones", 2_890),
        ("Matatu to Rongai", "bus.fill", 3_900), ("SGR Nairobi–Mombasa", "tram.fill", 17_400), ("Leave balance", "sun.max.fill", 183_600),
    ]

    var body: some View {
        FmtCard(padding: 6) {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("short").frame(width: 62)
                    Text("clock").frame(width: 62)
                }
                .font(.caption2.weight(.heavy)).foregroundStyle(.secondary).textCase(.uppercase)
                .padding(.horizontal, 10).padding(.top, 8)
                ForEach(items, id: \.0) { item in
                    HStack(spacing: 10) {
                        Image(systemName: item.1).frame(width: 30).foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.0).font(.subheadline.weight(.semibold)).lineLimit(1)
                            Text(KitoDurationFormatting.spelledOut(item.2)).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(KitoDurationFormatting.short(item.2)).frame(width: 62)
                        Text(KitoDurationFormatting.clock(item.2)).frame(width: 62)
                    }
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .padding(10)
                }
            }
        }
    }
}

private struct FmtGreetingSample: View {
    @State private var hour = Calendar.current.component(.hour, from: Date())

    private var date: Date { Calendar.current.date(bySettingHour: hour, minute: 15, second: 0, of: Date()) ?? Date() }
    private var sky: [Color] {
        switch hour {
        case 5..<12: return [Color(red: 1.0, green: 0.78, blue: 0.45), Color(red: 0.98, green: 0.5, blue: 0.4)]
        case 12..<17: return [Color(red: 0.35, green: 0.7, blue: 1.0), Color(red: 0.2, green: 0.45, blue: 0.9)]
        default: return FmtPalette.dusk
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: hour >= 5 && hour < 17 ? "sun.max.fill" : "moon.stars.fill").font(.title).symbolRenderingMode(.multicolor)
                Text("\(KitoDateFormatting.greeting(for: date)), Wycliff").font(.title2.weight(.heavy))
                Text(KitoDateFormatting.full(date)).font(.subheadline.weight(.medium)).opacity(0.85)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .background(LinearGradient(colors: sky, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .animation(.easeInOut(duration: 0.5), value: hour)
            HStack {
                Image(systemName: "clock")
                Slider(value: Binding(get: { Double(hour) }, set: { hour = Int($0) }), in: 0...23, step: 1).tint(.primary)
                Text(KitoDateFormatting.shortTime(date)).font(.caption.monospacedDigit()).frame(width: 64)
            }
        }
    }
}

// MARK: - Distance, size & phone

private struct FmtDistancesSample: View {
    @State private var system: KitoDistanceSystem = .metric
    private let places: [(String, String, Double)] = [
        ("Kahawa Corner, Ngong Rd", "cup.and.saucer.fill", 420), ("Karura Forest gate", "tree.fill", 2_380),
        ("Runda shopping centre", "bag.fill", 8_900), ("JKIA", "airplane", 17_600), ("Lake Naivasha", "water.waves", 88_400),
    ]

    var body: some View {
        VStack(spacing: 14) {
            Picker("Units", selection: $system) {
                Text("Kilometres").tag(KitoDistanceSystem.metric)
                Text("Miles").tag(KitoDistanceSystem.imperial)
            }
            .pickerStyle(.segmented)
            FmtCard(padding: 6) {
                VStack(spacing: 0) {
                    ForEach(places, id: \.0) { place in
                        HStack(spacing: 12) {
                            Image(systemName: place.1).font(.system(size: 14, weight: .semibold)).frame(width: 36, height: 36)
                                .background(Color.primary.opacity(0.07), in: Circle())
                            Text(place.0).font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(KitoDistanceFormatting.string(meters: place.2, system: system))
                                .font(.subheadline.weight(.bold).monospacedDigit())
                                .contentTransition(.numericText())
                        }
                        .padding(10)
                    }
                }
            }
            .animation(.snappy, value: system)
        }
    }
}

private struct FmtDownloadsSample: View {
    @State private var progress: [Double] = [0.18, 0.6, 1.0]
    private let files: [(String, String, Int64)] = [("Offline map · Nairobi", "map.fill", 184_000_000), ("Statement_Aug.pdf", "doc.richtext.fill", 1_240_000), ("Harusi video.mp4", "film.fill", 2_450_000_000)]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(files.indices, id: \.self) { index in
                let file = files[index]
                let received = Int64(Double(file.2) * progress[index])
                HStack(spacing: 12) {
                    FmtIcon(symbol: file.1, colors: [FmtPalette.ocean, FmtPalette.sunset, FmtPalette.dusk][index])
                    VStack(alignment: .leading, spacing: 6) {
                        Text(file.0).font(.subheadline.weight(.semibold)).lineLimit(1)
                        ProgressView(value: progress[index]).tint(.primary)
                        Text(progress[index] >= 1 ? "\(KitoFileSizeFormatting.string(bytes: file.2)) · Done" : KitoFileSizeFormatting.progress(received: received, total: file.2))
                            .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 400_000_000)
                withAnimation(.linear(duration: 0.4)) {
                    progress = progress.map { $0 >= 1 ? 1 : min(1, $0 + Double.random(in: 0.01...0.05)) }
                }
            }
        }
    }
}

private struct FmtPhoneFieldSample: View {
    @State private var text = "0712 345 678"

    private var phone: KitoKenyanPhoneNumber? { KitoKenyanPhoneNumber(text) }

    private func tint(for carrier: KitoKenyanCarrier) -> Color {
        switch carrier {
        case .safaricom: return .green
        case .airtel: return .red
        case .telkom: return .blue
        case .unknown: return .gray
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Text("🇰🇪").font(.title2)
                TextField("0712 345 678", text: Binding(get: { text }, set: { text = KitoPhoneFormatting.kenyanAsYouType($0) }))
                    .keyboardType(.phonePad)
                    .font(.title3.weight(.semibold).monospacedDigit())
                if phone != nil {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(Color(.secondarySystemBackground), in: Capsule())
            .overlay(Capsule().strokeBorder(phone == nil && text.count > 5 ? Color.red.opacity(0.6) : .clear, lineWidth: 1.5))

            if let phone {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Circle().fill(tint(for: phone.carrier)).frame(width: 10, height: 10)
                        Text(phone.carrier.displayName).font(.subheadline.weight(.bold))
                        if let wallet = phone.carrier.walletName {
                            Text(wallet).font(.caption.weight(.bold)).padding(.horizontal, 8).padding(.vertical, 3)
                                .background(tint(for: phone.carrier).opacity(0.15), in: Capsule()).foregroundStyle(tint(for: phone.carrier))
                        }
                    }
                    FmtRow(label: "E.164", value: phone.e164)
                    FmtRow(label: "International", value: phone.international)
                    FmtRow(label: "Local", value: phone.local)
                    FmtRow(label: "Masked", value: phone.masked)
                }
                .padding(16)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                Label("Enter a Kenyan mobile number", systemImage: "info.circle").font(.footnote).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                ForEach(["0712345678", "+254733111222", "0110 987 654", "0772 000 111"], id: \.self) { sample in
                    Button(String(sample.suffix(3))) { text = KitoPhoneFormatting.kenyanAsYouType(sample) }
                        .font(.caption.weight(.bold)).buttonStyle(.bordered).tint(.primary)
                }
            }
        }
        .animation(.snappy, value: phone)
    }
}

private struct FmtPhoneTableSample: View {
    private let inputs = ["0712345678", "712 345 678", "+254 712 345 678", "254712345678", "(0733) 45-67-89", "0812345678", "07123"]

    var body: some View {
        FmtCard(padding: 6) {
            VStack(spacing: 0) {
                ForEach(inputs, id: \.self) { input in
                    let phone = KitoKenyanPhoneNumber(input)
                    HStack(spacing: 10) {
                        Image(systemName: phone == nil ? "xmark.circle.fill" : "checkmark.circle.fill").foregroundStyle(phone == nil ? .red : .green)
                        Text(input).font(.caption.monospaced()).lineLimit(1)
                        Spacer()
                        Text(phone?.international ?? "Not a mobile number")
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(phone == nil ? .secondary : .primary)
                    }
                    .padding(10)
                }
            }
        }
    }
}

private struct FmtLeaderboardSample: View {
    private let people: [(String, Int)] = [("Wycliff N", 4_820), ("Achieng O.", 4_610), ("Kamau W.", 3_990), ("Njeri M.", 3_450), ("Otieno J.", 2_975), ("Wanjiru K.", 2_410)]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(people.enumerated()), id: \.offset) { index, person in
                HStack(spacing: 12) {
                    Text(KitoNumberFormatting.ordinal(index + 1))
                        .font(.subheadline.weight(.heavy))
                        .frame(width: 44, height: 36)
                        .background(index < 3 ? [Color.yellow, Color.gray, Color.orange][index].opacity(0.3) : Color.primary.opacity(0.06), in: Capsule())
                    Text(person.0).font(.subheadline.weight(index == 0 ? .bold : .medium))
                    Spacer()
                    Text("\(KitoNumberFormatting.grouped(Double(person.1))) pts").font(.subheadline.weight(.semibold).monospacedDigit())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(index == 0 ? Color.primary.opacity(0.06) : .clear, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

// MARK: - Catalog

enum FormattingSamples {
    static let sections: [KitSection] = [money, animated, changes, dates, everydayUnits]

    static let money = KitSection("Money", symbol: "banknote", [
        KitSample("A receipt in shillings", "Fixed grouping on every device; cents only when there are some.", code: """
        Decimal(1450).kitoAmount(in: .kes)                    // "KES 1,450"
        Decimal(750.5).kitoAmount(in: .kes)                   // "KES 750.50"
        total.kitoAmount(in: .kes, cents: .always)            // "KES 2,480.50"
        """) { FmtReceiptSample() },
        KitSample("Compact stat tiles", "Big numbers that fit a tile: KES 1.2M, KES 48.5K.", code: """
        Decimal(1_248_300).kitoCompactAmount(in: .kes)   // "KES 1.2M"
        Decimal(48_520).kitoCompactAmount(in: .kes)      // "KES 48.5K"
        """) { FmtCompactTilesSample() },
        KitSample("Every currency", "Shillings from Kenya, Uganda and Tanzania, plus the majors, by code or symbol.", code: """
        amount.kitoAmount(in: .ugx)                    // "UGX 24,651" (no decimals)
        amount.kitoAmount(in: .kes, display: .symbol)  // "KSh 24,650.75"
        KitoCurrency.tzs.flag                          // "🇹🇿"
        """) { FmtCurrenciesSample() },
        KitSample("Signed transactions", "Money in and money out, with a true minus sign.", code: """
        KitoMoneyFormatting.signed(2_500, currency: .kes)     // "+KES 2,500"
        KitoMoneyFormatting.signed(-1_836.5, currency: .kes)  // "−KES 1,836.50"
        """) { FmtTransactionsSample() },
        KitSample("Following the region", "The same amount in five locales when you want local conventions.", code: """
        amount.kitoFormatted(currency: .kes, locale: Locale(identifier: "sw_KE"))
        amount.kitoFormatted(currency: .kes)   // the device's own locale
        """) { FmtLocalesSample() },
        KitSample("Split the bill", "Drag the total, add people and a tip; the share rolls to its new value.", code: """
        KitoAnimatedNumberText(total * (1 + tip) / Double(people)) {
            KitoMoneyFormatting.string(Decimal($0), currency: .kes, cents: .never)
        }
        .font(.system(size: 44, weight: .heavy, design: .rounded))
        """) { FmtSplitBillSample() },
    ])

    static let animated = KitSection("Animated numbers", symbol: "number", [
        KitSample("Rolling balance", "Receive or pay and the wallet balance rolls digit by digit.", code: """
        KitoAnimatedNumberText(balance) {
            KitoMoneyFormatting.string(Decimal($0), currency: .kes, cents: .always)
        }
        """) { FmtRollingBalanceSample() },
        KitSample("Counting up", "Stats count in from zero when they appear.", code: """
        KitoCountingText(12_480, duration: 1.4)
        KitoCountingText(84_200) { KitoMoneyFormatting.compact(Decimal($0), currency: .kes) }
        KitoCountingText(0.964) { KitoNumberFormatting.percent($0, fractionDigits: 1) }
        """) { FmtCountingSample() },
        KitSample("Live counter", "Fares ticking up in real time, each change rolling in.", code: """
        KitoAnimatedNumberText(fares) { KitoMoneyFormatting.string(Decimal($0), currency: .kes, cents: .never) }
            .task { while true { try? await Task.sleep(for: .seconds(1.3)); fares += 250 } }
        """) { FmtLiveCounterSample() },
        KitSample("Scoreboard", "Tap a team to score; the digits roll over.", code: """
        KitoAnimatedNumberText(Double(home))
            .font(.system(size: 54, weight: .heavy, design: .rounded))
        """) { FmtScoreboardSample() },
    ])

    static let changes = KitSection("Changes & percentages", symbol: "chart.line.uptrend.xyaxis", [
        KitSample("Change badges", "Pill, plain and solid, green up, red down, grey when flat.", code: """
        KitoChangeBadge(0.124)                   // pill, "+12.4%"
        KitoChangeBadge(-0.031, style: .plain)
        KitoChangeBadge(0.587, style: .solid)
        KitoNumberFormatting.signedPercent(-0.031) // "−3.1%"
        """) { FmtChangeBadgesSample() },
        KitSample("Portfolio rows", "Holdings with sparklines and daily change.", code: """
        HStack {
            Text(holding.name)
            Spacer()
            Sparkline(holding.history).stroke(KitoTrend(holding.change) == .up ? .green : .red)
            KitoChangeBadge(holding.change)
        }
        """) { FmtPortfolioSample() },
        KitSample("Spending, where down is good", "Inverted colours for numbers you want to fall.", code: "KitoChangeBadge(-0.082, style: .plain, invertsColors: true)   // green") { FmtSpendingSample() },
        KitSample("Progress to a goal", "A savings ring with the percentage rolling as you add.", code: """
        KitoAnimatedNumberText(saved / goal) { KitoNumberFormatting.percent($0) }
        Text("\\(Decimal(saved).kitoAmount(in: .kes)) saved of \\(Decimal(goal).kitoAmount(in: .kes))")
        """) { FmtGoalSample() },
    ])

    static let dates = KitSection("Dates & durations", symbol: "clock", [
        KitSample("Chat timestamps", "now, 5m, 3h, 2d, then a date: the tight format chat lists use.", code: "Text(KitoDateFormatting.abbreviated(message.sentAt))   // \"5m\"") { FmtChatListSample() },
        KitSample("Grouped by day", "Today, Yesterday, a weekday, then a date.", code: """
        ForEach(days) { day in
            Section(KitoDateFormatting.dayLabel(day.date)) { … }   // "Today", "Yesterday", "Monday"
        }
        """) { FmtGroupedDaysSample() },
        KitSample("Delivery windows", "Time ranges as selectable slots.", code: "Text(KitoDateFormatting.timeRange(slot.start, slot.end))   // \"9:00 – 10:30 AM\"") { FmtDeliveryWindowsSample() },
        KitSample("Durations", "Short, clock and spelled-out forms side by side.", code: """
        KitoDurationFormatting.short(3_900)       // "1h 5m"
        KitoDurationFormatting.clock(3_900)       // "1:05:00"
        KitoDurationFormatting.spelledOut(3_900)  // "1 hour, 5 minutes"
        """) { FmtDurationsSample() },
        KitSample("Good morning, Wycliff", "A greeting that follows the time of day; drag the hour.", code: """
        Text("\\(KitoDateFormatting.greeting()), Wycliff")
        Text(KitoDateFormatting.full(Date()))
        """) { FmtGreetingSample() },
    ])

    static let everydayUnits = KitSection("Distance, size & phone", symbol: "ruler", [
        KitSample("Distances", "Metres below a kilometre, one decimal below ten, or miles.", code: """
        KitoDistanceFormatting.string(meters: 420)                     // "420 m"
        KitoDistanceFormatting.string(meters: 2_380)                   // "2.4 km"
        KitoDistanceFormatting.string(meters: 17_600, system: .imperial) // "11 mi"
        """) { FmtDistancesSample() },
        KitSample("Download sizes", "Live progress in bytes, as a download moves.", code: """
        KitoFileSizeFormatting.progress(received: received, total: size)   // "1.2 MB of 4.5 MB"
        KitoFileSizeFormatting.string(bytes: 2_450_000_000)                // "2.45 GB"
        """) { FmtDownloadsSample() },
        KitSample("Kenyan phone field", "Formats as you type, validates, and guesses the network and wallet.", code: """
        TextField("0712 345 678", text: Binding(get: { text }, set: { text = KitoPhoneFormatting.kenyanAsYouType($0) }))

        if let phone = KitoKenyanPhoneNumber(text) {
            phone.e164              // "+254712345678"
            phone.carrier.walletName // "M-Pesa"
        }
        """) { FmtPhoneFieldSample() },
        KitSample("Phone numbers, any shape", "Seven ways people type a number, and what parses.", code: "KitoKenyanPhoneNumber(\"(0733) 45-67-89\")?.international   // \"+254 733 456 789\"") { FmtPhoneTableSample() },
        KitSample("Ranks", "English ordinals for a leaderboard.", code: "Text(KitoNumberFormatting.ordinal(rank))   // \"1st\", \"2nd\", \"3rd\", \"11th\"") { FmtLeaderboardSample() },
    ])
}

/// Every formatting sample.
struct FormattingDemo: View {
    static var count: Int { KitGallery.count(FormattingSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Formatting",
            sections: FormattingSamples.sections,
            footnote: "Requires `import KitoFormatting`.",
            searchHint: "Try “shillings”, “phone”, “counting” or “yesterday”."
        )
    }
}
