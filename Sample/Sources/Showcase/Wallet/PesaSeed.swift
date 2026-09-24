//
//  PesaSeed.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoWalletCards
import KitoNotifications
import KitoScanner

extension WalletShowcase {
    /// The demo's starting data: four cards, a dozen friends, and about three months of
    /// transactions dated relative to today, so the app always looks current.
    enum PesaSeed {
        static let everydayID = "pesa-everyday"
        static let onlineID = "pesa-online"
        static let travelID = "pesa-travel"
        static let familyID = "pesa-family"

        static var cards: [PesaCard] {
            [
                PesaCard(face: KitoWalletCard(id: everydayID, name: "Everyday", mark: .wordmark("PESA", italic: true), last4: "4120",
                                              holder: "Wycliff Njenga", expiry: "09/29", balance: 84_350, currencyCode: "KES", style: .midnight),
                         isVirtual: false, monthlyLimit: 120_000, demoNumber: "5399 2210 8841 4120", demoCVV: "381"),
                PesaCard(face: KitoWalletCard(id: onlineID, name: "Online", mark: .symbol("globe"), last4: "7781",
                                              holder: "Wycliff Njenga", expiry: "03/28", balance: 12_500, currencyCode: "KES", style: .ocean),
                         isVirtual: true, monthlyLimit: 25_000, demoNumber: "5399 2210 3307 7781", demoCVV: "904"),
                PesaCard(face: KitoWalletCard(id: travelID, name: "Travel", mark: .symbol("airplane"), last4: "5519",
                                              holder: "Wycliff Njenga", expiry: "11/30", balance: 23_900, currencyCode: "KES", style: .sunset),
                         isVirtual: false, monthlyLimit: 60_000, demoNumber: "5399 2210 6620 5519", demoCVV: "217"),
                PesaCard(face: KitoWalletCard(id: familyID, name: "Family", mark: .symbol("house.fill"), last4: "0932",
                                              holder: "Wycliff Njenga", expiry: "06/29", balance: 18_400, currencyCode: "KES", style: .lavender),
                         isVirtual: false, monthlyLimit: 40_000, demoNumber: "5399 2210 1954 0932", demoCVV: "655"),
            ]
        }

        static let contacts: [PesaContact] = [
            PesaContact(id: "c-achieng", name: "Achieng Owuor", phone: "0711 482 903", color: .pink, isFavourite: true),
            PesaContact(id: "c-kamau", name: "Kamau Njoroge", phone: "0722 615 204", color: .orange, isFavourite: true),
            PesaContact(id: "c-wanjiru", name: "Wanjiru Mwangi", phone: "0733 908 117", color: .purple, isFavourite: true),
            PesaContact(id: "c-otieno", name: "Otieno Odhiambo", phone: "0701 356 842", color: .blue, isFavourite: true),
            PesaContact(id: "c-fatuma", name: "Fatuma Hassan", phone: "0745 271 690", color: .teal, isFavourite: true),
            PesaContact(id: "c-kiprono", name: "Kiprono Rotich", phone: "0790 442 318", color: .green, isFavourite: false),
            PesaContact(id: "c-njeri", name: "Njeri Kariuki", phone: "0712 830 556", color: .red, isFavourite: false),
            PesaContact(id: "c-baraka", name: "Baraka Omondi", phone: "0768 104 729", color: .indigo, isFavourite: false),
            PesaContact(id: "c-zawadi", name: "Zawadi Chebet", phone: "0799 563 081", color: .mint, isFavourite: false),
            PesaContact(id: "c-juma", name: "Juma Bakari", phone: "0708 219 944", color: .brown, isFavourite: false),
            PesaContact(id: "c-akinyi", name: "Akinyi Adhiambo", phone: "0746 687 310", color: .cyan, isFavourite: false),
            PesaContact(id: "c-mwende", name: "Mwende Mutua", phone: "0725 390 462", color: .yellow, isFavourite: false),
        ]

