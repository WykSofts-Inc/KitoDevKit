//
//  PhotoSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoPhotoEditor
import KitoButtons
import KitoFields
import KitoModals
import KitoMediaPicker

// MARK: - Shared pieces

@MainActor
private enum PhotoSource {
    static let sample = KitoSamplePhoto.make(size: CGSize(width: 900, height: 1200))
}

/// Renders an edit off the main thread and fades it in.
private struct RenderedPhoto: View {
    var source: UIImage = PhotoSource.sample
    let edit: KitoPhotoEdit
    var maxDimension: CGFloat = 400
    var contentMode: ContentMode = .fill
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color.primary.opacity(0.06)
            if let image {
                Image(uiImage: image).resizable().aspectRatio(contentMode: contentMode).transition(.opacity)
            }
        }
        .clipped()
        .animation(.easeOut(duration: 0.2), value: image)
        .task(id: RenderKey(edit: edit, size: maxDimension)) {
            let source = source, edit = edit, maxDimension = maxDimension
            image = await Task.detached(priority: .userInitiated) {
                KitoPhotoRenderer.render(source, edit: edit, maxDimension: maxDimension)
            }.value
        }
    }

    private struct RenderKey: Equatable { let edit: KitoPhotoEdit; let size: CGFloat }
}

private func makeEdit(_ filter: KitoPhotoFilter = .original, intensity: Double = 1, crop: KitoCropAspect = .original,
                  turns: Int = 0, flipped: Bool = false, _ adjust: (inout KitoPhotoAdjustments) -> Void = { _ in }) -> KitoPhotoEdit {
    var edit = KitoPhotoEdit()
    edit.filter = filter
    edit.intensity = intensity
    edit.crop = crop
    edit.quarterTurns = turns
    edit.isFlipped = flipped
    adjust(&edit.adjustments)
    return edit
}

/// A card that launches a full-screen experience.
private struct Launcher<Screen: View>: View {
    let title: String
    let message: String
    let systemImage: String
    var tint: Color = .black
    @ViewBuilder let screen: (_ close: @escaping () -> Void) -> Screen
    @State private var isOpen = false

    var body: some View {
        VStack(spacing: 18) {
            RenderedPhoto(edit: KitoPhotoEdit(), maxDimension: 500)
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    Image(systemName: systemImage).font(.system(size: 34, weight: .semibold)).foregroundStyle(.white)
                        .frame(width: 84, height: 84).background(.ultraThinMaterial, in: Circle())
                }
            VStack(spacing: 6) {
                Text(title).font(.title3.bold())
                Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            KitoButton(title, systemImage: systemImage) { isOpen = true }.fullWidth()
        }
        .fullScreenCover(isPresented: $isOpen) { screen { isOpen = false } }
    }
}

// MARK: - Publishing

/// What happens after editing: caption, audience, save or share, then post with progress.
private struct PostComposer: View {
    let photo: UIImage
    var onBack: () -> Void = {}
    var onPosted: () -> Void = {}

    enum Audience: String, CaseIterable { case everyone = "Everyone", friends = "Close friends", only = "Only me" }

