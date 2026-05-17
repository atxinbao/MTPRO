import Core
import XCTest

final class CoreTests: XCTestCase {
    func testBaselineCapturesSelectedUniverseAndTimeframes() {
        let baseline = CoreBaseline()

        XCTAssertEqual(baseline.projectName, "MTPRO")
        XCTAssertEqual(baseline.executionMode, "paper-only")
        XCTAssertEqual(baseline.primaryUniverse, ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT", "XRPUSDT"])
        XCTAssertEqual(baseline.timeframes, ["1m", "5m"])
    }

    func testSymbolAndTimeframeContractsAcceptOnlyConfiguredUniverse() throws {
        let symbol = try Symbol(rawValue: "btcusdt")
        let oneMinute = try Timeframe(contractValue: "1m")
        let fiveMinutes = try Timeframe(contractValue: "5m")

        XCTAssertEqual(symbol.rawValue, "BTCUSDT")
        XCTAssertEqual(oneMinute, .oneMinute)
        XCTAssertEqual(fiveMinutes, .fiveMinutes)

        XCTAssertThrowsError(try Symbol(rawValue: "DOGEUSDT")) { error in
            XCTAssertEqual(error as? CoreError, .unsupportedSymbol("DOGEUSDT"))
        }
        XCTAssertThrowsError(try Timeframe(contractValue: "1h")) { error in
            XCTAssertEqual(error as? CoreError, .unsupportedTimeframe("1h"))
        }
    }

    func testPriceAndQuantityContractsRejectInvalidNumericValues() throws {
        let price = try Price(100)
        let quantity = try Quantity(0)

        XCTAssertEqual(price.rawValue, 100)
        XCTAssertEqual(quantity.rawValue, 0)

        XCTAssertThrowsError(try Price(-1, field: "bid")) { error in
            XCTAssertEqual(error as? CoreError, .invalidPrice("bid", -1))
        }
        XCTAssertThrowsError(try Quantity(-0.01, field: "volume")) { error in
            XCTAssertEqual(error as? CoreError, .invalidQuantity("volume", -0.01))
        }
    }

    func testDateAndSequenceRangesRejectInvalidBoundaries() throws {
        let start = Date(timeIntervalSince1970: 100)
        let end = Date(timeIntervalSince1970: 160)

        let validDateRange = try DateRange(start: start, end: end)
        let validSequenceRange = try EventSequenceRange(lowerBound: 1, upperBound: 3)

        XCTAssertEqual(validDateRange.start, start)
        XCTAssertEqual(validDateRange.end, end)
        XCTAssertTrue(validSequenceRange.contains(2))
        XCTAssertFalse(validSequenceRange.contains(4))

        XCTAssertThrowsError(try DateRange(start: end, end: start)) { error in
            XCTAssertEqual(error as? CoreError, .invalidDateRange)
        }
        XCTAssertThrowsError(try EventSequenceRange(lowerBound: 0, upperBound: 1)) { error in
            XCTAssertEqual(error as? CoreError, .invalidSequenceRange)
        }
        XCTAssertThrowsError(try EventSequenceRange(lowerBound: 4, upperBound: 3)) { error in
            XCTAssertEqual(error as? CoreError, .invalidSequenceRange)
        }
    }

    func testEventEnvelopeWrapsMarketEventsAndRoundTripsThroughCodable() throws {
        let bar = try makeMarketBar()
        let event = DomainEvent.market(.bar(bar))
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
            try decoder.decode(Symbol.self, from: Data(#""DOGEUSDT""#.utf8))
        )
        XCTAssertThrowsError(
            try decoder.decode(DateRange.self, from: Data(#"{"start":160,"end":100}"#.utf8))
        )
        XCTAssertThrowsError(
            try decoder.decode(EventSequenceRange.self, from: Data(#"{"lowerBound":0,"upperBound":1}"#.utf8))
        )
        XCTAssertThrowsError(
            try decoder.decode(
                PaperSessionCommand.self,
                from: Data(
                    #"""
                    {
                      "sessionID": "paper-fixture",
                      "strategy": {
                        "strategyID": "ema-cross",
                        "symbol": "BTCUSDT",
                        "timeframe": "1m",
                        "shortPeriod": 2,
                        "longPeriod": 3
                      },
                      "marketData": {
                        "symbol": "BTCUSDT",
                        "timeframe": "1m",
                        "range": { "start": 100, "end": 500 }
                      },
                      "riskProfileID": "paper-risk",
                      "executionMode": "backtest"
                    }
                    """#.utf8
                )
            )
        )
    }

    func testAppendOnlyEventLogAssignsMonotonicSequencesAndReplaysRanges() throws {
        let marketEvent = DomainEvent.market(.bar(try makeMarketBar()))
        let backtestEvent = DomainEvent.backtest(
            .requested(try makeBacktestCommand())
        )
        let portfolioEvent = DomainEvent.portfolio(
            .projectionRequested(
                PortfolioQuery(
                    portfolioID: try Identifier("portfolio-main"),
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
        let marketDataQuery = try makeEMAMarketDataQuery()
        let backtestCommand = BacktestCommand(
            runID: try Identifier("backtest-ema-fixture"),
            strategy: try makeEMAStrategy(),
            marketData: marketDataQuery
        )
        let paperCommand = try PaperSessionCommand(
            sessionID: try Identifier("paper-ema-fixture"),
            strategy: try makeEMAStrategy(),
            marketData: marketDataQuery,
            riskProfileID: try Identifier("paper-risk"),
            executionMode: try ExecutionMode(contractValue: "paper")
        )

        XCTAssertEqual(Command.runBacktest(backtestCommand), .runBacktest(backtestCommand))
        XCTAssertEqual(Command.startPaperSession(paperCommand), .startPaperSession(paperCommand))
        XCTAssertEqual(Query.marketData(marketDataQuery), .marketData(marketDataQuery))

        XCTAssertThrowsError(try ExecutionMode(contractValue: "live")) { error in
            XCTAssertEqual(error as? CoreError, .liveExecutionForbidden("live"))
        }
        XCTAssertThrowsError(
            try PaperSessionCommand(
                sessionID: try Identifier("paper-ema-fixture"),
                strategy: try makeEMAStrategy(),
                marketData: marketDataQuery,
                riskProfileID: try Identifier("paper-risk"),
                executionMode: .backtest
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperSessionRequiresPaperMode)
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
            XCTAssertEqual(error as? CoreError, .invalidSequenceRange)
        }
    }

    func testMessageBusPublishesMonotonicSequencesAndReplaysSelectedStreams() throws {
        var messageBus = try MessageBus()
        let marketEvent = DomainEvent.market(.bar(try makeMarketBar()))
        let signalEvent = DomainEvent.strategySignal(
            StrategySignalEvent(
                strategyID: try Identifier("ema-cross"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
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
        var messageBus = try MessageBus()
        var cache = MarketDataCache()
        let dataEngine = DataEngine()
        let bar = try makeMarketBar()

        let envelope = try dataEngine.ingest(
            .bar(bar),
            cache: &cache,
            messageBus: &messageBus,
            recordedAt: Date(timeIntervalSince1970: 230)
        )

        let key = MarketDataSeriesKey(symbol: bar.symbol, timeframe: bar.timeframe)
        XCTAssertEqual(envelope.sequence, 1)
        XCTAssertEqual(envelope.stream, .market)
        XCTAssertEqual(envelope.event, .market(.bar(bar)))
        XCTAssertEqual(messageBus.envelopes, [envelope])
        XCTAssertEqual(cache.snapshot.barsBySeries[key], [bar])
        XCTAssertEqual(cache.snapshot.marketEventCount, 1)
    }

    func testCacheProjectionIsDeterministicFromMessageBusReplay() throws {
        var messageBus = try MessageBus()
        var cache = MarketDataCache()
        let dataEngine = DataEngine()
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
        let projectedSnapshot = MarketDataCache.project(replay.envelopes)

        XCTAssertEqual(projectedSnapshot, cache.snapshot)
        XCTAssertEqual(projectedSnapshot.marketEventCount, 3)
        XCTAssertEqual(projectedSnapshot.tradesBySymbol[trade.symbol], [trade])
        XCTAssertEqual(projectedSnapshot.bestBidAskBySymbol[bestBidAsk.symbol], bestBidAsk)
    }

    func testTradingKernelActorSerializesConcurrentMarketIngestion() async throws {
        let kernel = try TradingKernel()
        let marketEvents: [MarketEvent] = [
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
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let key = MarketDataSeriesKey(
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
        let kernel = try TradingKernel()
        let firstBar = try makeMarketBar(close: 101, start: 600)
        let secondBar = try makeMarketBar(close: 102, start: 660)

        try await kernel.ingestMarketEvent(.bar(firstBar), recordedAt: Date(timeIntervalSince1970: 601))
        try await kernel.ingestMarketEvent(.bar(secondBar), recordedAt: Date(timeIntervalSince1970: 661))

        let replayCommand = EventReplayCommand(
            range: try EventSequenceRange(lowerBound: 2, upperBound: 2),
            streams: [.market]
        )
        let rebuiltSnapshot = await kernel.rebuildCache(from: replayCommand)
        let key = MarketDataSeriesKey(symbol: firstBar.symbol, timeframe: firstBar.timeframe)

        XCTAssertEqual(rebuiltSnapshot.barsBySeries[key], [secondBar])
        XCTAssertEqual(rebuiltSnapshot.marketEventCount, 1)
    }

    func testEMACrossStrategyContractGeneratesDeterministicSignalFixture() throws {
        let strategy = EMACrossStrategyContract(configuration: try makeEMAStrategy())
        let samples = try strategy.evaluate(try makeEMAFixtureBars())

        XCTAssertEqual(samples.map(\.signal.direction), [.long, .long, .flat, .long])
        XCTAssertEqual(samples.map(\.signal.generatedAt.timeIntervalSince1970), [280, 340, 400, 460])
        XCTAssertEqual(samples.map(\.signal.timeframe), [.oneMinute, .oneMinute, .oneMinute, .oneMinute])
        XCTAssertEqual(samples[0].shortEMA.rawValue, 11.5555555556, accuracy: 0.0001)
        XCTAssertEqual(samples[0].longEMA.rawValue, 11.25, accuracy: 0.0001)
        XCTAssertEqual(samples[2].shortEMA.rawValue, 10.3950617284, accuracy: 0.0001)
        XCTAssertEqual(samples[2].longEMA.rawValue, 10.5625, accuracy: 0.0001)
    }

    func testEMACrossStrategyRejectsInvalidConfigurationAndMismatchedMarketData() throws {
        XCTAssertThrowsError(
            try EMACrossStrategyConfiguration(
                strategyID: try Identifier("ema-cross"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                shortPeriod: 3,
                longPeriod: 3
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .invalidEMAPeriodOrder(shortPeriod: 3, longPeriod: 3)
            )
        }

        let strategy = EMACrossStrategyContract(configuration: try makeEMAStrategy())

        XCTAssertThrowsError(try strategy.evaluate(Array(try makeEMAFixtureBars().prefix(2)))) { error in
            XCTAssertEqual(error as? CoreError, .insufficientMarketData(required: 3, actual: 2))
        }

        let mismatchedBar = try MarketBar(
            symbol: try Symbol(rawValue: "ETHUSDT"),
            timeframe: .oneMinute,
            interval: try DateRange(
                start: Date(timeIntervalSince1970: 100),
                end: Date(timeIntervalSince1970: 160)
            ),
            open: 10,
            high: 12,
            low: 9,
            close: 11,
            volume: 1
        )

        XCTAssertThrowsError(try strategy.evaluate([mismatchedBar, mismatchedBar, mismatchedBar])) { error in
            XCTAssertEqual(
                error as? CoreError,
                .marketDataMismatch(field: "symbol", expected: "BTCUSDT", actual: "ETHUSDT")
            )
        }

        let mismatchedMarketData = MarketDataQuery(
            symbol: try Symbol(rawValue: "ETHUSDT"),
            timeframe: .oneMinute,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 100),
                end: Date(timeIntervalSince1970: 400)
            )
        )

        XCTAssertThrowsError(
            try BacktestEventFlow().run(
                BacktestCommand(
                    runID: try Identifier("backtest-ema-fixture"),
                    strategy: try makeEMAStrategy(),
                    marketData: mismatchedMarketData
                ),
                bars: try makeEMAFixtureBars()
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .marketDataMismatch(field: "marketData.symbol", expected: "BTCUSDT", actual: "ETHUSDT")
            )
        }
    }

    func testBacktestAndPaperEventFlowsShareSignalTimelineForParity() throws {
        let marketDataQuery = try makeEMAMarketDataQuery()
        let strategy = try makeEMAStrategy()
        let bars = try makeEMAFixtureBars()
        let backtestCommand = BacktestCommand(
            runID: try Identifier("backtest-ema-fixture"),
            strategy: strategy,
            marketData: marketDataQuery
        )
        let paperCommand = try PaperSessionCommand(
            sessionID: try Identifier("paper-ema-fixture"),
            strategy: strategy,
            marketData: marketDataQuery,
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )

        let backtestRun = try BacktestEventFlow().run(
            backtestCommand,
            bars: bars,
            completedAt: Date(timeIntervalSince1970: 500)
        )
        let paperRun = try PaperSessionEventFlow().start(
            paperCommand,
            bars: bars,
            completedAt: Date(timeIntervalSince1970: 501)
        )
        let parity = BacktestPaperParity.verify(
            backtest: backtestRun.result,
            paper: paperRun.result
        )

        XCTAssertEqual(backtestRun.events.count, 6)
        XCTAssertEqual(paperRun.events.count, 6)
        XCTAssertEqual(backtestRun.result.signalSamples.map(\.signal.direction), [.long, .long, .flat, .long])
        XCTAssertEqual(paperRun.result.signalSamples, backtestRun.result.signalSamples)
        XCTAssertTrue(parity.sameStrategy)
        XCTAssertTrue(parity.sameMarketData)
        XCTAssertTrue(parity.matchingSignalTimeline)
        XCTAssertTrue(parity.isConsistent)
    }

    func testBacktestAndPaperEventFlowsCanPublishThroughMessageBusStreams() throws {
        var messageBus = try MessageBus()
        let bars = try makeEMAFixtureBars()
        let marketDataQuery = try makeEMAMarketDataQuery()
        let strategy = try makeEMAStrategy()
        let backtestRun = try BacktestEventFlow().run(
            BacktestCommand(
                runID: try Identifier("backtest-ema-fixture"),
                strategy: strategy,
                marketData: marketDataQuery
            ),
            bars: bars,
            completedAt: Date(timeIntervalSince1970: 500)
        )
        let paperRun = try PaperSessionEventFlow().start(
            PaperSessionCommand(
                sessionID: try Identifier("paper-ema-fixture"),
                strategy: strategy,
                marketData: marketDataQuery,
                riskProfileID: try Identifier("paper-risk"),
                executionMode: .paper
            ),
            bars: bars,
            completedAt: Date(timeIntervalSince1970: 501)
        )

        for event in backtestRun.events {
            try messageBus.publish(.backtest(event), stream: .backtest)
        }
        for event in paperRun.events {
            try messageBus.publish(.paper(event), stream: .paper)
        }

        XCTAssertEqual(messageBus.envelopes.map(\.sequence), Array(1...12))
        XCTAssertEqual(
            messageBus.replay(
                EventReplayCommand(
                    range: try EventSequenceRange(lowerBound: 1, upperBound: 12),
                    streams: [.backtest]
                )
            ).envelopes.count,
            6
        )
        XCTAssertEqual(
            messageBus.replay(
                EventReplayCommand(
                    range: try EventSequenceRange(lowerBound: 1, upperBound: 12),
                    streams: [.paper]
                )
            ).envelopes.count,
            6
        )
    }

    func testOrderBookReadModelAppliesSnapshotAndDeltasDeterministically() throws {
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let snapshot = OrderBookSnapshot(
            symbol: symbol,
            observedAt: Date(timeIntervalSince1970: 1_000),
            bids: [
                try makeOrderBookLevel(price: 100, quantity: 2),
                try makeOrderBookLevel(price: 99, quantity: 1)
            ],
            asks: [
                try makeOrderBookLevel(price: 101, quantity: 1),
                try makeOrderBookLevel(price: 102, quantity: 1)
            ]
        )
        let input = OrderBookReadModelInput(snapshot: snapshot)
        let delta = OrderBookDelta(
            symbol: symbol,
            observedAt: Date(timeIntervalSince1970: 1_010),
            bidUpdates: [
                try makeOrderBookLevel(price: 99, quantity: 0),
                try makeOrderBookLevel(price: 100.5, quantity: 1.5)
            ],
            askUpdates: [
                try makeOrderBookLevel(price: 101, quantity: 0.5),
                try makeOrderBookLevel(price: 103, quantity: 2)
            ]
        )

        let updated = try input.applying(delta)

        XCTAssertEqual(input.source, .snapshot)
        XCTAssertEqual(input.bids.map(\.price.rawValue), [100, 99])
        XCTAssertEqual(input.asks.map(\.price.rawValue), [101, 102])
        XCTAssertEqual(updated.source, .deltaApplied)
        XCTAssertEqual(updated.observedAt.timeIntervalSince1970, 1_010)
        XCTAssertEqual(updated.bids.map(\.price.rawValue), [100.5, 100])
        XCTAssertEqual(updated.asks.map(\.price.rawValue), [101, 102, 103])
        XCTAssertEqual(updated.asks[0].quantity.rawValue, 0.5)

        XCTAssertThrowsError(
            try input.applying(
                OrderBookDelta(
                    symbol: try Symbol(rawValue: "ETHUSDT"),
                    observedAt: Date(timeIntervalSince1970: 1_011),
                    bidUpdates: [],
                    askUpdates: []
                )
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .marketDataMismatch(field: "orderBookDelta.symbol", expected: "BTCUSDT", actual: "ETHUSDT")
            )
        }
    }

    func testOrderBookImbalanceStrategyGeneratesStableSignalFixture() throws {
        let contract = OrderBookImbalanceStrategyContract(
            configuration: try makeOrderBookImbalanceStrategy()
        )

        let samples = try contract.evaluate(try makeOrderBookImbalanceInputs())

        XCTAssertEqual(samples.map(\.bias), [.bidDominant, .neutral, .askDominant])
        XCTAssertEqual(samples.map(\.signal.direction), [.long, .flat, .flat])
        XCTAssertEqual(samples.map(\.signal.generatedAt.timeIntervalSince1970), [1_000, 1_060, 1_120])
        XCTAssertEqual(samples.map(\.signal.timeframe), [.oneMinute, .oneMinute, .oneMinute])
        XCTAssertEqual(samples[0].bidNotional, 299, accuracy: 0.0001)
        XCTAssertEqual(samples[0].askNotional, 203, accuracy: 0.0001)
        XCTAssertEqual(samples[0].imbalanceRatio, 0.1912350598, accuracy: 0.0001)
        XCTAssertEqual(samples[1].imbalanceRatio, 0, accuracy: 0.0001)
        XCTAssertEqual(samples[2].imbalanceRatio, -0.2088353414, accuracy: 0.0001)
    }

    func testOrderBookImbalanceRejectsInvalidConfigurationAndInputs() throws {
        XCTAssertThrowsError(
            try OrderBookImbalanceStrategyConfiguration(
                strategyID: try Identifier("obi-fixture"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                depth: 0,
                signalThreshold: 0.15
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .invalidOrderBookDepth("depth", 0))
        }

        XCTAssertThrowsError(
            try OrderBookImbalanceStrategyConfiguration(
                strategyID: try Identifier("obi-fixture"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                depth: 2,
                signalThreshold: 1.1
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .invalidImbalanceThreshold(1.1))
        }

        let contract = OrderBookImbalanceStrategyContract(
            configuration: try makeOrderBookImbalanceStrategy()
        )
        let mismatchedInput = OrderBookReadModelInput(
            symbol: try Symbol(rawValue: "ETHUSDT"),
            observedAt: Date(timeIntervalSince1970: 1_000),
            bids: [try makeOrderBookLevel(price: 100, quantity: 1), try makeOrderBookLevel(price: 99, quantity: 1)],
            asks: [try makeOrderBookLevel(price: 101, quantity: 1), try makeOrderBookLevel(price: 102, quantity: 1)],
            source: .snapshot
        )
        let thinInput = OrderBookReadModelInput(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 1_000),
            bids: [try makeOrderBookLevel(price: 100, quantity: 1)],
            asks: [],
            source: .snapshot
        )

        XCTAssertThrowsError(try contract.evaluate([mismatchedInput])) { error in
            XCTAssertEqual(
                error as? CoreError,
                .marketDataMismatch(field: "orderBook.symbol", expected: "BTCUSDT", actual: "ETHUSDT")
            )
        }
        XCTAssertThrowsError(try contract.evaluate([thinInput])) { error in
            XCTAssertEqual(
                error as? CoreError,
                .insufficientOrderBookDepth(required: 2, bidLevels: 1, askLevels: 0)
            )
        }
    }

    func testOrderBookImbalanceResearchFlowPublishesThroughStrategyStream() throws {
        var messageBus = try MessageBus()
        let strategy = try makeOrderBookImbalanceStrategy()
        let command = OrderBookImbalanceResearchCommand(
            researchID: try Identifier("obi-research-fixture"),
            strategy: strategy,
            marketData: try makeOrderBookMarketDataQuery()
        )
        let run = try OrderBookImbalanceResearchEventFlow().run(
            command,
            inputs: try makeOrderBookImbalanceInputs(),
            completedAt: Date(timeIntervalSince1970: 1_300)
        )

        for event in run.events {
            try messageBus.publish(.orderBookImbalanceResearch(event), stream: .strategy)
        }

        XCTAssertEqual(Command.runOrderBookImbalanceResearch(command), .runOrderBookImbalanceResearch(command))
        XCTAssertEqual(run.events.count, 5)
        XCTAssertEqual(run.result.signalSamples.map(\.bias), [.bidDominant, .neutral, .askDominant])
        XCTAssertEqual(messageBus.envelopes.map(\.sequence), Array(1...5))
        XCTAssertEqual(
            messageBus.replay(
                EventReplayCommand(
                    range: try EventSequenceRange(lowerBound: 1, upperBound: 5),
                    streams: [.strategy]
                )
            ).envelopes.count,
            5
        )

        let mismatchedMarketData = MarketDataQuery(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .fiveMinutes,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 1_000),
                end: Date(timeIntervalSince1970: 1_200)
            )
        )
        let mismatchedCommand = OrderBookImbalanceResearchCommand(
            researchID: try Identifier("obi-mismatch"),
            strategy: strategy,
            marketData: mismatchedMarketData
        )

        XCTAssertThrowsError(
            try OrderBookImbalanceResearchEventFlow().run(
                mismatchedCommand,
                inputs: try makeOrderBookImbalanceInputs()
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .marketDataMismatch(field: "marketData.timeframe", expected: "1m", actual: "5m")
            )
        }
    }

    private func makeMarketBar(close: Double = 105, start: TimeInterval = 100) throws -> MarketBar {
        try MarketBar(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            interval: try DateRange(
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
    ) throws -> TradeTick {
        try TradeTick(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            tradedAt: Date(timeIntervalSince1970: tradedAt),
            price: price,
            quantity: quantity,
            makerSide: .bid
        )
    }

    private func makeBestBidAsk() throws -> BestBidAsk {
        try BestBidAsk(
            symbol: Symbol(rawValue: "BTCUSDT"),
            observedAt: Date(timeIntervalSince1970: 320),
            bid: OrderBookLevel(price: 41999, quantity: 1.25),
            ask: OrderBookLevel(price: 42001, quantity: 0.75)
        )
    }

    private func makeBacktestCommand() throws -> BacktestCommand {
        BacktestCommand(
            runID: try Identifier("backtest-ema-fixture"),
            strategy: try makeEMAStrategy(),
            marketData: try makeEMAMarketDataQuery()
        )
    }

    private func makeEMAStrategy() throws -> EMACrossStrategyConfiguration {
        try EMACrossStrategyConfiguration(
            strategyID: try Identifier("ema-cross"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            shortPeriod: 2,
            longPeriod: 3
        )
    }

    private func makeEMAMarketDataQuery() throws -> MarketDataQuery {
        MarketDataQuery(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 100),
                end: Date(timeIntervalSince1970: 400)
            )
        )
    }

    private func makeEMAFixtureBars() throws -> [MarketBar] {
        try [10.0, 11.0, 12.0, 11.0, 10.0, 13.0].enumerated().map { index, close in
            let start = 100 + TimeInterval(index * 60)
            return try MarketBar(
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                interval: try DateRange(
                    start: Date(timeIntervalSince1970: start),
                    end: Date(timeIntervalSince1970: start + 60)
                ),
                open: close,
                high: close + 1,
                low: close - 1,
                close: close,
                volume: 1
            )
        }
    }

    private func makeOrderBookLevel(price: Double, quantity: Double) throws -> OrderBookLevel {
        try OrderBookLevel(price: price, quantity: quantity)
    }

    private func makeOrderBookImbalanceStrategy() throws -> OrderBookImbalanceStrategyConfiguration {
        try OrderBookImbalanceStrategyConfiguration(
            strategyID: try Identifier("obi-fixture"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            depth: 2,
            signalThreshold: 0.15
        )
    }

    private func makeOrderBookMarketDataQuery() throws -> MarketDataQuery {
        MarketDataQuery(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 1_000),
                end: Date(timeIntervalSince1970: 1_200)
            )
        )
    }

    private func makeOrderBookImbalanceInputs() throws -> [OrderBookReadModelInput] {
        let symbol = try Symbol(rawValue: "BTCUSDT")
        let bidDominant = OrderBookReadModelInput(
            symbol: symbol,
            observedAt: Date(timeIntervalSince1970: 1_000),
            bids: [
                try makeOrderBookLevel(price: 100, quantity: 2),
                try makeOrderBookLevel(price: 99, quantity: 1)
            ],
            asks: [
                try makeOrderBookLevel(price: 101, quantity: 1),
                try makeOrderBookLevel(price: 102, quantity: 1)
            ],
            source: .snapshot
        )
        let neutral = OrderBookReadModelInput(
            symbol: symbol,
            observedAt: Date(timeIntervalSince1970: 1_060),
            bids: [
                try makeOrderBookLevel(price: 100, quantity: 1),
                try makeOrderBookLevel(price: 99, quantity: 1)
            ],
            asks: [
                try makeOrderBookLevel(price: 100, quantity: 1),
                try makeOrderBookLevel(price: 99, quantity: 1)
            ],
            source: .snapshot
        )
        let askDominant = OrderBookReadModelInput(
            symbol: symbol,
            observedAt: Date(timeIntervalSince1970: 1_120),
            bids: [
                try makeOrderBookLevel(price: 99, quantity: 1),
                try makeOrderBookLevel(price: 98, quantity: 1)
            ],
            asks: [
                try makeOrderBookLevel(price: 100, quantity: 2),
                try makeOrderBookLevel(price: 101, quantity: 1)
            ],
            source: .snapshot
        )

        return [askDominant, bidDominant, neutral]
    }
}
