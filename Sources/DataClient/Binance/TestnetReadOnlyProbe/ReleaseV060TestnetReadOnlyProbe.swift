import DomainModel
import Foundation

/// ReleaseV060TestnetReadOnlyProbeError 描述 GH-765 testnet read-only probe 的失败原因。
///
/// 错误只覆盖显式 operator confirmation、testnet endpoint allowlist、credential reference、
/// snapshot artifact redaction 和 no-order boundary；它不代表 production cutover 或交易命令能力。
public enum ReleaseV060TestnetReadOnlyProbeError: Error, Equatable, Sendable, CustomStringConvertible {
    case operatorConfirmationRequired
    case invalidTestnetProfile(String)
    case emptyCredentialReference
    case credentialReferenceMismatch(expected: String, actual: String)
    case invalidEndpoint(String)
    case productionEndpointForbidden(String)
    case unsupportedEndpointHost(String)
    case forbiddenCapability(String)
    case artifactRedactionViolation(String)
    case contractDrift(String)

    public var description: String {
        switch self {
        case .operatorConfirmationRequired:
            "Release v0.6.0 testnet read-only probe requires explicit operator confirmation"
        case let .invalidTestnetProfile(value):
            "Release v0.6.0 testnet read-only probe requires binance-testnet-readonly profile: \(value)"
        case .emptyCredentialReference:
            "Release v0.6.0 testnet read-only probe credential reference must not be empty"
        case let .credentialReferenceMismatch(expected, actual):
            "Release v0.6.0 testnet read-only probe credential reference mismatch: expected \(expected), actual \(actual)"
        case let .invalidEndpoint(value):
            "Release v0.6.0 testnet read-only probe endpoint is invalid: \(value)"
        case let .productionEndpointForbidden(host):
            "Release v0.6.0 testnet read-only probe rejects production endpoint host: \(host)"
        case let .unsupportedEndpointHost(host):
            "Release v0.6.0 testnet read-only probe supports testnet hosts only: \(host)"
        case let .forbiddenCapability(value):
            "Release v0.6.0 testnet read-only probe rejected forbidden capability: \(value)"
        case let .artifactRedactionViolation(value):
            "Release v0.6.0 testnet read-only probe artifact leaked credential value: \(value)"
        case let .contractDrift(value):
            "Release v0.6.0 testnet read-only probe contract drift: \(value)"
        }
    }
}

/// ReleaseV060TestnetReadOnlyProbeConfiguration 固定 GH-765 的显式 testnet 探针输入。
///
/// 配置只允许 Binance testnet endpoint、approved credential reference 和 operator confirmation。
/// Credential value 通过调用方注入的 provider 短生命周期进入内存，不进入该配置或 artifact。
public struct ReleaseV060TestnetReadOnlyProbeConfiguration: Equatable, Sendable {
    public let profileName: String
    public let endpointReference: URL
    public let approvedCredentialReference: String
    public let operatorConfirmationID: String
    public let operatorConfirmedReadOnlyProbe: Bool
    public let privateStreamSnapshotSimulated: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnectionEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let submitCommandEnabled: Bool
    public let cancelCommandEnabled: Bool
    public let replaceCommandEnabled: Bool

    public var configurationHeld: Bool {
        profileName == Self.requiredProfileName
            && operatorConfirmedReadOnlyProbe
            && operatorConfirmationID.isEmpty == false
            && approvedCredentialReference.isEmpty == false
            && Self.allowedTestnetHosts.contains(endpointReference.host?.lowercased() ?? "")
            && endpointReference.scheme?.lowercased() == "https"
            && privateStreamSnapshotSimulated
            && productionTradingEnabledByDefault == false
            && productionEndpointConnectionEnabled == false
            && productionSecretAutoReadEnabled == false
            && submitCommandEnabled == false
            && cancelCommandEnabled == false
            && replaceCommandEnabled == false
    }

