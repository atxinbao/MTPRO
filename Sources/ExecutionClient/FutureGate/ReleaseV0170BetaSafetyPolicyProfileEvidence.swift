import DomainModel
import Foundation

// GH-1147 static contract boundary:
// betaSafetyPolicyProfileEvidence=ReleaseV0170BetaSafetyPolicyProfileEvidence
// activeSafetyPolicyProfileRecorded=true
// venueLimitEvidenceRecorded=true
// productLimitEvidenceRecorded=true
// symbolLimitEvidenceRecorded=true
// notionalLimitEvidenceRecorded=true
// orderCountLimitEvidenceRecorded=true
// productionGuardStateRecorded=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false

/// ReleaseV0170BetaSafetyPolicyProfile 固定 GH-1147 的 operator beta 安全策略档案。
///
/// 该 profile 只是本地 evidence contract：它把 v0.16 beta safety guard 的 symbol / order-count
/// 限制扩展成可审计的 venue、product、notional 和 production-disabled 状态。它不读取 credential
/// value，不连接 endpoint，也不发送 submit / cancel / replace。
public struct ReleaseV0170BetaSafetyPolicyProfile: Codable, Equatable, Sendable {
    public let profileID: Identifier
    public let profileVersion: String
    public let venue: String
    public let productTypes: [String]
    public let symbols: [String]
    public let quoteCurrency: String
    public let maxNotionalUSDT: Double
    public let maxOrdersPerRun: Int
    public let inheritedGuardSource: String

    public var profileHeld: Bool {
        profileID == Self.requiredProfileID
            && profileVersion == Self.requiredProfileVersion
            && venue == Self.requiredVenue
            && productTypes == Self.requiredProductTypes
            && symbols == Self.requiredSymbols
            && quoteCurrency == "USDT"
            && maxNotionalUSDT == Self.requiredMaxNotionalUSDT
            && maxOrdersPerRun == ReleaseV0160BetaSafetyGuardLimits.standard.maxOrdersPerRun
            && inheritedGuardSource == "ReleaseV0160BetaSafetyGuard"
    }

    public init(
        profileID: Identifier = Self.requiredProfileID,
        profileVersion: String = Self.requiredProfileVersion,
        venue: String = Self.requiredVenue,
        productTypes: [String] = Self.requiredProductTypes,
        symbols: [String] = Self.requiredSymbols,
        quoteCurrency: String = "USDT",
        maxNotionalUSDT: Double = Self.requiredMaxNotionalUSDT,
        maxOrdersPerRun: Int = ReleaseV0160BetaSafetyGuardLimits.standard.maxOrdersPerRun,
        inheritedGuardSource: String = "ReleaseV0160BetaSafetyGuard"
    ) {
        self.profileID = profileID
        self.profileVersion = profileVersion
        self.venue = venue
        self.productTypes = productTypes
        self.symbols = symbols
        self.quoteCurrency = quoteCurrency
        self.maxNotionalUSDT = maxNotionalUSDT
        self.maxOrdersPerRun = maxOrdersPerRun
        self.inheritedGuardSource = inheritedGuardSource
    }

    public static let requiredProfileID = Identifier.constant("gh-1147-v0170-beta-safety-policy-profile")
    public static let requiredProfileVersion = "v0.17.0-operator-beta-safety-policy"
    public static let requiredVenue = "Binance"
    public static let requiredProductTypes = ["spot"]
    public static let requiredSymbols = ReleaseV0160BetaSafetyGuardLimits.standard.allowedSymbols
    public static let requiredMaxNotionalUSDT = 25.0
}

/// ReleaseV0170BetaSafetyPolicyProductionGuardState 固定 production-disabled proof。
///
/// 该状态必须在每份 GH-1147 evidence 中显式出现，避免只靠文字说明默认关闭 production trading。
public struct ReleaseV0170BetaSafetyPolicyProductionGuardState: Codable, Equatable, Sendable {
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretReadEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmitCancelReplaceEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var guardHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretReadEnabled == false
            && productionEndpointConnectionEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmitCancelReplaceEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        productionTradingEnabledByDefault: Bool = false,
        productionSecretReadEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmitCancelReplaceEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) {
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretReadEnabled = productionSecretReadEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmitCancelReplaceEnabled = productionOrderSubmitCancelReplaceEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }
}

