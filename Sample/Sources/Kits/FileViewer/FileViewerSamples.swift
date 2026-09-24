//
//  FileViewerSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoFileViewer

// MARK: - Sample data

/// Real files generated on the device by KitoSampleDocuments, so every sample works offline.
private enum FileViewerData {
    static let root: KitoFolder = {
        (try? KitoSampleDocuments.make())
            ?? KitoFolder(name: "Documents", files: KitoSampleDocuments.remoteFiles())
    }()

    static var localFiles: [KitoFileItem] { root.allFiles.filter(\.isLocal) }

    static func file(_ name: String) -> KitoFileItem? {
        root.allFiles.first { $0.name == name }
    }

    static func url(_ name: String) -> URL? { file(name)?.url }

    static var invoice: URL? { url("Invoice INV-2026-0914.pdf") }
    static var report: URL? { url("Term 2 Report.pdf") }
    static var photo: URL? { url("Maasai Mara sunset.png") }
    static var swiftFile: URL? { url("FileListScreen.swift") }

    static var photos: KitoFolder {
        KitoFolder(name: "Photos", files: root.allFiles.filter { $0.kind == .image } + [
            KitoFileItem(name: "Diani beach.heic", size: 2_800_000, modified: .now.addingTimeInterval(-86_400 * 12)),
            KitoFileItem(name: "Team offsite.jpg", size: 4_100_000, modified: .now.addingTimeInterval(-86_400 * 40)),
            KitoFileItem(name: "Launch night.mov", size: 96_000_000, modified: .now.addingTimeInterval(-86_400 * 2)),
        ])
    }

    static let attachments: [KitoFileItem] = [
        KitoFileItem(name: "Invoice.pdf", size: 240_000),
        KitoFileItem(name: "Site photos.zip", size: 18_400_000),
        KitoFileItem(name: "Budget 2026.xlsx", size: 186_000),
    ]
}

/// A placeholder when a sample file couldn't be generated.
private struct FileViewerMissing: View {
    var body: some View {
        ContentUnavailableView("Sample file unavailable", systemImage: "doc.questionmark",
                               description: Text("The sample documents couldn't be written to the temporary folder."))
    }
}

// MARK: - Browse

private struct FileViewerBrowserScreen: View {
    @State private var files = KitoFileBrowserModel(root: FileViewerData.root, sort: .name)
    @State private var preview: KitoFileItem?

    var body: some View {
        NavigationStack {
            KitoFileBrowser(model: files) { preview = $0 }
                .navigationTitle(files.currentFolder.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if files.canGoUp {
                        ToolbarItem(placement: .topBarLeading) {
                            Button { withAnimation { _ = files.goUp() } } label: { Image(systemName: "chevron.left") }
                                .accessibilityLabel("Back")
                        }
                    }
                }
        }
        .fullScreenCover(item: $preview) { KitoFilePreview($0) }
    }
}

private struct FileViewerGridScreen: View {
    @State private var files = KitoFileBrowserModel(root: FileViewerData.photos, sort: .newest, layout: .grid)
    @State private var preview: KitoFileItem?

    var body: some View {
        NavigationStack {
            KitoFileGrid(model: files, options: KitoFileBrowserOptions(showsBreadcrumbs: false),
                         minimumTileWidth: 104, tint: .purple) { preview = $0 }
                .navigationTitle("Photos")
                .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(item: $preview) { KitoFilePreview($0, tint: .purple) }
    }
}

private struct FileViewerGroupingSample: View {
    @State private var files = KitoFileBrowserModel(files: FileViewerData.root.allFiles, title: "All files",
                                                    sort: .newest, grouping: .kind)

    var body: some View {
        VStack(spacing: 12) {
            Picker("Group by", selection: $files.grouping) {
                ForEach(KitoFileGrouping.allCases, id: \.self) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            KitoFileList(model: files, options: KitoFileBrowserOptions(showsBreadcrumbs: false, showsSearch: false)) { _ in }
                .frame(height: 460)
        }
        .animation(.snappy, value: files.grouping)
    }
}

private struct FileViewerSelectionScreen: View {
    @State private var files: KitoFileBrowserModel = {
        let model = KitoFileBrowserModel(root: FileViewerData.root, sort: .largest)
        model.isSelecting = true
        return model
    }()
    @State private var log = "Tap files, then Share, Move or Delete."