    @State private var caption = ""
    @State private var audience: Audience = .everyone
    @State private var location = "Nairobi, Kenya"
    @State private var tagsPeople = false
    @State private var shareToStory = true
    @State private var progress: Double?
    @State private var alert: KitoAlert?
    @State private var savedMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 14) {
                        Image(uiImage: photo).resizable().scaledToFill().frame(width: 96, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay {
                                if let progress {
                                    ZStack {
                                        Color.black.opacity(0.45)
                                        Circle().stroke(.white.opacity(0.3), lineWidth: 4)
                                        Circle().trim(from: 0, to: progress).stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round)).rotationEffect(.degrees(-90))
                                        Text("\(Int(progress * 100))%").font(.caption.bold().monospacedDigit()).foregroundStyle(.white)
                                    }
                                    .padding(0)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                        KitoTextField("Caption", text: $caption, prompt: "Write a caption…")
                            .multiline(3...6)
                            .characterLimit(220, showsCounter: true)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Who can see this").font(.subheadline.weight(.semibold))
                        HStack(spacing: 8) {
                            ForEach(Audience.allCases, id: \.self) { item in
                                Button { withAnimation(.snappy) { audience = item } } label: {
                                    Text(item.rawValue).font(.subheadline.weight(.semibold)).padding(.horizontal, 14).padding(.vertical, 9)
                                        .background(Capsule().fill(audience == item ? Color.primary : Color.primary.opacity(0.07)))
                                        .foregroundStyle(audience == item ? Color(.systemBackground) : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(spacing: 0) {
                        row("mappin.and.ellipse", "Location", value: location)
                        Divider().padding(.leading, 44)
                        Toggle(isOn: $tagsPeople) { label("person.crop.square", "Tag people") }.padding(.vertical, 12)
                        Divider().padding(.leading, 44)
                        Toggle(isOn: $shareToStory) { label("circle.dashed.inset.filled", "Also share to your story") }.padding(.vertical, 12)
                    }
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.primary.opacity(0.05)))

                    HStack(spacing: 10) {
                        KitoButton("Save", systemImage: "arrow.down.to.line") {
                            do {
                                try await KitoMediaExporter.saveImageToPhotoLibrary(photo)
                                savedMessage = "Saved to Photos"
                            } catch {
                                savedMessage = "Couldn't save: allow Photos access in Settings."
                            }
                        }
                        .variant(.outlined).fullWidth()
                        ShareLink(item: Image(uiImage: photo), preview: SharePreview(caption.isEmpty ? "Photo" : caption, image: Image(uiImage: photo))) {
                            Label("Share", systemImage: "square.and.arrow.up").font(.headline).frame(maxWidth: .infinity).frame(height: 52)
                                .background(Capsule().stroke(Color.primary.opacity(0.2), lineWidth: 1.5))
                        }
                        .buttonStyle(.plain)
                    }
                    if let savedMessage {
                        Label(savedMessage, systemImage: "checkmark.circle.fill").font(.footnote).foregroundStyle(.secondary).transition(.opacity)
                    }
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                KitoButton(progress == nil ? "Post" : "Posting…", systemImage: "paperplane.fill") { await post() }
                    .fullWidth()
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(.bar)
            }
            .navigationTitle("New post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button { onBack() } label: { Image(systemName: "chevron.left") }.accessibilityLabel("Back to editing") }
            }
            .kitoAlert($alert)
        }
    }

    private func label(_ symbol: String, _ title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol).frame(width: 30)
            Text(title)
        }
    }

    private func row(_ symbol: String, _ title: String, value: String) -> some View {
        HStack {
            label(symbol, title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
        }
        .padding(.vertical, 14)
    }

    private func post() async {
        for step in 0...20 {
            withAnimation(.linear(duration: 0.07)) { progress = Double(step) / 20 }
            try? await Task.sleep(nanoseconds: 70_000_000)
        }
        progress = nil
        alert = KitoAlert(systemImage: "checkmark.seal.fill", tint: .green, title: "Posted!",
                          message: audience == .everyone ? "Your photo is live for everyone\(shareToStory ? " and on your story" : "")." : "Shared with \(audience.rawValue.lowercased()).",
                          actions: [KitoAlertAction("Done") { onPosted() }], celebrates: true)
    }
}

/// Camera, editor, then the composer: the whole take-edit-publish journey.
private struct CameraToPost: View {
    let close: () -> Void
    @State private var edited: UIImage?

    var body: some View {
        ZStack {
            if let edited {
                PostComposer(photo: edited, onBack: { withAnimation { self.edited = nil } }, onPosted: close)
                    .transition(.move(edge: .trailing))
            } else {
                KitoPhotoFlow(onFinish: { image in withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) { edited = image } }, onCancel: close)
                    .transition(.move(edge: .leading))
            }
        }
    }
}

