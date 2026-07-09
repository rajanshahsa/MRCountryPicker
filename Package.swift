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
        // Main library target. Adjust the path if your sources live elsewhere.
        .target(
            name: "MRCountryPicker",
            path: "Sources",
            exclude: [
                // Exclude non-source folders if present in Sources
            ],
            resources: [
                // If the picker uses assets (flags JSON, images, etc.) inside Sources,
                // add them here, for example:
                // .process(["Resources"]) 
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