//
//  EmptyStatesSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoLoaders
import KitoEmptyStates

// MARK: - Building blocks

/// The top of an app screen — a title, a trailing control and optional filter chips —
/// with the empty state under it, so each sample reads in context.
private struct EmptyStatesScreen<Content: View>: View {
    let title: String
    var trailing = "ellipsis"
    var chips: [String] = []
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title).font(.title2.bold())
                Spacer()
                Image(systemName: trailing).font(.body.weight(.semibold))
                    .frame(width: 36, height: 36).background(Circle().fill(Color.primary.opacity(0.06)))
            }
            if !chips.isEmpty {
                HStack(spacing: 8) {
                    ForEach(Array(chips.enumerated()), id: \.offset) { index, chip in
                        Text(chip).font(.caption.weight(.semibold)).padding(.horizontal, 12).padding(.vertical, 7)
                            .background(Capsule().fill(index == 0 ? Color.primary : Color.primary.opacity(0.06)))
                            .foregroundStyle(index == 0 ? Color(.systemBackground) : .primary)
                    }
                }
            }
            content().frame(maxWidth: .infinity)
        }
    }
}

private struct EmptyStatesSearchField: View {
    let query: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            Text(query)
            Spacer()
            Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary)
        }
        .font(.subheadline)
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.primary.opacity(0.06)))
    }
}

// MARK: - Samples with state

private struct EmptyStatesOffline: View {
    @State private var isRetrying = false
    @State private var attempts = 0

    var body: some View {
        KitoEmptyStateView(
            media: .illustration(.offline),
            title: "You're offline",
            message: attempts == 0 ? "Check your data bundle or Wi-Fi, then try again." : "Still no connection after \(attempts) \(attempts == 1 ? "try" : "tries").",
            actions: [KitoEmptyStateAction(title: "Retry") { Task { await retry() } }]
        )
        .kitoLoadingOverlay(isPresented: isRetrying, message: "Reconnecting…", blurRadius: 4, dimming: 0)
    }

    private func retry() async {
        isRetrying = true
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        attempts += 1
        isRetrying = false
    }
}

private struct EmptyStatesWalletCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Kito Pay · Wycliff N").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.75))
                Text("KSh 0.00").font(.title.bold()).foregroundStyle(.white)
                Text("New account · opened today").font(.caption).foregroundStyle(.white.opacity(0.7))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.16), Color(red: 0.3, green: 0.28, blue: 0.42)], startPoint: .topLeading, endPoint: .bottomTrailing))

            Text("Recent activity").font(.subheadline.weight(.semibold)).padding([.horizontal, .top], 16)
            KitoEmptyStateView(
                media: .illustration(.wallet),
                title: "No transactions yet",
                message: "Send, pay or buy airtime and it'll show up here.",
                actions: [KitoEmptyStateAction(title: "Send money") {}],
                layout: .compact
            )
        }
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(.secondarySystemBackground)))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct EmptyStatesPaymentMethods: View {
    @State private var cards: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment methods").font(.headline)
            HStack(spacing: 12) {
                Image(systemName: "iphone.gen3").foregroundStyle(.green)
                    .frame(width: 34, height: 34).background(Circle().fill(Color.green.opacity(0.14)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("M-Pesa").font(.subheadline.weight(.semibold))
                    Text("0712 ••• 678 · Default").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.primary.opacity(0.04)))

            if cards.isEmpty {
                KitoEmptyStateView(
                    media: .systemImage("creditcard"),
                    title: "No cards saved",
                    message: "Add a Visa or Mastercard for online shops.",
                    actions: [KitoEmptyStateAction(title: "Add") { withAnimation(.spring) { cards = ["•••• 4120"] } }],
                    layout: .inline
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "creditcard.fill").foregroundStyle(.indigo)
                        .frame(width: 34, height: 34).background(Circle().fill(Color.indigo.opacity(0.14)))
                    Text("Card \(cards[0])").font(.subheadline.weight(.semibold))
                    Spacer()
                    Button("Remove") { withAnimation(.spring) { cards = [] } }.font(.subheadline.weight(.semibold)).foregroundStyle(.red)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.primary.opacity(0.04)))
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
    }
}

