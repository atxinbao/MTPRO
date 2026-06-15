import DomainModel
import Foundation

/// ReleaseV080RiskPolicyProfileManagementError 描述 GH-816 风控策略 profile 管理合同错误。
///
/// 错误只覆盖本地 `risk_policy.json` profile 的版本、hash、diff、operator metadata
/// 和 run application evidence；它不表达 broker、OMS、endpoint 或订单执行能力。
public enum ReleaseV080RiskPolicyProfileManagementError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyField(String)
    case invalidVersion(String)
    case invalidLimit(field: String, value: Int64)
    case emptyAllowlist(String)
    case duplicateAllowlist(String)
    case forbiddenCapability(String)
    case diffMismatch
    case applicationEvidenceDrift(String)
    case contractDrift(String)

    public var description: String {
        switch self {
        case let .emptyField(field):
            "Release v0.8.0 risk policy profile requires non-empty \(field)"
        case let .invalidVersion(version):
            "Release v0.8.0 risk policy profile rejects invalid version \(version)"
        case let .invalidLimit(field, value):
            "Release v0.8.0 risk policy profile invalid limit \(field): \(value)"
        case let .emptyAllowlist(field):
            "Release v0.8.0 risk policy profile requires non-empty \(field)"
        case let .duplicateAllowlist(field):
            "Release v0.8.0 risk policy profile rejects duplicate \(field)"
        case let .forbiddenCapability(capability):
            "Release v0.8.0 risk policy profile rejected forbidden capability \(capability)"
        case .diffMismatch:
            "Release v0.8.0 risk policy profile deterministic diff mismatch"
        case let .applicationEvidenceDrift(field):
            "Release v0.8.0 risk policy profile application evidence drift: \(field)"
        case let .contractDrift(field):
            "Release v0.8.0 risk policy profile contract drift: \(field)"
        }
    }
}

/// ReleaseV080RiskPolicyProfileOperatorChangeMetadata 固定 operator-managed policy change 元数据。
///
/// metadata 只记录 operator identity reference、变更时间、原因和本地来源；不得保存
/// credential、endpoint、broker adapter 或订单 payload。
public struct ReleaseV080RiskPolicyProfileOperatorChangeMetadata: Codable, Equatable, Sendable {
    public let operatorID: Identifier
    public let changedAtISO8601: String
    public let changeReason: String
    public let changeSource: String
    public let credentialValueStored: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let productionCutoverAuthorized: Bool

    public var metadataHeld: Bool {
        operatorID.rawValue.isEmpty == false
            && changedAtISO8601.contains("T")
            && changedAtISO8601.hasSuffix("Z")
            && changeReason.isEmpty == false
            && changeSource == "local-risk-policy-profile-management"
            && credentialValueStored == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && productionCutoverAuthorized == false
    }

    public init(
        operatorID: Identifier,
        changedAtISO8601: String,
        changeReason: String,
        changeSource: String = "local-risk-policy-profile-management",
        credentialValueStored: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.operatorID = operatorID
        self.changedAtISO8601 = changedAtISO8601
        self.changeReason = changeReason
        self.changeSource = changeSource
        self.credentialValueStored = credentialValueStored
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard metadataHeld else {
            throw ReleaseV080RiskPolicyProfileManagementError.contractDrift("operatorChangeMetadata")
        }
    }
}

