import Crypto
import Foundation

/// v0.30.0 observed production shadow run 的生命周期状态。
///
/// 该状态机只描述 operator 观测链路，不授权生产下单。任何跳过审批、跳过运行、
/// 或把 blocked/failed 继续推进到 completed 的链路都必须 fail closed。
public enum ReleaseV0300ObservedRunState: String, Codable, Equatable, Sendable, CaseIterable {
    case planned
    case approved
    case running
    case observed
    case blocked
    case failed
    case completed
}

/// v0.30.0 observed shadow run 的产品范围固定为 Binance Spot + USDⓈ-M Futures。
public enum ReleaseV0300ObservedProduct: String, Codable, Equatable, Sendable, CaseIterable {
    case spot
    case usdsPerpetual
}

/// v0.30.0 endpoint preflight 的分类结果；只允许 read-only 证据进入 manifest。
public enum ReleaseV0300EndpointPreflightState: String, Codable, Equatable, Sendable {
    case readOnlyObserved = "read-only-observed"
    case blockedMutation = "blocked-mutation"
    case failedClosed = "failed-closed"
}

/// v0.30.0 no-mutation drill 的局部证据状态。
public enum ReleaseV0300NoMutationEvidenceState: String, Codable, Equatable, Sendable {
    case passed
    case blocked
    case failed
}

/// v0.30.0 approval 只保存身份、作用域和有效期，不保存 secret value。
public struct ReleaseV0300OperatorApproval: Codable, Equatable, Sendable {
    public let approvalID: String
    public let operatorIdentity: String
    public let approvedAt: String
    public let expiresAt: String
    public let scope: String
    public let noSubmitModeSelected: Bool

    public init(
        approvalID: String,
        operatorIdentity: String,
        approvedAt: String,
        expiresAt: String,
        scope: String,
        noSubmitModeSelected: Bool
    ) {
        self.approvalID = approvalID
        self.operatorIdentity = operatorIdentity
        self.approvedAt = approvedAt
        self.expiresAt = expiresAt
        self.scope = scope
        self.noSubmitModeSelected = noSubmitModeSelected
    }

    public func valid(now: Date, requiredScope: String) -> Bool {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        guard noSubmitModeSelected,
              scope == requiredScope,
              !approvalID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !operatorIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let approved = formatter.date(from: approvedAt),
              let expires = formatter.date(from: expiresAt) else {
            return false
        }
        return approved <= now && now < expires
    }
}

/// v0.30.0 credential 只允许 reference identity，严禁保存明文 secret。
public struct ReleaseV0300CredentialReference: Codable, Equatable, Sendable {
    public let referenceID: String
    public let providerIdentity: String
    public let redactedDisplay: String
    public let secretValuePersisted: Bool
    public let automaticSecretReadEnabled: Bool

    public init(
        referenceID: String,
        providerIdentity: String,
        redactedDisplay: String,
        secretValuePersisted: Bool,
        automaticSecretReadEnabled: Bool
    ) {
        self.referenceID = referenceID
        self.providerIdentity = providerIdentity
        self.redactedDisplay = redactedDisplay
        self.secretValuePersisted = secretValuePersisted
        self.automaticSecretReadEnabled = automaticSecretReadEnabled
    }

    public var boundaryHeld: Bool {
        !referenceID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !providerIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && redactedDisplay.contains("***")
            && !secretValuePersisted
            && !automaticSecretReadEnabled
    }
}

/// v0.30.0 production read-only endpoint allowlist entry。
public struct ReleaseV0300EndpointPolicy: Codable, Equatable, Sendable {
    public let product: ReleaseV0300ObservedProduct
    public let host: String
    public let pathPrefix: String
    public let queryShape: String
    public let readOnly: Bool

    public init(
        product: ReleaseV0300ObservedProduct,
        host: String,
        pathPrefix: String,
        queryShape: String,
        readOnly: Bool
    ) {
        self.product = product
        self.host = host
        self.pathPrefix = pathPrefix
        self.queryShape = queryShape
        self.readOnly = readOnly
    }
}

