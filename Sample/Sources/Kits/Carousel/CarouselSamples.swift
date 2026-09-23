//
//  CarouselSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoCarousel

// MARK: - Offline art

/// Hand-drawn East African scenes: gradients and shapes, no images needed.
private enum SceneKind: CaseIterable {
    case savanna, beach, kilimanjaro, skyline, flamingo, spice, forest, dhow
}

private struct SceneArt: View {
    let kind: SceneKind

    var body: some View {
        ZStack {
            switch kind {
            case .savanna: SavannaScene()
            case .beach: BeachScene()
            case .kilimanjaro: MountainScene()
            case .skyline: SkylineScene()
            case .flamingo: LakeScene()
            case .spice: SpiceScene()
            case .forest: ForestScene()
            case .dhow: DhowScene()
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

private struct SavannaScene: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack {
                LinearGradient(colors: [Color(red: 0.36, green: 0.17, blue: 0.42), Color(red: 0.93, green: 0.42, blue: 0.24), Color(red: 1.0, green: 0.78, blue: 0.38)],
                               startPoint: .top, endPoint: .bottom)
                Circle()
                    .fill(RadialGradient(colors: [Color(red: 1, green: 0.93, blue: 0.62), Color(red: 1, green: 0.62, blue: 0.25).opacity(0)], center: .center, startRadius: 0, endRadius: w * 0.3))
                    .frame(width: w * 0.6)
                    .position(x: w * 0.62, y: h * 0.62)
                Circle().fill(Color(red: 1, green: 0.9, blue: 0.6)).frame(width: w * 0.2).position(x: w * 0.62, y: h * 0.62)
                HillShape(phase: 0.2).fill(Color(red: 0.36, green: 0.16, blue: 0.14).opacity(0.7)).frame(height: h * 0.34).frame(maxHeight: .infinity, alignment: .bottom)
                AcaciaShape().fill(Color(red: 0.18, green: 0.08, blue: 0.08)).frame(width: w * 0.46, height: h * 0.42).position(x: w * 0.26, y: h * 0.62)
                AcaciaShape().fill(Color(red: 0.18, green: 0.08, blue: 0.08)).frame(width: w * 0.22, height: h * 0.2).position(x: w * 0.84, y: h * 0.72)
                HillShape(phase: 0.7).fill(Color(red: 0.2, green: 0.09, blue: 0.08)).frame(height: h * 0.2).frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

private struct BeachScene: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack {
                LinearGradient(colors: [Color(red: 0.36, green: 0.74, blue: 0.96), Color(red: 0.7, green: 0.91, blue: 0.98)], startPoint: .top, endPoint: .center)
                Circle().fill(.white.opacity(0.9)).frame(width: w * 0.14).position(x: w * 0.8, y: h * 0.2).blur(radius: 1)
                WaveShape(amplitude: 6, frequency: 2.5, phase: 0).fill(Color(red: 0.0, green: 0.62, blue: 0.72)).frame(height: h * 0.58).frame(maxHeight: .infinity, alignment: .bottom)
                WaveShape(amplitude: 8, frequency: 2, phase: 1.2).fill(Color(red: 0.2, green: 0.83, blue: 0.82)).frame(height: h * 0.44).frame(maxHeight: .infinity, alignment: .bottom)
                WaveShape(amplitude: 10, frequency: 1.4, phase: 2).fill(Color(red: 0.98, green: 0.9, blue: 0.74)).frame(height: h * 0.22).frame(maxHeight: .infinity, alignment: .bottom)
                PalmShape().fill(Color(red: 0.08, green: 0.32, blue: 0.26)).frame(width: w * 0.36, height: h * 0.62).position(x: w * 0.16, y: h * 0.5)
            }
        }
    }
}

private struct MountainScene: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack {
                LinearGradient(colors: [Color(red: 0.13, green: 0.3, blue: 0.62), Color(red: 0.55, green: 0.74, blue: 0.93)], startPoint: .top, endPoint: .bottom)
                MountainShape().fill(LinearGradient(colors: [Color(red: 0.36, green: 0.4, blue: 0.55), Color(red: 0.2, green: 0.24, blue: 0.36)], startPoint: .top, endPoint: .bottom))
                    .frame(width: w * 1.1, height: h * 0.55).position(x: w * 0.5, y: h * 0.72)
                MountainShape().fill(.white).frame(width: w * 0.3, height: h * 0.16).position(x: w * 0.5, y: h * 0.52)
                    .mask(MountainShape().frame(width: w * 1.1, height: h * 0.55).position(x: w * 0.5, y: h * 0.72))
                HillShape(phase: 0.4).fill(Color(red: 0.2, green: 0.42, blue: 0.24)).frame(height: h * 0.2).frame(maxHeight: .infinity, alignment: .bottom)
                AcaciaShape().fill(Color(red: 0.08, green: 0.2, blue: 0.1)).frame(width: w * 0.3, height: h * 0.26).position(x: w * 0.78, y: h * 0.8)
            }
        }
    }
}

private struct SkylineScene: View {
    private let towers: [(CGFloat, CGFloat)] = [(0.08, 0.3), (0.07, 0.46), (0.1, 0.38), (0.06, 0.62), (0.09, 0.5), (0.05, 0.34), (0.1, 0.56), (0.07, 0.42), (0.08, 0.28), (0.06, 0.48), (0.09, 0.36), (0.07, 0.3)]

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: [Color(red: 0.05, green: 0.06, blue: 0.2), Color(red: 0.38, green: 0.18, blue: 0.45), Color(red: 0.95, green: 0.5, blue: 0.36)], startPoint: .top, endPoint: .bottom)
                HStack(alignment: .bottom, spacing: w * 0.006) {
                    ForEach(Array(towers.enumerated()), id: \.offset) { index, tower in
                        Rectangle()
                            .fill(Color(red: 0.07, green: 0.07, blue: 0.16))
                            .overlay {
                                VStack(spacing: 5) {
                                    ForEach(0..<Int(tower.1 * 16), id: \.self) { row in
                                        Rectangle().fill(Color(red: 1, green: 0.84, blue: 0.5).opacity((row + index).isMultiple(of: 3) ? 0.85 : 0.18)).frame(height: 2)
                                    }
                                }
                                .padding(.horizontal, 4)
                                .padding(.top, 6)
                            }
                            .frame(width: w * tower.0, height: h * tower.1)
                    }
                }
            }
        }
    }
}

private struct LakeScene: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack {
                LinearGradient(colors: [Color(red: 0.98, green: 0.78, blue: 0.82), Color(red: 0.99, green: 0.9, blue: 0.86)], startPoint: .top, endPoint: .center)
                HillShape(phase: 0.1).fill(Color(red: 0.55, green: 0.5, blue: 0.62).opacity(0.6)).frame(height: h * 0.6).frame(maxHeight: .infinity, alignment: .bottom)
                Rectangle().fill(LinearGradient(colors: [Color(red: 0.93, green: 0.6, blue: 0.7), Color(red: 0.72, green: 0.52, blue: 0.7)], startPoint: .top, endPoint: .bottom)).frame(height: h * 0.4).frame(maxHeight: .infinity, alignment: .bottom)
                ForEach(0..<7, id: \.self) { index in
                    Image(systemName: "bird.fill")
                        .font(.system(size: w * (0.06 + CGFloat(index % 3) * 0.015)))
                        .foregroundStyle(Color(red: 0.95, green: 0.36, blue: 0.5))
                        .position(x: w * (0.12 + CGFloat(index) * 0.12), y: h * (0.62 + CGFloat(index % 2) * 0.06))
                }
            }
        }
    }
}

