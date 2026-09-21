//
//  MediaPickerDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoMediaPicker

struct MediaPickerDemo: View {
    @State private var picker = KitoMediaPickerViewModel()

    var body: some View {
        VStack(spacing: 20) {
            KitoAvatarPicker(viewModel: picker, size: 140)
            Text("Tap the avatar — Photo Library, Camera, Files, Clipboard, and URL download are all wired up.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if case .loaded(let asset) = picker.state {
                Text("Loaded from: \(asset.source.label)")
                    .font(.caption.bold())
            }
        }
        .padding()
        .navigationTitle("Media Picker")
    }
}
