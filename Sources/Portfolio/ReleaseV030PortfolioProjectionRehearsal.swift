import Database
import DomainModel
import Foundation

/// ReleaseV030PortfolioProjectionRehearsalStrategyKind 固定 v0.3.0 rehearsal 的 active strategy。
///
/// GH-665 只允许 EMA 与 RSI attribution；该枚举不代表 strategy runtime 注册，也不授权新增
/// active concrete strategy。
public enum ReleaseV030PortfolioProjectionRehearsalStrategyKind:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case ema
    case rsi
}

/// ReleaseV030PortfolioProjectionRehearsalRequirement 固定 GH-665 的验收要求。
public enum ReleaseV030PortfolioProjectionRehearsalRequirement:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case upstreamEventStoreReplayRequired = "upstream GH-664 Event Store replay evidence required"
    case spotProjectionRequired = "Spot portfolio projection from rehearsal fill evidence required"
    case perpetualProjectionRequired = "USDs-M Perpetual portfolio projection from rehearsal fill evidence required"
    case strategyAttributionRequired = "EMA and RSI attribution required"
    case noProductionAccountSync = "no production account sync"
    case noRawBrokerPayloadExposure = "no raw broker payload exposure"
}

/// ReleaseV030PortfolioProjectionRehearsalForbiddenCapability 枚举 GH-665 必须保持关闭的能力。
public enum ReleaseV030PortfolioProjectionRehearsalForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case productionTradingDefaultEnabled = "production trading enabled by default"
    case productionEndpointAutoConnect = "production endpoint auto-connect"
    case productionSecretAutoRead = "production secret auto-read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case productionAccountSync = "production account sync"
    case accountEndpointRead = "account endpoint read"
    case brokerPositionSync = "broker position sync"
    case rawBrokerPayloadExposed = "raw broker payload exposed"
    case reconciliationRuntime = "reconciliation runtime"
    case brokerGatewayAccess = "broker gateway access"
    case executionClientAccess = "ExecutionClient access"
    case dashboardCommandSurface = "Dashboard command surface"
    case commandGatewayBypass = "CommandGateway bypass"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV030PortfolioProjectionRehearsalFill 是 GH-665 的本地 fill evidence 输入。
///
/// Fill 只表达 dry-run / testnet rehearsal 已脱敏结果，不保存原始 broker payload，不读取
/// account endpoint，也不触发 portfolio reconciliation runtime。
public struct ReleaseV030PortfolioProjectionRehearsalFill: Codable, Equatable, Sendable {
    public let fillID: Identifier
    public let productType: ProductType
    public let instrumentID: InstrumentIdentity
    public let strategyKind: ReleaseV030PortfolioProjectionRehearsalStrategyKind
    public let sourceReplayEventID: Identifier
    public let sourceReplaySequence: Int
    public let sourceEvidenceAnchor: String
    public let quantity: Quantity
    public let price: Price
    public let feeQuote: Double
    public let signedPositionDelta: Double
    public let notional: Double
    public let filledAt: Date
    public let simulatedOrTestnetEvidence: Bool
    public let rawBrokerPayloadExposed: Bool
    public let productionAccountSynced: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionSynced: Bool

    public var fillHeld: Bool {
        ReleaseV030PortfolioProjectionRehearsalEvidence.requiredProductTypes.contains(productType)
            && instrumentID.productType == productType
            && sourceReplaySequence > 0
            && sourceEvidenceAnchor == ReleaseV030PortfolioProjectionRehearsalEvidence.requiredUpstreamEventStoreAnchor
            && quantity.rawValue > 0
            && price.rawValue > 0
            && feeQuote >= 0
            && notional == quantity.rawValue * price.rawValue
            && simulatedOrTestnetEvidence
            && rawBrokerPayloadExposed == false
            && productionAccountSynced == false
            && accountEndpointRead == false
            && brokerPositionSynced == false
    }

