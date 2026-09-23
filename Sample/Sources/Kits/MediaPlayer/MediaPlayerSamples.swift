//
//  MediaPlayerSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoMediaPlayer

// MARK: - Shared pieces

/// Only one sample plays at a time: starting one pauses the last.
@MainActor
private final class PlaybackGate {
    static let shared = PlaybackGate()
    private weak var audio: KitoAudioPlayerModel?
    private weak var video: KitoVideoPlayerModel?

    func claim(_ model: KitoAudioPlayerModel) {
        if audio !== model { audio?.pause() }
        video?.pause()
        audio = model
    }

    func claim(_ model: KitoVideoPlayerModel) {
        if video !== model { video?.pause() }
        audio?.pause()
        video = model
    }
}

/// Loads the generated playlist (offline, cached) and hands a player to its content.
private struct WithPlayer<Content: View>: View {
    var arrange: ([KitoAudioTrack]) -> [KitoAudioTrack] = { $0 }
    var systemControls = false
    @ViewBuilder let content: (KitoAudioPlayerModel) -> Content
    @State private var model: KitoAudioPlayerModel?

    var body: some View {
        Group {
            if let model {
                content(model)
                    .onChange(of: model.isPlaying) { _, playing in
                        if playing { PlaybackGate.shared.claim(model) }
                    }
            } else {
                VStack(spacing: 10) {
                    ProgressView()
                    Text("Composing sample music…").font(.footnote).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            }
        }
        .task {
            guard model == nil else { return }
            let tracks = (try? await KitoSampleAudio.playlist()) ?? []
            model = KitoAudioPlayerModel(tracks: arrange(tracks), systemControls: systemControls)
        }
        .onDisappear { model?.pause() }
    }
}

/// A podcast episode with chapters, built from a generated minute of music.
private struct WithEpisode<Content: View>: View {
    @ViewBuilder let content: (KitoAudioPlayerModel) -> Content
    @State private var model: KitoAudioPlayerModel?

    var body: some View {
        Group {
            if let model {
                content(model)
                    .onChange(of: model.isPlaying) { _, playing in
                        if playing { PlaybackGate.shared.claim(model) }
                    }
            } else {
                ProgressView().frame(maxWidth: .infinity, minHeight: 180)
            }
        }
        .task {
            guard model == nil else { return }
            let url = try? await Task.detached { try KitoSampleAudio.makeFile(.drift, duration: 60) }.value
            guard let url else { return }
            model = KitoAudioPlayerModel(tracks: [Episode.track(url: url)])
        }
        .onDisappear { model?.pause() }
    }
}

private enum Episode {
    static let chapters = [
        KitoChapter("Cold open", start: 0, systemImage: "sparkles"),
        KitoChapter("Why ship small", start: 12, systemImage: "shippingbox.fill"),
        KitoChapter("Designing for motion", start: 27, systemImage: "wand.and.stars"),
        KitoChapter("Listener questions", start: 41, systemImage: "questionmark.bubble.fill"),
        KitoChapter("Wrap-up", start: 53, systemImage: "hand.wave.fill"),
    ]

    static func track(url: URL) -> KitoAudioTrack {
        KitoAudioTrack(
            id: "episode-42",
            title: "Ep. 42 — Small, polished, shipped",
            artist: "The Kito Show",
            album: "The Kito Show",
            url: url,
            artwork: .gradient([Color(red: 0.1, green: 0.75, blue: 0.55), Color(red: 0.05, green: 0.3, blue: 0.45)], systemImage: "mic.fill"),
            chapters: chapters
        )
    }
}

/// Owns a video model for samples that also drive it from outside the player.
private struct WithVideo<Content: View>: View {
    let url: URL
    var chapters: [KitoChapter] = []
    var loops = false
    var isMuted = false
    @ViewBuilder let content: (KitoVideoPlayerModel) -> Content
    @State private var model: KitoVideoPlayerModel?

