import DomainModel
import Foundation

/// MTP-206 在 Trader 容器下新增 Accounts 边界，但只表达 account context。
///
/// 本文件不实现账户读取、账户快照 runtime、private WebSocket runtime、Trader runtime 或 Live runtime。
/// 这里的 account 只用于把 Trader 内部的 account identity、source identity 和 future real account gate
/// 固定成可测试的本地合同；资金、持仓、PnL、margin 和 leverage 继续属于 Portfolio / RiskEngine 边界。

/// TraderAccountSourceKind 描述 account context 的来源语义。
///
/// 这些来源都是本地 deterministic / paper / simulated / future-gated label，不表示真实账户连接。
public enum TraderAccountSourceKind: String, Codable, CaseIterable, Equatable, Sendable {
    case fixture
    case paper
    case simulated
    case futureRealAccountGate = "future_real_account_gate"
}

/// TraderAccountFutureRealAccountGate 固定 future real account 的当前状态。
///
/// 当前唯一状态要求 Human + @001 / PLN 规划、Linear issue、@002 queue preflight 和验证 gate；
/// 不能在本类型中恢复 signed endpoint、account endpoint、listenKey 或 broker account payload。
public enum TraderAccountFutureRealAccountGate: String, Codable, Equatable, Sendable {
    case unavailableRequiresHumanPlanning = "unavailable_requires_human_planning"

    public var authorizesRealAccountRead: Bool {
        false
    }
}

/// TraderAccountContext 保存 Trader/Accounts 的最小 account context。
///
/// 输入字段只允许 identity / source / gate / relationship evidence。所有真实账户状态和财务状态
/// 都通过显式 forbidden flags 保持关闭，并在初始化与 Codable 解码时统一校验。
public struct TraderAccountContext: Codable, Equatable, Sendable {
    public let contextID: Identifier
    public let accountIdentity: Identifier
    public let sourceIdentity: String
    public let sourceKind: TraderAccountSourceKind
    public let futureRealAccountGate: TraderAccountFutureRealAccountGate
    public let portfolioRelationship: String
    public let riskEngineRelationship: String
    public let executionEngineRelationship: String
    public let validationAnchors: [String]
    public let ownsCash: Bool
    public let ownsPositions: Bool
    public let ownsPnL: Bool
    public let ownsMargin: Bool
    public let ownsLeverage: Bool
    public let readsBrokerAccountPayload: Bool
    public let callsSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let startsPrivateWebSocketRuntime: Bool
    public let implementsAccountSnapshotRuntime: Bool
    public let implementsTraderRuntime: Bool
    public let implementsLiveRuntime: Bool
    public let usesExecutionClient: Bool
    public let usesOMS: Bool
    public let connectsBrokerGateway: Bool

