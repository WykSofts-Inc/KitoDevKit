//
//  MapsSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit
import KitoMaps
import KitoMapsGoogle
import KitoMapsLibre

// MARK: - Places

private func spot(_ id: String, _ lat: Double, _ lon: Double, _ title: String, _ subtitle: String,
                  _ style: KitoMapPinStyle, tint: Color? = nil, badge: String? = nil, symbol: String? = nil) -> KitoMapPin {
    KitoMapPin(id: id, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), title: title,
               subtitle: subtitle, style: style, tint: tint, badge: badge, systemImage: symbol)
}

private enum Places {
    static let kicc = CLLocationCoordinate2D(latitude: -1.2884, longitude: 36.8233)
    static let nairobi = CLLocationCoordinate2D(latitude: -1.2864, longitude: 36.8172)

    static let nairobiSpots: [KitoMapPin] = [
        spot("java", -1.2635, 36.8030, "Java House", "Coffee · ABC Place", .icon("cup.and.saucer.fill"), tint: .brown, badge: "4.6"),
        spot("artcaffe", -1.2571, 36.8030, "Artcaffé", "Bakery · Westgate", .icon("birthday.cake.fill"), tint: .pink, badge: "4.5"),
        spot("carnivore", -1.3281, 36.8054, "Carnivore", "Nyama choma · Langata", .icon("fork.knife"), tint: .orange, badge: "4.7"),
        spot("karura", -1.2376, 36.8335, "Karura Forest", "Trails & waterfall", .icon("tree.fill"), tint: .green, badge: "4.9"),
        spot("kicc", -1.2884, 36.8233, "KICC", "Rooftop helipad views", .teardrop, tint: .indigo, symbol: "building.columns.fill"),
        spot("museum", -1.2744, 36.8144, "Nairobi National Museum", "Museum Hill", .icon("building.columns"), tint: .teal, badge: "4.4"),
        spot("giraffe", -1.3760, 36.7446, "Giraffe Centre", "Langata", .icon("pawprint.fill"), tint: .yellow, badge: "4.8"),
        spot("alchemist", -1.2663, 36.8061, "The Alchemist", "Bar & food trucks", .icon("music.note"), tint: .purple, badge: "4.3"),
        spot("talisman", -1.3226, 36.7109, "Talisman", "Garden restaurant · Karen", .icon("leaf.fill"), tint: .mint, badge: "4.7"),
        spot("park", -1.3733, 36.8589, "Nairobi National Park", "Main gate", .icon("binoculars.fill"), tint: .green, badge: "4.8"),
    ]

    static let stays: [KitoMapPin] = [
        spot("kilimani", -1.2890, 36.7870, "Kilimani loft", "1 bed · rooftop pool", .bubble("KSh 4,500"), badge: "4.8", symbol: nil),
        spot("westlands", -1.2660, 36.8050, "Westlands studio", "Studio · walk to Sarit", .bubble("KSh 6,200"), badge: "4.7"),
        spot("lavington", -1.2780, 36.7690, "Lavington villa", "3 beds · garden", .bubble("KSh 12,800"), badge: "4.9"),
        spot("karen", -1.3190, 36.7100, "Karen cottage", "2 beds · fireplace", .bubble("KSh 9,300"), badge: "4.9"),
        spot("upperhill", -1.2990, 36.8150, "Upper Hill suite", "1 bed · city view", .bubble("KSh 7,400"), badge: "4.6"),
        spot("kileleshwa", -1.2830, 36.7830, "Kileleshwa flat", "2 beds · gym", .bubble("KSh 5,100"), badge: "4.5"),
        spot("runda", -1.2170, 36.8150, "Runda house", "4 beds · pool", .bubble("KSh 15,500"), badge: "5.0"),
        spot("parklands", -1.2600, 36.8190, "Parklands room", "Private room", .bubble("KSh 3,900"), badge: "4.4"),
    ]

    static let friends: [KitoMapPin] = [
        spot("amina", -1.2840, 36.8200, "Amina", "At KICC · 2 min ago", .avatar(initials: "AW"), tint: .pink),
        spot("brian", -1.2700, 36.8110, "Brian", "Westlands · just now", .avatar(initials: "BK"), tint: .blue),
        spot("chebet", -1.3000, 36.7870, "Chebet", "Yaya Centre · 5 min ago", .avatar(initials: "CC"), tint: .orange),
        spot("david", -1.2560, 36.8330, "David", "Muthaiga · 12 min ago", .avatar(initials: "DM"), tint: .teal, badge: "2"),
        spot("wycliff", -1.2930, 36.8060, "Wycliff", "Upper Hill · live", .avatar(initials: "WN"), tint: .indigo),
    ]

