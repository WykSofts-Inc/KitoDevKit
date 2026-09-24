//
//  ImageLoaderSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import UIKit
import KitoImageLoader
import KitoFormatting

// MARK: - Offline-friendly image sources

/// Paints a small landscape for a URL — sky, sun and layered hills — so samples that need a
/// predictable load (retries, reveals, stats) work with no network at all.
private enum ImgArt {
    static let palettes: [[UIColor]] = [
        [UIColor(red: 1.0, green: 0.62, blue: 0.4, alpha: 1), UIColor(red: 0.55, green: 0.25, blue: 0.55, alpha: 1), UIColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1)],
        [UIColor(red: 0.45, green: 0.8, blue: 1.0, alpha: 1), UIColor(red: 0.2, green: 0.55, blue: 0.45, alpha: 1), UIColor(red: 0.08, green: 0.3, blue: 0.25, alpha: 1)],
        [UIColor(red: 1.0, green: 0.85, blue: 0.5, alpha: 1), UIColor(red: 0.85, green: 0.45, blue: 0.2, alpha: 1), UIColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1)],
        [UIColor(red: 0.6, green: 0.65, blue: 1.0, alpha: 1), UIColor(red: 0.3, green: 0.3, blue: 0.7, alpha: 1), UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1)],
        [UIColor(red: 0.98, green: 0.7, blue: 0.75, alpha: 1), UIColor(red: 0.7, green: 0.35, blue: 0.5, alpha: 1), UIColor(red: 0.3, green: 0.12, blue: 0.25, alpha: 1)],
    ]

    static func seed(_ url: URL) -> Int {
        url.absoluteString.unicodeScalars.reduce(7) { ($0 &* 31 &+ Int($1.value)) & 0x7fffffff }
    }

    static func size(_ url: URL) -> CGSize {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let width = items.first { $0.name == "w" }.flatMap { Double($0.value ?? "") } ?? 600
        let height = items.first { $0.name == "h" }.flatMap { Double($0.value ?? "") } ?? 400
        return CGSize(width: width, height: height)
    }

    static func data(for url: URL) -> Data {
        let size = size(url)
        let seed = seed(url)
        let palette = palettes[seed % palettes.count]
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            let cg = context.cgContext
            let colors = [palette[0].cgColor, palette[1].cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
                cg.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }
            let sunX = size.width * (0.2 + Double(seed % 60) / 100)
            UIColor.white.withAlphaComponent(0.85).setFill()
            cg.fillEllipse(in: CGRect(x: sunX, y: size.height * 0.18, width: size.width * 0.16, height: size.width * 0.16))
            for layer in 0..<3 {
                let path = UIBezierPath()
                let base = size.height * (0.55 + Double(layer) * 0.14)
                path.move(to: CGPoint(x: 0, y: size.height))
                for step in 0...24 {
                    let x = size.width * Double(step) / 24
                    let wave = sin(Double(step) / 3.2 + Double(seed % 7) + Double(layer) * 1.7) * size.height * 0.06
                    path.addLine(to: CGPoint(x: x, y: base + wave))
                }
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.close()
                palette[2].withAlphaComponent(0.45 + Double(layer) * 0.25).setFill()
                path.fill()
            }
        }
        return image.jpegData(compressionQuality: 0.85) ?? Data()
    }

    /// Fresh each launch, so painted images load (and show their placeholders) the first time
    /// they're seen in a session instead of coming straight off disk.
    static let session = UUID().uuidString.prefix(6)

    /// A `kito-art://` URL the art fetcher paints; `key` makes it unique.
    static func url(_ key: String, width: Int = 600, height: Int = 400) -> URL {
        URL(string: "kito-art://\(session)-\(key)?w=\(width)&h=\(height)")!
    }
}

private actor ImgAttempts {
    static let shared = ImgAttempts()
    private var counts: [URL: Int] = [:]

    func next(for url: URL) -> Int {
        counts[url, default: 0] += 1
        return counts[url]!
    }
}

/// Paints `ImgArt` after a believable delay, reporting progress; can fail the first few tries.
private struct ImgArtFetcher: KitoImageDataFetching {
    var latency: ClosedRange<Double> = 0.5...1.4
    var failuresBeforeSuccess = 0
    var alwaysFails = false