    public init(
        contextID: Identifier,
        accountIdentity: Identifier,
        sourceIdentity: String,
        sourceKind: TraderAccountSourceKind,
        futureRealAccountGate: TraderAccountFutureRealAccountGate = .unavailableRequiresHumanPlanning,
        portfolioRelationship: String,
        riskEngineRelationship: String,
        executionEngineRelationship: String,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        ownsCash: Bool = false,
        ownsPositions: Bool = false,
        ownsPnL: Bool = false,
        ownsMargin: Bool = false,
        ownsLeverage: Bool = false,
        readsBrokerAccountPayload: Bool = false,
        callsSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        startsPrivateWebSocketRuntime: Bool = false,
        implementsAccountSnapshotRuntime: Bool = false,
        implementsTraderRuntime: Bool = false,
        implementsLiveRuntime: Bool = false,
        usesExecutionClient: Bool = false,
        usesOMS: Bool = false,
        connectsBrokerGateway: Bool = false
    ) throws {
        self.contextID = contextID
        self.accountIdentity = accountIdentity
        self.sourceIdentity = try Self.validatedText(
            sourceIdentity,
            field: "traderAccountContext.sourceIdentity"
        )
        self.sourceKind = sourceKind
        self.futureRealAccountGate = futureRealAccountGate
        self.portfolioRelationship = try Self.validatedText(
            portfolioRelationship,
            field: "traderAccountContext.portfolioRelationship"
        )
        self.riskEngineRelationship = try Self.validatedText(
            riskEngineRelationship,
            field: "traderAccountContext.riskEngineRelationship"
        )
        self.executionEngineRelationship = try Self.validatedText(
            executionEngineRelationship,
            field: "traderAccountContext.executionEngineRelationship"
        )
        self.validationAnchors = validationAnchors
        self.ownsCash = ownsCash
        self.ownsPositions = ownsPositions
        self.ownsPnL = ownsPnL
        self.ownsMargin = ownsMargin
        self.ownsLeverage = ownsLeverage
        self.readsBrokerAccountPayload = readsBrokerAccountPayload
        self.callsSignedEndpoint = callsSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.startsPrivateWebSocketRuntime = startsPrivateWebSocketRuntime
        self.implementsAccountSnapshotRuntime = implementsAccountSnapshotRuntime
        self.implementsTraderRuntime = implementsTraderRuntime
        self.implementsLiveRuntime = implementsLiveRuntime
        self.usesExecutionClient = usesExecutionClient
        self.usesOMS = usesOMS
        self.connectsBrokerGateway = connectsBrokerGateway

        try validate()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contextID: try container.decode(Identifier.self, forKey: .contextID),
            accountIdentity: try container.decode(Identifier.self, forKey: .accountIdentity),
            sourceIdentity: try container.decode(String.self, forKey: .sourceIdentity),
            sourceKind: try container.decode(TraderAccountSourceKind.self, forKey: .sourceKind),
            futureRealAccountGate: try container.decode(
                TraderAccountFutureRealAccountGate.self,
                forKey: .futureRealAccountGate
            ),
            portfolioRelationship: try container.decode(String.self, forKey: .portfolioRelationship),
            riskEngineRelationship: try container.decode(String.self, forKey: .riskEngineRelationship),
            executionEngineRelationship: try container.decode(String.self, forKey: .executionEngineRelationship),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            ownsCash: try container.decode(Bool.self, forKey: .ownsCash),
            ownsPositions: try container.decode(Bool.self, forKey: .ownsPositions),
            ownsPnL: try container.decode(Bool.self, forKey: .ownsPnL),
            ownsMargin: try container.decode(Bool.self, forKey: .ownsMargin),
            ownsLeverage: try container.decode(Bool.self, forKey: .ownsLeverage),
            readsBrokerAccountPayload: try container.decode(Bool.self, forKey: .readsBrokerAccountPayload),
            callsSignedEndpoint: try container.decode(Bool.self, forKey: .callsSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            startsPrivateWebSocketRuntime: try container.decode(Bool.self, forKey: .startsPrivateWebSocketRuntime),
            implementsAccountSnapshotRuntime: try container.decode(Bool.self, forKey: .implementsAccountSnapshotRuntime),
            implementsTraderRuntime: try container.decode(Bool.self, forKey: .implementsTraderRuntime),
            implementsLiveRuntime: try container.decode(Bool.self, forKey: .implementsLiveRuntime),
            usesExecutionClient: try container.decode(Bool.self, forKey: .usesExecutionClient),
            usesOMS: try container.decode(Bool.self, forKey: .usesOMS),
            connectsBrokerGateway: try container.decode(Bool.self, forKey: .connectsBrokerGateway)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contextID, forKey: .contextID)
        try container.encode(accountIdentity, forKey: .accountIdentity)
        try container.encode(sourceIdentity, forKey: .sourceIdentity)
        try container.encode(sourceKind, forKey: .sourceKind)
        try container.encode(futureRealAccountGate, forKey: .futureRealAccountGate)
        try container.encode(portfolioRelationship, forKey: .portfolioRelationship)
        try container.encode(riskEngineRelationship, forKey: .riskEngineRelationship)
        try container.encode(executionEngineRelationship, forKey: .executionEngineRelationship)
        try container.encode(validationAnchors, forKey: .validationAnchors)
        try container.encode(ownsCash, forKey: .ownsCash)
        try container.encode(ownsPositions, forKey: .ownsPositions)
        try container.encode(ownsPnL, forKey: .ownsPnL)
        try container.encode(ownsMargin, forKey: .ownsMargin)
        try container.encode(ownsLeverage, forKey: .ownsLeverage)
        try container.encode(readsBrokerAccountPayload, forKey: .readsBrokerAccountPayload)
        try container.encode(callsSignedEndpoint, forKey: .callsSignedEndpoint)
        try container.encode(callsAccountEndpoint, forKey: .callsAccountEndpoint)
        try container.encode(createsListenKey, forKey: .createsListenKey)
        try container.encode(startsPrivateWebSocketRuntime, forKey: .startsPrivateWebSocketRuntime)
        try container.encode(implementsAccountSnapshotRuntime, forKey: .implementsAccountSnapshotRuntime)
        try container.encode(implementsTraderRuntime, forKey: .implementsTraderRuntime)
        try container.encode(implementsLiveRuntime, forKey: .implementsLiveRuntime)
        try container.encode(usesExecutionClient, forKey: .usesExecutionClient)
        try container.encode(usesOMS, forKey: .usesOMS)
        try container.encode(connectsBrokerGateway, forKey: .connectsBrokerGateway)
    }

