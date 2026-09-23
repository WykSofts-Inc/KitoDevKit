//
//  Chart3DSampleCatalog.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCharts

// MARK: - Sample data
// Fixed values, not random, so every launch (and every App Store screenshot) looks the same.

enum Chart3DData {
    static let week: [ChartDataPoint] = zip(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], [120.0, 200, 150, 260, 190, 310, 240])
        .map { ChartDataPoint(label: $0, value: $1) }

    static let months: [ChartDataPoint] = zip(
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        [82.0, 95, 110, 104, 128, 150, 162, 158, 171, 190, 214, 260]
    ).map { ChartDataPoint(label: $0, value: $1) }

    /// A day of traffic: quiet overnight, a morning peak and a bigger evening one.
    static let hours: [ChartDataPoint] = (0..<24).map { hour in
        let h = Double(hour)
        let morning = 60 * exp(-pow(h - 9, 2) / 6)
        let evening = 95 * exp(-pow(h - 19, 2) / 8)
        return ChartDataPoint(label: String(format: "%02d", hour), value: 8 + morning + evening)
    }

    static let quarters: [ChartDataPoint] = zip(["Q1", "Q2", "Q3", "Q4"], [410.0, 520, 480, 690])
        .map { ChartDataPoint(label: $0, value: $1) }

    static let leaderboard: [ChartDataPoint] = zip(["Wycliff", "Brian", "Chen", "Dalia", "Eli", "Fatma"], [980.0, 860, 790, 640, 520, 410])
        .map { ChartDataPoint(label: $0, value: $1) }

    static let budget: [ChartDataPoint] = [
        ChartDataPoint(label: "Rent", value: 900, color: .red),
        ChartDataPoint(label: "Food", value: 400, color: .orange),
        ChartDataPoint(label: "Savings", value: 500, color: .green),
        ChartDataPoint(label: "Transport", value: 220, color: .blue),
        ChartDataPoint(label: "Fun", value: 150, color: .purple),
    ]

    static let marketShare: [ChartDataPoint] = [
        ChartDataPoint(label: "Kito", value: 38),
        ChartDataPoint(label: "Acme", value: 24),
        ChartDataPoint(label: "Globex", value: 17),
        ChartDataPoint(label: "Initech", value: 11),
        ChartDataPoint(label: "Others", value: 10, color: .gray),
    ]

    static let storage: [ChartDataPoint] = [
        ChartDataPoint(label: "Photos", value: 48, color: .yellow),
        ChartDataPoint(label: "Apps", value: 31, color: .blue),
        ChartDataPoint(label: "Messages", value: 12, color: .green),
        ChartDataPoint(label: "System", value: 14, color: .gray),
        ChartDataPoint(label: "Free", value: 23, color: Color(white: 0.85)),
    ]

    static let survey: [ChartDataPoint] = [
        ChartDataPoint(label: "Love it", value: 46, color: .green),
        ChartDataPoint(label: "Like it", value: 31, color: .mint),
        ChartDataPoint(label: "Neutral", value: 14, color: .gray),
        ChartDataPoint(label: "Dislike", value: 9, color: .red),
    ]

    static let languages: [ChartDataPoint] = zip(
        ["Swift", "Kotlin", "TypeScript", "Python", "Go", "Rust", "Dart", "Ruby", "C#", "Java"],
        [22.0, 16, 15, 13, 9, 7, 6, 5, 4, 3]
    ).map { ChartDataPoint(label: $0, value: $1) }

    static let stepsGoal = 8_000.0
    static let steps: [ChartDataPoint] = zip(["M", "T", "W", "T", "F", "S", "S"], [9_200.0, 6_400, 8_800, 10_400, 7_100, 12_600, 5_300])
        .map { ChartDataPoint(label: $0, value: $1, color: $1 >= stepsGoal ? .green : .orange) }

    static func progress(_ done: Double, remainderColor: Color = Color(white: 0.82), color: Color = .blue) -> [ChartDataPoint] {
        [ChartDataPoint(label: "Done", value: done, color: color),
         ChartDataPoint(label: "Left", value: 100 - done, color: remainderColor)]
    }
}

// MARK: - Palettes

