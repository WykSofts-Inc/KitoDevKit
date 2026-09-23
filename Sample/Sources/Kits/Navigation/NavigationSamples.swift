//
//  NavigationSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoNavigation

// MARK: - Shared pieces

private let appTabs: [KitoTabItem] = [
    KitoTabItem(id: "home", title: "Home", systemImage: "house", selectedSystemImage: "house.fill"),
    KitoTabItem(id: "explore", title: "Explore", systemImage: "safari", selectedSystemImage: "safari.fill"),
    KitoTabItem(id: "orders", title: "Orders", systemImage: "bag", selectedSystemImage: "bag.fill", badgeCount: 2),
    KitoTabItem(id: "inbox", title: "Inbox", systemImage: "bell", selectedSystemImage: "bell.fill", badgeCount: 5),
    KitoTabItem(id: "profile", title: "Profile", systemImage: "person", selectedSystemImage: "person.fill"),
]

private let fourTabs: [KitoTabItem] = [appTabs[0], appTabs[1], appTabs[3], appTabs[4]]

private let drawerDark = Color(red: 0.07, green: 0.07, blue: 0.09)

/// The app behind a menu or a tab bar: a header, a hero card and rows.
private struct MockFeed: View {
    let title: String
    var tint: Color = .indigo
    var onMenu: (() -> Void)?
    var menuOnTrailing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    if !menuOnTrailing { menuButton }
                    Spacer()
                    if menuOnTrailing { menuButton } else { KitoAvatar(initials: "WN", size: 38) }
                }
                .frame(height: 44)
                Text(title).font(.largeTitle.bold())
                RoundedRectangle(cornerRadius: 24, style: .continuous).fill(tint.gradient).frame(height: 170)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekend picks").font(.title3.bold())
                            Text("12 new places near you").font(.subheadline).opacity(0.85)
                        }
                        .foregroundStyle(.white).padding(18)
                    }
                ForEach(0..<7, id: \.self) { index in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous).fill(tint.opacity(0.15 + Double(index % 3) * 0.12)).frame(width: 56, height: 56)
                        VStack(alignment: .leading, spacing: 7) {
                            Capsule().fill(Color.primary.opacity(0.18)).frame(width: 160, height: 10)
                            Capsule().fill(Color.primary.opacity(0.09)).frame(width: 100, height: 8)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 44)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private var menuButton: some View {
        if let onMenu {
            Button(action: onMenu) {
                Image(systemName: menuOnTrailing ? "line.3.horizontal.decrease" : "line.3.horizontal").font(.title3.weight(.semibold))
                    .frame(width: 44, height: 44).background(Circle().fill(Color.primary.opacity(0.07)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(menuOnTrailing ? "Filters" : "Menu")
        }
    }
}

/// A screen with a side menu that opens a moment after it appears, so the sample shows itself.
private struct MenuHost<Menu: View>: View {
    var style: KitoSideMenuStyle = .push
    var background: KitoSideMenuBackground = .material
    var width: CGFloat = 300
    var edge: KitoSideMenuEdge = .leading
    var tint: Color = .indigo
    @ViewBuilder let menu: (KitoSideMenuViewModel) -> Menu
    @State private var model = KitoSideMenuViewModel()

    var body: some View {
        GeometryReader { proxy in
            MockFeed(title: edge == .leading ? "Home" : "Stays", tint: tint, onMenu: { model.toggle() }, menuOnTrailing: edge == .trailing)
                // Narrower in the gallery's frame than full screen, so the screen behind still shows.
                .kitoSideMenu(viewModel: model, menuWidth: min(width, proxy.size.width * 0.8), style: style, background: background) { menu(model) }
        }
        .task {
            model.edge = edge
            try? await Task.sleep(nanoseconds: 600_000_000)
            model.open()
        }
    }
}

private struct DrawerRow: Identifiable {
    let title: String
    let icon: String
    var badge: String?
    var id: String { title }
}

// MARK: - Drawer designs

/// Avatar, name and email, rows with badges, and a Sign out capsule.
private struct ProfileDrawer: View {
    let model: KitoSideMenuViewModel
    var tint: Color = .indigo
    @State private var selected = "Home"

    private let rows = [
        DrawerRow(title: "Home", icon: "house.fill"), DrawerRow(title: "My wallet", icon: "wallet.pass.fill", badge: "$10"),
        DrawerRow(title: "Orders", icon: "bag.fill"), DrawerRow(title: "Notifications", icon: "bell.fill", badge: "3"),
        DrawerRow(title: "Invite friends", icon: "gift.fill", badge: "New"), DrawerRow(title: "Settings", icon: "gearshape.fill"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            KitoDrawerHeader(name: "Wycliff N", detail: "wycliff@example.com", avatar: KitoAvatar(initials: "WN", size: 60, showsRing: true))
            VStack(spacing: 4) {
                ForEach(rows) { row in
                    KitoDrawerItem(row.title, systemImage: row.icon, badge: row.badge, isSelected: selected == row.title, tint: tint) {
                        selected = row.title
                    }
                }
            }
            Spacer(minLength: 0)
            KitoDrawerFooterButton("Sign out") { model.close() }
        }
        .padding(.horizontal, 18)
        .padding(.top, 44)
        .padding(.bottom, 24)
    }
}

/// A title bar, a verify-email callout, a tile grid and grouped sections.
private struct MainMenuDrawer: View {
    let model: KitoSideMenuViewModel
    @State private var showsCallout = true
    @State private var sent = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Text("Main Menu").font(.title2.bold())
                    Spacer()
                    Button { model.close() } label: {
                        Image(systemName: "xmark").font(.subheadline.weight(.bold)).frame(width: 36, height: 36).background(Circle().fill(Color.primary.opacity(0.08)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close menu")
                }
                if showsCallout {
                    KitoDrawerCallout(systemImage: sent ? "checkmark" : "envelope.badge.fill", title: sent ? "Check your inbox" : "Verify your email",
                                      message: sent ? "We sent a link to wycliff@example.com." : "Confirm it to keep your account secure.",
                                      actionTitle: sent ? nil : "Send link", tint: sent ? .green : .orange,
                                      action: { withAnimation(.snappy) { sent = true } },
                                      onDismiss: { withAnimation(.snappy) { showsCallout = false } })
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                KitoDrawerTileGrid {
                    KitoDrawerTile("Orders", systemImage: "shippingbox.fill", detail: "2 on the way", tint: .blue) {}
                    KitoDrawerTile("Wallet", systemImage: "creditcard.fill", detail: "$248.50", tint: .green) {}
                    KitoDrawerTile("Rewards", systemImage: "star.fill", detail: "1,240 pts", tint: .orange) {}
                    KitoDrawerTile("Addresses", systemImage: "mappin.and.ellipse", detail: "3 saved", tint: .pink) {}
                }
                KitoDrawerSection("Messages") {
                    KitoDrawerItem("Inbox", systemImage: "tray.fill", badge: "4", tint: .indigo) {}
                    KitoDrawerItem("Promotions", systemImage: "megaphone.fill", badge: "New", tint: .indigo) {}
                    KitoDrawerItem("Support chat", systemImage: "bubble.left.and.bubble.right.fill", tint: .indigo) {}
                }
                KitoDrawerSection("Account & Security") {
                    KitoDrawerItem("Profile", systemImage: "person.fill", showsChevron: true) {}
                    KitoDrawerItem("Password", systemImage: "key.fill", showsChevron: true) {}
                    KitoDrawerItem("Privacy", systemImage: "hand.raised.fill", showsChevron: true) {}
                    KitoDrawerItem("Devices", systemImage: "iphone", badge: "2", showsChevron: true) {}
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 50)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
    }
}

/// Workspaces in a rail, channels beside them.
private struct WorkspaceDrawer: View {
    let model: KitoSideMenuViewModel
    @State private var workspace = "studio"
    @State private var channel = "general"

    private let workspaces = [
        KitoTabItem(id: "studio", title: "Studio", systemImage: "paintpalette", selectedSystemImage: "paintpalette.fill", badgeCount: 3),
        KitoTabItem(id: "shop", title: "Shop", systemImage: "bag", selectedSystemImage: "bag.fill"),
        KitoTabItem(id: "club", title: "Running club", systemImage: "figure.run"),
        KitoTabItem(id: "family", title: "Family", systemImage: "house", selectedSystemImage: "house.fill", badgeCount: 1),
    ]

    var body: some View {
        HStack(spacing: 0) {
            KitoSideRail(items: workspaces, selection: $workspace, tint: .purple) {
                KitoAvatar(initials: "WN", size: 40)
            } footer: {
                Image(systemName: "plus").font(.headline).frame(width: 50, height: 50)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [4])))
                    .accessibilityLabel("Add workspace")
            }
            .padding(.top, 30)
            .background(Color.primary.opacity(0.05))

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workspaces.first { $0.id == workspace }?.title ?? "").font(.title3.bold()).contentTransition(.opacity)
                        Text("14 members · 3 online").font(.caption).foregroundStyle(.secondary)
                    }
                    KitoDrawerSection("Channels") {
                        ForEach(["general", "design", "launch", "random"], id: \.self) { name in
                            KitoDrawerItem(name, systemImage: "number", badge: name == "launch" ? "8" : nil, isSelected: channel == name, tint: .purple) { channel = name }
                        }
                    }
                    KitoDrawerSection("Direct messages") {
                        KitoDrawerItem("Achieng", systemImage: "person.crop.circle.fill", badge: "2", tint: .purple) {}
                        KitoDrawerItem("Brian", systemImage: "person.crop.circle.fill", tint: .purple) {}
                        KitoDrawerItem("Zawadi", systemImage: "person.crop.circle.fill", tint: .purple) {}
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 44)
            }
            .scrollIndicators(.hidden)
        }
        .animation(.snappy, value: workspace)
    }
}

