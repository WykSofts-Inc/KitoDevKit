//
//  LineChartSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCharts

/// The code shown for a line sample: the same style arguments the preview uses.
private func lineCode(_ styleArgs: [String], data: String = "let points: [ChartDataPoint] = …", extra: String = "") -> String {
    let style = styleArgs.isEmpty
        ? ""
        : ", style: LineChartStyle(\n    " + styleArgs.joined(separator: ",\n    ") + "\n)"
    return """
    \(data)
    @State private var chart = LineChartViewModel(points: points)

    LineChartView(viewModel: chart\(style))\(extra)
        .frame(height: 220)
    """
}

private func lineCode(preset: String, data: String = "let points: [ChartDataPoint] = …") -> String {
    """
    \(data)
    @State private var chart = LineChartViewModel(points: points)

    LineChartView(viewModel: chart, style: .\(preset))
        .frame(height: 220)
    """
}

enum LineChartSamples {
    static let sections: [KitSection] = [shapes, points, styling, area, guides, multiSeries, sparklines, interactive, dashboards]

    // MARK: Shapes

    static let shapes = KitSection("Line shapes", symbol: "point.topleft.down.to.point.bottomright.curvepath", [
        KitSample("Smooth", "Curves with flat tangents: smooth, never overshoots a peak.", code: lineCode(["interpolation: .smooth"])) {
            LineHost(ChartsData.week, style: LineChartStyle(interpolation: .smooth))
        },
        KitSample("Straight", "Point-to-point segments, for data that shouldn't look interpolated.", code: lineCode(["interpolation: .linear"])) {
            LineHost(ChartsData.week, style: LineChartStyle(interpolation: .linear))
        },
        KitSample("Catmull–Rom", "The most natural curve through every point.", code: lineCode(["interpolation: .catmullRom"])) {
            LineHost(ChartsData.week, style: LineChartStyle(interpolation: .catmullRom))
        },
        KitSample("Stepped", "Holds each value until the next: pricing tiers, states, rates.", code: lineCode(["interpolation: .stepped", "points: .filled"])) {
            LineHost(ChartsData.pricingTiers, style: LineChartStyle(interpolation: .stepped, points: .filled, showsLabels: true), format: { "$\(Int($0))" })
        },
        KitSample("Smooth vs Catmull–Rom", "Same spiky data: Catmull–Rom dips below the baseline, smooth doesn't.", code: """
        LineChartView(viewModel: chart, style: LineChartStyle(interpolation: .smooth))
        LineChartView(viewModel: chart, style: LineChartStyle(interpolation: .catmullRom))
        """) {
            VStack(alignment: .leading, spacing: 14) {
                Text(".smooth").font(.caption.monospaced()).foregroundStyle(.secondary)
                LineHost(ChartsData.spiky, style: LineChartStyle(interpolation: .smooth, points: .filled), height: 160)
                Text(".catmullRom").font(.caption.monospaced()).foregroundStyle(.secondary)
                LineHost(ChartsData.spiky, style: LineChartStyle(interpolation: .catmullRom, points: .filled), height: 160)
            }
        },
        KitSample("Dense data", "60 points with a thinner line.", code: lineCode(["interpolation: .linear", "lineWidth: 1.5"])) {
            LineHost(ChartsData.dense, style: LineChartStyle(interpolation: .linear, lineWidth: 1.5))
        },
        KitSample("Flat series", "Identical values still get a readable axis.", code: lineCode([])) {
            LineHost(ChartsData.flat)
        },
        KitSample("Negative values", "Profit and loss around a solid break-even line.", code: lineCode([
            "includesZero: true",
            "referenceLines: [LineReferenceLine(\"Break-even\", value: 0, isDashed: false)]",
        ])) {
            LineHost(ChartsData.profitAndLoss, style: LineChartStyle(includesZero: true, referenceLines: [LineReferenceLine("Break-even", value: 0, isDashed: false)]), format: { "\(Int($0))k" })
        },
    ])

    // MARK: Points & labels