/// A feed post with a double-tap heart.
private struct FeedCard: View {
    let edit: KitoPhotoEdit
    var author = "Wycliff N"
    var place = "Lake Naivasha"
    var caption = "Golden hour never misses."
    @State private var liked = false
    @State private var burst = 0
    @State private var likes = 1_284

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle().fill(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)
                    .overlay(Text("WN").font(.caption.bold()).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 1) {
                    Text(author).font(.subheadline.bold())
                    Text(place).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "ellipsis")
            }
            RenderedPhoto(edit: edit, maxDimension: 700)
                .aspectRatio(4 / 5, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    Image(systemName: "heart.fill").font(.system(size: 90)).foregroundStyle(.white).shadow(radius: 10)
                        .keyframeAnimator(initialValue: HeartPop(), trigger: burst) { view, value in
                            view.scaleEffect(value.scale).opacity(value.opacity)
                        } keyframes: { _ in
                            KeyframeTrack(\.scale) {
                                CubicKeyframe(0.2, duration: 0.01)
                                SpringKeyframe(1.15, duration: 0.25, spring: .bouncy)
                                SpringKeyframe(1, duration: 0.2)
                                CubicKeyframe(1.3, duration: 0.25)
                            }
                            KeyframeTrack(\.opacity) {
                                LinearKeyframe(burst == 0 ? 0 : 1, duration: 0.01)
                                LinearKeyframe(burst == 0 ? 0 : 1, duration: 0.45)
                                LinearKeyframe(0, duration: 0.25)
                            }
                        }
                        .allowsHitTesting(false)
                }
                .onTapGesture(count: 2) {
                    if !liked { liked = true; likes += 1 }
                    burst += 1
                }
            HStack(spacing: 18) {
                Button {
                    liked.toggle(); likes += liked ? 1 : -1
                } label: {
                    Image(systemName: liked ? "heart.fill" : "heart").foregroundStyle(liked ? .red : .primary)
                        .symbolEffect(.bounce, value: liked)
                }
                .accessibilityLabel(liked ? "Unlike" : "Like")
                Image(systemName: "bubble.right")
                Image(systemName: "paperplane")
                Spacer()
                Image(systemName: "bookmark")
            }
            .font(.title3)
            .buttonStyle(.plain)
            Text("\(likes.formatted()) likes").font(.subheadline.bold()).contentTransition(.numericText(value: Double(likes)))
                .animation(.snappy, value: likes)
            (Text(author).bold() + Text("  ") + Text(caption)).font(.subheadline)
        }
    }

    private struct HeartPop { var scale: CGFloat = 0; var opacity: Double = 0 }
}

// MARK: - Filters

private struct FilterGrid: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 14) {
            ForEach(KitoPhotoFilter.allCases) { filter in
                VStack(spacing: 6) {
                    RenderedPhoto(edit: makeEdit(filter, crop: .square), maxDimension: 240)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Text(filter.name).font(.caption.weight(.semibold))
                }
            }
        }
    }
}

/// Drag the divider to compare the original with a filter.
private struct BeforeAfter: View {
    @State private var filter: KitoPhotoFilter = .chrome
    @State private var split: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 14) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RenderedPhoto(edit: makeEdit(filter), maxDimension: 700)
                    RenderedPhoto(edit: KitoPhotoEdit(), maxDimension: 700)
                        .mask(alignment: .leading) { Rectangle().frame(width: geometry.size.width * split) }
                    Rectangle().fill(.white).frame(width: 3).shadow(radius: 3)
                        .overlay(Image(systemName: "arrow.left.and.right").font(.caption.bold()).foregroundStyle(.black)
                            .frame(width: 34, height: 34).background(Circle().fill(.white)))
                        .offset(x: geometry.size.width * split - 1.5)
                    HStack {
                        tag("Before")
                        Spacer()
                        tag(filter.name)
                    }
                    .padding(10)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { split = min(max($0.location.x / geometry.size.width, 0), 1) })
            }
            .aspectRatio(3 / 4, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .accessibilityElement()
            .accessibilityLabel("Before and after comparison")
            .accessibilityValue("\(Int(split * 100)) percent original")
            .accessibilityAdjustableAction { direction in
                split = min(max(split + (direction == .increment ? 0.1 : -0.1), 0), 1)
            }
            Picker("Filter", selection: $filter) {
                ForEach(KitoPhotoFilter.allCases.dropFirst()) { Text($0.name).tag($0) }
            }
            .pickerStyle(.menu)
        }
    }

    private func tag(_ text: String) -> some View {
        Text(text).font(.caption.bold()).foregroundStyle(.white).padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(.black.opacity(0.55)))
    }
}

