import DomainModel
import ExecutionEngine
import Foundation
import MessageBus
import Portfolio

/// GH-416 Core compatibility bridge 只把 Portfolio-owned projection update 接回旧
/// event-log / replay surface。Portfolio target 本身不依赖 `PortfolioEvent`、simulated fill
/// lifecycle、ExecutionEngine 或 Core；这些路径仍是明确保留的 compatibility envelope。
extension PaperPortfolioProjectionUpdate {
    public var portfolioEvent: PortfolioEvent {
        .paperProjectionUpdated(self)
    }

    public init(
        updateID: Identifier,
        portfolioID: Identifier,
        simulatedFill: PaperSimulatedFillEvidence,
        sourceSimulatedFillSequence: Int,
        updatedAt: Date
    ) throws {
        try self.init(
            updateID: updateID,
            decisionID: simulatedFill.riskDecisionID,
            orderID: simulatedFill.orderID,
            fillID: simulatedFill.fillID,
            proposalID: simulatedFill.proposalID,
            sessionID: simulatedFill.sessionID,
            riskProfileID: simulatedFill.riskProfileID,
            side: simulatedFill.side,
            riskDecisionStatus: simulatedFill.riskDecisionStatus,
            exposure: PortfolioExposureSnapshot(
                portfolioID: portfolioID,
                symbol: simulatedFill.symbol,
                timeframe: simulatedFill.timeframe,
                paperQuantity: simulatedFill.filledQuantity,
                referencePrice: simulatedFill.fillPrice,
                source: .paperProjection,
                observedAt: updatedAt
            ),
            executionMode: simulatedFill.executionMode,
            sourceSequence: sourceSimulatedFillSequence,
            sourceOrderIntentSequence: simulatedFill.sourceOrderIntentSequence,
            sourceRiskDecisionSequence: simulatedFill.sourceRiskDecisionSequence,
            updatedAt: updatedAt,
            usesSimulatedFillEvidence: true,
            authorizesTradingExecution: false,
            readsRealAccountBalance: false,
            syncsBrokerPosition: false
        )
    }
}
