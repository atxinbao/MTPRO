import DomainModel
import Foundation

/// L4ExecutionClientSandboxCommandKind 固定 GH-459 允许验证的 sandbox command kind。
///
/// 这些 command 只用于 sandbox-only request envelope 和 deterministic evidence；它们不会连接真实
/// broker、不会生成 signed request，也不会进入 production venue。
public enum L4ExecutionClientSandboxCommandKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case submit = "submit"
    case cancel = "cancel"
    case replace = "replace"
}

/// L4ExecutionClientSandboxVenueMode 区分当前允许的 sandbox 和仍禁止的 production。
///
/// GH-459 只能使用 `sandbox`。`production` 作为 rejected value 进入测试和 evidence，不能变成可达路径。
public enum L4ExecutionClientSandboxVenueMode: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case sandbox = "sandbox"
    case production = "production"
}

/// L4ExecutionClientSandboxForbiddenCapability 枚举 GH-459 必须保持关闭的能力。
///
/// Sandbox adapter 只生成 deterministic command evidence。它不实现真实 broker gateway、signed endpoint、
/// OMS、reconciliation、Live PRO Console、order form 或 production trading。
public enum L4ExecutionClientSandboxForbiddenCapability: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case productionVenueReachable = "production venue reachable"
    case productionTradingEnabledByDefault = "production trading enabled by default"
    case secretRead = "secret read"
    case signedRequestGenerated = "signed request generated"
    case accountEndpointCalled = "account endpoint called"
    case listenKeyRuntime = "listenKey runtime"
    case privateWebSocketRuntime = "private WebSocket runtime"
    case brokerGatewayTouched = "broker gateway touched"
    case realOrderSubmitted = "real order submitted"
    case realOrderCanceled = "real order canceled"
    case realOrderReplaced = "real order replaced"
    case executionReportRuntimeParser = "execution report runtime parser"
    case brokerFillRuntimeParser = "broker fill runtime parser"
    case omsImplementation = "OMS implementation"
    case reconciliationRuntime = "reconciliation runtime"
    case liveProConsoleCommandSurface = "Live PRO Console command surface"
    case orderForm = "order form"
}

/// L4ExecutionClientSandboxRequestEnvelope 是 GH-459 的 sandbox request/response evidence 输入。
///
/// Envelope 只保存可审计的本地 sandbox command identity、symbol、quantity、price 和 reason。它不是
/// exchange API request，不包含 header、signature、secret、account payload、broker payload 或 network URL。
public struct L4ExecutionClientSandboxRequestEnvelope: Codable, Equatable, Sendable {
    public let envelopeID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let commandKind: L4ExecutionClientSandboxCommandKind
    public let venueMode: L4ExecutionClientSandboxVenueMode
    public let sandboxVenueID: Identifier
    public let clientOrderID: Identifier
    public let symbol: String
    public let quantity: String
    public let limitPrice: String
    public let reason: String
    public let signedRequestGenerated: Bool
    public let brokerGatewayTouched: Bool
    public let productionVenueReachable: Bool

    public init(
        envelopeID: Identifier,
        issueID: Identifier = Identifier.constant("GH-459"),
        upstreamIssueID: Identifier = Identifier.constant("GH-458"),
        commandKind: L4ExecutionClientSandboxCommandKind,
        venueMode: L4ExecutionClientSandboxVenueMode = .sandbox,
        sandboxVenueID: Identifier = Identifier.constant("gh-459-sandbox-venue"),
        clientOrderID: Identifier,
        symbol: String,
        quantity: String,
        limitPrice: String,
        reason: String,
        signedRequestGenerated: Bool = false,
        brokerGatewayTouched: Bool = false,
        productionVenueReachable: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-459" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-459",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-458" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-458",
                actual: upstreamIssueID.rawValue
            )
        }
        guard venueMode == .sandbox else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("venueMode.production")
        }
        for requiredField in [
            ("symbol", symbol),
            ("quantity", quantity),
            ("limitPrice", limitPrice),
            ("reason", reason)
        ] where requiredField.1.isEmpty {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredField.0,
                expected: "non-empty sandbox request envelope value",
                actual: "empty"
            )
        }
        for forbiddenFlag in [
            ("signedRequestGenerated", signedRequestGenerated),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("productionVenueReachable", productionVenueReachable)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.envelopeID = envelopeID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.commandKind = commandKind
        self.venueMode = venueMode
        self.sandboxVenueID = sandboxVenueID
        self.clientOrderID = clientOrderID
        self.symbol = symbol
        self.quantity = quantity
        self.limitPrice = limitPrice
        self.reason = reason
        self.signedRequestGenerated = signedRequestGenerated
        self.brokerGatewayTouched = brokerGatewayTouched
        self.productionVenueReachable = productionVenueReachable
    }
}

