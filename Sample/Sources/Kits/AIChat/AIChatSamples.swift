//
//  AIChatSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoAIChat

// MARK: - Fixtures

private enum AIChatPeople {
    static let me = "Wycliff N"
}

private func aiChatMinutesAgo(_ minutes: Double) -> Date { Date().addingTimeInterval(-minutes * 60) }

private func aiChatDaysAgo(_ days: Int, hour: Int = 10) -> Date {
    let calendar = Calendar.current
    let day = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    return calendar.date(bySettingHour: hour, minute: 12, second: 0, of: day) ?? day
}

private enum AIChatFixtures {
    static let richMarkdown = """
    ## Nairobi to Naivasha for the weekend

    Leave **before 7am** to beat the traffic on Waiyaki Way — the drive takes about *two hours*.

    ### Stops worth making
    1. **Rift Valley viewpoint** — tea, roasted maize and the whole valley below you.
    2. Hell's Gate National Park — cycle through the gorge.
       - Hire bikes at the gate
       - Carry at least 2 litres of water
    3. A boat ride on Lake Naivasha to see the hippos 🦛

    ### Before you go
    - [x] Top up M-Pesa for park fees
    - [x] Download offline maps
    - [ ] Book the lodge

    > Park fees are paid by M-Pesa or card only — no cash at the gate.

    Check current fees on [the KWS site](https://www.kws.go.ke), and use `#NaivashaWeekend` when you post. ~~Carry cash~~
    """

    static let swiftCode = """
    import Foundation

    struct Fare: Decodable {
        let route: String
        let amount: Int        // KES
    }

    func cheapest(_ fares: [Fare]) -> Fare? {
        fares.min { $0.amount < $1.amount }
    }

    let fares = [Fare(route: "SGR economy", amount: 1_500), Fare(route: "Bus", amount: 1_200)]
    print(cheapest(fares)?.route ?? "none")   // "Bus"
    """

    static let pythonCode = """
    # Split a bill between friends at Carnivore
    def split(total: int, people: int, tip: float = 0.1) -> int:
        return round(total * (1 + tip) / people)

    print(split(18_400, 4))  # 5060 each
    """

    static let jsonCode = """
    {
      "phone": "254712345678",
      "amount": 1500,
      "reference": "SGR-NBO-MSA",
      "sandbox": true
    }
    """

    static let tableMarkdown = """
    | English | Swahili | Say it like |
    |:--|:--|:--|
    | Good morning | Habari za asubuhi | ha-BAH-ree zah ah-soo-BOO-hee |
    | Thank you | Asante | ah-SAHN-teh |
    | How much? | Ni bei gani? | nee BAY GAH-nee |
    | Slowly | Pole pole | POH-leh POH-leh |

    | Route | Time | KES |
    |:--|:--:|--:|
    | Nairobi → Mombasa (SGR) | 6 h | 1,500 |
    | Nairobi → Kisumu (bus) | 7 h | 1,600 |
    | Nairobi → Arusha (shuttle) | 5 h | 3,500 |
    """

    static let streamingReply = """
    ## Kampala in 48 hours 🇺🇬

    Start at the **Uganda Museum**, then take a *boda boda* to Owino Market for rolex — chapati rolled around eggs.

    | Day | Morning | Evening |
    |:--|:--|:--|
    | Sat | Kasubi Tombs | Kabalagala |
    | Sun | Source of the Nile | Lake Victoria sunset |

    ```swift
    let budget = 180_000   // UGX per day
    ```

    - Carry small notes for bodas
    - Agree on the fare **before** you get on
    """

