import DomainModel
import Foundation

// GH-1214 static contract boundary:
// cliCommand=venue-product
// cliActions=list,capabilities,explain
// cliOutputStates=active,placeholder,forbidden,future-gated
// cliRegistryRows=binance/spot,binance/usdmFutures,okx/spot,okx/swap
// cliReadOnlyInspectOnly=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false
// GH-1214-VERIFY-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT
// TVM-RELEASE-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT
// V0190-009-CLI-REGISTRY-LIST
// V0190-009-CLI-CAPABILITIES-INSPECT
// V0190-009-CLI-EXPLAIN-UNSUPPORTED
// V0190-009-ACTIVE-PLACEHOLDER-FORBIDDEN-FUTURE-GATED
// V0190-009-READ-ONLY-NO-COMMANDS
// V0190-009-NO-PRODUCTION-CUTOVER

/// ReleaseV0190CLIVenueProductRegistryInspectError 是 #1214 CLI inspect 的 fail-closed 错误。
///
/// 错误消息面向 operator 展示，保持可读，但不泄漏 secret、不构造 endpoint request，也不创建
/// submit / cancel / replace 等交易命令路径。
public enum ReleaseV0190CLIVenueProductRegistryInspectError: Error, CustomStringConvertible, Equatable {
    case invalidArguments(expected: String, actual: String)
    case unsupportedVenueProduct(expected: String, actual: String)

    public var description: String {
        switch self {
        case let .invalidArguments(expected, actual):
            "mtpro venue-product arguments expected \(expected), actual \(actual)"
        case let .unsupportedVenueProduct(expected, actual):
            "mtpro venue-product unsupported venue/product expected \(expected), actual \(actual)"
        }
    }
}

/// ReleaseV0190CLIVenueProductRegistryInspectRow 是 CLI 输出使用的只读 registry row。
///
/// Row 聚合 typed venue/product registry、capability matrix 和 runtime registry 的本地证据；
/// 它只渲染 operator inspection 文本，不读取 credential value、不连接 endpoint / broker、
/// 不发送 order，也不授权 production cutover。
public struct ReleaseV0190CLIVenueProductRegistryInspectRow: Equatable, Sendable {
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let venueDisplayName: String
    public let productDisplayName: String
    public let supportStatus: String
    public let runtimeRegistrationState: String
    public let capabilityDecisions: [ReleaseV0190VenueProductCapabilityDecision]
    public let unsupportedReasons: [String]
    public let readsSecretValue: Bool
    public let connectsEndpoint: Bool
    public let brokerEndpointConnected: Bool
    public let submitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var pairKey: String {
        "\(venueID.rawValue)/\(productKind.rawValue)"
    }

