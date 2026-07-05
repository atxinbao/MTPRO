import DomainModel
import ExecutionClient
import Foundation

/// ReleaseV0220SpotLiveCanaryOneShotSubmitTransportOutcome 固定 GH-1313 的
/// Binance Spot 单笔 canary submit transport 结果。
///
/// `submitted` 只表示一笔经过 approval、account preflight、CommandGateway、RiskEngine、
/// kill switch、no-trade、ExecutionEngine 和 OMS gate 的 allowlisted Spot canary order
/// 已生成脱敏 transport request / exchange ack evidence。它不表示 production cutover、循环交易、
/// Futures / OKX 或 Dashboard 下单界面已开启。
public enum ReleaseV0220SpotLiveCanaryOneShotSubmitTransportOutcome:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case submitted = "submitted"
    case rejected = "rejected"
}

/// ReleaseV0220SpotLiveCanaryOneShotSubmitTransportRejectReason 是 GH-1313 的
/// fail-closed 分类。
public enum ReleaseV0220SpotLiveCanaryOneShotSubmitTransportRejectReason:
    String, Codable, CaseIterable, Equatable, Hashable, Sendable
{
    case upstreamSubmitPathRejected = "upstream submit path rejected"
    case signedAccountPreflightMissing = "signed account preflight missing"
    case commandGatewayRejected = "command gateway rejected"
    case riskRejected = "risk rejected"
    case killSwitchActive = "kill switch active"
    case noTradeActive = "no-trade active"
    case executionEngineRejected = "execution engine rejected"
    case omsRejected = "oms rejected"
    case allowlistScopeViolated = "allowlist scope violated"
    case duplicateOrderAttempt = "duplicate order attempt"
    case redactedRequestEvidenceMissing = "redacted request evidence missing"
    case exchangeAckEvidenceMissing = "exchange ack evidence missing"
    case transportFailure = "transport failure"
}

/// ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy 描述 GH-1313 的
/// 单笔 Binance Spot canary submit transport 输入约束。
///
/// Policy 只保存可审计的 scope、gate 和脱敏 evidence handle，不保存 raw credential、signature、
/// raw request payload、raw exchange ack 或 account payload。
public struct ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy:
    Codable, Equatable, Sendable
{
    public let policyID: Identifier
    public let commandGatewayGateHeld: Bool
    public let riskGateHeld: Bool
    public let killSwitchClear: Bool
    public let noTradeClear: Bool
    public let executionEngineGateHeld: Bool
    public let omsGateHeld: Bool
    public let requestedSymbol: String
    public let requestedSide: String
    public let requestedOrderType: String
    public let requestedTimeInForce: String
    public let requestedNotionalMinorUnits: Int
    public let requestedQuantityBaseMinorUnits: Int
    public let orderAlreadySubmittedForRun: Bool
    public let redactedRequestEvidenceStored: Bool
    public let exchangeAckEvidenceStored: Bool
    public let transportFailureObserved: Bool
    public let rawRequestPayloadPersisted: Bool
    public let rawExchangeAckPersisted: Bool
    public let rawCredentialValuePersisted: Bool
    public let signaturePersisted: Bool
    public let repeatedAutomatedTradingLoopEnabled: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var allowlistedScopeHeld: Bool {
        requestedSymbol == Self.requiredSymbol
            && requestedSide == Self.requiredSide
            && requestedOrderType == Self.requiredOrderType
            && requestedTimeInForce == Self.requiredTimeInForce
            && requestedNotionalMinorUnits <= Self.requiredMaxNotionalMinorUnits
            && requestedQuantityBaseMinorUnits <= Self.requiredMaxQuantityBaseMinorUnits
    }

    public var gatesHeld: Bool {
        commandGatewayGateHeld
            && riskGateHeld
            && killSwitchClear
            && noTradeClear
            && executionEngineGateHeld
            && omsGateHeld
    }

    public var oneShotHeld: Bool {
        orderAlreadySubmittedForRun == false
    }

    public var evidenceHeld: Bool {
        redactedRequestEvidenceStored
            && exchangeAckEvidenceStored
            && transportFailureObserved == false
    }

    public var forbiddenCapabilitiesClosed: Bool {
        rawRequestPayloadPersisted == false
            && rawExchangeAckPersisted == false
            && rawCredentialValuePersisted == false
            && signaturePersisted == false
            && repeatedAutomatedTradingLoopEnabled == false
            && futuresExecutionEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingCommandEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        policyID: Identifier = Identifier.constant("gh-1313-v0220-one-shot-submit-transport-policy"),
        commandGatewayGateHeld: Bool = true,
        riskGateHeld: Bool = true,
        killSwitchClear: Bool = true,
        noTradeClear: Bool = true,
        executionEngineGateHeld: Bool = true,
        omsGateHeld: Bool = true,
        requestedSymbol: String = Self.requiredSymbol,
        requestedSide: String = Self.requiredSide,
        requestedOrderType: String = Self.requiredOrderType,
        requestedTimeInForce: String = Self.requiredTimeInForce,
        requestedNotionalMinorUnits: Int = Self.requiredMaxNotionalMinorUnits,
        requestedQuantityBaseMinorUnits: Int = Self.requiredMaxQuantityBaseMinorUnits,
        orderAlreadySubmittedForRun: Bool = false,
        redactedRequestEvidenceStored: Bool = true,
        exchangeAckEvidenceStored: Bool = true,
        transportFailureObserved: Bool = false,
        rawRequestPayloadPersisted: Bool = false,
        rawExchangeAckPersisted: Bool = false,
        rawCredentialValuePersisted: Bool = false,
        signaturePersisted: Bool = false,
        repeatedAutomatedTradingLoopEnabled: Bool = false,
        futuresExecutionEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        try Self.validateForbiddenFlags(
            rawRequestPayloadPersisted: rawRequestPayloadPersisted,
            rawExchangeAckPersisted: rawExchangeAckPersisted,
            rawCredentialValuePersisted: rawCredentialValuePersisted,
            signaturePersisted: signaturePersisted,
            repeatedAutomatedTradingLoopEnabled: repeatedAutomatedTradingLoopEnabled,
            futuresExecutionEnabled: futuresExecutionEnabled,
            okxActiveImplementationEnabled: okxActiveImplementationEnabled,
            dashboardTradingCommandEnabled: dashboardTradingCommandEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized
        )

        self.policyID = policyID
        self.commandGatewayGateHeld = commandGatewayGateHeld
        self.riskGateHeld = riskGateHeld
        self.killSwitchClear = killSwitchClear
        self.noTradeClear = noTradeClear
        self.executionEngineGateHeld = executionEngineGateHeld
        self.omsGateHeld = omsGateHeld
        self.requestedSymbol = requestedSymbol
        self.requestedSide = requestedSide
        self.requestedOrderType = requestedOrderType
        self.requestedTimeInForce = requestedTimeInForce
        self.requestedNotionalMinorUnits = requestedNotionalMinorUnits
        self.requestedQuantityBaseMinorUnits = requestedQuantityBaseMinorUnits
        self.orderAlreadySubmittedForRun = orderAlreadySubmittedForRun
        self.redactedRequestEvidenceStored = redactedRequestEvidenceStored
        self.exchangeAckEvidenceStored = exchangeAckEvidenceStored
        self.transportFailureObserved = transportFailureObserved
        self.rawRequestPayloadPersisted = rawRequestPayloadPersisted
        self.rawExchangeAckPersisted = rawExchangeAckPersisted
        self.rawCredentialValuePersisted = rawCredentialValuePersisted
        self.signaturePersisted = signaturePersisted
        self.repeatedAutomatedTradingLoopEnabled = repeatedAutomatedTradingLoopEnabled
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws
        -> ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy()
    }

    public static func missingPreflightFixture() throws
        -> ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy()
    }

    public static func riskRejectedFixture() throws
        -> ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy(riskGateHeld: false)
    }

    public static func killSwitchRejectedFixture() throws
        -> ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy(killSwitchClear: false)
    }

    public static func noTradeRejectedFixture() throws
        -> ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy(noTradeClear: false)
    }

    public static func limitRejectedFixture() throws
        -> ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy(
            requestedNotionalMinorUnits: Self.requiredMaxNotionalMinorUnits + 1
        )
    }

    public static func duplicateRejectedFixture() throws
        -> ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy(orderAlreadySubmittedForRun: true)
    }

    public static func transportFailureFixture() throws
        -> ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy
    {
        try ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy(
            exchangeAckEvidenceStored: false,
            transportFailureObserved: true
        )
    }

    public static let requiredSymbol = "BTCUSDT"
    public static let requiredSide = "BUY"
    public static let requiredOrderType = "LIMIT"
    public static let requiredTimeInForce = "GTC"
    public static let requiredMaxNotionalMinorUnits = 500
    public static let requiredMaxQuantityBaseMinorUnits = 50_000
}