    static let tripConversation = KitoAIConversation(
        title: "Weekend in Diani",
        messages: [
            KitoAIMessage.user("Plan a weekend in Diani on a budget", date: aiChatMinutesAgo(12)),
            KitoAIMessage(
                role: .assistant,
                blocks: [
                    .toolCall(KitoAIToolCall.webSearch(id: "seed-search").with(status: .done, detail: "4 sources")),
                    .markdown("""
                    Here's a relaxed plan for **under KES 15,000**:

                    1. Take the **SGR economy** to Mombasa on Friday morning.
                    2. Stay at a guesthouse in Ukunda instead of on the beach road.
                    3. Snorkel at Kisite on Saturday — share a boat to split the cost.

                    > Tip: matatus from Likoni to Ukunda run all day and cost about KES 150.
                    """),
                    .citations([
                        KitoAICitation(id: "seed-1", title: "Diani Beach", url: URL(string: "https://www.magicalkenya.com")),
                        KitoAICitation(id: "seed-2", title: "Madaraka Express", url: URL(string: "https://metickets.krc.co.ke")),
                    ]),
                ],
                date: aiChatMinutesAgo(11),
                followUps: ["What should I pack?", "Add a day on Wasini Island"]
            ),
        ],
        model: "Kito Pro"
    )

    static let history: [KitoAIConversation] = [
        KitoAIConversation(id: "h1", title: "Weekend in Diani", messages: [.user("Plan a weekend in Diani"), .assistant("Take the **SGR** on Friday morning and stay in Ukunda.")], updatedAt: aiChatMinutesAgo(12), model: "Kito Pro", isPinned: true),
        KitoAIConversation(id: "h2", title: "M-Pesa STK push in Swift", messages: [.user("Show me STK push"), .assistant("Here's a minimal `URLSession` request against the Daraja sandbox.")], updatedAt: aiChatMinutesAgo(95), model: "Kito Fast"),
        KitoAIConversation(id: "h3", title: "Swahili for the safari", messages: [.user("Teach me Swahili phrases"), .assistant("**Asante sana** — thank you very much.")], updatedAt: aiChatDaysAgo(1)),
        KitoAIConversation(id: "h4", title: "Chapati that stays soft", messages: [.user("Chapati recipe"), .assistant("Rest the dough for 30 minutes and coil it like a snail.")], updatedAt: aiChatDaysAgo(3), model: "Kito Fast"),
        KitoAIConversation(id: "h5", title: "Leaking tap in Kilimani", messages: [.user("Draft a note to my landlord"), .assistant("> Hi Mr. Otieno, the kitchen tap in B4 has been leaking since Monday…")], updatedAt: aiChatDaysAgo(9)),
        KitoAIConversation(id: "h6", title: "Kampala in 48 hours", messages: [.user("Kampala itinerary"), .assistant("Start at the Uganda Museum, then rolex at Owino Market.")], updatedAt: aiChatDaysAgo(45), model: "Kito Pro"),
    ]

    static let attachments = [
        KitoAIAttachment(name: "Itinerary.pdf", kind: .pdf, byteCount: 482_000),
        KitoAIAttachment(name: "Fares 2026.xlsx", kind: .spreadsheet, byteCount: 36_400),
        KitoAIAttachment(name: "STKPush.swift", kind: .code, byteCount: 2_100),
    ]

    static let suggestions = [
        KitoAISuggestion(title: "Plan a weekend", subtitle: "in Diani on a budget", prompt: "Plan a weekend in Diani on a budget", symbol: "beach.umbrella"),
        KitoAISuggestion(title: "Draft a note", subtitle: "to my landlord in Kilimani", prompt: "Draft a polite note to my landlord about a leaking tap", symbol: "envelope"),
        KitoAISuggestion(title: "Cook chapati", subtitle: "soft and layered", prompt: "Chapati recipe that stays soft", symbol: "frying.pan"),
        KitoAISuggestion(title: "Compare the SGR", subtitle: "and a matatu to Mombasa", prompt: "Compare the SGR and a matatu to Mombasa", symbol: "tram.fill"),
    ]
}

// MARK: - Live chats

