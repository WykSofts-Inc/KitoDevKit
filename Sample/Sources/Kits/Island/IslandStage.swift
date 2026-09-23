//
//  IslandStage.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoIslandBar

/// A lock-screen-style wallpaper for island samples.
struct IslandWallpaper: View {
    var colors: [Color] = [Color(red: 0.16, green: 0.12, blue: 0.36), Color(red: 0.55, green: 0.2, blue: 0.5), Color(red: 0.95, green: 0.55, blue: 0.4)]

    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
            VStack(spacing: 0) {
                Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.top, 78)
                Text("9:41")
                    .font(.system(size: 86, weight: .bold, design: .rounded))
                Spacer()
            }
            .foregroundStyle(.white.opacity(0.92))
        }
    }
}

/// Shows an island activity in a phone frame, with controls for its three presentations and a
/// button to run it full screen, where it grows out of the device's real island.
struct IslandStage<Leading: View, Trailing: View, Expanded: View, Controls: View>: View {
    @Binding var presentation: KitoIslandPresentation
    var wallpaper: [Color]?
    var hint: String?
    @ViewBuilder let leading: () -> Leading
    @ViewBuilder let trailing: () -> Trailing
    @ViewBuilder let expanded: () -> Expanded
    @ViewBuilder let controls: () -> Controls

    @State private var isFullScreen = false

    var body: some View {
        VStack(spacing: 16) {
            screen(showsClose: false)
                .frame(height: 560)
                .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 44, style: .continuous).stroke(Color.primary.opacity(0.15), lineWidth: 5))

            presentationPicker
            controls()
            if let hint {
                Label(hint, systemImage: "hand.tap").font(.caption).foregroundStyle(.secondary)
            }

            Button { isFullScreen = true } label: {
                Label("Open full screen", systemImage: "arrow.up.left.and.arrow.down.right")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            screen(showsClose: true)
                .ignoresSafeArea()
                // The clock would sit under a widened island; the real island hides it too.
                .statusBarHidden()
                .overlay(alignment: .bottom) {
                    VStack(spacing: 14) {
                        presentationPicker
                        controls()
                    }
                    .padding(18)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(16)
                }
        }
    }

    private func screen(showsClose: Bool) -> some View {
        IslandWallpaper(colors: wallpaper ?? [Color(red: 0.16, green: 0.12, blue: 0.36), Color(red: 0.55, green: 0.2, blue: 0.5), Color(red: 0.95, green: 0.55, blue: 0.4)])
            .overlay(alignment: .topTrailing) {
                if showsClose {
                    Button { isFullScreen = false } label: {
                        Image(systemName: "xmark").font(.headline).padding(12).background(.ultraThinMaterial, in: Circle())
                    }
                    .foregroundStyle(.white)
                    .padding(.top, 70)
                    .padding(.trailing, 18)
                }
            }
            .kitoDynamicIsland(presentation: $presentation, leading: leading, trailing: trailing, expanded: expanded)
    }

    private var presentationPicker: some View {
        Picker("Presentation", selection: $presentation) {
            Text("Idle").tag(KitoIslandPresentation.idle)
            Text("Compact").tag(KitoIslandPresentation.compact)
            Text("Expanded").tag(KitoIslandPresentation.expanded)
        }
        .pickerStyle(.segmented)
    }
}

extension IslandStage where Controls == EmptyView {
    init(presentation: Binding<KitoIslandPresentation>, wallpaper: [Color]? = nil, hint: String? = nil,
         @ViewBuilder leading: @escaping () -> Leading, @ViewBuilder trailing: @escaping () -> Trailing, @ViewBuilder expanded: @escaping () -> Expanded) {
        self.init(presentation: presentation, wallpaper: wallpaper, hint: hint, leading: leading, trailing: trailing, expanded: expanded, controls: { EmptyView() })
    }
}

/// Plays a short-lived island moment (a connection, a payment, a toggle) and settles back.
@MainActor
func flash(_ presentation: Binding<KitoIslandPresentation>, to state: KitoIslandPresentation, for seconds: Double = 2.4) {
    presentation.wrappedValue = state
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        presentation.wrappedValue = .idle
    }
}

/// A round, filled icon button, like the system's island controls.
struct IslandRoundButton: View {
    let symbol: String
    var color: Color = Color.white.opacity(0.18)
    var foreground: Color = .white
    var size: CGFloat = 48
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(width: size, height: size)
                .background(Circle().fill(color))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