    public init(
        profileName: String = Self.requiredProfileName,
        endpointReference: URL,
        approvedCredentialReference: String,
        operatorConfirmationID: String,
        operatorConfirmedReadOnlyProbe: Bool,
        privateStreamSnapshotSimulated: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnectionEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        submitCommandEnabled: Bool = false,
        cancelCommandEnabled: Bool = false,
        replaceCommandEnabled: Bool = false
    ) throws {
        guard operatorConfirmedReadOnlyProbe else {
            throw ReleaseV060TestnetReadOnlyProbeError.operatorConfirmationRequired
        }
        guard profileName == Self.requiredProfileName else {
            throw ReleaseV060TestnetReadOnlyProbeError.invalidTestnetProfile(profileName)
        }
        guard approvedCredentialReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV060TestnetReadOnlyProbeError.emptyCredentialReference
        }
        guard operatorConfirmationID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ReleaseV060TestnetReadOnlyProbeError.operatorConfirmationRequired
        }
        try Self.validateEndpoint(endpointReference)
        guard privateStreamSnapshotSimulated else {
            throw ReleaseV060TestnetReadOnlyProbeError.forbiddenCapability("privateStreamSnapshotSimulated=false")
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointConnectionEnabled", productionEndpointConnectionEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("submitCommandEnabled", submitCommandEnabled),
            ("cancelCommandEnabled", cancelCommandEnabled),
            ("replaceCommandEnabled", replaceCommandEnabled)
        ] where forbiddenFlag.1 {
            throw ReleaseV060TestnetReadOnlyProbeError.forbiddenCapability(forbiddenFlag.0)
        }

        self.profileName = profileName
        self.endpointReference = endpointReference
        self.approvedCredentialReference = approvedCredentialReference
        self.operatorConfirmationID = operatorConfirmationID
        self.operatorConfirmedReadOnlyProbe = operatorConfirmedReadOnlyProbe
        self.privateStreamSnapshotSimulated = privateStreamSnapshotSimulated
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnectionEnabled = productionEndpointConnectionEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.submitCommandEnabled = submitCommandEnabled
        self.cancelCommandEnabled = cancelCommandEnabled
        self.replaceCommandEnabled = replaceCommandEnabled

        guard configurationHeld else {
            throw ReleaseV060TestnetReadOnlyProbeError.contractDrift("configurationHeld")
        }
    }

    public static func deterministicFixture(
        credentialReference: String = "gh-765-approved-testnet-reference"
    ) throws -> ReleaseV060TestnetReadOnlyProbeConfiguration {
        try ReleaseV060TestnetReadOnlyProbeConfiguration(
            endpointReference: defaultSpotTestnetEndpoint,
            approvedCredentialReference: credentialReference,
            operatorConfirmationID: "operator-confirmed-gh-765-read-only-probe",
            operatorConfirmedReadOnlyProbe: true
        )
    }

    public static func validateEndpoint(_ endpointReference: URL) throws {
        guard endpointReference.scheme?.lowercased() == "https" else {
            throw ReleaseV060TestnetReadOnlyProbeError.invalidEndpoint(endpointReference.absoluteString)
        }
        let host = endpointReference.host?.lowercased() ?? ""
        guard productionHosts.contains(host) == false else {
            throw ReleaseV060TestnetReadOnlyProbeError.productionEndpointForbidden(host)
        }
        guard allowedTestnetHosts.contains(host) else {
            throw ReleaseV060TestnetReadOnlyProbeError.unsupportedEndpointHost(host)
        }
    }

    public static let requiredProfileName = "binance-testnet-readonly"
    public static let allowedTestnetHosts = [
        "testnet.binance.vision",
        "testnet.binancefuture.com"
    ]
    public static let productionHosts = [
        "api.binance.com",
        "fapi.binance.com",
        "dapi.binance.com"
    ]
    public static var defaultSpotTestnetEndpoint: URL {
        constantURL("https://testnet.binance.vision")
    }

    public static var defaultPrivateStreamTestnetEndpoint: URL {
        constantURL("wss://stream.testnet.binance.vision")
    }

    private static func constantURL(_ value: String) -> URL {
        guard let url = URL(string: value) else {
            preconditionFailure("GH-765 constant URL must be valid: \(value)")
        }
        return url
    }
}

