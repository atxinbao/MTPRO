import MTPROAdapters
import XCTest

final class MTPROAdaptersTests: XCTestCase {
    func testBinanceBoundaryIsReadOnly() {
        let boundary = BinanceReadOnlyAdapterBoundary()

        XCTAssertTrue(boundary.allowedCapabilities.contains("klines"))
        XCTAssertTrue(boundary.allowedCapabilities.contains("depth delta"))
        XCTAssertTrue(boundary.forbiddenCapabilities.contains("order submit"))
        XCTAssertTrue(boundary.forbiddenCapabilities.contains("API key"))
    }
}
