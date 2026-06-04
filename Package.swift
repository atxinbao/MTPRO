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
        .library(name: "ExecutionClient", targets: ["ExecutionClient"]),
        .library(name: "ExecutionEngine", targets: ["ExecutionEngine"]),
        .library(name: "TraderStrategies", targets: ["TraderStrategies"]),
        .library(name: "Trader", targets: ["Trader"]),
        .library(name: "Workbench", targets: ["Workbench"]),
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
            path: "Sources/DomainModel",
            exclude: [
                "CoreBaseline.swift",
                "MarketDataModels.swift",
                "MarketPrimitives.swift"
            ],
            sources: [
                "TargetGraph/DomainModelTargetBoundary.swift"
            ]
        ),
        .target(
            name: "MessageBus",
            dependencies: ["DomainModel"],
            path: "Sources/MessageBus",
            exclude: [
                "CommandsAndQueries.swift",
                "DomainEvents.swift",
                "EventLog.swift",
                "PaperRuntimeBusRouting.swift"
            ],
            sources: [
                "TargetGraph/MessageBusTargetBoundary.swift"
            ]
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
            path: "Sources/Database",
            exclude: [
                "Projections",
                "ReplayProjection"
            ],
            sources: [
                "TargetGraph/DatabaseTargetBoundary.swift"
            ]
        ),
        .target(
            name: "DataClient",
            dependencies: ["DomainModel"],
            path: "Sources/DataClient",
            exclude: [
                "Binance"
            ],
            sources: [
                "TargetGraph/DataClientTargetBoundary.swift"
            ]
        ),
        .target(
            name: "Cache",
            dependencies: ["DomainModel", "MessageBus"],
            path: "Sources/Cache",
            exclude: [
                "MarketData"
            ],
            sources: [
                "TargetGraph/CacheTargetBoundary.swift"
            ]
        ),
        .target(
            name: "DataEngine",
            dependencies: ["DomainModel", "DataClient", "MessageBus", "Cache"],
            path: "Sources/DataEngine",
            exclude: [
                "DataQuality",
                "Ingest",
                "ScenarioReplay"
            ],
            sources: [
                "TargetGraph/DataEngineTargetBoundary.swift"
            ]
        ),
        .target(
            name: "Portfolio",
            dependencies: ["DomainModel", "MessageBus", "Cache", "Database"],
            path: "Sources/Portfolio",
            exclude: [
                "PaperAccountPortfolioProjectionV2.swift",
                "PaperPortfolioProjectionUpdate.swift",
                "SimulatedExchangePortfolioProjectionParity.swift"
            ],
            sources: [
                "TargetGraph/PortfolioTargetBoundary.swift"
            ]
        ),
        .target(
            name: "RiskEngine",
            dependencies: ["DomainModel", "MessageBus", "Cache", "Portfolio"],
            path: "Sources/RiskEngine",
            exclude: [
                "LiveGate",
                "PreTrade"
            ],
            sources: [
                "TargetGraph/RiskEngineTargetBoundary.swift"
            ]
        ),
        .target(
            name: "ExecutionClient",
            dependencies: ["DomainModel", "MessageBus"],
            path: "Sources/TargetGraph/ExecutionClient"
        ),
        .target(
            name: "ExecutionEngine",
            dependencies: ["DomainModel", "MessageBus", "Cache", "Portfolio", "RiskEngine", "ExecutionClient"],
            path: "Sources/TargetGraph/ExecutionEngine"
        ),
        .target(
            name: "TraderStrategies",
            dependencies: ["DomainModel", "MessageBus", "Cache", "Portfolio", "RiskEngine"],
            path: "Sources/Trader/Strategies/EMA",
            exclude: [
                "EMACross.swift",
                "PaperActionProposal.swift",
                "StrategySignals.swift"
            ],
            sources: [
                "TargetGraph/TraderStrategiesTargetBoundary.swift"
            ]
        ),
        .target(
            name: "Trader",
            dependencies: ["DomainModel", "MessageBus", "Cache", "TraderStrategies", "Portfolio", "RiskEngine", "ExecutionEngine"],
            path: "Sources/Trader",
            exclude: [
                "Accounts",
                "Coordination",
                "Strategies"
            ],
            sources: [
                "TargetGraph/TraderTargetBoundary.swift"
            ]
        ),
        .target(
            name: "Workbench",
            dependencies: ["Core", "Persistence"],
            path: "Sources",
            exclude: [
                "AppCompatibility",
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
                "Dashboard/DashboardApplication.swift",
                "Dashboard/DashboardTargetBoundary.swift"
            ],
            sources: [
                "Workbench/ReadModels",
                "Workbench/Report",
                "Workbench/Dashboard",
                "Workbench/Events",
                "Workbench/FutureLiveProConsole",
                "Workbench/TargetGraph",
                "Dashboard/DashboardShell.swift"
            ]
        ),
        .target(
            name: "Core",
            path: "Sources",
            exclude: [
                "AppCompatibility",
                "Cache/TargetGraph",
                "Dashboard",
                "DataClient",
                "DataEngine/Ingest",
                "DataEngine/TargetGraph",
                "Database",
                "DomainModel/TargetGraph",
                "MessageBus/TargetGraph",
                "Portfolio/TargetGraph",
                "RiskEngine/TargetGraph",
                "TargetGraph",
                "Trader/Strategies/EMA/TargetGraph",
                "Trader/TargetGraph",
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
            exclude: [
                "TargetGraph"
            ],
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
                "ReplayProjection",
                "TargetGraph"
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
                "AppCompatibility",
                "Cache",
                "Core",
                "Dashboard",
                "DataClient",
                "DataEngine/ScenarioReplay",
                "DataEngine/DataQuality",
                "DataEngine/TargetGraph",
                "Database/Projections",
                "Database/TargetGraph",
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
            dependencies: ["Workbench"],
            path: "Sources/AppCompatibility"
        ),
        .executableTarget(
            name: "Dashboard",
            dependencies: ["Workbench"],
            path: "Sources/Dashboard",
            exclude: [
                "DashboardShell.swift"
            ],
            sources: [
                "DashboardApplication.swift",
                "DashboardTargetBoundary.swift"
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
                "ExecutionClient",
                "ExecutionEngine",
                "TraderStrategies",
                "Trader",
                "Workbench",
                "Dashboard"
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
