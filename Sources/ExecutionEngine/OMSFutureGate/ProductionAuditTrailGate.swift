import DomainModel
import ExecutionClient
import Foundation

/// ProductionAuditTrailRequirement 固定 GH-647 的 OMS / Event Store audit trail 要求。
///
/// 这些 requirement 只描述 command 进入 execution handoff 前必须存在的 append-only evidence、
/// idempotency、replay 和 rollback / repair 证据，不实现 production Event Store runtime。
public enum ProductionAuditTrailRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamCommandDispatchGateRequired = "upstream command dispatch gate required"
    case appendOnlyCommandRiskOMSExecutionEventsRequired = "append-only command / risk / OMS / execution events required"
    case eventIdempotencyRequired = "event idempotency required"
    case replayRestoresCommandState = "replay restores command state"
    case rollbackRepairEvidenceRequired = "rollback / repair evidence required"
    case missingAuditTrailBlocksExecutionHandoff = "missing audit trail blocks execution handoff"
    case eventStoreAuditNoBypass = "Event Store audit no bypass"
}

/// ProductionAuditTrailForbiddenCapability 枚举 GH-647 必须拒绝的 audit trail 绕过。
public enum ProductionAuditTrailForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case missingAppendOnlyEvent = "missing append-only event"
    case mutableEventWrite = "mutable event write"
    case duplicateEventNonIdempotent = "duplicate event non-idempotent"
    case replayCannotRestoreCommandState = "replay cannot restore command state"
    case rollbackRepairEvidenceMissing = "rollback / repair evidence missing"
    case executionHandoffWithoutAuditTrail = "execution handoff without audit trail"
    case eventStoreBypass = "Event Store bypass"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretValueRead = "production secret value read"
    case realBrokerConnection = "real broker connection"
    case realOrderSubmission = "real order submission"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ProductionAuditTrailEventKind 固定 GH-647 append-only audit trail 必须覆盖的事件种类。
public enum ProductionAuditTrailEventKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case command = "command"
    case riskDecision = "risk decision"
    case omsTransition = "OMS transition"
    case executionIntent = "execution intent"
}

/// ProductionAuditTrailEventEvidence 是 GH-647 的 append-only event evidence row。
///
/// Row 只记录 deterministic identity 和 replay metadata；不包含 secret、broker payload、account payload、
/// production endpoint response 或真实 order state mutation。
public struct ProductionAuditTrailEventEvidence: Codable, Equatable, Sendable {
    public let eventID: Identifier
    public let commandID: Identifier
    public let kind: ProductionAuditTrailEventKind
    public let sequence: Int
    public let idempotencyKey: String
    public let sourceAnchor: String
    public let appendOnly: Bool
    public let idempotent: Bool
    public let mutableWriteAllowed: Bool
    public let containsSecretValue: Bool
    public let containsBrokerPayload: Bool
    public let writesProductionOrderState: Bool

    public var eventBoundaryHeld: Bool {
        sequence > 0
            && idempotencyKey.isEmpty == false
            && sourceAnchor.isEmpty == false
            && appendOnly
            && idempotent
            && mutableWriteAllowed == false
            && containsSecretValue == false
            && containsBrokerPayload == false
            && writesProductionOrderState == false
    }

    public init(
        eventID: Identifier,
        commandID: Identifier,
        kind: ProductionAuditTrailEventKind,
        sequence: Int,
        idempotencyKey: String,
        sourceAnchor: String,
        appendOnly: Bool = true,
        idempotent: Bool = true,
        mutableWriteAllowed: Bool = false,
        containsSecretValue: Bool = false,
        containsBrokerPayload: Bool = false,
        writesProductionOrderState: Bool = false
    ) throws {
        guard sequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sequence",
                expected: "positive append-only audit sequence",
                actual: "\(sequence)"
            )
        }
        guard idempotencyKey.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "idempotencyKey",
                expected: "non-empty audit event idempotency key",
                actual: "empty"
            )
        }
        guard sourceAnchor.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceAnchor",
                expected: "non-empty audit event source anchor",
                actual: "empty"
            )
        }
        guard appendOnly else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "appendOnly", expected: "true", actual: "false")
        }
        guard idempotent else {
            throw CoreError.liveTradingBoundaryContractMismatch(field: "idempotent", expected: "true", actual: "false")
        }
        for forbiddenFlag in [
            ("mutableWriteAllowed", mutableWriteAllowed),
            ("containsSecretValue", containsSecretValue),
            ("containsBrokerPayload", containsBrokerPayload),
            ("writesProductionOrderState", writesProductionOrderState)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.eventID = eventID
        self.commandID = commandID
        self.kind = kind
        self.sequence = sequence
        self.idempotencyKey = idempotencyKey
        self.sourceAnchor = sourceAnchor
        self.appendOnly = appendOnly
        self.idempotent = idempotent
        self.mutableWriteAllowed = mutableWriteAllowed
        self.containsSecretValue = containsSecretValue
        self.containsBrokerPayload = containsBrokerPayload
        self.writesProductionOrderState = writesProductionOrderState
    }
}

