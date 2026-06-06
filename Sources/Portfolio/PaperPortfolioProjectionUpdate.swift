import DomainModel
import Foundation
import MessageBus

/// MTP-187 将 portfolio projection update 放入 `Sources/Portfolio/`，保持 Core compatibility envelope。
/// 该 update 仍只消费 replay 后的 simulated fill evidence，不同步 broker position 或真实账户余额。
/// Paper portfolio projection update 把 replay 后的 simulated fill evidence 转成组合 exposure 更新事件。
///
/// 输入只能是 MTP-40 / MTP-41 生成并经 MTP-42 event log replay 取回的
/// `PaperSimulatedFillEvidence`；输出只是一条本地 paper-only portfolio projection fact，
/// 可被 replay / SQLite runtime projection 消费。该路径不读取真实账户余额、不同步 broker
/// position、不处理 margin / leverage，也不提交、取消或替换任何真实订单。
public struct PaperPortfolioProjectionUpdate: Codable, Equatable, Sendable {
    public let updateID: Identifier
    public let decisionID: Identifier
    public let orderID: Identifier
    public let fillID: Identifier
    public let proposalID: Identifier
    public let sessionID: Identifier
    public let riskProfileID: Identifier
    public let side: PaperActionProposalSide
    public let riskDecisionStatus: PaperActionProposalRiskDecisionStatus
    public let exposure: PortfolioExposureSnapshot
    public let executionMode: ExecutionMode
    public let sourceSequence: Int
    public let sourceOrderIntentSequence: Int
    public let sourceRiskDecisionSequence: Int
    public let updatedAt: Date
    public let usesSimulatedFillEvidence: Bool
    public let authorizesTradingExecution: Bool
    public let readsRealAccountBalance: Bool
    public let syncsBrokerPosition: Bool

    public var portfolioID: Identifier {
        exposure.portfolioID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            updateID: try container.decode(Identifier.self, forKey: .updateID),
            decisionID: try container.decode(Identifier.self, forKey: .decisionID),
            orderID: try container.decode(Identifier.self, forKey: .orderID),
            fillID: try container.decode(Identifier.self, forKey: .fillID),
            proposalID: try container.decode(Identifier.self, forKey: .proposalID),
            sessionID: try container.decode(Identifier.self, forKey: .sessionID),
            riskProfileID: try container.decode(Identifier.self, forKey: .riskProfileID),
            side: try container.decode(PaperActionProposalSide.self, forKey: .side),
            riskDecisionStatus: try container.decode(
                PaperActionProposalRiskDecisionStatus.self,
                forKey: .riskDecisionStatus
            ),
            exposure: try container.decode(PortfolioExposureSnapshot.self, forKey: .exposure),
            executionMode: try container.decode(ExecutionMode.self, forKey: .executionMode),
            sourceSequence: try container.decode(Int.self, forKey: .sourceSequence),
            sourceOrderIntentSequence: try container.decode(Int.self, forKey: .sourceOrderIntentSequence),
            sourceRiskDecisionSequence: try container.decode(Int.self, forKey: .sourceRiskDecisionSequence),
            updatedAt: try container.decode(Date.self, forKey: .updatedAt),
            usesSimulatedFillEvidence: try container.decode(Bool.self, forKey: .usesSimulatedFillEvidence),
            authorizesTradingExecution: try container.decode(
                Bool.self,
                forKey: .authorizesTradingExecution
            ),
            readsRealAccountBalance: try container.decode(Bool.self, forKey: .readsRealAccountBalance),
            syncsBrokerPosition: try container.decode(Bool.self, forKey: .syncsBrokerPosition)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(updateID, forKey: .updateID)
        try container.encode(decisionID, forKey: .decisionID)
        try container.encode(orderID, forKey: .orderID)
        try container.encode(fillID, forKey: .fillID)
        try container.encode(proposalID, forKey: .proposalID)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(riskProfileID, forKey: .riskProfileID)
        try container.encode(side, forKey: .side)
        try container.encode(riskDecisionStatus, forKey: .riskDecisionStatus)
        try container.encode(exposure, forKey: .exposure)
        try container.encode(executionMode, forKey: .executionMode)
        try container.encode(sourceSequence, forKey: .sourceSequence)
        try container.encode(sourceOrderIntentSequence, forKey: .sourceOrderIntentSequence)
        try container.encode(sourceRiskDecisionSequence, forKey: .sourceRiskDecisionSequence)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(usesSimulatedFillEvidence, forKey: .usesSimulatedFillEvidence)
        try container.encode(authorizesTradingExecution, forKey: .authorizesTradingExecution)
        try container.encode(readsRealAccountBalance, forKey: .readsRealAccountBalance)
        try container.encode(syncsBrokerPosition, forKey: .syncsBrokerPosition)
    }

