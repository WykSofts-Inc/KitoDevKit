//
//  ReviewsSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import UIKit
import KitoReviews

// MARK: - Sample data

/// Offline "photos": a gradient with a symbol, drawn once.
private enum SamplePhoto {
    static func make(_ symbol: String, _ top: UIColor, _ bottom: UIColor, caption: String? = nil) -> KitoReviewPhoto {
        let size = CGSize(width: 600, height: 600)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let colors = [top.cgColor, bottom.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
                context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            }
            let config = UIImage.SymbolConfiguration(pointSize: 190, weight: .semibold)
            if let glyph = UIImage(systemName: symbol, withConfiguration: config)?.withTintColor(.white.withAlphaComponent(0.85), renderingMode: .alwaysOriginal) {
                glyph.draw(at: CGPoint(x: (size.width - glyph.size.width) / 2, y: (size.height - glyph.size.height) / 2))
            }
        }
        return KitoReviewPhoto(Image(uiImage: image), caption: caption)
    }

    static let ember = UIColor(red: 0.91, green: 0.36, blue: 0.19, alpha: 1)
    static let saffron = UIColor(red: 0.98, green: 0.72, blue: 0.22, alpha: 1)
    static let ocean = UIColor(red: 0.10, green: 0.55, blue: 0.78, alpha: 1)
    static let lagoon = UIColor(red: 0.20, green: 0.80, blue: 0.75, alpha: 1)
    static let forest = UIColor(red: 0.13, green: 0.50, blue: 0.33, alpha: 1)
    static let dusk = UIColor(red: 0.36, green: 0.25, blue: 0.62, alpha: 1)
    static let night = UIColor(red: 0.10, green: 0.11, blue: 0.16, alpha: 1)
    static let slate = UIColor(red: 0.42, green: 0.46, blue: 0.54, alpha: 1)

    static let fish = make("fish.fill", ember, saffron, caption: "Whole tilapia, wet fry, with ugali")
    static let grill = make("flame.fill", saffron, ember, caption: "Nyama choma platter for four")
    static let drinks = make("cup.and.saucer.fill", forest, saffron, caption: "Dawa and fresh passion juice")
    static let beach = make("beach.umbrella.fill", ocean, lagoon, caption: "Morning on the beach, Diani")
    static let room = make("bed.double.fill", dusk, ocean, caption: "Ocean-view room")
    static let pool = make("water.waves", lagoon, ocean, caption: "Infinity pool at sunset")
    static let earbuds = make("earbuds", night, slate, caption: "Tembo Buds in the charging case")
    static let unboxing = make("shippingbox.fill", slate, dusk, caption: "Unboxing")
}

private enum SampleReviews {
    static func ago(days: Double) -> Date { Date().addingTimeInterval(-days * 86_400) }

