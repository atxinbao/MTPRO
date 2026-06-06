import DomainModel
import Foundation
import MessageBus

/// TradingClock 和 PaperRuntimeKernelBoundary 定义 MTP-96 的 paper-only runtime kernel 基础合同。
///
/// 本文件只表达确定性时间、paper command intake、paper event emission、replay 不变量和 forbidden
/// capability flags。它不是 Runtime target 的编排服务，不启动 actor，不访问 Adapter / Persistence /
/// UI，也不实现 CommandBus、EventBus、Paper RiskEngine、lifecycle coordinator、simulated fill、broker、
/// signed endpoint、OMS、live command 或真实交易能力。

/// TradingClockSource 标记时间来源，只允许 deterministic fixture 或 replay evidence。
///
/// `wallClock` 被保留为明确禁区说明，不能出现在有效 `TradingClock` 中；当前 paper runtime kernel
/// 必须由显式 ticks 或 replayed event sequence 驱动，避免测试和回放依赖 `Date()`。
public enum TradingClockSource: String, Codable, CaseIterable, Equatable, Sendable {
    case deterministicFixture
    case replay
    case wallClock
}

/// TradingClockTick 是 paper runtime kernel 可消费的单个确定性时间事实。
///
/// `sequence` 是本地 clock tick 的单调编号，不代表 exchange sequence、broker sequence 或生产调度
/// cursor。`replaySourceSequence` 只在 replay 场景中引用 append-only event log sequence，用于证明
/// replay tick 来自本地事实源，而不是系统时间或外部 broker。
public struct TradingClockTick: Codable, Equatable, Sendable {
    public let sequence: Int
    public let instant: Date
    public let source: TradingClockSource
    public let replaySourceSequence: Int?

    public init(
        sequence: Int,
        instant: Date,
        source: TradingClockSource,
        replaySourceSequence: Int? = nil
    ) throws {
        guard sequence > 0 else {
            throw CoreError.tradingClockContractMismatch(
                field: "sequence",
                expected: "positive monotonic tick sequence",
                actual: "\(sequence)"
            )
        }
        guard source != .wallClock else {
            throw CoreError.tradingClockContractMismatch(
                field: "source",
                expected: "deterministicFixture or replay",
                actual: source.rawValue
            )
        }
        if source == .replay {
            guard let replaySourceSequence, replaySourceSequence > 0 else {
                throw CoreError.tradingClockContractMismatch(
                    field: "replaySourceSequence",
                    expected: "positive event log sequence for replay ticks",
                    actual: "\(String(describing: replaySourceSequence))"
                )
            }
        } else if replaySourceSequence != nil {
            throw CoreError.tradingClockContractMismatch(
                field: "replaySourceSequence",
                expected: "nil for deterministic fixture ticks",
                actual: "\(String(describing: replaySourceSequence))"
            )
        }

        self.sequence = sequence
        self.instant = instant
        self.source = source
        self.replaySourceSequence = replaySourceSequence
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            sequence: try container.decode(Int.self, forKey: .sequence),
            instant: try container.decode(Date.self, forKey: .instant),
            source: try container.decode(TradingClockSource.self, forKey: .source),
            replaySourceSequence: try container.decodeIfPresent(Int.self, forKey: .replaySourceSequence)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sequence, forKey: .sequence)
        try container.encode(instant, forKey: .instant)
        try container.encode(source, forKey: .source)
        try container.encodeIfPresent(replaySourceSequence, forKey: .replaySourceSequence)
    }

    private enum CodingKeys: String, CodingKey {
        case sequence
        case instant
        case source
        case replaySourceSequence
    }
}

/// TradingClock 保存 paper runtime kernel 的确定性 tick 序列。
///
/// 该 clock 不读取系统时间、不启动 scheduler、不代表 exchange clock 或 broker session clock。后续
/// Runtime 编排只能把已经确定的 tick 序列注入 paper kernel，再通过 event log / replay 复现同一批
/// instants。
public struct TradingClock: Codable, Equatable, Sendable {
    public let clockID: Identifier
    public let issueID: Identifier
    public let ticks: [TradingClockTick]
    public let validationAnchors: [String]

    public var instants: [Date] {
        ticks.map(\.instant)
    }

    public var isDeterministic: Bool {
        ticks.allSatisfy { $0.source != .wallClock }
    }

