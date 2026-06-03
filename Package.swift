// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MTPRO",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "DomainModel", targets: ["DomainModel"]),
        .library(name: "MessageBus", targets: ["MessageBus"]),
        .library(name: "Database", targets: ["Database"]),
        .library(name: "DataClient", targets: ["DataClient"]),
        .library(name: "DataEngine", targets: ["DataEngine"]),
        .library(name: "Cache", targets: ["Cache"]),
        .library(name: "Portfolio", targets: ["Portfolio"]),
        .library(name: "RiskEngine", targets: ["RiskEngine"]),
        .library(name: "TraderStrategies", targets: ["TraderStrategies"]),
        .library(name: "Trader", targets: ["Trader"]),
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
            name: "DomainModel",
            path: "Sources/TargetGraph/DomainModel"
        ),
        .target(
            name: "MessageBus",
            dependencies: ["DomainModel"],
            path: "Sources/TargetGraph/MessageBus"
        ),
        .target(
            name: "Database",
            dependencies: [
                "DomainModel",
                "MessageBus",
                "CSQLite",
                .product(
                    name: "DuckDB",
                    package: "duckdb-swift",
                    condition: .when(platforms: [.macOS])
                )
            ],
            path: "Sources/TargetGraph/Database"
        ),
        .target(
            name: "DataClient",
            dependencies: ["DomainModel"],
            path: "Sources/TargetGraph/DataClient"
        ),
        .target(
            name: "Cache",
            dependencies: ["DomainModel", "MessageBus"],
            path: "Sources/TargetGraph/Cache"
        ),
        .target(
            name: "DataEngine",
            dependencies: ["DomainModel", "DataClient", "MessageBus", "Cache"],
            path: "Sources/TargetGraph/DataEngine"
        ),
        .target(
            name: "Portfolio",
            dependencies: ["DomainModel", "MessageBus", "Cache", "Database"],
            path: "Sources/TargetGraph/Portfolio"
        ),
        .target(
            name: "RiskEngine",
            dependencies: ["DomainModel", "MessageBus", "Cache", "Portfolio"],
            path: "Sources/TargetGraph/RiskEngine"
        ),
        .target(
            name: "TraderStrategies",
            dependencies: ["DomainModel", "MessageBus", "Cache", "Portfolio", "RiskEngine"],
            path: "Sources/TargetGraph/TraderStrategies"
        ),
        .target(
            name: "Trader",
            dependencies: ["DomainModel", "MessageBus", "Cache", "TraderStrategies", "Portfolio", "RiskEngine"],
            path: "Sources/TargetGraph/Trader"
        ),
        .target(
            name: "Core",
            path: "Sources",
            exclude: [
                "Dashboard",
                "DataClient",
                "DataEngine/Ingest",
                "Database",
                "TargetGraph",
                "Workbench"
            ],
            sources: [
                "Cache/MarketData",
                "Core",
                "DomainModel",
                "MessageBus",
                "Trader/Accounts",
                "Trader/Strategies/EMA",
                "Trader/Coordination/RiskBinding",
                "Portfolio",
                "RiskEngine/PreTrade",
                "RiskEngine/LiveGate",
                "ExecutionEngine/PaperLifecycle",
                "ExecutionEngine/SimulatedExchange",
                "ExecutionEngine/OMSFutureGate",
                "ExecutionClient/FutureGate",
                "ExecutionClient/BrokerCapabilityMatrix",
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
                "Cache",
                "Core",
                "Dashboard",
                "DataClient",
                "DataEngine/ScenarioReplay",
                "DataEngine/DataQuality",
                "Database/Projections",
                "DomainModel",
                "MessageBus",
                "Portfolio",
                "RiskEngine",
                "ExecutionEngine",
                "ExecutionClient",
                "TargetGraph",
                "Trader",
                "Workbench"
            ],
            sources: [
                "Database/ReplayProjection",
                "DataEngine/Ingest"
            ]
        ),
        .target(
            name: "App",
            dependencies: ["Core", "Persistence"],
            path: "Sources",
            exclude: [
                "Cache",
                "Core",
                "DataClient",
                "DataEngine",
                "Database",
                "DomainModel",
                "MessageBus",
                "Portfolio",
                "RiskEngine",
                "ExecutionEngine",
                "ExecutionClient",
                "TargetGraph",
                "Trader",
                "Dashboard/DashboardApplication.swift"
            ],
            sources: [
                "Workbench/ReadModels",
                "Workbench/Report",
                "Workbench/Dashboard",
                "Workbench/Events",
                "Workbench/FutureLiveProConsole",
                "Dashboard/DashboardShell.swift"
            ]
        ),
        .executableTarget(
            name: "Dashboard",
            dependencies: ["App"],
            path: "Sources/Dashboard",
            exclude: [
                "DashboardShell.swift"
            ],
            sources: [
                "DashboardApplication.swift"
            ]
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
            name: "TargetGraphTests",
            dependencies: [
                "DomainModel",
                "MessageBus",
                "Database",
                "DataClient",
                "DataEngine",
                "Cache",
                "Portfolio",
                "RiskEngine",
                "TraderStrategies",
                "Trader"
            ],
            path: "Tests/TargetGraphTests"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App", "Core", "Adapters", "Persistence", "Runtime"],
            path: "Tests/AppTests"
        )
    ]
)
