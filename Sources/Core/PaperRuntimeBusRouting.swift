import Foundation

/// MTP-97 的 paper runtime bus routing 只在 Core 层定义 deterministic command / event / message 路由。
///
/// 该文件复用既有 `MessageBus` / `AppendOnlyEventLog` 作为 append-only facts source，并显式保留
/// correlation / causation / source evidence。它不是 live command plane，不连接 broker / exchange，
/// 不路由 signed request，不实现 execution report、broker fill、reconciliation、真实订单命令或交易按钮。

/// PaperRuntimeBusName 固定 MTP-97 允许出现的三类本地 bus 名称。
///
/// `commandBus` 只负责把 paper-only 输入转成待发布消息；`eventBus` 只负责把这些消息发布到既有
/// `MessageBus`；`messageBus` 仍是 append-only event log 的复用边界，不代表外部 message broker。
public enum PaperRuntimeBusName: String, Codable, CaseIterable, Equatable, Sendable {
    case commandBus
    case eventBus
    case messageBus
}

/// PaperRuntimeRouteSource 描述 MTP-97 允许进入 routing 的 paper-only 输入来源。
///
/// 这些来源只覆盖当前 Linear issue 指定的 session command、paper risk decision、lifecycle event 和
/// simulated fill event。MTP-98 可以把 Paper Pre-trade RiskEngine 产生的 paper-only decision 放入
/// `.paperRiskDecision` route；lifecycle coordinator、portfolio projection 仍由后续 issue 单独实现，
/// 不能在本路由层扩大 scope。
public enum PaperRuntimeRouteSource: String, Codable, CaseIterable, Equatable, Sendable {
    case paperSessionCommand
    case paperRiskDecision
    case paperLifecycleEvent
    case simulatedFillEvent
}

/// PaperRuntimeRoutePayloadKind 标记 route 后真正进入 event log 的 payload 类别。
///
/// risk decision 会拆成既有 `.risk` stream 里的 evaluation requested / blocked evidence；MTP-98 的
/// accepted decision 只写入 evaluation requested，rejected decision 额外写入 blocked evidence。这样能
/// 复用当前 `RiskEvent` 合同，同时保持 replay 后的 route evidence 可由 envelope 反推。
public enum PaperRuntimeRoutePayloadKind: String, Codable, CaseIterable, Equatable, Sendable {
    case paperSessionCommand
    case paperRiskEvaluationRequested
    case paperRiskBlocked
    case paperLifecycleStarted
    case paperLifecycleUpdated
    case paperLifecycleClosed
    case simulatedFillRecorded
}

/// PaperRuntimeRouteInput 是 CommandBus 接受的 paper-only routing 输入。
///
/// 输入类型全部来自既有 Core 合同，避免为 MTP-97 引入新的执行语义。CommandBus 会把它们转成
/// `PaperRuntimeRoutedMessage`，再交给 EventBus 发布到复用的 `MessageBus`。
public enum PaperRuntimeRouteInput: Codable, Equatable, Sendable {
    case paperSessionCommand(PaperSessionCommand)
    case paperRiskDecision(PaperActionProposalRiskDecision)
    case paperLifecycleEvent(PaperEvent)
    case simulatedFillEvent(PaperSimulatedFillEvidence)

    public var source: PaperRuntimeRouteSource {
        switch self {
        case .paperSessionCommand:
            .paperSessionCommand
        case .paperRiskDecision:
            .paperRiskDecision
        case .paperLifecycleEvent:
            .paperLifecycleEvent
        case .simulatedFillEvent:
            .simulatedFillEvent
        }
    }