    static let restaurant: [KitoReview] = [
        KitoReview(id: "r1", author: KitoReviewer("Achieng O.", subtitle: "Local guide · 48 reviews"), rating: 5,
                   title: "Best tilapia in Kilimani",
                   body: "We came for the wet fry fish and stayed for the atmosphere. The tilapia was crisp outside and soft inside, the ugali was perfectly firm and the kachumbari had just the right bite. Service was warm even on a packed Friday night, and our waiter remembered we wanted extra pili pili without being asked twice. Parking is tight, so take a cab.",
                   date: ago(days: 14), photos: [SamplePhoto.fish, SamplePhoto.drinks], tags: ["Great value", "Friendly staff"],
                   helpfulCount: 42, notHelpfulCount: 2, isVerified: true,
                   ownerReply: KitoOwnerReply(name: "Chef Wairimu", body: "Asante sana, Achieng! We'll save you a table by the window next Friday.", date: ago(days: 12))),
        KitoReview(id: "r2", author: KitoReviewer("Brian K.", subtitle: "12 reviews"), rating: 4,
                   title: "Great nyama choma, slow on weekends",
                   body: "The goat ribs were outstanding and the portion was generous. We waited almost 40 minutes for mains on Saturday though.",
                   date: ago(days: 3), photos: [SamplePhoto.grill], tags: ["Generous portions"], helpfulCount: 18, notHelpfulCount: 1, isVerified: true),
        KitoReview(id: "r3", author: KitoReviewer("Zawadi M.", subtitle: "Food blogger"), rating: 5,
                   body: "Ordered the fish for a birthday lunch and everyone went quiet as soon as it arrived. That's the review.",
                   date: ago(days: 30), tags: ["Great for groups"], helpfulCount: 27),
        KitoReview(id: "r4", author: KitoReviewer("Kamau W."), rating: 2, title: "Not what it used to be",
                   body: "The fish was over-salted and the chips arrived cold. Staff apologised and took the chips off the bill, which I appreciated.",
                   date: ago(days: 8), tags: ["Too slow"], helpfulCount: 9, notHelpfulCount: 4,
                   ownerReply: KitoOwnerReply(name: "Chef Wairimu", body: "Sorry, Kamau. That's not our standard; we've spoken to the kitchen team. Please come back and ask for me.", date: ago(days: 7))),
        KitoReview(id: "r5", author: KitoReviewer("Njeri G.", subtitle: "3 reviews"), rating: 3,
                   body: "Tasty food but very noisy inside. Ask for the garden if you want to talk.", date: ago(days: 60), helpfulCount: 4),
        KitoReview(id: "r6", author: KitoReviewer("Otieno J."), rating: 5, body: "Took my parents from Kisumu and my dad said it tastes like home. High praise!",
                   date: ago(days: 1), helpfulCount: 2, isVerified: true),
    ]

    static let hotel: [KitoReview] = [
        KitoReview(id: "h1", author: KitoReviewer("Amina H.", subtitle: "Stayed 4 nights · Couple"), rating: 5, title: "Paradise on Diani Beach",
                   body: "Wake up, walk twenty steps and you're in the Indian Ocean. The room was spotless, the breakfast mandazi were still warm and the staff arranged a dhow trip to Kisite for us at a day's notice.",
                   date: ago(days: 21), photos: [SamplePhoto.beach, SamplePhoto.room, SamplePhoto.pool], tags: ["Clean", "Great location", "Would return"],
                   helpfulCount: 31, isVerified: true),
        KitoReview(id: "h2", author: KitoReviewer("David M.", subtitle: "Stayed 2 nights · Family"), rating: 4, title: "Lovely, bring bug spray",
                   body: "Kids loved the pool and the colobus monkeys at breakfast. Wi-Fi was patchy in the garden rooms.",
                   date: ago(days: 45), tags: ["Family friendly"], helpfulCount: 12, isVerified: true),
        KitoReview(id: "h3", author: KitoReviewer("Wanjiru N.", subtitle: "Stayed 7 nights · Solo"), rating: 5,
                   body: "The kind of calm you only find on the south coast. I finished two books and didn't miss Nairobi once.",
                   date: ago(days: 70), helpfulCount: 8),
    ]

    static let app: [KitoReview] = [
        KitoReview(id: "a1", author: KitoReviewer("Faith C."), rating: 5, title: "Finally, M-Pesa checkout that just works",
                   body: "Paid for groceries in two taps and the receipt was in my messages before I left the shop. The new dark mode is gorgeous.",
                   date: ago(days: 2), helpfulCount: 64, isVerified: true),
        KitoReview(id: "a2", author: KitoReviewer("Brian K."), rating: 4, title: "Great, wish it had widgets",
                   body: "Fast and reliable. A home screen widget for my balance would make it perfect.", date: ago(days: 9), helpfulCount: 23),
        KitoReview(id: "a3", author: KitoReviewer("Zawadi M."), rating: 5, title: "Support replied in 5 minutes",
                   body: "Had an issue with a double charge and it was refunded the same afternoon. Impressed.", date: ago(days: 16), helpfulCount: 11),
    ]

