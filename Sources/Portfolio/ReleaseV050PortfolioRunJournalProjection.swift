import Database
import DomainModel
import Foundation
import MessageBus

/// ReleaseV050PortfolioRunJournalProjectionError 描述 GH-736 Portfolio journal projection 合同错误。
///
/// 错误只覆盖 run journal replay、typed dry-run evidence 关联、InstrumentCatalog 精度计算和
/// broker / account payload 禁止边界；它不表达真实账户同步、broker reconciliation 或生产交易能力。
public enum ReleaseV050PortfolioRunJournalProjectionError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyJournal
    case missingStrategyIntent(Identifier)
    case missingRiskDecision(Identifier)
    case missingAcceptedDryRunSubmit(Identifier)
    case missingInstrumentCatalogEntry(InstrumentIdentity)
    case missingFilledDryRunEvidence
    case runJournalReplayMismatch
    case invalidFixedPointComputation(String)
    case forbiddenBrokerAccountPayload(String)
    case contractDrift(String)

    public var description: String {
        switch self {
        case .emptyJournal:
            "Release v0.5.0 Portfolio projection requires a non-empty run journal"
        case let .missingStrategyIntent(strategyID):
            "Release v0.5.0 Portfolio projection missing source StrategyIntentEvent: \(strategyID.rawValue)"
        case let .missingRiskDecision(decisionID):
            "Release v0.5.0 Portfolio projection missing source RiskDecisionEvent: \(decisionID.rawValue)"
        case let .missingAcceptedDryRunSubmit(orderID):
            "Release v0.5.0 Portfolio projection missing accepted dry-run submit for order: \(orderID.rawValue)"
        case let .missingInstrumentCatalogEntry(instrument):
            "Release v0.5.0 Portfolio projection missing InstrumentCatalog entry: \(instrument.rawValue)"
        case .missingFilledDryRunEvidence:
            "Release v0.5.0 Portfolio projection requires at least one simulatedFilled OMS event"
        case .runJournalReplayMismatch:
            "Release v0.5.0 Portfolio projection replayed journal does not match append-only records"
        case let .invalidFixedPointComputation(reason):
            "Release v0.5.0 Portfolio projection fixed-point computation failed: \(reason)"
        case let .forbiddenBrokerAccountPayload(field):
            "Release v0.5.0 Portfolio projection rejected broker/account payload field: \(field)"
        case let .contractDrift(reason):
            "Release v0.5.0 Portfolio projection contract drift: \(reason)"
        }
    }
}

/// ReleaseV050PortfolioRunJournalFillEvidence 是从 journal + dry-run OMS/fill evidence 派生的 fill-like 输入。
///
/// 该 evidence 只把 `simulatedFilled` dry-run lifecycle 解释为 rehearsal read-model 输入；
/// 它不是 broker fill，不是 account position，也不触发 reconciliation runtime。
public struct ReleaseV050PortfolioRunJournalFillEvidence: Codable, Equatable, Sendable {
    public let fillID: Identifier
    public let runID: Identifier
    public let sourceJournalRecordID: Identifier
    public let sourceJournalSequence: Int
    public let sourceOMSOrderID: Identifier
    public let sourceRiskDecisionID: Identifier
    public let sourceStrategyID: Identifier
    public let productType: ProductType
    public let instrument: InstrumentIdentity
    public let catalogTickSize: ReleaseV050FixedPointValue
    public let catalogStepSize: ReleaseV050FixedPointValue
    public let catalogMinNotional: ReleaseV050FixedPointValue
    public let targetQuantity: ReleaseV050FixedPointValue
    public let projectionReferencePrice: ReleaseV050FixedPointValue
    public let projectionMarkPrice: ReleaseV050FixedPointValue
    public let notionalExposure: ReleaseV050FixedPointValue
    public let projectedPnLLike: ReleaseV050FixedPointValue
    public let marginLikeRequirement: ReleaseV050FixedPointValue
    public let sourceOMSState: RuntimeOMSState
    public let sourceExecutionCommandKind: RuntimeDryRunCommandKind
    public let sourceExecutionAcceptedByDryRunAdapter: Bool
    public let sourceIsRunJournalOnly: Bool
    public let sourceIsDryRunOnly: Bool
    public let projectionLabel: String
    public let productionAccountSynced: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionRead: Bool
    public let brokerMarginRead: Bool
    public let brokerLeverageRead: Bool
    public let realPnLRead: Bool
    public let rawBrokerPayloadStored: Bool

