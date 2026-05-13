import MTPROApp
import XCTest

final class MTPROAppTests: XCTestCase {
    func testDashboardSectionsUseResearchFirstInformationArchitecture() {
        let baseline = MTPROAppBaseline()

        XCTAssertEqual(
            baseline.sections,
            [.market, .strategy, .backtest, .paper, .risk, .portfolio, .events]
        )
    }
}
