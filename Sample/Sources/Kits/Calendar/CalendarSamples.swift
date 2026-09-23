//
//  CalendarSamples.swift
//  KitoSample
//
//  Created by Wycliff Njenga on 23/09/2026.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCalendar

// MARK: - Sample data

/// Dates are relative to today, so the today ring, the now line and "Today" headers always show.
private enum Demo {
    static var calendar: Calendar { .current }

    static func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: .now)) ?? .now
    }

    static func at(_ offset: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(byAdding: .minute, value: hour * 60 + minute, to: day(offset)) ?? .now
    }

    static func event(_ title: String, day offset: Int, _ hour: Int, _ minute: Int = 0, minutes: Int, _ color: Color, at location: String? = nil) -> KitoCalendarEvent {
        let start = at(offset, hour, minute)
        return KitoCalendarEvent(title: title, start: start, end: start.addingTimeInterval(TimeInterval(minutes * 60)), color: color, location: location)
    }

    static func allDay(_ title: String, day offset: Int, days: Int = 1, _ color: Color, at location: String? = nil) -> KitoCalendarEvent {
        KitoCalendarEvent(title: title, start: day(offset), end: day(offset + days), color: color, location: location, isAllDay: true)
    }

    /// Something happening right now, so the agenda's live badge and the timeline's now line meet.
    static var deepWork: KitoCalendarEvent {
        let start = Date.now.addingTimeInterval(-25 * 60)
        return KitoCalendarEvent(title: "Deep work: KitoCalendar", start: start, end: start.addingTimeInterval(80 * 60), color: .indigo, location: "Studio, Westlands")
    }

    static let today: [KitoCalendarEvent] = [
        event("Karura Forest run", day: 0, 6, 30, minutes: 45, .green, at: "Karura Forest"),
        event("Standup with the Kito team", day: 0, 9, minutes: 15, .purple),
        event("Design review", day: 0, 10, minutes: 90, .blue, at: "Studio, Westlands"),
        event("Coffee with Njeri", day: 0, 10, 30, minutes: 45, .orange, at: "Kilimani"),
        event("Nyama choma lunch", day: 0, 13, minutes: 60, .red, at: "Ngong Road"),
        event("Chama meeting", day: 0, 17, 30, minutes: 60, .green, at: "Lavington"),
        event("Swahili class", day: 0, 18, minutes: 60, .teal, at: "Online"),
        allDay("Amani's birthday", day: 0, .pink),
        deepWork,
    ]

    static let tomorrow: [KitoCalendarEvent] = [
        event("School run", day: 1, 7, minutes: 45, .orange),
        event("Client call · Kampala", day: 1, 9, minutes: 60, .blue, at: "Zoom"),
        event("Sprint planning", day: 1, 9, 30, minutes: 90, .purple, at: "Studio, Westlands"),
        event("Lunch with Otieno", day: 1, 12, 30, minutes: 60, .red, at: "Kenyatta Avenue"),
        event("M-Pesa integration review", day: 1, 14, minutes: 45, .green),
        event("Dentist", day: 1, 16, minutes: 30, .teal, at: "Kilimani"),
    ]

    static let week: [KitoCalendarEvent] = today + tomorrow + [
        event("Matatu to Thika", day: 2, 8, minutes: 60, .orange),
        event("Workshop: SwiftUI animations", day: 2, 10, minutes: 120, .purple, at: "iHub, Nairobi"),
        event("Gym", day: 3, 6, minutes: 60, .green, at: "Karura Forest"),
        event("Board game night", day: 3, 19, minutes: 150, .pink, at: "Westlands"),
        allDay("Flight NBO → MBA", day: 4, .blue, at: "JKIA"),
        allDay("Diani getaway", day: 4, days: 3, .teal, at: "Diani Beach"),
        event("Sunset dhow cruise", day: 5, 17, 30, minutes: 120, .orange, at: "Diani Beach"),
        event("Market run", day: -1, 9, minutes: 90, .green, at: "Maasai Market"),
        event("Family lunch", day: -2, 13, minutes: 120, .red, at: "Karen"),
    ]

    /// A busy month: some days have one event, some three or more.
    static let month: [KitoCalendarEvent] = week + (-10...24).compactMap { offset in
        guard offset % 3 == 0 || offset % 5 == 0 else { return nil }
        let colors: [Color] = [.blue, .orange, .purple, .green, .pink]
        let titles = ["Client call", "Chama meeting", "Code review", "Football at Nyayo", "Book club"]
        let index = (abs(offset) * 7) % colors.count
        return event(titles[index], day: offset, 8 + abs(offset) % 10, minutes: 60, colors[index])
    }

    /// Kenyan public holidays with fixed dates, this year.
    static let holidays: [KitoCalendarEvent] = {
        let year = calendar.component(.year, from: .now)
        let list: [(String, Int, Int)] = [
            ("New Year's Day", 1, 1), ("Labour Day", 5, 1), ("Madaraka Day", 6, 1), ("Mashujaa Day", 10, 20),
            ("Jamhuri Day", 12, 12), ("Christmas Day", 12, 25), ("Boxing Day", 12, 26),
        ]
        return list.compactMap { title, month, day in
            guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)),
                  let end = calendar.date(byAdding: .day, value: 1, to: date) else { return nil }
            return KitoCalendarEvent(title: title, start: date, end: end, color: .red, isAllDay: true)
        }
    }()

    /// Kilometres run each day for the last two months, 0…1.
    static let runs: [Date: Double] = Dictionary(uniqueKeysWithValues: (-60...0).compactMap { offset in
        let seed = abs(offset * 37 + 11) % 10
        return seed < 3 ? nil : (day(offset), Double(seed) / 10)
    })

    /// The next time a fixed-date holiday comes round, with a night either side.
    static func holidayWeekend(month: Int, day: Int, now: Date, calendar: Calendar) -> KitoDateRange {
        let today = calendar.startOfDay(for: now)
        let year = calendar.component(.year, from: today)
        let thisYear = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? today
        let holiday = thisYear < today ? (calendar.date(byAdding: .year, value: 1, to: thisYear) ?? thisYear) : thisYear
        let start = calendar.date(byAdding: .day, value: -1, to: holiday) ?? holiday
        let end = calendar.date(byAdding: .day, value: 1, to: holiday) ?? holiday
        return KitoDateRange(start: max(start, today), end: end)
    }

    static let mashujaa = KitoDatePreset("Mashujaa weekend", systemImage: "star.fill") { now, calendar in
        holidayWeekend(month: 10, day: 20, now: now, calendar: calendar)
    }

    static let jamhuri = KitoDatePreset("Jamhuri weekend", systemImage: "flag.fill") { now, calendar in
        holidayWeekend(month: 12, day: 12, now: now, calendar: calendar)
    }

    static func events(on date: Date, in events: [KitoCalendarEvent]) -> [KitoCalendarEvent] {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        return events.filter { $0.start < end && ($0.end > start || $0.start >= start) }.sorted { $0.start < $1.start }
    }

    static func kes(_ amount: Int) -> String {
        amount.formatted(.currency(code: "KES").precision(.fractionLength(0)))
    }
}