    public var fillHeld: Bool {
        runID.rawValue.isEmpty == false
            && sourceJournalSequence > 0
            && productType == instrument.productType
            && catalogTickSize.semantic == .price
            && catalogStepSize.semantic == .quantity
            && catalogMinNotional.semantic == .notional
            && targetQuantity.semantic == .quantity
            && projectionReferencePrice.semantic == .price
            && projectionMarkPrice.semantic == .price
            && notionalExposure.semantic == .notional
            && projectedPnLLike.semantic == .money
            && marginLikeRequirement.semantic == .notional
            && sourceOMSState == .simulatedFilled
            && sourceExecutionCommandKind == .submit
            && sourceExecutionAcceptedByDryRunAdapter
            && sourceIsRunJournalOnly
            && sourceIsDryRunOnly
            && projectionLabel == Self.requiredProjectionLabel
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
        sourceJournalRecordID: Identifier,
        sourceJournalSequence: Int,
        sourceOMSOrderID: Identifier,
        sourceRiskDecisionID: Identifier,
        sourceStrategyID: Identifier,
        productType: ProductType,
        instrument: InstrumentIdentity,
        catalogTickSize: ReleaseV050FixedPointValue,
        catalogStepSize: ReleaseV050FixedPointValue,
        catalogMinNotional: ReleaseV050FixedPointValue,
        targetQuantity: ReleaseV050FixedPointValue,
        projectionReferencePrice: ReleaseV050FixedPointValue,
        projectionMarkPrice: ReleaseV050FixedPointValue,
        notionalExposure: ReleaseV050FixedPointValue,
        projectedPnLLike: ReleaseV050FixedPointValue,
        marginLikeRequirement: ReleaseV050FixedPointValue,
        sourceOMSState: RuntimeOMSState,
        sourceExecutionCommandKind: RuntimeDryRunCommandKind,
        sourceExecutionAcceptedByDryRunAdapter: Bool,
        sourceIsRunJournalOnly: Bool = true,
        sourceIsDryRunOnly: Bool = true,
        projectionLabel: String = Self.requiredProjectionLabel,
        productionAccountSynced: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionRead: Bool = false,
        brokerMarginRead: Bool = false,
        brokerLeverageRead: Bool = false,
        realPnLRead: Bool = false,
        rawBrokerPayloadStored: Bool = false
    ) throws {
        guard sourceJournalSequence > 0 else {
            throw ReleaseV050PortfolioRunJournalProjectionError.invalidFixedPointComputation("sourceJournalSequence")
        }
        guard productType == instrument.productType else {
            throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("productTypeInstrumentMismatch")
        }
        guard targetQuantity.semantic == .quantity,
              projectionReferencePrice.semantic == .price,
              projectionMarkPrice.semantic == .price,
              notionalExposure.semantic == .notional,
              projectedPnLLike.semantic == .money,
              marginLikeRequirement.semantic == .notional else {
            throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("fixedPointSemanticMismatch")
        }
        guard sourceOMSState == .simulatedFilled,
              sourceExecutionCommandKind == .submit,
              sourceExecutionAcceptedByDryRunAdapter,
              sourceIsRunJournalOnly,
              sourceIsDryRunOnly,
              projectionLabel == Self.requiredProjectionLabel else {
            throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("dryRunFillSourceMismatch")
        }
        try Self.forbid(productionAccountSynced, "productionAccountSynced")
        try Self.forbid(accountEndpointRead, "accountEndpointRead")
        try Self.forbid(brokerPositionRead, "brokerPositionRead")
        try Self.forbid(brokerMarginRead, "brokerMarginRead")
        try Self.forbid(brokerLeverageRead, "brokerLeverageRead")
        try Self.forbid(realPnLRead, "realPnLRead")
        try Self.forbid(rawBrokerPayloadStored, "rawBrokerPayloadStored")

        self.fillID = fillID
        self.runID = runID
        self.sourceJournalRecordID = sourceJournalRecordID
        self.sourceJournalSequence = sourceJournalSequence
        self.sourceOMSOrderID = sourceOMSOrderID
        self.sourceRiskDecisionID = sourceRiskDecisionID
        self.sourceStrategyID = sourceStrategyID
        self.productType = productType
        self.instrument = instrument
        self.catalogTickSize = catalogTickSize
        self.catalogStepSize = catalogStepSize
        self.catalogMinNotional = catalogMinNotional
        self.targetQuantity = targetQuantity
        self.projectionReferencePrice = projectionReferencePrice
        self.projectionMarkPrice = projectionMarkPrice
        self.notionalExposure = notionalExposure
        self.projectedPnLLike = projectedPnLLike
        self.marginLikeRequirement = marginLikeRequirement
        self.sourceOMSState = sourceOMSState
        self.sourceExecutionCommandKind = sourceExecutionCommandKind
        self.sourceExecutionAcceptedByDryRunAdapter = sourceExecutionAcceptedByDryRunAdapter
        self.sourceIsRunJournalOnly = sourceIsRunJournalOnly
        self.sourceIsDryRunOnly = sourceIsDryRunOnly
        self.projectionLabel = projectionLabel
        self.productionAccountSynced = productionAccountSynced
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionRead = brokerPositionRead
        self.brokerMarginRead = brokerMarginRead
        self.brokerLeverageRead = brokerLeverageRead
        self.realPnLRead = realPnLRead
        self.rawBrokerPayloadStored = rawBrokerPayloadStored

        guard fillHeld else {
            throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("fillEvidenceHeld")
        }
    }

