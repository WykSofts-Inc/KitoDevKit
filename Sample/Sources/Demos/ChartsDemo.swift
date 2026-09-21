//
//  ChartsDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCharts

// MARK: - Shared sample data

private let weekly: [ChartDataPoint] = [
    ChartDataPoint(label: "Mon", value: 120),
    ChartDataPoint(label: "Tue", value: 200),
    ChartDataPoint(label: "Wed", value: 150),
    ChartDataPoint(label: "Thu", value: 260),
    ChartDataPoint(label: "Fri", value: 190),
]

private let twoSeries: [ChartDataPoint] = [
    ChartDataPoint(label: "Mon", value: 120, category: "This week"),
    ChartDataPoint(label: "Tue", value: 200, category: "This week"),
    ChartDataPoint(label: "Wed", value: 150, category: "This week"),
    ChartDataPoint(label: "Thu", value: 260, category: "This week"),
    ChartDataPoint(label: "Mon", value: 90, category: "Last week"),
    ChartDataPoint(label: "Tue", value: 140, category: "Last week"),
    ChartDataPoint(label: "Wed", value: 180, category: "Last week"),
    ChartDataPoint(label: "Thu", value: 170, category: "Last week"),
]

private let negativeSwing: [ChartDataPoint] = [
    ChartDataPoint(label: "Jan", value: -40),
    ChartDataPoint(label: "Feb", value: 20),
    ChartDataPoint(label: "Mar", value: -10),
    ChartDataPoint(label: "Apr", value: 60),
    ChartDataPoint(label: "May", value: 35),
]

private let coloredPoints: [ChartDataPoint] = [
    ChartDataPoint(label: "Rent", value: 900, color: .red),
    ChartDataPoint(label: "Food", value: 400, color: .orange),
    ChartDataPoint(label: "Save", value: 500, color: .green),
    ChartDataPoint(label: "Fun", value: 150, color: .purple),
]

private let manyPoints: [ChartDataPoint] = (1...12).map {
    ChartDataPoint(label: "M\($0)", value: Double.random(in: 40...220))
}

// MARK: - Top-level catalog

struct ChartsDemo: View {
    var body: some View {
        List {
            NavigationLink("Line charts") { LineChartsDemo() }
            NavigationLink("Bar charts") { BarChartsDemo() }
            NavigationLink("Pie & donut charts") { PieChartsDemo() }
            NavigationLink("3D charts") { ThreeDChartsDemo() }
            NavigationLink("Theming (KitoChartTheme)") { ChartThemingDemo() }
        }
        .navigationTitle("Charts")
    }
}

private func group<Content: View>(_ title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title).font(.headline)
        if let subtitle {
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        content()
    }
    .padding(.vertical, 8)
}

// MARK: - Line charts

private struct LineChartsDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                group("Smoothed (default)") {
                    LineChartView(viewModel: LineChartViewModel(points: weekly)).frame(height: 160)
                }
                group("Straight lines", subtitle: "isSmoothed: false") {
                    LineChartView(viewModel: LineChartViewModel(points: weekly, isSmoothed: false)).frame(height: 160)
                }
                group("Multi-series with legend", subtitle: "Two categories on one chart") {
                    LineChartView(viewModel: LineChartViewModel(points: twoSeries)).frame(height: 180)
                }
                group("Legend hidden", subtitle: "showLegend: false") {
                    LineChartView(viewModel: LineChartViewModel(points: twoSeries), showLegend: false).frame(height: 160)
                }
                group("Custom value formatter", subtitle: "Currency instead of a raw number") {
                    LineChartView(
                        viewModel: LineChartViewModel(points: weekly),
                        valueFormatter: { $0.formatted(.currency(code: "USD").precision(.fractionLength(0))) }
                    )
                    .frame(height: 160)
                }
                group("Negative and positive values", subtitle: "Baseline floats correctly around zero") {
                    LineChartView(viewModel: LineChartViewModel(points: negativeSwing)).frame(height: 160)
                }
                group("Dense data (12 points)") {
                    LineChartView(viewModel: LineChartViewModel(points: manyPoints), showLegend: false).frame(height: 160)
                }
                group("Drag to inspect", subtitle: "Touch and drag across any line chart above — try it here") {
                    LineChartView(viewModel: LineChartViewModel(points: weekly)).frame(height: 160)
                    Text("A callout follows your finger showing the nearest point's value.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Line charts")
    }
}