    static let product = KitoReview(id: "p1", author: KitoReviewer("Achieng O.", subtitle: "Verified buyer"), rating: 4.5, title: "Punchy bass, all-day battery",
                                    body: "I use them on the matatu every morning and the noise cancelling handles Thika Road traffic easily. Case is a little bulky for small pockets.",
                                    date: ago(days: 5), photos: [SamplePhoto.earbuds, SamplePhoto.unboxing], tags: ["Great sound", "Long battery"],
                                    helpfulCount: 88, notHelpfulCount: 3, isVerified: true)

    static let restaurantStats = KitoRatingStats(fiveToOne: [812, 240, 96, 31, 18])
    static let appStats = KitoRatingStats(fiveToOne: [9_870, 1_620, 410, 150, 390])
    static let hotelStats = KitoRatingStats(fiveToOne: [214, 22, 3, 0, 1])
    static let hotelCategories = [
        KitoCategoryScore("Cleanliness", score: 4.9, systemImage: "sparkles"),
        KitoCategoryScore("Accuracy", score: 4.8, systemImage: "checkmark.circle"),
        KitoCategoryScore("Check-in", score: 4.9, systemImage: "key"),
        KitoCategoryScore("Communication", score: 5.0, systemImage: "bubble.left"),
        KitoCategoryScore("Location", score: 4.7, systemImage: "map"),
        KitoCategoryScore("Value", score: 4.6, systemImage: "tag"),
    ]
}

// MARK: - Star rating samples

private struct TapToRate: View {
    @State private var rating: Double = 0

    var body: some View {
        VStack(spacing: 14) {
            Text("How was your meal at Jiko Kilimani?").font(.headline)
            KitoStarRating(rating: $rating)
            Text(KitoRatingMood(rating: rating)?.title ?? "Tap or drag across the stars")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .contentTransition(.interpolate)
                .animation(.snappy, value: rating)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HalfStars: View {
    @State private var rating: Double = 3.5

    var body: some View {
        VStack(spacing: 12) {
            KitoStarRating(rating: $rating, step: .half, size: .custom(40))
            Text("\(KitoRatingMath.formatted(rating)) out of 5")
                .font(.title3.bold().monospacedDigit())
                .contentTransition(.numericText(value: rating))
                .animation(.snappy, value: rating)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PartialFill: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach([("Jiko Kilimani", 4.3), ("Mawimbi Beach House", 4.85), ("Tembo Buds", 3.7), ("Matatu Café", 2.2)], id: \.0) { name, value in
                HStack {
                    Text(name).font(.subheadline.weight(.semibold))
                    Spacer()
                    KitoStarRating(value: value, size: .medium)
                    Text(KitoRatingMath.formatted(value, fractionDigits: 2)).font(.subheadline.monospacedDigit()).frame(width: 40, alignment: .trailing)
                }
            }
        }
    }
}

private struct Sizes: View {
    var body: some View {
        VStack(spacing: 16) {
            KitoStarRating(value: 4.5, size: .small)
            KitoStarRating(value: 4.5, size: .medium)
            KitoStarRating(value: 4.5, size: .large)
            KitoStarRating(value: 4.5, size: .custom(48))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct Symbols: View {
    @State private var love: Double = 4
    @State private var heat: Double = 3
    @State private var thumbs: Double = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            row("How much did you love it?", KitoStarRating(rating: $love, size: .custom(30), symbol: .heart))
            row("Spice level", KitoStarRating(rating: $heat, size: .custom(30), symbol: .flame))
            row("Would you recommend it?", KitoStarRating(rating: $thumbs, maximum: 3, size: .custom(30), symbol: .thumb))
            row("Custom: moons", KitoStarRating(value: 3.5, size: .custom(26), symbol: KitoRatingSymbol(filled: "moon.fill", noun: "moons"), tint: .indigo))
        }
    }

    private func row<V: View>(_ title: String, _ content: V) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
            content
        }
    }
}

private struct CompactListing: View {
    var body: some View {
        VStack(spacing: 12) {
            listing("Jiko Kilimani", "Kenyan · Fish · $$", 4.8, 2_140, "fork.knife", .orange)
            listing("Mawimbi Beach House", "Diani · Hotel", 4.93, 240, "beach.umbrella.fill", .teal)
            listing("Tembo Buds Pro", "Wireless earbuds", 4.5, 12_480, "earbuds", .gray)
        }
    }

    private func listing(_ name: String, _ detail: String, _ rating: Double, _ count: Int, _ symbol: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).font(.title3.weight(.semibold)).foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(color.gradient))
            VStack(alignment: .leading, spacing: 3) {
                Text(name).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            KitoCompactRating(value: rating, count: count)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.primary.opacity(0.05)))
    }
}

