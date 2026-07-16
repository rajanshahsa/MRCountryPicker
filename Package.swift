// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MRCountryPicker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MRCountryPicker",
            targets: ["MRCountryPicker"]
        )
    ],
    targets: [
        .target(
            name: "MRCountryPicker",
            path: "MRCountryPicker",
            resources: [
                .process("Assets/SwiftCountryPicker.bundle/Images"),
                .process("Assets/SwiftCountryPicker.bundle/Data"),
                .process("Classes/SwiftCountryView.xib")
              ]
        )
    ]
)
