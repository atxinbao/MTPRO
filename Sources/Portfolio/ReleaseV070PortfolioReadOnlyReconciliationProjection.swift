import DomainModel
import Foundation

/// ReleaseV070PortfolioReadOnlyReconciliationProjectionError 描述 GH-790 read-only reconciliation 的合同错误。
///
/// 错误只覆盖本地 journal expected state、testnet read-only observed state、diff artifact replay
/// 和禁止写路径；它不表达 broker correction、production account sync、真实 PnL 归属或交易调整命令。
public enum ReleaseV070PortfolioReadOnlyReconciliationProjectionError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyExpectedProjection
    case emptyObservedState
    case invalidObservedAsset(String)
    case missingDiffRecords
    case replayMismatch
    case artifactBoundaryMismatch(String)
    case forbiddenCapability(String)

    public var description: String {
        switch self {
        case .emptyExpectedProjection:
            "Release v0.7.0 Portfolio read-only reconciliation requires expected journal projection"
        case .emptyObservedState:
            "Release v0.7.0 Portfolio read-only reconciliation requires read-only observed state"
        case let .invalidObservedAsset(asset):
            "Release v0.7.0 Portfolio read-only reconciliation invalid observed asset: \(asset)"
        case .missingDiffRecords:
            "Release v0.7.0 Portfolio read-only reconciliation requires diff records"
        case .replayMismatch:
            "Release v0.7.0 Portfolio read-only reconciliation replayed diffs do not match"
        case let .artifactBoundaryMismatch(reason):
            "Release v0.7.0 Portfolio read-only reconciliation artifact boundary mismatch: \(reason)"
        case let .forbiddenCapability(capability):
            "Release v0.7.0 Portfolio read-only reconciliation rejected forbidden capability: \(capability)"
        }
    }
}

/// ReleaseV070PortfolioReadOnlyReconciliationDiffStatus 固定 #790 diff 的解释状态。
///
/// 这些状态只用于解释 expected vs observed 的差异；任何状态都不授权 correction command、
/// broker write、account mutation、production account sync 或交易调整。
public enum ReleaseV070PortfolioReadOnlyReconciliationDiffStatus: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
    case matchedReadOnlyObservation = "matched-read-only-observation"
    case explanatoryDelta = "explanatory-delta"
    case missingObservedState = "missing-observed-state"
}

/// ReleaseV070PortfolioReadOnlyObservedAssetState 是 #790 的本地 observed state 值对象。
///
/// 调用方可以从 GH-786 signed account artifact 或 GH-787 private stream read model 映射到该值对象。
/// Portfolio target 只消费这个值对象，不依赖 DataClient target，也不读取 account endpoint。
public struct ReleaseV070PortfolioReadOnlyObservedAssetState: Codable, Equatable, Sendable {
    public let asset: String
    public let free: Decimal
    public let locked: Decimal
    public let total: Decimal
    public let sourceLabel: String
    public let readOnly: Bool
    public let redacted: Bool
    public let commandSurfaceEnabled: Bool
    public let brokerWritePathEnabled: Bool

    public var stateHeld: Bool {
        asset.isEmpty == false
            && total == free + locked
            && sourceLabel.isEmpty == false
            && readOnly
            && redacted
            && commandSurfaceEnabled == false
            && brokerWritePathEnabled == false
    }

    public init(
        asset: String,
        free: Decimal,
        locked: Decimal,
        sourceLabel: String,
        readOnly: Bool = true,
        redacted: Bool = true,
        commandSurfaceEnabled: Bool = false,
        brokerWritePathEnabled: Bool = false
    ) throws {
        let trimmedAsset = asset.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSource = sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedAsset.isEmpty == false else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.invalidObservedAsset(asset)
        }
        guard readOnly else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.forbiddenCapability("observedAsset.readOnly=false")
        }
        guard redacted else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.forbiddenCapability("observedAsset.redacted=false")
        }
        try Self.reject(commandSurfaceEnabled, "observedAsset.commandSurfaceEnabled")
        try Self.reject(brokerWritePathEnabled, "observedAsset.brokerWritePathEnabled")

        self.asset = trimmedAsset
        self.free = free
        self.locked = locked
        self.total = free + locked
        self.sourceLabel = trimmedSource
        self.readOnly = readOnly
        self.redacted = redacted
        self.commandSurfaceEnabled = commandSurfaceEnabled
        self.brokerWritePathEnabled = brokerWritePathEnabled

        guard stateHeld else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.artifactBoundaryMismatch("observedAssetStateHeld")
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.forbiddenCapability(field)
        }
    }
}