private struct SpiceScene: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack {
                LinearGradient(colors: [Color(red: 0.62, green: 0.2, blue: 0.1), Color(red: 0.95, green: 0.6, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill([Color(red: 0.95, green: 0.8, blue: 0.2), Color(red: 0.8, green: 0.3, blue: 0.1), Color(red: 0.5, green: 0.25, blue: 0.1), Color(red: 0.98, green: 0.5, blue: 0.2), Color(red: 0.4, green: 0.5, blue: 0.15)][index])
                        .frame(width: w * 0.3)
                        .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 3))
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 6)
                        .position(x: w * (0.18 + CGFloat(index) * 0.16), y: h * (index.isMultiple(of: 2) ? 0.68 : 0.8))
                }
            }
        }
    }
}

private struct ForestScene: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack {
                LinearGradient(colors: [Color(red: 0.62, green: 0.84, blue: 0.62), Color(red: 0.1, green: 0.36, blue: 0.22)], startPoint: .top, endPoint: .bottom)
                ForEach(0..<9, id: \.self) { index in
                    Image(systemName: "tree.fill")
                        .font(.system(size: w * (0.16 + CGFloat(index % 3) * 0.05)))
                        .foregroundStyle(Color(red: 0.05, green: 0.25 + Double(index % 3) * 0.06, blue: 0.14))
                        .position(x: w * (0.05 + CGFloat(index) * 0.115), y: h * (0.66 + CGFloat(index % 2) * 0.1))
                }
                Image(systemName: "hare.fill").font(.system(size: w * 0.08)).foregroundStyle(.white.opacity(0.8)).position(x: w * 0.7, y: h * 0.88)
            }
        }
    }
}

private struct DhowScene: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack {
                LinearGradient(colors: [Color(red: 0.99, green: 0.55, blue: 0.35), Color(red: 0.99, green: 0.82, blue: 0.55)], startPoint: .top, endPoint: .center)
                Circle().fill(Color(red: 1, green: 0.95, blue: 0.75)).frame(width: w * 0.26).position(x: w * 0.3, y: h * 0.5)
                WaveShape(amplitude: 4, frequency: 3, phase: 0.5).fill(Color(red: 0.2, green: 0.3, blue: 0.5)).frame(height: h * 0.45).frame(maxHeight: .infinity, alignment: .bottom)
                SailShape().fill(Color(red: 0.98, green: 0.94, blue: 0.86)).frame(width: w * 0.28, height: h * 0.34).position(x: w * 0.64, y: h * 0.42)
                Capsule().fill(Color(red: 0.3, green: 0.16, blue: 0.1)).frame(width: w * 0.36, height: h * 0.05).position(x: w * 0.62, y: h * 0.6)
            }
        }
    }
}

private struct HillShape: Shape {
    var phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.height * (0.4 + phase * 0.2)))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.height * (0.5 - phase * 0.2)),
                      control1: CGPoint(x: rect.width * 0.3, y: rect.height * (0.0 + phase * 0.3)),
                      control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.8))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct WaveShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        for step in stride(from: 0, through: rect.width, by: 4) {
            let y = amplitude + sin(step / rect.width * .pi * 2 * frequency + phase) * amplitude
            path.addLine(to: CGPoint(x: step, y: y))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct AcaciaShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let trunk = rect.width * 0.05
        path.addRect(CGRect(x: rect.midX - trunk / 2, y: rect.height * 0.3, width: trunk, height: rect.height * 0.7))
        path.move(to: CGPoint(x: rect.midX, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.width * 0.28, y: rect.height * 0.2))
        path.addLine(to: CGPoint(x: rect.width * 0.32, y: rect.height * 0.2))
        path.addLine(to: CGPoint(x: rect.midX + trunk, y: rect.height * 0.5))
        path.closeSubpath()
        path.addEllipse(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height * 0.26))
        return path
    }
}

private struct PalmShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.2, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0.2), control: CGPoint(x: rect.width * 0.5, y: rect.height * 0.7))
        path.addLine(to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.22))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.3, y: rect.maxY), control: CGPoint(x: rect.width * 0.6, y: rect.height * 0.7))
        path.closeSubpath()
        for angle in stride(from: -150.0, through: 10.0, by: 32.0) {
            let radians = angle * .pi / 180
            let tip = CGPoint(x: rect.width * 0.57 + cos(radians) * rect.width * 0.55, y: rect.height * 0.2 + sin(radians) * rect.height * 0.2 + rect.height * 0.08)
            path.move(to: CGPoint(x: rect.width * 0.57, y: rect.height * 0.2))
            path.addQuadCurve(to: tip, control: CGPoint(x: (rect.width * 0.57 + tip.x) / 2, y: min(tip.y, rect.height * 0.2) - rect.height * 0.08))
            path.addQuadCurve(to: CGPoint(x: rect.width * 0.57, y: rect.height * 0.22), control: CGPoint(x: (rect.width * 0.57 + tip.x) / 2, y: min(tip.y, rect.height * 0.2) - rect.height * 0.02))
        }
        return path
    }
}

private struct MountainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.width * 0.38, y: rect.height * 0.08))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.62, y: rect.height * 0.08), control: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct SailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.1, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.9, y: 0), control: CGPoint(x: rect.width * 0.2, y: rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Initials on a gradient disc.
private struct InitialsAvatar: View {
    let initials: String
    let colors: [Color]

    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Text(initials).font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(.white).minimumScaleFactor(0.4).padding(4)
        }
    }
}

// MARK: - Content

private struct Place: Identifiable {
    let id = UUID()
    let name: String
    let region: String
    let price: String
    let rating: Double
    let scene: SceneKind

    static let lodges: [Place] = [
        Place(name: "Mara Serena Camp", region: "Maasai Mara", price: "KSh 32,000", rating: 4.9, scene: .savanna),
        Place(name: "Kibo Slopes Lodge", region: "Amboseli", price: "KSh 24,500", rating: 4.8, scene: .kilimanjaro),
        Place(name: "Flamingo Shores", region: "Lake Nakuru", price: "KSh 18,900", rating: 4.7, scene: .flamingo),
        Place(name: "Karura Treehouse", region: "Nairobi", price: "KSh 12,000", rating: 4.6, scene: .forest),
        Place(name: "Nungwi Reef Villa", region: "Zanzibar", price: "KSh 28,000", rating: 4.9, scene: .beach),
    ]

    static let coast: [Place] = [
        Place(name: "Nungwi", region: "Zanzibar", price: "from KSh 9,800", rating: 4.9, scene: .beach),
        Place(name: "Lamu Old Town", region: "Lamu", price: "from KSh 7,400", rating: 4.8, scene: .dhow),
        Place(name: "Stone Town", region: "Zanzibar", price: "from KSh 6,900", rating: 4.7, scene: .spice),
        Place(name: "Diani", region: "Kwale", price: "from KSh 8,200", rating: 4.8, scene: .beach),
        Place(name: "Watamu", region: "Kilifi", price: "from KSh 7,900", rating: 4.6, scene: .dhow),
    ]
}

