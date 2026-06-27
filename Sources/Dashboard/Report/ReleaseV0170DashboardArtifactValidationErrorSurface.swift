import Core
import Foundation

// GH-1144 static contract boundary:
// dashboardArtifactValidationErrorSurface=ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel
// artifactValidationStatusVisible=true
// failureReasonsVisible=true
// recoveryCaseSummaryVisible=true
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

/// ReleaseV0170DashboardArtifactValidationErrorKind 固定 #1144 Dashboard 可展示的错误分类。
///
/// 这些分类只来自 #1140 artifact bundle replay validator 和 #1143 cancel/status recovery report。
/// Dashboard 只能展示分类和 operator 下一步，不得把分类转换为 submit / cancel / replace command。
public enum ReleaseV0170DashboardArtifactValidationErrorKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case artifactBundleValidationFailed
    case cancelStatusMismatch
    case interruptedStatusEvidence
}

/// ReleaseV0170DashboardArtifactValidationErrorInput 是 #1144 的只读 Dashboard 输入。
///
/// 输入只保存本地 validation / recovery evidence 的脱敏摘要：result ID、report ID、失败原因和
/// operator action summary。它不保存 credential、raw order identity、broker payload 或 endpoint response。
public struct ReleaseV0170DashboardArtifactValidationErrorInput:
    Codable,
    Equatable,
    Sendable
{
    public let sourceEvidenceType: String
    public let runID: String
    public let artifactBundleValidationResultID: String
    public let artifactBundleValidationStatus: String
    public let artifactBundleFailureReasons: [String]
    public let recoveryReportID: String
    public let recoveryStatus: String
    public let recoveryFailureReasons: [String]
    public let sourceManifestChecksum: String
    public let localArtifactReadModelOnly: Bool
    public let artifactValidationStatusVisible: Bool
    public let failureReasonsVisible: Bool
    public let recoveryCaseSummaryVisible: Bool
    public let redactedEvidenceOnly: Bool
    public let readOnly: Bool

    public var inputHeld: Bool {
        sourceEvidenceType == "ReleaseV0170DashboardArtifactValidationErrorReadModel"
            && runID.isEmpty == false
            && artifactBundleValidationResultID.hasPrefix("gh-1140-v0170-artifact-bundle-result:")
            && ["passed", "failed"].contains(artifactBundleValidationStatus)
            && artifactBundleFailureReasons.isEmpty == false
            && artifactBundleFailureReasons.allSatisfy(Self.isSafeDisplayText)
            && recoveryReportID.hasPrefix("gh-1143-v0170-cancel-status-recovery-report:")
            && ["passed", "failed"].contains(recoveryStatus)
            && recoveryFailureReasons.isEmpty == false
            && recoveryFailureReasons.allSatisfy(Self.isSafeDisplayText)
            && Self.isValidSHA256Reference(sourceManifestChecksum)
            && localArtifactReadModelOnly
            && artifactValidationStatusVisible
            && failureReasonsVisible
            && recoveryCaseSummaryVisible
            && redactedEvidenceOnly
            && readOnly
    }

    public init(
        sourceEvidenceType: String = "ReleaseV0170DashboardArtifactValidationErrorReadModel",
        runID: String = "gh-1144-v0170-operator-run",
        artifactBundleValidationResultID: String =
            "gh-1140-v0170-artifact-bundle-result:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        artifactBundleValidationStatus: String = "failed",
        artifactBundleFailureReasons: [String] = [
            "checksumMismatch",
            "reconciliationArtifactMissing"
        ],
        recoveryReportID: String =
            "gh-1143-v0170-cancel-status-recovery-report:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        recoveryStatus: String = "failed",
        recoveryFailureReasons: [String] = [
            "cancelStatusMismatch",
            "interruptedStatusEvidence"
        ],
        sourceManifestChecksum: String =
            "sha256:abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789",
        localArtifactReadModelOnly: Bool = true,
        artifactValidationStatusVisible: Bool = true,
        failureReasonsVisible: Bool = true,
        recoveryCaseSummaryVisible: Bool = true,
        redactedEvidenceOnly: Bool = true,
        readOnly: Bool = true
    ) {
        self.sourceEvidenceType = sourceEvidenceType
        self.runID = runID
        self.artifactBundleValidationResultID = artifactBundleValidationResultID
        self.artifactBundleValidationStatus = artifactBundleValidationStatus
        self.artifactBundleFailureReasons = artifactBundleFailureReasons
        self.recoveryReportID = recoveryReportID
        self.recoveryStatus = recoveryStatus
        self.recoveryFailureReasons = recoveryFailureReasons
        self.sourceManifestChecksum = sourceManifestChecksum
        self.localArtifactReadModelOnly = localArtifactReadModelOnly
        self.artifactValidationStatusVisible = artifactValidationStatusVisible
        self.failureReasonsVisible = failureReasonsVisible
        self.recoveryCaseSummaryVisible = recoveryCaseSummaryVisible
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.readOnly = readOnly
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            sourceEvidenceType: try container.decode(String.self, forKey: .sourceEvidenceType),
            runID: try container.decode(String.self, forKey: .runID),
            artifactBundleValidationResultID: try container.decode(
                String.self,
                forKey: .artifactBundleValidationResultID
            ),
            artifactBundleValidationStatus: try container.decode(
                String.self,
                forKey: .artifactBundleValidationStatus
            ),
            artifactBundleFailureReasons: try container.decode(
                [String].self,
                forKey: .artifactBundleFailureReasons
            ),
            recoveryReportID: try container.decode(String.self, forKey: .recoveryReportID),
            recoveryStatus: try container.decode(String.self, forKey: .recoveryStatus),
            recoveryFailureReasons: try container.decode([String].self, forKey: .recoveryFailureReasons),
            sourceManifestChecksum: try container.decode(String.self, forKey: .sourceManifestChecksum),
            localArtifactReadModelOnly: try container.decode(Bool.self, forKey: .localArtifactReadModelOnly),
            artifactValidationStatusVisible: try container.decode(
                Bool.self,
                forKey: .artifactValidationStatusVisible
            ),
            failureReasonsVisible: try container.decode(Bool.self, forKey: .failureReasonsVisible),
            recoveryCaseSummaryVisible: try container.decode(Bool.self, forKey: .recoveryCaseSummaryVisible),
            redactedEvidenceOnly: try container.decode(Bool.self, forKey: .redactedEvidenceOnly),
            readOnly: try container.decode(Bool.self, forKey: .readOnly)
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

    public static func isSafeDisplayText(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return false }
        let forbidden = [
            "api key",
            "secret",
            "listenkey",
            "signature=",
            "api.binance.com",
            "broker payload",
            "newclientorderid"
        ]
        let lowercased = trimmed.lowercased()
        return forbidden.allSatisfy { lowercased.contains($0) == false }
    }

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "ReleaseV0170DashboardArtifactValidationErrorInput decode failed: \(field)"
                )
            )
        }
    }
}