/// ReleaseV070PortfolioReadOnlyObservedState 汇总 #790 可选 testnet read-only observation。
///
/// 该 observed state 只保存 redacted source identity、asset-level read model 和 no-order proof；
/// 它不是 production account state，也不能驱动 correction command。
public struct ReleaseV070PortfolioReadOnlyObservedState: Codable, Equatable, Sendable {
    public let signedAccountIssueID: Identifier
    public let privateStreamIssueID: Identifier
    public let signedAccountCredentialReference: String
    public let privateStreamCredentialReference: String
    public let signedAccountAssets: [ReleaseV070PortfolioReadOnlyObservedAssetState]
    public let privateStreamAssets: [ReleaseV070PortfolioReadOnlyObservedAssetState]
    public let privateStreamReadModelRecordCount: Int
    public let operatorConfirmedReadOnlyObservation: Bool
    public let readOnly: Bool
    public let redacted: Bool
    public let productionAccountRead: Bool
    public let productionAccountSync: Bool
    public let brokerCorrectionEnabled: Bool
    public let tradingAdjustmentCommandEnabled: Bool

    public var stateHeld: Bool {
        signedAccountIssueID.rawValue == "GH-786"
            && privateStreamIssueID.rawValue == "GH-787"
            && signedAccountCredentialReference.isEmpty == false
            && privateStreamCredentialReference.isEmpty == false
            && signedAccountAssets.isEmpty == false
            && privateStreamAssets.isEmpty == false
            && signedAccountAssets.allSatisfy(\.stateHeld)
            && privateStreamAssets.allSatisfy(\.stateHeld)
            && privateStreamReadModelRecordCount >= privateStreamAssets.count
            && operatorConfirmedReadOnlyObservation
            && readOnly
            && redacted
            && forbiddenBoundaryHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        productionAccountRead == false
            && productionAccountSync == false
            && brokerCorrectionEnabled == false
            && tradingAdjustmentCommandEnabled == false
    }

    public init(
        signedAccountIssueID: Identifier = Identifier.constant("GH-786"),
        privateStreamIssueID: Identifier = Identifier.constant("GH-787"),
        signedAccountCredentialReference: String,
        privateStreamCredentialReference: String,
        signedAccountAssets: [ReleaseV070PortfolioReadOnlyObservedAssetState],
        privateStreamAssets: [ReleaseV070PortfolioReadOnlyObservedAssetState],
        privateStreamReadModelRecordCount: Int,
        operatorConfirmedReadOnlyObservation: Bool = true,
        readOnly: Bool = true,
        redacted: Bool = true,
        productionAccountRead: Bool = false,
        productionAccountSync: Bool = false,
        brokerCorrectionEnabled: Bool = false,
        tradingAdjustmentCommandEnabled: Bool = false
    ) throws {
        guard signedAccountAssets.isEmpty == false || privateStreamAssets.isEmpty == false else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.emptyObservedState
        }
        guard operatorConfirmedReadOnlyObservation else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.forbiddenCapability("operatorConfirmedReadOnlyObservation=false")
        }
        guard readOnly else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.forbiddenCapability("observedState.readOnly=false")
        }
        guard redacted else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.forbiddenCapability("observedState.redacted=false")
        }
        try Self.reject(productionAccountRead, "productionAccountRead")
        try Self.reject(productionAccountSync, "productionAccountSync")
        try Self.reject(brokerCorrectionEnabled, "brokerCorrectionEnabled")
        try Self.reject(tradingAdjustmentCommandEnabled, "tradingAdjustmentCommandEnabled")

        self.signedAccountIssueID = signedAccountIssueID
        self.privateStreamIssueID = privateStreamIssueID
        self.signedAccountCredentialReference = signedAccountCredentialReference
        self.privateStreamCredentialReference = privateStreamCredentialReference
        self.signedAccountAssets = signedAccountAssets
        self.privateStreamAssets = privateStreamAssets
        self.privateStreamReadModelRecordCount = privateStreamReadModelRecordCount
        self.operatorConfirmedReadOnlyObservation = operatorConfirmedReadOnlyObservation
        self.readOnly = readOnly
        self.redacted = redacted
        self.productionAccountRead = productionAccountRead
        self.productionAccountSync = productionAccountSync
        self.brokerCorrectionEnabled = brokerCorrectionEnabled
        self.tradingAdjustmentCommandEnabled = tradingAdjustmentCommandEnabled

        guard stateHeld else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.artifactBoundaryMismatch("observedStateHeld")
        }
    }

    public func observedTotal(for asset: String) -> Decimal? {
        privateStreamAssets.reversed().first { $0.asset == asset }?.total
            ?? signedAccountAssets.reversed().first { $0.asset == asset }?.total
    }

    public func observedSources(for asset: String) -> [String] {
        (signedAccountAssets + privateStreamAssets)
            .filter { $0.asset == asset }
            .map(\.sourceLabel)
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.forbiddenCapability(field)
        }
    }
}