    func fetch(_ url: URL, onProgress: (@Sendable (Double) -> Void)?) async throws -> Data {
        let attempt = await ImgAttempts.shared.next(for: url)
        let total = Double.random(in: latency)
        for step in 1...8 {
            try await Task.sleep(nanoseconds: UInt64(total / 8 * 1_000_000_000))
            onProgress?(Double(step) / 8)
        }
        if alwaysFails || attempt <= failuresBeforeSuccess { throw URLError(.timedOut) }
        return ImgArt.data(for: url)
    }
}

private enum ImgLoaders {
    static let art = KitoImageLoader(diskCache: KitoDiskImageCache(directoryName: "KitoDevKitArt"), fetcher: ImgArtFetcher())
    static let flaky = KitoImageLoader(diskCache: KitoDiskImageCache(directoryName: "KitoDevKitFlaky"), fetcher: ImgArtFetcher(failuresBeforeSuccess: 2))
    static let broken = KitoImageLoader(diskCache: KitoDiskImageCache(directoryName: "KitoDevKitBroken"), fetcher: ImgArtFetcher(latency: 0.3...0.6, alwaysFails: true))
}

private enum ImgPhotos {
    static func url(_ seed: String, _ width: Int = 800, _ height: Int = 600) -> URL {
        URL(string: "https://picsum.photos/seed/kito-\(seed)/\(width)/\(height)")!
    }

    static let gradients: [[Color]] = [
        [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 0.85, green: 0.3, blue: 0.45)],
        [Color(red: 0.35, green: 0.7, blue: 0.95), Color(red: 0.25, green: 0.35, blue: 0.85)],
        [Color(red: 0.3, green: 0.8, blue: 0.6), Color(red: 0.1, green: 0.5, blue: 0.5)],
        [Color(red: 0.95, green: 0.78, blue: 0.4), Color(red: 0.9, green: 0.5, blue: 0.25)],
        [Color(red: 0.7, green: 0.55, blue: 0.95), Color(red: 0.4, green: 0.3, blue: 0.8)],
    ]

    static func gradient(_ index: Int) -> KitoImageLoadingStyle { .gradient(gradients[index % gradients.count]) }

    static let places: [(String, String, CGFloat)] = [
        ("maasai-mara", "Maasai Mara at dawn", 1.5), ("diani", "Diani beach", 0.75), ("lamu", "Lamu old town", 1.0),
        ("naivasha", "Lake Naivasha", 0.8), ("kilimanjaro", "Kilimanjaro from Amboseli", 1.33), ("nairobi", "Nairobi skyline", 0.66),
        ("hells-gate", "Hell's Gate gorge", 1.2), ("watamu", "Watamu reef", 0.9), ("karura", "Karura Forest", 0.7), ("mt-kenya", "Mount Kenya", 1.1),
    ]
}

