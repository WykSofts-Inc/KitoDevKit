//
//  Chart3DInteractiveSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCharts

// SceneKit scenes aren't observable, so every sample here mutates the view model and then calls
// `rebuild()`, which is the pattern the package documents.

// MARK: - Live & interactive

struct DepthSliderSample: View {
    @State private var chart = Chart3DPieViewModel(points: Chart3DData.budget)
    @State private var depth = 0.6

    var body: some View {
        VStack(spacing: 12) {
            Chart3DPieView(viewModel: chart).frame(height: 280)
            Slider(value: $depth, in: 0.1...1.6, step: 0.05) { Text("Depth") }
                .onChange(of: depth) { _, newValue in
                    chart.extrusionDepth = newValue
                    chart.rebuild()
                }
            Text("extrusionDepth: \(depth, specifier: "%.2f")").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
    }
}

struct InnerRadiusSliderSample: View {
    @State private var chart = Chart3DPieViewModel(points: Chart3DData.budget)
    @State private var hole = 0.0

    var body: some View {
        VStack(spacing: 12) {
            Chart3DPieView(viewModel: chart).frame(height: 280)
            Slider(value: $hole, in: 0...0.9, step: 0.05) { Text("Inner radius") }
                .onChange(of: hole) { _, newValue in
                    chart.innerRadiusFraction = newValue
                    chart.rebuild()
                }
            Text("innerRadiusFraction: \(hole, specifier: "%.2f")").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
    }
}

struct ValueEditorSample: View {
    @State private var chart = Chart3DPieViewModel(points: Array(Chart3DData.survey.prefix(3)), innerRadiusFraction: 0.35)

    var body: some View {
        VStack(spacing: 14) {
            Chart3DPieView(viewModel: chart).frame(height: 260)
            ForEach(chart.points.indices, id: \.self) { index in
                HStack {
                    Circle().fill(chart.points[index].color ?? .accentColor).frame(width: 10, height: 10)
                    Text(chart.points[index].label).font(.caption.weight(.medium)).frame(width: 60, alignment: .leading)
                    Slider(value: Binding(
                        get: { chart.points[index].value },
                        set: { chart.points[index].value = $0; chart.rebuild() }
                    ), in: 1...100)
                    Text("\(Int(chart.points[index].value))").font(.caption.monospacedDigit()).frame(width: 28, alignment: .trailing)
                }
            }
        }
    }
}

struct ShuffleBarsSample: View {
    @State private var chart = Chart3DViewModel(points: Chart3DData.week)
    @State private var generator = SeededValues(seed: 7)

    var body: some View {
        VStack(spacing: 12) {
            Chart3DView(viewModel: chart).frame(height: 280)
            Button {
                chart.points = chart.points.map { ChartDataPoint(label: $0.label, value: generator.next(in: 40...320)) }
                chart.rebuild()
            } label: {
                Label("Shuffle", systemImage: "shuffle").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

struct BarCountSample: View {
    @State private var chart = Chart3DViewModel(points: Array(Chart3DData.months.prefix(5)))
    @State private var count = 5

    var body: some View {
        VStack(spacing: 12) {
            Chart3DView(viewModel: chart).frame(height: 280)
            Stepper("Bars: \(count)", value: $count, in: 1...Chart3DData.months.count)
                .onChange(of: count) { _, n in
                    chart.points = Array(Chart3DData.months.prefix(n))
                    chart.rebuild()
                }
        }
    }
}

struct RangeSwitcherSample: View {
    enum Range: String, CaseIterable, Identifiable {
        case week = "Week", month = "Year", quarter = "Quarters"
        var id: String { rawValue }
        var points: [ChartDataPoint] {
            switch self {
            case .week: return Chart3DData.week
            case .month: return Chart3DData.months
            case .quarter: return Chart3DData.quarters
            }
        }
    }

    @State private var chart = Chart3DViewModel(points: Chart3DData.week)
    @State private var range = Range.week

    var body: some View {
        VStack(spacing: 12) {
            Picker("Range", selection: $range) {
                ForEach(Range.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: range) { _, newRange in
                chart.points = newRange.points
                chart.rebuild()
            }
            Chart3DView(viewModel: chart).frame(height: 280)
        }
    }
}

struct SliceToggleSample: View {
    @State private var chart = Chart3DPieViewModel(points: Chart3DData.budget, innerRadiusFraction: 0.4)
    @State private var hidden: Set<String> = []

    var body: some View {
        VStack(spacing: 14) {
            Chart3DPieView(viewModel: chart).frame(height: 260)
            FlowChips(items: Chart3DData.budget, hidden: hidden) { label in
                if hidden.contains(label) {
                    hidden.remove(label)
                } else if hidden.count < Chart3DData.budget.count - 1 {
                    hidden.insert(label)   // always leave at least one slice
                }
                chart.points = Chart3DData.budget.filter { !hidden.contains($0.label) }
                chart.rebuild()
            }
        }
    }
}

private struct FlowChips: View {
    let items: [ChartDataPoint]
    let hidden: Set<String>
    let toggle: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96))], spacing: 8) {
            ForEach(items) { item in
                let isOn = !hidden.contains(item.label)
                Button { toggle(item.label) } label: {
                    HStack(spacing: 6) {
                        Circle().fill(item.color ?? .accentColor).frame(width: 8, height: 8).opacity(isOn ? 1 : 0.3)
                        Text(item.label).font(.caption.weight(.semibold))
                    }
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
                    .background(Capsule().fill(isOn ? Color.primary.opacity(0.1) : .clear))
                    .overlay(Capsule().stroke(Color.primary.opacity(isOn ? 0 : 0.2)))
                    .foregroundStyle(isOn ? Color.primary : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
    }
}

struct PieDonutToggleSample: View {
    @State private var chart = Chart3DPieViewModel(points: Chart3DData.marketShare)
    @State private var isDonut = false

    var body: some View {
        VStack(spacing: 12) {
            Chart3DPieView(viewModel: chart).frame(height: 280)
            Toggle("Donut", isOn: $isDonut)
                .tint(.primary)
                .onChange(of: isDonut) { _, donut in
                    chart.innerRadiusFraction = donut ? 0.6 : 0
                    chart.rebuild()
                }
        }
    }
}

// MARK: - Styling

struct PaletteSwitcherSample: View {
    @State private var bars = Chart3DViewModel(points: Array(Chart3DData.week.prefix(5)))
    @State private var pie = Chart3DPieViewModel(points: Array(Chart3DData.languages.prefix(5)), innerRadiusFraction: 0.45)
    @State private var selection = 0

    var body: some View {
        VStack(spacing: 12) {
            Picker("Palette", selection: $selection) {
                ForEach(Chart3DPalettes.named.indices, id: \.self) { Text(Chart3DPalettes.named[$0].name).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: selection) { _, index in
                let theme = Chart3DPalettes.named[index].theme
                bars.theme = theme; bars.rebuild()
                pie.theme = theme; pie.rebuild()
            }
            Chart3DView(viewModel: bars).frame(height: 260)
            Chart3DPieView(viewModel: pie).frame(height: 260)
        }
    }
}

// MARK: - Dashboard cards

private struct DashboardCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: content)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.secondarySystemBackground)))
    }
}

struct RevenueCardSample: View {
    private var total: Double { Chart3DData.week.map(\.value).reduce(0, +) }