/// ReleaseV070PortfolioReadOnlyReconciliationDiffRecord 是 #790 单条 expected vs observed diff artifact。
public struct ReleaseV070PortfolioReadOnlyReconciliationDiffRecord: Codable, Equatable, Sendable {
    public let recordID: Identifier
    public let runID: Identifier
    public let productType: ProductType
    public let instrument: InstrumentIdentity
    public let asset: String
    public let expectedQuantity: Decimal
    public let observedTotal: Decimal?
    public let delta: Decimal?
    public let status: ReleaseV070PortfolioReadOnlyReconciliationDiffStatus
    public let observedSources: [String]
    public let explanation: String
    public let artifactPath: String
    public let correctionCommandCreated: Bool
    public let brokerWritePathCreated: Bool
    public let accountMutationCreated: Bool
    public let tradingAdjustmentCommandCreated: Bool
    public let productionAccountReadRequired: Bool

    public var recordHeld: Bool {
        recordID.rawValue.isEmpty == false
            && runID.rawValue.isEmpty == false
            && asset.isEmpty == false
            && explanation.contains("read-only")
            && artifactPath.contains("portfolio-reconciliation")
            && statusHeld
            && forbiddenBoundaryHeld
    }

    public var statusHeld: Bool {
        switch status {
        case .matchedReadOnlyObservation:
            observedTotal == expectedQuantity && delta == 0
        case .explanatoryDelta:
            observedTotal != nil && observedTotal != expectedQuantity && delta != nil
        case .missingObservedState:
            observedTotal == nil && delta == nil
        }
    }

    public var forbiddenBoundaryHeld: Bool {
        correctionCommandCreated == false
            && brokerWritePathCreated == false
            && accountMutationCreated == false
            && tradingAdjustmentCommandCreated == false
            && productionAccountReadRequired == false
    }

