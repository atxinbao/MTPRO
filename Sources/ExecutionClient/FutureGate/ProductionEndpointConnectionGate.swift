import DomainModel
import Foundation

/// ProductionEndpointConnectionRequirement 固定 GH-645 的 production endpoint connection gate 要求。
///
/// 这些 requirement 只描述生产 endpoint 连接前必须存在的显式 gate 和审计证据，不会读取
/// production secret、连接 production endpoint、启用 broker adapter、提交真实订单或绕过命令链路。
public enum ProductionEndpointConnectionRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamCredentialIsolationRequired = "upstream credential isolation required"
    case explicitOperatorApprovalRequired = "explicit operator approval required"
    case endpointVenueProductAllowlistRequired = "endpoint / venue / product allowlist required"
    case connectionAttemptAuditEvidenceRequired = "connection attempt audit evidence required"
    case connectionFailureFailsClosed = "connection failure fails closed"
    case noEndpointFallback = "no endpoint fallback"
    case noSilentContinuationAfterFailure = "no silent continuation after failure"
    case productionEndpointAutoConnectDisabled = "production endpoint auto-connect disabled"
    case commandRiskExecutionOMSEventStoreRequired = "CommandGateway / RiskEngine / ExecutionEngine / OMS / Event Store required"
}

/// ProductionEndpointConnectionForbiddenCapability 枚举 GH-645 必须拒绝的 endpoint connection bypass。
public enum ProductionEndpointConnectionForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case operatorApprovalBypass = "operator approval bypass"
    case endpointAllowlistBypass = "endpoint allowlist bypass"
    case venueAllowlistBypass = "venue allowlist bypass"
    case productTypeAllowlistBypass = "productType allowlist bypass"
    case endpointFallback = "endpoint fallback"
    case silentContinuationAfterFailure = "silent continuation after failure"
    case productionSecretValueRead = "production secret value read"
    case realBrokerConnection = "real broker connection"
    case realOrderSubmission = "real order submission"
    case commandRiskExecutionOMSBypass = "CommandGateway / RiskEngine / ExecutionEngine / OMS bypass"
    case eventStoreBypass = "Event Store bypass"
    case nonBinanceVenue = "non-Binance venue"
    case unsupportedProductType = "unsupported product type"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ProductionEndpointConnectionAttemptOutcome 描述 production endpoint connection attempt 的阻断原因。
///
/// 当前 issue 只允许产生被记录、被阻断、fail-closed 的 evidence outcome。这里没有成功连接 outcome。
public enum ProductionEndpointConnectionAttemptOutcome: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case blockedMissingOperatorApproval = "blocked: missing operator approval"
    case blockedEndpointNotAllowlisted = "blocked: endpoint not allowlisted"
    case blockedVenueNotAllowlisted = "blocked: venue not allowlisted"
    case blockedProductTypeNotAllowlisted = "blocked: productType not allowlisted"
    case blockedConnectionFailureFailClosed = "blocked: connection failure fail-closed"
}

/// ProductionEndpointConnectionAttemptAuditEvidence 是 GH-645 的 endpoint connection attempt 证据行。
///
/// Row 必须记录 endpoint / venue / productType / operator approval / audit anchor，并证明失败后不能
/// fallback、不能 silent continuation、不能真实连接 production endpoint。
public struct ProductionEndpointConnectionAttemptAuditEvidence: Codable, Equatable, Sendable {
    public let attemptID: Identifier
    public let endpointReference: String
    public let venue: String
    public let productType: String
    public let operatorApprovalAnchor: String
    public let auditAnchor: String
    public let outcome: ProductionEndpointConnectionAttemptOutcome
    public let endpointAllowlisted: Bool
    public let venueAllowlisted: Bool
    public let productTypeAllowlisted: Bool
    public let operatorApprovalPresent: Bool
    public let connectionAttemptRecorded: Bool
    public let connectionFailureObserved: Bool
    public let failureFailsClosed: Bool
    public let allowsFallback: Bool
    public let silentContinuationAllowed: Bool
    public let connectsProductionEndpoint: Bool

