import Foundation

public enum MTPROCoreError: Error, Equatable, Sendable, CustomStringConvertible {
    case unsupportedSymbol(String)
    case unsupportedTimeframe(String)
    case unsupportedExecutionMode(String)
    case liveExecutionForbidden(String)
    case invalidDateRange
    case invalidSequenceRange
    case invalidEventSequence(Int)
    case invalidPrice(String, Double)
    case invalidQuantity(String, Double)
    case paperSessionRequiresPaperMode
    case emptyIdentifier(String)

    public var description: String {
        switch self {
        case let .unsupportedSymbol(value):
            "Unsupported symbol: \(value)"
        case let .unsupportedTimeframe(value):
            "Unsupported timeframe: \(value)"
        case let .unsupportedExecutionMode(value):
            "Unsupported execution mode: \(value)"
        case let .liveExecutionForbidden(value):
            "Live execution is forbidden: \(value)"
        case .invalidDateRange:
            "Date range must have start before end"
        case .invalidSequenceRange:
            "Event sequence range is invalid"
        case let .invalidEventSequence(value):
            "Event sequence must be positive: \(value)"
        case let .invalidPrice(field, value):
            "Price must be finite and positive for \(field): \(value)"
        case let .invalidQuantity(field, value):
            "Quantity must be finite and non-negative for \(field): \(value)"
        case .paperSessionRequiresPaperMode:
            "Paper session command requires paper mode"
        case let .emptyIdentifier(field):
            "Identifier must not be empty: \(field)"
        }
    }
}

public struct MTPROSymbol: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public static let supportedRawValues = ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"]

    public let rawValue: String

    public init(rawValue: String) throws {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard Self.supportedRawValues.contains(normalized) else {
            throw MTPROCoreError.unsupportedSymbol(rawValue)
        }
        self.rawValue = normalized
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        try self.init(rawValue: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var description: String {
        rawValue
    }
}

public enum MTPROTimeframe: String, Codable, CaseIterable, Equatable, Sendable {
    case oneMinute = "1m"
    case fiveMinutes = "5m"

    public static var supportedRawValues: [String] {
        allCases.map(\.rawValue)
    }

    public init(contractValue: String) throws {
        guard let timeframe = Self(rawValue: contractValue) else {
            throw MTPROCoreError.unsupportedTimeframe(contractValue)
        }
        self = timeframe
    }
}

public enum MTPROExecutionMode: String, Codable, CaseIterable, Equatable, Sendable {
    case backtest
    case paper

    public init(contractValue: String) throws {
        let normalized = contractValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case Self.backtest.rawValue:
            self = .backtest
        case Self.paper.rawValue:
            self = .paper
        case "live", "broker", "real", "production":
            throw MTPROCoreError.liveExecutionForbidden(contractValue)
        default:
            throw MTPROCoreError.unsupportedExecutionMode(contractValue)
        }
    }
}

public struct MTPRODateRange: Codable, Equatable, Sendable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) throws {
        guard start < end else {
            throw MTPROCoreError.invalidDateRange
        }
        self.start = start
        self.end = end
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let start = try container.decode(Date.self, forKey: .start)
        let end = try container.decode(Date.self, forKey: .end)
        try self.init(start: start, end: end)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
    }

    private enum CodingKeys: String, CodingKey {
        case start
        case end
    }
}

public struct MTPROIdentifier: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String, field: String = "identifier") throws {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw MTPROCoreError.emptyIdentifier(field)
        }
        self.rawValue = trimmed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var description: String {
        rawValue
    }
}

public struct MTPROPrice: Codable, Equatable, Sendable {
    public let rawValue: Double

