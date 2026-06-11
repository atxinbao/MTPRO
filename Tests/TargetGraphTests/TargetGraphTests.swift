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

    func testGH419DatabasePersistenceRuntimeOwnershipMatrixIsExplicit() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        let databaseTarget = try packageTargetBlock(named: "Database", packageSource: packageSource)
        let persistenceTarget = try packageTargetBlock(named: "Persistence", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)
        let databaseSources = try packageTargetSourcesBlock(targetBlock: databaseTarget)
        let databaseExcludes = try packageTargetExcludesBlock(targetBlock: databaseTarget)
        let persistenceSources = try packageTargetSourcesBlock(targetBlock: persistenceTarget)
        let persistenceExcludes = try packageTargetExcludesBlock(targetBlock: persistenceTarget)
        let runtimeSources = try packageTargetSourcesBlock(targetBlock: runtimeTarget)
        let runtimeExcludes = try packageTargetExcludesBlock(targetBlock: runtimeTarget)

        let matrix = DatabaseRuntimeOwnershipMatrix.gh419
        XCTAssertTrue(matrix.ownershipBoundaryHeld)
        XCTAssertTrue(DatabaseTargetBoundary.mtp217.validationAnchors.contains(
            "GH-419-DATABASE-PERSISTENCE-RUNTIME-OWNERSHIP-MATRIX"
        ))

        XCTAssertTrue(databaseSources.contains("\"DatabaseRuntimeOwnershipMatrix.swift\""))
        XCTAssertTrue(databaseSources.contains("\"FoundationDatabaseCheckpoint.swift\""))
        XCTAssertTrue(databaseSources.contains("\"TargetGraph/DatabaseTargetBoundary.swift\""))
        XCTAssertTrue(databaseExcludes.contains("\"Projections\""))
        XCTAssertTrue(databaseExcludes.contains("\"ReplayProjection\""))

        XCTAssertTrue(persistenceTarget.contains("\"Core\""))
        XCTAssertTrue(persistenceTarget.contains("\"CSQLite\""))
        XCTAssertTrue(persistenceTarget.contains("name: \"DuckDB\""))
        XCTAssertTrue(persistenceExcludes.contains("\"DatabaseRuntimeOwnershipMatrix.swift\""))
        XCTAssertTrue(persistenceSources.contains("\"Projections/SQLite/Persistence.swift\""))
        XCTAssertTrue(persistenceSources.contains("\"Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift\""))
        for forbidden in [
            "\"Runtime\"",
            "\"Dashboard\"",
            "\"Trader\"",
            "\"TraderStrategies\"",
            "\"RiskEngine\"",
            "\"ExecutionEngine\"",
            "\"ExecutionClient\""
        ] {
            XCTAssertFalse(
                persistenceTarget.contains(forbidden),
                "Persistence compatibility envelope must not add higher-layer dependency \(forbidden)"
            )
        }

        XCTAssertTrue(runtimeTarget.contains("dependencies: [\"Core\", \"Adapters\", \"Persistence\"]"))
        XCTAssertTrue(runtimeExcludes.contains("\"Database/DatabaseRuntimeOwnershipMatrix.swift\""))
        XCTAssertTrue(runtimeSources.contains("\"Database/ReplayProjection\""))
        XCTAssertTrue(runtimeSources.contains("\"DataEngine/Ingest\""))
        XCTAssertFalse(runtimeSources.contains("\"Database/Projections\""))
        XCTAssertFalse(runtimeSources.contains("\"DataEngine/ScenarioReplay\""))
        XCTAssertFalse(runtimeSources.contains("\"Dashboard\""))

        XCTAssertFalse(matrix.exposesSchemaToDashboard)
        XCTAssertFalse(matrix.ownsRuntimeObject)
        XCTAssertFalse(matrix.persistsBrokerOrAccountPayload)
        XCTAssertFalse(matrix.implementsTraderRuntime)
        XCTAssertFalse(matrix.implementsStrategyRuntime)
        XCTAssertFalse(matrix.implementsLiveRuntime)
        XCTAssertFalse(matrix.implementsExecutionClient)
        XCTAssertFalse(matrix.implementsOMS)
        XCTAssertFalse(matrix.implementsBrokerGateway)
        XCTAssertFalse(matrix.advancesL4)
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
        let coreSources = try packageTargetSourcesBlock(targetBlock: coreTarget)

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
        XCTAssertTrue(coreTarget.contains("\"DomainModel\""))
        XCTAssertTrue(coreTarget.contains("\"MessageBus\""))
        XCTAssertTrue(coreTarget.contains("\"Cache\""))
        XCTAssertFalse(
            coreSources.contains("\"DomainModel"),
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

    func testGH414MessageBusOwnsNeutralQueryAndReplayContracts() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )

        let messageBusTarget = try packageTargetBlock(named: "MessageBus", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let coreSources = try packageTargetSourcesBlock(targetBlock: coreTarget)

        for expected in [
            "\"MarketDataQuery.swift\"",
            "\"EventReplayContract.swift\""
        ] {
            XCTAssertTrue(messageBusTarget.contains(expected), "MessageBus target must own \(expected)")
        }

        for expected in [
            "\"MessageBus/MarketDataQuery.swift\"",
            "\"MessageBus/EventReplayContract.swift\""
        ] {
            XCTAssertTrue(coreTarget.contains(expected), "Core compatibility envelope must exclude \(expected)")
            XCTAssertFalse(coreSources.contains(expected), "Core must not primary-compile \(expected)")
        }

        let symbol = try Symbol(rawValue: "btcusdt")
        let range = try DateRange(
            start: Date(timeIntervalSince1970: 414),
            end: Date(timeIntervalSince1970: 474)
        )
        let query = MarketDataQuery(symbol: symbol, timeframe: .oneMinute, range: range)
        XCTAssertEqual(query.symbol.rawValue, "BTCUSDT")
        XCTAssertEqual(query.timeframe, .oneMinute)

        let sequenceRange = try EventSequenceRange(lowerBound: 1, upperBound: 3)
        XCTAssertTrue(sequenceRange.contains(2))
        XCTAssertFalse(sequenceRange.contains(4))

        let replay = EventReplayCommand(range: sequenceRange, streams: [.paper])
        XCTAssertTrue(replay.streams.contains(.paper))
        XCTAssertFalse(replay.streams.contains(.market))

        XCTAssertTrue(
            MessageBusTargetBoundary.requiredValidationAnchors.contains(
                "GH-414-MESSAGEBUS-NEUTRAL-QUERY-REPLAY-OWNERSHIP"
            )
        )
        XCTAssertTrue(
            MessageBusTargetBoundary.requiredValidationAnchors.contains(
                "GH-414-CORE-RICH-MESSAGEBUS-COMPATIBILITY-ENVELOPE"
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
        XCTAssertEqual(dataEngine.retainedCompatibilityEnvelope, "Core/Runtime(deterministic matching compatibility, ingest workflow)")
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
        XCTAssertTrue(coreTarget.contains("\"DomainModel\""))
        XCTAssertTrue(coreTarget.contains("\"Cache\""))
        XCTAssertTrue(coreTarget.contains("\"DataClient\""))
        XCTAssertTrue(coreTarget.contains("\"DataEngine/DataEngineReadOnlyReplayPlan.swift\""))
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
        for expected in [
            "\"DataQuality/ScenarioDataQualityReportInput.swift\"",
            "\"ScenarioReplay/DataCatalogScenarioReplayBoundary.swift\"",
            "\"ScenarioReplay/ScenarioFixture.swift\"",
            "\"ScenarioReplay/ScenarioManifest.swift\"",
            "\"ScenarioReplay/ScenarioReplayEvidence.swift\""
        ] {
            XCTAssertTrue(dataEngineSources.contains(expected), "DataEngine target must own \(expected)")
        }

        XCTAssertTrue(adaptersTarget.contains("dependencies: [\"DataClient\"]"))
        XCTAssertTrue(adaptersSources.contains("\"AdaptersCompatibility.swift\""))
        XCTAssertFalse(adaptersSources.contains("Binance/PublicMarketData"))

        XCTAssertTrue(coreTarget.contains("\"DomainModel\""))
        XCTAssertTrue(coreTarget.contains("\"Cache\""))
        XCTAssertTrue(coreTarget.contains("\"DataClient\""))
        XCTAssertTrue(coreTarget.contains("\"DataEngine\""))
        XCTAssertFalse(coreSources.contains("Cache/MarketData"))
        XCTAssertFalse(coreSources.contains("DataClient/Binance"))
        XCTAssertFalse(coreSources.contains("\"DataEngine/ScenarioReplay\""))
        XCTAssertFalse(coreSources.contains("\"DataEngine/DataQuality\""))
        XCTAssertTrue(coreSources.contains("\"DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift\""))
        XCTAssertFalse(runtimeSources.contains("\"DataEngine/ScenarioReplay\""))
        XCTAssertFalse(runtimeSources.contains("\"DataEngine/DataQuality\""))
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
        let scenarioManifest = ScenarioManifest.deterministicFixture
        XCTAssertTrue(scenarioManifest.manifestBoundaryHeld)
        let replayEvidence = ScenarioReplayEvidence.deterministicFixture
        XCTAssertTrue(replayEvidence.evidenceBoundaryHeld)
        let qualityEvaluation = try ScenarioDataQualityGateEvaluation(replayEvidence: replayEvidence)
        XCTAssertTrue(qualityEvaluation.qualityGateBoundaryHeld)
        XCTAssertEqual(qualityEvaluation.qualityVerdict, .accepted)
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
                "GH-415-DATAENGINE-SCENARIO-REPLAY-QUALITY-OWNERSHIP"
            )
        )
        XCTAssertTrue(
            DataEngineTargetBoundary.mtp218.validationAnchors.contains(
                "GH-415-DATAENGINE-DETERMINISTIC-MATCHING-CORE-ENVELOPE-DEFERRED"
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

        XCTAssertEqual(portfolio.retainedCompatibilityEnvelope, "Core(replay / simulated parity bridge deferred)")
        XCTAssertEqual(riskEngine.retainedCompatibilityEnvelope, "Core(event bridge deferred)")
        XCTAssertEqual(strategies.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(trader.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(executionClient.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(executionEngine.retainedCompatibilityEnvelope, "Core(event/replay bridge deferred)")

        XCTAssertTrue(strategies.validationAnchors.contains("GH-397-TRADERSTRATEGIES-EMA-REAL-TARGET-SMOKE"))
        XCTAssertTrue(trader.validationAnchors.contains("GH-397-TRADER-REAL-TARGET-SMOKE"))
        XCTAssertTrue(portfolio.validationAnchors.contains("GH-397-PORTFOLIO-REAL-TARGET-SMOKE"))
        XCTAssertTrue(portfolio.validationAnchors.contains("GH-416-PORTFOLIO-PAPER-PROJECTION-UPDATE-OWNERSHIP"))
        XCTAssertTrue(portfolio.validationAnchors.contains("GH-416-PORTFOLIO-REPLAY-PARITY-BRIDGE-DEFERRED"))
        XCTAssertTrue(riskEngine.validationAnchors.contains("GH-397-RISKENGINE-REAL-TARGET-SMOKE"))
        XCTAssertTrue(riskEngine.validationAnchors.contains("GH-417-RISKENGINE-PAPER-PRETRADE-OWNERSHIP"))
        XCTAssertTrue(riskEngine.validationAnchors.contains("GH-417-CORE-RISKENGINE-EVENT-BRIDGE-ONLY"))
        XCTAssertTrue(riskEngine.validationAnchors.contains("GH-417-RISKENGINE-NO-EXECUTIONCLIENT-OMS-BROKER-GUARD"))
        XCTAssertTrue(executionClient.validationAnchors.contains("GH-397-EXECUTIONCLIENT-FUTURE-GATE-SMOKE"))
        XCTAssertTrue(executionEngine.validationAnchors.contains("GH-397-EXECUTIONENGINE-REAL-TARGET-SMOKE"))
        XCTAssertTrue(executionEngine.validationAnchors.contains("GH-418-EXECUTIONENGINE-PAPER-RUNTIME-KERNEL-OWNERSHIP"))
        XCTAssertTrue(executionEngine.validationAnchors.contains("GH-418-EXECUTIONENGINE-SESSION-CONTROL-OWNERSHIP"))
        XCTAssertTrue(executionEngine.validationAnchors.contains("GH-418-EXECUTIONENGINE-SIMULATED-PARITY-BOUNDARY-OWNERSHIP"))
        XCTAssertTrue(executionEngine.validationAnchors.contains("GH-418-CORE-EXECUTIONENGINE-ORDER-EVENT-REPLAY-BRIDGE-DEFERRED"))

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

    func testGH452L4LiveProductionCommandContractDefinesDisabledProductionMatrix() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)

        let contract = try L4LiveProductionCommandContract.deterministicFixture()
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.acceptanceMatrixCoverageHeld)
        XCTAssertEqual(contract.canonicalQueueRange, "GH-452..GH-472")
        XCTAssertEqual(contract.issueID.rawValue, "GH-452")
        XCTAssertTrue(contract.validationAnchors.contains("GH-452-L4-LIVE-PRODUCTION-COMMAND-CONTRACT"))
        XCTAssertTrue(contract.validationAnchors.contains("TVM-L4-LIVE-PRODUCTION-COMMANDS"))
        XCTAssertEqual(
            Set(contract.acceptanceMatrix.map(\.domain)),
            Set(L4LiveProductionAcceptanceDomain.allCases)
        )

        XCTAssertFalse(contract.productionTradingEnabledByDefault)
        XCTAssertTrue(contract.sandboxGateRequiredBeforeCommand)
        XCTAssertTrue(contract.commandAuthorizationRequired)
        XCTAssertTrue(contract.riskGateRequiredBeforeExecution)
        XCTAssertTrue(contract.omsGateRequiredBeforeExecutionClient)
        XCTAssertTrue(contract.auditTrailRequired)
        XCTAssertTrue(contract.rollbackEvidenceRequired)
        XCTAssertTrue(contract.noDefaultRealTradingPolicyRequired)

        for forbidden in [
            contract.readsCredentialValue,
            contract.printsCredentialValue,
            contract.connectsProductionEndpoint,
            contract.usesSignedEndpoint,
            contract.opensPrivateStream,
            contract.implementsExecutionClientAdapter,
            contract.implementsOMS,
            contract.submitsRealOrder,
            contract.cancelsRealOrder,
            contract.replacesRealOrder,
            contract.consumesExecutionReport,
            contract.recordsBrokerFill,
            contract.performsReconciliation,
            contract.exposesLiveProConsoleCommandSurface,
            contract.exposesOrderForm
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(coreTarget.contains("\"ExecutionClient/FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4LiveProductionCommandContract.swift"
                ).path
            )
        )
    }

    func testGH452L4LiveProductionCommandContractRejectsProductionBypass() throws {
        XCTAssertThrowsError(
            try L4LiveProductionCommandContract(
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionTradingEnabledByDefault")
            )
        }

        XCTAssertThrowsError(
            try L4LiveProductionCommandContract(
                acceptanceMatrix: []
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "acceptanceMatrix",
                    expected: "GH-452 required acceptance matrix",
                    actual: "[]"
                )
            )
        }

        XCTAssertThrowsError(
            try L4LiveProductionCommandContract(
                requiredValidationCommands: ["bash checks/run.sh"]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "requiredValidationCommands",
                    expected: "git diff --check,bash checks/automation-readiness.sh,bash checks/run.sh",
                    actual: "bash checks/run.sh"
                )
            )
        }
    }

    func testGH453L4CredentialEnvironmentGateDefinesSandboxOnlyContract() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let contract = try L4CredentialEnvironmentGateContract.deterministicFixture()
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.validationRulesCoverageHeld)
        XCTAssertEqual(contract.canonicalQueueRange, "GH-452..GH-472")
        XCTAssertEqual(contract.issueID.rawValue, "GH-453")
        XCTAssertEqual(contract.upstreamIssueID.rawValue, "GH-452")
        XCTAssertTrue(contract.validationAnchors.contains("GH-453-L4-CREDENTIAL-ENVIRONMENT-GATE-CONTRACT"))
        XCTAssertTrue(contract.validationAnchors.contains("TVM-L4-CREDENTIAL-ENVIRONMENT-GATE"))
        XCTAssertEqual(
            Set(contract.scopes),
            Set(L4CredentialEnvironmentScope.allCases)
        )
        XCTAssertEqual(
            Set(contract.sourceIdentities),
            Set(L4CredentialSourceIdentity.allCases)
        )

        XCTAssertTrue(contract.credentialSourceIdentityRequired)
        XCTAssertTrue(contract.sandboxOnlyGateRequired)
        XCTAssertTrue(contract.productionDisabledByDefault)
        XCTAssertTrue(contract.productionCutoverRequiresGH471)
        XCTAssertTrue(contract.localValidationMustRejectSecrets)
        XCTAssertTrue(contract.ciValidationMustRejectProductionDefault)
        XCTAssertTrue(contract.networkIndependentValidationRequired)

        for forbidden in [
            contract.allowsPlaintextCredentialInRepository,
            contract.readsCredentialValue,
            contract.printsCredentialValue,
            contract.storesSecret,
            contract.constructsAPIKeyHeader,
            contract.generatesRequestSignature,
            contract.callsSignedEndpoint,
            contract.callsAccountEndpoint,
            contract.createsListenKey,
            contract.opensPrivateStream,
            contract.connectsSandboxNetwork,
            contract.connectsProductionNetwork,
            contract.productionTradingEnabledByDefault,
            contract.productionCutoverAllowedBeforeGH471,
            contract.implementsExecutionClientAdapter,
            contract.implementsOMS,
            contract.submitsRealOrder,
            contract.cancelsRealOrder,
            contract.replacesRealOrder,
            contract.exposesLiveProConsoleCommandSurface,
            contract.exposesOrderForm
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4CredentialEnvironmentGateContract.swift"
                ).path
            )
        )
    }

    func testGH453L4CredentialEnvironmentGateRejectsSecretAndProductionDefault() throws {
        XCTAssertThrowsError(
            try L4CredentialEnvironmentGateContract(
                readsCredentialValue: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("readsCredentialValue")
            )
        }

        XCTAssertThrowsError(
            try L4CredentialEnvironmentGateContract(
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionTradingEnabledByDefault")
            )
        }

        XCTAssertThrowsError(
            try L4CredentialEnvironmentGateContract(
                validationRules: []
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "validationRules",
                    expected: "GH-453 required validation rules",
                    actual: "[]"
                )
            )
        }

        XCTAssertThrowsError(
            try L4CredentialEnvironmentValidationRule(
                environmentVariableName: "MTPRO_L4_UNSAFE_SECRET",
                sourceIdentity: .forbiddenCredentialValue,
                allowedScopes: [.local],
                expectedEvidence: "unsafe rule must be rejected",
                allowsSecretValue: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("allowsSecretValue")
            )
        }
    }

    func testGH454L4SignedEndpointPrivateStreamBoundarySeparatesRuntimeKinds() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let contract = try L4SignedEndpointPrivateStreamBoundaryContract.deterministicFixture()
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.boundaryCoverageHeld)
        XCTAssertEqual(contract.canonicalQueueRange, "GH-452..GH-472")
        XCTAssertEqual(contract.issueID.rawValue, "GH-454")
        XCTAssertEqual(contract.upstreamIssueIDs.map(\.rawValue), ["GH-452", "GH-453"])
        XCTAssertTrue(contract.validationAnchors.contains("GH-454-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY"))
        XCTAssertTrue(contract.validationAnchors.contains("TVM-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY"))
        XCTAssertEqual(
            Set(contract.runtimeKinds),
            Set(L4SignedPrivateRuntimeKind.allCases)
        )
        XCTAssertEqual(
            Set(contract.capabilityTaxonomy),
            Set(L4SignedRequestCapabilityTaxonomy.allCases)
        )
        XCTAssertEqual(
            Set(contract.lifecycleGates),
            Set(L4PrivateStreamLifecycleGate.allCases)
        )
        XCTAssertEqual(
            Set(contract.sourceIdentities),
            Set(L4AccountPrivateEventSourceIdentity.allCases)
        )

        XCTAssertTrue(contract.signedReadOnlyPrivateStreamAndCommandRuntimeAreSeparated)
        XCTAssertTrue(contract.futureImplementationContractRequired)
        XCTAssertTrue(contract.accountSnapshotSourceIdentityRequired)
        XCTAssertTrue(contract.privateEventSourceIdentityRequired)
        XCTAssertTrue(contract.credentialEnvironmentGateRequired)
        XCTAssertTrue(contract.productionDisabledByDefault)

        for forbidden in [
            contract.readsCredentialValue,
            contract.constructsAPIKeyHeader,
            contract.generatesRequestSignature,
            contract.callsSignedEndpoint,
            contract.callsAccountEndpoint,
            contract.createsListenKey,
            contract.keepsListenKeyAlive,
            contract.closesListenKey,
            contract.opensPrivateWebSocket,
            contract.reconnectsPrivateWebSocket,
            contract.readsRealAccountSnapshot,
            contract.consumesRealPrivateEvent,
            contract.implementsCommandRuntime,
            contract.implementsExecutionClientAdapter,
            contract.implementsOMS,
            contract.submitsRealOrder,
            contract.cancelsRealOrder,
            contract.replacesRealOrder,
            contract.productionTradingEnabledByDefault,
            contract.exposesLiveProConsoleCommandSurface,
            contract.exposesOrderForm
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4SignedEndpointPrivateStreamBoundaryContract.swift"
                ).path
            )
        )
    }

    func testGH454L4SignedEndpointPrivateStreamBoundaryRejectsEndpointRuntimeBypass() throws {
        XCTAssertThrowsError(
            try L4SignedEndpointPrivateStreamBoundaryContract(
                callsSignedEndpoint: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("callsSignedEndpoint")
            )
        }

        XCTAssertThrowsError(
            try L4SignedEndpointPrivateStreamBoundaryContract(
                createsListenKey: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("createsListenKey")
            )
        }

        XCTAssertThrowsError(
            try L4SignedEndpointPrivateStreamBoundaryContract(
                implementsCommandRuntime: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsCommandRuntime")
            )
        }

        XCTAssertThrowsError(
            try L4SignedEndpointPrivateStreamBoundaryContract(
                boundaryEntries: []
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "boundaryEntries",
                    expected: "GH-454 required signed/private boundary entries",
                    actual: "[]"
                )
            )
        }
    }

    func testGH455SignedAccountReadOnlyRuntimeDefaultsDisabledAndReturnsCanonicalEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let runtime = try L4SignedAccountReadOnlyRuntime.deterministicFixture()
        XCTAssertTrue(runtime.runtimeBoundaryHeld)
        XCTAssertEqual(runtime.issueID.rawValue, "GH-455")
        XCTAssertEqual(runtime.upstreamIssueIDs.map(\.rawValue), ["GH-453", "GH-454"])
        XCTAssertTrue(runtime.validationAnchors.contains("GH-455-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME"))
        XCTAssertTrue(runtime.validationAnchors.contains("TVM-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME"))
        XCTAssertTrue(runtime.productionDisabledByDefault)
        XCTAssertTrue(runtime.networkIndependentFixtureRuntime)
        XCTAssertTrue(runtime.dashboardReadModelOnlyBoundaryHeld)

        XCTAssertThrowsError(
            try runtime.readAccountEvidence(configuration: .disabled())
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "mode",
                    expected: "local fixture or sandbox configured",
                    actual: "disabled"
                )
            )
        }

        let evidence = try runtime.readAccountEvidence(configuration: .sandboxFixture())
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(
            Set(evidence.records.map(\.component)),
            Set(L4SignedAccountReadOnlyEvidenceComponent.allCases)
        )
        XCTAssertTrue(evidence.records.allSatisfy { $0.rawPayloadExposed == false })
        XCTAssertTrue(evidence.readModelOnly)
        XCTAssertFalse(evidence.rawSignedPayloadExposed)
        XCTAssertFalse(evidence.dashboardRawPayloadExposed)
        XCTAssertFalse(evidence.brokerStateExposed)
        XCTAssertFalse(evidence.productionGateEnabled)
        XCTAssertFalse(evidence.commandRuntimeEnabled)

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4SignedAccountReadOnlyRuntime.swift"
                ).path
            )
        )
    }

    func testGH455SignedAccountReadOnlyRuntimeRejectsProductionSecretAndPayloadBypass() throws {
        XCTAssertThrowsError(
            try L4SignedAccountReadOnlyRuntimeConfiguration(
                mode: .production
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("mode.production"))
        }

        XCTAssertThrowsError(
            try L4SignedAccountReadOnlyRuntimeConfiguration(
                secretMaterialAvailable: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("secretMaterialAvailable")
            )
        }

        XCTAssertThrowsError(
            try L4SignedAccountReadOnlyRuntimeConfiguration(
                rawPayloadExposureAllowed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("rawPayloadExposureAllowed")
            )
        }

        XCTAssertThrowsError(
            try L4SignedAccountReadOnlyRuntimeConfiguration(
                mode: .sandboxConfigured,
                credentialReference: nil,
                sandboxGateEnabled: true,
                fixtureReadEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "credentialReference",
                    expected: "non-empty external credential reference identity",
                    actual: "missing"
                )
            )
        }

        XCTAssertThrowsError(
            try L4SignedAccountReadOnlyEvidence(
                sourceIdentity: "unsafe-gh-455",
                records: [
                    L4SignedAccountReadOnlyEvidenceRecord(
                        component: .account,
                        canonicalValue: "unsafe",
                        sourceIdentity: "unsafe-gh-455"
                    )
                ],
                rawSignedPayloadExposed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("rawSignedPayloadExposed")
            )
        }
    }

    func testGH456PrivateStreamAccountSnapshotReadOnlyRuntimeProducesFreshnessEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let signedRuntime = try L4SignedAccountReadOnlyRuntime.deterministicFixture()
        let signedEvidence = try signedRuntime.readAccountEvidence(configuration: .sandboxFixture())
        let runtime = try L4PrivateStreamAccountSnapshotReadOnlyRuntime.deterministicFixture()
        XCTAssertTrue(runtime.runtimeBoundaryHeld)
        XCTAssertEqual(runtime.issueID.rawValue, "GH-456")
        XCTAssertEqual(runtime.upstreamIssueIDs.map(\.rawValue), ["GH-454", "GH-455"])
        XCTAssertTrue(
            runtime.validationAnchors.contains("GH-456-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME")
        )
        XCTAssertTrue(runtime.validationAnchors.contains("TVM-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME"))
        XCTAssertTrue(runtime.productionDisabledByDefault)
        XCTAssertTrue(runtime.fixtureStreamOnly)
        XCTAssertTrue(runtime.dashboardReadModelOnlyBoundaryHeld)

        XCTAssertThrowsError(
            try runtime.readPrivateStreamAccountSnapshotEvidence(
                configuration: .disabled(),
                signedAccountEvidence: signedEvidence
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "mode",
                    expected: "local fixture or sandbox configured",
                    actual: "disabled"
                )
            )
        }

        let evidence = try runtime.readPrivateStreamAccountSnapshotEvidence(
            configuration: .sandboxFixture(),
            signedAccountEvidence: signedEvidence
        )
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-456")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-454", "GH-455"])
        XCTAssertEqual(evidence.signedAccountEvidenceID.rawValue, "gh-455-signed-account-read-only-evidence")
        XCTAssertEqual(
            Set(evidence.records.map(\.freshnessStatus)),
            Set(L4PrivateStreamFreshnessStatus.allCases)
        )
        XCTAssertEqual(
            Set(evidence.records.map(\.sourceKind)),
            Set(L4PrivateStreamSourceIdentity.allCases)
        )
        XCTAssertTrue(evidence.records.contains { $0.eventKind == .accountSnapshot })
        XCTAssertTrue(evidence.records.contains { $0.eventKind == .disconnectEvidence })
        XCTAssertTrue(evidence.records.allSatisfy { $0.rawPrivatePayloadExposed == false })
        XCTAssertTrue(evidence.records.allSatisfy { $0.commandSurfaceEnabled == false })
        XCTAssertTrue(evidence.readModelOnly)
        XCTAssertTrue(evidence.dashboardReadModelOnly)
        XCTAssertFalse(evidence.listenKeyValueExposed)
        XCTAssertFalse(evidence.privateWebSocketOpened)
        XCTAssertFalse(evidence.rawBrokerPayloadExposed)
        XCTAssertFalse(evidence.rawPrivatePayloadExposed)
        XCTAssertFalse(evidence.commandSurfaceEnabled)
        XCTAssertFalse(evidence.productionGateEnabled)

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4PrivateStreamAccountSnapshotReadOnlyRuntime.swift"
                ).path
            )
        )
    }

    func testGH456PrivateStreamAccountSnapshotReadOnlyRuntimeRejectsListenKeyPayloadAndCommandBypass() throws {
        XCTAssertThrowsError(
            try L4PrivateStreamReadOnlyRuntimeConfiguration(
                mode: .production
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("mode.production"))
        }

        XCTAssertThrowsError(
            try L4PrivateStreamReadOnlyRuntimeConfiguration(
                listenKeyLifecycleAllowed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("listenKeyLifecycleAllowed")
            )
        }

        XCTAssertThrowsError(
            try L4PrivateStreamReadOnlyRuntimeConfiguration(
                privateWebSocketAllowed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("privateWebSocketAllowed")
            )
        }

        XCTAssertThrowsError(
            try L4PrivateStreamReadOnlyRuntimeConfiguration(
                rawPayloadExposureAllowed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("rawPayloadExposureAllowed")
            )
        }

        XCTAssertThrowsError(
            try L4PrivateStreamReadOnlyRuntimeConfiguration(
                commandRuntimeAllowed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("commandRuntimeAllowed")
            )
        }

        XCTAssertThrowsError(
            try L4PrivateStreamReadOnlyRuntimeConfiguration(
                mode: .sandboxConfigured,
                credentialReference: nil,
                sandboxGateEnabled: true,
                fixtureStreamEnabled: true,
                accountSnapshotMappingEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "credentialReference",
                    expected: "non-empty external credential reference identity",
                    actual: "missing"
                )
            )
        }

        XCTAssertThrowsError(
            try L4PrivateStreamAccountSnapshotReadModelRecord(
                eventKind: .accountSnapshot,
                sourceKind: .signedAccountSnapshot,
                freshnessStatus: .fresh,
                canonicalReadModelValue: "unsafe raw payload",
                sourceIdentity: "unsafe-gh-456",
                rawPrivatePayloadExposed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("rawPrivatePayloadExposed")
            )
        }

        XCTAssertThrowsError(
            try L4PrivateStreamAccountSnapshotReadOnlyEvidence(
                signedAccountEvidenceID: Identifier.constant("gh-455-signed-account-read-only-evidence"),
                sourceIdentity: "unsafe-gh-456",
                records: [
                    L4PrivateStreamAccountSnapshotReadModelRecord(
                        eventKind: .accountSnapshot,
                        sourceKind: .signedAccountSnapshot,
                        freshnessStatus: .fresh,
                        canonicalReadModelValue: "unsafe",
                        sourceIdentity: "unsafe-gh-456"
                    )
                ],
                rawBrokerPayloadExposed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("rawBrokerPayloadExposed")
            )
        }
    }

    func testGH457LiveAccountReadModelMappingMapsAPBMarginEvidenceReadOnly() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let signedRuntime = try L4SignedAccountReadOnlyRuntime.deterministicFixture()
        let signedEvidence = try signedRuntime.readAccountEvidence(configuration: .sandboxFixture())
        let privateStreamRuntime = try L4PrivateStreamAccountSnapshotReadOnlyRuntime.deterministicFixture()
        let privateStreamEvidence = try privateStreamRuntime.readPrivateStreamAccountSnapshotEvidence(
            configuration: .sandboxFixture(),
            signedAccountEvidence: signedEvidence
        )
        let mapper = try L4LiveAccountReadModelMapping.deterministicFixture()
        XCTAssertTrue(mapper.mappingContractHeld)
        XCTAssertEqual(mapper.issueID.rawValue, "GH-457")
        XCTAssertEqual(mapper.upstreamIssueIDs.map(\.rawValue), ["GH-455", "GH-456"])
        XCTAssertTrue(mapper.validationAnchors.contains("GH-457-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING"))
        XCTAssertTrue(mapper.validationAnchors.contains("TVM-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING"))
        XCTAssertTrue(mapper.dashboardReadModelOnlyBoundaryHeld)
        XCTAssertTrue(mapper.fixtureSandboxAndRealAccountSeparated)
        XCTAssertFalse(mapper.realPnLRuntimeEnabled)

        let readModel = try mapper.mapReadModel(
            signedAccountEvidence: signedEvidence,
            privateStreamEvidence: privateStreamEvidence
        )
        XCTAssertTrue(readModel.mappingBoundaryHeld)
        XCTAssertEqual(readModel.issueID.rawValue, "GH-457")
        XCTAssertEqual(readModel.signedAccountEvidenceID.rawValue, "gh-455-signed-account-read-only-evidence")
        XCTAssertEqual(
            readModel.privateStreamEvidenceID.rawValue,
            "gh-456-private-stream-account-snapshot-read-only-evidence"
        )
        XCTAssertEqual(
            Set(readModel.records.map(\.component)),
            Set(L4LiveAccountReadModelComponent.allCases)
        )
        XCTAssertEqual(
            Set(readModel.freshnessStatuses),
            Set(L4PrivateStreamFreshnessStatus.allCases)
        )
        XCTAssertTrue(readModel.records.allSatisfy { $0.interpretationMode == .sandboxFixture })
        XCTAssertTrue(readModel.records.allSatisfy { $0.sourceKinds.contains(.signedAccountEvidence) })
        XCTAssertTrue(readModel.records.allSatisfy { $0.sourceKinds.contains(.privateStreamEvidence) })
        XCTAssertTrue(readModel.records.allSatisfy { $0.sourceKinds.contains(.sandboxFixtureEvidence) })
        XCTAssertTrue(readModel.records.allSatisfy { $0.sourceKinds.contains(.liveReadOnlyExplanation) })
        XCTAssertTrue(readModel.records.allSatisfy { $0.freshnessStatus == .fresh })
        XCTAssertTrue(readModel.dashboardReadModelOnly)
        XCTAssertTrue(readModel.fixtureSandboxAndRealAccountSeparated)
        XCTAssertFalse(readModel.rawAccountPayloadExposed)
        XCTAssertFalse(readModel.brokerStateExposed)
        XCTAssertFalse(readModel.runtimeObjectExposed)
        XCTAssertFalse(readModel.adapterRequestExposed)
        XCTAssertFalse(readModel.schemaExposed)
        XCTAssertFalse(readModel.realPnLRuntimeEnabled)
        XCTAssertFalse(readModel.commandSurfaceEnabled)
        XCTAssertFalse(readModel.productionGateEnabled)

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4LiveAccountReadModelMapping.swift"
                ).path
            )
        )
    }

    func testGH457LiveAccountReadModelMappingRejectsRawPayloadBrokerStateAndRuntimeBypass() throws {
        XCTAssertThrowsError(
            try L4LiveAccountReadModelMapping(
                forbiddenCapabilities: []
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "forbiddenCapabilities",
                    expected: L4LiveAccountReadModelForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                    actual: ""
                )
            )
        }

        XCTAssertThrowsError(
            try L4LiveAccountReadModelMapping(
                realPnLRuntimeEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("realPnLRuntimeEnabled")
            )
        }

        XCTAssertThrowsError(
            try L4LiveAccountReadModelRecord(
                component: .account,
                sourceKinds: [.signedAccountEvidence],
                interpretationMode: .sandboxFixture,
                freshnessStatus: .fresh,
                canonicalReadModelValue: "unsafe raw account payload",
                evidenceIdentity: Identifier.constant("unsafe-gh-457"),
                sourceIdentity: "unsafe-gh-457",
                rawAccountPayloadExposed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("rawAccountPayloadExposed")
            )
        }

        let signedRuntime = try L4SignedAccountReadOnlyRuntime.deterministicFixture()
        let signedEvidence = try signedRuntime.readAccountEvidence(configuration: .sandboxFixture())
        let privateStreamRuntime = try L4PrivateStreamAccountSnapshotReadOnlyRuntime.deterministicFixture()
        let privateStreamEvidence = try privateStreamRuntime.readPrivateStreamAccountSnapshotEvidence(
            configuration: .sandboxFixture(),
            signedAccountEvidence: signedEvidence
        )
        let readModel = try L4LiveAccountReadModelMapping.deterministicFixture().mapReadModel(
            signedAccountEvidence: signedEvidence,
            privateStreamEvidence: privateStreamEvidence
        )

        XCTAssertThrowsError(
            try L4LiveAccountReadModel(
                signedAccountEvidenceID: readModel.signedAccountEvidenceID,
                privateStreamEvidenceID: readModel.privateStreamEvidenceID,
                records: readModel.records,
                freshnessStatuses: readModel.freshnessStatuses,
                brokerStateExposed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("brokerStateExposed"))
        }

        XCTAssertThrowsError(
            try L4LiveAccountReadModel(
                signedAccountEvidenceID: readModel.signedAccountEvidenceID,
                privateStreamEvidenceID: readModel.privateStreamEvidenceID,
                records: readModel.records,
                freshnessStatuses: readModel.freshnessStatuses,
                runtimeObjectExposed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runtimeObjectExposed"))
        }

        XCTAssertThrowsError(
            try L4LiveAccountReadModel(
                signedAccountEvidenceID: readModel.signedAccountEvidenceID,
                privateStreamEvidenceID: readModel.privateStreamEvidenceID,
                records: readModel.records,
                freshnessStatuses: readModel.freshnessStatuses,
                adapterRequestExposed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("adapterRequestExposed"))
        }

        XCTAssertThrowsError(
            try L4LiveAccountReadModel(
                signedAccountEvidenceID: readModel.signedAccountEvidenceID,
                privateStreamEvidenceID: readModel.privateStreamEvidenceID,
                records: readModel.records,
                freshnessStatuses: readModel.freshnessStatuses,
                schemaExposed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("schemaExposed"))
        }
    }

    func testGH458ExecutionClientVenueAdapterContractDefinesEngineClientBoundary() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        let traderTarget = try packageTargetBlock(named: "Trader", packageSource: packageSource)
        let traderStrategiesTarget = try packageTargetBlock(named: "TraderStrategies", packageSource: packageSource)

        let contract = try L4ExecutionClientVenueAdapterContract.deterministicFixture()
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.operationCoverageHeld)
        XCTAssertEqual(contract.issueID.rawValue, "GH-458")
        XCTAssertEqual(contract.upstreamIssueIDs.map(\.rawValue), ["GH-452", "GH-457"])
        XCTAssertTrue(contract.executionClientIsExternalVenueAdapter)
        XCTAssertTrue(contract.executionEngineIsInternalLifecycleCoordinator)
        XCTAssertFalse(contract.traderStrategyDirectAccessAllowed)
        XCTAssertTrue(contract.sandboxVenueGateRequired)
        XCTAssertTrue(contract.productionVenueGateRequired)
        XCTAssertFalse(contract.productionVenueEnabled)
        XCTAssertFalse(contract.implementsBrokerGateway)
        XCTAssertFalse(contract.implementsSandboxSubmitCancelReplace)
        XCTAssertFalse(contract.implementsRealSubmitCancelReplace)
        XCTAssertFalse(contract.implementsExecutionReportParser)
        XCTAssertFalse(contract.implementsBrokerFillParser)
        XCTAssertFalse(contract.implementsOMS)
        XCTAssertFalse(contract.exposesLiveProConsoleCommandSurface)
        XCTAssertTrue(contract.validationAnchors.contains("GH-458-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT"))
        XCTAssertTrue(contract.validationAnchors.contains("GH-458-EXECUTIONENGINE-INTERNAL-LIFECYCLE-BOUNDARY"))
        XCTAssertTrue(contract.validationAnchors.contains("GH-458-SANDBOX-PRODUCTION-VENUE-GATE"))
        XCTAssertTrue(contract.validationAnchors.contains("GH-458-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT"))
        XCTAssertEqual(
            Set(contract.operationContracts.map(\.operation)),
            Set(L4ExecutionClientVenueAdapterOperation.allCases)
        )
        XCTAssertTrue(contract.operationContracts.allSatisfy { $0.requiresExecutionEngineHandoff })
        XCTAssertTrue(contract.operationContracts.allSatisfy { $0.sandboxGateRequired })
        XCTAssertTrue(contract.operationContracts.allSatisfy { $0.productionGateRequired })
        XCTAssertTrue(contract.operationContracts.allSatisfy { $0.implementsRuntime == false })

        XCTAssertTrue(ExecutionClientTargetBoundary.mtp220.futureGateOnly)
        XCTAssertTrue(ExecutionEngineTargetBoundary.mtp220.executionClientFutureGateOnly)
        XCTAssertFalse(ExecutionClientTargetBoundary.mtp220.implementsOrderSubmitCancelReplace)
        XCTAssertFalse(ExecutionEngineTargetBoundary.mtp220.implementsRealOrderLifecycle)
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(executionEngineTarget.contains("\"ExecutionClient\""))
        XCTAssertFalse(traderTarget.contains("\"ExecutionClient\""))
        XCTAssertFalse(traderStrategiesTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4ExecutionClientVenueAdapterContract.swift"
                ).path
            )
        )
    }

    func testGH458ExecutionClientVenueAdapterContractRejectsDirectAccessAndRuntimeBypass() throws {
        XCTAssertThrowsError(
            try L4ExecutionClientVenueOperationContract(
                operation: .submit,
                executionClientResponsibility: "",
                executionEngineResponsibility: "unsafe"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "executionClientResponsibility",
                    expected: "non-empty ExecutionClient venue adapter responsibility",
                    actual: "empty"
                )
            )
        }

        XCTAssertThrowsError(
            try L4ExecutionClientVenueOperationContract(
                operation: .submit,
                executionClientResponsibility: "unsafe",
                executionEngineResponsibility: "unsafe",
                implementsRuntime: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("implementsRuntime"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientVenueAdapterContract(
                operationContracts: []
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "operationContracts",
                    expected: L4ExecutionClientVenueAdapterOperation.allCases.map(\.rawValue).joined(separator: ","),
                    actual: ""
                )
            )
        }

        XCTAssertThrowsError(
            try L4ExecutionClientVenueAdapterContract(
                traderStrategyDirectAccessAllowed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("traderStrategyDirectAccessAllowed")
            )
        }

        XCTAssertThrowsError(
            try L4ExecutionClientVenueAdapterContract(
                productionVenueEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionVenueEnabled"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientVenueAdapterContract(
                implementsSandboxSubmitCancelReplace: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsSandboxSubmitCancelReplace")
            )
        }

        XCTAssertThrowsError(
            try L4ExecutionClientVenueAdapterContract(
                implementsExecutionReportParser: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsExecutionReportParser")
            )
        }
    }

    func testGH459ExecutionClientSandboxVenueAdapterProducesDeterministicCommandEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let adapter = try L4ExecutionClientSandboxVenueAdapter.deterministicFixture()
        XCTAssertTrue(adapter.sandboxAdapterBoundaryHeld)
        XCTAssertEqual(adapter.issueID.rawValue, "GH-459")
        XCTAssertEqual(adapter.upstreamIssueID.rawValue, "GH-458")
        XCTAssertTrue(adapter.contract.contractHeld)
        XCTAssertEqual(adapter.venueMode, .sandbox)
        XCTAssertFalse(adapter.productionVenueEnabled)
        XCTAssertFalse(adapter.readsSecret)
        XCTAssertFalse(adapter.generatesSignedRequest)
        XCTAssertFalse(adapter.touchesBrokerGateway)
        XCTAssertFalse(adapter.touchesOMS)
        XCTAssertFalse(adapter.touchesLiveCommandSurface)
        XCTAssertTrue(adapter.validationAnchors.contains("GH-459-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE"))
        XCTAssertTrue(adapter.validationAnchors.contains("GH-459-SANDBOX-REQUEST-ENVELOPE"))
        XCTAssertTrue(adapter.validationAnchors.contains("GH-459-DETERMINISTIC-COMMAND-EVIDENCE"))
        XCTAssertTrue(adapter.validationAnchors.contains("GH-459-PRODUCTION-VENUE-DISABLED"))

        let submitEnvelope = try gh497SandboxEnvelope(kind: .submit)
        let cancelEnvelope = try gh497SandboxEnvelope(kind: .cancel)
        let replaceEnvelope = try gh497SandboxEnvelope(kind: .replace)
        let submitResponse = try adapter.submit(submitEnvelope)
        let cancelResponse = try adapter.cancel(cancelEnvelope)
        let replaceResponse = try adapter.replace(replaceEnvelope)

        XCTAssertEqual(submitResponse.commandKind, .submit)
        XCTAssertEqual(cancelResponse.commandKind, .cancel)
        XCTAssertEqual(replaceResponse.commandKind, .replace)
        XCTAssertTrue([submitResponse, cancelResponse, replaceResponse].allSatisfy(\.acceptedBySandbox))
        XCTAssertTrue([submitResponse, cancelResponse, replaceResponse].allSatisfy { $0.venueMode == .sandbox })
        XCTAssertTrue([submitResponse, cancelResponse, replaceResponse].allSatisfy { $0.productionVenueTouched == false })
        XCTAssertTrue([submitResponse, cancelResponse, replaceResponse].allSatisfy { $0.brokerGatewayTouched == false })
        XCTAssertTrue([submitResponse, cancelResponse, replaceResponse].allSatisfy { $0.realOrderLifecycleTouched == false })

        let evidence = try adapter.deterministicCommandEvidence()
        XCTAssertTrue(evidence.commandEvidenceHeld)
        XCTAssertEqual(Set(evidence.requestEnvelopes.map(\.commandKind)), Set(L4ExecutionClientSandboxCommandKind.allCases))
        XCTAssertEqual(Set(evidence.responses.map(\.commandKind)), Set(L4ExecutionClientSandboxCommandKind.allCases))
        XCTAssertTrue(evidence.requestResponseEvidenceAuditable)
        XCTAssertTrue(evidence.productionVenueDisabled)
        XCTAssertFalse(evidence.signedEndpointTouched)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.realOrderLifecycleTouched)
        XCTAssertFalse(evidence.omsTouched)
        XCTAssertFalse(evidence.liveCommandSurfaceTouched)

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxVenueAdapter.swift"
                ).path
            )
        )
    }

    func testGH459ExecutionClientSandboxVenueAdapterRejectsProductionAndBrokerBypass() throws {
        XCTAssertThrowsError(
            try L4ExecutionClientSandboxVenueAdapter(
                venueMode: .production
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("venueMode.production"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientSandboxVenueAdapter(
                generatesSignedRequest: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("generatesSignedRequest"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientSandboxVenueAdapter(
                touchesBrokerGateway: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("touchesBrokerGateway"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientSandboxRequestEnvelope(
                envelopeID: Identifier.constant("unsafe-gh-459-production-envelope"),
                commandKind: .submit,
                venueMode: .production,
                clientOrderID: Identifier.constant("unsafe-gh-459-order"),
                symbol: "BTCUSDT",
                quantity: "0.0100",
                limitPrice: "42120.70",
                reason: "unsafe production route"
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("venueMode.production"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientSandboxRequestEnvelope(
                envelopeID: Identifier.constant("unsafe-gh-459-signed-envelope"),
                commandKind: .submit,
                clientOrderID: Identifier.constant("unsafe-gh-459-order"),
                symbol: "BTCUSDT",
                quantity: "0.0100",
                limitPrice: "42120.70",
                reason: "unsafe signed request route",
                signedRequestGenerated: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("signedRequestGenerated"))
        }

        let adapter = try L4ExecutionClientSandboxVenueAdapter.deterministicFixture()
        let cancelEnvelope = try gh497SandboxEnvelope(kind: .cancel)
        XCTAssertThrowsError(
            try adapter.submit(cancelEnvelope)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "commandKind",
                    expected: "submit",
                    actual: "cancel"
                )
            )
        }

        let submitEnvelope = try gh497SandboxEnvelope(kind: .submit)
        let submitResponse = try adapter.submit(submitEnvelope)
        XCTAssertThrowsError(
            try L4ExecutionClientSandboxCommandEvidence(
                requestEnvelopes: [submitEnvelope],
                responses: [submitResponse]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "requestEnvelopes",
                    expected: L4ExecutionClientSandboxCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                    actual: "submit"
                )
            )
        }
    }

    func testGH460ExecutionClientSandboxReportParserProducesReplayableAuditEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let parser = try L4ExecutionClientSandboxReportParser.deterministicFixture()
        XCTAssertTrue(parser.parserBoundaryHeld)
        XCTAssertEqual(parser.issueID.rawValue, "GH-460")
        XCTAssertEqual(parser.upstreamIssueID.rawValue, "GH-459")
        XCTAssertTrue(parser.commandEvidence.commandEvidenceHeld)
        XCTAssertEqual(parser.venueMode, .sandbox)
        XCTAssertFalse(parser.productionParserEnabled)
        XCTAssertFalse(parser.interpretsProductionRawPayload)
        XCTAssertFalse(parser.exposesRawPayloadToDashboard)
        XCTAssertFalse(parser.touchesBrokerGateway)
        XCTAssertFalse(parser.recordsRealBrokerFill)
        XCTAssertFalse(parser.producesOMSStateTransition)
        XCTAssertFalse(parser.producesReconciliation)
        XCTAssertFalse(parser.touchesLiveCommandSurface)
        XCTAssertTrue(parser.validationAnchors.contains("GH-460-EXECUTION-REPORT-BROKER-FILL-PARSER"))
        XCTAssertTrue(parser.validationAnchors.contains("GH-460-SANDBOX-REPORT-KIND-COVERAGE"))
        XCTAssertTrue(parser.validationAnchors.contains("GH-460-REPLAYABLE-AUDIT-EVIDENCE"))
        XCTAssertTrue(parser.validationAnchors.contains("GH-460-RAW-PAYLOAD-DASHBOARD-BLOCK"))
        XCTAssertTrue(parser.validationAnchors.contains("GH-460-PRODUCTION-PARSER-DISABLED"))

        let fixtures = try gh497SandboxReportFixtures()
        XCTAssertEqual(fixtures.map(\.reportKind), [.fill, .partialFill, .reject, .cancelAcknowledgement])
        XCTAssertEqual(fixtures.map(\.replaySequence), [1, 2, 3, 4])
        XCTAssertTrue(fixtures.allSatisfy { $0.sourceKind == .sandboxFixture })
        XCTAssertTrue(fixtures.allSatisfy { $0.venueMode == .sandbox })
        XCTAssertTrue(fixtures.allSatisfy { $0.productionRawPayloadPresent == false })
        XCTAssertTrue(fixtures.allSatisfy { $0.rawPayloadExposedToDashboard == false })
        XCTAssertTrue(fixtures.allSatisfy { $0.brokerGatewayTouched == false })

        let parsedEvents = try fixtures.map(parser.parse)
        XCTAssertTrue(parsedEvents.allSatisfy(\.parsedEventBoundaryHeld))
        XCTAssertEqual(Set(parsedEvents.map(\.reportKind)), Set(L4ExecutionClientSandboxReportKind.allCases))
        XCTAssertEqual(parsedEvents.map(\.eventStatus), [
            "filled by deterministic sandbox report",
            "partially filled by deterministic sandbox report",
            "rejected by deterministic sandbox report",
            "cancel acknowledged by deterministic sandbox report"
        ])
        XCTAssertTrue(parsedEvents.allSatisfy(\.replayable))
        XCTAssertTrue(parsedEvents.allSatisfy(\.auditEvidenceAttached))
        XCTAssertTrue(parsedEvents.allSatisfy(\.dashboardReadModelSafe))
        XCTAssertTrue(parsedEvents.allSatisfy { $0.rawPayloadRetainedForDashboard == false })
        XCTAssertTrue(parsedEvents.allSatisfy { $0.productionPayloadInterpreted == false })
        XCTAssertTrue(parsedEvents.allSatisfy { $0.brokerFillFactRecorded == false })
        XCTAssertTrue(parsedEvents.allSatisfy { $0.omsStateTransitionProduced == false })
        XCTAssertTrue(parsedEvents.allSatisfy { $0.reconciliationProduced == false })

        let evidence = try parser.deterministicReplayEvidence()
        XCTAssertTrue(evidence.reportParserEvidenceHeld)
        XCTAssertEqual(Set(evidence.parsedEvents.map(\.reportKind)), Set(L4ExecutionClientSandboxReportKind.allCases))
        XCTAssertEqual(evidence.parsedEvents.map(\.replaySequence), [1, 2, 3, 4])
        XCTAssertTrue(evidence.reportParserReplayable)
        XCTAssertTrue(evidence.eventAuditEvidenceAttached)
        XCTAssertTrue(evidence.rawPayloadExcludedFromDashboard)
        XCTAssertTrue(evidence.productionParserDisabled)
        XCTAssertFalse(evidence.productionPayloadInterpreted)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.realBrokerFillRecorded)
        XCTAssertFalse(evidence.omsStateTransitionProduced)
        XCTAssertFalse(evidence.reconciliationProduced)
        XCTAssertFalse(evidence.liveCommandSurfaceTouched)

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxReportParser.swift"
                ).path
            )
        )
    }

    func testGH460ExecutionClientSandboxReportParserRejectsProductionRawPayloadAndDashboardBypass() throws {
        XCTAssertThrowsError(
            try L4ExecutionClientSandboxReportParser(
                productionParserEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionParserEnabled"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientSandboxReportParser(
                interpretsProductionRawPayload: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("interpretsProductionRawPayload"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientSandboxReportParser(
                exposesRawPayloadToDashboard: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesRawPayloadToDashboard"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientSandboxReportFixture(
                reportID: Identifier.constant("unsafe-gh-460-production-report"),
                sourceKind: .productionRawPayload,
                reportKind: .fill,
                relatedCommandKind: .submit,
                clientOrderID: Identifier.constant("unsafe-gh-460-order"),
                symbol: "BTCUSDT",
                filledQuantity: "0.0100",
                remainingQuantity: "0.0000",
                reportStatus: L4ExecutionClientSandboxReportFixture.expectedStatus(for: .fill),
                replaySequence: 1,
                sandboxTraceID: Identifier.constant("unsafe-gh-460-trace"),
                rawPayloadDigest: "sha256:unsafe-production-payload"
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("sourceKind.productionRawPayload"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientSandboxReportFixture(
                reportID: Identifier.constant("unsafe-gh-460-dashboard-raw-report"),
                reportKind: .fill,
                relatedCommandKind: .submit,
                clientOrderID: Identifier.constant("unsafe-gh-460-order"),
                symbol: "BTCUSDT",
                filledQuantity: "0.0100",
                remainingQuantity: "0.0000",
                reportStatus: L4ExecutionClientSandboxReportFixture.expectedStatus(for: .fill),
                replaySequence: 1,
                sandboxTraceID: Identifier.constant("unsafe-gh-460-trace"),
                rawPayloadDigest: "sha256:unsafe-dashboard-payload",
                rawPayloadExposedToDashboard: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("rawPayloadExposedToDashboard"))
        }

        XCTAssertThrowsError(
            try L4ExecutionClientSandboxParsedReportEvent(
                eventID: Identifier.constant("unsafe-gh-460-oms-event"),
                reportID: Identifier.constant("unsafe-gh-460-report"),
                reportKind: .fill,
                relatedCommandKind: .submit,
                replaySequence: 1,
                eventStatus: L4ExecutionClientSandboxReportFixture.expectedStatus(for: .fill),
                clientOrderID: Identifier.constant("unsafe-gh-460-order"),
                symbol: "BTCUSDT",
                filledQuantity: "0.0100",
                remainingQuantity: "0.0000",
                rawPayloadDigest: "sha256:unsafe-oms-payload",
                omsStateTransitionProduced: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("omsStateTransitionProduced"))
        }

        let parser = try L4ExecutionClientSandboxReportParser.deterministicFixture()
        let firstEvent = try parser.parse(gh497SandboxReportFixtures()[0])
        XCTAssertThrowsError(
            try L4ExecutionClientSandboxReportReplayEvidence(parsedEvents: [firstEvent])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "parsedEvents",
                    expected: L4ExecutionClientSandboxReportKind.allCases.map(\.rawValue).joined(separator: ","),
                    actual: "fill"
                )
            )
        }

        let allEvents = try gh497SandboxReportFixtures().map(parser.parse)
        XCTAssertThrowsError(
            try L4ExecutionClientSandboxReportReplayEvidence(
                parsedEvents: allEvents,
                productionParserDisabled: false
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionParserDisabled"))
        }
    }

    func testGH461OMSOrderLifecycleContractDefinesStateMachineAndBoundaries() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)

        let contract = try L4OMSOrderLifecycleContract.deterministicFixture()
        XCTAssertTrue(contract.contractHeld)
        XCTAssertEqual(contract.issueID.rawValue, "GH-461")
        XCTAssertEqual(contract.upstreamIssueIDs.map(\.rawValue), ["GH-458", "GH-460"])
        XCTAssertTrue(contract.parserEvidence.reportParserEvidenceHeld)
        XCTAssertEqual(contract.states, L4OMSOrderLifecycleState.allCases)
        XCTAssertEqual(contract.transitionRules.count, 8)
        XCTAssertEqual(contract.illegalTransitionEvidence.count, 3)
        XCTAssertTrue(contract.rollbackIncidentEvidence.boundaryHeld)
        XCTAssertTrue(contract.executionEngineOwnsLocalLifecycleCoordination)
        XCTAssertTrue(contract.executionClientOnlyProvidesSandboxReportEvidence)
        XCTAssertTrue(contract.portfolioConsumesProjectionOnly)
        XCTAssertTrue(contract.riskEnginePreTradeBoundaryRequired)
        XCTAssertFalse(contract.implementsProductionOrderManager)
        XCTAssertFalse(contract.submitsRealOrder)
        XCTAssertFalse(contract.consumesProductionBrokerReport)
        XCTAssertFalse(contract.bypassesRiskEngine)
        XCTAssertFalse(contract.touchesBrokerGateway)
        XCTAssertFalse(contract.mutatesPortfolio)
        XCTAssertFalse(contract.performsReconciliation)
        XCTAssertFalse(contract.exposesLiveCommandSurface)

        XCTAssertTrue(contract.isAllowedTransition(from: .accepted, trigger: .sandboxSubmitAccepted, to: .submitted))
        XCTAssertTrue(contract.isAllowedTransition(from: .submitted, trigger: .sandboxPartialFillReport, to: .partiallyFilled))
        XCTAssertTrue(contract.isAllowedTransition(from: .partiallyFilled, trigger: .sandboxFillReport, to: .filled))
        XCTAssertTrue(contract.isAllowedTransition(from: .submitted, trigger: .sandboxCancelAcknowledgement, to: .cancelled))
        XCTAssertTrue(contract.isAllowedTransition(from: .submitted, trigger: .sandboxRejectReport, to: .rejected))
        XCTAssertFalse(contract.isAllowedTransition(from: .filled, trigger: .sandboxSubmitAccepted, to: .submitted))
        XCTAssertFalse(contract.isAllowedTransition(from: .cancelled, trigger: .sandboxPartialFillReport, to: .partiallyFilled))
        XCTAssertFalse(contract.isAllowedTransition(from: .rejected, trigger: .sandboxFillReport, to: .filled))

        XCTAssertTrue(contract.validationAnchors.contains("GH-461-OMS-ORDER-LIFECYCLE-STATE-MACHINE"))
        XCTAssertTrue(contract.validationAnchors.contains("GH-461-LOCAL-ORDER-BROKER-REPORT-RELATIONSHIP"))
        XCTAssertTrue(contract.validationAnchors.contains("GH-461-ILLEGAL-TRANSITION-EVIDENCE"))
        XCTAssertTrue(contract.validationAnchors.contains("GH-461-OMS-ENGINE-CLIENT-PORTFOLIO-BOUNDARY"))
        XCTAssertTrue(contract.validationAnchors.contains("GH-461-ROLLBACK-INCIDENT-EVIDENCE"))

        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/L4OMSOrderLifecycleContract.swift"
                ).path
            )
        )
    }

    func testGH461OMSOrderLifecycleContractRejectsIllegalTransitionAndBypass() throws {
        XCTAssertThrowsError(
            try L4OMSOrderStateTransitionRule(
                fromState: .filled,
                trigger: .sandboxSubmitAccepted,
                toState: .submitted,
                sourceEvidence: "unsafe filled to submitted bypass"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "transition",
                    expected: L4OMSOrderLifecycleContract.requiredTransitionRules.map {
                        "\($0.fromState.rawValue)|\($0.trigger.rawValue)|\($0.toState.rawValue)"
                    }.sorted().joined(separator: ","),
                    actual: "filled|sandbox submit accepted|submitted"
                )
            )
        }

        XCTAssertThrowsError(
            try L4OMSIllegalTransitionEvidence(
                evidenceID: Identifier.constant("unsafe-gh-461-allowed-illegal-evidence"),
                fromState: .accepted,
                attemptedTrigger: .sandboxSubmitAccepted,
                attemptedToState: .submitted,
                rejectionReason: "allowed transition cannot become illegal evidence"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "illegalTransition",
                    expected: "transition not present in GH-461 allowed graph",
                    actual: "accepted->submitted"
                )
            )
        }

        XCTAssertThrowsError(
            try L4OMSOrderLifecycleContract(
                implementsProductionOrderManager: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsProductionOrderManager")
            )
        }

        XCTAssertThrowsError(
            try L4OMSOrderLifecycleContract(
                bypassesRiskEngine: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("bypassesRiskEngine"))
        }

        XCTAssertThrowsError(
            try L4OMSOrderLifecycleContract(
                mutatesPortfolio: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("mutatesPortfolio"))
        }

        XCTAssertThrowsError(
            try L4OMSOrderLifecycleContract(
                transitionRules: Array(L4OMSOrderLifecycleContract.requiredTransitionRules.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "transitionRules",
                    expected: L4OMSOrderLifecycleContract.requiredTransitionRules.map {
                        "\($0.fromState.rawValue)|\($0.trigger.rawValue)|\($0.toState.rawValue)"
                    }.joined(separator: ","),
                    actual: Array(L4OMSOrderLifecycleContract.requiredTransitionRules.dropLast()).map {
                        "\($0.fromState.rawValue)|\($0.trigger.rawValue)|\($0.toState.rawValue)"
                    }.joined(separator: ",")
                )
            )
        }

        XCTAssertThrowsError(
            try L4OMSRollbackIncidentEvidence(
                automaticRetryEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("automaticRetryEnabled"))
        }
    }

    func testGH462OMSLocalOrderTransitionEvidenceBuildsDeterministicSandboxLifecycle() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)

        let builder = try L4OMSLocalOrderTransitionEvidenceBuilder.deterministicFixture()
        XCTAssertTrue(builder.lifecycleContract.contractHeld)
        XCTAssertTrue(builder.parserEvidence.reportParserEvidenceHeld)
        XCTAssertFalse(builder.productionRuntimeEnabled)
        XCTAssertFalse(builder.brokerGatewayTouched)
        XCTAssertFalse(builder.liveCommandSurfaceTouched)

        let evidence = try builder.deterministicEvidence()
        XCTAssertTrue(evidence.transitionEvidenceHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-462")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-461")
        XCTAssertTrue(evidence.lifecycleContract.contractHeld)
        XCTAssertEqual(evidence.stateRecords.count, 9)
        XCTAssertEqual(evidence.transitions.count, 6)
        XCTAssertEqual(evidence.illegalRejections.count, 3)
        XCTAssertTrue(evidence.fillEvidenceComplete)
        XCTAssertTrue(evidence.cancelEvidenceComplete)
        XCTAssertTrue(evidence.rejectEvidenceComplete)
        XCTAssertTrue(evidence.deterministicSandboxOnly)
        XCTAssertTrue(evidence.brokerIndependent)
        XCTAssertFalse(evidence.writesRealOrderStateStore)
        XCTAssertFalse(evidence.mutatesPortfolio)
        XCTAssertFalse(evidence.performsReconciliation)
        XCTAssertFalse(evidence.exposesLiveCommandSurface)

        XCTAssertEqual(evidence.stateRecords.map(\.sequence), Array(1...9))
        XCTAssertTrue(evidence.stateRecords.allSatisfy(\.recordBoundaryHeld))
        XCTAssertTrue(evidence.transitions.allSatisfy(\.transitionBoundaryHeld))
        XCTAssertTrue(evidence.illegalRejections.allSatisfy(\.rejectionBoundaryHeld))
        XCTAssertTrue(Set(evidence.transitions.map(\.trigger)).isSuperset(of: [
            .sandboxSubmitAccepted,
            .sandboxPartialFillReport,
            .sandboxFillReport,
            .sandboxCancelAcknowledgement,
            .sandboxRejectReport
        ]))
        XCTAssertTrue(Set(evidence.stateRecords.map(\.state)).isSuperset(of: [
            .filled,
            .cancelled,
            .rejected
        ]))

        let reportKinds = evidence.transitions.compactMap { $0.sandboxReportEvent?.reportKind }
        XCTAssertEqual(Set(reportKinds), Set<L4ExecutionClientSandboxReportKind>([
            .partialFill,
            .fill,
            .cancelAcknowledgement,
            .reject
        ]))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-462-OMS-LOCAL-ORDER-STATE-RECORD"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-462-DETERMINISTIC-TRANSITION-EVIDENCE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-462-SANDBOX-FILL-CANCEL-REJECT-EVIDENCE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-462-ILLEGAL-TRANSITION-REJECTION"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-462-BROKER-INDEPENDENT-LOCAL-STATE"))

        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/L4OMSLocalOrderTransitionEvidence.swift"
                ).path
            )
        )
    }

    func testGH462OMSLocalOrderTransitionEvidenceRejectsIllegalTransitionAndRuntimeBypass() throws {
        XCTAssertThrowsError(
            try L4OMSLocalOrderTransitionEvidenceBuilder(
                productionRuntimeEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionRuntimeEnabled"))
        }

        XCTAssertThrowsError(
            try L4OMSLocalOrderStateRecord(
                recordID: Identifier.constant("unsafe-gh-462-real-state-record"),
                orderID: Identifier.constant("unsafe-gh-462-order"),
                state: .submitted,
                sequence: 1,
                sourceEvidenceID: Identifier.constant("unsafe-gh-462-source"),
                writesRealOrderStateStore: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("writesRealOrderStateStore"))
        }

        let contract = try L4OMSOrderLifecycleContract.deterministicFixture()
        let fromRecord = try L4OMSLocalOrderStateRecord(
            recordID: Identifier.constant("unsafe-gh-462-filled-record"),
            orderID: Identifier.constant("unsafe-gh-462-order"),
            state: .filled,
            sequence: 1,
            sourceEvidenceID: Identifier.constant("unsafe-gh-462-source")
        )
        let toRecord = try L4OMSLocalOrderStateRecord(
            recordID: Identifier.constant("unsafe-gh-462-submitted-record"),
            orderID: Identifier.constant("unsafe-gh-462-order"),
            state: .submitted,
            sequence: 2,
            sourceEvidenceID: Identifier.constant("unsafe-gh-462-source")
        )
        XCTAssertThrowsError(
            try L4OMSLocalOrderTransitionRecord(
                transitionID: Identifier.constant("unsafe-gh-462-filled-to-submitted"),
                fromRecord: fromRecord,
                toRecord: toRecord,
                trigger: .sandboxSubmitAccepted,
                sourceEvidence: "unsafe illegal transition",
                contract: contract
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "transition",
                    expected: "GH-461 allowed transition",
                    actual: "filled|sandbox submit accepted|submitted"
                )
            )
        }

        let submitted = try L4OMSLocalOrderStateRecord(
            recordID: Identifier.constant("unsafe-gh-462-submitted-record-2"),
            orderID: Identifier.constant("unsafe-gh-462-order-2"),
            state: .submitted,
            sequence: 1,
            sourceEvidenceID: Identifier.constant("unsafe-gh-462-source")
        )
        let filled = try L4OMSLocalOrderStateRecord(
            recordID: Identifier.constant("unsafe-gh-462-filled-record-2"),
            orderID: Identifier.constant("unsafe-gh-462-order-2"),
            state: .filled,
            sequence: 2,
            sourceEvidenceID: Identifier.constant("unsafe-gh-462-source")
        )
        XCTAssertThrowsError(
            try L4OMSLocalOrderTransitionRecord(
                transitionID: Identifier.constant("unsafe-gh-462-missing-fill-event"),
                fromRecord: submitted,
                toRecord: filled,
                trigger: .sandboxFillReport,
                sourceEvidence: "missing GH-460 fill event",
                contract: contract
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "sandboxReportEvent",
                    expected: "fill",
                    actual: "nil"
                )
            )
        }

        let builder = try L4OMSLocalOrderTransitionEvidenceBuilder.deterministicFixture()
        let evidence = try builder.deterministicEvidence()
        XCTAssertThrowsError(
            try L4OMSLocalOrderTransitionEvidence(
                lifecycleContract: evidence.lifecycleContract,
                stateRecords: evidence.stateRecords,
                transitions: Array(evidence.transitions.dropLast()),
                illegalRejections: evidence.illegalRejections
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "transitionTriggers",
                    expected: L4OMSLocalOrderTransitionEvidence.requiredTransitionTriggers.map(\.rawValue).sorted().joined(separator: ","),
                    actual: Set(Array(evidence.transitions.dropLast()).map(\.trigger)).map(\.rawValue).sorted().joined(separator: ",")
                )
            )
        }

        XCTAssertThrowsError(
            try L4OMSLocalOrderTransitionEvidence(
                lifecycleContract: evidence.lifecycleContract,
                stateRecords: evidence.stateRecords,
                transitions: evidence.transitions,
                illegalRejections: evidence.illegalRejections,
                performsReconciliation: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("performsReconciliation"))
        }
    }

    func testGH463ExecutionEngineSandboxPathWiresRiskApprovedCommandEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)

        let coordinator = try L4ExecutionEngineSandboxPathCoordinator.deterministicFixture()
        XCTAssertTrue(coordinator.coordinatorBoundaryHeld)
        XCTAssertTrue(coordinator.riskEngineBoundary.dependencyDirectionHeld)
        XCTAssertTrue(coordinator.sandboxAdapter.sandboxAdapterBoundaryHeld)
        XCTAssertTrue(coordinator.localTransitionEvidence.transitionEvidenceHeld)
        XCTAssertFalse(coordinator.productionExecutionEnabled)
        XCTAssertFalse(coordinator.directTraderAccessAllowed)
        XCTAssertFalse(coordinator.directStrategyAccessAllowed)
        XCTAssertFalse(coordinator.skipsOMS)
        XCTAssertFalse(coordinator.performsReconciliation)
        XCTAssertFalse(coordinator.exposesLiveCommandSurface)

        let evidence = try coordinator.deterministicEvidence()
        XCTAssertTrue(evidence.sandboxPathEvidenceHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-463")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-459", "GH-461", "GH-462"])
        XCTAssertEqual(Set(evidence.proposals.map(\.commandKind)), Set(L4ExecutionClientSandboxCommandKind.allCases))
        XCTAssertEqual(Set(evidence.responses.map(\.commandKind)), Set(L4ExecutionClientSandboxCommandKind.allCases))
        XCTAssertEqual(Set(evidence.events.map(\.eventKind)), Set(L4ExecutionEngineSandboxPathEventKind.allCases))
        XCTAssertEqual(evidence.events.count, L4ExecutionClientSandboxCommandKind.allCases.count * L4ExecutionEngineSandboxPathEventKind.allCases.count)
        XCTAssertTrue(evidence.proposals.allSatisfy(\.proposalBoundaryHeld))
        XCTAssertTrue(evidence.responses.allSatisfy(\.acceptedBySandbox))
        XCTAssertTrue(evidence.events.allSatisfy(\.eventBoundaryHeld))
        XCTAssertTrue(evidence.commandEvidenceTraceable)
        XCTAssertTrue(evidence.responseEvidenceTraceable)
        XCTAssertTrue(evidence.executionEventEvidenceTraceable)
        XCTAssertTrue(evidence.directTraderStrategyAccessRejected)
        XCTAssertTrue(evidence.omsPathRequired)
        XCTAssertTrue(evidence.productionExecutionDisabled)
        XCTAssertFalse(evidence.performsReconciliation)
        XCTAssertFalse(evidence.mutatesPortfolio)
        XCTAssertFalse(evidence.exposesLiveCommandSurface)

        for proposal in evidence.proposals {
            let response = try coordinator.dispatch(proposal)
            XCTAssertEqual(response.commandKind, proposal.commandKind)
            XCTAssertEqual(response.venueMode, .sandbox)
            XCTAssertFalse(response.productionVenueTouched)
            XCTAssertFalse(response.brokerGatewayTouched)
            XCTAssertFalse(response.realOrderLifecycleTouched)
        }

        XCTAssertTrue(evidence.validationAnchors.contains("GH-463-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-463-RISKENGINE-APPROVED-COMMAND-PROPOSAL"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-463-SANDBOX-EXECUTIONCLIENT-HANDOFF"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-463-COMMAND-RESPONSE-EVENT-EVIDENCE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-463-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT"))
        XCTAssertTrue(evidence.validationAnchors.contains("TVM-L4-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH"))

        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/L4ExecutionEngineSandboxPathEvidence.swift"
                ).path
            )
        )
    }

    func testGH463ExecutionEngineSandboxPathRejectsDirectAccessAndBoundaryBypass() throws {
        XCTAssertThrowsError(
            try L4ExecutionEngineSandboxPathCoordinator(
                productionExecutionEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionExecutionEnabled"))
        }

        XCTAssertThrowsError(
            try L4ExecutionEngineSandboxPathCoordinator(
                directTraderAccessAllowed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("directTraderAccessAllowed"))
        }

        let localTransitionEvidence = try L4OMSLocalOrderTransitionEvidenceBuilder.deterministicFixture().deterministicEvidence()
        XCTAssertThrowsError(
            try L4ExecutionEngineSandboxCommandProposal(
                proposalID: Identifier.constant("unsafe-gh-463-direct-strategy-proposal"),
                source: .directStrategy,
                commandKind: .submit,
                riskEngineDecisionID: Identifier.constant("unsafe-gh-463-risk-decision"),
                omsTransitionEvidenceID: localTransitionEvidence.evidenceID,
                clientOrderID: Identifier.constant("unsafe-gh-463-client-order"),
                symbol: "BTCUSDT",
                quantity: "0.0100",
                limitPrice: "42120.70",
                reason: "unsafe direct strategy"
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("direct Strategy command"))
        }

        XCTAssertThrowsError(
            try L4ExecutionEngineSandboxCommandProposal(
                proposalID: Identifier.constant("unsafe-gh-463-skip-oms-proposal"),
                commandKind: .submit,
                riskEngineDecisionID: Identifier.constant("unsafe-gh-463-risk-decision"),
                omsTransitionEvidenceID: localTransitionEvidence.evidenceID,
                clientOrderID: Identifier.constant("unsafe-gh-463-client-order"),
                symbol: "BTCUSDT",
                quantity: "0.0100",
                limitPrice: "42120.70",
                reason: "unsafe skip OMS",
                routedThroughOMS: false
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("routedThroughOMS"))
        }

        let coordinator = try L4ExecutionEngineSandboxPathCoordinator.deterministicFixture()
        let evidence = try coordinator.deterministicEvidence()
        XCTAssertThrowsError(
            try L4ExecutionEngineSandboxPathEvidence(
                riskEngineBoundary: evidence.riskEngineBoundary,
                sandboxAdapter: evidence.sandboxAdapter,
                localTransitionEvidence: evidence.localTransitionEvidence,
                proposals: evidence.proposals,
                responses: Array(evidence.responses.dropLast()),
                events: evidence.events
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "responses",
                    expected: L4ExecutionClientSandboxCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                    actual: Array(evidence.responses.dropLast()).map { $0.commandKind.rawValue }.joined(separator: ",")
                )
            )
        }

        XCTAssertThrowsError(
            try L4ExecutionEngineSandboxPathEvidence(
                riskEngineBoundary: evidence.riskEngineBoundary,
                sandboxAdapter: evidence.sandboxAdapter,
                localTransitionEvidence: evidence.localTransitionEvidence,
                proposals: evidence.proposals,
                responses: evidence.responses,
                events: evidence.events,
                performsReconciliation: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("performsReconciliation"))
        }

        XCTAssertThrowsError(
            try L4ExecutionEngineSandboxPathEvent(
                eventID: Identifier.constant("unsafe-gh-463-portfolio-event"),
                proposalID: Identifier.constant("unsafe-gh-463-proposal"),
                eventKind: .sandboxResponseRecorded,
                commandKind: .submit,
                responseID: Identifier.constant("unsafe-gh-463-response"),
                omsTransitionEvidenceID: localTransitionEvidence.evidenceID,
                sequence: 1,
                writesPortfolioProjection: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("writesPortfolioProjection"))
        }
    }

    func testGH464LiveRiskPreTradeGateProducesAllowRejectBlockedIncidentEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let riskEngineTarget = try packageTargetBlock(named: "RiskEngine", packageSource: packageSource)

        let runtime = try L4LiveRiskPreTradeGateRuntime.deterministicFixture()
        XCTAssertTrue(runtime.runtimeBoundaryHeld)
        XCTAssertFalse(runtime.productionRiskEnabled)
        XCTAssertFalse(runtime.productionTradingEnabled)
        XCTAssertFalse(runtime.readsSecret)
        XCTAssertFalse(runtime.callsExecutionClient)
        XCTAssertFalse(runtime.touchesBrokerGateway)
        XCTAssertFalse(runtime.mutatesPortfolio)
        XCTAssertFalse(runtime.performsReconciliation)
        XCTAssertFalse(runtime.exposesLiveCommandSurface)

        let evidence = try runtime.deterministicEvidence()
        XCTAssertTrue(evidence.gateEvidenceHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-464")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-457", "GH-461"])
        XCTAssertEqual(Set(evidence.decisions.map(\.outcome)), Set(L4LiveRiskPreTradeDecisionOutcome.allCases))
        XCTAssertTrue(evidence.decisions.allSatisfy(\.decisionBoundaryHeld))
        XCTAssertTrue(evidence.allSandboxCommandsPassRiskEngine)
        XCTAssertTrue(evidence.riskRejectReasonsAuditable)
        XCTAssertTrue(evidence.commandBlockedWithoutRiskGate)
        XCTAssertTrue(evidence.productionEnablementClosed)
        XCTAssertFalse(evidence.callsExecutionClient)
        XCTAssertFalse(evidence.mutatesPortfolio)
        XCTAssertFalse(evidence.performsReconciliation)
        XCTAssertFalse(evidence.exposesLiveCommandSurface)

        let decisionsByOutcome = Dictionary(uniqueKeysWithValues: evidence.decisions.map { ($0.outcome, $0) })
        XCTAssertEqual(decisionsByOutcome[.allow]?.rejectReasons, [.none])
        XCTAssertEqual(decisionsByOutcome[.reject]?.rejectReasons, [.notionalLimitExceeded])
        XCTAssertEqual(decisionsByOutcome[.blocked]?.rejectReasons, [.accountReadModelMissing, .riskGateBypassRejected])
        XCTAssertEqual(decisionsByOutcome[.incidentStop]?.rejectReasons, [.incidentStopActive])

        for decision in evidence.decisions {
            XCTAssertTrue(decision.proposal.proposalBoundaryHeld)
            XCTAssertTrue(decision.readModelInput.inputBoundaryHeld)
            XCTAssertEqual(Set(decision.readModelInput.components), L4LiveRiskPreTradeReadModelInput.requiredComponents)
            XCTAssertTrue(decision.commandPathRequiresRiskEngine)
            XCTAssertTrue(decision.accountPositionBalanceMarginReadModelAttached)
            XCTAssertTrue(decision.decisionAuditable)
            XCTAssertFalse(decision.executesCommand)
            XCTAssertFalse(decision.callsExecutionClient)
            XCTAssertFalse(decision.touchesBrokerGateway)
            XCTAssertFalse(decision.mutatesPortfolio)
            XCTAssertFalse(decision.performsReconciliation)
            XCTAssertFalse(decision.exposesLiveCommandSurface)
        }

        XCTAssertTrue(evidence.validationAnchors.contains("GH-464-LIVE-RISKENGINE-PRE-TRADE-GATE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-464-ORDER-PROPOSAL-RISK-INPUT"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-464-APB-MARGIN-READ-MODEL-GATE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-464-ALLOW-REJECT-BLOCKED-INCIDENT-EVIDENCE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-464-COMMAND-PATH-RISKENGINE-REQUIRED"))
        XCTAssertTrue(evidence.validationAnchors.contains("TVM-L4-LIVE-RISKENGINE-PRE-TRADE-GATE"))

        XCTAssertTrue(riskEngineTarget.contains("\"LiveGate\""))
        XCTAssertFalse(riskEngineTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/RiskEngine/LiveGate/L4LiveRiskPreTradeGate.swift"
                ).path
            )
        )
    }

    func testGH464LiveRiskPreTradeGateRejectsBypassAndForbiddenRuntime() throws {
        XCTAssertThrowsError(
            try L4LiveRiskPreTradeGateRuntime(
                productionRiskEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionRiskEnabled"))
        }

        XCTAssertThrowsError(
            try L4LiveRiskPreTradeReadModelInput(
                accountValue: "account",
                positionValue: "position",
                balanceValue: "balance",
                marginValue: "margin",
                availableBalance: 1000,
                marginCapacity: 1000,
                components: ["account"]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "components",
                    expected: "account,balance,margin,position",
                    actual: "account"
                )
            )
        }

        XCTAssertThrowsError(
            try L4LiveRiskOrderProposalInput(
                proposalID: Identifier.constant("unsafe-gh-464-risk-bypass-proposal"),
                commandKind: .submit,
                symbol: "BTCUSDT",
                quantity: 0.10,
                limitPrice: 42120.70,
                reason: "unsafe bypass",
                riskGateBypassed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("riskGateBypassed"))
        }

        let runtime = try L4LiveRiskPreTradeGateRuntime.deterministicFixture()
        let readModelInput = try L4LiveRiskPreTradeReadModelInput.deterministicFixture()
        let proposal = try L4LiveRiskOrderProposalInput(
            proposalID: Identifier.constant("unsafe-gh-464-executes-command-proposal"),
            commandKind: .submit,
            symbol: "BTCUSDT",
            quantity: 0.10,
            limitPrice: 42120.70,
            reason: "unsafe command execution"
        )
        XCTAssertThrowsError(
            try L4LiveRiskPreTradeDecisionEvidence(
                decisionID: Identifier.constant("unsafe-gh-464-executes-command-decision"),
                proposal: proposal,
                readModelInput: readModelInput,
                outcome: .allow,
                rejectReasons: [.none],
                executesCommand: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("executesCommand"))
        }

        let evidence = try runtime.deterministicEvidence()
        XCTAssertThrowsError(
            try L4LiveRiskPreTradeGateEvidence(
                decisions: Array(evidence.decisions.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "decisions.outcome",
                    expected: L4LiveRiskPreTradeDecisionOutcome.allCases.map(\.rawValue).joined(separator: ","),
                    actual: Array(evidence.decisions.dropLast()).map { $0.outcome.rawValue }.joined(separator: ",")
                )
            )
        }

        XCTAssertThrowsError(
            try L4LiveRiskPreTradeGateEvidence(
                decisions: evidence.decisions,
                callsExecutionClient: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("callsExecutionClient"))
        }

        let rejected = try runtime.evaluate(
            proposal: try L4LiveRiskOrderProposalInput(
                proposalID: Identifier.constant("gh-464-focused-reject-proposal"),
                commandKind: .replace,
                symbol: "BTCUSDT",
                quantity: 1.0,
                limitPrice: 42120.70,
                reason: "focused reject coverage"
            ),
            readModelInput: readModelInput
        )
        XCTAssertEqual(rejected.outcome, .reject)
        XCTAssertEqual(rejected.rejectReasons, [.notionalLimitExceeded])
    }

    func testGH465KillSwitchIncidentShutdownGateBlocksAllCommandsAndDefinesRecoveryBoundary() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let riskEngineTarget = try packageTargetBlock(named: "RiskEngine", packageSource: packageSource)

        let runtime = try L4KillSwitchIncidentShutdownGateRuntime.deterministicFixture()
        XCTAssertTrue(runtime.runtimeBoundaryHeld)
        XCTAssertFalse(runtime.productionTradingEnabled)
        XCTAssertFalse(runtime.productionOperationsRuntimeTouched)
        XCTAssertFalse(runtime.readsSecret)
        XCTAssertFalse(runtime.callsExecutionClient)
        XCTAssertFalse(runtime.touchesBrokerGateway)
        XCTAssertFalse(runtime.submitsRealOrder)
        XCTAssertFalse(runtime.autoRecoveryEnabled)
        XCTAssertFalse(runtime.bypassesRiskEngine)
        XCTAssertFalse(runtime.bypassesOMS)
        XCTAssertFalse(runtime.exposesLiveCommandSurface)

        let evidence = try runtime.deterministicEvidence()
        XCTAssertTrue(evidence.gateEvidenceHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-465")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-464"])
        XCTAssertTrue(evidence.sourceEvidence.sourceBoundaryHeld)
        XCTAssertEqual(evidence.sourceEvidence.sourceKind, .riskEngineIncidentStop)
        XCTAssertEqual(evidence.sourceEvidence.upstreamRiskOutcome, .incidentStop)
        XCTAssertTrue(evidence.sourceEvidence.identityRecorded)
        XCTAssertTrue(evidence.sourceEvidence.operatorAcknowledged)
        XCTAssertFalse(evidence.sourceEvidence.autoRecoveryAuthorized)
        XCTAssertFalse(evidence.sourceEvidence.liveCommandSurfaceTouched)
        XCTAssertFalse(evidence.sourceEvidence.productionOperationsRuntimeTouched)
        XCTAssertFalse(evidence.sourceEvidence.brokerGatewayTouched)

        XCTAssertEqual(evidence.decisions.map(\.commandKind), L4LiveRiskPreTradeCommandKind.allCases)
        XCTAssertTrue(evidence.decisions.allSatisfy(\.decisionBoundaryHeld))
        XCTAssertTrue(evidence.incidentStopBlocksCommandPath)
        XCTAssertTrue(evidence.submitCancelReplaceBlocked)
        XCTAssertTrue(evidence.sourceIdentityAuditable)
        XCTAssertTrue(evidence.dashboardAuditEvidenceExplainable)
        XCTAssertTrue(evidence.recoveryBoundaryNotAutomatic)
        XCTAssertTrue(evidence.productionEnablementClosed)
        XCTAssertFalse(evidence.callsExecutionClient)
        XCTAssertFalse(evidence.touchesBrokerGateway)
        XCTAssertFalse(evidence.exposesLiveCommandSurface)

        for decision in evidence.decisions {
            XCTAssertEqual(decision.outcome, .blockedByCommandShutdown)
            XCTAssertEqual(decision.reasons, L4CommandShutdownGateDecisionEvidence.requiredReasons)
            XCTAssertEqual(decision.recoveryBoundary, L4CommandShutdownGateDecisionEvidence.requiredRecoveryBoundary)
            XCTAssertTrue(decision.incidentStopActive)
            XCTAssertTrue(decision.commandShutdownActive)
            XCTAssertTrue(decision.sourceIdentityAttached)
            XCTAssertTrue(decision.dashboardAuditExplainable)
            XCTAssertFalse(decision.executesCommand)
            XCTAssertFalse(decision.callsExecutionClient)
            XCTAssertFalse(decision.touchesBrokerGateway)
            XCTAssertFalse(decision.submitsRealOrder)
            XCTAssertFalse(decision.productionTradingEnabled)
            XCTAssertFalse(decision.autoRecoveryEnabled)
            XCTAssertFalse(decision.exposesLiveCommandSurface)
        }

        XCTAssertTrue(evidence.validationAnchors.contains("GH-465-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-465-INCIDENT-STOP-SOURCE-IDENTITY"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-465-SUBMIT-CANCEL-REPLACE-SHUTDOWN-RULES"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-465-DASHBOARD-AUDIT-SHUTDOWN-EVIDENCE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-465-NO-AUTOMATIC-RECOVERY"))
        XCTAssertTrue(evidence.validationAnchors.contains("TVM-L4-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE"))

        XCTAssertTrue(riskEngineTarget.contains("\"LiveGate\""))
        XCTAssertFalse(riskEngineTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/RiskEngine/LiveGate/L4KillSwitchIncidentShutdownGate.swift"
                ).path
            )
        )
    }

    func testGH465KillSwitchIncidentShutdownGateRejectsAutoRecoveryAndCommandBypass() throws {
        XCTAssertThrowsError(
            try L4KillSwitchIncidentShutdownGateRuntime(
                autoRecoveryEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("autoRecoveryEnabled"))
        }

        let riskRuntime = try L4LiveRiskPreTradeGateRuntime.deterministicFixture()
        let riskEvidence = try riskRuntime.deterministicEvidence()
        let decisionsByOutcome = Dictionary(uniqueKeysWithValues: riskEvidence.decisions.map { ($0.outcome, $0) })
        let incidentDecision = try XCTUnwrap(decisionsByOutcome[.incidentStop])
        let allowDecision = try XCTUnwrap(decisionsByOutcome[.allow])

        XCTAssertThrowsError(
            try L4IncidentStopSourceEvidence(
                triggeredByRiskDecisionID: incidentDecision.decisionID,
                upstreamRiskOutcome: incidentDecision.outcome,
                reason: "unsafe auto recovery",
                autoRecoveryAuthorized: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("autoRecoveryAuthorized"))
        }

        XCTAssertThrowsError(
            try L4IncidentStopSourceEvidence(
                triggeredByRiskDecisionID: allowDecision.decisionID,
                upstreamRiskOutcome: allowDecision.outcome,
                reason: "unsafe non-incident source"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamRiskOutcome",
                    expected: L4LiveRiskPreTradeDecisionOutcome.incidentStop.rawValue,
                    actual: L4LiveRiskPreTradeDecisionOutcome.allow.rawValue
                )
            )
        }

        let source = try L4IncidentStopSourceEvidence(
            triggeredByRiskDecisionID: incidentDecision.decisionID,
            upstreamRiskOutcome: incidentDecision.outcome,
            reason: "GH-465 focused incident shutdown source"
        )
        XCTAssertThrowsError(
            try L4CommandShutdownGateDecisionEvidence(
                decisionID: Identifier.constant("unsafe-gh-465-executes-command"),
                sourceEvidenceID: source.sourceEvidenceID,
                triggeredByRiskDecisionID: incidentDecision.decisionID,
                commandKind: .submit,
                executesCommand: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("executesCommand"))
        }

        let runtime = try L4KillSwitchIncidentShutdownGateRuntime.deterministicFixture()
        XCTAssertThrowsError(
            try runtime.activate(sourceEvidence: source, riskDecision: allowDecision)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "riskDecision.outcome",
                    expected: L4LiveRiskPreTradeDecisionOutcome.incidentStop.rawValue,
                    actual: L4LiveRiskPreTradeDecisionOutcome.allow.rawValue
                )
            )
        }

        let evidence = try runtime.activate(sourceEvidence: source, riskDecision: incidentDecision)
        XCTAssertThrowsError(
            try L4KillSwitchIncidentShutdownGateEvidence(
                sourceEvidence: evidence.sourceEvidence,
                decisions: Array(evidence.decisions.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "decisions.commandKind",
                    expected: L4LiveRiskPreTradeCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                    actual: Array(evidence.decisions.dropLast()).map { $0.commandKind.rawValue }.joined(separator: ",")
                )
            )
        }

        XCTAssertThrowsError(
            try L4KillSwitchIncidentShutdownGateEvidence(
                sourceEvidence: evidence.sourceEvidence,
                decisions: evidence.decisions,
                exposesLiveCommandSurface: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesLiveCommandSurface"))
        }
    }

    func testGH466OMSBrokerPortfolioReconciliationBuildsDeterministicEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)

        let runtime = try L4OMSBrokerPortfolioReconciliationRuntime.deterministicFixture()
        XCTAssertTrue(runtime.runtimeBoundaryHeld)
        XCTAssertTrue(runtime.parserEvidence.reportParserEvidenceHeld)
        XCTAssertTrue(runtime.localTransitionEvidence.transitionEvidenceHeld)
        XCTAssertTrue(runtime.sandboxPathEvidence.sandboxPathEvidenceHeld)
        XCTAssertFalse(runtime.productionReconciliationEnabled)
        XCTAssertFalse(runtime.productionBrokerReportConsumed)
        XCTAssertFalse(runtime.rawBrokerPayloadRead)
        XCTAssertFalse(runtime.realAccountRead)
        XCTAssertFalse(runtime.realPnLProduced)
        XCTAssertFalse(runtime.portfolioRuntimeMutated)
        XCTAssertFalse(runtime.callsExecutionClient)
        XCTAssertFalse(runtime.touchesBrokerGateway)
        XCTAssertFalse(runtime.exposesLiveCommandSurface)

        let evidence = try runtime.deterministicEvidence()
        XCTAssertTrue(evidence.reconciliationEvidenceHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-466")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-460", "GH-462", "GH-463"])
        XCTAssertEqual(Set(evidence.records.map(\.status)), Set(L4OMSBrokerPortfolioReconciliationStatus.allCases))
        XCTAssertTrue(Set(evidence.records.map(\.path)).isSuperset(of: [
            .partialFill,
            .cancel,
            .reject
        ]))
        XCTAssertTrue(evidence.records.allSatisfy(\.recordBoundaryHeld))
        XCTAssertTrue(evidence.matchedMismatchedStaleMissingCovered)
        XCTAssertTrue(evidence.partialFillCancelRejectCovered)
        XCTAssertTrue(evidence.portfolioProjectionAvoidsBrokerPayload)
        XCTAssertTrue(evidence.productionBrokerReportFutureGated)
        XCTAssertTrue(evidence.deterministicAuditEvidence)
        XCTAssertFalse(evidence.productionReconciliationEnabled)
        XCTAssertFalse(evidence.realPnLProduced)
        XCTAssertFalse(evidence.exposesLiveCommandSurface)

        let recordsByStatus = Dictionary(uniqueKeysWithValues: evidence.records.map { ($0.status, $0) })
        let matched = try XCTUnwrap(recordsByStatus[.matched])
        XCTAssertEqual(matched.path, .partialFill)
        XCTAssertEqual(matched.reasons, [.none])
        XCTAssertEqual(matched.portfolioProjection?.projectedState, matched.omsTransition.toRecord.state)
        XCTAssertEqual(matched.portfolioProjection?.projectedFilledQuantity, matched.brokerReportEvent?.filledQuantity)
        XCTAssertEqual(matched.portfolioProjection?.projectedRemainingQuantity, matched.brokerReportEvent?.remainingQuantity)

        let mismatched = try XCTUnwrap(recordsByStatus[.mismatched])
        XCTAssertEqual(mismatched.path, .cancel)
        XCTAssertEqual(mismatched.reasons, [.omsProjectionStateMismatch])
        XCTAssertNotEqual(mismatched.portfolioProjection?.projectedState, mismatched.omsTransition.toRecord.state)

        let stale = try XCTUnwrap(recordsByStatus[.stale])
        XCTAssertEqual(stale.path, .reject)
        XCTAssertEqual(stale.reasons, [.projectionStaleSequence])
        XCTAssertLessThan(
            try XCTUnwrap(stale.portfolioProjection?.projectionSequence),
            stale.omsTransition.toRecord.sequence
        )

        let missing = try XCTUnwrap(recordsByStatus[.missing])
        XCTAssertEqual(missing.path, .fill)
        XCTAssertEqual(missing.reasons, [.portfolioProjectionMissing])
        XCTAssertNotNil(missing.brokerReportEvent)
        XCTAssertNil(missing.portfolioProjection)

        for record in evidence.records {
            XCTAssertEqual(record.comparedFields, L4OMSBrokerPortfolioReconciliationRecord.requiredComparedFields)
            XCTAssertTrue(record.deterministicAuditEvidence)
            XCTAssertFalse(record.productionBrokerReportConsumed)
            XCTAssertFalse(record.rawBrokerPayloadRead)
            XCTAssertFalse(record.realAccountRead)
            XCTAssertFalse(record.portfolioRuntimeMutated)
            XCTAssertFalse(record.repairCommandProduced)
            XCTAssertFalse(record.exposesLiveCommandSurface)
            XCTAssertTrue(record.brokerReportEvent?.parsedEventBoundaryHeld ?? false)
            if let projection = record.portfolioProjection {
                XCTAssertTrue(projection.projectionBoundaryHeld)
                XCTAssertFalse(projection.readsRawBrokerPayload)
                XCTAssertFalse(projection.readsRealAccount)
                XCTAssertFalse(projection.computesRealPnL)
                XCTAssertFalse(projection.mutatesPortfolioRuntime)
            }
        }

        XCTAssertTrue(evidence.validationAnchors.contains("GH-466-OMS-BROKER-PORTFOLIO-RECONCILIATION"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-466-RECONCILIATION-FIELD-MATRIX"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-466-MATCHED-MISMATCHED-STALE-MISSING-EVIDENCE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-466-PARTIAL-CANCEL-REJECT-PATHS"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-466-PORTFOLIO-PROJECTION-NO-BROKER-PAYLOAD"))
        XCTAssertTrue(evidence.validationAnchors.contains("TVM-L4-OMS-BROKER-PORTFOLIO-RECONCILIATION"))

        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/L4OMSBrokerPortfolioReconciliationEvidence.swift"
                ).path
            )
        )
    }

    func testGH466OMSBrokerPortfolioReconciliationRejectsProductionBrokerPayloadAndCoverageBypass() throws {
        XCTAssertThrowsError(
            try L4OMSBrokerPortfolioReconciliationRuntime(
                productionReconciliationEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionReconciliationEnabled"))
        }

        let runtime = try L4OMSBrokerPortfolioReconciliationRuntime.deterministicFixture()
        let transition = try XCTUnwrap(
            runtime.localTransitionEvidence.transitions.first { $0.trigger == .sandboxPartialFillReport }
        )
        let event = try XCTUnwrap(
            runtime.parserEvidence.parsedEvents.first { $0.reportKind == .partialFill }
        )

        XCTAssertThrowsError(
            try L4PortfolioProjectionReconciliationSnapshot(
                projectionID: Identifier.constant("unsafe-gh-466-broker-payload-projection"),
                sourceTransitionID: transition.transitionID,
                sourceReportEventID: event.eventID,
                clientOrderID: event.clientOrderID,
                path: .partialFill,
                projectedState: transition.toRecord.state,
                projectedFilledQuantity: event.filledQuantity,
                projectedRemainingQuantity: event.remainingQuantity,
                projectionSequence: transition.toRecord.sequence,
                readsRawBrokerPayload: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRawBrokerPayload"))
        }

        let mismatchingProjection = try L4PortfolioProjectionReconciliationSnapshot(
            projectionID: Identifier.constant("unsafe-gh-466-matched-mismatch-projection"),
            sourceTransitionID: transition.transitionID,
            sourceReportEventID: event.eventID,
            clientOrderID: event.clientOrderID,
            path: .partialFill,
            projectedState: .submitted,
            projectedFilledQuantity: event.filledQuantity,
            projectedRemainingQuantity: event.remainingQuantity,
            projectionSequence: transition.toRecord.sequence
        )
        XCTAssertThrowsError(
            try L4OMSBrokerPortfolioReconciliationRecord(
                recordID: Identifier.constant("unsafe-gh-466-matched-record"),
                path: .partialFill,
                status: .matched,
                omsTransition: transition,
                brokerReportEvent: event,
                portfolioProjection: mismatchingProjection,
                reasons: [.none]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "recordBoundaryHeld",
                    expected: "matched partial fill reconciliation boundary held",
                    actual: "mismatch"
                )
            )
        }

        XCTAssertThrowsError(
            try L4OMSBrokerPortfolioReconciliationRecord(
                recordID: Identifier.constant("unsafe-gh-466-production-report-record"),
                path: .partialFill,
                status: .mismatched,
                omsTransition: transition,
                brokerReportEvent: event,
                portfolioProjection: mismatchingProjection,
                reasons: [.omsProjectionStateMismatch],
                productionBrokerReportConsumed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionBrokerReportConsumed"))
        }

        let evidence = try runtime.deterministicEvidence()
        XCTAssertThrowsError(
            try L4OMSBrokerPortfolioReconciliationEvidence(
                parserEvidence: evidence.parserEvidence,
                localTransitionEvidence: evidence.localTransitionEvidence,
                sandboxPathEvidence: evidence.sandboxPathEvidence,
                records: Array(evidence.records.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "records.status",
                    expected: L4OMSBrokerPortfolioReconciliationStatus.allCases.map(\.rawValue).joined(separator: ","),
                    actual: Array(evidence.records.dropLast()).map { $0.status.rawValue }.joined(separator: ",")
                )
            )
        }

        XCTAssertThrowsError(
            try L4OMSBrokerPortfolioReconciliationEvidence(
                parserEvidence: evidence.parserEvidence,
                localTransitionEvidence: evidence.localTransitionEvidence,
                sandboxPathEvidence: evidence.sandboxPathEvidence,
                records: evidence.records,
                productionReconciliationEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionReconciliationEnabled"))
        }
    }

    func testGH467AuditTrailIncidentReplayBuildsAppendOnlyReplayEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)

        let runtime = try L4AuditTrailIncidentReplayRuntime.deterministicFixture()
        XCTAssertTrue(runtime.runtimeBoundaryHeld)
        XCTAssertTrue(runtime.sandboxPathEvidence.sandboxPathEvidenceHeld)
        XCTAssertTrue(runtime.reconciliationEvidence.reconciliationEvidenceHeld)
        XCTAssertFalse(runtime.externalAuditUploadEnabled)
        XCTAssertFalse(runtime.productionIncidentOpsEnabled)
        XCTAssertFalse(runtime.productionBrokerReplayEnabled)
        XCTAssertFalse(runtime.capturesSecret)
        XCTAssertFalse(runtime.capturesRawBrokerPayload)
        XCTAssertFalse(runtime.mutableAuditTrail)
        XCTAssertFalse(runtime.callsExecutionClient)
        XCTAssertFalse(runtime.touchesBrokerGateway)
        XCTAssertFalse(runtime.exposesLiveCommandSurface)

        let evidence = try runtime.deterministicEvidence()
        XCTAssertTrue(evidence.auditTrailReplayEvidenceHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-467")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-463", "GH-466"])
        XCTAssertTrue(evidence.sandboxPathEvidence.sandboxPathEvidenceHeld)
        XCTAssertTrue(evidence.reconciliationEvidence.reconciliationEvidenceHeld)
        XCTAssertTrue(evidence.commandEvidenceTraceable)
        XCTAssertTrue(evidence.incidentReplayDeterministic)
        XCTAssertTrue(evidence.appendOnlyAuditTrail)
        XCTAssertTrue(evidence.secretAndRawPayloadFree)
        XCTAssertTrue(evidence.externalAuditDisabled)
        XCTAssertTrue(evidence.productionIncidentOpsDisabled)
        XCTAssertFalse(evidence.productionBrokerReplayEnabled)
        XCTAssertFalse(evidence.exposesLiveCommandSurface)

        XCTAssertEqual(evidence.auditTrailEntries.map(\.sequence), Array(1...evidence.auditTrailEntries.count))
        XCTAssertEqual(Set(evidence.auditTrailEntries.map(\.commandKind)), Set(L4ExecutionClientSandboxCommandKind.allCases))
        XCTAssertEqual(Set(evidence.auditTrailEntries.map(\.stage)), Set(L4AuditTrailIncidentReplayStage.allCases))
        XCTAssertEqual(
            Set(evidence.auditTrailEntries.compactMap(\.reconciliationStatus)),
            Set(L4OMSBrokerPortfolioReconciliationStatus.allCases)
        )
        XCTAssertTrue(evidence.auditTrailEntries.allSatisfy(\.entryBoundaryHeld))

        for commandKind in L4ExecutionClientSandboxCommandKind.allCases {
            let commandEntries = evidence.auditTrailEntries.filter { $0.commandKind == commandKind }
            XCTAssertEqual(Set(commandEntries.map(\.stage)), Set(L4AuditTrailIncidentReplayStage.allCases))
        }

        for entry in evidence.auditTrailEntries {
            XCTAssertTrue(entry.appendOnlyFact)
            XCTAssertFalse(entry.containsSecret)
            XCTAssertFalse(entry.containsRawBrokerPayload)
            XCTAssertFalse(entry.uploadedToExternalAudit)
            XCTAssertFalse(entry.mutableAfterAppend)
            XCTAssertFalse(entry.productionBrokerReplay)
            XCTAssertFalse(entry.repairCommandProduced)
            XCTAssertFalse(entry.callsExecutionClient)
            XCTAssertFalse(entry.touchesBrokerGateway)
            XCTAssertFalse(entry.exposesLiveCommandSurface)
            XCTAssertFalse(entry.deterministicPayloadDigest.isEmpty)
            switch entry.stage {
            case .commandIntent:
                XCTAssertFalse(entry.commandIntentID.rawValue.isEmpty)
            case .riskDecision:
                XCTAssertFalse(entry.riskDecisionID.rawValue.isEmpty)
            case .executionRequest:
                XCTAssertFalse(entry.executionRequestID.rawValue.isEmpty)
            case .brokerReport:
                XCTAssertNotNil(entry.brokerReportEventID)
            case .omsTransition:
                XCTAssertNotNil(entry.omsTransitionID)
            case .reconciliationOutcome:
                XCTAssertNotNil(entry.reconciliationRecordID)
                XCTAssertNotNil(entry.reconciliationStatus)
            }
        }

        XCTAssertTrue(evidence.replayInput.inputBoundaryHeld)
        XCTAssertTrue(evidence.replayOutput.outputBoundaryHeld)
        XCTAssertEqual(evidence.replayOutput.replayedCommandKinds, L4ExecutionClientSandboxCommandKind.allCases)
        XCTAssertEqual(evidence.replayOutput.replayedStages, L4AuditTrailIncidentReplayStage.allCases)
        XCTAssertEqual(evidence.replayOutput.replayedReconciliationStatuses, L4OMSBrokerPortfolioReconciliationStatus.allCases)
        XCTAssertTrue(evidence.replayOutput.appendOnlyReplayDeterministic)
        XCTAssertTrue(evidence.replayOutput.sandboxLifecycleReplayed)
        XCTAssertTrue(evidence.replayOutput.secretFree)
        XCTAssertTrue(evidence.replayOutput.rawBrokerPayloadFree)
        XCTAssertFalse(evidence.replayOutput.externalAuditUpload)
        XCTAssertFalse(evidence.replayOutput.productionIncidentOps)
        XCTAssertFalse(evidence.replayOutput.productionBrokerReplay)
        XCTAssertFalse(evidence.replayOutput.repairCommandProduced)
        XCTAssertFalse(evidence.replayOutput.exposesLiveCommandSurface)

        XCTAssertTrue(evidence.validationAnchors.contains("GH-467-AUDIT-TRAIL-INCIDENT-REPLAY"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-467-COMMAND-EVIDENCE-TRACE"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-467-APPEND-ONLY-AUDIT-TRAIL"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-467-DETERMINISTIC-INCIDENT-REPLAY"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-467-NO-SECRET-RAW-PAYLOAD"))
        XCTAssertTrue(evidence.validationAnchors.contains("TVM-L4-AUDIT-TRAIL-INCIDENT-REPLAY"))

        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/L4AuditTrailIncidentReplayEvidence.swift"
                ).path
            )
        )
    }

    func testGH467AuditTrailIncidentReplayRejectsExternalAuditRawPayloadAndReplayBypass() throws {
        XCTAssertThrowsError(
            try L4AuditTrailIncidentReplayRuntime(
                externalAuditUploadEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("externalAuditUploadEnabled"))
        }

        let runtime = try L4AuditTrailIncidentReplayRuntime.deterministicFixture()
        let evidence = try runtime.deterministicEvidence()
        let firstEntry = try XCTUnwrap(evidence.auditTrailEntries.first)

        XCTAssertThrowsError(
            try L4CommandAuditTrailEntry(
                entryID: Identifier.constant("unsafe-gh-467-zero-sequence-entry"),
                commandKind: firstEntry.commandKind,
                stage: .commandIntent,
                sequence: 0,
                commandIntentID: firstEntry.commandIntentID,
                riskDecisionID: firstEntry.riskDecisionID,
                executionRequestID: firstEntry.executionRequestID,
                deterministicPayloadDigest: "unsafe"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "sequence",
                    expected: "positive append-only GH-467 sequence",
                    actual: "0"
                )
            )
        }

        XCTAssertThrowsError(
            try L4CommandAuditTrailEntry(
                entryID: Identifier.constant("unsafe-gh-467-secret-entry"),
                commandKind: firstEntry.commandKind,
                stage: .commandIntent,
                sequence: firstEntry.sequence,
                commandIntentID: firstEntry.commandIntentID,
                riskDecisionID: firstEntry.riskDecisionID,
                executionRequestID: firstEntry.executionRequestID,
                deterministicPayloadDigest: "unsafe",
                containsSecret: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("containsSecret"))
        }

        XCTAssertThrowsError(
            try L4IncidentReplayOutput(
                inputID: evidence.replayInput.inputID,
                incidentID: evidence.replayInput.incidentID,
                replayedEntries: evidence.auditTrailEntries,
                replayedCommandKinds: L4ExecutionClientSandboxCommandKind.allCases,
                replayedStages: L4AuditTrailIncidentReplayStage.allCases,
                replayedReconciliationStatuses: L4OMSBrokerPortfolioReconciliationStatus.allCases,
                deterministicReplayDigest: "unsafe",
                productionBrokerReplay: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionBrokerReplay"))
        }

        XCTAssertThrowsError(
            try L4AuditTrailIncidentReplayEvidence(
                sandboxPathEvidence: evidence.sandboxPathEvidence,
                reconciliationEvidence: evidence.reconciliationEvidence,
                auditTrailEntries: Array(evidence.auditTrailEntries.dropLast()),
                replayInput: evidence.replayInput,
                replayOutput: evidence.replayOutput
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "auditTrailEntries.reconciliationStatus",
                    expected: L4OMSBrokerPortfolioReconciliationStatus.allCases.map(\.rawValue).joined(separator: ","),
                    actual: Set(Array(evidence.auditTrailEntries.dropLast()).compactMap(\.reconciliationStatus))
                        .map(\.rawValue)
                        .sorted()
                        .joined(separator: ",")
                )
            )
        }
    }

    func testGH471ProductionCutoverGatePolicyDefinesNoDefaultRealTradingBoundary() throws {
        // 测试场景：GH-471 只定义 future production cutover gate 和 no-default-real-trading policy；
        // 它不能打开 production endpoint、broker gateway、order form、trading button 或真实订单。
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let policy = try L4ProductionCutoverGatePolicy.deterministicFixture()
        XCTAssertTrue(policy.policyHeld)
        XCTAssertTrue(policy.acceptanceCriteriaCoverageHeld)
        XCTAssertEqual(policy.issueID.rawValue, "GH-471")
        XCTAssertEqual(policy.upstreamIssueID.rawValue, "GH-470")
        XCTAssertEqual(policy.downstreamIssueID.rawValue, "GH-472")
        XCTAssertEqual(policy.canonicalQueueRange, "GH-452..GH-472")
        XCTAssertEqual(Set(policy.prerequisites), Set(L4ProductionCutoverPrerequisite.allCases))
        XCTAssertEqual(Set(policy.forbiddenCapabilities), Set(L4ProductionCutoverForbiddenCapability.allCases))

        XCTAssertTrue(policy.validationAnchors.contains("GH-471-PRODUCTION-CUTOVER-FUTURE-GATE"))
        XCTAssertTrue(policy.validationAnchors.contains("GH-471-NO-DEFAULT-REAL-TRADING-POLICY"))
        XCTAssertTrue(policy.validationAnchors.contains("GH-471-HUMAN-ACCEPTANCE-CRITERIA"))
        XCTAssertTrue(policy.validationAnchors.contains("TVM-L4-PRODUCTION-CUTOVER-GATE"))

        XCTAssertTrue(policy.productionCutoverIsFutureGate)
        XCTAssertTrue(policy.humanAcceptanceRequired)
        XCTAssertTrue(policy.sandboxValidationMatrixClosureRequired)
        XCTAssertTrue(policy.stageAuditInputRequiredBeforeCutover)
        XCTAssertTrue(policy.noDefaultRealTradingPolicyRequired)
        XCTAssertTrue(policy.acceptanceCriteria.allSatisfy(\.requiresHumanAcceptance))
        XCTAssertTrue(policy.acceptanceCriteria.allSatisfy { $0.allowsAutomationOnlyCutover == false })

        for forbidden in [
            policy.productionTradingEnabledByDefault,
            policy.automaticProductionCutoverEnabled,
            policy.automationOnlyCutoverAllowed,
            policy.readsCredentialValue,
            policy.storesSecret,
            policy.callsSignedEndpoint,
            policy.connectsProductionEndpoint,
            policy.enablesBrokerGateway,
            policy.submitsRealOrder,
            policy.cancelsRealOrder,
            policy.replacesRealOrder,
            policy.exposesDashboardCommandBypass,
            policy.exposesLiveProConsoleProductionCommand,
            policy.exposesOrderForm,
            policy.exposesTradingButton
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/L4ProductionCutoverGatePolicy.swift"
                ).path
            )
        )
    }

    func testGH471ProductionCutoverGatePolicyRejectsAutomaticCutoverAndProductionBypass() throws {
        XCTAssertThrowsError(
            try L4ProductionCutoverGatePolicy(
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionTradingEnabledByDefault")
            )
        }

        XCTAssertThrowsError(
            try L4ProductionCutoverGatePolicy(
                automaticProductionCutoverEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("automaticProductionCutoverEnabled")
            )
        }

        XCTAssertThrowsError(
            try L4ProductionCutoverGatePolicy(
                connectsProductionEndpoint: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("connectsProductionEndpoint")
            )
        }

        XCTAssertThrowsError(
            try L4ProductionCutoverGatePolicy(
                acceptanceCriteria: []
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "acceptanceCriteria",
                    expected: "GH-471 required human acceptance criteria",
                    actual: "[]"
                )
            )
        }

        XCTAssertThrowsError(
            try L4ProductionCutoverAcceptanceCriterion(
                name: "unsafe automation-only cutover",
                evidenceAnchor: "unsafe",
                upstreamIssueAnchors: ["GH-471"],
                allowsAutomationOnlyCutover: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("allowsAutomationOnlyCutover"))
        }
    }

    func testGH421AllArchitectureTargetsExposeIndependentRealAPISmokeCoverage() throws {
        let sourceID = try FoundationTargetID("gh-421-source")
        let domainOwnership = FoundationTargetSourceOwnership.domainModel(ownerID: sourceID)
        XCTAssertEqual(domainOwnership.targetName, "DomainModel")
        XCTAssertEqual(domainOwnership.canonicalSourceRoot, "Sources/DomainModel")
        XCTAssertTrue(domainOwnership.ownsRealModuleSourceRoot)

        let topic = try FoundationMessageTopic("gh421.foundation")
        var foundationStream = try FoundationMessageStream()
        let foundationEnvelope = try foundationStream.publish(
            topic: topic,
            sourceID: sourceID,
            recordedAt: Date(timeIntervalSince1970: 421)
        )
        XCTAssertEqual(foundationStream.replay(topic: topic), [foundationEnvelope])

        var checkpoint = try FoundationDatabaseCheckpoint(
            checkpointID: try FoundationTargetID("gh-421-database-checkpoint")
        )
        try checkpoint.apply(foundationEnvelope)
        XCTAssertEqual(checkpoint.lastAppliedSequence, 1)
        XCTAssertTrue(checkpoint.ownsDatabaseSourceRoot)

        let symbol = try Symbol(rawValue: "BTCUSDT")
        let timeframe = Timeframe.oneMinute
        let dataSource = try DataClientReadOnlyMarketDataSource(
            sourceID: sourceID,
            venue: .binance,
            symbol: symbol,
            timeframe: timeframe,
            datasetVersion: "gh-421"
        )
        XCTAssertTrue(dataSource.publicReadOnlyBoundaryHeld)

        let marketStream = try MessageBusJournalStreamID("gh421.market")
        var journal = try MessageBusAppendOnlyJournal()
        let marketEnvelope = try journal.append(
            stream: marketStream,
            sourceID: sourceID,
            payloadType: "market.bar",
            recordedAt: Date(timeIntervalSince1970: 422)
        )
        XCTAssertEqual(journal.replay(stream: marketStream), [marketEnvelope])

        var cacheSnapshot = CacheReadModelSnapshot(
            snapshotID: try FoundationTargetID("gh-421-cache"),
            stream: marketStream,
            symbol: symbol
        )
        try cacheSnapshot.apply(marketEnvelope)
        XCTAssertEqual(cacheSnapshot.appliedEventCount, 1)
        XCTAssertTrue(cacheSnapshot.readModelBoundaryHeld)

        let replayPlan = DataEngineReadOnlyReplayPlan(
            planID: try FoundationTargetID("gh-421-dataengine-plan"),
            source: dataSource,
            stream: marketStream,
            cacheSnapshot: cacheSnapshot
        )
        XCTAssertTrue(replayPlan.ingestReplayQualityBoundaryHeld)
        XCTAssertTrue(replayPlan.payloadType.contains("dataengine.public-market-data.binance.BTCUSDT.1m"))

        let bars = try (0..<5).map { index in
            let start = Date(timeIntervalSince1970: Double(index * 60))
            return try MarketBar(
                symbol: symbol,
                timeframe: timeframe,
                interval: try DateRange(start: start, end: start.addingTimeInterval(60)),
                open: 100 + Double(index),
                high: 101 + Double(index),
                low: 99 + Double(index),
                close: 100 + Double(index),
                volume: 1 + Double(index)
            )
        }
        let emaConfig = try EMACrossStrategyConfiguration(
            strategyID: try Identifier("gh-421-ema"),
            symbol: symbol,
            timeframe: timeframe,
            shortPeriod: 2,
            longPeriod: 3
        )
        let emaSamples = try EMACrossStrategyContract(configuration: emaConfig).evaluate(bars)
        XCTAssertFalse(emaSamples.isEmpty)
        let signal = try XCTUnwrap(emaSamples.last?.signal)
        XCTAssertEqual(signal.strategyID, emaConfig.strategyID)

        let traderAccount = TraderAccountContext.deterministicFixture
        XCTAssertTrue(traderAccount.accountContextBoundaryHeld)
        XCTAssertFalse(traderAccount.futureRealAccountGate.authorizesRealAccountRead)

        let sizing = try PaperActionProposalSizingAssumption(
            assumptionID: try Identifier("gh-421-sizing"),
            quantity: try Quantity(0.1, field: "gh421.quantity"),
            referencePrice: try Price(100, field: "gh421.referencePrice"),
            liquidityRole: .maker
        )
        let proposal = try PaperActionProposal(
            proposalID: try Identifier("gh-421-proposal"),
            sessionID: try Identifier("gh-421-session"),
            signal: signal,
            sizingAssumption: sizing,
            proposedAt: Date(timeIntervalSince1970: 423)
        )
        XCTAssertFalse(proposal.isExecutableAsRealOrder)

        let exposure = PortfolioExposureSnapshot(
            portfolioID: try Identifier("gh-421-portfolio"),
            symbol: symbol,
            timeframe: timeframe,
            paperQuantity: try Quantity(0.1, field: "gh421.paperQuantity"),
            referencePrice: try Price(100, field: "gh421.exposurePrice"),
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 424)
        )
        let financialProjection = try PortfolioFinancialStateProjection(
            projectionID: try Identifier("gh-421-financial-projection"),
            exposure: exposure,
            projectedAt: Date(timeIntervalSince1970: 424)
        )
        XCTAssertTrue(financialProjection.paperOnlyBoundaryHeld)
        XCTAssertEqual(financialProjection.exposure.grossExposureNotional, 10)

        let riskDecision = try RiskEnginePreTradeOwnershipEvaluator.evaluate(
            decisionID: try Identifier("gh-421-risk-decision"),
            proposal: proposal,
            portfolioExposure: exposure,
            riskProfileID: try Identifier("gh-421-risk-profile"),
            maxPaperNotional: 10_000,
            sourceSequence: marketEnvelope.sequence,
            evaluatedAt: Date(timeIntervalSince1970: 425)
        )
        XCTAssertTrue(riskDecision.boundaryHeld)
        XCTAssertTrue(riskDecision.isAllowed)
        XCTAssertFalse(riskDecision.touchesExecutionClient)

        let executionClient = ExecutionClientTargetBoundary.mtp220
        XCTAssertTrue(executionClient.futureGateOnly)
        XCTAssertFalse(executionClient.implementsBrokerGateway)
        XCTAssertFalse(executionClient.implementsOrderSubmitCancelReplace)

        let executionHandoff = try ExecutionEnginePaperOwnershipEvaluator.handoff(
            handoffID: try Identifier("gh-421-execution-handoff"),
            riskDecision: riskDecision
        )
        XCTAssertTrue(executionHandoff.boundaryHeld)
        XCTAssertTrue(executionHandoff.acceptedForPaperLifecycle)
        XCTAssertFalse(executionHandoff.submitsRealOrder)

        let dashboard = DashboardTargetBoundary.gh420
        XCTAssertTrue(dashboard.dependencyDirectionHeld)
        XCTAssertTrue(dashboard.consumesReadModelOnly)
        XCTAssertFalse(dashboard.providesLiveCommand)
    }

    func testGH398TraderPortfolioRiskExecutionTargetsOwnRealSourceWithoutRuntimeDrift() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let portfolioTarget = try packageTargetBlock(named: "Portfolio", packageSource: packageSource)
        let riskEngineTarget = try packageTargetBlock(named: "RiskEngine", packageSource: packageSource)
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let portfolioSources = try packageTargetSourcesBlock(targetBlock: portfolioTarget)
        let riskEngineSources = try packageTargetSourcesBlock(targetBlock: riskEngineTarget)
        let executionEngineSources = try packageTargetSourcesBlock(targetBlock: executionEngineTarget)
        let coreSources = try packageTargetSourcesBlock(targetBlock: coreTarget)
        let portfolioExcludes = try packageTargetExcludesBlock(targetBlock: portfolioTarget)
        let coreExcludes = try packageTargetExcludesBlock(targetBlock: coreTarget)

        XCTAssertTrue(portfolioSources.contains("\"PaperPortfolioProjectionUpdate.swift\""))
        XCTAssertTrue(portfolioSources.contains("\"PortfolioFinancialStateProjection.swift\""))
        XCTAssertFalse(portfolioSources.contains("PaperAccountPortfolioProjectionV2.swift"))
        XCTAssertFalse(portfolioSources.contains("SimulatedExchangePortfolioProjectionParity.swift"))
        XCTAssertTrue(portfolioExcludes.contains("\"PaperAccountPortfolioProjectionV2.swift\""))
        XCTAssertTrue(portfolioExcludes.contains("\"SimulatedExchangePortfolioProjectionParity.swift\""))
        XCTAssertTrue(riskEngineSources.contains("\"PreTrade/PaperPreTradeRiskEngine.swift\""))
        XCTAssertTrue(riskEngineSources.contains("\"PreTrade/RiskEnginePreTradeOwnership.swift\""))
        XCTAssertTrue(executionEngineSources.contains("\"Ownership\""))
        XCTAssertTrue(executionEngineSources.contains("\"PaperLifecycle/PaperExecutionWorkflowContract.swift\""))
        XCTAssertTrue(executionEngineSources.contains("\"PaperLifecycle/PaperRuntimeKernelBoundary.swift\""))
        XCTAssertTrue(executionEngineSources.contains("\"PaperLifecycle/PaperSessionLocalControlCommand.swift\""))
        XCTAssertTrue(executionEngineSources.contains("\"SimulatedExchange/SimulatedExchangeBacktestParityBoundary.swift\""))
        XCTAssertTrue(coreExcludes.contains("\"Portfolio/PaperPortfolioProjectionUpdate.swift\""))
        XCTAssertFalse(coreSources.contains("\"Portfolio/PaperPortfolioProjectionUpdate.swift\""))
        XCTAssertTrue(coreSources.contains("\"Portfolio/PaperAccountPortfolioProjectionV2.swift\""))
        XCTAssertTrue(coreSources.contains("\"Portfolio/SimulatedExchangePortfolioProjectionParity.swift\""))
        XCTAssertTrue(coreExcludes.contains("\"RiskEngine/PreTrade/PaperPreTradeRiskEngine.swift\""))
        XCTAssertFalse(coreSources.contains("\"RiskEngine/PreTrade/PaperPreTradeRiskEngine.swift\""))
        XCTAssertFalse(executionEngineSources.contains("\"PaperLifecycle\""))
        XCTAssertFalse(executionEngineSources.contains("\"SimulatedExchange\""))
        XCTAssertTrue(coreExcludes.contains("\"ExecutionEngine/PaperLifecycle/PaperExecutionWorkflowContract.swift\""))
        XCTAssertTrue(coreExcludes.contains("\"ExecutionEngine/PaperLifecycle/PaperRuntimeKernelBoundary.swift\""))
        XCTAssertTrue(coreExcludes.contains("\"ExecutionEngine/PaperLifecycle/PaperSessionLocalControlCommand.swift\""))
        XCTAssertTrue(coreExcludes.contains("\"ExecutionEngine/SimulatedExchange/SimulatedExchangeBacktestParityBoundary.swift\""))
        XCTAssertTrue(coreSources.contains("\"ExecutionEngine/PaperLifecycle\""))
        XCTAssertTrue(coreSources.contains("\"ExecutionEngine/SimulatedExchange\""))

        let proposal = try PaperActionProposalFixture.deterministicLong()
        let exposure = PortfolioExposureSnapshot(
            portfolioID: try Identifier("gh-398-paper-portfolio"),
            symbol: proposal.symbol,
            timeframe: proposal.timeframe,
            paperQuantity: try Quantity(0.1, field: "gh398.paperQuantity"),
            referencePrice: proposal.referencePrice,
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 398)
        )
        let financialProjection = try PortfolioFinancialStateProjection(
            projectionID: try Identifier("gh-398-portfolio-financial-state"),
            exposure: exposure,
            projectedAt: Date(timeIntervalSince1970: 398)
        )
        XCTAssertTrue(financialProjection.paperOnlyBoundaryHeld)
        XCTAssertEqual(financialProjection.exposure.grossExposureNotional, exposure.grossExposureNotional)

        let projectionUpdate = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("gh-416-portfolio-projection-update"),
            decisionID: try Identifier("gh-416-risk-decision"),
            orderID: try Identifier("gh-416-order"),
            fillID: try Identifier("gh-416-fill"),
            proposalID: proposal.proposalID,
            sessionID: try Identifier("gh-416-session"),
            riskProfileID: try Identifier("gh-416-risk-profile"),
            side: proposal.side,
            riskDecisionStatus: .allowed,
            exposure: exposure,
            executionMode: .paper,
            sourceSequence: 416,
            sourceOrderIntentSequence: 414,
            sourceRiskDecisionSequence: 415,
            updatedAt: exposure.observedAt,
            usesSimulatedFillEvidence: true,
            authorizesTradingExecution: false,
            readsRealAccountBalance: false,
            syncsBrokerPosition: false
        )
        XCTAssertEqual(projectionUpdate.portfolioID, exposure.portfolioID)
        XCTAssertFalse(projectionUpdate.authorizesTradingExecution)
        XCTAssertFalse(projectionUpdate.readsRealAccountBalance)
        XCTAssertFalse(projectionUpdate.syncsBrokerPosition)

        let riskDecision = try RiskEnginePreTradeOwnershipEvaluator.evaluate(
            decisionID: try Identifier("gh-398-risk-decision"),
            proposal: proposal,
            portfolioExposure: exposure,
            riskProfileID: try Identifier("gh-398-risk-profile"),
            maxPaperNotional: 10_000,
            sourceSequence: 399,
            evaluatedAt: Date(timeIntervalSince1970: 399)
        )
        XCTAssertTrue(riskDecision.boundaryHeld)
        XCTAssertTrue(riskDecision.isAllowed)
        XCTAssertFalse(riskDecision.touchesExecutionEngine)
        XCTAssertFalse(riskDecision.touchesExecutionClient)
        XCTAssertFalse(riskDecision.authorizesLiveTrading)

        let paperPreTradeDecision = try PaperPreTradeRiskEngine().evaluate(
            decisionID: try Identifier("gh-417-riskengine-paper-pretrade-decision"),
            input: try PaperPreTradeRiskEngineFixture.acceptedInput()
        )
        XCTAssertTrue(paperPreTradeDecision.isAccepted)
        XCTAssertTrue(paperPreTradeDecision.paperOnlyBoundaryHeld)
        XCTAssertFalse(paperPreTradeDecision.providesLiveRiskEngine)
        XCTAssertFalse(paperPreTradeDecision.runsRealPreTradeAllowReject)

        let executionHandoff = try ExecutionEnginePaperOwnershipEvaluator.handoff(
            handoffID: try Identifier("gh-398-execution-handoff"),
            riskDecision: riskDecision
        )
        XCTAssertTrue(executionHandoff.boundaryHeld)
        XCTAssertTrue(executionHandoff.acceptedForPaperLifecycle)
        XCTAssertFalse(executionHandoff.touchesExecutionClient)
        XCTAssertFalse(executionHandoff.touchesOMS)
        XCTAssertFalse(executionHandoff.touchesBrokerGateway)
        XCTAssertFalse(executionHandoff.submitsRealOrder)

        let workflow = PaperExecutionWorkflowContract.deterministicFixture
        XCTAssertEqual(workflow.stageOrder, PaperExecutionWorkflowStage.allCases)
        XCTAssertTrue(workflow.paperOnlyBoundaryHeld)

        let runtimeKernel = PaperRuntimeKernelBoundary.deterministicFixture
        XCTAssertTrue(runtimeKernel.paperOnlyBoundaryHeld)
        XCTAssertFalse(runtimeKernel.connectsBroker)
        XCTAssertFalse(runtimeKernel.usesSignedEndpoint)

        let localControl = try PaperSessionLocalControlCommandFixture.deterministic(control: .pause)
        XCTAssertTrue(localControl.paperOnlyBoundaryHeld)
        XCTAssertFalse(localControl.submitsRealOrder)

        let simulatedParity = SimulatedExchangeBacktestParityBoundary.deterministicFixture
        XCTAssertTrue(simulatedParity.terminologyBoundaryHeld)
        XCTAssertFalse(simulatedParity.implementsOrderExecutionRuntime)
        XCTAssertFalse(simulatedParity.implementsOMS)
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
            "\"PaperWorkflowDashboardArchitecture.swift\"",
            "\"DashboardBetaAcceptancePath.swift\"",
            "\"DashboardBetaFirstRunState.swift\"",
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
            "Sources/Dashboard/FutureLiveProConsole/LiveReadOnlyDashboardBoundary.swift",
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

    func testGH420DashboardActiveSourceUsesDashboardReadModelOnlyNaming() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let dashboard = DashboardTargetBoundary.gh420
        let dashboardFiles = try swiftFiles(under: repositoryRoot, relativeRoots: ["Sources/Dashboard"])

        XCTAssertTrue(dashboard.dependencyDirectionHeld)
        XCTAssertTrue(dashboard.validationAnchors.contains("GH-420-DASHBOARD-ACTIVE-SOURCE-NAMING-CLEAN"))
        XCTAssertFalse(dashboardFiles.isEmpty, "Dashboard source root must contain Swift files")
        for file in dashboardFiles {
            let source = try String(contentsOf: file, encoding: .utf8)
            XCTAssertFalse(source.contains("Workbench"), "\(file.path) must not use active Workbench naming")
            XCTAssertFalse(source.contains("workbench"), "\(file.path) must not use active workbench naming")
        }

        let coreLiveBoundary = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/Core/LiveTradingBoundary.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(coreLiveBoundary.contains("public typealias LiveReadOnlyDashboardReadModelBoundary"))
        XCTAssertTrue(coreLiveBoundary.contains("dashboardReadModelOnlyBoundaryHeld"))

        let betaAcceptanceSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/Dashboard/DashboardBetaAcceptancePath.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(betaAcceptanceSource.contains("mtp-122-dashboard-beta-acceptance-path"))
        XCTAssertFalse(betaAcceptanceSource.contains("mtp-122-workbench-beta-acceptance-path"))
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

    func testGH400TryBangPreconditionFailureAndFatalErrorStayInAllowedConstructs() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let scannedFiles = try swiftFiles(
            under: repositoryRoot,
            relativeRoots: ["Sources", "Tests"]
        )

        let violations = try scannedFiles.flatMap { file in
            try unsafeConstructOccurrences(in: file, repositoryRoot: repositoryRoot).filter { occurrence in
                !isAllowedUnsafeConstructOccurrence(occurrence)
            }
        }

        XCTAssertTrue(
            violations.isEmpty,
            """
            GH-400 unsafe construct guard failed.
            try!, preconditionFailure, and fatalError are only allowed in tests, deterministic .constant(...) \
            helpers, or production fixture/evidence/contract/boundary builders with explicit markers. Violations:
            \(violations.map(\.description).joined(separator: "\n"))
            """
        )
    }

    func testGH496UnsafeConstructGuardRejectsRuntimeFacingCrashPaths() {
        let runtimePreconditionFailure = UnsafeConstructOccurrence(
            relativePath: "Sources/ExecutionEngine/Runtime/LiveOrderRouter.swift",
            lineNumber: 42,
            construct: "preconditionFailure",
            line: "preconditionFailure(\"live order router failed\")",
            context: "func submitLiveOrder() { preconditionFailure(\"live order router failed\") }"
        )
        let runtimeFatalError = UnsafeConstructOccurrence(
            relativePath: "Sources/Trader/Runtime/TraderRuntime.swift",
            lineNumber: 27,
            construct: "fatalError",
            line: "fatalError(\"trader runtime not configured\")",
            context: "func startRuntime() { fatalError(\"trader runtime not configured\") }"
        )
        let runtimeForceTry = UnsafeConstructOccurrence(
            relativePath: "Sources/RiskEngine/Runtime/LiveRiskRuntime.swift",
            lineNumber: 19,
            construct: "try!",
            line: "let decision = try! evaluateLiveRisk()",
            context: "func evaluate() { let decision = try! evaluateLiveRisk() }"
        )

        XCTAssertFalse(isAllowedUnsafeConstructOccurrence(runtimePreconditionFailure))
        XCTAssertFalse(isAllowedUnsafeConstructOccurrence(runtimeFatalError))
        XCTAssertFalse(isAllowedUnsafeConstructOccurrence(runtimeForceTry))
    }

    func testGH497FutureGateBuilderHelpersAreNotPublicSurface() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let scopedFiles = [
            "Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxVenueAdapter.swift",
            "Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxReportParser.swift"
        ]
        let forbiddenPublicHelpers = [
            "public static func deterministicEnvelope(",
            "public static func deterministicFixtures()"
        ]

        let violations = try scopedFiles.flatMap { relativePath -> [String] in
            let source = try String(
                contentsOf: repositoryRoot.appendingPathComponent(relativePath),
                encoding: .utf8
            )
            return forbiddenPublicHelpers.compactMap { helper in
                source.contains(helper) ? "\(relativePath): \(helper)" : nil
            }
        }

        XCTAssertTrue(
            violations.isEmpty,
            """
            GH-497 FutureGate builder/helper functions must stay internal unless Dashboard or tests \
            need them as read-model contract surface.
            Violations:
            \(violations.joined(separator: "\n"))
            """
        )
    }

    func testGH522ReleaseV010OwnershipGapsAreRetiredOrExplicitlyDeferred() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md"
            ),
            encoding: .utf8
        )

        for anchor in [
            "GH-522-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT",
            "GH-522-RELEASE-OWNERSHIP-AUTHORITY",
            "GH-522-COMPATIBILITY-ENVELOPE-MATRIX",
            "GH-522-DEFERRED-OWNERSHIP-REGISTER",
            "GH-522-NO-PRODUCTION-AUTHORIZATION",
            "TVM-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT"
        ] {
            XCTAssertTrue(releaseContract.contains(anchor), "\(anchor) must remain documented")
        }

        let dataClientTarget = try packageTargetBlock(named: "DataClient", packageSource: packageSource)
        let dataEngineTarget = try packageTargetBlock(named: "DataEngine", packageSource: packageSource)
        let adaptersTarget = try packageTargetBlock(named: "Adapters", packageSource: packageSource)
        let persistenceTarget = try packageTargetBlock(named: "Persistence", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)
        let dataClientSources = try packageTargetSourcesBlock(targetBlock: dataClientTarget)
        let dataEngineExcludes = try packageTargetExcludesBlock(targetBlock: dataEngineTarget)
        let adaptersSources = try packageTargetSourcesBlock(targetBlock: adaptersTarget)
        let persistenceSources = try packageTargetSourcesBlock(targetBlock: persistenceTarget)
        let runtimeSources = try packageTargetSourcesBlock(targetBlock: runtimeTarget)

        XCTAssertTrue(dataClientSources.contains("\"Binance/PublicMarketData/Adapters.swift\""))
        XCTAssertTrue(dataClientSources.contains("\"DataClientReadOnlyMarketDataSource.swift\""))
        XCTAssertTrue(dataEngineExcludes.contains("\"Ingest\""))
        XCTAssertTrue(adaptersSources.contains("\"AdaptersCompatibility.swift\""))
        XCTAssertFalse(adaptersSources.contains("\"Binance/PublicMarketData/Adapters.swift\""))
        XCTAssertTrue(persistenceSources.contains("\"Projections/SQLite/Persistence.swift\""))
        XCTAssertTrue(persistenceSources.contains("\"Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift\""))
        XCTAssertTrue(runtimeSources.contains("\"Database/ReplayProjection\""))
        XCTAssertTrue(runtimeSources.contains("\"DataEngine/Ingest\""))

        for requiredDecision in [
            "Runtime -> DataEngine/Ingest",
            "Runtime -> Database/ReplayProjection",
            "Persistence -> Database/Projections",
            "Core -> LiveTradingBoundary / LiveMonitoring*"
        ] {
            XCTAssertTrue(releaseContract.contains(requiredDecision), "\(requiredDecision) must be deferred")
        }

        for forbiddenDefault in [
            "productionTradingEnabledByDefault == false",
            "productionSecretReadEnabledByDefault == false",
            "productionEndpointConnectionEnabledByDefault == false",
            "productionOrderSubmitEnabledByDefault == false",
            "nonBinanceVenueEnabled == false",
            "nonEMAStrategyEnabled == false"
        ] {
            XCTAssertTrue(releaseContract.contains(forbiddenDefault), "\(forbiddenDefault) must remain explicit")
        }
    }

    func testGH523ReleaseV010TargetsExposeRealSmokeCoverage() throws {
        let sourceID = try FoundationTargetID("gh-523-release-source")
        let domainOwnership = FoundationTargetSourceOwnership.domainModel(ownerID: sourceID)
        XCTAssertEqual(domainOwnership.targetName, "DomainModel")
        XCTAssertTrue(domainOwnership.ownsRealModuleSourceRoot)

        let topic = try FoundationMessageTopic("gh523.release")
        var foundationStream = try FoundationMessageStream()
        let foundationEnvelope = try foundationStream.publish(
            topic: topic,
            sourceID: sourceID,
            recordedAt: Date(timeIntervalSince1970: 523)
        )
        XCTAssertEqual(foundationStream.replay(topic: topic), [foundationEnvelope])

        var checkpoint = try FoundationDatabaseCheckpoint(
            checkpointID: try FoundationTargetID("gh-523-database-checkpoint")
        )
        try checkpoint.apply(foundationEnvelope)
        XCTAssertEqual(checkpoint.lastAppliedSequence, 1)
        XCTAssertTrue(checkpoint.ownsDatabaseSourceRoot)

        let symbol = try Symbol(rawValue: "BTCUSDT")
        let timeframe = Timeframe.oneMinute
        let dataSource = try DataClientReadOnlyMarketDataSource(
            sourceID: sourceID,
            venue: .binance,
            symbol: symbol,
            timeframe: timeframe,
            datasetVersion: "gh-523"
        )
        XCTAssertTrue(dataSource.publicReadOnlyBoundaryHeld)

        let marketStream = try MessageBusJournalStreamID("gh523.market")
        var journal = try MessageBusAppendOnlyJournal()
        let marketEnvelope = try journal.append(
            stream: marketStream,
            sourceID: sourceID,
            payloadType: "market.bar",
            recordedAt: Date(timeIntervalSince1970: 524)
        )
        var cacheSnapshot = CacheReadModelSnapshot(
            snapshotID: try FoundationTargetID("gh-523-cache"),
            stream: marketStream,
            symbol: symbol
        )
        try cacheSnapshot.apply(marketEnvelope)
        XCTAssertEqual(cacheSnapshot.appliedEventCount, 1)
        XCTAssertTrue(cacheSnapshot.readModelBoundaryHeld)

        let replayPlan = DataEngineReadOnlyReplayPlan(
            planID: try FoundationTargetID("gh-523-dataengine-plan"),
            source: dataSource,
            stream: marketStream,
            cacheSnapshot: cacheSnapshot
        )
        XCTAssertTrue(replayPlan.ingestReplayQualityBoundaryHeld)
        XCTAssertTrue(replayPlan.payloadType.contains("dataengine.public-market-data.binance.BTCUSDT.1m"))

        let bars = try (0..<5).map { index in
            let start = Date(timeIntervalSince1970: Double(index * 60))
            return try MarketBar(
                symbol: symbol,
                timeframe: timeframe,
                interval: try DateRange(start: start, end: start.addingTimeInterval(60)),
                open: 100 + Double(index),
                high: 101 + Double(index),
                low: 99 + Double(index),
                close: 100 + Double(index),
                volume: 1 + Double(index)
            )
        }
        let emaConfig = try EMACrossStrategyConfiguration(
            strategyID: try Identifier("gh-523-ema"),
            symbol: symbol,
            timeframe: timeframe,
            shortPeriod: 2,
            longPeriod: 3
        )
        let emaSamples = try EMACrossStrategyContract(configuration: emaConfig).evaluate(bars)
        let signal = try XCTUnwrap(emaSamples.last?.signal)
        XCTAssertEqual(signal.strategyID, emaConfig.strategyID)

        let traderAccount = TraderAccountContext.deterministicFixture
        XCTAssertTrue(traderAccount.accountContextBoundaryHeld)
        XCTAssertFalse(traderAccount.futureRealAccountGate.authorizesRealAccountRead)

        let sizing = try PaperActionProposalSizingAssumption(
            assumptionID: try Identifier("gh-523-sizing"),
            quantity: try Quantity(0.1, field: "gh523.quantity"),
            referencePrice: try Price(100, field: "gh523.referencePrice"),
            liquidityRole: .maker
        )
        let proposal = try PaperActionProposal(
            proposalID: try Identifier("gh-523-proposal"),
            sessionID: try Identifier("gh-523-session"),
            signal: signal,
            sizingAssumption: sizing,
            proposedAt: Date(timeIntervalSince1970: 525)
        )
        XCTAssertFalse(proposal.isExecutableAsRealOrder)

        let exposure = PortfolioExposureSnapshot(
            portfolioID: try Identifier("gh-523-portfolio"),
            symbol: symbol,
            timeframe: timeframe,
            paperQuantity: try Quantity(0.1, field: "gh523.paperQuantity"),
            referencePrice: try Price(100, field: "gh523.exposurePrice"),
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 526)
        )
        let financialProjection = try PortfolioFinancialStateProjection(
            projectionID: try Identifier("gh-523-financial-projection"),
            exposure: exposure,
            projectedAt: Date(timeIntervalSince1970: 526)
        )
        XCTAssertTrue(financialProjection.paperOnlyBoundaryHeld)
        XCTAssertEqual(financialProjection.exposure.grossExposureNotional, 10)

        let riskDecision = try RiskEnginePreTradeOwnershipEvaluator.evaluate(
            decisionID: try Identifier("gh-523-risk-decision"),
            proposal: proposal,
            portfolioExposure: exposure,
            riskProfileID: try Identifier("gh-523-risk-profile"),
            maxPaperNotional: 10_000,
            sourceSequence: marketEnvelope.sequence,
            evaluatedAt: Date(timeIntervalSince1970: 527)
        )
        XCTAssertTrue(riskDecision.boundaryHeld)
        XCTAssertTrue(riskDecision.isAllowed)
        XCTAssertFalse(riskDecision.touchesExecutionClient)

        let executionHandoff = try ExecutionEnginePaperOwnershipEvaluator.handoff(
            handoffID: try Identifier("gh-523-execution-handoff"),
            riskDecision: riskDecision
        )
        XCTAssertTrue(executionHandoff.boundaryHeld)
        XCTAssertTrue(executionHandoff.acceptedForPaperLifecycle)
        XCTAssertFalse(executionHandoff.submitsRealOrder)

        let venueContract = try L4ExecutionClientVenueAdapterContract.deterministicFixture()
        XCTAssertTrue(venueContract.contractHeld)
        XCTAssertTrue(venueContract.operationCoverageHeld)

        let dashboard = DashboardTargetBoundary.gh420
        XCTAssertTrue(dashboard.dependencyDirectionHeld)
        XCTAssertTrue(dashboard.consumesReadModelOnly)
        XCTAssertFalse(dashboard.providesLiveCommand)
    }

    func testGH524BinancePublicMarketDataRuntimePathProjectsIntoCacheReadModel() async throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let dataEngineTarget = try packageTargetBlock(named: "DataEngine", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)
        XCTAssertTrue(
            try packageTargetSourcesBlock(targetBlock: dataEngineTarget)
                .contains("\"BinancePublicMarketDataRuntimePath.swift\"")
        )
        XCTAssertTrue(
            try packageTargetExcludesBlock(targetBlock: coreTarget)
                .contains("\"DataEngine/BinancePublicMarketDataRuntimePath.swift\"")
        )
        XCTAssertTrue(
            try packageTargetExcludesBlock(targetBlock: runtimeTarget)
                .contains("\"DataEngine/BinancePublicMarketDataRuntimePath.swift\"")
        )

        let symbol = try Symbol(rawValue: "BTCUSDT")
        let range = try DateRange(
            start: Date(timeIntervalSince1970: 1_704_067_200),
            end: Date(timeIntervalSince1970: 1_704_067_260)
        )
        let transport = TargetGraphMockBinancePublicMarketDataTransport { request in
            switch request.contract.capability {
            case .klines:
                Data(
                    #"""
                    [
                      [
                        1704067200000,
                        "42000.10",
                        "42100.20",
                        "41900.30",
                        "42050.40",
                        "12.345",
                        1704067259999,
                        "519000.00",
                        120,
                        "6.000",
                        "252000.00",
                        "0"
                      ]
                    ]
                    """#.utf8
                )
            case .recentTrades:
                Data(
                    #"""
                    [
                      {
                        "id": 1,
                        "price": "42010.50",
                        "qty": "0.125",
                        "time": 1704067201000,
                        "isBuyerMaker": true,
                        "isBestMatch": true
                      }
                    ]
                    """#.utf8
                )
            case .bestBidAsk:
                Data(
                    #"""
                    {
                      "symbol": "BTCUSDT",
                      "bidPrice": "42009.90",
                      "bidQty": "1.500",
                      "askPrice": "42010.10",
                      "askQty": "1.250"
                    }
                    """#.utf8
                )
            case .depthSnapshot:
                Data(
                    #"""
                    {
                      "lastUpdateId": 100,
                      "bids": [["42000.00", "1.100"]],
                      "asks": [["42001.00", "0.900"]]
                    }
                    """#.utf8
                )
            case .depthDelta:
                Data(
                    #"""
                    {
                      "e": "depthUpdate",
                      "E": 1704067203000,
                      "s": "BTCUSDT",
                      "U": 101,
                      "u": 102,
                      "b": [["42000.20", "0.400"]],
                      "a": [["42001.20", "0.000"]]
                    }
                    """#.utf8
                )
            case .exchangeInfo:
                Data(#"{"symbols":[]}"#.utf8)
            }
        }
        let client = BinancePublicMarketDataClient(transport: transport)
        let plan = try BinancePublicMarketDataRuntimePlan(
            sourceID: try FoundationTargetID("gh-524-binance-public-source"),
            symbol: symbol,
            timeframe: .oneMinute,
            range: range,
            datasetVersion: "gh-524",
            klineLimit: 1,
            recentTradeLimit: 1,
            depthSnapshotLimit: .oneHundred,
            bestBidAskObservedAt: Date(timeIntervalSince1970: 1_704_067_202),
            depthSnapshotObservedAt: Date(timeIntervalSince1970: 1_704_067_204),
            firstRecordedAt: Date(timeIntervalSince1970: 1_704_067_210)
        )

        let result = try await BinancePublicMarketDataRuntimePath(client: client).run(plan)

        XCTAssertEqual(result.marketEvents.count, 5)
        XCTAssertEqual(result.eventEnvelopes.map(\.sequence), [1, 2, 3, 4, 5])
        XCTAssertEqual(result.replayedEnvelopes, result.eventEnvelopes)
        XCTAssertEqual(result.cacheSnapshot, result.replayedCacheSnapshot)
        XCTAssertEqual(result.cacheSnapshot.marketEventCount, 5)
        XCTAssertTrue(result.publicMarketDataRuntimePathBoundaryHeld)
        XCTAssertFalse(result.callsSignedEndpoint)
        XCTAssertFalse(result.callsAccountEndpoint)
        XCTAssertFalse(result.createsListenKey)
        XCTAssertFalse(result.connectsPrivateWebSocketRuntime)
        XCTAssertFalse(result.routesBrokerOrExecutionCommand)
        XCTAssertFalse(result.enablesProductionTrading)

        let seriesKey = MarketDataSeriesKey(symbol: symbol, timeframe: .oneMinute)
        XCTAssertEqual(result.cacheSnapshot.barsBySeries[seriesKey]?.count, 1)
        XCTAssertEqual(result.cacheSnapshot.tradesBySymbol[symbol]?.count, 1)
        XCTAssertEqual(result.cacheSnapshot.bestBidAskBySymbol[symbol]?.bid.price.rawValue, 42_009.90)
        XCTAssertEqual(result.cacheSnapshot.orderBookSnapshotsBySymbol[symbol]?.bids.count, 1)
        XCTAssertEqual(result.cacheSnapshot.orderBookDeltasBySymbol[symbol]?.count, 1)

        let requests = await transport.requests()
        XCTAssertEqual(requests.map(\.contract.path), result.requestedPublicPaths)
        XCTAssertEqual(
            result.requestedPublicPaths,
            ["/api/v3/klines", "/api/v3/trades", "/api/v3/ticker/bookTicker", "/api/v3/depth", "/ws/btcusdt@depth"]
        )
        XCTAssertTrue(requests.allSatisfy { $0.method == "GET" })
        XCTAssertTrue(requests.allSatisfy { $0.headers.isEmpty })
        assertNoForbiddenBinancePublicRequestFragments(
            result.publicRequestContracts,
            file: #filePath,
            line: #line
        )
    }

    func testGH525BinanceSignedAccountReadRuntimeMapsCanonicalSnapshotWithoutCommandSurface() async throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let dataClientTarget = try packageTargetBlock(named: "DataClient", packageSource: packageSource)
        XCTAssertTrue(dataClientTarget.contains(".product(name: \"Crypto\", package: \"swift-crypto\")"))
        XCTAssertTrue(dataClientTarget.contains("\"Binance/SignedAccount/BinanceSignedAccountReadRuntime.swift\""))

        XCTAssertThrowsError(
            try BinanceSignedAccountReadClientConfiguration(
                baseURL: try XCTUnwrap(URL(string: "https://api.binance.com"))
            )
        ) { error in
            XCTAssertEqual(
                error as? BinanceSignedAccountReadRuntimeError,
                .productionEndpointForbidden("api.binance.com")
            )
        }

        let material = try BinanceSignedAccountCredentialMaterial(
            referenceID: "gh-525-fixture-credential",
            keyHeaderValue: "fixture-key",
            signingSecretValue: "fixture-secret"
        )
        let timestamp = Date(timeIntervalSince1970: 1_704_067_200)
        let configuration = try BinanceSignedAccountReadClientConfiguration(receiveWindowMilliseconds: 5_000)
        let transport = TargetGraphMockBinanceSignedAccountReadTransport { request in
            XCTAssertEqual(request.environment, .testnet)
            XCTAssertEqual(request.method, "GET")
            XCTAssertEqual(request.path, "/api/v3/account")
            XCTAssertEqual(request.headers[BinanceSignedAccountReadTransportRequest.binanceKeyHeaderName], "fixture-key")
            XCTAssertEqual(request.credentialReference, "gh-525-fixture-credential")
            XCTAssertTrue(request.unsignedQueryString.contains("timestamp=1704067200000"))
            XCTAssertTrue(request.unsignedQueryString.contains("recvWindow=5000"))
            XCTAssertTrue(request.url.absoluteString.contains("signature="))
            XCTAssertFalse(request.url.absoluteString.contains("fixture-secret"))
            XCTAssertFalse(request.url.absoluteString.contains("/api/v3/order"))
            XCTAssertFalse(request.url.absoluteString.lowercased().contains("listenkey"))
            return Data(
                #"""
                {
                  "makerCommission": 15,
                  "takerCommission": 15,
                  "buyerCommission": 0,
                  "sellerCommission": 0,
                  "canTrade": true,
                  "canWithdraw": false,
                  "canDeposit": true,
                  "updateTime": 1704067205000,
                  "accountType": "SPOT",
                  "balances": [
                    { "asset": "BTC", "free": "0.10000000", "locked": "0.00000000" },
                    { "asset": "USDT", "free": "1000.50000000", "locked": "10.00000000" }
                  ],
                  "permissions": ["SPOT"]
                }
                """#.utf8
            )
        }
        let client = BinanceSignedAccountReadClient(
            configuration: configuration,
            credentialProvider: BinanceStaticSignedAccountCredentialProvider(material: material),
            transport: transport
        )

        let request = try client.transportRequest(timestamp: timestamp, credential: material)
        XCTAssertEqual(
            request.url.query?.contains("signature=\(material.signature(for: request.unsignedQueryString))"),
            true
        )

        let snapshot = try await client.accountSnapshot(timestamp: timestamp)

        XCTAssertEqual(snapshot.accountType, "SPOT")
        XCTAssertTrue(snapshot.canTrade)
        XCTAssertFalse(snapshot.canWithdraw)
        XCTAssertTrue(snapshot.canDeposit)
        XCTAssertEqual(try XCTUnwrap(snapshot.updateTime).timeIntervalSince1970, 1_704_067_205, accuracy: 0.001)
        XCTAssertEqual(snapshot.balances.map(\.asset), ["BTC", "USDT"])
        XCTAssertEqual(snapshot.balances.first?.free, Decimal(string: "0.10000000"))
        XCTAssertEqual(snapshot.balances.last?.total, Decimal(string: "1010.50000000"))
        XCTAssertEqual(snapshot.credentialReference, "gh-525-fixture-credential")
        XCTAssertTrue(snapshot.snapshotBoundaryHeld)
        XCTAssertFalse(snapshot.rawPayloadExposed)
        XCTAssertFalse(snapshot.secretMaterialExposed)
        XCTAssertFalse(snapshot.commandRuntimeEnabled)
        XCTAssertFalse(snapshot.productionTradingEnabledByDefault)
        XCTAssertFalse(String(describing: snapshot).contains("fixture-secret"))
        XCTAssertFalse(String(describing: snapshot).contains("fixture-key"))

        let requests = await transport.requests()
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(requests.first?.path, BinanceSignedAccountReadTransportRequest.accountReadOnlyPath)
    }

    func testGH526BinancePrivateStreamAccountSnapshotRuntimeMapsEventsWithoutCommandSurface() async throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let dataClientTarget = try packageTargetBlock(named: "DataClient", packageSource: packageSource)
        XCTAssertTrue(
            dataClientTarget.contains(
                "\"Binance/PrivateStream/BinancePrivateStreamAccountSnapshotRuntime.swift\""
            )
        )

        XCTAssertThrowsError(
            try BinancePrivateStreamRuntimeConfiguration(
                restBaseURL: try XCTUnwrap(URL(string: "https://api.binance.com"))
            )
        ) { error in
            XCTAssertEqual(
                error as? BinancePrivateStreamRuntimeError,
                .productionEndpointForbidden("api.binance.com")
            )
        }

        let material = try BinanceSignedAccountCredentialMaterial(
            referenceID: "gh-526-fixture-credential",
            keyHeaderValue: "fixture-key",
            signingSecretValue: "fixture-secret"
        )
        let configuration = try BinancePrivateStreamRuntimeConfiguration(staleAfterSeconds: 90)
        let listenKeyTransport = TargetGraphMockBinancePrivateStreamListenKeyTransport { request in
            XCTAssertEqual(request.environment, .testnet)
            XCTAssertEqual(request.action, .create)
            XCTAssertEqual(request.method, "POST")
            XCTAssertEqual(request.path, "/api/v3/userDataStream")
            XCTAssertEqual(
                request.headers[BinanceSignedAccountReadTransportRequest.binanceKeyHeaderName],
                "fixture-key"
            )
            XCTAssertEqual(request.credentialReference, "gh-526-fixture-credential")
            XCTAssertFalse(request.url.absoluteString.contains("/api/v3/order"))
            return Data(#"{ "listenKey": "fixture-listen-key-gh-526" }"#.utf8)
        }
        let listenKeyClient = BinancePrivateStreamListenKeyClient(
            configuration: configuration,
            credentialProvider: BinanceStaticSignedAccountCredentialProvider(material: material),
            transport: listenKeyTransport
        )
        let lease = try await listenKeyClient.openListenKey(createdAt: Date(timeIntervalSince1970: 1_704_067_200))
        XCTAssertEqual(lease.credentialReference, "gh-526-fixture-credential")
        XCTAssertTrue(lease.listenKeyReference.hasPrefix("listen-key:"))
        XCTAssertFalse(lease.listenKeyReference.contains("fixture-listen-key-gh-526"))
        XCTAssertFalse(String(describing: lease).contains("fixture-listen-key-gh-526"))

        let keepAliveRequest = try listenKeyClient.lifecycleRequest(
            action: .keepAlive,
            credential: material,
            lease: lease
        )
        XCTAssertEqual(keepAliveRequest.method, "PUT")
        XCTAssertTrue(keepAliveRequest.url.absoluteString.contains("listenKey=fixture-listen-key-gh-526"))

        let closeRequest = try listenKeyClient.lifecycleRequest(
            action: .close,
            credential: material,
            lease: lease
        )
        XCTAssertEqual(closeRequest.method, "DELETE")

        let runtime = BinancePrivateStreamAccountSnapshotRuntime(configuration: configuration)
        let subscription = try runtime.subscription(for: lease)
        XCTAssertTrue(subscription.boundaryHeld)
        XCTAssertTrue(subscription.redactedStreamURL.absoluteString.contains(lease.listenKeyReference))
        XCTAssertFalse(subscription.redactedStreamURL.absoluteString.contains("fixture-listen-key-gh-526"))
        XCTAssertFalse(subscription.exposesListenKeyValue)
        XCTAssertFalse(subscription.opensProductionStream)

        let signedSnapshot = try BinanceSignedAccountReadSnapshot(
            snapshotID: try FoundationTargetID("gh-526-signed-account-snapshot"),
            accountType: "SPOT",
            canTrade: true,
            canWithdraw: false,
            canDeposit: true,
            updateTime: Date(timeIntervalSince1970: 1_704_067_205),
            balances: [
                BinanceSignedAccountBalanceReadModel(
                    asset: "BTC",
                    free: try XCTUnwrap(Decimal(string: "0.10000000")),
                    locked: 0
                ),
                BinanceSignedAccountBalanceReadModel(
                    asset: "USDT",
                    free: try XCTUnwrap(Decimal(string: "1000.50000000")),
                    locked: 10
                )
            ],
            credentialReference: material.referenceID
        )
        let eventPayloads = [
            Data(
                #"""
                {
                  "e": "outboundAccountPosition",
                  "E": 1704067210000,
                  "u": 1704067211000,
                  "B": [
                    { "a": "BTC", "f": "0.12000000", "l": "0.01000000" },
                    { "a": "USDT", "f": "900.00000000", "l": "5.00000000" }
                  ]
                }
                """#.utf8
            ),
            Data(
                #"""
                {
                  "e": "balanceUpdate",
                  "E": 1704067220000,
                  "a": "USDT",
                  "d": "12.50000000",
                  "T": 1704067221000
                }
                """#.utf8
            )
        ]

        let readModel = try runtime.readModel(
            signedSnapshot: signedSnapshot,
            lease: lease,
            eventPayloads: eventPayloads
        )
        XCTAssertTrue(readModel.boundaryHeld)
        XCTAssertEqual(readModel.signedSnapshotID.rawValue, "gh-526-signed-account-snapshot")
        XCTAssertEqual(readModel.listenKeyReference, lease.listenKeyReference)
        XCTAssertEqual(readModel.credentialReference, "gh-526-fixture-credential")
        XCTAssertEqual(readModel.staleAfterSeconds, 90)
        XCTAssertEqual(
            Set(readModel.records.map(\.freshnessStatus)),
            Set(BinancePrivateStreamFreshnessStatus.allCases)
        )
        XCTAssertTrue(readModel.records.contains { $0.eventKind == .accountSnapshot })
        XCTAssertTrue(readModel.records.contains { $0.eventKind == .balanceUpdate && $0.asset == "USDT" })
        XCTAssertTrue(readModel.records.contains { $0.eventKind == .positionUpdate && $0.asset == "BTC" })
        XCTAssertTrue(readModel.records.contains { $0.eventKind == .staleEvidence })
        XCTAssertTrue(readModel.records.contains { $0.eventKind == .blockedEvidence })
        XCTAssertTrue(readModel.records.contains { $0.eventKind == .missingEvidence })
        XCTAssertTrue(readModel.records.contains { $0.eventKind == .disconnectedEvidence })
        XCTAssertFalse(readModel.rawPrivatePayloadExposed)
        XCTAssertFalse(readModel.listenKeyValueExposed)
        XCTAssertFalse(readModel.commandRuntimeEnabled)
        XCTAssertFalse(readModel.productionTradingEnabledByDefault)
        XCTAssertTrue(readModel.records.allSatisfy { $0.rawPrivatePayloadExposed == false })
        XCTAssertTrue(readModel.records.allSatisfy { $0.listenKeyValueExposed == false })
        XCTAssertTrue(readModel.records.allSatisfy { $0.commandSurfaceEnabled == false })
        XCTAssertFalse(String(describing: readModel).contains("fixture-listen-key-gh-526"))
        XCTAssertFalse(String(describing: readModel).contains("fixture-secret"))

        let eventSource = TargetGraphMockBinancePrivateStreamEventSource(payloads: eventPayloads)
        let readModelFromSource = try await runtime.readModel(
            signedSnapshot: signedSnapshot,
            lease: lease,
            eventSource: eventSource
        )
        XCTAssertEqual(readModelFromSource.records, readModel.records)
        let eventSourceLeaseReferences = await eventSource.leaseReferences()
        XCTAssertEqual(eventSourceLeaseReferences, [lease.listenKeyReference])

        XCTAssertThrowsError(
            try BinancePrivateStreamPayloadDecoder.decodeEventRecords(
                from: [Data(#"{ "e": "executionReport", "E": 1704067230000 }"#.utf8)],
                sourceIdentity: "gh-526-forbidden-execution-report"
            )
        ) { error in
            XCTAssertEqual(
                error as? BinancePrivateStreamRuntimeError,
                .forbiddenEventKind("executionReport")
            )
        }

        XCTAssertThrowsError(
            try BinancePrivateStreamReadModelRecord(
                eventKind: .balanceUpdate,
                freshnessStatus: .fresh,
                canonicalReadModelValue: "unsafe",
                sourceIdentity: "unsafe",
                listenKeyValueExposed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? BinancePrivateStreamRuntimeError,
                .forbiddenCapability("listenKeyValueExposed")
            )
        }
    }

    func testGH527TraderRuntimeLifecycleManagesAccountsEMAAndCoordinationWithoutOrderSubmission() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let traderTarget = try packageTargetBlock(named: "Trader", packageSource: packageSource)
        XCTAssertTrue(traderTarget.contains("\"Runtime/TraderRuntimeLifecycle.swift\""))
        XCTAssertTrue(traderTarget.contains("\"TraderStrategies\""))
        XCTAssertTrue(traderTarget.contains("\"RiskEngine\""))
        XCTAssertFalse(traderTarget.contains("\"ExecutionClient\""))

        let lifecycle = try TraderRuntimeLifecycle.deterministicFixture()
        XCTAssertEqual(lifecycle.releaseVenue, "Binance")
        XCTAssertEqual(lifecycle.activeConcreteStrategy, "EMA")
        XCTAssertEqual(lifecycle.emaStrategyConfiguration.strategyID.rawValue, "gh-527-ema-instance")
        XCTAssertTrue(lifecycle.accountContext.accountContextBoundaryHeld)
        XCTAssertTrue(lifecycle.coordinationBoundary.isGenericBindingProtocolAndAdapterOnly)
        XCTAssertTrue(lifecycle.coordinationBoundary.concreteStrategiesRemainTraderOwned)
        XCTAssertTrue(lifecycle.coordinationBoundary.forbidsExecutionAndLiveCommandPaths)

        let report = try lifecycle.runDeterministicLifecycle(
            startedAt: Date(timeIntervalSince1970: 1_704_067_300),
            shutdownAt: Date(timeIntervalSince1970: 1_704_067_360)
        )
        XCTAssertTrue(report.boundaryHeld)
        XCTAssertEqual(report.lifecycleID.rawValue, "gh-527-trader-runtime-lifecycle")
        XCTAssertEqual(report.accountContextID, lifecycle.accountContext.contextID)
        XCTAssertEqual(report.accountIdentity, lifecycle.accountContext.accountIdentity)
        XCTAssertEqual(report.emaStrategyID, lifecycle.emaStrategyConfiguration.strategyID)
        XCTAssertEqual(report.events.map(\.kind), TraderRuntimeLifecycle.requiredEventKinds)
        XCTAssertEqual(Set(report.validationAnchors), Set(TraderRuntimeLifecycle.requiredValidationAnchors))
        XCTAssertTrue(report.riskEngineHandoffRequired)
        XCTAssertFalse(report.directExecutionClientEnabled)
        XCTAssertFalse(report.brokerCommandEnabled)
        XCTAssertFalse(report.omsBypassEnabled)
        XCTAssertFalse(report.productionTradingEnabledByDefault)
        XCTAssertFalse(report.nonBinanceVenueEnabled)
        XCTAssertFalse(report.nonEMAStrategyEnabled)

        XCTAssertThrowsError(
            try TraderRuntimeLifecycle(
                lifecycleID: Identifier.constant("unsafe-gh-527-direct-executionclient"),
                accountContext: .deterministicFixture,
                emaStrategyConfiguration: lifecycle.emaStrategyConfiguration,
                directExecutionClientEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.directExecutionClientEnabled")
            )
        }

        XCTAssertThrowsError(
            try TraderRuntimeLifecycle(
                lifecycleID: Identifier.constant("unsafe-gh-527-production-default"),
                accountContext: .deterministicFixture,
                emaStrategyConfiguration: lifecycle.emaStrategyConfiguration,
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.productionTradingEnabledByDefault")
            )
        }

        XCTAssertThrowsError(
            try lifecycle.runDeterministicLifecycle(
                startedAt: Date(timeIntervalSince1970: 1_704_067_400),
                shutdownAt: Date(timeIntervalSince1970: 1_704_067_399)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("traderRuntimeLifecycle.shutdownBeforeStart")
            )
        }
    }

    func testGH528EMAProposalRuntimeGeneratesRiskConsumableProposalWithoutExecutionPath() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let traderStrategiesTarget = try packageTargetBlock(named: "TraderStrategies", packageSource: packageSource)
        XCTAssertTrue(traderStrategiesTarget.contains("\"EMAProposalRuntime.swift\""))
        XCTAssertTrue(traderStrategiesTarget.contains("\"MessageBus\""))
        XCTAssertTrue(traderStrategiesTarget.contains("\"RiskEngine\""))
        XCTAssertFalse(traderStrategiesTarget.contains("\"ExecutionClient\""))

        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        XCTAssertTrue(coreTarget.contains("\"Trader/Strategies/EMA/EMAProposalRuntime.swift\""))

        let runtime = try EMAProposalRuntime.deterministicFixture()
        XCTAssertEqual(runtime.releaseVenue, "Binance")
        XCTAssertEqual(runtime.activeConcreteStrategy, "EMA")
        XCTAssertFalse(runtime.directExecutionClientEnabled)
        XCTAssertFalse(runtime.brokerCommandEnabled)
        XCTAssertFalse(runtime.omsBypassEnabled)
        XCTAssertFalse(runtime.productionTradingEnabledByDefault)

        let evidence = try runtime.generateProposal(
            from: EMAProposalRuntime.deterministicBars(),
            sessionID: Identifier.constant("gh-528-session"),
            riskProfileID: Identifier.constant("gh-528-risk-profile"),
            sourceSequence: 528,
            proposedAt: Date(timeIntervalSince1970: 1_704_067_528),
            paperQuantity: Quantity(0.10, field: "gh528.paperQuantity")
        )
        XCTAssertTrue(evidence.boundaryHeld)
        XCTAssertTrue(evidence.riskEngineConsumable)
        XCTAssertTrue(evidence.paperOnlyProposalBoundaryHeld)
        XCTAssertTrue(evidence.liveReadPathCompatible)
        XCTAssertEqual(evidence.proposal.signal.strategyID, runtime.configuration.strategyID)
        XCTAssertEqual(evidence.proposal.signal.direction, .long)
        XCTAssertEqual(evidence.proposal.side, .buy)
        XCTAssertEqual(evidence.proposal.executionMode, .paper)
        XCTAssertFalse(evidence.proposal.isExecutableAsRealOrder)
        XCTAssertEqual(evidence.riskQuery.paperOrderID, evidence.proposal.proposalID)
        XCTAssertEqual(evidence.riskQuery.riskProfileID.rawValue, "gh-528-risk-profile")
        XCTAssertEqual(evidence.riskQuery.executionMode, .paper)
        XCTAssertEqual(evidence.riskEvents, [.evaluationRequested(evidence.riskQuery)])
        XCTAssertEqual(Set(evidence.validationAnchors), Set(EMAProposalRuntime.requiredValidationAnchors))
        XCTAssertFalse(evidence.directExecutionClientEnabled)
        XCTAssertFalse(evidence.brokerCommandEnabled)
        XCTAssertFalse(evidence.omsBypassEnabled)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.nonBinanceVenueEnabled)
        XCTAssertFalse(evidence.nonEMAStrategyEnabled)

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(EMAProposalRuntimeEvidence.self, from: encoded)
        XCTAssertEqual(decoded, evidence)

        XCTAssertThrowsError(
            try EMAProposalRuntime(
                runtimeID: Identifier.constant("unsafe-gh-528-production-default"),
                configuration: runtime.configuration,
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("emaProposalRuntime.productionTradingEnabledByDefault")
            )
        }

        let sample = try XCTUnwrap(EMACrossStrategyContract(configuration: runtime.configuration)
            .evaluate(EMAProposalRuntime.deterministicBars())
            .last)
        let mismatchedSizing = try PaperActionProposalSizingAssumption(
            assumptionID: Identifier.constant("unsafe-gh-528-sizing"),
            quantity: Quantity(0.10, field: "gh528.unsafeQuantity"),
            referencePrice: Price(1, field: "gh528.unsafeReferencePrice"),
            liquidityRole: .maker
        )
        XCTAssertThrowsError(
            try runtime.generateProposal(
                from: sample,
                sessionID: Identifier.constant("gh-528-session"),
                riskProfileID: Identifier.constant("gh-528-risk-profile"),
                sourceSequence: 528,
                sizingAssumption: mismatchedSizing,
                proposedAt: Date(timeIntervalSince1970: 1_704_067_528)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperActionProposalCostEvidenceMismatch(
                    field: "emaProposalRuntime.referencePrice",
                    expected: "\(sample.close.rawValue)",
                    actual: "1.0"
                )
            )
        }
    }

    func testGH529RiskEnginePreTradeGateConsumesEMAProposalBeforeExecutionPath() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let riskEngineTarget = try packageTargetBlock(named: "RiskEngine", packageSource: packageSource)
        XCTAssertTrue(riskEngineTarget.contains("\"LiveGate\""))
        XCTAssertFalse(riskEngineTarget.contains("\"ExecutionClient\""))

        let emaRuntime = try EMAProposalRuntime.deterministicFixture()
        let proposalEvidence = try emaRuntime.generateProposal(
            from: EMAProposalRuntime.deterministicBars(),
            sessionID: Identifier.constant("gh-529-session"),
            riskProfileID: Identifier.constant("gh-529-risk-profile"),
            sourceSequence: 529,
            proposedAt: Date(timeIntervalSince1970: 1_704_067_529),
            paperQuantity: Quantity(0.10, field: "gh529.paperQuantity")
        )
        XCTAssertTrue(proposalEvidence.boundaryHeld)

        let riskInput = try ReleaseV010RiskPreTradeInput(
            inputID: Identifier.constant("gh-529-risk-input"),
            proposal: proposalEvidence.proposal,
            riskQuery: proposalEvidence.riskQuery,
            sourceSequence: proposalEvidence.sourceSequence,
            availableBalance: 100_000
        )
        XCTAssertTrue(riskInput.inputBoundaryHeld)
        XCTAssertTrue(riskInput.riskQueryMatchesProposal)

        let gate = try ReleaseV010RiskPreTradeGateRuntime.deterministicFixture()
        let approved = try gate.evaluate(riskInput)
        XCTAssertEqual(approved.outcome, .approved)
        XCTAssertEqual(approved.rejectReasons, [.none])
        XCTAssertTrue(approved.decisionBoundaryHeld)
        XCTAssertTrue(approved.allProposalsRequireRiskEngine)
        XCTAssertFalse(approved.authorizesExecutionCommand)
        XCTAssertFalse(approved.productionTradingEnabledByDefault)
        XCTAssertFalse(approved.callsExecutionClient)
        XCTAssertFalse(approved.submitsRealOrder)

        let evidence = try gate.deterministicEvidence(approvedInput: riskInput)
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(Set(evidence.decisions.map(\.outcome)), Set(ReleaseV010RiskPreTradeDecisionOutcome.allCases))
        XCTAssertTrue(evidence.allProposalsRequireRiskEngine)
        XCTAssertTrue(evidence.blockedRejectedEvidenceAuditable)
        XCTAssertTrue(evidence.noTradeGuardCovered)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.callsExecutionClient)
        XCTAssertFalse(evidence.submitsRealOrder)
        XCTAssertEqual(Set(evidence.validationAnchors), Set(ReleaseV010RiskPreTradeGateRuntime.requiredValidationAnchors))
        XCTAssertTrue(try XCTUnwrap(evidence.decisions.first { $0.outcome == .rejected })
            .rejectReasons.contains(.availableBalanceExceeded))
        XCTAssertTrue(try XCTUnwrap(evidence.decisions.first { $0.outcome == .blocked })
            .rejectReasons.contains(.noTradeGuardActive))

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(ReleaseV010RiskPreTradeGateEvidence.self, from: encoded)
        XCTAssertEqual(decoded, evidence)

        XCTAssertThrowsError(
            try ReleaseV010RiskPreTradeGateRuntime(
                runtimeID: Identifier.constant("unsafe-gh-529-production-default"),
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV010RiskPreTrade.productionTradingEnabledByDefault"
                )
            )
        }

        let mismatchedRiskQuery = try RiskEvaluationQuery(
            paperOrderID: proposalEvidence.proposal.proposalID,
            symbol: proposalEvidence.proposal.symbol,
            timeframe: proposalEvidence.proposal.timeframe,
            proposedQuantity: Quantity(0.99, field: "gh529.mismatchedQuantity"),
            riskProfileID: Identifier.constant("gh-529-risk-profile"),
            executionMode: .paper
        )
        XCTAssertThrowsError(
            try ReleaseV010RiskPreTradeInput(
                inputID: Identifier.constant("unsafe-gh-529-risk-input"),
                proposal: proposalEvidence.proposal,
                riskQuery: mismatchedRiskQuery,
                sourceSequence: proposalEvidence.sourceSequence,
                availableBalance: 100_000
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperActionRiskDecisionMismatch(
                    field: "riskQuery",
                    expected: "proposal-compatible risk query",
                    actual: "mismatched"
                )
            )
        }
    }

    func testGH530ExecutionEngineOMSStateMachineRequiresRiskApprovedEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(executionEngineTarget.contains("\"RiskEngine\""))

        let emaRuntime = try EMAProposalRuntime.deterministicFixture()
        let proposalEvidence = try emaRuntime.generateProposal(
            from: EMAProposalRuntime.deterministicBars(),
            sessionID: Identifier.constant("gh-530-session"),
            riskProfileID: Identifier.constant("gh-530-risk-profile"),
            sourceSequence: 530,
            proposedAt: Date(timeIntervalSince1970: 1_704_067_530),
            paperQuantity: Quantity(0.10, field: "gh530.paperQuantity")
        )
        let riskInput = try ReleaseV010RiskPreTradeInput(
            inputID: Identifier.constant("gh-530-risk-input"),
            proposal: proposalEvidence.proposal,
            riskQuery: proposalEvidence.riskQuery,
            sourceSequence: proposalEvidence.sourceSequence,
            availableBalance: 100_000
        )
        let riskGate = try ReleaseV010RiskPreTradeGateRuntime.deterministicFixture()
        let riskEvidence = try riskGate.deterministicEvidence(approvedInput: riskInput)
        let approvedRiskDecision = try XCTUnwrap(riskEvidence.decisions.first { $0.outcome == .approved })
        let blockedRiskDecision = try XCTUnwrap(riskEvidence.decisions.first { $0.outcome == .blocked })

        let stateMachine = try ReleaseV010ExecutionOMSStateMachine.deterministicFixture()
        let orderIntent = try stateMachine.makeOrderIntent(
            from: approvedRiskDecision,
            orderIntentID: Identifier.constant("gh-530-order-intent")
        )
        XCTAssertTrue(orderIntent.intentBoundaryHeld)
        XCTAssertEqual(orderIntent.proposalID, proposalEvidence.proposal.proposalID)
        XCTAssertEqual(orderIntent.symbol, proposalEvidence.proposal.symbol)
        XCTAssertEqual(orderIntent.quantity, proposalEvidence.proposal.quantity)
        XCTAssertFalse(orderIntent.routedToExecutionClient)
        XCTAssertFalse(orderIntent.submitsRealOrder)

        let evidence = try stateMachine.deterministicEvidence(from: riskEvidence)
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(evidence.statesCovered, Set(ReleaseV010OMSOrderLifecycleState.allCases))
        XCTAssertEqual(Set(evidence.eventLogs.map(\.path)), Set(ReleaseV010OMSPath.allCases))
        XCTAssertTrue(evidence.riskApprovedRequiredBeforeExecutionPath)
        XCTAssertTrue(evidence.stateMachineCoversAllRequiredStates)
        XCTAssertTrue(evidence.eventLogAuditEvidenceComplete)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionOMSRuntimeEnabledByDefault)
        XCTAssertFalse(evidence.callsExecutionClient)
        XCTAssertFalse(evidence.submitsRealOrder)
        XCTAssertFalse(evidence.cancelsRealOrder)
        XCTAssertFalse(evidence.replacesRealOrder)

        let rejectedLog = try XCTUnwrap(evidence.eventLogs.first { $0.path == .riskRejected })
        XCTAssertNil(rejectedLog.orderIntent)
        XCTAssertEqual(rejectedLog.sourceRiskDecision.outcome, .blocked)
        XCTAssertEqual(rejectedLog.terminalState, .rejected)
        XCTAssertTrue(rejectedLog.eventLogBoundaryHeld)

        let replacedLog = try XCTUnwrap(evidence.eventLogs.first { $0.path == .acceptedReplacedFilled })
        XCTAssertTrue(replacedLog.statesCovered.contains(.replaced))
        XCTAssertEqual(replacedLog.terminalState, .filled)
        XCTAssertTrue(replacedLog.transitions.allSatisfy(\.appendOnlyAuditEvent))

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(ReleaseV010ExecutionOMSStateMachineEvidence.self, from: encoded)
        XCTAssertEqual(decoded, evidence)

        XCTAssertThrowsError(
            try stateMachine.makeOrderIntent(
                from: blockedRiskDecision,
                orderIntentID: Identifier.constant("unsafe-gh-530-blocked-intent")
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "sourceRiskDecision.outcome",
                    expected: ReleaseV010RiskPreTradeDecisionOutcome.approved.rawValue,
                    actual: ReleaseV010RiskPreTradeDecisionOutcome.blocked.rawValue
                )
            )
        }

        XCTAssertThrowsError(
            try ReleaseV010ExecutionOMSStateMachine(
                stateMachineID: Identifier.constant("unsafe-gh-530-production-oms"),
                productionOMSRuntimeEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010OMS.productionOMSRuntimeEnabledByDefault")
            )
        }

        XCTAssertThrowsError(
            try ReleaseV010OMSStateTransition(
                transitionID: Identifier.constant("unsafe-gh-530-transition"),
                orderID: Identifier.constant("unsafe-gh-530-order"),
                sourceRiskDecisionID: approvedRiskDecision.decisionID,
                fromState: .filled,
                trigger: .riskApproved,
                toState: .accepted,
                sequence: 1
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "omsTransition",
                    expected: ReleaseV010OMSStateTransition.allowedTransitionDescriptions.sorted().joined(separator: ","),
                    actual: "filled|risk approved|accepted"
                )
            )
        }
    }

    func testGH531BinanceExecutionClientTestnetSubmitCancelReplaceRequiresCredentialGuardAndOMS() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))

        let adapter = try ReleaseV010BinanceExecutionClientTestnetAdapter.deterministicFixture()
        XCTAssertTrue(adapter.adapterBoundaryHeld)
        XCTAssertEqual(adapter.issueID.rawValue, "GH-531")
        XCTAssertEqual(adapter.upstreamIssueID.rawValue, "GH-530")
        XCTAssertTrue(adapter.capabilityMatrix.matrixHeld)
        XCTAssertTrue(adapter.credentialGuard.guardHeld)
        XCTAssertEqual(adapter.environment, .testnet)
        XCTAssertFalse(adapter.productionEndpointEnabledByDefault)
        XCTAssertFalse(adapter.productionTradingEnabledByDefault)
        XCTAssertFalse(adapter.productionSecretReadEnabledByDefault)
        XCTAssertFalse(adapter.brokerGatewayTouched)
        XCTAssertFalse(adapter.bypassesRiskEngine)
        XCTAssertFalse(adapter.bypassesOMS)
        XCTAssertFalse(adapter.bypassesKillSwitch)

        let evidence = try adapter.deterministicCommandEvidence()
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(
            Set(evidence.requests.map(\.commandKind)),
            Set(ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases)
        )
        XCTAssertEqual(
            Set(evidence.acknowledgements.map(\.commandKind)),
            Set(ReleaseV010BinanceExecutionClientTestnetCommandKind.allCases)
        )
        XCTAssertTrue(evidence.requests.allSatisfy { $0.environment == .testnet })
        XCTAssertTrue(evidence.requests.allSatisfy { $0.baseURL.host == "testnet.binance.vision" })
        XCTAssertTrue(evidence.requests.allSatisfy(\.signatureRequired))
        XCTAssertTrue(evidence.requests.allSatisfy { $0.signatureValueExposed == false })
        XCTAssertTrue(evidence.acknowledgements.allSatisfy(\.acceptedByTestnetAdapter))
        XCTAssertTrue(evidence.acknowledgements.allSatisfy { $0.productionOrderTouched == false })
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionSecretReadEnabledByDefault)
        XCTAssertFalse(evidence.productionSubmitEnabledByDefault)
        XCTAssertFalse(evidence.productionCancelEnabledByDefault)
        XCTAssertFalse(evidence.productionReplaceEnabledByDefault)
        XCTAssertFalse(evidence.executionReportParsed)
        XCTAssertFalse(evidence.brokerFillParsed)
        XCTAssertFalse(evidence.reconciliationPerformed)

        let submit = try XCTUnwrap(evidence.requests.first { $0.commandKind == .submit })
        XCTAssertEqual(submit.method, .post)
        XCTAssertEqual(submit.endpointPath, "/api/v3/order")
        XCTAssertEqual(
            submit.queryItemNames,
            ["symbol", "side", "type", "timeInForce", "quantity", "price", "newClientOrderId", "recvWindow", "timestamp"]
        )

        let cancel = try XCTUnwrap(evidence.requests.first { $0.commandKind == .cancel })
        XCTAssertEqual(cancel.method, .delete)
        XCTAssertEqual(cancel.endpointPath, "/api/v3/order")
        XCTAssertEqual(
            cancel.queryItemNames,
            ["symbol", "origClientOrderId", "newClientOrderId", "recvWindow", "timestamp"]
        )

        let replace = try XCTUnwrap(evidence.requests.first { $0.commandKind == .replace })
        XCTAssertEqual(replace.method, .post)
        XCTAssertEqual(replace.endpointPath, "/api/v3/order/cancelReplace")
        XCTAssertEqual(
            replace.queryItemNames,
            [
                "symbol",
                "side",
                "type",
                "timeInForce",
                "quantity",
                "price",
                "cancelOrigClientOrderId",
                "newClientOrderId",
                "cancelReplaceMode",
                "recvWindow",
                "timestamp"
            ]
        )

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            ReleaseV010BinanceExecutionClientTestnetCommandEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ReleaseV010BinanceExecutionClientTestnetCommands.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ReleaseV010BinanceExecutionClientCredentialGuard(
                credentialReferenceID: Identifier.constant("unsafe-gh-531-production-credential"),
                environment: .production
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.productionCredential")
            )
        }

        XCTAssertThrowsError(
            try ReleaseV010BinanceExecutionClientTestnetCommandRequest(
                requestID: Identifier.constant("unsafe-gh-531-production-request"),
                commandKind: .submit,
                environment: .production,
                credentialReferenceID: adapter.credentialGuard.credentialReferenceID,
                sourceOMSOrderID: Identifier.constant("gh-530-oms-submit-order"),
                sourceOMSEventLogID: Identifier.constant("gh-530-oms-submit-event-log"),
                sourceRiskDecisionID: Identifier.constant("gh-529-approved-risk-decision"),
                clientOrderID: Identifier.constant("unsafe-gh-531-client-order"),
                symbol: "BTCUSDT",
                queryItems: submit.queryItems
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.productionEnvironment")
            )
        }

        let productionURL = try XCTUnwrap(URL(string: "https://api.binance.com"))
        XCTAssertThrowsError(
            try ReleaseV010BinanceExecutionClientTestnetCommandRequest(
                requestID: Identifier.constant("unsafe-gh-531-production-url"),
                commandKind: .submit,
                baseURL: productionURL,
                credentialReferenceID: adapter.credentialGuard.credentialReferenceID,
                sourceOMSOrderID: Identifier.constant("gh-530-oms-submit-order"),
                sourceOMSEventLogID: Identifier.constant("gh-530-oms-submit-event-log"),
                sourceRiskDecisionID: Identifier.constant("gh-529-approved-risk-decision"),
                clientOrderID: Identifier.constant("unsafe-gh-531-client-order"),
                symbol: "BTCUSDT",
                queryItems: submit.queryItems
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.productionEndpoint")
            )
        }

        XCTAssertThrowsError(
            try ReleaseV010BinanceExecutionClientTestnetQueryItem(name: "signature", value: "unsafe-signature")
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010BinanceExecutionClient.signatureValue")
            )
        }

        XCTAssertThrowsError(
            try adapter.submit(cancel)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "commandKind",
                    expected: "submit",
                    actual: "cancel"
                )
            )
        }
    }

    func testGH532BinanceExecutionReportParserMapsBrokerFillAndInvalidEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))

        let parser = try ReleaseV010BinanceExecutionReportParser.deterministicFixture()
        XCTAssertTrue(parser.parserBoundaryHeld)
        XCTAssertEqual(parser.issueID.rawValue, "GH-532")
        XCTAssertEqual(parser.upstreamIssueID.rawValue, "GH-531")
        XCTAssertTrue(parser.commandEvidence.evidenceBoundaryHeld)
        XCTAssertFalse(parser.productionParserEnabledByDefault)
        XCTAssertFalse(parser.productionTradingEnabledByDefault)
        XCTAssertFalse(parser.productionPayloadInterpreted)
        XCTAssertFalse(parser.brokerGatewayTouched)
        XCTAssertFalse(parser.reconciliationProduced)
        XCTAssertFalse(parser.portfolioUpdated)
        XCTAssertFalse(parser.dashboardCommandSurfaceTouched)
        XCTAssertTrue(parser.validationAnchors.contains("GH-532-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER"))
        XCTAssertTrue(parser.validationAnchors.contains("GH-532-EXECUTIONENGINE-EVENT-MODEL-HANDOFF"))
        XCTAssertTrue(parser.validationAnchors.contains("GH-532-BROKER-FILL-MAPPING"))
        XCTAssertTrue(parser.validationAnchors.contains("GH-532-PARTIAL-CANCEL-REJECT-EVIDENCE"))
        XCTAssertTrue(parser.validationAnchors.contains("GH-532-INVALID-REPORT-BLOCKED-EVIDENCE"))
        XCTAssertTrue(parser.validationAnchors.contains("GH-532-PRODUCTION-PARSER-DISABLED"))

        let evidence = try parser.deterministicParserEvidence()
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(Set(evidence.parsedEvents.map(\.reportKind)), Set(ReleaseV010BinanceExecutionReportKind.allCases))
        XCTAssertEqual(evidence.parsedEvents.map(\.replaySequence), [1, 2, 3, 4])
        XCTAssertTrue(evidence.executionEngineEventModelReady)
        XCTAssertTrue(evidence.brokerFillMappingEvidenceComplete)
        XCTAssertTrue(evidence.partialFillCancelRejectCovered)
        XCTAssertTrue(evidence.invalidReportBlockedEvidenceComplete)
        XCTAssertTrue(evidence.productionParserDisabled)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionPayloadInterpreted)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.reconciliationProduced)
        XCTAssertFalse(evidence.portfolioUpdated)
        XCTAssertFalse(evidence.dashboardCommandSurfaceTouched)

        let fillEvents = evidence.parsedEvents.filter(\.brokerFillMapped)
        XCTAssertEqual(Set(fillEvents.map(\.reportKind)), [.fullFill, .partialFill])
        XCTAssertTrue(fillEvents.allSatisfy { $0.executionEngineEventModelReady })
        XCTAssertTrue(fillEvents.allSatisfy { $0.eventStream == .paper })
        XCTAssertTrue(fillEvents.allSatisfy { $0.rawPayloadExposed == false })
        XCTAssertTrue(fillEvents.allSatisfy { $0.reconciliationProduced == false })
        XCTAssertTrue(fillEvents.allSatisfy { $0.portfolioUpdated == false })

        let canceled = try XCTUnwrap(evidence.parsedEvents.first { $0.reportKind == .canceled })
        XCTAssertEqual(canceled.orderStatus, "CANCELED")
        XCTAssertFalse(canceled.brokerFillMapped)
        XCTAssertTrue(canceled.executionEngineEventModelReady)

        let rejected = try XCTUnwrap(evidence.parsedEvents.first { $0.reportKind == .rejected })
        XCTAssertEqual(rejected.executionType, "REJECTED")
        XCTAssertFalse(rejected.brokerFillMapped)
        XCTAssertTrue(rejected.executionEngineEventModelReady)

        XCTAssertEqual(
            Set(evidence.invalidReports.map(\.reason)),
            [.unsupportedExecutionStatus, .productionRawPayload]
        )
        XCTAssertTrue(evidence.invalidReports.allSatisfy(\.invalidReportBlocked))
        XCTAssertTrue(evidence.invalidReports.allSatisfy { $0.executionEngineEventProduced == false })
        XCTAssertTrue(evidence.invalidReports.allSatisfy { $0.brokerFillMapped == false })
        XCTAssertTrue(evidence.invalidReports.allSatisfy { $0.productionPayloadInterpreted == false })

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            ReleaseV010BinanceExecutionReportParserEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ReleaseV010BinanceExecutionReportBrokerFillParser.swift"
                ).path
            )
        )

        let commandEvidence = parser.commandEvidence
        let submit = try XCTUnwrap(commandEvidence.requests.first { $0.commandKind == .submit })
        let submitAck = try XCTUnwrap(commandEvidence.acknowledgements.first { $0.commandKind == .submit })
        XCTAssertThrowsError(
            try ReleaseV010BinanceExecutionReportFixture(
                reportID: Identifier.constant("unsafe-gh-532-production-report"),
                sourceKind: .productionRawExecutionReport,
                reportKind: .fullFill,
                sourceCommandKind: .submit,
                sourceCommandRequestID: submit.requestID,
                sourceCommandAckID: submitAck.ackID,
                sourceOMSOrderID: submit.sourceOMSOrderID,
                sourceOMSEventLogID: submit.sourceOMSEventLogID,
                sourceRiskDecisionID: submit.sourceRiskDecisionID,
                clientOrderID: submit.clientOrderID,
                symbol: submit.symbol,
                cumulativeFilledQuantity: "0.0100",
                lastExecutedQuantity: "0.0100",
                remainingQuantity: "0.0000",
                lastExecutedPrice: "42120.70",
                commissionAsset: "USDT",
                commissionAmount: "0.000010",
                replaySequence: 1,
                rawPayloadDigest: "sha256:unsafe-production-report"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.productionRawPayload")
            )
        }

        XCTAssertThrowsError(
            try ReleaseV010BinanceExecutionReportParser(
                productionParserEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010ExecutionReport.productionParserEnabledByDefault")
            )
        }
    }

    func testGH533PortfolioReconciliationUpdatesFromExecutionAndAccountEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(executionEngineTarget.contains("\"Portfolio\""))
        XCTAssertTrue(executionEngineTarget.contains("\"ExecutionClient\""))

        let path = try ReleaseV010PortfolioReconciliationUpdatePath.deterministicFixture()
        XCTAssertTrue(path.pathBoundaryHeld)
        XCTAssertTrue(path.parserEvidence.evidenceBoundaryHeld)
        XCTAssertFalse(path.productionTradingEnabledByDefault)
        XCTAssertFalse(path.productionAccountEndpointRead)
        XCTAssertFalse(path.brokerGatewayTouched)
        XCTAssertFalse(path.repairCommandProduced)
        XCTAssertFalse(path.dashboardCommandSurfaceTouched)

        let evidence = try path.deterministicEvidence()
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-533")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-530", "GH-532"])
        XCTAssertEqual(Set(evidence.records.map(\.status)), Set(ReleaseV010PortfolioReconciliationStatus.allCases))
        XCTAssertTrue(evidence.portfolioCanUpdateFromExecutionAndAccountEvidence)
        XCTAssertTrue(evidence.mismatchStaleBlockedAuditable)
        XCTAssertTrue(evidence.positionsNetMarginOpenValueCovered)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionAccountEndpointRead)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.repairCommandProduced)
        XCTAssertFalse(evidence.dashboardCommandSurfaceTouched)
        XCTAssertTrue(evidence.validationAnchors.contains("GH-533-EXECUTION-ACCOUNT-PORTFOLIO-RECONCILIATION"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-533-PORTFOLIO-UPDATE-PATH"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-533-MISMATCH-STALE-BLOCKED-AUDIT-EVIDENCE"))

        let matched = try XCTUnwrap(evidence.records.first { $0.status == .matched })
        XCTAssertTrue(matched.recordBoundaryHeld)
        XCTAssertEqual(matched.reasons, [.none])
        XCTAssertNotNil(matched.portfolioUpdate)
        XCTAssertTrue(try XCTUnwrap(matched.portfolioUpdate).updateBoundaryHeld)
        XCTAssertEqual(try XCTUnwrap(matched.portfolioUpdate).openValue, try XCTUnwrap(matched.portfolioUpdate).exposure.grossExposureNotional)
        XCTAssertFalse(try XCTUnwrap(matched.portfolioUpdate).portfolioRuntimeMutated)
        XCTAssertFalse(try XCTUnwrap(matched.portfolioUpdate).readsProductionAccountEndpoint)
        XCTAssertFalse(try XCTUnwrap(matched.portfolioUpdate).syncsBrokerPosition)
        XCTAssertFalse(try XCTUnwrap(matched.portfolioUpdate).authorizesTradingExecution)

        let mismatched = try XCTUnwrap(evidence.records.first { $0.status == .mismatched })
        XCTAssertTrue(mismatched.recordBoundaryHeld)
        XCTAssertEqual(mismatched.reasons, [.accountPositionQuantityMismatch])
        XCTAssertNotNil(mismatched.portfolioUpdate)

        let stale = try XCTUnwrap(evidence.records.first { $0.status == .stale })
        XCTAssertTrue(stale.recordBoundaryHeld)
        XCTAssertEqual(stale.accountSnapshot.freshness, .stale)
        XCTAssertNil(stale.portfolioUpdate)

        let blocked = try XCTUnwrap(evidence.records.first { $0.status == .blocked })
        XCTAssertTrue(blocked.recordBoundaryHeld)
        XCTAssertEqual(blocked.accountSnapshot.freshness, .blocked)
        XCTAssertNil(blocked.portfolioUpdate)

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            ReleaseV010PortfolioReconciliationUpdateEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/ReleaseV010PortfolioReconciliationUpdatePath.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ReleaseV010PortfolioReconciliationUpdatePath(
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010Portfolio.productionTradingEnabledByDefault")
            )
        }

        XCTAssertThrowsError(
            try ReleaseV010AccountPortfolioSnapshotEvidence(
                snapshotID: Identifier.constant("unsafe-gh-533-account"),
                accountID: Identifier.constant("unsafe-gh-533-account-id"),
                portfolioID: Identifier.constant("unsafe-gh-533-portfolio"),
                symbol: Symbol.constant("BTCUSDT"),
                freeBalance: 100_000,
                lockedBalance: 0,
                accountPositionQuantity: Quantity(0.01, field: "unsafe-gh-533-quantity"),
                referencePrice: Price(42_120.70, field: "unsafe-gh-533-price"),
                freshness: .fresh,
                observedAt: Date(timeIntervalSince1970: 1_704_067_700),
                readsProductionAccountEndpoint: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010Portfolio.readsProductionAccountEndpoint")
            )
        }
    }

    func testGH537ReleaseDryRunTestnetValidationSuiteIsRepeatableAndProductionSafe() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(executionEngineTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(executionEngineTarget.contains("\"Portfolio\""))

        let suite = try ReleaseV010DryRunTestnetValidationSuite.deterministicFixture()
        XCTAssertTrue(suite.suiteBoundaryHeld)

        let evidence = try suite.deterministicValidationEvidence()
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-537")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-531", "GH-532", "GH-533", "GH-536"])
        XCTAssertEqual(evidence.validationCommand, "bash checks/release-v0.1.0-dryrun-testnet.sh")
        XCTAssertEqual(evidence.steps.map(\.stage), ReleaseV010DryRunTestnetValidationStage.allCases)
        XCTAssertTrue(evidence.steps.allSatisfy(\.stepBoundaryHeld))
        XCTAssertEqual(evidence.commandEvidence.requests.count, 3)
        XCTAssertEqual(evidence.commandEvidence.acknowledgements.count, 3)
        XCTAssertEqual(evidence.parserEvidence.parsedEvents.count, 4)
        XCTAssertEqual(evidence.parserEvidence.parsedEvents.filter(\.brokerFillMapped).count, 2)
        XCTAssertEqual(evidence.reconciliationEvidence.records.count, 4)

        let dryRun = try XCTUnwrap(evidence.steps.first { $0.stage == .dryRunEndToEnd })
        XCTAssertEqual(dryRun.expectedRecordCount, 14)
        XCTAssertEqual(dryRun.actualRecordCount, 14)

        let testnet = try XCTUnwrap(evidence.steps.first { $0.stage == .testnetSubmitCancelReplace })
        XCTAssertEqual(testnet.expectedRecordCount, 6)
        XCTAssertEqual(testnet.sourceIssueIDs, ["GH-531"])

        let report = try XCTUnwrap(evidence.steps.first { $0.stage == .executionReportBrokerFill })
        XCTAssertEqual(report.expectedRecordCount, 6)
        XCTAssertEqual(report.sourceIssueIDs, ["GH-532"])

        let reconciliation = try XCTUnwrap(evidence.steps.first { $0.stage == .reconciliationPortfolioUpdate })
        XCTAssertEqual(reconciliation.expectedRecordCount, 4)
        XCTAssertEqual(reconciliation.sourceIssueIDs, ["GH-533"])

        let killSwitch = try XCTUnwrap(evidence.steps.first { $0.stage == .killSwitchNoTradeRollback })
        XCTAssertEqual(killSwitch.expectedRecordCount, 3)
        XCTAssertEqual(killSwitch.sourceIssueIDs, ["GH-536"])

        XCTAssertTrue(evidence.dryRunEndToEndRepeatable)
        XCTAssertTrue(evidence.testnetSubmitCancelReplaceCovered)
        XCTAssertTrue(evidence.executionReportFillReconciliationCovered)
        XCTAssertTrue(evidence.killSwitchNoTradeRollbackRequired)
        XCTAssertFalse(evidence.failureTriggersProductionOrder)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionSecretReadEnabledByDefault)
        XCTAssertFalse(evidence.productionEndpointConnectionEnabledByDefault)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.nonBinanceVenueEnabled)
        XCTAssertFalse(evidence.nonEMAStrategyEnabled)
        XCTAssertFalse(evidence.authorizesTradingExecution)
        XCTAssertTrue(
            evidence.validationAnchors.contains("GH-537-BINANCE-DRYRUN-TESTNET-VALIDATION-SUITE")
        )
        XCTAssertTrue(
            evidence.validationAnchors.contains("GH-537-NO-PRODUCTION-ORDER-ON-FAILURE")
        )
        XCTAssertTrue(
            evidence.validationAnchors.contains("TVM-RELEASE-V010-BINANCE-DRYRUN-TESTNET-VALIDATION")
        )

        let repeatEvidence = try ReleaseV010DryRunTestnetValidationSuite.deterministicFixture()
            .deterministicValidationEvidence()
        XCTAssertEqual(repeatEvidence, evidence)

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/ReleaseV010DryRunTestnetValidationSuite.swift"
                ).path
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "checks/release-v0.1.0-dryrun-testnet.sh"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ReleaseV010DryRunTestnetValidationEvidence(
                steps: evidence.steps,
                commandEvidence: evidence.commandEvidence,
                parserEvidence: evidence.parserEvidence,
                reconciliationEvidence: evidence.reconciliationEvidence,
                failureTriggersProductionOrder: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV010Validation.failureTriggersProductionOrder")
            )
        }

        XCTAssertThrowsError(
            try ReleaseV010DryRunTestnetValidationSuite(validationAnchors: ["unsafe"])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "validationAnchors",
                    expected: ReleaseV010DryRunTestnetValidationEvidence.requiredValidationAnchors
                        .joined(separator: ","),
                    actual: "unsafe"
                )
            )
        }
    }

    func testGH538NoDefaultProductionTradingGuardIsRequiredAutomationReadiness() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let guardScriptPath = repositoryRoot.appendingPathComponent(
            "checks/automation-readiness.d/release-v010-no-default-production-trading.sh"
        )
        let guardScript = try String(contentsOf: guardScriptPath, encoding: .utf8)
        let domainGuardRunner = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.d/run-domain-guards.sh"),
            encoding: .utf8
        )
        let l4Boundary = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.d/l4-boundary.sh"),
            encoding: .utf8
        )
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md"
            ),
            encoding: .utf8
        )
        let validationMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let domainContext = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/domain/context.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: guardScriptPath.path))
        XCTAssertTrue(domainGuardRunner.contains("release-v010-no-default-production-trading"))
        XCTAssertTrue(l4Boundary.contains("release-v010-no-default-production-trading.sh"))

        for expected in [
            "GH-538-NO-DEFAULT-PRODUCTION-TRADING-AUTOMATION-GUARD",
            "GH-538-FORBIDDEN-PRODUCTION-CONFIG-DEFAULTS",
            "GH-538-SECRET-ENDPOINT-GUARD-EVIDENCE",
            "GH-538-DRYRUN-TESTNET-KILLSWITCH-BYPASS-GUARD",
            "TVM-RELEASE-V010-NO-DEFAULT-PRODUCTION-TRADING-GUARD",
            "productionTradingEnabledByDefault",
            "productionEndpointConnectionEnabledByDefault",
            "productionSecretReadEnabledByDefault",
            "productionOrderSubmitEnabledByDefault",
            "productionOrderCancelEnabledByDefault",
            "productionOrderReplaceEnabledByDefault",
            "productionOMSRuntimeEnabledByDefault",
            "productionDashboardCommandEnabledByDefault",
            "automaticProductionCutoverEnabled",
            "failureTriggersProductionOrder",
            "sandboxCommandPromotesProductionCommand",
            "bypassesRiskEngine",
            "bypassesExecutionEngine",
            "bypassesOMS",
            "bypassesKillSwitch",
            "bypassesNoTradeState"
        ] {
            XCTAssertTrue(guardScript.contains(expected), "GH-538 guard script must contain \(expected)")
        }

        for expected in [
            "GH-538-NO-DEFAULT-PRODUCTION-TRADING-AUTOMATION-GUARD",
            "GH-538-FORBIDDEN-PRODUCTION-CONFIG-DEFAULTS",
            "GH-538-SECRET-ENDPOINT-GUARD-EVIDENCE",
            "GH-538-DRYRUN-TESTNET-KILLSWITCH-BYPASS-GUARD",
            "TVM-RELEASE-V010-NO-DEFAULT-PRODUCTION-TRADING-GUARD"
        ] {
            XCTAssertTrue(releaseContract.contains(expected), "Release contract must contain \(expected)")
            XCTAssertTrue(l4Boundary.contains(expected), "L4 boundary readiness must contain \(expected)")
        }

        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V010-NO-DEFAULT-PRODUCTION-TRADING-GUARD"))
        XCTAssertTrue(validationPlan.contains("GH-538 No-default Production Trading Automation Guard Validation"))
        XCTAssertTrue(domainContext.contains("GH-538 No-default Production Trading Automation Guard Terms"))
        XCTAssertTrue(
            automationReadiness.contains(
                "Release v0.1.0 no-default-production-trading automation guard anchor"
            )
        )
    }

    func testGH563ReleaseV020ContractDefinesBinanceSpotPerpEMARSIBoundary() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let contractPath = repositoryRoot.appendingPathComponent(
            "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
        )
        let releaseContract = try String(contentsOf: contractPath, encoding: .utf8)
        let validationMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let domainContext = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/domain/context.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let l4Boundary = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.d/l4-boundary.sh"),
            encoding: .utf8
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: contractPath.path))

        for expected in [
            "GH-563-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-CONTRACT",
            "GH-563-BINANCE-SPOT-PERP-ACTIVE-SCOPE",
            "GH-563-EMA-RSI-ACTIVE-STRATEGY-SCOPE",
            "GH-563-NTPRO-SCOPED-ALIGNMENT-MATRIX",
            "GH-563-ACCEPTANCE-MATRIX",
            "GH-563-NO-DEFAULT-PRODUCTION-TRADING",
            "GH-563-VALIDATION-ANCHORS",
            "GH-563-NON-AUTHORIZATION",
            "TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-NTPRO-ALIGNMENT",
            "activeVenue == Binance",
            "activeProductTypes == [spot, usdsPerpetual]",
            "activeStrategies == [ema, rsi]",
            "productionTradingEnabledByDefault == false",
            "NTPRO scoped 100% alignment"
        ] {
            XCTAssertTrue(releaseContract.contains(expected), "Release v0.2.0 contract must contain \(expected)")
        }

        for forbiddenBoundary in [
            "non-Binance venue",
            "非 Spot / USDⓈ-M Perpetual product",
            "非 EMA / RSI active strategy",
            "CommandGateway",
            "RiskEngine",
            "ExecutionEngine",
            "OMS",
            "Event Store",
            "production secret",
            "production endpoint",
            "real submit / cancel / replace"
        ] {
            XCTAssertTrue(
                releaseContract.contains(forbiddenBoundary),
                "Release v0.2.0 contract must preserve boundary text for \(forbiddenBoundary)"
            )
        }

        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-NTPRO-ALIGNMENT"))
        XCTAssertTrue(validationMatrix.contains("GH-563..GH-596 issue backfill"))
        XCTAssertTrue(validationMatrix.contains("`GH-563`"))
        XCTAssertTrue(
            validationPlan.contains("GH-563 Release v0.2.0 Binance Spot + Perp EMA/RSI Contract Validation")
        )
        XCTAssertTrue(
            domainContext.contains("GH-563 Release v0.2.0 Binance Spot + Perp EMA/RSI Contract Terms")
        )
        XCTAssertTrue(
            automationReadiness.contains("Release v0.2.0 Binance Spot + Perp EMA/RSI contract anchor")
        )
        XCTAssertTrue(l4Boundary.contains("release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"))
        XCTAssertTrue(l4Boundary.contains("testGH563ReleaseV020ContractDefinesBinanceSpotPerpEMARSIBoundary"))
    }

    func testGH503ProductionCredentialSecretPolicyGateDefinesNoDefaultSecretReadContract() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let gate = try ProductionCutoverCredentialSecretPolicyGate.deterministicFixture()
        XCTAssertTrue(gate.contractHeld)
        XCTAssertTrue(gate.readinessEvidenceCoverageHeld)
        XCTAssertEqual(gate.issueID.rawValue, "GH-503")
        XCTAssertEqual(gate.canonicalQueueRange, "GH-503..GH-510")
        XCTAssertEqual(Set(gate.scopes), Set(ProductionCutoverCredentialPolicyScope.allCases))
        XCTAssertEqual(Set(gate.gates), Set(ProductionCutoverSecretPolicyGate.allCases))
        XCTAssertEqual(Set(gate.forbiddenCapabilities), Set(ProductionCutoverCredentialForbiddenCapability.allCases))
        XCTAssertTrue(gate.validationAnchors.contains("GH-503-NO-DEFAULT-SECRET-READ"))
        XCTAssertTrue(gate.validationAnchors.contains("GH-503-PRODUCTION-BLOCKED-EVIDENCE"))

        XCTAssertTrue(gate.noDefaultSecretReadRequired)
        XCTAssertTrue(gate.localFixtureDryRunProductionIsolationRequired)
        XCTAssertTrue(gate.secretStorageFutureGateOnly)
        XCTAssertTrue(gate.secretInjectionRotationFutureGateOnly)
        XCTAssertTrue(gate.productionBlockedByDefault)

        for forbidden in [
            gate.readsSecretValue,
            gate.probesEnvironmentSecret,
            gate.storesAPIKey,
            gate.storesAPISecret,
            gate.constructsAPIKeyHeader,
            gate.generatesRequestSignature,
            gate.callsSignedEndpoint,
            gate.callsAccountEndpoint,
            gate.createsListenKey,
            gate.connectsBroker,
            gate.sandboxCommandPromotesProductionCredential,
            gate.productionTradingEnabledByDefault,
            gate.implementsExecutionClientAdapter,
            gate.implementsOMS,
            gate.submitsRealOrder,
            gate.cancelsRealOrder,
            gate.replacesRealOrder
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ProductionCutoverCredentialSecretPolicyGate.swift"
                ).path
            )
        )
    }

    func testGH503ProductionCredentialSecretPolicyGateRejectsSecretReadAndProductionPromotion() throws {
        XCTAssertThrowsError(
            try ProductionCutoverCredentialSecretPolicyGate(
                readsSecretValue: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsSecretValue"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverCredentialSecretPolicyGate(
                sandboxCommandPromotesProductionCredential: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("sandboxCommandPromotesProductionCredential")
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverCredentialSecretPolicyGate(
                requiredValidationCommands: ["bash checks/run.sh"]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "requiredValidationCommands",
                    expected: "git diff --check,bash checks/automation-readiness.sh,bash checks/run.sh",
                    actual: "bash checks/run.sh"
                )
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverCredentialReadinessEvidence(
                evidenceID: Identifier.constant("gh-503-unsafe-secret-read"),
                scope: .dryRun,
                expectedEvidence: "unsafe secret read",
                blockedReason: "must be rejected",
                readsSecretValue: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsSecretValue"))
        }
    }

    func testGH504ProductionEnvironmentIsolationGateDefinesBlockedDryRunDefault() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let upstream = try ProductionCutoverCredentialSecretPolicyGate.deterministicFixture()
        let gate = try ProductionCutoverEnvironmentIsolationGateContract.deterministicFixture()
        XCTAssertTrue(upstream.contractHeld)
        XCTAssertTrue(gate.contractHeld)
        XCTAssertTrue(gate.environmentCoverageHeld)
        XCTAssertEqual(gate.issueID.rawValue, "GH-504")
        XCTAssertEqual(gate.upstreamIssueID.rawValue, "GH-503")
        XCTAssertEqual(gate.canonicalQueueRange, "GH-503..GH-510")
        XCTAssertEqual(Set(gate.scopes), Set(ProductionCutoverEnvironmentScope.allCases))
        XCTAssertEqual(Set(gate.gates), Set(ProductionCutoverEnvironmentGate.allCases))
        XCTAssertEqual(Set(gate.forbiddenCapabilities), Set(ProductionCutoverEnvironmentForbiddenCapability.allCases))
        XCTAssertTrue(gate.validationAnchors.contains("GH-504-PRODUCTION-NO-DEFAULT-TRADING"))
        XCTAssertTrue(gate.validationAnchors.contains("GH-504-SANDBOX-DRYRUN-PRODUCTION-COMMAND-ISOLATION"))

        XCTAssertTrue(gate.credentialPolicyGateRequired)
        XCTAssertTrue(gate.productionNoDefaultTradingRequired)
        XCTAssertTrue(gate.sandboxCommandProductionCommandIsolationRequired)
        XCTAssertTrue(gate.explicitAuditableEnvironmentSwitchRequired)
        XCTAssertTrue(gate.manualApprovalCannotBeBypassed)
        XCTAssertTrue(gate.productionBlockedDryRunDefault)

        for forbidden in [
            gate.implementsProductionRuntime,
            gate.allowsAutomaticEnvironmentSwitch,
            gate.readsSecretValue,
            gate.connectsBroker,
            gate.implementsBrokerAdapter,
            gate.implementsOMS,
            gate.implementsLiveExecutionAdapter,
            gate.sandboxCommandPromotesProductionCommand,
            gate.productionTradingEnabledByDefault,
            gate.submitsRealOrder,
            gate.cancelsRealOrder,
            gate.replacesRealOrder,
            gate.exposesLiveCommandSurface,
            gate.exposesTradingButton,
            gate.exposesOrderForm
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ProductionCutoverEnvironmentIsolationGate.swift"
                ).path
            )
        )
    }

    func testGH504ProductionEnvironmentIsolationGateRejectsAutomaticSwitchAndBrokerBypass() throws {
        XCTAssertThrowsError(
            try ProductionCutoverEnvironmentIsolationGateContract(
                allowsAutomaticEnvironmentSwitch: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("allowsAutomaticEnvironmentSwitch")
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverEnvironmentIsolationGateContract(
                connectsBroker: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("connectsBroker"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverEnvironmentIsolationGateContract(
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionTradingEnabledByDefault")
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverEnvironmentSwitchEvidence(
                evidenceID: Identifier.constant("gh-504-unsafe-automatic-switch"),
                fromScope: .dryRun,
                toScope: .futureProduction,
                triggerIdentity: "unsafe automatic production switch",
                blockedReason: "must be rejected",
                allowsAutomaticSwitch: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("allowsAutomaticSwitch"))
        }
    }

    func testGH505BrokerVenueCapabilityMatrixBindsCredentialAndEnvironmentGates() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)

        let credentialGate = try ProductionCutoverCredentialSecretPolicyGate.deterministicFixture()
        let environmentGate = try ProductionCutoverEnvironmentIsolationGateContract.deterministicFixture()
        let matrix = try ProductionCutoverBrokerVenueCapabilityMatrix.deterministicFixture()
        XCTAssertTrue(credentialGate.contractHeld)
        XCTAssertTrue(environmentGate.contractHeld)
        XCTAssertTrue(matrix.matrixHeld)
        XCTAssertTrue(matrix.domainCoverageHeld)
        XCTAssertEqual(matrix.issueID.rawValue, "GH-505")
        XCTAssertEqual(matrix.upstreamIssueIDs.map(\.rawValue), ["GH-503", "GH-504"])
        XCTAssertEqual(matrix.canonicalQueueRange, "GH-503..GH-510")
        XCTAssertEqual(Set(matrix.rows.map(\.domain)), Set(ProductionCutoverBrokerCapabilityDomain.allCases))
        XCTAssertEqual(Set(matrix.states), Set(ProductionCutoverBrokerCapabilityState.allCases))
        XCTAssertEqual(
            Set(matrix.forbiddenCapabilities),
            Set(ProductionCutoverBrokerVenueForbiddenCapability.allCases)
        )
        XCTAssertTrue(matrix.validationAnchors.contains("GH-505-CAPABILITY-TAXONOMY"))
        XCTAssertTrue(matrix.validationAnchors.contains("GH-505-NO-BROKER-ADAPTER-IMPLEMENTATION"))

        XCTAssertFalse(matrix.brokerSelectionIsExecutionAuthorization)
        XCTAssertTrue(matrix.credentialPolicyGateRequired)
        XCTAssertTrue(matrix.environmentIsolationGateRequired)
        XCTAssertTrue(matrix.readinessMatrixOnly)

        for forbidden in [
            matrix.implementsBrokerAdapter,
            matrix.connectsBroker,
            matrix.callsSignedEndpoint,
            matrix.callsAccountEndpoint,
            matrix.createsListenKey,
            matrix.opensPrivateWebSocket,
            matrix.implementsRealOrderLifecycle,
            matrix.submitsRealOrder,
            matrix.cancelsRealOrder,
            matrix.replacesRealOrder,
            matrix.parsesExecutionReport,
            matrix.parsesBrokerFill,
            matrix.performsReconciliation
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(executionClientTarget.contains("\"BrokerCapabilityMatrix\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/BrokerCapabilityMatrix/ProductionCutoverBrokerVenueCapabilityMatrix.swift"
                ).path
            )
        )
    }

    func testGH505BrokerVenueCapabilityMatrixRejectsAdapterEndpointAndOrderBypass() throws {
        XCTAssertThrowsError(
            try ProductionCutoverBrokerVenueCapabilityMatrix(
                implementsBrokerAdapter: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("implementsBrokerAdapter"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverBrokerVenueCapabilityMatrix(
                callsSignedEndpoint: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("callsSignedEndpoint"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverBrokerVenueCapabilityMatrix(
                submitsRealOrder: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverBrokerVenueCapabilityRow(
                domain: .signedTrading,
                state: .futureGated,
                evidence: "unsafe endpoint row",
                callsSignedEndpoint: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("callsSignedEndpoint"))
        }
    }

    func testGH506ManualApprovalGateBindsUpstreamCutoverReadinessEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let credentialGate = try ProductionCutoverCredentialSecretPolicyGate.deterministicFixture()
        let environmentGate = try ProductionCutoverEnvironmentIsolationGateContract.deterministicFixture()
        let brokerMatrix = try ProductionCutoverBrokerVenueCapabilityMatrix.deterministicFixture()
        let manualGate = try ProductionCutoverManualApprovalGate.deterministicFixture()

        XCTAssertTrue(credentialGate.contractHeld)
        XCTAssertTrue(environmentGate.contractHeld)
        XCTAssertTrue(brokerMatrix.matrixHeld)
        XCTAssertTrue(manualGate.gateHeld)
        XCTAssertTrue(manualGate.checklistCoverageHeld)
        XCTAssertEqual(manualGate.issueID.rawValue, "GH-506")
        XCTAssertEqual(manualGate.upstreamIssueIDs.map(\.rawValue), ["GH-503", "GH-504", "GH-505"])
        XCTAssertEqual(manualGate.canonicalQueueRange, "GH-503..GH-510")
        XCTAssertEqual(
            Set(manualGate.checkpoints),
            Set(ProductionCutoverManualApprovalCheckpoint.allCases)
        )
        XCTAssertEqual(
            Set(manualGate.forbiddenCapabilities),
            Set(ProductionCutoverManualApprovalForbiddenCapability.allCases)
        )
        XCTAssertTrue(manualGate.validationAnchors.contains("GH-506-OPERATOR-CONFIRMATION-CHECKLIST"))
        XCTAssertTrue(manualGate.validationAnchors.contains("GH-506-NO-APPROVAL-BYPASS"))

        XCTAssertTrue(manualGate.credentialPolicyGateRequired)
        XCTAssertTrue(manualGate.environmentIsolationGateRequired)
        XCTAssertTrue(manualGate.brokerVenueCapabilityMatrixRequired)
        XCTAssertTrue(manualGate.manualApprovalRequired)
        XCTAssertTrue(manualGate.operatorConfirmationRequired)
        XCTAssertTrue(manualGate.futureDedicatedCutoverIssueRequired)
        XCTAssertTrue(manualGate.productionCommandBlockedByDefault)

        for forbidden in [
            manualGate.approvalGranted,
            manualGate.allowsConfigDefaultApproval,
            manualGate.allowsEnvironmentVariableApproval,
            manualGate.allowsUIApprovalBypass,
            manualGate.allowsScriptApprovalBypass,
            manualGate.sandboxCommandPromotesProductionCommand,
            manualGate.exposesLiveCommandSurface,
            manualGate.exposesTradingButton,
            manualGate.exposesOrderForm,
            manualGate.readsSecretValue,
            manualGate.connectsBroker,
            manualGate.implementsProductionApprovalSystem,
            manualGate.implementsProductionOMS,
            manualGate.submitsRealOrder,
            manualGate.cancelsRealOrder,
            manualGate.replacesRealOrder
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ProductionCutoverManualApprovalGate.swift"
                ).path
            )
        )
    }

    func testGH506ManualApprovalGateRejectsConfigEnvUIAndSandboxBypass() throws {
        XCTAssertThrowsError(
            try ProductionCutoverManualApprovalGate(
                allowsConfigDefaultApproval: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("allowsConfigDefaultApproval"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverManualApprovalGate(
                allowsEnvironmentVariableApproval: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("allowsEnvironmentVariableApproval")
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverManualApprovalGate(
                exposesTradingButton: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesTradingButton"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverManualApprovalGate(
                sandboxCommandPromotesProductionCommand: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("sandboxCommandPromotesProductionCommand")
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverManualApprovalEvidence(
                evidenceID: Identifier.constant("gh-506-unsafe-ui-bypass"),
                checkpoint: .operatorConfirmationChecklist,
                expectedEvidence: "unsafe approval bypass",
                blockedReason: "must be rejected",
                allowsUIApprovalBypass: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("allowsUIApprovalBypass"))
        }
    }

    func testGH507IncidentRollbackNoTradeGateBindsManualApprovalAndNoTradePriority() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let manualGate = try ProductionCutoverManualApprovalGate.deterministicFixture()
        let incidentGate = try ProductionCutoverIncidentRollbackNoTradeGate.deterministicFixture()

        XCTAssertTrue(manualGate.gateHeld)
        XCTAssertTrue(incidentGate.gateHeld)
        XCTAssertTrue(incidentGate.rollbackChecklistCoverageHeld)
        XCTAssertEqual(incidentGate.issueID.rawValue, "GH-507")
        XCTAssertEqual(incidentGate.upstreamIssueIDs.map(\.rawValue), ["GH-506"])
        XCTAssertEqual(incidentGate.canonicalQueueRange, "GH-503..GH-510")
        XCTAssertEqual(
            Set(incidentGate.states),
            Set(ProductionCutoverIncidentReadinessState.allCases)
        )
        XCTAssertEqual(
            Set(incidentGate.forbiddenCapabilities),
            Set(ProductionCutoverIncidentForbiddenCapability.allCases)
        )
        XCTAssertTrue(incidentGate.validationAnchors.contains("GH-507-NO-TRADE-STATE-PRIORITY"))
        XCTAssertTrue(incidentGate.validationAnchors.contains("GH-507-NO-PRODUCTION-RUNTIME-COMMAND"))

        XCTAssertTrue(incidentGate.manualApprovalGateRequired)
        XCTAssertTrue(incidentGate.productionNoDefaultTradingRequired)
        XCTAssertTrue(incidentGate.rollbackChecklistRequired)
        XCTAssertTrue(incidentGate.noTradeStatePriorityRequired)
        XCTAssertTrue(incidentGate.productionBlockedDryRunDefault)

        for forbidden in [
            incidentGate.implementsEmergencyStopRuntime,
            incidentGate.implementsShutdownRuntime,
            incidentGate.implementsRestoreRuntime,
            incidentGate.implementsProductionOperationsRuntime,
            incidentGate.exposesLiveCommandSurface,
            incidentGate.exposesTradingButton,
            incidentGate.exposesOrderForm,
            incidentGate.connectsBroker,
            incidentGate.parsesBrokerFill,
            incidentGate.performsReconciliation,
            incidentGate.bypassesNoTradeState,
            incidentGate.productionTradingEnabledByDefault,
            incidentGate.submitsRealOrder,
            incidentGate.cancelsRealOrder,
            incidentGate.replacesRealOrder
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ProductionCutoverIncidentRollbackNoTradeGate.swift"
                ).path
            )
        )
    }

    func testGH507IncidentRollbackNoTradeGateRejectsRuntimeCommandAndOrderBypass() throws {
        XCTAssertThrowsError(
            try ProductionCutoverIncidentRollbackNoTradeGate(
                implementsEmergencyStopRuntime: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsEmergencyStopRuntime")
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverIncidentRollbackNoTradeGate(
                exposesLiveCommandSurface: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesLiveCommandSurface"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverIncidentRollbackNoTradeGate(
                bypassesNoTradeState: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("bypassesNoTradeState"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverIncidentRollbackNoTradeGate(
                submitsRealOrder: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverIncidentRollbackEvidence(
                evidenceID: Identifier.constant("gh-507-unsafe-runtime-command"),
                state: .incidentStop,
                expectedEvidence: "unsafe runtime command",
                blockedReason: "must be rejected",
                runtimeCommandImplemented: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runtimeCommandImplemented"))
        }
    }

    func testGH508CapitalRiskLimitGateBindsBrokerMatrixAndManualApproval() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let brokerMatrix = try ProductionCutoverBrokerVenueCapabilityMatrix.deterministicFixture()
        let manualGate = try ProductionCutoverManualApprovalGate.deterministicFixture()
        let limitGate = try ProductionCutoverCapitalRiskLimitGate.deterministicFixture()

        XCTAssertTrue(brokerMatrix.matrixHeld)
        XCTAssertTrue(manualGate.gateHeld)
        XCTAssertTrue(limitGate.gateHeld)
        XCTAssertTrue(limitGate.limitEvidenceCoverageHeld)
        XCTAssertEqual(limitGate.issueID.rawValue, "GH-508")
        XCTAssertEqual(limitGate.upstreamIssueIDs.map(\.rawValue), ["GH-505", "GH-506"])
        XCTAssertEqual(limitGate.canonicalQueueRange, "GH-503..GH-510")
        XCTAssertEqual(
            Set(limitGate.limitKinds),
            Set(ProductionCutoverCapitalRiskLimitKind.allCases)
        )
        XCTAssertEqual(
            Set(limitGate.states),
            Set(ProductionCutoverCapitalRiskLimitState.allCases)
        )
        XCTAssertEqual(
            Set(limitGate.forbiddenCapabilities),
            Set(ProductionCutoverCapitalRiskForbiddenCapability.allCases)
        )
        XCTAssertTrue(limitGate.validationAnchors.contains("GH-508-BINDS-GH505-GH506"))
        XCTAssertTrue(limitGate.validationAnchors.contains("GH-508-NO-LIVE-RISK-PRETRADE-RUNTIME"))

        XCTAssertTrue(limitGate.brokerVenueCapabilityMatrixRequired)
        XCTAssertTrue(limitGate.manualApprovalGateRequired)
        XCTAssertTrue(limitGate.productionNoDefaultTradingRequired)
        XCTAssertTrue(limitGate.blockedDryRunNoTradeDefault)

        for forbidden in [
            limitGate.implementsLiveRiskEngine,
            limitGate.evaluatesRealPreTradeAllowReject,
            limitGate.readsRealAccountBalance,
            limitGate.readsBrokerPosition,
            limitGate.readsMarginOrLeverage,
            limitGate.readsRealPnL,
            limitGate.implementsCapitalAllocationRuntime,
            limitGate.connectsBroker,
            limitGate.implementsOMS,
            limitGate.implementsBrokerGateway,
            limitGate.productionTradingEnabledByDefault,
            limitGate.submitsRealOrder,
            limitGate.cancelsRealOrder,
            limitGate.replacesRealOrder
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/RiskEngine/LiveGate/ProductionCutoverCapitalRiskLimitGate.swift"
                ).path
            )
        )
    }

    func testGH508CapitalRiskLimitGateRejectsLiveRiskRuntimeAndAccountReads() throws {
        XCTAssertThrowsError(
            try ProductionCutoverCapitalRiskLimitGate(
                implementsLiveRiskEngine: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("implementsLiveRiskEngine"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverCapitalRiskLimitGate(
                evaluatesRealPreTradeAllowReject: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("evaluatesRealPreTradeAllowReject")
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverCapitalRiskLimitGate(
                readsRealAccountBalance: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRealAccountBalance"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverCapitalRiskLimitGate(
                submitsRealOrder: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverCapitalRiskLimitEvidence(
                evidenceID: Identifier.constant("gh-508-unsafe-broker-position-read"),
                kind: .exposure,
                state: .futureGated,
                expectedEvidence: "unsafe broker position read",
                blockedReason: "must be rejected",
                readsBrokerPosition: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsBrokerPosition"))
        }
    }

    func testGH509DryRunShadowNoDefaultTradingEvidenceBindsUpstreamGatesAndReadModelSurfaces() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let manualGate = try ProductionCutoverManualApprovalGate.deterministicFixture()
        let incidentGate = try ProductionCutoverIncidentRollbackNoTradeGate.deterministicFixture()
        let limitGate = try ProductionCutoverCapitalRiskLimitGate.deterministicFixture()
        let evidence = try ProductionCutoverDryRunShadowNoDefaultTradingEvidence.deterministicFixture()

        XCTAssertTrue(manualGate.gateHeld)
        XCTAssertTrue(incidentGate.gateHeld)
        XCTAssertTrue(limitGate.gateHeld)
        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.proofCoverageHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-509")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-506", "GH-507", "GH-508"])
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-503..GH-510")
        XCTAssertEqual(Set(evidence.modes), Set(ProductionCutoverDryRunProofMode.allCases))
        XCTAssertEqual(Set(evidence.surfaces), Set(ProductionCutoverDryRunEvidenceSurface.allCases))
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ProductionCutoverDryRunForbiddenCapability.allCases)
        )
        XCTAssertTrue(evidence.validationAnchors.contains("GH-509-REPORT-DASHBOARD-EVENTS-READ-MODEL-ONLY"))
        XCTAssertTrue(evidence.validationAnchors.contains("GH-509-NO-SANDBOX-TO-PRODUCTION-PROMOTION"))

        XCTAssertTrue(evidence.manualApprovalGateRequired)
        XCTAssertTrue(evidence.incidentRollbackNoTradeGateRequired)
        XCTAssertTrue(evidence.capitalRiskLimitGateRequired)
        XCTAssertTrue(evidence.noDefaultTradingRequired)
        XCTAssertTrue(evidence.reportSurfaceReadModelOnly)
        XCTAssertTrue(evidence.dashboardSurfaceReadModelOnly)
        XCTAssertTrue(evidence.eventsSurfaceReadModelOnly)

        for forbidden in [
            evidence.implementsProductionExecution,
            evidence.implementsRealBrokerShadowTrading,
            evidence.connectsBroker,
            evidence.readsSecretValue,
            evidence.callsSignedEndpoint,
            evidence.callsAccountEndpoint,
            evidence.createsListenKey,
            evidence.opensPrivateWebSocket,
            evidence.sandboxCommandPromotesProductionCommand,
            evidence.productionTradingEnabledByDefault,
            evidence.submitsRealOrder,
            evidence.cancelsRealOrder,
            evidence.replacesRealOrder,
            evidence.exposesLiveCommandSurface,
            evidence.exposesTradingButton,
            evidence.exposesOrderForm
        ] {
            XCTAssertFalse(forbidden)
        }

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ProductionCutoverDryRunShadowNoDefaultTradingEvidence.swift"
                ).path
            )
        )
    }

    func testGH509DryRunShadowNoDefaultTradingEvidenceRejectsBrokerSecretAndProductionPromotion() throws {
        XCTAssertThrowsError(
            try ProductionCutoverDryRunShadowNoDefaultTradingEvidence(
                implementsProductionExecution: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsProductionExecution")
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverDryRunShadowNoDefaultTradingEvidence(
                readsSecretValue: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsSecretValue"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverDryRunShadowNoDefaultTradingEvidence(
                sandboxCommandPromotesProductionCommand: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("sandboxCommandPromotesProductionCommand")
            )
        }

        XCTAssertThrowsError(
            try ProductionCutoverDryRunShadowNoDefaultTradingEvidence(
                submitsRealOrder: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }

        XCTAssertThrowsError(
            try ProductionCutoverDryRunProofEvidence(
                evidenceID: Identifier.constant("gh-509-unsafe-secret-read"),
                mode: .shadow,
                expectedEvidence: "unsafe shadow secret read",
                blockedReason: "must be rejected",
                readsSecretValue: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsSecretValue"))
        }
    }

    func testGH510ProductionCutoverReadinessStageAuditInputDocumentsCompleteEvidenceChain() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let stageAuditInput = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/audit/inputs/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-audit-input.md"
            ),
            encoding: .utf8
        )
        let validationMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )

        for expected in [
            "GH-510-STAGE-AUDIT-INPUT",
            "TVM-PRODUCTION-CUTOVER-READINESS-REAL-BROKER-GATE",
            "Parent Codex Handoff",
            "git diff --check",
            "bash checks/automation-readiness.sh",
            "bash checks/run.sh"
        ] {
            XCTAssertTrue(stageAuditInput.contains(expected), "Stage audit input must contain \(expected)")
        }

        for issueID in ["GH-503", "GH-504", "GH-505", "GH-506", "GH-507", "GH-508", "GH-509", "GH-510"] {
            XCTAssertTrue(stageAuditInput.contains(issueID), "Stage audit input must cover \(issueID)")
            XCTAssertTrue(validationMatrix.contains(issueID), "Validation matrix must cover \(issueID)")
        }

        for pullRequest in ["PR #511", "PR #512", "PR #513", "PR #514", "PR #515", "PR #516", "PR #517"] {
            XCTAssertTrue(stageAuditInput.contains(pullRequest), "Stage audit input must record \(pullRequest)")
        }

        XCTAssertTrue(validationMatrix.contains("TVM-PRODUCTION-CUTOVER-READINESS-REAL-BROKER-GATE"))
        XCTAssertTrue(validationMatrix.contains("GH-503..GH-510 issue backfill"))
        XCTAssertTrue(automationReadiness.contains("Production Cutover Readiness stage audit input anchor"))
        XCTAssertTrue(
            automationReadiness.contains(
                "docs/audit/inputs/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-audit-input.md"
            )
        )
        XCTAssertTrue(
            automationReadiness.contains(
                "testGH510ProductionCutoverReadinessStageAuditInputDocumentsCompleteEvidenceChain"
            )
        )
        XCTAssertTrue(stageAuditInput.contains("不输出最终 Stage Code Audit Report"))
    }

    func testGH510ProductionCutoverReadinessCloseoutRejectsProductionRuntimeAuthorization() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let stageAuditInput = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/audit/inputs/mtpro-production-cutover-readiness-real-broker-enablement-gate-v1-stage-audit-input.md"
            ),
            encoding: .utf8
        )

        for forbiddenBoundary in [
            "不授权 production cutover",
            "不连接 broker",
            "不读取真实 secret",
            "不提交 / 撤销 / 替换真实订单",
            "不实现 production OMS",
            "不创建下一阶段 Project / Issue",
            "不推进 Todo",
            "不输出最终 Stage Code Audit Report"
        ] {
            XCTAssertTrue(stageAuditInput.contains(forbiddenBoundary), "Stage audit input must preserve \(forbiddenBoundary)")
        }
    }

    func testGH434DeterministicValueObjectConstantsUseExplicitConstructors() throws {
        let identifier = Identifier.constant(" gh-434-identifier ", field: "gh434Identifier")
        XCTAssertEqual(identifier.rawValue, "gh-434-identifier")
        XCTAssertEqual(FixtureVersion.constant("fixture-v1").rawValue, "fixture-v1")
        XCTAssertEqual(ScenarioID.constant("mtp-104-btcusdt-1m-first-scenario").rawValue, "mtp-104-btcusdt-1m-first-scenario")
        XCTAssertEqual(DatasetVersion.constant("dataset-v1").rawValue, "dataset-v1")
        XCTAssertTrue(ScenarioReportInputVersion.constant().reportInputBoundaryHeld)

        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let sourceFiles = try swiftFiles(
            under: repositoryRoot,
            relativeRoots: ["Sources"]
        )
        let forbiddenForceTryValueObjects = [
            "try! Identifier(",
            "try! FixtureVersion(",
            "try! ScenarioID(",
            "try! DatasetVersion(",
            "try! ScenarioReportInputVersion()"
        ]

        let violations = try sourceFiles.flatMap { file -> [String] in
            let source = try String(contentsOf: file, encoding: .utf8)
            let relativePath = relativePath(for: file, repositoryRoot: repositoryRoot)
            return source.components(separatedBy: .newlines).enumerated().compactMap { index, line in
                guard let forbidden = forbiddenForceTryValueObjects.first(where: { line.contains($0) }) else {
                    return nil
                }
                return "\(relativePath):\(index + 1): \(forbidden): \(line.trimmingCharacters(in: .whitespaces))"
            }
        }

        XCTAssertTrue(
            violations.isEmpty,
            """
            GH-434 deterministic value object constants must use explicit constant constructors.
            Violations:
            \(violations.joined(separator: "\n"))
            """
        )
    }

    func testGH435URLSessionBinanceTransportUsesActorIsolationWithoutUncheckedSendable() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let adapterSourceURL = repositoryRoot.appendingPathComponent(
            "Sources/DataClient/Binance/PublicMarketData/Adapters.swift"
        )
        let adapterSource = try String(contentsOf: adapterSourceURL, encoding: .utf8)

        XCTAssertTrue(
            adapterSource.contains("public actor URLSessionBinancePublicMarketDataTransport"),
            "GH-435 expects the real URLSession public transport to use actor isolation."
        )
        XCTAssertFalse(
            adapterSource.contains("URLSessionBinancePublicMarketDataTransport: BinancePublicMarketDataTransport, @unchecked Sendable"),
            "GH-435 must not keep the previous unchecked Sendable URLSession transport declaration."
        )

        let sourceFiles = try swiftFiles(
            under: repositoryRoot,
            relativeRoots: ["Sources"]
        )
        let uncheckedSendableOccurrences = try sourceFiles.flatMap { file -> [String] in
            let source = try String(contentsOf: file, encoding: .utf8)
            let relativePath = relativePath(for: file, repositoryRoot: repositoryRoot)
            return source.components(separatedBy: .newlines).enumerated().compactMap { index, line in
                guard line.contains("@unchecked Sendable") else {
                    return nil
                }
                return "\(relativePath):\(index + 1): \(line.trimmingCharacters(in: .whitespaces))"
            }
        }

        XCTAssertTrue(
            uncheckedSendableOccurrences.isEmpty,
            """
            GH-435 production sources must not use unchecked Sendable escape hatches.
            Violations:
            \(uncheckedSendableOccurrences.joined(separator: "\n"))
            """
        )
    }

    func testGH436DataClientAndTraderForbiddenImplementationShapesStayOutOfActiveSource() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let traderTarget = try packageTargetBlock(named: "Trader", packageSource: packageSource)

        XCTAssertTrue(
            traderTarget.contains("dependencies: [\"DomainModel\", \"MessageBus\", \"Cache\", \"TraderStrategies\", \"Portfolio\", \"RiskEngine\"]"),
            "GH-436 expects Trader to remain a proposal / coordination container without ExecutionEngine dependency."
        )
        XCTAssertFalse(
            traderTarget.contains("\"ExecutionEngine\""),
            "GH-436: Trader target must not depend directly on ExecutionEngine."
        )
        XCTAssertFalse(
            traderTarget.contains("\"ExecutionClient\""),
            "GH-436: Trader target must not depend directly on ExecutionClient."
        )

        let dataClientSourceFiles = try swiftFiles(
            under: repositoryRoot,
            relativeRoots: ["Sources/DataClient"]
        )
        let violations = try dataClientSourceFiles.flatMap { file in
            try forbiddenDataClientImplementationOccurrences(in: file, repositoryRoot: repositoryRoot)
        }

        XCTAssertTrue(
            violations.isEmpty,
            """
            GH-436 precise forbidden implementation guard failed.
            DataClient may document and reject forbidden capabilities, but active source must not implement \
            signed/account/order endpoints, API-key headers, HMAC/signature generation, or credential storage.
            Violations:
            \(violations.joined(separator: "\n"))
            """
        )
    }

    func testGH437SwiftStyleConfigurationIsDocumentedWithoutWholeRepoReformat() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let styleConfigURL = repositoryRoot.appendingPathComponent(".swift-format")
        let styleDocURL = repositoryRoot.appendingPathComponent("docs/validation/swift-style.md")
        let runScriptURL = repositoryRoot.appendingPathComponent("checks/run.sh")

        XCTAssertTrue(FileManager.default.fileExists(atPath: styleConfigURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: styleDocURL.path))

        let styleConfig = try String(contentsOf: styleConfigURL, encoding: .utf8)
        XCTAssertTrue(styleConfig.contains("\"version\": 1"))
        XCTAssertTrue(styleConfig.contains("\"lineLength\": 120"))
        XCTAssertTrue(styleConfig.contains("\"spaces\": 4"))
        XCTAssertTrue(styleConfig.contains("\"maximumBlankLines\": 1"))
        XCTAssertTrue(styleConfig.contains("\"respectsExistingLineBreaks\": true"))

        let styleDoc = try String(contentsOf: styleDocURL, encoding: .utf8)
        XCTAssertTrue(styleDoc.contains("GH-437-SWIFT-STYLE-CONFIGURATION"))
        XCTAssertTrue(styleDoc.contains("swift-format lint --configuration .swift-format --recursive Sources Tests Package.swift"))
        XCTAssertTrue(styleDoc.contains("本阶段不做全仓格式化"))
        XCTAssertTrue(styleDoc.contains("不把 formatter 强制接入 `checks/run.sh`"))

        let runScript = try String(contentsOf: runScriptURL, encoding: .utf8)
        XCTAssertFalse(
            runScript.contains("swift-format"),
            "GH-437 must not make checks/run.sh depend on an unavailable formatter."
        )
    }

    func testGH445DeterministicDefaultsUseNamedFactoriesInsteadOfTryBang() throws {
        XCTAssertEqual(Symbol.constant("BTCUSDT").rawValue, "BTCUSDT")
        XCTAssertEqual(
            DateRange.constant(
                start: Date(timeIntervalSince1970: 1_704_067_200),
                end: Date(timeIntervalSince1970: 1_704_067_260)
            ).end.timeIntervalSince1970,
            1_704_067_260
        )
        XCTAssertEqual(ScenarioReplayWindow.constant().recordCount, 3)
        XCTAssertEqual(ScenarioReplayCursor.constant(nextRecordSequence: 2).nextRecordSequence, 2)
        XCTAssertTrue(ScenarioReplayChecksumEvidence.constant().parityEvidenceStable)
        XCTAssertTrue(ScenarioReplayFreshnessPolicy.constant().retainFixtureLocally)
        XCTAssertTrue(ScenarioReplayFreshnessEvidence.constant().isLocalFixtureFreshnessOnly)
        XCTAssertTrue(ScenarioDataQualityGateEvaluation.constant().qualityGateBoundaryHeld)

        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let scannedFiles = try swiftFiles(
            under: repositoryRoot,
            relativeRoots: [
                "Sources/DataEngine/ScenarioReplay",
                "Sources/DataEngine/DataQuality",
                "Sources/Portfolio",
                "Sources/Dashboard/Report"
            ]
        ) + [
            repositoryRoot.appendingPathComponent("Sources/Core/DashboardBetaDemoScenario.swift")
        ]

        let violations = try scannedFiles.flatMap { file -> [String] in
            let source = try String(contentsOf: file, encoding: .utf8)
            let relativePath = relativePath(for: file, repositoryRoot: repositoryRoot)
            return source.components(separatedBy: .newlines).enumerated().compactMap { index, line in
                let implementationLine = line.components(separatedBy: "//").first ?? line
                guard implementationLine.contains("try!") else {
                    return nil
                }
                return "\(relativePath):\(index + 1): \(line.trimmingCharacters(in: .whitespaces))"
            }
        }

        XCTAssertTrue(
            violations.isEmpty,
            """
            GH-445 deterministic replay / data quality / simulated parity / dashboard defaults must use named factory entrypoints \
            instead of bare try!.
            Violations:
            \(violations.joined(separator: "\n"))
            """
        )
    }

    private struct UnsafeConstructOccurrence {
        let relativePath: String
        let lineNumber: Int
        let construct: String
        let line: String
        let context: String

        var description: String {
            "\(relativePath):\(lineNumber): \(construct): \(line.trimmingCharacters(in: .whitespaces))"
        }
    }

    private func gh497SandboxEnvelope(
        kind: L4ExecutionClientSandboxCommandKind
    ) throws -> L4ExecutionClientSandboxRequestEnvelope {
        try L4ExecutionClientSandboxRequestEnvelope(
            envelopeID: Identifier.constant("gh-459-sandbox-\(kind.rawValue)-request-envelope"),
            commandKind: kind,
            clientOrderID: Identifier.constant("gh-459-sandbox-client-order-\(kind.rawValue)"),
            symbol: "BTCUSDT",
            quantity: "0.0100",
            limitPrice: "42120.70",
            reason: "GH-459 deterministic sandbox \(kind.rawValue) evidence"
        )
    }

    private func gh497SandboxReportFixtures() throws -> [L4ExecutionClientSandboxReportFixture] {
        try [
            gh497SandboxReportFixture(kind: .fill, commandKind: .submit, sequence: 1),
            gh497SandboxReportFixture(kind: .partialFill, commandKind: .replace, sequence: 2),
            gh497SandboxReportFixture(kind: .reject, commandKind: .submit, sequence: 3),
            gh497SandboxReportFixture(kind: .cancelAcknowledgement, commandKind: .cancel, sequence: 4)
        ]
    }

    private func gh497SandboxReportFixture(
        kind: L4ExecutionClientSandboxReportKind,
        commandKind: L4ExecutionClientSandboxCommandKind,
        sequence: Int
    ) throws -> L4ExecutionClientSandboxReportFixture {
        try L4ExecutionClientSandboxReportFixture(
            reportID: Identifier.constant("gh-460-sandbox-\(gh497EventIDComponent(for: kind))-report"),
            reportKind: kind,
            relatedCommandKind: commandKind,
            clientOrderID: Identifier.constant("gh-459-sandbox-client-order-\(commandKind.rawValue)"),
            symbol: "BTCUSDT",
            filledQuantity: gh497FilledQuantity(for: kind),
            remainingQuantity: gh497RemainingQuantity(for: kind),
            reportStatus: L4ExecutionClientSandboxReportFixture.expectedStatus(for: kind),
            replaySequence: sequence,
            sandboxTraceID: Identifier.constant("gh-459-sandbox-\(commandKind.rawValue)-trace"),
            rawPayloadDigest: "sha256:gh-460-sandbox-\(gh497EventIDComponent(for: kind))-fixture"
        )
    }

    private func gh497EventIDComponent(for kind: L4ExecutionClientSandboxReportKind) -> String {
        switch kind {
        case .fill:
            "fill"
        case .partialFill:
            "partial-fill"
        case .reject:
            "reject"
        case .cancelAcknowledgement:
            "cancel-acknowledgement"
        }
    }

    private func gh497FilledQuantity(for kind: L4ExecutionClientSandboxReportKind) -> String {
        switch kind {
        case .fill:
            "0.0100"
        case .partialFill:
            "0.0040"
        case .reject, .cancelAcknowledgement:
            "0.0000"
        }
    }

    private func gh497RemainingQuantity(for kind: L4ExecutionClientSandboxReportKind) -> String {
        switch kind {
        case .fill:
            "0.0000"
        case .partialFill:
            "0.0060"
        case .reject, .cancelAcknowledgement:
            "0.0100"
        }
    }

    private func swiftFiles(under repositoryRoot: URL, relativeRoots: [String]) throws -> [URL] {
        let fileManager = FileManager.default
        var files: [URL] = []

        for relativeRoot in relativeRoots {
            let root = repositoryRoot.appendingPathComponent(relativeRoot)
            guard let enumerator = fileManager.enumerator(
                at: root,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsPackageDescendants]
            ) else {
                continue
            }

            for case let url as URL in enumerator {
                let values = try url.resourceValues(forKeys: [.isRegularFileKey])
                guard values.isRegularFile == true, url.pathExtension == "swift" else {
                    continue
                }
                files.append(url)
            }
        }

        return files.sorted { $0.path < $1.path }
    }

    private func unsafeConstructOccurrences(in file: URL, repositoryRoot: URL) throws -> [UnsafeConstructOccurrence] {
        let source = try String(contentsOf: file, encoding: .utf8)
        let relativePath = relativePath(for: file, repositoryRoot: repositoryRoot)
        let lines = source.components(separatedBy: .newlines)

        return lines.enumerated().flatMap { index, line -> [UnsafeConstructOccurrence] in
            let implementationLine = line.components(separatedBy: "//").first ?? line
            return [
                implementationLine.contains("try!") ? "try!" : nil,
                implementationLine.contains("preconditionFailure") ? "preconditionFailure" : nil,
                implementationLine.contains("fatalError") ? "fatalError" : nil
            ].compactMap { construct in
                construct.map {
                    UnsafeConstructOccurrence(
                        relativePath: relativePath,
                        lineNumber: index + 1,
                        construct: $0,
                        line: line,
                        context: unsafeConstructContext(lines: lines, occurrenceIndex: index)
                    )
                }
            }
        }
    }

    private func unsafeConstructContext(lines: [String], occurrenceIndex: Int) -> String {
        let lowerBound = max(0, occurrenceIndex - 90)
        let upperBound = min(lines.count - 1, occurrenceIndex + 6)
        guard lowerBound <= upperBound else {
            return ""
        }
        return lines[lowerBound...upperBound].joined(separator: "\n")
    }

    private func relativePath(for file: URL, repositoryRoot: URL) -> String {
        let rootPath = repositoryRoot.path.hasSuffix("/") ? repositoryRoot.path : "\(repositoryRoot.path)/"
        return file.path.replacingOccurrences(of: rootPath, with: "")
    }

    private func isAllowedUnsafeConstructOccurrence(_ occurrence: UnsafeConstructOccurrence) -> Bool {
        if occurrence.relativePath.hasPrefix("Tests/") {
            return true
        }

        switch occurrence.construct {
        case "try!":
            return false
        case "fatalError":
            return isDeterministicConstantHelperCrash(occurrence)
        case "preconditionFailure":
            return hasAllowedFixtureEvidenceOrBoundaryMarker(occurrence)
        default:
            return false
        }
    }

    private func isDeterministicConstantHelperCrash(_ occurrence: UnsafeConstructOccurrence) -> Bool {
        let context = occurrence.context
        return context.contains("MTPRO deterministic")
            && (
                context.contains("static func constant(")
                    || context.contains("static func deterministic")
                    || context.contains("static var deterministic")
            )
    }

    private func hasAllowedFixtureEvidenceOrBoundaryMarker(_ occurrence: UnsafeConstructOccurrence) -> Bool {
        let context = occurrence.context.lowercased()
        let allowedMarkers = [
            "deterministic",
            "fixture",
            "evidence",
            "contract",
            "boundary",
            "validation rules",
            "acceptance fixture"
        ]

        return allowedMarkers.contains { context.contains($0) }
            || (context.contains("static func required") && context.contains("must be valid"))
    }

    private func forbiddenDataClientImplementationOccurrences(in file: URL, repositoryRoot: URL) throws -> [String] {
        let source = try String(contentsOf: file, encoding: .utf8)
        let relativePath = relativePath(for: file, repositoryRoot: repositoryRoot)
        let gh525SignedAccountReadRuntime = "Sources/DataClient/Binance/SignedAccount/BinanceSignedAccountReadRuntime.swift"
        let gh526PrivateStreamRuntime = "Sources/DataClient/Binance/PrivateStream/BinancePrivateStreamAccountSnapshotRuntime.swift"
        let gh525AllowedPatterns = Set([
            "path: \"/api/v3/account\"",
            "= \"/api/v3/account\"",
            "URLQueryItem(name: \"signature\"",
            "forHTTPHeaderField: \"X-MBX-APIKEY\"",
            "HMAC<"
        ])
        let gh526AllowedPatterns = Set([
            "= \"/api/v3/userDataStream\""
        ])
        let forbiddenImplementationPatterns = [
            "path: \"/api/v3/account\"",
            "path: \"/api/v3/order\"",
            "path: \"/api/v3/userDataStream\"",
            "= \"/api/v3/account\"",
            "= \"/api/v3/order\"",
            "= \"/api/v3/userDataStream\"",
            "URLQueryItem(name: \"signature\"",
            "BinanceQueryItem(name: \"signature\"",
            "forHTTPHeaderField: \"X-MBX-APIKEY\"",
            "headers: [\"X-MBX-APIKEY\"",
            "import CryptoKit",
            "import CryptoSwift",
            "import CommonCrypto",
            "HMAC<",
            "CCHmac",
            "CC_HMAC",
            "let apiKey",
            "var apiKey",
            "let apiSecret",
            "var apiSecret",
            "let secretKey",
            "var secretKey"
        ]

        return source.components(separatedBy: .newlines).enumerated().compactMap { index, line in
            let implementationLine = line.components(separatedBy: "//").first ?? line
            guard let forbidden = forbiddenImplementationPatterns.first(where: { implementationLine.contains($0) }) else {
                return nil
            }
            if relativePath == gh525SignedAccountReadRuntime, gh525AllowedPatterns.contains(forbidden) {
                return nil
            }
            if relativePath == gh526PrivateStreamRuntime, gh526AllowedPatterns.contains(forbidden) {
                return nil
            }
            return "\(relativePath):\(index + 1): \(forbidden): \(line.trimmingCharacters(in: .whitespaces))"
        }
    }

    private func assertNoForbiddenBinancePublicRequestFragments(
        _ contracts: [BinancePublicRequestContract],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let serializedRequests = contracts
            .flatMap { contract in
                [contract.path] + contract.queryItems.flatMap { [$0.name, $0.value] }
            }
            .joined(separator: " ")
            .lowercased()

        XCTAssertFalse(serializedRequests.contains("apikey"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("signature"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("listenkey"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/api/v3/account"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/api/v3/order"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/api/v3/userdatastream"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/sapi/"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/fapi/"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/dapi/"), file: file, line: line)
    }

    private func packageTargetBlock(named targetName: String, packageSource: String) throws -> String {
        let targetMarker = ".target(\n            name: \"\(targetName)\""
        guard let markerRange = packageSource.range(of: targetMarker) else {
            throw XCTSkip("Package.swift target \(targetName) not found")
        }
        let tail = packageSource[markerRange.lowerBound...]
        let nextTargetMarkers = [
            "\n        .target(",
            "\n        .executableTarget(",
            "\n        .testTarget(",
            "\n        .systemLibrary("
        ]
        let searchRange = tail.index(after: markerRange.lowerBound)..<tail.endIndex
        let nextTarget = nextTargetMarkers
            .compactMap { tail.range(of: $0, options: [], range: searchRange) }
            .min { $0.lowerBound < $1.lowerBound }
        if let nextTarget {
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

    private func packageTargetExcludesBlock(targetBlock: String) throws -> String {
        guard let excludesRange = targetBlock.range(of: "exclude: [") else {
            throw XCTSkip("Package.swift target excludes block not found")
        }
        let tail = targetBlock[excludesRange.lowerBound...]
        guard let closeRange = tail.range(of: "\n            ]") else {
            throw XCTSkip("Package.swift target excludes block is not closed")
        }
        return String(tail[..<closeRange.upperBound])
    }
}

/// TargetGraphTests 专用 mock transport 只返回本地 fixture，不访问 Binance 网络。
private actor TargetGraphMockBinancePublicMarketDataTransport: BinancePublicMarketDataTransport {
    typealias Handler = @Sendable (BinancePublicTransportRequest) throws -> Data

    private let handler: Handler
    private var loadedRequests: [BinancePublicTransportRequest] = []

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func load(_ request: BinancePublicTransportRequest) async throws -> Data {
        loadedRequests.append(request)
        return try handler(request)
    }

    func requests() -> [BinancePublicTransportRequest] {
        loadedRequests
    }
}

/// TargetGraphTests 专用 signed account mock transport 只返回本地 account fixture。
private actor TargetGraphMockBinanceSignedAccountReadTransport: BinanceSignedAccountReadTransport {
    typealias Handler = @Sendable (BinanceSignedAccountReadTransportRequest) throws -> Data

    private let handler: Handler
    private var loadedRequests: [BinanceSignedAccountReadTransportRequest] = []

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func load(_ request: BinanceSignedAccountReadTransportRequest) async throws -> Data {
        loadedRequests.append(request)
        return try handler(request)
    }

    func requests() -> [BinanceSignedAccountReadTransportRequest] {
        loadedRequests
    }
}

/// TargetGraphTests 专用 listenKey lifecycle mock transport 只返回本地 listenKey fixture。
private actor TargetGraphMockBinancePrivateStreamListenKeyTransport: BinancePrivateStreamListenKeyTransport {
    typealias Handler = @Sendable (BinancePrivateStreamListenKeyLifecycleRequest) throws -> Data

    private let handler: Handler
    private var loadedRequests: [BinancePrivateStreamListenKeyLifecycleRequest] = []

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func perform(_ request: BinancePrivateStreamListenKeyLifecycleRequest) async throws -> Data {
        loadedRequests.append(request)
        return try handler(request)
    }

    func requests() -> [BinancePrivateStreamListenKeyLifecycleRequest] {
        loadedRequests
    }
}

/// TargetGraphTests 专用 private stream event source 只返回本地 WebSocket frame fixture。
private actor TargetGraphMockBinancePrivateStreamEventSource: BinancePrivateStreamEventSource {
    private let payloads: [Data]
    private var loadedLeaseReferences: [String] = []

    init(payloads: [Data]) {
        self.payloads = payloads
    }

    func receiveEvents(for lease: BinancePrivateStreamListenKeyLease) async throws -> [Data] {
        loadedLeaseReferences.append(lease.listenKeyReference)
        return payloads
    }

    func leaseReferences() -> [String] {
        loadedLeaseReferences
    }
}