// MARK: - Shared pieces

/// A caption under a preview that rolls when its text changes.
private struct Caption: View {
    let text: String
    var systemImage = "calendar"

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .contentTransition(.numericText())
            .animation(.snappy, value: text)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Capsule().fill(Color.primary.opacity(0.06)))
            .frame(maxWidth: .infinity)
    }
}

/// A compact row for an event under a calendar.
private struct EventRow: View {
    let event: KitoCalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3).fill(event.color.gradient).frame(width: 5, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title).font(.subheadline.weight(.semibold))
                Text(event.isAllDay ? "All day" : "\(event.start.formatted(date: .omitted, time: .shortened)) – \(event.end.formatted(date: .omitted, time: .shortened))")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            if let location = event.location {
                Text(location).font(.caption2.weight(.medium)).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.primary.opacity(0.04)))
    }
}

private struct DayEvents: View {
    let date: Date?
    let events: [KitoCalendarEvent]
    var limit = 3

    var body: some View {
        let items = date.map { Demo.events(on: $0, in: events) } ?? []
        VStack(spacing: 8) {
            if items.isEmpty {
                Text("Nothing on — enjoy the day.").font(.subheadline).foregroundStyle(.secondary).padding(.vertical, 8)
            }
            ForEach(items.prefix(limit)) { event in
                EventRow(event: event).transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: items.map(\.id))
    }
}

// MARK: - Month

private struct PickADay: View {
    @State private var day: Date? = Demo.day(2)

