//
//  LoadersDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoLoaders

private enum LoaderKindOption: String, CaseIterable, Identifiable {
    case spinner, dots, pulse, progressRing, skeleton
    var id: Self { self }
    var label: String {
        switch self {
        case .spinner: return "Spinner"
        case .dots: return "Dots"
        case .pulse: return "Pulse"
        case .progressRing: return "Progress ring"
        case .skeleton: return "Skeleton"
        }
    }
    var kind: KitoLoaderKind {
        switch self {
        case .spinner: return .spinner
        case .dots: return .dots
        case .pulse: return .pulse
        case .progressRing: return .progressRing(fraction: 0.6)
        case .skeleton: return .skeleton
        }
    }
}

struct LoadersDemo: View {
    @State private var progress: Double = 0.35
    @State private var isSkeletonLoading = true
    @State private var pickerStyle: LoaderKindOption = .spinner

    var body: some View {
        Form {
            Section("Spinner — default") {
                row { KitoSpinner() }
            }
            Section("Spinner — sizes") {
                row {
                    HStack(spacing: 20) {
                        KitoSpinner(size: 16)
                        KitoSpinner(size: 24)
                        KitoSpinner(size: 40)
                        KitoSpinner(size: 56, lineWidth: 5)
                    }
                }
            }
            Section("Spinner — custom colors") {
                row {
                    HStack(spacing: 20) {
                        KitoSpinner(color: .red)
                        KitoSpinner(color: .green)
                        KitoSpinner(color: .purple)
                        KitoSpinner(color: .orange)
                    }
                }
            }
            Section("Dots") {
                row { KitoDotsLoader() }
            }
            Section("Dots — larger, custom color") {
                row { KitoDotsLoader(dotSize: 14, color: .indigo) }
            }
            Section("Pulse") {
                row { KitoPulseLoader() }
            }
            Section("Pulse — sizes and colors") {
                row {
                    HStack(spacing: 24) {
                        KitoPulseLoader(size: 20, color: .blue)
                        KitoPulseLoader(size: 36, color: .pink)
                        KitoPulseLoader(size: 50, color: .teal)
                    }
                }
            }
            Section("Progress ring — interactive") {
                row { KitoProgressRing(fraction: progress) }
                Slider(value: $progress, in: 0...1)
            }
            Section("Progress ring — variants") {
                row {
                    HStack(spacing: 20) {
                        KitoProgressRing(fraction: 0.25, size: 40, showsPercentage: false)
                        KitoProgressRing(fraction: 0.5, size: 56, lineWidth: 8, color: .green)
                        KitoProgressRing(fraction: 0.9, size: 72, lineWidth: 10, color: .red)
                    }
                }
            }
            Section("Skeleton") {
                Toggle("Loading", isOn: $isSkeletonLoading)
                Text("Real content once loaded")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .kitoSkeleton(isLoading: isSkeletonLoading)
                HStack {
                    Circle().fill(.gray.opacity(0.3)).frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("Title row").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Subtitle row").frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .kitoSkeleton(isLoading: isSkeletonLoading)
            }
            Section("Style-driven — pick a kind") {
                Picker("Kind", selection: $pickerStyle) {
                    ForEach(LoaderKindOption.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                row { KitoLoaderView(style: KitoLoaderStyle(kind: pickerStyle.kind, size: 32)) }
                Text("A screen configured with a single KitoLoaderStyle value can swap its loader kind app-wide.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Loaders")
    }

    private func row<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack { Spacer(); content(); Spacer() }.padding(.vertical, 8)
    }
}
