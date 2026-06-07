import DomainModel
import ExecutionClient
import Foundation
import MessageBus
import Portfolio

/// ReleaseV010PortfolioReconciliationStatus 固定 GH-533 必须审计的 reconciliation 结果。
public enum ReleaseV010PortfolioReconciliationStatus:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case matched
    case mismatched
    case stale
    case blocked
}

/// ReleaseV010PortfolioReconciliationReason 固定 GH-533 mismatch / stale / blocked 的原因分类。
public enum ReleaseV010PortfolioReconciliationReason:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case none
    case accountPositionQuantityMismatch = "account position quantity mismatch"
    case accountSnapshotStale = "account snapshot stale"
    case accountSnapshotBlocked = "account snapshot blocked"
}

/// ReleaseV010AccountSnapshotFreshness 固定 GH-533 可消费的 account evidence freshness。
public enum ReleaseV010AccountSnapshotFreshness:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case fresh
    case stale
    case blocked
}

/// ReleaseV010AccountPortfolioSnapshotEvidence 是 GH-533 的 normalized account evidence 输入。
///
/// 该 evidence 代表 GH-526 account / balance / position read-model 的安全摘要。它不引入 `DataClient`
/// dependency，不保存 raw private payload，不暴露 listenKey、secret、broker state 或 command surface。
/// `GH-533-ACCOUNT-POSITION-BALANCE-SNAPSHOT-EVIDENCE`
public struct ReleaseV010AccountPortfolioSnapshotEvidence: Codable, Equatable, Sendable {
    public let snapshotID: Identifier
    public let sourceIssueID: Identifier
    public let accountID: Identifier
    public let portfolioID: Identifier
    public let symbol: Symbol
    public let asset: String
    public let freeBalance: Double
    public let lockedBalance: Double
    public let accountPositionQuantity: Quantity
    public let referencePrice: Price
    public let freshness: ReleaseV010AccountSnapshotFreshness
    public let observedAt: Date
    public let readModelOnly: Bool
    public let rawPrivatePayloadExposed: Bool
    public let listenKeyValueExposed: Bool
    public let commandRuntimeEnabled: Bool
    public let readsProductionAccountEndpoint: Bool
    public let syncsBrokerPosition: Bool

    public var totalBalance: Double {
        freeBalance + lockedBalance
    }

    public var accountEvidenceBoundaryHeld: Bool {
        sourceIssueID.rawValue == "GH-526"
            && asset.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && freeBalance.isFinite
            && freeBalance >= 0
            && lockedBalance.isFinite
            && lockedBalance >= 0
            && readModelOnly
            && [
                rawPrivatePayloadExposed,
                listenKeyValueExposed,
                commandRuntimeEnabled,
                readsProductionAccountEndpoint,
                syncsBrokerPosition
            ].allSatisfy { $0 == false }
    }

