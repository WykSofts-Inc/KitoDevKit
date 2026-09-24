//
//  FeedSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoFeed

// MARK: - Sample data

private enum FeedData {
    static let me = KitoFeedPerson(id: "me", name: "Wycliff N", handle: "wycliff", isVerified: true)

    static let amani = KitoFeedPerson(id: "amani", name: "Amani Otieno", handle: "amani_o", isVerified: true,
                                      followsYou: true, bio: "Photographer · Nairobi")
    static let wanjiru = KitoFeedPerson(id: "wanjiru", name: "Wanjiru Kamau", handle: "wanjiru", isFollowing: true,
                                        followsYou: true, bio: "Product designer")
    static let juma = KitoFeedPerson(id: "juma", name: "Juma Wafula", handle: "jwafula", bio: "Trail runner")
    static let zawadi = KitoFeedPerson(id: "zawadi", name: "Zawadi Achieng", handle: "zawadi", isFollowing: true,
                                       bio: "Coffee roaster · Kiambu")
    static let baraka = KitoFeedPerson(id: "baraka", name: "Baraka Kiprono", handle: "baraka.k", followsYou: true,
                                       bio: "iOS engineer")
    static let njeri = KitoFeedPerson(id: "njeri", name: "Njeri Wambui", handle: "njeri_w", isVerified: true,
                                      bio: "Food writer")
    static let halima = KitoFeedPerson(id: "halima", name: "Halima Said", handle: "halima", bio: "Mombasa · Sailing")
    static let otieno = KitoFeedPerson(id: "otieno", name: "Otieno Odhiambo", handle: "otieno", isFollowing: true)
    static let kip = KitoFeedPerson(id: "kip", name: "Kiprotich Rotich", handle: "kiprotich", followsYou: true)
    static let desk = KitoFeedPerson(id: "desk", name: "Savanna Daily", handle: "savannadaily", isVerified: true)

    static let people = [amani, wanjiru, juma, zawadi, baraka, njeri, halima, otieno, kip]

    static func ago(_ minutes: Double) -> Date { .now.addingTimeInterval(-minutes * 60) }

    // Generated "photos": gradients with a symbol, so the gallery works offline.
    static let sunrise = KitoFeedPhoto(id: "sunrise", colors: [.orange, .pink], symbol: "sun.horizon.fill",
                                       aspectRatio: 1.5, altText: "Sunrise over rolling hills")
    static let forest = KitoFeedPhoto(id: "forest", colors: [.green, .teal], symbol: "tree.fill",
                                      altText: "A forest path")
    static let coffee = KitoFeedPhoto(id: "coffee", colors: [.brown, .orange], symbol: "cup.and.saucer.fill",
                                      altText: "A cup of coffee")
    static let ocean = KitoFeedPhoto(id: "ocean", colors: [.cyan, .blue], symbol: "water.waves",
                                     altText: "The ocean at dawn")
    static let market = KitoFeedPhoto(id: "market", colors: [.yellow, .orange], symbol: "basket.fill",
                                      altText: "Baskets at a market")
    static let city = KitoFeedPhoto(id: "city", colors: [.indigo, .purple], symbol: "building.2.fill",
                                    altText: "City lights at night")
    static let dhow = KitoFeedPhoto(id: "dhow", colors: [.teal, .blue], symbol: "sailboat.fill",
                                    aspectRatio: 1.2, altText: "A dhow under sail")
    static let giraffe = KitoFeedPhoto(id: "giraffe", colors: [.orange, .brown], symbol: "pawprint.fill",
                                       altText: "Tracks on red earth")

    static let photos = [sunrise, forest, coffee, ocean, market, city, dhow, giraffe]

    static let hikeLink = KitoFeedLink(
        url: URL(string: "https://example.com/hikes-near-nairobi") ?? URL(fileURLWithPath: "/"),
        title: "Ten day hikes within two hours of the city",
        summary: "Forest loops, crater rims and a waterfall you can swim under, with maps and bus routes.",
        siteName: "Savanna Daily",
        image: KitoFeedPhoto(id: "hike", colors: [.green, .mint], symbol: "mountain.2.fill"))