/// ReleaseV0170DashboardArtifactValidationErrorRow 是 Dashboard 展示的只读失败行。
public struct ReleaseV0170DashboardArtifactValidationErrorRow:
    Codable,
    Equatable,
    Sendable
{
    public let kind: ReleaseV0170DashboardArtifactValidationErrorKind
    public let sequence: Int
    public let sourceEvidenceID: String
    public let displayReason: String
    public let operatorActionSummary: String
    public let visibleInDashboard: Bool
    public let readOnly: Bool
    public let commandHandlerBound: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let submitCancelReplaceEnabled: Bool

    public var rowHeld: Bool {
        sequence > 0
            && sourceEvidenceID.isEmpty == false
            && ReleaseV0170DashboardArtifactValidationErrorInput.isSafeDisplayText(displayReason)
            && ReleaseV0170DashboardArtifactValidationErrorInput.isSafeDisplayText(operatorActionSummary)
            && visibleInDashboard
            && readOnly
            && commandHandlerBound == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && submitCancelReplaceEnabled == false
    }

    public init(
        kind: ReleaseV0170DashboardArtifactValidationErrorKind,
        sequence: Int,
        sourceEvidenceID: String,
        displayReason: String,
        operatorActionSummary: String,
        visibleInDashboard: Bool = true,
        readOnly: Bool = true,
        commandHandlerBound: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false
    ) {
        self.kind = kind
        self.sequence = sequence
        self.sourceEvidenceID = sourceEvidenceID
        self.displayReason = displayReason
        self.operatorActionSummary = operatorActionSummary
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
            kind: try container.decode(ReleaseV0170DashboardArtifactValidationErrorKind.self, forKey: .kind),
            sequence: try container.decode(Int.self, forKey: .sequence),
            sourceEvidenceID: try container.decode(String.self, forKey: .sourceEvidenceID),
            displayReason: try container.decode(String.self, forKey: .displayReason),
            operatorActionSummary: try container.decode(String.self, forKey: .operatorActionSummary),
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
                    debugDescription: "ReleaseV0170DashboardArtifactValidationErrorRow decode failed: \(field)"
                )
            )
        }
    }
}

/// ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel 是 #1144 的只读 Dashboard 错误面。
///
/// Surface 把 #1140 artifact validation result 和 #1143 recovery report 显示为 operator review
/// evidence。它没有 command handler、交易按钮、order form、live command 或 production cutover 标志。
public struct ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel:
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
    public let input: ReleaseV0170DashboardArtifactValidationErrorInput
    public let rows: [ReleaseV0170DashboardArtifactValidationErrorRow]
    public let artifactValidationStatusVisible: Bool
    public let failureReasonsVisible: Bool
    public let recoveryCaseSummaryVisible: Bool
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
        case artifactValidationStatusVisible
        case failureReasonsVisible
        case recoveryCaseSummaryVisible
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
            && rows.count == ReleaseV0170DashboardArtifactValidationErrorKind.allCases.count
            && rows.map(\.kind) == ReleaseV0170DashboardArtifactValidationErrorKind.allCases
            && rows.map(\.sequence) == Array(1...ReleaseV0170DashboardArtifactValidationErrorKind.allCases.count)
            && rows.allSatisfy(\.rowHeld)
            && artifactValidationStatusVisible
            && failureReasonsVisible
            && recoveryCaseSummaryVisible
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

    public var failureReasonLabels: [String] {
        (input.artifactBundleFailureReasons + input.recoveryFailureReasons).sorted()
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.17 artifact validation rows", value: "\(visibleRowCount)"),
            DashboardShellMetric(label: "v0.17 artifact validation", value: input.artifactBundleValidationStatus),
            DashboardShellMetric(label: "v0.17 recovery", value: input.recoveryStatus),
            DashboardShellMetric(label: "v0.17 failure reasons", value: failureReasonLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Run ID: \(input.runID)",
            "Artifact validation result: \(input.artifactBundleValidationResultID)",
            "Artifact validation state: \(input.artifactBundleValidationStatus)",
            "Artifact failure reasons: \(input.artifactBundleFailureReasons.joined(separator: ", "))",
            "Recovery report: \(input.recoveryReportID)",
            "Recovery state: \(input.recoveryStatus)",
            "Recovery reasons: \(input.recoveryFailureReasons.joined(separator: ", "))",
            "Source manifest checksum: \(input.sourceManifestChecksum)",
            "Visible rows: \(rows.map(\.displayReason).joined(separator: ", "))",
            "Operator action summary: \(rows.map(\.operatorActionSummary).joined(separator: ", "))",
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
        issueID: String = "GH-1144",
        upstreamIssueIDs: [String] = ["GH-1140", "GH-1143"],
        previousIssueID: String = "GH-1143",
        releaseVersion: String = "v0.17.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        input: ReleaseV0170DashboardArtifactValidationErrorInput =
            ReleaseV0170DashboardArtifactValidationErrorInput(),
        rows: [ReleaseV0170DashboardArtifactValidationErrorRow] = Self.defaultRows,
        artifactValidationStatusVisible: Bool = true,
        failureReasonsVisible: Bool = true,
        recoveryCaseSummaryVisible: Bool = true,
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
        self.artifactValidationStatusVisible = artifactValidationStatusVisible
        self.failureReasonsVisible = failureReasonsVisible
        self.recoveryCaseSummaryVisible = recoveryCaseSummaryVisible
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
            input: try container.decode(ReleaseV0170DashboardArtifactValidationErrorInput.self, forKey: .input),
            rows: try container.decode([ReleaseV0170DashboardArtifactValidationErrorRow].self, forKey: .rows),
            artifactValidationStatusVisible: try container.decode(Bool.self, forKey: .artifactValidationStatusVisible),
            failureReasonsVisible: try container.decode(Bool.self, forKey: .failureReasonsVisible),
            recoveryCaseSummaryVisible: try container.decode(Bool.self, forKey: .recoveryCaseSummaryVisible),
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
        try container.encode(artifactValidationStatusVisible, forKey: .artifactValidationStatusVisible)
        try container.encode(failureReasonsVisible, forKey: .failureReasonsVisible)
        try container.encode(recoveryCaseSummaryVisible, forKey: .recoveryCaseSummaryVisible)
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
    ) throws -> ReleaseV0170DashboardArtifactValidationErrorLocalArtifactInput {
        try decoder.decode(ReleaseV0170DashboardArtifactValidationErrorLocalArtifactInput.self, from: data)
    }

    public static func localReadModelArtifact(
        fromJSON data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel {
        try localReadModelArtifactInput(fromJSON: data, decoder: decoder).surface
    }

    public static var deterministicFixture: ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel {
        ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-1144-VERIFY-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE",
        "TVM-RELEASE-V0170-DASHBOARD-ARTIFACT-VALIDATION-ERROR-SURFACE",
        "V0170-006-ARTIFACT-VALIDATION-STATUS-VISIBLE",
        "V0170-006-FAILURE-REASONS-VISIBLE",
        "V0170-006-RECOVERY-CASE-SUMMARY-VISIBLE",
        "V0170-006-DASHBOARD-READ-ONLY-NO-COMMANDS",
        "V0170-006-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH1144DashboardArtifactValidationErrorSurfaceShowsFailuresWithoutCommands",
        "swift test --filter TargetGraphTests/testGH1144DashboardArtifactValidationErrorSurfaceIsAnchoredInV0170Guards",
        "bash checks/verify-v0.17.0-dashboard-artifact-validation-error-surface.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultRows = [
        ReleaseV0170DashboardArtifactValidationErrorRow(
            kind: .artifactBundleValidationFailed,
            sequence: 1,
            sourceEvidenceID:
                "gh-1140-v0170-artifact-bundle-result:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            displayReason: "checksumMismatch",
            operatorActionSummary: "freeze run and inspect local artifact bundle"
        ),
        ReleaseV0170DashboardArtifactValidationErrorRow(
            kind: .cancelStatusMismatch,
            sequence: 2,
            sourceEvidenceID:
                "gh-1143-v0170-cancel-status-recovery-report:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            displayReason: "cancelStatusMismatch",
            operatorActionSummary: "run status compensation and replay observed-status reconciliation"
        ),
        ReleaseV0170DashboardArtifactValidationErrorRow(
            kind: .interruptedStatusEvidence,
            sequence: 3,
            sourceEvidenceID:
                "gh-1143-v0170-cancel-status-recovery-report:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            displayReason: "interruptedStatusEvidence",
            operatorActionSummary: "require operator review and close failed without retry"
        )
    ]

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: """
                    ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel decode failed: \(field)
                    """
                )
            )
        }
    }
}