    public init(
        fillID: Identifier,
        productType: ProductType,
        instrumentID: InstrumentIdentity,
        strategyKind: ReleaseV030PortfolioProjectionRehearsalStrategyKind,
        sourceReplayEventID: Identifier,
        sourceReplaySequence: Int,
        sourceEvidenceAnchor: String,
        quantity: Quantity,
        price: Price,
        feeQuote: Double,
        signedPositionDelta: Double,
        filledAt: Date,
        simulatedOrTestnetEvidence: Bool = true,
        rawBrokerPayloadExposed: Bool = false,
        productionAccountSynced: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionSynced: Bool = false
    ) throws {
        guard ReleaseV030PortfolioProjectionRehearsalEvidence.requiredProductTypes.contains(productType),
              instrumentID.productType == productType else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.productType",
                expected: ReleaseV030PortfolioProjectionRehearsalEvidence.requiredProductTypes
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: instrumentID.productType.rawValue
            )
        }
        guard sourceReplaySequence > 0 else {
            throw CoreError.invalidEventSequence(sourceReplaySequence)
        }
        guard sourceEvidenceAnchor == ReleaseV030PortfolioProjectionRehearsalEvidence.requiredUpstreamEventStoreAnchor else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030PortfolioRehearsal.sourceEvidenceAnchor",
                expected: ReleaseV030PortfolioProjectionRehearsalEvidence.requiredUpstreamEventStoreAnchor,
                actual: sourceEvidenceAnchor
            )
        }
        guard quantity.rawValue > 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.quantity",
                expected: "positive rehearsal fill quantity",
                actual: "\(quantity.rawValue)"
            )
        }
        guard feeQuote.isFinite, feeQuote >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.feeQuote",
                expected: "finite non-negative fee",
                actual: "\(feeQuote)"
            )
        }
        guard signedPositionDelta.isFinite, signedPositionDelta != 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.signedPositionDelta",
                expected: "finite non-zero delta",
                actual: "\(signedPositionDelta)"
            )
        }
        guard simulatedOrTestnetEvidence else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.simulatedOrTestnetEvidence",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(rawBrokerPayloadExposed, "rawBrokerPayloadExposed")
        try Self.forbid(productionAccountSynced, "productionAccountSynced")
        try Self.forbid(accountEndpointRead, "accountEndpointRead")
        try Self.forbid(brokerPositionSynced, "brokerPositionSynced")

        self.fillID = fillID
        self.productType = productType
        self.instrumentID = instrumentID
        self.strategyKind = strategyKind
        self.sourceReplayEventID = sourceReplayEventID
        self.sourceReplaySequence = sourceReplaySequence
        self.sourceEvidenceAnchor = sourceEvidenceAnchor
        self.quantity = quantity
        self.price = price
        self.feeQuote = feeQuote
        self.signedPositionDelta = signedPositionDelta
        self.notional = quantity.rawValue * price.rawValue
        self.filledAt = filledAt
        self.simulatedOrTestnetEvidence = simulatedOrTestnetEvidence
        self.rawBrokerPayloadExposed = rawBrokerPayloadExposed
        self.productionAccountSynced = productionAccountSynced
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionSynced = brokerPositionSynced
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("releaseV030PortfolioRehearsal.fill.\(field)")
        }
    }
}

/// ReleaseV030PortfolioProjectionRehearsalProductProjection 是 GH-665 的产品级 portfolio projection。
///
/// Projection 只聚合已脱敏 rehearsal fill，不代表真实账户余额、真实仓位、保证金同步或 broker
/// reconciliation。
public struct ReleaseV030PortfolioProjectionRehearsalProductProjection: Codable, Equatable, Sendable {
    public let projectionID: Identifier
    public let productType: ProductType
    public let instrumentID: InstrumentIdentity
    public let sourceFillIDs: [Identifier]
    public let netPositionQuantity: Double
    public let grossFillQuantity: Double
    public let grossNotional: Double
    public let feeQuote: Double
    public let averageFillPrice: Price
    public let projectedAt: Date
    public let sourceIsRehearsalOnly: Bool
    public let productionAccountSynced: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionSynced: Bool
    public let rawBrokerPayloadExposed: Bool
    public let reconciliationRuntimeExecuted: Bool

    public var projectionHeld: Bool {
        ReleaseV030PortfolioProjectionRehearsalEvidence.requiredProductTypes.contains(productType)
            && instrumentID.productType == productType
            && sourceFillIDs.isEmpty == false
            && netPositionQuantity.isFinite
            && grossFillQuantity > 0
            && grossNotional > 0
            && feeQuote >= 0
            && averageFillPrice.rawValue == grossNotional / grossFillQuantity
            && sourceIsRehearsalOnly
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        productionAccountSynced == false
            && accountEndpointRead == false
            && brokerPositionSynced == false
            && rawBrokerPayloadExposed == false
            && reconciliationRuntimeExecuted == false
    }