    /// MTP-206 focused validation anchors，供 XCTest、docs 和后续 MTP-207 validation wiring 复用。
    public static let requiredValidationAnchors = [
        "MTP-206-TRADER-ACCOUNTS-SOURCE-BOUNDARY",
        "MTP-206-ACCOUNT-IDENTITY-SOURCE-FUTURE-GATE",
        "MTP-206-NO-FINANCIAL-STATE-OWNERSHIP",
        "MTP-206-NO-ENDPOINT-LISTENKEY-BROKER-RUNTIME",
        "MTP-206-PORTFOLIO-RISK-EXECUTION-RELATIONSHIP"
    ]

    /// deterministic fixture 只服务本地测试和 PR evidence，不代表真实账户。
    public static let deterministicFixture: TraderAccountContext = {
        do {
            return try TraderAccountContext(
                contextID: try Identifier("mtp-206-trader-account-context"),
                accountIdentity: try Identifier("paper-account:mtp-206"),
                sourceIdentity: "fixture:trader-account-context:mtp-206",
                sourceKind: .fixture,
                portfolioRelationship: "Portfolio read model remains authoritative for financial state",
                riskEngineRelationship: "RiskEngine consumes account context only as local risk evidence",
                executionEngineRelationship: "ExecutionEngine remains paper or simulated boundary evidence"
            )
        } catch {
            preconditionFailure("Invalid deterministic Trader account context fixture: \(error)")
        }
    }()

    /// 证明当前 Accounts 边界只保存 identity / source / future gate。
    public var identitySourceFutureGateBoundaryHeld: Bool {
        validationAnchors == Self.requiredValidationAnchors
            && sourceIdentity.isEmpty == false
            && futureRealAccountGate.authorizesRealAccountRead == false
    }

    /// 证明 Trader/Accounts 不拥有 Portfolio financial state。
    public var noFinancialStateOwnership: Bool {
        ownsCash == false
            && ownsPositions == false
            && ownsPnL == false
            && ownsMargin == false
            && ownsLeverage == false
    }

