import Database
import DomainModel
import Foundation

/// ReleaseV040PortfolioReplayProjectionRequirement 固定 GH-704 的 Portfolio replay projection 验收要求。
public enum ReleaseV040PortfolioReplayProjectionRequirement:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case upstreamEventStoreRunJournalRequired = "upstream GH-703 Event Store run journal required"
    case replayDerivedFillsRequired = "replay-derived fill evidence required"
    case spotPerpProjectionRequired = "Spot and USDs-M Perpetual projection required"
    case pnlMarginLikeMetricsRequired = "PnL-like and margin-like rehearsal metrics required"
    case readModelOnlyProjectionRequired = "read-model-only projection required"
    case noRealAccountRead = "no real account read"
}

/// ReleaseV040PortfolioReplayProjectionForbiddenCapability 枚举 GH-704 必须保持关闭的能力。
public enum ReleaseV040PortfolioReplayProjectionForbiddenCapability:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case productionTradingDefaultEnabled = "production trading enabled by default"
    case productionEndpointConnection = "production endpoint connection"
    case productionSecretRead = "production secret read"
    case productionOrderSubmission = "production order submission"
    case productionCutoverAuthorization = "production cutover authorization"
    case realAccountStateSync = "real account state sync"
    case accountEndpointRead = "account endpoint read"
    case brokerPositionRead = "broker position read"
    case brokerMarginRead = "broker margin read"
    case brokerLeverageRead = "broker leverage read"
    case realPnLRead = "real PnL read"
    case rawBrokerPayloadStored = "raw broker payload stored"
    case reconciliationRuntime = "reconciliation runtime"
    case brokerGatewayAccess = "broker gateway access"
    case executionClientAccess = "ExecutionClient access"
    case dashboardCommandSurface = "Dashboard command surface"
    case startsNextMilestone = "next milestone auto-start"
}

/// ReleaseV040PortfolioReplayFillEvidence 是 GH-704 的 replay-derived fill-like 输入。
///
/// Fill evidence 只从 GH-703 run journal record 派生，用于 Portfolio read model projection；
/// 它不是 broker fill、不是真实 account position，也不触发 reconciliation runtime。
public struct ReleaseV040PortfolioReplayFillEvidence: Codable, Equatable, Sendable {
    public let fillID: Identifier
    public let runID: Identifier
    public let productType: ProductType
    public let instrumentID: InstrumentIdentity
    public let strategy: ReleaseV040RehearsalStrategyKind
    public let sourceRunJournalRecordID: Identifier
    public let sourceOMSRecordID: Identifier
    public let sourceExecutionClientRecordID: Identifier
    public let sourcePortfolioRecordID: Identifier
    public let sourceReplaySequence: Int
    public let quantity: Quantity
    public let price: Price
    public let markPrice: Price
    public let feeQuote: Double
    public let signedPositionDelta: Double
    public let notional: Double
    public let projectedPnLLike: Double
    public let marginLikeRequirement: Double
    public let filledAt: Date
    public let sourceIsReplayOnly: Bool
    public let productionAccountSynced: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionRead: Bool
    public let brokerMarginRead: Bool
    public let brokerLeverageRead: Bool
    public let realPnLRead: Bool
    public let rawBrokerPayloadStored: Bool

    public var fillHeld: Bool {
        ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes.contains(productType)
            && ReleaseV040PortfolioReplayProjectionEvidence.requiredStrategies.contains(strategy)
            && instrumentID.productType == productType
            && sourceReplaySequence > 0
            && quantity.rawValue > 0
            && price.rawValue > 0
            && markPrice.rawValue > 0
            && feeQuote >= 0
            && signedPositionDelta.isFinite
            && signedPositionDelta != 0
            && notional == quantity.rawValue * price.rawValue
            && projectedPnLLike == (markPrice.rawValue - price.rawValue) * signedPositionDelta
            && marginLikeRequirement >= 0
            && sourceIsReplayOnly
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        productionAccountSynced == false
            && accountEndpointRead == false
            && brokerPositionRead == false
            && brokerMarginRead == false
            && brokerLeverageRead == false
            && realPnLRead == false
            && rawBrokerPayloadStored == false
    }