private struct PlaceCard: View {
    let place: Place
    var height: CGFloat = 260

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SceneArt(kind: place.scene)
            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                Text(place.region.uppercased()).font(.caption2.weight(.bold)).tracking(1.2).foregroundStyle(.white.opacity(0.8))
                Text(place.name).font(.title3.bold()).foregroundStyle(.white)
                Text("\(place.price) · night").font(.footnote.weight(.medium)).foregroundStyle(.white.opacity(0.85))
            }
            .padding(18)
        }
        .overlay(alignment: .topTrailing) {
            Label(String(format: "%.1f", place.rating), systemImage: "star.fill")
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(12)
        }
        .frame(height: height)
        .accessibilityElement(children: .combine)
    }
}

private struct Dish: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let spot: String
    let price: String
    let blurb: String
    let colors: [Color]

    static let nairobi: [Dish] = [
        Dish(name: "Nyama Choma", emoji: "🍖", spot: "Kenyatta Market", price: "KSh 950", blurb: "Goat ribs slow-roasted over charcoal, kachumbari on the side.", colors: [Color(red: 0.62, green: 0.18, blue: 0.1), Color(red: 0.96, green: 0.52, blue: 0.2)]),
        Dish(name: "Pilau", emoji: "🍛", spot: "Mama Oliech", price: "KSh 450", blurb: "Spiced rice with beef, cardamom and a squeeze of lime.", colors: [Color(red: 0.55, green: 0.32, blue: 0.1), Color(red: 0.95, green: 0.72, blue: 0.3)]),
        Dish(name: "Chapati & Beans", emoji: "🫓", spot: "River Road", price: "KSh 200", blurb: "Flaky layered chapati, coconut beans for dipping.", colors: [Color(red: 0.8, green: 0.55, blue: 0.2), Color(red: 1.0, green: 0.86, blue: 0.5)]),
        Dish(name: "Mandazi", emoji: "🍩", spot: "Westlands", price: "KSh 60", blurb: "Warm coconut doughnuts, best with chai at 7am.", colors: [Color(red: 0.72, green: 0.4, blue: 0.2), Color(red: 1.0, green: 0.78, blue: 0.55)]),
        Dish(name: "Samosa", emoji: "🥟", spot: "Kilimani", price: "KSh 80", blurb: "Crisp triangles of spiced minced beef and onion.", colors: [Color(red: 0.6, green: 0.3, blue: 0.08), Color(red: 0.98, green: 0.66, blue: 0.24)]),
        Dish(name: "Mutura", emoji: "🌭", spot: "Kawangware", price: "KSh 100", blurb: "Nairobi's street sausage, grilled at dusk.", colors: [Color(red: 0.4, green: 0.1, blue: 0.1), Color(red: 0.86, green: 0.3, blue: 0.24)]),
        Dish(name: "Viazi Karai", emoji: "🥔", spot: "Mombasa Road", price: "KSh 50", blurb: "Battered potatoes with a pinch of pilipili.", colors: [Color(red: 0.7, green: 0.5, blue: 0.1), Color(red: 1.0, green: 0.86, blue: 0.32)]),
        Dish(name: "Mahamri & Chai", emoji: "☕️", spot: "Eastleigh", price: "KSh 120", blurb: "Cardamom mahamri and sweet spiced tea.", colors: [Color(red: 0.4, green: 0.24, blue: 0.14), Color(red: 0.86, green: 0.62, blue: 0.4)]),
    ]
}

private struct DishCard: View {
    let dish: Dish

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: dish.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(.white.opacity(0.12)).frame(width: 300).offset(x: 160, y: -220)
            Text(dish.emoji).font(.system(size: 130)).shadow(color: .black.opacity(0.3), radius: 18, y: 12).frame(maxWidth: .infinity, maxHeight: .infinity).offset(y: -40)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(dish.name).font(.title2.bold())
                    Spacer()
                    Text(dish.price).font(.subheadline.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 5).background(.white.opacity(0.2), in: Capsule())
                }
                Label(dish.spot, systemImage: "mappin.and.ellipse").font(.subheadline.weight(.medium)).opacity(0.9)
                Text(dish.blurb).font(.footnote).opacity(0.85).lineLimit(2)
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(LinearGradient(colors: [.clear, .black.opacity(0.35)], startPoint: .top, endPoint: .bottom))
        }
        .accessibilityElement(children: .combine)
    }
}

private struct StoryFrame {
    let scene: SceneKind
    let caption: String
    let time: String
}

private struct StoryPerson: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let colors: [Color]
    var seen: Bool
    var live: Bool
    let frames: [StoryFrame]

    static let friends: [StoryPerson] = [
        StoryPerson(name: "Wanjiru", initials: "WK", colors: [.orange, .pink], seen: false, live: true, frames: [
            StoryFrame(scene: .savanna, caption: "Sunrise game drive, Maasai Mara 🦁", time: "Live"),
            StoryFrame(scene: .kilimanjaro, caption: "Kili peeking over Amboseli", time: "1h"),
        ]),
        person("Baraka", "BO", [.teal, .blue], [
            StoryFrame(scene: .beach, caption: "Nungwi, low tide, no notes", time: "2h"),
            StoryFrame(scene: .dhow, caption: "Dhow sunset cruise ⛵️", time: "2h"),
            StoryFrame(scene: .spice, caption: "Spice farm, Stone Town", time: "3h"),
        ]),
        person("Achieng", "AO", [.purple, .indigo], [
            StoryFrame(scene: .skyline, caption: "Nairobi from the rooftop 🌆", time: "4h"),
        ]),
        person("Kamau", "JK", [.green, .mint], [
            StoryFrame(scene: .forest, caption: "Karura forest run, 10k done", time: "5h"),
            StoryFrame(scene: .flamingo, caption: "Flamingos at Nakuru 🦩", time: "6h"),
        ]),
        person("Zawadi", "ZM", [.red, .orange], [
            StoryFrame(scene: .spice, caption: "Pilau spice run at the market", time: "8h"),
        ]),
        person("Otieno", "OD", [.cyan, .teal], [
            StoryFrame(scene: .dhow, caption: "Lamu, where time slows down", time: "9h"),
        ]),
    ]
}

private extension StoryPerson {
    static func person(_ name: String, _ initials: String, _ colors: [Color], _ frames: [StoryFrame]) -> StoryPerson {
        StoryPerson(name: name, initials: initials, colors: colors, seen: false, live: false, frames: frames)
    }
}

private struct StoryPage: View {
    let frame: StoryFrame

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SceneArt(kind: frame.scene)
            Text(frame.caption)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 8, y: 2)
                .padding(.horizontal, 22)
                .padding(.bottom, 120)
        }
    }
}

// MARK: - Carousel samples

private struct LodgeCarouselSample: View {
    var effect: KitoCarouselEffect = .scale
    var indicator: KitoPageIndicatorStyle = .worm
    var loops = false
    var autoPlay: TimeInterval?
    var places: [Place] = Place.lodges
    var height: CGFloat = 260
    @State private var page = 0
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 14) {
            KitoCarousel(places, selection: $page, effect: effect, peek: 36, loops: loops, autoPlay: autoPlay, autoPlayProgress: $progress) { place in
                PlaceCard(place: place, height: height)
            }
            .frame(height: height)
            KitoPageIndicator(count: places.count, selection: $page, style: indicator, progress: progress)
            Text(places[page].name).font(.headline).contentTransition(.opacity).animation(.easeInOut, value: page)
        }
        .padding(.vertical, 24)
    }
}

