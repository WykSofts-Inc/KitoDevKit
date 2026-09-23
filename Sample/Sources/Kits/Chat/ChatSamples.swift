//
//  ChatSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import UIKit
import KitoChat

// MARK: - Cast

private enum People {
    static let me = KitoChatUser(id: "wycliff", name: "Wycliff N", isOnline: true)
    static let amani = KitoChatUser(id: "amani", name: "Amani Wanjiru", isOnline: true)
    static let baraka = KitoChatUser(id: "baraka", name: "Baraka Otieno")
    static let chebet = KitoChatUser(id: "chebet", name: "Chebet Kiprono", isOnline: true)
    static let njeri = KitoChatUser(id: "njeri", name: "Njeri Kamau", isOnline: true)
    static let juma = KitoChatUser(id: "juma", name: "Juma Hassan")
    static let zawadi = KitoChatUser(id: "zawadi", name: "Zawadi Mwangi", isOnline: true)
    static let achieng = KitoChatUser(id: "achieng", name: "Achieng Odhiambo")
    static let safariCrew = KitoChatUser(id: "safari-crew", name: "Safari Crew", color: .orange)
}

private func minutesAgo(_ minutes: Double) -> Date { Date().addingTimeInterval(-minutes * 60) }

private func daysAgo(_ days: Int, hour: Int, minute: Int = 0) -> Date {
    let calendar = Calendar.current
    let day = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
}

// MARK: - Photos

/// Painted scenes so the photo samples work offline.
private enum Photos {
    static let naivasha = scene(
        sky: [UIColor(red: 0.98, green: 0.62, blue: 0.38, alpha: 1), UIColor(red: 0.62, green: 0.36, blue: 0.62, alpha: 1)],
        sun: UIColor(red: 1, green: 0.86, blue: 0.55, alpha: 1),
        water: UIColor(red: 0.27, green: 0.25, blue: 0.45, alpha: 1)
    )
    static let diani = scene(
        sky: [UIColor(red: 0.45, green: 0.78, blue: 0.98, alpha: 1), UIColor(red: 0.80, green: 0.93, blue: 1, alpha: 1)],
        sun: UIColor(red: 1, green: 0.97, blue: 0.80, alpha: 1),
        water: UIColor(red: 0.10, green: 0.66, blue: 0.72, alpha: 1)
    )
    static let karura = scene(
        sky: [UIColor(red: 0.62, green: 0.84, blue: 0.62, alpha: 1), UIColor(red: 0.95, green: 0.93, blue: 0.75, alpha: 1)],
        sun: UIColor(red: 1, green: 0.95, blue: 0.70, alpha: 1),
        water: UIColor(red: 0.18, green: 0.42, blue: 0.25, alpha: 1)
    )

    static func scene(sky: [UIColor], sun: UIColor, water: UIColor, size: CGSize = CGSize(width: 900, height: 675)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            let cg = context.cgContext
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: sky.map(\.cgColor) as CFArray, locations: nil) {
                cg.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height * 0.68), options: [.drawsAfterEndLocation])
            }
            sun.setFill()
            cg.fillEllipse(in: CGRect(x: size.width * 0.56, y: size.height * 0.30, width: size.width * 0.2, height: size.width * 0.2))
            let hills = UIBezierPath()
            hills.move(to: CGPoint(x: 0, y: size.height * 0.62))
            hills.addCurve(to: CGPoint(x: size.width, y: size.height * 0.60),
                           controlPoint1: CGPoint(x: size.width * 0.3, y: size.height * 0.48),
                           controlPoint2: CGPoint(x: size.width * 0.6, y: size.height * 0.70))
            hills.addLine(to: CGPoint(x: size.width, y: size.height))
            hills.addLine(to: CGPoint(x: 0, y: size.height))
            water.withAlphaComponent(0.65).setFill()
            hills.fill()
            water.setFill()
            cg.fill(CGRect(x: 0, y: size.height * 0.68, width: size.width, height: size.height * 0.32))
            UIColor.white.withAlphaComponent(0.28).setFill()
            for index in 0..<7 {
                let width = size.width * (0.18 - CGFloat(index) * 0.018)
                cg.fill(CGRect(x: size.width * 0.66 - width / 2, y: size.height * (0.71 + CGFloat(index) * 0.035), width: width, height: 5))
            }
        }
    }
}

// MARK: - Scripts

private enum Script {
    static let replies = [
        "Sawa sawa 👍🏾",
        "Haha 😂 uko sure?",
        "Niko njiani, traffic ya Thika Road ni mbaya 😩",
        "Poa! Tuonane basi",
        "Nimeona 🙏🏾",
        "Asante sana!",
    ]