enum Chart3DPalettes {
    /// Greys rather than pure black, so bars still read against the dark-mode floor.
    static let brand = KitoChartTheme(categoricalPalette: [Color(white: 0.3), Color(white: 0.5), Color(white: 0.7), Color(white: 0.9)])
    static let pastel = KitoChartTheme(categoricalPalette: [
        Color(red: 0.98, green: 0.71, blue: 0.73), Color(red: 0.99, green: 0.84, blue: 0.65), Color(red: 0.99, green: 0.96, blue: 0.69),
        Color(red: 0.73, green: 0.91, blue: 0.75), Color(red: 0.69, green: 0.84, blue: 0.97), Color(red: 0.82, green: 0.75, blue: 0.96),
    ])
    static let neon = KitoChartTheme(categoricalPalette: [
        Color(red: 0.0, green: 1.0, blue: 0.8), Color(red: 1.0, green: 0.0, blue: 0.6), Color(red: 0.6, green: 0.3, blue: 1.0),
        Color(red: 1.0, green: 0.9, blue: 0.0), Color(red: 0.0, green: 0.6, blue: 1.0),
    ])
    static let sunset = KitoChartTheme(categoricalPalette: [.red, .orange, .yellow, .pink, .purple])
    /// One hue from dark to light: for ordered data, where colour should read as "more".
    static let blues = KitoChartTheme(categoricalPalette: (0..<12).map { Color(hue: 0.6, saturation: 0.85, brightness: 0.35 + Double($0) * 0.055) })
    static let greens = KitoChartTheme(categoricalPalette: (0..<6).map { Color(hue: 0.38, saturation: 0.75 - Double($0) * 0.1, brightness: 0.55 + Double($0) * 0.07) })

    static let named: [(name: String, theme: KitoChartTheme)] = [
        ("Default", .default), ("Pastel", pastel), ("Neon", neon), ("Sunset", sunset), ("Mono", brand),
    ]
}

// MARK: - Code snippets

private func barsCode(_ data: String, theme: String? = nil) -> String {
    let themeArg = theme.map { ", theme: \($0)" } ?? ""
    return """
    \(data)

    @State private var chart = Chart3DViewModel(points: points\(themeArg))

    Chart3DView(viewModel: chart)
        .frame(height: 300)   // drag to rotate, pinch to zoom
    """
}

private func pieCode(_ data: String, innerRadius: Double? = nil, depth: Double? = nil, theme: String? = nil) -> String {
    var args = ["points: points"]
    if let innerRadius { args.append("innerRadiusFraction: \(innerRadius)") }
    if let depth { args.append("extrusionDepth: \(depth)") }
    if let theme { args.append("theme: \(theme)") }
    let call = args.count > 2
        ? "Chart3DPieViewModel(\n    " + args.joined(separator: ",\n    ") + "\n)"
        : "Chart3DPieViewModel(" + args.joined(separator: ", ") + ")"
    return """
    \(data)

    @State private var chart = \(call)

    Chart3DPieView(viewModel: chart)
        .frame(height: 300)
    """
}

private let weekData = """
let points = zip(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                 [120.0, 200, 150, 260, 190, 310, 240])
    .map { ChartDataPoint(label: $0, value: $1) }
"""

private let budgetData = """
let points = [
    ChartDataPoint(label: "Rent", value: 900, color: .red),
    ChartDataPoint(label: "Food", value: 400, color: .orange),
    ChartDataPoint(label: "Savings", value: 500, color: .green),
    ChartDataPoint(label: "Transport", value: 220, color: .blue),
    ChartDataPoint(label: "Fun", value: 150, color: .purple),
]
"""

private let progressData = """
let points = [
    ChartDataPoint(label: "Done", value: 72, color: .blue),
    ChartDataPoint(label: "Left", value: 28, color: Color(white: 0.82)),
]
"""

// MARK: - Catalog

enum Chart3DSampleCatalog {
    static let all: [Chart3DSample] = bars + pies + donuts + interactive + styling + dashboards

