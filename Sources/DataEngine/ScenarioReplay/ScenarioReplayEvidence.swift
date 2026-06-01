import Foundation

/// Scenario replay evidence 固定 MTP-106 的本地回放窗口、游标、checksum 和 freshness 证据。
///
/// 本文件只消费 MTP-104 `ScenarioManifest` 和 MTP-105 `DeterministicScenarioFixture` 的本地值对象，
/// 输出可编码、可比较、可被后续 MTP-107 data quality gates 消费的稳定 evidence。它不解析文件、
/// 不下载真实历史数据、不执行 production retention engine、不暴露 database schema / adapter request，
/// 也不接 signed/account/listenKey、broker、LiveExecutionAdapter、OMS、live command 或交易按钮。

/// ScenarioReplayFreshnessStatus 描述本地 deterministic fixture 相对 freshness policy 的状态。
///
/// 状态只由固定 replay window、固定评估时间和本地 policy 计算，不执行清理、归档、下载或调度。
public enum ScenarioReplayFreshnessStatus: String, Codable, Equatable, Hashable, Sendable {
    case fresh
    case stale
    case expired
    case notRetained = "not retained"
}

/// ScenarioReplayWindow 是 MTP-106 的 historical replay window 值合同。
///
/// Window 复用 MTP-105 fixture 的 fixed window、record sequence 和 manifest identity，确保后续
/// cursor、checksum、freshness 和 MTP-107 data quality gate 都引用同一个 deterministic input。
public struct ScenarioReplayWindow: Codable, Equatable, Sendable {
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let fixtureVersion: FixtureVersion
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let window: DateRange
    public let recordCount: Int
    public let firstRecordSequence: Int
    public let lastRecordSequence: Int
    public let orderedRecordStarts: [Int]
    public let recordOrderIdentity: String
    public let sourceIdentity: String
    public let sourceAnchor: String

    public init(
        fixture: DeterministicScenarioFixture = .deterministicFixture,
        sourceAnchor: String = "MTP-106-DETERMINISTIC-REPLAY-WINDOW"
    ) throws {
        guard fixture.fixtureBoundaryHeld else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayWindow.fixtureBoundaryHeld",
                expected: "true",
                actual: "false"
            )
        }
        guard let firstSequence = fixture.records.first?.sequence,
              let lastSequence = fixture.records.last?.sequence else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayWindow.records",
                expected: "non-empty deterministic fixture records",
                actual: "empty"
            )
        }
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayWindow.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }

        let summary = fixture.deterministicSummary
        self.scenarioID = summary.scenarioID
        self.datasetVersion = summary.datasetVersion
        self.fixtureVersion = summary.fixtureVersion
        self.symbol = summary.symbol
        self.timeframe = summary.timeframe
        self.window = summary.fixedWindow
        self.recordCount = summary.recordCount
        self.firstRecordSequence = firstSequence
        self.lastRecordSequence = lastSequence
        self.orderedRecordStarts = summary.orderedRecordStarts
        self.recordOrderIdentity = summary.recordOrderIdentity
        self.sourceIdentity = summary.sourceIdentity
        self.sourceAnchor = sourceAnchor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scenarioID = try container.decode(ScenarioID.self, forKey: .scenarioID)
        let datasetVersion = try container.decode(DatasetVersion.self, forKey: .datasetVersion)
        let fixtureVersion = try container.decode(FixtureVersion.self, forKey: .fixtureVersion)
        let symbol = try container.decode(Symbol.self, forKey: .symbol)
        let timeframe = try container.decode(Timeframe.self, forKey: .timeframe)
        let window = try container.decode(DateRange.self, forKey: .window)
        let recordCount = try container.decode(Int.self, forKey: .recordCount)
        let firstRecordSequence = try container.decode(Int.self, forKey: .firstRecordSequence)
        let lastRecordSequence = try container.decode(Int.self, forKey: .lastRecordSequence)
        let orderedRecordStarts = try container.decode([Int].self, forKey: .orderedRecordStarts)
        let recordOrderIdentity = try container.decode(String.self, forKey: .recordOrderIdentity)
        let sourceIdentity = try container.decode(String.self, forKey: .sourceIdentity)
        let sourceAnchor = try container.decode(String.self, forKey: .sourceAnchor)

        try Self.validate(
            scenarioID: scenarioID,
            datasetVersion: datasetVersion,
            fixtureVersion: fixtureVersion,
            symbol: symbol,
            timeframe: timeframe,
            window: window,
            recordCount: recordCount,
            firstRecordSequence: firstRecordSequence,
            lastRecordSequence: lastRecordSequence,
            orderedRecordStarts: orderedRecordStarts,
            recordOrderIdentity: recordOrderIdentity,
            sourceIdentity: sourceIdentity,
            sourceAnchor: sourceAnchor
        )

        self.scenarioID = scenarioID
        self.datasetVersion = datasetVersion
        self.fixtureVersion = fixtureVersion
        self.symbol = symbol
        self.timeframe = timeframe
        self.window = window
        self.recordCount = recordCount
        self.firstRecordSequence = firstRecordSequence
        self.lastRecordSequence = lastRecordSequence
        self.orderedRecordStarts = orderedRecordStarts
        self.recordOrderIdentity = recordOrderIdentity
        self.sourceIdentity = sourceIdentity
        self.sourceAnchor = sourceAnchor
    }

    public var windowDescription: String {
        "\(Int(window.start.timeIntervalSince1970))...\(Int(window.end.timeIntervalSince1970))"
    }

    public var deterministicWindowIdentity: String {
        [
            scenarioID.rawValue,
            datasetVersion.rawValue,
            fixtureVersion.rawValue,
            symbol.rawValue,
            timeframe.rawValue,
            windowDescription,
            "records=\(recordCount)",
            "sequence=\(firstRecordSequence)...\(lastRecordSequence)",
            recordOrderIdentity
        ].joined(separator: "|")
    }

    private static func validate(
        scenarioID: ScenarioID,
        datasetVersion: DatasetVersion,
        fixtureVersion: FixtureVersion,
        symbol: Symbol,
        timeframe: Timeframe,
        window: DateRange,
        recordCount: Int,
        firstRecordSequence: Int,
        lastRecordSequence: Int,
        orderedRecordStarts: [Int],
        recordOrderIdentity: String,
        sourceIdentity: String,
        sourceAnchor: String
    ) throws {
        let expected = try ScenarioReplayWindow(fixture: .deterministicFixture, sourceAnchor: sourceAnchor)
        guard scenarioID == expected.scenarioID,
              datasetVersion == expected.datasetVersion,
              fixtureVersion == expected.fixtureVersion,
              symbol == expected.symbol,
              timeframe == expected.timeframe,
              window == expected.window,
              recordCount == expected.recordCount,
              firstRecordSequence == expected.firstRecordSequence,
              lastRecordSequence == expected.lastRecordSequence,
              orderedRecordStarts == expected.orderedRecordStarts,
              recordOrderIdentity == expected.recordOrderIdentity,
              sourceIdentity == expected.sourceIdentity else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayWindow",
                expected: expected.deterministicWindowIdentity,
                actual: [
                    scenarioID.rawValue,
                    datasetVersion.rawValue,
                    fixtureVersion.rawValue,
                    symbol.rawValue,
                    timeframe.rawValue,
                    "\(Int(window.start.timeIntervalSince1970))...\(Int(window.end.timeIntervalSince1970))",
                    "records=\(recordCount)",
                    "sequence=\(firstRecordSequence)...\(lastRecordSequence)",
                    recordOrderIdentity
                ].joined(separator: "|")
            )
        }
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayWindow.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }
    }
}

