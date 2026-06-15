import DomainModel
import Foundation

/// ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofError 描述 GH-814 手动 private stream 监控证明失败边界。
///
/// 该错误集合只服务 operator 手动确认的 Binance Spot testnet private stream read-only monitoring
/// 摘要；它不授权 production endpoint、production secret、broker connection、executionReport command
/// path 或订单命令。
public enum ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofError: Error, Equatable, Sendable,
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
            "Release v0.8.0 manual private stream monitoring proof requires explicit operator confirmation"
        case .emptyManualProofReference:
            "Release v0.8.0 manual private stream monitoring proof reference must not be empty"
        case let .invalidSourceArtifact(value):
            "Release v0.8.0 manual private stream monitoring proof source artifact is invalid: \(value)"
        case let .forbiddenCapability(value):
            "Release v0.8.0 manual private stream monitoring proof rejected forbidden capability: \(value)"
        case let .artifactRedactionViolation(value):
            "Release v0.8.0 manual private stream monitoring proof artifact leaked forbidden value: \(value)"
        case let .contractDrift(value):
            "Release v0.8.0 manual private stream monitoring proof contract drift: \(value)"
        }
    }
}

/// ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifact 是 GH-814 的 redacted monitoring proof。
///
/// Artifact 消费 GH-787 network read-only artifact，只保存 endpoint、operator confirmation、
/// redacted credential / listenKey reference、open / observe / close lifecycle 和 account / balance /
/// position read-model 摘要。它不保存 API key、secret、raw listenKey、raw private payload、
/// production endpoint、broker state、executionReport command 或 order request。
public struct ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifact: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let sourceIssueID: Identifier
    public let sourceArtifactID: Identifier
    public let releaseVersion: String
    public let profileName: String
    public let restEndpointHost: String
    public let streamEndpointHost: String
    public let streamEndpointScheme: String
    public let operatorConfirmationID: String
    public let operatorConfirmedManualMonitoringProof: Bool
    public let manualProofReference: String
    public let credentialReference: String
    public let redactedCredentialReference: String
    public let listenKeyReference: String
    public let redactedListenKeyReference: String
    public let redactedStreamURL: String
    public let listenKeyOpened: Bool
    public let privateStreamObserved: Bool
    public let listenKeyClosed: Bool
    public let lifecycleSteps: [String]
    public let accountBalancePositionReadModelObserved: Bool
    public let observedReadModelRecordCount: Int
    public let accountSnapshotRecordCount: Int
    public let balanceUpdateRecordCount: Int
    public let positionUpdateRecordCount: Int
    public let freshnessStatuses: [String]
    public let lastObservedReadModelEventKind: String
    public let manualOperatorMonitoringProof: Bool
    public let deterministicCIProof: Bool
    public let ciRequiresNetwork: Bool
    public let ciRequiresSecrets: Bool
    public let credentialResolvedAtCallTime: Bool
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let testnetReadOnlyMonitoringAllowed: Bool
    public let credentialValuesPersisted: Bool
    public let credentialValuesPrinted: Bool
    public let rawListenKeyPersisted: Bool
    public let rawListenKeyPrinted: Bool
    public let rawPrivatePayloadPersisted: Bool
    public let commandEventsProduced: Bool
    public let executionReportCommandPathEnabled: Bool
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
        issueID.rawValue == "GH-814"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-809", "GH-810", "GH-811", "GH-812", "GH-813"]
            && previousIssueID.rawValue == "GH-813"
            && downstreamIssueID.rawValue == "GH-815"
            && sourceIssueID.rawValue == "GH-787"
            && sourceArtifactID.rawValue.isEmpty == false
            && releaseVersion == "v0.8.0"
            && profileName == ReleaseV070TestnetPrivateStreamReadOnlyProbeConfiguration.requiredProfileName
            && restEndpointHost == "testnet.binance.vision"
            && streamEndpointHost == "stream.testnet.binance.vision"
            && streamEndpointScheme == "wss"
            && operatorConfirmedManualMonitoringProof
            && operatorConfirmationID.isEmpty == false
            && manualProofReference.isEmpty == false
            && credentialReference.isEmpty == false
            && redactedCredentialReference == Self.redactedCredentialReference(credentialReference)
            && listenKeyReference.hasPrefix("listen-key:")
            && redactedListenKeyReference == Self.redactedListenKeyReference(listenKeyReference)
            && redactedStreamURL.contains(listenKeyReference)
            && listenKeyOpened
            && privateStreamObserved
            && listenKeyClosed
            && lifecycleSteps == ReleaseV070TestnetPrivateStreamReadOnlyProbeArtifact.requiredLifecycleSteps
            && accountBalancePositionReadModelObserved
            && observedReadModelRecordCount > 0
            && accountSnapshotRecordCount > 0
            && balanceUpdateRecordCount > 0
            && positionUpdateRecordCount > 0
            && freshnessStatuses == Self.requiredFreshnessStatuses
            && lastObservedReadModelEventKind.isEmpty == false
            && manualOperatorMonitoringProof
            && deterministicCIProof == false
            && ciRequiresNetwork == false
            && ciRequiresSecrets == false
            && credentialResolvedAtCallTime
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && testnetReadOnlyMonitoringAllowed
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        credentialValuesPersisted == false
            && credentialValuesPrinted == false
            && rawListenKeyPersisted == false
            && rawListenKeyPrinted == false
            && rawPrivatePayloadPersisted == false
            && commandEventsProduced == false
            && executionReportCommandPathEnabled == false
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
        artifactID: Identifier = Identifier.constant("gh-814-manual-testnet-private-stream-monitoring-proof"),
        issueID: Identifier = Identifier.constant("GH-814"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-809"),
            Identifier.constant("GH-810"),
            Identifier.constant("GH-811"),
            Identifier.constant("GH-812"),
            Identifier.constant("GH-813")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-813"),
        downstreamIssueID: Identifier = Identifier.constant("GH-815"),
        sourceIssueID: Identifier = Identifier.constant("GH-787"),
        sourceArtifactID: Identifier,
        releaseVersion: String = "v0.8.0",
        profileName: String,
        restEndpointHost: String,
        streamEndpointHost: String,
        streamEndpointScheme: String,
        operatorConfirmationID: String,
        operatorConfirmedManualMonitoringProof: Bool,
        manualProofReference: String,
        credentialReference: String,
        listenKeyReference: String,
        redactedStreamURL: String,
        listenKeyOpened: Bool,
        privateStreamObserved: Bool,
        listenKeyClosed: Bool,
        lifecycleSteps: [String],
        accountBalancePositionReadModelObserved: Bool,
        observedReadModelRecordCount: Int,
        accountSnapshotRecordCount: Int,
        balanceUpdateRecordCount: Int,
        positionUpdateRecordCount: Int,
        freshnessStatuses: [String] = Self.requiredFreshnessStatuses,
        lastObservedReadModelEventKind: String,
        manualOperatorMonitoringProof: Bool = true,
        deterministicCIProof: Bool = false,
        ciRequiresNetwork: Bool = false,
        ciRequiresSecrets: Bool = false,
        credentialResolvedAtCallTime: Bool,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        testnetReadOnlyMonitoringAllowed: Bool = true,
        credentialValuesPersisted: Bool = false,
        credentialValuesPrinted: Bool = false,
        rawListenKeyPersisted: Bool = false,
        rawListenKeyPrinted: Bool = false,
        rawPrivatePayloadPersisted: Bool = false,
        commandEventsProduced: Bool = false,
        executionReportCommandPathEnabled: Bool = false,
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
        guard operatorConfirmedManualMonitoringProof,
              operatorConfirmationID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofError.operatorConfirmationRequired
        }
        guard manualProofReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofError.emptyManualProofReference
        }
        for forbiddenFlag in [
            ("deterministicCIProof", deterministicCIProof),
            ("ciRequiresNetwork", ciRequiresNetwork),
            ("ciRequiresSecrets", ciRequiresSecrets),
            ("credentialValuesPersisted", credentialValuesPersisted),
            ("credentialValuesPrinted", credentialValuesPrinted),
            ("rawListenKeyPersisted", rawListenKeyPersisted),
            ("rawListenKeyPrinted", rawListenKeyPrinted),
            ("rawPrivatePayloadPersisted", rawPrivatePayloadPersisted),
            ("commandEventsProduced", commandEventsProduced),
            ("executionReportCommandPathEnabled", executionReportCommandPathEnabled),
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
            throw ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofError.forbiddenCapability(
                forbiddenFlag.0
            )
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
        self.restEndpointHost = restEndpointHost
        self.streamEndpointHost = streamEndpointHost
        self.streamEndpointScheme = streamEndpointScheme
        self.operatorConfirmationID = operatorConfirmationID
        self.operatorConfirmedManualMonitoringProof = operatorConfirmedManualMonitoringProof
        self.manualProofReference = manualProofReference
        self.credentialReference = credentialReference
        self.redactedCredentialReference = Self.redactedCredentialReference(credentialReference)
        self.listenKeyReference = listenKeyReference
        self.redactedListenKeyReference = Self.redactedListenKeyReference(listenKeyReference)
        self.redactedStreamURL = redactedStreamURL
        self.listenKeyOpened = listenKeyOpened
        self.privateStreamObserved = privateStreamObserved
        self.listenKeyClosed = listenKeyClosed
        self.lifecycleSteps = lifecycleSteps
        self.accountBalancePositionReadModelObserved = accountBalancePositionReadModelObserved
        self.observedReadModelRecordCount = observedReadModelRecordCount
        self.accountSnapshotRecordCount = accountSnapshotRecordCount
        self.balanceUpdateRecordCount = balanceUpdateRecordCount
        self.positionUpdateRecordCount = positionUpdateRecordCount
        self.freshnessStatuses = freshnessStatuses
        self.lastObservedReadModelEventKind = lastObservedReadModelEventKind
        self.manualOperatorMonitoringProof = manualOperatorMonitoringProof
        self.deterministicCIProof = deterministicCIProof
        self.ciRequiresNetwork = ciRequiresNetwork
        self.ciRequiresSecrets = ciRequiresSecrets
        self.credentialResolvedAtCallTime = credentialResolvedAtCallTime
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.testnetReadOnlyMonitoringAllowed = testnetReadOnlyMonitoringAllowed
        self.credentialValuesPersisted = credentialValuesPersisted
        self.credentialValuesPrinted = credentialValuesPrinted
        self.rawListenKeyPersisted = rawListenKeyPersisted
        self.rawListenKeyPrinted = rawListenKeyPrinted
        self.rawPrivatePayloadPersisted = rawPrivatePayloadPersisted
        self.commandEventsProduced = commandEventsProduced
        self.executionReportCommandPathEnabled = executionReportCommandPathEnabled
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
            throw ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofError.contractDrift("artifactHeld")
        }
    }

    public func redactionHeld(forbiddenValues: [String]) throws -> Bool {
        let encoded = try ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifactEncoder.encodedString(self)
        for value in forbiddenValues where value.isEmpty == false && encoded.contains(value) {
            throw ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofError.artifactRedactionViolation(value)
        }
        return true
    }

    public static func redactedCredentialReference(_ reference: String) -> String {
        "\(reference):<redacted>"
    }

    public static func redactedListenKeyReference(_ reference: String) -> String {
        "\(reference):<redacted>"
    }

    public static let requiredFreshnessStatuses = BinancePrivateStreamFreshnessStatus.allCases.map(\.rawValue)

    public static let requiredValidationAnchors = [
        "GH-814-VERIFY-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING",
        "TVM-RELEASE-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING",
        "V080-008-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING",
        "V080-008-LISTENKEY-LIFECYCLE-OPEN-OBSERVE-CLOSE",
        "V080-008-ACCOUNT-BALANCE-POSITION-READMODEL",
        "V080-008-REDACTED-LISTENKEY-CREDENTIAL-REFERENCE",
        "V080-008-EXECUTIONREPORT-COMMAND-PATH-REJECTION",
        "V080-008-NO-TESTNET-ORDER-ROUTING",
        "V080-008-NO-PRODUCTION-CUTOVER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH814ManualBinanceTestnetPrivateStreamMonitoringProofIsRedactedAndNoOrder",
        "bash checks/verify-v0.8.0-manual-testnet-private-stream-monitoring.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifactEncoder 生成稳定 JSON evidence。
public enum ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifactEncoder {
    public static func encodedString(
        _ artifact: ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifact
    ) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return String(decoding: try encoder.encode(artifact), as: UTF8.self)
    }
}

/// ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofWorkflow 将 GH-787 network artifact 压成 GH-814 proof。
///
/// Workflow 不读取环境变量、不打开 CI network、不持久化 credential value 或 raw listenKey。真实 operator
/// 可先运行 GH-787 network read-only probe，再把 redacted artifact 交给本 workflow 生成手动监控证明摘要。
public struct ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofWorkflow: Sendable {
    public init() {}

    public func proofArtifact(
        from sourceArtifact: ReleaseV070TestnetPrivateStreamReadOnlyProbeArtifact,
        manualProofReference: String,
        operatorConfirmationID: String
    ) throws -> ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifact {
        guard sourceArtifact.artifactHeld,
              sourceArtifact.mode == .networkReadOnly,
              sourceArtifact.networkReadOnlyMode,
              sourceArtifact.listenKeyOpened,
              sourceArtifact.privateStreamObserved,
              sourceArtifact.listenKeyClosed,
              sourceArtifact.privateStreamReadModel.boundaryHeld,
              sourceArtifact.noOrderProof.proofHeld,
              sourceArtifact.forbiddenBoundaryHeld else {
            throw ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofError.invalidSourceArtifact(
                sourceArtifact.artifactID.rawValue
            )
        }
        guard sourceArtifact.restEndpointHost == "testnet.binance.vision",
              sourceArtifact.streamEndpointHost == "stream.testnet.binance.vision",
              sourceArtifact.streamEndpointScheme == "wss" else {
            throw ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofError.invalidSourceArtifact(
                "\(sourceArtifact.restEndpointHost)|\(sourceArtifact.streamEndpointScheme)://\(sourceArtifact.streamEndpointHost)"
            )
        }

        let records = sourceArtifact.privateStreamReadModel.records
        let accountSnapshotRecordCount = records.filter { $0.eventKind == .accountSnapshot }.count
        let balanceUpdateRecordCount = records.filter { $0.eventKind == .balanceUpdate }.count
        let positionUpdateRecordCount = records.filter { $0.eventKind == .positionUpdate }.count
        let lastObservedReadModelEventKind = records.last?.eventKind.rawValue ?? ""

        return try ReleaseV080ManualBinanceTestnetPrivateStreamMonitoringProofArtifact(
            sourceArtifactID: sourceArtifact.artifactID,
            profileName: sourceArtifact.profileName,
            restEndpointHost: sourceArtifact.restEndpointHost,
            streamEndpointHost: sourceArtifact.streamEndpointHost,
            streamEndpointScheme: sourceArtifact.streamEndpointScheme,
            operatorConfirmationID: operatorConfirmationID,
            operatorConfirmedManualMonitoringProof: true,
            manualProofReference: manualProofReference,
            credentialReference: sourceArtifact.credentialReference,
            listenKeyReference: sourceArtifact.listenKeyReference,
            redactedStreamURL: sourceArtifact.redactedStreamURL,
            listenKeyOpened: sourceArtifact.listenKeyOpened,
            privateStreamObserved: sourceArtifact.privateStreamObserved,
            listenKeyClosed: sourceArtifact.listenKeyClosed,
            lifecycleSteps: sourceArtifact.lifecycleSteps,
            accountBalancePositionReadModelObserved: accountSnapshotRecordCount > 0
                && balanceUpdateRecordCount > 0
                && positionUpdateRecordCount > 0,
            observedReadModelRecordCount: sourceArtifact.observedReadModelRecordCount,
            accountSnapshotRecordCount: accountSnapshotRecordCount,
            balanceUpdateRecordCount: balanceUpdateRecordCount,
            positionUpdateRecordCount: positionUpdateRecordCount,
            lastObservedReadModelEventKind: lastObservedReadModelEventKind,
            credentialResolvedAtCallTime: sourceArtifact.credentialResolvedAtCallTime
        )
    }
}