    static let bars: [Chart3DSample] = [
        Chart3DSample("Weekly revenue", "Seven bars, theme palette, orbit with one finger.", category: .bars, code: barsCode(weekData)) {
            VStack(spacing: 10) {
                Bars3D(Chart3DData.week)
                Chart3DHint("Drag to orbit · pinch to zoom · two fingers to pan")
            }
        },
        Chart3DSample("12-month trend", "A year of growth; the camera pulls back to fit.", category: .bars, code: barsCode("let points = months   // Jan … Dec")) {
            Bars3D(Chart3DData.months)
        },
        Chart3DSample("24-hour traffic", "Dense data: 24 bars with morning and evening peaks.", category: .bars, code: barsCode("let points = (0..<24).map { hour in\n    ChartDataPoint(label: String(format: \"%02d\", hour), value: visits[hour])\n}")) {
            Bars3D(Chart3DData.hours, theme: Chart3DPalettes.blues)
        },
        Chart3DSample("Quarterly results", "Four wide bars for a short series.", category: .bars, code: barsCode("let points = zip([\"Q1\", \"Q2\", \"Q3\", \"Q4\"], [410.0, 520, 480, 690])\n    .map { ChartDataPoint(label: $0, value: $1) }")) {
            Bars3D(Chart3DData.quarters)
        },
        Chart3DSample("Leaderboard", "Sorted high to low, so the podium reads left to right.", category: .bars, code: barsCode("let points = scores\n    .sorted { $0.value > $1.value }")) {
            VStack(spacing: 12) {
                Bars3D(Chart3DData.leaderboard, theme: Chart3DPalettes.greens)
                Chart3DLegend(points: Chart3DData.leaderboard, theme: Chart3DPalettes.greens)
            }
        },
        Chart3DSample("Target vs actual", "Two bars with explicit colours.", category: .bars, code: barsCode("let points = [\n    ChartDataPoint(label: \"Target\", value: 1_000, color: .gray),\n    ChartDataPoint(label: \"Actual\", value: 1_240, color: .green),\n]")) {
            VStack(spacing: 12) {
                let points = [ChartDataPoint(label: "Target", value: 1_000, color: .gray), ChartDataPoint(label: "Actual", value: 1_240, color: .green)]
                Bars3D(points)
                Chart3DLegend(points: points)
            }
        },
        Chart3DSample("Zero still shows", "A zero value keeps a thin sliver, so the slot never looks missing.", category: .bars, code: barsCode("let points = [\n    ChartDataPoint(label: \"Jan\", value: 40),\n    ChartDataPoint(label: \"Feb\", value: 0),   // drawn as a sliver\n    ChartDataPoint(label: \"Mar\", value: 65),\n]")) {
            Bars3D(zip(["Jan", "Feb", "Mar", "Apr"], [40.0, 0, 65, 30]).map { ChartDataPoint(label: $0, value: $1) })
        },
    ]

    static let pies: [Chart3DSample] = [
        Chart3DSample("Monthly budget", "Extruded wedges with per-slice colours.", category: .pies, code: pieCode(budgetData)) {
            VStack(spacing: 12) {
                Pie3D(Chart3DData.budget)
                Chart3DLegend(points: Chart3DData.budget, format: { $0.formatted(.currency(code: "USD").precision(.fractionLength(0))) })
            }
        },
        Chart3DSample("Market share", "Theme palette, with “Others” pinned to grey.", category: .pies, code: pieCode("let points = [\n    ChartDataPoint(label: \"Kito\", value: 38),\n    ChartDataPoint(label: \"Acme\", value: 24),\n    // …\n    ChartDataPoint(label: \"Others\", value: 10, color: .gray),\n]")) {
            VStack(spacing: 12) {
                Pie3D(Chart3DData.marketShare)
                Chart3DLegend(points: Chart3DData.marketShare, showsPercent: true)
            }
        },
        Chart3DSample("Thin coin", "A shallow extrusion reads like a flat token.", category: .pies, code: pieCode(budgetData, depth: 0.15)) {
            Pie3D(Chart3DData.budget, depth: 0.15)
        },
        Chart3DSample("Tall cake", "A deep extrusion shows off the wedge sides.", category: .pies, code: pieCode(budgetData, depth: 1.4)) {
            Pie3D(Chart3DData.budget, depth: 1.4)
        },
        Chart3DSample("Ten slices", "Dense data wraps the palette instead of running out.", category: .pies, code: pieCode("let points = languages   // 10 entries, 6-colour palette")) {
            VStack(spacing: 12) {
                Pie3D(Chart3DData.languages)
                Chart3DLegend(points: Chart3DData.languages, showsPercent: true)
            }
        },
        Chart3DSample("One dominant slice", "90 / 10: the small wedge stays visible.", category: .pies, code: pieCode("let points = [\n    ChartDataPoint(label: \"Paid\", value: 90, color: .green),\n    ChartDataPoint(label: \"Overdue\", value: 10, color: .red),\n]")) {
            Pie3D([ChartDataPoint(label: "Paid", value: 90, color: .green), ChartDataPoint(label: "Overdue", value: 10, color: .red)])
        },
        Chart3DSample("Survey results", "Four answers with a percentage legend.", category: .pies, code: pieCode("let points = [\n    ChartDataPoint(label: \"Love it\", value: 46, color: .green),\n    ChartDataPoint(label: \"Like it\", value: 31, color: .mint),\n    ChartDataPoint(label: \"Neutral\", value: 14, color: .gray),\n    ChartDataPoint(label: \"Dislike\", value: 9, color: .red),\n]")) {
            VStack(spacing: 12) {
                Pie3D(Chart3DData.survey)
                Chart3DLegend(points: Chart3DData.survey, showsPercent: true)
            }
        },
    ]

