// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SignalRSwift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "SignalRSwift", targets: ["SignalRSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.0.0"),
    ],
    targets: [
        .target(
            name: "SignalRSwift",
            dependencies: ["Alamofire", "Starscream"],
            path: "SignalR-Swift"
        ),
        .testTarget(
            name: "SignalR-SwiftTests",
            dependencies: [
                "SignalRSwift",
                "Quick",
                "Nimble",
            ],
            path: "SignalR-SwiftTests"
        ),
    ]
)
