import CryptoKit
import Foundation

// GH-1559-ADD-APPROVAL-BOUND-OBSERVED-CANARY-RUNNER
// TVM-RELEASE-V0330-APPROVAL-BOUND-OBSERVED-CANARY-RUNNER
// V0330-002A-APPROVAL-BOUND-FAIL-CLOSED-RUNNER

// GH-1561-ADD-EXACT-OBSERVED-CANARY-ORDER-PLAN
// TVM-RELEASE-V0330-EXACT-ORDER-PLAN-ACTIVATION-BOUNDARY
// V0330-002B-EXACT-ORDER-PLAN-FAIL-CLOSED-ACTIVATION

// GH-1565-ADD-EXPLICIT-BINANCE-DEMO-CANARY-ENVIRONMENT
// TVM-RELEASE-V0330-BINANCE-DEMO-ENVIRONMENT-ISOLATION
// V0330-002D-DEMO-ENVIRONMENT-FAIL-CLOSED-BINDING

public enum ReleaseV0330CanaryEnvironment: String, Codable, Sendable {
    case production
    case demo

    public func endpointHost(for product: ReleaseV0330CanaryProduct) -> String {
        switch (self, product) {
        case (.production, .spot):
            "api.binance.com"
        case (.production, .usdsPerpetual):
            "fapi.binance.com"
        case (.demo, .spot):
            "demo-api.binance.com"
        case (.demo, .usdsPerpetual):
            "demo-fapi.binance.com"
        }
    }

    public func endpointBaseURL(for product: ReleaseV0330CanaryProduct) -> URL {
        URL(string: "https://\(endpointHost(for: product))")!
    }
}

public struct ReleaseV0330ObservedCanaryOrderPlan: Codable, Equatable, Sendable {
    public let planID: String
    public let approvalPacketID: String
    public let sourceCommit: String
    public let product: ReleaseV0330CanaryProduct
    public let issueNumber: Int
    public let symbol: String
    public let side: String
    public let orderType: String
    public let timeInForce: String
    public let priceQuoteMinorUnits: Int64
    public let quantityBaseAtomicUnits: Int64
    public let baseAssetScale: Int
    public let notionalMinorUnits: Int64
    public let leverageBasisPoints: Int
    public let clientOrderID: String

    public init(
        planID: String,
        approvalPacketID: String,
        sourceCommit: String,
        product: ReleaseV0330CanaryProduct,
        issueNumber: Int,
        symbol: String,
        side: String,
        orderType: String,
        timeInForce: String,
        priceQuoteMinorUnits: Int64,
        quantityBaseAtomicUnits: Int64,
        baseAssetScale: Int,
        notionalMinorUnits: Int64,
        leverageBasisPoints: Int,
        clientOrderID: String
    ) {
        self.planID = planID
        self.approvalPacketID = approvalPacketID
        self.sourceCommit = sourceCommit
        self.product = product
        self.issueNumber = issueNumber
        self.symbol = symbol
        self.side = side
        self.orderType = orderType
        self.timeInForce = timeInForce
        self.priceQuoteMinorUnits = priceQuoteMinorUnits
        self.quantityBaseAtomicUnits = quantityBaseAtomicUnits
        self.baseAssetScale = baseAssetScale
        self.notionalMinorUnits = notionalMinorUnits
        self.leverageBasisPoints = leverageBasisPoints
        self.clientOrderID = clientOrderID
    }

    public func canonicalSHA256() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let digest = SHA256.hash(data: try encoder.encode(self))
        return "sha256:" + digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func deterministicClientOrderID(
        planID: String,
        sourceCommit: String,
        product: ReleaseV0330CanaryProduct,
        symbol: String,
        issueNumber: Int
    ) -> String {
        let material = "\(planID)|\(sourceCommit)|\(product.rawValue)|\(symbol)|\(issueNumber)"
        let digest = SHA256.hash(data: Data(material.utf8))
        return "mtp33-" + digest.prefix(12).map { String(format: "%02x", $0) }.joined()
    }
}