    static let coast: [KitoMapPin] = [
        spot("fortjesus", -4.0626, 39.6795, "Fort Jesus", "Old Town, Mombasa", .icon("shield.lefthalf.filled"), tint: .brown, badge: "4.6"),
        spot("nyali", -4.0340, 39.7180, "Nyali Beach", "Mombasa", .icon("beach.umbrella.fill"), tint: .cyan, badge: "4.5"),
        spot("haller", -4.0021, 39.7274, "Haller Park", "Bamburi", .icon("tortoise.fill"), tint: .green, badge: "4.6"),
        spot("diani", -4.2797, 39.5947, "Diani Beach", "Kwale", .icon("sun.horizon.fill"), tint: .orange, badge: "4.9"),
        spot("stonetown", -6.1630, 39.1880, "Stone Town", "Zanzibar", .icon("building.2.fill"), tint: .indigo, badge: "4.7"),
        spot("forodhani", -6.1606, 39.1880, "Forodhani Gardens", "Night food market", .icon("takeoutbag.and.cup.and.straw.fill"), tint: .red, badge: "4.6"),
        spot("nungwi", -5.7270, 39.2960, "Nungwi", "North Zanzibar", .icon("water.waves"), tint: .teal, badge: "4.8"),
        spot("paje", -6.2660, 39.5360, "Paje", "Kitesurfing", .icon("wind"), tint: .mint, badge: "4.7"),
    ]

    static let kisumu: [KitoMapPin] = [
        spot("dunga", -0.1486, 34.7406, "Dunga Beach", "Lake Victoria · boat rides", .icon("sailboat.fill"), tint: .blue, badge: "4.5"),
        spot("impala", -0.1137, 34.7433, "Impala Sanctuary", "Kisumu", .icon("hare.fill"), tint: .green, badge: "4.4"),
        spot("kisumumuseum", -0.1010, 34.7610, "Kisumu Museum", "Kisumu", .icon("building.columns"), tint: .teal, badge: "4.2"),
    ]

    /// Westlands to KICC along Waiyaki Way and Uhuru Highway.
    static let cbdRoute: [CLLocationCoordinate2D] = [
        (-1.2676, 36.8108), (-1.2702, 36.8126), (-1.2731, 36.8146), (-1.2759, 36.8160), (-1.2788, 36.8168),
        (-1.2815, 36.8177), (-1.2840, 36.8186), (-1.2858, 36.8207), (-1.2872, 36.8222), (-1.2884, 36.8233),
    ].map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }

    /// Java House ABC Place to a flat in Kileleshwa.
    static let deliveryRoute: [CLLocationCoordinate2D] = [
        (-1.2635, 36.8030), (-1.2652, 36.8012), (-1.2671, 36.7990), (-1.2694, 36.7968), (-1.2718, 36.7950),
        (-1.2741, 36.7921), (-1.2763, 36.7897), (-1.2789, 36.7872), (-1.2812, 36.7851), (-1.2830, 36.7830),
    ].map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }

    /// Mombasa to Stone Town by sea.
    static let ferry: [CLLocationCoordinate2D] = [
        (-4.0700, 39.6900), (-4.4500, 39.7200), (-5.1000, 39.5500), (-5.7500, 39.3200), (-6.1600, 39.1900),
    ].map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }

    /// A loop through Karura Forest, as an encoded polyline — the format routing APIs return.
    static let karuraTrail = "vurFoex_FkMcG_NsIcL_NwGgO_I{JwGbLwBnPnF~MfOfJbQnFnPnAjM_D"

    /// 140 M-Pesa agents scattered around Nairobi, the same every launch.
    static let agents: [KitoMapPin] = {
        var seed: UInt64 = 0x4B49544F
        func next() -> Double {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Double(seed >> 11) / Double(1 << 53)
        }
        let hubs = [(-1.2864, 36.8172), (-1.2640, 36.8040), (-1.3000, 36.7870), (-1.3190, 36.7100), (-1.2330, 36.8800), (-1.3100, 36.8900)]
        return (0..<140).map { index in
            let hub = hubs[index % hubs.count]
            let lat = hub.0 + (next() - 0.5) * 0.045, lon = hub.1 + (next() - 0.5) * 0.045
            return spot("agent-\(index)", lat, lon, "M-Pesa agent \(index + 1)", "Open until 21:00", .dot, tint: .green)
        }
    }()

    static let cities: [City] = [
        City(name: "Nairobi", pins: nairobiSpots), City(name: "Mombasa", pins: Array(coast.prefix(4))),
        City(name: "Kisumu", pins: kisumu), City(name: "Zanzibar", pins: Array(coast.suffix(4))),
    ]
}

private struct City: Identifiable {
    let name: String
    let pins: [KitoMapPin]
    var id: String { name }
}

// MARK: - Shared pieces

/// A floating title in the corner of a map screen.
private struct MapTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 3)
        .padding(12)
    }
}

/// A capsule segmented control floating over a map.
private struct FloatingPicker<Value: Hashable>: View {
    @Binding var selection: Value
    let options: [Value]
    let title: (Value) -> String

    var body: some View {
        Picker("Style", selection: $selection) {
            ForEach(options, id: \.self) { Text(title($0)).tag($0) }
        }
        .pickerStyle(.segmented)
        .padding(6)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
}

/// A stays card: artwork, rating, price per night.
private struct StayCard: View {
    let pin: KitoMapPin

