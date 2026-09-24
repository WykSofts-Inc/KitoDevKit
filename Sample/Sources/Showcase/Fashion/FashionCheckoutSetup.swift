//
//  FashionCheckoutSetup.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation
import KitoCart
import KitoCheckout
import KitoPaywall

/// Mock delivery, payment and membership data. Nothing here talks to a server or takes real money.
enum FashionCheckoutSetup {
    static let freeDeliveryThreshold: Decimal = 25_000

    static let cartRules = KitoCartPricingRules(deliveryFee: 450, freeDeliveryThreshold: freeDeliveryThreshold)

    static let promos = KitoPromoValidator(codes: [
        KitoPromoCode(code: "KARIBU10", kind: .percent(10, cap: 3_000), title: "10% off, up to KES 3,000"),
        KitoPromoCode(code: "PRIVE15", kind: .percent(15), minimumSubtotal: 30_000, title: "Maison Privé: 15% off"),
        KitoPromoCode(code: "FREESHIP", kind: .freeDelivery, title: "Free delivery"),
    ])

    static let addresses: [KitoAddress] = [
        KitoAddress(id: "home", label: .home, recipient: "Zawadi Njeri", phone: "0712 345 678", street: "Argwings Kodhek Road",
                    building: "Mvuli Court, Block B, 4th floor", area: "Kilimani", town: "Kilimani", county: "Nairobi",
                    landmark: "the petrol station", instructions: "Call at the gate", isDefault: true),
        KitoAddress(id: "studio", label: .work, recipient: "Zawadi Njeri", phone: "0712 345 678", street: "Riverside Drive",
                    building: "The Oval, 7th floor", area: "Westlands", town: "Westlands", county: "Nairobi",
                    landmark: "the Riverside roundabout"),
        KitoAddress(id: "lamu", label: .other("Lamu house"), recipient: "Zawadi Njeri", phone: "0712 345 678", street: "Shela Beach Path",
                    area: "Shela", town: "Lamu", county: "Lamu", landmark: "the Peponi jetty"),
    ]

    static let boutiques: [KitoPickupPoint] = [
        KitoPickupPoint(id: "karen", name: "Maison Amani Karen", address: "Dagoretti Road, Karen", hours: "Mon–Sat, 10 AM–7 PM", distanceKm: 6.2),
        KitoPickupPoint(id: "westlands", name: "Maison Amani Westlands", address: "Woodvale Grove, Westlands", hours: "Daily, 10 AM–8 PM", distanceKm: 2.1),
    ]

    static func deliveryOptions() -> [KitoDeliveryOption] {
        [
            .standard(price: 450, eta: .days(1...2), title: "Standard delivery"),
            .express(price: 950, eta: .hours(2...4), title: "Same-day in Nairobi"),
            .scheduled(price: 650, title: "Choose a time"),
            .pickup(points: boutiques, eta: .hours(3...5), title: "Collect from a boutique"),
        ]
    }

    static func schedule() -> KitoDeliverySchedule {
        KitoDeliverySchedule(rules: KitoSlotRules(daysAhead: 6, leadTime: 2 * 60 * 60, sameDayCutoffMinutes: 16 * 60,
                                                  closedWeekdays: [1], capacity: 6))
    }

    static let payments: [KitoPaymentMethod] = [
        .mpesa(phone: "0712345678"),
        .card(.visa, last4: "4242", expiry: "08/29"),
        .applePay,
        .wallet(balance: 12_500),
    ]

    static let rules = KitoCheckoutPricingRules(vat: .kenya, freeDeliveryThreshold: freeDeliveryThreshold)

    @MainActor static func model(cart: KitoCartViewModel) -> KitoCheckoutModel {
        KitoCheckoutModel(
            cart: cart, steps: [.delivery, .payment, .review],
            addresses: addresses, deliveryOptions: deliveryOptions(), schedule: schedule(),
            paymentMethods: payments,
            applePay: KitoApplePayConfiguration(merchantIdentifier: nil, merchantName: "Maison Amani"),
            rules: rules, promoValidator: promos, offersGiftNote: true,
            termsText: "I agree to the Maison Amani [Terms of Sale](https://example.com/terms) and [Privacy Policy](https://example.com/privacy)")
    }

    // MARK: Maison Privé

    static let privePlans: [KitoPaywallPlan] = KitoPaywallPlan.arranged([
        KitoPaywallPlan(id: "prive.monthly", title: "Monthly", price: 1_500, currencyCode: "KES", period: .monthly, trial: .weekly),
        KitoPaywallPlan(id: "prive.yearly", title: "Yearly", price: 14_000, currencyCode: "KES", period: .yearly, trial: .weekly),
        KitoPaywallPlan(id: "prive.lifetime", title: "Lifetime", price: 45_000, currencyCode: "KES", period: nil),
    ], mostPopular: "prive.yearly")

    static let priveContent = KitoPaywallContent(
        title: "Maison Privé",
        subtitle: "Our private client circle. Mock plans only; nothing is charged.",
        symbol: "crown.fill",
        features: [
            KitoPaywallFeature("Early access", detail: "Shop each collection 48 hours before everyone else.", symbol: "clock.badge.checkmark.fill"),
            KitoPaywallFeature("Free same-day delivery", detail: "Across Nairobi, on every order.", symbol: "shippingbox.fill"),
            KitoPaywallFeature("Private styling", detail: "An hour with a stylist at our Karen boutique.", symbol: "sparkles"),
            KitoPaywallFeature("15% off, always", detail: "With the code PRIVE15 at checkout.", symbol: "tag.fill"),
            KitoPaywallFeature("Complimentary alterations", detail: "Hems and sleeves, done in the atelier.", symbol: "scissors"),
        ],
        termsURL: URL(string: "https://example.com/terms"),
        privacyURL: URL(string: "https://example.com/privacy"),
        closeButtonDelay: 1,
        celebrationTitle: "Welcome to Maison Privé",
        celebrationMessage: "Early access, free delivery and your stylist are ready.")
}