    var body: some View {
        NavigationStack {
            KitoFileList(model: files, tint: .indigo) { _ in }
                .navigationTitle("Select files")
                .navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge: .top) { FileViewerLogBanner(text: log) }
        }
        .onAppear {
            files.onDelete = { removed in log = "Deleted \(removed.map(\.name).joined(separator: ", "))" }
            files.onMove = { moved, folder in log = "Moved \(moved.count) to \(folder.name)" }
        }
    }
}

private struct FileViewerLogBanner: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.thinMaterial, in: Capsule())
            .padding(.vertical, 6)
            .contentTransition(.opacity)
            .animation(.easeOut, value: text)
    }
}

private struct FileViewerEmptySample: View {
    @State private var files = KitoFileBrowserModel(root: KitoFolder(name: "Downloads"))
    @State private var search = KitoFileBrowserModel(files: FileViewerData.localFiles, title: "Documents")

    var body: some View {
        VStack(spacing: 20) {
            KitoFileList(model: files, options: KitoFileBrowserOptions(showsSearch: false, emptyTitle: "No downloads yet",
                                                                      emptyMessage: "Files you save appear here.")) { _ in }
                .frame(height: 300)
            Divider()
            KitoFileList(model: search, options: KitoFileBrowserOptions(showsBreadcrumbs: false)) { _ in }
                .frame(height: 320)
                .onAppear { search.query = "safari" }
        }
    }
}

// MARK: - Icons

