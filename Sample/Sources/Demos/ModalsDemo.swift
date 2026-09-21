//
//  ModalsDemo.swift
//  KitoDevKit
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoModals

private enum DemoSheet: String, KitoSheetRoute {
    case medium, large, multi
    var id: Self { self }
}

struct ModalsDemo: View {
    @State private var sheets = KitoSheetPresenter<DemoSheet>()
    @State private var confirmation: KitoConfirmation?
    @State private var status: KitoStatusDialogState?

    var body: some View {
        Form {
            Section("Bottom sheet — detents") {
                Button("Medium detent") { sheets.present(.medium) }
                Button("Large detent") { sheets.present(.large) }
                Button("Medium + large (draggable between)") { sheets.present(.multi) }
            }

            Section("Confirmation dialog") {
                Button("Non-destructive confirm") {
                    confirmation = KitoConfirmation(title: "Save changes?", confirmTitle: "Save") {}
                }
                Button("Destructive confirm", role: .destructive) {
                    confirmation = KitoConfirmation(
                        title: "Delete item?",
                        message: "This can't be undone.",
                        confirmTitle: "Delete",
                        isDestructive: true
                    ) {}
                }
                Button("With a message, no destructive role") {
                    confirmation = KitoConfirmation(
                        title: "Turn on notifications?",
                        message: "You can change this later in Settings.",
                        confirmTitle: "Turn On"
                    ) {}
                }
            }

            Section("Status dialog — each state directly") {
                Button("Pending only (stays until you act)") {
                    status = .pending(message: "Processing…")
                }
                Button("Success") {
                    status = .success(message: "Payment complete")
                }
                Button("Failure") {
                    status = .failure(message: "Payment failed")
                }
                Button("Pending → Success (simulated async work)") {
                    status = .pending(message: "Processing payment…")
                    Task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        status = .success(message: "Payment complete")
                    }
                }
                Button("Pending → Failure (simulated async work)") {
                    status = .pending(message: "Contacting bank…")
                    Task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        status = .failure(message: "Card declined")
                    }
                }
            }

            Section("Status dialog — no title, no message") {
                Button("Bare success (icon only)") { status = .success() }
            }
        }
        .navigationTitle("Modals")
        .kitoBottomSheet(presenter: sheets, detents: sheetDetents(for: sheets.route)) { route in
            sheetContent(for: route)
        }
        .kitoConfirmation($confirmation)
        .kitoStatusDialog($status)
    }

    private func sheetDetents(for route: DemoSheet?) -> Set<PresentationDetent> {
        switch route {
        case .medium: return [.medium]
        case .large: return [.large]
        case .multi: return [.medium, .large]
        case .none: return [.medium]
        }
    }

    @ViewBuilder
    private func sheetContent(for route: DemoSheet) -> some View {
        VStack(spacing: 16) {
            Text(title(for: route)).font(.title2.bold())
            Text("Presented via KitoSheetPresenter — only one route can be active at a time, by construction.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }

    private func title(for route: DemoSheet) -> String {
        switch route {
        case .medium: return "Medium detent"
        case .large: return "Large detent"
        case .multi: return "Drag the grabber — this sheet has two detents"
        }
    }
}