private struct EmptyStatesTodayCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("THURSDAY").font(.caption2.weight(.bold)).foregroundStyle(.red)
                    Text("24 September").font(.title3.bold())
                }
                Spacer()
                Image(systemName: "plus").font(.body.weight(.semibold))
                    .frame(width: 34, height: 34).background(Circle().fill(Color.primary.opacity(0.06)))
            }
            .padding([.horizontal, .top], 16)
            KitoEmptyStateView(
                media: .illustration(.calendar),
                title: "Nothing scheduled",
                message: "A free day. Chai at Java House, maybe?",
                actions: [KitoEmptyStateAction(title: "Add event") {}, KitoEmptyStateAction(title: "Find time", role: .secondary) {}],
                layout: .compact
            )
        }
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}

private struct EmptyStatesStateCycle: View {
    private struct StatementError: LocalizedError {
        var errorDescription: String? { "We couldn't reach the statements service (503)." }
    }

    @State private var state: KitoLoadState<[String]> = .loading
    @State private var succeedsNext = false

    var body: some View {
        VStack(spacing: 16) {
            KitoStateView(state, retry: { Task { await load() } }) { items in
                VStack(spacing: 10) {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Image(systemName: "doc.text.fill").foregroundStyle(.indigo)
                            Text(item).font(.subheadline.weight(.medium))
                            Spacer()
                            Image(systemName: "arrow.down.circle").foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.primary.opacity(0.04)))
                    }
                }
                .transition(.opacity)
            }
            .frame(minHeight: 320)
            .animation(.easeInOut(duration: 0.3), value: state.isLoading)

            Text(stateLabel).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
        }
        .task { await load() }
    }

    private var stateLabel: String {
        switch state {
        case .idle: return "Idle"
        case .loading: return "State: .loading"
        case .loaded: return "State: .loaded — pull a new statement to start again"
        case .failed: return "State: .failed — tap Try again"
        }
    }

    private func load() async {
        withAnimation { state = .loading }
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        withAnimation {
            state = succeedsNext ? .loaded(["September 2026 statement", "August 2026 statement", "July 2026 statement"]) : .failed(StatementError())
        }
        succeedsNext.toggle()
    }
}

private struct EmptyStatesLibrary: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
            ForEach(KitoEmptyStateIllustration.presets, id: \.name) { illustration in
                VStack(spacing: 4) {
                    KitoEmptyStateIllustrationView(illustration, size: 96)
                    Text(illustration.name).font(.caption2.weight(.medium)).foregroundStyle(.secondary)
                        .lineLimit(1).minimumScaleFactor(0.8)
                }
            }
        }
    }
}

// MARK: - Code

private func illustratedCode(_ preset: String, _ title: String, _ message: String, action: String? = nil) -> String {
    let actions = action.map { ",\n    actions: [KitoEmptyStateAction(title: \"\($0)\") { … }]" } ?? ""
    return """
    KitoEmptyStateView(
        media: .illustration(.\(preset)),
        title: "\(title)",
        message: "\(message)"\(actions)
    )
    """
}

private let noTrips = KitoEmptyStateIllustration(
    name: "No trips", symbol: "airplane", satellites: ["suitcase.fill", "map.fill", "camera.fill"],
    colors: [Color(red: 0.05, green: 0.65, blue: 0.7), Color(red: 0.95, green: 0.6, blue: 0.2)], motion: .float
)

// MARK: - Catalogue

enum EmptyStatesSamples {
    static let sections: [KitSection] = [everyday, money, outcomes, layouts, custom, state, library]

