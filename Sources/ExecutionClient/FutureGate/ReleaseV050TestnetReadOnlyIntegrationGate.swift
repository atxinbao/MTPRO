import DomainModel
import Foundation

/// ReleaseV050TestnetReadOnlyRouteKind 固定 GH-733 可进入 testnet read-only gate 的来源类型。
///
/// 这些 route 只表达 signed account snapshot 和 private stream account snapshot 的 read-model 证据；
/// 它们不创建 order command、broker gateway、OMS lifecycle 或 production cutover。
public enum ReleaseV050TestnetReadOnlyRouteKind: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case signedAccountReadOnly = "signed account read-only"
    case privateStreamAccountSnapshot = "private stream account snapshot read-model"
}

/// ReleaseV050TestnetReadOnlyReadModelRoute 描述 GH-733 的 read-only evidence 输入。
///
/// Route 记录 DataClient 已拥有的 read-model source identity 和 endpoint reference，但不保存 secret、
/// raw payload、socket task、request object 或 command-capable runtime。
public struct ReleaseV050TestnetReadOnlyReadModelRoute: Codable, Equatable, Sendable {
    public let routeID: Identifier
    public let kind: ReleaseV050TestnetReadOnlyRouteKind
    public let sourceIdentity: String
    public let endpointReference: String
    public let sourcePath: String
    public let productType: String
    public let readModelOnly: Bool
    public let rawPayloadExposed: Bool
    public let secretMaterialExposed: Bool
    public let commandSurfaceEnabled: Bool

    public var routeBoundaryHeld: Bool {
        sourceIdentity.isEmpty == false
            && endpointReference.isEmpty == false
            && sourcePath == Self.expectedSourcePath(for: kind)
            && productType == "spot"
            && readModelOnly
            && rawPayloadExposed == false
            && secretMaterialExposed == false
            && commandSurfaceEnabled == false
    }

    public init(
        routeID: Identifier,
        kind: ReleaseV050TestnetReadOnlyRouteKind,
        sourceIdentity: String,
        endpointReference: String,
        sourcePath: String,
        productType: String = "spot",
        readModelOnly: Bool = true,
        rawPayloadExposed: Bool = false,
        secretMaterialExposed: Bool = false,
        commandSurfaceEnabled: Bool = false
    ) throws {
        guard sourceIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIdentity",
                expected: "non-empty read-model source identity",
                actual: "empty"
            )
        }
        guard endpointReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "endpointReference",
                expected: "explicit testnet endpoint reference",
                actual: "empty"
            )
        }
        guard sourcePath == Self.expectedSourcePath(for: kind) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourcePath",
                expected: Self.expectedSourcePath(for: kind),
                actual: sourcePath
            )
        }
        guard productType == "spot" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "productType",
                expected: "spot",
                actual: productType
            )
        }
        guard readModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("readModelOnly=false")
        }
        for forbiddenFlag in [
            ("rawPayloadExposed", rawPayloadExposed),
            ("secretMaterialExposed", secretMaterialExposed),
            ("commandSurfaceEnabled", commandSurfaceEnabled)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.routeID = routeID
        self.kind = kind
        self.sourceIdentity = sourceIdentity
        self.endpointReference = endpointReference
        self.sourcePath = sourcePath
        self.productType = productType
        self.readModelOnly = readModelOnly
        self.rawPayloadExposed = rawPayloadExposed
        self.secretMaterialExposed = secretMaterialExposed
        self.commandSurfaceEnabled = commandSurfaceEnabled
    }

    public static func deterministicRoutes(endpointReference: String) throws -> [ReleaseV050TestnetReadOnlyReadModelRoute] {
        try [
            ReleaseV050TestnetReadOnlyReadModelRoute(
                routeID: Identifier.constant("gh-733-signed-account-read-only-route"),
                kind: .signedAccountReadOnly,
                sourceIdentity: "DataClient.BinanceSignedAccountReadSnapshot",
                endpointReference: endpointReference,
                sourcePath: expectedSourcePath(for: .signedAccountReadOnly)
            ),
            ReleaseV050TestnetReadOnlyReadModelRoute(
                routeID: Identifier.constant("gh-733-private-stream-account-snapshot-route"),
                kind: .privateStreamAccountSnapshot,
                sourceIdentity: "DataClient.BinancePrivateStreamAccountSnapshotReadModel",
                endpointReference: endpointReference,
                sourcePath: expectedSourcePath(for: .privateStreamAccountSnapshot)
            )
        ]
    }

    public static func expectedSourcePath(for kind: ReleaseV050TestnetReadOnlyRouteKind) -> String {
        switch kind {
        case .signedAccountReadOnly:
            "/api/v3/account"
        case .privateStreamAccountSnapshot:
            "/api/v3/userDataStream"
        }
    }
}

