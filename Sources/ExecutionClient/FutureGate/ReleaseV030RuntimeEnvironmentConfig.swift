import DomainModel
import Foundation

/// ReleaseV030RuntimeEnvironmentEndpointPolicy 描述 v0.3.0 rehearsal mode 能使用的 endpoint 形态。
///
/// 这些 policy 都不是 production endpoint connector。`productionBlockedNoEndpoint` 明确表示生产路径
/// 没有 endpoint 可用，不能被自动 fallback 或 hidden flag 打开。
public enum ReleaseV030RuntimeEnvironmentEndpointPolicy: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case localFixtureOnly = "local fixture endpoint only"
    case binanceTestnetReferenceOnly = "Binance testnet endpoint reference only"
    case shadowReplayOnly = "shadow replay endpoint evidence only"
    case productionBlockedNoEndpoint = "production blocked no endpoint"
}

/// ReleaseV030RuntimeEnvironmentCredentialPolicy 描述 v0.3.0 rehearsal mode 的 credential 身份边界。
///
/// Policy 只允许 profile / reference / redacted identity，不允许读取 production secret value。
public enum ReleaseV030RuntimeEnvironmentCredentialPolicy: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case localFixtureReference = "local fixture credential reference"
    case testnetProfileReference = "testnet profile reference"
    case shadowRedactedReference = "shadow redacted reference"
    case productionSecretUnavailable = "production secret unavailable"
}

/// ReleaseV030RuntimeEnvironmentRequirement 固定 GH-658 的统一 runtime environment config 要求。
public enum ReleaseV030RuntimeEnvironmentRequirement: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case upstreamRehearsalContractRequired = "upstream rehearsal contract required"
    case explicitEnvironmentModeRequired = "explicit environment mode required"
    case safeDefaultModeRequired = "safe default mode required"
    case dryRunTestnetShadowProductionBlockedCoverage = "dry-run / testnet / shadow / production-blocked coverage"
    case noProductionSecretAutoRead = "no production secret auto-read"
    case noProductionEndpointAutoConnect = "no production endpoint auto-connect"
    case invalidTransitionFailsClosed = "invalid transition fails closed"
    case commandGatewayBoundaryRequired = "CommandGateway boundary required"
}

/// ReleaseV030RuntimeEnvironmentForbiddenCapability 枚举 GH-658 必须拒绝的 environment config 漂移。
public enum ReleaseV030RuntimeEnvironmentForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionTradingDefaultEnabled = "production trading default enabled"
    case productionSecretAutoRead = "production secret auto-read"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case defaultModeProductionEnabled = "default mode production enabled"
    case ambiguousModeFallsBackToProduction = "ambiguous mode falls back to production"
    case invalidTransitionAllowed = "invalid environment transition allowed"
    case dashboardCLICommandGatewayBypass = "Dashboard / CLI CommandGateway bypass"
    case strategyExecutionClientDirectAccess = "Strategy direct ExecutionClient access"
    case nextMilestoneAutoStart = "next milestone auto-start"
}

/// ReleaseV030RuntimeEnvironmentModeConfig 是单个 rehearsal mode 的 endpoint / credential 配置证据。
///
/// 构造时会拒绝 production secret、production endpoint、真实订单和 cutover 授权，避免 mode config
/// 被误用成真实 production runtime 配置。
public struct ReleaseV030RuntimeEnvironmentModeConfig: Codable, Equatable, Sendable {
    public let mode: ReleaseV030RuntimeRehearsalMode
    public let endpointPolicy: ReleaseV030RuntimeEnvironmentEndpointPolicy
    public let credentialPolicy: ReleaseV030RuntimeEnvironmentCredentialPolicy
    public let readsProductionSecret: Bool
    public let autoConnectsProductionEndpoint: Bool
    public let enablesProductionTrading: Bool
    public let submitsProductionOrder: Bool
    public let authorizesProductionCutover: Bool

    public var modeBoundaryHeld: Bool {
        expectedEndpointPolicy(for: mode) == endpointPolicy
            && expectedCredentialPolicy(for: mode) == credentialPolicy
            && readsProductionSecret == false
            && autoConnectsProductionEndpoint == false
            && enablesProductionTrading == false
            && submitsProductionOrder == false
            && authorizesProductionCutover == false
    }

