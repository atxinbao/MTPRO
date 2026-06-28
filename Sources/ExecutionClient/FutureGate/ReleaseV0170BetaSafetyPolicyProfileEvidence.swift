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

// GH-1184 static contract boundary:
// betaSafetyProfileDriftDetector=ReleaseV0180BetaSafetyProfileDriftDetector
// venueProductEnvironmentScopeRecorded=true
// binanceSpotToOKXSwapReuseRejected=true
// binanceSpotToUSDMFuturesReuseRejected=true
// wrongEnvironmentReuseRejected=true
// crossProductEvidenceReuseFailsClosed=true
// driftedEvidenceProducesFailedValidation=true
// noNewLiveAdapterImplementation=true
// productionTradingEnabledByDefault=false
// productionSecretReadEnabled=false
// productionEndpointConnectionEnabled=false
// productionBrokerConnectionEnabled=false
// productionOrderSubmitCancelReplaceEnabled=false
// productionCutoverAuthorized=false

/// ReleaseV0180BetaSafetyProfileScope 固定 GH-1184 的 beta safety profile 使用范围。
///
/// Scope 只描述本地 evidence 所属的 venue / product / environment / account / runID。
/// 它不会创建 venue runtime，也不会连接 endpoint、broker 或 production secret。
public struct ReleaseV0180BetaSafetyProfileScope: Codable, Equatable, Sendable {
    public let venue: String
    public let product: String
    public let environment: String
    public let accountProfile: String
    public let runID: Identifier

    public var namespaceKey: String {
        [
            "venue=\(venue)",
            "product=\(product)",
            "environment=\(environment)",
            "accountProfile=\(accountProfile)",
            "runID=\(runID.rawValue)"
        ].joined(separator: "|")
    }

    public var fieldsPresent: Bool {
        venue.isEmpty == false
            && product.isEmpty == false
            && environment.isEmpty == false
            && accountProfile.isEmpty == false
            && runID.rawValue.isEmpty == false
    }

    public var venueProductPairSupported: Bool {
        switch (venue, product) {
        case ("binance", "spot"), ("binance", "usdmFutures"), ("okx", "spot"), ("okx", "swap"):
            true
        default:
            false
        }
    }

    public var scopeHeld: Bool {
        fieldsPresent && venueProductPairSupported
    }

    public init(
        venue: String,
        product: String,
        environment: String,
        accountProfile: String,
        runID: Identifier
    ) {
        self.venue = Self.normalizeVenue(venue)
        self.product = Self.normalizeProduct(product)
        self.environment = environment.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.accountProfile = accountProfile.trimmingCharacters(in: .whitespacesAndNewlines)
        self.runID = runID
    }

