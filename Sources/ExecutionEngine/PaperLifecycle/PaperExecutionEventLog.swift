import Foundation

/// Paper execution event log 边界把 MTP-41 的本地 decision chain 写入 append-only facts。
///
/// 该边界只负责把 `PaperExecutionDecision`、`PaperOrderIntent` 和
/// `PaperSimulatedFillEvidence` 固定写入 `.paper` stream。它不创建订单、不连接 broker、
/// 不调用 signed endpoint、不读取账户，也不更新 portfolio projection；portfolio update 必须由
/// replay 后的 simulated fill evidence 另行派生。

/// PaperExecutionEventAppendResult 记录一次写入产生的 envelope，供测试和 replay 串联。
public struct PaperExecutionEventAppendResult: Equatable, Sendable {
    public let decisionEnvelope: EventEnvelope
    public let orderIntentEnvelope: EventEnvelope?
    public let simulatedFillEnvelope: EventEnvelope?

    public var appendedEnvelopes: [EventEnvelope] {
        [decisionEnvelope, orderIntentEnvelope, simulatedFillEnvelope].compactMap { $0 }
    }

    public init(
        decisionEnvelope: EventEnvelope,
        orderIntentEnvelope: EventEnvelope?,
        simulatedFillEnvelope: EventEnvelope?
    ) {
        self.decisionEnvelope = decisionEnvelope
        self.orderIntentEnvelope = orderIntentEnvelope
        self.simulatedFillEnvelope = simulatedFillEnvelope
    }
}

/// PaperExecutionEventLogBoundary 只把 paper execution facts 追加到本地 `.paper` stream。
///
/// allowed decision 必须按 decision -> order intent -> simulated fill 顺序写入；blocked
/// decision 只能写入 decision fact，不能生成 order 或 fill。所有 sequence 仍由
/// `AppendOnlyEventLog` 分配，source sequence 校验用来阻止绕过 event log 的伪造输入。
public struct PaperExecutionEventLogBoundary: Equatable, Sendable {
    public init() {}

    @discardableResult
    public func append(
        _ decision: PaperExecutionDecision,
        to eventLog: inout AppendOnlyEventLog,
        recordedAt: Date,
        recordedAtStride: TimeInterval = 1
    ) throws -> PaperExecutionEventAppendResult {
        try validate(decision, nextDecisionSequence: eventLog.envelopes.count + 1)

        let decisionEnvelope = try eventLog.append(
            .paper(.executionDecisionRecorded(decision)),
            stream: .paper,
            recordedAt: recordedAt
        )

        guard decision.isAllowed else {
            return PaperExecutionEventAppendResult(
                decisionEnvelope: decisionEnvelope,
                orderIntentEnvelope: nil,
                simulatedFillEnvelope: nil
            )
        }

        let orderIntent = try unwrap(
            decision.paperOrderIntent,
            field: "paperOrderIntent",
            expected: "present for allowed decision"
        )
        let simulatedFill = try unwrap(
            decision.simulatedFillEvidence,
            field: "simulatedFillEvidence",
            expected: "present for allowed decision"
        )

        let orderEnvelope = try eventLog.append(
            .paper(.orderIntentRecorded(orderIntent)),
            stream: .paper,
            recordedAt: recordedAt.addingTimeInterval(recordedAtStride)
        )
        let fillEnvelope = try eventLog.append(
            .paper(.simulatedFillRecorded(simulatedFill)),
            stream: .paper,
            recordedAt: recordedAt.addingTimeInterval(recordedAtStride * 2)
        )

        return PaperExecutionEventAppendResult(
            decisionEnvelope: decisionEnvelope,
            orderIntentEnvelope: orderEnvelope,
            simulatedFillEnvelope: fillEnvelope
        )
    }

    private func validate(
        _ decision: PaperExecutionDecision,
        nextDecisionSequence: Int
    ) throws {
        guard decision.paperOnlyBoundaryHeld else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "paperOnlyBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard decision.eventStream == .paper else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "eventStream",
                expected: EventStreamID.paper.rawValue,
                actual: decision.eventStream.rawValue
            )
        }

        if decision.isAllowed {
            let expectedOrderSequence = nextDecisionSequence + 1
            guard decision.sourceOrderIntentSequence == expectedOrderSequence else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "sourceOrderIntentSequence",
                    expected: "\(expectedOrderSequence)",
                    actual: "\(String(describing: decision.sourceOrderIntentSequence))"
                )
            }
            guard decision.simulatedFillEvidence?.sourceOrderIntentSequence == expectedOrderSequence else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "simulatedFillEvidence.sourceOrderIntentSequence",
                    expected: "\(expectedOrderSequence)",
                    actual: "\(String(describing: decision.simulatedFillEvidence?.sourceOrderIntentSequence))"
                )
            }
        } else {
            guard decision.paperOrderIntent == nil, decision.simulatedFillEvidence == nil else {
                throw CoreError.paperExecutionDecisionMismatch(
                    field: "blockedDecisionArtifacts",
                    expected: "nil order and fill for blocked decision",
                    actual: "present"
                )
            }
        }
    }

    private func unwrap<T>(
        _ value: T?,
        field: String,
        expected: String
    ) throws -> T {
        guard let value else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: field,
                expected: expected,
                actual: "nil"
            )
        }
        return value
    }
}

/// PaperExecutionReplayProjectionPath 从 replay result 中提取 simulated fill 并生成 portfolio update。
///
/// 该路径明确要求输入来自 append-only event log replay，且只消费 `.paper` stream 中的
/// `simulatedFillRecorded` facts。它不会读取账户、broker position、SQLite schema 或任何
/// signed endpoint；输出仍是 `.portfolio` stream 可追加的本地 projection fact。
public enum PaperExecutionReplayProjectionPath {
    public static func simulatedFillEnvelopes(
        from replay: EventReplayResult
    ) throws -> [EventEnvelope] {
        try validateReplayOrder(replay.envelopes)
        return replay.envelopes.filter { envelope in
            if case .paper(.simulatedFillRecorded) = envelope.event {
                return true
            }
            return false
        }
    }

    public static func projectPortfolioUpdate(
        from simulatedFillEnvelope: EventEnvelope,
        updateID: Identifier,
        portfolioID: Identifier,
        updatedAt: Date
    ) throws -> PaperPortfolioProjectionUpdate {
        guard case let .paper(.simulatedFillRecorded(fill)) = simulatedFillEnvelope.event else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "event",
                expected: "paper.simulatedFillRecorded",
                actual: "\(simulatedFillEnvelope.event)"
            )
        }
        guard fill.paperOnlyBoundaryHeld else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "simulatedFill.paperOnlyBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }

        return try PaperPortfolioProjectionUpdate(
            updateID: updateID,
            portfolioID: portfolioID,
            simulatedFill: fill,
            sourceSimulatedFillSequence: simulatedFillEnvelope.sequence,
            updatedAt: updatedAt
        )
    }

    private static func validateReplayOrder(_ envelopes: [EventEnvelope]) throws {
        let sequences = envelopes.map(\.sequence)
        let sortedUnique = Array(Set(sequences)).sorted()
        guard sequences == sortedUnique else {
            throw CoreError.invalidSequenceRange
        }
    }
}
