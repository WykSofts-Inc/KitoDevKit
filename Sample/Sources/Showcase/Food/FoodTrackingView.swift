//
//  FoodTrackingView.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import CoreLocation
import KitoCore
import KitoCart
import KitoMaps
import KitoOrderTracking
import KitoIslandBar
import KitoNotifications
import KitoToasts
import KitoModals
import KitoButtons
import KitoHaptics
import KitoChat
import KitoReviews

extension FoodShowcase {

    /// Live tracking: the rider moving on the map, an ETA ring, the courier with call and chat,
    /// the order's history and a Dynamic Island–style status along the top.
    struct FoodTrackingScreen: View {
        let order: FoodActiveOrder
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme
        @Environment(\.dismiss) private var dismiss
        @State private var showsChat = false
        @State private var alert: KitoAlert?
        @State private var rating: FoodPastOrder?

        private var riderVisible: Bool { order.stage >= .outForDelivery && order.stage != .cancelled }

        private var pins: [KitoMapPin] {
            var pins = [
                KitoMapPin(id: "kitchen", coordinate: order.restaurant.coordinate, title: order.restaurant.name, subtitle: "Kitchen",
                           style: .icon(order.restaurant.cuisine.systemImage), tint: FoodPalette.pepper),
                KitoMapPin(id: "home", coordinate: order.destination.coordinate, title: "Home", subtitle: order.destination.line,
                           style: .teardrop, tint: .indigo, systemImage: "house.fill"),
            ]
            if riderVisible { pins.append(order.tracker.pin) }
            return pins
        }

        private var overlays: [KitoMapOverlay] {
            if riderVisible { return order.tracker.overlays(color: FoodPalette.pepper) }
            return [.polyline(order.tracker.remainingPath, id: "planned", color: FoodPalette.pepper.opacity(0.6), lineWidth: 5, dashed: true)]
        }

        var body: some View {
            @Bindable var store = store
            GeometryReader { proxy in
                VStack(spacing: -28) {
                    KitoMapView(pins: pins, style: .muted, camera: .fit(order.tracker.path.coordinates))
                        .overlays(overlays)
                        .controls([])
                        .followsSelection(false)
                        .fitPadding(EdgeInsets(top: 110, leading: 50, bottom: 60, trailing: 50))
                        .frame(height: proxy.size.height * 0.44 + proxy.safeAreaInsets.top)
                        .overlay(alignment: .top) { topBar.padding(.top, proxy.safeAreaInsets.top) }
                    panel
                }
                .ignoresSafeArea(edges: .top)
            }
            .background(theme.colors.background.ignoresSafeArea())
            .overlay { island }
            .kitoNotificationBanner($store.banner, style: .card)
            .kitoToastHost(store.toasts)
            .kitoAlert($alert)
            .sheet(isPresented: $showsChat) {
                FoodRiderChat(order: order)
                    .environment(store)
                    .kitoTheme(theme)
            }
            .sheet(item: $rating) { past in
                FoodRateSheet(order: past)
                    .environment(store)
                    .kitoTheme(theme)
            }
        }

        // MARK: Top

