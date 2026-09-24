//
//  ContentView.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

struct KitoCatalogEntry: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let isNew: Bool
    let destination: AnyView

    init<Content: View>(_ title: String, _ subtitle: String, systemImage: String, isNew: Bool = false, @ViewBuilder destination: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isNew = isNew
        self.destination = AnyView(destination())
    }

    /// A kit added in the latest round, badged "New" on the home screen.
    static func new<Content: View>(_ title: String, _ subtitle: String, systemImage: String, @ViewBuilder destination: () -> Content) -> KitoCatalogEntry {
        KitoCatalogEntry(title, subtitle, systemImage: systemImage, isNew: true, destination: destination)
    }

    /// "24 samples" from "24 samples · sheets, alerts", or nil when the subtitle has no count.
    var countText: String? {
        guard let first = subtitle.components(separatedBy: " · ").first, first.first?.isNumber == true else { return nil }
        return first
    }

    /// What the kit covers, without the count.
    var blurb: String { subtitle.components(separatedBy: " · ").last ?? subtitle }

    static func == (lhs: KitoCatalogEntry, rhs: KitoCatalogEntry) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct KitoCatalogSection: Identifiable {
    let title: String
    let symbol: String
    let tint: Color
    let entries: [KitoCatalogEntry]
    var id: String { title }
}

struct ContentView: View {
    @Environment(\.kitoTheme) private var theme
    @State private var query = ""
    @State private var category: String?
    @State private var surprise: KitoCatalogEntry?
    @State private var featured: String?
    @AppStorage("home.recentKits") private var recentRaw = ""