    public init(
        recordID: Identifier,
        runID: Identifier,
        productType: ProductType,
        instrument: InstrumentIdentity,
        asset: String,
        expectedQuantity: Decimal,
        observedTotal: Decimal?,
        observedSources: [String],
        artifactPath: String? = nil,
        correctionCommandCreated: Bool = false,
        brokerWritePathCreated: Bool = false,
        accountMutationCreated: Bool = false,
        tradingAdjustmentCommandCreated: Bool = false,
        productionAccountReadRequired: Bool = false
    ) throws {
        let resolvedDelta = observedTotal.map { $0 - expectedQuantity }
        let resolvedStatus: ReleaseV070PortfolioReadOnlyReconciliationDiffStatus
        if let observedTotal {
            resolvedStatus = observedTotal == expectedQuantity ? .matchedReadOnlyObservation : .explanatoryDelta
        } else {
            resolvedStatus = .missingObservedState
        }
        let resolvedArtifactPath = artifactPath
            ?? "runs/\(runID.rawValue)/portfolio-reconciliation/\(recordID.rawValue).json"
        let resolvedExplanation = Self.explanation(
            status: resolvedStatus,
            asset: asset,
            expectedQuantity: expectedQuantity,
            observedTotal: observedTotal,
            observedSources: observedSources
        )

        try Self.reject(correctionCommandCreated, "correctionCommandCreated")
        try Self.reject(brokerWritePathCreated, "brokerWritePathCreated")
        try Self.reject(accountMutationCreated, "accountMutationCreated")
        try Self.reject(tradingAdjustmentCommandCreated, "tradingAdjustmentCommandCreated")
        try Self.reject(productionAccountReadRequired, "productionAccountReadRequired")

        self.recordID = recordID
        self.runID = runID
        self.productType = productType
        self.instrument = instrument
        self.asset = asset
        self.expectedQuantity = expectedQuantity
        self.observedTotal = observedTotal
        self.delta = resolvedDelta
        self.status = resolvedStatus
        self.observedSources = observedSources
        self.explanation = resolvedExplanation
        self.artifactPath = resolvedArtifactPath
        self.correctionCommandCreated = correctionCommandCreated
        self.brokerWritePathCreated = brokerWritePathCreated
        self.accountMutationCreated = accountMutationCreated
        self.tradingAdjustmentCommandCreated = tradingAdjustmentCommandCreated
        self.productionAccountReadRequired = productionAccountReadRequired

        guard recordHeld else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.artifactBoundaryMismatch("diffRecordHeld")
        }
    }

    private static func explanation(
        status: ReleaseV070PortfolioReadOnlyReconciliationDiffStatus,
        asset: String,
        expectedQuantity: Decimal,
        observedTotal: Decimal?,
        observedSources: [String]
    ) -> String {
        switch status {
        case .matchedReadOnlyObservation:
            "read-only observed \(asset) total matches journal expected quantity \(expectedQuantity)"
        case .explanatoryDelta:
            "read-only observed \(asset) total \(observedTotal?.description ?? "missing") differs from journal expected quantity \(expectedQuantity); sources=\(observedSources.joined(separator: ","))"
        case .missingObservedState:
            "read-only observed \(asset) state is unavailable; expected quantity \(expectedQuantity) remains journal-derived only"
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.forbiddenCapability(field)
        }
    }
}

