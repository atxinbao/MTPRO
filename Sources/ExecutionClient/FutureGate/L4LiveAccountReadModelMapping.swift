import DomainModel
import Foundation

/// L4LiveAccountReadModelComponent 固定 GH-457 的 live APB / margin read-model component。
///
/// 这些 component 是 Dashboard / Report 可消费的 canonical read model 维度，不是 broker object、
/// account endpoint schema、Runtime object、Adapter request 或 command state。
public enum L4LiveAccountReadModelComponent: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case account = "account"
    case position = "position"
    case balance = "balance"
    case margin = "margin"
}

/// L4LiveAccountReadModelSourceKind 区分 GH-457 mapping 的证据来源。
///
/// `sandboxFixtureEvidence` 表示当前值来自 deterministic fixture；`liveReadOnlyExplanation`
/// 只表达 live read model 语义解释，不等于真实账户 payload、broker state 或 real PnL runtime。
public enum L4LiveAccountReadModelSourceKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signedAccountEvidence = "GH-455 signed account evidence"
    case privateStreamEvidence = "GH-456 private stream evidence"
    case sandboxFixtureEvidence = "sandbox fixture evidence"
    case liveReadOnlyExplanation = "live read-only explanation"
}

/// L4LiveAccountReadModelInterpretationMode 固定 fixture / sandbox 和 future real account 的解释分界。
///
/// 当前 GH-457 只能使用 sandbox fixture interpretation；future real account interpretation 只是
/// read-model 语义标签，不能把 fixture 值伪装成真实账户，也不能读取真实账户 payload。
public enum L4LiveAccountReadModelInterpretationMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case sandboxFixture = "sandbox fixture interpretation"
    case futureRealAccountReadOnly = "future real account read-only interpretation"
}

/// L4LiveAccountReadModelForbiddenCapability 枚举 GH-457 mapping 必须保持禁止的能力。
///
/// Mapping 只能解释 canonical evidence，不得暴露 raw account payload、broker state、schema、
/// Runtime object、Adapter request、real PnL、reconciliation、ExecutionClient adapter、OMS 或 command surface。
public enum L4LiveAccountReadModelForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case rawAccountPayloadExposure = "raw account payload exposure"
    case rawPrivatePayloadExposure = "raw private payload exposure"
    case brokerStateExposure = "broker state exposure"
    case runtimeObjectExposure = "Runtime object exposure"
    case adapterRequestExposure = "Adapter request exposure"
    case schemaExposure = "schema exposure"
    case realPnLRuntime = "real PnL runtime"
    case marginLeverageRuntime = "margin / leverage runtime"
    case commandSurface = "command surface"
    case reconciliationRuntime = "reconciliation runtime"
    case executionReportIngestion = "execution report ingestion"
    case brokerFillIngestion = "broker fill ingestion"
    case executionClientAdapterImplementation = "ExecutionClient adapter implementation"
    case omsImplementation = "OMS implementation"
    case realSubmitCancelReplace = "real submit / cancel / replace"
    case liveProConsoleCommandSurface = "Live PRO Console command surface"
    case orderForm = "order form"
    case productionTradingEnabledByDefault = "production trading enabled by default"
}

/// L4LiveAccountReadModelRecord 是 GH-457 的 account / position / balance / margin read model 行。
///
/// `canonicalReadModelValue` 是从 GH-455 / GH-456 evidence 解释出的 canonical 值。该结构不保存
/// raw account payload、broker state、schema、Runtime object 或 Adapter request。
public struct L4LiveAccountReadModelRecord: Codable, Equatable, Sendable {
    public let component: L4LiveAccountReadModelComponent
    public let sourceKinds: [L4LiveAccountReadModelSourceKind]
    public let interpretationMode: L4LiveAccountReadModelInterpretationMode
    public let freshnessStatus: L4PrivateStreamFreshnessStatus
    public let canonicalReadModelValue: String
    public let evidenceIdentity: Identifier
    public let sourceIdentity: String
    public let rawAccountPayloadExposed: Bool
    public let brokerStateExposed: Bool
    public let runtimeObjectExposed: Bool
    public let adapterRequestExposed: Bool
    public let schemaExposed: Bool
    public let commandSurfaceEnabled: Bool

