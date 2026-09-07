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
        .library(name: "Effect", targets: ["Effect"]),
        .library(name: "Effect Standard Library Integration", targets: ["Effect Standard Library Integration"]),
        .library(name: "Effect Foundation Library Integration", targets: ["Effect Foundation Library Integration"]),
        .library(name: "Effect Test Support", targets: ["Effect Test Support"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Effect",
            dependencies: [
            ],
            path: "Sources/Effect"
        ),
        .target(
            name: "Effect Standard Library Integration",
            dependencies: [
                .target(name: "Effect"),
            ],
            path: "Sources/Effect Standard Library Integration"
        ),
        .target(
            name: "Effect Foundation Library Integration",
            dependencies: [
                .target(name: "Effect"),
                .target(name: "Effect Standard Library Integration"),
            ],
            path: "Sources/Effect Foundation Library Integration"
        ),
        .target(
            name: "Effect Test Support",
            dependencies: [
                .target(name: "Effect"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Effect Tests",
            dependencies: [
                .target(name: "Effect"),
                .target(name: "Effect Test Support"),
                .target(name: "Effect Standard Library Integration"),
                .target(name: "Effect Foundation Library Integration"),
            ],
            path: "Tests/Effect Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