    public init(_ rawValue: Double, field: String = "price") throws {
        guard rawValue.isFinite, rawValue > 0 else {
            throw MTPROCoreError.invalidPrice(field, rawValue)
        }
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Double.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct MTPROQuantity: Codable, Equatable, Sendable {
    public let rawValue: Double

    public init(_ rawValue: Double, field: String = "quantity") throws {
        guard rawValue.isFinite, rawValue >= 0 else {
            throw MTPROCoreError.invalidQuantity(field, rawValue)
        }
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Double.self)
        try self.init(rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct MTPROMarketBar: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let interval: MTPRODateRange
    public let open: MTPROPrice
    public let high: MTPROPrice
    public let low: MTPROPrice
    public let close: MTPROPrice
    public let volume: MTPROQuantity

    public init(
        symbol: MTPROSymbol,
        timeframe: MTPROTimeframe,
        interval: MTPRODateRange,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double
    ) throws {
        self.symbol = symbol
        self.timeframe = timeframe
        self.interval = interval
        self.open = try MTPROPrice(open, field: "open")
        self.high = try MTPROPrice(high, field: "high")
        self.low = try MTPROPrice(low, field: "low")
        self.close = try MTPROPrice(close, field: "close")
        self.volume = try MTPROQuantity(volume, field: "volume")
    }
}

public struct MTPROTradeTick: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let tradedAt: Date
    public let price: MTPROPrice
    public let quantity: MTPROQuantity
    public let makerSide: MTPROBookSide

    public init(
        symbol: MTPROSymbol,
        tradedAt: Date,
        price: Double,
        quantity: Double,
        makerSide: MTPROBookSide
    ) throws {
        self.symbol = symbol
        self.tradedAt = tradedAt
        self.price = try MTPROPrice(price)
        self.quantity = try MTPROQuantity(quantity)
        self.makerSide = makerSide
    }
}

public enum MTPROBookSide: String, Codable, Equatable, Sendable {
    case bid
    case ask
}

public struct MTPROOrderBookLevel: Codable, Equatable, Sendable {
    public let price: MTPROPrice
    public let quantity: MTPROQuantity

    public init(price: Double, quantity: Double) throws {
        self.price = try MTPROPrice(price)
        self.quantity = try MTPROQuantity(quantity)
    }
}

public struct MTPROBestBidAsk: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let observedAt: Date
    public let bid: MTPROOrderBookLevel
    public let ask: MTPROOrderBookLevel

    public init(
        symbol: MTPROSymbol,
        observedAt: Date,
        bid: MTPROOrderBookLevel,
        ask: MTPROOrderBookLevel
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bid = bid
        self.ask = ask
    }
}

public struct MTPROOrderBookSnapshot: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let observedAt: Date
    public let bids: [MTPROOrderBookLevel]
    public let asks: [MTPROOrderBookLevel]

    public init(
        symbol: MTPROSymbol,
        observedAt: Date,
        bids: [MTPROOrderBookLevel],
        asks: [MTPROOrderBookLevel]
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bids = bids
        self.asks = asks
    }
}

public struct MTPROOrderBookDelta: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let observedAt: Date
    public let bidUpdates: [MTPROOrderBookLevel]
    public let askUpdates: [MTPROOrderBookLevel]

    public init(
        symbol: MTPROSymbol,
        observedAt: Date,
        bidUpdates: [MTPROOrderBookLevel],
        askUpdates: [MTPROOrderBookLevel]
    ) {
        self.symbol = symbol
        self.observedAt = observedAt
        self.bidUpdates = bidUpdates
        self.askUpdates = askUpdates
    }
}

public enum MTPROMarketEvent: Codable, Equatable, Sendable {
    case bar(MTPROMarketBar)
    case trade(MTPROTradeTick)
    case bestBidAsk(MTPROBestBidAsk)
    case orderBookSnapshot(MTPROOrderBookSnapshot)
    case orderBookDelta(MTPROOrderBookDelta)
}

public enum MTPROSignalDirection: String, Codable, Equatable, Sendable {
    case long
    case flat
}

public struct MTPROStrategySignalEvent: Codable, Equatable, Sendable {
    public let strategyID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let direction: MTPROSignalDirection
    public let generatedAt: Date

    public init(
        strategyID: MTPROIdentifier,
        symbol: MTPROSymbol,
        direction: MTPROSignalDirection,
        generatedAt: Date
    ) {
        self.strategyID = strategyID
        self.symbol = symbol
        self.direction = direction
        self.generatedAt = generatedAt
    }
}

public enum MTPROBacktestEvent: Codable, Equatable, Sendable {
    case requested(BacktestCommand)
    case completed(MTPROIdentifier)
}

public enum MTPROPaperEvent: Codable, Equatable, Sendable {
    case sessionRequested(PaperSessionCommand)
    case simulatedOrderAccepted(MTPROIdentifier)
}

public enum MTPRORiskEvent: Codable, Equatable, Sendable {
    case evaluationRequested(RiskEvaluationQuery)
    case rejected(MTPROIdentifier)
}

public enum MTPROPortfolioEvent: Codable, Equatable, Sendable {
    case projectionRequested(PortfolioQuery)
    case projectionUpdated(MTPROIdentifier)
}

public struct MTPROReplayEvent: Codable, Equatable, Sendable {
    public let command: EventReplayCommand
    public let replayedCount: Int

    public init(command: EventReplayCommand, replayedCount: Int) {
        self.command = command
        self.replayedCount = replayedCount
    }
}

public enum MTPRODomainEvent: Codable, Equatable, Sendable {
    case market(MTPROMarketEvent)
    case strategySignal(MTPROStrategySignalEvent)
    case backtest(MTPROBacktestEvent)
    case paper(MTPROPaperEvent)
    case risk(MTPRORiskEvent)
    case portfolio(MTPROPortfolioEvent)
    case replay(MTPROReplayEvent)
}

