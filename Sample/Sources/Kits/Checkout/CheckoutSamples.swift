//
//  CheckoutSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoCheckout

// MARK: - Sample data

private enum CheckoutData {
    static func groceries() -> [KitoCartItem] {
        [
            KitoCartItem(id: "coffee", name: "Kenyan AA coffee", unitPrice: 1_200, quantity: 1, subtitle: "Medium roast · 500 g"),
            KitoCartItem(id: "avocado", name: "Hass avocados", unitPrice: 90, quantity: 4, subtitle: "Ripe tomorrow"),
            KitoCartItem(id: "mandazi", name: "Coconut mandazi", unitPrice: 30, quantity: 6, subtitle: "Baked this morning"),
            KitoCartItem(id: "milk", name: "Fresh milk", unitPrice: 75, quantity: 2, subtitle: "1 L"),
        ]
    }

    static func meal() -> [KitoCartItem] {
        [
            KitoCartItem(id: "pilau", name: "Beef pilau", unitPrice: 650, quantity: 2, subtitle: "Kachumbari on the side"),
            KitoCartItem(id: "chapati", name: "Chapati", unitPrice: 60, quantity: 4, subtitle: "Soft, layered"),
            KitoCartItem(id: "juice", name: "Passion juice", unitPrice: 250, quantity: 1, subtitle: "500 ml"),
        ]
    }

    static let addresses: [KitoAddress] = [
        KitoAddress(id: "home", label: .home, recipient: "Achieng Otieno", phone: "0712 345 678", street: "Argwings Kodhek Road",
                    building: "Mvuli Court, Block B, 4th floor", area: "Kilimani", town: "Kilimani", county: "Nairobi",
                    landmark: "the petrol station", instructions: "Call at the gate", isDefault: true),
        KitoAddress(id: "work", label: .work, recipient: "Achieng Otieno", phone: "0712 345 678", street: "Waiyaki Way",
                    building: "Delta Towers, 6th floor", area: "Westlands", town: "Westlands", county: "Nairobi",
                    landmark: "the footbridge"),
        KitoAddress(id: "mum", label: .other("Mum's place"), recipient: "Grace Otieno", phone: "0722 111 222", street: "Karen Road",
                    area: "Karen", town: "Karen", county: "Nairobi", landmark: "the shopping centre"),
    ]

    static let pickupPoints: [KitoPickupPoint] = [
        KitoPickupPoint(id: "westlands", name: "Westlands Hub", address: "Waiyaki Way, Westlands", hours: "Mon–Sat, 8 AM–8 PM", distanceKm: 1.4),
        KitoPickupPoint(id: "kilimani", name: "Kilimani Locker", address: "Argwings Kodhek Road", hours: "Open 24 hours", distanceKm: 0.6),
        KitoPickupPoint(id: "cbd", name: "CBD Counter", address: "Moi Avenue, Nairobi CBD", hours: "Mon–Fri, 7 AM–7 PM", distanceKm: 4.8),
    ]

    static func deliveryOptions() -> [KitoDeliveryOption] {
        [
            .standard(price: 250, eta: .hours(2...4), title: "Standard"),
            .express(price: 450, eta: .minutes(30...45)),
            .scheduled(price: 150),
            .pickup(points: pickupPoints),
        ]
    }

    static func mealOptions() -> [KitoDeliveryOption] {
        var busy = KitoDeliveryOption.express(price: 180, eta: .minutes(15...25), title: "Priority")
        busy.unavailableReason = "Riders are busy right now — try again soon."
        return [.standard(price: 120, eta: .minutes(35...50), title: "Delivery"), busy, .pickup(points: [pickupPoints[1]], eta: .minutes(20...25), title: "Collect")]
    }

    /// Some slots already booked today and tomorrow, so full ones show up.
    static func schedule(now: Date = Date()) -> KitoDeliverySchedule {
        let rules = KitoSlotRules(daysAhead: 6, leadTime: 45 * 60, sameDayCutoffMinutes: 18 * 60, closedWeekdays: [1], capacity: 5)
        let base = KitoDeliverySchedule(rules: rules)
        let calendar = rules.calendar
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let booked = [
            base.slotID(day: tomorrow, window: KitoTimeWindow(8, 10)): 5,
            base.slotID(day: tomorrow, window: KitoTimeWindow(10, 12)): 4,
            base.slotID(day: tomorrow, window: KitoTimeWindow(16, 18)): 5,
            base.slotID(day: today, window: KitoTimeWindow(18, 20)): 3,
        ]
        return KitoDeliverySchedule(rules: rules, booked: booked)
    }

