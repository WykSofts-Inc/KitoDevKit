//
//  PermissionsDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoPermissions

struct PermissionsDemo: View {
    @State private var statuses: [KitoPermissionKind: KitoPermissionStatus] = [:]

    var body: some View {
        Form {
            ForEach(KitoPermissionKind.allCases, id: \.self) { kind in
                HStack {
                    Text(label(for: kind))
                    Spacer()
                    Text(statusLabel(statuses[kind]))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Request") {
                        Task { statuses[kind] = await KitoPermissionManager.shared.request(kind) }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Permissions")
        .task {
            for kind in KitoPermissionKind.allCases {
                statuses[kind] = await KitoPermissionManager.shared.status(for: kind)
            }
        }
    }

    private func label(for kind: KitoPermissionKind) -> String {
        switch kind {
        case .camera: return "Camera"
        case .photoLibrary: return "Photo Library"
        case .microphone: return "Microphone"
        case .locationWhenInUse: return "Location"
        case .notifications: return "Notifications"
        case .contacts: return "Contacts"
        }
    }

    private func statusLabel(_ status: KitoPermissionStatus?) -> String {
        switch status {
        case .granted: return "Granted"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined, .none: return "Not asked"
        }
    }
}