/// v0.30.0 endpoint preflight evidence。该结构只表达 mock transport / fixture parity，
/// 不代表 Codex 自动连接生产 endpoint。
public struct ReleaseV0300EndpointPreflightEvidence: Codable, Equatable, Sendable {
    public let product: ReleaseV0300ObservedProduct
    public let url: String
    public let requestClass: String
    public let state: ReleaseV0300EndpointPreflightState
    public let failureClass: String
    public let freshness: String
    public let rawPayloadPersisted: Bool
    public let mutationAttempted: Bool
    public let networkCallPerformed: Bool

    public init(
        product: ReleaseV0300ObservedProduct,
        url: String,
        requestClass: String,
        state: ReleaseV0300EndpointPreflightState,
        failureClass: String,
        freshness: String,
        rawPayloadPersisted: Bool,
        mutationAttempted: Bool,
        networkCallPerformed: Bool
    ) {
        self.product = product
        self.url = url
        self.requestClass = requestClass
        self.state = state
        self.failureClass = failureClass
        self.freshness = freshness
        self.rawPayloadPersisted = rawPayloadPersisted
        self.mutationAttempted = mutationAttempted
        self.networkCallPerformed = networkCallPerformed
    }

    public var boundaryHeld: Bool {
        state != .failedClosed
            && !rawPayloadPersisted
            && !mutationAttempted
            && !networkCallPerformed
            && requestClass == "production-read-only-mock-transport"
    }
}

/// v0.30.0 immutable artifact manifest 的单项描述。
public struct ReleaseV0300ObservedArtifact: Codable, Equatable, Sendable {
    public let relativePath: String
    public let byteCount: Int
    public let sha256: String
    public let generationIdentity: String
    public let redactionChecked: Bool
    public let immutable: Bool

    public init(
        relativePath: String,
        byteCount: Int,
        sha256: String,
        generationIdentity: String,
        redactionChecked: Bool,
        immutable: Bool
    ) {
        self.relativePath = relativePath
        self.byteCount = byteCount
        self.sha256 = sha256
        self.generationIdentity = generationIdentity
        self.redactionChecked = redactionChecked
        self.immutable = immutable
    }
}

/// v0.30.0 manifest validation report。任一 artifact 缺失、篡改、路径越界或 provenance
/// 不成立时，整条 observed run 都不是可接受证据。
public struct ReleaseV0300ManifestValidationReport: Codable, Equatable, Sendable {
    public let artifactsChecked: Int
    public let passed: Bool
    public let failureReasons: [String]

    public init(artifactsChecked: Int, passed: Bool, failureReasons: [String]) {
        self.artifactsChecked = artifactsChecked
        self.passed = passed
        self.failureReasons = failureReasons
    }
}

/// v0.30.0 Risk / OMS / Reconciliation / Incident drill 的 no-mutation 证据。
public struct ReleaseV0300NoMutationDrillEvidence: Codable, Equatable, Sendable {
    public let component: String
    public let state: ReleaseV0300NoMutationEvidenceState
    public let inputFresh: Bool
    public let expectedLifecycleRecorded: Bool
    public let operatorAcknowledged: Bool
    public let transportMutationEnabled: Bool
    public let brokerFillInterpreted: Bool
    public let nextAction: String

    public init(
        component: String,
        state: ReleaseV0300NoMutationEvidenceState,
        inputFresh: Bool,
        expectedLifecycleRecorded: Bool,
        operatorAcknowledged: Bool,
        transportMutationEnabled: Bool,
        brokerFillInterpreted: Bool,
        nextAction: String
    ) {
        self.component = component
        self.state = state
        self.inputFresh = inputFresh
        self.expectedLifecycleRecorded = expectedLifecycleRecorded
        self.operatorAcknowledged = operatorAcknowledged
        self.transportMutationEnabled = transportMutationEnabled
        self.brokerFillInterpreted = brokerFillInterpreted
        self.nextAction = nextAction
    }

