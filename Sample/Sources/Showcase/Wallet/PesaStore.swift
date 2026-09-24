//
//  PesaStore.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Observation
import KitoWalletCards
import KitoNotifications
import KitoScanner

extension WalletShowcase {
    /// The whole app's state: cards and their balances, transactions, contacts, goals and budgets.
    /// Everything is in memory; nothing is sent anywhere.
    @Observable
    @MainActor
    final class PesaStore {
        static let demoPIN = "1234"
        static let ownerName = "Wycliff Njenga"
        static let ownerPhone = "254712000678"

        var cards: [PesaCard]
        var transactions: [PesaTransaction]
        var contacts: [PesaContact]
        var goals: [PesaGoal]
        var budgets: [PesaBudget]
        var billers: [PesaBiller]
        var inbox: [KitoInboxNotification]
        var isBalanceHidden = false
        var confirmsWithBiometrics = true
        var roundsUpSpare = true

        init() {
            cards = PesaSeed.cards
            contacts = PesaSeed.contacts
            goals = PesaSeed.goals
            budgets = PesaSeed.budgets
            billers = PesaSeed.billers
            transactions = PesaSeed.transactions(contacts: PesaSeed.contacts).sorted { $0.date > $1.date }
            inbox = PesaSeed.inbox
        }

        // MARK: Reading

        var totalBalance: Double { cards.map(\.balance).reduce(0, +) }
        var mainCard: PesaCard { cards[0] }
        var favourites: [PesaContact] { contacts.filter(\.isFavourite) }
        var unreadCount: Int { inbox.filter { !$0.isRead }.count }

        func card(_ id: String) -> PesaCard? { cards.first { $0.id == id } }
        func contact(_ id: String?) -> PesaContact? { contacts.first { $0.id == id } }

        func transactions(inMonthOf date: Date, calendar: Calendar = .current) -> [PesaTransaction] {
            transactions.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
        }

        /// Money out in the month of `date`, by category, biggest first.
        func spending(inMonthOf date: Date) -> [(category: PesaCategory, amount: Double)] {
            var totals: [PesaCategory: Double] = [:]
            for transaction in transactions(inMonthOf: date) where !transaction.isIncoming {
                totals[transaction.category, default: 0] += -transaction.amount
            }
            return totals.map { ($0.key, $0.value) }.sorted { $0.amount > $1.amount }
        }

        func totalSpent(inMonthOf date: Date) -> Double {
            spending(inMonthOf: date).map(\.amount).reduce(0, +)
        }

        func totalIn(inMonthOf date: Date) -> Double {
            transactions(inMonthOf: date).filter(\.isIncoming).map(\.amount).reduce(0, +)
        }

        func spent(on card: PesaCard, inMonthOf date: Date = .now) -> Double {
            transactions(inMonthOf: date).filter { $0.cardID == card.id && !$0.isIncoming }.map { -$0.amount }.reduce(0, +)
        }

        // MARK: Moving money

        @discardableResult
        func send(_ amount: Double, to contact: PesaContact, note: String?, from cardID: String) -> PesaTransaction {
            record(PesaTransaction(title: contact.name, note: note, category: .transfers, amount: -amount, date: .now,
                                   cardID: cardID, reference: PesaSeed.reference(), contactID: contact.id))
        }

        @discardableResult
        func pay(_ request: KitoPaymentRequest, amount: Double, from cardID: String) -> PesaTransaction {
            let title = request.merchant ?? "\(request.kind.title) \(request.number)"
            let category: PesaCategory = request.kind == .paybill ? .bills : (request.kind == .phone ? .transfers : .groceries)
            let note = request.account.map { "Account \($0)" } ?? request.note
            return record(PesaTransaction(title: title, note: note, category: category, amount: -amount, date: .now,
                                          cardID: cardID, reference: PesaSeed.reference(), systemImage: "qrcode"))
        }

        @discardableResult
        func receive(_ amount: Double, from contact: PesaContact, note: String?) -> PesaTransaction {
            let transaction = record(PesaTransaction(title: contact.name, note: note, category: .income, amount: amount, date: .now,
                                                     cardID: mainCard.id, reference: PesaSeed.reference(), contactID: contact.id))
            inbox.insert(KitoInboxNotification(kind: .payment, title: "\(contact.firstName) sent you \(PesaMoney.string(amount))",
                                               body: note ?? "Money received", date: .now,
                                               avatar: .initials(contact.initials, contact.color), actionTitle: "View"), at: 0)
            return transaction
        }

        @discardableResult
        func topUp(_ amount: Double, into cardID: String) -> PesaTransaction {
            record(PesaTransaction(title: "Top up from Umoja Savings ••4410", note: "Bank transfer", category: .income, amount: amount,
                                   date: .now, cardID: cardID, reference: PesaSeed.reference(), systemImage: "building.columns.fill"))
        }

        func addToGoal(_ amount: Double, goalID: String) {
            guard let index = goals.firstIndex(where: { $0.id == goalID }), mainCard.balance >= amount else { return }
            goals[index].saved = min(goals[index].saved + amount, goals[index].target)
            record(PesaTransaction(title: "To \(goals[index].name)", note: "Savings goal", category: .transfers, amount: -amount,
                                   date: .now, cardID: mainCard.id, reference: PesaSeed.reference(), systemImage: goals[index].systemImage))
        }

        func toggleFreeze(_ cardID: String) {
            guard let index = cards.firstIndex(where: { $0.id == cardID }) else { return }
            cards[index].isFrozen.toggle()
        }

        func update(_ card: PesaCard) {
            guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
            cards[index] = card
        }

        @discardableResult
        func addCard(last4: String, holder: String?, expiry: String?) -> PesaCard {
            let face = KitoWalletCard(name: "Linked card", mark: .wordmark("LINKED"), last4: last4,
                                      holder: holder?.capitalized ?? "Wycliff Njenga", expiry: expiry ?? "08/29",
                                      balance: 0, currencyCode: "KES", style: .pearl)
            let card = PesaCard(face: face, isVirtual: false, monthlyLimit: 50_000,
                                demoNumber: "4000 0000 0000 \(last4)", demoCVV: "000")
            cards.append(card)
            return card
        }

        func markAllRead() {
            for index in inbox.indices { inbox[index].isRead = true }
        }

        @discardableResult
        private func record(_ transaction: PesaTransaction) -> PesaTransaction {
            if let index = cards.firstIndex(where: { $0.id == transaction.cardID }) {
                cards[index].face.balance += transaction.amount
            }
            transactions.insert(transaction, at: 0)
            return transaction
        }
    }
}
