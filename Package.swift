// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-effect",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Effect",
            targets: ["Effect"]
        ),
        .library(
            name: "Effect Standard Library Integration",
            targets: ["Effect Standard Library Integration"]
        ),
        .library(
            name: "Effect Apple Foundation Integration",
            targets: ["Effect Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Effect",
            dependencies: []
        ),
        .target(
            name: "Effect Standard Library Integration",
            dependencies: ["Effect"]
        ),
        .target(
            name: "Effect Apple Foundation Integration",
            dependencies: [
                "Effect",
                "Effect Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Effect Tests",
            dependencies: ["Effect"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
