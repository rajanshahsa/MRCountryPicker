// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MRCountryPicker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "MRCountryPicker",
            targets: ["MRCountryPicker"]
        )
    ],
    targets: [
        // Main library target configured to match the repo layout shown in the screenshot.
        // Sources: MRCountryPicker/Classes/**
        // Resources: MRCountryPicker/Assets/** (Data, Images, etc.)
        .target(
            name: "MRCountryPicker",
            path: "MRCountryPicker",
            exclude: [
                // Exclude non-source directories under the repo root that shouldn't be part of the target
                "../Example",
                "../Pods",
                // Exclude top-level files not needed in compilation if they appear within this path
                "README.md",
                "CHANGELOG",
                "LICENSE",
                "MRCountryPicker.podspec"
            ],
            sources: [
                // Explicitly include Swift sources under Classes
                "Classes/SwiftCountryPicker",
                "Classes/SwiftCountryView"
            ],
            resources: [
                // Process assets used by the picker (flags data, images, etc.)
                .process("Assets/Data"),
                .process("Assets/Images")
            ]
        ),

        // Unit tests for the library
        .testTarget(
            name: "MRCountryPickerTests",
            dependencies: ["MRCountryPicker"],
            path: "Tests"
        )
    ]
)
