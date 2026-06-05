import DomainModel
import Foundation

/// Paper session local control command 是 MTP-48 的本地 session-level 控制意图模型。
///
/// 该模型只表达 Workbench 对本地 Paper session 的 `start` / `pause` / `close` / `reset`
/// 意图，后续 MTP-49 才能把已接受的 command 串到 paper-only event boundary。当前类型不写
/// event log、不调用 Runtime / Adapter、不提交或撤销订单，也不连接 signed endpoint、account
/// endpoint、listenKey、broker 或 Live execution。
public enum PaperSessionLocalControlAction: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case start
    case pause
    case close
    case reset
}

/// PaperSessionLocalControlScope 固定 command 的作用域只能是本地 Paper session。
///
/// 该 scope 防止 Codable payload 把同一个 command 扩展成账户、broker、OMS、全局 workflow
/// 或真实交易控制面。
public enum PaperSessionLocalControlScope: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case localPaperSession = "local paper session"
}

/// PaperSessionLocalControlLevel 固定 command 粒度只能是 session-level。
///
/// MTP-48 不允许 order-level command；任何 order submit / cancel / replace 或 broker-facing
/// action 都只能以 rejection evidence 表达，不能进入可接受 command。
public enum PaperSessionLocalControlLevel: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case session
}

/// PaperSessionLocalControlRejectedReason 描述 raw control request 被拒绝的原因。
///
/// rejection 只用于 deterministic validation 和后续 Workbench 展示，不提供降级到真实订单、
/// broker fallback、signed endpoint 或 Live execution 的路径。
public enum PaperSessionLocalControlRejectedReason: String, Codable, CaseIterable, Equatable, Sendable {
    case emptyCommandID = "empty command id"
    case emptySessionID = "empty session id"
    case nonPaperExecutionMode = "non-paper execution mode"
    case nonSessionLevelControl = "non-session-level control"
    case orderLevelCommand = "order-level command"
    case realOrderCommand = "real order command"
    case brokerFacingCommand = "broker-facing command"
}

/// PaperSessionLocalControlRejection 是无法进入 command model 的本地拒绝证据。
///
/// 字段保留原始请求和标准化 control，便于后续 read model / evidence explorer 解释失败原因；
/// 它不是 event log fact，也不触发外部系统或真实交易动作。
public struct PaperSessionLocalControlRejection: Codable, Equatable, Sendable {
    public let commandID: String
    public let sessionID: String
    public let requestedControl: String
    public let normalizedControl: String
    public let executionMode: ExecutionMode
    public let reason: PaperSessionLocalControlRejectedReason
    public let rejectedAt: Date

    public init(
        commandID: String,
        sessionID: String,
        requestedControl: String,
        normalizedControl: String,
        executionMode: ExecutionMode,
        reason: PaperSessionLocalControlRejectedReason,
        rejectedAt: Date
    ) {
        self.commandID = commandID
        self.sessionID = sessionID
        self.requestedControl = requestedControl
        self.normalizedControl = normalizedControl
        self.executionMode = executionMode
        self.reason = reason
        self.rejectedAt = rejectedAt
    }
}

/// PaperSessionLocalControlValidation 是 raw request validation 的确定性结果。
///
/// accepted path 只返回本地 Paper session command；rejected path 只返回拒绝原因，调用方不能从
/// rejection 恢复 order-level、broker-facing 或真实订单行为。
public enum PaperSessionLocalControlValidation: Codable, Equatable, Sendable {
    case accepted(PaperSessionLocalControlCommand)
    case rejected(PaperSessionLocalControlRejection)

    public var acceptedCommand: PaperSessionLocalControlCommand? {
        switch self {
        case let .accepted(command):
            command
        case .rejected:
            nil
        }
    }

    public var rejection: PaperSessionLocalControlRejection? {
        switch self {
        case .accepted:
            nil
        case let .rejected(rejection):
            rejection
        }
    }

    public var isAccepted: Bool {
        acceptedCommand != nil
    }
}