    public init(
        snapshotID: Identifier,
        sourceIssueID: Identifier = Identifier.constant("GH-526"),
        accountID: Identifier,
        portfolioID: Identifier,
        symbol: Symbol,
        asset: String = "USDT",
        freeBalance: Double,
        lockedBalance: Double,
        accountPositionQuantity: Quantity,
        referencePrice: Price,
        freshness: ReleaseV010AccountSnapshotFreshness,
        observedAt: Date,
        readModelOnly: Bool = true,
        rawPrivatePayloadExposed: Bool = false,
        listenKeyValueExposed: Bool = false,
        commandRuntimeEnabled: Bool = false,
        readsProductionAccountEndpoint: Bool = false,
        syncsBrokerPosition: Bool = false
    ) throws {
        let trimmedAsset = asset.trimmingCharacters(in: .whitespacesAndNewlines)
        guard sourceIssueID.rawValue == "GH-526" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "sourceIssueID",
                expected: "GH-526",
                actual: sourceIssueID.rawValue
            )
        }
        guard trimmedAsset.isEmpty == false else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "asset",
                expected: "non-empty asset",
                actual: "empty"
            )
        }
        try Self.validateFiniteNonNegative(freeBalance, field: "freeBalance")
        try Self.validateFiniteNonNegative(lockedBalance, field: "lockedBalance")
        guard readModelOnly else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010Portfolio.readModelOnly=false")
        }
        for forbiddenFlag in [
            ("rawPrivatePayloadExposed", rawPrivatePayloadExposed),
            ("listenKeyValueExposed", listenKeyValueExposed),
            ("commandRuntimeEnabled", commandRuntimeEnabled),
            ("readsProductionAccountEndpoint", readsProductionAccountEndpoint),
            ("syncsBrokerPosition", syncsBrokerPosition)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010Portfolio.\(forbiddenFlag.0)")
        }

        self.snapshotID = snapshotID
        self.sourceIssueID = sourceIssueID
        self.accountID = accountID
        self.portfolioID = portfolioID
        self.symbol = symbol
        self.asset = trimmedAsset
        self.freeBalance = freeBalance
        self.lockedBalance = lockedBalance
        self.accountPositionQuantity = accountPositionQuantity
        self.referencePrice = referencePrice
        self.freshness = freshness
        self.observedAt = observedAt
        self.readModelOnly = readModelOnly
        self.rawPrivatePayloadExposed = rawPrivatePayloadExposed
        self.listenKeyValueExposed = listenKeyValueExposed
        self.commandRuntimeEnabled = commandRuntimeEnabled
        self.readsProductionAccountEndpoint = readsProductionAccountEndpoint
        self.syncsBrokerPosition = syncsBrokerPosition
    }

    private static func validateFiniteNonNegative(_ value: Double, field: String) throws {
        guard value.isFinite, value >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: field,
                expected: "finite non-negative value",
                actual: "\(value)"
            )
        }
    }
}

/// ReleaseV010PortfolioUpdateProjection 是 GH-533 的 Portfolio update evidence。
///
/// Projection 从 #532 execution event 和 GH-526 account evidence 计算 positions / net positions /
/// margin / open value。它是 evidence，不 mutate Portfolio runtime，不写 production account store。
/// `GH-533-PORTFOLIO-UPDATE-PATH`
public struct ReleaseV010PortfolioUpdateProjection: Codable, Equatable, Sendable {
    public let updateID: Identifier
    public let sourceExecutionEventID: Identifier
    public let sourceAccountSnapshotID: Identifier
    public let portfolioID: Identifier
    public let symbol: Symbol
    public let exposure: PortfolioExposureSnapshot
    public let financialState: PortfolioFinancialStateProjection
    public let netPositionQuantity: Quantity
    public let marginRequirement: Double
    public let openValue: Double
    public let updatedAt: Date
    public let updatesPortfolioProjection: Bool
    public let portfolioRuntimeMutated: Bool
    public let readsProductionAccountEndpoint: Bool
    public let syncsBrokerPosition: Bool
    public let authorizesTradingExecution: Bool

    public var updateBoundaryHeld: Bool {
        exposure.source == .paperProjection
            && financialState.paperOnlyBoundaryHeld
            && financialState.exposure == exposure
            && openValue == exposure.grossExposureNotional
            && marginRequirement.isFinite
            && marginRequirement >= 0
            && updatesPortfolioProjection
            && [
                portfolioRuntimeMutated,
                readsProductionAccountEndpoint,
                syncsBrokerPosition,
                authorizesTradingExecution
            ].allSatisfy { $0 == false }
    }