    static func poll(voted: Bool, closed: Bool = false) -> KitoFeedPoll {
        KitoFeedPoll(id: voted ? "poll-voted" : "poll",
                     options: [KitoFeedPollOption(id: "chai", text: "Chai", votes: 412),
                               KitoFeedPollOption(id: "kahawa", text: "Kahawa", votes: 388),
                               KitoFeedPollOption(id: "juice", text: "Fresh juice", votes: 97),
                               KitoFeedPollOption(id: "water", text: "Just water", votes: 41)],
                     endsAt: closed ? .now.addingTimeInterval(-60) : .now.addingTimeInterval(2 * 3_600 + 120),
                     votedOptionID: voted ? "kahawa" : nil)
    }

    static let timelinePost = KitoFeedPost(
        id: "t1", author: amani, date: ago(2),
        text: "Sunrise over the Ngong hills with @wanjiru this morning. Worth the 4am alarm. #nairobi #hiking",
        media: .photos([sunrise, forest]), location: "Ngong Hills",
        likes: 1_204, comments: 38, reposts: 12, shareURL: URL(string: "https://example.com/p/t1"),
        likedBy: [wanjiru])

    static let cardPost = KitoFeedPost(
        id: "c1", author: zawadi, date: ago(95),
        text: "First roast of the season is out. Notes of blackcurrant and honey. @njeri_w come taste! #coffee",
        media: .photos([coffee]), location: "Kiambu",
        likes: 3_482, comments: 126, reposts: 40, likedBy: [wanjiru])

    static let newsPost = KitoFeedPost(
        id: "n1", author: desk, date: ago(180),
        text: "From forest loops to crater rims, these trails are an easy day out, and most are reachable by bus. Read the guide at example.com/hikes",
        media: .link(hikeLink), title: "The ten best day hikes within two hours of the city",
        likes: 842, comments: 57, reposts: 210)

    static let pollPost = KitoFeedPost(
        id: "poll1", author: baraka, date: ago(40),
        text: "Settling this once and for all. What's the first drink of your day? #mornings",
        media: .poll(poll(voted: false)), likes: 96, comments: 212, reposts: 8)

    static let videoPost = KitoFeedPost(
        id: "v1", author: halima, date: ago(60 * 5),
        text: "Racing the dhows off the old town at sunset ⛵️",
        media: .video(KitoFeedVideo(poster: dhow, duration: 94, viewCount: 18_300)),
        location: "Mombasa", likes: 2_310, comments: 64, reposts: 51)

    static let quotePost = KitoFeedPost(
        id: "q1", author: juma, date: ago(26 * 60),
        text: "This is the trail I was telling you about @baraka.k. Saturday?",
        quote: KitoFeedQuote(author: amani, text: "Sunrise over the Ngong hills this morning. Worth the 4am alarm.",
                             date: ago(26 * 60 + 30), photo: sunrise),
        repostedBy: wanjiru, likes: 48, comments: 6, reposts: 2)

    static let marketPost = KitoFeedPost(
        id: "m1", author: njeri, date: ago(60 * 30),
        text: "Saturday market haul: mangoes, sukuma, fresh ginger and far too many baskets. Recipes tomorrow! #eatlocal",
        media: .photos([market, giraffe, forest, coffee, ocean, city]), likes: 5_120, comments: 301, reposts: 97)

    static let textPost = KitoFeedPost(
        id: "x1", author: otieno, date: ago(12),
        text: "Shipped the new onboarding today. Huge thanks to @wanjiru for the designs and @baraka.k for staying late. Notes at https://example.com/changelog",
        likes: 312, comments: 18, reposts: 9)

    static let longText = """
    Spent the weekend on the coast learning to sail a dhow with @halima and her crew. The first hour was \
    mostly me holding the wrong rope. By the afternoon we were tacking across the creek, and by sunset I \
    could almost tell which way the wind was coming from. If you're ever in Lamu, ask around for the \
    Sunday lessons. Bring sunscreen, a hat and a sense of humour. #sailing #lamu
    """

