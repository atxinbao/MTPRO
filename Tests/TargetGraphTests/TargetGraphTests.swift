import Database
import DomainModel
import MessageBus
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
}
