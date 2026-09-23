//
//  EmptyStatesDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoEmptyStates

struct EmptyStatesDemo: View {
    @Environment(\.kitoTheme) private var theme

    private enum Preset: String, CaseIterable, Identifiable {
        case noData, noResults, noConnection, error, custom, stateView
        var id: Self { self }
        var label: String {
            switch self {
            case .noData: return "No data"
            case .noResults: return "No results"
            case .noConnection: return "No connection"
            case .error: return "Error"
            case .custom: return "Custom"
            case .stateView: return "KitoStateView cycle"
            }
        }
    }
    @State private var preset: Preset = .noData
    @State private var stateViewState: KitoLoadState<String> = .idle

    var body: some View {
        VStack(spacing: 0) {
            Picker("Preset", selection: $preset) {
                ForEach(Preset.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.menu)
            .tint(theme.colors.primary)
            .padding()

            Spacer()
            content
                .padding(theme.spacing.lg)
                .kitoGlassCard(cornerRadius: theme.radii.lg)
                .padding(.horizontal, theme.spacing.lg)
            Spacer()
        }
        .background(
            LinearGradient(colors: [theme.colors.background, theme.colors.primary.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationTitle("Empty States")
        .onChange(of: preset) { _, newValue in
            if newValue == .stateView { stateViewState = .idle }
        }
    }

    @ViewBuilder private var content: some View {
        switch preset {
        case .noData:
            KitoEmptyStateView.noData(message: "Add your first item to see it here.")
        case .noResults:
            KitoEmptyStateView.noResults(query: "sneakers")
        case .noConnection:
            KitoEmptyStateView.noConnection {}
        case .error:
            KitoEmptyStateView.error(message: "Something went wrong.") {}
        case .custom:
            KitoEmptyStateView(
                systemImage: "cart",
                title: "Your cart is empty",
                message: "Items you add will show up here.",
                action: KitoEmptyStateAction(title: "Browse products") {}
            )
        case .stateView:
            VStack(spacing: 16) {
                KitoStateView(stateViewState, retry: { stateViewState = .loading }) { value in
                    Text(value).font(.headline)
                }
                .frame(height: 120)

                HStack {
                    Button("Idle") { stateViewState = .idle }
                    Button("Loading") { stateViewState = .loading }
                    Button("Loaded") { stateViewState = .loaded("Here's your content!") }
                    Button("Failed") { stateViewState = .failed(NSError(domain: "Demo", code: 1, userInfo: [NSLocalizedDescriptionKey: "Something broke."])) }
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }
        }
    }
}