private struct IntensitySteps: View {
    var body: some View {
        HStack(spacing: 6) {
            ForEach([0, 0.25, 0.5, 0.75, 1.0], id: \.self) { amount in
                VStack(spacing: 6) {
                    RenderedPhoto(edit: makeEdit(.noir, intensity: amount, crop: .portrait), maxDimension: 200)
                        .aspectRatio(4 / 5, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text("\(Int(amount * 100))%").font(.caption2.monospacedDigit().weight(.semibold))
                }
            }
        }
    }
}

private struct Preset: Identifiable {
    let name: String
    let edit: KitoPhotoEdit
    var id: String { name }

    static let all: [Preset] = [
        Preset(name: "Golden hour", edit: makeEdit(.warm, intensity: 0.7) { $0.contrast = 0.2; $0.vignette = 0.5; $0.warmth = 0.3 }),
        Preset(name: "Moody", edit: makeEdit(.fade) { $0.exposure = -0.25; $0.contrast = 0.35; $0.grain = 0.6; $0.vignette = 0.7 }),
        Preset(name: "Clean", edit: makeEdit { $0.exposure = 0.2; $0.saturation = 0.15; $0.sharpness = 0.6 }),
        Preset(name: "Retro", edit: makeEdit(.film) { $0.warmth = 0.4; $0.grain = 0.8; $0.saturation = -0.2 }),
        Preset(name: "Cinematic", edit: makeEdit(.dramatic, crop: .landscape) { $0.warmth = -0.25; $0.contrast = 0.2 }),
        Preset(name: "Arctic", edit: makeEdit(.cool) { $0.exposure = 0.3; $0.saturation = -0.35 }),
    ]
}

private struct PresetStrip: View {
    @State private var selected = Preset.all[0]

