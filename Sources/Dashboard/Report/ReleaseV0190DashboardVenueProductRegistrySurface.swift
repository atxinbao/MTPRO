import Core
import Foundation

// GH-1213 static contract boundary:
// dashboardVenueProductRegistrySurfaceRows=binance/spot,binance/usdmFutures,okx/spot,okx/swap
// dashboardVenueProductRegistryStates=active,placeholder,futureGated,forbidden
// dashboardVenueProductRegistryCapabilityReasonsVisible=true
// dashboardVenueProductRegistryReadOnly=true
// dashboardVenueProductRegistryCommandSurfaceEnabled=false
// tradingButtonVisible=false
// orderFormVisible=false
// liveCommandVisible=false
// productionTradingEnabledByDefault=false
// productionSecretRead=false
// productionEndpointConnected=false
// brokerEndpointConnected=false
// productionSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false
// GH-1213-VERIFY-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE
// TVM-RELEASE-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE
// V0190-008-DASHBOARD-REGISTRY-READ-ONLY-SURFACE
// V0190-008-BINANCE-SPOT-FUTURES-OKX-SPOT-SWAP-STATES
// V0190-008-ACTIVE-PLACEHOLDER-FUTURE-GATED-FORBIDDEN
// V0190-008-CAPABILITY-UNSUPPORTED-REASONS
// V0190-008-DASHBOARD-READ-ONLY-NO-COMMANDS
// V0190-008-NO-PRODUCTION-CUTOVER

/// ReleaseV0190DashboardVenueProductRegistrySupportState 是 Dashboard 可展示的 registry 状态。
///
/// 这些状态只用于 read-model 展示。`active` 也不等于生产授权，Dashboard 仍不能从
/// surface 反向构造 submit / cancel / replace command。
public enum ReleaseV0190DashboardVenueProductRegistrySupportState:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case active
    case placeholder
    case futureGated
    case forbidden
}