    var body: some View {
        VStack(spacing: 18) {
            KitoMonthCalendar(selection: $day, tint: .primary)
            Caption(text: day.map { "Deliver on \($0.formatted(.dateTime.weekday(.wide).day().month(.wide)))" } ?? "Pick a delivery day", systemImage: "shippingbox.fill")
        }
    }
}

private struct EventDots: View {
    @State private var day: Date? = Demo.day(0)

    var body: some View {
        VStack(spacing: 16) {
            KitoMonthCalendar(selection: $day).events(Demo.month)
            DayEvents(date: day, events: Demo.month)
        }
    }
}

private struct SeveralDays: View {
    @State private var runs: Set<Date> = [Demo.day(1), Demo.day(3), Demo.day(6)]

    var body: some View {
        VStack(spacing: 18) {
            KitoMonthCalendar(selection: $runs, tint: .green).disablesPastDates()
            Caption(text: runs.isEmpty ? "Tap days to plan runs" : "\(runs.count) Karura runs planned", systemImage: "figure.run")
        }
    }
}

private struct RunHeatmap: View {
    @State private var day: Date?

    var body: some View {
        VStack(spacing: 16) {
            KitoMonthCalendar(selection: $day, tint: .orange)
                .heatmap(Demo.runs)
                .maximumDate(.now)
            HStack(spacing: 6) {
                Text("Less").font(.caption).foregroundStyle(.secondary)
                ForEach([0.1, 0.35, 0.6, 0.9], id: \.self) { level in
                    RoundedRectangle(cornerRadius: 4).fill(Color.orange.opacity(0.06 + 0.8 * level)).frame(width: 16, height: 16)
                }
                Text("More").font(.caption).foregroundStyle(.secondary)
                Spacer()
                if let day, let value = Demo.runs[Calendar.current.startOfDay(for: day)] {
                    Text("\(Int(value * 12)) km").font(.caption.weight(.semibold)).contentTransition(.numericText())
                }
            }
            .animation(.snappy, value: day)
        }
    }
}

private struct BookableDays: View {
    @State private var day: Date?
    private let soldOut: Set<Date> = [Demo.day(4), Demo.day(5), Demo.day(11)]

    var body: some View {
        VStack(spacing: 18) {
            KitoMonthCalendar(selection: $day, tint: .indigo)
                .minimumDate(.now)
                .maximumDate(Demo.day(45))
                .unavailableDates { date in
                    Calendar.current.component(.weekday, from: date) == 2 || soldOut.contains(Calendar.current.startOfDay(for: date))
                }
            Caption(text: day.map { "Table for 4 · \($0.formatted(.dateTime.weekday().day().month()))" } ?? "Closed Mondays · book up to 45 days ahead", systemImage: "fork.knife")
        }
    }
}

private struct Locales: View {
    enum Region: String, CaseIterable, Identifiable {
        case kenya = "Kiswahili", uk = "English (UK)", us = "English (US)"
        var id: String { rawValue }
        var locale: Locale {
            switch self {
            case .kenya: return Locale(identifier: "sw_KE")
            case .uk: return Locale(identifier: "en_GB")
            case .us: return Locale(identifier: "en_US")
            }
        }
        var calendar: Calendar {
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = locale
            calendar.firstWeekday = self == .us ? 1 : 2
            return calendar
        }
    }

    @State private var region: Region = .kenya
    @State private var day: Date? = .now