    public init(
        projectionID: Identifier,
        productType: ProductType,
        instrumentID: InstrumentIdentity,
        sourceFillIDs: [Identifier],
        netPositionQuantity: Double,
        grossFillQuantity: Double,
        grossNotional: Double,
        feeQuote: Double,
        projectedAt: Date,
        sourceIsRehearsalOnly: Bool = true,
        productionAccountSynced: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionSynced: Bool = false,
        rawBrokerPayloadExposed: Bool = false,
        reconciliationRuntimeExecuted: Bool = false
    ) throws {
        guard ReleaseV030PortfolioProjectionRehearsalEvidence.requiredProductTypes.contains(productType),
              instrumentID.productType == productType else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.productProjection.productType",
                expected: ReleaseV030PortfolioProjectionRehearsalEvidence.requiredProductTypes
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: instrumentID.productType.rawValue
            )
        }
        guard sourceFillIDs.isEmpty == false else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.productProjection.sourceFillIDs",
                expected: "non-empty rehearsal fill IDs",
                actual: "empty"
            )
        }
        guard netPositionQuantity.isFinite,
              grossFillQuantity.isFinite,
              grossFillQuantity > 0,
              grossNotional.isFinite,
              grossNotional > 0,
              feeQuote.isFinite,
              feeQuote >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.productProjection.amounts",
                expected: "finite positive gross amounts and finite net position",
                actual: "\(netPositionQuantity):\(grossFillQuantity):\(grossNotional):\(feeQuote)"
            )
        }
        guard sourceIsRehearsalOnly else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.productProjection.sourceIsRehearsalOnly",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(productionAccountSynced, "productionAccountSynced")
        try Self.forbid(accountEndpointRead, "accountEndpointRead")
        try Self.forbid(brokerPositionSynced, "brokerPositionSynced")
        try Self.forbid(rawBrokerPayloadExposed, "rawBrokerPayloadExposed")
        try Self.forbid(reconciliationRuntimeExecuted, "reconciliationRuntimeExecuted")

        self.projectionID = projectionID
        self.productType = productType
        self.instrumentID = instrumentID
        self.sourceFillIDs = sourceFillIDs
        self.netPositionQuantity = netPositionQuantity
        self.grossFillQuantity = grossFillQuantity
        self.grossNotional = grossNotional
        self.feeQuote = feeQuote
        self.averageFillPrice = try Price(
            grossNotional / grossFillQuantity,
            field: "releaseV030PortfolioRehearsal.productProjection.averageFillPrice"
        )
        self.projectedAt = projectedAt
        self.sourceIsRehearsalOnly = sourceIsRehearsalOnly
        self.productionAccountSynced = productionAccountSynced
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionSynced = brokerPositionSynced
        self.rawBrokerPayloadExposed = rawBrokerPayloadExposed
        self.reconciliationRuntimeExecuted = reconciliationRuntimeExecuted
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability(
                "releaseV030PortfolioRehearsal.productProjection.\(field)"
            )
        }
    }
}

/// ReleaseV030PortfolioProjectionRehearsalStrategyAttribution 是 GH-665 的策略归因 evidence。
public struct ReleaseV030PortfolioProjectionRehearsalStrategyAttribution: Codable, Equatable, Sendable {
    public let attributionID: Identifier
    public let strategyKind: ReleaseV030PortfolioProjectionRehearsalStrategyKind
    public let sourceFillIDs: [Identifier]
    public let productTypes: [ProductType]
    public let attributedNotional: Double
    public let attributedFeeQuote: Double
    public let visibleInEvidence: Bool
    public let productionAccountSynced: Bool
    public let rawBrokerPayloadExposed: Bool

    public var attributionHeld: Bool {
        sourceFillIDs.isEmpty == false
            && productTypes.isEmpty == false
            && Set(productTypes).isSubset(of: Set(ReleaseV030PortfolioProjectionRehearsalEvidence.requiredProductTypes))
            && attributedNotional > 0
            && attributedFeeQuote >= 0
            && visibleInEvidence
            && productionAccountSynced == false
            && rawBrokerPayloadExposed == false
    }