/// A full chat screen with a slim header: the conversation title, a model picker and New chat.
private struct AIChatLiveChat: View {
    var title = "Kito Assistant"
    var autoPrompt: String?
    var tint: Color?
    var showsModelPicker = true

    @State private var session: KitoAIChatSession
    @State private var model = "pro"
    @State private var didAutoSend = false

    init(title: String = "Kito Assistant", stream: KitoAIStream = KitoMockAIStream(), conversation: KitoAIConversation = KitoAIConversation(),
         suggestions: [KitoAISuggestion] = KitoAISuggestion.defaults, autoPrompt: String? = nil, tint: Color? = nil, showsModelPicker: Bool = true) {
        self.title = title
        self.autoPrompt = autoPrompt
        self.tint = tint
        self.showsModelPicker = showsModelPicker
        _session = State(initialValue: KitoAIChatSession(conversation: conversation, stream: stream, suggestions: suggestions))
    }

    var body: some View {
        VStack(spacing: 0) {
            AIChatHeader(title: session.messages.isEmpty ? title : session.conversation.displayTitle,
                         isGenerating: session.isGenerating, tint: tint) {
                session.reset()
                didAutoSend = true
            }
            if showsModelPicker {
                KitoAIChatView(session: session, userName: AIChatPeople.me, tint: tint, onAttach: attach) {
                    KitoAIModelPicker(KitoAIModelOption.defaults, selection: $model, tint: tint)
                }
            } else {
                KitoAIChatView(session: session, userName: AIChatPeople.me, tint: tint, onAttach: attach)
            }
        }
        .onAppear {
            guard let autoPrompt, !didAutoSend, session.messages.isEmpty else { return }
            didAutoSend = true
            session.send(autoPrompt)
        }
    }

    private func attach() {
        let next = AIChatFixtures.attachments[session.attachments.count % AIChatFixtures.attachments.count]
        session.attachments.append(KitoAIAttachment(name: next.name, kind: next.kind, byteCount: next.byteCount))
    }
}

private struct AIChatHeader: View {
    let title: String
    let isGenerating: Bool
    let tint: Color?
    let onNewChat: () -> Void

    @Environment(\.kitoTheme) private var theme

    var body: some View {
        HStack(spacing: 10) {
            KitoAIOrb(size: 22, isActive: isGenerating, tint: tint)
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.colors.onBackground)
                .lineLimit(1)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: title)
            Spacer()
            Button(action: onNewChat) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.colors.onBackground)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(theme.colors.surfaceMuted))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("New chat")
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .background(theme.colors.background)
    }
}

// MARK: - Rendering

private struct AIChatStreamingReplay: View {
    @State private var text = ""
    @State private var isStreaming = false
    @State private var runID = 0
    @State private var chunkCount = 0

    private var blocks: [KitoAIMarkdownBlock] {
        KitoAIMarkdown.blocks(from: KitoAIStreamAssembler.displayText(for: text, isStreaming: isStreaming))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KitoAIMarkdownView(text, isStreaming: isStreaming)
                .frame(minHeight: 360, alignment: .top)
            HStack(spacing: 6) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                    Text(block.kind)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.primary.opacity(0.08)))
                }
            }
            .animation(.easeOut(duration: 0.2), value: blocks.count)
            Text("\(chunkCount) tokens · \(KitoAITextStats.wordCount(text)) words")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            Button { runID += 1 } label: {
                Label(isStreaming ? "Streaming…" : "Replay", systemImage: "play.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(isStreaming)
        }
        .task(id: runID) { await replay() }
    }

    private func replay() async {
        text = ""
        chunkCount = 0
        isStreaming = true
        for chunk in KitoMockAIStream.chunks(for: AIChatFixtures.streamingReply, seed: UInt64(runID + 11)) {
            try? await Task.sleep(nanoseconds: UInt64(chunk.delay * 1_000_000_000))
            if Task.isCancelled { return }
            text += chunk.text
            chunkCount += 1
        }
        isStreaming = false
    }
}