    public var auditBoundaryHeld: Bool {
        endpointReference.isEmpty == false
            && venue.isEmpty == false
            && productType.isEmpty == false
            && operatorApprovalAnchor.isEmpty == false
            && auditAnchor.isEmpty == false
            && connectionAttemptRecorded
            && failureFailsClosed
            && allowsFallback == false
            && silentContinuationAllowed == false
            && connectsProductionEndpoint == false
            && outcomeBoundaryHeld
    }

    private var outcomeBoundaryHeld: Bool {
        switch outcome {
        case .blockedMissingOperatorApproval:
            return endpointAllowlisted
                && venueAllowlisted
                && productTypeAllowlisted
                && operatorApprovalPresent == false
                && connectionFailureObserved == false
        case .blockedEndpointNotAllowlisted:
            return endpointAllowlisted == false
                && venueAllowlisted
                && productTypeAllowlisted
                && operatorApprovalPresent
                && connectionFailureObserved == false
        case .blockedVenueNotAllowlisted:
            return endpointAllowlisted
                && venueAllowlisted == false
                && productTypeAllowlisted
                && operatorApprovalPresent
                && connectionFailureObserved == false
        case .blockedProductTypeNotAllowlisted:
            return endpointAllowlisted
                && venueAllowlisted
                && productTypeAllowlisted == false
                && operatorApprovalPresent
                && connectionFailureObserved == false
        case .blockedConnectionFailureFailClosed:
            return endpointAllowlisted
                && venueAllowlisted
                && productTypeAllowlisted
                && operatorApprovalPresent
                && connectionFailureObserved
        }
    }

    public init(
        attemptID: Identifier,
        endpointReference: String,
        venue: String,
        productType: String,
        operatorApprovalAnchor: String,
        auditAnchor: String,
        outcome: ProductionEndpointConnectionAttemptOutcome,
        endpointAllowlisted: Bool,
        venueAllowlisted: Bool,
        productTypeAllowlisted: Bool,
        operatorApprovalPresent: Bool,
        connectionAttemptRecorded: Bool = true,
        connectionFailureObserved: Bool = false,
        failureFailsClosed: Bool = true,
        allowsFallback: Bool = false,
        silentContinuationAllowed: Bool = false,
        connectsProductionEndpoint: Bool = false
    ) throws {
        guard endpointReference.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointReference",
                expected: "non-empty production endpoint reference",
                actual: "empty"
            )
        }
        guard venue.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "venue",
                expected: "non-empty production endpoint venue",
                actual: "empty"
            )
        }
        guard productType.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "productType",
                expected: "non-empty production endpoint productType",
                actual: "empty"
            )
        }
        guard operatorApprovalAnchor.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "operatorApprovalAnchor",
                expected: "non-empty operator approval anchor",
                actual: "empty"
            )
        }
        guard auditAnchor.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "auditAnchor",
                expected: "non-empty endpoint connection audit anchor",
                actual: "empty"
            )
        }
        guard connectionAttemptRecorded else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "connectionAttemptRecorded",
                expected: "true",
                actual: "false"
            )
        }
        guard failureFailsClosed else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "failureFailsClosed",
                expected: "true",
                actual: "false"
            )
        }
        guard allowsFallback == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("allowsFallback")
        }
        guard silentContinuationAllowed == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("silentContinuationAllowed")
        }
        guard connectsProductionEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("connectsProductionEndpoint")
        }

        self.attemptID = attemptID
        self.endpointReference = endpointReference
        self.venue = venue
        self.productType = productType
        self.operatorApprovalAnchor = operatorApprovalAnchor
        self.auditAnchor = auditAnchor
        self.outcome = outcome
        self.endpointAllowlisted = endpointAllowlisted
        self.venueAllowlisted = venueAllowlisted
        self.productTypeAllowlisted = productTypeAllowlisted
        self.operatorApprovalPresent = operatorApprovalPresent
        self.connectionAttemptRecorded = connectionAttemptRecorded
        self.connectionFailureObserved = connectionFailureObserved
        self.failureFailsClosed = failureFailsClosed
        self.allowsFallback = allowsFallback
        self.silentContinuationAllowed = silentContinuationAllowed
        self.connectsProductionEndpoint = connectsProductionEndpoint

        guard auditBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "auditBoundaryHeld",
                expected: "endpoint attempt outcome matches fail-closed connection gate",
                actual: outcome.rawValue
            )
        }
    }
}

