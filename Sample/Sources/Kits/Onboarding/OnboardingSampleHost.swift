//
//  OnboardingSampleHost.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoOnboarding

/// A live, swipeable onboarding in a phone-shaped frame, plus a button to run it full screen.
/// Finishing the preview flashes "Finished" and starts it over.
struct OnboardingSampleHost: View {
    let style: KitoOnboardingStyle
    let pages: () -> [KitoOnboardingPage]
    var colorScheme: ColorScheme?

    @State private var preview: KitoOnboardingViewModel
    @State private var isFullScreen = false
    @State private var showsFinished = false

    init(style: KitoOnboardingStyle = .default, colorScheme: ColorScheme? = nil, pages: @escaping () -> [KitoOnboardingPage]) {
        self.style = style
        self.pages = pages
        self.colorScheme = colorScheme
        _preview = State(initialValue: KitoOnboardingViewModel(pages: pages()))
    }

    var body: some View {
        VStack(spacing: 14) {
            KitoOnboardingView(viewModel: preview, style: style)
                .modifier(OptionalColorScheme(scheme: colorScheme))
                .frame(height: 640)
                .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 38, style: .continuous).stroke(Color.primary.opacity(0.14), lineWidth: 1))
                .overlay {
                    if showsFinished {
                        Label("Finished", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .padding(.horizontal, 18).padding(.vertical, 12)
                            .background(.regularMaterial, in: Capsule())
                            .transition(.scale.combined(with: .opacity))
                    }
                }

            Button { isFullScreen = true } label: {
                Label("Open full screen", systemImage: "arrow.up.left.and.arrow.down.right")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.primary)
        }
        .onAppear {
            preview.onFinish = {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showsFinished = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { showsFinished = false }
                    preview.currentIndex = 0
                }
            }
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenOnboarding(style: style, pages: pages(), colorScheme: colorScheme) { isFullScreen = false }
        }
    }
}

private struct FullScreenOnboarding: View {
    let style: KitoOnboardingStyle
    let colorScheme: ColorScheme?
    @State private var viewModel: KitoOnboardingViewModel

    init(style: KitoOnboardingStyle, pages: [KitoOnboardingPage], colorScheme: ColorScheme?, onFinish: @escaping () -> Void) {
        self.style = style
        self.colorScheme = colorScheme
        _viewModel = State(initialValue: KitoOnboardingViewModel(pages: pages, onFinish: onFinish))
    }

    var body: some View {
        KitoOnboardingView(viewModel: viewModel, style: style)
            .modifier(OptionalColorScheme(scheme: colorScheme))
    }
}

/// Forces a colour scheme only when a sample asks for one (e.g. an all-black design).
private struct OptionalColorScheme: ViewModifier {
    let scheme: ColorScheme?

    func body(content: Content) -> some View {
        if let scheme {
            content.environment(\.colorScheme, scheme)
        } else {
            content
        }
    }
}
