import DomainModel
import Foundation

/// ExecutionContractStage 固定 v0.14.0 执行合同必须分离的语义阶段。
///
/// 这些阶段只描述 ExecutionEngine 与 dry-run / Binance testnet adapter 之间的接口边界；
/// 它们不是生产交易命令，也不表示已经连接 broker、signed endpoint 或真实订单系统。
public enum ExecutionContractStage: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case intent
    case requestMapping
    case submissionResult
    case acknowledgement
    case rejection
    case cancel
    case replace
    case auditEvidence
}

/// ExecutionContractOperation 是 adapter 合同允许表达的操作类型。
///
/// submit / cancel / replace 仍然只在显式 dry-run 或 Binance testnet mode 下生成
/// auditable evidence，不授权 production order。
public enum ExecutionContractOperation: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit
    case cancel
    case replace
}

/// ExecutionContractAdapterMode 限定 v0.14.0 只允许 dry-run 与 Binance testnet。
public enum ExecutionContractAdapterMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case binanceTestnet = "binance-testnet"

    public var submissionLifecycleState: OrderLifecycleState {
        switch self {
        case .dryRun:
            .submittedDryRun
        case .binanceTestnet:
            .submittedTestnet
        }
    }

    public var isTestnetScoped: Bool {
        true
    }

    public var authorizesProductionTrading: Bool {
        false
    }

    public var touchesProductionEndpoint: Bool {
        false
    }
}

/// ExecutionContractError 是 v0.14.0 execution contract 的局部 fail-closed 错误。
public enum ExecutionContractError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidBoundary(String)

    public var description: String {
        switch self {
        case let .invalidBoundary(value):
            "Execution contract boundary is invalid: \(value)"
        }
    }
}

/// ExecutionContractAdapter 是 ExecutionEngine 消费、dry-run / Binance testnet adapter 实现的接口。
///
/// 协议只定义 interface，不提供 production adapter implementation；后续 issue 必须在各自
/// scope 内显式实现 dry-run 或 Binance testnet adapter，并继续保持生产交易默认关闭。
public protocol ExecutionContractAdapter: Sendable {
    var mode: ExecutionContractAdapterMode { get }

    func mapRequest(
        _ intent: OrderIntent,
        operation: ExecutionContractOperation,
        lifecycleState: OrderLifecycleState
    ) throws -> ExecutionContractRequestMapping

    func submit(_ mapping: ExecutionContractRequestMapping) async throws -> ExecutionContractSubmissionResult

    func acknowledge(_ result: ExecutionContractSubmissionResult) throws -> ExecutionContractAcknowledgement

    func reject(_ mapping: ExecutionContractRequestMapping, reason: String) throws -> ExecutionContractRejection

    func cancel(_ mapping: ExecutionContractRequestMapping, reason: String) throws -> ExecutionContractCancel

    func replace(_ mapping: ExecutionContractRequestMapping, reason: String) throws -> ExecutionContractReplace

    func auditEvidence(for mapping: ExecutionContractRequestMapping) throws -> ExecutionContractAuditEvidence
}

/// ExecutionContractRequestMapping 是 OrderIntent 到 adapter request 的纯合同映射。
///
/// 该映射不包含 URL、API key、signature、listenKey、account endpoint 或 broker endpoint。
/// 它只绑定 intent、operation、mode 与本地生命周期状态，供后续 issue 生成 testnet / dry-run
/// evidence。
public struct ExecutionContractRequestMapping: Codable, Equatable, Sendable {
    public let mappingID: Identifier
    public let intentID: Identifier
    public let operation: ExecutionContractOperation
    public let mode: ExecutionContractAdapterMode
    public let lifecycleState: OrderLifecycleState
    public let requestSchemaVersion: String
    public let carriesEndpointPath: Bool
    public let carriesCredentialMaterial: Bool
    public let authorizesProductionTrading: Bool
    public let touchesProductionEndpoint: Bool

