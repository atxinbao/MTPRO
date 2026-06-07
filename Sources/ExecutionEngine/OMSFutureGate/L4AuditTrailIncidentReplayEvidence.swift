import DomainModel
import ExecutionClient
import Foundation

/// L4AuditTrailIncidentReplayStage 固定 GH-467 audit trail 必须覆盖的 lifecycle stage。
///
/// Stage 只描述本地 deterministic sandbox command path 的审计记录，不代表 production incident ops、
/// 外部审计系统、真实 broker replay 或 Live command runtime。
public enum L4AuditTrailIncidentReplayStage: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case commandIntent = "command intent"
    case riskDecision = "risk decision"
    case executionRequest = "execution request"
    case brokerReport = "broker report"
    case omsTransition = "OMS transition"
    case reconciliationOutcome = "reconciliation outcome"
}

/// L4AuditTrailIncidentReplayForbiddenCapability 枚举 GH-467 必须保持关闭的能力。
///
/// GH-467 只生成 local append-only audit trail 和 incident replay evidence；它不上传外部审计系统，
/// 不捕获 secret / raw broker payload，不执行 production broker replay，也不产生 repair command。
public enum L4AuditTrailIncidentReplayForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case externalAuditUpload = "external audit upload"
    case secretCaptured = "secret captured"
    case rawBrokerPayloadCaptured = "raw broker payload captured"
    case productionIncidentOps = "production incident ops"
    case productionBrokerReplay = "production broker replay"
    case mutableAuditTrail = "mutable audit trail"
    case repairCommandProduced = "repair command produced"
    case callsExecutionClient = "calls ExecutionClient"
    case touchesBrokerGateway = "touches broker gateway"
    case exposesLiveCommandSurface = "exposes Live command surface"
}

/// L4CommandAuditTrailEntry 是 GH-467 的单条 append-only command audit evidence。
///
/// Entry 绑定 command intent、RiskEngine decision、sandbox execution request、normalized broker report、
/// OMS transition 和 reconciliation outcome 中的一个 stage。它不保存 secret、raw broker payload、真实账户
/// 或 production broker replay payload，也不会上传外部系统。
public struct L4CommandAuditTrailEntry: Codable, Equatable, Sendable {
    public let entryID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let commandKind: L4ExecutionClientSandboxCommandKind
    public let stage: L4AuditTrailIncidentReplayStage
    public let sequence: Int
    public let commandIntentID: Identifier
    public let riskDecisionID: Identifier
    public let executionRequestID: Identifier
    public let brokerReportEventID: Identifier?
    public let omsTransitionID: Identifier?
    public let reconciliationRecordID: Identifier?
    public let reconciliationStatus: L4OMSBrokerPortfolioReconciliationStatus?
    public let deterministicPayloadDigest: String
    public let appendOnlyFact: Bool
    public let containsSecret: Bool
    public let containsRawBrokerPayload: Bool
    public let uploadedToExternalAudit: Bool
    public let mutableAfterAppend: Bool
    public let productionBrokerReplay: Bool
    public let repairCommandProduced: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let exposesLiveCommandSurface: Bool

    public var entryBoundaryHeld: Bool {
        issueID.rawValue == "GH-467"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-463", "GH-466"]
            && sequence > 0
            && deterministicPayloadDigest.isEmpty == false
            && appendOnlyFact
            && stageSourceBoundaryHeld
            && allForbiddenFlagsRemainClosed
    }