    var body: some View {
        VStack(spacing: 18) {
            Picker("Region", selection: $region) {
                ForEach(Region.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            KitoMonthCalendar(selection: $day, tint: .primary)
                .environment(\.locale, region.locale)
                .environment(\.calendar, region.calendar)
            Caption(text: region == .us ? "Weeks start on Sunday" : "Weeks start on Monday", systemImage: "globe.africa.fill")
        }
    }
}

// MARK: - Ranges

private struct StayRange: View {
    @State private var stay = KitoRangeSelection()
    private let nightly = 12_500

    var body: some View {
        VStack(spacing: 16) {
            KitoMonthCalendar(range: $stay, tint: .primary).disablesPastDates()
            VStack(alignment: .leading, spacing: 6) {
                Text("Diani Beach cottage").font(.headline)
                Group {
                    if let range = stay.range {
                        let nights = range.nights()
                        Text("\(range.formatted()) · \(Demo.kes(nightly * nights))")
                    } else if stay.isAwaitingEnd {
                        Text("Now pick your check-out day")
                    } else {
                        Text("Pick your check-in day · \(Demo.kes(nightly)) a night")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.primary.opacity(0.05)))
            .animation(.snappy, value: stay)
        }
    }
}

private struct RangeField: View {
    @State private var stay: KitoDateRange? = KitoDateRange(start: Demo.day(19), end: Demo.day(25))

    var body: some View {
        VStack(spacing: 16) {
            KitoDateRangeBar(range: $stay, title: "Check-in – Check-out")
            KitoDateRangeBar(range: .constant(nil), title: "Return trip", placeholder: "Add dates", unit: .days)
            Caption(text: stay.map { "\($0.nights()) nights in Naivasha" } ?? "No dates yet", systemImage: "tent.fill")
        }
    }
}

private struct RangeChip: View {
    @State private var trip: KitoDateRange?
    @State private var guests = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Maasai Mara", systemImage: "binoculars.fill").font(.title3.bold())
            Text("Safari camps · Narok County").font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 10) {
                KitoDateRangeBar(range: $trip, placeholder: "Any week", unit: .days, style: .chip, tint: .primary)
                Button {
                    guests = guests % 6 + 1
                } label: {
                    Label("\(guests) guests", systemImage: "person.2.fill")
                        .font(.subheadline.weight(.semibold))
                        .contentTransition(.numericText())
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(Capsule().strokeBorder(Color.primary.opacity(0.15)))
                }
                .buttonStyle(.plain)
                .animation(.snappy, value: guests)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CustomPresets: View {
    @State private var weekend: KitoDateRange?

    var body: some View {
        VStack(spacing: 16) {
            KitoDateRangeBar(range: $weekend, title: "Long weekend", placeholder: "When are you off?")
                .presets([.thisWeekend, Demo.mashujaa, Demo.jamhuri, .nextSevenDays])
            Caption(text: weekend.map { "Out of office · \($0.formatted(unit: .days))" } ?? "Try the Mashujaa preset", systemImage: "suitcase.rolling.fill")
        }
    }
}

private struct LodgeBooking: View {
    @State private var stay: KitoDateRange? = KitoDatePreset.thisWeekend.range()
    @State private var guests = 2
    @State private var reserved = false
    private let nightly = 18_900

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(colors: [.teal, .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        Image(systemName: "water.waves").font(.system(size: 120, weight: .ultraLight)).foregroundStyle(.white.opacity(0.25))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing).padding(20)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Kilifi Creek Lodge").font(.title2.bold())
                            Label("4.9 · Kilifi, Coast", systemImage: "star.fill").font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(.white).padding(20)
                    }
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                    KitoDateRangeBar(range: $stay, title: "Check-in – Check-out")
                        .presets([.thisWeekend, .nextSevenDays, Demo.mashujaa])

                    HStack {
                        Label("Guests", systemImage: "person.2.fill").font(.body.weight(.medium))
                        Spacer()
                        Stepper("\(guests)", value: $guests, in: 1...6).fixedSize()
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))

                    VStack(spacing: 10) {
                        let nights = stay?.nights() ?? 0
                        row("\(Demo.kes(nightly)) × \(nights) night\(nights == 1 ? "" : "s")", Demo.kes(nightly * nights))
                        row("Cleaning fee", Demo.kes(nights == 0 ? 0 : 2_500))
                        Divider()
                        row("Total", Demo.kes(nights == 0 ? 0 : nightly * nights + 2_500), bold: true)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
                    .animation(.snappy, value: stay)
                }
                .padding(20)
                .padding(.top, 30)
                .padding(.bottom, 100)
            }
            VStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { reserved = true }
                } label: {
                    Label(reserved ? "Reserved for Wycliff N" : "Reserve", systemImage: reserved ? "checkmark.circle.fill" : "lock.fill")
                        .contentTransition(.symbolEffect(.replace))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(GalleryPrimaryButtonStyle())
                .disabled(stay == nil)
                .padding(20)
                .sensoryFeedback(.success, trigger: reserved)
            }
        }
        .onChange(of: stay) { _, _ in reserved = false }
    }

    private func row(_ title: String, _ value: String, bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).monospacedDigit().contentTransition(.numericText())
        }
        .font(bold ? .body.weight(.bold) : .subheadline)
    }
}

