import DomainModel
import Foundation
import RiskEngine

/// GH-417 Core compatibility bridge 只保留 PaperPreTradeRiskEngine 的 MessageBus publish/replay 证据路径。
///
/// 纯 pre-trade 风控判断已经由 `RiskEngine` target 的 `PaperPreTradeRiskEngine` 拥有。
/// 本桥接文件只连接仍在 Core envelope 内的 `PaperRuntimeMessageBusRouting` / `MessageBus`
/// evidence，不实现 live risk runtime、ExecutionClient、OMS、broker gateway 或真实下单能力。
public struct PaperPreTradeRiskEnginePublication: Codable, Equatable, Sendable {
    public let decision: PaperPreTradeRiskEngineDecision
    public let routeEvidence: [PaperRuntimeRouteEvidence]
    public let replayEvidence: [PaperRuntimeRouteEvidence]

    public var replayMatchesRouteEvidence: Bool {
        replayEvidence == routeEvidence
    }

    public var rejectedDecisionEnteredReplay: Bool {
        decision.isRejected
            && replayEvidence.contains { $0.payloadKind == .paperRiskBlocked && $0.stream == .risk }
    }

    public init(
        decision: PaperPreTradeRiskEngineDecision,
        routeEvidence: [PaperRuntimeRouteEvidence],
        replayEvidence: [PaperRuntimeRouteEvidence]
    ) throws {
        guard routeEvidence.isEmpty == false else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "routeEvidence",
                expected: "at least one paper risk route evidence",
                actual: "empty"
            )
        }
        guard replayEvidence == routeEvidence else {
            throw CoreError.paperPreTradeRiskEngineMismatch(
                field: "replayEvidence",
                expected: "same as route evidence",
                actual: "drift"
            )
        }
        if decision.isRejected {
            guard replayEvidence.contains(where: { $0.payloadKind == .paperRiskBlocked && $0.stream == .risk }) else {
                throw CoreError.paperPreTradeRiskEngineMismatch(
                    field: "replayEvidence",
                    expected: "paperRiskBlocked evidence for rejected decision",
                    actual: replayEvidence.map(\.payloadKind.rawValue).joined(separator: ",")
                )
            }
        }

        self.decision = decision
        self.routeEvidence = routeEvidence
        self.replayEvidence = replayEvidence
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            decision: try container.decode(PaperPreTradeRiskEngineDecision.self, forKey: .decision),
            routeEvidence: try container.decode([PaperRuntimeRouteEvidence].self, forKey: .routeEvidence),
            replayEvidence: try container.decode([PaperRuntimeRouteEvidence].self, forKey: .replayEvidence)
        )
    }
}

/// PaperPreTradeRiskEngineRuntimePath 是 Core envelope 内的本地 evidence bridge。
///
/// `evaluate` 转发到 RiskEngine target 的 pure evaluator；`evaluateAndPublish` 额外复用
/// Core envelope 内的 routing 写入 `MessageBus` 并 replay。该路径不启动 actor、不访问
/// Persistence schema、不读取 Adapter 或 broker，也不提供 UI command。
public struct PaperPreTradeRiskEngineRuntimePath: Equatable, Sendable {
    public let routing: PaperRuntimeMessageBusRouting

    public init(routing: PaperRuntimeMessageBusRouting = PaperRuntimeMessageBusRouting()) {
        self.routing = routing
    }

    public func evaluate(
        decisionID: Identifier,
        input: PaperPreTradeRiskEngineInput
    ) throws -> PaperPreTradeRiskEngineDecision {
        try PaperPreTradeRiskEngine().evaluate(decisionID: decisionID, input: input)
    }

    public func evaluateAndPublish(
        decisionID: Identifier,
        input: PaperPreTradeRiskEngineInput,
        to messageBus: inout MessageBus,
        clock: TradingClock,
        envelopeIDs: [UUID],
        correlationID: UUID,
        rootCausationID: UUID?
    ) throws -> PaperPreTradeRiskEnginePublication {
        let decision = try evaluate(decisionID: decisionID, input: input)
        let firstNewSequence = messageBus.envelopes.count + 1
        let routeEvidence = try routing.publish(
            [.paperRiskDecision(decision.riskDecision)],
            to: &messageBus,
            clock: clock,
            envelopeIDs: envelopeIDs,
            correlationID: correlationID,
            rootCausationID: rootCausationID
        )
        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: firstNewSequence, upperBound: messageBus.envelopes.count),
                streams: [.risk]
            )
        )
        let replayEvidence = try PaperRuntimeMessageBusRouting.replayEvidence(from: replay)
        return try PaperPreTradeRiskEnginePublication(
            decision: decision,
            routeEvidence: routeEvidence,
            replayEvidence: replayEvidence
        )
    }
}

public extension PaperPreTradeRiskEngineFixture {
    static let deterministicClock: TradingClock = PaperRuntimeBusRoutingFixture.deterministicClock

    static func publishedRejectedDecision() throws -> (MessageBus, PaperPreTradeRiskEnginePublication) {
        var messageBus = try MessageBus()
        let publication = try PaperPreTradeRiskEngineRuntimePath().evaluateAndPublish(
            decisionID: try Identifier("mtp-98-paper-risk-rejected"),
            input: rejectedInput(),
            to: &messageBus,
            clock: deterministicClock,
            envelopeIDs: rejectedEnvelopeIDs,
            correlationID: correlationID,
            rootCausationID: rootCausationID
        )
        return (messageBus, publication)
    }
}
