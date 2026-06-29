import Core
import Foundation

// GH-1182 static contract boundary:
// dashboardArtifactRecoveryDrilldownSurface=ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel
// localBundleEvidenceVisible=true
// namespaceVisible=true
// failureClassVisible=true
// nextActionGuidanceVisible=true
// dashboardDependsOnExecutionClientTarget=false
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
// GH-1203-VERIFY-V0181-ARTIFACT-NAMESPACE-PATHS
// TVM-RELEASE-V0181-ARTIFACT-NAMESPACE-PATHS
// V0181-004-RUNS-NAMESPACE-PATH
// V0181-004-V0180-ACTIVE-PATHS-MIGRATED
// V0181-004-CROSS-VENUE-PRODUCT-REUSE-FAILS-CLOSED
// V0181-004-OLD-VERSION-FIXTURES-PRESERVED
// V0181-004-NO-PRODUCTION-CUTOVER
// GH-1210-VERIFY-V0190-V018-LIFECYCLE-TYPED-NAMESPACE
// TVM-RELEASE-V0190-V018-LIFECYCLE-TYPED-NAMESPACE
// V0190-005-TYPED-LIFECYCLE-NAMESPACE
// V0190-005-JSON-DECODE-MIGRATION
// V0190-005-DASHBOARD-NAMESPACE-CONSISTENCY
// V0190-005-NAMESPACE-MISMATCH-FAILS-CLOSED
// V0190-005-NO-PRODUCTION-CUTOVER

/// ReleaseV0180DashboardArtifactRecoveryDrilldownStage 固定 #1182 Dashboard drilldown 行。
///
/// 每一行都只映射本地 artifact bundle 中已经生成的 lifecycle / status / resume /
/// reconciliation evidence，不绑定 command handler，也不重新读取 ExecutionClient runtime object。
public enum ReleaseV0180DashboardArtifactRecoveryDrilldownStage:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case lifecycleManifest = "lifecycleManifest"
    case statusQuery = "statusQuery"
    case resume = "resume"
    case reconciliationReplay = "reconciliationReplay"
}

/// ReleaseV0180DashboardArtifactRecoveryDrilldownNextAction 是 Dashboard 可展示的只读下一步。
///
/// 值域与 GH-1181 CLI 保持一致，但这里只是 read model label；Dashboard 不能把它转成
/// retry / resume / submit / cancel / replace action。
public enum ReleaseV0180DashboardArtifactRecoveryDrilldownNextAction:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case retry
    case resume
    case manualReview
    case stop
}