/// ReleaseV060TestnetReadOnlyProbeDashboardRow 是 Dashboard 可消费的 redacted read-model 行。
///
/// Row 只暴露红acted credential reference、endpoint host、read-only/no-order 边界和 artifact status。
public struct ReleaseV060TestnetReadOnlyProbeDashboardRow: Codable, Equatable, Sendable {
    public let label: String
    public let value: String
    public let readModelOnly: Bool
    public let redacted: Bool
    public let commandSurfaceEnabled: Bool
    public let tradingButtonVisible: Bool
    public let orderFormVisible: Bool

    public var rowHeld: Bool {
        label.isEmpty == false
            && value.isEmpty == false
            && readModelOnly
            && redacted
            && commandSurfaceEnabled == false
            && tradingButtonVisible == false
            && orderFormVisible == false
    }

    public init(
        label: String,
        value: String,
        readModelOnly: Bool = true,
        redacted: Bool = true,
        commandSurfaceEnabled: Bool = false,
        tradingButtonVisible: Bool = false,
        orderFormVisible: Bool = false
    ) throws {
        self.label = label
        self.value = value
        self.readModelOnly = readModelOnly
        self.redacted = redacted
        self.commandSurfaceEnabled = commandSurfaceEnabled
        self.tradingButtonVisible = tradingButtonVisible
        self.orderFormVisible = orderFormVisible

        guard rowHeld else {
            throw ReleaseV060TestnetReadOnlyProbeError.contractDrift("dashboardRow.\(label)")
        }
    }
}

/// ReleaseV060TestnetReadOnlyProbeNoOrderProof 固定 GH-765 的 no-order proof。
public struct ReleaseV060TestnetReadOnlyProbeNoOrderProof: Codable, Equatable, Sendable {
    public let submitCommandEnabled: Bool
    public let cancelCommandEnabled: Bool
    public let replaceCommandEnabled: Bool
    public let brokerExecutionEnabled: Bool
    public let omsLifecycleCreated: Bool
    public let productionTradingEnabledByDefault: Bool

    public var proofHeld: Bool {
        submitCommandEnabled == false
            && cancelCommandEnabled == false
            && replaceCommandEnabled == false
            && brokerExecutionEnabled == false
            && omsLifecycleCreated == false
            && productionTradingEnabledByDefault == false
    }

    public init(
        submitCommandEnabled: Bool = false,
        cancelCommandEnabled: Bool = false,
        replaceCommandEnabled: Bool = false,
        brokerExecutionEnabled: Bool = false,
        omsLifecycleCreated: Bool = false,
        productionTradingEnabledByDefault: Bool = false
    ) throws {
        for forbiddenFlag in [
            ("submitCommandEnabled", submitCommandEnabled),
            ("cancelCommandEnabled", cancelCommandEnabled),
            ("replaceCommandEnabled", replaceCommandEnabled),
            ("brokerExecutionEnabled", brokerExecutionEnabled),
            ("omsLifecycleCreated", omsLifecycleCreated),
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault)
        ] where forbiddenFlag.1 {
            throw ReleaseV060TestnetReadOnlyProbeError.forbiddenCapability(forbiddenFlag.0)
        }

        self.submitCommandEnabled = submitCommandEnabled
        self.cancelCommandEnabled = cancelCommandEnabled
        self.replaceCommandEnabled = replaceCommandEnabled
        self.brokerExecutionEnabled = brokerExecutionEnabled
        self.omsLifecycleCreated = omsLifecycleCreated
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
    }
}