private struct Album: Identifiable {
    let id = UUID()
    let title: String
    let genre: String
    let colors: [Color]
    let symbol: String

    static let all: [Album] = [
        Album(title: "Benga Nights", genre: "Benga", colors: [.orange, .red], symbol: "guitars.fill"),
        Album(title: "Taarab Tides", genre: "Taarab", colors: [.teal, .blue], symbol: "music.quarternote.3"),
        Album(title: "Gengetone Vol. 2", genre: "Gengetone", colors: [.pink, .purple], symbol: "speaker.wave.3.fill"),
        Album(title: "Bongo Flava", genre: "Bongo Flava", colors: [.yellow, .orange], symbol: "headphones"),
        Album(title: "Rhumba Sunday", genre: "Rhumba", colors: [.indigo, .mint], symbol: "music.mic"),
        Album(title: "Ohangla Fire", genre: "Ohangla", colors: [.red, .purple], symbol: "waveform"),
    ]
}

private struct CoverFlowSample: View {
    @State private var page = 2

    var body: some View {
        VStack(spacing: 18) {
            KitoCarousel(Album.all, selection: $page, effect: .coverFlow, spacing: 4, peek: 70, loops: true, cornerRadius: 18) { album in
                ZStack {
                    LinearGradient(colors: album.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: album.symbol).font(.system(size: 64, weight: .bold)).foregroundStyle(.white.opacity(0.9))
                    Text(album.genre.uppercased()).font(.caption.weight(.heavy)).tracking(2).foregroundStyle(.white.opacity(0.8))
                        .frame(maxHeight: .infinity, alignment: .bottom).padding(.bottom, 16)
                }
                .aspectRatio(1, contentMode: .fit)
            }
            .frame(height: 220)
            VStack(spacing: 4) {
                Text(Album.all[page].title).font(.title3.bold())
                Text(Album.all[page].genre).font(.subheadline).foregroundStyle(.secondary)
            }
            .contentTransition(.opacity)
            .animation(.easeInOut, value: page)
            KitoPageIndicator(count: Album.all.count, selection: $page, style: .dots)
        }
        .padding(.vertical, 24)
    }
}

private struct Proverb: Identifiable {
    let id = UUID()
    let swahili: String
    let english: String
    let colors: [Color]

    static let all: [Proverb] = [
        Proverb(swahili: "Haba na haba hujaza kibaba.", english: "Little by little fills the measure.", colors: [.orange, .pink]),
        Proverb(swahili: "Pole pole ndio mwendo.", english: "Slowly, slowly is the way to go.", colors: [.teal, .indigo]),
        Proverb(swahili: "Umoja ni nguvu.", english: "Unity is strength.", colors: [.green, .teal]),
        Proverb(swahili: "Asiyefunzwa na mamaye hufunzwa na ulimwengu.", english: "Who isn't taught by their mother is taught by the world.", colors: [.purple, .pink]),
    ]
}