    fileprivate func routePayloads() throws -> [PaperRuntimeRoutePayload] {
        switch self {
        case let .paperSessionCommand(command):
            return [
                PaperRuntimeRoutePayload(
                    source: source,
                    payloadKind: .paperSessionCommand,
                    stream: .paper,
                    event: .paper(.sessionRequested(command))
                )
            ]
        case let .paperRiskDecision(decision):
            guard decision.paperOnlyContextIsConsistent else {
                throw CoreError.paperRuntimeBusRoutingMismatch(
                    field: "paperRiskDecision.paperOnlyContextIsConsistent",
                    expected: "true",
                    actual: "false"
                )
            }
            return decision.riskEvents.map { riskEvent in
                PaperRuntimeRoutePayload(
                    source: source,
                    payloadKind: Self.payloadKind(for: riskEvent),
                    stream: .risk,
                    event: .risk(riskEvent)
                )
            }
        case let .paperLifecycleEvent(event):
            let payloadKind = try Self.payloadKind(forLifecycleEvent: event)
            return [
                PaperRuntimeRoutePayload(
                    source: source,
                    payloadKind: payloadKind,
                    stream: .paper,
                    event: .paper(event)
                )
            ]
        case let .simulatedFillEvent(fill):
            guard fill.paperOnlyBoundaryHeld else {
                throw CoreError.paperRuntimeBusRoutingMismatch(
                    field: "simulatedFill.paperOnlyBoundaryHeld",
                    expected: "true",
                    actual: "false"
                )
            }
            return [
                PaperRuntimeRoutePayload(
                    source: source,
                    payloadKind: .simulatedFillRecorded,
                    stream: .paper,
                    event: .paper(.simulatedFillRecorded(fill))
                )
            ]
        }
    }

    private static func payloadKind(for riskEvent: RiskEvent) -> PaperRuntimeRoutePayloadKind {
        switch riskEvent {
        case .evaluationRequested:
            .paperRiskEvaluationRequested
        case .blocked:
            .paperRiskBlocked
        }
    }

    private static func payloadKind(forLifecycleEvent event: PaperEvent) throws -> PaperRuntimeRoutePayloadKind {
        switch event {
        case .sessionStarted:
            .paperLifecycleStarted
        case .sessionUpdated:
            .paperLifecycleUpdated
        case .sessionClosed:
            .paperLifecycleClosed
        default:
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "paperLifecycleEvent",
                expected: "sessionStarted/sessionUpdated/sessionClosed",
                actual: event.routeDebugName
            )
        }
    }
}

private struct PaperRuntimeRoutePayload: Equatable, Sendable {
    let source: PaperRuntimeRouteSource
    let payloadKind: PaperRuntimeRoutePayloadKind
    let stream: EventStreamID
    let event: DomainEvent
}

/// PaperRuntimeRoutedMessage 是 CommandBus 输出、EventBus 输入的 deterministic route envelope。
///
/// `envelopeID`、`correlationID` 和 `causationID` 由调用方显式提供，避免 replay evidence 依赖随机
/// UUID。`recordedAt` 来自 `TradingClock` tick，不能来自 wall clock。所有 event 都会在初始化时
/// 反查 payload kind / source，拒绝 market、backtest、live、signed、broker 或不属于 MTP-97 的事件。
public struct PaperRuntimeRoutedMessage: Codable, Equatable, Sendable {
    public let routeSequence: Int
    public let envelopeID: UUID
    public let source: PaperRuntimeRouteSource
    public let payloadKind: PaperRuntimeRoutePayloadKind
    public let stream: EventStreamID
    public let event: DomainEvent
    public let recordedAt: Date
    public let correlationID: UUID
    public let causationID: UUID?

    public init(
        routeSequence: Int,
        envelopeID: UUID,
        source: PaperRuntimeRouteSource,
        payloadKind: PaperRuntimeRoutePayloadKind,
        stream: EventStreamID,
        event: DomainEvent,
        recordedAt: Date,
        correlationID: UUID,
        causationID: UUID?
    ) throws {
        guard routeSequence > 0 else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "routeSequence",
                expected: "positive monotonic route sequence",
                actual: "\(routeSequence)"
            )
        }
        let classification = try PaperRuntimeRouteClassifier.classify(event)
        guard classification.source == source else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "source",
                expected: classification.source.rawValue,
                actual: source.rawValue
            )
        }
        guard classification.payloadKind == payloadKind else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "payloadKind",
                expected: classification.payloadKind.rawValue,
                actual: payloadKind.rawValue
            )
        }
        guard classification.stream == stream else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "stream",
                expected: classification.stream.rawValue,
                actual: stream.rawValue
            )
        }

        self.routeSequence = routeSequence
        self.envelopeID = envelopeID
        self.source = source
        self.payloadKind = payloadKind
        self.stream = stream
        self.event = event
        self.recordedAt = recordedAt
        self.correlationID = correlationID
        self.causationID = causationID
    }
}