    public init(
        mappingID: Identifier,
        intent: OrderIntent,
        operation: ExecutionContractOperation,
        mode: ExecutionContractAdapterMode,
        lifecycleState: OrderLifecycleState,
        requestSchemaVersion: String = ExecutionContractInterface.schemaVersion,
        carriesEndpointPath: Bool = false,
        carriesCredentialMaterial: Bool = false,
        authorizesProductionTrading: Bool = false,
        touchesProductionEndpoint: Bool = false
    ) throws {
        guard intent.isPreRiskEngineIntent else {
            throw ExecutionContractError.invalidBoundary(
                "ExecutionContract request mapping must consume a pre-RiskEngine OrderIntent boundary"
            )
        }
        guard Self.allowedLifecycleStates(for: operation).contains(lifecycleState) else {
            throw ExecutionContractError.invalidBoundary(
                "ExecutionContract \(operation.rawValue) mapping cannot start from \(lifecycleState.rawValue)"
            )
        }
        guard requestSchemaVersion == ExecutionContractInterface.schemaVersion else {
            throw ExecutionContractError.invalidBoundary(
                "ExecutionContract request schema must be \(ExecutionContractInterface.schemaVersion)"
            )
        }
        try ExecutionContractInterface.validateBoundary(
            carriesEndpointPath: carriesEndpointPath,
            carriesCredentialMaterial: carriesCredentialMaterial,
            authorizesProductionTrading: authorizesProductionTrading,
            touchesProductionEndpoint: touchesProductionEndpoint
        )
        guard mappingID == Self.deterministicID(
            intentID: intent.intentID,
            operation: operation,
            mode: mode,
            lifecycleState: lifecycleState
        ) else {
            throw ExecutionContractError.invalidBoundary(
                "ExecutionContract request mapping ID must be deterministic"
            )
        }

        self.mappingID = mappingID
        self.intentID = intent.intentID
        self.operation = operation
        self.mode = mode
        self.lifecycleState = lifecycleState
        self.requestSchemaVersion = requestSchemaVersion
        self.carriesEndpointPath = carriesEndpointPath
        self.carriesCredentialMaterial = carriesCredentialMaterial
        self.authorizesProductionTrading = authorizesProductionTrading
        self.touchesProductionEndpoint = touchesProductionEndpoint
    }

    public var targetLifecycleState: OrderLifecycleState {
        switch operation {
        case .submit:
            mode.submissionLifecycleState
        case .cancel:
            .cancelRequested
        case .replace:
            .replaceRequested
        }
    }

    public var boundaryHeld: Bool {
        mode.isTestnetScoped
            && mode.authorizesProductionTrading == false
            && mode.touchesProductionEndpoint == false
            && carriesEndpointPath == false
            && carriesCredentialMaterial == false
            && authorizesProductionTrading == false
            && touchesProductionEndpoint == false
    }

    public static func allowedLifecycleStates(for operation: ExecutionContractOperation) -> Set<OrderLifecycleState> {
        switch operation {
        case .submit:
            [.riskAccepted]
        case .cancel:
            [.accepted, .partiallyFilled, .replaced]
        case .replace:
            [.accepted, .partiallyFilled, .replaced]
        }
    }

    public static func deterministicID(
        intentID: Identifier,
        operation: ExecutionContractOperation,
        mode: ExecutionContractAdapterMode,
        lifecycleState: OrderLifecycleState
    ) -> Identifier {
        .constant(
            [
                "execution-contract-mapping",
                intentID.rawValue,
                operation.rawValue,
                mode.rawValue,
                lifecycleState.rawValue
            ].joined(separator: ":"),
            field: "executionContract.mappingID"
        )
    }
}

/// ExecutionContractSubmissionResult 表达 adapter 接收 request mapping 后的本地提交结果。
public struct ExecutionContractSubmissionResult: Codable, Equatable, Sendable {
    public let resultID: Identifier
    public let mappingID: Identifier
    public let operation: ExecutionContractOperation
    public let mode: ExecutionContractAdapterMode
    public let lifecycleState: OrderLifecycleState
    public let acceptedByAdapter: Bool
    public let authorizesProductionTrading: Bool
    public let touchesProductionEndpoint: Bool

    public init(
        resultID: Identifier,
        mapping: ExecutionContractRequestMapping,
        acceptedByAdapter: Bool = true,
        authorizesProductionTrading: Bool = false,
        touchesProductionEndpoint: Bool = false
    ) throws {
        guard mapping.boundaryHeld else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract submission requires boundary-held mapping")
        }
        guard OrderLifecycleStateMachine.canTransition(from: mapping.lifecycleState, to: mapping.targetLifecycleState) else {
            throw ExecutionContractError.invalidBoundary(
                "ExecutionContract submission lifecycle transition must be valid"
            )
        }
        try ExecutionContractInterface.validateBoundary(
            authorizesProductionTrading: authorizesProductionTrading,
            touchesProductionEndpoint: touchesProductionEndpoint
        )
        guard resultID == Self.deterministicID(mappingID: mapping.mappingID, state: mapping.targetLifecycleState) else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract submission result ID must be deterministic")
        }

        self.resultID = resultID
        self.mappingID = mapping.mappingID
        self.operation = mapping.operation
        self.mode = mapping.mode
        self.lifecycleState = mapping.targetLifecycleState
        self.acceptedByAdapter = acceptedByAdapter
        self.authorizesProductionTrading = authorizesProductionTrading
        self.touchesProductionEndpoint = touchesProductionEndpoint
    }

    public var boundaryHeld: Bool {
        acceptedByAdapter
            && authorizesProductionTrading == false
            && touchesProductionEndpoint == false
            && mode.authorizesProductionTrading == false
            && mode.touchesProductionEndpoint == false
    }

    public static func deterministicID(mappingID: Identifier, state: OrderLifecycleState) -> Identifier {
        .constant(
            "execution-contract-result:\(mappingID.rawValue):\(state.rawValue)",
            field: "executionContract.resultID"
        )
    }
}