    public init(
        fillID: Identifier,
        runID: Identifier,
        productType: ProductType,
        instrumentID: InstrumentIdentity,
        strategy: ReleaseV040RehearsalStrategyKind,
        sourceRunJournalRecordID: Identifier,
        sourceOMSRecordID: Identifier,
        sourceExecutionClientRecordID: Identifier,
        sourcePortfolioRecordID: Identifier,
        sourceReplaySequence: Int,
        quantity: Quantity,
        price: Price,
        markPrice: Price,
        feeQuote: Double,
        signedPositionDelta: Double,
        marginRate: Double,
        filledAt: Date,
        sourceIsReplayOnly: Bool = true,
        productionAccountSynced: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionRead: Bool = false,
        brokerMarginRead: Bool = false,
        brokerLeverageRead: Bool = false,
        realPnLRead: Bool = false,
        rawBrokerPayloadStored: Bool = false
    ) throws {
        guard ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes.contains(productType),
              instrumentID.productType == productType else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV040PortfolioReplay.fill.productType",
                expected: ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: instrumentID.productType.rawValue
            )
        }
        guard ReleaseV040PortfolioReplayProjectionEvidence.requiredStrategies.contains(strategy) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040PortfolioReplay.fill.strategy",
                expected: ReleaseV040PortfolioReplayProjectionEvidence.requiredStrategies
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: strategy.rawValue
            )
        }
        guard sourceReplaySequence > 0 else {
            throw CoreError.invalidEventSequence(sourceReplaySequence)
        }
        guard quantity.rawValue > 0,
              price.rawValue > 0,
              markPrice.rawValue > 0,
              feeQuote.isFinite,
              feeQuote >= 0,
              signedPositionDelta.isFinite,
              signedPositionDelta != 0,
              marginRate.isFinite,
              marginRate >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV040PortfolioReplay.fill.amounts",
                expected: "positive replay quantity/price and finite margin-like inputs",
                actual: "\(quantity.rawValue):\(price.rawValue):\(markPrice.rawValue):\(marginRate)"
            )
        }
        guard sourceIsReplayOnly else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV040PortfolioReplay.fill.sourceIsReplayOnly",
                expected: "true",
                actual: "false"
            )
        }
        try Self.forbid(productionAccountSynced, "productionAccountSynced")
        try Self.forbid(accountEndpointRead, "accountEndpointRead")
        try Self.forbid(brokerPositionRead, "brokerPositionRead")
        try Self.forbid(brokerMarginRead, "brokerMarginRead")
        try Self.forbid(brokerLeverageRead, "brokerLeverageRead")
        try Self.forbid(realPnLRead, "realPnLRead")
        try Self.forbid(rawBrokerPayloadStored, "rawBrokerPayloadStored")

        let resolvedNotional = quantity.rawValue * price.rawValue
        self.fillID = fillID
        self.runID = runID
        self.productType = productType
        self.instrumentID = instrumentID
        self.strategy = strategy
        self.sourceRunJournalRecordID = sourceRunJournalRecordID
        self.sourceOMSRecordID = sourceOMSRecordID
        self.sourceExecutionClientRecordID = sourceExecutionClientRecordID
        self.sourcePortfolioRecordID = sourcePortfolioRecordID
        self.sourceReplaySequence = sourceReplaySequence
        self.quantity = quantity
        self.price = price
        self.markPrice = markPrice
        self.feeQuote = feeQuote
        self.signedPositionDelta = signedPositionDelta
        self.notional = resolvedNotional
        self.projectedPnLLike = (markPrice.rawValue - price.rawValue) * signedPositionDelta
        self.marginLikeRequirement = resolvedNotional * marginRate
        self.filledAt = filledAt
        self.sourceIsReplayOnly = sourceIsReplayOnly
        self.productionAccountSynced = productionAccountSynced
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionRead = brokerPositionRead
        self.brokerMarginRead = brokerMarginRead
        self.brokerLeverageRead = brokerLeverageRead
        self.realPnLRead = realPnLRead
        self.rawBrokerPayloadStored = rawBrokerPayloadStored
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("releaseV040PortfolioReplay.fill.\(field)")
        }
    }
}

/// ReleaseV040PortfolioReplayProductProjection 是 GH-704 的产品级 read model projection。
public struct ReleaseV040PortfolioReplayProductProjection: Codable, Equatable, Sendable {
    public let projectionID: Identifier
    public let runID: Identifier
    public let productType: ProductType
    public let instrumentID: InstrumentIdentity
    public let sourceFillIDs: [Identifier]
    public let sourceReplaySequences: [Int]
    public let netPositionQuantity: Double
    public let grossReplayQuantity: Double
    public let grossExposure: Double
    public let averageReplayPrice: Price
    public let projectedPnLLike: Double
    public let marginLikeRequirement: Double
    public let projectedAt: Date
    public let sourceIsReplayOnly: Bool
    public let readModelOnly: Bool
    public let productionAccountSynced: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionRead: Bool
    public let realPnLRead: Bool
    public let reconciliationRuntimeExecuted: Bool
    public let rawBrokerPayloadStored: Bool