    var body: some View {
        VStack(spacing: 14) {
            RenderedPhoto(edit: selected.edit, maxDimension: 700, contentMode: .fit)
                .frame(height: 360)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Preset.all) { preset in
                        Button { withAnimation(.snappy) { selected = preset } } label: {
                            VStack(spacing: 6) {
                                RenderedPhoto(edit: preset.edit, maxDimension: 160)
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(selected.id == preset.id ? Color.primary : .clear, lineWidth: 2.5))
                                Text(preset.name).font(.caption2.weight(selected.id == preset.id ? .bold : .regular))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Adjust

private struct LiveAdjust: View {
    @State private var photoEdit = KitoPhotoEdit()

    private let controls: [(String, WritableKeyPath<KitoPhotoAdjustments, Double>, ClosedRange<Double>)] = [
        ("Exposure", \.exposure, -1...1), ("Brightness", \.brightness, -1...1), ("Contrast", \.contrast, -1...1),
        ("Saturation", \.saturation, -1...1), ("Warmth", \.warmth, -1...1), ("Vignette", \.vignette, 0...1),
        ("Sharpness", \.sharpness, 0...1), ("Grain", \.grain, 0...1),
    ]

    var body: some View {
        VStack(spacing: 14) {
            RenderedPhoto(edit: photoEdit, maxDimension: 500, contentMode: .fit)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            ForEach(controls, id: \.0) { name, keyPath, range in
                HStack {
                    Text(name).font(.caption.weight(.semibold)).frame(width: 78, alignment: .leading)
                    Slider(value: Binding(get: { photoEdit.adjustments[keyPath: keyPath] }, set: { photoEdit.adjustments[keyPath: keyPath] = $0 }), in: range)
                        .tint(.primary)
                    Text("\(Int((photoEdit.adjustments[keyPath: keyPath] * 100).rounded()))").font(.caption.monospacedDigit()).frame(width: 34, alignment: .trailing)
                }
            }
            Button("Reset") { withAnimation { photoEdit = KitoPhotoEdit() } }
                .font(.subheadline.weight(.semibold))
                .disabled(photoEdit == KitoPhotoEdit())
        }
    }
}

private struct EveryAdjustment: View {
    private let items: [(String, KitoPhotoEdit)] = [
        ("Exposure +", makeEdit { $0.exposure = 0.8 }), ("Exposure −", makeEdit { $0.exposure = -0.8 }),
        ("Contrast", makeEdit { $0.contrast = 1 }), ("Saturation", makeEdit { $0.saturation = 1 }),
        ("Desaturate", makeEdit { $0.saturation = -1 }), ("Warm", makeEdit { $0.warmth = 1 }),
        ("Cool", makeEdit { $0.warmth = -1 }), ("Vignette", makeEdit { $0.vignette = 1 }),
        ("Grain", makeEdit { $0.grain = 1 }),
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 14) {
            ForEach(items, id: \.0) { name, photoEdit in
                VStack(spacing: 6) {
                    RenderedPhoto(edit: photoEdit, maxDimension: 240).aspectRatio(3 / 4, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Text(name).font(.caption.weight(.semibold))
                }
            }
        }
    }
}

// MARK: - Crop

private struct AspectRatios: View {
    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .bottom, spacing: 10) {
                ForEach([KitoCropAspect.story, .portrait, .square]) { aspect in cell(aspect) }
            }
            HStack(alignment: .bottom, spacing: 10) {
                ForEach([KitoCropAspect.original, .landscape]) { aspect in cell(aspect) }
            }
        }
    }

    private func cell(_ aspect: KitoCropAspect) -> some View {
        VStack(spacing: 6) {
            RenderedPhoto(edit: makeEdit(crop: aspect), maxDimension: 300, contentMode: .fit)
                .aspectRatio(aspect.ratio ?? 3 / 4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(aspect.name).font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct RotateAndFlip: View {
    @State private var turns = 0
    @State private var flipped = false

    var body: some View {
        VStack(spacing: 16) {
            RenderedPhoto(edit: makeEdit(turns: turns, flipped: flipped), maxDimension: 500, contentMode: .fit)
                .frame(height: 300)
            HStack(spacing: 12) {
                KitoButton("Left", systemImage: "rotate.left") { turns = (turns + 3) % 4 }.variant(.outlined).fullWidth()
                KitoButton("Right", systemImage: "rotate.right") { turns = (turns + 1) % 4 }.variant(.outlined).fullWidth()
                KitoButton("Flip", systemImage: "arrow.left.and.right") { flipped.toggle() }.variant(flipped ? .primary : .outlined).fullWidth()
            }
            Text("\(turns * 90)°\(flipped ? " · mirrored" : "")").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Publish

private struct ProfileGrid: View {
    @State private var posts: [KitoPhotoEdit] = [Preset.all[0].edit, Preset.all[1].edit, Preset.all[3].edit, Preset.all[5].edit, makeEdit(.mono), makeEdit(.instant)]
    @State private var isAdding = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 18) {
                Circle().fill(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 72).overlay(Text("WN").font(.title3.bold()).foregroundStyle(.white))
                stat(posts.count, "Posts"); stat(12_400, "Followers"); stat(318, "Following")
            }
            KitoButton("New post", systemImage: "plus") { isAdding = true }.fullWidth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                ForEach(Array(posts.enumerated()), id: \.offset) { _, post in
                    RenderedPhoto(edit: post, maxDimension: 240).aspectRatio(1, contentMode: .fit)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .fullScreenCover(isPresented: $isAdding) {
            KitoPhotoEditorView(image: PhotoSource.sample, onCancel: { isAdding = false }) { _ in
                isAdding = false
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { posts.insert(Preset.all[Int.random(in: 0..<Preset.all.count)].edit, at: 0) }
            }
        }
    }

    private func stat(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value.formatted(.number.notation(.compactName))).font(.headline).contentTransition(.numericText(value: Double(value)))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StoryPublish: View {
    @State private var sent: String?

    var body: some View {
        VStack(spacing: 16) {
            RenderedPhoto(edit: makeEdit(.vivid, crop: .story), maxDimension: 600)
                .aspectRatio(9 / 16, contentMode: .fit)
                .frame(height: 440)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(alignment: .top) {
                    Capsule().fill(.white.opacity(0.4)).frame(height: 3)
                        .overlay(alignment: .leading) { Capsule().fill(.white).frame(width: sent == nil ? 0 : nil) }
                        .padding(12)
                        .animation(.linear(duration: 2), value: sent)
                }
                .overlay(alignment: .bottom) {
                    Text("Weekend by the lake ☀️").font(.title3.bold()).foregroundStyle(.white).shadow(radius: 6).padding(.bottom, 40)
                }
            HStack(spacing: 10) {
                KitoButton("Your story", systemImage: "circle.dashed") { try await Task.sleep(nanoseconds: 700_000_000); sent = "Shared to your story" }.fullWidth()
                KitoButton("Close friends", systemImage: "star.circle.fill") { try await Task.sleep(nanoseconds: 700_000_000); sent = "Shared with close friends" }.variant(.tonal).fullWidth()
            }
            if let sent { Label(sent, systemImage: "checkmark.circle.fill").font(.footnote.weight(.semibold)).foregroundStyle(.green) }
        }
    }
}

private struct CameraOnly: View {
    @State private var isOpen = false
    @State private var shots: [UIImage] = []

    var body: some View {
        VStack(spacing: 16) {
            KitoButton("Open camera", systemImage: "camera.fill") { isOpen = true }.fullWidth()
            if shots.isEmpty {
                Text("Photos you take appear here.").font(.subheadline).foregroundStyle(.secondary).frame(height: 90)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(shots.enumerated()), id: \.offset) { _, shot in
                            Image(uiImage: shot).resizable().scaledToFill().frame(width: 90, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isOpen) {
            KitoCameraView(onCapture: { image in
                withAnimation(.snappy) { shots.insert(image, at: 0) }
                isOpen = false
            }, onCancel: { isOpen = false })
        }
    }
}

// MARK: - Catalogue

enum PhotoSamples {
    static let capture = KitSection("Capture & publish", symbol: "camera.fill", [
        KitSample("Camera to post", "Take a photo, filter and edit it, write a caption and post it.", code: """
        KitoPhotoFlow { edited in
            composer = PostComposer(photo: edited)   // caption, audience, save, share, post
        } onCancel: { dismiss() }
        """) {
            Launcher(title: "Camera to post", message: "The whole journey. In the simulator, tap “Use a sample photo”.", systemImage: "camera.fill") { close in
                CameraToPost(close: close)
            }
        },
        KitSample("Editor", "Filters, adjustments, crop, rotate, text; hold the photo to compare.", code: """
        KitoPhotoEditorView(image: photo, onCancel: { dismiss() }) { edited in
            save(edited)
        }
        """) {
            Launcher(title: "Edit a photo", message: "Starts from a sample photo.", systemImage: "wand.and.stars") { close in
                KitoPhotoEditorView(image: PhotoSource.sample, onCancel: close) { _ in close() }
            }
        },
        KitSample("Camera", "Flash, .5×/1×/2× zoom, flip, grid and a shutter flash.", code: """
        KitoCameraView(onCapture: { photo in shots.insert(photo, at: 0) }, onCancel: { dismiss() })
        """) { CameraOnly() },
    ])

    static let filters = KitSection("Filters", symbol: "camera.filters", [
        KitSample("Every filter", "Twelve looks, from Vivid to Film.", code: """
        var edit = KitoPhotoEdit()
        edit.filter = .chrome
        let result = KitoPhotoRenderer.render(photo, edit: edit)
        """) { FilterGrid() },
        KitSample("Before and after", "Drag the divider to compare.", code: """
        ZStack(alignment: .leading) {
            Image(uiImage: KitoPhotoRenderer.render(photo, edit: edit)!)
            Image(uiImage: photo).mask(alignment: .leading) { Rectangle().frame(width: width * split) }
        }
        """) { BeforeAfter() },
        KitSample("Intensity", "The same filter from 0 to 100%.", code: """
        edit.filter = .noir
        edit.intensity = 0.5
        """) { IntensitySteps() },
        KitSample("Presets", "Filters plus adjustments, saved as one look.", code: """
        var goldenHour = KitoPhotoEdit()
        goldenHour.filter = .warm
        goldenHour.intensity = 0.7
        goldenHour.adjustments.contrast = 0.2
        goldenHour.adjustments.vignette = 0.5
        """) { PresetStrip() },
    ])

    static let adjust = KitSection("Adjust", symbol: "slider.horizontal.3", [
        KitSample("Live adjustments", "Eight sliders, rendered off the main thread as you drag.", code: """
        edit.adjustments.exposure = 0.2      // -1…1
        edit.adjustments.warmth = 0.3        // -1 cool … 1 warm
        edit.adjustments.vignette = 0.5      // 0…1
        edit.adjustments.grain = 0.4         // 0…1
        """) { LiveAdjust() },
        KitSample("Every adjustment", "Each one pushed to its limit.", code: """
        edit.adjustments.saturation = -1     // black and white
        """) { EveryAdjustment() },
    ])

    static let crop = KitSection("Crop & rotate", symbol: "crop.rotate", [
        KitSample("Aspect ratios", "Original, 1:1, 4:5, 16:9 and 9:16, centred.", code: """
        edit.crop = .portrait       // .original, .square, .portrait, .landscape, .story
        """) { AspectRatios() },
        KitSample("Rotate and flip", "Quarter turns and a mirror.", code: """
        edit.quarterTurns = 1       // clockwise
        edit.isFlipped = true
        """) { RotateAndFlip() },
    ])

    static let publish = KitSection("Publish", symbol: "paperplane.fill", [
        KitSample("Post composer", "Caption, audience, location, save to Photos, share and post with progress.", code: """
        KitoTextField("Caption", text: $caption, prompt: "Write a caption…")
            .multiline(3...6)
            .characterLimit(220, showsCounter: true)
        KitoButton("Save", systemImage: "arrow.down.to.line") {
            try await KitoMediaExporter.saveImageToPhotoLibrary(photo)
        }
        KitoButton("Post", systemImage: "paperplane.fill") { await upload() }
        """) {
            Launcher(title: "Write a post", message: "Opens the composer with an edited sample.", systemImage: "square.and.pencil") { close in
                PostComposer(photo: KitoPhotoRenderer.render(PhotoSource.sample, edit: Preset.all[0].edit) ?? PhotoSource.sample, onBack: close, onPosted: close)
            }
        },
        KitSample("Feed post", "Double-tap the photo for a heart; the count rolls.", code: """
        photo.onTapGesture(count: 2) { liked = true; burst += 1 }
            .overlay { Heart().keyframeAnimator(initialValue: Pop(), trigger: burst) { … } }
        """) { FeedCard(edit: Preset.all[0].edit) },
        KitSample("Story", "9:16, a progress bar and two audiences.", code: """
        edit.crop = .story
        """) { StoryPublish() },
        KitSample("Profile grid", "New posts slide into your grid.", code: """
        KitoPhotoEditorView(image: photo) { edited in
            withAnimation(.spring) { posts.insert(edited, at: 0) }
        }
        """) { ProfileGrid() },
    ])

    static let sections: [KitSection] = [capture, filters, adjust, crop, publish]
}

struct PhotoGallery: View {
    static var count: Int { KitGallery.count(PhotoSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Photo Editor",
            sections: PhotoSamples.sections,
            footnote: "Requires `import KitoPhotoEditor`. The composer also uses KitoFields, KitoButtons, KitoModals and KitoMediaPicker.",
            searchHint: "Try “camera”, “filter”, “crop”, “story” or “post”."
        )
    }
}