private struct AIChatMessageSamples: View {
    @State private var feedback: KitoAIFeedback = .none

    private var reply: KitoAIMessage {
        var message = KitoAIMessage.assistant("""
        **Habari za asubuhi** means *good morning*. For friends, a simple **“Sasa!”** works too — reply with **“Poa!”**.
        """)
        message.feedback = feedback
        return message
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            KitoAIMessageView(.user("How do I say good morning in Swahili?"), onEdit: {})
            KitoAIMessageView(reply, onRegenerate: {}) { value in
                feedback = feedback == value ? .none : value
            }
            KitoAIMessageView(.system("Switched to Kito Pro"))
        }
    }
}

// MARK: - States

private struct AIChatToolCycle: View {
    @State private var search = KitoAIToolCall.webSearch(id: "cycle")
    @State private var runID = 0

    private let reading = KitoAIToolCall(id: "read", name: "read_file", runningTitle: "Reading Itinerary.pdf…",
                                         doneTitle: "Read Itinerary.pdf", detail: "3 pages", symbol: "doc.richtext", status: .done)
    private let failed = KitoAIToolCall(id: "fail", name: "check_weather", runningTitle: "Checking the weather in Kisumu…",
                                        doneTitle: "Checked the weather", symbol: "cloud.sun", status: .failed)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KitoAIToolChip(search)
            KitoAIToolChip(reading)
            KitoAIToolChip(failed)
            Button { runID += 1 } label: {
                Label("Run the search again", systemImage: "arrow.clockwise").frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task(id: runID) {
            search = search.with(status: .running)
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard !Task.isCancelled else { return }
            search = search.with(status: .done, detail: "5 sources")
        }
    }
}

private struct AIChatFollowUpSample: View {
    @State private var picked: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KitoAIFollowUpChips(["What should I pack?", "Make it cheaper", "Add a day on Wasini Island", "Is December too busy?"]) { picked = $0 }
            Text(picked.map { "Would send “\($0)”" } ?? "Tap a suggestion.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AIChatSuggestionsSample: View {
    @State private var picked: String?

    var body: some View {
        VStack(spacing: 16) {
            KitoAISuggestedPrompts(AIChatFixtures.suggestions) { picked = $0.prompt }
            Text(picked.map { "Would send “\($0)”" } ?? "Tap a card.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AIChatErrorSample: View {
    @State private var retries = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KitoAIErrorBubble("The connection was lost before the reply finished.") { retries += 1 }
            Text(retries == 0 ? "Tap Retry." : "Retried \(retries) time\(retries == 1 ? "" : "s").")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Composer

private struct AIChatComposerSample: View {
    enum Mode { case plain, attachments, voice, picker }

    let mode: Mode

    @State private var draft = ""
    @State private var attachments: [KitoAIAttachment] = []
    @State private var isGenerating = false
    @State private var model = "fast"
    @State private var sent: [String] = []
    @State private var reply: Task<Void, Never>?

    init(mode: Mode) {
        self.mode = mode
        _attachments = State(initialValue: mode == .attachments ? AIChatFixtures.attachments : [])
        _draft = State(initialValue: mode == .voice ? "Plan a trip to" : "")
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .trailing, spacing: 8) {
                ForEach(Array(sent.suffix(3).enumerated()), id: \.offset) { _, text in
                    Text(text)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.primary.opacity(0.07)))
                }
                if isGenerating {
                    KitoAIThinkingIndicator("Replying").frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .bottomTrailing)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: sent)

            if mode == .picker {
                KitoAIComposer(text: $draft, attachments: $attachments, isGenerating: isGenerating,
                               onAttach: attach, onStop: stop, onSend: send) {
                    KitoAIModelPicker(KitoAIModelOption.defaults, selection: $model)
                }
            } else {
                KitoAIComposer(text: $draft, attachments: $attachments, isGenerating: isGenerating,
                               allowsVoice: true, onAttach: attach, onStop: stop, onSend: send)
            }
        }
    }

    private func attach() {
        let next = AIChatFixtures.attachments[attachments.count % AIChatFixtures.attachments.count]
        attachments.append(KitoAIAttachment(name: next.name, kind: next.kind, byteCount: next.byteCount))
    }

    private func send(_ text: String) {
        sent.append(text.isEmpty ? "📎 \(attachments.count) files" : text)
        attachments = []
        isGenerating = true
        reply = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            isGenerating = false
        }
    }

