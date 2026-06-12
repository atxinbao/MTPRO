import DomainModel
import ExecutionClient
import Foundation
import RiskEngine

/// ProductionBrokerShadowDryRunProofMode 固定 GH-648 允许表达的 production cutover proof mode。
///
/// 这些 mode 只用于生产切换前的 shadow / dry-run proof，不会连接 broker、读取 secret 或发送真实订单。
public enum ProductionBrokerShadowDryRunProofMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case dryRun = "dry-run"
    case shadow = "shadow"
    case productionBlocked = "production-blocked"
}

/// ProductionBrokerShadowDryRunRequirement 固定 GH-648 的 cutover proof 要求。
public enum ProductionBrokerShadowDryRunRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamAuditTrailGateRequired = "upstream audit trail gate required"
    case productionLikeRequestMappingEvidenceRequired = "production-like request mapping evidence required"
    case noRealOrderSent = "no real order sent"
    case dryRunAndShadowModeMarked = "dry-run and shadow mode marked"
    case submitCancelReplacePayloadAuditRequired = "submit / cancel / replace payload audit required"
    case productionOrderPathBlockedByDefault = "production order path blocked by default"
    case rawBrokerPayloadNotExposedToDashboard = "raw broker payload not exposed to Dashboard"
}

/// ProductionBrokerShadowDryRunForbiddenCapability 枚举 GH-648 必须拒绝的 bypass。
public enum ProductionBrokerShadowDryRunForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case realOrderSent = "real order sent"
    case productionOrderPathEnabledByDefault = "production order path enabled by default"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretValueRead = "production secret value read"
    case realBrokerConnection = "real broker connection"
    case rawBrokerPayloadExposedToDashboard = "raw broker payload exposed to Dashboard"
    case commandRiskExecutionOMSAuditBypass = "CommandGateway / RiskEngine / ExecutionEngine / OMS / audit bypass"
    case dryRunModeMissing = "dry-run mode missing"
    case shadowModeMissing = "shadow mode missing"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ProductionBrokerShadowDryRunPayloadEvidence 是 GH-648 的 submit / cancel / replace payload mapping evidence。
///
/// Evidence 只证明 production-like payload shape 可以被审计；它不保存 raw broker payload 到 Dashboard，
/// 不调用 broker，不提交 / 撤销 / 替换真实订单。
public struct ProductionBrokerShadowDryRunPayloadEvidence: Codable, Equatable, Sendable {
    public let payloadID: Identifier
    public let commandKind: L4LiveRiskPreTradeCommandKind
    public let mode: ProductionBrokerShadowDryRunProofMode
    public let productType: String
    public let productionLikeRequestMappingPresent: Bool
    public let modeExplicitlyMarked: Bool
    public let payloadConstructionAuditable: Bool
    public let upstreamAuditTrailLinked: Bool
    public let productionOrderPathBlocked: Bool
    public let sendsRealOrder: Bool
    public let connectsBroker: Bool
    public let readsSecretValue: Bool
    public let exposesRawBrokerPayloadToDashboard: Bool

    public var payloadBoundaryHeld: Bool {
        productType.isEmpty == false
            && productionLikeRequestMappingPresent
            && modeExplicitlyMarked
            && payloadConstructionAuditable
            && upstreamAuditTrailLinked
            && productionOrderPathBlocked
            && sendsRealOrder == false
            && connectsBroker == false
            && readsSecretValue == false
            && exposesRawBrokerPayloadToDashboard == false
    }

    public init(
        payloadID: Identifier,
        commandKind: L4LiveRiskPreTradeCommandKind,
        mode: ProductionBrokerShadowDryRunProofMode,
        productType: String,
        productionLikeRequestMappingPresent: Bool = true,
        modeExplicitlyMarked: Bool = true,
        payloadConstructionAuditable: Bool = true,
        upstreamAuditTrailLinked: Bool = true,
        productionOrderPathBlocked: Bool = true,
        sendsRealOrder: Bool = false,
        connectsBroker: Bool = false,
        readsSecretValue: Bool = false,
        exposesRawBrokerPayloadToDashboard: Bool = false
    ) throws {
        guard productType.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "productType",
                expected: "non-empty GH-648 product type",
                actual: "empty"
            )
        }
        for requiredFlag in [
            ("productionLikeRequestMappingPresent", productionLikeRequestMappingPresent),
            ("modeExplicitlyMarked", modeExplicitlyMarked),
            ("payloadConstructionAuditable", payloadConstructionAuditable),
            ("upstreamAuditTrailLinked", upstreamAuditTrailLinked),
            ("productionOrderPathBlocked", productionOrderPathBlocked)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: requiredFlag.0, expected: "true", actual: "false")
        }
        for forbiddenFlag in [
            ("sendsRealOrder", sendsRealOrder),
            ("connectsBroker", connectsBroker),
            ("readsSecretValue", readsSecretValue),
            ("exposesRawBrokerPayloadToDashboard", exposesRawBrokerPayloadToDashboard)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.payloadID = payloadID
        self.commandKind = commandKind
        self.mode = mode
        self.productType = productType
        self.productionLikeRequestMappingPresent = productionLikeRequestMappingPresent
        self.modeExplicitlyMarked = modeExplicitlyMarked
        self.payloadConstructionAuditable = payloadConstructionAuditable
        self.upstreamAuditTrailLinked = upstreamAuditTrailLinked
        self.productionOrderPathBlocked = productionOrderPathBlocked
        self.sendsRealOrder = sendsRealOrder
        self.connectsBroker = connectsBroker
        self.readsSecretValue = readsSecretValue
        self.exposesRawBrokerPayloadToDashboard = exposesRawBrokerPayloadToDashboard
    }
}