// MARK: - Week & year

private struct WeekStrip: View {
    @State private var day = Calendar.current.startOfDay(for: .now)

    var body: some View {
        VStack(spacing: 18) {
            KitoWeekStrip(selection: $day).events(Demo.week)
            DayEvents(date: day, events: Demo.week, limit: 4)
        }
    }
}

private struct DeliveryDay: View {
    @State private var day = Demo.day(1)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When should we deliver?").font(.headline)
            KitoWeekStrip(selection: $day, tint: .green)
                .disablesPastDates()
                .showsHeader(false)
            Caption(text: "Arrives \(day.formatted(.dateTime.weekday(.wide).day().month())) · free to Kilimani", systemImage: "box.truck.fill")
        }
    }
}

private struct YearAtAGlance: View {
    @State private var day: Date?

    var body: some View {
        KitoYearOverview(selection: $day).events(Demo.holidays + Demo.week)
    }
}

// MARK: - Booking slots

private struct BarberSlots: View {
    @State private var slot: KitoTimeSlot?
    private let day = Demo.day(1)

    private var slots: [KitoTimeSlot] {
        KitoSlotSchedule(opens: .init(9), closes: .init(19), duration: 30).slots(on: day, booked: [
            DateInterval(start: Demo.at(1, 10), duration: 3_600),
            DateInterval(start: Demo.at(1, 13), duration: 1_800),
            DateInterval(start: Demo.at(1, 17), duration: 5_400),
        ])
    }

    var body: some View {
        VStack(spacing: 18) {
            KitoTimeSlotPicker(slots: slots, selection: $slot, tint: .primary)
            Caption(text: slot.map { "Fade & beard trim at \($0.start.formatted(date: .omitted, time: .shortened))" } ?? "Kinyozi Studio · Westlands", systemImage: "scissors")
        }
    }
}

private struct OverlappingSlots: View {
    @State private var slot: KitoTimeSlot?

    var body: some View {
        KitoTimeSlotPicker(
            slots: KitoSlotSchedule(opens: .init(8, 30), closes: .init(13), duration: 45, interval: 15)
                .slots(on: Demo.day(2), booked: [DateInterval(start: Demo.at(2, 9, 30), duration: 2_700)]),
            selection: $slot,
            tint: .indigo
        )
        .showsEndTime()
    }
}

private struct AppointmentFlow: View {
    enum Service: String, CaseIterable, Identifiable {
        case checkup = "Check-up", cleaning = "Cleaning", whitening = "Whitening"
        var id: String { rawValue }
        var minutes: Int { self == .checkup ? 30 : (self == .cleaning ? 45 : 60) }
    }

    @State private var day = Demo.day(1)
    @State private var service: Service = .checkup
    @State private var slot: KitoTimeSlot?
    @State private var booked = false
    @Namespace private var namespace

    private var slots: [KitoTimeSlot] {
        let seed = Calendar.current.component(.day, from: day)
        let taken = [10, 12, 15].map { hour in
            DateInterval(start: Calendar.current.date(byAdding: .minute, value: (hour + seed % 3) * 60, to: Calendar.current.startOfDay(for: day)) ?? day, duration: 3_600)
        }
        return KitoSlotSchedule(opens: .init(8), closes: .init(18), duration: service.minutes, interval: 30)
            .slots(on: day, booked: taken, notBefore: .now)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "cross.case.fill").font(.title2).foregroundStyle(.white)
                            .frame(width: 52, height: 52).background(Circle().fill(Color.teal.gradient))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Savannah Dental").font(.title3.bold())
                            Text("Dr. Achieng Otieno · Kilimani").font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            ForEach(Service.allCases) { item in
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { service = item; slot = nil }
                                } label: {
                                    Text("\(item.rawValue) · \(item.minutes)m")
                                        .font(.footnote.weight(.semibold))
                                        .lineLimit(1)
                                        .fixedSize()
                                        .padding(.horizontal, 12).padding(.vertical, 9)
                                        .foregroundStyle(service == item ? Color(.systemBackground) : .primary)
                                        .background {
                                            if service == item {
                                                Capsule().fill(Color.primary).matchedGeometryEffect(id: "service", in: namespace)
                                            } else {
                                                Capsule().fill(Color.primary.opacity(0.06))
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    KitoWeekStrip(selection: $day, tint: .primary).disablesPastDates()
                    KitoTimeSlotPicker(slots: slots, selection: $slot, tint: .primary)
                }
                .padding(20)
                .padding(.top, 36)
                .padding(.bottom, 110)
            }
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { booked = true }
            } label: {
                Text(slot.map { "Book \(service.rawValue.lowercased()) at \($0.start.formatted(date: .omitted, time: .shortened))" } ?? "Pick a time")
                    .contentTransition(.numericText())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GalleryPrimaryButtonStyle())
            .disabled(slot == nil)
            .opacity(slot == nil ? 0.5 : 1)
            .padding(20)
            .background(.ultraThinMaterial)

