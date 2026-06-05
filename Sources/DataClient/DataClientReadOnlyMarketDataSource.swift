import DomainModel
import Foundation

/// DataClientTargetOwnershipError 描述 DataClient target smoke surface 的最小合同错误。
///
/// 该错误类型只服务 GH-395 real target smoke tests，用来证明 `DataClient`
/// target 已能独立编译并暴露非 TargetGraph 的 public read-only source API。
public enum DataClientTargetOwnershipError: Error, Equatable, Sendable, CustomStringConvertible {
    case emptyDatasetVersion

    public var description: String {
        switch self {
        case .emptyDatasetVersion:
            "DataClient dataset version must not be empty"
        }
    }
}

/// DataClientVenue 是 public market data input adapter 的 venue identity。
///
/// 当前只允许 Binance public read-only 数据源。这里不表达 signed endpoint、
/// account endpoint、listenKey、private stream runtime、broker 或 execution adapter。
public enum DataClientVenue: String, Codable, Equatable, Sendable {
    case binance
}

/// DataClientReadOnlyMarketDataSource 是 DataClient target 自己拥有的最小数据源合同。
///
/// 它只描述本地可验证的 public read-only market data source identity，证明
/// `DataClient` target 不只是 TargetGraph boundary anchor。完整 Binance adapter
/// implementation 仍留在 `Adapters` compatibility envelope，后续 GH-396 再迁移。
public struct DataClientReadOnlyMarketDataSource: Codable, Equatable, Sendable {
    public let sourceID: FoundationTargetID
    public let venue: DataClientVenue
    public let symbol: Symbol
    public let timeframe: Timeframe
    public let datasetVersion: String
    public let sourceRoot: String
    public let validationAnchors: [String]

    public init(
        sourceID: FoundationTargetID,
        venue: DataClientVenue,
        symbol: Symbol,
        timeframe: Timeframe,
        datasetVersion: String,
        sourceRoot: String = "Sources/DataClient",
        validationAnchors: [String] = Self.requiredValidationAnchors
    ) throws {
        let trimmedDatasetVersion = datasetVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedDatasetVersion.isEmpty == false else {
            throw DataClientTargetOwnershipError.emptyDatasetVersion
        }
        self.sourceID = sourceID
        self.venue = venue
        self.symbol = symbol
        self.timeframe = timeframe
        self.datasetVersion = trimmedDatasetVersion
        self.sourceRoot = sourceRoot
        self.validationAnchors = validationAnchors
    }

    /// DataClient 当前只能提供 public read-only data input。
    public var publicReadOnlyBoundaryHeld: Bool {
        sourceRoot == "Sources/DataClient"
            && validationAnchors == Self.requiredValidationAnchors
            && callsSignedEndpoint == false
            && callsAccountEndpoint == false
            && createsListenKey == false
            && connectsPrivateWebSocketRuntime == false
            && connectsBrokerOrExecutionAdapter == false
    }

    public var callsSignedEndpoint: Bool { false }
    public var callsAccountEndpoint: Bool { false }
    public var createsListenKey: Bool { false }
    public var connectsPrivateWebSocketRuntime: Bool { false }
    public var connectsBrokerOrExecutionAdapter: Bool { false }

    public static let requiredValidationAnchors = [
        "GH-395-DATACLIENT-REAL-TARGET-SMOKE",
        "GH-395-DATACLIENT-PUBLIC-READ-ONLY-SOURCE"
    ]
}