public struct MarketDataQuery: Codable, Equatable, Sendable {
    public let symbol: MTPROSymbol
    public let timeframe: MTPROTimeframe
    public let range: MTPRODateRange

    public init(symbol: MTPROSymbol, timeframe: MTPROTimeframe, range: MTPRODateRange) {
        self.symbol = symbol
        self.timeframe = timeframe
        self.range = range
    }
}

public struct BacktestCommand: Codable, Equatable, Sendable {
    public let strategyID: MTPROIdentifier
    public let marketData: MarketDataQuery

    public init(strategyID: MTPROIdentifier, marketData: MarketDataQuery) {
        self.strategyID = strategyID
        self.marketData = marketData
    }
}

public struct PaperSessionCommand: Codable, Equatable, Sendable {
    public let strategyID: MTPROIdentifier
    public let riskProfileID: MTPROIdentifier
    public let executionMode: MTPROExecutionMode

    public init(
        strategyID: MTPROIdentifier,
        riskProfileID: MTPROIdentifier,
        executionMode: MTPROExecutionMode
    ) throws {
        guard executionMode == .paper else {
            throw MTPROCoreError.paperSessionRequiresPaperMode
        }
        self.strategyID = strategyID
        self.riskProfileID = riskProfileID
        self.executionMode = executionMode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let strategyID = try container.decode(MTPROIdentifier.self, forKey: .strategyID)
        let riskProfileID = try container.decode(MTPROIdentifier.self, forKey: .riskProfileID)
        let executionMode = try container.decode(MTPROExecutionMode.self, forKey: .executionMode)
        try self.init(strategyID: strategyID, riskProfileID: riskProfileID, executionMode: executionMode)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(strategyID, forKey: .strategyID)
        try container.encode(riskProfileID, forKey: .riskProfileID)
        try container.encode(executionMode, forKey: .executionMode)
    }

    private enum CodingKeys: String, CodingKey {
        case strategyID
        case riskProfileID
        case executionMode
    }
}

public struct RiskEvaluationQuery: Codable, Equatable, Sendable {
    public let paperOrderID: MTPROIdentifier
    public let symbol: MTPROSymbol
    public let proposedQuantity: Double

    public init(paperOrderID: MTPROIdentifier, symbol: MTPROSymbol, proposedQuantity: Double) {
        self.paperOrderID = paperOrderID
        self.symbol = symbol
        self.proposedQuantity = proposedQuantity
    }
}

public struct PortfolioQuery: Codable, Equatable, Sendable {
    public let portfolioID: MTPROIdentifier
    public let asOf: Date

    public init(portfolioID: MTPROIdentifier, asOf: Date) {
        self.portfolioID = portfolioID
        self.asOf = asOf
    }
}

public enum MTPROCommand: Codable, Equatable, Sendable {
    case runBacktest(BacktestCommand)
    case startPaperSession(PaperSessionCommand)
    case replayEvents(EventReplayCommand)
}

public enum MTPROQuery: Codable, Equatable, Sendable {
    case marketData(MarketDataQuery)
    case riskEvaluation(RiskEvaluationQuery)
    case portfolio(PortfolioQuery)
}

public struct EventStreamID: Codable, Equatable, Hashable, Sendable, CustomStringConvertible {
    public static let market = EventStreamID(rawValue: "market")
    public static let strategy = EventStreamID(rawValue: "strategy")
    public static let backtest = EventStreamID(rawValue: "backtest")
    public static let paper = EventStreamID(rawValue: "paper")
    public static let risk = EventStreamID(rawValue: "risk")
    public static let portfolio = EventStreamID(rawValue: "portfolio")
    public static let replay = EventStreamID(rawValue: "replay")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue
    }
}

public struct EventEnvelope: Codable, Equatable, Sendable {
    public let id: UUID
    public let sequence: Int
    public let stream: EventStreamID
    public let recordedAt: Date
    public let correlationID: UUID?
    public let causationID: UUID?
    public let event: MTPRODomainEvent