    static func amani() -> [KitoChatMessage] {
        let lunch = KitoChatMessage(id: "a6", author: People.amani, text: "Java House Kimathi Street, saa saba?", date: minutesAgo(42))
        return [
            KitoChatMessage(id: "a1", author: People.amani, text: "Umefika Naivasha salama?", date: daysAgo(3, hour: 16, minute: 5)),
            KitoChatMessage(id: "a2", author: People.me, text: "Eeh! Tumefika saa kumi. Hii place ni **poa sana** 😍", date: daysAgo(3, hour: 16, minute: 20), status: .read),
            KitoChatMessage(id: "a3", author: People.me, date: daysAgo(3, hour: 16, minute: 21),
                            kind: .image(KitoChatImage(Photos.naivasha, caption: "Lake Naivasha from the boat")), status: .read,
                            reactions: [KitoChatReaction("❤️", userIDs: [People.amani.id])]),
            KitoChatMessage(id: "a4", author: People.amani, date: daysAgo(1, hour: 19, minute: 40),
                            kind: .voice(duration: 14, waveform: KitoWaveform.placeholder(count: 48, seed: 11))),
            KitoChatMessage(id: "a5", author: People.me, text: "Haha sawa, nitakuletea mandazi 😂", date: daysAgo(1, hour: 19, minute: 44), status: .read,
                            reactions: [KitoChatReaction("😂", userIDs: [People.amani.id])]),
            KitoChatMessage(id: "a5b", author: People.amani, text: "Kesho tuko on for lunch?", date: minutesAgo(43)),
            lunch,
            KitoChatMessage(id: "a7", author: People.me, text: "Perfect 👌🏾 Nitafika saa saba kasoro", date: minutesAgo(40), status: .read, replyTo: KitoChatReply(lunch)),
            KitoChatMessage(id: "a8", author: People.amani, text: "🔥", date: minutesAgo(39)),
        ]
    }

    static func safariCrew() -> [KitoChatMessage] {
        [
            KitoChatMessage(id: "s0", author: People.chebet, date: daysAgo(1, hour: 9), kind: .system("Chebet created the group “Safari Crew”")),
            KitoChatMessage(id: "s1", author: People.chebet, text: "Watu wa Diani mko wapi? 🏖️", date: daysAgo(1, hour: 9, minute: 2)),
            KitoChatMessage(id: "s2", author: People.baraka, text: "Mimi niko in! Tunaenda na SGR?", date: daysAgo(1, hour: 9, minute: 10)),
            KitoChatMessage(id: "s3", author: People.baraka, text: "Economy ni 1,500 kila mtu", date: daysAgo(1, hour: 9, minute: 11)),
            KitoChatMessage(id: "s4", author: People.amani, text: "SGR ni best. Tuonane Syokimau saa moja asubuhi", date: daysAgo(1, hour: 9, minute: 30),
                            reactions: [KitoChatReaction("👍", userIDs: [People.baraka.id, People.chebet.id, People.me.id])]),
            KitoChatMessage(id: "s5", author: People.me, text: "Nimebook yangu ✅", date: daysAgo(1, hour: 9, minute: 45), status: .read),
            KitoChatMessage(id: "s6", author: People.juma, date: minutesAgo(80), kind: .system("Juma joined")),
            KitoChatMessage(id: "s7", author: People.chebet, date: minutesAgo(30),
                            kind: .image(KitoChatImage(Photos.diani, caption: "Our place in Diani 🌴")),
                            reactions: [KitoChatReaction("😮", userIDs: [People.amani.id]), KitoChatReaction("❤️", userIDs: [People.baraka.id, People.juma.id])]),
            KitoChatMessage(id: "s8", author: People.juma, text: "Karibuni Pwani! Nitawapeleka Kongo River 🚤", date: minutesAgo(12)),
        ]
    }

    static func njeri() -> [KitoChatMessage] {
        let lines: [(KitoChatUser, String)] = [
            (People.njeri, "Karura run bado iko Jumamosi?"),
            (People.me, "Iko! 7am Limuru Road gate"),
            (People.njeri, "Poa. Tutafanya 10K ama 5K?"),
            (People.me, "10K, tuko fit 💪🏾"),
            (People.njeri, "Hehe sawa, nitaleta maji"),
            (People.me, "Na usisahau sunscreen ☀️"),
            (People.njeri, "Umeona the new trail by the waterfall?"),
            (People.me, "Bado, tutaenda kuona"),
            (People.njeri, "Nimewaambia Achieng na Otieno pia"),
            (People.me, "Nice, the more the merrier"),
            (People.njeri, "Tukimaliza tuende River Café breakfast?"),
            (People.njeri, "Wanapika pancakes poa sana 🥞"),
            (People.njeri, "Also nimeget new running shoes"),
            (People.njeri, "Ziko fresh 👟"),
            (People.njeri, "Utaona tu"),
        ]
        return lines.enumerated().map { index, line in
            KitoChatMessage(id: "n\(index)", author: line.0, text: line.1, date: minutesAgo(Double(60 - index * 3)), status: .read)
        }
    }

    static let feed = [
        "Btw weather ni sunny Jumamosi",
        "Nimecheck forecast, hakuna mvua 🌤️",
        "Otieno anasema atakuja late kidogo",
        "Achieng ameconfirm!",
        "Ok see you at the gate 🏃🏾‍♀️",
        "Usiwe late 😂",
    ]

    static func zawadi() -> [KitoChatMessage] {
        [
            KitoChatMessage(id: "z1", author: People.zawadi, text: "Nimefika Kilifi 🌊 Bofa beach ni kama picha", date: minutesAgo(90)),
            KitoChatMessage(id: "z2", author: People.zawadi, date: minutesAgo(89), kind: .image(KitoChatImage(Photos.diani))),
            KitoChatMessage(id: "z3", author: People.me, text: "Wow! Hiyo maji ni turquoise kabisa", date: minutesAgo(70), status: .read,
                            reactions: [KitoChatReaction("🙏", userIDs: [People.zawadi.id])]),
            KitoChatMessage(id: "z4", author: People.me, date: minutesAgo(69), kind: .voice(duration: 9, waveform: KitoWaveform.placeholder(count: 40, seed: 5)), status: .read),
            KitoChatMessage(id: "z5", author: People.zawadi, text: "Next time lazima uje 😎", date: minutesAgo(20)),
        ]
    }

