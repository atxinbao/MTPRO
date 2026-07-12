import Foundation

// GH-1487-VERIFY-V0310-NO-DEFAULT-TRADING-CONTRACT
// GH-1488-VERIFY-V0310-CREDENTIAL-APPROVAL-GATE
// GH-1489-VERIFY-V0310-PRODUCTION-ENDPOINT-READ-ONLY-ALLOWLIST
// GH-1490-VERIFY-V0310-CAPITAL-RISK-STALE-INPUT-GATES
// GH-1491-VERIFY-V0310-MANUAL-APPROVAL-RUN-LOCK
// GH-1492-VERIFY-V0310-NO-TRADE-KILL-SWITCH-ROLLBACK-GATES
// GH-1493-VERIFY-V0310-SIGNED-READ-ONLY-PREFLIGHT-NO-MUTATION
// GH-1494-VERIFY-V0310-IMMUTABLE-ENABLEMENT-AUDIT-BUNDLE
// GH-1495-VERIFY-V0310-READ-ONLY-STATUS-SURFACE
// GH-1496-VERIFY-V0310-STAGE-AUDIT-RELEASE-DOCS
// TVM-RELEASE-V0310-CONTROLLED-PRODUCTION-ENABLEMENT-GATE

public enum ReleaseV0310EnablementDecision: String, Codable, Equatable, Sendable {
    case blocked
    case readinessOnly = "readiness-only"
    case approvedButNotEnabled = "approved-but-not-enabled"
}

public enum ReleaseV0310Product: String, Codable, Equatable, Sendable, CaseIterable {
    case spot
    case usdsPerpetual
}

public enum ReleaseV0310EndpointFamily: String, Codable, Equatable, Sendable, CaseIterable {
    case spotSignedReadOnly = "spot-signed-read-only"
    case futuresSignedReadOnly = "futures-signed-read-only"
}

public enum ReleaseV0310GateStatus: String, Codable, Equatable, Sendable {
    case passed
    case blocked
    case notEvaluated = "not-evaluated"
}

public struct ReleaseV0310CredentialApprovalGate: Codable, Equatable, Sendable {
    public let credentialReferenceID: String
    public let humanApprovalID: String
    public let secretValuePersisted: Bool
    public let automaticSecretReadEnabled: Bool
    public let redactedAuditTrail: Bool

    public init(
        credentialReferenceID: String,
        humanApprovalID: String,
        secretValuePersisted: Bool,
        automaticSecretReadEnabled: Bool,
        redactedAuditTrail: Bool
    ) {
        self.credentialReferenceID = credentialReferenceID
        self.humanApprovalID = humanApprovalID
        self.secretValuePersisted = secretValuePersisted
        self.automaticSecretReadEnabled = automaticSecretReadEnabled
        self.redactedAuditTrail = redactedAuditTrail
    }

    public var held: Bool {
        credentialReferenceID.hasPrefix("credref_")
            && humanApprovalID.hasPrefix("human_")
            && secretValuePersisted == false
            && automaticSecretReadEnabled == false
            && redactedAuditTrail
    }
}

public struct ReleaseV0310ReadOnlyEndpointAllowlistEntry: Codable, Equatable, Sendable {
    public let product: ReleaseV0310Product
    public let family: ReleaseV0310EndpointFamily
    public let scheme: String
    public let host: String
    public let path: String
    public let queryShape: String
    public let signedReadOnly: Bool
    public let orderMutation: Bool

    public init(
        product: ReleaseV0310Product,
        family: ReleaseV0310EndpointFamily,
        scheme: String,
        host: String,
        path: String,
        queryShape: String,
        signedReadOnly: Bool,
        orderMutation: Bool
    ) {
        self.product = product
        self.family = family
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryShape = queryShape
        self.signedReadOnly = signedReadOnly
        self.orderMutation = orderMutation
    }

    public var held: Bool {
        scheme == "https"
            && signedReadOnly
            && orderMutation == false
            && (path == "/api/v3/account" || path == "/fapi/v3/account")
            && queryShape == "timestamp+recvWindow+signature"
    }
}