/// ReleaseV070PortfolioReadOnlyReconciliationEvidence 汇总 #790 Portfolio reconciliation evidence。
public struct ReleaseV070PortfolioReadOnlyReconciliationEvidence: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let expectedProjection: ReleaseV050PortfolioRunJournalProjectionEvidence
    public let observedState: ReleaseV070PortfolioReadOnlyObservedState
    public let diffRecords: [ReleaseV070PortfolioReadOnlyReconciliationDiffRecord]
    public let replayedDiffRecords: [ReleaseV070PortfolioReadOnlyReconciliationDiffRecord]
    public let diffArtifactPaths: [String]
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let journalDerivedExpectedState: Bool
    public let testnetReadOnlyObservedStateAvailable: Bool
    public let diffArtifactsExplainOnly: Bool
    public let correctionCommandCreated: Bool
    public let brokerWritePathCreated: Bool
    public let accountMutationCreated: Bool
    public let productionAccountReadRequired: Bool
    public let productionAccountSyncEnabled: Bool
    public let realPnLOwnershipClaimed: Bool
    public let tradingAdjustmentCommandCreated: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var evidenceHeld: Bool {
        issueID.rawValue == "GH-790"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-786", "GH-787", "GH-789"]
            && previousIssueID.rawValue == "GH-789"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-791", "GH-792"]
            && releaseVersion == "v0.7.0"
            && expectedProjection.evidenceHeld
            && observedState.stateHeld
            && diffRecords.isEmpty == false
            && diffRecords.allSatisfy(\.recordHeld)
            && replayedDiffRecords == diffRecords
            && diffArtifactPaths == diffRecords.map(\.artifactPath)
            && validationAnchors == ReleaseV070PortfolioReadOnlyReconciliationContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV070PortfolioReadOnlyReconciliationContract.requiredValidationCommands
            && sourceBoundaryHeld
            && forbiddenBoundaryHeld
    }

    public var sourceBoundaryHeld: Bool {
        journalDerivedExpectedState
            && testnetReadOnlyObservedStateAvailable
            && diffArtifactsExplainOnly
            && diffRecords.contains { $0.status == .explanatoryDelta || $0.status == .matchedReadOnlyObservation }
    }

    public var forbiddenBoundaryHeld: Bool {
        correctionCommandCreated == false
            && brokerWritePathCreated == false
            && accountMutationCreated == false
            && productionAccountReadRequired == false
            && productionAccountSyncEnabled == false
            && realPnLOwnershipClaimed == false
            && tradingAdjustmentCommandCreated == false
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-790"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-786"),
            Identifier.constant("GH-787"),
            Identifier.constant("GH-789")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-789"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-791"), Identifier.constant("GH-792")],
        releaseVersion: String = "v0.7.0",
        expectedProjection: ReleaseV050PortfolioRunJournalProjectionEvidence,
        observedState: ReleaseV070PortfolioReadOnlyObservedState,
        diffRecords: [ReleaseV070PortfolioReadOnlyReconciliationDiffRecord],
        replayedDiffRecords: [ReleaseV070PortfolioReadOnlyReconciliationDiffRecord],
        validationAnchors: [String] = ReleaseV070PortfolioReadOnlyReconciliationContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV070PortfolioReadOnlyReconciliationContract.requiredValidationCommands,
        journalDerivedExpectedState: Bool = true,
        testnetReadOnlyObservedStateAvailable: Bool = true,
        diffArtifactsExplainOnly: Bool = true,
        correctionCommandCreated: Bool = false,
        brokerWritePathCreated: Bool = false,
        accountMutationCreated: Bool = false,
        productionAccountReadRequired: Bool = false,
        productionAccountSyncEnabled: Bool = false,
        realPnLOwnershipClaimed: Bool = false,
        tradingAdjustmentCommandCreated: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        guard diffRecords.isEmpty == false else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.missingDiffRecords
        }
        guard replayedDiffRecords == diffRecords else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.replayMismatch
        }
        try Self.reject(correctionCommandCreated, "correctionCommandCreated")
        try Self.reject(brokerWritePathCreated, "brokerWritePathCreated")
        try Self.reject(accountMutationCreated, "accountMutationCreated")
        try Self.reject(productionAccountReadRequired, "productionAccountReadRequired")
        try Self.reject(productionAccountSyncEnabled, "productionAccountSyncEnabled")
        try Self.reject(realPnLOwnershipClaimed, "realPnLOwnershipClaimed")
        try Self.reject(tradingAdjustmentCommandCreated, "tradingAdjustmentCommandCreated")
        try Self.reject(productionTradingEnabledByDefault, "productionTradingEnabledByDefault")
        try Self.reject(productionSecretAutoReadEnabled, "productionSecretAutoReadEnabled")
        try Self.reject(productionEndpointConnected, "productionEndpointConnected")
        try Self.reject(productionBrokerConnected, "productionBrokerConnected")
        try Self.reject(productionOrderSubmitted, "productionOrderSubmitted")
        try Self.reject(productionCutoverAuthorized, "productionCutoverAuthorized")

        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.expectedProjection = expectedProjection
        self.observedState = observedState
        self.diffRecords = diffRecords
        self.replayedDiffRecords = replayedDiffRecords
        self.diffArtifactPaths = diffRecords.map(\.artifactPath)
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.journalDerivedExpectedState = journalDerivedExpectedState
        self.testnetReadOnlyObservedStateAvailable = testnetReadOnlyObservedStateAvailable
        self.diffArtifactsExplainOnly = diffArtifactsExplainOnly
        self.correctionCommandCreated = correctionCommandCreated
        self.brokerWritePathCreated = brokerWritePathCreated
        self.accountMutationCreated = accountMutationCreated
        self.productionAccountReadRequired = productionAccountReadRequired
        self.productionAccountSyncEnabled = productionAccountSyncEnabled
        self.realPnLOwnershipClaimed = realPnLOwnershipClaimed
        self.tradingAdjustmentCommandCreated = tradingAdjustmentCommandCreated
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard evidenceHeld else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.artifactBoundaryMismatch("evidenceHeld")
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.forbiddenCapability(field)
        }
    }
}