/// ProductionBrokerShadowDryRunProof 是 GH-648 的 broker adapter shadow / dry-run production cutover proof。
///
/// 合同绑定 GH-647 audit trail，并固定 submit / cancel / replace 的 production-like request mapping
/// evidence。它不发送真实订单、不连接 broker、不暴露 raw broker payload 给 Dashboard。
public struct ProductionBrokerShadowDryRunProof: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamAuditTrailGateHeld: Bool
    public let requirements: [ProductionBrokerShadowDryRunRequirement]
    public let forbiddenCapabilities: [ProductionBrokerShadowDryRunForbiddenCapability]
    public let payloadEvidence: [ProductionBrokerShadowDryRunPayloadEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionLikeRequestMappingRequired: Bool
    public let dryRunAndShadowModeMarked: Bool
    public let submitCancelReplacePayloadAuditRequired: Bool
    public let productionOrderPathBlockedByDefault: Bool
    public let rawBrokerPayloadNotExposedToDashboard: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let realBrokerConnectionEnabled: Bool
    public let realOrderSubmissionEnabled: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-648"
            && upstreamIssueID.rawValue == "GH-647"
            && downstreamIssueID.rawValue == "GH-649"
            && canonicalQueueRange == "GH-643..GH-649"
            && projectName == ProductionCutoverRuntimeHardeningContract.requiredProjectName
            && upstreamAuditTrailGateHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && payloadEvidence == Self.requiredPayloadEvidence
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionLikeRequestMappingRequired
            && dryRunAndShadowModeMarked
            && submitCancelReplacePayloadAuditRequired
            && productionOrderPathBlockedByDefault
            && rawBrokerPayloadNotExposedToDashboard
            && productionDefaultsClosed
            && startsNextMilestone == false
    }

    public var payloadCoverageHeld: Bool {
        Set(payloadEvidence.map(\.commandKind)) == Set(L4LiveRiskPreTradeCommandKind.allCases)
            && Set(payloadEvidence.map(\.mode)) == Set(ProductionBrokerShadowDryRunProofMode.allCases)
            && payloadEvidence.allSatisfy(\.payloadBoundaryHeld)
    }

    public var productionDefaultsClosed: Bool {
        productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && realBrokerConnectionEnabled == false
            && realOrderSubmissionEnabled == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-648-production-broker-shadow-dry-run-proof"),
        issueID: Identifier = Identifier.constant("GH-648"),
        upstreamIssueID: Identifier = Identifier.constant("GH-647"),
        downstreamIssueID: Identifier = Identifier.constant("GH-649"),
        canonicalQueueRange: String = "GH-643..GH-649",
        projectName: String = ProductionCutoverRuntimeHardeningContract.requiredProjectName,
        upstreamAuditTrailGateHeld: Bool = true,
        requirements: [ProductionBrokerShadowDryRunRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ProductionBrokerShadowDryRunForbiddenCapability] = Self.requiredForbiddenCapabilities,
        payloadEvidence: [ProductionBrokerShadowDryRunPayloadEvidence] = Self.requiredPayloadEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionLikeRequestMappingRequired: Bool = true,
        dryRunAndShadowModeMarked: Bool = true,
        submitCancelReplacePayloadAuditRequired: Bool = true,
        productionOrderPathBlockedByDefault: Bool = true,
        rawBrokerPayloadNotExposedToDashboard: Bool = true,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        realBrokerConnectionEnabled: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            payloadEvidence: payloadEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamAuditTrailGateHeld: upstreamAuditTrailGateHeld,
            productionLikeRequestMappingRequired: productionLikeRequestMappingRequired,
            dryRunAndShadowModeMarked: dryRunAndShadowModeMarked,
            submitCancelReplacePayloadAuditRequired: submitCancelReplacePayloadAuditRequired,
            productionOrderPathBlockedByDefault: productionOrderPathBlockedByDefault,
            rawBrokerPayloadNotExposedToDashboard: rawBrokerPayloadNotExposedToDashboard
        )
        try Self.validateForbiddenFlags(
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            realBrokerConnectionEnabled: realBrokerConnectionEnabled,
            realOrderSubmissionEnabled: realOrderSubmissionEnabled,
            startsNextMilestone: startsNextMilestone
        )

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamAuditTrailGateHeld = upstreamAuditTrailGateHeld
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.payloadEvidence = payloadEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionLikeRequestMappingRequired = productionLikeRequestMappingRequired
        self.dryRunAndShadowModeMarked = dryRunAndShadowModeMarked
        self.submitCancelReplacePayloadAuditRequired = submitCancelReplacePayloadAuditRequired
        self.productionOrderPathBlockedByDefault = productionOrderPathBlockedByDefault
        self.rawBrokerPayloadNotExposedToDashboard = rawBrokerPayloadNotExposedToDashboard
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.realBrokerConnectionEnabled = realBrokerConnectionEnabled
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ProductionBrokerShadowDryRunProof {
        let upstream = try ProductionAuditTrailGate.deterministicFixture()
        return try ProductionBrokerShadowDryRunProof(upstreamAuditTrailGateHeld: upstream.contractHeld)
    }

    public static let requiredRequirements = ProductionBrokerShadowDryRunRequirement.allCases
    public static let requiredForbiddenCapabilities = ProductionBrokerShadowDryRunForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "PCHR-06-BROKER-SHADOW-DRY-RUN-PRODUCTION-CUTOVER-PROOF",
        "PCHR-06-PRODUCTION-LIKE-REQUEST-MAPPING-EVIDENCE",
        "PCHR-06-NO-REAL-ORDER-SENT",
        "PCHR-06-DRY-RUN-SHADOW-MODE-MARKED",
        "PCHR-06-SUBMIT-CANCEL-REPLACE-PAYLOAD-AUDIT",
        "PCHR-06-PRODUCTION-ORDER-PATH-BLOCKED-BY-DEFAULT",
        "PCHR-06-NO-RAW-BROKER-PAYLOAD-DASHBOARD",
        "TVM-PCHR-BROKER-SHADOW-DRY-RUN-PROOF"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH648BrokerShadowDryRunProofKeepsProductionOrdersBlocked",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredPayloadEvidence: [ProductionBrokerShadowDryRunPayloadEvidence] = {
        do {
            return [
                try payload(kind: .submit, mode: .dryRun, productType: "spot"),
                try payload(kind: .cancel, mode: .shadow, productType: "usdsPerpetual"),
                try payload(kind: .replace, mode: .productionBlocked, productType: "usdsPerpetual")
            ]
        } catch {
            preconditionFailure("GH-648 shadow / dry-run payload evidence must be valid: \(error)")
        }
    }()

    private static func payload(
        kind: L4LiveRiskPreTradeCommandKind,
        mode: ProductionBrokerShadowDryRunProofMode,
        productType: String
    ) throws -> ProductionBrokerShadowDryRunPayloadEvidence {
        try ProductionBrokerShadowDryRunPayloadEvidence(
            payloadID: Identifier.constant("gh-648-\(kind.rawValue)-\(mode.rawValue)-payload"),
            commandKind: kind,
            mode: mode,
            productType: productType
        )
    }
}