/// ScenarioReplayCursor 表达本地 scenario replay progress。
///
/// Cursor 只记录 deterministic fixture records 的下一个本地 sequence，不代表 production scheduler、
/// downloader offset、event log sequence、broker sequence、account replay 或 runtime resume token。
public struct ScenarioReplayCursor: Codable, Equatable, Comparable, Sendable {
    public let scenarioID: ScenarioID
    public let datasetVersion: DatasetVersion
    public let fixtureVersion: FixtureVersion
    public let windowIdentity: String
    public let nextRecordSequence: Int
    public let consumedRecordCount: Int
    public let totalRecordCount: Int
    public let state: ScenarioReplayCursorState
    public let sourceAnchor: String

    public init(
        replayWindow: ScenarioReplayWindow = try! ScenarioReplayWindow(),
        nextRecordSequence: Int = 1,
        sourceAnchor: String = "MTP-106-REPLAY-CURSOR-SUMMARY"
    ) throws {
        guard nextRecordSequence >= replayWindow.firstRecordSequence,
              nextRecordSequence <= replayWindow.lastRecordSequence + 1 else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayCursor.nextRecordSequence",
                expected: "\(replayWindow.firstRecordSequence)...\(replayWindow.lastRecordSequence + 1)",
                actual: String(nextRecordSequence)
            )
        }
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayCursor.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }

        self.scenarioID = replayWindow.scenarioID
        self.datasetVersion = replayWindow.datasetVersion
        self.fixtureVersion = replayWindow.fixtureVersion
        self.windowIdentity = replayWindow.deterministicWindowIdentity
        self.nextRecordSequence = nextRecordSequence
        self.consumedRecordCount = nextRecordSequence - replayWindow.firstRecordSequence
        self.totalRecordCount = replayWindow.recordCount
        self.state = Self.state(
            nextRecordSequence: nextRecordSequence,
            firstRecordSequence: replayWindow.firstRecordSequence,
            lastRecordSequence: replayWindow.lastRecordSequence
        )
        self.sourceAnchor = sourceAnchor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let replayWindow = try ScenarioReplayWindow()
        let scenarioID = try container.decode(ScenarioID.self, forKey: .scenarioID)
        let datasetVersion = try container.decode(DatasetVersion.self, forKey: .datasetVersion)
        let fixtureVersion = try container.decode(FixtureVersion.self, forKey: .fixtureVersion)
        let windowIdentity = try container.decode(String.self, forKey: .windowIdentity)
        let nextRecordSequence = try container.decode(Int.self, forKey: .nextRecordSequence)
        let consumedRecordCount = try container.decode(Int.self, forKey: .consumedRecordCount)
        let totalRecordCount = try container.decode(Int.self, forKey: .totalRecordCount)
        let state = try container.decode(ScenarioReplayCursorState.self, forKey: .state)
        let sourceAnchor = try container.decode(String.self, forKey: .sourceAnchor)
        let expected = try ScenarioReplayCursor(replayWindow: replayWindow, nextRecordSequence: nextRecordSequence)

        guard scenarioID == replayWindow.scenarioID,
              datasetVersion == replayWindow.datasetVersion,
              fixtureVersion == replayWindow.fixtureVersion,
              windowIdentity == replayWindow.deterministicWindowIdentity,
              consumedRecordCount == expected.consumedRecordCount,
              totalRecordCount == expected.totalRecordCount,
              state == expected.state else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayCursor",
                expected: expected.cursorIdentity,
                actual: [
                    scenarioID.rawValue,
                    datasetVersion.rawValue,
                    fixtureVersion.rawValue,
                    windowIdentity,
                    "next=\(nextRecordSequence)",
                    "consumed=\(consumedRecordCount)",
                    "total=\(totalRecordCount)",
                    "state=\(state.rawValue)"
                ].joined(separator: "|")
            )
        }
        guard sourceAnchor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayCursor.sourceAnchor",
                expected: "non-empty source anchor",
                actual: "empty"
            )
        }

        self.scenarioID = scenarioID
        self.datasetVersion = datasetVersion
        self.fixtureVersion = fixtureVersion
        self.windowIdentity = windowIdentity
        self.nextRecordSequence = nextRecordSequence
        self.consumedRecordCount = consumedRecordCount
        self.totalRecordCount = totalRecordCount
        self.state = state
        self.sourceAnchor = sourceAnchor
    }

    public var cursorIdentity: String {
        [
            scenarioID.rawValue,
            datasetVersion.rawValue,
            fixtureVersion.rawValue,
            "next=\(nextRecordSequence)",
            "consumed=\(consumedRecordCount)",
            "total=\(totalRecordCount)",
            "state=\(state.rawValue)",
            windowIdentity
        ].joined(separator: "|")
    }

    public static func < (lhs: ScenarioReplayCursor, rhs: ScenarioReplayCursor) -> Bool {
        [
            lhs.scenarioID.rawValue,
            lhs.datasetVersion.rawValue,
            lhs.fixtureVersion.rawValue,
            lhs.windowIdentity,
            String(format: "%010d", lhs.nextRecordSequence)
        ].lexicographicallyPrecedes([
            rhs.scenarioID.rawValue,
            rhs.datasetVersion.rawValue,
            rhs.fixtureVersion.rawValue,
            rhs.windowIdentity,
            String(format: "%010d", rhs.nextRecordSequence)
        ])
    }

    private static func state(
        nextRecordSequence: Int,
        firstRecordSequence: Int,
        lastRecordSequence: Int
    ) -> ScenarioReplayCursorState {
        if nextRecordSequence == firstRecordSequence {
            return .atStart
        }
        if nextRecordSequence == lastRecordSequence + 1 {
            return .completed
        }
        return .inProgress
    }
}

