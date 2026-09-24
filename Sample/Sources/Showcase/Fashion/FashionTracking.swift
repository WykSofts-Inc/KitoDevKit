//
//  FashionTracking.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoOrderTracking

// MARK: - Script

enum FashionTrackingScript {
    static let style = KitoOrderTrackingStyle(
        headlineFont: .system(size: 26, weight: .regular, design: .serif),
        stageLabels: [.preparing: "Being wrapped", .outForDelivery: "On its way", .delivered: "Delivered"],
        stageIcons: [.preparing: "gift.fill", .outForDelivery: "scooter"],
        cornerRadius: 16)

    static let courier = KitoCourier(name: "Baraka Otieno", phone: "+254712000111", vehicle: .motorbike,
                                     plate: "KMGA 118J", rating: 4.9, deliveries: 1_284)

    static func update(for order: FashionOrder, now: Date = Date()) -> KitoOrderUpdate {
        let stage = order.stage(at: now)
        switch stage {
        case .placed:
            return KitoOrderUpdate(stage: .placed, detail: "We've received order \(order.id).", estimatedArrival: order.eta)
        case .confirmed:
            return KitoOrderUpdate(stage: .confirmed, detail: "The atelier has checked every piece.", estimatedArrival: order.eta)
        case .preparing:
            return KitoOrderUpdate(stage: .preparing, headline: "Being wrapped",
                                   detail: "Tissue, ribbon and a handwritten card, in our Karen studio.", estimatedArrival: order.eta)
        case .outForDelivery:
            return KitoOrderUpdate(stage: .outForDelivery, headline: "On its way",
                                   detail: "\(courier.name) is bringing your parcel to \(order.destination).",
                                   estimatedArrival: order.eta, courierName: courier.name)
        default:
            return KitoOrderUpdate(stage: .delivered, headline: "Delivered",
                                   detail: "Signed for at \(order.destination). Enjoy wearing it.", courierName: courier.name)
        }
    }
}

// MARK: - Card

/// A compact tracking card: status chip, the courier riding along a track and a live ETA.
struct FashionTrackingCard: View {
    @Environment(\.kitoTheme) private var theme
    let order: FashionOrder
    let onTrack: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let stage = order.stage(at: context.date)
            Button(action: onTrack) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            FashionKicker("Order \(order.id)")
                            Text(FashionTrackingScript.style.label(for: stage))
                                .font(theme.typography.titleMedium)
                                .foregroundStyle(theme.colors.onSurface)
                        }
                        Spacer()
                        KitoOrderStatusChip(stage: stage, trackingStyle: FashionTrackingScript.style)
                    }
                    KitoOrderProgressTrack(stage: stage, vehicle: .motorbike, style: FashionTrackingScript.style)
                    HStack {
                        if stage != .delivered {
                            KitoETACountdown(eta: order.eta, start: order.placedAt, style: .pill)
                        }
                        Spacer()
                        Text("Track order")
                            .font(.system(size: 13, weight: .semibold))
                            .underline()
                            .foregroundStyle(theme.colors.onSurface)
                    }
                }
                .padding(theme.spacing.lg)
                .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous).stroke(theme.colors.border))
            }
            .buttonStyle(FashionPressStyle(scale: 0.98))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Order \(order.id), \(FashionTrackingScript.style.label(for: stage))")
            .accessibilityHint("Opens tracking")
        }
    }
}

// MARK: - Screen

/// KitoOrderTracking's screen for one order, refreshing from the scripted timeline.
struct FashionTrackingScreen: View {
    @Environment(\.kitoTheme) private var theme
    let order: FashionOrder
    @State private var viewModel: KitoOrderTrackingViewModel

    init(order: FashionOrder) {
        self.order = order
        _viewModel = State(initialValue: KitoOrderTrackingViewModel(
            orderID: order.id, merchantName: "Maison Amani",
            initial: FashionTrackingScript.update(for: order),
            refreshInterval: order.isHistoric ? 600 : 5,
            fetchUpdate: { FashionTrackingScript.update(for: order) }))
    }

    private var showsCourier: Bool {
        viewModel.update.stage == .outForDelivery || viewModel.update.stage == .delivered
    }

    var body: some View {
        KitoOrderTrackingScreen(viewModel: viewModel, style: FashionTrackingScript.style,
                                startsTrackingOnAppear: !order.isHistoric)
            .background(theme.colors.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: theme.spacing.md) {
                    if showsCourier {
                        KitoCourierCard(courier: FashionTrackingScript.courier)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    FashionOrderItemsStrip(items: order.items, total: order.total)
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, theme.spacing.md)
                .animation(.default, value: showsCourier)
            }
            .navigationTitle(order.id)
            .navigationBarTitleDisplayMode(.inline)
    }
}

/// The pieces in an order as small thumbnails with the total.
struct FashionOrderItemsStrip: View {
    @Environment(\.kitoTheme) private var theme
    let items: [KitoCartItem]
    let total: Decimal

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(items.prefix(4)) { item in
                FashionCartThumbnail(item: item).frame(width: 44, height: 44)
            }
            if items.count > 4 {
                Text("+\(items.count - 4)").font(theme.typography.caption).foregroundStyle(theme.colors.onSurface.opacity(0.6))
            }
            Spacer()
            Text(KitoCartMoney.string(total))
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundStyle(theme.colors.onSurface)
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous).stroke(theme.colors.border))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(items.count) pieces, total \(KitoCartMoney.string(total))")
    }
}