// MARK: - Summary samples

private struct FilteringHistogram: View {
    @State private var star: Int?

    private var shown: [KitoReview] {
        let filter = KitoReviewFilter(stars: star.map { [$0] } ?? [])
        return KitoReviewSort.mostRecent.sorted(filter.apply(to: SampleReviews.restaurant))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            KitoRatingSummary(stats: SampleReviews.restaurantStats, selection: $star)
            Divider()
            Text(star.map { "\($0)-star reviews" } ?? "Recent reviews").font(.headline)
            if shown.isEmpty {
                Text("No written reviews with \(star ?? 0) stars yet.").font(.subheadline).foregroundStyle(.secondary)
            }
            ForEach(shown) { review in
                KitoReviewCard(review, style: .compact)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(duration: 0.4), value: star)
    }
}

private struct HotelCategories: View {
    var body: some View {
        VStack(spacing: 24) {
            KitoRatingSummary(stats: SampleReviews.hotelStats, categories: SampleReviews.hotelCategories, badge: "Guest favourite")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SampleReviews.hotel) { KitoReviewCard($0, style: .carouselCard) }
                }
                .padding(.vertical, 12)
            }
            .scrollClipDisabled()
        }
    }
}

private struct AppStoreSummary: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "k.square.fill").font(.system(size: 44)).foregroundStyle(Color.primary.gradient)
                VStack(alignment: .leading) {
                    Text("Kito Pay").font(.headline)
                    Text("Ratings & Reviews").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                KitoCompactRating(value: SampleReviews.appStats.average, count: SampleReviews.appStats.total)
            }
            KitoRatingSummary(stats: SampleReviews.appStats)
        }
    }
}

// MARK: - Card samples

private struct FullCard: View {
    @State private var log: String?

    var body: some View {
        VStack(spacing: 12) {
            KitoReviewCard(SampleReviews.restaurant[0], onVote: { vote in
                log = vote == nil ? "Vote cleared" : (vote == .helpful ? "Marked helpful" : "Marked not helpful")
            }, onReport: { reason in
                log = "Reported: \(reason.rawValue)"
            })
            if let log {
                Text(log).font(.footnote.weight(.semibold)).foregroundStyle(.secondary).transition(.opacity)
            }
        }
        .animation(.snappy, value: log)
    }
}

private struct CompactRows: View {
    var body: some View {
        VStack(spacing: 4) {
            ForEach(SampleReviews.restaurant.prefix(4)) { review in
                KitoReviewCard(review, style: .compact)
                Divider()
            }
        }
    }
}

private struct Testimonials: View {
    var body: some View {
        TabView {
            ForEach(SampleReviews.app) { review in
                KitoReviewCard(review, style: .bubble).padding(.horizontal, 4)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: 360)
    }
}

private struct Carousel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("What guests say").font(.title3.bold())
                Spacer()
                KitoCompactRating(value: SampleReviews.restaurantStats.average, count: SampleReviews.restaurantStats.total)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(SampleReviews.restaurant + [SampleReviews.product]) { review in
                        KitoReviewCard(review, style: .carouselCard, lineLimit: 5)
                            .scrollTransition { card, phase in
                                card.scaleEffect(phase.isIdentity ? 1 : 0.94).opacity(phase.isIdentity ? 1 : 0.7)
                            }
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 14)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
        }
    }
}

// MARK: - List & composer samples

/// The top of a product or place page inside the phone frame.
private struct ScreenHeader: View {
    let title: String
    let subtitle: String
    let symbol: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).font(.headline).foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(color.gradient))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 6)
    }
}