/// A gradient drawer with now playing and playlists.
private struct MusicDrawer: View {
    let model: KitoSideMenuViewModel
    @State private var selected = "Listen now"
    @State private var isPlaying = true

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52).overlay(Image(systemName: "music.note").foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nairobi Nights").font(.subheadline.bold())
                    Text("Sauti Sol").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button { isPlaying.toggle() } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill").font(.headline).frame(width: 38, height: 38).background(Circle().fill(.white.opacity(0.18)))
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPlaying ? "Pause" : "Play")
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white.opacity(0.1)))

            VStack(spacing: 4) {
                ForEach([DrawerRow(title: "Listen now", icon: "play.circle.fill"), DrawerRow(title: "Browse", icon: "square.grid.2x2.fill"),
                         DrawerRow(title: "Radio", icon: "dot.radiowaves.left.and.right"), DrawerRow(title: "Library", icon: "music.note.list", badge: "12")]) { row in
                    KitoDrawerItem(row.title, systemImage: row.icon, badge: row.badge, isSelected: selected == row.title, tint: .pink) { selected = row.title }
                }
            }
            KitoDrawerSection("Playlists") {
                ForEach(Array(["Morning run", "Focus", "Afrobeats", "Road trip"].enumerated()), id: \.offset) { index, name in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(LinearGradient(colors: [[Color.teal, .blue], [.purple, .indigo], [.orange, .red], [.green, .teal]][index], startPoint: .top, endPoint: .bottom))
                            .frame(width: 36, height: 36)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(name).font(.subheadline.weight(.semibold))
                            Text("\(18 + index * 7) songs").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 6)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 44)
        .environment(\.colorScheme, .dark)
    }
}