    static func inbox() -> [KitoChatConversation] {
        [
            KitoChatConversation(id: "c-amani", user: People.amani, lastMessage: KitoChatMessage(author: People.amani, text: "Java House Kimathi Street, saa saba?", date: minutesAgo(8)), unreadCount: 2, isPinned: true),
            KitoChatConversation(id: "c-safari", user: People.safariCrew, title: "Safari Crew 🏖️",
                                 lastMessage: KitoChatMessage(author: People.juma, text: "Karibuni Pwani!", date: minutesAgo(12)), unreadCount: 14, isMuted: true, isTyping: true),
            KitoChatConversation(id: "c-njeri", user: People.njeri, lastMessage: KitoChatMessage(author: People.me, text: "10K, tuko fit 💪🏾", date: minutesAgo(55), status: .delivered)),
            KitoChatConversation(id: "c-zawadi", user: People.zawadi, lastMessage: KitoChatMessage(author: People.zawadi, date: daysAgo(1, hour: 18), kind: .image(KitoChatImage(Photos.diani, caption: "Bofa beach"))), unreadCount: 1),
            KitoChatConversation(id: "c-baraka", user: People.baraka, lastMessage: KitoChatMessage(author: People.baraka, date: daysAgo(2, hour: 11), kind: .voice(duration: 23, waveform: []))),
            KitoChatConversation(id: "c-juma", user: People.juma, lastMessage: KitoChatMessage(author: People.me, text: "Nitakutumia location", date: daysAgo(4, hour: 9), status: .read)),
            KitoChatConversation(id: "c-achieng", user: People.achieng, lastMessage: KitoChatMessage(author: People.achieng, text: "Happy birthday Wycliff! 🎂🎉", date: daysAgo(12, hour: 7)), isMuted: true),
        ]
    }
}

// MARK: - Full-screen chats

/// A conversation that answers back: your message goes sent → delivered, someone types, replies,
/// and your message turns read.
private struct LiveChat: View {
    let contact: KitoChatUser
    var title: String?
    var subtitle: String?
    var responders: [KitoChatUser]
    var style: KitoChatBubbleStyle = .modern
    var wallpaper: KitoChatWallpaper = .plain
    var unreadCount = 0
    var tint: Color?
    var showsStylePicker = false
    var onBack: (() -> Void)?

    @State private var messages: [KitoChatMessage]
    @State private var typing: [KitoChatUser] = []
    @State private var replyIndex = 0
    @State private var pickedStyle: KitoChatBubbleStyle

    init(contact: KitoChatUser, title: String? = nil, subtitle: String? = nil, responders: [KitoChatUser], messages: [KitoChatMessage],
         style: KitoChatBubbleStyle = .modern, wallpaper: KitoChatWallpaper = .plain, unreadCount: Int = 0, tint: Color? = nil, showsStylePicker: Bool = false, onBack: (() -> Void)? = nil) {
        self.contact = contact
        self.title = title
        self.subtitle = subtitle
        self.responders = responders
        self.style = style
        self.wallpaper = wallpaper
        self.unreadCount = unreadCount
        self.tint = tint
        self.showsStylePicker = showsStylePicker
        self.onBack = onBack
        _messages = State(initialValue: messages)
        _pickedStyle = State(initialValue: style)
    }

    var body: some View {
        VStack(spacing: 0) {
            KitoChatHeader(user: contact, title: title, typingUsers: typing, subtitle: subtitle, tint: tint, onBack: onBack)
            if showsStylePicker {
                Picker("Bubble style", selection: $pickedStyle.animation(.snappy)) {
                    ForEach(KitoChatBubbleStyle.allCases) { style in Text(style.title).tag(style) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.bar)
            }
            KitoChatView(
                messages: $messages,
                currentUser: People.me,
                style: pickedStyle,
                wallpaper: pickedStyle == .glass ? .aurora : wallpaper,
                typingUsers: typing,
                unreadCount: unreadCount,
                tint: tint,
                onAttach: sendPhoto
            ) { message in
                deliver(message)
            }
        }
    }

    private func sendPhoto() {
        let photo = KitoChatMessage(author: People.me, kind: .image(KitoChatImage(Photos.karura, caption: "Karura this morning 🌿")), status: .sending)
        messages.append(photo)
        deliver(photo)
    }

    private func deliver(_ message: KitoChatMessage) {
        let responder = responders[replyIndex % max(1, responders.count)]
        let reply = Script.replies[replyIndex % Script.replies.count]
        replyIndex += 1
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(600))
            messages.kitoUpdateStatus(of: message.id, to: .sent)
            try? await Task.sleep(for: .milliseconds(700))
            messages.kitoUpdateStatus(of: message.id, to: .delivered)
            try? await Task.sleep(for: .milliseconds(500))
            typing = [responder]
            messages.kitoUpdateStatus(of: message.id, to: .read)
            try? await Task.sleep(for: .seconds(1.8))
            typing = []
            if case .voice = message.kind {
                messages.append(KitoChatMessage(author: responder, text: "Nimesikia 🎧 sawa kabisa"))
            } else {
                messages.append(KitoChatMessage(author: responder, text: reply))
            }
        }
    }
}