    static func payments() -> [KitoPaymentMethod] {
        [
            .mpesa(phone: "0712345678"),
            .card(.visa, last4: "4242", expiry: "08/29"),
            .card(.mastercard, last4: "4444", expiry: "01/25"),
            .applePay,
            .cashOnDelivery(limit: 10_000),
            .wallet(balance: 850),
        ]
    }

    static let rules = KitoCheckoutPricingRules(serviceFee: .percent(2, minimum: 20, maximum: 150), vat: .kenya, freeDeliveryThreshold: 5_000)

    static let validator = KitoPromoValidator(codes: [
        KitoPromoCode(code: "KARIBU10", kind: .percent(10, cap: 300), title: "10% off, up to KES 300"),
        KitoPromoCode(code: "FREESHIP", kind: .freeDelivery),
        KitoPromoCode(code: "SAVE200", kind: .fixed(200), minimumSubtotal: 1_500),
    ])

    static let terms = "I agree to the [Terms of Sale](https://example.com/terms) and [Privacy Policy](https://example.com/privacy)"

    static let applePayNotSetUp = KitoApplePayConfiguration(merchantIdentifier: nil, merchantName: "Duka Moja")

    static func place(_ order: KitoCheckoutOrder) async throws -> KitoPlacedOrder {
        try await Task.sleep(nanoseconds: 1_300_000_000)
        return order.confirmed(number: KitoOrderNumber.dated(Int.random(in: 40...980), date: Date()))
    }

    static let placedOrder = KitoPlacedOrder(
        number: "KC-260924-0042", eta: "Today, 2–4 PM", destination: "Mvuli Court, Argwings Kodhek Road, Kilimani, Nairobi",
        deliveryTitle: "Choose a time", paymentTitle: "M-Pesa", items: groceries(),
        lines: KitoCheckoutTotals(items: groceries(), rules: rules, deliveryFee: 150).lines,
        total: KitoCheckoutTotals(items: groceries(), rules: rules, deliveryFee: 150).total)
}

private struct CheckoutSampleTimeout: LocalizedError {
    var errorDescription: String? { "The M-Pesa request timed out. Check your phone and try again." }
}

/// Fails the first attempt, then goes through.
private final class CheckoutFlakyPayments {
    var attempts = 0
}

// MARK: - Full checkouts

private struct CheckoutGroceryFlow: View {
    @State private var model = KitoCheckoutModel(
        items: CheckoutData.groceries(), addresses: CheckoutData.addresses, deliveryOptions: CheckoutData.deliveryOptions(),
        schedule: CheckoutData.schedule(), paymentMethods: CheckoutData.payments(), applePay: CheckoutData.applePayNotSetUp,
        rules: CheckoutData.rules, promoValidator: CheckoutData.validator, offersGiftNote: true, termsText: CheckoutData.terms)

    var body: some View {
        KitoCheckoutFlow(model: model, onTrackOrder: { _ in model.reset() }, onContinueShopping: { model.reset() },
                         onPlaceOrder: CheckoutData.place)
    }
}

private struct CheckoutFoodFlow: View {
    @State private var model = KitoCheckoutModel(
        items: CheckoutData.meal(), addresses: CheckoutData.addresses, deliveryOptions: CheckoutData.mealOptions(),
        paymentMethods: [.mpesa(phone: "0712345678"), .card(.visa, last4: "4242", expiry: "08/29"), .cashOnDelivery()],
        rules: KitoCheckoutPricingRules(serviceFee: .fixed(30)), offersTip: true)

    var body: some View {
        KitoCheckoutFlow(model: model, title: "Your order", progressStyle: .segmented, tint: .orange,
                         onContinueShopping: { model.reset() }, onPlaceOrder: CheckoutData.place)
    }
}

private struct CheckoutPickupFlow: View {
    @State private var model = KitoCheckoutModel(
        items: CheckoutData.groceries(), steps: [.delivery, .payment, .review],
        deliveryOptions: [.pickup(points: CheckoutData.pickupPoints, eta: .hours(1...2), title: "Pick up in store")],
        paymentMethods: [.mpesa(phone: "0712345678"), .wallet(balance: 5_000)], rules: CheckoutData.rules)

