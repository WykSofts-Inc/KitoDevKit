//
//  ControlCenterSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 24/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoButtons
import KitoHaptics
import KitoToasts

// MARK: - Shared pieces

/// The dark, blurred wallpaper Control Center sits on.
private struct CCBackdrop<Content: View>: View {
    var colors: [Color] = [Color(red: 0.2, green: 0.12, blue: 0.4), Color(red: 0.05, green: 0.2, blue: 0.3), Color(red: 0.4, green: 0.12, blue: 0.2)]
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(18)
            .frame(maxWidth: .infinity)
            .background {
                ZStack {
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    Circle().fill(colors[0]).frame(width: 220).blur(radius: 60).offset(x: -90, y: -80)
                    Circle().fill(colors[2]).frame(width: 200).blur(radius: 60).offset(x: 110, y: 120)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .environment(\.colorScheme, .dark)
    }
}

/// A frosted module tile.
private struct CCModule<Content: View>: View {
    var cornerRadius: CGFloat = 26
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }
}

/// A round toggle: grey when off, tinted and glowing when on.
private struct CCRoundToggle: View {
    let symbol: String
    let label: String
    let tint: Color
    @Binding var isOn: Bool
    var size: CGFloat = 58

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { isOn.toggle() }
            KitoHaptics.impact(.light)
        } label: {
            Image(systemName: symbol)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(isOn ? .white : .white.opacity(0.9))
                .symbolEffect(.bounce, value: isOn)
                .frame(width: size, height: size)
                .background(isOn ? AnyShapeStyle(tint) : AnyShapeStyle(.white.opacity(0.14)), in: Circle())
                .shadow(color: isOn ? tint.opacity(0.6) : .clear, radius: 12)
        }
        .buttonStyle(CCPressStyle())
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

private struct CCPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// A tall slider that fills from the bottom as you drag, like iOS brightness and volume.
private struct CCTallSlider: View {
    @Binding var value: Double
    let symbols: [String]
    let label: String
    var width: CGFloat = 76
    var height: CGFloat = 170

    private var symbol: String {
        let index = min(Int(value * Double(symbols.count)), symbols.count - 1)
        return symbols[max(index, 0)]
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Rectangle().fill(.white.opacity(0.12))
                Rectangle().fill(.white).frame(height: proxy.size.height * value)
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(value > 0.18 ? Color.black.opacity(0.7) : .white)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(.bottom, 16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { drag in
                    let next = min(max(1 - drag.location.y / proxy.size.height, 0), 1)
                    if (next == 0 || next == 1) && next != value { KitoHaptics.impact(.light) }
                    value = next
                }
            )
        }
        .frame(width: width, height: height)
        .accessibilityElement()
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(value * 100)) percent")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: value = min(1, value + 0.1)
            case .decrement: value = max(0, value - 0.1)
            @unknown default: break
            }
        }
    }
}

// MARK: - This app

