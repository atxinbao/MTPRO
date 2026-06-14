import Database
import DomainModel
import Foundation
import MessageBus

/// ReleaseV060DataEngineLocalDryRunRunnerError 描述 GH-759 DataEngine 本地 dry-run runner 的合同错误。
///
/// 错误只覆盖本地 fixture / catalog、DataEngine market event、RuntimeMessageBus envelope
/// 和 local run journal writer 证据；不表达网络、secret、broker、订单或 production cutover 能力。
public enum ReleaseV060DataEngineLocalDryRunRunnerError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyInputs
    case journalRecordMismatch
    case forbiddenProductionCapability(String)

    public var description: String {
        switch self {
        case .emptyInputs:
            "Release v0.6.0 DataEngine local dry-run runner requires deterministic local inputs"
        case .journalRecordMismatch:
            "Release v0.6.0 DataEngine local dry-run runner journal records do not match DataEngine market events"
        case let .forbiddenProductionCapability(capability):
            "Release v0.6.0 DataEngine local dry-run runner rejected forbidden production capability: \(capability)"
        }
    }
}

/// ReleaseV060DataEngineLocalDryRunRunnerResult 汇总 GH-759 本地 runner 落盘结果。
///
/// Result 把 GH-732 typed DataEngine market event evidence、GH-731 append-only journal、
/// GH-756 filesystem writer 和 GH-757 manifest validation 绑定成一个本地 run 证据链。
/// 它不读取 secret，不连接 endpoint，不调用 broker，也不提交真实订单。
public struct ReleaseV060DataEngineLocalDryRunRunnerResult: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let dataEngineEvidence: ReleaseV050DataEngineOperationalDryRunEvidence
    public let journal: ReleaseV050DurableLocalRunJournal
    public let writerResult: ReleaseV060LocalRunJournalWriterResult
    public let manifestValidation: ReleaseV060LocalRunJournalManifestValidation
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let networkCallsPerformed: Bool
    public let secretReadsPerformed: Bool
    public let productionEndpointConnected: Bool
    public let productionBrokerConnected: Bool
    public let productionOrderSubmitted: Bool
    public let productionCutoverAuthorized: Bool

    public var eventEnvelopes: [RuntimeEventEnvelope<ReleaseV050RuntimeEventPayload>] {
        dataEngineEvidence.eventEnvelopes
    }

    public var journalRecords: [ReleaseV050DurableLocalRunJournalRecord] {
        journal.records
    }

    public var dataEngineMarketEventJournalHeld: Bool {
        eventEnvelopes.isEmpty == false
            && journal.appendOnlyHeld
            && journalRecords.map(\.envelope) == eventEnvelopes
            && journalRecords.allSatisfy { $0.envelope.payloadType == .dataEngineMarketEvent }
            && journalRecords.allSatisfy { $0.envelope.sourceModule == .dataEngine }
            && journalRecords.allSatisfy { $0.envelope.checksum.hasPrefix("sha256:") }
            && journalRecords.allSatisfy { $0.journalSHA256.hasPrefix("sha256:") }
            && journal.latestJournalSHA256.hasPrefix("sha256:")
            && writerResult.resultHeld
            && writerResult.status.eventCount == eventEnvelopes.count
            && writerResult.manifest.eventCount == eventEnvelopes.count
            && manifestValidation.validationHeld
            && manifestValidation.runID == dataEngineEvidence.runID
    }

    public var productBoundaryHeld: Bool {
        Set(dataEngineEvidence.productTypes) == Set(ReleaseV050DataEngineOperationalDryRunPathContract.requiredProductTypes)
            && dataEngineEvidence.marketInputs.allSatisfy { $0.instrument.venue.rawValue == "binance" }
            && dataEngineEvidence.marketInputs.allSatisfy(\.source.publicReadOnlyBoundaryHeld)
    }

    public var forbiddenRuntimeHeld: Bool {
        networkCallsPerformed == false
            && secretReadsPerformed == false
            && productionEndpointConnected == false
            && productionBrokerConnected == false
            && productionOrderSubmitted == false
            && productionCutoverAuthorized == false
    }

    public var resultHeld: Bool {
        issueID.rawValue == "GH-759"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-756", "GH-757", "GH-758"]
            && previousIssueID.rawValue == "GH-758"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-760", "GH-761", "GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
            && dataEngineEvidence.runID.rawValue == "gh-759-v060-dataengine-local-dry-run"
            && dataEngineEvidence.streamID.rawValue == "release-v060-dataengine-local-dry-run"
            && dataEngineEvidence.correlationID.rawValue == "gh-759-v060-dataengine-correlation"
            && dataEngineEvidence.evidenceHeld
            && dataEngineMarketEventJournalHeld
            && productBoundaryHeld
            && validationAnchors == ReleaseV060DataEngineLocalDryRunRunnerContract.requiredValidationAnchors
            && requiredValidationCommands == ReleaseV060DataEngineLocalDryRunRunnerContract.requiredValidationCommands
            && forbiddenRuntimeHeld
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-759"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-756"),
            Identifier.constant("GH-757"),
            Identifier.constant("GH-758")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-758"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-760"),
            Identifier.constant("GH-761"),
            Identifier.constant("GH-764"),
            Identifier.constant("GH-766")
        ],
        releaseVersion: String = "v0.6.0",
        dataEngineEvidence: ReleaseV050DataEngineOperationalDryRunEvidence,
        journal: ReleaseV050DurableLocalRunJournal,
        writerResult: ReleaseV060LocalRunJournalWriterResult,
        manifestValidation: ReleaseV060LocalRunJournalManifestValidation,
        validationAnchors: [String] = ReleaseV060DataEngineLocalDryRunRunnerContract.requiredValidationAnchors,
        requiredValidationCommands: [String] = ReleaseV060DataEngineLocalDryRunRunnerContract.requiredValidationCommands,
        networkCallsPerformed: Bool = false,
        secretReadsPerformed: Bool = false,
        productionEndpointConnected: Bool = false,
        productionBrokerConnected: Bool = false,
        productionOrderSubmitted: Bool = false,
        productionCutoverAuthorized: Bool = false
    ) throws {
        self.issueID = issueID
        self.upstreamIssueIDs = upstreamIssueIDs
        self.previousIssueID = previousIssueID
        self.downstreamIssueIDs = downstreamIssueIDs
        self.releaseVersion = releaseVersion
        self.dataEngineEvidence = dataEngineEvidence
        self.journal = journal
        self.writerResult = writerResult
        self.manifestValidation = manifestValidation
        self.validationAnchors = validationAnchors
        self.requiredValidationCommands = requiredValidationCommands
        self.networkCallsPerformed = networkCallsPerformed
        self.secretReadsPerformed = secretReadsPerformed
        self.productionEndpointConnected = productionEndpointConnected
        self.productionBrokerConnected = productionBrokerConnected
        self.productionOrderSubmitted = productionOrderSubmitted
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard resultHeld else {
            throw ReleaseV060DataEngineLocalDryRunRunnerError.forbiddenProductionCapability("resultContractDrift")
        }
    }
}