/// L4ExecutionClientSandboxCommandResponse 是 GH-459 的 deterministic command evidence 行。
///
/// Response 只证明 sandbox adapter 接收了本地 envelope 并返回可审计结果；它不代表交易所确认、
/// broker fill、execution report、OMS state transition 或真实 order lifecycle。
public struct L4ExecutionClientSandboxCommandResponse: Codable, Equatable, Sendable {
    public let responseID: Identifier
    public let requestEnvelopeID: Identifier
    public let commandKind: L4ExecutionClientSandboxCommandKind
    public let venueMode: L4ExecutionClientSandboxVenueMode
    public let acceptedBySandbox: Bool
    public let deterministicTraceID: Identifier
    public let responseStatus: String
    public let productionVenueTouched: Bool
    public let brokerGatewayTouched: Bool
    public let realOrderLifecycleTouched: Bool

    public init(
        responseID: Identifier,
        requestEnvelopeID: Identifier,
        commandKind: L4ExecutionClientSandboxCommandKind,
        venueMode: L4ExecutionClientSandboxVenueMode = .sandbox,
        acceptedBySandbox: Bool = true,
        deterministicTraceID: Identifier,
        responseStatus: String,
        productionVenueTouched: Bool = false,
        brokerGatewayTouched: Bool = false,
        realOrderLifecycleTouched: Bool = false
    ) throws {
        guard venueMode == .sandbox else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("venueMode.production")
        }
        guard acceptedBySandbox else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "acceptedBySandbox",
                expected: "true deterministic sandbox acceptance",
                actual: "false"
            )
        }
        guard responseStatus.isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "responseStatus",
                expected: "non-empty sandbox response status",
                actual: "empty"
            )
        }
        for forbiddenFlag in [
            ("productionVenueTouched", productionVenueTouched),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("realOrderLifecycleTouched", realOrderLifecycleTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.responseID = responseID
        self.requestEnvelopeID = requestEnvelopeID
        self.commandKind = commandKind
        self.venueMode = venueMode
        self.acceptedBySandbox = acceptedBySandbox
        self.deterministicTraceID = deterministicTraceID
        self.responseStatus = responseStatus
        self.productionVenueTouched = productionVenueTouched
        self.brokerGatewayTouched = brokerGatewayTouched
        self.realOrderLifecycleTouched = realOrderLifecycleTouched
    }
}

/// L4ExecutionClientSandboxCommandEvidence 汇总 GH-459 submit / cancel / replace 证据链。
///
/// Evidence 必须覆盖三类 command，并证明 production venue disabled、request/response 可审计、
/// forbidden flags 全部关闭。它不是 OMS lifecycle，也不包含 execution report 或 broker fill。
public struct L4ExecutionClientSandboxCommandEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let requestEnvelopes: [L4ExecutionClientSandboxRequestEnvelope]
    public let responses: [L4ExecutionClientSandboxCommandResponse]
    public let validationAnchors: [String]
    public let requestResponseEvidenceAuditable: Bool
    public let productionVenueDisabled: Bool
    public let signedEndpointTouched: Bool
    public let brokerGatewayTouched: Bool
    public let realOrderLifecycleTouched: Bool
    public let omsTouched: Bool
    public let liveCommandSurfaceTouched: Bool

    public var commandEvidenceHeld: Bool {
        issueID.rawValue == "GH-459"
            && upstreamIssueID.rawValue == "GH-458"
            && Set(requestEnvelopes.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases)
            && Set(responses.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases)
            && requestEnvelopes.allSatisfy { $0.venueMode == .sandbox }
            && responses.allSatisfy { $0.venueMode == .sandbox }
            && responses.allSatisfy(\.acceptedBySandbox)
            && validationAnchors == L4ExecutionClientSandboxVenueAdapter.requiredValidationAnchors
            && requestResponseEvidenceAuditable
            && productionVenueDisabled
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            signedEndpointTouched,
            brokerGatewayTouched,
            realOrderLifecycleTouched,
            omsTouched,
            liveCommandSurfaceTouched
        ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-459-executionclient-sandbox-command-evidence"),
        issueID: Identifier = Identifier.constant("GH-459"),
        upstreamIssueID: Identifier = Identifier.constant("GH-458"),
        requestEnvelopes: [L4ExecutionClientSandboxRequestEnvelope],
        responses: [L4ExecutionClientSandboxCommandResponse],
        validationAnchors: [String] = L4ExecutionClientSandboxVenueAdapter.requiredValidationAnchors,
        requestResponseEvidenceAuditable: Bool = true,
        productionVenueDisabled: Bool = true,
        signedEndpointTouched: Bool = false,
        brokerGatewayTouched: Bool = false,
        realOrderLifecycleTouched: Bool = false,
        omsTouched: Bool = false,
        liveCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-459" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-459",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-458" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-458",
                actual: upstreamIssueID.rawValue
            )
        }
        guard Set(requestEnvelopes.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requestEnvelopes",
                expected: L4ExecutionClientSandboxCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: requestEnvelopes.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard Set(responses.map(\.commandKind)) == Set(L4ExecutionClientSandboxCommandKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "responses",
                expected: L4ExecutionClientSandboxCommandKind.allCases.map(\.rawValue).joined(separator: ","),
                actual: responses.map { $0.commandKind.rawValue }.joined(separator: ",")
            )
        }
        guard validationAnchors == L4ExecutionClientSandboxVenueAdapter.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: L4ExecutionClientSandboxVenueAdapter.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard requestResponseEvidenceAuditable else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("requestResponseEvidenceAuditable")
        }
        guard productionVenueDisabled else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("productionVenueDisabled")
        }
        for forbiddenFlag in [
            ("signedEndpointTouched", signedEndpointTouched),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("realOrderLifecycleTouched", realOrderLifecycleTouched),
            ("omsTouched", omsTouched),
            ("liveCommandSurfaceTouched", liveCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.requestEnvelopes = requestEnvelopes
        self.responses = responses
        self.validationAnchors = validationAnchors
        self.requestResponseEvidenceAuditable = requestResponseEvidenceAuditable
        self.productionVenueDisabled = productionVenueDisabled
        self.signedEndpointTouched = signedEndpointTouched
        self.brokerGatewayTouched = brokerGatewayTouched
        self.realOrderLifecycleTouched = realOrderLifecycleTouched
        self.omsTouched = omsTouched
        self.liveCommandSurfaceTouched = liveCommandSurfaceTouched
    }
}