    var body: some View {
        let tint = pin.tint ?? .indigo
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [tint, tint.opacity(0.45), .orange.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 84, height: 84)
                .overlay(Image(systemName: "house.lodge.fill").font(.title2).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(pin.title).font(.headline).lineLimit(1)
                    Spacer(minLength: 4)
                    Label(pin.badge ?? "4.8", systemImage: "star.fill").font(.caption.weight(.bold)).labelStyle(.titleAndIcon)
                }
                Text(pin.subtitle ?? "").font(.caption).foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(pin.priceText ?? "").font(.headline).monospacedDigit()
                    Text("night").font(.caption).foregroundStyle(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(12)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 6)
    }
}

// MARK: - Google key

/// Reads `GMSApiKey` from Info.plist once and hands it to the SDK.
@MainActor
private enum GoogleKey {
    static let isReady: Bool = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String else { return false }
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else { return false }
        return KitoGoogleMaps.provideAPIKey(trimmed)
    }()
}

/// Shows Google content when a key is set up, otherwise a card explaining how to add one.
private struct GoogleGate<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        if GoogleKey.isReady { content() } else { GoogleKeyCard() }
    }
}

private struct GoogleKeyCard: View {
    @State private var copied = false
    private let snippet = "<key>GMSApiKey</key>\n<string>YOUR_API_KEY</string>"

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.18), Color.green.opacity(0.12), Color(.systemBackground)],
                           startPoint: .topLeading, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "key.viewfinder")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add your Google Maps API key").font(.headline)
                        Text("Google Maps needs a key; nothing else changes.").font(.caption).foregroundStyle(.secondary)
                    }
                }
                step(1, "Create a key with **Maps SDK for iOS** enabled in the Google Cloud console.")
                step(2, "Add it to KitoSample's Info.plist as **GMSApiKey** (or `GMSApiKey: $(GMS_API_KEY)` in project.yml with the value in an untracked xcconfig).")
                step(3, "Rebuild. These samples call `KitoGoogleMaps.provideAPIKey(_:)` once with it.")
                Text(snippet)
                    .font(.system(.caption, design: .monospaced))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Button {
                    UIPasteboard.general.string = snippet
                    withAnimation(.snappy) { copied = true }
                } label: {
                    Label(copied ? "Copied" : "Copy Info.plist snippet", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .contentTransition(.symbolEffect(.replace))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
                Label("The MapLibre samples work without any key.", systemImage: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 24, y: 10)
            .padding(18)
        }
    }

    private func step(_ number: Int, _ text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.blue))
            Text(text).font(.subheadline)
        }
    }
}

// MARK: - Apple Maps samples

private struct PlacesWithCards: View {
    @State private var selected: String? = "carnivore"

    var body: some View {
        KitoMapView(pins: Places.nairobiSpots, selection: $selected) { pin in
            KitoMapPinCard(pin: pin, detail: "Open until 23:00")
        }
        .controls(.all)
        .overlay(alignment: .topLeading) { MapTitle(title: "Nairobi", subtitle: "\(Places.nairobiSpots.count) favourite spots") }
    }
}

private struct AppleStyles: View {
    @State private var style = KitoMapStyle.muted

    var body: some View {
        KitoMapView(pins: Places.nairobiSpots, style: style)
            .controls([.pitch])
            .overlay(alignment: .bottom) {
                FloatingPicker(selection: $style, options: KitoMapStyle.allCases) { $0.title }
            }
    }
}

private struct CityIn3D: View {
    var body: some View {
        KitoMapView(pins: [Places.nairobiSpots[4], Places.nairobiSpots[5]], style: .standard, camera: .center(Places.kicc, zoom: 16.5))
            .startsIn3D()
            .controls([.pitch, .styleSwitcher])
            .overlay(alignment: .topLeading) { MapTitle(title: "Nairobi CBD", subtitle: "Tilted, with realistic elevation") }
    }
}

private struct NearMe: View {
    var body: some View {
        KitoMapView(pins: Places.nairobiSpots, style: .muted)
            .showsUserLocation()
            .controls([.userLocation, .fitAll])
            .overlay(alignment: .topLeading) { MapTitle(title: "Near you", subtitle: "Tap the arrow to find yourself") }
    }
}

private struct SnapshotList: View {
    private let rows = [Places.nairobiSpots[2], Places.nairobiSpots[3], Places.coast[0]]