/// ReleaseV060DataEngineLocalDryRunRunner 执行 GH-759 本地 DataEngine dry-run runner。
///
/// Runner 只消费现有 deterministic local fixture / catalog input，先生成 typed
/// DataEngineMarketEvent envelope，再写入 append-only local run journal 和 filesystem artifacts。
/// 它不包含网络请求客户端、secret resolution、broker adapter 或 order command。
public struct ReleaseV060DataEngineLocalDryRunRunner {
    public let runID: Identifier
    public let streamID: MessageBusJournalStreamID
    public let correlationID: Identifier
    public let firstRecordedAt: Date
    public let recordedAtStride: TimeInterval
    public let eventIDPrefix: String
    public let storageRootURL: URL
    private let fileManager: FileManager

    public init(
        runID: Identifier = Identifier.constant("gh-759-v060-dataengine-local-dry-run"),
        streamID: MessageBusJournalStreamID? = nil,
        correlationID: Identifier = Identifier.constant("gh-759-v060-dataengine-correlation"),
        firstRecordedAt: Date = Date(timeIntervalSince1970: 1_800_000_759),
        recordedAtStride: TimeInterval = 1,
        eventIDPrefix: String = "gh-759-v060-dataengine-market-event",
        storageRootURL: URL = URL(fileURLWithPath: ReleaseV050LocalRunJournalPath.root, isDirectory: true),
        fileManager: FileManager = .default
    ) throws {
        self.runID = runID
        self.streamID = try streamID ?? MessageBusJournalStreamID("release-v060-dataengine-local-dry-run")
        self.correlationID = correlationID
        self.firstRecordedAt = firstRecordedAt
        self.recordedAtStride = recordedAtStride
        self.eventIDPrefix = try FoundationTargetID(eventIDPrefix, field: "releaseV060DataEngineEventIDPrefix").rawValue
        self.storageRootURL = storageRootURL
        self.fileManager = fileManager
    }