    public init(
        attributionID: Identifier,
        strategyKind: ReleaseV030PortfolioProjectionRehearsalStrategyKind,
        sourceFillIDs: [Identifier],
        productTypes: [ProductType],
        attributedNotional: Double,
        attributedFeeQuote: Double,
        visibleInEvidence: Bool = true,
        productionAccountSynced: Bool = false,
        rawBrokerPayloadExposed: Bool = false
    ) throws {
        guard sourceFillIDs.isEmpty == false,
              productTypes.isEmpty == false,
              Set(productTypes).isSubset(of: Set(ReleaseV030PortfolioProjectionRehearsalEvidence.requiredProductTypes)),
              attributedNotional.isFinite,
              attributedNotional > 0,
              attributedFeeQuote.isFinite,
              attributedFeeQuote >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.attribution",
                expected: "non-empty fills/products and finite positive notional",
                actual: "\(sourceFillIDs.count):\(productTypes.map(\.rawValue).joined(separator: ",")):\(attributedNotional)"
            )
        }
        guard visibleInEvidence else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.visibleInEvidence",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(productionAccountSynced, "productionAccountSynced")
        try Self.forbid(rawBrokerPayloadExposed, "rawBrokerPayloadExposed")

        self.attributionID = attributionID
        self.strategyKind = strategyKind
        self.sourceFillIDs = sourceFillIDs
        self.productTypes = productTypes
        self.attributedNotional = attributedNotional
        self.attributedFeeQuote = attributedFeeQuote
        self.visibleInEvidence = visibleInEvidence
        self.productionAccountSynced = productionAccountSynced
        self.rawBrokerPayloadExposed = rawBrokerPayloadExposed
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability(
                "releaseV030PortfolioRehearsal.attribution.\(field)"
            )
        }
    }
}

