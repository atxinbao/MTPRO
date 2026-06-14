import Database
import DomainModel
import Foundation
import MessageBus

/// ReleaseV060PortfolioJournalProjectionRunnerError 描述 GH-763 Portfolio journal projection runner 错误。
///
/// 错误只覆盖本地 run journal replay、Portfolio projection rebuild、projection.json 写入
/// 和 manifest 校验；不表达 broker account sync、production endpoint、secret 或真实资金能力。
public enum ReleaseV060PortfolioJournalProjectionRunnerError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyJournal
    case journalReplayMismatch
    case projectionJSONMismatch
    case projectionRebuildMismatch
    case forbiddenBrokerAccountPayload(String)
    case contractDrift(String)

    public var description: String {
        switch self {
        case .emptyJournal:
            "Release v0.6.0 Portfolio journal projection requires a non-empty local run journal"
        case .journalReplayMismatch:
            "Release v0.6.0 Portfolio journal projection replay does not match append-only records"
        case .projectionJSONMismatch:
            "Release v0.6.0 Portfolio journal projection.json does not match rebuilt projection evidence"
        case .projectionRebuildMismatch:
            "Release v0.6.0 Portfolio journal projection cannot be rebuilt from the same journal"
        case let .forbiddenBrokerAccountPayload(field):
            "Release v0.6.0 Portfolio journal projection rejected broker/account payload field: \(field)"
        case let .contractDrift(reason):
            "Release v0.6.0 Portfolio journal projection contract drift: \(reason)"
        }
    }
}