    @discardableResult
    public func run(
        inputs: [ReleaseV050DataEngineDryRunMarketInput]
    ) async throws -> ReleaseV060DataEngineLocalDryRunRunnerResult {
        guard inputs.isEmpty == false else {
            throw ReleaseV060DataEngineLocalDryRunRunnerError.emptyInputs
        }

        let dataEnginePath = try ReleaseV050DataEngineOperationalDryRunPath(
            runID: runID,
            streamID: streamID,
            correlationID: correlationID,
            firstRecordedAt: firstRecordedAt,
            recordedAtStride: recordedAtStride,
            eventIDPrefix: eventIDPrefix
        )
        let evidence = try await dataEnginePath.run(inputs: inputs)

        var journal = try ReleaseV050DurableLocalRunJournal(runID: evidence.runID)
        for envelope in evidence.eventEnvelopes {
            try journal.append(envelope: envelope)
        }
        guard journal.records.map(\.envelope) == evidence.eventEnvelopes else {
            throw ReleaseV060DataEngineLocalDryRunRunnerError.journalRecordMismatch
        }

        let writer = ReleaseV060LocalRunJournalWriter(storageRootURL: storageRootURL, fileManager: fileManager)
        let writerResult = try writer.writeCompletedRun(journal: journal)
        let manifestValidation = try writer.validateRunManifest(runID: evidence.runID)

        return try ReleaseV060DataEngineLocalDryRunRunnerResult(
            dataEngineEvidence: evidence,
            journal: journal,
            writerResult: writerResult,
            manifestValidation: manifestValidation
        )
    }

    public func runDeterministicInputs() async throws -> ReleaseV060DataEngineLocalDryRunRunnerResult {
        try await run(inputs: ReleaseV050DataEngineOperationalDryRunPath.deterministicInputs())
    }

    public static func deterministicEvidence(
        storageRootURL: URL
    ) async throws -> ReleaseV060DataEngineLocalDryRunRunnerResult {
        let runner = try ReleaseV060DataEngineLocalDryRunRunner(storageRootURL: storageRootURL)
        return try await runner.runDeterministicInputs()
    }
}

/// ReleaseV060DataEngineLocalDryRunRunnerContract 固定 GH-759 validation anchors 和边界。
public struct ReleaseV060DataEngineLocalDryRunRunnerContract: Codable, Equatable, Sendable {
    public let issueID: Identifier
    public let upstreamIssueIDs: [Identifier]
    public let previousIssueID: Identifier
    public let downstreamIssueIDs: [Identifier]
    public let releaseVersion: String
    public let validationAnchors: [String]
    public let requiredValidationCommands: [String]
    public let allowedVenue: String
    public let allowedProductTypes: [ProductType]
    public let productionTradingEnabledByDefault: Bool
    public let productionSecretAutoReadEnabled: Bool
    public let productionEndpointAutoConnectEnabled: Bool
    public let productionBrokerConnectionEnabled: Bool
    public let productionOrderSubmissionEnabled: Bool
    public let productionCutoverAuthorized: Bool