public struct ReleaseV0330ObservedCanaryExecutionAuthorization: Codable, Equatable, Sendable {
    public let recordID: String
    public let approvalPacketID: String
    public let approverIdentity: String
    public let sourceCommit: String
    public let product: ReleaseV0330CanaryProduct
    public let symbol: String
    public let issueNumber: Int
    public let authorizedAtEpochSeconds: Int64
    public let expiresAtEpochSeconds: Int64
    public let attestationSHA256: String
    public let orderPlanSHA256: String
    public let evidenceOrigin: ReleaseV0330ApprovalEvidenceOrigin
    public let oneShot: Bool

    public init(
        recordID: String,
        approvalPacketID: String,
        approverIdentity: String,
        sourceCommit: String,
        product: ReleaseV0330CanaryProduct,
        symbol: String,
        issueNumber: Int,
        authorizedAtEpochSeconds: Int64,
        expiresAtEpochSeconds: Int64,
        attestationSHA256: String,
        orderPlanSHA256: String,
        evidenceOrigin: ReleaseV0330ApprovalEvidenceOrigin,
        oneShot: Bool
    ) {
        self.recordID = recordID
        self.approvalPacketID = approvalPacketID
        self.approverIdentity = approverIdentity
        self.sourceCommit = sourceCommit
        self.product = product
        self.symbol = symbol
        self.issueNumber = issueNumber
        self.authorizedAtEpochSeconds = authorizedAtEpochSeconds
        self.expiresAtEpochSeconds = expiresAtEpochSeconds
        self.attestationSHA256 = attestationSHA256
        self.orderPlanSHA256 = orderPlanSHA256
        self.evidenceOrigin = evidenceOrigin
        self.oneShot = oneShot
    }
}

public struct ReleaseV0330ObservedCanaryRunRequest: Sendable {
    public let runID: String
    public let ownerID: String
    public let nonce: String
    public let sourceCommit: String
    public let approvalPacket: ReleaseV0330CanaryApprovalPacket
    public let executionAuthorization: ReleaseV0330ObservedCanaryExecutionAuthorization
    public let orderPlan: ReleaseV0330ObservedCanaryOrderPlan
    public let environment: ReleaseV0330CanaryEnvironment
    public let baseURL: URL
    public let credentialReference: String
    public let riskGatePassed: Bool
    public let killSwitchClear: Bool
    public let noTradeClear: Bool
    public let rollbackEvidenceReference: String
    public let evaluationEpochSeconds: Int64

    public init(
        runID: String,
        ownerID: String,
        nonce: String,
        sourceCommit: String,
        approvalPacket: ReleaseV0330CanaryApprovalPacket,
        executionAuthorization: ReleaseV0330ObservedCanaryExecutionAuthorization,
        orderPlan: ReleaseV0330ObservedCanaryOrderPlan,
        environment: ReleaseV0330CanaryEnvironment = .production,
        baseURL: URL,
        credentialReference: String,
        riskGatePassed: Bool,
        killSwitchClear: Bool,
        noTradeClear: Bool,
        rollbackEvidenceReference: String,
        evaluationEpochSeconds: Int64
    ) {
        self.runID = runID
        self.ownerID = ownerID
        self.nonce = nonce
        self.sourceCommit = sourceCommit
        self.approvalPacket = approvalPacket
        self.executionAuthorization = executionAuthorization
        self.orderPlan = orderPlan
        self.environment = environment
        self.baseURL = baseURL
        self.credentialReference = credentialReference
        self.riskGatePassed = riskGatePassed
        self.killSwitchClear = killSwitchClear
        self.noTradeClear = noTradeClear
        self.rollbackEvidenceReference = rollbackEvidenceReference
        self.evaluationEpochSeconds = evaluationEpochSeconds
    }
}