    var body: some View {
        VStack(spacing: 14) {
            ForEach(rows) { pin in
                VStack(alignment: .leading, spacing: 0) {
                    KitoMapSnapshot(center: pin.coordinate, meters: 1_400, pins: [pin])
                        .frame(height: 120)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pin.title).font(.headline)
                            Text(pin.subtitle ?? "").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Label(pin.badge ?? "", systemImage: "star.fill").font(.caption.weight(.semibold))
                    }
                    .padding(12)
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }
}

// MARK: - Pin samples

private struct PinStyles: View {
    @State private var selected: Set<String> = ["bubble"]
    private let pins: [KitoMapPin] = [
        spot("dot", 0, 0, "Dot", "", .dot, tint: .blue),
        spot("icon", 0, 0, "Icon", "", .icon("cup.and.saucer.fill"), tint: .brown, badge: "4.6"),
        spot("bubble", 0, 0, "Bubble", "", .bubble("KSh 4,500")),
        spot("avatar", 0, 0, "Avatar", "", .avatar(initials: "WN"), tint: .indigo),
        spot("teardrop", 0, 0, "Teardrop", "", .teardrop, tint: .red, symbol: "fork.knife"),
        KitoMapPin(id: "pulse", coordinate: CLLocationCoordinate2D(), title: "Pulse", style: .pulse, tint: .green,
                   systemImage: "bicycle", heading: 40),
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(pins) { pin in
                Button {
                    if selected.contains(pin.id) { selected.remove(pin.id) } else { selected.insert(pin.id) }
                } label: {
                    VStack(spacing: 10) {
                        KitoMapPinView(pin: pin, isSelected: selected.contains(pin.id))
                            .frame(height: 86)
                        Text(pin.title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LinearGradient(colors: [Color.green.opacity(0.10), Color.blue.opacity(0.08)], startPoint: .top, endPoint: .bottom))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(pin.title) pin")
                .accessibilityAddTraits(selected.contains(pin.id) ? .isSelected : [])
            }
        }
    }
}

private struct PriceBubbles: View {
    @State private var selected: String? = "lavington"

    var body: some View {
        KitoMapView(pins: Places.stays, selection: $selected, style: .muted)
            .controls([.fitAll])
            .overlay(alignment: .topLeading) { MapTitle(title: "Stays in Nairobi", subtitle: "Tap a price") }
    }
}

private struct FriendsNearby: View {
    @State private var selected: String?

    var body: some View {
        KitoMapView(pins: Places.friends, selection: $selected, style: .muted) { pin in
            KitoMapPinCard(pin: pin, detail: "Say hi")
        }
        .controls([])
        .overlay(alignment: .topLeading) { MapTitle(title: "Friends", subtitle: "\(Places.friends.count) sharing location") }
    }
}

private struct LivePulse: View {
    private let riders: [KitoMapPin] = [
        KitoMapPin(id: "r1", coordinate: .init(latitude: -1.2800, longitude: 36.8120), title: "Otieno", subtitle: "Boda · 2 min",
                   style: .pulse, tint: .green, systemImage: "bicycle", heading: 45),
        KitoMapPin(id: "r2", coordinate: .init(latitude: -1.2890, longitude: 36.8010), title: "Wanjiru", subtitle: "Car · 5 min",
                   style: .pulse, tint: .blue, systemImage: "car.fill", heading: 190),
        KitoMapPin(id: "r3", coordinate: .init(latitude: -1.2950, longitude: 36.8230), title: "Kamau", subtitle: "Walking · 8 min",
                   style: .pulse, tint: .orange, systemImage: "figure.walk", heading: 300),
        KitoMapPin(id: "me", coordinate: .init(latitude: -1.2864, longitude: 36.8172), title: "You", style: .pulse, tint: .blue),
    ]

    var body: some View {
        KitoMapView(pins: riders, style: .muted)
            .controls([])
            .overlay(alignment: .topLeading) { MapTitle(title: "Riders near you", subtitle: "Live, with direction of travel") }
    }
}

// MARK: - Clusters & cards

private struct SplittingClusters: View {
    var body: some View {
        KitoMapView(pins: Places.agents, style: .muted)
            .clustering()
            .controls([.fitAll])
            .overlay(alignment: .topLeading) { MapTitle(title: "M-Pesa agents", subtitle: "Pinch to split \(Places.agents.count) pins") }
    }
}

private struct SyncedCarousel: View {
    @State private var selected: String? = "kilimani"

    var body: some View {
        KitoMapView(pins: Places.stays, selection: $selected, style: .muted) { pin in
            KitoMapPinCard(pin: pin, detail: "Free cancellation")
        }
        .clustering()
        .controls([.fitAll])
    }
}

private struct CustomCards: View {
    @State private var selected: String? = "karen"

    var body: some View {
        KitoMapView(pins: Places.stays, selection: $selected) { pin in
            StayCard(pin: pin)
        }
        .controls([])
        .overlay(alignment: .topLeading) { MapTitle(title: "Weekend stays", subtitle: "Swipe the cards") }
    }
}

private struct CityHopper: View {
    @State private var map = KitoMapController()
    @State private var city = "Nairobi"
    private let pins = Places.nairobiSpots + Places.coast + Places.kisumu

    var body: some View {
        KitoMapView(pins: pins, camera: .fit(Places.nairobiSpots.map(\.coordinate)), controller: map)
            .clustering()
            .controls([])
            .overlay(alignment: .bottom) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Places.cities) { entry in
                            Button {
                                city = entry.name
                                map.move(to: .fit(entry.pins.map(\.coordinate)))
                            } label: {
                                Text(entry.name)
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(city == entry.name ? Color.primary : Color(.systemBackground)))
                                    .foregroundStyle(city == entry.name ? Color(.systemBackground) : Color.primary)
                                    .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .padding(.bottom, 20)
                .animation(.snappy, value: city)
            }
    }
}

// MARK: - Routes & tracking

private struct Directions: View {
    @State private var route: KitoMapRoute?
    @State private var source = "Finding the fastest route…"
    private let from = spot("westlands-stage", -1.2676, 36.8108, "Westlands", "Start", .teardrop, tint: .green, symbol: "figure.wave")
    private let to = spot("kicc-end", -1.2884, 36.8233, "KICC", "Destination", .teardrop, tint: .red, symbol: "flag.checkered")

