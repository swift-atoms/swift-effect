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
    dependencies: [

        .package(url: "https://github.com/swift-atoms/swift-equation.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-hash.git", branch: "main"),
],
    targets: [
        .target(
            name: "Effect",
            dependencies: [
                .product(name: "Hash", package: "swift-hash"),
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
        .testTarget(
            name: "Consolidated Effect Equation Tests",
            dependencies: [

                .target(name: "Effect"),
                .product(name: "Equation", package: "swift-equation"),
            ],
            path: "Tests/Consolidated swift-effect-equation"
        ),
        .testTarget(
            name: "Consolidated Effect Hash Tests",
            dependencies: [

                .target(name: "Effect"),
                .product(name: "Hash", package: "swift-hash"),
            ],
            path: "Tests/Consolidated swift-effect-hash"
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