            if booked, let slot {
                Confirmation(title: "You're booked, Wycliff", message: "\(service.rawValue) · \(slot.start.formatted(.dateTime.weekday(.wide).day().month().hour().minute()))") {
                    withAnimation(.spring) { booked = false; self.slot = nil }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onChange(of: day) { _, _ in slot = nil }
        .sensoryFeedback(.success, trigger: booked)
    }
}

private struct Confirmation: View {
    let title: String
    let message: String
    let onDone: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: appeared)
            Text(title).font(.title3.bold())
            Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Done", action: onDone).buttonStyle(GalleryPrimaryButtonStyle())
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(Color(.secondarySystemBackground)).shadow(color: .black.opacity(0.2), radius: 30, y: 10))
        .padding(12)
        .onAppear { appeared = true }
    }
}

// MARK: - Day & agenda

private struct Timeline: View {
    @State private var opened: KitoCalendarEvent?

    var body: some View {
        VStack(spacing: 14) {
            KitoDayTimeline(day: .now, events: Demo.today) { event in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { opened = event }
            }
            .frame(height: 440)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            if let opened {
                EventRow(event: opened).transition(.scale(scale: 0.9).combined(with: .opacity)).id(opened.id)
            } else {
                Caption(text: "Tap an event", systemImage: "hand.tap.fill")
            }
        }
    }
}

private struct WorkingHours: View {
    var body: some View {
        KitoDayTimeline(day: Demo.day(1), events: Demo.tomorrow)
            .visibleHours(7...18)
            .hourHeight(50)
            .frame(height: 420)
    }
}

private struct Agenda: View {
    @State private var showsEmpty = false

    var body: some View {
        VStack(spacing: 12) {
            Toggle("Empty state", isOn: $showsEmpty.animation(.snappy)).font(.subheadline.weight(.medium))
            KitoAgendaList(events: showsEmpty ? [] : Demo.week)
                .emptyState(title: "Hakuna matata", message: "Nothing planned this week, Wycliff.")
                .frame(height: 500)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

private struct CalendarApp: View {
    enum Tab: String, CaseIterable, Identifiable {
        case day = "Day", month = "Month", agenda = "Agenda"
        var id: String { rawValue }
    }

    @State private var tab: Tab = .day
    @State private var day = Calendar.current.startOfDay(for: .now)
    @State private var monthDay: Date? = .now
    @State private var events = Demo.week
    @State private var added = 0
    @Namespace private var namespace

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemBackground).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Habari, Wycliff N").font(.title2.bold())
                        Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("WN").font(.subheadline.bold()).foregroundStyle(.white)
                        .frame(width: 42, height: 42).background(Circle().fill(LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)))
                }
                HStack(spacing: 4) {
                    ForEach(Tab.allCases) { item in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) { tab = item }
                        } label: {
                            Text(item.rawValue).font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity).padding(.vertical, 9)
                                .foregroundStyle(tab == item ? Color(.systemBackground) : .primary)
                                .background {
                                    if tab == item { Capsule().fill(Color.primary).matchedGeometryEffect(id: "tab", in: namespace) }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(Capsule().fill(Color.primary.opacity(0.06)))
                .sensoryFeedback(.selection, trigger: tab)

                switch tab {
                case .day:
                    KitoWeekStrip(selection: $day, tint: .primary).events(events).showsHeader(false)
                    KitoDayTimeline(day: day, events: Demo.events(on: day, in: events))
                        .transition(.opacity)
                case .month:
                    ScrollView {
                        VStack(spacing: 14) {
                            KitoMonthCalendar(selection: $monthDay, tint: .primary).events(events)
                            DayEvents(date: monthDay, events: events, limit: 5)
                        }
                    }
                    .transition(.opacity)
                case .agenda:
                    KitoAgendaList(events: events, tint: .primary)
                        .padding(.horizontal, -20)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 36)

            Button {
                let target = tab == .month ? (monthDay ?? .now) : day
                let start = Calendar.current.date(byAdding: .hour, value: 15 + added % 5, to: Calendar.current.startOfDay(for: target)) ?? target
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    events.append(KitoCalendarEvent(title: ["Call Mum", "Pay KPLC bill", "Jog", "Fundi visit", "Read"][added % 5], start: start, end: start.addingTimeInterval(2_700), color: [.pink, .orange, .green, .blue, .purple][added % 5]))
                    added += 1
                }
            } label: {
                Image(systemName: "plus").font(.title2.weight(.semibold)).foregroundStyle(Color(.systemBackground))
                    .symbolEffect(.bounce, value: added)
                    .frame(width: 58, height: 58).background(Circle().fill(Color.primary)).shadow(color: .black.opacity(0.25), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add event")
            .padding(22)
            .sensoryFeedback(.increase, trigger: added)
        }
    }
}

