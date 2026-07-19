import Foundation
import XCTest

final class V0330BackendMaintenanceContractTests: XCTestCase {
    func testGH1574MaintenanceContractDefinesOwnershipAndPreservesReleaseBoundary() throws {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        let contractURL = root.appendingPathComponent(
            "docs/contracts/v0330-backend-maintenance-ownership-contract.md"
        )
        let contract = try String(contentsOf: contractURL, encoding: .utf8)

        let requiredAnchors = [
            "GH-1574-V0330-BACKEND-MAINTENANCE-CONTRACT",
            "GH-1574-CURRENT-REAL-MODULE-OWNERSHIP",
            "GH-1574-RETAINED-COMPATIBILITY-ENVELOPE",
            "GH-1574-CURRENT-MAINTENANCE-INVENTORY",
            "GH-1574-DEPENDENCY-DIRECTION",
            "GH-1574-DEMO-AND-PRODUCTION-BOUNDARY",
            "GH-1574-CLEANUP-SEQUENCE",
            "GH-1574-ROLLBACK-AND-ACCEPTANCE",
        ]

        for anchor in requiredAnchors {
            XCTAssertTrue(contract.contains(anchor), "Missing contract anchor: \(anchor)")
        }

        XCTAssertTrue(contract.contains("backendClosureDecision=accepted-demo-network-parity"))
        XCTAssertTrue(contract.contains("productionCutoverAuthorized=false"))
        XCTAssertTrue(contract.contains("defaultProductionTradingEnabled=false"))
        XCTAssertTrue(contract.contains("v0.33.0"))
        XCTAssertTrue(contract.contains("9d6e252ce9d2f63dd8f13c0d55141d75d11e4925"))
        XCTAssertTrue(contract.contains("Core"))
        XCTAssertTrue(contract.contains("Adapters"))
        XCTAssertTrue(contract.contains("Persistence"))
        XCTAssertTrue(contract.contains("Runtime"))
    }
}
