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
            .package(url: "https://github.com/groue/GRDB.swift.git", .upToNextMajor(from: "6.29.3")),
            .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.28.2"),
            .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
            .package(url: "https://github.com/sunimp/HDWalletKit.git", .upToNextMajor(from: "1.0.0")),
            .package(url: "https://github.com/sunimp/SWCryptoKit.git", .upToNextMajor(from: "1.0.0")),
            .package(url: "https://github.com/sunimp/SWExtensions.git", .upToNextMajor(from: "1.0.0")),
            .package(url: "https://github.com/sunimp/SWToolKit.git", .upToNextMajor(from: "1.0.0")),
            .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.54.6"),
        ],
        targets: [
            .target(
                    name: "BinanceChainKit",
                    dependencies: [
                        .product(name: "GRDB", package: "GRDB.swift"),
                        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                        "SwiftyJSON",
                        "HDWalletKit",
                        "SWCryptoKit",
                        "SWExtensions",
                        "SWToolKit",
                    ]
            )
        ]
)