private struct ProverbCard: View {
    let proverb: Proverb

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "quote.opening").font(.title.bold()).foregroundStyle(.white.opacity(0.6))
            Text(proverb.swahili).font(.title2.bold()).foregroundStyle(.white)
            Text(proverb.english).font(.subheadline).foregroundStyle(.white.opacity(0.85))
            Spacer()
            Text("Methali ya Kiswahili").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.7))
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 240)
        .background(LinearGradient(colors: proverb.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

private struct ProverbSample: View {
    let effect: KitoCarouselEffect
    @State private var page = 0

    var body: some View {
        VStack(spacing: 14) {
            KitoCarousel(Proverb.all, selection: $page, effect: effect, peek: 40) { ProverbCard(proverb: $0) }
                .frame(height: 240)
            KitoPageIndicator(count: Proverb.all.count, selection: $page, style: .capsule)
        }
        .padding(.vertical, 24)
    }
}

private struct PlaygroundSample: View {
    @State private var effect: KitoCarouselEffect = .coverFlow
    @State private var peek: Double = 36
    @State private var spacing: Double = 12
    @State private var loops = true
    @State private var page = 0

    var body: some View {
        VStack(spacing: 18) {
            KitoCarousel(Place.lodges, selection: $page, effect: effect, spacing: spacing, peek: peek, loops: loops) {
                PlaceCard(place: $0, height: 220)
            }
            .frame(height: 220)
            .id("\(loops)")
            KitoPageIndicator(count: Place.lodges.count, selection: $page, style: .worm)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(KitoCarouselEffect.allCases, id: \.self) { option in
                        Button(option.rawValue) { withAnimation(.snappy) { effect = option } }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(effect == option ? Color.primary : Color.primary.opacity(0.08), in: Capsule())
                            .foregroundStyle(effect == option ? Color(.systemBackground) : .primary)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            VStack(spacing: 10) {
                LabeledContent("Peek \(Int(peek)) pt") { Slider(value: $peek, in: 0...70).frame(width: 180) }
                LabeledContent("Spacing \(Int(spacing)) pt") { Slider(value: $spacing, in: 0...28).frame(width: 180) }
                Toggle("Loop forever", isOn: $loops)
            }
            .font(.subheadline)
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
    }
}

// MARK: - Indicator samples

private struct AllIndicatorsSample: View {
    @State private var page = 2
    @State private var progress: Double = 0.4

    var body: some View {
        VStack(spacing: 22) {
            ForEach(KitoPageIndicatorStyle.allCases, id: \.self) { style in
                VStack(spacing: 6) {
                    KitoPageIndicator(count: 6, selection: $page, style: style, progress: progress, tint: style == .worm ? .orange : nil)
                    Text(".\(style.rawValue)").font(.caption.monospaced()).foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 12) {
                Button { page = max(page - 1, 0) } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                    .background(Color.primary.opacity(0.08), in: Circle())
                Button { page = min(page + 1, 5) } label: { Image(systemName: "chevron.right").frame(width: 44, height: 44) }
                    .background(Color.primary.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
            LabeledContent("Progress") { Slider(value: $progress).frame(width: 180) }.font(.subheadline).padding(.horizontal)
        }
        .padding(.vertical, 24)
    }
}

private struct ScrubSample: View {
    @State private var page = 0

    var body: some View {
        VStack(spacing: 18) {
            KitoCarousel(Place.coast, selection: $page, effect: .parallax, peek: 24) { PlaceCard(place: $0, height: 200) }
                .frame(height: 200)
            KitoPageIndicator(count: Place.coast.count, selection: $page, style: .capsule, dotSize: 12, tint: .teal)
            Text("Drag along the dots to scrub").font(.footnote).foregroundStyle(.secondary)
        }
        .padding(.vertical, 24)
    }
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let scene: SceneKind

    static let all: [OnboardingPage] = [
        OnboardingPage(title: "Karibu Safari", message: "Book lodges across the Mara, Amboseli and Nakuru in a few taps.", scene: .savanna),
        OnboardingPage(title: "Island time", message: "Zanzibar, Lamu and Diani, with ferries and dhows included.", scene: .beach),
        OnboardingPage(title: "Eat like a local", message: "Nyama choma, pilau and mandazi picked by Nairobi foodies.", scene: .spice),
    ]
}

private struct OnboardingScreen: View {
    @State private var page = 0

    var body: some View {
        VStack(spacing: 24) {
            KitoCarousel(OnboardingPage.all, selection: $page, effect: .fade, spacing: 0, peek: 0, cornerRadius: 0) { item in
                VStack(spacing: 24) {
                    SceneArt(kind: item.scene)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                        .padding(.horizontal, 24)
                    VStack(spacing: 10) {
                        Text(item.title).font(.largeTitle.bold())
                        Text(item.message).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 32)
                    }
                }
                .frame(maxHeight: .infinity)
            }
            KitoPageIndicator(count: OnboardingPage.all.count, selection: $page, style: .worm, dotSize: 10)
            Button(page == OnboardingPage.all.count - 1 ? "Get started" : "Next") {
                withAnimation { page = min(page + 1, OnboardingPage.all.count - 1) }
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .padding(.top, 48)
        .background(Color(.systemBackground))
    }
}

// MARK: - Banners & marquees

private struct Deal: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let badge: String
    let emoji: String
    let colors: [Color]

    static let all: [Deal] = [
        Deal(title: "Nyama Choma Friday", detail: "20% off grills at Kenyatta Market", badge: "TONIGHT", emoji: "🍖", colors: [Color(red: 0.62, green: 0.12, blue: 0.1), Color(red: 0.98, green: 0.5, blue: 0.2)]),
        Deal(title: "Zanzibar Long Weekend", detail: "Ferry + 3 nights in Nungwi", badge: "−35%", emoji: "🏝️", colors: [Color(red: 0.0, green: 0.45, blue: 0.62), Color(red: 0.2, green: 0.85, blue: 0.8)]),
        Deal(title: "Mara Migration", detail: "Game drives from KSh 9,999", badge: "JULY", emoji: "🦓", colors: [Color(red: 0.36, green: 0.2, blue: 0.1), Color(red: 0.95, green: 0.7, blue: 0.3)]),
        Deal(title: "Chai & Mandazi", detail: "Free mandazi with any chai before 9", badge: "DAILY", emoji: "☕️", colors: [Color(red: 0.3, green: 0.18, blue: 0.45), Color(red: 0.86, green: 0.45, blue: 0.6)]),
    ]
}

private struct DealBanner: View {
    let deal: Deal

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(colors: deal.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle().fill(.white.opacity(0.12)).frame(width: 240).offset(x: 220, y: -40)
            Circle().fill(.white.opacity(0.08)).frame(width: 160).offset(x: 280, y: 90)
            Text(deal.emoji).font(.system(size: 84)).frame(maxWidth: .infinity, alignment: .trailing).padding(.trailing, 22).shadow(color: .black.opacity(0.25), radius: 10, y: 8)
            VStack(alignment: .leading, spacing: 8) {
                Text(deal.badge).font(.caption2.weight(.heavy)).tracking(1.5).padding(.horizontal, 8).padding(.vertical, 4).background(.white.opacity(0.25), in: Capsule())
                Text(deal.title).font(.title3.bold())
                Text(deal.detail).font(.subheadline).opacity(0.9)
                Text("Book now →").font(.footnote.weight(.bold)).padding(.top, 2)
            }
            .foregroundStyle(.white)
            .padding(20)
            .frame(maxWidth: 220, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct Partner: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String

    static let all: [Partner] = [
        Partner(name: "Savannah Air", symbol: "airplane"),
        Partner(name: "Coast Ferries", symbol: "ferry.fill"),
        Partner(name: "Mara Rovers", symbol: "car.side.fill"),
        Partner(name: "Madaraka Rail", symbol: "tram.fill"),
        Partner(name: "Boda Go", symbol: "bicycle"),
        Partner(name: "Tusker Tours", symbol: "binoculars.fill"),
        Partner(name: "Kilele Hikes", symbol: "mountain.2.fill"),
    ]
}

private struct Headline: Identifiable {
    let id = UUID()
    let text: String
    let symbol: String

    static let all: [Headline] = [
        Headline(text: "Madaraka Express Nairobi → Mombasa departs 08:00", symbol: "tram.fill"),
        Headline(text: "Wildebeest crossing at the Mara River right now", symbol: "binoculars.fill"),
        Headline(text: "Zanzibar ferry: calm seas, 2 h crossing", symbol: "ferry.fill"),
        Headline(text: "Nairobi 24°C, sunny till 5pm", symbol: "sun.max.fill"),
    ]
}

private struct MarqueeSample: View {
    var body: some View {
        VStack(spacing: 18) {
            KitoInfiniteMarquee(Partner.all, speed: 38) { partner in
                Label(partner.name, systemImage: partner.symbol)
                    .font(.headline)
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    .background(.thinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08)))
            }
            KitoInfiniteMarquee(Partner.all.reversed(), speed: 26, direction: .trailing) { partner in
                Image(systemName: partner.symbol)
                    .font(.title2)
                    .frame(width: 56, height: 56)
                    .background(LinearGradient(colors: [.orange.opacity(0.25), .pink.opacity(0.25)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            Text("Press and hold to pause").font(.footnote).foregroundStyle(.secondary)
        }
        .padding(.vertical, 24)
    }
}

private struct TickerSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Circle().fill(.red).frame(width: 8, height: 8)
                Text("TRAVEL LIVE").font(.caption.weight(.heavy)).tracking(1.2)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            KitoInfiniteMarquee(Headline.all, speed: 55, spacing: 22, tint: .orange) { headline in
                Label(headline.text, systemImage: headline.symbol).font(.subheadline.weight(.medium))
            }
            .padding(.vertical, 12)
            .background(Color.primary.opacity(0.05))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Color.primary.opacity(0.08)))
        .padding(24)
    }
}

// MARK: - Deck & stack samples

private struct DeckSample: View {
    @State private var liked: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            KitoCardDeck(Dish.nairobi, likeLabel: "YUM", nopeLabel: "PASS", superLikeLabel: "CRAVE") { dish in
                DishCard(dish: dish)
            } onSwipe: { dish, direction in
                if direction != .left { withAnimation { liked.insert(dish.emoji, at: 0) } }
            }
            .frame(height: 540)
            HStack(spacing: 4) {
                Text("Craving:").font(.subheadline.weight(.semibold))
                Text(liked.isEmpty ? "swipe right on something" : liked.prefix(8).joined(separator: " "))
                    .font(.subheadline).foregroundStyle(.secondary)
                    .contentTransition(.opacity)
            }
        }
        .padding(20)
    }
}

private struct ControlledDeckSample: View {
    @State private var deck = KitoCardDeckController()
    @State private var last = "Swipe, or use the buttons"

    var body: some View {
        VStack(spacing: 18) {
            KitoCardDeck(Place.lodges, controller: deck, allowsSuperLike: false, showsControls: false) { place in
                PlaceCard(place: place, height: 420)
            } onSwipe: { place, direction in
                last = direction == .right ? "Saved \(place.name)" : "Skipped \(place.name)"
            }
            .frame(height: 420)
            Text(last).font(.subheadline.weight(.medium)).contentTransition(.opacity).animation(.easeInOut, value: last)
            HStack(spacing: 12) {
                Button { deck.undo() } label: { Label("Undo", systemImage: "arrow.uturn.backward") }
                    .disabled(!deck.canUndo)
                Button { deck.swipe(.left) } label: { Label("Skip", systemImage: "xmark") }
                Button { deck.swipe(.right) } label: { Label("Save", systemImage: "bookmark.fill") }
            }
            .buttonStyle(.bordered)
            .disabled(deck.remaining == 0 && !deck.canUndo)
            Text("\(deck.remaining) lodges left").font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
    }
}

private struct TravelPass: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let code: String
    let symbol: String
    let colors: [Color]

    static let all: [TravelPass] = [
        TravelPass(title: "Maasai Mara Park Pass", subtitle: "3 days · 2 adults", code: "MMR-2291", symbol: "binoculars.fill", colors: [Color(red: 0.55, green: 0.3, blue: 0.1), Color(red: 0.95, green: 0.65, blue: 0.25)]),
        TravelPass(title: "Madaraka Express", subtitle: "Nairobi → Mombasa · First class", code: "SGR-0816", symbol: "tram.fill", colors: [Color(red: 0.1, green: 0.3, blue: 0.2), Color(red: 0.2, green: 0.65, blue: 0.4)]),
        TravelPass(title: "Zanzibar Ferry", subtitle: "Dar → Stone Town · 09:30", code: "ZNZ-4410", symbol: "ferry.fill", colors: [Color(red: 0.0, green: 0.35, blue: 0.6), Color(red: 0.2, green: 0.75, blue: 0.85)]),
        TravelPass(title: "Savannah Air", subtitle: "NBO → ZNZ · Seat 4A", code: "SVA-117", symbol: "airplane", colors: [Color(red: 0.2, green: 0.1, blue: 0.35), Color(red: 0.7, green: 0.3, blue: 0.7)]),
        TravelPass(title: "Nairobi Food Walk", subtitle: "Sat 10:00 · River Road", code: "NFW-0032", symbol: "fork.knife", colors: [Color(red: 0.55, green: 0.1, blue: 0.15), Color(red: 0.95, green: 0.4, blue: 0.35)]),
    ]
}

private struct PassCard: View {
    let pass: TravelPass

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: pass.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: pass.symbol).font(.system(size: 120)).foregroundStyle(.white.opacity(0.12)).offset(x: 190, y: 50)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: pass.symbol).font(.headline)
                    Text(pass.title).font(.headline)
                    Spacer()
                    Text(pass.code).font(.caption.monospaced().weight(.semibold)).opacity(0.85)
                }
                Text(pass.subtitle).font(.subheadline).opacity(0.85)
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PASSENGER").font(.caption2.weight(.bold)).opacity(0.7)
                        Text("Wycliff Njenga").font(.subheadline.weight(.semibold))
                    }
                    Spacer()
                    Image(systemName: "qrcode").font(.system(size: 40))
                }
            }
            .foregroundStyle(.white)
            .padding(18)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct WalletSample: View {
    @State private var selection: TravelPass.ID?
    @State private var fanned = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Trip wallet").font(.title2.bold())
                Spacer()
                if fanned || selection != nil {
                    Button("Done") { withAnimation { selection = nil; fanned = false } }
                        .font(.subheadline.weight(.semibold))
                        .transition(.opacity)
                }
            }
            KitoStackedCards(TravelPass.all, selection: $selection, isExpanded: $fanned, cardHeight: 200) { pass in
                PassCard(pass: pass)
            }
            Text(fanned || selection != nil ? "Tap a pass to bring it forward" : "Tap the stack to fan it out")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding(24)
    }
}

