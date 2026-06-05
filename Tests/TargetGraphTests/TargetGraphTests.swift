import Foundation
import Cache
import Database
import DataClient
import DataEngine
import Dashboard
import DomainModel
import ExecutionClient
import ExecutionEngine
import MessageBus
import Portfolio
import RiskEngine
import Trader
import TraderStrategies
import XCTest

final class TargetGraphTests: XCTestCase {
    func testMTP217FoundationTargetsExposeDependencyDirectionAndCompatibilityBoundary() {
        let domainModel = DomainModelTargetBoundary.mtp217
        let messageBus = MessageBusTargetBoundary.mtp217
        let database = DatabaseTargetBoundary.mtp217

        XCTAssertTrue(domainModel.boundaryHeld)
        XCTAssertTrue(messageBus.dependencyDirectionHeld)
        XCTAssertTrue(database.dependencyDirectionHeld)

        XCTAssertEqual(messageBus.allowedDependencies, ["DomainModel"])
        XCTAssertEqual(database.allowedDependencies, ["DomainModel", "MessageBus", "CSQLite", "DuckDB(macOS)"])
        XCTAssertEqual(domainModel.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(messageBus.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(database.retainedCompatibilityEnvelope, "Persistence")
    }

    func testMTP217FoundationTargetsRejectHigherLayerRuntimeAndBrokerDrift() {
        let messageBus = MessageBusTargetBoundary.mtp217
        let database = DatabaseTargetBoundary.mtp217

        for forbidden in ["Trader", "ExecutionEngine", "ExecutionClient", "Workbench", "Dashboard", "Broker", "OMS"] {
            XCTAssertTrue(messageBus.forbiddenDependencies.contains(forbidden))
            XCTAssertTrue(database.forbiddenDependencies.contains(forbidden))
        }

        XCTAssertFalse(DomainModelTargetBoundary.mtp217.containsRuntimeOrLiveCapability)
        XCTAssertFalse(messageBus.containsRuntimeOrLiveCapability)
        XCTAssertFalse(database.containsRuntimeOrLiveCapability)
        XCTAssertFalse(database.exposesSchemaToWorkbench)
        XCTAssertFalse(database.persistsBrokerOrAccountPayload)
    }

    func testMTP226FoundationTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(DomainModelTargetBoundary.mtp217.compiledBoundaryRoot, "Sources/DomainModel/TargetGraph")
        XCTAssertEqual(MessageBusTargetBoundary.mtp217.compiledBoundaryRoot, "Sources/MessageBus/TargetGraph")
        XCTAssertEqual(DatabaseTargetBoundary.mtp217.compiledBoundaryRoot, "Sources/Database/TargetGraph")

        for expected in [
            "path: \"Sources/DomainModel\"",
            "\"TargetGraph/DomainModelTargetBoundary.swift\"",
            "path: \"Sources/MessageBus\"",
            "\"TargetGraph/MessageBusTargetBoundary.swift\"",
            "path: \"Sources/Database\"",
            "\"TargetGraph/DatabaseTargetBoundary.swift\"",
            "\"DomainModel/TargetGraph\"",
            "\"MessageBus/TargetGraph\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "Package.swift must contain \(expected)")
        }

        for forbidden in [
            "path: \"Sources/TargetGraph/DomainModel\"",
            "path: \"Sources/TargetGraph/MessageBus\"",
            "path: \"Sources/TargetGraph/Database\""
        ] {
            XCTAssertFalse(packageSource.contains(forbidden), "Foundation target path must not remain active: \(forbidden)")
        }

        for migratedPath in [
            "Sources/DomainModel/TargetGraph/DomainModelTargetBoundary.swift",
            "Sources/MessageBus/TargetGraph/MessageBusTargetBoundary.swift",
            "Sources/Database/TargetGraph/DatabaseTargetBoundary.swift"
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(migratedPath).path),
                "\(migratedPath) must exist under the real module root"
            )
        }

