// swift-tools-version:5.5
//
//  Package.swift
//  Animator
//
//  Created by Aaron Wright on 7/16/19.
//  Copyright © 2019 Infinite Token LLC. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "Animator",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Animator",
            targets: ["Animator"])
    ],
    targets: [
        .target(
            name: "Animator",
            path: "Sources"),
        .testTarget(
            name: "AnimatorTests",
            dependencies: ["Animator"],
            path: "Tests"),
    ]
)
