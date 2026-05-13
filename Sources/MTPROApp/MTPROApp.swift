import Foundation
import MTPROCore

public enum MTPRODashboardSection: String, CaseIterable, Sendable {
    case market = "Market"
    case strategy = "Strategy"
    case backtest = "Backtest"
    case paper = "Paper"
    case risk = "Risk"
    case portfolio = "Portfolio"
    case events = "Events"
}

public struct MTPROAppBaseline: Equatable, Sendable {
    public let sections: [MTPRODashboardSection]

    public init(sections: [MTPRODashboardSection] = MTPRODashboardSection.allCases) {
        self.sections = sections
    }
}