    static let sections: [KitoCatalogSection] = [
        KitoCatalogSection(title: "Components", symbol: "square.on.square", tint: Color.cyan, entries: [
            KitoCatalogEntry("Buttons", "\(SampleCatalog.all.count) samples · variants, phases, add-to-cart", systemImage: "hand.tap.fill") { ButtonsGallery() },
            KitoCatalogEntry("Fields", "\(FieldSampleCatalog.all.count) samples · text, phone, OTP, currency", systemImage: "character.cursor.ibeam") { FieldsGallery() },
            KitoCatalogEntry.new("Carousels & Stories", "\(CarouselGallery.count) samples · snap, cover flow, swipe deck, stories", systemImage: "rectangle.stack.fill") { CarouselGallery() },
            KitoCatalogEntry.new("Reviews & Ratings", "\(ReviewsGallery.count) samples · stars, histograms, composer, NPS", systemImage: "star.bubble.fill") { ReviewsGallery() },
        ]),
        KitoCatalogSection(title: "Feedback", symbol: "bell.badge.fill", tint: Color.orange, entries: [
            KitoCatalogEntry("Loaders", "\(LoadersDemo.count) samples · spinners, skeletons, overlays, refresh", systemImage: "arrow.triangle.2.circlepath") { LoadersDemo() },
            KitoCatalogEntry("Toasts", "\(ToastsDemo.count) samples · stacks, island, promise, undo", systemImage: "bubble.left.fill") { ToastsDemo() },
            KitoCatalogEntry("Modals", "\(ModalsGallery.count) samples · sheets, alerts, paywall, hero cards", systemImage: "rectangle.portrait.bottomthird.inset.filled") { ModalsGallery() },
            KitoCatalogEntry("Empty States", "\(EmptyStatesDemo.count) samples · animated illustrations, layouts", systemImage: "tray") { EmptyStatesDemo() },
            KitoCatalogEntry("Haptics", "\(HapticsDemo.count) samples · patterns, visualizer, triggers", systemImage: "waveform") { HapticsDemo() },
        ]),
        KitoCatalogSection(title: "Data & Charts", symbol: "chart.bar.xaxis", tint: Color.green, entries: [
            KitoCatalogEntry("Charts", "\(ChartsGallery.count) samples · line, area, sparklines, bar, pie", systemImage: "chart.xyaxis.line") { ChartsGallery() },
            KitoCatalogEntry("3D Charts", "\(Chart3DSampleCatalog.all.count) samples · bars, pies, donuts, live data", systemImage: "cube.fill") { Chart3DGallery() },
            KitoCatalogEntry.new("Calendar", "\(CalendarGallery.count) samples · month, ranges, slots, timeline", systemImage: "calendar") { CalendarGallery() },
            KitoCatalogEntry("Formatting", "\(FormattingDemo.count) samples · money, dates, phones, counting text", systemImage: "textformat.123") { FormattingDemo() },
        ]),
        KitoCatalogSection(title: "Navigation", symbol: "sidebar.left", tint: Color.purple, entries: [
            KitoCatalogEntry.new("Side Menus & Tab Bars", "\(NavigationGallery.count) samples · drawers, transitions, tab bars, top tabs", systemImage: "sidebar.left") { NavigationGallery() },
            KitoCatalogEntry("Onboarding", "\(OnboardingGallery.count) samples · layouts, photos, gradients, transitions", systemImage: "sparkles") { OnboardingGallery() },
        ]),
        KitoCatalogSection(title: "Forms", symbol: "rectangle.and.pencil.and.ellipsis", tint: Color.pink, entries: [
            KitoCatalogEntry("Validation", "\(ValidationGallery.count) samples · rules, passwords, async, forms", systemImage: "checkmark.shield") { ValidationGallery() },
            KitoCatalogEntry.new("Photo Editor", "\(PhotoGallery.count) samples · camera, filters, crop, publish", systemImage: "camera.filters") { PhotoGallery() },
            KitoCatalogEntry.new("Media Player", "\(MediaPlayerGallery.count) samples · video, Reels, music, podcasts", systemImage: "play.rectangle.fill") { MediaPlayerGallery() },
            KitoCatalogEntry("Media Picker", "\(MediaGallery.count) samples · avatars, uploads, grids, sources", systemImage: "photo.on.rectangle.angled") { MediaGallery() },
        ]),
        KitoCatalogSection(title: "Communication", symbol: "bubble.left.and.bubble.right.fill", tint: Color.blue, entries: [
            KitoCatalogEntry.new("Chat", "\(ChatGallery.count) samples · bubbles, voice notes, reactions, inbox", systemImage: "bubble.left.and.bubble.right.fill") { ChatGallery() },
            KitoCatalogEntry.new("Notifications", "\(NotificationsGallery.count) samples · inbox, banners, actions, quiet hours", systemImage: "bell.badge.fill") { NotificationsGallery() },
        ]),
        KitoCatalogSection(title: "Account", symbol: "person.crop.circle.badge.checkmark", tint: Color.indigo, entries: [
            KitoCatalogEntry.new("Auth", "\(AuthGallery.count) samples · Apple, passkeys, codes, app lock", systemImage: "person.badge.key.fill") { AuthGallery() },
        ]),
        KitoCatalogSection(title: "Location", symbol: "map.fill", tint: Color.teal, entries: [
            KitoCatalogEntry.new("Maps", "\(MapsGallery.count) samples · Apple, Google, MapLibre, pins, routes", systemImage: "map.fill") { MapsGallery() },
        ]),
        KitoCatalogSection(title: "Device", symbol: "iphone", tint: Color.mint, entries: [
            KitoCatalogEntry("Permissions", "\(PermissionsDemo.count) samples · primers, dashboard, recovery", systemImage: "hand.raised") { PermissionsDemo() },
            KitoCatalogEntry("Biometrics", "\(BiometricsDemo.count) samples · lock screens, protected actions", systemImage: "faceid") { BiometricsDemo() },
            KitoCatalogEntry("Keychain", "\(KeychainDemo.count) samples · vault, reveal on Face ID", systemImage: "key.fill") { KeychainDemo() },
            KitoCatalogEntry("Connectivity", "\(ConnectivityDemo.count) samples · banners, quality, retry when online", systemImage: "wifi") { ConnectivityDemo() },
        ]),
        KitoCatalogSection(title: "System", symbol: "gearshape.2.fill", tint: Color.yellow, entries: [
            KitoCatalogEntry("Control Center", "\(ControlCenterDemo.count) samples · glass modules, toggles, sliders", systemImage: "slider.horizontal.3") { ControlCenterDemo() },
            KitoCatalogEntry("Dynamic Island", "\(IslandGallery.count) samples · music, timers, calls, rides, moments", systemImage: "capsule.portrait") { IslandGallery() },
            KitoCatalogEntry.new("Widgets & Intents", "\(WidgetsGallery.count) samples · Home Screen, Lock Screen, Siri", systemImage: "square.grid.2x2.fill") { WidgetsGallery() },
        ]),
        KitoCatalogSection(title: "Networking", symbol: "network", tint: Color.gray, entries: [
            KitoCatalogEntry("Image Loader", "\(ImageLoaderDemo.count) samples · blur-up, avatars, zoom, masonry", systemImage: "photo.badge.arrow.down") { ImageLoaderDemo() },
        ]),
        KitoCatalogSection(title: "Commerce", symbol: "bag.fill", tint: Color.red, entries: [
            KitoCatalogEntry("Cart", "\(CartDemo.count) samples · steppers, promo codes, fly to cart", systemImage: "cart.fill") { CartDemo() },
            KitoCatalogEntry("Wallet & Cards", "\(WalletGallery.count) samples · pocket, stack, carousel, add a card", systemImage: "wallet.pass.fill") { WalletGallery() },
            KitoCatalogEntry.new("Paywall", "\(PaywallGallery.count) samples · StoreKit 2, plans, trials, Pro gate", systemImage: "crown.fill") { PaywallGallery() },
            KitoCatalogEntry("Order Tracking", "\(OrderTrackingDemo.count) samples · timelines, courier, Live Activity", systemImage: "shippingbox.fill") { OrderTrackingDemo() },
        ]),
    ]

