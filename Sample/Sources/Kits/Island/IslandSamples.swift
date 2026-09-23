//
//  IslandSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoIslandBar

private let islandCode = """
@State private var presentation = KitoIslandPresentation.compact

ContentView()
    .kitoDynamicIsland(presentation: $presentation) {
        Image(systemName: "timer")            // compact, left of the camera
    } trailing: {
        Text("4:59")                          // compact, right of the camera
    } expanded: {
        TimerControls()                       // the grown panel
    }
"""

enum IslandSamples {
    static let sections: [KitSection] = [media, everyday, travel, live, moments, pill]

    static let media = KitSection("Media", symbol: "music.note", [
        KitSample("Apple Music style", "Artwork and a live waveform; expands to a player with a scrubber.", code: """
        @State private var presentation = KitoIslandPresentation.compact
        @State private var isPlaying = true
        @State private var elapsed: TimeInterval = 42

        ContentView()
            .kitoNowPlayingIsland(
                presentation: $presentation,
                item: KitoNowPlayingItem(title: "Midnight Drive", artist: "Neon Coast",
                                         artwork: .gradient([.pink, .purple], symbol: "music.note"),
                                         duration: 214),
                isPlaying: $isPlaying,
                elapsed: $elapsed,
                onPrevious: previous, onNext: next
            )
        """) { MusicIslandSample() },
    ])

    static let everyday = KitSection("Everyday", symbol: "clock", [
        KitSample("Timer", "Countdown in the island; pause and cancel when expanded.", code: islandCode) { TimerIslandSample() },
        KitSample("Phone call", "Incoming call with accept and decline, then a compact call timer.", code: islandCode.replacingOccurrences(of: "Image(systemName: \"timer\")", with: "Image(systemName: \"phone.fill\")")) { CallIslandSample() },
        KitSample("Voice recording", "A pulsing red dot and a live waveform.", code: islandCode.replacingOccurrences(of: "Image(systemName: \"timer\")", with: "Circle().fill(.red)")) { RecordingIslandSample() },
        KitSample("Upload progress", "A filling ring when compact; file and bar when expanded.", code: islandCode) { UploadIslandSample() },
    ])

    static let travel = KitSection("Travel & delivery", symbol: "car.fill", [
        KitSample("Ride arriving", "Minutes away, with the car moving along the route.", code: islandCode) { RideIslandSample() },
        KitSample("Food delivery", "Order steps from kitchen to door.", code: islandCode) { DeliveryIslandSample() },
        KitSample("Turn-by-turn", "The next turn and the distance to it.", code: islandCode) { NavigationIslandSample() },
        KitSample("Flight", "Boarding pass details: gate, seat, route.", code: islandCode) { FlightIslandSample() },
    ])

    static let live = KitSection("Live data", symbol: "waveform.path.ecg", [
        KitSample("Match score", "Team badges either side of the camera.", code: islandCode) { ScoreIslandSample() },
        KitSample("Workout", "Heart rate compact; activity rings expanded.", code: islandCode) { WorkoutIslandSample() },
    ])