/// L4ExecutionClientSandboxVenueAdapter 是 GH-459 的 sandbox-only adapter。
///
/// Adapter 只接受 sandbox request envelope，并返回 deterministic command evidence。它不保存 credential、
/// 不生成 signed request、不连接网络、不触碰 broker gateway、不推进 OMS，也不暴露 Live command surface。
public struct L4ExecutionClientSandboxVenueAdapter: Codable, Equatable, Sendable {
    public let adapterID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let contract: L4ExecutionClientVenueAdapterContract
    public let venueMode: L4ExecutionClientSandboxVenueMode
    public let forbiddenCapabilities: [L4ExecutionClientSandboxForbiddenCapability]
    public let validationAnchors: [String]
    public let productionVenueEnabled: Bool
    public let readsSecret: Bool
    public let generatesSignedRequest: Bool
    public let touchesBrokerGateway: Bool
    public let touchesOMS: Bool
    public let touchesLiveCommandSurface: Bool

    public var sandboxAdapterBoundaryHeld: Bool {
        issueID.rawValue == "GH-459"
            && upstreamIssueID.rawValue == "GH-458"
            && contract.contractHeld
            && venueMode == .sandbox
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && allForbiddenFlagsRemainClosed
    }

    private var allForbiddenFlagsRemainClosed: Bool {
        [
            productionVenueEnabled,
            readsSecret,
            generatesSignedRequest,
            touchesBrokerGateway,
            touchesOMS,
            touchesLiveCommandSurface
        ].allSatisfy { $0 == false }
    }

