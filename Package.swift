// swift-tools-version:5.0
//  Package.swift
//
//  Created by Dave Carlson on 8/8/19.

import PackageDescription

let package = Package(
    name: "SMART",
	platforms: [
		.macOS(.v10_13),
        .iOS(.v12)
	],
    products: [
        .library(
            name: "SMART",
            targets: ["SMART"]),
    ],
    dependencies: [
		.package(url: "https://github.com/kuraby1389Lab/Swift-FHIR.git", .upToNextMajor(from: "4.2.0")),
		// .package(url: "https://github.com/p2/OAuth2", "5.1.0"..<"6.0.0"),
        // .package(url: "https://github.com/openid/AppAuth-iOS", .upToNextMajor(from: "1.6.0"))
    ],
    targets: [
		.target(
			name: "SMART",
			dependencies: [
				// .product(name: "AppAuth-iOS"),
				.product(name: "FHIR"),
			],
			path: "Sources",
			sources: ["SMART", "Client", "iOS", "macOS"]),
    ]
)
