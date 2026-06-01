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
        .library(name: "Runtime", targets: ["Runtime"]),
        .library(name: "App", targets: ["App"]),
        .executable(name: "Dashboard", targets: ["Dashboard"])
    ],
    dependencies: [
        .package(url: "https://github.com/duckdb/duckdb-swift.git", from: "1.1.3")
    ],
    targets: [
        .target(
            name: "Core",
            path: "Sources",
            exclude: [
                "App",
                "Dashboard",
                "DataClient",
                "DataEngine/Ingest",
                "Database",
                "Runtime"
            ],
            sources: [
                "Cache/MarketData",
                "Core",
                "DomainModel",
                "MessageBus",
                "DataEngine/ScenarioReplay",
                "DataEngine/DataQuality"
            ]
        ),
        .target(
            name: "Adapters",
            dependencies: ["Core"],
            path: "Sources/DataClient",
            sources: [
                "Binance/PublicMarketData"
            ]
        ),
        .systemLibrary(
            name: "CSQLite",
            path: "Sources/Database/Projections/SQLite/CSQLite",
            pkgConfig: "sqlite3",
            providers: [
                .apt(["libsqlite3-dev"])
            ]
        ),
        .target(
            name: "Persistence",
            dependencies: [
                "Core",
                "CSQLite",
                .product(
                    name: "DuckDB",
                    package: "duckdb-swift",
                    condition: .when(platforms: [.macOS])
                )
            ],
            path: "Sources/Database",
            exclude: [
                "ReplayProjection"
            ],
            sources: [
                "Projections/SQLite/Persistence.swift",
                "Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift"
            ]
        ),
        .target(
            name: "Runtime",
            dependencies: ["Core", "Adapters", "Persistence"],
            path: "Sources",
            exclude: [
                "App",
                "Cache",
                "Core",
                "Dashboard",
                "DataClient",
                "DataEngine/ScenarioReplay",
                "DataEngine/DataQuality",
                "Database/Projections",
                "DomainModel",
                "MessageBus"
            ],
            sources: [
                "Database/ReplayProjection",
                "Runtime",
                "DataEngine/Ingest"
            ]
        ),
        .target(
            name: "App",
            dependencies: ["Core", "Persistence"],
            path: "Sources/App"
        ),
        .executableTarget(
            name: "Dashboard",
            dependencies: ["App"],
            path: "Sources/Dashboard"
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
            name: "RuntimeTests",
            dependencies: ["Runtime"],
            path: "Tests/RuntimeTests"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App", "Core", "Adapters", "Persistence", "Runtime"],
            path: "Tests/AppTests"
        )
    ]
)
