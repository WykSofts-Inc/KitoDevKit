//
//  FashionHome.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCarousel
import KitoNavigation
import KitoProduct
import KitoToasts
import KitoTour

/// Home: an editorial hero, category chips, "New in", the lookbook and the designer spotlight.
struct FashionHomeScreen: View {
    @Environment(FashionStore.self) private var store
    @Environment(\.kitoTheme) private var theme
    @Environment(\.fashionExit) private var exit
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var heroPage = 0
    @State private var heroProgress: Double = 0
    @State private var chip = "All"
    @State private var lookPage = 0
    @State private var openStory: String?
    @State private var seenStories: Set<String> = []
    @State private var tour = KitoTourController(FashionHomeScreen.welcomeTour)

    private static let welcomeTour = KitoTour("maison.home", version: 1, title: "Welcome to Maison", steps: [
        KitoTourStep("hero", title: "The edit", message: "Swipe through this season's stories, or tap one to shop it.",
                     systemImage: "sparkles", placement: .bottom, spotlight: .roundedRect(cornerRadius: 0)),
        KitoTourStep("bag", title: "Your bag", message: "It follows you across every tab, with free delivery over KES 25,000.",
                     systemImage: "bag.fill", spotlight: .circle),
        KitoTourStep("exit", title: "Leave any time", message: "This closes the Maison demo and takes you back to the DevKit.",
                     systemImage: "xmark", spotlight: .circle, actionTitle: "Start shopping"),
    ])

    private var chips: [String] { ["All"] + FashionCategory.allCases.map(\.title) }