/// ReleaseV080RiskPolicyProfileRules 是 v0.8.0 operator-managed `risk_policy.json` 规则体。
///
/// 规则体继承 v0.7 local Risk policy 字段，并额外固定 forbidden capability guard，
/// 确保 profile 不能打开 broker、production endpoint、OMS bypass 或 order command path。
public struct ReleaseV080RiskPolicyProfileRules: Codable, Equatable, Sendable {
    public let maxNotionalMinorUnits: Int64
    public let maxExposureMinorUnits: Int64
    public let killSwitchRequired: Bool
    public let noTradeRequired: Bool
    public let allowedSymbols: [Symbol]
    public let allowedProductTypes: [ProductType]
    public let brokerEnabled: Bool
    public let productionEndpointEnabled: Bool
    public let omsBypassEnabled: Bool
    public let orderCommandPathEnabled: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var rulesHeld: Bool {
        maxNotionalMinorUnits > 0
            && maxExposureMinorUnits > 0
            && allowedSymbols.isEmpty == false
            && allowedProductTypes.isEmpty == false
            && Set(allowedSymbols).count == allowedSymbols.count
            && Set(allowedProductTypes).count == allowedProductTypes.count
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        brokerEnabled == false
            && productionEndpointEnabled == false
            && omsBypassEnabled == false
            && orderCommandPathEnabled == false
            && testnetOrderRoutingAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        maxNotionalMinorUnits: Int64,
        maxExposureMinorUnits: Int64,
        killSwitchRequired: Bool,
        noTradeRequired: Bool,
        allowedSymbols: [Symbol],
        allowedProductTypes: [ProductType],
        brokerEnabled: Bool = false,
        productionEndpointEnabled: Bool = false,
        omsBypassEnabled: Bool = false,
        orderCommandPathEnabled: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard maxNotionalMinorUnits > 0 else {
            throw ReleaseV080RiskPolicyProfileManagementError.invalidLimit(
                field: "maxNotionalMinorUnits",
                value: maxNotionalMinorUnits
            )
        }
        guard maxExposureMinorUnits > 0 else {
            throw ReleaseV080RiskPolicyProfileManagementError.invalidLimit(
                field: "maxExposureMinorUnits",
                value: maxExposureMinorUnits
            )
        }
        guard allowedSymbols.isEmpty == false else {
            throw ReleaseV080RiskPolicyProfileManagementError.emptyAllowlist("allowedSymbols")
        }
        guard allowedProductTypes.isEmpty == false else {
            throw ReleaseV080RiskPolicyProfileManagementError.emptyAllowlist("allowedProductTypes")
        }
        guard Set(allowedSymbols).count == allowedSymbols.count else {
            throw ReleaseV080RiskPolicyProfileManagementError.duplicateAllowlist("allowedSymbols")
        }
        guard Set(allowedProductTypes).count == allowedProductTypes.count else {
            throw ReleaseV080RiskPolicyProfileManagementError.duplicateAllowlist("allowedProductTypes")
        }
        try Self.validateForbiddenFlags(
            brokerEnabled: brokerEnabled,
            productionEndpointEnabled: productionEndpointEnabled,
            omsBypassEnabled: omsBypassEnabled,
            orderCommandPathEnabled: orderCommandPathEnabled,
            testnetOrderRoutingAllowed: testnetOrderRoutingAllowed,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.maxNotionalMinorUnits = maxNotionalMinorUnits
        self.maxExposureMinorUnits = maxExposureMinorUnits
        self.killSwitchRequired = killSwitchRequired
        self.noTradeRequired = noTradeRequired
        self.allowedSymbols = allowedSymbols
        self.allowedProductTypes = allowedProductTypes
        self.brokerEnabled = brokerEnabled
        self.productionEndpointEnabled = productionEndpointEnabled
        self.omsBypassEnabled = omsBypassEnabled
        self.orderCommandPathEnabled = orderCommandPathEnabled
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    private static func validateForbiddenFlags(
        brokerEnabled: Bool,
        productionEndpointEnabled: Bool,
        omsBypassEnabled: Bool,
        orderCommandPathEnabled: Bool,
        testnetOrderRoutingAllowed: Bool,
        productionTradingEnabledByDefault: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        let forbiddenFlags = [
            ("brokerEnabled", brokerEnabled),
            ("productionEndpointEnabled", productionEndpointEnabled),
            ("omsBypassEnabled", omsBypassEnabled),
            ("orderCommandPathEnabled", orderCommandPathEnabled),
            ("testnetOrderRoutingAllowed", testnetOrderRoutingAllowed),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ]
        for (field, value) in forbiddenFlags where value {
            throw ReleaseV080RiskPolicyProfileManagementError.forbiddenCapability(field)
        }
    }
}

/// ReleaseV080RiskPolicyProfile 是 GH-816 的本地 `risk_policy.json` profile。
///
/// Profile 只用于 operator-managed local evidence，可被 run manifest 引用；它不会
/// 启动 RiskEngine runtime、ExecutionEngine、OMS、broker adapter 或真实订单路径。
public struct ReleaseV080RiskPolicyProfile: Codable, Equatable, Sendable {
    public static let canonicalProfilePath = ".local/mtpro/risk_policy.json"

    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let profileID: Identifier
    public let profileVersion: String
    public let profilePath: String
    public let policyHash: String
    public let operatorChangeMetadata: ReleaseV080RiskPolicyProfileOperatorChangeMetadata
    public let rules: ReleaseV080RiskPolicyProfileRules
    public let appliedRunIDs: [Identifier]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]

    public var profileHeld: Bool {
        issueID.rawValue == "GH-816"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-810", "GH-811"]
            && releaseVersion == "v0.8.0"
            && profileID.rawValue.isEmpty == false
            && profileVersion.hasPrefix("v0.8.0-risk-policy-profile.")
            && profilePath == Self.canonicalProfilePath
            && policyHash == Self.stablePolicyHash(
                profileID: profileID,
                profileVersion: profileVersion,
                profilePath: profilePath,
                operatorChangeMetadata: operatorChangeMetadata,
                rules: rules,
                appliedRunIDs: appliedRunIDs
            )
            && operatorChangeMetadata.metadataHeld
            && rules.rulesHeld
            && appliedRunIDs.isEmpty == false
            && Set(appliedRunIDs).count == appliedRunIDs.count
            && validationAnchors == ReleaseV080RiskPolicyProfileManagementContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV080RiskPolicyProfileManagementContract.requiredValidationCommands
    }

    public var forbiddenBoundaryHeld: Bool {
        operatorChangeMetadata.metadataHeld && rules.forbiddenBoundaryHeld
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-816"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-810"), Identifier.constant("GH-811")],
        releaseVersion: String = "v0.8.0",
        profileID: Identifier,
        profileVersion: String,
        profilePath: String = Self.canonicalProfilePath,
        policyHash: String? = nil,
        operatorChangeMetadata: ReleaseV080RiskPolicyProfileOperatorChangeMetadata,
        rules: ReleaseV080RiskPolicyProfileRules,
        appliedRunIDs: [Identifier],
        validationAnchors: [String] = ReleaseV080RiskPolicyProfileManagementContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV080RiskPolicyProfileManagementContract.requiredValidationCommands
    ) throws {
        guard profileID.rawValue.isEmpty == false else {
            throw ReleaseV080RiskPolicyProfileManagementError.emptyField("profileID")
        }
        guard profileVersion.hasPrefix("v0.8.0-risk-policy-profile.") else {
            throw ReleaseV080RiskPolicyProfileManagementError.invalidVersion(profileVersion)
        }
        guard appliedRunIDs.isEmpty == false else {
            throw ReleaseV080RiskPolicyProfileManagementError.emptyField("appliedRunIDs")
        }
        guard Set(appliedRunIDs).count == appliedRunIDs.count else {
            throw ReleaseV080RiskPolicyProfileManagementError.duplicateAllowlist("appliedRunIDs")
        }

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.profileID = profileID
        self.profileVersion = profileVersion
        self.profilePath = profilePath
        self.operatorChangeMetadata = operatorChangeMetadata
        self.rules = rules
        self.appliedRunIDs = appliedRunIDs
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.policyHash = policyHash ?? Self.stablePolicyHash(
            profileID: profileID,
            profileVersion: profileVersion,
            profilePath: profilePath,
            operatorChangeMetadata: operatorChangeMetadata,
            rules: rules,
            appliedRunIDs: appliedRunIDs
        )

        guard profileHeld else {
            throw ReleaseV080RiskPolicyProfileManagementError.contractDrift("riskPolicyProfile")
        }
    }

    public static func stablePolicyHash(
        profileID: Identifier,
        profileVersion: String,
        profilePath: String,
        operatorChangeMetadata: ReleaseV080RiskPolicyProfileOperatorChangeMetadata,
        rules: ReleaseV080RiskPolicyProfileRules,
        appliedRunIDs: [Identifier]
    ) -> String {
        let input = [
            "profileID=\(profileID.rawValue)",
            "profileVersion=\(profileVersion)",
            "profilePath=\(profilePath)",
            "operatorID=\(operatorChangeMetadata.operatorID.rawValue)",
            "changedAt=\(operatorChangeMetadata.changedAtISO8601)",
            "reason=\(operatorChangeMetadata.changeReason)",
            "source=\(operatorChangeMetadata.changeSource)",
            "maxNotional=\(rules.maxNotionalMinorUnits)",
            "maxExposure=\(rules.maxExposureMinorUnits)",
            "killSwitchRequired=\(rules.killSwitchRequired)",
            "noTradeRequired=\(rules.noTradeRequired)",
            "allowedSymbols=\(rules.allowedSymbols.map(\.rawValue).sorted().joined(separator: ","))",
            "allowedProductTypes=\(rules.allowedProductTypes.map(\.rawValue).sorted().joined(separator: ","))",
            "appliedRunIDs=\(appliedRunIDs.map(\.rawValue).sorted().joined(separator: ","))",
            "brokerEnabled=\(rules.brokerEnabled)",
            "productionEndpointEnabled=\(rules.productionEndpointEnabled)",
            "omsBypassEnabled=\(rules.omsBypassEnabled)",
            "orderCommandPathEnabled=\(rules.orderCommandPathEnabled)"
        ].joined(separator: "|")
        return "risk-policy-fnv64-\(fnv1a64Hex(input))"
    }

    private static func fnv1a64Hex(_ input: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in input.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        return String(format: "%016llx", hash)
    }
}