private struct CCLiveGridSample: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(KitoAppSettingsViewModel.self) private var settings
    @Environment(KitoToastCenter.self) private var toasts
    @State private var online = true
    @State private var sound = true
    @State private var haptics = KitoHaptics.isEnabled

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        @Bindable var settings = settings
        LazyVGrid(columns: columns, spacing: 12) {
            Button { online.toggle(); KitoHaptics.impact(.light) } label: {
                HStack(spacing: 14) {
                    Image(systemName: online ? "wifi" : "wifi.slash")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(online ? theme.colors.success : theme.colors.danger)
                        .frame(width: 46, height: 46)
                        .background((online ? theme.colors.success : theme.colors.danger).opacity(0.18), in: Circle())
                        .contentTransition(.symbolEffect(.replace))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Connectivity").font(.subheadline.weight(.semibold))
                        Text(online ? "Online" : "Offline").font(.caption2).foregroundStyle(theme.colors.onBackground.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            .kitoGlassCard(cornerRadius: theme.radii.lg, tint: online ? theme.colors.success : theme.colors.danger)
            .gridCellColumns(2)

            appToggle("Neon", "bolt.fill", Binding(get: { settings.themeMode == .neon }, set: { settings.themeMode = $0 ? .neon : .dark }), theme.colors.primary)
            appToggle("Haptics", "waveform", $haptics, theme.colors.secondary)
                .onChange(of: haptics) { _, value in KitoHaptics.isEnabled = value }
            appToggle("Sound", sound ? "speaker.wave.2.fill" : "speaker.slash.fill", $sound, theme.colors.warning)
            appToggle("Light mode", "sun.max.fill", Binding(get: { settings.themeMode == .light }, set: { settings.themeMode = $0 ? .light : .neon }), .orange)

            CCThemeSlider(value: $settings.fontScale, range: 0.8...1.5, title: "Text size", symbol: "textformat.size", tint: theme.colors.primary)
            CCThemeSlider(value: $settings.cornerRadiusScale, range: 0...2, title: "Roundness", symbol: "square.on.circle", tint: theme.colors.secondary)

            VStack(alignment: .leading, spacing: 10) {
                Text("QUICK ACTIONS").font(.caption2.weight(.bold)).kerning(0.6).foregroundStyle(theme.colors.onBackground.opacity(0.5))
                HStack(spacing: 8) {
                    Button("Success") { KitoHaptics.success(); toasts.show("All systems go", style: .success) }
                    Button("Warning") { KitoHaptics.warning(); toasts.show("Battery at 15%", style: .warning) }
                    Button("Error") { KitoHaptics.error(); toasts.show("Connection lost", style: .error) }
                }
                .buttonStyle(.kito(.tonal, size: .small, fullWidth: true))
            }
            .padding(16)
            .kitoGlassCard(cornerRadius: theme.radii.lg)
            .gridCellColumns(2)
        }
        .foregroundStyle(theme.colors.onBackground)
    }

    private func appToggle(_ title: String, _ symbol: String, _ isOn: Binding<Bool>, _ tint: Color) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isOn.wrappedValue.toggle() }
            KitoHaptics.impact(.light)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isOn.wrappedValue ? tint : theme.colors.onBackground.opacity(0.4))
                    .frame(width: 40, height: 40)
                    .background((isOn.wrappedValue ? tint.opacity(0.2) : theme.colors.onBackground.opacity(0.1)), in: Circle())
                    .kitoGlow(isOn.wrappedValue ? tint : .clear, radius: 10, intensity: 0.4)
                Text(title).font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
        .buttonStyle(.plain)
        .kitoGlassCard(cornerRadius: theme.radii.lg, tint: isOn.wrappedValue ? tint : .clear)
        .accessibilityValue(isOn.wrappedValue ? "On" : "Off")
    }
}

/// Drag anywhere in the tile to set a theme value, filling from the bottom.
private struct CCThemeSlider: View {
    @Environment(\.kitoTheme) private var theme
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String
    let symbol: String
    let tint: Color

    private var fraction: Double { (value - range.lowerBound) / (range.upperBound - range.lowerBound) }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous).fill(theme.colors.onBackground.opacity(0.06))
                RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous)
                    .fill(tint.opacity(0.35))
                    .frame(height: max(8, proxy.size.height * fraction))
                VStack(alignment: .leading) {
                    Text(title).font(.caption.weight(.semibold))
                    Spacer()
                    HStack {
                        Image(systemName: symbol).font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Text(String(format: "%.0f%%", value * 100)).font(.caption2.weight(.bold).monospacedDigit())
                    }
                }
                .padding(12)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
                let clamped = min(max(1 - drag.location.y / max(proxy.size.height, 1), 0), 1)
                value = range.lowerBound + clamped * (range.upperBound - range.lowerBound)
            })
        }
        .frame(height: 120)
        .kitoGlassCard(cornerRadius: theme.radii.lg)
        .kitoHaptic(Int((fraction * 20).rounded())) { KitoHaptics.selectionChanged() }
        .accessibilityElement()
        .accessibilityLabel(title)
        .accessibilityValue(String(format: "%.0f percent", value * 100))
        .accessibilityAdjustableAction { direction in
            let step = (range.upperBound - range.lowerBound) / 10
            switch direction {
            case .increment: value = min(range.upperBound, value + step)
            case .decrement: value = max(range.lowerBound, value - step)
            @unknown default: break
            }
        }
    }
}

// MARK: - Toggles & tiles

private struct CCConnectivitySample: View {
    @State private var airplane = false
    @State private var cellular = true
    @State private var wifi = true
    @State private var bluetooth = true

    var body: some View {
        CCBackdrop {
            HStack(spacing: 14) {
                CCModule {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        CCRoundToggle(symbol: "airplane", label: "Airplane mode", tint: .orange, isOn: $airplane)
                        CCRoundToggle(symbol: "antenna.radiowaves.left.and.right", label: "Mobile data", tint: .green, isOn: $cellular)
                        CCRoundToggle(symbol: "wifi", label: "Wi-Fi", tint: .blue, isOn: $wifi)
                        CCRoundToggle(symbol: "dot.radiowaves.right", label: "Bluetooth", tint: .blue, isOn: $bluetooth)
                    }
                    .padding(16)
                }
                .frame(width: 170, height: 170)
                VStack(alignment: .leading, spacing: 10) {
                    status("Airplane", airplane ? "On" : "Off")
                    status("Safari-Net 5G", cellular ? "Connected" : "Off")
                    status("Wi-Fi", wifi ? "Nyumbani_5G" : "Off")
                    status("Bluetooth", bluetooth ? "Wycliff's Buds" : "Off")
                }
                .foregroundStyle(.white)
            }
            .onChange(of: airplane) { _, on in
                if on { withAnimation(.spring) { cellular = false; wifi = false; bluetooth = false } }
            }
        }
    }

    private func status(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title).font(.caption.weight(.bold))
            Text(value).font(.caption2).opacity(0.6).contentTransition(.opacity)
        }
    }
}

