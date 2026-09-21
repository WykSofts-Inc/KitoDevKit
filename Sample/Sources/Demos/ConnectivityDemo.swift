//
//  ConnectivityDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoConnectivity

/// KitoConnectivityMonitor deliberately wraps the REAL system network
/// signal — that's its whole reason to exist (KitoNetKit is the simulated
/// counterpart, for request-level testing, not for faking this OS signal).
/// So it can't be toggled from code. This demo screen offers its own local
/// "Simulated" mode purely for interactive testing here — flip it to see
/// every visual state without touching your Mac's actual network.
private enum SimulatedConnection: String, CaseIterable, Identifiable {
    case live, online, offlineState, cellular
    var id: Self { self }
    var label: String {
        switch self {
        case .live: return "Live (real signal)"
        case .online: return "Simulated: Online (Wi-Fi)"
        case .offlineState: return "Simulated: Offline"
        case .cellular: return "Simulated: Online (Cellular)"
        }
    }
}

struct ConnectivityDemo: View {
    @State private var monitor = KitoConnectivityMonitor()
    @State private var simulated: SimulatedConnection = .live

    var body: some View {
        VStack(spacing: 20) {
            Picker("Mode", selection: $simulated) {
                ForEach(SimulatedConnection.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.menu)

            Image(systemName: displayIsOnline ? "wifi" : "wifi.slash")
                .font(.system(size: 56))
                .foregroundStyle(displayIsOnline ? .green : .red)
            Text(displayIsOnline ? "Online" : "Offline")
                .font(.title2.bold())
            Text("Connection: \(displayConnectionLabel)")
                .foregroundStyle(.secondary)

            if simulated == .live {
                Text("This is the real KitoConnectivityMonitor signal. Turn on Airplane Mode in the simulator's paired device settings, or toggle your Mac's network, to see it change.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                Text("Simulated for this screen only — KitoConnectivityMonitor itself always reports the real signal; this picker overrides only what's displayed below.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
        .padding()
        .navigationTitle("Connectivity")
        .overlay(alignment: .top) {
            if !displayIsOnline {
                offlineBanner
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: displayIsOnline)
    }

    private var displayIsOnline: Bool {
        switch simulated {
        case .live: return monitor.isOnline
        case .online, .cellular: return true
        case .offlineState: return false
        }
    }

    private var displayConnectionLabel: String {
        switch simulated {
        case .live:
            switch monitor.connectionType {
            case .wifi: return "Wi-Fi"
            case .cellular: return "Cellular"
            case .wiredEthernet: return "Ethernet"
            case .unknown: return "Unknown"
            }
        case .online: return "Wi-Fi (simulated)"
        case .cellular: return "Cellular (simulated)"
        case .offlineState: return "None (simulated)"
        }
    }

    private var offlineBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi.slash")
            Text("You're offline")
        }
        .font(.caption.bold())
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(.red)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
