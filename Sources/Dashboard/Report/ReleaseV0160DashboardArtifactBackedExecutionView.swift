import Foundation

// GH-1108 static contract boundary:
// dashboardArtifactBackedExecutionView=ReleaseV0160DashboardArtifactBackedExecutionViewModel
// localArtifactBackedRows=true
// actionSequenceVisible=true
// checksumsVisible=true
// omsReconciliationResultVisible=true
// dashboardCommandSurfaceEnabled=false
// tradingButtonVisible=false
// orderFormVisible=false
// liveCommandVisible=false
// productionTradingEnabledByDefault=false
// productionSecretRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false

/// ReleaseV0160DashboardArtifactBackedExecutionAction 固定 #1108 Dashboard 可展示的本地 artifact 动作序列。
///
/// 这些 action 只来自 #1106 append-only artifact store 和 #1107 OMS observed-status reconciliation
/// report。Dashboard 只能展示它们，不能把 action label 解释成 submit / cancel / status command。
public enum ReleaseV0160DashboardArtifactBackedExecutionAction:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case submit
    case cancel
    case status
}

/// ReleaseV0160DashboardArtifactBackedExecutionInput 是 #1108 的只读本地 artifact 摘要。
///
/// 输入把 operator run、manifest checksum、artifact record、action sequence 和 #1107 reconciliation
/// result 收敛成 Dashboard read model。它不保存 credential value、raw order id、broker payload 或 endpoint
/// response，也不允许 Dashboard 反向构造交易命令。
public struct ReleaseV0160DashboardArtifactBackedExecutionInput:
    Codable,
    Equatable,
    Sendable
{
    public let sourceEvidenceType: String
    public let runID: String
    public let artifactStoreManifestID: String
    public let artifactStoreManifestChecksum: String
    public let artifactRecordIDs: [String]
    public let artifactRecordChecksums: [String]
    public let artifactRelativePaths: [String]
    public let actionSequence: [ReleaseV0160DashboardArtifactBackedExecutionAction]
    public let reconciliationReportID: String
    public let reconciliationStatus: String
    public let observedStatus: String
    public let failureReasons: [String]
    public let venueName: String
    public let executionProductScope: String
    public let localArtifactBackedRows: Bool
    public let actionSequenceVisible: Bool
    public let checksumsVisible: Bool
    public let omsReconciliationResultVisible: Bool
    public let redactedEvidenceOnly: Bool
    public let readModelArtifactOnly: Bool
    public let testnetEvidenceOnly: Bool

    public var inputHeld: Bool {
        sourceEvidenceType == "ReleaseV0160DashboardArtifactBackedExecutionReadModel"
            && runID.isEmpty == false
            && artifactStoreManifestID.isEmpty == false
            && Self.isValidSHA256Reference(artifactStoreManifestChecksum)
            && artifactRecordIDs.count == ReleaseV0160DashboardArtifactBackedExecutionAction.allCases.count
            && artifactRecordIDs.allSatisfy { $0.isEmpty == false }
            && artifactRecordChecksums.count == artifactRecordIDs.count
            && artifactRecordChecksums.allSatisfy(Self.isValidSHA256Reference)
            && artifactRelativePaths.count == artifactRecordIDs.count
            && artifactRelativePaths.allSatisfy(Self.isSafeLocalArtifactPath)
            && actionSequence == ReleaseV0160DashboardArtifactBackedExecutionAction.allCases
            && reconciliationReportID.isEmpty == false
            && ["passed", "failed"].contains(reconciliationStatus)
            && observedStatus.isEmpty == false
            && failureReasons.isEmpty == false
            && venueName == "Binance"
            && executionProductScope == "Binance Spot Testnet"
            && localArtifactBackedRows
            && actionSequenceVisible
            && checksumsVisible
            && omsReconciliationResultVisible
            && redactedEvidenceOnly
            && readModelArtifactOnly
            && testnetEvidenceOnly
    }

    public init(
        sourceEvidenceType: String = "ReleaseV0160DashboardArtifactBackedExecutionReadModel",
        runID: String = "gh-1108-v0160-operator-run",
        artifactStoreManifestID: String = "gh-1106-v0160-local-execution-artifact-manifest",
        artifactStoreManifestChecksum: String =
            "sha256:abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
        artifactRecordIDs: [String] = [
            "gh-1106-v0160-submit-artifact-record",
            "gh-1106-v0160-cancel-artifact-record",
            "gh-1106-v0160-status-artifact-record"
        ],
        artifactRecordChecksums: [String] = [
            "sha256:1111111111111111111111111111111111111111111111111111111111111111",
            "sha256:2222222222222222222222222222222222222222222222222222222222222222",
            "sha256:3333333333333333333333333333333333333333333333333333333333333333"
        ],
        artifactRelativePaths: [String] = [
            ".local/mtpro/v0.16.0/operator-runs/gh-1108-v0160-operator-run/artifacts/001-submit.json",
            ".local/mtpro/v0.16.0/operator-runs/gh-1108-v0160-operator-run/artifacts/002-cancel.json",
            ".local/mtpro/v0.16.0/operator-runs/gh-1108-v0160-operator-run/artifacts/003-status.json"
        ],
        actionSequence: [ReleaseV0160DashboardArtifactBackedExecutionAction] =
            ReleaseV0160DashboardArtifactBackedExecutionAction.allCases,
        reconciliationReportID: String = "gh-1107-v0160-oms-observed-status-reconciliation-report",
        reconciliationStatus: String = "passed",
        observedStatus: String = "CANCELED",
        failureReasons: [String] = ["none"],
        venueName: String = "Binance",
        executionProductScope: String = "Binance Spot Testnet",
        localArtifactBackedRows: Bool = true,
        actionSequenceVisible: Bool = true,
        checksumsVisible: Bool = true,
        omsReconciliationResultVisible: Bool = true,
        redactedEvidenceOnly: Bool = true,
        readModelArtifactOnly: Bool = true,
        testnetEvidenceOnly: Bool = true
    ) {
        self.sourceEvidenceType = sourceEvidenceType
        self.runID = runID
        self.artifactStoreManifestID = artifactStoreManifestID
        self.artifactStoreManifestChecksum = artifactStoreManifestChecksum
        self.artifactRecordIDs = artifactRecordIDs
        self.artifactRecordChecksums = artifactRecordChecksums
        self.artifactRelativePaths = artifactRelativePaths
        self.actionSequence = actionSequence
        self.reconciliationReportID = reconciliationReportID
        self.reconciliationStatus = reconciliationStatus
        self.observedStatus = observedStatus
        self.failureReasons = failureReasons
        self.venueName = venueName
        self.executionProductScope = executionProductScope
        self.localArtifactBackedRows = localArtifactBackedRows
        self.actionSequenceVisible = actionSequenceVisible
        self.checksumsVisible = checksumsVisible
        self.omsReconciliationResultVisible = omsReconciliationResultVisible
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.readModelArtifactOnly = readModelArtifactOnly
        self.testnetEvidenceOnly = testnetEvidenceOnly
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            sourceEvidenceType: try container.decode(String.self, forKey: .sourceEvidenceType),
            runID: try container.decode(String.self, forKey: .runID),
            artifactStoreManifestID: try container.decode(String.self, forKey: .artifactStoreManifestID),
            artifactStoreManifestChecksum: try container.decode(String.self, forKey: .artifactStoreManifestChecksum),
            artifactRecordIDs: try container.decode([String].self, forKey: .artifactRecordIDs),
            artifactRecordChecksums: try container.decode([String].self, forKey: .artifactRecordChecksums),
            artifactRelativePaths: try container.decode([String].self, forKey: .artifactRelativePaths),
            actionSequence: try container.decode(
                [ReleaseV0160DashboardArtifactBackedExecutionAction].self,
                forKey: .actionSequence
            ),
            reconciliationReportID: try container.decode(String.self, forKey: .reconciliationReportID),
            reconciliationStatus: try container.decode(String.self, forKey: .reconciliationStatus),
            observedStatus: try container.decode(String.self, forKey: .observedStatus),
            failureReasons: try container.decode([String].self, forKey: .failureReasons),
            venueName: try container.decode(String.self, forKey: .venueName),
            executionProductScope: try container.decode(String.self, forKey: .executionProductScope),
            localArtifactBackedRows: try container.decode(Bool.self, forKey: .localArtifactBackedRows),
            actionSequenceVisible: try container.decode(Bool.self, forKey: .actionSequenceVisible),
            checksumsVisible: try container.decode(Bool.self, forKey: .checksumsVisible),
            omsReconciliationResultVisible: try container.decode(
                Bool.self,
                forKey: .omsReconciliationResultVisible
            ),
            redactedEvidenceOnly: try container.decode(Bool.self, forKey: .redactedEvidenceOnly),
            readModelArtifactOnly: try container.decode(Bool.self, forKey: .readModelArtifactOnly),
            testnetEvidenceOnly: try container.decode(Bool.self, forKey: .testnetEvidenceOnly)
        )
        try Self.requireDecodedBoundary(inputHeld, field: "inputHeld", codingPath: decoder.codingPath)
    }

    public static func isValidSHA256Reference(_ value: String) -> Bool {
        let prefix = "sha256:"
        guard value.hasPrefix(prefix) else { return false }
        let digest = value.dropFirst(prefix.count)
        return digest.count == 64 && digest.allSatisfy { character in
            character.isNumber || ("a"..."f").contains(character)
        }
    }

    public static func isSafeLocalArtifactPath(_ value: String) -> Bool {
        value.hasPrefix(".local/mtpro/v0.16.0/operator-runs/")
            && value.contains("..") == false
            && value.contains("//") == false
            && value.hasSuffix(".json")
    }

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "ReleaseV0160DashboardArtifactBackedExecutionInput decode validation failed: \(field)"
                )
            )
        }
    }
}