        for retiredPath in [
            "Sources/TargetGraph/DomainModel/DomainModelTargetBoundary.swift",
            "Sources/TargetGraph/MessageBus/MessageBusTargetBoundary.swift",
            "Sources/TargetGraph/Database/DatabaseTargetBoundary.swift"
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(retiredPath).path),
                "\(retiredPath) must no longer be the active foundation target boundary file"
            )
        }
    }

    func testGH393FoundationTargetsExposeRealAPIsBeyondBoundaryAnchors() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        let domainID = try FoundationTargetID("foundation-domain")
        let domainOwnership = FoundationTargetSourceOwnership.domainModel(ownerID: domainID)
        XCTAssertEqual(domainOwnership.targetName, "DomainModel")
        XCTAssertEqual(domainOwnership.canonicalSourceRoot, "Sources/DomainModel")
        XCTAssertTrue(domainOwnership.ownsRealModuleSourceRoot)

        let topic = try FoundationMessageTopic("foundation.events")
        var stream = try FoundationMessageStream()
        let first = try stream.publish(
            topic: topic,
            sourceID: domainID,
            recordedAt: Date(timeIntervalSince1970: 393)
        )
        let second = try stream.publish(
            topic: topic,
            sourceID: domainID,
            recordedAt: Date(timeIntervalSince1970: 394)
        )
        XCTAssertEqual(first.sequence, 1)
        XCTAssertEqual(second.sequence, 2)
        XCTAssertEqual(stream.replay(topic: topic).map(\.sequence), [1, 2])

        var checkpoint = try FoundationDatabaseCheckpoint(
            checkpointID: try FoundationTargetID("foundation-database-checkpoint")
        )
        try checkpoint.apply(first)
        try checkpoint.apply(second)
        XCTAssertEqual(checkpoint.lastAppliedSequence, 2)
        XCTAssertTrue(checkpoint.ownsDatabaseSourceRoot)
        XCTAssertThrowsError(try checkpoint.apply(first)) { error in
            XCTAssertEqual(
                error as? FoundationTargetOwnershipError,
                .sequenceRegression(current: 2, proposed: 1)
            )
        }

        for expected in [
            "\"FoundationTargetOwnership.swift\"",
            "\"FoundationMessageStream.swift\"",
            "\"FoundationDatabaseCheckpoint.swift\"",
            "GH-393-DOMAINMODEL-REAL-TARGET-SMOKE",
            "GH-393-MESSAGEBUS-REAL-TARGET-SMOKE",
            "GH-393-DATABASE-REAL-TARGET-SMOKE"
        ] {
            XCTAssertTrue(packageSource.contains(expected) || packageSourceContainsAnchor(expected), "\(expected) must be active")
        }
    }

    private func packageSourceContainsAnchor(_ expected: String) -> Bool {
        DomainModelTargetBoundary.requiredValidationAnchors.contains(expected)
            || MessageBusTargetBoundary.requiredValidationAnchors.contains(expected)
            || DatabaseTargetBoundary.requiredValidationAnchors.contains(expected)
    }

    func testGH394DomainModelAndMessageBusOwnRealImplementationSource() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        let domainModelTarget = try packageTargetBlock(named: "DomainModel", packageSource: packageSource)
        let messageBusTarget = try packageTargetBlock(named: "MessageBus", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)

        for expected in [
            "\"CoreBaseline.swift\"",
            "\"DomainModelContractError.swift\"",
            "\"MarketDataModels.swift\"",
            "\"MarketPrimitives.swift\"",
            "\"FoundationTargetOwnership.swift\""
        ] {
            XCTAssertTrue(domainModelTarget.contains(expected), "DomainModel target must own \(expected)")
        }

        XCTAssertTrue(messageBusTarget.contains("\"FoundationMessageStream.swift\""))
        XCTAssertTrue(messageBusTarget.contains("\"MessageBusAppendOnlyJournal.swift\""))
        XCTAssertTrue(coreTarget.contains("dependencies: [\"DomainModel\", \"Cache\"]"))
        XCTAssertFalse(
            coreTarget.contains("\n                \"DomainModel\","),
            "Core sources must not compile Sources/DomainModel as primary owner"
        )

        let symbol = try Symbol(rawValue: "btcusdt")
        XCTAssertEqual(symbol.rawValue, "BTCUSDT")
        XCTAssertThrowsError(try Symbol(rawValue: "DOGEUSDT")) { error in
            XCTAssertEqual(error as? DomainModelContractError, .unsupportedSymbol("DOGEUSDT"))
        }

        let interval = try DateRange(
            start: Date(timeIntervalSince1970: 394),
            end: Date(timeIntervalSince1970: 454)
        )
        let bar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 100,
            high: 110,
            low: 95,
            close: 105,
            volume: 42
        )
        XCTAssertEqual(bar.close.rawValue, 105)
        XCTAssertEqual(CoreBaseline().primaryUniverse.first, "BTCUSDT")

        let stream = try MessageBusJournalStreamID("foundation.messagebus")
        let sourceID = try FoundationTargetID("foundation-source")
        var journal = try MessageBusAppendOnlyJournal()
        let first = try journal.append(
            stream: stream,
            sourceID: sourceID,
            payloadType: "foundation.payload",
            recordedAt: Date(timeIntervalSince1970: 394)
        )
        let second = try journal.append(
            stream: stream,
            sourceID: sourceID,
            payloadType: "foundation.payload",
            recordedAt: Date(timeIntervalSince1970: 395)
        )
        XCTAssertEqual(first.sequence, 1)
        XCTAssertEqual(second.sequence, 2)
        XCTAssertEqual(journal.replay(stream: stream).map(\.sequence), [1, 2])

        XCTAssertTrue(
            DomainModelTargetBoundary.requiredValidationAnchors.contains(
                "GH-394-DOMAINMODEL-REAL-IMPLEMENTATION-OWNERSHIP"
            )
        )
        XCTAssertTrue(
            MessageBusTargetBoundary.requiredValidationAnchors.contains(
                "GH-394-MESSAGEBUS-NEUTRAL-JOURNAL-OWNERSHIP"
            )
        )
    }

    func testMTP218DataTargetsExposeReadOnlyDependencyDirectionAndCompatibilityBoundary() {
        let dataClient = DataClientTargetBoundary.mtp218
        let cache = CacheTargetBoundary.mtp218
        let dataEngine = DataEngineTargetBoundary.mtp218

        XCTAssertTrue(dataClient.dependencyDirectionHeld)
        XCTAssertTrue(cache.dependencyDirectionHeld)
        XCTAssertTrue(dataEngine.dependencyDirectionHeld)

        XCTAssertEqual(dataClient.allowedDependencies, ["DomainModel"])
        XCTAssertEqual(cache.allowedDependencies, ["DomainModel", "MessageBus"])
        XCTAssertEqual(dataEngine.allowedDependencies, ["DomainModel", "DataClient", "MessageBus", "Cache"])
        XCTAssertEqual(dataClient.retainedCompatibilityEnvelope, "Adapters(re-export only)")
        XCTAssertEqual(cache.retainedCompatibilityEnvelope, "Core(re-export only)")
        XCTAssertEqual(dataEngine.retainedCompatibilityEnvelope, "Core/Runtime(scenario replay, quality, ingest workflow)")
    }

    func testMTP218DataTargetsRejectSignedAccountBrokerAndRuntimeDrift() {
        let dataClient = DataClientTargetBoundary.mtp218
        let cache = CacheTargetBoundary.mtp218
        let dataEngine = DataEngineTargetBoundary.mtp218

        XCTAssertTrue(dataClient.publicReadOnlyBoundary)
        XCTAssertFalse(dataClient.callsSignedEndpoint)
        XCTAssertFalse(dataClient.callsAccountEndpoint)
        XCTAssertFalse(dataClient.createsListenKey)
        XCTAssertFalse(dataClient.connectsBrokerOrExecutionAdapter)

        XCTAssertTrue(cache.readModelStateSurface)
        XCTAssertFalse(cache.ownsDurableFacts)
        XCTAssertFalse(cache.ownsBrokerState)
        XCTAssertFalse(cache.exposesDatabaseSchema)

        XCTAssertTrue(dataEngine.ingestReplayQualityBoundary)
        XCTAssertFalse(dataEngine.implementsPrivateStreamRuntime)
        XCTAssertFalse(dataEngine.callsSignedOrAccountEndpoint)
        XCTAssertFalse(dataEngine.routesBrokerOrExecutionCommand)
    }

    func testMTP227DataTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(DataClientTargetBoundary.mtp218.compiledBoundaryRoot, "Sources/DataClient/TargetGraph")
        XCTAssertEqual(CacheTargetBoundary.mtp218.compiledBoundaryRoot, "Sources/Cache/TargetGraph")
        XCTAssertEqual(DataEngineTargetBoundary.mtp218.compiledBoundaryRoot, "Sources/DataEngine/TargetGraph")

        for expected in [
            "path: \"Sources/DataClient\"",
            "\"TargetGraph/DataClientTargetBoundary.swift\"",
            "path: \"Sources/Cache\"",
            "\"TargetGraph/CacheTargetBoundary.swift\"",
            "path: \"Sources/DataEngine\"",
            "\"TargetGraph/DataEngineTargetBoundary.swift\"",
            "\"Cache/TargetGraph\"",
            "\"DataEngine/TargetGraph\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "Package.swift must contain \(expected)")
        }

        for forbidden in [
            "path: \"Sources/TargetGraph/DataClient\"",
            "path: \"Sources/TargetGraph/Cache\"",
            "path: \"Sources/TargetGraph/DataEngine\""
        ] {
            XCTAssertFalse(packageSource.contains(forbidden), "Data target path must not remain active: \(forbidden)")
        }

        for migratedPath in [
            "Sources/DataClient/TargetGraph/DataClientTargetBoundary.swift",
            "Sources/Cache/TargetGraph/CacheTargetBoundary.swift",
            "Sources/DataEngine/TargetGraph/DataEngineTargetBoundary.swift"
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(migratedPath).path),
                "\(migratedPath) must exist under the real module root"
            )
        }

        for retiredPath in [
            "Sources/TargetGraph/DataClient/DataClientTargetBoundary.swift",
            "Sources/TargetGraph/Cache/CacheTargetBoundary.swift",
            "Sources/TargetGraph/DataEngine/DataEngineTargetBoundary.swift"
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(retiredPath).path),
                "\(retiredPath) must no longer be the active data target boundary file"
            )
        }
    }

    func testGH395DataTargetsExposeRealAPIsBeyondBoundaryAnchors() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        let dataClientTarget = try packageTargetBlock(named: "DataClient", packageSource: packageSource)
        let cacheTarget = try packageTargetBlock(named: "Cache", packageSource: packageSource)
        let dataEngineTarget = try packageTargetBlock(named: "DataEngine", packageSource: packageSource)
        let adaptersTarget = try packageTargetBlock(named: "Adapters", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)
        let adaptersSources = try packageTargetSourcesBlock(targetBlock: adaptersTarget)
        let coreSources = try packageTargetSourcesBlock(targetBlock: coreTarget)
        let runtimeSources = try packageTargetSourcesBlock(targetBlock: runtimeTarget)

        XCTAssertTrue(dataClientTarget.contains("\"DataClientReadOnlyMarketDataSource.swift\""))
        XCTAssertTrue(dataClientTarget.contains("\"Binance/PublicMarketData/Adapters.swift\""))
        XCTAssertTrue(cacheTarget.contains("\"CacheReadModelSnapshot.swift\""))
        XCTAssertTrue(cacheTarget.contains("\"MarketData/MarketDataCache.swift\""))
        XCTAssertTrue(dataEngineTarget.contains("\"DataEngineReadOnlyReplayPlan.swift\""))
        XCTAssertFalse(adaptersSources.contains("DataClientReadOnlyMarketDataSource.swift"))
        XCTAssertFalse(coreSources.contains("CacheReadModelSnapshot.swift"))
        XCTAssertFalse(coreSources.contains("Cache/MarketData"))
        XCTAssertFalse(coreSources.contains("DataEngineReadOnlyReplayPlan.swift"))
        XCTAssertFalse(runtimeSources.contains("DataEngineReadOnlyReplayPlan.swift"))
        XCTAssertTrue(adaptersTarget.contains("dependencies: [\"DataClient\"]"))
        XCTAssertTrue(adaptersTarget.contains("\"AdaptersCompatibility.swift\""))
        XCTAssertFalse(adaptersSources.contains("Binance/PublicMarketData"))
        XCTAssertTrue(coreTarget.contains("\"Cache/CacheReadModelSnapshot.swift\""))
        XCTAssertTrue(coreTarget.contains("dependencies: [\"DomainModel\", \"Cache\"]"))
        XCTAssertTrue(runtimeTarget.contains("\"DataEngine/DataEngineReadOnlyReplayPlan.swift\""))

        let symbol = try Symbol(rawValue: "BTCUSDT")
        let source = try DataClientReadOnlyMarketDataSource(
            sourceID: try FoundationTargetID("gh-395-binance-public-source"),
            venue: .binance,
            symbol: symbol,
            timeframe: try Timeframe(contractValue: "1m"),
            datasetVersion: "fixture-gh-395"
        )
        XCTAssertTrue(source.publicReadOnlyBoundaryHeld)
        XCTAssertFalse(source.callsSignedEndpoint)
        XCTAssertFalse(source.callsAccountEndpoint)
        XCTAssertFalse(source.createsListenKey)
        XCTAssertFalse(source.connectsPrivateWebSocketRuntime)
        XCTAssertFalse(source.connectsBrokerOrExecutionAdapter)

        let streamID = try MessageBusJournalStreamID("gh-395.public-market-data")
        var snapshot = CacheReadModelSnapshot(
            snapshotID: try FoundationTargetID("gh-395-cache-snapshot"),
            stream: streamID,
            symbol: symbol
        )
        XCTAssertTrue(snapshot.readModelBoundaryHeld)
        XCTAssertFalse(snapshot.ownsDurableFacts)
        XCTAssertFalse(snapshot.ownsBrokerState)
        XCTAssertFalse(snapshot.exposesDatabaseSchema)

        let plan = DataEngineReadOnlyReplayPlan(
            planID: try FoundationTargetID("gh-395-dataengine-plan"),
            source: source,
            stream: streamID,
            cacheSnapshot: snapshot
        )
        XCTAssertTrue(plan.ingestReplayQualityBoundaryHeld)
        XCTAssertFalse(plan.implementsPrivateStreamRuntime)
        XCTAssertFalse(plan.callsSignedOrAccountEndpoint)
        XCTAssertFalse(plan.routesBrokerOrExecutionCommand)
        XCTAssertFalse(plan.exposesLiveRuntime)
        XCTAssertTrue(plan.payloadType.contains("dataengine.public-market-data.binance.BTCUSDT.1m"))

        var journal = try MessageBusAppendOnlyJournal()
        let envelope = try journal.append(
            stream: streamID,
            sourceID: source.sourceID,
            payloadType: plan.payloadType,
            recordedAt: Date(timeIntervalSince1970: 395)
        )
        try snapshot.apply(envelope)
        XCTAssertEqual(snapshot.appliedEventCount, 1)
        XCTAssertEqual(journal.replay(stream: streamID).map(\.sequence), [1])

        XCTAssertTrue(DataClientTargetBoundary.mtp218.validationAnchors.contains("GH-395-DATACLIENT-REAL-TARGET-SMOKE"))
        XCTAssertTrue(CacheTargetBoundary.mtp218.validationAnchors.contains("GH-395-CACHE-REAL-TARGET-SMOKE"))
        XCTAssertTrue(DataEngineTargetBoundary.mtp218.validationAnchors.contains("GH-395-DATAENGINE-REAL-TARGET-SMOKE"))
    }

    func testGH396DataClientAndCacheOwnImplementationSourceWhileDataEngineEnvelopeIsExplicit() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        let dataClientTarget = try packageTargetBlock(named: "DataClient", packageSource: packageSource)
        let cacheTarget = try packageTargetBlock(named: "Cache", packageSource: packageSource)
        let dataEngineTarget = try packageTargetBlock(named: "DataEngine", packageSource: packageSource)
        let adaptersTarget = try packageTargetBlock(named: "Adapters", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)
        let dataClientSources = try packageTargetSourcesBlock(targetBlock: dataClientTarget)
        let cacheSources = try packageTargetSourcesBlock(targetBlock: cacheTarget)
        let dataEngineSources = try packageTargetSourcesBlock(targetBlock: dataEngineTarget)
        let adaptersSources = try packageTargetSourcesBlock(targetBlock: adaptersTarget)
        let coreSources = try packageTargetSourcesBlock(targetBlock: coreTarget)
        let runtimeSources = try packageTargetSourcesBlock(targetBlock: runtimeTarget)

        XCTAssertTrue(dataClientSources.contains("\"Binance/PublicMarketData/Adapters.swift\""))
        XCTAssertTrue(dataClientSources.contains("\"Binance/PublicMarketData/BinanceMarketDataReplayFreshness.swift\""))
        XCTAssertTrue(dataClientSources.contains("\"DataClientReadOnlyMarketDataSource.swift\""))
        XCTAssertTrue(cacheSources.contains("\"MarketData/MarketDataCache.swift\""))
        XCTAssertTrue(cacheSources.contains("\"MarketData/OrderBookReadModel.swift\""))
        XCTAssertTrue(cacheSources.contains("\"MarketData/CacheContractError.swift\""))
        XCTAssertTrue(cacheSources.contains("\"CacheReadModelSnapshot.swift\""))
        XCTAssertTrue(dataEngineSources.contains("\"DataEngineReadOnlyReplayPlan.swift\""))

        XCTAssertTrue(adaptersTarget.contains("dependencies: [\"DataClient\"]"))
        XCTAssertTrue(adaptersSources.contains("\"AdaptersCompatibility.swift\""))
        XCTAssertFalse(adaptersSources.contains("Binance/PublicMarketData"))

        XCTAssertTrue(coreTarget.contains("dependencies: [\"DomainModel\", \"Cache\"]"))
        XCTAssertFalse(coreSources.contains("Cache/MarketData"))
        XCTAssertFalse(coreSources.contains("DataClient/Binance"))
        XCTAssertTrue(dataEngineTarget.contains("\"ScenarioReplay\""))
        XCTAssertTrue(dataEngineTarget.contains("\"DataQuality\""))
        XCTAssertTrue(runtimeTarget.contains("\"DataEngine/ScenarioReplay\""))
        XCTAssertTrue(runtimeTarget.contains("\"DataEngine/DataQuality\""))
        XCTAssertTrue(runtimeSources.contains("\"DataEngine/Ingest\""))

        let request = BinancePublicRequestContract(
            capability: .klines,
            transport: .restGET,
            path: "/api/v3/klines",
            queryItems: [BinanceQueryItem(name: "symbol", value: "BTCUSDT")]
        )
        XCTAssertTrue(request.isReadOnly)
        XCTAssertFalse(request.requiresAPIKey)

        var cache = MarketDataCache()
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let interval = try DateRange(
            start: Date(timeIntervalSince1970: 396),
            end: Date(timeIntervalSince1970: 456)
        )
        let bar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 1,
            high: 2,
            low: 0.5,
            close: 1.5,
            volume: 10
        )
        cache.ingest(.bar(bar))
        XCTAssertEqual(cache.snapshot.marketEventCount, 1)
        XCTAssertThrowsError(
            try OrderBookReadModelInput(snapshot: OrderBookSnapshot(
                symbol: symbol,
                observedAt: Date(timeIntervalSince1970: 396),
                bids: [],
                asks: []
            )).applying(OrderBookDelta(
                symbol: try Symbol(rawValue: "ETHUSDT"),
                observedAt: Date(timeIntervalSince1970: 397),
                bidUpdates: [],
                askUpdates: []
            ))
        ) { error in
            XCTAssertEqual(
                error as? CacheContractError,
                .marketDataMismatch(field: "orderBookDelta.symbol", expected: "BTCUSDT", actual: "ETHUSDT")
            )
        }

        XCTAssertTrue(
            DataClientTargetBoundary.mtp218.validationAnchors.contains(
                "GH-396-DATACLIENT-BINANCE-PUBLIC-IMPLEMENTATION-OWNERSHIP"
            )
        )
        XCTAssertTrue(
            CacheTargetBoundary.mtp218.validationAnchors.contains(
                "GH-396-CACHE-MARKETDATA-IMPLEMENTATION-OWNERSHIP"
            )
        )
        XCTAssertTrue(
            DataEngineTargetBoundary.mtp218.validationAnchors.contains(
                "GH-396-DATAENGINE-REPLAY-QUALITY-COREERROR-ENVELOPE-DOCUMENTED"
            )
        )
    }

    func testMTP219TraderPortfolioRiskTargetsExposeDependencyDirectionAndContainerBoundary() {
        let portfolio = PortfolioTargetBoundary.mtp219
        let riskEngine = RiskEngineTargetBoundary.mtp219
        let strategies = TraderStrategiesTargetBoundary.mtp219
        let trader = TraderTargetBoundary.mtp219

        XCTAssertTrue(portfolio.dependencyDirectionHeld)
        XCTAssertTrue(riskEngine.dependencyDirectionHeld)
        XCTAssertTrue(strategies.dependencyDirectionHeld)
        XCTAssertTrue(trader.dependencyDirectionHeld)

        XCTAssertEqual(portfolio.allowedDependencies, ["DomainModel", "MessageBus", "Cache", "Database"])
        XCTAssertEqual(riskEngine.allowedDependencies, ["DomainModel", "MessageBus", "Cache", "Portfolio"])
        XCTAssertEqual(strategies.allowedDependencies, ["DomainModel", "MessageBus", "Cache", "Portfolio", "RiskEngine"])
        XCTAssertEqual(trader.allowedDependencies, ["DomainModel", "MessageBus", "Cache", "TraderStrategies", "Portfolio", "RiskEngine"])
        XCTAssertTrue(trader.forbiddenDependencies.contains("ExecutionEngine"))
        XCTAssertTrue(trader.deferredDependencies.isEmpty)

        XCTAssertEqual(trader.accountContextRoot, "Sources/Trader/Accounts")
        XCTAssertEqual(trader.activeStrategyRoot, "Sources/Trader/Strategies/EMA")
        XCTAssertEqual(trader.coordinationRoot, "Sources/Trader/Coordination/RiskBinding")
        XCTAssertEqual(strategies.activeConcreteStrategies, ["EMA"])
        XCTAssertEqual(strategies.activeStrategySourceRoots, ["Sources/Trader/Strategies/EMA"])
    }

    func testMTP219TraderPortfolioRiskTargetsRejectRuntimeBrokerAndNonEMADrift() {
        let portfolio = PortfolioTargetBoundary.mtp219
        let riskEngine = RiskEngineTargetBoundary.mtp219
        let strategies = TraderStrategiesTargetBoundary.mtp219
        let trader = TraderTargetBoundary.mtp219

        XCTAssertTrue(portfolio.financialStateProjectionBoundary)
        XCTAssertFalse(portfolio.ownsAccountIdentity)
        XCTAssertFalse(portfolio.readsBrokerAccountState)
        XCTAssertFalse(portfolio.readsAccountEndpointPayload)
        XCTAssertFalse(portfolio.implementsPortfolioRuntime)

        XCTAssertTrue(riskEngine.preExecutionBoundary)
        XCTAssertFalse(riskEngine.implementsLiveRiskRuntime)
        XCTAssertFalse(riskEngine.callsBrokerOrExecutionClient)
        XCTAssertFalse(riskEngine.readsSignedOrAccountEndpoint)
        XCTAssertFalse(riskEngine.routesExecutableOrderCommand)

        XCTAssertTrue(strategies.nonEMAActiveStrategySourceRoots.isEmpty)
        XCTAssertFalse(strategies.callsExecutionClient)
        XCTAssertFalse(strategies.callsBrokerOrOMS)
        XCTAssertFalse(strategies.exposesUICommandSurface)

        XCTAssertFalse(trader.implementsTraderRuntime)
        XCTAssertFalse(trader.callsExecutionClientDirectly)
        XCTAssertFalse(trader.callsBrokerOrOMS)
        XCTAssertFalse(trader.readsRealAccountPayload)
        XCTAssertFalse(trader.exposesLiveCommandSurface)
    }

    func testMTP228TraderPortfolioRiskTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(TraderStrategiesTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Trader/Strategies/EMA/TargetGraph")
        XCTAssertEqual(TraderTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Trader/TargetGraph")
        XCTAssertEqual(PortfolioTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Portfolio/TargetGraph")
        XCTAssertEqual(RiskEngineTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/RiskEngine/TargetGraph")
        XCTAssertEqual(TraderStrategiesTargetBoundary.mtp219.activeConcreteStrategies, ["EMA"])
        XCTAssertEqual(TraderTargetBoundary.mtp219.activeStrategyRoot, "Sources/Trader/Strategies/EMA")

        for expected in [
            "path: \"Sources/Trader/Strategies/EMA\"",
            "\"TargetGraph/TraderStrategiesTargetBoundary.swift\"",
            "path: \"Sources/Trader\"",
            "\"TargetGraph/TraderTargetBoundary.swift\"",
            "path: \"Sources/Portfolio\"",
            "\"TargetGraph/PortfolioTargetBoundary.swift\"",
            "path: \"Sources/RiskEngine\"",
            "\"TargetGraph/RiskEngineTargetBoundary.swift\"",
            "\"Trader/Strategies/EMA/TargetGraph\"",
            "\"Trader/TargetGraph\"",
            "\"Portfolio/TargetGraph\"",
            "\"RiskEngine/TargetGraph\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "Package.swift must contain \(expected)")
        }

        for forbidden in [
            "path: \"Sources/TargetGraph/TraderStrategies\"",
            "path: \"Sources/TargetGraph/Trader\"",
            "path: \"Sources/TargetGraph/Portfolio\"",
            "path: \"Sources/TargetGraph/RiskEngine\""
        ] {
            XCTAssertFalse(packageSource.contains(forbidden), "Trader / Portfolio / Risk target path must not remain active: \(forbidden)")
        }

        for migratedPath in [
            "Sources/Trader/Strategies/EMA/TargetGraph/TraderStrategiesTargetBoundary.swift",
            "Sources/Trader/TargetGraph/TraderTargetBoundary.swift",
            "Sources/Portfolio/TargetGraph/PortfolioTargetBoundary.swift",
            "Sources/RiskEngine/TargetGraph/RiskEngineTargetBoundary.swift"
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(migratedPath).path),
                "\(migratedPath) must exist under the real module root"
            )
        }

        for retiredPath in [
            "Sources/TargetGraph/TraderStrategies/TraderStrategiesTargetBoundary.swift",
            "Sources/TargetGraph/Trader/TraderTargetBoundary.swift",
            "Sources/TargetGraph/Portfolio/PortfolioTargetBoundary.swift",
            "Sources/TargetGraph/RiskEngine/RiskEngineTargetBoundary.swift"
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(retiredPath).path),
                "\(retiredPath) must no longer be the active Trader / Portfolio / Risk target boundary file"
            )
        }
    }

    func testGH397TraderPortfolioRiskExecutionTargetsExposeUsableBoundaryAPIs() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let strategies = TraderStrategiesTargetBoundary.mtp219
        let trader = TraderTargetBoundary.mtp219
        let portfolio = PortfolioTargetBoundary.mtp219
        let riskEngine = RiskEngineTargetBoundary.mtp219
        let executionClient = ExecutionClientTargetBoundary.mtp220
        let executionEngine = ExecutionEngineTargetBoundary.mtp220

        XCTAssertTrue(strategies.dependencyDirectionHeld)
        XCTAssertTrue(trader.dependencyDirectionHeld)
        XCTAssertTrue(portfolio.dependencyDirectionHeld)
        XCTAssertTrue(riskEngine.dependencyDirectionHeld)
        XCTAssertTrue(executionClient.dependencyDirectionHeld)
        XCTAssertTrue(executionEngine.dependencyDirectionHeld)

        XCTAssertEqual(trader.accountContextRoot, "Sources/Trader/Accounts")
        XCTAssertEqual(trader.activeStrategyRoot, "Sources/Trader/Strategies/EMA")
        XCTAssertEqual(trader.coordinationRoot, "Sources/Trader/Coordination/RiskBinding")
        XCTAssertEqual(trader.activeConcreteStrategies, ["EMA"])
        XCTAssertEqual(strategies.activeConcreteStrategies, ["EMA"])
        XCTAssertEqual(strategies.activeStrategySourceRoots, ["Sources/Trader/Strategies/EMA"])
        XCTAssertTrue(strategies.nonEMAActiveStrategySourceRoots.isEmpty)

        XCTAssertFalse(trader.callsExecutionClientDirectly)
        XCTAssertTrue(trader.forbiddenDependencies.contains("ExecutionEngine"))
        XCTAssertTrue(trader.forbiddenDependencies.contains("ExecutionClient"))
        XCTAssertFalse(strategies.callsExecutionClient)
        XCTAssertFalse(strategies.callsBrokerOrOMS)
        XCTAssertFalse(riskEngine.callsBrokerOrExecutionClient)
        XCTAssertFalse(riskEngine.routesExecutableOrderCommand)

        XCTAssertTrue(executionClient.futureGateOnly)
        XCTAssertFalse(executionClient.implementsBrokerGateway)
        XCTAssertFalse(executionClient.implementsOrderSubmitCancelReplace)
        XCTAssertFalse(executionClient.parsesExecutionReportOrBrokerFill)
        XCTAssertTrue(executionEngine.paperSimulatedLifecycleBoundary)
        XCTAssertTrue(executionEngine.consumesRiskEngineBoundary)
        XCTAssertTrue(executionEngine.executionClientFutureGateOnly)
        XCTAssertFalse(executionEngine.implementsLiveExecutionRuntime)
        XCTAssertFalse(executionEngine.implementsOMS)
        XCTAssertFalse(executionEngine.implementsRealOrderLifecycle)

        XCTAssertEqual(portfolio.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(riskEngine.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(strategies.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(trader.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(executionClient.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(executionEngine.retainedCompatibilityEnvelope, "Core")

        XCTAssertTrue(strategies.validationAnchors.contains("GH-397-TRADERSTRATEGIES-EMA-REAL-TARGET-SMOKE"))
        XCTAssertTrue(trader.validationAnchors.contains("GH-397-TRADER-REAL-TARGET-SMOKE"))
        XCTAssertTrue(portfolio.validationAnchors.contains("GH-397-PORTFOLIO-REAL-TARGET-SMOKE"))
        XCTAssertTrue(riskEngine.validationAnchors.contains("GH-397-RISKENGINE-REAL-TARGET-SMOKE"))
        XCTAssertTrue(executionClient.validationAnchors.contains("GH-397-EXECUTIONCLIENT-FUTURE-GATE-SMOKE"))
        XCTAssertTrue(executionEngine.validationAnchors.contains("GH-397-EXECUTIONENGINE-REAL-TARGET-SMOKE"))

        let traderStrategiesTarget = try packageTargetBlock(named: "TraderStrategies", packageSource: packageSource)
        let traderTarget = try packageTargetBlock(named: "Trader", packageSource: packageSource)
        let portfolioTarget = try packageTargetBlock(named: "Portfolio", packageSource: packageSource)
        let riskEngineTarget = try packageTargetBlock(named: "RiskEngine", packageSource: packageSource)
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)

        XCTAssertTrue(traderStrategiesTarget.contains("path: \"Sources/Trader/Strategies/EMA\""))
        XCTAssertTrue(traderTarget.contains("path: \"Sources/Trader\""))
        XCTAssertTrue(portfolioTarget.contains("path: \"Sources/Portfolio\""))
        XCTAssertTrue(riskEngineTarget.contains("path: \"Sources/RiskEngine\""))
        XCTAssertTrue(executionClientTarget.contains("path: \"Sources/ExecutionClient\""))
        XCTAssertTrue(executionEngineTarget.contains("path: \"Sources/ExecutionEngine\""))

        XCTAssertTrue(traderTarget.contains("dependencies: [\"DomainModel\", \"MessageBus\", \"Cache\", \"TraderStrategies\", \"Portfolio\", \"RiskEngine\"]"))
        XCTAssertFalse(traderTarget.contains("\"ExecutionEngine\""))
        XCTAssertFalse(traderTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(executionEngineTarget.contains("dependencies: [\"DomainModel\", \"MessageBus\", \"Cache\", \"Portfolio\", \"RiskEngine\", \"ExecutionClient\"]"))
        XCTAssertTrue(executionClientTarget.contains("dependencies: [\"DomainModel\", \"MessageBus\"]"))
    }

    func testMTP220ExecutionTargetsExposeFutureGateDependencyDirection() {
        let executionClient = ExecutionClientTargetBoundary.mtp220
        let executionEngine = ExecutionEngineTargetBoundary.mtp220
        let trader = TraderTargetBoundary.mtp219

        XCTAssertTrue(executionClient.dependencyDirectionHeld)
        XCTAssertTrue(executionEngine.dependencyDirectionHeld)
        XCTAssertTrue(trader.dependencyDirectionHeld)

        XCTAssertEqual(executionClient.allowedDependencies, ["DomainModel", "MessageBus"])
        XCTAssertEqual(executionEngine.allowedDependencies, ["DomainModel", "MessageBus", "Cache", "Portfolio", "RiskEngine", "ExecutionClient"])
        XCTAssertEqual(trader.allowedDependencies, ["DomainModel", "MessageBus", "Cache", "TraderStrategies", "Portfolio", "RiskEngine"])
        XCTAssertFalse(trader.allowedDependencies.contains("ExecutionEngine"))
        XCTAssertTrue(trader.forbiddenDependencies.contains("ExecutionEngine"))
        XCTAssertTrue(trader.validationAnchors.contains("GH-392-TRADER-NO-DIRECT-EXECUTIONENGINE-DEPENDENCY"))
        XCTAssertTrue(trader.deferredDependencies.isEmpty)
        XCTAssertTrue(executionEngine.consumesRiskEngineBoundary)
        XCTAssertTrue(executionEngine.executionClientFutureGateOnly)
    }

    func testGH392TraderTargetPackageDoesNotDependDirectlyOnExecutionEngine() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(contentsOf: repositoryRoot.appendingPathComponent("Package.swift"))
        let traderBoundarySource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/Trader/TargetGraph/TraderTargetBoundary.swift")
        )

        XCTAssertFalse(
            packageSource.contains("dependencies: [\"DomainModel\", \"MessageBus\", \"Cache\", \"TraderStrategies\", \"Portfolio\", \"RiskEngine\", \"ExecutionEngine\"]"),
            "Trader target must not directly depend on ExecutionEngine after GH-392"
        )
        XCTAssertTrue(
            packageSource.contains("dependencies: [\"DomainModel\", \"MessageBus\", \"Cache\", \"TraderStrategies\", \"Portfolio\", \"RiskEngine\"]"),
            "Trader target must keep only account / strategy / portfolio / risk coordination dependencies"
        )
        XCTAssertFalse(
            traderBoundarySource.contains("import ExecutionEngine"),
            "Trader boundary must not import ExecutionEngine after GH-392"
        )
        XCTAssertTrue(
            traderBoundarySource.contains("GH-392-TRADER-NO-DIRECT-EXECUTIONENGINE-DEPENDENCY"),
            "Trader boundary must expose the GH-392 validation anchor"
        )
    }

    func testMTP220ExecutionTargetsRejectBrokerOMSRealOrderAndEndpointDrift() {
        let executionClient = ExecutionClientTargetBoundary.mtp220
        let executionEngine = ExecutionEngineTargetBoundary.mtp220

        XCTAssertTrue(executionClient.futureGateOnly)
        XCTAssertFalse(executionClient.implementsBrokerGateway)
        XCTAssertFalse(executionClient.implementsSignedEndpoint)
        XCTAssertFalse(executionClient.readsAccountEndpointOrListenKey)
        XCTAssertFalse(executionClient.connectsPrivateWebSocketRuntime)
        XCTAssertFalse(executionClient.implementsOrderSubmitCancelReplace)
        XCTAssertFalse(executionClient.parsesExecutionReportOrBrokerFill)
        XCTAssertFalse(executionClient.runsReconciliationRuntime)
        XCTAssertFalse(executionClient.exposesLiveCommandSurface)

        XCTAssertTrue(executionEngine.paperSimulatedLifecycleBoundary)
        XCTAssertFalse(executionEngine.implementsLiveExecutionRuntime)
        XCTAssertFalse(executionEngine.implementsOMS)
        XCTAssertFalse(executionEngine.implementsBrokerGateway)
        XCTAssertFalse(executionEngine.callsSignedOrAccountEndpoint)
        XCTAssertFalse(executionEngine.createsListenKeyOrPrivateWebSocket)
        XCTAssertFalse(executionEngine.implementsRealOrderLifecycle)
        XCTAssertFalse(executionEngine.exposesLiveCommandSurface)
    }

    func testMTP229ExecutionTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(ExecutionClientTargetBoundary.mtp220.compiledBoundaryRoot, "Sources/ExecutionClient/TargetGraph")
        XCTAssertEqual(ExecutionEngineTargetBoundary.mtp220.compiledBoundaryRoot, "Sources/ExecutionEngine/TargetGraph")
        XCTAssertTrue(ExecutionClientTargetBoundary.mtp220.futureGateOnly)
        XCTAssertTrue(ExecutionEngineTargetBoundary.mtp220.executionClientFutureGateOnly)
        XCTAssertFalse(ExecutionClientTargetBoundary.mtp220.implementsOrderSubmitCancelReplace)
        XCTAssertFalse(ExecutionEngineTargetBoundary.mtp220.implementsRealOrderLifecycle)

        for expected in [
            "path: \"Sources/ExecutionClient\"",
            "\"TargetGraph/ExecutionClientTargetBoundary.swift\"",
            "path: \"Sources/ExecutionEngine\"",
            "\"TargetGraph/ExecutionEngineTargetBoundary.swift\"",
            "\"ExecutionClient/TargetGraph\"",
            "\"ExecutionEngine/TargetGraph\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "Package.swift must contain \(expected)")
        }

        for forbidden in [
            "path: \"Sources/TargetGraph/ExecutionClient\"",
            "path: \"Sources/TargetGraph/ExecutionEngine\""
        ] {
            XCTAssertFalse(packageSource.contains(forbidden), "Execution target path must not remain active: \(forbidden)")
        }

        for migratedPath in [
            "Sources/ExecutionClient/TargetGraph/ExecutionClientTargetBoundary.swift",
            "Sources/ExecutionEngine/TargetGraph/ExecutionEngineTargetBoundary.swift"
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(migratedPath).path),
                "\(migratedPath) must exist under the real module root"
            )
        }

        for retiredPath in [
            "Sources/TargetGraph/ExecutionClient/ExecutionClientTargetBoundary.swift",
            "Sources/TargetGraph/ExecutionEngine/ExecutionEngineTargetBoundary.swift"
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(retiredPath).path),
                "\(retiredPath) must no longer be the active execution target boundary file"
            )
        }
    }

    func testMTP221DashboardTargetExposesReadModelOnlyDependencyDirection() {
        let dashboard = DashboardTargetBoundary.mtp221

        XCTAssertTrue(dashboard.dependencyDirectionHeld)

        XCTAssertEqual(dashboard.allowedDependencies, ["Core", "Persistence"])
        XCTAssertTrue(dashboard.displaySurfaceOnly)
        XCTAssertTrue(dashboard.consumesReadModelOnly)
        XCTAssertTrue(dashboard.consumesViewModelOnly)
        XCTAssertTrue(dashboard.validationAnchors.contains("MTP-DASHBOARD-WORKBENCH-TARGET-RETIRED"))
    }

    func testMTP221DashboardTargetRejectsRuntimeAdapterSchemaAndCommandDrift() {
        let dashboard = DashboardTargetBoundary.mtp221

        for forbidden in [
            "Adapters",
            "Runtime",
            "DatabaseSchema",
            "ExecutionClient",
            "ExecutionEngineRuntime",
            "Broker",
            "OMS",
            "SignedEndpoint",
            "AccountEndpoint",
            "ListenKey",
            "PrivateWebSocketRuntime",
            "LiveCommandSurface",
            "OrderForm"
        ] {
            XCTAssertTrue(dashboard.forbiddenDependencies.contains(forbidden))
        }

        XCTAssertFalse(dashboard.exposesRuntimeObject)
        XCTAssertFalse(dashboard.readsAdapterRequest)
        XCTAssertFalse(dashboard.exposesPersistenceSchema)
        XCTAssertFalse(dashboard.exposesAccountPayload)
        XCTAssertFalse(dashboard.exposesBrokerState)
        XCTAssertFalse(dashboard.exposesLivePROConsole)
        XCTAssertFalse(dashboard.providesTradingButton)
        XCTAssertFalse(dashboard.providesLiveCommand)
        XCTAssertFalse(dashboard.exposesOrderForm)
    }

    func testMTP230DashboardTargetUsesRealModuleRootAndRetiresWorkbenchTarget() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let dashboard = DashboardTargetBoundary.mtp230

        XCTAssertTrue(dashboard.dependencyDirectionHeld)
        XCTAssertEqual(dashboard.canonicalSourceRoot, "Sources/Dashboard")
        XCTAssertEqual(dashboard.shellSource, "Sources/Dashboard/DashboardShell.swift")

        for expected in [
            "path: \"Sources/Dashboard\"",
            "\"DashboardApplication.swift\"",
            "\"DashboardTargetBoundary.swift\"",
            "\"DashboardShell.swift\"",
            "\"PaperWorkflowObservability.swift\"",
            "\"PaperWorkflowWorkbenchArchitecture.swift\"",
            "\"WorkbenchBetaAcceptancePath.swift\"",
            "\"WorkbenchBetaFirstRunState.swift\"",
            "\"ReadModels\"",
            "\"Report\"",
            "\"Events\"",
            "\"FutureLiveProConsole\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "Package.swift must contain \(expected)")
        }

        for forbidden in [
            ".library(name: \"Workbench\"",
            "name: \"Workbench\"",
            "path: \"Sources/Workbench\"",
            "path: \"Sources/TargetGraph/Workbench\"",
            "path: \"Sources/TargetGraph/Dashboard\"",
            "\"Dashboard/DashboardShell.swift\""
        ] {
            XCTAssertFalse(packageSource.contains(forbidden), "UI target path must not remain active: \(forbidden)")
        }

        for migratedPath in [
            "Sources/Dashboard/DashboardShell.swift",
            "Sources/Dashboard/ReadModels/App.swift",
            "Sources/Dashboard/Report/LiveTradingBlockedEvidence.swift",
            "Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift",
            "Sources/Dashboard/FutureLiveProConsole/LiveReadOnlyWorkbenchBoundary.swift",
            "Sources/Dashboard/DashboardTargetBoundary.swift",
            "Sources/Dashboard/DashboardApplication.swift"
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(migratedPath).path),
                "\(migratedPath) must exist under its real module root"
            )
        }

        for retiredPath in [
            "Sources/Workbench",
            "Sources/Workbench/TargetGraph/WorkbenchTargetBoundary.swift",
            "Sources/Workbench/Dashboard/DashboardShell.swift",
            "Sources/TargetGraph/Workbench/WorkbenchTargetBoundary.swift",
            "Sources/TargetGraph/Dashboard/DashboardTargetBoundary.swift"
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(retiredPath).path),
                "\(retiredPath) must no longer be an active UI target boundary path"
            )
        }

        XCTAssertTrue(dashboard.validationAnchors.contains("MTP-230-DASHBOARD-REAL-ROOT-TARGET-PATH"))
        XCTAssertFalse(dashboard.exposesRuntimeObject)
        XCTAssertFalse(dashboard.providesLiveCommand)
    }

    func testMTP231TargetGraphActivePathReferencesAreRetiredAndRealRootsRemainCurrent() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let contractSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/targetgraph-anchor-retirement-real-module-source-root-migration-contract.md"
            ),
            encoding: .utf8
        )

        XCTAssertFalse(
            FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent("Sources/TargetGraph").path),
            "Sources/TargetGraph must no longer exist as an active source directory"
        )
        XCTAssertFalse(packageSource.contains("path: \"Sources/TargetGraph"))
        XCTAssertFalse(packageSource.contains("Sources/TargetGraph/"))

        for expectedRoot in [
            "path: \"Sources/DomainModel\"",
            "path: \"Sources/MessageBus\"",
            "path: \"Sources/Database\"",
            "path: \"Sources/DataClient\"",
            "path: \"Sources/Cache\"",
            "path: \"Sources/DataEngine\"",
            "path: \"Sources/Trader/Strategies/EMA\"",
            "path: \"Sources/Trader\"",
            "path: \"Sources/Portfolio\"",
            "path: \"Sources/RiskEngine\"",
            "path: \"Sources/ExecutionClient\"",
            "path: \"Sources/ExecutionEngine\"",
            "path: \"Sources/Dashboard\""
        ] {
            XCTAssertTrue(packageSource.contains(expectedRoot), "Package.swift must keep real module root active: \(expectedRoot)")
        }

        XCTAssertEqual(DomainModelTargetBoundary.mtp217.compiledBoundaryRoot, "Sources/DomainModel/TargetGraph")
        XCTAssertEqual(MessageBusTargetBoundary.mtp217.compiledBoundaryRoot, "Sources/MessageBus/TargetGraph")
        XCTAssertEqual(DatabaseTargetBoundary.mtp217.compiledBoundaryRoot, "Sources/Database/TargetGraph")
        XCTAssertEqual(DataClientTargetBoundary.mtp218.compiledBoundaryRoot, "Sources/DataClient/TargetGraph")
        XCTAssertEqual(CacheTargetBoundary.mtp218.compiledBoundaryRoot, "Sources/Cache/TargetGraph")
        XCTAssertEqual(DataEngineTargetBoundary.mtp218.compiledBoundaryRoot, "Sources/DataEngine/TargetGraph")
        XCTAssertEqual(TraderStrategiesTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Trader/Strategies/EMA/TargetGraph")
        XCTAssertEqual(TraderTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Trader/TargetGraph")
        XCTAssertEqual(PortfolioTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Portfolio/TargetGraph")
        XCTAssertEqual(RiskEngineTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/RiskEngine/TargetGraph")
        XCTAssertEqual(ExecutionClientTargetBoundary.mtp220.compiledBoundaryRoot, "Sources/ExecutionClient/TargetGraph")
        XCTAssertEqual(ExecutionEngineTargetBoundary.mtp220.compiledBoundaryRoot, "Sources/ExecutionEngine/TargetGraph")
        XCTAssertEqual(DashboardTargetBoundary.mtp230.canonicalSourceRoot, "Sources/Dashboard")

        XCTAssertTrue(contractSource.contains("MTP-231-TARGETGRAPH-ACTIVE-PATH-REFERENCE-RETIREMENT"))
        XCTAssertTrue(contractSource.contains("MTP-231-REAL-MODULE-ROOT-ACTIVE-SNAPSHOT"))
        XCTAssertTrue(contractSource.contains("MTP-231-TARGETGRAPH-RETIREMENT-VALIDATION"))
    }

    private func packageTargetBlock(named targetName: String, packageSource: String) throws -> String {
        let targetMarker = ".target(\n            name: \"\(targetName)\""
        guard let markerRange = packageSource.range(of: targetMarker) else {
            throw XCTSkip("Package.swift target \(targetName) not found")
        }
        let tail = packageSource[markerRange.lowerBound...]
        if let nextTarget = tail.range(of: "\n        .target(", options: [], range: tail.index(after: markerRange.lowerBound)..<tail.endIndex) {
            return String(tail[..<nextTarget.lowerBound])
        }
        return String(tail)
    }

    private func packageTargetSourcesBlock(targetBlock: String) throws -> String {
        guard let sourcesRange = targetBlock.range(of: "sources: [") else {
            throw XCTSkip("Package.swift target sources block not found")
        }
        let tail = targetBlock[sourcesRange.lowerBound...]
        guard let closeRange = tail.range(of: "\n            ]") else {
            throw XCTSkip("Package.swift target sources block is not closed")
        }
        return String(tail[..<closeRange.upperBound])
    }
}