    public var projectionHeld: Bool {
        ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes.contains(productType)
            && instrumentID.productType == productType
            && sourceFillIDs.isEmpty == false
            && sourceReplaySequences.isEmpty == false
            && netPositionQuantity.isFinite
            && grossReplayQuantity > 0
            && grossExposure > 0
            && averageReplayPrice.rawValue == grossExposure / grossReplayQuantity
            && averageReplayPrice.rawValue > 0
            && projectedPnLLike.isFinite
            && marginLikeRequirement >= 0
            && sourceIsReplayOnly
            && readModelOnly
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        productionAccountSynced == false
            && accountEndpointRead == false
            && brokerPositionRead == false
            && realPnLRead == false
            && reconciliationRuntimeExecuted == false
            && rawBrokerPayloadStored == false
    }

    public init(
        projectionID: Identifier,
        runID: Identifier,
        productType: ProductType,
        instrumentID: InstrumentIdentity,
        sourceFillIDs: [Identifier],
        sourceReplaySequences: [Int],
        netPositionQuantity: Double,
        grossReplayQuantity: Double,
        grossExposure: Double,
        projectedPnLLike: Double,
        marginLikeRequirement: Double,
        projectedAt: Date,
        sourceIsReplayOnly: Bool = true,
        readModelOnly: Bool = true,
        productionAccountSynced: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionRead: Bool = false,
        realPnLRead: Bool = false,
        reconciliationRuntimeExecuted: Bool = false,
        rawBrokerPayloadStored: Bool = false
    ) throws {
        guard ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes.contains(productType),
              instrumentID.productType == productType else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV040PortfolioReplay.productProjection.productType",
                expected: ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes
                    .map(\.rawValue)
                    .joined(separator: ","),
                actual: instrumentID.productType.rawValue
            )
        }
        guard sourceFillIDs.isEmpty == false,
              sourceReplaySequences.isEmpty == false,
              netPositionQuantity.isFinite,
              grossReplayQuantity.isFinite,
              grossReplayQuantity > 0,
              grossExposure.isFinite,
              grossExposure > 0,
              projectedPnLLike.isFinite,
              marginLikeRequirement.isFinite,
              marginLikeRequirement >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV040PortfolioReplay.productProjection.amounts",
                expected: "non-empty replay source and finite projection amounts",
                actual: "\(sourceFillIDs.count):\(sourceReplaySequences.count):\(grossReplayQuantity):\(grossExposure)"
            )
        }
        guard sourceIsReplayOnly, readModelOnly else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV040PortfolioReplay.productProjection.readModelOnly",
                expected: "replay-only read model",
                actual: "\(sourceIsReplayOnly):\(readModelOnly)"
            )
        }
        try Self.forbid(productionAccountSynced, "productionAccountSynced")
        try Self.forbid(accountEndpointRead, "accountEndpointRead")
        try Self.forbid(brokerPositionRead, "brokerPositionRead")
        try Self.forbid(realPnLRead, "realPnLRead")
        try Self.forbid(reconciliationRuntimeExecuted, "reconciliationRuntimeExecuted")
        try Self.forbid(rawBrokerPayloadStored, "rawBrokerPayloadStored")

        self.projectionID = projectionID
        self.runID = runID
        self.productType = productType
        self.instrumentID = instrumentID
        self.sourceFillIDs = sourceFillIDs
        self.sourceReplaySequences = sourceReplaySequences
        self.netPositionQuantity = netPositionQuantity
        self.grossReplayQuantity = grossReplayQuantity
        self.grossExposure = grossExposure
        self.averageReplayPrice = try Price(
            grossExposure / grossReplayQuantity,
            field: "releaseV040PortfolioReplay.productProjection.averageReplayPrice"
        )
        self.projectedPnLLike = projectedPnLLike
        self.marginLikeRequirement = marginLikeRequirement
        self.projectedAt = projectedAt
        self.sourceIsReplayOnly = sourceIsReplayOnly
        self.readModelOnly = readModelOnly
        self.productionAccountSynced = productionAccountSynced
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionRead = brokerPositionRead
        self.realPnLRead = realPnLRead
        self.reconciliationRuntimeExecuted = reconciliationRuntimeExecuted
        self.rawBrokerPayloadStored = rawBrokerPayloadStored
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw CoreError.paperPortfolioProjectionForbiddenCapability(
                "releaseV040PortfolioReplay.productProjection.\(field)"
            )
        }
    }
}

