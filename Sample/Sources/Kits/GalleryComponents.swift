//
//  GalleryComponents.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// Building blocks shared by every kit's sample gallery: a searchable list of samples, each
/// opening to a live preview with its copyable code.

struct GallerySampleRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.body.weight(.semibold))
            Text(subtitle).font(.footnote).foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct GallerySectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
            .textCase(nil)
    }
}

struct GalleryNoResults: View {
    let query: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass").font(.largeTitle).foregroundStyle(.secondary)
            Text("No samples for “\(query)”").font(.headline)
            Text("Try a use case (“checkout”), a component (“phone”) or a behaviour (“shake”).")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

/// A sample's live preview above its code, with a one-tap copy.
struct GallerySampleDetail<Preview: View>: View {
    let title: String
    let subtitle: String
    let code: String
    let footnote: String
    @ViewBuilder let preview: () -> Preview

    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)

                preview()
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.12), lineWidth: 1))

                HStack {
                    Text("Code").font(.headline)
                    Spacer()
                    Button(action: copy) {
                        Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(copied ? Color.primary : Color.primary.opacity(0.08)))
                            .foregroundStyle(copied ? Color(.systemBackground) : Color.primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(copied ? "Code copied" : "Copy code")
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    Text(code)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(16)
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))

                // LocalizedStringKey so `code` in the footnote renders as code: SwiftUI only parses
                // markdown for string literals, and this arrives as a String parameter.
                Text(LocalizedStringKey(footnote)).font(.caption).foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func copy() {
        UIPasteboard.general.string = code
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { copied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { withAnimation { copied = false } }
    }
}