        static var goals: [PesaGoal] {
            [
                PesaGoal(id: "g-mombasa", name: "Mombasa getaway", systemImage: "beach.umbrella.fill", saved: 68_000, target: 100_000,
                         color: Color(red: 0.10, green: 0.62, blue: 0.95), due: Calendar.current.date(byAdding: .month, value: 3, to: .now) ?? .now),
                PesaGoal(id: "g-rainy", name: "Rainy-day fund", systemImage: "umbrella.fill", saved: 120_000, target: 300_000,
                         color: PesaStyle.positive, due: Calendar.current.date(byAdding: .month, value: 10, to: .now) ?? .now),
            ]
        }

        static let budgets: [PesaBudget] = [
            PesaBudget(category: .bills, limit: 55_000),
            PesaBudget(category: .groceries, limit: 15_000),
            PesaBudget(category: .dining, limit: 4_000),
            PesaBudget(category: .transport, limit: 3_000),
            PesaBudget(category: .shopping, limit: 3_000),
            PesaBudget(category: .health, limit: 3_000),
            PesaBudget(category: .entertainment, limit: 1_000),
        ]

        static let billers: [PesaBiller] = [
            PesaBiller(id: "b-power", name: "Nyota Power", systemImage: "bolt.fill", color: .yellow,
                       request: KitoPaymentRequest(kind: .paybill, number: "888444", account: "PRE-20417", amount: 2_500, merchant: "Nyota Power")),
            PesaBiller(id: "b-water", name: "Kilimani Heights Water", systemImage: "drop.fill", color: .cyan,
                       request: KitoPaymentRequest(kind: .paybill, number: "247247", account: "KTH-0042", amount: 1_200, merchant: "Kilimani Heights Water")),
            PesaBiller(id: "b-fibre", name: "Mtandao Fibre", systemImage: "wifi", color: .indigo,
                       request: KitoPaymentRequest(kind: .paybill, number: "506070", account: "MF-88213", amount: 3_999, merchant: "Mtandao Fibre")),
            PesaBiller(id: "b-rent", name: "Mlango Homes rent", systemImage: "key.fill", color: .purple,
                       request: KitoPaymentRequest(kind: .paybill, number: "600321", account: "UNIT-B7", amount: 45_000, merchant: "Mlango Homes")),
        ]

        static var inbox: [KitoInboxNotification] {
            let now = Date.now
            return [
                KitoInboxNotification(kind: .security, title: "Online card used", body: "Your Online card ••7781 paid Chapa Books KES 2,300.",
                                      date: now.addingTimeInterval(-3_600 * 5), avatar: .symbol("globe", .blue)),
                KitoInboxNotification(kind: .reminder, title: "68% of the way to Mombasa", body: "Add KES 1,000 a week to get there on time.",
                                      date: now.addingTimeInterval(-3_600 * 28), isRead: true, avatar: .symbol("beach.umbrella.fill", .cyan)),
                KitoInboxNotification(kind: .payment, title: "Salary received", body: "Tausi Studio paid KES 185,000 into Everyday.",
                                      date: now.addingTimeInterval(-3_600 * 24 * 23), isRead: true, avatar: .symbol("banknote.fill", .green)),
                KitoInboxNotification(kind: .promo, title: "Split a bill in seconds", body: "Tap Request on Home and pick your friends.",
                                      date: now.addingTimeInterval(-3_600 * 24 * 16), isRead: true, avatar: .symbol("person.2.fill", .orange)),
            ]
        }

        // MARK: Transactions

        private struct Row {
            let daysAgo: Int
            let hour: Int
            let title: String
            let category: PesaCategory
            let amount: Double
            var note: String? = nil
            var card: String = PesaSeed.everydayID
            var contact: String? = nil
            var symbol: String? = nil
        }