/// ReleaseV030PortfolioProjectionRehearsalEvidence 汇总 GH-665 的 Portfolio projection rehearsal。
public struct ReleaseV030PortfolioProjectionRehearsalEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueID: Identifier
    public let downstreamIssueID: Identifier
    public let canonicalQueueRange: String
    public let projectName: String
    public let releaseVersion: String
    public let upstreamEventStoreAnchor: String
    public let upstreamReplayState: ReleaseV030EventStoreRehearsalReplayState
    public let fills: [ReleaseV030PortfolioProjectionRehearsalFill]
    public let productProjections: [ReleaseV030PortfolioProjectionRehearsalProductProjection]
    public let strategyAttributions: [ReleaseV030PortfolioProjectionRehearsalStrategyAttribution]
    public let requirements: [ReleaseV030PortfolioProjectionRehearsalRequirement]
    public let forbiddenCapabilities: [ReleaseV030PortfolioProjectionRehearsalForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let spotProjectionUpdated: Bool
    public let perpetualProjectionUpdated: Bool
    public let strategyAttributionVisible: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool
    public let productionAccountSyncEnabled: Bool
    public let accountEndpointReadEnabled: Bool
    public let brokerPositionSyncEnabled: Bool
    public let rawBrokerPayloadExposed: Bool
    public let reconciliationRuntimeExecuted: Bool
    public let dashboardCommandSurfaceExposed: Bool
    public let commandGatewayBypassAllowed: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-665"
            && upstreamIssueID.rawValue == "GH-664"
            && downstreamIssueID.rawValue == "GH-666"
            && canonicalQueueRange == "GH-657..GH-670"
            && projectName == Self.requiredProjectName
            && releaseVersion == "v0.3.0"
            && upstreamEventStoreAnchor == Self.requiredUpstreamEventStoreAnchor
            && upstreamReplayState.replayStateHeld
            && fills.count == 4
            && fills.allSatisfy(\.fillHeld)
            && productProjections.count == 2
            && productProjections.allSatisfy(\.projectionHeld)
            && Set(productProjections.map(\.productType)) == Set(Self.requiredProductTypes)
            && Set(strategyAttributions.map(\.strategyKind)) == Set(Self.requiredStrategies)
            && strategyAttributions.allSatisfy(\.attributionHeld)
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && spotProjectionUpdated
            && perpetualProjectionUpdated
            && strategyAttributionVisible
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointAutoConnectEnabled == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
            && productionAccountSyncEnabled == false
            && accountEndpointReadEnabled == false
            && brokerPositionSyncEnabled == false
            && rawBrokerPayloadExposed == false
            && reconciliationRuntimeExecuted == false
            && dashboardCommandSurfaceExposed == false
            && commandGatewayBypassAllowed == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-665-release-v0.3.0-portfolio-projection-rehearsal"),
        issueID: Identifier = Identifier.constant("GH-665"),
        upstreamIssueID: Identifier = Identifier.constant("GH-664"),
        downstreamIssueID: Identifier = Identifier.constant("GH-666"),
        canonicalQueueRange: String = "GH-657..GH-670",
        projectName: String = Self.requiredProjectName,
        releaseVersion: String = "v0.3.0",
        upstreamEventStoreAnchor: String = Self.requiredUpstreamEventStoreAnchor,
        upstreamReplayState: ReleaseV030EventStoreRehearsalReplayState,
        fills: [ReleaseV030PortfolioProjectionRehearsalFill],
        productProjections: [ReleaseV030PortfolioProjectionRehearsalProductProjection],
        strategyAttributions: [ReleaseV030PortfolioProjectionRehearsalStrategyAttribution],
        requirements: [ReleaseV030PortfolioProjectionRehearsalRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV030PortfolioProjectionRehearsalForbiddenCapability] = Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        spotProjectionUpdated: Bool = true,
        perpetualProjectionUpdated: Bool = true,
        strategyAttributionVisible: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false,
        productionAccountSyncEnabled: Bool = false,
        accountEndpointReadEnabled: Bool = false,
        brokerPositionSyncEnabled: Bool = false,
        rawBrokerPayloadExposed: Bool = false,
        reconciliationRuntimeExecuted: Bool = false,
        dashboardCommandSurfaceExposed: Bool = false,
        commandGatewayBypassAllowed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateRequired(
            canonicalQueueRange: canonicalQueueRange,
            projectName: projectName,
            releaseVersion: releaseVersion,
            upstreamEventStoreAnchor: upstreamEventStoreAnchor,
            requirements: requirements,
            forbiddenCapabilities: forbiddenCapabilities,
            validationAnchors: validationAnchors,
            requiredValidationCommands: requiredValidationCommands
        )
        try Self.validateBoundary(
            spotProjectionUpdated: spotProjectionUpdated,
            perpetualProjectionUpdated: perpetualProjectionUpdated,
            strategyAttributionVisible: strategyAttributionVisible,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointAutoConnectEnabled: productionEndpointAutoConnectEnabled,
            productionSecretAutoReadEnabled: productionSecretAutoReadEnabled,
            productionOrderSubmissionEnabled: productionOrderSubmissionEnabled,
            productionCutoverAuthorized: productionCutoverAuthorized,
            productionAccountSyncEnabled: productionAccountSyncEnabled,
            accountEndpointReadEnabled: accountEndpointReadEnabled,
            brokerPositionSyncEnabled: brokerPositionSyncEnabled,
            rawBrokerPayloadExposed: rawBrokerPayloadExposed,
            reconciliationRuntimeExecuted: reconciliationRuntimeExecuted,
            dashboardCommandSurfaceExposed: dashboardCommandSurfaceExposed,
            commandGatewayBypassAllowed: commandGatewayBypassAllowed,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueID = upstreamIssueID
        self.downstreamIssueID = downstreamIssueID
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.releaseVersion = releaseVersion
        self.upstreamEventStoreAnchor = upstreamEventStoreAnchor
        self.upstreamReplayState = upstreamReplayState
        self.fills = fills
        self.productProjections = productProjections
        self.strategyAttributions = strategyAttributions
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.spotProjectionUpdated = spotProjectionUpdated
        self.perpetualProjectionUpdated = perpetualProjectionUpdated
        self.strategyAttributionVisible = strategyAttributionVisible
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.productionAccountSyncEnabled = productionAccountSyncEnabled
        self.accountEndpointReadEnabled = accountEndpointReadEnabled
        self.brokerPositionSyncEnabled = brokerPositionSyncEnabled
        self.rawBrokerPayloadExposed = rawBrokerPayloadExposed
        self.reconciliationRuntimeExecuted = reconciliationRuntimeExecuted
        self.dashboardCommandSurfaceExposed = dashboardCommandSurfaceExposed
        self.commandGatewayBypassAllowed = commandGatewayBypassAllowed
        self.startsNextMilestone = startsNextMilestone
    }

    public static let requiredProjectName = "MTPRO Release v0.3.0 Runtime Rehearsal v1"
    public static let requiredUpstreamEventStoreAnchor =
        "TVM-RELEASE-V030-EVENT-STORE-REHEARSAL-EVIDENCE"
    /// GH-685 固定 v0.3.x rehearsal product boundary 为显式 release 常量。
    ///
    /// 不能用产品枚举全集作为 release 期望，否则未来新增 product type 时会
    /// 静默扩大 v0.3.x evidence 范围。
    public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]
    /// GH-685 固定 v0.3.x rehearsal strategy boundary 为显式 release 常量。
    public static let requiredStrategies: [ReleaseV030PortfolioProjectionRehearsalStrategyKind] = [.ema, .rsi]
    public static let requiredRequirements = ReleaseV030PortfolioProjectionRehearsalRequirement.allCases
    public static let requiredForbiddenCapabilities =
        ReleaseV030PortfolioProjectionRehearsalForbiddenCapability.allCases
    public static let requiredValidationAnchors = [
        "V030-09-PORTFOLIO-PROJECTION-REHEARSAL",
        "V030-09-SPOT-PORTFOLIO-PROJECTION",
        "V030-09-PERP-PORTFOLIO-PROJECTION",
        "V030-09-EMA-RSI-ATTRIBUTION",
        "V030-09-NO-PRODUCTION-ACCOUNT-SYNC",
        "TVM-RELEASE-V030-PORTFOLIO-PROJECTION-REHEARSAL"
    ]
    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH665PortfolioProjectionRehearsalProjectsSpotPerpAndAttributionFromReplayEvidence",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV030PortfolioProjectionRehearsal 生成 GH-665 deterministic Portfolio projection evidence。