/// ScenarioReplayCursorState 固定 cursor 的本地进度分类。
///
/// 状态只解释 fixture record consumption，不表示生产 job、下载任务、broker/account replay 或 live resume。
public enum ScenarioReplayCursorState: String, Codable, Equatable, Hashable, Sendable {
    case atStart = "at start"
    case inProgress = "in progress"
    case completed
}

/// ScenarioReplayCursorSummary 是后续 quality gate 可消费的稳定 cursor 摘要。
///
/// Summary 复制 cursor 必要字段，避免后续 App / Report 层读取 Runtime object、adapter request 或
/// persistence schema 来理解当前本地 scenario replay progress。
public struct ScenarioReplayCursorSummary: Codable, Equatable, Sendable {
    public let cursorIdentity: String
    public let windowIdentity: String
    public let nextRecordSequence: Int
    public let consumedRecordCount: Int
    public let totalRecordCount: Int
    public let state: ScenarioReplayCursorState
    public let summaryLine: String

    public init(cursor: ScenarioReplayCursor = try! ScenarioReplayCursor()) {
        self.cursorIdentity = cursor.cursorIdentity
        self.windowIdentity = cursor.windowIdentity
        self.nextRecordSequence = cursor.nextRecordSequence
        self.consumedRecordCount = cursor.consumedRecordCount
        self.totalRecordCount = cursor.totalRecordCount
        self.state = cursor.state
        self.summaryLine = [
            "cursor=\(cursor.state.rawValue)",
            "next=\(cursor.nextRecordSequence)",
            "consumed=\(cursor.consumedRecordCount)",
            "total=\(cursor.totalRecordCount)"
        ].joined(separator: "; ")
    }
}

/// ScenarioReplayChecksumEvidence 是 MTP-106 的 final checksum / parity evidence。
///
/// Checksum 只对 MTP-105 的 canonical checksum preimage 做 FNV-1a 计算，并把算法、preimage identity、
/// record order 和 checksum 固定为可比较 evidence。它不是生产数据质量平台或真实下载校验服务。
public struct ScenarioReplayChecksumEvidence: Codable, Equatable, Sendable {
    public let algorithm: String
    public let sourceIdentity: String
    public let recordOrderIdentity: String
    public let canonicalPreimage: String
    public let checksum: String
    public let checksumMatchedCanonicalPreimage: Bool
    public let parityEvidenceStable: Bool

    public init(
        summary: ScenarioFixtureDeterministicSummary = DeterministicScenarioFixture
            .deterministicFixture
            .deterministicSummary,
        checksum: String? = nil
    ) throws {
        let computed = Self.checksum(forCanonicalPreimage: summary.checksumPreimage)
        if let checksum, checksum != computed {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayChecksum.checksum",
                expected: computed,
                actual: checksum
            )
        }

