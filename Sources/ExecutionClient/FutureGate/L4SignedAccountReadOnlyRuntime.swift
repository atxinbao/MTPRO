import DomainModel
import Foundation

/// L4SignedAccountReadOnlyRuntimeMode 定义 GH-455 signed account read-only runtime 的触发模式。
///
/// 默认 `disabled` 不能读取任何 evidence；`localFixture` 和 `sandboxConfigured` 只允许返回
/// deterministic read-model evidence，不连接 signed endpoint、不读取 secret、不打开 production gate。
public enum L4SignedAccountReadOnlyRuntimeMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case disabled = "disabled"
    case localFixture = "local fixture"
    case sandboxConfigured = "sandbox configured"
    case production = "production"
}

/// L4SignedAccountReadOnlyEvidenceComponent 固定 GH-455 可以暴露的 canonical account evidence。
///
/// 这些 component 是 read-model-only 输出字段，不是 raw signed account payload、broker state、
/// account endpoint JSON、private stream event 或 Dashboard command state。
public enum L4SignedAccountReadOnlyEvidenceComponent: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case account = "account"
    case balance = "balance"
    case position = "position"
    case margin = "margin"
}

/// L4SignedAccountReadOnlyForbiddenCapability 枚举 GH-455 runtime 必须保持关闭的能力。
///
/// Runtime 可以在 sandbox / local fixture gate 下返回 canonical evidence，但仍不能读取真实
/// credential、调用 endpoint、暴露 raw payload、连接 broker、实现 OMS 或执行交易命令。
public enum L4SignedAccountReadOnlyForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case unconfiguredSignedRead = "unconfigured signed read"
    case productionGateEnabled = "production gate enabled"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case credentialValueRead = "credential value read"
    case secretMaterialAvailable = "secret material available"
    case apiKeyHeaderConstruction = "API-key header construction"
    case requestSignatureGeneration = "request signature generation"
    case signedEndpointCall = "signed endpoint call"
    case accountEndpointCall = "account endpoint call"
    case rawSignedPayloadExposure = "raw signed payload exposure"
    case dashboardRawPayloadExposure = "Dashboard raw payload exposure"
    case brokerStateExposure = "broker state exposure"
    case privateStreamOpen = "private stream open"
    case executionClientAdapterImplementation = "ExecutionClient adapter implementation"
    case omsImplementation = "OMS implementation"
    case commandRuntime = "command runtime"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case liveProConsoleCommandSurface = "Live PRO Console command surface"
    case orderForm = "order form"
}

/// L4SignedAccountReadOnlyRuntimeConfiguration 是 GH-455 的 runtime 输入合同。
///
/// 配置只允许携带 credential reference identity 和 sandbox / fixture gate。它不携带 credential
/// value，不读取环境变量 value，不构造 signed request，也不授权 production endpoint。
public struct L4SignedAccountReadOnlyRuntimeConfiguration: Codable, Equatable, Sendable {
    public let mode: L4SignedAccountReadOnlyRuntimeMode
    public let credentialReference: String?
    public let sourceIdentity: String
    public let sandboxGateEnabled: Bool
    public let fixtureReadEnabled: Bool
    public let productionGateEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let secretMaterialAvailable: Bool
    public let rawPayloadExposureAllowed: Bool
    public let networkConnectionAllowed: Bool
    public let dashboardRawPayloadAllowed: Bool

