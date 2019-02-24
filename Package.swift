// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "YellowCake",
    dependencies: [
    ],
    targets: [
        .target(
            name: "Akouta",
            dependencies: []),
        .target(
            name: "YellowCake",
            dependencies: ["Akouta"]),
        .testTarget(
            name: "YellowCakeTests",
            dependencies: ["YellowCake"]),
    ]
)