/// A balance card, quick actions and account rows.
private struct BankingDrawer: View {
    let model: KitoSideMenuViewModel
    @State private var hidden = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Total balance").font(.caption.weight(.semibold)).opacity(0.8)
                    Spacer()
                    Button { withAnimation(.snappy) { hidden.toggle() } } label: { Image(systemName: hidden ? "eye.slash.fill" : "eye.fill") }
                        .buttonStyle(.plain).accessibilityLabel(hidden ? "Show balance" : "Hide balance")
                }
                Text(hidden ? "KES ••••••" : "KES 248,500").font(.title.bold().monospacedDigit()).contentTransition(.numericText())
                Text("+ KES 12,400 this month").font(.caption.weight(.semibold)).opacity(0.85)
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(LinearGradient(colors: [Color(red: 0.1, green: 0.5, blue: 0.45), Color(red: 0.05, green: 0.25, blue: 0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)))

            HStack {
                ForEach([("Send", "arrow.up.right"), ("Request", "arrow.down.left"), ("Top up", "plus"), ("Cards", "creditcard")], id: \.0) { title, icon in
                    VStack(spacing: 6) {
                        Image(systemName: icon).font(.headline).frame(width: 48, height: 48).background(Circle().fill(Color.primary.opacity(0.07)))
                        Text(title).font(.caption2.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            KitoDrawerSection("Accounts") {
                KitoDrawerItem("Everyday", systemImage: "banknote.fill", badge: "Main", tint: .teal, showsChevron: true) {}
                KitoDrawerItem("Savings", systemImage: "building.columns.fill", badge: "4.5%", tint: .teal, showsChevron: true) {}
                KitoDrawerItem("Statements", systemImage: "doc.text.fill", tint: .teal, showsChevron: true) {}
            }
            Spacer(minLength: 0)
            KitoDrawerFooterButton("Lock app", systemImage: "lock.fill") { model.close() }
        }
        .padding(.horizontal, 16)
        .padding(.top, 44)
        .padding(.bottom, 28)
    }
}

/// Filters in a floating drawer from the trailing edge.
private struct FiltersDrawer: View {
    let model: KitoSideMenuViewModel
    @State private var kind = "Apartments"
    @State private var price = 2
    @State private var wifi = true
    @State private var pool = false
    @State private var pets = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Filters").font(.title2.bold())
                Spacer()
                Button("Reset") { withAnimation { kind = "Apartments"; price = 2; wifi = true; pool = false; pets = true } }.font(.subheadline.weight(.semibold))
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Type").font(.subheadline.weight(.semibold))
                KitoTopTabs(["Apartments", "Villas", "Cabins", "Hotels"], selection: $kind, style: .chips, tint: .teal).padding(.horizontal, -16)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Price").font(.subheadline.weight(.semibold))
                HStack(spacing: 8) {
                    ForEach(1...4, id: \.self) { level in
                        Button { withAnimation(.snappy) { price = level } } label: {
                            Text(String(repeating: "$", count: level)).font(.subheadline.weight(.bold)).frame(maxWidth: .infinity).frame(height: 40)
                                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(level <= price ? Color.teal : Color.primary.opacity(0.06)))
                                .foregroundStyle(level <= price ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            VStack(spacing: 0) {
                KitoDrawerToggle("Wi-Fi", systemImage: "wifi", isOn: $wifi, tint: .teal)
                KitoDrawerToggle("Pool", systemImage: "figure.pool.swim", isOn: $pool, tint: .teal)
                KitoDrawerToggle("Pets allowed", systemImage: "pawprint.fill", isOn: $pets, tint: .teal)
            }
            .padding(.horizontal, -14)
            Spacer(minLength: 0)
            Button { model.close() } label: {
                Text("Show 128 stays").font(.headline).frame(maxWidth: .infinity).frame(height: 52).background(Capsule().fill(Color.teal)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }
}

/// Toggles that change the screen behind, including dark mode.
private struct SettingsDrawerSample: View {
    @State private var dark = true
    @State private var notifications = true
    @State private var faceID = false

    var body: some View {
        MenuHost(style: .overlay, background: .color(Color(.systemBackground)), tint: .blue) { model in
            VStack(alignment: .leading, spacing: 22) {
                KitoDrawerHeader(name: "Wycliff N", detail: "Pro plan · renews 12 Oct", avatar: KitoAvatar(initials: "WN", colors: [.blue, .cyan], size: 48), layout: .inline)
                KitoDrawerSection("Preferences") {
                    KitoDrawerToggle("Dark mode", systemImage: "moon.fill", isOn: $dark.animation(.easeInOut), tint: .blue)
                    KitoDrawerToggle("Notifications", systemImage: "bell.badge.fill", isOn: $notifications, tint: .blue)
                    KitoDrawerToggle("Face ID", systemImage: "faceid", isOn: $faceID, tint: .blue)
                }
                KitoDrawerSection("General") {
                    KitoDrawerItem("Language", systemImage: "globe", badge: "English", tint: .blue, showsChevron: true) {}
                    KitoDrawerItem("Currency", systemImage: "dollarsign.circle.fill", badge: "KES", tint: .blue, showsChevron: true) {}
                }
                Spacer(minLength: 0)
                KitoDrawerFooterButton("Delete account", systemImage: "trash", role: .destructive) { model.close() }
            }
            .padding(.horizontal, 16).padding(.top, 44).padding(.bottom, 28)
        }
        .environment(\.colorScheme, dark ? .dark : .light)
    }
}

/// A plain drawer used to compare transitions.
private struct SimpleDrawer: View {
    let model: KitoSideMenuViewModel
    var onDark = false
    var tint: Color = .indigo
    @State private var selected = "Home"

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            KitoDrawerHeader(name: "Wycliff N", detail: "Nairobi, Kenya", avatar: KitoAvatar(initials: "WN", colors: onDark ? [.white.opacity(0.35), .white.opacity(0.15)] : [.orange, .pink], size: 52, showsRing: !onDark), layout: .inline)
            VStack(spacing: 4) {
                ForEach([DrawerRow(title: "Home", icon: "house.fill"), DrawerRow(title: "Trips", icon: "airplane", badge: "2"),
                         DrawerRow(title: "Saved", icon: "bookmark.fill"), DrawerRow(title: "Messages", icon: "bubble.left.fill", badge: "5"),
                         DrawerRow(title: "Settings", icon: "gearshape.fill")]) { row in
                    KitoDrawerItem(row.title, systemImage: row.icon, badge: row.badge, isSelected: selected == row.title, tint: onDark ? .white.opacity(0.2) : tint, badgeTint: onDark ? .white : nil) { selected = row.title }
                }
            }
            Spacer(minLength: 0)
            KitoDrawerFooterButton("Sign out") { model.close() }
        }
        .padding(.horizontal, 18)
        .padding(.top, 60)
        .padding(.bottom, 30)
        .environment(\.colorScheme, onDark ? .dark : .light)
    }
}

// MARK: - Tab bars

private struct TabHost: View {
    let style: KitoTabBarStyle
    var tint: Color?
    var hasCenter = false
    @State private var model: KitoTabBarViewModel
    @State private var created = 0

    init(style: KitoTabBarStyle, tint: Color? = nil, items: [KitoTabItem] = appTabs, hasCenter: Bool = false) {
        self.style = style
        self.tint = tint
        self.hasCenter = hasCenter
        _model = State(initialValue: KitoTabBarViewModel(items: items))
    }

    var body: some View {
        KitoTabContainerView(viewModel: model, style: style, tint: tint,
                             centerAction: hasCenter ? KitoTabCenterAction(systemImage: "plus", accessibilityLabel: "New post") { created += 1 } : nil) { id in
            MockFeed(title: model.items.first { $0.id == id }?.title ?? id, tint: tint ?? .indigo)
        }
        .overlay(alignment: .top) {
            if created > 0 {
                Label("Created post \(created)", systemImage: "checkmark.circle.fill").font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16).padding(.vertical, 10).background(Capsule().fill(.regularMaterial))
                    .padding(.top, 12).transition(.move(edge: .top).combined(with: .opacity)).id(created)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: created)
    }
}

/// Each tab has its own colour; the pill takes it on.
private struct ColourfulTabs: View {
    @State private var model = KitoTabBarViewModel(items: fourTabs)
    private let colours: [String: Color] = ["home": .indigo, "explore": .orange, "inbox": .pink, "profile": .teal]

    var body: some View {
        let tint = colours[model.selectedID] ?? .indigo
        KitoTabContainerView(viewModel: model, style: .pill, tint: tint) { id in
            MockFeed(title: model.items.first { $0.id == id }?.title ?? id, tint: colours[id] ?? .indigo)
        }
        .animation(.easeInOut(duration: 0.3), value: model.selectedID)
    }
}

// MARK: - Top tabs

private struct TopTabsSample: View {
    let style: KitoTopTabsStyle
    var tint: Color = .indigo
    @State private var selection = "For you"
    private let titles = ["For you", "Following", "Nairobi", "Food", "Music", "Sport", "Tech", "Travel"]

    var body: some View {
        VStack(spacing: 16) {
            KitoTopTabs(titles, selection: $selection, style: style, tint: tint)
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(tint.opacity(0.12)).frame(height: 160)
                .overlay(Text(selection).font(.title2.bold()).foregroundStyle(tint).contentTransition(.opacity).id(selection).transition(.push(from: .trailing)))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 16)
                .animation(.snappy, value: selection)
        }
        .padding(.horizontal, -24)
    }
}

/// Tab bar, side menu and top tabs working together.
private struct AppShell: View {
    @State private var tabs = KitoTabBarViewModel(items: appTabs)
    @State private var menu = KitoSideMenuViewModel()
    @State private var feed = "For you"

    var body: some View {
        KitoTabContainerView(viewModel: tabs, style: .glass, tint: .indigo) { id in
            if id == "home" {
                VStack(spacing: 0) {
                    HStack {
                        Button { menu.toggle() } label: {
                            Image(systemName: "line.3.horizontal").font(.title3.weight(.semibold)).frame(width: 44, height: 44).background(Circle().fill(Color.primary.opacity(0.07)))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Menu")
                        Spacer()
                        Text("Kito").font(.headline)
                        Spacer()
                        KitoAvatar(initials: "WN", size: 38)
                    }
                    .padding(.horizontal, 20).padding(.top, 44).padding(.bottom, 6)
                    KitoTopTabs(["For you", "Following", "Nearby", "Deals", "New"], selection: $feed, tint: .indigo)
                    MockFeed(title: feed, tint: .indigo)
                }
                .background(Color(.systemBackground))
            } else {
                MockFeed(title: tabs.items.first { $0.id == id }?.title ?? id, tint: .indigo)
            }
        }
        .kitoSideMenu(viewModel: menu, style: .scale, background: .gradient([Color(red: 0.2, green: 0.18, blue: 0.5), Color(red: 0.08, green: 0.06, blue: 0.2)])) {
            SimpleDrawer(model: menu, onDark: true)
        }
    }
}

// MARK: - Catalogue

private let menuCode = """
@State private var menu = KitoSideMenuViewModel()

HomeScreen(onMenu: { menu.toggle() })
    .kitoSideMenu(viewModel: menu, style: .push) {
        VStack(alignment: .leading, spacing: 26) {
            KitoDrawerHeader(name: "Wycliff N", detail: "wycliff@example.com",
                             avatar: KitoAvatar(initials: "WN", size: 64, showsRing: true))
            KitoDrawerItem("Home", systemImage: "house.fill", isSelected: true) { }
            KitoDrawerItem("My wallet", systemImage: "wallet.pass.fill", badge: "$10") { }
            KitoDrawerItem("Notifications", systemImage: "bell.fill", badge: "3") { }
            Spacer()
            KitoDrawerFooterButton("Sign out") { signOut() }
        }
    }
"""

private func tabCode(_ style: String, extra: String = "") -> String {
    """
    @State private var tabs = KitoTabBarViewModel(items: [
        KitoTabItem(id: "home", title: "Home", systemImage: "house", selectedSystemImage: "house.fill"),
        KitoTabItem(id: "orders", title: "Orders", systemImage: "bag", badgeCount: 2),
        …
    ])

    KitoTabContainerView(viewModel: tabs, style: .\(style)\(extra)) { id in
        screen(for: id)
    }
    """
}

private func transition(_ title: String, _ subtitle: String, style: KitoSideMenuStyle, background: KitoSideMenuBackground, backgroundCode: String, onDark: Bool) -> KitSample {
    KitSample(title, subtitle, code: """
    screen.kitoSideMenu(viewModel: menu, style: .\(style.rawValue), background: \(backgroundCode)) {
        DrawerContent()
    }
    """) {
        ModalStage { MenuHost(style: style, background: background) { SimpleDrawer(model: $0, onDark: onDark) } }
    }
}

enum NavigationSamples {
    static let drawers = KitSection("Drawer designs", symbol: "sidebar.left", [
        KitSample("Profile drawer, dark", "Avatar with a ring, name and email, badges like $10, and Sign out.", code: menuCode) {
            ModalStage { MenuHost(background: .color(drawerDark), tint: .indigo) { ProfileDrawer(model: $0).environment(\.colorScheme, .dark) } }
        },
        KitSample("Profile drawer, light", "The same drawer on white.", code: menuCode.replacingOccurrences(of: "style: .push", with: "style: .overlay, background: .color(.white)")) {
            ModalStage { MenuHost(style: .overlay, background: .color(.white), tint: .black) { ProfileDrawer(model: $0, tint: .black).environment(\.colorScheme, .light) } }
        },
        KitSample("Main menu", "Verify-email callout, a 2×2 grid of tiles, Messages and Account & Security.", code: """
        KitoDrawerCallout(systemImage: "envelope.badge.fill", title: "Verify your email",
                          message: "Confirm your address to keep your account secure.",
                          actionTitle: "Send link", tint: .orange, action: sendLink, onDismiss: hide)
        KitoDrawerTileGrid {
            KitoDrawerTile("Orders", systemImage: "shippingbox.fill", detail: "2 on the way", tint: .blue) { }
            KitoDrawerTile("Wallet", systemImage: "creditcard.fill", detail: "$248.50", tint: .green) { }
        }
        KitoDrawerSection("Messages") {
            KitoDrawerItem("Inbox", systemImage: "tray.fill", badge: "4") { }
        }
        KitoDrawerSection("Account & Security") {
            KitoDrawerItem("Password", systemImage: "key.fill", showsChevron: true) { }
        }
        """) {
            ModalStage { MenuHost(style: .overlay, background: .color(Color(.systemBackground)), width: 320) { MainMenuDrawer(model: $0) } }
        },
        KitSample("Workspaces", "A rail of workspaces beside channels and messages.", code: """
        HStack(spacing: 0) {
            KitoSideRail(items: workspaces, selection: $workspace, tint: .purple) {
                KitoAvatar(initials: "WN", size: 40)
            } footer: {
                AddWorkspaceButton()
            }
            ChannelList()
        }
        """) {
            ModalStage { MenuHost(style: .push, background: .color(Color(.secondarySystemBackground)), width: 320, tint: .purple) { WorkspaceDrawer(model: $0) } }
        },
        KitSample("Music", "Gradient drawer, now playing and playlists.", code: """
        .kitoSideMenu(viewModel: menu, style: .scale, background: .gradient([.purple, .indigo])) {
            MusicDrawer()
        }
        """) {
            ModalStage { MenuHost(style: .scale, background: .gradient([Color(red: 0.45, green: 0.1, blue: 0.45), Color(red: 0.12, green: 0.08, blue: 0.3)]), tint: .pink) { MusicDrawer(model: $0) } }
        },
        KitSample("Banking", "A balance card you can hide, quick actions and accounts.", code: """
        .kitoSideMenu(viewModel: menu, style: .reveal, background: .color(Color(.systemBackground))) {
            BankingDrawer()
        }
        """) {
            ModalStage { MenuHost(style: .reveal, background: .color(Color(.secondarySystemBackground)), width: 310, tint: .teal) { BankingDrawer(model: $0) } }
        },
        KitSample("Filters from the right", "A floating drawer from the trailing edge with chips, price and toggles.", code: """
        @State private var menu = KitoSideMenuViewModel(edge: .trailing)

        screen.kitoSideMenu(viewModel: menu, menuWidth: 320, style: .floating) {
            FiltersDrawer()
        }
        """) {
            ModalStage { MenuHost(style: .floating, background: .color(Color(.systemBackground)), width: 320, edge: .trailing, tint: .teal) { FiltersDrawer(model: $0) } }
        },
        KitSample("Settings", "Toggles, including a dark mode that flips the screen behind.", code: """
        KitoDrawerToggle("Dark mode", systemImage: "moon.fill", isOn: $dark)
        KitoDrawerItem("Language", systemImage: "globe", badge: "English", showsChevron: true) { }
        KitoDrawerFooterButton("Delete account", systemImage: "trash", role: .destructive) { }
        """) { ModalStage { SettingsDrawerSample() } },
        KitSample("Icon rail", "A slim rail of icons with a sliding highlight.", code: """
        screen.kitoSideMenu(viewModel: menu, menuWidth: 84, style: .push) {
            KitoSideRail(items: items, selection: $selection) {
                KitoAvatar(initials: "WN", size: 40)
            } footer: {
                Image(systemName: "gearshape")
            }
        }
        """) {
            ModalStage { MenuHost(style: .push, background: .color(Color(.secondarySystemBackground)), width: 84) { _ in RailDrawer() } }
        },
    ])

    static let transitions = KitSection("Transitions", symbol: "rectangle.lefthalf.inset.filled.arrow.left", [
        transition("Push", "The drawer pushes the screen aside.", style: .push, background: .material, backgroundCode: ".material", onDark: false),
        transition("Overlay", "Slides over a dimmed screen.", style: .overlay, background: .color(Color(.systemBackground)), backgroundCode: ".color(Color(.systemBackground))", onDark: false),
        transition("Reveal", "The screen slides away to show the drawer underneath.", style: .reveal, background: .color(Color(red: 0.1, green: 0.1, blue: 0.18)), backgroundCode: ".color(.midnight)", onDark: true),
        transition("Scale", "The screen shrinks into a rounded card.", style: .scale, background: .gradient([.indigo, .purple]), backgroundCode: ".gradient([.indigo, .purple])", onDark: true),
        transition("3D", "The screen swings away in perspective.", style: .rotate3D, background: .gradient([.teal, .blue]), backgroundCode: ".gradient([.teal, .blue])", onDark: true),
        transition("Floating card", "An inset, rounded drawer over a softened screen.", style: .floating, background: .color(Color(.systemBackground)), backgroundCode: ".color(Color(.systemBackground))", onDark: false),
    ])

    static let tabBars = KitSection("Tab bars", symbol: "dock.rectangle", [
        KitSample("Classic", "Edge to edge, a soft capsule behind the icon.", code: tabCode("classic")) { ModalStage { TabHost(style: .classic) } },
        KitSample("Floating", "A capsule above the content with a dot.", code: tabCode("floating", extra: ", tint: .indigo")) { ModalStage { TabHost(style: .floating, tint: .indigo) } },
        KitSample("Expanding pill", "The selected tab grows into a pill with its title.", code: tabCode("pill", extra: ", tint: .black")) { ModalStage { TabHost(style: .pill, tint: .black) } },
        KitSample("Colour per tab", "The pill takes on each tab's colour.", code: """
        KitoTabContainerView(viewModel: tabs, style: .pill, tint: colours[tabs.selectedID]) { id in
            screen(for: id)
        }
        """) { ModalStage { ColourfulTabs() } },
        KitSample("Underline", "A line glides along the top edge.", code: tabCode("underline", extra: ", tint: .orange")) { ModalStage { TabHost(style: .underline, tint: .orange) } },
        KitSample("Curved bubble", "The icon rises into a circle sitting in a curved dip.", code: tabCode("bubble", extra: ", tint: .pink")) { ModalStage { TabHost(style: .bubble, tint: .pink, items: fourTabs) } },
        KitSample("Glass", "Frosted glass floating over the content.", code: tabCode("glass", extra: ", tint: .blue")) { ModalStage { TabHost(style: .glass, tint: .blue) } },
        KitSample("Segmented", "A tile slides behind the icon and title.", code: tabCode("segmented", extra: ", tint: .teal")) { ModalStage { TabHost(style: .segmented, tint: .teal, items: fourTabs) } },
        KitSample("Minimal", "Icons only; the dot stretches and the icon bounces.", code: tabCode("minimal", extra: ", tint: .purple")) { ModalStage { TabHost(style: .minimal, tint: .purple) } },
        KitSample("Centre action", "A raised create button in a notch.", code: tabCode("notched", extra: """
        , tint: .indigo,
                             centerAction: KitoTabCenterAction(systemImage: "plus") { compose() }
        """)) { ModalStage { TabHost(style: .notched, tint: .indigo, items: fourTabs, hasCenter: true) } },
    ])

    static let topTabs = KitSection("Top tabs", symbol: "rectangle.topthird.inset.filled", [
        KitSample("Underline", "Scrollable tabs with a sliding line.", code: "KitoTopTabs(titles, selection: $feed, style: .underline)") { TopTabsSample(style: .underline) },
        KitSample("Pill", "A capsule slides behind the selected tab.", code: "KitoTopTabs(titles, selection: $feed, style: .pill, tint: .black)") { TopTabsSample(style: .pill, tint: .primary) },
        KitSample("Chips", "Separate chips; the selected one fills.", code: "KitoTopTabs(titles, selection: $feed, style: .chips, tint: .orange)") { TopTabsSample(style: .chips, tint: .orange) },
    ])

    static let together = KitSection("Put together", symbol: "square.stack.3d.up.fill", [
        KitSample("App shell", "Glass tab bar, top tabs and a scale drawer in one app.", code: """
        KitoTabContainerView(viewModel: tabs, style: .glass) { id in
            VStack {
                TopBar(onMenu: { menu.toggle() })
                KitoTopTabs(feeds, selection: $feed)
                Feed(feed)
            }
        }
        .kitoSideMenu(viewModel: menu, style: .scale, background: .gradient([.indigo, .black])) {
            DrawerContent()
        }
        """) { ModalStage { AppShell() } },
    ])

    static let sections: [KitSection] = [drawers, transitions, tabBars, topTabs, together]
}

private struct RailDrawer: View {
    @State private var selection = "home"

    var body: some View {
        KitoSideRail(items: appTabs, selection: $selection, tint: .indigo) {
            KitoAvatar(initials: "WN", size: 40)
        } footer: {
            Image(systemName: "gearshape").font(.title3).foregroundStyle(.secondary).frame(width: 50, height: 50).accessibilityLabel("Settings")
        }
        .padding(.top, 30)
        .frame(maxHeight: .infinity)
    }
}

struct NavigationGallery: View {
    static var count: Int { KitGallery.count(NavigationSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Side Menus & Tab Bars",
            sections: NavigationSamples.sections,
            footnote: "Requires `import KitoNavigation`. Samples run inside the frame; Open full screen shows them for real.",
            searchHint: "Try “drawer”, “profile”, “scale”, “pill” or “notch”."
        )
    }
}