        self.algorithm = "fnv1a64"
        self.sourceIdentity = summary.sourceIdentity
        self.recordOrderIdentity = summary.recordOrderIdentity
        self.canonicalPreimage = summary.checksumPreimage
        self.checksum = computed
        self.checksumMatchedCanonicalPreimage = true
        self.parityEvidenceStable = true
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let summary = DeterministicScenarioFixture.deterministicFixture.deterministicSummary
        let algorithm = try container.decode(String.self, forKey: .algorithm)
        let sourceIdentity = try container.decode(String.self, forKey: .sourceIdentity)
        let recordOrderIdentity = try container.decode(String.self, forKey: .recordOrderIdentity)
        let canonicalPreimage = try container.decode(String.self, forKey: .canonicalPreimage)
        let checksum = try container.decode(String.self, forKey: .checksum)
        let checksumMatchedCanonicalPreimage = try container.decode(
            Bool.self,
            forKey: .checksumMatchedCanonicalPreimage
        )
        let parityEvidenceStable = try container.decode(Bool.self, forKey: .parityEvidenceStable)
        let expected = try ScenarioReplayChecksumEvidence(summary: summary)

        guard algorithm == expected.algorithm,
              sourceIdentity == expected.sourceIdentity,
              recordOrderIdentity == expected.recordOrderIdentity,
              canonicalPreimage == expected.canonicalPreimage,
              checksum == expected.checksum,
              checksumMatchedCanonicalPreimage,
              parityEvidenceStable else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayChecksum",
                expected: expected.checksum,
                actual: checksum
            )
        }

        self.algorithm = algorithm
        self.sourceIdentity = sourceIdentity
        self.recordOrderIdentity = recordOrderIdentity
        self.canonicalPreimage = canonicalPreimage
        self.checksum = checksum
        self.checksumMatchedCanonicalPreimage = checksumMatchedCanonicalPreimage
        self.parityEvidenceStable = parityEvidenceStable
    }

    public static func checksum(forCanonicalPreimage preimage: String) -> String {
        "fnv1a64:\(fnv1a64Hex(preimage))"
    }

    private static func fnv1a64Hex(_ payload: String) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in payload.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        let hex = String(hash, radix: 16)
        return String(repeating: "0", count: max(0, 16 - hex.count)) + hex
    }
}

/// ScenarioReplayFreshnessPolicy 是 MTP-106 的本地 fixture freshness policy。
///
/// Policy 只给 deterministic fixture freshness evidence 提供稳定阈值，不执行 production retention、
/// cleanup、cloud archive、storage tiering、scheduler 或 downloader side effect。
public struct ScenarioReplayFreshnessPolicy: Codable, Equatable, Sendable {
    public let policyID: Identifier
    public let retainFixtureLocally: Bool
    public let staleAfterSeconds: Int
    public let expiresAfterSeconds: Int
    public let authorizesProductionRetentionEngine: Bool
    public let authorizesCloudArchive: Bool
    public let authorizesStorageTiering: Bool

    public init(
        policyID: Identifier = try! Identifier("mtp-106-local-fixture-freshness-policy"),
        retainFixtureLocally: Bool = true,
        staleAfterSeconds: Int = 300,
        expiresAfterSeconds: Int = 900,
        authorizesProductionRetentionEngine: Bool = false,
        authorizesCloudArchive: Bool = false,
        authorizesStorageTiering: Bool = false
    ) throws {
        guard staleAfterSeconds >= 0 else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayFreshnessPolicy.staleAfterSeconds",
                expected: "non-negative seconds",
                actual: String(staleAfterSeconds)
            )
        }
        guard expiresAfterSeconds >= 0 else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayFreshnessPolicy.expiresAfterSeconds",
                expected: "non-negative seconds",
                actual: String(expiresAfterSeconds)
            )
        }
        guard staleAfterSeconds < expiresAfterSeconds else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayFreshnessPolicy.windowOrder",
                expected: "staleAfterSeconds < expiresAfterSeconds",
                actual: "\(staleAfterSeconds) >= \(expiresAfterSeconds)"
            )
        }

        let forbiddenFlags = [
            ("authorizesProductionRetentionEngine", authorizesProductionRetentionEngine),
            ("authorizesCloudArchive", authorizesCloudArchive),
            ("authorizesStorageTiering", authorizesStorageTiering)
        ]
        if let capability = forbiddenFlags.first(where: \.1) {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability(
                "scenarioReplayFreshnessPolicy.\(capability.0)"
            )
        }

        self.policyID = policyID
        self.retainFixtureLocally = retainFixtureLocally
        self.staleAfterSeconds = staleAfterSeconds
        self.expiresAfterSeconds = expiresAfterSeconds
        self.authorizesProductionRetentionEngine = authorizesProductionRetentionEngine
        self.authorizesCloudArchive = authorizesCloudArchive
        self.authorizesStorageTiering = authorizesStorageTiering
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            policyID: try container.decode(Identifier.self, forKey: .policyID),
            retainFixtureLocally: try container.decode(Bool.self, forKey: .retainFixtureLocally),
            staleAfterSeconds: try container.decode(Int.self, forKey: .staleAfterSeconds),
            expiresAfterSeconds: try container.decode(Int.self, forKey: .expiresAfterSeconds),
            authorizesProductionRetentionEngine: try container.decode(
                Bool.self,
                forKey: .authorizesProductionRetentionEngine
            ),
            authorizesCloudArchive: try container.decode(Bool.self, forKey: .authorizesCloudArchive),
            authorizesStorageTiering: try container.decode(Bool.self, forKey: .authorizesStorageTiering)
        )
    }

    public func status(windowEnd: Date, evaluatedAt: Date) -> ScenarioReplayFreshnessStatus {
        guard retainFixtureLocally else {
            return .notRetained
        }

        let age = max(0, Int(evaluatedAt.timeIntervalSince(windowEnd)))
        if age >= expiresAfterSeconds {
            return .expired
        }
        if age >= staleAfterSeconds {
            return .stale
        }
        return .fresh
    }
}