/// PaperSessionLocalControlCommand 保存已通过验证的本地 Paper session control intent。
///
/// capability flags 永远固定为 `false`，并在 Codable 解码时再次校验，确保 payload 不能把
/// session-level local command 伪造成 order submit / cancel / replace、broker action、signed
/// endpoint、account endpoint、listenKey 或 Live trading 授权。
public struct PaperSessionLocalControlCommand: Codable, Equatable, Sendable {
    public let commandID: Identifier
    public let sessionID: Identifier
    public let control: PaperSessionLocalControlAction
    public let scope: PaperSessionLocalControlScope
    public let controlLevel: PaperSessionLocalControlLevel
    public let executionMode: ExecutionMode
    public let requestedAt: Date
    public let authorizesOrderLevelCommand: Bool
    public let authorizesTradingExecution: Bool
    public let authorizesLiveTrading: Bool
    public let touchesSignedEndpoint: Bool
    public let touchesAccountEndpoint: Bool
    public let touchesListenKey: Bool
    public let touchesBrokerAction: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool

    public var isSessionLevelLocalPaperControl: Bool {
        scope == .localPaperSession
            && controlLevel == .session
            && executionMode == .paper
    }

    public var paperOnlyBoundaryHeld: Bool {
        isSessionLevelLocalPaperControl
            && authorizesOrderLevelCommand == false
            && authorizesTradingExecution == false
            && authorizesLiveTrading == false
            && touchesSignedEndpoint == false
            && touchesAccountEndpoint == false
            && touchesListenKey == false
            && touchesBrokerAction == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
    }

    /// 通过已结构化的 session-level control 构造 accepted command。
    ///
    /// 输入必须已经是 `PaperSessionLocalControlAction`，因此该 initializer 只负责写入固定
    /// paper-only scope、session level 和全部 false 的 capability flags；错误边界由私有完整
    /// initializer 统一校验，避免 Codable 和直接构造走出不同规则。
    public init(
        commandID: Identifier,
        sessionID: Identifier,
        control: PaperSessionLocalControlAction,
        requestedAt: Date
    ) throws {
        try self.init(
            commandID: commandID,
            sessionID: sessionID,
            control: control,
            scope: .localPaperSession,
            controlLevel: .session,
            executionMode: .paper,
            requestedAt: requestedAt,
            authorizesOrderLevelCommand: false,
            authorizesTradingExecution: false,
            authorizesLiveTrading: false,
            touchesSignedEndpoint: false,
            touchesAccountEndpoint: false,
            touchesListenKey: false,
            touchesBrokerAction: false,
            submitsRealOrder: false,
            cancelsRealOrder: false,
            replacesRealOrder: false
        )
    }