        /// Three months, newest first, placed by days before today. On the 24th of a month this
        /// month's spending comes out 12% under last month's.
        private static let rows: [Row] = [
            // This month
            Row(daysAgo: 0, hour: 8, title: "Kahawa House", category: .dining, amount: -450, note: "Flat white and mandazi", symbol: "cup.and.saucer.fill"),
            Row(daysAgo: 0, hour: 7, title: "Mji Rides", category: .transport, amount: -380, note: "Kilimani to Westlands"),
            Row(daysAgo: 1, hour: 18, title: "Mama Mboga Greens", category: .groceries, amount: -850, note: "Sukuma, nyanya, dhania", symbol: "leaf.fill"),
            Row(daysAgo: 2, hour: 20, title: "Nyota Power", category: .bills, amount: -2_500, note: "Prepaid tokens", symbol: "bolt.fill"),
            Row(daysAgo: 3, hour: 11, title: "Soko Fresh Market", category: .groceries, amount: -4_320, note: "Weekly shop"),
            Row(daysAgo: 4, hour: 13, title: "Achieng Owuor", category: .transfers, amount: -1_500, note: "Lunch split", contact: "c-achieng"),
            Row(daysAgo: 5, hour: 21, title: "Sinema Tano", category: .entertainment, amount: -1_200, note: "Two tickets", card: travelID, symbol: "film.fill"),
            Row(daysAgo: 6, hour: 17, title: "Mji Rides", category: .transport, amount: -640),
            Row(daysAgo: 8, hour: 10, title: "Afya Plus Pharmacy", category: .health, amount: -1_850, card: familyID, symbol: "pills.fill"),
            Row(daysAgo: 9, hour: 19, title: "Kamau Njoroge", category: .income, amount: 2_000, note: "Rent share", contact: "c-kamau"),
            Row(daysAgo: 10, hour: 9, title: "Mtandao Fibre", category: .bills, amount: -3_999, note: "Home fibre, 40 Mbps", symbol: "wifi"),
            Row(daysAgo: 12, hour: 16, title: "Tamu Bakery", category: .dining, amount: -720, card: familyID, symbol: "birthday.cake.fill"),
            Row(daysAgo: 14, hour: 15, title: "Chapa Books", category: .shopping, amount: -2_300, note: "Two novels", card: onlineID, symbol: "book.fill"),
            Row(daysAgo: 17, hour: 12, title: "Soko Fresh Market", category: .groceries, amount: -5_110, card: familyID),
            Row(daysAgo: 20, hour: 8, title: "Kilimani Heights Water", category: .bills, amount: -1_200, symbol: "drop.fill"),
            Row(daysAgo: 23, hour: 10, title: "Mlango Homes", category: .bills, amount: -45_000, note: "Rent, unit B7", symbol: "key.fill"),
            Row(daysAgo: 23, hour: 7, title: "Tausi Studio", category: .income, amount: 185_000, note: "Salary", symbol: "banknote.fill"),
            // Last month
            Row(daysAgo: 24, hour: 9, title: "Kahawa House", category: .dining, amount: -520, symbol: "cup.and.saucer.fill"),
            Row(daysAgo: 26, hour: 11, title: "Soko Fresh Market", category: .groceries, amount: -6_240, note: "Weekly shop", card: familyID),
            Row(daysAgo: 28, hour: 22, title: "Mji Rides", category: .transport, amount: -1_150, note: "Late ride home"),
            Row(daysAgo: 30, hour: 14, title: "Pumzika Spa", category: .health, amount: -4_500, card: travelID, symbol: "sparkles"),
            Row(daysAgo: 32, hour: 20, title: "Nyota Power", category: .bills, amount: -2_500, note: "Prepaid tokens", symbol: "bolt.fill"),
            Row(daysAgo: 34, hour: 18, title: "Duka la Mtaa", category: .groceries, amount: -1_380, symbol: "basket.fill"),
            Row(daysAgo: 36, hour: 9, title: "Mtandao Fibre", category: .bills, amount: -3_999, note: "Home fibre, 40 Mbps", symbol: "wifi"),
            Row(daysAgo: 38, hour: 15, title: "Chapa Books", category: .shopping, amount: -3_040, card: onlineID, symbol: "book.fill"),
            Row(daysAgo: 40, hour: 12, title: "Wanjiru Mwangi", category: .transfers, amount: -5_000, note: "Birthday gift", contact: "c-wanjiru"),
            Row(daysAgo: 43, hour: 21, title: "Sinema Tano", category: .entertainment, amount: -1_800, card: travelID, symbol: "film.fill"),
            Row(daysAgo: 46, hour: 10, title: "Soko Fresh Market", category: .groceries, amount: -4_870, card: familyID),
            Row(daysAgo: 50, hour: 8, title: "Kilimani Heights Water", category: .bills, amount: -1_200, symbol: "drop.fill"),
            Row(daysAgo: 52, hour: 16, title: "Tamu Bakery", category: .dining, amount: -640, symbol: "birthday.cake.fill"),
            Row(daysAgo: 53, hour: 10, title: "Mlango Homes", category: .bills, amount: -45_000, note: "Rent, unit B7", symbol: "key.fill"),
            Row(daysAgo: 54, hour: 7, title: "Tausi Studio", category: .income, amount: 185_000, note: "Salary", symbol: "banknote.fill"),
            // Two months ago
            Row(daysAgo: 58, hour: 8, title: "Kahawa House", category: .dining, amount: -380, symbol: "cup.and.saucer.fill"),
            Row(daysAgo: 60, hour: 11, title: "Soko Fresh Market", category: .groceries, amount: -5_600, card: familyID),
            Row(daysAgo: 62, hour: 19, title: "Mji Rides", category: .transport, amount: -920),
            Row(daysAgo: 65, hour: 20, title: "Nyota Power", category: .bills, amount: -2_500, note: "Prepaid tokens", symbol: "bolt.fill"),
            Row(daysAgo: 67, hour: 9, title: "Mtandao Fibre", category: .bills, amount: -3_999, note: "Home fibre, 40 Mbps", symbol: "wifi"),
            Row(daysAgo: 70, hour: 13, title: "Otieno Odhiambo", category: .transfers, amount: -3_000, note: "Harambee contribution", contact: "c-otieno"),
            Row(daysAgo: 73, hour: 21, title: "Sinema Tano", category: .entertainment, amount: -900, card: travelID, symbol: "film.fill"),
            Row(daysAgo: 76, hour: 17, title: "Afya Plus Pharmacy", category: .health, amount: -1_250, card: familyID, symbol: "pills.fill"),
            Row(daysAgo: 79, hour: 8, title: "Kilimani Heights Water", category: .bills, amount: -1_200, symbol: "drop.fill"),
            Row(daysAgo: 81, hour: 18, title: "Duka la Mtaa", category: .groceries, amount: -2_150, symbol: "basket.fill"),
            Row(daysAgo: 84, hour: 10, title: "Mlango Homes", category: .bills, amount: -45_000, note: "Rent, unit B7", symbol: "key.fill"),
            Row(daysAgo: 85, hour: 7, title: "Tausi Studio", category: .income, amount: 185_000, note: "Salary", symbol: "banknote.fill"),
        ]

