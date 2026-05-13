// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MTPRO",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "MTPROCore", targets: ["MTPROCore"]),
        .library(name: "MTPROAdapters", targets: ["MTPROAdapters"]),
        .library(name: "MTPROPersistence", targets: ["MTPROPersistence"]),
        .library(name: "MTPROApp", targets: ["MTPROApp"])
    ],
    targets: [
        .target(
            name: "MTPROCore",
            path: "Sources/MTPROCore"
        ),
        .target(
            name: "MTPROAdapters",
            dependencies: ["MTPROCore"],
            path: "Sources/MTPROAdapters"
        ),
        .target(
            name: "MTPROPersistence",
            dependencies: ["MTPROCore"],
            path: "Sources/MTPROPersistence"
        ),
        .target(
            name: "MTPROApp",
            dependencies: ["MTPROCore", "MTPROAdapters", "MTPROPersistence"],
            path: "Sources/MTPROApp"
        ),
        .testTarget(
            name: "MTPROCoreTests",
            dependencies: ["MTPROCore"],
            path: "Tests/MTPROCoreTests"
        ),
        .testTarget(
            name: "MTPROAdaptersTests",
            dependencies: ["MTPROAdapters"],
            path: "Tests/MTPROAdaptersTests"
        ),
        .testTarget(
            name: "MTPROPersistenceTests",
            dependencies: ["MTPROPersistence"],
            path: "Tests/MTPROPersistenceTests"
        ),
        .testTarget(
            name: "MTPROAppTests",
            dependencies: ["MTPROApp"],
            path: "Tests/MTPROAppTests"
        )
    ]
)