        private var topBar: some View {
            HStack(spacing: 10) {
                FoodCircleButton(systemImage: "chevron.down", label: "Close tracking") { dismiss() }
                Spacer()
                if !order.isFinished {
                    Button { store.skipAhead() } label: {
                        Label("Skip ahead", systemImage: "forward.fill")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(theme.colors.onSurface)
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                            .background(.regularMaterial, in: Capsule())
                    }
                    .buttonStyle(FoodPressStyle())
                    .accessibilityHint("Demo only: jumps the order to its next step")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }

        @ViewBuilder
        private var island: some View {
            @Bindable var store = store
            if store.island != .idle {
                Color.clear
                    .kitoDynamicIsland(presentation: $store.island) {
                        KitoOrderIslandCompactLeadingView(state: .init(from: order.update), style: FoodIsland.style)
                    } trailing: {
                        KitoOrderIslandCompactTrailingView(state: .init(from: order.update))
                    } expanded: {
                        KitoOrderIslandExpandedView(merchantName: order.restaurant.name, state: .init(from: order.update), style: FoodIsland.style)
                            .environment(\.colorScheme, .dark)
                    }
            }
        }

        // MARK: Panel

        private var panel: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Capsule().fill(theme.colors.border).frame(width: 40, height: 5).frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                    header
                    KitoOrderProgressTrack(stage: order.stage, progress: order.overallProgress, vehicle: .motorbike, style: FoodIsland.style)
                    if order.stage == .delivered {
                        delivered
                    } else if riderVisible {
                        rider
                    } else {
                        kitchen
                    }
                    card(title: "Order progress") {
                        KitoOrderEventTimeline(events: order.events, currentStage: order.stage, style: FoodIsland.style)
                    }
                    card(title: "Your order") { receipt }
                    card(title: "On your Lock Screen") {
                        KitoLiveActivityPreview(merchantName: order.restaurant.name, update: order.update, surface: .lockScreen,
                                                style: FoodIsland.style)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .background {
                UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous)
                    .fill(theme.colors.background)
                    .shadow(color: .black.opacity(0.12), radius: 20, y: -6)
                    .ignoresSafeArea(edges: .bottom)
            }
        }

        private var header: some View {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    KitoOrderStatusChip(stage: order.stage, trackingStyle: FoodIsland.style)
                    Text(order.headline)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(theme.colors.onBackground)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    Text("Order \(order.id) · \(order.restaurant.name)")
                        .font(.footnote)
                        .foregroundStyle(theme.colors.onBackground.opacity(0.55))
                }
                Spacer(minLength: 0)
                if order.isFinished {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(theme.colors.success)
                        .symbolEffect(.bounce, value: order.stage)
                        .accessibilityLabel("Delivered")
                } else {
                    // Re-read the demo clock every second: before pickup nothing else redraws this view.
                    TimelineView(.periodic(from: .now, by: 1)) { _ in
                        KitoETACountdown(eta: order.demoETA, start: order.demoStart, style: .ring, tint: FoodPalette.pepper)
                    }
                    .frame(width: 88, height: 88)
                }
            }
        }
    }
}

// MARK: - Panel sections

extension FoodShowcase.FoodTrackingScreen {
    typealias FoodPalette = FoodShowcase.FoodPalette