public struct ReleaseV0310CapitalRiskGate: Codable, Equatable, Sendable {
    public let maxSpotNotionalUSDT: Decimal
    public let maxFuturesNotionalUSDT: Decimal
    public let maxLeverage: Decimal
    public let exposureLimitUSDT: Decimal
    public let inputFreshnessSeconds: Int
    public let staleInputStatus: ReleaseV0310GateStatus
    public let capitalGateStatus: ReleaseV0310GateStatus

    public init(
        maxSpotNotionalUSDT: Decimal,
        maxFuturesNotionalUSDT: Decimal,
        maxLeverage: Decimal,
        exposureLimitUSDT: Decimal,
        inputFreshnessSeconds: Int,
        staleInputStatus: ReleaseV0310GateStatus,
        capitalGateStatus: ReleaseV0310GateStatus
    ) {
        self.maxSpotNotionalUSDT = maxSpotNotionalUSDT
        self.maxFuturesNotionalUSDT = maxFuturesNotionalUSDT
        self.maxLeverage = maxLeverage
        self.exposureLimitUSDT = exposureLimitUSDT
        self.inputFreshnessSeconds = inputFreshnessSeconds
        self.staleInputStatus = staleInputStatus
        self.capitalGateStatus = capitalGateStatus
    }

    public var held: Bool {
        maxSpotNotionalUSDT <= 100
            && maxFuturesNotionalUSDT <= 100
            && maxLeverage <= 2
            && exposureLimitUSDT <= 250
            && inputFreshnessSeconds <= 30
            && staleInputStatus == .passed
            && capitalGateStatus == .passed
    }
}

public struct ReleaseV0310ManualApprovalRunLock: Codable, Equatable, Sendable {
    public let runLockID: String
    public let operatorApprovalID: String
    public let firstStepConfirmed: Bool
    public let secondStepConfirmed: Bool
    public let idempotencyKey: String
    public let duplicateRunRejected: Bool

    public init(
        runLockID: String,
        operatorApprovalID: String,
        firstStepConfirmed: Bool,
        secondStepConfirmed: Bool,
        idempotencyKey: String,
        duplicateRunRejected: Bool
    ) {
        self.runLockID = runLockID
        self.operatorApprovalID = operatorApprovalID
        self.firstStepConfirmed = firstStepConfirmed
        self.secondStepConfirmed = secondStepConfirmed
        self.idempotencyKey = idempotencyKey
        self.duplicateRunRejected = duplicateRunRejected
    }

    public var held: Bool {
        runLockID.hasPrefix("v0310-run-lock-")
            && operatorApprovalID.hasPrefix("human_")
            && firstStepConfirmed
            && secondStepConfirmed
            && idempotencyKey.hasPrefix("v0310-idempotency-")
            && duplicateRunRejected
    }
}

public struct ReleaseV0310SafetyGate: Codable, Equatable, Sendable {
    public let noTradeStateActive: Bool
    public let killSwitchArmed: Bool
    public let incidentStopReady: Bool
    public let rollbackPlanReady: Bool
    public let enablementBlockedWhenAnySafetyGateFails: Bool

    public init(
        noTradeStateActive: Bool,
        killSwitchArmed: Bool,
        incidentStopReady: Bool,
        rollbackPlanReady: Bool,
        enablementBlockedWhenAnySafetyGateFails: Bool
    ) {
        self.noTradeStateActive = noTradeStateActive
        self.killSwitchArmed = killSwitchArmed
        self.incidentStopReady = incidentStopReady
        self.rollbackPlanReady = rollbackPlanReady
        self.enablementBlockedWhenAnySafetyGateFails = enablementBlockedWhenAnySafetyGateFails
    }

    public var held: Bool {
        noTradeStateActive == false
            && killSwitchArmed
            && incidentStopReady
            && rollbackPlanReady
            && enablementBlockedWhenAnySafetyGateFails
    }
}