    public static func accountEndpointReadRejectedProbe() throws -> Bool {
        let catalogEntry = try ReleaseV050InstrumentCatalog.requiredEntries()[0]
        do {
            _ = try ReleaseV050PortfolioRunJournalFillEvidence(
                fillID: Identifier.constant("gh-736-account-payload-probe"),
                runID: Identifier.constant("gh-736-account-payload-probe-run"),
                sourceJournalRecordID: Identifier.constant("gh-736-account-payload-probe-record"),
                sourceJournalSequence: 1,
                sourceOMSOrderID: Identifier.constant("gh-736-account-payload-probe-order"),
                sourceRiskDecisionID: Identifier.constant("gh-736-account-payload-probe-risk"),
                sourceStrategyID: Identifier.constant("gh-736-account-payload-probe-strategy"),
                productType: catalogEntry.instrument.productType,
                instrument: catalogEntry.instrument,
                catalogTickSize: catalogEntry.tickSize,
                catalogStepSize: catalogEntry.stepSize,
                catalogMinNotional: catalogEntry.minNotional,
                targetQuantity: catalogEntry.minQuantity,
                projectionReferencePrice: try ReleaseV050PortfolioRunJournalProjection.referencePrice(from: catalogEntry),
                projectionMarkPrice: try ReleaseV050PortfolioRunJournalProjection.markPrice(from: catalogEntry),
                notionalExposure: catalogEntry.minNotional,
                projectedPnLLike: try ReleaseV050FixedPointValue(
                    minorUnits: 0,
                    scale: catalogEntry.precisionPolicy.moneyScale,
                    semantic: .money,
                    allowsZero: true
                ),
                marginLikeRequirement: try ReleaseV050FixedPointValue(
                    minorUnits: 0,
                    scale: catalogEntry.precisionPolicy.notionalScale,
                    semantic: .notional,
                    allowsZero: true
                ),
                sourceOMSState: .simulatedFilled,
                sourceExecutionCommandKind: .submit,
                sourceExecutionAcceptedByDryRunAdapter: true,
                accountEndpointRead: true
            )
            return false
        } catch ReleaseV050PortfolioRunJournalProjectionError.forbiddenBrokerAccountPayload("accountEndpointRead") {
            return true
        }
    }

    private static func forbid(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV050PortfolioRunJournalProjectionError.forbiddenBrokerAccountPayload(field)
        }
    }

    public static let requiredProjectionLabel = "rehearsal-dry-run-run-journal-read-model-not-broker-truth"
}

/// ReleaseV050PortfolioRunJournalProductProjection 是按产品归集的 Portfolio read model。
public struct ReleaseV050PortfolioRunJournalProductProjection: Codable, Equatable, Sendable {
    public let projectionID: Identifier
    public let runID: Identifier
    public let productType: ProductType
    public let instrument: InstrumentIdentity
    public let sourceFillIDs: [Identifier]
    public let sourceJournalSequences: [Int]
    public let netPositionQuantity: ReleaseV050FixedPointValue
    public let grossExposure: ReleaseV050FixedPointValue
    public let projectedPnLLike: ReleaseV050FixedPointValue
    public let marginLikeRequirement: ReleaseV050FixedPointValue
    public let sourceIsRunJournalOnly: Bool
    public let readModelOnly: Bool
    public let brokerTruth: Bool

    public var projectionHeld: Bool {
        productType == instrument.productType
            && sourceFillIDs.isEmpty == false
            && sourceJournalSequences.isEmpty == false
            && sourceJournalSequences.allSatisfy { $0 > 0 }
            && netPositionQuantity.semantic == .quantity
            && grossExposure.semantic == .notional
            && projectedPnLLike.semantic == .money
            && marginLikeRequirement.semantic == .notional
            && sourceIsRunJournalOnly
            && readModelOnly
            && brokerTruth == false
    }

    public init(
        projectionID: Identifier,
        runID: Identifier,
        productType: ProductType,
        instrument: InstrumentIdentity,
        sourceFillIDs: [Identifier],
        sourceJournalSequences: [Int],
        netPositionQuantity: ReleaseV050FixedPointValue,
        grossExposure: ReleaseV050FixedPointValue,
        projectedPnLLike: ReleaseV050FixedPointValue,
        marginLikeRequirement: ReleaseV050FixedPointValue,
        sourceIsRunJournalOnly: Bool = true,
        readModelOnly: Bool = true,
        brokerTruth: Bool = false
    ) throws {
        self.projectionID = projectionID
        self.runID = runID
        self.productType = productType
        self.instrument = instrument
        self.sourceFillIDs = sourceFillIDs
        self.sourceJournalSequences = sourceJournalSequences
        self.netPositionQuantity = netPositionQuantity
        self.grossExposure = grossExposure
        self.projectedPnLLike = projectedPnLLike
        self.marginLikeRequirement = marginLikeRequirement
        self.sourceIsRunJournalOnly = sourceIsRunJournalOnly
        self.readModelOnly = readModelOnly
        self.brokerTruth = brokerTruth

        guard projectionHeld else {
            throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("productProjectionHeld")
        }
    }
}

/// ReleaseV050PortfolioRunJournalProjectionState 汇总 runID 可复现的 Portfolio 投影。
public struct ReleaseV050PortfolioRunJournalProjectionState: Codable, Equatable, Sendable {
    public let runID: Identifier
    public let sourceJournalLatestChecksum: String
    public let sourceJournalEventCount: Int
    public let productProjections: [ReleaseV050PortfolioRunJournalProductProjection]
    public let totalGrossExposure: ReleaseV050FixedPointValue
    public let totalProjectedPnLLike: ReleaseV050FixedPointValue
    public let totalMarginLikeRequirement: ReleaseV050FixedPointValue
    public let projectionByRunID: Bool
    public let sourceChainAuditable: Bool
    public let readModelOnly: Bool
    public let brokerTruth: Bool