    static let feed: [KitoFeedPost] = [timelinePost, textPost, pollPost, cardPost, videoPost, quotePost, marketPost, newsPost]

    static func olderPage(_ page: Int) -> [KitoFeedPost] {
        let authors = [kip, zawadi, juma, halima]
        return (0..<4).map { index in
            let photo = photos[(page * 4 + index) % photos.count]
            return KitoFeedPost(id: "older-\(page)-\(index)", author: authors[index], date: ago(Double(60 * 24 * (page + 2) + index * 90)),
                                text: "Throwback from week \(page + 1): still thinking about this view. #tbt",
                                media: index.isMultiple(of: 2) ? .photos([photo]) : nil,
                                likes: 120 * (index + 1), comments: 4 * index, reposts: index)
        }
    }

    static func freshPosts(_ round: Int) -> [KitoFeedPost] {
        let authors = [wanjiru, kip, njeri]
        let lines = ["Matatu art on Ngong Road is on another level today 🎨",
                     "Rain in Nairobi means one thing: chai and a good book. #weekend",
                     "Testing a new chapati recipe, results are... promising. @zawadi"]
        return (0..<3).map { index in
            KitoFeedPost(id: "fresh-\(round)-\(index)", author: authors[index], date: .now, text: lines[index],
                         media: index == 0 ? .photos([city]) : nil, likes: index * 3)
        }
    }

    static var comments: [KitoFeedComment] {
        [
            KitoFeedComment(id: "pin", author: amani, text: "Thanks everyone! Prints of this one are up next week 🙏",
                            date: ago(20), likes: 88, isPinned: true, badge: .author),
            KitoFeedComment(id: "k1", author: wanjiru, text: "This light is unreal. Which trailhead did you start from?",
                            date: ago(55), likes: 24, replies: [
                KitoFeedComment(id: "k1r1", author: amani, text: "@wanjiru the one by the wind turbines, gate opens at 6.",
                                date: ago(50), likes: 9, badge: .author, replies: [
                    KitoFeedComment(id: "k1r1r1", author: juma, text: "Can confirm, parking is easy before 7 too.",
                                    date: ago(44), likes: 3),
                ]),
                KitoFeedComment(id: "k1r2", author: baraka, text: "Adding this to the Saturday plan 📍", date: ago(41), likes: 2),
                KitoFeedComment(id: "k1r3", author: zawadi, text: "Bring a jacket, it's cold up there before sunrise!",
                                date: ago(38), likes: 6),
                KitoFeedComment(id: "k1r4", author: kip, text: "How long is the full ridge?", date: ago(30)),
            ]),
            KitoFeedComment(id: "k2", author: njeri, text: "Framing this for my kitchen. #goals", date: ago(90), likes: 12,
                            badge: .topFan),
            KitoFeedComment(id: "k3", author: halima, text: "Next time come to the coast for sunrise over the ocean 🌊",
                            date: ago(120), likes: 5, replies: [
                KitoFeedComment(id: "k3r1", author: amani, text: "@halima deal. Lamu in December?", date: ago(110),
                                likes: 4, badge: .author),
            ]),
        ]
    }
}

// MARK: - Post samples

private struct FeedPostSample: View {
    @State var post: KitoFeedPost
    let style: KitoFeedPostStyle
    var lineLimit: Int? = 5

    var body: some View {
        KitoFeedPostView(post: $post, style: style, lineLimit: lineLimit)
            .padding(.horizontal, -24)
    }
}

private struct FeedMinimalSample: View {
    @State private var posts = [FeedData.textPost, FeedData.quotePost, FeedData.pollPost]

    var body: some View {
        VStack(spacing: 0) {
            ForEach($posts) { $post in
                KitoFeedPostView(post: $post, style: .minimal)
                if post.id != posts.last?.id { Divider() }
            }
        }
        .padding(.horizontal, -24)
    }
}

