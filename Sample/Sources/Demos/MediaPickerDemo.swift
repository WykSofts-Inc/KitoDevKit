//
//  MediaPickerDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoMediaPicker
import UniformTypeIdentifiers

struct MediaPickerDemo: View {
    var body: some View {
        List {
            NavigationLink("Avatar picker (all sources)") { AvatarPickerDemo() }
            NavigationLink("Restricted sources") { RestrictedSourcesDemo() }
            NavigationLink("Paste from clipboard directly") { ClipboardDemo() }
            NavigationLink("Download from URL directly") { URLDownloadDemo() }
            NavigationLink("Export — Files, Photos, Share sheet") { ExportDemo() }
        }
        .navigationTitle("Media Picker")
    }
}

private struct AvatarPickerDemo: View {
    @State private var picker = KitoMediaPickerViewModel()

    var body: some View {
        VStack(spacing: 20) {
            KitoAvatarPicker(viewModel: picker, size: 140)
            Text("Every source is available: Photo Library, Camera (if present), Files, Clipboard, URL download.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if case .loaded(let asset) = picker.state {
                Text("Loaded from: \(asset.source.label)").font(.caption.bold())
            }
        }
        .padding()
        .navigationTitle("Avatar picker")
    }
}

private struct RestrictedSourcesDemo: View {
    @State private var picker = KitoMediaPickerViewModel(sources: [.photoLibrary, .files])

    var body: some View {
        VStack(spacing: 16) {
            Text("Only Photo Library and Files are offered — e.g. a document-upload flow with no reason to offer the camera.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Add document") { picker.isShowingSourceMenu = true }
                .kitoMediaSourceMenu(picker, allowedFileTypes: [.pdf, .image])
            if case .loaded(let asset) = picker.state {
                Text(asset.fileName ?? "Loaded").font(.caption)
            }
        }
        .navigationTitle("Restricted sources")
    }
}

private struct ClipboardDemo: View {
    @State private var picker = KitoMediaPickerViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Copy an image anywhere on your device, then tap Paste.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Paste") { picker.pasteFromClipboard() }
            switch picker.state {
            case .idle: EmptyView()
            case .loading: ProgressView()
            case .loaded(let asset):
                if let image = asset.image { image.resizable().scaledToFit().frame(height: 150) }
            case .failed(let error):
                Text(error.localizedDescription).font(.caption).foregroundStyle(.red)
            }
        }
        .navigationTitle("Clipboard")
    }
}

private struct URLDownloadDemo: View {
    @State private var picker = KitoMediaPickerViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Button("Download a sample image") {
                Task { await picker.downloadFromURL(URL(string: "https://picsum.photos/300")!) }
            }
            switch picker.state {
            case .idle: EmptyView()
            case .loading: ProgressView()
            case .loaded(let asset):
                if let image = asset.image { image.resizable().scaledToFit().frame(height: 200) }
            case .failed(let error):
                Text(error.localizedDescription).font(.caption).foregroundStyle(.red)
            }
        }
        .navigationTitle("URL download")
    }
}

private struct ExportDemo: View {
    @State private var picker = KitoMediaPickerViewModel(sources: [.photoLibrary])
    @State private var isExportingFile = false
    @State private var isSharing = false
    @State private var statusText = ""

    var body: some View {
        Form {
            Section("1. Pick an image first") {
                KitoAvatarPicker(viewModel: picker, size: 100)
            }
            Section("2. Then export it") {
                Button("Save to Photos") {
                    Task {
                        guard let data = picker.asset?.data else { statusText = "Pick an image first"; return }
                        do {
                            try await KitoMediaExporter.saveImageDataToPhotoLibrary(data)
                            statusText = "Saved to Photos"
                        } catch {
                            statusText = error.localizedDescription
                        }
                    }
                }
                Button("Export to Files") { isExportingFile = true }
                Button("Share sheet") { isSharing = true }
            }
            if !statusText.isEmpty {
                Section("Result") { Text(statusText).font(.caption).foregroundStyle(.secondary) }
            }
        }
        .navigationTitle("Export")
        .kitoFileExporter(
            isPresented: $isExportingFile,
            data: picker.asset?.data ?? Data(),
            contentType: .image,
            defaultFileName: "photo.jpg"
        ) { result in
            switch result {
            case .success: statusText = "Exported to Files"
            case .failure(let error): statusText = error.localizedDescription
            }
        }
        .kitoShareSheet(isPresented: $isSharing, items: picker.asset?.data.map { [$0] } ?? [])
    }
}
