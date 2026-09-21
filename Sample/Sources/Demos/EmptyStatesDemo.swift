//
//  EmptyStatesDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoEmptyStates

struct EmptyStatesDemo: View {
    private enum Preset: String, CaseIterable, Identifiable {
        case noData, noResults, noConnection, error
        var id: Self { self }
    }
    @State private var preset: Preset = .noData

    var body: some View {
        VStack(spacing: 0) {
            Picker("Preset", selection: $preset) {
                ForEach(Preset.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding()

            Spacer()
            content
            Spacer()
        }
        .navigationTitle("Empty States")
    }

    @ViewBuilder private var content: some View {
        switch preset {
        case .noData: KitoEmptyStateView.noData(message: "Add your first item to see it here.")
        case .noResults: KitoEmptyStateView.noResults(query: "sneakers")
        case .noConnection: KitoEmptyStateView.noConnection {}
        case .error: KitoEmptyStateView.error(message: "Something went wrong.") {}
        }
    }
}