/// ReleaseV0180DashboardArtifactRecoveryDrilldownInput 是 #1182 的本地 bundle read model 输入。
///
/// 输入只保存脱敏 namespace、artifact path、failure class 和 CLI guidance 摘要。它不保存
/// credential、raw broker payload、signed endpoint response 或可执行 command payload。
public struct ReleaseV0180DashboardArtifactRecoveryDrilldownInput:
    Codable,
    Equatable,
    Sendable
{
    public let sourceEvidenceType: String
    public let venue: String
    public let product: String
    public let environment: String
    public let accountProfile: String
    public let runID: String
    public let sourceBundleID: String
    public let sourceBundleChecksum: String
    public let lifecycleManifestPath: String
    public let statusQueryArtifactPath: String
    public let resumeArtifactPath: String
    public let reconciliationReplayArtifactPath: String
    public let failureClassificationArtifactPath: String
    public let lifecycleManifestState: String
    public let statusQueryState: String
    public let resumeState: String
    public let reconciliationReplayState: String
    public let failureClassificationResultID: String
    public let topLevelNextAction: ReleaseV0180DashboardArtifactRecoveryDrilldownNextAction
    public let operatorNextActionCLI: String
    public let artifactBundleBackedRows: Bool
    public let namespaceVisible: Bool
    public let failureClassVisible: Bool
    public let nextActionVisible: Bool
    public let redactedEvidenceOnly: Bool
    public let readOnly: Bool

    public var namespaceKey: String {
        "\(venue)/\(product)/\(environment)/\(accountProfile)/\(runID)"
    }

    public var inputHeld: Bool {
        sourceEvidenceType == "ReleaseV0180DashboardArtifactRecoveryDrilldownReadModel"
            && Self.isSafeNamespaceText(venue)
            && Self.isSafeNamespaceText(product)
            && Self.isSafeNamespaceText(environment)
            && Self.isSafeNamespaceText(accountProfile)
            && runID.hasPrefix("gh-1182-v0180-")
            && sourceBundleID.hasPrefix("gh-1182-v0180-dashboard-recovery-drilldown-bundle:")
            && Self.isValidSHA256Reference(sourceBundleChecksum)
            && Self.isSafeLocalArtifactPath(lifecycleManifestPath)
            && Self.isSafeLocalArtifactPath(statusQueryArtifactPath)
            && Self.isSafeLocalArtifactPath(resumeArtifactPath)
            && Self.isSafeLocalArtifactPath(reconciliationReplayArtifactPath)
            && Self.isSafeLocalArtifactPath(failureClassificationArtifactPath)
            && lifecycleManifestState == "validated"
            && ["persisted", "retryLimitReached"].contains(statusQueryState)
            && ["blocked", "ready"].contains(resumeState)
            && ["failed", "matched"].contains(reconciliationReplayState)
            && failureClassificationResultID
                .hasPrefix("gh-1181-v0180-failure-classification-result:")
            && operatorNextActionCLI
                .hasPrefix("mtpro operator-run explain-failure --run-id \(runID)")
            && Self.isSafeDisplayText(operatorNextActionCLI)
            && artifactBundleBackedRows
            && namespaceVisible
            && failureClassVisible
            && nextActionVisible
            && redactedEvidenceOnly
            && readOnly
    }

    public init(
        sourceEvidenceType: String = "ReleaseV0180DashboardArtifactRecoveryDrilldownReadModel",
        venue: String = "binance",
        product: String = "usdmFutures",
        environment: String = "testnet",
        accountProfile: String = "operator-beta-redacted",
        runID: String = "gh-1182-v0180-operator-run",
        sourceBundleID: String =
            "gh-1182-v0180-dashboard-recovery-drilldown-bundle:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        sourceBundleChecksum: String =
            "sha256:abababababababababababababababababababababababababababababababab",
        lifecycleManifestPath: String =
            ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/lifecycle-manifest-v0.18.0.json",
        statusQueryArtifactPath: String =
            ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/status-query-retry-result.json",
        resumeArtifactPath: String =
            ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/resume-after-interruption-result.json",
        reconciliationReplayArtifactPath: String =
            ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/cancel-status-reconciliation-replay.json",
        failureClassificationArtifactPath: String =
            ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/failure-classification-next-action.json",
        lifecycleManifestState: String = "validated",
        statusQueryState: String = "retryLimitReached",
        resumeState: String = "blocked",
        reconciliationReplayState: String = "failed",
        failureClassificationResultID: String =
            "gh-1181-v0180-failure-classification-result:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        topLevelNextAction: ReleaseV0180DashboardArtifactRecoveryDrilldownNextAction = .stop,
        operatorNextActionCLI: String =
            "mtpro operator-run explain-failure --run-id gh-1182-v0180-operator-run --venue binance --product usdmFutures --environment testnet --account-profile operator-beta-redacted",
        artifactBundleBackedRows: Bool = true,
        namespaceVisible: Bool = true,
        failureClassVisible: Bool = true,
        nextActionVisible: Bool = true,
        redactedEvidenceOnly: Bool = true,
        readOnly: Bool = true
    ) {
        self.sourceEvidenceType = sourceEvidenceType
        self.venue = venue
        self.product = product
        self.environment = environment
        self.accountProfile = accountProfile
        self.runID = runID
        self.sourceBundleID = sourceBundleID
        self.sourceBundleChecksum = sourceBundleChecksum
        self.lifecycleManifestPath = lifecycleManifestPath
        self.statusQueryArtifactPath = statusQueryArtifactPath
        self.resumeArtifactPath = resumeArtifactPath
        self.reconciliationReplayArtifactPath = reconciliationReplayArtifactPath
        self.failureClassificationArtifactPath = failureClassificationArtifactPath
        self.lifecycleManifestState = lifecycleManifestState
        self.statusQueryState = statusQueryState
        self.resumeState = resumeState
        self.reconciliationReplayState = reconciliationReplayState
        self.failureClassificationResultID = failureClassificationResultID
        self.topLevelNextAction = topLevelNextAction
        self.operatorNextActionCLI = operatorNextActionCLI
        self.artifactBundleBackedRows = artifactBundleBackedRows
        self.namespaceVisible = namespaceVisible
        self.failureClassVisible = failureClassVisible
        self.nextActionVisible = nextActionVisible
        self.redactedEvidenceOnly = redactedEvidenceOnly
        self.readOnly = readOnly
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            sourceEvidenceType: try container.decode(String.self, forKey: .sourceEvidenceType),
            venue: try container.decode(String.self, forKey: .venue),
            product: try container.decode(String.self, forKey: .product),
            environment: try container.decode(String.self, forKey: .environment),
            accountProfile: try container.decode(String.self, forKey: .accountProfile),
            runID: try container.decode(String.self, forKey: .runID),
            sourceBundleID: try container.decode(String.self, forKey: .sourceBundleID),
            sourceBundleChecksum: try container.decode(String.self, forKey: .sourceBundleChecksum),
            lifecycleManifestPath: try container.decode(String.self, forKey: .lifecycleManifestPath),
            statusQueryArtifactPath: try container.decode(String.self, forKey: .statusQueryArtifactPath),
            resumeArtifactPath: try container.decode(String.self, forKey: .resumeArtifactPath),
            reconciliationReplayArtifactPath: try container.decode(
                String.self,
                forKey: .reconciliationReplayArtifactPath
            ),
            failureClassificationArtifactPath: try container.decode(
                String.self,
                forKey: .failureClassificationArtifactPath
            ),
            lifecycleManifestState: try container.decode(String.self, forKey: .lifecycleManifestState),
            statusQueryState: try container.decode(String.self, forKey: .statusQueryState),
            resumeState: try container.decode(String.self, forKey: .resumeState),
            reconciliationReplayState: try container.decode(String.self, forKey: .reconciliationReplayState),
            failureClassificationResultID: try container.decode(
                String.self,
                forKey: .failureClassificationResultID
            ),
            topLevelNextAction: try container.decode(
                ReleaseV0180DashboardArtifactRecoveryDrilldownNextAction.self,
                forKey: .topLevelNextAction
            ),
            operatorNextActionCLI: try container.decode(String.self, forKey: .operatorNextActionCLI),
            artifactBundleBackedRows: try container.decode(Bool.self, forKey: .artifactBundleBackedRows),
            namespaceVisible: try container.decode(Bool.self, forKey: .namespaceVisible),
            failureClassVisible: try container.decode(Bool.self, forKey: .failureClassVisible),
            nextActionVisible: try container.decode(Bool.self, forKey: .nextActionVisible),
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

    public static func isSafeLocalArtifactPath(_ value: String) -> Bool {
        value.hasPrefix(".local/mtpro/runs/")
            && value.contains("/artifacts/")
            && value.contains("..") == false
            && value.contains("//") == false
            && value.hasSuffix(".json")
    }

    public static func isSafeNamespaceText(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return false }
        return trimmed.allSatisfy { character in
            character.isLetter || character.isNumber || character == "-" || character == "_"
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
            "api." + "binance.com",
            "broker payload",
            "newclientorderid",
            "submitorder",
            "cancelorder",
            "replaceorder"
        ]
        let lowercased = trimmed.lowercased()
        return forbidden.allSatisfy { lowercased.contains($0) == false }
    }

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription:
                        "ReleaseV0180DashboardArtifactRecoveryDrilldownInput decode failed: \(field)"
                )
            )
        }
    }
}

