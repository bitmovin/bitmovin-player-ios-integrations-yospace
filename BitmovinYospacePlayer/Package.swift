// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinYospacePlayer",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BitmovinYospacePlayer",
            targets: ["BitmovinYospacePlayer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios.git", from: "3.100.0"),
        .package(id: "yospace.admanagement-sdk", exact: "3.10.3"),
        .package(url: "https://github.com/socialvibe/TruexAdRenderer-iOS-Swift-Package.git", exact: "3.5.1"),
        .package(url: "https://github.com/socialvibe/TruexAdRenderer-tvOS-Swift-Package.git", exact: "3.15.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BitmovinYospacePlayer",
            dependencies: [
                .product(name: "BitmovinPlayer", package: "player-ios"),
                .product(name: "YOAdManagement-Release", package: "yospace.admanagement-sdk"),
                .product(name: "TruexAdRenderer-iOS", package: "TruexAdRenderer-iOS-Swift-Package", condition: .when(platforms: [.iOS])),
                .product(name: "TruexAdRenderer", package: "TruexAdRenderer-tvOS-Swift-Package", condition: .when(platforms: [.tvOS]))
            ],
        ),
        .testTarget(
            name: "BitmovinYospacePlayerTests",
            dependencies: ["BitmovinYospacePlayer"]
        ),
    ]
)