// MARK: - Story samples

private struct RingStatesSample: View {
    var body: some View {
        VStack(spacing: 28) {
            HStack(spacing: 22) {
                ring("New", seen: false)
                ring("Seen", seen: true)
                ring("Live", live: true)
                ring("Loading", loading: true)
            }
            HStack(spacing: 22) {
                KitoStoryRing(size: 96, lineWidth: 4, tint: .teal) { InitialsAvatar(initials: "BO", colors: [.teal, .blue]) }
                KitoStoryRing(size: 96, lineWidth: 4, colors: [.green, .yellow, .red]) { InitialsAvatar(initials: "KE", colors: [.green, .black]) }
            }
        }
        .padding(.vertical, 32)
    }

    private func ring(_ title: String, seen: Bool = false, live: Bool = false, loading: Bool = false) -> some View {
        VStack(spacing: 8) {
            KitoStoryRing(isSeen: seen, isLive: live, isLoading: loading) {
                InitialsAvatar(initials: String(title.prefix(2)).uppercased(), colors: [.orange, .pink])
            }
            .accessibilityLabel(Text(title))
            Text(title).font(.caption)
        }
    }
}

private struct TraySample: View {
    @State private var people = StoryPerson.friends
    @State private var opened: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KitoStoryTray(people, title: { $0.name }, isSeen: { $0.seen }, isLive: { $0.live },
                          yourStory: KitoYourStory(initials: "WN") { opened = "Your story" },
                          onSelect: { person in
                              opened = person.name
                              if let index = people.firstIndex(where: { $0.id == person.id }) { people[index].seen = true }
                          }) { person in
                InitialsAvatar(initials: person.initials, colors: person.colors)
            }
            Text(opened.map { "Opened \($0)" } ?? "Tap a ring; it spins, then turns grey once seen.")
                .font(.footnote).foregroundStyle(.secondary).padding(.horizontal, 16)
            Button("Reset") { people = StoryPerson.friends; opened = nil }.font(.footnote.weight(.semibold)).padding(.horizontal, 16)
        }
        .padding(.vertical, 24)
    }
}

