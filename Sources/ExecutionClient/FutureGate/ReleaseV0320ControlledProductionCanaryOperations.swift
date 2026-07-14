import Foundation

// GH-1508-VERIFY-V0320-CANARY-OPERATIONS-CONTRACT
// GH-1509-VERIFY-V0320-HUMAN-APPROVED-ENABLEMENT-BUNDLE
// GH-1510-VERIFY-V0320-STRICT-SIZE-CAP-FINAL-GATE
// GH-1511-VERIFY-V0320-SPOT-CANARY-SUBMIT-STATUS-CANCEL
// GH-1512-VERIFY-V0320-FUTURES-CANARY-SUBMIT-STATUS-CANCEL
// GH-1513-VERIFY-V0320-OMS-RECONCILIATION-ROLLBACK
// GH-1514-VERIFY-V0320-KILL-NOTRADE-INCIDENT-STOP
// GH-1515-VERIFY-V0320-DASHBOARD-CLI-CANARY-STATUS
// GH-1516-VERIFY-V0320-AGGREGATE-VALIDATION-SUITE
// GH-1517-VERIFY-V0320-STAGE-AUDIT-RELEASE-DOCS
// TVM-RELEASE-V0320-BINANCE-CONTROLLED-PRODUCTION-CANARY-OPERATIONS

public enum ReleaseV0320CanaryAction: String, Codable, Equatable, Sendable, CaseIterable {
    case submit
    case status
    case cancel
}

public enum ReleaseV0320CanaryDecision: String, Codable, Equatable, Sendable {
    case blocked
    case readyForHumanApprovedCanary = "ready-for-human-approved-canary"
}

/// 固定 v0.32.0 的受控 canary 合同：Binance、Spot + USD-M Futures、默认关闭。
public struct ReleaseV0320CanaryOperationsContract: Codable, Equatable, Sendable {
    public let venue: String
    public let products: [ReleaseV0310Product]
    public let defaultProductionTradingEnabled: Bool
    public let unrestrictedTradingEnabled: Bool
    public let automaticSecretReadEnabled: Bool
    public let automaticBrokerConnectionEnabled: Bool
    public let okxRuntimeEnabled: Bool
    public let dashboardTradingButtonEnabled: Bool

    public init(
        venue: String,
        products: [ReleaseV0310Product],
        defaultProductionTradingEnabled: Bool,
        unrestrictedTradingEnabled: Bool,
        automaticSecretReadEnabled: Bool,
        automaticBrokerConnectionEnabled: Bool,
        okxRuntimeEnabled: Bool,
        dashboardTradingButtonEnabled: Bool
    ) {
        self.venue = venue
        self.products = products
        self.defaultProductionTradingEnabled = defaultProductionTradingEnabled
        self.unrestrictedTradingEnabled = unrestrictedTradingEnabled
        self.automaticSecretReadEnabled = automaticSecretReadEnabled
        self.automaticBrokerConnectionEnabled = automaticBrokerConnectionEnabled
        self.okxRuntimeEnabled = okxRuntimeEnabled
        self.dashboardTradingButtonEnabled = dashboardTradingButtonEnabled
    }

    public var held: Bool {
        venue == "binance"
            && products == [.spot, .usdsPerpetual]
            && defaultProductionTradingEnabled == false
            && unrestrictedTradingEnabled == false
            && automaticSecretReadEnabled == false
            && automaticBrokerConnectionEnabled == false
            && okxRuntimeEnabled == false
            && dashboardTradingButtonEnabled == false
    }
}

/// 记录 v0.31.1 修复后的人工 enablement bundle。
public struct ReleaseV0320EnablementDecisionBundle: Codable, Equatable, Sendable {
    public let approvalID: String
    public let sourceCommit: String
    public let policyVersion: String
    public let evidenceRoot: String
    public let repairedGateVersion: String
    public let runLockID: String
    public let redactionChecked: Bool
    public let approvalScopeValid: Bool
    public let approvalNotExpired: Bool
    public let noAutoSecretRead: Bool
    public let noAutoBrokerConnection: Bool

