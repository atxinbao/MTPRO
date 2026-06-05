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
        .library(name: "Core", targets: ["Core"]),
        .library(name: "Adapters", targets: ["Adapters"]),
        .library(name: "Persistence", targets: ["Persistence"]),
        .library(name: "Runtime", targets: ["Runtime"]),
        .executable(name: "Dashboard", targets: ["Dashboard"])
    ],
    dependencies: [
        .package(url: "https://github.com/duckdb/duckdb-swift.git", from: "1.1.3")
    ],
    targets: [
        .target(
            name: "DomainModel",
            path: "Sources/DomainModel",
            sources: [
                "CoreBaseline.swift",
                "DomainModelContractError.swift",
                "FoundationTargetOwnership.swift",
                "MarketDataModels.swift",
                "MarketPrimitives.swift",
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
                "FoundationMessageStream.swift",
                "MessageBusAppendOnlyJournal.swift",
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
                "FoundationDatabaseCheckpoint.swift",
                "TargetGraph/DatabaseTargetBoundary.swift"
            ]
        ),
        .target(
            name: "DataClient",
            dependencies: ["DomainModel"],
            path: "Sources/DataClient",
            exclude: [
                "AdaptersCompatibility.swift"
            ],
            sources: [
                "Binance/PublicMarketData/Adapters.swift",
                "Binance/PublicMarketData/BinanceMarketDataBatchReplayBoundary.swift",
                "Binance/PublicMarketData/BinanceMarketDataReplayFreshness.swift",
                "Binance/PublicMarketData/BinanceMarketDataReplayOperationsMetadata.swift",
                "Binance/PublicMarketData/BinanceMarketDataReplayParity.swift",
                "DataClientReadOnlyMarketDataSource.swift",
                "TargetGraph/DataClientTargetBoundary.swift"
            ]
        ),
        .target(
            name: "Cache",
            dependencies: ["DomainModel", "MessageBus"],
            path: "Sources/Cache",
            sources: [
                "CacheReadModelSnapshot.swift",
                "MarketData/CacheContractError.swift",
                "MarketData/MarketDataCache.swift",
                "MarketData/OrderBookReadModel.swift",
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
                "DataEngineReadOnlyReplayPlan.swift",
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
            path: "Sources/ExecutionClient",
            exclude: [
                "BrokerCapabilityMatrix",
                "FutureGate"
            ],
            sources: [
                "TargetGraph/ExecutionClientTargetBoundary.swift"
            ]
        ),
        .target(
            name: "ExecutionEngine",
            dependencies: ["DomainModel", "MessageBus", "Cache", "Portfolio", "RiskEngine", "ExecutionClient"],
            path: "Sources/ExecutionEngine",
            exclude: [
                "OMSFutureGate",
                "PaperLifecycle",
                "SimulatedExchange"
            ],
            sources: [
                "TargetGraph/ExecutionEngineTargetBoundary.swift"
            ]
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
            dependencies: ["DomainModel", "MessageBus", "Cache", "TraderStrategies", "Portfolio", "RiskEngine"],
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
            name: "Core",
            dependencies: ["DomainModel", "Cache"],
            path: "Sources",
            exclude: [
                "Cache/TargetGraph",
                "Cache/CacheReadModelSnapshot.swift",
                "Cache/MarketData",
                "Dashboard",
                "DataClient",
                "DataEngine/DataEngineReadOnlyReplayPlan.swift",
                "DataEngine/Ingest",
                "DataEngine/TargetGraph",
                "Database",
                "DomainModel/DomainModelContractError.swift",
                "DomainModel/FoundationTargetOwnership.swift",
                "DomainModel/CoreBaseline.swift",
                "DomainModel/MarketDataModels.swift",
                "DomainModel/MarketPrimitives.swift",
                "DomainModel/TargetGraph",
                "ExecutionClient/TargetGraph",
                "ExecutionEngine/TargetGraph",
                "MessageBus/FoundationMessageStream.swift",
                "MessageBus/MessageBusAppendOnlyJournal.swift",
                "MessageBus/TargetGraph",
                "Portfolio/TargetGraph",
                "RiskEngine/TargetGraph",
                "Trader/Strategies/EMA/TargetGraph",
                "Trader/TargetGraph"
            ],
            sources: [
                "Core",
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
            dependencies: ["DataClient"],
            path: "Sources/DataClient",
            exclude: [
                "Binance",
                "DataClientReadOnlyMarketDataSource.swift",
                "TargetGraph"
            ],
            sources: [
                "AdaptersCompatibility.swift"
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
                "FoundationDatabaseCheckpoint.swift",
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
                "Cache",
                "Core",
                "Dashboard",
                "DataClient",
                "DataEngine/DataEngineReadOnlyReplayPlan.swift",
                "DataEngine/ScenarioReplay",
                "DataEngine/DataQuality",
                "DataEngine/TargetGraph",
                "Database/FoundationDatabaseCheckpoint.swift",
                "Database/Projections",
                "Database/TargetGraph",
                "DomainModel",
                "MessageBus",
                "Portfolio",
                "RiskEngine",
                "ExecutionEngine",
                "ExecutionClient",
                "Trader"
            ],
            sources: [
                "Database/ReplayProjection",
                "DataEngine/Ingest"
            ]
        ),
        .executableTarget(
            name: "Dashboard",
            dependencies: ["Core", "Persistence"],
            path: "Sources/Dashboard",
            sources: [
                "DashboardApplication.swift",
                "DashboardTargetBoundary.swift",
                "DashboardShell.swift",
                "PaperWorkflowObservability.swift",
                "PaperWorkflowWorkbenchArchitecture.swift",
                "WorkbenchBetaAcceptancePath.swift",
                "WorkbenchBetaFirstRunState.swift",
                "ReadModels",
                "Report",
                "Events",
                "FutureLiveProConsole"
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
                "Dashboard"
            ],
            path: "Tests/TargetGraphTests"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["Dashboard", "Core", "Adapters", "Persistence", "Runtime"],
            path: "Tests/AppTests"
        )
    ]
)
