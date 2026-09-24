//
//  FoodAccountView.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoSettings
import KitoNotifications

extension FoodShowcase {

    /// The account, built with KitoSettings, with the notification inbox from KitoNotifications.
    struct FoodAccountTab: View {
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme
        @State private var changesAddress = false

        private var unread: Int { store.inbox.filter { !$0.isRead }.count }

        var body: some View {
            @Bindable var store = store
            NavigationStack {
                KitoSettingsList(style: .insetGrouped, searchPrompt: nil) {
                    KitoSettingsProfileHeader(name: "Wycliff N", detail: "+254 712 345 678", plan: "Chakula Plus",
                                              isVerified: true, layout: .centered)
                } sections: {
                    KitoSettingsSection("Delivery") {
                        KitoActionRow("Delivery address", systemImage: "house.fill", color: .indigo,
                                      subtitle: "\(store.address.area) · \(store.address.line)", showsChevron: true) {
                            changesAddress = true
                        }
                        KitoNavigationRow("Notifications", systemImage: "bell.badge.fill", color: .red,
                                          value: unread > 0 ? "\(unread) new" : nil) {
                            FoodInboxScreen()
                                .environment(store)
                                .kitoTheme(theme)
                        }
                        KitoValueRow("Favourites", systemImage: "heart.fill", color: FoodPalette.pepper,
                                     subtitle: store.favourites.compactMap { FoodData.restaurant(id: $0)?.name }.sorted().joined(separator: ", "),
                                     value: "\(store.favourites.count)")
                    }
                    KitoSettingsSection("Payment", footer: "M-Pesa payments are simulated in this demo — nothing is charged.") {
                        KitoValueRow("M-Pesa", systemImage: "iphone.gen3", color: FoodPalette.mpesa, value: "0712 ••• 678")
                        KitoValueRow("Visa", systemImage: "creditcard.fill", color: .blue, value: "•••• 4242")
                        KitoValueRow("Chakula Plus", systemImage: "sparkles", color: .purple, subtitle: "Free delivery over KES 2,500",
                                     value: "Active")
                    }
                    KitoSettingsSection("Preferences") {
                        KitoToggleRow("Order updates", systemImage: "scooter", color: FoodPalette.pepper,
                                      subtitle: "Banners while your food is on the way", isOn: $store.orderUpdates)
                        KitoToggleRow("Offers and promos", systemImage: "tag.fill", color: .orange, isOn: $store.offers)
                    }
                    KitoSettingsSection("Demo", footer: "Chakula is a Kito DevKit showcase. Restaurants, riders and orders are made up.") {
                        KitoActionRow("Start again", systemImage: "arrow.counterclockwise", color: .gray,
                                      confirmation: "Start the demo again from the location picker?") {
                            store.resetDemo()
                        }
                        KitoActionRow("Exit demo", systemImage: "xmark.circle.fill", color: .red, role: .destructive) {
                            store.onExit()
                        }
                    }
                }
                .navigationTitle("Account")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) { FoodExitButton() }
                }
            }
            .fullScreenCover(isPresented: $changesAddress) {
                FoodLocationScreen { changesAddress = false }
                    .environment(store)
                    .kitoTheme(theme)
            }
        }
    }

    struct FoodInboxScreen: View {
        @Environment(FoodStore.self) private var store

        var body: some View {
            @Bindable var store = store
            KitoNotificationInbox($store.inbox, title: "Notifications") { item in
                if item.kind == .order, store.activeOrder != nil { store.track() }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
