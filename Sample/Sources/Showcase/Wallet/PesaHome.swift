//
//  PesaHome.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoNavigation
import KitoWalletCards
import KitoFormatting
import KitoNotifications
import KitoButtons
import KitoToasts
import KitoHaptics

extension WalletShowcase {
    enum PesaHomeRoute: KitoRoute {
        case transactions
        case transaction(UUID)
    }

    enum PesaMoneySheet: String, Identifiable {
        case request, topUp, payBill, inbox
        var id: String { rawValue }
    }

    struct PesaHomeTab: View {
        @Bindable var store: PesaStore
        let openTab: (PesaTab) -> Void

        @State private var router = KitoRouter<PesaHomeRoute>()

        var body: some View {
            KitoRouterView(router: router) {
                PesaHomeScreen(store: store, router: router, openTab: openTab)
            } destination: { route in
                switch route {
                case .transactions:
                    PesaTransactionsScreen(store: store) { router.push(.transaction($0.id)) }
                case .transaction(let id):
                    if let transaction = store.transactions.first(where: { $0.id == id }) {
                        PesaTransactionDetail(store: store, transaction: transaction)
                    }
                }
            }
        }
    }

    private struct PesaHomeScreen: View {
        @Bindable var store: PesaStore
        let router: KitoRouter<PesaHomeRoute>
        let openTab: (PesaTab) -> Void