// MARK: - Catalogue

enum CalendarSamples {
    private static let month = KitSection("Month", symbol: "calendar", [
        KitSample("Pick a day", "Swipe between months; the fill glides to the day you tap.", code: """
        @State private var day: Date?
        KitoMonthCalendar(selection: $day, tint: .primary)
        """) { PickADay() },
        KitSample("Event dots", "Up to three coloured dots per day, with that day's plans below.", code: """
        KitoMonthCalendar(selection: $day)
            .events(events)          // [KitoCalendarEvent]
        """) { EventDots() },
        KitSample("Several days", "Tap to add or remove days — a Set<Date> binding.", code: """
        @State private var runs: Set<Date> = []
        KitoMonthCalendar(selection: $runs, tint: .green)
            .disablesPastDates()
        """) { SeveralDays() },
        KitSample("Heatmap", "Shade days by intensity, like a running streak.", code: """
        KitoMonthCalendar(selection: $day, tint: .orange)
            .heatmap(kilometresByDay)   // [Date: Double], 0…1
            .maximumDate(.now)
        """) { RunHeatmap() },
        KitSample("Bounds and closed days", "A booking window, closed Mondays and sold-out days struck out.", code: """
        KitoMonthCalendar(selection: $day)
            .minimumDate(.now)
            .maximumDate(in45Days)
            .unavailableDates { date in
                calendar.component(.weekday, from: date) == 2 || soldOut.contains(date)
            }
        """) { BookableDays() },
        KitSample("Locale and first weekday", "Kiswahili, UK and US: names and week start follow the environment.", code: """
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2       // Monday

        KitoMonthCalendar(selection: $day)
            .environment(\\.locale, Locale(identifier: "sw_KE"))
            .environment(\\.calendar, calendar)
        """) { Locales() },
    ])

    private static let ranges = KitSection("Date ranges", symbol: "arrow.left.and.right.circle.fill", [
        KitSample("Stay range", "Start and end caps with a band that runs across weeks.", code: """
        @State private var stay = KitoRangeSelection()
        KitoMonthCalendar(range: $stay).disablesPastDates()

        if let range = stay.range {
            Text(range.formatted())      // "12 – 18 Oct · 6 nights"
        }
        """) { StayRange() },
        KitSample("Date range field", "Reads \"12 – 18 Oct · 6 nights\" and opens a sheet with presets.", code: """
        @State private var stay: KitoDateRange?
        KitoDateRangeBar(range: $stay, title: "Check-in – Check-out")
        KitoDateRangeBar(range: $trip, title: "Return trip", unit: .days)
        """) { RangeField() },
        KitSample("Compact chip", "A capsule for search bars and filters.", code: """
        KitoDateRangeBar(range: $trip, placeholder: "Any week", unit: .days, style: .chip, tint: .primary)
        """) { RangeChip() },
        KitSample("Holiday presets", "Your own one-tap ranges next to the built-in ones.", code: """
        let mashujaa = KitoDatePreset("Mashujaa weekend", systemImage: "star.fill") { now, calendar in
            KitoDateRange(start: oct19, end: oct21)
        }
        KitoDateRangeBar(range: $weekend, title: "Long weekend")
            .presets([.thisWeekend, mashujaa, .nextSevenDays])
        """) { CustomPresets() },
        KitSample("Lodge booking", "A full booking screen: dates, guests, a live total and Reserve.", code: """
        KitoDateRangeBar(range: $stay, title: "Check-in – Check-out")
            .presets([.thisWeekend, .nextSevenDays, mashujaa])

        let nights = stay?.nights() ?? 0
        Text((nightly * nights).formatted(.currency(code: "KES")))
        """) { ModalStage { LodgeBooking() } },
    ])

