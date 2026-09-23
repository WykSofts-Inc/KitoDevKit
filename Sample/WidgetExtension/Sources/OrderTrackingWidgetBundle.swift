//
//  OrderTrackingWidgetBundle.swift
//  OrderTrackingWidgetExtension
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//
//  This is the ~20 lines of Xcode-side glue documented in
//  KitoOrderTracking/docs/INTEGRATION.md — every visual piece is defined
//  once in KitoOrderTracking's KitoOrderLiveActivityViews.swift and reused
//  here; this file only registers them with ActivityConfiguration.

import WidgetKit
import SwiftUI
import KitoOrderTracking

struct OrderTrackingWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: KitoOrderTrackingAttributes.self) { context in
            KitoOrderLockScreenView(
                merchantName: context.attributes.merchantName,
                state: context.state
            )
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    KitoOrderIslandExpandedView(
                        merchantName: context.attributes.merchantName,
                        state: context.state
                    )
                }
            } compactLeading: {
                KitoOrderIslandCompactLeadingView(state: context.state)
            } compactTrailing: {
                KitoOrderIslandCompactTrailingView(state: context.state)
            } minimal: {
                KitoOrderIslandMinimalView(state: context.state)
            }
        }
    }
}

@main
struct OrderTrackingWidgetBundle: WidgetBundle {
    var body: some Widget {
        OrderTrackingWidget()
        KitoStatsWidget()
        KitoRingsWidget()
        KitoCountdownWidget()
        KitoTasksWidget()
        KitoWaterWidget()
    }
}