private extension ProductionBrokerShadowDryRunProof {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        requirements: [ProductionBrokerShadowDryRunRequirement],
        forbiddenCapabilities: [ProductionBrokerShadowDryRunForbiddenCapability],
        payloadEvidence: [ProductionBrokerShadowDryRunPayloadEvidence],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-643..GH-649", "GH-643..GH-649", canonicalQueueRange),
            (
                "projectName",
                projectName == ProductionCutoverRuntimeHardeningContract.requiredProjectName,
                ProductionCutoverRuntimeHardeningContract.requiredProjectName,
                projectName
            ),
            (
                "requirements",
                requirements == requiredRequirements,
                requiredRequirements.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "payloadEvidence",
                payloadEvidence == requiredPayloadEvidence,
                requiredPayloadEvidence.map(\.payloadID.rawValue).joined(separator: ","),
                payloadEvidence.map(\.payloadID.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateRequiredTrueFlags(
        upstreamAuditTrailGateHeld: Bool,
        productionLikeRequestMappingRequired: Bool,
        dryRunAndShadowModeMarked: Bool,
        submitCancelReplacePayloadAuditRequired: Bool,
        productionOrderPathBlockedByDefault: Bool,
        rawBrokerPayloadNotExposedToDashboard: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamAuditTrailGateHeld", upstreamAuditTrailGateHeld),
            ("productionLikeRequestMappingRequired", productionLikeRequestMappingRequired),
            ("dryRunAndShadowModeMarked", dryRunAndShadowModeMarked),
            ("submitCancelReplacePayloadAuditRequired", submitCancelReplacePayloadAuditRequired),
            ("productionOrderPathBlockedByDefault", productionOrderPathBlockedByDefault),
            ("rawBrokerPayloadNotExposedToDashboard", rawBrokerPayloadNotExposedToDashboard)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        realBrokerConnectionEnabled: Bool,
        realOrderSubmissionEnabled: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("realBrokerConnectionEnabled", realBrokerConnectionEnabled),
            ("realOrderSubmissionEnabled", realOrderSubmissionEnabled),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