    public init(
        id: UUID = UUID(),
        sequence: Int,
        stream: EventStreamID,
        recordedAt: Date,
        correlationID: UUID? = nil,
        causationID: UUID? = nil,
        event: MTPRODomainEvent
    ) throws {
        guard sequence > 0 else {
            throw MTPROCoreError.invalidEventSequence(sequence)
        }
        self.id = id
        self.sequence = sequence
        self.stream = stream
        self.recordedAt = recordedAt
        self.correlationID = correlationID
        self.causationID = causationID
        self.event = event
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let sequence = try container.decode(Int.self, forKey: .sequence)
        let stream = try container.decode(EventStreamID.self, forKey: .stream)
        let recordedAt = try container.decode(Date.self, forKey: .recordedAt)
        let correlationID = try container.decodeIfPresent(UUID.self, forKey: .correlationID)
        let causationID = try container.decodeIfPresent(UUID.self, forKey: .causationID)
        let event = try container.decode(MTPRODomainEvent.self, forKey: .event)
        try self.init(
            id: id,
            sequence: sequence,
            stream: stream,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID,
            event: event
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sequence, forKey: .sequence)
        try container.encode(stream, forKey: .stream)
        try container.encode(recordedAt, forKey: .recordedAt)
        try container.encodeIfPresent(correlationID, forKey: .correlationID)
        try container.encodeIfPresent(causationID, forKey: .causationID)
        try container.encode(event, forKey: .event)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case sequence
        case stream
        case recordedAt
        case correlationID
        case causationID
        case event
    }
}

public struct EventSequenceRange: Codable, Equatable, Sendable {
    public let lowerBound: Int?
    public let upperBound: Int?

    public init(lowerBound: Int? = nil, upperBound: Int? = nil) throws {
        if let lowerBound, lowerBound < 1 {
            throw MTPROCoreError.invalidSequenceRange
        }
        if let upperBound, upperBound < 1 {
            throw MTPROCoreError.invalidSequenceRange
        }
        if let lowerBound, let upperBound, lowerBound > upperBound {
            throw MTPROCoreError.invalidSequenceRange
        }
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lowerBound = try container.decodeIfPresent(Int.self, forKey: .lowerBound)
        let upperBound = try container.decodeIfPresent(Int.self, forKey: .upperBound)
        try self.init(lowerBound: lowerBound, upperBound: upperBound)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(lowerBound, forKey: .lowerBound)
        try container.encodeIfPresent(upperBound, forKey: .upperBound)
    }

    public func contains(_ sequence: Int) -> Bool {
        if let lowerBound, sequence < lowerBound {
            return false
        }
        if let upperBound, sequence > upperBound {
            return false
        }
        return true
    }

    private enum CodingKeys: String, CodingKey {
        case lowerBound
        case upperBound
    }
}

public struct EventReplayCommand: Codable, Equatable, Sendable {
    public let range: EventSequenceRange
    public let streams: Set<EventStreamID>

    public init(range: EventSequenceRange, streams: Set<EventStreamID> = []) {
        self.range = range
        self.streams = streams
    }
}

public struct EventReplayResult: Codable, Equatable, Sendable {
    public let command: EventReplayCommand
    public let envelopes: [EventEnvelope]

    public init(command: EventReplayCommand, envelopes: [EventEnvelope]) {
        self.command = command
        self.envelopes = envelopes
    }
}

public struct AppendOnlyEventLog: Equatable, Sendable {
    public private(set) var envelopes: [EventEnvelope]

    public init(envelopes: [EventEnvelope] = []) throws {
        let sequences = envelopes.map(\.sequence)
        let expectedSequences = sequences.indices.map { $0 + 1 }
        guard sequences == expectedSequences else {
            throw MTPROCoreError.invalidSequenceRange
        }
        self.envelopes = envelopes
    }

    @discardableResult
    public mutating func append(
        _ event: MTPRODomainEvent,
        stream: EventStreamID,
        recordedAt: Date = Date(),
        correlationID: UUID? = nil,
        causationID: UUID? = nil
    ) throws -> EventEnvelope {
        let envelope = try EventEnvelope(
            sequence: envelopes.count + 1,
            stream: stream,
            recordedAt: recordedAt,
            correlationID: correlationID,
            causationID: causationID,
            event: event
        )
        envelopes.append(envelope)
        return envelope
    }

    public func replay(_ command: EventReplayCommand) -> EventReplayResult {
        let matchedEnvelopes = envelopes.filter { envelope in
            command.range.contains(envelope.sequence)
                && (command.streams.isEmpty || command.streams.contains(envelope.stream))
        }
        return EventReplayResult(command: command, envelopes: matchedEnvelopes)
    }
}

public struct MTPROCoreBaseline: Equatable, Sendable {
    public let projectName: String
    public let coreMode: String
    public let executionMode: String
    public let primaryUniverse: [String]
    public let timeframes: [String]

    public init(
        projectName: String = "MTPRO",
        coreMode: String = "Swift-only actor core",
        executionMode: String = "paper-only",
        primaryUniverse: [String] = MTPROSymbol.supportedRawValues,
        timeframes: [String] = MTPROTimeframe.supportedRawValues
    ) {
        self.projectName = projectName
        self.coreMode = coreMode
        self.executionMode = executionMode
        self.primaryUniverse = primaryUniverse
        self.timeframes = timeframes
    }
}
