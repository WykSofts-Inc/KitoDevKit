//
//  LineChartShowcases.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Combine
import KitoCharts

// MARK: - Sparklines & tiles

struct StatTilesSample: View {
    private struct Metric: Identifiable {
        let id = UUID()
        let name: String
        let value: String
        let change: String
        let isGood: Bool
        let points: [ChartDataPoint]
    }

    private let metrics = [
        Metric(name: "Revenue", value: "$48.2k", change: "+12%", isGood: true, points: ChartsData.walk(count: 24, start: 40, volatility: 4, drift: 0.8, seed: 11)),
        Metric(name: "Active users", value: "8,410", change: "+4%", isGood: true, points: ChartsData.walk(count: 24, start: 70, volatility: 5, drift: 0.4, seed: 12)),
        Metric(name: "Churn", value: "2.1%", change: "−0.3%", isGood: true, points: ChartsData.walk(count: 24, start: 60, volatility: 3, drift: -0.9, seed: 13)),
        Metric(name: "Latency", value: "182 ms", change: "+9%", isGood: false, points: ChartsData.walk(count: 24, start: 30, volatility: 6, drift: 0.7, seed: 14)),
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(spacing: 12), GridItem(spacing: 12)], spacing: 12) {
            ForEach(metrics) { metric in
                VStack(alignment: .leading, spacing: 4) {
                    Text(metric.name).font(.caption).foregroundStyle(.secondary)
                    Text(metric.value).font(.title3.bold().monospacedDigit())
                    Text(metric.change).font(.caption2.weight(.bold)).foregroundStyle(metric.isGood ? .green : .red)
                    LineHost(metric.points, style: .sparkline, height: 44)
                        .kitoChartTheme(KitoChartTheme(categoricalPalette: [metric.isGood ? .green : .red]))
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
            }
        }
    }
}

struct SparklineRowsSample: View {
    private struct Row: Identifiable {
        let id = UUID()
        let symbol: String
        let name: String
        let points: [ChartDataPoint]
        var first: Double { points.first?.value ?? 0 }
        var last: Double { points.last?.value ?? 0 }
        var change: Double { first == 0 ? 0 : (last - first) / first }
    }

    // Fictional tickers: sample data, not market data.
    private let rows = [
        Row(symbol: "KITO", name: "Kito Labs", points: ChartsData.walk(count: 30, start: 120, volatility: 4, drift: 0.6, seed: 21)),
        Row(symbol: "ACME", name: "Acme Corp", points: ChartsData.walk(count: 30, start: 80, volatility: 3, drift: -0.4, seed: 22)),
        Row(symbol: "GLBX", name: "Globex", points: ChartsData.walk(count: 30, start: 200, volatility: 6, drift: 0.9, seed: 23)),
        Row(symbol: "INIT", name: "Initech", points: ChartsData.walk(count: 30, start: 45, volatility: 2, drift: -0.2, seed: 24)),
        Row(symbol: "UMBR", name: "Umbrella", points: ChartsData.walk(count: 30, start: 150, volatility: 5, drift: 0.3, seed: 25)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.symbol).font(.subheadline.bold())
                        Text(row.name).font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(width: 84, alignment: .leading)
                    LineHost(row.points, style: LineChartStyle(interpolation: .linear, lineWidth: 1.5, showsValueAxis: false, animatesIn: false), height: 44)
                        .kitoChartTheme(KitoChartTheme(categoricalPalette: [row.change >= 0 ? .green : .red]))
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(row.last.usd).font(.subheadline.monospacedDigit())
                        Text(row.change.formatted(.percent.precision(.fractionLength(1)).sign(strategy: .always())))
                            .font(.caption2.bold().monospacedDigit())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(row.change >= 0 ? Color.green : Color.red))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 76, alignment: .trailing)
                }
                .padding(.vertical, 10)
                Divider()
            }
            Text("Fictional companies and sample data.").font(.caption2).foregroundStyle(.secondary).padding(.top, 8)
        }
    }
}

// MARK: - Live & interactive