private extension ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy {
    static func validateForbiddenFlags(
        rawRequestPayloadPersisted: Bool,
        rawExchangeAckPersisted: Bool,
        rawCredentialValuePersisted: Bool,
        signaturePersisted: Bool,
        repeatedAutomatedTradingLoopEnabled: Bool,
        futuresExecutionEnabled: Bool,
        okxActiveImplementationEnabled: Bool,
        dashboardTradingCommandEnabled: Bool,
        productionCutoverAuthorized: Bool
    ) throws {
        for (field, value) in [
            ("rawRequestPayloadPersisted", rawRequestPayloadPersisted),
            ("rawExchangeAckPersisted", rawExchangeAckPersisted),
            ("rawCredentialValuePersisted", rawCredentialValuePersisted),
            ("signaturePersisted", signaturePersisted),
            ("repeatedAutomatedTradingLoopEnabled", repeatedAutomatedTradingLoopEnabled),
            ("futuresExecutionEnabled", futuresExecutionEnabled),
            ("okxActiveImplementationEnabled", okxActiveImplementationEnabled),
            ("dashboardTradingCommandEnabled", dashboardTradingCommandEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where value {
            throw CoreError.liveTradingBoundaryForbiddenCapability(
                "releaseV0220.oneShotSubmitTransport.\(field)"
            )
        }
    }
}

/// ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation 是 GH-1313 的
/// 单笔 submit transport 判定。
public struct ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation:
    Codable, Equatable, Sendable
{
    public let observationID: Identifier
    public let policy: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy
    public let upstreamSubmitPathHeld: Bool
    public let signedAccountPreflightHeld: Bool
    public let endpointFamilyReference: String
    public let orderPath: String
    public let method: String
    public let redactedRequestEnvelope: String
    public let redactedExchangeAckEnvelope: String
    public let outcome: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportOutcome
    public let rejectReasons: [ReleaseV0220SpotLiveCanaryOneShotSubmitTransportRejectReason]
    public let signedOrderSubmitTransportCreated: Bool
    public let exchangeAckEvidenceStored: Bool

    public var acceptedObservationHeld: Bool {
        rejectReasons.isEmpty
            && outcome == .submitted
            && signedOrderSubmitTransportCreated
            && exchangeAckEvidenceStored
            && upstreamSubmitPathHeld
            && signedAccountPreflightHeld
            && endpointHeld
            && redactedEvidenceHeld
            && policy.gatesHeld
            && policy.allowlistedScopeHeld
            && policy.oneShotHeld
            && policy.evidenceHeld
            && policy.forbiddenCapabilitiesClosed
    }

    public var failClosedObservationHeld: Bool {
        rejectReasons.isEmpty == false
            && outcome == .rejected
            && signedOrderSubmitTransportCreated == false
            && exchangeAckEvidenceStored == false
            && policy.forbiddenCapabilitiesClosed
    }

    public var endpointHeld: Bool {
        endpointFamilyReference == Self.requiredEndpointFamilyReference
            && orderPath == Self.requiredOrderPath
            && method == "POST"
    }

    public var redactedEvidenceHeld: Bool {
        redactedRequestEnvelope.hasPrefix(Self.requiredRedactedRequestPrefix)
            && redactedExchangeAckEnvelope.hasPrefix(Self.requiredRedactedAckPrefix)
            && redactedRequestEnvelope.contains("<redacted>")
            && redactedExchangeAckEnvelope.contains("<redacted>")
            && redactedRequestEnvelope.lowercased().contains("signature=") == false
            && redactedExchangeAckEnvelope.lowercased().contains("secret") == false
    }

    public init(
        observationID: Identifier? = nil,
        policy: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy,
        upstreamSubmitPathHeld: Bool = true,
        signedAccountPreflightHeld: Bool = true,
        endpointFamilyReference: String = Self.requiredEndpointFamilyReference,
        orderPath: String = Self.requiredOrderPath,
        method: String = "POST",
        redactedRequestEnvelope: String = Self.requiredRedactedRequestEnvelope,
        redactedExchangeAckEnvelope: String = Self.requiredRedactedAckEnvelope
    ) {
        let reasons = Self.expectedRejectReasons(
            policy: policy,
            upstreamSubmitPathHeld: upstreamSubmitPathHeld,
            signedAccountPreflightHeld: signedAccountPreflightHeld,
            endpointFamilyReference: endpointFamilyReference,
            orderPath: orderPath,
            method: method,
            redactedRequestEnvelope: redactedRequestEnvelope,
            redactedExchangeAckEnvelope: redactedExchangeAckEnvelope
        )
        let accepted = reasons.isEmpty
        self.observationID = observationID
            ?? Self.deterministicID(policy: policy, outcome: accepted ? .submitted : .rejected)
        self.policy = policy
        self.upstreamSubmitPathHeld = upstreamSubmitPathHeld
        self.signedAccountPreflightHeld = signedAccountPreflightHeld
        self.endpointFamilyReference = endpointFamilyReference
        self.orderPath = orderPath
        self.method = method
        self.redactedRequestEnvelope = redactedRequestEnvelope
        self.redactedExchangeAckEnvelope = redactedExchangeAckEnvelope
        self.outcome = accepted ? .submitted : .rejected
        self.rejectReasons = reasons
        self.signedOrderSubmitTransportCreated = accepted
        self.exchangeAckEvidenceStored = accepted
    }

    public static func expectedRejectReasons(
        policy: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy,
        upstreamSubmitPathHeld: Bool,
        signedAccountPreflightHeld: Bool,
        endpointFamilyReference: String,
        orderPath: String,
        method: String,
        redactedRequestEnvelope: String,
        redactedExchangeAckEnvelope: String
    ) -> [ReleaseV0220SpotLiveCanaryOneShotSubmitTransportRejectReason] {
        var reasons: [ReleaseV0220SpotLiveCanaryOneShotSubmitTransportRejectReason] = []
        if upstreamSubmitPathHeld == false {
            reasons.append(.upstreamSubmitPathRejected)
        }
        if signedAccountPreflightHeld == false {
            reasons.append(.signedAccountPreflightMissing)
        }
        if policy.commandGatewayGateHeld == false {
            reasons.append(.commandGatewayRejected)
        }
        if policy.riskGateHeld == false {
            reasons.append(.riskRejected)
        }
        if policy.killSwitchClear == false {
            reasons.append(.killSwitchActive)
        }
        if policy.noTradeClear == false {
            reasons.append(.noTradeActive)
        }
        if policy.executionEngineGateHeld == false {
            reasons.append(.executionEngineRejected)
        }
        if policy.omsGateHeld == false {
            reasons.append(.omsRejected)
        }
        if policy.allowlistedScopeHeld == false
            || endpointFamilyReference != Self.requiredEndpointFamilyReference
            || orderPath != Self.requiredOrderPath
            || method != "POST"
        {
            reasons.append(.allowlistScopeViolated)
        }
        if policy.oneShotHeld == false {
            reasons.append(.duplicateOrderAttempt)
        }
        if policy.redactedRequestEvidenceStored == false
            || redactedRequestEnvelope.hasPrefix(Self.requiredRedactedRequestPrefix) == false
            || redactedRequestEnvelope.contains("<redacted>") == false
        {
            reasons.append(.redactedRequestEvidenceMissing)
        }
        if policy.exchangeAckEvidenceStored == false
            || redactedExchangeAckEnvelope.hasPrefix(Self.requiredRedactedAckPrefix) == false
            || redactedExchangeAckEnvelope.contains("<redacted>") == false
        {
            reasons.append(.exchangeAckEvidenceMissing)
        }
        if policy.transportFailureObserved {
            reasons.append(.transportFailure)
        }
        return reasons
    }

    public static func deterministicID(
        policy: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportPolicy,
        outcome: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportOutcome
    ) -> Identifier {
        .constant(
            [
                "gh-1313-v0220-one-shot-submit-transport-observation",
                policy.policyID.rawValue,
                outcome.rawValue
            ].joined(separator: ":"),
            field: "releaseV0220.oneShotSubmitTransport.observationID"
        )
    }

    public static let requiredEndpointFamilyReference = "https://api.binance.com"
    public static let requiredOrderPath = "/api/v3/order"
    public static let requiredRedactedRequestPrefix = "redacted-order-request:gh-1313"
    public static let requiredRedactedAckPrefix = "redacted-exchange-ack:gh-1313"
    public static let requiredRedactedRequestEnvelope =
        "redacted-order-request:gh-1313 symbol=BTCUSDT side=BUY type=LIMIT tif=GTC notional=<redacted> quantity=<redacted> clientOrderId=<redacted>"
    public static let requiredRedactedAckEnvelope =
        "redacted-exchange-ack:gh-1313 orderId=<redacted> clientOrderId=<redacted> status=ACK endpoint=<redacted>"
}

/// ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence 是 GH-1313 的
/// 单笔 Binance Spot live canary submit transport evidence。
public struct ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence:
    Codable, Equatable, Sendable
{
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let blockedByIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let releaseVersion: String
    public let venueID: ReleaseV0181VenueID
    public let productKind: ReleaseV0181ProductKind
    public let tradingEnvironment: ReleaseV0181TradingEnvironment
    public let upstreamControlledSubmitPath: ReleaseV0210ControlledSpotCanarySubmitPathEvidence
    public let signedAccountRuntimePreflight: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight
    public let acceptedObservation: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation
    public let missingPreflightObservation: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation
    public let riskRejectedObservation: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation
    public let killSwitchRejectedObservation: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation
    public let noTradeRejectedObservation: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation
    public let limitRejectedObservation: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation
    public let duplicateRejectedObservation: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation
    public let transportFailureObservation: ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let allPreviousGatesRequired: Bool
    public let oneApprovedOrderOnly: Bool
    public let commandRiskKillNoTradeExecutionOMSGatesRequired: Bool
    public let redactedExchangeAckEvidenceRequired: Bool
    public let failClosedForLimitRiskKillNoTradeTransport: Bool
    public let productionTradingEnabledByDefault: Bool
    public let futuresExecutionEnabled: Bool
    public let okxActiveImplementationEnabled: Bool
    public let dashboardTradingCommandEnabled: Bool
    public let repeatedAutomatedTradingLoopEnabled: Bool
    public let createsTagOrRelease: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-1313"
            && blockedByIssueIDs.map(\.rawValue) == ["GH-1312"]
            && downstreamIssueIDs.map(\.rawValue) == ["GH-1314", "GH-1315"]
            && canonicalQueueRange == "GH-1309..GH-1320"
            && releaseVersion == "v0.22.0"
            && namespaceHeld
            && upstreamControlledSubmitPath.evidenceHeld
            && signedAccountRuntimePreflight.preflightHeld
            && observationsHeld
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && requiredControlsHeld
            && forbiddenCapabilitiesClosed
    }

    public var namespaceHeld: Bool {
        venueID == .binance
            && productKind == .spot
            && tradingEnvironment == .productionLive
    }

    public var observationsHeld: Bool {
        acceptedObservation.acceptedObservationHeld
            && missingPreflightObservation.rejectReasons == [.signedAccountPreflightMissing]
            && riskRejectedObservation.rejectReasons == [.riskRejected]
            && killSwitchRejectedObservation.rejectReasons == [.killSwitchActive]
            && noTradeRejectedObservation.rejectReasons == [.noTradeActive]
            && limitRejectedObservation.rejectReasons == [.allowlistScopeViolated]
            && duplicateRejectedObservation.rejectReasons == [.duplicateOrderAttempt]
            && transportFailureObservation.rejectReasons == [.exchangeAckEvidenceMissing, .transportFailure]
            && [
                missingPreflightObservation,
                riskRejectedObservation,
                killSwitchRejectedObservation,
                noTradeRejectedObservation,
                limitRejectedObservation,
                duplicateRejectedObservation,
                transportFailureObservation
            ].allSatisfy(\.failClosedObservationHeld)
    }

    public var requiredControlsHeld: Bool {
        allPreviousGatesRequired
            && oneApprovedOrderOnly
            && commandRiskKillNoTradeExecutionOMSGatesRequired
            && redactedExchangeAckEvidenceRequired
            && failClosedForLimitRiskKillNoTradeTransport
    }

    public var forbiddenCapabilitiesClosed: Bool {
        productionTradingEnabledByDefault == false
            && futuresExecutionEnabled == false
            && okxActiveImplementationEnabled == false
            && dashboardTradingCommandEnabled == false
            && repeatedAutomatedTradingLoopEnabled == false
            && createsTagOrRelease == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-1313-release-v0.22.0-one-shot-submit-transport-evidence"),
        issueID: Identifier = Identifier.constant("GH-1313"),
        blockedByIssueIDs: [Identifier] = [Identifier.constant("GH-1312")],
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-1314"), Identifier.constant("GH-1315")],
        canonicalQueueRange: String = "GH-1309..GH-1320",
        releaseVersion: String = "v0.22.0",
        venueID: ReleaseV0181VenueID = .binance,
        productKind: ReleaseV0181ProductKind = .spot,
        tradingEnvironment: ReleaseV0181TradingEnvironment = .productionLive,
        upstreamControlledSubmitPath: ReleaseV0210ControlledSpotCanarySubmitPathEvidence? = nil,
        signedAccountRuntimePreflight: ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        allPreviousGatesRequired: Bool = true,
        oneApprovedOrderOnly: Bool = true,
        commandRiskKillNoTradeExecutionOMSGatesRequired: Bool = true,
        redactedExchangeAckEvidenceRequired: Bool = true,
        failClosedForLimitRiskKillNoTradeTransport: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        futuresExecutionEnabled: Bool = false,
        okxActiveImplementationEnabled: Bool = false,
        dashboardTradingCommandEnabled: Bool = false,
        repeatedAutomatedTradingLoopEnabled: Bool = false,
        createsTagOrRelease: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.evidenceID = evidenceID
        self.issueID = issueID
        self.blockedByIssueIDs = blockedByIssueIDs
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.releaseVersion = releaseVersion
        self.venueID = venueID
        self.productKind = productKind
        self.tradingEnvironment = tradingEnvironment
        self.upstreamControlledSubmitPath = try upstreamControlledSubmitPath
            ?? ReleaseV0210ControlledSpotCanarySubmitPathEvidence.deterministicFixture()
        self.signedAccountRuntimePreflight = try signedAccountRuntimePreflight
            ?? ReleaseV0220SpotLiveCanarySignedAccountReadOnlyRuntimePreflight.deterministicFixture()
        self.acceptedObservation = ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation(
            policy: try .deterministicFixture()
        )
        self.missingPreflightObservation = ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation(
            policy: try .missingPreflightFixture(),
            signedAccountPreflightHeld: false
        )
        self.riskRejectedObservation = ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation(
            policy: try .riskRejectedFixture()
        )
        self.killSwitchRejectedObservation = ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation(
            policy: try .killSwitchRejectedFixture()
        )
        self.noTradeRejectedObservation = ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation(
            policy: try .noTradeRejectedFixture()
        )
        self.limitRejectedObservation = ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation(
            policy: try .limitRejectedFixture()
        )
        self.duplicateRejectedObservation = ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation(
            policy: try .duplicateRejectedFixture()
        )
        self.transportFailureObservation = ReleaseV0220SpotLiveCanaryOneShotSubmitTransportObservation(
            policy: try .transportFailureFixture()
        )
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.allPreviousGatesRequired = allPreviousGatesRequired
        self.oneApprovedOrderOnly = oneApprovedOrderOnly
        self.commandRiskKillNoTradeExecutionOMSGatesRequired = commandRiskKillNoTradeExecutionOMSGatesRequired
        self.redactedExchangeAckEvidenceRequired = redactedExchangeAckEvidenceRequired
        self.failClosedForLimitRiskKillNoTradeTransport = failClosedForLimitRiskKillNoTradeTransport
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.futuresExecutionEnabled = futuresExecutionEnabled
        self.okxActiveImplementationEnabled = okxActiveImplementationEnabled
        self.dashboardTradingCommandEnabled = dashboardTradingCommandEnabled
        self.repeatedAutomatedTradingLoopEnabled = repeatedAutomatedTradingLoopEnabled
        self.createsTagOrRelease = createsTagOrRelease
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV0220.oneShotSubmitTransport",
                expected: "single approved Binance Spot canary submit transport evidence",
                actual: "invalid one-shot submit transport evidence"
            )
        }
    }

    public static func deterministicFixture() throws
        -> ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence
    {
        try ReleaseV0220SpotLiveCanaryOneShotSubmitTransportEvidence()
    }

    public static let requiredValidationAnchors = [
        "GH-1313-VERIFY-V0220-LIVE-ORDER-SUBMIT-TRANSPORT",
        "TVM-RELEASE-V0220-LIVE-ORDER-SUBMIT-TRANSPORT",
        "V0220-005-BLOCKED-BY-GH1312",
        "V0220-005-BINANCE-SPOT-ONE-SHOT-SUBMIT",
        "V0220-005-ALLOWLISTED-SYMBOL-NOTIONAL-SIDE-TIF",
        "V0220-005-COMMAND-RISK-KILL-NOTRADE-EXECUTION-OMS-GATES",
        "V0220-005-REDACTED-EXCHANGE-ACK-EVIDENCE",
        "V0220-005-SINGLE-APPROVED-ORDER-PER-RUN",
        "V0220-005-FAIL-CLOSED-LIMIT-RISK-KILL-NOTRADE-TRANSPORT",
        "V0220-005-NO-FUTURES-OKX",
        "V0220-005-NO-DASHBOARD-TRADING-CONTROLS",
        "V0220-005-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH1313ReleaseV0220LiveOrderSubmitTransport",
        "bash checks/verify-v0.22.0-live-order-submit-transport.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/verify-v0.21.0.sh",
        "bash checks/run.sh"
    ]
}