    var body: some View {
        Group {
            if let model {
                content(model)
                    .onChange(of: model.isPlaying) { _, playing in
                        if playing { PlaybackGate.shared.claim(model) }
                    }
            } else {
                Color.black.aspectRatio(16 / 9, contentMode: .fit)
            }
        }
        .onAppear {
            if model == nil { model = KitoVideoPlayerModel(url: url, chapters: chapters, loops: loops, isMuted: isMuted) }
        }
        .onDisappear { model?.pause() }
    }
}

private func videoFrame<V: View>(_ view: V, ratio: CGFloat = 16 / 9) -> some View {
    view
        .aspectRatio(ratio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 16, y: 8)
}

// MARK: - Video

private struct CinemaSample: View {
    var body: some View {
        WithVideo(url: KitoSampleMedia.videoURL, chapters: KitoSampleMedia.videoChapters) { model in
            VStack(alignment: .leading, spacing: 12) {
                videoFrame(KitoVideoPlayer(model: model, style: .cinema, title: "BipBop", subtitle: "Apple HLS test stream"))
                Text("Tap to show controls · double-tap the sides for ±10s · drag the scrubber for the time bubble")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ErrorSample: View {
    @State private var model = KitoVideoPlayerModel(url: URL(fileURLWithPath: "/missing/clip.mp4"))

    var body: some View {
        VStack(spacing: 12) {
            videoFrame(KitoVideoPlayer(model: model, style: .cinema, title: "Offline clip"))
            Button("Point at the real stream") {
                model.replace(url: KitoSampleMedia.videoURL)
                model.retry()
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

private struct WatchScreen: View {
    var body: some View {
        WithVideo(url: KitoSampleMedia.videoURL, chapters: KitoSampleMedia.videoChapters) { model in
            VStack(spacing: 0) {
                KitoVideoPlayer(model: model, style: .cinema, title: "Streaming 101")
                    .aspectRatio(16 / 9, contentMode: .fit)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Streaming 101: adaptive video on iPhone").font(.title3.bold())
                            Text("48K views · 2 days ago").font(.subheadline).foregroundStyle(.secondary)
                        }
                        HStack(spacing: 12) {
                            Circle().fill(LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom))
                                .frame(width: 40, height: 40)
                                .overlay(Text("K").font(.headline).foregroundStyle(.white))
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Kito Studio").font(.subheadline.weight(.semibold))
                                Text("312K subscribers").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("Subscribe")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color(.systemBackground))
                                .padding(.horizontal, 16).padding(.vertical, 8)
                                .background(Capsule().fill(Color.primary))
                        }
                        HStack {
                            Text("Chapters").font(.headline)
                            Spacer()
                            KitoPlaybackRateChip(model: model)
                        }
                        KitoChapterList(model: model)
                    }
                    .padding(16)
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

private struct ChapteredVideo: View {
    var body: some View {
        WithVideo(url: KitoSampleMedia.videoURL, chapters: KitoSampleMedia.videoChapters) { model in
            VStack(spacing: 16) {
                videoFrame(KitoVideoPlayer(model: model, style: .minimal))
                KitoChapterList(model: model)
            }
        }
    }
}

// MARK: - Social

private struct ReelPost: Identifiable {
    let id: Int
    let handle: String
    let caption: String
    let likes: Int
    let comments: Int
    let model: KitoVideoPlayerModel
}

private struct ReelsFeed: View {
    @State private var posts: [ReelPost] = [
        ReelPost(id: 0, handle: "@kito.studio", caption: "Colour bars never looked this good. Double-tap if you agree 🎨", likes: 12_400, comments: 318,
                 model: KitoVideoPlayerModel(url: KitoSampleMedia.videoURL, loops: true, isMuted: true)),
        ReelPost(id: 1, handle: "@nala.waves", caption: "The classic BipBop, 4:3 memories in 16:9", likes: 8_930, comments: 142,
                 model: KitoVideoPlayerModel(url: KitoSampleMedia.classicVideoURL, loops: true, isMuted: true)),
        ReelPost(id: 2, handle: "@lumen", caption: "Streaming test patterns at 60fps. Sound on 🔊", likes: 41_200, comments: 1_024,
                 model: KitoVideoPlayerModel(url: KitoSampleMedia.videoURL, loops: true, isMuted: true)),
    ]
    @State private var current: Int? = 0

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(posts) { post in
                    KitoVideoPlayer(
                        model: post.model,
                        style: .social,
                        title: post.handle,
                        subtitle: post.caption,
                        actions: [
                            .like(count: post.likes),
                            .comments(count: post.comments),
                            .save(),
                            .share(),
                        ]
                    )
                    .containerRelativeFrame([.horizontal, .vertical])
                    .id(post.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $current)
        .scrollIndicators(.hidden)
        .background(Color.black)
        .onAppear { play(current) }
        .onChange(of: current) { _, index in play(index) }
        .onDisappear { posts.forEach { $0.model.pause() } }
    }

    private func play(_ index: Int?) {
        for post in posts {
            if post.id == index {
                post.model.seek(to: 0)
                post.model.play()
                PlaybackGate.shared.claim(post.model)
            } else {
                post.model.pause()
            }
        }
    }
}

// MARK: - Music

private struct LibraryScreen: View {
    let model: KitoAudioPlayerModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Made for you").font(.title3.bold())
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(model.tracks) { track in
                                Button { model.play(track) } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        KitoArtworkView(track.artwork).frame(width: 130, height: 130)
                                        Text(track.title).font(.subheadline.weight(.semibold)).lineLimit(1)
                                        Text(track.artist).font(.caption).foregroundStyle(.secondary)
                                    }
                                    .frame(width: 130, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    Text("Recently played").font(.title3.bold())
                    ForEach(model.tracks.reversed()) { track in
                        Button { model.play(track) } label: {
                            HStack(spacing: 12) {
                                KitoArtworkView(track.artwork).frame(width: 52, height: 52)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(track.title).font(.body.weight(.medium))
                                    Text(track.artist).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if model.currentTrack == track && model.isPlaying {
                                    Image(systemName: "waveform").symbolEffect(.variableColor.iterative)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .padding(.bottom, 90)
            }
            .navigationTitle("Listen Now")
        }
        .kitoMiniPlayer(model)
    }
}

private struct QueueCard: View {
    let model: KitoAudioPlayerModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                if let track = model.currentTrack {
                    KitoArtworkView(track.artwork).frame(width: 56, height: 56)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title).font(.headline)
                        Text(track.artist).font(.subheadline).foregroundStyle(.secondary)
                    }
                    .id(track.id)
                    .transition(.push(from: .trailing))
                }
                Spacer()
                Button { model.togglePlayback() } label: {
                    Image(systemName: model.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            }
            .animation(.snappy, value: model.currentTrack?.id)

            HStack(spacing: 10) {
                pill(model.repeatMode == .one ? "repeat.1" : "repeat", title: "Repeat \(model.repeatMode.rawValue)", isOn: model.repeatMode != .off) { model.cycleRepeatMode() }
                pill("shuffle", title: model.isShuffled ? "Shuffled" : "In order", isOn: model.isShuffled) { model.toggleShuffle() }
                Spacer()
                Button { model.previous() } label: { Image(systemName: "backward.fill") }.buttonStyle(.plain)
                Button { model.next() } label: { Image(systemName: "forward.fill") }.buttonStyle(.plain)
            }
            .font(.subheadline.weight(.semibold))

            Text("Up next").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
            ForEach(Array(model.upNext.enumerated()), id: \.element.id) { index, track in
                HStack(spacing: 10) {
                    Text("\(index + 1)").font(.caption.monospacedDigit()).foregroundStyle(.secondary).frame(width: 16)
                    KitoArtworkView(track.artwork).frame(width: 34, height: 34)
                    Text(track.title).font(.subheadline)
                    Spacer()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: model.upNext.map(\.id))
    }

    private func pill(_ symbol: String, title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title.capitalized, systemImage: symbol)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Capsule().fill(isOn ? Color.primary : Color.primary.opacity(0.08)))
                .foregroundStyle(isOn ? Color(.systemBackground) : Color.primary)
        }
        .buttonStyle(.plain)
    }
}

private struct SleepCard: View {
    let model: KitoAudioPlayerModel

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().stroke(Color.indigo.opacity(0.15), lineWidth: 12)
                TimelineView(.periodic(from: .now, by: 0.5)) { context in
                    let fraction = fractionLeft(at: context.date)
                    Circle()
                        .trim(from: 0, to: fraction)
                        .stroke(Color.indigo.gradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: fraction)
                }
                VStack(spacing: 4) {
                    Image(systemName: model.sleepTimer == nil ? "moon.zzz" : "moon.zzz.fill")
                        .font(.title2)
                        .foregroundStyle(.indigo)
                        .symbolEffect(.bounce, value: model.sleepTimer == nil)
                    Text(model.sleepTimerLabel ?? "Off")
                        .font(.title2.bold().monospacedDigit())
                        .contentTransition(.numericText(countsDown: true))
                }
            }
            .frame(width: 170, height: 170)
            HStack(spacing: 12) {
                Button { model.togglePlayback() } label: {
                    Label(model.isPlaying ? "Pause" : "Play", systemImage: model.isPlaying ? "pause.fill" : "play.fill")
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
                KitoSleepTimerMenu(model: model, options: [.duration(20), .minutes(5), .minutes(15), .endOfTrack], tint: .indigo)
            }
            Text("Pick 20 seconds to hear the fade-out.").font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func fractionLeft(at date: Date) -> Double {
        guard let timer = model.sleepTimer, case .duration(let total) = timer.mode, total > 0 else { return 0 }
        return (timer.remaining(at: date) ?? 0) / total
    }
}

// MARK: - Podcasts

private struct EpisodeScreen: View {
    let model: KitoAudioPlayerModel

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                if let track = model.currentTrack {
                    KitoArtworkView(track.artwork)
                        .frame(width: 180, height: 180)
                        .shadow(color: .teal.opacity(0.4), radius: 24, y: 12)
                        .scaleEffect(model.isPlaying ? 1 : 0.9)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: model.isPlaying)
                    VStack(spacing: 4) {
                        Text(track.title).font(.headline).multilineTextAlignment(.center)
                        Text(track.artist).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                KitoWaveformView(
                    samples: model.waveform,
                    progress: model.progress,
                    duration: model.duration,
                    tint: .teal,
                    onSeek: { model.seek(to: $0 * model.duration) }
                )
                .frame(height: 40)
                HStack {
                    Text(KitoMediaTime.string(model.currentTime))
                    Spacer()
                    Text(KitoMediaTime.remainingString(currentTime: model.currentTime, duration: model.duration))
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                HStack(spacing: 28) {
                    KitoPlaybackRateChip(model: model, tint: .teal)
                    Button { model.skip(by: -15) } label: { Image(systemName: "gobackward.15").font(.title2) }
                    Button { model.togglePlayback() } label: {
                        Image(systemName: model.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.teal)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    Button { model.skip(by: 15) } label: { Image(systemName: "goforward.15").font(.title2) }
                    KitoSleepTimerMenu(model: model, tint: .teal)
                }
                .buttonStyle(.plain)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Chapters").font(.headline)
                    KitoChapterList(model: model, tint: .teal)
                }
            }
            .padding(20)
        }
        .background(LinearGradient(colors: [Color.teal.opacity(0.18), Color(.systemBackground)], startPoint: .top, endPoint: .center))
    }
}

private struct EpisodeChapters: View {
    let model: KitoAudioPlayerModel

    var body: some View {
        VStack(spacing: 12) {
            Button { model.togglePlayback() } label: {
                Label(model.isPlaying ? "Pause episode" : "Play episode", systemImage: model.isPlaying ? "pause.fill" : "play.fill")
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            KitoChapterList(model: model, tint: .teal)
        }
    }
}

private struct RateChipSample: View {
    @State private var rate: Float = 1

    var body: some View {
        VStack(spacing: 16) {
            KitoPlaybackRateChip(rate: $rate, tint: .orange)
                .scaleEffect(1.4)
            Text("A 60-minute episode takes \(KitoMediaTime.string(3600 / Double(rate)))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .animation(.snappy, value: rate)
            Text("Tap to step through speeds · press and hold to pick one").font(.footnote).foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

// MARK: - Waveforms

private struct WaveformScrubber: View {
    let model: KitoAudioPlayerModel

    var body: some View {
        VStack(spacing: 14) {
            KitoWaveformView(
                samples: model.waveform,
                progress: model.progress,
                duration: model.duration,
                barWidth: 4,
                spacing: 3,
                tint: .pink,
                onSeek: { model.seek(to: $0 * model.duration) }
            )
            .frame(height: 70)
            HStack {
                Button { model.togglePlayback() } label: {
                    Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Color.pink.opacity(0.15)))
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.pink)
                VStack(alignment: .leading) {
                    Text(model.currentTrack?.title ?? "").font(.headline)
                    Text("Peaks read from the file with AVAssetReader").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(KitoMediaTime.string(model.currentTime)).font(.subheadline.monospacedDigit())
            }
        }
    }
}

private struct VoiceNotes: View {
    var body: some View {
        VStack(spacing: 12) {
            WithPlayer(arrange: { Array($0.dropFirst(2).prefix(1)) }) { model in
                VoiceBubble(model: model, isMine: false)
            }
            WithPlayer(arrange: { Array($0.prefix(1)) }) { model in
                VoiceBubble(model: model, isMine: true)
            }
        }
    }
}

private struct VoiceBubble: View {
    let model: KitoAudioPlayerModel
    let isMine: Bool

    var body: some View {
        let accent: Color = isMine ? .white : .blue
        HStack(spacing: 10) {
            Button { model.togglePlayback() } label: {
                Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                    .font(.headline)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(accent.opacity(0.2)))
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            KitoWaveformView(
                samples: model.waveform,
                progress: model.progress,
                duration: model.duration,
                barWidth: 2.5,
                spacing: 2,
                tint: accent,
                trackColor: accent.opacity(0.3),
                onSeek: { model.seek(to: $0 * model.duration) }
            )
            .frame(width: 150, height: 30)
            Text(KitoMediaTime.string(model.isPlaying ? model.currentTime : model.duration))
                .font(.caption.monospacedDigit())
                .opacity(0.8)
        }
        .foregroundStyle(isMine ? .white : .primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(isMine ? Color.blue : Color.primary.opacity(0.07)))
        .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
    }
}

private struct BarStyles: View {
    @State private var progress = [0.3, 0.55, 0.8]

    var body: some View {
        VStack(spacing: 22) {
            row(0, seed: "podcast", width: 2, spacing: 1.5, tint: .purple)
            row(1, seed: "voice memo", width: 4, spacing: 3, tint: .orange)
            row(2, seed: "track", width: 6, spacing: 4, tint: .mint)
        }
    }

    private func row(_ index: Int, seed: String, width: CGFloat, spacing: CGFloat, tint: Color) -> some View {
        KitoWaveformView(
            samples: KitoWaveformAnalyzer.placeholder(count: 80, seed: seed),
            progress: progress[index],
            barWidth: width,
            spacing: spacing,
            tint: tint,
            onSeek: { value in withAnimation(.snappy) { progress[index] = value } }
        )
        .frame(height: 44)
    }
}

// MARK: - Building blocks

private struct CustomChrome: View {
    @State private var model = KitoVideoPlayerModel(url: KitoSampleMedia.videoURL, loops: true)

    var body: some View {
        ZStack(alignment: .bottom) {
            KitoVideoSurface(model: model, gravity: .fill)
                .background(Color.black)
            HStack(spacing: 14) {
                Button { model.togglePlayback() } label: {
                    Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                        .contentTransition(.symbolEffect(.replace))
                }
                Text("\(KitoMediaTime.string(model.currentTime)) / \(KitoMediaTime.string(model.duration))")
                    .font(.caption.monospacedDigit())
                ProgressView(value: model.progress).tint(.white)
                Button { model.toggleMuted() } label: {
                    Image(systemName: model.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .environment(\.colorScheme, .dark)
            .padding(12)
        }
        .aspectRatio(4 / 5, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .task { model.prepare() }
        .onChange(of: model.isPlaying) { _, playing in if playing { PlaybackGate.shared.claim(model) } }
        .onDisappear { model.pause() }
    }
}

private struct TimeFormats: View {
    private let rows: [(String, String)] = [
        ("KitoMediaTime.string(7)", KitoMediaTime.string(7)),
        ("KitoMediaTime.string(62)", KitoMediaTime.string(62)),
        ("KitoMediaTime.string(3723)", KitoMediaTime.string(3723)),
        ("remainingString(10, 202)", KitoMediaTime.remainingString(currentTime: 10, duration: 202)),
        ("clamped(-5, duration: 60)", KitoMediaTime.string(KitoMediaTime.clamped(-5, duration: 60))),
        ("spoken(62)", KitoMediaTime.spoken(62)),
        ("KitoPlaybackRate.label(1.5)", KitoPlaybackRate.label(1.5)),
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(rows, id: \.0) { row in
                HStack {
                    Text(row.0).font(.system(.footnote, design: .monospaced)).foregroundStyle(.secondary)
                    Spacer()
                    Text(row.1).font(.subheadline.weight(.semibold).monospacedDigit())
                }
            }
        }
    }
}

// MARK: - Catalogue

enum MediaPlayerSamples {
    static let video = KitSection("Video", symbol: "play.rectangle.fill", [
        KitSample("Cinema player", "Custom chrome over AVPlayer: chapters, buffered range, speed, mute, PiP and fullscreen.", code: """
        KitoVideoPlayer(
            url: videoURL,
            chapters: [KitoChapter("Intro", start: 0), KitoChapter("Demo", start: 95)],
            style: .cinema,
            title: "BipBop",
            subtitle: "Apple HLS test stream"
        )
        .aspectRatio(16 / 9, contentMode: .fit)
        """) { CinemaSample() },
        KitSample("Minimal", "A play button and a slim scrubber that fade away. Muted and looping.", code: """
        KitoVideoPlayer(url: clipURL, loops: true, isMuted: true, autoplay: true, style: .minimal)
        """) {
            videoFrame(KitoVideoPlayer(url: KitoSampleMedia.classicVideoURL, loops: true, isMuted: true, style: .minimal))
        },
        KitSample("Inline card", "The video on top, compact controls and a speed chip below.", code: """
        KitoVideoPlayer(url: lessonURL, style: .inline, title: "Lesson 3: Streaming",
                        subtitle: "8 min · Beginner", tint: .indigo)
        """) {
            KitoVideoPlayer(url: KitoSampleMedia.videoURL, chapters: KitoSampleMedia.videoChapters, style: .inline,
                            title: "Lesson 3: Adaptive streaming", subtitle: "10 min · Beginner", tint: .indigo)
        },
        KitSample("Chapters under the video", "One model drives the player and a tappable chapter list.", code: """
        @State private var player = KitoVideoPlayerModel(url: videoURL, chapters: chapters)

        KitoVideoPlayer(model: player, style: .minimal)
        KitoChapterList(model: player)
        """) { ChapteredVideo() },
        KitSample("Loading and errors", "A spinner while buffering; a failure shows the reason and Try again.", code: """
        @State private var player = KitoVideoPlayerModel(url: offlineURL)

        KitoVideoPlayer(model: player)        // "Can't play this video" + Try again
        player.replace(url: mirrorURL)
        player.retry()                        // resumes where it stopped
        """) { ErrorSample() },
        KitSample("Watch screen", "A video page: player, channel row, speed chip and chapters.", code: """
        VStack(spacing: 0) {
            KitoVideoPlayer(model: player, style: .cinema, title: video.title)
                .aspectRatio(16 / 9, contentMode: .fit)
            ScrollView {
                VideoDetails(video)
                KitoPlaybackRateChip(model: player)
                KitoChapterList(model: player)
            }
        }
        """) { ModalStage { WatchScreen() } },
    ])

    static let social = KitSection("Social", symbol: "play.square.stack.fill", [
        KitSample("Reels feed", "Vertical paging; the visible post plays. Double-tap to like, tap to pause.", code: """
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(posts) { post in
                    KitoVideoPlayer(model: post.player, style: .social,
                                    title: post.handle, subtitle: post.caption,
                                    actions: [.like(count: post.likes), .comments(count: post.comments), .save(), .share()])
                        .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $visible)
        .onChange(of: visible) { playOnly($1) }
        """) { ModalStage { ReelsFeed() } },
        KitSample("Single post", "Side actions with counts, a spinning sound disc and a thin progress line you can drag.", code: """
        KitoVideoPlayer(
            url: reelURL, loops: true, style: .social,
            title: "@kito.studio", subtitle: "Colour bars never looked this good 🎨",
            actions: [
                .like(count: 12_400) { liked in api.setLiked(liked) },
                .comments(count: 318) { showComments = true },
                .share { share(reel) },
            ]
        )
        """) {
            KitoVideoPlayer(url: KitoSampleMedia.videoURL, loops: true, style: .social, title: "@kito.studio",
                            subtitle: "Colour bars never looked this good 🎨",
                            actions: [.like(count: 12_400), .comments(count: 318), .share()])
                .frame(height: 520)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        },
    ])

    static let music = KitSection("Music", symbol: "music.note", [
        KitSample("Now playing", "Artwork that breathes while playing, waveform scrubber, ±15s, repeat, shuffle and a sleep timer.", code: """
        @State private var player = KitoAudioPlayerModel(tracks: tracks, systemControls: true)

        KitoAudioPlayer(model: player)
        """) {
            ModalStage { WithPlayer(systemControls: true) { KitoAudioPlayer(model: $0) } }
        },
        KitSample("Vinyl", "The same player with a spinning record that eases to a stop.", code: """
        KitoAudioPlayer(model: player, artworkStyle: .vinyl, tint: .orange)
        """) {
            ModalStage { WithPlayer(arrange: { Array($0.dropFirst()) + $0.prefix(1) }) { KitoAudioPlayer(model: $0, artworkStyle: .vinyl, tint: .orange) } }
        },
        KitSample("Mini player", "A floating bar that expands into the full player with matched geometry. Swipe down to close.", code: """
        LibraryView()
            .kitoMiniPlayer(player)          // tap or swipe up to expand
        """) {
            ModalStage { WithPlayer { LibraryScreen(model: $0) } }
        },
        KitSample("Queue, repeat and shuffle", "Previous restarts after three seconds; shuffle keeps the current track.", code: """
        player.cycleRepeatMode()   // off → all → one
        player.toggleShuffle()
        player.next()
        player.previous()
        ForEach(player.upNext) { track in QueueRow(track) }
        """) { WithPlayer { QueueCard(model: $0) } },
        KitSample("Sleep timer", "Counts down, fades the volume over the last five seconds, then pauses.", code: """
        KitoSleepTimerMenu(model: player)            // 5, 15, 30, 45, 60 min, end of track
        player.startSleepTimer(.minutes(15))
        Text(player.sleepTimerLabel ?? "Off")        // "14:32"
        """) { WithPlayer(arrange: { Array($0.suffix(1)) }) { SleepCard(model: $0) } },
    ])

    static let podcasts = KitSection("Podcasts", symbol: "mic.fill", [
        KitSample("Episode screen", "Waveform, speed chip, ±15s, sleep timer and live chapters.", code: """
        let episode = KitoAudioTrack(title: "Ep. 42", artist: "The Kito Show", url: episodeURL,
                                     chapters: [KitoChapter("Cold open", start: 0), KitoChapter("Guest", start: 12)])
        @State private var player = KitoAudioPlayerModel(tracks: [episode])

        KitoWaveformView(samples: player.waveform, progress: player.progress,
                         duration: player.duration) { player.seek(to: $0 * player.duration) }
        KitoPlaybackRateChip(model: player)
        KitoChapterList(model: player)
        """) { ModalStage { WithEpisode { EpisodeScreen(model: $0) } } },
        KitSample("Chapter list", "The playing chapter fills as it plays; tap any row to jump.", code: """
        KitoChapterList(model: player, tint: .teal)
        """) {
            WithEpisode { EpisodeChapters(model: $0) }
        },
        KitSample("Playback speed chip", "0.5× to 2×. Works with a model or any Float binding.", code: """
        @State private var rate: Float = 1
        KitoPlaybackRateChip(rate: $rate, tint: .orange)
        KitoPlaybackRateChip(model: player)
        """) { RateChipSample() },
    ])

    static let waveforms = KitSection("Waveforms", symbol: "waveform", [
        KitSample("Waveform scrubber", "Real peaks from a local file; drag to seek, with a time bubble.", code: """
        let peaks = try await KitoWaveformAnalyzer.peaks(of: fileURL, count: 96)

        KitoWaveformView(samples: peaks, progress: player.progress, duration: player.duration,
                         barWidth: 4, spacing: 3, tint: .pink) { fraction in
            player.seek(to: fraction * player.duration)
        }
        """) { WithPlayer(arrange: { Array($0.prefix(1)) }) { WaveformScrubber(model: $0) } },
        KitSample("Voice notes", "Chat bubbles that play in place.", code: """
        HStack {
            PlayButton(note)
            KitoWaveformView(samples: note.waveform, progress: note.progress,
                             barWidth: 2.5, tint: .white, trackColor: .white.opacity(0.3)) { note.seek(to: $0 * note.duration) }
            Text(KitoMediaTime.string(note.duration))
        }
        """) { VoiceNotes() },
        KitSample("Bar styles", "Deterministic placeholder bars for streams, in three widths. Drag them.", code: """
        KitoWaveformView(
            samples: KitoWaveformAnalyzer.placeholder(count: 80, seed: episode.id),
            progress: progress, barWidth: 6, spacing: 4, tint: .mint
        ) { progress = $0 }
        """) { BarStyles() },
    ])

    static let blocks = KitSection("Building blocks", symbol: "square.stack.3d.up.fill", [
        KitSample("Your own chrome", "Just the picture, driven by the same model.", code: """
        @State private var player = KitoVideoPlayerModel(url: videoURL, loops: true)

        ZStack(alignment: .bottom) {
            KitoVideoSurface(model: player, gravity: .fill)
            MyControls(player)          // player.togglePlayback(), player.progress, …
        }
        .task { player.prepare() }
        """) { CustomChrome() },
        KitSample("Time and speed labels", "Formatting helpers the players use.", code: """
        KitoMediaTime.string(7)                                         // "0:07"
        KitoMediaTime.string(3723)                                      // "1:02:03"
        KitoMediaTime.remainingString(currentTime: 10, duration: 202)   // "-3:12"
        KitoMediaTime.clamped(-5, duration: 60)                         // 0
        KitoPlaybackRate.label(1.5)                                     // "1.5×"
        """) { TimeFormats() },
    ])

    static let sections: [KitSection] = [video, social, music, podcasts, waveforms, blocks]
}

struct MediaPlayerGallery: View {
    static var count: Int { KitGallery.count(MediaPlayerSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Media Player",
            sections: MediaPlayerSamples.sections,
            footnote: "Requires `import KitoMediaPlayer`.",
            searchHint: "Try “reels”, “chapters”, “waveform”, “mini player” or “sleep”."
        )
    }
}