public enum ReleaseV030PortfolioProjectionRehearsal {
    public static func deterministicEvidence(
        upstreamEventStoreEvidence: ReleaseV030EventStoreRehearsalEvidence? = nil
    ) throws -> ReleaseV030PortfolioProjectionRehearsalEvidence {
        let upstream: ReleaseV030EventStoreRehearsalEvidence
        if let upstreamEventStoreEvidence {
            upstream = upstreamEventStoreEvidence
        } else {
            upstream = try ReleaseV030EventStoreRehearsal.deterministicEvidence()
        }
        guard upstream.evidenceHeld,
              upstream.downstreamIssueID.rawValue == "GH-665",
              upstream.validationAnchors.contains(
                  ReleaseV030PortfolioProjectionRehearsalEvidence.requiredUpstreamEventStoreAnchor
              ) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV030PortfolioRehearsal.upstreamEventStoreEvidence",
                expected: "GH-664 held Event Store replay evidence for GH-665",
                actual: upstream.downstreamIssueID.rawValue
            )
        }

        let fills = try deterministicFills(upstream: upstream)
        return try ReleaseV030PortfolioProjectionRehearsalEvidence(
            upstreamReplayState: upstream.replayState,
            fills: fills,
            productProjections: try productProjections(from: fills),
            strategyAttributions: try strategyAttributions(from: fills)
        )
    }

    public static func productionAccountSyncRejected() throws -> Bool {
        let upstream = try ReleaseV030EventStoreRehearsal.deterministicEvidence()
        let replayRecord = try unwrap(
            upstream.records.last,
            field: "releaseV030PortfolioRehearsal.productionAccountSyncRejected.replayRecord"
        )
        do {
            _ = try ReleaseV030PortfolioProjectionRehearsalFill(
                fillID: Identifier.constant("gh-665-production-account-sync-rejected"),
                productType: .spot,
                instrumentID: InstrumentIdentity.binance(productType: .spot, symbol: Symbol.constant("BTCUSDT")),
                strategyKind: .ema,
                sourceReplayEventID: replayRecord.eventID,
                sourceReplaySequence: replayRecord.sequence,
                sourceEvidenceAnchor: ReleaseV030PortfolioProjectionRehearsalEvidence.requiredUpstreamEventStoreAnchor,
                quantity: try Quantity(0.10, field: "releaseV030PortfolioRehearsal.rejected.quantity"),
                price: try Price(43_000, field: "releaseV030PortfolioRehearsal.rejected.price"),
                feeQuote: 1.20,
                signedPositionDelta: 0.10,
                filledAt: Date(timeIntervalSince1970: 1_704_068_800),
                productionAccountSynced: true
            )
            return false
        } catch CoreError.paperPortfolioProjectionForbiddenCapability(
            "releaseV030PortfolioRehearsal.fill.productionAccountSynced"
        ) {
            return true
        }
    }

    private static func deterministicFills(
        upstream: ReleaseV030EventStoreRehearsalEvidence
    ) throws -> [ReleaseV030PortfolioProjectionRehearsalFill] {
        let replayRecord = try unwrap(
            upstream.records.last,
            field: "releaseV030PortfolioRehearsal.replayRecord"
        )
        let btc = Symbol.constant("BTCUSDT")
        let baseDate = Date(timeIntervalSince1970: 1_704_068_800)
        let specs: [(ProductType, ReleaseV030PortfolioProjectionRehearsalStrategyKind, Double, Double, Double, Double)] = [
            (.spot, .ema, 0.10, 43_000, 1.20, 0.10),
            (.spot, .rsi, 0.05, 43_100, 0.65, -0.05),
            (.usdsPerpetual, .ema, 0.20, 43_050, 1.55, 0.20),
            (.usdsPerpetual, .rsi, 0.08, 43_020, 0.72, -0.08)
        ]
        return try specs.enumerated().map { index, spec in
            try ReleaseV030PortfolioProjectionRehearsalFill(
                fillID: Identifier.constant("gh-665-\(spec.0.rawValue)-\(spec.1.rawValue)-fill-\(index + 1)"),
                productType: spec.0,
                instrumentID: InstrumentIdentity.binance(productType: spec.0, symbol: btc),
                strategyKind: spec.1,
                sourceReplayEventID: replayRecord.eventID,
                sourceReplaySequence: replayRecord.sequence,
                sourceEvidenceAnchor: ReleaseV030PortfolioProjectionRehearsalEvidence.requiredUpstreamEventStoreAnchor,
                quantity: Quantity(spec.2, field: "releaseV030PortfolioRehearsal.fill.quantity"),
                price: Price(spec.3, field: "releaseV030PortfolioRehearsal.fill.price"),
                feeQuote: spec.4,
                signedPositionDelta: spec.5,
                filledAt: baseDate.addingTimeInterval(TimeInterval(index))
            )
        }
    }

    private static func productProjections(
        from fills: [ReleaseV030PortfolioProjectionRehearsalFill]
    ) throws -> [ReleaseV030PortfolioProjectionRehearsalProductProjection] {
        try ReleaseV030PortfolioProjectionRehearsalEvidence.requiredProductTypes.map { productType in
            let productFills = fills.filter { $0.productType == productType }
            let instrument = try unwrap(
                productFills.first?.instrumentID,
                field: "releaseV030PortfolioRehearsal.productProjection.instrument"
            )
            let grossFillQuantity = productFills.reduce(0) { $0 + $1.quantity.rawValue }
            let grossNotional = productFills.reduce(0) { $0 + $1.notional }
            return try ReleaseV030PortfolioProjectionRehearsalProductProjection(
                projectionID: Identifier.constant("gh-665-\(productType.rawValue)-portfolio-projection"),
                productType: productType,
                instrumentID: instrument,
                sourceFillIDs: productFills.map(\.fillID),
                netPositionQuantity: productFills.reduce(0) { $0 + $1.signedPositionDelta },
                grossFillQuantity: grossFillQuantity,
                grossNotional: grossNotional,
                feeQuote: productFills.reduce(0) { $0 + $1.feeQuote },
                projectedAt: Date(timeIntervalSince1970: 1_704_068_900)
            )
        }
    }

    private static func strategyAttributions(
        from fills: [ReleaseV030PortfolioProjectionRehearsalFill]
    ) throws -> [ReleaseV030PortfolioProjectionRehearsalStrategyAttribution] {
        try ReleaseV030PortfolioProjectionRehearsalEvidence.requiredStrategies.map { strategyKind in
            let strategyFills = fills.filter { $0.strategyKind == strategyKind }
            return try ReleaseV030PortfolioProjectionRehearsalStrategyAttribution(
                attributionID: Identifier.constant("gh-665-\(strategyKind.rawValue)-attribution"),
                strategyKind: strategyKind,
                sourceFillIDs: strategyFills.map(\.fillID),
                productTypes: Array(Set(strategyFills.map(\.productType))).sorted { $0.rawValue < $1.rawValue },
                attributedNotional: strategyFills.reduce(0) { $0 + $1.notional },
                attributedFeeQuote: strategyFills.reduce(0) { $0 + $1.feeQuote }
            )
        }
    }
}