    var body: some View {
        KitoCheckoutFlow(model: model, title: "Click & collect", progressStyle: .text, tint: .indigo,
                         onContinueShopping: { model.reset() }, onPlaceOrder: CheckoutData.place)
    }
}

private struct CheckoutApplePayFlow: View {
    @State private var model = KitoCheckoutModel(
        items: CheckoutData.meal(), steps: [.payment, .review], addresses: [CheckoutData.addresses[0]],
        deliveryOptions: [.standard(price: 200)], paymentMethods: [.applePay, .mpesa(phone: "0712345678")],
        applePay: CheckoutData.applePayNotSetUp)

    var body: some View {
        KitoCheckoutFlow(model: model, title: "Pay", onContinueShopping: { model.reset() }, onPlaceOrder: CheckoutData.place)
    }
}

private struct CheckoutFailingFlow: View {
    @State private var model = KitoCheckoutModel(
        items: CheckoutData.meal(), steps: [.review], addresses: [CheckoutData.addresses[1]],
        deliveryOptions: [.express(price: 300)], paymentMethods: [.mpesa(phone: "0712345678")])
    @State private var payments = CheckoutFlakyPayments()

    var body: some View {
        KitoCheckoutFlow(model: model, title: "Pay with M-Pesa", onContinueShopping: { model.reset() }) { order in
            payments.attempts += 1
            try await Task.sleep(nanoseconds: 1_000_000_000)
            if payments.attempts % 2 == 1 { throw CheckoutSampleTimeout() }
            return order.confirmed(number: KitoOrderNumber.random())
        }
    }
}

// MARK: - Progress

private struct CheckoutProgressSample: View {
    let style: KitoCheckoutProgressStyle
    @State private var step: KitoCheckoutStep = .delivery

    var body: some View {
        VStack(spacing: 28) {
            KitoCheckoutProgressHeader(current: step, style: style) { step = $0 }
            HStack(spacing: 12) {
                Button("Back") { move(-1) }
                    .buttonStyle(.bordered)
                    .disabled(step == .bag)
                Button("Next") { move(1) }
                    .buttonStyle(GalleryPrimaryButtonStyle())
                    .disabled(step == .review)
            }
        }
    }

    private func move(_ offset: Int) {
        let steps = KitoCheckoutStep.standard
        guard let index = steps.firstIndex(of: step) else { return }
        let next = min(max(index + offset, 0), steps.count - 1)
        withAnimation { step = steps[next] }
    }
}

private struct CheckoutTotalBarSample: View {
    @State private var tip: KitoTip = .none
    @State private var ready = false

    private var totals: KitoCheckoutTotals {
        KitoCheckoutTotals(items: CheckoutData.meal(), deliveryFee: 120, tip: tip)
    }