struct LineStylePlayground: View {
    enum Interpolation: String, CaseIterable, Identifiable {
        case linear = "Linear", smooth = "Smooth", catmullRom = "Catmull", stepped = "Stepped"
        var id: String { rawValue }
        var value: LineInterpolation {
            switch self {
            case .linear: return .linear
            case .smooth: return .smooth
            case .catmullRom: return .catmullRom
            case .stepped: return .stepped
            }
        }
    }

    enum Marker: String, CaseIterable, Identifiable {
        case none = "None", filled = "Filled", hollow = "Hollow", halo = "Halo", last = "Latest"
        var id: String { rawValue }
        var value: LinePointStyle {
            switch self {
            case .none: return .none
            case .filled: return .filled
            case .hollow: return .hollow
            case .halo: return .halo
            case .last: return .lastPoint
            }
        }
    }

    @State private var chart = LineChartViewModel(points: ChartsData.week)
    @State private var interpolation = Interpolation.smooth
    @State private var marker = Marker.filled
    @State private var lineWidth = 2.5
    @State private var fillsArea = false
    @State private var glows = false
    @State private var dashed = false
    @State private var gradient = false
    @State private var showsLabels = true
    @State private var showsValues = false
    @State private var showsAxis = true
    @State private var showsGoal = false

    private var style: LineChartStyle {
        LineChartStyle(
            interpolation: interpolation.value,
            lineWidth: lineWidth,
            dash: dashed ? [8, 5] : [],
            points: marker.value,
            area: fillsArea ? .gradient(opacity: 0.35) : .none,
            strokeGradient: gradient ? [.blue, .purple, .pink] : nil,
            glows: glows,
            showsValueAxis: showsAxis,
            showsLabels: showsLabels,
            showsValues: showsValues,
            referenceLines: showsGoal ? [LineReferenceLine("Goal", value: 280, color: .green)] : []
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LineChartView(viewModel: chart, style: style).frame(height: 220)
                .animation(.easeInOut(duration: 0.25), value: style)

            Picker("Interpolation", selection: $interpolation) {
                ForEach(Interpolation.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            Picker("Points", selection: $marker) {
                ForEach(Marker.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Line width").font(.subheadline)
                Slider(value: $lineWidth, in: 0.5...7)
                Text(lineWidth, format: .number.precision(.fractionLength(1))).font(.caption.monospacedDigit()).frame(width: 30)
            }

            LazyVGrid(columns: [GridItem(), GridItem()], alignment: .leading, spacing: 4) {
                Toggle("Area fill", isOn: $fillsArea)
                Toggle("Glow", isOn: $glows)
                Toggle("Dashed", isOn: $dashed)
                Toggle("Gradient", isOn: $gradient)
                Toggle("X labels", isOn: $showsLabels)
                Toggle("Values", isOn: $showsValues)
                Toggle("Value axis", isOn: $showsAxis)
                Toggle("Goal line", isOn: $showsGoal)
            }
            .font(.subheadline)
            .tint(.primary)
        }
    }
}

struct LiveStreamSample: View {
    @State private var chart = LineChartViewModel(points: ChartsData.walk(count: 30, start: 60, volatility: 5, drift: 0, seed: 31))
    @State private var generator = SeededValues(seed: 32)
    @State private var tick = 30
    @State private var isRunning = true
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var latest: Double { chart.points.last?.value ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(Int(latest))").font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
                    .contentTransition(.numericText())
                Text("req/s").foregroundStyle(.secondary)
                Spacer()
                Label(isRunning ? "Live" : "Paused", systemImage: isRunning ? "dot.radiowaves.left.and.right" : "pause.fill")
                    .font(.caption.bold())
                    .foregroundStyle(isRunning ? .red : .secondary)
            }
            LineChartView(viewModel: chart, style: LineChartStyle(interpolation: .catmullRom, points: .lastPoint, area: .gradient(opacity: 0.25), animatesIn: false))
                .frame(height: 200)
            Button(isRunning ? "Pause" : "Resume") { isRunning.toggle() }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(.primary)
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            tick += 1
            let next = min(max(latest + generator.next(in: -8...8), 10), 120)
            withAnimation(.easeInOut(duration: 0.4)) {
                chart.points.removeFirst()
                chart.points.append(ChartDataPoint(label: "\(tick)s", value: next))
            }
        }
    }
}

struct LineRangeSwitcherSample: View {
    enum Range: String, CaseIterable, Identifiable {
        case day = "1D", week = "1W", month = "1M", year = "1Y", fiveYears = "5Y"
        var id: String { rawValue }
        var points: [ChartDataPoint] {
            switch self {
            case .day: return ChartsData.walk(count: 78, start: 180, volatility: 1.5, drift: 0.05, seed: 41)
            case .week: return ChartsData.walk(count: 35, start: 172, volatility: 3, drift: 0.3, seed: 42)
            case .month: return ChartsData.walk(count: 30, start: 160, volatility: 4, drift: 0.8, seed: 43)
            case .year: return ChartsData.walk(count: 52, start: 120, volatility: 6, drift: 1.2, seed: 44)
            case .fiveYears: return ChartsData.walk(count: 60, start: 60, volatility: 8, drift: 2, seed: 45)
            }
        }
    }