/// Njeri keeps writing while you scroll back: the button counts new messages.
private struct UnreadChat: View {
    @State private var messages = Script.njeri()
    @State private var typing: [KitoChatUser] = []

    var body: some View {
        VStack(spacing: 0) {
            KitoChatHeader(user: People.njeri, typingUsers: typing)
            KitoChatView(messages: $messages, currentUser: People.me, style: .imessage, wallpaper: .dots, typingUsers: typing, unreadCount: 5)
        }
        .task {
            for line in Script.feed {
                try? await Task.sleep(for: .seconds(2.5))
                typing = [People.njeri]
                try? await Task.sleep(for: .seconds(1.5))
                typing = []
                messages.append(KitoChatMessage(author: People.njeri, text: line))
            }
        }
    }
}

/// An inbox that opens into live conversations.
private struct Inbox: View {
    @State private var conversations = Script.inbox()
    @State private var openID: String?

    var body: some View {
        NavigationStack {
            KitoChatList(conversations: $conversations, currentUserID: People.me.id) { conversation in
                if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
                    conversations[index].unreadCount = 0
                }
                openID = conversation.id
            }
            .navigationTitle("Chats")
            .navigationDestination(item: $openID) { id in
                conversationScreen(id)
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    private func close() { openID = nil }

    @ViewBuilder
    private func conversationScreen(_ id: String) -> some View {
        switch id {
        case "c-safari":
            LiveChat(contact: People.safariCrew, title: "Safari Crew 🏖️", subtitle: "Amani, Baraka, Chebet, Juma, You",
                     responders: [People.juma, People.chebet, People.baraka], messages: Script.safariCrew(), onBack: close)
        case "c-njeri":
            LiveChat(contact: People.njeri, responders: [People.njeri], messages: Script.njeri(), style: .imessage, onBack: close)
        case "c-zawadi":
            LiveChat(contact: People.zawadi, responders: [People.zawadi], messages: Script.zawadi(), style: .glass, wallpaper: .aurora, onBack: close)
        default:
            LiveChat(contact: conversations.first { $0.id == id }?.user ?? People.amani, responders: [People.amani], messages: Script.amani(), onBack: close)
        }
    }
}

// MARK: - Bubble samples

private struct StyleGallery: View {
    @State private var style: KitoChatBubbleStyle = .modern
    @State private var tintIndex = 0

    private let tints: [(String, Color?)] = [
        ("Theme", nil),
        ("Ink", .primary),
        ("Savanna", Color(red: 0.93, green: 0.45, blue: 0.16)),
        ("Maasai", Color(red: 0.78, green: 0.13, blue: 0.20)),
        ("Lake", Color(red: 0.05, green: 0.55, blue: 0.60)),
    ]

    var body: some View {
        let tint = tints[tintIndex].1
        VStack(spacing: 16) {
            Picker("Style", selection: $style.animation(.snappy)) {
                ForEach(KitoChatBubbleStyle.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            HStack(spacing: 8) {
                ForEach(tints.indices, id: \.self) { index in
                    Button { withAnimation(.snappy) { tintIndex = index } } label: {
                        Text(tints[index].0)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Capsule().fill(tintIndex == index ? Color.primary : Color.primary.opacity(0.07)))
                            .foregroundStyle(tintIndex == index ? Color(.systemBackground) : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            VStack(spacing: 3) {
                bubble("Habari ya asubuhi! ☀️", from: People.amani, .first, tint: tint)
                bubble("Uko free leo jioni?", from: People.amani, .last, tint: tint)
                bubble("Niko free baada ya saa kumi", from: People.me, .first, tint: tint)
                bubble("Tukutane Westlands?", from: People.me, .last, tint: tint)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(style == .glass
                ? AnyShapeStyle(LinearGradient(colors: [.orange.opacity(0.5), .purple.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing))
                : AnyShapeStyle(Color.primary.opacity(0.03))))
        }
    }

    private func bubble(_ text: String, from user: KitoChatUser, _ position: KitoChatGroupPosition, tint: Color?) -> some View {
        let outgoing = user.id == People.me.id
        return HStack {
            if outgoing { Spacer(minLength: 40) }
            KitoChatBubble(KitoChatMessage(author: user, text: text), isOutgoing: outgoing, position: position, style: style, tint: tint)
            if !outgoing { Spacer(minLength: 40) }
        }
    }
}

private struct GroupingSample: View {
    @State private var style: KitoChatBubbleStyle = .modern
    private let positions: [KitoChatGroupPosition] = [.first, .middle, .middle, .last]
    private let lines = ["Nimefika stage", "Matatu imejaa sana 😩", "Nitachukua boda", "Dakika tano niko hapo"]

    var body: some View {
        VStack(spacing: 14) {
            Picker("Style", selection: $style.animation(.snappy)) {
                ForEach(KitoChatBubbleStyle.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            VStack(alignment: .trailing, spacing: 2) {
                ForEach(lines.indices, id: \.self) { index in
                    HStack {
                        Text(String(describing: positions[index])).font(.caption2.monospaced()).foregroundStyle(.secondary)
                        Spacer(minLength: 24)
                        KitoChatBubble(KitoChatMessage(author: People.me, text: lines[index]), isOutgoing: true, position: positions[index], style: style)
                    }
                }
            }
        }
    }
}

private struct RepliesAndReactions: View {
    @State private var question = KitoChatMessage(id: "q", author: People.baraka, text: "Nani ataleta nyama choma Jumapili? 🍖",
                                                 reactions: [KitoChatReaction("😂", userIDs: ["amani", "chebet"]), KitoChatReaction("🙏", userIDs: ["juma"])])

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                KitoChatBubble(question, isOutgoing: false, showsAuthorName: true, currentUserID: People.me.id, onReactionTap: { emoji in
                    withAnimation(.spring) { question.toggleReaction(emoji, by: People.me.id) }
                })
                Spacer(minLength: 40)
            }
            HStack {
                Spacer(minLength: 40)
                KitoChatBubble(
                    KitoChatMessage(author: People.me, text: "Mimi! Nitanunua kwa Kenchic Inn 😄", status: .read, replyTo: KitoChatReply(question)),
                    isOutgoing: true, position: .single, style: .imessage
                )
            }
            HStack(spacing: 8) {
                ForEach(KitoChatReaction.quickPicks, id: \.self) { emoji in
                    Button(emoji) { withAnimation(.spring) { question.toggleReaction(emoji, by: People.me.id) } }
                        .font(.title3)
                        .buttonStyle(.plain)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(question.reaction(of: People.me.id) == emoji ? Color.primary.opacity(0.12) : .clear))
                }
            }
            .frame(maxWidth: .infinity)
            Text("Tap a chip or an emoji to react as Wycliff N.").font(.footnote).foregroundStyle(.secondary)
        }
    }
}

private struct MediaBubbles: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                KitoChatBubble(KitoChatMessage(author: People.zawadi, kind: .image(KitoChatImage(Photos.diani, caption: "Diani, 6pm 🌅"))), isOutgoing: false)
                Spacer(minLength: 0)
            }
            HStack {
                Spacer(minLength: 0)
                KitoChatBubble(KitoChatMessage(author: People.me, kind: .image(KitoChatImage(Photos.naivasha))), isOutgoing: true, style: .imessage)
            }
            Text("Tap a photo to open it; drag down to close.").font(.footnote).foregroundStyle(.secondary)
        }
    }
}

private struct VoiceBubbles: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                KitoChatBubble(KitoChatMessage(author: People.amani, kind: .voice(duration: 14, waveform: KitoWaveform.placeholder(count: 48, seed: 3))), isOutgoing: false)
                Spacer(minLength: 0)
            }
            HStack {
                Spacer(minLength: 0)
                KitoChatBubble(KitoChatMessage(author: People.me, kind: .voice(duration: 42, waveform: KitoWaveform.placeholder(count: 48, seed: 8)), status: .read),
                               isOutgoing: true, style: .imessage)
            }
            Text("Play, drag across the waveform to scrub, tap 1× for 1.5× and 2×.").font(.footnote).foregroundStyle(.secondary)
        }
    }
}