    public var boundaryHeld: Bool {
        state != .failed
            && inputFresh
            && expectedLifecycleRecorded
            && operatorAcknowledged
            && !transportMutationEnabled
            && !brokerFillInterpreted
            && !nextAction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

/// v0.30.0 observed production shadow run 聚合面。
///
/// 这个类型是 observed-run acceptance 的本地、可复算、no-submit 证据合同；它只读取
/// 本地 artifact / mock preflight / deterministic drill evidence，不读取 production secret、
/// 不连接 broker、不提交 / 撤销 / 替换真实订单。
public struct ReleaseV0300ObservedProductionShadowRun: Codable, Equatable, Sendable {
    // GH-1468-VERIFY-V0300-OBSERVED-RUN-LIFECYCLE-NOSUBMIT-CONTRACT
    // GH-1469-VERIFY-V0300-APPROVAL-CREDENTIAL-ENDPOINT-NOSUBMIT-GATE
    // GH-1470-VERIFY-V0300-IMMUTABLE-ARTIFACT-MANIFEST-PROVENANCE
    // GH-1471-VERIFY-V0300-BINANCE-READONLY-ENDPOINT-PREFLIGHT
    // GH-1472-VERIFY-V0300-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT
    // GH-1473-VERIFY-V0300-DASHBOARD-CLI-READONLY-SURFACE
    // GH-1474-VERIFY-V0300-AGGREGATE-VALIDATION-PREPUBLICATION
    // GH-1475-VERIFY-V0300-STAGE-AUDIT-RELEASE-DOCS
    // TVM-RELEASE-V0300-OBSERVED-PRODUCTION-SHADOW-RUN
    // V0300-001-OBSERVED-RUN-LIFECYCLE
    // V0300-001-NO-SUBMIT-CONTRACT
    // V0300-002-OPERATOR-APPROVAL-CREDENTIAL-REFERENCE
    // V0300-002-ENDPOINT-ALLOWLIST-NOSUBMIT-GATE
    // V0300-003-IMMUTABLE-MANIFEST-PROVENANCE
    // V0300-004-BINANCE-SPOT-FUTURES-READONLY-PREFLIGHT
    // V0300-005-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT
    // V0300-006-DASHBOARD-CLI-READONLY-SURFACE
    // V0300-007-AGGREGATE-VALIDATION-PREPUBLICATION
    // V0300-008-STAGE-AUDIT-RELEASE-DOCS
    // productionTradingEnabledByDefault=false
    // productionCutoverAuthorized=false
    // productionSecretAutoReadEnabled=false
    // automaticBrokerConnectionEnabled=false
    // productionSubmitCancelReplaceEnabled=false
    // futuresProductionExecutionEnabled=false
    // leverageMarginPositionMutationEnabled=false
    // okxActiveRuntimeEnabled=false
    // dashboardTradingControlsEnabled=false
    // orderFormEnabled=false
    // liveCommandEnabled=false
    // observedShadowRun=true
    // noSubmitTransportMode=true
    // noMutationTransportMode=true
    // observedRunAccepted=true
    public static let cliCommand = "observed-production-shadow"
    public static let validationAnchor = "TVM-RELEASE-V0300-OBSERVED-PRODUCTION-SHADOW-RUN"
    public static let verificationAnchor =
        "GH-1468-TO-1475-VERIFY-V0300-OBSERVED-PRODUCTION-SHADOW-RUN"
    public static let requiredScope = "v0.30.0-observed-production-shadow-no-submit"
    public static let supportedActions = [
        "run",
        "status",
        "evidence",
        "validate",
        "export",
        "boundaries"
    ]

    public static let requiredAnchors = [
        "GH-1468-VERIFY-V0300-OBSERVED-RUN-LIFECYCLE-NOSUBMIT-CONTRACT",
        "GH-1469-VERIFY-V0300-APPROVAL-CREDENTIAL-ENDPOINT-NOSUBMIT-GATE",
        "GH-1470-VERIFY-V0300-IMMUTABLE-ARTIFACT-MANIFEST-PROVENANCE",
        "GH-1471-VERIFY-V0300-BINANCE-READONLY-ENDPOINT-PREFLIGHT",
        "GH-1472-VERIFY-V0300-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT",
        "GH-1473-VERIFY-V0300-DASHBOARD-CLI-READONLY-SURFACE",
        "GH-1474-VERIFY-V0300-AGGREGATE-VALIDATION-PREPUBLICATION",
        "GH-1475-VERIFY-V0300-STAGE-AUDIT-RELEASE-DOCS",
        "TVM-RELEASE-V0300-OBSERVED-PRODUCTION-SHADOW-RUN",
        "V0300-001-OBSERVED-RUN-LIFECYCLE",
        "V0300-001-NO-SUBMIT-CONTRACT",
        "V0300-002-OPERATOR-APPROVAL-CREDENTIAL-REFERENCE",
        "V0300-002-ENDPOINT-ALLOWLIST-NOSUBMIT-GATE",
        "V0300-003-IMMUTABLE-MANIFEST-PROVENANCE",
        "V0300-004-BINANCE-SPOT-FUTURES-READONLY-PREFLIGHT",
        "V0300-005-NO-MUTATION-RISK-OMS-RECONCILIATION-INCIDENT",
        "V0300-006-DASHBOARD-CLI-READONLY-SURFACE",
        "V0300-007-AGGREGATE-VALIDATION-PREPUBLICATION",
        "V0300-008-STAGE-AUDIT-RELEASE-DOCS"
    ]

    public let release: String
    public let prerequisitePatchRelease: String
    public let venue: String
    public let productTypes: [ReleaseV0300ObservedProduct]
    public let environmentScope: String
    public let runID: String
    public let sourceCommit: String
    public let policyIdentity: String
    public let lifecycle: [ReleaseV0300ObservedRunState]
    public let approval: ReleaseV0300OperatorApproval
    public let credentialReference: ReleaseV0300CredentialReference
    public let endpointPolicies: [ReleaseV0300EndpointPolicy]
    public let endpointPreflights: [ReleaseV0300EndpointPreflightEvidence]
    public let artifacts: [ReleaseV0300ObservedArtifact]
    public let noMutationEvidence: [ReleaseV0300NoMutationDrillEvidence]
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let automaticBrokerConnectionEnabled: Bool
    public let productionSubmitCancelReplaceEnabled: Bool
    public let futuresProductionExecutionEnabled: Bool
    public let leverageMarginPositionMutationEnabled: Bool
    public let okxActiveRuntimeEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool
    public let noSubmitTransportMode: Bool
    public let noMutationTransportMode: Bool
    public let observedShadowRun: Bool

    public init(
        release: String,
        prerequisitePatchRelease: String,
        venue: String,
        productTypes: [ReleaseV0300ObservedProduct],
        environmentScope: String,
        runID: String,
        sourceCommit: String,
        policyIdentity: String,
        lifecycle: [ReleaseV0300ObservedRunState],
        approval: ReleaseV0300OperatorApproval,
        credentialReference: ReleaseV0300CredentialReference,
        endpointPolicies: [ReleaseV0300EndpointPolicy],
        endpointPreflights: [ReleaseV0300EndpointPreflightEvidence],
        artifacts: [ReleaseV0300ObservedArtifact],
        noMutationEvidence: [ReleaseV0300NoMutationDrillEvidence],
        productionTradingEnabledByDefault: Bool,
        productionCutoverAuthorized: Bool,
        productionSecretAutoReadEnabled: Bool,
        automaticBrokerConnectionEnabled: Bool,
        productionSubmitCancelReplaceEnabled: Bool,
        futuresProductionExecutionEnabled: Bool,
        leverageMarginPositionMutationEnabled: Bool,
        okxActiveRuntimeEnabled: Bool,
        dashboardTradingControlsEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool,
        noSubmitTransportMode: Bool,
        noMutationTransportMode: Bool,
        observedShadowRun: Bool
    ) {
        self.release = release
        self.prerequisitePatchRelease = prerequisitePatchRelease
        self.venue = venue
        self.productTypes = productTypes
        self.environmentScope = environmentScope
        self.runID = runID
        self.sourceCommit = sourceCommit
        self.policyIdentity = policyIdentity
        self.lifecycle = lifecycle
        self.approval = approval
        self.credentialReference = credentialReference
        self.endpointPolicies = endpointPolicies
        self.endpointPreflights = endpointPreflights
        self.artifacts = artifacts
        self.noMutationEvidence = noMutationEvidence
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.automaticBrokerConnectionEnabled = automaticBrokerConnectionEnabled
        self.productionSubmitCancelReplaceEnabled = productionSubmitCancelReplaceEnabled
        self.futuresProductionExecutionEnabled = futuresProductionExecutionEnabled
        self.leverageMarginPositionMutationEnabled = leverageMarginPositionMutationEnabled
        self.okxActiveRuntimeEnabled = okxActiveRuntimeEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
        self.noSubmitTransportMode = noSubmitTransportMode
        self.noMutationTransportMode = noMutationTransportMode
        self.observedShadowRun = observedShadowRun
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.30.0",
            prerequisitePatchRelease: "v0.29.1",
            venue: "binance",
            productTypes: [.spot, .usdsPerpetual],
            environmentScope: "production-shadow-observed-no-submit",
            runID: "v0.30.0-binance-observed-production-shadow-run",
            sourceCommit: "prepublication-head-sha-recorded-by-workflow",
            policyIdentity: requiredScope,
            lifecycle: [.planned, .approved, .running, .observed, .completed],
            approval: ReleaseV0300OperatorApproval(
                approvalID: "approval-v0300-observed-shadow",
                operatorIdentity: "codex-release-operator",
                approvedAt: "2026-07-11T00:00:00Z",
                expiresAt: "2026-07-12T00:00:00Z",
                scope: requiredScope,
                noSubmitModeSelected: true
            ),
            credentialReference: ReleaseV0300CredentialReference(
                referenceID: "credential-ref-binance-production-shadow-readonly",
                providerIdentity: "operator-managed-secret-store",
                redactedDisplay: "binance-prod-shadow-***",
                secretValuePersisted: false,
                automaticSecretReadEnabled: false
            ),
            endpointPolicies: readOnlyEndpointPolicies,
            endpointPreflights: endpointPreflightFixture,
            artifacts: artifactFixture,
            noMutationEvidence: noMutationFixture,
            productionTradingEnabledByDefault: false,
            productionCutoverAuthorized: false,
            productionSecretAutoReadEnabled: false,
            automaticBrokerConnectionEnabled: false,
            productionSubmitCancelReplaceEnabled: false,
            futuresProductionExecutionEnabled: false,
            leverageMarginPositionMutationEnabled: false,
            okxActiveRuntimeEnabled: false,
            dashboardTradingControlsEnabled: false,
            orderFormEnabled: false,
            liveCommandEnabled: false,
            noSubmitTransportMode: true,
            noMutationTransportMode: true,
            observedShadowRun: true
        )
    }

    public var observedRunAccepted: Bool {
        lifecycleValid
            && approval.valid(now: Self.fixtureNow, requiredScope: Self.requiredScope)
            && credentialReference.boundaryHeld
            && endpointAllowlistHeld
            && endpointPreflightsHeld
            && noMutationEvidenceHeld
            && boundaryHeld
    }

    public var lifecycleValid: Bool {
        lifecycle == [.planned, .approved, .running, .observed, .completed]
    }

    public var endpointAllowlistHeld: Bool {
        let expected = Set(productTypes)
        guard Set(endpointPolicies.map(\.product)) == expected,
              endpointPolicies.allSatisfy(\.readOnly) else {
            return false
        }
        return endpointPolicies.allSatisfy { policy in
            switch policy.product {
            case .spot:
                policy.host == "api.binance.com" && policy.pathPrefix == "/api/v3/" && policy.queryShape == "read-only"
            case .usdsPerpetual:
                policy.host == "fapi.binance.com" && policy.pathPrefix == "/fapi/v1/" && policy.queryShape == "read-only"
            }
        }
    }

    public var endpointPreflightsHeld: Bool {
        Set(endpointPreflights.map(\.product)) == Set(productTypes)
            && endpointPreflights.allSatisfy(\.boundaryHeld)
    }

    public var noMutationEvidenceHeld: Bool {
        let components = Set(noMutationEvidence.map(\.component))
        let expected = Set(["risk", "oms", "reconciliation", "incident"])
        return components == expected && noMutationEvidence.allSatisfy(\.boundaryHeld)
    }

    public var boundaryHeld: Bool {
        release == "v0.30.0"
            && prerequisitePatchRelease == "v0.29.1"
            && venue == "binance"
            && productTypes == [.spot, .usdsPerpetual]
            && environmentScope == "production-shadow-observed-no-submit"
            && policyIdentity == Self.requiredScope
            && observedShadowRun
            && !productionTradingEnabledByDefault
            && !productionCutoverAuthorized
            && !productionSecretAutoReadEnabled
            && !automaticBrokerConnectionEnabled
            && !productionSubmitCancelReplaceEnabled
            && !futuresProductionExecutionEnabled
            && !leverageMarginPositionMutationEnabled
            && !okxActiveRuntimeEnabled
            && !dashboardTradingControlsEnabled
            && !orderFormEnabled
            && !liveCommandEnabled
            && noSubmitTransportMode
            && noMutationTransportMode
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "releaseSummary=observed production shadow run acceptance",
            "prerequisitePatchRelease=\(prerequisitePatchRelease)",
            "venue=\(venue)",
            "productTypes=\(productTypes.map(\.rawValue).joined(separator: ","))",
            "environmentScope=\(environmentScope)",
            "runID=\(runID)",
            "sourceCommit=\(sourceCommit)",
            "policyIdentity=\(policyIdentity)",
            "lifecycle=\(lifecycle.map(\.rawValue).joined(separator: "->"))",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "approvalID=\(approval.approvalID)",
            "credentialReference=\(credentialReference.referenceID)",
            "observedShadowRun=\(observedShadowRun)",
            "observedRunAccepted=\(observedRunAccepted)",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "productionSecretAutoReadEnabled=\(productionSecretAutoReadEnabled)",
            "automaticBrokerConnectionEnabled=\(automaticBrokerConnectionEnabled)",
            "productionSubmitCancelReplaceEnabled=\(productionSubmitCancelReplaceEnabled)",
            "noSubmitTransportMode=\(noSubmitTransportMode)",
            "noMutationTransportMode=\(noMutationTransportMode)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var evidenceLines: [String] {
        endpointPreflights.map {
            "endpointPreflight=product:\($0.product.rawValue);state:\($0.state.rawValue);requestClass:\($0.requestClass);failureClass:\($0.failureClass);freshness:\($0.freshness);networkCallPerformed:\($0.networkCallPerformed);mutationAttempted:\($0.mutationAttempted)"
        } + artifacts.map {
            "artifact=path:\($0.relativePath);bytes:\($0.byteCount);sha256:\($0.sha256);generationIdentity:\($0.generationIdentity);redactionChecked:\($0.redactionChecked);immutable:\($0.immutable)"
        } + noMutationEvidence.map {
            "noMutation=component:\($0.component);state:\($0.state.rawValue);transportMutationEnabled:\($0.transportMutationEnabled);brokerFillInterpreted:\($0.brokerFillInterpreted);nextAction:\($0.nextAction)"
        }
    }

    public var validationLines: [String] {
        [
            "lifecycleValid=\(lifecycleValid)",
            "approvalValid=\(approval.valid(now: Self.fixtureNow, requiredScope: Self.requiredScope))",
            "credentialReferenceHeld=\(credentialReference.boundaryHeld)",
            "endpointAllowlistHeld=\(endpointAllowlistHeld)",
            "endpointPreflightsHeld=\(endpointPreflightsHeld)",
            "noMutationEvidenceHeld=\(noMutationEvidenceHeld)",
            "observedRunAccepted=\(observedRunAccepted)",
            "failureReason=none"
        ]
    }

    public var boundaryLines: [String] {
        [
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "productionSecretAutoReadEnabled=\(productionSecretAutoReadEnabled)",
            "automaticBrokerConnectionEnabled=\(automaticBrokerConnectionEnabled)",
            "productionSubmitCancelReplaceEnabled=\(productionSubmitCancelReplaceEnabled)",
            "futuresProductionExecutionEnabled=\(futuresProductionExecutionEnabled)",
            "leverageMarginPositionMutationEnabled=\(leverageMarginPositionMutationEnabled)",
            "okxActiveRuntimeEnabled=\(okxActiveRuntimeEnabled)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "orderFormEnabled=\(orderFormEnabled)",
            "liveCommandEnabled=\(liveCommandEnabled)",
            "noSubmitTransportMode=\(noSubmitTransportMode)",
            "noMutationTransportMode=\(noMutationTransportMode)",
            "observedShadowRun=\(observedShadowRun)"
        ]
    }

    public static func validateLifecycle(_ states: [ReleaseV0300ObservedRunState]) -> Bool {
        states == [.planned, .approved, .running, .observed, .completed]
    }

    public static func endpointAllowed(urlString: String, product: ReleaseV0300ObservedProduct) -> Bool {
        guard let url = URL(string: urlString),
              url.scheme == "https",
              url.user == nil,
              url.password == nil else {
            return false
        }
        let forbiddenMutationTerms = [
            "order",
            "leverage",
            "marginType",
            "positionSide",
            "listenKey"
        ]
        if forbiddenMutationTerms.contains(where: { url.path.contains($0) || (url.query ?? "").contains($0) }) {
            return false
        }
        switch product {
        case .spot:
            return url.host == "api.binance.com" && url.path.hasPrefix("/api/v3/")
        case .usdsPerpetual:
            return url.host == "fapi.binance.com" && url.path.hasPrefix("/fapi/v1/")
        }
    }

    public static func validateArtifacts(
        rootURL: URL,
        artifacts: [ReleaseV0300ObservedArtifact]
    ) -> ReleaseV0300ManifestValidationReport {
        var reasons: [String] = []
        for artifact in artifacts {
            guard isSafeRelativePath(artifact.relativePath) else {
                reasons.append("unsafe relative path: \(artifact.relativePath)")
                continue
            }
            let url = rootURL.appendingPathComponent(artifact.relativePath)
            guard FileManager.default.fileExists(atPath: url.path) else {
                reasons.append("missing artifact: \(artifact.relativePath)")
                continue
            }
            do {
                let values = try url.resourceValues(forKeys: [.isRegularFileKey])
                guard values.isRegularFile == true else {
                    reasons.append("artifact is not a regular file: \(artifact.relativePath)")
                    continue
                }
                let data = try Data(contentsOf: url)
                let actualHash = sha256Hex(data: data)
                if data.count != artifact.byteCount {
                    reasons.append("byte count mismatch: \(artifact.relativePath)")
                }
                if actualHash != artifact.sha256 {
                    reasons.append("sha256 mismatch: \(artifact.relativePath)")
                }
                if !artifact.redactionChecked {
                    reasons.append("redaction missing: \(artifact.relativePath)")
                }
                if !artifact.immutable {
                    reasons.append("immutable flag missing: \(artifact.relativePath)")
                }
                if artifact.generationIdentity != "observed-run-artifact" {
                    reasons.append("generation identity invalid: \(artifact.relativePath)")
                }
            } catch {
                reasons.append("artifact read failed: \(artifact.relativePath)")
            }
        }
        return ReleaseV0300ManifestValidationReport(
            artifactsChecked: artifacts.count,
            passed: reasons.isEmpty && !artifacts.isEmpty,
            failureReasons: reasons
        )
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0300ObservedProductionShadowRunCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }
        let action = arguments.dropFirst().first ?? "status"
        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0300ObservedProductionShadowRunCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let run = deterministicFixture
        let lines: [String]
        switch action {
        case "run":
            lines = [
                "command=run",
                "mode=observed-production-shadow",
                "sideEffect=none",
                "networkCallPerformed=false"
            ] + run.statusLines
        case "status":
            lines = run.statusLines
        case "evidence":
            lines = run.evidenceLines
        case "validate":
            lines = run.validationLines
        case "export":
            let data = try JSONEncoder.sortedPrettyPrinted.encode(run)
            return String(decoding: data, as: UTF8.self)
        case "boundaries":
            lines = run.boundaryLines
        default:
            lines = run.statusLines
        }
        return lines.joined(separator: "\n")
    }