    private var stageSourceBoundaryHeld: Bool {
        switch stage {
        case .commandIntent:
            commandIntentID.rawValue.isEmpty == false
        case .riskDecision:
            riskDecisionID.rawValue.isEmpty == false
        case .executionRequest:
            executionRequestID.rawValue.isEmpty == false
        case .brokerReport:
            brokerReportEventID?.rawValue.isEmpty == false
        case .omsTransition:
            omsTransitionID?.rawValue.isEmpty == false
        case .reconciliationOutcome:
            reconciliationRecordID?.rawValue.isEmpty == false && reconciliationStatus != nil
        }
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            containsSecret,
            containsRawBrokerPayload,
            uploadedToExternalAudit,
            mutableAfterAppend,
            productionBrokerReplay,
            repairCommandProduced,
            callsExecutionClient,
            touchesBrokerGateway,
            exposesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        entryID: Identifier,
        issueID: Identifier = Identifier.constant("GH-467"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-463"),
            Identifier.constant("GH-466")
        ],
        commandKind: L4ExecutionClientSandboxCommandKind,
        stage: L4AuditTrailIncidentReplayStage,
        sequence: Int,
        commandIntentID: Identifier,
        riskDecisionID: Identifier,
        executionRequestID: Identifier,
        brokerReportEventID: Identifier? = nil,
        omsTransitionID: Identifier? = nil,
        reconciliationRecordID: Identifier? = nil,
        reconciliationStatus: L4OMSBrokerPortfolioReconciliationStatus? = nil,
        deterministicPayloadDigest: String,
        appendOnlyFact: Bool = true,
        containsSecret: Bool = false,
        containsRawBrokerPayload: Bool = false,
        uploadedToExternalAudit: Bool = false,
        mutableAfterAppend: Bool = false,
        productionBrokerReplay: Bool = false,
        repairCommandProduced: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-467" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-467",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-463", "GH-466"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-463,GH-466",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard sequence > 0 else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sequence",
                expected: "positive append-only GH-467 sequence",
                actual: "\(sequence)"
            )
        }
        guard deterministicPayloadDigest.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "deterministicPayloadDigest",
                expected: "non-empty deterministic payload digest",
                actual: "empty"
            )
        }
        guard appendOnlyFact else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("appendOnlyFact")
        }
        for forbiddenFlag in [
            ("containsSecret", containsSecret),
            ("containsRawBrokerPayload", containsRawBrokerPayload),
            ("uploadedToExternalAudit", uploadedToExternalAudit),
            ("mutableAfterAppend", mutableAfterAppend),
            ("productionBrokerReplay", productionBrokerReplay),
            ("repairCommandProduced", repairCommandProduced),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.entryID = entryID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.commandKind = commandKind
        self.stage = stage
        self.sequence = sequence
        self.commandIntentID = commandIntentID
        self.riskDecisionID = riskDecisionID
        self.executionRequestID = executionRequestID
        self.brokerReportEventID = brokerReportEventID
        self.omsTransitionID = omsTransitionID
        self.reconciliationRecordID = reconciliationRecordID
        self.reconciliationStatus = reconciliationStatus
        self.deterministicPayloadDigest = deterministicPayloadDigest
        self.appendOnlyFact = appendOnlyFact
        self.containsSecret = containsSecret
        self.containsRawBrokerPayload = containsRawBrokerPayload
        self.uploadedToExternalAudit = uploadedToExternalAudit
        self.mutableAfterAppend = mutableAfterAppend
        self.productionBrokerReplay = productionBrokerReplay
        self.repairCommandProduced = repairCommandProduced
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.exposesLiveCommandSurface = exposesLiveCommandSurface

        guard entryBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "entryBoundaryHeld",
                expected: "\(stage.rawValue) audit trail entry boundary held",
                actual: "mismatch"
            )
        }
    }
}

/// L4IncidentReplayInput 固定 GH-467 incident replay 的本地输入。
///
/// Input 只能消费 GH-467 append-only audit entries。它不读取外部审计系统、production broker report、
/// secret、raw payload 或真实账户状态。
public struct L4IncidentReplayInput: Codable, Equatable, Sendable {
    public let inputID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let incidentID: Identifier
    public let entries: [L4CommandAuditTrailEntry]
    public let deterministicInputDigest: String
    public let consumesAppendOnlyAuditTrail: Bool
    public let readsExternalAuditSystem: Bool
    public let readsProductionBrokerReport: Bool
    public let readsSecret: Bool
    public let readsRawBrokerPayload: Bool

    public var inputBoundaryHeld: Bool {
        issueID.rawValue == "GH-467"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-463", "GH-466"]
            && entries.isEmpty == false
            && entries.allSatisfy(\.entryBoundaryHeld)
            && Self.sequencesAreContiguous(entries)
            && deterministicInputDigest.isEmpty == false
            && consumesAppendOnlyAuditTrail
            && readsExternalAuditSystem == false
            && readsProductionBrokerReport == false
            && readsSecret == false
            && readsRawBrokerPayload == false
    }

