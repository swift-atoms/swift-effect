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

        .library(name: "Effect Foundation Integration", targets: ["Effect Foundation Integration"]),
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
            name: "Effect Foundation Integration",
            dependencies: [
                .target(name: "Effect"),
            ],
            path: "Sources/Effect Foundation Integration"
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
                .target(name: "Effect Foundation Integration"),
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