public struct ReleaseV0330ObservedCanaryTransportRequest: Equatable, Sendable {
    public let runID: String
    public let sourceCommit: String
    public let orderPlan: ReleaseV0330ObservedCanaryOrderPlan
    public let action: ReleaseV0320CanaryAction
    public let environment: ReleaseV0330CanaryEnvironment
    public let baseURL: URL
    public let credentialReference: String

    public var product: ReleaseV0330CanaryProduct { orderPlan.product }
    public var symbol: String { orderPlan.symbol }
    public var notionalMinorUnits: Int64 { orderPlan.notionalMinorUnits }
    public var orderType: String { orderPlan.orderType }
    public var leverageBasisPoints: Int { orderPlan.leverageBasisPoints }

    public init(
        runID: String,
        sourceCommit: String,
        orderPlan: ReleaseV0330ObservedCanaryOrderPlan,
        action: ReleaseV0320CanaryAction,
        environment: ReleaseV0330CanaryEnvironment = .production,
        baseURL: URL,
        credentialReference: String
    ) {
        self.runID = runID
        self.sourceCommit = sourceCommit
        self.orderPlan = orderPlan
        self.action = action
        self.environment = environment
        self.baseURL = baseURL
        self.credentialReference = credentialReference
    }
}

public struct ReleaseV0330ObservedCanaryArtifactReference: Codable, Equatable, Sendable {
    public let relativePath: String
    public let sha256: String

    public init(relativePath: String, sha256: String) {
        self.relativePath = relativePath
        self.sha256 = sha256
    }
}

public struct ReleaseV0330ObservedCanaryTransportObservation: Codable, Equatable, Sendable {
    public let runID: String
    public let product: ReleaseV0330CanaryProduct
    public let action: ReleaseV0320CanaryAction
    public let environment: ReleaseV0330CanaryEnvironment
    public let requestID: String
    public let redactedOrderReference: String
    public let endpointHost: String
    public let artifact: ReleaseV0330ObservedCanaryArtifactReference
    public let rawSecretPersisted: Bool
    public let rawResponsePersisted: Bool

    public init(
        runID: String,
        product: ReleaseV0330CanaryProduct,
        action: ReleaseV0320CanaryAction,
        environment: ReleaseV0330CanaryEnvironment = .production,
        requestID: String,
        redactedOrderReference: String,
        endpointHost: String,
        artifact: ReleaseV0330ObservedCanaryArtifactReference,
        rawSecretPersisted: Bool,
        rawResponsePersisted: Bool
    ) {
        self.runID = runID
        self.product = product
        self.action = action
        self.environment = environment
        self.requestID = requestID
        self.redactedOrderReference = redactedOrderReference
        self.endpointHost = endpointHost
        self.artifact = artifact
        self.rawSecretPersisted = rawSecretPersisted
        self.rawResponsePersisted = rawResponsePersisted
    }
}

public protocol ReleaseV0330ObservedCanaryTransport: Sendable {
    func perform(
        _ request: ReleaseV0330ObservedCanaryTransportRequest
    ) async throws -> ReleaseV0330ObservedCanaryTransportObservation
}

public struct ReleaseV0330RejectingObservedCanaryTransport: ReleaseV0330ObservedCanaryTransport {
    public init() {}

    public func perform(
        _: ReleaseV0330ObservedCanaryTransportRequest
    ) async throws -> ReleaseV0330ObservedCanaryTransportObservation {
        throw ReleaseV0330ObservedCanaryRunnerError.transportNotConfigured
    }
}

public struct ReleaseV0330InjectedObservedCanaryTransport: ReleaseV0330ObservedCanaryTransport {
    private let handler: @Sendable (
        ReleaseV0330ObservedCanaryTransportRequest
    ) async throws -> ReleaseV0330ObservedCanaryTransportObservation

    public init(
        handler: @escaping @Sendable (
            ReleaseV0330ObservedCanaryTransportRequest
        ) async throws -> ReleaseV0330ObservedCanaryTransportObservation
    ) {
        self.handler = handler
    }

