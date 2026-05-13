import MTPROCore
import XCTest

final class MTPROCoreTests: XCTestCase {
    func testBaselineCapturesSelectedUniverseAndTimeframes() {
        let baseline = MTPROCoreBaseline()

        XCTAssertEqual(baseline.projectName, "MTPRO")
        XCTAssertEqual(baseline.executionMode, "paper-only")
        XCTAssertEqual(baseline.primaryUniverse, ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"])
        XCTAssertEqual(baseline.timeframes, ["1m", "5m"])
    }
}
