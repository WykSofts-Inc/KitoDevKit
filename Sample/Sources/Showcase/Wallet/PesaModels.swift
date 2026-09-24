//
//  PesaModels.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoWalletCards
import KitoFormatting
import KitoNotifications
import KitoScanner

// Every merchant, person, card and number here is invented. Amounts are in Kenyan shillings.

extension WalletShowcase {
    enum PesaCategory: String, CaseIterable, Identifiable, Hashable {
        case groceries, dining, transport, bills, shopping, entertainment, health, transfers, income

        var id: String { rawValue }

        var title: String {
            switch self {
            case .groceries: "Groceries"
            case .dining: "Eating out"
            case .transport: "Transport"
            case .bills: "Bills & rent"
            case .shopping: "Shopping"
            case .entertainment: "Fun"
            case .health: "Health"
            case .transfers: "Transfers"
            case .income: "Income"
            }
        }

        var systemImage: String {
            switch self {
            case .groceries: "cart.fill"
            case .dining: "fork.knife"
            case .transport: "car.fill"
            case .bills: "house.fill"
            case .shopping: "bag.fill"
            case .entertainment: "popcorn.fill"
            case .health: "cross.case.fill"
            case .transfers: "arrow.left.arrow.right"
            case .income: "arrow.down.left"
            }
        }

        var color: Color {
            switch self {
            case .groceries: Color(red: 0.20, green: 0.70, blue: 0.40)
            case .dining: Color(red: 0.98, green: 0.55, blue: 0.20)
            case .transport: Color(red: 0.25, green: 0.50, blue: 0.98)
            case .bills: Color(red: 0.55, green: 0.40, blue: 0.95)
            case .shopping: Color(red: 0.95, green: 0.30, blue: 0.55)
            case .entertainment: Color(red: 0.98, green: 0.75, blue: 0.15)
            case .health: Color(red: 0.10, green: 0.72, blue: 0.80)
            case .transfers: Color(red: 0.45, green: 0.50, blue: 0.60)
            case .income: PesaStyle.positive
            }
        }

        /// Categories that count as spending in Insights.
        static var spending: [PesaCategory] { allCases.filter { $0 != .income } }
    }

    struct PesaTransaction: Identifiable, Hashable {
        let id: UUID
        var title: String
        var note: String?
        var category: PesaCategory
        /// Negative leaves the account, positive arrives.
        var amount: Double
        var date: Date
        var cardID: String
        var reference: String
        /// Set when the other side is a person, for an initials avatar.
        var contactID: String?
        var systemImage: String?

        init(id: UUID = UUID(), title: String, note: String? = nil, category: PesaCategory, amount: Double, date: Date,
             cardID: String, reference: String, contactID: String? = nil, systemImage: String? = nil) {
            self.id = id
            self.title = title
            self.note = note
            self.category = category
            self.amount = amount
            self.date = date
            self.cardID = cardID
            self.reference = reference
            self.contactID = contactID
            self.systemImage = systemImage
        }

        var isIncoming: Bool { amount > 0 }
        var symbol: String { systemImage ?? category.systemImage }
    }

    struct PesaContact: Identifiable, Hashable {
        let id: String
        var name: String
        var phone: String
        var color: Color
        var isFavourite: Bool

        var firstName: String { String(name.split(separator: " ").first ?? "") }
        var initials: String { name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined() }
        var maskedPhone: String { KitoKenyanPhoneNumber(phone)?.masked ?? phone }
    }

    struct PesaCard: Identifiable {
        var face: KitoWalletCard
        var isVirtual: Bool
        var isFrozen = false
        var monthlyLimit: Double
        /// Mock only: a made-up number that is written to the keychain and read back on reveal.
        var demoNumber: String
        var demoCVV: String
        var onlinePayments = true
        var contactless = true
        var withdrawals = true

        var id: String { face.id }
        var name: String { face.name }
        var balance: Double { face.balance }
    }

    struct PesaGoal: Identifiable {
        let id: String
        var name: String
        var systemImage: String
        var saved: Double
        var target: Double
        var color: Color
        var due: Date

        var progress: Double { target > 0 ? min(saved / target, 1) : 0 }
    }

    struct PesaBudget: Identifiable {
        var category: PesaCategory
        var limit: Double
        var id: String { category.rawValue }
    }

    struct PesaBiller: Identifiable {
        let id: String
        var name: String
        var systemImage: String
        var color: Color
        var request: KitoPaymentRequest
    }

    /// Money formatting in one place, so every screen reads "KES 1,250".
    enum PesaMoney {
        static func string(_ amount: Double, cents: KitoCents = .auto) -> String {
            KitoMoneyFormatting.string(Decimal(amount.rounded(toPlaces: 2)), currency: .kes, cents: cents)
        }

        static func signed(_ amount: Double) -> String {
            KitoMoneyFormatting.signed(Decimal(amount.rounded(toPlaces: 2)), currency: .kes)
        }

        static func compact(_ amount: Double) -> String {
            KitoMoneyFormatting.compact(Decimal(amount.rounded(toPlaces: 0)), currency: .kes)
        }

        static let hidden = "KES ••••••"
    }

    enum PesaStyle {
        static let positive = Color(red: 0.05, green: 0.66, blue: 0.42)
        static let brand = Color(red: 0.05, green: 0.66, blue: 0.42)
        static let cardCorner: CGFloat = 22
    }
}

extension Double {
    fileprivate func rounded(toPlaces places: Int) -> Double {
        let factor = pow(10, Double(places))
        return (self * factor).rounded() / factor
    }
}
