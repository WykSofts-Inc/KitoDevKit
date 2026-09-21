//
//  ChartsDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCharts

struct ChartsDemo: View {
    private let points: [ChartDataPoint] = [
        ChartDataPoint(label: "Mon", value: 120),
        ChartDataPoint(label: "Tue", value: 200),
        ChartDataPoint(label: "Wed", value: 150),
        ChartDataPoint(label: "Thu", value: 260),
        ChartDataPoint(label: "Fri", value: 190),
    ]

    @State private var line = LineChartViewModel(points: [])
    @State private var bars = BarChartViewModel(points: [])
    @State private var pie = PieChartViewModel(points: [], innerRadiusFraction: 0.6)
    @State private var chart3D = Chart3DViewModel(points: [])

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                group("Line") { LineChartView(viewModel: line).frame(height: 180) }
                group("Bar") { BarChartView(viewModel: bars).frame(height: 200) }
                group("Donut") { PieChartView(viewModel: pie).frame(height: 220) }
                group("3D bars — drag to rotate, pinch to zoom") {
                    Chart3DView(viewModel: chart3D).frame(height: 260)
                }
            }
            .padding()
        }
        .navigationTitle("Charts")
        .onAppear {
            line = LineChartViewModel(points: points)
            bars = BarChartViewModel(points: points)
            pie = PieChartViewModel(points: points, innerRadiusFraction: 0.6)
            chart3D = Chart3DViewModel(points: points)
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
        }
    }
}