    public init(
        inputID: Identifier = Identifier.constant("gh-467-incident-replay-input"),
        issueID: Identifier = Identifier.constant("GH-467"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-463"),
            Identifier.constant("GH-466")
        ],
        incidentID: Identifier = Identifier.constant("gh-467-sandbox-incident"),
        entries: [L4CommandAuditTrailEntry],
        deterministicInputDigest: String,
        consumesAppendOnlyAuditTrail: Bool = true,
        readsExternalAuditSystem: Bool = false,
        readsProductionBrokerReport: Bool = false,
        readsSecret: Bool = false,
        readsRawBrokerPayload: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-467" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-467",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-463", "GH-466"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-463,GH-466",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard entries.isEmpty == false && entries.allSatisfy(\.entryBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "entries",
                expected: "non-empty GH-467 append-only audit entries",
                actual: "mismatch"
            )
        }
        guard Self.sequencesAreContiguous(entries) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "entries.sequence",
                expected: Self.expectedSequenceDigest(count: entries.count),
                actual: entries.map { "\($0.sequence)" }.joined(separator: ",")
            )
        }
        guard deterministicInputDigest.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "deterministicInputDigest",
                expected: "non-empty deterministic input digest",
                actual: "empty"
            )
        }
        guard consumesAppendOnlyAuditTrail else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("consumesAppendOnlyAuditTrail")
        }
        for forbiddenFlag in [
            ("readsExternalAuditSystem", readsExternalAuditSystem),
            ("readsProductionBrokerReport", readsProductionBrokerReport),
            ("readsSecret", readsSecret),
            ("readsRawBrokerPayload", readsRawBrokerPayload)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.inputID = inputID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.incidentID = incidentID
        self.entries = entries
        self.deterministicInputDigest = deterministicInputDigest
        self.consumesAppendOnlyAuditTrail = consumesAppendOnlyAuditTrail
        self.readsExternalAuditSystem = readsExternalAuditSystem
        self.readsProductionBrokerReport = readsProductionBrokerReport
        self.readsSecret = readsSecret
        self.readsRawBrokerPayload = readsRawBrokerPayload
    }

    public static func sequencesAreContiguous(_ entries: [L4CommandAuditTrailEntry]) -> Bool {
        entries.map(\.sequence) == Array(1...entries.count)
    }

    public static func expectedSequenceDigest(count: Int) -> String {
        Array(1...max(count, 1)).map(String.init).joined(separator: ",")
    }
}

/// L4IncidentReplayOutput 固定 GH-467 deterministic incident replay 输出。
///
/// Output 只能从本地 append-only audit trail replay 派生，用于证明 sandbox lifecycle 可重放。它不执行
/// production incident ops、不调用 broker、不上传审计记录，也不发出修复或交易命令。
public struct L4IncidentReplayOutput: Codable, Equatable, Sendable {
    public let replayID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let inputID: Identifier
    public let incidentID: Identifier
    public let replayedEntries: [L4CommandAuditTrailEntry]
    public let replayedCommandKinds: [L4ExecutionClientSandboxCommandKind]
    public let replayedStages: [L4AuditTrailIncidentReplayStage]
    public let replayedReconciliationStatuses: [L4OMSBrokerPortfolioReconciliationStatus]
    public let deterministicReplayDigest: String
    public let appendOnlyReplayDeterministic: Bool
    public let sandboxLifecycleReplayed: Bool
    public let secretFree: Bool
    public let rawBrokerPayloadFree: Bool
    public let externalAuditUpload: Bool
    public let productionIncidentOps: Bool
    public let productionBrokerReplay: Bool
    public let repairCommandProduced: Bool
    public let exposesLiveCommandSurface: Bool

    public var outputBoundaryHeld: Bool {
        issueID.rawValue == "GH-467"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-463", "GH-466"]
            && replayedEntries.isEmpty == false
            && replayedEntries.allSatisfy(\.entryBoundaryHeld)
            && L4IncidentReplayInput.sequencesAreContiguous(replayedEntries)
            && Set(replayedCommandKinds) == Set(L4ExecutionClientSandboxCommandKind.allCases)
            && Set(replayedStages) == Set(L4AuditTrailIncidentReplayStage.allCases)
            && Set(replayedReconciliationStatuses) == Set(L4OMSBrokerPortfolioReconciliationStatus.allCases)
            && deterministicReplayDigest.isEmpty == false
            && appendOnlyReplayDeterministic
            && sandboxLifecycleReplayed
            && secretFree
            && rawBrokerPayloadFree
            && externalAuditUpload == false
            && productionIncidentOps == false
            && productionBrokerReplay == false
            && repairCommandProduced == false
            && exposesLiveCommandSurface == false
    }