    public init(
        mode: L4SignedAccountReadOnlyRuntimeMode = .disabled,
        credentialReference: String? = nil,
        sourceIdentity: String = "gh-455-disabled-signed-account-read-only-runtime",
        sandboxGateEnabled: Bool = false,
        fixtureReadEnabled: Bool = false,
        productionGateEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        secretMaterialAvailable: Bool = false,
        rawPayloadExposureAllowed: Bool = false,
        networkConnectionAllowed: Bool = false,
        dashboardRawPayloadAllowed: Bool = false
    ) throws {
        guard mode != .production else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("mode.production")
        }
        guard productionGateEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionGateEnabled")
        }
        guard productionTradingEnabledByDefault == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionTradingEnabledByDefault")
        }
        guard secretMaterialAvailable == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("secretMaterialAvailable")
        }
        guard rawPayloadExposureAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("rawPayloadExposureAllowed")
        }
        guard networkConnectionAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("networkConnectionAllowed")
        }
        guard dashboardRawPayloadAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("dashboardRawPayloadAllowed")
        }
        if mode != .disabled {
            guard let credentialReference, credentialReference.isEmpty == false else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "credentialReference",
                    expected: "non-empty external credential reference identity",
                    actual: "missing"
                )
            }
            guard sandboxGateEnabled else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "sandboxGateEnabled",
                    expected: "true",
                    actual: "false"
                )
            }
            guard fixtureReadEnabled else {
                throw CoreError.liveTradingBoundaryContractMismatch(
                    field: "fixtureReadEnabled",
                    expected: "true",
                    actual: "false"
                )
            }
        }

        self.mode = mode
        self.credentialReference = credentialReference
        self.sourceIdentity = sourceIdentity
        self.sandboxGateEnabled = sandboxGateEnabled
        self.fixtureReadEnabled = fixtureReadEnabled
        self.productionGateEnabled = productionGateEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.secretMaterialAvailable = secretMaterialAvailable
        self.rawPayloadExposureAllowed = rawPayloadExposureAllowed
        self.networkConnectionAllowed = networkConnectionAllowed
        self.dashboardRawPayloadAllowed = dashboardRawPayloadAllowed
    }

    public static func disabled() throws -> L4SignedAccountReadOnlyRuntimeConfiguration {
        try L4SignedAccountReadOnlyRuntimeConfiguration()
    }

    public static func sandboxFixture(
        credentialReference: String = "credential-reference:gh-453-external"
    ) throws -> L4SignedAccountReadOnlyRuntimeConfiguration {
        try L4SignedAccountReadOnlyRuntimeConfiguration(
            mode: .sandboxConfigured,
            credentialReference: credentialReference,
            sourceIdentity: "gh-455-sandbox-configured-account-read-only-fixture",
            sandboxGateEnabled: true,
            fixtureReadEnabled: true
        )
    }
}

/// L4SignedAccountReadOnlyEvidenceRecord 是 GH-455 输出的 canonical account evidence 行。
///
/// `canonicalValue` 是经过归一化的 read-model evidence，不是 raw account endpoint payload。
/// 每一行都固定 source identity，确保 Dashboard / Report 只能消费安全的 canonical evidence。
public struct L4SignedAccountReadOnlyEvidenceRecord: Codable, Equatable, Sendable {
    public let component: L4SignedAccountReadOnlyEvidenceComponent
    public let canonicalValue: String
    public let sourceIdentity: String
    public let rawPayloadExposed: Bool

    public init(
        component: L4SignedAccountReadOnlyEvidenceComponent,
        canonicalValue: String,
        sourceIdentity: String,
        rawPayloadExposed: Bool = false
    ) throws {
        guard canonicalValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "canonicalValue",
                expected: "non-empty canonical account evidence",
                actual: "empty"
            )
        }
        guard sourceIdentity.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIdentity",
                expected: "non-empty source identity",
                actual: "empty"
            )
        }
        guard rawPayloadExposed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("rawPayloadExposed")
        }

        self.component = component
        self.canonicalValue = canonicalValue
        self.sourceIdentity = sourceIdentity
        self.rawPayloadExposed = rawPayloadExposed
    }
}

