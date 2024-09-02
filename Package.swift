// swift-tools-version:5.10

import PackageDescription

let package = Package(
        name: "BinanceChainKit",
        platforms: [
            .iOS(.v14),
            .macOS(.v12)
        ],
        products: [
            .library(
                    name: "BinanceChainKit",
                    targets: ["BinanceChainKit"]
            ),
        ],
        dependencies: [
            .package(url: "https://github.com/groue/GRDB.swift.git", .upToNextMajor(from: "6.29.2")),
            .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.28.1"),
            .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
            .package(url: "https://github.com/sunimp/HDWalletKit.Swift.git", .upToNextMajor(from: "1.4.0")),
            .package(url: "https://github.com/sunimp/WWCryptoKit.Swift.git", .upToNextMajor(from: "1.4.0")),
            .package(url: "https://github.com/sunimp/WWExtensions.Swift.git", .upToNextMajor(from: "1.2.0")),
            .package(url: "https://github.com/sunimp/WWToolKit.Swift.git", .upToNextMajor(from: "2.2.0")),
            .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.54.3"),
        ],
        targets: [
            .target(
                    name: "BinanceChainKit",
                    dependencies: [
                        .product(name: "GRDB", package: "GRDB.swift"),
                        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                        "SwiftyJSON",
                        .product(name: "HDWalletKit", package: "HDWalletKit.Swift"),
                        .product(name: "WWCryptoKit", package: "WWCryptoKit.Swift"),
                        .product(name: "WWExtensions", package: "WWExtensions.Swift"),
                        .product(name: "WWToolKit", package: "WWToolKit.Swift"),
                    ]
            )
        ]
)