    /// 证明该 account context 没有 endpoint、listenKey、broker、runtime 或 command-capable path。
    public var noEndpointBrokerRuntimeBoundaryHeld: Bool {
        readsBrokerAccountPayload == false
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && startsPrivateWebSocketRuntime == false
            && implementsAccountSnapshotRuntime == false
            && implementsTraderRuntime == false
            && implementsLiveRuntime == false
            && usesExecutionClient == false
            && usesOMS == false
            && connectsBrokerGateway == false
    }

    /// 证明 Trader/Accounts 与 Portfolio / RiskEngine / ExecutionEngine 的关系仍是只读协调语义。
    public var coordinationRelationshipBoundaryHeld: Bool {
        portfolioRelationship.contains("Portfolio")
            && riskEngineRelationship.contains("RiskEngine")
            && executionEngineRelationship.contains("ExecutionEngine")
            && portfolioRelationship.contains("authoritative")
    }

    /// MTP-206 总边界：identity/source/gate 成立，且没有财务状态、endpoint、broker 或 runtime。
    public var accountContextBoundaryHeld: Bool {
        identitySourceFutureGateBoundaryHeld
            && noFinancialStateOwnership
            && noEndpointBrokerRuntimeBoundaryHeld
            && coordinationRelationshipBoundaryHeld
    }

    private func validate() throws {
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.traderAccountContextMismatch(
                field: "traderAccountContext.validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        try forbid(ownsCash, "ownsCash")
        try forbid(ownsPositions, "ownsPositions")
        try forbid(ownsPnL, "ownsPnL")
        try forbid(ownsMargin, "ownsMargin")
        try forbid(ownsLeverage, "ownsLeverage")
        try forbid(readsBrokerAccountPayload, "readsBrokerAccountPayload")
        try forbid(callsSignedEndpoint, "callsSignedEndpoint")
        try forbid(callsAccountEndpoint, "callsAccountEndpoint")
        try forbid(createsListenKey, "createsListenKey")
        try forbid(startsPrivateWebSocketRuntime, "startsPrivateWebSocketRuntime")
        try forbid(implementsAccountSnapshotRuntime, "implementsAccountSnapshotRuntime")
        try forbid(implementsTraderRuntime, "implementsTraderRuntime")
        try forbid(implementsLiveRuntime, "implementsLiveRuntime")
        try forbid(usesExecutionClient, "usesExecutionClient")
        try forbid(usesOMS, "usesOMS")
        try forbid(connectsBrokerGateway, "connectsBrokerGateway")
    }

    private func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.traderAccountContextForbiddenCapability("traderAccountContext.\(field)")
        }
    }

    private static func validatedText(_ value: String, field: String) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw CoreError.emptyIdentifier(field)
        }
        let normalized = trimmed
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "/", with: "")
        for forbiddenToken in forbiddenTextTokens where normalized.contains(forbiddenToken) {
            throw CoreError.traderAccountContextForbiddenCapability("\(field).\(forbiddenToken)")
        }
        return trimmed
    }

    private static let forbiddenTextTokens = [
        "signedendpoint",
        "accountendpoint",
        "listenkey",
        "privatewebsocket",
        "brokerpayload",
        "brokerstate",
        "accountpayload",
        "runtimeobject",
        "adapterrequest",
        "ordercommand",
        "livecommand",
        "orderform"
    ]

    private enum CodingKeys: String, CodingKey {
        case contextID
        case accountIdentity
        case sourceIdentity
        case sourceKind
        case futureRealAccountGate
        case portfolioRelationship
        case riskEngineRelationship
        case executionEngineRelationship
        case validationAnchors
        case ownsCash
        case ownsPositions
        case ownsPnL
        case ownsMargin
        case ownsLeverage
        case readsBrokerAccountPayload
        case callsSignedEndpoint
        case callsAccountEndpoint
        case createsListenKey
        case startsPrivateWebSocketRuntime
        case implementsAccountSnapshotRuntime
        case implementsTraderRuntime
        case implementsLiveRuntime
        case usesExecutionClient
        case usesOMS
        case connectsBrokerGateway
    }
}