    public var boundaryHeld: Bool {
        readsSecretValue == false
            && connectsEndpoint == false
            && brokerEndpointConnected == false
            && submitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public var activeCapabilities: [String] {
        capabilities(in: .active)
    }

    public var placeholderCapabilities: [String] {
        capabilities(in: .placeholder)
    }

    public var forbiddenCapabilities: [String] {
        capabilities(in: .forbidden)
    }

    public var futureGatedCapabilities: [String] {
        capabilities(in: .futureGated)
    }

    public init(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind,
        venueDisplayName: String,
        productDisplayName: String,
        supportStatus: String,
        runtimeRegistrationState: String,
        capabilityDecisions: [ReleaseV0190VenueProductCapabilityDecision],
        unsupportedReasons: [String],
        readsSecretValue: Bool = false,
        connectsEndpoint: Bool = false,
        brokerEndpointConnected: Bool = false,
        submitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.venueID = venueID
        self.productKind = productKind
        self.venueDisplayName = venueDisplayName
        self.productDisplayName = productDisplayName
        self.supportStatus = supportStatus
        self.runtimeRegistrationState = runtimeRegistrationState
        self.capabilityDecisions = capabilityDecisions
        self.unsupportedReasons = unsupportedReasons
        self.readsSecretValue = readsSecretValue
        self.connectsEndpoint = connectsEndpoint
        self.brokerEndpointConnected = brokerEndpointConnected
        self.submitCancelReplaceEnabled = submitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    private func capabilities(in state: ReleaseV0190VenueProductCapabilityState) -> [String] {
        capabilityDecisions
            .filter { $0.state == state }
            .map(\.capability.rawValue)
    }
}

/// ReleaseV0190CLIVenueProductRegistryInspect 实现 `mtpro venue-product` 只读 inspect 命令。
///
/// 该命令只支持 list / capabilities / explain 三个 action。所有输出都来自本地 deterministic
/// registry evidence；unknown 或 unsupported venue/product 会 fail closed，不会进入 runtime command path。
public enum ReleaseV0190CLIVenueProductRegistryInspect {
    public static let cliCommand = "venue-product"
    public static let verificationAnchor = "GH-1214-VERIFY-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT"
    public static let validationAnchor = "TVM-RELEASE-V0190-CLI-VENUE-PRODUCT-REGISTRY-INSPECT"
    public static let supportedActions = [
        "list",
        "capabilities --venue <venue> --product <product>",
        "explain --venue <venue> --product <product>"
    ]
    public static let stateLabels = ["active", "placeholder", "forbidden", "future-gated"]

    public static var productionTradingEnabledByDefault: Bool { false }
    public static var productionSecretReadEnabled: Bool { false }
    public static var productionEndpointConnectionEnabled: Bool { false }
    public static var productionBrokerConnectionEnabled: Bool { false }
    public static var productionOrderSubmitCancelReplaceEnabled: Bool { false }
    public static var productionCutoverAuthorized: Bool { false }

    public static func commandLineOutput(arguments: [String]) throws -> String {
        guard arguments.first == cliCommand, arguments.count >= 2 else {
            throw ReleaseV0190CLIVenueProductRegistryInspectError.invalidArguments(
                expected: "\(cliCommand) \(supportedActions.joined(separator: " | "))",
                actual: arguments.joined(separator: " ")
            )
        }

        switch arguments[1] {
        case "list":
            guard arguments.count == 2 else {
                throw ReleaseV0190CLIVenueProductRegistryInspectError.invalidArguments(
                    expected: "\(cliCommand) list",
                    actual: arguments.joined(separator: " ")
                )
            }
            return try listOutput()
        case "capabilities":
            let pair = try parseVenueProduct(arguments: arguments)
            return try capabilitiesOutput(venueID: pair.venueID, productKind: pair.productKind)
        case "explain":
            let pair = try parseVenueProduct(arguments: arguments)
            return try explainOutput(venueID: pair.venueID, productKind: pair.productKind)
        default:
            throw ReleaseV0190CLIVenueProductRegistryInspectError.invalidArguments(
                expected: supportedActions.joined(separator: " | "),
                actual: arguments.joined(separator: " ")
            )
        }
    }

    public static func deterministicRows() throws -> [ReleaseV0190CLIVenueProductRegistryInspectRow] {
        try [
            row(venueID: .binance, productKind: .spot),
            row(venueID: .binance, productKind: .usdmFutures),
            row(venueID: .okx, productKind: .spot),
            row(venueID: .okx, productKind: .swap)
        ]
    }

    public static func row(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) throws -> ReleaseV0190CLIVenueProductRegistryInspectRow {
        guard ReleaseV0190VenueProductTargetRegistry.supportsPair(
            venueID: venueID,
            productKind: productKind
        ) else {
            throw ReleaseV0190CLIVenueProductRegistryInspectError.unsupportedVenueProduct(
                expected: "binance/spot,binance/usdmFutures,okx/spot,okx/swap",
                actual: "\(venueID.rawValue)/\(productKind.rawValue)"
            )
        }

        let venue = try ReleaseV0190VenueRegistry.entry(for: venueID)
        let product = try ReleaseV0190ProductRegistry.entry(for: productKind)
        let profile = try ReleaseV0190VenueProductCapabilityMatrix.profile(
            venueID: venueID,
            productKind: productKind
        )
        let runtimeState = runtimeRegistrationState(venueID: venueID, productKind: productKind)
        return ReleaseV0190CLIVenueProductRegistryInspectRow(
            venueID: venueID,
            productKind: productKind,
            venueDisplayName: venue.displayName,
            productDisplayName: product.displayName,
            supportStatus: supportStatus(venueID: venueID, productKind: productKind),
            runtimeRegistrationState: runtimeState,
            capabilityDecisions: profile.decisions,
            unsupportedReasons: unsupportedReasons(from: profile.decisions, runtimeState: runtimeState)
        )
    }

    public static func listOutput() throws -> String {
        let rows = try deterministicRows()
        let rowLines = rows.map { row in
            [
                "row=\(row.pairKey)",
                "venue=\(row.venueDisplayName)",
                "product=\(row.productDisplayName)",
                "status=\(row.supportStatus)",
                "runtime=\(row.runtimeRegistrationState)",
                "active=\(joined(row.activeCapabilities))",
                "placeholder=\(joined(row.placeholderCapabilities))",
                "forbidden=\(joined(row.forbiddenCapabilities))",
                "futureGated=\(joined(row.futureGatedCapabilities))",
                "boundaryHeld=\(row.boundaryHeld)"
            ].joined(separator: " ")
        }

        return (headerLines(action: "list", rows: rows) + rowLines)
            .joined(separator: "\n")
    }

    public static func capabilitiesOutput(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) throws -> String {
        let row = try row(venueID: venueID, productKind: productKind)
        let capabilityLines = row.capabilityDecisions.map { decision in
            "capability.\(decision.capability.rawValue)=\(displayState(decision.state)) reason=\(decision.reason)"
        }

        return (
            headerLines(action: "capabilities", rows: [row]) + [
                "target=\(row.pairKey)",
                "status=\(row.supportStatus)",
                "runtime=\(row.runtimeRegistrationState)"
            ] + capabilityLines + boundaryLines()
        ).joined(separator: "\n")
    }

    public static func explainOutput(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) throws -> String {
        let row = try row(venueID: venueID, productKind: productKind)
        let reasonLines = row.unsupportedReasons.map { "unsupportedReason=\($0)" }

        return (
            headerLines(action: "explain", rows: [row]) + [
                "target=\(row.pairKey)",
                "status=\(row.supportStatus)",
                "runtime=\(row.runtimeRegistrationState)",
                "operatorVisibleRegistryInspectionOnly=true",
                "commandPathIntroduced=false",
                "submitCancelReplaceCommandPath=false"
            ] + reasonLines + boundaryLines()
        ).joined(separator: "\n")
    }

    private static func headerLines(
        action: String,
        rows: [ReleaseV0190CLIVenueProductRegistryInspectRow]
    ) -> [String] {
        [
            "mtpro venue-product \(action)",
            "issue=GH-1214",
            "verificationAnchor=\(verificationAnchor)",
            "validationAnchor=\(validationAnchor)",
            "supportedActions=\(supportedActions.joined(separator: ","))",
            "states=\(stateLabels.joined(separator: ","))",
            "registryRows=\(rows.count)"
        ]
    }

    private static func boundaryLines() -> [String] {
        [
            "readOnlyInspectOnly=true",
            "productionTradingEnabledByDefault=\(productionTradingEnabledByDefault)",
            "productionSecretRead=\(productionSecretReadEnabled)",
            "productionEndpointConnected=\(productionEndpointConnectionEnabled)",
            "brokerEndpointConnected=\(productionBrokerConnectionEnabled)",
            "productionOrderSubmitCancelReplaceEnabled=\(productionOrderSubmitCancelReplaceEnabled)",
            "productionCutoverAuthorized=\(productionCutoverAuthorized)",
            "boundaryHeld=true"
        ]
    }

    private static func supportStatus(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) -> String {
        switch (venueID, productKind) {
        case (.binance, .spot):
            "active"
        case (.binance, .usdmFutures):
            "future-gated"
        case (.okx, .spot):
            "placeholder"
        case (.okx, .swap):
            "future-gated"
        default:
            "forbidden"
        }
    }

    private static func runtimeRegistrationState(
        venueID: ReleaseV0181VenueID,
        productKind: ReleaseV0181ProductKind
    ) -> String {
        do {
            let pair = ReleaseV0181VenueProductPair(venueID: venueID, productKind: productKind)
            let profileID = try ReleaseV0181AccountProfileID(
                ReleaseV0190VenueCredentialProfileEntry.expectedProfileID(
                    pair: pair,
                    tradingEnvironment: .testnet
                )
            )
            let registration = try ReleaseV0190VenueProductRuntimeRegistry.registration(
                venueID: venueID,
                productKind: productKind,
                tradingEnvironment: .testnet,
                accountProfileID: profileID
            )
            return "registered:\(registration.registeredOperations.map(\.rawValue).joined(separator: ","))"
        } catch {
            return "unsupported:\(String(describing: error))"
        }
    }

    private static func unsupportedReasons(
        from decisions: [ReleaseV0190VenueProductCapabilityDecision],
        runtimeState: String
    ) -> [String] {
        var reasons = decisions
            .filter { $0.state != .active }
            .map { "\($0.capability.rawValue):\(displayState($0.state)):\($0.reason)" }
        if runtimeState.hasPrefix("unsupported:") {
            reasons.append(runtimeState)
        }
        return reasons
    }

    private static func parseVenueProduct(
        arguments: [String]
    ) throws -> ReleaseV0181VenueProductPair {
        guard arguments.count == 6 else {
            throw ReleaseV0190CLIVenueProductRegistryInspectError.invalidArguments(
                expected: "\(cliCommand) \(arguments.dropFirst().first ?? "action") --venue <venue> --product <product>",
                actual: arguments.joined(separator: " ")
            )
        }

        var venue: String?
        var product: String?
        var index = 2
        while index < arguments.count {
            switch arguments[index] {
            case "--venue":
                guard index + 1 < arguments.count else {
                    throw ReleaseV0190CLIVenueProductRegistryInspectError.invalidArguments(
                        expected: "--venue <venue>",
                        actual: arguments.joined(separator: " ")
                    )
                }
                venue = arguments[index + 1]
                index += 2
            case "--product":
                guard index + 1 < arguments.count else {
                    throw ReleaseV0190CLIVenueProductRegistryInspectError.invalidArguments(
                        expected: "--product <product>",
                        actual: arguments.joined(separator: " ")
                    )
                }
                product = arguments[index + 1]
                index += 2
            default:
                throw ReleaseV0190CLIVenueProductRegistryInspectError.invalidArguments(
                    expected: "--venue <venue> --product <product>",
                    actual: arguments.joined(separator: " ")
                )
            }
        }

        guard let venue, let product else {
            throw ReleaseV0190CLIVenueProductRegistryInspectError.invalidArguments(
                expected: "--venue <venue> --product <product>",
                actual: arguments.joined(separator: " ")
            )
        }

        return ReleaseV0181VenueProductPair(
            venueID: try ReleaseV0181VenueID(validating: venue, field: "mtpro.venueProduct.venue"),
            productKind: try ReleaseV0181ProductKind(validating: product, field: "mtpro.venueProduct.product")
        )
    }

    private static func displayState(_ state: ReleaseV0190VenueProductCapabilityState) -> String {
        switch state {
        case .active:
            "active"
        case .placeholder:
            "placeholder"
        case .forbidden:
            "forbidden"
        case .futureGated:
            "future-gated"
        }
    }

    private static func joined(_ values: [String]) -> String {
        values.isEmpty ? "none" : values.joined(separator: ",")
    }
}