private struct RestaurantScreen: View {
    @State private var reviews = SampleReviews.restaurant
    @State private var writing = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Jiko Kilimani", subtitle: "Kenyan · Fish · Kilimani, Nairobi", symbol: "fork.knife", color: .orange)
            KitoReviewList(reviews: reviews, onWriteReview: { writing = true })
                .sheet(isPresented: $writing) {
                    KitoReviewComposer(subject: "Jiko Kilimani", subtitle: "Kilimani, Nairobi", authorName: "Wycliff N") { draft in
                        try? await Task.sleep(nanoseconds: 900_000_000)
                        let photos = draft.photos.map { KitoReviewPhoto(Image(uiImage: $0)) }
                        let author = KitoReviewer(draft.isAnonymous ? "Anonymous" : "Wycliff N")
                        let review = KitoReview(author: author, rating: Double(draft.rating),
                                                body: draft.text.isEmpty ? "Rated \(draft.rating) stars." : draft.text,
                                                photos: photos, tags: draft.tags)
                        withAnimation(.spring) { reviews.insert(review, at: 0) }
                    }
                }
        }
    }
}

private struct ComposerLauncher: View {
    @State private var writing = false
    @State private var posted: KitoReviewDraft?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "beach.umbrella.fill").font(.system(size: 54)).foregroundStyle(.teal.gradient)
            Text("How was your stay?").font(.title2.bold())
            Text("Mawimbi Beach House, Diani · 4 nights").font(.subheadline).foregroundStyle(.secondary)
            if let posted {
                VStack(spacing: 6) {
                    KitoStarRating(value: Double(posted.rating), size: .medium)
                    Text(posted.tags.joined(separator: " · ")).font(.footnote).foregroundStyle(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
            Spacer()
            Button { writing = true } label: {
                Text(posted == nil ? "Write a review" : "Write another").frame(maxWidth: .infinity)
            }
                .buttonStyle(GalleryPrimaryButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .animation(.spring, value: posted)
        .sheet(isPresented: $writing) {
            KitoReviewComposer(subject: "Mawimbi Beach House", subtitle: "Diani Beach · 4 nights", authorName: "Wycliff N") { draft in
                try? await Task.sleep(nanoseconds: 800_000_000)
                posted = draft
            }
        }
    }
}

private struct EmptyReviews: View {
    @State private var writing = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Tembo Buds Lite", subtitle: "Wireless earbuds · New", symbol: "earbuds", color: .gray)
            KitoReviewList(reviews: [], onWriteReview: { writing = true })
                .sheet(isPresented: $writing) {
                    KitoReviewComposer(subject: "Tembo Buds Lite", tags: ["Great sound", "Comfy fit", "Long battery", "Easy pairing"],
                                       authorName: "Wycliff N") { _ in
                        try? await Task.sleep(nanoseconds: 700_000_000)
                    }
                }
        }
    }
}

// MARK: - Other inputs

private struct EmojiSample: View {
    @State private var mood: KitoRatingMood?

    var body: some View {
        VStack(spacing: 10) {
            Text("How was your delivery?").font(.headline)
            KitoEmojiRating(selection: $mood)
        }
    }
}

private struct ThumbsSample: View {
    @State private var thumb: KitoThumb?