    /// 从 Codable payload 恢复 command，并重新执行所有 paper-only 不变量校验。
    ///
    /// 输入 payload 只要试图把 scope、level、execution mode 或 capability flags 改成
    /// order-level / broker-facing / real-order 语义，就会抛出 `CoreError`，不会产生 accepted
    /// command。
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            commandID: try container.decode(Identifier.self, forKey: .commandID),
            sessionID: try container.decode(Identifier.self, forKey: .sessionID),
            control: try container.decode(PaperSessionLocalControlAction.self, forKey: .control),
            scope: try container.decode(PaperSessionLocalControlScope.self, forKey: .scope),
            controlLevel: try container.decode(PaperSessionLocalControlLevel.self, forKey: .controlLevel),
            executionMode: try container.decode(ExecutionMode.self, forKey: .executionMode),
            requestedAt: try container.decode(Date.self, forKey: .requestedAt),
            authorizesOrderLevelCommand: try container.decode(Bool.self, forKey: .authorizesOrderLevelCommand),
            authorizesTradingExecution: try container.decode(Bool.self, forKey: .authorizesTradingExecution),
            authorizesLiveTrading: try container.decode(Bool.self, forKey: .authorizesLiveTrading),
            touchesSignedEndpoint: try container.decode(Bool.self, forKey: .touchesSignedEndpoint),
            touchesAccountEndpoint: try container.decode(Bool.self, forKey: .touchesAccountEndpoint),
            touchesListenKey: try container.decode(Bool.self, forKey: .touchesListenKey),
            touchesBrokerAction: try container.decode(Bool.self, forKey: .touchesBrokerAction),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder)
        )
    }

    private init(
        commandID: Identifier,
        sessionID: Identifier,
        control: PaperSessionLocalControlAction,
        scope: PaperSessionLocalControlScope,
        controlLevel: PaperSessionLocalControlLevel,
        executionMode: ExecutionMode,
        requestedAt: Date,
        authorizesOrderLevelCommand: Bool,
        authorizesTradingExecution: Bool,
        authorizesLiveTrading: Bool,
        touchesSignedEndpoint: Bool,
        touchesAccountEndpoint: Bool,
        touchesListenKey: Bool,
        touchesBrokerAction: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool
    ) throws {
        guard scope == .localPaperSession else {
            throw CoreError.paperSessionLocalControlMismatch(
                field: "scope",
                expected: PaperSessionLocalControlScope.localPaperSession.rawValue,
                actual: scope.rawValue
            )
        }
        guard controlLevel == .session else {
            throw CoreError.paperSessionLocalControlMismatch(
                field: "controlLevel",
                expected: PaperSessionLocalControlLevel.session.rawValue,
                actual: controlLevel.rawValue
            )
        }
        guard executionMode == .paper else {
            throw CoreError.paperSessionLocalControlRequiresPaperMode(executionMode)
        }
        try Self.validateForbiddenCapabilities(
            authorizesOrderLevelCommand: authorizesOrderLevelCommand,
            authorizesTradingExecution: authorizesTradingExecution,
            authorizesLiveTrading: authorizesLiveTrading,
            touchesSignedEndpoint: touchesSignedEndpoint,
            touchesAccountEndpoint: touchesAccountEndpoint,
            touchesListenKey: touchesListenKey,
            touchesBrokerAction: touchesBrokerAction,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder
        )

        self.commandID = commandID
        self.sessionID = sessionID
        self.control = control
        self.scope = scope
        self.controlLevel = controlLevel
        self.executionMode = executionMode
        self.requestedAt = requestedAt
        self.authorizesOrderLevelCommand = authorizesOrderLevelCommand
        self.authorizesTradingExecution = authorizesTradingExecution
        self.authorizesLiveTrading = authorizesLiveTrading
        self.touchesSignedEndpoint = touchesSignedEndpoint
        self.touchesAccountEndpoint = touchesAccountEndpoint
        self.touchesListenKey = touchesListenKey
        self.touchesBrokerAction = touchesBrokerAction
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
    }

    /// 校验 Workbench 或测试传入的 raw control request。
    ///
    /// 输入是原始 commandID、sessionID、requestedControl、executionMode 和 requestedAt；输出只会是
    /// accepted `PaperSessionLocalControlCommand` 或 rejected reason。该函数不写 event log、不调用
    /// runtime，也不会把非法请求降级成 order-level、broker-facing 或真实订单行为。
    public static func validate(
        commandID: String,
        sessionID: String,
        requestedControl: String,
        executionMode: ExecutionMode,
        requestedAt: Date
    ) -> PaperSessionLocalControlValidation {
        let normalizedControl = normalize(requestedControl)
        let trimmedCommandID = commandID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSessionID = sessionID.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedCommandID.isEmpty {
            return rejection(
                commandID: commandID,
                sessionID: sessionID,
                requestedControl: requestedControl,
                normalizedControl: normalizedControl,
                executionMode: executionMode,
                reason: .emptyCommandID,
                rejectedAt: requestedAt
            )
        }
        if trimmedSessionID.isEmpty {
            return rejection(
                commandID: commandID,
                sessionID: sessionID,
                requestedControl: requestedControl,
                normalizedControl: normalizedControl,
                executionMode: executionMode,
                reason: .emptySessionID,
                rejectedAt: requestedAt
            )
        }
        guard executionMode == .paper else {
            return rejection(
                commandID: commandID,
                sessionID: sessionID,
                requestedControl: requestedControl,
                normalizedControl: normalizedControl,
                executionMode: executionMode,
                reason: .nonPaperExecutionMode,
                rejectedAt: requestedAt
            )
        }
        if let reason = rejectedReason(for: normalizedControl) {
            return rejection(
                commandID: commandID,
                sessionID: sessionID,
                requestedControl: requestedControl,
                normalizedControl: normalizedControl,
                executionMode: executionMode,
                reason: reason,
                rejectedAt: requestedAt
            )
        }
        guard let control = PaperSessionLocalControlAction(rawValue: normalizedControl) else {
            return rejection(
                commandID: commandID,
                sessionID: sessionID,
                requestedControl: requestedControl,
                normalizedControl: normalizedControl,
                executionMode: executionMode,
                reason: .nonSessionLevelControl,
                rejectedAt: requestedAt
            )
        }

        do {
            let command = try PaperSessionLocalControlCommand(
                commandID: Identifier(trimmedCommandID, field: "paperSessionLocalControlCommandID"),
                sessionID: Identifier(trimmedSessionID, field: "paperSessionLocalControlSessionID"),
                control: control,
                requestedAt: requestedAt
            )
            return .accepted(command)
        } catch {
            return rejection(
                commandID: commandID,
                sessionID: sessionID,
                requestedControl: requestedControl,
                normalizedControl: normalizedControl,
                executionMode: executionMode,
                reason: .nonSessionLevelControl,
                rejectedAt: requestedAt
            )
        }
    }

    private static func normalize(_ requestedControl: String) -> String {
        requestedControl
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .joined(separator: " ")
    }

    private static func rejectedReason(for normalizedControl: String) -> PaperSessionLocalControlRejectedReason? {
        switch normalizedControl {
        case "order", "paper order", "risk control", "position management":
            .orderLevelCommand
        case "submit", "cancel", "replace", "order submit", "order cancel", "order replace",
             "submit order", "cancel order", "replace order":
            .realOrderCommand
        case "broker", "broker action", "signed endpoint", "account endpoint", "listenkey", "listen key",
             "live", "live trading":
            .brokerFacingCommand
        default:
            nil
        }
    }

    private static func rejection(
        commandID: String,
        sessionID: String,
        requestedControl: String,
        normalizedControl: String,
        executionMode: ExecutionMode,
        reason: PaperSessionLocalControlRejectedReason,
        rejectedAt: Date
    ) -> PaperSessionLocalControlValidation {
        .rejected(
            PaperSessionLocalControlRejection(
                commandID: commandID,
                sessionID: sessionID,
                requestedControl: requestedControl,
                normalizedControl: normalizedControl,
                executionMode: executionMode,
                reason: reason,
                rejectedAt: rejectedAt
            )
        )
    }

    private static func validateForbiddenCapabilities(
        authorizesOrderLevelCommand: Bool,
        authorizesTradingExecution: Bool,
        authorizesLiveTrading: Bool,
        touchesSignedEndpoint: Bool,
        touchesAccountEndpoint: Bool,
        touchesListenKey: Bool,
        touchesBrokerAction: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool
    ) throws {
        let forbiddenCapabilities = [
            ("authorizesOrderLevelCommand", authorizesOrderLevelCommand),
            ("authorizesTradingExecution", authorizesTradingExecution),
            ("authorizesLiveTrading", authorizesLiveTrading),
            ("touchesSignedEndpoint", touchesSignedEndpoint),
            ("touchesAccountEndpoint", touchesAccountEndpoint),
            ("touchesListenKey", touchesListenKey),
            ("touchesBrokerAction", touchesBrokerAction),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder)
        ]

        if let capability = forbiddenCapabilities.first(where: { $0.1 }) {
            throw CoreError.paperSessionLocalControlForbiddenCapability(capability.0)
        }
    }
}