/// ReleaseV060TestnetReadOnlyProbeArtifact 是 GH-765 的本地 read-only snapshot artifact。
///
/// Artifact 可以包含 signed account snapshot 和 simulated private stream account read model，但只保存
/// reference identity 与 redacted 展示字段，不保存 API key、secret、raw payload、listenKey value 或 command state。
public struct ReleaseV060TestnetReadOnlyProbeArtifact: Codable, Equatable, Sendable {
    public let artifactID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let profileName: String
    public let endpointHost: String
    public let operatorConfirmationID: String
    public let operatorConfirmedReadOnlyProbe: Bool
    public let credentialReference: String
    public let redactedCredentialReference: String
    public let signedAccountSnapshot: BinanceSignedAccountReadSnapshot
    public let privateStreamSnapshotReadModel: BinancePrivateStreamAccountSnapshotReadModel
    public let privateStreamSnapshotSimulated: Bool
    public let dashboardRows: [ReleaseV060TestnetReadOnlyProbeDashboardRow]
    public let noOrderProof: ReleaseV060TestnetReadOnlyProbeNoOrderProof
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let endpointAllowlistHeld: Bool
    public let productionEndpointRejected: Bool
    public let credentialValuesPersisted: Bool
    public let credentialValuesDisplayedOnDashboard: Bool
    public let credentialValuesDisplayedOnCLI: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var artifactHeld: Bool {
        issueID.rawValue == "GH-765"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-755", "GH-757", "GH-764"]
            && previousIssueID.rawValue == "GH-764"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-766"]
            && releaseVersion == "v0.6.0"
            && profileName == ReleaseV060TestnetReadOnlyProbeConfiguration.requiredProfileName
            && ReleaseV060TestnetReadOnlyProbeConfiguration.allowedTestnetHosts.contains(endpointHost)
            && operatorConfirmedReadOnlyProbe
            && credentialReference.isEmpty == false
            && redactedCredentialReference == Self.redactedCredentialReference(credentialReference)
            && signedAccountSnapshot.snapshotBoundaryHeld
            && signedAccountSnapshot.credentialReference == credentialReference
            && privateStreamSnapshotReadModel.boundaryHeld
            && privateStreamSnapshotReadModel.credentialReference == credentialReference
            && privateStreamSnapshotSimulated
            && dashboardRows.isEmpty == false
            && dashboardRows.allSatisfy(\.rowHeld)
            && noOrderProof.proofHeld
            && validationAnchors == ReleaseV060TestnetReadOnlyProbeContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV060TestnetReadOnlyProbeContract.requiredValidationCommands
            && endpointAllowlistHeld
            && productionEndpointRejected
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        credentialValuesPersisted == false
            && credentialValuesDisplayedOnDashboard == false
            && credentialValuesDisplayedOnCLI == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        artifactID: Identifier = Identifier.constant("gh-765-testnet-read-only-probe-artifact"),
        issueID: Identifier = Identifier.constant("GH-765"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-755"),
            Identifier.constant("GH-757"),
            Identifier.constant("GH-764")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-764"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-766")],
        releaseVersion: String = "v0.6.0",
        profileName: String,
        endpointHost: String,
        operatorConfirmationID: String,
        operatorConfirmedReadOnlyProbe: Bool,
        credentialReference: String,
        signedAccountSnapshot: BinanceSignedAccountReadSnapshot,
        privateStreamSnapshotReadModel: BinancePrivateStreamAccountSnapshotReadModel,
        privateStreamSnapshotSimulated: Bool,
        dashboardRows: [ReleaseV060TestnetReadOnlyProbeDashboardRow],
        noOrderProof: ReleaseV060TestnetReadOnlyProbeNoOrderProof,
        validationAnchors: [String] = ReleaseV060TestnetReadOnlyProbeContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV060TestnetReadOnlyProbeContract.requiredValidationCommands,
        endpointAllowlistHeld: Bool = true,
        productionEndpointRejected: Bool = true,
        credentialValuesPersisted: Bool = false,
        credentialValuesDisplayedOnDashboard: Bool = false,
        credentialValuesDisplayedOnCLI: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.artifactID = artifactID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.profileName = profileName
        self.endpointHost = endpointHost
        self.operatorConfirmationID = operatorConfirmationID
        self.operatorConfirmedReadOnlyProbe = operatorConfirmedReadOnlyProbe
        self.credentialReference = credentialReference
        self.redactedCredentialReference = Self.redactedCredentialReference(credentialReference)
        self.signedAccountSnapshot = signedAccountSnapshot
        self.privateStreamSnapshotReadModel = privateStreamSnapshotReadModel
        self.privateStreamSnapshotSimulated = privateStreamSnapshotSimulated
        self.dashboardRows = dashboardRows
        self.noOrderProof = noOrderProof
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.endpointAllowlistHeld = endpointAllowlistHeld
        self.productionEndpointRejected = productionEndpointRejected
        self.credentialValuesPersisted = credentialValuesPersisted
        self.credentialValuesDisplayedOnDashboard = credentialValuesDisplayedOnDashboard
        self.credentialValuesDisplayedOnCLI = credentialValuesDisplayedOnCLI
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointConnected = productionEndpointConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard artifactHeld else {
            throw ReleaseV060TestnetReadOnlyProbeError.contractDrift("artifactHeld")
        }
    }

    public func redactionHeld(forbiddenValues: [String]) throws -> Bool {
        let encoded = try ReleaseV060TestnetReadOnlyProbeArtifactEncoder.encodedString(self)
        for value in forbiddenValues where value.isEmpty == false && encoded.contains(value) {
            throw ReleaseV060TestnetReadOnlyProbeError.artifactRedactionViolation(value)
        }
        return true
    }

    public static func redactedCredentialReference(_ reference: String) -> String {
        "\(reference):<redacted>"
    }
}

