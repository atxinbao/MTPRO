import Foundation
import MTPROCore

public struct MTPROPersistenceBoundary: Equatable, Sendable {
    public let factSource: String
    public let sqliteResponsibility: String
    public let duckDBResponsibility: String

    public init(
        factSource: String = "append-only event log",
        sqliteResponsibility: String = "runtime state and lightweight projections",
        duckDBResponsibility: String = "market data and backtest analytical projections"
    ) {
        self.factSource = factSource
        self.sqliteResponsibility = sqliteResponsibility
        self.duckDBResponsibility = duckDBResponsibility
    }
}
