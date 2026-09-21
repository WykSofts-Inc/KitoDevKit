//
//  OrderTrackingDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoOrderTracking

struct OrderTrackingDemo: View {
    @State private var viewModel: KitoOrderTrackingViewModel

    init() {
        let simulator = KitoOrderTrackingSimulator(merchantName: "Kito Kitchen", stageDuration: 4)
        _viewModel = State(initialValue: KitoOrderTrackingViewModel(
            orderID: "demo-1",
            merchantName: simulator.merchantName,
            initial: simulator.script[0],
            refreshInterval: simulator.stageDuration,
            fetchUpdate: simulator.nextUpdate
        ))
    }

    var body: some View {
        KitoOrderTrackingScreen(viewModel: viewModel)
            .navigationTitle("Order Tracking")
            .navigationBarTitleDisplayMode(.inline)
    }
}