private struct CCRoundTogglesSample: View {
    @State private var focus = true
    @State private var torch = false
    @State private var darkMode = true
    @State private var rotation = false
    @State private var mirroring = false
    @State private var calculator = false

    var body: some View {
        CCBackdrop(colors: [Color(red: 0.1, green: 0.1, blue: 0.14), Color(red: 0.16, green: 0.12, blue: 0.3), Color(red: 0.05, green: 0.25, blue: 0.3)]) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 18) {
                labelled(CCRoundToggle(symbol: "moon.fill", label: "Do Not Disturb", tint: .indigo, isOn: $focus, size: 64), "Focus")
                labelled(CCRoundToggle(symbol: "flashlight.on.fill", label: "Torch", tint: .yellow, isOn: $torch, size: 64), "Torch")
                labelled(CCRoundToggle(symbol: "circle.lefthalf.filled", label: "Dark Mode", tint: .gray, isOn: $darkMode, size: 64), "Dark")
                labelled(CCRoundToggle(symbol: "lock.rotation", label: "Rotation lock", tint: .red, isOn: $rotation, size: 64), "Rotation")
                labelled(CCRoundToggle(symbol: "rectangle.on.rectangle", label: "Screen mirroring", tint: .teal, isOn: $mirroring, size: 64), "Mirror")
                labelled(CCRoundToggle(symbol: "plus.forwardslash.minus", label: "Calculator", tint: .orange, isOn: $calculator, size: 64), "Calc")
            }
            .padding(.vertical, 8)
        }
    }

    private func labelled(_ toggle: CCRoundToggle, _ title: String) -> some View {
        VStack(spacing: 8) {
            toggle
            Text(title).font(.caption2.weight(.semibold)).foregroundStyle(.white.opacity(0.8))
        }
    }
}

private struct CCFocusTileSample: View {
    @State private var mode: (String, String, Color)? = ("Work", "briefcase.fill", .teal)
    private let modes: [(String, String, Color)] = [("Do Not Disturb", "moon.fill", .indigo), ("Work", "briefcase.fill", .teal), ("Sleep", "bed.double.fill", .mint), ("Driving", "car.fill", .orange), ("Maombi", "hands.sparkles.fill", .purple)]