    static let points = KitSection("Points & labels", symbol: "circle.dotted", [
        KitSample("Filled points", "A solid dot on every value.", code: lineCode(["points: .filled"])) {
            LineHost(ChartsData.week, style: LineChartStyle(points: .filled))
        },
        KitSample("Hollow points", "Rings with the background showing through.", code: lineCode(["points: .hollow", "pointSize: 9"])) {
            LineHost(ChartsData.week, style: LineChartStyle(points: .hollow, pointSize: 9))
        },
        KitSample("Halo points", "A dot with a soft ring around it.", code: lineCode(["points: .halo"])) {
            LineHost(ChartsData.week, style: LineChartStyle(interpolation: .catmullRom, points: .halo))
        },
        KitSample("Pulsing latest value", "Only the newest point, pulsing: the live-data look.", code: lineCode(["points: .lastPoint", "pointSize: 8"])) {
            LineHost(ChartsData.dense, style: LineChartStyle(interpolation: .linear, lineWidth: 2, points: .lastPoint, pointSize: 8))
        },
        KitSample("Value labels", "Each value printed above its point.", code: lineCode(["points: .filled", "showsValues: true"])) {
            LineHost(ChartsData.week, style: LineChartStyle(points: .filled, showsValues: true))
        },
        KitSample("X-axis labels", "Month names along the bottom.", code: lineCode(["showsLabels: true"])) {
            LineHost(ChartsData.months, style: LineChartStyle(showsLabels: true))
        },
        KitSample("Crowded labels thin out", "24 hours: labels skip so they never collide, the last always shows.", code: lineCode(["showsLabels: true"])) {
            LineHost(ChartsData.hours, style: LineChartStyle(interpolation: .catmullRom, showsLabels: true))
        },
        KitSample("Big markers", "Thick line, large rings: readable at a glance.", code: lineCode(["lineWidth: 4", "points: .hollow", "pointSize: 13"])) {
            LineHost(ChartsData.week, style: LineChartStyle(lineWidth: 4, points: .hollow, pointSize: 13))
        },
        KitSample("Labels without an axis", "Values and months only, no gridlines.", code: lineCode(["points: .filled", "showsValueAxis: false", "showsLabels: true", "showsValues: true"])) {
            LineHost(ChartsData.week, style: LineChartStyle(points: .filled, showsValueAxis: false, showsLabels: true, showsValues: true))
        },
    ])

    // MARK: Line styling