/// ReleaseV050TestnetReadOnlyRouteResolution 记录单个 read-only route 的 policy 解析结果。
///
/// Resolution 只复用 GH-728 endpoint policy evidence；`networkConnectionOpened` 必须保持 false。
public struct ReleaseV050TestnetReadOnlyRouteResolution: Codable, Equatable, Sendable {
    public let route: ReleaseV050TestnetReadOnlyReadModelRoute
    public let endpointEvidence: ReleaseV050EndpointResolutionEvidence
    public let redactedSecretProfileReference: String
    public let credentialReferenceOnly: Bool

    public var resolutionHeld: Bool {
        route.routeBoundaryHeld
            && endpointEvidence.boundaryHeld
            && endpointEvidence.decision == .testnetEndpointAllowed
            && endpointEvidence.productType == route.productType
            && endpointEvidence.networkConnectionOpened == false
            && redactedSecretProfileReference.hasSuffix(":<redacted>")
            && credentialReferenceOnly
    }
}

/// ReleaseV050TestnetReadOnlyNoSubmitProof 固定 GH-733 的 no-submit / no-order proof。
///
/// 该 proof 是后续 RiskEngine / ExecutionEngine 前的阻断证据，不是订单生命周期输入。
public struct ReleaseV050TestnetReadOnlyNoSubmitProof: Codable, Equatable, Sendable {
    public let proofID: Identifier
    public let orderLifecycleCreated: Bool
    public let submitCommandEnabled: Bool
    public let cancelCommandEnabled: Bool
    public let replaceCommandEnabled: Bool
    public let brokerGatewayConnected: Bool
    public let omsStateCreated: Bool
    public let productionTradingEnabledByDefault: Bool

    public var proofHeld: Bool {
        orderLifecycleCreated == false
            && submitCommandEnabled == false
            && cancelCommandEnabled == false
            && replaceCommandEnabled == false
            && brokerGatewayConnected == false
            && omsStateCreated == false
            && productionTradingEnabledByDefault == false
    }