    public func perform(
        _ request: ReleaseV0330ObservedCanaryTransportRequest
    ) async throws -> ReleaseV0330ObservedCanaryTransportObservation {
        try await handler(request)
    }
}

public struct ReleaseV0330ObservedCanaryRunEvidence: Codable, Equatable, Sendable {
    public let runID: String
    public let sourceCommit: String
    public let product: ReleaseV0330CanaryProduct
    public let environment: ReleaseV0330CanaryEnvironment
    public let symbol: String
    public let approvalPacketID: String
    public let executionAuthorizationRecordID: String
    public let observations: [ReleaseV0330ObservedCanaryTransportObservation]
    public let runLockReleased: Bool
    public let productionCutoverAuthorized: Bool
    public let defaultProductionTradingEnabled: Bool

    public init(
        runID: String,
        sourceCommit: String,
        product: ReleaseV0330CanaryProduct,
        environment: ReleaseV0330CanaryEnvironment,
        symbol: String,
        approvalPacketID: String,
        executionAuthorizationRecordID: String,
        observations: [ReleaseV0330ObservedCanaryTransportObservation],
        runLockReleased: Bool,
        productionCutoverAuthorized: Bool,
        defaultProductionTradingEnabled: Bool
    ) {
        self.runID = runID
        self.sourceCommit = sourceCommit
        self.product = product
        self.environment = environment
        self.symbol = symbol
        self.approvalPacketID = approvalPacketID
        self.executionAuthorizationRecordID = executionAuthorizationRecordID
        self.observations = observations
        self.runLockReleased = runLockReleased
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.defaultProductionTradingEnabled = defaultProductionTradingEnabled
    }

    public var boundaryHeld: Bool {
        observations.map(\.action) == [.submit, .status, .cancel]
            && observations.allSatisfy {
                $0.runID == runID
                    && $0.product == product
                    && $0.environment == environment
                    && $0.rawSecretPersisted == false
                    && $0.rawResponsePersisted == false
            }
            && runLockReleased
            && productionCutoverAuthorized == false
            && defaultProductionTradingEnabled == false
    }
}

public enum ReleaseV0330ObservedCanaryRunnerError: Error, Equatable, Sendable {
    case invalidApprovalPacket([ReleaseV0330ApprovalPacketFailure])
    case invalidExecutionAuthorization
    case invalidOrderPlan
    case scopeMismatch
    case invalidEndpoint(String)
    case safetyGateRejected
    case missingCredentialReference
    case missingRollbackEvidence
    case transportNotConfigured
    case invalidTransportObservation(ReleaseV0320CanaryAction)
}

public struct ReleaseV0330ObservedCanaryRunner: Sendable {
    public static let validationAnchor = "TVM-RELEASE-V0330-APPROVAL-BOUND-OBSERVED-CANARY-RUNNER"

    public let lockStore: ReleaseV0323PersistentRunLockStore
    public let transport: any ReleaseV0330ObservedCanaryTransport

    public init(
        lockStore: ReleaseV0323PersistentRunLockStore,
        transport: any ReleaseV0330ObservedCanaryTransport = ReleaseV0330RejectingObservedCanaryTransport()
    ) {
        self.lockStore = lockStore
        self.transport = transport
    }