/// ReleaseV060PortfolioJournalProjectionRunnerResult 汇总 GH-763 的本地 Portfolio projection 证据。
///
/// Result 复用 GH-736 的 fixed-point projection model，但输入升级为 v0.6.0 同一条
/// local run journal。`projection.json` 由 `ReleaseV060LocalRunJournalWriter` 写出并纳入
/// manifest checksum 校验；它仍然只是本地 read model evidence，不是 broker truth。
public struct ReleaseV060PortfolioJournalProjectionRunnerResult: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let runID: Identifier
    public let sourceJournal: ReleaseV050DurableLocalRunJournal
    public let replayedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>]
    public let projectionEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence
    public let decodedProjectionJSONEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence
    public let rebuiltProjectionEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence
    public let writerResult: ReleaseV060LocalRunJournalWriterResult
    public let manifestValidation: ReleaseV060LocalRunJournalManifestValidation
    public let projectionJSONPath: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let journalReplayDerived: Bool
    public let projectionJSONWrittenThroughWriter: Bool
    public let projectionManifestValidated: Bool
    public let projectionRebuildFromJournalHeld: Bool
    public let fixedPointExposureNotionalQuantityHeld: Bool
    public let productionAccountSynced: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionRead: Bool
    public let brokerMarginRead: Bool
    public let brokerLeverageRead: Bool
    public let rawBrokerPayloadStored: Bool
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var resultHeld: Bool {
        issueID.rawValue == "GH-763"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-761", "GH-762"]
            && previousIssueID.rawValue == "GH-762"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
            && sourceJournal.appendOnlyHeld
            && replayedEnvelopes == sourceJournal.records.map(\.envelope)
            && replayedEnvelopes == projectionEvidence.replayedEnvelopes
            && projectionEvidence.evidenceHeld
            && decodedProjectionJSONEvidence == projectionEvidence
            && rebuiltProjectionEvidence == projectionEvidence
            && writerResult.resultHeld
            && writerResult.status.eventCount == sourceJournal.records.count
            && writerResult.manifest.eventCount == sourceJournal.records.count
            && manifestValidation.validationHeld
            && manifestValidation.runID == runID
            && projectionJSONPath.hasSuffix("/projection.json")
            && manifestValidation.artifacts.contains { $0.path == projectionJSONPath && $0.sha256.hasPrefix("sha256:") }
            && validationAnchors == ReleaseV060PortfolioJournalProjectionRunnerContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV060PortfolioJournalProjectionRunnerContract.requiredValidationCommands
            && sourceBoundaryHeld
            && forbiddenBoundaryHeld
    }

    public var sourceBoundaryHeld: Bool {
        journalReplayDerived
            && projectionJSONWrittenThroughWriter
            && projectionManifestValidated
            && projectionRebuildFromJournalHeld
            && fixedPointExposureNotionalQuantityHeld
    }

    public var forbiddenBoundaryHeld: Bool {
        productionAccountSynced == false
            && accountEndpointRead == false
            && brokerPositionRead == false
            && brokerMarginRead == false
            && brokerLeverageRead == false
            && rawBrokerPayloadStored == false
            && productionTradingEnabledByDefault == false
            && productionEndpointConnected == false
            && productionSecretAutoReadEnabled == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-763"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-761"), Identifier.constant("GH-762")],
        previousIssueID: Identifier = Identifier.constant("GH-762"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-764"), Identifier.constant("GH-766")],
        releaseVersion: String = "v0.6.0",
        runID: Identifier,
        sourceJournal: ReleaseV050DurableLocalRunJournal,
        replayedEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>],
        projectionEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence,
        decodedProjectionJSONEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence,
        rebuiltProjectionEvidence: ReleaseV050PortfolioRunJournalProjectionEvidence,
        writerResult: ReleaseV060LocalRunJournalWriterResult,
        manifestValidation: ReleaseV060LocalRunJournalManifestValidation,
        projectionJSONPath: String,
        validationAnchors: [String] = ReleaseV060PortfolioJournalProjectionRunnerContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV060PortfolioJournalProjectionRunnerContract.requiredValidationCommands,
        journalReplayDerived: Bool = true,
        projectionJSONWrittenThroughWriter: Bool = true,
        projectionManifestValidated: Bool = true,
        projectionRebuildFromJournalHeld: Bool = true,
        fixedPointExposureNotionalQuantityHeld: Bool = true,
        productionAccountSynced: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionRead: Bool = false,
        brokerMarginRead: Bool = false,
        brokerLeverageRead: Bool = false,
        rawBrokerPayloadStored: Bool = false,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.runID = runID
        self.sourceJournal = sourceJournal
        self.replayedEnvelopes = replayedEnvelopes
        self.projectionEvidence = projectionEvidence
        self.decodedProjectionJSONEvidence = decodedProjectionJSONEvidence
        self.rebuiltProjectionEvidence = rebuiltProjectionEvidence
        self.writerResult = writerResult
        self.manifestValidation = manifestValidation
        self.projectionJSONPath = projectionJSONPath
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.journalReplayDerived = journalReplayDerived
        self.projectionJSONWrittenThroughWriter = projectionJSONWrittenThroughWriter
        self.projectionManifestValidated = projectionManifestValidated
        self.projectionRebuildFromJournalHeld = projectionRebuildFromJournalHeld
        self.fixedPointExposureNotionalQuantityHeld = fixedPointExposureNotionalQuantityHeld
        self.productionAccountSynced = productionAccountSynced
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionRead = brokerPositionRead
        self.brokerMarginRead = brokerMarginRead
        self.brokerLeverageRead = brokerLeverageRead
        self.rawBrokerPayloadStored = rawBrokerPayloadStored
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        try Self.reject(productionAccountSynced, "productionAccountSynced")
        try Self.reject(accountEndpointRead, "accountEndpointRead")
        try Self.reject(brokerPositionRead, "brokerPositionRead")
        try Self.reject(brokerMarginRead, "brokerMarginRead")
        try Self.reject(brokerLeverageRead, "brokerLeverageRead")
        try Self.reject(rawBrokerPayloadStored, "rawBrokerPayloadStored")

        guard resultHeld else {
            throw ReleaseV060PortfolioJournalProjectionRunnerError.contractDrift("portfolioJournalProjectionResultDrift")
        }
    }

    public static func accountEndpointReadRejectedProbe(
        source: ReleaseV060PortfolioJournalProjectionRunnerResult
    ) throws -> Bool {
        do {
            _ = try ReleaseV060PortfolioJournalProjectionRunnerResult(
                runID: source.runID,
                sourceJournal: source.sourceJournal,
                replayedEnvelopes: source.replayedEnvelopes,
                projectionEvidence: source.projectionEvidence,
                decodedProjectionJSONEvidence: source.decodedProjectionJSONEvidence,
                rebuiltProjectionEvidence: source.rebuiltProjectionEvidence,
                writerResult: source.writerResult,
                manifestValidation: source.manifestValidation,
                projectionJSONPath: source.projectionJSONPath,
                accountEndpointRead: true
            )
            return false
        } catch ReleaseV060PortfolioJournalProjectionRunnerError.forbiddenBrokerAccountPayload("accountEndpointRead") {
            return true
        }
    }

    private static func reject(_ value: Bool, _ field: String) throws {
        guard value == false else {
            throw ReleaseV060PortfolioJournalProjectionRunnerError.forbiddenBrokerAccountPayload(field)
        }
    }
}