/// L4SignedAccountReadOnlyEvidence 是 GH-455 runtime 的唯一输出。
///
/// Evidence 只暴露 canonical account / balance / position / margin 记录和 boundary flags。
/// 它不包含 secret、raw signed payload、broker state、private stream event 或 command state。
public struct L4SignedAccountReadOnlyEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let sourceIdentity: String
    public let records: [L4SignedAccountReadOnlyEvidenceRecord]
    public let validationAnchors: [String]
    public let readModelOnly: Bool
    public let rawSignedPayloadExposed: Bool
    public let dashboardRawPayloadExposed: Bool
    public let brokerStateExposed: Bool
    public let productionGateEnabled: Bool
    public let commandRuntimeEnabled: Bool

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-455"
            && Set(records.map(\.component)) == Set(L4SignedAccountReadOnlyEvidenceComponent.allCases)
            && records.allSatisfy { $0.rawPayloadExposed == false }
            && validationAnchors == L4SignedAccountReadOnlyRuntime.requiredValidationAnchors
            && readModelOnly
            && rawSignedPayloadExposed == false
            && dashboardRawPayloadExposed == false
            && brokerStateExposed == false
            && productionGateEnabled == false
            && commandRuntimeEnabled == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-455-signed-account-read-only-evidence"),
        issueID: Identifier = Identifier.constant("GH-455"),
        sourceIdentity: String,
        records: [L4SignedAccountReadOnlyEvidenceRecord],
        validationAnchors: [String] = L4SignedAccountReadOnlyRuntime.requiredValidationAnchors,
        readModelOnly: Bool = true,
        rawSignedPayloadExposed: Bool = false,
        dashboardRawPayloadExposed: Bool = false,
        brokerStateExposed: Bool = false,
        productionGateEnabled: Bool = false,
        commandRuntimeEnabled: Bool = false
    ) throws {
        guard records.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "records",
                expected: "non-empty canonical account evidence records",
                actual: "empty"
            )
        }
        guard validationAnchors == L4SignedAccountReadOnlyRuntime.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: L4SignedAccountReadOnlyRuntime.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard readModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readModelOnly")
        }
        for forbiddenFlag in [
            ("rawSignedPayloadExposed", rawSignedPayloadExposed),
            ("dashboardRawPayloadExposed", dashboardRawPayloadExposed),
            ("brokerStateExposed", brokerStateExposed),
            ("productionGateEnabled", productionGateEnabled),
            ("commandRuntimeEnabled", commandRuntimeEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.sourceIdentity = sourceIdentity
        self.records = records
        self.validationAnchors = validationAnchors
        self.readModelOnly = readModelOnly
        self.rawSignedPayloadExposed = rawSignedPayloadExposed
        self.dashboardRawPayloadExposed = dashboardRawPayloadExposed
        self.brokerStateExposed = brokerStateExposed
        self.productionGateEnabled = productionGateEnabled
        self.commandRuntimeEnabled = commandRuntimeEnabled
    }
}

/// L4SignedAccountReadOnlyRuntime 是 GH-455 的 sandbox / fixture-first read-only runtime。
///
/// Runtime 默认关闭；只有 `sandboxFixture` 配置满足 credential reference identity、sandbox gate、
/// fixture gate 和 production disabled gate 时，才返回 deterministic canonical evidence。它不访问
/// 网络、不读取 secret、不签名 request、不暴露 raw payload、不实现 command runtime。
public struct L4SignedAccountReadOnlyRuntime: Codable, Equatable, Sendable {
    public let runtimeID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let forbiddenCapabilities: [L4SignedAccountReadOnlyForbiddenCapability]
    public let validationAnchors: [String]
    public let productionDisabledByDefault: Bool
    public let networkIndependentFixtureRuntime: Bool
    public let dashboardReadModelOnlyBoundaryHeld: Bool