/// ReleaseV060TestnetReadOnlyProbeArtifactEncoder 提供稳定 JSON artifact 输出。
public enum ReleaseV060TestnetReadOnlyProbeArtifactEncoder {
    public static func encodedString(_ artifact: ReleaseV060TestnetReadOnlyProbeArtifact) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return String(decoding: try encoder.encode(artifact), as: UTF8.self)
    }
}

/// ReleaseV060TestnetReadOnlyProbe 执行 GH-765 的显式 testnet read-only probe。
///
/// Probe 可通过调用方注入的 credential provider 和 transport 生成 signed account read-only snapshot。
/// 默认 artifact 继续使用 simulated private stream snapshot read model，不打开 WebSocket、不创建 listenKey lifecycle。
public struct ReleaseV060TestnetReadOnlyProbe: Sendable {
    public let configuration: ReleaseV060TestnetReadOnlyProbeConfiguration

    private let credentialProvider: any BinanceSignedAccountCredentialProvider
    private let signedAccountTransport: any BinanceSignedAccountReadTransport

    public init(
        configuration: ReleaseV060TestnetReadOnlyProbeConfiguration,
        credentialProvider: any BinanceSignedAccountCredentialProvider,
        signedAccountTransport: any BinanceSignedAccountReadTransport = URLSessionBinanceSignedAccountReadTransport()
    ) {
        self.configuration = configuration
        self.credentialProvider = credentialProvider
        self.signedAccountTransport = signedAccountTransport
    }