    public func run(
        _ request: ReleaseV0330ObservedCanaryRunRequest
    ) async throws -> ReleaseV0330ObservedCanaryRunEvidence {
        try validate(request)
        _ = try lockStore.acquire(
            runID: request.runID,
            ownerID: request.ownerID,
            nonce: request.nonce,
            sourceCommit: request.sourceCommit,
            acquiredAtEpochSeconds: Int(request.evaluationEpochSeconds)
        )

        do {
            var observations: [ReleaseV0330ObservedCanaryTransportObservation] = []
            for action in ReleaseV0320CanaryAction.allCases {
                let transportRequest = ReleaseV0330ObservedCanaryTransportRequest(
                    runID: request.runID,
                    sourceCommit: request.sourceCommit,
                    orderPlan: request.orderPlan,
                    action: action,
                    environment: request.environment,
                    baseURL: request.baseURL,
                    credentialReference: request.credentialReference
                )
                let observation = try await transport.perform(transportRequest)
                guard observationHeld(observation, for: transportRequest) else {
                    throw ReleaseV0330ObservedCanaryRunnerError.invalidTransportObservation(action)
                }
                observations.append(observation)
            }

            let released = try lockStore.release(
                runID: request.runID,
                ownerID: request.ownerID,
                nonce: request.nonce,
                releasedAtEpochSeconds: Int(request.evaluationEpochSeconds) + 1
            )
            return ReleaseV0330ObservedCanaryRunEvidence(
                runID: request.runID,
                sourceCommit: request.sourceCommit,
                product: request.orderPlan.product,
                environment: request.environment,
                symbol: request.orderPlan.symbol,
                approvalPacketID: request.approvalPacket.packetID,
                executionAuthorizationRecordID: request.executionAuthorization.recordID,
                observations: observations,
                runLockReleased: released.state == .released,
                productionCutoverAuthorized: false,
                defaultProductionTradingEnabled: false
            )
        } catch {
            _ = try? lockStore.release(
                runID: request.runID,
                ownerID: request.ownerID,
                nonce: request.nonce,
                releasedAtEpochSeconds: Int(request.evaluationEpochSeconds) + 1
            )
            throw error
        }
    }