/// ProductionAuditTrailReplayRepairEvidence 描述 GH-647 replay / rollback / repair 证据。
///
/// Evidence 只证明 append-only event set 可以恢复关键 command state，并能输出 rollback / repair identity。
/// 它不执行自动修复、不提交订单、不触碰真实 broker 或 production Event Store。
public struct ProductionAuditTrailReplayRepairEvidence: Codable, Equatable, Sendable {
    public let replayID: Identifier
    public let commandID: Identifier
    public let replayedEventIDs: [Identifier]
    public let restoredCommandState: String
    public let rollbackRepairEvidenceID: Identifier
    public let replayRestoresKeyState: Bool
    public let rollbackRepairEvidenceProduced: Bool
    public let missingAuditTrailBlocksExecutionHandoff: Bool
    public let automaticRepairEnabled: Bool
    public let executionHandoffAllowedWithoutAuditTrail: Bool
    public let eventStoreBypassAllowed: Bool

    public var replayRepairBoundaryHeld: Bool {
        replayedEventIDs.isEmpty == false
            && restoredCommandState.isEmpty == false
            && replayRestoresKeyState
            && rollbackRepairEvidenceProduced
            && missingAuditTrailBlocksExecutionHandoff
            && automaticRepairEnabled == false
            && executionHandoffAllowedWithoutAuditTrail == false
            && eventStoreBypassAllowed == false
    }

    public init(
        replayID: Identifier = Identifier.constant("gh-647-audit-trail-replay"),
        commandID: Identifier = Identifier.constant("gh-647-command"),
        replayedEventIDs: [Identifier],
        restoredCommandState: String = "command recorded / risk approved / OMS transition recorded / execution intent pending",
        rollbackRepairEvidenceID: Identifier = Identifier.constant("gh-647-rollback-repair-evidence"),
        replayRestoresKeyState: Bool = true,
        rollbackRepairEvidenceProduced: Bool = true,
        missingAuditTrailBlocksExecutionHandoff: Bool = true,
        automaticRepairEnabled: Bool = false,
        executionHandoffAllowedWithoutAuditTrail: Bool = false,
        eventStoreBypassAllowed: Bool = false
    ) throws {
        guard replayedEventIDs.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayedEventIDs",
                expected: "non-empty replay event ids",
                actual: "empty"
            )
        }
        guard restoredCommandState.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "restoredCommandState",
                expected: "non-empty restored command state",
                actual: "empty"
            )
        }
        for requiredFlag in [
            ("replayRestoresKeyState", replayRestoresKeyState),
            ("rollbackRepairEvidenceProduced", rollbackRepairEvidenceProduced),
            ("missingAuditTrailBlocksExecutionHandoff", missingAuditTrailBlocksExecutionHandoff)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: requiredFlag.0, expected: "true", actual: "false")
        }
        for forbiddenFlag in [
            ("automaticRepairEnabled", automaticRepairEnabled),
            ("executionHandoffAllowedWithoutAuditTrail", executionHandoffAllowedWithoutAuditTrail),
            ("eventStoreBypassAllowed", eventStoreBypassAllowed)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.replayID = replayID
        self.commandID = commandID
        self.replayedEventIDs = replayedEventIDs
        self.restoredCommandState = restoredCommandState
        self.rollbackRepairEvidenceID = rollbackRepairEvidenceID
        self.replayRestoresKeyState = replayRestoresKeyState
        self.rollbackRepairEvidenceProduced = rollbackRepairEvidenceProduced
        self.missingAuditTrailBlocksExecutionHandoff = missingAuditTrailBlocksExecutionHandoff
        self.automaticRepairEnabled = automaticRepairEnabled
        self.executionHandoffAllowedWithoutAuditTrail = executionHandoffAllowedWithoutAuditTrail
        self.eventStoreBypassAllowed = eventStoreBypassAllowed
    }
}

