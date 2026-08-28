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
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-dependency.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-equation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-hash.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Effect",
            dependencies: [
                .product(name: "Dependency", package: "swift-dependency"),
                .product(name: "Equation Protocol", package: "swift-equation"),
                .product(name: "Hash Protocol", package: "swift-hash"),
            ]
        ),
        .testTarget(
            name: "Effect Tests",
            dependencies: [
                .target(name: "Effect"),
            ]
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
