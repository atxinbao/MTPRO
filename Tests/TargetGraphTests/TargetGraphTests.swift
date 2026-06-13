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
        XCTAssertEqual(trader.activeStrategyRoot, "Sources/Trader/Strategies")
        XCTAssertEqual(trader.coordinationRoot, "Sources/Trader/Coordination/RiskBinding")
        XCTAssertEqual(strategies.activeConcreteStrategies, ["EMA", "RSI"])
        XCTAssertEqual(
            strategies.activeStrategySourceRoots,
            ["Sources/Trader/Strategies/EMA", "Sources/Trader/Strategies/RSI"]
        )
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

        XCTAssertTrue(strategies.nonReleaseActiveStrategySourceRoots.isEmpty)
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

        XCTAssertEqual(TraderStrategiesTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Trader/Strategies/TargetGraph")
        XCTAssertEqual(TraderTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Trader/TargetGraph")
        XCTAssertEqual(PortfolioTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Portfolio/TargetGraph")
        XCTAssertEqual(RiskEngineTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/RiskEngine/TargetGraph")
        XCTAssertEqual(TraderStrategiesTargetBoundary.mtp219.activeConcreteStrategies, ["EMA", "RSI"])
        XCTAssertEqual(TraderTargetBoundary.mtp219.activeStrategyRoot, "Sources/Trader/Strategies")

        for expected in [
            "path: \"Sources/Trader/Strategies\"",
            "\"EMA/EMAProposalRuntime.swift\"",
            "\"EMA/EMACross.swift\"",
            "\"RSI/RSIStrategy.swift\"",
            "\"TargetGraph/TraderStrategiesTargetBoundary.swift\"",
            "path: \"Sources/Trader\"",
            "\"TargetGraph/TraderTargetBoundary.swift\"",
            "path: \"Sources/Portfolio\"",
            "\"TargetGraph/PortfolioTargetBoundary.swift\"",
            "path: \"Sources/RiskEngine\"",
            "\"TargetGraph/RiskEngineTargetBoundary.swift\"",
            "\"Trader/Strategies/TargetGraph\"",
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
            "Sources/Trader/Strategies/TargetGraph/TraderStrategiesTargetBoundary.swift",
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
        XCTAssertEqual(trader.activeStrategyRoot, "Sources/Trader/Strategies")
        XCTAssertEqual(trader.coordinationRoot, "Sources/Trader/Coordination/RiskBinding")
        XCTAssertEqual(trader.activeConcreteStrategies, ["EMA", "RSI"])
        XCTAssertEqual(strategies.activeConcreteStrategies, ["EMA", "RSI"])
        XCTAssertEqual(
            strategies.activeStrategySourceRoots,
            ["Sources/Trader/Strategies/EMA", "Sources/Trader/Strategies/RSI"]
        )
        XCTAssertTrue(strategies.nonReleaseActiveStrategySourceRoots.isEmpty)

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

        XCTAssertTrue(traderStrategiesTarget.contains("path: \"Sources/Trader/Strategies\""))
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
            "path: \"Sources/Trader/Strategies\"",
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
        XCTAssertEqual(TraderStrategiesTargetBoundary.mtp219.compiledBoundaryRoot, "Sources/Trader/Strategies/TargetGraph")
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

    func testGH631FinalEnvelopeRetirementContractClassifiesEveryRetainedSource() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let contract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/core-compatibility-envelope-final-retirement-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )

        for anchor in [
            "GH-631-CEFR-FINAL-ENVELOPE-RETIREMENT-CONTRACT",
            "GH-631-RETAINED-ENVELOPE-SOURCE-INVENTORY",
            "GH-631-REAL-MODULE-OWNER-CLASSIFICATION",
            "GH-631-RETENTION-REASON-AND-EXIT-PATH",
            "GH-631-FIRST-EXECUTABLE-CANDIDATE-ONLY",
            "GH-631-NO-PRODUCTION-AUTHORIZATION",
            "GH-631-VALIDATION-ANCHORS",
            "TVM-CEFR-FINAL-ENVELOPE-RETIREMENT-CONTRACT"
        ] {
            XCTAssertTrue(contract.contains(anchor), "\(anchor) must remain in the CEFR contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must remain in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must remain in trading-validation-matrix.md")
        }

        for retiredDirectory in [
            "Sources/Adapters",
            "Sources/Persistence",
            "Sources/Runtime"
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(retiredDirectory).path),
                "\(retiredDirectory) must not reappear as an active source directory"
            )
        }

        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let adaptersTarget = try packageTargetBlock(named: "Adapters", packageSource: packageSource)
        let persistenceTarget = try packageTargetBlock(named: "Persistence", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)

        let expectedCoreRetainedSources: Set<String> = [
            "Sources/Core/DashboardBetaDemoScenario.swift",
            "Sources/Core/DomainModelCompatibilityImport.swift",
            "Sources/Core/LiveMonitoringConnectionReadinessExplanation.swift",
            "Sources/Core/LiveMonitoringConsole.swift",
            "Sources/Core/LiveMonitoringForbiddenCapabilityTests.swift",
            "Sources/Core/LiveMonitoringSimulationGateHealth.swift",
            "Sources/Core/LiveMonitoringSourceIdentity.swift",
            "Sources/Core/LiveTradingBoundary.swift",
            "Sources/Core/MarketDataCacheCoreReplayCompatibility.swift",
            "Sources/Core/PortfolioProjectionCompatibility.swift",
            "Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift",
            "Sources/Core/ResearchEventFlows.swift",
            "Sources/Core/ResearchResults.swift",
            "Sources/Core/RiskEnginePaperPreTradeRuntimeBridge.swift",
            "Sources/Core/TradingKernel.swift",
            "Sources/MessageBus/CommandsAndQueries.swift",
            "Sources/MessageBus/DomainEvents.swift",
            "Sources/MessageBus/EventLog.swift",
            "Sources/MessageBus/PaperRuntimeBusRouting.swift",
            "Sources/DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift",
            "Sources/Portfolio/PaperAccountPortfolioProjectionV2.swift",
            "Sources/Portfolio/SimulatedExchangePortfolioProjectionParity.swift",
            "Sources/ExecutionEngine/PaperLifecycle/PaperExecutionDecision.swift",
            "Sources/ExecutionEngine/PaperLifecycle/PaperExecutionEventLog.swift",
            "Sources/ExecutionEngine/PaperLifecycle/PaperOrderIntent.swift",
            "Sources/ExecutionEngine/PaperLifecycle/PaperOrderLifecycleCoordinator.swift",
            "Sources/ExecutionEngine/PaperLifecycle/PaperSessionLifecycle.swift",
            "Sources/ExecutionEngine/PaperLifecycle/PaperSessionLocalControlEventLog.swift",
            "Sources/ExecutionEngine/PaperLifecycle/PaperSessionReplay.swift",
            "Sources/ExecutionEngine/SimulatedExchange/BacktestPaperSharedOrderSemantics.swift",
            "Sources/ExecutionEngine/SimulatedExchange/MarketLimitSimulatedExecutionSemantics.swift",
            "Sources/ExecutionEngine/SimulatedExchange/PaperSimulatedFillEvidence.swift",
            "Sources/ExecutionEngine/SimulatedExchange/PartialFillLatencyFeeSlippageParity.swift"
        ]
        let expectedAdaptersRetainedSources: Set<String> = [
            "Sources/DataClient/AdaptersCompatibility.swift"
        ]
        let expectedPersistenceRetainedSources: Set<String> = [
            "Sources/Database/Projections/ReleaseV020SpotPerpDatabaseProjections.swift",
            "Sources/Database/Projections/SQLite/Persistence.swift",
            "Sources/Database/Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift"
        ]
        let expectedRuntimeRetainedSources: Set<String> = [
            "Sources/Database/ReplayProjection/MarketDataReplayProjectionConsistency.swift",
            "Sources/DataEngine/Ingest/MarketDataIngestReplayProjectionWorkflow.swift"
        ]

        XCTAssertEqual(
            try packageTargetSwiftSources(repositoryRoot: repositoryRoot, targetRoot: "Sources", targetBlock: coreTarget),
            expectedCoreRetainedSources
        )
        XCTAssertEqual(
            try packageTargetSwiftSources(
                repositoryRoot: repositoryRoot,
                targetRoot: "Sources/DataClient",
                targetBlock: adaptersTarget
            ),
            expectedAdaptersRetainedSources
        )
        XCTAssertEqual(
            try packageTargetSwiftSources(
                repositoryRoot: repositoryRoot,
                targetRoot: "Sources/Database",
                targetBlock: persistenceTarget
            ),
            expectedPersistenceRetainedSources
        )
        XCTAssertEqual(
            try packageTargetSwiftSources(repositoryRoot: repositoryRoot, targetRoot: "Sources", targetBlock: runtimeTarget),
            expectedRuntimeRetainedSources
        )

        let allRetainedSources = expectedCoreRetainedSources
            .union(expectedAdaptersRetainedSources)
            .union(expectedPersistenceRetainedSources)
            .union(expectedRuntimeRetainedSources)
        for retainedSource in allRetainedSources.sorted() {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(retainedSource).path),
                "\(retainedSource) must exist while it is listed as retained"
            )
            XCTAssertTrue(contract.contains("`\(retainedSource)`"), "\(retainedSource) must be classified in the contract")
        }

        for requiredClassification in [
            "`Core` 只能保留 legacy import surface",
            "`Adapters` 只能保留 `DataClient` compatibility re-export",
            "`Persistence` 只能保留 `Database` projection adapter shim",
            "`Runtime` 只能保留 `DataEngine` ingest 与 `Database` replay projection workflow shim",
            "`GH-631` is the only executable candidate"
        ] {
            XCTAssertTrue(contract.contains(requiredClassification), "\(requiredClassification) must remain explicit")
        }

        for forbiddenDefault in [
            "productionTradingEnabledByDefault == false",
            "productionSecretReadEnabledByDefault == false",
            "productionEndpointConnectionEnabledByDefault == false",
            "productionOrderSubmitEnabledByDefault == false",
            "productionBrokerConnectionEnabledByDefault == false"
        ] {
            XCTAssertTrue(contract.contains(forbiddenDefault), "\(forbiddenDefault) must remain explicit")
        }
    }

    func testGH632MessageBusOwnsRichRoutingCompatibilityContractAndKeepsCoreCompatibilityOnly() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let contract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/core-compatibility-envelope-final-retirement-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )

        for anchor in MessageBusRichRoutingCompatibilityContract.requiredValidationAnchors {
            XCTAssertTrue(contract.contains(anchor), "\(anchor) must remain in CEFR contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must remain in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must remain in trading-validation-matrix.md")
        }

        let messageBusTarget = try packageTargetBlock(named: "MessageBus", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let dashboardTarget = try packageTargetBlock(named: "Dashboard", packageSource: packageSource)
        let cliTarget = try packageTargetBlock(named: "MTPROCLI", packageSource: packageSource)
        let messageBusSources = try packageTargetSourcesBlock(targetBlock: messageBusTarget)
        let coreSources = try packageTargetSourcesBlock(targetBlock: coreTarget)
        let coreExcludes = try packageTargetExcludesBlock(targetBlock: coreTarget)

        XCTAssertTrue(messageBusSources.contains("\"RichRoutingCompatibilityContract.swift\""))
        XCTAssertTrue(coreExcludes.contains("\"MessageBus/RichRoutingCompatibilityContract.swift\""))
        XCTAssertFalse(coreSources.contains("\"MessageBus/RichRoutingCompatibilityContract.swift\""))

        for forbiddenDependency in [
            "\"Trader\"",
            "\"TraderStrategies\"",
            "\"Portfolio\"",
            "\"RiskEngine\"",
            "\"ExecutionEngine\"",
            "\"ExecutionClient\"",
            "\"Dashboard\""
        ] {
            XCTAssertFalse(
                messageBusTarget.contains(forbiddenDependency),
                "MessageBus target must not gain upper-layer dependency \(forbiddenDependency)"
            )
        }

        let evidence = MessageBusRichRoutingCompatibilityContract.gh632
        XCTAssertTrue(evidence.boundaryHeld)
        XCTAssertEqual(
            Set(evidence.retainedSourcePaths),
            MessageBusRichRoutingCompatibilityContract.requiredRetainedSourcePaths
        )
        XCTAssertTrue(evidence.allSurfacesAreCompatibilityOnly)
        XCTAssertTrue(evidence.noProductionAuthorization.allProductionCapabilitiesDisabledByDefault)
        XCTAssertTrue(
            MessageBusTargetBoundary.requiredValidationAnchors.contains(
                "GH-632-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY-CONTRACT"
            )
        )

        for surface in evidence.retainedSurfaces {
            XCTAssertEqual(surface.compiledByCompatibilityEnvelope, "Core")
            XCTAssertEqual(surface.status, .retainedCompatibilityOnly)
            XCTAssertTrue(surface.messageBusOwnsCompatibilityDecision)
            XCTAssertTrue(surface.realModuleOwners.contains("MessageBus"))
            XCTAssertTrue(contract.contains("`\(surface.sourcePath)`"))
            XCTAssertTrue(FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(surface.sourcePath).path
            ))
        }

        XCTAssertTrue(dashboardTarget.contains("dependencies: [\"Core\", \"Persistence\"]"))
        XCTAssertTrue(cliTarget.contains("dependencies: [\"Database\"]"))
        XCTAssertFalse(cliTarget.contains("\"Core\""))
        XCTAssertFalse(cliTarget.contains("\"MessageBus\""))
        XCTAssertFalse(cliTarget.contains("\"ExecutionEngine\""))
        XCTAssertFalse(cliTarget.contains("\"ExecutionClient\""))

        for forbiddenDefault in [
            "productionTradingEnabledByDefault == false",
            "productionSecretReadEnabledByDefault == false",
            "productionEndpointConnectionEnabledByDefault == false",
            "brokerGatewayEnabledByDefault == false",
            "realOrderCommandEnabledByDefault == false",
            "omsRuntimeEnabledByDefault == false",
            "dashboardCommandSurfaceEnabledByDefault == false"
        ] {
            XCTAssertTrue(contract.contains(forbiddenDefault), "\(forbiddenDefault) must remain explicit")
        }
    }

    func testGH633DataEngineOwnsScenarioReplayAndDataQualityWhileCoreRetainsMatchingBridgeOnly() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let contract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/core-compatibility-envelope-final-retirement-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )

        for anchor in ScenarioReplayDataQualityOwnershipContract.requiredValidationAnchors {
            XCTAssertTrue(contract.contains(anchor), "\(anchor) must remain in CEFR contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must remain in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must remain in trading-validation-matrix.md")
        }

        let dataEngineTarget = try packageTargetBlock(named: "DataEngine", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let dataEngineSources = try packageTargetSourcesBlock(targetBlock: dataEngineTarget)
        let coreSources = try packageTargetSourcesBlock(targetBlock: coreTarget)
        let coreExcludes = try packageTargetExcludesBlock(targetBlock: coreTarget)

        for activeSource in ScenarioReplayDataQualityOwnershipContract.requiredActiveDataEngineSourcePaths {
            let packageEntry = activeSource.replacingOccurrences(of: "Sources/DataEngine/", with: "")
            XCTAssertTrue(dataEngineSources.contains("\"\(packageEntry)\""), "\(packageEntry) must be DataEngine-owned")
            XCTAssertTrue(contract.contains("`\(activeSource)`"))
            XCTAssertTrue(FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(activeSource).path
            ))
        }

        XCTAssertTrue(coreExcludes.contains("\"DataEngine/ScenarioReplay/ScenarioReplayDataQualityOwnershipContract.swift\""))
        XCTAssertFalse(coreSources.contains("\"DataEngine/ScenarioReplay/ScenarioReplayDataQualityOwnershipContract.swift\""))
        XCTAssertTrue(coreSources.contains("\"DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift\""))
        XCTAssertFalse(dataEngineSources.contains("\"ScenarioReplay/ScenarioReplayDeterministicMatching.swift\""))

        for forbiddenDependency in [
            "\"Trader\"",
            "\"TraderStrategies\"",
            "\"Portfolio\"",
            "\"RiskEngine\"",
            "\"ExecutionEngine\"",
            "\"ExecutionClient\"",
            "\"Dashboard\""
        ] {
            XCTAssertFalse(
                dataEngineTarget.contains(forbiddenDependency),
                "DataEngine target must not gain upper-layer dependency \(forbiddenDependency)"
            )
        }

        let evidence = ScenarioReplayDataQualityOwnershipContract.gh633
        XCTAssertTrue(evidence.boundaryHeld)
        XCTAssertEqual(
            Set(evidence.activeSourcePaths),
            ScenarioReplayDataQualityOwnershipContract.requiredActiveDataEngineSourcePaths
        )
        XCTAssertEqual(
            Set(evidence.retainedBridgeSourcePaths),
            ScenarioReplayDataQualityOwnershipContract.requiredRetainedBridgeSourcePaths
        )
        XCTAssertTrue(evidence.dataEngineOwnsAllActiveSurfaces)
        XCTAssertTrue(evidence.retainedBridgesAreCompatibilityOnly)
        XCTAssertTrue(evidence.noProductionAuthorization.allProductionCapabilitiesDisabledByDefault)
        XCTAssertTrue(
            DataEngineTargetBoundary.requiredValidationAnchors.contains(
                "GH-633-DATAENGINE-SCENARIO-QUALITY-OWNERSHIP-CONTRACT"
            )
        )

        for bridge in evidence.retainedCompatibilityBridges {
            XCTAssertEqual(bridge.compiledByCompatibilityEnvelope, "Core")
            XCTAssertEqual(bridge.status, .retainedCompatibilityOnly)
            XCTAssertTrue(bridge.realModuleOwners.contains("DataEngine"))
            XCTAssertTrue(bridge.realModuleOwners.contains("ExecutionEngine"))
            XCTAssertTrue(contract.contains("`\(bridge.sourcePath)`"))
            XCTAssertTrue(FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(bridge.sourcePath).path
            ))
        }

        for forbiddenDefault in [
            "productionTradingEnabledByDefault == false",
            "productionSecretReadEnabledByDefault == false",
            "productionEndpointConnectionEnabledByDefault == false",
            "signedEndpointEnabledByDefault == false",
            "privateStreamRuntimeEnabledByDefault == false",
            "brokerGatewayEnabledByDefault == false",
            "realOrderCommandEnabledByDefault == false"
        ] {
            XCTAssertTrue(contract.contains(forbiddenDefault), "\(forbiddenDefault) must remain explicit")
        }
    }

    func testGH634PortfolioAndExecutionOwnParityContractsWhileCoreRetainsBridgeOnly() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let contract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/core-compatibility-envelope-final-retirement-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )

        for anchor in Set(
            PortfolioParityOwnershipContract.requiredValidationAnchors
                + ExecutionParityOwnershipContract.requiredValidationAnchors
        ) {
            XCTAssertTrue(contract.contains(anchor), "\(anchor) must remain in CEFR contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must remain in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must remain in trading-validation-matrix.md")
        }

        let portfolioTarget = try packageTargetBlock(named: "Portfolio", packageSource: packageSource)
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let portfolioSources = try packageTargetSourcesBlock(targetBlock: portfolioTarget)
        let portfolioExcludes = try packageTargetExcludesBlock(targetBlock: portfolioTarget)
        let executionEngineSources = try packageTargetSourcesBlock(targetBlock: executionEngineTarget)
        let executionEngineExcludes = try packageTargetExcludesBlock(targetBlock: executionEngineTarget)
        let coreExcludes = try packageTargetExcludesBlock(targetBlock: coreTarget)

        XCTAssertTrue(portfolioSources.contains("\"PortfolioParityOwnershipContract.swift\""))
        XCTAssertTrue(coreExcludes.contains("\"Portfolio/PortfolioParityOwnershipContract.swift\""))
        XCTAssertTrue(portfolioExcludes.contains("\"PaperAccountPortfolioProjectionV2.swift\""))
        XCTAssertTrue(portfolioExcludes.contains("\"SimulatedExchangePortfolioProjectionParity.swift\""))
        XCTAssertTrue(executionEngineSources.contains("\"Ownership\""))

        let portfolioTargetSwiftSources = try packageTargetSwiftSources(
            repositoryRoot: repositoryRoot,
            targetRoot: "Sources/Portfolio",
            targetBlock: portfolioTarget
        )
        let executionTargetSwiftSources = try packageTargetSwiftSources(
            repositoryRoot: repositoryRoot,
            targetRoot: "Sources/ExecutionEngine",
            targetBlock: executionEngineTarget
        )
        let coreTargetSwiftSources = try packageTargetSwiftSources(
            repositoryRoot: repositoryRoot,
            targetRoot: "Sources",
            targetBlock: coreTarget
        )

        for activeSource in PortfolioParityOwnershipContract.requiredActivePortfolioSourcePaths {
            XCTAssertTrue(portfolioTargetSwiftSources.contains(activeSource), "\(activeSource) must be Portfolio-owned")
            XCTAssertTrue(contract.contains("`\(activeSource)`"))
        }
        for activeSource in ExecutionParityOwnershipContract.requiredActiveExecutionSourcePaths {
            XCTAssertTrue(executionTargetSwiftSources.contains(activeSource), "\(activeSource) must be ExecutionEngine-owned")
            XCTAssertTrue(contract.contains("`\(activeSource)`"))
        }

        for retainedSource in PortfolioParityOwnershipContract.requiredRetainedBridgeSourcePaths {
            let relative = retainedSource.replacingOccurrences(of: "Sources/Portfolio/", with: "")
            XCTAssertTrue(portfolioExcludes.contains("\"\(relative)\""))
            XCTAssertTrue(coreTargetSwiftSources.contains(retainedSource), "\(retainedSource) must remain Core compatibility-only")
            XCTAssertTrue(contract.contains("`\(retainedSource)`"))
        }
        for retainedSource in ExecutionParityOwnershipContract.requiredRetainedBridgeSourcePaths {
            let relative = retainedSource.replacingOccurrences(of: "Sources/ExecutionEngine/", with: "")
            XCTAssertTrue(executionEngineExcludes.contains("\"\(relative)\""))
            XCTAssertTrue(coreTargetSwiftSources.contains(retainedSource), "\(retainedSource) must remain Core compatibility-only")
            XCTAssertTrue(contract.contains("`\(retainedSource)`"))
        }

        let portfolioEvidence = PortfolioParityOwnershipContract.gh634
        let executionEvidence = ExecutionParityOwnershipContract.gh634
        XCTAssertTrue(portfolioEvidence.boundaryHeld)
        XCTAssertTrue(executionEvidence.boundaryHeld)
        XCTAssertTrue(portfolioEvidence.portfolioOwnsAllActiveSurfaces)
        XCTAssertTrue(portfolioEvidence.retainedBridgesAreCompatibilityOnly)
        XCTAssertTrue(executionEvidence.executionEngineOwnsAllActiveSurfaces)
        XCTAssertTrue(executionEvidence.retainedBridgesAreCompatibilityOnly)
        XCTAssertTrue(portfolioEvidence.noProductionAuthorization.allProductionCapabilitiesDisabledByDefault)
        XCTAssertTrue(executionEvidence.noProductionAuthorization.allProductionCapabilitiesDisabledByDefault)

        XCTAssertTrue(
            PortfolioTargetBoundary.requiredValidationAnchors.contains(
                "GH-634-PORTFOLIO-PARITY-OWNERSHIP-CONTRACT"
            )
        )
        XCTAssertTrue(
            ExecutionEngineTargetBoundary.requiredValidationAnchors.contains(
                "GH-634-EXECUTION-PARITY-OWNERSHIP-CONTRACT"
            )
        )
        XCTAssertTrue(executionClientTarget.contains("dependencies: [\"DomainModel\", \"MessageBus\"]"))

        for forbiddenDefault in [
            "productionTradingEnabledByDefault == false",
            "productionSecretReadEnabledByDefault == false",
            "productionEndpointConnectionEnabledByDefault == false",
            "brokerGatewayEnabledByDefault == false",
            "omsRuntimeEnabledByDefault == false",
            "realOrderCommandEnabledByDefault == false",
            "executionReportRuntimeEnabledByDefault == false",
            "brokerFillRuntimeEnabledByDefault == false",
            "reconciliationRuntimeEnabledByDefault == false"
        ] {
            XCTAssertTrue(contract.contains(forbiddenDefault), "\(forbiddenDefault) must remain explicit")
        }
    }

    func testGH635PersistenceRuntimeEnvelopesAreAdapterAndWorkflowShimsOnly() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let contract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/core-compatibility-envelope-final-retirement-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )

        let envelope = PersistenceRuntimeEnvelopeRetirementContract.gh635
        XCTAssertTrue(envelope.boundaryHeld)
        XCTAssertTrue(envelope.persistenceEnvelopeIsAdapterShimOnly)
        XCTAssertTrue(envelope.runtimeEnvelopeIsWorkflowShimOnly)
        XCTAssertTrue(envelope.noProductionAuthorization.allForbiddenCapabilitiesDisabledByDefault)

        for anchor in PersistenceRuntimeEnvelopeRetirementContract.requiredValidationAnchors {
            XCTAssertTrue(contract.contains(anchor), "\(anchor) must remain in CEFR contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must remain in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must remain in trading-validation-matrix.md")
        }

        let databaseTarget = try packageTargetBlock(named: "Database", packageSource: packageSource)
        let persistenceTarget = try packageTargetBlock(named: "Persistence", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)
        let databaseSources = try packageTargetSourcesBlock(targetBlock: databaseTarget)
        let databaseExcludes = try packageTargetExcludesBlock(targetBlock: databaseTarget)
        let persistenceSources = try packageTargetSourcesBlock(targetBlock: persistenceTarget)
        let persistenceExcludes = try packageTargetExcludesBlock(targetBlock: persistenceTarget)
        let runtimeSources = try packageTargetSourcesBlock(targetBlock: runtimeTarget)
        let runtimeExcludes = try packageTargetExcludesBlock(targetBlock: runtimeTarget)

        XCTAssertTrue(databaseSources.contains("\"PersistenceRuntimeEnvelopeRetirementContract.swift\""))
        XCTAssertTrue(databaseExcludes.contains("\"Projections\""))
        XCTAssertTrue(databaseExcludes.contains("\"ReplayProjection\""))
        XCTAssertTrue(persistenceExcludes.contains("\"PersistenceRuntimeEnvelopeRetirementContract.swift\""))
        XCTAssertTrue(runtimeExcludes.contains("\"Database/PersistenceRuntimeEnvelopeRetirementContract.swift\""))

        XCTAssertEqual(
            try packageTargetSwiftSources(
                repositoryRoot: repositoryRoot,
                targetRoot: "Sources/Database",
                targetBlock: persistenceTarget
            ),
            PersistenceRuntimeEnvelopeRetirementContract.requiredPersistenceShimSourcePaths
        )
        XCTAssertEqual(
            try packageTargetSwiftSources(repositoryRoot: repositoryRoot, targetRoot: "Sources", targetBlock: runtimeTarget),
            PersistenceRuntimeEnvelopeRetirementContract.requiredRuntimeShimSourcePaths
        )

        for source in PersistenceRuntimeEnvelopeRetirementContract.requiredPersistenceShimSourcePaths {
            let relative = source.replacingOccurrences(of: "Sources/Database/", with: "")
            XCTAssertTrue(persistenceSources.contains("\"\(relative)\""))
            XCTAssertTrue(contract.contains("`\(source)`"))
        }
        for source in PersistenceRuntimeEnvelopeRetirementContract.requiredRuntimeShimSourcePaths {
            XCTAssertTrue(contract.contains("`\(source)`"))
        }
        XCTAssertTrue(runtimeSources.contains("\"Database/ReplayProjection\""))
        XCTAssertTrue(runtimeSources.contains("\"DataEngine/Ingest\""))
        XCTAssertFalse(runtimeSources.contains("\"Database/Projections\""))
        XCTAssertFalse(runtimeSources.contains("\"DataEngine/BinancePublicMarketDataRuntimePath.swift\""))

        for retiredDirectory in [
            "Sources/Persistence",
            "Sources/Runtime"
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(retiredDirectory).path),
                "\(retiredDirectory) must not reappear as an active source directory"
            )
        }

        XCTAssertTrue(
            DatabaseTargetBoundary.requiredValidationAnchors.contains(
                "GH-635-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT-CONTRACT"
            )
        )
        XCTAssertTrue(
            DatabaseRuntimeOwnershipMatrix.requiredValidationAnchors.contains(
                "GH-635-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT-CONTRACT"
            )
        )

        for forbiddenDefault in [
            "productionTradingEnabledByDefault == false",
            "productionSecretReadEnabledByDefault == false",
            "productionEndpointConnectionEnabledByDefault == false",
            "rawSchemaExposedToDashboard == false",
            "runtimeObjectExposedToDashboard == false",
            "brokerPayloadPersistenceEnabledByDefault == false",
            "accountPayloadPersistenceEnabledByDefault == false",
            "brokerGatewayEnabledByDefault == false",
            "omsRuntimeEnabledByDefault == false",
            "realOrderCommandEnabledByDefault == false",
            "reconciliationRuntimeEnabledByDefault == false"
        ] {
            XCTAssertTrue(contract.contains(forbiddenDefault), "\(forbiddenDefault) must remain explicit")
        }
    }

    func testGH636FinalEnvelopeRetirementCloseoutMatrixCoversCompletedEvidenceWithoutProductionCutover() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let contract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/core-compatibility-envelope-final-retirement-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let auditInput = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/audit/inputs/mtpro-core-compatibility-envelope-final-retirement-v1-stage-audit-input.md"
            ),
            encoding: .utf8
        )

        let closeoutAnchors = [
            "GH-636-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT",
            "GH-636-ISSUE-PR-EVIDENCE-CHAIN",
            "GH-636-REAL-MODULE-OWNER-MAP-COMPLETE",
            "GH-636-RETAINED-ENVELOPE-SHIM-MATRIX",
            "GH-636-AUTOMATION-READINESS-CLOSEOUT",
            "GH-636-NO-PRODUCTION-CUTOVER-AUTHORIZATION",
            "TVM-CEFR-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT"
        ]
        for anchor in closeoutAnchors {
            XCTAssertTrue(contract.contains(anchor), "\(anchor) must remain in CEFR contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must remain in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must remain in trading-validation-matrix.md")
            XCTAssertTrue(auditInput.contains(anchor), "\(anchor) must remain in stage audit input")
        }
        for anchor in closeoutAnchors.dropLast() {
            XCTAssertTrue(readinessScript.contains(anchor), "\(anchor) must be mechanically checked")
        }
        XCTAssertTrue(automationReadiness.contains("Core compatibility envelope final retirement closeout anchor"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH636FinalEnvelopeRetirementCloseoutMatrixCoversCompletedEvidenceWithoutProductionCutover"
            )
        )

        for issue in 631...635 {
            XCTAssertTrue(auditInput.contains("[GH-\(issue)]"), "GH-\(issue) must be linked in evidence chain")
        }
        for pr in 637...641 {
            XCTAssertTrue(auditInput.contains("[PR #\(pr)]"), "PR #\(pr) must be linked in evidence chain")
        }
        for mergeCommit in [
            "e3279b0c102ba47e56304d3ad98d203819ef3ecc",
            "c1aa7634c658833171f2956bbc7102be3e7e5bdc",
            "02c50ea24488e430664073833d076af88fbddff5",
            "4041b7eb82e490ee6deb2c2bfe6781cc772bb778",
            "75cb1cf157244c3e4234ad4f866ae2eab06a2634"
        ] {
            XCTAssertTrue(auditInput.contains(mergeCommit), "\(mergeCommit) must remain in evidence chain")
        }

        for owner in [
            "DataClient",
            "DataEngine",
            "MessageBus",
            "Database",
            "Portfolio",
            "RiskEngine",
            "ExecutionEngine",
            "ExecutionClient",
            "Trader",
            "TraderStrategies",
            "Dashboard"
        ] {
            XCTAssertTrue(auditInput.contains("`\(owner)`"), "\(owner) must be present in owner map")
        }

        for retainedRole in [
            "`Core` | compatibility envelope only",
            "`Adapters` | DataClient compatibility re-export only",
            "`Persistence` | Database projection adapter shim only",
            "`Runtime` | DataEngine / Database replay-ingest workflow shim only"
        ] {
            XCTAssertTrue(auditInput.contains(retainedRole), "\(retainedRole) must stay explicit")
        }

        let dataClientTarget = try packageTargetBlock(named: "DataClient", packageSource: packageSource)
        let dataEngineTarget = try packageTargetBlock(named: "DataEngine", packageSource: packageSource)
        let messageBusTarget = try packageTargetBlock(named: "MessageBus", packageSource: packageSource)
        let databaseTarget = try packageTargetBlock(named: "Database", packageSource: packageSource)
        let portfolioTarget = try packageTargetBlock(named: "Portfolio", packageSource: packageSource)
        let riskEngineTarget = try packageTargetBlock(named: "RiskEngine", packageSource: packageSource)
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let traderTarget = try packageTargetBlock(named: "Trader", packageSource: packageSource)
        let traderStrategiesTarget = try packageTargetBlock(named: "TraderStrategies", packageSource: packageSource)
        let dashboardTarget = try packageTargetBlock(named: "Dashboard", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let adaptersTarget = try packageTargetBlock(named: "Adapters", packageSource: packageSource)
        let persistenceTarget = try packageTargetBlock(named: "Persistence", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)

        XCTAssertTrue(dataClientTarget.contains("\"Binance/PublicMarketData/Adapters.swift\""))
        XCTAssertTrue(dataEngineTarget.contains("\"ScenarioReplay/ScenarioReplayDataQualityOwnershipContract.swift\""))
        XCTAssertTrue(messageBusTarget.contains("\"RichRoutingCompatibilityContract.swift\""))
        XCTAssertTrue(databaseTarget.contains("\"PersistenceRuntimeEnvelopeRetirementContract.swift\""))
        XCTAssertTrue(portfolioTarget.contains("\"PortfolioParityOwnershipContract.swift\""))
        XCTAssertTrue(riskEngineTarget.contains("\"PreTrade/RiskEnginePreTradeOwnership.swift\""))
        XCTAssertTrue(executionEngineTarget.contains("\"Ownership\""))
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(traderTarget.contains("\"Accounts\""))
        XCTAssertTrue(traderStrategiesTarget.contains("\"StrategyRegistry.swift\""))
        XCTAssertTrue(dashboardTarget.contains("dependencies: [\"Core\", \"Persistence\"]"))

        XCTAssertTrue(adaptersTarget.contains("\"AdaptersCompatibility.swift\""))
        XCTAssertTrue(persistenceTarget.contains("\"Projections/ReleaseV020SpotPerpDatabaseProjections.swift\""))
        XCTAssertTrue(persistenceTarget.contains("\"Projections/SQLite/Persistence.swift\""))
        XCTAssertTrue(persistenceTarget.contains("\"Projections/DuckDB/DuckDBAnalyticalProjectionAdapter.swift\""))
        XCTAssertTrue(runtimeTarget.contains("\"Database/ReplayProjection\""))
        XCTAssertTrue(runtimeTarget.contains("\"DataEngine/Ingest\""))
        XCTAssertTrue(coreTarget.contains("\"DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift\""))
        XCTAssertTrue(coreTarget.contains("\"Portfolio/PaperAccountPortfolioProjectionV2.swift\""))
        XCTAssertTrue(coreTarget.contains("\"ExecutionEngine/PaperLifecycle\""))

        for retiredDirectory in [
            "Sources/Adapters",
            "Sources/Persistence",
            "Sources/Runtime"
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(retiredDirectory).path),
                "\(retiredDirectory) must stay absent after final closeout"
            )
        }

        for forbiddenDefault in [
            "productionTradingEnabledByDefault == false",
            "productionSecretReadEnabledByDefault == false",
            "productionEndpointConnectionEnabledByDefault == false",
            "productionOrderSubmitEnabledByDefault == false",
            "productionBrokerConnectionEnabledByDefault == false",
            "productionCutoverAuthorized == false"
        ] {
            XCTAssertTrue(contract.contains(forbiddenDefault), "\(forbiddenDefault) must stay in contract")
            XCTAssertTrue(auditInput.contains(forbiddenDefault), "\(forbiddenDefault) must stay in audit input")
        }
        XCTAssertTrue(tradingMatrix.contains("production cutover"))
        XCTAssertTrue(auditInput.contains("no next Project / Issue is created or promoted"))
    }

    func testGH657ReleaseV030RuntimeRehearsalContractDefinesDryRunTestnetShadowBoundary() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-runtime-rehearsal-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        let contract = try ReleaseV030RuntimeRehearsalContract.deterministicFixture()
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.productionDefaultsClosed)
        XCTAssertTrue(contract.commandGateChainRequired)
        XCTAssertTrue(contract.bypassesRejected)
        XCTAssertTrue(contract.oneCommandCriteriaHeld)
        XCTAssertEqual(contract.issueID.rawValue, "GH-657")
        XCTAssertEqual(contract.downstreamIssueID.rawValue, "GH-658")
        XCTAssertEqual(contract.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(contract.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(contract.releaseVersion, "v0.3.0")
        XCTAssertEqual(contract.allowedVenue, "Binance")
        XCTAssertEqual(contract.allowedProductTypes, ["spot", "usdsPerpetual"])
        XCTAssertEqual(contract.allowedStrategies, ["EMA", "RSI"])
        XCTAssertEqual(contract.rehearsalModes, ReleaseV030RuntimeRehearsalMode.allCases)
        XCTAssertEqual(
            Set(contract.forbiddenCapabilities),
            Set(ReleaseV030RuntimeRehearsalForbiddenCapability.allCases)
        )
        XCTAssertEqual(contract.oneCommandRehearsalName, "verify-v0.3.0")
        XCTAssertEqual(contract.successCriteria, ReleaseV030RuntimeRehearsalSuccessCriterion.allCases)

        XCTAssertFalse(contract.productionTradingEnabledByDefault)
        XCTAssertFalse(contract.productionSecretAutoReadEnabled)
        XCTAssertFalse(contract.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(contract.productionOrderSubmissionEnabled)
        XCTAssertFalse(contract.productionCutoverAuthorized)
        XCTAssertTrue(contract.commandGatewayRequired)
        XCTAssertTrue(contract.riskEngineRequired)
        XCTAssertTrue(contract.executionEngineRequired)
        XCTAssertTrue(contract.omsRequired)
        XCTAssertTrue(contract.eventStoreRequired)
        XCTAssertFalse(contract.dashboardCLICommandGatewayBypassAllowed)
        XCTAssertFalse(contract.strategyExecutionClientDirectAccessAllowed)
        XCTAssertFalse(contract.riskExecutionOMSEventStoreBypassAllowed)
        XCTAssertFalse(contract.startsNextMilestone)

        for anchor in ReleaseV030RuntimeRehearsalContract.requiredValidationAnchors {
            XCTAssertTrue(contract.validationAnchors.contains(anchor), "\(anchor) must stay in Swift contract")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        for mode in ["dry-run", "testnet", "shadow", "production-blocked"] {
            XCTAssertTrue(contractDoc.contains(mode), "\(mode) must stay documented as a rehearsal mode")
        }
        for criterion in ReleaseV030RuntimeRehearsalSuccessCriterion.allCases {
            XCTAssertTrue(
                contractDoc.contains(criterion.rawValue),
                "\(criterion.rawValue) must stay documented as one-command success criteria"
            )
        }

        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 runtime rehearsal contract anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030RuntimeRehearsalContract.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH657ReleaseV030RuntimeRehearsalContractDefinesDryRunTestnetShadowBoundary"
            )
        )
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ReleaseV030RuntimeRehearsalContract.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ReleaseV030RuntimeRehearsalContract(
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionTradingEnabledByDefault")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeRehearsalContract(
                productionSecretAutoReadEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionSecretAutoReadEnabled")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeRehearsalContract(
                productionEndpointAutoConnectEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionEndpointAutoConnectEnabled")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeRehearsalContract(
                productionOrderSubmissionEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionOrderSubmissionEnabled")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeRehearsalContract(
                productionCutoverAuthorized: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("productionCutoverAuthorized"))
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeRehearsalContract(
                allowedVenue: "Coinbase"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(field: "allowedVenue", expected: "Binance", actual: "Coinbase")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeRehearsalContract(
                allowedProductTypes: ["spot"]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "allowedProductTypes",
                    expected: "spot,usdsPerpetual",
                    actual: "spot"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeRehearsalContract(
                strategyExecutionClientDirectAccessAllowed: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("strategyExecutionClientDirectAccessAllowed")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeRehearsalContract(
                commandGatewayRequired: false
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(field: "commandGatewayRequired", expected: "true", actual: "false")
            )
        }
    }

    func testGH658RuntimeEnvironmentConfigDefaultsSafeAndRejectsProductionTransitions() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let configDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-runtime-environment-config-contract.md"
            ),
            encoding: .utf8
        )
        let upstreamContractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-runtime-rehearsal-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        let config = try ReleaseV030RuntimeEnvironmentConfig.deterministicFixture()
        XCTAssertTrue(config.configHeld)
        XCTAssertTrue(config.safeDefaultHeld)
        XCTAssertTrue(config.modeCoverageHeld)
        XCTAssertTrue(config.transitionCoverageHeld)
        XCTAssertTrue(config.productionCapabilityDefaultsClosed)
        XCTAssertTrue(config.commandPathBypassRejected)
        XCTAssertEqual(config.issueID.rawValue, "GH-658")
        XCTAssertEqual(config.upstreamIssueID.rawValue, "GH-657")
        XCTAssertEqual(config.downstreamIssueID.rawValue, "GH-659")
        XCTAssertEqual(config.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(config.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(config.defaultMode, .dryRun)
        XCTAssertEqual(config.allowedDefaultModes, [.dryRun, .productionBlocked])
        XCTAssertEqual(Set(config.modeConfigs.map(\.mode)), Set(ReleaseV030RuntimeRehearsalMode.allCases))
        XCTAssertEqual(config.requirements, ReleaseV030RuntimeEnvironmentRequirement.allCases)
        XCTAssertEqual(
            Set(config.forbiddenCapabilities),
            Set(ReleaseV030RuntimeEnvironmentForbiddenCapability.allCases)
        )

        XCTAssertTrue(config.transitionAllowed(from: .productionBlocked, to: .dryRun))
        XCTAssertTrue(config.transitionAllowed(from: .dryRun, to: .testnet))
        XCTAssertTrue(config.transitionAllowed(from: .dryRun, to: .shadow))
        XCTAssertTrue(config.transitionAllowed(from: .testnet, to: .shadow))
        XCTAssertTrue(config.transitionAllowed(from: .dryRun, to: .productionBlocked))
        XCTAssertTrue(config.transitionAllowed(from: .testnet, to: .productionBlocked))
        XCTAssertTrue(config.transitionAllowed(from: .shadow, to: .productionBlocked))
        XCTAssertFalse(config.transitionAllowed(from: .productionBlocked, to: .testnet))
        XCTAssertFalse(config.transitionAllowed(from: .shadow, to: .testnet))
        XCTAssertFalse(config.transitionAllowed(from: .testnet, to: .dryRun))

        for modeConfig in config.modeConfigs {
            XCTAssertTrue(modeConfig.modeBoundaryHeld)
            XCTAssertFalse(modeConfig.readsProductionSecret)
            XCTAssertFalse(modeConfig.autoConnectsProductionEndpoint)
            XCTAssertFalse(modeConfig.enablesProductionTrading)
            XCTAssertFalse(modeConfig.submitsProductionOrder)
            XCTAssertFalse(modeConfig.authorizesProductionCutover)
        }
        for transition in config.allowedTransitions {
            XCTAssertTrue(transition.transitionBoundaryHeld)
            XCTAssertFalse(transition.readsProductionSecret)
            XCTAssertFalse(transition.autoConnectsProductionEndpoint)
            XCTAssertFalse(transition.enablesProductionTrading)
            XCTAssertFalse(transition.submitsProductionOrder)
            XCTAssertFalse(transition.authorizesProductionCutover)
        }

        XCTAssertFalse(config.productionTradingEnabledByDefault)
        XCTAssertFalse(config.productionSecretAutoReadEnabled)
        XCTAssertFalse(config.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(config.productionOrderSubmissionEnabled)
        XCTAssertFalse(config.productionCutoverAuthorized)
        XCTAssertFalse(config.ambiguousModeFallsBackToProduction)
        XCTAssertFalse(config.invalidTransitionAllowed)
        XCTAssertFalse(config.commandGatewayBypassAllowed)
        XCTAssertFalse(config.strategyExecutionClientDirectAccessAllowed)
        XCTAssertFalse(config.startsNextMilestone)

        for anchor in ReleaseV030RuntimeEnvironmentConfig.requiredValidationAnchors {
            XCTAssertTrue(config.validationAnchors.contains(anchor), "\(anchor) must stay in Swift config")
            XCTAssertTrue(configDoc.contains(anchor), "\(anchor) must stay in environment config doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(upstreamContractDoc.contains("V030-01-RUNTIME-REHEARSAL-CONTRACT"))
        XCTAssertTrue(configDoc.contains("production-blocked -> dry-run"))
        XCTAssertTrue(configDoc.contains("dry-run -> testnet"))
        XCTAssertTrue(configDoc.contains("testnet -> shadow"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 runtime environment config anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030RuntimeEnvironmentConfig.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH658RuntimeEnvironmentConfigDefaultsSafeAndRejectsProductionTransitions"
            )
        )
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ReleaseV030RuntimeEnvironmentConfig.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ReleaseV030RuntimeEnvironmentConfig(defaultMode: .testnet)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(field: "defaultMode", expected: "dry-run", actual: "testnet")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeEnvironmentConfig(productionSecretAutoReadEnabled: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionSecretAutoReadEnabled")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeEnvironmentConfig(productionEndpointAutoConnectEnabled: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionEndpointAutoConnectEnabled")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeEnvironmentConfig(invalidTransitionAllowed: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("invalidTransitionAllowed"))
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeEnvironmentConfig(upstreamRehearsalContractHeld: false)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamRehearsalContractHeld",
                    expected: "true",
                    actual: "false"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeEnvironmentModeConfig(
                mode: .testnet,
                endpointPolicy: .localFixtureOnly,
                credentialPolicy: .testnetProfileReference
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "endpointPolicy",
                    expected: "Binance testnet endpoint reference only",
                    actual: "local fixture endpoint only"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeEnvironmentModeConfig(
                mode: .dryRun,
                endpointPolicy: .localFixtureOnly,
                credentialPolicy: .localFixtureReference,
                readsProductionSecret: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsProductionSecret"))
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeEnvironmentTransition(
                from: .dryRun,
                to: .dryRun,
                transitionAnchor: "V030-02-INVALID-SAME-MODE"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "environmentTransition",
                    expected: "distinct rehearsal modes",
                    actual: "dry-run->dry-run"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RuntimeEnvironmentTransition(
                from: .dryRun,
                to: .testnet,
                transitionAnchor: "V030-02-UNSAFE-TRANSITION",
                autoConnectsProductionEndpoint: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("transitionAutoConnectsProductionEndpoint")
            )
        }
    }

    func testGH659DataEngineRuntimeRehearsalFlowPreservesSpotPerpProductIdentity() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let dataEngineTarget = try packageTargetBlock(named: "DataEngine", packageSource: packageSource)
        let flowDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-dataengine-runtime-rehearsal-flow-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let interval = try DateRange(
            start: Date(timeIntervalSince1970: 1_704_068_000),
            end: Date(timeIntervalSince1970: 1_704_068_060)
        )
        let spotBar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 43_000,
            high: 43_120,
            low: 42_980,
            close: 43_080,
            volume: 9
        )
        let perpBar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 43_010,
            high: 43_180,
            low: 42_990,
            close: 43_150,
            volume: 14
        )
        let spotEvent = try BinanceSpotProductAwareMarketDataEvent(
            instrument: spot,
            marketEvent: .bar(spotBar)
        )
        let perpEvent = try BinanceUSDMPerpetualProductAwareMarketDataEvent(
            instrument: perp,
            marketEvent: .bar(perpBar)
        )

        let flow = try ReleaseV030DataEngineRuntimeRehearsalFlow()
        let evidence = try flow.run(
            spotEvents: [spotEvent],
            usdmPerpetualEvents: [perpEvent]
        )

        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.productIdentityCoverageHeld)
        XCTAssertTrue(evidence.traceableMessageBusEvidenceHeld)
        XCTAssertTrue(evidence.productionCapabilitiesClosed)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-659")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-658")
        XCTAssertEqual(evidence.downstreamIssueID.rawValue, "GH-660")
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(evidence.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(evidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(evidence.upstreamEnvironmentConfigAnchor, "TVM-RELEASE-V030-RUNTIME-ENVIRONMENT-CONFIG")
        XCTAssertEqual(evidence.mode, .dryRun)
        XCTAssertEqual(evidence.requirements, ReleaseV030DataEngineRuntimeRehearsalRequirement.allCases)
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ReleaseV030DataEngineRuntimeRehearsalForbiddenCapability.allCases)
        )

        XCTAssertEqual(evidence.spotRecord.instrument, spot)
        XCTAssertEqual(evidence.spotRecord.marketEventCount, 1)
        XCTAssertEqual(evidence.spotRecord.messageBusEnvelopeCount, 1)
        XCTAssertTrue(evidence.spotRecord.payloadTypes.first?.contains("dataengine.release-v0.3.0.binance.spot") == true)
        XCTAssertEqual(evidence.usdmPerpetualRecord.instrument, perp)
        XCTAssertEqual(evidence.usdmPerpetualRecord.marketEventCount, 1)
        XCTAssertEqual(evidence.usdmPerpetualRecord.messageBusEnvelopeCount, 1)
        XCTAssertTrue(
            evidence.usdmPerpetualRecord.payloadTypes.first?.contains(
                "dataengine.release-v0.3.0.binance.usdsPerpetual"
            ) == true
        )

        let spotSeriesKey = ProductAwareMarketDataSeriesKey(instrument: spot, timeframe: .oneMinute)
        let perpSeriesKey = ProductAwareMarketDataSeriesKey(instrument: perp, timeframe: .oneMinute)
        XCTAssertNotEqual(spotSeriesKey, perpSeriesKey)
        XCTAssertEqual(evidence.cacheSnapshot.barsBySeries[spotSeriesKey]?.first?.close.rawValue, 43_080)
        XCTAssertEqual(evidence.cacheSnapshot.barsBySeries[perpSeriesKey]?.first?.close.rawValue, 43_150)
        XCTAssertTrue(evidence.cacheSnapshot.productAwareBoundaryHeld)
        XCTAssertEqual(evidence.cacheSnapshot.marketEventCount, 2)
        XCTAssertEqual(evidence.eventEnvelopes, evidence.replayedEnvelopes)
        XCTAssertEqual(evidence.eventEnvelopes.map(\.instrumentID), [spot, perp])
        XCTAssertEqual(evidence.eventEnvelopes.compactMap(\.productType), [.spot, .usdsPerpetual])

        XCTAssertFalse(evidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(evidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(evidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(evidence.productionCutoverAuthorized)
        XCTAssertFalse(evidence.commandGatewayBypassAllowed)
        XCTAssertFalse(evidence.strategyExecutionClientDirectAccessAllowed)
        XCTAssertFalse(evidence.startsNextMilestone)

        for anchor in ReleaseV030DataEngineRuntimeRehearsalEvidence.requiredValidationAnchors {
            XCTAssertTrue(evidence.validationAnchors.contains(anchor), "\(anchor) must stay in Swift evidence")
            XCTAssertTrue(flowDoc.contains(anchor), "\(anchor) must stay in DataEngine rehearsal contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(flowDoc.contains("DataEngine target 不依赖 ExecutionClient target"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 DataEngine runtime rehearsal flow anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030DataEngineRuntimeRehearsalFlow.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH659DataEngineRuntimeRehearsalFlowPreservesSpotPerpProductIdentity"
            )
        )
        XCTAssertTrue(dataEngineTarget.contains("ReleaseV030DataEngineRuntimeRehearsalFlow.swift"))
        XCTAssertFalse(dataEngineTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/DataEngine/ReleaseV030DataEngineRuntimeRehearsalFlow.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try flow.run(
                upstreamEnvironmentConfigAnchor: "UNSAFE-MISSING-GH-658-ANCHOR",
                spotEvents: [spotEvent],
                usdmPerpetualEvents: [perpEvent]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamEnvironmentConfigAnchor",
                    expected: "TVM-RELEASE-V030-RUNTIME-ENVIRONMENT-CONFIG",
                    actual: "UNSAFE-MISSING-GH-658-ANCHOR"
                )
            )
        }
        XCTAssertThrowsError(
            try flow.run(spotEvents: [], usdmPerpetualEvents: [perpEvent])
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("missingSpotRehearsalEvent"))
        }
        XCTAssertThrowsError(
            try flow.run(spotEvents: [spotEvent], usdmPerpetualEvents: [])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("missingUSDMPerpetualRehearsalEvent")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030DataEngineRuntimeRehearsalRecord(
                mode: .dryRun,
                instrument: spot,
                marketEventCount: 1,
                messageBusEnvelopeCount: 1,
                payloadTypes: ["dataengine.release-v0.3.0.binance.spot.rehearsal.BTCUSDT"],
                usesProductionEndpoint: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("usesProductionEndpoint"))
        }
        XCTAssertThrowsError(
            try ReleaseV030DataEngineRuntimeRehearsalEvidence(
                spotRecord: evidence.spotRecord,
                usdmPerpetualRecord: evidence.usdmPerpetualRecord,
                cacheSnapshot: evidence.cacheSnapshot,
                eventEnvelopes: evidence.eventEnvelopes,
                replayedEnvelopes: evidence.replayedEnvelopes,
                productionEndpointAutoConnectEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionEndpointAutoConnectEnabled")
            )
        }
    }

    func testGH660TraderStrategyRuntimeRehearsalFlowEmitsEMAAndRSIIntentThroughMessageBus() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let traderTarget = try packageTargetBlock(named: "Trader", packageSource: packageSource)
        let flowDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-trader-strategy-runtime-rehearsal-flow-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let emaSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/Trader/Strategies/EMA/EMAProposalRuntime.swift"),
            encoding: .utf8
        )
        let rsiSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/Trader/Strategies/RSI/RSIStrategy.swift"),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let flow = try ReleaseV030TraderStrategyRuntimeRehearsalFlow()
        let emaRuntime = try EMAProposalRuntime.deterministicFixture()
        let rsiEmitter = try RSITargetExposureIntentEmitter.deterministicFixture(perpetualShortEnabled: true)
        let evidence = try flow.run(
            emaRuntime: emaRuntime,
            rsiEmitter: rsiEmitter,
            emaBars: EMAProposalRuntime.deterministicBars(),
            rsiBars: Self.gh568Bars(closes: [100, 101, 102, 103]),
            emaInstrument: spot,
            rsiInstrument: perp,
            quantity: Quantity(0.10, field: "gh660Quantity"),
            emittedAt: Date(timeIntervalSince1970: 1_704_068_100)
        )

        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.intentCoverageHeld)
        XCTAssertTrue(evidence.messageBusTraceHeld)
        XCTAssertTrue(evidence.strategyIsolationHeld)
        XCTAssertTrue(evidence.productionCapabilitiesClosed)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-660")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-659")
        XCTAssertEqual(evidence.downstreamIssueID.rawValue, "GH-661")
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(evidence.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(evidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(evidence.upstreamDataEngineRehearsalAnchor, "TVM-RELEASE-V030-DATAENGINE-RUNTIME-REHEARSAL-FLOW")
        XCTAssertEqual(evidence.mode, .dryRun)
        XCTAssertEqual(evidence.requirements, ReleaseV030TraderStrategyRuntimeRehearsalRequirement.allCases)
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ReleaseV030TraderStrategyRuntimeRehearsalForbiddenCapability.allCases)
        )

        XCTAssertEqual(evidence.emaRecord.strategyName, "EMA")
        XCTAssertEqual(evidence.emaRecord.message.instrument, spot)
        XCTAssertEqual(evidence.emaRecord.message.targetExposure, .hold)
        XCTAssertNil(evidence.emaRecord.message.productAwareOrderIntent)
        XCTAssertTrue(evidence.emaRecord.payloadType.contains("trader.release-v0.3.0.binance.spot.ema"))
        XCTAssertEqual(evidence.rsiRecord.strategyName, "RSI")
        XCTAssertEqual(evidence.rsiRecord.message.instrument, perp)
        XCTAssertEqual(evidence.rsiRecord.message.targetExposure, .targetShort)
        XCTAssertNotNil(evidence.rsiRecord.message.productAwareOrderIntent)
        XCTAssertTrue(
            evidence.rsiRecord.payloadType.contains("trader.release-v0.3.0.binance.usdsPerpetual.rsi")
        )

        XCTAssertEqual(evidence.intentMessages, [evidence.emaRecord.message, evidence.rsiRecord.message])
        XCTAssertEqual(evidence.eventEnvelopes, evidence.replayedEnvelopes)
        XCTAssertEqual(evidence.eventEnvelopes.map(\.instrumentID), [spot, perp])
        XCTAssertEqual(evidence.eventEnvelopes.compactMap(\.productType), [.spot, .usdsPerpetual])
        XCTAssertTrue(evidence.eventEnvelopes.allSatisfy { $0.payloadType.contains("targetExposureIntent") })

        XCTAssertFalse(evidence.directExecutionClientAccessEnabled)
        XCTAssertFalse(evidence.directBinanceAdapterAccessEnabled)
        XCTAssertFalse(evidence.commandGatewayBypassAllowed)
        XCTAssertFalse(evidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(evidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(evidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(evidence.productionCutoverAuthorized)
        XCTAssertFalse(evidence.startsNextMilestone)

        for anchor in ReleaseV030TraderStrategyRuntimeRehearsalEvidence.requiredValidationAnchors {
            XCTAssertTrue(evidence.validationAnchors.contains(anchor), "\(anchor) must stay in Swift evidence")
            XCTAssertTrue(flowDoc.contains(anchor), "\(anchor) must stay in Trader rehearsal contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(flowDoc.contains("Trader target 不依赖 DataEngine target"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 Trader strategy runtime rehearsal flow anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030TraderStrategyRuntimeRehearsalFlow.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH660TraderStrategyRuntimeRehearsalFlowEmitsEMAAndRSIIntentThroughMessageBus"
            )
        )
        XCTAssertTrue(traderTarget.contains("Runtime/ReleaseV030TraderStrategyRuntimeRehearsalFlow.swift"))
        XCTAssertTrue(traderTarget.contains("\"TraderStrategies\""))
        XCTAssertTrue(traderTarget.contains("\"MessageBus\""))
        XCTAssertFalse(traderTarget.contains("\"ExecutionClient\""))

        for forbidden in [
            "import ExecutionClient",
            "ExecutionClient.",
            "BinancePublicMarketDataClient",
            "URLSessionBinance",
            "import DataClient"
        ] {
            XCTAssertFalse(emaSource.contains(forbidden), "EMA source must not contain \(forbidden)")
            XCTAssertFalse(rsiSource.contains(forbidden), "RSI source must not contain \(forbidden)")
        }

        XCTAssertThrowsError(
            try flow.run(
                upstreamDataEngineRehearsalAnchor: "UNSAFE-MISSING-GH-659-ANCHOR",
                emaRuntime: emaRuntime,
                rsiEmitter: rsiEmitter,
                emaBars: EMAProposalRuntime.deterministicBars(),
                rsiBars: Self.gh568Bars(closes: [100, 101, 102, 103]),
                emaInstrument: spot,
                rsiInstrument: perp,
                quantity: Quantity(0.10, field: "gh660UnsafeQuantity"),
                emittedAt: Date(timeIntervalSince1970: 1_704_068_100)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamDataEngineRehearsalAnchor",
                    expected: "TVM-RELEASE-V030-DATAENGINE-RUNTIME-REHEARSAL-FLOW",
                    actual: "UNSAFE-MISSING-GH-659-ANCHOR"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030TraderStrategyRuntimeRehearsalRecord(
                mode: .dryRun,
                strategyName: "EMA",
                message: evidence.emaRecord.message,
                payloadType: evidence.emaRecord.payloadType,
                directExecutionClientAccessEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("directExecutionClientAccessEnabled"))
        }
        XCTAssertThrowsError(
            try ReleaseV030TraderStrategyRuntimeRehearsalRecord(
                mode: .dryRun,
                strategyName: "Grid",
                message: evidence.emaRecord.message,
                payloadType: evidence.emaRecord.payloadType
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("unsupportedStrategy"))
        }
        XCTAssertThrowsError(
            try ReleaseV030TraderStrategyRuntimeRehearsalEvidence(
                emaRecord: evidence.emaRecord,
                rsiRecord: evidence.rsiRecord,
                intentMessages: evidence.intentMessages,
                eventEnvelopes: evidence.eventEnvelopes,
                replayedEnvelopes: evidence.replayedEnvelopes,
                directBinanceAdapterAccessEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("directBinanceAdapterAccessEnabled")
            )
        }
    }

    func testGH661RiskEngineRehearsalGateAllowsRejectsAndBlocksStrategyIntents() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let riskEngineTarget = try packageTargetBlock(named: "RiskEngine", packageSource: packageSource)
        let gateDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-riskengine-rehearsal-gate-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let riskSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/RiskEngine/LiveGate/ReleaseV030RiskEngineRehearsalGate.swift"
            ),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let traderFlow = try ReleaseV030TraderStrategyRuntimeRehearsalFlow()
        let traderEvidence = try traderFlow.run(
            emaRuntime: EMAProposalRuntime.deterministicFixture(),
            rsiEmitter: RSITargetExposureIntentEmitter.deterministicFixture(perpetualShortEnabled: true),
            emaBars: EMAProposalRuntime.deterministicBars(),
            rsiBars: Self.gh568Bars(closes: [100, 101, 102, 103]),
            emaInstrument: spot,
            rsiInstrument: perp,
            quantity: Quantity(0.10, field: "gh661Quantity"),
            emittedAt: Date(timeIntervalSince1970: 1_704_068_100)
        )
        let allowedStrategyIDs = traderEvidence.intentMessages.map(\.strategyID)
        let allowedInstruments = traderEvidence.intentMessages.map(\.instrument)
        let allowPolicy = try ReleaseV030RiskEngineRehearsalPolicy(
            policyID: Identifier("gh-661-riskengine-allow-policy"),
            allowedStrategyIDs: allowedStrategyIDs,
            allowedInstruments: allowedInstruments,
            maxNotional: 10_000,
            maxAggregateExposure: 20_000
        )
        let invalidPolicy = try ReleaseV030RiskEngineRehearsalPolicy(
            policyID: Identifier("gh-661-riskengine-invalid-policy"),
            allowedStrategyIDs: allowedStrategyIDs,
            allowedInstruments: allowedInstruments,
            maxNotional: 1,
            maxAggregateExposure: 20_000
        )
        let killSwitchPolicy = try ReleaseV030RiskEngineRehearsalPolicy(
            policyID: Identifier("gh-661-riskengine-kill-switch-policy"),
            allowedStrategyIDs: allowedStrategyIDs,
            allowedInstruments: allowedInstruments,
            maxNotional: 10_000,
            maxAggregateExposure: 20_000,
            killSwitchActive: true
        )
        let noTradePolicy = try ReleaseV030RiskEngineRehearsalPolicy(
            policyID: Identifier("gh-661-riskengine-no-trade-policy"),
            allowedStrategyIDs: allowedStrategyIDs,
            allowedInstruments: allowedInstruments,
            maxNotional: 10_000,
            maxAggregateExposure: 20_000,
            noTradeActive: true
        )
        let gate = ReleaseV030RiskEngineRehearsalGate()
        let evidence = try gate.run(
            intentMessages: traderEvidence.intentMessages,
            eventEnvelopes: traderEvidence.eventEnvelopes,
            replayedEnvelopes: traderEvidence.replayedEnvelopes,
            allowPolicy: allowPolicy,
            invalidPolicy: invalidPolicy,
            killSwitchPolicy: killSwitchPolicy,
            noTradePolicy: noTradePolicy,
            evaluatedAt: Date(timeIntervalSince1970: 1_704_068_200)
        )

        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.allowRejectCoverageHeld)
        XCTAssertTrue(evidence.messageBusTraceHeld)
        XCTAssertTrue(evidence.auditBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-661")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-660")
        XCTAssertEqual(evidence.downstreamIssueID.rawValue, "GH-662")
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(evidence.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(evidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(evidence.upstreamTraderRehearsalAnchor, "TVM-RELEASE-V030-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW")
        XCTAssertEqual(evidence.mode, .dryRun)
        XCTAssertEqual(evidence.requirements, ReleaseV030RiskEngineRehearsalRequirement.allCases)
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ReleaseV030RiskEngineRehearsalForbiddenCapability.allCases)
        )

        XCTAssertTrue(evidence.allowDecision.isAllowed)
        XCTAssertEqual(evidence.allowDecision.status, .allow)
        XCTAssertNil(evidence.allowDecision.rejectReason)
        XCTAssertEqual(
            Set(evidence.allowDecision.passedGates),
            Set(ReleaseV030RiskEngineRehearsalGateType.allCases)
        )
        XCTAssertEqual(evidence.invalidDecision.rejectReason, .notionalLimitExceeded)
        XCTAssertEqual(evidence.killSwitchDecision.rejectReason, .killSwitchActive)
        XCTAssertEqual(evidence.noTradeDecision.rejectReason, .noTradeActive)
        XCTAssertTrue(evidence.invalidDecision.isRejected)
        XCTAssertTrue(evidence.killSwitchDecision.isRejected)
        XCTAssertTrue(evidence.noTradeDecision.isRejected)

        XCTAssertEqual(evidence.intentMessages, traderEvidence.intentMessages)
        XCTAssertEqual(evidence.eventEnvelopes, traderEvidence.eventEnvelopes)
        XCTAssertEqual(evidence.replayedEnvelopes, traderEvidence.replayedEnvelopes)
        XCTAssertEqual(evidence.eventEnvelopes.map(\.instrumentID), evidence.intentMessages.map(\.instrument))
        XCTAssertTrue(evidence.eventEnvelopes.allSatisfy { $0.payloadType.contains("targetExposureIntent") })

        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(evidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(evidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(evidence.productionCutoverAuthorized)
        XCTAssertFalse(evidence.commandGatewayBypassAllowed)
        XCTAssertFalse(evidence.executionEngineBypassAllowed)
        XCTAssertFalse(evidence.omsBypassAllowed)
        XCTAssertFalse(evidence.executionClientAccessEnabled)
        XCTAssertFalse(evidence.brokerGatewayAccessEnabled)
        XCTAssertFalse(evidence.eventStoreBypassAllowed)
        XCTAssertFalse(evidence.startsNextMilestone)

        for anchor in ReleaseV030RiskEngineRehearsalEvidence.requiredValidationAnchors {
            XCTAssertTrue(evidence.validationAnchors.contains(anchor), "\(anchor) must stay in Swift evidence")
            XCTAssertTrue(gateDoc.contains(anchor), "\(anchor) must stay in RiskEngine rehearsal contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(gateDoc.contains("RiskEngine target 不依赖 Trader target"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 RiskEngine rehearsal gate anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030RiskEngineRehearsalGate.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH661RiskEngineRehearsalGateAllowsRejectsAndBlocksStrategyIntents"
            )
        )
        XCTAssertTrue(riskEngineTarget.contains("\"MessageBus\""))
        XCTAssertTrue(riskEngineTarget.contains("\"LiveGate\""))
        XCTAssertFalse(riskEngineTarget.contains("\"ExecutionClient\""))
        XCTAssertFalse(riskEngineTarget.contains("\"ExecutionEngine\""))

        for forbidden in [
            "import ExecutionClient",
            "import ExecutionEngine",
            "import Trader",
            "URLSessionBinance",
            "/api/v3/order",
            "/fapi/v1/order"
        ] {
            XCTAssertFalse(riskSource.contains(forbidden), "RiskEngine rehearsal source must not contain \(forbidden)")
        }

        XCTAssertThrowsError(
            try gate.run(
                upstreamTraderRehearsalAnchor: "UNSAFE-MISSING-GH-660-ANCHOR",
                intentMessages: traderEvidence.intentMessages,
                eventEnvelopes: traderEvidence.eventEnvelopes,
                replayedEnvelopes: traderEvidence.replayedEnvelopes,
                allowPolicy: allowPolicy,
                invalidPolicy: invalidPolicy,
                killSwitchPolicy: killSwitchPolicy,
                noTradePolicy: noTradePolicy,
                evaluatedAt: Date(timeIntervalSince1970: 1_704_068_200)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamTraderRehearsalAnchor",
                    expected: "TVM-RELEASE-V030-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW",
                    actual: "UNSAFE-MISSING-GH-660-ANCHOR"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RiskEngineRehearsalPolicy(
                policyID: Identifier("gh-661-unsafe-policy"),
                allowedStrategyIDs: allowedStrategyIDs,
                allowedInstruments: allowedInstruments,
                maxNotional: 10_000,
                maxAggregateExposure: 20_000,
                productionOrderSubmissionEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV030RiskEngine.productionOrderSubmissionEnabled")
            )
        }

        let missingTraceDecision = try gate.evaluate(
            decisionID: Identifier("gh-661-missing-trace-decision"),
            message: traderEvidence.rsiRecord.message,
            envelope: nil,
            policy: allowPolicy,
            currentAggregateExposure: 0,
            evaluatedAt: Date(timeIntervalSince1970: 1_704_068_300)
        )
        XCTAssertTrue(missingTraceDecision.isRejected)
        XCTAssertEqual(missingTraceDecision.rejectReason, .missingMessageBusTrace)
    }

    func testGH662ExecutionOMSRehearsalLifecycleConsumesRiskApprovedIntentAndReplaysOMSState() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        let lifecycleDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-execution-oms-rehearsal-lifecycle-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let lifecycleSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/ExecutionEngine/OMSFutureGate/ReleaseV030ExecutionOMSRehearsalLifecycle.swift"
            ),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let traderEvidence = try ReleaseV030TraderStrategyRuntimeRehearsalFlow().run(
            emaRuntime: EMAProposalRuntime.deterministicFixture(),
            rsiEmitter: RSITargetExposureIntentEmitter.deterministicFixture(perpetualShortEnabled: true),
            emaBars: EMAProposalRuntime.deterministicBars(),
            rsiBars: Self.gh568Bars(closes: [100, 101, 102, 103]),
            emaInstrument: spot,
            rsiInstrument: perp,
            quantity: Quantity(0.10, field: "gh662Quantity"),
            emittedAt: Date(timeIntervalSince1970: 1_704_068_100)
        )
        let allowedStrategyIDs = traderEvidence.intentMessages.map(\.strategyID)
        let allowedInstruments = traderEvidence.intentMessages.map(\.instrument)
        let riskGate = ReleaseV030RiskEngineRehearsalGate()
        let riskEvidence = try riskGate.run(
            intentMessages: traderEvidence.intentMessages,
            eventEnvelopes: traderEvidence.eventEnvelopes,
            replayedEnvelopes: traderEvidence.replayedEnvelopes,
            allowPolicy: ReleaseV030RiskEngineRehearsalPolicy(
                policyID: Identifier("gh-662-riskengine-allow-policy"),
                allowedStrategyIDs: allowedStrategyIDs,
                allowedInstruments: allowedInstruments,
                maxNotional: 10_000,
                maxAggregateExposure: 20_000
            ),
            invalidPolicy: ReleaseV030RiskEngineRehearsalPolicy(
                policyID: Identifier("gh-662-riskengine-invalid-policy"),
                allowedStrategyIDs: allowedStrategyIDs,
                allowedInstruments: allowedInstruments,
                maxNotional: 1,
                maxAggregateExposure: 20_000
            ),
            killSwitchPolicy: ReleaseV030RiskEngineRehearsalPolicy(
                policyID: Identifier("gh-662-riskengine-kill-policy"),
                allowedStrategyIDs: allowedStrategyIDs,
                allowedInstruments: allowedInstruments,
                maxNotional: 10_000,
                maxAggregateExposure: 20_000,
                killSwitchActive: true
            ),
            noTradePolicy: ReleaseV030RiskEngineRehearsalPolicy(
                policyID: Identifier("gh-662-riskengine-no-trade-policy"),
                allowedStrategyIDs: allowedStrategyIDs,
                allowedInstruments: allowedInstruments,
                maxNotional: 10_000,
                maxAggregateExposure: 20_000,
                noTradeActive: true
            ),
            evaluatedAt: Date(timeIntervalSince1970: 1_704_068_200)
        )
        let lifecycle = try ReleaseV030ExecutionOMSRehearsalLifecycle()
        let evidence = try lifecycle.run(
            riskEvidence: riskEvidence,
            recordedAt: Date(timeIntervalSince1970: 1_704_068_300)
        )

        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.lifecycleCoverageHeld)
        XCTAssertTrue(evidence.replayCoverageHeld)
        XCTAssertTrue(evidence.boundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-662")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-661")
        XCTAssertEqual(evidence.downstreamIssueID.rawValue, "GH-663")
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(evidence.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(evidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(evidence.upstreamRiskEngineRehearsalAnchor, "TVM-RELEASE-V030-RISKENGINE-REHEARSAL-GATE")
        XCTAssertEqual(evidence.mode, .dryRun)
        XCTAssertEqual(evidence.requirements, ReleaseV030ExecutionOMSRehearsalRequirement.allCases)
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ReleaseV030ExecutionOMSRehearsalForbiddenCapability.allCases)
        )

        XCTAssertEqual(evidence.eventLogs.count, 3)
        XCTAssertTrue(evidence.eventLogs.allSatisfy(\.eventLogHeld))
        XCTAssertTrue(evidence.eventLogs.allSatisfy(\.replayRestoresFinalState))
        XCTAssertTrue(evidence.eventLogs.contains { $0.path == .acceptedSubmittedFilled && $0.finalState == .filledSimulated })
        XCTAssertTrue(evidence.eventLogs.contains { $0.path == .acceptedSubmittedCancelled && $0.finalState == .cancelled })
        XCTAssertTrue(evidence.eventLogs.contains { $0.path == .riskRejected && $0.finalState == .rejected })
        XCTAssertEqual(
            Set(evidence.eventLogs.flatMap { log in log.transitions.flatMap { [$0.fromState, $0.toState] } }),
            Set(ReleaseV030OMSRehearsalState.allCases)
        )
        XCTAssertTrue(
            evidence.eventLogs.flatMap(\.envelopes).allSatisfy {
                $0.payloadType.contains("execution.release-v0.3.0.oms")
            }
        )

        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(evidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(evidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(evidence.productionCutoverAuthorized)
        XCTAssertFalse(evidence.callsExecutionClient)
        XCTAssertFalse(evidence.touchesBrokerGateway)
        XCTAssertFalse(evidence.productionOMSRuntimeEnabledByDefault)
        XCTAssertFalse(evidence.performsReconciliation)
        XCTAssertFalse(evidence.exposesDashboardCommandSurface)
        XCTAssertFalse(evidence.commandGatewayBypassAllowed)
        XCTAssertFalse(evidence.riskEngineBypassAllowed)
        XCTAssertFalse(evidence.eventStoreBypassAllowed)
        XCTAssertFalse(evidence.startsNextMilestone)

        for anchor in ReleaseV030ExecutionOMSRehearsalEvidence.requiredValidationAnchors {
            XCTAssertTrue(evidence.validationAnchors.contains(anchor), "\(anchor) must stay in Swift evidence")
            XCTAssertTrue(lifecycleDoc.contains(anchor), "\(anchor) must stay in Execution OMS contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(lifecycleDoc.contains("submitted-testnet-or-dry-run"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 ExecutionEngine OMS rehearsal lifecycle anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030ExecutionOMSRehearsalLifecycle.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH662ExecutionOMSRehearsalLifecycleConsumesRiskApprovedIntentAndReplaysOMSState"
            )
        )
        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(executionEngineTarget.contains("\"RiskEngine\""))

        for forbidden in [
            "import ExecutionClient",
            "URLSessionBinance",
            "/api/v3/order",
            "/fapi/v1/order"
        ] {
            XCTAssertFalse(lifecycleSource.contains(forbidden), "Execution OMS rehearsal source must not contain \(forbidden)")
        }

        XCTAssertThrowsError(
            try lifecycle.run(
                upstreamRiskEngineRehearsalAnchor: "UNSAFE-MISSING-GH-661-ANCHOR",
                riskEvidence: riskEvidence,
                recordedAt: Date(timeIntervalSince1970: 1_704_068_300)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamRiskEngineRehearsalAnchor",
                    expected: "TVM-RELEASE-V030-RISKENGINE-REHEARSAL-GATE",
                    actual: "UNSAFE-MISSING-GH-661-ANCHOR"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030OMSRehearsalTransition(
                transitionID: Identifier("gh-662-illegal-transition"),
                orderID: Identifier("gh-662-illegal-order"),
                sourceRiskDecisionID: riskEvidence.allowDecision.decisionID,
                fromState: .accepted,
                trigger: .simulatedFillObserved,
                toState: .filledSimulated,
                sequence: 1,
                recordedAt: Date(timeIntervalSince1970: 1_704_068_300)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "releaseV030OMS.transition",
                    expected: "legal OMS rehearsal transition",
                    actual: "accepted->simulated fill observed->filled-simulated"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030OMSRehearsalOrderIntent(
                orderIntentID: Identifier("gh-662-rejected-order-intent"),
                sourceRiskDecision: riskEvidence.invalidDecision,
                createdAt: Date(timeIntervalSince1970: 1_704_068_300)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "releaseV030OMS.sourceRiskDecision",
                    expected: "allowed risk decision",
                    actual: ReleaseV030RiskEngineRehearsalDecisionStatus.reject.rawValue
                )
            )
        }
    }

    func testGH663BinanceAdapterRehearsalMapsDryRunAndTestnetSubmitCancelReplace() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-binance-adapter-rehearsal-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let adapterSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/ExecutionClient/FutureGate/ReleaseV030BinanceAdapterRehearsal.swift"
            ),
            encoding: .utf8
        )

        let rehearsal = try ReleaseV030BinanceAdapterRehearsal()
        let evidence = try rehearsal.run(recordedAt: Date(timeIntervalSince1970: 1_704_068_400))

        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.mappingCoverageHeld)
        XCTAssertTrue(evidence.replayCoverageHeld)
        XCTAssertTrue(evidence.boundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-663")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-662")
        XCTAssertEqual(evidence.downstreamIssueID.rawValue, "GH-664")
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(evidence.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(evidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(
            evidence.upstreamOMSRehearsalAnchor,
            "TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE"
        )
        XCTAssertEqual(evidence.supportedProductTypes, [.spot, .usdsPerpetual])
        XCTAssertEqual(evidence.supportedCommands, ReleaseV030BinanceAdapterRehearsalCommandKind.allCases)
        XCTAssertEqual(evidence.requirements, ReleaseV030BinanceAdapterRehearsalRequirement.allCases)
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ReleaseV030BinanceAdapterRehearsalForbiddenCapability.allCases)
        )

        XCTAssertEqual(evidence.omsHandoffs.count, 2)
        XCTAssertTrue(evidence.omsHandoffs.allSatisfy(\.handoffHeld))
        XCTAssertTrue(evidence.omsHandoffs.allSatisfy { $0.sourceIssueID.rawValue == "GH-662" })
        XCTAssertTrue(evidence.omsHandoffs.allSatisfy { $0.stateEvidence.contains("submitted-testnet-or-dry-run") })
        XCTAssertEqual(evidence.dryRunMappings.count, 6)
        XCTAssertEqual(evidence.testnetMappings.count, 6)
        XCTAssertEqual(evidence.testnetAcknowledgements.count, 6)
        XCTAssertTrue(evidence.dryRunMappings.allSatisfy { $0.mode == .dryRun && $0.mappingHeld })
        XCTAssertTrue(evidence.testnetMappings.allSatisfy { $0.mode == .testnet && $0.mappingHeld })
        XCTAssertTrue(evidence.testnetAcknowledgements.allSatisfy(\.acknowledgementHeld))
        XCTAssertTrue(evidence.eventEnvelopes.allSatisfy { $0.payloadType.contains("executionclient.release-v0.3.0.binance") })
        XCTAssertEqual(evidence.eventEnvelopes, evidence.replayedEnvelopes)

        let dryRunPairs = Set(evidence.dryRunMappings.map { "\($0.productType.rawValue):\($0.commandKind.rawValue)" })
        let testnetPairs = Set(evidence.testnetMappings.map { "\($0.productType.rawValue):\($0.commandKind.rawValue)" })
        let expectedPairs = Set(["spot:submit", "spot:cancel", "spot:replace", "usdsPerpetual:submit", "usdsPerpetual:cancel", "usdsPerpetual:replace"])
        XCTAssertEqual(dryRunPairs, expectedPairs)
        XCTAssertEqual(testnetPairs, expectedPairs)
        XCTAssertTrue(evidence.testnetMappings.contains {
            $0.productType == .spot
                && $0.commandKind == .replace
                && $0.method == .post
                && $0.endpointPath == "/api/v3/order/cancelReplace"
        })
        XCTAssertTrue(evidence.testnetMappings.contains {
            $0.productType == .usdsPerpetual
                && $0.commandKind == .replace
                && $0.method == .put
                && $0.endpointPath == "/fapi/v1/order"
                && $0.positionSide == "SHORT"
        })
        XCTAssertTrue(evidence.testnetMappings.allSatisfy(\.signatureRequired))
        XCTAssertTrue(evidence.testnetMappings.allSatisfy { $0.networkCallPerformed == false })
        XCTAssertTrue(evidence.testnetMappings.allSatisfy { $0.productionOrderSubmitted == false })
        XCTAssertTrue(evidence.testnetMappings.allSatisfy { $0.rawBrokerPayloadExposedToDashboard == false })

        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(evidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(evidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(evidence.productionCutoverAuthorized)
        XCTAssertFalse(evidence.exposesRawBrokerPayloadToDashboard)
        XCTAssertFalse(evidence.commandGatewayBypassAllowed)
        XCTAssertFalse(evidence.riskEngineBypassAllowed)
        XCTAssertFalse(evidence.omsBypassAllowed)
        XCTAssertFalse(evidence.eventStoreBypassAllowed)
        XCTAssertFalse(evidence.startsNextMilestone)

        for anchor in ReleaseV030BinanceAdapterRehearsalEvidence.requiredValidationAnchors {
            XCTAssertTrue(evidence.validationAnchors.contains(anchor), "\(anchor) must stay in Swift evidence")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in Binance adapter rehearsal contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(contractDoc.contains("GH-662"))
        XCTAssertTrue(contractDoc.contains("GH-664"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 Binance adapter rehearsal anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030BinanceAdapterRehearsal.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH663BinanceAdapterRehearsalMapsDryRunAndTestnetSubmitCancelReplace"
            )
        )
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(adapterSource.contains("ReleaseV030BinanceAdapterRehearsal"))
        XCTAssertTrue(adapterSource.contains("ReleaseV030BinanceAdapterRehearsalEvidence"))
        XCTAssertTrue(adapterSource.contains("ReleaseV030BinanceAdapterRehearsalRequestMapping"))

        for forbidden in [
            "api.binance.com",
            "fapi.binance.com",
            "URLSession",
            "import ExecutionEngine",
            "import RiskEngine",
            "secretValue",
            "privateKey",
            "rawBrokerPayload:"
        ] {
            XCTAssertFalse(adapterSource.contains(forbidden), "Binance adapter rehearsal source must not contain \(forbidden)")
        }

        XCTAssertThrowsError(
            try rehearsal.run(
                upstreamOMSRehearsalAnchor: "UNSAFE-MISSING-GH-662-ANCHOR",
                recordedAt: Date(timeIntervalSince1970: 1_704_068_400)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamOMSRehearsalAnchor",
                    expected: "TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE",
                    actual: "UNSAFE-MISSING-GH-662-ANCHOR"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030BinanceAdapterRehearsalRequestMapping(
                mappingID: Identifier("gh-663-production-endpoint-rejected"),
                commandKind: .submit,
                mode: .testnet,
                productType: .spot,
                baseURL: URL(string: "https://api.binance.com"),
                credentialReferenceID: Identifier("gh-663-testnet-credential"),
                sourceOrderIntentID: Identifier("gh-662-order-intent"),
                sourceEventLogID: Identifier("gh-662-event-log"),
                sourceOMSOrderID: Identifier("gh-662-order"),
                clientOrderID: Identifier("gh-663-client-order"),
                symbol: "BTCUSDT",
                side: "BUY",
                queryItems: [
                    try ReleaseV030BinanceAdapterRehearsalQueryItem(name: "symbol", value: "BTCUSDT"),
                    try ReleaseV030BinanceAdapterRehearsalQueryItem(name: "side", value: "BUY"),
                    try ReleaseV030BinanceAdapterRehearsalQueryItem(name: "type", value: "LIMIT"),
                    try ReleaseV030BinanceAdapterRehearsalQueryItem(name: "timeInForce", value: "GTC"),
                    try ReleaseV030BinanceAdapterRehearsalQueryItem(name: "quantity", value: "0.10"),
                    try ReleaseV030BinanceAdapterRehearsalQueryItem(name: "price", value: "43000"),
                    try ReleaseV030BinanceAdapterRehearsalQueryItem(name: "newClientOrderId", value: "unsafe"),
                    try ReleaseV030BinanceAdapterRehearsalQueryItem(name: "recvWindow", value: "5000"),
                    try ReleaseV030BinanceAdapterRehearsalQueryItem(name: "timestamp", value: "1704068600000")
                ]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV030BinanceAdapter.productionEndpoint")
            )
        }
    }

    func testGH664EventStoreReplayReconstructsRehearsalCausalityChain() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let databaseTarget = try packageTargetBlock(named: "Database", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-event-store-rehearsal-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let eventStoreSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/Database/ReleaseV030EventStoreRehearsalEvidence.swift"
            ),
            encoding: .utf8
        )

        let evidence = try ReleaseV030EventStoreRehearsal.deterministicEvidence()

        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.boundaryHeld)
        XCTAssertTrue(evidence.appendOnlyRecordsHeld)
        XCTAssertTrue(evidence.correlationCausationHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-664")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-663")
        XCTAssertEqual(evidence.downstreamIssueID.rawValue, "GH-665")
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(evidence.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(evidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(evidence.upstreamAdapterRehearsalAnchor, "TVM-RELEASE-V030-BINANCE-ADAPTER-REHEARSAL")
        XCTAssertEqual(evidence.requirements, ReleaseV030EventStoreRehearsalRequirement.allCases)
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ReleaseV030EventStoreRehearsalForbiddenCapability.allCases)
        )

        XCTAssertEqual(evidence.records.count, 6)
        XCTAssertEqual(evidence.records, evidence.replayedRecords)
        XCTAssertTrue(evidence.records.allSatisfy(\.recordHeld))
        XCTAssertEqual(evidence.records.map(\.sequence), [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(
            evidence.records.map(\.stage),
            [.strategy, .risk, .execution, .oms, .adapter, .portfolio]
        )
        XCTAssertEqual(
            evidence.records.map { $0.sourceIssueID.rawValue },
            ["GH-660", "GH-661", "GH-662", "GH-662", "GH-663", "GH-664"]
        )
        XCTAssertTrue(evidence.records.dropFirst().enumerated().allSatisfy { index, record in
            record.causationID == evidence.records[index].eventID
        })
        XCTAssertTrue(evidence.records.allSatisfy {
            $0.correlationID == ReleaseV030EventStoreRehearsalStore.requiredCorrelationID
        })
        XCTAssertTrue(evidence.records.allSatisfy {
            $0.payloadType.contains("database.release-v0.3.0")
                && $0.instrumentID.productType == .spot
                && $0.strategyID.rawValue == "ema"
        })

        XCTAssertTrue(evidence.replayState.replayStateHeld)
        XCTAssertEqual(evidence.replayState.eventCount, 6)
        XCTAssertEqual(evidence.replayState.finalStage, .portfolio)
        XCTAssertEqual(evidence.replayState.latestChecksum, evidence.records.last?.checksum)
        XCTAssertTrue(evidence.replayState.reconstructsStrategyRiskExecutionOMSPortfolio)
        XCTAssertTrue(evidence.replayState.correlationCausationHeld)
        XCTAssertTrue(try ReleaseV030EventStoreRehearsal.outOfOrderAppendRejected())

        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(evidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(evidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(evidence.productionCutoverAuthorized)
        XCTAssertFalse(evidence.productionEventStoreRuntimeEnabled)
        XCTAssertFalse(evidence.rawBrokerPayloadStored)
        XCTAssertFalse(evidence.rawDatabaseSchemaExposedToDashboard)
        XCTAssertFalse(evidence.dashboardCommandSurfaceExposed)
        XCTAssertFalse(evidence.commandGatewayBypassAllowed)
        XCTAssertFalse(evidence.riskEngineBypassAllowed)
        XCTAssertFalse(evidence.omsBypassAllowed)
        XCTAssertFalse(evidence.eventStoreBypassAllowed)
        XCTAssertFalse(evidence.startsNextMilestone)

        for anchor in ReleaseV030EventStoreRehearsalEvidence.requiredValidationAnchors {
            XCTAssertTrue(evidence.validationAnchors.contains(anchor), "\(anchor) must stay in Swift evidence")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in Event Store rehearsal contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(contractDoc.contains("GH-663"))
        XCTAssertTrue(contractDoc.contains("GH-665"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 Event Store rehearsal anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030EventStoreRehearsalEvidence.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH664EventStoreReplayReconstructsRehearsalCausalityChain"
            )
        )
        XCTAssertTrue(databaseTarget.contains("\"ReleaseV030EventStoreRehearsalEvidence.swift\""))

        for forbidden in [
            "import ExecutionClient",
            "import ExecutionEngine",
            "import RiskEngine",
            "URLSession",
            "api.binance.com",
            "fapi.binance.com",
            "secretValue",
            "rawBrokerPayload:"
        ] {
            XCTAssertFalse(eventStoreSource.contains(forbidden), "Event Store rehearsal source must not contain \(forbidden)")
        }

        XCTAssertThrowsError(
            try ReleaseV030EventStoreRehearsalEvidence(
                upstreamAdapterRehearsalAnchor: "UNSAFE-MISSING-GH-663-ANCHOR",
                records: evidence.records,
                replayedRecords: evidence.replayedRecords,
                replayState: evidence.replayState
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamAdapterRehearsalAnchor",
                    expected: "TVM-RELEASE-V030-BINANCE-ADAPTER-REHEARSAL",
                    actual: "UNSAFE-MISSING-GH-663-ANCHOR"
                )
            )
        }
    }

    func testGH665PortfolioProjectionRehearsalProjectsSpotPerpAndAttributionFromReplayEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let portfolioTarget = try packageTargetBlock(named: "Portfolio", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-portfolio-projection-rehearsal-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let portfolioSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/Portfolio/ReleaseV030PortfolioProjectionRehearsal.swift"
            ),
            encoding: .utf8
        )

        let evidence = try ReleaseV030PortfolioProjectionRehearsal.deterministicEvidence()

        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.boundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-665")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-664")
        XCTAssertEqual(evidence.downstreamIssueID.rawValue, "GH-666")
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(evidence.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(evidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(
            evidence.upstreamEventStoreAnchor,
            "TVM-RELEASE-V030-EVENT-STORE-REHEARSAL-EVIDENCE"
        )
        XCTAssertTrue(evidence.upstreamReplayState.replayStateHeld)
        XCTAssertEqual(evidence.requirements, ReleaseV030PortfolioProjectionRehearsalRequirement.allCases)
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ReleaseV030PortfolioProjectionRehearsalForbiddenCapability.allCases)
        )

        XCTAssertEqual(evidence.fills.count, 4)
        XCTAssertTrue(evidence.fills.allSatisfy(\.fillHeld))
        XCTAssertEqual(Set(evidence.fills.map(\.productType)), Set(ProductType.allCases))
        XCTAssertEqual(
            Set(evidence.fills.map(\.strategyKind)),
            Set(ReleaseV030PortfolioProjectionRehearsalStrategyKind.allCases)
        )
        XCTAssertTrue(evidence.fills.allSatisfy {
            $0.sourceEvidenceAnchor == ReleaseV030PortfolioProjectionRehearsalEvidence.requiredUpstreamEventStoreAnchor
                && $0.sourceReplaySequence == 6
                && $0.simulatedOrTestnetEvidence
                && $0.rawBrokerPayloadExposed == false
                && $0.productionAccountSynced == false
                && $0.accountEndpointRead == false
                && $0.brokerPositionSynced == false
        })

        XCTAssertEqual(evidence.productProjections.count, 2)
        XCTAssertTrue(evidence.productProjections.allSatisfy(\.projectionHeld))
        XCTAssertEqual(Set(evidence.productProjections.map(\.productType)), Set(ProductType.allCases))
        let spotProjection = try XCTUnwrap(evidence.productProjections.first { $0.productType == .spot })
        let perpProjection = try XCTUnwrap(evidence.productProjections.first { $0.productType == .usdsPerpetual })
        XCTAssertEqual(spotProjection.netPositionQuantity, 0.05, accuracy: 0.000001)
        XCTAssertEqual(perpProjection.netPositionQuantity, 0.12, accuracy: 0.000001)
        XCTAssertFalse(spotProjection.productionAccountSynced)
        XCTAssertFalse(perpProjection.brokerPositionSynced)
        XCTAssertFalse(spotProjection.reconciliationRuntimeExecuted)
        XCTAssertFalse(perpProjection.rawBrokerPayloadExposed)

        XCTAssertEqual(evidence.strategyAttributions.count, 2)
        XCTAssertTrue(evidence.strategyAttributions.allSatisfy(\.attributionHeld))
        XCTAssertEqual(
            Set(evidence.strategyAttributions.map(\.strategyKind)),
            Set(ReleaseV030PortfolioProjectionRehearsalStrategyKind.allCases)
        )
        XCTAssertTrue(evidence.strategyAttributions.allSatisfy {
            Set($0.productTypes) == Set(ProductType.allCases)
                && $0.visibleInEvidence
                && $0.productionAccountSynced == false
                && $0.rawBrokerPayloadExposed == false
        })
        XCTAssertTrue(try ReleaseV030PortfolioProjectionRehearsal.productionAccountSyncRejected())

        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(evidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(evidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(evidence.productionCutoverAuthorized)
        XCTAssertFalse(evidence.productionAccountSyncEnabled)
        XCTAssertFalse(evidence.accountEndpointReadEnabled)
        XCTAssertFalse(evidence.brokerPositionSyncEnabled)
        XCTAssertFalse(evidence.rawBrokerPayloadExposed)
        XCTAssertFalse(evidence.reconciliationRuntimeExecuted)
        XCTAssertFalse(evidence.dashboardCommandSurfaceExposed)
        XCTAssertFalse(evidence.commandGatewayBypassAllowed)
        XCTAssertFalse(evidence.startsNextMilestone)

        for anchor in ReleaseV030PortfolioProjectionRehearsalEvidence.requiredValidationAnchors {
            XCTAssertTrue(evidence.validationAnchors.contains(anchor), "\(anchor) must stay in Swift evidence")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in Portfolio rehearsal contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(contractDoc.contains("GH-664"))
        XCTAssertTrue(contractDoc.contains("GH-666"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 Portfolio projection rehearsal anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030PortfolioProjectionRehearsal.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH665PortfolioProjectionRehearsalProjectsSpotPerpAndAttributionFromReplayEvidence"
            )
        )
        XCTAssertTrue(portfolioTarget.contains("\"ReleaseV030PortfolioProjectionRehearsal.swift\""))
        XCTAssertTrue(
            PortfolioParityOwnershipContract.gh634.activeSourcePaths.contains(
                "Sources/Portfolio/ReleaseV030PortfolioProjectionRehearsal.swift"
            )
        )

        for forbidden in [
            "import ExecutionClient",
            "import ExecutionEngine",
            "import RiskEngine",
            "URLSession",
            "api.binance.com",
            "fapi.binance.com",
            "listenKey",
            "secretValue",
            "rawBrokerPayload:"
        ] {
            XCTAssertFalse(
                portfolioSource.contains(forbidden),
                "Portfolio rehearsal source must not contain \(forbidden)"
            )
        }

        XCTAssertThrowsError(
            try ReleaseV030PortfolioProjectionRehearsalEvidence(
                upstreamEventStoreAnchor: "UNSAFE-MISSING-GH-664-ANCHOR",
                upstreamReplayState: evidence.upstreamReplayState,
                fills: evidence.fills,
                productProjections: evidence.productProjections,
                strategyAttributions: evidence.strategyAttributions
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamEventStoreAnchor",
                    expected: "TVM-RELEASE-V030-EVENT-STORE-REHEARSAL-EVIDENCE",
                    actual: "UNSAFE-MISSING-GH-664-ANCHOR"
                )
            )
        }
    }

    func testGH666DashboardCLIRehearsalSurfaceShowsStatusGatesAndCommandGatewayRoute() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let portfolioTarget = try packageTargetBlock(named: "Portfolio", packageSource: packageSource)
        let databaseTarget = try packageTargetBlock(named: "Database", packageSource: packageSource)
        let persistenceTarget = try packageTargetBlock(named: "Persistence", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let cliTarget = try packageTargetBlock(named: "MTPROCLI", packageSource: packageSource)
        let databaseSources = try packageTargetSourcesBlock(targetBlock: databaseTarget)
        let persistenceExcludes = try packageTargetExcludesBlock(targetBlock: persistenceTarget)
        let runtimeExcludes = try packageTargetExcludesBlock(targetBlock: runtimeTarget)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-dashboard-cli-rehearsal-surface-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let portfolioSurfaceSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/Portfolio/ReleaseV030RehearsalSurface.swift"
            ),
            encoding: .utf8
        )
        let databaseCLISource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/Database/ReleaseV030CLIRehearsalSurface.swift"
            ),
            encoding: .utf8
        )
        let dashboardSurfaceSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/Dashboard/Report/ReleaseV030DashboardRehearsalSurface.swift"
            ),
            encoding: .utf8
        )
        let cliSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/MTPROCLI/main.swift"),
            encoding: .utf8
        )

        let evidence = try ReleaseV030RehearsalSurface.deterministicEvidence()
        let cliEvidence = try ReleaseV030CLIRehearsalSurface.deterministicEvidence()

        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.boundaryHeld)
        XCTAssertTrue(cliEvidence.cliBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-666")
        XCTAssertEqual(cliEvidence.issueID.rawValue, "GH-666")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-665")
        XCTAssertEqual(cliEvidence.upstreamIssueID.rawValue, "GH-665")
        XCTAssertEqual(evidence.downstreamIssueID.rawValue, "GH-667")
        XCTAssertEqual(cliEvidence.downstreamIssueID.rawValue, "GH-667")
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(cliEvidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(evidence.projectName, "MTPRO Release v0.3.0 Runtime Rehearsal v1")
        XCTAssertEqual(evidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(cliEvidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(
            evidence.upstreamPortfolioProjectionAnchor,
            "TVM-RELEASE-V030-PORTFOLIO-PROJECTION-REHEARSAL"
        )
        XCTAssertEqual(
            cliEvidence.upstreamPortfolioProjectionAnchor,
            "TVM-RELEASE-V030-PORTFOLIO-PROJECTION-REHEARSAL"
        )
        XCTAssertEqual(evidence.runStatus, .blocked)
        XCTAssertEqual(cliEvidence.runStatus, .blocked)
        XCTAssertEqual(Set(evidence.productTypes), Set(ProductType.allCases))
        XCTAssertEqual(Set(cliEvidence.productTypes), Set(ProductType.allCases))
        XCTAssertEqual(
            Set(evidence.strategies),
            Set(ReleaseV030PortfolioProjectionRehearsalStrategyKind.allCases)
        )
        XCTAssertEqual(
            Set(cliEvidence.strategies),
            Set(ReleaseV030CLIRehearsalStrategyKind.allCases)
        )
        XCTAssertEqual(evidence.gates.map(\.gate), ReleaseV030RehearsalSurfaceGate.allCases)
        XCTAssertEqual(cliEvidence.gates.map(\.gate), ReleaseV030CLIRehearsalGate.allCases)
        XCTAssertTrue(evidence.gates.allSatisfy(\.gateHeld))
        XCTAssertTrue(cliEvidence.gates.allSatisfy(\.gateHeld))
        XCTAssertEqual(evidence.requirements, ReleaseV030RehearsalSurfaceRequirement.allCases)
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ReleaseV030RehearsalSurfaceForbiddenCapability.allCases)
        )
        XCTAssertEqual(evidence.killSwitchStatus, .blocked)
        XCTAssertEqual(evidence.noTradeStatus, .blocked)
        XCTAssertEqual(cliEvidence.killSwitchStatus, .blocked)
        XCTAssertEqual(cliEvidence.noTradeStatus, .blocked)
        XCTAssertTrue(evidence.failureReasons.contains { $0.contains("kill switch") })
        XCTAssertTrue(evidence.failureReasons.contains { $0.contains("no-trade") })
        XCTAssertTrue(cliEvidence.failureReasons.contains { $0.contains("kill switch") })
        XCTAssertTrue(cliEvidence.failureReasons.contains { $0.contains("no-trade") })
        XCTAssertTrue(evidence.dashboardStatusVisible)
        XCTAssertTrue(evidence.cliStatusVisible)
        XCTAssertTrue(evidence.failureReasonsVisible)
        XCTAssertTrue(evidence.killSwitchStatusVisible)
        XCTAssertTrue(evidence.noTradeStatusVisible)
        XCTAssertTrue(evidence.commandsRouteThroughCommandGateway)
        XCTAssertThrowsError(
            try ReleaseV030RehearsalSurfaceGateEvidence(
                gate: .commandGateway,
                status: .ready,
                failureReason: "unsafe bypass attempt",
                bypassesCommandGateway: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV030RehearsalSurface.gate.bypassesCommandGateway"
                )
            )
        }

        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(evidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(evidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(evidence.productionCutoverAuthorized)
        XCTAssertFalse(evidence.dashboardTradingButtonExposed)
        XCTAssertFalse(evidence.liveCommandSurfaceExposed)
        XCTAssertFalse(evidence.orderFormExposed)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.accountEndpointRead)
        XCTAssertFalse(evidence.dashboardBypassesCommandGateway)
        XCTAssertFalse(evidence.cliBypassesCommandGateway)
        XCTAssertFalse(evidence.startsNextMilestone)
        XCTAssertFalse(cliEvidence.productionTradingEnabledByDefault)
        XCTAssertFalse(cliEvidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(cliEvidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(cliEvidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(cliEvidence.productionCutoverAuthorized)
        XCTAssertFalse(cliEvidence.accountEndpointRead)
        XCTAssertFalse(cliEvidence.brokerGatewayTouched)
        XCTAssertFalse(cliEvidence.bypassesCommandGateway)
        XCTAssertFalse(cliEvidence.startsNextMilestone)

        let viewModel = try ReleaseV030DashboardRehearsalSurfaceViewModel.deterministic()
        XCTAssertTrue(viewModel.dashboardSurfaceBoundaryHeld)
        XCTAssertEqual(viewModel.issueID, "GH-666")
        XCTAssertEqual(viewModel.matrixID, "TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE")
        XCTAssertEqual(viewModel.runStatusLabel, "blocked")
        XCTAssertEqual(Set(viewModel.productTypeLabels), Set(ProductType.supportedRawValues))
        XCTAssertEqual(viewModel.gateLabels, ReleaseV030RehearsalSurfaceGate.allCases.map(\.rawValue))
        XCTAssertTrue(viewModel.dashboardStatusVisible)
        XCTAssertTrue(viewModel.failureReasonsVisible)
        XCTAssertTrue(viewModel.killSwitchStatusVisible)
        XCTAssertTrue(viewModel.noTradeStatusVisible)
        XCTAssertTrue(viewModel.commandsRouteThroughCommandGateway)
        XCTAssertFalse(viewModel.commandSurfaceEnabled)
        XCTAssertFalse(viewModel.providesTradingButton)
        XCTAssertFalse(viewModel.exposesOrderForm)
        XCTAssertFalse(viewModel.authorizesTradingExecution)
        XCTAssertFalse(viewModel.readsSecret)
        XCTAssertFalse(viewModel.opensProductionEndpoint)
        XCTAssertFalse(viewModel.touchesAccountEndpoint)
        XCTAssertFalse(viewModel.connectsBroker)
        XCTAssertFalse(viewModel.submitsRealOrder)
        XCTAssertFalse(viewModel.bypassesCommandGateway)

        let cliOutput = try ReleaseV030CLIRehearsalSurface.commandLineOutput(arguments: ["rehearsal-status"])
        XCTAssertTrue(cliOutput.contains("mtpro rehearsal-status blocked"))
        XCTAssertTrue(cliOutput.contains("issue=GH-666"))
        XCTAssertTrue(cliOutput.contains("upstream=GH-665"))
        XCTAssertTrue(cliOutput.contains("commandGateway=required"))
        XCTAssertTrue(cliOutput.contains("validationAnchor=TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE"))
        XCTAssertTrue(cliOutput.contains("killSwitchStatus=blocked"))
        XCTAssertTrue(cliOutput.contains("noTradeStatus=blocked"))
        XCTAssertTrue(cliOutput.contains("commandsRouteThroughCommandGateway=true"))
        XCTAssertTrue(cliOutput.contains("productionTradingEnabledByDefault=false"))
        XCTAssertTrue(cliOutput.contains("productionCutoverAuthorized=false"))
        XCTAssertTrue(cliOutput.contains("boundaryHeld=true"))
        XCTAssertThrowsError(try ReleaseV030CLIRehearsalSurface.commandLineOutput(arguments: ["submit"])) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "mtpro.rehearsal.arguments",
                    expected: "rehearsal-status",
                    actual: "submit"
                )
            )
        }

        for anchor in ReleaseV030RehearsalSurfaceEvidence.requiredValidationAnchors {
            XCTAssertTrue(evidence.validationAnchors.contains(anchor), "\(anchor) must stay in Swift evidence")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in Dashboard / CLI rehearsal contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(contractDoc.contains("GH-665"))
        XCTAssertTrue(contractDoc.contains("GH-667"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 Dashboard / CLI rehearsal surface anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030RehearsalSurface.swift"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030CLIRehearsalSurface.swift"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030DashboardRehearsalSurfaceViewModel"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH666DashboardCLIRehearsalSurfaceShowsStatusGatesAndCommandGatewayRoute"
            )
        )
        XCTAssertTrue(portfolioTarget.contains("\"ReleaseV030RehearsalSurface.swift\""))
        XCTAssertTrue(databaseSources.contains("\"ReleaseV030CLIRehearsalSurface.swift\""))
        XCTAssertTrue(persistenceExcludes.contains("\"ReleaseV030CLIRehearsalSurface.swift\""))
        XCTAssertTrue(runtimeExcludes.contains("\"Database/ReleaseV030CLIRehearsalSurface.swift\""))
        XCTAssertTrue(coreTarget.contains("\"Portfolio/ReleaseV030RehearsalSurface.swift\""))
        XCTAssertTrue(cliTarget.contains("dependencies: [\"Database\"]"))
        XCTAssertFalse(cliTarget.contains("\"Portfolio\""))
        XCTAssertFalse(cliTarget.contains("\"Core\""))
        XCTAssertFalse(cliTarget.contains("\"MessageBus\""))
        XCTAssertTrue(cliSource.contains("ReleaseV030CLIRehearsalSurface.cliCommand"))
        XCTAssertTrue(
            PortfolioParityOwnershipContract.gh634.activeSourcePaths.contains(
                "Sources/Portfolio/ReleaseV030RehearsalSurface.swift"
            )
        )

        for forbidden in [
            "import ExecutionClient",
            "import ExecutionEngine",
            "import RiskEngine",
            "URLSession",
            "api.binance.com",
            "fapi.binance.com",
            "listenKey",
            "secretValue",
            "rawBrokerPayload:"
        ] {
            XCTAssertFalse(
                portfolioSurfaceSource.contains(forbidden),
                "Portfolio rehearsal surface source must not contain \(forbidden)"
            )
            XCTAssertFalse(
                databaseCLISource.contains(forbidden),
                "Database CLI rehearsal surface source must not contain \(forbidden)"
            )
            XCTAssertFalse(
                dashboardSurfaceSource.contains(forbidden),
                "Dashboard rehearsal surface source must not contain \(forbidden)"
            )
            XCTAssertFalse(
                cliSource.contains(forbidden),
                "CLI rehearsal surface route must not contain \(forbidden)"
            )
        }

        XCTAssertThrowsError(
            try ReleaseV030RehearsalSurfaceEvidence(
                upstreamPortfolioProjectionAnchor: "UNSAFE-MISSING-GH-665-ANCHOR",
                gates: evidence.gates
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamPortfolioProjectionAnchor",
                    expected: "TVM-RELEASE-V030-PORTFOLIO-PROJECTION-REHEARSAL",
                    actual: "UNSAFE-MISSING-GH-665-ANCHOR"
                )
            )
        }
    }

    func testGH667KillSwitchNoTradeRollbackDrillBlocksSubmitCancelReplace() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-kill-switch-notrade-rollback-drill-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let drillSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/ExecutionEngine/OMSFutureGate/ReleaseV030KillSwitchNoTradeRollbackDrill.swift"
            ),
            encoding: .utf8
        )

        let evidence = try ReleaseV030KillSwitchNoTradeRollbackDrill.deterministicEvidence()

        XCTAssertTrue(evidence.evidenceHeld)
        XCTAssertTrue(evidence.boundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-667")
        XCTAssertEqual(evidence.upstreamIssueID.rawValue, "GH-666")
        XCTAssertEqual(evidence.downstreamIssueID.rawValue, "GH-668")
        XCTAssertEqual(evidence.canonicalQueueRange, "GH-657..GH-670")
        XCTAssertEqual(evidence.releaseVersion, "v0.3.0")
        XCTAssertEqual(evidence.upstreamSurfaceAnchor, "TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE")
        XCTAssertEqual(evidence.upstreamSurfaceIssueID.rawValue, "GH-666")
        XCTAssertEqual(evidence.upstreamSurfaceStatus, .blocked)
        XCTAssertEqual(evidence.requirements, ReleaseV030ControlDrillRequirement.allCases)
        XCTAssertEqual(
            Set(evidence.forbiddenCapabilities),
            Set(ReleaseV030ControlDrillForbiddenCapability.allCases)
        )
        XCTAssertEqual(evidence.blockedCommands.count, 9)
        XCTAssertEqual(Set(evidence.blockedCommands.map(\.command)), Set(ReleaseV030ControlDrillCommandKind.allCases))
        XCTAssertEqual(Set(evidence.blockedCommands.map(\.scenario)), Set(ReleaseV030ControlDrillScenario.allCases))
        XCTAssertTrue(evidence.blockedCommands.allSatisfy(\.blockHeld))
        XCTAssertTrue(evidence.blockedCommands.allSatisfy {
            $0.commandGatewayRoute.hasPrefix("command-gateway/release-v0.3.0/drill/")
                && $0.audited
                && $0.blockedBeforeExecutionClient
                && $0.blockedBeforeBrokerGateway
        })

        let killSwitchRecords = evidence.records(for: .killSwitch)
        let noTradeRecords = evidence.records(for: .noTrade)
        let rollbackRecords = evidence.records(for: .rollback)
        XCTAssertEqual(killSwitchRecords.count, 3)
        XCTAssertEqual(noTradeRecords.count, 3)
        XCTAssertEqual(rollbackRecords.count, 3)
        XCTAssertEqual(Set(killSwitchRecords.map(\.command)), Set(ReleaseV030ControlDrillCommandKind.allCases))
        XCTAssertEqual(Set(noTradeRecords.map(\.command)), Set(ReleaseV030ControlDrillCommandKind.allCases))
        XCTAssertEqual(Set(rollbackRecords.map(\.command)), Set(ReleaseV030ControlDrillCommandKind.allCases))
        XCTAssertTrue(killSwitchRecords.allSatisfy { $0.blockReason.contains("kill switch active") })
        XCTAssertTrue(noTradeRecords.allSatisfy { $0.blockReason.contains("no-trade state") })
        XCTAssertTrue(rollbackRecords.allSatisfy {
            $0.blockReason.contains("rollback drill")
                && $0.rollbackEvidenceID == evidence.rollbackEvidence.evidenceID
        })

        XCTAssertTrue(evidence.rollbackEvidence.boundaryHeld)
        XCTAssertTrue(evidence.rollbackEvidence.rollbackReady)
        XCTAssertTrue(evidence.rollbackEvidence.noTradePriorityHeld)
        XCTAssertTrue(evidence.rollbackEvidence.incidentStopActive)
        XCTAssertEqual(
            evidence.rollbackEvidence.auditSteps,
            ReleaseV030RollbackDrillEvidence.requiredAuditSteps
        )
        XCTAssertFalse(evidence.rollbackEvidence.restoresProductionTrading)
        XCTAssertFalse(evidence.rollbackEvidence.connectsBrokerGateway)
        XCTAssertFalse(evidence.rollbackEvidence.submitsRealOrder)
        XCTAssertFalse(evidence.rollbackEvidence.productionCutoverAuthorized)

        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(evidence.productionSecretAutoReadEnabled)
        XCTAssertFalse(evidence.productionOrderSubmissionEnabled)
        XCTAssertFalse(evidence.productionCutoverAuthorized)
        XCTAssertFalse(evidence.startsNextMilestone)

        for anchor in ReleaseV030KillSwitchNoTradeRollbackDrillEvidence.requiredValidationAnchors {
            XCTAssertTrue(evidence.validationAnchors.contains(anchor), "\(anchor) must stay in Swift evidence")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in kill switch / no-trade contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(contractDoc.contains("GH-666"))
        XCTAssertTrue(contractDoc.contains("GH-668"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 kill switch / no-trade / rollback drill anchor"))
        XCTAssertTrue(readinessScript.contains("ReleaseV030KillSwitchNoTradeRollbackDrill.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH667KillSwitchNoTradeRollbackDrillBlocksSubmitCancelReplace"
            )
        )
        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(coreTarget.contains("\"ExecutionEngine/OMSFutureGate\""))

        for forbidden in [
            "import ExecutionClient",
            "URLSession",
            "api.binance.com",
            "fapi.binance.com",
            "secretValue",
            "listenKey",
            "rawBrokerPayload:"
        ] {
            XCTAssertFalse(drillSource.contains(forbidden), "GH-667 drill source must not contain \(forbidden)")
        }

        XCTAssertThrowsError(
            try ReleaseV030BlockedCommandDrillRecord(
                command: .submit,
                scenario: .killSwitch,
                blockReason: "unsafe bypass attempt",
                bypassesCommandGateway: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV030ControlDrill.bypassesCommandGateway")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV030RollbackDrillEvidence(productionCutoverAuthorized: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV030RollbackDrill.productionCutoverAuthorized")
            )
        }
    }

    func testGH668VerifyV030ReleaseValidationSuiteCoversFullRehearsalChain() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let verificationScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/verify-v0.3.0.sh"),
            encoding: .utf8
        )
        let runScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/run.sh"),
            encoding: .utf8
        )
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.3.0-validation-suite-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let targetGraphTests = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Tests/TargetGraphTests/TargetGraphTests.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(verificationScript.contains("GH-668-VERIFY-V030-RELEASE-VALIDATION-SUITE"))
        XCTAssertTrue(verificationScript.contains("TVM-RELEASE-V030-VERIFY-VALIDATION-SUITE"))
        XCTAssertTrue(runScript.contains("bash checks/verify-v0.3.0.sh"))
        XCTAssertTrue(readinessScript.contains("checks/verify-v0.3.0.sh"))

        let requiredFocusedTests = [
            "testGH657ReleaseV030RuntimeRehearsalContractDefinesDryRunTestnetShadowBoundary",
            "testGH658RuntimeEnvironmentConfigDefaultsSafeAndRejectsProductionTransitions",
            "testGH659DataEngineRuntimeRehearsalFlowPreservesSpotPerpProductIdentity",
            "testGH660TraderStrategyRuntimeRehearsalFlowEmitsEMAAndRSIIntentThroughMessageBus",
            "testGH661RiskEngineRehearsalGateAllowsRejectsAndBlocksStrategyIntents",
            "testGH662ExecutionOMSRehearsalLifecycleConsumesRiskApprovedIntentAndReplaysOMSState",
            "testGH663BinanceAdapterRehearsalMapsDryRunAndTestnetSubmitCancelReplace",
            "testGH664EventStoreReplayReconstructsRehearsalCausalityChain",
            "testGH665PortfolioProjectionRehearsalProjectsSpotPerpAndAttributionFromReplayEvidence",
            "testGH666DashboardCLIRehearsalSurfaceShowsStatusGatesAndCommandGatewayRoute",
            "testGH667KillSwitchNoTradeRollbackDrillBlocksSubmitCancelReplace"
        ]
        for testName in requiredFocusedTests {
            XCTAssertTrue(verificationScript.contains(testName), "\(testName) must stay in verify-v0.3.0.sh")
            XCTAssertTrue(targetGraphTests.contains(testName), "\(testName) must stay in TargetGraphTests")
        }

        for cliAssertion in [
            "swift run mtpro rehearsal-status",
            "mtpro rehearsal-status blocked",
            "commandGateway=required",
            "killSwitchStatus=blocked",
            "noTradeStatus=blocked",
            "commandsRouteThroughCommandGateway=true",
            "productionTradingEnabledByDefault=false",
            "productionEndpointAutoConnect=false",
            "productionSecretAutoRead=false",
            "productionOrderSubmission=false",
            "productionCutoverAuthorized=false",
            "boundaryHeld=true"
        ] {
            XCTAssertTrue(verificationScript.contains(cliAssertion), "\(cliAssertion) must stay in CLI smoke")
        }

        for anchor in [
            "V030-12-VERIFY-RELEASE-VALIDATION-SUITE",
            "V030-12-COMPLETE-REHEARSAL-CHAIN",
            "V030-12-CLI-REHEARSAL-SMOKE",
            "V030-12-PRODUCTION-DISABLED-BOUNDARY",
            "TVM-RELEASE-V030-VERIFY-VALIDATION-SUITE"
        ] {
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation plan")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading matrix")
            XCTAssertTrue(readinessScript.contains(anchor), "\(anchor) must stay in readiness script")
        }

        XCTAssertTrue(validationPlan.contains("GH-668 Release v0.3.0 Validation Suite"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 validation suite anchor"))
        XCTAssertTrue(tradingMatrix.contains("GH-669"))
        XCTAssertTrue(contractDoc.contains("GH-669"))

        for forbidden in [
            "api.binance.com",
            "fapi.binance.com",
            "secretValue",
            "listenKey",
            "rawBrokerPayload:",
            "productionCutoverAuthorized=true",
            "productionTradingEnabledByDefault=true"
        ] {
            XCTAssertFalse(verificationScript.contains(forbidden), "verify-v0.3.0.sh must not contain \(forbidden)")
        }
    }

    func testGH669OperatorRehearsalRunbookDocumentsStartObserveStopAndProductionProof() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let runbook = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/operators/release-v0.3.0-operator-rehearsal-runbook.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        for anchor in [
            "GH-669-RELEASE-V030-OPERATOR-REHEARSAL-RUNBOOK",
            "V030-13-START-REHEARSAL",
            "V030-13-OBSERVE-DASHBOARD-CLI-EVIDENCE",
            "V030-13-STOP-REHEARSAL",
            "V030-13-PRODUCTION-DISABLED-PROOF",
            "TVM-RELEASE-V030-OPERATOR-REHEARSAL-RUNBOOK",
            "GH-669-NON-AUTHORIZATION"
        ] {
            XCTAssertTrue(runbook.contains(anchor), "\(anchor) must stay in operator runbook")
            XCTAssertTrue(readinessScript.contains(anchor), "\(anchor) must stay in readiness script")
        }

        for command in [
            "git diff --check",
            "bash checks/automation-readiness.sh",
            "bash checks/verify-v0.3.0.sh",
            "swift run mtpro rehearsal-status",
            "DASHBOARD_SMOKE=1 swift run Dashboard",
            "bash checks/run.sh"
        ] {
            XCTAssertTrue(runbook.contains(command), "\(command) must stay in runbook")
        }

        for observedEvidence in [
            "mtpro rehearsal-status blocked",
            "commandGateway=required",
            "validationAnchor=TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE",
            "productTypes=spot,usdsPerpetual",
            "strategies=ema,rsi",
            "killSwitchStatus=blocked",
            "noTradeStatus=blocked",
            "commandsRouteThroughCommandGateway=true",
            "boundaryHeld=true"
        ] {
            XCTAssertTrue(runbook.contains(observedEvidence), "\(observedEvidence) must stay in observe section")
        }

        for productionDisabledProof in [
            "productionTradingEnabledByDefault=false",
            "productionEndpointAutoConnect=false",
            "productionSecretAutoRead=false",
            "productionOrderSubmission=false",
            "productionCutoverAuthorized=false"
        ] {
            XCTAssertTrue(runbook.contains(productionDisabledProof), "\(productionDisabledProof) must stay in proof")
        }

        for stopBoundary in [
            "停止当前 shell command",
            "保留 kill switch / no-trade blocked 状态",
            "不执行 automatic recovery",
            "不调用 broker emergency API",
            "不执行 rollback command",
            "不触发 submit / cancel / replace"
        ] {
            XCTAssertTrue(runbook.contains(stopBoundary), "\(stopBoundary) must stay in stop procedure")
        }

        XCTAssertTrue(validationPlan.contains("GH-669 Release v0.3.0 Operator Rehearsal Runbook"))
        XCTAssertTrue(tradingMatrix.contains("TVM-RELEASE-V030-OPERATOR-REHEARSAL-RUNBOOK"))
        XCTAssertTrue(tradingMatrix.contains("GH-670"))
        XCTAssertTrue(automationReadiness.contains("Release v0.3.0 operator rehearsal runbook anchor"))

        for forbiddenAuthorization in [
            "授权 production trading",
            "授权 production cutover",
            "读取 production secret",
            "连接 production endpoint",
            "发送真实 submit / cancel / replace",
            "启动下一 milestone"
        ] {
            XCTAssertTrue(
                runbook.contains("不\(forbiddenAuthorization)") || runbook.contains("不\(forbiddenAuthorization.dropFirst(2))"),
                "runbook must explicitly deny \(forbiddenAuthorization)"
            )
        }
    }

    func testGH643ProductionCutoverRuntimeHardeningContractFailsClosedWithoutProductionCutover() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-cutover-runtime-hardening-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        let contract = try ProductionCutoverRuntimeHardeningContract.deterministicFixture()
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.productionCapabilityDefaultsClosed)
        XCTAssertTrue(contract.gateBypassRejected)
        XCTAssertTrue(contract.gatePassCoverageHeld)
        XCTAssertEqual(contract.issueID.rawValue, "GH-643")
        XCTAssertEqual(contract.downstreamIssueID.rawValue, "GH-644")
        XCTAssertEqual(contract.canonicalQueueRange, "GH-643..GH-649")
        XCTAssertEqual(contract.projectName, "MTPRO Production Cutover Runtime Hardening v1")
        XCTAssertEqual(contract.allowedVenue, "Binance")
        XCTAssertEqual(contract.allowedProductTypes, ["spot", "usdsPerpetual"])
        XCTAssertEqual(contract.allowedStrategies, ["EMA", "RSI"])
        XCTAssertEqual(Set(contract.requirements), Set(ProductionCutoverRuntimeHardeningGateRequirement.allCases))
        XCTAssertEqual(
            Set(contract.forbiddenCapabilities),
            Set(ProductionCutoverRuntimeHardeningForbiddenCapability.allCases)
        )

        XCTAssertTrue(contract.operatorApprovalRequired)
        XCTAssertTrue(contract.allGatePassesRequired)
        XCTAssertFalse(contract.productionTradingEnabledByDefault)
        XCTAssertFalse(contract.realBrokerEnabledByDefault)
        XCTAssertFalse(contract.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(contract.productionSecretAutoReadEnabled)
        XCTAssertFalse(contract.commandGatewayBypassAllowed)
        XCTAssertFalse(contract.riskEngineBypassAllowed)
        XCTAssertFalse(contract.executionEngineBypassAllowed)
        XCTAssertFalse(contract.omsBypassAllowed)
        XCTAssertFalse(contract.eventStoreBypassAllowed)
        XCTAssertFalse(contract.realOrderSubmissionEnabled)
        XCTAssertFalse(contract.startsNextMilestone)

        for anchor in ProductionCutoverRuntimeHardeningContract.requiredValidationAnchors {
            XCTAssertTrue(contract.validationAnchors.contains(anchor), "\(anchor) must stay in Swift contract")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        for gateAnchor in [
            "PCHR-01-COMMANDGATEWAY-REQUIRED",
            "PCHR-01-RISKENGINE-REQUIRED",
            "PCHR-01-EXECUTIONENGINE-REQUIRED",
            "PCHR-01-OMS-REQUIRED",
            "PCHR-01-EVENT-STORE-REQUIRED"
        ] {
            XCTAssertTrue(contractDoc.contains(gateAnchor), "\(gateAnchor) must stay in contract doc")
            XCTAssertTrue(
                contract.gatePassRequirements.map(\.requiredAnchor).contains(gateAnchor),
                "\(gateAnchor) must stay in gate pass requirements"
            )
        }

        XCTAssertTrue(automationReadiness.contains("Production cutover runtime hardening contract anchor"))
        XCTAssertTrue(readinessScript.contains("ProductionCutoverRuntimeHardeningContract.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH643ProductionCutoverRuntimeHardeningContractFailsClosedWithoutProductionCutover"
            )
        )
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ProductionCutoverRuntimeHardeningContract.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ProductionCutoverRuntimeHardeningContract(
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionTradingEnabledByDefault")
            )
        }
        XCTAssertThrowsError(
            try ProductionCutoverRuntimeHardeningContract(
                productionSecretAutoReadEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionSecretAutoReadEnabled")
            )
        }
        XCTAssertThrowsError(
            try ProductionCutoverRuntimeHardeningContract(
                productionEndpointAutoConnectEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionEndpointAutoConnectEnabled")
            )
        }
        XCTAssertThrowsError(
            try ProductionCutoverRuntimeHardeningContract(
                realOrderSubmissionEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("realOrderSubmissionEnabled"))
        }
        XCTAssertThrowsError(
            try ProductionCutoverRuntimeHardeningContract(
                commandGatewayBypassAllowed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("commandGatewayBypassAllowed"))
        }
        XCTAssertThrowsError(
            try ProductionCutoverRuntimeHardeningContract(
                operatorApprovalRequired: false
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "operatorApprovalRequired",
                    expected: "true",
                    actual: "false"
                )
            )
        }
        XCTAssertThrowsError(
            try ProductionCutoverRuntimeHardeningGatePassRequirement(
                gateName: "unsafe gate",
                requiredAnchor: "PCHR-01-UNSAFE-GATE-BYPASS",
                bypassAllowed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("bypassAllowed"))
        }
    }

    func testGH644CredentialReferenceEnvironmentIsolationFailsClosedWithoutSecretRead() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-credential-reference-environment-isolation-contract.md"
            ),
            encoding: .utf8
        )
        let upstreamContractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-cutover-runtime-hardening-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        let upstream = try ProductionCutoverRuntimeHardeningContract.deterministicFixture()
        let contract = try ProductionCredentialReferenceEnvironmentIsolation.deterministicFixture()
        XCTAssertTrue(upstream.contractHeld)
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.environmentCoverageHeld)
        XCTAssertTrue(contract.secretAndEndpointDefaultsClosed)
        XCTAssertTrue(contract.commandPathBypassRejected)
        XCTAssertEqual(contract.issueID.rawValue, "GH-644")
        XCTAssertEqual(contract.upstreamIssueID.rawValue, "GH-643")
        XCTAssertEqual(contract.downstreamIssueID.rawValue, "GH-645")
        XCTAssertEqual(contract.canonicalQueueRange, "GH-643..GH-649")
        XCTAssertEqual(Set(contract.requirements), Set(ProductionCredentialReferenceRequirement.allCases))
        XCTAssertEqual(
            Set(contract.forbiddenCapabilities),
            Set(ProductionCredentialReferenceForbiddenCapability.allCases)
        )
        XCTAssertEqual(
            Set(contract.profileReferences.map(\.environment)),
            Set(ProductionCredentialEnvironmentKind.allCases)
        )

        XCTAssertTrue(contract.upstreamRuntimeHardeningContractHeld)
        XCTAssertTrue(contract.credentialIdentityOnlyRequired)
        XCTAssertTrue(contract.explicitEnvironmentSelectionRequired)
        XCTAssertTrue(contract.missingAuthorizationFailsClosed)
        XCTAssertTrue(contract.noProductionFallbackRequired)
        XCTAssertFalse(contract.readsProductionSecretValue)
        XCTAssertFalse(contract.probesEnvironmentSecret)
        XCTAssertFalse(contract.storesSecretValue)
        XCTAssertFalse(contract.defaultProductionEnvironmentSelected)
        XCTAssertFalse(contract.ambiguousEnvironmentFallsBackToProduction)
        XCTAssertFalse(contract.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(contract.realBrokerConnectionEnabled)
        XCTAssertFalse(contract.realOrderSubmissionEnabled)
        XCTAssertFalse(contract.commandRiskExecutionOMSBypassAllowed)
        XCTAssertFalse(contract.startsNextMilestone)

        let profileStates = Dictionary(uniqueKeysWithValues: contract.profileReferences.map { ($0.environment, $0) })
        XCTAssertEqual(profileStates[.dryRun]?.authorizationState, .localFixtureAuthorized)
        XCTAssertEqual(profileStates[.testnet]?.authorizationState, .testnetReferenceAuthorized)
        XCTAssertEqual(profileStates[.productionBlocked]?.authorizationState, .productionMissingFailClosed)
        XCTAssertEqual(profileStates[.futureProduction]?.authorizationState, .futureProductionManualGateRequired)
        XCTAssertTrue(contract.profileReferences.allSatisfy(\.referenceBoundaryHeld))

        for anchor in ProductionCredentialReferenceEnvironmentIsolation.requiredValidationAnchors {
            XCTAssertTrue(contract.validationAnchors.contains(anchor), "\(anchor) must stay in Swift contract")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in credential contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(upstreamContractDoc.contains("PCHR-01-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT"))
        XCTAssertTrue(automationReadiness.contains("Production credential reference / environment isolation anchor"))
        XCTAssertTrue(readinessScript.contains("ProductionCredentialReferenceEnvironmentIsolation.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH644CredentialReferenceEnvironmentIsolationFailsClosedWithoutSecretRead"
            )
        )
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ProductionCredentialReferenceEnvironmentIsolation.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ProductionCredentialReferenceEnvironmentIsolation(
                readsProductionSecretValue: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsProductionSecretValue"))
        }
        XCTAssertThrowsError(
            try ProductionCredentialReferenceEnvironmentIsolation(
                probesEnvironmentSecret: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("probesEnvironmentSecret"))
        }
        XCTAssertThrowsError(
            try ProductionCredentialReferenceEnvironmentIsolation(
                ambiguousEnvironmentFallsBackToProduction: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("ambiguousEnvironmentFallsBackToProduction")
            )
        }
        XCTAssertThrowsError(
            try ProductionCredentialReferenceEnvironmentIsolation(
                productionEndpointAutoConnectEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionEndpointAutoConnectEnabled")
            )
        }
        XCTAssertThrowsError(
            try ProductionCredentialReferenceEnvironmentIsolation(
                upstreamRuntimeHardeningContractHeld: false
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamRuntimeHardeningContractHeld",
                    expected: "true",
                    actual: "false"
                )
            )
        }
        XCTAssertThrowsError(
            try ProductionCredentialProfileReference(
                referenceID: Identifier.constant("unsafe-gh-644-secret-read"),
                environment: .testnet,
                profileReference: "unsafe-testnet-profile-reference",
                authorizationState: .testnetReferenceAuthorized,
                authorizationAnchor: "PCHR-02-UNSAFE-SECRET-READ",
                readsSecretValue: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsSecretValue"))
        }
        XCTAssertThrowsError(
            try ProductionCredentialProfileReference(
                referenceID: Identifier.constant("unsafe-gh-644-production-state-mismatch"),
                environment: .productionBlocked,
                profileReference: "unsafe-production-profile-reference",
                authorizationState: .testnetReferenceAuthorized,
                authorizationAnchor: "PCHR-02-UNSAFE-PRODUCTION-STATE"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "referenceBoundaryHeld",
                    expected: "credential reference environment state matches fail-closed contract",
                    actual: "production blocked:testnet reference authorized"
                )
            )
        }
    }

    func testGH645ProductionEndpointConnectionGateRequiresApprovalAllowlistAndAudit() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-endpoint-connection-gate-contract.md"
            ),
            encoding: .utf8
        )
        let upstreamContractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-credential-reference-environment-isolation-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        let upstream = try ProductionCredentialReferenceEnvironmentIsolation.deterministicFixture()
        let contract = try ProductionEndpointConnectionGate.deterministicFixture()
        XCTAssertTrue(upstream.contractHeld)
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.allowlistCoverageHeld)
        XCTAssertTrue(contract.auditFailClosedCoverageHeld)
        XCTAssertTrue(contract.endpointDefaultsClosed)
        XCTAssertTrue(contract.bypassRejected)
        XCTAssertEqual(contract.issueID.rawValue, "GH-645")
        XCTAssertEqual(contract.upstreamIssueID.rawValue, "GH-644")
        XCTAssertEqual(contract.downstreamIssueID.rawValue, "GH-646")
        XCTAssertEqual(contract.canonicalQueueRange, "GH-643..GH-649")
        XCTAssertEqual(contract.allowedEndpointReferences, ProductionEndpointConnectionGate.requiredAllowedEndpointReferences)
        XCTAssertEqual(contract.allowedVenue, "Binance")
        XCTAssertEqual(contract.allowedProductTypes, ["spot", "usdsPerpetual"])
        XCTAssertEqual(Set(contract.requirements), Set(ProductionEndpointConnectionRequirement.allCases))
        XCTAssertEqual(
            Set(contract.forbiddenCapabilities),
            Set(ProductionEndpointConnectionForbiddenCapability.allCases)
        )

        XCTAssertTrue(contract.upstreamCredentialIsolationContractHeld)
        XCTAssertTrue(contract.operatorApprovalRequired)
        XCTAssertTrue(contract.endpointVenueProductAllowlistRequired)
        XCTAssertTrue(contract.connectionAttemptAuditRequired)
        XCTAssertTrue(contract.connectionFailureFailsClosed)
        XCTAssertTrue(contract.noEndpointFallbackRequired)
        XCTAssertTrue(contract.noSilentContinuationAfterFailureRequired)
        XCTAssertFalse(contract.productionEndpointConnectsByDefault)
        XCTAssertFalse(contract.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(contract.productionSecretAutoReadEnabled)
        XCTAssertFalse(contract.realBrokerConnectionEnabled)
        XCTAssertFalse(contract.realOrderSubmissionEnabled)
        XCTAssertFalse(contract.commandRiskExecutionOMSBypassAllowed)
        XCTAssertFalse(contract.eventStoreBypassAllowed)
        XCTAssertFalse(contract.startsNextMilestone)

        let outcomes = Set(contract.attemptEvidence.map(\.outcome))
        XCTAssertEqual(outcomes, Set(ProductionEndpointConnectionAttemptOutcome.allCases))
        XCTAssertTrue(contract.attemptEvidence.allSatisfy(\.auditBoundaryHeld))
        XCTAssertTrue(contract.attemptEvidence.allSatisfy(\.connectionAttemptRecorded))
        XCTAssertTrue(contract.attemptEvidence.allSatisfy(\.failureFailsClosed))
        XCTAssertTrue(contract.attemptEvidence.allSatisfy { $0.allowsFallback == false })
        XCTAssertTrue(contract.attemptEvidence.allSatisfy { $0.silentContinuationAllowed == false })
        XCTAssertTrue(contract.attemptEvidence.allSatisfy { $0.connectsProductionEndpoint == false })

        for anchor in ProductionEndpointConnectionGate.requiredValidationAnchors {
            XCTAssertTrue(contract.validationAnchors.contains(anchor), "\(anchor) must stay in Swift contract")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in endpoint gate contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(upstreamContractDoc.contains("PCHR-02-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION-RUNTIME"))
        XCTAssertTrue(automationReadiness.contains("Production endpoint connection gate anchor"))
        XCTAssertTrue(readinessScript.contains("ProductionEndpointConnectionGate.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH645ProductionEndpointConnectionGateRequiresApprovalAllowlistAndAudit"
            )
        )
        XCTAssertTrue(executionClientTarget.contains("\"FutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ProductionEndpointConnectionGate.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ProductionEndpointConnectionGate(
                productionEndpointAutoConnectEnabled: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionEndpointAutoConnectEnabled")
            )
        }
        XCTAssertThrowsError(
            try ProductionEndpointConnectionGate(
                productionEndpointConnectsByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("productionEndpointConnectsByDefault")
            )
        }
        XCTAssertThrowsError(
            try ProductionEndpointConnectionGate(
                upstreamCredentialIsolationContractHeld: false
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamCredentialIsolationContractHeld",
                    expected: "true",
                    actual: "false"
                )
            )
        }
        XCTAssertThrowsError(
            try ProductionEndpointConnectionAttemptAuditEvidence(
                attemptID: Identifier.constant("unsafe-gh-645-fallback"),
                endpointReference: "binance-production-rest-endpoint-reference",
                venue: "Binance",
                productType: "spot",
                operatorApprovalAnchor: "PCHR-03-OPERATOR-APPROVAL-REQUIRED",
                auditAnchor: "PCHR-03-UNSAFE-FALLBACK",
                outcome: .blockedMissingOperatorApproval,
                endpointAllowlisted: true,
                venueAllowlisted: true,
                productTypeAllowlisted: true,
                operatorApprovalPresent: false,
                allowsFallback: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("allowsFallback"))
        }
        XCTAssertThrowsError(
            try ProductionEndpointConnectionAttemptAuditEvidence(
                attemptID: Identifier.constant("unsafe-gh-645-outcome-mismatch"),
                endpointReference: "binance-production-rest-endpoint-reference",
                venue: "Binance",
                productType: "spot",
                operatorApprovalAnchor: "PCHR-03-OPERATOR-APPROVAL-REQUIRED",
                auditAnchor: "PCHR-03-UNSAFE-OUTCOME-MISMATCH",
                outcome: .blockedEndpointNotAllowlisted,
                endpointAllowlisted: true,
                venueAllowlisted: true,
                productTypeAllowlisted: true,
                operatorApprovalPresent: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "auditBoundaryHeld",
                    expected: "endpoint attempt outcome matches fail-closed connection gate",
                    actual: "blocked: endpoint not allowlisted"
                )
            )
        }
    }

    func testGH646ProductionCommandDispatchGateRequiresCommandRiskExecutionOMSGates() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-command-dispatch-gate-contract.md"
            ),
            encoding: .utf8
        )
        let upstreamContractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-endpoint-connection-gate-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        let upstream = try ProductionEndpointConnectionGate.deterministicFixture()
        let contract = try ProductionCommandDispatchGate.deterministicFixture()
        XCTAssertTrue(upstream.contractHeld)
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.dispatchGateCoverageHeld)
        XCTAssertTrue(contract.surfaceDirectAccessBlocked)
        XCTAssertTrue(contract.productionDefaultsClosed)
        XCTAssertEqual(contract.issueID.rawValue, "GH-646")
        XCTAssertEqual(contract.upstreamIssueID.rawValue, "GH-645")
        XCTAssertEqual(contract.downstreamIssueID.rawValue, "GH-647")
        XCTAssertEqual(contract.canonicalQueueRange, "GH-643..GH-649")
        XCTAssertEqual(contract.allowedCommandSource, .commandGateway)
        XCTAssertEqual(Set(contract.requirements), Set(ProductionCommandDispatchGateRequirement.allCases))
        XCTAssertEqual(
            Set(contract.forbiddenCapabilities),
            Set(ProductionCommandDispatchForbiddenCapability.allCases)
        )

        XCTAssertTrue(contract.upstreamEndpointConnectionGateHeld)
        XCTAssertTrue(contract.dashboardCLIDirectExecutionClientBlocked)
        XCTAssertTrue(contract.commandGatewayOperatorApprovalRequired)
        XCTAssertTrue(contract.riskEngineKillSwitchRequired)
        XCTAssertTrue(contract.riskEngineNoTradeStateRequired)
        XCTAssertTrue(contract.riskEngineLimitChecksRequired)
        XCTAssertTrue(contract.executionEngineRiskApprovedOnly)
        XCTAssertTrue(contract.omsLifecycleRecordingRequiredBeforeHandoff)
        XCTAssertTrue(contract.eventStoreAuditRequired)
        XCTAssertTrue(contract.failedGateBlocksCommand)
        XCTAssertFalse(contract.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(contract.productionSecretAutoReadEnabled)
        XCTAssertFalse(contract.realBrokerConnectionEnabled)
        XCTAssertFalse(contract.realOrderSubmissionEnabled)
        XCTAssertFalse(contract.startsNextMilestone)

        let outcomes = Set(contract.attemptEvidence.map(\.outcome))
        XCTAssertEqual(outcomes, Set(ProductionCommandDispatchOutcome.allCases))
        XCTAssertTrue(contract.attemptEvidence.allSatisfy(\.evidenceBoundaryHeld))
        XCTAssertTrue(contract.attemptEvidence.allSatisfy(\.eventStoreAuditRecorded))
        XCTAssertTrue(contract.attemptEvidence.allSatisfy { $0.callsExecutionClient == false })
        XCTAssertTrue(contract.attemptEvidence.allSatisfy { $0.touchesBrokerGateway == false })
        XCTAssertTrue(contract.attemptEvidence.allSatisfy { $0.submitsRealOrder == false })
        XCTAssertTrue(contract.attemptEvidence.allSatisfy { $0.cancelsRealOrder == false })
        XCTAssertTrue(contract.attemptEvidence.allSatisfy { $0.replacesRealOrder == false })
        XCTAssertTrue(
            contract.attemptEvidence.contains {
                $0.outcome == .recordedGatedHandoff
                    && $0.riskEngineApproved
                    && $0.executionEngineAccepted
                    && $0.omsLifecycleRecorded
                    && $0.commandBlocked == false
            }
        )

        for anchor in ProductionCommandDispatchGate.requiredValidationAnchors {
            XCTAssertTrue(contract.validationAnchors.contains(anchor), "\(anchor) must stay in Swift contract")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in dispatch gate contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(upstreamContractDoc.contains("PCHR-03-PRODUCTION-ENDPOINT-CONNECTION-GATE"))
        XCTAssertTrue(automationReadiness.contains("Production command dispatch gate anchor"))
        XCTAssertTrue(readinessScript.contains("ProductionCommandDispatchGate.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH646ProductionCommandDispatchGateRequiresCommandRiskExecutionOMSGates"
            )
        )
        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/ProductionCommandDispatchGate.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ProductionCommandDispatchGate(
                upstreamEndpointConnectionGateHeld: false
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamEndpointConnectionGateHeld",
                    expected: "true",
                    actual: "false"
                )
            )
        }
        XCTAssertThrowsError(
            try ProductionCommandDispatchGate(
                realOrderSubmissionEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("realOrderSubmissionEnabled"))
        }
        XCTAssertThrowsError(
            try ProductionCommandDispatchAttemptEvidence(
                attemptID: Identifier.constant("unsafe-gh-646-executionclient-call"),
                commandKind: .submit,
                source: .commandGateway,
                outcome: .recordedGatedHandoff,
                operatorApprovalPassed: true,
                killSwitchPassed: true,
                noTradeStatePassed: true,
                limitChecksPassed: true,
                riskEngineApproved: true,
                executionEngineAccepted: true,
                omsLifecycleRecorded: true,
                commandBlocked: false,
                callsExecutionClient: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("callsExecutionClient"))
        }
        XCTAssertThrowsError(
            try ProductionCommandDispatchAttemptEvidence(
                attemptID: Identifier.constant("unsafe-gh-646-outcome-mismatch"),
                commandKind: .cancel,
                source: .commandGateway,
                outcome: .recordedGatedHandoff,
                operatorApprovalPassed: true,
                killSwitchPassed: true,
                noTradeStatePassed: true,
                limitChecksPassed: true,
                riskEngineApproved: false,
                executionEngineAccepted: false,
                omsLifecycleRecorded: false,
                commandBlocked: false
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "evidenceBoundaryHeld",
                    expected: "command dispatch attempt matches GH-646 fail-closed gate chain",
                    actual: "recorded: gated handoff evidence"
                )
            )
        }
    }

    func testGH647ProductionAuditTrailRequiresAppendOnlyReplayAndRepairEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-audit-trail-gate-contract.md"
            ),
            encoding: .utf8
        )
        let upstreamContractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-command-dispatch-gate-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        let upstream = try ProductionCommandDispatchGate.deterministicFixture()
        let contract = try ProductionAuditTrailGate.deterministicFixture()
        XCTAssertTrue(upstream.contractHeld)
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.auditTrailCoverageHeld)
        XCTAssertTrue(contract.replayRepairCoverageHeld)
        XCTAssertTrue(contract.productionDefaultsClosed)
        XCTAssertEqual(contract.issueID.rawValue, "GH-647")
        XCTAssertEqual(contract.upstreamIssueID.rawValue, "GH-646")
        XCTAssertEqual(contract.downstreamIssueID.rawValue, "GH-648")
        XCTAssertEqual(contract.canonicalQueueRange, "GH-643..GH-649")
        XCTAssertEqual(Set(contract.requirements), Set(ProductionAuditTrailRequirement.allCases))
        XCTAssertEqual(Set(contract.forbiddenCapabilities), Set(ProductionAuditTrailForbiddenCapability.allCases))

        XCTAssertTrue(contract.upstreamCommandDispatchGateHeld)
        XCTAssertTrue(contract.appendOnlyEvidenceRequired)
        XCTAssertTrue(contract.eventIdempotencyRequired)
        XCTAssertTrue(contract.replayRestoresKeyCommandState)
        XCTAssertTrue(contract.rollbackRepairEvidenceRequired)
        XCTAssertTrue(contract.missingAuditTrailBlocksExecutionHandoff)
        XCTAssertFalse(contract.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(contract.productionSecretAutoReadEnabled)
        XCTAssertFalse(contract.realBrokerConnectionEnabled)
        XCTAssertFalse(contract.realOrderSubmissionEnabled)
        XCTAssertFalse(contract.startsNextMilestone)

        XCTAssertEqual(Set(contract.events.map(\.kind)), Set(ProductionAuditTrailEventKind.allCases))
        XCTAssertEqual(contract.events.map(\.sequence), [1, 2, 3, 4])
        XCTAssertTrue(contract.events.allSatisfy(\.eventBoundaryHeld))
        XCTAssertTrue(contract.events.allSatisfy(\.appendOnly))
        XCTAssertTrue(contract.events.allSatisfy(\.idempotent))
        XCTAssertTrue(contract.events.allSatisfy { $0.mutableWriteAllowed == false })
        XCTAssertTrue(contract.events.allSatisfy { $0.containsSecretValue == false })
        XCTAssertTrue(contract.events.allSatisfy { $0.containsBrokerPayload == false })
        XCTAssertTrue(contract.events.allSatisfy { $0.writesProductionOrderState == false })
        XCTAssertTrue(contract.replayRepairEvidence.replayRepairBoundaryHeld)
        XCTAssertTrue(contract.replayRepairEvidence.replayRestoresKeyState)
        XCTAssertTrue(contract.replayRepairEvidence.rollbackRepairEvidenceProduced)
        XCTAssertTrue(contract.replayRepairEvidence.missingAuditTrailBlocksExecutionHandoff)
        XCTAssertFalse(contract.replayRepairEvidence.automaticRepairEnabled)
        XCTAssertFalse(contract.replayRepairEvidence.executionHandoffAllowedWithoutAuditTrail)
        XCTAssertFalse(contract.replayRepairEvidence.eventStoreBypassAllowed)

        for anchor in ProductionAuditTrailGate.requiredValidationAnchors {
            XCTAssertTrue(contract.validationAnchors.contains(anchor), "\(anchor) must stay in Swift contract")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in audit trail contract doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(upstreamContractDoc.contains("PCHR-04-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE"))
        XCTAssertTrue(automationReadiness.contains("Production audit trail gate anchor"))
        XCTAssertTrue(readinessScript.contains("ProductionAuditTrailGate.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH647ProductionAuditTrailRequiresAppendOnlyReplayAndRepairEvidence"
            )
        )
        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/ProductionAuditTrailGate.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ProductionAuditTrailGate(
                upstreamCommandDispatchGateHeld: false
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamCommandDispatchGateHeld",
                    expected: "true",
                    actual: "false"
                )
            )
        }
        XCTAssertThrowsError(
            try ProductionAuditTrailGate(
                realOrderSubmissionEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("realOrderSubmissionEnabled"))
        }
        XCTAssertThrowsError(
            try ProductionAuditTrailEventEvidence(
                eventID: Identifier.constant("unsafe-gh-647-mutable-event"),
                commandID: Identifier.constant("gh-647-command"),
                kind: .command,
                sequence: 1,
                idempotencyKey: "unsafe-gh-647-mutable",
                sourceAnchor: "PCHR-05-UNSAFE-MUTABLE",
                mutableWriteAllowed: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("mutableWriteAllowed"))
        }
        XCTAssertThrowsError(
            try ProductionAuditTrailReplayRepairEvidence(
                replayedEventIDs: ProductionAuditTrailGate.requiredEvents.map(\.eventID),
                executionHandoffAllowedWithoutAuditTrail: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("executionHandoffAllowedWithoutAuditTrail")
            )
        }
    }

    func testGH648BrokerShadowDryRunProofKeepsProductionOrdersBlocked() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        let contractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-broker-shadow-dry-run-proof-contract.md"
            ),
            encoding: .utf8
        )
        let upstreamContractDoc = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-audit-trail-gate-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )

        let upstream = try ProductionAuditTrailGate.deterministicFixture()
        let contract = try ProductionBrokerShadowDryRunProof.deterministicFixture()
        XCTAssertTrue(upstream.contractHeld)
        XCTAssertTrue(contract.contractHeld)
        XCTAssertTrue(contract.payloadCoverageHeld)
        XCTAssertTrue(contract.productionDefaultsClosed)
        XCTAssertEqual(contract.issueID.rawValue, "GH-648")
        XCTAssertEqual(contract.upstreamIssueID.rawValue, "GH-647")
        XCTAssertEqual(contract.downstreamIssueID.rawValue, "GH-649")
        XCTAssertEqual(contract.canonicalQueueRange, "GH-643..GH-649")
        XCTAssertEqual(Set(contract.requirements), Set(ProductionBrokerShadowDryRunRequirement.allCases))
        XCTAssertEqual(Set(contract.forbiddenCapabilities), Set(ProductionBrokerShadowDryRunForbiddenCapability.allCases))

        XCTAssertTrue(contract.upstreamAuditTrailGateHeld)
        XCTAssertTrue(contract.productionLikeRequestMappingRequired)
        XCTAssertTrue(contract.dryRunAndShadowModeMarked)
        XCTAssertTrue(contract.submitCancelReplacePayloadAuditRequired)
        XCTAssertTrue(contract.productionOrderPathBlockedByDefault)
        XCTAssertTrue(contract.rawBrokerPayloadNotExposedToDashboard)
        XCTAssertFalse(contract.productionEndpointAutoConnectEnabled)
        XCTAssertFalse(contract.productionSecretAutoReadEnabled)
        XCTAssertFalse(contract.realBrokerConnectionEnabled)
        XCTAssertFalse(contract.realOrderSubmissionEnabled)
        XCTAssertFalse(contract.startsNextMilestone)

        XCTAssertEqual(Set(contract.payloadEvidence.map(\.commandKind)), Set(L4LiveRiskPreTradeCommandKind.allCases))
        XCTAssertEqual(Set(contract.payloadEvidence.map(\.mode)), Set(ProductionBrokerShadowDryRunProofMode.allCases))
        XCTAssertTrue(contract.payloadEvidence.allSatisfy(\.payloadBoundaryHeld))
        XCTAssertTrue(contract.payloadEvidence.allSatisfy(\.productionLikeRequestMappingPresent))
        XCTAssertTrue(contract.payloadEvidence.allSatisfy(\.modeExplicitlyMarked))
        XCTAssertTrue(contract.payloadEvidence.allSatisfy(\.payloadConstructionAuditable))
        XCTAssertTrue(contract.payloadEvidence.allSatisfy(\.upstreamAuditTrailLinked))
        XCTAssertTrue(contract.payloadEvidence.allSatisfy(\.productionOrderPathBlocked))
        XCTAssertTrue(contract.payloadEvidence.allSatisfy { $0.sendsRealOrder == false })
        XCTAssertTrue(contract.payloadEvidence.allSatisfy { $0.connectsBroker == false })
        XCTAssertTrue(contract.payloadEvidence.allSatisfy { $0.readsSecretValue == false })
        XCTAssertTrue(contract.payloadEvidence.allSatisfy { $0.exposesRawBrokerPayloadToDashboard == false })

        for anchor in ProductionBrokerShadowDryRunProof.requiredValidationAnchors {
            XCTAssertTrue(contract.validationAnchors.contains(anchor), "\(anchor) must stay in Swift contract")
            XCTAssertTrue(contractDoc.contains(anchor), "\(anchor) must stay in broker shadow / dry-run proof doc")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must stay in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must stay in trading-validation-matrix.md")
        }
        XCTAssertTrue(upstreamContractDoc.contains("PCHR-05-OMS-EVENT-STORE-PRODUCTION-AUDIT-TRAIL"))
        XCTAssertTrue(automationReadiness.contains("Production broker shadow / dry-run proof anchor"))
        XCTAssertTrue(readinessScript.contains("ProductionBrokerShadowDryRunProof.swift"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH648BrokerShadowDryRunProofKeepsProductionOrdersBlocked"
            )
        )
        XCTAssertTrue(executionEngineTarget.contains("\"OMSFutureGate\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/ProductionBrokerShadowDryRunProof.swift"
                ).path
            )
        )

        XCTAssertThrowsError(
            try ProductionBrokerShadowDryRunProof(
                upstreamAuditTrailGateHeld: false
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "upstreamAuditTrailGateHeld",
                    expected: "true",
                    actual: "false"
                )
            )
        }
        XCTAssertThrowsError(
            try ProductionBrokerShadowDryRunProof(
                realOrderSubmissionEnabled: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("realOrderSubmissionEnabled"))
        }
        XCTAssertThrowsError(
            try ProductionBrokerShadowDryRunPayloadEvidence(
                payloadID: Identifier.constant("unsafe-gh-648-real-order"),
                commandKind: .submit,
                mode: .dryRun,
                productType: "spot",
                sendsRealOrder: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("sendsRealOrder"))
        }
        XCTAssertThrowsError(
            try ProductionBrokerShadowDryRunPayloadEvidence(
                payloadID: Identifier.constant("unsafe-gh-648-dashboard-payload"),
                commandKind: .replace,
                mode: .shadow,
                productType: "usdsPerpetual",
                exposesRawBrokerPayloadToDashboard: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("exposesRawBrokerPayloadToDashboard")
            )
        }
    }

    func testGH649ProductionHardeningReadinessCloseoutDocumentsCompleteEvidenceWithoutCutover() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let contract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/production-cutover-runtime-hardening-contract.md"
            ),
            encoding: .utf8
        )
        let validationPlan = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/validation-plan.md"),
            encoding: .utf8
        )
        let tradingMatrix = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/trading-validation-matrix.md"),
            encoding: .utf8
        )
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let readinessScript = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.sh"),
            encoding: .utf8
        )
        let auditInput = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/audit/inputs/mtpro-production-cutover-runtime-hardening-v1-stage-audit-input.md"
            ),
            encoding: .utf8
        )

        let closeoutAnchors = [
            "PCHR-07-PRODUCTION-HARDENING-READINESS-CLOSEOUT",
            "PCHR-07-ISSUE-PR-EVIDENCE-CHAIN",
            "PCHR-07-PRODUCTION-DEFAULTS-REMAIN-CLOSED",
            "PCHR-07-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-GATES-COMPLETE",
            "PCHR-07-AUTOMATION-READINESS-CLOSEOUT",
            "PCHR-07-NO-PRODUCTION-CUTOVER-AUTHORIZATION",
            "PCHR-07-STAGE-CODE-AUDIT-HANDOFF",
            "TVM-PCHR-PRODUCTION-HARDENING-READINESS-CLOSEOUT"
        ]
        for anchor in closeoutAnchors {
            XCTAssertTrue(contract.contains(anchor), "\(anchor) must remain in PCHR contract")
            XCTAssertTrue(validationPlan.contains(anchor), "\(anchor) must remain in validation-plan.md")
            XCTAssertTrue(tradingMatrix.contains(anchor), "\(anchor) must remain in trading-validation-matrix.md")
            XCTAssertTrue(auditInput.contains(anchor), "\(anchor) must remain in stage audit input")
            XCTAssertTrue(readinessScript.contains(anchor), "\(anchor) must be mechanically checked")
        }
        XCTAssertTrue(automationReadiness.contains("Production hardening readiness closeout anchor"))
        XCTAssertTrue(
            readinessScript.contains(
                "testGH649ProductionHardeningReadinessCloseoutDocumentsCompleteEvidenceWithoutCutover"
            )
        )

        for issue in 643...648 {
            XCTAssertTrue(auditInput.contains("[GH-\(issue)]"), "GH-\(issue) must be linked in evidence chain")
        }
        for pr in 650...655 {
            XCTAssertTrue(auditInput.contains("[PR #\(pr)]"), "PR #\(pr) must be linked in evidence chain")
        }
        for mergeCommit in [
            "485a8a93a7de13d98e174345b9eddc53e2eb6c84",
            "d29d557bdda1abbe71338cfe8c4204cb1c63feaa",
            "5a64abfea38b482d8e5da87e83fbee785dd6ef8b",
            "9e250ec3b46feb7074de55f3651e3e5fa3dc817d",
            "eee1f3e18ee545507f4b4d4be1d6fcb19b499e05",
            "d73ab662a2193bdf99944a4cd733519bf1978986"
        ] {
            XCTAssertTrue(auditInput.contains(mergeCommit), "\(mergeCommit) must remain in evidence chain")
            XCTAssertTrue(contract.contains(mergeCommit), "\(mergeCommit) must remain in PCHR contract")
        }

        for closedDefault in [
            "productionTradingEnabledByDefault == false",
            "productionSecretReadEnabledByDefault == false",
            "productionEndpointConnectionEnabledByDefault == false",
            "productionBrokerConnectionEnabledByDefault == false",
            "productionOrderSubmitEnabledByDefault == false",
            "productionCutoverAuthorized == false"
        ] {
            XCTAssertTrue(auditInput.contains(closedDefault), "\(closedDefault) must remain in audit input")
            XCTAssertTrue(contract.contains(closedDefault), "\(closedDefault) must remain in PCHR contract")
        }

        for forbidden in [
            "production trading",
            "production secret read",
            "production endpoint connection",
            "real submit / cancel / replace",
            "production OMS",
            "production Event Store runtime",
            "production cutover",
            "next Project / Issue creation"
        ] {
            XCTAssertTrue(auditInput.contains(forbidden), "\(forbidden) must remain forbidden")
        }

        for upstreamAnchor in [
            "PCHR-01-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT",
            "PCHR-02-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION-RUNTIME",
            "PCHR-03-PRODUCTION-ENDPOINT-CONNECTION-GATE",
            "PCHR-04-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE",
            "PCHR-05-OMS-EVENT-STORE-PRODUCTION-AUDIT-TRAIL",
            "PCHR-06-BROKER-SHADOW-DRY-RUN-PRODUCTION-CUTOVER-PROOF"
        ] {
            XCTAssertTrue(readinessScript.contains(upstreamAnchor), "\(upstreamAnchor) must remain in readiness guard")
        }

        XCTAssertTrue(auditInput.contains("formal `v0.2.0` GitHub Release"))
        XCTAssertFalse(auditInput.contains("productionCutoverAuthorized == true"))
        XCTAssertFalse(contract.contains("productionCutoverAuthorized == true"))
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
            case .premiumIndex, .openInterest:
                throw XCTSkip("Unexpected GH-524 Perp-only capability: \(request.contract.capability.rawValue)")
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

    func testGH573BinanceSpotMarketDataActivePathEmitsProductAwareEventsIntoCache() async throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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

        let symbol = try Symbol(rawValue: "BTCUSDT")
        let instrument = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let range = try DateRange(
            start: Date(timeIntervalSince1970: 1_704_067_300),
            end: Date(timeIntervalSince1970: 1_704_067_360)
        )
        let transport = TargetGraphMockBinancePublicMarketDataTransport { request in
            switch request.contract.capability {
            case .klines:
                Data(
                    #"""
                    [[1704067300000,"43000.00","43100.00","42950.00","43050.00","8.000",1704067359999,"344400.00",100,"4.000","172200.00","0"]]
                    """#.utf8
                )
            case .recentTrades:
                Data(
                    #"""
                    [{"id":2,"price":"43020.00","qty":"0.200","time":1704067301000,"isBuyerMaker":false,"isBestMatch":true}]
                    """#.utf8
                )
            case .bestBidAsk:
                Data(
                    #"""
                    {"symbol":"BTCUSDT","bidPrice":"43019.90","bidQty":"1.000","askPrice":"43020.10","askQty":"1.100"}
                    """#.utf8
                )
            case .depthSnapshot:
                Data(
                    #"""
                    {"lastUpdateId":110,"bids":[["43000.00","1.000"]],"asks":[["43001.00","1.000"]]}
                    """#.utf8
                )
            case .depthDelta:
                Data(
                    #"""
                    {"e":"depthUpdate","E":1704067303000,"s":"BTCUSDT","U":111,"u":112,"b":[["43000.50","0.500"]],"a":[["43001.50","0.000"]]}
                    """#.utf8
                )
            case .exchangeInfo:
                Data(#"{"symbols":[]}"#.utf8)
            case .premiumIndex, .openInterest:
                throw XCTSkip("Unexpected GH-573 Perp-only capability: \(request.contract.capability.rawValue)")
            }
        }
        let plan = try BinancePublicMarketDataRuntimePlan(
            sourceID: try FoundationTargetID("gh-573-binance-spot-source"),
            instrument: instrument,
            symbol: symbol,
            timeframe: .oneMinute,
            range: range,
            datasetVersion: "gh-573",
            klineLimit: 1,
            recentTradeLimit: 1,
            depthSnapshotLimit: .oneHundred,
            bestBidAskObservedAt: Date(timeIntervalSince1970: 1_704_067_302),
            depthSnapshotObservedAt: Date(timeIntervalSince1970: 1_704_067_304),
            firstRecordedAt: Date(timeIntervalSince1970: 1_704_067_310)
        )

        let result = try await BinancePublicMarketDataRuntimePath(
            client: BinancePublicMarketDataClient(transport: transport)
        ).run(plan)

        XCTAssertEqual(result.instrument, instrument)
        XCTAssertEqual(result.marketEvents.count, 5)
        XCTAssertEqual(result.productAwareEvents.count, 5)
        XCTAssertTrue(result.productAwareEvents.allSatisfy { $0.instrument == instrument })
        XCTAssertTrue(result.productAwareEvents.allSatisfy { $0.productType == .spot })
        XCTAssertEqual(result.eventEnvelopes.map(\.instrumentID), Array(repeating: instrument, count: 5))
        XCTAssertEqual(result.eventEnvelopes.map(\.productType), Array(repeating: .spot, count: 5))
        XCTAssertTrue(result.eventEnvelopes.allSatisfy { $0.payloadType.contains("dataengine.binance.spot") })
        XCTAssertTrue(result.spotProductAwareEventsBoundaryHeld)
        XCTAssertTrue(result.publicMarketDataRuntimePathBoundaryHeld)
        XCTAssertEqual(result.cacheSnapshot.marketEventCount, 5)
        XCTAssertEqual(result.cacheSnapshot, result.replayedCacheSnapshot)
        XCTAssertEqual(result.replayedEnvelopes, result.eventEnvelopes)

        let seriesKey = MarketDataSeriesKey(symbol: symbol, timeframe: .oneMinute)
        XCTAssertEqual(result.cacheSnapshot.barsBySeries[seriesKey]?.count, 1)
        XCTAssertEqual(result.cacheSnapshot.tradesBySymbol[symbol]?.count, 1)
        XCTAssertNotNil(result.cacheSnapshot.bestBidAskBySymbol[symbol])
        XCTAssertNotNil(result.cacheSnapshot.orderBookSnapshotsBySymbol[symbol])
        XCTAssertEqual(result.cacheSnapshot.orderBookDeltasBySymbol[symbol]?.count, 1)

        XCTAssertThrowsError(
            try BinancePublicMarketDataRuntimePlan(
                sourceID: try FoundationTargetID("gh-573-invalid-perp-source"),
                instrument: InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol),
                symbol: symbol,
                timeframe: .oneMinute,
                range: range,
                datasetVersion: "gh-573",
                klineLimit: 1,
                recentTradeLimit: 1,
                depthSnapshotLimit: .oneHundred,
                bestBidAskObservedAt: Date(timeIntervalSince1970: 1_704_067_302),
                depthSnapshotObservedAt: Date(timeIntervalSince1970: 1_704_067_304),
                firstRecordedAt: Date(timeIntervalSince1970: 1_704_067_310)
            )
        ) { error in
            XCTAssertEqual(
                error as? BinancePublicMarketDataRuntimePathError,
                .invalidSpotInstrument(
                    field: "instrument.productType",
                    expected: ProductType.spot.rawValue,
                    actual: ProductType.usdsPerpetual.rawValue
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-573`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-BINANCE-SPOT-DATAENGINE-CACHE-PATH"))
        XCTAssertTrue(validationPlan.contains("GH-573 Release v0.2.0 Binance Spot DataEngine Cache Path Validation"))
        XCTAssertTrue(domainContext.contains("GH-573 Binance Spot DataEngine Cache Path Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Binance Spot DataEngine Cache path anchor"))
    }

    func testGH574BinanceUSDMPerpetualMarketDataActivePathEmitsProductAwareEventsIntoCache() async throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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

        let symbol = try Symbol(rawValue: "BTCUSDT")
        let contract = try PerpetualContract.binanceBTCUSDTFixture()
        let instrument = contract.instrument
        let range = try DateRange(
            start: Date(timeIntervalSince1970: 1_704_067_400),
            end: Date(timeIntervalSince1970: 1_704_067_460)
        )
        let transport = TargetGraphMockBinancePublicMarketDataTransport { request in
            switch request.contract.path {
            case "/fapi/v1/exchangeInfo":
                Data(
                    #"""
                    {"symbols":[{"symbol":"BTCUSDT","status":"TRADING","contractType":"PERPETUAL","marginAsset":"USDT","quoteAsset":"USDT","pricePrecision":2,"quantityPrecision":3}]}
                    """#.utf8
                )
            case "/fapi/v1/klines":
                Data(
                    #"""
                    [[1704067400000,"43000.00","43200.00","42900.00","43150.00","12.000",1704067459999,"517800.00",120,"6.000","258900.00","0"]]
                    """#.utf8
                )
            case "/fapi/v1/depth":
                Data(
                    #"""
                    {"lastUpdateId":210,"bids":[["43100.00","2.000"]],"asks":[["43101.00","2.500"]]}
                    """#.utf8
                )
            case "/ws/btcusdt@depth":
                Data(
                    #"""
                    {"e":"depthUpdate","E":1704067403000,"s":"BTCUSDT","U":211,"u":212,"b":[["43100.50","1.500"]],"a":[["43101.50","0.000"]]}
                    """#.utf8
                )
            case "/fapi/v1/premiumIndex":
                Data(
                    #"""
                    {"symbol":"BTCUSDT","markPrice":"43120.50","indexPrice":"43118.25","lastFundingRate":"0.00010000","nextFundingTime":1704096000000,"time":1704067405000}
                    """#.utf8
                )
            case "/fapi/v1/openInterest":
                Data(
                    #"""
                    {"symbol":"BTCUSDT","openInterest":"12345.678","time":1704067406000}
                    """#.utf8
                )
            default:
                throw XCTSkip("Unexpected GH-574 request path: \(request.contract.path)")
            }
        }
        let plan = try BinanceUSDMPerpetualMarketDataRuntimePlan(
            sourceID: try FoundationTargetID("gh-574-binance-usdm-perp-source"),
            contract: contract,
            symbol: symbol,
            timeframe: .oneMinute,
            range: range,
            datasetVersion: "gh-574",
            klineLimit: 1,
            depthSnapshotLimit: .oneHundred,
            depthSnapshotObservedAt: Date(timeIntervalSince1970: 1_704_067_404),
            firstRecordedAt: Date(timeIntervalSince1970: 1_704_067_410)
        )

        let result = try await BinancePublicMarketDataRuntimePath(
            client: BinancePublicMarketDataClient(transport: transport)
        ).run(plan)

        XCTAssertEqual(result.instrument, instrument)
        XCTAssertEqual(result.marketEvents.count, 3)
        XCTAssertEqual(result.productAwareEvents.count, 6)
        XCTAssertTrue(result.productAwareEvents.allSatisfy { $0.instrument == instrument })
        XCTAssertTrue(result.productAwareEvents.allSatisfy { $0.productType == .usdsPerpetual })
        XCTAssertEqual(result.eventEnvelopes.map(\.instrumentID), Array(repeating: instrument, count: 6))
        XCTAssertEqual(result.eventEnvelopes.map(\.productType), Array(repeating: .usdsPerpetual, count: 6))
        XCTAssertTrue(result.eventEnvelopes.allSatisfy { $0.payloadType.contains("dataengine.binance.usdsPerpetual") })
        XCTAssertTrue(result.usdmPerpetualProductAwareEventsBoundaryHeld)
        XCTAssertTrue(result.publicMarketDataRuntimePathBoundaryHeld)
        XCTAssertEqual(result.cacheSnapshot.marketEventCount, 3)
        XCTAssertEqual(result.cacheSnapshot, result.replayedCacheSnapshot)
        XCTAssertEqual(result.replayedEnvelopes, result.eventEnvelopes)

        let seriesKey = MarketDataSeriesKey(symbol: symbol, timeframe: .oneMinute)
        XCTAssertEqual(result.cacheSnapshot.barsBySeries[seriesKey]?.count, 1)
        XCTAssertNotNil(result.cacheSnapshot.orderBookSnapshotsBySymbol[symbol])
        XCTAssertEqual(result.cacheSnapshot.orderBookDeltasBySymbol[symbol]?.count, 1)

        let requests = await transport.requests()
        XCTAssertEqual(requests.map(\.contract.path), result.requestedPublicPaths)
        XCTAssertEqual(
            result.requestedPublicPaths,
            [
                "/fapi/v1/exchangeInfo",
                "/fapi/v1/klines",
                "/fapi/v1/depth",
                "/ws/btcusdt@depth",
                "/fapi/v1/premiumIndex",
                "/fapi/v1/openInterest"
            ]
        )
        XCTAssertTrue(requests.allSatisfy { $0.method == "GET" })
        XCTAssertTrue(requests.allSatisfy { $0.headers.isEmpty })
        XCTAssertTrue(result.publicRequestContracts.allSatisfy { $0.productType == .usdsPerpetual })
        assertNoForbiddenBinanceUSDMPerpetualPublicRequestFragments(
            result.publicRequestContracts,
            file: #filePath,
            line: #line
        )

        XCTAssertThrowsError(
            try BinanceUSDMPerpetualMarketDataRuntimePlan(
                sourceID: try FoundationTargetID("gh-574-invalid-symbol-source"),
                contract: contract,
                symbol: try Symbol(rawValue: "ETHUSDT"),
                timeframe: .oneMinute,
                range: range,
                datasetVersion: "gh-574",
                klineLimit: 1,
                depthSnapshotLimit: .oneHundred,
                depthSnapshotObservedAt: Date(timeIntervalSince1970: 1_704_067_404),
                firstRecordedAt: Date(timeIntervalSince1970: 1_704_067_410)
            )
        ) { error in
            XCTAssertEqual(
                error as? BinancePublicMarketDataRuntimePathError,
                .invalidUSDMPerpetualInstrument(
                    field: "instrument.symbol",
                    expected: "ETHUSDT",
                    actual: "BTCUSDT"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-574`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-BINANCE-USDM-PERP-DATAENGINE-CACHE-PATH"))
        XCTAssertTrue(validationPlan.contains("GH-574 Release v0.2.0 Binance USD-M Perpetual DataEngine Cache Path Validation"))
        XCTAssertTrue(domainContext.contains("GH-574 Binance USD-M Perpetual DataEngine Cache Path Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Binance USD-M Perpetual DataEngine Cache path anchor"))
    }

    func testGH575PerpMarkFundingOpenInterestReadModelSupportsStaleEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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

        let contract = try PerpetualContract.binanceBTCUSDTFixture()
        let instrument = contract.instrument
        let observedAt = Date(timeIntervalSince1970: 1_704_067_500)
        let freshEvaluation = observedAt.addingTimeInterval(30)
        let staleEvaluation = observedAt.addingTimeInterval(90)
        let staleAfter: TimeInterval = 60

        var cache = PerpetualMarketDataCache()
        try cache.ingestMarkPrice(
            instrument: instrument,
            markPrice: 43_120.50,
            indexPrice: 43_118.25,
            observedAt: observedAt,
            evaluatedAt: freshEvaluation,
            staleAfter: staleAfter
        )
        try cache.ingestFundingRate(
            instrument: instrument,
            fundingRate: 0.0001,
            nextFundingTime: observedAt.addingTimeInterval(8 * 60 * 60),
            observedAt: observedAt,
            evaluatedAt: freshEvaluation,
            staleAfter: staleAfter
        )
        try cache.ingestOpenInterest(
            instrument: instrument,
            openInterest: 12_345.678,
            observedAt: observedAt,
            evaluatedAt: freshEvaluation,
            staleAfter: staleAfter
        )

        XCTAssertEqual(cache.snapshot.evidenceCount, 3)
        XCTAssertEqual(cache.snapshot.markPricesByInstrument[instrument]?.markPrice.rawValue, 43_120.50)
        XCTAssertEqual(cache.snapshot.markPricesByInstrument[instrument]?.indexPrice.rawValue, 43_118.25)
        XCTAssertEqual(cache.snapshot.fundingRatesByInstrument[instrument]?.fundingRate, 0.0001)
        XCTAssertEqual(cache.snapshot.openInterestsByInstrument[instrument]?.openInterest.rawValue, 12_345.678)
        XCTAssertEqual(cache.snapshot.markPricesByInstrument[instrument]?.freshness.status, .fresh)
        XCTAssertEqual(cache.snapshot.fundingRatesByInstrument[instrument]?.freshness.status, .fresh)

        let fundingReadModel = try XCTUnwrap(cache.snapshot.fundingRatesByInstrument[instrument])
        let riskReadModel = try PerpetualFundingRiskReadModel(fundingReadModel: fundingReadModel)
        XCTAssertTrue(riskReadModel.riskReadModelReady)
        XCTAssertFalse(riskReadModel.staleFundingEvidenceSupported)
        XCTAssertTrue(riskReadModel.boundaryHeld)
        XCTAssertFalse(riskReadModel.touchesExecutionEngine)
        XCTAssertFalse(riskReadModel.touchesExecutionClient)
        XCTAssertFalse(riskReadModel.touchesBrokerGateway)
        XCTAssertFalse(riskReadModel.authorizesLiveTrading)

        let staleMark = try PerpetualMarkPriceReadModel(
            instrument: instrument,
            markPrice: 43_120.50,
            indexPrice: 43_118.25,
            observedAt: observedAt,
            evaluatedAt: staleEvaluation,
            staleAfter: staleAfter
        )
        let staleFunding = try PerpetualFundingRateReadModel(
            instrument: instrument,
            fundingRate: 0.0001,
            nextFundingTime: observedAt.addingTimeInterval(8 * 60 * 60),
            observedAt: observedAt,
            evaluatedAt: staleEvaluation,
            staleAfter: staleAfter
        )
        let staleRiskReadModel = try PerpetualFundingRiskReadModel(fundingReadModel: staleFunding)

        XCTAssertEqual(staleMark.freshness.status, .stale)
        XCTAssertEqual(staleFunding.freshness.status, .stale)
        XCTAssertFalse(staleRiskReadModel.riskReadModelReady)
        XCTAssertTrue(staleRiskReadModel.staleFundingEvidenceSupported)

        XCTAssertThrowsError(
            try PerpetualMarkPriceReadModel(
                instrument: InstrumentIdentity.binance(productType: .spot, symbol: instrument.symbol),
                markPrice: 43_120.50,
                indexPrice: 43_118.25,
                observedAt: observedAt,
                evaluatedAt: freshEvaluation,
                staleAfter: staleAfter
            )
        ) { error in
            XCTAssertEqual(
                error as? PerpetualMarketDataReadModelError,
                .invalidInstrument(InstrumentIdentity.binance(productType: .spot, symbol: instrument.symbol))
            )
        }

        XCTAssertThrowsError(
            try PerpetualFundingRiskReadModel(
                fundingReadModel: fundingReadModel,
                authorizesLiveTrading: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineForbiddenCapability("authorizesLiveTrading")
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-575`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-PERP-MARK-FUNDING-OI-READ-MODEL"))
        XCTAssertTrue(validationPlan.contains("GH-575 Release v0.2.0 Perp Mark Funding Open Interest Read Model Validation"))
        XCTAssertTrue(domainContext.contains("GH-575 Perp Mark Funding Open Interest Read Model Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Perp mark funding open interest read model anchor"))
    }

    func testGH576ProductAwareCacheSeparatesSpotPerpStateAndRebuildsFromReplay() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let interval = try DateRange(
            start: Date(timeIntervalSince1970: 1_704_067_600),
            end: Date(timeIntervalSince1970: 1_704_067_660)
        )
        let emittedAt = Date(timeIntervalSince1970: 1_704_067_610)
        let strategyID = Identifier.constant("gh-576-shared-ema-strategy")

        let spotBar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 43_000,
            high: 43_100,
            low: 42_900,
            close: 43_050,
            volume: 10
        )
        let perpBar = try MarketBar(
            symbol: symbol,
            timeframe: .oneMinute,
            interval: interval,
            open: 43_020,
            high: 43_180,
            low: 42_950,
            close: 43_120,
            volume: 18
        )
        let spotOrderIntent = try ProductAwareOrderIntent(
            intentID: Identifier.constant("gh-576-spot-long-intent"),
            instrument: spot,
            targetExposure: .targetLong,
            quantity: try Quantity(0.10, field: "gh576SpotQuantity"),
            referencePrice: try Price(43_050, field: "gh576SpotReferencePrice"),
            createdAt: emittedAt
        )
        let perpOrderIntent = try ProductAwareOrderIntent(
            intentID: Identifier.constant("gh-576-perp-short-intent"),
            instrument: perp,
            targetExposure: .targetShort,
            quantity: try Quantity(0.20, field: "gh576PerpQuantity"),
            referencePrice: try Price(43_120, field: "gh576PerpReferencePrice"),
            createdAt: emittedAt
        )
        let spotStrategyMessage = try StrategyIntentMessage(
            messageID: Identifier.constant("gh-576-spot-strategy-message"),
            strategyID: strategyID,
            instrument: spot,
            targetExposure: .targetLong,
            productAwareOrderIntent: spotOrderIntent,
            emittedAt: emittedAt
        )
        let perpStrategyMessage = try StrategyIntentMessage(
            messageID: Identifier.constant("gh-576-perp-strategy-message"),
            strategyID: strategyID,
            instrument: perp,
            targetExposure: .targetShort,
            productAwareOrderIntent: perpOrderIntent,
            emittedAt: emittedAt
        )
        let spotPosition = try ProductAwarePositionState(
            positionID: Identifier.constant("gh-576-shared-position"),
            portfolioID: Identifier.constant("gh-576-portfolio"),
            instrument: spot,
            netQuantity: 0.10,
            averageEntryPrice: 43_050,
            updatedAt: emittedAt,
            sourceSequence: 7
        )
        let perpPosition = try ProductAwarePositionState(
            positionID: Identifier.constant("gh-576-shared-position"),
            portfolioID: Identifier.constant("gh-576-portfolio"),
            instrument: perp,
            netQuantity: 0.20,
            averageEntryPrice: 43_120,
            updatedAt: emittedAt,
            sourceSequence: 8
        )

        var cache = ProductAwareCache()
        try cache.ingestMarketEvent(.bar(spotBar), instrument: spot)
        try cache.ingestMarketEvent(.bar(perpBar), instrument: perp)
        try cache.ingestStrategyIntent(spotStrategyMessage, sourceSequence: 3)
        try cache.ingestStrategyIntent(perpStrategyMessage, sourceSequence: 4)
        try cache.ingestOrderIntent(spotOrderIntent, sourceSequence: 5)
        try cache.ingestOrderIntent(perpOrderIntent, sourceSequence: 6)
        cache.ingestPositionState(spotPosition)
        cache.ingestPositionState(perpPosition)

        let spotSeriesKey = ProductAwareMarketDataSeriesKey(instrument: spot, timeframe: .oneMinute)
        let perpSeriesKey = ProductAwareMarketDataSeriesKey(instrument: perp, timeframe: .oneMinute)
        XCTAssertNotEqual(spotSeriesKey, perpSeriesKey)
        XCTAssertEqual(cache.snapshot.marketData.barsBySeries[spotSeriesKey]?.first?.close.rawValue, 43_050)
        XCTAssertEqual(cache.snapshot.marketData.barsBySeries[perpSeriesKey]?.first?.close.rawValue, 43_120)

        let spotStrategyKey = ProductAwareStrategyStateKey(instrument: spot, strategyID: strategyID)
        let perpStrategyKey = ProductAwareStrategyStateKey(instrument: perp, strategyID: strategyID)
        XCTAssertNotEqual(spotStrategyKey, perpStrategyKey)
        XCTAssertEqual(cache.snapshot.strategyStatesByKey[spotStrategyKey]?.targetExposure, .targetLong)
        XCTAssertEqual(cache.snapshot.strategyStatesByKey[perpStrategyKey]?.targetExposure, .targetShort)
        XCTAssertEqual(cache.snapshot.orderStatesByKey.count, 2)
        XCTAssertEqual(cache.snapshot.positionStatesByKey.count, 2)
        XCTAssertTrue(cache.snapshot.productAwareBoundaryHeld)
        XCTAssertEqual(cache.snapshot.evidenceCount, 8)

        let replayFacts: [ProductAwareCacheReplayFact] = [
            .marketEvent(instrument: spot, event: .bar(spotBar)),
            .marketEvent(instrument: perp, event: .bar(perpBar)),
            .strategyIntent(message: spotStrategyMessage, sourceSequence: 3),
            .strategyIntent(message: perpStrategyMessage, sourceSequence: 4),
            .orderIntent(intent: spotOrderIntent, sourceSequence: 5),
            .orderIntent(intent: perpOrderIntent, sourceSequence: 6),
            .positionState(spotPosition),
            .positionState(perpPosition)
        ]
        XCTAssertEqual(try ProductAwareCache.project(replayFacts), cache.snapshot)

        var replayCache = ProductAwareCache()
        XCTAssertEqual(try replayCache.replay(replayFacts), cache.snapshot)
        XCTAssertEqual(replayCache.snapshot, cache.snapshot)

        XCTAssertThrowsError(
            try ProductAwarePositionState(
                positionID: Identifier.constant("unsafe-gh-576-margin-position"),
                portfolioID: Identifier.constant("gh-576-portfolio"),
                instrument: perp,
                netQuantity: 0.20,
                averageEntryPrice: 43_120,
                updatedAt: emittedAt,
                sourceSequence: 9,
                usesMargin: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CacheContractError,
                .marketDataMismatch(
                    field: "productAwarePositionState.usesMargin",
                    expected: "false",
                    actual: "true"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-576`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-PRODUCT-AWARE-CACHE-STATE"))
        XCTAssertTrue(validationPlan.contains("GH-576 Release v0.2.0 Product-aware Cache State Validation"))
        XCTAssertTrue(domainContext.contains("GH-576 Product-aware Cache State Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 product-aware Cache state anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-576 / V020-14 | Product-aware Cache market / order / position / strategy state"
            )
        )
    }

    func testGH577ProposalArbitratorAllowsAgreementAndBlocksConflictsBeforeRisk() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let emittedAt = Date(timeIntervalSince1970: 1_704_067_700)
        let quantity = try Quantity(0.25, field: "gh577Quantity")
        let spotReferencePrice = try Price(43_000, field: "gh577SpotReferencePrice")
        let perpReferencePrice = try Price(43_100, field: "gh577PerpReferencePrice")

        func candidate(
            strategyID: String,
            instrument: InstrumentIdentity,
            targetExposure: TargetExposureIntent,
            intentID: String,
            sourceSequence: Int
        ) throws -> StrategyProposalArbitrationCandidate {
            let orderIntent = try ProductAwareOrderIntent(
                intentID: Identifier.constant(intentID),
                instrument: instrument,
                targetExposure: targetExposure,
                quantity: quantity,
                referencePrice: instrument.productType == .spot ? spotReferencePrice : perpReferencePrice,
                createdAt: emittedAt
            )
            return try StrategyProposalArbitrationCandidate(
                strategyID: Identifier.constant(strategyID),
                instrument: instrument,
                targetExposure: targetExposure,
                productAwareOrderIntent: orderIntent,
                emittedAt: emittedAt,
                sourceSequence: sourceSequence
            )
        }

        let agreeLong = try ProposalArbitrator.arbitrate(
            decisionID: Identifier.constant("gh-577-agree-long"),
            candidates: [
                candidate(
                    strategyID: "gh-577-ema",
                    instrument: spot,
                    targetExposure: .targetLong,
                    intentID: "gh-577-ema-long",
                    sourceSequence: 1
                ),
                candidate(
                    strategyID: "gh-577-rsi",
                    instrument: spot,
                    targetExposure: .targetLong,
                    intentID: "gh-577-rsi-long",
                    sourceSequence: 2
                )
            ],
            evaluatedAt: emittedAt
        )
        XCTAssertEqual(agreeLong.status, .forwardToRisk)
        XCTAssertEqual(agreeLong.targetExposure, .targetLong)
        XCTAssertTrue(agreeLong.forwardsToRisk)
        XCTAssertTrue(agreeLong.boundaryHeld)

        let agreeFlat = try ProposalArbitrator.arbitrate(
            decisionID: Identifier.constant("gh-577-agree-flat"),
            candidates: [
                candidate(
                    strategyID: "gh-577-ema",
                    instrument: spot,
                    targetExposure: .targetFlat,
                    intentID: "gh-577-ema-flat",
                    sourceSequence: 3
                ),
                candidate(
                    strategyID: "gh-577-rsi",
                    instrument: spot,
                    targetExposure: .targetFlat,
                    intentID: "gh-577-rsi-flat",
                    sourceSequence: 4
                )
            ],
            evaluatedAt: emittedAt
        )
        XCTAssertEqual(agreeFlat.status, .forwardToRisk)
        XCTAssertEqual(agreeFlat.targetExposure, .targetFlat)
        XCTAssertTrue(agreeFlat.forwardsToRisk)

        let conflict = try ProposalArbitrator.arbitrate(
            decisionID: Identifier.constant("gh-577-conflict"),
            candidates: [
                candidate(
                    strategyID: "gh-577-ema",
                    instrument: spot,
                    targetExposure: .targetLong,
                    intentID: "gh-577-ema-conflict-long",
                    sourceSequence: 5
                ),
                candidate(
                    strategyID: "gh-577-rsi",
                    instrument: spot,
                    targetExposure: .targetFlat,
                    intentID: "gh-577-rsi-conflict-flat",
                    sourceSequence: 6
                )
            ],
            evaluatedAt: emittedAt
        )
        XCTAssertEqual(conflict.status, .blocked)
        XCTAssertEqual(conflict.blocker, .conflictBlockedByDefault)
        XCTAssertFalse(conflict.forwardsToRisk)

        let spotShortCandidate = try StrategyProposalArbitrationCandidate(
            strategyID: Identifier.constant("gh-577-rsi"),
            instrument: spot,
            targetExposure: .targetShort,
            productAwareOrderIntent: nil,
            emittedAt: emittedAt,
            sourceSequence: 7
        )
        let spotShort = try ProposalArbitrator.arbitrate(
            decisionID: Identifier.constant("gh-577-spot-short"),
            candidates: [spotShortCandidate],
            evaluatedAt: emittedAt
        )
        XCTAssertEqual(spotShort.status, .blocked)
        XCTAssertEqual(spotShort.blocker, .spotShortBlocked)
        XCTAssertNil(spotShort.forwardedOrderIntent)

        let perpShort = try ProposalArbitrator.arbitrate(
            decisionID: Identifier.constant("gh-577-perp-short"),
            candidates: [
                candidate(
                    strategyID: "gh-577-ema",
                    instrument: perp,
                    targetExposure: .targetShort,
                    intentID: "gh-577-ema-perp-short",
                    sourceSequence: 8
                ),
                candidate(
                    strategyID: "gh-577-rsi",
                    instrument: perp,
                    targetExposure: .targetShort,
                    intentID: "gh-577-rsi-perp-short",
                    sourceSequence: 9
                )
            ],
            evaluatedAt: emittedAt,
            allowPerpetualShort: true
        )
        XCTAssertEqual(perpShort.status, .forwardToRisk)
        XCTAssertEqual(perpShort.targetExposure, .targetShort)
        XCTAssertEqual(perpShort.forwardedOrderIntent?.instrument.productType, .usdsPerpetual)
        XCTAssertTrue(perpShort.forwardsToRisk)
        XCTAssertFalse(perpShort.authorizesLiveTrading)
        XCTAssertFalse(perpShort.productionTradingEnabledByDefault)

        let perpShortBlocked = try ProposalArbitrator.arbitrate(
            decisionID: Identifier.constant("gh-577-perp-short-gate-closed"),
            candidates: [
                candidate(
                    strategyID: "gh-577-rsi",
                    instrument: perp,
                    targetExposure: .targetShort,
                    intentID: "gh-577-rsi-perp-short-blocked",
                    sourceSequence: 10
                )
            ],
            evaluatedAt: emittedAt,
            allowPerpetualShort: false
        )
        XCTAssertEqual(perpShortBlocked.status, .blocked)
        XCTAssertEqual(perpShortBlocked.blocker, .perpetualShortGateClosed)

        XCTAssertThrowsError(
            try ProposalArbitrationDecision(
                decisionID: Identifier.constant("unsafe-gh-577-production-default"),
                instrument: spot,
                targetExposure: .targetLong,
                candidateStrategyIDs: [Identifier.constant("gh-577-ema")],
                sourceSequences: [11],
                status: .forwardToRisk,
                blocker: nil,
                forwardedOrderIntent: candidate(
                    strategyID: "gh-577-ema",
                    instrument: spot,
                    targetExposure: .targetLong,
                    intentID: "unsafe-gh-577-order",
                    sourceSequence: 11
                ).productAwareOrderIntent,
                evaluatedAt: emittedAt,
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineForbiddenCapability("productionTradingEnabledByDefault")
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-577`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-PROPOSAL-ARBITRATOR"))
        XCTAssertTrue(validationPlan.contains("GH-577 Release v0.2.0 Proposal Arbitrator Validation"))
        XCTAssertTrue(domainContext.contains("GH-577 Proposal Arbitrator Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 ProposalArbitrator anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-577 / V020-15 | EMA / RSI ProposalArbitrator across Spot and Perp"
            )
        )
    }

    func testGH578RiskEngineCommonLayerAppliesAllowlistsLimitsKillSwitchAndNoTrade() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let btc = Symbol.constant("BTCUSDT")
        let eth = Symbol.constant("ETHUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: btc)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: btc)
        let unlistedSpot = InstrumentIdentity.binance(productType: .spot, symbol: eth)
        let evaluatedAt = Date(timeIntervalSince1970: 1_704_067_800)
        let emaID = Identifier.constant("gh-578-ema")
        let rsiID = Identifier.constant("gh-578-rsi")
        let quantity = try Quantity(0.25, field: "gh578Quantity")
        let spotReferencePrice = try Price(43_000, field: "gh578SpotReferencePrice")
        let perpReferencePrice = try Price(43_100, field: "gh578PerpReferencePrice")

        func policy(
            maxNotional: Double = 20_000,
            maxAggregateExposure: Double = 50_000,
            killSwitchActive: Bool = false,
            noTradeStateActive: Bool = false
        ) throws -> ReleaseV020RiskEngineCommonPolicy {
            try ReleaseV020RiskEngineCommonPolicy(
                policyID: Identifier.constant("gh-578-risk-policy"),
                allowedStrategies: [
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: emaID, kind: .ema),
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: rsiID, kind: .rsi)
                ],
                allowedInstruments: [spot, perp],
                maxNotional: maxNotional,
                maxAggregateExposure: maxAggregateExposure,
                killSwitchActive: killSwitchActive,
                noTradeStateActive: noTradeStateActive
            )
        }

        func candidate(
            strategyID: Identifier,
            instrument: InstrumentIdentity,
            targetExposure: TargetExposureIntent,
            intentID: String,
            sourceSequence: Int,
            candidateQuantity: Quantity = quantity
        ) throws -> StrategyProposalArbitrationCandidate {
            let orderIntent = try ProductAwareOrderIntent(
                intentID: Identifier.constant(intentID),
                instrument: instrument,
                targetExposure: targetExposure,
                quantity: candidateQuantity,
                referencePrice: instrument.productType == .spot ? spotReferencePrice : perpReferencePrice,
                createdAt: evaluatedAt
            )
            return try StrategyProposalArbitrationCandidate(
                strategyID: strategyID,
                instrument: instrument,
                targetExposure: targetExposure,
                productAwareOrderIntent: orderIntent,
                emittedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        func arbitration(
            decisionID: String,
            candidates: [StrategyProposalArbitrationCandidate]
        ) throws -> ProposalArbitrationDecision {
            try ProposalArbitrator.arbitrate(
                decisionID: Identifier.constant(decisionID),
                candidates: candidates,
                evaluatedAt: evaluatedAt
            )
        }

        func input(
            _ decision: ProposalArbitrationDecision,
            currentAggregateExposure: Double = 10_000,
            sourceSequence: Int
        ) throws -> ReleaseV020RiskEngineCommonInput {
            try ReleaseV020RiskEngineCommonInput(
                inputID: Identifier.constant("gh-578-risk-input-\(sourceSequence)"),
                arbitrationDecision: decision,
                currentAggregateExposure: currentAggregateExposure,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        let approvedArbitration = try arbitration(
            decisionID: "gh-578-approved-arbitration",
            candidates: [
                candidate(
                    strategyID: emaID,
                    instrument: spot,
                    targetExposure: .targetLong,
                    intentID: "gh-578-ema-long",
                    sourceSequence: 1
                ),
                candidate(
                    strategyID: rsiID,
                    instrument: spot,
                    targetExposure: .targetLong,
                    intentID: "gh-578-rsi-long",
                    sourceSequence: 2
                )
            ]
        )
        let approved = try ReleaseV020RiskEngineCommonLayer.evaluate(
            decisionID: Identifier.constant("gh-578-approved"),
            input: input(approvedArbitration, sourceSequence: 3),
            policy: policy()
        )
        XCTAssertEqual(approved.status, .forwardToCommandGateway)
        XCTAssertNil(approved.blocker)
        XCTAssertEqual(Set(approved.passedGates), Set(ReleaseV020RiskEngineCommonGate.allCases))
        XCTAssertEqual(approved.proposedNotional, 10_750)
        XCTAssertEqual(approved.projectedAggregateExposure, 20_750)
        XCTAssertTrue(approved.forwardsToCommandGateway)
        XCTAssertTrue(approved.boundaryHeld)
        XCTAssertFalse(approved.productionTradingEnabledByDefault)
        XCTAssertFalse(approved.bypassesCommandGateway)
        XCTAssertFalse(approved.touchesExecutionEngine)
        XCTAssertFalse(approved.submitsRealOrder)

        let unknownStrategyArbitration = try arbitration(
            decisionID: "gh-578-unknown-strategy-arbitration",
            candidates: [
                candidate(
                    strategyID: Identifier.constant("gh-578-momentum"),
                    instrument: spot,
                    targetExposure: .targetLong,
                    intentID: "gh-578-momentum-long",
                    sourceSequence: 4
                )
            ]
        )
        let strategyBlocked = try ReleaseV020RiskEngineCommonLayer.evaluate(
            decisionID: Identifier.constant("gh-578-strategy-blocked"),
            input: input(unknownStrategyArbitration, sourceSequence: 5),
            policy: policy()
        )
        XCTAssertEqual(strategyBlocked.status, .blocked)
        XCTAssertEqual(strategyBlocked.blocker, .strategyNotAllowed)
        XCTAssertFalse(strategyBlocked.forwardsToCommandGateway)

        let unlistedInstrumentArbitration = try arbitration(
            decisionID: "gh-578-unlisted-instrument-arbitration",
            candidates: [
                candidate(
                    strategyID: emaID,
                    instrument: unlistedSpot,
                    targetExposure: .targetLong,
                    intentID: "gh-578-unlisted-spot-long",
                    sourceSequence: 6
                )
            ]
        )
        let instrumentBlocked = try ReleaseV020RiskEngineCommonLayer.evaluate(
            decisionID: Identifier.constant("gh-578-instrument-blocked"),
            input: input(unlistedInstrumentArbitration, sourceSequence: 7),
            policy: policy()
        )
        XCTAssertEqual(instrumentBlocked.status, .blocked)
        XCTAssertEqual(instrumentBlocked.blocker, .instrumentNotAllowed)

        let oversizedArbitration = try arbitration(
            decisionID: "gh-578-oversized-arbitration",
            candidates: [
                candidate(
                    strategyID: emaID,
                    instrument: spot,
                    targetExposure: .targetLong,
                    intentID: "gh-578-oversized-long",
                    sourceSequence: 8,
                    candidateQuantity: Quantity(1, field: "gh578OversizedQuantity")
                )
            ]
        )
        let notionalBlocked = try ReleaseV020RiskEngineCommonLayer.evaluate(
            decisionID: Identifier.constant("gh-578-notional-blocked"),
            input: input(oversizedArbitration, sourceSequence: 9),
            policy: policy()
        )
        XCTAssertEqual(notionalBlocked.status, .blocked)
        XCTAssertEqual(notionalBlocked.blocker, .maxNotionalExceeded)

        let aggregateBlocked = try ReleaseV020RiskEngineCommonLayer.evaluate(
            decisionID: Identifier.constant("gh-578-aggregate-blocked"),
            input: input(approvedArbitration, currentAggregateExposure: 45_000, sourceSequence: 10),
            policy: policy()
        )
        XCTAssertEqual(aggregateBlocked.status, .blocked)
        XCTAssertEqual(aggregateBlocked.blocker, .aggregateExposureExceeded)
        XCTAssertEqual(aggregateBlocked.projectedAggregateExposure, 55_750)

        let killSwitchBlocked = try ReleaseV020RiskEngineCommonLayer.evaluate(
            decisionID: Identifier.constant("gh-578-kill-switch-blocked"),
            input: input(approvedArbitration, sourceSequence: 11),
            policy: policy(killSwitchActive: true)
        )
        XCTAssertEqual(killSwitchBlocked.status, .blocked)
        XCTAssertEqual(killSwitchBlocked.blocker, .killSwitchActive)

        let noTradeBlocked = try ReleaseV020RiskEngineCommonLayer.evaluate(
            decisionID: Identifier.constant("gh-578-no-trade-blocked"),
            input: input(approvedArbitration, sourceSequence: 12),
            policy: policy(noTradeStateActive: true)
        )
        XCTAssertEqual(noTradeBlocked.status, .blocked)
        XCTAssertEqual(noTradeBlocked.blocker, .noTradeStateActive)

        let perpShortArbitration = try ProposalArbitrator.arbitrate(
            decisionID: Identifier.constant("gh-578-perp-short-arbitration"),
            candidates: [
                candidate(
                    strategyID: rsiID,
                    instrument: perp,
                    targetExposure: .targetShort,
                    intentID: "gh-578-rsi-perp-short",
                    sourceSequence: 13
                )
            ],
            evaluatedAt: evaluatedAt,
            allowPerpetualShort: true
        )
        let perpShortForwarded = try ReleaseV020RiskEngineCommonLayer.evaluate(
            decisionID: Identifier.constant("gh-578-perp-short-forwarded"),
            input: input(perpShortArbitration, sourceSequence: 14),
            policy: policy()
        )
        XCTAssertEqual(perpShortForwarded.status, .forwardToCommandGateway)
        XCTAssertEqual(perpShortForwarded.instrument?.productType, .usdsPerpetual)
        XCTAssertTrue(perpShortForwarded.forwardsToCommandGateway)

        XCTAssertThrowsError(
            try ReleaseV020RiskEngineCommonPolicy(
                policyID: Identifier.constant("unsafe-gh-578-production-default"),
                allowedStrategies: [
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: emaID, kind: .ema),
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: rsiID, kind: .rsi)
                ],
                allowedInstruments: [spot, perp],
                maxNotional: 20_000,
                maxAggregateExposure: 50_000,
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineForbiddenCapability(
                    "releaseV020RiskEngineCommon.productionTradingEnabledByDefault"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV020RiskEngineCommonDecision(
                decisionID: Identifier.constant("unsafe-gh-578-command-bypass"),
                inputID: Identifier.constant("unsafe-gh-578-input"),
                instrument: spot,
                status: .forwardToCommandGateway,
                blocker: nil,
                passedGates: ReleaseV020RiskEngineCommonGate.allCases,
                proposedNotional: 10_750,
                projectedAggregateExposure: 20_750,
                forwardedOrderIntent: approved.forwardedOrderIntent,
                evaluatedAt: evaluatedAt,
                bypassesCommandGateway: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineForbiddenCapability("releaseV020RiskEngineCommon.bypassesCommandGateway")
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-578`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-RISKENGINE-COMMON-LAYER"))
        XCTAssertTrue(validationPlan.contains("GH-578 Release v0.2.0 RiskEngine Common Layer Validation"))
        XCTAssertTrue(domainContext.contains("GH-578 RiskEngine Common Layer Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 RiskEngine common layer anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-578 / V020-16 | RiskEngine common layer for strategy / instrument / notional / exposure / kill switch / no-trade"
            )
        )
    }

    func testGH579SpotRiskChecksCoverBalancesShortAndExchangeFilters() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let evaluatedAt = Date(timeIntervalSince1970: 1_704_067_900)
        let emaID = Identifier.constant("gh-579-ema")
        let rsiID = Identifier.constant("gh-579-rsi")
        let quantity = try Quantity(0.25, field: "gh579Quantity")
        let referencePrice = try Price(43_000, field: "gh579ReferencePrice")
        let exchangeFilter = try ReleaseV020SpotExchangeFilterEvidence.deterministicFixture()

        func candidate(
            strategyID: Identifier,
            targetExposure: TargetExposureIntent,
            intentID: String,
            sourceSequence: Int,
            candidateQuantity: Quantity = quantity
        ) throws -> StrategyProposalArbitrationCandidate {
            let orderIntent = try ProductAwareOrderIntent(
                intentID: Identifier.constant(intentID),
                instrument: spot,
                targetExposure: targetExposure,
                quantity: candidateQuantity,
                referencePrice: referencePrice,
                createdAt: evaluatedAt
            )
            return try StrategyProposalArbitrationCandidate(
                strategyID: strategyID,
                instrument: spot,
                targetExposure: targetExposure,
                productAwareOrderIntent: orderIntent,
                emittedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        func commonDecision(
            decisionID: String,
            targetExposure: TargetExposureIntent,
            quantity: Quantity = quantity,
            sourceSequence: Int
        ) throws -> ReleaseV020RiskEngineCommonDecision {
            let arbitration = try ProposalArbitrator.arbitrate(
                decisionID: Identifier.constant("\(decisionID)-arbitration"),
                candidates: [
                    candidate(
                        strategyID: emaID,
                        targetExposure: targetExposure,
                        intentID: "\(decisionID)-ema",
                        sourceSequence: sourceSequence,
                        candidateQuantity: quantity
                    ),
                    candidate(
                        strategyID: rsiID,
                        targetExposure: targetExposure,
                        intentID: "\(decisionID)-rsi",
                        sourceSequence: sourceSequence + 1,
                        candidateQuantity: quantity
                    )
                ],
                evaluatedAt: evaluatedAt
            )
            let input = try ReleaseV020RiskEngineCommonInput(
                inputID: Identifier.constant("\(decisionID)-common-input"),
                arbitrationDecision: arbitration,
                currentAggregateExposure: 10_000,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence + 2
            )
            let policy = try ReleaseV020RiskEngineCommonPolicy(
                policyID: Identifier.constant("\(decisionID)-common-policy"),
                allowedStrategies: [
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: emaID, kind: .ema),
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: rsiID, kind: .rsi)
                ],
                allowedInstruments: [spot],
                maxNotional: 20_000,
                maxAggregateExposure: 50_000
            )
            return try ReleaseV020RiskEngineCommonLayer.evaluate(
                decisionID: Identifier.constant("\(decisionID)-common-decision"),
                input: input,
                policy: policy
            )
        }

        func spotInput(
            decision: ReleaseV020RiskEngineCommonDecision,
            targetExposure: TargetExposureIntent? = nil,
            quantity: Quantity? = nil,
            referencePrice: Price? = nil,
            cashBalance: Double = 20_000,
            baseBalance: Double = 1,
            sourceSequence: Int
        ) throws -> ReleaseV020SpotRiskInput {
            try ReleaseV020SpotRiskInput(
                inputID: Identifier.constant("gh-579-spot-risk-input-\(sourceSequence)"),
                commonDecision: decision,
                targetExposure: targetExposure,
                quantity: quantity,
                referencePrice: referencePrice,
                cashBalance: cashBalance,
                baseBalance: baseBalance,
                exchangeFilter: exchangeFilter,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        let longCommon = try commonDecision(
            decisionID: "gh-579-long",
            targetExposure: .targetLong,
            sourceSequence: 1
        )
        let allowed = try ReleaseV020SpotRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-579-spot-allowed"),
            input: spotInput(decision: longCommon, sourceSequence: 4)
        )
        XCTAssertEqual(allowed.status, .forwardToCommandGateway)
        XCTAssertNil(allowed.blocker)
        XCTAssertEqual(Set(allowed.passedGates), Set(ReleaseV020SpotRiskGate.allCases))
        XCTAssertEqual(allowed.notional, 10_750)
        XCTAssertTrue(allowed.forwardsToCommandGateway)
        XCTAssertTrue(allowed.boundaryHeld)
        XCTAssertFalse(allowed.productionTradingEnabledByDefault)
        XCTAssertFalse(allowed.bypassesCommandGateway)
        XCTAssertFalse(allowed.touchesExecutionEngine)
        XCTAssertFalse(allowed.submitsRealOrder)

        let cashBlocked = try ReleaseV020SpotRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-579-cash-blocked"),
            input: spotInput(decision: longCommon, cashBalance: 100, sourceSequence: 5)
        )
        XCTAssertEqual(cashBlocked.status, .blocked)
        XCTAssertEqual(cashBlocked.blocker, .cashBalanceInsufficient)

        let flatCommon = try commonDecision(
            decisionID: "gh-579-flat",
            targetExposure: .targetFlat,
            sourceSequence: 6
        )
        let baseBlocked = try ReleaseV020SpotRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-579-base-blocked"),
            input: spotInput(decision: flatCommon, baseBalance: 0.10, sourceSequence: 9)
        )
        XCTAssertEqual(baseBlocked.status, .blocked)
        XCTAssertEqual(baseBlocked.blocker, .baseBalanceInsufficient)

        let shortBlocked = try ReleaseV020SpotRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-579-short-blocked"),
            input: spotInput(decision: longCommon, targetExposure: .targetShort, sourceSequence: 10)
        )
        XCTAssertEqual(shortBlocked.status, .blocked)
        XCTAssertEqual(shortBlocked.blocker, .spotShortForbidden)

        let minNotionalBlocked = try ReleaseV020SpotRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-579-min-notional-blocked"),
            input: spotInput(
                decision: longCommon,
                quantity: Quantity(0.001, field: "gh579TinyQuantity"),
                sourceSequence: 11
            )
        )
        XCTAssertEqual(minNotionalBlocked.status, .blocked)
        XCTAssertEqual(minNotionalBlocked.blocker, .minNotionalFilterFailed)

        let lotSizeBlocked = try ReleaseV020SpotRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-579-lot-size-blocked"),
            input: spotInput(
                decision: longCommon,
                quantity: Quantity(0.255, field: "gh579OddLotQuantity"),
                sourceSequence: 12
            )
        )
        XCTAssertEqual(lotSizeBlocked.status, .blocked)
        XCTAssertEqual(lotSizeBlocked.blocker, .lotSizeFilterFailed)

        let priceFilterBlocked = try ReleaseV020SpotRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-579-price-filter-blocked"),
            input: spotInput(
                decision: longCommon,
                referencePrice: Price(43_000.005, field: "gh579OddTickPrice"),
                sourceSequence: 13
            )
        )
        XCTAssertEqual(priceFilterBlocked.status, .blocked)
        XCTAssertEqual(priceFilterBlocked.blocker, .priceFilterFailed)

        XCTAssertThrowsError(
            try ReleaseV020SpotRiskDecision(
                decisionID: Identifier.constant("unsafe-gh-579-command-bypass"),
                inputID: Identifier.constant("unsafe-gh-579-input"),
                instrument: spot,
                targetExposure: .targetLong,
                status: .forwardToCommandGateway,
                blocker: nil,
                passedGates: ReleaseV020SpotRiskGate.allCases,
                notional: 10_750,
                evaluatedAt: evaluatedAt,
                bypassesCommandGateway: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineForbiddenCapability("releaseV020SpotRisk.bypassesCommandGateway")
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-579`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-SPOT-RISK-CHECKS"))
        XCTAssertTrue(validationPlan.contains("GH-579 Release v0.2.0 Spot Risk Checks Validation"))
        XCTAssertTrue(domainContext.contains("GH-579 Spot Risk Checks Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Spot risk checks anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-579 / V020-17 | Binance Spot risk checks for cash / base balance / filters"
            )
        )
    }

    func testGH580PerpetualRiskChecksCoverLeverageLiquidationFundingAndReduceOnly() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let evaluatedAt = Date(timeIntervalSince1970: 1_704_068_000)
        let freshObservedAt = evaluatedAt.addingTimeInterval(-30)
        let staleObservedAt = evaluatedAt.addingTimeInterval(-120)
        let staleAfter: TimeInterval = 60
        let emaID = Identifier.constant("gh-580-ema")
        let rsiID = Identifier.constant("gh-580-rsi")
        let quantity = try Quantity(0.25, field: "gh580Quantity")
        let referencePrice = try Price(43_000, field: "gh580ReferencePrice")
        let policy = try ReleaseV020PerpetualRiskPolicy.deterministicFixture()

        func candidate(
            strategyID: Identifier,
            targetExposure: TargetExposureIntent,
            intentID: String,
            sourceSequence: Int,
            candidateQuantity: Quantity = quantity
        ) throws -> StrategyProposalArbitrationCandidate {
            let orderIntent = try ProductAwareOrderIntent(
                intentID: Identifier.constant(intentID),
                instrument: perp,
                targetExposure: targetExposure,
                quantity: candidateQuantity,
                referencePrice: referencePrice,
                createdAt: evaluatedAt
            )
            return try StrategyProposalArbitrationCandidate(
                strategyID: strategyID,
                instrument: perp,
                targetExposure: targetExposure,
                productAwareOrderIntent: orderIntent,
                emittedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        func commonDecision(
            decisionID: String,
            targetExposure: TargetExposureIntent,
            sourceSequence: Int
        ) throws -> ReleaseV020RiskEngineCommonDecision {
            let arbitration = try ProposalArbitrator.arbitrate(
                decisionID: Identifier.constant("\(decisionID)-arbitration"),
                candidates: [
                    candidate(
                        strategyID: emaID,
                        targetExposure: targetExposure,
                        intentID: "\(decisionID)-ema",
                        sourceSequence: sourceSequence
                    ),
                    candidate(
                        strategyID: rsiID,
                        targetExposure: targetExposure,
                        intentID: "\(decisionID)-rsi",
                        sourceSequence: sourceSequence + 1
                    )
                ],
                evaluatedAt: evaluatedAt,
                allowPerpetualShort: true
            )
            let input = try ReleaseV020RiskEngineCommonInput(
                inputID: Identifier.constant("\(decisionID)-common-input"),
                arbitrationDecision: arbitration,
                currentAggregateExposure: 10_000,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence + 2
            )
            let commonPolicy = try ReleaseV020RiskEngineCommonPolicy(
                policyID: Identifier.constant("\(decisionID)-common-policy"),
                allowedStrategies: [
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: emaID, kind: .ema),
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: rsiID, kind: .rsi)
                ],
                allowedInstruments: [perp],
                maxNotional: 20_000,
                maxAggregateExposure: 50_000
            )
            return try ReleaseV020RiskEngineCommonLayer.evaluate(
                decisionID: Identifier.constant("\(decisionID)-common-decision"),
                input: input,
                policy: commonPolicy
            )
        }

        func markPrice(stale: Bool = false) throws -> PerpetualMarkPriceReadModel {
            try PerpetualMarkPriceReadModel(
                instrument: perp,
                markPrice: 43_100,
                indexPrice: 43_090,
                observedAt: stale ? staleObservedAt : freshObservedAt,
                evaluatedAt: evaluatedAt,
                staleAfter: staleAfter
            )
        }

        func funding(rate: Double) throws -> PerpetualFundingRiskReadModel {
            let readModel = try PerpetualFundingRateReadModel(
                instrument: perp,
                fundingRate: rate,
                nextFundingTime: evaluatedAt.addingTimeInterval(8 * 60 * 60),
                observedAt: freshObservedAt,
                evaluatedAt: evaluatedAt,
                staleAfter: staleAfter
            )
            return try PerpetualFundingRiskReadModel(fundingReadModel: readModel)
        }

        func perpInput(
            decision: ReleaseV020RiskEngineCommonDecision,
            leverage: Double = 3,
            liquidationPrice: Double = 39_000,
            fundingRate: Double = 0.0001,
            staleMark: Bool = false,
            reduceOnlyClose: Bool = false,
            currentPositionQuantity: Double = 0.50,
            sourceSequence: Int
        ) throws -> ReleaseV020PerpetualRiskInput {
            try ReleaseV020PerpetualRiskInput(
                inputID: Identifier.constant("gh-580-perp-risk-input-\(sourceSequence)"),
                commonDecision: decision,
                markPriceReadModel: markPrice(stale: staleMark),
                fundingReadModel: funding(rate: fundingRate),
                leverage: leverage,
                liquidationPrice: Price(liquidationPrice, field: "gh580LiquidationPrice"),
                reduceOnlyClose: reduceOnlyClose,
                currentPositionQuantity: currentPositionQuantity,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        let shortCommon = try commonDecision(
            decisionID: "gh-580-short",
            targetExposure: .targetShort,
            sourceSequence: 1
        )
        let allowed = try ReleaseV020PerpetualRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-580-allowed"),
            input: perpInput(decision: shortCommon, sourceSequence: 4),
            policy: policy
        )
        XCTAssertEqual(allowed.status, .forwardToCommandGateway)
        XCTAssertTrue(allowed.warnings.isEmpty)
        XCTAssertEqual(Set(allowed.passedGates), Set(ReleaseV020PerpetualRiskGate.allCases))
        XCTAssertGreaterThanOrEqual(allowed.liquidationDistanceRatio, policy.minLiquidationDistanceRatio)
        XCTAssertTrue(allowed.forwardsToCommandGateway)
        XCTAssertTrue(allowed.boundaryHeld)
        XCTAssertFalse(allowed.productionTradingEnabledByDefault)
        XCTAssertFalse(allowed.bypassesCommandGateway)
        XCTAssertFalse(allowed.touchesExecutionEngine)
        XCTAssertFalse(allowed.submitsRealOrder)

        let fundingWarning = try ReleaseV020PerpetualRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-580-funding-warning"),
            input: perpInput(decision: shortCommon, fundingRate: 0.0007, sourceSequence: 5),
            policy: policy
        )
        XCTAssertEqual(fundingWarning.status, .forwardToCommandGatewayWithWarning)
        XCTAssertEqual(fundingWarning.warnings, [.fundingRiskWarning])
        XCTAssertTrue(fundingWarning.forwardsToCommandGateway)

        let leverageBlocked = try ReleaseV020PerpetualRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-580-leverage-blocked"),
            input: perpInput(decision: shortCommon, leverage: 8, sourceSequence: 6),
            policy: policy
        )
        XCTAssertEqual(leverageBlocked.status, .blocked)
        XCTAssertEqual(leverageBlocked.blocker, .leverageCapExceeded)

        let liquidationBlocked = try ReleaseV020PerpetualRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-580-liquidation-blocked"),
            input: perpInput(decision: shortCommon, liquidationPrice: 43_000, sourceSequence: 7),
            policy: policy
        )
        XCTAssertEqual(liquidationBlocked.status, .blocked)
        XCTAssertEqual(liquidationBlocked.blocker, .liquidationDistanceUnsafe)

        let staleMarkBlocked = try ReleaseV020PerpetualRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-580-stale-mark-blocked"),
            input: perpInput(decision: shortCommon, staleMark: true, sourceSequence: 8),
            policy: policy
        )
        XCTAssertEqual(staleMarkBlocked.status, .blocked)
        XCTAssertEqual(staleMarkBlocked.blocker, .staleMarkPrice)

        let fundingBlocked = try ReleaseV020PerpetualRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-580-funding-blocked"),
            input: perpInput(decision: shortCommon, fundingRate: 0.0012, sourceSequence: 9),
            policy: policy
        )
        XCTAssertEqual(fundingBlocked.status, .blocked)
        XCTAssertEqual(fundingBlocked.blocker, .fundingRiskBlocked)

        let flatCommon = try commonDecision(
            decisionID: "gh-580-flat",
            targetExposure: .targetFlat,
            sourceSequence: 10
        )
        let reduceOnlyAllowed = try ReleaseV020PerpetualRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-580-reduce-only-allowed"),
            input: perpInput(
                decision: flatCommon,
                reduceOnlyClose: true,
                currentPositionQuantity: -0.50,
                sourceSequence: 13
            ),
            policy: policy
        )
        XCTAssertEqual(reduceOnlyAllowed.status, .forwardToCommandGateway)
        XCTAssertTrue(reduceOnlyAllowed.reduceOnlyClose)

        let reduceOnlyBlocked = try ReleaseV020PerpetualRiskLayer.evaluate(
            decisionID: Identifier.constant("gh-580-reduce-only-blocked"),
            input: perpInput(
                decision: flatCommon,
                reduceOnlyClose: true,
                currentPositionQuantity: -0.10,
                sourceSequence: 14
            ),
            policy: policy
        )
        XCTAssertEqual(reduceOnlyBlocked.status, .blocked)
        XCTAssertEqual(reduceOnlyBlocked.blocker, .reduceOnlyCloseInvalid)

        XCTAssertThrowsError(
            try ReleaseV020PerpetualRiskDecision(
                decisionID: Identifier.constant("unsafe-gh-580-command-bypass"),
                inputID: Identifier.constant("unsafe-gh-580-input"),
                instrument: perp,
                status: .forwardToCommandGateway,
                blocker: nil,
                warnings: [],
                passedGates: ReleaseV020PerpetualRiskGate.allCases,
                leverage: 3,
                liquidationDistanceRatio: 0.10,
                fundingRate: 0.0001,
                reduceOnlyClose: false,
                evaluatedAt: evaluatedAt,
                bypassesCommandGateway: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineForbiddenCapability("releaseV020PerpetualRisk.bypassesCommandGateway")
            )
        }
        XCTAssertThrowsError(
            try ReleaseV020PerpetualRiskDecision(
                decisionID: Identifier.constant("unsafe-gh-580-warning-status"),
                inputID: Identifier.constant("unsafe-gh-580-warning-input"),
                instrument: perp,
                status: .forwardToCommandGatewayWithWarning,
                blocker: nil,
                warnings: [],
                passedGates: ReleaseV020PerpetualRiskGate.allCases,
                leverage: 3,
                liquidationDistanceRatio: 0.10,
                fundingRate: 0.0007,
                reduceOnlyClose: false,
                evaluatedAt: evaluatedAt
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineMismatch(
                    field: "releaseV020PerpetualRisk.warnings",
                    expected: "present for warning forward",
                    actual: "empty"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-580`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-PERP-RISK-CHECKS"))
        XCTAssertTrue(validationPlan.contains("GH-580 Release v0.2.0 Perpetual Risk Checks Validation"))
        XCTAssertTrue(domainContext.contains("GH-580 Perpetual Risk Checks Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Perpetual risk checks anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-580 / V020-18 | Binance USD-M Perpetual margin / leverage / liquidation / funding risk checks"
            )
        )
    }

    func testGH581SpotExecutionAlgorithmMapsTargetExposureToControlledSpotOrderIntent() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let evaluatedAt = Date(timeIntervalSince1970: 1_704_068_100)
        let emaID = Identifier.constant("gh-581-ema")
        let rsiID = Identifier.constant("gh-581-rsi")
        let quantity = try Quantity(0.25, field: "gh581Quantity")
        let referencePrice = try Price(43_000, field: "gh581ReferencePrice")
        let filter = try ReleaseV020SpotExchangeFilterEvidence.deterministicFixture()

        func sourceIntent(
            targetExposure: TargetExposureIntent,
            intentID: String
        ) throws -> ProductAwareOrderIntent {
            try ProductAwareOrderIntent(
                intentID: Identifier.constant(intentID),
                instrument: spot,
                targetExposure: targetExposure,
                quantity: quantity,
                referencePrice: referencePrice,
                createdAt: evaluatedAt
            )
        }

        func candidate(
            strategyID: Identifier,
            targetExposure: TargetExposureIntent,
            sourceOrderIntent: ProductAwareOrderIntent,
            sourceSequence: Int
        ) throws -> StrategyProposalArbitrationCandidate {
            try StrategyProposalArbitrationCandidate(
                strategyID: strategyID,
                instrument: spot,
                targetExposure: targetExposure,
                productAwareOrderIntent: sourceOrderIntent,
                emittedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        func spotRiskEvidence(
            decisionID: String,
            targetExposure: TargetExposureIntent,
            sourceSequence: Int,
            cashBalance: Double,
            baseBalance: Double
        ) throws -> (ProductAwareOrderIntent, ReleaseV020SpotRiskDecision) {
            let orderIntent = try sourceIntent(
                targetExposure: targetExposure,
                intentID: "\(decisionID)-source-order-intent"
            )
            let arbitration = try ProposalArbitrator.arbitrate(
                decisionID: Identifier.constant("\(decisionID)-arbitration"),
                candidates: [
                    candidate(
                        strategyID: emaID,
                        targetExposure: targetExposure,
                        sourceOrderIntent: orderIntent,
                        sourceSequence: sourceSequence
                    ),
                    candidate(
                        strategyID: rsiID,
                        targetExposure: targetExposure,
                        sourceOrderIntent: orderIntent,
                        sourceSequence: sourceSequence + 1
                    )
                ],
                evaluatedAt: evaluatedAt
            )
            let commonInput = try ReleaseV020RiskEngineCommonInput(
                inputID: Identifier.constant("\(decisionID)-common-input"),
                arbitrationDecision: arbitration,
                currentAggregateExposure: 5_000,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence + 2
            )
            let commonPolicy = try ReleaseV020RiskEngineCommonPolicy(
                policyID: Identifier.constant("\(decisionID)-common-policy"),
                allowedStrategies: [
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: emaID, kind: .ema),
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: rsiID, kind: .rsi)
                ],
                allowedInstruments: [spot],
                maxNotional: 20_000,
                maxAggregateExposure: 50_000
            )
            let commonDecision = try ReleaseV020RiskEngineCommonLayer.evaluate(
                decisionID: Identifier.constant("\(decisionID)-common-decision"),
                input: commonInput,
                policy: commonPolicy
            )
            let spotRiskInput = try ReleaseV020SpotRiskInput(
                inputID: Identifier.constant("\(decisionID)-spot-risk-input"),
                commonDecision: commonDecision,
                cashBalance: cashBalance,
                baseBalance: baseBalance,
                exchangeFilter: filter,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence + 3
            )
            let spotRiskDecision = try ReleaseV020SpotRiskLayer.evaluate(
                decisionID: Identifier.constant("\(decisionID)-spot-risk-decision"),
                input: spotRiskInput
            )
            XCTAssertTrue(spotRiskDecision.forwardsToCommandGateway)
            return (orderIntent, spotRiskDecision)
        }

        func algorithmInput(
            inputID: String,
            targetExposure: TargetExposureIntent,
            sourceOrderIntent: ProductAwareOrderIntent? = nil,
            spotRiskDecision: ReleaseV020SpotRiskDecision? = nil,
            currentBasePositionQuantity: Double,
            sourceSequence: Int
        ) throws -> ReleaseV020SpotExecutionAlgorithmInput {
            try ReleaseV020SpotExecutionAlgorithmInput(
                inputID: Identifier.constant(inputID),
                targetExposure: targetExposure,
                sourceOrderIntent: sourceOrderIntent,
                spotRiskDecision: spotRiskDecision,
                currentBasePositionQuantity: currentBasePositionQuantity,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        let longEvidence = try spotRiskEvidence(
            decisionID: "gh-581-long",
            targetExposure: .targetLong,
            sourceSequence: 1,
            cashBalance: 20_000,
            baseBalance: 0
        )
        let buyDecision = try ReleaseV020SpotExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-581-buy-decision"),
            input: algorithmInput(
                inputID: "gh-581-buy-input",
                targetExposure: .targetLong,
                sourceOrderIntent: longEvidence.0,
                spotRiskDecision: longEvidence.1,
                currentBasePositionQuantity: 0,
                sourceSequence: 5
            )
        )
        XCTAssertEqual(buyDecision.status, .orderIntentCreated)
        XCTAssertEqual(buyDecision.orderIntent?.side, .buy)
        XCTAssertEqual(buyDecision.orderIntent?.targetExposure, .targetLong)
        XCTAssertEqual(buyDecision.orderIntent?.instrument, spot)
        XCTAssertTrue(buyDecision.orderIntentCreated)
        XCTAssertFalse(buyDecision.productionTradingEnabledByDefault)
        XCTAssertFalse(buyDecision.callsExecutionClient)
        XCTAssertFalse(buyDecision.submitsRealOrder)
        XCTAssertTrue(buyDecision.orderIntent?.requiresOMSBeforeExecution == true)
        XCTAssertTrue(buyDecision.orderIntent?.requiresKillSwitchBeforeExecution == true)

        let flatEvidence = try spotRiskEvidence(
            decisionID: "gh-581-flat",
            targetExposure: .targetFlat,
            sourceSequence: 10,
            cashBalance: 20_000,
            baseBalance: 1.0
        )
        let sellDecision = try ReleaseV020SpotExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-581-sell-decision"),
            input: algorithmInput(
                inputID: "gh-581-sell-input",
                targetExposure: .targetFlat,
                sourceOrderIntent: flatEvidence.0,
                spotRiskDecision: flatEvidence.1,
                currentBasePositionQuantity: 0.50,
                sourceSequence: 14
            )
        )
        XCTAssertEqual(sellDecision.status, .orderIntentCreated)
        XCTAssertEqual(sellDecision.orderIntent?.side, .sell)
        XCTAssertEqual(sellDecision.orderIntent?.targetExposure, .targetFlat)
        XCTAssertTrue(sellDecision.orderIntentCreated)

        let targetShortBlocked = try ReleaseV020SpotExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-581-target-short-blocked"),
            input: algorithmInput(
                inputID: "gh-581-target-short-input",
                targetExposure: .targetShort,
                currentBasePositionQuantity: 0,
                sourceSequence: 20
            )
        )
        XCTAssertEqual(targetShortBlocked.status, .blocked)
        XCTAssertEqual(targetShortBlocked.blocker, .targetShortForbidden)
        XCTAssertNil(targetShortBlocked.orderIntent)

        let holdNoOrder = try ReleaseV020SpotExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-581-hold-no-order"),
            input: algorithmInput(
                inputID: "gh-581-hold-input",
                targetExposure: .hold,
                currentBasePositionQuantity: 0.25,
                sourceSequence: 21
            )
        )
        XCTAssertEqual(holdNoOrder.status, .noOrder)
        XCTAssertEqual(holdNoOrder.noOrderReason, .holdTargetExposure)
        XCTAssertNil(holdNoOrder.orderIntent)

        let alreadyLongNoOrder = try ReleaseV020SpotExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-581-already-long-no-order"),
            input: algorithmInput(
                inputID: "gh-581-already-long-input",
                targetExposure: .targetLong,
                sourceOrderIntent: longEvidence.0,
                spotRiskDecision: longEvidence.1,
                currentBasePositionQuantity: 0.25,
                sourceSequence: 22
            )
        )
        XCTAssertEqual(alreadyLongNoOrder.status, .noOrder)
        XCTAssertEqual(alreadyLongNoOrder.noOrderReason, .alreadyLong)

        XCTAssertThrowsError(
            try ReleaseV020SpotExecutionAlgorithmOrderIntent(
                orderIntentID: Identifier.constant("unsafe-gh-581-order-intent"),
                sourceInputID: Identifier.constant("unsafe-gh-581-input"),
                sourceRiskDecisionID: longEvidence.1.decisionID,
                sourceProductAwareIntentID: longEvidence.0.intentID,
                instrument: spot,
                targetExposure: .targetLong,
                side: .buy,
                quantity: quantity,
                referencePrice: referencePrice,
                currentBasePositionQuantity: 0,
                createdAt: evaluatedAt,
                callsExecutionClient: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020SpotExecutionAlgorithm.callsExecutionClient"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-581`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-SPOT-EXECUTION-ALGORITHM"))
        XCTAssertTrue(validationPlan.contains("GH-581 Release v0.2.0 Spot ExecutionAlgorithm Validation"))
        XCTAssertTrue(domainContext.contains("GH-581 Spot ExecutionAlgorithm Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Spot ExecutionAlgorithm anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-581 / V020-19 | Spot ExecutionAlgorithm maps TargetExposureIntent to controlled Spot order intent"
            )
        )
    }

    func testGH582PerpetualExecutionAlgorithmSupportsOpenReduceOnlyAndBlocksOneShotFlip() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let evaluatedAt = Date(timeIntervalSince1970: 1_704_068_200)
        let freshObservedAt = evaluatedAt.addingTimeInterval(-30)
        let emaID = Identifier.constant("gh-582-ema")
        let rsiID = Identifier.constant("gh-582-rsi")
        let quantity = try Quantity(0.25, field: "gh582Quantity")
        let referencePrice = try Price(43_000, field: "gh582ReferencePrice")
        let riskPolicy = try ReleaseV020PerpetualRiskPolicy.deterministicFixture()

        func sourceIntent(
            targetExposure: TargetExposureIntent,
            intentID: String
        ) throws -> ProductAwareOrderIntent {
            try ProductAwareOrderIntent(
                intentID: Identifier.constant(intentID),
                instrument: perp,
                targetExposure: targetExposure,
                quantity: quantity,
                referencePrice: referencePrice,
                createdAt: evaluatedAt
            )
        }

        func candidate(
            strategyID: Identifier,
            targetExposure: TargetExposureIntent,
            sourceOrderIntent: ProductAwareOrderIntent,
            sourceSequence: Int
        ) throws -> StrategyProposalArbitrationCandidate {
            try StrategyProposalArbitrationCandidate(
                strategyID: strategyID,
                instrument: perp,
                targetExposure: targetExposure,
                productAwareOrderIntent: sourceOrderIntent,
                emittedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        func markPrice() throws -> PerpetualMarkPriceReadModel {
            try PerpetualMarkPriceReadModel(
                instrument: perp,
                markPrice: 43_100,
                indexPrice: 43_090,
                observedAt: freshObservedAt,
                evaluatedAt: evaluatedAt,
                staleAfter: 60
            )
        }

        func funding() throws -> PerpetualFundingRiskReadModel {
            let readModel = try PerpetualFundingRateReadModel(
                instrument: perp,
                fundingRate: 0.0001,
                nextFundingTime: evaluatedAt.addingTimeInterval(8 * 60 * 60),
                observedAt: freshObservedAt,
                evaluatedAt: evaluatedAt,
                staleAfter: 60
            )
            return try PerpetualFundingRiskReadModel(fundingReadModel: readModel)
        }

        func perpetualRiskEvidence(
            decisionID: String,
            targetExposure: TargetExposureIntent,
            reduceOnlyClose: Bool,
            currentPositionQuantity: Double,
            sourceSequence: Int
        ) throws -> (ProductAwareOrderIntent, ReleaseV020PerpetualRiskDecision) {
            let orderIntent = try sourceIntent(
                targetExposure: targetExposure,
                intentID: "\(decisionID)-source-order-intent"
            )
            let arbitration = try ProposalArbitrator.arbitrate(
                decisionID: Identifier.constant("\(decisionID)-arbitration"),
                candidates: [
                    candidate(
                        strategyID: emaID,
                        targetExposure: targetExposure,
                        sourceOrderIntent: orderIntent,
                        sourceSequence: sourceSequence
                    ),
                    candidate(
                        strategyID: rsiID,
                        targetExposure: targetExposure,
                        sourceOrderIntent: orderIntent,
                        sourceSequence: sourceSequence + 1
                    )
                ],
                evaluatedAt: evaluatedAt,
                allowPerpetualShort: true
            )
            let commonInput = try ReleaseV020RiskEngineCommonInput(
                inputID: Identifier.constant("\(decisionID)-common-input"),
                arbitrationDecision: arbitration,
                currentAggregateExposure: 5_000,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence + 2
            )
            let commonPolicy = try ReleaseV020RiskEngineCommonPolicy(
                policyID: Identifier.constant("\(decisionID)-common-policy"),
                allowedStrategies: [
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: emaID, kind: .ema),
                    ReleaseV020RiskStrategyAllowlistEntry(strategyID: rsiID, kind: .rsi)
                ],
                allowedInstruments: [perp],
                maxNotional: 20_000,
                maxAggregateExposure: 50_000
            )
            let commonDecision = try ReleaseV020RiskEngineCommonLayer.evaluate(
                decisionID: Identifier.constant("\(decisionID)-common-decision"),
                input: commonInput,
                policy: commonPolicy
            )
            let perpInput = try ReleaseV020PerpetualRiskInput(
                inputID: Identifier.constant("\(decisionID)-perp-risk-input"),
                commonDecision: commonDecision,
                markPriceReadModel: markPrice(),
                fundingReadModel: funding(),
                leverage: 3,
                liquidationPrice: Price(39_000, field: "gh582LiquidationPrice"),
                reduceOnlyClose: reduceOnlyClose,
                currentPositionQuantity: currentPositionQuantity,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence + 3
            )
            let riskDecision = try ReleaseV020PerpetualRiskLayer.evaluate(
                decisionID: Identifier.constant("\(decisionID)-perp-risk-decision"),
                input: perpInput,
                policy: riskPolicy
            )
            XCTAssertTrue(riskDecision.forwardsToCommandGateway)
            return (orderIntent, riskDecision)
        }

        func algorithmInput(
            inputID: String,
            targetExposure: TargetExposureIntent,
            sourceOrderIntent: ProductAwareOrderIntent? = nil,
            riskDecision: ReleaseV020PerpetualRiskDecision? = nil,
            currentPositionQuantity: Double,
            sourceSequence: Int
        ) throws -> ReleaseV020PerpetualExecutionAlgorithmInput {
            try ReleaseV020PerpetualExecutionAlgorithmInput(
                inputID: Identifier.constant(inputID),
                targetExposure: targetExposure,
                sourceOrderIntent: sourceOrderIntent,
                perpetualRiskDecision: riskDecision,
                currentPositionQuantity: currentPositionQuantity,
                evaluatedAt: evaluatedAt,
                sourceSequence: sourceSequence
            )
        }

        let longEvidence = try perpetualRiskEvidence(
            decisionID: "gh-582-open-long",
            targetExposure: .targetLong,
            reduceOnlyClose: false,
            currentPositionQuantity: 0,
            sourceSequence: 1
        )
        let openLong = try ReleaseV020PerpetualExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-582-open-long-decision"),
            input: algorithmInput(
                inputID: "gh-582-open-long-input",
                targetExposure: .targetLong,
                sourceOrderIntent: longEvidence.0,
                riskDecision: longEvidence.1,
                currentPositionQuantity: 0,
                sourceSequence: 5
            )
        )
        XCTAssertEqual(openLong.status, .orderIntentCreated)
        XCTAssertEqual(openLong.orderIntent?.action, .openLong)
        XCTAssertEqual(openLong.orderIntent?.side, .buy)
        XCTAssertEqual(openLong.orderIntent?.reduceOnly, false)
        XCTAssertTrue(openLong.orderIntentCreated)
        XCTAssertFalse(openLong.orderIntent?.executesLeverageAction ?? true)
        XCTAssertFalse(openLong.orderIntent?.submitsRealOrder ?? true)

        let shortEvidence = try perpetualRiskEvidence(
            decisionID: "gh-582-open-short",
            targetExposure: .targetShort,
            reduceOnlyClose: false,
            currentPositionQuantity: 0,
            sourceSequence: 10
        )
        let openShort = try ReleaseV020PerpetualExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-582-open-short-decision"),
            input: algorithmInput(
                inputID: "gh-582-open-short-input",
                targetExposure: .targetShort,
                sourceOrderIntent: shortEvidence.0,
                riskDecision: shortEvidence.1,
                currentPositionQuantity: 0,
                sourceSequence: 14
            )
        )
        XCTAssertEqual(openShort.status, .orderIntentCreated)
        XCTAssertEqual(openShort.orderIntent?.action, .openShort)
        XCTAssertEqual(openShort.orderIntent?.side, .sell)
        XCTAssertEqual(openShort.orderIntent?.reduceOnly, false)

        let closeLongEvidence = try perpetualRiskEvidence(
            decisionID: "gh-582-close-long",
            targetExposure: .targetFlat,
            reduceOnlyClose: true,
            currentPositionQuantity: 0.50,
            sourceSequence: 20
        )
        let closeLong = try ReleaseV020PerpetualExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-582-close-long-decision"),
            input: algorithmInput(
                inputID: "gh-582-close-long-input",
                targetExposure: .targetFlat,
                sourceOrderIntent: closeLongEvidence.0,
                riskDecision: closeLongEvidence.1,
                currentPositionQuantity: 0.50,
                sourceSequence: 24
            )
        )
        XCTAssertEqual(closeLong.status, .orderIntentCreated)
        XCTAssertEqual(closeLong.orderIntent?.action, .reduceOnlyCloseLong)
        XCTAssertEqual(closeLong.orderIntent?.side, .sell)
        XCTAssertEqual(closeLong.orderIntent?.reduceOnly, true)

        let closeShortEvidence = try perpetualRiskEvidence(
            decisionID: "gh-582-close-short",
            targetExposure: .targetFlat,
            reduceOnlyClose: true,
            currentPositionQuantity: -0.50,
            sourceSequence: 30
        )
        let closeShort = try ReleaseV020PerpetualExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-582-close-short-decision"),
            input: algorithmInput(
                inputID: "gh-582-close-short-input",
                targetExposure: .targetFlat,
                sourceOrderIntent: closeShortEvidence.0,
                riskDecision: closeShortEvidence.1,
                currentPositionQuantity: -0.50,
                sourceSequence: 34
            )
        )
        XCTAssertEqual(closeShort.status, .orderIntentCreated)
        XCTAssertEqual(closeShort.orderIntent?.action, .reduceOnlyCloseShort)
        XCTAssertEqual(closeShort.orderIntent?.side, .buy)
        XCTAssertEqual(closeShort.orderIntent?.reduceOnly, true)

        let longFromShortBlocked = try ReleaseV020PerpetualExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-582-long-from-short-blocked"),
            input: algorithmInput(
                inputID: "gh-582-long-from-short-input",
                targetExposure: .targetLong,
                sourceOrderIntent: longEvidence.0,
                riskDecision: longEvidence.1,
                currentPositionQuantity: -0.25,
                sourceSequence: 40
            )
        )
        XCTAssertEqual(longFromShortBlocked.status, .blocked)
        XCTAssertEqual(longFromShortBlocked.blocker, .uncontrolledOneShotFlip)

        let shortFromLongBlocked = try ReleaseV020PerpetualExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-582-short-from-long-blocked"),
            input: algorithmInput(
                inputID: "gh-582-short-from-long-input",
                targetExposure: .targetShort,
                sourceOrderIntent: shortEvidence.0,
                riskDecision: shortEvidence.1,
                currentPositionQuantity: 0.25,
                sourceSequence: 41
            )
        )
        XCTAssertEqual(shortFromLongBlocked.status, .blocked)
        XCTAssertEqual(shortFromLongBlocked.blocker, .uncontrolledOneShotFlip)

        let holdNoOrder = try ReleaseV020PerpetualExecutionAlgorithm.decide(
            decisionID: Identifier.constant("gh-582-hold-no-order"),
            input: algorithmInput(
                inputID: "gh-582-hold-input",
                targetExposure: .hold,
                currentPositionQuantity: -0.25,
                sourceSequence: 42
            )
        )
        XCTAssertEqual(holdNoOrder.status, .noOrder)
        XCTAssertEqual(holdNoOrder.noOrderReason, .holdTargetExposure)

        XCTAssertThrowsError(
            try ReleaseV020PerpetualExecutionAlgorithmOrderIntent(
                orderIntentID: Identifier.constant("unsafe-gh-582-order-intent"),
                sourceInputID: Identifier.constant("unsafe-gh-582-input"),
                sourceRiskDecisionID: longEvidence.1.decisionID,
                sourceProductAwareIntentID: longEvidence.0.intentID,
                instrument: perp,
                targetExposure: .targetLong,
                action: .openLong,
                side: .buy,
                quantity: quantity,
                referencePrice: referencePrice,
                currentPositionQuantity: 0,
                reduceOnly: false,
                createdAt: evaluatedAt,
                executesLeverageAction: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020PerpetualExecutionAlgorithm.executesLeverageAction"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-582`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-PERP-EXECUTION-ALGORITHM"))
        XCTAssertTrue(validationPlan.contains("GH-582 Release v0.2.0 Perpetual ExecutionAlgorithm Validation"))
        XCTAssertTrue(domainContext.contains("GH-582 Perpetual ExecutionAlgorithm Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Perpetual ExecutionAlgorithm anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-582 / V020-20 | Perpetual ExecutionAlgorithm maps TargetExposureIntent to controlled Perp order intent"
            )
        )
    }

    func testGH583ProductAwareOMSStateMachineCoversSpotPerpReplayAndRejectsIllegalTransition() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let evaluatedAt = Date(timeIntervalSince1970: 1_704_071_800)
        let quantity = try Quantity(0.25, field: "gh583Quantity")
        let referencePrice = try Price(43_500, field: "gh583ReferencePrice")
        let spotOrderIntent = try ReleaseV020SpotExecutionAlgorithmOrderIntent(
            orderIntentID: Identifier.constant("gh-583-spot-order-intent"),
            sourceInputID: Identifier.constant("gh-583-spot-input"),
            sourceRiskDecisionID: Identifier.constant("gh-583-spot-risk-decision"),
            sourceProductAwareIntentID: Identifier.constant("gh-583-spot-product-aware-intent"),
            instrument: spot,
            targetExposure: .targetLong,
            side: .buy,
            quantity: quantity,
            referencePrice: referencePrice,
            currentBasePositionQuantity: 0,
            createdAt: evaluatedAt
        )
        let perpetualOrderIntent = try ReleaseV020PerpetualExecutionAlgorithmOrderIntent(
            orderIntentID: Identifier.constant("gh-583-perp-order-intent"),
            sourceInputID: Identifier.constant("gh-583-perp-input"),
            sourceRiskDecisionID: Identifier.constant("gh-583-perp-risk-decision"),
            sourceProductAwareIntentID: Identifier.constant("gh-583-perp-product-aware-intent"),
            instrument: perp,
            targetExposure: .targetShort,
            action: .openShort,
            side: .sell,
            quantity: quantity,
            referencePrice: referencePrice,
            currentPositionQuantity: 0,
            reduceOnly: false,
            createdAt: evaluatedAt
        )
        let stateMachine = try ReleaseV020ProductAwareOMSStateMachine.deterministicFixture()
        let evidence = try stateMachine.deterministicEvidence(
            evidenceID: Identifier.constant("gh-583-product-aware-oms-evidence"),
            spotOrderIntent: spotOrderIntent,
            perpetualOrderIntent: perpetualOrderIntent,
            replayedAt: evaluatedAt.addingTimeInterval(60)
        )

        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertTrue(evidence.spotLifecyclePasses)
        XCTAssertTrue(evidence.perpetualLifecyclePasses)
        XCTAssertTrue(evidence.illegalTransitionGuarded)
        XCTAssertTrue(evidence.replayRestoresOrderState)
        XCTAssertEqual(evidence.productTypesCovered, Set(ProductType.allCases))
        XCTAssertEqual(evidence.statesCovered, Set(ReleaseV020ProductAwareOMSOrderState.allCases))
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionOMSRuntimeEnabledByDefault)
        XCTAssertFalse(evidence.callsExecutionClient)
        XCTAssertFalse(evidence.submitsRealOrder)

        let spotFilledLog = try XCTUnwrap(evidence.eventLogs.first { $0.path == .spotFilled })
        XCTAssertEqual(spotFilledLog.orderIntent.instrument.productType, .spot)
        XCTAssertEqual(spotFilledLog.terminalState, .filled)
        XCTAssertTrue(spotFilledLog.eventLogBoundaryHeld)

        let perpetualCancelledLog = try XCTUnwrap(evidence.eventLogs.first { $0.path == .perpetualCancelled })
        XCTAssertEqual(perpetualCancelledLog.orderIntent.instrument.productType, .usdsPerpetual)
        XCTAssertEqual(perpetualCancelledLog.terminalState, .cancelled)
        XCTAssertTrue(perpetualCancelledLog.eventLogBoundaryHeld)

        for replay in evidence.replayResults {
            let sourceLog = try XCTUnwrap(evidence.eventLogs.first { $0.eventLogID == replay.sourceEventLogID })
            XCTAssertEqual(replay.restoredState, sourceLog.terminalState)
            XCTAssertEqual(replay.restoredFromTransitionCount, sourceLog.transitions.count)
            XCTAssertTrue(replay.replayBoundaryHeld)
        }

        XCTAssertThrowsError(
            try ReleaseV020ProductAwareOMSTransition(
                transitionID: Identifier.constant("unsafe-gh-583-transition"),
                orderID: Identifier.constant("unsafe-gh-583-order"),
                sourceOrderIntentID: spotOrderIntent.orderIntentID,
                instrument: spot,
                fromState: .submitted,
                trigger: .orderIntentAccepted,
                toState: .accepted,
                sequence: 999
            )
        ) { error in
            guard case let CoreError.liveTradingBoundaryContractMismatch(field, _, _) = error else {
                XCTFail("unexpected error: \(error)")
                return
            }
            XCTAssertEqual(field, "releaseV020ProductAwareOMS.transition")
        }

        XCTAssertThrowsError(
            try ReleaseV020ProductAwareOMSStateMachine(
                stateMachineID: Identifier.constant("unsafe-gh-583-state-machine"),
                callsExecutionClient: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV020ProductAwareOMS.callsExecutionClient")
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-583`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-PRODUCT-AWARE-OMS-STATE-MACHINE"))
        XCTAssertTrue(validationPlan.contains("GH-583 Release v0.2.0 Product-aware OMS State Machine Validation"))
        XCTAssertTrue(domainContext.contains("GH-583 Product-aware OMS State Machine Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Product-aware OMS state machine anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-583 / V020-21 | Product-aware OMS state machine covers Spot/Perp lifecycle and replay"
            )
        )
    }

    func testGH584BinanceSpotExecutionClientAdapterProducesDryRunAndTestnetMapping() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        XCTAssertTrue(executionClientTarget.contains("path: \"Sources/ExecutionClient\""))
        XCTAssertFalse(executionClientTarget.contains("\"ExecutionEngine\""))

        let adapter = try ReleaseV020BinanceSpotExecutionClientAdapter.deterministicFixture()
        let evidence = try adapter.deterministicAdapterEvidence()

        XCTAssertTrue(adapter.adapterBoundaryHeld)
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertTrue(evidence.capabilityMatrix.matrixHeld)
        XCTAssertTrue(evidence.credentialGate.gateHeld)
        XCTAssertTrue(evidence.omsHandoff.handoffBoundaryHeld)
        XCTAssertEqual(evidence.omsHandoff.sourceIssueID.rawValue, "GH-583")
        XCTAssertEqual(evidence.omsHandoff.instrument.productType, .spot)
        XCTAssertEqual(evidence.omsHandoff.eventStream.rawValue, "execution-oms-local")
        XCTAssertTrue(evidence.dryRunEvidenceComplete)
        XCTAssertTrue(evidence.testnetEvidenceGateHeld)
        XCTAssertTrue(evidence.productionRejectedByDefault)
        XCTAssertFalse(evidence.productionEndpointEnabledByDefault)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionSecretReadEnabledByDefault)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.realOrderSubmitted)
        XCTAssertFalse(evidence.realOrderCanceled)
        XCTAssertFalse(evidence.realOrderReplaced)
        XCTAssertFalse(evidence.liveCommandSurfaceTouched)

        let previews = Dictionary(uniqueKeysWithValues: evidence.dryRunPreviews.map { ($0.commandKind, $0) })
        let requests = Dictionary(uniqueKeysWithValues: evidence.testnetRequests.map { ($0.commandKind, $0) })
        let acknowledgements = Dictionary(uniqueKeysWithValues: evidence.acknowledgements.map { ($0.commandKind, $0) })
        XCTAssertEqual(Set(previews.keys), Set(ReleaseV020BinanceSpotExecutionClientCommandKind.allCases))
        XCTAssertEqual(Set(requests.keys), Set(ReleaseV020BinanceSpotExecutionClientCommandKind.allCases))
        XCTAssertEqual(Set(acknowledgements.keys), Set(ReleaseV020BinanceSpotExecutionClientCommandKind.allCases))

        let expectedQueryItemNames: [ReleaseV020BinanceSpotExecutionClientCommandKind: [String]] = [
            .submit: ["symbol", "side", "type", "timeInForce", "quantity", "price", "newClientOrderId", "recvWindow", "timestamp"],
            .cancel: ["symbol", "origClientOrderId", "newClientOrderId", "recvWindow", "timestamp"],
            .replace: [
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
                "timestamp",
            ],
        ]
        let expectedEndpointPaths: [ReleaseV020BinanceSpotExecutionClientCommandKind: String] = [
            .submit: "/api/v3/order",
            .cancel: "/api/v3/order",
            .replace: "/api/v3/order/cancelReplace",
        ]
        let expectedMethods: [ReleaseV020BinanceSpotExecutionClientCommandKind: ReleaseV020BinanceSpotExecutionClientHTTPMethod] = [
            .submit: .post,
            .cancel: .delete,
            .replace: .post,
        ]

        for kind in ReleaseV020BinanceSpotExecutionClientCommandKind.allCases {
            let preview = try XCTUnwrap(previews[kind])
            let request = try XCTUnwrap(requests[kind])
            let acknowledgement = try XCTUnwrap(acknowledgements[kind])

            XCTAssertTrue(preview.previewBoundaryHeld)
            XCTAssertEqual(preview.mode, .dryRun)
            XCTAssertEqual(preview.baseURL.host?.lowercased(), "testnet.binance.vision")
            XCTAssertEqual(preview.method, expectedMethods[kind])
            XCTAssertEqual(preview.endpointPath, expectedEndpointPaths[kind])
            XCTAssertEqual(preview.queryItems.map(\.name), expectedQueryItemNames[kind])
            XCTAssertFalse(preview.networkCallPerformed)
            XCTAssertFalse(preview.signatureValueExposed)
            XCTAssertFalse(preview.productionEndpointTouched)
            XCTAssertFalse(preview.productionTradingEnabledByDefault)

            XCTAssertTrue(request.requestMappingHeld)
            XCTAssertEqual(request.mode, .testnet)
            XCTAssertEqual(request.baseURL.host?.lowercased(), "testnet.binance.vision")
            XCTAssertEqual(request.method, expectedMethods[kind])
            XCTAssertEqual(request.endpointPath, expectedEndpointPaths[kind])
            XCTAssertEqual(request.queryItems.map(\.name), expectedQueryItemNames[kind])
            XCTAssertFalse(request.signatureValueExposed)
            XCTAssertFalse(request.productionEndpointTouched)
            XCTAssertFalse(request.productionSecretRead)
            XCTAssertFalse(request.brokerGatewayTouched)
            XCTAssertFalse(request.liveCommandSurfaceTouched)

            XCTAssertTrue(acknowledgement.ackBoundaryHeld)
            XCTAssertEqual(acknowledgement.mode, .testnet)
            XCTAssertEqual(acknowledgement.requestID, request.requestID)
            XCTAssertEqual(acknowledgement.commandKind, kind)
            XCTAssertFalse(acknowledgement.productionEndpointTouched)
            XCTAssertFalse(acknowledgement.productionOrderTouched)
            XCTAssertFalse(acknowledgement.brokerGatewayTouched)
        }

        XCTAssertThrowsError(
            try ReleaseV020BinanceSpotExecutionClientAdapter(
                testnetMode: .production
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020BinanceSpotExecutionClient.productionEnvironment"
                )
            )
        }

        XCTAssertThrowsError(
            try ReleaseV020BinanceSpotExecutionClientQueryItem(
                name: "signature",
                value: "redacted"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020BinanceSpotExecutionClient.signatureValue"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-584`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-BINANCE-SPOT-EXECUTIONCLIENT-ADAPTER"))
        XCTAssertTrue(validationPlan.contains("GH-584 Release v0.2.0 Binance Spot ExecutionClient Adapter Validation"))
        XCTAssertTrue(domainContext.contains("GH-584 Binance Spot ExecutionClient Adapter Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Binance Spot ExecutionClient adapter anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-584 / V020-22 | Binance Spot ExecutionClient adapter submit / cancel / replace mapping"
            )
        )
    }

    func testGH585BinanceUSDMPerpExecutionClientAdapterProducesPositionSideReduceOnlyMapping() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        XCTAssertTrue(executionClientTarget.contains("path: \"Sources/ExecutionClient\""))
        XCTAssertFalse(executionClientTarget.contains("\"ExecutionEngine\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ReleaseV020BinanceUSDMPerpExecutionClientAdapter.swift"
                ).path
            )
        )

        let adapter = try ReleaseV020BinanceUSDMPerpExecutionClientAdapter.deterministicFixture()
        let evidence = try adapter.deterministicAdapterEvidence()

        XCTAssertTrue(adapter.adapterBoundaryHeld)
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertTrue(evidence.capabilityMatrix.matrixHeld)
        XCTAssertTrue(evidence.credentialGate.gateHeld)
        XCTAssertTrue(evidence.omsHandoff.handoffBoundaryHeld)
        XCTAssertEqual(evidence.omsHandoff.sourceIssueID.rawValue, "GH-583")
        XCTAssertEqual(evidence.omsHandoff.instrument.productType, .usdsPerpetual)
        XCTAssertEqual(evidence.omsHandoff.eventStream.rawValue, "execution-oms-local")
        XCTAssertEqual(evidence.omsHandoff.positionSide, .long)
        XCTAssertTrue(evidence.omsHandoff.reduceOnly)
        XCTAssertEqual(evidence.omsHandoff.side, "SELL")
        XCTAssertEqual(evidence.omsHandoff.action, "reduceOnlyCloseLong")
        XCTAssertTrue(evidence.dryRunEvidenceComplete)
        XCTAssertTrue(evidence.testnetEvidenceGateHeld)
        XCTAssertTrue(evidence.positionSideReduceOnlyMappingHeld)
        XCTAssertTrue(evidence.productionRejectedByDefault)
        XCTAssertFalse(evidence.productionEndpointEnabledByDefault)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionSecretReadEnabledByDefault)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.realOrderSubmitted)
        XCTAssertFalse(evidence.capabilityMatrix.realOrderCanceled)
        XCTAssertFalse(evidence.capabilityMatrix.realOrderReplaced)
        XCTAssertFalse(evidence.liveCommandSurfaceTouched)
        XCTAssertFalse(adapter.bypassesOMS)
        XCTAssertFalse(adapter.bypassesKillSwitch)
        XCTAssertFalse(adapter.bypassesNoTradeGate)
        XCTAssertFalse(adapter.executesLeverageAction)
        XCTAssertFalse(adapter.executesMarginAction)

        let previews = Dictionary(uniqueKeysWithValues: evidence.dryRunPreviews.map { ($0.commandKind, $0) })
        let requests = Dictionary(uniqueKeysWithValues: evidence.testnetRequests.map { ($0.commandKind, $0) })
        let acknowledgements = Dictionary(uniqueKeysWithValues: evidence.acknowledgements.map { ($0.commandKind, $0) })
        XCTAssertEqual(Set(previews.keys), Set(ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases))
        XCTAssertEqual(Set(requests.keys), Set(ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases))
        XCTAssertEqual(Set(acknowledgements.keys), Set(ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases))

        let expectedQueryItemNames: [ReleaseV020BinanceUSDMPerpExecutionClientCommandKind: [String]] = [
            .submit: [
                "symbol",
                "side",
                "positionSide",
                "type",
                "timeInForce",
                "quantity",
                "price",
                "reduceOnly",
                "newClientOrderId",
                "recvWindow",
                "timestamp",
            ],
            .cancel: ["symbol", "origClientOrderId", "recvWindow", "timestamp"],
            .replace: [
                "symbol",
                "side",
                "positionSide",
                "quantity",
                "price",
                "reduceOnly",
                "origClientOrderId",
                "newClientOrderId",
                "recvWindow",
                "timestamp",
            ],
        ]
        let expectedMethods: [ReleaseV020BinanceUSDMPerpExecutionClientCommandKind: ReleaseV020BinanceUSDMPerpExecutionClientHTTPMethod] = [
            .submit: .post,
            .cancel: .delete,
            .replace: .put,
        ]

        for kind in ReleaseV020BinanceUSDMPerpExecutionClientCommandKind.allCases {
            let preview = try XCTUnwrap(previews[kind])
            let request = try XCTUnwrap(requests[kind])
            let acknowledgement = try XCTUnwrap(acknowledgements[kind])

            XCTAssertTrue(preview.mappingBoundaryHeld)
            XCTAssertEqual(preview.mode, .dryRun)
            XCTAssertEqual(preview.baseURL.host?.lowercased(), "testnet.binancefuture.com")
            XCTAssertEqual(preview.method, expectedMethods[kind])
            XCTAssertEqual(preview.endpointPath, "/fapi/v1/order")
            XCTAssertEqual(preview.queryItems.map(\.name), expectedQueryItemNames[kind])
            XCTAssertEqual(preview.positionSide, .long)
            XCTAssertTrue(preview.reduceOnly)
            XCTAssertFalse(preview.networkCallPerformed)
            XCTAssertFalse(preview.signatureValueExposed)
            XCTAssertFalse(preview.productionEndpointTouched)
            XCTAssertFalse(preview.productionSecretRead)
            XCTAssertFalse(preview.brokerGatewayTouched)

            XCTAssertTrue(request.mappingBoundaryHeld)
            XCTAssertEqual(request.mode, .testnet)
            XCTAssertEqual(request.baseURL.host?.lowercased(), "testnet.binancefuture.com")
            XCTAssertEqual(request.method, expectedMethods[kind])
            XCTAssertEqual(request.endpointPath, "/fapi/v1/order")
            XCTAssertEqual(request.queryItems.map(\.name), expectedQueryItemNames[kind])
            XCTAssertEqual(request.positionSide, .long)
            XCTAssertTrue(request.reduceOnly)
            XCTAssertFalse(request.networkCallPerformed)
            XCTAssertFalse(request.signatureValueExposed)
            XCTAssertFalse(request.productionEndpointTouched)
            XCTAssertFalse(request.productionSecretRead)
            XCTAssertFalse(request.brokerGatewayTouched)
            XCTAssertFalse(request.liveCommandSurfaceTouched)

            XCTAssertTrue(acknowledgement.ackBoundaryHeld)
            XCTAssertEqual(acknowledgement.mode, .testnet)
            XCTAssertEqual(acknowledgement.requestID, request.mappingID)
            XCTAssertEqual(acknowledgement.commandKind, kind)
            XCTAssertFalse(acknowledgement.productionEndpointTouched)
            XCTAssertFalse(acknowledgement.productionOrderTouched)
            XCTAssertFalse(acknowledgement.brokerGatewayTouched)
        }

        XCTAssertThrowsError(
            try ReleaseV020BinanceUSDMPerpExecutionClientAdapter(
                testnetMode: .production
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020BinanceUSDMPerpExecutionClient.productionEnvironment"
                )
            )
        }

        XCTAssertThrowsError(
            try ReleaseV020BinanceUSDMPerpExecutionClientQueryItem(
                name: "signature",
                value: "redacted"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020BinanceUSDMPerpExecutionClient.signatureValue"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-585`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-BINANCE-USDM-PERP-EXECUTIONCLIENT-ADAPTER"))
        XCTAssertTrue(validationPlan.contains("GH-585 Release v0.2.0 Binance USD-M Perpetual ExecutionClient Adapter Validation"))
        XCTAssertTrue(domainContext.contains("GH-585 Binance USD-M Perpetual ExecutionClient Adapter Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Binance USD-M Perpetual ExecutionClient adapter anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-585 / V020-23 | Binance USD-M Perpetual ExecutionClient adapter submit / cancel / replace mapping"
            )
        )
    }

    func testGH586BinanceExecutionReportParserMapsSpotPerpBrokerFillAndPositionUpdates() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let executionClientTarget = try packageTargetBlock(named: "ExecutionClient", packageSource: packageSource)
        XCTAssertTrue(executionClientTarget.contains("path: \"Sources/ExecutionClient\""))
        XCTAssertFalse(executionClientTarget.contains("\"ExecutionEngine\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionClient/FutureGate/ReleaseV020BinanceExecutionReportBrokerFillParser.swift"
                ).path
            )
        )

        let parser = try ReleaseV020BinanceExecutionReportParser.deterministicFixture()
        XCTAssertTrue(parser.parserBoundaryHeld)
        XCTAssertEqual(parser.issueID.rawValue, "GH-586")
        XCTAssertEqual(parser.upstreamIssueIDs.map(\.rawValue), ["GH-584", "GH-585"])
        XCTAssertTrue(parser.spotAdapterEvidence.evidenceBoundaryHeld)
        XCTAssertTrue(parser.perpAdapterEvidence.evidenceBoundaryHeld)
        XCTAssertFalse(parser.productionParserEnabledByDefault)
        XCTAssertFalse(parser.productionTradingEnabledByDefault)
        XCTAssertFalse(parser.productionPayloadInterpreted)
        XCTAssertFalse(parser.brokerGatewayTouched)
        XCTAssertFalse(parser.reconciliationProduced)
        XCTAssertFalse(parser.portfolioRuntimeUpdated)
        XCTAssertFalse(parser.dashboardRawPayloadExposed)
        XCTAssertFalse(parser.liveCommandSurfaceTouched)

        for anchor in [
            "GH-586-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER",
            "GH-586-SPOT-BROKER-FILL-PARSER",
            "GH-586-PERP-BROKER-FILL-PARSER",
            "GH-586-NORMALIZED-BROKER-FILL",
            "GH-586-PERP-POSITION-UPDATE",
            "GH-586-INVALID-PAYLOAD-BLOCKED",
            "GH-586-RAW-PAYLOAD-NOT-EXPOSED-TO-DASHBOARD",
            "GH-586-PRODUCTION-PARSER-DISABLED",
            "TVM-RELEASE-V020-EXECUTION-REPORT-BROKER-FILL-PARSER",
        ] {
            XCTAssertTrue(parser.validationAnchors.contains(anchor), anchor)
        }

        let evidence = try parser.deterministicParserEvidence()
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(Set(evidence.parseResults.map(\.brokerFill.reportKind)), Set(ReleaseV020BinanceExecutionReportKind.allCases))
        XCTAssertEqual(evidence.parseResults.map(\.brokerFill.replaySequence), [1, 2, 3, 4])
        XCTAssertTrue(evidence.spotBrokerFillParserComplete)
        XCTAssertTrue(evidence.perpBrokerFillParserComplete)
        XCTAssertTrue(evidence.perpPositionUpdateEvidenceComplete)
        XCTAssertTrue(evidence.invalidPayloadBlockedEvidenceComplete)
        XCTAssertTrue(evidence.rawPayloadNotExposedToDashboard)
        XCTAssertTrue(evidence.productionParserDisabled)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionPayloadInterpreted)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.reconciliationProduced)
        XCTAssertFalse(evidence.portfolioRuntimeUpdated)
        XCTAssertFalse(evidence.dashboardRawPayloadExposed)

        let spotResults = evidence.parseResults.filter { $0.brokerFill.instrument.productType == .spot }
        XCTAssertEqual(Set(spotResults.map(\.brokerFill.reportKind)), [.spotFill, .spotPartialFill])
        XCTAssertTrue(spotResults.allSatisfy(\.resultBoundaryHeld))
        XCTAssertTrue(spotResults.allSatisfy { $0.positionUpdate == nil })
        XCTAssertTrue(spotResults.allSatisfy { $0.brokerFill.sourceAdapterIssueID.rawValue == "GH-584" })

        let perpResults = evidence.parseResults.filter { $0.brokerFill.instrument.productType == .usdsPerpetual }
        XCTAssertEqual(Set(perpResults.map(\.brokerFill.reportKind)), [.perpFill, .perpPartialFill])
        XCTAssertTrue(perpResults.allSatisfy(\.resultBoundaryHeld))
        XCTAssertTrue(perpResults.allSatisfy { $0.positionUpdate?.positionUpdateBoundaryHeld == true })
        XCTAssertTrue(perpResults.allSatisfy { $0.brokerFill.sourceAdapterIssueID.rawValue == "GH-585" })
        XCTAssertTrue(perpResults.allSatisfy { $0.brokerFill.positionSide == .long })
        XCTAssertTrue(perpResults.allSatisfy { $0.brokerFill.reduceOnly })
        XCTAssertTrue(perpResults.allSatisfy { $0.positionUpdate?.accountEndpointRead == false })
        XCTAssertTrue(perpResults.allSatisfy { $0.positionUpdate?.brokerPositionSynced == false })
        XCTAssertTrue(perpResults.allSatisfy { $0.positionUpdate?.leverageActionExecuted == false })
        XCTAssertTrue(perpResults.allSatisfy { $0.positionUpdate?.marginActionExecuted == false })
        XCTAssertTrue(perpResults.allSatisfy { $0.positionUpdate?.portfolioRuntimeUpdated == false })

        let perpFull = try XCTUnwrap(perpResults.first { $0.brokerFill.reportKind == .perpFill })
        let perpFullUpdate = try XCTUnwrap(perpFull.positionUpdate)
        XCTAssertEqual(perpFullUpdate.previousPositionQuantity.rawValue, 0.25)
        XCTAssertEqual(perpFullUpdate.fillQuantity.rawValue, 0.25)
        XCTAssertEqual(perpFullUpdate.resultingPositionQuantity.rawValue, 0)

        let perpPartial = try XCTUnwrap(perpResults.first { $0.brokerFill.reportKind == .perpPartialFill })
        let perpPartialUpdate = try XCTUnwrap(perpPartial.positionUpdate)
        XCTAssertEqual(perpPartialUpdate.previousPositionQuantity.rawValue, 0.25)
        XCTAssertEqual(perpPartialUpdate.fillQuantity.rawValue, 0.10)
        XCTAssertEqual(perpPartialUpdate.resultingPositionQuantity.rawValue, 0.15, accuracy: 0.000_000_01)

        XCTAssertTrue(evidence.parseResults.allSatisfy { $0.brokerFill.fillBoundaryHeld })
        XCTAssertTrue(evidence.parseResults.allSatisfy { $0.brokerFill.dashboardReadModelSafe })
        XCTAssertTrue(evidence.parseResults.allSatisfy { $0.brokerFill.rawPayloadExposedToDashboard == false })
        XCTAssertTrue(evidence.parseResults.allSatisfy { $0.brokerFill.productionPayloadInterpreted == false })
        XCTAssertTrue(evidence.parseResults.allSatisfy { $0.brokerFill.brokerGatewayTouched == false })
        XCTAssertTrue(evidence.parseResults.allSatisfy { $0.brokerFill.reconciliationProduced == false })
        XCTAssertTrue(evidence.parseResults.allSatisfy { $0.brokerFill.portfolioUpdated == false })
        XCTAssertTrue(evidence.parseResults.allSatisfy { $0.brokerFill.liveCommandSurfaceTouched == false })

        XCTAssertEqual(
            Set(evidence.invalidPayloads.map(\.reason)),
            [.productionRawPayload, .unsupportedExecutionStatus, .rawPayloadExposureAttempt]
        )
        XCTAssertTrue(evidence.invalidPayloads.allSatisfy(\.invalidEvidenceBoundaryHeld))
        XCTAssertTrue(evidence.invalidPayloads.allSatisfy { $0.brokerFillProduced == false })
        XCTAssertTrue(evidence.invalidPayloads.allSatisfy { $0.positionUpdateProduced == false })
        XCTAssertTrue(evidence.invalidPayloads.allSatisfy { $0.rawPayloadRetained == false })
        XCTAssertTrue(evidence.invalidPayloads.allSatisfy { $0.rawPayloadExposedToDashboard == false })

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            ReleaseV020BinanceExecutionReportParserEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)

        let spotRequest = try XCTUnwrap(parser.spotAdapterEvidence.testnetRequests.first { $0.commandKind == .submit })
        let spotAck = try XCTUnwrap(parser.spotAdapterEvidence.acknowledgements.first { $0.commandKind == .submit })
        XCTAssertThrowsError(
            try ReleaseV020BinanceExecutionReportFixture(
                reportID: Identifier.constant("unsafe-gh-586-production-raw-report"),
                sourceAdapterIssueID: Identifier.constant("GH-584"),
                sourceKind: .productionRawPayload,
                reportKind: .spotFill,
                sourceCommandKind: "submit",
                sourceCommandRequestID: spotRequest.requestID,
                sourceCommandAckID: spotAck.ackID,
                sourceOrderIntentID: spotRequest.sourceOrderIntentID,
                sourceEventLogID: spotRequest.sourceEventLogID,
                sourceOMSOrderID: spotRequest.sourceOMSOrderID,
                clientOrderID: spotRequest.clientOrderID,
                instrument: InstrumentIdentity.binance(productType: .spot, symbol: Symbol.constant(spotRequest.symbol)),
                side: "BUY",
                cumulativeFilledQuantity: try Quantity(0.01, field: "gh586UnsafeCumulative"),
                lastExecutedQuantity: try Quantity(0.01, field: "gh586UnsafeLast"),
                remainingQuantity: try Quantity(0, field: "gh586UnsafeRemaining"),
                lastExecutedPrice: try Price(42_120.70, field: "gh586UnsafePrice"),
                commissionAsset: "USDT",
                commissionAmount: "0.000010",
                replaySequence: 1,
                rawPayloadDigest: "sha256:unsafe-gh-586-production-report"
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV020ExecutionReport.productionRawPayload")
            )
        }

        XCTAssertThrowsError(
            try ReleaseV020BinanceExecutionReportParser(
                productionParserEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV020ExecutionReport.productionParserEnabledByDefault")
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-586`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-EXECUTION-REPORT-BROKER-FILL-PARSER"))
        XCTAssertTrue(validationPlan.contains("GH-586 Release v0.2.0 Execution Report Broker Fill Parser Validation"))
        XCTAssertTrue(domainContext.contains("GH-586 Execution Report Broker Fill Parser Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 execution report broker fill parser anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-586 / V020-24 | Spot / Perp execution report and broker fill parser"
            )
        )
    }

    func testGH587SpotPortfolioProjectionUpdatesBalancePositionPnLAndStrategyAttribution() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        XCTAssertTrue(executionEngineTarget.contains("\"Portfolio\""))
        XCTAssertTrue(executionEngineTarget.contains("\"ExecutionClient\""))
        XCTAssertFalse(executionEngineTarget.contains("\"DataClient\""))

        let portfolioTarget = try packageTargetBlock(named: "Portfolio", packageSource: packageSource)
        XCTAssertFalse(portfolioTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/ReleaseV020SpotPortfolioProjection.swift"
                ).path
            )
        )

        let projection = try ReleaseV020SpotPortfolioProjection.deterministicFixture()
        XCTAssertTrue(projection.projectionBoundaryHeld)
        XCTAssertEqual(projection.issueID.rawValue, "GH-587")
        XCTAssertTrue(projection.input.inputBoundaryHeld)
        XCTAssertEqual(projection.input.parserEvidence.issueID.rawValue, "GH-586")
        XCTAssertEqual(projection.input.spotBrokerFills.map(\.reportKind), [.spotFill, .spotPartialFill])
        XCTAssertTrue(projection.input.spotBrokerFills.allSatisfy { $0.instrument.productType == .spot })
        XCTAssertTrue(projection.input.spotBrokerFills.allSatisfy { $0.sourceAdapterIssueID.rawValue == "GH-584" })
        XCTAssertFalse(projection.productionTradingEnabledByDefault)
        XCTAssertFalse(projection.productionAccountEndpointRead)
        XCTAssertFalse(projection.brokerGatewayTouched)
        XCTAssertFalse(projection.brokerPositionSynced)
        XCTAssertFalse(projection.portfolioRuntimeMutated)
        XCTAssertFalse(projection.liveCommandSurfaceTouched)

        for anchor in [
            "GH-587-SPOT-PORTFOLIO-PROJECTION",
            "GH-587-SPOT-BALANCE-UPDATE",
            "GH-587-SPOT-POSITION-UPDATE",
            "GH-587-SPOT-PNL-PROJECTION",
            "GH-587-STRATEGY-ATTRIBUTION",
            "GH-587-NO-PRODUCTION-ACCOUNT-READ",
            "TVM-RELEASE-V020-SPOT-PORTFOLIO-PROJECTION",
        ] {
            XCTAssertTrue(projection.input.validationAnchors.contains(anchor), anchor)
        }

        let evidence = try projection.deterministicEvidence()
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-587")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-586"])
        XCTAssertEqual(evidence.sourceFillIDs.count, 2)
        XCTAssertTrue(evidence.balancesUpdated)
        XCTAssertTrue(evidence.positionUpdated)
        XCTAssertTrue(evidence.pnlProjected)
        XCTAssertTrue(evidence.strategyAttributionComplete)

        XCTAssertEqual(evidence.balanceProjection.quoteAsset, "USDT")
        XCTAssertEqual(evidence.balanceProjection.startingFreeBalance, 100_000, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.balanceProjection.quoteSpent, 589.7298, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.balanceProjection.commissionPaid, 0.000014, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.balanceProjection.endingFreeBalance, 99_410.270186, accuracy: 0.000_000_01)
        XCTAssertTrue(evidence.balanceProjection.balanceBoundaryHeld)
        XCTAssertFalse(evidence.balanceProjection.readsRealBalance)
        XCTAssertFalse(evidence.balanceProjection.accountEndpointRead)

        XCTAssertEqual(evidence.positionProjection.instrument.productType, .spot)
        XCTAssertEqual(evidence.positionProjection.baseAsset, "BTC")
        XCTAssertEqual(evidence.positionProjection.positionQuantity.rawValue, 0.014, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.positionProjection.averageCost.rawValue, 42_123.55714285714, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.positionProjection.markPrice.rawValue, 42_250.70, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.positionProjection.grossPositionNotional, 591.5098, accuracy: 0.000_000_01)
        XCTAssertTrue(evidence.positionProjection.positionBoundaryHeld)
        XCTAssertFalse(evidence.positionProjection.brokerPositionSynced)
        XCTAssertFalse(evidence.positionProjection.marginOrLeverageTouched)

        XCTAssertEqual(evidence.pnlProjection.realizedPnL, 0, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.pnlProjection.unrealizedPnL, 1.78, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.pnlProjection.netPnL, 1.779986, accuracy: 0.000_000_01)
        XCTAssertTrue(evidence.pnlProjection.pnlBoundaryHeld)
        XCTAssertFalse(evidence.pnlProjection.readsRealPnL)
        XCTAssertFalse(evidence.pnlProjection.brokerReconciliationPerformed)

        XCTAssertEqual(Set(evidence.strategyAttributions.map(\.strategyKind)), Set(ReleaseV020SpotPortfolioProjectionStrategyKind.allCases))
        XCTAssertTrue(evidence.strategyAttributions.allSatisfy(\.attributionBoundaryHeld))
        XCTAssertEqual(
            evidence.strategyAttributions.reduce(0.0) { $0 + $1.attributedQuantity.rawValue },
            evidence.positionProjection.positionQuantity.rawValue,
            accuracy: 0.000_000_01
        )
        XCTAssertEqual(
            evidence.strategyAttributions.reduce(0.0) { $0 + $1.attributedNotional },
            evidence.balanceProjection.quoteSpent,
            accuracy: 0.000_000_01
        )
        XCTAssertEqual(
            evidence.strategyAttributions.reduce(0.0) { $0 + $1.attributedNetPnL },
            evidence.pnlProjection.netPnL,
            accuracy: 0.000_000_01
        )

        XCTAssertTrue(evidence.financialStateProjection.paperOnlyBoundaryHeld)
        XCTAssertEqual(evidence.exposureSnapshot.source, .paperProjection)
        XCTAssertEqual(evidence.exposureSnapshot.grossExposureNotional, evidence.positionProjection.grossPositionNotional)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionAccountEndpointRead)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.brokerPositionSynced)
        XCTAssertFalse(evidence.portfolioRuntimeMutated)
        XCTAssertFalse(evidence.liveCommandSurfaceTouched)

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            ReleaseV020SpotPortfolioProjectionEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)

        let parserEvidence = projection.input.parserEvidence
        XCTAssertThrowsError(
            try ReleaseV020SpotPortfolioProjectionInput(
                parserEvidence: parserEvidence,
                spotBrokerFills: parserEvidence.parseResults.map(\.brokerFill)
            )
        )
        XCTAssertThrowsError(
            try ReleaseV020SpotPortfolioProjection(
                input: projection.input,
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020SpotPortfolioProjection.productionTradingEnabledByDefault"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-587`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-SPOT-PORTFOLIO-PROJECTION"))
        XCTAssertTrue(validationPlan.contains("GH-587 Release v0.2.0 Spot Portfolio Projection Validation"))
        XCTAssertTrue(domainContext.contains("GH-587 Spot Portfolio Projection Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Spot Portfolio projection anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-587 / V020-25 | Spot Portfolio projection from BrokerFill"
            )
        )
    }

    func testGH588PerpetualPortfolioProjectionUpdatesPositionMarginPnLFundingAndAttribution() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        XCTAssertTrue(executionEngineTarget.contains("\"Portfolio\""))
        XCTAssertTrue(executionEngineTarget.contains("\"ExecutionClient\""))
        XCTAssertFalse(executionEngineTarget.contains("\"DataClient\""))

        let portfolioTarget = try packageTargetBlock(named: "Portfolio", packageSource: packageSource)
        XCTAssertFalse(portfolioTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/ReleaseV020PerpetualPortfolioProjection.swift"
                ).path
            )
        )

        let projection = try ReleaseV020PerpetualPortfolioProjection.deterministicFixture()
        XCTAssertTrue(projection.projectionBoundaryHeld)
        XCTAssertEqual(projection.issueID.rawValue, "GH-588")
        XCTAssertTrue(projection.input.inputBoundaryHeld)
        XCTAssertEqual(projection.input.parserEvidence.issueID.rawValue, "GH-586")
        XCTAssertEqual(projection.input.perpParseResults.map(\.brokerFill.reportKind), [.perpFill, .perpPartialFill])
        XCTAssertTrue(projection.input.perpParseResults.allSatisfy { $0.brokerFill.instrument.productType == .usdsPerpetual })
        XCTAssertTrue(projection.input.perpParseResults.allSatisfy { $0.brokerFill.sourceAdapterIssueID.rawValue == "GH-585" })
        XCTAssertTrue(projection.input.perpParseResults.allSatisfy { $0.positionUpdate?.positionUpdateBoundaryHeld == true })
        XCTAssertTrue(projection.input.markPriceReadModel.freshness.isFresh)
        XCTAssertTrue(projection.input.fundingReadModel.freshness.isFresh)
        XCTAssertFalse(projection.productionTradingEnabledByDefault)
        XCTAssertFalse(projection.productionAccountEndpointRead)
        XCTAssertFalse(projection.brokerGatewayTouched)
        XCTAssertFalse(projection.brokerPositionSynced)
        XCTAssertFalse(projection.leverageActionExecuted)
        XCTAssertFalse(projection.marginActionExecuted)
        XCTAssertFalse(projection.portfolioRuntimeMutated)
        XCTAssertFalse(projection.liveCommandSurfaceTouched)

        for anchor in [
            "GH-588-PERPETUAL-PORTFOLIO-PROJECTION",
            "GH-588-PERP-POSITIONAMT-ENTRY-MARK",
            "GH-588-PERP-MARGIN-PROJECTION",
            "GH-588-PERP-PNL-PROJECTION",
            "GH-588-PERP-FUNDING-PROJECTION",
            "GH-588-PERP-STRATEGY-ATTRIBUTION",
            "GH-588-NO-PRODUCTION-ACCOUNT-READ",
            "TVM-RELEASE-V020-PERPETUAL-PORTFOLIO-PROJECTION",
        ] {
            XCTAssertTrue(projection.input.validationAnchors.contains(anchor), anchor)
        }

        let evidence = try projection.deterministicEvidence()
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-588")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-575", "GH-586"])
        XCTAssertEqual(evidence.sourceFillIDs.count, 2)
        XCTAssertEqual(evidence.sourcePositionUpdateIDs.count, 2)
        XCTAssertTrue(evidence.positionUpdated)
        XCTAssertTrue(evidence.marginProjected)
        XCTAssertTrue(evidence.pnlProjected)
        XCTAssertTrue(evidence.fundingProjected)
        XCTAssertTrue(evidence.strategyAttributionComplete)

        XCTAssertEqual(evidence.positionProjection.instrument.productType, .usdsPerpetual)
        XCTAssertEqual(evidence.positionProjection.positionSide, .long)
        XCTAssertEqual(evidence.positionProjection.positionAmt.rawValue, 0.15, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.positionProjection.entryPrice.rawValue, 43_000, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.positionProjection.markPrice.rawValue, 43_120.50, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.positionProjection.positionNotional, 6_468.075, accuracy: 0.000_000_01)
        XCTAssertTrue(evidence.positionProjection.positionBoundaryHeld)
        XCTAssertFalse(evidence.positionProjection.accountEndpointRead)
        XCTAssertFalse(evidence.positionProjection.brokerPositionSynced)
        XCTAssertFalse(evidence.positionProjection.leverageActionExecuted)
        XCTAssertFalse(evidence.positionProjection.marginActionExecuted)

        XCTAssertEqual(evidence.marginProjection.leverage, 5, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.marginProjection.marginRequirement, 1_293.615, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.marginProjection.marginAsset, "USDT")
        XCTAssertTrue(evidence.marginProjection.marginBoundaryHeld)
        XCTAssertFalse(evidence.marginProjection.readsAccountMargin)
        XCTAssertFalse(evidence.marginProjection.marginActionExecuted)

        XCTAssertEqual(evidence.pnlProjection.realizedPnL, 176, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.pnlProjection.unrealizedPnL, 18.075, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.pnlProjection.commissionPaid, 0.000175, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.pnlProjection.fundingPaymentEstimate, 0.6468075, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.pnlProjection.netPnL, 193.4280175, accuracy: 0.000_000_01)
        XCTAssertTrue(evidence.pnlProjection.pnlBoundaryHeld)
        XCTAssertFalse(evidence.pnlProjection.readsRealPnL)
        XCTAssertFalse(evidence.pnlProjection.brokerReconciliationPerformed)

        XCTAssertEqual(evidence.fundingProjection.fundingRate, 0.0001, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.fundingProjection.fundingPaymentEstimate, 0.6468075, accuracy: 0.000_000_01)
        XCTAssertTrue(evidence.fundingProjection.fundingBoundaryHeld)
        XCTAssertFalse(evidence.fundingProjection.fundingSettlementTouched)
        XCTAssertFalse(evidence.fundingProjection.brokerStatementRead)

        XCTAssertEqual(Set(evidence.strategyAttributions.map(\.strategyKind)), Set(ReleaseV020PerpetualPortfolioProjectionStrategyKind.allCases))
        XCTAssertTrue(evidence.strategyAttributions.allSatisfy(\.attributionBoundaryHeld))
        XCTAssertEqual(
            evidence.strategyAttributions.reduce(0.0) { $0 + $1.attributedQuantity.rawValue },
            0.35,
            accuracy: 0.000_000_01
        )
        XCTAssertEqual(
            evidence.strategyAttributions.reduce(0.0) { $0 + $1.attributedNotional },
            15_226,
            accuracy: 0.000_000_01
        )
        XCTAssertEqual(
            evidence.strategyAttributions.reduce(0.0) { $0 + $1.attributedRealizedPnL },
            176,
            accuracy: 0.000_000_01
        )

        XCTAssertTrue(evidence.financialStateProjection.paperOnlyBoundaryHeld)
        XCTAssertEqual(evidence.exposureSnapshot.source, .paperProjection)
        XCTAssertEqual(evidence.exposureSnapshot.grossExposureNotional, evidence.positionProjection.positionNotional)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionAccountEndpointRead)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.brokerPositionSynced)
        XCTAssertFalse(evidence.leverageActionExecuted)
        XCTAssertFalse(evidence.marginActionExecuted)
        XCTAssertFalse(evidence.portfolioRuntimeMutated)
        XCTAssertFalse(evidence.liveCommandSurfaceTouched)

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            ReleaseV020PerpetualPortfolioProjectionEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)

        let parserEvidence = projection.input.parserEvidence
        XCTAssertThrowsError(
            try ReleaseV020PerpetualPortfolioProjectionInput(
                parserEvidence: parserEvidence,
                perpParseResults: parserEvidence.parseResults,
                markPriceReadModel: projection.input.markPriceReadModel,
                fundingReadModel: projection.input.fundingReadModel
            )
        )
        XCTAssertThrowsError(
            try ReleaseV020PerpetualPortfolioProjection(
                input: projection.input,
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020PerpetualPortfolioProjection.productionTradingEnabledByDefault"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-588`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-PERPETUAL-PORTFOLIO-PROJECTION"))
        XCTAssertTrue(validationPlan.contains("GH-588 Release v0.2.0 Perpetual Portfolio Projection Validation"))
        XCTAssertTrue(domainContext.contains("GH-588 Perpetual Portfolio Projection Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Perpetual Portfolio projection anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-588 / V020-26 | Perpetual Portfolio projection from BrokerFill and mark/funding"
            )
        )
    }

    func testGH589AggregatePortfolioAndStrategyAttributionCombinesSpotPerpEvidence() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let executionEngineTarget = try packageTargetBlock(named: "ExecutionEngine", packageSource: packageSource)
        XCTAssertTrue(executionEngineTarget.contains("\"Portfolio\""))
        XCTAssertTrue(executionEngineTarget.contains("\"ExecutionClient\""))
        XCTAssertFalse(executionEngineTarget.contains("\"DataClient\""))

        let portfolioTarget = try packageTargetBlock(named: "Portfolio", packageSource: packageSource)
        XCTAssertFalse(portfolioTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/ExecutionEngine/OMSFutureGate/ReleaseV020AggregatePortfolioAttribution.swift"
                ).path
            )
        )

        let aggregate = try ReleaseV020AggregatePortfolioAttribution.deterministicFixture()
        XCTAssertTrue(aggregate.aggregateBoundaryHeld)
        XCTAssertEqual(aggregate.issueID.rawValue, "GH-589")
        XCTAssertTrue(aggregate.input.inputBoundaryHeld)
        XCTAssertEqual(aggregate.input.spotEvidence.issueID.rawValue, "GH-587")
        XCTAssertEqual(aggregate.input.perpetualEvidence.issueID.rawValue, "GH-588")
        XCTAssertFalse(aggregate.productionTradingEnabledByDefault)
        XCTAssertFalse(aggregate.productionAccountEndpointRead)
        XCTAssertFalse(aggregate.brokerGatewayTouched)
        XCTAssertFalse(aggregate.brokerPositionSynced)
        XCTAssertFalse(aggregate.reconciliationRuntimeExecuted)
        XCTAssertFalse(aggregate.portfolioRuntimeMutated)
        XCTAssertFalse(aggregate.liveCommandSurfaceTouched)

        for anchor in [
            "GH-589-AGGREGATE-PORTFOLIO-ATTRIBUTION",
            "GH-589-SPOT-PERP-EXPOSURE-SUMMARY",
            "GH-589-EMA-RSI-ATTRIBUTION-SEPARATED",
            "GH-589-FUNDING-LIQUIDATION-SUMMARY",
            "GH-589-NO-PRODUCTION-PORTFOLIO-RUNTIME",
            "TVM-RELEASE-V020-AGGREGATE-PORTFOLIO-ATTRIBUTION",
        ] {
            XCTAssertTrue(aggregate.input.validationAnchors.contains(anchor), anchor)
        }

        let evidence = try aggregate.deterministicEvidence()
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-589")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-587", "GH-588"])
        XCTAssertTrue(evidence.aggregateExposureCalculated)
        XCTAssertTrue(evidence.strategyAttributionSeparated)
        XCTAssertTrue(evidence.fundingAndLiquidationSummaryVisible)

        XCTAssertEqual(evidence.exposureSummary.spotInstrument.productType, .spot)
        XCTAssertEqual(evidence.exposureSummary.perpetualInstrument.productType, .usdsPerpetual)
        XCTAssertEqual(evidence.exposureSummary.spotGrossExposureNotional, 591.5098, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.exposureSummary.perpetualGrossExposureNotional, 6_468.075, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.exposureSummary.aggregateGrossExposureNotional, 7_059.5848, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.exposureSummary.spotNetPnL, 1.779986, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.exposureSummary.perpetualNetPnL, 193.4280175, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.exposureSummary.aggregateNetPnL, 195.2080035, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.exposureSummary.marginRequirement, 1_293.615, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.exposureSummary.fundingPaymentEstimate, 0.6468075, accuracy: 0.000_000_01)
        XCTAssertTrue(evidence.exposureSummary.exposureBoundaryHeld)
        XCTAssertFalse(evidence.exposureSummary.productionAccountEndpointRead)
        XCTAssertFalse(evidence.exposureSummary.brokerPositionSynced)
        XCTAssertFalse(evidence.exposureSummary.portfolioRuntimeMutated)

        XCTAssertEqual(
            Set(evidence.strategyAttributionSummaries.map(\.strategyKind)),
            Set(ReleaseV020AggregatePortfolioStrategyKind.allCases)
        )
        XCTAssertTrue(evidence.strategyAttributionSummaries.allSatisfy(\.attributionBoundaryHeld))
        XCTAssertTrue(evidence.strategyAttributionSummaries.allSatisfy { $0.sourceSpotAttributionIDs.isEmpty == false })
        XCTAssertTrue(evidence.strategyAttributionSummaries.allSatisfy { $0.sourcePerpetualAttributionIDs.isEmpty == false })
        XCTAssertEqual(
            evidence.strategyAttributionSummaries.reduce(0.0) { $0 + $1.aggregateAttributedNotional },
            15_815.7298,
            accuracy: 0.000_000_01
        )
        XCTAssertEqual(
            evidence.strategyAttributionSummaries.reduce(0.0) { $0 + $1.aggregateAttributedPnL },
            177.779986,
            accuracy: 0.000_000_01
        )

        XCTAssertEqual(evidence.fundingLiquidationSummary.instrument.productType, .usdsPerpetual)
        XCTAssertEqual(evidence.fundingLiquidationSummary.positionSide, .long)
        XCTAssertEqual(evidence.fundingLiquidationSummary.leverage, 5, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.fundingLiquidationSummary.entryPrice.rawValue, 43_000, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.fundingLiquidationSummary.markPrice.rawValue, 43_120.50, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.fundingLiquidationSummary.fundingRate, 0.0001, accuracy: 0.000_000_01)
        XCTAssertEqual(evidence.fundingLiquidationSummary.fundingPaymentEstimate, 0.6468075, accuracy: 0.000_000_01)
        XCTAssertEqual(
            evidence.fundingLiquidationSummary.deterministicLiquidationReferencePrice.rawValue,
            34_400,
            accuracy: 0.000_000_01
        )
        XCTAssertEqual(evidence.fundingLiquidationSummary.liquidationDistance, 8_720.5, accuracy: 0.000_000_01)
        XCTAssertEqual(
            evidence.fundingLiquidationSummary.liquidationDistanceRatio,
            8_720.5 / 43_120.50,
            accuracy: 0.000_000_01
        )
        XCTAssertTrue(evidence.fundingLiquidationSummary.fundingSummaryVisible)
        XCTAssertTrue(evidence.fundingLiquidationSummary.liquidationSummaryVisible)
        XCTAssertTrue(evidence.fundingLiquidationSummary.summaryBoundaryHeld)
        XCTAssertFalse(evidence.fundingLiquidationSummary.readsBrokerMargin)
        XCTAssertFalse(evidence.fundingLiquidationSummary.brokerStatementRead)
        XCTAssertFalse(evidence.fundingLiquidationSummary.leverageActionExecuted)
        XCTAssertFalse(evidence.fundingLiquidationSummary.marginActionExecuted)

        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionAccountEndpointRead)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.brokerPositionSynced)
        XCTAssertFalse(evidence.reconciliationRuntimeExecuted)
        XCTAssertFalse(evidence.portfolioRuntimeMutated)
        XCTAssertFalse(evidence.liveCommandSurfaceTouched)

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            ReleaseV020AggregatePortfolioAttributionEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)

        XCTAssertThrowsError(
            try ReleaseV020AggregatePortfolioAttributionInput(
                spotEvidence: aggregate.input.spotEvidence,
                perpetualEvidence: aggregate.input.perpetualEvidence,
                brokerPositionSynced: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020AggregatePortfolioAttribution.brokerPositionSynced"
                )
            )
        }
        XCTAssertThrowsError(
            try ReleaseV020AggregatePortfolioAttribution(
                input: aggregate.input,
                productionTradingEnabledByDefault: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020AggregatePortfolioAttribution.productionTradingEnabledByDefault"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-589`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-AGGREGATE-PORTFOLIO-ATTRIBUTION"))
        XCTAssertTrue(validationPlan.contains("GH-589 Release v0.2.0 Aggregate Portfolio Attribution Validation"))
        XCTAssertTrue(domainContext.contains("GH-589 Aggregate Portfolio Attribution Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 aggregate Portfolio attribution anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-589 / V020-27 | Aggregate Portfolio and strategy attribution"
            )
        )
    }

    func testGH590ProductAwareEventStoreSchemaStoresContextRejectsOutOfOrderAndKeepsChecksum() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let databaseTarget = try packageTargetBlock(named: "Database", packageSource: packageSource)
        XCTAssertTrue(databaseTarget.contains("\"DomainModel\""))
        XCTAssertTrue(databaseTarget.contains("\"MessageBus\""))
        XCTAssertTrue(databaseTarget.contains("\"ReleaseV020ProductAwareEventStoreSchema.swift\""))
        XCTAssertFalse(databaseTarget.contains("\"ExecutionClient\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/Database/ReleaseV020ProductAwareEventStoreSchema.swift"
                ).path
            )
        )

        let evidence = try ReleaseV020ProductAwareEventStore.deterministicEvidence()
        XCTAssertTrue(evidence.evidenceBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-590")
        XCTAssertEqual(
            evidence.schemaColumns,
            [
                "sequence",
                "stream",
                "venue",
                "productType",
                "instrumentID",
                "payloadType",
                "previousChecksum",
                "checksum",
                "recordedAt",
            ]
        )
        XCTAssertEqual(evidence.records.map(\.sequence), [1, 2])
        XCTAssertEqual(Set(evidence.records.map(\.venue.rawValue)), ["binance"])
        XCTAssertEqual(Set(evidence.records.map(\.productType)), Set(ProductType.allCases))
        XCTAssertEqual(evidence.records.map(\.instrumentID.rawValue), [
            "binance:spot:BTCUSDT",
            "binance:usdsPerpetual:BTCUSDT",
        ])
        XCTAssertTrue(evidence.records.allSatisfy(\.recordBoundaryHeld))
        XCTAssertEqual(evidence.records[0].previousChecksum, ReleaseV020ProductAwareEventStoreSchema.genesisChecksum)
        XCTAssertEqual(evidence.records[1].previousChecksum, evidence.records[0].checksum)
        XCTAssertNotEqual(evidence.records[0].checksum, evidence.records[1].checksum)
        XCTAssertTrue(evidence.venueProductInstrumentStoredForEveryEvent)
        XCTAssertTrue(evidence.outOfOrderAppendRejected)
        XCTAssertTrue(evidence.checksumStable)
        XCTAssertTrue(evidence.appendOnlySchema)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.rawPayloadStored)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.accountEndpointRead)
        XCTAssertFalse(evidence.liveCommandSurfaceTouched)

        var schema = try ReleaseV020ProductAwareEventStoreSchema()
        for envelope in try ReleaseV020ProductAwareEventStore.deterministicSourceEnvelopes() {
            try schema.append(sourceEnvelope: envelope)
        }
        XCTAssertTrue(schema.schemaBoundaryHeld)
        XCTAssertEqual(schema.storedProductTypes, Set(ProductType.allCases))
        XCTAssertEqual(schema.stableChecksum, schema.recomputedStableChecksum)

        let stream = try MessageBusJournalStreamID("release-v020-event-store")
        let source = try FoundationTargetID("gh-590", field: "releaseV020ProductAwareEventStore.sourceID")
        XCTAssertThrowsError(
            try {
                var rejectedSchema = try ReleaseV020ProductAwareEventStoreSchema()
                try rejectedSchema.append(
                    sourceEnvelope: MessageBusJournalEnvelope(
                        sequence: 2,
                        stream: stream,
                        sourceID: source,
                        payloadType: "gh-590-out-of-order-event",
                        instrumentID: .binance(productType: .spot, symbol: Symbol.constant("BTCUSDT")),
                        recordedAt: Date(timeIntervalSince1970: 1_801_353_600)
                    )
                )
            }()
        ) { error in
            XCTAssertEqual(error as? CoreError, .invalidSequenceRange)
        }
        XCTAssertThrowsError(
            try {
                var rejectedSchema = try ReleaseV020ProductAwareEventStoreSchema()
                try rejectedSchema.append(
                    sourceEnvelope: MessageBusJournalEnvelope(
                        sequence: 1,
                        stream: stream,
                        sourceID: source,
                        payloadType: "gh-590-missing-instrument-event",
                        instrumentID: nil,
                        recordedAt: Date(timeIntervalSince1970: 1_801_353_600)
                    )
                )
            }()
        )

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            ReleaseV020ProductAwareEventStoreSchemaEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)

        XCTAssertTrue(validationMatrix.contains("`GH-590`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-PRODUCT-AWARE-EVENT-STORE-SCHEMA"))
        XCTAssertTrue(validationPlan.contains("GH-590 Release v0.2.0 Product-aware Event Store Schema Validation"))
        XCTAssertTrue(domainContext.contains("GH-590 Product-aware Event Store Schema Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 product-aware Event Store schema anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-590 / V020-28 | Product-aware append-only Event Store schema"
            )
        )
    }

    func testGH592SpotPerpGoldenTraceCatalogCovers15RequiredRunReplayChecksums() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        let databaseTarget = try packageTargetBlock(named: "Database", packageSource: packageSource)
        XCTAssertTrue(databaseTarget.contains("\"ReleaseV020GoldenTraceCatalog.swift\""))
        XCTAssertFalse(databaseTarget.contains("\"ExecutionClient\""))
        XCTAssertFalse(databaseTarget.contains("\"ExecutionEngine\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    "Sources/Database/ReleaseV020GoldenTraceCatalog.swift"
                ).path
            )
        )

        let evidence = try ReleaseV020GoldenTraceCatalog.deterministicEvidence()
        XCTAssertTrue(evidence.catalogBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-592")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-591"])
        XCTAssertEqual(evidence.traceCount, 15)
        XCTAssertEqual(ReleaseV020GoldenTraceKind.allCases.count, 15)
        XCTAssertEqual(evidence.traceKinds, ReleaseV020GoldenTraceKind.allCases)
        XCTAssertEqual(
            evidence.traceIDs.map(\.rawValue),
            ReleaseV020GoldenTraceKind.allCases.map { "gh-592-\($0.rawValue)" }
        )
        XCTAssertEqual(evidence.records.map(\.sequence), Array(1...15))
        XCTAssertEqual(evidence.runChecksums, evidence.replayChecksums)
        XCTAssertEqual(evidence.runChecksums.count, 15)
        XCTAssertEqual(Set(evidence.runChecksums).count, 15)
        XCTAssertTrue(evidence.records.allSatisfy(\.traceBoundaryHeld))
        XCTAssertEqual(Set(evidence.records.flatMap { $0.productTypes }), Set(ProductType.allCases))
        XCTAssertEqual(
            Set(evidence.records.flatMap { $0.strategies }),
            Set(ReleaseV020GoldenTraceStrategy.allCases)
        )
        XCTAssertTrue(evidence.allRequiredTracesPresent)
        XCTAssertTrue(evidence.runReplayChecksumsMatch)
        XCTAssertEqual(evidence.catalogVenue.rawValue, "binance")
        XCTAssertEqual(Set(evidence.catalogProductTypes), Set(ProductType.allCases))
        XCTAssertEqual(Set(evidence.catalogStrategies), Set(ReleaseV020GoldenTraceStrategy.allCases))
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionSecretRead)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.accountEndpointRead)
        XCTAssertFalse(evidence.rawPayloadStored)
        XCTAssertFalse(evidence.rawDatabaseSchemaExposedToDashboard)

        let upstreamIssues = Set(evidence.records.map(\.upstreamIssueID.rawValue))
        for issue in ["GH-573", "GH-574", "GH-575", "GH-569", "GH-570", "GH-577",
                      "GH-578", "GH-579", "GH-580", "GH-581", "GH-582", "GH-586", "GH-591"] {
            XCTAssertTrue(upstreamIssues.contains(issue), issue)
        }

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(ReleaseV020GoldenTraceCatalogEvidence.self, from: encoded)
        XCTAssertEqual(decoded, evidence)

        let spotTrace = try XCTUnwrap(evidence.records.first { $0.kind == .spotMarketDataCache })
        XCTAssertEqual(spotTrace.productTypes, [.spot])
        XCTAssertEqual(spotTrace.strategies, [])
        XCTAssertTrue(spotTrace.runChecksum.hasPrefix("fnv1a64:"))

        let projectionTrace = try XCTUnwrap(evidence.records.first { $0.kind == .eventStoreSQLiteDuckDBProjection })
        XCTAssertEqual(Set(projectionTrace.productTypes), Set(ProductType.allCases))
        XCTAssertEqual(Set(projectionTrace.strategies), Set(ReleaseV020GoldenTraceStrategy.allCases))
        XCTAssertEqual(projectionTrace.upstreamIssueID.rawValue, "GH-591")

        XCTAssertThrowsError(
            try ReleaseV020GoldenTraceRecord(
                traceID: Identifier.constant("unsafe-gh-592-trace"),
                sequence: 1,
                kind: .spotMarketDataCache,
                upstreamIssueID: Identifier.constant("GH-573"),
                productTypes: [.spot],
                strategies: [],
                sourceEvidenceAnchor: "GH-573-BINANCE-SPOT-MARKET-DATA-ACTIVE-PATH",
                runChecksum: "fnv1a64:0000000000000000"
            )
        )
        XCTAssertThrowsError(
            try ReleaseV020GoldenTraceCatalogEvidence(records: Array(evidence.records.dropLast()))
        )

        XCTAssertTrue(validationMatrix.contains("`GH-592`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-SPOT-PERP-GOLDEN-TRACE-CATALOG"))
        XCTAssertTrue(validationPlan.contains("GH-592 Release v0.2.0 Spot + Perp Golden Trace Catalog Validation"))
        XCTAssertTrue(domainContext.contains("GH-592 Spot + Perp Golden Trace Catalog Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Spot + Perp golden trace catalog anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-592 / V020-30 | Spot + Perp golden trace catalog"
            )
        )
    }

    func testGH593CLIProductSurfaceRoutesVerifyCommandsThroughCommandGateway() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )
        let cliMainSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/MTPROCLI/main.swift"),
            encoding: .utf8
        )

        let databaseTarget = try packageTargetBlock(named: "Database", packageSource: packageSource)
        let persistenceTarget = try packageTargetBlock(named: "Persistence", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)
        let coreTarget = try packageTargetBlock(named: "Core", packageSource: packageSource)
        let cliTarget = try packageTargetBlock(named: "MTPROCLI", packageSource: packageSource)
        let databaseSources = try packageTargetSourcesBlock(targetBlock: databaseTarget)
        let persistenceExcludes = try packageTargetExcludesBlock(targetBlock: persistenceTarget)
        let runtimeExcludes = try packageTargetExcludesBlock(targetBlock: runtimeTarget)
        let coreExcludes = try packageTargetExcludesBlock(targetBlock: coreTarget)

        XCTAssertTrue(packageSource.contains(".executable(name: \"mtpro\", targets: [\"MTPROCLI\"])"))
        XCTAssertTrue(cliTarget.contains("dependencies: [\"Database\"]"))
        XCTAssertTrue(cliTarget.contains("path: \"Sources/MTPROCLI\""))
        XCTAssertTrue(cliTarget.contains("\"main.swift\""))
        XCTAssertFalse(cliTarget.contains("\"ExecutionClient\""))
        XCTAssertFalse(cliTarget.contains("\"ExecutionEngine\""))
        XCTAssertFalse(cliTarget.contains("\"RiskEngine\""))
        XCTAssertTrue(databaseSources.contains("\"ReleaseV020CLIProductSurface.swift\""))
        XCTAssertTrue(persistenceExcludes.contains("\"ReleaseV020CLIProductSurface.swift\""))
        XCTAssertTrue(runtimeExcludes.contains("\"Database/ReleaseV020CLIProductSurface.swift\""))
        XCTAssertTrue(coreExcludes.contains("\"MTPROCLI\""))
        XCTAssertTrue(runtimeExcludes.contains("\"MTPROCLI\""))
        XCTAssertTrue(cliMainSource.contains("ReleaseV020CLIProductSurface.commandLineOutput"))

        let evidence = try ReleaseV020CLIProductSurface.deterministicEvidence()
        XCTAssertTrue(evidence.surfaceBoundaryHeld)
        XCTAssertEqual(evidence.issueID.rawValue, "GH-593")
        XCTAssertEqual(evidence.upstreamIssueIDs.map(\.rawValue), ["GH-592"])
        XCTAssertEqual(evidence.cliProductName, "mtpro")
        XCTAssertEqual(evidence.executableTargetName, "MTPROCLI")
        XCTAssertEqual(evidence.commandNames, ["spot", "perp", "strategy", "risk", "execution", "verify-fast", "verify-release"])
        XCTAssertEqual(Set(evidence.cliProductTypes), Set(ProductType.allCases))
        XCTAssertEqual(Set(evidence.cliStrategies), Set(ReleaseV020GoldenTraceStrategy.allCases))
        XCTAssertEqual(evidence.cliVenue.rawValue, "binance")
        XCTAssertTrue(evidence.commands.allSatisfy(\.routesThroughCommandGateway))
        XCTAssertTrue(evidence.commands.allSatisfy(\.usesGoldenTraceCatalog))
        XCTAssertTrue(evidence.commands.allSatisfy(\.commandBoundaryHeld))
        XCTAssertTrue(evidence.verifyFastPasses)
        XCTAssertTrue(evidence.verifyReleasePasses)
        XCTAssertTrue(evidence.commandGatewayRequired)
        XCTAssertFalse(evidence.productionTradingEnabledByDefault)
        XCTAssertFalse(evidence.productionSecretRead)
        XCTAssertFalse(evidence.productionEndpointTouched)
        XCTAssertFalse(evidence.brokerGatewayTouched)
        XCTAssertFalse(evidence.accountEndpointRead)
        XCTAssertFalse(evidence.submitsRealOrder)
        XCTAssertFalse(evidence.cancelsRealOrder)
        XCTAssertFalse(evidence.replacesRealOrder)
        XCTAssertFalse(evidence.bypassesCommandGateway)
        XCTAssertFalse(evidence.bypassesRiskEngine)
        XCTAssertFalse(evidence.bypassesExecutionEngine)
        XCTAssertFalse(evidence.bypassesOMS)
        XCTAssertFalse(evidence.bypassesEventStore)
        XCTAssertFalse(evidence.bypassesKillSwitch)
        XCTAssertFalse(evidence.bypassesNoTradeState)

        let verifyFast = try ReleaseV020CLIProductSurface.verify(arguments: ["verify-fast"], evidence: evidence)
        let verifyRelease = try ReleaseV020CLIProductSurface.verify(arguments: ["verify-release"], evidence: evidence)
        XCTAssertTrue(verifyFast.passed)
        XCTAssertTrue(verifyRelease.passed)
        XCTAssertTrue(
            try ReleaseV020CLIProductSurface.commandLineOutput(arguments: ["verify-fast"])
                .contains("mtpro verify-fast pass")
        )
        XCTAssertTrue(
            try ReleaseV020CLIProductSurface.commandLineOutput(arguments: ["verify-release"])
                .contains("mtpro verify-release pass")
        )
        XCTAssertTrue(
            try ReleaseV020CLIProductSurface.commandLineOutput(arguments: ["verify-release"])
                .contains("commandGateway=required")
        )
        XCTAssertTrue(
            try ReleaseV020CLIProductSurface.commandLineOutput(arguments: ["verify-release"])
                .contains("realOrderSubmitCancelReplace=false")
        )

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(ReleaseV020CLIProductSurfaceEvidence.self, from: encoded)
        XCTAssertEqual(decoded, evidence)

        XCTAssertThrowsError(
            try ReleaseV020CLIProductSurface.verify(arguments: ["spot"], evidence: evidence)
        )
        XCTAssertThrowsError(
            try ReleaseV020CLIProductSurfaceEvidence(commands: Array(evidence.commands.dropLast()))
        )
        XCTAssertThrowsError(
            try ReleaseV020CLICommandRecord(
                command: .verifyFast,
                productTypes: ProductType.allCases,
                strategies: ReleaseV020GoldenTraceStrategy.allCases,
                sourceEvidenceAnchor: "unsafe-command-gateway-bypass",
                bypassesCommandGateway: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV020CLIProductSurface.bypassesCommandGateway")
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-593`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-CLI-PRODUCT-SURFACE"))
        XCTAssertTrue(validationPlan.contains("GH-593 Release v0.2.0 CLI Product Surface Validation"))
        XCTAssertTrue(domainContext.contains("GH-593 CLI Product Surface Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 CLI product surface anchor"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-593 / V020-31 | CLI product surface for Spot / Perp / strategy / risk / execution / verify"
            )
        )
    }

    func testGH594DashboardCommandGatewaySurfaceShowsReleasePanelsWithoutProductionCommand() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )
        let releaseGuard = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "checks/automation-readiness.d/release-v0.2.0-boundary.sh"
            ),
            encoding: .utf8
        )
        let dashboardSurfaceSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Sources/Dashboard/Report/ReleaseV020DashboardCommandGatewaySurface.swift"
            ),
            encoding: .utf8
        )

        let dashboardTarget = try packageTargetBlock(named: "Dashboard", packageSource: packageSource)
        XCTAssertTrue(dashboardTarget.contains("\"Report\""))
        XCTAssertFalse(dashboardTarget.contains("\"ExecutionClient\""))
        XCTAssertFalse(dashboardTarget.contains("\"ExecutionEngine\""))
        XCTAssertTrue(dashboardSurfaceSource.contains("GH-594-DASHBOARD-COMMANDGATEWAY-SURFACE"))

        let readModel = ReleaseV020DashboardCommandGatewaySurfaceReadModel()
        XCTAssertTrue(readModel.dashboardSurfaceBoundaryHeld)
        XCTAssertEqual(readModel.dashboardLabels, ["Spot", "Perp", "EMA", "RSI", "Risk", "OMS", "Portfolio"])
        XCTAssertEqual(Set(readModel.productTypesCovered), Set(ProductType.allCases))
        XCTAssertEqual(readModel.strategiesCovered.map(\.rawValue), ["ema", "rsi"])
        XCTAssertTrue(readModel.commandsRouteThroughCommandGateway)
        XCTAssertTrue(readModel.productionCommandDisabledByDefault)
        XCTAssertEqual(
            readModel.validationAnchors,
            ReleaseV020DashboardCommandGatewaySurfaceReadModel.requiredValidationAnchors
        )

        let surface = ReleaseV020DashboardCommandGatewaySurfaceViewModel(readModel: readModel)
        XCTAssertEqual(surface.issueID, "GH-594")
        XCTAssertEqual(surface.matrixID, "TVM-RELEASE-V020-DASHBOARD-COMMANDGATEWAY-SURFACE")
        XCTAssertEqual(surface.panelCount, 7)
        XCTAssertTrue(surface.dashboardShowsRequiredPanels)
        XCTAssertTrue(surface.commandsRouteThroughCommandGateway)
        XCTAssertTrue(surface.commandEntryDefaultNoTrade)
        XCTAssertFalse(surface.productionTradingEnabledByDefault)
        XCTAssertFalse(surface.productionCommandEnabled)
        XCTAssertTrue(surface.commandSurfaceVisible)
        XCTAssertFalse(surface.commandSurfaceEnabled)
        XCTAssertTrue(surface.riskEngineGateRequired)
        XCTAssertTrue(surface.executionEngineGateRequired)
        XCTAssertTrue(surface.omsGateRequired)
        XCTAssertTrue(surface.eventStoreGateRequired)
        XCTAssertTrue(surface.killSwitchGateRequired)
        XCTAssertTrue(surface.noTradeStateRequired)
        XCTAssertTrue(surface.dashboardSurfaceBoundaryHeld)
        XCTAssertTrue(surface.providesCommandSurface)
        XCTAssertFalse(surface.providesTradingButton)
        XCTAssertFalse(surface.providesLiveCommand)
        XCTAssertFalse(surface.exposesOrderForm)
        XCTAssertFalse(surface.exposesSecretEditor)
        XCTAssertFalse(surface.readsSecret)
        XCTAssertFalse(surface.opensProductionEndpoint)
        XCTAssertFalse(surface.connectsBroker)
        XCTAssertFalse(surface.touchesAccountEndpoint)
        XCTAssertFalse(surface.submitsRealOrder)
        XCTAssertFalse(surface.cancelsRealOrder)
        XCTAssertFalse(surface.replacesRealOrder)
        XCTAssertFalse(surface.bypassesCommandGateway)
        XCTAssertFalse(surface.bypassesRiskEngine)
        XCTAssertFalse(surface.bypassesExecutionEngine)
        XCTAssertFalse(surface.bypassesOMS)
        XCTAssertFalse(surface.bypassesEventStore)
        XCTAssertFalse(surface.bypassesKillSwitch)
        XCTAssertFalse(surface.bypassesNoTradeState)
        XCTAssertFalse(surface.authorizesTradingExecution)

        let report = ReportReadModel(releaseV020DashboardCommandGatewaySurface: readModel)
        let dashboard = DashboardViewModel(
            readModel: DashboardReadModel(
                market: MarketReadModel(),
                strategy: StrategyReadModel(),
                backtest: BacktestReadModel(),
                report: report,
                paper: PaperReadModel(),
                risk: RiskReadModel(),
                portfolio: PortfolioReadModel(),
                events: EventTimelineReadModel()
            )
        )
        XCTAssertEqual(dashboard.report.releaseV020DashboardCommandGatewayPanelCount, 7)
        XCTAssertEqual(
            dashboard.report.releaseV020DashboardCommandGatewayPanelLabels,
            ["Spot", "Perp", "EMA", "RSI", "Risk", "OMS", "Portfolio"]
        )
        XCTAssertTrue(dashboard.report.releaseV020DashboardCommandGatewayRoutesThroughGateway)
        XCTAssertTrue(dashboard.report.releaseV020DashboardCommandGatewayProductionDisabled)
        XCTAssertFalse(dashboard.report.releaseV020DashboardCommandGatewaySurfaceEnabled)
        XCTAssertTrue(dashboard.report.releaseV020DashboardCommandGatewayBoundaryHeld)
        XCTAssertFalse(dashboard.report.releaseV020DashboardCommandGatewayAuthorizesTradingExecution)
        XCTAssertFalse(dashboard.report.authorizesTradingExecution)
        XCTAssertTrue(dashboard.viewModelSources.allSatisfy(\.isReadModelOnly))

        let shell = DashboardShellSnapshot(viewModel: dashboard)
        XCTAssertTrue(shell.isReadModelOnly)
        XCTAssertTrue(shell.smokeSummary.contains("releaseV020DashboardSurface=7"))
        let reportSection = try XCTUnwrap(shell.sections.first { $0.section == .report })
        XCTAssertTrue(
            reportSection.metrics.contains(DashboardShellMetric(label: "Release v0.2 dashboard", value: "7"))
        )
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release v0.2 Dashboard required panels: confirmed")
            }
        )
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release v0.2 Dashboard CommandGateway: confirmed")
            }
        )
        XCTAssertTrue(
            reportSection.details.contains {
                $0.contains("Release v0.2 Dashboard production disabled: confirmed")
            }
        )

        XCTAssertThrowsError(
            try ReleaseV020DashboardCommandGatewayPanelViewModel(
                panel: .spot,
                bypassesCommandGateway: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability(
                    "releaseV020DashboardCommandGatewaySurface.bypassesCommandGateway"
                )
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-594`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-DASHBOARD-COMMANDGATEWAY-SURFACE"))
        XCTAssertTrue(validationPlan.contains("GH-594 Release v0.2.0 Dashboard CommandGateway Surface Validation"))
        XCTAssertTrue(domainContext.contains("GH-594 Dashboard CommandGateway Surface Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 Dashboard CommandGateway surface anchor"))
        XCTAssertTrue(releaseGuard.contains("testGH594DashboardCommandGatewaySurfaceShowsReleasePanelsWithoutProductionCommand"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-594 / V020-32 | Dashboard Spot + Perp control surface through CommandGateway"
            )
        )
    }

    func testGH595VerifyFastAndVerifyReleaseCoverFoundationSampleFullAndAllTraces() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )
        let releaseGuard = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "checks/automation-readiness.d/release-v0.2.0-boundary.sh"
            ),
            encoding: .utf8
        )

        let databaseTarget = try packageTargetBlock(named: "Database", packageSource: packageSource)
        let persistenceTarget = try packageTargetBlock(named: "Persistence", packageSource: packageSource)
        let runtimeTarget = try packageTargetBlock(named: "Runtime", packageSource: packageSource)
        let databaseSources = try packageTargetSourcesBlock(targetBlock: databaseTarget)
        let persistenceExcludes = try packageTargetExcludesBlock(targetBlock: persistenceTarget)
        let runtimeExcludes = try packageTargetExcludesBlock(targetBlock: runtimeTarget)
        XCTAssertTrue(databaseSources.contains("\"ReleaseV020VerificationGates.swift\""))
        XCTAssertTrue(persistenceExcludes.contains("\"ReleaseV020VerificationGates.swift\""))
        XCTAssertTrue(runtimeExcludes.contains("\"Database/ReleaseV020VerificationGates.swift\""))

        let gateEvidence = try ReleaseV020VerificationGates.deterministicEvidence()
        XCTAssertTrue(gateEvidence.gateBoundaryHeld)
        XCTAssertEqual(gateEvidence.issueID.rawValue, "GH-595")
        XCTAssertEqual(gateEvidence.upstreamIssueIDs.map(\.rawValue), ["GH-594"])
        XCTAssertEqual(gateEvidence.catalogTraceCount, ReleaseV020GoldenTraceCatalog.requiredTraceCount)
        XCTAssertTrue(gateEvidence.verifyFastPasses)
        XCTAssertTrue(gateEvidence.verifyReleasePasses)
        XCTAssertEqual(gateEvidence.verifyFast.sectionLabels, ["foundation", "sample-traces"])
        XCTAssertEqual(gateEvidence.verifyFast.traceKinds, ReleaseV020VerificationGates.sampleTraceKinds)
        XCTAssertEqual(
            gateEvidence.verifyRelease.sectionLabels,
            ["foundation", "sample-traces", "full-gates", "all-traces"]
        )
        XCTAssertEqual(Set(gateEvidence.verifyRelease.traceKinds), Set(ReleaseV020GoldenTraceKind.allCases))
        XCTAssertEqual(gateEvidence.validationAnchors, ReleaseV020VerificationGates.requiredValidationAnchors)
        XCTAssertFalse(gateEvidence.productionTradingEnabledByDefault)
        XCTAssertFalse(gateEvidence.productionSecretRead)
        XCTAssertFalse(gateEvidence.productionEndpointTouched)
        XCTAssertFalse(gateEvidence.brokerGatewayTouched)
        XCTAssertFalse(gateEvidence.accountEndpointRead)
        XCTAssertFalse(gateEvidence.submitsRealOrder)
        XCTAssertFalse(gateEvidence.cancelsRealOrder)
        XCTAssertFalse(gateEvidence.replacesRealOrder)
        XCTAssertTrue(gateEvidence.verifyFast.commandGatewayRequired)
        XCTAssertTrue(gateEvidence.verifyRelease.commandGatewayRequired)
        XCTAssertTrue(gateEvidence.verifyRelease.eventStoreGateRequired)
        XCTAssertTrue(gateEvidence.verifyRelease.killSwitchGateRequired)
        XCTAssertTrue(gateEvidence.verifyRelease.noTradeStateRequired)

        let verifyFast = try ReleaseV020CLIProductSurface.verify(arguments: ["verify-fast"])
        let verifyRelease = try ReleaseV020CLIProductSurface.verify(arguments: ["verify-release"])
        XCTAssertTrue(verifyFast.passed)
        XCTAssertTrue(verifyRelease.passed)
        XCTAssertEqual(verifyFast.verificationGates, gateEvidence)
        XCTAssertEqual(verifyRelease.verificationGates, gateEvidence)
        let verifyFastOutput = try ReleaseV020CLIProductSurface.commandLineOutput(arguments: ["verify-fast"])
        let verifyReleaseOutput = try ReleaseV020CLIProductSurface.commandLineOutput(arguments: ["verify-release"])
        XCTAssertTrue(verifyFastOutput.contains("mtpro verify-fast pass"))
        XCTAssertTrue(verifyFastOutput.contains("verificationIssue=GH-595"))
        XCTAssertTrue(verifyFastOutput.contains("verifyCoverage=foundation,sample-traces"))
        XCTAssertTrue(verifyFastOutput.contains("verifyTraceCount=6"))
        XCTAssertTrue(verifyReleaseOutput.contains("mtpro verify-release pass"))
        XCTAssertTrue(verifyReleaseOutput.contains("verificationIssue=GH-595"))
        XCTAssertTrue(verifyReleaseOutput.contains("verifyCoverage=foundation,sample-traces,full-gates,all-traces"))
        XCTAssertTrue(verifyReleaseOutput.contains("verifyCatalogTraceCount=15"))
        XCTAssertTrue(verifyReleaseOutput.contains("verifyGateBoundaryHeld=true"))

        XCTAssertThrowsError(
            try ReleaseV020VerificationGateCoverage(
                mode: .verifyFast,
                sections: [.foundation],
                traceKinds: ReleaseV020VerificationGates.sampleTraceKinds,
                sourceEvidenceAnchors: ["GH-595-INCOMPLETE-FAST-GATE"]
            )
        )
        XCTAssertThrowsError(
            try ReleaseV020VerificationGateCoverage(
                mode: .verifyRelease,
                sections: ReleaseV020VerificationGates.requiredSections(for: .verifyRelease),
                traceKinds: ReleaseV020VerificationGates.sampleTraceKinds,
                sourceEvidenceAnchors: ["GH-595-INCOMPLETE-RELEASE-GATE"]
            )
        )
        XCTAssertThrowsError(
            try ReleaseV020VerificationGateCoverage(
                mode: .verifyRelease,
                sections: ReleaseV020VerificationGates.requiredSections(for: .verifyRelease),
                traceKinds: ReleaseV020GoldenTraceKind.allCases,
                sourceEvidenceAnchors: ["GH-595-BYPASS-GATE"],
                bypassesCommandGateway: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("releaseV020VerificationGates.bypassesCommandGateway")
            )
        }

        XCTAssertTrue(validationMatrix.contains("`GH-595`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-VERIFY-FAST-RELEASE-GATES"))
        XCTAssertTrue(validationPlan.contains("GH-595 Release v0.2.0 Verify Fast / Verify Release Gate Validation"))
        XCTAssertTrue(domainContext.contains("GH-595 Verify Fast / Verify Release Gate Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 verify-fast / verify-release gate anchor"))
        XCTAssertTrue(releaseGuard.contains("testGH595VerifyFastAndVerifyReleaseCoverFoundationSampleFullAndAllTraces"))
        XCTAssertTrue(
            releaseContract.contains(
                "GH-595 / V020-33 | verify-fast / verify-release Spot + Perp release gates"
            )
        )
    }

    func testGH596ReleaseV020ClosureDocsRecordCompletedFactsWithoutNextPhaseAuthorization() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        func read(_ relativePath: String) throws -> String {
            try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
        }

        let runbook = try read("docs/operators/release-v0.2.0-operator-runbook.md")
        let stageAudit = try read(
            "docs/audit/mtpro-release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-stage-code-audit.md"
        )
        let readme = try read("README.md")
        let architecture = try read("architecture.md")
        let roadmap = try read("docs/roadmap.md")
        let latestSummary = try read("docs/validation/latest-verification-summary.md")
        let validationMatrix = try read("docs/validation/trading-validation-matrix.md")
        let validationPlan = try read("docs/validation/validation-plan.md")
        let domainContext = try read("docs/domain/context.md")
        let automationReadiness = try read("docs/automation/automation-readiness.md")
        let releaseGuard = try read("checks/automation-readiness.d/release-v0.2.0-boundary.sh")
        let releaseContract = try read(
            "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
        )

        XCTAssertTrue(runbook.contains("GH-596-RELEASE-V020-OPERATOR-RUNBOOK"))
        XCTAssertTrue(runbook.contains("swift run mtpro verify-fast"))
        XCTAssertTrue(runbook.contains("swift run mtpro verify-release"))
        XCTAssertTrue(runbook.contains("DASHBOARD_SMOKE=1 swift run Dashboard"))
        XCTAssertTrue(runbook.contains("productionTradingEnabledByDefault == false"))
        XCTAssertTrue(runbook.contains("No-trade state"))
        XCTAssertTrue(runbook.contains("不授权 production trading"))
        XCTAssertTrue(runbook.contains("不创建下一 Project / Issue"))

        XCTAssertTrue(stageAudit.contains("GH-596-RELEASE-V020-STAGE-CODE-AUDIT"))
        XCTAssertTrue(stageAudit.contains("GitHub fallback queue `#563` 至 `#596`"))
        XCTAssertTrue(stageAudit.contains("`V020-01` 至 `V020-34`"))
        XCTAssertTrue(stageAudit.contains("PR `#597` 至 `#629`"))
        XCTAssertTrue(stageAudit.contains("`checks` SUCCESS"))
        XCTAssertTrue(stageAudit.contains("e71d5c568f7346051e3d924b977bfcdfeb809043"))
        XCTAssertTrue(stageAudit.contains("current #596 closure PR"))
        XCTAssertTrue(stageAudit.contains("TVM-RELEASE-V020-FINAL-STAGE-CODE-AUDIT-ROOT-DOCS"))
        XCTAssertTrue(stageAudit.contains("production trading remains disabled by default"))

        XCTAssertTrue(readme.contains("GH-596-RELEASE-V020-ROOT-DOCS-REFRESH"))
        XCTAssertTrue(readme.contains("Latest completed release construction scope: `MTPRO Release v0.2.0`"))
        XCTAssertTrue(architecture.contains("GH-596-RELEASE-V020-ROOT-DOCS-REFRESH"))
        XCTAssertTrue(architecture.contains("docs/operators/release-v0.2.0-operator-runbook.md"))
        XCTAssertTrue(roadmap.contains("MTPRO Release v0.2.0 | Completed"))
        XCTAssertTrue(roadmap.contains("Project Closure Count: 36 / 36 (100%)"))
        XCTAssertTrue(roadmap.contains("Latest Completed Project：`MTPRO Release v0.2.0`"))
        XCTAssertTrue(latestSummary.contains("GH-596-RELEASE-V020-ROOT-DOCS-REFRESH"))
        XCTAssertTrue(latestSummary.contains("Project Closure Count: 36 / 36"))
        XCTAssertTrue(
            latestSummary.contains(
                "Current maturity statement：`MTPRO Release v0.2.0 Binance Spot + USDⓈ-M Perpetual + EMA/RSI validation complete with production trading disabled by default`"
            )
        )

        XCTAssertTrue(validationMatrix.contains("`GH-596`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-FINAL-STAGE-CODE-AUDIT-ROOT-DOCS"))
        XCTAssertTrue(validationPlan.contains("GH-596 Release v0.2.0 Final Stage Code Audit and Root Docs Refresh Validation"))
        XCTAssertTrue(domainContext.contains("GH-596 Release v0.2.0 Final Closure Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 final Stage Code Audit / Root Docs anchor"))
        XCTAssertTrue(releaseContract.contains("GH-596 / V020-34 | final Stage Code Audit, operator runbook and Root Docs Refresh"))
        XCTAssertTrue(releaseGuard.contains("testGH596ReleaseV020ClosureDocsRecordCompletedFactsWithoutNextPhaseAuthorization"))

        for forbiddenAuthorization in [
            "productionTradingEnabledByDefault == true",
            "productionSecretReadEnabledByDefault == true",
            "productionEndpointEnabledByDefault == true",
            "productionSubmitEnabledByDefault == true",
            "productionCancelEnabledByDefault == true",
            "productionReplaceEnabledByDefault == true",
            "automaticProductionCutoverEnabled == true",
            "nonBinanceVenueEnabled == true",
            "nonSpotProductEnabled == true",
            "nonUSDSPerpetualProductEnabled == true",
            "nonEMARSIStrategyEnabled == true"
        ] {
            XCTAssertFalse(runbook.contains(forbiddenAuthorization))
            XCTAssertFalse(stageAudit.contains(forbiddenAuthorization))
            XCTAssertFalse(readme.contains(forbiddenAuthorization))
            XCTAssertFalse(roadmap.contains(forbiddenAuthorization))
            XCTAssertFalse(latestSummary.contains(forbiddenAuthorization))
        }
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
        XCTAssertTrue(traderStrategiesTarget.contains("\"EMA/EMAProposalRuntime.swift\""))
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

    func testGH564ReleaseV020RootDocsReplaceOldSpotPaperEMABoundaries() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let readme = try String(contentsOf: repositoryRoot.appendingPathComponent("README.md"), encoding: .utf8)
        let architecture = try String(contentsOf: repositoryRoot.appendingPathComponent("architecture.md"), encoding: .utf8)
        let roadmap = try String(contentsOf: repositoryRoot.appendingPathComponent("docs/roadmap.md"), encoding: .utf8)
        let latestSummary = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/validation/latest-verification-summary.md"),
            encoding: .utf8
        )
        let domainContext = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/domain/context.md"),
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
        let automationReadiness = try String(
            contentsOf: repositoryRoot.appendingPathComponent("docs/automation/automation-readiness.md"),
            encoding: .utf8
        )
        let l4Boundary = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.d/l4-boundary.sh"),
            encoding: .utf8
        )

        for rootDoc in [readme, architecture, roadmap, latestSummary, domainContext] {
            XCTAssertTrue(rootDoc.contains("GH-564-RELEASE-V020-ROOT-DOCS-BOUNDARY-REFRESH"))
            XCTAssertTrue(rootDoc.contains("activeVenue == Binance"))
            XCTAssertTrue(rootDoc.contains("activeProductTypes == [spot, usdsPerpetual]"))
            XCTAssertTrue(rootDoc.contains("activeStrategies == [ema, rsi]"))
            XCTAssertTrue(rootDoc.contains("productionTradingEnabledByDefault == false"))
        }

        for currentBoundaryDoc in [readme, architecture, roadmap, latestSummary, domainContext] {
            XCTAssertTrue(currentBoundaryDoc.contains("productionCapabilityGatedNotMissing == true"))
            XCTAssertTrue(currentBoundaryDoc.contains("oldPublicReadOnlyPaperOnlyEMAOnlyIsHistorical == true"))
        }

        XCTAssertTrue(domainContext.contains("GH-564-PRODUCTION-CAPABILITY-GATED-NOT-MISSING"))
        XCTAssertTrue(domainContext.contains("GH-564-NO-OLD-BOUNDARY-AS-CURRENT"))
        XCTAssertTrue(validationMatrix.contains("`GH-564`"))
        XCTAssertTrue(validationPlan.contains("GH-564 Release v0.2.0 Root Docs Boundary Refresh Validation"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 root docs boundary refresh anchor"))
        XCTAssertTrue(l4Boundary.contains("GH-564-RELEASE-V020-ROOT-DOCS-BOUNDARY-REFRESH"))
        XCTAssertTrue(l4Boundary.contains("testGH564ReleaseV020RootDocsReplaceOldSpotPaperEMABoundaries"))

        XCTAssertFalse(
            readme.contains("当前 execution scope 仍是 paper-only / public-read-only foundation")
        )
        for retiredCurrentBoundary in [
            "当前只允许 Binance public market data read-only 和 future-gated private stream label",
            "active concrete strategy 只有 `EMA`",
            "非 EMA strategy 只能作为 future candidate",
            "`ExecutionClient` 只存在 future gate / capability matrix"
        ] {
            XCTAssertFalse(
                architecture.contains(retiredCurrentBoundary),
                "architecture.md must not present old boundary as current: \(retiredCurrentBoundary)"
            )
        }
    }

    func testGH565ReleaseV020BoundaryGuardBlocksScopeExpansionAndProductionDefaults() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let guardPath = repositoryRoot.appendingPathComponent(
            "checks/automation-readiness.d/release-v0.2.0-boundary.sh"
        )
        let guardScript = try String(contentsOf: guardPath, encoding: .utf8)
        let runDomainGuards = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.d/run-domain-guards.sh"),
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

        XCTAssertTrue(FileManager.default.fileExists(atPath: guardPath.path))
        for expected in [
            "GH-565-V020-BINANCE-SPOT-PERP-EMA-RSI-AUTOMATION-GUARD",
            "GH-565-NON-BINANCE-ACTIVE-SOURCE-GUARD",
            "GH-565-ACTIVE-PRODUCT-TYPE-GUARD",
            "GH-565-ACTIVE-STRATEGY-GUARD",
            "GH-565-PRODUCTION-AUTO-ENABLE-GUARD",
            "TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY-GUARD",
            "allowed_venue_dirs = {\"Binance\", \"TargetGraph\"}",
            "allowed_strategy_dirs = {\"EMA\", \"RSI\", \"TargetGraph\"}",
            "activeVenue must be Binance only",
            "activeProductTypes must be spot + usdsPerpetual only",
            "activeStrategies must be EMA + RSI only",
            "productionTradingEnabledByDefault",
            "nonBinanceVenueEnabled",
            "thirdActiveProductTypeEnabled",
            "thirdActiveStrategyEnabled",
            "bypassesCommandGateway",
            "MTPRO release v0.2.0 boundary guard passed."
        ] {
            XCTAssertTrue(guardScript.contains(expected), "v0.2.0 boundary guard must contain \(expected)")
        }

        XCTAssertTrue(runDomainGuards.contains("release-v0.2.0-boundary"))
        XCTAssertTrue(validationMatrix.contains("`GH-565`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY-GUARD"))
        XCTAssertTrue(validationPlan.contains("GH-565 Release v0.2.0 Boundary Automation Guard Validation"))
        XCTAssertTrue(domainContext.contains("GH-565 Release v0.2.0 Boundary Automation Guard Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 boundary automation guard anchor"))
    }

    func testGH566ProductTypeInstrumentIdentityAndPerpetualContractDomainModel() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perpetual = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let contract = try PerpetualContract(
            instrument: perpetual,
            marginAsset: .constant("USDT", field: "perpetualContract.marginAsset"),
            settlementAsset: .constant("USDT", field: "perpetualContract.settlementAsset"),
            contractSize: 1,
            fundingIntervalHours: 8
        )

        XCTAssertNotEqual(spot, perpetual)
        XCTAssertEqual(spot.rawValue, "binance:spot:BTCUSDT")
        XCTAssertEqual(perpetual.rawValue, "binance:usdsPerpetual:BTCUSDT")
        XCTAssertEqual(try ProductType(contractValue: "usds-perpetual"), .usdsPerpetual)
        XCTAssertEqual(contract.instrument, perpetual)
        XCTAssertEqual(contract.marginAsset.rawValue, "USDT")
        XCTAssertEqual(contract.settlementAsset.rawValue, "USDT")
        XCTAssertEqual(contract.fundingIntervalHours, 8)
        XCTAssertEqual(try PerpetualContract.binanceBTCUSDTFixture().instrument, perpetual)

        XCTAssertThrowsError(try InstrumentIdentity(rawValue: "binance:BTCUSDT"))
        XCTAssertThrowsError(try InstrumentIdentity(rawValue: "binance:coinMPerpetual:BTCUSDT"))
        XCTAssertThrowsError(try InstrumentIdentity(rawValue: "binance:spot:UNKNOWN"))
        XCTAssertThrowsError(
            try PerpetualContract(
                instrument: spot,
                marginAsset: .constant("USDT", field: "perpetualContract.marginAsset"),
                settlementAsset: .constant("USDT", field: "perpetualContract.settlementAsset"),
                contractSize: 1,
                fundingIntervalHours: 8
            )
        )

        for expected in [
            "\"ProductType.swift\"",
            "\"InstrumentIdentity.swift\"",
            "\"PerpetualContract.swift\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "DomainModel target must compile \(expected)")
        }
        XCTAssertTrue(validationMatrix.contains("`GH-566`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-PRODUCT-INSTRUMENT-PERPETUAL-DOMAIN-MODEL"))
        XCTAssertTrue(validationPlan.contains("GH-566 Release v0.2.0 Product / Instrument Domain Model Validation"))
        XCTAssertTrue(domainContext.contains("GH-566 Product Type / Instrument Identity / Perpetual Contract Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 product instrument domain model anchor"))
    }

    func testGH567TargetExposureAndProductAwareOrderIntentModel() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let quantity = try Quantity(0.25, field: "productAwareOrderIntent.quantity")
        let referencePrice = try Price(100, field: "productAwareOrderIntent.referencePrice")
        let createdAt = Date(timeIntervalSince1970: 567)

        XCTAssertEqual(
            TargetExposureIntent.allCases,
            [.targetLong, .targetShort, .targetFlat, .hold]
        )
        XCTAssertTrue(TargetExposureIntent.targetLong.requiresOrderIntent)
        XCTAssertTrue(TargetExposureIntent.targetShort.requiresOrderIntent)
        XCTAssertTrue(TargetExposureIntent.targetFlat.requiresOrderIntent)
        XCTAssertFalse(TargetExposureIntent.hold.requiresOrderIntent)

        let spotLong = try ProductAwareOrderIntent(
            intentID: .constant("gh-567-spot-long"),
            instrument: spot,
            targetExposure: .targetLong,
            quantity: quantity,
            referencePrice: referencePrice,
            createdAt: createdAt
        )
        let spotFlat = try ProductAwareOrderIntent(
            intentID: .constant("gh-567-spot-flat"),
            instrument: spot,
            targetExposure: .targetFlat,
            quantity: quantity,
            referencePrice: referencePrice,
            createdAt: createdAt
        )
        let perpShort = try ProductAwareOrderIntent(
            intentID: .constant("gh-567-perp-short"),
            instrument: perp,
            targetExposure: .targetShort,
            quantity: quantity,
            referencePrice: referencePrice,
            createdAt: createdAt
        )

        XCTAssertEqual(spotLong.instrument.productType, .spot)
        XCTAssertEqual(spotFlat.targetExposure, .targetFlat)
        XCTAssertEqual(perpShort.instrument.productType, .usdsPerpetual)
        XCTAssertEqual(perpShort.targetExposure, .targetShort)
        XCTAssertTrue(perpShort.isPreRiskGateIntent)
        XCTAssertFalse(perpShort.authorizesTradingExecution)
        XCTAssertFalse(perpShort.productionTradingEnabledByDefault)

        XCTAssertThrowsError(
            try ProductAwareOrderIntent(
                intentID: .constant("gh-567-spot-short"),
                instrument: spot,
                targetExposure: .targetShort,
                quantity: quantity,
                referencePrice: referencePrice,
                createdAt: createdAt
            )
        )
        XCTAssertThrowsError(
            try ProductAwareOrderIntent(
                intentID: .constant("gh-567-hold-order"),
                instrument: spot,
                targetExposure: .hold,
                quantity: quantity,
                referencePrice: referencePrice,
                createdAt: createdAt
            )
        )

        let shortMessage = try StrategyIntentMessage(
            messageID: .constant("gh-567-perp-short-message"),
            strategyID: .constant("gh-567-rsi-strategy"),
            instrument: perp,
            targetExposure: .targetShort,
            productAwareOrderIntent: perpShort,
            emittedAt: createdAt
        )
        let holdMessage = try StrategyIntentMessage(
            messageID: .constant("gh-567-hold-message"),
            strategyID: .constant("gh-567-rsi-strategy"),
            instrument: spot,
            targetExposure: .hold,
            productAwareOrderIntent: nil,
            emittedAt: createdAt
        )

        XCTAssertEqual(shortMessage.productAwareOrderIntent, perpShort)
        XCTAssertNil(holdMessage.productAwareOrderIntent)
        XCTAssertThrowsError(
            try StrategyIntentMessage(
                messageID: .constant("gh-567-missing-order"),
                strategyID: .constant("gh-567-rsi-strategy"),
                instrument: perp,
                targetExposure: .targetLong,
                productAwareOrderIntent: nil,
                emittedAt: createdAt
            )
        )

        for expected in [
            "\"TargetExposureIntent.swift\"",
            "\"ProductAwareOrderIntent.swift\"",
            "\"StrategyIntentMessages.swift\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "Package.swift must compile \(expected)")
        }
        XCTAssertTrue(validationMatrix.contains("`GH-567`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-TARGET-EXPOSURE-PRODUCT-AWARE-INTENT"))
        XCTAssertTrue(validationPlan.contains("GH-567 Release v0.2.0 Target Exposure / Product-aware Intent Validation"))
        XCTAssertTrue(domainContext.contains("GH-567 Target Exposure / Product-aware Order Intent Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 target exposure product-aware intent anchor"))
    }

    func testGH568TraderStrategiesTargetUsesEMARSISharedRoot() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let strategies = TraderStrategiesTargetBoundary.mtp219
        let trader = TraderTargetBoundary.mtp219

        XCTAssertEqual(strategies.canonicalSourceRoot, "Sources/Trader/Strategies")
        XCTAssertEqual(strategies.compiledBoundaryRoot, "Sources/Trader/Strategies/TargetGraph")
        XCTAssertEqual(strategies.activeConcreteStrategies, ["EMA", "RSI"])
        XCTAssertEqual(
            strategies.activeStrategySourceRoots,
            ["Sources/Trader/Strategies/EMA", "Sources/Trader/Strategies/RSI"]
        )
        XCTAssertTrue(strategies.nonReleaseActiveStrategySourceRoots.isEmpty)
        XCTAssertFalse(strategies.callsExecutionClient)
        XCTAssertFalse(strategies.callsBrokerOrOMS)
        XCTAssertFalse(strategies.exposesUICommandSurface)
        XCTAssertEqual(trader.activeStrategyRoot, "Sources/Trader/Strategies")
        XCTAssertEqual(trader.activeConcreteStrategies, ["EMA", "RSI"])

        for expected in [
            "path: \"Sources/Trader/Strategies\"",
            "\"EMA/EMAProposalRuntime.swift\"",
            "\"EMA/EMACross.swift\"",
            "\"RSI/RSIStrategy.swift\"",
            "\"TargetGraph/TraderStrategiesTargetBoundary.swift\"",
            "\"Trader/Strategies/RSI/RSIStrategy.swift\"",
            "\"Trader/Strategies/TargetGraph\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "Package.swift must contain \(expected)")
        }
        XCTAssertFalse(packageSource.contains("path: \"Sources/Trader/Strategies/EMA\""))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repositoryRoot
                    .appendingPathComponent("Sources/Trader/Strategies/TargetGraph/TraderStrategiesTargetBoundary.swift")
                    .path
            )
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: repositoryRoot
                    .appendingPathComponent("Sources/Trader/Strategies/EMA/TargetGraph/TraderStrategiesTargetBoundary.swift")
                    .path
            )
        )

        _ = try EMACrossStrategyConfiguration(
            strategyID: .constant("gh-568-ema"),
            symbol: .constant("BTCUSDT"),
            timeframe: .oneMinute,
            shortPeriod: 2,
            longPeriod: 3
        )
        let rsiConfiguration = try RSIStrategyConfiguration(
            strategyID: .constant("gh-568-rsi"),
            symbol: .constant("BTCUSDT"),
            timeframe: .oneMinute,
            period: 3
        )
        let rsiSamples = try RSIStrategyContract(configuration: rsiConfiguration).evaluate(
            Self.gh568Bars(closes: [100, 99, 98, 97, 96])
        )
        XCTAssertEqual(rsiSamples.last?.signal.direction, .long)
        XCTAssertEqual(rsiSamples.last?.rsiValue, 0)
        XCTAssertThrowsError(
            try RSIStrategyConfiguration(
                strategyID: .constant("gh-568-rsi-invalid"),
                symbol: .constant("BTCUSDT"),
                timeframe: .oneMinute,
                period: 1
            )
        )

        XCTAssertTrue(validationMatrix.contains("`GH-568`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-TRADERSTRATEGIES-EMA-RSI-ROOT"))
        XCTAssertTrue(validationPlan.contains("GH-568 Release v0.2.0 TraderStrategies EMA / RSI Root Validation"))
        XCTAssertTrue(domainContext.contains("GH-568 TraderStrategies EMA / RSI Root Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 TraderStrategies EMA RSI root anchor"))
    }

    func testGH569EMATargetExposureIntentSupportsSpotAndPerpWithoutDirectOrderSide() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let emaSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/Trader/Strategies/EMA/EMACross.swift"),
            encoding: .utf8
        )

        let runtime = try EMAProposalRuntime.deterministicFixture()
        let samples = try EMACrossStrategyContract(configuration: runtime.configuration).evaluate(
            Self.gh568Bars(closes: [10, 11, 12, 11, 10, 13])
        )
        XCTAssertEqual(samples.map(\.signal.direction), [.long, .long, .flat, .long])
        XCTAssertEqual(samples.map(\.targetExposure), [.targetLong, .hold, .targetFlat, .targetLong])
        XCTAssertTrue(samples.allSatisfy { $0.emitsDirectOrderSide == false })
        XCTAssertTrue(emaSource.contains("TargetExposureIntent"))
        XCTAssertFalse(emaSource.contains("PaperActionProposalSide"))

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let quantity = try Quantity(0.20, field: "gh569.quantity")
        let emittedAt = Date(timeIntervalSince1970: 1_704_067_569)

        let spotLong = try runtime.generateTargetExposureIntent(
            from: samples[0],
            instrument: spot,
            sourceSequence: 5_691,
            quantity: quantity,
            emittedAt: emittedAt
        )
        let perpLong = try runtime.generateTargetExposureIntent(
            from: samples[0],
            instrument: perp,
            sourceSequence: 5_692,
            quantity: quantity,
            emittedAt: emittedAt
        )
        let spotFlat = try runtime.generateTargetExposureIntent(
            from: samples[2],
            instrument: spot,
            sourceSequence: 5_693,
            quantity: quantity,
            emittedAt: emittedAt
        )
        let hold = try runtime.generateTargetExposureIntent(
            from: samples[1],
            instrument: perp,
            sourceSequence: 5_694,
            quantity: quantity,
            emittedAt: emittedAt
        )

        XCTAssertEqual(spotLong.targetExposure, .targetLong)
        XCTAssertEqual(perpLong.targetExposure, .targetLong)
        XCTAssertEqual(spotFlat.targetExposure, .targetFlat)
        XCTAssertEqual(hold.targetExposure, .hold)
        XCTAssertEqual(spotLong.instrument.productType, .spot)
        XCTAssertEqual(perpLong.instrument.productType, .usdsPerpetual)
        XCTAssertNil(hold.productAwareOrderIntent)

        let spotLongIntent = try XCTUnwrap(spotLong.productAwareOrderIntent)
        let perpLongIntent = try XCTUnwrap(perpLong.productAwareOrderIntent)
        let spotFlatIntent = try XCTUnwrap(spotFlat.productAwareOrderIntent)
        XCTAssertEqual(spotLongIntent.instrument, spot)
        XCTAssertEqual(perpLongIntent.instrument, perp)
        XCTAssertEqual(spotFlatIntent.targetExposure, .targetFlat)
        XCTAssertTrue(spotLongIntent.isPreRiskGateIntent)
        XCTAssertTrue(perpLongIntent.isPreRiskGateIntent)
        XCTAssertFalse(spotLongIntent.authorizesTradingExecution)
        XCTAssertFalse(perpLongIntent.productionTradingEnabledByDefault)

        XCTAssertThrowsError(
            try runtime.generateTargetExposureIntent(
                from: samples[0],
                instrument: InstrumentIdentity(
                    venue: "coinbase",
                    productType: .spot,
                    symbol: symbol
                ),
                sourceSequence: 5_695,
                quantity: quantity,
                emittedAt: emittedAt
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("emaProposalRuntime.nonBinanceInstrument")
            )
        }

        for expected in [
            "\"EMA/EMAProposalRuntime.swift\"",
            "\"EMA/EMACross.swift\"",
            "\"TargetExposureIntent.swift\"",
            "\"ProductAwareOrderIntent.swift\"",
            "\"StrategyIntentMessages.swift\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "Package.swift must compile \(expected)")
        }
        XCTAssertTrue(validationMatrix.contains("`GH-569`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-EMA-TARGET-EXPOSURE-INTENT"))
        XCTAssertTrue(validationPlan.contains("GH-569 Release v0.2.0 EMA Target Exposure Intent Validation"))
        XCTAssertTrue(domainContext.contains("GH-569 EMA Target Exposure Intent Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 EMA target exposure intent anchor"))
    }

    func testGH570RSITargetExposureIntentSupportsSpotAndGatedPerpShort() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let rsiSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/Trader/Strategies/RSI/RSIStrategy.swift"),
            encoding: .utf8
        )

        let defaultEmitter = try RSITargetExposureIntentEmitter.deterministicFixture()
        let defaultContract = RSIStrategyContract(configuration: defaultEmitter.configuration)
        let oversoldSample = try XCTUnwrap(
            defaultContract.evaluate(Self.gh568Bars(closes: [100, 99, 98, 97])).last
        )
        let overboughtSample = try XCTUnwrap(
            defaultContract.evaluate(Self.gh568Bars(closes: [100, 101, 102, 103])).last
        )
        let neutralSample = try XCTUnwrap(
            defaultContract.evaluate(Self.gh568Bars(closes: [100, 101, 100, 101])).last
        )

        XCTAssertEqual(oversoldSample.rsiValue, 0)
        XCTAssertEqual(oversoldSample.signal.direction, .long)
        XCTAssertEqual(oversoldSample.targetExposure, .targetLong)
        XCTAssertEqual(overboughtSample.rsiValue, 100)
        XCTAssertEqual(overboughtSample.signal.direction, .flat)
        XCTAssertEqual(overboughtSample.targetExposure, .targetFlat)
        XCTAssertEqual(neutralSample.rsiValue, 66.6666666667, accuracy: 0.0001)
        XCTAssertEqual(neutralSample.targetExposure, .hold)
        XCTAssertTrue([oversoldSample, overboughtSample, neutralSample].allSatisfy {
            $0.emitsDirectOrderSide == false
        })
        XCTAssertTrue(rsiSource.contains("TargetExposureIntent"))
        XCTAssertFalse(rsiSource.contains("PaperActionProposalSide"))

        let symbol = Symbol.constant("BTCUSDT")
        let spot = InstrumentIdentity.binance(productType: .spot, symbol: symbol)
        let perp = InstrumentIdentity.binance(productType: .usdsPerpetual, symbol: symbol)
        let quantity = try Quantity(0.15, field: "gh570.quantity")
        let emittedAt = Date(timeIntervalSince1970: 1_704_067_570)

        let spotLong = try defaultEmitter.generateTargetExposureIntent(
            from: oversoldSample,
            instrument: spot,
            sourceSequence: 5_701,
            quantity: quantity,
            emittedAt: emittedAt
        )
        let spotFlat = try defaultEmitter.generateTargetExposureIntent(
            from: overboughtSample,
            instrument: spot,
            sourceSequence: 5_702,
            quantity: quantity,
            emittedAt: emittedAt
        )
        let perpFlatWhenShortDisabled = try defaultEmitter.generateTargetExposureIntent(
            from: overboughtSample,
            instrument: perp,
            sourceSequence: 5_703,
            quantity: quantity,
            emittedAt: emittedAt
        )
        let hold = try defaultEmitter.generateTargetExposureIntent(
            from: neutralSample,
            instrument: perp,
            sourceSequence: 5_704,
            quantity: quantity,
            emittedAt: emittedAt
        )

        XCTAssertEqual(spotLong.targetExposure, .targetLong)
        XCTAssertEqual(spotFlat.targetExposure, .targetFlat)
        XCTAssertEqual(perpFlatWhenShortDisabled.targetExposure, .targetFlat)
        XCTAssertEqual(hold.targetExposure, .hold)
        XCTAssertNil(hold.productAwareOrderIntent)
        XCTAssertEqual(spotFlat.productAwareOrderIntent?.instrument.productType, .spot)
        XCTAssertEqual(perpFlatWhenShortDisabled.productAwareOrderIntent?.targetExposure, .targetFlat)

        let shortEmitter = try RSITargetExposureIntentEmitter.deterministicFixture(perpetualShortEnabled: true)
        let shortContract = RSIStrategyContract(configuration: shortEmitter.configuration)
        let shortCandidateSample = try XCTUnwrap(
            shortContract.evaluate(Self.gh568Bars(closes: [100, 101, 102, 103])).last
        )
        XCTAssertEqual(shortCandidateSample.targetExposure, .targetFlat)
        let spotStillFlat = try shortEmitter.generateTargetExposureIntent(
            from: shortCandidateSample,
            instrument: spot,
            sourceSequence: 5_705,
            quantity: quantity,
            emittedAt: emittedAt
        )
        let perpShort = try shortEmitter.generateTargetExposureIntent(
            from: shortCandidateSample,
            instrument: perp,
            sourceSequence: 5_706,
            quantity: quantity,
            emittedAt: emittedAt
        )
        XCTAssertEqual(spotStillFlat.targetExposure, .targetFlat)
        XCTAssertEqual(perpShort.targetExposure, .targetShort)
        let perpShortIntent = try XCTUnwrap(perpShort.productAwareOrderIntent)
        XCTAssertEqual(perpShortIntent.instrument, perp)
        XCTAssertEqual(perpShortIntent.targetExposure, .targetShort)
        XCTAssertTrue(perpShortIntent.isPreRiskGateIntent)
        XCTAssertFalse(perpShortIntent.authorizesTradingExecution)
        XCTAssertFalse(perpShortIntent.productionTradingEnabledByDefault)

        XCTAssertThrowsError(
            try defaultEmitter.generateTargetExposureIntent(
                from: oversoldSample,
                instrument: InstrumentIdentity(
                    venue: "coinbase",
                    productType: .spot,
                    symbol: symbol
                ),
                sourceSequence: 5_707,
                quantity: quantity,
                emittedAt: emittedAt
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("rsiTargetExposureEmitter.nonBinanceInstrument")
            )
        }

        for expected in [
            "\"RSI/RSIStrategy.swift\"",
            "\"TargetExposureIntent.swift\"",
            "\"ProductAwareOrderIntent.swift\"",
            "\"StrategyIntentMessages.swift\""
        ] {
            XCTAssertTrue(packageSource.contains(expected), "Package.swift must compile \(expected)")
        }
        XCTAssertTrue(validationMatrix.contains("`GH-570`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-RSI-TARGET-EXPOSURE-INTENT"))
        XCTAssertTrue(validationPlan.contains("GH-570 Release v0.2.0 RSI Target Exposure Intent Validation"))
        XCTAssertTrue(domainContext.contains("GH-570 RSI Target Exposure Intent Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 RSI target exposure intent anchor"))
    }

    func testGH571StrategyRegistryRegistersEMAAndRSIProductBindingsWithoutExecutionDependency() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let packageSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Package.swift"),
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
        let registrySource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/Trader/Strategies/StrategyRegistry.swift"),
            encoding: .utf8
        )

        var registry = try StrategyRegistry.deterministicReleaseV020(perpetualShortEnabled: true)
        let emaRegistrations = registry.registrations(for: .ema)
        let rsiRegistrations = registry.registrations(for: .rsi)
        XCTAssertEqual(emaRegistrations.count, 1)
        XCTAssertEqual(rsiRegistrations.count, 1)

        let emaRegistration = try XCTUnwrap(emaRegistrations.first)
        let rsiRegistration = try XCTUnwrap(rsiRegistrations.first)
        XCTAssertEqual(emaRegistration.sourceRoot, "Sources/Trader/Strategies/EMA")
        XCTAssertEqual(rsiRegistration.sourceRoot, "Sources/Trader/Strategies/RSI")
        XCTAssertTrue(emaRegistration.isExecutionIsolated)
        XCTAssertTrue(rsiRegistration.isExecutionIsolated)
        XCTAssertEqual(Set(emaRegistration.productBindings.map(\.instrument.productType)), [.spot, .usdsPerpetual])
        XCTAssertEqual(Set(rsiRegistration.productBindings.map(\.instrument.productType)), [.spot, .usdsPerpetual])
        XCTAssertTrue(emaRegistration.productBindings.allSatisfy { $0.allowsTargetShort == false })

        let rsiSpotBinding = try XCTUnwrap(
            rsiRegistration.productBindings.first { $0.instrument.productType == .spot }
        )
        let rsiPerpBinding = try XCTUnwrap(
            rsiRegistration.productBindings.first { $0.instrument.productType == .usdsPerpetual }
        )
        XCTAssertFalse(rsiSpotBinding.allowsTargetShort)
        XCTAssertTrue(rsiPerpBinding.allowsTargetShort)
        XCTAssertTrue(rsiSpotBinding.isPreRiskOnlyBinding)
        XCTAssertTrue(rsiPerpBinding.isPreRiskOnlyBinding)

        XCTAssertThrowsError(try registry.register(emaRegistration)) { error in
            XCTAssertEqual(
                error as? CoreError,
                .traderAccountContextMismatch(
                    field: "strategyRegistry.duplicateStrategyID",
                    expected: "unique",
                    actual: "gh-571-ema-actor"
                )
            )
        }
        XCTAssertThrowsError(try StrategyActorKind(contractValue: "grid")) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("strategyRegistry.unknownStrategyKind.grid")
            )
        }
        XCTAssertThrowsError(
            try StrategyProductBinding(
                strategyID: Identifier("gh-571-invalid-binding"),
                kind: .rsi,
                instrument: InstrumentIdentity(
                    venue: "coinbase",
                    productType: .spot,
                    symbol: Symbol.constant("BTCUSDT")
                )
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("strategyProductBinding.nonBinanceInstrument")
            )
        }

        XCTAssertTrue(packageSource.contains("\"StrategyRegistry.swift\""))
        XCTAssertTrue(
            packageSource.contains("dependencies: [\"DomainModel\", \"MessageBus\", \"Cache\", \"Portfolio\", \"RiskEngine\"]")
        )
        XCTAssertFalse(registrySource.contains("import ExecutionClient"))
        XCTAssertFalse(registrySource.contains("ExecutionClient."))
        XCTAssertFalse(registrySource.contains("brokerCommand"))

        XCTAssertTrue(validationMatrix.contains("`GH-571`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-STRATEGY-ACTOR-REGISTRY-BINDING"))
        XCTAssertTrue(validationPlan.contains("GH-571 Release v0.2.0 Strategy Actor Registry Validation"))
        XCTAssertTrue(domainContext.contains("GH-571 Strategy Actor Registry Terms"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 strategy actor registry anchor"))
    }

    func testGH572TypedMessageBusEnvelopeEvidenceIsWiredIntoReleaseGuard() throws {
        let repositoryRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let domainEventsSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/MessageBus/DomainEvents.swift"),
            encoding: .utf8
        )
        let eventLogSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/MessageBus/EventLog.swift"),
            encoding: .utf8
        )
        let paperRoutingSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Sources/MessageBus/PaperRuntimeBusRouting.swift"),
            encoding: .utf8
        )
        let coreTests = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Tests/CoreTests/CoreTests.swift"),
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
        let releaseGuard = try String(
            contentsOf: repositoryRoot.appendingPathComponent("checks/automation-readiness.d/release-v0.2.0-boundary.sh"),
            encoding: .utf8
        )
        let releaseContract = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "docs/contracts/release-v0.2.0-binance-spot-perp-ema-rsi-ntpro-alignment-contract.md"
            ),
            encoding: .utf8
        )

        XCTAssertTrue(domainEventsSource.contains("public struct TypedMessageEnvelopeContext"))
        XCTAssertTrue(domainEventsSource.contains("public let venue: Identifier"))
        XCTAssertTrue(domainEventsSource.contains("public let productType: ProductType"))
        XCTAssertTrue(domainEventsSource.contains("public let instrumentID: InstrumentIdentity"))
        XCTAssertTrue(domainEventsSource.contains("public let typedContext: TypedMessageEnvelopeContext?"))
        XCTAssertTrue(eventLogSource.contains("typedContext: TypedMessageEnvelopeContext? = nil"))
        XCTAssertTrue(paperRoutingSource.contains("public let typedContext: TypedMessageEnvelopeContext?"))
        XCTAssertTrue(paperRoutingSource.contains("typedContext: message.typedContext"))
        XCTAssertTrue(coreTests.contains("testGH572TypedMessageBusEnvelopePreservesProductContextAcrossReplay"))
        XCTAssertTrue(coreTests.contains("strategy/risk/execution/portfolio"))
        XCTAssertTrue(coreTests.contains("replay.envelopes.map(\\.typedContext)"))

        XCTAssertTrue(releaseContract.contains("Typed MessageBus envelopes with venue + productType + instrumentID"))
        XCTAssertTrue(validationMatrix.contains("`GH-572`"))
        XCTAssertTrue(validationMatrix.contains("TVM-RELEASE-V020-TYPED-MESSAGEBUS-ENVELOPE"))
        XCTAssertTrue(validationPlan.contains("GH-572 Release v0.2.0 Typed MessageBus Envelope Validation"))
        XCTAssertTrue(domainContext.contains("GH-572 Typed MessageBus Envelope Terms"))
        XCTAssertTrue(domainContext.contains("GH-572-NO-LIVE-COMMAND-BUS"))
        XCTAssertTrue(automationReadiness.contains("Release v0.2.0 typed MessageBus envelope anchor"))
        XCTAssertTrue(releaseGuard.contains("testGH572TypedMessageBusEnvelopeEvidenceIsWiredIntoReleaseGuard"))
        XCTAssertFalse(domainEventsSource.contains("ExecutionClient"))
        XCTAssertFalse(domainEventsSource.contains("brokerCommand"))
    }

    private static func gh568Bars(closes: [Double]) throws -> [MarketBar] {
        try closes.enumerated().map { index, close in
            let start = Date(timeIntervalSince1970: Double(index * 60))
            return try MarketBar(
                symbol: .constant("BTCUSDT"),
                timeframe: .oneMinute,
                interval: DateRange(start: start, end: start.addingTimeInterval(60)),
                open: close,
                high: close + 1,
                low: close - 1,
                close: close,
                volume: 10 + Double(index)
            )
        }
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

    private func packageTargetSwiftSources(
        repositoryRoot: URL,
        targetRoot: String,
        targetBlock: String
    ) throws -> Set<String> {
        let sourceEntries = try packageListEntries(in: packageTargetSourcesBlock(targetBlock: targetBlock))
        let excludeEntries: [String]
        if let excludesBlock = try? packageTargetExcludesBlock(targetBlock: targetBlock) {
            excludeEntries = packageListEntries(in: excludesBlock)
        } else {
            excludeEntries = []
        }

        let fileManager = FileManager.default
        let targetRootURL = repositoryRoot.appendingPathComponent(targetRoot, isDirectory: true)
        let sourceFiles = try sourceEntries.flatMap { sourceEntry -> [URL] in
            let sourceURL = targetRootURL.appendingPathComponent(sourceEntry)
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: sourceURL.path, isDirectory: &isDirectory) else {
                throw XCTSkip("Package.swift source entry \(targetRoot)/\(sourceEntry) does not exist")
            }
            if isDirectory.boolValue {
                guard let enumerator = fileManager.enumerator(
                    at: sourceURL,
                    includingPropertiesForKeys: [.isRegularFileKey],
                    options: [.skipsPackageDescendants]
                ) else {
                    throw XCTSkip("Cannot enumerate Package.swift source entry \(sourceURL.path)")
                }
                return try enumerator.compactMap { item -> URL? in
                    guard let url = item as? URL else {
                        return nil
                    }
                    let values = try url.resourceValues(forKeys: [.isRegularFileKey])
                    return values.isRegularFile == true && url.pathExtension == "swift" ? url : nil
                }
            }
            return sourceURL.pathExtension == "swift" ? [sourceURL] : []
        }

        return Set(sourceFiles.compactMap { file in
            let targetRelativePath = relativePath(for: file, repositoryRoot: targetRootURL)
            let isExcluded = excludeEntries.contains { excludeEntry in
                targetRelativePath == excludeEntry || targetRelativePath.hasPrefix("\(excludeEntry)/")
            }
            guard !isExcluded else {
                return nil
            }
            return relativePath(for: file, repositoryRoot: repositoryRoot)
        })
    }

    private func packageListEntries(in listBlock: String) -> [String] {
        listBlock.components(separatedBy: .newlines).compactMap { line in
            guard let openingQuote = line.firstIndex(of: "\"") else {
                return nil
            }
            let afterOpeningQuote = line.index(after: openingQuote)
            guard let closingQuote = line[afterOpeningQuote...].firstIndex(of: "\"") else {
                return nil
            }
            return String(line[afterOpeningQuote..<closingQuote])
        }
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

    private func assertNoForbiddenBinanceUSDMPerpetualPublicRequestFragments(
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
        XCTAssertFalse(serializedRequests.contains("/fapi/v1/account"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/fapi/v1/order"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/fapi/v1/listenkey"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/fapi/v1/userdatastream"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/sapi/"), file: file, line: line)
        XCTAssertFalse(serializedRequests.contains("/dapi/"), file: file, line: line)
    }

    private func packageTargetBlock(named targetName: String, packageSource: String) throws -> String {
        let targetMarkers = [
            ".target(\n            name: \"\(targetName)\"",
            ".executableTarget(\n            name: \"\(targetName)\"",
            ".testTarget(\n            name: \"\(targetName)\""
        ]
        let markerRange = targetMarkers
            .compactMap { packageSource.range(of: $0) }
            .min { $0.lowerBound < $1.lowerBound }
        guard let markerRange else {
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
