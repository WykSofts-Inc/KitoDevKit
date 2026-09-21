// swift-tools-version: 5.9
//
//  Package.swift
//  KitoDevKit
//
//  Created by Wycliff on 12/5/25.
//  Copyright © 2025 wyksoftsinc.com. All rights reserved.
//


import PackageDescription

// This file is the BOM analog. Every child version below is pinned exactly.
// A KitoDevKit release advertises: "these four versions were tested together."
// To roll a new curated set, bump the pins here and cut a new KitoDevKit tag.
// See docs/VERSIONING.md.

let package = Package(
    name: "KitoDevKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "KitoDevKit", targets: ["KitoDevKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/WykSofts-Inc/KitoCore.git", exact: "1.0.0"),
        .package(url: "https://github.com/wykeenjenga/KitoButtons.git", from: "1.0.0"),
        .package(url: "https://github.com/wykeenjenga/KitoFields.git", from: "1.0.0"),
        .package(url: "https://github.com/wykeenjenga/KitoScreens.git", from: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoCharts.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoLoaders.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoToasts.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoModals.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoEmptyStates.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoHaptics.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoValidation.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoNavigation.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoPermissions.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoBiometrics.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoMediaPicker.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoOnboarding.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoCart.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoOrderTracking.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoFormatting.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoConnectivity.git", exact: "1.0.0"),
        .package(url: "https://github.com/WykSofts-Inc/KitoKeychain.git", exact: "1.0.0"),
    ],
    targets: [
        .target(
            name: "KitoDevKit",
            dependencies: [
                .product(name: "KitoCore", package: "KitoCore"),
                .product(name: "KitoButtons", package: "KitoButtons"),
                .product(name: "KitoFields", package: "KitoFields"),
                .product(name: "KitoScreens", package: "KitoScreens"),
                .product(name: "KitoCharts", package: "KitoCharts"),
                .product(name: "KitoLoaders", package: "KitoLoaders"),
                .product(name: "KitoToasts", package: "KitoToasts"),
                .product(name: "KitoModals", package: "KitoModals"),
                .product(name: "KitoEmptyStates", package: "KitoEmptyStates"),
                .product(name: "KitoHaptics", package: "KitoHaptics"),
                .product(name: "KitoValidation", package: "KitoValidation"),
                .product(name: "KitoNavigation", package: "KitoNavigation"),
                .product(name: "KitoPermissions", package: "KitoPermissions"),
                .product(name: "KitoBiometrics", package: "KitoBiometrics"),
                .product(name: "KitoMediaPicker", package: "KitoMediaPicker"),
                .product(name: "KitoOnboarding", package: "KitoOnboarding"),
                .product(name: "KitoCart", package: "KitoCart"),
                .product(name: "KitoOrderTracking", package: "KitoOrderTracking"),
                .product(name: "KitoFormatting", package: "KitoFormatting"),
                .product(name: "KitoConnectivity", package: "KitoConnectivity"),
                .product(name: "KitoKeychain", package: "KitoKeychain"),
            ]
        ),
        .testTarget(
            name: "KitoDevKitTests",
            dependencies: ["KitoDevKit"]
        ),
    ]
)
