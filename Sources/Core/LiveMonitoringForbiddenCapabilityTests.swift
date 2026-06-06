import DomainModel
import Foundation

/// LiveMonitoringForbiddenCapabilityTestDomain 固定 MTP-151 的 forbidden test 覆盖域。
///
/// 这些 domain 只表达本地 deterministic 检查矩阵，不代表可执行 runtime、endpoint、
/// broker adapter 或 UI command。MTP-151 的职责是把 Live Monitoring v2 的越界能力固定为
/// 必须失败的测试入口。
public enum LiveMonitoringForbiddenCapabilityTestDomain:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case endpoint = "endpoint forbidden tests"
    case streamRuntime = "private stream runtime forbidden tests"
    case liveRuntime = "live monitoring runtime forbidden tests"
    case brokerExecution = "broker execution forbidden tests"
    case uiCommand = "ui command forbidden tests"
}

/// LiveMonitoringForbiddenCapabilityTestAssertion 列出 MTP-151 必须覆盖的 forbidden capability。
///
/// 枚举值可以包含 endpoint、listenKey、broker 和 UI command 等禁区词，因为它们是测试名称，
/// 不是当前产品能力。任何对应 implementation flag 仍必须保持 false。
public enum LiveMonitoringForbiddenCapabilityTestAssertion:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case signedEndpoint = "signed endpoint must be rejected"
    case accountEndpoint = "account endpoint must be rejected"
    case listenKey = "listenKey must be rejected"
    case privateWebSocketRuntime = "private WebSocket runtime must be rejected"
    case privateStreamRuntime = "private stream runtime must be rejected"
    case accountSnapshotRuntime = "account snapshot runtime must be rejected"
    case connectionManager = "connection manager must be rejected"
    case runtimeConnection = "runtime connection must be rejected"
    case liveReadinessRuntime = "live readiness runtime must be rejected"
    case liveMonitoringRuntime = "Live Monitoring runtime must be rejected"
    case brokerAdapter = "broker adapter must be rejected"
    case exchangeExecutionAdapter = "exchange execution adapter must be rejected"
    case liveExecutionAdapter = "LiveExecutionAdapter must be rejected"
    case oms = "OMS must be rejected"
    case livePROConsole = "Live PRO Console must be rejected"
    case tradingButton = "trading button must be rejected"
    case liveCommand = "live command must be rejected"
    case orderForm = "order form must be rejected"
    case stopShutdownRestore = "stop / shutdown / restore command must be rejected"
}

/// LiveMonitoringForbiddenCapabilityTestCase 是 MTP-151 的单条 forbidden test evidence。
///
/// Test case 只描述本地检查应覆盖哪些 forbidden capability、应链接哪个已有合同，以及失败信号。
/// 它不创建 endpoint client、WebSocket、broker adapter、Runtime object、Live PRO Console 或交易命令。
public struct LiveMonitoringForbiddenCapabilityTestCase: Codable, Equatable, Sendable {
    public let domain: LiveMonitoringForbiddenCapabilityTestDomain
    public let assertion: LiveMonitoringForbiddenCapabilityTestAssertion
    public let testID: String
    public let sourceContractIDs: [Identifier]
    public let requirement: String
    public let expectedFailureSignal: String
    public let deterministicLocalOnly: Bool
    public let readModelOnly: Bool
    public let noNetworkDependency: Bool

    public var canonicalLine: String {
        [
            domain.rawValue,
            assertion.rawValue,
            testID,
            sourceContractIDs.map(\.rawValue).joined(separator: "+"),
            requirement,
            expectedFailureSignal,
            String(deterministicLocalOnly),
            String(readModelOnly),
            String(noNetworkDependency)
        ].joined(separator: "|")
    }

    public var forbiddenCapabilityTestBoundaryHeld: Bool {
        self == Self.requiredCase(for: assertion)
            && deterministicLocalOnly
            && readModelOnly
            && noNetworkDependency
    }

