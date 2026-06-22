import Foundation

// GH-1074 static contract boundary:
// dashboardConsumesReadModelArtifactsOnly=true
// submitCancelCancelReplaceStatusVisible=true
// omsStateVisible=true
// reconciliationStateVisible=true
// failureReasonsVisible=true
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

/// ReleaseV0150DashboardTestnetExecutionStatusAction 固定 #1074 Dashboard 可展示的动作状态。
///
/// 这些 action label 只映射已经落仓的 v0.15.0 Spot Testnet evidence；它们不是 Dashboard
/// command handler，也不是 production order path、broker adapter 或 order form。
public enum ReleaseV0150DashboardTestnetExecutionStatusAction:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case submit
    case cancel
    case cancelReplace = "cancel-replace"
}

/// ReleaseV0150DashboardTestnetExecutionStatusInput 是 Dashboard 消费的本地 read-model 摘要。
///
/// 输入只保存 append-only network event log、OMS snapshot、reconciliation report 和 CLI operator
/// evidence 的脱敏 handle。Dashboard 不能从这里反向构造 request、secret、broker payload 或命令。
public struct ReleaseV0150DashboardTestnetExecutionStatusInput:
    Codable,
    Equatable,
    Sendable
{
    public let sourceEvidenceType: String
    public let runID: String
    public let networkEventLogID: String
    public let omsSnapshotID: String
    public let reconciliationReportID: String
    public let cliOperatorEvidenceID: String
    public let sourceActionKinds: [ReleaseV0150DashboardTestnetExecutionStatusAction]
    public let sourceEventArtifactIDs: [String]
    public let sourceOMSStateRecordIDs: [String]
    public let reconciliationStatus: String
    public let failureReasons: [String]
    public let venueName: String
    public let executionProductScope: String
    public let redactedEvidenceOnly: Bool
    public let appendOnlyNetworkExecutionEventLog: Bool
    public let readModelArtifactOnly: Bool
    public let testnetEvidenceOnly: Bool
    public let independentlyInspectable: Bool

    public var inputHeld: Bool {
        sourceEvidenceType == "ReleaseV0150DashboardTestnetExecutionStatusReadModel"
            && runID.isEmpty == false
            && networkEventLogID.isEmpty == false
            && omsSnapshotID.isEmpty == false
            && reconciliationReportID.isEmpty == false
            && cliOperatorEvidenceID.isEmpty == false
            && sourceActionKinds == ReleaseV0150DashboardTestnetExecutionStatusAction.allCases
            && sourceEventArtifactIDs.count == sourceActionKinds.count
            && sourceEventArtifactIDs.allSatisfy { $0.isEmpty == false }
            && sourceOMSStateRecordIDs.isEmpty == false
            && reconciliationStatus == "passed"
            && failureReasons == ["none"]
            && venueName == "Binance"
            && executionProductScope == "Binance Spot Testnet"
            && redactedEvidenceOnly
            && appendOnlyNetworkExecutionEventLog
            && readModelArtifactOnly
            && testnetEvidenceOnly
            && independentlyInspectable
    }

    public init(
        sourceEvidenceType: String = "ReleaseV0150DashboardTestnetExecutionStatusReadModel",
        runID: String = "gh-1074-dashboard-testnet-execution-status-run",
        networkEventLogID: String = "gh-1071-v0150-network-execution-event-log",
        omsSnapshotID: String = "gh-1072-v0150-oms-state-snapshot",
        reconciliationReportID: String = "gh-1072-v0150-oms-reconciliation-report",
        cliOperatorEvidenceID: String = "gh-1073-v0150-cli-operator-evidence",
        sourceActionKinds: [ReleaseV0150DashboardTestnetExecutionStatusAction] =
            ReleaseV0150DashboardTestnetExecutionStatusAction.allCases,
        sourceEventArtifactIDs: [String] = [
            "gh-1071-submit-event-artifact",
            "gh-1071-cancel-event-artifact",
            "gh-1071-cancel-replace-event-artifact"
        ],
        sourceOMSStateRecordIDs: [String] = ["gh-1072-oms-state-record"],
        reconciliationStatus: String = "passed",
        failureReasons: [String] = ["none"],
        venueName: String = "Binance",
        executionProductScope: String = "Binance Spot Testnet",
        redactedEvidenceOnly: Bool = true,
        appendOnlyNetworkExecutionEventLog: Bool = true,
        readModelArtifactOnly: Bool = true,
        testnetEvidenceOnly: Bool = true,
        independentlyInspectable: Bool = true
    ) {
        self.sourceEvidenceType = sourceEvidenceType
        self.runID = runID
        self.networkEventLogID = networkEventLogID
        self.omsSnapshotID = omsSnapshotID
        self.reconciliationReportID = reconciliationReportID
        self.cliOperatorEvidenceID = cliOperatorEvidenceID
        self.sourceActionKinds = sourceActionKinds
        self.sourceEventArtifactIDs = sourceEventArtifactIDs
        self.sourceOMSStateRecordIDs = sourceOMSStateRecordIDs
        self.reconciliationStatus = reconciliationStatus
        self.failureReasons = failureReasons
        self.venueName = venueName
        self.executionProductScope = executionProductScope
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.appendOnlyNetworkExecutionEventLog = appendOnlyNetworkExecutionEventLog
        self.readModelArtifactOnly = readModelArtifactOnly
        self.testnetEvidenceOnly = testnetEvidenceOnly
        self.independentlyInspectable = independentlyInspectable
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            sourceEvidenceType: try container.decode(String.self, forKey: .sourceEvidenceType),
            runID: try container.decode(String.self, forKey: .runID),
            networkEventLogID: try container.decode(String.self, forKey: .networkEventLogID),
            omsSnapshotID: try container.decode(String.self, forKey: .omsSnapshotID),
            reconciliationReportID: try container.decode(String.self, forKey: .reconciliationReportID),
            cliOperatorEvidenceID: try container.decode(String.self, forKey: .cliOperatorEvidenceID),
            sourceActionKinds: try container.decode(
                [ReleaseV0150DashboardTestnetExecutionStatusAction].self,
                forKey: .sourceActionKinds
            ),
            sourceEventArtifactIDs: try container.decode([String].self, forKey: .sourceEventArtifactIDs),
            sourceOMSStateRecordIDs: try container.decode([String].self, forKey: .sourceOMSStateRecordIDs),
            reconciliationStatus: try container.decode(String.self, forKey: .reconciliationStatus),
            failureReasons: try container.decode([String].self, forKey: .failureReasons),
            venueName: try container.decode(String.self, forKey: .venueName),
            executionProductScope: try container.decode(String.self, forKey: .executionProductScope),
            redactedEvidenceOnly: try container.decode(Bool.self, forKey: .redactedEvidenceOnly),
            appendOnlyNetworkExecutionEventLog: try container.decode(
                Bool.self,
                forKey: .appendOnlyNetworkExecutionEventLog
            ),
            readModelArtifactOnly: try container.decode(Bool.self, forKey: .readModelArtifactOnly),
            testnetEvidenceOnly: try container.decode(Bool.self, forKey: .testnetEvidenceOnly),
            independentlyInspectable: try container.decode(Bool.self, forKey: .independentlyInspectable)
        )
        try Self.requireDecodedBoundary(inputHeld, field: "inputHeld", codingPath: decoder.codingPath)
    }

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "ReleaseV0150DashboardTestnetExecutionStatusInput decode validation failed: \(field)"
                )
            )
        }
    }
}