private struct FeedGridsSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach([1, 2, 3, 4, 7], id: \.self) { count in
                VStack(alignment: .leading, spacing: 6) {
                    Text(count == 1 ? "1 photo" : "\(count) photos").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    KitoFeedPhotoGrid(photos: Array((FeedData.photos + FeedData.photos).prefix(count))) { _ in }
                }
            }
        }
    }
}

private struct FeedMediaSample: View {
    var body: some View {
        VStack(spacing: 16) {
            KitoFeedVideoPoster(video: KitoFeedVideo(poster: FeedData.dhow, duration: 94, viewCount: 18_300))
            KitoLinkPreviewCard(link: FeedData.hikeLink)
            KitoLinkPreviewCard(link: FeedData.hikeLink, style: .compact)
        }
    }
}

private struct FeedMenuSample: View {
    @State private var post = FeedData.textPost
    @State private var last = "Tap … on the post"

    var body: some View {
        VStack(spacing: 12) {
            KitoFeedPostView(post: $post, style: .social)
                .padding(.horizontal, -24)
            Label(last, systemImage: "ellipsis.circle").font(.footnote).foregroundStyle(.secondary)
        }
        .kitoFeedActions(KitoFeedActions(onMenu: { _, action in last = "Menu: \(String(describing: action))" }))
    }
}

// MARK: - Interaction samples

private struct FeedLikeSample: View {
    @State private var small = false
    @State private var smallCount = 41
    @State private var big = true
    @State private var bigCount = 1_204
    @State private var bare = false

    var body: some View {
        HStack(spacing: 36) {
            KitoFeedLikeButton(isLiked: $small, count: $smallCount)
            KitoFeedLikeButton(isLiked: $big, count: $bigCount, size: 30)
            KitoFeedLikeButton(isLiked: $bare, count: .constant(0), showsCount: false, size: 26, tint: .pink)
        }
        .padding(.vertical, 20)
    }
}

private struct FeedActionBarSample: View {
    @State private var post = FeedData.cardPost

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach([("Spread", KitoFeedActionBar.Layout.spread), ("Leading", .leading), ("Compact", .compact)], id: \.0) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.0).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    KitoFeedActionBar(post: $post, layout: item.1)
                }
            }
        }
    }
}

private struct FeedRichTextSample: View {
    @State private var tapped = "Tap a mention, hashtag or link"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            KitoRichText("Lunch with @amani_o and @wanjiru at the new place in Westlands 🍜 #nairobi #foodie — menu at example.com/menu",
                         onMention: { tapped = "Mention: @\($0)" },
                         onHashtag: { tapped = "Hashtag: #\($0)" },
                         onLink: { tapped = "Link: \($0.absoluteString)" })
            Label(tapped, systemImage: "hand.tap").font(.footnote).foregroundStyle(.secondary)
        }
    }
}

private struct FeedReadMoreSample: View {
    var body: some View {
        KitoRichText(FeedData.longText, lineLimit: 3)
    }
}

private struct FeedFollowSample: View {
    @State private var first = false
    @State private var second = true
    @State private var third = false

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                KitoFeedAvatar(person: FeedData.juma, size: 44)
                Text(FeedData.juma.name).font(.headline)
                Spacer()
                KitoFollowButton(isFollowing: $first, name: FeedData.juma.name)
            }
            HStack(spacing: 12) {
                KitoFeedAvatar(person: FeedData.wanjiru, size: 44)
                Text(FeedData.wanjiru.name).font(.headline)
                Spacer()
                KitoFollowButton(isFollowing: $second, name: FeedData.wanjiru.name)
            }
            KitoFollowButton(isFollowing: $third, name: FeedData.baraka.name, followsYou: true, size: .regular,
                             confirmsUnfollow: false)
        }
    }
}