        @Environment(KitoToastCenter.self) private var toasts
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var isSending = false
        @State private var sheet: PesaMoneySheet?
        @State private var pocketOpen = false

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    greeting
                    balance
                    quickActions
                    pocket
                    if let goal = store.goals.first { PesaGoalCard(store: store, goal: goal) }
                    recent
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Home")
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $isSending) { PesaSendFlow(store: store) }
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .request: PesaRequestSheet(store: store)
                case .topUp: PesaTopUpSheet(store: store)
                case .payBill: PesaPayBillSheet(store: store)
                case .inbox: PesaInboxSheet(store: store)
                }
            }
        }

        private var greeting: some View {
            HStack(spacing: 12) {
                KitoAvatar(initials: "WN", colors: [.black, Color(white: 0.35)], size: 44, showsRing: true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(KitoDateFormatting.greeting())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Wycliff")
                        .font(.title3.weight(.bold))
                }
                .accessibilityElement(children: .combine)
                Spacer()
                PesaExitButton { exitDemo() }
                Button { sheet = .inbox } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 40, height: 40)
                        .background(Color(.secondarySystemGroupedBackground), in: Circle())
                        .overlay(alignment: .topTrailing) {
                            if store.unreadCount > 0 {
                                Text("\(store.unreadCount)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 18, minHeight: 18)
                                    .background(Color.red, in: Circle())
                                    .offset(x: 4, y: -4)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Notifications")
                .accessibilityValue(store.unreadCount > 0 ? "\(store.unreadCount) unread" : "None unread")
            }
            .padding(.top, 8)
        }

        @Environment(\.pesaExit) private var exit
        private func exitDemo() { exit() }

        private var balance: some View {
            let spent = store.totalSpent(inMonthOf: .now)
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
            let previous = store.totalSpent(inMonthOf: lastMonth)
            return VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("Total balance")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Button {
                        KitoHaptics.selectionChanged()
                        withAnimation(reduceMotion ? nil : .snappy) { store.isBalanceHidden.toggle() }
                    } label: {
                        Image(systemName: store.isBalanceHidden ? "eye.slash.fill" : "eye.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(store.isBalanceHidden ? "Show balance" : "Hide balance")
                }
                Group {
                    if store.isBalanceHidden {
                        Text(PesaMoney.hidden)
                            .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .leading)))
                    } else {
                        KitoCountingText(store.totalBalance, duration: 1.0) { PesaMoney.string($0.rounded(), cents: .never) }
                            .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .leading)))
                    }
                }
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .accessibilityLabel(store.isBalanceHidden ? "Balance hidden" : PesaMoney.string(store.totalBalance))

                if previous > 0 {
                    HStack(spacing: 8) {
                        KitoChangeBadge(spent / previous - 1, fractionDigits: 0, invertsColors: true)
                        Text(store.isBalanceHidden ? "spending vs last month" : "\(PesaMoney.string(spent, cents: .never)) spent this month")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }

        private var quickActions: some View {
            HStack(spacing: 8) {
                PesaQuickAction(title: "Send", systemImage: "arrow.up.right") { isSending = true }
                PesaQuickAction(title: "Request", systemImage: "arrow.down.left") { sheet = .request }
                PesaQuickAction(title: "Top up", systemImage: "plus") { sheet = .topUp }
                PesaQuickAction(title: "Pay bill", systemImage: "doc.text.fill") { sheet = .payBill }
            }
        }

        private var pocket: some View {
            VStack(alignment: .leading, spacing: 12) {
                PesaSectionHeader(title: "Pockets", actionTitle: "Cards") { openTab(.cards) }
                KitoWalletPocket(cards: store.cards.map(\.face), isRevealed: $pocketOpen, style: .midnight,
                                 title: "Across \(store.cards.count) pockets", showLabel: "Show pockets", hideLabel: "Hide pockets")
                    .padding(20)
                    .background(
                        LinearGradient(colors: [Color(red: 0.08, green: 0.09, blue: 0.2), Color(red: 0.03, green: 0.03, blue: 0.08)],
                                       startPoint: .top, endPoint: .bottom),
                        in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                    )
                    .environment(\.colorScheme, .dark)
                    .onChange(of: store.isBalanceHidden) { _, hidden in if hidden { pocketOpen = false } }
            }
        }

        private var recent: some View {
            VStack(alignment: .leading, spacing: 12) {
                PesaSectionHeader(title: "Recent", actionTitle: "See all") { router.push(.transactions) }
                VStack(spacing: 0) {
                    ForEach(Array(store.transactions.prefix(6).enumerated()), id: \.element.id) { index, transaction in
                        Button { router.push(.transaction(transaction.id)) } label: {
                            PesaTransactionRow(transaction: transaction, contact: store.contact(transaction.contactID),
                                               isHidden: store.isBalanceHidden)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        if index < 5 { Divider().padding(.leading, 56) }
                    }
                }
                .pesaSurface(padding: 12)
            }
        }
    }

    /// The first savings goal as a ring, with a one-tap top-up.
    private struct PesaGoalCard: View {
        @Bindable var store: PesaStore
        let goal: PesaGoal

        @Environment(KitoToastCenter.self) private var toasts

        var body: some View {
            HStack(spacing: 16) {
                ZStack {
                    PesaRing(progress: goal.progress, color: goal.color, lineWidth: 9)
                    VStack(spacing: 0) {
                        Image(systemName: goal.systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(goal.color)
                        Text(KitoNumberFormatting.percent(goal.progress))
                            .font(.caption.weight(.bold))
                            .monospacedDigit()
                            .contentTransition(.numericText(value: goal.progress))
                    }
                }
                .frame(width: 76, height: 76)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name).font(.headline)
                    Text("\(PesaMoney.string(goal.saved, cents: .never)) of \(PesaMoney.string(goal.target, cents: .never))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Text("By \(goal.due.formatted(.dateTime.month(.wide).year()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityValue("\(KitoNumberFormatting.percent(goal.progress)) saved")
                Spacer(minLength: 0)
                KitoButton(systemImage: "plus", accessibilityLabel: "Add KES 1,000 to \(goal.name)") {
                    try await Task.sleep(for: .milliseconds(450))
                    withAnimation(.snappy) { store.addToGoal(1_000, goalID: goal.id) }
                    toasts.show(KitoToast(title: "KES 1,000 saved", message: "\(goal.name) is \(KitoNumberFormatting.percent(store.goals[0].progress)) there.",
                                          style: .success, icon: .custom(goal.systemImage)))
                }
                .variant(.tonal)
                .disabled(goal.progress >= 1)
            }
            .pesaSurface()
        }
    }

    struct PesaInboxSheet: View {
        @Bindable var store: PesaStore
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationStack {
                KitoNotificationInbox($store.inbox, title: "Notifications") { item in
                    if let index = store.inbox.firstIndex(where: { $0.id == item.id }) { store.inbox[index].isRead = true }
                }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
                    }
            }
        }
    }
}