/// ReleaseV0160DashboardArtifactBackedExecutionRow 是 #1108 Dashboard 的只读 artifact 行。
public struct ReleaseV0160DashboardArtifactBackedExecutionRow:
    Codable,
    Equatable,
    Sendable
{
    public let action: ReleaseV0160DashboardArtifactBackedExecutionAction
    public let sequence: Int
    public let artifactRecordID: String
    public let artifactChecksum: String
    public let artifactRelativePath: String
    public let displayStatus: String
    public let reconciliationReportID: String
    public let visibleInDashboard: Bool
    public let readOnly: Bool
    public let commandHandlerBound: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let submitCancelReplaceEnabled: Bool

    public var rowHeld: Bool {
        sequence > 0
            && artifactRecordID.isEmpty == false
            && ReleaseV0160DashboardArtifactBackedExecutionInput.isValidSHA256Reference(artifactChecksum)
            && ReleaseV0160DashboardArtifactBackedExecutionInput.isSafeLocalArtifactPath(artifactRelativePath)
            && displayStatus == "artifact-backed-visible"
            && reconciliationReportID.isEmpty == false
            && visibleInDashboard
            && readOnly
            && commandHandlerBound == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && submitCancelReplaceEnabled == false
    }

    public init(
        action: ReleaseV0160DashboardArtifactBackedExecutionAction,
        sequence: Int,
        artifactRecordID: String,
        artifactChecksum: String,
        artifactRelativePath: String,
        reconciliationReportID: String,
        displayStatus: String = "artifact-backed-visible",
        visibleInDashboard: Bool = true,
        readOnly: Bool = true,
        commandHandlerBound: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false
    ) {
        self.action = action
        self.sequence = sequence
        self.artifactRecordID = artifactRecordID
        self.artifactChecksum = artifactChecksum
        self.artifactRelativePath = artifactRelativePath
        self.reconciliationReportID = reconciliationReportID
        self.displayStatus = displayStatus
        self.visibleInDashboard = visibleInDashboard
        self.readOnly = readOnly
        self.commandHandlerBound = commandHandlerBound
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            action: try container.decode(ReleaseV0160DashboardArtifactBackedExecutionAction.self, forKey: .action),
            sequence: try container.decode(Int.self, forKey: .sequence),
            artifactRecordID: try container.decode(String.self, forKey: .artifactRecordID),
            artifactChecksum: try container.decode(String.self, forKey: .artifactChecksum),
            artifactRelativePath: try container.decode(String.self, forKey: .artifactRelativePath),
            reconciliationReportID: try container.decode(String.self, forKey: .reconciliationReportID),
            displayStatus: try container.decode(String.self, forKey: .displayStatus),
            visibleInDashboard: try container.decode(Bool.self, forKey: .visibleInDashboard),
            readOnly: try container.decode(Bool.self, forKey: .readOnly),
            commandHandlerBound: try container.decode(Bool.self, forKey: .commandHandlerBound),
            tradingButtonVisible: try container.decode(Bool.self, forKey: .tradingButtonVisible),
            orderFormVisible: try container.decode(Bool.self, forKey: .orderFormVisible),
            submitCancelReplaceEnabled: try container.decode(Bool.self, forKey: .submitCancelReplaceEnabled)
        )
        try Self.requireDecodedBoundary(rowHeld, field: "rowHeld", codingPath: decoder.codingPath)
    }

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "ReleaseV0160DashboardArtifactBackedExecutionRow decode validation failed: \(field)"
                )
            )
        }
    }
}