/// A social home screen with a tray; tapping a ring opens the viewer over it.
private struct StoriesHomeScreen: View {
    @State private var people = StoryPerson.friends
    @State private var openedID: StoryPerson.ID?

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Safiri").font(.system(size: 30, weight: .black, design: .rounded))
                        Spacer()
                        Image(systemName: "heart").font(.title3)
                        Image(systemName: "paperplane").font(.title3)
                    }
                    .padding(.horizontal, 16)
                    KitoStoryTray(people, title: { $0.name }, isSeen: { $0.seen }, isLive: { $0.live },
                                  yourStory: KitoYourStory(initials: "WN") {},
                                  onSelect: { person in withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) { openedID = person.id } }) { person in
                        InitialsAvatar(initials: person.initials, colors: person.colors)
                    }
                    ForEach(Place.lodges.prefix(3)) { place in
                        PlaceCard(place: place, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 20)
            }
            if let openedID {
                KitoStoryViewer(people, startingAt: openedID,
                                segmentCount: { $0.frames.count },
                                title: { $0.name },
                                subtitle: { person, index in person.frames[index].time },
                                onSeen: { person, _ in
                                    if let index = people.firstIndex(where: { $0.id == person.id }) { people[index].seen = true }
                                },
                                onDismiss: { withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { self.openedID = nil } }) { person, index in
                    StoryPage(frame: person.frames[index])
                } avatar: { person in
                    InitialsAvatar(initials: person.initials, colors: person.colors)
                }
                .transition(.scale(scale: 0.85).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Scroll container samples

private struct ZanzibarGuideScreen: View {
    var body: some View {
        KitoParallaxHeader(title: "Zanzibar", subtitle: "Stone Town · Nungwi · Paje", height: 340) {
            BeachScene()
        } content: {
            VStack(alignment: .leading, spacing: 22) {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(["🏖️ Beaches", "🌶️ Spice tours", "⛵️ Dhows", "🐢 Turtles", "🍤 Forodhani"], id: \.self) { tag in
                            Text(tag).font(.subheadline.weight(.medium)).padding(.horizontal, 14).padding(.vertical, 8)
                                .background(Color.primary.opacity(0.06), in: Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
                Text("Where to stay").font(.title3.bold()).padding(.horizontal, 20)
                KitoCarousel(Place.coast, effect: .scale, peek: 28) { PlaceCard(place: $0, height: 190) }
                    .frame(height: 190)
                Text("Good to know").font(.title3.bold()).padding(.horizontal, 20)
                ForEach(tips) { tip in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: tip.symbol).font(.title3).foregroundStyle(.teal).frame(width: 28)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tip.title).font(.headline)
                            Text(tip.detail).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 24)
        }
    }

    private struct Tip: Identifiable {
        let title: String
        let symbol: String
        let detail: String
        var id: String { title }
    }

    private let tips: [Tip] = [
        Tip(title: "Ferry from Dar", symbol: "ferry.fill", detail: "Fast ferries take about two hours; book the morning boat for calm seas."),
        Tip(title: "Currency", symbol: "banknote", detail: "Tanzanian shillings; US dollars are accepted at most hotels."),
        Tip(title: "Best season", symbol: "sun.max.fill", detail: "June to October is dry and breezy; the short rains come in November."),
        Tip(title: "Stone Town", symbol: "building.columns.fill", detail: "Get lost in the alleys, then eat at Forodhani Gardens at sunset."),
        Tip(title: "Nungwi", symbol: "water.waves", detail: "No big tides in the north, so the beach stays swimmable all day."),
        Tip(title: "Respect", symbol: "hands.sparkles.fill", detail: "Cover shoulders and knees in town; swimwear is for the beach."),
    ]
}

private struct Reel: Identifiable {
    let id = UUID()
    let scene: SceneKind
    let handle: String
    let caption: String
    let likes: Int

    static let all: [Reel] = [
        Reel(scene: .savanna, handle: "@mara.guide", caption: "Lions at golden hour, Maasai Mara", likes: 12_400),
        Reel(scene: .beach, handle: "@zanzi.waves", caption: "Nungwi water is this clear", likes: 8_900),
        Reel(scene: .skyline, handle: "@nairobi.nights", caption: "Nairobi skyline from Upper Hill", likes: 5_200),
        Reel(scene: .flamingo, handle: "@nakuru.birds", caption: "A million flamingos, zero filters", likes: 15_100),
        Reel(scene: .dhow, handle: "@lamu.slow", caption: "Dhow sunset, Lamu channel", likes: 6_700),
    ]
}

private struct ReelsScreen: View {
    @State private var index = 0
    @State private var liked: Set<UUID> = []

    var body: some View {
        KitoPagedList(Reel.all, selection: $index) { reel, isActive in
            ZStack(alignment: .bottomLeading) {
                SceneArt(kind: reel.scene)
                LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 6) {
                    Text(reel.handle).font(.headline)
                    Text(reel.caption).font(.subheadline)
                    Label(isActive ? "Playing" : "Paused", systemImage: isActive ? "play.fill" : "pause.fill").font(.caption.weight(.semibold)).opacity(0.8)
                }
                .foregroundStyle(.white)
                .padding(20)
                .padding(.bottom, 20)
                VStack(spacing: 20) {
                    Button {
                        if liked.contains(reel.id) { liked.remove(reel.id) } else { liked.insert(reel.id) }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: liked.contains(reel.id) ? "heart.fill" : "heart").font(.title)
                                .foregroundStyle(liked.contains(reel.id) ? .red : .white)
                                .symbolEffect(.bounce, value: liked.contains(reel.id))
                            Text("\(reel.likes + (liked.contains(reel.id) ? 1 : 0))").font(.caption.weight(.semibold))
                        }
                    }
                    Image(systemName: "bubble.right.fill").font(.title2)
                    Image(systemName: "paperplane.fill").font(.title2)
                }
                .foregroundStyle(.white)
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(20)
                .padding(.bottom, 30)
            }
        }
    }
}

private struct MenuItem: Identifiable {
    let id = UUID()
    let dish: Dish

    static let all: [MenuItem] = (Dish.nairobi + Dish.nairobi.reversed()).map { MenuItem(dish: $0) }
}

private struct SnapGridSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nairobi eats").font(.title3.bold())
                Spacer()
                Text("See all").font(.subheadline.weight(.semibold)).foregroundStyle(.orange)
            }
            .padding(.horizontal, 16)
            KitoSnapGrid(MenuItem.all, rows: 3, rowHeight: 64) { item in
                HStack(spacing: 12) {
                    Text(item.dish.emoji).font(.system(size: 30))
                        .frame(width: 56, height: 56)
                        .background(LinearGradient(colors: item.dish.colors, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.dish.name).font(.subheadline.weight(.semibold))
                        Text(item.dish.spot).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(item.dish.price).font(.caption.weight(.bold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.primary.opacity(0.06), in: Capsule())
                }
            }
        }
        .padding(.vertical, 24)
    }
}

// MARK: - Gallery

enum CarouselSamples {
    private static let carousels = KitSection("Carousels", symbol: "rectangle.stack.fill", [
        KitSample("Safari lodges", "Peeking neighbours that shrink away, with a worm indicator.", code: """
        KitoCarousel(lodges, selection: $page, effect: .scale, peek: 36) { lodge in
            LodgeCard(lodge).frame(height: 260)
        }
        KitoPageIndicator(count: lodges.count, selection: $page, style: .worm)
        """) { LodgeCarouselSample() },
        KitSample("Cover flow", "Kenyan sounds in 3D, looping forever.", code: """
        KitoCarousel(albums, selection: $page, effect: .coverFlow,
                     spacing: 4, peek: 70, loops: true) { album in
            AlbumCover(album).aspectRatio(1, contentMode: .fit)
        }
        """) { CoverFlowSample() },
        KitSample("Parallax coast", "Each scene drifts against the swipe.", code: """
        KitoCarousel(coast, effect: .parallax) { PlaceCard($0) }
        """) { LodgeCarouselSample(effect: .parallax, indicator: .capsule, places: Place.coast) },
        KitSample("Hand of cards", "Neighbours tilt and drop like a fanned hand.", code: """
        KitoCarousel(proverbs, effect: .rotate) { ProverbCard($0) }
        """) { ProverbSample(effect: .rotate) },
        KitSample("Stacked", "Upcoming lodges wait behind the current one.", code: """
        KitoCarousel(lodges, effect: .stack, loops: true) { PlaceCard($0) }
        """) { LodgeCarouselSample(effect: .stack, indicator: .dots, loops: true) },
        KitSample("Fade and soften", "Swahili proverbs that blur as they leave.", code: """
        KitoCarousel(proverbs, effect: .fade, peek: 40) { ProverbCard($0) }
        """) { ProverbSample(effect: .fade) },
        KitSample("Auto-play", "Loops every three seconds and holds while you touch it.", code: """
        @State private var progress = 0.0

        KitoCarousel(lodges, selection: $page, loops: true,
                     autoPlay: 3, autoPlayProgress: $progress) { PlaceCard($0) }
        KitoPageIndicator(count: lodges.count, selection: $page,
                          style: .progress, progress: progress)
        """) { LodgeCarouselSample(effect: .scale, indicator: .progress, loops: true, autoPlay: 3) },
        KitSample("Effect playground", "Every effect, peek, spacing and looping, live.", code: """
        KitoCarousel(lodges, selection: $page, effect: effect,
                     spacing: spacing, peek: peek, loops: loops) { PlaceCard($0) }
        """) { PlaygroundSample() },
    ])