    static let moments = KitSection("Moments", symbol: "sparkles", [
        KitSample("AirPods connected", "Grows, shows the battery, and settles.", code: momentCode) {
            MomentIslandSample(trigger: "Connect AirPods", settlesTo: .expanded) {
                EmptyView()
            } trailing: {
                EmptyView()
            } expanded: {
                HStack(spacing: 14) {
                    Image(systemName: "airpods.pro").font(.system(size: 34)).foregroundStyle(.white).symbolEffect(.bounce, value: true)
                    VStack(alignment: .leading) {
                        Text("AirPods Pro").font(.headline).foregroundStyle(.white)
                        Text("Connected").font(.caption).foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Label("82%", systemImage: "battery.75percent").font(.subheadline.weight(.semibold)).foregroundStyle(.green)
                }
            }
        },
        KitSample("Charging", "A green bolt and the level, briefly.", code: momentCode) {
            MomentIslandSample(trigger: "Plug in", settlesTo: .compact) {
                Image(systemName: "bolt.fill").font(.system(size: 14, weight: .bold)).foregroundStyle(.green).symbolEffect(.bounce, value: true)
            } trailing: {
                Text("82%").font(.system(size: 13, weight: .semibold)).foregroundStyle(.green)
            } expanded: { EmptyView() }
        },
        KitSample("Silent mode", "The bell slashes when you flip the switch.", code: momentCode) {
            MomentIslandSample(trigger: "Flip the switch", settlesTo: .compact) {
                Image(systemName: "bell.slash.fill").font(.system(size: 14, weight: .bold)).foregroundStyle(.orange).symbolEffect(.bounce, value: true)
            } trailing: {
                Text("Silent").font(.system(size: 13, weight: .semibold)).foregroundStyle(.orange)
            } expanded: { EmptyView() }
        },
        KitSample("Face ID", "A quick confirmation after authenticating.", code: momentCode) {
            MomentIslandSample(trigger: "Authenticate", settlesTo: .expanded) {
                EmptyView()
            } trailing: {
                EmptyView()
            } expanded: {
                VStack(spacing: 8) {
                    Image(systemName: "faceid").font(.system(size: 44)).foregroundStyle(.green).symbolEffect(.bounce, value: true)
                    Text("Face ID").font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
            }
        },
        KitSample("Payment done", "A tick, the amount and the merchant.", code: momentCode) {
            MomentIslandSample(trigger: "Pay", settlesTo: .expanded, wallpaper: [.black, .green.opacity(0.6)]) {
                EmptyView()
            } trailing: {
                EmptyView()
            } expanded: {
                HStack(spacing: 14) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 38)).foregroundStyle(.green).symbolEffect(.bounce, value: true)
                    VStack(alignment: .leading) {
                        Text("Paid KSh 1,200").font(.headline).foregroundStyle(.white)
                        Text("Mama's Kitchen").font(.caption).foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                }
            }
        },
        KitSample("Low battery", "A warning with a one-tap action.", code: momentCode) {
            MomentIslandSample(trigger: "Drain battery", settlesTo: .expanded) {
                EmptyView()
            } trailing: {
                EmptyView()
            } expanded: {
                HStack(spacing: 14) {
                    Image(systemName: "battery.25percent").font(.system(size: 30)).foregroundStyle(.red)
                    VStack(alignment: .leading) {
                        Text("Low Battery").font(.headline).foregroundStyle(.white)
                        Text("10% remaining").font(.caption).foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("Low Power").font(.caption.weight(.bold)).padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Capsule().fill(.yellow)).foregroundStyle(.black)
                }
            }
        },
        KitSample("Focus on", "A moon and the mode's name.", code: momentCode) {
            MomentIslandSample(trigger: "Turn on Focus", settlesTo: .compact) {
                Image(systemName: "moon.fill").font(.system(size: 14, weight: .bold)).foregroundStyle(.purple).symbolEffect(.bounce, value: true)
            } trailing: {
                Text("Sleep").font(.system(size: 13, weight: .semibold)).foregroundStyle(.purple)
            } expanded: { EmptyView() }
        },
    ])

    static let momentCode = """
    // Grow the island for a moment, then let it settle back.
    presentation = .expanded
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
        presentation = .idle
    }
    """

    static let pill = KitSection("Status pill", symbol: "capsule", [
        KitSample("Glyph pill", "The original KitoIslandBar pill: a tinted glyph.", code: ".kitoIslandBar(.compact(systemImage: \"bolt.fill\", color: .blue))") {
            PillStage(state: .compact(systemImage: "bolt.fill", color: .blue))
        },
        KitSample("Progress pill", "A ring and a label.", code: ".kitoIslandBar(.progress(fraction: 0.6, color: .green, label: \"60%\"))") {
            PillStage(state: .progress(fraction: 0.6, color: .green, label: "60%"))
        },
        KitSample("Alert pill", "A title and a message.", code: ".kitoIslandBar(.expanded(title: \"Low battery\", message: \"12% remaining\", color: .red))") {
            PillStage(state: .expanded(title: "Low battery", message: "12% remaining", color: .red))
        },
        KitSample("Real battery", "KitoBatteryMonitor's live level (hidden in the Simulator).", code: "@State private var battery = KitoBatteryMonitor()\n\n.kitoIslandBar(battery.islandBarState())") {
            BatteryPillStage()
        },
    ])
}

private struct PillStage: View {
    let state: KitoIslandBarState
    @State private var shown = true

    var body: some View {
        VStack(spacing: 14) {
            IslandWallpaper()
                .frame(height: 300)
                .kitoIslandBar(shown ? state : .hidden)
                .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            Toggle("Show pill", isOn: $shown).tint(.primary)
        }
    }
}

private struct BatteryPillStage: View {
    @State private var battery = KitoBatteryMonitor()

    var body: some View {
        VStack(spacing: 10) {
            IslandWallpaper()
                .frame(height: 300)
                .kitoIslandBar(battery.islandBarState())
                .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            Text(battery.level == nil ? "This Simulator has no battery hardware; run on a device to see the live level." : "Live battery level")
                .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
    }
}

/// Every island sample.
struct IslandGallery: View {
    static var count: Int { KitGallery.count(IslandSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Dynamic Island",
            sections: IslandSamples.sections,
            footnote: "Requires `import KitoIslandBar`. Drawn by the app over the hardware island: iOS doesn't let apps resize the real one. Open full screen to see it grow out of the real island.",
            searchHint: "Try an activity (“music”, “timer”, “ride”) or a moment (“AirPods”)."
        )
    }
}