private struct JumboEmoji: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack { KitoChatBubble(KitoChatMessage(author: People.juma, text: "🔥"), isOutgoing: false); Spacer() }
            HStack { Spacer(); KitoChatBubble(KitoChatMessage(author: People.me, text: "😂🙏🏾"), isOutgoing: true) }
            HStack { Spacer(); KitoChatBubble(KitoChatMessage(author: People.me, text: "Hio ni moto kabisa 🔥"), isOutgoing: true) }
        }
    }
}

// MARK: - Composer samples

private struct ComposerSample: View {
    var intro: String
    var startsWithReply = false

    @State private var draft = ""
    @State private var replyTo: KitoChatReply?
    @State private var sent: [KitoChatMessage] = []

    private let original = KitoChatMessage(id: "orig", author: People.amani, text: "Tuonane Java saa saba?")

    init(intro: String, startsWithReply: Bool = false) {
        self.intro = intro
        self.startsWithReply = startsWithReply
        _replyTo = State(initialValue: startsWithReply ? KitoChatReply(original) : nil)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                if startsWithReply {
                    HStack {
                        KitoChatBubble(original, isOutgoing: false)
                        Spacer(minLength: 40)
                    }
                }
                if sent.isEmpty {
                    Text(intro)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 120)
                }
                ForEach(sent.suffix(3)) { message in
                    HStack {
                        Spacer(minLength: 40)
                        KitoChatBubble(message, isOutgoing: true, position: .single, style: .imessage)
                    }
                    .transition(.scale(scale: 0.6, anchor: .bottomTrailing).combined(with: .opacity))
                }
            }
            .padding(12)
            .frame(minHeight: 200, alignment: .bottom)
            if startsWithReply && replyTo == nil {
                Button("Reply to Amani") { replyTo = KitoChatReply(original) }
                    .buttonStyle(GalleryPrimaryButtonStyle())
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }
            KitoChatComposer(text: $draft, replyTo: $replyTo, onAttach: {
                withAnimation(.spring) { sent.append(KitoChatMessage(author: People.me, kind: .image(KitoChatImage(Photos.karura)), status: .sent)) }
            }) { kind in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    sent.append(KitoChatMessage(author: People.me, kind: kind, status: .sent, replyTo: replyTo))
                }
            }
        }
        .background(Color.primary.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - Status and presence samples

private struct ReceiptsSample: View {
    @State private var status: KitoChatMessageStatus = .sending
    @State private var run = 0
    @State private var failsNext = false

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 18) {
                ForEach(KitoChatMessageStatus.allCases, id: \.self) { status in
                    VStack(spacing: 6) {
                        KitoChatStatusTicks(status)
                        Text(status.accessibilityLabel).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            VStack(alignment: .trailing, spacing: 4) {
                KitoChatBubble(KitoChatMessage(author: People.me, text: "Nimetuma pesa ya lunch 🙏🏾", status: status), isOutgoing: true, style: .modern)
                HStack(spacing: 4) {
                    Text(status.accessibilityLabel).font(.caption).foregroundStyle(.secondary).contentTransition(.opacity)
                    KitoChatStatusTicks(status)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            HStack {
                Button("Send again") { failsNext = false; run += 1 }
                    .buttonStyle(GalleryPrimaryButtonStyle())
                Button("Fail it") { failsNext = true; run += 1 }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.primary)
                    .controlSize(.large)
            }
        }
        .task(id: run) {
            status = .sending
            if failsNext {
                try? await Task.sleep(for: .milliseconds(900))
                status = status.transitioned(to: .failed)
                return
            }
            while let next = status.next {
                try? await Task.sleep(for: .milliseconds(900))
                guard !Task.isCancelled else { return }
                status = status.transitioned(to: next)
            }
        }
    }
}

private struct TypingSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(KitoChatBubbleStyle.allCases) { style in
                HStack(spacing: 12) {
                    KitoTypingIndicator(style: style)
                    Text(style.title).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct HeaderSample: View {
    @State private var typingCount = 1
    @State private var isOnline = true
    @State private var calls = 0

    private var user: KitoChatUser {
        var amani = People.amani
        amani.isOnline = isOnline
        return amani
    }

    var body: some View {
        VStack(spacing: 16) {
            KitoChatHeader(
                user: user,
                typingUsers: Array([People.amani, People.baraka, People.chebet].prefix(typingCount)),
                subtitle: isOnline ? nil : "Last seen today at 08:12",
                onBack: {},
                onCall: { calls += 1 },
                onVideo: { calls += 1 }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            Stepper("People typing: \(typingCount)", value: $typingCount.animation(.spring), in: 0...3)
            Toggle("Online", isOn: $isOnline.animation(.spring))
        }
        .sensoryFeedback(.impact, trigger: calls)
    }
}

private struct AvatarSample: View {
    @State private var online = true

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ForEach([People.amani, People.baraka, People.chebet, People.njeri, People.juma], id: \.id) { user in
                    KitoChatAvatar(presence(of: user), size: 48)
                }
            }
            HStack(spacing: 14) {
                KitoChatAvatar(People.zawadi, size: 72)
                KitoChatAvatar(People.safariCrew, size: 56, showsOnlineStatus: false)
                KitoChatAvatar(People.achieng, size: 32)
            }
            Toggle("Online", isOn: $online.animation(.spring))
        }
    }

    private func presence(of user: KitoChatUser) -> KitoChatUser {
        var person = user
        person.isOnline = online && user.id != People.baraka.id
        return person
    }
}

// MARK: - Inbox samples

private struct RowsSample: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Script.inbox().prefix(5)) { conversation in
                KitoChatListRow(conversation, currentUserID: People.me.id)
                Divider().padding(.leading, 66)
            }
        }
    }
}

