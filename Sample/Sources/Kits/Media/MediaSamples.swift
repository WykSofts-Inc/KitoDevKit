//
//  MediaSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoMediaPicker
import KitoFields
import KitoButtons

// MARK: - Avatars

private struct AvatarSample: View {
    var shape: KitoAvatarShape = .circle
    var badge: KitoAvatarBadge = .edit
    var ring: [Color]?
    var size: CGFloat = 132
    @State private var picker = KitoMediaPickerViewModel()

    var body: some View {
        VStack(spacing: 14) {
            KitoAvatarPicker(viewModel: picker, size: size, shape: shape, badge: badge, ring: ring)
            if let asset = picker.asset {
                Text("From \(asset.source.label.lowercased())").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Button("Remove photo", role: .destructive) { withAnimation { picker.clear() } }.font(.caption)
            } else {
                Text("Tap to choose a photo").font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct AvatarSizesSample: View {
    @State private var picker = KitoMediaPickerViewModel()

    var body: some View {
        HStack(alignment: .bottom, spacing: 18) {
            ForEach([44.0, 64, 88, 120], id: \.self) { size in
                KitoAvatarPicker(viewModel: picker, size: size, badge: size < 60 ? .none : .edit)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// A profile header: a cover photo you can change, an avatar overlapping it, name and handle.
private struct ProfileHeaderSample: View {
    @State private var cover = KitoMediaPickerViewModel(sources: [.photoLibrary, .camera, .url])
    @State private var avatar = KitoMediaPickerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let image = cover.asset?.image {
                        image.resizable().scaledToFill()
                    } else {
                        LinearGradient(colors: [.indigo, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                Button { cover.isShowingSourceMenu = true } label: {
                    Label("Edit cover", systemImage: "camera.fill").font(.caption.weight(.semibold))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(12)
                .kitoMediaSourceSheet(cover, title: "Cover photo")
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            KitoAvatarPicker(viewModel: avatar, size: 96, badge: .camera, ring: [.orange, .pink, .purple])
                .offset(y: -48)
                .padding(.bottom, -40)
            Text("Amina Mwangi").font(.title3.bold())
            Text("@amina · Nairobi").font(.subheadline).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Uploads

private struct DropZoneSample: View {
    var title = "Upload a file"
    var subtitle = "PNG, JPG or PDF, up to 10 MB"
    var systemImage = "arrow.up.doc"
    @State private var picker = KitoMediaPickerViewModel(sources: [.photoLibrary, .camera, .files])

    var body: some View {
        KitoMediaDropZone(viewModel: picker, title: title, subtitle: subtitle, systemImage: systemImage)
    }
}

/// Identity verification: front, back and a selfie, with a Continue button once all three exist.
private struct KYCSample: View {
    @State private var front = KitoMediaPickerViewModel(sources: [.camera, .photoLibrary, .files])
    @State private var back = KitoMediaPickerViewModel(sources: [.camera, .photoLibrary, .files])
    @State private var selfie = KitoMediaPickerViewModel(sources: [.camera, .photoLibrary])

    private var done: Int { [front.asset, back.asset, selfie.asset].compactMap { $0 }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Verify your identity").font(.headline)
                Spacer()
                Text("\(done) of 3").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
            }
            ProgressView(value: Double(done), total: 3).tint(done == 3 ? .green : .primary)
            KitoMediaDropZone(viewModel: front, title: "Front of ID", subtitle: "All four corners visible", systemImage: "person.text.rectangle", height: 130)
            KitoMediaDropZone(viewModel: back, title: "Back of ID", subtitle: "Make sure it's in focus", systemImage: "rectangle.on.rectangle", height: 130)
            HStack(spacing: 16) {
                KitoAvatarPicker(viewModel: selfie, size: 72, placeholderSystemImage: "face.smiling", badge: .camera)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Selfie").font(.subheadline.weight(.semibold))
                    Text("Good light, no glasses").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            KitoButton("Continue") { try await Task.sleep(nanoseconds: 800_000_000) }
                .fullWidth()
                .disabled(done < 3)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: done)
    }
}

// MARK: - Several at once

private struct GridSample: View {
    var limit = 6
    var columns = 3
    @State private var collection: KitoMediaCollectionViewModel

    init(limit: Int = 6, columns: Int = 3) {
        self.limit = limit
        self.columns = columns
        _collection = State(initialValue: KitoMediaCollectionViewModel(limit: limit))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KitoMediaGrid(viewModel: collection, columns: columns)
            Text(collection.items.isEmpty ? "Tap + to pick up to \(limit) photos at once." : "Long-press a photo to make it the cover or remove it.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

/// A listing form: photos, title, price, description and a Publish button.
private struct ListingSample: View {
    @State private var photos = KitoMediaCollectionViewModel(limit: 8)
    @State private var title = ""
    @State private var price = ""
    @State private var details = ""

    private var canPublish: Bool { !photos.items.isEmpty && title.count >= 3 && !price.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Photos").font(.headline)
            KitoMediaGrid(viewModel: photos, columns: 4)
            KitoTextField("Title", text: $title, prompt: "Leather weekend bag").required().validation(.minLength(3))
            KitoCurrencyField("Price", text: $price, currencyCode: "KES")
            KitoTextArea("Description", text: $details, prompt: "Condition, size, what's included", lines: 3...6, limit: 300)
            KitoButton("Publish listing", systemImage: "paperplane.fill") { try await Task.sleep(nanoseconds: 1_000_000_000) }
                .fullWidth()
                .disabled(!canPublish)
        }
    }
}

/// A message composer with an attachments strip above the text field.
private struct ComposerSample: View {
    @State private var attachments = KitoMediaCollectionViewModel(limit: 10)
    @State private var message = ""
    @State private var sent: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(sent, id: \.self) { text in
                Text(text).padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Capsule().fill(Color.accentColor.opacity(0.18)))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            KitoAttachmentStrip(viewModel: attachments)
            HStack(spacing: 10) {
                TextField("Message", text: $message, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.primary.opacity(0.06)))
                Button {
                    let count = attachments.items.count
                    sent.append(message.isEmpty ? "\(count) photo\(count == 1 ? "" : "s")" : message)
                    message = ""
                    withAnimation { attachments.clear() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 32))
                }
                .disabled(message.isEmpty && attachments.items.isEmpty)
            }
        }
    }
}

// MARK: - Sources

private struct SourceStyleSample: View {
    let useSheet: Bool
    var sources: [KitoMediaSource] = KitoMediaSource.allCases
    @State private var picker: KitoMediaPickerViewModel

    init(useSheet: Bool, sources: [KitoMediaSource] = KitoMediaSource.allCases) {
        self.useSheet = useSheet
        self.sources = sources
        _picker = State(initialValue: KitoMediaPickerViewModel(sources: sources))
    }

    var body: some View {
        VStack(spacing: 14) {
            PickedPreview(picker: picker)
            if useSheet {
                KitoButton("Add a photo", systemImage: "plus") { picker.isShowingSourceMenu = true }.variant(.tonal)
                    .kitoMediaSourceSheet(picker)
            } else {
                KitoButton("Add a photo", systemImage: "plus") { picker.isShowingSourceMenu = true }.variant(.tonal)
                    .kitoMediaSourceMenu(picker)
            }
            Text("Offered: \(picker.availableSources.map(\.label).joined(separator: ", "))").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ClipboardSample: View {
    @State private var picker = KitoMediaPickerViewModel(sources: [.clipboard])

    var body: some View {
        VStack(spacing: 14) {
            PickedPreview(picker: picker)
            KitoButton("Paste image", systemImage: "doc.on.clipboard") { picker.pasteFromClipboard() }.variant(.tonal)
            Text("Copy an image in Photos or Safari, then paste.").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct URLSample: View {
    @State private var picker = KitoMediaPickerViewModel(sources: [.url])
    @State private var address = "https://picsum.photos/seed/kito-media/600/400"

    var body: some View {
        VStack(spacing: 14) {
            PickedPreview(picker: picker)
            KitoTextField("Image URL", text: $address).keyboard(.url).autocapitalization(.never)
            KitoButton("Download", systemImage: "arrow.down.circle") {
                guard let url = URL(string: address) else { return }
                await picker.downloadFromURL(url)
            }
            .fullWidth()
        }
    }
}

private struct ExportSample: View {
    @State private var picker = KitoMediaPickerViewModel(sources: [.photoLibrary, .clipboard])
    @State private var isExporting = false
    @State private var isSharing = false
    @State private var status = ""

    var body: some View {
        VStack(spacing: 14) {
            KitoAvatarPicker(viewModel: picker, size: 110, shape: .squircle, badge: .plus)
            HStack(spacing: 10) {
                KitoButton("Photos", systemImage: "square.and.arrow.down") {
                    guard let data = picker.asset?.data else { status = "Pick an image first"; return }
                    try await KitoMediaExporter.saveImageDataToPhotoLibrary(data)
                    status = "Saved to Photos"
                }
                .variant(.tonal).size(.small)
                KitoButton("Files", systemImage: "folder") { isExporting = picker.asset != nil; if picker.asset == nil { status = "Pick an image first" } }
                    .variant(.tonal).size(.small)
                KitoButton("Share", systemImage: "square.and.arrow.up") { isSharing = picker.asset != nil; if picker.asset == nil { status = "Pick an image first" } }
                    .variant(.tonal).size(.small)
            }
            if !status.isEmpty { Text(status).font(.caption).foregroundStyle(.secondary) }
        }
        .frame(maxWidth: .infinity)
        .kitoFileExporter(isPresented: $isExporting, data: picker.asset?.data ?? Data(), contentType: .image, defaultFileName: "photo.jpg") { result in
            if case .failure(let error) = result { status = error.localizedDescription } else { status = "Exported to Files" }
        }
        .kitoShareSheet(isPresented: $isSharing, items: picker.asset?.data.map { [$0] } ?? [])
    }
}

/// What a picker currently holds: an image, a document, a spinner or an error.
private struct PickedPreview: View {
    let picker: KitoMediaPickerViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.primary.opacity(0.05))
            switch picker.state {
            case .idle:
                Image(systemName: "photo").font(.largeTitle).foregroundStyle(.tertiary)
            case .loading:
                ProgressView()
            case .loaded(let asset):
                if let image = asset.image {
                    image.resizable().scaledToFill().transition(.opacity)
                } else {
                    Label(asset.fileName ?? "File", systemImage: "doc.fill").font(.subheadline)
                }
            case .failed(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle.fill").font(.subheadline).foregroundStyle(.red).padding()
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .animation(.easeOut(duration: 0.3), value: picker.asset?.fileName)
    }
}

// MARK: - Catalog

enum MediaSamples {
    static let sections: [KitSection] = [avatars, uploads, multiple, sources]

    static let avatars = KitSection("Avatars", symbol: "person.crop.circle", [
        KitSample("Circle avatar", "Tap to choose from any source.", code: "KitoAvatarPicker(viewModel: picker, size: 132)") { AvatarSample() },
        KitSample("Squircle", "Continuous corners, like an app icon.", code: "KitoAvatarPicker(viewModel: picker, shape: .squircle)") { AvatarSample(shape: .squircle) },
        KitSample("Rounded square", "For businesses and groups.", code: "KitoAvatarPicker(viewModel: picker, shape: .roundedSquare, badge: .camera)") { AvatarSample(shape: .roundedSquare, badge: .camera) },
        KitSample("Story ring", "A gradient ring around the photo.", code: "KitoAvatarPicker(viewModel: picker, badge: .plus,\n                 ring: [.orange, .pink, .purple])") { AvatarSample(badge: .plus, ring: [.orange, .pink, .purple]) },
        KitSample("No badge", "Just the photo.", code: "KitoAvatarPicker(viewModel: picker, badge: .none)") { AvatarSample(badge: .none) },
        KitSample("Sizes", "44 to 120 points, badge hidden when tiny.", code: "KitoAvatarPicker(viewModel: picker, size: 44, badge: .none)") { AvatarSizesSample() },
        KitSample("Profile header", "Cover photo, overlapping avatar, name.", code: """
        KitoAvatarPicker(viewModel: avatar, size: 96, badge: .camera, ring: [.orange, .pink, .purple])
            .offset(y: -48)

        Button("Edit cover") { cover.isShowingSourceMenu = true }
            .kitoMediaSourceSheet(cover, title: "Cover photo")
        """) { ProfileHeaderSample() },
    ])

    static let uploads = KitSection("Uploads", symbol: "arrow.up.doc", [
        KitSample("Drop zone", "Tap to choose, or drop a file on it; shows name and size.", code: "KitoMediaDropZone(viewModel: picker,\n                  title: \"Upload a file\",\n                  subtitle: \"PNG, JPG or PDF, up to 10 MB\")") { DropZoneSample() },
        KitSample("Receipt upload", "A focused title and icon.", code: "KitoMediaDropZone(viewModel: picker, title: \"Add a receipt\", systemImage: \"doc.text.viewfinder\")") {
            DropZoneSample(title: "Add a receipt", subtitle: "Photo or PDF", systemImage: "doc.text.viewfinder")
        },
        KitSample("Identity verification", "ID front, back and a selfie, with progress.", code: """
        KitoMediaDropZone(viewModel: front, title: "Front of ID", systemImage: "person.text.rectangle")
        KitoMediaDropZone(viewModel: back, title: "Back of ID")
        KitoAvatarPicker(viewModel: selfie, placeholderSystemImage: "face.smiling", badge: .camera)
        """) { KYCSample() },
    ])

    static let multiple = KitSection("Several at once", symbol: "square.grid.3x3", [
        KitSample("Photo grid", "Pick up to six at once; the first is the cover.", code: "@State private var photos = KitoMediaCollectionViewModel(limit: 6)\n\nKitoMediaGrid(viewModel: photos, columns: 3)") { GridSample() },
        KitSample("Two-column gallery", "Bigger tiles, up to four.", code: "KitoMediaGrid(viewModel: KitoMediaCollectionViewModel(limit: 4), columns: 2)") { GridSample(limit: 4, columns: 2) },
        KitSample("Create a listing", "Photos with KitoFields and a KitoButton.", code: """
        KitoMediaGrid(viewModel: photos, columns: 4)
        KitoTextField("Title", text: $title).required()
        KitoCurrencyField("Price", text: $price, currencyCode: "KES")
        KitoButton("Publish listing") { … }.disabled(!canPublish)
        """) { ListingSample() },
        KitSample("Message attachments", "A strip above the composer.", code: "KitoAttachmentStrip(viewModel: attachments)") { ComposerSample() },
    ])

    static let sources = KitSection("Sources", symbol: "tray.and.arrow.down", [
        KitSample("Action sheet", "The system menu of sources.", code: "Button(\"Add a photo\") { picker.isShowingSourceMenu = true }\n    .kitoMediaSourceMenu(picker)") { SourceStyleSample(useSheet: false) },
        KitSample("Tile sheet", "Large source tiles in a short sheet.", code: "Button(\"Add a photo\") { picker.isShowingSourceMenu = true }\n    .kitoMediaSourceSheet(picker)") { SourceStyleSample(useSheet: true) },
        KitSample("Only some sources", "Library and Files: no camera, no URL.", code: "KitoMediaPickerViewModel(sources: [.photoLibrary, .files])") { SourceStyleSample(useSheet: true, sources: [.photoLibrary, .files]) },
        KitSample("Paste", "Straight from the clipboard.", code: "picker.pasteFromClipboard()") { ClipboardSample() },
        KitSample("Download a URL", "Any image address.", code: "await picker.downloadFromURL(url)") { URLSample() },
        KitSample("Save and share", "Photos, Files or the share sheet.", code: """
        try await KitoMediaExporter.saveImageDataToPhotoLibrary(data)
        .kitoFileExporter(isPresented: $isExporting, data: data, contentType: .image, defaultFileName: "photo.jpg")
        .kitoShareSheet(isPresented: $isSharing, items: [data])
        """) { ExportSample() },
    ])
}

/// Every media picker sample.
struct MediaGallery: View {
    static var count: Int { KitGallery.count(MediaSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Media Picker",
            sections: MediaSamples.sections,
            footnote: "Requires `import KitoMediaPicker`. The camera isn't offered in the Simulator.",
            searchHint: "Try “avatar”, “upload”, “grid” or “paste”."
        )
    }
}
