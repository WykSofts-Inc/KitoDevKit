//
//  FashionAccount.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCheckout
import KitoFormatting
import KitoPaywall
import KitoToasts

/// Account: profile, the Maison Privé membership, orders and preferences.
struct FashionAccountScreen: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.kitoTheme) private var theme
    @Environment(\.fashionExit) private var exit

    @State private var showsPrive = false
    @State private var showsAddresses = false
    @State private var notifications = true
    @State private var confirmsSignOut = false

    var body: some View {
        @Bindable var store = store
        @Bindable var checkout = store.checkout
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                Text(KitoDateFormatting.greeting())
                    .font(theme.typography.displayLarge)
                    .foregroundStyle(theme.colors.onBackground)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal, theme.spacing.lg)
                profile
                FashionPriveCard(isMember: store.prive.isPro) { showsPrive = true }
                    .padding(.horizontal, theme.spacing.lg)

                FashionRowGroup(title: "Shopping") {
                    FashionRow(systemImage: "shippingbox", title: "Orders",
                               detail: store.orders.count == 1 ? "1 order" : "\(store.orders.count) orders") { store.open(.orders) }
                    FashionRow(systemImage: "heart", title: "Wishlist", detail: "\(store.wishlist.count) saved") { store.show(.wishlist) }
                    FashionRow(systemImage: "mappin.and.ellipse", title: "Addresses",
                               detail: "\(store.checkout.addresses.count) saved") { showsAddresses = true }
                    FashionRow(systemImage: "creditcard", title: "Payment", detail: "M-Pesa, Visa ·· 4242")
                }

                FashionRowGroup(title: "Preferences", footer: "Maison follows the system appearance unless you pick one here.") {
                    FashionRowContainer(systemImage: "circle.lefthalf.filled", title: "Appearance") {
                        Picker("Appearance", selection: $store.appearance) {
                            ForEach(FashionAppearance.allCases) { Text($0.title).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 190)
                    }
                    FashionRowContainer(systemImage: "bell", title: "New-in alerts") {
                        Toggle("New-in alerts", isOn: $notifications).labelsHidden()
                    }
                    FashionRow(systemImage: "ruler", title: "My sizes", detail: "M · EU 40")
                }

                FashionRowGroup(title: "Maison Amani") {
                    FashionRow(systemImage: "storefront", title: "Boutiques", detail: "Karen · Westlands")
                    FashionRow(systemImage: "bubble.left.and.bubble.right", title: "Client care", detail: "Daily, 8 AM–9 PM") {
                        store.toasts.show(KitoToast(title: "Client care", message: "A stylist will message you shortly. This is a demo, so nobody will.",
                                                    icon: .custom("bubble.left.and.bubble.right.fill"), accentColor: FashionPalette.gold))
                    }
                    if store.user != nil {
                        FashionRow(systemImage: "rectangle.portrait.and.arrow.right", title: "Sign out", isDestructive: true) {
                            confirmsSignOut = true
                        }
                    }
                    FashionRow(systemImage: "xmark.circle", title: "Exit demo", isDestructive: true) { exit() }
                }

                Text("Maison Amani is a Kito DevKit showcase. Designers, products and prices are invented; nothing is charged.")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.colors.onBackground.opacity(0.45))
                    .padding(.horizontal, theme.spacing.lg)
            }
            .padding(.top, theme.spacing.md)
            .padding(.bottom, theme.spacing.xxl)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .kitoPaywall(isPresented: $showsPrive, store: store.prive, style: .luxe, content: FashionCheckoutSetup.priveContent,
                     tint: FashionPalette.gold) { _ in
            store.toasts.show(KitoToast(title: "Welcome to Maison Privé", message: "Use PRIVE15 at checkout for 15% off.",
                                        icon: .custom("crown.fill"), accentColor: FashionPalette.gold, duration: 4))
        }
        .sheet(isPresented: $showsAddresses) {
            NavigationStack {
                ScrollView {
                    KitoAddressPicker(addresses: $checkout.addresses, selection: $checkout.selectedAddressID)
                        .padding(theme.spacing.lg)
                }
                .background(theme.colors.background.ignoresSafeArea())
                .navigationTitle("Addresses")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { showsAddresses = false }.fontWeight(.semibold) } }
            }
            .presentationDragIndicator(.visible)
        }
        .confirmationDialog("Sign out of Maison?", isPresented: $confirmsSignOut, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) { store.signOut() }
        } message: {
            Text("Your bag and wishlist stay on this device.")
        }
    }

    private var profile: some View {
        HStack(spacing: theme.spacing.md) {
            Circle()
                .fill(theme.colors.primary)
                .overlay {
                    if let user = store.user {
                        Text(user.initials).font(.system(size: 22, weight: .regular, design: .serif)).foregroundStyle(theme.colors.onPrimary)
                    } else {
                        Image(systemName: "person").font(.system(size: 22)).foregroundStyle(theme.colors.onPrimary)
                    }
                }
                .frame(width: 60, height: 60)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(store.user?.name ?? "Guest")
                    .font(theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.onBackground)
                Text(store.user?.email ?? "Sign in to keep your bag and wishlist everywhere")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.onBackground.opacity(0.6))
            }
            Spacer()
            if store.user == nil {
                Button("Sign in") { store.phase = .welcome }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.colors.onPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(theme.colors.primary, in: Capsule())
            }
        }
        .padding(.horizontal, theme.spacing.lg)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Maison Privé card