    private static let weekAndYear = KitSection("Week & year", symbol: "calendar.day.timeline.left", [
        KitSample("Week strip", "Swipe weeks, tap a day, jump back with Today.", code: """
        @State private var day = Date.now
        KitoWeekStrip(selection: $day)
            .events(events)
        """) { WeekStrip() },
        KitSample("Delivery day", "Future days only, without the month header.", code: """
        KitoWeekStrip(selection: $day, tint: .green)
            .disablesPastDates()
            .showsHeader(false)
        """) { DeliveryDay() },
        KitSample("Year at a glance", "Twelve mini months with Kenyan holidays; tap one to zoom in.", code: """
        KitoYearOverview(selection: $day)
            .events(holidays)
        """) { YearAtAGlance() },
    ])

    private static let slots = KitSection("Booking slots", symbol: "clock.fill", [
        KitSample("Time slots", "Morning, afternoon and evening, with taken slots struck out.", code: """
        let slots = KitoSlotSchedule(opens: .init(9), closes: .init(19), duration: 30)
            .slots(on: tomorrow, booked: bookings)
        KitoTimeSlotPicker(slots: slots, selection: $slot, tint: .primary)
        """) { BarberSlots() },
        KitSample("Overlapping slots", "45-minute sessions starting every 15 minutes.", code: """
        KitoSlotSchedule(opens: .init(8, 30), closes: .init(13), duration: 45, interval: 15)
            .slots(on: day, booked: bookings)

        KitoTimeSlotPicker(slots: slots, selection: $slot)
            .showsEndTime()
        """) { OverlappingSlots() },
        KitSample("Book an appointment", "Service, day and time, then a confirmation.", code: """
        KitoWeekStrip(selection: $day).disablesPastDates()
        KitoTimeSlotPicker(
            slots: KitoSlotSchedule(opens: .init(8), closes: .init(18), duration: service.minutes, interval: 30)
                .slots(on: day, booked: taken, notBefore: .now),
            selection: $slot
        )
        """) { ModalStage { AppointmentFlow() } },
    ])

    private static let dayAndAgenda = KitSection("Day & agenda", symbol: "list.bullet.rectangle.portrait.fill", [
        KitSample("Day timeline", "Overlapping events side by side, and a now line that moves.", code: """
        KitoDayTimeline(day: .now, events: today) { event in
            opened = event
        }
        """) { Timeline() },
        KitSample("Working hours", "Only 07:00 to 18:00, with a tighter hour height.", code: """
        KitoDayTimeline(day: tomorrow, events: events)
            .visibleHours(7...18)
            .hourHeight(50)
        """) { WorkingHours() },
        KitSample("Agenda", "Grouped by day with sticky headers and a live badge.", code: """
        KitoAgendaList(events: events) { event in open(event) }
            .emptyState(title: "Hakuna matata", message: "Nothing planned this week.")
        """) { Agenda() },
        KitSample("Calendar app", "Day, month and agenda in one screen; + adds an event.", code: """
        switch tab {
        case .day:
            KitoWeekStrip(selection: $day).events(events).showsHeader(false)
            KitoDayTimeline(day: day, events: events)
        case .month:
            KitoMonthCalendar(selection: $monthDay).events(events)
        case .agenda:
            KitoAgendaList(events: events)
        }
        """) { ModalStage { CalendarApp() } },
    ])

    static let sections: [KitSection] = [month, ranges, weekAndYear, slots, dayAndAgenda]
}

struct CalendarGallery: View {
    static var count: Int { KitGallery.count(CalendarSamples.sections) }

    var body: some View {
        KitGallery(
            title: "Calendar",
            sections: CalendarSamples.sections,
            footnote: "Requires `import KitoCalendar`.",
            searchHint: "Try “range”, “week”, “slot”, “timeline” or “agenda”."
        )
    }
}