    var body: some View {
        VStack(spacing: 16) {
            Text("Was this answer helpful?").font(.headline)
            KitoThumbsRating(selection: $thumb, upCount: 128, downCount: 9)
            Text(thumb == nil ? "Tap a thumb" : (thumb == .up ? "Glad it helped!" : "Thanks, we'll improve it."))
                .font(.subheadline).foregroundStyle(.secondary)
                .contentTransition(.interpolate)
                .animation(.snappy, value: thumb)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct NPSSample: View {
    @State private var score: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How likely are you to recommend Kito Pay to a friend?").font(.headline)
            KitoNPSScale(score: $score)
            if let score {
                Text(followUp(KitoNPSCategory(score: score)))
                    .font(.subheadline).foregroundStyle(.secondary)
                    .transition(.opacity)
            }
            Divider()
            let answers = [10, 9, 9, 8, 7, 10, 6, 9, 3, 10] + (score.map { [$0] } ?? [])
            HStack {
                Text("Team NPS").font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(Int(KitoNPSCategory.netPromoterScore(answers).rounded()))")
                    .font(.title2.bold().monospacedDigit())
                    .contentTransition(.numericText())
            }
        }
        .animation(.snappy, value: score)
    }

    private func followUp(_ category: KitoNPSCategory) -> String {
        switch category {
        case .detractor: "Sorry to hear that. What's the one thing we should fix?"
        case .passive: "Thanks! What would make it a 10?"
        case .promoter: "Asante! Want to invite a friend and both get KES 200?"
        }
    }
}

private struct SliderSample: View {
    @State private var spice: Double = 6
    @State private var comfort: Double = 3.5

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Rate the pilau").font(.headline)
                KitoSliderRating(value: $spice, in: 0...10, step: 1)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Bed comfort").font(.headline)
                KitoSliderRating(value: $comfort, in: 1...5, step: 0.5, showsEmoji: false, tint: .teal)
            }
        }
    }
}

// MARK: - Prompt samples

private struct PromptScreen: View {
    @State private var state = KitoReviewPromptState(installDate: Date().addingTimeInterval(-5 * 86_400))
    @State private var asking = false
    @State private var feedback: String?
    private let policy = KitoReviewPromptPolicy(minimumSignificantEvents: 3, minimumDaysSinceInstall: 3, cooldownDays: 120)

    private var decision: KitoReviewPromptDecision { policy.decision(for: state, currentVersion: "2.4", now: Date()) }

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "bag.fill").font(.system(size: 48)).foregroundStyle(Color.primary.gradient)
            Text("Kito Market").font(.title2.bold())
            Text("Place 3 orders and we'll politely ask how it's going.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule().fill(index < state.significantEvents ? Color.primary : Color.primary.opacity(0.12)).frame(width: 36, height: 6)
                }
            }
            .animation(.spring, value: state.significantEvents)
            if let feedback {
                Label("Feedback sent: “\(feedback)”", systemImage: "envelope.fill")
                    .font(.footnote).foregroundStyle(.secondary).padding(.horizontal)
            }
            Spacer()
            Button {
                state.recordSignificantEvent()
                if decision.shouldAsk {
                    state.recordPrompt(version: "2.4")
                    asking = true
                }
            } label: {
                Text(state.lastPromptedVersion == nil ? "Place an order" : "Asked for 2.4 already").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(state.lastPromptedVersion != nil)
            .padding(.horizontal, 24)
            Button("Reset") {
                state = KitoReviewPromptState(installDate: Date().addingTimeInterval(-5 * 86_400))
                feedback = nil
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.bottom, 24)
        }
        .kitoReviewPrompt(isPresented: $asking, appName: "Kito Market") { text in feedback = text }
    }
}

private struct PolicyPlayground: View {
    @State private var events = 1
    @State private var daysSinceInstall = 2.0
    @State private var askedThisVersion = false
    @State private var daysSincePrompt = 200.0
    private let policy = KitoReviewPromptPolicy()

    private var decision: KitoReviewPromptDecision {
        let now = Date()
        let state = KitoReviewPromptState(
            installDate: now.addingTimeInterval(-daysSinceInstall * 86_400),
            significantEvents: events,
            lastPromptDate: now.addingTimeInterval(-daysSincePrompt * 86_400),
            lastPromptedVersion: askedThisVersion ? "3.0" : "2.9"
        )
        return policy.decision(for: state, currentVersion: "3.0", now: now)
    }