    var body: some View {
        KitoMapView(pins: [from, to], camera: .fit(Places.cbdRoute))
            .overlays(route.map { [KitoMapOverlay.route($0, color: .blue)] } ?? [])
            .controls([])
            .overlay(alignment: .bottom) {
                HStack(spacing: 14) {
                    Image(systemName: "car.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Color.blue))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(route.map { "\($0.formattedTravelTime) · \($0.formattedDistance)" } ?? "—")
                            .font(.title3.bold())
                            .contentTransition(.numericText())
                        Text(source).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 18, y: 6)
                .padding(16)
                .redacted(reason: route == nil ? .placeholder : [])
            }
            .task {
                do {
                    let found = try await KitoRouteService.route(from: from.coordinate, to: to.coordinate)
                    withAnimation(.snappy) { route = found; source = "Apple Maps · \(found.name)" }
                } catch {
                    withAnimation(.snappy) {
                        route = KitoMapRoute(coordinates: Places.cbdRoute, expectedTravelTime: 11 * 60, name: "Waiyaki Way")
                        source = "Sample route · directions unavailable offline"
                    }
                }
            }
    }
}

private struct DeliveryTracking: View {
    @State private var rider = KitoLiveTracker(
        route: Places.deliveryRoute, duration: 45,
        pin: KitoMapPin(id: "rider", coordinate: Places.deliveryRoute[0], title: "Otieno", subtitle: "Your rider",
                        style: .pulse, tint: .green, systemImage: "bicycle"))
    private let shop = spot("shop", -1.2635, 36.8030, "Java House", "Picked up", .icon("cup.and.saucer.fill"), tint: .brown)
    private let home = spot("home", -1.2830, 36.7830, "Home", "Kileleshwa", .teardrop, tint: .indigo, symbol: "house.fill")

    var body: some View {
        KitoMapView(pins: [shop, home, rider.pin], style: .muted, camera: .fit(Places.deliveryRoute))
            .overlays(rider.overlays(color: .green))
            .controls([])
            .followsSelection(false)
            .fitPadding(EdgeInsets(top: 60, leading: 40, bottom: 220, trailing: 40))
            .overlay(alignment: .bottom) { etaCard }
            .onAppear { rider.start() }
            .onDisappear { rider.pause() }
    }

    private var etaCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text("OT")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color.green.gradient))
                VStack(alignment: .leading, spacing: 2) {
                    Text(rider.hasArrived ? "Otieno has arrived" : "Otieno is on the way").font(.headline)
                    Text(rider.hasArrived ? "Meet your rider outside" : "Boda · KDA 123X").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(rider.formattedCountdown)
                        .font(.title2.weight(.bold).monospacedDigit())
                        .contentTransition(.numericText(countsDown: true))
                    Text(KitoMapFormat.distance(rider.remainingDistance)).font(.caption).foregroundStyle(.secondary)
                }
            }
            ProgressView(value: rider.progress).tint(.green)
            Button {
                rider.reset()
                rider.start()
            } label: {
                Label("Replay delivery", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .padding(18)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        .padding(14)
        .animation(.snappy, value: rider.hasArrived)
    }
}

private struct DeliveryZone: View {
    @State private var radius: Double = 3_000
    private let kitchen = spot("kitchen", -1.2890, 36.7870, "Kilimani kitchen", "Cloud kitchen", .icon("frying.pan.fill"), tint: .orange)

    private var customers: [KitoMapPin] {
        Places.stays.map { stay in
            let inside = KitoMapGeometry.distance(from: kitchen.coordinate, to: stay.coordinate) <= radius
            return KitoMapPin(id: stay.id, coordinate: stay.coordinate, title: stay.title,
                              subtitle: inside ? "Delivers here" : "Outside the zone", style: .dot, tint: inside ? .green : .gray)
        }
    }

    var body: some View {
        let reachable = customers.filter { $0.tint == .green }.count
        KitoMapView(pins: [kitchen] + customers, style: .muted, camera: .center(kitchen.coordinate, zoom: 12.3))
            .overlays([.circle(center: kitchen.coordinate, radius: radius, id: "zone", color: .orange)])
            .controls([])
            .followsSelection(false)
            .overlay(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Delivery radius").font(.headline)
                        Spacer()
                        Text(KitoMapFormat.distance(radius)).font(.headline.monospacedDigit()).contentTransition(.numericText())
                    }
                    Slider(value: $radius, in: 800...6_000, step: 100).tint(.orange)
                    Text("\(reachable) of \(customers.count) addresses can order").font(.caption).foregroundStyle(.secondary)
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 16, y: 6)
                .padding(14)
            }
    }
}