/// ReleaseV0190DashboardVenueProductRegistryRow 是 #1213 Dashboard 的只读 registry 行。
///
/// Row 只保存 venue / product / environment、capability summary 和 unsupported reason。
/// 它不会保存 endpoint URL、secret value、adapter request、broker payload 或 live command。
public struct ReleaseV0190DashboardVenueProductRegistryRow:
    Codable,
    Equatable,
    Sendable
{
    public let venueID: String
    public let venueName: String
    public let productKind: String
    public let productName: String
    public let tradingEnvironment: String
    public let accountProfileID: String
    public let namespaceKey: String
    public let supportState: ReleaseV0190DashboardVenueProductRegistrySupportState
    public let runtimeRegistrationState: String
    public let capabilitySummary: [String]
    public let activeCapabilities: [String]
    public let placeholderCapabilities: [String]
    public let futureGatedCapabilities: [String]
    public let forbiddenCapabilities: [String]
    public let unsupportedOperationReasons: [String]
    public let visibleInDashboard: Bool
    public let readOnly: Bool
    public let commandHandlerBound: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool
    public let liveCommandVisible: Bool
    public let endpointConnected: Bool
    public let secretRead: Bool
    public let brokerEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public var rowHeld: Bool {
        venueID.isEmpty == false
            && venueName.isEmpty == false
            && productKind.isEmpty == false
            && productName.isEmpty == false
            && tradingEnvironment == ReleaseV0181TradingEnvironment.testnet.rawValue
            && accountProfileID.isEmpty == false
            && namespaceKey == "\(venueID)/\(productKind)/\(tradingEnvironment)/\(accountProfileID)"
            && runtimeRegistrationState.isEmpty == false
            && capabilitySummary.count == ReleaseV0190VenueProductCapability.allCases.count
            && capabilitySummary.allSatisfy { $0.contains("=") }
            && (activeCapabilities.isEmpty == false || supportState != .active)
            && unsupportedOperationReasons.isEmpty == false
            && visibleInDashboard
            && readOnly
            && commandHandlerBound == false
            && tradingButtonVisible == false
            && orderFormVisible == false
            && liveCommandVisible == false
            && endpointConnected == false
            && secretRead == false
            && brokerEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public init(
        venueID: String,
        venueName: String,
        productKind: String,
        productName: String,
        tradingEnvironment: String,
        accountProfileID: String,
        namespaceKey: String,
        supportState: ReleaseV0190DashboardVenueProductRegistrySupportState,
        runtimeRegistrationState: String,
        capabilitySummary: [String],
        activeCapabilities: [String],
        placeholderCapabilities: [String],
        futureGatedCapabilities: [String],
        forbiddenCapabilities: [String],
        unsupportedOperationReasons: [String],
        visibleInDashboard: Bool = true,
        readOnly: Bool = true,
        commandHandlerBound: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false,
        liveCommandVisible: Bool = false,
        endpointConnected: Bool = false,
        secretRead: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.venueID = venueID
        self.venueName = venueName
        self.productKind = productKind
        self.productName = productName
        self.tradingEnvironment = tradingEnvironment
        self.accountProfileID = accountProfileID
        self.namespaceKey = namespaceKey
        self.supportState = supportState
        self.runtimeRegistrationState = runtimeRegistrationState
        self.capabilitySummary = capabilitySummary
        self.activeCapabilities = activeCapabilities
        self.placeholderCapabilities = placeholderCapabilities
        self.futureGatedCapabilities = futureGatedCapabilities
        self.forbiddenCapabilities = forbiddenCapabilities
        self.unsupportedOperationReasons = unsupportedOperationReasons
        self.visibleInDashboard = visibleInDashboard
        self.readOnly = readOnly
        self.commandHandlerBound = commandHandlerBound
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible
        self.liveCommandVisible = liveCommandVisible
        self.endpointConnected = endpointConnected
        self.secretRead = secretRead
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV0190DashboardVenueProductRegistrySurfaceViewModel 是 #1213 的 Dashboard 只读面。
///
/// Surface 将 v0.19.0 venue/product registry、capability matrix 和 runtime registry 结果
/// 投影为可读 rows。它只供 operator inspect，不提供任何命令、endpoint 连接或 cutover 授权。
public struct ReleaseV0190DashboardVenueProductRegistrySurfaceViewModel:
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
    public let rows: [ReleaseV0190DashboardVenueProductRegistryRow]
    public let supportedVenueProductEnvironmentCombinationsVisible: Bool
    public let activePlaceholderFutureGatedForbiddenStatesVisible: Bool
    public let capabilitySummaryVisible: Bool
    public let unsupportedOperationReasonsVisible: Bool
    public let readOnly: Bool
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

    public var boundaryHeld: Bool {
        source.isReadModelOnly
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && rows.count == 4
            && rows.map(\.namespaceKey) == [
                "binance/spot/testnet/binance-spot-testnet-credential-profile-ref",
                "binance/usdmFutures/testnet/binance-usdmFutures-testnet-credential-profile-ref",
                "okx/spot/testnet/okx-spot-testnet-credential-profile-ref",
                "okx/swap/testnet/okx-swap-testnet-credential-profile-ref"
            ]
            && rows.allSatisfy(\.rowHeld)
            && stateLabels == ReleaseV0190DashboardVenueProductRegistrySupportState.allCases.map(\.rawValue)
            && supportedVenueProductEnvironmentCombinationsVisible
            && activePlaceholderFutureGatedForbiddenStatesVisible
            && capabilitySummaryVisible
            && unsupportedOperationReasonsVisible
            && readOnly
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

    public var stateLabels: [String] {
        let rowStates = Set(rows.map(\.supportState.rawValue))
        let forbiddenCapabilityVisible = rows.contains { $0.forbiddenCapabilities.isEmpty == false }
        return ReleaseV0190DashboardVenueProductRegistrySupportState.allCases
            .map(\.rawValue)
            .filter { state in
                rowStates.contains(state) || (state == "forbidden" && forbiddenCapabilityVisible)
            }
    }

    public var activeRowCount: Int {
        rows.filter { $0.supportState == .active }.count
    }

    public var placeholderRowCount: Int {
        rows.filter { $0.supportState == .placeholder }.count
    }

    public var futureGatedRowCount: Int {
        rows.filter { $0.supportState == .futureGated }.count
    }

    public var forbiddenCapabilityCount: Int {
        rows.flatMap(\.forbiddenCapabilities).count
    }

    public var metrics: [DashboardShellMetric] {
        [
            DashboardShellMetric(label: "v0.19 registry rows", value: "\(visibleRowCount)"),
            DashboardShellMetric(label: "v0.19 registry states", value: stateLabels.joined(separator: ",")),
            DashboardShellMetric(label: "v0.19 active targets", value: "\(activeRowCount)"),
            DashboardShellMetric(label: "v0.19 placeholder targets", value: "\(placeholderRowCount)"),
            DashboardShellMetric(label: "v0.19 future-gated targets", value: "\(futureGatedRowCount)"),
            DashboardShellMetric(label: "v0.19 forbidden capabilities", value: "\(forbiddenCapabilityCount)"),
            DashboardShellMetric(label: "Boundary", value: boundaryHeld ? "confirmed" : "breached")
        ]
    }

    public var details: [String] {
        rows.map { row in
            """
            \(row.namespaceKey): \(row.supportState.rawValue); runtime=\(row.runtimeRegistrationState); \
            capabilities=\(row.capabilitySummary.joined(separator: ",")); \
            unsupported=\(row.unsupportedOperationReasons.joined(separator: " | "))
            """
        } + [
            "Dashboard command surface: none",
            "Trading button: none",
            "Order form: none",
            "Live command: none",
            "Submit / cancel / replace: none",
            "Production endpoint: none",
            "Production cutover: none",
            "Registry boundary: \(boundaryHeld ? "confirmed" : "breached")"
        ]
    }

    public init(
        issueID: String = "GH-1213",
        upstreamIssueIDs: [String] = ["GH-1211", "GH-1212"],
        previousIssueID: String = "GH-1212",
        releaseVersion: String = "v0.19.0",
        source: ViewModelSourceContract = ViewModelSourceContract(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        rows: [ReleaseV0190DashboardVenueProductRegistryRow],
        supportedVenueProductEnvironmentCombinationsVisible: Bool = true,
        activePlaceholderFutureGatedForbiddenStatesVisible: Bool = true,
        capabilitySummaryVisible: Bool = true,
        unsupportedOperationReasonsVisible: Bool = true,
        readOnly: Bool = true,
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
        self.rows = rows
        self.supportedVenueProductEnvironmentCombinationsVisible =
            supportedVenueProductEnvironmentCombinationsVisible
        self.activePlaceholderFutureGatedForbiddenStatesVisible =
            activePlaceholderFutureGatedForbiddenStatesVisible
        self.capabilitySummaryVisible = capabilitySummaryVisible
        self.unsupportedOperationReasonsVisible = unsupportedOperationReasonsVisible
        self.readOnly = readOnly
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

    public static var deterministicFixture: ReleaseV0190DashboardVenueProductRegistrySurfaceViewModel {
        do {
            return try deterministic()
        } catch {
            preconditionFailure("Release v0.19.0 Dashboard registry surface fixture failed: \(error)")
        }
    }

    public static func deterministic() throws -> ReleaseV0190DashboardVenueProductRegistrySurfaceViewModel {
        try ReleaseV0190DashboardVenueProductRegistrySurfaceViewModel(
            rows: [
                row(venueID: .binance, productKind: .spot, supportState: .active),
                row(venueID: .binance, productKind: .usdmFutures, supportState: .futureGated),
                row(venueID: .okx, productKind: .spot, supportState: .placeholder),
                row(venueID: .okx, productKind: .swap, supportState: .futureGated)
            ]
        )
    }

    public static let requiredValidationAnchors = [
        "GH-1213-VERIFY-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE",
        "TVM-RELEASE-V0190-DASHBOARD-VENUE-PRODUCT-REGISTRY-SURFACE",
        "V0190-008-DASHBOARD-REGISTRY-READ-ONLY-SURFACE",
        "V0190-008-BINANCE-SPOT-FUTURES-OKX-SPOT-SWAP-STATES",
        "V0190-008-ACTIVE-PLACEHOLDER-FUTURE-GATED-FORBIDDEN",
        "V0190-008-CAPABILITY-UNSUPPORTED-REASONS",
        "V0190-008-DASHBOARD-READ-ONLY-NO-COMMANDS",
        "V0190-008-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter AppTests/testGH1213DashboardVenueProductRegistrySurfaceShowsReadOnlySupportStatus",
        "swift test --filter TargetGraphTests/testGH1213DashboardVenueProductRegistrySurfaceIsAnchoredInV0190Guards",
        "bash checks/verify-v0.19.0-dashboard-venue-product-registry-surface.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    private static func row(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        supportState: ReleaseV0190DashboardVenueProductRegistrySupportState
    ) throws -> ReleaseV0190DashboardVenueProductRegistryRow {
        let pair = ReleaseV0181VenueProductPair(venueID: venueID, productKind: productKind)
        let accountProfileID = try ReleaseV0181AccountProfileID(
            ReleaseV0190VenueCredentialProfileEntry.expectedProfileID(
                pair: pair,
                tradingEnvironment: .testnet
            )
        )
        let target = try ReleaseV0190VenueProductTarget(
            venueID: venueID,
            productKind: productKind,
            tradingEnvironment: .testnet,
            accountProfileID: accountProfileID
        )
        let venueEntry = try ReleaseV0190VenueRegistry.entry(for: venueID)
        let productEntry = try ReleaseV0190ProductRegistry.entry(for: productKind)
        let profile = try ReleaseV0190VenueProductCapabilityMatrix.profile(
            venueID: venueID,
            productKind: productKind
        )
        let runtimeState = runtimeRegistrationState(target: target)
        let decisions = profile.decisions

        return ReleaseV0190DashboardVenueProductRegistryRow(
            venueID: venueID.rawValue,
            venueName: venueEntry.displayName,
            productKind: productKind.rawValue,
            productName: productEntry.displayName,
            tradingEnvironment: ReleaseV0181TradingEnvironment.testnet.rawValue,
            accountProfileID: accountProfileID.rawValue,
            namespaceKey: target.namespaceKey,
            supportState: supportState,
            runtimeRegistrationState: runtimeState,
            capabilitySummary: decisions.map { "\($0.capability.rawValue)=\($0.state.rawValue)" },
            activeCapabilities: capabilities(in: decisions, matching: .active),
            placeholderCapabilities: capabilities(in: decisions, matching: .placeholder),
            futureGatedCapabilities: capabilities(in: decisions, matching: .futureGated),
            forbiddenCapabilities: capabilities(in: decisions, matching: .forbidden),
            unsupportedOperationReasons: unsupportedReasons(decisions: decisions, runtimeState: runtimeState)
        )
    }

    private static func capabilities(
        in decisions: [ReleaseV0190VenueProductCapabilityDecision],
        matching state: ReleaseV0190VenueProductCapabilityState
    ) -> [String] {
        decisions
            .filter { $0.state == state }
            .map(\.capability.rawValue)
    }

    private static func runtimeRegistrationState(
        target: ReleaseV0190VenueProductTarget
    ) -> String {
        do {
            let registration = try ReleaseV0190VenueProductRuntimeRegistry.registration(
                venueID: target.venueID,
                productKind: target.productKind,
                tradingEnvironment: target.tradingEnvironment,
                accountProfileID: target.accountProfileID
            )
            return "registered:\(registration.registeredOperations.map(\.rawValue).joined(separator: ","))"
        } catch {
            return "unsupported:\(String(describing: error))"
        }
    }

    private static func unsupportedReasons(
        decisions: [ReleaseV0190VenueProductCapabilityDecision],
        runtimeState: String
    ) -> [String] {
        let capabilityReasons = decisions
            .filter { $0.state != .active }
            .map { "\($0.capability.rawValue): \($0.state.rawValue) - \($0.reason)" }
        let runtimeReason = runtimeState.hasPrefix("registered:")
            ? "runtime: unregistered operations fail closed outside submit,cancel,queryStatus"
            : "runtime: \(runtimeState)"
        return [runtimeReason] + capabilityReasons
    }
}
