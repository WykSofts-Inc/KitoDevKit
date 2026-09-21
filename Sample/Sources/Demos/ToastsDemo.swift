//
//  ToastsDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoToasts

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
            Section("Actionable (does not auto-dismiss)") {
                Button("Item removed, with Undo") {
                    toasts.show(KitoToast(
                        message: "Item removed",
                        style: .warning,
                        action: KitoToastAction(title: "Undo") {
                            toasts.show("Restored", style: .success)
                        }
                    ))
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
}