    private static func normalizeVenue(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func normalizeProduct(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = trimmed
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .lowercased()

        switch key {
        case "spot":
            return "spot"
        case "swap":
            return "swap"
        case "usdmfutures", "usdm-futures", "usdm-perpetual":
            return "usdmFutures"
        default:
            return trimmed
        }
    }
}

/// ReleaseV0180BetaSafetyProfileDriftReason 描述 GH-1184 可解释的 fail-closed 原因。
public enum ReleaseV0180BetaSafetyProfileDriftReason: String, Codable, CaseIterable, Equatable, Sendable {
    case venueDrift = "venue-drift"
    case productDrift = "product-drift"
    case environmentDrift = "environment-drift"
    case accountProfileDrift = "account-profile-drift"
    case runIDDrift = "run-id-drift"
    case unsupportedExpectedVenueProduct = "unsupported-expected-venue-product"
    case unsupportedObservedVenueProduct = "unsupported-observed-venue-product"
    case sourceEvidenceBoundaryFailed = "source-evidence-boundary-failed"
    case productionGuardStateFailed = "production-guard-state-failed"
}

/// ReleaseV0180BetaSafetyProfileDriftEvidence 是 GH-1184 的 venue/product-aware drift detector 输出。
///
/// 它把 expected scope、observed scope 和 v0.17 beta safety profile evidence 绑定在一起。
/// 任何 cross-product 或 cross-environment 复用都必须得到 failed validation，而不是成功状态里的失败字串。
public struct ReleaseV0180BetaSafetyProfileDriftEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let releaseVersion: String
    public let expectedScope: ReleaseV0180BetaSafetyProfileScope
    public let observedScope: ReleaseV0180BetaSafetyProfileScope
    public let sourceEvidenceID: Identifier
    public let sourceEvidenceIssueID: Identifier
    public let sourceEvidenceVenue: String
    public let sourceEvidenceProduct: String
    public let sourceEvidenceBoundaryHeld: Bool
    public let venueProductEnvironmentScopeRecorded: Bool
    public let venueDriftDetected: Bool
    public let productDriftDetected: Bool
    public let environmentDriftDetected: Bool
    public let accountProfileDriftDetected: Bool
    public let runIDDriftDetected: Bool
    public let unsupportedExpectedVenueProductDetected: Bool
    public let unsupportedObservedVenueProductDetected: Bool
    public let productionGuardStateHeld: Bool
    public let crossProductEvidenceReuseRejected: Bool
    public let validationStatus: String
    public let validationAnchors: [String]

    public var driftDetected: Bool {
        venueDriftDetected
            || productDriftDetected
            || environmentDriftDetected
            || accountProfileDriftDetected
            || runIDDriftDetected
            || unsupportedExpectedVenueProductDetected
            || unsupportedObservedVenueProductDetected
            || sourceEvidenceBoundaryHeld == false
            || productionGuardStateHeld == false
    }

    public var detectionHeld: Bool {
        evidenceID == Self.deterministicID(expectedScope: expectedScope, observedScope: observedScope)
            && issueID.rawValue == "GH-1184"
            && blockedByIssueIDs == [.constant("GH-1177"), .constant("GH-1181"), .constant("GH-1183")]
            && releaseVersion == "v0.18.0"
            && expectedScope.fieldsPresent
            && observedScope.fieldsPresent
            && sourceEvidenceIssueID.rawValue == "GH-1147"
            && venueProductEnvironmentScopeRecorded
            && crossProductEvidenceReuseRejected == driftDetected
            && validationStatus == (driftDetected ? "failed" : "passed")
            && validationAnchors == Self.requiredValidationAnchors
    }

    public var failureReasons: [String] {
        var reasons: [String] = []
        if venueDriftDetected { reasons.append(ReleaseV0180BetaSafetyProfileDriftReason.venueDrift.rawValue) }
        if productDriftDetected { reasons.append(ReleaseV0180BetaSafetyProfileDriftReason.productDrift.rawValue) }
        if environmentDriftDetected { reasons.append(ReleaseV0180BetaSafetyProfileDriftReason.environmentDrift.rawValue) }
        if accountProfileDriftDetected { reasons.append(ReleaseV0180BetaSafetyProfileDriftReason.accountProfileDrift.rawValue) }
        if runIDDriftDetected { reasons.append(ReleaseV0180BetaSafetyProfileDriftReason.runIDDrift.rawValue) }
        if unsupportedExpectedVenueProductDetected {
            reasons.append(ReleaseV0180BetaSafetyProfileDriftReason.unsupportedExpectedVenueProduct.rawValue)
        }
        if unsupportedObservedVenueProductDetected {
            reasons.append(ReleaseV0180BetaSafetyProfileDriftReason.unsupportedObservedVenueProduct.rawValue)
        }
        if sourceEvidenceBoundaryHeld == false {
            reasons.append(ReleaseV0180BetaSafetyProfileDriftReason.sourceEvidenceBoundaryFailed.rawValue)
        }
        if productionGuardStateHeld == false {
            reasons.append(ReleaseV0180BetaSafetyProfileDriftReason.productionGuardStateFailed.rawValue)
        }
        return reasons
    }