private struct FileViewerBadgesSample: View {
    private let badges: [(KitoFileKind, String)] = [
        (.pdf, "pdf"), (.doc, "docx"), (.sheet, "xlsx"), (.slides, "pptx"), (.archive, "zip"), (.image, "heic"),
        (.video, "mov"), (.audio, "m4a"), (.code, "swift"), (.text, "txt"), (.sheet, "csv"), (.other, "bin"),
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: 16)], spacing: 18) {
            ForEach(badges.indices, id: \.self) { index in
                VStack(spacing: 6) {
                    KitoFileIcon(kind: badges[index].0, extension: badges[index].1, size: 56)
                    Text(badges[index].0.singularTitle).font(.caption2).foregroundStyle(.secondary)
                }
            }
            VStack(spacing: 6) {
                KitoFolderIcon(size: 56)
                Text("Folder").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}

private struct FileViewerThumbnailsSample: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 18) {
            ForEach(FileViewerData.localFiles.filter { $0.kind == .pdf || $0.kind == .image }) { file in
                VStack(spacing: 8) {
                    KitoFileIcon(file, size: 92, showsThumbnail: true)
                    Text(file.baseName).font(.caption2).lineLimit(1).frame(width: 92)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FileViewerBreadcrumbSample: View {
    @State private var path = KitoBreadcrumb.items(forPath: "Documents/Clients/Baobab Coffee/2026/Invoices/September")
    @State private var maxVisible = 4.0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KitoBreadcrumbBar(path, maxVisible: Int(maxVisible), tint: .teal) { crumb in
                withAnimation { path = Array(path.prefix { $0.depth <= crumb.depth }) }
            }
            .padding(.horizontal, -16)
            Stepper("Show up to \(Int(maxVisible)) steps", value: $maxVisible, in: 3...8)
                .font(.subheadline)
            Button("Reset path") {
                withAnimation { path = KitoBreadcrumb.items(forPath: "Documents/Clients/Baobab Coffee/2026/Invoices/September") }
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
        }
    }
}

// MARK: - Preview

private struct FileViewerPDFScreen: View {
    var body: some View {
        if let url = FileViewerData.invoice {
            KitoPDFViewer(url: url, tint: Color(red: 0.07, green: 0.45, blue: 0.33))
        } else {
            FileViewerMissing()
        }
    }
}

private struct FileViewerPDFSearchScreen: View {
    @State private var pdf: KitoPDFViewerModel? = FileViewerData.report.map { KitoPDFViewerModel(url: $0) }

    var body: some View {
        if let pdf {
            KitoPDFViewer(model: pdf, tint: .indigo)
                .task {
                    try? await Task.sleep(for: .milliseconds(400))
                    pdf.searchQuery = "Excellent"
                }
        } else {
            FileViewerMissing()
        }
    }
}

private struct FileViewerAnyFileScreen: View {
    @State private var preview: KitoFileItem?

    var body: some View {
        NavigationStack {
            List(FileViewerData.root.allFiles) { file in
                Button { preview = file } label: { KitoFileRow(file) }
                    .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .navigationTitle("Open anything")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(item: $preview) { KitoFilePreview($0) }
    }
}

private struct FileViewerImageSample: View {
    var body: some View {
        Group {
            if let url = FileViewerData.photo {
                KitoFileImageViewer(url: url)
            } else {
                FileViewerMissing()
            }
        }
        .frame(height: 300)
        .background(Color.black, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct FileViewerCodeSample: View {
    var body: some View {
        Group {
            if let url = FileViewerData.swiftFile {
                KitoTextViewer(url: url)
            } else {
                FileViewerMissing()
            }
        }
        .frame(height: 440)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct FileViewerQuickLookScreen: View {
    @State private var index = 0
    private let urls = ["Expenses Q3.csv", "Meeting notes.txt", "Nairobi skyline.png"].compactMap(FileViewerData.url)

    var body: some View {
        VStack(spacing: 0) {
            Picker("File", selection: $index) {
                ForEach(urls.indices, id: \.self) { Text(urls[$0].pathExtension.uppercased()).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding()
            if urls.isEmpty {
                FileViewerMissing()
            } else {
                KitoQuickLookPreview(urls: urls, selection: $index)
            }
        }
    }
}

// MARK: - Transfers

private struct FileViewerRowsSample: View {
    @State private var transfers = KitoTransferModel()

    var body: some View {
        VStack(spacing: 4) {
            ForEach(transfers.transfers) { transfer in
                KitoDownloadRow(transfer, model: transfers)
                if transfer.id != transfers.transfers.last?.id { Divider() }
            }
            Button("Run again") { start() }
                .buttonStyle(GalleryPrimaryButtonStyle())
                .padding(.top, 12)
        }
        .onAppear { if transfers.transfers.isEmpty { start() } }
    }

    private func start() {
        transfers.transfers.forEach { transfers.remove($0) }
        transfers.simulate(name: "Invoice INV-2026-0914.pdf", size: 2_400_000, duration: 5)
        transfers.simulate(name: "Site walkthrough.mov", size: 212_000_000, duration: 14, startsPaused: true)
        transfers.simulate(name: "Brand assets.zip", size: 48_200_000, duration: 7, failsAt: 0.55)
        transfers.simulate(name: "Budget 2026.xlsx", size: 186_000, direction: .upload, duration: 3)
    }
}

private struct FileViewerTransferScreen: View {
    @State private var transfers = KitoTransferModel()
    @State private var preview: KitoFileItem?
    @State private var added = 0
    private let names = ["Pitch deck.pptx", "Voice memo.m4a", "Supplier contract.docx", "Term 2 Report.pdf"]

    var body: some View {
        NavigationStack {
            KitoTransferList(model: transfers, tint: .blue) { preview = $0 }
                .navigationTitle("Transfers")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { add() } label: { Image(systemName: "plus.circle.fill") }
                            .accessibilityLabel("Add a download")
                    }
                }
        }
        .onAppear(perform: seed)
        .fullScreenCover(item: $preview) { KitoFilePreview($0) }
    }

    private func seed() {
        guard transfers.transfers.isEmpty else { return }
        let invoice = FileViewerData.invoice
        transfers.simulate(name: "Invoice INV-2026-0914.pdf", size: 2_400_000, duration: 4, fileURL: invoice)
        transfers.simulate(name: "Nairobi skyline.png", size: 9_800_000, direction: .upload, duration: 9)
        transfers.simulate(name: "Brand assets.zip", size: 48_200_000, duration: 10, failsAt: 0.4)
        transfers.simulate(name: "Site walkthrough.mov", size: 212_000_000, duration: 30, startsPaused: true)
    }

    private func add() {
        let name = names[added % names.count]
        added += 1
        transfers.simulate(name: name, size: Int64.random(in: 800_000...40_000_000), duration: Double.random(in: 4...9))
    }
}

private struct FileViewerRingSample: View {
    @State private var fraction = 0.42
    @State private var indeterminate = false

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 28) {
                KitoTransferProgressRing(fraction: indeterminate ? nil : fraction, tint: .blue, lineWidth: 6) {
                    Text(indeterminate ? "…" : "\(Int(fraction * 100))%")
                        .font(.headline.monospacedDigit())
                        .contentTransition(.numericText())
                }
                .frame(width: 96, height: 96)
                KitoTransferProgressRing(fraction: indeterminate ? nil : fraction, tint: .green, lineWidth: 4)
                    .frame(width: 56, height: 56)
                KitoTransferProgressRing(fraction: indeterminate ? nil : fraction, tint: .orange, lineWidth: 3)
                    .frame(width: 32, height: 32)
            }
            Slider(value: $fraction, in: 0...1)
                .disabled(indeterminate)
            Toggle("Size not known yet", isOn: $indeterminate)
                .font(.subheadline)
        }
    }
}

// MARK: - Attach and share

private struct FileViewerChipsSample: View {
    @State private var files = FileViewerData.attachments

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KitoAttachmentRow($files, allowedContentTypes: [.pdf, .image, .spreadsheet], maxCount: 6)
                .padding(.horizontal, -16)
            HStack {
                ForEach(FileViewerData.attachments.prefix(1)) { file in
                    KitoAttachmentChip(file, tint: .red)
                }
                Spacer()
                Button("Reset") { withAnimation { files = FileViewerData.attachments } }
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

private struct FileViewerPickerSample: View {
    @State private var picked: [KitoFileItem] = []

    var body: some View {
        VStack(spacing: 16) {
            KitoDocumentPickerButton("Choose PDFs or images", allowedContentTypes: [.pdf, .image]) { files in
                withAnimation { picked += files }
            }
            KitoDocumentPickerButton("One document", systemImage: "doc", allowedContentTypes: [.item],
                                     allowsMultipleSelection: false, style: .tonal) { files in
                withAnimation { picked = files }
            }
            if picked.isEmpty {
                Text("Nothing picked yet").font(.footnote).foregroundStyle(.secondary)
            } else {
                ForEach(picked) { KitoFileRow($0) }
            }
        }
    }
}

private struct FileViewerShareSample: View {
    private var items: [KitoFileItem] { FileViewerData.localFiles.filter { $0.kind == .pdf } }

    var body: some View {
        VStack(spacing: 14) {
            KitoShareButton("Share both PDFs", items: items)
            KitoShareButton("Share the invoice", urls: FileViewerData.invoice.map { [$0] } ?? [], style: .outlined,
                            tint: Color(red: 0.07, green: 0.45, blue: 0.33))
            KitoShareButton("Share the report", urls: FileViewerData.report.map { [$0] } ?? [], style: .tonal, tint: .indigo)
        }
    }
}

private struct FileViewerComposerScreen: View {
    @State private var subject = "Baobab Coffee — September invoice"
    @State private var message = "Hi Njeri,\n\nPlease find the invoice and the site photos attached.\n\nAsante,\nWanjiku"
    @State private var files = Array(FileViewerData.localFiles.filter { $0.kind == .pdf || $0.kind == .image }.prefix(3))
    @State private var preview: KitoFileItem?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("To", value: "njeri@baobab.example")
                    TextField("Subject", text: $subject)
                    TextField("Message", text: $message, axis: .vertical)
                        .lineLimit(5...10)
                }
                Section("Attachments") {
                    KitoAttachmentRow($files, tint: .indigo) { preview = $0 }
                        .listRowInsets(EdgeInsets())
                    Text(summary).font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New message")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(item: $preview) { KitoFilePreview($0) }
    }

    private var summary: String {
        let total = files.reduce(Int64(0)) { $0 + ($1.size ?? 0) }
        return "\(files.count) files · \(KitoByteCount.string(total))"
    }
}

// MARK: - Gallery

enum FileViewerSamples {
    private static let browse = KitSection("Browse files", symbol: "folder", [
        KitSample("File browser", "Folders, breadcrumbs, search, sort and a list ⇄ grid switch.", code: """
        @State private var files = KitoFileBrowserModel(root: KitoFolder.load(from: documentsURL))
        @State private var preview: KitoFileItem?

        KitoFileBrowser(model: files) { preview = $0 }
            .fullScreenCover(item: $preview) { KitoFilePreview($0) }
        """) { ModalStage { FileViewerBrowserScreen() } },
        KitSample("Photo grid", "Large thumbnails from QuickLook, newest first.", code: """
        @State private var files = KitoFileBrowserModel(root: photos, sort: .newest, layout: .grid)

        KitoFileGrid(model: files, options: KitoFileBrowserOptions(showsBreadcrumbs: false),
                     minimumTileWidth: 104, tint: .purple) { preview = $0 }
        """) { ModalStage { FileViewerGridScreen() } },
        KitSample("Sort and group", "Group by kind or date: Today, Yesterday, Previous 7 Days, by month.", code: """
        @State private var files = KitoFileBrowserModel(files: allFiles, sort: .newest, grouping: .kind)

        Picker("Group by", selection: $files.grouping) {
            ForEach(KitoFileGrouping.allCases, id: \\.self) { Text($0.title).tag($0) }
        }
        KitoFileList(model: files) { open($0) }
        // Or on its own: KitoFileGroup.make(files, sort: .largest, grouping: .date)
        """) { FileViewerGroupingSample() },
        KitSample("Select, share, move, delete", "Checkmarks and a floating action bar; swipe rows too.", code: """
        files.isSelecting = true
        files.onDelete = { removed in removed.compactMap(\\.url).forEach { try? FileManager.default.removeItem(at: $0) } }
        files.onMove = { moved, folder in sync(moved, to: folder) }

        KitoFileList(model: files, tint: .indigo) { open($0) }
        """) { ModalStage { FileViewerSelectionScreen() } },
        KitSample("Empty folder and no results", "A floating stack of documents, and “Nothing matches”.", code: """
        KitoFileList(model: downloads,
                     options: KitoFileBrowserOptions(emptyTitle: "No downloads yet",
                                                     emptyMessage: "Files you save appear here.")) { open($0) }
        KitoFileEmptyState(title: "No files", message: "Files you add appear here.")
        """) { FileViewerEmptySample() },
    ])

    private static let icons = KitSection("Icons and paths", symbol: "doc.richtext", [
        KitSample("File badges", "A colour per kind with the extension on it.", code: """
        KitoFileIcon(file, size: 44)                              // kind and extension from the file
        KitoFileIcon(kind: .sheet, extension: "xlsx", size: 56)
        KitoFolderIcon(size: 56)
        """) { FileViewerBadgesSample() },
        KitSample("Thumbnails", "A real preview of PDFs and images once QuickLook has made one.", code: """
        KitoFileIcon(file, size: 92, showsThumbnail: true)   // shows the badge until the thumbnail is ready
        """) { FileViewerThumbnailsSample() },
        KitSample("Breadcrumb path", "Tap a step to go back; long paths fold their middle into “…”.", code: """
        KitoBreadcrumbBar(files.breadcrumbs, maxVisible: 4, tint: .teal) { files.goTo($0) }

        KitoBreadcrumb.items(for: url, root: documentsURL, rootTitle: "Documents")
        KitoBreadcrumb.collapsed(items, maxVisible: 4)     // Documents › … › Invoices › September
        """) { FileViewerBreadcrumbSample() },
    ])

    private static let preview = KitSection("Preview", symbol: "eye", [
        KitSample("PDF viewer", "Page thumbnails, “1 / 3”, zoom and share, built on PDFKit.", code: """
        KitoPDFViewer(url: invoiceURL, tint: .green)
        """) { ModalStage { FileViewerPDFScreen() } },
        KitSample("Search in a PDF", "Every match highlighted, “2 of 4”, and the words around it.", code: """
        @State private var pdf = KitoPDFViewerModel(url: reportURL)

        KitoPDFViewer(model: pdf, tint: .indigo)
        pdf.searchQuery = "Excellent"
        pdf.nextResult()               // pdf.cursor.label, pdf.currentResult?.snippet
        """) { ModalStage { FileViewerPDFSearchScreen() } },
        KitSample("Open any file", "The right viewer for each kind, or “Download to preview”.", code: """
        .fullScreenCover(item: $preview) { file in
            KitoFilePreview(file)      // PDF, image, text and code viewers; QuickLook for the rest
        }
        KitoPreviewMode.mode(for: file)   // .pdf, .image, .text, .quickLook, .unavailable
        """) { ModalStage { FileViewerAnyFileScreen() } },
        KitSample("Image viewer", "Pinch to zoom, drag, double-tap to zoom in and out.", code: """
        KitoFileImageViewer(url: photoURL, maximumZoom: 5)
        """) { FileViewerImageSample() },
        KitSample("Code and text", "Line numbers, monospaced, light syntax colours, wrap and text size.", code: """
        KitoTextViewer(url: swiftFileURL)
        KitoTextViewer(text: csv, fileExtension: "csv", wraps: false)
        """) { FileViewerCodeSample() },
        KitSample("QuickLook", "The system previewer for CSV, Office, iWork, video and more.", code: """
        @State private var index = 0

        KitoQuickLookPreview(urls: [csvURL, notesURL, photoURL], selection: $index)
        KitoQuickLookPreview.canPreview(url)
        """) { ModalStage { FileViewerQuickLookScreen() } },
    ])

    private static let transfers = KitSection("Downloads and uploads", symbol: "arrow.down.circle", [
        KitSample("Transfer rows", "Speed, time left, pause, resume, cancel, and Retry after a failure.", code: """
        @State private var transfers = KitoTransferModel()

        transfers.download(reportURL)                                   // URLSession
        transfers.simulate(name: "Brand assets.zip", size: 48_200_000, failsAt: 0.55)   // for demos

        ForEach(transfers.transfers) { KitoDownloadRow($0, model: transfers) }
        """) { FileViewerRowsSample() },
        KitSample("Transfer list", "Overall progress, In progress and Done; finished files open.", code: """
        KitoTransferList(model: transfers, tint: .blue) { file in preview = file }

        transfers.upload(fileURL, to: URLRequest(url: uploadURL))
        transfers.clearFinished()
        """) { ModalStage { FileViewerTransferScreen() } },
        KitSample("Progress ring", "Gradient stroke with a rounded cap; spins while the size is unknown.", code: """
        KitoTransferProgressRing(fraction: 0.42, tint: .blue, lineWidth: 6) {
            Text("42%").font(.headline)
        }
        KitoTransferProgressRing(fraction: nil)  // indeterminate
        """) { FileViewerRingSample() },
    ])

    private static let attach = KitSection("Attach and share", symbol: "paperclip", [
        KitSample("Attachment chips", "“Invoice.pdf · 240 KB ✕” with an Add chip that opens Files.", code: """
        @State private var attachments: [KitoFileItem] = []

        KitoAttachmentRow($attachments, allowedContentTypes: [.pdf, .image], maxCount: 6)
        KitoAttachmentChip(file) { remove(file) }
        """) { FileViewerChipsSample() },
        KitSample("Pick documents", "The Files picker with allowed types and multi-select.", code: """
        KitoDocumentPickerButton("Choose PDFs or images", allowedContentTypes: [.pdf, .image]) { files in
            attachments += files        // copied into a temporary folder, ready to use
        }
        """) { FileViewerPickerSample() },
        KitSample("Share buttons", "Filled, outlined and tonal capsules around ShareLink.", code: """
        KitoShareButton("Share both PDFs", items: pdfs)
        KitoShareButton("Share the invoice", urls: [invoiceURL], style: .outlined, tint: .green)
        """) { FileViewerShareSample() },
        KitSample("Message with attachments", "Chips inside a form; tap one to preview it.", code: """
        Section("Attachments") {
            KitoAttachmentRow($files, tint: .indigo) { preview = $0 }
        }
        .fullScreenCover(item: $preview) { KitoFilePreview($0) }
        """) { ModalStage { FileViewerComposerScreen() } },
    ])

    static let sections: [KitSection] = [browse, icons, preview, transfers, attach]
}

struct FileViewerGallery: View {
    static var count: Int { KitGallery.count(FileViewerSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Files & Documents",
            sections: FileViewerSamples.sections,
            footnote: "Requires `import KitoFileViewer`.",
            searchHint: "Try “PDF”, “grid”, “search”, “download”, “QuickLook” or “attach”."
        )
    }
}
