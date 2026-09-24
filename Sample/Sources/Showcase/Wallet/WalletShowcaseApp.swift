//
//  WalletShowcaseApp.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoAuth
import KitoNavigation
import KitoToasts
import KitoNotifications
import KitoHaptics

/// Pesa: a wallet and personal-finance app built almost entirely from Kito packages.
/// Every name, number and balance is made up, and nothing leaves the device.
enum WalletShowcase {
    static let title = "Pesa"
    static let subtitle = "Wallet & money"
    static let systemImage = "creditcard.fill"
}

/// The Pesa demo, full screen: an app lock, then five tabs. Present it with `.fullScreenCover`.
struct WalletShowcaseApp: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = WalletShowcase.PesaStore()
    @State private var toasts = KitoToastCenter()
    @State private var isLocked = true

    var body: some View {
        WalletShowcase.PesaRoot(store: store, isLocked: $isLocked)
            .kitoToastHost(toasts)
            .environment(toasts)
            .environment(\.pesaExit, WalletShowcase.PesaExitAction { dismiss() })
            .autoKitoTheme()
    }
}

extension WalletShowcase {
    /// Closes the demo from anywhere inside it.
    struct PesaExitAction {
        var run: () -> Void = {}
        func callAsFunction() { run() }
    }

    struct PesaRoot: View {
        @Bindable var store: PesaStore
        @Binding var isLocked: Bool

        @Environment(\.pesaExit) private var exit
        @State private var tabs = KitoTabBarViewModel(items: [
            KitoTabItem(id: PesaTab.home.rawValue, title: "Home", systemImage: "house", selectedSystemImage: "house.fill"),
            KitoTabItem(id: PesaTab.cards.rawValue, title: "Cards", systemImage: "creditcard", selectedSystemImage: "creditcard.fill"),
            KitoTabItem(id: PesaTab.pay.rawValue, title: "Pay", systemImage: "qrcode.viewfinder"),
            KitoTabItem(id: PesaTab.insights.rawValue, title: "Insights", systemImage: "chart.pie", selectedSystemImage: "chart.pie.fill"),
            KitoTabItem(id: PesaTab.profile.rawValue, title: "Profile", systemImage: "person.crop.circle", selectedSystemImage: "person.crop.circle.fill"),
        ])
        @State private var incoming: KitoInboxNotification?
        @State private var didWelcome = false

        var body: some View {
            KitoTabContainerView(viewModel: tabs, style: .floating) { id in
                switch PesaTab(rawValue: id) ?? .home {
                case .home: PesaHomeTab(store: store) { tabs.select($0.rawValue) }
                case .cards: PesaCardsTab(store: store)
                case .pay: PesaPayTab(store: store)
                case .insights: PesaInsightsTab(store: store)
                case .profile: PesaProfileTab(store: store) { isLocked = true }
                }
            }
            .kitoNotificationBanner($incoming, style: .card) { _ in tabs.select(PesaTab.home.rawValue) }
            .kitoAppLock(isLocked: $isLocked, timeout: 60,
                         configuration: KitoAppLockConfiguration(title: "Enter your Pesa PIN", userName: "Wycliff",
                                                                 pinLength: 4, storageKey: nil)) { pin in
                pin == PesaStore.demoPIN ? .success : .failure(message: "That PIN isn’t right. The demo PIN is 1234.")
            }
            .overlay(alignment: .top) {
                if isLocked { PesaLockChrome(exit: exit.run) }
            }
            .onChange(of: isLocked) { _, locked in
                guard !locked, !didWelcome else { return }
                didWelcome = true
                welcome()
            }
        }

        /// A friend pays you back a few seconds after you unlock, so the banner, inbox and
        /// balance all get a moment to show off.
        private func welcome() {
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                guard let friend = store.contacts.first(where: { $0.name.hasPrefix("Kamau") }) else { return }
                let transaction = store.receive(1_200, from: friend, note: "Nyama choma, Saturday")
                KitoHaptics.success()
                incoming = KitoInboxNotification(kind: .payment, title: "\(friend.firstName) sent you \(PesaMoney.string(transaction.amount))",
                                                 body: transaction.note ?? "Money received", date: .now,
                                                 avatar: .initials(friend.initials, friend.color), actionTitle: "View")
            }
        }
    }

    enum PesaTab: String { case home, cards, pay, insights, profile }

    /// The demo PIN hint and an Exit button over the lock screen, so nobody gets stuck.
    private struct PesaLockChrome: View {
        let exit: () -> Void

        var body: some View {
            HStack {
                Label("Demo PIN 1234", systemImage: "key.fill")
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())
                    .accessibilityLabel("Demo PIN is 1 2 3 4")
                Spacer()
                PesaExitButton(action: exit)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}

private struct PesaExitKey: EnvironmentKey {
    static let defaultValue = WalletShowcase.PesaExitAction()
}

extension EnvironmentValues {
    /// Closes the Pesa demo.
    var pesaExit: WalletShowcase.PesaExitAction {
        get { self[PesaExitKey.self] }
        set { self[PesaExitKey.self] = newValue }
    }
}
