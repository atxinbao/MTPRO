import MTPROCore
import XCTest

final class MTPROCoreTests: XCTestCase {
    func testBaselineCapturesSelectedUniverseAndTimeframes() {
        let baseline = MTPROCoreBaseline()

        XCTAssertEqual(baseline.projectName, "MTPRO")
        XCTAssertEqual(baseline.executionMode, "paper-only")
        XCTAssertEqual(baseline.primaryUniverse, ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"])
        XCTAssertEqual(baseline.timeframes, ["1m", "5m"])
    }

    func testSymbolAndTimeframeContractsAcceptOnlyConfiguredUniverse() throws {
        let symbol = try MTPROSymbol(rawValue: "btcusdt")
        let oneMinute = try MTPROTimeframe(contractValue: "1m")
        let fiveMinutes = try MTPROTimeframe(contractValue: "5m")

        XCTAssertEqual(symbol.rawValue, "BTCUSDT")
        XCTAssertEqual(oneMinute, .oneMinute)
        XCTAssertEqual(fiveMinutes, .fiveMinutes)

        XCTAssertThrowsError(try MTPROSymbol(rawValue: "DOGEUSDT")) { error in
            XCTAssertEqual(error as? MTPROCoreError, .unsupportedSymbol("DOGEUSDT"))
        }
        XCTAssertThrowsError(try MTPROTimeframe(contractValue: "1h")) { error in
            XCTAssertEqual(error as? MTPROCoreError, .unsupportedTimeframe("1h"))
        }
    }

    func testPriceAndQuantityContractsRejectInvalidNumericValues() throws {
        let price = try MTPROPrice(100)
        let quantity = try MTPROQuantity(0)

        XCTAssertEqual(price.rawValue, 100)
        XCTAssertEqual(quantity.rawValue, 0)

        XCTAssertThrowsError(try MTPROPrice(-1, field: "bid")) { error in
            XCTAssertEqual(error as? MTPROCoreError, .invalidPrice("bid", -1))
        }
        XCTAssertThrowsError(try MTPROQuantity(-0.01, field: "volume")) { error in
            XCTAssertEqual(error as? MTPROCoreError, .invalidQuantity("volume", -0.01))
        }
    }

    func testDateAndSequenceRangesRejectInvalidBoundaries() throws {
        let start = Date(timeIntervalSince1970: 100)
        let end = Date(timeIntervalSince1970: 160)

        let validDateRange = try MTPRODateRange(start: start, end: end)
        let validSequenceRange = try EventSequenceRange(lowerBound: 1, upperBound: 3)

        XCTAssertEqual(validDateRange.start, start)
        XCTAssertEqual(validDateRange.end, end)
        XCTAssertTrue(validSequenceRange.contains(2))
        XCTAssertFalse(validSequenceRange.contains(4))

        XCTAssertThrowsError(try MTPRODateRange(start: end, end: start)) { error in
            XCTAssertEqual(error as? MTPROCoreError, .invalidDateRange)
        }
        XCTAssertThrowsError(try EventSequenceRange(lowerBound: 0, upperBound: 1)) { error in
            XCTAssertEqual(error as? MTPROCoreError, .invalidSequenceRange)
        }
        XCTAssertThrowsError(try EventSequenceRange(lowerBound: 4, upperBound: 3)) { error in
            XCTAssertEqual(error as? MTPROCoreError, .invalidSequenceRange)
        }
    }

    func testEventEnvelopeWrapsMarketEventsAndRoundTripsThroughCodable() throws {
        let bar = try makeMarketBar()
        let event = MTPRODomainEvent.market(.bar(bar))
        let envelope = try EventEnvelope(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            sequence: 1,
            stream: .market,
            recordedAt: Date(timeIntervalSince1970: 200),
            event: event
        )

        let encoded = try JSONEncoder().encode(envelope)
        let decoded = try JSONDecoder().decode(EventEnvelope.self, from: encoded)

        XCTAssertEqual(decoded, envelope)
        XCTAssertEqual(decoded.sequence, 1)
        XCTAssertEqual(decoded.stream, .market)
        XCTAssertEqual(decoded.event, event)
    }

    func testCodableDecodingCannotBypassCoreContractValidation() {
        let decoder = JSONDecoder()

        XCTAssertThrowsError(
            try decoder.decode(MTPROSymbol.self, from: Data(#""DOGEUSDT""#.utf8))
        )
        XCTAssertThrowsError(
            try decoder.decode(MTPRODateRange.self, from: Data(#"{"start":160,"end":100}"#.utf8))
        )
        XCTAssertThrowsError(
            try decoder.decode(EventSequenceRange.self, from: Data(#"{"lowerBound":0,"upperBound":1}"#.utf8))
        )
        XCTAssertThrowsError(
            try decoder.decode(
                PaperSessionCommand.self,
                from: Data(#"{"strategyID":"ema-cross","riskProfileID":"paper-risk","executionMode":"backtest"}"#.utf8)
            )
        )
    }

    func testAppendOnlyEventLogAssignsMonotonicSequencesAndReplaysRanges() throws {
        let marketEvent = MTPRODomainEvent.market(.bar(try makeMarketBar()))
        let backtestEvent = MTPRODomainEvent.backtest(
            .requested(try makeBacktestCommand())
        )
        let portfolioEvent = MTPRODomainEvent.portfolio(
            .projectionRequested(
                PortfolioQuery(
                    portfolioID: try MTPROIdentifier("portfolio-main"),
                    asOf: Date(timeIntervalSince1970: 180)
                )
            )
        )
        var log = try AppendOnlyEventLog()

        let first = try log.append(marketEvent, stream: .market, recordedAt: Date(timeIntervalSince1970: 201))
        let second = try log.append(backtestEvent, stream: .backtest, recordedAt: Date(timeIntervalSince1970: 202))
        let third = try log.append(portfolioEvent, stream: .portfolio, recordedAt: Date(timeIntervalSince1970: 203))

        XCTAssertEqual(first.sequence, 1)
        XCTAssertEqual(second.sequence, 2)
        XCTAssertEqual(third.sequence, 3)
        XCTAssertEqual(log.envelopes.map(\.sequence), [1, 2, 3])

        let replayCommand = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 2, upperBound: 3),
            streams: [.portfolio]
        )
        let replay = log.replay(replayCommand)

        XCTAssertEqual(replay.envelopes.map(\.sequence), [3])
        XCTAssertEqual(replay.envelopes.first?.event, portfolioEvent)
    }

    func testCommandAndQueryContractsRejectLiveExecutionMode() throws {
        let marketDataQuery = MarketDataQuery(
            symbol: try MTPROSymbol(rawValue: "ETHUSDT"),
            timeframe: .fiveMinutes,
            range: try MTPRODateRange(
                start: Date(timeIntervalSince1970: 300),
                end: Date(timeIntervalSince1970: 600)
            )
        )
        let backtestCommand = BacktestCommand(
            strategyID: try MTPROIdentifier("ema-cross"),
            marketData: marketDataQuery
        )
        let paperCommand = try PaperSessionCommand(
            strategyID: try MTPROIdentifier("ema-cross"),
            riskProfileID: try MTPROIdentifier("paper-risk"),
            executionMode: try MTPROExecutionMode(contractValue: "paper")
        )

        XCTAssertEqual(MTPROCommand.runBacktest(backtestCommand), .runBacktest(backtestCommand))
        XCTAssertEqual(MTPROCommand.startPaperSession(paperCommand), .startPaperSession(paperCommand))
        XCTAssertEqual(MTPROQuery.marketData(marketDataQuery), .marketData(marketDataQuery))

        XCTAssertThrowsError(try MTPROExecutionMode(contractValue: "live")) { error in
            XCTAssertEqual(error as? MTPROCoreError, .liveExecutionForbidden("live"))
        }
        XCTAssertThrowsError(
            try PaperSessionCommand(
                strategyID: try MTPROIdentifier("ema-cross"),
                riskProfileID: try MTPROIdentifier("paper-risk"),
                executionMode: .backtest
            )
        ) { error in
            XCTAssertEqual(error as? MTPROCoreError, .paperSessionRequiresPaperMode)
        }
    }

    func testAppendOnlyEventLogRejectsNonContiguousSeedSequences() throws {
        let first = try EventEnvelope(
            sequence: 1,
            stream: .market,
            recordedAt: Date(timeIntervalSince1970: 1),
            event: .market(.bar(try makeMarketBar()))
        )
        let third = try EventEnvelope(
            sequence: 3,
            stream: .market,
            recordedAt: Date(timeIntervalSince1970: 3),
            event: .market(.bar(try makeMarketBar()))
        )

        XCTAssertThrowsError(try AppendOnlyEventLog(envelopes: [first, third])) { error in
            XCTAssertEqual(error as? MTPROCoreError, .invalidSequenceRange)
        }
    }

    private func makeMarketBar() throws -> MTPROMarketBar {
        try MTPROMarketBar(
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            interval: try MTPRODateRange(
                start: Date(timeIntervalSince1970: 100),
                end: Date(timeIntervalSince1970: 160)
            ),
            open: 100,
            high: 110,
            low: 95,
            close: 105,
            volume: 42
        )
    }

    private func makeBacktestCommand() throws -> BacktestCommand {
        BacktestCommand(
            strategyID: try MTPROIdentifier("ema-cross"),
            marketData: MarketDataQuery(
                symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                range: try MTPRODateRange(
                    start: Date(timeIntervalSince1970: 100),
                    end: Date(timeIntervalSince1970: 160)
                )
            )
        )
    }
}