/// ProductionEndpointConnectionGate 是 GH-645 的 production endpoint connection gate 合同。
///
/// 合同绑定 GH-644 credential isolation，并固定 endpoint / venue / productType allowlist、
/// operator approval requirement、connection attempt audit evidence 和 failure fail-closed 规则。
/// 它不实现 endpoint connection runtime，不读取 secret，不启用 broker 或真实订单。
public struct ProductionEndpointConnectionGate: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamCredentialIsolationContractHeld: Bool
    public let allowedEndpointReferences: [String]
    public let allowedVenue: String
    public let allowedProductTypes: [String]
    public let requirements: [ProductionEndpointConnectionRequirement]
    public let forbiddenCapabilities: [ProductionEndpointConnectionForbiddenCapability]
    public let attemptEvidence: [ProductionEndpointConnectionAttemptAuditEvidence]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let operatorApprovalRequired: Bool
    public let endpointVenueProductAllowlistRequired: Bool
    public let connectionAttemptAuditRequired: Bool
    public let connectionFailureFailsClosed: Bool
    public let noEndpointFallbackRequired: Bool
    public let noSilentContinuationAfterFailureRequired: Bool
    public let productionEndpointConnectsByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let realBrokerConnectionEnabled: Bool
    public let realOrderSubmissionEnabled: Bool
    public let commandRiskExecutionOMSBypassAllowed: Bool
    public let eventStoreBypassAllowed: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-645"
            && upstreamIssueID.rawValue == "GH-644"
            && downstreamIssueID.rawValue == "GH-646"
            && canonicalQueueRange == "GH-643..GH-649"
            && projectName == ProductionCutoverRuntimeHardeningContract.requiredProjectName
            && upstreamCredentialIsolationContractHeld
            && allowedEndpointReferences == Self.requiredAllowedEndpointReferences
            && allowedVenue == ProductionCutoverRuntimeHardeningContract.requiredAllowedVenue
            && allowedProductTypes == ProductionCutoverRuntimeHardeningContract.requiredAllowedProductTypes
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && attemptEvidence == Self.requiredAttemptEvidence
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && operatorApprovalRequired
            && endpointVenueProductAllowlistRequired
            && connectionAttemptAuditRequired
            && connectionFailureFailsClosed
            && noEndpointFallbackRequired
            && noSilentContinuationAfterFailureRequired
            && endpointDefaultsClosed
            && bypassRejected
            && startsNextMilestone == false
    }

    public var allowlistCoverageHeld: Bool {
        Set(allowedEndpointReferences) == Set(Self.requiredAllowedEndpointReferences)
            && allowedVenue == ProductionCutoverRuntimeHardeningContract.requiredAllowedVenue
            && allowedProductTypes == ProductionCutoverRuntimeHardeningContract.requiredAllowedProductTypes
            && attemptEvidence.contains { $0.outcome == .blockedEndpointNotAllowlisted }
            && attemptEvidence.contains { $0.outcome == .blockedVenueNotAllowlisted }
            && attemptEvidence.contains { $0.outcome == .blockedProductTypeNotAllowlisted }
    }

    public var auditFailClosedCoverageHeld: Bool {
        attemptEvidence.allSatisfy(\.auditBoundaryHeld)
            && attemptEvidence.contains { $0.outcome == .blockedMissingOperatorApproval }
            && attemptEvidence.contains { $0.outcome == .blockedConnectionFailureFailClosed }
            && attemptEvidence.allSatisfy { $0.allowsFallback == false }
            && attemptEvidence.allSatisfy { $0.silentContinuationAllowed == false }
            && attemptEvidence.allSatisfy { $0.connectsProductionEndpoint == false }
    }

    public var endpointDefaultsClosed: Bool {
        productionEndpointConnectsByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && realBrokerConnectionEnabled == false
            && realOrderSubmissionEnabled == false
    }

    public var bypassRejected: Bool {
        commandRiskExecutionOMSBypassAllowed == false
            && eventStoreBypassAllowed == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-645-production-endpoint-connection-gate"),
        issueID: Identifier = Identifier.constant("GH-645"),
        upstreamIssueID: Identifier = Identifier.constant("GH-644"),
        downstreamIssueID: Identifier = Identifier.constant("GH-646"),
        canonicalQueueRange: String = "GH-643..GH-649",
        projectName: String = ProductionCutoverRuntimeHardeningContract.requiredProjectName,
        upstreamCredentialIsolationContractHeld: Bool = true,
        allowedEndpointReferences: [String] = Self.requiredAllowedEndpointReferences,
        allowedVenue: String = ProductionCutoverRuntimeHardeningContract.requiredAllowedVenue,
        allowedProductTypes: [String] = ProductionCutoverRuntimeHardeningContract.requiredAllowedProductTypes,
        requirements: [ProductionEndpointConnectionRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ProductionEndpointConnectionForbiddenCapability] = Self.requiredForbiddenCapabilities,
        attemptEvidence: [ProductionEndpointConnectionAttemptAuditEvidence] = Self.requiredAttemptEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        operatorApprovalRequired: Bool = true,
        endpointVenueProductAllowlistRequired: Bool = true,
        connectionAttemptAuditRequired: Bool = true,
        connectionFailureFailsClosed: Bool = true,
        noEndpointFallbackRequired: Bool = true,
        noSilentContinuationAfterFailureRequired: Bool = true,
        productionEndpointConnectsByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        realBrokerConnectionEnabled: Bool = false,
        realOrderSubmissionEnabled: Bool = false,
        commandRiskExecutionOMSBypassAllowed: Bool = false,
        eventStoreBypassAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            allowedEndpointReferences: allowedEndpointReferences,
            allowedVenue: allowedVenue,
            allowedProductTypes: allowedProductTypes,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            attemptEvidence: attemptEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamCredentialIsolationContractHeld: upstreamCredentialIsolationContractHeld,
            operatorApprovalRequired: operatorApprovalRequired,
            endpointVenueProductAllowlistRequired: endpointVenueProductAllowlistRequired,
            connectionAttemptAuditRequired: connectionAttemptAuditRequired,
            connectionFailureFailsClosed: connectionFailureFailsClosed,
            noEndpointFallbackRequired: noEndpointFallbackRequired,
            noSilentContinuationAfterFailureRequired: noSilentContinuationAfterFailureRequired
        )
        try Self.validateForbiddenFlags(
            productionEndpointConnectsByDefault: productionEndpointConnectsByDefault,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            realBrokerConnectionEnabled: realBrokerConnectionEnabled,
            realOrderSubmissionEnabled: realOrderSubmissionEnabled,
            commandRiskExecutionOMSBypassAllowed: commandRiskExecutionOMSBypassAllowed,
            eventStoreBypassAllowed: eventStoreBypassAllowed,
            startsNextMilestone: startsNextMilestone
        )

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamCredentialIsolationContractHeld = upstreamCredentialIsolationContractHeld
        self.allowedEndpointReferences = allowedEndpointReferences
        self.allowedVenue = allowedVenue
        self.allowedProductTypes = allowedProductTypes
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.attemptEvidence = attemptEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.operatorApprovalRequired = operatorApprovalRequired
        self.endpointVenueProductAllowlistRequired = endpointVenueProductAllowlistRequired
        self.connectionAttemptAuditRequired = connectionAttemptAuditRequired
        self.connectionFailureFailsClosed = connectionFailureFailsClosed
        self.noEndpointFallbackRequired = noEndpointFallbackRequired
        self.noSilentContinuationAfterFailureRequired = noSilentContinuationAfterFailureRequired
        self.productionEndpointConnectsByDefault = productionEndpointConnectsByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.realBrokerConnectionEnabled = realBrokerConnectionEnabled
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.commandRiskExecutionOMSBypassAllowed = commandRiskExecutionOMSBypassAllowed
        self.eventStoreBypassAllowed = eventStoreBypassAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ProductionEndpointConnectionGate {
        let upstream = try ProductionCredentialReferenceEnvironmentIsolation.deterministicFixture()
        return try ProductionEndpointConnectionGate(
            upstreamCredentialIsolationContractHeld: upstream.contractHeld
        )
    }

    public static let requiredAllowedEndpointReferences = [
        "binance-production-rest-endpoint-reference",
        "binance-production-websocket-endpoint-reference"
    ]

    public static let requiredRequirements = ProductionEndpointConnectionRequirement.allCases
    public static let requiredForbiddenCapabilities = ProductionEndpointConnectionForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "PCHR-03-PRODUCTION-ENDPOINT-CONNECTION-GATE",
        "PCHR-03-OPERATOR-APPROVAL-REQUIRED",
        "PCHR-03-ENDPOINT-VENUE-PRODUCT-ALLOWLIST",
        "PCHR-03-CONNECTION-ATTEMPT-AUDIT-EVIDENCE",
        "PCHR-03-CONNECTION-FAILURE-FAIL-CLOSED",
        "PCHR-03-NO-ENDPOINT-FALLBACK-OR-SILENT-CONTINUATION",
        "PCHR-03-NO-PRODUCTION-ENDPOINT-AUTO-CONNECT",
        "TVM-PCHR-PRODUCTION-ENDPOINT-CONNECTION-GATE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH645ProductionEndpointConnectionGateRequiresApprovalAllowlistAndAudit",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredAttemptEvidence: [ProductionEndpointConnectionAttemptAuditEvidence] = {
        do {
            return [
                try ProductionEndpointConnectionAttemptAuditEvidence(
                    attemptID: Identifier.constant("gh-645-missing-operator-approval-attempt"),
                    endpointReference: "binance-production-rest-endpoint-reference",
                    venue: "Binance",
                    productType: "spot",
                    operatorApprovalAnchor: "PCHR-03-OPERATOR-APPROVAL-REQUIRED",
                    auditAnchor: "PCHR-03-AUDIT-MISSING-OPERATOR-APPROVAL",
                    outcome: .blockedMissingOperatorApproval,
                    endpointAllowlisted: true,
                    venueAllowlisted: true,
                    productTypeAllowlisted: true,
                    operatorApprovalPresent: false
                ),
                try ProductionEndpointConnectionAttemptAuditEvidence(
                    attemptID: Identifier.constant("gh-645-unlisted-endpoint-attempt"),
                    endpointReference: "unlisted-production-endpoint-reference",
                    venue: "Binance",
                    productType: "spot",
                    operatorApprovalAnchor: "PCHR-03-OPERATOR-APPROVAL-REQUIRED",
                    auditAnchor: "PCHR-03-AUDIT-ENDPOINT-NOT-ALLOWLISTED",
                    outcome: .blockedEndpointNotAllowlisted,
                    endpointAllowlisted: false,
                    venueAllowlisted: true,
                    productTypeAllowlisted: true,
                    operatorApprovalPresent: true
                ),
                try ProductionEndpointConnectionAttemptAuditEvidence(
                    attemptID: Identifier.constant("gh-645-unlisted-venue-attempt"),
                    endpointReference: "binance-production-rest-endpoint-reference",
                    venue: "UnsupportedVenue",
                    productType: "spot",
                    operatorApprovalAnchor: "PCHR-03-OPERATOR-APPROVAL-REQUIRED",
                    auditAnchor: "PCHR-03-AUDIT-VENUE-NOT-ALLOWLISTED",
                    outcome: .blockedVenueNotAllowlisted,
                    endpointAllowlisted: true,
                    venueAllowlisted: false,
                    productTypeAllowlisted: true,
                    operatorApprovalPresent: true
                ),
                try ProductionEndpointConnectionAttemptAuditEvidence(
                    attemptID: Identifier.constant("gh-645-unlisted-product-type-attempt"),
                    endpointReference: "binance-production-rest-endpoint-reference",
                    venue: "Binance",
                    productType: "unsupportedProduct",
                    operatorApprovalAnchor: "PCHR-03-OPERATOR-APPROVAL-REQUIRED",
                    auditAnchor: "PCHR-03-AUDIT-PRODUCT-TYPE-NOT-ALLOWLISTED",
                    outcome: .blockedProductTypeNotAllowlisted,
                    endpointAllowlisted: true,
                    venueAllowlisted: true,
                    productTypeAllowlisted: false,
                    operatorApprovalPresent: true
                ),
                try ProductionEndpointConnectionAttemptAuditEvidence(
                    attemptID: Identifier.constant("gh-645-connection-failure-fail-closed-attempt"),
                    endpointReference: "binance-production-websocket-endpoint-reference",
                    venue: "Binance",
                    productType: "usdsPerpetual",
                    operatorApprovalAnchor: "PCHR-03-OPERATOR-APPROVAL-REQUIRED",
                    auditAnchor: "PCHR-03-AUDIT-CONNECTION-FAILURE-FAIL-CLOSED",
                    outcome: .blockedConnectionFailureFailClosed,
                    endpointAllowlisted: true,
                    venueAllowlisted: true,
                    productTypeAllowlisted: true,
                    operatorApprovalPresent: true,
                    connectionFailureObserved: true
                )
            ]
        } catch {
            preconditionFailure("GH-645 endpoint connection attempt evidence must be valid: \(error)")
        }
    }()
}