/// ReleaseV0170BetaSafetyPolicyProfileRequest 是 GH-1147 profile evidence 的输入。
///
/// Request 只接收本地 run / policy metadata 和 GH-1110 safety evidence。它不得携带 API key、
/// secret、raw order identity、raw broker payload 或 production endpoint。
public struct ReleaseV0170BetaSafetyPolicyProfileRequest: Equatable, Sendable {
    public let runID: Identifier
    public let venue: String
    public let productType: String
    public let symbol: String
    public let notionalUSDT: Double
    public let orderCount: Int
    public let safetyGuardEvidence: ReleaseV0160BetaSafetyGuardEvidence
    public let productionGuardState: ReleaseV0170BetaSafetyPolicyProductionGuardState

    public init(
        runID: Identifier,
        venue: String,
        productType: String,
        symbol: String,
        notionalUSDT: Double,
        orderCount: Int,
        safetyGuardEvidence: ReleaseV0160BetaSafetyGuardEvidence,
        productionGuardState: ReleaseV0170BetaSafetyPolicyProductionGuardState =
            ReleaseV0170BetaSafetyPolicyProductionGuardState()
    ) {
        self.runID = runID
        self.venue = venue
        self.productType = productType
        self.symbol = symbol
        self.notionalUSDT = notionalUSDT
        self.orderCount = orderCount
        self.safetyGuardEvidence = safetyGuardEvidence
        self.productionGuardState = productionGuardState
    }
}