/// ReleaseV080RiskPolicyProfileDiff 表示两个 operator-managed profile 的 deterministic diff。
public struct ReleaseV080RiskPolicyProfileDiff: Codable, Equatable, Sendable {
    public let previousProfileVersion: String
    public let nextProfileVersion: String
    public let previousPolicyHash: String
    public let nextPolicyHash: String
    public let changedFields: [String]
    public let diffLines: [String]
    public let brokerEnabled: Bool
    public let productionEndpointEnabled: Bool
    public let omsBypassEnabled: Bool
    public let orderCommandPathEnabled: Bool

    public var diffHeld: Bool {
        previousProfileVersion.isEmpty == false
            && nextProfileVersion.isEmpty == false
            && previousProfileVersion != nextProfileVersion
            && previousPolicyHash != nextPolicyHash
            && changedFields.isEmpty == false
            && diffLines.count == changedFields.count
            && brokerEnabled == false
            && productionEndpointEnabled == false
            && omsBypassEnabled == false
            && orderCommandPathEnabled == false
    }

    public init(previousProfile: ReleaseV080RiskPolicyProfile, nextProfile: ReleaseV080RiskPolicyProfile) throws {
        var fields: [String] = []
        var lines: [String] = []

        Self.appendDiff(
            field: "profileVersion",
            previous: previousProfile.profileVersion,
            next: nextProfile.profileVersion,
            fields: &fields,
            lines: &lines
        )
        Self.appendDiff(
            field: "maxNotionalMinorUnits",
            previous: String(previousProfile.rules.maxNotionalMinorUnits),
            next: String(nextProfile.rules.maxNotionalMinorUnits),
            fields: &fields,
            lines: &lines
        )
        Self.appendDiff(
            field: "maxExposureMinorUnits",
            previous: String(previousProfile.rules.maxExposureMinorUnits),
            next: String(nextProfile.rules.maxExposureMinorUnits),
            fields: &fields,
            lines: &lines
        )
        Self.appendDiff(
            field: "appliedRunIDs",
            previous: previousProfile.appliedRunIDs.map(\.rawValue).sorted().joined(separator: ","),
            next: nextProfile.appliedRunIDs.map(\.rawValue).sorted().joined(separator: ","),
            fields: &fields,
            lines: &lines
        )

        self.previousProfileVersion = previousProfile.profileVersion
        self.nextProfileVersion = nextProfile.profileVersion
        self.previousPolicyHash = previousProfile.policyHash
        self.nextPolicyHash = nextProfile.policyHash
        self.changedFields = fields
        self.diffLines = lines
        self.brokerEnabled = nextProfile.rules.brokerEnabled
        self.productionEndpointEnabled = nextProfile.rules.productionEndpointEnabled
        self.omsBypassEnabled = nextProfile.rules.omsBypassEnabled
        self.orderCommandPathEnabled = nextProfile.rules.orderCommandPathEnabled

        guard diffHeld else {
            throw ReleaseV080RiskPolicyProfileManagementError.diffMismatch
        }
    }