/// PaperRuntimeRouteEvidence 是 replay 后可复现的 route evidence 摘要。
///
/// 它只记录 envelope 的稳定追踪字段和 route 分类，不暴露 Runtime object、Persistence schema 或
/// adapter payload。`init(envelope:)` 会重新分类 event，确保 replay evidence 与原发布 evidence 一致。
public struct PaperRuntimeRouteEvidence: Codable, Equatable, Sendable {
    public let envelopeID: UUID
    public let eventSequence: Int
    public let source: PaperRuntimeRouteSource
    public let payloadKind: PaperRuntimeRoutePayloadKind
    public let stream: EventStreamID
    public let recordedAt: Date
    public let correlationID: UUID?
    public let causationID: UUID?

    public init(envelope: EventEnvelope) throws {
        let classification = try PaperRuntimeRouteClassifier.classify(envelope.event)
        self.envelopeID = envelope.id
        self.eventSequence = envelope.sequence
        self.source = classification.source
        self.payloadKind = classification.payloadKind
        self.stream = envelope.stream
        self.recordedAt = envelope.recordedAt
        self.correlationID = envelope.correlationID
        self.causationID = envelope.causationID

        guard envelope.stream == classification.stream else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "envelope.stream",
                expected: classification.stream.rawValue,
                actual: envelope.stream.rawValue
            )
        }
    }
}

/// PaperRuntimeCommandBus 把 paper-only 输入确定性展开为待发布消息。
///
/// 该 bus 不执行命令、不读取 adapter、不写 event log；它只做输入分类、route ordering、clock tick
/// 绑定和 causation chain 生成。调用方必须提供 deterministic `TradingClock` 和 envelope IDs。
public struct PaperRuntimeCommandBus: Equatable, Sendable {
    public init() {}

    public func route(
        _ inputs: [PaperRuntimeRouteInput],
        clock: TradingClock,
        envelopeIDs: [UUID],
        correlationID: UUID,
        rootCausationID: UUID?
    ) throws -> [PaperRuntimeRoutedMessage] {
        guard clock.isDeterministic else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "clock.isDeterministic",
                expected: "true",
                actual: "false"
            )
        }

        let payloads = try inputs.flatMap { try $0.routePayloads() }
        guard payloads.isEmpty == false else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "inputs",
                expected: "at least one paper runtime route input",
                actual: "empty"
            )
        }
        guard envelopeIDs.count == payloads.count else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "envelopeIDs.count",
                expected: "\(payloads.count)",
                actual: "\(envelopeIDs.count)"
            )
        }
        guard Set(envelopeIDs).count == envelopeIDs.count else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "envelopeIDs",
                expected: "unique deterministic envelope IDs",
                actual: "duplicates"
            )
        }
        guard clock.ticks.count >= payloads.count else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "clock.ticks.count",
                expected: "at least \(payloads.count)",
                actual: "\(clock.ticks.count)"
            )
        }

        var previousCausationID = rootCausationID
        var routedMessages: [PaperRuntimeRoutedMessage] = []

        for (index, payload) in payloads.enumerated() {
            let envelopeID = envelopeIDs[index]
            let message = try PaperRuntimeRoutedMessage(
                routeSequence: index + 1,
                envelopeID: envelopeID,
                source: payload.source,
                payloadKind: payload.payloadKind,
                stream: payload.stream,
                event: payload.event,
                recordedAt: clock.ticks[index].instant,
                correlationID: correlationID,
                causationID: previousCausationID
            )
            routedMessages.append(message)
            previousCausationID = envelopeID
        }

        return routedMessages
    }
}

/// PaperRuntimeEventBus 把 CommandBus 产出的 route message 发布到既有 MessageBus。
///
/// 它只调用 `MessageBus.publish`，不持有状态、不连接外部 broker、不实现外部 pub/sub。sequence 仍由
/// append-only event log 分配，routeSequence 只用来校验本批输入顺序没有被重排。
public struct PaperRuntimeEventBus: Equatable, Sendable {
    public init() {}