/// ScenarioReplayFreshnessEvidence 是 MTP-106 的本地 fixture freshness evidence。
///
/// Evidence 只复制 replay window、policy、固定 evaluatedAt 和 freshness status，供后续 quality gate
/// 判定使用；它不删除数据、不调度下载、不实现 production retention engine 或 cloud archive。
public struct ScenarioReplayFreshnessEvidence: Codable, Equatable, Sendable {
    public let policy: ScenarioReplayFreshnessPolicy
    public let windowIdentity: String
    public let windowDescription: String
    public let evaluatedAt: Date
    public let windowEnd: Date
    public let ageSeconds: Int
    public let status: ScenarioReplayFreshnessStatus
    public let freshnessSummary: String
    public let isLocalFixtureFreshnessOnly: Bool
    public let requiredValidationDependsOnNetwork: Bool
    public let authorizesProductionRetentionEngine: Bool
    public let authorizesCloudArchive: Bool
    public let authorizesStorageTiering: Bool

    public init(
        replayWindow: ScenarioReplayWindow = try! ScenarioReplayWindow(),
        policy: ScenarioReplayFreshnessPolicy = try! ScenarioReplayFreshnessPolicy(),
        evaluatedAt: Date = Date(timeIntervalSince1970: 1_704_067_500),
        requiredValidationDependsOnNetwork: Bool = false,
        authorizesProductionRetentionEngine: Bool = false,
        authorizesCloudArchive: Bool = false,
        authorizesStorageTiering: Bool = false
    ) throws {
        let forbiddenFlags = [
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork),
            ("authorizesProductionRetentionEngine", authorizesProductionRetentionEngine),
            ("authorizesCloudArchive", authorizesCloudArchive),
            ("authorizesStorageTiering", authorizesStorageTiering)
        ]
        if let capability = forbiddenFlags.first(where: \.1) {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability(
                "scenarioReplayFreshness.\(capability.0)"
            )
        }

        let age = max(0, Int(evaluatedAt.timeIntervalSince(replayWindow.window.end)))
        let status = policy.status(windowEnd: replayWindow.window.end, evaluatedAt: evaluatedAt)
        self.policy = policy
        self.windowIdentity = replayWindow.deterministicWindowIdentity
        self.windowDescription = replayWindow.windowDescription
        self.evaluatedAt = evaluatedAt
        self.windowEnd = replayWindow.window.end
        self.ageSeconds = age
        self.status = status
        self.freshnessSummary = [
            "policy=\(policy.policyID.rawValue)",
            "status=\(status.rawValue)",
            "ageSeconds=\(age)",
            "window=\(replayWindow.windowDescription)",
            "localFixtureOnly=true"
        ].joined(separator: "|")
        self.isLocalFixtureFreshnessOnly = true
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.authorizesProductionRetentionEngine = authorizesProductionRetentionEngine
        self.authorizesCloudArchive = authorizesCloudArchive
        self.authorizesStorageTiering = authorizesStorageTiering
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let policy = try container.decode(ScenarioReplayFreshnessPolicy.self, forKey: .policy)
        let replayWindow = try ScenarioReplayWindow()
        let evaluatedAt = try container.decode(Date.self, forKey: .evaluatedAt)
        let expected = try ScenarioReplayFreshnessEvidence(
            replayWindow: replayWindow,
            policy: policy,
            evaluatedAt: evaluatedAt
        )
        let windowIdentity = try container.decode(String.self, forKey: .windowIdentity)
        let windowDescription = try container.decode(String.self, forKey: .windowDescription)
        let windowEnd = try container.decode(Date.self, forKey: .windowEnd)
        let ageSeconds = try container.decode(Int.self, forKey: .ageSeconds)
        let status = try container.decode(ScenarioReplayFreshnessStatus.self, forKey: .status)
        let freshnessSummary = try container.decode(String.self, forKey: .freshnessSummary)
        let isLocalFixtureFreshnessOnly = try container.decode(Bool.self, forKey: .isLocalFixtureFreshnessOnly)
        let requiredValidationDependsOnNetwork = try container.decode(
            Bool.self,
            forKey: .requiredValidationDependsOnNetwork
        )
        let authorizesProductionRetentionEngine = try container.decode(
            Bool.self,
            forKey: .authorizesProductionRetentionEngine
        )
        let authorizesCloudArchive = try container.decode(Bool.self, forKey: .authorizesCloudArchive)
        let authorizesStorageTiering = try container.decode(Bool.self, forKey: .authorizesStorageTiering)

        guard windowIdentity == expected.windowIdentity,
              windowDescription == expected.windowDescription,
              windowEnd == expected.windowEnd,
              ageSeconds == expected.ageSeconds,
              status == expected.status,
              freshnessSummary == expected.freshnessSummary,
              isLocalFixtureFreshnessOnly,
              requiredValidationDependsOnNetwork == false,
              authorizesProductionRetentionEngine == false,
              authorizesCloudArchive == false,
              authorizesStorageTiering == false else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayFreshness",
                expected: expected.freshnessSummary,
                actual: freshnessSummary
            )
        }

        self.policy = policy
        self.windowIdentity = windowIdentity
        self.windowDescription = windowDescription
        self.evaluatedAt = evaluatedAt
        self.windowEnd = windowEnd
        self.ageSeconds = ageSeconds
        self.status = status
        self.freshnessSummary = freshnessSummary
        self.isLocalFixtureFreshnessOnly = isLocalFixtureFreshnessOnly
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.authorizesProductionRetentionEngine = authorizesProductionRetentionEngine
        self.authorizesCloudArchive = authorizesCloudArchive
        self.authorizesStorageTiering = authorizesStorageTiering
    }
}

