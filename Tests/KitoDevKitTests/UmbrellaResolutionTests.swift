//
//  UmbrellaResolutionTests.swift
//  KitoDevKit
//
//  Created by Wycliff on 12/7/25.
//  Copyright © 2025 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoDevKit

// These tests exist to prove one thing: that importing KitoDevKit alone gave
// the test target access to every kit's public API. If a kit is removed from
// Exports.swift or Package.swift, these calls fail to compile — which is the
// signal we want. Nothing here asserts runtime behavior; each kit tests itself.

final class UmbrellaResolutionTests: XCTestCase {
    func testKitoCoreIsReExported() {
        // KitoCore.version resolves through the umbrella import.
        XCTAssertFalse(Kito.version.isEmpty)
    }

    func testThemeTokensAreReachable() {
        let theme = KitoTheme.light
        XCTAssertNotNil(theme.colors.primary)
    }

    // Add one no-op reference per child kit as they land, so a missing
    // re-export becomes a compile error instead of a silent regression.
}