/// ReleaseV040PortfolioReplayProjectionState 汇总 Dashboard / CLI 后续可按 runID 消费的 projection state。
public struct ReleaseV040PortfolioReplayProjectionState: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let sourceJournalEvidenceID: Identifier
    public let sourceJournalLatestChecksum: String
    public let productProjections: [ReleaseV040PortfolioReplayProductProjection]
    public let totalGrossExposure: Double
    public let totalProjectedPnLLike: Double
    public let totalMarginLikeRequirement: Double
    public let dashboardCLIConsumableByRunID: Bool
    public let readModelOnly: Bool

    public var stateHeld: Bool {
        productProjections.count == ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes.count
            && Set(productProjections.map(\.productType)) ==
                Set(ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes)
            && productProjections.allSatisfy(\.projectionHeld)
            && productProjections.allSatisfy { $0.runID == runID }
            && totalGrossExposure == productProjections.reduce(0) { $0 + $1.grossExposure }
            && totalProjectedPnLLike == productProjections.reduce(0) { $0 + $1.projectedPnLLike }
            && totalMarginLikeRequirement == productProjections.reduce(0) { $0 + $1.marginLikeRequirement }
            && sourceJournalLatestChecksum.hasPrefix("fnv1a64:")
            && dashboardCLIConsumableByRunID
            && readModelOnly
    }

    public init(
        runID: Identifier,
        sourceJournalEvidenceID: Identifier,
        sourceJournalLatestChecksum: String,
        productProjections: [ReleaseV040PortfolioReplayProductProjection],
        dashboardCLIConsumableByRunID: Bool = true,
        readModelOnly: Bool = true
    ) throws {
        guard productProjections.count == ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes.count,
              Set(productProjections.map(\.productType)) ==
              Set(ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes),
              productProjections.allSatisfy(\.projectionHeld),
              productProjections.allSatisfy({ $0.runID == runID }),
              dashboardCLIConsumableByRunID,
              readModelOnly else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV040PortfolioReplay.state",
                expected: "Spot + USDs-M replay projection read model for one runID",
                actual: productProjections.map(\.productType.rawValue).joined(separator: ",")
            )
        }

        self.runID = runID
        self.sourceJournalEvidenceID = sourceJournalEvidenceID
        self.sourceJournalLatestChecksum = sourceJournalLatestChecksum
        self.productProjections = productProjections
        self.totalGrossExposure = productProjections.reduce(0) { $0 + $1.grossExposure }
        self.totalProjectedPnLLike = productProjections.reduce(0) { $0 + $1.projectedPnLLike }
        self.totalMarginLikeRequirement = productProjections.reduce(0) { $0 + $1.marginLikeRequirement }
        self.dashboardCLIConsumableByRunID = dashboardCLIConsumableByRunID
        self.readModelOnly = readModelOnly
    }
}

