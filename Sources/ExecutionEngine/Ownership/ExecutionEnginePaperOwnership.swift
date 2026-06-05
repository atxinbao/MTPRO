import DomainModel
import Foundation
import MessageBus
import RiskEngine

/// GH-398 的 ExecutionEngine 真实 target 所有权锚点。
///
/// ExecutionEngine 在当前阶段只接收 RiskEngine 的 paper decision evidence，并把它解释为
/// paper lifecycle readiness。旧 paper lifecycle / simulated exchange 运行时证据仍在 Core
/// compatibility envelope 中等待后续 retirement。本文件不实现 ExecutionClient、OMS、broker
/// gateway、submit / cancel / replace、execution report 或 broker fill。
public struct ExecutionEnginePaperOwnershipHandoff: Codable, Equatable, Sendable {
    public let handoffID: Identifier
    public let riskDecision: RiskEnginePreTradeOwnershipDecision
    public let executionMode: ExecutionMode
    public let acceptedForPaperLifecycle: Bool
    public let rejectedBeforePaperLifecycle: Bool
    public let validationAnchors: [String]
    public let touchesExecutionClient: Bool
    public let touchesOMS: Bool
    public let touchesBrokerGateway: Bool
    public let submitsRealOrder: Bool
    public let authorizesLiveTrading: Bool

    public var boundaryHeld: Bool {
        executionMode == .paper
            && touchesExecutionClient == false
            && touchesOMS == false
            && touchesBrokerGateway == false
            && submitsRealOrder == false
            && authorizesLiveTrading == false
            && validationAnchors.contains("GH-398-EXECUTIONENGINE-REAL-TARGET-OWNERSHIP")
    }

    public init(
        handoffID: Identifier,
        riskDecision: RiskEnginePreTradeOwnershipDecision,
        executionMode: ExecutionMode = .paper,
        validationAnchors: [String] = ["GH-398-EXECUTIONENGINE-REAL-TARGET-OWNERSHIP"],
        touchesExecutionClient: Bool = false,
        touchesOMS: Bool = false,
        touchesBrokerGateway: Bool = false,
        submitsRealOrder: Bool = false,
        authorizesLiveTrading: Bool = false
    ) throws {
        guard riskDecision.boundaryHeld else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "riskDecision.boundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard executionMode == .paper else {
            throw CoreError.paperExecutionDecisionForbiddenCapability("executionMode.\(executionMode.rawValue)")
        }
        let forbiddenFlags: [(String, Bool)] = [
            ("touchesExecutionClient", touchesExecutionClient),
            ("touchesOMS", touchesOMS),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("submitsRealOrder", submitsRealOrder),
            ("authorizesLiveTrading", authorizesLiveTrading)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperExecutionDecisionForbiddenCapability(forbidden.0)
        }

        self.handoffID = handoffID
        self.riskDecision = riskDecision
        self.executionMode = executionMode
        self.acceptedForPaperLifecycle = riskDecision.isAllowed
        self.rejectedBeforePaperLifecycle = riskDecision.isBlocked
        self.validationAnchors = validationAnchors
        self.touchesExecutionClient = touchesExecutionClient
        self.touchesOMS = touchesOMS
        self.touchesBrokerGateway = touchesBrokerGateway
        self.submitsRealOrder = submitsRealOrder
        self.authorizesLiveTrading = authorizesLiveTrading
    }
}

/// GH-398 的 ExecutionEngine paper handoff evaluator。
///
/// 它只做 RiskEngine decision -> paper lifecycle readiness 的本地映射，不创建订单、
/// 不写 event log、不连接 ExecutionClient，也不提供 Live command surface。
public enum ExecutionEnginePaperOwnershipEvaluator {
    public static func handoff(
        handoffID: Identifier,
        riskDecision: RiskEnginePreTradeOwnershipDecision
    ) throws -> ExecutionEnginePaperOwnershipHandoff {
        try ExecutionEnginePaperOwnershipHandoff(
            handoffID: handoffID,
            riskDecision: riskDecision
        )
    }
}
