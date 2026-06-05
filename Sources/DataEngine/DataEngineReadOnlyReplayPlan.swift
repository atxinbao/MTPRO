import Cache
import DataClient
import DomainModel
import Foundation
import MessageBus

/// DataEngineReadOnlyReplayPlan 是 DataEngine target 自己拥有的最小 ingest / replay plan。
///
/// 它串联 DataClient public source、MessageBus stream 和 Cache read model snapshot，
/// 证明 `DataEngine` target 能直接使用 data graph 依赖。它不实现 streaming runtime、
/// private stream、account endpoint、broker command 或 execution path。
public struct DataEngineReadOnlyReplayPlan: Codable, Equatable, Sendable {
    public let planID: FoundationTargetID
    public let source: DataClientReadOnlyMarketDataSource
    public let stream: MessageBusJournalStreamID
    public let cacheSnapshot: CacheReadModelSnapshot
    public let sourceRoot: String
    public let validationAnchors: [String]

    public init(
        planID: FoundationTargetID,
        source: DataClientReadOnlyMarketDataSource,
        stream: MessageBusJournalStreamID,
        cacheSnapshot: CacheReadModelSnapshot,
        sourceRoot: String = "Sources/DataEngine",
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) {
        self.planID = planID
        self.source = source
        self.stream = stream
        self.cacheSnapshot = cacheSnapshot
        self.sourceRoot = sourceRoot
        self.validationAnchors = validationAnchors
    }

    /// 生成中性 MessageBus payload label，不携带 adapter request、broker payload 或 account payload。
    public var payloadType: String {
        "dataengine.public-market-data.\(source.venue.rawValue).\(source.symbol.rawValue).\(source.timeframe.rawValue)"
    }

    public var ingestReplayQualityBoundaryHeld: Bool {
        sourceRoot == "Sources/DataEngine"
            && source.publicReadOnlyBoundaryHeld
            && cacheSnapshot.readModelBoundaryHeld
            && validationAnchors == Self.requiredValidationAnchors
            && implementsPrivateStreamRuntime == false
            && callsSignedOrAccountEndpoint == false
            && routesBrokerOrExecutionCommand == false
            && exposesLiveRuntime == false
    }

    public var implementsPrivateStreamRuntime: Bool { false }
    public var callsSignedOrAccountEndpoint: Bool { false }
    public var routesBrokerOrExecutionCommand: Bool { false }
    public var exposesLiveRuntime: Bool { false }

    public static let requiredValidationAnchors = [
        "GH-395-DATAENGINE-REAL-TARGET-SMOKE",
        "GH-395-DATAENGINE-READ-ONLY-REPLAY-PLAN"
    ]
}