private extension ReleaseV030PortfolioProjectionRehearsalEvidence {
    static func validateRequired(
        canonicalQueueRange: String,
        projectName: String,
        releaseVersion: String,
        upstreamEventStoreAnchor: String,
        requirements: [ReleaseV030PortfolioProjectionRehearsalRequirement],
        forbiddenCapabilities: [ReleaseV030PortfolioProjectionRehearsalForbiddenCapability],
        validationAnchors: [String],
        requiredValidationCommands: [String]
    ) throws {
        let checks: [(String, Bool, String, String)] = [
            ("canonicalQueueRange", canonicalQueueRange == "GH-657..GH-670", "GH-657..GH-670", canonicalQueueRange),
            ("projectName", projectName == requiredProjectName, requiredProjectName, projectName),
            ("releaseVersion", releaseVersion == "v0.3.0", "v0.3.0", releaseVersion),
            (
                "upstreamEventStoreAnchor",
                upstreamEventStoreAnchor == requiredUpstreamEventStoreAnchor,
                requiredUpstreamEventStoreAnchor,
                upstreamEventStoreAnchor
            ),
            (
                "requirements",
                requirements == requiredRequirements,
                requiredRequirements.map(\.rawValue).joined(separator: ","),
                requirements.map(\.rawValue).joined(separator: ",")
            ),
            (
                "forbiddenCapabilities",
                forbiddenCapabilities == requiredForbiddenCapabilities,
                requiredForbiddenCapabilities.map(\.rawValue).joined(separator: ","),
                forbiddenCapabilities.map(\.rawValue).joined(separator: ",")
            ),
            (
                "validationAnchors",
                validationAnchors == requiredValidationAnchors,
                requiredValidationAnchors.joined(separator: ","),
                validationAnchors.joined(separator: ",")
            ),
            (
                "requiredValidationCommands",
                requiredValidationCommands == Self.requiredValidationCommands,
                Self.requiredValidationCommands.joined(separator: ","),
                requiredValidationCommands.joined(separator: ",")
            )
        ]

        for (field, isValid, expected, actual) in checks where isValid == false {
            throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: expected, actual: actual)
        }
    }

    static func validateBoundary(
        spotProjectionUpdated: Bool,
        perpetualProjectionUpdated: Bool,
        strategyAttributionVisible: Bool,
        productionTradingEnabledByDefault: Bool,
        productionEndpointAutoConnectEnabled: Bool,
        productionSecretAutoReadEnabled: Bool,
        productionOrderSubmissionEnabled: Bool,
        productionCutoverAuthorized: Bool,
        productionAccountSyncEnabled: Bool,
        accountEndpointReadEnabled: Bool,
        brokerPositionSyncEnabled: Bool,
        rawBrokerPayloadExposed: Bool,
        reconciliationRuntimeExecuted: Bool,
        dashboardCommandSurfaceExposed: Bool,
        commandGatewayBypassAllowed: Bool,
        startsNextMilestone: Bool
    ) throws {
        guard spotProjectionUpdated, perpetualProjectionUpdated, strategyAttributionVisible else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV030PortfolioRehearsal.acceptance",
                expected: "spot/perp projection and strategy attribution visible",
                actual: "\(spotProjectionUpdated):\(perpetualProjectionUpdated):\(strategyAttributionVisible)"
            )
        }
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointAutoConnectEnabled", productionEndpointAutoConnectEnabled),
            ("productionSecretAutoReadEnabled", productionSecretAutoReadEnabled),
            ("productionOrderSubmissionEnabled", productionOrderSubmissionEnabled),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("productionAccountSyncEnabled", productionAccountSyncEnabled),
            ("accountEndpointReadEnabled", accountEndpointReadEnabled),
            ("brokerPositionSyncEnabled", brokerPositionSyncEnabled),
            ("rawBrokerPayloadExposed", rawBrokerPayloadExposed),
            ("reconciliationRuntimeExecuted", reconciliationRuntimeExecuted),
            ("dashboardCommandSurfaceExposed", dashboardCommandSurfaceExposed),
            ("commandGatewayBypassAllowed", commandGatewayBypassAllowed),
            ("startsNextMilestone", startsNextMilestone)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("releaseV030PortfolioRehearsal.\(field)")
        }
    }
}

private func unwrap<T>(_ value: T?, field: String) throws -> T {
    guard let value else {
        throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "present", actual: "nil")
    }
    return value
}