    private var newIn: [FashionItem] {
        guard let category = FashionCategory.allCases.first(where: { $0.title == chip }) else { return FashionCatalogue.newIn }
        let fresh = FashionCatalogue.items(in: category).sorted { ($0.isNew ? 1 : 0) > ($1.isNew ? 1 : 0) }
        return fresh
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                promiseStrip
                hero
                VStack(alignment: .leading, spacing: theme.spacing.xxl + 8) {
                    newInSection
                    lookbook
                    spotlight
                    trending
                    footer
                }
                .padding(.top, theme.spacing.xl)
                .padding(.bottom, theme.spacing.xxl)
            }
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .kitoTour(tour, style: .spotlight, tint: FashionPalette.gold)
        .task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            tour.startIfNeeded()
        }
        .fullScreenCover(isPresented: Binding(get: { openStory != nil }, set: { if !$0 { openStory = nil } })) {
            FashionDesignerStories(startingAt: openStory, seen: $seenStories) { openStory = nil }
        }
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            FashionWordmark(size: 17)
            HStack {
                FashionCircleButton(systemImage: "xmark", label: "Exit demo") { exit() }
                    .kitoTourAnchor("exit")
                Spacer()
                FashionCircleButton(systemImage: "bag", label: "Bag", badge: store.cart.totalQuantity) { store.show(.bag) }
                    .kitoTourAnchor("bag")
            }
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.sm)
    }

    private struct Promise: Identifiable {
        let id: String
        let symbol: String
    }

    private var promiseStrip: some View {
        let promises = [
            Promise(id: "Complimentary delivery over KES 25,000", symbol: "shippingbox"),
            Promise(id: "Free returns within 30 days", symbol: "arrow.uturn.left"),
            Promise(id: "Made in Nairobi, Lamu and Zanzibar", symbol: "scissors"),
            Promise(id: "Pay with M-Pesa or card", symbol: "creditcard"),
        ]
        return KitoInfiniteMarquee(promises, speed: 28, spacing: 36, pausesOnPress: true) { promise in
            Label(promise.id, systemImage: promise.symbol)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(theme.colors.onPrimary)
                .fixedSize()
        }
        .padding(.vertical, 9)
        .background(theme.colors.primary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Complimentary delivery over KES 25,000, free returns within 30 days")
    }

    // MARK: Hero

    private var hero: some View {
        ZStack(alignment: .bottom) {
            KitoCarousel(FashionCatalogue.editorials, selection: $heroPage, effect: .parallax, spacing: 0, peek: 0,
                         loops: true, autoPlay: reduceMotion ? nil : 5, autoPlayProgress: $heroProgress, cornerRadius: 0) { slide in
                FashionHeroSlide(slide: slide) { store.open(slide.destination) }
            }
            .frame(height: 500)
            .kitoTourAnchor("hero")
            KitoPageIndicator(count: FashionCatalogue.editorials.count, selection: $heroPage, style: .progress,
                              progress: heroProgress, dotSize: 6, tint: .white)
                .padding(.bottom, theme.spacing.lg)
        }
    }

    // MARK: New in

    private var newInSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            FashionSectionHeader(kicker: "Just landed", title: "New in", actionTitle: "Shop all") {
                store.pendingSearch = nil
                store.show(.search)
            }
            KitoTopTabs(chips, selection: $chip, style: .chips)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: theme.spacing.md) {
                    ForEach(newIn) { item in
                        KitoProductCard(item.product, style: .editorial, isWishlisted: store.savedBinding(item.id),
                                        onQuickAdd: { store.add($0, $1) },
                                        onSelect: { store.open(product: item.id) })
                            .frame(width: 250)
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
            }
            .animation(FashionMotion.spring(reduceMotion), value: chip)
        }
    }

    // MARK: Lookbook

    private var lookbook: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            FashionSectionHeader(kicker: "Lookbook", title: "Stories from the coast")
            KitoCarousel(FashionCatalogue.looks, selection: $lookPage, effect: .coverFlow, spacing: 14, peek: 44) { look in
                Button { store.open(.look(look.id)) } label: {
                    FashionLookCard(look: look)
                }
                .buttonStyle(FashionPressStyle(scale: 0.98))
                .accessibilityLabel("\(look.title), \(look.place). Shop the look")
            }
            .frame(height: 400)
            KitoPageIndicator(count: FashionCatalogue.looks.count, selection: $lookPage, style: .worm, dotSize: 7)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: Designer spotlight

    private var spotlight: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            FashionSectionHeader(kicker: "Designer spotlight", title: "Meet the atelier")
            KitoStoryTray(FashionCatalogue.designers, title: { $0.name.components(separatedBy: " ").first ?? $0.name },
                          isSeen: { seenStories.contains($0.id) }, isLive: { $0.id == "wanjiru" },
                          ringSize: 76, tint: FashionPalette.gold,
                          onSelect: { openStory = $0.id }) { designer in
                FashionDesignerAvatar(designer: designer, size: 76)
            }
            ForEach(FashionCatalogue.designers) { designer in
                Button { store.open(.designer(designer.id)) } label: {
                    HStack(spacing: theme.spacing.md) {
                        FashionDesignerAvatar(designer: designer, size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(designer.name).font(theme.typography.bodyEmphasized).foregroundStyle(theme.colors.onBackground)
                            Text("\(designer.discipline) · \(designer.city)").font(theme.typography.caption)
                                .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.onBackground.opacity(0.4))
                    }
                    .padding(.horizontal, theme.spacing.lg)
                    .contentShape(Rectangle())
                }
                .buttonStyle(FashionPressStyle(scale: 0.99))
            }
        }
    }

    // MARK: Trending

    private var trending: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            FashionSectionHeader(kicker: "Most loved", title: "Trending in Nairobi")
            FashionGrid(products: FashionCatalogue.trending.prefix(6).map(\.product))
        }
    }

    private var footer: some View {
        VStack(spacing: theme.spacing.sm) {
            FashionWordmark(size: 14)
            Text("Nairobi · Lamu · Zanzibar")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.onBackground.opacity(0.5))
            Text("A Kito DevKit demo. Products, designers and prices are invented.")
                .font(.system(size: 11))
                .foregroundStyle(theme.colors.onBackground.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, theme.spacing.xl)
    }
}