    var body: some View {
        VStack(spacing: 18) {
            Picker("Tip", selection: $tip) {
                Text("No tip").tag(KitoTip.none)
                Text("10%").tag(KitoTip.percent(10))
                Text("15%").tag(KitoTip.percent(15))
            }
            .pickerStyle(.segmented)
            Toggle("Address chosen", isOn: $ready)
            KitoCheckoutTotalBar(total: totals.total, caption: "\(totals.itemCount) items", button: .standard("Continue to payment"),
                                 hint: ready ? nil : "Choose a delivery address.", isEnabled: ready) {}
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

// MARK: - Delivery

private struct CheckoutAddressSample: View {
    @State private var addresses = CheckoutData.addresses
    @State private var selection: KitoAddress.ID? = "home"

    var body: some View {
        KitoAddressPicker(addresses: $addresses, selection: $selection)
    }
}

private struct CheckoutAddressFormSample: View {
    @State private var saved: KitoAddress?

    var body: some View {
        KitoAddressForm(onCancel: { saved = nil }, onSave: { saved = $0 })
            .overlay(alignment: .top) {
                if let saved {
                    Text("Saved: " + saved.formatted(.short))
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().fill(.regularMaterial))
                        .padding(.top, 56)
                }
            }
    }
}

private struct CheckoutDeliveryOptionsSample: View {
    @State private var option: KitoDeliveryOption.ID? = "standard"
    @State private var point: KitoPickupPoint.ID?

    var body: some View {
        KitoDeliveryOptions(CheckoutData.deliveryOptions(), selection: $option, pickupPoint: $point)
    }
}

private struct CheckoutSlotSample: View {
    @State private var slot: KitoDeliverySlot?
    private let schedule = CheckoutData.schedule()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            KitoDeliverySlotPicker(schedule: schedule, selection: $slot)
            Text(slot.map { "Delivering " + schedule.label(for: $0, now: Date()) } ?? "Choose a time")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Payment

private struct CheckoutPaymentSample: View {
    @State private var method: KitoPaymentMethod.ID? = "mpesa"

    var body: some View {
        KitoPaymentMethodList(CheckoutData.payments(), selection: $method, total: 2_150,
                              applePay: KitoApplePay.availability(for: CheckoutData.applePayNotSetUp), onAddCard: {})
    }
}

private struct CheckoutApplePaySample: View {
    @State private var tapped = 0

    var body: some View {
        VStack(spacing: 16) {
            KitoApplePayButton(type: .buy) { tapped += 1 }
            KitoApplePayButton(type: .checkout, style: .whiteOutline, cornerRadius: 12) { tapped += 1 }
            if tapped > 0 {
                Text("Tapped \(tapped) time\(tapped == 1 ? "" : "s")").font(.footnote).foregroundStyle(.secondary)
            }
            KitoApplePayNotice(availability: .notConfigured)
            KitoApplePayNotice(availability: .needsSetup)
        }
    }
}

private struct CheckoutTipSample: View {
    @State private var tip: KitoTip = .percent(10)

    var body: some View {
        VStack(spacing: 14) {
            KitoTipSelector(tip: $tip, subtotal: 1_560, tint: .orange)
            Text("Tip: " + KitoCartMoney.string(tip.amount(on: 1_560), currencyCode: "KES"))
                .font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Review and done

private struct CheckoutSummarySample: View {
    @State private var promo: KitoPromoCode? = KitoPromoCode(code: "KARIBU10", kind: .percent(10, cap: 300))
    @State private var express = false

    private var totals: KitoCheckoutTotals {
        KitoCheckoutTotals(items: CheckoutData.groceries(), rules: CheckoutData.rules, deliveryFee: express ? 450 : 250, promo: promo)
    }

    var body: some View {
        VStack(spacing: 16) {
            Toggle("Express delivery", isOn: $express)
            Toggle("Promo KARIBU10", isOn: Binding(get: { promo != nil }, set: { promo = $0 ? KitoPromoCode(code: "KARIBU10", kind: .percent(10, cap: 300)) : nil }))
            KitoOrderSummary(totals: totals)
        }
    }
}

private struct CheckoutExtrasSample: View {
    @State private var promo: KitoPromoCode?
    @State private var isGift = true
    @State private var note = "Happy birthday, Mum! Enjoy the coffee."
    @State private var accepted = false

    var body: some View {
        VStack(spacing: 18) {
            KitoPromoCodeField(applied: $promo, validator: CheckoutData.validator, subtotal: 1_890)
            KitoGiftNoteField(isGift: $isGift, note: $note)
            KitoTermsCheckbox(isOn: $accepted, text: CheckoutData.terms)
        }
    }
}

private struct CheckoutSuccessSample: View {
    @State private var run = 0

    var body: some View {
        KitoOrderSuccessView(order: CheckoutData.placedOrder, onTrackOrder: { run += 1 }, onContinueShopping: { run += 1 })
            .id(run)
    }
}

// MARK: - Logic

private struct CheckoutTotalsSample: View {
    @State private var mode: KitoVATMode = .inclusive
    @State private var tip: KitoTip = .none
    @State private var wholeUnits = true

    private var totals: KitoCheckoutTotals {
        let rules = KitoCheckoutPricingRules(serviceFee: .percent(2, minimum: 20), vat: KitoVAT(percent: 16, mode: mode), roundsToWholeUnits: wholeUnits)
        return KitoCheckoutTotals(items: CheckoutData.groceries(), rules: rules, deliveryFee: 250, tip: tip)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("VAT", selection: $mode) {
                Text("VAT included").tag(KitoVATMode.inclusive)
                Text("VAT added").tag(KitoVATMode.exclusive)
            }
            .pickerStyle(.segmented)
            Picker("Tip", selection: $tip) {
                Text("No tip").tag(KitoTip.none)
                Text("5%").tag(KitoTip.percent(5))
                Text("15%").tag(KitoTip.percent(15))
            }
            .pickerStyle(.segmented)
            Toggle("Round to whole shillings", isOn: $wholeUnits)
            ForEach(totals.lines) { line in
                HStack {
                    Text(line.title).fontWeight(line.kind == .total ? .bold : .regular)
                    Spacer()
                    Text(KitoCartMoney.string(line.amount, currencyCode: "KES"))
                        .monospacedDigit()
                        .foregroundStyle(line.isIncluded ? .secondary : .primary)
                }
                .font(.subheadline)
            }
        }
    }
}

private struct CheckoutOrderNumberSample: View {
    @State private var sequence = 42
    @State private var random = KitoOrderNumber.random()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            row("Dated", KitoOrderNumber.dated(sequence, date: Date()))
            row("Random", random)
            row("Grouped", KitoOrderNumber.grouped("10423381"))
            Button("Next order") {
                sequence += 1
                random = KitoOrderNumber.random()
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.body.monospaced().weight(.semibold)).contentTransition(.numericText())
        }
    }
}

private struct CheckoutAddressFormatSample: View {
    private let address = CheckoutData.addresses[1]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            format("Single line", address.formatted(.singleLine))
            format("Short", address.formatted(.short))
            format("Multi-line", address.formatted(.multiLine))
            format("Courier label", address.formatted(.courier))
            format("M-Pesa prompt to", KitoKenyanPhone.masked(address.phone) ?? "")
        }
    }

    private func format(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased()).font(.caption2.weight(.bold)).foregroundStyle(.secondary)
            Text(value).font(.subheadline)
        }
    }
}