private struct SwipeSample: View {
    @State private var conversations = Array(Script.inbox().prefix(4))
    @State private var log = "Swipe a row either way."

    var body: some View {
        VStack(spacing: 10) {
            List {
                ForEach(conversations) { conversation in
                    KitoChatListRow(conversation, currentUserID: People.me.id)
                        .kitoChatSwipeActions(
                            for: conversation,
                            onToggleRead: { change(conversation.id, "Marked read/unread") { $0.unreadCount = $0.unreadCount > 0 ? 0 : 1 } },
                            onTogglePin: { change(conversation.id, "Pinned/unpinned") { $0.isPinned.toggle() } },
                            onToggleMute: { change(conversation.id, "Muted/unmuted") { $0.isMuted.toggle() } },
                            onDelete: { withAnimation { conversations.removeAll { $0.id == conversation.id }; log = "Deleted \(conversation.displayName)" } }
                        )
                }
            }
            .listStyle(.plain)
            .frame(height: 330)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            Text(log).font(.footnote).foregroundStyle(.secondary).contentTransition(.opacity)
            if conversations.count < 4 {
                Button("Reset") { withAnimation { conversations = Array(Script.inbox().prefix(4)) } }
                    .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
    }

    private func change(_ id: String, _ message: String, _ edit: (inout KitoChatConversation) -> Void) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(.spring) { edit(&conversations[index]) }
        log = "\(message): \(conversations[index].displayName)"
    }
}

// MARK: - Building-block samples

private struct WaveformSample: View {
    @State private var progress = 0.35
    @State private var bars = 40.0