/// ReleaseV040PortfolioReplayProjectionEvidence 汇总 GH-704 Portfolio replay projection evidence。
public struct ReleaseV040PortfolioReplayProjectionEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let upstreamJournalEvidenceID: Identifier
    public let upstreamReplayState: ReleaseV040EventStoreRunReplayState
    public let replayFills: [ReleaseV040PortfolioReplayFillEvidence]
    public let productProjections: [ReleaseV040PortfolioReplayProductProjection]
    public let projectionState: ReleaseV040PortfolioReplayProjectionState
    public let requirements: [ReleaseV040PortfolioReplayProjectionRequirement]
    public let forbiddenCapabilities: [ReleaseV040PortfolioReplayProjectionForbiddenCapability]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let replayDerived: Bool
    public let spotProjectionUpdated: Bool
    public let perpetualProjectionUpdated: Bool
    public let pnlLikeMetricsProjected: Bool
    public let marginLikeMetricsProjected: Bool
    public let dashboardCLIConsumableByRunID: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretRead: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let realAccountStateSynced: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionRead: Bool
    public let brokerMarginRead: Bool
    public let brokerLeverageRead: Bool
    public let realPnLRead: Bool
    public let rawBrokerPayloadStored: Bool
    public let reconciliationRuntimeExecuted: Bool
    public let brokerGatewayTouched: Bool
    public let executionClientTouched: Bool
    public let dashboardCommandSurfaceExposed: Bool
    public let startsNextMilestone: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-704"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-700", "GH-703"]
            && downstreamIssueIDs.map(\.rawValue) == ["GH-705", "GH-707"]
            && releaseVersion == "v0.4.0"
            && upstreamReplayState.replayStateHeld
            && replayFills.count == 4
            && replayFills.allSatisfy(\.fillHeld)
            && productProjections.count == 2
            && productProjections.allSatisfy(\.projectionHeld)
            && projectionState.stateHeld
            && Set(productProjections.map(\.productType)) == Set(Self.requiredProductTypes)
            && replayDerived
            && spotProjectionUpdated
            && perpetualProjectionUpdated
            && pnlLikeMetricsProjected
            && marginLikeMetricsProjected
            && dashboardCLIConsumableByRunID
            && requirements == Self.requiredRequirements
            && forbiddenCapabilities == Self.requiredForbiddenCapabilities
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && boundaryHeld
    }

    public var boundaryHeld: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretRead == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && realAccountStateSynced == false
            && accountEndpointRead == false
            && brokerPositionRead == false
            && brokerMarginRead == false
            && brokerLeverageRead == false
            && realPnLRead == false
            && rawBrokerPayloadStored == false
            && reconciliationRuntimeExecuted == false
            && brokerGatewayTouched == false
            && executionClientTouched == false
            && dashboardCommandSurfaceExposed == false
            && startsNextMilestone == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-704-v040-portfolio-replay-projection"),
        issueID: Identifier = Identifier.constant("GH-704"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-700"), Identifier.constant("GH-703")],
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-705"), Identifier.constant("GH-707")],
        releaseVersion: String = "v0.4.0",
        upstreamJournalEvidenceID: Identifier,
        upstreamReplayState: ReleaseV040EventStoreRunReplayState,
        replayFills: [ReleaseV040PortfolioReplayFillEvidence],
        productProjections: [ReleaseV040PortfolioReplayProductProjection],
        projectionState: ReleaseV040PortfolioReplayProjectionState,
        requirements: [ReleaseV040PortfolioReplayProjectionRequirement] = Self.requiredRequirements,
        forbiddenCapabilities: [ReleaseV040PortfolioReplayProjectionForbiddenCapability] =
            Self.requiredForbiddenCapabilities,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        replayDerived: Bool = true,
        spotProjectionUpdated: Bool = true,
        perpetualProjectionUpdated: Bool = true,
        pnlLikeMetricsProjected: Bool = true,
        marginLikeMetricsProjected: Bool = true,
        dashboardCLIConsumableByRunID: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretRead: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        realAccountStateSynced: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionRead: Bool = false,
        brokerMarginRead: Bool = false,
        brokerLeverageRead: Bool = false,
        realPnLRead: Bool = false,
        rawBrokerPayloadStored: Bool = false,
        reconciliationRuntimeExecuted: Bool = false,
        brokerGatewayTouched: Bool = false,
        executionClientTouched: Bool = false,
        dashboardCommandSurfaceExposed: Bool = false,
        startsNextMilestone: Bool = false
    ) throws {
        try Self.validateBoundary(
            replayDerived: replayDerived,
            spotProjectionUpdated: spotProjectionUpdated,
            perpetualProjectionUpdated: perpetualProjectionUpdated,
            pnlLikeMetricsProjected: pnlLikeMetricsProjected,
            marginLikeMetricsProjected: marginLikeMetricsProjected,
            dashboardCLIConsumableByRunID: dashboardCLIConsumableByRunID,
            productionTradingEnabledByDefault: productionTradingEnabledByDefault,
            productionEndpointConnected: productionEndpointConnected,
            productionSecretRead: productionSecretRead,
            productionOrderSubmitted: productionOrderSubmitted,
            productionCutoverAuthorized: productionCutoverAuthorized,
            realAccountStateSynced: realAccountStateSynced,
            accountEndpointRead: accountEndpointRead,
            brokerPositionRead: brokerPositionRead,
            brokerMarginRead: brokerMarginRead,
            brokerLeverageRead: brokerLeverageRead,
            realPnLRead: realPnLRead,
            rawBrokerPayloadStored: rawBrokerPayloadStored,
            reconciliationRuntimeExecuted: reconciliationRuntimeExecuted,
            brokerGatewayTouched: brokerGatewayTouched,
            executionClientTouched: executionClientTouched,
            dashboardCommandSurfaceExposed: dashboardCommandSurfaceExposed,
            startsNextMilestone: startsNextMilestone
        )

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.upstreamJournalEvidenceID = upstreamJournalEvidenceID
        self.upstreamReplayState = upstreamReplayState
        self.replayFills = replayFills
        self.productProjections = productProjections
        self.projectionState = projectionState
        self.requirements = requirements
        self.forbiddenCapabilities = forbiddenCapabilities
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.replayDerived = replayDerived
        self.spotProjectionUpdated = spotProjectionUpdated
        self.perpetualProjectionUpdated = perpetualProjectionUpdated
        self.pnlLikeMetricsProjected = pnlLikeMetricsProjected
        self.marginLikeMetricsProjected = marginLikeMetricsProjected
        self.dashboardCLIConsumableByRunID = dashboardCLIConsumableByRunID
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretRead = productionSecretRead
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.realAccountStateSynced = realAccountStateSynced
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionRead = brokerPositionRead
        self.brokerMarginRead = brokerMarginRead
        self.brokerLeverageRead = brokerLeverageRead
        self.realPnLRead = realPnLRead
        self.rawBrokerPayloadStored = rawBrokerPayloadStored
        self.reconciliationRuntimeExecuted = reconciliationRuntimeExecuted
        self.brokerGatewayTouched = brokerGatewayTouched
        self.executionClientTouched = executionClientTouched
        self.dashboardCommandSurfaceExposed = dashboardCommandSurfaceExposed
        self.startsNextMilestone = startsNextMilestone

        guard evidenceHeld else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV040PortfolioReplay.evidenceHeld",
                expected: "held GH-704 evidence",
                actual: "false"
            )
        }
    }

    public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]
    public static let requiredStrategies: [ReleaseV040RehearsalStrategyKind] = [.ema, .rsi]
    public static let requiredRequirements = ReleaseV040PortfolioReplayProjectionRequirement.allCases
    public static let requiredForbiddenCapabilities =
        ReleaseV040PortfolioReplayProjectionForbiddenCapability.allCases
    public static let validationAnchor = "TVM-RELEASE-V040-PORTFOLIO-REPLAY-PROJECTION"
    public static let requiredValidationAnchors = [
        "V040-11-PORTFOLIO-REPLAY-PROJECTION",
        "V040-11-REPLAY-DERIVED-POSITIONS-EXPOSURE",
        "V040-11-SPOT-PERP-PNL-MARGIN-LIKE-METRICS",
        "V040-11-READMODEL-ONLY-NO-ACCOUNT-SYNC",
        "V040-11-DASHBOARD-CLI-RUNID-CONSUMABLE",
        validationAnchor
    ]
    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH704PortfolioReplayProjectionDerivesReadModelFromEventStoreRunJournal",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV040PortfolioReplayProjection 生成 GH-704 deterministic Portfolio replay projection evidence。