private struct FeedPollSample: View {
    @State private var open = FeedData.poll(voted: false)
    @State private var voted = FeedData.poll(voted: true)
    @State private var closed = FeedData.poll(voted: false, closed: true)

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            section("Tap to vote") { KitoPollView(poll: $open) }
            section("Voted") { KitoPollView(poll: $voted, tint: .green) }
            section("Closed") { KitoPollView(poll: $closed, tint: .purple) }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            content()
        }
    }
}

// MARK: - Feed screens

private struct FeedLiveScreen: View {
    var style: KitoFeedPostStyle = .social
    @State private var posts = FeedData.feed
    @State private var page = 0
    @State private var round = 0
    @State private var composing = false
    @State private var commentsFor: KitoFeedPost?
    @State private var likesFor: KitoFeedPost?
    @State private var quoting: KitoFeedPost?

    init(style: KitoFeedPostStyle = .social) {
        self.style = style
    }

    var body: some View {
        NavigationStack {
            KitoFeedView(posts: $posts, style: style, hasMore: page < 3,
                         onRefresh: refresh, onLoadMore: loadMore, onCompose: { composing = true })
                .navigationTitle(style == .card ? "Discover" : "Home")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("New posts", systemImage: "sparkles", action: simulateNewPosts)
                    }
                }
        }
        .kitoFeedActions(KitoFeedActions(
            onComment: { commentsFor = $0 },
            onRepost: { post, kind in if kind == .quote { quoting = post } },
            onShowLikes: { likesFor = $0 }))
        .sheet(isPresented: $composing) {
            KitoPostComposer(author: FeedData.me, people: FeedData.people, onCancel: { composing = false }) { composed in
                posts.insert(composed.makePost(author: FeedData.me), at: 0)
                composing = false
            }
        }
        .sheet(item: $quoting) { post in
            KitoPostComposer(author: FeedData.me, people: FeedData.people,
                             quoting: KitoFeedQuote(author: post.author, text: post.text, date: post.date),
                             placeholder: "Add a comment", onCancel: { quoting = nil }) { composed in
                posts.insert(composed.makePost(author: FeedData.me), at: 0)
                quoting = nil
            }
        }
        .sheet(item: $commentsFor) { post in FeedCommentsSheet(post: post) }
        .sheet(item: $likesFor) { post in FeedLikesHost(total: post.likes) }
    }

    /// Drops three posts in at the top, as if they'd just arrived. Scroll down first to see the pill.
    private func simulateNewPosts() {
        round += 1
        posts.insert(contentsOf: FeedData.freshPosts(round), at: 0)
    }

    private func refresh() async {
        try? await Task.sleep(for: .seconds(1))
        round += 1
        posts.insert(contentsOf: FeedData.freshPosts(round).prefix(1), at: 0)
    }

    private func loadMore() async {
        try? await Task.sleep(for: .seconds(1.2))
        posts.append(contentsOf: FeedData.olderPage(page))
        page += 1
    }
}

private struct FeedFirstLoadScreen: View {
    @State private var posts: [KitoFeedPost] = []
    @State private var loading = true

    var body: some View {
        NavigationStack {
            KitoFeedView(posts: $posts, isLoading: loading, onRefresh: reload)
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Reload", systemImage: "arrow.clockwise") { Task { await reload() } }
                    }
                }
        }
        .task { await reload() }
    }

    private func reload() async {
        posts = []
        loading = true
        try? await Task.sleep(for: .seconds(2))
        posts = Array(FeedData.feed.prefix(4))
        loading = false
    }
}

// MARK: - Comments

private struct FeedCommentsSheet: View {
    @State private var post: KitoFeedPost
    @State private var comments = FeedData.comments
    @Environment(\.dismiss) private var dismiss

    init(post: KitoFeedPost) {
        _post = State(initialValue: post)
    }

