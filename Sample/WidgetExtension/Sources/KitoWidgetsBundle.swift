//
//  KitoWidgetsBundle.swift
//  OrderTrackingWidgetExtension
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//
//  Home Screen, Lock Screen and StandBy widgets built from KitoWidgets. They join the existing
//  OrderTrackingWidgetBundle — see INTEGRATION.md for the five lines to add to its body. Every
//  view comes from KitoWidgets; this file only supplies timelines and registers the widgets.

import WidgetKit
import SwiftUI
import AppIntents
import KitoWidgets

/// Store keys shared with the in-app gallery (WidgetsSamples.swift).
private enum SampleKeys {
    static let steps = "kito.sample.steps"
    static let tasks = "kito.sample.tasks"
    static let water = "kito.sample.water"
}

/// Fallback data, outside the widgets so the (nonisolated) timeline closures can read it.
private enum SampleData {
    static let week: [Double] = [6_200, 7_400, 5_100, 8_900, 7_600, 9_800]

    static let tasks: [KitoWidgetTask] = [
        KitoWidgetTask(id: "milk", title: "Buy oat milk", detail: "Groceries"),
        KitoWidgetTask(id: "bank", title: "Call the bank", detail: "Before 5 pm"),
        KitoWidgetTask(id: "flights", title: "Book flights", detail: "Mombasa trip"),
        KitoWidgetTask(id: "plants", title: "Water the plants"),
    ]

    /// Rings filling up through the day, so the timeline has something to show.
    static func rings(at date: Date) -> [KitoRing] {
        let dayFraction = date.timeIntervalSince(Calendar.current.startOfDay(for: date)) / 86_400
        return [
            KitoRing(title: "Move", value: 700 * dayFraction, goal: 600, unit: "kcal", color: Color(red: 1, green: 0.22, blue: 0.42), symbol: "flame.fill"),
            KitoRing(title: "Exercise", value: 40 * dayFraction, goal: 30, unit: "min", color: Color(red: 0.62, green: 1, blue: 0.2), symbol: "figure.run"),
            KitoRing(title: "Stand", value: (14 * dayFraction).rounded(.down), goal: 12, unit: "hr", color: Color(red: 0.2, green: 0.9, blue: 1), symbol: "figure.stand"),
        ]
    }
}

/// Lets the system find KitoWidgets' intents (toggle task, log water) in this extension.
struct KitoWidgetsExtensionIntents: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] { [KitoWidgetsIntents.self] }
}

// MARK: - Stats

struct KitoStatsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KitoStatsWidget", provider: KitoIntervalTimelineProvider(
            placeholder: KitoWidgetEntry(date: .now, value: 8_432.0), interval: 15 * 60, count: 4
        ) { date in
            KitoWidgetEntry(date: date, value: KitoWidgetStore.shared.load(Double.self, forKey: SampleKeys.steps, default: 8_432))
        }) { entry in
            KitoStatWidgetView(title: "Steps", value: entry.value, previous: 7_510, history: SampleData.week + [entry.value],
                               symbol: "figure.walk", tint: .mint, caption: "vs. yesterday")
                .widgetURL(URL(string: "kitosample://widgets/steps"))
        }
        .configurationDisplayName("Steps")
        .description("Today's steps, the change since yesterday and your week.")
        .supportedFamilies(KitoStatWidgetView.supportedFamilies)
    }
}

// MARK: - Rings

struct KitoRingsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KitoRingsWidget", provider: KitoIntervalTimelineProvider(
            placeholder: KitoWidgetEntry(date: .now, value: SampleData.rings(at: .now)), interval: 30 * 60, count: 8, aligned: true
        ) { date in
            KitoWidgetEntry(date: date, value: SampleData.rings(at: date))
        }) { entry in
            KitoProgressRingWidgetView(rings: entry.value, caption: "Close your rings by 9 pm")
        }
        .configurationDisplayName("Activity Rings")
        .description("Move, exercise and stand, closing through the day.")
        .supportedFamilies(KitoProgressRingWidgetView.supportedFamilies)
    }
}