private struct ImgCaption: View {
    let text: String
    var body: some View {
        Text(text).font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Loading states

private struct ImgShimmerSample: View {
    @State private var token = 0

    var body: some View {
        VStack(spacing: 14) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(0..<4, id: \.self) { index in
                    KitoRemoteImage(url: ImgArt.url("shimmer-\(index)-\(token)", width: 400, height: 400), loader: ImgLoaders.art, loading: .shimmer)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            Button { token += 1 } label: { Label("Load new images", systemImage: "arrow.clockwise") }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct ImgBlurUpSample: View {
    @State private var token = 0
    private var seed: String { "blurup-\(token % 3)" }

    var body: some View {
        VStack(spacing: 14) {
            KitoRemoteImage(
                url: ImgPhotos.url(seed, 1200, 900),
                loading: .blurUp(preview: ImgPhotos.url(seed, 24, 18)),
                appearance: .fade
            )
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tiny preview first").font(.headline)
                    Text("24 × 18 px, blurred, then the full photo").font(.caption)
                }
                .foregroundStyle(.white)
                .padding(16)
                .shadow(radius: 6)
            }
            .id(token)
            Button { token += 1 } label: { Label("Next photo", systemImage: "photo.on.rectangle") }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct ImgColorPlaceholderSample: View {
    private let stays: [(String, String, String, Color)] = [
        ("stay-1", "Treehouse, Karen", "KES 12,500 / night", Color(red: 0.36, green: 0.5, blue: 0.32)),
        ("stay-2", "Beach villa, Kilifi", "KES 28,000 / night", Color(red: 0.4, green: 0.65, blue: 0.8)),
        ("stay-3", "Loft, Kilimani", "KES 7,800 / night", Color(red: 0.62, green: 0.45, blue: 0.35)),
    ]

    var body: some View {
        VStack(spacing: 14) {
            ForEach(stays, id: \.0) { stay in
                HStack(spacing: 14) {
                    KitoRemoteImage(url: ImgPhotos.url(stay.0, 300, 300), loading: .color(stay.3), appearance: .fade)
                        .frame(width: 84, height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stay.1).font(.headline)
                        Text(stay.2).font(.subheadline).foregroundStyle(.secondary)
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill").foregroundStyle(.orange)
                            Text("4.9").fontWeight(.semibold)
                        }
                        .font(.caption)
                    }
                    Spacer()
                }
            }
            ImgCaption(text: "Each placeholder is the photo's dominant colour, sent by the API, so the list feels calm while it loads.")
        }
    }
}

private struct ImgLoaderStylesSample: View {
    @State private var style: KitoImagePlaceholderStyle = .spinner
    @State private var token = 0

    var body: some View {
        VStack(spacing: 14) {
            KitoRemoteImage(url: ImgArt.url("loader-\(token)", width: 900, height: 600), loader: ImgLoaders.art, loading: .loader(style), appearance: .fade)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .id("\(token)-\(style.label)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(KitoImagePlaceholderStyle.allCases, id: \.self) { option in
                        Button(option.label) { style = option; token += 1 }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .foregroundStyle(option == style ? Color(.systemBackground) : .primary)
                            .background(option == style ? Color.primary : Color.primary.opacity(0.07), in: Capsule())
                            .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct ImgProgressSample: View {
    @State private var token = 0

    var body: some View {
        VStack(spacing: 14) {
            KitoRemoteImage(url: ImgArt.url("progress-\(token)", width: 1400, height: 1000), loader: ImgLoaders.art, loading: .loader(.progressRing), appearance: .scaleIn)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            Button { token += 1 } label: { Label("Download again", systemImage: "arrow.down.circle") }
                .buttonStyle(GalleryPrimaryButtonStyle())
            ImgCaption(text: "The ring fills from the loader's real progress callback as bytes arrive.")
        }
    }
}

// MARK: - Reveal

private struct ImgRevealSample: View {
    @State private var appearance: KitoImageAppearance = .scaleIn
    @State private var token = 0

    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    KitoRemoteImage(url: ImgArt.url("reveal-\(index)-\(token)", width: 300, height: 400), loader: ImgLoaders.art, loading: .shimmer, appearance: appearance)
                        .aspectRatio(0.75, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .id("\(token)-\(appearance.rawValue)")
            Picker("Reveal", selection: $appearance) {
                ForEach(KitoImageAppearance.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: appearance) { _, _ in token += 1 }
            Button { token += 1 } label: { Label("Replay", systemImage: "play.fill") }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct ImgHeroSample: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KitoRemoteImage(url: ImgPhotos.url("maasai-mara", 1000, 1300), loading: ImgPhotos.gradient(0), appearance: .blurIn)
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 6) {
                Text("3 DAYS · FROM KES 64,000").font(.caption.weight(.heavy)).kerning(0.8).opacity(0.85)
                Text("Great Migration safari").font(.title.weight(.heavy))
                HStack(spacing: 10) {
                    KitoImageAvatarStack([KitoAvatarPerson(name: "Achieng O"), KitoAvatarPerson(name: "Kamau W"), KitoAvatarPerson(name: "Njeri M"), KitoAvatarPerson(name: "Brian K"), KitoAvatarPerson(name: "Zawadi A")], size: 26, maxVisible: 3)
                    Text("5 friends went").font(.caption.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .padding(20)
        }
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 12)
    }
}

// MARK: - Failure & retry

private struct ImgFlakySample: View {
    @State private var token = 0

    var body: some View {
        VStack(spacing: 14) {
            KitoRemoteImage(
                url: ImgArt.url("flaky-\(token)", width: 900, height: 600),
                loader: ImgLoaders.flaky,
                loading: .loader(.dots),
                appearance: .scaleIn,
                retry: KitoImageRetryPolicy(maxRetries: 3, baseDelay: 0.6)
            )
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .id(token)
            HStack(spacing: 8) {
                ForEach(["Try 1 fails", "Try 2 fails", "Try 3 loads"], id: \.self) { step in
                    Text(step).font(.caption.weight(.bold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.primary.opacity(step.hasSuffix("loads") ? 0.14 : 0.06), in: Capsule())
                }
            }
            Button { token += 1 } label: { Label("Run it again", systemImage: "arrow.clockwise") }
                .buttonStyle(GalleryPrimaryButtonStyle())
            ImgCaption(text: "This source times out twice. The image quietly retries after 0.6s, then 1.2s, and loads on the third try.")
        }
    }
}

private struct ImgFailureStylesSample: View {
    @State private var token = 0

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ForEach(Array(KitoImageFailureStyle.allCases.enumerated()), id: \.offset) { index, failure in
                    VStack(spacing: 6) {
                        KitoRemoteImage(url: ImgArt.url("broken-\(index)-\(token)"), loader: ImgLoaders.broken, loading: ImgPhotos.gradient(index + 1), retry: .none, failure: failure)
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        Text(String(describing: failure).capitalized).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    }
                }
            }
            .id(token)
            ImgCaption(text: "The retry style shrinks to just a button, then an icon, as the frame gets smaller.")
            HStack(spacing: 12) {
                ForEach([36.0, 56, 80], id: \.self) { size in
                    KitoRemoteImage(url: ImgArt.url("broken-small-\(size)-\(token)"), loader: ImgLoaders.broken, loading: .shimmer, retry: .none)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: size / 4, style: .continuous))
                }
            }
        }
    }
}

// MARK: - Avatars

private struct ImgAvatarsSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                KitoImageAvatar(url: ImgPhotos.url("face-wycliff", 200, 200), name: "Wycliff N", size: 64)
                KitoImageAvatar(url: nil, name: "Achieng Otieno", size: 64)
                KitoImageAvatar(url: ImgArt.url("broken-avatar"), name: "Kamau Wanjiku", size: 64, loader: ImgLoaders.broken)
                KitoImageAvatar(url: nil, name: "zawadi", size: 64)
            }
            HStack(alignment: .bottom, spacing: 12) {
                ForEach([24.0, 32, 44, 56, 72], id: \.self) { size in
                    KitoImageAvatar(url: nil, name: "Njeri Mwangi", size: size)
                }
            }
            ImgCaption(text: "Photo, no photo, a photo that fails, and a single name. Initials sit on a gradient that's always the same for the same name.")
        }
    }
}

private struct ImgStoriesSample: View {
    private let people: [(String, Bool)] = [("Wycliff N", false), ("Achieng O", false), ("Kamau W", false), ("Njeri M", true), ("Brian K", true), ("Zawadi A", true)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    VStack(spacing: 6) {
                        ZStack(alignment: .bottomTrailing) {
                            KitoImageAvatar(url: ImgPhotos.url("face-wycliff", 200, 200), name: "Wycliff N", size: 68)
                            Image(systemName: "plus").font(.caption.weight(.heavy)).foregroundStyle(.white)
                                .frame(width: 22, height: 22).background(Color.blue, in: Circle())
                                .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                        }
                        Text("Your story").font(.caption2.weight(.medium))
                    }
                    ForEach(Array(people.enumerated()), id: \.offset) { index, person in
                        VStack(spacing: 6) {
                            KitoImageAvatar(url: ImgPhotos.url("face-\(index)", 200, 200), name: person.0, size: 68, ring: person.1 ? .seen : .story(animates: index == 0))
                            Text(person.0.components(separatedBy: " ").first ?? person.0).font(.caption2.weight(.medium))
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            ImgCaption(text: "Unseen stories get the gradient ring (the first one spins while it loads); seen ones go grey.")
        }
    }
}

private struct ImgPresenceSample: View {
    private let contacts: [(String, String, KitoAvatarStatus)] = [
        ("Achieng Otieno", "Designing the new onboarding", .online), ("Kamau Wanjiku", "In a meeting until 3", .busy),
        ("Njeri Mwangi", "Back in 10", .away), ("Brian Kiprono", "Last seen yesterday", .none),
    ]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(Array(contacts.enumerated()), id: \.offset) { index, contact in
                HStack(spacing: 12) {
                    KitoImageAvatar(url: index.isMultiple(of: 2) ? ImgPhotos.url("contact-\(index)", 160, 160) : nil, name: contact.0, size: 48, status: contact.2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.0).font(.subheadline.weight(.semibold))
                        Text(contact.1).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "bubble.left.fill").foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
}

private struct ImgStacksSample: View {
    private let chama = ["Wycliff N", "Achieng O", "Kamau W", "Njeri M", "Brian K", "Zawadi A", "Otieno J", "Wanjiru K", "Mutua P"].map { KitoAvatarPerson(name: $0) }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chama ya Wikendi").font(.headline)
                    Text("9 members · KES 45,000 this month").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                KitoImageAvatarStack(chama, size: 34, maxVisible: 4)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Friday braai, Runda").font(.headline)
                    Text("3 going").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                KitoImageAvatarStack(Array(chama.prefix(3)).enumerated().map { index, person in
                    KitoAvatarPerson(name: person.name, photoURL: ImgPhotos.url("friend-\(index)", 160, 160))
                }, size: 40, maxVisible: 3, overlap: 0.25)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

// MARK: - Viewing

private struct ImgZoomSample: View {
    var body: some View {
        VStack(spacing: 10) {
            KitoZoomableImage(url: ImgPhotos.url("lamu", 1400, 1400))
                .frame(height: 340)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            Label("Pinch, pan, or double-tap to zoom", systemImage: "hand.pinch").font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct ImgViewerSample: View {
    @State private var openIndex: Int?
    private let photos = Array(ImgPhotos.places.prefix(6))

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                    Button { openIndex = index } label: {
                        KitoRemoteImage(url: ImgPhotos.url(photo.0, 1200, 1200), loading: ImgPhotos.gradient(index), appearance: .fade, accessibilityLabel: photo.1)
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            Label("Tap a photo · swipe between · drag down to close", systemImage: "hand.tap").font(.caption).foregroundStyle(.secondary)
        }
        .fullScreenCover(isPresented: Binding(get: { openIndex != nil }, set: { if !$0 { openIndex = nil } })) {
            KitoImageViewer(urls: photos.map { ImgPhotos.url($0.0, 1200, 1200) }, startIndex: openIndex ?? 0, captions: photos.map(\.1)) { openIndex = nil }
        }
    }
}

private struct ImgMasonrySample: View {
    let columns: Int
    let useArt: Bool

    var body: some View {
        ScrollView {
            KitoMasonryLayout(columns: columns, spacing: 8) {
                ForEach(Array(ImgPhotos.places.enumerated()), id: \.offset) { index, place in
                    let aspect = place.2
                    ZStack(alignment: .bottomLeading) {
                        if useArt {
                            KitoRemoteImage(url: ImgArt.url("masonry-\(index)", width: 300, height: Int(300 / aspect)), loader: ImgLoaders.art, loading: .shimmer, appearance: .scaleIn)
                        } else {
                            KitoRemoteImage(url: ImgPhotos.url(place.0, 500, Int(500 / aspect)), loading: ImgPhotos.gradient(index), appearance: .fade, accessibilityLabel: place.1)
                        }
                        if !useArt {
                            Text(place.1).font(.caption2.weight(.bold)).foregroundStyle(.white).padding(8).shadow(radius: 4)
                        }
                    }
                    .aspectRatio(aspect, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .frame(height: 520)
    }
}

// MARK: - Cache

private struct ImgStatsSample: View {
    @State private var stats = KitoImageCacheStats()
    @State private var round = 0
    private let urls = (0..<8).map { ImgArt.url("stats-\($0)", width: 400, height: 300) }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 18) {
                ZStack {
                    Circle().stroke(Color.primary.opacity(0.08), lineWidth: 12)
                    Circle().trim(from: 0, to: stats.hitRate)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        KitoAnimatedNumberText(stats.hitRate) { KitoNumberFormatting.percent($0) }.font(.title3.weight(.heavy))
                        Text("hit rate").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .frame(width: 110, height: 110)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: stats.hitRate)
                VStack(alignment: .leading, spacing: 6) {
                    statRow("Requests", stats.requests)
                    statRow("Memory hits", stats.memoryHits)
                    statRow("Disk hits", stats.diskHits)
                    statRow("Downloads", stats.networkFetches)
                    statRow("Shared", stats.sharedRequests)
                    HStack {
                        Text("On disk").foregroundStyle(.secondary)
                        Spacer()
                        Text(KitoFileSizeFormatting.string(bytes: Int64(stats.diskBytes))).fontWeight(.semibold)
                    }
                }
                .font(.caption.monospacedDigit())
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                ForEach(urls, id: \.self) { url in
                    KitoRemoteImage(url: url, loader: ImgLoaders.art, loading: .shimmer)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .id(round)

            HStack(spacing: 8) {
                Button("Reload") { round += 1 }
                Button("Clear memory") { Task { await ImgLoaders.art.clearMemoryCache(); round += 1 } }
                Button("Clear all") { Task { await ImgLoaders.art.clearAll(); await ImgLoaders.art.resetStats(); round += 1 } }
            }
            .font(.caption.weight(.bold))
            .buttonStyle(.bordered)
            .tint(.primary)
        }
        .task {
            while !Task.isCancelled {
                let latest = await ImgLoaders.art.stats()
                if latest != stats { withAnimation(.snappy) { stats = latest } }
                try? await Task.sleep(nanoseconds: 400_000_000)
            }
        }
    }

    private func statRow(_ title: String, _ value: Int) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            KitoAnimatedNumberText(Double(value)).fontWeight(.semibold)
        }
    }
}

private struct ImgPrefetchSample: View {
    @State private var phase = 0 // 0 idle, 1 prefetching, 2 ready
    @State private var loaded = 0
    @State private var batch = UUID().uuidString.prefix(6)
    private var urls: [URL] { (0..<8).map { ImgArt.url("prefetch-\(batch)-\($0)", width: 400, height: 400) } }

    var body: some View {
        VStack(spacing: 16) {
            if phase == 2 {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                    ForEach(urls, id: \.self) { url in
                        KitoRemoteImage(url: url, loader: ImgLoaders.art, loading: .shimmer)
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
                .transition(.scale(scale: 0.95).combined(with: .opacity))
                ImgCaption(text: "Every image was already in memory, so the grid appears complete, with no placeholders.")
            } else {
                VStack(spacing: 12) {
                    ZStack {
                        Circle().stroke(Color.primary.opacity(0.08), lineWidth: 10)
                        Circle().trim(from: 0, to: CGFloat(loaded) / 8)
                            .stroke(Color.primary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(loaded)/8").font(.headline.monospacedDigit()).contentTransition(.numericText())
                    }
                    .frame(width: 100, height: 100)
                    .animation(.snappy, value: loaded)
                    Text(phase == 1 ? "Warming the cache…" : "8 photos for the next screen").font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity, minHeight: 190)
            }
            Button {
                if phase == 2 { batch = UUID().uuidString.prefix(6); phase = 0; loaded = 0 } else { prefetch() }
            } label: {
                Label(phase == 2 ? "Start over" : "Prefetch, then show", systemImage: phase == 2 ? "arrow.counterclockwise" : "arrow.down.to.line")
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(phase == 1)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: phase)
    }

    private func prefetch() {
        phase = 1
        let targets = urls
        Task {
            await withTaskGroup(of: Void.self) { group in
                for url in targets {
                    group.addTask { _ = try? await ImgLoaders.art.image(for: url) }
                }
                for await _ in group { loaded += 1 }
            }
            phase = 2
        }
    }
}

private struct ImgDedupSample: View {
    @State private var stats = KitoImageCacheStats()
    @State private var token = UUID().uuidString.prefix(6)

    private var url: URL { ImgArt.url("dedup-\(token)", width: 300, height: 300) }

    var body: some View {
        VStack(spacing: 14) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                ForEach(0..<12, id: \.self) { _ in
                    KitoRemoteImage(url: url, loader: ImgLoaders.art, loading: .shimmer, appearance: .scaleIn)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(Circle())
                }
            }
            .id(token)
            HStack(spacing: 20) {
                VStack { KitoAnimatedNumberText(Double(stats.networkFetches)).font(.title2.weight(.heavy)); Text("downloads").font(.caption2).foregroundStyle(.secondary) }
                VStack { KitoAnimatedNumberText(Double(stats.sharedRequests)).font(.title2.weight(.heavy)); Text("shared").font(.caption2).foregroundStyle(.secondary) }
                VStack { KitoAnimatedNumberText(Double(stats.memoryHits)).font(.title2.weight(.heavy)); Text("from memory").font(.caption2).foregroundStyle(.secondary) }
            }
            Button { token = UUID().uuidString.prefix(6) } label: { Label("Twelve cells, one new URL", systemImage: "square.grid.3x3.fill") }
                .buttonStyle(GalleryPrimaryButtonStyle())
        }
        .task {
            await ImgLoaders.art.resetStats()
            while !Task.isCancelled {
                let latest = await ImgLoaders.art.stats()
                if latest != stats { stats = latest }
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
        }
    }
}

// MARK: - Catalog

enum ImageLoaderSamples {
    static let sections: [KitSection] = [loading, reveal, failure, avatars, viewing, cache]

    static let loading = KitSection("While it loads", symbol: "photo.badge.arrow.down", [
        KitSample("Shimmer", "A band of light sweeps the tile until the photo lands.", code: """
        KitoRemoteImage(url: photo.url, loading: .shimmer)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        """) { ImgShimmerSample() },
        KitSample("Blur-up", "A tiny preview shows blurred, then the full photo fades over it.", code: """
        KitoRemoteImage(
            url: listing.photoURL,
            loading: .blurUp(preview: listing.thumbnailURL)   // a 24 × 18 px version
        )
        """) { ImgBlurUpSample() },
        KitSample("Dominant colour", "Each tile starts as the photo's own colour, for a calm list.", code: "KitoRemoteImage(url: stay.photoURL, loading: .color(stay.dominantColor))") { ImgColorPlaceholderSample() },
        KitSample("Loader styles", "Spinner, dots, pulse, progress ring or skeleton from KitoLoaders.", code: "KitoRemoteImage(url: url, loading: .loader(.dots))") { ImgLoaderStylesSample() },
        KitSample("Real download progress", "A ring that fills from the loader's byte-by-byte progress.", code: "KitoRemoteImage(url: largePhotoURL, loading: .loader(.progressRing), appearance: .scaleIn)") { ImgProgressSample() },
    ])

    static let reveal = KitSection("Reveal", symbol: "sparkles", [
        KitSample("Reveal styles", "Fade, scale in, blur in or slide up; Reduce Motion always fades.", code: """
        KitoRemoteImage(url: url, loading: .shimmer, appearance: .scaleIn)   // .fade, .blurIn, .slideUp, .none
        """) { ImgRevealSample() },
        KitSample("Hero card", "A tall travel card that sharpens in behind its text.", code: """
        ZStack(alignment: .bottomLeading) {
            KitoRemoteImage(url: trip.coverURL, loading: .gradient(brandColors), appearance: .blurIn)
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
            TripDetails(trip)
        }
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        """) { ImgHeroSample() },
    ])

    static let failure = KitSection("Failure & retry", symbol: "arrow.clockwise", [
        KitSample("Retries with backoff", "Fails twice, retries after 0.6s and 1.2s, then loads.", code: """
        KitoRemoteImage(
            url: url,
            retry: KitoImageRetryPolicy(maxRetries: 3, baseDelay: 0.6)   // .none, .standard, .persistent
        )
        """) { ImgFlakySample() },
        KitSample("Failure styles", "Retry button, icon only, or nothing; the button shrinks in small frames.", code: """
        KitoRemoteImage(url: url, failure: .retry)   // .icon, .hidden
        """) { ImgFailureStylesSample() },
    ])

    static let avatars = KitSection("Avatars", symbol: "person.crop.circle", [
        KitSample("Avatars with fallbacks", "Photo, initials on a stable gradient, or a failed photo falling back.", code: """
        KitoImageAvatar(url: user.photoURL, name: "Wycliff N", size: 64)
        KitoImageAvatar(url: nil, name: "Achieng Otieno")   // "AO"
        """) { ImgAvatarsSample() },
        KitSample("Story rings", "A story tray with unseen, seen and spinning rings.", code: """
        KitoImageAvatar(url: friend.photoURL, name: friend.name, size: 68, ring: friend.hasNewStory ? .story(animates: false) : .seen)
        """) { ImgStoriesSample() },
        KitSample("Presence", "Online, away and busy dots on a contact list.", code: "KitoImageAvatar(url: contact.photoURL, name: contact.name, size: 48, status: .online)") { ImgPresenceSample() },
        KitSample("Avatar stacks", "Overlapping members with a +5 bubble.", code: "KitoImageAvatarStack(members, size: 34, maxVisible: 4)") { ImgStacksSample() },
    ])

    static let viewing = KitSection("Viewing", symbol: "rectangle.expand.vertical", [
        KitSample("Pinch to zoom", "Pinch, pan and double-tap; it springs back inside its frame.", code: "KitoZoomableImage(url: photo.url, maxScale: 4)") { ImgZoomSample() },
        KitSample("Full-screen viewer", "Swipe between photos, zoom any of them, drag down to close.", code: """
        .fullScreenCover(isPresented: $isViewerOpen) {
            KitoImageViewer(urls: photos, startIndex: tapped, captions: captions) { isViewerOpen = false }
        }
        """) { ImgViewerSample() },
        KitSample("Masonry gallery", "A two-column Pinterest-style grid, each photo keeping its shape.", code: """
        ScrollView {
            KitoMasonryLayout(columns: 2, spacing: 8) {
                ForEach(photos) { photo in
                    KitoRemoteImage(url: photo.url).aspectRatio(photo.aspect, contentMode: .fit)
                }
            }
        }
        """) { ImgMasonrySample(columns: 2, useArt: false) },
        KitSample("Three-column masonry", "Denser, with a scale-in reveal as each tile loads.", code: "KitoMasonryLayout(columns: 3, spacing: 8) { … }") { ImgMasonrySample(columns: 3, useArt: true) },
    ])

    static let cache = KitSection("Cache", symbol: "internaldrive", [
        KitSample("Cache stats", "Hit rate, memory and disk hits, downloads and bytes on disk, live.", code: """
        let stats = await KitoImageLoader.shared.stats()
        stats.hitRate          // 0.87
        stats.networkFetches   // 8
        stats.diskBytes        // 1_240_000
        """) { ImgStatsSample() },
        KitSample("Prefetch, then show", "Warm the cache first so the next screen opens complete.", code: """
        await KitoImageLoader.shared.prefetchAndWait(nextScreenURLs)
        // or, fire and forget:
        .kitoPrefetchImages(nextScreenURLs)
        """) { ImgPrefetchSample() },
        KitSample("One URL, one download", "Twelve cells ask at once; one request serves them all.", code: """
        ForEach(0..<12) { _ in
            KitoRemoteImage(url: sameURL)   // one download, eleven shared
        }
        """) { ImgDedupSample() },
    ])
}

/// Every image loader sample.
struct ImageLoaderDemo: View {
    static var count: Int { KitGallery.count(ImageLoaderSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Image Loader",
            sections: ImageLoaderSamples.sections,
            footnote: "Requires `import KitoImageLoader`. Photos come from picsum.photos; samples marked offline paint their own images.",
            searchHint: "Try “shimmer”, “avatar”, “zoom” or “cache”."
        )
    }
}