    public init(
        component: L4LiveAccountReadModelComponent,
        sourceKinds: [L4LiveAccountReadModelSourceKind],
        interpretationMode: L4LiveAccountReadModelInterpretationMode,
        freshnessStatus: L4PrivateStreamFreshnessStatus,
        canonicalReadModelValue: String,
        evidenceIdentity: Identifier,
        sourceIdentity: String,
        rawAccountPayloadExposed: Bool = false,
        brokerStateExposed: Bool = false,
        runtimeObjectExposed: Bool = false,
        adapterRequestExposed: Bool = false,
        schemaExposed: Bool = false,
        commandSurfaceEnabled: Bool = false
    ) throws {
        guard sourceKinds.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceKinds",
                expected: "non-empty read-model source kinds",
                actual: "empty"
            )
        }
        guard canonicalReadModelValue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "canonicalReadModelValue",
                expected: "non-empty live account read-model value",
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
        for forbiddenFlag in [
            ("rawAccountPayloadExposed", rawAccountPayloadExposed),
            ("brokerStateExposed", brokerStateExposed),
            ("runtimeObjectExposed", runtimeObjectExposed),
            ("adapterRequestExposed", adapterRequestExposed),
            ("schemaExposed", schemaExposed),
            ("commandSurfaceEnabled", commandSurfaceEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.component = component
        self.sourceKinds = sourceKinds
        self.interpretationMode = interpretationMode
        self.freshnessStatus = freshnessStatus
        self.canonicalReadModelValue = canonicalReadModelValue
        self.evidenceIdentity = evidenceIdentity
        self.sourceIdentity = sourceIdentity
        self.rawAccountPayloadExposed = rawAccountPayloadExposed
        self.brokerStateExposed = brokerStateExposed
        self.runtimeObjectExposed = runtimeObjectExposed
        self.adapterRequestExposed = adapterRequestExposed
        self.schemaExposed = schemaExposed
        self.commandSurfaceEnabled = commandSurfaceEnabled
    }
}

/// L4LiveAccountReadModel 是 GH-457 mapper 的唯一输出。
///
/// Output 只包含 APB / margin canonical records、freshness statuses 和 boundary flags。它不包含
/// real account payload、broker state、runtime object、adapter request、schema、real PnL 或 command state。
public struct L4LiveAccountReadModel: Codable, Equatable, Sendable {
    public let readModelID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let signedAccountEvidenceID: Identifier
    public let privateStreamEvidenceID: Identifier
    public let records: [L4LiveAccountReadModelRecord]
    public let freshnessStatuses: [L4PrivateStreamFreshnessStatus]
    public let validationAnchors: [String]
    public let dashboardReadModelOnly: Bool
    public let fixtureSandboxAndRealAccountSeparated: Bool
    public let rawAccountPayloadExposed: Bool
    public let brokerStateExposed: Bool
    public let runtimeObjectExposed: Bool
    public let adapterRequestExposed: Bool
    public let schemaExposed: Bool
    public let realPnLRuntimeEnabled: Bool
    public let commandSurfaceEnabled: Bool
    public let productionGateEnabled: Bool