    var body: some View {
        CCBackdrop {
            VStack(spacing: 14) {
                Menu {
                    ForEach(modes, id: \.0) { item in
                        Button { withAnimation(.spring) { mode = item } } label: { Label(item.0, systemImage: item.1) }
                    }
                    Divider()
                    Button("Turn off", role: .destructive) { withAnimation(.spring) { mode = nil } }
                } label: {
                    CCModule {
                        HStack(spacing: 12) {
                            Image(systemName: mode?.1 ?? "moon")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(mode.map { AnyShapeStyle($0.2) } ?? AnyShapeStyle(.white.opacity(0.14)), in: Circle())
                                .contentTransition(.symbolEffect(.replace))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(mode?.0 ?? "Focus").font(.subheadline.weight(.bold))
                                Text(mode == nil ? "Off" : "On until 5:00 PM").font(.caption).opacity(0.6)
                            }
                            .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(14)
                    }
                    .frame(height: 72)
                }
                .buttonStyle(CCPressStyle())
                Label("Tap the tile for Focus modes", systemImage: "hand.tap").font(.caption).foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

private struct CCScenesSample: View {
    @State private var active = "Movie time"
    private let scenes: [(String, String, [Color])] = [
        ("Good morning", "sunrise.fill", [.orange, .pink]), ("Movie time", "tv.fill", [.purple, .indigo]),
        ("Leaving home", "figure.walk.departure", [.teal, .blue]), ("Good night", "moon.stars.fill", [Color(red: 0.2, green: 0.2, blue: 0.5), .black]),
    ]

    var body: some View {
        CCBackdrop {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(scenes, id: \.0) { scene in
                    let on = active == scene.0
                    Button { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { active = scene.0 }; KitoHaptics.impact(.medium) } label: {
                        VStack(alignment: .leading, spacing: 14) {
                            Image(systemName: scene.1).font(.system(size: 20, weight: .semibold)).symbolEffect(.bounce, value: on)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(scene.0).font(.subheadline.weight(.bold))
                                Text(on ? "Running" : "Scene").font(.caption2).opacity(0.7)
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background {
                            if on {
                                RoundedRectangle(cornerRadius: 24, style: .continuous).fill(LinearGradient(colors: scene.2, startPoint: .topLeading, endPoint: .bottomTrailing))
                            } else {
                                RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.ultraThinMaterial)
                            }
                        }
                        .shadow(color: on ? scene.2[0].opacity(0.5) : .clear, radius: 14, y: 6)
                    }
                    .buttonStyle(CCPressStyle())
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        }
    }
}

// MARK: - Sliders

private struct CCTallSlidersSample: View {
    @State private var brightness = 0.7
    @State private var volume = 0.45

    var body: some View {
        CCBackdrop {
            HStack(spacing: 18) {
                CCTallSlider(value: $brightness, symbols: ["sun.min.fill", "sun.max.fill"], label: "Brightness")
                CCTallSlider(value: $volume, symbols: ["speaker.slash.fill", "speaker.wave.1.fill", "speaker.wave.2.fill", "speaker.wave.3.fill"], label: "Volume")
                VStack(alignment: .leading, spacing: 12) {
                    readout("Brightness", brightness)
                    readout("Volume", volume)
                }
                .foregroundStyle(.white)
            }
        }
    }

    private func readout(_ title: String, _ value: Double) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title).font(.caption.weight(.bold)).opacity(0.7)
            Text("\(Int(value * 100))%").font(.title2.weight(.heavy).monospacedDigit()).contentTransition(.numericText())
        }
    }
}

private struct CCThermostatSample: View {
    @State private var temperature = 22.0

    private var tint: Color {
        temperature < 20 ? .cyan : (temperature < 25 ? .green : .orange)
    }

    var body: some View {
        CCBackdrop {
            CCModule {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label("Living room AC", systemImage: "air.conditioner.horizontal.fill").font(.subheadline.weight(.bold))
                        Spacer()
                        Text(String(format: "%.0f°C", temperature)).font(.title.weight(.heavy).monospacedDigit()).contentTransition(.numericText(value: temperature))
                    }
                    GeometryReader { proxy in
                        let fraction = (temperature - 16) / 14
                        ZStack(alignment: .leading) {
                            Capsule().fill(LinearGradient(colors: [.cyan, .green, .orange], startPoint: .leading, endPoint: .trailing)).opacity(0.3)
                            Capsule().fill(LinearGradient(colors: [.cyan, tint], startPoint: .leading, endPoint: .trailing))
                                .frame(width: max(44, proxy.size.width * fraction))
                            Circle().fill(.white).frame(width: 36, height: 36).shadow(radius: 4)
                                .offset(x: max(4, proxy.size.width * fraction - 40))
                        }
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
                            let next = (16 + min(max(drag.location.x / proxy.size.width, 0), 1) * 14).rounded()
                            if next != temperature { KitoHaptics.selectionChanged(); temperature = next }
                        })
                    }
                    .frame(height: 44)
                    HStack {
                        Text("16°").font(.caption2)
                        Spacer()
                        Text(temperature < 20 ? "Cool" : (temperature < 25 ? "Comfort" : "Warm")).font(.caption.weight(.bold)).foregroundStyle(tint)
                        Spacer()
                        Text("30°").font(.caption2)
                    }
                    .opacity(0.8)
                }
                .foregroundStyle(.white)
                .padding(18)
            }
            .animation(.snappy, value: temperature)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Air conditioner temperature")
            .accessibilityValue(String(format: "%.0f degrees", temperature))
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: temperature = min(30, temperature + 1)
                case .decrement: temperature = max(16, temperature - 1)
                @unknown default: break
                }
            }
        }
    }
}

private struct CCFanSpeedSample: View {
    @State private var speed = 2