// MARK: - Bar charts

private struct BarChartsDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                group("Default corner radius") {
                    BarChartView(viewModel: BarChartViewModel(points: weekly)).frame(height: 200)
                }
                group("Sharp corners", subtitle: "cornerRadius: 0") {
                    BarChartView(viewModel: BarChartViewModel(points: weekly), cornerRadius: 0).frame(height: 200)
                }
                group("Fully rounded (pill bars)", subtitle: "cornerRadius: 14") {
                    BarChartView(viewModel: BarChartViewModel(points: weekly), cornerRadius: 14).frame(height: 200)
                }
                group("Per-point custom colors", subtitle: "ChartDataPoint.color overrides the theme palette") {
                    BarChartView(viewModel: BarChartViewModel(points: coloredPoints)).frame(height: 200)
                }
                group("Custom value formatter", subtitle: "Percent instead of a raw number") {
                    BarChartView(
                        viewModel: BarChartViewModel(points: weekly),
                        valueFormatter: { ($0 / 300).formatted(.percent.precision(.fractionLength(0))) }
                    )
                    .frame(height: 200)
                }
                group("Tap a bar to highlight it", subtitle: "Other bars dim — try it above") {
                    BarChartView(viewModel: BarChartViewModel(points: coloredPoints)).frame(height: 180)
                }
            }
            .padding()
        }
        .navigationTitle("Bar charts")
    }
}

// MARK: - Pie / donut charts

private struct PieChartsDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                group("Pie", subtitle: "innerRadiusFraction: 0") {
                    PieChartView(viewModel: PieChartViewModel(points: coloredPoints, innerRadiusFraction: 0)).frame(height: 240)
                }
                group("Donut", subtitle: "innerRadiusFraction: 0.6") {
                    PieChartView(viewModel: PieChartViewModel(points: coloredPoints, innerRadiusFraction: 0.6)).frame(height: 240)
                }
                group("Thin ring", subtitle: "innerRadiusFraction: 0.85") {
                    PieChartView(viewModel: PieChartViewModel(points: coloredPoints, innerRadiusFraction: 0.85)).frame(height: 240)
                }
                group("Legend hidden") {
                    PieChartView(viewModel: PieChartViewModel(points: coloredPoints, innerRadiusFraction: 0.6), showLegend: false)
                        .frame(height: 200)
                }
                group("Tap a slice", subtitle: "Shows its label and percentage in the center — try it above") {
                    PieChartView(viewModel: PieChartViewModel(points: coloredPoints, innerRadiusFraction: 0.65)).frame(height: 220)
                }
            }
            .padding()
        }
        .navigationTitle("Pie & donut")
    }
}

// MARK: - 3D charts

private struct ThreeDChartsDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                group("4 bars", subtitle: "Drag to rotate, pinch to zoom, two-finger pan") {
                    Chart3DView(viewModel: Chart3DViewModel(points: coloredPoints)).frame(height: 240)
                }
                group("12 bars", subtitle: "Same interaction, denser dataset") {
                    Chart3DView(viewModel: Chart3DViewModel(points: manyPoints)).frame(height: 240)
                }
                group("3D pie", subtitle: "Extruded wedges (SCNShape), not a flat texture") {
                    Chart3DPieView(viewModel: Chart3DPieViewModel(points: coloredPoints)).frame(height: 260)
                }
                group("3D donut", subtitle: "innerRadiusFraction: 0.55") {
                    Chart3DPieView(viewModel: Chart3DPieViewModel(points: coloredPoints, innerRadiusFraction: 0.55)).frame(height: 260)
                }
                group("3D pie — dense dataset", subtitle: "12 wedges") {
                    Chart3DPieView(viewModel: Chart3DPieViewModel(points: manyPoints)).frame(height: 260)
                }
                group("3D pie — custom palette", subtitle: "Passed into the view model directly — SceneKit content doesn't read .kitoChartTheme(_:)") {
                    Chart3DPieView(viewModel: Chart3DPieViewModel(
                        points: manyPoints,
                        theme: KitoChartTheme(categoricalPalette: [.indigo, .cyan, .mint, .yellow, .pink, .orange])
                    ))
                    .frame(height: 260)
                }
                group("3D pie — interactive extrusion depth", subtitle: "Drag to change the wedge thickness live") {
                    Interactive3DPieDepthDemo()
                }
                group("3D pie — interactive inner radius", subtitle: "Drag to morph pie into a donut live") {
                    Interactive3DPieRadiusDemo()
                }
            }
            .padding()
        }
        .navigationTitle("3D charts")
    }
}

