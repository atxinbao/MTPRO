// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MTPRO",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Adapters", targets: ["Adapters"]),
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "App", targets: ["App"])
    ],
    targets: [
        .target(
            name: "Core",
            path: "Sources/Core"
        ),
        .target(
            name: "Adapters",
            dependencies: ["Core"],
            path: "Sources/Adapters"
        ),
        .target(
            name: "Persistence",
            dependencies: ["Core"],
            path: "Sources/Persistence"
        ),
        .target(
            name: "App",
            dependencies: ["Core", "Persistence"],
            path: "Sources/App"
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests/CoreTests"
        ),
        .testTarget(
            name: "AdaptersTests",
            dependencies: ["Adapters"],
            path: "Tests/AdaptersTests"
        ),
        .testTarget(
            name: "PersistenceTests",
            dependencies: ["Persistence"],
            path: "Tests/PersistenceTests"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App", "Core", "Persistence"],
            path: "Tests/AppTests"
        )
    ]
)