    var body: some View {
        CCBackdrop(colors: [Color(red: 0.05, green: 0.2, blue: 0.25), Color(red: 0.05, green: 0.12, blue: 0.2), Color(red: 0.1, green: 0.35, blue: 0.4)]) {
            CCModule {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "fan.fill")
                            .font(.title2)
                            .rotationEffect(.degrees(speed == 0 ? 0 : 360))
                            .animation(speed == 0 ? .default : .linear(duration: 2.0 / Double(speed)).repeatForever(autoreverses: false), value: speed)
                        Text("Ceiling fan").font(.subheadline.weight(.bold))
                        Spacer()
                        Text(speed == 0 ? "Off" : "Speed \(speed)").font(.caption.weight(.bold)).opacity(0.7)
                    }
                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { index in
                            Button { withAnimation(.snappy) { speed = index == 0 && speed == 1 ? 0 : index + 1 }; KitoHaptics.selectionChanged() } label: {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(index < speed ? Color.white : Color.white.opacity(0.15))
                                    .frame(height: 20 + CGFloat(index) * 8)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Speed \(index + 1)")
                        }
                    }
                    .frame(height: 56)
                }
                .foregroundStyle(.white)
                .padding(18)
            }
        }
    }
}

// MARK: - Media & widgets

private struct CCNowPlayingSample: View {
    @State private var playing = true
    @State private var position = 84.0
    private let length = 214.0

    var body: some View {
        CCBackdrop(colors: [Color(red: 0.5, green: 0.2, blue: 0.1), Color(red: 0.2, green: 0.08, blue: 0.25), Color(red: 0.8, green: 0.4, blue: 0.2)]) {
            CCModule {
                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 58, height: 58)
                            .overlay(Image(systemName: "music.note").font(.title2.weight(.bold)).foregroundStyle(.white))
                            .scaleEffect(playing ? 1 : 0.88)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: playing)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Maisha Mazuri").font(.subheadline.weight(.bold))
                            Text("The Nairobi Collective").font(.caption).opacity(0.65)
                        }
                        Spacer()
                        Image(systemName: "airplayaudio").opacity(0.8)
                    }
                    VStack(spacing: 4) {
                        Slider(value: $position, in: 0...length).tint(.white)
                        HStack {
                            Text(clock(position))
                            Spacer()
                            Text("-" + clock(length - position))
                        }
                        .font(.caption2.monospacedDigit()).opacity(0.6)
                    }
                    HStack(spacing: 44) {
                        Button { position = max(0, position - 15) } label: { Image(systemName: "backward.fill") }.accessibilityLabel("Back 15 seconds")
                        Button { playing.toggle() } label: {
                            Image(systemName: playing ? "pause.fill" : "play.fill").font(.title).contentTransition(.symbolEffect(.replace))
                        }
                        .accessibilityLabel(playing ? "Pause" : "Play")
                        Button { position = min(length, position + 15) } label: { Image(systemName: "forward.fill") }.accessibilityLabel("Forward 15 seconds")
                    }
                    .font(.title3)
                    .buttonStyle(CCPressStyle())
                }
                .foregroundStyle(.white)
                .padding(18)
            }
        }
        .task(id: playing) {
            while playing && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if playing { position = position >= length ? 0 : position + 1 }
            }
        }
    }

    private func clock(_ seconds: Double) -> String { String(format: "%d:%02d", Int(seconds) / 60, Int(seconds) % 60) }
}

private struct CCTimerSample: View {
    @State private var total: TimeInterval = 300
    @State private var endsAt: Date?

    var body: some View {
        CCBackdrop(colors: [Color(red: 0.3, green: 0.15, blue: 0.05), Color(red: 0.1, green: 0.1, blue: 0.1), Color(red: 0.6, green: 0.3, blue: 0.05)]) {
            HStack(spacing: 16) {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let remaining = endsAt.map { max(0, $0.timeIntervalSince(context.date)) } ?? total
                    ZStack {
                        Circle().stroke(.white.opacity(0.12), lineWidth: 10)
                        Circle().trim(from: 0, to: remaining / total)
                            .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: remaining)
                        Text(String(format: "%d:%02d", Int(remaining) / 60, Int(remaining) % 60))
                            .font(.title2.weight(.heavy).monospacedDigit())
                            .contentTransition(.numericText(countsDown: true))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 130, height: 130)
                    .onChange(of: remaining == 0) { _, done in if done && endsAt != nil { KitoHaptics.success(); endsAt = nil } }
                }
                VStack(spacing: 10) {
                    ForEach([60.0, 300, 600], id: \.self) { preset in
                        Button("\(Int(preset / 60)) min") { total = preset; endsAt = nil }
                            .font(.caption.weight(.bold))
                            .frame(width: 70, height: 32)
                            .foregroundStyle(total == preset ? .black : .white)
                            .background(total == preset ? AnyShapeStyle(Color.orange) : AnyShapeStyle(.white.opacity(0.14)), in: Capsule())
                            .buttonStyle(.plain)
                    }
                    Button { endsAt = endsAt == nil ? Date().addingTimeInterval(total) : nil } label: {
                        Image(systemName: endsAt == nil ? "play.fill" : "stop.fill")
                            .frame(width: 70, height: 36)
                            .foregroundStyle(.black)
                            .background(.white, in: Capsule())
                    }
                    .buttonStyle(CCPressStyle())
                    .accessibilityLabel(endsAt == nil ? "Start timer" : "Stop timer")
                }
            }
        }
    }
}

