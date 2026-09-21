//
//  ModalsDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoModals

private enum DemoSheet: String, KitoSheetRoute {
    case example
    var id: Self { self }
}

struct ModalsDemo: View {
    @State private var sheets = KitoSheetPresenter<DemoSheet>()
    @State private var confirmation: KitoConfirmation?
    @State private var status: KitoStatusDialogState?

    var body: some View {
        Form {
            Section("Bottom sheet") {
                Button("Open sheet") { sheets.present(.example) }
            }
            Section("Confirmation dialog") {
                Button("Delete item", role: .destructive) {
                    confirmation = KitoConfirmation(
                        title: "Delete item?",
                        message: "This can't be undone.",
                        confirmTitle: "Delete",
                        isDestructive: true
                    ) {}
                }
            }
            Section("Status dialog") {
                Button("Simulate payment") {
                    status = .pending(message: "Processing payment…")
                    Task {
                        try? await Task.sleep(nanoseconds: 1_800_000_000)
                        status = Bool.random() ? .success(message: "Payment complete") : .failure(message: "Payment failed")
                    }
                }
            }
        }
        .navigationTitle("Modals")
        .kitoBottomSheet(presenter: sheets, detents: [.medium]) { _ in
            VStack(spacing: 16) {
                Text("A bottom sheet").font(.title2.bold())
                Text("Presented via KitoSheetPresenter — only one route can be active at a time.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .kitoConfirmation($confirmation)
        .kitoStatusDialog($status)
    }
}