    public var mappingBoundaryHeld: Bool {
        issueID.rawValue == "GH-457"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-455", "GH-456"]
            && signedAccountEvidenceID.rawValue == "gh-455-signed-account-read-only-evidence"
            && privateStreamEvidenceID.rawValue == "gh-456-private-stream-account-snapshot-read-only-evidence"
            && Set(records.map(\.component)) == Set(L4LiveAccountReadModelComponent.allCases)
            && Set(freshnessStatuses) == Set(L4PrivateStreamFreshnessStatus.allCases)
            && records.allSatisfy { $0.interpretationMode == .sandboxFixture }
            && records.allSatisfy { $0.rawAccountPayloadExposed == false }
            && records.allSatisfy { $0.brokerStateExposed == false }
            && records.allSatisfy { $0.runtimeObjectExposed == false }
            && records.allSatisfy { $0.adapterRequestExposed == false }
            && records.allSatisfy { $0.schemaExposed == false }
            && records.allSatisfy { $0.commandSurfaceEnabled == false }
            && validationAnchors == L4LiveAccountReadModelMapping.requiredValidationAnchors
            && dashboardReadModelOnly
            && fixtureSandboxAndRealAccountSeparated
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            rawAccountPayloadExposed,
            brokerStateExposed,
            runtimeObjectExposed,
            adapterRequestExposed,
            schemaExposed,
            realPnLRuntimeEnabled,
            commandSurfaceEnabled,
            productionGateEnabled
        ].allSatisfy { $0 == false }
    }

    public init(
        readModelID: Identifier = Identifier.constant("gh-457-live-account-read-model"),
        issueID: Identifier = Identifier.constant("GH-457"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-455"),
            Identifier.constant("GH-456")
        ],
        signedAccountEvidenceID: Identifier,
        privateStreamEvidenceID: Identifier,
        records: [L4LiveAccountReadModelRecord],
        freshnessStatuses: [L4PrivateStreamFreshnessStatus],
        validationAnchors: [String] = L4LiveAccountReadModelMapping.requiredValidationAnchors,
        dashboardReadModelOnly: Bool = true,
        fixtureSandboxAndRealAccountSeparated: Bool = true,
        rawAccountPayloadExposed: Bool = false,
        brokerStateExposed: Bool = false,
        runtimeObjectExposed: Bool = false,
        adapterRequestExposed: Bool = false,
        schemaExposed: Bool = false,
        realPnLRuntimeEnabled: Bool = false,
        commandSurfaceEnabled: Bool = false,
        productionGateEnabled: Bool = false
    ) throws {
        guard Set(records.map(\.component)) == Set(L4LiveAccountReadModelComponent.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "records.component",
                expected: L4LiveAccountReadModelComponent.allCases.map(\.rawValue).joined(separator: ","),
                actual: records.map(\.component.rawValue).joined(separator: ",")
            )
        }
        guard Set(freshnessStatuses) == Set(L4PrivateStreamFreshnessStatus.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "freshnessStatuses",
                expected: L4PrivateStreamFreshnessStatus.allCases.map(\.rawValue).joined(separator: ","),
                actual: freshnessStatuses.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == L4LiveAccountReadModelMapping.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: L4LiveAccountReadModelMapping.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard dashboardReadModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("dashboardReadModelOnly")
        }
        guard fixtureSandboxAndRealAccountSeparated else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("fixtureSandboxAndRealAccountSeparated")
        }
        for forbiddenFlag in [
            ("rawAccountPayloadExposed", rawAccountPayloadExposed),
            ("brokerStateExposed", brokerStateExposed),
            ("runtimeObjectExposed", runtimeObjectExposed),
            ("adapterRequestExposed", adapterRequestExposed),
            ("schemaExposed", schemaExposed),
            ("realPnLRuntimeEnabled", realPnLRuntimeEnabled),
            ("commandSurfaceEnabled", commandSurfaceEnabled),
            ("productionGateEnabled", productionGateEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.readModelID = readModelID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.signedAccountEvidenceID = signedAccountEvidenceID
        self.privateStreamEvidenceID = privateStreamEvidenceID
        self.records = records
        self.freshnessStatuses = freshnessStatuses
        self.validationAnchors = validationAnchors
        self.dashboardReadModelOnly = dashboardReadModelOnly
        self.fixtureSandboxAndRealAccountSeparated = fixtureSandboxAndRealAccountSeparated
        self.rawAccountPayloadExposed = rawAccountPayloadExposed
        self.brokerStateExposed = brokerStateExposed
        self.runtimeObjectExposed = runtimeObjectExposed
        self.adapterRequestExposed = adapterRequestExposed
        self.schemaExposed = schemaExposed
        self.realPnLRuntimeEnabled = realPnLRuntimeEnabled
        self.commandSurfaceEnabled = commandSurfaceEnabled
        self.productionGateEnabled = productionGateEnabled
    }
}

