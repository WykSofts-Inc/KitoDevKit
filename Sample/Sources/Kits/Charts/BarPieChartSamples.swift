//
//  BarPieChartSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCharts

private func barCode(_ args: String = "", data: String = "let points: [ChartDataPoint] = …") -> String {
    """
    \(data)
    @State private var chart = BarChartViewModel(points: points)

    BarChartView(viewModel: chart\(args))
        .frame(height: 220)
    """
}

private func pieCode(_ innerRadius: Double? = nil, args: String = "") -> String {
    let radius = innerRadius.map { ", innerRadiusFraction: \($0)" } ?? ""
    return """
    @State private var chart = PieChartViewModel(points: points\(radius))

    PieChartView(viewModel: chart\(args))
        .frame(height: 260)
    """
}

enum BarPieChartSamples {
    static let sections: [KitSection] = [bars, pies, theming]

    static let bars = KitSection("Bar charts", symbol: "chart.bar.fill", [
        KitSample("Weekly bars", "Default corner radius, theme palette.", code: barCode()) {
            BarHost(ChartsData.week)
        },
        KitSample("Sharp corners", "cornerRadius: 0.", code: barCode(", cornerRadius: 0")) {
            BarHost(ChartsData.week, cornerRadius: 0)
        },
        KitSample("Pill bars", "Fully rounded, cornerRadius: 14.", code: barCode(", cornerRadius: 14")) {
            BarHost(ChartsData.week, cornerRadius: 14)
        },
        KitSample("Per-bar colours", "ChartDataPoint.color overrides the palette.", code: barCode(data: "let points = [\n    ChartDataPoint(label: \"Rent\", value: 900, color: .red),\n    // …\n]")) {
            BarHost(ChartsData.budget, format: { $0.usd })
        },
        KitSample("Highlight one bar", "Everything grey except the one that matters.", code: barCode(data: "let points = week.map {\n    ChartDataPoint(label: $0.label, value: $0.value,\n                   color: $0.label == \"Sat\" ? .orange : .gray.opacity(0.4))\n}")) {
            BarHost(ChartsData.week.map { ChartDataPoint(label: $0.label, value: $0.value, color: $0.label == "Sat" ? .orange : .gray.opacity(0.4)) })
        },
        KitSample("Grouped bars", "Two categories side by side per label.", code: barCode(data: "let points = thisWeek + lastWeek   // category: \"This week\" / \"Last week\"")) {
            BarHost(ChartsData.visitors)
        },
        KitSample("Percent axis", "A custom value formatter.", code: barCode(", valueFormatter: { ($0 / 300).formatted(.percent) }")) {
            BarHost(ChartsData.week, format: { ($0 / 300).formatted(.percent.precision(.fractionLength(0))) })
        },
        KitSample("Tap to highlight", "Tap a bar; the others dim.", code: barCode()) {
            VStack(spacing: 10) {
                BarHost(ChartsData.budget, cornerRadius: 10, format: { $0.usd })
                Label("Tap any bar", systemImage: "hand.tap").font(.caption).foregroundStyle(.secondary)
            }
        },
        KitSample("Twelve months", "A full year of bars.", code: barCode()) {
            BarHost(ChartsData.months, cornerRadius: 4)
        },
        KitSample("Brand palette", "Single-colour bars from the theme.", code: barCode() + "\n.kitoChartTheme(KitoChartTheme(categoricalPalette: [.indigo]))") {
            BarHost(ChartsData.week, cornerRadius: 10).kitoChartTheme(KitoChartTheme(categoricalPalette: [.indigo]))
        },
    ])