    public init(
        mode: ReleaseV030RuntimeRehearsalMode,
        endpointPolicy: ReleaseV030RuntimeEnvironmentEndpointPolicy,
        credentialPolicy: ReleaseV030RuntimeEnvironmentCredentialPolicy,
        readsProductionSecret: Bool = false,
        autoConnectsProductionEndpoint: Bool = false,
        enablesProductionTrading: Bool = false,
        submitsProductionOrder: Bool = false,
        authorizesProductionCutover: Bool = false
    ) throws {
        guard endpointPolicy == expectedEndpointPolicy(for: mode) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointPolicy",
                expected: expectedEndpointPolicy(for: mode).rawValue,
                actual: endpointPolicy.rawValue
            )
        }
        guard credentialPolicy == expectedCredentialPolicy(for: mode) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "credentialPolicy",
                expected: expectedCredentialPolicy(for: mode).rawValue,
                actual: credentialPolicy.rawValue
            )
        }
        guard readsProductionSecret == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readsProductionSecret")
        }
        guard autoConnectsProductionEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("autoConnectsProductionEndpoint")
        }
        guard enablesProductionTrading == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("enablesProductionTrading")
        }
        guard submitsProductionOrder == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("submitsProductionOrder")
        }
        guard authorizesProductionCutover == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("authorizesProductionCutover")
        }

        self.mode = mode
        self.endpointPolicy = endpointPolicy
        self.credentialPolicy = credentialPolicy
        self.readsProductionSecret = readsProductionSecret
        self.autoConnectsProductionEndpoint = autoConnectsProductionEndpoint
        self.enablesProductionTrading = enablesProductionTrading
        self.submitsProductionOrder = submitsProductionOrder
        self.authorizesProductionCutover = authorizesProductionCutover
    }
}

/// ReleaseV030RuntimeEnvironmentTransition 表示 mode 之间允许的 deterministic transition。
///
/// Transition 只能在 rehearsal mode 之间移动，且必须保持 production capability 关闭。未列入
/// required transitions 的路径必须 fail closed。
public struct ReleaseV030RuntimeEnvironmentTransition: Codable, Equatable, Hashable, Sendable {
    public let from: ReleaseV030RuntimeRehearsalMode
    public let to: ReleaseV030RuntimeRehearsalMode
    public let transitionAnchor: String
    public let readsProductionSecret: Bool
    public let autoConnectsProductionEndpoint: Bool
    public let enablesProductionTrading: Bool
    public let submitsProductionOrder: Bool
    public let authorizesProductionCutover: Bool

    public var transitionBoundaryHeld: Bool {
        transitionAnchor.isEmpty == false
            && readsProductionSecret == false
            && autoConnectsProductionEndpoint == false
            && enablesProductionTrading == false
            && submitsProductionOrder == false
            && authorizesProductionCutover == false
    }

    public init(
        from: ReleaseV030RuntimeRehearsalMode,
        to: ReleaseV030RuntimeRehearsalMode,
        transitionAnchor: String,
        readsProductionSecret: Bool = false,
        autoConnectsProductionEndpoint: Bool = false,
        enablesProductionTrading: Bool = false,
        submitsProductionOrder: Bool = false,
        authorizesProductionCutover: Bool = false
    ) throws {
        guard from != to else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "environmentTransition",
                expected: "distinct rehearsal modes",
                actual: "\(from.rawValue)->\(to.rawValue)"
            )
        }
        guard transitionAnchor.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "transitionAnchor",
                expected: "non-empty transition anchor",
                actual: "empty"
            )
        }
        guard readsProductionSecret == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("transitionReadsProductionSecret")
        }
        guard autoConnectsProductionEndpoint == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("transitionAutoConnectsProductionEndpoint")
        }
        guard enablesProductionTrading == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("transitionEnablesProductionTrading")
        }
        guard submitsProductionOrder == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("transitionSubmitsProductionOrder")
        }
        guard authorizesProductionCutover == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("transitionAuthorizesProductionCutover")
        }

        self.from = from
        self.to = to
        self.transitionAnchor = transitionAnchor
        self.readsProductionSecret = readsProductionSecret
        self.autoConnectsProductionEndpoint = autoConnectsProductionEndpoint
        self.enablesProductionTrading = enablesProductionTrading
        self.submitsProductionOrder = submitsProductionOrder
        self.authorizesProductionCutover = authorizesProductionCutover
    }
}