    @discardableResult
    public func publish(
        _ messages: [PaperRuntimeRoutedMessage],
        to messageBus: inout MessageBus
    ) throws -> [PaperRuntimeRouteEvidence] {
        try Self.validateRouteOrder(messages)
        var evidence: [PaperRuntimeRouteEvidence] = []

        for message in messages {
            let envelope = try messageBus.publish(
                message.event,
                stream: message.stream,
                id: message.envelopeID,
                recordedAt: message.recordedAt,
                correlationID: message.correlationID,
                causationID: message.causationID
            )
            evidence.append(try PaperRuntimeRouteEvidence(envelope: envelope))
        }

        return evidence
    }

    private static func validateRouteOrder(_ messages: [PaperRuntimeRoutedMessage]) throws {
        let expected = Array(1...messages.count)
        let actual = messages.map(\.routeSequence)
        guard actual == expected else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "routeSequence",
                expected: expected.map(String.init).joined(separator: ","),
                actual: actual.map(String.init).joined(separator: ",")
            )
        }
    }
}

/// PaperRuntimeMessageBusRouting 串联 CommandBus、EventBus 和既有 MessageBus。
///
/// 这是 MTP-97 的便利编排入口：调用方给定 paper-only route inputs、deterministic clock 和 IDs，
/// 本类型返回可 replay 的 route evidence。它不会启动 Runtime actor，也不会创建任何 live command bus。
public struct PaperRuntimeMessageBusRouting: Equatable, Sendable {
    public let commandBus: PaperRuntimeCommandBus
    public let eventBus: PaperRuntimeEventBus

    public init(
        commandBus: PaperRuntimeCommandBus = PaperRuntimeCommandBus(),
        eventBus: PaperRuntimeEventBus = PaperRuntimeEventBus()
    ) {
        self.commandBus = commandBus
        self.eventBus = eventBus
    }

    @discardableResult
    public func publish(
        _ inputs: [PaperRuntimeRouteInput],
        to messageBus: inout MessageBus,
        clock: TradingClock,
        envelopeIDs: [UUID],
        correlationID: UUID,
        rootCausationID: UUID?
    ) throws -> [PaperRuntimeRouteEvidence] {
        let messages = try commandBus.route(
            inputs,
            clock: clock,
            envelopeIDs: envelopeIDs,
            correlationID: correlationID,
            rootCausationID: rootCausationID
        )
        return try eventBus.publish(messages, to: &messageBus)
    }

    public static func replayEvidence(from replay: EventReplayResult) throws -> [PaperRuntimeRouteEvidence] {
        try validateReplayOrder(replay.envelopes)
        return try replay.envelopes.map(PaperRuntimeRouteEvidence.init(envelope:))
    }

    private static func validateReplayOrder(_ envelopes: [EventEnvelope]) throws {
        let sequences = envelopes.map(\.sequence)
        let sortedUnique = Array(Set(sequences)).sorted()
        guard sequences == sortedUnique else {
            throw CoreError.invalidSequenceRange
        }
    }
}