private struct SearchPlaces: View {
    @State private var pins: [KitoMapPin] = [Places.nairobiSpots[4]]
    @State private var selected: String?
    @State private var map = KitoMapController()

    var body: some View {
        KitoMapView(pins: pins, selection: $selected, style: .muted, camera: .center(Places.nairobi, zoom: 12.5), controller: map)
            .controls([])
            .overlay(alignment: .top) {
                KitoPlaceSearchField("Search Nairobi", near: MKCoordinateRegion(center: Places.nairobi, latitudinalMeters: 30_000,
                                                                              longitudinalMeters: 30_000)) { place in
                    let pin = place.pin(style: .teardrop, tint: .red)
                    withAnimation(.snappy) {
                        pins.removeAll { $0.id == pin.id }
                        pins.append(pin)
                        selected = pin.id
                    }
                    map.focus(on: pin, zoom: 16)
                }
                .padding(14)
            }
    }
}

private struct PickLocation: View {
    @State private var confirmed: KitoPickedLocation?

    var body: some View {
        KitoLocationPicker(initialCoordinate: Places.kicc, title: "Deliver to") { picked in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { confirmed = picked }
        }
        .overlay(alignment: .top) {
            if let confirmed {
                Label("Delivering to \(confirmed.name)", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                    .padding(.top, 14)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task {
                        try? await Task.sleep(nanoseconds: 2_500_000_000)
                        withAnimation { self.confirmed = nil }
                    }
            }
        }
    }
}

private struct EncodedTrail: View {
    private let trail = KitoPolyline.decode(Places.karuraTrail) ?? []

    var body: some View {
        let start = spot("trailhead", trail.first?.latitude ?? -1.2376, trail.first?.longitude ?? 36.8335, "Trailhead", "Gate A",
                         .teardrop, tint: .green, symbol: "figure.hiking")
        KitoMapView(pins: [start, Places.nairobiSpots[3]], style: .imagery, camera: .fit(trail))
            .overlays([.polyline(trail, id: "trail", color: .yellow, lineWidth: 5, dashed: true)])
            .controls([.styleSwitcher])
            .overlay(alignment: .topLeading) {
                MapTitle(title: "Karura loop", subtitle: KitoMapFormat.distance(KitoMapGeometry.length(of: trail)) + " · decoded polyline")
            }
    }
}

// MARK: - Google Maps

private struct GooglePlaces: View {
    @State private var selected: String? = "java"

    var body: some View {
        GoogleGate {
            KitoGoogleMapView(pins: Places.nairobiSpots, selection: $selected) { pin in
                KitoMapPinCard(pin: pin, detail: "Open until 23:00")
            }
            .controls(.all)
        }
    }
}

private struct GoogleStyles: View {
    @State private var style = KitoGoogleMapStyle.muted

    var body: some View {
        GoogleGate {
            KitoGoogleMapView(pins: Places.stays, style: style)
                .controls([.pitch])
                .overlay(alignment: .bottom) {
                    FloatingPicker(selection: $style, options: [.standard, .muted, .dark, .satellite, .terrain]) { $0.title }
                }
        }
    }
}

private struct GoogleClustersAndRoute: View {
    var body: some View {
        GoogleGate {
            KitoGoogleMapView(pins: Places.agents, style: .automatic)
                .clustering()
                .overlays([.polyline(Places.cbdRoute, id: "cbd", color: .blue, lineWidth: 6),
                           .circle(center: Places.kicc, radius: 1_200, id: "cbd-zone", color: .purple)])
                .controls([.fitAll, .pitch])
        }
    }
}

// MARK: - MapLibre

private struct LibrePlaces: View {
    @State private var selected: String? = "karura"

    var body: some View {
        KitoLibreMapView(pins: Places.nairobiSpots, selection: $selected) { pin in
            KitoMapPinCard(pin: pin, detail: "OpenStreetMap · no API key")
        }
        .controls(.all)
    }
}

private struct LibreStyles: View {
    @State private var style = KitoLibreStyle.positron

    var body: some View {
        KitoLibreMapView(pins: Places.stays, style: style)
            .controls([.pitch])
            .overlay(alignment: .bottom) {
                FloatingPicker(selection: $style, options: [.liberty, .bright, .positron, .dark, .demo]) { $0.title }
                    .padding(.bottom, 18)
            }
    }
}

private struct CoastTrip: View {
    @State private var selected: String? = "diani"

    var body: some View {
        KitoLibreMapView(pins: Places.coast, selection: $selected, style: .liberty) { pin in
            KitoMapPinCard(pin: pin)
        }
        .overlays([
            .polyline(Places.ferry, id: "ferry", color: .blue, lineWidth: 4, dashed: true),
            .circle(center: Places.coast[3].coordinate, radius: 4_000, id: "reef", color: .teal),
        ])
        .controls([.fitAll, .styleSwitcher])
    }
}

// MARK: - Provider switcher

private struct ProviderSwitcher: View {
    private enum Provider: String, CaseIterable { case apple = "Apple", google = "Google", libre = "MapLibre" }
    @State private var provider = Provider.apple
    @State private var selected: String? = "carnivore"

    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                switch provider {
                case .apple:
                    KitoMapView(pins: Places.nairobiSpots, selection: $selected) { KitoMapPinCard(pin: $0) }
                        .clustering()
                        .controls([.fitAll])
                case .google:
                    GoogleGate {
                        KitoGoogleMapView(pins: Places.nairobiSpots, selection: $selected) { KitoMapPinCard(pin: $0) }
                            .clustering()
                            .controls([.fitAll])
                    }
                case .libre:
                    KitoLibreMapView(pins: Places.nairobiSpots, selection: $selected) { KitoMapPinCard(pin: $0) }
                        .clustering()
                        .controls([.fitAll])
                }
            }
            .id(provider)
            .transition(.opacity)