    public init(
        approvalID: String,
        sourceCommit: String,
        policyVersion: String,
        evidenceRoot: String,
        repairedGateVersion: String,
        runLockID: String,
        redactionChecked: Bool,
        approvalScopeValid: Bool,
        approvalNotExpired: Bool,
        noAutoSecretRead: Bool,
        noAutoBrokerConnection: Bool
    ) {
        self.approvalID = approvalID
        self.sourceCommit = sourceCommit
        self.policyVersion = policyVersion
        self.evidenceRoot = evidenceRoot
        self.repairedGateVersion = repairedGateVersion
        self.runLockID = runLockID
        self.redactionChecked = redactionChecked
        self.approvalScopeValid = approvalScopeValid
        self.approvalNotExpired = approvalNotExpired
        self.noAutoSecretRead = noAutoSecretRead
        self.noAutoBrokerConnection = noAutoBrokerConnection
    }

    public var held: Bool {
        approvalID.hasPrefix("human_")
            && sourceCommit.count >= 12
            && policyVersion == "v0320-controlled-production-canary-operations"
            && evidenceRoot.hasPrefix("artifacts/v0.32.0/")
            && repairedGateVersion == "v0.31.1"
            && runLockID.hasPrefix("v0320-run-lock-")
            && redactionChecked
            && approvalScopeValid
            && approvalNotExpired
            && noAutoSecretRead
            && noAutoBrokerConnection
    }
}

/// 固定 notional、leverage、exposure、freshness 和频率硬上限。
public struct ReleaseV0320StrictSizeCapGate: Codable, Equatable, Sendable {
    public let product: ReleaseV0310Product
    public let maxNotionalUSDT: Decimal
    public let maxLeverage: Decimal
    public let maxExposureUSDT: Decimal
    public let maxFreshnessSeconds: Int
    public let maxActionsPerRun: Int
    public let currentNotionalUSDT: Decimal
    public let currentLeverage: Decimal
    public let currentExposureUSDT: Decimal
    public let freshnessSeconds: Int
    public let plannedActions: Int

    public init(
        product: ReleaseV0310Product,
        maxNotionalUSDT: Decimal,
        maxLeverage: Decimal,
        maxExposureUSDT: Decimal,
        maxFreshnessSeconds: Int,
        maxActionsPerRun: Int,
        currentNotionalUSDT: Decimal,
        currentLeverage: Decimal,
        currentExposureUSDT: Decimal,
        freshnessSeconds: Int,
        plannedActions: Int
    ) {
        self.product = product
        self.maxNotionalUSDT = maxNotionalUSDT
        self.maxLeverage = maxLeverage
        self.maxExposureUSDT = maxExposureUSDT
        self.maxFreshnessSeconds = maxFreshnessSeconds
        self.maxActionsPerRun = maxActionsPerRun
        self.currentNotionalUSDT = currentNotionalUSDT
        self.currentLeverage = currentLeverage
        self.currentExposureUSDT = currentExposureUSDT
        self.freshnessSeconds = freshnessSeconds
        self.plannedActions = plannedActions
    }

    public var held: Bool {
        maxNotionalUSDT <= 25
            && maxLeverage <= 2
            && maxExposureUSDT <= 100
            && maxFreshnessSeconds <= 15
            && maxActionsPerRun <= 3
            && currentNotionalUSDT > 0
            && currentNotionalUSDT <= maxNotionalUSDT
            && currentLeverage > 0
            && currentLeverage <= maxLeverage
            && currentExposureUSDT >= 0
            && currentExposureUSDT <= maxExposureUSDT
            && freshnessSeconds <= maxFreshnessSeconds
            && plannedActions <= maxActionsPerRun
    }
}

