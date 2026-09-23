//
//  WidgetsSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Combine
import WidgetKit
import KitoWidgets

// MARK: - Shared pieces

/// Store keys shared with the widgets in `KitoWidgetsBundle.swift`.
private enum SampleKeys {
    static let steps = "kito.sample.steps"
    static let tasks = "kito.sample.tasks"
    static let water = "kito.sample.water"
}

private enum SampleData {
    static let week: [Double] = [6_200, 7_400, 5_100, 8_900, 7_600, 9_800]

    static func rings(move: Double = 420, exercise: Double = 22, stand: Double = 9) -> [KitoRing] {
        [
            KitoRing(title: "Move", value: move, goal: 600, unit: "kcal", color: Color(red: 1, green: 0.22, blue: 0.42), symbol: "flame.fill"),
            KitoRing(title: "Exercise", value: exercise, goal: 30, unit: "min", color: Color(red: 0.62, green: 1, blue: 0.2), symbol: "figure.run"),
            KitoRing(title: "Stand", value: stand, goal: 12, unit: "hr", color: Color(red: 0.2, green: 0.9, blue: 1), symbol: "figure.stand"),
        ]
    }

    static let tasks: [KitoWidgetTask] = [
        KitoWidgetTask(id: "milk", title: "Buy oat milk", detail: "Groceries"),
        KitoWidgetTask(id: "bank", title: "Call the bank", detail: "Before 5 pm"),
        KitoWidgetTask(id: "flights", title: "Book flights", detail: "Mombasa trip"),
        KitoWidgetTask(id: "plants", title: "Water the plants"),
        KitoWidgetTask(id: "review", title: "Review the widgets PR", detail: "KitoWidgets"),
    ]

    static let extraTasks = ["Pick up dry cleaning", "Renew car insurance", "Plan Saturday brunch", "Pay the electricity bill", "Send the invoice"]

    static func agenda(from now: Date) -> [KitoWidgetTask] {
        let items: [(String, String, Double)] = [
            ("Stand-up", "Zoom", -1), ("Design review", "Studio 2", 1), ("Lunch with Amara", "Java House", 2.5),
            ("Dentist", "Westlands", 4), ("Gym", "Legs day", 6), ("Call mum", "", 8),
        ]
        return items.map { title, detail, hours in
            KitoWidgetTask(id: title, title: title, detail: detail.isEmpty ? nil : detail,
                           due: now.addingTimeInterval(hours * 3_600), isDone: hours < 0)
        }
    }

    static let transactions: [KitoBalanceTransaction] = [
        KitoBalanceTransaction(title: "Salary", amount: 85_000, symbol: "briefcase.fill", date: Date().addingTimeInterval(-3_600)),
        KitoBalanceTransaction(title: "Java House", amount: -650, symbol: "cup.and.saucer.fill", date: Date().addingTimeInterval(-7_200)),
        KitoBalanceTransaction(title: "Uber", amount: -1_200, symbol: "car.fill", date: Date().addingTimeInterval(-26_000)),
    ]

    static let quotes: [(text: String, author: String)] = [
        ("Simplicity is the soul of efficiency.", "R. Austin Freeman"),
        ("The best way out is always through.", "Robert Frost"),
        ("Small steps, every day, add up to a long way.", "Kito"),
        ("Well begun is half done.", "Aristotle"),
    ]

    static func link(_ path: String) -> URL {
        URL(string: "kitosample://\(path)") ?? URL(fileURLWithPath: "/")
    }
}

/// A generated landscape standing in for a user's photo.
@MainActor
private enum SamplePhoto {
    static let image: Image = {
        let size = CGSize(width: 600, height: 600)
        let rendered = UIGraphicsImageRenderer(size: size).image { context in
            let cg = context.cgContext
            let colors = [UIColor(red: 1, green: 0.6, blue: 0.3, alpha: 1).cgColor, UIColor(red: 0.9, green: 0.25, blue: 0.45, alpha: 1).cgColor,
                          UIColor(red: 0.25, green: 0.15, blue: 0.5, alpha: 1).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.55, 1]) {
                cg.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }
            UIColor(white: 1, alpha: 0.85).setFill()
            cg.fillEllipse(in: CGRect(x: 380, y: 150, width: 110, height: 110))
            let far = UIBezierPath()
            far.move(to: CGPoint(x: 0, y: 420)); far.addLine(to: CGPoint(x: 170, y: 270)); far.addLine(to: CGPoint(x: 330, y: 400))
            far.addLine(to: CGPoint(x: 470, y: 300)); far.addLine(to: CGPoint(x: 600, y: 390)); far.addLine(to: CGPoint(x: 600, y: 600))
            far.addLine(to: CGPoint(x: 0, y: 600)); far.close()
            UIColor(red: 0.35, green: 0.12, blue: 0.3, alpha: 0.85).setFill(); far.fill()
            let near = UIBezierPath()
            near.move(to: CGPoint(x: 0, y: 500)); near.addQuadCurve(to: CGPoint(x: 600, y: 470), controlPoint: CGPoint(x: 300, y: 400))
            near.addLine(to: CGPoint(x: 600, y: 600)); near.addLine(to: CGPoint(x: 0, y: 600)); near.close()
            UIColor(red: 0.12, green: 0.05, blue: 0.18, alpha: 1).setFill(); near.fill()
        }
        return Image(uiImage: rendered)
    }()
}