    private func stop() {
        reply?.cancel()
        isGenerating = false
    }
}

private struct AIChatModelPickerSample: View {
    @State private var model = "pro"

    var body: some View {
        VStack(spacing: 16) {
            KitoAIModelPicker(KitoAIModelOption.defaults, selection: $model)
            Text(KitoAIModelOption.defaults.first { $0.id == model }?.detail ?? "")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)
                .animation(.easeInOut, value: model)
        }
    }
}

// MARK: - Sidebar and welcome

private struct AIChatSidebarSample: View {
    @State private var conversations = AIChatFixtures.history
    @State private var selection: String? = "h1"

    var body: some View {
        KitoAIConversationList(
            conversations: conversations,
            selection: $selection,
            onNewChat: newChat,
            onTogglePin: togglePin,
            onDelete: { conversation in conversations.removeAll { $0.id == conversation.id } }
        )
        .padding(.top, 12)
    }

    private func newChat() {
        let chat = KitoAIConversation(messages: [.user("Where can I watch the Safari Rally in Naivasha?")])
        conversations.append(chat)
        selection = chat.id
    }

    private func togglePin(_ conversation: KitoAIConversation) {
        guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
        conversations[index].isPinned.toggle()
    }
}

private struct AIChatRowsSample: View {
    var body: some View {
        VStack(spacing: 4) {
            ForEach(Array(AIChatFixtures.history.prefix(4).enumerated()), id: \.element.id) { index, conversation in
                KitoAIConversationRow(conversation, isSelected: index == 1)
            }
        }
    }
}

private struct AIChatOrbSample: View {
    @State private var isActive = true

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 20) {
                KitoAIOrb(size: 28, isActive: isActive)
                KitoAIOrb(size: 48, isActive: isActive, tint: .orange)
                KitoAIOrb(size: 72, isActive: isActive, tint: .teal)
            }
            KitoAIOrb(size: 96, isActive: isActive, colors: [.green, .yellow, .red, .black, .green])
            Toggle("Working", isOn: $isActive.animation())
                .toggleStyle(.switch)
                .frame(maxWidth: 200)
        }
    }
}

// MARK: - Logic

