import Cache
import Database
import DataClient
import DataEngine
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
        XCTAssertEqual(dataClient.retainedCompatibilityEnvelope, "Adapters")
        XCTAssertEqual(cache.retainedCompatibilityEnvelope, "Core")
        XCTAssertEqual(dataEngine.retainedCompatibilityEnvelope, "Core/Runtime")
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
        XCTAssertEqual(trader.allowedDependencies, ["DomainModel", "MessageBus", "Cache", "TraderStrategies", "Portfolio", "RiskEngine", "ExecutionEngine"])
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

    func testMTP220ExecutionTargetsExposeFutureGateDependencyDirection() {
        let executionClient = ExecutionClientTargetBoundary.mtp220
        let executionEngine = ExecutionEngineTargetBoundary.mtp220
        let trader = TraderTargetBoundary.mtp219

        XCTAssertTrue(executionClient.dependencyDirectionHeld)
        XCTAssertTrue(executionEngine.dependencyDirectionHeld)
        XCTAssertTrue(trader.dependencyDirectionHeld)

        XCTAssertEqual(executionClient.allowedDependencies, ["DomainModel", "MessageBus"])
        XCTAssertEqual(executionEngine.allowedDependencies, ["DomainModel", "MessageBus", "Cache", "Portfolio", "RiskEngine", "ExecutionClient"])
        XCTAssertEqual(trader.allowedDependencies, ["DomainModel", "MessageBus", "Cache", "TraderStrategies", "Portfolio", "RiskEngine", "ExecutionEngine"])
        XCTAssertTrue(trader.deferredDependencies.isEmpty)
        XCTAssertTrue(executionEngine.consumesRiskEngineBoundary)
        XCTAssertTrue(executionEngine.executionClientFutureGateOnly)
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
}