    static let everyday = KitSection("Everyday", symbol: "tray", [
        KitSample("Empty inbox", "An envelope-and-tray illustration, gently floating.", code: "KitoEmptyStateView.emptyInbox()") {
            EmptyStatesScreen(title: "Inbox", trailing: "square.and.pencil", chips: ["All", "Unread", "Flagged"]) {
                KitoEmptyStateView.emptyInbox(message: "Messages from Kito Pay, riders and friends land here.")
            }
        },
        KitSample("No search results", "The magnifier sweeps; the query is in the title.", code: illustratedCode("search", "No results for “nyama choma karen”", "Try a different spelling, or search nearby.", action: "Clear search")) {
            EmptyStatesScreen(title: "Search", trailing: "slider.horizontal.3") {
                VStack(spacing: 4) {
                    EmptyStatesSearchField(query: "nyama choma karen")
                    KitoEmptyStateView(media: .illustration(.search), title: "No results for “nyama choma karen”",
                                       message: "Try a different spelling, or search nearby.",
                                       actions: [KitoEmptyStateAction(title: "Search near me") {}, KitoEmptyStateAction(title: "Clear search", role: .secondary) {}],
                                       actionsAxis: .horizontal)
                }
            }
        },
        KitSample("Offline", "Retry reconnects behind a loading card.", code: illustratedCode("offline", "You're offline", "Check your data bundle or Wi-Fi, then try again.", action: "Retry")) {
            EmptyStatesOffline()
        },
        KitSample("Empty cart", "The cart rocks, waiting to be filled.", code: "KitoEmptyStateView.emptyCart { router.push(.shop) }") {
            EmptyStatesScreen(title: "Basket", trailing: "trash") { KitoEmptyStateView.emptyCart {} }
        },
        KitSample("No notifications", "The bell swings now and then.", code: "KitoEmptyStateView.noNotifications()") {
            EmptyStatesScreen(title: "Notifications", trailing: "gearshape", chips: ["All", "Payments", "Orders"]) { KitoEmptyStateView.noNotifications() }
        },
        KitSample("No favourites", "A heart that beats.", code: "KitoEmptyStateView.noFavourites { router.push(.explore) }") {
            EmptyStatesScreen(title: "Favourites", trailing: "heart") { KitoEmptyStateView.noFavourites {} }
        },
        KitSample("Location off", "A bouncing pin with a way to Settings.", code: "KitoEmptyStateView.locationOff {\n    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)\n}") {
            EmptyStatesScreen(title: "Nearby", trailing: "map") { KitoEmptyStateView.locationOff {} }
        },
        KitSample("No photos", "Two actions side by side.", code: illustratedCode("photos", "No photos yet", "Photos from your safaris will show up here.")) {
            EmptyStatesScreen(title: "Photos", trailing: "plus", chips: ["Library", "Albums"]) {
                KitoEmptyStateView(media: .illustration(.photos), title: "No photos yet", message: "Photos from your safaris will show up here.",
                                   actions: [KitoEmptyStateAction(title: "Take photo") {}, KitoEmptyStateAction(title: "Import", role: .secondary) {}],
                                   actionsAxis: .horizontal)
            }
        },
    ])

    static let money = KitSection("Money", symbol: "creditcard", [
        KitSample("No transactions", "Compact, inside a wallet card.", code: """
        KitoEmptyStateView(
            media: .illustration(.wallet),
            title: "No transactions yet",
            message: "Send, pay or buy airtime and it'll show up here.",
            actions: [KitoEmptyStateAction(title: "Send money") { … }],
            layout: .compact
        )
        """) { EmptyStatesWalletCard() },
        KitSample("No saved cards", "One dashed row in a form; tap Add.", code: """
        KitoEmptyStateView(
            media: .systemImage("creditcard"),
            title: "No cards saved",
            message: "Add a Visa or Mastercard for online shops.",
            actions: [KitoEmptyStateAction(title: "Add") { addCard() }],
            layout: .inline
        )
        """) { EmptyStatesPaymentMethods() },
    ])

    static let outcomes = KitSection("Errors & success", symbol: "exclamationmark.triangle", [
        KitSample("Something went wrong", "A shake, a retry and a way out.", code: illustratedCode("error", "Something went wrong", "We couldn't load your statement. Error 503.", action: "Try again")) {
            KitoEmptyStateView(media: .illustration(.error), title: "Something went wrong", message: "We couldn't load your statement. Error 503.",
                               actions: [KitoEmptyStateAction(title: "Try again") {}, KitoEmptyStateAction(title: "Contact support", role: .secondary) {}])
        },
        KitSample("Payment sent", "Full screen, with a bouncing seal.", code: """
        KitoEmptyStateView(
            media: .illustration(.success),
            title: "Payment sent!",
            message: "KSh 2,500 to Achieng Odhiambo",
            actions: [KitoEmptyStateAction(title: "Done") { dismiss() },
                      KitoEmptyStateAction(title: "Share receipt", role: .secondary) { share() }],
            layout: .fullScreen
        )
        """) {
            ModalStage {
                KitoEmptyStateView(media: .illustration(.success), title: "Payment sent!",
                                   message: "KSh 2,500 to Achieng Odhiambo\nReceipt RKT4H2L9QX · 09:41",
                                   actions: [KitoEmptyStateAction(title: "Done") {}, KitoEmptyStateAction(title: "Share receipt", role: .secondary) {}],
                                   layout: .fullScreen)
            }
        },
        KitSample("Locked", "A padlock that shakes its head.", code: illustratedCode("locked", "Statements are locked", "Use Face ID to see your statements.", action: "Unlock with Face ID")) {
            KitoEmptyStateView(media: .illustration(.locked), title: "Statements are locked", message: "Use Face ID to see your statements.",
                               actions: [KitoEmptyStateAction(title: "Unlock with Face ID") {}])
        },
    ])