/// ReleaseV030RuntimeEnvironmentConfig 是 GH-658 的统一 runtime environment 配置合同。
///
/// 它绑定 GH-657 rehearsal contract，并把 default mode、mode config 和 transition allowlist
/// 固定为可本地验证的 deterministic evidence，不提供 production endpoint、secret 或订单执行能力。
public struct ReleaseV030RuntimeEnvironmentConfig: Codable, Equatable, Sendable {
    public let configID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let upstreamRehearsalContractHeld: Bool
    public let defaultMode: ReleaseV030RuntimeRehearsalMode
    public let allowedDefaultModes: [ReleaseV030RuntimeRehearsalMode]
    public let modeConfigs: [ReleaseV030RuntimeEnvironmentModeConfig]
    public let allowedTransitions: [ReleaseV030RuntimeEnvironmentTransition]
    public let requirements: [ReleaseV030RuntimeEnvironmentRequirement]
    public let forbiddenCapabilities: [ReleaseV030RuntimeEnvironmentForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let ambiguousModeFallsBackToProduction: Bool
    public let invalidTransitionAllowed: Bool
    public let commandGatewayBypassAllowed: Bool
    public let strategyExecutionClientDirectAccessAllowed: Bool
    public let startsNextMilestone: Bool

    public var configHeld: Bool {
        issueID.rawValue == "GH-658"
            && upstreamIssueID.rawValue == "GH-657"
            && downstreamIssueID.rawValue == "GH-659"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == ReleaseV030RuntimeRehearsalContract.requiredProjectName
            && upstreamRehearsalContractHeld
            && defaultMode == .dryRun
            && allowedDefaultModes == Self.requiredAllowedDefaultModes
            && modeConfigs == Self.requiredModeConfigs
            && allowedTransitions == Self.requiredAllowedTransitions
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && safeDefaultHeld
            && modeCoverageHeld
            && transitionCoverageHeld
            && productionCapabilityDefaultsClosed
            && commandPathBypassRejected
            && startsNextMilestone == false
    }

    public var safeDefaultHeld: Bool {
        allowedDefaultModes.contains(defaultMode)
            && defaultMode != .testnet
            && defaultMode != .shadow
    }

    public var modeCoverageHeld: Bool {
        Set(modeConfigs.map(\.mode)) == Set(ReleaseV030RuntimeRehearsalMode.allCases)
            && modeConfigs.allSatisfy(\.modeBoundaryHeld)
    }

    public var transitionCoverageHeld: Bool {
        Set(allowedTransitions) == Set(Self.requiredAllowedTransitions)
            && allowedTransitions.allSatisfy(\.transitionBoundaryHeld)
    }

    public var productionCapabilityDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && ambiguousModeFallsBackToProduction == false
            && invalidTransitionAllowed == false
    }

    public var commandPathBypassRejected: Bool {
        commandGatewayBypassAllowed == false
            && strategyExecutionClientDirectAccessAllowed == false
    }