/// L4LiveAccountReadModelMapping 将 GH-455 / GH-456 evidence 解释为 GH-457 canonical read model。
///
/// Mapper 只做 read-model projection，不读取 Runtime object、Adapter request、schema、raw payload、
/// broker state、real PnL，也不实现 command surface、ExecutionClient adapter、OMS 或 reconciliation。
public struct L4LiveAccountReadModelMapping: Codable, Equatable, Sendable {
    public let mapperID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let forbiddenCapabilities: [L4LiveAccountReadModelForbiddenCapability]
    public let validationAnchors: [String]
    public let dashboardReadModelOnlyBoundaryHeld: Bool
    public let fixtureSandboxAndRealAccountSeparated: Bool
    public let realPnLRuntimeEnabled: Bool

    public init(
        mapperID: Identifier = Identifier.constant("gh-457-live-account-read-model-mapping"),
        issueID: Identifier = Identifier.constant("GH-457"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-455"),
            Identifier.constant("GH-456")
        ],
        forbiddenCapabilities: [L4LiveAccountReadModelForbiddenCapability] =
            L4LiveAccountReadModelForbiddenCapability.allCases,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        dashboardReadModelOnlyBoundaryHeld: Bool = true,
        fixtureSandboxAndRealAccountSeparated: Bool = true,
        realPnLRuntimeEnabled: Bool = false
    ) throws {
        guard forbiddenCapabilities == L4LiveAccountReadModelForbiddenCapability.allCases else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: L4LiveAccountReadModelForbiddenCapability.allCases.map(\.rawValue).joined(separator: ","),
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
        guard dashboardReadModelOnlyBoundaryHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("dashboardReadModelOnlyBoundaryHeld")
        }
        guard fixtureSandboxAndRealAccountSeparated else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("fixtureSandboxAndRealAccountSeparated")
        }
        guard realPnLRuntimeEnabled == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("realPnLRuntimeEnabled")
        }

        self.mapperID = mapperID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.dashboardReadModelOnlyBoundaryHeld = dashboardReadModelOnlyBoundaryHeld
        self.fixtureSandboxAndRealAccountSeparated = fixtureSandboxAndRealAccountSeparated
        self.realPnLRuntimeEnabled = realPnLRuntimeEnabled
    }

    public var mappingContractHeld: Bool {
        issueID.rawValue == "GH-457"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-455", "GH-456"]
            && forbiddenCapabilities == L4LiveAccountReadModelForbiddenCapability.allCases
            && validationAnchors == Self.requiredValidationAnchors
            && dashboardReadModelOnlyBoundaryHeld
            && fixtureSandboxAndRealAccountSeparated
            && realPnLRuntimeEnabled == false
    }

    public func mapReadModel(
        signedAccountEvidence: L4SignedAccountReadOnlyEvidence,
        privateStreamEvidence: L4PrivateStreamAccountSnapshotReadOnlyEvidence
    ) throws -> L4LiveAccountReadModel {
        guard signedAccountEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "signedAccountEvidence",
                expected: "GH-455 canonical signed account read-only evidence",
                actual: "boundary drift"
            )
        }
        guard privateStreamEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "privateStreamEvidence",
                expected: "GH-456 private stream account snapshot read-only evidence",
                actual: "boundary drift"
            )
        }
        guard privateStreamEvidence.signedAccountEvidenceID == signedAccountEvidence.evidenceID else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "privateStreamEvidence.signedAccountEvidenceID",
                expected: signedAccountEvidence.evidenceID.rawValue,
                actual: privateStreamEvidence.signedAccountEvidenceID.rawValue
            )
        }

        return try L4LiveAccountReadModel(
            signedAccountEvidenceID: signedAccountEvidence.evidenceID,
            privateStreamEvidenceID: privateStreamEvidence.evidenceID,
            records: try Self.records(
                signedAccountEvidence: signedAccountEvidence,
                privateStreamEvidence: privateStreamEvidence
            ),
            freshnessStatuses: L4PrivateStreamFreshnessStatus.allCases
        )
    }

    public static func deterministicFixture() throws -> L4LiveAccountReadModelMapping {
        try L4LiveAccountReadModelMapping()
    }

    public static let requiredValidationAnchors: [String] = [
        "GH-457-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING",
        "GH-457-APB-MARGIN-CANONICAL-COMPONENTS",
        "GH-457-FRESHNESS-SOURCE-EVIDENCE-IDENTITY",
        "GH-457-DASHBOARD-READ-MODEL-ONLY-CONSUMPTION",
        "GH-457-FIXTURE-SANDBOX-REAL-ACCOUNT-INTERPRETATION-SEPARATION",
        "GH-457-FORBIDDEN-RAW-PAYLOAD-BROKER-STATE-TESTS",
        "GH-457-NON-AUTHORIZATION",
        "TVM-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING"
    ]

    private static func records(
        signedAccountEvidence: L4SignedAccountReadOnlyEvidence,
        privateStreamEvidence: L4PrivateStreamAccountSnapshotReadOnlyEvidence
    ) throws -> [L4LiveAccountReadModelRecord] {
        let signedRecordsByComponent = Dictionary(uniqueKeysWithValues: signedAccountEvidence.records.map {
            ($0.component, $0)
        })
        return try [
            record(
                component: .account,
                signedComponent: .account,
                valuePrefix: "live account read model",
                signedRecordsByComponent: signedRecordsByComponent,
                privateStreamEvidence: privateStreamEvidence
            ),
            record(
                component: .position,
                signedComponent: .position,
                valuePrefix: "live position read model",
                signedRecordsByComponent: signedRecordsByComponent,
                privateStreamEvidence: privateStreamEvidence
            ),
            record(
                component: .balance,
                signedComponent: .balance,
                valuePrefix: "live balance read model",
                signedRecordsByComponent: signedRecordsByComponent,
                privateStreamEvidence: privateStreamEvidence
            ),
            record(
                component: .margin,
                signedComponent: .margin,
                valuePrefix: "live margin read model",
                signedRecordsByComponent: signedRecordsByComponent,
                privateStreamEvidence: privateStreamEvidence
            )
        ]
    }

    private static func record(
        component: L4LiveAccountReadModelComponent,
        signedComponent: L4SignedAccountReadOnlyEvidenceComponent,
        valuePrefix: String,
        signedRecordsByComponent: [L4SignedAccountReadOnlyEvidenceComponent: L4SignedAccountReadOnlyEvidenceRecord],
        privateStreamEvidence: L4PrivateStreamAccountSnapshotReadOnlyEvidence
    ) throws -> L4LiveAccountReadModelRecord {
        guard let signedRecord = signedRecordsByComponent[signedComponent] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "signedAccountEvidence.records",
                expected: signedComponent.rawValue,
                actual: "missing"
            )
        }
        return try L4LiveAccountReadModelRecord(
            component: component,
            sourceKinds: [
                .signedAccountEvidence,
                .privateStreamEvidence,
                .sandboxFixtureEvidence,
                .liveReadOnlyExplanation
            ],
            interpretationMode: .sandboxFixture,
            freshnessStatus: .fresh,
            canonicalReadModelValue: "\(valuePrefix): \(signedRecord.canonicalValue)",
            evidenceIdentity: privateStreamEvidence.evidenceID,
            sourceIdentity: privateStreamEvidence.sourceIdentity
        )
    }
}