    public init(
        updateID: Identifier,
        sourceExecutionEventID: Identifier,
        sourceAccountSnapshotID: Identifier,
        portfolioID: Identifier,
        symbol: Symbol,
        exposure: PortfolioExposureSnapshot,
        netPositionQuantity: Quantity,
        marginRequirement: Double,
        openValue: Double,
        updatedAt: Date,
        updatesPortfolioProjection: Bool = true,
        portfolioRuntimeMutated: Bool = false,
        readsProductionAccountEndpoint: Bool = false,
        syncsBrokerPosition: Bool = false,
        authorizesTradingExecution: Bool = false
    ) throws {
        try Self.validateFiniteNonNegative(marginRequirement, field: "marginRequirement")
        try Self.validateFiniteNonNegative(openValue, field: "openValue")
        guard exposure.portfolioID == portfolioID else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "exposure.portfolioID",
                expected: portfolioID.rawValue,
                actual: exposure.portfolioID.rawValue
            )
        }
        guard exposure.symbol == symbol else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "exposure.symbol",
                expected: symbol.rawValue,
                actual: exposure.symbol.rawValue
            )
        }
        guard exposure.source == .paperProjection else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "exposure.source",
                expected: PortfolioExposureSource.paperProjection.rawValue,
                actual: exposure.source.rawValue
            )
        }
        guard openValue == exposure.grossExposureNotional else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "openValue",
                expected: "\(exposure.grossExposureNotional)",
                actual: "\(openValue)"
            )
        }
        guard updatesPortfolioProjection else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: "updatesPortfolioProjection",
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("portfolioRuntimeMutated", portfolioRuntimeMutated),
            ("readsProductionAccountEndpoint", readsProductionAccountEndpoint),
            ("syncsBrokerPosition", syncsBrokerPosition),
            ("authorizesTradingExecution", authorizesTradingExecution)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010Portfolio.\(forbiddenFlag.0)")
        }

        let state = try PortfolioFinancialStateProjection(
            projectionID: Identifier.constant("\(updateID.rawValue)-financial-state"),
            exposure: exposure,
            projectedAt: updatedAt
        )

        self.updateID = updateID
        self.sourceExecutionEventID = sourceExecutionEventID
        self.sourceAccountSnapshotID = sourceAccountSnapshotID
        self.portfolioID = portfolioID
        self.symbol = symbol
        self.exposure = exposure
        self.financialState = state
        self.netPositionQuantity = netPositionQuantity
        self.marginRequirement = marginRequirement
        self.openValue = openValue
        self.updatedAt = updatedAt
        self.updatesPortfolioProjection = updatesPortfolioProjection
        self.portfolioRuntimeMutated = portfolioRuntimeMutated
        self.readsProductionAccountEndpoint = readsProductionAccountEndpoint
        self.syncsBrokerPosition = syncsBrokerPosition
        self.authorizesTradingExecution = authorizesTradingExecution
    }

    private static func validateFiniteNonNegative(_ value: Double, field: String) throws {
        guard value.isFinite, value >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: field,
                expected: "finite non-negative value",
                actual: "\(value)"
            )
        }
    }
}

/// ReleaseV010PortfolioReconciliationRecord 是 GH-533 的单条 execution/account/portfolio 对账记录。
/// `GH-533-MISMATCH-STALE-BLOCKED-AUDIT-EVIDENCE`
public struct ReleaseV010PortfolioReconciliationRecord: Codable, Equatable, Sendable {
    public let recordID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let status: ReleaseV010PortfolioReconciliationStatus
    public let executionEvent: ReleaseV010ExecutionEngineBrokerFillEvent
    public let accountSnapshot: ReleaseV010AccountPortfolioSnapshotEvidence
    public let portfolioUpdate: ReleaseV010PortfolioUpdateProjection?
    public let reasons: [ReleaseV010PortfolioReconciliationReason]
    public let deterministicAuditEvidence: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let repairCommandProduced: Bool
    public let dashboardCommandSurfaceTouched: Bool

    public var recordBoundaryHeld: Bool {
        issueID.rawValue == "GH-533"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-530", "GH-532"]
            && executionEvent.eventBoundaryHeld
            && accountSnapshot.accountEvidenceBoundaryHeld
            && statusReasonBoundaryHeld
            && deterministicAuditEvidence
            && [
                productionTradingEnabledByDefault,
                productionAccountEndpointRead,
                brokerGatewayTouched,
                repairCommandProduced,
                dashboardCommandSurfaceTouched
            ].allSatisfy { $0 == false }
    }

    private var statusReasonBoundaryHeld: Bool {
        switch status {
        case .matched:
            reasons == [.none]
                && portfolioUpdate?.updateBoundaryHeld == true
                && quantitiesMatch
        case .mismatched:
            reasons.contains(.accountPositionQuantityMismatch)
                && portfolioUpdate?.updateBoundaryHeld == true
                && quantitiesMatch == false
        case .stale:
            reasons == [.accountSnapshotStale]
                && accountSnapshot.freshness == .stale
                && portfolioUpdate == nil
        case .blocked:
            reasons == [.accountSnapshotBlocked]
                && accountSnapshot.freshness == .blocked
                && portfolioUpdate == nil
        }
    }