/// ExecutionContractAcknowledgement 记录 adapter acknowledgement evidence。
public struct ExecutionContractAcknowledgement: Codable, Equatable, Sendable {
    public let acknowledgementID: Identifier
    public let resultID: Identifier
    public let lifecycleState: OrderLifecycleState
    public let authorizesProductionTrading: Bool

    public init(
        acknowledgementID: Identifier,
        result: ExecutionContractSubmissionResult,
        lifecycleState: OrderLifecycleState = .accepted,
        authorizesProductionTrading: Bool = false
    ) throws {
        guard result.boundaryHeld else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract acknowledgement requires boundary-held result")
        }
        guard lifecycleState == .accepted else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract acknowledgement state must be accepted")
        }
        guard authorizesProductionTrading == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract acknowledgement must not authorize production trading")
        }
        guard acknowledgementID == Self.deterministicID(resultID: result.resultID) else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract acknowledgement ID must be deterministic")
        }

        self.acknowledgementID = acknowledgementID
        self.resultID = result.resultID
        self.lifecycleState = lifecycleState
        self.authorizesProductionTrading = authorizesProductionTrading
    }

    public static func deterministicID(resultID: Identifier) -> Identifier {
        .constant("execution-contract-ack:\(resultID.rawValue)", field: "executionContract.acknowledgementID")
    }
}

/// ExecutionContractRejection 记录 adapter rejection evidence。
public struct ExecutionContractRejection: Codable, Equatable, Sendable {
    public let rejectionID: Identifier
    public let mappingID: Identifier
    public let lifecycleState: OrderLifecycleState
    public let reason: String
    public let authorizesProductionTrading: Bool

    public init(
        rejectionID: Identifier,
        mapping: ExecutionContractRequestMapping,
        lifecycleState: OrderLifecycleState = .rejected,
        reason: String,
        authorizesProductionTrading: Bool = false
    ) throws {
        guard mapping.boundaryHeld else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract rejection requires boundary-held mapping")
        }
        guard lifecycleState == .rejected || lifecycleState == .failedClosed else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract rejection state must be rejected or failedClosed")
        }
        guard reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract rejection reason must not be empty")
        }
        guard authorizesProductionTrading == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract rejection must not authorize production trading")
        }
        guard rejectionID == Self.deterministicID(mappingID: mapping.mappingID, state: lifecycleState) else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract rejection ID must be deterministic")
        }

        self.rejectionID = rejectionID
        self.mappingID = mapping.mappingID
        self.lifecycleState = lifecycleState
        self.reason = reason
        self.authorizesProductionTrading = authorizesProductionTrading
    }

    public static func deterministicID(mappingID: Identifier, state: OrderLifecycleState) -> Identifier {
        .constant("execution-contract-reject:\(mappingID.rawValue):\(state.rawValue)", field: "executionContract.rejectionID")
    }
}

/// ExecutionContractCancel 记录 cancel request / cancelled evidence，不提交真实 cancel。
public struct ExecutionContractCancel: Codable, Equatable, Sendable {
    public let cancelID: Identifier
    public let mappingID: Identifier
    public let lifecycleState: OrderLifecycleState
    public let authorizesProductionTrading: Bool
    public let touchesProductionEndpoint: Bool