    public init(
        domain: LiveMonitoringForbiddenCapabilityTestDomain? = nil,
        assertion: LiveMonitoringForbiddenCapabilityTestAssertion,
        testID: String? = nil,
        sourceContractIDs: [Identifier] = Self.requiredSourceContractIDs,
        requirement: String? = nil,
        expectedFailureSignal: String? = nil,
        deterministicLocalOnly: Bool = true,
        readModelOnly: Bool = true,
        noNetworkDependency: Bool = true
    ) throws {
        let resolvedDomain = domain ?? Self.requiredDomain(for: assertion)
        let resolvedTestID = testID ?? Self.requiredTestID(for: assertion)
        let resolvedRequirement = requirement ?? Self.requiredRequirement(for: assertion)
        let resolvedExpectedFailureSignal =
            expectedFailureSignal ?? Self.requiredExpectedFailureSignal(for: assertion)
        try Self.validate(
            domain: resolvedDomain,
            assertion: assertion,
            testID: resolvedTestID,
            sourceContractIDs: sourceContractIDs,
            requirement: resolvedRequirement,
            expectedFailureSignal: resolvedExpectedFailureSignal,
            deterministicLocalOnly: deterministicLocalOnly,
            readModelOnly: readModelOnly,
            noNetworkDependency: noNetworkDependency
        )

        self.domain = resolvedDomain
        self.assertion = assertion
        self.testID = resolvedTestID
        self.sourceContractIDs = sourceContractIDs
        self.requirement = resolvedRequirement
        self.expectedFailureSignal = resolvedExpectedFailureSignal
        self.deterministicLocalOnly = deterministicLocalOnly
        self.readModelOnly = readModelOnly
        self.noNetworkDependency = noNetworkDependency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            domain: try container.decode(LiveMonitoringForbiddenCapabilityTestDomain.self, forKey: .domain),
            assertion: try container.decode(LiveMonitoringForbiddenCapabilityTestAssertion.self, forKey: .assertion),
            testID: try container.decode(String.self, forKey: .testID),
            sourceContractIDs: try container.decode([Identifier].self, forKey: .sourceContractIDs),
            requirement: try container.decode(String.self, forKey: .requirement),
            expectedFailureSignal: try container.decode(String.self, forKey: .expectedFailureSignal),
            deterministicLocalOnly: try container.decode(Bool.self, forKey: .deterministicLocalOnly),
            readModelOnly: try container.decode(Bool.self, forKey: .readModelOnly),
            noNetworkDependency: try container.decode(Bool.self, forKey: .noNetworkDependency)
        )
    }

    public static let requiredSourceContractIDs = [
        LiveMonitoringSourceIdentityContract.deterministicFixture.contractID,
        LiveMonitoringSimulationGateHealthContract.deterministicFixture.contractID,
        LiveMonitoringConnectionReadinessExplanationContract.deterministicFixture.contractID
    ]

    public static func requiredCase(
        for assertion: LiveMonitoringForbiddenCapabilityTestAssertion
    ) -> LiveMonitoringForbiddenCapabilityTestCase {
        do {
            return try LiveMonitoringForbiddenCapabilityTestCase(assertion: assertion)
        } catch {
            preconditionFailure("MTP-151 forbidden capability test case must be valid: \(error)")
        }
    }

    public static func requiredDomain(
        for assertion: LiveMonitoringForbiddenCapabilityTestAssertion
    ) -> LiveMonitoringForbiddenCapabilityTestDomain {
        switch assertion {
        case .signedEndpoint, .accountEndpoint, .listenKey:
            return .endpoint
        case .privateWebSocketRuntime, .privateStreamRuntime, .accountSnapshotRuntime:
            return .streamRuntime
        case .connectionManager, .runtimeConnection, .liveReadinessRuntime, .liveMonitoringRuntime:
            return .liveRuntime
        case .brokerAdapter, .exchangeExecutionAdapter, .liveExecutionAdapter, .oms:
            return .brokerExecution
        case .livePROConsole, .tradingButton, .liveCommand, .orderForm, .stopShutdownRestore:
            return .uiCommand
        }
    }

    public static func requiredTestID(for assertion: LiveMonitoringForbiddenCapabilityTestAssertion) -> String {
        "live-monitoring-forbidden-capability|mtp-151|\(slug(for: assertion))|001"
    }

    public static func requiredRequirement(
        for assertion: LiveMonitoringForbiddenCapabilityTestAssertion
    ) -> String {
        switch assertion {
        case .signedEndpoint:
            return "contract and focused tests reject signed endpoint call"
        case .accountEndpoint:
            return "contract and focused tests reject account endpoint call"
        case .listenKey:
            return "contract and focused tests reject listenKey creation or keepalive"
        case .privateWebSocketRuntime:
            return "contract and focused tests reject private WebSocket runtime"
        case .privateStreamRuntime:
            return "contract and focused tests reject private stream runtime"
        case .accountSnapshotRuntime:
            return "contract and focused tests reject account snapshot runtime"
        case .connectionManager:
            return "contract and focused tests reject connection manager implementation"
        case .runtimeConnection:
            return "contract and focused tests reject runtime connection opening"
        case .liveReadinessRuntime:
            return "contract and focused tests reject live readiness runtime"
        case .liveMonitoringRuntime:
            return "contract and focused tests reject Live Monitoring runtime"
        case .brokerAdapter:
            return "contract and focused tests reject broker adapter"
        case .exchangeExecutionAdapter:
            return "contract and focused tests reject exchange execution adapter"
        case .liveExecutionAdapter:
            return "contract and focused tests reject LiveExecutionAdapter"
        case .oms:
            return "contract and focused tests reject OMS"
        case .livePROConsole:
            return "contract and focused tests reject Live PRO Console"
        case .tradingButton:
            return "contract and focused tests reject trading button"
        case .liveCommand:
            return "contract and focused tests reject live command"
        case .orderForm:
            return "contract and focused tests reject order form"
        case .stopShutdownRestore:
            return "contract and focused tests reject stop / shutdown / restore command"
        }
    }

    public static func requiredExpectedFailureSignal(
        for assertion: LiveMonitoringForbiddenCapabilityTestAssertion
    ) -> String {
        "CoreError.liveMonitoringConsoleForbiddenCapability(\(slug(for: assertion)))"
    }

    private static func validate(
        domain: LiveMonitoringForbiddenCapabilityTestDomain,
        assertion: LiveMonitoringForbiddenCapabilityTestAssertion,
        testID: String,
        sourceContractIDs: [Identifier],
        requirement: String,
        expectedFailureSignal: String,
        deterministicLocalOnly: Bool,
        readModelOnly: Bool,
        noNetworkDependency: Bool
    ) throws {
        guard domain == Self.requiredDomain(for: assertion) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(assertion.rawValue).domain",
                expected: Self.requiredDomain(for: assertion).rawValue,
                actual: domain.rawValue
            )
        }
        guard testID == Self.requiredTestID(for: assertion) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(assertion.rawValue).testID",
                expected: Self.requiredTestID(for: assertion),
                actual: testID
            )
        }
        guard sourceContractIDs == Self.requiredSourceContractIDs else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceContractIDs",
                expected: Self.requiredSourceContractIDs.map(\.rawValue).joined(separator: ","),
                actual: sourceContractIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard requirement == Self.requiredRequirement(for: assertion) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(assertion.rawValue).requirement",
                expected: Self.requiredRequirement(for: assertion),
                actual: requirement
            )
        }
        guard expectedFailureSignal == Self.requiredExpectedFailureSignal(for: assertion) else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "\(assertion.rawValue).expectedFailureSignal",
                expected: Self.requiredExpectedFailureSignal(for: assertion),
                actual: expectedFailureSignal
            )
        }
        guard deterministicLocalOnly else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("deterministicLocalOnly")
        }
        guard readModelOnly else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("readModelOnly")
        }
        guard noNetworkDependency else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("noNetworkDependency")
        }
    }

    private static func slug(for assertion: LiveMonitoringForbiddenCapabilityTestAssertion) -> String {
        switch assertion {
        case .signedEndpoint:
            return "signed-endpoint"
        case .accountEndpoint:
            return "account-endpoint"
        case .listenKey:
            return "listenkey"
        case .privateWebSocketRuntime:
            return "private-websocket-runtime"
        case .privateStreamRuntime:
            return "private-stream-runtime"
        case .accountSnapshotRuntime:
            return "account-snapshot-runtime"
        case .connectionManager:
            return "connection-manager"
        case .runtimeConnection:
            return "runtime-connection"
        case .liveReadinessRuntime:
            return "live-readiness-runtime"
        case .liveMonitoringRuntime:
            return "live-monitoring-runtime"
        case .brokerAdapter:
            return "broker-adapter"
        case .exchangeExecutionAdapter:
            return "exchange-execution-adapter"
        case .liveExecutionAdapter:
            return "live-execution-adapter"
        case .oms:
            return "oms"
        case .livePROConsole:
            return "live-pro-console"
        case .tradingButton:
            return "trading-button"
        case .liveCommand:
            return "live-command"
        case .orderForm:
            return "order-form"
        case .stopShutdownRestore:
            return "stop-shutdown-restore"
        }
    }
}