public enum ReleaseV040PortfolioReplayProjection {
    public static func deterministicEvidence(
        upstreamJournalEvidence: ReleaseV040EventStoreRunJournalEvidence? = nil
    ) throws -> ReleaseV040PortfolioReplayProjectionEvidence {
        let upstream = try upstreamJournalEvidence ?? ReleaseV040EventStoreRunJournalBuilder.deterministicEvidence()
        guard upstream.evidenceHeld,
              upstream.issueID.rawValue == "GH-703",
              upstream.replayState.replayStateHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "releaseV040PortfolioReplay.upstreamJournal",
                expected: "held GH-703 Event Store run journal evidence",
                actual: upstream.issueID.rawValue
            )
        }

        let fills = try deterministicReplayFills(upstream: upstream)
        let productProjections = try projectProducts(from: fills)
        let projectionState = try ReleaseV040PortfolioReplayProjectionState(
            runID: upstream.replayState.runID,
            sourceJournalEvidenceID: upstream.evidenceID,
            sourceJournalLatestChecksum: upstream.replayState.latestChecksum,
            productProjections: productProjections
        )
        return try ReleaseV040PortfolioReplayProjectionEvidence(
            upstreamJournalEvidenceID: upstream.evidenceID,
            upstreamReplayState: upstream.replayState,
            replayFills: fills,
            productProjections: productProjections,
            projectionState: projectionState
        )
    }

    public static func realAccountReadRejected() throws -> Bool {
        let upstream = try ReleaseV040EventStoreRunJournalBuilder.deterministicEvidence()
        let executionClientRecord = try record(.executionClient, from: upstream)
        let omsRecord = try record(.oms, from: upstream)
        let portfolioRecord = try record(.portfolio, from: upstream)
        do {
            _ = try ReleaseV040PortfolioReplayFillEvidence(
                fillID: Identifier.constant("gh-704-real-account-read-rejected"),
                runID: upstream.replayState.runID,
                productType: .spot,
                instrumentID: InstrumentIdentity.binance(productType: .spot, symbol: Symbol.constant("BTCUSDT")),
                strategy: .ema,
                sourceRunJournalRecordID: executionClientRecord.recordID,
                sourceOMSRecordID: omsRecord.recordID,
                sourceExecutionClientRecordID: executionClientRecord.recordID,
                sourcePortfolioRecordID: portfolioRecord.recordID,
                sourceReplaySequence: executionClientRecord.sequence,
                quantity: Quantity(0.10, field: "releaseV040PortfolioReplay.rejected.quantity"),
                price: Price(42_500, field: "releaseV040PortfolioReplay.rejected.price"),
                markPrice: Price(42_700, field: "releaseV040PortfolioReplay.rejected.markPrice"),
                feeQuote: 1.10,
                signedPositionDelta: 0.10,
                marginRate: 0,
                filledAt: Date(timeIntervalSince1970: 1_705_004_000),
                accountEndpointRead: true
            )
            return false
        } catch CoreError.paperPortfolioProjectionForbiddenCapability(
            "releaseV040PortfolioReplay.fill.accountEndpointRead"
        ) {
            return true
        }
    }

    private static func deterministicReplayFills(
        upstream: ReleaseV040EventStoreRunJournalEvidence
    ) throws -> [ReleaseV040PortfolioReplayFillEvidence] {
        let omsRecord = try record(.oms, from: upstream)
        let executionClientRecord = try record(.executionClient, from: upstream)
        let portfolioRecord = try record(.portfolio, from: upstream)
        let btc = Symbol.constant("BTCUSDT")
        let baseDate = Date(timeIntervalSince1970: 1_705_004_000)
        let specs: [
            (ProductType, ReleaseV040RehearsalStrategyKind, Double, Double, Double, Double, Double, Double)
        ] = [
            (.spot, .ema, 0.10, 42_500, 42_700, 1.10, 0.10, 0.00),
            (.spot, .rsi, 0.04, 42_300, 42_200, 0.45, -0.04, 0.00),
            (.usdsPerpetual, .ema, 0.20, 42_600, 42_900, 1.75, 0.20, 0.10),
            (.usdsPerpetual, .rsi, 0.08, 42_550, 42_400, 0.80, -0.08, 0.10)
        ]

        return try specs.enumerated().map { index, spec in
            try ReleaseV040PortfolioReplayFillEvidence(
                fillID: Identifier.constant("gh-704-\(spec.0.rawValue)-\(spec.1.rawValue)-replay-fill-\(index + 1)"),
                runID: upstream.replayState.runID,
                productType: spec.0,
                instrumentID: InstrumentIdentity.binance(productType: spec.0, symbol: btc),
                strategy: spec.1,
                sourceRunJournalRecordID: executionClientRecord.recordID,
                sourceOMSRecordID: omsRecord.recordID,
                sourceExecutionClientRecordID: executionClientRecord.recordID,
                sourcePortfolioRecordID: portfolioRecord.recordID,
                sourceReplaySequence: executionClientRecord.sequence,
                quantity: Quantity(spec.2, field: "releaseV040PortfolioReplay.fill.quantity"),
                price: Price(spec.3, field: "releaseV040PortfolioReplay.fill.price"),
                markPrice: Price(spec.4, field: "releaseV040PortfolioReplay.fill.markPrice"),
                feeQuote: spec.5,
                signedPositionDelta: spec.6,
                marginRate: spec.7,
                filledAt: baseDate.addingTimeInterval(TimeInterval(index))
            )
        }
    }

    private static func projectProducts(
        from fills: [ReleaseV040PortfolioReplayFillEvidence]
    ) throws -> [ReleaseV040PortfolioReplayProductProjection] {
        try ReleaseV040PortfolioReplayProjectionEvidence.requiredProductTypes.map { productType in
            let productFills = fills.filter { $0.productType == productType }
            let instrument = try unwrap(
                productFills.first?.instrumentID,
                field: "releaseV040PortfolioReplay.productProjection.instrument"
            )
            let grossQuantity = productFills.reduce(0) { $0 + $1.quantity.rawValue }
            let grossExposure = productFills.reduce(0) { $0 + $1.notional }
            return try ReleaseV040PortfolioReplayProductProjection(
                projectionID: Identifier.constant("gh-704-\(productType.rawValue)-portfolio-replay-projection"),
                runID: try unwrap(productFills.first?.runID, field: "releaseV040PortfolioReplay.productProjection.runID"),
                productType: productType,
                instrumentID: instrument,
                sourceFillIDs: productFills.map(\.fillID),
                sourceReplaySequences: productFills.map(\.sourceReplaySequence),
                netPositionQuantity: productFills.reduce(0) { $0 + $1.signedPositionDelta },
                grossReplayQuantity: grossQuantity,
                grossExposure: grossExposure,
                projectedPnLLike: productFills.reduce(0) { $0 + $1.projectedPnLLike },
                marginLikeRequirement: productFills.reduce(0) { $0 + $1.marginLikeRequirement },
                projectedAt: Date(timeIntervalSince1970: 1_705_004_100)
            )
        }
    }

    private static func record(
        _ module: ReleaseV040UnifiedEvidenceModule,
        from upstream: ReleaseV040EventStoreRunJournalEvidence
    ) throws -> ReleaseV040EventStoreRunJournalRecord {
        try unwrap(
            upstream.records.first { $0.module == module },
            field: "releaseV040PortfolioReplay.sourceRecord.\(module.rawValue)"
        )
    }
}