/// ReleaseV0180DashboardArtifactRecoveryDrilldownRow 是 Dashboard 展示的只读恢复 drilldown 行。
public struct ReleaseV0180DashboardArtifactRecoveryDrilldownRow:
    Codable,
    Equatable,
    Sendable
{
    public let stage: ReleaseV0180DashboardArtifactRecoveryDrilldownStage
    public let sequence: Int
    public let sourceArtifactPath: String
    public let failureClass: String
    public let nextAction: ReleaseV0180DashboardArtifactRecoveryDrilldownNextAction
    public let explanation: String
    public let visibleInDashboard: Bool
    public let readOnly: Bool
    public let commandHandlerBound: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let submitCancelReplaceEnabled: Bool

    public var rowHeld: Bool {
        sequence > 0
            && ReleaseV0180DashboardArtifactRecoveryDrilldownInput
                .isSafeLocalArtifactPath(sourceArtifactPath)
            && ReleaseV0180DashboardArtifactRecoveryDrilldownInput.isSafeDisplayText(failureClass)
            && ReleaseV0180DashboardArtifactRecoveryDrilldownInput.isSafeDisplayText(explanation)
            && explanation.contains("binance/usdmFutures/testnet/operator-beta-redacted")
            && visibleInDashboard
            && readOnly
            && commandHandlerBound == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && submitCancelReplaceEnabled == false
    }

    public init(
        stage: ReleaseV0180DashboardArtifactRecoveryDrilldownStage,
        sequence: Int,
        sourceArtifactPath: String,
        failureClass: String,
        nextAction: ReleaseV0180DashboardArtifactRecoveryDrilldownNextAction,
        explanation: String,
        visibleInDashboard: Bool = true,
        readOnly: Bool = true,
        commandHandlerBound: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        submitCancelReplaceEnabled: Bool = false
    ) {
        self.stage = stage
        self.sequence = sequence
        self.sourceArtifactPath = sourceArtifactPath
        self.failureClass = failureClass
        self.nextAction = nextAction
        self.explanation = explanation
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
            stage: try container.decode(
                ReleaseV0180DashboardArtifactRecoveryDrilldownStage.self,
                forKey: .stage
            ),
            sequence: try container.decode(Int.self, forKey: .sequence),
            sourceArtifactPath: try container.decode(String.self, forKey: .sourceArtifactPath),
            failureClass: try container.decode(String.self, forKey: .failureClass),
            nextAction: try container.decode(
                ReleaseV0180DashboardArtifactRecoveryDrilldownNextAction.self,
                forKey: .nextAction
            ),
            explanation: try container.decode(String.self, forKey: .explanation),
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
                    debugDescription:
                        "ReleaseV0180DashboardArtifactRecoveryDrilldownRow decode failed: \(field)"
                )
            )
        }
    }
}

/// ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel 是 #1182 的只读 Dashboard drilldown。
///
/// Surface 把 GH-1179 resume、GH-1180 reconciliation replay 和 GH-1181 next-action
/// classification 的本地 artifact bundle 汇总成 operator 可读 drilldown。它没有 command handler、
/// 交易按钮、order form、live command、ExecutionClient target 依赖或 production cutover 标志。
public struct ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel:
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
    public let input: ReleaseV0180DashboardArtifactRecoveryDrilldownInput
    public let rows: [ReleaseV0180DashboardArtifactRecoveryDrilldownRow]
    public let localBundleEvidenceVisible: Bool
    public let namespaceVisible: Bool
    public let failureClassVisible: Bool
    public let nextActionGuidanceVisible: Bool
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
        case localBundleEvidenceVisible
        case namespaceVisible
        case failureClassVisible
        case nextActionGuidanceVisible
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
            && rows.count == ReleaseV0180DashboardArtifactRecoveryDrilldownStage.allCases.count
            && rows.map(\.stage) == ReleaseV0180DashboardArtifactRecoveryDrilldownStage.allCases
            && rows.map(\.sequence) == Array(
                1...ReleaseV0180DashboardArtifactRecoveryDrilldownStage.allCases.count
            )
            && rows.allSatisfy(\.rowHeld)
            && localBundleEvidenceVisible
            && namespaceVisible
            && failureClassVisible
            && nextActionGuidanceVisible
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

    public var failureClassLabels: [String] {
        rows.map(\.failureClass).sorted()
    }

    public var nextActionLabels: [String] {
        rows.map(\.nextAction.rawValue).sorted()
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.18 drilldown rows", value: "\(visibleRowCount)"),
            DashboardShellMetric(label: "v0.18 namespace", value: input.namespaceKey),
            DashboardShellMetric(label: "v0.18 failure classes", value: failureClassLabels.joined(separator: ",")),
            DashboardShellMetric(label: "v0.18 next actions", value: nextActionLabels.joined(separator: ",")),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        [
            "Bundle: \(input.sourceBundleID)",
            "Bundle checksum: \(input.sourceBundleChecksum)",
            "Namespace: \(input.namespaceKey)",
            "Lifecycle manifest: \(input.lifecycleManifestPath)",
            "Status query artifact: \(input.statusQueryArtifactPath)",
            "Resume artifact: \(input.resumeArtifactPath)",
            "Reconciliation replay artifact: \(input.reconciliationReplayArtifactPath)",
            "Failure classification artifact: \(input.failureClassificationArtifactPath)",
            "Failure classes: \(failureClassLabels.joined(separator: ", "))",
            "Top-level next action: \(input.topLevelNextAction.rawValue)",
            "Operator next-action CLI: \(input.operatorNextActionCLI)",
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
        issueID: String = "GH-1182",
        upstreamIssueIDs: [String] = ["GH-1179", "GH-1180", "GH-1181"],
        previousIssueID: String = "GH-1181",
        releaseVersion: String = "v0.18.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        input: ReleaseV0180DashboardArtifactRecoveryDrilldownInput =
            ReleaseV0180DashboardArtifactRecoveryDrilldownInput(),
        rows: [ReleaseV0180DashboardArtifactRecoveryDrilldownRow] = Self.defaultRows,
        localBundleEvidenceVisible: Bool = true,
        namespaceVisible: Bool = true,
        failureClassVisible: Bool = true,
        nextActionGuidanceVisible: Bool = true,
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
        self.localBundleEvidenceVisible = localBundleEvidenceVisible
        self.namespaceVisible = namespaceVisible
        self.failureClassVisible = failureClassVisible
        self.nextActionGuidanceVisible = nextActionGuidanceVisible
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
            input: try container.decode(ReleaseV0180DashboardArtifactRecoveryDrilldownInput.self, forKey: .input),
            rows: try container.decode([ReleaseV0180DashboardArtifactRecoveryDrilldownRow].self, forKey: .rows),
            localBundleEvidenceVisible: try container.decode(Bool.self, forKey: .localBundleEvidenceVisible),
            namespaceVisible: try container.decode(Bool.self, forKey: .namespaceVisible),
            failureClassVisible: try container.decode(Bool.self, forKey: .failureClassVisible),
            nextActionGuidanceVisible: try container.decode(Bool.self, forKey: .nextActionGuidanceVisible),
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
        try container.encode(localBundleEvidenceVisible, forKey: .localBundleEvidenceVisible)
        try container.encode(namespaceVisible, forKey: .namespaceVisible)
        try container.encode(failureClassVisible, forKey: .failureClassVisible)
        try container.encode(nextActionGuidanceVisible, forKey: .nextActionGuidanceVisible)
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
    ) throws -> ReleaseV0180DashboardArtifactRecoveryDrilldownLocalArtifactInput {
        try decoder.decode(ReleaseV0180DashboardArtifactRecoveryDrilldownLocalArtifactInput.self, from: data)
    }

    public static func localReadModelArtifact(
        fromJSON data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel {
        try localReadModelArtifactInput(fromJSON: data, decoder: decoder).surface
    }

    public static var deterministicFixture: ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel {
        ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel()
    }

    public static let requiredValidationAnchors = [
        "GH-1182-VERIFY-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN",
        "TVM-RELEASE-V0180-DASHBOARD-ARTIFACT-RECOVERY-DRILLDOWN",
        "V0180-007-DEPENDENCIES-GH1179-GH1180-GH1181-DONE",
        "V0180-007-REAL-LOCAL-BUNDLE-EVIDENCE",
        "V0180-007-LIFECYCLE-STATUS-RESUME-RECONCILIATION-DRILLDOWN",
        "V0180-007-VENUE-PRODUCT-ENVIRONMENT-DRILLDOWN",
        "V0180-007-FAILURE-CLASS-NEXT-ACTION-GUIDANCE",
        "V0180-007-DASHBOARD-READ-ONLY-NO-COMMANDS",
        "V0180-007-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH1182DashboardArtifactRecoveryDrilldownShowsRealBundleEvidenceWithoutCommands",
        "swift test --filter TargetGraphTests/testGH1182DashboardArtifactRecoveryDrilldownIsAnchoredInV0180Guards",
        "bash checks/verify-v0.18.0-dashboard-artifact-recovery-drilldown.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let defaultRows = [
        ReleaseV0180DashboardArtifactRecoveryDrilldownRow(
            stage: .lifecycleManifest,
            sequence: 1,
            sourceArtifactPath:
                ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/lifecycle-manifest-v0.18.0.json",
            failureClass: "artifactManifestValidated",
            nextAction: .manualReview,
            explanation:
                "binance/usdmFutures/testnet/operator-beta-redacted namespace validated for local bundle review"
        ),
        ReleaseV0180DashboardArtifactRecoveryDrilldownRow(
            stage: .statusQuery,
            sequence: 2,
            sourceArtifactPath:
                ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/status-query-retry-result.json",
            failureClass: "statusQueryRetryLimitReached",
            nextAction: .retry,
            explanation:
                "binance/usdmFutures/testnet/operator-beta-redacted status query failed closed before any network retry"
        ),
        ReleaseV0180DashboardArtifactRecoveryDrilldownRow(
            stage: .resume,
            sequence: 3,
            sourceArtifactPath:
                ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/resume-after-interruption-result.json",
            failureClass: "resumeEvidenceBlocked",
            nextAction: .manualReview,
            explanation:
                "binance/usdmFutures/testnet/operator-beta-redacted resume evidence requires operator review"
        ),
        ReleaseV0180DashboardArtifactRecoveryDrilldownRow(
            stage: .reconciliationReplay,
            sequence: 4,
            sourceArtifactPath:
                ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/cancel-status-reconciliation-replay.json",
            failureClass: "reconciliationReplayMismatch",
            nextAction: .stop,
            explanation:
                "binance/usdmFutures/testnet/operator-beta-redacted reconciliation mismatch keeps recovery stopped"
        )
    ]

    private static func requireDecodedBoundary(_ condition: Bool, field: String, codingPath: [CodingKey]) throws {
        guard condition else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: """
                    ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel decode failed: \(field)
                    """
                )
            )
        }
    }
}