            Picker("Provider", selection: $provider) {
                ForEach(Provider.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 270)
            .padding(6)
            .background(.regularMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            .padding(12)
        }
        .animation(.easeInOut(duration: 0.25), value: provider)
    }
}

// MARK: - Catalogue

enum MapsSamples {
    private static let apple = KitSection("Apple Maps", symbol: "map.fill", [
        KitSample("Places with cards", "Tap a pin or swipe a card; the other follows.", code: """
        KitoMapView(pins: places, selection: $selected) { pin in
            KitoMapPinCard(pin: pin, detail: "Open until 23:00")
        }
        .controls(.all)
        """) { ModalStage { PlacesWithCards() } },
        KitSample("Map styles", "Standard, muted, satellite and hybrid.", code: """
        KitoMapView(pins: places, style: .muted)   // .standard, .muted, .imagery, .hybrid
        """) { ModalStage { AppleStyles() } },
        KitSample("3D city", "Starts tilted over the CBD with realistic elevation.", code: """
        KitoMapView(pins: pins, camera: .center(kicc, zoom: 16.5))
            .startsIn3D()
            .controls([.pitch, .styleSwitcher])
        """) { ModalStage { CityIn3D() } },
        KitSample("Near me", "The blue dot and a locate button.", code: """
        KitoMapView(pins: places)
            .showsUserLocation()
            .controls([.userLocation, .fitAll])
        """) { ModalStage { NearMe() } },
        KitSample("Static snapshots", "Map images for lists, redrawn for dark mode.", code: """
        KitoMapSnapshot(center: pin.coordinate, meters: 1_400, pins: [pin])
            .frame(height: 120)
        """) { SnapshotList() },
    ])

    private static let pins = KitSection("Pins", symbol: "mappin.and.ellipse", [
        KitSample("Pin styles", "Six styles; tap one to see it selected.", code: """
        KitoMapPin(id: "java", coordinate: java, title: "Java House",
                   style: .icon("cup.and.saucer.fill"), tint: .brown, badge: "4.6")
        // .dot, .icon(_), .bubble(_), .avatar(initials:imageURL:), .teardrop, .pulse
        """) { PinStyles() },
        KitSample("Price bubbles", "Stays by price; the selected one fills in.", code: """
        KitoMapPin(id: "karen", coordinate: karen, title: "Karen cottage",
                   style: .bubble("KSh 9,300"), badge: "4.9")
        """) { ModalStage { PriceBubbles() } },
        KitSample("Friends", "Avatar pins with a card per friend.", code: """
        KitoMapPin(id: "amina", coordinate: kicc, title: "Amina",
                   style: .avatar(initials: "AW"), tint: .pink)
        """) { ModalStage { FriendsNearby() } },
        KitSample("Live riders", "Pulsing pins with a heading cone.", code: """
        KitoMapPin(id: "otieno", coordinate: here, title: "Otieno",
                   style: .pulse, tint: .green, systemImage: "bicycle", heading: 45)
        """) { ModalStage { LivePulse() } },
    ])

    private static let clusters = KitSection("Clusters & cards", symbol: "circle.hexagongrid.fill", [
        KitSample("Clusters that split", "140 agents merge into counts and fly apart as you zoom.", code: """
        KitoMapView(pins: agents).clustering()
        """) { ModalStage { SplittingClusters() } },
        KitSample("Synced carousel", "Clusters plus cards; the selected pin never hides in a cluster.", code: """
        KitoMapView(pins: stays, selection: $selected) { pin in
            KitoMapPinCard(pin: pin, detail: "Free cancellation")
        }
        .clustering()
        """) { ModalStage { SyncedCarousel() } },
        KitSample("Custom cards", "Any view as the card.", code: """
        KitoMapView(pins: stays, selection: $selected) { pin in
            StayCard(pin: pin)
        }
        """) { ModalStage { CustomCards() } },
        KitSample("Fly between cities", "A controller moves the camera from outside.", code: """
        @State private var map = KitoMapController()

        KitoMapView(pins: pins, controller: map)
        Button("Mombasa") { map.move(to: .fit(mombasa.map(\\.coordinate))) }
        """) { ModalStage { CityHopper() } },
    ])