private struct AIChatTitlesSample: View {
    private let prompts = [
        "Hey, can you help me plan a weekend in Diani?",
        "Please explain **M-Pesa** STK push in Swift",
        "habari! teach me Swahili phrases for a safari",
        "What are the best places to eat nyama choma in Nairobi on a Sunday afternoon",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(prompts, id: \.self) { prompt in
                VStack(alignment: .leading, spacing: 4) {
                    Text(prompt).font(.footnote).foregroundStyle(.secondary)
                    Text(KitoAITitle.make(from: prompt)).font(.subheadline.weight(.semibold))
                    Text("\(KitoAITextStats.wordCount(prompt)) words · ~\(KitoAITextStats.estimatedTokens(prompt)) tokens")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Divider()
            Text(KitoAIGreeting.text(name: AIChatPeople.me)).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Gallery

enum AIChatSamples {
    private static let conversations = KitSection("Conversations", symbol: "bubble.left.and.text.bubble.right.fill", [
        KitSample("Streaming chat", "Welcome, starter prompts, streaming replies, Stop, Regenerate and follow-ups — ask anything.", code: """
        @State private var session = KitoAIChatSession(stream: KitoMockAIStream())
        @State private var model = "pro"

        KitoAIChatView(session: session, userName: "Wycliff N", onAttach: { showPicker = true }) {
            KitoAIModelPicker(KitoAIModelOption.defaults, selection: $model)
        }
        """) {
            ModalStage { AIChatLiveChat() }
        },
        KitSample("Tools and sources", "A web search chip runs first, then the reply streams in with numbered sources.", code: """
        continuation.yield(.toolCall(.webSearch(id: "s1")))
        continuation.yield(.toolCall(search.with(status: .done, detail: "4 sources")))
        continuation.yield(.token("## A relaxed weekend in Diani…"))
        continuation.yield(.citations([KitoAICitation(title: "Diani Beach", url: url)]))
        """) {
            ModalStage { AIChatLiveChat(title: "Diani", autoPrompt: "Plan a weekend in Diani") }
        },
        KitSample("Errors and Retry", "The first reply drops part-way; the error bubble's Retry streams it again.", code: """
        KitoAIChatView(stream: KitoMockAIStream(failures: 1))

        // Your stream: throw, and the message shows your error's description.
        continuation.finish(throwing: KitoAIStreamError("The connection was lost."))
        """) {
            ModalStage { AIChatLiveChat(title: "SGR or matatu", stream: KitoMockAIStream(failures: 1), autoPrompt: "Compare the SGR and a matatu to Mombasa") }
        },
        KitSample("Edit and resend", "Tap Edit under your last message, change it and send — the chat continues from there.", code: """
        let text = session.beginEditing()      // "Plan a weekend in Diani on a budget"
        session.send("Plan a weekend in Watamu instead")
        """) {
            ModalStage { AIChatLiveChat(title: "Weekend in Diani", conversation: AIChatFixtures.tripConversation) }
        },
        KitSample("Tinted and dark", "Any tint for links, the orb and Send; everything else follows the theme.", code: """
        KitoAIChatView(stream: KitoMockAIStream(), userName: "Wycliff N", tint: .orange)
            .kitoTheme(.dark)
        """) {
            ModalStage {
                AIChatLiveChat(title: "Kito Assistant", suggestions: AIChatFixtures.suggestions, tint: .orange, showsModelPicker: false)
                    .kitoTheme(.dark)
                    .environment(\.colorScheme, .dark)
            }
        },
    ])

    private static let rendering = KitSection("Rendering", symbol: "text.alignleft", [
        KitSample("Markdown", "Headings, numbered and nested lists, tasks, quotes, links, `code` and strikethrough.", code: """
        KitoAIMarkdownView(reply)

        KitoAIMarkdown.blocks(from: reply).map(\\.kind)
        // ["heading", "paragraph", "heading", "list", "heading", "list", "quote", "paragraph"]
        """) { KitoAIMarkdownView(AIChatFixtures.richMarkdown) },
        KitSample("Code blocks", "Language label, Copy, syntax colours; long lines scroll sideways.", code: """
        KitoAICodeBlock(code, language: "swift")
        KitoAISyntaxHighlighter.tokens(in: code, language: "python")   // keywords, strings, comments, numbers
        """) {
            VStack(spacing: 14) {
                KitoAICodeBlock(AIChatFixtures.swiftCode, language: "swift")
                KitoAICodeBlock(AIChatFixtures.pythonCode, language: "python")
                KitoAICodeBlock(AIChatFixtures.jsonCode, language: "json")
            }
        },
        KitSample("Tables", "GitHub tables with column alignment, a tinted header and striped rows.", code: """
        KitoAIMarkdownView(\"\"\"
        | Route | Time | KES |
        |:--|:--:|--:|
        | Nairobi → Mombasa (SGR) | 6 h | 1,500 |
        \"\"\")
        """) { KitoAIMarkdownView(AIChatFixtures.tableMarkdown) },
        KitSample("Streaming without flicker", "Tokens arrive with realistic jitter; unfinished syntax waits, blocks never flip.", code: """
        var assembler = KitoAIStreamAssembler()
        for try await token in tokens {
            assembler.append(token)
            blocks = assembler.blocks          // "#" and "| a |" wait; "**bo" shows as bold
        }

        KitoAIMarkdownView(partial, isStreaming: true)
        """) { AIChatStreamingReplay() },
        KitSample("Messages", "A user bubble with Copy and Edit, a reply with Copy, 👍, 👎 and Regenerate, a system note.", code: """
        KitoAIMessageView(.user("How do I say good morning in Swahili?"), onEdit: { session.beginEditing() })
        KitoAIMessageView(reply, onRegenerate: { session.regenerate() }) { feedback in
            session.setFeedback(feedback, for: reply.id)
        }
        KitoAIMessageView(.system("Switched to Kito Pro"))
        """) { AIChatMessageSamples() },
    ])

    private static let states = KitSection("States", symbol: "sparkles", [
        KitSample("Thinking", "An orb and a light sweep until the first token; still with Reduce Motion.", code: """
        KitoAIThinkingIndicator()
        KitoAIThinkingIndicator("Reading Itinerary.pdf", tint: .orange)
        """) {
            VStack(alignment: .leading, spacing: 18) {
                KitoAIThinkingIndicator()
                KitoAIThinkingIndicator("Reading Itinerary.pdf", tint: .orange)
                KitoAIThinkingIndicator("Checking fares", tint: .teal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        },
        KitSample("Tool chips", "“Searching the web…” turns into “Searched the web · 5 sources”.", code: """
        KitoAIToolChip(.webSearch())
        KitoAIToolChip(search.with(status: .done, detail: "5 sources"))
        KitoAIToolCall(name: "read_file", runningTitle: "Reading Itinerary.pdf…",
                       doneTitle: "Read Itinerary.pdf", detail: "3 pages", symbol: "doc.richtext")
        """) { AIChatToolCycle() },
        KitSample("Sources", "Numbered chips with the site's domain; tap to open.", code: """
        KitoAICitationChips([
            KitoAICitation(title: "Kisite-Mpunguti Marine Park", url: URL(string: "https://www.kws.go.ke")),
        ])
        """) {
            KitoAICitationChips([
                KitoAICitation(title: "Diani Beach", url: URL(string: "https://www.magicalkenya.com")),
                KitoAICitation(title: "Madaraka Express tickets", url: URL(string: "https://metickets.krc.co.ke")),
                KitoAICitation(title: "Kisite-Mpunguti Marine Park", url: URL(string: "https://www.kws.go.ke")),
            ])
        },
        KitSample("Follow-up chips", "Suggested next prompts wrap onto lines and rise in one by one.", code: """
        KitoAIFollowUpChips(message.followUps) { prompt in session.send(prompt) }
        """) { AIChatFollowUpSample() },
        KitSample("Starter prompts", "Cards for an empty conversation; one column at accessibility sizes.", code: """
        KitoAISuggestedPrompts([
            KitoAISuggestion(title: "Plan a weekend", subtitle: "in Diani on a budget", symbol: "beach.umbrella"),
        ]) { suggestion in session.send(suggestion.prompt) }
        """) { AIChatSuggestionsSample() },
        KitSample("Error bubble", "What went wrong and a Retry button.", code: """
        KitoAIErrorBubble("The connection was lost before the reply finished.") { session.retry() }
        """) { AIChatErrorSample() },
    ])

    private static let composer = KitSection("Composer", symbol: "keyboard.fill", [
        KitSample("Send and Stop", "Type and send: the arrow morphs into Stop while the reply generates.", code: """
        KitoAIComposer(text: $draft, isGenerating: session.isGenerating,
                       onStop: { session.stop() }) { prompt in
            session.send(prompt)
        }
        """) { AIChatComposerSample(mode: .plain) },
        KitSample("Attachments", "Files wait as chips above the field; remove one with its ✕.", code: """
        KitoAIComposer(text: $draft, attachments: $files, onAttach: { showPicker = true }) { prompt in
            send(prompt, files)
        }
        KitoAIAttachment(name: "Itinerary.pdf", kind: .pdf, byteCount: 482_000)
        """) { AIChatComposerSample(mode: .attachments) },
        KitSample("Voice input", "Tap the mic to dictate into the field; the waveform follows your voice.", code: """
        KitoAIComposer(text: $draft) { prompt in send(prompt) }
        // Needs NSSpeechRecognitionUsageDescription and NSMicrophoneUsageDescription.
        // Without them, or without a microphone, the mic shows a hint instead.
        """) { AIChatComposerSample(mode: .voice) },
        KitSample("Model picker", "A capsule menu for the composer's accessory slot.", code: """
        @State private var model = "pro"

        KitoAIComposer(text: $draft) { send($0) } accessory: {
            KitoAIModelPicker(KitoAIModelOption.defaults, selection: $model)
        }
        """) {
            VStack(spacing: 24) {
                AIChatModelPickerSample()
                AIChatComposerSample(mode: .picker)
            }
        },
    ])

    private static let sidebar = KitSection("Sidebar & welcome", symbol: "sidebar.left", [
        KitSample("Conversation list", "Pinned, Today, Yesterday, Previous 7 days…; search, New chat, pin and delete.", code: """
        KitoAIConversationList(conversations: history, selection: $openID,
                               onNewChat: { startChat() },
                               onTogglePin: { pin($0) }, onDelete: { delete($0) })
        """) {
            ModalStage { AIChatSidebarSample() }
        },
        KitSample("Rows", "Title, the latest text, when it was active and the model.", code: """
        KitoAIConversationRow(conversation, isSelected: conversation.id == openID)
        """) { AIChatRowsSample() },
        KitSample("Welcome", "A glowing orb over a time-of-day greeting.", code: """
        KitoAIWelcome(name: "Wycliff N")            // "Good evening, Wycliff"
        KitoAIWelcome(greeting: "Karibu tena!", subtitle: "Tuanze wapi leo?")
        """) {
            VStack(spacing: 40) {
                KitoAIWelcome(name: AIChatPeople.me)
                KitoAIWelcome(greeting: "Karibu tena!", subtitle: "Tuanze wapi leo?", tint: .orange)
            }
        },
        KitSample("Orb", "Drifting colour that breathes while working; any tint or palette.", code: """
        KitoAIOrb(size: 72, isActive: isGenerating, tint: .teal)
        KitoAIOrb(size: 96, colors: [.green, .yellow, .red, .black, .green])
        """) { AIChatOrbSample() },
    ])

    private static let logic = KitSection("Building blocks", symbol: "function", [
        KitSample("Titles and counts", "A short title from the first message, word and token counts, the greeting.", code: """
        KitoAITitle.make(from: "Hey, can you help me plan a weekend in Diani?")  // "Plan a weekend in Diani"
        KitoAITextStats.wordCount(prompt)
        KitoAITextStats.estimatedTokens(prompt)
        KitoAIGreeting.text(name: "Wycliff N")                                   // "Good evening, Wycliff"
        """) { AIChatTitlesSample() },
    ])

    static let sections: [KitSection] = [conversations, rendering, states, composer, sidebar, logic]
}

struct AIChatGallery: View {
    static var count: Int { KitGallery.count(AIChatSamples.sections) }

    var body: some View {
        KitGallery(
            title: "AI Chat",
            sections: AIChatSamples.sections,
            footnote: "Requires `import KitoAIChat`.",
            searchHint: "Try “streaming”, “code”, “tools”, “voice” or “sidebar”."
        )
    }
}