/// ReleaseV0150DashboardTestnetExecutionStatusRow 是 #1074 Dashboard 的只读状态行。
public struct ReleaseV0150DashboardTestnetExecutionStatusRow:
    Codable,
    Equatable,
    Sendable
{
    public let action: ReleaseV0150DashboardTestnetExecutionStatusAction
    public let status: String
    public let sourceNetworkEventArtifactID: String
    public let sourceOMSStateRecordID: String
    public let sourceReconciliationReportID: String
    public let failureReason: String
    public let sequence: Int
    public let visibleInDashboard: Bool
    public let readOnly: Bool
    public let commandHandlerBound: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let submitCancelReplaceEnabled: Bool

    public var rowHeld: Bool {
        sequence > 0
            && status == "read-only-visible"
            && sourceNetworkEventArtifactID.isEmpty == false
            && sourceOMSStateRecordID.isEmpty == false
            && sourceReconciliationReportID.isEmpty == false
            && failureReason.isEmpty == false
            && visibleInDashboard
            && readOnly
            && commandHandlerBound == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && submitCancelReplaceEnabled == false
    }

    public init(
        action: ReleaseV0150DashboardTestnetExecutionStatusAction,
        sourceNetworkEventArtifactID: String,
        sourceOMSStateRecordID: String,
        sourceReconciliationReportID: String,
        failureReason: String = "none",
        sequence: Int,
        status: String = "read-only-visible",
        visibleInDashboard: Bool = true,
        readOnly: Bool = true,
        commandHandlerBound: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false
    ) {
        self.action = action
        self.status = status
        self.sourceNetworkEventArtifactID = sourceNetworkEventArtifactID
        self.sourceOMSStateRecordID = sourceOMSStateRecordID
        self.sourceReconciliationReportID = sourceReconciliationReportID
        self.failureReason = failureReason
        self.sequence = sequence
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
            action: try container.decode(ReleaseV0150DashboardTestnetExecutionStatusAction.self, forKey: .action),
            sourceNetworkEventArtifactID: try container.decode(String.self, forKey: .sourceNetworkEventArtifactID),
            sourceOMSStateRecordID: try container.decode(String.self, forKey: .sourceOMSStateRecordID),
            sourceReconciliationReportID: try container.decode(String.self, forKey: .sourceReconciliationReportID),
            failureReason: try container.decode(String.self, forKey: .failureReason),
            sequence: try container.decode(Int.self, forKey: .sequence),
            status: try container.decode(String.self, forKey: .status),
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
                    debugDescription: "ReleaseV0150DashboardTestnetExecutionStatusRow decode validation failed: \(field)"
                )
            )
        }
    }
}

/// ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel 是 #1074 的只读 Dashboard 状态面。
///
/// Surface 只展示 submit / cancel / cancel-replace、OMS state、reconciliation state 和 failure
/// reason evidence。它不包含任何交易按钮、live command、order form 或 submit/cancel/replace handler。
public struct ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel:
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
    public let input: ReleaseV0150DashboardTestnetExecutionStatusInput
    public let rows: [ReleaseV0150DashboardTestnetExecutionStatusRow]
    public let submitStatusVisible: Bool
    public let cancelStatusVisible: Bool
    public let cancelReplaceStatusVisible: Bool
    public let omsStateVisible: Bool
    public let reconciliationStateVisible: Bool
    public let failureReasonsVisible: Bool
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
        case submitStatusVisible
        case cancelStatusVisible
        case cancelReplaceStatusVisible
        case omsStateVisible
        case reconciliationStateVisible
        case failureReasonsVisible
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
            && rows.map(\.action) == ReleaseV0150DashboardTestnetExecutionStatusAction.allCases
            && rows.map(\.sequence) == Array(1...ReleaseV0150DashboardTestnetExecutionStatusAction.allCases.count)
            && rows.allSatisfy(\.rowHeld)
            && submitStatusVisible
            && cancelStatusVisible
            && cancelReplaceStatusVisible
            && omsStateVisible
            && reconciliationStateVisible
            && failureReasonsVisible
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

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.15 execution status rows", value: "\(visibleRowCount)"),
            DashboardShellMetric(label: "v0.15 execution actions", value: actionLabels.joined(separator: ",")),
            DashboardShellMetric(label: "v0.15 OMS state", value: input.omsSnapshotID),
            DashboardShellMetric(label: "v0.15 reconciliation", value: input.reconciliationStatus),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Run ID: \(input.runID)",
            "Network event log: \(input.networkEventLogID)",
            "OMS snapshot: \(input.omsSnapshotID)",
            "Reconciliation report: \(input.reconciliationReportID)",
            "CLI operator evidence: \(input.cliOperatorEvidenceID)",
            "Actions: \(actionLabels.joined(separator: ", "))",
            "Event artifacts: \(rows.map(\.sourceNetworkEventArtifactID).joined(separator: ", "))",
            "OMS records: \(input.sourceOMSStateRecordIDs.joined(separator: ", "))",
            "Reconciliation state: \(input.reconciliationStatus)",
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

    public var actionLabels: [String] {
        rows.map(\.action.rawValue)
    }

    public init(
        issueID: String = "GH-1074",
        upstreamIssueIDs: [String] = ["GH-1072", "GH-1073"],
        previousIssueID: String = "GH-1073",
        releaseVersion: String = "v0.15.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        input: ReleaseV0150DashboardTestnetExecutionStatusInput =
            ReleaseV0150DashboardTestnetExecutionStatusInput(),
        rows: [ReleaseV0150DashboardTestnetExecutionStatusRow] = Self.defaultRows,
        submitStatusVisible: Bool = true,
        cancelStatusVisible: Bool = true,
        cancelReplaceStatusVisible: Bool = true,
        omsStateVisible: Bool = true,
        reconciliationStateVisible: Bool = true,
        failureReasonsVisible: Bool = true,
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
        self.submitStatusVisible = submitStatusVisible
        self.cancelStatusVisible = cancelStatusVisible
        self.cancelReplaceStatusVisible = cancelReplaceStatusVisible
        self.omsStateVisible = omsStateVisible
        self.reconciliationStateVisible = reconciliationStateVisible
        self.failureReasonsVisible = failureReasonsVisible
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
            input: try container.decode(ReleaseV0150DashboardTestnetExecutionStatusInput.self, forKey: .input),
            rows: try container.decode([ReleaseV0150DashboardTestnetExecutionStatusRow].self, forKey: .rows),
            submitStatusVisible: try container.decode(Bool.self, forKey: .submitStatusVisible),
            cancelStatusVisible: try container.decode(Bool.self, forKey: .cancelStatusVisible),
            cancelReplaceStatusVisible: try container.decode(Bool.self, forKey: .cancelReplaceStatusVisible),
            omsStateVisible: try container.decode(Bool.self, forKey: .omsStateVisible),
            reconciliationStateVisible: try container.decode(Bool.self, forKey: .reconciliationStateVisible),
            failureReasonsVisible: try container.decode(Bool.self, forKey: .failureReasonsVisible),
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
        try container.encode(submitStatusVisible, forKey: .submitStatusVisible)
        try container.encode(cancelStatusVisible, forKey: .cancelStatusVisible)
        try container.encode(cancelReplaceStatusVisible, forKey: .cancelReplaceStatusVisible)
        try container.encode(omsStateVisible, forKey: .omsStateVisible)
        try container.encode(reconciliationStateVisible, forKey: .reconciliationStateVisible)
        try container.encode(failureReasonsVisible, forKey: .failureReasonsVisible)
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
    ) throws -> ReleaseV0150DashboardTestnetExecutionStatusLocalArtifactInput {
        try decoder.decode(ReleaseV0150DashboardTestnetExecutionStatusLocalArtifactInput.self, from: data)
    }

    public static func localReadModelArtifact(
        fromJSON data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel {
        try localReadModelArtifactInput(fromJSON: data, decoder: decoder).surface
    }

    public static var deterministicFixture: ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel {
        ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-1074-VERIFY-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS",
        "TVM-RELEASE-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS",
        "V0150-009-DASHBOARD-READ-MODEL-ARTIFACT",
        "V0150-009-SUBMIT-CANCEL-CANCEL-REPLACE-STATUS",
        "V0150-009-OMS-RECONCILIATION-FAILURE-REASONS",
        "V0150-009-DASHBOARD-READ-ONLY-NO-COMMANDS",
        "V0150-009-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH1074DashboardTestnetExecutionStatusSurfaceShowsReadOnlyStatusWithoutCommands",
        "swift test --filter TargetGraphTests/testGH1074DashboardTestnetExecutionStatusSurfaceIsAnchoredInV0150Guards",
        "bash checks/verify-v0.15.0-dashboard-testnet-execution-status.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultRows = [
        ReleaseV0150DashboardTestnetExecutionStatusRow(
            action: .submit,
            sourceNetworkEventArtifactID: "gh-1071-submit-event-artifact",
            sourceOMSStateRecordID: "gh-1072-oms-state-record",
            sourceReconciliationReportID: "gh-1072-v0150-oms-reconciliation-report",
            sequence: 1
        ),
        ReleaseV0150DashboardTestnetExecutionStatusRow(
            action: .cancel,
            sourceNetworkEventArtifactID: "gh-1071-cancel-event-artifact",
            sourceOMSStateRecordID: "gh-1072-oms-state-record",
            sourceReconciliationReportID: "gh-1072-v0150-oms-reconciliation-report",
            sequence: 2
        ),
        ReleaseV0150DashboardTestnetExecutionStatusRow(
            action: .cancelReplace,
            sourceNetworkEventArtifactID: "gh-1071-cancel-replace-event-artifact",
            sourceOMSStateRecordID: "gh-1072-oms-state-record",
            sourceReconciliationReportID: "gh-1072-v0150-oms-reconciliation-report",
            sequence: 3
        )
    ]

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: """
                    ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel decode validation failed: \(field)
                    """
                )
            )
        }
    }
}

