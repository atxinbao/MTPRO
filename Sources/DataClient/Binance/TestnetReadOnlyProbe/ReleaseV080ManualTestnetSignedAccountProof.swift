import DomainModel
import Foundation

/// ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofError 描述 GH-813 手动网络证明的失败边界。
///
/// 该错误集合只服务 operator 手动确认的 Binance Spot testnet signed account read-only
/// 证明摘要；它不授权 production endpoint、production secret、broker connection 或订单命令。
public enum ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofError: Error, Equatable, Sendable,
    CustomStringConvertible
{
    case operatorConfirmationRequired
    case emptyManualProofReference
    case invalidSourceArtifact(String)
    case forbiddenCapability(String)
    case artifactRedactionViolation(String)
    case contractDrift(String)

    public var description: String {
        switch self {
        case .operatorConfirmationRequired:
            "Release v0.8.0 manual signed account proof requires explicit operator confirmation"
        case .emptyManualProofReference:
            "Release v0.8.0 manual signed account proof reference must not be empty"
        case let .invalidSourceArtifact(value):
            "Release v0.8.0 manual signed account proof source artifact is invalid: \(value)"
        case let .forbiddenCapability(value):
            "Release v0.8.0 manual signed account proof rejected forbidden capability: \(value)"
        case let .artifactRedactionViolation(value):
            "Release v0.8.0 manual signed account proof artifact leaked forbidden value: \(value)"
        case let .contractDrift(value):
            "Release v0.8.0 manual signed account proof contract drift: \(value)"
        }
    }
}

/// ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifact 是 GH-813 的 redacted proof 摘要。
///
/// Artifact 消费 GH-786 network read-only artifact，只保存 endpoint、operator confirmation、
/// redacted credential reference 和账户快照摘要。它不保存 API key、secret、raw account payload、
/// production endpoint、broker state、order request 或 production cutover 授权。
public struct ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifact: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let sourceIssueID: Identifier
    public let sourceArtifactID: Identifier
    public let releaseVersion: String
    public let profileName: String
    public let endpointHost: String
    public let endpointPath: String
    public let operatorConfirmationID: String
    public let operatorConfirmedManualNetworkProof: Bool
    public let manualProofReference: String
    public let credentialReference: String
    public let redactedCredentialReference: String
    public let networkAttempted: Bool
    public let signedAccountSnapshotRead: Bool
    public let manualOperatorNetworkProof: Bool
    public let deterministicCIProof: Bool
    public let ciRequiresNetwork: Bool
    public let ciRequiresSecrets: Bool
    public let credentialResolvedAtCallTime: Bool
    public let accountType: String
    public let balanceAssetCount: Int
    public let accountCanTrade: Bool
    public let accountCanWithdraw: Bool
    public let accountCanDeposit: Bool
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let credentialValuesPersisted: Bool
    public let credentialValuesPrinted: Bool
    public let rawAccountPayloadPersisted: Bool
    public let ordersSubmitted: Bool
    public let testnetOrderSubmissionAllowed: Bool
    public let testnetOrderRoutingAllowed: Bool
    public let testnetCancelReplaceAllowed: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretRead: Bool
    public let productionEndpointConnected: Bool
    public let brokerEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var artifactHeld: Bool {
        issueID.rawValue == "GH-813"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-809", "GH-810", "GH-811", "GH-812"]
            && previousIssueID.rawValue == "GH-812"
            && downstreamIssueID.rawValue == "GH-814"
            && sourceIssueID.rawValue == "GH-786"
            && sourceArtifactID.rawValue.isEmpty == false
            && releaseVersion == "v0.8.0"
            && profileName == ReleaseV070TestnetSignedAccountReadOnlyProbeConfiguration.requiredProfileName
            && endpointHost == "testnet.binance.vision"
            && endpointPath == BinanceSignedAccountReadTransportRequest.accountReadOnlyPath
            && operatorConfirmedManualNetworkProof
            && operatorConfirmationID.isEmpty == false
            && manualProofReference.isEmpty == false
            && credentialReference.isEmpty == false
            && redactedCredentialReference == Self.redactedCredentialReference(credentialReference)
            && networkAttempted
            && signedAccountSnapshotRead
            && manualOperatorNetworkProof
            && deterministicCIProof == false
            && ciRequiresNetwork == false
            && ciRequiresSecrets == false
            && credentialResolvedAtCallTime
            && accountType.isEmpty == false
            && balanceAssetCount >= 0
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        credentialValuesPersisted == false
            && credentialValuesPrinted == false
            && rawAccountPayloadPersisted == false
            && ordersSubmitted == false
            && testnetOrderSubmissionAllowed == false
            && testnetOrderRoutingAllowed == false
            && testnetCancelReplaceAllowed == false
            && productionTradingEnabledByDefault == false
            && productionSecretRead == false
            && productionEndpointConnected == false
            && brokerEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        artifactID: Identifier = Identifier.constant("gh-813-manual-testnet-signed-account-network-proof"),
        issueID: Identifier = Identifier.constant("GH-813"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-809"),
            Identifier.constant("GH-810"),
            Identifier.constant("GH-811"),
            Identifier.constant("GH-812")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-812"),
        downstreamIssueID: Identifier = Identifier.constant("GH-814"),
        sourceIssueID: Identifier = Identifier.constant("GH-786"),
        sourceArtifactID: Identifier,
        releaseVersion: String = "v0.8.0",
        profileName: String,
        endpointHost: String,
        endpointPath: String,
        operatorConfirmationID: String,
        operatorConfirmedManualNetworkProof: Bool,
        manualProofReference: String,
        credentialReference: String,
        networkAttempted: Bool,
        signedAccountSnapshotRead: Bool,
        manualOperatorNetworkProof: Bool = true,
        deterministicCIProof: Bool = false,
        ciRequiresNetwork: Bool = false,
        ciRequiresSecrets: Bool = false,
        credentialResolvedAtCallTime: Bool,
        accountType: String,
        balanceAssetCount: Int,
        accountCanTrade: Bool,
        accountCanWithdraw: Bool,
        accountCanDeposit: Bool,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        credentialValuesPersisted: Bool = false,
        credentialValuesPrinted: Bool = false,
        rawAccountPayloadPersisted: Bool = false,
        ordersSubmitted: Bool = false,
        testnetOrderSubmissionAllowed: Bool = false,
        testnetOrderRoutingAllowed: Bool = false,
        testnetCancelReplaceAllowed: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretRead: Bool = false,
        productionEndpointConnected: Bool = false,
        brokerEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard operatorConfirmedManualNetworkProof, operatorConfirmationID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofError.operatorConfirmationRequired
        }
        guard manualProofReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofError.emptyManualProofReference
        }
        for forbiddenFlag in [
            ("deterministicCIProof", deterministicCIProof),
            ("ciRequiresNetwork", ciRequiresNetwork),
            ("ciRequiresSecrets", ciRequiresSecrets),
            ("credentialValuesPersisted", credentialValuesPersisted),
            ("credentialValuesPrinted", credentialValuesPrinted),
            ("rawAccountPayloadPersisted", rawAccountPayloadPersisted),
            ("ordersSubmitted", ordersSubmitted),
            ("testnetOrderSubmissionAllowed", testnetOrderSubmissionAllowed),
            ("testnetOrderRoutingAllowed", testnetOrderRoutingAllowed),
            ("testnetCancelReplaceAllowed", testnetCancelReplaceAllowed),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionSecretRead", productionSecretRead),
            ("productionEndpointConnected", productionEndpointConnected),
            ("brokerEndpointConnected", brokerEndpointConnected),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized)
        ] where forbiddenFlag.1 {
            throw ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofError.forbiddenCapability(forbiddenFlag.0)
        }

        self.artifactID = artifactID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.sourceIssueID = sourceIssueID
        self.sourceArtifactID = sourceArtifactID
        self.releaseVersion = releaseVersion
        self.profileName = profileName
        self.endpointHost = endpointHost
        self.endpointPath = endpointPath
        self.operatorConfirmationID = operatorConfirmationID
        self.operatorConfirmedManualNetworkProof = operatorConfirmedManualNetworkProof
        self.manualProofReference = manualProofReference
        self.credentialReference = credentialReference
        self.redactedCredentialReference = Self.redactedCredentialReference(credentialReference)
        self.networkAttempted = networkAttempted
        self.signedAccountSnapshotRead = signedAccountSnapshotRead
        self.manualOperatorNetworkProof = manualOperatorNetworkProof
        self.deterministicCIProof = deterministicCIProof
        self.ciRequiresNetwork = ciRequiresNetwork
        self.ciRequiresSecrets = ciRequiresSecrets
        self.credentialResolvedAtCallTime = credentialResolvedAtCallTime
        self.accountType = accountType
        self.balanceAssetCount = balanceAssetCount
        self.accountCanTrade = accountCanTrade
        self.accountCanWithdraw = accountCanWithdraw
        self.accountCanDeposit = accountCanDeposit
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.credentialValuesPersisted = credentialValuesPersisted
        self.credentialValuesPrinted = credentialValuesPrinted
        self.rawAccountPayloadPersisted = rawAccountPayloadPersisted
        self.ordersSubmitted = ordersSubmitted
        self.testnetOrderSubmissionAllowed = testnetOrderSubmissionAllowed
        self.testnetOrderRoutingAllowed = testnetOrderRoutingAllowed
        self.testnetCancelReplaceAllowed = testnetCancelReplaceAllowed
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretRead = productionSecretRead
        self.productionEndpointConnected = productionEndpointConnected
        self.brokerEndpointConnected = brokerEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard artifactHeld else {
            throw ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofError.contractDrift("artifactHeld")
        }
    }

    public func redactionHeld(forbiddenValues: [String]) throws -> Bool {
        let encoded = try ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifactEncoder.encodedString(self)
        for value in forbiddenValues where value.isEmpty == false && encoded.contains(value) {
            throw ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofError.artifactRedactionViolation(value)
        }
        return true
    }

    public static func redactedCredentialReference(_ reference: String) -> String {
        "\(reference):<redacted>"
    }

    public static let requiredValidationAnchors = [
        "GH-813-VERIFY-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF",
        "TVM-RELEASE-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF",
        "V080-007-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF",
        "V080-007-NETWORK-ATTEMPTED-AND-SNAPSHOT-READ",
        "V080-007-REDACTED-CREDENTIAL-REFERENCE",
        "V080-007-CI-DETERMINISTIC-NO-NETWORK-SECRET",
        "V080-007-NO-TESTNET-ORDER-ROUTING",
        "V080-007-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH813ManualBinanceTestnetSignedAccountNetworkProofIsRedactedAndNoOrder",
        "bash checks/verify-v0.8.0-manual-testnet-signed-account-proof.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifactEncoder 生成稳定 JSON evidence。
public enum ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifactEncoder {
    public static func encodedString(
        _ artifact: ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifact
    ) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return String(decoding: try encoder.encode(artifact), as: UTF8.self)
    }
}

/// ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofWorkflow 将 GH-786 network artifact 压成 GH-813 proof。
///
/// Workflow 不读取环境变量、不打开 CI network、不持久化 credential value。真实 operator 可先运行
/// GH-786 network read-only probe，再把 redacted artifact 交给本 workflow 生成手动证明摘要。
public struct ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofWorkflow: Sendable {
    public init() {}

    public func proofArtifact(
        from sourceArtifact: ReleaseV070TestnetSignedAccountReadOnlyProbeArtifact,
        manualProofReference: String,
        operatorConfirmationID: String
    ) throws -> ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifact {
        guard sourceArtifact.artifactHeld,
              sourceArtifact.mode == .networkReadOnly,
              sourceArtifact.networkReadOnlyMode,
              sourceArtifact.signedAccountSnapshot.snapshotBoundaryHeld,
              sourceArtifact.noOrderProof.proofHeld,
              sourceArtifact.forbiddenBoundaryHeld else {
            throw ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofError.invalidSourceArtifact(
                sourceArtifact.artifactID.rawValue
            )
        }
        guard sourceArtifact.endpointHost == "testnet.binance.vision",
              sourceArtifact.endpointPath == BinanceSignedAccountReadTransportRequest.accountReadOnlyPath else {
            throw ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofError.invalidSourceArtifact(
                "\(sourceArtifact.endpointHost)\(sourceArtifact.endpointPath)"
            )
        }

        return try ReleaseV080ManualBinanceTestnetSignedAccountNetworkProofArtifact(
            sourceArtifactID: sourceArtifact.artifactID,
            profileName: sourceArtifact.profileName,
            endpointHost: sourceArtifact.endpointHost,
            endpointPath: sourceArtifact.endpointPath,
            operatorConfirmationID: operatorConfirmationID,
            operatorConfirmedManualNetworkProof: true,
            manualProofReference: manualProofReference,
            credentialReference: sourceArtifact.credentialReference,
            networkAttempted: true,
            signedAccountSnapshotRead: true,
            credentialResolvedAtCallTime: sourceArtifact.credentialResolvedAtCallTime,
            accountType: sourceArtifact.signedAccountSnapshot.accountType,
            balanceAssetCount: sourceArtifact.signedAccountSnapshot.balances.count,
            accountCanTrade: sourceArtifact.signedAccountSnapshot.canTrade,
            accountCanWithdraw: sourceArtifact.signedAccountSnapshot.canWithdraw,
            accountCanDeposit: sourceArtifact.signedAccountSnapshot.canDeposit
        )
    }
}
