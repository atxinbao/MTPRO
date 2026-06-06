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

    func testGH400TryBangAndPreconditionFailureStayInAllowedPaths() throws {
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
            try! and preconditionFailure are only allowed in tests, deterministic fixture/evidence helpers, \
            future gates, boundary/contract files, paper/simulated local evidence, and retained Core compatibility \
            live/read-model boundary files. Violations:
            \(violations.map(\.description).joined(separator: "\n"))
            """
        )
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
                "Sources/DataEngine/DataQuality"
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
            GH-445 deterministic replay / data quality / dashboard defaults must use named factory entrypoints \
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

        var description: String {
            "\(relativePath):\(lineNumber): \(construct): \(line.trimmingCharacters(in: .whitespaces))"
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
            [
                line.contains("try!") ? "try!" : nil,
                line.contains("preconditionFailure") ? "preconditionFailure" : nil
            ].compactMap { construct in
                construct.map {
                    UnsafeConstructOccurrence(
                        relativePath: relativePath,
                        lineNumber: index + 1,
                        construct: $0,
                        line: line
                    )
                }
            }
        }
    }

    private func relativePath(for file: URL, repositoryRoot: URL) -> String {
        let rootPath = repositoryRoot.path.hasSuffix("/") ? repositoryRoot.path : "\(repositoryRoot.path)/"
        return file.path.replacingOccurrences(of: rootPath, with: "")
    }

    private func isAllowedUnsafeConstructOccurrence(_ occurrence: UnsafeConstructOccurrence) -> Bool {
        if occurrence.relativePath.hasPrefix("Tests/") {
            return true
        }

        // GH-400: 这些路径只承载 deterministic fixture、evidence、future gate、
        // boundary / contract 或 retained compatibility evidence；新增 runtime-facing path
        // 使用 try! / preconditionFailure 时必须先扩展这里的 taxonomy，并说明原因。
        let allowedSourcePathFragments = [
            "/TargetGraph/",
            "/FutureGate/",
            "/LiveGate/",
            "/OMSFutureGate/",
            "/ScenarioReplay/",
            "/DataQuality/",
            "/PaperLifecycle/",
            "/SimulatedExchange/",
            "/BrokerCapabilityMatrix/",
            "/Report/",
            "Sources/Core/Live",
            "Sources/Core/DashboardBetaDemoScenario.swift",
            "Sources/Dashboard/PaperWorkflowDashboardArchitecture.swift",
            "Sources/Dashboard/Report/SimulatedExchangeParityEvidenceSurface.swift",
            "Sources/DomainModel/ExecutionCosts.swift",
            "Sources/MessageBus/PaperActionProposal.swift",
            "Sources/MessageBus/PaperRuntimeBusRouting.swift",
            "Sources/Portfolio/SimulatedExchangePortfolioProjectionParity.swift",
            "Sources/RiskEngine/PreTrade/PaperPreTradeRiskEngine.swift",
            "Sources/Trader/Accounts/TraderAccountContext.swift",
            "Sources/Trader/Coordination/RiskBinding/PaperActionRiskLink.swift"
        ]

        return allowedSourcePathFragments.contains { occurrence.relativePath.contains($0) }
    }

    private func forbiddenDataClientImplementationOccurrences(in file: URL, repositoryRoot: URL) throws -> [String] {
        let source = try String(contentsOf: file, encoding: .utf8)
        let relativePath = relativePath(for: file, repositoryRoot: repositoryRoot)
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
            return "\(relativePath):\(index + 1): \(forbidden): \(line.trimmingCharacters(in: .whitespaces))"
        }
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
