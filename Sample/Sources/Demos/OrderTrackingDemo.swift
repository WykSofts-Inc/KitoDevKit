//
//  OrderTrackingDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoOrderTracking

// MARK: - Sample data per stage — lets every stage be triggered on demand

private let etaSample = Date().addingTimeInterval(18 * 60)

private let stageSamples: [(stage: KitoOrderStage, update: KitoOrderUpdate)] = [
    (.placed, KitoOrderUpdate(stage: .placed, detail: "We've received your order.")),
    (.confirmed, KitoOrderUpdate(stage: .confirmed, detail: "Kito Kitchen confirmed your order.")),
    (.preparing, KitoOrderUpdate(stage: .preparing, detail: "Your order is being prepared.", estimatedArrival: etaSample)),
    (.outForDelivery, KitoOrderUpdate(stage: .outForDelivery, detail: "Amara is on the way.", estimatedArrival: etaSample, courierName: "Amara M.")),
    (.delivered, KitoOrderUpdate(stage: .delivered, detail: "Delivered — enjoy!", courierName: "Amara M.")),
    (.cancelled, KitoOrderUpdate(stage: .cancelled, detail: "This order was cancelled.")),
]

// MARK: - Top-level catalog

struct OrderTrackingDemo: View {
    var body: some View {
        List {
            NavigationLink("Manual stage control") { ManualStageDemo() }
            NavigationLink("Style variants") { OrderTrackingStyleVariantsDemo() }
            NavigationLink("Auto-refreshing simulator") { AutoRefreshDemo() }
        }
        .navigationTitle("Order Tracking")
    }
}

// MARK: - Manual stage control — the primary, directly-triggerable demo

private struct ManualStageDemo: View {
    @State private var viewModel = KitoOrderTrackingViewModel(
        orderID: "manual-demo",
        merchantName: "Kito Kitchen",
        initial: stageSamples[0].update,
        refreshInterval: 999_999, // effectively never auto-advances — this screen is manually driven
        fetchUpdate: { stageSamples[0].update }
    )

    var body: some View {
        VStack(spacing: 0) {
            // Every stage, one tap away — including .cancelled, which the
            // auto-refreshing simulator never reaches on its own.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(stageSamples, id: \.stage) { sample in
                        Button(sample.stage.defaultLabel) {
                            viewModel.setUpdate(sample.update)
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.update.stage == sample.stage ? Color.accentColor : Color.gray.opacity(0.15),
                            in: Capsule()
                        )
                        .foregroundStyle(viewModel.update.stage == sample.stage ? .white : .primary)
                    }
                }
                .padding()
            }
            Divider()
            KitoOrderTrackingScreen(viewModel: viewModel, startsTrackingOnAppear: false)
        }
        .navigationTitle("Tap a stage above")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Style variants — every customization axis KitoOrderTrackingStyle supports

private struct OrderTrackingStyleVariantsDemo: View {
    var body: some View {
        List {
            NavigationLink("Default style") {
                StyledExample(style: .default)
            }
            NavigationLink("Custom accent + fonts") {
                StyledExample(style: KitoOrderTrackingStyle(
                    accentColor: .orange,
                    headlineFont: .system(size: 22, weight: .heavy, design: .rounded),
                    detailFont: .system(size: 14, weight: .medium)
                ))
            }
            NavigationLink("Custom stage labels + icons") {
                StyledExample(style: KitoOrderTrackingStyle(
                    accentColor: .purple,
                    stageLabels: [
                        .placed: "Order received",
                        .confirmed: "Kitchen confirmed",
                        .preparing: "Cooking now",
                        .outForDelivery: "Rider en route",
                        .delivered: "Enjoy your meal!",
                    ],
                    stageIcons: [
                        .preparing: "flame.fill",
                        .outForDelivery: "scooter",
                    ]
                ))
            }
            NavigationLink("Compact timeline") {
                StyledExample(style: KitoOrderTrackingStyle(accentColor: .green, compactTimeline: true))
            }
            NavigationLink("No ETA, no courier row") {
                StyledExample(style: KitoOrderTrackingStyle(showsCourierRow: false, showsETA: false))
            }
            NavigationLink("Large corner radius, teal") {
                StyledExample(style: KitoOrderTrackingStyle(accentColor: .teal, cornerRadius: 32))
            }
        }
        .navigationTitle("Style variants")
    }
}

private struct StyledExample: View {
    let style: KitoOrderTrackingStyle
    @State private var viewModel = KitoOrderTrackingViewModel(
        orderID: "style-demo",
        merchantName: "Kito Kitchen",
        initial: stageSamples[3].update, // .outForDelivery — shows ETA + courier row
        refreshInterval: 999_999,
        fetchUpdate: { stageSamples[3].update }
    )

    var body: some View {
        KitoOrderTrackingScreen(viewModel: viewModel, style: style, startsTrackingOnAppear: false)
    }
}

// MARK: - Auto-refreshing simulator (the original scripted end-to-end demo)

private struct AutoRefreshDemo: View {
    @State private var viewModel: KitoOrderTrackingViewModel

    init() {
        let simulator = KitoOrderTrackingSimulator(merchantName: "Kito Kitchen", stageDuration: 4)
        _viewModel = State(initialValue: KitoOrderTrackingViewModel(
            orderID: "auto-demo",
            merchantName: simulator.merchantName,
            initial: simulator.script[0],
            refreshInterval: simulator.stageDuration,
            fetchUpdate: simulator.nextUpdate
        ))
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Advances through every stage automatically, every 4 seconds, using KitoOrderTrackingSimulator.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            KitoOrderTrackingScreen(viewModel: viewModel)
        }
        .navigationTitle("Auto-refreshing")
        .navigationBarTitleDisplayMode(.inline)
    }
}
