//
//  ModalStage.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Runs a modal sample inside a phone-shaped frame (so the modal presents within it), with a
/// button to run the same sample full screen.
struct ModalStage<Screen: View>: View {
    @ViewBuilder let screen: () -> Screen
    @State private var isFullScreen = false

    var body: some View {
        VStack(spacing: 14) {
            screen()
                .frame(height: 620)
                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 40, style: .continuous).stroke(Color.primary.opacity(0.15), lineWidth: 5))
            Button { isFullScreen = true } label: {
                Label("Open full screen", systemImage: "arrow.up.left.and.arrow.down.right").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            screen()
                .overlay(alignment: .topTrailing) {
                    Button { isFullScreen = false } label: {
                        Image(systemName: "xmark").font(.headline).padding(12).background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 18)
                }
        }
    }
}

/// A plausible app screen behind the modal, with the button that opens it.
struct MockAppScreen<Trigger: View>: View {
    var title = "Home"
    var tint: Color = .indigo
    @ViewBuilder let trigger: () -> Trigger

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [tint.opacity(0.25), Color(.systemBackground)], startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 14) {
                Text(title).font(.largeTitle.bold()).padding(.top, 60)
                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(tint.gradient).frame(height: 150)
                    .overlay(alignment: .bottomLeading) {
                        Text("Weekend picks").font(.title3.bold()).foregroundStyle(.white).padding(16)
                    }
                ForEach(0..<3, id: \.self) { index in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12).fill(tint.opacity(0.2 + Double(index) * 0.15)).frame(width: 48, height: 48)
                        VStack(alignment: .leading, spacing: 6) {
                            Capsule().fill(Color.primary.opacity(0.18)).frame(width: 150, height: 9)
                            Capsule().fill(Color.primary.opacity(0.09)).frame(width: 90, height: 7)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            trigger().padding(.horizontal, 20).padding(.bottom, 40)
        }
    }
}