private struct Interactive3DPieDepthDemo: View {
    @State private var viewModel = Chart3DPieViewModel(points: coloredPoints, extrusionDepth: 0.6)
    @State private var depth: Double = 0.6

    var body: some View {
        VStack(spacing: 12) {
            Chart3DPieView(viewModel: viewModel).frame(height: 240)
            Slider(value: $depth, in: 0.1...1.6, step: 0.05) { Text("Depth") }
                .onChange(of: depth) { _, newValue in
                    viewModel.extrusionDepth = newValue
                    viewModel.rebuild()
                }
            Text("Extrusion depth: \(depth, specifier: "%.2f")").font(.caption2).foregroundStyle(.secondary)
        }
    }
}

private struct Interactive3DPieRadiusDemo: View {
    @State private var viewModel = Chart3DPieViewModel(points: coloredPoints)
    @State private var innerRadius: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            Chart3DPieView(viewModel: viewModel).frame(height: 240)
            Slider(value: $innerRadius, in: 0...0.9, step: 0.05) { Text("Inner radius") }
                .onChange(of: innerRadius) { _, newValue in
                    viewModel.innerRadiusFraction = newValue
                    viewModel.rebuild()
                }
            Text("Inner radius fraction: \(innerRadius, specifier: "%.2f")").font(.caption2).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Theming

private struct ChartThemingDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                group("Default theme") {
                    BarChartView(viewModel: BarChartViewModel(points: twoSeries)).frame(height: 180)
                }
                group("Custom categorical palette", subtitle: "Brand colors instead of the default palette") {
                    BarChartView(viewModel: BarChartViewModel(points: twoSeries))
                        .frame(height: 180)
                        .kitoChartTheme(KitoChartTheme(categoricalPalette: [.pink, .mint]))
                }
                group("Gridlines hidden", subtitle: "showGridlines: false") {
                    LineChartView(viewModel: LineChartViewModel(points: weekly))
                        .frame(height: 160)
                        .kitoChartTheme(KitoChartTheme(showGridlines: false))
                }
                group("Slow reveal animation", subtitle: "animationDuration: 2.5 — reopen this screen to replay") {
                    LineChartView(viewModel: LineChartViewModel(points: weekly))
                        .frame(height: 160)
                        .kitoChartTheme(KitoChartTheme(animationDuration: 2.5))
                }
                group("Custom axis colors") {
                    LineChartView(viewModel: LineChartViewModel(points: weekly))
                        .frame(height: 160)
                        .kitoChartTheme(KitoChartTheme(
                            gridlineColor: .purple.opacity(0.15),
                            axisColor: .purple,
                            axisLabelColor: .purple
                        ))
                }
                group("Everything combined", subtitle: "Palette + no gridlines + custom axis color") {
                    PieChartView(viewModel: PieChartViewModel(points: weekly, innerRadiusFraction: 0.55))
                        .frame(height: 220)
                        .kitoChartTheme(KitoChartTheme(
                            categoricalPalette: [.indigo, .cyan, .mint, .yellow, .pink],
                            axisLabelColor: .indigo,
                            showGridlines: false
                        ))
                }
            }
            .padding()
        }
        .navigationTitle("Chart theming")
    }
}
