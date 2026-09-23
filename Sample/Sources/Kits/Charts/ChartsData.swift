//
//  ChartsData.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCharts

/// Sample data for the 2D chart gallery. Fixed or seeded, never random, so every launch and
/// every App Store screenshot looks the same.
enum ChartsData {
    static func series(_ labels: [String], _ values: [Double], category: String = "default") -> [ChartDataPoint] {
        zip(labels, values).map { ChartDataPoint(label: $0, value: $1, category: category) }
    }

    static let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    static let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    static let week = series(weekdays, [120, 200, 150, 260, 190, 310, 240])
    static let months = series(monthNames, [82, 95, 110, 104, 128, 150, 162, 158, 171, 190, 214, 260])
    /// Sharp peaks, where Catmull–Rom visibly overshoots and `.smooth` doesn't.
    static let spiky = series(["1", "2", "3", "4", "5", "6", "7", "8"], [20, 20, 90, 20, 25, 85, 30, 30])
    static let flat = series(weekdays, [50, 50, 50, 50, 50, 50, 50])
    static let profitAndLoss = series(monthNames, [-40, -25, -10, 15, 5, -8, 22, 38, 30, 52, 47, 70])
    static let pricingTiers = series(["0", "10", "50", "100", "250", "500", "1k"], [0, 9, 29, 29, 79, 149, 299])

    static let hours: [ChartDataPoint] = (0..<24).map { hour in
        let h = Double(hour)
        let value = 8 + 60 * exp(-pow(h - 9, 2) / 6) + 95 * exp(-pow(h - 19, 2) / 8)
        return ChartDataPoint(label: String(format: "%02d", hour), value: value.rounded())
    }

    static let hourlyTemperature = series(
        ["6am", "7am", "8am", "9am", "10am", "11am", "12pm", "1pm", "2pm", "3pm", "4pm", "5pm"],
        [14, 15, 17, 19, 21, 23, 25, 26, 26, 25, 23, 21]
    )

    static let heartRate: [ChartDataPoint] = {
        var generator = SeededValues(seed: 42)
        return (0..<30).map { minute in
            let base = 72 + 26 * sin(Double(minute) / 30 * .pi)
            return ChartDataPoint(label: "\(minute)m", value: (base + generator.next(in: -4...4)).rounded())
        }
    }()

    /// A seeded random walk: looks like a price, is the same every launch.
    static func walk(count: Int, start: Double, volatility: Double, drift: Double = 0.2, seed: UInt64, labels: (Int) -> String = { "\($0)" }) -> [ChartDataPoint] {
        var generator = SeededValues(seed: seed)
        var value = start
        return (0..<count).map { index in
            // SeededValues rounds to whole numbers; draw in thousandths for a finer walk.
            let step = generator.next(in: -1_000...1_000) / 1_000 * volatility
            value = max(value + step + drift, 1)
            return ChartDataPoint(label: labels(index), value: (value * 100).rounded() / 100)
        }
    }

    static let dense = walk(count: 60, start: 100, volatility: 6, seed: 3)

    /// 0 awake … 3 deep, sampled every 30 minutes.
    static let sleepStages = series(
        ["11p", "", "12a", "", "1a", "", "2a", "", "3a", "", "4a", "", "5a", "", "6a", "", "7a"],
        [0, 1, 2, 3, 3, 2, 1, 2, 3, 2, 1, 1, 2, 1, 1, 0, 0]
    )

    static let battery = series(
        ["8am", "10am", "12pm", "2pm", "4pm", "6pm", "8pm", "10pm"],
        [100, 91, 80, 64, 58, 41, 30, 22]
    )

    static let visitors = series(weekdays, [820, 932, 901, 1290, 1330, 1120, 980], category: "This week")
        + series(weekdays, [620, 732, 701, 934, 1090, 1030, 820], category: "Last week")

    static let platforms = series(monthNames.prefix(6).map { $0 }, [120, 150, 170, 210, 260, 320], category: "iOS")
        + series(monthNames.prefix(6).map { $0 }, [180, 190, 195, 200, 210, 215], category: "Android")
        + series(monthNames.prefix(6).map { $0 }, [90, 85, 100, 130, 125, 160], category: "Web")

    static let budget: [ChartDataPoint] = [
        ChartDataPoint(label: "Rent", value: 900, color: .red),
        ChartDataPoint(label: "Food", value: 400, color: .orange),
        ChartDataPoint(label: "Savings", value: 500, color: .green),
        ChartDataPoint(label: "Transport", value: 220, color: .blue),
        ChartDataPoint(label: "Fun", value: 150, color: .purple),
    ]

    static let languages = series(["Swift", "Kotlin", "TypeScript", "Python", "Go", "Rust", "Dart", "Ruby"], [22, 16, 15, 13, 9, 7, 6, 5])

    static func average(_ points: [ChartDataPoint]) -> Double {
        points.isEmpty ? 0 : points.map(\.value).reduce(0, +) / Double(points.count)
    }
}

// MARK: - Hosts
// Each keeps its view model in @State so a re-render (e.g. tapping Copy) doesn't rebuild it and
// replay the reveal animation.

struct LineHost: View {
    @State private var viewModel: LineChartViewModel
    let style: LineChartStyle
    let showLegend: Bool
    let height: CGFloat
    let format: (Double) -> String

    init(_ points: [ChartDataPoint], smoothed: Bool = true, style: LineChartStyle = .default, showLegend: Bool = true, height: CGFloat = 220, format: @escaping (Double) -> String = { String(format: "%.0f", $0) }) {
        _viewModel = State(initialValue: LineChartViewModel(points: points, isSmoothed: smoothed))
        self.style = style
        self.showLegend = showLegend
        self.height = height
        self.format = format
    }

    var body: some View {
        LineChartView(viewModel: viewModel, style: style, showLegend: showLegend, valueFormatter: format)
            .frame(height: height)
    }
}

struct BarHost: View {
    @State private var viewModel: BarChartViewModel
    let cornerRadius: CGFloat
    let height: CGFloat
    let format: (Double) -> String

    init(_ points: [ChartDataPoint], cornerRadius: CGFloat = 6, height: CGFloat = 220, format: @escaping (Double) -> String = { String(format: "%.0f", $0) }) {
        _viewModel = State(initialValue: BarChartViewModel(points: points))
        self.cornerRadius = cornerRadius
        self.height = height
        self.format = format
    }

    var body: some View {
        BarChartView(viewModel: viewModel, cornerRadius: cornerRadius, valueFormatter: format).frame(height: height)
    }
}

struct PieHost: View {
    @State private var viewModel: PieChartViewModel
    let showLegend: Bool
    let height: CGFloat

    init(_ points: [ChartDataPoint], innerRadius: Double = 0, showLegend: Bool = true, height: CGFloat = 260) {
        _viewModel = State(initialValue: PieChartViewModel(points: points, innerRadiusFraction: innerRadius))
        self.showLegend = showLegend
        self.height = height
    }

    var body: some View {
        PieChartView(viewModel: viewModel, showLegend: showLegend).frame(height: height)
    }
}

extension Double {
    var usd: String { formatted(.currency(code: "USD").precision(.fractionLength(0))) }
}
