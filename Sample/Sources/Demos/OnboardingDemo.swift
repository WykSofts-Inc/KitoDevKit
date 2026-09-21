//
//  OnboardingDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoOnboarding

struct OnboardingDemo: View {
    @State private var isShowing = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Tap below to launch the onboarding flow full-screen.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Button("Launch onboarding") { isShowing = true }
        }
        .navigationTitle("Onboarding")
        .fullScreenCover(isPresented: $isShowing) {
            KitoOnboardingView(viewModel: KitoOnboardingViewModel(
                pages: [
                    KitoOnboardingPage(systemImage: "bolt.fill", title: "Fast", message: "Everything loads instantly."),
                    KitoOnboardingPage(systemImage: "lock.fill", title: "Secure", message: "Your data stays yours."),
                    KitoOnboardingPage(systemImage: "checkmark.seal.fill", title: "Simple", message: "No clutter, just what you need."),
                ],
                onFinish: { isShowing = false }
            ))
        }
    }
}