/// ProductionAuditTrailGate 是 GH-647 的 OMS / Event Store production audit trail 合同。
///
/// 合同绑定 GH-646 dispatch gate，并固定 command、risk decision、OMS transition、execution intent 必须作为
/// append-only events 存在。缺少 audit trail 时不能进入 execution handoff。
public struct ProductionAuditTrailGate: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamCommandDispatchGateHeld: Bool
    public let requirements: [ProductionAuditTrailRequirement]
    public let forbiddenCapabilities: [ProductionAuditTrailForbiddenCapability]
    public let events: [ProductionAuditTrailEventEvidence]
    public let replayRepairEvidence: ProductionAuditTrailReplayRepairEvidence
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let appendOnlyEvidenceRequired: Bool
    public let eventIdempotencyRequired: Bool
    public let replayRestoresKeyCommandState: Bool
    public let rollbackRepairEvidenceRequired: Bool
    public let missingAuditTrailBlocksExecutionHandoff: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let realBrokerConnectionEnabled: Bool
    public let realOrderSubmissionEnabled: Bool
    public let startsNextMilestone: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-647"
            && upstreamIssueID.rawValue == "GH-646"
            && downstreamIssueID.rawValue == "GH-648"
            && canonicalQueueRange == "GH-643..GH-649"
            && projectName == ProductionCutoverRuntimeHardeningContract.requiredProjectName
            && upstreamCommandDispatchGateHeld
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && events == Self.requiredEvents
            && replayRepairEvidence == Self.requiredReplayRepairEvidence
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && appendOnlyEvidenceRequired
            && eventIdempotencyRequired
            && replayRestoresKeyCommandState
            && rollbackRepairEvidenceRequired
            && missingAuditTrailBlocksExecutionHandoff
            && productionDefaultsClosed
            && startsNextMilestone == false
    }

    public var auditTrailCoverageHeld: Bool {
        Set(events.map(\.kind)) == Set(ProductionAuditTrailEventKind.allCases)
            && events.map(\.sequence) == [1, 2, 3, 4]
            && events.allSatisfy(\.eventBoundaryHeld)
            && Set(events.map(\.idempotencyKey)).count == events.count
    }

    public var replayRepairCoverageHeld: Bool {
        replayRepairEvidence.replayRepairBoundaryHeld
            && Set(replayRepairEvidence.replayedEventIDs) == Set(events.map(\.eventID))
    }

    public var productionDefaultsClosed: Bool {
        productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && realBrokerConnectionEnabled == false
            && realOrderSubmissionEnabled == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-647-production-audit-trail-gate"),
        issueID: Identifier = Identifier.constant("GH-647"),
        upstreamIssueID: Identifier = Identifier.constant("GH-646"),
        downstreamIssueID: Identifier = Identifier.constant("GH-648"),
        canonicalQueueRange: String = "GH-643..GH-649",
        projectName: String = ProductionCutoverRuntimeHardeningContract.requiredProjectName,
        upstreamCommandDispatchGateHeld: Bool = true,
        requirements: [ProductionAuditTrailRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ProductionAuditTrailForbiddenCapability] = Self.requiredForbiddenCapabilities,
        events: [ProductionAuditTrailEventEvidence] = Self.requiredEvents,
        replayRepairEvidence: ProductionAuditTrailReplayRepairEvidence = Self.requiredReplayRepairEvidence,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        appendOnlyEvidenceRequired: Bool = true,
        eventIdempotencyRequired: Bool = true,
        replayRestoresKeyCommandState: Bool = true,
        rollbackRepairEvidenceRequired: Bool = true,
        missingAuditTrailBlocksExecutionHandoff: Bool = true,
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
            events: events,
            replayRepairEvidence: replayRepairEvidence,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(
            upstreamCommandDispatchGateHeld: upstreamCommandDispatchGateHeld,
            appendOnlyEvidenceRequired: appendOnlyEvidenceRequired,
            eventIdempotencyRequired: eventIdempotencyRequired,
            replayRestoresKeyCommandState: replayRestoresKeyCommandState,
            rollbackRepairEvidenceRequired: rollbackRepairEvidenceRequired,
            missingAuditTrailBlocksExecutionHandoff: missingAuditTrailBlocksExecutionHandoff
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
        self.upstreamCommandDispatchGateHeld = upstreamCommandDispatchGateHeld
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.events = events
        self.replayRepairEvidence = replayRepairEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.appendOnlyEvidenceRequired = appendOnlyEvidenceRequired
        self.eventIdempotencyRequired = eventIdempotencyRequired
        self.replayRestoresKeyCommandState = replayRestoresKeyCommandState
        self.rollbackRepairEvidenceRequired = rollbackRepairEvidenceRequired
        self.missingAuditTrailBlocksExecutionHandoff = missingAuditTrailBlocksExecutionHandoff
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.realBrokerConnectionEnabled = realBrokerConnectionEnabled
        self.realOrderSubmissionEnabled = realOrderSubmissionEnabled
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ProductionAuditTrailGate {
        let upstream = try ProductionCommandDispatchGate.deterministicFixture()
        return try ProductionAuditTrailGate(
            upstreamCommandDispatchGateHeld: upstream.contractHeld
        )
    }

    public static let requiredRequirements = ProductionAuditTrailRequirement.allCases
    public static let requiredForbiddenCapabilities = ProductionAuditTrailForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "PCHR-05-OMS-EVENT-STORE-PRODUCTION-AUDIT-TRAIL",
        "PCHR-05-APPEND-ONLY-COMMAND-RISK-OMS-EXECUTION-EVENTS",
        "PCHR-05-EVENT-IDEMPOTENCY",
        "PCHR-05-REPLAY-RESTORES-COMMAND-STATE",
        "PCHR-05-ROLLBACK-REPAIR-EVIDENCE",
        "PCHR-05-MISSING-AUDIT-BLOCKS-HANDOFF",
        "PCHR-05-NO-PRODUCTION-ORDER-AUTHORIZATION",
        "TVM-PCHR-OMS-EVENT-STORE-AUDIT-TRAIL"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH647ProductionAuditTrailRequiresAppendOnlyReplayAndRepairEvidence",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredEvents: [ProductionAuditTrailEventEvidence] = {
        do {
            let commandID = Identifier.constant("gh-647-command")
            return [
                try event(kind: .command, sequence: 1, commandID: commandID),
                try event(kind: .riskDecision, sequence: 2, commandID: commandID),
                try event(kind: .omsTransition, sequence: 3, commandID: commandID),
                try event(kind: .executionIntent, sequence: 4, commandID: commandID)
            ]
        } catch {
            preconditionFailure("GH-647 audit trail events must be valid: \(error)")
        }
    }()

    public static let requiredReplayRepairEvidence: ProductionAuditTrailReplayRepairEvidence = {
        do {
            return try ProductionAuditTrailReplayRepairEvidence(
                replayedEventIDs: requiredEvents.map(\.eventID)
            )
        } catch {
            preconditionFailure("GH-647 replay / repair evidence must be valid: \(error)")
        }
    }()

    private static func event(
        kind: ProductionAuditTrailEventKind,
        sequence: Int,
        commandID: Identifier
    ) throws -> ProductionAuditTrailEventEvidence {
        try ProductionAuditTrailEventEvidence(
            eventID: Identifier.constant("gh-647-\(kind.rawValue.replacingOccurrences(of: " ", with: "-"))-event"),
            commandID: commandID,
            kind: kind,
            sequence: sequence,
            idempotencyKey: "gh-647-\(sequence)-\(kind.rawValue)",
            sourceAnchor: "PCHR-05-\(kind.rawValue.uppercased().replacingOccurrences(of: " ", with: "-"))"
        )
    }
}