/// ReleaseV0170DashboardArtifactValidationErrorLocalArtifactInput 是 #1144 本地 read-model wrapper。
///
/// Dashboard 必须先验证 wrapper path、checksum、schema 和 boundary flags，再展示内嵌错误面。
/// 任何路径逃逸、checksum 格式错误、production flag 或 command surface 注入都会 fail closed。
public struct ReleaseV0170DashboardArtifactValidationErrorLocalArtifactInput:
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
    public let surface: ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel
    public let localReadModelArtifact: Bool
    public let redactedEvidenceOnly: Bool
    public let readOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let submitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public static let schemaID = "release-v0.17.0-dashboard-artifact-validation-error-surface-read-model"

    public static let validationAnchors =
        ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel.requiredValidationAnchors

    public var inputHeld: Bool {
        artifactID.isEmpty == false
            && Self.isSafeLocalArtifactPath(relativePath)
            && schema == Self.schemaID
            && releaseVersion == "v0.17.0"
            && validationState == "valid"
            && ReleaseV0170DashboardArtifactValidationErrorInput.isValidSHA256Reference(checksumReference)
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
        artifactID: String = "gh-1144-dashboard-artifact-validation-error-surface",
        relativePath: String =
            ".local/mtpro/v0.17.0/operator-runs/gh-1144-v0170-operator-run/artifacts/dashboard-artifact-validation-errors.json",
        schema: String = Self.schemaID,
        releaseVersion: String = "v0.17.0",
        validationState: String = "valid",
        checksumReference: String =
            "sha256:4444444444444444444444444444444444444444444444444444444444444444",
        surface: ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel = .deterministicFixture,
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
                ReleaseV0170DashboardArtifactValidationErrorSurfaceViewModel.self,
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

    public static func isSafeLocalArtifactPath(_ value: String) -> Bool {
        value.hasPrefix(".local/mtpro/v0.17.0/operator-runs/")
            && value.contains("..") == false
            && value.contains("//") == false
            && value.hasSuffix(".json")
    }

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription:
                        "ReleaseV0170DashboardArtifactValidationErrorLocalArtifactInput decode failed: \(field)"
                )
            )
        }
    }
}