    public init(
        cancelID: Identifier,
        mapping: ExecutionContractRequestMapping,
        lifecycleState: OrderLifecycleState = .cancelRequested,
        authorizesProductionTrading: Bool = false,
        touchesProductionEndpoint: Bool = false
    ) throws {
        guard mapping.operation == .cancel else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract cancel requires cancel mapping")
        }
        guard lifecycleState == .cancelRequested || lifecycleState == .cancelled else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract cancel state must be cancelRequested or cancelled")
        }
        try ExecutionContractInterface.validateBoundary(
            authorizesProductionTrading: authorizesProductionTrading,
            touchesProductionEndpoint: touchesProductionEndpoint
        )
        guard cancelID == Self.deterministicID(mappingID: mapping.mappingID, state: lifecycleState) else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract cancel ID must be deterministic")
        }

        self.cancelID = cancelID
        self.mappingID = mapping.mappingID
        self.lifecycleState = lifecycleState
        self.authorizesProductionTrading = authorizesProductionTrading
        self.touchesProductionEndpoint = touchesProductionEndpoint
    }

    public static func deterministicID(mappingID: Identifier, state: OrderLifecycleState) -> Identifier {
        .constant("execution-contract-cancel:\(mappingID.rawValue):\(state.rawValue)", field: "executionContract.cancelID")
    }
}

/// ExecutionContractReplace 记录 replace request / replaced evidence，不提交真实 replace。
public struct ExecutionContractReplace: Codable, Equatable, Sendable {
    public let replaceID: Identifier
    public let mappingID: Identifier
    public let lifecycleState: OrderLifecycleState
    public let authorizesProductionTrading: Bool
    public let touchesProductionEndpoint: Bool

    public init(
        replaceID: Identifier,
        mapping: ExecutionContractRequestMapping,
        lifecycleState: OrderLifecycleState = .replaceRequested,
        authorizesProductionTrading: Bool = false,
        touchesProductionEndpoint: Bool = false
    ) throws {
        guard mapping.operation == .replace else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract replace requires replace mapping")
        }
        guard lifecycleState == .replaceRequested || lifecycleState == .replaced else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract replace state must be replaceRequested or replaced")
        }
        try ExecutionContractInterface.validateBoundary(
            authorizesProductionTrading: authorizesProductionTrading,
            touchesProductionEndpoint: touchesProductionEndpoint
        )
        guard replaceID == Self.deterministicID(mappingID: mapping.mappingID, state: lifecycleState) else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract replace ID must be deterministic")
        }

        self.replaceID = replaceID
        self.mappingID = mapping.mappingID
        self.lifecycleState = lifecycleState
        self.authorizesProductionTrading = authorizesProductionTrading
        self.touchesProductionEndpoint = touchesProductionEndpoint
    }

    public static func deterministicID(mappingID: Identifier, state: OrderLifecycleState) -> Identifier {
        .constant("execution-contract-replace:\(mappingID.rawValue):\(state.rawValue)", field: "executionContract.replaceID")
    }
}

/// ExecutionContractAuditEvidence 汇总 execution contract 的阶段覆盖和边界证据。
public struct ExecutionContractAuditEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let coveredStages: [ExecutionContractStage]
    public let adapterModes: [ExecutionContractAdapterMode]
    public let validationAnchors: [String]
    public let productionAdapterImplementationPresent: Bool
    public let authorizesProductionTrading: Bool
    public let touchesProductionEndpoint: Bool

    public init(
        evidenceID: Identifier,
        coveredStages: [ExecutionContractStage] = ExecutionContractInterface.requiredStages,
        adapterModes: [ExecutionContractAdapterMode] = ExecutionContractInterface.requiredAdapterModes,
        validationAnchors: [String] = ExecutionContractInterface.requiredValidationAnchors,
        productionAdapterImplementationPresent: Bool = false,
        authorizesProductionTrading: Bool = false,
        touchesProductionEndpoint: Bool = false
    ) throws {
        guard coveredStages == ExecutionContractInterface.requiredStages else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract audit evidence must cover every required stage")
        }
        guard adapterModes == ExecutionContractInterface.requiredAdapterModes else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract audit evidence must cover dry-run and Binance testnet modes")
        }
        guard validationAnchors == ExecutionContractInterface.requiredValidationAnchors else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract audit evidence anchors changed")
        }
        guard productionAdapterImplementationPresent == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract must not include production adapter implementation")
        }
        try ExecutionContractInterface.validateBoundary(
            authorizesProductionTrading: authorizesProductionTrading,
            touchesProductionEndpoint: touchesProductionEndpoint
        )
        guard evidenceID == Self.deterministicID(coveredStages: coveredStages, adapterModes: adapterModes) else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract audit evidence ID must be deterministic")
        }

        self.evidenceID = evidenceID
        self.coveredStages = coveredStages
        self.adapterModes = adapterModes
        self.validationAnchors = validationAnchors
        self.productionAdapterImplementationPresent = productionAdapterImplementationPresent
        self.authorizesProductionTrading = authorizesProductionTrading
        self.touchesProductionEndpoint = touchesProductionEndpoint
    }

    public var boundaryHeld: Bool {
        coveredStages == ExecutionContractInterface.requiredStages
            && adapterModes == ExecutionContractInterface.requiredAdapterModes
            && validationAnchors == ExecutionContractInterface.requiredValidationAnchors
            && productionAdapterImplementationPresent == false
            && authorizesProductionTrading == false
            && touchesProductionEndpoint == false
    }

    public static func deterministicID(
        coveredStages: [ExecutionContractStage],
        adapterModes: [ExecutionContractAdapterMode]
    ) -> Identifier {
        .constant(
            [
                "execution-contract-audit",
                coveredStages.map(\.rawValue).joined(separator: ","),
                adapterModes.map(\.rawValue).joined(separator: ",")
            ].joined(separator: ":"),
            field: "executionContract.evidenceID"
        )
    }
}