/// LiveMonitoringForbiddenCapabilityTestContract 是 MTP-151 的 forbidden test matrix 合同。
///
/// 合同聚合 endpoint、private stream、Live Monitoring runtime、broker / execution 和 UI command
/// 五类禁止测试，确保 MTP-147 至 MTP-150 的 monitoring evidence 不能被升级为真实 runtime 或交易入口。
public struct LiveMonitoringForbiddenCapabilityTestContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let matrixID: String
    public let sourceIdentityChecksum: String
    public let simulationGateHealthChecksum: String
    public let connectionReadinessChecksum: String
    public let testCases: [LiveMonitoringForbiddenCapabilityTestCase]
    public let coveredDomains: [LiveMonitoringForbiddenCapabilityTestDomain]
    public let coveredAssertions: [LiveMonitoringForbiddenCapabilityTestAssertion]
    public let checksum: String
    public let checksumMatchedCanonicalPreimage: Bool
    public let deterministicLocalOnly: Bool
    public let readModelOnly: Bool
    public let noNetworkDependency: Bool
    public let forbiddenEndpointCoverageHeld: Bool
    public let forbiddenRuntimeCoverageHeld: Bool
    public let forbiddenBrokerCoverageHeld: Bool
    public let forbiddenUICommandCoverageHeld: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let opensPrivateWebSocket: Bool
    public let runsPrivateStreamRuntime: Bool
    public let runsAccountSnapshotRuntime: Bool
    public let createsConnectionManager: Bool
    public let opensRuntimeConnection: Bool
    public let implementsLiveReadiness: Bool
    public let runsLiveMonitoringRuntime: Bool
    public let connectsBrokerAdapter: Bool
    public let connectsExchangeExecutionAdapter: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let exposesLivePROConsole: Bool
    public let exposesTradingButton: Bool
    public let exposesLiveCommand: Bool
    public let exposesOrderForm: Bool
    public let exposesStopShutdownRestoreCommand: Bool
    public let readsRealAccount: Bool
    public let dependsOnRealBroker: Bool

    public var forbiddenCapabilityTestBoundaryHeld: Bool {
        matrixID == Self.requiredMatrixID
            && sourceIdentityChecksum == Self.requiredSourceIdentityChecksum
            && simulationGateHealthChecksum == Self.requiredSimulationGateHealthChecksum
            && connectionReadinessChecksum == Self.requiredConnectionReadinessChecksum
            && testCases == Self.requiredTestCases
            && testCases.allSatisfy(\.forbiddenCapabilityTestBoundaryHeld)
            && coveredDomains == Self.requiredCoveredDomains
            && coveredAssertions == Self.requiredCoveredAssertions
            && checksum == Self.requiredChecksum
            && checksumMatchedCanonicalPreimage
            && deterministicLocalOnly
            && readModelOnly
            && noNetworkDependency
            && forbiddenEndpointCoverageHeld
            && forbiddenRuntimeCoverageHeld
            && forbiddenBrokerCoverageHeld
            && forbiddenUICommandCoverageHeld
            && forbiddenFlagsAreFalse
    }

    public var canonicalPreimage: String {
        Self.canonicalPreimage(for: testCases)
    }

    public init(
        contractID: Identifier = Identifier.constant("mtp-151-live-monitoring-forbidden-capability-tests"),
        issueID: Identifier = Identifier.constant("MTP-151"),
        matrixID: String = Self.requiredMatrixID,
        sourceIdentityChecksum: String = Self.requiredSourceIdentityChecksum,
        simulationGateHealthChecksum: String = Self.requiredSimulationGateHealthChecksum,
        connectionReadinessChecksum: String = Self.requiredConnectionReadinessChecksum,
        testCases: [LiveMonitoringForbiddenCapabilityTestCase] = Self.requiredTestCases,
        coveredDomains: [LiveMonitoringForbiddenCapabilityTestDomain] = Self.requiredCoveredDomains,
        coveredAssertions: [LiveMonitoringForbiddenCapabilityTestAssertion] = Self.requiredCoveredAssertions,
        checksum: String? = nil,
        checksumMatchedCanonicalPreimage: Bool = true,
        deterministicLocalOnly: Bool = true,
        readModelOnly: Bool = true,
        noNetworkDependency: Bool = true,
        forbiddenEndpointCoverageHeld: Bool = true,
        forbiddenRuntimeCoverageHeld: Bool = true,
        forbiddenBrokerCoverageHeld: Bool = true,
        forbiddenUICommandCoverageHeld: Bool = true,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        opensPrivateWebSocket: Bool = false,
        runsPrivateStreamRuntime: Bool = false,
        runsAccountSnapshotRuntime: Bool = false,
        createsConnectionManager: Bool = false,
        opensRuntimeConnection: Bool = false,
        implementsLiveReadiness: Bool = false,
        runsLiveMonitoringRuntime: Bool = false,
        connectsBrokerAdapter: Bool = false,
        connectsExchangeExecutionAdapter: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        exposesLivePROConsole: Bool = false,
        exposesTradingButton: Bool = false,
        exposesLiveCommand: Bool = false,
        exposesOrderForm: Bool = false,
        exposesStopShutdownRestoreCommand: Bool = false,
        readsRealAccount: Bool = false,
        dependsOnRealBroker: Bool = false
    ) throws {
        let providedChecksum = checksum ?? Self.checksum(for: testCases)
        try Self.validate(
            matrixID: matrixID,
            sourceIdentityChecksum: sourceIdentityChecksum,
            simulationGateHealthChecksum: simulationGateHealthChecksum,
            connectionReadinessChecksum: connectionReadinessChecksum,
            testCases: testCases,
            coveredDomains: coveredDomains,
            coveredAssertions: coveredAssertions,
            checksum: providedChecksum,
            checksumMatchedCanonicalPreimage: checksumMatchedCanonicalPreimage,
            deterministicLocalOnly: deterministicLocalOnly,
            readModelOnly: readModelOnly,
            noNetworkDependency: noNetworkDependency,
            forbiddenEndpointCoverageHeld: forbiddenEndpointCoverageHeld,
            forbiddenRuntimeCoverageHeld: forbiddenRuntimeCoverageHeld,
            forbiddenBrokerCoverageHeld: forbiddenBrokerCoverageHeld,
            forbiddenUICommandCoverageHeld: forbiddenUICommandCoverageHeld
        )
        try Self.validateForbiddenFlags(
            callsSignedEndpoint: callsSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            opensPrivateWebSocket: opensPrivateWebSocket,
            runsPrivateStreamRuntime: runsPrivateStreamRuntime,
            runsAccountSnapshotRuntime: runsAccountSnapshotRuntime,
            createsConnectionManager: createsConnectionManager,
            opensRuntimeConnection: opensRuntimeConnection,
            implementsLiveReadiness: implementsLiveReadiness,
            runsLiveMonitoringRuntime: runsLiveMonitoringRuntime,
            connectsBrokerAdapter: connectsBrokerAdapter,
            connectsExchangeExecutionAdapter: connectsExchangeExecutionAdapter,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            exposesLivePROConsole: exposesLivePROConsole,
            exposesTradingButton: exposesTradingButton,
            exposesLiveCommand: exposesLiveCommand,
            exposesOrderForm: exposesOrderForm,
            exposesStopShutdownRestoreCommand: exposesStopShutdownRestoreCommand,
            readsRealAccount: readsRealAccount,
            dependsOnRealBroker: dependsOnRealBroker
        )

        self.contractID = contractID
        self.issueID = issueID
        self.matrixID = matrixID
        self.sourceIdentityChecksum = sourceIdentityChecksum
        self.simulationGateHealthChecksum = simulationGateHealthChecksum
        self.connectionReadinessChecksum = connectionReadinessChecksum
        self.testCases = testCases
        self.coveredDomains = coveredDomains
        self.coveredAssertions = coveredAssertions
        self.checksum = providedChecksum
        self.checksumMatchedCanonicalPreimage = checksumMatchedCanonicalPreimage
        self.deterministicLocalOnly = deterministicLocalOnly
        self.readModelOnly = readModelOnly
        self.noNetworkDependency = noNetworkDependency
        self.forbiddenEndpointCoverageHeld = forbiddenEndpointCoverageHeld
        self.forbiddenRuntimeCoverageHeld = forbiddenRuntimeCoverageHeld
        self.forbiddenBrokerCoverageHeld = forbiddenBrokerCoverageHeld
        self.forbiddenUICommandCoverageHeld = forbiddenUICommandCoverageHeld
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.opensPrivateWebSocket = opensPrivateWebSocket
        self.runsPrivateStreamRuntime = runsPrivateStreamRuntime
        self.runsAccountSnapshotRuntime = runsAccountSnapshotRuntime
        self.createsConnectionManager = createsConnectionManager
        self.opensRuntimeConnection = opensRuntimeConnection
        self.implementsLiveReadiness = implementsLiveReadiness
        self.runsLiveMonitoringRuntime = runsLiveMonitoringRuntime
        self.connectsBrokerAdapter = connectsBrokerAdapter
        self.connectsExchangeExecutionAdapter = connectsExchangeExecutionAdapter
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.exposesLivePROConsole = exposesLivePROConsole
        self.exposesTradingButton = exposesTradingButton
        self.exposesLiveCommand = exposesLiveCommand
        self.exposesOrderForm = exposesOrderForm
        self.exposesStopShutdownRestoreCommand = exposesStopShutdownRestoreCommand
        self.readsRealAccount = readsRealAccount
        self.dependsOnRealBroker = dependsOnRealBroker
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            matrixID: try container.decode(String.self, forKey: .matrixID),
            sourceIdentityChecksum: try container.decode(String.self, forKey: .sourceIdentityChecksum),
            simulationGateHealthChecksum: try container.decode(String.self, forKey: .simulationGateHealthChecksum),
            connectionReadinessChecksum: try container.decode(String.self, forKey: .connectionReadinessChecksum),
            testCases: try container.decode([LiveMonitoringForbiddenCapabilityTestCase].self, forKey: .testCases),
            coveredDomains: try container.decode(
                [LiveMonitoringForbiddenCapabilityTestDomain].self,
                forKey: .coveredDomains
            ),
            coveredAssertions: try container.decode(
                [LiveMonitoringForbiddenCapabilityTestAssertion].self,
                forKey: .coveredAssertions
            ),
            checksum: try container.decode(String.self, forKey: .checksum),
            checksumMatchedCanonicalPreimage: try container.decode(
                Bool.self,
                forKey: .checksumMatchedCanonicalPreimage
            ),
            deterministicLocalOnly: try container.decode(Bool.self, forKey: .deterministicLocalOnly),
            readModelOnly: try container.decode(Bool.self, forKey: .readModelOnly),
            noNetworkDependency: try container.decode(Bool.self, forKey: .noNetworkDependency),
            forbiddenEndpointCoverageHeld: try container.decode(
                Bool.self,
                forKey: .forbiddenEndpointCoverageHeld
            ),
            forbiddenRuntimeCoverageHeld: try container.decode(Bool.self, forKey: .forbiddenRuntimeCoverageHeld),
            forbiddenBrokerCoverageHeld: try container.decode(Bool.self, forKey: .forbiddenBrokerCoverageHeld),
            forbiddenUICommandCoverageHeld: try container.decode(
                Bool.self,
                forKey: .forbiddenUICommandCoverageHeld
            ),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            opensPrivateWebSocket: try container.decode(Bool.self, forKey: .opensPrivateWebSocket),
            runsPrivateStreamRuntime: try container.decode(Bool.self, forKey: .runsPrivateStreamRuntime),
            runsAccountSnapshotRuntime: try container.decode(Bool.self, forKey: .runsAccountSnapshotRuntime),
            createsConnectionManager: try container.decode(Bool.self, forKey: .createsConnectionManager),
            opensRuntimeConnection: try container.decode(Bool.self, forKey: .opensRuntimeConnection),
            implementsLiveReadiness: try container.decode(Bool.self, forKey: .implementsLiveReadiness),
            runsLiveMonitoringRuntime: try container.decode(Bool.self, forKey: .runsLiveMonitoringRuntime),
            connectsBrokerAdapter: try container.decode(Bool.self, forKey: .connectsBrokerAdapter),
            connectsExchangeExecutionAdapter: try container.decode(
                Bool.self,
                forKey: .connectsExchangeExecutionAdapter
            ),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            exposesLivePROConsole: try container.decode(Bool.self, forKey: .exposesLivePROConsole),
            exposesTradingButton: try container.decode(Bool.self, forKey: .exposesTradingButton),
            exposesLiveCommand: try container.decode(Bool.self, forKey: .exposesLiveCommand),
            exposesOrderForm: try container.decode(Bool.self, forKey: .exposesOrderForm),
            exposesStopShutdownRestoreCommand: try container.decode(
                Bool.self,
                forKey: .exposesStopShutdownRestoreCommand
            ),
            readsRealAccount: try container.decode(Bool.self, forKey: .readsRealAccount),
            dependsOnRealBroker: try container.decode(Bool.self, forKey: .dependsOnRealBroker)
        )
    }

    public static let requiredMatrixID = "TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2"
    public static let requiredSourceIdentityChecksum = LiveMonitoringSourceIdentityContract.requiredChecksum
    public static let requiredSimulationGateHealthChecksum =
        LiveMonitoringSimulationGateHealthContract.requiredChecksum
    public static let requiredConnectionReadinessChecksum =
        LiveMonitoringConnectionReadinessExplanationContract.requiredChecksum
    public static let requiredCoveredDomains = LiveMonitoringForbiddenCapabilityTestDomain.allCases
    public static let requiredCoveredAssertions = LiveMonitoringForbiddenCapabilityTestAssertion.allCases

    public static let requiredTestCases: [LiveMonitoringForbiddenCapabilityTestCase] = {
        LiveMonitoringForbiddenCapabilityTestAssertion.allCases.map {
            LiveMonitoringForbiddenCapabilityTestCase.requiredCase(for: $0)
        }
    }()

    public static let requiredChecksum = checksum(for: requiredTestCases)

    public static let deterministicFixture: LiveMonitoringForbiddenCapabilityTestContract = {
        do {
            return try LiveMonitoringForbiddenCapabilityTestContract()
        } catch {
            preconditionFailure("MTP-151 forbidden capability test contract must be valid: \(error)")
        }
    }()

    public static func canonicalPreimage(
        for testCases: [LiveMonitoringForbiddenCapabilityTestCase]
    ) -> String {
        testCases.map(\.canonicalLine).joined(separator: "\n")
    }

    public static func checksum(
        for testCases: [LiveMonitoringForbiddenCapabilityTestCase]
    ) -> String {
        ScenarioReplayChecksumEvidence.checksum(forCanonicalPreimage: canonicalPreimage(for: testCases))
    }

    private var forbiddenFlagsAreFalse: Bool {
        callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && opensPrivateWebSocket == false
            && runsPrivateStreamRuntime == false
            && runsAccountSnapshotRuntime == false
            && createsConnectionManager == false
            && opensRuntimeConnection == false
            && implementsLiveReadiness == false
            && runsLiveMonitoringRuntime == false
            && connectsBrokerAdapter == false
            && connectsExchangeExecutionAdapter == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && exposesLivePROConsole == false
            && exposesTradingButton == false
            && exposesLiveCommand == false
            && exposesOrderForm == false
            && exposesStopShutdownRestoreCommand == false
            && readsRealAccount == false
            && dependsOnRealBroker == false
    }

    private static func validate(
        matrixID: String,
        sourceIdentityChecksum: String,
        simulationGateHealthChecksum: String,
        connectionReadinessChecksum: String,
        testCases: [LiveMonitoringForbiddenCapabilityTestCase],
        coveredDomains: [LiveMonitoringForbiddenCapabilityTestDomain],
        coveredAssertions: [LiveMonitoringForbiddenCapabilityTestAssertion],
        checksum: String,
        checksumMatchedCanonicalPreimage: Bool,
        deterministicLocalOnly: Bool,
        readModelOnly: Bool,
        noNetworkDependency: Bool,
        forbiddenEndpointCoverageHeld: Bool,
        forbiddenRuntimeCoverageHeld: Bool,
        forbiddenBrokerCoverageHeld: Bool,
        forbiddenUICommandCoverageHeld: Bool
    ) throws {
        guard matrixID == Self.requiredMatrixID else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "matrixID",
                expected: Self.requiredMatrixID,
                actual: matrixID
            )
        }
        guard sourceIdentityChecksum == Self.requiredSourceIdentityChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "sourceIdentityChecksum",
                expected: Self.requiredSourceIdentityChecksum,
                actual: sourceIdentityChecksum
            )
        }
        guard simulationGateHealthChecksum == Self.requiredSimulationGateHealthChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "simulationGateHealthChecksum",
                expected: Self.requiredSimulationGateHealthChecksum,
                actual: simulationGateHealthChecksum
            )
        }
        guard connectionReadinessChecksum == Self.requiredConnectionReadinessChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "connectionReadinessChecksum",
                expected: Self.requiredConnectionReadinessChecksum,
                actual: connectionReadinessChecksum
            )
        }
        guard testCases == Self.requiredTestCases else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "testCases",
                expected: Self.requiredTestCases.map(\.testID).joined(separator: ","),
                actual: testCases.map(\.testID).joined(separator: ",")
            )
        }
        guard testCases.allSatisfy(\.forbiddenCapabilityTestBoundaryHeld) else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("forbiddenCapabilityTestBoundaryHeld")
        }
        guard coveredDomains == Self.requiredCoveredDomains else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "coveredDomains",
                expected: Self.requiredCoveredDomains.map(\.rawValue).joined(separator: ","),
                actual: coveredDomains.map(\.rawValue).joined(separator: ",")
            )
        }
        guard coveredAssertions == Self.requiredCoveredAssertions else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "coveredAssertions",
                expected: Self.requiredCoveredAssertions.map(\.rawValue).joined(separator: ","),
                actual: coveredAssertions.map(\.rawValue).joined(separator: ",")
            )
        }
        guard checksum == Self.requiredChecksum else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "checksum",
                expected: Self.requiredChecksum,
                actual: checksum
            )
        }
        guard checksumMatchedCanonicalPreimage else {
            throw CoreError.liveMonitoringConsoleContractMismatch(
                field: "checksumMatchedCanonicalPreimage",
                expected: "true",
                actual: "false"
            )
        }
        guard deterministicLocalOnly else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("deterministicLocalOnly")
        }
        guard readModelOnly else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("readModelOnly")
        }
        guard noNetworkDependency else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("noNetworkDependency")
        }
        guard forbiddenEndpointCoverageHeld else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("forbiddenEndpointCoverageHeld")
        }
        guard forbiddenRuntimeCoverageHeld else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("forbiddenRuntimeCoverageHeld")
        }
        guard forbiddenBrokerCoverageHeld else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("forbiddenBrokerCoverageHeld")
        }
        guard forbiddenUICommandCoverageHeld else {
            throw CoreError.liveMonitoringConsoleForbiddenCapability("forbiddenUICommandCoverageHeld")
        }
    }

    private static func validateForbiddenFlags(
        callsSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        opensPrivateWebSocket: Bool,
        runsPrivateStreamRuntime: Bool,
        runsAccountSnapshotRuntime: Bool,
        createsConnectionManager: Bool,
        opensRuntimeConnection: Bool,
        implementsLiveReadiness: Bool,
        runsLiveMonitoringRuntime: Bool,
        connectsBrokerAdapter: Bool,
        connectsExchangeExecutionAdapter: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        exposesLivePROConsole: Bool,
        exposesTradingButton: Bool,
        exposesLiveCommand: Bool,
        exposesOrderForm: Bool,
        exposesStopShutdownRestoreCommand: Bool,
        readsRealAccount: Bool,
        dependsOnRealBroker: Bool
    ) throws {
        let forbiddenFlags = [
            ("callsSignedEndpoint", callsSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("opensPrivateWebSocket", opensPrivateWebSocket),
            ("runsPrivateStreamRuntime", runsPrivateStreamRuntime),
            ("runsAccountSnapshotRuntime", runsAccountSnapshotRuntime),
            ("createsConnectionManager", createsConnectionManager),
            ("opensRuntimeConnection", opensRuntimeConnection),
            ("implementsLiveReadiness", implementsLiveReadiness),
            ("runsLiveMonitoringRuntime", runsLiveMonitoringRuntime),
            ("connectsBrokerAdapter", connectsBrokerAdapter),
            ("connectsExchangeExecutionAdapter", connectsExchangeExecutionAdapter),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("exposesLivePROConsole", exposesLivePROConsole),
            ("exposesTradingButton", exposesTradingButton),
            ("exposesLiveCommand", exposesLiveCommand),
            ("exposesOrderForm", exposesOrderForm),
            ("exposesStopShutdownRestoreCommand", exposesStopShutdownRestoreCommand),
            ("readsRealAccount", readsRealAccount),
            ("dependsOnRealBroker", dependsOnRealBroker)
        ]

        if let capability = forbiddenFlags.first(where: { $0.1 }) {
            throw CoreError.liveMonitoringConsoleForbiddenCapability(capability.0)
        }
    }
}