    public init(
        configID: Identifier = Identifier.constant("gh-658-release-v0.3.0-runtime-environment-config"),
        issueID: Identifier = Identifier.constant("GH-658"),
        upstreamIssueID: Identifier = Identifier.constant("GH-657"),
        downstreamIssueID: Identifier = Identifier.constant("GH-659"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = ReleaseV030RuntimeRehearsalContract.requiredProjectName,
        upstreamRehearsalContractHeld: Bool = true,
        defaultMode: ReleaseV030RuntimeRehearsalMode = .dryRun,
        allowedDefaultModes: [ReleaseV030RuntimeRehearsalMode] = Self.requiredAllowedDefaultModes,
        modeConfigs: [ReleaseV030RuntimeEnvironmentModeConfig] = Self.requiredModeConfigs,
        allowedTransitions: [ReleaseV030RuntimeEnvironmentTransition] = Self.requiredAllowedTransitions,
        requirements: [ReleaseV030RuntimeEnvironmentRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030RuntimeEnvironmentForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        ambiguousModeFallsBackToProduction: Bool = false,
        invalidTransitionAllowed: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        strategyExecutionClientDirectAccessAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            defaultMode: defaultMode,
            allowedDefaultModes: allowedDefaultModes,
            modeConfigs: modeConfigs,
            allowedTransitions: allowedTransitions,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateRequiredTrueFlags(upstreamRehearsalContractHeld: upstreamRehearsalContractHeld)
        try Self.validateForbiddenFlags(
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            ambiguousModeFallsBackToProduction: ambiguousModeFallsBackToProduction,
            invalidTransitionAllowed: invalidTransitionAllowed,
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            strategyExecutionClientDirectAccessAllowed: strategyExecutionClientDirectAccessAllowed,
            startsNextMilestone: startsNextMilestone
        )

        self.configID = configID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.upstreamRehearsalContractHeld = upstreamRehearsalContractHeld
        self.defaultMode = defaultMode
        self.allowedDefaultModes = allowedDefaultModes
        self.modeConfigs = modeConfigs
        self.allowedTransitions = allowedTransitions
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.ambiguousModeFallsBackToProduction = ambiguousModeFallsBackToProduction
        self.invalidTransitionAllowed = invalidTransitionAllowed
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.strategyExecutionClientDirectAccessAllowed = strategyExecutionClientDirectAccessAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static func deterministicFixture() throws -> ReleaseV030RuntimeEnvironmentConfig {
        let upstream = try ReleaseV030RuntimeRehearsalContract.deterministicFixture()
        return try ReleaseV030RuntimeEnvironmentConfig(upstreamRehearsalContractHeld: upstream.contractHeld)
    }

    public func transitionAllowed(from: ReleaseV030RuntimeRehearsalMode, to: ReleaseV030RuntimeRehearsalMode) -> Bool {
        allowedTransitions.contains { $0.from == from && $0.to == to }
    }

    public static let requiredAllowedDefaultModes: [ReleaseV030RuntimeRehearsalMode] = [
        .dryRun,
        .productionBlocked
    ]

    public static let requiredRequirements = ReleaseV030RuntimeEnvironmentRequirement.allCases
    public static let requiredForbiddenCapabilities = ReleaseV030RuntimeEnvironmentForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "V030-02-RUNTIME-ENVIRONMENT-CONFIG",
        "V030-02-DRYRUN-TESTNET-SHADOW-PRODUCTION-BLOCKED-MODES",
        "V030-02-SAFE-DEFAULT-MODE",
        "V030-02-NO-PRODUCTION-SECRET-AUTO-READ",
        "V030-02-NO-PRODUCTION-ENDPOINT-AUTO-CONNECT",
        "V030-02-INVALID-ENVIRONMENT-TRANSITION-FAIL-CLOSED",
        "TVM-RELEASE-V030-RUNTIME-ENVIRONMENT-CONFIG"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH658RuntimeEnvironmentConfigDefaultsSafeAndRejectsProductionTransitions",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static let requiredModeConfigs: [ReleaseV030RuntimeEnvironmentModeConfig] = {
        do {
            return [
                try ReleaseV030RuntimeEnvironmentModeConfig(
                    mode: .dryRun,
                    endpointPolicy: .localFixtureOnly,
                    credentialPolicy: .localFixtureReference
                ),
                try ReleaseV030RuntimeEnvironmentModeConfig(
                    mode: .testnet,
                    endpointPolicy: .binanceTestnetReferenceOnly,
                    credentialPolicy: .testnetProfileReference
                ),
                try ReleaseV030RuntimeEnvironmentModeConfig(
                    mode: .shadow,
                    endpointPolicy: .shadowReplayOnly,
                    credentialPolicy: .shadowRedactedReference
                ),
                try ReleaseV030RuntimeEnvironmentModeConfig(
                    mode: .productionBlocked,
                    endpointPolicy: .productionBlockedNoEndpoint,
                    credentialPolicy: .productionSecretUnavailable
                )
            ]
        } catch {
            preconditionFailure("GH-658 runtime environment mode configs must be valid: \(error)")
        }
    }()

    public static let requiredAllowedTransitions: [ReleaseV030RuntimeEnvironmentTransition] = {
        do {
            return [
                try ReleaseV030RuntimeEnvironmentTransition(
                    from: .productionBlocked,
                    to: .dryRun,
                    transitionAnchor: "V030-02-TRANSITION-PRODUCTION-BLOCKED-TO-DRYRUN"
                ),
                try ReleaseV030RuntimeEnvironmentTransition(
                    from: .dryRun,
                    to: .testnet,
                    transitionAnchor: "V030-02-TRANSITION-DRYRUN-TO-TESTNET"
                ),
                try ReleaseV030RuntimeEnvironmentTransition(
                    from: .dryRun,
                    to: .shadow,
                    transitionAnchor: "V030-02-TRANSITION-DRYRUN-TO-SHADOW"
                ),
                try ReleaseV030RuntimeEnvironmentTransition(
                    from: .testnet,
                    to: .shadow,
                    transitionAnchor: "V030-02-TRANSITION-TESTNET-TO-SHADOW"
                ),
                try ReleaseV030RuntimeEnvironmentTransition(
                    from: .dryRun,
                    to: .productionBlocked,
                    transitionAnchor: "V030-02-TRANSITION-DRYRUN-TO-PRODUCTION-BLOCKED"
                ),
                try ReleaseV030RuntimeEnvironmentTransition(
                    from: .testnet,
                    to: .productionBlocked,
                    transitionAnchor: "V030-02-TRANSITION-TESTNET-TO-PRODUCTION-BLOCKED"
                ),
                try ReleaseV030RuntimeEnvironmentTransition(
                    from: .shadow,
                    to: .productionBlocked,
                    transitionAnchor: "V030-02-TRANSITION-SHADOW-TO-PRODUCTION-BLOCKED"
                )
            ]
        } catch {
            preconditionFailure("GH-658 runtime environment transitions must be valid: \(error)")
        }
    }()
}

private extension ReleaseV030RuntimeEnvironmentConfig {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        defaultMode: ReleaseV030RuntimeRehearsalMode,
        allowedDefaultModes: [ReleaseV030RuntimeRehearsalMode],
        modeConfigs: [ReleaseV030RuntimeEnvironmentModeConfig],
        allowedTransitions: [ReleaseV030RuntimeEnvironmentTransition],
        requirements: [ReleaseV030RuntimeEnvironmentRequirement],
        forbiddenCapabilities: [ReleaseV030RuntimeEnvironmentForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == ReleaseV030RuntimeRehearsalContract.requiredProjectName, ReleaseV030RuntimeRehearsalContract.requiredProjectName, projectName),
            ("defaultMode", defaultMode == .dryRun, ReleaseV030RuntimeRehearsalMode.dryRun.rawValue, defaultMode.rawValue),
            (
                "allowedDefaultModes",
                allowedDefaultModes == requiredAllowedDefaultModes,
                requiredAllowedDefaultModes.map(\.rawValue).joined(separator: ","),
                allowedDefaultModes.map(\.rawValue).joined(separator: ",")
            ),
            (
                "modeConfigs",
                modeConfigs == requiredModeConfigs,
                requiredModeConfigs.map(\.mode.rawValue).joined(separator: ","),
                modeConfigs.map(\.mode.rawValue).joined(separator: ",")
            ),
            (
                "allowedTransitions",
                allowedTransitions == requiredAllowedTransitions,
                requiredAllowedTransitions.map { "\($0.from.rawValue)->\($0.to.rawValue)" }.joined(separator: ","),
                allowedTransitions.map { "\($0.from.rawValue)->\($0.to.rawValue)" }.joined(separator: ",")
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

    static func validateRequiredTrueFlags(upstreamRehearsalContractHeld: Bool) throws {
        guard upstreamRehearsalContractHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamRehearsalContractHeld",
                expected: "true",
                actual: "false"
            )
        }
    }

    static func validateForbiddenFlags(
        productionTradingEnabledByDefault: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        ambiguousModeFallsBackToProduction: Bool,
        invalidTransitionAllowed: Bool,
        commandGatewayBypassAllowed: Bool,
        strategyExecutionClientDirectAccessAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("ambiguousModeFallsBackToProduction", ambiguousModeFallsBackToProduction),
            ("invalidTransitionAllowed", invalidTransitionAllowed),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("strategyExecutionClientDirectAccessAllowed", strategyExecutionClientDirectAccessAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]

        for (field, value) in forbiddenFlags where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(field)
        }
    }
}

private func expectedEndpointPolicy(
    for mode: ReleaseV030RuntimeRehearsalMode
) -> ReleaseV030RuntimeEnvironmentEndpointPolicy {
    switch mode {
    case .dryRun:
        .localFixtureOnly
    case .testnet:
        .binanceTestnetReferenceOnly
    case .shadow:
        .shadowReplayOnly
    case .productionBlocked:
        .productionBlockedNoEndpoint
    }
}

private func expectedCredentialPolicy(
    for mode: ReleaseV030RuntimeRehearsalMode
) -> ReleaseV030RuntimeEnvironmentCredentialPolicy {
    switch mode {
    case .dryRun:
        .localFixtureReference
    case .testnet:
        .testnetProfileReference
    case .shadow:
        .shadowRedactedReference
    case .productionBlocked:
        .productionSecretUnavailable
    }
}
