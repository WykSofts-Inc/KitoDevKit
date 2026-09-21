//
//  ConnectivityDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoConnectivity

struct ConnectivityDemo: View {
    @State private var monitor = KitoConnectivityMonitor()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: monitor.isOnline ? "wifi" : "wifi.slash")
                .font(.system(size: 56))
                .foregroundStyle(monitor.isOnline ? .green : .red)
            Text(monitor.isOnline ? "Online" : "Offline")
                .font(.title2.bold())
            Text("Connection: \(connectionLabel)")
                .foregroundStyle(.secondary)
            Text("Turn on Airplane Mode in the simulator's paired device settings, or toggle your Mac's network, to see this update live.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Connectivity")
        .kitoOfflineBanner(monitor)
    }

    private var connectionLabel: String {
        switch monitor.connectionType {
        case .wifi: return "Wi-Fi"
        case .cellular: return "Cellular"
        case .wiredEthernet: return "Ethernet"
        case .unknown: return "Unknown"
        }
    }
}