/// ExecutionContractInterface 固定 ExecutionEngine 与 adapter 之间的 v0.14.0 interface contract。
public struct ExecutionContractInterface: Codable, Equatable, Sendable {
    public let consumedBy: String
    public let implementedByModes: [ExecutionContractAdapterMode]
    public let stages: [ExecutionContractStage]
    public let productionAdapterImplementationPresent: Bool
    public let productionTradingEnabledByDefault: Bool
    public let authorizesProductionTrading: Bool
    public let touchesProductionEndpoint: Bool

    public init(
        consumedBy: String = "ExecutionEngine",
        implementedByModes: [ExecutionContractAdapterMode] = Self.requiredAdapterModes,
        stages: [ExecutionContractStage] = Self.requiredStages,
        productionAdapterImplementationPresent: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        authorizesProductionTrading: Bool = false,
        touchesProductionEndpoint: Bool = false
    ) throws {
        guard consumedBy == "ExecutionEngine" else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract must be consumed by ExecutionEngine")
        }
        guard implementedByModes == Self.requiredAdapterModes else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract must be implemented by dry-run and Binance testnet adapters")
        }
        guard stages == Self.requiredStages else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract stage separation changed")
        }
        guard productionAdapterImplementationPresent == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract must not include production adapter implementation")
        }
        guard productionTradingEnabledByDefault == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract must keep production trading disabled by default")
        }
        try Self.validateBoundary(
            authorizesProductionTrading: authorizesProductionTrading,
            touchesProductionEndpoint: touchesProductionEndpoint
        )

        self.consumedBy = consumedBy
        self.implementedByModes = implementedByModes
        self.stages = stages
        self.productionAdapterImplementationPresent = productionAdapterImplementationPresent
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.authorizesProductionTrading = authorizesProductionTrading
        self.touchesProductionEndpoint = touchesProductionEndpoint
    }

    public var boundaryHeld: Bool {
        consumedBy == "ExecutionEngine"
            && implementedByModes == Self.requiredAdapterModes
            && stages == Self.requiredStages
            && productionAdapterImplementationPresent == false
            && productionTradingEnabledByDefault == false
            && authorizesProductionTrading == false
            && touchesProductionEndpoint == false
    }

    public static let schemaVersion = "v0.14.0-execution-contract"

    public static let requiredAdapterModes: [ExecutionContractAdapterMode] = [
        .dryRun,
        .binanceTestnet
    ]

    public static let requiredStages: [ExecutionContractStage] = [
        .intent,
        .requestMapping,
        .submissionResult,
        .acknowledgement,
        .rejection,
        .cancel,
        .replace,
        .auditEvidence
    ]

    public static let requiredValidationAnchors = [
        "GH-1027-EXECUTION-CONTRACT-INTERFACE",
        "GH-1027-EXECUTION-CONTRACT-STAGE-SEPARATION",
        "GH-1027-EXECUTION-CONTRACT-NO-PRODUCTION-ADAPTER",
        "TVM-RELEASE-V0140-EXECUTION-CONTRACT-INTERFACE"
    ]

    public static func validateBoundary(
        carriesEndpointPath: Bool = false,
        carriesCredentialMaterial: Bool = false,
        authorizesProductionTrading: Bool = false,
        touchesProductionEndpoint: Bool = false
    ) throws {
        guard carriesEndpointPath == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract must not carry endpoint path in GH-1027")
        }
        guard carriesCredentialMaterial == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract must not carry credential material in GH-1027")
        }
        guard authorizesProductionTrading == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract must not authorize production trading")
        }
        guard touchesProductionEndpoint == false else {
            throw ExecutionContractError.invalidBoundary("ExecutionContract must not touch production endpoint")
        }
    }
}