/// ReleaseV0180DashboardArtifactRecoveryDrilldownLocalArtifactInput 是 #1182 本地 read-model wrapper。
///
/// Dashboard 必须先验证 wrapper path、schema、checksum 和 read-only boundary flags，再展示内嵌
/// drilldown surface。任何路径逃逸、production flag 或 command surface 注入都会 fail closed。
public struct ReleaseV0180DashboardArtifactRecoveryDrilldownLocalArtifactInput:
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
    public let surface: ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel
    public let localReadModelArtifact: Bool
    public let redactedEvidenceOnly: Bool
    public let readOnly: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let submitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public static let schemaID = "release-v0.18.0-dashboard-artifact-recovery-drilldown-read-model"

    public static let validationAnchors =
        ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel.requiredValidationAnchors

    public var inputHeld: Bool {
        artifactID == "gh-1182-dashboard-artifact-recovery-drilldown"
            && ReleaseV0180DashboardArtifactRecoveryDrilldownInput
                .isSafeLocalArtifactPath(relativePath)
            && schema == Self.schemaID
            && releaseVersion == "v0.18.0"
            && validationState == "valid"
            && ReleaseV0180DashboardArtifactRecoveryDrilldownInput
                .isValidSHA256Reference(checksumReference)
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
        artifactID: String = "gh-1182-dashboard-artifact-recovery-drilldown",
        relativePath: String =
            ".local/mtpro/runs/binance/usdmFutures/testnet/operator-beta-redacted/gh-1182-v0180-operator-run/artifacts/dashboard-recovery-drilldown.json",
        schema: String = Self.schemaID,
        releaseVersion: String = "v0.18.0",
        validationState: String = "valid",
        checksumReference: String =
            "sha256:1818181818181818181818181818181818181818181818181818181818181818",
        surface: ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel = .deterministicFixture,
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
                ReleaseV0180DashboardArtifactRecoveryDrilldownSurfaceViewModel.self,
                forKey: .surface
            ),
            localReadModelArtifact: try container.decode(Bool.self, forKey: .localReadModelArtifact),
            redactedEvidenceOnly: try container.decode(Bool.self, forKey: .redactedEvidenceOnly),
            readOnly: try container.decode(Bool.self, forKey: .readOnly),
            productionTradingEnabledByDefault: try container.decode(
                Bool.self,
                forKey: .productionTradingEnabledByDefault
            ),
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
                    debugDescription:
                        "ReleaseV0180DashboardArtifactRecoveryDrilldownLocalArtifactInput decode failed: \(field)"
                )
            )
        }
    }
}