/// ReleaseV060PortfolioJournalProjectionRunner 从真实本地 run journal 重建 Portfolio projection。
///
/// Runner 只 replay `events.jsonl` 对应的 append-only journal records，复用 v0.5 fixed-point
/// projection 语义，并通过 v0.6 writer 把 projection evidence 写成 `projection.json`。它不读取
/// broker/account payload，不连接生产 endpoint，也不提交真实订单。
public struct ReleaseV060PortfolioJournalProjectionRunner {
    public let storageRootURL: URL
    private let fileManager: FileManager

    public init(
        storageRootURL: URL = URL(fileURLWithPath: ReleaseV050LocalRunJournalPath.root, isDirectory: true),
        fileManager: FileManager = .default
    ) {
        self.storageRootURL = storageRootURL
        self.fileManager = fileManager
    }

    public func run(
        journal: ReleaseV050DurableLocalRunJournal
    ) throws -> ReleaseV060PortfolioJournalProjectionRunnerResult {
        guard journal.records.isEmpty == false else {
            throw ReleaseV060PortfolioJournalProjectionRunnerError.emptyJournal
        }
        guard journal.appendOnlyHeld else {
            throw ReleaseV060PortfolioJournalProjectionRunnerError.journalReplayMismatch
        }

        let cursor = try ReleaseV050RunJournalReplayCursor(runID: journal.paths.runID)
        let replayed = try journal.replay(cursor: cursor)
        guard replayed == journal.records.map(\.envelope) else {
            throw ReleaseV060PortfolioJournalProjectionRunnerError.journalReplayMismatch
        }

        let projectionEvidence = try ReleaseV050PortfolioRunJournalProjection.project(journal: journal)
        let projectionJSON = try Self.encodeJSON(projectionEvidence)
        let writer = ReleaseV060LocalRunJournalWriter(storageRootURL: storageRootURL, fileManager: fileManager)
        let writerResult = try writer.writeCompletedRun(journal: journal, projectionJSON: projectionJSON)
        let manifestValidation = try writer.validateRunManifest(runID: journal.paths.runID)
        let persistedProjectionJSON = try String(contentsOfFile: writerResult.projectionJSONPath, encoding: .utf8)
        guard persistedProjectionJSON == projectionJSON else {
            throw ReleaseV060PortfolioJournalProjectionRunnerError.projectionJSONMismatch
        }
        let decodedProjection = try Self.decodeJSON(
            ReleaseV050PortfolioRunJournalProjectionEvidence.self,
            from: persistedProjectionJSON
        )
        let rebuiltProjection = try ReleaseV050PortfolioRunJournalProjection.project(journal: journal)
        guard decodedProjection == projectionEvidence, rebuiltProjection == projectionEvidence else {
            throw ReleaseV060PortfolioJournalProjectionRunnerError.projectionRebuildMismatch
        }

        return try ReleaseV060PortfolioJournalProjectionRunnerResult(
            runID: journal.paths.runID,
            sourceJournal: journal,
            replayedEnvelopes: replayed,
            projectionEvidence: projectionEvidence,
            decodedProjectionJSONEvidence: decodedProjection,
            rebuiltProjectionEvidence: rebuiltProjection,
            writerResult: writerResult,
            manifestValidation: manifestValidation,
            projectionJSONPath: writerResult.projectionJSONPath,
            fixedPointExposureNotionalQuantityHeld: Self.fixedPointProjectionHeld(projectionEvidence)
        )
    }

