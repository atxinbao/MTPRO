import DomainModel
import Foundation

/// MTP-188 的 ExecutionClient BrokerCapabilityMatrix 只描述 future venue capability taxonomy。
///
/// 该矩阵不是 capability discovery runtime，不读取 credential，不做 network probe，不创建 broker
/// adapter，也不实现 signed request、account endpoint、order submit / cancel / replace、execution report、
/// broker fill 或 reconciliation。它只让 target source layout 中的 `ExecutionClient/BrokerCapabilityMatrix`
/// 有明确的 future-gated 边界证据。
public enum ExecutionClientBrokerCapabilityMatrixEntry: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case futureVenueAPIClient = "future venue API client"
    case signedEndpointFutureGate = "signed endpoint future gate"
    case accountEndpointFutureGate = "account endpoint future gate"
    case orderSubmitForbidden = "order submit forbidden"
    case orderCancelForbidden = "order cancel forbidden"
    case orderReplaceForbidden = "order replace forbidden"
    case executionReportForbidden = "execution report forbidden"
    case brokerFillForbidden = "broker fill forbidden"
    case reconciliationForbidden = "reconciliation forbidden"
}

/// ExecutionClientBrokerCapabilityMatrixFutureGate 固定 ExecutionClient 目录下的非实现边界。
///
/// 所有 `implements*` / `uses*` flag 必须保持 false。后续如果要实现真实 client，必须另开 Human +
/// PLN 规划、Linear Project、queue preflight 和 Live gate；当前 source migration PR 不授权。
public struct ExecutionClientBrokerCapabilityMatrixFutureGate: Codable, Equatable, Sendable {
    public let matrixID: Identifier
    public let entries: [ExecutionClientBrokerCapabilityMatrixEntry]
    public let isFutureGateOnly: Bool
    public let implementsExecutionClient: Bool
    public let implementsBrokerAdapter: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let parsesExecutionReport: Bool
    public let parsesBrokerFill: Bool
    public let performsReconciliation: Bool

    public var futureGateBoundaryHeld: Bool {
        entries == ExecutionClientBrokerCapabilityMatrixEntry.allCases
            && isFutureGateOnly
            && implementsExecutionClient == false
            && implementsBrokerAdapter == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && parsesExecutionReport == false
            && parsesBrokerFill == false
            && performsReconciliation == false
    }

    private enum CodingKeys: String, CodingKey {
        case matrixID
        case entries
        case isFutureGateOnly
        case implementsExecutionClient
        case implementsBrokerAdapter
        case usesSignedEndpoint
        case callsAccountEndpoint
        case submitsRealOrder
        case cancelsRealOrder
        case replacesRealOrder
        case parsesExecutionReport
        case parsesBrokerFill
        case performsReconciliation
    }

    public init(
        matrixID: Identifier = try! Identifier("mtp-188-executionclient-broker-capability-matrix"),
        entries: [ExecutionClientBrokerCapabilityMatrixEntry] = ExecutionClientBrokerCapabilityMatrixEntry.allCases,
        isFutureGateOnly: Bool = true,
        implementsExecutionClient: Bool = false,
        implementsBrokerAdapter: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        parsesExecutionReport: Bool = false,
        parsesBrokerFill: Bool = false,
        performsReconciliation: Bool = false
    ) throws {
        try Self.validateBoundary(
            entries: entries,
            isFutureGateOnly: isFutureGateOnly,
            implementsExecutionClient: implementsExecutionClient,
            implementsBrokerAdapter: implementsBrokerAdapter,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            parsesExecutionReport: parsesExecutionReport,
            parsesBrokerFill: parsesBrokerFill,
            performsReconciliation: performsReconciliation
        )

        self.matrixID = matrixID
        self.entries = entries
        self.isFutureGateOnly = isFutureGateOnly
        self.implementsExecutionClient = implementsExecutionClient
        self.implementsBrokerAdapter = implementsBrokerAdapter
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.parsesExecutionReport = parsesExecutionReport
        self.parsesBrokerFill = parsesBrokerFill
        self.performsReconciliation = performsReconciliation
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            matrixID: try container.decode(Identifier.self, forKey: .matrixID),
            entries: try container.decode([ExecutionClientBrokerCapabilityMatrixEntry].self, forKey: .entries),
            isFutureGateOnly: try container.decode(Bool.self, forKey: .isFutureGateOnly),
            implementsExecutionClient: try container.decode(Bool.self, forKey: .implementsExecutionClient),
            implementsBrokerAdapter: try container.decode(Bool.self, forKey: .implementsBrokerAdapter),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            parsesExecutionReport: try container.decode(Bool.self, forKey: .parsesExecutionReport),
            parsesBrokerFill: try container.decode(Bool.self, forKey: .parsesBrokerFill),
            performsReconciliation: try container.decode(Bool.self, forKey: .performsReconciliation)
        )
    }

    private static func validateBoundary(
        entries: [ExecutionClientBrokerCapabilityMatrixEntry],
        isFutureGateOnly: Bool,
        implementsExecutionClient: Bool,
        implementsBrokerAdapter: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        parsesExecutionReport: Bool,
        parsesBrokerFill: Bool,
        performsReconciliation: Bool
    ) throws {
        guard entries == ExecutionClientBrokerCapabilityMatrixEntry.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "entries",
                expected: "ExecutionClientBrokerCapabilityMatrixEntry.allCases",
                actual: "\(entries)"
            )
        }
        guard isFutureGateOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("isFutureGateOnly")
        }
        for capability in [
            ("implementsExecutionClient", implementsExecutionClient),
            ("implementsBrokerAdapter", implementsBrokerAdapter),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("parsesExecutionReport", parsesExecutionReport),
            ("parsesBrokerFill", parsesBrokerFill),
            ("performsReconciliation", performsReconciliation)
        ] where capability.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}