    private var verdict: String {
        switch decision {
        case .ask: "Ask now"
        case .needsMoreEvents(let remaining): "Wait for \(remaining) more good moment\(remaining == 1 ? "" : "s")"
        case .tooSoonAfterInstall(let days): "Too soon: \(days) more day\(days == 1 ? "" : "s") after install"
        case .alreadyAskedThisVersion: "Already asked in version 3.0"
        case .coolingDown(let days): "Cooling down: \(days) day\(days == 1 ? "" : "s") left"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(verdict, systemImage: decision.shouldAsk ? "checkmark.circle.fill" : "hourglass")
                .font(.headline)
                .foregroundStyle(decision.shouldAsk ? .green : .orange)
                .contentTransition(.interpolate)
                .animation(.snappy, value: decision)
            Stepper("Significant events: \(events)", value: $events, in: 0...10)
            VStack(alignment: .leading) {
                Text("Days since install: \(Int(daysSinceInstall))")
                Slider(value: $daysSinceInstall, in: 0...30, step: 1)
            }
            VStack(alignment: .leading) {
                Text("Days since last prompt: \(Int(daysSincePrompt))")
                Slider(value: $daysSincePrompt, in: 0...365, step: 1)
            }
            Toggle("Already asked in this version", isOn: $askedThisVersion)
        }
        .font(.subheadline)
    }
}

// MARK: - Catalogue

enum ReviewsSamples {
    private static let stars = KitSection("Star ratings", symbol: "star.fill", [
        KitSample("Tap or drag to rate", "Stars pop one by one with a haptic tick as you drag.", code: """
        @State private var rating: Double = 0
        KitoStarRating(rating: $rating)
        """) { TapToRate() },
        KitSample("Half stars", "Snap to halves for finer ratings.", code: """
        KitoStarRating(rating: $rating, step: .half, size: .custom(40))
        """) { HalfStars() },
        KitSample("Partial fill", "Averages like 4.3 fill the last star 30%.", code: """
        KitoStarRating(value: 4.3, size: .medium)
        """) { PartialFill() },
        KitSample("Sizes", "Small, medium, large or any point size.", code: """
        KitoStarRating(value: 4.5, size: .small)    // .medium, .large, .custom(48)
        """) { Sizes() },
        KitSample("Hearts, flames, thumbs", "Built-in symbols, or bring your own.", code: """
        KitoStarRating(rating: $love, symbol: .heart)
        KitoStarRating(rating: $heat, symbol: .flame)
        KitoStarRating(rating: $thumbs, maximum: 3, symbol: .thumb)
        KitoStarRating(value: 3.5, symbol: KitoRatingSymbol(filled: "moon.fill", noun: "moons"), tint: .indigo)
        """) { Symbols() },
        KitSample("Compact badge", "“★ 4.8 (2.1k)” for listings and search results.", code: """
        KitoCompactRating(value: 4.8, count: 2_140)
        """) { CompactListing() },
    ])

    private static let summaries = KitSection("Summaries", symbol: "chart.bar.fill", [
        KitSample("Histogram that filters", "Bars grow in; tap one to show only those reviews.", code: """
        @State private var star: Int?
        KitoRatingSummary(stats: KitoRatingStats(fiveToOne: [812, 240, 96, 31, 18]), selection: $star)
        let shown = KitoReviewFilter(stars: star.map { [$0] } ?? []).apply(to: reviews)
        """) { FilteringHistogram() },
        KitSample("Category scores", "A guest-favourite score with animated bars per category.", code: """
        KitoRatingSummary(stats: stats, categories: [
            KitoCategoryScore("Cleanliness", score: 4.9, systemImage: "sparkles"),
            KitoCategoryScore("Location", score: 4.7, systemImage: "map"),
        ], badge: "Guest favourite")
        """) { HotelCategories() },
        KitSample("App ratings", "Twelve thousand ratings, summarised.", code: """
        KitoCompactRating(value: stats.average, count: stats.total)
        KitoRatingSummary(stats: stats)
        """) { AppStoreSummary() },
    ])

    private static let cards = KitSection("Review cards", symbol: "text.bubble.fill", [
        KitSample("Full review", "Photos, tags, owner reply, helpful votes and a report menu.", code: """
        KitoReviewCard(review, onVote: { vote in api.vote(review.id, vote) },
                       onReport: { reason in api.report(review.id, reason) })
        """) { FullCard() },
        KitSample("Compact rows", "Dense rows for previews.", code: """
        KitoReviewCard(review, style: .compact)
        """) { CompactRows() },
        KitSample("Testimonials", "Quote bubbles for landing pages.", code: """
        KitoReviewCard(review, style: .bubble)
        """) { Testimonials() },
        KitSample("Carousel", "Fixed-width cards that snap as you swipe.", code: """
        ScrollView(.horizontal) {
            LazyHStack { ForEach(reviews) { KitoReviewCard($0, style: .carouselCard) } }
                .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        """) { Carousel() },
    ])