    public var redactedOutputLines: [String] {
        [
            "betaSafetyProfileDriftDetector=ReleaseV0180BetaSafetyProfileDriftDetector",
            "issue=GH-1184",
            "blockedBy=GH-1177,GH-1181,GH-1183",
            "releaseVersion=\(releaseVersion)",
            "expectedNamespace=\(expectedScope.namespaceKey)",
            "observedNamespace=\(observedScope.namespaceKey)",
            "sourceEvidenceID=\(sourceEvidenceID.rawValue)",
            "sourceEvidenceVenue=\(sourceEvidenceVenue)",
            "sourceEvidenceProduct=\(sourceEvidenceProduct)",
            "venueProductEnvironmentScopeRecorded=\(venueProductEnvironmentScopeRecorded)",
            "venueDriftDetected=\(venueDriftDetected)",
            "productDriftDetected=\(productDriftDetected)",
            "environmentDriftDetected=\(environmentDriftDetected)",
            "accountProfileDriftDetected=\(accountProfileDriftDetected)",
            "runIDDriftDetected=\(runIDDriftDetected)",
            "crossProductEvidenceReuseRejected=\(crossProductEvidenceReuseRejected)",
            "validationStatus=\(validationStatus)",
            "failureReasons=\(failureReasons.joined(separator: ","))",
            "productionCutoverAuthorized=false"
        ]
    }

    public init(
        expectedScope: ReleaseV0180BetaSafetyProfileScope,
        observedScope: ReleaseV0180BetaSafetyProfileScope,
        sourceEvidence: ReleaseV0170BetaSafetyPolicyProfileEvidence,
        venueProductEnvironmentScopeRecorded: Bool = true,
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        let sourceScope = ReleaseV0180BetaSafetyProfileScope(
            venue: sourceEvidence.venue,
            product: sourceEvidence.productType,
            environment: observedScope.environment,
            accountProfile: observedScope.accountProfile,
            runID: sourceEvidence.runID
        )
        let venueDriftDetected = expectedScope.venue != observedScope.venue
            || expectedScope.venue != sourceScope.venue
        let productDriftDetected = expectedScope.product != observedScope.product
            || expectedScope.product != sourceScope.product
        let environmentDriftDetected = expectedScope.environment != observedScope.environment
        let accountProfileDriftDetected = expectedScope.accountProfile != observedScope.accountProfile
        let runIDDriftDetected = expectedScope.runID != observedScope.runID
            || expectedScope.runID != sourceEvidence.runID
        let unsupportedExpectedVenueProductDetected = expectedScope.venueProductPairSupported == false
        let unsupportedObservedVenueProductDetected = observedScope.venueProductPairSupported == false
        let sourceEvidenceBoundaryHeld = sourceEvidence.evidenceHeld
        let productionGuardStateHeld = sourceEvidence.productionGuardState.guardHeld
        let failed = venueDriftDetected
            || productDriftDetected
            || environmentDriftDetected
            || accountProfileDriftDetected
            || runIDDriftDetected
            || unsupportedExpectedVenueProductDetected
            || unsupportedObservedVenueProductDetected
            || sourceEvidenceBoundaryHeld == false
            || productionGuardStateHeld == false

        self.evidenceID = Self.deterministicID(expectedScope: expectedScope, observedScope: observedScope)
        self.issueID = .constant("GH-1184")
        self.blockedByIssueIDs = [.constant("GH-1177"), .constant("GH-1181"), .constant("GH-1183")]
        self.releaseVersion = "v0.18.0"
        self.expectedScope = expectedScope
        self.observedScope = observedScope
        self.sourceEvidenceID = sourceEvidence.evidenceID
        self.sourceEvidenceIssueID = sourceEvidence.issueID
        self.sourceEvidenceVenue = sourceScope.venue
        self.sourceEvidenceProduct = sourceScope.product
        self.sourceEvidenceBoundaryHeld = sourceEvidenceBoundaryHeld
        self.venueProductEnvironmentScopeRecorded = venueProductEnvironmentScopeRecorded
        self.venueDriftDetected = venueDriftDetected
        self.productDriftDetected = productDriftDetected
        self.environmentDriftDetected = environmentDriftDetected
        self.accountProfileDriftDetected = accountProfileDriftDetected
        self.runIDDriftDetected = runIDDriftDetected
        self.unsupportedExpectedVenueProductDetected = unsupportedExpectedVenueProductDetected
        self.unsupportedObservedVenueProductDetected = unsupportedObservedVenueProductDetected
        self.productionGuardStateHeld = productionGuardStateHeld
        self.crossProductEvidenceReuseRejected = failed
        self.validationStatus = failed ? "failed" : "passed"
        self.validationAnchors = validationAnchors
    }

