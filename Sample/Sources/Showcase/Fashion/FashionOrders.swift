//
//  FashionOrders.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCart
import KitoEmptyStates
import KitoFormatting
import KitoOrderTracking

/// Every order, newest first, with a live card for the one on its way.
struct FashionOrdersScreen: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.kitoTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                if let active = store.activeOrder {
                    FashionKicker("On its way").padding(.horizontal, theme.spacing.lg)
                    FashionTrackingCard(order: active) { store.open(.tracking(active.id)) }
                        .padding(.horizontal, theme.spacing.lg)
                }
                if store.orders.isEmpty {
                    KitoEmptyStateView(media: .illustration(.cart.tinted(FashionPalette.gold, FashionPalette.cognac)),
                                       title: "No orders yet", message: "Your orders and their tracking will live here.")
                } else {
                    FashionKicker("All orders").padding(.horizontal, theme.spacing.lg)
                    ForEach(store.orders) { order in
                        Button { store.open(.tracking(order.id)) } label: { FashionOrderRow(order: order) }
                            .buttonStyle(FashionPressStyle(scale: 0.98))
                            .padding(.horizontal, theme.spacing.lg)
                    }
                }
            }
            .padding(.vertical, theme.spacing.lg)
        }
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle("Orders")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FashionOrderRow: View {
    @Environment(\.kitoTheme) private var theme
    let order: FashionOrder

    var body: some View {
        TimelineView(.periodic(from: .now, by: 5)) { context in
            let stage = order.stage(at: context.date)
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(order.id).font(theme.typography.bodyEmphasized).foregroundStyle(theme.colors.onSurface)
                        Text("\(KitoDateFormatting.mediumDate(order.placedAt)) · \(order.itemCount == 1 ? "1 piece" : "\(order.itemCount) pieces")")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.onSurface.opacity(0.6))
                    }
                    Spacer()
                    KitoOrderStatusChip(stage: stage, style: stage == .delivered ? .solid : .tinted,
                                        trackingStyle: FashionTrackingScript.style)
                }
                HStack(spacing: theme.spacing.sm) {
                    ForEach(order.items.prefix(4)) { item in
                        FashionCartThumbnail(item: item).frame(width: 52, height: 52)
                    }
                    Spacer()
                    Text(KitoCartMoney.string(order.total))
                        .font(.system(size: 17, weight: .regular, design: .serif))
                        .foregroundStyle(theme.colors.onSurface)
                }
            }
            .padding(theme.spacing.lg)
            .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous).stroke(theme.colors.border))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Order \(order.id), \(FashionTrackingScript.style.label(for: stage)), \(KitoCartMoney.string(order.total))")
            .accessibilityAddTraits(.isButton)
        }
    }
}