/// Small, medium and large, one under the other.
private struct HomeSizes<Widget: View>: View {
    var families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
    var placement: KitoWidgetPlacement = .homeScreen
    @ViewBuilder let widget: () -> Widget

    var body: some View {
        VStack(spacing: 22) {
            ForEach(families, id: \.self) { family in
                KitoWidgetPreviewFrame(family, placement: placement, showsLabel: true) { widget() }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// The three Lock Screen families.
private struct LockScreenSizes<Widget: View>: View {
    var families: [WidgetFamily] = [.accessoryCircular, .accessoryRectangular, .accessoryInline]
    @ViewBuilder let widget: () -> Widget

    var body: some View {
        VStack(spacing: 18) {
            ForEach(families, id: \.self) { family in
                KitoWidgetPreviewFrame(family, showsLabel: true) { widget() }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// A card of controls under a sample.
private struct Controls<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) { content() }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}

private struct LabeledSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var format: (Double) -> String = { "\(Int($0))" }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.subheadline.weight(.medium))
                Spacer()
                Text(format(value)).font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step).tint(.primary)
        }
    }
}

private struct BackgroundPicker: View {
    @Binding var index: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(KitoWidgetGradient.presets.enumerated()), id: \.offset) { offset, preset in
                    Button {
                        withAnimation(.smooth) { index = offset }
                    } label: {
                        KitoWidgetBackground(preset.gradient)
                            .frame(width: 38, height: 38)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(Color.primary.opacity(index == offset ? 0.9 : 0.1), lineWidth: index == offset ? 2.5 : 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(preset.name))
                    .accessibilityAddTraits(index == offset ? .isSelected : [])
                }
            }
            .padding(.vertical, 2)
        }
    }
}

/// Reloads a view's data whenever a widget intent (or anything else) writes to the store.
private extension View {
    func onStoreChange(_ action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: KitoWidgetStore.didChangeNotification).receive(on: RunLoop.main)) { _ in
            withAnimation(.snappy) { action() }
        }
    }
}

// MARK: - Stats

private struct StatPlayground: View {
    @State private var steps: Double = 8_432

