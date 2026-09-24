//
//  FashionReviews.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoReviews

/// The reviews for one piece: summary with a tappable histogram, sortable list and a composer.
struct FashionReviewsSheet: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    let productName: String
    let designerName: String
    let rating: Double
    let reviewCount: Int
    let seed: String
    let authorName: String?
    let onPosted: () -> Void

    @State private var writing = false
    @State private var posted: [KitoReview] = []

    private var reviews: [KitoReview] { posted + FashionReviewPool.reviews(seed: seed, rating: rating) }

    var body: some View {
        NavigationStack {
            KitoReviewList(reviews: reviews,
                           stats: FashionReviewPool.stats(rating: rating, count: reviewCount + posted.count),
                           sort: .mostHelpful,
                           onWriteReview: { writing = true })
                .background(theme.colors.background.ignoresSafeArea())
                .navigationTitle("Reviews")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }.fontWeight(.semibold)
                    }
                }
                .sheet(isPresented: $writing) {
                    KitoReviewComposer(subject: productName, subtitle: designerName,
                                       tags: ["True to size", "Beautiful fabric", "Runs small", "Worth it", "Fast delivery"],
                                       authorName: authorName) { draft in
                        try? await Task.sleep(nanoseconds: 700_000_000)
                        posted.insert(KitoReview(author: KitoReviewer(draft.isAnonymous ? "Anonymous" : (authorName ?? "Guest"),
                                                                      subtitle: "Just now"),
                                                 rating: Double(draft.rating), body: draft.text.isEmpty ? "Loved it." : draft.text,
                                                 tags: draft.tags, isVerified: true), at: 0)
                        onPosted()
                    }
                }
        }
    }
}

/// A one-line score for the product page toolbar.
struct FashionCompactRating: View {
    let rating: Double
    let count: Int

    var body: some View {
        KitoCompactRating(value: rating, count: count)
    }
}

// MARK: - Mock reviews

private enum FashionReviewPool {
    private struct Entry {
        let name: String
        let from: String
        let rating: Double
        let title: String
        let body: String
        let tags: [String]
    }

    private static let entries: [Entry] = [
        Entry(name: "Achieng O.", from: "Kilimani", rating: 5, title: "Worth every shilling",
              body: "The fabric is heavier than I expected in the best way. Wore it to a wedding in Karen and three people asked where it was from.",
              tags: ["Beautiful fabric", "Worth it"]),
        Entry(name: "Fatma A.", from: "Mombasa", rating: 5, title: "Perfect for the coast",
              body: "Light, breathable and it kept its shape after a whole day in the Old Town heat.",
              tags: ["True to size"]),
        Entry(name: "Wambui K.", from: "Westlands", rating: 4, title: "Size up if unsure",
              body: "Gorgeous finish but it runs a touch small. The boutique swapped it the same afternoon.",
              tags: ["Runs small", "Great service"]),
        Entry(name: "Otieno M.", from: "Kisumu", rating: 5, title: "Bought a second one",
              body: "Delivery was the next morning and the packaging felt like a gift. Already ordered another colour.",
              tags: ["Fast delivery"]),
        Entry(name: "Neema S.", from: "Arusha", rating: 4, title: "Lovely, a little long",
              body: "I'm 1.60 m and needed a small hem. The atelier did it for free, which was a nice surprise.",
              tags: ["Alterations"]),
        Entry(name: "Salma H.", from: "Stone Town", rating: 5, title: "Timeless",
              body: "You can tell it was made by hand. The stitching is perfect and the colour is richer in person.",
              tags: ["Beautiful fabric"]),
        Entry(name: "Kamau J.", from: "Nanyuki", rating: 3, title: "Good, not perfect",
              body: "Quality is excellent, but the colour is warmer than the photos. Still keeping it.",
              tags: ["Colour differs"]),
    ]

    static func reviews(seed: String, rating: Double) -> [KitoReview] {
        let offset = seed.unicodeScalars.reduce(0) { $0 + Int($1.value) } % entries.count
        let ordered = Array(entries[offset...] + entries[..<offset])
        return ordered.prefix(6).enumerated().map { index, entry in
            KitoReview(
                id: "\(seed)-\(index)",
                author: KitoReviewer(entry.name, subtitle: entry.from),
                rating: rating >= 4.7 && entry.rating == 3 ? 4 : entry.rating,
                title: entry.title, body: entry.body,
                date: Date().addingTimeInterval(-Double(index * 5 + 2) * 86_400),
                tags: entry.tags, helpfulCount: 40 - index * 6, isVerified: index % 3 != 2,
                ownerReply: index == 2 ? KitoOwnerReply(name: "Maison Amani client care",
                                                        body: "Asante for the note. Our stylists are always happy to help with sizing.") : nil)
        }
    }

    /// A believable five-to-one spread whose average lands near `rating`.
    static func stats(rating: Double, count: Int) -> KitoRatingStats {
        let five = max(0.0, min(1.0, (rating - 3.6) / 1.4))
        let shares = [five, (1 - five) * 0.62, (1 - five) * 0.22, (1 - five) * 0.1, (1 - five) * 0.06]
        return KitoRatingStats(fiveToOne: shares.map { Int(($0 * Double(max(count, 1))).rounded()) })
    }
}