    public static let requiredValidationAnchors = [
        "GH-1184-VERIFY-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR",
        "TVM-RELEASE-V0180-BETA-SAFETY-PROFILE-DRIFT-DETECTOR",
        "V0180-009-DEPENDENCIES-GH1177-GH1181-GH1183-DONE",
        "V0180-009-VENUE-PRODUCT-ENVIRONMENT-SCOPE",
        "V0180-009-BINANCE-SPOT-TO-OKX-SWAP-REUSE-REJECTED",
        "V0180-009-BINANCE-SPOT-TO-USDM-FUTURES-REUSE-REJECTED",
        "V0180-009-WRONG-ENVIRONMENT-REUSE-REJECTED",
        "V0180-009-CROSS-PRODUCT-EVIDENCE-REUSE-FAILS-CLOSED",
        "V0180-009-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1184BetaSafetyProfileDriftDetectorRejectsCrossVenueProductReuse",
        "bash checks/verify-v0.18.0-beta-safety-profile-drift-detector.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]

    public static func deterministicID(
        expectedScope: ReleaseV0180BetaSafetyProfileScope,
        observedScope: ReleaseV0180BetaSafetyProfileScope
    ) -> Identifier {
        .constant(
            [
                "gh-1184-v0180-beta-safety-profile-drift-detector",
                expectedScope.namespaceKey,
                observedScope.namespaceKey
            ].joined(separator: ":")
        )
    }
}

/// ReleaseV0180BetaSafetyProfileDriftDetector 是 GH-1184 的 fail-closed 校验入口。
public enum ReleaseV0180BetaSafetyProfileDriftDetector {
    public static func evaluate(
        sourceEvidence: ReleaseV0170BetaSafetyPolicyProfileEvidence,
        expectedScope: ReleaseV0180BetaSafetyProfileScope,
        observedScope: ReleaseV0180BetaSafetyProfileScope
    ) -> ReleaseV0180BetaSafetyProfileDriftEvidence {
        ReleaseV0180BetaSafetyProfileDriftEvidence(
            expectedScope: expectedScope,
            observedScope: observedScope,
            sourceEvidence: sourceEvidence
        )
    }

    @discardableResult
    public static func validateNoDrift(
        sourceEvidence: ReleaseV0170BetaSafetyPolicyProfileEvidence,
        expectedScope: ReleaseV0180BetaSafetyProfileScope,
        observedScope: ReleaseV0180BetaSafetyProfileScope
    ) throws -> ReleaseV0180BetaSafetyProfileDriftEvidence {
        let evidence = evaluate(
            sourceEvidence: sourceEvidence,
            expectedScope: expectedScope,
            observedScope: observedScope
        )
        guard evidence.detectionHeld, evidence.driftDetected == false else {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0180BetaSafetyProfileDriftDetector.\(evidence.failureReasons.joined(separator: "+"))"
            )
        }
        return evidence
    }
}