    private static func appendDiff(
        field: String,
        previous: String,
        next: String,
        fields: inout [String],
        lines: inout [String]
    ) {
        guard previous != next else {
            return
        }
        fields.append(field)
        lines.append("\(field): \(previous) -> \(next)")
    }
}

/// ReleaseV080RiskPolicyProfileRunApplicationEvidence 记录 run 对 policy profile 的引用。
public struct ReleaseV080RiskPolicyProfileRunApplicationEvidence: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let appliedProfileVersion: String
    public let appliedPolicyHash: String
    public let appliedPolicyPath: String
    public let manifestPolicyReferencePath: String
    public let localRunManifestUpdated: Bool
    public let brokerEnabled: Bool
    public let productionEndpointEnabled: Bool
    public let omsBypassEnabled: Bool
    public let orderCommandPathEnabled: Bool

    public var evidenceHeld: Bool {
        runID.rawValue.isEmpty == false
            && appliedProfileVersion.hasPrefix("v0.8.0-risk-policy-profile.")
            && appliedPolicyHash.hasPrefix("risk-policy-fnv64-")
            && appliedPolicyPath == ReleaseV080RiskPolicyProfile.canonicalProfilePath
            && manifestPolicyReferencePath == ".local/mtpro/runs/\(runID.rawValue)/manifest.json"
            && localRunManifestUpdated
            && brokerEnabled == false
            && productionEndpointEnabled == false
            && omsBypassEnabled == false
            && orderCommandPathEnabled == false
    }

    public init(runID: Identifier, profile: ReleaseV080RiskPolicyProfile) throws {
        self.runID = runID
        self.appliedProfileVersion = profile.profileVersion
        self.appliedPolicyHash = profile.policyHash
        self.appliedPolicyPath = profile.profilePath
        self.manifestPolicyReferencePath = ".local/mtpro/runs/\(runID.rawValue)/manifest.json"
        self.localRunManifestUpdated = true
        self.brokerEnabled = profile.rules.brokerEnabled
        self.productionEndpointEnabled = profile.rules.productionEndpointEnabled
        self.omsBypassEnabled = profile.rules.omsBypassEnabled
        self.orderCommandPathEnabled = profile.rules.orderCommandPathEnabled

        guard evidenceHeld else {
            throw ReleaseV080RiskPolicyProfileManagementError.applicationEvidenceDrift("runApplication")
        }
    }
}