    var body: some View {
        DashboardCard {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This week").font(.subheadline).foregroundStyle(.secondary)
                    Text(total, format: .currency(code: "USD").precision(.fractionLength(0))).font(.largeTitle.bold().monospacedDigit())
                }
                Spacer()
                Label("12%", systemImage: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(Color.green.opacity(0.15)))
                    .foregroundStyle(.green)
            }
            Bars3D(Chart3DData.week, theme: Chart3DPalettes.brand, height: 260)
        }
    }
}

struct StorageCardSample: View {
    private var used: Double { Chart3DData.storage.filter { $0.label != "Free" }.map(\.value).reduce(0, +) }
    private var capacity: Double { Chart3DData.storage.map(\.value).reduce(0, +) }

    var body: some View {
        DashboardCard {
            Text("iPhone storage").font(.headline)
            Text("\(Int(used)) GB of \(Int(capacity)) GB used").font(.subheadline).foregroundStyle(.secondary)
            Pie3D(Chart3DData.storage, innerRadius: 0.6, depth: 0.4, height: 260)
            Chart3DLegend(points: Chart3DData.storage, format: { "\(Int($0)) GB" })
        }
    }
}

struct StepsCardSample: View {
    private var daysOnGoal: Int { Chart3DData.steps.filter { $0.value >= Chart3DData.stepsGoal }.count }

    var body: some View {
        DashboardCard {
            Text("Steps").font(.headline)
            Text("Goal hit \(daysOnGoal) of 7 days").font(.subheadline).foregroundStyle(.secondary)
            Bars3D(Chart3DData.steps, height: 260)
            HStack(spacing: 16) {
                Label("≥ 8,000", systemImage: "circle.fill").foregroundStyle(.green)
                Label("Under goal", systemImage: "circle.fill").foregroundStyle(.orange)
            }
            .font(.caption)
            .labelStyle(.titleAndIcon)
        }
    }
}

struct BudgetCardSample: View {
    private var total: Double { Chart3DData.budget.map(\.value).reduce(0, +) }

    var body: some View {
        DashboardCard {
            Text("September spend").font(.subheadline).foregroundStyle(.secondary)
            Text(total, format: .currency(code: "USD").precision(.fractionLength(0))).font(.title.bold().monospacedDigit())
            Pie3D(Chart3DData.budget, depth: 0.5, height: 260)
            Chart3DLegend(points: Chart3DData.budget, showsPercent: true)
        }
    }
}

struct ProgressRingsSample: View {
    private let tasks: [(name: String, done: Double, color: Color)] = [
        ("Design", 90, .purple), ("Build", 64, .blue), ("Test", 30, .orange),
    ]
    @State private var chart = Chart3DPieViewModel(points: Chart3DData.progress(90, color: .purple), innerRadiusFraction: 0.7, extrusionDepth: 0.4)
    @State private var selection = 0

    var body: some View {
        DashboardCard {
            Text("Release 2.0").font(.headline)
            Picker("Workstream", selection: $selection) {
                ForEach(tasks.indices, id: \.self) { Text(tasks[$0].name).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: selection) { _, index in
                chart.points = Chart3DData.progress(tasks[index].done, color: tasks[index].color)
                chart.rebuild()
            }
            Chart3DPieView(viewModel: chart).frame(height: 260)
            Text("\(Int(tasks[selection].done))% complete")
                .font(.title3.bold().monospacedDigit())
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Helpers

/// A tiny deterministic generator, so "Shuffle" produces the same sequence on every run.
struct SeededValues {
    private var state: UInt64
    init(seed: UInt64) { state = seed }

    mutating func next(in range: ClosedRange<Double>) -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        let unit = Double(state >> 11) / Double(1 << 53)
        return (range.lowerBound + unit * (range.upperBound - range.lowerBound)).rounded()
    }
}