    static let pies = KitSection("Pie & donut", symbol: "chart.pie.fill", [
        KitSample("Pie", "Solid slices with a legend.", code: pieCode(0)) {
            PieHost(ChartsData.budget)
        },
        KitSample("Donut", "innerRadiusFraction: 0.6.", code: pieCode(0.6)) {
            PieHost(ChartsData.budget, innerRadius: 0.6)
        },
        KitSample("Thin ring", "innerRadiusFraction: 0.85.", code: pieCode(0.85)) {
            PieHost(ChartsData.budget, innerRadius: 0.85)
        },
        KitSample("Tap a slice", "The label and share appear in the centre.", code: pieCode(0.65)) {
            VStack(spacing: 10) {
                PieHost(ChartsData.budget, innerRadius: 0.65)
                Label("Tap any slice", systemImage: "hand.tap").font(.caption).foregroundStyle(.secondary)
            }
        },
        KitSample("Many slices", "Eight categories wrap the palette.", code: pieCode(0.5)) {
            PieHost(ChartsData.languages, innerRadius: 0.5)
        },
        KitSample("No legend", "showLegend: false.", code: pieCode(0.6, args: ", showLegend: false")) {
            PieHost(ChartsData.budget, innerRadius: 0.6, showLegend: false, height: 220)
        },
        KitSample("Pastel palette", "Soft colours from the theme.", code: pieCode(0.55) + "\n.kitoChartTheme(KitoChartTheme(categoricalPalette: pastel))") {
            PieHost(ChartsData.languages, innerRadius: 0.55).kitoChartTheme(KitoChartTheme(categoricalPalette: [
                Color(red: 0.98, green: 0.71, blue: 0.73), Color(red: 0.99, green: 0.84, blue: 0.65), Color(red: 0.99, green: 0.96, blue: 0.69),
                Color(red: 0.73, green: 0.91, blue: 0.75), Color(red: 0.69, green: 0.84, blue: 0.97), Color(red: 0.82, green: 0.75, blue: 0.96),
            ]))
        },
    ])

    static let theming = KitSection("Theming", symbol: "paintpalette", [
        KitSample("One theme, every chart", "A single .kitoChartTheme retints line, bar and pie.", code: """
        VStack {
            LineChartView(viewModel: line)
            BarChartView(viewModel: bars)
            PieChartView(viewModel: pie)
        }
        .kitoChartTheme(KitoChartTheme(categoricalPalette: [.teal, .orange, .pink, .indigo]))
        """) {
            VStack(spacing: 18) {
                LineHost(ChartsData.visitors, style: LineChartStyle(points: .filled), height: 160)
                BarHost(ChartsData.visitors, height: 160)
                PieHost(Array(ChartsData.languages.prefix(4)), innerRadius: 0.6, height: 200)
            }
            .kitoChartTheme(KitoChartTheme(categoricalPalette: [.teal, .orange, .pink, .indigo]))
        },
        KitSample("Dark card", "Light labels and gridlines for a dark surface.", code: """
        .kitoChartTheme(KitoChartTheme(
            categoricalPalette: [.mint, .yellow],
            gridlineColor: .white.opacity(0.1),
            axisLabelColor: .white.opacity(0.6)
        ))
        """) {
            LineHost(ChartsData.visitors, style: LineChartStyle(interpolation: .catmullRom, points: .halo, showsLabels: true))
                .kitoChartTheme(KitoChartTheme(categoricalPalette: [.mint, .yellow], gridlineColor: .white.opacity(0.1), axisColor: .white.opacity(0.3), axisLabelColor: .white.opacity(0.6)))
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color(white: 0.08)))
                .environment(\.colorScheme, .dark)
        },
        KitSample("Everything combined", "Palette, no gridlines, custom label colour.", code: """
        .kitoChartTheme(KitoChartTheme(
            categoricalPalette: [.indigo, .cyan, .mint, .yellow, .pink],
            axisLabelColor: .indigo,
            showGridlines: false
        ))
        """) {
            VStack(spacing: 18) {
                LineHost(ChartsData.platforms, style: LineChartStyle(interpolation: .catmullRom, points: .hollow), height: 180)
                PieHost(ChartsData.week, innerRadius: 0.55, height: 220)
            }
            .kitoChartTheme(KitoChartTheme(categoricalPalette: [.indigo, .cyan, .mint, .yellow, .pink], axisLabelColor: .indigo, showGridlines: false))
        },
    ])
}

/// Every 2D chart sample: line, area, sparklines, bars, pies and theming.
struct ChartsGallery: View {
    static let sections = LineChartSamples.sections + BarPieChartSamples.sections
    static var count: Int { KitGallery.count(sections) }

    var body: some View {
        KitGallery(
            title: "Charts",
            sections: Self.sections,
            footnote: "Requires `import KitoCharts`. Drag across a line chart to inspect a value.",
            searchHint: "Try a chart (“area”), a style (“stepped”, “glow”) or a screen (“stock”)."
        )
    }
}