    private static let routes = KitSection("Routes & tracking", symbol: "point.topleft.down.to.point.bottomright.curvepath.fill", [
        KitSample("Directions", "Apple Maps route, distance and time.", code: """
        let route = try await KitoRouteService.route(from: westlands, to: kicc)
        KitoMapView(pins: [start, end]).overlays([.route(route, color: .blue)])
        Text("\\(route.formattedTravelTime) · \\(route.formattedDistance)")
        """) { ModalStage { Directions() } },
        KitSample("Delivery tracking", "The rider glides along the route with a live countdown.", code: """
        @State private var rider = KitoLiveTracker(route: path, duration: 45)

        KitoMapView(pins: [shop, home, rider.pin])
            .overlays(rider.overlays(color: .green))
            .onAppear { rider.start() }
        Text(rider.formattedCountdown)
        """) { ModalStage { DeliveryTracking() } },
        KitSample("Delivery zone", "A radius you can drag; pins inside turn green.", code: """
        KitoMapView(pins: pins)
            .overlays([.circle(center: kitchen, radius: radius, color: .orange)])
        let inside = KitoMapGeometry.distance(from: kitchen, to: home) <= radius
        """) { ModalStage { DeliveryZone() } },
        KitSample("Place search", "Live Apple Maps suggestions; pick one to drop a pin.", code: """
        KitoPlaceSearchField("Search Nairobi", near: region) { place in
            pins.append(place.pin(style: .teardrop, tint: .red))
        }
        """) { ModalStage { SearchPlaces() } },
        KitSample("Location picker", "Drag the map under the pin; the address follows.", code: """
        KitoLocationPicker(initialCoordinate: kicc, title: "Deliver to") { picked in
            order.dropOff = picked
        }
        """) { ModalStage { PickLocation() } },
        KitSample("Encoded polyline", "A trail decoded from the format routing APIs return.", code: """
        let trail = KitoPolyline.decode(encoded) ?? []
        KitoMapView(pins: pins, style: .imagery)
            .overlays([.polyline(trail, color: .yellow, dashed: true)])
        """) { ModalStage { EncodedTrail() } },
    ])

    private static let google = KitSection("Google Maps", symbol: "globe.americas.fill", [
        KitSample("Google Maps", "The same pins and cards on Google. Needs an API key.", code: """
        KitoGoogleMaps.provideAPIKey(key)          // once, at launch

        KitoGoogleMapView(pins: places, selection: $selected) { pin in
            KitoMapPinCard(pin: pin)
        }
        """) { ModalStage { GooglePlaces() } },
        KitSample("Google styles", "Standard, muted, dark, satellite and terrain.", code: """
        KitoGoogleMapView(pins: stays, style: .dark)   // .automatic follows dark mode
        """) { ModalStage { GoogleStyles() } },
        KitSample("Google clusters & routes", "Clusters, a route and a zone on Google.", code: """
        KitoGoogleMapView(pins: agents)
            .clustering()
            .overlays([.polyline(route, color: .blue), .circle(center: kicc, radius: 1_200)])
        """) { ModalStage { GoogleClustersAndRoute() } },
    ])

    private static let libre = KitSection("MapLibre (free)", symbol: "leaf.fill", [
        KitSample("OpenStreetMap, no key", "Free OpenFreeMap tiles with the credit line.", code: """
        KitoLibreMapView(pins: places, selection: $selected) { pin in
            KitoMapPinCard(pin: pin)
        }
        """) { ModalStage { LibrePlaces() } },
        KitSample("Free styles", "Liberty, Bright, Positron, Dark and the demo tiles.", code: """
        KitoLibreMapView(pins: stays, style: .positron)   // or .custom(url, attribution:)
        """) { ModalStage { LibreStyles() } },
        KitSample("Coast trip", "Mombasa to Zanzibar with a ferry line and a reef zone.", code: """
        KitoLibreMapView(pins: coast, selection: $selected) { KitoMapPinCard(pin: $0) }
            .overlays([.polyline(ferry, color: .blue, dashed: true),
                       .circle(center: diani, radius: 4_000, color: .teal)])
        """) { ModalStage { CoastTrip() } },
    ])

    private static let switcher = KitSection("Provider switcher", symbol: "arrow.triangle.2.circlepath", [
        KitSample("Same pins, three maps", "Switch Apple, Google and MapLibre; the selection stays.", code: """
        switch provider {
        case .apple:  KitoMapView(pins: pins, selection: $selected) { KitoMapPinCard(pin: $0) }
        case .google: KitoGoogleMapView(pins: pins, selection: $selected) { KitoMapPinCard(pin: $0) }
        case .libre:  KitoLibreMapView(pins: pins, selection: $selected) { KitoMapPinCard(pin: $0) }
        }
        """) { ModalStage { ProviderSwitcher() } },
    ])

    static let sections: [KitSection] = [apple, pins, clusters, routes, google, libre, switcher]
}

struct MapsGallery: View {
    static var count: Int { KitGallery.count(MapsSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Maps",
            sections: MapsSamples.sections,
            footnote: "Requires `import KitoMaps` (Apple), `KitoMapsGoogle` or `KitoMapsLibre`.",
            searchHint: "Try “cluster”, “price”, “delivery”, “route”, “Google” or “free”."
        )
    }
}