    var body: some View {
        NavigationStack {
            KitoCommentsView(comments: $comments, currentUser: FeedData.me, people: FeedData.people) {
                KitoFeedPostView(post: $post, style: .minimal, lineLimit: 3)
                Divider()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
    }
}

private struct FeedCommentsScreen: View {
    @State private var post = FeedData.timelinePost
    @State private var comments = FeedData.comments

    var body: some View {
        NavigationStack {
            KitoCommentsView(comments: $comments, currentUser: FeedData.me, people: FeedData.people) {
                KitoFeedPostView(post: $post, style: .minimal, lineLimit: 3)
                Divider()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct FeedThreadSample: View {
    @State private var comments = FeedData.comments
    @State private var replyingTo = "Tap Reply on a comment"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KitoCommentThread(comments: $comments, previewReplies: 1, onReply: { comment in
                replyingTo = "Reply to @\(comment.author.handle)"
            })
            .padding(.horizontal, -24)
            Label(replyingTo, systemImage: "arrowshape.turn.up.left").font(.footnote).foregroundStyle(.secondary)
        }
    }
}

private struct FeedComposerBarSample: View {
    @State private var text = "Great shot @"
    @State private var sent: [String] = []

    var body: some View {
        VStack(spacing: 12) {
            ForEach(sent, id: \.self) { line in
                KitoRichText(line, font: .subheadline).frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: 230)
            KitoCommentComposer(text: $text, author: FeedData.me, people: FeedData.people,
                                replyingTo: FeedData.amani, onCancelReply: {}) { message in
                sent.append(message)
                text = ""
            }
            .padding(.horizontal, -24)
        }
    }
}

private struct FeedLikesHost: View {
    let total: Int
    @State private var people = FeedData.people

    init(total: Int) {
        self.total = total
    }

    var body: some View {
        KitoLikesSheet(people: $people, total: total, currentUserID: FeedData.me.id)
    }
}

private struct FeedLikesScreen: View {
    @State private var showing = false
    @State private var post = FeedData.cardPost

    var body: some View {
        NavigationStack {
            ScrollView {
                KitoFeedPostView(post: $post, style: .card)
                Button("Show likes") { showing = true }
                    .buttonStyle(GalleryPrimaryButtonStyle())
                    .padding()
            }
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
        }
        .kitoFeedActions(KitoFeedActions(onShowLikes: { _ in showing = true }))
        .sheet(isPresented: $showing) { FeedLikesHost(total: post.likes) }
    }
}

// MARK: - Composer

private struct FeedComposerScreen: View {
    @State private var posted: String?

    var body: some View {
        KitoPostComposer(author: FeedData.me, people: FeedData.people, text: "Morning run along the river with @",
                         onCancel: { posted = nil }) { composed in
            posted = composed.text
        }
        .overlay(alignment: .top) {
            if let posted {
                Label("Posted: \(posted)", systemImage: "checkmark.circle.fill")
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: Capsule())
                    .padding(.top, 56)
                    .padding(.horizontal)
            }
        }
    }
}

private struct FeedCounterSample: View {
    @State private var count = 240.0

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 28) {
                KitoCharacterCounterRing(count: Int(count), limit: 280)
                Text("\(280 - Int(count)) left").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
            }
            Slider(value: $count, in: 0...320, step: 1)
        }
    }
}

private struct FeedFormatSample: View {
    private let times: [(String, Double)] = [("30 seconds", 0.5), ("2 minutes", 2), ("3 hours", 180),
                                             ("30 hours", 1_800), ("4 days", 5_760), ("3 weeks", 30_240)]
    private let counts = [999, 1_250, 12_400, 123_456, 3_450_000, 1_100_000_000]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 8) {
            ForEach(times, id: \.0) { item in
                GridRow {
                    Text(item.0 + " ago").foregroundStyle(.secondary)
                    Text(KitoFeedFormat.relativeTime(from: FeedData.ago(item.1))).fontWeight(.semibold)
                }
            }
            Divider()
            ForEach(counts, id: \.self) { count in
                GridRow {
                    Text(count.formatted()).foregroundStyle(.secondary)
                    Text(KitoFeedFormat.compactCount(count)).fontWeight(.semibold)
                }
            }
        }
        .font(.subheadline.monospacedDigit())
    }
}

// MARK: - Gallery