    public var stateHeld: Bool {
        sourceJournalLatestChecksum.hasPrefix("fnv1a64:")
            && sourceJournalEventCount > 0
            && productProjections.isEmpty == false
            && productProjections.allSatisfy(\.projectionHeld)
            && productProjections.allSatisfy { $0.runID == runID }
            && totalGrossExposure.semantic == .notional
            && totalProjectedPnLLike.semantic == .money
            && totalMarginLikeRequirement.semantic == .notional
            && projectionByRunID
            && sourceChainAuditable
            && readModelOnly
            && brokerTruth == false
    }

    public init(
        runID: Identifier,
        sourceJournalLatestChecksum: String,
        sourceJournalEventCount: Int,
        productProjections: [ReleaseV050PortfolioRunJournalProductProjection],
        totalGrossExposure: ReleaseV050FixedPointValue,
        totalProjectedPnLLike: ReleaseV050FixedPointValue,
        totalMarginLikeRequirement: ReleaseV050FixedPointValue,
        projectionByRunID: Bool = true,
        sourceChainAuditable: Bool = true,
        readModelOnly: Bool = true,
        brokerTruth: Bool = false
    ) throws {
        self.runID = runID
        self.sourceJournalLatestChecksum = sourceJournalLatestChecksum
        self.sourceJournalEventCount = sourceJournalEventCount
        self.productProjections = productProjections
        self.totalGrossExposure = totalGrossExposure
        self.totalProjectedPnLLike = totalProjectedPnLLike
        self.totalMarginLikeRequirement = totalMarginLikeRequirement
        self.projectionByRunID = projectionByRunID
        self.sourceChainAuditable = sourceChainAuditable
        self.readModelOnly = readModelOnly
        self.brokerTruth = brokerTruth

        guard stateHeld else {
            throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("projectionStateHeld")
        }
    }
}

/// ReleaseV050PortfolioRunJournalProjectionEvidence 汇总 GH-736 Portfolio projection evidence。
public struct ReleaseV050PortfolioRunJournalProjectionEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let runID: Identifier
    public let replayedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let sourcePayloadTypes: [RuntimeEventPayloadType]
    public let sourceJournalLatestChecksum: String
    public let fillEvidence: [ReleaseV050PortfolioRunJournalFillEvidence]
    public let productProjections: [ReleaseV050PortfolioRunJournalProductProjection]
    public let portfolioProjectionEvents: [PortfolioProjectionEvent]
    public let projectionState: ReleaseV050PortfolioRunJournalProjectionState
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let journalReplayDerived: Bool
    public let productAwarePrecisionUsed: Bool
    public let projectionByRunID: Bool
    public let sourceChainAuditable: Bool
    public let dryRunRehearsalProjection: Bool
    public let brokerTruth: Bool
    public let productionAccountSynced: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionRead: Bool
    public let brokerMarginRead: Bool
    public let brokerLeverageRead: Bool
    public let realPnLRead: Bool
    public let rawBrokerPayloadStored: Bool
    public let reconciliationRuntimeExecuted: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-736"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-729", "GH-731", "GH-734", "GH-735"]
            && previousIssueID.rawValue == "GH-735"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-737", "GH-739"]
            && canonicalQueueRange == "GH-726..GH-739"
            && projectName == "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge"
            && replayedEnvelopes.isEmpty == false
            && replayedEnvelopes.allSatisfy(\.envelopeHeld)
            && sourcePayloadTypes == replayedEnvelopes.map(\.payloadType)
            && Set(sourcePayloadTypes).isSuperset(of: Set(Self.requiredSourcePayloadTypes))
            && sourceJournalLatestChecksum.hasPrefix("fnv1a64:")
            && fillEvidence.isEmpty == false
            && fillEvidence.allSatisfy(\.fillHeld)
            && productProjections.isEmpty == false
            && productProjections.allSatisfy(\.projectionHeld)
            && portfolioProjectionEvents.map(\.projectionID) == productProjections.map(\.projectionID)
            && portfolioProjectionEvents.map(\.instrument) == productProjections.map(\.instrument)
            && projectionState.stateHeld
            && validationAnchors == ReleaseV050PortfolioRunJournalProjectionContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV050PortfolioRunJournalProjectionContract.requiredValidationCommands
            && sourceBoundaryHeld
            && forbiddenBoundaryHeld
    }

    public var sourceBoundaryHeld: Bool {
        journalReplayDerived
            && productAwarePrecisionUsed
            && projectionByRunID
            && sourceChainAuditable
            && dryRunRehearsalProjection
            && brokerTruth == false
    }

    public var forbiddenBoundaryHeld: Bool {
        productionAccountSynced == false
            && accountEndpointRead == false
            && brokerPositionRead == false
            && brokerMarginRead == false
            && brokerLeverageRead == false
            && realPnLRead == false
            && rawBrokerPayloadStored == false
            && reconciliationRuntimeExecuted == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-736-v050-portfolio-run-journal-projection-evidence"),
        issueID: Identifier = Identifier.constant("GH-736"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-729"),
            Identifier.constant("GH-731"),
            Identifier.constant("GH-734"),
            Identifier.constant("GH-735")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-735"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-737"), Identifier.constant("GH-739")],
        canonicalQueueRange: String = "GH-726..GH-739",
        projectName: String = "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge",
        runID: Identifier,
        replayedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        sourceJournalLatestChecksum: String,
        fillEvidence: [ReleaseV050PortfolioRunJournalFillEvidence],
        productProjections: [ReleaseV050PortfolioRunJournalProductProjection],
        portfolioProjectionEvents: [PortfolioProjectionEvent],
        projectionState: ReleaseV050PortfolioRunJournalProjectionState,
        validationAnchors: [String] = ReleaseV050PortfolioRunJournalProjectionContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV050PortfolioRunJournalProjectionContract.requiredValidationCommands,
        journalReplayDerived: Bool = true,
        productAwarePrecisionUsed: Bool = true,
        projectionByRunID: Bool = true,
        sourceChainAuditable: Bool = true,
        dryRunRehearsalProjection: Bool = true,
        brokerTruth: Bool = false,
        productionAccountSynced: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionRead: Bool = false,
        brokerMarginRead: Bool = false,
        brokerLeverageRead: Bool = false,
        realPnLRead: Bool = false,
        rawBrokerPayloadStored: Bool = false,
        reconciliationRuntimeExecuted: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.runID = runID
        self.replayedEnvelopes = replayedEnvelopes
        self.sourcePayloadTypes = replayedEnvelopes.map(\.payloadType)
        self.sourceJournalLatestChecksum = sourceJournalLatestChecksum
        self.fillEvidence = fillEvidence
        self.productProjections = productProjections
        self.portfolioProjectionEvents = portfolioProjectionEvents
        self.projectionState = projectionState
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.journalReplayDerived = journalReplayDerived
        self.productAwarePrecisionUsed = productAwarePrecisionUsed
        self.projectionByRunID = projectionByRunID
        self.sourceChainAuditable = sourceChainAuditable
        self.dryRunRehearsalProjection = dryRunRehearsalProjection
        self.brokerTruth = brokerTruth
        self.productionAccountSynced = productionAccountSynced
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionRead = brokerPositionRead
        self.brokerMarginRead = brokerMarginRead
        self.brokerLeverageRead = brokerLeverageRead
        self.realPnLRead = realPnLRead
        self.rawBrokerPayloadStored = rawBrokerPayloadStored
        self.reconciliationRuntimeExecuted = reconciliationRuntimeExecuted
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("portfolioRunJournalProjectionEvidenceHeld")
        }
    }

    public static let requiredSourcePayloadTypes: [RuntimeEventPayloadType] = [
        .strategyIntentEvent,
        .riskDecisionEvent,
        .omsLifecycleEvent,
        .executionClientDryRunEvent
    ]
}

