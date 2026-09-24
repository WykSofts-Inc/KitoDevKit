//
//  FashionLaunch.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoAuth
import KitoLoaders
import KitoProduct
import KitoToasts

// MARK: - Splash

/// The wordmark opening up letter by letter over ink, then on to sign-in or the shop.
struct FashionSplash: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let onFinish: () -> Void
    @State private var revealed = false

    var body: some View {
        ZStack {
            FashionPalette.ink.ignoresSafeArea()
            VStack(spacing: 18) {
                Text("MAISON AMANI")
                    .font(.system(size: 26, weight: .regular, design: .serif))
                    .tracking(revealed ? 9 : 2)
                    .foregroundStyle(FashionPalette.ivory)
                    .opacity(revealed ? 1 : 0)
                    .scaleEffect(revealed || reduceMotion ? 1 : 0.94)
                Rectangle()
                    .fill(FashionPalette.gold)
                    .frame(width: revealed ? 120 : 0, height: 1)
                Text("NAIROBI · LAMU · ZANZIBAR")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(3)
                    .foregroundStyle(FashionPalette.ivory.opacity(0.6))
                    .opacity(revealed ? 1 : 0)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Maison Amani")
        }
        .task {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 1.1)) { revealed = true }
            try? await Task.sleep(nanoseconds: reduceMotion ? 700_000_000 : 1_900_000_000)
            onFinish()
        }
    }
}

// MARK: - Welcome

/// KitoAuth's welcome screen over a campaign image, with a skippable "Browse as guest".
struct FashionWelcome: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.fashionExit) private var exit
    @State private var backdrop: Image?
    @State private var signingIn = false

    var body: some View {
        KitoWelcomeScreen(title: "Maison Amani", subtitle: "Luxury, made on the coast.",
                          style: backdrop.map { .photo($0) } ?? .gradient([FashionPalette.ink, FashionPalette.cognac, FashionPalette.gold]),
                          providers: [.apple, .google, .email], tint: FashionPalette.ivory,
                          onProvider: { provider in signIn(provider) },
                          onSignIn: { signIn(.email) })
            .overlay(alignment: .top) { topBar }
            .kitoLoadingOverlay(isPresented: signingIn, message: "Signing you in", detail: "A demo account, nothing leaves the device")
            .onAppear(perform: renderBackdrop)
    }

    private var topBar: some View {
        HStack {
            Button { exit() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("Exit demo")
            Spacer()
            Button("Browse as guest") {
                store.phase = .shopping
            }
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 16)
            .frame(height: 38)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .foregroundStyle(.white)
        .environment(\.colorScheme, .dark)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func renderBackdrop() {
        guard backdrop == nil else { return }
        let art = KitoProductArtwork(.dress, primary: FashionPalette.sand, accent: FashionPalette.gold,
                                     backdrop: Color(red: 0.55, green: 0.42, blue: 0.34), framing: .angled)
        if let image = art.renderedImage(size: CGSize(width: 430, height: 932)) {
            backdrop = Image(uiImage: image)
        }
    }

    private func signIn(_ provider: KitoAuthProvider) {
        guard !signingIn else { return }
        signingIn = true
        Task {
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            store.signIn(name: "Zawadi Njeri", email: provider == .apple ? "zawadi@privaterelay.example" : "zawadi@example.com")
            signingIn = false
            store.phase = .shopping
            store.toasts.show(KitoToast(title: "Karibu, Zawadi", message: "Your bag and wishlist are ready.",
                                        icon: .custom("sparkles"), accentColor: FashionPalette.gold))
        }
    }
}