    private func validate(_ request: ReleaseV0330ObservedCanaryRunRequest) throws {
        let report = ReleaseV0330CanaryApprovalPacketValidator.validate(
            request.approvalPacket,
            expectedSourceCommit: request.sourceCommit,
            nowEpochSeconds: request.evaluationEpochSeconds
        )
        guard report.approvalPacketRecorded else {
            throw ReleaseV0330ObservedCanaryRunnerError.invalidApprovalPacket(report.failures)
        }

        let authorization = request.executionAuthorization
        let plan = request.orderPlan
        let expectedIssue = plan.product == .spot ? 1544 : 1545
        let planSHA256 = try plan.canonicalSHA256()
        guard authorization.evidenceOrigin == .humanRecorded,
              authorization.recordID.isEmpty == false,
              authorization.approvalPacketID == request.approvalPacket.packetID,
              authorization.approverIdentity.isEmpty == false,
              authorization.sourceCommit == request.sourceCommit,
              authorization.product == plan.product,
              authorization.symbol == plan.symbol,
              authorization.issueNumber == expectedIssue,
              authorization.authorizedAtEpochSeconds <= request.evaluationEpochSeconds,
              request.evaluationEpochSeconds < authorization.expiresAtEpochSeconds,
              authorization.oneShot,
              Self.isSHA256(authorization.attestationSHA256),
              authorization.orderPlanSHA256 == planSHA256
        else {
            throw ReleaseV0330ObservedCanaryRunnerError.invalidExecutionAuthorization
        }

        guard plan.planID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              plan.approvalPacketID == request.approvalPacket.packetID,
              plan.sourceCommit == request.sourceCommit,
              plan.issueNumber == expectedIssue,
              plan.side == "BUY" || plan.side == "SELL",
              plan.orderType == "LIMIT",
              plan.timeInForce == "GTC",
              plan.priceQuoteMinorUnits > 0,
              plan.quantityBaseAtomicUnits > 0,
              (1...12).contains(plan.baseAssetScale),
              Self.derivedNotionalMinorUnits(for: plan) == plan.notionalMinorUnits,
              plan.clientOrderID == ReleaseV0330ObservedCanaryOrderPlan.deterministicClientOrderID(
                  planID: plan.planID,
                  sourceCommit: plan.sourceCommit,
                  product: plan.product,
                  symbol: plan.symbol,
                  issueNumber: plan.issueNumber
              )
        else {
            throw ReleaseV0330ObservedCanaryRunnerError.invalidOrderPlan
        }

        guard let scope = request.approvalPacket.productScopes.first(where: { $0.product == plan.product }),
              scope.symbolAllowlist.contains(plan.symbol),
              plan.notionalMinorUnits > 0,
              plan.notionalMinorUnits <= scope.maximumNotionalMinorUnits,
              scope.allowedOrderTypes.map({ $0.uppercased() }).contains("LIMIT"),
              plan.leverageBasisPoints > 0,
              plan.leverageBasisPoints <= scope.maximumLeverageBasisPoints
        else {
            throw ReleaseV0330ObservedCanaryRunnerError.scopeMismatch
        }

        let expectedHost = request.environment.endpointHost(for: plan.product)
        guard request.baseURL.scheme == "https",
              request.baseURL.host == expectedHost,
              request.baseURL.user == nil,
              request.baseURL.password == nil,
              request.baseURL.query == nil,
              request.baseURL.fragment == nil,
              request.baseURL.path.isEmpty || request.baseURL.path == "/"
        else {
            throw ReleaseV0330ObservedCanaryRunnerError.invalidEndpoint(request.baseURL.absoluteString)
        }

        guard request.riskGatePassed, request.killSwitchClear, request.noTradeClear else {
            throw ReleaseV0330ObservedCanaryRunnerError.safetyGateRejected
        }
        guard request.credentialReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV0330ObservedCanaryRunnerError.missingCredentialReference
        }
        guard request.rollbackEvidenceReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV0330ObservedCanaryRunnerError.missingRollbackEvidence
        }
    }

    private func observationHeld(
        _ observation: ReleaseV0330ObservedCanaryTransportObservation,
        for request: ReleaseV0330ObservedCanaryTransportRequest
    ) -> Bool {
        observation.runID == request.runID
            && observation.product == request.product
            && observation.action == request.action
            && observation.environment == request.environment
            && observation.requestID.isEmpty == false
            && observation.redactedOrderReference.isEmpty == false
            && observation.endpointHost == request.baseURL.host
            && Self.isSafeRelativePath(observation.artifact.relativePath)
            && Self.isSHA256(observation.artifact.sha256)
            && observation.rawSecretPersisted == false
            && observation.rawResponsePersisted == false
    }

    private static func isSafeRelativePath(_ path: String) -> Bool {
        path.isEmpty == false
            && path.hasPrefix("/") == false
            && path.hasPrefix("~") == false
            && path.contains("\\") == false
            && path.split(separator: "/", omittingEmptySubsequences: false).allSatisfy {
                $0.isEmpty == false && $0 != "." && $0 != ".."
            }
    }

    private static func isSHA256(_ value: String) -> Bool {
        guard value.hasPrefix("sha256:") else { return false }
        let digest = value.dropFirst("sha256:".count)
        return digest.count == 64 && digest.allSatisfy { $0.isHexDigit && $0.isASCII }
    }

    private static func derivedNotionalMinorUnits(
        for plan: ReleaseV0330ObservedCanaryOrderPlan
    ) -> Int64? {
        guard let divisor = powerOfTen(plan.baseAssetScale) else { return nil }
        let product = plan.priceQuoteMinorUnits.multipliedReportingOverflow(
            by: plan.quantityBaseAtomicUnits
        )
        guard product.overflow == false, product.partialValue % divisor == 0 else { return nil }
        return product.partialValue / divisor
    }

    private static func powerOfTen(_ exponent: Int) -> Int64? {
        guard exponent >= 0 else { return nil }
        var value: Int64 = 1
        for _ in 0..<exponent {
            let result = value.multipliedReportingOverflow(by: 10)
            guard result.overflow == false else { return nil }
            value = result.partialValue
        }
        return value
    }
}
