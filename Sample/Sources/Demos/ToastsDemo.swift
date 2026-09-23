//
//  ToastsDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoToasts
import KitoCore

struct ToastsDemo: View {
    @Environment(KitoToastCenter.self) private var toasts

    var body: some View {
        Form {
            Section("Styles") {
                Button("Success") { toasts.show("Profile updated", style: .success) }
                Button("Error") { toasts.show("Could not connect", style: .error) }
                Button("Warning") { toasts.show("Low battery on device", style: .warning) }
                Button("Info") { toasts.show("New version available", style: .info) }
            }
            Section("Title, size, and bold") {
                Button("Large bold banner") {
                    toasts.show(KitoToast(
                        title: "Payment successful",
                        message: "Order #1234 has been confirmed and will arrive by 5:30 PM.",
                        style: .success,
                        titleStyle: .large,
                        isBold: true
                    ))
                }
                Button("Small subtle title") {
                    toasts.show(KitoToast(title: "Synced", message: "Just now", titleStyle: .small))
                }
            }
            Section("Custom icon") {
                Button("Trophy icon") {
                    toasts.show(KitoToast(message: "Achievement unlocked!", style: .success, icon: .custom("trophy.fill")))
                }
                Button("No icon") {
                    toasts.show(KitoToast(message: "Plain text toast", icon: .none))
                }
            }
            Section("Multiple actions (does not auto-dismiss)") {
                Button("Item removed — Undo / Dismiss") {
                    toasts.show(KitoToast(
                        title: "Item removed",
                        message: "\"Blue Hoodie\" was removed from your cart.",
                        style: .warning,
                        actions: [
                            KitoToastAction(title: "Undo", role: .primary) {
                                toasts.show("Restored", style: .success)
                            },
                            KitoToastAction(title: "Dismiss", role: .cancel) {},
                        ]
                    ))
                }
            }
            Section("Action button content — icon, text, or both") {
                Button("Icon + text actions") {
                    toasts.show(KitoToast(
                        message: "New message from Alex",
                        icon: .custom("bubble.left.fill"),
                        actions: [
                            KitoToastAction(title: "Reply", icon: "arrowshape.turn.up.left.fill", content: .iconAndTitle) {},
                            KitoToastAction(title: "Dismiss", icon: "xmark", content: .iconAndTitle, role: .cancel) {},
                        ]
                    ))
                }
                Button("Icon-only actions") {
                    toasts.show(KitoToast(
                        message: "Track added to queue",
                        actions: [
                            KitoToastAction(title: "Play now", icon: "play.fill", content: .iconOnly) {},
                            KitoToastAction(title: "Remove", icon: "trash", content: .iconOnly, role: .destructive) {},
                        ]
                    ))
                }
            }
            Section("Progress toast — uploading, then success") {
                Button("Simulate an upload") { simulateUpload() }
            }
            Section("Custom accent color") {
                Button("Purple, independent of style") {
                    toasts.show(KitoToast(message: "Achievement unlocked", icon: .custom("star.fill"), accentColor: .purple))
                }
            }
            Section("Background — color, gradient, image") {
                Button("Gradient background") {
                    toasts.show(KitoToast(
                        title: "Level up!",
                        message: "You've reached level 12.",
                        icon: .custom("bolt.fill"),
                        backgroundStyle: .gradient(.linear(.purple, .indigo))
                    ))
                }
                Button("Solid color background") {
                    toasts.show(KitoToast(message: "Saved to favorites", icon: .custom("heart.fill"), backgroundStyle: .color(.pink.opacity(0.85))))
                }
            }
            Section("Queueing") {
                Button("Queue three toasts") {
                    toasts.show("First", style: .info)
                    toasts.show("Second", style: .info)
                    toasts.show("Third", style: .info)
                }
            }
        }
        .navigationTitle("Toasts")
    }

    private func simulateUpload() {
        let id = UUID()
        toasts.show(KitoToast(
            id: id,
            title: "Uploading",
            message: "sunset.jpg",
            icon: .custom("arrow.up.circle.fill"),
            progress: KitoToastProgress(fraction: 0)
        ))
        Task {
            for step in 1...10 {
                try? await Task.sleep(nanoseconds: 150_000_000)
                toasts.updateProgress(id: id, fraction: Double(step) / 10)
            }
            toasts.complete(id: id, style: .success, title: "Uploaded", message: "sunset.jpg")
        }
    }
}