    @State private var chart = LineChartViewModel(points: Range.month.points)
    @State private var range = Range.month

    var body: some View {
        VStack(spacing: 14) {
            Picker("Range", selection: $range) {
                ForEach(Range.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: range) { _, newRange in
                chart.points = newRange.points
                chart.reveal(duration: 0.6)
            }
            LineChartView(viewModel: chart, style: LineChartStyle(interpolation: .linear, lineWidth: 2, area: .gradient(opacity: 0.25)), valueFormatter: { $0.usd })
                .frame(height: 220)
        }
    }
}

struct PointCountSample: View {
    @State private var chart = LineChartViewModel(points: Array(ChartsData.months.prefix(6)))
    @State private var count = 6

    var body: some View {
        VStack(spacing: 12) {
            LineChartView(viewModel: chart, style: LineChartStyle(interpolation: .catmullRom, points: .filled, showsLabels: true))
                .frame(height: 220)
                .animation(.easeInOut(duration: 0.3), value: count)
            Stepper("Points: \(count)", value: $count, in: 2...ChartsData.months.count)
                .onChange(of: count) { _, n in chart.points = Array(ChartsData.months.prefix(n)) }
        }
    }
}

struct InterpolationPickerSample: View {
    @State private var chart = LineChartViewModel(points: ChartsData.spiky)
    @State private var interpolation = LineStylePlayground.Interpolation.smooth

    var body: some View {
        VStack(spacing: 12) {
            Picker("Interpolation", selection: $interpolation) {
                ForEach(LineStylePlayground.Interpolation.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            LineChartView(viewModel: chart, style: LineChartStyle(interpolation: interpolation.value, points: .filled))
                .frame(height: 220)
        }
    }
}

// MARK: - Real-world screens

private struct ScreenCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12, content: content)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 22).fill(Color(.secondarySystemBackground)))
    }
}

struct StockDetailSample: View {
    @State private var chart = LineChartViewModel(points: LineRangeSwitcherSample.Range.day.points)
    @State private var range = LineRangeSwitcherSample.Range.day

    private var first: Double { chart.points.first?.value ?? 0 }
    private var last: Double { chart.points.last?.value ?? 0 }
    private var isUp: Bool { last >= first }
    private var change: Double { last - first }

