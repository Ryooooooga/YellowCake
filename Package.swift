// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "YellowCake",
    dependencies: [
    ],
    targets: [
        .target(
            name: "YellowCake",
            dependencies: []),
        .testTarget(
            name: "YellowCakeTests",
            dependencies: ["YellowCake"]),
    ]
)