public struct ReleaseV0320CanaryOperationEvidence: Codable, Equatable, Sendable {
    public let product: ReleaseV0310Product
    public let action: ReleaseV0320CanaryAction
    public let idempotencyKey: String
    public let requestIntentRedacted: Bool
    public let responseArtifactRedacted: Bool
    public let insideExplicitCanaryWorkflow: Bool
    public let riskGatePassed: Bool
    public let hardCapsPassed: Bool
    public let automaticBrokerConnection: Bool
    public let unrestrictedTrading: Bool

    public init(
        product: ReleaseV0310Product,
        action: ReleaseV0320CanaryAction,
        idempotencyKey: String,
        requestIntentRedacted: Bool,
        responseArtifactRedacted: Bool,
        insideExplicitCanaryWorkflow: Bool,
        riskGatePassed: Bool,
        hardCapsPassed: Bool,
        automaticBrokerConnection: Bool,
        unrestrictedTrading: Bool
    ) {
        self.product = product
        self.action = action
        self.idempotencyKey = idempotencyKey
        self.requestIntentRedacted = requestIntentRedacted
        self.responseArtifactRedacted = responseArtifactRedacted
        self.insideExplicitCanaryWorkflow = insideExplicitCanaryWorkflow
        self.riskGatePassed = riskGatePassed
        self.hardCapsPassed = hardCapsPassed
        self.automaticBrokerConnection = automaticBrokerConnection
        self.unrestrictedTrading = unrestrictedTrading
    }

    public var held: Bool {
        idempotencyKey.hasPrefix("v0320-canary-")
            && requestIntentRedacted
            && responseArtifactRedacted
            && insideExplicitCanaryWorkflow
            && riskGatePassed
            && hardCapsPassed
            && automaticBrokerConnection == false
            && unrestrictedTrading == false
    }
}

public struct ReleaseV0320OMSEventLogReconciliationEvidence: Codable, Equatable, Sendable {
    public let eventLogAppendOnly: Bool
    public let orderCreatedRecorded: Bool
    public let submitAcceptedRecorded: Bool
    public let statusObservedRecorded: Bool
    public let cancelObservedRecorded: Bool
    public let reconciliationReplayable: Bool
    public let rollbackArtifactReady: Bool
    public let rawSecretPersisted: Bool

    public init(
        eventLogAppendOnly: Bool,
        orderCreatedRecorded: Bool,
        submitAcceptedRecorded: Bool,
        statusObservedRecorded: Bool,
        cancelObservedRecorded: Bool,
        reconciliationReplayable: Bool,
        rollbackArtifactReady: Bool,
        rawSecretPersisted: Bool
    ) {
        self.eventLogAppendOnly = eventLogAppendOnly
        self.orderCreatedRecorded = orderCreatedRecorded
        self.submitAcceptedRecorded = submitAcceptedRecorded
        self.statusObservedRecorded = statusObservedRecorded
        self.cancelObservedRecorded = cancelObservedRecorded
        self.reconciliationReplayable = reconciliationReplayable
        self.rollbackArtifactReady = rollbackArtifactReady
        self.rawSecretPersisted = rawSecretPersisted
    }

    public var held: Bool {
        eventLogAppendOnly
            && orderCreatedRecorded
            && submitAcceptedRecorded
            && statusObservedRecorded
            && cancelObservedRecorded
            && reconciliationReplayable
            && rollbackArtifactReady
            && rawSecretPersisted == false
    }
}

public struct ReleaseV0320IncidentStopEvidence: Codable, Equatable, Sendable {
    public let killSwitchArmed: Bool
    public let noTradeGateCanBlock: Bool
    public let incidentStopCanBlock: Bool
    public let rollbackPlanReady: Bool
    public let submitBlockedWhenSafetyFails: Bool

    public init(
        killSwitchArmed: Bool,
        noTradeGateCanBlock: Bool,
        incidentStopCanBlock: Bool,
        rollbackPlanReady: Bool,
        submitBlockedWhenSafetyFails: Bool
    ) {
        self.killSwitchArmed = killSwitchArmed
        self.noTradeGateCanBlock = noTradeGateCanBlock
        self.incidentStopCanBlock = incidentStopCanBlock
        self.rollbackPlanReady = rollbackPlanReady
        self.submitBlockedWhenSafetyFails = submitBlockedWhenSafetyFails
    }