private struct CCBatterySample: View {
    @State private var charging = true
    private let devices: [(String, String, Double)] = [("iPhone", "iphone.gen3", 0.82), ("Buds", "airpods", 0.46), ("Watch", "applewatch", 0.18)]

    var body: some View {
        CCBackdrop {
            CCModule {
                HStack(spacing: 18) {
                    ForEach(devices, id: \.0) { device in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle().stroke(.white.opacity(0.12), lineWidth: 6)
                                Circle().trim(from: 0, to: device.2)
                                    .stroke(device.2 < 0.2 ? Color.red : Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                Image(systemName: device.1).font(.system(size: 18, weight: .semibold))
                                if charging && device.0 == "iPhone" {
                                    Image(systemName: "bolt.fill").font(.system(size: 10, weight: .heavy)).foregroundStyle(.yellow)
                                        .offset(y: 22).symbolEffect(.pulse, options: .repeating)
                                }
                            }
                            .frame(width: 60, height: 60)
                            Text("\(Int(device.2 * 100))%").font(.caption.weight(.bold).monospacedDigit())
                            Text(device.0).font(.caption2).opacity(0.6)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(device.0), \(Int(device.2 * 100)) percent")
                    }
                }
                .foregroundStyle(.white)
                .padding(18)
            }
        }
    }
}

private struct CCDataBundleSample: View {
    @State private var used = 1.8
    private let bundle = 5.0

    var body: some View {
        CCBackdrop(colors: [Color(red: 0.05, green: 0.3, blue: 0.15), Color(red: 0.05, green: 0.15, blue: 0.1), Color(red: 0.2, green: 0.45, blue: 0.2)]) {
            CCModule {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("Data bundle", systemImage: "antenna.radiowaves.left.and.right").font(.subheadline.weight(.bold))
                        Spacer()
                        Text("Expires Sun, 23:59").font(.caption2).opacity(0.6)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f GB", bundle - used)).font(.system(size: 34, weight: .heavy, design: .rounded)).monospacedDigit()
                            .contentTransition(.numericText(value: used))
                        Text("left of \(Int(bundle)) GB").font(.caption).opacity(0.7)
                    }
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.14))
                            Capsule().fill(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                                .frame(width: proxy.size.width * (bundle - used) / bundle)
                        }
                    }
                    .frame(height: 10)
                    HStack(spacing: 8) {
                        Button("Stream 30 min") { withAnimation(.spring) { used = min(bundle, used + 0.7) } }
                        Button("Top up 1 GB") { withAnimation(.spring) { used = max(0, used - 1) } }
                    }
                    .font(.caption.weight(.bold))
                    .buttonStyle(.bordered)
                    .tint(.white)
                }
                .foregroundStyle(.white)
                .padding(18)
            }
        }
    }
}

// MARK: - Layouts

private struct CCFullPanelSample: View {
    @State private var airplane = false
    @State private var cellular = true
    @State private var wifi = true
    @State private var bluetooth = false
    @State private var focus = false
    @State private var torch = false
    @State private var rotation = true
    @State private var brightness = 0.6
    @State private var volume = 0.35
    @State private var playing = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.25, green: 0.1, blue: 0.4), Color(red: 0.05, green: 0.2, blue: 0.35)], startPoint: .top, endPoint: .bottom)
                .overlay(.ultraThinMaterial)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        CCModule {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                CCRoundToggle(symbol: "airplane", label: "Airplane mode", tint: .orange, isOn: $airplane, size: 54)
                                CCRoundToggle(symbol: "antenna.radiowaves.left.and.right", label: "Mobile data", tint: .green, isOn: $cellular, size: 54)
                                CCRoundToggle(symbol: "wifi", label: "Wi-Fi", tint: .blue, isOn: $wifi, size: 54)
                                CCRoundToggle(symbol: "dot.radiowaves.right", label: "Bluetooth", tint: .blue, isOn: $bluetooth, size: 54)
                            }
                            .padding(14)
                        }
                        CCModule {
                            VStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 52, height: 52)
                                    .overlay(Image(systemName: "music.note").foregroundStyle(.white))
                                Text("Maisha Mazuri").font(.caption.weight(.bold)).lineLimit(1)
                                Button { playing.toggle() } label: {
                                    Image(systemName: playing ? "pause.fill" : "play.fill").font(.title3).contentTransition(.symbolEffect(.replace))
                                }
                                .buttonStyle(CCPressStyle())
                                .accessibilityLabel(playing ? "Pause" : "Play")
                            }
                            .foregroundStyle(.white)
                            .padding(12)
                        }
                    }
                    .frame(height: 160)
                    HStack(spacing: 14) {
                        VStack(spacing: 14) {
                            HStack(spacing: 14) {
                                CCRoundToggle(symbol: "lock.rotation", label: "Rotation lock", tint: .red, isOn: $rotation)
                                CCRoundToggle(symbol: "moon.fill", label: "Focus", tint: .indigo, isOn: $focus)
                            }
                            HStack(spacing: 14) {
                                CCRoundToggle(symbol: "flashlight.on.fill", label: "Torch", tint: .yellow, isOn: $torch)
                                CCRoundToggle(symbol: "camera.fill", label: "Camera", tint: .gray, isOn: .constant(false))
                            }
                        }
                        Spacer()
                        CCTallSlider(value: $brightness, symbols: ["sun.min.fill", "sun.max.fill"], label: "Brightness", width: 70, height: 140)
                        CCTallSlider(value: $volume, symbols: ["speaker.fill", "speaker.wave.2.fill", "speaker.wave.3.fill"], label: "Volume", width: 70, height: 140)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 70)
            }
        }
        .environment(\.colorScheme, .dark)
    }
}