    public init(
        replayID: Identifier = Identifier.constant("gh-467-incident-replay-output"),
        issueID: Identifier = Identifier.constant("GH-467"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-463"),
            Identifier.constant("GH-466")
        ],
        inputID: Identifier,
        incidentID: Identifier,
        replayedEntries: [L4CommandAuditTrailEntry],
        replayedCommandKinds: [L4ExecutionClientSandboxCommandKind],
        replayedStages: [L4AuditTrailIncidentReplayStage],
        replayedReconciliationStatuses: [L4OMSBrokerPortfolioReconciliationStatus],
        deterministicReplayDigest: String,
        appendOnlyReplayDeterministic: Bool = true,
        sandboxLifecycleReplayed: Bool = true,
        secretFree: Bool = true,
        rawBrokerPayloadFree: Bool = true,
        externalAuditUpload: Bool = false,
        productionIncidentOps: Bool = false,
        productionBrokerReplay: Bool = false,
        repairCommandProduced: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-467" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-467",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-463", "GH-466"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-463,GH-466",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard replayedEntries.isEmpty == false && replayedEntries.allSatisfy(\.entryBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayedEntries",
                expected: "non-empty GH-467 replayed audit entries",
                actual: "mismatch"
            )
        }
        guard L4IncidentReplayInput.sequencesAreContiguous(replayedEntries) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayedEntries.sequence",
                expected: L4IncidentReplayInput.expectedSequenceDigest(count: replayedEntries.count),
                actual: replayedEntries.map { "\($0.sequence)" }.joined(separator: ",")
            )
        }
        guard Set(replayedCommandKinds) == Set(L4ExecutionClientSandboxCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayedCommandKinds",
                expected: L4ExecutionClientSandboxCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: replayedCommandKinds.map(\.rawValue).joined(separator: ",")
            )
        }
        guard Set(replayedStages) == Set(L4AuditTrailIncidentReplayStage.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayedStages",
                expected: L4AuditTrailIncidentReplayStage.allCases.map(\.rawValue).joined(separator: ","),
                actual: replayedStages.map(\.rawValue).joined(separator: ",")
            )
        }
        guard Set(replayedReconciliationStatuses) == Set(L4OMSBrokerPortfolioReconciliationStatus.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayedReconciliationStatuses",
                expected: L4OMSBrokerPortfolioReconciliationStatus.allCases.map(\.rawValue).joined(separator: ","),
                actual: replayedReconciliationStatuses.map(\.rawValue).joined(separator: ",")
            )
        }
        guard deterministicReplayDigest.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "deterministicReplayDigest",
                expected: "non-empty deterministic replay digest",
                actual: "empty"
            )
        }
        for requiredFlag in [
            ("appendOnlyReplayDeterministic", appendOnlyReplayDeterministic),
            ("sandboxLifecycleReplayed", sandboxLifecycleReplayed),
            ("secretFree", secretFree),
            ("rawBrokerPayloadFree", rawBrokerPayloadFree)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("externalAuditUpload", externalAuditUpload),
            ("productionIncidentOps", productionIncidentOps),
            ("productionBrokerReplay", productionBrokerReplay),
            ("repairCommandProduced", repairCommandProduced),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.replayID = replayID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.inputID = inputID
        self.incidentID = incidentID
        self.replayedEntries = replayedEntries
        self.replayedCommandKinds = replayedCommandKinds
        self.replayedStages = replayedStages
        self.replayedReconciliationStatuses = replayedReconciliationStatuses
        self.deterministicReplayDigest = deterministicReplayDigest
        self.appendOnlyReplayDeterministic = appendOnlyReplayDeterministic
        self.sandboxLifecycleReplayed = sandboxLifecycleReplayed
        self.secretFree = secretFree
        self.rawBrokerPayloadFree = rawBrokerPayloadFree
        self.externalAuditUpload = externalAuditUpload
        self.productionIncidentOps = productionIncidentOps
        self.productionBrokerReplay = productionBrokerReplay
        self.repairCommandProduced = repairCommandProduced
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }
}