    var body: some View {
        VStack(spacing: 16) {
            KitoWaveformView(samples: KitoWaveform.placeholder(count: Int(bars), seed: 21), progress: progress, barWidth: 4, spacing: 3) { progress = $0 }
                .frame(height: 56)
            KitoWaveformView(
                samples: KitoWaveform.downsample((0..<2_000).map { Float(sin(Double($0) / 40) * sin(Double($0) / 311)) }, to: Int(bars)),
                progress: progress,
                activeColor: .orange
            )
            .frame(height: 36)
            LabeledContent("Progress", value: "\(Int(progress * 100))%")
            Slider(value: $bars, in: 16...64, step: 4) { Text("Bars") }
            Text("\(Int(bars)) bars · drag the top waveform to scrub").font(.footnote).foregroundStyle(.secondary)
        }
    }
}

private struct TimelineSample: View {
    var body: some View {
        let timeline = KitoChatTimeline(messages: Script.njeri(), currentUserID: People.me.id, unreadCount: 3)
        VStack(alignment: .leading, spacing: 8) {
            ForEach(timeline.sections) { section in
                Text(section.title).font(.headline)
                ForEach(section.rows) { row in
                    switch row {
                    case .unreadDivider(let count):
                        Text("— \(count) unread —").font(.caption.bold()).foregroundStyle(.orange)
                    case .message(let message, let position):
                        HStack {
                            Text(message.previewText).lineLimit(1)
                            Spacer()
                            Text(String(describing: position)).font(.caption.monospaced()).foregroundStyle(.secondary)
                        }
                        .font(.footnote)
                    }
                }
            }
        }
    }
}

private struct DatesSample: View {
    private let dates: [(String, Date)] = [
        ("5 min ago", minutesAgo(5)),
        ("Yesterday", daysAgo(1, hour: 20)),
        ("3 days ago", daysAgo(3, hour: 9)),
        ("3 weeks ago", daysAgo(21, hour: 9)),
        ("Last year", daysAgo(400, hour: 9)),
    ]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
            GridRow {
                Text("When").bold()
                Text("Separator").bold()
                Text("Inbox").bold()
            }
            .font(.caption)
            ForEach(dates.indices, id: \.self) { index in
                GridRow {
                    Text(dates[index].0).foregroundStyle(.secondary)
                    Text(KitoChatDateFormat.separatorTitle(for: dates[index].1))
                    Text(KitoChatDateFormat.listTimestamp(for: dates[index].1))
                }
                .font(.footnote)
            }
        }
    }
}

// MARK: - Gallery

enum ChatSamples {
    private static let conversations = KitSection("Conversations", symbol: "bubble.left.and.bubble.right.fill", [
        KitSample("Live chat", "Send a message: it goes sent, delivered, read — then Amani types back.", code: """
        @State private var messages: [KitoChatMessage] = []

        VStack(spacing: 0) {
            KitoChatHeader(user: amani, typingUsers: typing)
            KitoChatView(messages: $messages, currentUser: me, typingUsers: typing) { message in
                Task {
                    try await api.send(message)
                    messages.kitoUpdateStatus(of: message.id, to: .delivered)
                }
            }
        }
        """) {
            ModalStage { LiveChat(contact: People.amani, responders: [People.amani], messages: Script.amani()) }
        },
        KitSample("Group chat", "Author names and avatars appear automatically once more than one person writes.", code: """
        KitoChatHeader(user: safariCrew, title: "Safari Crew 🏖️",
                       typingUsers: typing, subtitle: "Amani, Baraka, Chebet, Juma, You")
        KitoChatView(messages: $messages, currentUser: me, typingUsers: typing)
        """) {
            ModalStage {
                LiveChat(contact: People.safariCrew, title: "Safari Crew 🏖️", subtitle: "Amani, Baraka, Chebet, Juma, You",
                         responders: [People.juma, People.chebet, People.baraka], messages: Script.safariCrew())
            }
        },
        KitSample("Unread and new messages", "Opens at the unread divider; scroll up and the button counts what arrives.", code: """
        KitoChatView(messages: $messages, currentUser: me,
                     style: .imessage, wallpaper: .dots, unreadCount: 5)
        """) {
            ModalStage { UnreadChat() }
        },
        KitSample("Every bubble style", "Switch Modern, Minimal, Glass and iMessage on a live conversation.", code: """
        KitoChatView(messages: $messages, currentUser: me, style: .glass, wallpaper: .aurora)
        """) {
            ModalStage {
                LiveChat(contact: People.zawadi, responders: [People.zawadi], messages: Script.zawadi(), style: .glass, wallpaper: .aurora, showsStylePicker: true)
            }
        },
    ])

    private static let bubbles = KitSection("Bubbles", symbol: "text.bubble.fill", [
        KitSample("Styles and tints", "Four styles; any tint, with text that stays readable on it.", code: """
        KitoChatBubble(message, isOutgoing: true, position: .last,
                       style: .imessage, tint: .orange)
        """) { StyleGallery() },
        KitSample("Grouping and tails", "Consecutive messages tuck their corners; only the last has a tail.", code: """
        let positions = KitoChatGrouping.positions(for: messages)   // [.first, .middle, .last, …]
        KitoChatBubble(message, isOutgoing: true, position: positions[index])
        """) { GroupingSample() },
        KitSample("Replies and reactions", "A quoted reply inside the bubble, reaction chips with counts.", code: """
        var reply = KitoChatMessage(author: me, text: "Mimi!", replyTo: KitoChatReply(question))
        question.toggleReaction("😂", by: me.id)    // one reaction per person
        KitoChatBubble(question, isOutgoing: false, currentUserID: me.id) { emoji in
            question.toggleReaction(emoji, by: me.id)
        }
        """) { RepliesAndReactions() },
        KitSample("Photos", "Rounded, sized from the aspect ratio, tap to open full screen.", code: """
        KitoChatMessage(author: zawadi, kind: .image(KitoChatImage(photo, caption: "Diani, 6pm 🌅")))
        KitoChatMessage(author: me, kind: .image(KitoChatImage(url: url, aspectRatio: 4 / 3)))
        """) { MediaBubbles() },
        KitSample("Voice notes", "Waveform progress, scrubbing and 1× / 1.5× / 2×.", code: """
        KitoChatMessage(author: amani, kind: .voice(duration: 14, waveform: samples, url: fileURL))
        // No url? Playback is simulated so the waveform still plays through.
        """) { VoiceBubbles() },
        KitSample("Big emoji", "One to three emoji on their own are shown large, without a bubble.", code: """
        KitoChatMessage(author: juma, text: "🔥").jumboEmojiCount   // 1
        """) { JumboEmoji() },
    ])