// MARK: - Gallery

enum CheckoutSamples {
    private static let flows = KitSection("Checkout flows", symbol: "cart.fill", [
        KitSample("Grocery checkout", "Bag, delivery with slots, payment, review with promo, gift note and terms.", code: """
        @State private var checkout = KitoCheckoutModel(
            cart: cart,
            addresses: savedAddresses,
            deliveryOptions: [.standard(price: 250), .express(price: 450), .scheduled(price: 150),
                              .pickup(points: pickupPoints)],
            schedule: KitoDeliverySchedule(rules: KitoSlotRules(sameDayCutoffMinutes: 18 * 60, closedWeekdays: [1])),
            paymentMethods: [.mpesa(phone: "0712345678"), .card(.visa, last4: "4242", expiry: "08/29"),
                             .applePay, .cashOnDelivery(limit: 10_000), .wallet(balance: 850)],
            rules: KitoCheckoutPricingRules(serviceFee: .percent(2, minimum: 20), vat: .kenya,
                                            freeDeliveryThreshold: 5_000),
            promoValidator: validator, offersGiftNote: true,
            termsText: "I agree to the [Terms of Sale](https://example.com/terms)")

        KitoCheckoutFlow(model: checkout, onTrackOrder: { track($0) }) { order in
            let number = try await api.placeOrder(order)
            return order.confirmed(number: number)
        }
        """) { ModalStage { CheckoutGroceryFlow() } },
        KitSample("Food delivery with a tip", "Segmented progress, a busy express option and a rider tip.", code: """
        var priority = KitoDeliveryOption.express(price: 180, eta: .minutes(15...25), title: "Priority")
        priority.unavailableReason = "Riders are busy right now — try again soon."

        @State private var checkout = KitoCheckoutModel(
            items: order, addresses: savedAddresses,
            deliveryOptions: [.standard(price: 120, eta: .minutes(35...50)), priority, .pickup(points: [kitchen])],
            paymentMethods: [.mpesa(phone: "0712345678"), .cashOnDelivery()],
            rules: KitoCheckoutPricingRules(serviceFee: .fixed(30)),
            offersTip: true)

        KitoCheckoutFlow(model: checkout, title: "Your order", progressStyle: .segmented, tint: .orange) { order in
            try await kitchen.submit(order)
        }
        """) { ModalStage { CheckoutFoodFlow() } },
        KitSample("Click and collect", "Starts at delivery, pickup points only, “Step 1 of 3” header.", code: """
        @State private var checkout = KitoCheckoutModel(
            cart: cart, steps: [.delivery, .payment, .review],
            deliveryOptions: [.pickup(points: pickupPoints, eta: .hours(1...2), title: "Pick up in store")],
            paymentMethods: [.mpesa(phone: "0712345678"), .wallet(balance: 5_000)])

        KitoCheckoutFlow(model: checkout, title: "Click & collect", progressStyle: .text, tint: .indigo) { order in … }
        """) { ModalStage { CheckoutPickupFlow() } },
        KitSample("Apple Pay without a merchant ID", "Apple Pay is listed but switched off, with a notice explaining why.", code: """
        KitoCheckoutModel(
            items: order, steps: [.payment, .review],
            deliveryOptions: [.standard(price: 200)],
            paymentMethods: [.applePay, .mpesa(phone: "0712345678")],
            applePay: KitoApplePayConfiguration(merchantIdentifier: nil, merchantName: "Duka Moja"))
        // With "merchant.com.yourcompany.shop" and the Apple Pay capability, the review button
        // becomes Apple's button and the order carries the payment token.
        """) { ModalStage { CheckoutApplePayFlow() } },
        KitSample("Payment that fails", "The first M-Pesa attempt times out; the banner explains and you can try again.", code: """
        KitoCheckoutFlow(model: checkout) { order in
            guard case .mpesa(let phone) = order.paymentMethod.kind else { throw MpesaError.unsupported }
            let result = try await mpesa.stkPush(phone: phone, amount: order.totals.total)
            guard result.ok else { throw MpesaError.timedOut }   // LocalizedError text shows in the banner
            return order.confirmed(number: result.reference)
        }
        """) { ModalStage { CheckoutFailingFlow() } },
    ])

