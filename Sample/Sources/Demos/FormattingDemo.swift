//
//  FormattingDemo.swift
//  KitoSample
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoFormatting

struct FormattingDemo: View {
    var body: some View {
        Form {
            Section("Currency") {
                row("KES", Decimal(1250.50).kitoFormatted(currency: .kes))
                row("USD", Decimal(1250.50).kitoFormatted(currency: .usd))
                row("Compact KES", Decimal(1_500_000).kitoCompactFormatted(currency: .kes))
            }
            Section("Compact numbers") {
                row("2,300", KitoNumberFormatting.compact(2300))
                row("47,200", KitoNumberFormatting.compact(47_200))
                row("2,100,000", KitoNumberFormatting.compact(2_100_000))
            }
            Section("Percent") {
                row("0.847", KitoNumberFormatting.percent(0.847, fractionDigits: 1))
            }
            Section("Dates") {
                row("Relative", KitoDateFormatting.relative(Date().addingTimeInterval(-120)))
                row("Short time", KitoDateFormatting.shortTime(Date()))
                row("Medium date", KitoDateFormatting.mediumDate(Date()))
            }
        }
        .navigationTitle("Formatting")
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
    }
}