        static func transactions(contacts: [PesaContact], now: Date = .now, calendar: Calendar = .current) -> [PesaTransaction] {
            let today = calendar.startOfDay(for: now)
            return rows.enumerated().map { index, row in
                let day = calendar.date(byAdding: .day, value: -row.daysAgo, to: today) ?? today
                var date = calendar.date(byAdding: .minute, value: row.hour * 60 + (index * 7) % 50, to: day) ?? day
                if date > now { date = now.addingTimeInterval(-Double(index + 1) * 900) }
                return PesaTransaction(title: row.title, note: row.note, category: row.category, amount: row.amount, date: date,
                                       cardID: row.card, reference: reference(seed: index), contactID: row.contact,
                                       systemImage: row.symbol)
            }
        }

        /// "PSA" and seven letters and digits, like a real receipt number.
        static func reference(seed: Int? = nil) -> String {
            let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
            var generator = PesaSeededGenerator(seed: UInt64(seed ?? Int.random(in: 1_000...9_999_999)))
            return "PSA" + String((0..<7).map { _ in alphabet[Int(generator.next() % UInt64(alphabet.count))] })
        }
    }

    /// A tiny deterministic generator so seeded references are stable between launches.
    private struct PesaSeededGenerator: RandomNumberGenerator {
        var state: UInt64
        init(seed: UInt64) { state = seed &* 0x9E37_79B9_7F4A_7C15 | 1 }
        mutating func next() -> UInt64 {
            state ^= state << 13
            state ^= state >> 7
            state ^= state << 17
            return state
        }
    }
}
