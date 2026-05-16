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

    func testMessageBusPublishesMonotonicSequencesAndReplaysSelectedStreams() throws {
        var messageBus = try MTPROMessageBus()
        let marketEvent = MTPRODomainEvent.market(.bar(try makeMarketBar()))
        let signalEvent = MTPRODomainEvent.strategySignal(
            MTPROStrategySignalEvent(
                strategyID: try MTPROIdentifier("ema-cross"),
                symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
                direction: .long,
                generatedAt: Date(timeIntervalSince1970: 220)
            )
        )

        let first = try messageBus.publish(
            marketEvent,
            stream: .market,
            recordedAt: Date(timeIntervalSince1970: 221)
        )
        let second = try messageBus.publish(
            signalEvent,
            stream: .strategy,
            recordedAt: Date(timeIntervalSince1970: 222)
        )

        XCTAssertEqual(first.sequence, 1)
        XCTAssertEqual(second.sequence, 2)
        XCTAssertEqual(messageBus.envelopes.map(\.sequence), [1, 2])

        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: 2),
                streams: [.market]
            )
        )

        XCTAssertEqual(replay.envelopes, [first])
        XCTAssertEqual(replay.envelopes.first?.event, marketEvent)
    }

    func testDataEngineMovesReadOnlyMarketEventsIntoCacheAndEventStream() throws {
        var messageBus = try MTPROMessageBus()
        var cache = MTPROMarketDataCache()
        let dataEngine = MTPRODataEngine()
        let bar = try makeMarketBar()

        let envelope = try dataEngine.ingest(
            .bar(bar),
            cache: &cache,
            messageBus: &messageBus,
            recordedAt: Date(timeIntervalSince1970: 230)
        )

        let key = MTPROMarketDataSeriesKey(symbol: bar.symbol, timeframe: bar.timeframe)
        XCTAssertEqual(envelope.sequence, 1)
        XCTAssertEqual(envelope.stream, .market)
        XCTAssertEqual(envelope.event, .market(.bar(bar)))
        XCTAssertEqual(messageBus.envelopes, [envelope])
        XCTAssertEqual(cache.snapshot.barsBySeries[key], [bar])
        XCTAssertEqual(cache.snapshot.marketEventCount, 1)
    }

    func testCacheProjectionIsDeterministicFromMessageBusReplay() throws {
        var messageBus = try MTPROMessageBus()
        var cache = MTPROMarketDataCache()
        let dataEngine = MTPRODataEngine()
        let bar = try makeMarketBar(close: 105, start: 300)
        let trade = try makeTradeTick()
        let bestBidAsk = try makeBestBidAsk()

        try dataEngine.ingest(.bar(bar), cache: &cache, messageBus: &messageBus, recordedAt: Date(timeIntervalSince1970: 301))
        try dataEngine.ingest(.trade(trade), cache: &cache, messageBus: &messageBus, recordedAt: Date(timeIntervalSince1970: 302))
        try dataEngine.ingest(.bestBidAsk(bestBidAsk), cache: &cache, messageBus: &messageBus, recordedAt: Date(timeIntervalSince1970: 303))

        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: 3),
                streams: [.market]
            )
        )
        let projectedSnapshot = MTPROMarketDataCache.project(replay.envelopes)

        XCTAssertEqual(projectedSnapshot, cache.snapshot)
        XCTAssertEqual(projectedSnapshot.marketEventCount, 3)
        XCTAssertEqual(projectedSnapshot.tradesBySymbol[trade.symbol], [trade])
        XCTAssertEqual(projectedSnapshot.bestBidAskBySymbol[bestBidAsk.symbol], bestBidAsk)
    }

    func testTradingKernelActorSerializesConcurrentMarketIngestion() async throws {
        let kernel = try MTPROTradingKernel()
        let marketEvents: [MTPROMarketEvent] = [
            .bar(try makeMarketBar(close: 101, start: 400)),
            .bar(try makeMarketBar(close: 102, start: 460)),
            .trade(try makeTradeTick(price: 42010.50, quantity: 0.125, tradedAt: 470))
        ]

        let envelopes = try await withThrowingTaskGroup(of: EventEnvelope.self) { group in
            for (index, event) in marketEvents.enumerated() {
                group.addTask {
                    try await kernel.ingestMarketEvent(
                        event,
                        recordedAt: Date(timeIntervalSince1970: 500 + Double(index))
                    )
                }
            }

            var envelopes: [EventEnvelope] = []
            for try await envelope in group {
                envelopes.append(envelope)
            }
            return envelopes
        }

        let sequences = envelopes.map(\.sequence).sorted()
        let eventStream = await kernel.eventStream()
        let snapshot = await kernel.cacheSnapshot()
        let symbol = try MTPROSymbol(rawValue: "BTCUSDT")
        let key = MTPROMarketDataSeriesKey(
            symbol: symbol,
            timeframe: .oneMinute
        )

        XCTAssertEqual(sequences, [1, 2, 3])
        XCTAssertEqual(eventStream.map(\.sequence), [1, 2, 3])
        XCTAssertEqual(snapshot.barsBySeries[key]?.count, 2)
        XCTAssertEqual(snapshot.tradesBySymbol[symbol]?.count, 1)
        XCTAssertEqual(snapshot.marketEventCount, 3)
    }

    func testTradingKernelCanRebuildCacheFromReplayCommand() async throws {
        let kernel = try MTPROTradingKernel()
        let firstBar = try makeMarketBar(close: 101, start: 600)
        let secondBar = try makeMarketBar(close: 102, start: 660)

        try await kernel.ingestMarketEvent(.bar(firstBar), recordedAt: Date(timeIntervalSince1970: 601))
        try await kernel.ingestMarketEvent(.bar(secondBar), recordedAt: Date(timeIntervalSince1970: 661))

        let replayCommand = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 2, upperBound: 2),
            streams: [.market]
        )
        let rebuiltSnapshot = await kernel.rebuildCache(from: replayCommand)
        let key = MTPROMarketDataSeriesKey(symbol: firstBar.symbol, timeframe: firstBar.timeframe)

        XCTAssertEqual(rebuiltSnapshot.barsBySeries[key], [secondBar])
        XCTAssertEqual(rebuiltSnapshot.marketEventCount, 1)
    }

    private func makeMarketBar(close: Double = 105, start: TimeInterval = 100) throws -> MTPROMarketBar {
        try MTPROMarketBar(
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            interval: try MTPRODateRange(
                start: Date(timeIntervalSince1970: start),
                end: Date(timeIntervalSince1970: start + 60)
            ),
            open: 100,
            high: 110,
            low: 95,
            close: close,
            volume: 42
        )
    }

    private func makeTradeTick(
        price: Double = 42000,
        quantity: Double = 0.25,
        tradedAt: TimeInterval = 310
    ) throws -> MTPROTradeTick {
        try MTPROTradeTick(
            symbol: try MTPROSymbol(rawValue: "BTCUSDT"),
            tradedAt: Date(timeIntervalSince1970: tradedAt),
            price: price,
            quantity: quantity,
            makerSide: .bid
        )
    }

    private func makeBestBidAsk() throws -> MTPROBestBidAsk {
        try MTPROBestBidAsk(
            symbol: MTPROSymbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 320),
            bid: MTPROOrderBookLevel(price: 41999, quantity: 1.25),
            ask: MTPROOrderBookLevel(price: 42001, quantity: 0.75)
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