/// PaperSessionLocalControlCommandFixture 提供 MTP-48 deterministic command evidence。
///
/// fixture 只服务本地 XCTest、PR evidence 和后续 read model 消费；它不创建 event log fact，
/// 也不代表用户已经触发真实交易或外部系统动作。
public enum PaperSessionLocalControlCommandFixture {
    public static let requestedAt = Date(timeIntervalSince1970: 3_200)

    /// 生成单个 deterministic accepted command fixture。
    ///
    /// 输入只允许 MTP-48 的四个 session-level controls；输出保持固定 session、固定时间和
    /// paper-only capability flags，用于 XCTest 和 PR evidence。
    public static func deterministic(
        control: PaperSessionLocalControlAction
    ) throws -> PaperSessionLocalControlCommand {
        try PaperSessionLocalControlCommand(
            commandID: Identifier("paper-session-local-control-\(control.rawValue)"),
            sessionID: Identifier("paper-session-fixture"),
            control: control,
            requestedAt: requestedAt
        )
    }

    /// 一次性生成 `start` / `pause` / `close` / `reset` 四个 deterministic fixtures。
    ///
    /// 输出顺序跟 `PaperSessionLocalControlAction.allCases` 一致，便于 tests 锁定允许集合没有漂移。
    public static func allDeterministic() throws -> [PaperSessionLocalControlCommand] {
        try PaperSessionLocalControlAction.allCases.map { control in
            try deterministic(control: control)
        }
    }
}