    private var sections: [KitoCatalogSection] { Self.sections }
    private var allEntries: [KitoCatalogEntry] { sections.flatMap(\.entries) }
    private static let featuredTitles = ["Wallet & Cards", "Maps", "Dynamic Island", "Chat", "Charts", "Paywall"]

    private func section(of entry: KitoCatalogEntry) -> KitoCatalogSection? {
        sections.first { $0.entries.contains(entry) }
    }

    private func entry(titled title: String) -> KitoCatalogEntry? {
        allEntries.first { $0.title == title }
    }

    private var recents: [KitoCatalogEntry] {
        recentRaw.split(separator: "|").compactMap { entry(titled: String($0)) }
    }

    private func remember(_ entry: KitoCatalogEntry) {
        var titles = recentRaw.split(separator: "|").map(String.init).filter { $0 != entry.title }
        titles.insert(entry.title, at: 0)
        recentRaw = titles.prefix(6).joined(separator: "|")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if !query.trimmingCharacters(in: .whitespaces).isEmpty {
                    LazyVStack(alignment: .leading, spacing: 28) { searchResults }
                        .padding(16)
                } else {
                    home
                }
            }
            .scrollIndicators(.hidden)
            .background(backdrop)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search \(GlobalSampleIndex.all.count) samples and every kit")
            .navigationDestination(item: $surprise) { $0.destination }
        }
    }

    // MARK: Home

    private var home: some View {
        VStack(alignment: .leading, spacing: 30) {
            HomeHeader(kitCount: allEntries.count, sampleCount: GlobalSampleIndex.all.count) {
                if let pick = allEntries.randomElement() {
                    remember(pick)
                    surprise = pick
                }
            }
            .padding(.horizontal, 16)

            featuredCarousel

            newStrip

            if !recents.isEmpty { recentStrip }

            VStack(alignment: .leading, spacing: 14) {
                HomeSectionHeader(title: "Browse", symbol: "square.grid.2x2.fill", trailing: "\(allEntries.count) kits")
                    .padding(.horizontal, 16)
                HomeCategoryChips(categories: sections, selection: $category)
                grid.padding(.horizontal, 16)
            }

            footer
        }
        .padding(.top, 8)
        .padding(.bottom, 32)
    }

    private var featuredCarousel: some View {
        let items = Self.featuredTitles.compactMap(entry(titled:))
        return VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(title: "Featured", symbol: "star.fill").padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(items) { item in
                        link(item) { HomeFeatureCard(entry: item, category: section(of: item)?.title ?? "") }
                            .containerRelativeFrame(.horizontal) { width, _ in width - 48 }
                            .scrollTransition { content, phase in
                                content.scaleEffect(phase.isIdentity ? 1 : 0.92).opacity(phase.isIdentity ? 1 : 0.75)
                            }
                            .id(item.title)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $featured)
            .scrollClipDisabled()
            HStack(spacing: 6) {
                ForEach(items) { item in
                    Capsule()
                        .fill((featured ?? items.first?.title) == item.title ? theme.colors.primary : theme.colors.onBackground.opacity(0.2))
                        .frame(width: (featured ?? items.first?.title) == item.title ? 20 : 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: featured)
            .accessibilityHidden(true)
        }
    }

    private var newStrip: some View {
        let items = allEntries.filter(\.isNew)
        return VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(title: "New", symbol: "sparkles", trailing: "\(items.count) kits").padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(items) { item in
                        link(item) { HomeNewCard(entry: item, tint: section(of: item)?.tint ?? theme.colors.primary) }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollClipDisabled()
        }
    }

    private var recentStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(title: "Jump back in", symbol: "clock.arrow.circlepath").padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(recents) { item in
                        link(item) { HomeNewCard(entry: item, tint: section(of: item)?.tint ?? theme.colors.primary) }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollClipDisabled()
        }
    }

    @ViewBuilder
    private var grid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        let shown = category.map { title in sections.filter { $0.title == title } } ?? sections
        VStack(alignment: .leading, spacing: 22) {
            ForEach(shown) { section in
                VStack(alignment: .leading, spacing: 10) {
                    if category == nil {
                        Label(section.title.uppercased(), systemImage: section.symbol)
                            .font(.caption.weight(.bold))
                            .kerning(0.8)
                            .foregroundStyle(section.tint)
                    }
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(section.entries) { item in
                            link(item) { HomeKitTile(entry: item, tint: section.tint) }
                                .transition(.scale(scale: 0.9).combined(with: .opacity))
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: category)
    }

    private var footer: some View {
        VStack(spacing: 6) {
            Image(systemName: "swift").font(.title2).foregroundStyle(theme.colors.primary)
            Text("Made in Nairobi with SwiftUI").font(.footnote.weight(.semibold)).foregroundStyle(theme.colors.onBackground.opacity(0.7))
            Text("wyksoftsinc.com · v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")")
                .font(.caption).foregroundStyle(theme.colors.onBackground.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func link<Label: View>(_ entry: KitoCatalogEntry, @ViewBuilder label: () -> Label) -> some View {
        NavigationLink(destination: entry.destination) { label() }
            .buttonStyle(HomePressStyle())
            .simultaneousGesture(TapGesture().onEnded { remember(entry) })
    }

    // MARK: Search

    private var matchingKits: [KitoCatalogEntry] {
        let q = query.trimmingCharacters(in: .whitespaces)
        return allEntries.filter {
            $0.title.localizedCaseInsensitiveContains(q) || $0.subtitle.localizedCaseInsensitiveContains(q)
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        let kits = matchingKits
        let samples = GlobalSampleIndex.search(query)
        if kits.isEmpty && samples.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "magnifyingglass").font(.largeTitle).foregroundStyle(theme.colors.onBackground.opacity(0.4))
                Text("Nothing for “\(query)”").font(.headline).foregroundStyle(theme.colors.onBackground)
                Text("Try a kit (“charts”), a sample (“stepped”, “timer”) or a screen (“stock”).")
                    .font(.footnote).foregroundStyle(theme.colors.onBackground.opacity(0.6)).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
        }
        if !kits.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Kits")
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(kits) { item in
                        link(item) { HomeKitTile(entry: item, tint: section(of: item)?.tint ?? theme.colors.primary) }
                    }
                }
            }
        }
        if !samples.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle(samples.count == 60 ? "Top 60 samples" : "\(samples.count) sample\(samples.count == 1 ? "" : "s")")
                VStack(spacing: 0) {
                    ForEach(samples) { hit in
                        SampleSearchRow(hit: hit)
                        if hit.id != samples.last?.id { Divider().padding(.leading, 58) }
                    }
                }
                .kitoGlassCard(cornerRadius: theme.radii.lg)
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .kerning(0.8)
            .foregroundStyle(theme.colors.primary)
            .padding(.horizontal, 4)
    }

    // MARK: Backdrop

    private var backdrop: some View {
        ZStack {
            theme.colors.background.ignoresSafeArea()
            Circle()
                .fill(theme.colors.primary.opacity(0.28))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: -140, y: -260)
            Circle()
                .fill(theme.colors.secondary.opacity(0.22))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: 160, y: 120)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView().kitoTheme(.neon)
}