    public var contractHeld: Bool {
        issueID.rawValue == "GH-759"
            && upstreamIssueIDs.map(\.rawValue) == ["GH-756", "GH-757", "GH-758"]
            && previousIssueID.rawValue == "GH-758"
            && downstreamIssueIDs.map(\.rawValue) == ["GH-760", "GH-761", "GH-764", "GH-766"]
            && releaseVersion == "v0.6.0"
            && validationAnchors == Self.requiredValidationAnchors
            && requiredValidationCommands == Self.requiredValidationCommands
            && allowedVenue == "binance"
            && allowedProductTypes == Self.requiredProductTypes
            && productionTradingEnabledByDefault == false
            && productionSecretAutoReadEnabled == false
            && productionEndpointAutoConnectEnabled == false
            && productionBrokerConnectionEnabled == false
            && productionOrderSubmissionEnabled == false
            && productionCutoverAuthorized == false
    }

    public init(
        issueID: Identifier = Identifier.constant("GH-759"),
        upstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-756"),
            Identifier.constant("GH-757"),
            Identifier.constant("GH-758")
        ],
        previousIssueID: Identifier = Identifier.constant("GH-758"),
        downstreamIssueIDs: [Identifier] = [
            Identifier.constant("GH-760"),
            Identifier.constant("GH-761"),
            Identifier.constant("GH-764"),
            Identifier.constant("GH-766")
        ],
        releaseVersion: String = "v0.6.0",
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationCommands: [String] = Self.requiredValidationCommands,
        allowedVenue: String = "binance",
        allowedProductTypes: [ProductType] = Self.requiredProductTypes,
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
        self.allowedVenue = allowedVenue
        self.allowedProductTypes = allowedProductTypes
        self.productionTradingEnabledByDefault = productionTradingEnabledByDefault
        self.productionSecretAutoReadEnabled = productionSecretAutoReadEnabled
        self.productionEndpointAutoConnectEnabled = productionEndpointAutoConnectEnabled
        self.productionBrokerConnectionEnabled = productionBrokerConnectionEnabled
        self.productionOrderSubmissionEnabled = productionOrderSubmissionEnabled
        self.productionCutoverAuthorized = productionCutoverAuthorized

        guard contractHeld else {
            throw ReleaseV060DataEngineLocalDryRunRunnerError.forbiddenProductionCapability("contractDrift")
        }
    }

    public static func deterministicFixture() throws -> ReleaseV060DataEngineLocalDryRunRunnerContract {
        try ReleaseV060DataEngineLocalDryRunRunnerContract()
    }

    public static let requiredProductTypes: [ProductType] = [.spot, .usdsPerpetual]

    public static let requiredValidationAnchors = [
        "V060-005-DATAENGINE-LOCAL-DRY-RUN-RUNNER",
        "V060-005-LOCAL-FIXTURE-CATALOG-ONLY",
        "V060-005-DATAENGINE-MARKET-EVENT-JOURNAL-WRITE",
        "V060-005-BINANCE-SPOT-USDM-PERP-BOUNDARY",
        "V060-005-NO-NETWORK-SECRET-ORDER",
        "TVM-RELEASE-V060-DATAENGINE-LOCAL-DRY-RUN-RUNNER"
    ]

    public static let requiredValidationCommands = [
        "swift test --filter TargetGraphTests/testGH759DataEngineLocalDryRunRunnerWritesMarketEventsToLocalRunJournal",
        "bash checks/verify-v0.6.0-dataengine-local-dry-run-runner.sh",
        "git diff --check",
        "bash checks/automation-readiness.sh",
        "bash checks/run.sh"
    ]
}
