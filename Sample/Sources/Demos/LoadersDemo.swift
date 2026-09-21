//
//  LoadersDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoLoaders

struct LoadersDemo: View {
    @State private var progress: Double = 0.35

    var body: some View {
        Form {
            Section("Spinner") { row { KitoSpinner() } }
            Section("Dots") { row { KitoDotsLoader() } }
            Section("Pulse") { row { KitoPulseLoader() } }
            Section("Progress ring") {
                row { KitoProgressRing(fraction: progress) }
                Slider(value: $progress, in: 0...1)
            }
            Section("Skeleton") {
                Text("Real content")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .kitoSkeleton(isLoading: true)
            }
            Section("Style-driven") {
                row { KitoLoaderView(style: KitoLoaderStyle(kind: .dots, size: 30)) }
            }
        }
        .navigationTitle("Loaders")
    }

    private func row<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack { Spacer(); content(); Spacer() }.padding(.vertical, 8)
    }
}