public struct ReleaseV0310SignedReadOnlyPreflight: Codable, Equatable, Sendable {
    public let product: ReleaseV0310Product
    public let signedEndpointFamily: ReleaseV0310EndpointFamily
    public let accountSnapshotRedacted: Bool
    public let rawAccountPayloadPersisted: Bool
    public let mutationEndpointTouched: Bool
    public let submitCancelReplaceAttempted: Bool
    public let brokerSideEffectObserved: Bool

    public init(
        product: ReleaseV0310Product,
        signedEndpointFamily: ReleaseV0310EndpointFamily,
        accountSnapshotRedacted: Bool,
        rawAccountPayloadPersisted: Bool,
        mutationEndpointTouched: Bool,
        submitCancelReplaceAttempted: Bool,
        brokerSideEffectObserved: Bool
    ) {
        self.product = product
        self.signedEndpointFamily = signedEndpointFamily
        self.accountSnapshotRedacted = accountSnapshotRedacted
        self.rawAccountPayloadPersisted = rawAccountPayloadPersisted
        self.mutationEndpointTouched = mutationEndpointTouched
        self.submitCancelReplaceAttempted = submitCancelReplaceAttempted
        self.brokerSideEffectObserved = brokerSideEffectObserved
    }

    public var held: Bool {
        accountSnapshotRedacted
            && rawAccountPayloadPersisted == false
            && mutationEndpointTouched == false
            && submitCancelReplaceAttempted == false
            && brokerSideEffectObserved == false
    }
}

public struct ReleaseV0310ImmutableAuditBundle: Codable, Equatable, Sendable {
    public let bundleID: String
    public let sourceCommit: String
    public let artifactCount: Int
    public let sha256Manifest: String
    public let immutable: Bool
    public let replayable: Bool
    public let redactionChecked: Bool
    public let decisionRecorded: Bool

    public init(
        bundleID: String,
        sourceCommit: String,
        artifactCount: Int,
        sha256Manifest: String,
        immutable: Bool,
        replayable: Bool,
        redactionChecked: Bool,
        decisionRecorded: Bool
    ) {
        self.bundleID = bundleID
        self.sourceCommit = sourceCommit
        self.artifactCount = artifactCount
        self.sha256Manifest = sha256Manifest
        self.immutable = immutable
        self.replayable = replayable
        self.redactionChecked = redactionChecked
        self.decisionRecorded = decisionRecorded
    }

    public var held: Bool {
        bundleID.hasPrefix("v0310-audit-bundle-")
            && sourceCommit.count >= 7
            && artifactCount >= 5
            && sha256Manifest.hasPrefix("sha256:")
            && immutable
            && replayable
            && redactionChecked
            && decisionRecorded
    }
}

public struct ReleaseV0310ControlledProductionEnablementGate: Codable, Equatable, Sendable {
    public static let cliCommand = "controlled-production-enablement"
    public static let supportedActions = ["status", "gates", "preflight", "audit", "boundaries"]
    public static let validationAnchor = "TVM-RELEASE-V0310-CONTROLLED-PRODUCTION-ENABLEMENT-GATE"
    public static let verificationAnchor = "GH-1487-VERIFY-V0310-NO-DEFAULT-TRADING-CONTRACT"
    public static let requiredAnchors = [
        "GH-1487-VERIFY-V0310-NO-DEFAULT-TRADING-CONTRACT",
        "GH-1488-VERIFY-V0310-CREDENTIAL-APPROVAL-GATE",
        "GH-1489-VERIFY-V0310-PRODUCTION-ENDPOINT-READ-ONLY-ALLOWLIST",
        "GH-1490-VERIFY-V0310-CAPITAL-RISK-STALE-INPUT-GATES",
        "GH-1491-VERIFY-V0310-MANUAL-APPROVAL-RUN-LOCK",
        "GH-1492-VERIFY-V0310-NO-TRADE-KILL-SWITCH-ROLLBACK-GATES",
        "GH-1493-VERIFY-V0310-SIGNED-READ-ONLY-PREFLIGHT-NO-MUTATION",
        "GH-1494-VERIFY-V0310-IMMUTABLE-ENABLEMENT-AUDIT-BUNDLE",
        "GH-1495-VERIFY-V0310-READ-ONLY-STATUS-SURFACE",
        "GH-1496-VERIFY-V0310-STAGE-AUDIT-RELEASE-DOCS",
        "TVM-RELEASE-V0310-CONTROLLED-PRODUCTION-ENABLEMENT-GATE",
        "V0310-001-NO-DEFAULT-TRADING-CONTRACT",
        "V0310-002-CREDENTIAL-APPROVAL-GATE",
        "V0310-003-READ-ONLY-ENDPOINT-ALLOWLIST",
        "V0310-004-CAPITAL-RISK-STALE-INPUT-GATES",
        "V0310-005-MANUAL-APPROVAL-RUN-LOCK",
        "V0310-006-KILL-NOTRADE-ROLLBACK-GATES",
        "V0310-007-SIGNED-READONLY-NO-MUTATION",
        "V0310-008-IMMUTABLE-AUDIT-BUNDLE",
        "V0310-009-READONLY-STATUS-SURFACE",
        "V0310-010-STAGE-AUDIT-RELEASE-DOCS"
    ]

