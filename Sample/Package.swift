// swift-tools-version: 5.9
//
//  Package.swift
//  KitoDevKit
//
//  Created by Wycliff on 12/8/25.
//  Copyright © 2025 wyksoftsinc.com. All rights reserved.
//


import PackageDescription

// A standalone package that consumes KitoDevKit exactly the way a downstream
// app would — one dependency, one import. If this builds and its tests pass,
// the umbrella is honest.

let package = Package(
    name: "KitoSample",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "KitoSample", targets: ["KitoSample"]),
    ],
    dependencies: [
        // In CI, override to `.package(path: "..")` to test against local sources.
        .package(url: "https://github.com/WykSofts-Inc/KitoDevKit.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "KitoSample",
            dependencies: [
                .product(name: "KitoDevKit", package: "KitoDevKit"),
            ]
        ),
    ]
)