    var body: some View {
        ScreenCard {
            VStack(alignment: .leading, spacing: 2) {
                Text("KITO · Kito Labs").font(.subheadline).foregroundStyle(.secondary)
                Text(last.usd).font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
                    .contentTransition(.numericText())
                Text("\(change >= 0 ? "▲" : "▼") \(abs(change).usd) (\((change / max(first, 1)).formatted(.percent.precision(.fractionLength(2))))) \(range.rawValue)")
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundStyle(isUp ? .green : .red)
            }
            LineChartView(viewModel: chart, style: LineChartStyle(interpolation: .linear, lineWidth: 2, area: .gradient(opacity: 0.3), showsValueAxis: false, referenceLines: [LineReferenceLine("Open", value: first)]), valueFormatter: { $0.usd })
                .frame(height: 200)
                .kitoChartTheme(KitoChartTheme(categoricalPalette: [isUp ? .green : .red]))
            Picker("Range", selection: $range) {
                ForEach(LineRangeSwitcherSample.Range.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: range) { _, newRange in
                withAnimation { chart.points = newRange.points }
                chart.reveal(duration: 0.5)
            }
            Text("Fictional company and sample data.").font(.caption2).foregroundStyle(.secondary)
        }
    }
}

struct HeartRateSample: View {
    var body: some View {
        ScreenCard {
            HStack {
                Image(systemName: "heart.fill").foregroundStyle(.red).symbolEffect(.pulse)
                Text("Heart rate").font(.headline)
                Spacer()
                Text("\(Int(ChartsData.heartRate.last?.value ?? 0)) BPM").font(.headline.monospacedDigit())
            }
            LineHost(ChartsData.heartRate, style: LineChartStyle(
                interpolation: .catmullRom, points: .lastPoint, area: .gradient(opacity: 0.2),
                referenceLines: [LineReferenceLine("Zone 4", value: 90, color: .orange), LineReferenceLine("Zone 2", value: 65, color: .green)]
            ), height: 200)
            .kitoChartTheme(KitoChartTheme(categoricalPalette: [.red]))
            Text("30-minute workout").font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct WeatherSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Nairobi").font(.title2.bold())
                Text("26° · Mostly sunny").font(.subheadline)
                Text("H: 26°  L: 14°").font(.caption).opacity(0.8)
            }
            LineHost(ChartsData.hourlyTemperature, style: LineChartStyle(
                interpolation: .catmullRom, lineWidth: 3, points: .filled, pointSize: 6,
                strokeGradient: [.cyan, .yellow, .orange], showsValueAxis: false, showsLabels: true, showsValues: true
            ), height: 180, format: { "\(Int($0))°" })
            .kitoChartTheme(KitoChartTheme(categoricalPalette: [.white], axisLabelColor: .white.opacity(0.85)))
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(
            LinearGradient(colors: [Color(red: 0.2, green: 0.45, blue: 0.9), Color(red: 0.45, green: 0.7, blue: 1)], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 22)
        )
    }
}

struct SleepSample: View {
    private static let stages = ["Deep", "Core", "REM", "Awake"]
    // Awake plotted on top, like the Health app.
    private let points = ChartsData.sleepStages.map { ChartDataPoint(label: $0.label, value: 3 - $0.value) }

    var body: some View {
        ScreenCard {
            HStack {
                Image(systemName: "bed.double.fill").foregroundStyle(.indigo)
                Text("Sleep").font(.headline)
                Spacer()
                Text("7h 42m").font(.headline.monospacedDigit())
            }
            LineHost(points, style: LineChartStyle(interpolation: .stepped, lineWidth: 3, area: .gradient(opacity: 0.3), showsLabels: true), height: 200, format: { value in
                Self.stages[min(max(Int(value.rounded()), 0), 3)]
            })
            .kitoChartTheme(KitoChartTheme(categoricalPalette: [.indigo]))
        }
    }
}

struct TrafficSample: View {
    var body: some View {
        ScreenCard {
            Text("Visitors").font(.headline)
            Text("7,373 this week · +21% vs last").font(.subheadline).foregroundStyle(.secondary)
            LineHost(ChartsData.visitors, style: LineChartStyle(points: .filled, showsLabels: true, referenceLines: [LineReferenceLine("Goal", value: 1_200, color: .green)]), height: 220)
        }
    }
}

struct BatterySample: View {
    var body: some View {
        ScreenCard {
            HStack {
                Image(systemName: "battery.25percent").foregroundStyle(.orange)
                Text("Battery").font(.headline)
                Spacer()
                Text("22%").font(.headline.monospacedDigit())
            }
            LineHost(ChartsData.battery, style: LineChartStyle(
                interpolation: .linear, points: .filled, area: .gradient(opacity: 0.3), showsLabels: true, includesZero: true,
                referenceLines: [LineReferenceLine("Low", value: 20, color: .red)]
            ), height: 200, format: { "\(Int($0))%" })
            .kitoChartTheme(KitoChartTheme(categoricalPalette: [.green]))
        }
    }
}