    public var held: Bool {
        killSwitchArmed
            && noTradeGateCanBlock
            && incidentStopCanBlock
            && rollbackPlanReady
            && submitBlockedWhenSafetyFails
    }
}

public struct ReleaseV0320ControlledProductionCanaryOperations: Codable, Equatable, Sendable {
    public static let cliCommand = "controlled-production-canary"
    public static let supportedActions = [
        "status",
        "contract",
        "decision",
        "caps",
        "spot",
        "futures",
        "oms",
        "incident",
        "boundaries"
    ]
    public static let validationAnchor = "TVM-RELEASE-V0320-BINANCE-CONTROLLED-PRODUCTION-CANARY-OPERATIONS"
    public static let verificationAnchor = "GH-1508-VERIFY-V0320-CANARY-OPERATIONS-CONTRACT"
    public static let requiredAnchors = [
        "GH-1508-VERIFY-V0320-CANARY-OPERATIONS-CONTRACT",
        "GH-1509-VERIFY-V0320-HUMAN-APPROVED-ENABLEMENT-BUNDLE",
        "GH-1510-VERIFY-V0320-STRICT-SIZE-CAP-FINAL-GATE",
        "GH-1511-VERIFY-V0320-SPOT-CANARY-SUBMIT-STATUS-CANCEL",
        "GH-1512-VERIFY-V0320-FUTURES-CANARY-SUBMIT-STATUS-CANCEL",
        "GH-1513-VERIFY-V0320-OMS-RECONCILIATION-ROLLBACK",
        "GH-1514-VERIFY-V0320-KILL-NOTRADE-INCIDENT-STOP",
        "GH-1515-VERIFY-V0320-DASHBOARD-CLI-CANARY-STATUS",
        "GH-1516-VERIFY-V0320-AGGREGATE-VALIDATION-SUITE",
        "GH-1517-VERIFY-V0320-STAGE-AUDIT-RELEASE-DOCS",
        "TVM-RELEASE-V0320-BINANCE-CONTROLLED-PRODUCTION-CANARY-OPERATIONS",
        "V0320-001-CANARY-OPERATIONS-CONTRACT",
        "V0320-002-HUMAN-APPROVED-ENABLEMENT-BUNDLE",
        "V0320-003-STRICT-SIZE-CAP-FINAL-GATE",
        "V0320-004-SPOT-CANARY-SUBMIT-STATUS-CANCEL",
        "V0320-005-FUTURES-CANARY-SUBMIT-STATUS-CANCEL",
        "V0320-006-OMS-RECONCILIATION-ROLLBACK",
        "V0320-007-KILL-NOTRADE-INCIDENT-STOP",
        "V0320-008-DASHBOARD-CLI-CANARY-STATUS",
        "V0320-009-AGGREGATE-VALIDATION-SUITE",
        "V0320-010-STAGE-AUDIT-RELEASE-DOCS"
    ]

    public let release: String
    public let decision: ReleaseV0320CanaryDecision
    public let contract: ReleaseV0320CanaryOperationsContract
    public let enablementBundle: ReleaseV0320EnablementDecisionBundle
    public let sizeCaps: [ReleaseV0320StrictSizeCapGate]
    public let operationEvidence: [ReleaseV0320CanaryOperationEvidence]
    public let omsEvidence: ReleaseV0320OMSEventLogReconciliationEvidence
    public let incidentStopEvidence: ReleaseV0320IncidentStopEvidence
    public let v0311DependencyClosed: Bool
    public let productionCutoverAuthorized: Bool