    private static let progress = KitSection("Progress and total", symbol: "list.number", [
        KitSample("Numbered dots", "Finished steps get a tick; tap one to go back.", code: """
        KitoCheckoutProgressHeader(current: step, style: .dots) { tapped in step = tapped }
        """) { CheckoutProgressSample(style: .dots) },
        KitSample("Segmented bar", "One bar per step with the step name and 2/4.", code: """
        KitoCheckoutProgressHeader(current: .payment, style: .segmented)
        """) { CheckoutProgressSample(style: .segmented) },
        KitSample("Step 2 of 4", "A text header with what comes next.", code: """
        KitoCheckoutProgressHeader(steps: KitoCheckoutStep.standard, current: .delivery, style: .text)
        """) { CheckoutProgressSample(style: .text) },
        KitSample("Sticky total bar", "A total that rolls and a hint while the step isn't complete.", code: """
        KitoCheckoutTotalBar(total: totals.total, caption: "\\(totals.itemCount) items",
                             button: .standard("Continue to payment"),
                             hint: model.issues.first?.message, isEnabled: model.canContinue) {
            model.advance()
        }
        """) { CheckoutTotalBarSample() },
    ])

    private static let delivery = KitSection("Delivery", symbol: "shippingbox.fill", [
        KitSample("Saved addresses", "Home, Work and your own labels, a default badge; long-press to edit.", code: """
        @State private var addresses = savedAddresses
        @State private var selection: KitoAddress.ID?

        KitoAddressPicker(addresses: $addresses, selection: $selection)
        """) { CheckoutAddressSample() },
        KitSample("New address form", "Map slot, 47 counties and their towns, Kenyan phone check.", code: """
        KitoAddressForm(onCancel: { dismiss() }, onSave: { address in save(address) })

        KitoAddressForm(onCancel: {}, onSave: save) { draft in
            MyMap(draft)            // any view, e.g. a KitoMaps map with a draggable pin
        }
        """) { ModalStage { CheckoutAddressFormSample() } },
        KitSample("Delivery options", "Standard, express, scheduled and pickup with prices and ETAs.", code: """
        KitoDeliveryOptions([.standard(price: 250, eta: .hours(2...4)), .express(price: 450),
                             .scheduled(price: 150), .pickup(points: pickupPoints)],
                            selection: $optionID, pickupPoint: $pointID)
        """) { CheckoutDeliveryOptionsSample() },
        KitSample("Delivery slots", "Day chips and two-hour windows; full and closed ones are disabled.", code: """
        let schedule = KitoDeliverySchedule(
            rules: KitoSlotRules(leadTime: 45 * 60, sameDayCutoffMinutes: 18 * 60,
                                 closedWeekdays: [1], capacity: 5),
            booked: ["2026-09-25-0800": 5])

        KitoDeliverySlotPicker(schedule: schedule, selection: $slot)
        """) { CheckoutSlotSample() },
    ])