/// ReleaseV070PortfolioReadOnlyReconciliationProjection 生成 #790 deterministic reconciliation evidence。
public enum ReleaseV070PortfolioReadOnlyReconciliationProjection {
    public static func reconcile(
        expectedProjection: ReleaseV050PortfolioRunJournalProjectionEvidence,
        observedState: ReleaseV070PortfolioReadOnlyObservedState
    ) throws -> ReleaseV070PortfolioReadOnlyReconciliationEvidence {
        guard expectedProjection.productProjections.isEmpty == false else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.emptyExpectedProjection
        }
        guard observedState.stateHeld else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.emptyObservedState
        }

        let records = try expectedProjection.productProjections.enumerated().map { index, projection in
            let asset = assetSymbol(from: projection.instrument)
            let expectedQuantity = try decimal(from: projection.netPositionQuantity)
            return try ReleaseV070PortfolioReadOnlyReconciliationDiffRecord(
                recordID: Identifier.constant("gh-790-v070-portfolio-reconciliation-diff-\(index + 1)"),
                runID: expectedProjection.runID,
                productType: projection.productType,
                instrument: projection.instrument,
                asset: asset,
                expectedQuantity: expectedQuantity,
                observedTotal: observedState.observedTotal(for: asset),
                observedSources: observedState.observedSources(for: asset)
            )
        }

        return try ReleaseV070PortfolioReadOnlyReconciliationEvidence(
            expectedProjection: expectedProjection,
            observedState: observedState,
            diffRecords: records,
            replayedDiffRecords: records
        )
    }

    public static func assetSymbol(from instrument: InstrumentIdentity) -> String {
        let symbol = instrument.symbol.rawValue
        if symbol.hasSuffix("USDT") {
            return String(symbol.dropLast(4))
        }
        return symbol
    }

    public static func decimal(from value: ReleaseV050FixedPointValue) throws -> Decimal {
        guard let decimal = Decimal(string: value.description, locale: Locale(identifier: "en_US_POSIX")) else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.artifactBoundaryMismatch("fixedPointDecimal")
        }
        return decimal
    }
}

/// ReleaseV070PortfolioReadOnlyReconciliationContract 固定 GH-790 issue-level 验收合同。
public struct ReleaseV070PortfolioReadOnlyReconciliationContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-790"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-786", "GH-787", "GH-789"]
            && previousIssueID.rawValue == "GH-789"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-791", "GH-792"]
            && releaseVersion == "v0.7.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-790"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-786"),
            Identifier.constant("GH-787"),
            Identifier.constant("GH-789")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-789"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-791"), Identifier.constant("GH-792")],
        releaseVersion: String = "v0.7.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionEndpointAutoConnectEnabled: Bool = false,
        productionBrokerConnectionEnabled: Bool = false,
        productionOrderSubmissionEnabled: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV070PortfolioReadOnlyReconciliationProjectionError.artifactBoundaryMismatch("contractHeld")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV070PortfolioReadOnlyReconciliationContract {
        try ReleaseV070PortfolioReadOnlyReconciliationContract()
    }

    public static let requiredValidationAnchors = [
        "GH-790-VERIFY-V070-PORTFOLIO-READONLY-RECONCILIATION",
        "TVM-RELEASE-V070-PORTFOLIO-READONLY-RECONCILIATION",
        "V070-012-JOURNAL-EXPECTED-VS-TESTNET-OBSERVED",
        "V070-012-DIFF-ARTIFACTS-EXPLAIN-ONLY",
        "V070-012-NO-CORRECTION-COMMAND",
        "V070-012-NO-PRODUCTION-ACCOUNT-READ",
        "V070-012-READONLY-RECONCILIATION-PROJECTION"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH790PortfolioReadOnlyReconciliationExplainsExpectedVsObservedWithoutCommands",
        "bash checks/verify-v0.7.0-portfolio-readonly-reconciliation.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