/// ScenarioReplayEvidence 汇总 MTP-106 可交付给后续 quality gates 的稳定证据。
///
/// Aggregate 同时固定 replay window、cursor summary、checksum evidence、freshness evidence、
/// validation anchors 和 forbidden capability flags。它只是 Core 值对象，不启动 Runtime，不执行
/// production scheduler，不接网络、broker、signed endpoint 或真实订单。
public struct ScenarioReplayEvidence: Codable, Equatable, Sendable {
    public let contractID: Identifier
    public let issueID: Identifier
    public let fixture: DeterministicScenarioFixture
    public let replayWindow: ScenarioReplayWindow
    public let cursorSummary: ScenarioReplayCursorSummary
    public let checksumEvidence: ScenarioReplayChecksumEvidence
    public let freshnessEvidence: ScenarioReplayFreshnessEvidence
    public let validationAnchors: [String]
    public let requiredValidationDependsOnNetwork: Bool
    public let downloadsRealNetworkData: Bool
    public let runsProductionRetentionEngine: Bool
    public let runsLargeScaleIngestionPipeline: Bool
    public let buildsProductionDataPlatform: Bool
    public let exposesDatabaseSchema: Bool
    public let exposesAdapterRequest: Bool
    public let readsSecret: Bool
    public let usesSignedEndpoint: Bool
    public let callsAccountEndpoint: Bool
    public let createsListenKey: Bool
    public let connectsBroker: Bool
    public let implementsLiveExecutionAdapter: Bool
    public let implementsOMS: Bool
    public let implementsRealOrderLifecycle: Bool
    public let implementsReportInputVersioning: Bool
    public let runsDataQualityGate: Bool
    public let runsLiveRuntime: Bool
    public let providesLiveCommand: Bool
    public let providesTradingButton: Bool

    public var evidenceBoundaryHeld: Bool {
        fixture.fixtureBoundaryHeld
            && replayWindow.deterministicWindowIdentity == cursorSummary.windowIdentity
            && checksumEvidence.checksumMatchedCanonicalPreimage
            && checksumEvidence.parityEvidenceStable
            && freshnessEvidence.isLocalFixtureFreshnessOnly
            && validationAnchors == Self.requiredValidationAnchors
            && forbiddenCapabilityBoundaryHeld
    }

    public var forbiddenCapabilityBoundaryHeld: Bool {
        requiredValidationDependsOnNetwork == false
            && downloadsRealNetworkData == false
            && runsProductionRetentionEngine == false
            && runsLargeScaleIngestionPipeline == false
            && buildsProductionDataPlatform == false
            && exposesDatabaseSchema == false
            && exposesAdapterRequest == false
            && readsSecret == false
            && usesSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsBroker == false
            && implementsLiveExecutionAdapter == false
            && implementsOMS == false
            && implementsRealOrderLifecycle == false
            && implementsReportInputVersioning == false
            && runsDataQualityGate == false
            && runsLiveRuntime == false
            && providesLiveCommand == false
            && providesTradingButton == false
    }

    public var dataQualityGateInputIdentity: String {
        [
            replayWindow.deterministicWindowIdentity,
            cursorSummary.cursorIdentity,
            checksumEvidence.checksum,
            freshnessEvidence.status.rawValue
        ].joined(separator: "|")
    }