/// ReleaseV0170BetaSafetyPolicyProfileEvidence 是 GH-1147 的 active safety policy profile evidence。
///
/// Evidence 必须把 active profile、venue/product/symbol/notional/order-count 结果和 production-disabled
/// guard state 放在同一个可验证对象里。后续 manual validation / stage audit 可以引用该对象，而不是重新解释
/// beta safety policy。
public struct ReleaseV0170BetaSafetyPolicyProfileEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let blockedByIssueID: Identifier
    public let releaseVersion: String
    public let profile: ReleaseV0170BetaSafetyPolicyProfile
    public let runID: Identifier
    public let venue: String
    public let productType: String
    public let symbol: String
    public let notionalUSDT: Double
    public let orderCount: Int
    public let safetyGuardEvidenceID: Identifier
    public let activeSafetyPolicyProfileRecorded: Bool
    public let venueLimitEvidenceRecorded: Bool
    public let productLimitEvidenceRecorded: Bool
    public let symbolLimitEvidenceRecorded: Bool
    public let notionalLimitEvidenceRecorded: Bool
    public let orderCountLimitEvidenceRecorded: Bool
    public let productionGuardStateRecorded: Bool
    public let venueLimitHeld: Bool
    public let productLimitHeld: Bool
    public let symbolLimitHeld: Bool
    public let notionalLimitHeld: Bool
    public let orderCountLimitHeld: Bool
    public let inheritedSafetyGuardHeld: Bool
    public let productionGuardState: ReleaseV0170BetaSafetyPolicyProductionGuardState
    public let validationAnchors: [String]

    public var evidenceHeld: Bool {
        evidenceID == Self.deterministicID(
            runID: runID,
            symbol: symbol,
            notionalUSDT: notionalUSDT,
            orderCount: orderCount
        )
            && issueID.rawValue == "GH-1147"
            && blockedByIssueID.rawValue == "GH-1146"
            && releaseVersion == "v0.17.0"
            && profile.profileHeld
            && runID.rawValue.isEmpty == false
            && activeSafetyPolicyProfileRecorded
            && venueLimitEvidenceRecorded
            && productLimitEvidenceRecorded
            && symbolLimitEvidenceRecorded
            && notionalLimitEvidenceRecorded
            && orderCountLimitEvidenceRecorded
            && productionGuardStateRecorded
            && venueLimitHeld
            && productLimitHeld
            && symbolLimitHeld
            && notionalLimitHeld
            && orderCountLimitHeld
            && inheritedSafetyGuardHeld
            && productionGuardState.guardHeld
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var failureReasons: [String] {
        var reasons: [String] = []
        if venueLimitHeld == false { reasons.append("venue-limit") }
        if productLimitHeld == false { reasons.append("product-limit") }
        if symbolLimitHeld == false { reasons.append("symbol-limit") }
        if notionalLimitHeld == false { reasons.append("notional-limit") }
        if orderCountLimitHeld == false { reasons.append("order-count-limit") }
        if inheritedSafetyGuardHeld == false { reasons.append("inherited-safety-guard") }
        if productionGuardState.guardHeld == false { reasons.append("production-guard-state") }
        return reasons
    }

    public var redactedOutputLines: [String] {
        [
            "betaSafetyPolicyProfileEvidence=ReleaseV0170BetaSafetyPolicyProfileEvidence",
            "issue=GH-1147",
            "blockedBy=GH-1146",
            "releaseVersion=\(releaseVersion)",
            "profileID=\(profile.profileID.rawValue)",
            "profileVersion=\(profile.profileVersion)",
            "runID=\(runID.rawValue)",
            "venue=\(venue)",
            "productType=\(productType)",
            "symbol=\(symbol)",
            "notionalUSDT=\(notionalUSDT)",
            "maxNotionalUSDT=\(profile.maxNotionalUSDT)",
            "orderCount=\(orderCount)",
            "maxOrdersPerRun=\(profile.maxOrdersPerRun)",
            "allowedSymbols=\(profile.symbols.joined(separator: ","))",
            "safetyGuardEvidenceID=\(safetyGuardEvidenceID.rawValue)",
            "venueLimitHeld=\(venueLimitHeld)",
            "productLimitHeld=\(productLimitHeld)",
            "symbolLimitHeld=\(symbolLimitHeld)",
            "notionalLimitHeld=\(notionalLimitHeld)",
            "orderCountLimitHeld=\(orderCountLimitHeld)",
            "inheritedSafetyGuardHeld=\(inheritedSafetyGuardHeld)",
            "productionTradingEnabledByDefault=\(productionGuardState.productionTradingEnabledByDefault)",
            "productionSecretReadEnabled=\(productionGuardState.productionSecretReadEnabled)",
            "productionEndpointConnectionEnabled=\(productionGuardState.productionEndpointConnectionEnabled)",
            "productionBrokerConnectionEnabled=\(productionGuardState.productionBrokerConnectionEnabled)",
            "productionOrderSubmitCancelReplaceEnabled=\(productionGuardState.productionOrderSubmitCancelReplaceEnabled)",
            "productionCutoverAuthorized=\(productionGuardState.productionCutoverAuthorized)",
            "failureReasons=\(failureReasons.joined(separator: ","))",
            "boundaryHeld=\(evidenceHeld)"
        ]
    }

    public init(
        request: ReleaseV0170BetaSafetyPolicyProfileRequest,
        profile: ReleaseV0170BetaSafetyPolicyProfile = ReleaseV0170BetaSafetyPolicyProfile(),
        activeSafetyPolicyProfileRecorded: Bool = true,
        venueLimitEvidenceRecorded: Bool = true,
        productLimitEvidenceRecorded: Bool = true,
        symbolLimitEvidenceRecorded: Bool = true,
        notionalLimitEvidenceRecorded: Bool = true,
        orderCountLimitEvidenceRecorded: Bool = true,
        productionGuardStateRecorded: Bool = true,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        let normalizedVenue = request.venue.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedProductType = request.productType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedSymbol = request.symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        self.evidenceID = Self.deterministicID(
            runID: request.runID,
            symbol: normalizedSymbol,
            notionalUSDT: request.notionalUSDT,
            orderCount: request.orderCount
        )
        self.issueID = .constant("GH-1147")
        self.blockedByIssueID = .constant("GH-1146")
        self.releaseVersion = "v0.17.0"
        self.profile = profile
        self.runID = request.runID
        self.venue = normalizedVenue
        self.productType = normalizedProductType
        self.symbol = normalizedSymbol
        self.notionalUSDT = request.notionalUSDT
        self.orderCount = request.orderCount
        self.safetyGuardEvidenceID = request.safetyGuardEvidence.evidenceID
        self.activeSafetyPolicyProfileRecorded = activeSafetyPolicyProfileRecorded
        self.venueLimitEvidenceRecorded = venueLimitEvidenceRecorded
        self.productLimitEvidenceRecorded = productLimitEvidenceRecorded
        self.symbolLimitEvidenceRecorded = symbolLimitEvidenceRecorded
        self.notionalLimitEvidenceRecorded = notionalLimitEvidenceRecorded
        self.orderCountLimitEvidenceRecorded = orderCountLimitEvidenceRecorded
        self.productionGuardStateRecorded = productionGuardStateRecorded
        self.venueLimitHeld = normalizedVenue == profile.venue
        self.productLimitHeld = profile.productTypes.contains(normalizedProductType)
        self.symbolLimitHeld = profile.symbols.contains(normalizedSymbol)
            && request.safetyGuardEvidence.symbol == normalizedSymbol
        self.notionalLimitHeld = request.notionalUSDT > 0
            && request.notionalUSDT.isFinite
            && request.notionalUSDT <= profile.maxNotionalUSDT
        self.orderCountLimitHeld = request.orderCount > 0
            && request.orderCount <= profile.maxOrdersPerRun
            && request.safetyGuardEvidence.attemptedOrderCount == request.orderCount
        self.inheritedSafetyGuardHeld = request.safetyGuardEvidence.boundaryHeld
        self.productionGuardState = request.productionGuardState
        self.validationAnchors = validationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-1147-VERIFY-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE",
        "TVM-RELEASE-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE",
        "V0170-009-ACTIVE-SAFETY-POLICY-PROFILE",
        "V0170-009-VENUE-PRODUCT-SYMBOL-LIMITS",
        "V0170-009-NOTIONAL-LIMIT-EVIDENCE",
        "V0170-009-ORDER-COUNT-LIMIT-EVIDENCE",
        "V0170-009-PRODUCTION-GUARD-STATE",
        "V0170-009-REDACTED-POLICY-EVIDENCE",
        "V0170-009-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1147ReleaseV0170BetaSafetyPolicyProfileEvidence",
        "bash checks/verify-v0.17.0-beta-safety-policy-profile-evidence.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func evaluate(
        request: ReleaseV0170BetaSafetyPolicyProfileRequest,
        profile: ReleaseV0170BetaSafetyPolicyProfile = ReleaseV0170BetaSafetyPolicyProfile()
    ) -> ReleaseV0170BetaSafetyPolicyProfileEvidence {
        ReleaseV0170BetaSafetyPolicyProfileEvidence(request: request, profile: profile)
    }

    @discardableResult
    public static func validate(
        request: ReleaseV0170BetaSafetyPolicyProfileRequest,
        profile: ReleaseV0170BetaSafetyPolicyProfile = ReleaseV0170BetaSafetyPolicyProfile()
    ) throws -> ReleaseV0170BetaSafetyPolicyProfileEvidence {
        let evidence = evaluate(request: request, profile: profile)
        guard evidence.evidenceHeld else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0170BetaSafetyPolicyProfileEvidence.\(evidence.failureReasons.joined(separator: "+"))"
            )
        }
        return evidence
    }

    public static func deterministicID(
        runID: Identifier,
        symbol: String,
        notionalUSDT: Double,
        orderCount: Int
    ) -> Identifier {
        .constant(
            [
                "gh-1147-v0170-beta-safety-policy-profile-evidence",
                runID.rawValue,
                symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                String(notionalUSDT),
                String(orderCount)
            ].joined(separator: ":")
        )
    }
}