/// L4AuditTrailIncidentReplayEvidence 汇总 GH-467 audit trail 和 incident replay evidence。
///
/// Evidence 证明 command intent、risk decision、execution request、broker report、OMS transition 和
/// reconciliation outcome 都能进入本地 append-only audit trail，并从该 trail deterministic replay。它不授权
/// production incident ops、外部审计上传、真实 broker replay 或 Live command surface。
public struct L4AuditTrailIncidentReplayEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let sandboxPathEvidence: L4ExecutionEngineSandboxPathEvidence
    public let reconciliationEvidence: L4OMSBrokerPortfolioReconciliationEvidence
    public let auditTrailEntries: [L4CommandAuditTrailEntry]
    public let replayInput: L4IncidentReplayInput
    public let replayOutput: L4IncidentReplayOutput
    public let forbiddenCapabilities: [L4AuditTrailIncidentReplayForbiddenCapability]
    public let validationAnchors: [String]
    public let commandEvidenceTraceable: Bool
    public let incidentReplayDeterministic: Bool
    public let appendOnlyAuditTrail: Bool
    public let secretAndRawPayloadFree: Bool
    public let externalAuditDisabled: Bool
    public let productionIncidentOpsDisabled: Bool
    public let productionBrokerReplayEnabled: Bool
    public let exposesLiveCommandSurface: Bool

    public var auditTrailReplayEvidenceHeld: Bool {
        issueID.rawValue == "GH-467"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-463", "GH-466"]
            && sandboxPathEvidence.sandboxPathEvidenceHeld
            && reconciliationEvidence.reconciliationEvidenceHeld
            && auditTrailEntries.isEmpty == false
            && auditTrailEntries.allSatisfy(\.entryBoundaryHeld)
            && L4IncidentReplayInput.sequencesAreContiguous(auditTrailEntries)
            && Set(auditTrailEntries.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases)
            && Set(auditTrailEntries.map(\.stage)) == Set(L4AuditTrailIncidentReplayStage.allCases)
            && Set(auditTrailEntries.compactMap(\.reconciliationStatus)) == Set(L4OMSBrokerPortfolioReconciliationStatus.allCases)
            && replayInput.inputBoundaryHeld
            && replayOutput.outputBoundaryHeld
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && commandEvidenceTraceable
            && incidentReplayDeterministic
            && appendOnlyAuditTrail
            && secretAndRawPayloadFree
            && externalAuditDisabled
            && productionIncidentOpsDisabled
            && productionBrokerReplayEnabled == false
            && exposesLiveCommandSurface == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-467-audit-trail-incident-replay-evidence"),
        issueID: Identifier = Identifier.constant("GH-467"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-463"),
            Identifier.constant("GH-466")
        ],
        sandboxPathEvidence: L4ExecutionEngineSandboxPathEvidence,
        reconciliationEvidence: L4OMSBrokerPortfolioReconciliationEvidence,
        auditTrailEntries: [L4CommandAuditTrailEntry],
        replayInput: L4IncidentReplayInput,
        replayOutput: L4IncidentReplayOutput,
        forbiddenCapabilities: [L4AuditTrailIncidentReplayForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        commandEvidenceTraceable: Bool = true,
        incidentReplayDeterministic: Bool = true,
        appendOnlyAuditTrail: Bool = true,
        secretAndRawPayloadFree: Bool = true,
        externalAuditDisabled: Bool = true,
        productionIncidentOpsDisabled: Bool = true,
        productionBrokerReplayEnabled: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-467" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-467",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-463", "GH-466"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-463,GH-466",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard sandboxPathEvidence.sandboxPathEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxPathEvidence",
                expected: "GH-463 sandbox path evidence held",
                actual: "mismatch"
            )
        }
        guard reconciliationEvidence.reconciliationEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "reconciliationEvidence",
                expected: "GH-466 reconciliation evidence held",
                actual: "mismatch"
            )
        }
        guard auditTrailEntries.isEmpty == false && auditTrailEntries.allSatisfy(\.entryBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "auditTrailEntries",
                expected: "non-empty GH-467 audit trail entries",
                actual: "mismatch"
            )
        }
        guard L4IncidentReplayInput.sequencesAreContiguous(auditTrailEntries) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "auditTrailEntries.sequence",
                expected: L4IncidentReplayInput.expectedSequenceDigest(count: auditTrailEntries.count),
                actual: auditTrailEntries.map { "\($0.sequence)" }.joined(separator: ",")
            )
        }
        guard Set(auditTrailEntries.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "auditTrailEntries.commandKind",
                expected: L4ExecutionClientSandboxCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: Set(auditTrailEntries.map(\.commandKind)).map(\.rawValue).sorted().joined(separator: ",")
            )
        }
        guard Set(auditTrailEntries.map(\.stage)) == Set(L4AuditTrailIncidentReplayStage.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "auditTrailEntries.stage",
                expected: L4AuditTrailIncidentReplayStage.allCases.map(\.rawValue).joined(separator: ","),
                actual: Set(auditTrailEntries.map(\.stage)).map(\.rawValue).sorted().joined(separator: ",")
            )
        }
        guard Set(auditTrailEntries.compactMap(\.reconciliationStatus)) == Set(L4OMSBrokerPortfolioReconciliationStatus.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "auditTrailEntries.reconciliationStatus",
                expected: L4OMSBrokerPortfolioReconciliationStatus.allCases.map(\.rawValue).joined(separator: ","),
                actual: Set(auditTrailEntries.compactMap(\.reconciliationStatus)).map(\.rawValue).sorted().joined(separator: ",")
            )
        }
        guard replayInput.inputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayInput",
                expected: "GH-467 replay input boundary held",
                actual: "mismatch"
            )
        }
        guard replayOutput.outputBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "replayOutput",
                expected: "GH-467 replay output boundary held",
                actual: "mismatch"
            )
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
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
        for requiredFlag in [
            ("commandEvidenceTraceable", commandEvidenceTraceable),
            ("incidentReplayDeterministic", incidentReplayDeterministic),
            ("appendOnlyAuditTrail", appendOnlyAuditTrail),
            ("secretAndRawPayloadFree", secretAndRawPayloadFree),
            ("externalAuditDisabled", externalAuditDisabled),
            ("productionIncidentOpsDisabled", productionIncidentOpsDisabled)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryForbiddenCapability(requiredFlag.0)
        }
        for forbiddenFlag in [
            ("productionBrokerReplayEnabled", productionBrokerReplayEnabled),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.sandboxPathEvidence = sandboxPathEvidence
        self.reconciliationEvidence = reconciliationEvidence
        self.auditTrailEntries = auditTrailEntries
        self.replayInput = replayInput
        self.replayOutput = replayOutput
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.commandEvidenceTraceable = commandEvidenceTraceable
        self.incidentReplayDeterministic = incidentReplayDeterministic
        self.appendOnlyAuditTrail = appendOnlyAuditTrail
        self.secretAndRawPayloadFree = secretAndRawPayloadFree
        self.externalAuditDisabled = externalAuditDisabled
        self.productionIncidentOpsDisabled = productionIncidentOpsDisabled
        self.productionBrokerReplayEnabled = productionBrokerReplayEnabled
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static let requiredForbiddenCapabilities = L4AuditTrailIncidentReplayForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-467-AUDIT-TRAIL-INCIDENT-REPLAY",
        "GH-467-COMMAND-EVIDENCE-TRACE",
        "GH-467-APPEND-ONLY-AUDIT-TRAIL",
        "GH-467-DETERMINISTIC-INCIDENT-REPLAY",
        "GH-467-NO-SECRET-RAW-PAYLOAD",
        "TVM-L4-AUDIT-TRAIL-INCIDENT-REPLAY"
    ]
}