    public init(
        updateID: Identifier,
        decisionID: Identifier,
        orderID: Identifier,
        fillID: Identifier,
        proposalID: Identifier,
        sessionID: Identifier,
        riskProfileID: Identifier,
        side: PaperActionProposalSide,
        riskDecisionStatus: PaperActionProposalRiskDecisionStatus,
        exposure: PortfolioExposureSnapshot,
        executionMode: ExecutionMode,
        sourceSequence: Int,
        sourceOrderIntentSequence: Int,
        sourceRiskDecisionSequence: Int,
        updatedAt: Date,
        usesSimulatedFillEvidence: Bool,
        authorizesTradingExecution: Bool,
        readsRealAccountBalance: Bool,
        syncsBrokerPosition: Bool
    ) throws {
        guard riskDecisionStatus == .allowed else {
            throw CoreError.paperPortfolioProjectionRequiresAllowedRiskDecision(riskDecisionStatus.rawValue)
        }
        guard executionMode == .paper else {
            throw CoreError.paperPortfolioProjectionRequiresPaperMode(executionMode)
        }
        guard sourceSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceSequence)
        }
        guard sourceOrderIntentSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceOrderIntentSequence)
        }
        guard sourceRiskDecisionSequence > 0 else {
            throw CoreError.invalidEventSequence(sourceRiskDecisionSequence)
        }
        guard sourceSequence > sourceOrderIntentSequence else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "sourceSequence",
                expected: "greater than sourceOrderIntentSequence",
                actual: "\(sourceSequence)"
            )
        }
        guard exposure.source == .paperProjection else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "source",
                expected: PortfolioExposureSource.paperProjection.rawValue,
                actual: exposure.source.rawValue
            )
        }
        try Self.validateSideQuantity(side: side, exposure: exposure)
        try Self.validateExposureNotional(exposure)
        guard exposure.observedAt == updatedAt else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "observedAt",
                expected: "\(updatedAt.timeIntervalSince1970)",
                actual: "\(exposure.observedAt.timeIntervalSince1970)"
            )
        }
        guard usesSimulatedFillEvidence else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "usesSimulatedFillEvidence",
                expected: "true",
                actual: "false"
            )
        }
        guard authorizesTradingExecution == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("authorizesTradingExecution")
        }
        guard readsRealAccountBalance == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("readsRealAccountBalance")
        }
        guard syncsBrokerPosition == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("syncsBrokerPosition")
        }

        self.updateID = updateID
        self.decisionID = decisionID
        self.orderID = orderID
        self.fillID = fillID
        self.proposalID = proposalID
        self.sessionID = sessionID
        self.riskProfileID = riskProfileID
        self.side = side
        self.riskDecisionStatus = riskDecisionStatus
        self.exposure = exposure
        self.executionMode = executionMode
        self.sourceSequence = sourceSequence
        self.sourceOrderIntentSequence = sourceOrderIntentSequence
        self.sourceRiskDecisionSequence = sourceRiskDecisionSequence
        self.updatedAt = updatedAt
        self.usesSimulatedFillEvidence = usesSimulatedFillEvidence
        self.authorizesTradingExecution = authorizesTradingExecution
        self.readsRealAccountBalance = readsRealAccountBalance
        self.syncsBrokerPosition = syncsBrokerPosition
    }

    private static func validateSideQuantity(
        side: PaperActionProposalSide,
        exposure: PortfolioExposureSnapshot
    ) throws {
        switch side {
        case .buy:
            guard exposure.paperQuantity.rawValue > 0 else {
                throw CoreError.paperPortfolioProjectionMismatch(
                    field: "paperQuantity",
                    expected: "positive for buy",
                    actual: "\(exposure.paperQuantity.rawValue)"
                )
            }
        case .hold:
            guard exposure.paperQuantity.rawValue == 0 else {
                throw CoreError.paperPortfolioProjectionMismatch(
                    field: "paperQuantity",
                    expected: "0 for hold",
                    actual: "\(exposure.paperQuantity.rawValue)"
                )
            }
        }
    }

    private static func validateExposureNotional(_ exposure: PortfolioExposureSnapshot) throws {
        let expected = exposure.paperQuantity.rawValue * exposure.referencePrice.rawValue
        guard exposure.grossExposureNotional == expected else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "grossExposureNotional",
                expected: "\(expected)",
                actual: "\(exposure.grossExposureNotional)"
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case updateID
        case decisionID
        case orderID
        case fillID
        case proposalID
        case sessionID
        case riskProfileID
        case side
        case riskDecisionStatus
        case exposure
        case executionMode
        case sourceSequence
        case sourceOrderIntentSequence
        case sourceRiskDecisionSequence
        case updatedAt
        case usesSimulatedFillEvidence
        case authorizesTradingExecution
        case readsRealAccountBalance
        case syncsBrokerPosition
    }
}