private struct FashionPriveCard: View {
    let isMember: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("MAISON PRIVÉ")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(3)
                        .foregroundStyle(FashionPalette.gold)
                    Spacer()
                    Image(systemName: "crown.fill").foregroundStyle(FashionPalette.gold)
                }
                Text(isMember ? "You're a member" : "Our private client circle")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(.white)
                Text(isMember ? "Early access, free same-day delivery and your stylist are ready."
                              : "Early access, free same-day delivery in Nairobi and a personal stylist.")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
                Text(isMember ? "Manage membership" : "Join from KES 1,500 a month")
                    .font(.system(size: 13, weight: .semibold))
                    .underline()
                    .foregroundStyle(FashionPalette.gold)
                    .padding(.top, 4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [Color(red: 0.10, green: 0.09, blue: 0.08), Color(red: 0.20, green: 0.16, blue: 0.11)],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(FashionPalette.gold.opacity(0.35)))
        }
        .buttonStyle(FashionPressStyle(scale: 0.98))
        .accessibilityElement(children: .combine)
        .accessibilityHint(isMember ? "Shows your membership" : "Shows the membership plans")
    }
}

// MARK: - Rows

/// A rounded group of rows with an optional title and footer.
struct FashionRowGroup<Content: View>: View {
    @Environment(\.kitoTheme) private var theme
    let title: String
    var footer: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FashionKicker(title).padding(.leading, 4)
            VStack(spacing: 0) { content() }
                .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous).stroke(theme.colors.border))
            if let footer {
                Text(footer).font(theme.typography.caption).foregroundStyle(theme.colors.onBackground.opacity(0.5)).padding(.leading, 4)
            }
        }
        .padding(.horizontal, theme.spacing.lg)
    }
}

/// A settings-style row. Without an action it's a plain, non-tappable line of information.
struct FashionRow: View {
    @Environment(\.kitoTheme) private var theme
    let systemImage: String
    let title: String
    var detail: String? = nil
    var isDestructive = false
    var action: (() -> Void)? = nil

    var body: some View {
        if let action {
            Button(action: action) { label(chevron: !isDestructive) }
                .buttonStyle(FashionPressStyle(scale: 0.99))
        } else {
            label(chevron: false).accessibilityElement(children: .combine)
        }
    }

    private func label(chevron: Bool) -> some View {
        let tint = isDestructive ? theme.colors.danger : theme.colors.onSurface
        return HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 16))
                .foregroundStyle(tint)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(title).font(theme.typography.body).foregroundStyle(tint)
            Spacer(minLength: 8)
            if let detail {
                Text(detail).font(theme.typography.label).foregroundStyle(theme.colors.onSurface.opacity(0.55)).lineLimit(1)
            }
            if chevron {
                Image(systemName: "chevron.right").font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.onSurface.opacity(0.3))
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }
}

/// A row with a control on the trailing side.
struct FashionRowContainer<Control: View>: View {
    @Environment(\.kitoTheme) private var theme
    let systemImage: String
    let title: String
    @ViewBuilder let control: () -> Control

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage).font(.system(size: 16)).foregroundStyle(theme.colors.onSurface)
                .frame(width: 24).accessibilityHidden(true)
            Text(title).font(theme.typography.body).foregroundStyle(theme.colors.onSurface)
            Spacer(minLength: 8)
            control()
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
    }
}