    public init(
        clockID: Identifier,
        issueID: Identifier,
        ticks: [TradingClockTick],
        validationAnchors: [String] = [
            "MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME",
            "MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION"
        ]
    ) throws {
        try Self.validate(ticks: ticks)
        guard validationAnchors.contains("MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME") else {
            throw CoreError.tradingClockContractMismatch(
                field: "validationAnchors",
                expected: "MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME",
                actual: validationAnchors.joined(separator: ",")
            )
        }

        self.clockID = clockID
        self.issueID = issueID
        self.ticks = ticks
        self.validationAnchors = validationAnchors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            clockID: try container.decode(Identifier.self, forKey: .clockID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            ticks: try container.decode([TradingClockTick].self, forKey: .ticks),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors)
        )
    }

    /// 返回指定 tick sequence 的 instant，调用方可用它驱动 deterministic fixture。
    public func instant(for sequence: Int) -> Date? {
        ticks.first { $0.sequence == sequence }?.instant
    }

    /// MTP-96 deterministic fixture 固定三段 paper runtime 时间：session open、command intake 和 replay。
    public static let deterministicFixture: TradingClock = {
        do {
            return try TradingClock(
                clockID: try Identifier("mtp-96-trading-clock-deterministic-fixture"),
                issueID: try Identifier("MTP-96"),
                ticks: [
                    TradingClockTick(
                        sequence: 1,
                        instant: Date(timeIntervalSince1970: 1_700_000_000),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 2,
                        instant: Date(timeIntervalSince1970: 1_700_000_060),
                        source: .deterministicFixture
                    ),
                    TradingClockTick(
                        sequence: 3,
                        instant: Date(timeIntervalSince1970: 1_700_000_120),
                        source: .replay,
                        replaySourceSequence: 2
                    )
                ]
            )
        } catch {
            preconditionFailure("Invalid MTP-96 TradingClock fixture: \(error)")
        }
    }()

    private static func validate(ticks: [TradingClockTick]) throws {
        guard ticks.isEmpty == false else {
            throw CoreError.tradingClockContractMismatch(
                field: "ticks",
                expected: "at least one deterministic tick",
                actual: "empty"
            )
        }

        let expectedSequences = Array(1...ticks.count)
        let actualSequences = ticks.map(\.sequence)
        guard actualSequences == expectedSequences else {
            throw CoreError.tradingClockContractMismatch(
                field: "tick.sequence",
                expected: expectedSequences.map(String.init).joined(separator: ","),
                actual: actualSequences.map(String.init).joined(separator: ",")
            )
        }

        let instants = ticks.map(\.instant)
        guard instants == instants.sorted() else {
            throw CoreError.tradingClockContractMismatch(
                field: "tick.instant",
                expected: "nondecreasing deterministic instants",
                actual: instants.map { "\($0.timeIntervalSince1970)" }.joined(separator: ",")
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case clockID
        case issueID
        case ticks
        case validationAnchors
    }
}

/// PaperRuntimeKernelLifecycleState 固定 MTP-96 可观察的 kernel lifecycle 名称。
///
/// 这些状态只是 paper runtime kernel contract 的边界语言，不实现后续 lifecycle coordinator，也不
/// 表达 broker session、exchange session、production scheduler 或 live runtime 状态。
public enum PaperRuntimeKernelLifecycleState: String, Codable, CaseIterable, Equatable, Sendable {
    case initialized
    case localPaperSessionOpened
    case paperCommandIntakeAccepted
    case paperEventEmitted
    case replaySnapshotProduced
    case localPaperSessionClosed
}

/// PaperRuntimeKernelInputKind 描述 MTP-96 允许进入 kernel boundary 的输入类别。
///
/// 所有输入都必须带 paper / local / replay 语义。后续 MTP-97+ 可以在该分类内接入 bus routing，
/// 但不能把 signed request、broker action、real order command 或 UI state 放入该入口。
public enum PaperRuntimeKernelInputKind: String, Codable, CaseIterable, Equatable, Sendable {
    case tradingClockTick
    case paperSessionCommand
    case paperSessionLocalControl
    case paperActionProposal
    case paperExecutionDecision
    case eventReplayCommand
}

/// PaperRuntimeKernelOutputKind 描述 kernel boundary 允许输出的事实类别。
///
/// 输出只能是 append-only paper facts、replay result 或后续 projection trigger；它不是 UI state、
/// persistence schema、adapter status、live command result 或 broker acknowledgement。
public enum PaperRuntimeKernelOutputKind: String, Codable, CaseIterable, Equatable, Sendable {
    case paperEventEnvelope
    case replayResult
    case paperProjectionTrigger
}

/// PaperRuntimeKernelBoundary 是 MTP-96 的 paper-only kernel contract deterministic fixture。
///
/// 该类型把时间、session、command intake、event emission、replay、module boundary 和禁区集中到
/// 一个 Core value model，供 tests、validation matrix、后续 bus/risk/lifecycle issue 复用。
public struct PaperRuntimeKernelBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let clock: TradingClock
    public let lifecycleStates: [PaperRuntimeKernelLifecycleState]
    public let allowedInputs: [PaperRuntimeKernelInputKind]
    public let allowedOutputs: [PaperRuntimeKernelOutputKind]
    public let eventStreams: [EventStreamID]
    public let validationAnchors: [String]
    public let exposesUIState: Bool
    public let exposesPersistenceSchema: Bool
    public let readsAdapterObject: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool

    public var paperOnlyBoundaryHeld: Bool {
        usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && providesLiveCommand == false
            && providesTradingButton == false
    }

    public var moduleBoundaryHeld: Bool {
        exposesUIState == false
            && exposesPersistenceSchema == false
            && readsAdapterObject == false
            && eventStreams.allSatisfy { $0 == .paper || $0 == .replay }
    }

    public var deterministicFixtureBoundaryHeld: Bool {
        clock.isDeterministic
            && lifecycleStates == PaperRuntimeKernelLifecycleState.allCases
            && allowedInputs == PaperRuntimeKernelInputKind.allCases
            && allowedOutputs == PaperRuntimeKernelOutputKind.allCases
            && validationAnchors.contains("MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION")
    }

    public init(
        contractID: Identifier,
        issueID: Identifier,
        clock: TradingClock,
        lifecycleStates: [PaperRuntimeKernelLifecycleState] = PaperRuntimeKernelLifecycleState.allCases,
        allowedInputs: [PaperRuntimeKernelInputKind] = PaperRuntimeKernelInputKind.allCases,
        allowedOutputs: [PaperRuntimeKernelOutputKind] = PaperRuntimeKernelOutputKind.allCases,
        eventStreams: [EventStreamID] = [.paper, .replay],
        validationAnchors: [String] = [
            "TVM-PAPER-RUNTIME-KERNEL",
            "MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME",
            "MTP-96-PAPER-RUNTIME-KERNEL-BOUNDARY",
            "MTP-96-PAPER-ONLY-KERNEL-EVENTS",
            "MTP-96-NO-UI-STATE-OR-PERSISTENCE-SCHEMA",
            "MTP-96-NO-LIVE-SIGNED-BROKER-RUNTIME",
            "MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION"
        ],
        exposesUIState: Bool = false,
        exposesPersistenceSchema: Bool = false,
        readsAdapterObject: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validateLifecycle(lifecycleStates)
        try Self.validateAllowedInputs(allowedInputs)
        try Self.validateAllowedOutputs(allowedOutputs)
        try Self.validateEventStreams(eventStreams)
        try Self.validateValidationAnchors(validationAnchors)

        let forbiddenFlags: [(String, Bool)] = [
            ("exposesUIState", exposesUIState),
            ("exposesPersistenceSchema", exposesPersistenceSchema),
            ("readsAdapterObject", readsAdapterObject),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton)
        ]
        if let forbidden = forbiddenFlags.first(where: \.1) {
            throw CoreError.paperRuntimeKernelForbiddenCapability(forbidden.0)
        }

        self.contractID = contractID
        self.issueID = issueID
        self.clock = clock
        self.lifecycleStates = lifecycleStates
        self.allowedInputs = allowedInputs
        self.allowedOutputs = allowedOutputs
        self.eventStreams = eventStreams
        self.validationAnchors = validationAnchors
        self.exposesUIState = exposesUIState
        self.exposesPersistenceSchema = exposesPersistenceSchema
        self.readsAdapterObject = readsAdapterObject
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            clock: try container.decode(TradingClock.self, forKey: .clock),
            lifecycleStates: try container.decode(
                [PaperRuntimeKernelLifecycleState].self,
                forKey: .lifecycleStates
            ),
            allowedInputs: try container.decode([PaperRuntimeKernelInputKind].self, forKey: .allowedInputs),
            allowedOutputs: try container.decode([PaperRuntimeKernelOutputKind].self, forKey: .allowedOutputs),
            eventStreams: try container.decode([EventStreamID].self, forKey: .eventStreams),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            exposesUIState: try container.decode(Bool.self, forKey: .exposesUIState),
            exposesPersistenceSchema: try container.decode(Bool.self, forKey: .exposesPersistenceSchema),
            readsAdapterObject: try container.decode(Bool.self, forKey: .readsAdapterObject),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    public func accepts(_ input: PaperRuntimeKernelInputKind) -> Bool {
        allowedInputs.contains(input)
    }

    public func emits(_ output: PaperRuntimeKernelOutputKind) -> Bool {
        allowedOutputs.contains(output)
    }

    /// MTP-96 fixture 是后续 CommandBus / EventBus / Paper Risk / lifecycle coordinator issue 的基础入口。
    public static let deterministicFixture: PaperRuntimeKernelBoundary = {
        do {
            return try PaperRuntimeKernelBoundary(
                contractID: try Identifier("mtp-96-paper-runtime-kernel-boundary"),
                issueID: try Identifier("MTP-96"),
                clock: .deterministicFixture
            )
        } catch {
            preconditionFailure("Invalid MTP-96 PaperRuntimeKernelBoundary fixture: \(error)")
        }
    }()

    private static func validateLifecycle(_ states: [PaperRuntimeKernelLifecycleState]) throws {
        guard states == PaperRuntimeKernelLifecycleState.allCases else {
            throw CoreError.paperRuntimeKernelContractMismatch(
                field: "lifecycleStates",
                expected: PaperRuntimeKernelLifecycleState.allCases.map(\.rawValue).joined(separator: ","),
                actual: states.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateAllowedInputs(_ inputs: [PaperRuntimeKernelInputKind]) throws {
        guard inputs == PaperRuntimeKernelInputKind.allCases else {
            throw CoreError.paperRuntimeKernelContractMismatch(
                field: "allowedInputs",
                expected: PaperRuntimeKernelInputKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: inputs.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateAllowedOutputs(_ outputs: [PaperRuntimeKernelOutputKind]) throws {
        guard outputs == PaperRuntimeKernelOutputKind.allCases else {
            throw CoreError.paperRuntimeKernelContractMismatch(
                field: "allowedOutputs",
                expected: PaperRuntimeKernelOutputKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: outputs.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateEventStreams(_ streams: [EventStreamID]) throws {
        guard streams == [.paper, .replay] else {
            throw CoreError.paperRuntimeKernelContractMismatch(
                field: "eventStreams",
                expected: "paper,replay",
                actual: streams.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateValidationAnchors(_ anchors: [String]) throws {
        let required = [
            "TVM-PAPER-RUNTIME-KERNEL",
            "MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME",
            "MTP-96-PAPER-RUNTIME-KERNEL-BOUNDARY",
            "MTP-96-PAPER-ONLY-KERNEL-EVENTS",
            "MTP-96-NO-UI-STATE-OR-PERSISTENCE-SCHEMA",
            "MTP-96-NO-LIVE-SIGNED-BROKER-RUNTIME",
            "MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION"
        ]
        guard anchors == required else {
            throw CoreError.paperRuntimeKernelContractMismatch(
                field: "validationAnchors",
                expected: required.joined(separator: ","),
                actual: anchors.joined(separator: ",")
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case contractID
        case issueID
        case clock
        case lifecycleStates
        case allowedInputs
        case allowedOutputs
        case eventStreams
        case validationAnchors
        case exposesUIState
        case exposesPersistenceSchema
        case readsAdapterObject
        case usesSignedEndpoint
        case callsAccountEndpoint
        case createsListenKey
        case connectsBroker
        case implementsLiveExecutionAdapter
        case implementsOMS
        case implementsRealOrderLifecycle
        case submitsRealOrder
        case cancelsRealOrder
        case replacesRealOrder
        case providesLiveCommand
        case providesTradingButton
    }
}