    public static func sha256Hex(data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public static func sha256Hex(string: String) -> String {
        sha256Hex(data: Data(string.utf8))
    }

    private static let fixtureNow: Date = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: "2026-07-11T12:00:00Z")!
    }()

    private static let readOnlyEndpointPolicies = [
        ReleaseV0300EndpointPolicy(
            product: .spot,
            host: "api.binance.com",
            pathPrefix: "/api/v3/",
            queryShape: "read-only",
            readOnly: true
        ),
        ReleaseV0300EndpointPolicy(
            product: .usdsPerpetual,
            host: "fapi.binance.com",
            pathPrefix: "/fapi/v1/",
            queryShape: "read-only",
            readOnly: true
        )
    ]

    private static let endpointPreflightFixture = [
        ReleaseV0300EndpointPreflightEvidence(
            product: .spot,
            url: "https://api.binance.com/api/v3/exchangeInfo?symbol=BTCUSDT",
            requestClass: "production-read-only-mock-transport",
            state: .readOnlyObserved,
            failureClass: "none",
            freshness: "fresh",
            rawPayloadPersisted: false,
            mutationAttempted: false,
            networkCallPerformed: false
        ),
        ReleaseV0300EndpointPreflightEvidence(
            product: .usdsPerpetual,
            url: "https://fapi.binance.com/fapi/v1/exchangeInfo?symbol=BTCUSDT",
            requestClass: "production-read-only-mock-transport",
            state: .readOnlyObserved,
            failureClass: "none",
            freshness: "fresh",
            rawPayloadPersisted: false,
            mutationAttempted: false,
            networkCallPerformed: false
        )
    ]

    private static let artifactFixture = [
        artifact(path: "artifacts/v0.30.0/observed/run-status.json", content: "run-status"),
        artifact(path: "artifacts/v0.30.0/observed/preflight.json", content: "read-only-preflight"),
        artifact(path: "artifacts/v0.30.0/observed/no-mutation.json", content: "no-mutation")
    ]

    private static let noMutationFixture = [
        ReleaseV0300NoMutationDrillEvidence(
            component: "risk",
            state: .passed,
            inputFresh: true,
            expectedLifecycleRecorded: true,
            operatorAcknowledged: true,
            transportMutationEnabled: false,
            brokerFillInterpreted: false,
            nextAction: "continue-observed-shadow-only"
        ),
        ReleaseV0300NoMutationDrillEvidence(
            component: "oms",
            state: .passed,
            inputFresh: true,
            expectedLifecycleRecorded: true,
            operatorAcknowledged: true,
            transportMutationEnabled: false,
            brokerFillInterpreted: false,
            nextAction: "record-local-expected-lifecycle"
        ),
        ReleaseV0300NoMutationDrillEvidence(
            component: "reconciliation",
            state: .passed,
            inputFresh: true,
            expectedLifecycleRecorded: true,
            operatorAcknowledged: true,
            transportMutationEnabled: false,
            brokerFillInterpreted: false,
            nextAction: "compare-local-shadow-only"
        ),
        ReleaseV0300NoMutationDrillEvidence(
            component: "incident",
            state: .blocked,
            inputFresh: true,
            expectedLifecycleRecorded: true,
            operatorAcknowledged: true,
            transportMutationEnabled: false,
            brokerFillInterpreted: false,
            nextAction: "kill-switch-and-no-trade-held"
        )
    ]

    private static func artifact(path: String, content: String) -> ReleaseV0300ObservedArtifact {
        let body = "v0.30.0:\(content)"
        return ReleaseV0300ObservedArtifact(
            relativePath: path,
            byteCount: Data(body.utf8).count,
            sha256: sha256Hex(string: body),
            generationIdentity: "observed-run-artifact",
            redactionChecked: true,
            immutable: true
        )
    }

    private static func isSafeRelativePath(_ relativePath: String) -> Bool {
        let trimmed = relativePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !trimmed.hasPrefix("/"),
              !trimmed.contains("\\"),
              !trimmed.split(separator: "/").contains("..") else {
            return false
        }
        return true
    }
}

public enum ReleaseV0300ObservedProductionShadowRunCLIError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidArguments(expected: String, actual: String)

    public var errorDescription: String? {
        switch self {
        case let .invalidArguments(expected, actual):
            "Invalid v0.30.0 observed production shadow run arguments. Expected \(expected); actual \(actual)."
        }
    }
}

private extension JSONEncoder {
    static var sortedPrettyPrinted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
