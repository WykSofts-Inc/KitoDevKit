//
//  HomeComponents.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

// MARK: - Header

/// Greeting, the app's name with a glow, and live stats.
struct HomeHeader: View {
    let kitCount: Int
    let sampleCount: Int
    let onSurprise: () -> Void

    @Environment(\.kitoTheme) private var theme
    @State private var appeared = false

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text("WN").font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text(greeting).font(.subheadline).foregroundStyle(theme.colors.onBackground.opacity(0.6))
                    Text("Wycliff N").font(.headline).foregroundStyle(theme.colors.onBackground)
                }
                Spacer()
                NavigationLink(destination: SettingsDemo()) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(theme.colors.primary)
                        .frame(width: 44, height: 44)
                        .kitoGlassCard(cornerRadius: 22)
                }
                .buttonStyle(HomePressStyle())
                .accessibilityLabel("Settings")
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("KitoDevKit")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [theme.colors.onBackground, theme.colors.primary], startPoint: .leading, endPoint: .trailing)
                    )
                    .kitoGlow(theme.colors.primary, radius: 18, intensity: 0.35)
                Text("Every kit in the ecosystem, live and interactive.")
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.onBackground.opacity(0.6))
            }

            HStack(spacing: 8) {
                HomeStatPill(value: "\(kitCount)", label: "kits", systemImage: "square.stack.3d.up.fill")
                HomeStatPill(value: sampleCount.formatted(), label: "samples", systemImage: "sparkles")
                Spacer(minLength: 0)
                Button(action: onSurprise) {
                    Label("Surprise me", systemImage: "dice.fill")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Capsule().fill(theme.colors.primary))
                        .foregroundStyle(theme.colors.onPrimary)
                }
                .buttonStyle(HomePressStyle())
                .accessibilityHint("Opens a random kit")
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -10)
        .onAppear { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
    }
}

struct HomeStatPill: View {
    let value: String
    let label: String
    let systemImage: String
    @Environment(\.kitoTheme) private var theme

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage).font(.caption2.weight(.bold)).foregroundStyle(theme.colors.primary)
            Text(value).font(.caption.weight(.bold).monospacedDigit()).foregroundStyle(theme.colors.onBackground)
            Text(label).font(.caption).foregroundStyle(theme.colors.onBackground.opacity(0.6))
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
        .kitoGlassCard(cornerRadius: 16)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Featured

/// Art for a featured card: its gradient and the symbols scattered across it.
struct HomeFeatureArt {
    let colors: [Color]
    let symbols: [String]

    static func `for`(_ title: String) -> HomeFeatureArt {
        switch title {
        case "Wallet & Cards": return HomeFeatureArt(colors: [Color(red: 0.12, green: 0.2, blue: 0.55), Color(red: 0.45, green: 0.15, blue: 0.6)], symbols: ["creditcard.fill", "wallet.pass.fill", "banknote.fill"])
        case "Maps": return HomeFeatureArt(colors: [Color(red: 0.05, green: 0.45, blue: 0.42), Color(red: 0.1, green: 0.25, blue: 0.5)], symbols: ["map.fill", "mappin.circle.fill", "location.fill"])
        case "Dynamic Island": return HomeFeatureArt(colors: [Color(red: 0.1, green: 0.1, blue: 0.14), Color(red: 0.35, green: 0.12, blue: 0.4)], symbols: ["capsule.portrait.fill", "music.note", "timer"])
        case "Charts": return HomeFeatureArt(colors: [Color(red: 0.05, green: 0.4, blue: 0.3), Color(red: 0.1, green: 0.6, blue: 0.5)], symbols: ["chart.xyaxis.line", "chart.pie.fill", "chart.bar.fill"])
        case "Paywall": return HomeFeatureArt(colors: [Color(red: 0.55, green: 0.35, blue: 0.05), Color(red: 0.75, green: 0.2, blue: 0.3)], symbols: ["crown.fill", "star.fill", "sparkles"])
        case "AI Chat": return HomeFeatureArt(colors: [Color(red: 0.2, green: 0.1, blue: 0.45), Color(red: 0.05, green: 0.45, blue: 0.55)], symbols: ["sparkles", "text.bubble.fill", "wand.and.stars"])
        case "Chat": return HomeFeatureArt(colors: [Color(red: 0.1, green: 0.35, blue: 0.75), Color(red: 0.3, green: 0.2, blue: 0.7)], symbols: ["bubble.left.and.bubble.right.fill", "heart.fill", "waveform"])
        default: return HomeFeatureArt(colors: [.indigo, .purple], symbols: ["sparkles", "star.fill", "circle.hexagongrid.fill"])
        }
    }
}