/// ReleaseV050PortfolioRunJournalProjectionContract 固定 GH-736 issue-level 验收合同。
public struct ReleaseV050PortfolioRunJournalProjectionContract: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let canonicalQueueRange: String
    public let projectName: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let projectionLabel: String
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionRead: Bool
    public let rawBrokerPayloadStored: Bool

    public var contractHeld: Bool {
        contractID.rawValue == "release-v050-portfolio-run-journal-projection-contract"
            && issueID.rawValue == "GH-736"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-729", "GH-731", "GH-734", "GH-735"]
            && previousIssueID.rawValue == "GH-735"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-737", "GH-739"]
            && canonicalQueueRange == "GH-726..GH-739"
            && projectName == "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && projectionLabel == ReleaseV050PortfolioRunJournalFillEvidence.requiredProjectionLabel
            && productionDefaultsClosed
    }

    public var productionDefaultsClosed: Bool {
        productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
            && accountEndpointRead == false
            && brokerPositionRead == false
            && rawBrokerPayloadStored == false
    }

    public init(
        contractID: Identifier = Identifier.constant("release-v050-portfolio-run-journal-projection-contract"),
        issueID: Identifier = Identifier.constant("GH-736"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-729"),
            Identifier.constant("GH-731"),
            Identifier.constant("GH-734"),
            Identifier.constant("GH-735")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-735"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-737"), Identifier.constant("GH-739")],
        canonicalQueueRange: String = "GH-726..GH-739",
        projectName: String = "MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        projectionLabel: String = ReleaseV050PortfolioRunJournalFillEvidence.requiredProjectionLabel,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionRead: Bool = false,
        rawBrokerPayloadStored: Bool = false
    ) throws {
        self.contractID = contractID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.canonicalQueueRange = canonicalQueueRange
        self.projectName = projectName
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.projectionLabel = projectionLabel
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionRead = brokerPositionRead
        self.rawBrokerPayloadStored = rawBrokerPayloadStored

        guard contractHeld else {
            throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("portfolioRunJournalProjectionContract")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV050PortfolioRunJournalProjectionContract {
        try ReleaseV050PortfolioRunJournalProjectionContract()
    }

    public static let requiredValidationAnchors = [
        "V050-11-PORTFOLIO-RUN-JOURNAL-PROJECTION",
        "V050-11-JOURNAL-REPLAY-DERIVED-POSITION-EXPOSURE",
        "V050-11-PNL-MARGIN-LIKE-REHEARSAL-METRICS",
        "V050-11-INSTRUMENT-CATALOG-PRECISION-SOURCE",
        "V050-11-NO-BROKER-ACCOUNT-PAYLOAD",
        "TVM-RELEASE-V050-PORTFOLIO-RUN-JOURNAL-PROJECTION"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH736PortfolioProjectionDerivesReadModelFromRunJournalAndOMSDryRunEvidence",
        "bash checks/verify-v0.5.0-portfolio.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}

/// ReleaseV050PortfolioRunJournalProjection 从 GH-731 journal + GH-735 dry-run evidence 派生 Portfolio read model。
public enum ReleaseV050PortfolioRunJournalProjection {
    public static func project(
        journal: ReleaseV050DurableLocalRunJournal,
        instrumentCatalog: ReleaseV050InstrumentCatalog? = nil
    ) throws -> ReleaseV050PortfolioRunJournalProjectionEvidence {
        guard journal.records.isEmpty == false else {
            throw ReleaseV050PortfolioRunJournalProjectionError.emptyJournal
        }
        guard journal.appendOnlyHeld else {
            throw ReleaseV050PortfolioRunJournalProjectionError.runJournalReplayMismatch
        }
        let cursor = try ReleaseV050RunJournalReplayCursor(runID: journal.paths.runID)
        let replayed = try journal.replay(cursor: cursor)
        guard replayed == journal.records.map(\.envelope) else {
            throw ReleaseV050PortfolioRunJournalProjectionError.runJournalReplayMismatch
        }

        let catalog = try instrumentCatalog ?? ReleaseV050InstrumentCatalog.deterministicFixture()
        let fillEvidence = try deriveFills(from: journal.records, catalog: catalog)
        let productProjections = try projectProducts(from: fillEvidence)
        let portfolioProjectionEvents = try projectionEvents(from: productProjections)
        let projectionState = try state(
            runID: journal.paths.runID,
            sourceJournalLatestChecksum: journal.latestJournalChecksum,
            sourceJournalEventCount: journal.records.count,
            productProjections: productProjections
        )

        return try ReleaseV050PortfolioRunJournalProjectionEvidence(
            runID: journal.paths.runID,
            replayedEnvelopes: replayed,
            sourceJournalLatestChecksum: journal.latestJournalChecksum,
            fillEvidence: fillEvidence,
            productProjections: productProjections,
            portfolioProjectionEvents: portfolioProjectionEvents,
            projectionState: projectionState
        )
    }

    public static func referencePrice(
        from entry: ReleaseV050InstrumentCatalogEntry
    ) throws -> ReleaseV050FixedPointValue {
        let scaleShift = entry.minQuantity.scale
            + entry.precisionPolicy.priceScale
            - entry.minNotional.scale
        let numerator: Int64
        if scaleShift >= 0 {
            numerator = try checkedProduct(
                entry.minNotional.minorUnits,
                pow10(scaleShift),
                "referencePriceNumerator"
            )
        } else {
            numerator = entry.minNotional.minorUnits / pow10(-scaleShift)
        }
        let priceMinorUnits = numerator / entry.minQuantity.minorUnits
        guard priceMinorUnits > 0 else {
            throw ReleaseV050PortfolioRunJournalProjectionError.invalidFixedPointComputation("referencePrice")
        }
        return try .price(minorUnits: priceMinorUnits, scale: entry.precisionPolicy.priceScale)
    }

    public static func markPrice(
        from entry: ReleaseV050InstrumentCatalogEntry
    ) throws -> ReleaseV050FixedPointValue {
        let reference = try referencePrice(from: entry)
        let minorUnits = try checkedSum(reference.minorUnits, entry.tickSize.minorUnits, "markPrice")
        return try .price(minorUnits: minorUnits, scale: reference.scale)
    }

    private static func deriveFills(
        from records: [ReleaseV050DurableLocalRunJournalRecord],
        catalog: ReleaseV050InstrumentCatalog
    ) throws -> [ReleaseV050PortfolioRunJournalFillEvidence] {
        var strategyIntents: [Identifier: StrategyIntentEvent] = [:]
        var riskDecisions: [Identifier: RiskDecisionEvent] = [:]
        var acceptedSubmits: [Identifier: ExecutionClientDryRunEvent] = [:]
        var filledOMSRecords: [(ReleaseV050DurableLocalRunJournalRecord, OMSLifecycleEvent)] = []

        for record in records {
            switch record.envelope.payload {
            case let .strategyIntent(intent):
                strategyIntents[intent.strategyID] = intent
            case let .riskDecision(decision):
                riskDecisions[decision.decisionID] = decision
            case let .executionClientDryRun(event)
                where event.commandKind == .submit && event.acceptedByDryRunAdapter:
                acceptedSubmits[event.sourceOMSOrderID] = event
            case let .omsLifecycle(event) where event.state == .simulatedFilled:
                filledOMSRecords.append((record, event))
            default:
                break
            }
        }

        guard filledOMSRecords.isEmpty == false else {
            throw ReleaseV050PortfolioRunJournalProjectionError.missingFilledDryRunEvidence
        }

        return try filledOMSRecords.enumerated().map { index, source in
            let (record, omsEvent) = source
            guard let riskDecision = riskDecisions[omsEvent.sourceRiskDecisionID] else {
                throw ReleaseV050PortfolioRunJournalProjectionError.missingRiskDecision(omsEvent.sourceRiskDecisionID)
            }
            guard let strategyIntent = strategyIntents[riskDecision.sourceIntentID] else {
                throw ReleaseV050PortfolioRunJournalProjectionError.missingStrategyIntent(riskDecision.sourceIntentID)
            }
            guard let acceptedSubmit = acceptedSubmits[omsEvent.orderID] else {
                throw ReleaseV050PortfolioRunJournalProjectionError.missingAcceptedDryRunSubmit(omsEvent.orderID)
            }
            guard let entry = catalog.entry(for: strategyIntent.instrument) else {
                throw ReleaseV050PortfolioRunJournalProjectionError.missingInstrumentCatalogEntry(strategyIntent.instrument)
            }
            let reference = try referencePrice(from: entry)
            let mark = try markPrice(from: entry)
            let notional = try notionalValue(
                quantity: strategyIntent.targetQuantity,
                price: reference,
                resultScale: entry.precisionPolicy.notionalScale
            )
            let pnlLike = try moneyValue(
                quantity: strategyIntent.targetQuantity,
                entry: entry,
                referencePrice: reference,
                markPrice: mark
            )
            let marginLike = try marginLikeValue(notional: notional, productType: strategyIntent.instrument.productType)
            return try ReleaseV050PortfolioRunJournalFillEvidence(
                fillID: Identifier.constant("gh-736-v050-portfolio-fill-\(index + 1)"),
                runID: record.runID,
                sourceJournalRecordID: record.journalRecordID,
                sourceJournalSequence: record.journalSequence,
                sourceOMSOrderID: omsEvent.orderID,
                sourceRiskDecisionID: omsEvent.sourceRiskDecisionID,
                sourceStrategyID: strategyIntent.strategyID,
                productType: strategyIntent.instrument.productType,
                instrument: strategyIntent.instrument,
                catalogTickSize: entry.tickSize,
                catalogStepSize: entry.stepSize,
                catalogMinNotional: entry.minNotional,
                targetQuantity: strategyIntent.targetQuantity,
                projectionReferencePrice: reference,
                projectionMarkPrice: mark,
                notionalExposure: notional,
                projectedPnLLike: pnlLike,
                marginLikeRequirement: marginLike,
                sourceOMSState: omsEvent.state,
                sourceExecutionCommandKind: acceptedSubmit.commandKind,
                sourceExecutionAcceptedByDryRunAdapter: acceptedSubmit.acceptedByDryRunAdapter
            )
        }
    }

    private static func projectProducts(
        from fills: [ReleaseV050PortfolioRunJournalFillEvidence]
    ) throws -> [ReleaseV050PortfolioRunJournalProductProjection] {
        let grouped = Dictionary(grouping: fills, by: \.productType)
        return try grouped.keys.sorted { $0.rawValue < $1.rawValue }.map { productType in
            let productFills = grouped[productType] ?? []
            guard let first = productFills.first else {
                throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("emptyProductFillGroup")
            }
            let quantityMinorUnits = try productFills.reduce(Int64(0)) {
                try checkedSum($0, $1.targetQuantity.minorUnits, "productQuantity")
            }
            let exposureMinorUnits = try productFills.reduce(Int64(0)) {
                try checkedSum($0, $1.notionalExposure.minorUnits, "productExposure")
            }
            let pnlMinorUnits = try productFills.reduce(Int64(0)) {
                try checkedSum($0, $1.projectedPnLLike.minorUnits, "productPnL")
            }
            let marginMinorUnits = try productFills.reduce(Int64(0)) {
                try checkedSum($0, $1.marginLikeRequirement.minorUnits, "productMargin")
            }
            return try ReleaseV050PortfolioRunJournalProductProjection(
                projectionID: Identifier.constant("gh-736-\(productType.rawValue)-portfolio-projection"),
                runID: first.runID,
                productType: productType,
                instrument: first.instrument,
                sourceFillIDs: productFills.map(\.fillID),
                sourceJournalSequences: productFills.map(\.sourceJournalSequence),
                netPositionQuantity: try ReleaseV050FixedPointValue(
                    minorUnits: quantityMinorUnits,
                    scale: first.targetQuantity.scale,
                    semantic: .quantity
                ),
                grossExposure: try ReleaseV050FixedPointValue(
                    minorUnits: exposureMinorUnits,
                    scale: first.notionalExposure.scale,
                    semantic: .notional
                ),
                projectedPnLLike: try ReleaseV050FixedPointValue(
                    minorUnits: pnlMinorUnits,
                    scale: first.projectedPnLLike.scale,
                    semantic: .money,
                    allowsZero: true
                ),
                marginLikeRequirement: try ReleaseV050FixedPointValue(
                    minorUnits: marginMinorUnits,
                    scale: first.marginLikeRequirement.scale,
                    semantic: .notional,
                    allowsZero: true
                )
            )
        }
    }

    private static func projectionEvents(
        from productProjections: [ReleaseV050PortfolioRunJournalProductProjection]
    ) throws -> [PortfolioProjectionEvent] {
        try productProjections.map { projection in
            try PortfolioProjectionEvent(
                projectionID: projection.projectionID,
                instrument: projection.instrument,
                notionalExposure: projection.grossExposure
            )
        }
    }

    private static func state(
        runID: Identifier,
        sourceJournalLatestChecksum: String,
        sourceJournalEventCount: Int,
        productProjections: [ReleaseV050PortfolioRunJournalProductProjection]
    ) throws -> ReleaseV050PortfolioRunJournalProjectionState {
        guard let first = productProjections.first else {
            throw ReleaseV050PortfolioRunJournalProjectionError.contractDrift("missingProductProjection")
        }
        let exposure = try productProjections.reduce(Int64(0)) {
            try checkedSum($0, $1.grossExposure.minorUnits, "stateExposure")
        }
        let pnl = try productProjections.reduce(Int64(0)) {
            try checkedSum($0, $1.projectedPnLLike.minorUnits, "statePnL")
        }
        let margin = try productProjections.reduce(Int64(0)) {
            try checkedSum($0, $1.marginLikeRequirement.minorUnits, "stateMargin")
        }
        return try ReleaseV050PortfolioRunJournalProjectionState(
            runID: runID,
            sourceJournalLatestChecksum: sourceJournalLatestChecksum,
            sourceJournalEventCount: sourceJournalEventCount,
            productProjections: productProjections,
            totalGrossExposure: try ReleaseV050FixedPointValue(
                minorUnits: exposure,
                scale: first.grossExposure.scale,
                semantic: .notional
            ),
            totalProjectedPnLLike: try ReleaseV050FixedPointValue(
                minorUnits: pnl,
                scale: first.projectedPnLLike.scale,
                semantic: .money,
                allowsZero: true
            ),
            totalMarginLikeRequirement: try ReleaseV050FixedPointValue(
                minorUnits: margin,
                scale: first.marginLikeRequirement.scale,
                semantic: .notional,
                allowsZero: true
            )
        )
    }

    private static func notionalValue(
        quantity: ReleaseV050FixedPointValue,
        price: ReleaseV050FixedPointValue,
        resultScale: Int
    ) throws -> ReleaseV050FixedPointValue {
        let minorUnits = try scaledProduct(
            quantity.minorUnits,
            quantity.scale,
            price.minorUnits,
            price.scale,
            resultScale,
            "notionalExposure"
        )
        return try ReleaseV050FixedPointValue.notional(minorUnits: minorUnits, scale: resultScale)
    }

    private static func moneyValue(
        quantity: ReleaseV050FixedPointValue,
        entry: ReleaseV050InstrumentCatalogEntry,
        referencePrice: ReleaseV050FixedPointValue,
        markPrice: ReleaseV050FixedPointValue
    ) throws -> ReleaseV050FixedPointValue {
        let priceDelta = try checkedSubtract(markPrice.minorUnits, referencePrice.minorUnits, "priceDelta")
        let minorUnits = try scaledProduct(
            quantity.minorUnits,
            quantity.scale,
            priceDelta,
            referencePrice.scale,
            entry.precisionPolicy.moneyScale,
            "projectedPnLLike"
        )
        return try ReleaseV050FixedPointValue(
            minorUnits: minorUnits,
            scale: entry.precisionPolicy.moneyScale,
            semantic: .money,
            allowsZero: true
        )
    }

    private static func marginLikeValue(
        notional: ReleaseV050FixedPointValue,
        productType: ProductType
    ) throws -> ReleaseV050FixedPointValue {
        let minorUnits: Int64
        switch productType {
        case .spot:
            minorUnits = 0
        case .usdsPerpetual:
            minorUnits = notional.minorUnits / 10
        }
        return try ReleaseV050FixedPointValue(
            minorUnits: minorUnits,
            scale: notional.scale,
            semantic: .notional,
            allowsZero: true
        )
    }

    private static func scaledProduct(
        _ lhsMinorUnits: Int64,
        _ lhsScale: Int,
        _ rhsMinorUnits: Int64,
        _ rhsScale: Int,
        _ resultScale: Int,
        _ field: String
    ) throws -> Int64 {
        var product = try checkedProduct(lhsMinorUnits, rhsMinorUnits, field)
        let sourceScale = lhsScale + rhsScale
        if resultScale >= sourceScale {
            product = try checkedProduct(product, pow10(resultScale - sourceScale), field)
        } else {
            product /= pow10(sourceScale - resultScale)
        }
        guard product >= 0 else {
            throw ReleaseV050PortfolioRunJournalProjectionError.invalidFixedPointComputation(field)
        }
        return product
    }

    private static func checkedProduct(_ lhs: Int64, _ rhs: Int64, _ field: String) throws -> Int64 {
        let result = lhs.multipliedReportingOverflow(by: rhs)
        guard result.overflow == false else {
            throw ReleaseV050PortfolioRunJournalProjectionError.invalidFixedPointComputation(field)
        }
        return result.partialValue
    }

    private static func checkedSum(_ lhs: Int64, _ rhs: Int64, _ field: String) throws -> Int64 {
        let result = lhs.addingReportingOverflow(rhs)
        guard result.overflow == false else {
            throw ReleaseV050PortfolioRunJournalProjectionError.invalidFixedPointComputation(field)
        }
        return result.partialValue
    }

    private static func checkedSubtract(_ lhs: Int64, _ rhs: Int64, _ field: String) throws -> Int64 {
        let result = lhs.subtractingReportingOverflow(rhs)
        guard result.overflow == false, result.partialValue >= 0 else {
            throw ReleaseV050PortfolioRunJournalProjectionError.invalidFixedPointComputation(field)
        }
        return result.partialValue
    }

    private static func pow10(_ exponent: Int) -> Int64 {
        precondition(exponent >= 0 && exponent <= 18, "Release v0.5.0 fixed-point scale exponent must be 0...18")
        return (0..<exponent).reduce(Int64(1)) { value, _ in value * 10 }
    }
}

/// ReleaseV050PortfolioRunJournalProjectionRunner 保留 GH-736 readiness vocabulary。
public typealias ReleaseV050PortfolioRunJournalProjectionRunner = ReleaseV050PortfolioRunJournalProjection