/// L4AuditTrailIncidentReplayRuntime 生成 GH-467 local audit trail / replay evidence。
///
/// Runtime 名称只表示本地 evidence builder；它不启用 production incident ops，不读取 secret，不消费 raw broker
/// payload，不上传外部审计系统，不调用 ExecutionClient，也不触碰 broker gateway。
public struct L4AuditTrailIncidentReplayRuntime: Codable, Equatable, Sendable {
    public let runtimeID: Identifier
    public let sandboxPathEvidence: L4ExecutionEngineSandboxPathEvidence
    public let reconciliationEvidence: L4OMSBrokerPortfolioReconciliationEvidence
    public let externalAuditUploadEnabled: Bool
    public let productionIncidentOpsEnabled: Bool
    public let productionBrokerReplayEnabled: Bool
    public let capturesSecret: Bool
    public let capturesRawBrokerPayload: Bool
    public let mutableAuditTrail: Bool
    public let callsExecutionClient: Bool
    public let touchesBrokerGateway: Bool
    public let exposesLiveCommandSurface: Bool

    public var runtimeBoundaryHeld: Bool {
        sandboxPathEvidence.sandboxPathEvidenceHeld
            && reconciliationEvidence.reconciliationEvidenceHeld
            && externalAuditUploadEnabled == false
            && productionIncidentOpsEnabled == false
            && productionBrokerReplayEnabled == false
            && capturesSecret == false
            && capturesRawBrokerPayload == false
            && mutableAuditTrail == false
            && callsExecutionClient == false
            && touchesBrokerGateway == false
            && exposesLiveCommandSurface == false
    }