    static let donuts: [Chart3DSample] = [
        Chart3DSample("Classic donut", "innerRadiusFraction 0.55.", category: .donuts, code: pieCode(budgetData, innerRadius: 0.55)) {
            Pie3D(Chart3DData.budget, innerRadius: 0.55)
        },
        Chart3DSample("Thin ring", "innerRadiusFraction 0.85, a delicate band.", category: .donuts, code: pieCode(budgetData, innerRadius: 0.85)) {
            Pie3D(Chart3DData.budget, innerRadius: 0.85)
        },
        Chart3DSample("Chunky donut", "A small hole, innerRadiusFraction 0.3.", category: .donuts, code: pieCode(budgetData, innerRadius: 0.3)) {
            Pie3D(Chart3DData.budget, innerRadius: 0.3)
        },
        Chart3DSample("Progress ring", "Two slices, the remainder in grey: 72% complete.", category: .donuts, code: pieCode(progressData, innerRadius: 0.75)) {
            VStack(spacing: 8) {
                Pie3D(Chart3DData.progress(72), innerRadius: 0.75)
                Text("72% complete").font(.headline.monospacedDigit())
            }
        },
        Chart3DSample("Deep donut", "A wide ring with a tall extrusion.", category: .donuts, code: pieCode(budgetData, innerRadius: 0.6, depth: 1.2)) {
            Pie3D(Chart3DData.budget, innerRadius: 0.6, depth: 1.2)
        },
    ]

    static let interactive: [Chart3DSample] = [
        Chart3DSample("Extrusion slider", "Drag to change the wedge thickness live.", category: .interactive, code: """
        @State private var chart = Chart3DPieViewModel(points: points)
        @State private var depth = 0.6

        Chart3DPieView(viewModel: chart)
        Slider(value: $depth, in: 0.1...1.6)
            .onChange(of: depth) { _, newValue in
                chart.extrusionDepth = newValue
                chart.rebuild()   // SceneKit scenes aren't observable
            }
        """) { DepthSliderSample() },
        Chart3DSample("Pie to donut morph", "Drag to open the hole from a pie to a ring.", category: .interactive, code: """
        @State private var chart = Chart3DPieViewModel(points: points)
        @State private var hole = 0.0

        Chart3DPieView(viewModel: chart)
        Slider(value: $hole, in: 0...0.9)
            .onChange(of: hole) { _, newValue in
                chart.innerRadiusFraction = newValue
                chart.rebuild()
            }
        """) { InnerRadiusSliderSample() },
        Chart3DSample("Edit the values", "One slider per slice; the pie re-proportions as you drag.", category: .interactive, code: """
        @State private var chart = Chart3DPieViewModel(points: points)

        ForEach(chart.points.indices, id: \\.self) { i in
            Slider(value: Binding(
                get: { chart.points[i].value },
                set: { chart.points[i].value = $0; chart.rebuild() }
            ), in: 1...100)
        }
        """) { ValueEditorSample() },
        Chart3DSample("Shuffle data", "Tap to load new values into the same bars.", category: .interactive, code: """
        Button("Shuffle") {
            chart.points = chart.points.map {
                ChartDataPoint(label: $0.label, value: .random(in: 40...320))
            }
            chart.rebuild()
        }
        """) { ShuffleBarsSample() },
        Chart3DSample("Add and remove bars", "A stepper grows the series; the camera refits.", category: .interactive, code: """
        Stepper("Bars: \\(count)", value: $count, in: 1...16)
            .onChange(of: count) { _, n in
                chart.points = Array(allPoints.prefix(n))
                chart.rebuild()
            }
        """) { BarCountSample() },
        Chart3DSample("Week, month, quarter", "A segmented control swaps the whole dataset.", category: .interactive, code: """
        Picker("Range", selection: $range) { … }
            .pickerStyle(.segmented)
            .onChange(of: range) { _, r in
                chart.points = r.points
                chart.rebuild()
            }
        """) { RangeSwitcherSample() },
        Chart3DSample("Toggle slices", "Tap a category to hide or show it; the rest fill the gap.", category: .interactive, code: """
        chart.points = allPoints.filter { !hidden.contains($0.label) }
        chart.rebuild()
        """) { SliceToggleSample() },
        Chart3DSample("Pie or donut", "Flip between a solid pie and a ring.", category: .interactive, code: """
        Toggle("Donut", isOn: $isDonut)
            .onChange(of: isDonut) { _, donut in
                chart.innerRadiusFraction = donut ? 0.6 : 0
                chart.rebuild()
            }
        """) { PieDonutToggleSample() },
    ]