    private var quantitiesMatch: Bool {
        guard let cumulative = Double(executionEvent.cumulativeFilledQuantity) else {
            return false
        }
        return accountSnapshot.accountPositionQuantity.rawValue == cumulative
    }

    public init(
        recordID: Identifier,
        issueID: Identifier = Identifier.constant("GH-533"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-530"),
            Identifier.constant("GH-532")
        ],
        status: ReleaseV010PortfolioReconciliationStatus,
        executionEvent: ReleaseV010ExecutionEngineBrokerFillEvent,
        accountSnapshot: ReleaseV010AccountPortfolioSnapshotEvidence,
        portfolioUpdate: ReleaseV010PortfolioUpdateProjection?,
        reasons: [ReleaseV010PortfolioReconciliationReason],
        deterministicAuditEvidence: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        repairCommandProduced: Bool = false,
        dashboardCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-533" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-533",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-530", "GH-532"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-530,GH-532",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard executionEvent.eventBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "executionEvent",
                expected: "GH-532 event boundary held",
                actual: "mismatch"
            )
        }
        guard accountSnapshot.accountEvidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "accountSnapshot",
                expected: "GH-526 account evidence boundary held",
                actual: "mismatch"
            )
        }
        guard deterministicAuditEvidence else {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010Portfolio.deterministicAuditEvidence")
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("repairCommandProduced", repairCommandProduced),
            ("dashboardCommandSurfaceTouched", dashboardCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010Portfolio.\(forbiddenFlag.0)")
        }

        self.recordID = recordID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.status = status
        self.executionEvent = executionEvent
        self.accountSnapshot = accountSnapshot
        self.portfolioUpdate = portfolioUpdate
        self.reasons = reasons
        self.deterministicAuditEvidence = deterministicAuditEvidence
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.repairCommandProduced = repairCommandProduced
        self.dashboardCommandSurfaceTouched = dashboardCommandSurfaceTouched

        guard recordBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "recordBoundaryHeld",
                expected: "\(status.rawValue) GH-533 reconciliation record boundary held",
                actual: "mismatch"
            )
        }
    }
}

/// ReleaseV010PortfolioReconciliationUpdateEvidence 汇总 GH-533 的最终 evidence。
/// `GH-533-EXECUTION-ACCOUNT-PORTFOLIO-RECONCILIATION`
/// `TVM-RELEASE-V010-PORTFOLIO-RECONCILIATION-UPDATE-PATH`
public struct ReleaseV010PortfolioReconciliationUpdateEvidence: Codable, Equatable, Sendable {
    public let evidenceID: Identifier
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let parserEvidence: ReleaseV010BinanceExecutionReportParserEvidence
    public let records: [ReleaseV010PortfolioReconciliationRecord]
    public let validationAnchors: [String]
    public let portfolioCanUpdateFromExecutionAndAccountEvidence: Bool
    public let mismatchStaleBlockedAuditable: Bool
    public let positionsNetMarginOpenValueCovered: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let repairCommandProduced: Bool
    public let dashboardCommandSurfaceTouched: Bool

    public var evidenceBoundaryHeld: Bool {
        issueID.rawValue == "GH-533"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-530", "GH-532"]
            && parserEvidence.evidenceBoundaryHeld
            && records.allSatisfy(\.recordBoundaryHeld)
            && Set(records.map(\.status)) == Set(ReleaseV010PortfolioReconciliationStatus.allCases)
            && validationAnchors == ReleaseV010PortfolioReconciliationUpdatePath.requiredValidationAnchors
            && portfolioCanUpdateFromExecutionAndAccountEvidence
            && mismatchStaleBlockedAuditable
            && positionsNetMarginOpenValueCovered
            && [
                productionTradingEnabledByDefault,
                productionAccountEndpointRead,
                brokerGatewayTouched,
                repairCommandProduced,
                dashboardCommandSurfaceTouched
            ].allSatisfy { $0 == false }
    }