// MARK: - Countdown

/// One entry now and one at each phase change; the timer text ticks by itself in between.
struct KitoCountdownProvider: TimelineProvider {
    struct Event {
        let target: Date
        let start: Date
        let end: Date
    }

    /// Next Friday at 6 pm, for an hour.
    static func nextEvent(after date: Date) -> Event {
        let calendar = Calendar.current
        let target = calendar.nextDate(after: date.addingTimeInterval(-3_600), matching: DateComponents(hour: 18, minute: 0, weekday: 6),
                                       matchingPolicy: .nextTime) ?? date.addingTimeInterval(3 * 86_400)
        return Event(target: target, start: target.addingTimeInterval(-7 * 86_400), end: target.addingTimeInterval(3_600))
    }

    func placeholder(in context: Context) -> KitoWidgetEntry<Event> {
        KitoWidgetEntry(date: .now, value: Self.nextEvent(after: .now))
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (KitoWidgetEntry<Event>) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<KitoWidgetEntry<Event>>) -> Void) {
        let now = Date()
        let event = Self.nextEvent(after: now)
        let dates = [now] + KitoCountdown.transitionDates(after: now, target: event.target, end: event.end)
            + [Calendar.current.startOfDay(for: now.addingTimeInterval(86_400))]   // the day count changes at midnight
        let entries = Array(Set(dates)).sorted().map { KitoWidgetEntry(date: $0, value: event) }
        completion(Timeline(entries: entries, policy: .after(event.end)))
    }
}

struct KitoCountdownWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KitoCountdownWidget", provider: KitoCountdownProvider()) { entry in
            KitoCountdownWidgetView(title: "Friday Launch", target: entry.value.target, start: entry.value.start,
                                    end: entry.value.end, symbol: "sparkles", now: entry.date)
        }
        .configurationDisplayName("Countdown")
        .description("Days to go, then a live timer that ticks without refreshing.")
        .supportedFamilies(KitoCountdownWidgetView.supportedFamilies)
    }
}

// MARK: - Tasks (interactive)

struct KitoTasksWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KitoTasksWidget", provider: KitoIntervalTimelineProvider(
            placeholder: KitoWidgetEntry(date: .now, value: SampleData.tasks), interval: 60 * 60, count: 1
        ) { date in
            KitoWidgetEntry(date: date, value: KitoWidgetStore.shared.load([KitoWidgetTask].self, forKey: SampleKeys.tasks) ?? SampleData.tasks)
        }) { entry in
            // Each check is Toggle(isOn:intent:) running KitoToggleTaskIntent on this list.
            KitoListWidgetView(title: "Today", items: entry.value, storeKey: SampleKeys.tasks)
        }
        .configurationDisplayName("Tasks")
        .description("Tick tasks off right on your Home Screen.")
        .supportedFamilies(KitoListWidgetView.supportedFamilies)
    }
}

// MARK: - Water (interactive)

struct KitoWaterWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KitoWaterWidget", provider: KitoIntervalTimelineProvider(
            placeholder: KitoWidgetEntry(date: .now, value: KitoWidgetCounter(count: 5)), interval: 60 * 60, count: 1
        ) { date in
            KitoWidgetEntry(date: date, value: KitoWidgetStore.shared.load(KitoWidgetCounter.self, forKey: SampleKeys.water,
                                                                           default: KitoWidgetCounter()))
        }) { entry in
            // The + and − buttons run KitoIncrementCounterIntent; it resets itself each day.
            KitoCounterWidgetView(title: "Water", counter: entry.value, counterKey: SampleKeys.water, now: entry.date)
        }
        .configurationDisplayName("Water")
        .description("Log a glass of water with one tap.")
        .supportedFamilies(KitoCounterWidgetView.supportedFamilies)
    }
}