private extension ProductionEndpointConnectionGate {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        allowedEndpointReferences: [String],
        allowedVenue: String,
        allowedProductTypes: [String],
        requirements: [ProductionEndpointConnectionRequirement],
        forbiddenCapabilities: [ProductionEndpointConnectionForbiddenCapability],
        attemptEvidence: [ProductionEndpointConnectionAttemptAuditEvidence],
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
                "allowedEndpointReferences",
                allowedEndpointReferences == requiredAllowedEndpointReferences,
                requiredAllowedEndpointReferences.joined(separator: ","),
                allowedEndpointReferences.joined(separator: ",")
            ),
            (
                "allowedVenue",
                allowedVenue == ProductionCutoverRuntimeHardeningContract.requiredAllowedVenue,
                ProductionCutoverRuntimeHardeningContract.requiredAllowedVenue,
                allowedVenue
            ),
            (
                "allowedProductTypes",
                allowedProductTypes == ProductionCutoverRuntimeHardeningContract.requiredAllowedProductTypes,
                ProductionCutoverRuntimeHardeningContract.requiredAllowedProductTypes.joined(separator: ","),
                allowedProductTypes.joined(separator: ",")
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
                "attemptEvidence",
                attemptEvidence == requiredAttemptEvidence,
                requiredAttemptEvidence.map(\.attemptID.rawValue).joined(separator: ","),
                attemptEvidence.map(\.attemptID.rawValue).joined(separator: ",")
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
        upstreamCredentialIsolationContractHeld: Bool,
        operatorApprovalRequired: Bool,
        endpointVenueProductAllowlistRequired: Bool,
        connectionAttemptAuditRequired: Bool,
        connectionFailureFailsClosed: Bool,
        noEndpointFallbackRequired: Bool,
        noSilentContinuationAfterFailureRequired: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamCredentialIsolationContractHeld", upstreamCredentialIsolationContractHeld),
            ("operatorApprovalRequired", operatorApprovalRequired),
            ("endpointVenueProductAllowlistRequired", endpointVenueProductAllowlistRequired),
            ("connectionAttemptAuditRequired", connectionAttemptAuditRequired),
            ("connectionFailureFailsClosed", connectionFailureFailsClosed),
            ("noEndpointFallbackRequired", noEndpointFallbackRequired),
            ("noSilentContinuationAfterFailureRequired", noSilentContinuationAfterFailureRequired)
        ]

        for (field, value) in requiredTrueFlags where value == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "true", actual: "false")
        }
    }

    static func validateForbiddenFlags(
        productionEndpointConnectsByDefault: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        realBrokerConnectionEnabled: Bool,
        realOrderSubmissionEnabled: Bool,
        commandRiskExecutionOMSBypassAllowed: Bool,
        eventStoreBypassAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionEndpointConnectsByDefault", productionEndpointConnectsByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("realBrokerConnectionEnabled", realBrokerConnectionEnabled),
            ("realOrderSubmissionEnabled", realOrderSubmissionEnabled),
            ("commandRiskExecutionOMSBypassAllowed", commandRiskExecutionOMSBypassAllowed),
            ("eventStoreBypassAllowed", eventStoreBypassAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}