    public func artifact(
        timestamp: Date,
        privateStreamEventPayloads: [Data] = Self.deterministicPrivateStreamEventPayloads()
    ) async throws -> ReleaseV060TestnetReadOnlyProbeArtifact {
        let signedConfiguration = try BinanceSignedAccountReadClientConfiguration(
            environment: .testnet,
            baseURL: configuration.endpointReference
        )
        let signedClient = BinanceSignedAccountReadClient(
            configuration: signedConfiguration,
            credentialProvider: credentialProvider,
            transport: signedAccountTransport
        )
        let snapshot = try await signedClient.accountSnapshot(timestamp: timestamp)
        guard snapshot.credentialReference == configuration.approvedCredentialReference else {
            throw ReleaseV060TestnetReadOnlyProbeError.credentialReferenceMismatch(
                expected: configuration.approvedCredentialReference,
                actual: snapshot.credentialReference
            )
        }

        let privateStreamConfiguration = try BinancePrivateStreamRuntimeConfiguration(
            environment: .testnet,
            restBaseURL: configuration.endpointReference,
            streamBaseURL: ReleaseV060TestnetReadOnlyProbeConfiguration.defaultPrivateStreamTestnetEndpoint,
            staleAfterSeconds: 90
        )
        let privateStreamRuntime = BinancePrivateStreamAccountSnapshotRuntime(
            configuration: privateStreamConfiguration
        )
        let lease = try BinancePrivateStreamListenKeyLease(
            rawListenKey: "gh-765-simulated-private-stream-lease",
            credentialReference: snapshot.credentialReference,
            createdAt: timestamp,
            expiresAt: timestamp.addingTimeInterval(60 * 60)
        )
        let privateStreamReadModel = try privateStreamRuntime.readModel(
            signedSnapshot: snapshot,
            lease: lease,
            eventPayloads: privateStreamEventPayloads,
            sourceIdentity: "gh-765-simulated-private-stream-read-model"
        )

        return try ReleaseV060TestnetReadOnlyProbeArtifact(
            profileName: configuration.profileName,
            endpointHost: configuration.endpointReference.host?.lowercased() ?? "",
            operatorConfirmationID: configuration.operatorConfirmationID,
            operatorConfirmedReadOnlyProbe: configuration.operatorConfirmedReadOnlyProbe,
            credentialReference: snapshot.credentialReference,
            signedAccountSnapshot: snapshot,
            privateStreamSnapshotReadModel: privateStreamReadModel,
            privateStreamSnapshotSimulated: configuration.privateStreamSnapshotSimulated,
            dashboardRows: Self.dashboardRows(
                endpointHost: configuration.endpointReference.host?.lowercased() ?? "",
                credentialReference: snapshot.credentialReference,
                snapshot: snapshot,
                privateStreamReadModel: privateStreamReadModel
            ),
            noOrderProof: try ReleaseV060TestnetReadOnlyProbeNoOrderProof()
        )
    }

    public static func deterministicArtifact() async throws -> ReleaseV060TestnetReadOnlyProbeArtifact {
        let reference = "gh-765-approved-testnet-reference"
        let material = try BinanceSignedAccountCredentialMaterial(
            referenceID: reference,
            keyHeaderValue: "gh-765-fixture-key-value",
            signingSecretValue: "gh-765-fixture-secret-value"
        )
        let probe = ReleaseV060TestnetReadOnlyProbe(
            configuration: try .deterministicFixture(credentialReference: reference),
            credentialProvider: BinanceStaticSignedAccountCredentialProvider(material: material),
            signedAccountTransport: ReleaseV060TestnetReadOnlyProbeFixtureTransport()
        )
        return try await probe.artifact(timestamp: Date(timeIntervalSince1970: 1_704_067_200))
    }