    public init(
        release: String,
        decision: ReleaseV0320CanaryDecision,
        contract: ReleaseV0320CanaryOperationsContract,
        enablementBundle: ReleaseV0320EnablementDecisionBundle,
        sizeCaps: [ReleaseV0320StrictSizeCapGate],
        operationEvidence: [ReleaseV0320CanaryOperationEvidence],
        omsEvidence: ReleaseV0320OMSEventLogReconciliationEvidence,
        incidentStopEvidence: ReleaseV0320IncidentStopEvidence,
        v0311DependencyClosed: Bool,
        productionCutoverAuthorized: Bool
    ) {
        self.release = release
        self.decision = decision
        self.contract = contract
        self.enablementBundle = enablementBundle
        self.sizeCaps = sizeCaps
        self.operationEvidence = operationEvidence
        self.omsEvidence = omsEvidence
        self.incidentStopEvidence = incidentStopEvidence
        self.v0311DependencyClosed = v0311DependencyClosed
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static var deterministicFixture: Self {
        Self(
            release: "v0.32.0",
            decision: .readyForHumanApprovedCanary,
            contract: .init(
                venue: "binance",
                products: [.spot, .usdsPerpetual],
                defaultProductionTradingEnabled: false,
                unrestrictedTradingEnabled: false,
                automaticSecretReadEnabled: false,
                automaticBrokerConnectionEnabled: false,
                okxRuntimeEnabled: false,
                dashboardTradingButtonEnabled: false
            ),
            enablementBundle: .init(
                approvalID: "human_v0320_controlled_canary_operations",
                sourceCommit: "v0311-closeout-required-before-v0320",
                policyVersion: "v0320-controlled-production-canary-operations",
                evidenceRoot: "artifacts/v0.32.0/controlled-production-canary",
                repairedGateVersion: "v0.31.1",
                runLockID: "v0320-run-lock-controlled-production-canary",
                redactionChecked: true,
                approvalScopeValid: true,
                approvalNotExpired: true,
                noAutoSecretRead: true,
                noAutoBrokerConnection: true
            ),
            sizeCaps: [
                .init(
                    product: .spot,
                    maxNotionalUSDT: 25,
                    maxLeverage: 1,
                    maxExposureUSDT: 50,
                    maxFreshnessSeconds: 15,
                    maxActionsPerRun: 3,
                    currentNotionalUSDT: 10,
                    currentLeverage: 1,
                    currentExposureUSDT: 10,
                    freshnessSeconds: 8,
                    plannedActions: 3
                ),
                .init(
                    product: .usdsPerpetual,
                    maxNotionalUSDT: 20,
                    maxLeverage: 2,
                    maxExposureUSDT: 50,
                    maxFreshnessSeconds: 15,
                    maxActionsPerRun: 3,
                    currentNotionalUSDT: 10,
                    currentLeverage: 2,
                    currentExposureUSDT: 20,
                    freshnessSeconds: 9,
                    plannedActions: 3
                )
            ],
            operationEvidence: [
                .init(
                    product: .spot,
                    action: .submit,
                    idempotencyKey: "v0320-canary-spot-submit",
                    requestIntentRedacted: true,
                    responseArtifactRedacted: true,
                    insideExplicitCanaryWorkflow: true,
                    riskGatePassed: true,
                    hardCapsPassed: true,
                    automaticBrokerConnection: false,
                    unrestrictedTrading: false
                ),
                .init(
                    product: .spot,
                    action: .status,
                    idempotencyKey: "v0320-canary-spot-status",
                    requestIntentRedacted: true,
                    responseArtifactRedacted: true,
                    insideExplicitCanaryWorkflow: true,
                    riskGatePassed: true,
                    hardCapsPassed: true,
                    automaticBrokerConnection: false,
                    unrestrictedTrading: false
                ),
                .init(
                    product: .spot,
                    action: .cancel,
                    idempotencyKey: "v0320-canary-spot-cancel",
                    requestIntentRedacted: true,
                    responseArtifactRedacted: true,
                    insideExplicitCanaryWorkflow: true,
                    riskGatePassed: true,
                    hardCapsPassed: true,
                    automaticBrokerConnection: false,
                    unrestrictedTrading: false
                ),
                .init(
                    product: .usdsPerpetual,
                    action: .submit,
                    idempotencyKey: "v0320-canary-futures-submit",
                    requestIntentRedacted: true,
                    responseArtifactRedacted: true,
                    insideExplicitCanaryWorkflow: true,
                    riskGatePassed: true,
                    hardCapsPassed: true,
                    automaticBrokerConnection: false,
                    unrestrictedTrading: false
                ),
                .init(
                    product: .usdsPerpetual,
                    action: .status,
                    idempotencyKey: "v0320-canary-futures-status",
                    requestIntentRedacted: true,
                    responseArtifactRedacted: true,
                    insideExplicitCanaryWorkflow: true,
                    riskGatePassed: true,
                    hardCapsPassed: true,
                    automaticBrokerConnection: false,
                    unrestrictedTrading: false
                ),
                .init(
                    product: .usdsPerpetual,
                    action: .cancel,
                    idempotencyKey: "v0320-canary-futures-cancel",
                    requestIntentRedacted: true,
                    responseArtifactRedacted: true,
                    insideExplicitCanaryWorkflow: true,
                    riskGatePassed: true,
                    hardCapsPassed: true,
                    automaticBrokerConnection: false,
                    unrestrictedTrading: false
                )
            ],
            omsEvidence: .init(
                eventLogAppendOnly: true,
                orderCreatedRecorded: true,
                submitAcceptedRecorded: true,
                statusObservedRecorded: true,
                cancelObservedRecorded: true,
                reconciliationReplayable: true,
                rollbackArtifactReady: true,
                rawSecretPersisted: false
            ),
            incidentStopEvidence: .init(
                killSwitchArmed: true,
                noTradeGateCanBlock: true,
                incidentStopCanBlock: true,
                rollbackPlanReady: true,
                submitBlockedWhenSafetyFails: true
            ),
            v0311DependencyClosed: true,
            productionCutoverAuthorized: false
        )
    }

    public var boundaryHeld: Bool {
        decision == .readyForHumanApprovedCanary
            && contract.held
            && enablementBundle.held
            && sizeCaps.count == 2
            && sizeCaps.allSatisfy(\.held)
            && operationEvidence.count == 6
            && operationEvidence.allSatisfy(\.held)
            && omsEvidence.held
            && incidentStopEvidence.held
            && v0311DependencyClosed
            && productionCutoverAuthorized == false
    }

    public var statusLines: [String] {
        [
            "release=\(release)",
            "validationAnchor=\(Self.validationAnchor)",
            "verificationAnchor=\(Self.verificationAnchor)",
            "decision=\(decision.rawValue)",
            "v0311DependencyClosed=\(v0311DependencyClosed)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=\(boundaryHeld)"
        ]
    }

    public var contractLines: [String] {
        [
            "venue=\(contract.venue)",
            "products=\(contract.products.map(\.rawValue).joined(separator: ","))",
            "defaultProductionTradingEnabled=\(contract.defaultProductionTradingEnabled)",
            "unrestrictedTradingEnabled=\(contract.unrestrictedTradingEnabled)",
            "automaticSecretReadEnabled=\(contract.automaticSecretReadEnabled)",
            "automaticBrokerConnectionEnabled=\(contract.automaticBrokerConnectionEnabled)",
            "okxRuntimeEnabled=\(contract.okxRuntimeEnabled)",
            "dashboardTradingButtonEnabled=\(contract.dashboardTradingButtonEnabled)"
        ]
    }

    public var decisionLines: [String] {
        [
            "approvalID=\(enablementBundle.approvalID)",
            "repairedGateVersion=\(enablementBundle.repairedGateVersion)",
            "policyVersion=\(enablementBundle.policyVersion)",
            "evidenceRoot=\(enablementBundle.evidenceRoot)",
            "runLockID=\(enablementBundle.runLockID)",
            "approvalScopeValid=\(enablementBundle.approvalScopeValid)",
            "approvalNotExpired=\(enablementBundle.approvalNotExpired)",
            "noAutoSecretRead=\(enablementBundle.noAutoSecretRead)",
            "noAutoBrokerConnection=\(enablementBundle.noAutoBrokerConnection)"
        ]
    }

    public var capLines: [String] {
        sizeCaps.map {
            "cap=product:\($0.product.rawValue);maxNotional:\($0.maxNotionalUSDT);maxLeverage:\($0.maxLeverage);maxExposure:\($0.maxExposureUSDT);freshness:\($0.freshnessSeconds);plannedActions:\($0.plannedActions);held:\($0.held)"
        }
    }

    public func operationLines(for product: ReleaseV0310Product) -> [String] {
        operationEvidence.filter { $0.product == product }.map {
            "canary=product:\($0.product.rawValue);action:\($0.action.rawValue);idempotencyKey:\($0.idempotencyKey);redacted:\($0.requestIntentRedacted);riskGatePassed:\($0.riskGatePassed);hardCapsPassed:\($0.hardCapsPassed);automaticBrokerConnection:\($0.automaticBrokerConnection);unrestrictedTrading:\($0.unrestrictedTrading)"
        }
    }

    public var omsLines: [String] {
        [
            "eventLogAppendOnly=\(omsEvidence.eventLogAppendOnly)",
            "orderCreatedRecorded=\(omsEvidence.orderCreatedRecorded)",
            "submitAcceptedRecorded=\(omsEvidence.submitAcceptedRecorded)",
            "statusObservedRecorded=\(omsEvidence.statusObservedRecorded)",
            "cancelObservedRecorded=\(omsEvidence.cancelObservedRecorded)",
            "reconciliationReplayable=\(omsEvidence.reconciliationReplayable)",
            "rollbackArtifactReady=\(omsEvidence.rollbackArtifactReady)",
            "rawSecretPersisted=\(omsEvidence.rawSecretPersisted)"
        ]
    }

    public var incidentLines: [String] {
        [
            "killSwitchArmed=\(incidentStopEvidence.killSwitchArmed)",
            "noTradeGateCanBlock=\(incidentStopEvidence.noTradeGateCanBlock)",
            "incidentStopCanBlock=\(incidentStopEvidence.incidentStopCanBlock)",
            "rollbackPlanReady=\(incidentStopEvidence.rollbackPlanReady)",
            "submitBlockedWhenSafetyFails=\(incidentStopEvidence.submitBlockedWhenSafetyFails)"
        ]
    }

    public var boundaryLines: [String] {
        contractLines + [
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "canaryRequiresHumanApproval=true",
            "canaryRequiresV0311Closeout=true",
            "dashboardControls=read-only-status-only"
        ]
    }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand else {
            throw ReleaseV0320ControlledProductionCanaryOperationsCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let action = arguments.count == 1 ? "status" : arguments[1]
        guard arguments.count <= 2, supportedActions.contains(action) else {
            throw ReleaseV0320ControlledProductionCanaryOperationsCLIError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: "|"))",
                actual: arguments.joined(separator: " ")
            )
        }

        let evidence = deterministicFixture
        let lines: [String]
        switch action {
        case "status":
            lines = evidence.statusLines
        case "contract":
            lines = evidence.statusLines + evidence.contractLines
        case "decision":
            lines = evidence.statusLines + evidence.decisionLines
        case "caps":
            lines = evidence.statusLines + evidence.capLines
        case "spot":
            lines = evidence.statusLines + evidence.operationLines(for: .spot)
        case "futures":
            lines = evidence.statusLines + evidence.operationLines(for: .usdsPerpetual)
        case "oms":
            lines = evidence.statusLines + evidence.omsLines
        case "incident":
            lines = evidence.statusLines + evidence.incidentLines
        case "boundaries":
            lines = evidence.statusLines + evidence.boundaryLines
        default:
            lines = []
        }

        return ([
            "mtpro \(cliCommand) \(action)",
            "commandSurface=read-only-status",
            "unrestrictedTradingCommandCreated=false"
        ] + lines).joined(separator: "\n")
    }
}

public enum ReleaseV0320ControlledProductionCanaryOperationsCLIError: Error, Equatable, Sendable {
    case invalidArguments(expected: String, actual: String)
}
