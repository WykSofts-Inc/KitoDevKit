//
//  OnboardingDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoOnboarding

struct OnboardingDemo: View {
    @State private var isShowingThreePage = false
    @State private var isShowingTwoPage = false
    @State private var isShowingFivePage = false
    @State private var lastResult = "Not launched yet"

    var body: some View {
        Form {
            Section("Standard — 3 pages") {
                Button("Launch") { isShowingThreePage = true }
            }
            Section("Minimal — 2 pages") {
                Button("Launch") { isShowingTwoPage = true }
            }
            Section("Long — 5 pages") {
                Button("Launch") { isShowingFivePage = true }
            }
            Section("Last result") {
                Text(lastResult).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Onboarding")
        .fullScreenCover(isPresented: $isShowingThreePage) {
            KitoOnboardingView(viewModel: KitoOnboardingViewModel(
                pages: [
                    KitoOnboardingPage(systemImage: "bolt.fill", title: "Fast", message: "Everything loads instantly."),
                    KitoOnboardingPage(systemImage: "lock.fill", title: "Secure", message: "Your data stays yours."),
                    KitoOnboardingPage(systemImage: "checkmark.seal.fill", title: "Simple", message: "No clutter, just what you need."),
                ],
                onFinish: { isShowingThreePage = false; lastResult = "Finished the 3-page flow" }
            ))
        }
        .fullScreenCover(isPresented: $isShowingTwoPage) {
            KitoOnboardingView(viewModel: KitoOnboardingViewModel(
                pages: [
                    KitoOnboardingPage(systemImage: "hand.wave.fill", title: "Welcome", message: "Let's get you set up."),
                    KitoOnboardingPage(systemImage: "arrow.right.circle.fill", title: "Ready", message: "You're all set."),
                ],
                onFinish: { isShowingTwoPage = false; lastResult = "Finished the 2-page flow" }
            ))
        }
        .fullScreenCover(isPresented: $isShowingFivePage) {
            KitoOnboardingView(viewModel: KitoOnboardingViewModel(
                pages: [
                    KitoOnboardingPage(systemImage: "1.circle.fill", title: "Step one", message: "Create your account."),
                    KitoOnboardingPage(systemImage: "2.circle.fill", title: "Step two", message: "Verify your phone number."),
                    KitoOnboardingPage(systemImage: "3.circle.fill", title: "Step three", message: "Add a payment method."),
                    KitoOnboardingPage(systemImage: "4.circle.fill", title: "Step four", message: "Set your preferences."),
                    KitoOnboardingPage(systemImage: "checkmark.circle.fill", title: "Done", message: "You're ready to go."),
                ],
                onFinish: { isShowingFivePage = false; lastResult = "Finished the 5-page flow" }
            ))
        }
    }
}