    public init(
        contractID: Identifier = try! Identifier("mtp-106-scenario-replay-evidence"),
        issueID: Identifier = try! Identifier("MTP-106"),
        fixture: DeterministicScenarioFixture = .deterministicFixture,
        replayWindow: ScenarioReplayWindow = try! ScenarioReplayWindow(),
        cursorSummary: ScenarioReplayCursorSummary = ScenarioReplayCursorSummary(),
        checksumEvidence: ScenarioReplayChecksumEvidence = try! ScenarioReplayChecksumEvidence(),
        freshnessEvidence: ScenarioReplayFreshnessEvidence = try! ScenarioReplayFreshnessEvidence(),
        validationAnchors: [String] = Self.requiredValidationAnchors,
        requiredValidationDependsOnNetwork: Bool = false,
        downloadsRealNetworkData: Bool = false,
        runsProductionRetentionEngine: Bool = false,
        runsLargeScaleIngestionPipeline: Bool = false,
        buildsProductionDataPlatform: Bool = false,
        exposesDatabaseSchema: Bool = false,
        exposesAdapterRequest: Bool = false,
        readsSecret: Bool = false,
        usesSignedEndpoint: Bool = false,
        callsAccountEndpoint: Bool = false,
        createsListenKey: Bool = false,
        connectsBroker: Bool = false,
        implementsLiveExecutionAdapter: Bool = false,
        implementsOMS: Bool = false,
        implementsRealOrderLifecycle: Bool = false,
        implementsReportInputVersioning: Bool = false,
        runsDataQualityGate: Bool = false,
        runsLiveRuntime: Bool = false,
        providesLiveCommand: Bool = false,
        providesTradingButton: Bool = false
    ) throws {
        try Self.validate(
            fixture: fixture,
            replayWindow: replayWindow,
            cursorSummary: cursorSummary,
            checksumEvidence: checksumEvidence,
            freshnessEvidence: freshnessEvidence,
            validationAnchors: validationAnchors,
            requiredValidationDependsOnNetwork: requiredValidationDependsOnNetwork,
            downloadsRealNetworkData: downloadsRealNetworkData,
            runsProductionRetentionEngine: runsProductionRetentionEngine,
            runsLargeScaleIngestionPipeline: runsLargeScaleIngestionPipeline,
            buildsProductionDataPlatform: buildsProductionDataPlatform,
            exposesDatabaseSchema: exposesDatabaseSchema,
            exposesAdapterRequest: exposesAdapterRequest,
            readsSecret: readsSecret,
            usesSignedEndpoint: usesSignedEndpoint,
            callsAccountEndpoint: callsAccountEndpoint,
            createsListenKey: createsListenKey,
            connectsBroker: connectsBroker,
            implementsLiveExecutionAdapter: implementsLiveExecutionAdapter,
            implementsOMS: implementsOMS,
            implementsRealOrderLifecycle: implementsRealOrderLifecycle,
            implementsReportInputVersioning: implementsReportInputVersioning,
            runsDataQualityGate: runsDataQualityGate,
            runsLiveRuntime: runsLiveRuntime,
            providesLiveCommand: providesLiveCommand,
            providesTradingButton: providesTradingButton
        )

        self.contractID = contractID
        self.issueID = issueID
        self.fixture = fixture
        self.replayWindow = replayWindow
        self.cursorSummary = cursorSummary
        self.checksumEvidence = checksumEvidence
        self.freshnessEvidence = freshnessEvidence
        self.validationAnchors = validationAnchors
        self.requiredValidationDependsOnNetwork = requiredValidationDependsOnNetwork
        self.downloadsRealNetworkData = downloadsRealNetworkData
        self.runsProductionRetentionEngine = runsProductionRetentionEngine
        self.runsLargeScaleIngestionPipeline = runsLargeScaleIngestionPipeline
        self.buildsProductionDataPlatform = buildsProductionDataPlatform
        self.exposesDatabaseSchema = exposesDatabaseSchema
        self.exposesAdapterRequest = exposesAdapterRequest
        self.readsSecret = readsSecret
        self.usesSignedEndpoint = usesSignedEndpoint
        self.callsAccountEndpoint = callsAccountEndpoint
        self.createsListenKey = createsListenKey
        self.connectsBroker = connectsBroker
        self.implementsLiveExecutionAdapter = implementsLiveExecutionAdapter
        self.implementsOMS = implementsOMS
        self.implementsRealOrderLifecycle = implementsRealOrderLifecycle
        self.implementsReportInputVersioning = implementsReportInputVersioning
        self.runsDataQualityGate = runsDataQualityGate
        self.runsLiveRuntime = runsLiveRuntime
        self.providesLiveCommand = providesLiveCommand
        self.providesTradingButton = providesTradingButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            contractID: try container.decode(Identifier.self, forKey: .contractID),
            issueID: try container.decode(Identifier.self, forKey: .issueID),
            fixture: try container.decode(DeterministicScenarioFixture.self, forKey: .fixture),
            replayWindow: try container.decode(ScenarioReplayWindow.self, forKey: .replayWindow),
            cursorSummary: try container.decode(ScenarioReplayCursorSummary.self, forKey: .cursorSummary),
            checksumEvidence: try container.decode(ScenarioReplayChecksumEvidence.self, forKey: .checksumEvidence),
            freshnessEvidence: try container.decode(ScenarioReplayFreshnessEvidence.self, forKey: .freshnessEvidence),
            validationAnchors: try container.decode([String].self, forKey: .validationAnchors),
            requiredValidationDependsOnNetwork: try container.decode(
                Bool.self,
                forKey: .requiredValidationDependsOnNetwork
            ),
            downloadsRealNetworkData: try container.decode(Bool.self, forKey: .downloadsRealNetworkData),
            runsProductionRetentionEngine: try container.decode(Bool.self, forKey: .runsProductionRetentionEngine),
            runsLargeScaleIngestionPipeline: try container.decode(Bool.self, forKey: .runsLargeScaleIngestionPipeline),
            buildsProductionDataPlatform: try container.decode(Bool.self, forKey: .buildsProductionDataPlatform),
            exposesDatabaseSchema: try container.decode(Bool.self, forKey: .exposesDatabaseSchema),
            exposesAdapterRequest: try container.decode(Bool.self, forKey: .exposesAdapterRequest),
            readsSecret: try container.decode(Bool.self, forKey: .readsSecret),
            usesSignedEndpoint: try container.decode(Bool.self, forKey: .usesSignedEndpoint),
            callsAccountEndpoint: try container.decode(Bool.self, forKey: .callsAccountEndpoint),
            createsListenKey: try container.decode(Bool.self, forKey: .createsListenKey),
            connectsBroker: try container.decode(Bool.self, forKey: .connectsBroker),
            implementsLiveExecutionAdapter: try container.decode(Bool.self, forKey: .implementsLiveExecutionAdapter),
            implementsOMS: try container.decode(Bool.self, forKey: .implementsOMS),
            implementsRealOrderLifecycle: try container.decode(Bool.self, forKey: .implementsRealOrderLifecycle),
            implementsReportInputVersioning: try container.decode(
                Bool.self,
                forKey: .implementsReportInputVersioning
            ),
            runsDataQualityGate: try container.decode(Bool.self, forKey: .runsDataQualityGate),
            runsLiveRuntime: try container.decode(Bool.self, forKey: .runsLiveRuntime),
            providesLiveCommand: try container.decode(Bool.self, forKey: .providesLiveCommand),
            providesTradingButton: try container.decode(Bool.self, forKey: .providesTradingButton)
        )
    }

    /// containsForbiddenCapabilityText 用于 focused tests 证明 MTP-106 evidence 文本未混入禁区能力。
    public func containsForbiddenCapabilityText(_ forbiddenTokens: [String]) -> Bool {
        let serialized = [
            contractID.rawValue,
            issueID.rawValue,
            replayWindow.deterministicWindowIdentity,
            cursorSummary.cursorIdentity,
            cursorSummary.summaryLine,
            checksumEvidence.checksum,
            checksumEvidence.canonicalPreimage,
            freshnessEvidence.freshnessSummary,
            dataQualityGateInputIdentity
        ]
        .joined(separator: " ")
        .lowercased()

        return forbiddenTokens.contains { token in
            serialized.contains(token.lowercased())
        }
    }

    public static let requiredValidationAnchors: [String] = [
        "MTP-106-DETERMINISTIC-REPLAY-WINDOW",
        "MTP-106-REPLAY-CURSOR-SUMMARY",
        "MTP-106-CHECKSUM-PARITY-EVIDENCE",
        "MTP-106-FIXTURE-FRESHNESS-EVIDENCE",
        "MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE",
        "MTP-106-SCENARIO-REPLAY-EVIDENCE-VALIDATION",
        "TVM-DATA-CATALOG-SCENARIO-REPLAY"
    ]

    public static let deterministicFixture: ScenarioReplayEvidence = {
        do {
            return try ScenarioReplayEvidence()
        } catch {
            preconditionFailure("MTP-106 scenario replay evidence fixture must be valid: \(error)")
        }
    }()

    private static func validate(
        fixture: DeterministicScenarioFixture,
        replayWindow: ScenarioReplayWindow,
        cursorSummary: ScenarioReplayCursorSummary,
        checksumEvidence: ScenarioReplayChecksumEvidence,
        freshnessEvidence: ScenarioReplayFreshnessEvidence,
        validationAnchors: [String],
        requiredValidationDependsOnNetwork: Bool,
        downloadsRealNetworkData: Bool,
        runsProductionRetentionEngine: Bool,
        runsLargeScaleIngestionPipeline: Bool,
        buildsProductionDataPlatform: Bool,
        exposesDatabaseSchema: Bool,
        exposesAdapterRequest: Bool,
        readsSecret: Bool,
        usesSignedEndpoint: Bool,
        callsAccountEndpoint: Bool,
        createsListenKey: Bool,
        connectsBroker: Bool,
        implementsLiveExecutionAdapter: Bool,
        implementsOMS: Bool,
        implementsRealOrderLifecycle: Bool,
        implementsReportInputVersioning: Bool,
        runsDataQualityGate: Bool,
        runsLiveRuntime: Bool,
        providesLiveCommand: Bool,
        providesTradingButton: Bool
    ) throws {
        let expectedWindow = try ScenarioReplayWindow(fixture: fixture)
        let expectedCursorSummary = ScenarioReplayCursorSummary()
        let expectedChecksum = try ScenarioReplayChecksumEvidence(summary: fixture.deterministicSummary)
        let expectedFreshness = try ScenarioReplayFreshnessEvidence()
        guard fixture.fixtureBoundaryHeld,
              replayWindow == expectedWindow,
              cursorSummary == expectedCursorSummary,
              checksumEvidence == expectedChecksum,
              freshnessEvidence == expectedFreshness,
              validationAnchors == Self.requiredValidationAnchors else {
            throw CoreError.dataCatalogScenarioReplayContractMismatch(
                field: "scenarioReplayEvidence",
                expected: expectedWindow.deterministicWindowIdentity,
                actual: replayWindow.deterministicWindowIdentity
            )
        }

        let forbiddenFlags: [(String, Bool)] = [
            ("requiredValidationDependsOnNetwork", requiredValidationDependsOnNetwork),
            ("downloadsRealNetworkData", downloadsRealNetworkData),
            ("runsProductionRetentionEngine", runsProductionRetentionEngine),
            ("runsLargeScaleIngestionPipeline", runsLargeScaleIngestionPipeline),
            ("buildsProductionDataPlatform", buildsProductionDataPlatform),
            ("exposesDatabaseSchema", exposesDatabaseSchema),
            ("exposesAdapterRequest", exposesAdapterRequest),
            ("readsSecret", readsSecret),
            ("usesSignedEndpoint", usesSignedEndpoint),
            ("callsAccountEndpoint", callsAccountEndpoint),
            ("createsListenKey", createsListenKey),
            ("connectsBroker", connectsBroker),
            ("implementsLiveExecutionAdapter", implementsLiveExecutionAdapter),
            ("implementsOMS", implementsOMS),
            ("implementsRealOrderLifecycle", implementsRealOrderLifecycle),
            ("implementsReportInputVersioning", implementsReportInputVersioning),
            ("runsDataQualityGate", runsDataQualityGate),
            ("runsLiveRuntime", runsLiveRuntime),
            ("providesLiveCommand", providesLiveCommand),
            ("providesTradingButton", providesTradingButton)
        ]

        if let capability = forbiddenFlags.first(where: \.1) {
            throw CoreError.dataCatalogScenarioReplayForbiddenCapability(
                "scenarioReplayEvidence.\(capability.0)"
            )
        }
    }
}