enum FeedSamples {
    private static let posts = KitSection("Posts", symbol: "text.bubble", [
        KitSample("Timeline post", "Avatar column, photos, counts along the bottom.", code: """
        KitoFeedPostView(post: $post, style: .social)
        """) { FeedPostSample(post: FeedData.timelinePost, style: .social) },
        KitSample("Photo card", "Edge-to-edge photo, double-tap to like, “Liked by … and 3,481 others”.", code: """
        KitoFeedPostView(post: $post, style: .card)
            .kitoFeedActions(KitoFeedActions(onShowLikes: { showLikes($0) }))
        """) { FeedPostSample(post: FeedData.cardPost, style: .card) },
        KitSample("Minimal", "Name, text and small icons for dense lists.", code: """
        ForEach($posts) { $post in
            KitoFeedPostView(post: $post, style: .minimal)
        }
        """) { FeedMinimalSample() },
        KitSample("News story", "Media first, then the source, a headline and a summary.", code: """
        KitoFeedPost(id: "n1", author: desk, date: date, text: summary,
                     media: .link(link), title: "The ten best day hikes within two hours of the city")
        KitoFeedPostView(post: $post, style: .news)
        """) { FeedPostSample(post: FeedData.newsPost, style: .news) },
        KitSample("Photo grids", "One, two, three, four, and “+N” past four.", code: """
        KitoFeedPhotoGrid(photos: photos) { index in openViewer(at: index) }
        """) { FeedGridsSample() },
        KitSample("Video and link cards", "A poster with play and running time; large and compact link cards.", code: """
        KitoFeedVideoPoster(video: KitoFeedVideo(poster: poster, duration: 94, viewCount: 18_300)) { play() }
        KitoLinkPreviewCard(link: link)                     // .compact
        """) { FeedMediaSample() },
        KitSample("Quotes and reposts", "“Wanjiru reposted” above a post that quotes another.", code: """
        KitoFeedPost(id: "q1", author: juma, date: date, text: "Saturday?",
                     quote: KitoFeedQuote(author: amani, text: original, date: then, photo: sunrise),
                     repostedBy: wanjiru)
        """) { FeedPostSample(post: FeedData.quotePost, style: .social) },
        KitSample("Not interested, mute, report", "The … menu folds the post into a note with Undo.", code: """
        KitoFeedPostView(post: $post)
            .kitoFeedActions(KitoFeedActions(onMenu: { post, action in api.send(action, for: post.id) }))
        """) { FeedMenuSample() },
    ])

    private static let interactions = KitSection("Interactions", symbol: "heart", [
        KitSample("Like burst", "A ring and dots fly out, the heart springs, the count rolls.", code: """
        KitoFeedLikeButton(isLiked: $post.isLiked, count: $post.likes)
        KitoFeedLikeButton(isLiked: $liked, count: .constant(0), showsCount: false, size: 26, tint: .pink)
        """) { FeedLikeSample() },
        KitSample("Action bar layouts", "Spread, leading and compact; repost opens Repost or Quote.", code: """
        KitoFeedActionBar(post: $post, layout: .spread)   // .leading, .compact
        """) { FeedActionBarSample() },
        KitSample("Mentions, hashtags and links", "Styled and tappable, with a handler for each.", code: """
        KitoRichText(text, onMention: { openProfile($0) },
                     onHashtag: { openTag($0) },
                     onLink: { open($0) })
        """) { FeedRichTextSample() },
        KitSample("Read more", "Long text cut to three lines, expanding in place.", code: """
        KitoRichText(longText, lineLimit: 3)
        """) { FeedReadMoreSample() },
        KitSample("Follow button", "Follow springs into an outlined Following; asks before unfollowing.", code: """
        KitoFollowButton(isFollowing: $person.isFollowing, name: person.name)
        KitoFollowButton(isFollowing: $following, name: name, followsYou: true, size: .regular)
        """) { FeedFollowSample() },
        KitSample("Polls", "Vote, then bars grow and percentages count up; “2h left”.", code: """
        KitoPollView(poll: $poll) { option in api.vote(option.id) }
        """) { FeedPollSample() },
    ])