    public init(
        runtimeID: Identifier = Identifier.constant("gh-455-signed-account-read-only-runtime"),
        issueID: Identifier = Identifier.constant("GH-455"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-453"),
            Identifier.constant("GH-454")
        ],
        forbiddenCapabilities: [L4SignedAccountReadOnlyForbiddenCapability] =
            L4SignedAccountReadOnlyForbiddenCapability.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionDisabledByDefault: Bool = true,
        networkIndependentFixtureRuntime: Bool = true,
        dashboardReadModelOnlyBoundaryHeld: Bool = true
    ) throws {
        guard forbiddenCapabilities == L4SignedAccountReadOnlyForbiddenCapability.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: L4SignedAccountReadOnlyForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard productionDisabledByDefault else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionDisabledByDefault")
        }
        guard networkIndependentFixtureRuntime else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("networkIndependentFixtureRuntime")
        }
        guard dashboardReadModelOnlyBoundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("dashboardReadModelOnlyBoundaryHeld")
        }

        self.runtimeID = runtimeID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.productionDisabledByDefault = productionDisabledByDefault
        self.networkIndependentFixtureRuntime = networkIndependentFixtureRuntime
        self.dashboardReadModelOnlyBoundaryHeld = dashboardReadModelOnlyBoundaryHeld
    }

    public var runtimeBoundaryHeld: Bool {
        issueID.rawValue == "GH-455"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-453", "GH-454"]
            && forbiddenCapabilities == L4SignedAccountReadOnlyForbiddenCapability.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && productionDisabledByDefault
            && networkIndependentFixtureRuntime
            && dashboardReadModelOnlyBoundaryHeld
    }

    public func readAccountEvidence(
        configuration: L4SignedAccountReadOnlyRuntimeConfiguration
    ) throws -> L4SignedAccountReadOnlyEvidence {
        guard configuration.mode != .disabled else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "mode",
                expected: "local fixture or sandbox configured",
                actual: "disabled"
            )
        }
        guard configuration.sandboxGateEnabled else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxGateEnabled",
                expected: "true",
                actual: "false"
            )
        }
        guard configuration.fixtureReadEnabled else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "fixtureReadEnabled",
                expected: "true",
                actual: "false"
            )
        }
        guard configuration.productionGateEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionGateEnabled")
        }
        guard configuration.networkConnectionAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("networkConnectionAllowed")
        }

        return try Self.deterministicEvidence(sourceIdentity: configuration.sourceIdentity)
    }

    public static func deterministicFixture() throws -> L4SignedAccountReadOnlyRuntime {
        try L4SignedAccountReadOnlyRuntime()
    }

    public static let requiredValidationAnchors: [String] = [
        "GH-455-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME",
        "GH-455-DISABLED-BY-DEFAULT-RUNTIME-GATE",
        "GH-455-SANDBOX-FIXTURE-FIRST-READ",
        "GH-455-CANONICAL-ACCOUNT-EVIDENCE",
        "GH-455-FORBIDDEN-PRODUCTION-DEFAULT-TESTS",
        "GH-455-NON-AUTHORIZATION",
        "TVM-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME"
    ]

    private static func deterministicEvidence(
        sourceIdentity: String
    ) throws -> L4SignedAccountReadOnlyEvidence {
        try L4SignedAccountReadOnlyEvidence(
            sourceIdentity: sourceIdentity,
            records: [
                L4SignedAccountReadOnlyEvidenceRecord(
                    component: .account,
                    canonicalValue: "sandbox-read-only-account:enabled-by-fixture-gate",
                    sourceIdentity: sourceIdentity
                ),
                L4SignedAccountReadOnlyEvidenceRecord(
                    component: .balance,
                    canonicalValue: "USDT available 100000.00",
                    sourceIdentity: sourceIdentity
                ),
                L4SignedAccountReadOnlyEvidenceRecord(
                    component: .position,
                    canonicalValue: "BTCUSDT net 0.0000",
                    sourceIdentity: sourceIdentity
                ),
                L4SignedAccountReadOnlyEvidenceRecord(
                    component: .margin,
                    canonicalValue: "margin mode fixture-only; leverage not read",
                    sourceIdentity: sourceIdentity
                )
            ]
        )
    }
}
