// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "OpeningBNRQuickLook",
    platforms: [.macOS(.v13)],
    products: [.library(name: "BNRKit", targets: ["BNRKit"])],
    targets: [
        .target(name: "BNRKit"),
        .testTarget(name: "BNRKitTests", dependencies: ["BNRKit"]),
    ]
)