private extension ReleaseV040PortfolioReplayProjectionEvidence {
    static func validateBoundary(
        replayDerived: Bool,
        spotProjectionUpdated: Bool,
        perpetualProjectionUpdated: Bool,
        pnlLikeMetricsProjected: Bool,
        marginLikeMetricsProjected: Bool,
        dashboardCLIConsumableByRunID: Bool,
        productionTradingEnabledByDefault: Bool,
        productionEndpointConnected: Bool,
        productionSecretRead: Bool,
        productionOrderSubmitted: Bool,
        productionCutoverAuthorized: Bool,
        realAccountStateSynced: Bool,
        accountEndpointRead: Bool,
        brokerPositionRead: Bool,
        brokerMarginRead: Bool,
        brokerLeverageRead: Bool,
        realPnLRead: Bool,
        rawBrokerPayloadStored: Bool,
        reconciliationRuntimeExecuted: Bool,
        brokerGatewayTouched: Bool,
        executionClientTouched: Bool,
        dashboardCommandSurfaceExposed: Bool,
        startsNextMilestone: Bool
    ) throws {
        guard replayDerived,
              spotProjectionUpdated,
              perpetualProjectionUpdated,
              pnlLikeMetricsProjected,
              marginLikeMetricsProjected,
              dashboardCLIConsumableByRunID else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "releaseV040PortfolioReplay.acceptance",
                expected: "replay-derived Spot/Perp read model with PnL-like and margin-like metrics",
                actual: "\(replayDerived):\(spotProjectionUpdated):\(perpetualProjectionUpdated)"
            )
        }
        let forbiddenFlags = [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionEndpointConnected", productionEndpointConnected),
            ("productionSecretRead", productionSecretRead),
            ("productionOrderSubmitted", productionOrderSubmitted),
            ("productionCutoverAuthorized", productionCutoverAuthorized),
            ("realAccountStateSynced", realAccountStateSynced),
            ("accountEndpointRead", accountEndpointRead),
            ("brokerPositionRead", brokerPositionRead),
            ("brokerMarginRead", brokerMarginRead),
            ("brokerLeverageRead", brokerLeverageRead),
            ("realPnLRead", realPnLRead),
            ("rawBrokerPayloadStored", rawBrokerPayloadStored),
            ("reconciliationRuntimeExecuted", reconciliationRuntimeExecuted),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("executionClientTouched", executionClientTouched),
            ("dashboardCommandSurfaceExposed", dashboardCommandSurfaceExposed),
            ("startsNextMilestone", startsNextMilestone)
        ]
        for (field, value) in forbiddenFlags where value {
            throw CoreError.paperPortfolioProjectionForbiddenCapability("releaseV040PortfolioReplay.\(field)")
        }
    }
}

private func unwrap<T>(_ value: T?, field: String) throws -> T {
    guard let value else {
        throw CoreError.liveTradingBoundaryContractMismatch(field: field, expected: "present", actual: "nil")
    }
    return value
}
