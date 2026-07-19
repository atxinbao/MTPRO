import Foundation

/// LiveAdapterCapabilityIsolationBoundary 是 MTP-63 的 Gate 2 合同 fixture。
///
/// 该合同把当前 Binance public read-only adapter 与 future live adapter capability 明确隔离：
/// 当前 adapter 只能提供公开行情读取，future live adapter / broker / exchange execution adapter
/// 只能作为 future gate 和 forbidden test 出现。所有执行、venue、真实订单和网络依赖 flag 必须
/// 为 false；Codable 解码也会重新校验，防止 fixture 被篡改成实盘执行入口。
public struct LiveAdapterCapabilityIsolationBoundary: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let gate: LiveTradingFoundationGate
    public let currentAdapterName: String
    public let readOnlyAllowedCapabilities: [String]
    public let forbiddenCapabilities: [LiveAdapterIsolationForbiddenCapability]
    public let futureGates: [LiveAdapterIsolationFutureGate]
    public let allowedEvidenceKinds: [LiveAdapterIsolationEvidenceKind]
    public let currentAdapterIsReadOnly: Bool
    public let currentAdapterRequiresAPIKey: Bool
    public let currentAdapterUsesSignedEndpoint: Bool
    public let currentAdapterCallsAccountEndpoint: Bool
    public let currentAdapterCreatesListenKey: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let instantiatesBrokerExecutionAdapter: Bool
    public let instantiatesExchangeExecutionAdapter: Bool
    public let exposesExecutionVenueConnection: Bool
    public let submitsRealOrder: Bool
    public let cancelsRealOrder: Bool
    public let replacesRealOrder: Bool
    public let requiredValidationDependsOnNetwork: Bool

    public var gateTwoBoundaryHeld: Bool {
        gate == .adapterCapabilityIsolation
            && currentAdapterName == Self.currentAdapterName
            && readOnlyAllowedCapabilities == Self.requiredReadOnlyAllowedCapabilities
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && futureGates == Self.requiredFutureGates
            && allowedEvidenceKinds == Self.allowedEvidenceKinds
            && currentAdapterIsReadOnly
            && currentAdapterRequiresAPIKey == false
            && currentAdapterUsesSignedEndpoint == false
            && currentAdapterCallsAccountEndpoint == false
            && currentAdapterCreatesListenKey == false
            && implementsLiveExecutionAdapter == false
            && instantiatesBrokerExecutionAdapter == false
            && instantiatesExchangeExecutionAdapter == false
            && exposesExecutionVenueConnection == false
            && submitsRealOrder == false
            && cancelsRealOrder == false
            && replacesRealOrder == false
            && requiredValidationDependsOnNetwork == false
    }

    public init(
        contractID: Identifier = Identifier.constant("mtp-63-live-adapter-capability-isolation"),
        issueID: Identifier = Identifier.constant("MTP-63"),
        gate: LiveTradingFoundationGate = .adapterCapabilityIsolation,
        currentAdapterName: String = Self.currentAdapterName,
        readOnlyAllowedCapabilities: [String] = Self.requiredReadOnlyAllowedCapabilities,
        forbiddenCapabilities: [LiveAdapterIsolationForbiddenCapability] = Self.requiredForbiddenCapabilities,
        futureGates: [LiveAdapterIsolationFutureGate] = Self.requiredFutureGates,
        allowedEvidenceKinds: [LiveAdapterIsolationEvidenceKind] = Self.allowedEvidenceKinds,
        currentAdapterIsReadOnly: Bool = true,
        currentAdapterRequiresAPIKey: Bool = false,
        currentAdapterUsesSignedEndpoint: Bool = false,
        currentAdapterCallsAccountEndpoint: Bool = false,
        currentAdapterCreatesListenKey: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        instantiatesBrokerExecutionAdapter: Bool = false,
        instantiatesExchangeExecutionAdapter: Bool = false,
        exposesExecutionVenueConnection: Bool = false,
        submitsRealOrder: Bool = false,
        cancelsRealOrder: Bool = false,
        replacesRealOrder: Bool = false,
        requiredValidationDependsOnNetwork: Bool = false
    ) throws {
        guard gate == .adapterCapabilityIsolation else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "gate",
                expected: LiveTradingFoundationGate.adapterCapabilityIsolation.rawValue,
                actual: gate.rawValue
            )
        }
        try Self.validate(
            currentAdapterName: currentAdapterName,
            readOnlyAllowedCapabilities: readOnlyAllowedCapabilities,
            forbiddenCapabilities: forbiddenCapabilities,
            futureGates: futureGates,
            allowedEvidenceKinds: allowedEvidenceKinds
        )
        try Self.validateForbiddenFlags(
            currentAdapterIsReadOnly: currentAdapterIsReadOnly,
            currentAdapterRequiresAPIKey: currentAdapterRequiresAPIKey,
            currentAdapterUsesSignedEndpoint: currentAdapterUsesSignedEndpoint,
            currentAdapterCallsAccountEndpoint: currentAdapterCallsAccountEndpoint,
            currentAdapterCreatesListenKey: currentAdapterCreatesListenKey,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            instantiatesBrokerExecutionAdapter: instantiatesBrokerExecutionAdapter,
            instantiatesExchangeExecutionAdapter: instantiatesExchangeExecutionAdapter,
            exposesExecutionVenueConnection: exposesExecutionVenueConnection,
            submitsRealOrder: submitsRealOrder,
            cancelsRealOrder: cancelsRealOrder,
            replacesRealOrder: replacesRealOrder,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork
        )

        self.contractID = contractID
        self.issueID = issueID
        self.gate = gate
        self.currentAdapterName = currentAdapterName
        self.readOnlyAllowedCapabilities = readOnlyAllowedCapabilities
        self.forbiddenCapabilities = forbiddenCapabilities
        self.futureGates = futureGates
        self.allowedEvidenceKinds = allowedEvidenceKinds
        self.currentAdapterIsReadOnly = currentAdapterIsReadOnly
        self.currentAdapterRequiresAPIKey = currentAdapterRequiresAPIKey
        self.currentAdapterUsesSignedEndpoint = currentAdapterUsesSignedEndpoint
        self.currentAdapterCallsAccountEndpoint = currentAdapterCallsAccountEndpoint
        self.currentAdapterCreatesListenKey = currentAdapterCreatesListenKey
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.instantiatesBrokerExecutionAdapter = instantiatesBrokerExecutionAdapter
        self.instantiatesExchangeExecutionAdapter = instantiatesExchangeExecutionAdapter
        self.exposesExecutionVenueConnection = exposesExecutionVenueConnection
        self.submitsRealOrder = submitsRealOrder
        self.cancelsRealOrder = cancelsRealOrder
        self.replacesRealOrder = replacesRealOrder
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            gate: try container.decode(LiveTradingFoundationGate.self, forKey: .gate),
            currentAdapterName: try container.decode(String.self, forKey: .currentAdapterName),
            readOnlyAllowedCapabilities: try container.decode([String].self, forKey: .readOnlyAllowedCapabilities),
            forbiddenCapabilities: try container.decode(
                [LiveAdapterIsolationForbiddenCapability].self,
                forKey: .forbiddenCapabilities
            ),
            futureGates: try container.decode([LiveAdapterIsolationFutureGate].self, forKey: .futureGates),
            allowedEvidenceKinds: try container.decode(
                [LiveAdapterIsolationEvidenceKind].self,
                forKey: .allowedEvidenceKinds
            ),
            currentAdapterIsReadOnly: try container.decode(Bool.self, forKey: .currentAdapterIsReadOnly),
            currentAdapterRequiresAPIKey: try container.decode(Bool.self, forKey: .currentAdapterRequiresAPIKey),
            currentAdapterUsesSignedEndpoint: try container.decode(
                Bool.self,
                forKey: .currentAdapterUsesSignedEndpoint
            ),
            currentAdapterCallsAccountEndpoint: try container.decode(
                Bool.self,
                forKey: .currentAdapterCallsAccountEndpoint
            ),
            currentAdapterCreatesListenKey: try container.decode(Bool.self, forKey: .currentAdapterCreatesListenKey),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            instantiatesBrokerExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesBrokerExecutionAdapter
            ),
            instantiatesExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .instantiatesExchangeExecutionAdapter
            ),
            exposesExecutionVenueConnection: try container.decode(
                Bool.self,
                forKey: .exposesExecutionVenueConnection
            ),
            submitsRealOrder: try container.decode(Bool.self, forKey: .submitsRealOrder),
            cancelsRealOrder: try container.decode(Bool.self, forKey: .cancelsRealOrder),
            replacesRealOrder: try container.decode(Bool.self, forKey: .replacesRealOrder),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            )
        )
    }

    public static let currentAdapterName = "Binance public market data"

    public static let requiredReadOnlyAllowedCapabilities = [
        "exchangeInfo",
        "klines",
        "recent trades",
        "best bid / ask",
        "depth snapshot",
        "depth delta"
    ]

    public static let requiredForbiddenCapabilities = LiveAdapterIsolationForbiddenCapability.allCases

    public static let requiredFutureGates: [LiveAdapterIsolationFutureGate] = [
        .humanLiveDecision,
        .credentialEndpointBoundarySatisfied,
        .adapterCapabilityContract,
        .brokerExchangeAdapterContract,
        .realOrderLifecycleContract,
        .riskAndOperationsReadiness,
        .auditEvidence
    ]

    public static let allowedEvidenceKinds: [LiveAdapterIsolationEvidenceKind] = [
        .contractDocumentation,
        .validationMatrixAnchor,
        .automationReadinessAnchor,
        .deterministicForbiddenTest,
        .prBoundaryEvidence
    ]

    public static let deterministicFixture: LiveAdapterCapabilityIsolationBoundary = {
        do {
            return try LiveAdapterCapabilityIsolationBoundary()
        } catch {
            preconditionFailure("MTP-63 Live adapter capability isolation fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        currentAdapterName: String,
        readOnlyAllowedCapabilities: [String],
        forbiddenCapabilities: [LiveAdapterIsolationForbiddenCapability],
        futureGates: [LiveAdapterIsolationFutureGate],
        allowedEvidenceKinds: [LiveAdapterIsolationEvidenceKind]
    ) throws {
        guard currentAdapterName == Self.currentAdapterName else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "currentAdapterName",
                expected: Self.currentAdapterName,
                actual: currentAdapterName
            )
        }
        guard readOnlyAllowedCapabilities == Self.requiredReadOnlyAllowedCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "readOnlyAllowedCapabilities",
                expected: Self.requiredReadOnlyAllowedCapabilities.joined(separator: ","),
                actual: readOnlyAllowedCapabilities.joined(separator: ",")
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard futureGates == Self.requiredFutureGates else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "futureGates",
                expected: Self.requiredFutureGates.map(\.rawValue).joined(separator: ","),
                actual: futureGates.map(\.rawValue).joined(separator: ",")
            )
        }
        guard allowedEvidenceKinds == Self.allowedEvidenceKinds else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "allowedEvidenceKinds",
                expected: Self.allowedEvidenceKinds.map(\.rawValue).joined(separator: ","),
                actual: allowedEvidenceKinds.map(\.rawValue).joined(separator: ",")
            )
        }
    }

    private static func validateForbiddenFlags(
        currentAdapterIsReadOnly: Bool,
        currentAdapterRequiresAPIKey: Bool,
        currentAdapterUsesSignedEndpoint: Bool,
        currentAdapterCallsAccountEndpoint: Bool,
        currentAdapterCreatesListenKey: Bool,
        implementsLiveExecutionAdapter: Bool,
        instantiatesBrokerExecutionAdapter: Bool,
        instantiatesExchangeExecutionAdapter: Bool,
        exposesExecutionVenueConnection: Bool,
        submitsRealOrder: Bool,
        cancelsRealOrder: Bool,
        replacesRealOrder: Bool,
        requiredValidationDependsOnNetwork: Bool
    ) throws {
        guard currentAdapterIsReadOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("currentAdapterIsReadOnly")
        }

        let forbiddenFlags = [
            ("currentAdapterRequiresAPIKey", currentAdapterRequiresAPIKey),
            ("currentAdapterUsesSignedEndpoint", currentAdapterUsesSignedEndpoint),
            ("currentAdapterCallsAccountEndpoint", currentAdapterCallsAccountEndpoint),
            ("currentAdapterCreatesListenKey", currentAdapterCreatesListenKey),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("instantiatesBrokerExecutionAdapter", instantiatesBrokerExecutionAdapter),
            ("instantiatesExchangeExecutionAdapter", instantiatesExchangeExecutionAdapter),
            ("exposesExecutionVenueConnection", exposesExecutionVenueConnection),
            ("submitsRealOrder", submitsRealOrder),
            ("cancelsRealOrder", cancelsRealOrder),
            ("replacesRealOrder", replacesRealOrder),
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveTradingBoundaryForbiddenCapability(capability.0)
        }
    }
}