/// ReleaseV080RiskPolicyProfileManagementEvidence 汇总 GH-816 profile 管理证据。
public struct ReleaseV080RiskPolicyProfileManagementEvidence: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let previousProfile: ReleaseV080RiskPolicyProfile
    public let nextProfile: ReleaseV080RiskPolicyProfile
    public let deterministicDiff: ReleaseV080RiskPolicyProfileDiff
    public let runApplicationEvidence: ReleaseV080RiskPolicyProfileRunApplicationEvidence
    public let cliSurfaceCommands: [String]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-816"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-810", "GH-811"]
            && releaseVersion == "v0.8.0"
            && previousProfile.profileHeld
            && nextProfile.profileHeld
            && deterministicDiff.diffHeld
            && runApplicationEvidence.evidenceHeld
            && runApplicationEvidence.appliedPolicyHash == nextProfile.policyHash
            && cliSurfaceCommands == ["risk-policy show", "risk-policy validate", "risk-policy diff"]
            && validationAnchors == ReleaseV080RiskPolicyProfileManagementContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV080RiskPolicyProfileManagementContract.requiredValidationCommands
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        previousProfile.forbiddenBoundaryHeld
            && nextProfile.forbiddenBoundaryHeld
            && deterministicDiff.brokerEnabled == false
            && deterministicDiff.productionEndpointEnabled == false
            && deterministicDiff.omsBypassEnabled == false
            && deterministicDiff.orderCommandPathEnabled == false
            && runApplicationEvidence.brokerEnabled == false
            && runApplicationEvidence.productionEndpointEnabled == false
            && runApplicationEvidence.omsBypassEnabled == false
            && runApplicationEvidence.orderCommandPathEnabled == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-816"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-810"), Identifier.constant("GH-811")],
        releaseVersion: String = "v0.8.0",
        previousProfile: ReleaseV080RiskPolicyProfile,
        nextProfile: ReleaseV080RiskPolicyProfile,
        deterministicDiff: ReleaseV080RiskPolicyProfileDiff,
        runApplicationEvidence: ReleaseV080RiskPolicyProfileRunApplicationEvidence,
        cliSurfaceCommands: [String] = ["risk-policy show", "risk-policy validate", "risk-policy diff"],
        validationAnchors: [String] = ReleaseV080RiskPolicyProfileManagementContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV080RiskPolicyProfileManagementContract.requiredValidationCommands
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.previousProfile = previousProfile
        self.nextProfile = nextProfile
        self.deterministicDiff = deterministicDiff
        self.runApplicationEvidence = runApplicationEvidence
        self.cliSurfaceCommands = cliSurfaceCommands
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands

        guard evidenceHeld else {
            throw ReleaseV080RiskPolicyProfileManagementError.contractDrift("riskPolicyProfileManagementEvidence")
        }
    }
}