    static let layouts = KitSection("Layouts", symbol: "rectangle.3.group", [
        KitSample("Compact", "Illustration beside the text, for cards and list sections.", code: "KitoEmptyStateView(media: .illustration(.calendar), title: \"Nothing scheduled\",\n                   actions: [add, findTime], layout: .compact)") {
            EmptyStatesTodayCard()
        },
        KitSample("Full screen", "Tinted backdrop, bigger art, actions pinned to the bottom.", code: "KitoEmptyStateView(media: .illustration(.offline), title: \"No connection\",\n                   actions: [retry, offlineMode], layout: .fullScreen)") {
            ModalStage {
                KitoEmptyStateView(media: .illustration(.offline.tinted(.indigo, .purple)), title: "No connection",
                                   message: "Kito works offline too: your cards, tickets and receipts are saved on this phone.",
                                   actions: [KitoEmptyStateAction(title: "Try again") {}, KitoEmptyStateAction(title: "Use offline", role: .secondary) {}],
                                   layout: .fullScreen)
            }
        },
        KitSample("Side-by-side actions", "Two choices in a row.", code: "KitoEmptyStateView(media: .illustration(.messages), title: \"No messages\",\n                   actions: [newChat, invite], actionsAxis: .horizontal)") {
            KitoEmptyStateView(media: .illustration(.messages), title: "No messages", message: "Say jambo to someone, or invite your crew.",
                               actions: [KitoEmptyStateAction(title: "New chat") {}, KitoEmptyStateAction(title: "Invite", role: .secondary) {}],
                               actionsAxis: .horizontal)
        },
    ])

    static let custom = KitSection("Make your own", symbol: "paintbrush", [
        KitSample("Your own illustration", "Any SF Symbol, satellites, colours and motion.", code: """
        let noTrips = KitoEmptyStateIllustration(
            name: "No trips", symbol: "airplane",
            satellites: ["suitcase.fill", "map.fill", "camera.fill"],
            colors: [.teal, .orange], motion: .float
        )
        KitoEmptyStateView(media: .illustration(noTrips), title: "No trips planned")
        """) {
            KitoEmptyStateView(media: .illustration(noTrips), title: "No trips planned", message: "Diani, Naivasha or the Mara: where to next?",
                               actions: [KitoEmptyStateAction(title: "Plan a trip") {}])
        },
        KitSample("Tinted preset", "A preset in your brand's colours.", code: "KitoEmptyStateView.illustrated(.downloads.tinted(.black, .gray), title: \"No downloads\")") {
            KitoEmptyStateView.illustrated(.downloads.tinted(Color(white: 0.12), Color(white: 0.45)), title: "No downloads",
                                           message: "Download playlists and podcasts for the matatu ride home.")
        },
        KitSample("Classic SF Symbol", "The original, simplest media.", code: "KitoEmptyStateView(systemImage: \"tray\", title: \"Nothing here yet\",\n                   action: KitoEmptyStateAction(title: \"Add item\") { … })") {
            KitoEmptyStateView(systemImage: "list.bullet.clipboard", title: "No shopping list", message: "Add what you need from Marikiti.",
                               action: KitoEmptyStateAction(title: "Add item") {})
        },
    ])

    static let state = KitSection("Whole-screen state", symbol: "arrow.triangle.branch", [
        KitSample("KitoStateView", "Loading, failed with retry, then loaded, from one KitoLoadState.", code: """
        KitoStateView(viewModel.state, retry: viewModel.reload) { statements in
            StatementsList(statements)
        }
        """) { EmptyStatesStateCycle() },
    ])

    static let library = KitSection("Library", symbol: "square.grid.3x3", [
        KitSample("Every illustration", "All fifteen presets, animating together.", code: "ForEach(KitoEmptyStateIllustration.presets, id: \\.name) {\n    KitoEmptyStateIllustrationView($0, size: 96)\n}") {
            EmptyStatesLibrary()
        },
    ])
}

/// Every empty-state sample. Keeps the home screen's entry name.
struct EmptyStatesDemo: View {
    static var count: Int { KitGallery.count(EmptyStatesSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Empty States",
            sections: EmptyStatesSamples.sections,
            footnote: "Requires `import KitoEmptyStates`.",
            searchHint: "Try “offline”, “cart”, “inline”, “full screen” or “illustration”."
        )
    }
}
