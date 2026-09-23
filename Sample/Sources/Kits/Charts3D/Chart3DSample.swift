//
//  Chart3DSample.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCharts

enum Chart3DCategory: String, CaseIterable, Identifiable {
    case bars = "3D bars"
    case pies = "3D pies"
    case donuts = "3D donuts"
    case interactive = "Live & interactive"
    case styling = "Palettes & styling"
    case dashboards = "Dashboard cards"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .bars: return "chart.bar.fill"
        case .pies: return "chart.pie.fill"
        case .donuts: return "circle.circle"
        case .interactive: return "hand.draw"
        case .styling: return "paintpalette"
        case .dashboards: return "rectangle.grid.1x2"
        }
    }
}

struct Chart3DSample: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: Chart3DCategory
    let code: String
    let view: () -> AnyView

    init<V: View>(_ title: String, _ subtitle: String, category: Chart3DCategory, code: String, @ViewBuilder view: @escaping () -> V) {
        self.title = title; self.subtitle = subtitle; self.category = category; self.code = code
        self.view = { AnyView(view()) }
    }
}

// MARK: - Hosts

/// Holds a bar-chart view model in `@State` so the scene is built once. Building it inline in a
/// `body` would rebuild the SceneKit scene, and reset the camera the user rotated, on every render.
/// Keep heights at 260 or more: the 3D views set `minHeight: 260` themselves and overflow a
/// smaller frame.
struct Bars3D: View {
    @State private var viewModel: Chart3DViewModel
    var height: CGFloat

    init(_ points: [ChartDataPoint], theme: KitoChartTheme = .default, height: CGFloat = 300) {
        _viewModel = State(initialValue: Chart3DViewModel(points: points, theme: theme))
        self.height = height
    }

    var body: some View {
        Chart3DView(viewModel: viewModel).frame(height: height)
    }
}

/// The pie/donut counterpart of `Bars3D`.
struct Pie3D: View {
    @State private var viewModel: Chart3DPieViewModel
    var height: CGFloat

    init(_ points: [ChartDataPoint], innerRadius: Double = 0, depth: Double = 0.6, theme: KitoChartTheme = .default, height: CGFloat = 300) {
        _viewModel = State(initialValue: Chart3DPieViewModel(points: points, innerRadiusFraction: innerRadius, extrusionDepth: depth, theme: theme))
        self.height = height
    }

    var body: some View {
        Chart3DPieView(viewModel: viewModel).frame(height: height)
    }
}

/// A colour-keyed legend for the 3D charts, which draw none of their own. Colours come from the
/// same place the chart takes them: the point's own colour, else the theme's palette by index.
struct Chart3DLegend: View {
    let points: [ChartDataPoint]
    var theme: KitoChartTheme = .default
    var showsPercent = false
    var format: (Double) -> String = { $0.formatted(.number.precision(.fractionLength(0))) }

    private var total: Double { points.map(\.value).reduce(0, +) }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), alignment: .leading)], alignment: .leading, spacing: 8) {
            ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                HStack(spacing: 8) {
                    Circle()
                        .fill(point.color ?? theme.color(forCategoryIndex: index))
                        .frame(width: 10, height: 10)
                    Text(point.label).font(.caption.weight(.medium))
                    Spacer(minLength: 4)
                    Text(showsPercent && total > 0
                         ? (point.value / total).formatted(.percent.precision(.fractionLength(0)))
                         : format(point.value))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

/// A one-line caption under a chart, used to say what to try.
struct Chart3DHint: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Label(text, systemImage: "hand.draw")
            .font(.caption2)
            .foregroundStyle(.secondary)
    }
}
