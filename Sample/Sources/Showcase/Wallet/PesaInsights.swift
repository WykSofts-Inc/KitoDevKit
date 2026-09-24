//
//  PesaInsights.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCharts
import KitoNavigation
import KitoFormatting

extension WalletShowcase {
    /// Insights: a month at a glance with a category donut, weekly bars, a six-month trend and budgets.
    struct PesaInsightsTab: View {
        @Bindable var store: PesaStore

        @State private var monthTitle = ""
        @State private var pie = PieChartViewModel(points: [], innerRadiusFraction: 0.64)
        @State private var bars = BarChartViewModel(points: [])
        @State private var trend = LineChartViewModel(points: [])

        /// The three months with data, oldest first.
        private var months: [Date] {
            let calendar = Calendar.current
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) ?? .now
            return (0..<3).reversed().compactMap { calendar.date(byAdding: .month, value: -$0, to: start) }
        }

        private var month: Date { months.first { title(for: $0) == monthTitle } ?? months.last ?? .now }
        private var previousMonth: Date { Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month }
        private var spending: [(category: PesaCategory, amount: Double)] { store.spending(inMonthOf: month) }
        private var total: Double { spending.map(\.amount).reduce(0, +) }

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        KitoTopTabs(months.map(title(for:)), selection: $monthTitle, style: .pill, tint: .primary)
                        insight
                        donut
                        weekly
                        trendCard
                        budgets
                    }
                    .padding(16)
                    .padding(.bottom, 16)
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle("Insights")
                .pesaExitToolbar()
                .kitoChartTheme(KitoChartTheme(categoricalPalette: PesaCategory.spending.map(\.color), animationDuration: 0.8))
                .onAppear {
                    if monthTitle.isEmpty, let last = months.last { monthTitle = title(for: last) }
                    refresh()
                }
                .onChange(of: monthTitle) { _, _ in refresh() }
                .onChange(of: store.transactions.count) { _, _ in refresh() }
            }
        }

        // MARK: Cards

        @ViewBuilder private var insight: some View {
            let previous = store.totalSpent(inMonthOf: previousMonth)
            if previous > 0 {
                let change = total / previous - 1
                let drops = PesaCategory.spending.map { category in
                    (category, amount(category, in: month) - amount(category, in: previousMonth))
                }
                let biggest = drops.min { $0.1 < $1.1 }
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: change <= 0 ? "leaf.fill" : "flame.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(change <= 0 ? PesaStyle.positive : .orange, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    VStack(alignment: .leading, spacing: 6) {
                        Text("You spent \(KitoNumberFormatting.percent(abs(change))) \(change <= 0 ? "less" : "more") than \(fullMonth(previousMonth))")
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                        if let biggest, biggest.1 < 0 {
                            Text("\(biggest.0.title) fell the most, down \(PesaMoney.string(-biggest.1, cents: .never)).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        KitoChangeBadge(change, fractionDigits: 0, invertsColors: true)
                    }
                    Spacer(minLength: 0)
                }
                .pesaSurface()
                .accessibilityElement(children: .combine)
            } else if let top = spending.first {
                Label("\(top.category.title) was your biggest spend in \(fullMonth(month)).", systemImage: top.category.systemImage)
                    .font(.headline)
                    .pesaSurface()
            }
        }

        private var donut: some View {
            VStack(alignment: .leading, spacing: 16) {
                PesaSectionHeader(title: "Where it went")
                ZStack {
                    PieChartView(viewModel: pie, showLegend: false)
                        .frame(height: 220)
                    if pie.selectedSliceID == nil {
                        VStack(spacing: 2) {
                            Text("Spent").font(.caption).foregroundStyle(.secondary)
                            Text(PesaMoney.compact(total))
                                .font(.title2.weight(.bold))
                                .monospacedDigit()
                        }
                        .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Spending by category, \(PesaMoney.string(total, cents: .never)) in total")

                VStack(spacing: 10) {
                    ForEach(spending, id: \.category) { item in
                        HStack(spacing: 10) {
                            Image(systemName: item.category.systemImage)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(item.category.color)
                                .frame(width: 28, height: 28)
                                .background(item.category.color.opacity(0.15), in: Circle())
                            Text(item.category.title).font(.subheadline.weight(.medium))
                            Spacer()
                            Text(KitoNumberFormatting.percent(total > 0 ? item.amount / total : 0))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(PesaMoney.string(item.amount, cents: .never))
                                .font(.subheadline.weight(.semibold))
                                .monospacedDigit()
                                .frame(minWidth: 92, alignment: .trailing)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            .pesaSurface()
        }

        private var weekly: some View {
            VStack(alignment: .leading, spacing: 12) {
                PesaSectionHeader(title: "Week by week")
                BarChartView(viewModel: bars, cornerRadius: 8) { KitoNumberFormatting.compact($0) }
                    .frame(height: 180)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Spending by week")
                    .accessibilityValue(bars.points.map { "\($0.label), \(PesaMoney.string($0.value, cents: .never))" }.joined(separator: "; "))
            }
            .pesaSurface()
        }

        private var trendCard: some View {
            let average = trend.points.isEmpty ? 0 : trend.points.map(\.value).reduce(0, +) / Double(trend.points.count)
            return VStack(alignment: .leading, spacing: 12) {
                PesaSectionHeader(title: "Six-month trend")
                Text("Average \(PesaMoney.compact(average)) a month")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                LineChartView(viewModel: trend,
                              style: LineChartStyle(interpolation: .catmullRom, lineWidth: 3, points: .lastPoint, area: .gradient(opacity: 0.25),
                                                    strokeGradient: [PesaStyle.brand.opacity(0.6), PesaStyle.brand],
                                                    showsLabels: true, includesZero: true,
                                                    referenceLines: [LineReferenceLine("Average", value: average, color: .secondary)]),
                              showLegend: false) { KitoNumberFormatting.compact($0) }
                    .frame(height: 200)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Monthly spending trend")
                    .accessibilityValue(trend.points.map { "\($0.label), \(PesaMoney.compact($0.value))" }.joined(separator: "; "))
            }
            .pesaSurface()
        }

        private var budgets: some View {
            VStack(alignment: .leading, spacing: 14) {
                PesaSectionHeader(title: "Budgets")
                ForEach(store.budgets) { budget in
                    let spent = amount(budget.category, in: month)
                    let fraction = budget.limit > 0 ? spent / budget.limit : 0
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(budget.category.title, systemImage: budget.category.systemImage)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(PesaMoney.compact(spent)) of \(PesaMoney.compact(budget.limit))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        PesaProgressBar(fraction: fraction, color: budget.category.color)
                        Text(fraction > 1 ? "\(PesaMoney.string(spent - budget.limit, cents: .never)) over" : "\(PesaMoney.string(budget.limit - spent, cents: .never)) left")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(fraction > 1 ? .red : .secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .pesaSurface()
        }

        // MARK: Data

        private func refresh() {
            pie.points = spending.map { ChartDataPoint(label: $0.category.title, value: $0.amount, color: $0.category.color) }
            pie.selectedSliceID = nil

            let calendar = Calendar.current
            var weeks = [0.0, 0, 0, 0, 0]
            for transaction in store.transactions(inMonthOf: month) where !transaction.isIncoming {
                let day = calendar.component(.day, from: transaction.date)
                weeks[min((day - 1) / 7, 4)] += -transaction.amount
            }
            let peak = weeks.max() ?? 0
            bars.points = weeks.enumerated().map { index, value in
                ChartDataPoint(label: "Wk \(index + 1)", value: value,
                               color: value == peak && peak > 0 ? PesaStyle.brand : Color.primary.opacity(0.22))
            }

            // Three earlier months come from before the demo data starts.
            let earlier = [78_400.0, 91_250, 69_800]
            let firstMonth = months.first ?? .now
            var points: [ChartDataPoint] = earlier.enumerated().compactMap { index, value in
                guard let date = calendar.date(byAdding: .month, value: index - 3, to: firstMonth) else { return nil }
                return ChartDataPoint(label: shortMonth(date), value: value)
            }
            points += months.map { ChartDataPoint(label: shortMonth($0), value: store.totalSpent(inMonthOf: $0)) }
            trend.points = points
        }

        private func amount(_ category: PesaCategory, in month: Date) -> Double {
            store.spending(inMonthOf: month).first { $0.category == category }?.amount ?? 0
        }

        private func title(for date: Date) -> String { date.formatted(.dateTime.month(.abbreviated)) }
        private func shortMonth(_ date: Date) -> String { date.formatted(.dateTime.month(.abbreviated)) }
        private func fullMonth(_ date: Date) -> String { date.formatted(.dateTime.month(.wide)) }
    }
}