    public static func deterministicEvidence(
        journal: ReleaseV050DurableLocalRunJournal,
        storageRootURL: URL
    ) throws -> ReleaseV060PortfolioJournalProjectionRunnerResult {
        let runner = ReleaseV060PortfolioJournalProjectionRunner(storageRootURL: storageRootURL)
        return try runner.run(journal: journal)
    }

    private static func fixedPointProjectionHeld(
        _ evidence: ReleaseV050PortfolioRunJournalProjectionEvidence
    ) -> Bool {
        evidence.fillEvidence.allSatisfy {
            $0.targetQuantity.semantic == .quantity
                && $0.notionalExposure.semantic == .notional
                && $0.projectionReferencePrice.semantic == .price
        }
            && evidence.productProjections.allSatisfy {
                $0.netPositionQuantity.semantic == .quantity
                    && $0.grossExposure.semantic == .notional
                    && $0.projectedPnLLike.semantic == .money
            }
            && evidence.projectionState.totalGrossExposure.semantic == .notional
            && evidence.projectionState.totalMarginLikeRequirement.semantic == .notional
    }

    private static func encodeJSON<Value: Encodable>(_ value: Value) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return String(decoding: try encoder.encode(value), as: UTF8.self)
    }

    private static func decodeJSON<Value: Decodable>(_ type: Value.Type, from json: String) throws -> Value {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: Data(json.utf8))
    }
}

/// ReleaseV060PortfolioJournalProjectionRunnerContract 固定 GH-763 issue-level 验收合同。
public struct ReleaseV060PortfolioJournalProjectionRunnerContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let productionTradingEnabledByDefault: Bool
    public let productionEndpointConnected: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool
    public let accountEndpointRead: Bool
    public let brokerPositionRead: Bool
    public let rawBrokerPayloadStored: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-763"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-761", "GH-762"]
            && previousIssueID.rawValue == "GH-762"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
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
        issueID: Identifier = Identifier.constant("GH-763"),
        upstreamIssueIDs: [Identifier] = [Identifier.constant("GH-761"), Identifier.constant("GH-762")],
        previousIssueID: Identifier = Identifier.constant("GH-762"),
        downstreamIssueIDs: [Identifier] = [Identifier.constant("GH-764"), Identifier.constant("GH-766")],
        releaseVersion: String = "v0.6.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        productionTradingEnabledByDefault: Bool = false,
        productionEndpointConnected: Bool = false,
        productionSecretAutoReadEnabled: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false,
        accountEndpointRead: Bool = false,
        brokerPositionRead: Bool = false,
        rawBrokerPayloadStored: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionEndpointConnected = productionEndpointConnected
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized
        self.accountEndpointRead = accountEndpointRead
        self.brokerPositionRead = brokerPositionRead
        self.rawBrokerPayloadStored = rawBrokerPayloadStored

        guard contractHeld else {
            throw ReleaseV060PortfolioJournalProjectionRunnerError.contractDrift("portfolioJournalProjectionContract")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV060PortfolioJournalProjectionRunnerContract {
        try ReleaseV060PortfolioJournalProjectionRunnerContract()
    }

    public static let requiredValidationAnchors = [
        "V060-009-PORTFOLIO-JOURNAL-PROJECTION",
        "V060-009-JOURNAL-REPLAY-TO-PROJECTION-JSON",
        "V060-009-FIXED-POINT-EXPOSURE-NOTIONAL-QUANTITY",
        "V060-009-MANIFEST-VALIDATED-PROJECTION-ARTIFACT",
        "V060-009-NO-BROKER-ACCOUNT-PAYLOAD",
        "TVM-RELEASE-V060-PORTFOLIO-JOURNAL-PROJECTION"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH763PortfolioJournalProjectionRebuildsProjectionJSONFromRealRunJournal",
        "bash checks/verify-v0.6.0-portfolio-journal-projection.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