private struct CCEditModeSample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var editing = false
    @State private var wiggle = false
    @State private var tiles = ["flashlight.on.fill", "timer", "calculator", "camera.fill", "qrcode.viewfinder", "alarm.fill"]
    @State private var removed: [String] = []

    var body: some View {
        CCBackdrop {
            VStack(spacing: 16) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    ForEach(tiles, id: \.self) { symbol in
                        Image(systemName: symbol)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(.white.opacity(0.14), in: Circle())
                            .overlay(alignment: .topLeading) {
                                if editing {
                                    Button { withAnimation(.spring) { tiles.removeAll { $0 == symbol }; removed.append(symbol) } } label: {
                                        Image(systemName: "minus").font(.caption.weight(.heavy)).foregroundStyle(.black)
                                            .frame(width: 22, height: 22).background(.white, in: Circle())
                                    }
                                    .buttonStyle(.plain)
                                    .offset(x: -4, y: -4)
                                    .transition(.scale)
                                    .accessibilityLabel("Remove")
                                }
                            }
                            .rotationEffect(.degrees(editing && !reduceMotion ? (wiggle ? 2.5 : -2.5) : 0))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                if editing && !removed.isEmpty {
                    HStack(spacing: 10) {
                        Text("Add").font(.caption.weight(.bold)).foregroundStyle(.white.opacity(0.7))
                        ForEach(removed, id: \.self) { symbol in
                            Button { withAnimation(.spring) { removed.removeAll { $0 == symbol }; tiles.append(symbol) } } label: {
                                Image(systemName: symbol).foregroundStyle(.white).frame(width: 36, height: 36).background(.white.opacity(0.14), in: Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                Button(editing ? "Done" : "Edit controls") {
                    withAnimation(.spring) { editing.toggle() }
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
            }
        }
        .onChange(of: editing) { _, on in
            guard on, !reduceMotion else { wiggle = false; return }
            withAnimation(.easeInOut(duration: 0.13).repeatForever(autoreverses: true)) { wiggle = true }
        }
    }
}

// MARK: - Catalog

enum ControlCenterSamples {
    static let sections: [KitSection] = [app, toggles, sliders, widgets, layouts]

    static let app = KitSection("This app", symbol: "switch.2", [
        KitSample("Live controls", "Glass modules wired to this app: Neon and light themes, haptics, text size and roundness.", code: """
        @Environment(KitoAppSettingsViewModel.self) private var settings

        Toggle("Neon", isOn: Binding(get: { settings.themeMode == .neon }, set: { settings.themeMode = $0 ? .neon : .dark }))
        VerticalSlider(value: $settings.fontScale, range: 0.8...1.5)
            .kitoGlassCard(cornerRadius: theme.radii.lg)
            .kitoHaptic(step) { KitoHaptics.selectionChanged() }
        """) { CCLiveGridSample() },
    ])

    static let toggles = KitSection("Toggles & tiles", symbol: "circle.grid.2x2", [
        KitSample("Connectivity cluster", "Airplane, mobile data, Wi-Fi and Bluetooth; airplane mode turns the rest off.", code: """
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            RoundToggle("airplane", tint: .orange, isOn: $airplane)
            RoundToggle("wifi", tint: .blue, isOn: $wifi)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))
        """) { CCConnectivitySample() },
        KitSample("Round toggles", "Six toggles that glow in their colour and bounce their symbol.", code: """
        Image(systemName: "flashlight.on.fill")
            .symbolEffect(.bounce, value: isOn)
            .background(isOn ? AnyShapeStyle(.yellow) : AnyShapeStyle(.white.opacity(0.14)), in: Circle())
            .shadow(color: isOn ? .yellow.opacity(0.6) : .clear, radius: 12)
        """) { CCRoundTogglesSample() },
        KitSample("Focus tile with a menu", "Tap for Focus modes, including Maombi.", code: """
        Menu {
            ForEach(modes) { mode in Button(mode.name, systemImage: mode.symbol) { current = mode } }
        } label: { FocusTile(current) }
        """) { CCFocusTileSample() },
        KitSample("Scenes", "Smart-home scenes that light up in their own gradient.", code: """
        SceneTile(scene)
            .background(isActive ? AnyShapeStyle(scene.gradient) : AnyShapeStyle(.ultraThinMaterial), in: RoundedRectangle(cornerRadius: 24))
        """) { CCScenesSample() },
    ])

    static let sliders = KitSection("Sliders", symbol: "slider.vertical.3", [
        KitSample("Brightness and volume", "Tall sliders that fill as you drag, with a tick at each end.", code: """
        ZStack(alignment: .bottom) {
            Rectangle().fill(.white.opacity(0.12))
            Rectangle().fill(.white).frame(height: height * value)
        }
        .gesture(DragGesture(minimumDistance: 0).onChanged { value = 1 - $0.location.y / height })
        """) { CCTallSlidersSample() },
        KitSample("Thermostat", "A temperature slider that changes colour from cool to warm.", code: """
        Capsule().fill(LinearGradient(colors: [.cyan, tint], startPoint: .leading, endPoint: .trailing))
        Text("\\(Int(temperature))°C").contentTransition(.numericText(value: temperature))
        """) { CCThermostatSample() },
        KitSample("Fan speed", "Five stepped bars; the fan spins faster with each.", code: """
        Image(systemName: "fan.fill")
            .rotationEffect(.degrees(speed == 0 ? 0 : 360))
            .animation(.linear(duration: 2 / Double(speed)).repeatForever(autoreverses: false), value: speed)
        """) { CCFanSpeedSample() },
    ])

    static let widgets = KitSection("Media & widgets", symbol: "play.circle", [
        KitSample("Now playing", "Artwork, scrubber and transport controls that keep time.", code: """
        Slider(value: $position, in: 0...length).tint(.white)
        Image(systemName: playing ? "pause.fill" : "play.fill").contentTransition(.symbolEffect(.replace))
        """) { CCNowPlayingSample() },
        KitSample("Timer", "Presets, a ring that empties and digits that count down.", code: """
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(remaining(at: context.date)).contentTransition(.numericText(countsDown: true))
        }
        """) { CCTimerSample() },
        KitSample("Batteries", "Phone, earbuds and watch at a glance.", code: "Circle().trim(from: 0, to: level).stroke(level < 0.2 ? .red : .green, lineWidth: 6)") { CCBatterySample() },
        KitSample("Data bundle", "What's left of the week's bundle, rolling as you use it.", code: "Text(String(format: \"%.1f GB\", left)).contentTransition(.numericText(value: used))") { CCDataBundleSample() },
    ])

    static let layouts = KitSection("Layouts", symbol: "square.grid.3x3.square", [
        KitSample("Full control centre", "Everything together over a blurred wallpaper.", code: """
        ZStack {
            wallpaper.overlay(.ultraThinMaterial)
            VStack { connectivity; HStack { toggles; brightness; volume } }
        }
        """) { ModalStage { CCFullPanelSample() } },
        KitSample("Edit mode", "Controls wobble, minus badges remove them, and they can be added back.", code: """
        control
            .rotationEffect(.degrees(isEditing ? (wiggle ? 2.5 : -2.5) : 0))
            .overlay(alignment: .topLeading) { if isEditing { RemoveBadge { remove(control) } } }
        """) { CCEditModeSample() },
    ])
}

/// Every Control Center sample.
struct ControlCenterDemo: View {
    static var count: Int { KitGallery.count(ControlCenterSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Control Center",
            sections: ControlCenterSamples.sections,
            footnote: "Built from SwiftUI with `import KitoCore` for glass cards and theming, and `import KitoHaptics` for feedback.",
            searchHint: "Try “toggle”, “slider”, “timer” or “edit”."
        )
    }
}