struct HomeFeatureCard: View {
    let entry: KitoCatalogEntry
    let category: String

    private var art: HomeFeatureArt { .for(entry.title) }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: art.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(.white.opacity(0.12)).frame(width: 220).blur(radius: 30).offset(x: 170, y: -90)
            ZStack {
                Image(systemName: art.symbols[0]).font(.system(size: 92, weight: .bold)).rotationEffect(.degrees(-10))
                Image(systemName: art.symbols[1]).font(.system(size: 34, weight: .bold)).offset(x: -70, y: 50).opacity(0.7)
                Image(systemName: art.symbols[2]).font(.system(size: 26, weight: .bold)).offset(x: 60, y: -62).opacity(0.6)
            }
            .foregroundStyle(.white.opacity(0.28))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, 34).padding(.trailing, 42)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(category.uppercased()).font(.caption2.weight(.heavy)).kerning(1).opacity(0.75)
                Text(entry.title).font(.system(size: 28, weight: .bold, design: .rounded))
                Text(entry.blurb.capitalizedFirst).font(.subheadline).opacity(0.85).lineLimit(2)
                HStack {
                    if let count = entry.countText {
                        Text(count).font(.caption.weight(.bold)).padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Capsule().fill(.white.opacity(0.2)))
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Text("Explore")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Capsule().fill(.white))
                    .foregroundStyle(art.colors[0])
                }
                .padding(.top, 6)
            }
            .foregroundStyle(.white)
            .padding(20)
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).strokeBorder(.white.opacity(0.15), lineWidth: 1))
        .shadow(color: art.colors[0].opacity(0.45), radius: 22, y: 12)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Tiles

/// A kit in the grid: a tinted icon, its name and sample count.
struct HomeKitTile: View {
    let entry: KitoCatalogEntry
    let tint: Color
    @Environment(\.kitoTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: entry.systemImage)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(LinearGradient(colors: [tint, tint.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    .shadow(color: tint.opacity(0.5), radius: 10, y: 4)
                Spacer()
                if entry.isNew { HomeNewBadge() }
            }
            Spacer(minLength: 0)
            Text(entry.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(theme.colors.onBackground)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Text(entry.countText ?? entry.blurb.capitalizedFirst)
                .font(.caption)
                .foregroundStyle(theme.colors.onBackground.opacity(0.55))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(alignment: .topLeading) {
            Circle().fill(tint.opacity(0.28)).frame(width: 120).blur(radius: 40).offset(x: -30, y: -40)
        }
        .kitoGlassCard(cornerRadius: 24)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint(entry.blurb)
    }
}

/// A small card for the "New" strip.
struct HomeNewCard: View {
    let entry: KitoCatalogEntry
    let tint: Color
    @Environment(\.kitoTheme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(tint))
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title).font(.subheadline.weight(.bold)).foregroundStyle(theme.colors.onBackground).lineLimit(1)
                Text(entry.countText ?? "New").font(.caption).foregroundStyle(theme.colors.onBackground.opacity(0.55))
            }
        }
        .padding(.leading, 10).padding(.trailing, 16).padding(.vertical, 10)
        .kitoGlassCard(cornerRadius: 30)
        .accessibilityElement(children: .combine)
    }
}

struct HomeNewBadge: View {
    var body: some View {
        Text("NEW")
            .font(.system(size: 9, weight: .heavy))
            .kerning(0.6)
            .padding(.horizontal, 7).padding(.vertical, 4)
            .background(Capsule().fill(LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing)))
            .foregroundStyle(.white)
    }
}

