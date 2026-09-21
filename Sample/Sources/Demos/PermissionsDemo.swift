//
//  PermissionsDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoPermissions

struct PermissionsDemo: View {
    @Environment(\.kitoTheme) private var theme
    @State private var statuses: [KitoPermissionKind: KitoPermissionStatus] = [:]

    private let groups: [(title: String, kinds: [KitoPermissionKind])] = [
        ("Media", [.camera, .photoLibrary, .microphone, .mediaLibrary]),
        ("Location", [.locationWhenInUse, .locationAlways]),
        ("Personal data", [.contacts, .calendar, .reminders]),
        ("System", [.notifications, .speechRecognition, .bluetooth, .tracking]),
    ]

    var body: some View {
        Form {
            ForEach(groups, id: \.title) { group in
                Section(group.title) {
                    ForEach(group.kinds, id: \.self) { kind in
                        row(for: kind)
                    }
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

    private func row(for kind: KitoPermissionKind) -> some View {
        HStack {
            Image(systemName: icon(for: kind))
                .foregroundStyle(theme.colors.primary)
                .frame(width: 22)
            Text(label(for: kind))
            Spacer()
            Text(statusLabel(statuses[kind]))
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Request") {
                Task { statuses[kind] = await KitoPermissionManager.shared.request(kind) }
            }
            .font(theme.typography.label.weight(.semibold))
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, 6)
            .background(theme.colors.primary.opacity(0.14), in: Capsule())
            .foregroundStyle(theme.colors.primary)
        }
    }

    private func icon(for kind: KitoPermissionKind) -> String {
        switch kind {
        case .camera: return "camera.fill"
        case .photoLibrary: return "photo.on.rectangle"
        case .microphone: return "mic.fill"
        case .mediaLibrary: return "music.note.list"
        case .locationWhenInUse: return "location.fill"
        case .locationAlways: return "location.fill.viewfinder"
        case .contacts: return "person.crop.circle"
        case .calendar: return "calendar"
        case .reminders: return "checklist"
        case .notifications: return "bell.fill"
        case .speechRecognition: return "waveform"
        case .bluetooth: return "dot.radiowaves.left.and.right"
        case .tracking: return "eye.fill"
        }
    }

    private func label(for kind: KitoPermissionKind) -> String {
        switch kind {
        case .camera: return "Camera"
        case .photoLibrary: return "Photo Library"
        case .microphone: return "Microphone"
        case .mediaLibrary: return "Media Library"
        case .locationWhenInUse: return "Location — When In Use"
        case .locationAlways: return "Location — Always"
        case .notifications: return "Notifications"
        case .contacts: return "Contacts"
        case .calendar: return "Calendar"
        case .reminders: return "Reminders"
        case .speechRecognition: return "Speech Recognition"
        case .bluetooth: return "Bluetooth"
        case .tracking: return "App Tracking"
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
