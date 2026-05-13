import MTPROPersistence
import XCTest

final class MTPROPersistenceTests: XCTestCase {
    func testPersistenceBoundarySeparatesFactsAndProjections() {
        let boundary = MTPROPersistenceBoundary()

        XCTAssertEqual(boundary.factSource, "append-only event log")
        XCTAssertTrue(boundary.sqliteResponsibility.contains("runtime state"))
        XCTAssertTrue(boundary.duckDBResponsibility.contains("backtest"))
    }
}