// MARK: - Chips and headers

struct HomeCategoryChips: View {
    let categories: [KitoCatalogSection]
    @Binding var selection: String?
    @Environment(\.kitoTheme) private var theme
    @Namespace private var namespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(nil, title: "All", symbol: "square.grid.2x2.fill")
                ForEach(categories) { section in chip(section.title, title: section.title, symbol: section.symbol) }
            }
            .padding(.horizontal, 16)
        }
        .scrollClipDisabled()
    }

    private func chip(_ id: String?, title: String, symbol: String) -> some View {
        let selected = selection == id
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selection = id }
        } label: {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14).padding(.vertical, 9)
                .foregroundStyle(selected ? theme.colors.onPrimary : theme.colors.onBackground.opacity(0.8))
                .background {
                    if selected {
                        Capsule().fill(theme.colors.primary).matchedGeometryEffect(id: "chip", in: namespace)
                    } else {
                        Capsule().fill(theme.colors.onBackground.opacity(0.07))
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct HomeSectionHeader: View {
    let title: String
    var symbol: String?
    var trailing: String?
    @Environment(\.kitoTheme) private var theme

    var body: some View {
        HStack(spacing: 8) {
            if let symbol { Image(systemName: symbol).foregroundStyle(theme.colors.primary) }
            Text(title).font(.title3.weight(.bold)).foregroundStyle(theme.colors.onBackground)
            Spacer()
            if let trailing { Text(trailing).font(.caption.weight(.semibold)).foregroundStyle(theme.colors.onBackground.opacity(0.5)) }
        }
        .accessibilityAddTraits(.isHeader)
    }
}

struct HomePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension String {
    /// "sheets, alerts" → "Sheets, alerts".
    var capitalizedFirst: String { prefix(1).uppercased() + dropFirst() }
}

// MARK: - Showcase apps

/// A complete demo app built only from Kito packages, opened full screen from the home screen.
struct HomeShowcaseApp: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let colors: [Color]
    let kits: [String]
    let makeView: () -> AnyView

    static let all: [HomeShowcaseApp] = [
        HomeShowcaseApp(id: "maison", title: FashionShowcase.title, subtitle: FashionShowcase.subtitle, systemImage: FashionShowcase.systemImage,
                        colors: [Color(red: 0.12, green: 0.1, blue: 0.09), Color(red: 0.55, green: 0.42, blue: 0.3)],
                        kits: ["Product", "Checkout", "Search", "Carousel", "Reviews", "Paywall"]) { AnyView(FashionShowcaseApp()) },
    ]
}

struct HomeShowcaseCard: View {
    let app: HomeShowcaseApp

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: app.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: app.systemImage)
                .font(.system(size: 110, weight: .bold))
                .foregroundStyle(.white.opacity(0.14))
                .rotationEffect(.degrees(-12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 20).padding(.trailing, 18)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Label("DEMO APP", systemImage: "iphone.gen3")
                    .font(.caption2.weight(.heavy)).kerning(1).opacity(0.75)
                Text(app.title).font(.system(size: 30, weight: .bold, design: .serif))
                Text(app.subtitle).font(.subheadline).opacity(0.85)
                Text("Built with " + app.kits.prefix(4).joined(separator: ", ") + " and more")
                    .font(.caption).opacity(0.7).lineLimit(1)
                HStack(spacing: 6) {
                    Text("Open app")
                    Image(systemName: "arrow.up.right")
                }
                .font(.subheadline.weight(.bold))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Capsule().fill(.white))
                .foregroundStyle(app.colors[0])
                .padding(.top, 4)
            }
            .foregroundStyle(.white)
            .padding(20)
        }
        .frame(width: 280, height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(.white.opacity(0.14), lineWidth: 1))
        .shadow(color: app.colors[0].opacity(0.4), radius: 18, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens the \(app.title) demo app full screen")
    }
}
