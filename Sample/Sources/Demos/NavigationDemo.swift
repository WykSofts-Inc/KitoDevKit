//
//  NavigationDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoNavigation

struct NavigationDemo: View {
    var body: some View {
        List {
            NavigationLink("Tab bar + side menu") { TabAndMenuDemo() }
            NavigationLink("Typed push/pop router") { RouterDemo() }
            NavigationLink("Side menu — trailing edge") { TrailingMenuDemo() }
        }
        .navigationTitle("Navigation")
    }
}

// MARK: - Tab bar + side menu (the original demo)

/// The side menu + its hamburger trigger are attached ONCE here, wrapping
/// the whole `KitoTabContainerView` from outside — not inside each tab's
/// own `NavigationStack`. Attaching per-tab was a real bug: it left the
/// menu covering only one tab's content slot (tab bar visible/undimmed
/// alongside it) and put three competing "Menu" toolbar buttons in the
/// tree simultaneously (each tab's NavigationStack is kept mounted for
/// state preservation, so all three toolbars existed at once — the
/// duplicate hamburger icons). Wrapping from outside fixes both: one
/// toolbar, one menu, covering everything including the tab bar.
private struct TabAndMenuDemo: View {
    @State private var tabs = KitoTabBarViewModel(
        items: [
            KitoTabItem(id: "home", title: "Home", systemImage: "house", selectedSystemImage: "house.fill"),
            KitoTabItem(id: "cart", title: "Cart", systemImage: "cart", badgeCount: 2),
            KitoTabItem(id: "profile", title: "Profile", systemImage: "person"),
        ],
        onReselect: { id in print("Reselected \(id) — a real app would scroll-to-top or pop its stack here") }
    )
    @State private var menu = KitoSideMenuViewModel()

    var body: some View {
        // No outer NavigationStack here on purpose — .toolbar/.navigationTitle
        // need one, but an outer one would nest awkwardly with each tab's own
        // NavigationStack. A plain manually-laid-out header plays the same role.
        VStack(spacing: 0) {
            header
            Divider()
            KitoTabContainerView(viewModel: tabs) { tabID in
                tabContent(for: tabID)
            }
        }
        .kitoSideMenu(viewModel: menu) {
            VStack(alignment: .leading, spacing: 4) {
                KitoSideMenuRow(systemImage: "house", title: "Home", isSelected: true) { menu.close() }
                KitoSideMenuRow(systemImage: "gearshape", title: "Settings") { menu.close() }
                KitoSideMenuRow(systemImage: "bell", title: "Notifications", badgeCount: 3) { menu.close() }
            }
            .padding(.top, 60)
            .padding(.horizontal, 8)
        }
        .navigationBarBackButtonHidden(false)
    }

    private var header: some View {
        HStack {
            Button("Menu", systemImage: "line.3.horizontal") { menu.toggle() }
            Spacer()
            Text("Tap a tab twice — see console").font(.headline)
            Spacer()
            Color.clear.frame(width: 24) // balances the leading button so the title stays centered
        }
        .padding()
    }

    @ViewBuilder
    private func tabContent(for id: String) -> some View {
        NavigationStack {
            List {
                Text("Tab: \(id)").font(.headline)
                Text("Swipe from the left edge, or tap the hamburger icon in the header above, to open the side menu — it now covers the whole screen, tab bar included. Switch tabs at the bottom — each keeps its own content alive.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle(id.capitalized)
        }
    }
}

// MARK: - Typed router

private enum DetailRoute: KitoRoute {
    case detail(depth: Int)
}

private struct RouterDemo: View {
    @State private var router = KitoRouter<DetailRoute>()

    var body: some View {
        KitoRouterView(router: router, root: { rootScreen }) { route in
            switch route {
            case .detail(let depth): detailScreen(depth: depth)
            }
        }
        .navigationTitle("Typed router")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var rootScreen: some View {
        VStack(spacing: 16) {
            Text("Root screen").font(.headline)
            Button("Push a detail screen") { router.push(.detail(depth: 1)) }
        }
        .padding()
    }

    private func detailScreen(depth: Int) -> some View {
        VStack(spacing: 16) {
            Text("Detail depth \(depth)").font(.headline)
            Button("Push another") { router.push(.detail(depth: depth + 1)) }
            Button("Pop one") { router.pop() }
            Button("Pop to root") { router.popToRoot() }
        }
        .padding()
    }
}

// MARK: - Trailing-edge side menu (RTL-correct via .trailing, not a hack)

private struct TrailingMenuDemo: View {
    @State private var menu = KitoSideMenuViewModel(edge: .trailing)

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("This menu opens from the trailing edge instead of leading.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                Button("Open menu") { menu.open() }
            }
        }
        .kitoSideMenu(viewModel: menu, menuWidth: 260) {
            VStack(alignment: .leading, spacing: 4) {
                KitoSideMenuRow(systemImage: "star", title: "Favorites") { menu.close() }
                KitoSideMenuRow(systemImage: "clock", title: "Recent") { menu.close() }
            }
            .padding(.top, 60)
            .padding(.horizontal, 8)
        }
        .navigationTitle("Trailing edge")
        .navigationBarTitleDisplayMode(.inline)
    }
}
