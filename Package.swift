// swift-tools-version:5.10

import PackageDescription

let package = Package(
        name: "BinanceChainKit",
        platforms: [
            .iOS(.v13),
        ],
        products: [
            .library(
                    name: "BinanceChainKit",
                    targets: ["BinanceChainKit"]
            ),
        ],
        dependencies: [
            .package(url: "https://github.com/groue/GRDB.swift.git", .upToNextMajor(from: "6.0.0")),
            .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.27.0"),
            .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
            .package(url: "https://github.com/sunimp/HDWalletKit.Swift.git", .upToNextMajor(from: "1.3.4")),
            .package(url: "https://github.com/sunimp/WWCryptoKit.Swift.git", .upToNextMajor(from: "1.3.4")),
            .package(url: "https://github.com/sunimp/WWExtensions.Swift.git", .upToNextMajor(from: "1.0.8")),
            .package(url: "https://github.com/sunimp/WWToolKit.Swift.git", .upToNextMajor(from: "2.0.7")),
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