    private static let lists = KitSection("Lists & writing", symbol: "square.and.pencil", [
        KitSample("Restaurant reviews", "Summary, sort, filter chips and a composer; your review lands on top.", code: """
        KitoReviewList(reviews: reviews, onWriteReview: { writing = true })
            .sheet(isPresented: $writing) {
                KitoReviewComposer(subject: "Jiko Kilimani", authorName: "Wycliff N") { draft in
                    await api.post(draft)
                }
            }
        """) { ModalStage { RestaurantScreen() } },
        KitSample("Write a review", "A face that changes mood, quick tags, photos and a thank-you.", code: """
        KitoReviewComposer(subject: "Mawimbi Beach House", subtitle: "Diani Beach · 4 nights",
                           authorName: "Wycliff N") { draft in
            await api.post(draft)     // draft.rating, .tags, .text, .photos, .isAnonymous
        }
        """) { ModalStage { ComposerLauncher() } },
        KitSample("No reviews yet", "The empty state invites the first review.", code: """
        KitoReviewList(reviews: [], onWriteReview: { writing = true })
        """) { ModalStage { EmptyReviews() } },
    ])

    private static let inputs = KitSection("Other ratings", symbol: "face.smiling", [
        KitSample("Emoji faces", "Five faces that grow and wobble.", code: """
        @State private var mood: KitoRatingMood?
        KitoEmojiRating(selection: $mood)
        """) { EmojiSample() },
        KitSample("Thumbs", "A quick yes or no that flips and bursts.", code: """
        KitoThumbsRating(selection: $thumb, upCount: 128, downCount: 9)
        """) { ThumbsSample() },
        KitSample("NPS survey", "0 to 10, red to green, with the live score.", code: """
        KitoNPSScale(score: $score)
        KitoNPSCategory(score: 9)                      // .promoter
        KitoNPSCategory.netPromoterScore(answers)      // -100…100
        """) { NPSSample() },
        KitSample("Slider", "A value bubble with a face that follows along.", code: """
        KitoSliderRating(value: $spice, in: 0...10, step: 1)
        """) { SliderSample() },
    ])

    private static let prompt = KitSection("Asking for reviews", symbol: "hand.wave.fill", [
        KitSample("Enjoying Kito?", "Yes asks the system for a review; no opens a feedback form.", code: """
        var state = KitoReviewPromptState.load()
        state.recordSignificantEvent()
        if policy.decision(for: state, currentVersion: appVersion).shouldAsk {
            state.recordPrompt(version: appVersion)
            asking = true
        }
        state.save()

        content.kitoReviewPrompt(isPresented: $asking, appName: "Kito Market") { feedback in
            support.send(feedback)
        }
        """) { ModalStage { PromptScreen() } },
        KitSample("When to ask", "Events, install age, once per version and a cooldown.", code: """
        let policy = KitoReviewPromptPolicy(minimumSignificantEvents: 3, minimumDaysSinceInstall: 3,
                                            cooldownDays: 120, oncePerVersion: true)
        switch policy.decision(for: state, currentVersion: "3.0") {
        case .ask: asking = true
        case .needsMoreEvents, .tooSoonAfterInstall, .alreadyAskedThisVersion, .coolingDown: break
        }
        """) { PolicyPlayground() },
    ])

    static let sections: [KitSection] = [stars, summaries, cards, lists, inputs, prompt]
}

struct ReviewsGallery: View {
    static var count: Int { KitGallery.count(ReviewsSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Reviews & Ratings",
            sections: ReviewsSamples.sections,
            footnote: "Requires `import KitoReviews`.",
            searchHint: "Try “stars”, “histogram”, “card”, “composer”, “NPS” or “prompt”."
        )
    }
}