    public init(
        runtimeID: Identifier = Identifier.constant("gh-467-audit-trail-incident-replay-runtime"),
        sandboxPathEvidence: L4ExecutionEngineSandboxPathEvidence? = nil,
        reconciliationEvidence: L4OMSBrokerPortfolioReconciliationEvidence? = nil,
        externalAuditUploadEnabled: Bool = false,
        productionIncidentOpsEnabled: Bool = false,
        productionBrokerReplayEnabled: Bool = false,
        capturesSecret: Bool = false,
        capturesRawBrokerPayload: Bool = false,
        mutableAuditTrail: Bool = false,
        callsExecutionClient: Bool = false,
        touchesBrokerGateway: Bool = false,
        exposesLiveCommandSurface: Bool = false
    ) throws {
        let resolvedSandboxPathEvidence = try sandboxPathEvidence
            ?? L4ExecutionEngineSandboxPathCoordinator.deterministicFixture().deterministicEvidence()
        let resolvedReconciliationEvidence = try reconciliationEvidence
            ?? L4OMSBrokerPortfolioReconciliationRuntime().deterministicEvidence()
        guard resolvedSandboxPathEvidence.sandboxPathEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxPathEvidence",
                expected: "GH-463 sandbox path evidence held",
                actual: "mismatch"
            )
        }
        guard resolvedReconciliationEvidence.reconciliationEvidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "reconciliationEvidence",
                expected: "GH-466 reconciliation evidence held",
                actual: "mismatch"
            )
        }
        for forbiddenFlag in [
            ("externalAuditUploadEnabled", externalAuditUploadEnabled),
            ("productionIncidentOpsEnabled", productionIncidentOpsEnabled),
            ("productionBrokerReplayEnabled", productionBrokerReplayEnabled),
            ("capturesSecret", capturesSecret),
            ("capturesRawBrokerPayload", capturesRawBrokerPayload),
            ("mutableAuditTrail", mutableAuditTrail),
            ("callsExecutionClient", callsExecutionClient),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("exposesLiveCommandSurface", exposesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.runtimeID = runtimeID
        self.sandboxPathEvidence = resolvedSandboxPathEvidence
        self.reconciliationEvidence = resolvedReconciliationEvidence
        self.externalAuditUploadEnabled = externalAuditUploadEnabled
        self.productionIncidentOpsEnabled = productionIncidentOpsEnabled
        self.productionBrokerReplayEnabled = productionBrokerReplayEnabled
        self.capturesSecret = capturesSecret
        self.capturesRawBrokerPayload = capturesRawBrokerPayload
        self.mutableAuditTrail = mutableAuditTrail
        self.callsExecutionClient = callsExecutionClient
        self.touchesBrokerGateway = touchesBrokerGateway
        self.exposesLiveCommandSurface = exposesLiveCommandSurface
    }

    public static func deterministicFixture() throws -> L4AuditTrailIncidentReplayRuntime {
        try L4AuditTrailIncidentReplayRuntime()
    }

    public func deterministicEvidence() throws -> L4AuditTrailIncidentReplayEvidence {
        guard runtimeBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "runtimeBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        let entries = try makeAuditTrailEntries()
        let replayInput = try L4IncidentReplayInput(
            entries: entries,
            deterministicInputDigest: digest(prefix: "input", entries: entries)
        )
        let replayOutput = try L4IncidentReplayOutput(
            inputID: replayInput.inputID,
            incidentID: replayInput.incidentID,
            replayedEntries: entries,
            replayedCommandKinds: L4ExecutionClientSandboxCommandKind.allCases,
            replayedStages: L4AuditTrailIncidentReplayStage.allCases,
            replayedReconciliationStatuses: L4OMSBrokerPortfolioReconciliationStatus.allCases,
            deterministicReplayDigest: digest(prefix: "replay", entries: entries)
        )
        return try L4AuditTrailIncidentReplayEvidence(
            sandboxPathEvidence: sandboxPathEvidence,
            reconciliationEvidence: reconciliationEvidence,
            auditTrailEntries: entries,
            replayInput: replayInput,
            replayOutput: replayOutput
        )
    }

    private func makeAuditTrailEntries() throws -> [L4CommandAuditTrailEntry] {
        var entries: [L4CommandAuditTrailEntry] = []
        for record in reconciliationEvidence.records {
            let commandKind = commandKind(for: record.path)
            let proposal = try proposal(for: commandKind)
            let response = try response(for: commandKind)
            for stage in L4AuditTrailIncidentReplayStage.allCases {
                let sequence = entries.count + 1
                entries.append(
                    try makeEntry(
                        sequence: sequence,
                        stage: stage,
                        commandKind: commandKind,
                        proposal: proposal,
                        response: response,
                        record: record
                    )
                )
            }
        }
        return entries
    }

    private func makeEntry(
        sequence: Int,
        stage: L4AuditTrailIncidentReplayStage,
        commandKind: L4ExecutionClientSandboxCommandKind,
        proposal: L4ExecutionEngineSandboxCommandProposal,
        response: L4ExecutionClientSandboxCommandResponse,
        record: L4OMSBrokerPortfolioReconciliationRecord
    ) throws -> L4CommandAuditTrailEntry {
        try L4CommandAuditTrailEntry(
            entryID: Identifier.constant("gh-467-\(sequence)-\(commandKind.rawValue)-\(stage.rawValue)-audit-entry"),
            commandKind: commandKind,
            stage: stage,
            sequence: sequence,
            commandIntentID: proposal.proposalID,
            riskDecisionID: proposal.riskEngineDecisionID,
            executionRequestID: response.requestEnvelopeID,
            brokerReportEventID: stage == .brokerReport ? record.brokerReportEvent?.eventID : nil,
            omsTransitionID: stage == .omsTransition ? record.omsTransition.transitionID : nil,
            reconciliationRecordID: stage == .reconciliationOutcome ? record.recordID : nil,
            reconciliationStatus: stage == .reconciliationOutcome ? record.status : nil,
            deterministicPayloadDigest: digest(
                prefix: "entry-\(sequence)-\(stage.rawValue)",
                commandKind: commandKind,
                record: record
            )
        )
    }

    private func commandKind(
        for path: L4OMSBrokerPortfolioReconciliationPath
    ) -> L4ExecutionClientSandboxCommandKind {
        switch path {
        case .fill, .partialFill:
            .submit
        case .cancel:
            .cancel
        case .reject:
            .replace
        }
    }

    private func proposal(
        for commandKind: L4ExecutionClientSandboxCommandKind
    ) throws -> L4ExecutionEngineSandboxCommandProposal {
        guard let proposal = sandboxPathEvidence.proposals.first(where: { $0.commandKind == commandKind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "proposal",
                expected: commandKind.rawValue,
                actual: sandboxPathEvidence.proposals.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        return proposal
    }

    private func response(
        for commandKind: L4ExecutionClientSandboxCommandKind
    ) throws -> L4ExecutionClientSandboxCommandResponse {
        guard let response = sandboxPathEvidence.responses.first(where: { $0.commandKind == commandKind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "response",
                expected: commandKind.rawValue,
                actual: sandboxPathEvidence.responses.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        return response
    }

    private func digest(prefix: String, entries: [L4CommandAuditTrailEntry]) -> String {
        let sequenceDigest = entries.map { "\($0.sequence):\($0.commandKind.rawValue):\($0.stage.rawValue)" }
            .joined(separator: "|")
        return "GH-467:\(prefix):\(sequenceDigest)"
    }

    private func digest(
        prefix: String,
        commandKind: L4ExecutionClientSandboxCommandKind,
        record: L4OMSBrokerPortfolioReconciliationRecord
    ) -> String {
        [
            "GH-467",
            prefix,
            commandKind.rawValue,
            record.path.rawValue,
            record.status.rawValue,
            record.recordID.rawValue
        ].joined(separator: ":")
    }
}