    public init(
        adapterID: Identifier = Identifier.constant("gh-459-executionclient-sandbox-venue-adapter"),
        issueID: Identifier = Identifier.constant("GH-459"),
        upstreamIssueID: Identifier = Identifier.constant("GH-458"),
        contract: L4ExecutionClientVenueAdapterContract? = nil,
        venueMode: L4ExecutionClientSandboxVenueMode = .sandbox,
        forbiddenCapabilities: [L4ExecutionClientSandboxForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionVenueEnabled: Bool = false,
        readsSecret: Bool = false,
        generatesSignedRequest: Bool = false,
        touchesBrokerGateway: Bool = false,
        touchesOMS: Bool = false,
        touchesLiveCommandSurface: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-459" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-459",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueID.rawValue == "GH-458" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueID",
                expected: "GH-458",
                actual: upstreamIssueID.rawValue
            )
        }
        let resolvedContract = try contract ?? L4ExecutionClientVenueAdapterContract.deterministicFixture()
        guard resolvedContract.contractHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "contract",
                expected: "GH-458 ExecutionClient venue adapter contract held",
                actual: "mismatch"
            )
        }
        guard venueMode == .sandbox else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("venueMode.production")
        }
        guard forbiddenCapabilities == Self.requiredForbiddenCapabilities else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "forbiddenCapabilities",
                expected: Self.requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                actual: forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("productionVenueEnabled", productionVenueEnabled),
            ("readsSecret", readsSecret),
            ("generatesSignedRequest", generatesSignedRequest),
            ("touchesBrokerGateway", touchesBrokerGateway),
            ("touchesOMS", touchesOMS),
            ("touchesLiveCommandSurface", touchesLiveCommandSurface)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.adapterID = adapterID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.contract = resolvedContract
        self.venueMode = venueMode
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.productionVenueEnabled = productionVenueEnabled
        self.readsSecret = readsSecret
        self.generatesSignedRequest = generatesSignedRequest
        self.touchesBrokerGateway = touchesBrokerGateway
        self.touchesOMS = touchesOMS
        self.touchesLiveCommandSurface = touchesLiveCommandSurface
    }

    public func submit(
        _ envelope: L4ExecutionClientSandboxRequestEnvelope
    ) throws -> L4ExecutionClientSandboxCommandResponse {
        try makeResponse(for: envelope, expectedKind: .submit)
    }

    public func cancel(
        _ envelope: L4ExecutionClientSandboxRequestEnvelope
    ) throws -> L4ExecutionClientSandboxCommandResponse {
        try makeResponse(for: envelope, expectedKind: .cancel)
    }

    public func replace(
        _ envelope: L4ExecutionClientSandboxRequestEnvelope
    ) throws -> L4ExecutionClientSandboxCommandResponse {
        try makeResponse(for: envelope, expectedKind: .replace)
    }

    /// 生成 GH-459 的 deterministic submit / cancel / replace evidence。
    public func deterministicCommandEvidence() throws -> L4ExecutionClientSandboxCommandEvidence {
        let submitEnvelope = try Self.deterministicEnvelope(kind: .submit)
        let cancelEnvelope = try Self.deterministicEnvelope(kind: .cancel)
        let replaceEnvelope = try Self.deterministicEnvelope(kind: .replace)
        return try L4ExecutionClientSandboxCommandEvidence(
            requestEnvelopes: [submitEnvelope, cancelEnvelope, replaceEnvelope],
            responses: [
                submit(submitEnvelope),
                cancel(cancelEnvelope),
                replace(replaceEnvelope)
            ]
        )
    }

    public static func deterministicFixture() throws -> L4ExecutionClientSandboxVenueAdapter {
        try L4ExecutionClientSandboxVenueAdapter()
    }

    static func deterministicEnvelope(
        kind: L4ExecutionClientSandboxCommandKind
    ) throws -> L4ExecutionClientSandboxRequestEnvelope {
        try L4ExecutionClientSandboxRequestEnvelope(
            envelopeID: Identifier.constant("gh-459-sandbox-\(kind.rawValue)-request-envelope"),
            commandKind: kind,
            clientOrderID: Identifier.constant("gh-459-sandbox-client-order-\(kind.rawValue)"),
            symbol: "BTCUSDT",
            quantity: "0.0100",
            limitPrice: "42120.70",
            reason: "GH-459 deterministic sandbox \(kind.rawValue) evidence"
        )
    }

    public static let requiredForbiddenCapabilities = L4ExecutionClientSandboxForbiddenCapability.allCases

    public static let requiredValidationAnchors = [
        "GH-459-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE",
        "GH-459-SANDBOX-REQUEST-ENVELOPE",
        "GH-459-DETERMINISTIC-COMMAND-EVIDENCE",
        "GH-459-PRODUCTION-VENUE-DISABLED",
        "TVM-L4-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE"
    ]

    private func makeResponse(
        for envelope: L4ExecutionClientSandboxRequestEnvelope,
        expectedKind: L4ExecutionClientSandboxCommandKind
    ) throws -> L4ExecutionClientSandboxCommandResponse {
        guard sandboxAdapterBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sandboxAdapterBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard envelope.commandKind == expectedKind else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "commandKind",
                expected: expectedKind.rawValue,
                actual: envelope.commandKind.rawValue
            )
        }
        return try L4ExecutionClientSandboxCommandResponse(
            responseID: Identifier.constant("gh-459-sandbox-\(expectedKind.rawValue)-response"),
            requestEnvelopeID: envelope.envelopeID,
            commandKind: expectedKind,
            deterministicTraceID: Identifier.constant("gh-459-sandbox-\(expectedKind.rawValue)-trace"),
            responseStatus: "accepted by deterministic sandbox \(expectedKind.rawValue) adapter"
        )
    }
}