    static let styling = KitSection("Line styling", symbol: "scribble.variable", [
        KitSample("Hairline", "0.75pt, for dense dashboards.", code: lineCode(["lineWidth: 0.75"])) {
            LineHost(ChartsData.months, style: LineChartStyle(lineWidth: 0.75))
        },
        KitSample("Bold", "5pt, for hero charts.", code: lineCode(["lineWidth: 5"])) {
            LineHost(ChartsData.week, style: LineChartStyle(lineWidth: 5))
        },
        KitSample("Dashed", "A projection or estimate.", code: lineCode(["dash: [8, 5]"])) {
            LineHost(ChartsData.months, style: LineChartStyle(dash: [8, 5]))
        },
        KitSample("Dotted", "Round caps on a near-zero dash draw dots.", code: lineCode(["lineWidth: 3.5", "dash: [0.1, 7]"])) {
            LineHost(ChartsData.week, style: LineChartStyle(lineWidth: 3.5, dash: [0.1, 7]))
        },
        KitSample("Gradient stroke", "Colour runs left to right along the line.", code: lineCode(["lineWidth: 4", "strokeGradient: [.blue, .purple, .pink]"])) {
            LineHost(ChartsData.months, style: LineChartStyle(lineWidth: 4, strokeGradient: [.blue, .purple, .pink]))
        },
        KitSample("Temperature gradient", "Cold to hot across the day.", code: lineCode([
            "interpolation: .catmullRom", "lineWidth: 4",
            "strokeGradient: [.blue, .green, .yellow, .orange, .red]", "showsLabels: true",
        ])) {
            LineHost(ChartsData.hourlyTemperature, style: LineChartStyle(interpolation: .catmullRom, lineWidth: 4, strokeGradient: [.blue, .green, .yellow, .orange, .red], showsLabels: true), format: { "\(Int($0))°" })
        },
        KitSample("Neon glow", "A glowing gradient line on a dark card.", code: lineCode(["lineWidth: 3", "strokeGradient: [.cyan, .purple, .pink]", "glows: true"], extra: "\n    .background(Color.black)")) {
            LineHost(ChartsData.months, style: LineChartStyle(interpolation: .catmullRom, lineWidth: 3, strokeGradient: [.cyan, .purple, .pink], glows: true, showsValueAxis: false))
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.black))
        },
        KitSample("Gridlines off", "KitoChartTheme(showGridlines: false).", code: lineCode([]) + "\n.kitoChartTheme(KitoChartTheme(showGridlines: false))") {
            LineHost(ChartsData.week).kitoChartTheme(KitoChartTheme(showGridlines: false))
        },
        KitSample("Custom axis colours", "Gridlines, axis and labels in your brand colour.", code: lineCode([]) + "\n.kitoChartTheme(KitoChartTheme(\n    gridlineColor: .purple.opacity(0.15), axisColor: .purple, axisLabelColor: .purple\n))") {
            LineHost(ChartsData.week).kitoChartTheme(KitoChartTheme(categoricalPalette: [.purple], gridlineColor: .purple.opacity(0.15), axisColor: .purple, axisLabelColor: .purple))
        },
        KitSample("No draw-in", "Appears instantly, for charts inside scrolling lists.", code: lineCode(["animatesIn: false"])) {
            LineHost(ChartsData.week, style: LineChartStyle(animatesIn: false))
        },
        KitSample("Slow draw-in", "A 2.5 second wipe; reopen to replay.", code: lineCode([]) + "\n.kitoChartTheme(KitoChartTheme(animationDuration: 2.5))") {
            LineHost(ChartsData.months, style: LineChartStyle(points: .filled)).kitoChartTheme(KitoChartTheme(animationDuration: 2.5))
        },
    ])

    // MARK: Area

    static let area = KitSection("Area charts", symbol: "chart.line.uptrend.xyaxis", [
        KitSample("Gradient area", "The .area preset: fades to clear at zero.", code: lineCode(preset: "area")) {
            LineHost(ChartsData.months, style: .area)
        },
        KitSample("Solid area", "A flat fill.", code: lineCode(["area: .solid(opacity: 0.25)", "includesZero: true"])) {
            LineHost(ChartsData.week, style: LineChartStyle(area: .solid(opacity: 0.25)))
        },
        KitSample("Stepped area", "Blocks of value, like usage per billing period.", code: lineCode(["interpolation: .stepped", "area: .gradient(opacity: 0.4)"])) {
            LineHost(ChartsData.pricingTiers, style: LineChartStyle(interpolation: .stepped, area: .gradient(opacity: 0.4), showsLabels: true))
        },
        KitSample("Area with points", "Fill, markers and month labels together.", code: lineCode(["interpolation: .catmullRom", "points: .hollow", "area: .gradient(opacity: 0.3)", "showsLabels: true"])) {
            LineHost(ChartsData.months, style: LineChartStyle(interpolation: .catmullRom, points: .hollow, area: .gradient(opacity: 0.3), showsLabels: true))
        },
        KitSample("Profit & loss area", "Fills above and below zero.", code: lineCode(["interpolation: .linear", "area: .gradient(opacity: 0.35)", "referenceLines: [LineReferenceLine(\"0\", value: 0, isDashed: false)]"])) {
            LineHost(ChartsData.profitAndLoss, style: LineChartStyle(interpolation: .linear, area: .gradient(opacity: 0.35), referenceLines: [LineReferenceLine("0", value: 0, isDashed: false)]), format: { "\(Int($0))k" })
        },
        KitSample("Glowing area", "Glow plus a strong fill, for dark designs.", code: lineCode(["interpolation: .catmullRom", "area: .gradient(opacity: 0.55)", "glows: true"])) {
            LineHost(ChartsData.hours, style: LineChartStyle(interpolation: .catmullRom, area: .gradient(opacity: 0.55), glows: true, showsValueAxis: false))
                .kitoChartTheme(KitoChartTheme(categoricalPalette: [.mint]))
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.black))
        },
    ])

    // MARK: Goals & guides

    static let guides = KitSection("Goals & guides", symbol: "ruler", [
        KitSample("Goal line", "A dashed target the line is chasing.", code: lineCode(["referenceLines: [LineReferenceLine(\"Goal\", value: 250, color: .green)]"])) {
            LineHost(ChartsData.months, style: LineChartStyle(referenceLines: [LineReferenceLine("Goal", value: 250, color: .green)]))
        },
        KitSample("Upper & lower limits", "Two solid red bounds.", code: lineCode([
            "referenceLines: [",
            "    LineReferenceLine(\"Max\", value: 110, color: .red, isDashed: false),",
            "    LineReferenceLine(\"Min\", value: 50, color: .red, isDashed: false),",
            "]",
        ])) {
            LineHost(ChartsData.heartRate, style: LineChartStyle(interpolation: .catmullRom, referenceLines: [
                LineReferenceLine("Max", value: 110, color: .red, isDashed: false),
                LineReferenceLine("Min", value: 50, color: .red, isDashed: false),
            ]))
        },
        KitSample("Average line", "Computed from the data.", code: """
        let average = points.map(\\.value).reduce(0, +) / Double(points.count)

        LineChartView(viewModel: chart, style: LineChartStyle(
            points: .filled,
            referenceLines: [LineReferenceLine("Avg", value: average)]
        ))
        """) {
            LineHost(ChartsData.week, style: LineChartStyle(points: .filled, referenceLines: [LineReferenceLine("Avg \(Int(ChartsData.average(ChartsData.week)))", value: ChartsData.average(ChartsData.week), color: .orange)]))
        },
        KitSample("Target band", "Green dashed bounds with markers inside.", code: lineCode(["points: .halo", "referenceLines: [high, low]"])) {
            LineHost(ChartsData.hourlyTemperature, style: LineChartStyle(interpolation: .catmullRom, points: .halo, showsLabels: true, referenceLines: [
                LineReferenceLine("Comfort", value: 24, color: .green), LineReferenceLine("", value: 18, color: .green),
            ]), format: { "\(Int($0))°" })
        },
        KitSample("Budget cap", "Spend against a hard limit.", code: lineCode(["interpolation: .linear", "area: .gradient(opacity: 0.25)", "referenceLines: [LineReferenceLine(\"Budget\", value: 1_000, color: .red, isDashed: false)]"])) {
            LineHost(ChartsData.series(ChartsData.weekdays, [120, 260, 410, 520, 700, 910, 1_060]), style: LineChartStyle(interpolation: .linear, points: .filled, area: .gradient(opacity: 0.25), referenceLines: [LineReferenceLine("Budget", value: 1_000, color: .red, isDashed: false)]), format: { $0.usd })
        },
    ])

    // MARK: Multi-series

    static let multiSeries = KitSection("Multi-series", symbol: "chart.line.text.clipboard", [
        KitSample("Two series with legend", "Points share a category per series.", code: """
        let points = thisWeek.map { ChartDataPoint(label: $0.day, value: $0.visits, category: "This week") }
                   + lastWeek.map { ChartDataPoint(label: $0.day, value: $0.visits, category: "Last week") }

        LineChartView(viewModel: LineChartViewModel(points: points))
        """) {
            LineHost(ChartsData.visitors)
        },
        KitSample("Three platforms", "Legend and palette scale to any number of series.", code: lineCode(["points: .filled", "showsLabels: true"])) {
            LineHost(ChartsData.platforms, style: LineChartStyle(points: .filled, showsLabels: true))
        },
        KitSample("Stepped series", "Several step lines, one per plan.", code: lineCode(["interpolation: .stepped"])) {
            LineHost(ChartsData.series(ChartsData.monthNames.prefix(8).map { $0 }, [10, 10, 12, 12, 12, 15, 15, 15], category: "Basic")
                     + ChartsData.series(ChartsData.monthNames.prefix(8).map { $0 }, [20, 20, 20, 25, 25, 25, 30, 30], category: "Pro"),
                     style: LineChartStyle(interpolation: .stepped, showsLabels: true), format: { "$\(Int($0))" })
        },
        KitSample("Custom palette", "Series colours from your own palette.", code: lineCode(["points: .hollow"]) + "\n.kitoChartTheme(KitoChartTheme(categoricalPalette: [.pink, .indigo, .teal]))") {
            LineHost(ChartsData.platforms, style: LineChartStyle(interpolation: .catmullRom, points: .hollow)).kitoChartTheme(KitoChartTheme(categoricalPalette: [.pink, .indigo, .teal]))
        },
        KitSample("Series with areas", "Overlapping translucent fills.", code: lineCode(["area: .gradient(opacity: 0.25)"])) {
            LineHost(ChartsData.visitors, style: LineChartStyle(area: .gradient(opacity: 0.25), showsLabels: true))
        },
    ])

    // MARK: Sparklines & tiles

    static let sparklines = KitSection("Sparklines & tiles", symbol: "square.grid.2x2", [
        KitSample("Sparkline", "The .sparkline preset: no axis, soft fill, pulsing latest value.", code: lineCode(preset: "sparkline").replacingOccurrences(of: "height: 220", with: "height: 60")) {
            LineHost(ChartsData.dense, style: .sparkline, height: 60)
        },
        KitSample("Stat tiles", "A 2×2 grid of metrics, each with its trend.", code: """
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            ForEach(metrics) { metric in
                VStack(alignment: .leading) {
                    Text(metric.name).font(.caption)
                    Text(metric.value).font(.title2.bold())
                    LineChartView(viewModel: metric.chart, style: .sparkline)
                        .frame(height: 44)
                }
            }
        }
        """) { StatTilesSample() },
        KitSample("List rows", "A trend in every row, like a watchlist.", code: """
        ForEach(rows) { row in
            HStack {
                Text(row.name)
                LineChartView(viewModel: row.chart, style: .sparkline)
                    .frame(width: 80, height: 32)
                Text(row.change)
            }
        }
        """) { SparklineRowsSample() },
        KitSample("Straight sparkline", "Linear, no fill, no marker: the minimal version.", code: lineCode(["interpolation: .linear", "lineWidth: 1.5", "showsValueAxis: false"]).replacingOccurrences(of: "height: 220", with: "height: 50")) {
            LineHost(ChartsData.dense, style: LineChartStyle(interpolation: .linear, lineWidth: 1.5, showsValueAxis: false), height: 50)
        },
    ])

    // MARK: Live & interactive

    static let interactive = KitSection("Live & interactive", symbol: "hand.draw", [
        KitSample("Style playground", "Every LineChartStyle option on one chart.", code: """
        LineChartView(viewModel: chart, style: LineChartStyle(
            interpolation: interpolation,
            lineWidth: lineWidth,
            points: points,
            area: fillsArea ? .gradient(opacity: 0.35) : .none,
            glows: glows,
            showsLabels: showsLabels,
            showsValues: showsValues
        ))
        """) { LineStylePlayground() },
        KitSample("Live stream", "A new value every second; the oldest scrolls off.", code: """
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            chart.points.removeFirst()
            chart.points.append(ChartDataPoint(label: now, value: nextValue()))
        }
        """) { LiveStreamSample() },
        KitSample("Range switcher", "1D, 1W, 1M, 1Y: swap the data and replay the draw-in.", code: """
        Picker("Range", selection: $range) { … }.pickerStyle(.segmented)
            .onChange(of: range) { _, newRange in
                chart.points = newRange.points
                chart.reveal(duration: 0.6)
            }
        """) { LineRangeSwitcherSample() },
        KitSample("Drag to inspect", "Touch and drag: a rule, a marker and a callout follow your finger.", code: lineCode(["points: .filled"])) {
            VStack(spacing: 10) {
                LineHost(ChartsData.months, style: LineChartStyle(points: .filled, showsLabels: true), format: { $0.usd })
                Label("Touch and drag across the chart", systemImage: "hand.point.up.left").font(.caption).foregroundStyle(.secondary)
            }
        },
        KitSample("Add and remove points", "A stepper grows the series.", code: """
        Stepper("Points: \\(count)", value: $count, in: 2...12)
            .onChange(of: count) { _, n in chart.points = Array(all.prefix(n)) }
        """) { PointCountSample() },
        KitSample("Interpolation picker", "Linear, smooth, Catmull–Rom and stepped on the same data.", code: """
        Picker("Interpolation", selection: $interpolation) { … }
        LineChartView(viewModel: chart, style: LineChartStyle(interpolation: interpolation, points: .filled))
        """) { InterpolationPickerSample() },
    ])

    // MARK: Dashboards

    static let dashboards = KitSection("Real-world screens", symbol: "rectangle.3.group", [
        KitSample("Stock detail", "Price header, range picker, colour follows the trend.", code: """
        let isUp = (points.last?.value ?? 0) >= (points.first?.value ?? 0)

        LineChartView(viewModel: chart, style: LineChartStyle(
            interpolation: .linear, lineWidth: 2,
            area: .gradient(opacity: 0.3), showsValueAxis: false
        ))
        .kitoChartTheme(KitoChartTheme(categoricalPalette: [isUp ? .green : .red]))
        """) { StockDetailSample() },
        KitSample("Heart rate", "BPM over a workout with zone limits.", code: lineCode(["interpolation: .catmullRom", "points: .lastPoint", "area: .gradient(opacity: 0.2)", "referenceLines: [zone2, zone4]"])) { HeartRateSample() },
        KitSample("Hourly weather", "Temperatures with values and hours.", code: lineCode(["interpolation: .catmullRom", "points: .filled", "strokeGradient: [.blue, .orange]", "showsValueAxis: false", "showsLabels: true", "showsValues: true"])) { WeatherSample() },
        KitSample("Sleep stages", "Stepped line on four named levels.", code: lineCode(["interpolation: .stepped", "lineWidth: 3", "area: .gradient(opacity: 0.3)", "showsLabels: true"])) { SleepSample() },
        KitSample("Website traffic", "This week vs last, with a goal.", code: lineCode(["points: .filled", "showsLabels: true", "referenceLines: [LineReferenceLine(\"Goal\", value: 1_200)]"])) { TrafficSample() },
        KitSample("Battery", "Drain across the day, red below 20%.", code: lineCode(["interpolation: .linear", "points: .filled", "area: .gradient(opacity: 0.3)", "referenceLines: [LineReferenceLine(\"Low\", value: 20, color: .red)]"])) { BatterySample() },
    ])
}