private extension ProductionAuditTrailGate {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        requirements: [ProductionAuditTrailRequirement],
        forbiddenCapabilities: [ProductionAuditTrailForbiddenCapability],
        events: [ProductionAuditTrailEventEvidence],
        replayRepairEvidence: ProductionAuditTrailReplayRepairEvidence,
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
                "events",
                events == requiredEvents,
                requiredEvents.map(\.eventID.rawValue).joined(separator: ","),
                events.map(\.eventID.rawValue).joined(separator: ",")
            ),
            (
                "replayRepairEvidence",
                replayRepairEvidence == requiredReplayRepairEvidence,
                requiredReplayRepairEvidence.replayID.rawValue,
                replayRepairEvidence.replayID.rawValue
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
        upstreamCommandDispatchGateHeld: Bool,
        appendOnlyEvidenceRequired: Bool,
        eventIdempotencyRequired: Bool,
        replayRestoresKeyCommandState: Bool,
        rollbackRepairEvidenceRequired: Bool,
        missingAuditTrailBlocksExecutionHandoff: Bool
    ) throws {
        let requiredTrueFlags = [
            ("upstreamCommandDispatchGateHeld", upstreamCommandDispatchGateHeld),
            ("appendOnlyEvidenceRequired", appendOnlyEvidenceRequired),
            ("eventIdempotencyRequired", eventIdempotencyRequired),
            ("replayRestoresKeyCommandState", replayRestoresKeyCommandState),
            ("rollbackRepairEvidenceRequired", rollbackRepairEvidenceRequired),
            ("missingAuditTrailBlocksExecutionHandoff", missingAuditTrailBlocksExecutionHandoff)
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