/// ReleaseV0160DashboardArtifactBackedExecutionViewModel 是 #1108 的 Dashboard 只读 execution view。
///
/// Surface 把 #1106 本地 artifact store 和 #1107 reconciliation report 显示为 operator review
/// evidence。它没有 command handler、交易按钮、order form、live command 或 production cutover 标志。
public struct ReleaseV0160DashboardArtifactBackedExecutionViewModel:
    Codable,
    Equatable,
    Sendable
{
    public let issueID: String
    public let upstreamIssueIDs: [String]
    public let previousIssueID: String
    public let releaseVersion: String
    public let source: ViewModelSourceContract
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let input: ReleaseV0160DashboardArtifactBackedExecutionInput
    public let rows: [ReleaseV0160DashboardArtifactBackedExecutionRow]
    public let localArtifactBackedRowsVisible: Bool
    public let actionSequenceVisible: Bool
    public let checksumsVisible: Bool
    public let omsReconciliationResultVisible: Bool
    public let readOnly: Bool
    public let dashboardDependsOnExecutionClientTarget: Bool
    public let dashboardCommandSurfaceEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let submitCancelReplaceEnabled: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    private enum CodingKeys: String, CodingKey {
        case issueID
        case upstreamIssueIDs
        case previousIssueID
        case releaseVersion
        case source
        case validationAnchors
        case requiredValidationCommands
        case input
        case rows
        case localArtifactBackedRowsVisible
        case actionSequenceVisible
        case checksumsVisible
        case omsReconciliationResultVisible
        case readOnly
        case dashboardDependsOnExecutionClientTarget
        case dashboardCommandSurfaceEnabled
        case tradingButtonVisible
        case orderFormVisible
        case liveCommandVisible
        case submitCancelReplaceEnabled
        case productionTradingEnabledByDefault
        case productionSecretRead
        case productionEndpointConnected
        case brokerEndpointConnected
        case productionSubmitCancelReplaceEnabled
        case productionCutoverAuthorized
        case boundaryHeld
    }

    public var boundaryHeld: Bool {
        source.isReadModelOnly
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && input.inputHeld
            && rows.count == input.actionSequence.count
            && rows.map(\.action) == input.actionSequence
            && rows.map(\.sequence) == Array(1...input.actionSequence.count)
            && rows.map(\.artifactRecordID) == input.artifactRecordIDs
            && rows.map(\.artifactChecksum) == input.artifactRecordChecksums
            && rows.map(\.artifactRelativePath) == input.artifactRelativePaths
            && rows.allSatisfy(\.rowHeld)
            && localArtifactBackedRowsVisible
            && actionSequenceVisible
            && checksumsVisible
            && omsReconciliationResultVisible
            && readOnly
            && dashboardDependsOnExecutionClientTarget == false
            && dashboardCommandSurfaceEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && submitCancelReplaceEnabled == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public var visibleRowCount: Int {
        rows.count
    }

    public var actionLabels: [String] {
        rows.map(\.action.rawValue)
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.16 artifact rows", value: "\(visibleRowCount)"),
            DashboardShellMetric(label: "v0.16 action sequence", value: actionLabels.joined(separator: ",")),
            DashboardShellMetric(label: "v0.16 reconciliation", value: input.reconciliationStatus),
            DashboardShellMetric(label: "v0.16 checksum count", value: "\(input.artifactRecordChecksums.count)"),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Run ID: \(input.runID)",
            "Manifest: \(input.artifactStoreManifestID)",
            "Manifest checksum: \(input.artifactStoreManifestChecksum)",
            "Action sequence: \(actionLabels.joined(separator: ", "))",
            "Artifact records: \(rows.map(\.artifactRecordID).joined(separator: ", "))",
            "Artifact checksums: \(rows.map(\.artifactChecksum).joined(separator: ", "))",
            "Artifact paths: \(rows.map(\.artifactRelativePath).joined(separator: ", "))",
            "OMS reconciliation report: \(input.reconciliationReportID)",
            "OMS reconciliation state: \(input.reconciliationStatus)",
            "Observed status: \(input.observedStatus)",
            "Failure reasons: \(input.failureReasons.joined(separator: ", "))",
            "Dashboard command surface: none",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Submit / cancel / replace: none",
            "Production endpoint: none",
            "Production boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        issueID: String = "GH-1108",
        upstreamIssueIDs: [String] = ["GH-1106", "GH-1107"],
        previousIssueID: String = "GH-1107",
        releaseVersion: String = "v0.16.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        input: ReleaseV0160DashboardArtifactBackedExecutionInput =
            ReleaseV0160DashboardArtifactBackedExecutionInput(),
        rows: [ReleaseV0160DashboardArtifactBackedExecutionRow] = Self.defaultRows,
        localArtifactBackedRowsVisible: Bool = true,
        actionSequenceVisible: Bool = true,
        checksumsVisible: Bool = true,
        omsReconciliationResultVisible: Bool = true,
        readOnly: Bool = true,
        dashboardDependsOnExecutionClientTarget: Bool = false,
        dashboardCommandSurfaceEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.releaseVersion = releaseVersion
        self.source = source
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.input = input
        self.rows = rows
        self.localArtifactBackedRowsVisible = localArtifactBackedRowsVisible
        self.actionSequenceVisible = actionSequenceVisible
        self.checksumsVisible = checksumsVisible
        self.omsReconciliationResultVisible = omsReconciliationResultVisible
        self.readOnly = readOnly
        self.dashboardDependsOnExecutionClientTarget = dashboardDependsOnExecutionClientTarget
        self.dashboardCommandSurfaceEnabled = dashboardCommandSurfaceEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionSubmitCancelReplaceEnabled = productionSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedBoundaryHeld = try container.decodeIfPresent(Bool.self, forKey: .boundaryHeld)
        self.init(
            issueID: try container.decode(String.self, forKey: .issueID),
            upstreamIssueIDs: try container.decode([String].self, forKey: .upstreamIssueIDs),
            previousIssueID: try container.decode(String.self, forKey: .previousIssueID),
            releaseVersion: try container.decode(String.self, forKey: .releaseVersion),
            source: try container.decode(ViewModelSourceContract.self, forKey: .source),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationCommands: try container.decode([String].self, forKey: .requiredValidationCommands),
            input: try container.decode(ReleaseV0160DashboardArtifactBackedExecutionInput.self, forKey: .input),
            rows: try container.decode([ReleaseV0160DashboardArtifactBackedExecutionRow].self, forKey: .rows),
            localArtifactBackedRowsVisible: try container.decode(Bool.self, forKey: .localArtifactBackedRowsVisible),
            actionSequenceVisible: try container.decode(Bool.self, forKey: .actionSequenceVisible),
            checksumsVisible: try container.decode(Bool.self, forKey: .checksumsVisible),
            omsReconciliationResultVisible: try container.decode(Bool.self, forKey: .omsReconciliationResultVisible),
            readOnly: try container.decode(Bool.self, forKey: .readOnly),
            dashboardDependsOnExecutionClientTarget: try container.decode(
                Bool.self,
                forKey: .dashboardDependsOnExecutionClientTarget
            ),
            dashboardCommandSurfaceEnabled: try container.decode(Bool.self, forKey: .dashboardCommandSurfaceEnabled),
            tradingButtonVisible: try container.decode(Bool.self, forKey: .tradingButtonVisible),
            orderFormVisible: try container.decode(Bool.self, forKey: .orderFormVisible),
            liveCommandVisible: try container.decode(Bool.self, forKey: .liveCommandVisible),
            submitCancelReplaceEnabled: try container.decode(Bool.self, forKey: .submitCancelReplaceEnabled),
            productionTradingEnabledByDefault: try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault),
            productionSecretRead: try container.decode(Bool.self, forKey: .productionSecretRead),
            productionEndpointConnected: try container.decode(Bool.self, forKey: .productionEndpointConnected),
            brokerEndpointConnected: try container.decode(Bool.self, forKey: .brokerEndpointConnected),
            productionSubmitCancelReplaceEnabled: try container.decode(
                Bool.self,
                forKey: .productionSubmitCancelReplaceEnabled
            ),
            productionCutoverAuthorized: try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
        )
        try Self.requireDecodedBoundary(boundaryHeld, field: "boundaryHeld", codingPath: decoder.codingPath)
        if let decodedBoundaryHeld, decodedBoundaryHeld != boundaryHeld {
            try Self.requireDecodedBoundary(false, field: "boundaryHeld payload mismatch", codingPath: decoder.codingPath)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(issueID, forKey: .issueID)
        try container.encode(upstreamIssueIDs, forKey: .upstreamIssueIDs)
        try container.encode(previousIssueID, forKey: .previousIssueID)
        try container.encode(releaseVersion, forKey: .releaseVersion)
        try container.encode(source, forKey: .source)
        try container.encode(validationAnchors, forKey: .validationAnchors)
        try container.encode(requiredValidationCommands, forKey: .requiredValidationCommands)
        try container.encode(input, forKey: .input)
        try container.encode(rows, forKey: .rows)
        try container.encode(localArtifactBackedRowsVisible, forKey: .localArtifactBackedRowsVisible)
        try container.encode(actionSequenceVisible, forKey: .actionSequenceVisible)
        try container.encode(checksumsVisible, forKey: .checksumsVisible)
        try container.encode(omsReconciliationResultVisible, forKey: .omsReconciliationResultVisible)
        try container.encode(readOnly, forKey: .readOnly)
        try container.encode(dashboardDependsOnExecutionClientTarget, forKey: .dashboardDependsOnExecutionClientTarget)
        try container.encode(dashboardCommandSurfaceEnabled, forKey: .dashboardCommandSurfaceEnabled)
        try container.encode(tradingButtonVisible, forKey: .tradingButtonVisible)
        try container.encode(orderFormVisible, forKey: .orderFormVisible)
        try container.encode(liveCommandVisible, forKey: .liveCommandVisible)
        try container.encode(submitCancelReplaceEnabled, forKey: .submitCancelReplaceEnabled)
        try container.encode(productionTradingEnabledByDefault, forKey: .productionTradingEnabledByDefault)
        try container.encode(productionSecretRead, forKey: .productionSecretRead)
        try container.encode(productionEndpointConnected, forKey: .productionEndpointConnected)
        try container.encode(brokerEndpointConnected, forKey: .brokerEndpointConnected)
        try container.encode(productionSubmitCancelReplaceEnabled, forKey: .productionSubmitCancelReplaceEnabled)
        try container.encode(productionCutoverAuthorized, forKey: .productionCutoverAuthorized)
        try container.encode(boundaryHeld, forKey: .boundaryHeld)
    }

    public static func localReadModelArtifactInput(
        fromJSON data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> ReleaseV0160DashboardArtifactBackedExecutionLocalArtifactInput {
        try decoder.decode(ReleaseV0160DashboardArtifactBackedExecutionLocalArtifactInput.self, from: data)
    }

    public static func localReadModelArtifact(
        fromJSON data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> ReleaseV0160DashboardArtifactBackedExecutionViewModel {
        try localReadModelArtifactInput(fromJSON: data, decoder: decoder).surface
    }

    public static var deterministicFixture: ReleaseV0160DashboardArtifactBackedExecutionViewModel {
        ReleaseV0160DashboardArtifactBackedExecutionViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-1108-VERIFY-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW",
        "TVM-RELEASE-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW",
        "V0160-008-LOCAL-ARTIFACT-BACKED-ROWS",
        "V0160-008-ACTION-SEQUENCE-VISIBLE",
        "V0160-008-CHECKSUMS-VISIBLE",
        "V0160-008-OMS-RECONCILIATION-RESULT-VISIBLE",
        "V0160-008-DASHBOARD-READ-ONLY-NO-COMMANDS",
        "V0160-008-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH1108DashboardArtifactBackedExecutionViewShowsLocalArtifactsWithoutCommands",
        "swift test --filter TargetGraphTests/testGH1108DashboardArtifactBackedExecutionViewIsAnchoredInV0160Guards",
        "bash checks/verify-v0.16.0-dashboard-artifact-backed-execution-view.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultRows = [
        ReleaseV0160DashboardArtifactBackedExecutionRow(
            action: .submit,
            sequence: 1,
            artifactRecordID: "gh-1106-v0160-submit-artifact-record",
            artifactChecksum: "sha256:1111111111111111111111111111111111111111111111111111111111111111",
            artifactRelativePath:
                ".local/mtpro/v0.16.0/operator-runs/gh-1108-v0160-operator-run/artifacts/001-submit.json",
            reconciliationReportID: "gh-1107-v0160-oms-observed-status-reconciliation-report"
        ),
        ReleaseV0160DashboardArtifactBackedExecutionRow(
            action: .cancel,
            sequence: 2,
            artifactRecordID: "gh-1106-v0160-cancel-artifact-record",
            artifactChecksum: "sha256:2222222222222222222222222222222222222222222222222222222222222222",
            artifactRelativePath:
                ".local/mtpro/v0.16.0/operator-runs/gh-1108-v0160-operator-run/artifacts/002-cancel.json",
            reconciliationReportID: "gh-1107-v0160-oms-observed-status-reconciliation-report"
        ),
        ReleaseV0160DashboardArtifactBackedExecutionRow(
            action: .status,
            sequence: 3,
            artifactRecordID: "gh-1106-v0160-status-artifact-record",
            artifactChecksum: "sha256:3333333333333333333333333333333333333333333333333333333333333333",
            artifactRelativePath:
                ".local/mtpro/v0.16.0/operator-runs/gh-1108-v0160-operator-run/artifacts/003-status.json",
            reconciliationReportID: "gh-1107-v0160-oms-observed-status-reconciliation-report"
        )
    ]

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: """
                    ReleaseV0160DashboardArtifactBackedExecutionViewModel decode validation failed: \(field)
                    """
                )
            )
        }
    }
}