    public init(
        proofID: Identifier = Identifier.constant("gh-733-no-submit-proof"),
        orderLifecycleCreated: Bool = false,
        submitCommandEnabled: Bool = false,
        cancelCommandEnabled: Bool = false,
        replaceCommandEnabled: Bool = false,
        brokerGatewayConnected: Bool = false,
        omsStateCreated: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        for forbiddenFlag in [
            ("orderLifecycleCreated", orderLifecycleCreated),
            ("submitCommandEnabled", submitCommandEnabled),
            ("cancelCommandEnabled", cancelCommandEnabled),
            ("replaceCommandEnabled", replaceCommandEnabled),
            ("brokerGatewayConnected", brokerGatewayConnected),
            ("omsStateCreated", omsStateCreated),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.proofID = proofID
        self.orderLifecycleCreated = orderLifecycleCreated
        self.submitCommandEnabled = submitCommandEnabled
        self.cancelCommandEnabled = cancelCommandEnabled
        self.replaceCommandEnabled = replaceCommandEnabled
        self.brokerGatewayConnected = brokerGatewayConnected
        self.omsStateCreated = omsStateCreated
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }
}

/// ReleaseV050TestnetReadOnlyIntegrationEvidence 是 GH-733 的最终 read-only gate evidence。
///
/// Evidence 必须来自显式 testnet-guarded profile，并证明 production / command / order path 都关闭。
public struct ReleaseV050TestnetReadOnlyIntegrationEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let environmentProfile: ReleaseV050EnvironmentProfile
    public let routeResolutions: [ReleaseV050TestnetReadOnlyRouteResolution]
    public let noSubmitProof: ReleaseV050TestnetReadOnlyNoSubmitProof
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionEndpointRejected: Bool
    public let productionSecretRejected: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-733"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-728", "GH-732"]
            && previousIssueID.rawValue == "GH-732"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-738", "GH-739"]
            && environmentProfile.mode == .testnetGuarded
            && environmentProfile.profileHeld
            && Set(routeResolutions.map { $0.route.kind }) == Set(ReleaseV050TestnetReadOnlyRouteKind.allCases)
            && routeResolutions.allSatisfy(\.resolutionHeld)
            && noSubmitProof.proofHeld
            && validationAnchors == ReleaseV050TestnetReadOnlyIntegrationGateContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV050TestnetReadOnlyIntegrationGateContract.requiredValidationCommands
            && productionEndpointRejected
            && productionSecretRejected
            && productionCutoverAuthorized == false
    }
}

/// ReleaseV050TestnetReadOnlyIntegrationGate 是 GH-733 的显式 testnet read-only gate。
///
/// Gate 只解析 GH-728 ReleaseV050EnvironmentProfile / ReleaseV050EndpointPolicy /
/// ReleaseV050SecretProfileRef，并把 GH-525/GH-526
/// DataClient read-model identity 组合成 redacted evidence；默认关闭，不连接网络、不读 secret、不创建订单。
public struct ReleaseV050TestnetReadOnlyIntegrationGate: Sendable {
    public let explicitTestnetProfileAccepted: Bool

    public init(explicitTestnetProfileAccepted: Bool = false) {
        self.explicitTestnetProfileAccepted = explicitTestnetProfileAccepted
    }

    public func resolve(
        profile: ReleaseV050EnvironmentProfile,
        routes: [ReleaseV050TestnetReadOnlyReadModelRoute]
    ) throws -> ReleaseV050TestnetReadOnlyIntegrationEvidence {
        guard explicitTestnetProfileAccepted else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "explicitTestnetProfileAccepted",
                expected: "true",
                actual: "false"
            )
        }
        guard profile.mode == .testnetGuarded else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("testnetReadOnlyRequiresTestnetGuardedProfile")
        }
        guard profile.profileHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "environmentProfile.profileHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard profile.secretProfileRef.kind == .testnetReferenceOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("nonTestnetSecretProfileRef")
        }
        guard Set(routes.map(\.kind)) == Set(ReleaseV050TestnetReadOnlyRouteKind.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "routes",
                expected: "signed account read-only,private stream account snapshot read-model",
                actual: routes.map { $0.kind.rawValue }.joined(separator: ",")
            )
        }

        let resolutions = try routes.map { route in
            let endpointEvidence = try profile.endpointPolicy.resolve(
                endpointReference: route.endpointReference,
                productType: route.productType
            )
            return ReleaseV050TestnetReadOnlyRouteResolution(
                route: route,
                endpointEvidence: endpointEvidence,
                redactedSecretProfileReference: "\(profile.secretProfileRef.profileReference):<redacted>",
                credentialReferenceOnly: profile.secretProfileRef.referenceOnlyHeld
            )
        }

        return ReleaseV050TestnetReadOnlyIntegrationEvidence(
            evidenceID: Identifier.constant("gh-733-testnet-read-only-integration-evidence"),
            issueID: Identifier.constant("GH-733"),
            upstreamIssueIDs: [
                Identifier.constant("GH-728"),
                Identifier.constant("GH-732")
            ],
            previousIssueID: Identifier.constant("GH-732"),
            downstreamIssueIDs: [
                Identifier.constant("GH-738"),
                Identifier.constant("GH-739")
            ],
            environmentProfile: profile,
            routeResolutions: resolutions,
            noSubmitProof: try ReleaseV050TestnetReadOnlyNoSubmitProof(),
            validationAnchors: ReleaseV050TestnetReadOnlyIntegrationGateContract.requiredValidationAnchors,
            requiredValidationCommands: ReleaseV050TestnetReadOnlyIntegrationGateContract.requiredValidationCommands,
            productionEndpointRejected: true,
            productionSecretRejected: true,
            productionCutoverAuthorized: false
        )
    }

    public static func deterministicEvidence() throws -> ReleaseV050TestnetReadOnlyIntegrationEvidence {
        let profile = try ReleaseV050EnvironmentProfile.fixture(for: .testnetGuarded)
        let routes = try ReleaseV050TestnetReadOnlyReadModelRoute.deterministicRoutes(
            endpointReference: "https://testnet.binance.vision"
        )
        return try ReleaseV050TestnetReadOnlyIntegrationGate(
            explicitTestnetProfileAccepted: true
        ).resolve(profile: profile, routes: routes)
    }
}