/// ReleaseV080RiskPolicyProfileManagementBuilder 生成 GH-816 deterministic profile evidence。
public enum ReleaseV080RiskPolicyProfileManagementBuilder {
    public static func deterministicEvidence() throws -> ReleaseV080RiskPolicyProfileManagementEvidence {
        let previous = try profile(
            versionSuffix: "1",
            maxNotionalMinorUnits: 50_000_000,
            maxExposureMinorUnits: 125_000_000,
            appliedRunIDs: [Identifier.constant("gh-810-local-alpha")]
        )
        let next = try profile(
            versionSuffix: "2",
            maxNotionalMinorUnits: 40_000_000,
            maxExposureMinorUnits: 100_000_000,
            appliedRunIDs: [
                Identifier.constant("gh-810-local-alpha"),
                Identifier.constant("gh-811-run-alpha")
            ]
        )
        let diff = try ReleaseV080RiskPolicyProfileDiff(previousProfile: previous, nextProfile: next)
        let application = try ReleaseV080RiskPolicyProfileRunApplicationEvidence(
            runID: Identifier.constant("gh-811-run-alpha"),
            profile: next
        )
        return try ReleaseV080RiskPolicyProfileManagementEvidence(
            previousProfile: previous,
            nextProfile: next,
            deterministicDiff: diff,
            runApplicationEvidence: application
        )
    }

    private static func profile(
        versionSuffix: String,
        maxNotionalMinorUnits: Int64,
        maxExposureMinorUnits: Int64,
        appliedRunIDs: [Identifier]
    ) throws -> ReleaseV080RiskPolicyProfile {
        let metadata = try ReleaseV080RiskPolicyProfileOperatorChangeMetadata(
            operatorID: Identifier.constant("gh-816-local-operator"),
            changedAtISO8601: "2026-06-15T00:00:00Z",
            changeReason: "operator-managed-local-risk-policy-profile"
        )
        let rules = try ReleaseV080RiskPolicyProfileRules(
            maxNotionalMinorUnits: maxNotionalMinorUnits,
            maxExposureMinorUnits: maxExposureMinorUnits,
            killSwitchRequired: true,
            noTradeRequired: true,
            allowedSymbols: [Symbol.constant("BTCUSDT"), Symbol.constant("ETHUSDT")],
            allowedProductTypes: [.spot, .usdsPerpetual]
        )
        return try ReleaseV080RiskPolicyProfile(
            profileID: Identifier.constant("gh-816-v080-risk-policy-profile"),
            profileVersion: "v0.8.0-risk-policy-profile.\(versionSuffix)",
            operatorChangeMetadata: metadata,
            rules: rules,
            appliedRunIDs: appliedRunIDs
        )
    }
}

/// ReleaseV080RiskPolicyProfileManagementContract 固定 GH-816 issue-level 验收合同。
public struct ReleaseV080RiskPolicyProfileManagementContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let brokerConnectionEnabled: Bool
    public let omsBypassEnabled: Bool
    public let orderCommandPathEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-816"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-810", "GH-811"]
            && releaseVersion == "v0.8.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && brokerConnectionEnabled == false
            && omsBypassEnabled == false
            && orderCommandPathEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-816"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-810"), Identifier.constant("GH-811")],
        releaseVersion: String = "v0.8.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        brokerConnectionEnabled: Bool = false,
        omsBypassEnabled: Bool = false,
        orderCommandPathEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.brokerConnectionEnabled = brokerConnectionEnabled
        self.omsBypassEnabled = omsBypassEnabled
        self.orderCommandPathEnabled = orderCommandPathEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV080RiskPolicyProfileManagementError.contractDrift("riskPolicyProfileManagementContract")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV080RiskPolicyProfileManagementContract {
        try ReleaseV080RiskPolicyProfileManagementContract()
    }

    public static let requiredValidationAnchors = [
        "GH-816-VERIFY-V080-RISK-POLICY-PROFILE-MANAGEMENT",
        "TVM-RELEASE-V080-RISK-POLICY-PROFILE-MANAGEMENT",
        "V080-010-RISK-POLICY-PROFILE-MANAGEMENT",
        "V080-010-RISK-POLICY-JSON-VERSION-HASH",
        "V080-010-DETERMINISTIC-POLICY-DIFF",
        "V080-010-OPERATOR-CHANGE-METADATA",
        "V080-010-RUN-APPLICATION-POLICY-REFERENCE",
        "V080-010-CLI-SHOW-VALIDATE-DIFF",
        "V080-010-NO-BROKER-ENDPOINT-OMS-ORDER-PATH"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH816RiskPolicyProfilesVersionHashDiffAndRunApplicationEvidence",
        "bash checks/verify-v0.8.0-risk-policy-profiles.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