    private static let indicators = KitSection("Page indicators", symbol: "ellipsis.rectangle.fill", [
        KitSample("Every style", "Dots, capsule, worm, numbers and progress on one page.", code: """
        KitoPageIndicator(count: 6, selection: $page, style: .dots)
        KitoPageIndicator(count: 6, selection: $page, style: .capsule)
        KitoPageIndicator(count: 6, selection: $page, style: .worm, tint: .orange)
        KitoPageIndicator(count: 6, selection: $page, style: .numbers)
        KitoPageIndicator(count: 6, selection: $page, style: .progress, progress: 0.4)
        """) { AllIndicatorsSample() },
        KitSample("Scrub to jump", "Tap a dot or drag along the row.", code: """
        KitoPageIndicator(count: coast.count, selection: $page,
                          style: .capsule, dotSize: 12, tint: .teal)
        """) { ScrubSample() },
        KitSample("Onboarding", "Full-width pages, a liquid indicator and a Next button.", code: """
        KitoCarousel(pages, selection: $page, effect: .fade,
                     spacing: 0, peek: 0, cornerRadius: 0) { OnboardingPageView($0) }
        KitoPageIndicator(count: pages.count, selection: $page, style: .worm)
        """) { ModalStage { OnboardingScreen() } },
    ])

    private static let banners = KitSection("Banners & marquees", symbol: "megaphone.fill", [
        KitSample("Promo banners", "Deals that advance on their own, with a countdown indicator.", code: """
        KitoBannerCarousel(deals, interval: 4, height: 170) { deal in
            DealBanner(deal)
        }
        """) {
            KitoBannerCarousel(Deal.all, interval: 4, height: 170) { DealBanner(deal: $0) }
                .padding(.vertical, 24)
        },
        KitSample("Partner strip", "Two endless rows drifting opposite ways; hold to pause.", code: """
        KitoInfiniteMarquee(partners, speed: 38) { PartnerChip($0) }
        KitoInfiniteMarquee(partners, speed: 26, direction: .trailing) { PartnerIcon($0) }
        """) { MarqueeSample() },
        KitSample("Travel ticker", "Live headlines with dot separators.", code: """
        KitoInfiniteMarquee(headlines, speed: 55, spacing: 22, tint: .orange) { headline in
            Label(headline.text, systemImage: headline.symbol)
        }
        """) { TickerSample() },
    ])

    private static let decks = KitSection("Swipe & stack", symbol: "hand.draw.fill", [
        KitSample("Swipe to crave", "Drag, flick or tap the buttons; stamps fade in, undo brings it back.", code: """
        KitoCardDeck(dishes, likeLabel: "YUM", nopeLabel: "PASS", superLikeLabel: "CRAVE") { dish in
            DishCard(dish)
        } onSwipe: { dish, direction in
            if direction != .left { cravings.append(dish) }
        }
        .frame(height: 540)
        """) { DeckSample() },
        KitSample("Your own buttons", "Drive the deck from a controller.", code: """
        @State private var deck = KitoCardDeckController()

        KitoCardDeck(lodges, controller: deck, allowsSuperLike: false, showsControls: false) {
            PlaceCard($0)
        }
        Button("Skip") { deck.swipe(.left) }
        Button("Save") { deck.swipe(.right) }
        Button("Undo") { deck.undo() }.disabled(!deck.canUndo)
        """) { ControlledDeckSample() },
        KitSample("Trip wallet", "Passes in a pile; tap to fan out, tap one to bring it forward.", code: """
        KitoStackedCards(passes, selection: $pass, isExpanded: $fanned) { pass in
            PassCard(pass)
        }
        """) { WalletSample() },
    ])

    private static let stories = KitSection("Stories", symbol: "circle.dashed.inset.filled", [
        KitSample("Story rings", "New, seen, live, loading and custom gradients.", code: """
        KitoStoryRing(isSeen: false) { Avatar() }
        KitoStoryRing(isSeen: true) { Avatar() }
        KitoStoryRing(isLive: true) { Avatar() }
        KitoStoryRing(isLoading: true) { Avatar() }
        KitoStoryRing(size: 96, tint: .teal) { Avatar() }
        """) { RingStatesSample() },
        KitSample("Story tray", "Your story first; rings spin, then grey out once seen.", code: """
        KitoStoryTray(friends, title: { $0.name }, isSeen: { $0.seen }, isLive: { $0.live },
                      yourStory: KitoYourStory(initials: "WN") { compose() },
                      onSelect: { open($0) }) { friend in
            Avatar(friend)
        }
        """) { TraySample() },
        KitSample("Story viewer", "Tap, hold, swipe between friends on a cube, swipe down, reply and like.", code: """
        KitoStoryViewer(friends, startingAt: opened,
                        segmentCount: { $0.frames.count },
                        title: { $0.name },
                        subtitle: { friend, index in friend.frames[index].time },
                        onDismiss: { opened = nil }) { friend, index in
            StoryPage(friend.frames[index])
        } avatar: { friend in
            Avatar(friend)
        }
        """) { ModalStage { StoriesHomeScreen() } },
    ])

    private static let containers = KitSection("Scroll containers", symbol: "scroll.fill", [
        KitSample("Stretchy header", "Pull to grow, scroll to parallax and blur; the title docks at the top.", code: """
        KitoParallaxHeader(title: "Zanzibar", subtitle: "Stone Town · Nungwi · Paje") {
            BeachScene()
        } content: {
            GuideSections()
        }
        """) { ModalStage { ZanzibarGuideScreen() } },
        KitSample("Reels", "Full-screen vertical paging; each page knows when it's active.", code: """
        KitoPagedList(reels, selection: $index) { reel, isActive in
            ReelView(reel, isPlaying: isActive)
        }
        """) { ModalStage { ReelsScreen() } },
        KitSample("Snap grid", "Three rows per column, snapping column by column.", code: """
        KitoSnapGrid(menu, rows: 3, rowHeight: 64) { item in
            MenuRow(item)
        }
        """) { SnapGridSample() },
    ])

    static let sections: [KitSection] = [carousels, indicators, banners, decks, stories, containers]
}

struct CarouselGallery: View {
    static var count: Int { KitGallery.count(CarouselSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Carousels & Stories",
            sections: CarouselSamples.sections,
            footnote: "Requires `import KitoCarousel`.",
            searchHint: "Try “cover flow”, “worm”, “swipe”, “story” or “reels”."
        )
    }
}