/// ReleaseV0150DashboardTestnetExecutionStatusLocalArtifactInput 是 #1074 本地 artifact wrapper。
///
/// Dashboard 只能先解码并验证该 wrapper，再展示内嵌 surface；任何路径逃逸、checksum 格式错误、
/// production flag 或 command surface 注入都必须 fail closed。
public struct ReleaseV0150DashboardTestnetExecutionStatusLocalArtifactInput:
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
    public let surface: ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel
    public let localReadModelArtifact: Bool
    public let redactedEvidenceOnly: Bool
    public let readOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let submitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public static let schemaID = "release-v0.15.0-dashboard-testnet-execution-status-read-model"

    public static let validationAnchors =
        ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel.requiredValidationAnchors

    public var inputHeld: Bool {
        artifactID.isEmpty == false
            && Self.isSafeLocalArtifactPath(relativePath)
            && schema == Self.schemaID
            && releaseVersion == "v0.15.0"
            && validationState == "valid"
            && Self.isValidSHA256Reference(checksumReference)
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
        artifactID: String = "gh-1074-dashboard-testnet-execution-status",
        relativePath: String = ".local/mtpro/runs/gh-1074/dashboard-testnet-execution-status.json",
        schema: String = Self.schemaID,
        releaseVersion: String = "v0.15.0",
        validationState: String = "valid",
        checksumReference: String =
            "sha256:abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
        surface: ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel = .deterministicFixture,
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
            surface: try container.decode(
                ReleaseV0150DashboardTestnetExecutionStatusSurfaceViewModel.self,
                forKey: .surface
            ),
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

    public static func isSafeLocalArtifactPath(_ path: String) -> Bool {
        path.isEmpty == false
            && path.hasPrefix("/") == false
            && path.contains("..") == false
            && path.hasSuffix(".json")
            && (path.hasPrefix(".local/mtpro/") || path.hasPrefix("runs/"))
    }

    public static func isValidSHA256Reference(_ value: String) -> Bool {
        let prefix = "sha256:"
        guard value.hasPrefix(prefix) else {
            return false
        }
        let digest = String(value.dropFirst(prefix.count))
        guard digest.count == 64 else {
            return false
        }
        return digest.unicodeScalars.allSatisfy {
            CharacterSet(charactersIn: "0123456789abcdef").contains($0)
        }
    }

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: """
                    ReleaseV0150DashboardTestnetExecutionStatusLocalArtifactInput decode validation failed: \(field)
                    """
                )
            )
        }
    }
}