    private static let feed = KitSection("Feed", symbol: "list.bullet.rectangle", [
        KitSample("Home feed", "Pull to refresh, endless loading, compose, comments and likes. Tap ✨ after scrolling for the new-posts pill.", code: """
        KitoFeedView(posts: $posts, hasMore: hasMore,
                     onRefresh: { await model.refresh() },
                     onLoadMore: { await model.loadMore() },
                     onCompose: { composing = true })
            .kitoFeedActions(KitoFeedActions(onComment: { commentsFor = $0 },
                                             onShowLikes: { likesFor = $0 }))
        """) { ModalStage { FeedLiveScreen() } },
        KitSample("Card feed", "The same feed with raised photo cards.", code: """
        KitoFeedView(posts: $posts, style: .card, hasMore: hasMore, onLoadMore: loadMore)
        """) { ModalStage { FeedLiveScreen(style: .card) } },
        KitSample("First load", "Shimmering skeletons until the first page arrives.", code: """
        KitoFeedView(posts: $posts, isLoading: posts.isEmpty, onRefresh: reload)
        """) { ModalStage { FeedFirstLoadScreen() } },
    ])

    private static let comments = KitSection("Comments", symbol: "bubble.left.and.bubble.right", [
        KitSample("Comments screen", "Reply fills in @name, sends under the right comment and scrolls to it.", code: """
        KitoCommentsView(comments: $comments, currentUser: me, people: following,
                         onSend: { comment, parentID in api.add(comment, to: parentID) }) {
            KitoFeedPostView(post: $post, style: .minimal)
        }
        """) { ModalStage { FeedCommentsScreen() } },
        KitSample("Threaded replies", "Connector lines, a pinned comment, “View 3 more replies”.", code: """
        KitoCommentThread(comments: $comments, previewReplies: 1, onReply: { comment in
            draft = "@\\(comment.author.handle) "
        })
        """) { FeedThreadSample() },
        KitSample("Comment composer", "Emoji quick-bar, “Replying to …” and @mention suggestions.", code: """
        KitoCommentComposer(text: $draft, author: me, people: following,
                            replyingTo: target?.author, onCancelReply: { target = nil }) { send($0) }
        """) { FeedComposerBarSample() },
        KitSample("Likes sheet", "Searchable likers with “Follows you” and Follow buttons.", code: """
        .sheet(isPresented: $showLikes) {
            KitoLikesSheet(people: $likers, total: post.likes) { person, following in
                api.follow(person.id, following)
            }
        }
        """) { ModalStage { FeedLikesScreen() } },
    ])

    private static let composer = KitSection("Composer", symbol: "square.and.pencil", [
        KitSample("Post composer", "Live highlighting, @ suggestions, photos, a poll builder and audience.", code: """
        KitoPostComposer(author: me, people: following, onCancel: { composing = false }) { composed in
            posts.insert(composed.makePost(author: me), at: 0)
        }
        """) { ModalStage { FeedComposerScreen() } },
        KitSample("Character ring", "Fills as you type, counts down the last 20, turns red when over.", code: """
        KitoCharacterCounterRing(count: text.count, limit: 280)
        """) { FeedCounterSample() },
        KitSample("Times and counts", "“2m”, “Yesterday”, “1.2K”, “3.4M”.", code: """
        KitoFeedFormat.relativeTime(from: post.date)   // "3h"
        KitoFeedFormat.compactCount(12_400)            // "12.4K"
        """) { FeedFormatSample() },
    ])

    static let sections: [KitSection] = [posts, interactions, feed, comments, composer]
}

struct FeedGallery: View {
    static var count: Int { KitGallery.count(FeedSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Feed & Comments",
            sections: FeedSamples.sections,
            footnote: "Requires `import KitoFeed`.",
            searchHint: "Try “poll”, “like”, “thread”, “mention”, “composer” or “pill”."
        )
    }
}
