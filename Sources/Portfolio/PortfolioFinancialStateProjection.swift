import DomainModel
import Foundation
import MessageBus

/// PortfolioFinancialStateProjection 是 Portfolio target 的真实 source owner 基线。
///
/// 它只把 MessageBus 暴露的 paper exposure snapshot 固定成组合只读状态，不读取真实账户、
/// 不同步 broker position、不处理 margin / leverage，也不生成任何交易命令。
public struct PortfolioFinancialStateProjection: Codable, Equatable, Sendable {
    public let projectionID: Identifier
    public let exposure: PortfolioExposureSnapshot
    public let projectedAt: Date
    public let readsBrokerAccountState: Bool
    public let readsAccountEndpointPayload: Bool
    public let performsBrokerReconciliation: Bool
    public let authorizesTradingExecution: Bool

    public var portfolioID: Identifier {
        exposure.portfolioID
    }

    public var paperOnlyBoundaryHeld: Bool {
        exposure.source == .paperProjection
            && readsBrokerAccountState == false
            && readsAccountEndpointPayload == false
            && performsBrokerReconciliation == false
            && authorizesTradingExecution == false
    }

    public init(
        projectionID: Identifier,
        exposure: PortfolioExposureSnapshot,
        projectedAt: Date,
        readsBrokerAccountState: Bool = false,
        readsAccountEndpointPayload: Bool = false,
        performsBrokerReconciliation: Bool = false,
        authorizesTradingExecution: Bool = false
    ) throws {
        guard exposure.source == .paperProjection else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "exposure.source",
                expected: PortfolioExposureSource.paperProjection.rawValue,
                actual: exposure.source.rawValue
            )
        }
        guard readsBrokerAccountState == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("readsBrokerAccountState")
        }
        guard readsAccountEndpointPayload == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("readsAccountEndpointPayload")
        }
        guard performsBrokerReconciliation == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("performsBrokerReconciliation")
        }
        guard authorizesTradingExecution == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("authorizesTradingExecution")
        }

        self.projectionID = projectionID
        self.exposure = exposure
        self.projectedAt = projectedAt
        self.readsBrokerAccountState = readsBrokerAccountState
        self.readsAccountEndpointPayload = readsAccountEndpointPayload
        self.performsBrokerReconciliation = performsBrokerReconciliation
        self.authorizesTradingExecution = authorizesTradingExecution
    }
}