/// ReleaseV0160DashboardArtifactBackedExecutionLocalArtifactInput 是 #1108 本地 read-model wrapper。
///
/// Dashboard 必须先验证 wrapper path、checksum、schema 和 boundary flags，再展示内嵌 surface；
/// 任何路径逃逸、checksum 格式错误、production flag 或 command surface 注入都会 fail closed。
public struct ReleaseV0160DashboardArtifactBackedExecutionLocalArtifactInput:
    Codable,
    Equatable,
    Sendable
{
    public let artifactID: String
    public let relativePath: String
    public let schema: String
    public let releaseVersion: String
    public let validationState: String
    public let checksumReference: String
    public let surface: ReleaseV0160DashboardArtifactBackedExecutionViewModel
    public let localReadModelArtifact: Bool
    public let redactedEvidenceOnly: Bool
    public let readOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let submitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public static let schemaID = "release-v0.16.0-dashboard-artifact-backed-execution-view-read-model"

    public static let validationAnchors =
        ReleaseV0160DashboardArtifactBackedExecutionViewModel.requiredValidationAnchors

    public var inputHeld: Bool {
        artifactID.isEmpty == false
            && ReleaseV0160DashboardArtifactBackedExecutionInput.isSafeLocalArtifactPath(relativePath)
            && schema == Self.schemaID
            && releaseVersion == "v0.16.0"
            && validationState == "valid"
            && ReleaseV0160DashboardArtifactBackedExecutionInput.isValidSHA256Reference(checksumReference)
            && surface.boundaryHeld
            && surface.readOnly
            && surface.dashboardCommandSurfaceEnabled == false
            && surface.tradingButtonVisible == false
            && surface.orderFormVisible == false
            && surface.liveCommandVisible == false
            && surface.submitCancelReplaceEnabled == false
            && localReadModelArtifact
            && redactedEvidenceOnly
            && readOnly
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && submitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        artifactID: String = "gh-1108-dashboard-artifact-backed-execution-view",
        relativePath: String =
            ".local/mtpro/v0.16.0/operator-runs/gh-1108-v0160-operator-run/dashboard/execution-view.json",
        schema: String = Self.schemaID,
        releaseVersion: String = "v0.16.0",
        validationState: String = "valid",
        checksumReference: String =
            "sha256:abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
        surface: ReleaseV0160DashboardArtifactBackedExecutionViewModel = .deterministicFixture,
        localReadModelArtifact: Bool = true,
        redactedEvidenceOnly: Bool = true,
        readOnly: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.artifactID = artifactID
        self.relativePath = relativePath
        self.schema = schema
        self.releaseVersion = releaseVersion
        self.validationState = validationState
        self.checksumReference = checksumReference
        self.surface = surface
        self.localReadModelArtifact = localReadModelArtifact
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.readOnly = readOnly
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            artifactID: try container.decode(String.self, forKey: .artifactID),
            relativePath: try container.decode(String.self, forKey: .relativePath),
            schema: try container.decode(String.self, forKey: .schema),
            releaseVersion: try container.decode(String.self, forKey: .releaseVersion),
            validationState: try container.decode(String.self, forKey: .validationState),
            checksumReference: try container.decode(String.self, forKey: .checksumReference),
            surface: try container.decode(ReleaseV0160DashboardArtifactBackedExecutionViewModel.self, forKey: .surface),
            localReadModelArtifact: try container.decode(Bool.self, forKey: .localReadModelArtifact),
            redactedEvidenceOnly: try container.decode(Bool.self, forKey: .redactedEvidenceOnly),
            readOnly: try container.decode(Bool.self, forKey: .readOnly),
            productionTradingEnabledByDefault: try container.decode(Bool.self, forKey: .productionTradingEnabledByDefault),
            productionSecretRead: try container.decode(Bool.self, forKey: .productionSecretRead),
            productionEndpointConnected: try container.decode(Bool.self, forKey: .productionEndpointConnected),
            brokerEndpointConnected: try container.decode(Bool.self, forKey: .brokerEndpointConnected),
            submitCancelReplaceEnabled: try container.decode(Bool.self, forKey: .submitCancelReplaceEnabled),
            productionCutoverAuthorized: try container.decode(Bool.self, forKey: .productionCutoverAuthorized)
        )
        try Self.requireDecodedBoundary(inputHeld, field: "inputHeld", codingPath: decoder.codingPath)
    }

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: """
                    ReleaseV0160DashboardArtifactBackedExecutionLocalArtifactInput decode validation failed: \(field)
                    """
                )
            )
        }
    }
}