    private static let composer = KitSection("Composer", symbol: "keyboard.fill", [
        KitSample("Composer", "Grows with your text; the mic morphs into a paper plane.", code: """
        KitoChatComposer(text: $draft, onAttach: { showPicker = true }) { kind in
            send(kind)      // .text(…) or .voice(duration:waveform:url:)
        }
        """) { ComposerSample(intro: "Type a message and send it.") },
        KitSample("Hold to record", "Hold the mic — slide left to cancel, slide up to lock hands-free.", code: """
        KitoChatComposer(text: $draft, simulatesRecordingWhenUnavailable: true) { kind in
            if case .voice(let duration, let waveform, let url) = kind { upload(url, duration, waveform) }
        }
        // Needs NSMicrophoneUsageDescription. Without a mic it records a "Preview".
        """) { ComposerSample(intro: "Hold the microphone to record.\nSlide left to cancel, up to lock.") },
        KitSample("Replying", "A quoted preview above the field; it clears after sending.", code: """
        @State private var replyTo: KitoChatReply?

        replyTo = KitoChatReply(message)
        KitoChatComposer(text: $draft, replyTo: $replyTo) { kind in send(kind, replyingTo: replyTo) }
        """) { ComposerSample(intro: "", startsWithReply: true) },
    ])

    private static let presence = KitSection("Status & presence", symbol: "checkmark.message.fill", [
        KitSample("Read receipts", "Clock, sent, delivered, read — each change animates. Failures show a retry.", code: """
        KitoChatStatusTicks(message.status)

        messages.kitoUpdateStatus(of: id, to: .read)     // only moves forward
        KitoChatMessageStatus.sending.canTransition(to: .failed)   // true
        """) { ReceiptsSample() },
        KitSample("Typing indicator", "Bouncing dots in every bubble style; still with Reduce Motion.", code: """
        KitoTypingIndicator(style: .imessage)
        """) { TypingSample() },
        KitSample("Chat header", "The subtitle switches to “Amani is typing…”.", code: """
        KitoChatHeader(user: amani, typingUsers: typing,
                       onBack: { dismiss() }, onCall: { call() }, onVideo: { video() })
        """) { HeaderSample() },
        KitSample("Avatars", "Initials on a stable gradient, or a photo; a pulsing dot when online.", code: """
        KitoChatAvatar(KitoChatUser(id: "amani", name: "Amani Wanjiru", isOnline: true), size: 48)
        """) { AvatarSample() },
    ])

    private static let inbox = KitSection("Inbox", symbol: "tray.full.fill", [
        KitSample("Chat list", "Pinned first, swipe actions, and each chat opens into a live conversation.", code: """
        KitoChatList(conversations: $conversations, currentUserID: me.id) { conversation in
            openID = conversation.id
        }
        .navigationDestination(item: $openID) { id in ChatScreen(id: id) }
        """) {
            ModalStage { Inbox() }
        },
        KitSample("List rows", "Unread badge, muted, pinned, typing, and your own last message with ticks.", code: """
        KitoChatListRow(KitoChatConversation(user: amani, lastMessage: last, unreadCount: 2, isPinned: true),
                        currentUserID: me.id)
        """) { RowsSample() },
        KitSample("Swipe actions", "Read and pin on the left, mute and delete on the right — in your own List.", code: """
        KitoChatListRow(conversation, currentUserID: me.id)
            .kitoChatSwipeActions(for: conversation,
                                  onToggleRead: { … }, onTogglePin: { … },
                                  onToggleMute: { … }, onDelete: { … })
        """) { SwipeSample() },
    ])

    private static let blocks = KitSection("Building blocks", symbol: "waveform", [
        KitSample("Waveform", "Downsample any audio to bars; scrub with a drag.", code: """
        let bars = KitoWaveform.downsample(samples, to: 40)     // peaks, normalised to 0…1
        KitoWaveformView(samples: bars, progress: progress) { progress = $0 }
        """) { WaveformSample() },
        KitSample("Timeline", "Day sections, group positions and the unread divider, without any UI.", code: """
        let timeline = KitoChatTimeline(messages: messages, currentUserID: me.id, unreadCount: 3)
        for section in timeline.sections { print(section.title, section.rows.count) }
        """) { TimelineSample() },
        KitSample("Dates", "Separator titles and inbox timestamps.", code: """
        KitoChatDateFormat.separatorTitle(for: date)    // "Today", "Yesterday", "Monday", "Sat 12 Sep"
        KitoChatDateFormat.listTimestamp(for: date)     // "14:05", "Yesterday", "Mon", "12/09/26"
        """) { DatesSample() },
    ])

    static let sections: [KitSection] = [conversations, bubbles, composer, presence, inbox, blocks]
}

struct ChatGallery: View {
    static var count: Int { KitGallery.count(ChatSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Chat",
            sections: ChatSamples.sections,
            footnote: "Requires `import KitoChat`.",
            searchHint: "Try “voice”, “reactions”, “typing”, “inbox” or “glass”."
        )
    }
}
