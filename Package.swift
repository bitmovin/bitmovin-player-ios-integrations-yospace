// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "BitmovinYospaceModule",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "BitmovinYospaceModule",
            targets: ["BitmovinYospaceModule"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios.git", exact: "3.86.0"),
        .package(id: "yospace.admanagement-sdk", exact: "3.10.0"),
        .package(url: "https://github.com/socialvibe/TruexAdRenderer-iOS-Swift-Package.git", exact: "3.5.1"),
        .package(url: "https://github.com/socialvibe/TruexAdRenderer-tvOS-Swift-Package.git", exact: "3.15.2")
    ],
    targets: [
        .target(
            name: "BitmovinYospaceModule",
            dependencies: [
                .product(name: "BitmovinPlayer", package: "player-ios"),
                .product(name: "YOAdManagement-Release", package: "yospace.admanagement-sdk"),
                .product(name: "TruexAdRenderer-iOS", package: "TruexAdRenderer-iOS-Swift-Package", condition: .when(platforms: [.iOS])),
                .product(name: "TruexAdRenderer", package: "TruexAdRenderer-tvOS-Swift-Package", condition: .when(platforms: [.tvOS]))
            ],
            path: "Sources/BitmovinYospaceModule"
        )
    ],
    swiftLanguageVersions: [.v5]
)