    var body: some View {
        VStack(spacing: 22) {
            HomeSizes {
                KitoStatWidgetView(title: "Steps", value: steps, previous: 7_510, history: SampleData.week + [steps],
                                   symbol: "figure.walk", tint: .mint, caption: "vs. yesterday")
            }
            Controls {
                LabeledSlider(title: "Today", value: $steps, range: 0...20_000, step: 50) { $0.formatted(.number.precision(.fractionLength(0))) }
                Button { withAnimation(.snappy) { steps = min(steps + 1_000, 20_000) } } label: {
                    Label("Walk 1,000 steps", systemImage: "figure.walk").frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
    }
}

private struct StatLockScreen: View {
    @State private var steps: Double = 6_120

    var body: some View {
        VStack(spacing: 22) {
            LockScreenSizes {
                KitoStatWidgetView(title: "Steps", value: steps, previous: 7_510, history: SampleData.week + [steps], symbol: "figure.walk")
            }
            Controls {
                LabeledSlider(title: "Today", value: $steps, range: 0...20_000, step: 50) { $0.formatted(.number.precision(.fractionLength(0))) }
            }
        }
    }
}

private struct SpendingSample: View {
    @State private var spent: Double = 18_400
    @State private var background = 4

    var body: some View {
        VStack(spacing: 22) {
            HomeSizes(families: [.systemSmall, .systemMedium]) {
                KitoStatWidgetView(title: "Spent this week", value: spent, previous: 15_200,
                                   history: [9_800, 14_100, 12_600, 16_900, 15_200, spent], format: .currency(code: "KES", fractionDigits: 0),
                                   symbol: "cart.fill", tint: .orange, caption: "vs. last week", increaseIsGood: false,
                                   background: KitoWidgetGradient.presets[background].gradient)
            }
            Controls {
                LabeledSlider(title: "Spent", value: $spent, range: 5_000...30_000, step: 100) { "KES \($0.formatted(.number.precision(.fractionLength(0))))" }
                BackgroundPicker(index: $background)
            }
        }
    }
}

// MARK: - Goals

private struct RingsPlayground: View {
    @State private var move: Double = 420
    @State private var exercise: Double = 22
    @State private var stand: Double = 9

    var body: some View {
        VStack(spacing: 22) {
            HomeSizes {
                KitoProgressRingWidgetView(rings: SampleData.rings(move: move, exercise: exercise, stand: stand),
                                           caption: "Close your rings by 9 pm")
            }
            Controls {
                LabeledSlider(title: "Move", value: $move, range: 0...1_000, step: 10) { "\(Int($0)) kcal" }
                LabeledSlider(title: "Exercise", value: $exercise, range: 0...60) { "\(Int($0)) min" }
                LabeledSlider(title: "Stand", value: $stand, range: 0...24) { "\(Int($0)) hr" }
            }
        }
    }
}

private struct RingsLockScreen: View {
    @State private var closed = false

    var body: some View {
        VStack(spacing: 22) {
            LockScreenSizes {
                KitoProgressRingWidgetView(rings: closed ? SampleData.rings(move: 640, exercise: 34, stand: 12) : SampleData.rings())
            }
            Button { withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { closed.toggle() } } label: {
                Label(closed ? "Reset rings" : "Close all rings", systemImage: closed ? "arrow.counterclockwise" : "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct GaugeSample: View {
    @State private var aqi: Double = 72

    private var status: (caption: String, detail: String) {
        switch aqi {
        case ..<51: return ("Good", "Air quality is great. Enjoy being outside.")
        case ..<101: return ("Moderate", "Sensitive groups should limit long outdoor exertion.")
        case ..<151: return ("Unhealthy for some", "Children and older adults should take it easy outside.")
        case ..<201: return ("Unhealthy", "Everyone should cut back on outdoor exertion.")
        default: return ("Very unhealthy", "Stay indoors and keep windows closed.")
        }
    }

    var body: some View {
        VStack(spacing: 22) {
            HomeSizes(families: [.systemSmall, .systemMedium]) {
                KitoGaugeWidgetView(title: "Air quality", value: aqi, in: 0...300, symbol: "aqi.medium",
                                    caption: status.caption, detail: status.detail)
            }
            LockScreenSizes(families: [.accessoryCircular, .accessoryRectangular]) {
                KitoGaugeWidgetView(title: "Air quality", value: aqi, in: 0...300, symbol: "aqi.medium", caption: status.caption)
            }
            Controls {
                LabeledSlider(title: "AQI", value: $aqi, range: 0...300)
            }
        }
    }
}

private struct WaterSample: View {
    @State private var counter = KitoWidgetCounter()

    private func reload() {
        counter = KitoWidgetStore.shared.load(KitoWidgetCounter.self, forKey: SampleKeys.water, default: KitoWidgetCounter())
    }

    var body: some View {
        VStack(spacing: 22) {
            HomeSizes(families: [.systemSmall, .systemMedium]) {
                KitoCounterWidgetView(title: "Water", counter: counter, counterKey: SampleKeys.water)
            }
            LockScreenSizes(families: [.accessoryCircular, .accessoryRectangular]) {
                KitoCounterWidgetView(title: "Water", counter: counter, counterKey: SampleKeys.water)
            }
            Controls {
                Text("The + and − buttons are `Button(intent:)` running `KitoIncrementCounterIntent` — here in the app, on the Home Screen in the widget. Both write to the same App Group.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button {
                    try? KitoWidgetStore.shared.save(KitoWidgetCounter(), forKey: SampleKeys.water)
                    KitoWidgetStore.reloadTimelines(ofKind: "KitoWaterWidget")
                } label: {
                    Label("Start the day again", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
        .onAppear(perform: reload)
        .onStoreChange(reload)
    }
}

// MARK: - Time

private enum CountdownScenario: String, CaseIterable, Identifiable {
    case days = "12 days", hours = "5 hours", minute = "1 minute", live = "Live", ended = "Ended"
    var id: String { rawValue }
}

private struct CountdownModel {
    let target: Date
    let start: Date
    let end: Date

    init(_ scenario: CountdownScenario, anchor: Date) {
        switch scenario {
        case .days: target = anchor.addingTimeInterval(12 * 86_400 + 5 * 3_600)
        case .hours: target = anchor.addingTimeInterval(5 * 3_600 + 754)
        case .minute: target = anchor.addingTimeInterval(60)
        case .live: target = anchor.addingTimeInterval(-600)
        case .ended: target = anchor.addingTimeInterval(-7_200)
        }
        start = target.addingTimeInterval(-20 * 86_400)
        end = target.addingTimeInterval(3_600)
    }
}

private struct CountdownPlayground: View {
    var lockScreen = false
    @State private var scenario: CountdownScenario = .days
    @State private var anchor = Date()

    var body: some View {
        VStack(spacing: 22) {
            Picker("Starts in", selection: $scenario) {
                ForEach(CountdownScenario.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: scenario) { anchor = Date() }
            // Re-rendered every second so the layout flips at the target, as timeline entries would.
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let model = CountdownModel(scenario, anchor: anchor)
                let widget = KitoCountdownWidgetView(title: "Launch Day", target: model.target, start: model.start, end: model.end,
                                                     symbol: "sparkles", now: context.date)
                if lockScreen {
                    LockScreenSizes { widget }
                } else {
                    HomeSizes { widget }
                }
            }
        }
    }
}

private struct CountdownPhases: View {
    @State private var anchor = Date()

    var body: some View {
        let phases: [(CountdownScenario, KitoWidgetGradient, String)] = [
            (.days, .sunset, "sparkles"), (.hours, .ocean, "sportscourt.fill"), (.live, .midnight, "play.tv.fill"), (.ended, .mint, "flag.checkered"),
        ]
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: 14)], spacing: 14) {
            ForEach(phases, id: \.0) { scenario, background, symbol in
                let model = CountdownModel(scenario, anchor: anchor)
                KitoWidgetPreviewFrame(.systemSmall) {
                    KitoCountdownWidgetView(title: scenario == .hours ? "Kickoff" : "Launch", target: model.target, start: model.start,
                                            end: model.end, symbol: symbol, background: background, now: anchor)
                }
            }
        }
    }
}

// MARK: - Lists and actions

private struct TasksSample: View {
    @State private var tasks: [KitoWidgetTask] = []

    private func reload() {
        tasks = KitoWidgetStore.shared.load([KitoWidgetTask].self, forKey: SampleKeys.tasks) ?? SampleData.tasks
    }

    private func save(_ new: [KitoWidgetTask]) {
        try? KitoWidgetStore.shared.save(new, forKey: SampleKeys.tasks)
        KitoWidgetStore.reloadTimelines(ofKind: "KitoTasksWidget")
    }

    var body: some View {
        VStack(spacing: 22) {
            HomeSizes {
                KitoListWidgetView(title: "Today", items: tasks, storeKey: SampleKeys.tasks)
            }
            Controls {
                Text("Tap a check: it runs `KitoToggleTaskIntent`, which saves to the store the widget reads.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    Button {
                        let title = SampleData.extraTasks.first { name in !tasks.contains { $0.title == name } } ?? "New task"
                        save([KitoWidgetTask(title: title)] + tasks)
                    } label: {
                        Label("Add", systemImage: "plus").frame(maxWidth: .infinity)
                    }
                    Button { save(SampleData.tasks) } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
        .onAppear {
            reload()
            if KitoWidgetStore.shared.load([KitoWidgetTask].self, forKey: SampleKeys.tasks) == nil { save(SampleData.tasks) }
        }
        .onStoreChange(reload)
    }
}

private struct AgendaSample: View {
    @State private var now = Date()

    var body: some View {
        HomeSizes(families: [.systemSmall, .systemMedium, .systemLarge]) {
            KitoListWidgetView(title: "Agenda", items: SampleData.agenda(from: now), style: .agenda, symbol: "calendar",
                               tint: .orange, background: .midnight)
        }
    }
}

private struct QuickActionsSample: View {
    @State private var water = KitoWidgetCounter()

    private var actions: [KitoQuickAction] {
        [
            KitoQuickAction(title: "Water", symbol: "drop.fill", tint: .cyan, action: .perform(KitoIncrementCounterIntent(counterKey: SampleKeys.water))),
            KitoQuickAction(title: "Scan", symbol: "qrcode.viewfinder", tint: .orange, action: .open(SampleData.link("scan"))),
            KitoQuickAction(title: "Pay", symbol: "creditcard.fill", tint: .green, action: .open(SampleData.link("pay"))),
            KitoQuickAction(title: "Note", symbol: "square.and.pencil", tint: .purple, action: .open(SampleData.link("note"))),
        ]
    }

    private func reload() {
        water = KitoWidgetStore.shared.load(KitoWidgetCounter.self, forKey: SampleKeys.water, default: KitoWidgetCounter()).current()
    }

    var body: some View {
        VStack(spacing: 22) {
            HomeSizes(families: [.systemSmall, .systemMedium, .systemLarge]) {
                KitoQuickActionsWidgetView(title: "Shortcuts", actions: actions)
            }
            Controls {
                Label("Water logged today: \(water.count)", systemImage: "drop.fill")
                    .font(.subheadline.weight(.semibold))
                    .contentTransition(.numericText(value: Double(water.count)))
                Text("Water runs an intent in place. Scan, Pay and Note open the app at a deep link — `Link` in medium and large, `KitoOpenDeepLinkIntent` in small.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear(perform: reload)
        .onStoreChange(reload)
    }
}

// MARK: - Media and weather

private struct QuoteSample: View {
    @State private var index = 0
    @State private var background = 6

    var body: some View {
        let quote = SampleData.quotes[index % SampleData.quotes.count]
        VStack(spacing: 22) {
            HomeSizes {
                KitoQuoteWidgetView(quote: quote.text, author: quote.author, background: KitoWidgetGradient.presets[background].gradient)
            }
            Controls {
                BackgroundPicker(index: $background)
                Button { withAnimation(.smooth) { index += 1 } } label: {
                    Label("Next quote", systemImage: "quote.bubble").frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
    }
}

private struct PhotoSample: View {
    @State private var showsBadge = true
    @State private var asQuote = false

    var body: some View {
        VStack(spacing: 22) {
            HomeSizes {
                if asQuote {
                    KitoQuoteWidgetView(quote: "The best way out is always through.", author: "Robert Frost", photo: SamplePhoto.image)
                } else {
                    KitoPhotoWidgetView(photo: SamplePhoto.image, title: "Diani Beach", subtitle: "One year ago today",
                                        badge: showsBadge ? "Memories" : nil)
                }
            }
            Controls {
                Toggle("Badge", isOn: $showsBadge.animation()).disabled(asQuote)
                Toggle("Quote over the photo", isOn: $asQuote.animation())
            }
            .tint(.primary)
        }
    }
}

private enum WeatherCondition: String, CaseIterable, Identifiable {
    case sunny = "Sunny", rainy = "Rainy", night = "Night"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .rainy: return "cloud.rain.fill"
        case .night: return "moon.stars.fill"
        }
    }

    var summary: String {
        switch self {
        case .sunny: return "Sunny"
        case .rainy: return "Showers"
        case .night: return "Clear"
        }
    }

    var background: KitoWidgetGradient {
        switch self {
        case .sunny: return .ocean
        case .rainy: return .graphite
        case .night: return .midnight
        }
    }

    var temperature: Double {
        switch self {
        case .sunny: return 27
        case .rainy: return 18
        case .night: return 14
        }
    }

    func hours(from now: Date) -> [KitoHourlyForecast] {
        (0..<12).map { hour in
            let wave = sin(Double(hour) / 2)
            let rain = self == .rainy ? max(0.1, 0.5 + 0.4 * wave) : 0.05
            let symbol = self == .rainy && rain > 0.55 ? "cloud.heavyrain.fill" : (self == .sunny && hour > 3 ? "cloud.sun.fill" : self.symbol)
            return KitoHourlyForecast(date: now.addingTimeInterval(Double(hour) * 3_600), symbol: symbol,
                                      temperature: temperature + wave * 2 - Double(hour) * 0.3, precipitationChance: rain)
        }
    }
}

private struct WidgetWeatherSample: View {
    var lockScreen = false
    @State private var condition: WeatherCondition = .sunny

    var body: some View {
        VStack(spacing: 22) {
            Picker("Sky", selection: $condition.animation(.smooth)) {
                ForEach(WeatherCondition.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            let widget = KitoWeatherStyleWidgetView(location: "Nairobi", temperature: condition.temperature, condition: condition.summary,
                                                    symbol: condition.symbol, high: condition.temperature + 3, low: condition.temperature - 8,
                                                    hourly: condition.hours(from: Date()), background: condition.background)
            if lockScreen {
                LockScreenSizes { widget }
            } else {
                HomeSizes { widget }
            }
        }
    }
}

// MARK: - Finance

private struct BalanceSample: View {
    var lockScreen = false
    @State private var isHidden = false
    @State private var alwaysOn = false
    @State private var locked = false

    var body: some View {
        VStack(spacing: 22) {
            Group {
                let widget = KitoBalanceWidgetView(title: "Everyday", balance: 124_480.5, currencyCode: "KES", change: 2_300,
                                                   history: [98_000, 104_500, 101_200, 112_800, 109_900, 121_400, 124_480],
                                                   accountSuffix: "4821", transactions: SampleData.transactions, isHidden: isHidden)
                if lockScreen {
                    LockScreenSizes { widget }
                } else {
                    HomeSizes { widget }
                }
            }
            .environment(\.isLuminanceReduced, alwaysOn)
            .redacted(reason: locked ? .privacy : [])
            Controls {
                Toggle("Hide balance", isOn: $isHidden.animation())
                Toggle("Always-On display", isOn: $alwaysOn.animation())
                Toggle("Device locked (privacy redaction)", isOn: $locked.animation())
            }
            .tint(.primary)
        }
    }
}

// MARK: - Look and feel

private struct PresetsGrid: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: 14)], spacing: 18) {
            ForEach(Array(KitoWidgetGradient.presets.enumerated()), id: \.offset) { _, preset in
                VStack(spacing: 6) {
                    KitoWidgetPreviewFrame(.systemSmall) {
                        KitoStatWidgetView(title: "Steps", value: 8_432, previous: 7_510, history: SampleData.week + [8_432],
                                           symbol: "figure.walk", tint: preset.gradient.foreground == .primary ? .blue : .white,
                                           background: preset.gradient)
                    }
                    Text(".\(preset.name.lowercased())").font(.caption.monospaced()).foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct StandBySample: View {
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                KitoWidgetPreviewFrame(.systemSmall, placement: .standBy) {
                    KitoProgressRingWidgetView(rings: SampleData.rings())
                }
                KitoWidgetPreviewFrame(.systemSmall, placement: .standBy) {
                    KitoCountdownWidgetView(title: "Kickoff", target: Date().addingTimeInterval(5 * 3_600), symbol: "sportscourt.fill")
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 30, style: .continuous).fill(.black))
            Text("StandBy removes the background and shows widgets on black, scaled up. Colour comes from rings, tints and symbols.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct LightDarkSample: View {
    var body: some View {
        HStack(spacing: 12) {
            ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
                VStack(spacing: 6) {
                    KitoWidgetPreviewFrame(.systemSmall) {
                        KitoListWidgetView(title: "Today", items: SampleData.tasks, onToggle: { _ in })
                    }
                    Text(scheme == .light ? "Light" : "Dark").font(.caption).foregroundStyle(.secondary)
                }
                .environment(\.colorScheme, scheme)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Set up

private struct AddToHomeScreen: View {
    private let steps: [(String, String)] = [
        ("hand.tap.fill", "Touch and hold an empty spot on the Home Screen until the apps jiggle."),
        ("plus.circle.fill", "Tap Edit, then Add Widget."),
        ("magnifyingglass", "Search for KitoDevKit."),
        ("square.grid.2x2.fill", "Swipe to pick Stats, Rings, Countdown, Tasks or Water and a size, then Add Widget."),
        ("lock.fill", "For the Lock Screen: touch and hold it, tap Customize, pick the Lock Screen and tap the widget area."),
        ("iphone.gen3.radiowaves.left.and.right", "For StandBy: charge the phone on its side while locked, then swipe to widgets."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 14) {
                    Text("\(index + 1)")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color(.systemBackground))
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.primary))
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: step.0).font(.headline)
                        Text(step.1).font(.subheadline)
                    }
                }
            }
            KitoWidgetPreviewFrame(.systemMedium) {
                KitoProgressRingWidgetView(rings: SampleData.rings())
            }
            .frame(maxWidth: .infinity)
            Button { KitoWidgetStore.reloadTimelines() } label: {
                Label("Refresh my widgets", systemImage: "arrow.clockwise").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            Text("Tasks and Water are interactive: tap right on the widget, no app launch.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SharedDataSample: View {
    @State private var steps: Double = 0
    private let store = KitoWidgetStore.shared

    var body: some View {
        VStack(spacing: 22) {
            KitoWidgetPreviewFrame(.systemMedium, showsLabel: true) {
                KitoStatWidgetView(title: "Steps", value: steps, previous: 7_510, history: SampleData.week + [steps],
                                   symbol: "figure.walk", tint: .mint)
            }
            Controls {
                Label(store.appGroup.map { "App Group: \($0)" } ?? "No App Group — add KitoWidgetsAppGroup to Info.plist",
                      systemImage: store.appGroup == nil ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(store.appGroup == nil ? .orange : .green)
                LabeledSlider(title: "Steps", value: $steps, range: 0...20_000, step: 50) { $0.formatted(.number.precision(.fractionLength(0))) }
                Button {
                    try? store.save(steps, forKey: SampleKeys.steps)
                    KitoWidgetStore.reloadTimelines(ofKind: "KitoStatsWidget")
                } label: {
                    Label("Save and reload the widget", systemImage: "square.and.arrow.down").frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
        .onAppear { steps = store.load(Double.self, forKey: SampleKeys.steps, default: 8_432) }
    }
}

// MARK: - Catalogue

enum WidgetsSamples {
    private static let stats = KitSection("Stats", symbol: "chart.line.uptrend.xyaxis", [
        KitSample("Stat in every size", "A big number, its change and a sparkline; drag to change today.", code: """
        KitoStatWidgetView(title: "Steps", value: steps, previous: 7_510, history: week,
                           symbol: "figure.walk", tint: .mint, caption: "vs. yesterday")
        """) { StatPlayground() },
        KitSample("Stat on the Lock Screen", "Circular, rectangular and inline, rendered vibrant.", code: """
        StaticConfiguration(kind: "Steps", provider: provider) { entry in
            KitoStatWidgetView(title: "Steps", value: entry.value, previous: 7_510)
        }
        .supportedFamilies(KitoStatWidgetView.supportedFamilies)
        """) { StatLockScreen() },
        KitSample("Spending", "Money in any currency; a rise shows red when it's bad news.", code: """
        KitoStatWidgetView(title: "Spent this week", value: spent, previous: 15_200,
                           format: .currency(code: "KES", fractionDigits: 0),
                           symbol: "cart.fill", tint: .orange, increaseIsGood: false, background: .ember)
        """) { SpendingSample() },
    ])

    private static let goals = KitSection("Goals", symbol: "circle.circle", [
        KitSample("Activity rings", "Up to four rings; past the goal they go round again.", code: """
        KitoProgressRingWidgetView(rings: [
            KitoRing(title: "Move", value: 420, goal: 600, unit: "kcal", color: .pink, symbol: "flame.fill"),
            KitoRing(title: "Exercise", value: 22, goal: 30, unit: "min", color: .green, symbol: "figure.run"),
            KitoRing(title: "Stand", value: 9, goal: 12, unit: "hr", color: .cyan, symbol: "figure.stand"),
        ], caption: "Close your rings by 9 pm")
        """) { RingsPlayground() },
        KitSample("Rings on the Lock Screen", "Concentric rings that take the Lock Screen's tint.", code: """
        KitoProgressRingWidgetView(rings: rings)   // same view, accessory families
        """) { RingsLockScreen() },
        KitSample("Gauge", "A 270° gradient arc with a status, from air quality to battery.", code: """
        KitoGaugeWidgetView(title: "Air quality", value: aqi, in: 0...300, symbol: "aqi.medium",
                            caption: "Moderate", detail: "Sensitive groups should limit long outdoor exertion.")
        """) { GaugeSample() },
        KitSample("Water tracker", "Interactive: + logs a glass through an App Intent.", code: """
        KitoCounterWidgetView(title: "Water", counter: entry.value, counterKey: "kito.sample.water")

        // The + button inside is just:
        Button(intent: KitoIncrementCounterIntent(counterKey: "kito.sample.water")) { … }
        """) { WaterSample() },
    ])

    private static let time = KitSection("Time", symbol: "timer", [
        KitSample("Countdown", "Days, then a ticking timer, then live — pick one and watch it flip.", code: """
        KitoCountdownWidgetView(title: "Launch Day", target: launch, start: announced,
                                end: launch.addingTimeInterval(3_600), symbol: "sparkles", now: entry.date)

        // Entries only where the layout changes; the timer ticks on its own.
        let dates = [Date.now] + KitoCountdown.transitionDates(after: .now, target: launch, end: end)
        """) { CountdownPlayground() },
        KitSample("Countdown on the Lock Screen", "A self-updating ring, a timer and an inline line.", code: """
        KitoCountdownWidgetView(title: "Launch Day", target: launch, start: announced, now: entry.date)
        """) { CountdownPlayground(lockScreen: true) },
        KitSample("Four phases", "Upcoming, final stretch, happening now and finished.", code: """
        switch KitoCountdown.phase(at: now, target: target, end: end) {
        case .upcoming, .finalStretch, .live, .ended: …
        }
        """) { CountdownPhases() },
    ])

    private static let lists = KitSection("Lists and actions", symbol: "checklist", [
        KitSample("To-do list", "Interactive: tap a check to toggle it through an App Intent.", code: """
        try KitoWidgetStore.shared.save(tasks, forKey: "kito.sample.tasks")

        KitoListWidgetView(title: "Today", items: entry.value, storeKey: "kito.sample.tasks")
        // Each row is Toggle(isOn: task.isDone, intent: KitoToggleTaskIntent(taskID: task.id, listKey: …))
        """) { TasksSample() },
        KitSample("Agenda", "Times and a coloured bar instead of checks.", code: """
        KitoListWidgetView(title: "Agenda", items: events, style: .agenda, symbol: "calendar",
                           tint: .orange, background: .midnight)
        """) { AgendaSample() },
        KitSample("Quick actions", "A grid of intent buttons and deep links.", code: """
        KitoQuickActionsWidgetView(title: "Shortcuts", actions: [
            KitoQuickAction(title: "Water", symbol: "drop.fill", tint: .cyan,
                            action: .perform(KitoIncrementCounterIntent(counterKey: "kito.sample.water"))),
            KitoQuickAction(title: "Scan", symbol: "qrcode.viewfinder", tint: .orange,
                            action: .open(scanURL)),
        ])
        """) { QuickActionsSample() },
    ])

    private static let media = KitSection("Media and weather", symbol: "photo.on.rectangle", [
        KitSample("Quote of the day", "Serif type on a gradient, with a huge faded quote mark.", code: """
        KitoQuoteWidgetView(quote: "Simplicity is the soul of efficiency.", author: "R. Austin Freeman",
                            background: .grape)
        """) { QuoteSample() },
        KitSample("Photo", "A full-bleed photo with a gradient scrim for the caption.", code: """
        KitoPhotoWidgetView(photo: Image(uiImage: memory), title: "Diani Beach",
                            subtitle: "One year ago today", badge: "Memories")
        """) { PhotoSample() },
        KitSample("Weather", "Conditions and an hourly strip; the sky sets the gradient.", code: """
        KitoWeatherStyleWidgetView(location: "Nairobi", temperature: 27, condition: "Sunny",
                                   symbol: "sun.max.fill", high: 30, low: 19, hourly: hours, background: .ocean)
        """) { WidgetWeatherSample() },
        KitSample("Weather on the Lock Screen", "A temperature gauge, a summary and an inline line.", code: """
        KitoWeatherStyleWidgetView(location: "Nairobi", temperature: 27, condition: "Sunny",
                                   symbol: "sun.max.fill", high: 30, low: 19)
        """) { WidgetWeatherSample(lockScreen: true) },
    ])

    private static let finance = KitSection("Finance", symbol: "creditcard.fill", [
        KitSample("Balance", "Hides itself on request, on Always-On and when the phone is locked.", code: """
        KitoBalanceWidgetView(title: "Everyday", balance: 124_480.5, currencyCode: "KES", change: 2_300,
                              history: month, accountSuffix: "4821", transactions: recent, isHidden: hideBalance)
        // Also hidden automatically when isLuminanceReduced or redactionReasons contains .privacy.
        """) { BalanceSample() },
        KitSample("Balance on the Lock Screen", "Privacy-sensitive amounts, redacted while locked.", code: """
        KitoBalanceWidgetView(title: "Everyday", balance: balance, currencyCode: "KES")
            .privacySensitive()   // already applied to every amount
        """) { BalanceSample(lockScreen: true) },
    ])

    private static let look = KitSection("Look and feel", symbol: "paintpalette.fill", [
        KitSample("Background presets", "Ten gradients, applied with containerBackground.", code: """
        MyWidgetView().kitoWidgetBackground(.aurora)
        MyWidgetView().kitoWidgetBackground { Image("coast").resizable().scaledToFill() }
        """) { PresetsGrid() },
        KitSample("StandBy", "No background, on black: tints and rings carry the colour.", code: """
        KitoWidgetPreviewFrame(.systemSmall, placement: .standBy) {
            KitoProgressRingWidgetView(rings: rings)
        }
        """) { StandBySample() },
        KitSample("Light and dark", "The .system background follows the appearance.", code: """
        KitoListWidgetView(title: "Today", items: tasks, background: .system)
        """) { LightDarkSample() },
    ])

    private static let setup = KitSection("Set up", symbol: "plus.app.fill", [
        KitSample("Add to the Home Screen", "Where to find the Kito widgets, and the Lock Screen and StandBy.", code: """
        @main
        struct OrderTrackingWidgetBundle: WidgetBundle {
            var body: some Widget {
                OrderTrackingWidget()
                KitoStatsWidget()
                KitoRingsWidget()
                KitoCountdownWidget()
                KitoTasksWidget()
                KitoWaterWidget()
            }
        }
        """) { AddToHomeScreen() },
        KitSample("Share data with the widget", "Save to the App Group, reload the timeline, see it on the Home Screen.", code: """
        let store = KitoWidgetStore.shared            // App Group from the KitoWidgetsAppGroup Info.plist key
        try store.save(steps, forKey: "kito.sample.steps")
        KitoWidgetStore.reloadTimelines(ofKind: "KitoStatsWidget")
        """) { SharedDataSample() },
    ])

    static let sections: [KitSection] = [stats, goals, time, lists, media, finance, look, setup]
}

struct WidgetsGallery: View {
    static var count: Int { KitGallery.count(WidgetsSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Widgets & Intents",
            sections: WidgetsSamples.sections,
            footnote: "Requires `import KitoWidgets`. Add the Kito widgets from the Home Screen to see them live.",
            searchHint: "Try “ring”, “countdown”, “tasks”, “lock screen” or “StandBy”."
        )
    }
}