/// ReleaseV050TestnetReadOnlyIntegrationGateContract 固定 GH-733 issue-level 验收合同。
///
/// Contract 证明 #733 只把 read-only testnet evidence 接入 guard，不授权 production 或 order path。
public struct ReleaseV050TestnetReadOnlyIntegrationGateContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let defaultFailClosed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretResolutionEnabled: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let orderLifecycleEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-733"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-728", "GH-732"]
            && previousIssueID.rawValue == "GH-732"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-738", "GH-739"]
            && canonicalQueueRange == "GH-726..GH-739"
            && projectName == ReleaseV050ReleaseBoundaryPreflightContract.requiredProjectName
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && defaultFailClosed
            && productionDefaultsClosed
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionSecretResolutionEnabled == false
            && productionEndpointConnectionEnabled == false
            && orderLifecycleEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-733-release-v0.5.0-testnet-read-only-integration-gate"),
        issueID: Identifier = Identifier.constant("GH-733"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-728"),
            Identifier.constant("GH-732")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-732"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-738"),
            Identifier.constant("GH-739")
        ],
        canonicalQueueRange: String = "GH-726..GH-739",
        projectName: String = ReleaseV050ReleaseBoundaryPreflightContract.requiredProjectName,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        defaultFailClosed: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretResolutionEnabled: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        orderLifecycleEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-728", "GH-732"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-728,GH-732",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard defaultFailClosed else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "defaultFailClosed",
                expected: "true",
                actual: "false"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        guard requiredValidationCommands == Self.requiredValidationCommands else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "requiredValidationCommands",
                expected: Self.requiredValidationCommands.joined(separator: ","),
                actual: requiredValidationCommands.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretResolutionEnabled", productionSecretResolutionEnabled),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("orderLifecycleEnabled", orderLifecycleEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability(forbiddenFlag.0)
        }

        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.defaultFailClosed = defaultFailClosed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretResolutionEnabled = productionSecretResolutionEnabled
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.orderLifecycleEnabled = orderLifecycleEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
    }

    public static func deterministicFixture() throws -> ReleaseV050TestnetReadOnlyIntegrationGateContract {
        try ReleaseV050TestnetReadOnlyIntegrationGateContract()
    }

    public static let requiredValidationAnchors = [
        "V050-08-TESTNET-READ-ONLY-INTEGRATION-GATE",
        "V050-08-EXPLICIT-TESTNET-PROFILE-REQUIRED",
        "V050-08-PRODUCTION-BLOCKED-REJECTS-READMODEL-RESOLUTION",
        "V050-08-REDACTED-EVIDENCE-NO-SUBMIT-PROOF",
        "TVM-RELEASE-V050-TESTNET-READONLY-INTEGRATION-GATE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH733TestnetReadOnlyIntegrationGateRequiresExplicitProfileAndNoSubmitProof",
        "bash checks/verify-v0.5.0-testnet-readonly.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