/// PaperRuntimeBusRoutingContract 固定 MTP-97 的允许集合、validation anchors 和 forbidden capabilities。
///
/// 该合同用于 tests / validation matrix / automation readiness。所有 forbidden flags 默认 false；任何
/// Codable payload 试图启用 live command、real order、broker、signed/account/listenKey、execution
/// report、broker fill 或 reconciliation routing 都会被拒绝。
public struct PaperRuntimeBusRoutingContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let buses: [PaperRuntimeBusName]
    public let routeSources: [PaperRuntimeRouteSource]
    public let payloadKinds: [PaperRuntimeRoutePayloadKind]
    public let eventStreams: [EventStreamID]
    public let validationAnchors: [String]
    public let usesLiveCommandBus: Bool
    public let routesRealOrderCommand: Bool
    public let connectsBroker: Bool
    public let routesSignedRequest: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let routesExecutionReport: Bool
    public let routesBrokerFill: Bool
    public let routesReconciliation: Bool

    public var paperOnlyBoundaryHeld: Bool {
        usesLiveCommandBus == false
            && routesRealOrderCommand == false
            && connectsBroker == false
            && routesSignedRequest == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && routesExecutionReport == false
            && routesBrokerFill == false
            && routesReconciliation == false
    }

    public var deterministicRoutingBoundaryHeld: Bool {
        buses == PaperRuntimeBusName.allCases
            && routeSources == PaperRuntimeRouteSource.allCases
            && payloadKinds == PaperRuntimeRoutePayloadKind.allCases
            && eventStreams == [.paper, .risk]
            && validationAnchors.contains("MTP-97-PAPER-RUNTIME-BUS-VALIDATION")
    }

    public init(
        contractID: Identifier,
        issueID: Identifier,
        buses: [PaperRuntimeBusName] = PaperRuntimeBusName.allCases,
        routeSources: [PaperRuntimeRouteSource] = PaperRuntimeRouteSource.allCases,
        payloadKinds: [PaperRuntimeRoutePayloadKind] = PaperRuntimeRoutePayloadKind.allCases,
        eventStreams: [EventStreamID] = [.paper, .risk],
        validationAnchors: [String] = Self.requiredValidationAnchors,
        usesLiveCommandBus: Bool = false,
        routesRealOrderCommand: Bool = false,
        connectsBroker: Bool = false,
        routesSignedRequest: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        routesExecutionReport: Bool = false,
        routesBrokerFill: Bool = false,
        routesReconciliation: Bool = false
    ) throws {
        try Self.validateAllowedCollections(
            buses: buses,
            routeSources: routeSources,
            payloadKinds: payloadKinds,
            eventStreams: eventStreams,
            validationAnchors: validationAnchors
        )
        try Self.validateForbiddenCapabilities(
            usesLiveCommandBus: usesLiveCommandBus,
            routesRealOrderCommand: routesRealOrderCommand,
            connectsBroker: connectsBroker,
            routesSignedRequest: routesSignedRequest,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            routesExecutionReport: routesExecutionReport,
            routesBrokerFill: routesBrokerFill,
            routesReconciliation: routesReconciliation
        )

        self.contractID = contractID
        self.issueID = issueID
        self.buses = buses
        self.routeSources = routeSources
        self.payloadKinds = payloadKinds
        self.eventStreams = eventStreams
        self.validationAnchors = validationAnchors
        self.usesLiveCommandBus = usesLiveCommandBus
        self.routesRealOrderCommand = routesRealOrderCommand
        self.connectsBroker = connectsBroker
        self.routesSignedRequest = routesSignedRequest
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.routesExecutionReport = routesExecutionReport
        self.routesBrokerFill = routesBrokerFill
        self.routesReconciliation = routesReconciliation
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            buses: try container.decode([PaperRuntimeBusName].self, forKey: .buses),
            routeSources: try container.decode([PaperRuntimeRouteSource].self, forKey: .routeSources),
            payloadKinds: try container.decode([PaperRuntimeRoutePayloadKind].self, forKey: .payloadKinds),
            eventStreams: try container.decode([EventStreamID].self, forKey: .eventStreams),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            usesLiveCommandBus: try container.decode(Bool.self, forKey: .usesLiveCommandBus),
            routesRealOrderCommand: try container.decode(Bool.self, forKey: .routesRealOrderCommand),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            routesSignedRequest: try container.decode(Bool.self, forKey: .routesSignedRequest),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            routesExecutionReport: try container.decode(Bool.self, forKey: .routesExecutionReport),
            routesBrokerFill: try container.decode(Bool.self, forKey: .routesBrokerFill),
            routesReconciliation: try container.decode(Bool.self, forKey: .routesReconciliation)
        )
    }

    public static let requiredValidationAnchors: [String] = [
        "TVM-PAPER-RUNTIME-KERNEL",
        "MTP-97-COMMANDBUS-EVENTBUS-MESSAGEBUS-ROUTING",
        "MTP-97-DETERMINISTIC-PAPER-ROUTE-ORDER",
        "MTP-97-REPLAYABLE-ROUTE-EVIDENCE",
        "MTP-97-NO-LIVE-SIGNED-BROKER-ROUTING",
        "MTP-97-PAPER-RUNTIME-BUS-VALIDATION"
    ]

    public static let deterministicFixture: PaperRuntimeBusRoutingContract = {
        do {
            return try PaperRuntimeBusRoutingContract(
                contractID: try Identifier("mtp-97-paper-runtime-bus-routing-contract"),
                issueID: try Identifier("MTP-97")
            )
        } catch {
            preconditionFailure("Invalid MTP-97 PaperRuntimeBusRoutingContract fixture: \(error)")
        }
    }()

    private static func validateAllowedCollections(
        buses: [PaperRuntimeBusName],
        routeSources: [PaperRuntimeRouteSource],
        payloadKinds: [PaperRuntimeRoutePayloadKind],
        eventStreams: [EventStreamID],
        validationAnchors: [String]
    ) throws {
        guard buses == PaperRuntimeBusName.allCases else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "buses",
                expected: PaperRuntimeBusName.allCases.map(\.rawValue).joined(separator: ","),
                actual: buses.map(\.rawValue).joined(separator: ",")
            )
        }
        guard routeSources == PaperRuntimeRouteSource.allCases else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "routeSources",
                expected: PaperRuntimeRouteSource.allCases.map(\.rawValue).joined(separator: ","),
                actual: routeSources.map(\.rawValue).joined(separator: ",")
            )
        }
        guard payloadKinds == PaperRuntimeRoutePayloadKind.allCases else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "payloadKinds",
                expected: PaperRuntimeRoutePayloadKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: payloadKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard eventStreams == [.paper, .risk] else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "eventStreams",
                expected: "paper,risk",
                actual: eventStreams.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == requiredValidationAnchors else {
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "validationAnchors",
                expected: requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenCapabilities(
        usesLiveCommandBus: Bool,
        routesRealOrderCommand: Bool,
        connectsBroker: Bool,
        routesSignedRequest: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        routesExecutionReport: Bool,
        routesBrokerFill: Bool,
        routesReconciliation: Bool
    ) throws {
        let forbiddenFlags: [(String, Bool)] = [
            ("usesLiveCommandBus", usesLiveCommandBus),
            ("routesRealOrderCommand", routesRealOrderCommand),
            ("connectsBroker", connectsBroker),
            ("routesSignedRequest", routesSignedRequest),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("routesExecutionReport", routesExecutionReport),
            ("routesBrokerFill", routesBrokerFill),
            ("routesReconciliation", routesReconciliation)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperRuntimeBusRoutingForbiddenCapability(forbidden.0)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case contractID
        case issueID
        case buses
        case routeSources
        case payloadKinds
        case eventStreams
        case validationAnchors
        case usesLiveCommandBus
        case routesRealOrderCommand
        case connectsBroker
        case routesSignedRequest
        case callsAccountEndpoint
        case createsListenKey
        case routesExecutionReport
        case routesBrokerFill
        case routesReconciliation
    }
}

/// PaperRuntimeBusRoutingFixture 提供 MTP-97 deterministic tracer bullet。
///
/// Fixture 串联 session command、blocked paper risk decision、session started lifecycle 和 simulated fill
/// event，输出固定五条 route message。它只服务 tests / PR evidence，不代表 production runtime actor。
public enum PaperRuntimeBusRoutingFixture {
    public static let correlationID = deterministicUUID("11111111-1111-4111-8111-111111111197")
    public static let rootCausationID = deterministicUUID("22222222-2222-4222-8222-222222222197")
    public static let envelopeIDs: [UUID] = [
        deterministicUUID("97000000-0000-4000-8000-000000000001"),
        deterministicUUID("97000000-0000-4000-8000-000000000002"),
        deterministicUUID("97000000-0000-4000-8000-000000000003"),
        deterministicUUID("97000000-0000-4000-8000-000000000004"),
        deterministicUUID("97000000-0000-4000-8000-000000000005")
    ]

    public static let deterministicClock: TradingClock = {
        do {
            return try TradingClock(
                clockID: try Identifier("mtp-97-paper-runtime-bus-routing-clock"),
                issueID: try Identifier("MTP-97"),
                ticks: [
                    TradingClockTick(
                        sequence: 1,
                        instant: Date(timeIntervalSince1970: 3_000),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 2,
                        instant: Date(timeIntervalSince1970: 3_001),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 3,
                        instant: Date(timeIntervalSince1970: 3_002),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 4,
                        instant: Date(timeIntervalSince1970: 3_003),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 5,
                        instant: Date(timeIntervalSince1970: 3_004),
                        source: .deterministicFixture
                    )
                ],
                validationAnchors: [
                    "MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME",
                    "MTP-97-DETERMINISTIC-PAPER-ROUTE-ORDER",
                    "MTP-97-PAPER-RUNTIME-BUS-VALIDATION"
                ]
            )
        } catch {
            preconditionFailure("Invalid MTP-97 bus routing clock fixture: \(error)")
        }
    }()

    public static func routeInputs() throws -> [PaperRuntimeRouteInput] {
        let command = try paperSessionCommand()
        let started = PaperSessionStarted(
            command: command,
            startedAt: Date(timeIntervalSince1970: 3_003)
        )
        let fill = try PaperExecutionDecisionFixture.deterministicAllowed().simulatedFillEvidence
            ?? missingFixture("PaperExecutionDecisionFixture.deterministicAllowed().simulatedFillEvidence")

        return [
            .paperSessionCommand(command),
            .paperRiskDecision(try PaperActionProposalRiskFixture.deterministicBlocked()),
            .paperLifecycleEvent(.sessionStarted(started)),
            .simulatedFillEvent(fill)
        ]
    }

    public static func publishDeterministicRoute() throws -> (MessageBus, [PaperRuntimeRouteEvidence]) {
        var messageBus = try MessageBus()
        let evidence = try PaperRuntimeMessageBusRouting().publish(
            try routeInputs(),
            to: &messageBus,
            clock: deterministicClock,
            envelopeIDs: envelopeIDs,
            correlationID: correlationID,
            rootCausationID: rootCausationID
        )
        return (messageBus, evidence)
    }

    private static func paperSessionCommand() throws -> PaperSessionCommand {
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let timeframe = Timeframe.oneMinute
        return try PaperSessionCommand(
            sessionID: try Identifier("mtp-97-paper-session"),
            strategy: EMACrossStrategyConfiguration(
                strategyID: try Identifier("ema-cross"),
                symbol: symbol,
                timeframe: timeframe,
                shortPeriod: 2,
                longPeriod: 3
            ),
            marketData: MarketDataQuery(
                symbol: symbol,
                timeframe: timeframe,
                range: try DateRange(
                    start: Date(timeIntervalSince1970: 100),
                    end: Date(timeIntervalSince1970: 500)
                )
            ),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
    }

    private static func deterministicUUID(_ rawValue: String) -> UUID {
        guard let uuid = UUID(uuidString: rawValue) else {
            preconditionFailure("Invalid deterministic UUID: \(rawValue)")
        }
        return uuid
    }

    private static func missingFixture<T>(_ name: String) throws -> T {
        throw CoreError.paperRuntimeBusRoutingMismatch(
            field: name,
            expected: "present deterministic fixture",
            actual: "nil"
        )
    }
}

private enum PaperRuntimeRouteClassifier {
    static func classify(_ event: DomainEvent) throws -> PaperRuntimeRoutePayload {
        switch event {
        case let .paper(paperEvent):
            return try classify(paperEvent)
        case let .risk(riskEvent):
            return try classify(riskEvent)
        default:
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "event",
                expected: "paper session command, paper lifecycle, simulated fill, or paper risk event",
                actual: event.routeDebugName
            )
        }
    }

    private static func classify(_ event: PaperEvent) throws -> PaperRuntimeRoutePayload {
        switch event {
        case let .sessionRequested(command):
            guard command.executionMode == .paper else {
                throw CoreError.paperRuntimeBusRoutingMismatch(
                    field: "paperSessionCommand.executionMode",
                    expected: ExecutionMode.paper.rawValue,
                    actual: command.executionMode.rawValue
                )
            }
            return PaperRuntimeRoutePayload(
                source: .paperSessionCommand,
                payloadKind: .paperSessionCommand,
                stream: .paper,
                event: .paper(event)
            )
        case let .sessionStarted(started):
            guard started.command.executionMode == .paper else {
                throw CoreError.paperRuntimeBusRoutingMismatch(
                    field: "paperLifecycleEvent.command.executionMode",
                    expected: ExecutionMode.paper.rawValue,
                    actual: started.command.executionMode.rawValue
                )
            }
            return PaperRuntimeRoutePayload(
                source: .paperLifecycleEvent,
                payloadKind: .paperLifecycleStarted,
                stream: .paper,
                event: .paper(event)
            )
        case let .sessionUpdated(updated):
            guard updated.command.executionMode == .paper else {
                throw CoreError.paperRuntimeBusRoutingMismatch(
                    field: "paperLifecycleEvent.command.executionMode",
                    expected: ExecutionMode.paper.rawValue,
                    actual: updated.command.executionMode.rawValue
                )
            }
            return PaperRuntimeRoutePayload(
                source: .paperLifecycleEvent,
                payloadKind: .paperLifecycleUpdated,
                stream: .paper,
                event: .paper(event)
            )
        case let .sessionClosed(closed):
            guard closed.result.command.executionMode == .paper else {
                throw CoreError.paperRuntimeBusRoutingMismatch(
                    field: "paperLifecycleEvent.result.command.executionMode",
                    expected: ExecutionMode.paper.rawValue,
                    actual: closed.result.command.executionMode.rawValue
                )
            }
            return PaperRuntimeRoutePayload(
                source: .paperLifecycleEvent,
                payloadKind: .paperLifecycleClosed,
                stream: .paper,
                event: .paper(event)
            )
        case let .simulatedFillRecorded(fill):
            guard fill.paperOnlyBoundaryHeld else {
                throw CoreError.paperRuntimeBusRoutingMismatch(
                    field: "simulatedFill.paperOnlyBoundaryHeld",
                    expected: "true",
                    actual: "false"
                )
            }
            return PaperRuntimeRoutePayload(
                source: .simulatedFillEvent,
                payloadKind: .simulatedFillRecorded,
                stream: .paper,
                event: .paper(event)
            )
        default:
            throw CoreError.paperRuntimeBusRoutingMismatch(
                field: "paperEvent",
                expected: "sessionRequested/sessionStarted/sessionUpdated/sessionClosed/simulatedFillRecorded",
                actual: event.routeDebugName
            )
        }
    }

    private static func classify(_ event: RiskEvent) throws -> PaperRuntimeRoutePayload {
        switch event {
        case let .evaluationRequested(query):
            guard query.executionMode == .paper else {
                throw CoreError.paperRuntimeBusRoutingMismatch(
                    field: "riskEvaluation.executionMode",
                    expected: ExecutionMode.paper.rawValue,
                    actual: query.executionMode.rawValue
                )
            }
            return PaperRuntimeRoutePayload(
                source: .paperRiskDecision,
                payloadKind: .paperRiskEvaluationRequested,
                stream: .risk,
                event: .risk(event)
            )
        case let .blocked(evidence):
            guard evidence.executionMode == .paper else {
                throw CoreError.paperRuntimeBusRoutingMismatch(
                    field: "riskBlocker.executionMode",
                    expected: ExecutionMode.paper.rawValue,
                    actual: evidence.executionMode.rawValue
                )
            }
            return PaperRuntimeRoutePayload(
                source: .paperRiskDecision,
                payloadKind: .paperRiskBlocked,
                stream: .risk,
                event: .risk(event)
            )
        }
    }
}

private extension DomainEvent {
    var routeDebugName: String {
        switch self {
        case .market:
            "market"
        case .strategySignal:
            "strategySignal"
        case .orderBookImbalanceResearch:
            "orderBookImbalanceResearch"
        case .backtest:
            "backtest"
        case .paper:
            "paper"
        case .risk:
            "risk"
        case .portfolio:
            "portfolio"
        case .replay:
            "replay"
        }
    }
}

private extension PaperEvent {
    var routeDebugName: String {
        switch self {
        case .sessionStarted:
            "sessionStarted"
        case .sessionUpdated:
            "sessionUpdated"
        case .sessionClosed:
            "sessionClosed"
        case .sessionControlApplied:
            "sessionControlApplied"
        case .sessionControlRejected:
            "sessionControlRejected"
        case .actionProposed:
            "actionProposed"
        case .executionDecisionRecorded:
            "executionDecisionRecorded"
        case .orderIntentRecorded:
            "orderIntentRecorded"
        case .simulatedFillRecorded:
            "simulatedFillRecorded"
        case .sessionRequested:
            "sessionRequested"
        case .signalGenerated:
            "signalGenerated"
        case .sessionCompleted:
            "sessionCompleted"
        }
    }
}