    public static func commandLineOutput(arguments: [String]) async throws -> String {
        guard arguments.count == 1 else {
            throw ReleaseV060TestnetReadOnlyProbeError.contractDrift(arguments.joined(separator: " "))
        }
        let artifact = try await deterministicArtifact()
        return [
            "mtpro \(cliCommand) read-only",
            "issue=\(artifact.issueID.rawValue)",
            "validationAnchor=\(ReleaseV060TestnetReadOnlyProbeContract.requiredValidationAnchors[0])",
            "profile=\(artifact.profileName)",
            "endpointHost=\(artifact.endpointHost)",
            "operatorConfirmedReadOnlyProbe=\(artifact.operatorConfirmedReadOnlyProbe)",
            "credentialReference=\(artifact.redactedCredentialReference)",
            "signedAccountSnapshotArtifact=true",
            "privateStreamSnapshotSimulated=\(artifact.privateStreamSnapshotSimulated)",
            "dashboardCredentialValuesDisplayed=\(artifact.credentialValuesDisplayedOnDashboard)",
            "cliCredentialValuesDisplayed=\(artifact.credentialValuesDisplayedOnCLI)",
            "submitCommandEnabled=\(artifact.noOrderProof.submitCommandEnabled)",
            "cancelCommandEnabled=\(artifact.noOrderProof.cancelCommandEnabled)",
            "replaceCommandEnabled=\(artifact.noOrderProof.replaceCommandEnabled)",
            "productionTradingEnabledByDefault=\(artifact.productionTradingEnabledByDefault)",
            "productionEndpointConnected=\(artifact.productionEndpointConnected)",
            "productionOrderSubmitted=\(artifact.productionOrderSubmitted)",
            "productionCutoverAuthorized=\(artifact.productionCutoverAuthorized)",
            "boundaryHeld=\(artifact.artifactHeld)"
        ].joined(separator: "\n")
    }

    public static let cliCommand = "testnet-readonly-probe"