    private static let payment = KitSection("Payment", symbol: "creditcard.fill", [
        KitSample("Payment methods", "M-Pesa, cards, Apple Pay, cash, wallet; ones that can't pay say why.", code: """
        KitoPaymentMethodList([.mpesa(phone: "0712345678"), .card(.visa, last4: "4242", expiry: "08/29"),
                               .card(.mastercard, last4: "4444", expiry: "01/25"), .applePay,
                               .cashOnDelivery(limit: 10_000), .wallet(balance: 850)],
                              selection: $methodID, total: 2_150,
                              applePay: KitoApplePay.availability(for: applePayConfig)) {
            showAddCard = true      // e.g. KitoScreens' KitoCardCheckoutScreen
        }
        """) { CheckoutPaymentSample() },
        KitSample("Apple Pay button", "PKPaymentButton in a capsule, and the not-set-up notices.", code: """
        KitoApplePayButton(type: .buy) { Task { await pay() } }
        KitoApplePayNotice(availability: KitoApplePay.availability(for: config))

        let request = try KitoApplePay.makeRequest(configuration: config, totals: totals)
        let outcome = await KitoApplePay.present(request) { payment in
            await provider.charge(payment.token.paymentData)
        }
        """) { CheckoutApplePaySample() },
        KitSample("Tip selector", "No tip, 5/10/15% with amounts, or a custom figure.", code: """
        KitoTipSelector(tip: $tip, subtotal: totals.subtotal, tint: .orange)
        """) { CheckoutTipSample() },
    ])

    private static let review = KitSection("Review and done", symbol: "checkmark.seal.fill", [
        KitSample("Order summary", "Thumbnails, promo, free delivery, service fee, VAT; the total rolls.", code: """
        let totals = KitoCheckoutTotals(items: cart.items, rules: rules, deliveryFee: 250, promo: promo)
        KitoOrderSummary(totals: totals)
        """) { CheckoutSummarySample() },
        KitSample("Promo, gift note and terms", "The review step's extras on their own.", code: """
        KitoPromoCodeField(applied: $promo, validator: validator, subtotal: totals.subtotal)
        KitoGiftNoteField(isGift: $isGift, note: $note, limit: 150)
        KitoTermsCheckbox(isOn: $accepted, text: "I agree to the [Terms of Sale](https://example.com/terms)")
        """) { CheckoutExtrasSample() },
        KitSample("Order confirmation", "Checkmark, confetti, order number to copy, ETA and a shareable receipt.", code: """
        KitoOrderSuccessView(order: placed,
                             onTrackOrder: { showTracking = true },
                             onContinueShopping: { dismiss() })
        """) { ModalStage { CheckoutSuccessSample() } },
    ])

    private static let logic = KitSection("The maths", symbol: "function", [
        KitSample("Totals", "VAT included or added, tips and rounding to whole shillings.", code: """
        let totals = KitoCheckoutTotals(
            items: cart.items,
            rules: KitoCheckoutPricingRules(serviceFee: .percent(2, minimum: 20),
                                            vat: KitoVAT(percent: 16, mode: .inclusive),
                                            roundsToWholeUnits: true),
            deliveryFee: 250, tip: .percent(15))
        totals.lines        // subtotal, delivery, service fee, VAT, tip, total
        """) { CheckoutTotalsSample() },
        KitSample("Order numbers", "Dated, random without look-alike characters, and grouped.", code: """
        KitoOrderNumber.dated(42, date: .now)     // "KC-260924-0042"
        KitoOrderNumber.random()                  // "KC-7QHM-X9TP"
        KitoOrderNumber.grouped("10423381")       // "1042 3381"
        """) { CheckoutOrderNumberSample() },
        KitSample("Address formats", "Single line, short, multi-line and a courier label.", code: """
        address.formatted(.singleLine)    // "Delta Towers, 6th floor, Waiyaki Way, Westlands, Nairobi"
        address.formatted(.short)         // "Westlands"
        address.formatted(.courier)       // name, +254 712 345 678, then the address
        KitoKenyanPhone.masked("0712345678")   // "0712 ••• 678"
        """) { CheckoutAddressFormatSample() },
    ])

    static let sections: [KitSection] = [flows, progress, delivery, payment, review, logic]
}

struct CheckoutGallery: View {
    static var count: Int { KitGallery.count(CheckoutSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Checkout",
            sections: CheckoutSamples.sections,
            footnote: "Requires `import KitoCheckout`.",
            searchHint: "Try “address”, “slots”, “M-Pesa”, “Apple Pay”, “tip” or “VAT”."
        )
    }
}