    public init(
        evidenceID: Identifier = Identifier.constant("gh-533-portfolio-reconciliation-update-evidence"),
        issueID: Identifier = Identifier.constant("GH-533"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-530"),
            Identifier.constant("GH-532")
        ],
        parserEvidence: ReleaseV010BinanceExecutionReportParserEvidence,
        records: [ReleaseV010PortfolioReconciliationRecord],
        validationAnchors: [String] = ReleaseV010PortfolioReconciliationUpdatePath.requiredValidationAnchors,
        portfolioCanUpdateFromExecutionAndAccountEvidence: Bool = true,
        mismatchStaleBlockedAuditable: Bool = true,
        positionsNetMarginOpenValueCovered: Bool = true,
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        repairCommandProduced: Bool = false,
        dashboardCommandSurfaceTouched: Bool = false
    ) throws {
        guard issueID.rawValue == "GH-533" else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "issueID",
                expected: "GH-533",
                actual: issueID.rawValue
            )
        }
        guard upstreamIssueIDs.map(\.rawValue) == ["GH-530", "GH-532"] else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "upstreamIssueIDs",
                expected: "GH-530,GH-532",
                actual: upstreamIssueIDs.map(\.rawValue).joined(separator: ",")
            )
        }
        guard parserEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserEvidence",
                expected: "GH-532 parser evidence held",
                actual: "mismatch"
            )
        }
        guard records.allSatisfy(\.recordBoundaryHeld) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "records",
                expected: "all GH-533 reconciliation records held",
                actual: "mismatch"
            )
        }
        guard Set(records.map(\.status)) == Set(ReleaseV010PortfolioReconciliationStatus.allCases) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "records.status",
                expected: ReleaseV010PortfolioReconciliationStatus.allCases.map(\.rawValue).joined(separator: ","),
                actual: records.map { $0.status.rawValue }.joined(separator: ",")
            )
        }
        guard validationAnchors == ReleaseV010PortfolioReconciliationUpdatePath.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: ReleaseV010PortfolioReconciliationUpdatePath.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for requiredFlag in [
            ("portfolioCanUpdateFromExecutionAndAccountEvidence", portfolioCanUpdateFromExecutionAndAccountEvidence),
            ("mismatchStaleBlockedAuditable", mismatchStaleBlockedAuditable),
            ("positionsNetMarginOpenValueCovered", positionsNetMarginOpenValueCovered)
        ] where requiredFlag.1 == false {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: requiredFlag.0,
                expected: "true",
                actual: "false"
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("repairCommandProduced", repairCommandProduced),
            ("dashboardCommandSurfaceTouched", dashboardCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010Portfolio.\(forbiddenFlag.0)")
        }

        self.evidenceID = evidenceID
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.parserEvidence = parserEvidence
        self.records = records
        self.validationAnchors = validationAnchors
        self.portfolioCanUpdateFromExecutionAndAccountEvidence = portfolioCanUpdateFromExecutionAndAccountEvidence
        self.mismatchStaleBlockedAuditable = mismatchStaleBlockedAuditable
        self.positionsNetMarginOpenValueCovered = positionsNetMarginOpenValueCovered
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.repairCommandProduced = repairCommandProduced
        self.dashboardCommandSurfaceTouched = dashboardCommandSurfaceTouched
    }
}

/// ReleaseV010PortfolioReconciliationUpdatePath 是 GH-533 的 deterministic evidence builder。
///
/// Builder 名称只表示本地 release evidence path；它不启用 production reconciliation runtime、
/// 不读取 production account endpoint、不连接 broker、不生成 repair command。
public struct ReleaseV010PortfolioReconciliationUpdatePath: Codable, Equatable, Sendable {
    public let pathID: Identifier
    public let parserEvidence: ReleaseV010BinanceExecutionReportParserEvidence
    public let validationAnchors: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionAccountEndpointRead: Bool
    public let brokerGatewayTouched: Bool
    public let repairCommandProduced: Bool
    public let dashboardCommandSurfaceTouched: Bool

    public var pathBoundaryHeld: Bool {
        parserEvidence.evidenceBoundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
            && [
                productionTradingEnabledByDefault,
                productionAccountEndpointRead,
                brokerGatewayTouched,
                repairCommandProduced,
                dashboardCommandSurfaceTouched
            ].allSatisfy { $0 == false }
    }