    static let styling: [Chart3DSample] = [
        Chart3DSample("Palette switcher", "Swap the theme on a live chart.", category: .styling, code: """
        // 3D charts take their theme at init, not from .kitoChartTheme(_:)
        chart.theme = KitoChartTheme(categoricalPalette: [.pink, .mint, .indigo])
        chart.rebuild()
        """) { PaletteSwitcherSample() },
        Chart3DSample("Monochrome brand", "Greys only, to match a monochrome design.", category: .styling, code: barsCode(weekData, theme: "KitoChartTheme(categoricalPalette: [\n    Color(white: 0.3), Color(white: 0.5), Color(white: 0.7), Color(white: 0.9)\n])")) {
            Bars3D(Chart3DData.week, theme: Chart3DPalettes.brand)
        },
        Chart3DSample("Single-hue ramp", "Dark to light blue: colour reinforces order.", category: .styling, code: barsCode("let points = months", theme: "KitoChartTheme(categoricalPalette: (0..<12).map {\n    Color(hue: 0.6, saturation: 0.85, brightness: 0.35 + Double($0) * 0.055)\n})")) {
            Bars3D(Chart3DData.months, theme: Chart3DPalettes.blues)
        },
        Chart3DSample("Highlight one bar", "Everything grey except the point that matters.", category: .styling, code: barsCode("let points = week.map {\n    ChartDataPoint(label: $0.label, value: $0.value,\n                   color: $0.label == \"Sat\" ? .orange : Color(white: 0.75))\n}")) {
            Bars3D(Chart3DData.week.map { ChartDataPoint(label: $0.label, value: $0.value, color: $0.label == "Sat" ? .orange : Color(white: 0.75)) })
        },
        Chart3DSample("Pastel pie", "Soft colours for friendly, consumer screens.", category: .styling, code: pieCode("let points = languages.prefix(6)", theme: "pastel")) {
            Pie3D(Array(Chart3DData.languages.prefix(6)), theme: Chart3DPalettes.pastel)
        },
        Chart3DSample("Neon donut", "High-saturation colours; great on dark backgrounds.", category: .styling, code: pieCode("let points = marketShare", innerRadius: 0.55, theme: "neon")) {
            Pie3D(Array(Chart3DData.marketShare.prefix(4)), innerRadius: 0.55, theme: Chart3DPalettes.neon)
        },
        Chart3DSample("Sunset bars", "A warm palette on quarterly data.", category: .styling, code: barsCode("let points = quarters", theme: "KitoChartTheme(categoricalPalette: [.red, .orange, .yellow, .pink])")) {
            Bars3D(Chart3DData.quarters, theme: Chart3DPalettes.sunset)
        },
    ]

    static let dashboards: [Chart3DSample] = [
        Chart3DSample("Revenue card", "Headline figure, trend badge and a 3D bar chart.", category: .dashboards, code: """
        VStack(alignment: .leading) {
            Text("This week").font(.subheadline).foregroundStyle(.secondary)
            Text("$1,470").font(.largeTitle.bold())
            Chart3DView(viewModel: chart).frame(height: 260)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(.background))
        """) { RevenueCardSample() },
        Chart3DSample("Storage card", "Device storage as a donut with a legend.", category: .dashboards, code: """
        Chart3DPieView(viewModel: Chart3DPieViewModel(
            points: storage, innerRadiusFraction: 0.6, extrusionDepth: 0.4
        ))
        .frame(height: 260)
        """) { StorageCardSample() },
        Chart3DSample("Fitness goal", "Days over 8,000 steps in green, under in orange.", category: .dashboards, code: """
        let points = steps.map {
            ChartDataPoint(label: $0.day, value: $0.count,
                           color: $0.count >= 8_000 ? .green : .orange)
        }
        """) { StepsCardSample() },
        Chart3DSample("Budget card", "Spend total above a 3D pie of categories.", category: .dashboards, code: pieCode(budgetData, depth: 0.5)) { BudgetCardSample() },
        Chart3DSample("Project progress", "One progress ring; pick a workstream to update it.", category: .dashboards, code: """
        Picker("Workstream", selection: $selection) { … }
            .pickerStyle(.segmented)
            .onChange(of: selection) { _, i in
                chart.points = [
                    ChartDataPoint(label: "Done", value: tasks[i].done, color: tasks[i].color),
                    ChartDataPoint(label: "Left", value: 100 - tasks[i].done, color: .gray),
                ]
                chart.rebuild()
            }

        Chart3DPieView(viewModel: chart)   // innerRadiusFraction: 0.7
            .frame(height: 260)
        """) { ProgressRingsSample() },
    ]
}
