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

    func testCodableDecodingCannotBypassCoreContractValidation() throws {
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

        let paperLifecycleCommand = try PaperSessionCommand(
            sessionID: try Identifier("paper-lifecycle-fixture"),
            strategy: try makeEMAStrategy(),
            marketData: try makeEMAMarketDataQuery(),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        let paperLifecycleUpdate = try PaperSessionUpdated(
            command: paperLifecycleCommand,
            signalCount: 0,
            updatedAt: Date(timeIntervalSince1970: 700)
        )
        let validLifecycleData = try JSONEncoder().encode(paperLifecycleUpdate)
        var invalidLifecycleObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: validLifecycleData) as? [String: Any]
        )
        invalidLifecycleObject["signalCount"] = -1
        let invalidLifecycleData = try JSONSerialization.data(withJSONObject: invalidLifecycleObject)

        XCTAssertThrowsError(
            try decoder.decode(PaperSessionUpdated.self, from: invalidLifecycleData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .invalidPaperSessionSignalCount(-1))
        }
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

    func testRiskBlockerEvidenceAndPortfolioExposureRemainPaperOnlyReadModels() throws {
        // 测试场景：MTP-28 risk blocker evidence 必须锁定 proposed Paper action context、
        // risk profile 和 blocker reason；portfolio exposure 只能是 Paper 投影派生的只读 notional。
        let riskQuery = try RiskEvaluationQuery(
            paperOrderID: try Identifier("paper-order-rejected"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            proposedQuantity: try Quantity(1.25),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        let evidence = RiskBlockerEvidence(
            evidenceID: try Identifier("risk-blocker-fixture"),
            query: riskQuery,
            reason: .maxPaperQuantityExceeded,
            generatedAt: Date(timeIntervalSince1970: 1_401)
        )
        let exposure = PortfolioExposureSnapshot(
            portfolioID: try Identifier("portfolio-main"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            paperQuantity: try Quantity(1.25),
            referencePrice: try Price(42_000),
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 1_500)
        )

        XCTAssertEqual(Query.riskEvaluation(riskQuery), .riskEvaluation(riskQuery))
        XCTAssertEqual(evidence.paperOrderID, riskQuery.paperOrderID)
        XCTAssertEqual(evidence.riskProfileID, try Identifier("paper-risk"))
        XCTAssertEqual(evidence.executionMode, .paper)
        XCTAssertEqual(evidence.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(exposure.source, .paperProjection)
        XCTAssertEqual(exposure.grossExposureNotional, 52_500, accuracy: 0.00000001)
        XCTAssertEqual(
            DomainEvent.risk(.blocked(evidence)),
            .risk(.blocked(evidence))
        )
        XCTAssertEqual(
            DomainEvent.portfolio(.exposureUpdated(exposure)),
            .portfolio(.exposureUpdated(exposure))
        )

        XCTAssertThrowsError(
            try RiskEvaluationQuery(
                paperOrderID: try Identifier("backtest-order"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                proposedQuantity: try Quantity(1),
                riskProfileID: try Identifier("paper-risk"),
                executionMode: .backtest
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .riskEvaluationRequiresPaperMode(.backtest))
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
        XCTAssertEqual(paperRun.events.count, 7)
        XCTAssertEqual(backtestRun.result.signalSamples.map(\.signal.direction), [.long, .long, .flat, .long])
        XCTAssertEqual(paperRun.result.signalSamples, backtestRun.result.signalSamples)
        XCTAssertTrue(parity.sameStrategy)
        XCTAssertTrue(parity.sameMarketData)
        XCTAssertTrue(parity.matchingSignalTimeline)
        XCTAssertTrue(parity.isConsistent)
    }

    func testPaperSessionLifecycleEmitsStartedUpdatedClosedFactsDeterministically() throws {
        // 测试场景：MTP-31 Paper session lifecycle 必须输出 started / updated / closed
        // 三类确定性本地事实，并继续保持 signal timeline 与真实交易能力隔离。
        let marketDataQuery = try makeEMAMarketDataQuery()
        let strategy = try makeEMAStrategy()
        let command = try PaperSessionCommand(
            sessionID: try Identifier("paper-lifecycle-fixture"),
            strategy: strategy,
            marketData: marketDataQuery,
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        let startedAt = Date(timeIntervalSince1970: 600)
        let updatedAt = Date(timeIntervalSince1970: 700)
        let closedAt = Date(timeIntervalSince1970: 800)

        let run = try PaperSessionEventFlow().start(
            command,
            bars: try makeEMAFixtureBars(),
            startedAt: startedAt,
            updatedAt: updatedAt,
            completedAt: closedAt
        )

        XCTAssertEqual(run.events.count, 7)
        XCTAssertEqual(run.events.filter { event in
            if case .signalGenerated = event {
                return true
            }
            return false
        }.count, 4)

        guard case let .sessionStarted(started) = run.events[0] else {
            return XCTFail("first paper lifecycle event must be sessionStarted")
        }
        guard case let .sessionUpdated(updated) = run.events[5] else {
            return XCTFail("updated lifecycle event must follow signal timeline")
        }
        guard case let .sessionClosed(closed) = run.events[6] else {
            return XCTFail("last paper lifecycle event must be sessionClosed")
        }

        XCTAssertEqual(started.sessionID, command.sessionID)
        XCTAssertEqual(started.state, .started)
        XCTAssertEqual(started.startedAt, startedAt)
        XCTAssertEqual(updated.sessionID, command.sessionID)
        XCTAssertEqual(updated.state, .updated)
        XCTAssertEqual(updated.signalCount, 4)
        XCTAssertEqual(updated.updatedAt, updatedAt)
        XCTAssertEqual(closed.sessionID, command.sessionID)
        XCTAssertEqual(closed.state, .closed)
        XCTAssertEqual(closed.signalCount, 4)
        XCTAssertEqual(closed.closedAt, closedAt)
        XCTAssertEqual(run.result.completedAt, closedAt)
    }

    func testPaperSessionEventLogBoundaryWritesOnlyPaperStreamFacts() throws {
        // 测试场景：MTP-31 event log 写入边界只接受 PaperEvent，并固定写入 `.paper` stream；
        // replay 证据必须可按 stream 确定性过滤，不能混入 risk、portfolio、broker 或 signed endpoint 事实。
        var eventLog = try AppendOnlyEventLog()
        let boundary = PaperSessionEventLogBoundary()
        let command = try PaperSessionCommand(
            sessionID: try Identifier("paper-event-log-boundary"),
            strategy: try makeEMAStrategy(),
            marketData: try makeEMAMarketDataQuery(),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        let run = try PaperSessionEventFlow().start(
            command,
            bars: try makeEMAFixtureBars(),
            startedAt: Date(timeIntervalSince1970: 600),
            updatedAt: Date(timeIntervalSince1970: 700),
            completedAt: Date(timeIntervalSince1970: 800)
        )

        for (index, event) in run.events.enumerated() {
            try boundary.append(
                event,
                to: &eventLog,
                recordedAt: Date(timeIntervalSince1970: 900 + TimeInterval(index))
            )
        }

        XCTAssertEqual(eventLog.envelopes.map(\.sequence), Array(1...run.events.count))
        XCTAssertEqual(eventLog.envelopes.map(\.stream), Array(repeating: EventStreamID.paper, count: run.events.count))
        XCTAssertEqual(eventLog.envelopes.map(\.recordedAt.timeIntervalSince1970), [900, 901, 902, 903, 904, 905, 906])
        XCTAssertTrue(eventLog.envelopes.allSatisfy { envelope in
            if case .paper = envelope.event {
                return true
            }
            return false
        })
        XCTAssertEqual(
            eventLog.replay(
                EventReplayCommand(
                    range: try EventSequenceRange(lowerBound: 1, upperBound: run.events.count),
                    streams: [.paper]
                )
            ).envelopes.count,
            run.events.count
        )
        XCTAssertTrue(
            eventLog.replay(
                EventReplayCommand(
                    range: try EventSequenceRange(lowerBound: 1, upperBound: run.events.count),
                    streams: [.risk]
                )
            ).envelopes.isEmpty
        )
    }

    func testPaperSessionReplayEvidenceSummarizesRuntimeEventsDeterministically() throws {
        // 测试场景：MTP-35 replay evidence 必须从 append-only replay result 汇总
        // session lifecycle、proposal、risk blocker 和 portfolio projection event，且不恢复真实交易能力。
        let replay = try PaperSessionReplayFixture.deterministicReplayResult()
        let summary = try PaperSessionReplayPath.summarize(replay)

        XCTAssertEqual(summary.factsSource, "append-only event log replay")
        XCTAssertEqual(summary.replayedSequences, Array(1...13))
        XCTAssertEqual(summary.replayedStreams, [.paper, .portfolio, .risk])
        XCTAssertEqual(summary.firstSequence, 1)
        XCTAssertEqual(summary.lastSequence, 13)
        XCTAssertEqual(summary.sessionIDs, [try Identifier("paper-replay-session")])
        XCTAssertEqual(summary.lifecycleStates, [.started, .updated, .closed])
        XCTAssertEqual(summary.signalEventCount, 4)
        XCTAssertEqual(
            summary.proposalIDs,
            [
                try Identifier("paper-replay-proposal"),
                try Identifier("paper-replay-proposal-blocked")
            ]
        )
        XCTAssertEqual(summary.riskEvaluationRequestedCount, 2)
        XCTAssertEqual(
            summary.riskBlockerEvidenceIDs,
            [try Identifier("risk-blocker-paper-replay-proposal-blocked")]
        )
        XCTAssertEqual(summary.rejectedPaperOrderIDs, [try Identifier("paper-replay-proposal-blocked")])
        XCTAssertEqual(summary.portfolioUpdateIDs, [try Identifier("paper-replay-portfolio-update")])
        XCTAssertEqual(summary.portfolioIDs, [try Identifier("portfolio-main")])
        XCTAssertTrue(summary.coversSessionEvents)
        XCTAssertTrue(summary.coversProposalEvents)
        XCTAssertTrue(summary.coversRiskBlockerEvents)
        XCTAssertTrue(summary.coversPortfolioProjectionEvents)
        XCTAssertTrue(summary.appendOnlyFactsSourceIsReplaySource)
        XCTAssertTrue(summary.replayResultIsDeterministic)
        XCTAssertTrue(summary.paperOnlyBoundaryHeld)
        XCTAssertFalse(summary.authorizesLiveTrading)
        XCTAssertFalse(summary.touchesBrokerAction)

        let encoded = try JSONEncoder().encode(summary)
        let decoded = try JSONDecoder().decode(PaperSessionReplayEvidenceSummary.self, from: encoded)
        XCTAssertEqual(decoded, summary)
    }

    func testPaperSessionReplayEvidenceRejectsOutOfOrderReplayResult() throws {
        // 测试场景：replay summary 必须拒绝乱序 envelope，避免把非 append-only 顺序的输入
        // 误标记为 deterministic evidence。
        let replay = try PaperSessionReplayFixture.deterministicReplayResult()
        let outOfOrderReplay = EventReplayResult(
            command: replay.command,
            envelopes: replay.envelopes.reversed()
        )

        XCTAssertThrowsError(try PaperSessionReplayPath.summarize(outOfOrderReplay)) { error in
            XCTAssertEqual(error as? CoreError, .invalidSequenceRange)
        }
    }

    func testPaperActionProposalMapsStrategySignalToPaperOnlyIntentDeterministically() throws {
        // 测试场景：MTP-32 proposal fixture 必须把 strategy signal 确定性映射为
        // paper-only action intent，并复用 MTP-27 fixed cost evidence，不生成真实订单能力。
        let longProposal = try PaperActionProposalFixture.deterministicLong()
        let flatProposal = try PaperActionProposalFixture.deterministicFlat()

        XCTAssertEqual(longProposal.proposalID, try Identifier("paper-action-proposal-long"))
        XCTAssertEqual(longProposal.sessionID, try Identifier("paper-session-fixture"))
        XCTAssertEqual(longProposal.signal.strategyID, try Identifier("ema-cross"))
        XCTAssertEqual(longProposal.symbol, try Symbol(rawValue: "BTCUSDT"))
        XCTAssertEqual(longProposal.timeframe, .oneMinute)
        XCTAssertEqual(longProposal.side, .buy)
        XCTAssertEqual(longProposal.sizingAssumptionID, try Identifier("mtp-32-paper-action-sizing"))
        XCTAssertEqual(longProposal.quantity.rawValue, 0.5, accuracy: 0.00000001)
        XCTAssertEqual(longProposal.referencePrice.rawValue, 100, accuracy: 0.00000001)
        XCTAssertEqual(longProposal.notionalAmount, 50, accuracy: 0.00000001)
        XCTAssertEqual(longProposal.costEstimate.executionMode, .paper)
        XCTAssertEqual(longProposal.costEstimate.assumptionID, try Identifier("mtp-27-fixed-cost-assumptions"))
        XCTAssertEqual(longProposal.costEstimate.grossNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(longProposal.costEstimate.feeAmount, 0.01, accuracy: 0.00000001)
        XCTAssertEqual(longProposal.costEstimate.slippageAmount, 0.0075, accuracy: 0.00000001)
        XCTAssertEqual(longProposal.costEstimate.totalCostAmount, 0.0175, accuracy: 0.00000001)
        XCTAssertEqual(longProposal.executionMode, .paper)
        XCTAssertEqual(longProposal.executionAuthorization, .paperIntentOnly)
        XCTAssertFalse(longProposal.executionAuthorization.allowsRealOrder)
        XCTAssertFalse(longProposal.executionAuthorization.allowsBrokerAction)
        XCTAssertFalse(longProposal.isExecutableAsRealOrder)
        XCTAssertEqual(longProposal.proposedAt.timeIntervalSince1970, 1_620)

        XCTAssertEqual(flatProposal.side, .hold)
        XCTAssertEqual(flatProposal.quantity.rawValue, 0, accuracy: 0.00000001)
        XCTAssertEqual(flatProposal.notionalAmount, 0, accuracy: 0.00000001)
        XCTAssertEqual(flatProposal.costEstimate.totalCostAmount, 0, accuracy: 0.00000001)
        XCTAssertFalse(flatProposal.isExecutableAsRealOrder)

        let encoded = try JSONEncoder().encode(longProposal)
        let decoded = try JSONDecoder().decode(PaperActionProposal.self, from: encoded)
        XCTAssertEqual(decoded, longProposal)

        XCTAssertThrowsError(
            try PaperActionProposalSizingAssumption(
                assumptionID: try Identifier("invalid-zero-sizing"),
                quantity: try Quantity(0, field: "paperActionProposal.quantity"),
                referencePrice: try Price(100, field: "paperActionProposal.referencePrice"),
                liquidityRole: .maker
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .invalidPaperActionProposalQuantity(0))
        }
    }

    func testPaperActionProposalDecodingRejectsNonPaperOrMismatchedIntent() throws {
        // 测试场景：Codable 解码不能绕过 MTP-32 paper-only 不变量；
        // 非 paper mode 或与 strategy signal 不一致的 side 必须被拒绝。
        let proposal = try PaperActionProposalFixture.deterministicLong()
        let encoded = try JSONEncoder().encode(proposal)
        let decoder = JSONDecoder()

        var nonPaperObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        nonPaperObject["executionMode"] = "backtest"
        let nonPaperData = try JSONSerialization.data(withJSONObject: nonPaperObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperActionProposal.self, from: nonPaperData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperActionProposalRequiresPaperMode(.backtest))
        }

        var mismatchedSideObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        mismatchedSideObject["side"] = "hold"
        let mismatchedSideData = try JSONSerialization.data(withJSONObject: mismatchedSideObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperActionProposal.self, from: mismatchedSideData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperActionProposalSignalMismatch(field: "side", expected: "buy", actual: "hold")
            )
        }
    }

    func testPaperActionRiskLinkAllowsPaperProposalWithTraceableContext() throws {
        // 测试场景：MTP-33 允许路径必须把 strategy signal、paper proposal 和 risk query
        // 串成可追溯证据，同时证明 allowed 不等于真实订单授权或 broker fallback。
        let decision = try PaperActionProposalRiskFixture.deterministicAllowed()

        XCTAssertEqual(decision.decisionID, try Identifier("paper-action-risk-allowed"))
        XCTAssertEqual(decision.status, .allowed)
        XCTAssertTrue(decision.isAllowed)
        XCTAssertFalse(decision.isBlocked)
        XCTAssertNil(decision.blockerEvidence)
        XCTAssertEqual(decision.sourceSequence, 7)
        XCTAssertEqual(decision.evaluatedAt.timeIntervalSince1970, 1_800)
        XCTAssertEqual(decision.proposal.proposalID, try Identifier("paper-action-proposal-long"))
        XCTAssertEqual(decision.proposal.side, .buy)
        XCTAssertEqual(decision.riskQuery.paperOrderID, decision.proposal.proposalID)
        XCTAssertEqual(decision.riskQuery.symbol, decision.proposal.symbol)
        XCTAssertEqual(decision.riskQuery.timeframe, decision.proposal.timeframe)
        XCTAssertEqual(decision.riskQuery.proposedQuantity, decision.proposal.quantity)
        XCTAssertEqual(decision.riskQuery.riskProfileID, try Identifier("paper-risk"))
        XCTAssertEqual(decision.riskQuery.executionMode, .paper)
        XCTAssertEqual(decision.riskEvents, [.evaluationRequested(decision.riskQuery)])
        XCTAssertTrue(decision.paperOnlyContextIsConsistent)
        XCTAssertFalse(decision.liveExecutionFallbackAvailable)
        XCTAssertFalse(decision.brokerFallbackAvailable)
        XCTAssertFalse(decision.proposal.isExecutableAsRealOrder)

        let encoded = try JSONEncoder().encode(decision)
        let decoded = try JSONDecoder().decode(PaperActionProposalRiskDecision.self, from: encoded)
        XCTAssertEqual(decoded, decision)
    }

    func testPaperActionRiskLinkBlocksOversizedPaperProposalWithEvidence() throws {
        // 测试场景：MTP-33 阻断路径必须复用 RiskBlockerEvidence，固定 blocker reason、
        // source sequence 和 paper-only context，不引入真实风控或 broker 拒单回退。
        let decision = try PaperActionProposalRiskFixture.deterministicBlocked()
        let evidence = try XCTUnwrap(decision.blockerEvidence)

        XCTAssertEqual(decision.decisionID, try Identifier("paper-action-risk-blocked"))
        XCTAssertEqual(decision.status, .blocked)
        XCTAssertFalse(decision.isAllowed)
        XCTAssertTrue(decision.isBlocked)
        XCTAssertEqual(decision.sourceSequence, 8)
        XCTAssertEqual(decision.evaluatedAt.timeIntervalSince1970, 1_860)
        XCTAssertEqual(evidence.evidenceID, try Identifier("risk-blocker-paper-action-proposal-long"))
        XCTAssertEqual(evidence.paperOrderID, decision.proposal.proposalID)
        XCTAssertEqual(evidence.symbol, decision.proposal.symbol)
        XCTAssertEqual(evidence.timeframe, decision.proposal.timeframe)
        XCTAssertEqual(evidence.proposedQuantity, decision.proposal.quantity)
        XCTAssertEqual(evidence.riskProfileID, try Identifier("paper-risk"))
        XCTAssertEqual(evidence.executionMode, .paper)
        XCTAssertEqual(evidence.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(evidence.generatedAt, decision.evaluatedAt)
        XCTAssertEqual(
            decision.riskEvents,
            [
                .evaluationRequested(decision.riskQuery),
                .blocked(evidence)
            ]
        )
        XCTAssertTrue(decision.paperOnlyContextIsConsistent)
        XCTAssertFalse(decision.liveExecutionFallbackAvailable)
        XCTAssertFalse(decision.brokerFallbackAvailable)
    }

    func testPaperActionRiskDecisionDecodingRejectsMismatchedEvidence() throws {
        // 测试场景：MTP-33 decision 解码不能把 allowed 结果伪造成带 blocker 的混合状态；
        // source sequence 也必须保持正数，避免不可追溯的风险证据进入 replay 链路。
        let decision = try PaperActionProposalRiskFixture.deterministicBlocked()
        let encoded = try JSONEncoder().encode(decision)
        let decoder = JSONDecoder()

        var allowedWithBlocker = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        allowedWithBlocker["status"] = "allowed"
        let allowedWithBlockerData = try JSONSerialization.data(withJSONObject: allowedWithBlocker)
        XCTAssertThrowsError(
            try decoder.decode(PaperActionProposalRiskDecision.self, from: allowedWithBlockerData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperActionRiskDecisionMismatch(
                    field: "blockerEvidence",
                    expected: "nil for allowed decision",
                    actual: "present"
                )
            )
        }

        var missingSourceSequence = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        missingSourceSequence["sourceSequence"] = 0
        let missingSourceSequenceData = try JSONSerialization.data(withJSONObject: missingSourceSequence)
        XCTAssertThrowsError(
            try decoder.decode(PaperActionProposalRiskDecision.self, from: missingSourceSequenceData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .invalidEventSequence(0))
        }
    }

    func testPaperPortfolioProjectionUpdateEmitsPaperOnlyPortfolioEventFromAllowedDecision() throws {
        // 测试场景：MTP-34 只能用 allowed paper risk decision 生成 portfolio exposure update；
        // 输出必须是 paper-only read model fact，不能携带真实账户读取、broker sync 或交易执行授权。
        let decision = try PaperActionProposalRiskFixture.deterministicAllowed()
        let update = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("paper-portfolio-update-allowed"),
            portfolioID: try Identifier("portfolio-main"),
            decision: decision,
            updatedAt: Date(timeIntervalSince1970: 1_900)
        )

        XCTAssertEqual(update.updateID, try Identifier("paper-portfolio-update-allowed"))
        XCTAssertEqual(update.decisionID, decision.decisionID)
        XCTAssertEqual(update.proposalID, decision.proposal.proposalID)
        XCTAssertEqual(update.sessionID, decision.proposal.sessionID)
        XCTAssertEqual(update.riskProfileID, try Identifier("paper-risk"))
        XCTAssertEqual(update.side, .buy)
        XCTAssertEqual(update.riskDecisionStatus, .allowed)
        XCTAssertEqual(update.executionMode, .paper)
        XCTAssertEqual(update.sourceSequence, decision.sourceSequence)
        XCTAssertEqual(update.exposure.portfolioID, try Identifier("portfolio-main"))
        XCTAssertEqual(update.exposure.symbol, try Symbol(rawValue: "BTCUSDT"))
        XCTAssertEqual(update.exposure.timeframe, .oneMinute)
        XCTAssertEqual(update.exposure.paperQuantity.rawValue, 0.5, accuracy: 0.00000001)
        XCTAssertEqual(update.exposure.referencePrice.rawValue, 100, accuracy: 0.00000001)
        XCTAssertEqual(update.exposure.grossExposureNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(update.exposure.source, .paperProjection)
        XCTAssertEqual(update.updatedAt.timeIntervalSince1970, 1_900)
        XCTAssertFalse(update.authorizesTradingExecution)
        XCTAssertFalse(update.readsRealAccountBalance)
        XCTAssertFalse(update.syncsBrokerPosition)
        XCTAssertEqual(update.portfolioEvent, .paperProjectionUpdated(update))
        XCTAssertEqual(
            DomainEvent.portfolio(update.portfolioEvent),
            .portfolio(.paperProjectionUpdated(update))
        )

        let encoded = try JSONEncoder().encode(update)
        let decoded = try JSONDecoder().decode(PaperPortfolioProjectionUpdate.self, from: encoded)
        XCTAssertEqual(decoded, update)
    }

    func testPaperPortfolioProjectionUpdateRejectsBlockedDecisionAndCapabilityBypass() throws {
        // 测试场景：blocked risk decision 不能更新 portfolio projection；Codable 解码也不能
        // 恢复 trading authorization、真实账户余额读取或 broker position sync 能力。
        let blockedDecision = try PaperActionProposalRiskFixture.deterministicBlocked()
        XCTAssertThrowsError(
            try PaperPortfolioProjectionUpdate(
                updateID: try Identifier("paper-portfolio-update-blocked"),
                portfolioID: try Identifier("portfolio-main"),
                decision: blockedDecision,
                updatedAt: Date(timeIntervalSince1970: 1_900)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPortfolioProjectionRequiresAllowedRiskDecision(.blocked)
            )
        }

        let allowedUpdate = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("paper-portfolio-update-allowed"),
            portfolioID: try Identifier("portfolio-main"),
            decision: try PaperActionProposalRiskFixture.deterministicAllowed(),
            updatedAt: Date(timeIntervalSince1970: 1_900)
        )
        let encoded = try JSONEncoder().encode(allowedUpdate)
        let decoder = JSONDecoder()

        var blockedObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        blockedObject["riskDecisionStatus"] = "blocked"
        let blockedData = try JSONSerialization.data(withJSONObject: blockedObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperPortfolioProjectionUpdate.self, from: blockedData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPortfolioProjectionRequiresAllowedRiskDecision(.blocked)
            )
        }

        var tradingAuthorizationObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        tradingAuthorizationObject["authorizesTradingExecution"] = true
        let tradingAuthorizationData = try JSONSerialization.data(withJSONObject: tradingAuthorizationObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperPortfolioProjectionUpdate.self, from: tradingAuthorizationData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPortfolioProjectionForbiddenCapability("authorizesTradingExecution")
            )
        }
    }

    func testEMABacktestPaperParityLocksStrategyQueryWarmupAndSignalTimeline() throws {
        // 场景：用乱序 deterministic fixture 验证 Backtest 与 Paper 共享同一 EMA 合同，
        // 并锁定 strategy、MarketDataQuery、warm-up 后首个 timestamp、方向和完整时间线。
        let marketDataQuery = try makeEMAMarketDataQuery()
        let strategy = try makeEMAStrategy()
        let bars = Array(try makeEMAFixtureBars().reversed())
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
        let backtestSamples = backtestRun.result.signalSamples
        let paperSamples = paperRun.result.signalSamples
        let parity = BacktestPaperParity.verify(
            backtest: backtestRun.result,
            paper: paperRun.result
        )

        XCTAssertEqual(backtestRun.result.command.strategy, strategy)
        XCTAssertEqual(paperRun.result.command.strategy, strategy)
        XCTAssertEqual(backtestRun.result.command.marketData, marketDataQuery)
        XCTAssertEqual(paperRun.result.command.marketData, marketDataQuery)
        XCTAssertEqual(backtestSamples.count, bars.count - strategy.longPeriod + 1)
        XCTAssertEqual(backtestSamples.map(\.signal.symbol), Array(repeating: strategy.symbol, count: 4))
        XCTAssertEqual(backtestSamples.map(\.signal.timeframe), Array(repeating: strategy.timeframe, count: 4))
        XCTAssertEqual(backtestSamples.map(\.signal.generatedAt.timeIntervalSince1970), [280, 340, 400, 460])
        XCTAssertEqual(backtestSamples.map(\.signal.direction), [.long, .long, .flat, .long])
        XCTAssertEqual(paperSamples, backtestSamples)
        XCTAssertTrue(parity.sameStrategy)
        XCTAssertTrue(parity.sameMarketData)
        XCTAssertTrue(parity.matchingSignalTimeline)
        XCTAssertTrue(parity.isConsistent)
    }

    func testEMAEventFlowsRejectBarsOutsideMarketDataQueryRange() throws {
        // 场景：MarketDataQuery 的时间范围窄于 fixture bars 时，Backtest 和 Paper 都必须拒绝，
        // 防止用超出查询窗口的数据生成看似一致的 signal timeline。
        let strategy = try makeEMAStrategy()
        let narrowMarketDataQuery = try makeEMAMarketDataQuery(end: 400)
        let bars = try makeEMAFixtureBars()
        let expectedError = CoreError.marketDataMismatch(
            field: "marketData.range",
            expected: "100...400",
            actual: "100...460"
        )

        XCTAssertThrowsError(
            try BacktestEventFlow().run(
                BacktestCommand(
                    runID: try Identifier("backtest-ema-fixture"),
                    strategy: strategy,
                    marketData: narrowMarketDataQuery
                ),
                bars: bars
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, expectedError)
        }

        XCTAssertThrowsError(
            try PaperSessionEventFlow().start(
                PaperSessionCommand(
                    sessionID: try Identifier("paper-ema-fixture"),
                    strategy: strategy,
                    marketData: narrowMarketDataQuery,
                    riskProfileID: try Identifier("paper-risk"),
                    executionMode: .paper
                ),
                bars: bars
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, expectedError)
        }
    }

    func testExecutionCostAssumptionsGenerateDeterministicFeesAndSlippageFixture() throws {
        // 测试场景：MTP-27 固定成本 fixture 必须用同一 notional 和同一四舍五入规则，
        // 稳定输出 maker / taker fee、fixed slippage 和 total cost evidence。
        let assumptions = ExecutionCostAssumptions.deterministicFixture
        let makerRequest = try makeExecutionCostRequest(liquidityRole: .maker)
        let takerRequest = try makeExecutionCostRequest(liquidityRole: .taker)

        let maker = ExecutionCostCalculator.estimate(makerRequest, assumptions: assumptions)
        let taker = ExecutionCostCalculator.estimate(takerRequest, assumptions: assumptions)
        let sameNotional = ExecutionCostCalculator.estimate(
            try makeExecutionCostRequest(referencePrice: 50, quantity: 1, liquidityRole: .maker),
            assumptions: assumptions
        )

        XCTAssertEqual(assumptions.assumptionID.rawValue, "mtp-27-fixed-cost-assumptions")
        XCTAssertEqual(assumptions.makerFeeRateBps, 2)
        XCTAssertEqual(assumptions.takerFeeRateBps, 5)
        XCTAssertEqual(assumptions.slippageRateBps, 1.5)
        XCTAssertEqual(maker.grossNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(maker.feeRateBps, 2, accuracy: 0.00000001)
        XCTAssertEqual(maker.feeAmount, 0.01, accuracy: 0.00000001)
        XCTAssertEqual(maker.slippageAmount, 0.0075, accuracy: 0.00000001)
        XCTAssertEqual(maker.totalCostAmount, 0.0175, accuracy: 0.00000001)
        XCTAssertEqual(taker.feeRateBps, 5, accuracy: 0.00000001)
        XCTAssertEqual(taker.feeAmount, 0.025, accuracy: 0.00000001)
        XCTAssertEqual(taker.totalCostAmount, 0.0325, accuracy: 0.00000001)
        XCTAssertEqual(sameNotional.grossNotional, maker.grossNotional, accuracy: 0.00000001)
        XCTAssertEqual(sameNotional.slippageAmount, maker.slippageAmount, accuracy: 0.00000001)
    }

    func testExecutionCostParityKeepsBacktestAndPaperCostEvidenceConsistent() throws {
        // 测试场景：Backtest 与 Paper 只要使用同一固定假设和同一输入，
        // fee / slippage evidence 必须完全一致，但仍不代表真实成交或 broker fill。
        let assumptions = ExecutionCostAssumptions.deterministicFixture
        let backtest = ExecutionCostCalculator.estimate(
            try makeExecutionCostRequest(executionMode: .backtest),
            assumptions: assumptions
        )
        let paper = ExecutionCostCalculator.estimate(
            try makeExecutionCostRequest(executionMode: .paper),
            assumptions: assumptions
        )

        let parity = ExecutionCostParity.verify(backtest: backtest, paper: paper)

        XCTAssertTrue(parity.sameAssumptionID)
        XCTAssertTrue(parity.sameCostInput)
        XCTAssertTrue(parity.matchingCostBreakdown)
        XCTAssertTrue(parity.backtestModeIsBacktest)
        XCTAssertTrue(parity.paperModeIsPaper)
        XCTAssertTrue(parity.isConsistent)
        XCTAssertEqual(backtest.totalCostAmount, paper.totalCostAmount, accuracy: 0.00000001)
    }

    func testExecutionCostAssumptionsRejectInvalidRatesAndRounding() throws {
        // 测试场景：成本假设只能使用有限且非负的固定 bps，并锁定统一 rounding scale，
        // 防止动态或不可复现的费用 / 滑点输入进入 parity evidence。
        XCTAssertThrowsError(
            try ExecutionCostAssumptions(
                assumptionID: try Identifier("invalid-maker-fee"),
                makerFeeRateBps: -0.1,
                takerFeeRateBps: 5,
                slippageRateBps: 1.5,
                roundingDecimalPlaces: 8
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .invalidExecutionCostAssumption(field: "makerFeeRateBps", value: -0.1)
            )
        }

        XCTAssertThrowsError(
            try ExecutionCostAssumptions(
                assumptionID: try Identifier("invalid-rounding"),
                makerFeeRateBps: 2,
                takerFeeRateBps: 5,
                slippageRateBps: 1.5,
                roundingDecimalPlaces: 9
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .invalidExecutionCostRoundingDecimalPlaces(9))
        }
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

        XCTAssertEqual(messageBus.envelopes.map(\.sequence), Array(1...13))
        XCTAssertEqual(
            messageBus.replay(
                EventReplayCommand(
                    range: try EventSequenceRange(lowerBound: 1, upperBound: 13),
                    streams: [.backtest]
                )
            ).envelopes.count,
            6
        )
        XCTAssertEqual(
            messageBus.replay(
                EventReplayCommand(
                    range: try EventSequenceRange(lowerBound: 1, upperBound: 13),
                    streams: [.paper]
                )
            ).envelopes.count,
            7
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
        // 测试场景：订单簿失衡 fixture 必须稳定覆盖 bid、neutral、ask 三种 bias，
        // 并保留 snapshot / delta 输入来源，作为后续投影和 PR evidence 的可审计字段。
        let contract = OrderBookImbalanceStrategyContract(
            configuration: try makeOrderBookImbalanceStrategy()
        )

        let samples = try contract.evaluate(try makeOrderBookImbalanceInputs())

        XCTAssertEqual(samples.map(\.bias), [.bidDominant, .neutral, .askDominant])
        XCTAssertEqual(samples.map(\.signal.direction), [.long, .flat, .flat])
        XCTAssertEqual(samples.map(\.inputSource), [.snapshot, .deltaApplied, .snapshot])
        XCTAssertEqual(samples.map(\.signal.generatedAt.timeIntervalSince1970), [1_000, 1_060, 1_120])
        XCTAssertEqual(samples.map(\.signal.timeframe), [.oneMinute, .oneMinute, .oneMinute])
        XCTAssertEqual(samples[0].bidNotional, 299, accuracy: 0.0001)
        XCTAssertEqual(samples[0].askNotional, 203, accuracy: 0.0001)
        XCTAssertEqual(samples[0].imbalanceRatio, 0.1912350598, accuracy: 0.0001)
        XCTAssertEqual(samples[1].imbalanceRatio, 0, accuracy: 0.0001)
        XCTAssertEqual(samples[2].imbalanceRatio, -0.2088353414, accuracy: 0.0001)
    }

    func testOrderBookImbalanceResearchParityEvidenceCoversBiasAndInputSources() throws {
        // 测试场景：research event flow 必须与直接策略 contract 生成相同 signal timeline，
        // 并证明 ask dominance 只保留为研究 bias，不会映射为 short、margin 或真实订单动作。
        let inputs = try makeOrderBookImbalanceInputs()
        let strategy = try makeOrderBookImbalanceStrategy()
        let marketData = try makeOrderBookMarketDataQuery()
        let command = OrderBookImbalanceResearchCommand(
            researchID: try Identifier("obi-research-fixture"),
            strategy: strategy,
            marketData: marketData
        )
        let directSamples = try OrderBookImbalanceStrategyContract(
            configuration: strategy
        ).evaluate(inputs)
        let run = try OrderBookImbalanceResearchEventFlow().run(
            command,
            inputs: inputs,
            completedAt: Date(timeIntervalSince1970: 1_300)
        )

        let parity = try OrderBookImbalanceResearchParity.verify(
            command: command,
            inputs: inputs,
            run: run
        )

        XCTAssertEqual(run.result.signalSamples, directSamples)
        XCTAssertTrue(parity.sameResearchID)
        XCTAssertTrue(parity.sameStrategy)
        XCTAssertTrue(parity.sameMarketData)
        XCTAssertTrue(parity.matchingSignalSamples)
        XCTAssertEqual(parity.coveredInputSources, [.snapshot, .deltaApplied])
        XCTAssertTrue(parity.askDominanceRemainsResearchOnly)
        XCTAssertTrue(parity.isConsistent)
        XCTAssertEqual(directSamples.map(\.bias), [.bidDominant, .neutral, .askDominant])
        XCTAssertEqual(directSamples.map(\.signal.direction), [.long, .flat, .flat])
        XCTAssertEqual(directSamples.map(\.inputSource), [.snapshot, .deltaApplied, .snapshot])
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

    private func makeEMAMarketDataQuery(end: TimeInterval = 460) throws -> MarketDataQuery {
        MarketDataQuery(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            range: try DateRange(
                start: Date(timeIntervalSince1970: 100),
                end: Date(timeIntervalSince1970: end)
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

    private func makeExecutionCostRequest(
        referencePrice: Double = 100,
        quantity: Double = 0.5,
        executionMode: ExecutionMode = .backtest,
        liquidityRole: ExecutionCostLiquidityRole = .maker
    ) throws -> ExecutionCostEstimateRequest {
        ExecutionCostEstimateRequest(
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            executionMode: executionMode,
            referencePrice: try Price(referencePrice, field: "executionCost.referencePrice"),
            quantity: try Quantity(quantity, field: "executionCost.quantity"),
            liquidityRole: liquidityRole
        )
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
        let neutral = try bidDominant.applying(
            OrderBookDelta(
                symbol: symbol,
                observedAt: Date(timeIntervalSince1970: 1_060),
                bidUpdates: [
                    try makeOrderBookLevel(price: 100, quantity: 1)
                ],
                askUpdates: [
                    try makeOrderBookLevel(price: 102, quantity: 0.96078431372549)
                ]
            )
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