    public init(
        pathID: Identifier = Identifier.constant("gh-533-portfolio-reconciliation-update-path"),
        parserEvidence: ReleaseV010BinanceExecutionReportParserEvidence? = nil,
        validationAnchors: [String] = Self.requiredValidationAnchors,
        productionTradingEnabledByDefault: Bool = false,
        productionAccountEndpointRead: Bool = false,
        brokerGatewayTouched: Bool = false,
        repairCommandProduced: Bool = false,
        dashboardCommandSurfaceTouched: Bool = false
    ) throws {
        let resolvedParserEvidence = try parserEvidence
            ?? ReleaseV010BinanceExecutionReportParser.deterministicFixture().deterministicParserEvidence()
        guard resolvedParserEvidence.evidenceBoundaryHeld else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserEvidence",
                expected: "GH-532 parser evidence held",
                actual: "mismatch"
            )
        }
        guard validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "validationAnchors",
                expected: Self.requiredValidationAnchors.joined(separator: ","),
                actual: validationAnchors.joined(separator: ",")
            )
        }
        for forbiddenFlag in [
            ("productionTradingEnabledByDefault", productionTradingEnabledByDefault),
            ("productionAccountEndpointRead", productionAccountEndpointRead),
            ("brokerGatewayTouched", brokerGatewayTouched),
            ("repairCommandProduced", repairCommandProduced),
            ("dashboardCommandSurfaceTouched", dashboardCommandSurfaceTouched)
        ] where forbiddenFlag.1 {
            throw CoreError.liveTradingBoundaryForbiddenCapability("releaseV010Portfolio.\(forbiddenFlag.0)")
        }

        self.pathID = pathID
        self.parserEvidence = resolvedParserEvidence
        self.validationAnchors = validationAnchors
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionAccountEndpointRead = productionAccountEndpointRead
        self.brokerGatewayTouched = brokerGatewayTouched
        self.repairCommandProduced = repairCommandProduced
        self.dashboardCommandSurfaceTouched = dashboardCommandSurfaceTouched
    }

    public func deterministicEvidence() throws -> ReleaseV010PortfolioReconciliationUpdateEvidence {
        let records = try [
            record(status: .matched, reportKind: .fullFill, sequence: 10, quantity: "0.0100", freshness: .fresh),
            record(status: .mismatched, reportKind: .partialFill, sequence: 20, quantity: "0.0050", freshness: .fresh),
            record(status: .stale, reportKind: .canceled, sequence: 30, quantity: "0.0000", freshness: .stale),
            record(status: .blocked, reportKind: .rejected, sequence: 40, quantity: "0.0000", freshness: .blocked)
        ]
        return try ReleaseV010PortfolioReconciliationUpdateEvidence(
            parserEvidence: parserEvidence,
            records: records
        )
    }

    public static func deterministicFixture() throws -> ReleaseV010PortfolioReconciliationUpdatePath {
        try ReleaseV010PortfolioReconciliationUpdatePath()
    }

    public static let requiredValidationAnchors = [
        "GH-533-EXECUTION-ACCOUNT-PORTFOLIO-RECONCILIATION",
        "GH-533-ACCOUNT-POSITION-BALANCE-SNAPSHOT-EVIDENCE",
        "GH-533-PORTFOLIO-UPDATE-PATH",
        "GH-533-MISMATCH-STALE-BLOCKED-AUDIT-EVIDENCE",
        "GH-533-PRODUCTION-TRADING-STAYS-DISABLED",
        "TVM-RELEASE-V010-PORTFOLIO-RECONCILIATION-UPDATE-PATH"
    ]

    private func record(
        status: ReleaseV010PortfolioReconciliationStatus,
        reportKind: ReleaseV010BinanceExecutionReportKind,
        sequence: Int,
        quantity: String,
        freshness: ReleaseV010AccountSnapshotFreshness
    ) throws -> ReleaseV010PortfolioReconciliationRecord {
        guard let event = parserEvidence.parsedEvents.first(where: { $0.reportKind == reportKind }) else {
            throw CoreError.liveTradingBoundaryContractMismatch(
                field: "parserEvidence.parsedEvents",
                expected: reportKind.rawValue,
                actual: parserEvidence.parsedEvents.map(\.reportKind.rawValue).joined(separator: ",")
            )
        }
        let account = try accountEvidence(
            for: event,
            sequence: sequence,
            quantity: quantity,
            freshness: freshness
        )
        let update: ReleaseV010PortfolioUpdateProjection?
        switch status {
        case .matched, .mismatched:
            update = try portfolioUpdate(for: event, account: account, sequence: sequence)
        case .stale, .blocked:
            update = nil
        }
        return try ReleaseV010PortfolioReconciliationRecord(
            recordID: Identifier.constant("gh-533-\(status.rawValue)-record"),
            status: status,
            executionEvent: event,
            accountSnapshot: account,
            portfolioUpdate: update,
            reasons: reasons(for: status)
        )
    }

    private func accountEvidence(
        for event: ReleaseV010ExecutionEngineBrokerFillEvent,
        sequence: Int,
        quantity: String,
        freshness: ReleaseV010AccountSnapshotFreshness
    ) throws -> ReleaseV010AccountPortfolioSnapshotEvidence {
        let parsedQuantity = try Self.decimal(quantity, field: "accountPositionQuantity")
        let price = try Self.decimal(event.lastExecutedPrice == "0.00" ? "42120.70" : event.lastExecutedPrice, field: "referencePrice")
        return try ReleaseV010AccountPortfolioSnapshotEvidence(
            snapshotID: Identifier.constant("gh-533-\(event.reportKind.rawValue.replacingOccurrences(of: " ", with: "-"))-account"),
            accountID: Identifier.constant("gh-526-release-account"),
            portfolioID: Identifier.constant("gh-533-release-portfolio"),
            symbol: try Symbol(rawValue: event.symbol),
            freeBalance: 100_000,
            lockedBalance: 0,
            accountPositionQuantity: try Quantity(parsedQuantity, field: "accountPositionQuantity"),
            referencePrice: try Price(price, field: "referencePrice"),
            freshness: freshness,
            observedAt: Date(timeIntervalSince1970: 1_704_067_600 + Double(sequence))
        )
    }

    private func portfolioUpdate(
        for event: ReleaseV010ExecutionEngineBrokerFillEvent,
        account: ReleaseV010AccountPortfolioSnapshotEvidence,
        sequence: Int
    ) throws -> ReleaseV010PortfolioUpdateProjection {
        let filledQuantity = try Self.decimal(event.cumulativeFilledQuantity, field: "cumulativeFilledQuantity")
        let referencePrice = try Self.decimal(event.lastExecutedPrice == "0.00" ? "\(account.referencePrice.rawValue)" : event.lastExecutedPrice, field: "lastExecutedPrice")
        let quantity = try Quantity(filledQuantity, field: "portfolioQuantity")
        let price = try Price(referencePrice, field: "portfolioReferencePrice")
        let exposure = PortfolioExposureSnapshot(
            portfolioID: account.portfolioID,
            symbol: account.symbol,
            timeframe: .oneMinute,
            paperQuantity: quantity,
            referencePrice: price,
            source: .paperProjection,
            observedAt: account.observedAt
        )
        return try ReleaseV010PortfolioUpdateProjection(
            updateID: Identifier.constant("gh-533-\(event.reportKind.rawValue.replacingOccurrences(of: " ", with: "-"))-portfolio-update"),
            sourceExecutionEventID: event.eventID,
            sourceAccountSnapshotID: account.snapshotID,
            portfolioID: account.portfolioID,
            symbol: account.symbol,
            exposure: exposure,
            netPositionQuantity: quantity,
            marginRequirement: exposure.grossExposureNotional * 0.10,
            openValue: exposure.grossExposureNotional,
            updatedAt: Date(timeIntervalSince1970: 1_704_067_700 + Double(sequence))
        )
    }

    private func reasons(
        for status: ReleaseV010PortfolioReconciliationStatus
    ) -> [ReleaseV010PortfolioReconciliationReason] {
        switch status {
        case .matched:
            [.none]
        case .mismatched:
            [.accountPositionQuantityMismatch]
        case .stale:
            [.accountSnapshotStale]
        case .blocked:
            [.accountSnapshotBlocked]
        }
    }

    private static func decimal(_ value: String, field: String) throws -> Double {
        guard let parsed = Double(value), parsed.isFinite, parsed >= 0 else {
            throw CoreError.paperPortfolioProjectionMismatch(
                field: field,
                expected: "finite non-negative decimal string",
                actual: value
            )
        }
        return parsed
    }
}
