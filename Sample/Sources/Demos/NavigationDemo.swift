//
//  NavigationDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoNavigation

struct NavigationDemo: View {
    @State private var tabs = KitoTabBarViewModel(items: [
        KitoTabItem(id: "home", title: "Home", systemImage: "house", selectedSystemImage: "house.fill"),
        KitoTabItem(id: "cart", title: "Cart", systemImage: "cart", badgeCount: 2),
        KitoTabItem(id: "profile", title: "Profile", systemImage: "person"),
    ])
    @State private var menu = KitoSideMenuViewModel()

    var body: some View {
        KitoTabContainerView(viewModel: tabs) { tabID in
            tabContent(for: tabID)
                .kitoSideMenu(viewModel: menu) {
                    VStack(alignment: .leading, spacing: 4) {
                        KitoSideMenuRow(systemImage: "house", title: "Home", isSelected: true) { menu.close() }
                        KitoSideMenuRow(systemImage: "gearshape", title: "Settings") { menu.close() }
                        KitoSideMenuRow(systemImage: "bell", title: "Notifications", badgeCount: 3) { menu.close() }
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 8)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Menu", systemImage: "line.3.horizontal") { menu.toggle() }
                    }
                }
        }
        .navigationTitle("Tab Bar & Side Menu")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func tabContent(for id: String) -> some View {
        NavigationStack {
            List {
                Text("Tab: \(id)").font(.headline)
                Text("Tap the hamburger icon top-left to open the side menu. Switch tabs at the bottom — each keeps its own content alive.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle(id.capitalized)
        }
    }
}