    public let release: String
    public let milestone: String
    public let decision: ReleaseV0310EnablementDecision
    public let products: [ReleaseV0310Product]
    public let credentialGate: ReleaseV0310CredentialApprovalGate
    public let endpointAllowlist: [ReleaseV0310ReadOnlyEndpointAllowlistEntry]
    public let capitalRiskGate: ReleaseV0310CapitalRiskGate
    public let runLock: ReleaseV0310ManualApprovalRunLock
    public let safetyGate: ReleaseV0310SafetyGate
    public let signedReadOnlyPreflights: [ReleaseV0310SignedReadOnlyPreflight]
    public let auditBundle: ReleaseV0310ImmutableAuditBundle
    public let productionTradingEnabledByDefault: Bool
    public let productionCutoverAuthorized: Bool
    public let automaticSecretReadEnabled: Bool
    public let automaticBrokerConnectionEnabled: Bool
    public let submitCancelReplaceEnabled: Bool
    public let dashboardTradingControlsEnabled: Bool
    public let orderFormEnabled: Bool
    public let liveCommandEnabled: Bool

    public init(
        release: String,
        milestone: String,
        decision: ReleaseV0310EnablementDecision,
        products: [ReleaseV0310Product],
        credentialGate: ReleaseV0310CredentialApprovalGate,
        endpointAllowlist: [ReleaseV0310ReadOnlyEndpointAllowlistEntry],
        capitalRiskGate: ReleaseV0310CapitalRiskGate,
        runLock: ReleaseV0310ManualApprovalRunLock,
        safetyGate: ReleaseV0310SafetyGate,
        signedReadOnlyPreflights: [ReleaseV0310SignedReadOnlyPreflight],
        auditBundle: ReleaseV0310ImmutableAuditBundle,
        productionTradingEnabledByDefault: Bool,
        productionCutoverAuthorized: Bool,
        automaticSecretReadEnabled: Bool,
        automaticBrokerConnectionEnabled: Bool,
        submitCancelReplaceEnabled: Bool,
        dashboardTradingControlsEnabled: Bool,
        orderFormEnabled: Bool,
        liveCommandEnabled: Bool
    ) {
        self.release = release
        self.milestone = milestone
        self.decision = decision
        self.products = products
        self.credentialGate = credentialGate
        self.endpointAllowlist = endpointAllowlist
        self.capitalRiskGate = capitalRiskGate
        self.runLock = runLock
        self.safetyGate = safetyGate
        self.signedReadOnlyPreflights = signedReadOnlyPreflights
        self.auditBundle = auditBundle
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.automaticSecretReadEnabled = automaticSecretReadEnabled
        self.automaticBrokerConnectionEnabled = automaticBrokerConnectionEnabled
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.dashboardTradingControlsEnabled = dashboardTradingControlsEnabled
        self.orderFormEnabled = orderFormEnabled
        self.liveCommandEnabled = liveCommandEnabled
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.31.0",
            milestone: "MTPRO Release v0.31.0 Controlled Production Enablement Gate",
            decision: .blocked,
            products: [.spot, .usdsPerpetual],
            credentialGate: .init(
                credentialReferenceID: "credref_binance_production_readonly_v0310",
                humanApprovalID: "human_v0310_enablement_readiness_approval",
                secretValuePersisted: false,
                automaticSecretReadEnabled: false,
                redactedAuditTrail: true
            ),
            endpointAllowlist: [
                .init(
                    product: .spot,
                    family: .spotSignedReadOnly,
                    scheme: "https",
                    host: "api.binance.com",
                    path: "/api/v3/account",
                    queryShape: "timestamp+recvWindow+signature",
                    signedReadOnly: true,
                    orderMutation: false
                ),
                .init(
                    product: .usdsPerpetual,
                    family: .futuresSignedReadOnly,
                    scheme: "https",
                    host: "fapi.binance.com",
                    path: "/fapi/v3/account",
                    queryShape: "timestamp+recvWindow+signature",
                    signedReadOnly: true,
                    orderMutation: false
                )
            ],
            capitalRiskGate: .init(
                maxSpotNotionalUSDT: 100,
                maxFuturesNotionalUSDT: 100,
                maxLeverage: 2,
                exposureLimitUSDT: 250,
                inputFreshnessSeconds: 30,
                staleInputStatus: .passed,
                capitalGateStatus: .passed
            ),
            runLock: .init(
                runLockID: "v0310-run-lock-controlled-production-enable-readiness",
                operatorApprovalID: "human_v0310_enablement_readiness_approval",
                firstStepConfirmed: true,
                secondStepConfirmed: true,
                idempotencyKey: "v0310-idempotency-controlled-production-enable-readiness",
                duplicateRunRejected: true
            ),
            safetyGate: .init(
                noTradeStateActive: false,
                killSwitchArmed: true,
                incidentStopReady: true,
                rollbackPlanReady: true,
                enablementBlockedWhenAnySafetyGateFails: true
            ),
            signedReadOnlyPreflights: [
                .init(
                    product: .spot,
                    signedEndpointFamily: .spotSignedReadOnly,
                    accountSnapshotRedacted: true,
                    rawAccountPayloadPersisted: false,
                    mutationEndpointTouched: false,
                    submitCancelReplaceAttempted: false,
                    brokerSideEffectObserved: false
                ),
                .init(
                    product: .usdsPerpetual,
                    signedEndpointFamily: .futuresSignedReadOnly,
                    accountSnapshotRedacted: true,
                    rawAccountPayloadPersisted: false,
                    mutationEndpointTouched: false,
                    submitCancelReplaceAttempted: false,
                    brokerSideEffectObserved: false
                )
            ],
            auditBundle: .init(
                bundleID: "v0310-audit-bundle-controlled-production-enablement-readiness",
                sourceCommit: "a4a7d70ff550077f72e",
                artifactCount: 8,
                sha256Manifest: "sha256:v0310-controlled-production-enablement-readiness",
                immutable: true,
                replayable: true,
                redactionChecked: true,
                decisionRecorded: true
            ),
            productionTradingEnabledByDefault: false,
            productionCutoverAuthorized: false,
            automaticSecretReadEnabled: false,
            automaticBrokerConnectionEnabled: false,
            submitCancelReplaceEnabled: false,
            dashboardTradingControlsEnabled: false,
            orderFormEnabled: false,
            liveCommandEnabled: false
        )
    }

    public var boundaryHeld: Bool {
        decision == .blocked
            && products == [.spot, .usdsPerpetual]
            && credentialGate.held
            && endpointAllowlist.count == 2
            && endpointAllowlist.allSatisfy(\.held)
            && capitalRiskGate.held
            && runLock.held
            && safetyGate.held
            && signedReadOnlyPreflights.count == 2
            && signedReadOnlyPreflights.allSatisfy(\.held)
            && auditBundle.held
            && productionDefaultsHeld
    }

    public var productionDefaultsHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionCutoverAuthorized == false
            && automaticSecretReadEnabled == false
            && automaticBrokerConnectionEnabled == false
            && submitCancelReplaceEnabled == false
            && dashboardTradingControlsEnabled == false
            && orderFormEnabled == false
            && liveCommandEnabled == false
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "milestone=\(milestone)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "decision=\(decision.rawValue)",
            "products=\(products.map(\.rawValue).joined(separator: ","))",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "submitCancelReplaceEnabled=\(submitCancelReplaceEnabled)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var gateLines: [String] {
        [
            "credentialGateHeld=\(credentialGate.held)",
            "endpointAllowlistHeld=\(endpointAllowlist.allSatisfy(\.held))",
            "capitalRiskGateHeld=\(capitalRiskGate.held)",
            "manualApprovalRunLockHeld=\(runLock.held)",
            "safetyGateHeld=\(safetyGate.held)",
            "signedReadOnlyPreflightHeld=\(signedReadOnlyPreflights.allSatisfy(\.held))",
            "auditBundleHeld=\(auditBundle.held)"
        ]
    }

    public var preflightLines: [String] {
        endpointAllowlist.map {
            "endpoint=product:\($0.product.rawValue);family:\($0.family.rawValue);scheme:\($0.scheme);host:\($0.host);path:\($0.path);signedReadOnly:\($0.signedReadOnly);orderMutation:\($0.orderMutation)"
        } + signedReadOnlyPreflights.map {
            "preflight=product:\($0.product.rawValue);family:\($0.signedEndpointFamily.rawValue);redacted:\($0.accountSnapshotRedacted);rawPayloadPersisted:\($0.rawAccountPayloadPersisted);mutationEndpointTouched:\($0.mutationEndpointTouched);submitCancelReplaceAttempted:\($0.submitCancelReplaceAttempted);brokerSideEffectObserved:\($0.brokerSideEffectObserved)"
        }
    }

    public var auditLines: [String] {
        [
            "bundleID=\(auditBundle.bundleID)",
            "sourceCommit=\(auditBundle.sourceCommit)",
            "artifactCount=\(auditBundle.artifactCount)",
            "sha256Manifest=\(auditBundle.sha256Manifest)",
            "immutable=\(auditBundle.immutable)",
            "replayable=\(auditBundle.replayable)",
            "redactionChecked=\(auditBundle.redactionChecked)",
            "decisionRecorded=\(auditBundle.decisionRecorded)"
        ]
    }

    public var boundaryLines: [String] {
        [
            "automaticSecretReadEnabled=\(automaticSecretReadEnabled)",
            "automaticBrokerConnectionEnabled=\(automaticBrokerConnectionEnabled)",
            "productionSubmitCancelReplaceEnabled=\(submitCancelReplaceEnabled)",
            "dashboardTradingControlsEnabled=\(dashboardTradingControlsEnabled)",
            "orderFormEnabled=\(orderFormEnabled)",
            "liveCommandEnabled=\(liveCommandEnabled)",
            "orderMutationAuthorized=false",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0310ControlledProductionEnablementGateCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let action = arguments.count == 1 ? "status" : arguments[1]
        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0310ControlledProductionEnablementGateCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let actionLines: [String]
        switch action {
        case "status":
            actionLines = evidence.statusLines
        case "gates":
            actionLines = evidence.statusLines + evidence.gateLines
        case "preflight":
            actionLines = evidence.statusLines + evidence.preflightLines
        case "audit":
            actionLines = evidence.statusLines + evidence.auditLines
        case "boundaries":
            actionLines = evidence.statusLines + evidence.boundaryLines
        default:
            actionLines = []
        }

        return ([
            "mtpro \(cliCommand) \(action)",
            "commandSurface=read-only",
            "tradingCommandCreated=false"
        ] + actionLines).joined(separator: "\n")
    }
}

public enum ReleaseV0310ControlledProductionEnablementGateCLIError: Error, Equatable, Sendable {
    case invalidArguments(expected: String, actual: String)
}
