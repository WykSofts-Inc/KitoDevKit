//
//  PesaProfile.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoSettings
import KitoFileViewer
import KitoToasts
import KitoHaptics

extension WalletShowcase {
    /// Profile: account, security, notifications, statements and the way out of the demo.
    struct PesaProfileTab: View {
        @Bindable var store: PesaStore
        let lock: () -> Void

        @Environment(\.pesaExit) private var exit
        @Environment(KitoToastCenter.self) private var toasts
        @State private var topics = PesaProfileTab.defaultTopics
        @State private var quietHours = KitoSettingsQuietHours(isEnabled: false)
        @State private var autoLock = true
        @State private var roundUps = true
        @State private var travelMode = false

        var body: some View {
            NavigationStack {
                KitoSettingsList(style: .insetGrouped, tint: .primary, searchPrompt: "Search settings") {
                    KitoSettingsProfileHeader(name: PesaStore.ownerName, detail: "+254 712 ••• 678 · Nairobi", plan: "Pesa Plus",
                                              isVerified: true, tint: .primary) {
                        toasts.show("Profile editing isn’t part of the demo.", style: .info)
                    }
                } sections: {
                    KitoSettingsSection("Account") {
                        KitoNavigationRow("Statements", systemImage: "doc.text.fill", color: .indigo, subtitle: "Monthly PDFs", value: "3") {
                            PesaStatementsScreen(store: store)
                        }
                        KitoValueRow("Account number", systemImage: "number", color: .gray, value: "0100 4417 4120", isCopyable: true)
                        KitoToggleRow("Round up spare change", systemImage: "arrow.up.circle.fill", color: .green,
                                      subtitle: "Into Mombasa getaway", isOn: $roundUps)
                            .keywords("savings", "goal")
                        KitoToggleRow("Travel mode", systemImage: "airplane", color: .orange, subtitle: "Cards work abroad", isOn: $travelMode)
                    }
                    KitoSettingsSection("Security", footer: "Face ID confirms every send and payment. The demo PIN is 1234.") {
                        KitoToggleRow("Face ID for payments", systemImage: "faceid", color: .green, isOn: $store.confirmsWithBiometrics)
                        KitoToggleRow("Lock when I leave the app", systemImage: "lock.fill", color: .blue, isOn: $autoLock)
                        KitoActionRow("Lock Pesa now", systemImage: "lock.rotation", color: .indigo) {
                            KitoHaptics.impact(.medium)
                            lock()
                        }
                        KitoActionRow("Change PIN", systemImage: "key.fill", color: .gray, showsChevron: true) {
                            toasts.show("The demo PIN stays 1234.", style: .info)
                        }
                    }
                    KitoSettingsSection("Preferences") {
                        KitoNavigationRow("Notifications", systemImage: "bell.badge.fill", color: .red,
                                          value: "\(topics.filter(\.isOn).count) on") {
                            KitoNotificationSettings(topics: $topics, quietHours: $quietHours, channels: [.push, .email, .sms])
                                .navigationTitle("Notifications")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                        KitoToggleRow("Hide balances", systemImage: "eye.slash.fill", color: .purple, isOn: $store.isBalanceHidden)
                    }
                    KitoSettingsSection("About") {
                        KitoValueRow("Version", systemImage: "info.circle.fill", color: .gray, value: "1.0 (demo)")
                        KitoInfoRow("Pesa is a demo built from Kito packages. No money moves, and nothing leaves this device.")
                        KitoActionRow("Exit demo", systemImage: "xmark.circle.fill", role: .destructive) { exit() }
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .pesaExitToolbar()
            }
        }

        private static let defaultTopics: [KitoNotificationTopic] = [
            KitoNotificationTopic("payments", title: "Money in and out", subtitle: "Every send, payment and top up", systemImage: "arrow.left.arrow.right",
                                  color: .green, channels: [.push]),
            KitoNotificationTopic("security", title: "Security", subtitle: "New sign-ins and card use abroad", systemImage: "lock.shield.fill",
                                  color: .red, channels: [.push, .sms]),
            KitoNotificationTopic("budgets", title: "Budgets", subtitle: "When you pass 80% of a budget", systemImage: "chart.pie.fill",
                                  color: .purple, channels: [.push]),
            KitoNotificationTopic("goals", title: "Savings goals", subtitle: "Weekly progress", systemImage: "target",
                                  color: .blue, isOn: false, channels: [.email]),
            KitoNotificationTopic("offers", title: "Offers", subtitle: "Cashback from shops near you", systemImage: "gift.fill",
                                  color: .orange, isOn: false, channels: [.email]),
        ]
    }

    /// Monthly statements as real PDFs made on the device, in a KitoFileViewer list.
    private struct PesaStatementsScreen: View {
        let store: PesaStore

        @State private var model: KitoFileBrowserModel?
        @State private var preview: KitoFileItem?

        var body: some View {
            Group {
                if let model {
                    KitoFileList(model: model, options: KitoFileBrowserOptions(showsBreadcrumbs: false, showsSearch: false,
                                                                                allowsDelete: false, allowsMove: false,
                                                                                emptyTitle: "No statements yet")) { file in
                        preview = file
                    }
                } else {
                    ProgressView("Preparing statements…").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Statements")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $preview) { KitoFilePreview($0) }
            .task { if model == nil { model = makeModel() } }
        }

        private func makeModel() -> KitoFileBrowserModel {
            let calendar = Calendar.current
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) ?? .now
            let files: [KitoFileItem] = (0..<3).compactMap { offset in
                guard let month = calendar.date(byAdding: .month, value: -offset, to: start),
                      let url = PesaDocuments.statementPDF(month: month, transactions: store.transactions(inMonthOf: month)) else { return nil }
                let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? nil
                let end = offset == 0 ? Date.now : (calendar.date(byAdding: DateComponents(month: 1, day: -1), to: month) ?? month)
                let name = offset == 0 ? "\(month.formatted(.dateTime.month(.wide).year())) (so far).pdf" : url.lastPathComponent
                return KitoFileItem(name: name, url: url, size: size, modified: end, kind: .pdf)
            }
            return KitoFileBrowserModel(root: KitoFolder(name: "Statements", files: files), sort: .newest)
        }
    }
}