    public static func deterministicPrivateStreamEventPayloads() -> [Data] {
        [
            Data(
                #"""
                {
                  "e": "outboundAccountPosition",
                  "E": 1704067210000,
                  "u": 1704067211000,
                  "B": [
                    { "a": "BTC", "f": "0.12000000", "l": "0.01000000" },
                    { "a": "USDT", "f": "900.00000000", "l": "5.00000000" }
                  ]
                }
                """#.utf8
            ),
            Data(
                #"""
                {
                  "e": "balanceUpdate",
                  "E": 1704067220000,
                  "a": "USDT",
                  "d": "12.50000000",
                  "T": 1704067221000
                }
                """#.utf8
            )
        ]
    }

    private static func dashboardRows(
        endpointHost: String,
        credentialReference: String,
        snapshot: BinanceSignedAccountReadSnapshot,
        privateStreamReadModel: BinancePrivateStreamAccountSnapshotReadModel
    ) throws -> [ReleaseV060TestnetReadOnlyProbeDashboardRow] {
        try [
            ReleaseV060TestnetReadOnlyProbeDashboardRow(
                label: "Endpoint",
                value: endpointHost
            ),
            ReleaseV060TestnetReadOnlyProbeDashboardRow(
                label: "Credential Reference",
                value: ReleaseV060TestnetReadOnlyProbeArtifact.redactedCredentialReference(credentialReference)
            ),
            ReleaseV060TestnetReadOnlyProbeDashboardRow(
                label: "Signed Account Snapshot",
                value: "\(snapshot.accountType):\(snapshot.balances.count)-balances"
            ),
            ReleaseV060TestnetReadOnlyProbeDashboardRow(
                label: "Private Stream Snapshot",
                value: "simulated-read-model:\(privateStreamReadModel.records.count)-records"
            ),
            ReleaseV060TestnetReadOnlyProbeDashboardRow(
                label: "No Order Boundary",
                value: "submit=false,cancel=false,replace=false"
            )
        ]
    }
}

/// ReleaseV060TestnetReadOnlyProbeFixtureTransport 只服务 deterministic local artifact。
///
/// Transport 不打开网络，只返回 Binance account snapshot fixture，确保 CLI / tests 可无 secret 验证。
public actor ReleaseV060TestnetReadOnlyProbeFixtureTransport: BinanceSignedAccountReadTransport {
    public init() {}

    public func load(_ request: BinanceSignedAccountReadTransportRequest) async throws -> Data {
        guard request.environment == .testnet else {
            throw ReleaseV060TestnetReadOnlyProbeError.forbiddenCapability("nonTestnetFixtureRequest")
        }
        guard request.path == BinanceSignedAccountReadTransportRequest.accountReadOnlyPath else {
            throw ReleaseV060TestnetReadOnlyProbeError.forbiddenCapability(request.path)
        }
        return Data(
            #"""
            {
              "makerCommission": 15,
              "takerCommission": 15,
              "buyerCommission": 0,
              "sellerCommission": 0,
              "canTrade": false,
              "canWithdraw": false,
              "canDeposit": true,
              "updateTime": 1704067205000,
              "accountType": "SPOT",
              "balances": [
                { "asset": "BTC", "free": "0.10000000", "locked": "0.00000000" },
                { "asset": "USDT", "free": "1000.50000000", "locked": "10.00000000" }
              ],
              "permissions": ["SPOT"]
            }
            """#.utf8
        )
    }
}

/// ReleaseV060TestnetReadOnlyProbeContract 固定 GH-765 issue-level 验收合同。
public struct ReleaseV060TestnetReadOnlyProbeContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let requiresOperatorConfirmation: Bool
    public let requiresTestnetOnlyEndpoint: Bool
    public let requiresCredentialRedaction: Bool
    public let privateStreamSnapshotSimulated: Bool
    public let noOrderBoundaryRequired: Bool
    public let productionDefaultsClosed: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-765"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-755", "GH-757", "GH-764"]
            && previousIssueID.rawValue == "GH-764"
            && downstreamIssueID.rawValue == "GH-766"
            && releaseVersion == "v0.6.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && requiresOperatorConfirmation
            && requiresTestnetOnlyEndpoint
            && requiresCredentialRedaction
            && privateStreamSnapshotSimulated
            && noOrderBoundaryRequired
            && productionDefaultsClosed
    }

    public init(
        contractID: Identifier = Identifier.constant("gh-765-release-v0.6.0-testnet-read-only-probe"),
        issueID: Identifier = Identifier.constant("GH-765"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-755"),
            Identifier.constant("GH-757"),
            Identifier.constant("GH-764")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-764"),
        downstreamIssueID: Identifier = Identifier.constant("GH-766"),
        releaseVersion: String = "v0.6.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        requiresOperatorConfirmation: Bool = true,
        requiresTestnetOnlyEndpoint: Bool = true,
        requiresCredentialRedaction: Bool = true,
        privateStreamSnapshotSimulated: Bool = true,
        noOrderBoundaryRequired: Bool = true,
        productionDefaultsClosed: Bool = true
    ) throws {
        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueID = downstreamIssueID
        self.releaseVersion = releaseVersion
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.requiresOperatorConfirmation = requiresOperatorConfirmation
        self.requiresTestnetOnlyEndpoint = requiresTestnetOnlyEndpoint
        self.requiresCredentialRedaction = requiresCredentialRedaction
        self.privateStreamSnapshotSimulated = privateStreamSnapshotSimulated
        self.noOrderBoundaryRequired = noOrderBoundaryRequired
        self.productionDefaultsClosed = productionDefaultsClosed

        guard contractHeld else {
            throw ReleaseV060TestnetReadOnlyProbeError.contractDrift("contractHeld")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV060TestnetReadOnlyProbeContract {
        try ReleaseV060TestnetReadOnlyProbeContract()
    }

    public static let requiredValidationAnchors = [
        "V060-011-TESTNET-READ-ONLY-PROBE",
        "V060-011-OPERATOR-CONFIRMED-TESTNET-PROFILE",
        "V060-011-TESTNET-ENDPOINT-ALLOWLIST-PRODUCTION-REJECTION",
        "V060-011-SIGNED-ACCOUNT-SNAPSHOT-ARTIFACT",
        "V060-011-CREDENTIAL-REDACTION-DASHBOARD-CLI",
        "V060-011-PRIVATE-STREAM-SIMULATED-READMODEL-NO-WEBSOCKET",
        "V060-011-NO-ORDER-NO-PRODUCTION-BOUNDARY",
        "TVM-RELEASE-V060-TESTNET-READONLY-PROBE"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH765TestnetReadOnlyProbeRequiresExplicitConfirmationAndRedactsCredentials",
        "bash checks/verify-v0.6.0-testnet-readonly-probe.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