    fileprivate func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.colors.onSurface)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(theme.colors.border, lineWidth: 0.5))
    }

    fileprivate var rider: some View {
        VStack(spacing: 12) {
            KitoCourierCard(courier: order.courier, onCall: {
                alert = KitoAlert(systemImage: "phone.fill", tint: theme.colors.success, title: "Call \(order.firstName)?",
                                  message: "This is a demo, so no call is placed. In the app this dials \(order.courier.phone ?? "the rider").",
                                  actions: [.cancel(), KitoAlertAction("Call") {
                                      store.toasts.show(KitoToast(message: "Calling \(order.firstName)…", icon: .custom("phone.fill"),
                                                                  accentColor: theme.colors.success, duration: 2))
                                  }])
            }, onChat: { showsChat = true })
            HStack(spacing: 10) {
                Image(systemName: "lock.shield.fill").foregroundStyle(FoodPalette.pepper)
                Text("Share code **\(order.deliveryCode)** with \(order.firstName) when the food arrives.")
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.onSurface)
                Spacer(minLength: 0)
            }
            .padding(14)
            .background(FoodPalette.pepper.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .accessibilityElement(children: .combine)
        }
    }

    fileprivate var kitchen: some View {
        HStack(spacing: 14) {
            FoodShowcase.FoodArtView(art: order.restaurant.art, symbolScale: 0.46, showsPattern: false)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(order.stage == .preparing ? "In the kitchen" : "Waiting for the kitchen")
                    .font(.headline)
                    .foregroundStyle(theme.colors.onSurface)
                Text(order.stage == .preparing
                     ? "\(order.restaurant.chef) is cooking. A rider is heading to \(order.restaurant.area)."
                     : "\(order.restaurant.name) is confirming your order.")
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.onSurface.opacity(0.6))
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(theme.colors.border, lineWidth: 0.5))
    }

    fileprivate var delivered: some View {
        VStack(spacing: 12) {
            KitoDeliveryProofView(proof: KitoDeliveryProof(recipientName: "Wycliff N", deliveredAt: order.stageTimes[.delivered].map(order.demoTime) ?? Date(),
                                                           code: order.deliveryCode, note: "Handed over at the gate by \(order.firstName)"))
            if order.isRated {
                Label("Thanks for rating this order", systemImage: "star.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FoodPalette.star)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else {
                KitoButton("Rate your order", systemImage: "star.fill") {
                    rating = store.history.first { $0.id == order.id }
                }
                .fullWidth()
            }
        }
    }

    fileprivate var receipt: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(order.items) { item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("\(item.quantity)×")
                        .font(.subheadline.weight(.bold).monospacedDigit())
                        .foregroundStyle(FoodPalette.pepper)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name).font(.subheadline.weight(.medium))
                        if let subtitle = item.subtitle {
                            Text(subtitle).font(.caption).foregroundStyle(theme.colors.onSurface.opacity(0.55))
                        }
                    }
                    Spacer()
                    Text(KitoCartMoney.string(item.lineTotal)).font(.subheadline.monospacedDigit())
                }
                .foregroundStyle(theme.colors.onSurface)
                .accessibilityElement(children: .combine)
            }
            Divider()
            HStack {
                Text("Total paid").font(.subheadline.weight(.bold))
                Spacer()
                Text(KitoCartMoney.string(order.total)).font(.subheadline.weight(.heavy).monospacedDigit())
            }
            .foregroundStyle(theme.colors.onSurface)
            Label("Paid with \(order.paymentTitle)", systemImage: order.paymentTitle.contains("M-Pesa") ? "iphone.gen3" : "creditcard.fill")
                .font(.caption)
                .foregroundStyle(theme.colors.onSurface.opacity(0.6))
        }
    }
}

// MARK: - Chat with the rider

extension FoodShowcase {

    struct FoodRiderChat: View {
        @Bindable var order: FoodActiveOrder
        @Environment(FoodStore.self) private var store
        @Environment(\.kitoTheme) private var theme
        @Environment(\.dismiss) private var dismiss
        @State private var alert: KitoAlert?

        private var typing: [KitoChatUser] { store.riderTyping ? [FoodStore.rider] : [] }

        var body: some View {
            VStack(spacing: 0) {
                KitoChatHeader(user: FoodStore.rider, typingUsers: typing,
                               subtitle: "\(order.courier.vehicle.label) · \(order.courier.plate ?? "") · \(order.stage == .delivered ? "Delivered" : "\(order.minutesAway) min away")",
                               onBack: { dismiss() },
                               onCall: {
                                   alert = KitoAlert(systemImage: "phone.fill", tint: theme.colors.success, title: "Call \(order.firstName)?",
                                                     message: "This is a demo, so no call is placed.", actions: [.cancel(), KitoAlertAction("OK")])
                               })
                KitoChatView(messages: $order.messages, currentUser: FoodStore.me, style: .modern, typingUsers: typing,
                             placeholder: "Message \(order.firstName)", tint: FoodPalette.pepper,
                             onSend: { message in store.send(message, in: order) })
            }
            .background(theme.colors.background.ignoresSafeArea())
            .kitoAlert($alert)
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Rate

    /// KitoReviews' composer for a delivered order.
    struct FoodRateSheet: View {
        let order: FoodPastOrder
        @Environment(FoodStore.self) private var store

        var body: some View {
            KitoReviewComposer(subject: order.restaurant?.name ?? "Your order",
                               subtitle: "Order \(order.id) · \(order.itemCount) items",
                               rating: order.rating ?? 0, minimumCharacters: 0, requiresText: false,
                               authorName: "Wycliff N") { draft in
                try? await Task.sleep(nanoseconds: 700_000_000)
                await MainActor.run { store.rate(orderID: order.id, rating: draft.rating) }
            }
        }
    }
}
