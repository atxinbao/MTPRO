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

    func testLiveTradingCredentialEndpointBoundaryDefinesMTP62GateOneAsFutureOnly() throws {
        // 测试场景：MTP-62 只定义 API key / secret / signed / account / listenKey
        // 的 Gate 1 禁止边界和 future gate，不实现任何 credential 或账户请求能力。
        let boundary = LiveTradingCredentialEndpointBoundary.deterministicFixture

        XCTAssertEqual(
            boundary.contractID,
            try Identifier("mtp-62-live-credential-endpoint-boundary")
        )
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-62"))
        XCTAssertEqual(boundary.gate, .credentialEndpointBoundary)
        XCTAssertEqual(
            boundary.forbiddenCapabilities,
            [
                .apiKey,
                .secretStorage,
                .requestSignature,
                .signedEndpoint,
                .accountEndpoint,
                .listenKeyUserDataStream,
                .realAccountPayload
            ]
        )
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveDecision,
                .apiKeySecretPolicy,
                .signedEndpointCapabilityContract,
                .accountEndpointCapabilityContract,
                .listenKeyUserDataStreamContract,
                .publicReadOnlyAdapterSeparation,
                .auditAndOperationsEvidence
            ]
        )
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixAnchor,
                .automationReadinessAnchor,
                .deterministicForbiddenTest,
                .prBoundaryEvidence
            ]
        )
        XCTAssertTrue(boundary.gateOneBoundaryHeld)
        XCTAssertFalse(boundary.readsAPIKey)
        XCTAssertFalse(boundary.storesSecret)
        XCTAssertFalse(boundary.signsRequests)
        XCTAssertFalse(boundary.callsSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.consumesRealAccountPayload)
        XCTAssertFalse(boundary.upgradesPublicReadOnlyAdapter)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveTradingCredentialEndpointBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testLiveTradingCredentialEndpointBoundaryRejectsSecretSignedAccountAndListenKeyBypass() throws {
        // 测试场景：Gate 1 fixture 的初始化和 Codable 解码都必须拒绝恢复真实 API key、
        // secret storage、签名请求、账户 endpoint 或 listenKey user data stream。
        XCTAssertThrowsError(
            try LiveTradingCredentialEndpointBoundary(readsAPIKey: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsAPIKey"))
        }
        XCTAssertThrowsError(
            try LiveTradingCredentialEndpointBoundary(storesSecret: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("storesSecret"))
        }
        XCTAssertThrowsError(
            try LiveTradingCredentialEndpointBoundary(signsRequests: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("signsRequests"))
        }
        XCTAssertThrowsError(
            try LiveTradingCredentialEndpointBoundary(callsAccountEndpoint: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("callsAccountEndpoint")
            )
        }
        XCTAssertThrowsError(
            try LiveTradingCredentialEndpointBoundary(createsListenKey: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("createsListenKey"))
        }
        XCTAssertThrowsError(
            try LiveTradingCredentialEndpointBoundary(
                forbiddenCapabilities: [.apiKey]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "forbiddenCapabilities",
                    expected: LiveTradingCredentialEndpointBoundary
                        .requiredForbiddenCapabilities
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "API key"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveTradingCredentialEndpointBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["callsSignedEndpoint"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveTradingCredentialEndpointBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("callsSignedEndpoint")
            )
        }
    }

    func testLiveAdapterCapabilityIsolationBoundaryDefinesMTP63GateTwoAsFutureOnly() throws {
        // 测试场景：MTP-63 只定义 current public read-only adapter 与 future live adapter
        // capability 的隔离合同；LiveExecutionAdapter 和 broker / exchange execution adapter
        // 只能作为 future gate / forbidden evidence 出现，不能成为当前可实例化能力。
        let boundary = LiveAdapterCapabilityIsolationBoundary.deterministicFixture

        XCTAssertEqual(
            boundary.contractID,
            try Identifier("mtp-63-live-adapter-capability-isolation")
        )
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-63"))
        XCTAssertEqual(boundary.gate, .adapterCapabilityIsolation)
        XCTAssertEqual(boundary.currentAdapterName, "Binance public market data")
        XCTAssertEqual(
            boundary.readOnlyAllowedCapabilities,
            [
                "exchangeInfo",
                "klines",
                "recent trades",
                "best bid / ask",
                "depth snapshot",
                "depth delta"
            ]
        )
        XCTAssertEqual(boundary.forbiddenCapabilities, LiveAdapterIsolationForbiddenCapability.allCases)
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveDecision,
                .credentialEndpointBoundarySatisfied,
                .adapterCapabilityContract,
                .brokerExchangeAdapterContract,
                .realOrderLifecycleContract,
                .riskAndOperationsReadiness,
                .auditEvidence
            ]
        )
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixAnchor,
                .automationReadinessAnchor,
                .deterministicForbiddenTest,
                .prBoundaryEvidence
            ]
        )
        XCTAssertTrue(boundary.gateTwoBoundaryHeld)
        XCTAssertTrue(boundary.currentAdapterIsReadOnly)
        XCTAssertFalse(boundary.currentAdapterRequiresAPIKey)
        XCTAssertFalse(boundary.currentAdapterUsesSignedEndpoint)
        XCTAssertFalse(boundary.currentAdapterCallsAccountEndpoint)
        XCTAssertFalse(boundary.currentAdapterCreatesListenKey)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.instantiatesBrokerExecutionAdapter)
        XCTAssertFalse(boundary.instantiatesExchangeExecutionAdapter)
        XCTAssertFalse(boundary.exposesExecutionVenueConnection)
        XCTAssertFalse(boundary.submitsRealOrder)
        XCTAssertFalse(boundary.cancelsRealOrder)
        XCTAssertFalse(boundary.replacesRealOrder)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveAdapterCapabilityIsolationBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testLiveAdapterCapabilityIsolationBoundaryRejectsExecutionAdapterInstantiationBypass() throws {
        // 测试场景：Gate 2 fixture 的初始化和 Codable 解码都必须拒绝把 future live
        // adapter capability 反序列化为 LiveExecutionAdapter、broker / exchange execution adapter
        // 或真实订单 submit / cancel / replace 能力。
        XCTAssertThrowsError(
            try LiveAdapterCapabilityIsolationBoundary(implementsLiveExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsLiveExecutionAdapter")
            )
        }
        XCTAssertThrowsError(
            try LiveAdapterCapabilityIsolationBoundary(instantiatesBrokerExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("instantiatesBrokerExecutionAdapter")
            )
        }
        XCTAssertThrowsError(
            try LiveAdapterCapabilityIsolationBoundary(instantiatesExchangeExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("instantiatesExchangeExecutionAdapter")
            )
        }
        XCTAssertThrowsError(
            try LiveAdapterCapabilityIsolationBoundary(submitsRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }
        XCTAssertThrowsError(
            try LiveAdapterCapabilityIsolationBoundary(
                forbiddenCapabilities: [.liveExecutionAdapter]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "forbiddenCapabilities",
                    expected: LiveAdapterCapabilityIsolationBoundary
                        .requiredForbiddenCapabilities
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "LiveExecutionAdapter"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveAdapterCapabilityIsolationBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["implementsLiveExecutionAdapter"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveAdapterCapabilityIsolationBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsLiveExecutionAdapter")
            )
        }
    }

    func testRealOrderLifecycleBoundaryDefinesMTP64GateThreeAsFutureOnly() throws {
        // 测试场景：MTP-64 只定义真实订单生命周期术语和 future gates；submit / cancel /
        // replace、execution report、broker fill、reconciliation 和 OMS 都必须保持不可执行。
        let boundary = RealOrderLifecycleBoundary.deterministicFixture

        XCTAssertEqual(
            boundary.contractID,
            try Identifier("mtp-64-real-order-lifecycle-boundary")
        )
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-64"))
        XCTAssertEqual(boundary.gate, .realOrderLifecycleTerms)
        XCTAssertEqual(boundary.terminology, RealOrderLifecycleTerm.allCases)
        XCTAssertEqual(boundary.forbiddenCapabilities, RealOrderLifecycleForbiddenCapability.allCases)
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveDecision,
                .credentialEndpointBoundarySatisfied,
                .adapterCapabilityIsolationSatisfied,
                .realOrderStateMachineContract,
                .submitContract,
                .cancelContract,
                .replaceContract,
                .executionReportContract,
                .brokerFillContract,
                .reconciliationContract,
                .omsBlueprint,
                .liveRiskOperationsAuditEvidence
            ]
        )
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .terminologyDocumentation,
                .futureGateDocumentation,
                .validationMatrixAnchor,
                .automationReadinessAnchor,
                .deterministicForbiddenTest,
                .paperLiveIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertTrue(boundary.gateThreeBoundaryHeld)
        XCTAssertFalse(boundary.implementsRealOrderStateMachine)
        XCTAssertFalse(boundary.submitsRealOrder)
        XCTAssertFalse(boundary.cancelsRealOrder)
        XCTAssertFalse(boundary.replacesRealOrder)
        XCTAssertFalse(boundary.consumesExecutionReport)
        XCTAssertFalse(boundary.recordsBrokerFill)
        XCTAssertFalse(boundary.performsReconciliation)
        XCTAssertFalse(boundary.implementsOMS)
        XCTAssertFalse(boundary.readsRealAccountState)
        XCTAssertFalse(boundary.syncsBrokerPosition)
        XCTAssertFalse(boundary.upgradesPaperOrderLifecycle)
        XCTAssertFalse(boundary.upgradesPaperOrderIntent)
        XCTAssertFalse(boundary.upgradesSimulatedFillToBrokerFill)
        XCTAssertFalse(boundary.upgradesPaperPortfolioToAccountState)
        XCTAssertFalse(boundary.readModelRepresentsRealOrderLifecycle)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(RealOrderLifecycleBoundary.self, from: encoded)
        XCTAssertEqual(decoded, boundary)
    }

    func testRealOrderLifecycleBoundaryRejectsMTP64ForbiddenCapabilityBypass() throws {
        // 测试场景：Gate 3 fixture 的初始化和 Codable 解码都必须拒绝恢复真实订单状态机、
        // submit / cancel / replace、execution report、broker fill、reconciliation、OMS 或 paper 升级路径。
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(implementsRealOrderStateMachine: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsRealOrderStateMachine")
            )
        }
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(submitsRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(cancelsRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("cancelsRealOrder"))
        }
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(replacesRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("replacesRealOrder"))
        }
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(consumesExecutionReport: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("consumesExecutionReport")
            )
        }
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(recordsBrokerFill: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("recordsBrokerFill"))
        }
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(performsReconciliation: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("performsReconciliation")
            )
        }
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(implementsOMS: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("implementsOMS"))
        }
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(upgradesSimulatedFillToBrokerFill: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("upgradesSimulatedFillToBrokerFill")
            )
        }
        XCTAssertThrowsError(
            try RealOrderLifecycleBoundary(terminology: [.realOrderIntent])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "terminology",
                    expected: RealOrderLifecycleBoundary
                        .requiredTerminology
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "real order intent"
                )
            )
        }

        let encoded = try JSONEncoder().encode(RealOrderLifecycleBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["performsReconciliation"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(RealOrderLifecycleBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("performsReconciliation")
            )
        }
    }

    func testPaperOrderFillAndPortfolioEvidenceCannotUpgradeToRealOrderLifecycle() throws {
        // 测试场景：MTP-64 明确 paper order lifecycle、simulated fill 和 paper portfolio
        // projection 只能保持 paper-only evidence，不能升级为真实订单、broker fill 或 account state。
        let boundary = RealOrderLifecycleBoundary.deterministicFixture
        let paperOrder = try PaperOrderIntentFixture.deterministicAllowed()
        let simulatedFill = try PaperSimulatedFillFixture.deterministicAllowed()
        let portfolioUpdate = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("paper-portfolio-update-mtp-64"),
            portfolioID: try Identifier("portfolio-main"),
            simulatedFill: simulatedFill,
            sourceSimulatedFillSequence: 10,
            updatedAt: Date(timeIntervalSince1970: 1_900)
        )

        XCTAssertTrue(boundary.gateThreeBoundaryHeld)
        XCTAssertFalse(boundary.upgradesPaperOrderLifecycle)
        XCTAssertFalse(boundary.upgradesPaperOrderIntent)
        XCTAssertFalse(boundary.upgradesSimulatedFillToBrokerFill)
        XCTAssertFalse(boundary.upgradesPaperPortfolioToAccountState)
        XCTAssertFalse(boundary.readModelRepresentsRealOrderLifecycle)

        XCTAssertEqual(paperOrder.lifecycleState, .intentCreated)
        XCTAssertTrue(paperOrder.paperOnlyBoundaryHeld)
        XCTAssertFalse(paperOrder.representsRealOrder)
        XCTAssertFalse(paperOrder.authorizesLiveTrading)
        XCTAssertFalse(paperOrder.isExecutableAsRealOrder)

        XCTAssertTrue(simulatedFill.isSimulatedFillEvidence)
        XCTAssertTrue(simulatedFill.paperOnlyBoundaryHeld)
        XCTAssertFalse(simulatedFill.representsRealFill)
        XCTAssertFalse(simulatedFill.representsBrokerFill)
        XCTAssertFalse(simulatedFill.updatesRealAccountBalance)

        XCTAssertTrue(portfolioUpdate.usesSimulatedFillEvidence)
        XCTAssertEqual(portfolioUpdate.exposure.source, .paperProjection)
        XCTAssertFalse(portfolioUpdate.authorizesTradingExecution)
        XCTAssertFalse(portfolioUpdate.readsRealAccountBalance)
        XCTAssertFalse(portfolioUpdate.syncsBrokerPosition)
    }

    func testLiveReadinessDefinesMTP65BlockedReadModelOnlyEvidence() throws {
        // 测试场景：MTP-65 只定义最小 Live readiness read model，把 API key、signed endpoint、
        // account endpoint、listenKey、broker adapter 和 real order lifecycle 全部表达为 blocked。
        let readiness = LiveReadiness.deterministicFixture

        XCTAssertEqual(readiness.readinessID, try Identifier("mtp-65-live-readiness"))
        XCTAssertEqual(readiness.issueID, try Identifier("MTP-65"))
        XCTAssertEqual(readiness.gate, .liveReadinessBlockedReadModel)
        XCTAssertEqual(readiness.status, .blocked)
        XCTAssertEqual(readiness.allowedEvidenceKinds, LiveReadiness.allowedEvidenceKinds)
        XCTAssertEqual(readiness.blockedEvidence, LiveReadiness.requiredBlockedEvidence)
        XCTAssertEqual(readiness.blockedEvidence.map(\.capability), LiveBlockedCapability.allCases)
        XCTAssertTrue(readiness.liveReadinessBoundaryHeld)
        XCTAssertTrue(readiness.allLiveGatesBlocked)
        XCTAssertTrue(readiness.isReadModelOnly)
        XCTAssertFalse(readiness.providesCommandSurface)
        XCTAssertFalse(readiness.authorizesLiveTrading)
        XCTAssertFalse(readiness.exposesAdapterSurface)
        XCTAssertFalse(readiness.exposesRuntimeObject)
        XCTAssertFalse(readiness.exposesSQLiteSchema)
        XCTAssertFalse(readiness.exposesDuckDBSchema)
        XCTAssertFalse(readiness.readsAPIKey)
        XCTAssertFalse(readiness.usesSignedEndpoint)
        XCTAssertFalse(readiness.callsAccountEndpoint)
        XCTAssertFalse(readiness.createsListenKey)
        XCTAssertFalse(readiness.instantiatesBrokerAdapter)
        XCTAssertFalse(readiness.representsRealOrderLifecycle)
        XCTAssertFalse(readiness.requiredValidationDependsOnNetwork)

        for evidence in readiness.blockedEvidence {
            XCTAssertTrue(evidence.blockedReadModelBoundaryHeld)
            XCTAssertEqual(
                evidence.gate,
                LiveBlockedEvidence.requiredGate(for: evidence.capability)
            )
            XCTAssertEqual(
                evidence.sourceAnchors,
                LiveBlockedEvidence.requiredSourceAnchors(for: evidence.capability)
            )
            XCTAssertEqual(evidence.evidenceKind, .readModelSnapshot)
            XCTAssertTrue(evidence.isBlocked)
            XCTAssertTrue(evidence.isReadModelOnly)
            XCTAssertFalse(evidence.providesCommandSurface)
            XCTAssertFalse(evidence.authorizesLiveTrading)
            XCTAssertFalse(evidence.exposesAdapterSurface)
            XCTAssertFalse(evidence.exposesRuntimeObject)
            XCTAssertFalse(evidence.exposesSQLiteSchema)
            XCTAssertFalse(evidence.exposesDuckDBSchema)
            XCTAssertFalse(evidence.requiresAPIKey)
            XCTAssertFalse(evidence.usesSignedEndpoint)
            XCTAssertFalse(evidence.callsAccountEndpoint)
            XCTAssertFalse(evidence.createsListenKey)
            XCTAssertFalse(evidence.instantiatesBrokerAdapter)
            XCTAssertFalse(evidence.representsRealOrderLifecycle)
        }

        let encoded = try JSONEncoder().encode(readiness)
        let decoded = try JSONDecoder().decode(LiveReadiness.self, from: encoded)
        XCTAssertEqual(decoded, readiness)
    }

    func testLiveReadinessRejectsMTP65CommandSchemaAndLiveCapabilityBypass() throws {
        // 测试场景：Gate 4 read model 的初始化和 Codable 解码都必须拒绝 command surface、
        // schema / runtime / adapter 暴露、API key、signed/account/listenKey、broker 和真实订单语义。
        XCTAssertThrowsError(
            try LiveReadiness(providesCommandSurface: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesCommandSurface"))
        }
        XCTAssertThrowsError(
            try LiveReadiness(exposesSQLiteSchema: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesSQLiteSchema"))
        }
        XCTAssertThrowsError(
            try LiveReadiness(exposesRuntimeObject: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesRuntimeObject"))
        }
        XCTAssertThrowsError(
            try LiveReadiness(readsAPIKey: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsAPIKey"))
        }
        XCTAssertThrowsError(
            try LiveReadiness(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try LiveReadiness(instantiatesBrokerAdapter: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("instantiatesBrokerAdapter"))
        }
        XCTAssertThrowsError(
            try LiveReadiness(
                blockedEvidence: Array(LiveReadiness.requiredBlockedEvidence.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "blockedEvidence",
                    expected: LiveReadiness.requiredBlockedEvidence
                        .map(\.capability.rawValue)
                        .joined(separator: ","),
                    actual: Array(LiveReadiness.requiredBlockedEvidence.dropLast())
                        .map(\.capability.rawValue)
                        .joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveReadiness.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["authorizesLiveTrading"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveReadiness.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("authorizesLiveTrading")
            )
        }
    }

    func testLiveBlockedEvidenceKeepsMTP65AllLiveGatesBlocked() throws {
        // 测试场景：单项 blocked evidence 本身也必须拒绝被改写成可执行 readiness、command、
        // adapter surface、broker adapter 或 real order lifecycle read model。
        let brokerEvidence = try LiveBlockedEvidence(
            evidenceID: try Identifier("mtp-65-broker-adapter-blocked"),
            gate: .adapterCapabilityIsolation,
            capability: .brokerAdapter
        )

        XCTAssertTrue(brokerEvidence.blockedReadModelBoundaryHeld)
        XCTAssertEqual(brokerEvidence.sourceAnchors, [
            "MTP-63-ADAPTER-CAPABILITY-ISOLATION",
            "LiveAdapterCapabilityIsolationBoundary"
        ])

        XCTAssertThrowsError(
            try LiveBlockedEvidence(
                evidenceID: try Identifier("mtp-65-api-key-blocked"),
                gate: .adapterCapabilityIsolation,
                capability: .apiKey
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "gate",
                    expected: LiveTradingFoundationGate.credentialEndpointBoundary.rawValue,
                    actual: LiveTradingFoundationGate.adapterCapabilityIsolation.rawValue
                )
            )
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidence(
                evidenceID: try Identifier("mtp-65-api-key-blocked"),
                gate: .credentialEndpointBoundary,
                capability: .apiKey,
                isBlocked: false
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("isBlocked"))
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidence(
                evidenceID: try Identifier("mtp-65-real-order-lifecycle-blocked"),
                gate: .realOrderLifecycleTerms,
                capability: .realOrderLifecycle,
                representsRealOrderLifecycle: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("representsRealOrderLifecycle")
            )
        }

        let encoded = try JSONEncoder().encode(brokerEvidence)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["instantiatesBrokerAdapter"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveBlockedEvidence.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("instantiatesBrokerAdapter")
            )
        }
    }

    func testLiveExecutionControlTerminologyDefinesMTP75FutureOnlyTaxonomy() throws {
        // 测试场景：MTP-75 只定义 Future Live Execution 的 terminology、real order
        // command taxonomy 和 validation anchors。所有字段都必须停留在 future-only /
        // forbidden evidence，不能形成当前可调用的真实订单命令。
        let boundary = LiveExecutionControlTerminologyBoundary.deterministicFixture

        XCTAssertEqual(
            boundary.contractID,
            try Identifier("mtp-75-live-execution-control-terminology")
        )
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-75"))
        XCTAssertEqual(boundary.terms, LiveExecutionControlTerm.allCases)
        XCTAssertEqual(boundary.commandTaxonomy, FutureRealOrderCommandTaxonomyTerm.allCases)
        XCTAssertEqual(
            boundary.commandTaxonomy,
            [.submit, .cancel, .replace, .executionReport, .reconciliation, .incidentFallback]
        )
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveDecision,
                .credentialEndpointBoundarySatisfied,
                .adapterCapabilityIsolationSatisfied,
                .realOrderLifecycleBoundarySatisfied,
                .submitCancelReplaceContract,
                .executionReportContract,
                .brokerFillContract,
                .reconciliationContract,
                .incidentFallbackContract,
                .liveRiskOperationsAuditEvidence
            ]
        )
        XCTAssertEqual(boundary.forbiddenCapabilities, LiveExecutionControlForbiddenCapability.allCases)
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperRealIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY",
            "MTP-75-REAL-ORDER-COMMAND-TAXONOMY",
            "MTP-75-PAPER-REAL-COMMAND-ISOLATION",
            "MTP-75-NO-EXECUTABLE-COMMAND-SURFACE",
            "MTP-75-LIVE-EXECUTION-CONTROL-VALIDATION",
            "TVM-LIVE-EXECUTION-CONTROL"
        ])
        XCTAssertEqual(boundary.paperIsolationSourceAnchors, [
            "TVM-PAPER-ORDER-LIFECYCLE",
            "TVM-PAPER-EXECUTION-DECISION",
            "TVM-PAPER-SIMULATED-FILL",
            "MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION",
            "MTP-75-PAPER-REAL-COMMAND-ISOLATION"
        ])
        XCTAssertTrue(boundary.terminologyBoundaryHeld)
        XCTAssertTrue(boundary.paperRealIsolationBoundaryHeld)
        XCTAssertTrue(boundary.isFutureOnlyTerminology)
        XCTAssertFalse(boundary.providesExecutableCommandSurface)
        XCTAssertFalse(boundary.readsAPIKey)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.implementsRealOrderStateMachine)
        XCTAssertFalse(boundary.implementsOMS)
        XCTAssertFalse(boundary.submitsRealOrder)
        XCTAssertFalse(boundary.cancelsRealOrder)
        XCTAssertFalse(boundary.replacesRealOrder)
        XCTAssertFalse(boundary.consumesExecutionReport)
        XCTAssertFalse(boundary.recordsBrokerFill)
        XCTAssertFalse(boundary.performsReconciliation)
        XCTAssertFalse(boundary.executesIncidentFallback)
        XCTAssertFalse(boundary.exposesOrderLevelCommandUI)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveExecutionControlTerminologyBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testLiveExecutionControlTerminologyRejectsMTP75ExecutableCommandBypass() throws {
        // 测试场景：MTP-75 taxonomy fixture 的初始化和 Codable 解码都必须拒绝
        // command surface、submit / cancel / replace、execution report、reconciliation、
        // broker adapter、LiveExecutionAdapter、real order state machine 和 OMS 绕过。
        XCTAssertThrowsError(
            try LiveExecutionControlTerminologyBoundary(providesExecutableCommandSurface: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("providesExecutableCommandSurface")
            )
        }
        XCTAssertThrowsError(
            try LiveExecutionControlTerminologyBoundary(submitsRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlTerminologyBoundary(cancelsRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("cancelsRealOrder"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlTerminologyBoundary(replacesRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("replacesRealOrder"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlTerminologyBoundary(consumesExecutionReport: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("consumesExecutionReport")
            )
        }
        XCTAssertThrowsError(
            try LiveExecutionControlTerminologyBoundary(performsReconciliation: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("performsReconciliation")
            )
        }
        XCTAssertThrowsError(
            try LiveExecutionControlTerminologyBoundary(implementsLiveExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsLiveExecutionAdapter")
            )
        }
        XCTAssertThrowsError(
            try LiveExecutionControlTerminologyBoundary(implementsRealOrderStateMachine: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsRealOrderStateMachine")
            )
        }
        XCTAssertThrowsError(
            try LiveExecutionControlTerminologyBoundary(commandTaxonomy: [.submit])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "commandTaxonomy",
                    expected: LiveExecutionControlTerminologyBoundary
                        .requiredCommandTaxonomy
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "submit"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveExecutionControlTerminologyBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["exposesOrderLevelCommandUI"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveExecutionControlTerminologyBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("exposesOrderLevelCommandUI")
            )
        }
    }

    func testLiveExecutionControlTerminologyKeepsMTP75PaperEvidenceIsolatedFromRealCommands() throws {
        // 测试场景：MTP-75 把 paper order intent、paper execution decision 和 simulated fill
        // 明确标为隔离证据来源，不能把既有 paper-only fixture 升级成 real order command。
        let boundary = LiveExecutionControlTerminologyBoundary.deterministicFixture
        let paperOrder = try PaperOrderIntentFixture.deterministicAllowed()
        let executionDecision = try PaperExecutionDecisionFixture.deterministicAllowed()
        let simulatedFill = try PaperSimulatedFillFixture.deterministicAllowed()

        XCTAssertTrue(boundary.paperRealIsolationBoundaryHeld)
        XCTAssertTrue(boundary.terms.contains(.paperOrderIntent))
        XCTAssertTrue(boundary.terms.contains(.paperExecutionDecision))
        XCTAssertTrue(boundary.terms.contains(.simulatedFillEvidence))
        XCTAssertTrue(boundary.forbiddenCapabilities.contains(.paperOrderIntentUpgrade))
        XCTAssertTrue(boundary.forbiddenCapabilities.contains(.paperExecutionDecisionUpgrade))
        XCTAssertTrue(boundary.forbiddenCapabilities.contains(.simulatedFillUpgrade))

        XCTAssertTrue(paperOrder.paperOnlyBoundaryHeld)
        XCTAssertFalse(paperOrder.representsRealOrder)
        XCTAssertFalse(paperOrder.authorizesLiveTrading)
        XCTAssertFalse(paperOrder.isExecutableAsRealOrder)

        XCTAssertTrue(executionDecision.paperOnlyBoundaryHeld)
        XCTAssertFalse(executionDecision.representsRealOrder)
        XCTAssertFalse(executionDecision.authorizesLiveTrading)
        XCTAssertFalse(executionDecision.isExecutableAsRealOrder)

        XCTAssertTrue(simulatedFill.paperOnlyBoundaryHeld)
        XCTAssertFalse(simulatedFill.representsRealFill)
        XCTAssertFalse(simulatedFill.representsBrokerFill)
        XCTAssertFalse(simulatedFill.updatesRealAccountBalance)
    }

    func testLiveSubmitCancelReplaceBoundaryDefinesMTP76FutureGatesAndForbiddenCommands() throws {
        // 测试场景：MTP-76 只把 submit / cancel / replace 固定为 future gates 和
        // forbidden capability evidence，不提供真实订单命令、签名请求、broker action 或 UI。
        let boundary = LiveSubmitCancelReplaceCommandBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-76-submit-cancel-replace-boundary"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-76"))
        XCTAssertEqual(boundary.commandTaxonomy, [.submit, .cancel, .replace])
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveDecision,
                .credentialEndpointBoundarySatisfied,
                .adapterCapabilityIsolationSatisfied,
                .realOrderLifecycleBoundarySatisfied,
                .submitCommandContractDefined,
                .cancelCommandContractDefined,
                .replaceCommandContractDefined,
                .liveRiskGateDefined,
                .executionReportReconciliationGateDefined,
                .operationsAuditHandoffDefined
            ]
        )
        XCTAssertEqual(boundary.forbiddenCapabilities, LiveSubmitCancelReplaceForbiddenCapability.allCases)
        XCTAssertTrue(boundary.forbidsCapability(.submitCommandAPI))
        XCTAssertTrue(boundary.forbidsCapability(.cancelCommandAPI))
        XCTAssertTrue(boundary.forbidsCapability(.replaceCommandAPI))
        XCTAssertTrue(boundary.forbidsCapability(.signedSubmitRequest))
        XCTAssertTrue(boundary.forbidsCapability(.brokerSubmitAction))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperRealIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES",
            "MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS",
            "MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE",
            "MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE",
            "MTP-76-LIVE-EXECUTION-CONTROL-VALIDATION",
            "TVM-LIVE-EXECUTION-CONTROL"
        ])
        XCTAssertEqual(boundary.sourceAnchors, [
            "MTP-75-REAL-ORDER-COMMAND-TAXONOMY",
            "MTP-75-NO-EXECUTABLE-COMMAND-SURFACE",
            "MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION",
            "TVM-PAPER-ORDER-LIFECYCLE",
            "TVM-PAPER-EXECUTION-DECISION",
            "TVM-PAPER-SIMULATED-FILL"
        ])
        XCTAssertTrue(boundary.submitCancelReplaceBoundaryHeld)
        XCTAssertTrue(boundary.allRealOrderCommandsBlocked)
        XCTAssertTrue(boundary.paperIntentUpgradeBoundaryHeld)
        XCTAssertTrue(boundary.isFutureGateOnly)
        XCTAssertFalse(boundary.providesExecutableCommandSurface)
        XCTAssertFalse(boundary.readsAPIKey)
        XCTAssertFalse(boundary.storesSecret)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.instantiatesBrokerExecutionAdapter)
        XCTAssertFalse(boundary.instantiatesExchangeExecutionAdapter)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.implementsRealOrderStateMachine)
        XCTAssertFalse(boundary.implementsOMS)
        XCTAssertFalse(boundary.submitsRealOrder)
        XCTAssertFalse(boundary.cancelsRealOrder)
        XCTAssertFalse(boundary.replacesRealOrder)
        XCTAssertFalse(boundary.sendsSignedSubmitRequest)
        XCTAssertFalse(boundary.sendsSignedCancelRequest)
        XCTAssertFalse(boundary.sendsSignedReplaceRequest)
        XCTAssertFalse(boundary.exposesOrderForm)
        XCTAssertFalse(boundary.exposesOrderLevelCommandUI)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveSubmitCancelReplaceCommandBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testLiveSubmitCancelReplaceBoundaryRejectsMTP76RealCommandBypass() throws {
        // 测试场景：MTP-76 fixture 的初始化和 Codable 解码都必须拒绝真实 submit /
        // cancel / replace、签名请求、broker adapter、LiveExecutionAdapter 和 order form。
        XCTAssertThrowsError(
            try LiveSubmitCancelReplaceCommandBoundary(submitsRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }
        XCTAssertThrowsError(
            try LiveSubmitCancelReplaceCommandBoundary(cancelsRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("cancelsRealOrder"))
        }
        XCTAssertThrowsError(
            try LiveSubmitCancelReplaceCommandBoundary(replacesRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("replacesRealOrder"))
        }
        XCTAssertThrowsError(
            try LiveSubmitCancelReplaceCommandBoundary(sendsSignedSubmitRequest: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("sendsSignedSubmitRequest")
            )
        }
        XCTAssertThrowsError(
            try LiveSubmitCancelReplaceCommandBoundary(instantiatesBrokerExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("instantiatesBrokerExecutionAdapter")
            )
        }
        XCTAssertThrowsError(
            try LiveSubmitCancelReplaceCommandBoundary(implementsLiveExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsLiveExecutionAdapter")
            )
        }
        XCTAssertThrowsError(
            try LiveSubmitCancelReplaceCommandBoundary(exposesOrderForm: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesOrderForm"))
        }
        XCTAssertThrowsError(
            try LiveSubmitCancelReplaceCommandBoundary(commandTaxonomy: [.submit, .cancel])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "commandTaxonomy",
                    expected: LiveSubmitCancelReplaceCommandBoundary
                        .requiredCommandTaxonomy
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "submit,cancel"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveSubmitCancelReplaceCommandBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["sendsSignedReplaceRequest"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveSubmitCancelReplaceCommandBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("sendsSignedReplaceRequest")
            )
        }
    }

    func testPaperOrderIntentCannotUpgradeToMTP76SubmitCancelReplaceCommands() throws {
        // 测试场景：MTP-76 明确 paper-only intent / decision / simulated fill 不能升级为
        // real submit / cancel / replace command，也不能绕过 MTP-75 的 taxonomy 禁区。
        let boundary = LiveSubmitCancelReplaceCommandBoundary.deterministicFixture
        let paperOrder = try PaperOrderIntentFixture.deterministicAllowed()
        let executionDecision = try PaperExecutionDecisionFixture.deterministicAllowed()
        let simulatedFill = try PaperSimulatedFillFixture.deterministicAllowed()

        XCTAssertTrue(boundary.paperIntentUpgradeBoundaryHeld)
        XCTAssertTrue(boundary.forbidsCapability(.paperOrderIntentToSubmitUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperOrderIntentToCancelUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperOrderIntentToReplaceUpgrade))
        XCTAssertFalse(boundary.mapsPaperOrderIntentToSubmit)
        XCTAssertFalse(boundary.mapsPaperOrderIntentToCancel)
        XCTAssertFalse(boundary.mapsPaperOrderIntentToReplace)
        XCTAssertFalse(boundary.upgradesPaperExecutionDecision)
        XCTAssertFalse(boundary.upgradesSimulatedFillToBrokerFill)

        XCTAssertTrue(paperOrder.paperOnlyBoundaryHeld)
        XCTAssertFalse(paperOrder.representsRealOrder)
        XCTAssertFalse(paperOrder.authorizesLiveTrading)
        XCTAssertFalse(paperOrder.isExecutableAsRealOrder)

        XCTAssertTrue(executionDecision.paperOnlyBoundaryHeld)
        XCTAssertFalse(executionDecision.representsRealOrder)
        XCTAssertFalse(executionDecision.authorizesLiveTrading)
        XCTAssertFalse(executionDecision.isExecutableAsRealOrder)

        XCTAssertTrue(simulatedFill.paperOnlyBoundaryHeld)
        XCTAssertFalse(simulatedFill.representsRealFill)
        XCTAssertFalse(simulatedFill.representsBrokerFill)
        XCTAssertFalse(simulatedFill.updatesRealAccountBalance)
    }

    func testExecutionReportBrokerFillReconciliationBoundaryDefinesMTP77FutureGates() throws {
        // 测试场景：MTP-77 只把 execution report、broker fill 和 reconciliation 固定为
        // future gates / blocked evidence，不提供 parser、broker fill fact、account sync 或对账 runtime。
        let boundary = LiveExecutionReportBrokerFillReconciliationBoundary.deterministicFixture

        XCTAssertEqual(
            boundary.contractID,
            try Identifier("mtp-77-execution-report-broker-fill-reconciliation-boundary")
        )
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-77"))
        XCTAssertEqual(boundary.terms, [.executionReport, .brokerFill, .orderReconciliation])
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveDecision,
                .credentialEndpointBoundarySatisfied,
                .adapterCapabilityIsolationSatisfied,
                .realOrderLifecycleBoundarySatisfied,
                .submitCancelReplaceBoundarySatisfied,
                .executionReportSchemaContractDefined,
                .brokerFillFactContractDefined,
                .reconciliationContractDefined,
                .accountStateReadBoundaryDefined,
                .liveRiskOperationsAuditHandoffDefined
            ]
        )
        XCTAssertEqual(
            boundary.forbiddenCapabilities,
            LiveExecutionReportBrokerFillReconciliationForbiddenCapability.allCases
        )
        XCTAssertTrue(boundary.forbidsCapability(.executionReportParser))
        XCTAssertTrue(boundary.forbidsCapability(.executionReportIngestion))
        XCTAssertTrue(boundary.forbidsCapability(.brokerFillRecorder))
        XCTAssertTrue(boundary.forbidsCapability(.reconciliationService))
        XCTAssertTrue(boundary.forbidsCapability(.accountSync))
        XCTAssertTrue(boundary.forbidsCapability(.brokerPositionSync))
        XCTAssertTrue(boundary.forbidsCapability(.simulatedFillToExecutionReportUpgrade))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperRealIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES",
            "MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS",
            "MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT",
            "MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY",
            "MTP-77-LIVE-EXECUTION-CONTROL-VALIDATION",
            "TVM-LIVE-EXECUTION-CONTROL"
        ])
        XCTAssertEqual(boundary.sourceAnchors, [
            "MTP-75-REAL-ORDER-COMMAND-TAXONOMY",
            "MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES",
            "MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE",
            "MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION",
            "TVM-PAPER-ORDER-LIFECYCLE",
            "TVM-PAPER-SIMULATED-FILL",
            "TVM-PAPER-EXECUTION-WORKFLOW"
        ])
        XCTAssertTrue(boundary.reportFillReconciliationBoundaryHeld)
        XCTAssertTrue(boundary.reportFillReconciliationImplementationBlocked)
        XCTAssertTrue(boundary.simulatedFillIsolationBoundaryHeld)
        XCTAssertTrue(boundary.reconciliationBlockedEvidenceBoundaryHeld)
        XCTAssertTrue(boundary.isFutureGateOnly)
        XCTAssertTrue(boundary.isBlockedEvidenceOnly)
        XCTAssertFalse(boundary.providesExecutableCommandSurface)
        XCTAssertFalse(boundary.readsAPIKey)
        XCTAssertFalse(boundary.storesSecret)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.instantiatesBrokerExecutionAdapter)
        XCTAssertFalse(boundary.instantiatesExchangeExecutionAdapter)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.implementsRealOrderStateMachine)
        XCTAssertFalse(boundary.implementsOMS)
        XCTAssertFalse(boundary.submitsRealOrder)
        XCTAssertFalse(boundary.cancelsRealOrder)
        XCTAssertFalse(boundary.replacesRealOrder)
        XCTAssertFalse(boundary.consumesExecutionReport)
        XCTAssertFalse(boundary.parsesExecutionReport)
        XCTAssertFalse(boundary.ingestsExecutionReport)
        XCTAssertFalse(boundary.recordsBrokerFill)
        XCTAssertFalse(boundary.storesBrokerFillFact)
        XCTAssertFalse(boundary.performsReconciliation)
        XCTAssertFalse(boundary.implementsReconciliationRuntime)
        XCTAssertFalse(boundary.readsRealAccountBalance)
        XCTAssertFalse(boundary.syncsBrokerPosition)
        XCTAssertFalse(boundary.mapsSimulatedFillToBrokerFill)
        XCTAssertFalse(boundary.mapsSimulatedFillToExecutionReport)
        XCTAssertFalse(boundary.mapsPaperPortfolioToBrokerPosition)
        XCTAssertFalse(boundary.updatesRealAccountFromSimulatedFill)
        XCTAssertFalse(boundary.exposesBrokerFillAsCurrentReadModel)
        XCTAssertFalse(boundary.exposesOrderLevelCommandUI)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveExecutionReportBrokerFillReconciliationBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testExecutionReportBrokerFillReconciliationBoundaryRejectsMTP77ImplementationBypass() throws {
        // 测试场景：MTP-77 fixture 的初始化和 Codable 解码必须拒绝 execution report
        // ingestion、broker fill recording、reconciliation runtime、账户读取和 broker position sync。
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(consumesExecutionReport: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("consumesExecutionReport")
            )
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(parsesExecutionReport: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("parsesExecutionReport"))
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(ingestsExecutionReport: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("ingestsExecutionReport"))
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(recordsBrokerFill: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("recordsBrokerFill"))
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(storesBrokerFillFact: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("storesBrokerFillFact"))
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(performsReconciliation: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("performsReconciliation"))
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(implementsReconciliationRuntime: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsReconciliationRuntime")
            )
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(readsRealAccountBalance: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRealAccountBalance"))
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(syncsBrokerPosition: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("syncsBrokerPosition"))
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(instantiatesBrokerExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("instantiatesBrokerExecutionAdapter")
            )
        }
        XCTAssertThrowsError(
            try LiveExecutionReportBrokerFillReconciliationBoundary(terms: [.executionReport, .brokerFill])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "terms",
                    expected: LiveExecutionReportBrokerFillReconciliationBoundary
                        .requiredTerms
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "execution report,broker fill"
                )
            )
        }

        let encoded = try JSONEncoder().encode(
            LiveExecutionReportBrokerFillReconciliationBoundary.deterministicFixture
        )
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["mapsSimulatedFillToExecutionReport"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveExecutionReportBrokerFillReconciliationBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsSimulatedFillToExecutionReport")
            )
        }
    }

    func testSimulatedFillAndPaperPortfolioCannotUpgradeToMTP77BrokerFillOrReconciliation() throws {
        // 测试场景：MTP-77 明确 simulated fill 和 paper portfolio projection 只能作为
        // paper-only evidence，不能升级为 broker fill、execution report、real account 或对账输入。
        let boundary = LiveExecutionReportBrokerFillReconciliationBoundary.deterministicFixture
        let simulatedFill = try PaperSimulatedFillFixture.deterministicAllowed()
        let portfolioUpdate = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("paper-portfolio-update-mtp-77"),
            portfolioID: try Identifier("portfolio-main"),
            simulatedFill: simulatedFill,
            sourceSimulatedFillSequence: 10,
            updatedAt: Date(timeIntervalSince1970: 1_900)
        )

        XCTAssertTrue(boundary.simulatedFillIsolationBoundaryHeld)
        XCTAssertTrue(boundary.reconciliationBlockedEvidenceBoundaryHeld)
        XCTAssertTrue(boundary.forbidsCapability(.simulatedFillToBrokerFillUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.simulatedFillToExecutionReportUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperPortfolioToBrokerPositionUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.simulatedFillAccountUpdate))
        XCTAssertFalse(boundary.mapsSimulatedFillToBrokerFill)
        XCTAssertFalse(boundary.mapsSimulatedFillToExecutionReport)
        XCTAssertFalse(boundary.mapsPaperPortfolioToBrokerPosition)
        XCTAssertFalse(boundary.updatesRealAccountFromSimulatedFill)

        XCTAssertTrue(simulatedFill.paperOnlyBoundaryHeld)
        XCTAssertTrue(simulatedFill.isSimulatedFillEvidence)
        XCTAssertFalse(simulatedFill.representsRealFill)
        XCTAssertFalse(simulatedFill.representsBrokerFill)
        XCTAssertFalse(simulatedFill.updatesRealAccountBalance)

        XCTAssertTrue(portfolioUpdate.usesSimulatedFillEvidence)
        XCTAssertEqual(portfolioUpdate.exposure.source, .paperProjection)
        XCTAssertFalse(portfolioUpdate.authorizesTradingExecution)
        XCTAssertFalse(portfolioUpdate.readsRealAccountBalance)
        XCTAssertFalse(portfolioUpdate.syncsBrokerPosition)
    }

    func testPaperRealCommandIsolationBoundaryDefinesMTP78Contract() throws {
        // 测试场景：MTP-78 只定义 paper evidence 与 future real order command 的隔离合同。
        // 该 fixture 必须引用 MTP-75 / MTP-76 / MTP-77 的 future gate evidence，但不能形成真实命令。
        let boundary = LivePaperRealCommandIsolationBoundary.deterministicFixture

        XCTAssertEqual(
            boundary.contractID,
            try Identifier("mtp-78-paper-real-command-isolation-boundary")
        )
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-78"))
        XCTAssertEqual(boundary.evidenceSources, LivePaperRealCommandIsolationEvidenceSource.allCases)
        XCTAssertEqual(
            boundary.forbiddenCapabilities,
            LivePaperRealCommandIsolationForbiddenCapability.allCases
        )
        XCTAssertTrue(boundary.forbidsCapability(.realOrderCommand))
        XCTAssertTrue(boundary.forbidsCapability(.paperOrderIntentToRealCommandUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.simulatedFillToExecutionReportUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperPortfolioToBrokerPositionUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.dashboardCommandSurface))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperRealIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT",
            "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE",
            "MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY",
            "MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY",
            "MTP-78-LIVE-EXECUTION-CONTROL-VALIDATION",
            "TVM-LIVE-EXECUTION-CONTROL"
        ])
        XCTAssertEqual(boundary.sourceAnchors, [
            "MTP-75-PAPER-REAL-COMMAND-ISOLATION",
            "MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE",
            "MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT",
            "MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY",
            "TVM-PAPER-ORDER-LIFECYCLE",
            "TVM-PAPER-EXECUTION-DECISION",
            "TVM-PAPER-SIMULATED-FILL",
            "TVM-PAPER-EXECUTION-WORKFLOW",
            "TVM-REPORT-EVIDENCE",
            "TVM-PAPER-WORKFLOW-CONTROL-SHELL"
        ])
        XCTAssertTrue(boundary.isolationBoundaryHeld)
        XCTAssertTrue(boundary.paperEvidenceCannotUpgradeToRealCommand)
        XCTAssertTrue(boundary.futureRealCommandCapabilitiesBlocked)
        XCTAssertTrue(boundary.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertTrue(boundary.isIsolationContractOnly)
        XCTAssertTrue(boundary.reportConsumesReadModelOnly)
        XCTAssertTrue(boundary.dashboardConsumesViewModelOnly)
        XCTAssertTrue(boundary.eventTimelineConsumesReadModelOnly)
        XCTAssertFalse(boundary.createsRealOrderCommand)
        XCTAssertFalse(boundary.submitsRealOrder)
        XCTAssertFalse(boundary.cancelsRealOrder)
        XCTAssertFalse(boundary.replacesRealOrder)
        XCTAssertFalse(boundary.sendsSignedCommandRequest)
        XCTAssertFalse(boundary.consumesExecutionReport)
        XCTAssertFalse(boundary.recordsBrokerFill)
        XCTAssertFalse(boundary.performsReconciliation)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.implementsRealOrderStateMachine)
        XCTAssertFalse(boundary.implementsOMS)
        XCTAssertFalse(boundary.readsRealAccountBalance)
        XCTAssertFalse(boundary.syncsBrokerPosition)
        XCTAssertFalse(boundary.mapsPaperOrderIntentToRealCommand)
        XCTAssertFalse(boundary.mapsPaperExecutionDecisionToRealCommand)
        XCTAssertFalse(boundary.mapsSimulatedFillToRealCommand)
        XCTAssertFalse(boundary.mapsSimulatedFillToExecutionReport)
        XCTAssertFalse(boundary.mapsSimulatedFillToBrokerFill)
        XCTAssertFalse(boundary.mapsPaperPortfolioToBrokerPosition)
        XCTAssertFalse(boundary.reportProvidesCommandSurface)
        XCTAssertFalse(boundary.dashboardProvidesCommandSurface)
        XCTAssertFalse(boundary.eventTimelineProvidesCommandSurface)
        XCTAssertFalse(boundary.exposesOrderForm)
        XCTAssertFalse(boundary.exposesOrderLevelCommandUI)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)
        XCTAssertTrue(LiveExecutionControlTerminologyBoundary.deterministicFixture.paperRealIsolationBoundaryHeld)
        XCTAssertTrue(LiveSubmitCancelReplaceCommandBoundary.deterministicFixture.paperIntentUpgradeBoundaryHeld)
        XCTAssertTrue(
            LiveExecutionReportBrokerFillReconciliationBoundary
                .deterministicFixture
                .simulatedFillIsolationBoundaryHeld
        )

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LivePaperRealCommandIsolationBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testPaperRealCommandIsolationBoundaryRejectsMTP78RealCommandUpgradeBypass() throws {
        // 测试场景：MTP-78 fixture 的初始化和 Codable 解码都必须拒绝 paper-to-real
        // command、真实 submit / cancel / replace、execution report、broker fill、对账和 UI 命令绕过。
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(mapsPaperOrderIntentToRealCommand: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsPaperOrderIntentToRealCommand")
            )
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(mapsPaperExecutionDecisionToRealCommand: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsPaperExecutionDecisionToRealCommand")
            )
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(mapsSimulatedFillToExecutionReport: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsSimulatedFillToExecutionReport")
            )
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(mapsPaperPortfolioToBrokerPosition: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsPaperPortfolioToBrokerPosition")
            )
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(createsRealOrderCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("createsRealOrderCommand"))
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(submitsRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(consumesExecutionReport: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("consumesExecutionReport"))
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(recordsBrokerFill: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("recordsBrokerFill"))
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(performsReconciliation: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("performsReconciliation"))
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(dashboardProvidesCommandSurface: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("dashboardProvidesCommandSurface")
            )
        }
        XCTAssertThrowsError(
            try LivePaperRealCommandIsolationBoundary(
                evidenceSources: Array(LivePaperRealCommandIsolationEvidenceSource.allCases.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "evidenceSources",
                    expected: LivePaperRealCommandIsolationBoundary
                        .requiredEvidenceSources
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: Array(LivePaperRealCommandIsolationEvidenceSource.allCases.dropLast())
                        .map(\.rawValue)
                        .joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(LivePaperRealCommandIsolationBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["eventTimelineProvidesCommandSurface"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LivePaperRealCommandIsolationBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("eventTimelineProvidesCommandSurface")
            )
        }
    }

    func testPaperEvidenceCannotUpgradeToMTP78FutureRealOrderCommand() throws {
        // 测试场景：MTP-78 把 paper order intent、paper execution decision、simulated fill
        // 和 paper portfolio projection 固定为 paper-only evidence，不能升级为 future real command 输入。
        let boundary = LivePaperRealCommandIsolationBoundary.deterministicFixture
        let paperOrder = try PaperOrderIntentFixture.deterministicAllowed()
        let executionDecision = try PaperExecutionDecisionFixture.deterministicAllowed()
        let simulatedFill = try PaperSimulatedFillFixture.deterministicAllowed()
        let portfolioUpdate = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("paper-portfolio-update-mtp-78"),
            portfolioID: try Identifier("portfolio-main"),
            simulatedFill: simulatedFill,
            sourceSimulatedFillSequence: 18,
            updatedAt: Date(timeIntervalSince1970: 2_100)
        )

        XCTAssertTrue(boundary.paperEvidenceCannotUpgradeToRealCommand)
        XCTAssertTrue(boundary.futureRealCommandCapabilitiesBlocked)
        XCTAssertTrue(boundary.forbidsCapability(.paperOrderIntentToRealCommandUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperExecutionDecisionToRealCommandUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.simulatedFillToRealCommandUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.simulatedFillToBrokerFillUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperPortfolioToBrokerPositionUpgrade))

        XCTAssertTrue(paperOrder.paperOnlyBoundaryHeld)
        XCTAssertFalse(paperOrder.representsRealOrder)
        XCTAssertFalse(paperOrder.authorizesLiveTrading)
        XCTAssertFalse(paperOrder.isExecutableAsRealOrder)

        XCTAssertTrue(executionDecision.paperOnlyBoundaryHeld)
        XCTAssertFalse(executionDecision.representsRealOrder)
        XCTAssertFalse(executionDecision.authorizesLiveTrading)
        XCTAssertFalse(executionDecision.isExecutableAsRealOrder)

        XCTAssertTrue(simulatedFill.paperOnlyBoundaryHeld)
        XCTAssertFalse(simulatedFill.representsRealFill)
        XCTAssertFalse(simulatedFill.representsBrokerFill)
        XCTAssertFalse(simulatedFill.updatesRealAccountBalance)

        XCTAssertTrue(portfolioUpdate.usesSimulatedFillEvidence)
        XCTAssertEqual(portfolioUpdate.exposure.source, .paperProjection)
        XCTAssertFalse(portfolioUpdate.authorizesTradingExecution)
        XCTAssertFalse(portfolioUpdate.readsRealAccountBalance)
        XCTAssertFalse(portfolioUpdate.syncsBrokerPosition)
    }

    func testLiveExecutionControlBlockedEvidenceDefinesMTP79ReadModelOnlySnapshot() throws {
        // 测试场景：MTP-79 只新增 execution-control blocked evidence read model。
        // snapshot 供后续 Dashboard / Report / Event Timeline 消费，但当前不能生成任何真实命令。
        let evidence = LiveExecutionControlBlockedEvidence.deterministicFixture

        XCTAssertEqual(
            evidence.contractID,
            try Identifier("mtp-79-live-execution-control-blocked-evidence")
        )
        XCTAssertEqual(evidence.issueID, try Identifier("MTP-79"))
        XCTAssertEqual(evidence.blockedItems.map(\.gate), LiveExecutionControlBlockedGate.allCases)
        XCTAssertEqual(
            evidence.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperRealIsolationEvidence,
                .readModelOnlyBlockedEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(evidence.validationAnchors, [
            "MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE",
            "MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS",
            "MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT",
            "MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE",
            "MTP-79-LIVE-EXECUTION-CONTROL-VALIDATION",
            "TVM-LIVE-EXECUTION-CONTROL"
        ])
        XCTAssertEqual(evidence.sourceAnchors, [
            "MTP-75-REAL-ORDER-COMMAND-TAXONOMY",
            "MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES",
            "MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE",
            "MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES",
            "MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY",
            "MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT",
            "MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY",
            "TVM-LIVE-EXECUTION-CONTROL"
        ])
        XCTAssertEqual(evidence.deterministicSnapshot, [
            "submit|blocked|human live decision missing;credential endpoint boundary unsatisfied;signed command request forbidden;broker execution adapter forbidden;live risk operations audit missing",
            "cancel|blocked|human live decision missing;credential endpoint boundary unsatisfied;signed command request forbidden;broker execution adapter forbidden;live risk operations audit missing",
            "replace|blocked|human live decision missing;credential endpoint boundary unsatisfied;signed command request forbidden;broker execution adapter forbidden;live risk operations audit missing",
            "execution report|blocked|account endpoint forbidden;listenKey user data stream forbidden;execution report implementation forbidden;read model only boundary required",
            "broker fill|blocked|broker execution adapter forbidden;broker fill implementation forbidden;real order state machine forbidden;paper / real command isolation required",
            "reconciliation|blocked|account endpoint forbidden;reconciliation runtime forbidden;broker position sync forbidden;read model only boundary required",
            "incident fallback|blocked|incident fallback automation forbidden;live risk operations audit missing;read model only boundary required"
        ])

        XCTAssertTrue(evidence.blockedEvidenceBoundaryHeld)
        XCTAssertTrue(evidence.allExecutionControlGatesBlocked)
        XCTAssertTrue(evidence.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertTrue(evidence.forbiddenImplementationBoundaryHeld)
        XCTAssertTrue(evidence.isReadModelOnly)
        XCTAssertTrue(evidence.reportConsumesReadModelOnly)
        XCTAssertTrue(evidence.dashboardConsumesViewModelOnly)
        XCTAssertTrue(evidence.eventTimelineConsumesReadModelOnly)
        XCTAssertFalse(evidence.exposesPersistenceSchema)
        XCTAssertFalse(evidence.readsAdapter)
        XCTAssertFalse(evidence.invokesRuntimeControl)
        XCTAssertFalse(evidence.providesCommandSurface)
        XCTAssertFalse(evidence.providesTradingButton)
        XCTAssertFalse(evidence.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(
            LiveExecutionControlBlockedEvidence.self,
            from: encoded
        )
        XCTAssertEqual(decoded, evidence)
    }

    func testLiveExecutionControlBlockedEvidenceRejectsMTP79CommandOrRuntimeBypass() throws {
        // 测试场景：MTP-79 的 read model 初始化和 Codable 解码都必须拒绝 schema、
        // adapter、runtime control、command surface、真实订单和交易按钮绕过。
        XCTAssertThrowsError(
            try LiveExecutionControlBlockedEvidence(providesCommandSurface: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesCommandSurface"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlBlockedEvidence(exposesPersistenceSchema: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesPersistenceSchema"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlBlockedEvidence(readsAdapter: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsAdapter"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlBlockedEvidence(invokesRuntimeControl: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("invokesRuntimeControl"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlBlockedEvidence(submitsRealOrder: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("submitsRealOrder"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlBlockedEvidence(consumesExecutionReport: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("consumesExecutionReport"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlBlockedEvidence(providesTradingButton: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesTradingButton"))
        }
        XCTAssertThrowsError(
            try LiveExecutionControlBlockedEvidence(
                blockedItems: Array(LiveExecutionControlBlockedEvidence.requiredBlockedItems.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "blockedItems",
                    expected: LiveExecutionControlBlockedEvidence
                        .requiredBlockedItems
                        .map(\.gate.rawValue)
                        .joined(separator: ","),
                    actual: Array(LiveExecutionControlBlockedEvidence.requiredBlockedItems.dropLast())
                        .map(\.gate.rawValue)
                        .joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveExecutionControlBlockedEvidence.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["providesCommandSurface"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveExecutionControlBlockedEvidence.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesCommandSurface"))
        }
    }

    func testLiveExecutionControlBlockedEvidenceSummarizesMTP79GateReasonsWithoutExecution() throws {
        // 测试场景：blocked evidence 必须逐项说明 submit / cancel / replace /
        // execution report / broker fill / reconciliation / incident fallback 为何仍被阻断。
        let evidence = LiveExecutionControlBlockedEvidence.deterministicFixture

        let submit = try XCTUnwrap(evidence.item(for: .submit))
        XCTAssertEqual(submit.blockedReasons, [
            .humanLiveDecisionMissing,
            .credentialEndpointBoundaryUnsatisfied,
            .signedCommandRequestForbidden,
            .brokerExecutionAdapterForbidden,
            .liveRiskOperationsAuditMissing
        ])
        XCTAssertTrue(submit.readModelOnlyBoundaryHeld)
        XCTAssertFalse(submit.canExecute)
        XCTAssertFalse(submit.emitsCommand)

        let executionReport = try XCTUnwrap(evidence.item(for: .executionReport))
        XCTAssertEqual(executionReport.blockedReasons, [
            .accountEndpointForbidden,
            .listenKeyUserDataStreamForbidden,
            .executionReportImplementationForbidden,
            .readModelOnlyBoundaryRequired
        ])
        XCTAssertFalse(executionReport.exposesSchema)
        XCTAssertFalse(executionReport.readsAdapter)

        let reconciliation = try XCTUnwrap(evidence.item(for: .reconciliation))
        XCTAssertEqual(reconciliation.blockedReasons, [
            .accountEndpointForbidden,
            .reconciliationRuntimeForbidden,
            .brokerPositionSyncForbidden,
            .readModelOnlyBoundaryRequired
        ])

        XCTAssertTrue(LiveSubmitCancelReplaceCommandBoundary.deterministicFixture.allRealOrderCommandsBlocked)
        XCTAssertTrue(
            LiveExecutionReportBrokerFillReconciliationBoundary
                .deterministicFixture
                .reportFillReconciliationImplementationBlocked
        )
        XCTAssertTrue(LivePaperRealCommandIsolationBoundary.deterministicFixture.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertTrue(evidence.forbiddenImplementationBoundaryHeld)
        XCTAssertFalse(evidence.submitsRealOrder)
        XCTAssertFalse(evidence.cancelsRealOrder)
        XCTAssertFalse(evidence.replacesRealOrder)
        XCTAssertFalse(evidence.recordsBrokerFill)
        XCTAssertFalse(evidence.performsReconciliation)
        XCTAssertFalse(evidence.executesIncidentFallback)
    }

    func testLiveRiskTerminologyDefinesMTP82FutureOnlyTaxonomy() throws {
        // 测试场景：MTP-82 只定义 Future Live Risk terminology 和 decision taxonomy。
        // fixture 必须能被稳定编码，并且所有真实账户、broker state、pre-trade runtime 和 UI 命令旗标保持关闭。
        let boundary = LiveRiskTerminologyBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-82-live-risk-terminology-boundary"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-82"))
        XCTAssertEqual(boundary.terms, LiveRiskTerm.allCases)
        XCTAssertEqual(boundary.decisionTaxonomy, [.allowed, .blocked, .degraded, .noTrade])
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveRiskDecision,
                .liveTradingFoundationBoundarySatisfied,
                .liveExecutionControlBoundarySatisfied,
                .exposureGateContractDefined,
                .orderNotionalGateContractDefined,
                .frequencyGateContractDefined,
                .lossDrawdownGateContractDefined,
                .circuitBreakerContractDefined,
                .noTradeStateContractDefined,
                .paperLiveRiskIsolationContractDefined,
                .readModelOnlyBlockedEvidenceDefined,
                .operationsAuditHandoffDefined
            ]
        )
        XCTAssertEqual(boundary.forbiddenCapabilities, LiveRiskForbiddenCapability.allCases)
        XCTAssertTrue(boundary.forbidsCapability(.realPreTradeRiskEngine))
        XCTAssertTrue(boundary.forbidsCapability(.realAccountBalanceRead))
        XCTAssertTrue(boundary.forbidsCapability(.brokerPositionSync))
        XCTAssertTrue(boundary.forbidsCapability(.paperRiskBlockerUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureUpgrade))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperLiveRiskIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-82-LIVE-RISK-TERMINOLOGY",
            "MTP-82-FUTURE-RISK-DECISION-TAXONOMY",
            "MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION",
            "MTP-82-NO-LIVE-RISK-RUNTIME",
            "MTP-82-LIVE-RISK-GATE-VALIDATION",
            "TVM-LIVE-RISK-GATE"
        ])
        XCTAssertEqual(boundary.paperIsolationSourceAnchors, [
            "TVM-RISK-BLOCKER",
            "TVM-PORTFOLIO-EXPOSURE",
            "TVM-PAPER-EXECUTION-DECISION",
            "TVM-PAPER-SIMULATED-FILL",
            "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE",
            "MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION"
        ])
        XCTAssertTrue(boundary.terminologyBoundaryHeld)
        XCTAssertTrue(boundary.futureRiskDecisionTaxonomyBoundaryHeld)
        XCTAssertTrue(boundary.paperLiveRiskIsolationBoundaryHeld)
        XCTAssertTrue(boundary.isFutureOnlyTerminology)
        XCTAssertFalse(boundary.providesLiveRiskEngine)
        XCTAssertFalse(boundary.readsAPIKey)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.instantiatesBrokerExecutionAdapter)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.readsRealAccountBalance)
        XCTAssertFalse(boundary.syncsBrokerPosition)
        XCTAssertFalse(boundary.readsMargin)
        XCTAssertFalse(boundary.readsLeverage)
        XCTAssertFalse(boundary.computesLiveExposureFromAccountState)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)
        XCTAssertFalse(boundary.runsCircuitBreaker)
        XCTAssertFalse(boundary.entersNoTradeState)
        XCTAssertFalse(boundary.authorizesLiveTrading)
        XCTAssertFalse(boundary.providesRiskCommandSurface)
        XCTAssertFalse(boundary.providesPositionManagementCommand)
        XCTAssertFalse(boundary.exposesOrderForm)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToFutureRiskDecision)
        XCTAssertFalse(boundary.mapsPaperExposureToRealAccountState)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(LiveRiskTerminologyBoundary.self, from: encoded)
        XCTAssertEqual(decoded, boundary)
    }

    func testLiveRiskTerminologyRejectsMTP82RuntimeAccountAndCommandBypass() throws {
        // 测试场景：MTP-82 fixture 的初始化和 Codable 解码必须拒绝真实风控引擎、
        // 账户 / 仓位读取、margin / leverage、pre-trade allow / reject 和 UI 命令绕过。
        XCTAssertThrowsError(
            try LiveRiskTerminologyBoundary(readsRealAccountBalance: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRealAccountBalance"))
        }
        XCTAssertThrowsError(
            try LiveRiskTerminologyBoundary(syncsBrokerPosition: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("syncsBrokerPosition"))
        }
        XCTAssertThrowsError(
            try LiveRiskTerminologyBoundary(readsMargin: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsMargin"))
        }
        XCTAssertThrowsError(
            try LiveRiskTerminologyBoundary(evaluatesRealPreTradeAllow: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("evaluatesRealPreTradeAllow")
            )
        }
        XCTAssertThrowsError(
            try LiveRiskTerminologyBoundary(evaluatesRealPreTradeReject: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("evaluatesRealPreTradeReject")
            )
        }
        XCTAssertThrowsError(
            try LiveRiskTerminologyBoundary(providesRiskCommandSurface: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesRiskCommandSurface"))
        }
        XCTAssertThrowsError(
            try LiveRiskTerminologyBoundary(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try LiveRiskTerminologyBoundary(implementsLiveExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("implementsLiveExecutionAdapter"))
        }
        XCTAssertThrowsError(
            try LiveRiskTerminologyBoundary(terms: Array(LiveRiskTerm.allCases.dropLast()))
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "terms",
                    expected: LiveRiskTerminologyBoundary.requiredTerms.map(\.rawValue).joined(separator: ","),
                    actual: Array(LiveRiskTerm.allCases.dropLast()).map(\.rawValue).joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveRiskTerminologyBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["providesTradingButton"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveRiskTerminologyBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesTradingButton"))
        }
    }

    func testPaperRiskBlockerAndExposureCannotUpgradeToMTP82FutureLiveRiskDecision() throws {
        // 测试场景：MTP-82 明确 paper risk blocker 和 paper exposure 只是本地 evidence，
        // 不能升级为 future live risk decision、真实账户状态、broker position 或 pre-trade runtime 输入。
        let boundary = LiveRiskTerminologyBoundary.deterministicFixture
        let riskQuery = try RiskEvaluationQuery(
            paperOrderID: try Identifier("paper-risk-order-mtp-82"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            proposedQuantity: try Quantity(1.25),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        let blocker = RiskBlockerEvidence(
            evidenceID: try Identifier("risk-blocker-mtp-82"),
            query: riskQuery,
            reason: .maxPaperQuantityExceeded,
            generatedAt: Date(timeIntervalSince1970: 2_200)
        )
        let exposure = PortfolioExposureSnapshot(
            portfolioID: try Identifier("portfolio-main"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            paperQuantity: try Quantity(1.25),
            referencePrice: try Price(42_000),
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 2_201)
        )

        XCTAssertTrue(boundary.paperLiveRiskIsolationBoundaryHeld)
        XCTAssertTrue(boundary.forbidsCapability(.paperRiskBlockerUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureUpgrade))
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToFutureRiskDecision)
        XCTAssertFalse(boundary.mapsPaperExposureToRealAccountState)
        XCTAssertFalse(boundary.computesLiveExposureFromAccountState)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)

        XCTAssertEqual(blocker.executionMode, .paper)
        XCTAssertEqual(blocker.paperOrderID, riskQuery.paperOrderID)
        XCTAssertEqual(blocker.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(exposure.source, .paperProjection)
        XCTAssertEqual(exposure.grossExposureNotional, 52_500, accuracy: 0.00000001)
        XCTAssertEqual(DomainEvent.risk(.blocked(blocker)), .risk(.blocked(blocker)))
        XCTAssertEqual(DomainEvent.portfolio(.exposureUpdated(exposure)), .portfolio(.exposureUpdated(exposure)))
    }

    func testLiveExposureOrderNotionalBoundaryDefinesMTP83FutureGatesAndForbiddenCapabilities() throws {
        // 测试场景：MTP-83 只定义 exposure / order notional 的 future gates 和
        // forbidden capability evidence，不读取真实账户、broker position、margin 或 leverage。
        let boundary = LiveExposureOrderNotionalGateBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-83-exposure-order-notional-boundary"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-83"))
        XCTAssertEqual(boundary.terms, [.exposureGate, .orderNotionalGate])
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveRiskDecision,
                .liveTradingFoundationBoundarySatisfied,
                .liveExecutionControlBoundarySatisfied,
                .accountStateSourceContractDefined,
                .brokerPositionSourceContractDefined,
                .marginLeverageSourceContractDefined,
                .exposureLimitPolicyDefined,
                .orderNotionalLimitPolicyDefined,
                .paperExposureIsolationDefined,
                .operationsAuditHandoffDefined
            ]
        )
        XCTAssertEqual(
            boundary.forbiddenCapabilities,
            LiveExposureOrderNotionalForbiddenCapability.allCases
        )
        XCTAssertTrue(boundary.forbidsCapability(.realAccountBalanceRead))
        XCTAssertTrue(boundary.forbidsCapability(.brokerPositionSync))
        XCTAssertTrue(boundary.forbidsCapability(.marginRead))
        XCTAssertTrue(boundary.forbidsCapability(.leverageRead))
        XCTAssertTrue(boundary.forbidsCapability(.realOrderNotionalLimitEvaluation))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperLiveRiskIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES",
            "MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS",
            "MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT",
            "MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE",
            "MTP-83-LIVE-RISK-GATE-VALIDATION",
            "TVM-LIVE-RISK-GATE"
        ])
        XCTAssertEqual(boundary.sourceAnchors, [
            "MTP-82-LIVE-RISK-TERMINOLOGY",
            "MTP-82-FUTURE-RISK-DECISION-TAXONOMY",
            "MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION",
            "TVM-PORTFOLIO-EXPOSURE",
            "TVM-RISK-BLOCKER",
            "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE"
        ])
        XCTAssertTrue(boundary.exposureOrderNotionalBoundaryHeld)
        XCTAssertTrue(boundary.accountPositionMarginLeverageBoundaryHeld)
        XCTAssertTrue(boundary.paperExposureIsolationBoundaryHeld)
        XCTAssertTrue(boundary.allPreTradeDecisionsBlocked)
        XCTAssertTrue(boundary.isFutureGateOnly)
        XCTAssertFalse(boundary.providesLiveRiskEngine)
        XCTAssertFalse(boundary.readsAPIKey)
        XCTAssertFalse(boundary.storesSecret)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.instantiatesBrokerExecutionAdapter)
        XCTAssertFalse(boundary.instantiatesExchangeExecutionAdapter)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.readsRealAccountBalance)
        XCTAssertFalse(boundary.syncsBrokerPosition)
        XCTAssertFalse(boundary.readsMargin)
        XCTAssertFalse(boundary.readsLeverage)
        XCTAssertFalse(boundary.computesLiveExposureFromAccountState)
        XCTAssertFalse(boundary.evaluatesRealOrderNotionalLimit)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)
        XCTAssertFalse(boundary.authorizesLiveTrading)
        XCTAssertFalse(boundary.submitsRealOrder)
        XCTAssertFalse(boundary.cancelsRealOrder)
        XCTAssertFalse(boundary.replacesRealOrder)
        XCTAssertFalse(boundary.mapsPaperExposureToLiveExposureGate)
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToFutureRiskDecision)
        XCTAssertFalse(boundary.providesRiskCommandSurface)
        XCTAssertFalse(boundary.providesPositionManagementCommand)
        XCTAssertFalse(boundary.exposesOrderForm)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveExposureOrderNotionalGateBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testLiveExposureOrderNotionalBoundaryRejectsMTP83AccountPositionMarginLeverageBypass() throws {
        // 测试场景：MTP-83 fixture 的初始化和 Codable 解码必须拒绝真实账户、
        // broker position、margin / leverage、真实订单 notional 决策和 UI 命令绕过。
        XCTAssertThrowsError(
            try LiveExposureOrderNotionalGateBoundary(readsRealAccountBalance: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRealAccountBalance"))
        }
        XCTAssertThrowsError(
            try LiveExposureOrderNotionalGateBoundary(syncsBrokerPosition: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("syncsBrokerPosition"))
        }
        XCTAssertThrowsError(
            try LiveExposureOrderNotionalGateBoundary(readsMargin: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsMargin"))
        }
        XCTAssertThrowsError(
            try LiveExposureOrderNotionalGateBoundary(readsLeverage: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsLeverage"))
        }
        XCTAssertThrowsError(
            try LiveExposureOrderNotionalGateBoundary(computesLiveExposureFromAccountState: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("computesLiveExposureFromAccountState")
            )
        }
        XCTAssertThrowsError(
            try LiveExposureOrderNotionalGateBoundary(evaluatesRealOrderNotionalLimit: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("evaluatesRealOrderNotionalLimit")
            )
        }
        XCTAssertThrowsError(
            try LiveExposureOrderNotionalGateBoundary(evaluatesRealPreTradeAllow: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("evaluatesRealPreTradeAllow")
            )
        }
        XCTAssertThrowsError(
            try LiveExposureOrderNotionalGateBoundary(terms: [.exposureGate])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "terms",
                    expected: LiveExposureOrderNotionalGateBoundary.requiredTerms.map(\.rawValue).joined(separator: ","),
                    actual: "exposure gate"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveExposureOrderNotionalGateBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["callsAccountEndpoint"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveExposureOrderNotionalGateBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("callsAccountEndpoint"))
        }
    }

    func testPaperExposureCannotUpgradeToMTP83FutureLiveExposureGateDecision() throws {
        // 测试场景：MTP-83 明确当前 portfolio exposure 仍是 paper projection read model，
        // 不能升级为 live exposure gate、真实账户 exposure、broker position 或 notional allow / reject。
        let boundary = LiveExposureOrderNotionalGateBoundary.deterministicFixture
        let exposure = PortfolioExposureSnapshot(
            portfolioID: try Identifier("portfolio-main"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            paperQuantity: try Quantity(1.5),
            referencePrice: try Price(30_000),
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 2_300)
        )

        XCTAssertTrue(boundary.paperExposureIsolationBoundaryHeld)
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperRiskBlockerUpgrade))
        XCTAssertFalse(boundary.mapsPaperExposureToLiveExposureGate)
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToFutureRiskDecision)
        XCTAssertFalse(boundary.readsRealAccountBalance)
        XCTAssertFalse(boundary.syncsBrokerPosition)
        XCTAssertFalse(boundary.computesLiveExposureFromAccountState)
        XCTAssertFalse(boundary.evaluatesRealOrderNotionalLimit)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)

        XCTAssertEqual(exposure.source, .paperProjection)
        XCTAssertEqual(exposure.grossExposureNotional, 45_000, accuracy: 0.00000001)
        XCTAssertEqual(DomainEvent.portfolio(.exposureUpdated(exposure)), .portfolio(.exposureUpdated(exposure)))
    }

    func testLiveFrequencyLossDrawdownBoundaryDefinesMTP84FutureGatesAndForbiddenCapabilities() throws {
        // 测试场景：MTP-84 只定义 frequency / loss / drawdown 的 future gates 和
        // forbidden capability evidence，不新增真实限频器、PnL reader、回撤控制或停机命令。
        let boundary = LiveFrequencyLossDrawdownGateBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-84-frequency-loss-drawdown-boundary"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-84"))
        XCTAssertEqual(boundary.terms, [.frequencyGate, .lossGate])
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveRiskDecision,
                .liveTradingFoundationBoundarySatisfied,
                .liveExecutionControlBoundarySatisfied,
                .frequencyWindowPolicyDefined,
                .orderEventSourceContractDefined,
                .pnlEquitySourceContractDefined,
                .lossLimitPolicyDefined,
                .drawdownLimitPolicyDefined,
                .paperRiskExposureIsolationDefined,
                .operationsAuditHandoffDefined
            ]
        )
        XCTAssertEqual(
            boundary.forbiddenCapabilities,
            LiveFrequencyLossDrawdownForbiddenCapability.allCases
        )
        XCTAssertTrue(boundary.forbidsCapability(.liveOrderFrequencyCounter))
        XCTAssertTrue(boundary.forbidsCapability(.productionFrequencyThrottling))
        XCTAssertTrue(boundary.forbidsCapability(.realPnLRead))
        XCTAssertTrue(boundary.forbidsCapability(.realAccountEquityRead))
        XCTAssertTrue(boundary.forbidsCapability(.realLossLimitEvaluation))
        XCTAssertTrue(boundary.forbidsCapability(.realDrawdownLimitEvaluation))
        XCTAssertTrue(boundary.forbidsCapability(.drawdownCircuitBreakerRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.stopTradingCommand))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperLiveRiskIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES",
            "MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS",
            "MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT",
            "MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE",
            "MTP-84-LIVE-RISK-GATE-VALIDATION",
            "TVM-LIVE-RISK-GATE"
        ])
        XCTAssertEqual(boundary.sourceAnchors, [
            "MTP-82-LIVE-RISK-TERMINOLOGY",
            "MTP-82-FUTURE-RISK-DECISION-TAXONOMY",
            "MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES",
            "TVM-RISK-BLOCKER",
            "TVM-PORTFOLIO-EXPOSURE",
            "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE"
        ])
        XCTAssertTrue(boundary.frequencyLossDrawdownBoundaryHeld)
        XCTAssertTrue(boundary.frequencyRuntimeBoundaryHeld)
        XCTAssertTrue(boundary.lossDrawdownRuntimeBoundaryHeld)
        XCTAssertTrue(boundary.paperRiskExposureIsolationBoundaryHeld)
        XCTAssertTrue(boundary.allPreTradeDecisionsBlocked)
        XCTAssertTrue(boundary.isFutureGateOnly)
        XCTAssertFalse(boundary.providesLiveRiskEngine)
        XCTAssertFalse(boundary.readsAPIKey)
        XCTAssertFalse(boundary.storesSecret)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.instantiatesBrokerExecutionAdapter)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.readsRealAccountBalance)
        XCTAssertFalse(boundary.syncsBrokerPosition)
        XCTAssertFalse(boundary.readsMargin)
        XCTAssertFalse(boundary.readsLeverage)
        XCTAssertFalse(boundary.readsRealPnL)
        XCTAssertFalse(boundary.readsRealAccountEquity)
        XCTAssertFalse(boundary.countsLiveOrderFrequency)
        XCTAssertFalse(boundary.enforcesFrequencyThrottle)
        XCTAssertFalse(boundary.evaluatesRealLossLimit)
        XCTAssertFalse(boundary.evaluatesRealDrawdownLimit)
        XCTAssertFalse(boundary.runsDrawdownCircuitBreaker)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)
        XCTAssertFalse(boundary.runsCircuitBreakerCommand)
        XCTAssertFalse(boundary.runsStopTradingCommand)
        XCTAssertFalse(boundary.runsEmergencyStopCommand)
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToFrequencyLossDrawdownGate)
        XCTAssertFalse(boundary.mapsPaperExposureToLossDrawdownGate)
        XCTAssertFalse(boundary.exposesOrderForm)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveFrequencyLossDrawdownGateBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testLiveFrequencyLossDrawdownBoundaryRejectsMTP84RuntimeBypass() throws {
        // 测试场景：MTP-84 fixture 的初始化和 Codable 解码必须拒绝真实频率计数、
        // 真实 PnL / equity 读取、loss / drawdown enforcement、熔断 / 停机命令和 UI 命令绕过。
        XCTAssertThrowsError(
            try LiveFrequencyLossDrawdownGateBoundary(countsLiveOrderFrequency: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("countsLiveOrderFrequency"))
        }
        XCTAssertThrowsError(
            try LiveFrequencyLossDrawdownGateBoundary(enforcesFrequencyThrottle: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("enforcesFrequencyThrottle"))
        }
        XCTAssertThrowsError(
            try LiveFrequencyLossDrawdownGateBoundary(readsRealPnL: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRealPnL"))
        }
        XCTAssertThrowsError(
            try LiveFrequencyLossDrawdownGateBoundary(readsRealAccountEquity: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRealAccountEquity"))
        }
        XCTAssertThrowsError(
            try LiveFrequencyLossDrawdownGateBoundary(evaluatesRealLossLimit: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("evaluatesRealLossLimit"))
        }
        XCTAssertThrowsError(
            try LiveFrequencyLossDrawdownGateBoundary(evaluatesRealDrawdownLimit: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("evaluatesRealDrawdownLimit"))
        }
        XCTAssertThrowsError(
            try LiveFrequencyLossDrawdownGateBoundary(runsDrawdownCircuitBreaker: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsDrawdownCircuitBreaker"))
        }
        XCTAssertThrowsError(
            try LiveFrequencyLossDrawdownGateBoundary(runsStopTradingCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsStopTradingCommand"))
        }
        XCTAssertThrowsError(
            try LiveFrequencyLossDrawdownGateBoundary(terms: [.frequencyGate])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "terms",
                    expected: LiveFrequencyLossDrawdownGateBoundary.requiredTerms.map(\.rawValue).joined(separator: ","),
                    actual: "frequency gate"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveFrequencyLossDrawdownGateBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["runsEmergencyStopCommand"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveFrequencyLossDrawdownGateBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsEmergencyStopCommand"))
        }
    }

    func testPaperRiskAndExposureCannotUpgradeToMTP84FrequencyLossDrawdownGateDecision() throws {
        // 测试场景：MTP-84 明确当前 paper risk blocker 和 portfolio exposure 仍是本地 evidence，
        // 不能升级为 live frequency gate、真实亏损 / 回撤 gate、PnL / equity 输入或 pre-trade runtime。
        let boundary = LiveFrequencyLossDrawdownGateBoundary.deterministicFixture
        let riskQuery = try RiskEvaluationQuery(
            paperOrderID: try Identifier("paper-risk-order-mtp-84"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            proposedQuantity: try Quantity(1.1),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        let blocker = RiskBlockerEvidence(
            evidenceID: try Identifier("risk-blocker-mtp-84"),
            query: riskQuery,
            reason: .maxPaperQuantityExceeded,
            generatedAt: Date(timeIntervalSince1970: 2_400)
        )
        let exposure = PortfolioExposureSnapshot(
            portfolioID: try Identifier("portfolio-main"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            paperQuantity: try Quantity(0.75),
            referencePrice: try Price(40_000),
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 2_401)
        )

        XCTAssertTrue(boundary.paperRiskExposureIsolationBoundaryHeld)
        XCTAssertTrue(boundary.forbidsCapability(.paperRiskBlockerUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureUpgrade))
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToFrequencyLossDrawdownGate)
        XCTAssertFalse(boundary.mapsPaperExposureToLossDrawdownGate)
        XCTAssertFalse(boundary.readsRealPnL)
        XCTAssertFalse(boundary.readsRealAccountEquity)
        XCTAssertFalse(boundary.countsLiveOrderFrequency)
        XCTAssertFalse(boundary.evaluatesRealLossLimit)
        XCTAssertFalse(boundary.evaluatesRealDrawdownLimit)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)

        XCTAssertEqual(blocker.executionMode, .paper)
        XCTAssertEqual(blocker.paperOrderID, riskQuery.paperOrderID)
        XCTAssertEqual(blocker.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(exposure.source, .paperProjection)
        XCTAssertEqual(exposure.grossExposureNotional, 30_000, accuracy: 0.00000001)
        XCTAssertEqual(DomainEvent.risk(.blocked(blocker)), .risk(.blocked(blocker)))
        XCTAssertEqual(DomainEvent.portfolio(.exposureUpdated(exposure)), .portfolio(.exposureUpdated(exposure)))
    }

    func testLiveCircuitBreakerNoTradeBoundaryDefinesMTP85FutureGatesAndForbiddenCapabilities() throws {
        // 测试场景：MTP-85 只定义 circuit breaker / no-trade state 的 future gates 和
        // forbidden capability evidence，不新增真实熔断 runtime、禁交易状态机、停机命令或 UI 交易控制。
        let boundary = LiveCircuitBreakerNoTradeGateBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-85-circuit-breaker-no-trade-boundary"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-85"))
        XCTAssertEqual(boundary.terms, [.circuitBreaker, .noTradeState])
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveRiskDecision,
                .liveTradingFoundationBoundarySatisfied,
                .liveExecutionControlBoundarySatisfied,
                .exposureOrderNotionalBoundarySatisfied,
                .frequencyLossDrawdownBoundarySatisfied,
                .circuitBreakerPolicyDefined,
                .circuitBreakerTriggerSourceContractDefined,
                .noTradeStatePolicyDefined,
                .noTradeStateTransitionPolicyDefined,
                .operationsAuditHandoffDefined
            ]
        )
        XCTAssertEqual(
            boundary.forbiddenCapabilities,
            LiveCircuitBreakerNoTradeForbiddenCapability.allCases
        )
        XCTAssertTrue(boundary.forbidsCapability(.circuitBreakerRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.noTradeStateRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.globalTradingLockRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.circuitBreakerCommand))
        XCTAssertTrue(boundary.forbidsCapability(.stopTradingCommand))
        XCTAssertTrue(boundary.forbidsCapability(.automaticRecoveryCommand))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperLiveRiskIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES",
            "MTP-85-FORBIDDEN-CIRCUIT-BREAKER-NO-TRADE-RUNTIME-TESTS",
            "MTP-85-NO-CIRCUIT-BREAKER-OR-NO-TRADE-STATE-RUNTIME",
            "MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE",
            "MTP-85-LIVE-RISK-GATE-VALIDATION",
            "TVM-LIVE-RISK-GATE"
        ])
        XCTAssertEqual(boundary.sourceAnchors, [
            "MTP-82-LIVE-RISK-TERMINOLOGY",
            "MTP-82-FUTURE-RISK-DECISION-TAXONOMY",
            "MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES",
            "MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES",
            "TVM-RISK-BLOCKER",
            "TVM-PORTFOLIO-EXPOSURE",
            "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE"
        ])
        XCTAssertTrue(boundary.circuitBreakerNoTradeBoundaryHeld)
        XCTAssertTrue(boundary.circuitBreakerRuntimeBoundaryHeld)
        XCTAssertTrue(boundary.noTradeStateRuntimeBoundaryHeld)
        XCTAssertTrue(boundary.operationsCommandBoundaryHeld)
        XCTAssertTrue(boundary.paperRiskExposureIsolationBoundaryHeld)
        XCTAssertTrue(boundary.allPreTradeDecisionsBlocked)
        XCTAssertTrue(boundary.isFutureGateOnly)
        XCTAssertFalse(boundary.providesLiveRiskEngine)
        XCTAssertFalse(boundary.readsAPIKey)
        XCTAssertFalse(boundary.storesSecret)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.instantiatesBrokerExecutionAdapter)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.readsRealAccountBalance)
        XCTAssertFalse(boundary.syncsBrokerPosition)
        XCTAssertFalse(boundary.readsMargin)
        XCTAssertFalse(boundary.readsLeverage)
        XCTAssertFalse(boundary.readsRealPnL)
        XCTAssertFalse(boundary.readsRealAccountEquity)
        XCTAssertFalse(boundary.evaluatesRealLossLimit)
        XCTAssertFalse(boundary.evaluatesRealDrawdownLimit)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)
        XCTAssertFalse(boundary.runsCircuitBreakerRuntime)
        XCTAssertFalse(boundary.entersNoTradeStateRuntime)
        XCTAssertFalse(boundary.mutatesNoTradeState)
        XCTAssertFalse(boundary.runsGlobalTradingLock)
        XCTAssertFalse(boundary.mutatesBrokerSessionState)
        XCTAssertFalse(boundary.runsCircuitBreakerCommand)
        XCTAssertFalse(boundary.runsStopTradingCommand)
        XCTAssertFalse(boundary.runsEmergencyStopCommand)
        XCTAssertFalse(boundary.runsAutomaticRecoveryCommand)
        XCTAssertFalse(boundary.controlsProductionShutdown)
        XCTAssertFalse(boundary.authorizesLiveTrading)
        XCTAssertFalse(boundary.submitsRealOrder)
        XCTAssertFalse(boundary.cancelsRealOrder)
        XCTAssertFalse(boundary.replacesRealOrder)
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToCircuitBreakerNoTradeGate)
        XCTAssertFalse(boundary.mapsPaperExposureToCircuitBreakerNoTradeGate)
        XCTAssertFalse(boundary.providesRiskCommandSurface)
        XCTAssertFalse(boundary.providesPositionManagementCommand)
        XCTAssertFalse(boundary.exposesOrderForm)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveCircuitBreakerNoTradeGateBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testLiveCircuitBreakerNoTradeBoundaryRejectsMTP85RuntimeCommandAndStateBypass() throws {
        // 测试场景：MTP-85 fixture 的初始化和 Codable 解码必须拒绝真实熔断 runtime、
        // no-trade 状态机、全局交易锁、broker session 变更、停机 / 恢复命令和 UI 命令绕过。
        XCTAssertThrowsError(
            try LiveCircuitBreakerNoTradeGateBoundary(runsCircuitBreakerRuntime: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsCircuitBreakerRuntime"))
        }
        XCTAssertThrowsError(
            try LiveCircuitBreakerNoTradeGateBoundary(entersNoTradeStateRuntime: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("entersNoTradeStateRuntime"))
        }
        XCTAssertThrowsError(
            try LiveCircuitBreakerNoTradeGateBoundary(runsGlobalTradingLock: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsGlobalTradingLock"))
        }
        XCTAssertThrowsError(
            try LiveCircuitBreakerNoTradeGateBoundary(mutatesBrokerSessionState: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("mutatesBrokerSessionState"))
        }
        XCTAssertThrowsError(
            try LiveCircuitBreakerNoTradeGateBoundary(runsStopTradingCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsStopTradingCommand"))
        }
        XCTAssertThrowsError(
            try LiveCircuitBreakerNoTradeGateBoundary(runsAutomaticRecoveryCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsAutomaticRecoveryCommand"))
        }
        XCTAssertThrowsError(
            try LiveCircuitBreakerNoTradeGateBoundary(terms: [.circuitBreaker])
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "terms",
                    expected: LiveCircuitBreakerNoTradeGateBoundary.requiredTerms.map(\.rawValue).joined(separator: ","),
                    actual: "circuit breaker"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveCircuitBreakerNoTradeGateBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["controlsProductionShutdown"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveCircuitBreakerNoTradeGateBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("controlsProductionShutdown"))
        }
    }

    func testPaperRiskAndExposureCannotUpgradeToMTP85CircuitBreakerNoTradeGateDecision() throws {
        // 测试场景：MTP-85 明确当前 paper risk blocker 和 portfolio exposure 仍是本地 evidence，
        // 不能升级为 live circuit breaker、no-trade 状态、真实账户状态或 pre-trade runtime。
        let boundary = LiveCircuitBreakerNoTradeGateBoundary.deterministicFixture
        let riskQuery = try RiskEvaluationQuery(
            paperOrderID: try Identifier("paper-risk-order-mtp-85"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            proposedQuantity: try Quantity(1.4),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        let blocker = RiskBlockerEvidence(
            evidenceID: try Identifier("risk-blocker-mtp-85"),
            query: riskQuery,
            reason: .maxPaperQuantityExceeded,
            generatedAt: Date(timeIntervalSince1970: 2_500)
        )
        let exposure = PortfolioExposureSnapshot(
            portfolioID: try Identifier("portfolio-main"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            paperQuantity: try Quantity(0.5),
            referencePrice: try Price(50_000),
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 2_501)
        )

        XCTAssertTrue(boundary.paperRiskExposureIsolationBoundaryHeld)
        XCTAssertTrue(boundary.forbidsCapability(.paperRiskBlockerUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureUpgrade))
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToCircuitBreakerNoTradeGate)
        XCTAssertFalse(boundary.mapsPaperExposureToCircuitBreakerNoTradeGate)
        XCTAssertFalse(boundary.runsCircuitBreakerRuntime)
        XCTAssertFalse(boundary.entersNoTradeStateRuntime)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)
        XCTAssertFalse(boundary.authorizesLiveTrading)

        XCTAssertEqual(blocker.executionMode, .paper)
        XCTAssertEqual(blocker.paperOrderID, riskQuery.paperOrderID)
        XCTAssertEqual(blocker.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(exposure.source, .paperProjection)
        XCTAssertEqual(exposure.grossExposureNotional, 25_000, accuracy: 0.00000001)
        XCTAssertEqual(DomainEvent.risk(.blocked(blocker)), .risk(.blocked(blocker)))
        XCTAssertEqual(DomainEvent.portfolio(.exposureUpdated(exposure)), .portfolio(.exposureUpdated(exposure)))
    }

    func testPaperRiskLiveDecisionIsolationBoundaryDefinesMTP86Contract() throws {
        // 测试场景：MTP-86 只定义 paper risk blocker / paper exposure 与 future live
        // risk decision 的隔离合同，不新增真实风控引擎、账户读取、allow / reject runtime 或 UI 命令。
        let boundary = LivePaperRiskLiveDecisionIsolationBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-86-paper-risk-live-decision-isolation-boundary"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-86"))
        XCTAssertEqual(
            boundary.evidenceSources,
            LivePaperRiskLiveDecisionIsolationEvidenceSource.allCases
        )
        XCTAssertEqual(
            boundary.forbiddenCapabilities,
            LivePaperRiskLiveDecisionForbiddenCapability.allCases
        )
        XCTAssertTrue(boundary.forbidsCapability(.futureRiskDecision))
        XCTAssertTrue(boundary.forbidsCapability(.realPreTradeAllow))
        XCTAssertTrue(boundary.forbidsCapability(.realPreTradeReject))
        XCTAssertTrue(boundary.forbidsCapability(.paperRiskBlockerToFutureRiskDecisionUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureToFutureRiskDecisionUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureToRealAccountExposureUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.riskCommandSurface))
        XCTAssertTrue(boundary.forbidsCapability(.tradingButton))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperLiveRiskIsolationEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT",
            "MTP-86-PAPER-RISK-EVIDENCE-NO-FUTURE-LIVE-RISK-DECISION",
            "MTP-86-PAPER-EXPOSURE-NO-REAL-ACCOUNT-RISK-INPUT",
            "MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY",
            "MTP-86-LIVE-RISK-GATE-VALIDATION",
            "TVM-LIVE-RISK-GATE"
        ])
        XCTAssertEqual(boundary.sourceAnchors, [
            "MTP-82-LIVE-RISK-TERMINOLOGY",
            "MTP-82-FUTURE-RISK-DECISION-TAXONOMY",
            "MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES",
            "MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES",
            "MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES",
            "TVM-RISK-BLOCKER",
            "TVM-PORTFOLIO-EXPOSURE",
            "TVM-PAPER-EXECUTION-DECISION",
            "TVM-REPORT-EVIDENCE",
            "MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE"
        ])
        XCTAssertTrue(boundary.isolationBoundaryHeld)
        XCTAssertTrue(boundary.paperRiskEvidenceCannotUpgradeToFutureRiskDecision)
        XCTAssertTrue(boundary.paperExposureCannotBecomeRealAccountRiskInput)
        XCTAssertTrue(boundary.futureLiveRiskDecisionCapabilitiesBlocked)
        XCTAssertTrue(boundary.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertTrue(boundary.isIsolationContractOnly)
        XCTAssertTrue(boundary.reportConsumesReadModelOnly)
        XCTAssertTrue(boundary.dashboardConsumesViewModelOnly)
        XCTAssertTrue(boundary.eventTimelineConsumesReadModelOnly)
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToFutureRiskDecision)
        XCTAssertFalse(boundary.mapsPaperExposureToFutureRiskDecision)
        XCTAssertFalse(boundary.mapsPaperRiskDecisionToRealPreTradeAllow)
        XCTAssertFalse(boundary.mapsPaperRiskDecisionToRealPreTradeReject)
        XCTAssertFalse(boundary.mapsPaperExposureToRealAccountExposure)
        XCTAssertFalse(boundary.mapsPaperExposureToBrokerPosition)
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToCircuitBreaker)
        XCTAssertFalse(boundary.mapsPaperExposureToNoTradeState)
        XCTAssertFalse(boundary.providesLiveRiskEngine)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)
        XCTAssertFalse(boundary.authorizesLiveTrading)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.readsRealAccountBalance)
        XCTAssertFalse(boundary.syncsBrokerPosition)
        XCTAssertFalse(boundary.readsMargin)
        XCTAssertFalse(boundary.readsLeverage)
        XCTAssertFalse(boundary.readsRealPnL)
        XCTAssertFalse(boundary.readsRealAccountEquity)
        XCTAssertFalse(boundary.providesRiskCommandSurface)
        XCTAssertFalse(boundary.providesPositionManagementCommand)
        XCTAssertFalse(boundary.exposesOrderForm)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LivePaperRiskLiveDecisionIsolationBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testPaperRiskLiveDecisionIsolationBoundaryRejectsMTP86UpgradeAndRuntimeBypass() throws {
        // 测试场景：MTP-86 fixture 的初始化和 Codable 解码必须拒绝 paper risk / exposure
        // 升级、真实 pre-trade allow / reject、账户读取、signed endpoint 和展示面命令绕过。
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(mapsPaperRiskBlockerToFutureRiskDecision: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsPaperRiskBlockerToFutureRiskDecision")
            )
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(mapsPaperExposureToFutureRiskDecision: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsPaperExposureToFutureRiskDecision")
            )
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(mapsPaperRiskDecisionToRealPreTradeAllow: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsPaperRiskDecisionToRealPreTradeAllow")
            )
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(mapsPaperExposureToRealAccountExposure: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsPaperExposureToRealAccountExposure")
            )
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(providesLiveRiskEngine: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesLiveRiskEngine"))
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(evaluatesRealPreTradeReject: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("evaluatesRealPreTradeReject"))
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(readsRealAccountBalance: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRealAccountBalance"))
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(providesRiskCommandSurface: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesRiskCommandSurface"))
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(reportConsumesReadModelOnly: false)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("reportConsumesReadModelOnly"))
        }
        XCTAssertThrowsError(
            try LivePaperRiskLiveDecisionIsolationBoundary(
                evidenceSources: Array(LivePaperRiskLiveDecisionIsolationEvidenceSource.allCases.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "evidenceSources",
                    expected: LivePaperRiskLiveDecisionIsolationBoundary
                        .requiredEvidenceSources
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: Array(LivePaperRiskLiveDecisionIsolationEvidenceSource.allCases.dropLast())
                        .map(\.rawValue)
                        .joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(LivePaperRiskLiveDecisionIsolationBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["mapsPaperExposureToNoTradeState"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LivePaperRiskLiveDecisionIsolationBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsPaperExposureToNoTradeState")
            )
        }
    }

    func testPaperRiskBlockerAndExposureCannotUpgradeToMTP86FutureLiveRiskDecision() throws {
        // 测试场景：MTP-86 明确当前 RiskBlockerEvidence 和 PortfolioExposureSnapshot
        // 仍是 paper-only / read-model evidence，不能升级为 live allow / reject、真实账户
        // 风险输入、circuit breaker trigger 或 no-trade state trigger。
        let boundary = LivePaperRiskLiveDecisionIsolationBoundary.deterministicFixture
        let riskQuery = try RiskEvaluationQuery(
            paperOrderID: try Identifier("paper-risk-order-mtp-86"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            proposedQuantity: try Quantity(1.6),
            riskProfileID: try Identifier("paper-risk"),
            executionMode: .paper
        )
        let blocker = RiskBlockerEvidence(
            evidenceID: try Identifier("risk-blocker-mtp-86"),
            query: riskQuery,
            reason: .maxPaperQuantityExceeded,
            generatedAt: Date(timeIntervalSince1970: 2_600)
        )
        let exposure = PortfolioExposureSnapshot(
            portfolioID: try Identifier("portfolio-main"),
            symbol: try Symbol(rawValue: "BTCUSDT"),
            timeframe: .oneMinute,
            paperQuantity: try Quantity(0.6),
            referencePrice: try Price(60_000),
            source: .paperProjection,
            observedAt: Date(timeIntervalSince1970: 2_601)
        )

        XCTAssertTrue(boundary.paperRiskEvidenceCannotUpgradeToFutureRiskDecision)
        XCTAssertTrue(boundary.paperExposureCannotBecomeRealAccountRiskInput)
        XCTAssertTrue(boundary.futureLiveRiskDecisionCapabilitiesBlocked)
        XCTAssertTrue(boundary.forbidsCapability(.futureRiskDecision))
        XCTAssertTrue(boundary.forbidsCapability(.paperRiskBlockerToFutureRiskDecisionUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureToFutureRiskDecisionUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperRiskDecisionToRealAllowRejectUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureToRealAccountExposureUpgrade))
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToFutureRiskDecision)
        XCTAssertFalse(boundary.mapsPaperExposureToFutureRiskDecision)
        XCTAssertFalse(boundary.mapsPaperRiskDecisionToRealPreTradeAllow)
        XCTAssertFalse(boundary.mapsPaperRiskDecisionToRealPreTradeReject)
        XCTAssertFalse(boundary.mapsPaperExposureToRealAccountExposure)
        XCTAssertFalse(boundary.mapsPaperExposureToBrokerPosition)
        XCTAssertFalse(boundary.mapsPaperRiskBlockerToCircuitBreaker)
        XCTAssertFalse(boundary.mapsPaperExposureToNoTradeState)
        XCTAssertFalse(boundary.evaluatesRealPreTradeAllow)
        XCTAssertFalse(boundary.evaluatesRealPreTradeReject)
        XCTAssertFalse(boundary.authorizesLiveTrading)

        XCTAssertEqual(blocker.executionMode, .paper)
        XCTAssertEqual(blocker.paperOrderID, riskQuery.paperOrderID)
        XCTAssertEqual(blocker.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(exposure.source, .paperProjection)
        XCTAssertEqual(exposure.grossExposureNotional, 36_000, accuracy: 0.00000001)
        XCTAssertEqual(DomainEvent.risk(.blocked(blocker)), .risk(.blocked(blocker)))
        XCTAssertEqual(DomainEvent.portfolio(.exposureUpdated(exposure)), .portfolio(.exposureUpdated(exposure)))
    }

    func testLiveRuntimeHealthDefinesMTP69ReadModelOnlyFixture() throws {
        // 测试场景：MTP-69 只新增 future live runtime health / connection status 的最小
        // read model。fixture 可以表达 healthy / blocked / disconnected / degraded /
        // unavailable 状态分类，但默认仍是 blocked / disconnected / unavailable evidence。
        let health = LiveRuntimeHealthReadModel.deterministicFixture

        XCTAssertEqual(health.healthID, try Identifier("mtp-69-live-runtime-health"))
        XCTAssertEqual(health.issueID, try Identifier("MTP-69"))
        XCTAssertEqual(health.status, .blocked)
        XCTAssertEqual(
            LiveMonitoringStatus.allCases,
            [.healthy, .blocked, .disconnected, .degraded, .unavailable]
        )
        XCTAssertEqual(health.allowedStatuses, LiveMonitoringStatus.allCases)
        XCTAssertEqual(health.sourceAnchors, LiveRuntimeHealthReadModel.requiredSourceAnchors)
        XCTAssertEqual(health.connections, LiveRuntimeHealthReadModel.requiredConnectionStatuses)
        XCTAssertEqual(
            health.connections.map(\.connectionKind),
            [.publicMarketData, .futurePrivateUserData, .futureBrokerSession]
        )
        XCTAssertEqual(health.connections.map(\.status), [.disconnected, .blocked, .unavailable])
        XCTAssertTrue(health.runtimeHealthBoundaryHeld)
        XCTAssertTrue(health.connectionStatusBoundaryHeld)
        XCTAssertTrue(health.isReadModelOnly)
        XCTAssertFalse(health.providesCommandSurface)
        XCTAssertFalse(health.startsLiveRuntime)
        XCTAssertFalse(health.stopsLiveRuntime)
        XCTAssertFalse(health.pollsRuntimeHealth)
        XCTAssertFalse(health.opensNetworkConnection)
        XCTAssertFalse(health.readsAPIKey)
        XCTAssertFalse(health.readsSecret)
        XCTAssertFalse(health.callsSignedEndpoint)
        XCTAssertFalse(health.callsAccountEndpoint)
        XCTAssertFalse(health.createsListenKey)
        XCTAssertFalse(health.readsAccountPayload)
        XCTAssertFalse(health.instantiatesBrokerAdapter)
        XCTAssertFalse(health.exposesAdapterSurface)
        XCTAssertFalse(health.exposesRuntimeObject)
        XCTAssertFalse(health.exposesSQLiteSchema)
        XCTAssertFalse(health.exposesDuckDBSchema)
        XCTAssertFalse(health.authorizesLiveTrading)
        XCTAssertFalse(health.authorizesTradingExecution)
        XCTAssertFalse(health.requiredValidationDependsOnNetwork)

        for connection in health.connections {
            XCTAssertTrue(connection.connectionBoundaryHeld)
            XCTAssertTrue(connection.isReadModelOnly)
            XCTAssertTrue(connection.isFutureEvidence)
            XCTAssertFalse(connection.hasActiveNetworkConnection)
            XCTAssertFalse(connection.opensWebSocket)
            XCTAssertFalse(connection.usesPrivateWebSocket)
            XCTAssertFalse(connection.callsSignedEndpoint)
            XCTAssertFalse(connection.callsAccountEndpoint)
            XCTAssertFalse(connection.createsListenKey)
            XCTAssertFalse(connection.readsAPIKey)
            XCTAssertFalse(connection.readsSecret)
            XCTAssertFalse(connection.readsAccountPayload)
            XCTAssertFalse(connection.instantiatesBrokerAdapter)
            XCTAssertFalse(connection.exposesAdapterSurface)
            XCTAssertFalse(connection.exposesRuntimeObject)
            XCTAssertFalse(connection.exposesSQLiteSchema)
            XCTAssertFalse(connection.exposesDuckDBSchema)
            XCTAssertFalse(connection.providesReconnectCommand)
            XCTAssertFalse(connection.providesStartStopCommand)
            XCTAssertFalse(connection.authorizesLiveTrading)
            XCTAssertFalse(connection.authorizesTradingExecution)
        }

        let encoded = try JSONEncoder().encode(health)
        let decoded = try JSONDecoder().decode(LiveRuntimeHealthReadModel.self, from: encoded)
        XCTAssertEqual(decoded, health)
    }

    func testLiveRuntimeHealthRejectsMTP69CommandNetworkSecretAndSchemaBypass() throws {
        // 测试场景：MTP-69 read model 的初始化和 Codable 解码都必须拒绝 command surface、
        // runtime polling、真实网络连接、secret/account payload、broker adapter 和 schema 暴露。
        XCTAssertThrowsError(
            try LiveRuntimeHealthReadModel(providesCommandSurface: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("providesCommandSurface"))
        }
        XCTAssertThrowsError(
            try LiveRuntimeHealthReadModel(opensNetworkConnection: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("opensNetworkConnection"))
        }
        XCTAssertThrowsError(
            try LiveRuntimeHealthReadModel(readsAPIKey: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("readsAPIKey"))
        }
        XCTAssertThrowsError(
            try LiveRuntimeHealthReadModel(exposesRuntimeObject: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("exposesRuntimeObject"))
        }
        XCTAssertThrowsError(
            try LiveRuntimeHealthReadModel(
                connections: Array(LiveRuntimeHealthReadModel.requiredConnectionStatuses.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleContractMismatch(
                    field: "connections",
                    expected: LiveRuntimeHealthReadModel.requiredConnectionStatuses
                        .map(\.connectionKind.rawValue)
                        .joined(separator: ","),
                    actual: Array(LiveRuntimeHealthReadModel.requiredConnectionStatuses.dropLast())
                        .map(\.connectionKind.rawValue)
                        .joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveRuntimeHealthReadModel.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["callsAccountEndpoint"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveRuntimeHealthReadModel.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("callsAccountEndpoint"))
        }
    }

    func testLiveConnectionStatusKeepsMTP69ConnectionEvidenceNonExecutable() throws {
        // 测试场景：connection status 只能是 read-model-only evidence。即使描述 public 或
        // future private / broker connection，也不能打开 WebSocket、创建 listenKey 或触发 reconnect。
        let privateConnection = try LiveConnectionStatusReadModel(
            connectionID: try Identifier("mtp-69-private-user-data-blocked"),
            connectionKind: .futurePrivateUserData,
            status: .blocked
        )

        XCTAssertTrue(privateConnection.connectionBoundaryHeld)
        XCTAssertEqual(privateConnection.sourceAnchors, [
            "MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY",
            "MTP-68-LIVE-MONITORING-READ-MODEL-ONLY",
            "MTP-69-CONNECTION-STATUS-READ-MODEL"
        ])

        XCTAssertThrowsError(
            try LiveConnectionStatusReadModel(
                connectionID: try Identifier("mtp-69-private-user-data-blocked"),
                connectionKind: .futurePrivateUserData,
                status: .blocked,
                sourceAnchors: ["wrong-anchor"]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleContractMismatch(
                    field: "sourceAnchors",
                    expected: [
                        "MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY",
                        "MTP-68-LIVE-MONITORING-READ-MODEL-ONLY",
                        "MTP-69-CONNECTION-STATUS-READ-MODEL"
                    ].joined(separator: ","),
                    actual: "wrong-anchor"
                )
            )
        }
        XCTAssertThrowsError(
            try LiveConnectionStatusReadModel(
                connectionID: try Identifier("mtp-69-public-market-disconnected"),
                connectionKind: .publicMarketData,
                status: .disconnected,
                hasActiveNetworkConnection: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("hasActiveNetworkConnection"))
        }

        let encoded = try JSONEncoder().encode(privateConnection)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["createsListenKey"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveConnectionStatusReadModel.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("createsListenKey"))
        }
    }

    func testLiveStreamMonitoringEvidenceDefinesMTP70MarketAndOrderStreamFixture() throws {
        // 测试场景：MTP-70 只新增 market stream / order stream 的只读 evidence read model。
        // market stream 只能是 public read-only / fixture evidence；order stream 只能是 blocked、
        // simulated 或 future evidence，不能被解释成真实订单状态机。
        let readModel = LiveStreamMonitoringEvidenceReadModel.deterministicFixture

        XCTAssertEqual(readModel.readModelID, try Identifier("mtp-70-live-stream-monitoring-evidence"))
        XCTAssertEqual(readModel.issueID, try Identifier("MTP-70"))
        XCTAssertEqual(readModel.runtimeHealth, LiveRuntimeHealthReadModel.deterministicFixture)
        XCTAssertEqual(readModel.sourceAnchors, LiveStreamMonitoringEvidenceReadModel.requiredSourceAnchors)
        XCTAssertEqual(readModel.streamEvidence, LiveStreamMonitoringEvidenceReadModel.requiredStreamEvidence)
        XCTAssertEqual(
            readModel.streamEvidence.map(\.streamKind),
            [.publicMarketStream, .blockedOrderStream, .simulatedOrderStream, .futureOrderStream]
        )
        XCTAssertEqual(
            readModel.streamEvidence.map(\.status),
            [.disconnected, .blocked, .blocked, .unavailable]
        )
        XCTAssertEqual(
            readModel.streamEvidence.map(\.evidenceKind),
            [
                .publicReadOnlyMarketEvidence,
                .blockedOrderStreamEvidence,
                .simulatedPaperOrderEvidence,
                .futureOrderStreamGate
            ]
        )
        XCTAssertEqual(readModel.marketStreamEvidenceCount, 1)
        XCTAssertEqual(readModel.orderStreamEvidenceCount, 3)
        XCTAssertEqual(
            readModel.orderStreamEvidenceKinds,
            [
                .blockedOrderStreamEvidence,
                .simulatedPaperOrderEvidence,
                .futureOrderStreamGate
            ]
        )
        XCTAssertTrue(readModel.streamEvidenceBoundaryHeld)
        XCTAssertTrue(readModel.orderStreamEvidenceBoundaryHeld)
        XCTAssertTrue(readModel.readModelOnlyBoundaryHeld)
        XCTAssertFalse(readModel.opensMarketWebSocket)
        XCTAssertFalse(readModel.opensPrivateUserDataStream)
        XCTAssertFalse(readModel.callsAccountEndpoint)
        XCTAssertFalse(readModel.createsListenKey)
        XCTAssertFalse(readModel.consumesExecutionReport)
        XCTAssertFalse(readModel.recordsBrokerFill)
        XCTAssertFalse(readModel.implementsRealOrderStateMachine)
        XCTAssertFalse(readModel.providesOrderCommand)
        XCTAssertFalse(readModel.submitsRealOrder)
        XCTAssertFalse(readModel.authorizesTradingExecution)

        let encoded = try JSONEncoder().encode(readModel)
        let decoded = try JSONDecoder().decode(LiveStreamMonitoringEvidenceReadModel.self, from: encoded)
        XCTAssertEqual(decoded, readModel)
    }

    func testLiveStreamMonitoringEvidenceRejectsMTP70ListenKeyAccountBrokerAndRealOrderBypass() throws {
        // 测试场景：MTP-70 fixture 的初始化和 Codable 解码必须拒绝 listenKey、
        // account endpoint、broker fill、execution report、真实订单状态机和 order command。
        XCTAssertThrowsError(
            try LiveStreamMonitoringEvidenceReadModel(createsListenKey: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("createsListenKey"))
        }
        XCTAssertThrowsError(
            try LiveStreamMonitoringEvidenceReadModel(consumesExecutionReport: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleForbiddenCapability("consumesExecutionReport")
            )
        }
        XCTAssertThrowsError(
            try LiveStreamMonitoringEvidenceReadModel(implementsRealOrderStateMachine: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleForbiddenCapability("implementsRealOrderStateMachine")
            )
        }
        XCTAssertThrowsError(
            try LiveStreamMonitoringEvidenceReadModel(
                streamEvidence: Array(LiveStreamMonitoringEvidenceReadModel.requiredStreamEvidence.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleContractMismatch(
                    field: "streamEvidence",
                    expected: LiveStreamMonitoringEvidenceReadModel.requiredStreamEvidence
                        .map(\.streamKind.rawValue)
                        .joined(separator: ","),
                    actual: Array(LiveStreamMonitoringEvidenceReadModel.requiredStreamEvidence.dropLast())
                        .map(\.streamKind.rawValue)
                        .joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveStreamMonitoringEvidenceReadModel.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["callsAccountEndpoint"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveStreamMonitoringEvidenceReadModel.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("callsAccountEndpoint"))
        }
    }

    func testLiveOrderStreamEvidenceKeepsMTP70BlockedSimulatedFutureOnly() throws {
        // 测试场景：订单流 evidence 必须固定为 blocked / simulated / future-only。
        // simulated 只能引用 paper order / simulated fill evidence，不得升级为 execution report、
        // broker fill、真实账户更新或 real order lifecycle。
        let readModel = LiveStreamMonitoringEvidenceReadModel.deterministicFixture
        let orderStreamEvidence = readModel.streamEvidence.filter(\.isOrderStreamEvidence)
        let simulated = try XCTUnwrap(
            orderStreamEvidence.first { $0.streamKind == .simulatedOrderStream }
        )

        XCTAssertEqual(orderStreamEvidence.count, 3)
        XCTAssertEqual(orderStreamEvidence.map(\.streamKind), [
            .blockedOrderStream,
            .simulatedOrderStream,
            .futureOrderStream
        ])
        XCTAssertEqual(
            simulated.paperEvidenceIDs,
            [
                try Identifier("paper-replay-order-allowed"),
                try Identifier("paper-replay-fill-allowed")
            ]
        )
        XCTAssertTrue(orderStreamEvidence.allSatisfy(\.streamBoundaryHeld))
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.isReadModelOnly })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.hasActiveOrderStream == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.opensPrivateUserDataStream == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.createsListenKey == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.callsAccountEndpoint == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.consumesExecutionReport == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.recordsBrokerFill == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.implementsRealOrderStateMachine == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.providesOrderCommand == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.submitsRealOrder == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.cancelsRealOrder == false })
        XCTAssertTrue(orderStreamEvidence.allSatisfy { $0.replacesRealOrder == false })

        XCTAssertThrowsError(
            try LiveStreamMonitoringEvidenceItem(
                streamID: try Identifier("mtp-70-order-stream-simulated-paper-evidence"),
                streamKind: .simulatedOrderStream,
                status: .blocked,
                evidenceKind: .simulatedPaperOrderEvidence,
                paperEvidenceIDs: []
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleContractMismatch(
                    field: "paperEvidenceIDs",
                    expected: "paper-replay-order-allowed,paper-replay-fill-allowed",
                    actual: ""
                )
            )
        }
    }

    func testLiveLatencyErrorDegradedEvidenceDefinesMTP71DeterministicFixture() throws {
        // 测试场景：MTP-71 只新增 latency / error / degraded state 的 deterministic
        // monitoring evidence read model。该 fixture 只供后续 Dashboard / Report 消费，
        // 不采集生产 telemetry，不触发 alert / reconnect / stop control。
        let readModel = LiveLatencyErrorDegradedMonitoringEvidenceReadModel.deterministicFixture

        XCTAssertEqual(readModel.readModelID, try Identifier("mtp-71-live-latency-error-degraded-evidence"))
        XCTAssertEqual(readModel.issueID, try Identifier("MTP-71"))
        XCTAssertEqual(readModel.streamEvidence, LiveStreamMonitoringEvidenceReadModel.deterministicFixture)
        XCTAssertEqual(
            readModel.sourceAnchors,
            LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredSourceAnchors
        )
        XCTAssertEqual(
            readModel.latencyEvidence,
            LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredLatencyEvidence
        )
        XCTAssertEqual(
            readModel.errorEvidence,
            LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredErrorEvidence
        )
        XCTAssertEqual(
            readModel.degradedStateEvidence,
            LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredDegradedStateEvidence
        )
        XCTAssertEqual(readModel.latencyEvidence.map(\.scope), [
            .runtimeHealth,
            .publicMarketStream,
            .simulatedOrderStream,
            .futurePrivateUserData,
            .futureBrokerSession
        ])
        XCTAssertEqual(readModel.latencyBuckets, [.stale, .degraded, .nominal, .unavailable, .unavailable])
        XCTAssertEqual(readModel.errorEvidence.map(\.status), [.disconnected, .blocked, .unavailable])
        XCTAssertEqual(readModel.degradedStateEvidence.map(\.scope), [.publicMarketStream, .futureBrokerSession])
        XCTAssertEqual(readModel.degradedStateStatuses, [.degraded, .unavailable])
        XCTAssertEqual(readModel.errorCodes, [
            "MTP71_PUBLIC_MARKET_STREAM_DISCONNECTED",
            "MTP71_PRIVATE_USER_DATA_BLOCKED",
            "MTP71_BROKER_SESSION_UNAVAILABLE"
        ])
        XCTAssertTrue(readModel.latencyEvidenceBoundaryHeld)
        XCTAssertTrue(readModel.errorEvidenceBoundaryHeld)
        XCTAssertTrue(readModel.degradedStateBoundaryHeld)
        XCTAssertTrue(readModel.readModelOnlyBoundaryHeld)
        XCTAssertFalse(readModel.usesProductionTelemetry)
        XCTAssertFalse(readModel.usesExternalMetricsService)
        XCTAssertFalse(readModel.startsRuntimeMonitor)
        XCTAssertFalse(readModel.pollsProductionRuntime)
        XCTAssertFalse(readModel.opensNetworkConnection)
        XCTAssertFalse(readModel.providesAlertingCommand)
        XCTAssertFalse(readModel.providesPagingCommand)
        XCTAssertFalse(readModel.providesReconnectCommand)
        XCTAssertFalse(readModel.providesStopControl)
        XCTAssertFalse(readModel.providesLiveRiskControl)
        XCTAssertFalse(readModel.triggersIncidentCommand)
        XCTAssertFalse(readModel.triggersAutoRecovery)
        XCTAssertFalse(readModel.callsSignedEndpoint)
        XCTAssertFalse(readModel.callsAccountEndpoint)
        XCTAssertFalse(readModel.createsListenKey)
        XCTAssertFalse(readModel.authorizesLiveTrading)
        XCTAssertFalse(readModel.authorizesTradingExecution)
        XCTAssertFalse(readModel.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(readModel)
        let decoded = try JSONDecoder().decode(
            LiveLatencyErrorDegradedMonitoringEvidenceReadModel.self,
            from: encoded
        )
        XCTAssertEqual(decoded, readModel)
    }

    func testLiveLatencyErrorDegradedEvidenceRejectsMTP71ProductionTelemetryAndCommands() throws {
        // 测试场景：MTP-71 聚合 read model 的初始化和 Codable 解码必须拒绝 production
        // telemetry、external metrics、alert / paging、reconnect / stop control 和 signed endpoint。
        XCTAssertThrowsError(
            try LiveLatencyErrorDegradedMonitoringEvidenceReadModel(usesProductionTelemetry: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleForbiddenCapability("usesProductionTelemetry")
            )
        }
        XCTAssertThrowsError(
            try LiveLatencyErrorDegradedMonitoringEvidenceReadModel(usesExternalMetricsService: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleForbiddenCapability("usesExternalMetricsService")
            )
        }
        XCTAssertThrowsError(
            try LiveLatencyErrorDegradedMonitoringEvidenceReadModel(providesStopControl: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("providesStopControl"))
        }
        XCTAssertThrowsError(
            try LiveLatencyErrorDegradedMonitoringEvidenceReadModel(providesReconnectCommand: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleForbiddenCapability("providesReconnectCommand")
            )
        }
        XCTAssertThrowsError(
            try LiveLatencyErrorDegradedMonitoringEvidenceReadModel(
                latencyEvidence: Array(
                    LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredLatencyEvidence.dropLast()
                )
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleContractMismatch(
                    field: "latencyEvidence",
                    expected: LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredLatencyEvidence
                        .map(\.scope.rawValue)
                        .joined(separator: ","),
                    actual: Array(
                        LiveLatencyErrorDegradedMonitoringEvidenceReadModel.requiredLatencyEvidence.dropLast()
                    )
                        .map(\.scope.rawValue)
                        .joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(
            LiveLatencyErrorDegradedMonitoringEvidenceReadModel.deterministicFixture
        )
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["callsSignedEndpoint"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveLatencyErrorDegradedMonitoringEvidenceReadModel.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("callsSignedEndpoint"))
        }
    }

    func testLiveMonitoringDegradedStateKeepsMTP71ReadModelOnlyNoRecoveryCommands() throws {
        // 测试场景：degraded / unavailable state 只能把 latency 和 error evidence 串成只读摘要。
        // 它不能绕过 risk gate、继续真实订单、触发 incident command、自动恢复或 stop control。
        let readModel = LiveLatencyErrorDegradedMonitoringEvidenceReadModel.deterministicFixture
        let marketDegraded = try XCTUnwrap(
            readModel.degradedStateEvidence.first { $0.scope == .publicMarketStream }
        )
        let brokerUnavailable = try XCTUnwrap(
            readModel.degradedStateEvidence.first { $0.scope == .futureBrokerSession }
        )

        XCTAssertTrue(marketDegraded.degradedStateBoundaryHeld)
        XCTAssertEqual(marketDegraded.status, .degraded)
        XCTAssertEqual(marketDegraded.contributingLatencyEvidenceIDs, [
            try Identifier("mtp-71-public-market-stream-latency-degraded")
        ])
        XCTAssertEqual(marketDegraded.contributingErrorEvidenceIDs, [
            try Identifier("mtp-71-public-market-stream-error-disconnected")
        ])
        XCTAssertTrue(brokerUnavailable.degradedStateBoundaryHeld)
        XCTAssertEqual(brokerUnavailable.status, .unavailable)
        XCTAssertEqual(brokerUnavailable.contributingLatencyEvidenceIDs, [
            try Identifier("mtp-71-broker-session-latency-unavailable")
        ])
        XCTAssertEqual(brokerUnavailable.contributingErrorEvidenceIDs, [
            try Identifier("mtp-71-broker-session-error-unavailable")
        ])
        XCTAssertTrue(readModel.degradedStateEvidence.allSatisfy { $0.isReadModelOnly })
        XCTAssertTrue(readModel.degradedStateEvidence.allSatisfy { $0.bypassesRiskGate == false })
        XCTAssertTrue(readModel.degradedStateEvidence.allSatisfy { $0.continuesRealOrders == false })
        XCTAssertTrue(readModel.degradedStateEvidence.allSatisfy { $0.triggersIncidentCommand == false })
        XCTAssertTrue(readModel.degradedStateEvidence.allSatisfy { $0.triggersAutoRecovery == false })
        XCTAssertTrue(readModel.degradedStateEvidence.allSatisfy { $0.providesStopControl == false })
        XCTAssertTrue(readModel.degradedStateEvidence.allSatisfy { $0.providesLiveRiskControl == false })
        XCTAssertTrue(readModel.degradedStateEvidence.allSatisfy { $0.authorizesTradingExecution == false })

        XCTAssertThrowsError(
            try LiveMonitoringDegradedStateEvidenceItem(
                stateID: try Identifier("mtp-71-public-market-stream-degraded"),
                scope: .publicMarketStream,
                sourceAnchors: ["wrong-anchor"]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveMonitoringConsoleContractMismatch(
                    field: "sourceAnchors",
                    expected: [
                        "MTP-70-MARKET-STREAM-PUBLIC-READ-ONLY-EVIDENCE",
                        "MTP-71-DEGRADED-STATE-READ-MODEL"
                    ].joined(separator: ","),
                    actual: "wrong-anchor"
                )
            )
        }
        XCTAssertThrowsError(
            try LiveMonitoringDegradedStateEvidenceItem(
                stateID: try Identifier("mtp-71-public-market-stream-degraded"),
                scope: .publicMarketStream,
                triggersAutoRecovery: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveMonitoringConsoleForbiddenCapability("triggersAutoRecovery"))
        }
    }

    func testPaperSessionLocalControlCommandModelSupportsSessionActionsDeterministically() throws {
        // 测试场景：MTP-48 只允许本地 Paper session-level control intent。
        // 四个 control 都必须保持 paper-only，且不能携带 order-level、broker 或真实订单能力。
        let commands = try PaperSessionLocalControlCommandFixture.allDeterministic()

        XCTAssertEqual(PaperSessionLocalControlAction.allCases, [.start, .pause, .close, .reset])
        XCTAssertEqual(commands.map(\.control), [.start, .pause, .close, .reset])
        XCTAssertEqual(
            commands.map { $0.commandID.rawValue },
            [
                "paper-session-local-control-start",
                "paper-session-local-control-pause",
                "paper-session-local-control-close",
                "paper-session-local-control-reset"
            ]
        )

        for command in commands {
            XCTAssertEqual(command.sessionID, try Identifier("paper-session-fixture"))
            XCTAssertEqual(command.scope, .localPaperSession)
            XCTAssertEqual(command.controlLevel, .session)
            XCTAssertEqual(command.executionMode, .paper)
            XCTAssertEqual(command.requestedAt.timeIntervalSince1970, 3_200)
            XCTAssertTrue(command.isSessionLevelLocalPaperControl)
            XCTAssertTrue(command.paperOnlyBoundaryHeld)
            XCTAssertFalse(command.authorizesOrderLevelCommand)
            XCTAssertFalse(command.authorizesTradingExecution)
            XCTAssertFalse(command.authorizesLiveTrading)
            XCTAssertFalse(command.touchesSignedEndpoint)
            XCTAssertFalse(command.touchesAccountEndpoint)
            XCTAssertFalse(command.touchesListenKey)
            XCTAssertFalse(command.touchesBrokerAction)
            XCTAssertFalse(command.submitsRealOrder)
            XCTAssertFalse(command.cancelsRealOrder)
            XCTAssertFalse(command.replacesRealOrder)
        }

        let accepted = PaperSessionLocalControlCommand.validate(
            commandID: " paper-control-start ",
            sessionID: " paper-session-fixture ",
            requestedControl: " START ",
            executionMode: .paper,
            requestedAt: Date(timeIntervalSince1970: 3_200)
        )
        XCTAssertTrue(accepted.isAccepted)
        XCTAssertEqual(accepted.acceptedCommand?.control, .start)
        XCTAssertEqual(accepted.acceptedCommand?.commandID, try Identifier("paper-control-start"))
        XCTAssertNil(accepted.rejection)
        XCTAssertEqual(Command.controlPaperSession(commands[0]), .controlPaperSession(commands[0]))
    }

    func testPaperSessionLocalControlValidationRejectsNonSessionOrderAndBrokerCommands() throws {
        // 测试场景：raw request validation 必须拒绝非 session-level control、order-level command、
        // submit / cancel / replace 和 broker-facing action，避免 MTP-48 越界成 OMS 或真实交易入口。
        let requestedAt = Date(timeIntervalSince1970: 3_210)

        func assertRejected(
            _ requestedControl: String,
            reason expectedReason: PaperSessionLocalControlRejectedReason,
            executionMode: ExecutionMode = .paper,
            file: StaticString = #filePath,
            line: UInt = #line
        ) {
            let validation = PaperSessionLocalControlCommand.validate(
                commandID: "paper-control-\(requestedControl)",
                sessionID: "paper-session-fixture",
                requestedControl: requestedControl,
                executionMode: executionMode,
                requestedAt: requestedAt
            )
            XCTAssertFalse(validation.isAccepted, file: file, line: line)
            XCTAssertEqual(validation.rejection?.reason, expectedReason, file: file, line: line)
            XCTAssertEqual(validation.rejection?.rejectedAt, requestedAt, file: file, line: line)
        }

        assertRejected("rebalance", reason: .nonSessionLevelControl)
        assertRejected("order", reason: .orderLevelCommand)
        assertRejected("submit", reason: .realOrderCommand)
        assertRejected("cancel", reason: .realOrderCommand)
        assertRejected("replace", reason: .realOrderCommand)
        assertRejected("broker action", reason: .brokerFacingCommand)
        assertRejected("start", reason: .nonPaperExecutionMode, executionMode: .backtest)

        let emptyCommandID = PaperSessionLocalControlCommand.validate(
            commandID: " ",
            sessionID: "paper-session-fixture",
            requestedControl: "start",
            executionMode: .paper,
            requestedAt: requestedAt
        )
        XCTAssertEqual(emptyCommandID.rejection?.reason, .emptyCommandID)

        let emptySessionID = PaperSessionLocalControlCommand.validate(
            commandID: "paper-control-start",
            sessionID: " ",
            requestedControl: "start",
            executionMode: .paper,
            requestedAt: requestedAt
        )
        XCTAssertEqual(emptySessionID.rejection?.reason, .emptySessionID)

        let rawControls = Set(PaperSessionLocalControlAction.allCases.map(\.rawValue))
        XCTAssertFalse(rawControls.contains("submit"))
        XCTAssertFalse(rawControls.contains("cancel"))
        XCTAssertFalse(rawControls.contains("replace"))
        XCTAssertFalse(rawControls.contains("broker action"))
    }

    func testPaperSessionLocalControlCommandDecodingRejectsRealTradingCapabilityBypass() throws {
        // 测试场景：Codable payload 不能把 session-level local command 伪造成 order-level、
        // signed endpoint、broker action 或真实订单 submit / cancel / replace 能力。
        let command = try PaperSessionLocalControlCommandFixture.deterministic(control: .start)
        let encoded = try JSONEncoder().encode(command)
        let decoder = JSONDecoder()

        var nonPaperObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        nonPaperObject["executionMode"] = "backtest"
        let nonPaperData = try JSONSerialization.data(withJSONObject: nonPaperObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperSessionLocalControlCommand.self, from: nonPaperData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperSessionLocalControlRequiresPaperMode(.backtest))
        }

        var orderLevelObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        orderLevelObject["authorizesOrderLevelCommand"] = true
        let orderLevelData = try JSONSerialization.data(withJSONObject: orderLevelObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperSessionLocalControlCommand.self, from: orderLevelData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSessionLocalControlForbiddenCapability("authorizesOrderLevelCommand")
            )
        }

        var brokerObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        brokerObject["touchesBrokerAction"] = true
        let brokerData = try JSONSerialization.data(withJSONObject: brokerObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperSessionLocalControlCommand.self, from: brokerData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSessionLocalControlForbiddenCapability("touchesBrokerAction")
            )
        }

        var submitObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        submitObject["submitsRealOrder"] = true
        let submitData = try JSONSerialization.data(withJSONObject: submitObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperSessionLocalControlCommand.self, from: submitData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSessionLocalControlForbiddenCapability("submitsRealOrder")
            )
        }
    }

    func testPaperSessionLocalControlEventBoundaryMapsAcceptedCommandsToPaperOnlyFacts() throws {
        // 测试场景：MTP-49 把 MTP-48 accepted session-level command 映射为 `.paper`
        // append-only fact；四个 control 都不能生成 order command、broker action 或真实订单行为。
        var eventLog = try AppendOnlyEventLog()
        let boundary = PaperSessionLocalControlEventLogBoundary()
        let commands = try PaperSessionLocalControlCommandFixture.allDeterministic()

        for (index, command) in commands.enumerated() {
            let recordedAt = Date(timeIntervalSince1970: 3_300 + Double(index))
            let result = try boundary.append(
                .accepted(command),
                to: &eventLog,
                recordedAt: recordedAt
            )

            XCTAssertEqual(result.envelope.sequence, index + 1)
            XCTAssertEqual(result.envelope.stream, .paper)
            XCTAssertEqual(result.envelope.recordedAt, recordedAt)
            XCTAssertEqual(result.acceptedFact?.commandID, command.commandID)
            XCTAssertEqual(result.acceptedFact?.sessionID, command.sessionID)
            XCTAssertEqual(result.acceptedFact?.control, command.control)
            XCTAssertEqual(result.acceptedFact?.eventStream, .paper)
            XCTAssertEqual(result.acceptedFact?.appliedAt, recordedAt)
            XCTAssertTrue(result.acceptedFact?.paperOnlyBoundaryHeld == true)
            XCTAssertNil(result.rejection)

            guard case let .paper(.sessionControlApplied(fact)) = result.envelope.event else {
                return XCTFail("accepted session control must append sessionControlApplied paper fact")
            }
            XCTAssertEqual(fact, result.acceptedFact)
            XCTAssertTrue(fact.command.paperOnlyBoundaryHeld)
            XCTAssertFalse(fact.command.authorizesOrderLevelCommand)
            XCTAssertFalse(fact.command.authorizesTradingExecution)
            XCTAssertFalse(fact.command.touchesBrokerAction)
            XCTAssertFalse(fact.command.submitsRealOrder)
            XCTAssertFalse(fact.command.cancelsRealOrder)
            XCTAssertFalse(fact.command.replacesRealOrder)
        }

        XCTAssertEqual(eventLog.envelopes.map(\.sequence), [1, 2, 3, 4])
        XCTAssertEqual(eventLog.envelopes.map(\.stream), Array(repeating: EventStreamID.paper, count: 4))
        XCTAssertEqual(
            eventLog.replay(
                EventReplayCommand(
                    range: try EventSequenceRange(lowerBound: 1, upperBound: 4),
                    streams: [.paper]
                )
            ).envelopes.count,
            4
        )
        XCTAssertTrue(
            eventLog.replay(
                EventReplayCommand(
                    range: try EventSequenceRange(lowerBound: 1, upperBound: 4),
                    streams: [.risk, .portfolio]
                )
            ).envelopes.isEmpty
        )
        XCTAssertFalse(eventLog.envelopes.contains { envelope in
            switch envelope.event {
            case .paper(.executionDecisionRecorded),
                 .paper(.orderIntentRecorded),
                 .paper(.simulatedFillRecorded):
                return true
            default:
                return false
            }
        })
    }

    func testPaperSessionLocalControlEventBoundaryRecordsRejectedReasonEvidence() throws {
        // 测试场景：invalid session control request 只能写入 rejection evidence，
        // 不能降级为 submit / cancel / replace、broker action、order intent 或 simulated fill。
        var eventLog = try AppendOnlyEventLog()
        let boundary = PaperSessionLocalControlEventLogBoundary()
        let rejectedAt = Date(timeIntervalSince1970: 3_400)
        let cases: [(String, ExecutionMode, PaperSessionLocalControlRejectedReason)] = [
            ("submit", .paper, .realOrderCommand),
            ("cancel", .paper, .realOrderCommand),
            ("replace", .paper, .realOrderCommand),
            ("broker action", .paper, .brokerFacingCommand),
            ("order", .paper, .orderLevelCommand),
            ("start", .backtest, .nonPaperExecutionMode)
        ]

        for (index, entry) in cases.enumerated() {
            let validation = PaperSessionLocalControlCommand.validate(
                commandID: "paper-control-rejected-\(index)",
                sessionID: "paper-session-fixture",
                requestedControl: entry.0,
                executionMode: entry.1,
                requestedAt: rejectedAt
            )

            let result = try boundary.append(
                validation,
                to: &eventLog,
                recordedAt: Date(timeIntervalSince1970: 3_410 + Double(index))
            )

            XCTAssertEqual(result.envelope.sequence, index + 1)
            XCTAssertEqual(result.envelope.stream, .paper)
            XCTAssertNil(result.acceptedFact)
            XCTAssertEqual(result.rejection?.reason, entry.2)
            XCTAssertEqual(result.rejection?.executionMode, entry.1)
            XCTAssertEqual(result.rejection?.rejectedAt, rejectedAt)

            guard case let .paper(.sessionControlRejected(rejection)) = result.envelope.event else {
                return XCTFail("invalid session control must append sessionControlRejected paper fact")
            }
            XCTAssertEqual(rejection, result.rejection)
            XCTAssertEqual(rejection.reason, entry.2)
        }

        XCTAssertEqual(eventLog.envelopes.map(\.sequence), Array(1...cases.count))
        XCTAssertFalse(eventLog.envelopes.contains { envelope in
            switch envelope.event {
            case .paper(.sessionControlApplied),
                 .paper(.executionDecisionRecorded),
                 .paper(.orderIntentRecorded),
                 .paper(.simulatedFillRecorded):
                return true
            default:
                return false
            }
        })
    }

    func testPaperSessionLocalControlEventBoundaryPreservesAppendOnlySequenceAfterExistingFacts() throws {
        // 测试场景：session control event boundary 追加到已有 event log 时，只能取得下一个
        // 单调 sequence，并固定写入 `.paper` stream，不能重排或覆盖既有事实。
        var eventLog = try AppendOnlyEventLog()
        let marketEnvelope = try eventLog.append(
            .market(.bar(try makeMarketBar())),
            stream: .market,
            recordedAt: Date(timeIntervalSince1970: 3_500)
        )
        let command = try PaperSessionLocalControlCommandFixture.deterministic(control: .pause)
        let result = try PaperSessionLocalControlEventLogBoundary().append(
            .accepted(command),
            to: &eventLog,
            recordedAt: Date(timeIntervalSince1970: 3_501)
        )

        XCTAssertEqual(marketEnvelope.sequence, 1)
        XCTAssertEqual(result.envelope.sequence, 2)
        XCTAssertEqual(eventLog.envelopes.map(\.sequence), [1, 2])
        XCTAssertEqual(eventLog.envelopes.map(\.stream), [.market, .paper])
        XCTAssertThrowsError(try AppendOnlyEventLog(envelopes: [result.envelope, marketEnvelope])) { error in
            XCTAssertEqual(error as? CoreError, .invalidSequenceRange)
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
        XCTAssertEqual(summary.replayedSequences, Array(1...16))
        XCTAssertEqual(summary.replayedStreams, [.paper, .portfolio, .risk])
        XCTAssertEqual(summary.firstSequence, 1)
        XCTAssertEqual(summary.lastSequence, 16)
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
        XCTAssertEqual(summary.paperExecutionDecisionIDs, [try Identifier("paper-replay-execution-decision-allowed")])
        XCTAssertEqual(summary.paperOrderIDs, [try Identifier("paper-replay-order-allowed")])
        XCTAssertEqual(summary.simulatedFillIDs, [try Identifier("paper-replay-fill-allowed")])
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
        XCTAssertTrue(summary.coversPaperExecutionDecisionEvents)
        XCTAssertTrue(summary.coversPaperOrderEvents)
        XCTAssertTrue(summary.coversSimulatedFillEvents)
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

    func testPaperExecutionWorkflowContractDefinesPaperOnlyStageAndEventBoundaries() throws {
        // 测试场景：MTP-38 workflow contract 只定义 paper-only 阶段顺序和 event boundary；
        // future issue 只能在该合同内补充 order / fill / execution decision，不能触碰真实交易能力。
        let contract = PaperExecutionWorkflowContract.deterministicFixture

        XCTAssertEqual(contract.contractID, try Identifier("mtp-38-paper-execution-workflow-contract"))
        XCTAssertEqual(contract.issueID, try Identifier("MTP-38"))
        XCTAssertEqual(contract.stageOrder, PaperExecutionWorkflowStage.allCases)
        XCTAssertTrue(contract.paperOnlyBoundaryHeld)

        let proposal = try XCTUnwrap(contract.boundary(for: .proposal))
        XCTAssertNil(proposal.consumes)
        XCTAssertEqual(proposal.produces, .riskDecision)
        XCTAssertEqual(proposal.eventStream, .paper)
        XCTAssertEqual(proposal.evidenceKind, .paperActionProposal)
        XCTAssertTrue(proposal.implementedInCurrentCode)
        XCTAssertNil(proposal.futureIssueID)

        let riskDecision = try XCTUnwrap(contract.boundary(for: .riskDecision))
        XCTAssertEqual(riskDecision.consumes, .proposal)
        XCTAssertEqual(riskDecision.produces, .paperExecutionDecision)
        XCTAssertEqual(riskDecision.eventStream, .risk)
        XCTAssertEqual(riskDecision.evidenceKind, .paperActionProposalRiskDecision)
        XCTAssertTrue(riskDecision.implementedInCurrentCode)

        let executionDecision = try XCTUnwrap(contract.boundary(for: .paperExecutionDecision))
        XCTAssertEqual(executionDecision.consumes, .riskDecision)
        XCTAssertEqual(executionDecision.produces, .paperOrder)
        XCTAssertEqual(executionDecision.eventStream, .paper)
        XCTAssertEqual(executionDecision.evidenceKind, .paperExecutionDecision)
        XCTAssertTrue(executionDecision.implementedInCurrentCode)
        XCTAssertNil(executionDecision.futureIssueID)

        let paperOrder = try XCTUnwrap(contract.boundary(for: .paperOrder))
        XCTAssertEqual(paperOrder.consumes, .paperExecutionDecision)
        XCTAssertEqual(paperOrder.produces, .simulatedFill)
        XCTAssertEqual(paperOrder.eventStream, .paper)
        XCTAssertEqual(paperOrder.evidenceKind, .paperOrder)
        XCTAssertTrue(paperOrder.implementedInCurrentCode)
        XCTAssertNil(paperOrder.futureIssueID)

        let simulatedFill = try XCTUnwrap(contract.boundary(for: .simulatedFill))
        XCTAssertEqual(simulatedFill.consumes, .paperOrder)
        XCTAssertEqual(simulatedFill.produces, .portfolioProjection)
        XCTAssertEqual(simulatedFill.eventStream, .paper)
        XCTAssertEqual(simulatedFill.evidenceKind, .simulatedFill)
        XCTAssertTrue(simulatedFill.implementedInCurrentCode)
        XCTAssertNil(simulatedFill.futureIssueID)

        let portfolioProjection = try XCTUnwrap(contract.boundary(for: .portfolioProjection))
        XCTAssertEqual(portfolioProjection.consumes, .simulatedFill)
        XCTAssertNil(portfolioProjection.produces)
        XCTAssertEqual(portfolioProjection.eventStream, .portfolio)
        XCTAssertEqual(portfolioProjection.evidenceKind, .paperPortfolioProjectionUpdate)
        XCTAssertTrue(portfolioProjection.implementedInCurrentCode)

        for boundary in contract.stageBoundaries {
            XCTAssertFalse(boundary.authorizesTradingExecution)
            XCTAssertFalse(boundary.authorizesLiveTrading)
            XCTAssertFalse(boundary.touchesSignedEndpoint)
            XCTAssertFalse(boundary.touchesBrokerAction)
            XCTAssertFalse(boundary.representsRealOrder)
            XCTAssertTrue(boundary.paperOnlyBoundaryHeld)
        }

        let encoded = try JSONEncoder().encode(contract)
        let decoded = try JSONDecoder().decode(PaperExecutionWorkflowContract.self, from: encoded)
        XCTAssertEqual(decoded, contract)
    }

    func testPaperExecutionWorkflowContractRejectsRealTradingCapabilityAndOrderBypass() throws {
        // 测试场景：MTP-38 contract 的 Codable 边界必须拒绝 trading capability 注入；
        // 阶段顺序也不能被重排，避免绕过 risk decision 直接进入 order / fill / portfolio。
        let contract = PaperExecutionWorkflowContract.deterministicFixture
        let encoded = try JSONEncoder().encode(contract)
        let decoder = JSONDecoder()
        var capabilityObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        var capabilityStages = try XCTUnwrap(
            capabilityObject["stageBoundaries"] as? [[String: Any]]
        )
        capabilityStages[0]["authorizesTradingExecution"] = true
        capabilityObject["stageBoundaries"] = capabilityStages
        let capabilityData = try JSONSerialization.data(withJSONObject: capabilityObject)

        XCTAssertThrowsError(
            try decoder.decode(PaperExecutionWorkflowContract.self, from: capabilityData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperExecutionWorkflowForbiddenCapability("authorizesTradingExecution")
            )
        }

        var orderObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        var reorderedStages = try XCTUnwrap(orderObject["stageBoundaries"] as? [[String: Any]])
        reorderedStages.swapAt(0, 1)
        orderObject["stageBoundaries"] = reorderedStages
        let orderData = try JSONSerialization.data(withJSONObject: orderObject)

        XCTAssertThrowsError(
            try decoder.decode(PaperExecutionWorkflowContract.self, from: orderData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperExecutionWorkflowContractMismatch(
                    field: "stageOrder",
                    expected: "proposal,riskDecision,paperExecutionDecision,paperOrder,simulatedFill,portfolioProjection",
                    actual: "riskDecision,proposal,paperExecutionDecision,paperOrder,simulatedFill,portfolioProjection"
                )
            )
        }

        var transitionObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        var transitionStages = try XCTUnwrap(transitionObject["stageBoundaries"] as? [[String: Any]])
        transitionStages[0]["produces"] = "portfolioProjection"
        transitionObject["stageBoundaries"] = transitionStages
        let transitionData = try JSONSerialization.data(withJSONObject: transitionObject)

        XCTAssertThrowsError(
            try decoder.decode(PaperExecutionWorkflowContract.self, from: transitionData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperExecutionWorkflowContractMismatch(
                    field: "proposal.produces",
                    expected: "riskDecision",
                    actual: "portfolioProjection"
                )
            )
        }
    }

    func testPaperOrderIntentCreatesPaperOnlyLifecycleFromAllowedRiskDecision() throws {
        // 测试场景：MTP-39 allowed risk decision 可以生成本地 paper order intent；
        // lifecycle 只记录 paper-only intentCreated，不代表真实订单、broker action 或 simulated fill。
        let intent = try PaperOrderIntentFixture.deterministicAllowed()

        XCTAssertEqual(intent.orderID, try Identifier("paper-order-intent-allowed"))
        XCTAssertEqual(intent.proposalID, try Identifier("paper-action-proposal-long"))
        XCTAssertEqual(intent.sessionID, try Identifier("paper-session-fixture"))
        XCTAssertEqual(intent.riskDecisionID, try Identifier("paper-action-risk-allowed"))
        XCTAssertEqual(intent.riskDecisionStatus, .allowed)
        XCTAssertNil(intent.blockerEvidenceID)
        XCTAssertEqual(intent.lifecycleState, .intentCreated)
        XCTAssertEqual(intent.riskProfileID, try Identifier("paper-risk"))
        XCTAssertEqual(intent.side, .buy)
        XCTAssertEqual(intent.symbol, try Symbol(rawValue: "BTCUSDT"))
        XCTAssertEqual(intent.timeframe, .oneMinute)
        XCTAssertEqual(intent.quantity.rawValue, 0.5, accuracy: 0.00000001)
        XCTAssertEqual(intent.referencePrice.rawValue, 100, accuracy: 0.00000001)
        XCTAssertEqual(intent.notionalAmount, 50, accuracy: 0.00000001)
        XCTAssertEqual(intent.executionMode, .paper)
        XCTAssertEqual(intent.proposalAuthorization, .paperIntentOnly)
        XCTAssertEqual(intent.workflowStage, .paperOrder)
        XCTAssertEqual(intent.eventStream, .paper)
        XCTAssertEqual(intent.evidenceKind, .paperOrder)
        XCTAssertEqual(intent.sourceRiskDecisionSequence, 7)
        XCTAssertEqual(intent.createdAt.timeIntervalSince1970, 2_500)
        XCTAssertFalse(intent.authorizesTradingExecution)
        XCTAssertFalse(intent.authorizesLiveTrading)
        XCTAssertFalse(intent.touchesSignedEndpoint)
        XCTAssertFalse(intent.touchesBrokerAction)
        XCTAssertFalse(intent.representsRealOrder)
        XCTAssertFalse(intent.representsSimulatedFill)
        XCTAssertFalse(intent.isExecutableAsRealOrder)
        XCTAssertTrue(intent.paperOnlyBoundaryHeld)

        let encoded = try JSONEncoder().encode(intent)
        let decoded = try JSONDecoder().decode(PaperOrderIntent.self, from: encoded)
        XCTAssertEqual(decoded, intent)
    }

    func testPaperOrderIntentMapsBlockedRiskDecisionToRejectedLifecycle() throws {
        // 测试场景：blocked risk decision 只生成 rejectedByRisk 的本地 lifecycle evidence；
        // 它保留 blocker ID 便于追溯，但不能进入真实订单或 simulated fill 语义。
        let intent = try PaperOrderIntentFixture.deterministicRiskRejected()

        XCTAssertEqual(intent.orderID, try Identifier("paper-order-intent-risk-rejected"))
        XCTAssertEqual(intent.proposalID, try Identifier("paper-action-proposal-long"))
        XCTAssertEqual(intent.riskDecisionID, try Identifier("paper-action-risk-blocked"))
        XCTAssertEqual(intent.riskDecisionStatus, .blocked)
        XCTAssertEqual(intent.blockerEvidenceID, try Identifier("risk-blocker-paper-action-proposal-long"))
        XCTAssertEqual(intent.lifecycleState, .rejectedByRisk)
        XCTAssertEqual(intent.sourceRiskDecisionSequence, 8)
        XCTAssertEqual(intent.createdAt.timeIntervalSince1970, 2_560)
        XCTAssertEqual(PaperOrderLifecycleState.allCases, [.intentCreated, .rejectedByRisk])
        XCTAssertTrue(intent.paperOnlyBoundaryHeld)
        XCTAssertFalse(intent.isExecutableAsRealOrder)
        XCTAssertFalse(intent.representsSimulatedFill)
    }

    func testPaperOrderIntentDecodingRejectsCapabilityAndLifecycleBypass() throws {
        // 测试场景：Codable 解码不能把 paper order intent 伪造成真实订单、Live 执行、
        // signed endpoint 调用或与 risk result 不一致的 lifecycle state。
        let intent = try PaperOrderIntentFixture.deterministicAllowed()
        let encoded = try JSONEncoder().encode(intent)
        let decoder = JSONDecoder()

        var nonPaperObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        nonPaperObject["executionMode"] = "backtest"
        let nonPaperData = try JSONSerialization.data(withJSONObject: nonPaperObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperOrderIntent.self, from: nonPaperData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperOrderIntentRequiresPaperMode(.backtest))
        }

        var lifecycleObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        lifecycleObject["lifecycleState"] = "rejectedByRisk"
        let lifecycleData = try JSONSerialization.data(withJSONObject: lifecycleObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperOrderIntent.self, from: lifecycleData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperOrderIntentMismatch(
                    field: "lifecycleState",
                    expected: "intentCreated",
                    actual: "rejectedByRisk"
                )
            )
        }

        var tradingAuthorizationObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        tradingAuthorizationObject["authorizesTradingExecution"] = true
        let tradingAuthorizationData = try JSONSerialization.data(withJSONObject: tradingAuthorizationObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperOrderIntent.self, from: tradingAuthorizationData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperOrderIntentForbiddenCapability("authorizesTradingExecution")
            )
        }

        var simulatedFillObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        simulatedFillObject["representsSimulatedFill"] = true
        let simulatedFillData = try JSONSerialization.data(withJSONObject: simulatedFillObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperOrderIntent.self, from: simulatedFillData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperOrderIntentForbiddenCapability("representsSimulatedFill")
            )
        }
    }

    func testPaperSimulatedFillEvidenceCreatesDeterministicPaperOnlyFillFromAllowedOrderIntent() throws {
        // 测试场景：MTP-40 simulated fill evidence 必须从 allowed paper order intent 派生，
        // 并复用 MTP-27 fixed cost evidence；它只表示本地模拟成交证据，不代表真实成交或 broker fill。
        let evidence = try PaperSimulatedFillFixture.deterministicAllowed()
        let orderIntent = try PaperOrderIntentFixture.deterministicAllowed()
        let expectedCost = ExecutionCostCalculator.estimate(
            ExecutionCostEstimateRequest(
                symbol: orderIntent.symbol,
                timeframe: orderIntent.timeframe,
                executionMode: .paper,
                referencePrice: orderIntent.referencePrice,
                quantity: orderIntent.quantity,
                liquidityRole: .maker
            ),
            assumptions: .deterministicFixture
        )

        XCTAssertEqual(evidence.fillID, try Identifier("paper-simulated-fill-allowed"))
        XCTAssertEqual(evidence.orderID, orderIntent.orderID)
        XCTAssertEqual(evidence.proposalID, orderIntent.proposalID)
        XCTAssertEqual(evidence.sessionID, orderIntent.sessionID)
        XCTAssertEqual(evidence.riskDecisionID, orderIntent.riskDecisionID)
        XCTAssertEqual(evidence.riskProfileID, try Identifier("paper-risk"))
        XCTAssertEqual(evidence.orderLifecycleState, .intentCreated)
        XCTAssertEqual(evidence.riskDecisionStatus, .allowed)
        XCTAssertEqual(evidence.side, .buy)
        XCTAssertEqual(evidence.symbol, try Symbol(rawValue: "BTCUSDT"))
        XCTAssertEqual(evidence.timeframe, .oneMinute)
        XCTAssertEqual(evidence.filledQuantity.rawValue, 0.5, accuracy: 0.00000001)
        XCTAssertEqual(evidence.fillPrice.rawValue, 100, accuracy: 0.00000001)
        XCTAssertEqual(evidence.orderIntentQuantity.rawValue, orderIntent.quantity.rawValue, accuracy: 0.00000001)
        XCTAssertEqual(
            evidence.orderIntentReferencePrice.rawValue,
            orderIntent.referencePrice.rawValue,
            accuracy: 0.00000001
        )
        XCTAssertEqual(evidence.grossNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(evidence.costEstimate, expectedCost)
        XCTAssertEqual(evidence.costEstimate.assumptionID, try Identifier("mtp-27-fixed-cost-assumptions"))
        XCTAssertEqual(evidence.costEstimate.feeAmount, 0.01, accuracy: 0.00000001)
        XCTAssertEqual(evidence.costEstimate.slippageAmount, 0.0075, accuracy: 0.00000001)
        XCTAssertEqual(evidence.costEstimate.totalCostAmount, 0.0175, accuracy: 0.00000001)
        XCTAssertEqual(evidence.executionMode, .paper)
        XCTAssertEqual(evidence.proposalAuthorization, .paperIntentOnly)
        XCTAssertEqual(evidence.workflowStage, .simulatedFill)
        XCTAssertEqual(evidence.eventStream, .paper)
        XCTAssertEqual(evidence.evidenceKind, .simulatedFill)
        XCTAssertEqual(evidence.sourceOrderIntentSequence, 9)
        XCTAssertEqual(evidence.sourceRiskDecisionSequence, 7)
        XCTAssertEqual(evidence.filledAt.timeIntervalSince1970, 2_700)
        XCTAssertTrue(evidence.isSimulatedFillEvidence)
        XCTAssertFalse(evidence.authorizesTradingExecution)
        XCTAssertFalse(evidence.authorizesLiveTrading)
        XCTAssertFalse(evidence.touchesSignedEndpoint)
        XCTAssertFalse(evidence.touchesBrokerAction)
        XCTAssertFalse(evidence.representsRealOrder)
        XCTAssertFalse(evidence.representsRealFill)
        XCTAssertFalse(evidence.representsBrokerFill)
        XCTAssertFalse(evidence.updatesRealAccountBalance)
        XCTAssertFalse(evidence.isExecutableAsRealOrder)
        XCTAssertTrue(evidence.paperOnlyBoundaryHeld)

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(PaperSimulatedFillEvidence.self, from: encoded)
        XCTAssertEqual(decoded, evidence)
    }

    func testPaperSimulatedFillEvidenceRejectsRejectedIntentAndAssumptionMismatch() throws {
        // 测试场景：risk-rejected order intent 不得生成 simulated fill；填充数量或价格也必须
        // 与 order intent deterministic assumption 对齐，避免引入部分成交或动态滑点语义。
        XCTAssertThrowsError(
            try PaperSimulatedFillEvidence(
                fillID: try Identifier("paper-simulated-fill-rejected"),
                orderIntent: PaperOrderIntentFixture.deterministicRiskRejected(),
                assumption: .deterministicFixture,
                sourceOrderIntentSequence: 10,
                filledAt: Date(timeIntervalSince1970: 2_700)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSimulatedFillRequiresOrderIntentCreated(.rejectedByRisk)
            )
        }

        XCTAssertThrowsError(
            try PaperSimulatedFillAssumption(
                assumptionID: try Identifier("invalid-zero-simulated-fill"),
                filledQuantity: try Quantity(0, field: "paperSimulatedFill.filledQuantity"),
                fillPrice: try Price(100, field: "paperSimulatedFill.fillPrice"),
                liquidityRole: .maker
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .invalidPaperSimulatedFillQuantity(0))
        }

        let evidence = try PaperSimulatedFillFixture.deterministicAllowed()
        let encoded = try JSONEncoder().encode(evidence)
        let decoder = JSONDecoder()

        var quantityMismatchObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        quantityMismatchObject["filledQuantity"] = 0.25
        let quantityMismatchData = try JSONSerialization.data(withJSONObject: quantityMismatchObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperSimulatedFillEvidence.self, from: quantityMismatchData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSimulatedFillMismatch(field: "filledQuantity", expected: "0.5", actual: "0.25")
            )
        }
    }

    func testPaperSimulatedFillEvidenceDecodingRejectsRealFillBrokerAndAccountBypass() throws {
        // 测试场景：Codable 解码不能把 simulated fill evidence 伪造成真实成交、
        // broker fill、account update、signed endpoint 或 Live trading 能力。
        let evidence = try PaperSimulatedFillFixture.deterministicAllowed()
        let encoded = try JSONEncoder().encode(evidence)
        let decoder = JSONDecoder()

        var nonPaperObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        nonPaperObject["executionMode"] = "backtest"
        let nonPaperData = try JSONSerialization.data(withJSONObject: nonPaperObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperSimulatedFillEvidence.self, from: nonPaperData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperSimulatedFillRequiresPaperMode(.backtest))
        }

        var realFillObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        realFillObject["representsRealFill"] = true
        let realFillData = try JSONSerialization.data(withJSONObject: realFillObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperSimulatedFillEvidence.self, from: realFillData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSimulatedFillForbiddenCapability("representsRealFill")
            )
        }

        var brokerFillObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        brokerFillObject["representsBrokerFill"] = true
        let brokerFillData = try JSONSerialization.data(withJSONObject: brokerFillObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperSimulatedFillEvidence.self, from: brokerFillData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSimulatedFillForbiddenCapability("representsBrokerFill")
            )
        }

        var accountUpdateObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        accountUpdateObject["updatesRealAccountBalance"] = true
        let accountUpdateData = try JSONSerialization.data(withJSONObject: accountUpdateObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperSimulatedFillEvidence.self, from: accountUpdateData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSimulatedFillForbiddenCapability("updatesRealAccountBalance")
            )
        }
    }

    func testPaperExecutionDecisionCreatesAllowedPaperOnlyDecisionChain() throws {
        // 测试场景：MTP-41 allowed risk decision 必须串联成本地 paper execution decision，
        // 并只生成 paper order intent 和 simulated fill evidence，不授权真实订单或 broker action。
        let decision = try PaperExecutionDecisionFixture.deterministicAllowed()
        let orderIntent = try XCTUnwrap(decision.paperOrderIntent)
        let fillAssumption = try XCTUnwrap(decision.simulatedFillAssumption)
        let fillEvidence = try XCTUnwrap(decision.simulatedFillEvidence)

        XCTAssertEqual(decision.decisionID, try Identifier("paper-execution-decision-allowed"))
        XCTAssertEqual(decision.status, .allowed)
        XCTAssertTrue(decision.isAllowed)
        XCTAssertFalse(decision.isBlocked)
        XCTAssertEqual(decision.riskDecisionID, try Identifier("paper-action-risk-allowed"))
        XCTAssertEqual(decision.proposalID, try Identifier("paper-action-proposal-long"))
        XCTAssertEqual(decision.sessionID, try Identifier("paper-session-fixture"))
        XCTAssertEqual(decision.riskProfileID, try Identifier("paper-risk"))
        XCTAssertNil(decision.blockerEvidenceID)
        XCTAssertEqual(decision.sourceRiskDecisionSequence, 7)
        XCTAssertEqual(decision.sourceOrderIntentSequence, 9)
        XCTAssertEqual(decision.decidedAt.timeIntervalSince1970, 2_900)
        XCTAssertEqual(decision.executionMode, .paper)
        XCTAssertEqual(decision.proposalAuthorization, .paperIntentOnly)
        XCTAssertEqual(decision.workflowStage, .paperExecutionDecision)
        XCTAssertEqual(decision.eventStream, .paper)
        XCTAssertEqual(decision.evidenceKind, .paperExecutionDecision)

        XCTAssertTrue(decision.generatedPaperOrderIntent)
        XCTAssertEqual(orderIntent.orderID, try Identifier("paper-execution-order-allowed"))
        XCTAssertEqual(orderIntent.riskDecisionID, decision.riskDecisionID)
        XCTAssertEqual(orderIntent.lifecycleState, .intentCreated)
        XCTAssertEqual(orderIntent.sourceRiskDecisionSequence, decision.sourceRiskDecisionSequence)
        XCTAssertTrue(orderIntent.paperOnlyBoundaryHeld)

        XCTAssertEqual(fillAssumption.assumptionID, try Identifier("mtp-40-simulated-fill-assumption"))
        XCTAssertTrue(decision.generatedSimulatedFillEvidence)
        XCTAssertEqual(fillEvidence.fillID, try Identifier("paper-execution-fill-allowed"))
        XCTAssertEqual(fillEvidence.orderID, orderIntent.orderID)
        XCTAssertEqual(fillEvidence.riskDecisionID, decision.riskDecisionID)
        XCTAssertEqual(fillEvidence.sourceOrderIntentSequence, 9)
        XCTAssertEqual(fillEvidence.sourceRiskDecisionSequence, 7)
        XCTAssertEqual(fillEvidence.filledQuantity.rawValue, orderIntent.quantity.rawValue, accuracy: 0.00000001)
        XCTAssertEqual(fillEvidence.fillPrice.rawValue, orderIntent.referencePrice.rawValue, accuracy: 0.00000001)
        XCTAssertTrue(fillEvidence.paperOnlyBoundaryHeld)

        XCTAssertFalse(decision.authorizesTradingExecution)
        XCTAssertFalse(decision.authorizesLiveTrading)
        XCTAssertFalse(decision.touchesSignedEndpoint)
        XCTAssertFalse(decision.touchesBrokerAction)
        XCTAssertFalse(decision.representsRealOrder)
        XCTAssertFalse(decision.representsRealFill)
        XCTAssertFalse(decision.representsBrokerFill)
        XCTAssertFalse(decision.updatesRealAccountBalance)
        XCTAssertFalse(decision.isExecutableAsRealOrder)
        XCTAssertTrue(decision.paperOnlyBoundaryHeld)

        let encoded = try JSONEncoder().encode(decision)
        let decoded = try JSONDecoder().decode(PaperExecutionDecision.self, from: encoded)
        XCTAssertEqual(decoded, decision)
    }

    func testPaperExecutionDecisionBlocksWithoutGeneratingPaperOrder() throws {
        // 测试场景：MTP-41 blocked risk decision 必须只保留本地 blocker evidence；
        // blocked 链路不得生成 paper order intent、simulated fill assumption 或 fill evidence。
        let decision = try PaperExecutionDecisionFixture.deterministicBlocked()
        let blockerEvidence = try XCTUnwrap(decision.riskDecision.blockerEvidence)

        XCTAssertEqual(decision.decisionID, try Identifier("paper-execution-decision-blocked"))
        XCTAssertEqual(decision.status, .blocked)
        XCTAssertFalse(decision.isAllowed)
        XCTAssertTrue(decision.isBlocked)
        XCTAssertEqual(decision.riskDecisionID, try Identifier("paper-action-risk-blocked"))
        XCTAssertEqual(decision.blockerEvidenceID, try Identifier("risk-blocker-paper-action-proposal-long"))
        XCTAssertEqual(blockerEvidence.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(decision.sourceRiskDecisionSequence, 8)
        XCTAssertNil(decision.sourceOrderIntentSequence)
        XCTAssertNil(decision.paperOrderIntent)
        XCTAssertNil(decision.simulatedFillAssumption)
        XCTAssertNil(decision.simulatedFillEvidence)
        XCTAssertFalse(decision.generatedPaperOrderIntent)
        XCTAssertFalse(decision.generatedSimulatedFillEvidence)
        XCTAssertEqual(decision.workflowStage, .paperExecutionDecision)
        XCTAssertEqual(decision.eventStream, .paper)
        XCTAssertEqual(decision.evidenceKind, .paperExecutionDecision)
        XCTAssertTrue(decision.paperOnlyBoundaryHeld)
        XCTAssertFalse(decision.isExecutableAsRealOrder)

        XCTAssertThrowsError(
            try PaperExecutionDecisionLink.decide(
                decisionID: try Identifier("invalid-blocked-order-bypass"),
                riskDecision: PaperActionProposalRiskFixture.deterministicBlocked(),
                orderID: try Identifier("must-not-exist"),
                fillID: try Identifier("must-not-fill"),
                simulatedFillAssumption: .deterministicFixture,
                sourceOrderIntentSequence: 10,
                decidedAt: Date(timeIntervalSince1970: 2_960)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperExecutionDecisionMismatch(
                    field: "orderID",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            )
        }

        let encoded = try JSONEncoder().encode(decision)
        let decoded = try JSONDecoder().decode(PaperExecutionDecision.self, from: encoded)
        XCTAssertEqual(decoded, decision)
    }

    func testPaperExecutionDecisionRejectsBypassAndRealTradingCapability() throws {
        // 测试场景：MTP-41 decision 解码不能把 blocked 风险结果伪造成可下单链路，
        // 也不能恢复真实交易、Live、signed endpoint、broker fill 或 account update 能力。
        let allowedDecision = try PaperExecutionDecisionFixture.deterministicAllowed()
        let blockedDecision = try PaperExecutionDecisionFixture.deterministicBlocked()
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        XCTAssertThrowsError(
            try PaperExecutionDecisionLink.decide(
                decisionID: try Identifier("invalid-allowed-without-order"),
                riskDecision: PaperActionProposalRiskFixture.deterministicAllowed(),
                decidedAt: Date(timeIntervalSince1970: 2_900)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperExecutionDecisionMismatch(
                    field: "orderID",
                    expected: "present for allowed decision",
                    actual: "nil"
                )
            )
        }

        var blockedOrderBypass = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoder.encode(blockedDecision)) as? [String: Any]
        )
        blockedOrderBypass["paperOrderIntent"] = try JSONSerialization.jsonObject(
            with: encoder.encode(try XCTUnwrap(allowedDecision.paperOrderIntent))
        )
        let blockedOrderBypassData = try JSONSerialization.data(withJSONObject: blockedOrderBypass)
        XCTAssertThrowsError(
            try decoder.decode(PaperExecutionDecision.self, from: blockedOrderBypassData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperExecutionDecisionMismatch(
                    field: "paperOrderIntent",
                    expected: "nil for blocked decision",
                    actual: "present"
                )
            )
        }

        var statusBypass = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoder.encode(allowedDecision)) as? [String: Any]
        )
        statusBypass["status"] = "blocked"
        let statusBypassData = try JSONSerialization.data(withJSONObject: statusBypass)
        XCTAssertThrowsError(
            try decoder.decode(PaperExecutionDecision.self, from: statusBypassData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperExecutionDecisionMismatch(field: "status", expected: "allowed", actual: "blocked")
            )
        }

        var tradingCapabilityBypass = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoder.encode(allowedDecision)) as? [String: Any]
        )
        tradingCapabilityBypass["authorizesTradingExecution"] = true
        let tradingCapabilityBypassData = try JSONSerialization.data(withJSONObject: tradingCapabilityBypass)
        XCTAssertThrowsError(
            try decoder.decode(PaperExecutionDecision.self, from: tradingCapabilityBypassData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperExecutionDecisionForbiddenCapability("authorizesTradingExecution")
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

    func testPaperExecutionEventLogBoundaryAppendsDecisionOrderAndFillFacts() throws {
        // 测试场景：MTP-42 allowed paper execution decision 必须按 decision -> order -> fill
        // 写入 `.paper` stream；source order sequence 必须与 append-only event log 分配的 sequence 对齐。
        var eventLog = try makePaperExecutionSeedEventLog()
        let proposalEnvelope = try XCTUnwrap(eventLog.envelopes.last)
        let decision = try makeAllowedPaperExecutionDecision(
            proposalEnvelope: proposalEnvelope,
            expectedSourceOrderIntentSequence: eventLog.envelopes.count + 2
        )
        let appendResult = try PaperExecutionEventLogBoundary().append(
            decision,
            to: &eventLog,
            recordedAt: Date(timeIntervalSince1970: 3_000)
        )

        XCTAssertEqual(appendResult.appendedEnvelopes.map(\.sequence), [8, 9, 10])
        XCTAssertEqual(appendResult.appendedEnvelopes.map(\.stream), [.paper, .paper, .paper])
        XCTAssertEqual(
            appendResult.appendedEnvelopes.map { $0.recordedAt.timeIntervalSince1970 },
            [3_000, 3_001, 3_002]
        )

        guard case let .paper(.executionDecisionRecorded(recordedDecision)) = appendResult.decisionEnvelope.event else {
            return XCTFail("first execution event must record the decision")
        }
        guard case let .paper(.orderIntentRecorded(recordedOrder)) = appendResult.orderIntentEnvelope?.event else {
            return XCTFail("second execution event must record the paper order intent")
        }
        guard case let .paper(.simulatedFillRecorded(recordedFill)) = appendResult.simulatedFillEnvelope?.event else {
            return XCTFail("third execution event must record the simulated fill evidence")
        }

        XCTAssertEqual(recordedDecision.decisionID, decision.decisionID)
        XCTAssertEqual(recordedOrder.orderID, try Identifier("paper-execution-log-order"))
        XCTAssertEqual(recordedFill.fillID, try Identifier("paper-execution-log-fill"))
        XCTAssertEqual(recordedFill.sourceOrderIntentSequence, appendResult.orderIntentEnvelope?.sequence)
        XCTAssertTrue(recordedDecision.paperOnlyBoundaryHeld)
        XCTAssertTrue(recordedOrder.paperOnlyBoundaryHeld)
        XCTAssertTrue(recordedFill.paperOnlyBoundaryHeld)
    }

    func testPaperExecutionEventLogBoundaryRejectsMismatchedOrderSequence() throws {
        // 测试场景：MTP-42 写入边界必须拒绝 source order sequence 与实际 append-only
        // sequence 不一致的 decision，避免 replay 后产生不可追溯的 fill evidence。
        var eventLog = try makePaperExecutionSeedEventLog()
        let proposalEnvelope = try XCTUnwrap(eventLog.envelopes.last)
        let decision = try makeAllowedPaperExecutionDecision(
            proposalEnvelope: proposalEnvelope,
            expectedSourceOrderIntentSequence: 99
        )

        XCTAssertThrowsError(
            try PaperExecutionEventLogBoundary().append(
                decision,
                to: &eventLog,
                recordedAt: Date(timeIntervalSince1970: 3_000)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperExecutionDecisionMismatch(
                    field: "sourceOrderIntentSequence",
                    expected: "9",
                    actual: "Optional(99)"
                )
            )
        }
        XCTAssertEqual(eventLog.envelopes.map(\.sequence), Array(1...7))
    }

    func testPaperExecutionReplayProjectsPortfolioOnlyFromSimulatedFillEvidence() throws {
        // 测试场景：MTP-42 portfolio projection update 必须由 replay 后的
        // `simulatedFillRecorded` fact 派生；risk decision 本身不能直接更新组合投影。
        var eventLog = try makePaperExecutionSeedEventLog()
        let proposalEnvelope = try XCTUnwrap(eventLog.envelopes.last)
        let decision = try makeAllowedPaperExecutionDecision(
            proposalEnvelope: proposalEnvelope,
            expectedSourceOrderIntentSequence: eventLog.envelopes.count + 2
        )
        let appendResult = try PaperExecutionEventLogBoundary().append(
            decision,
            to: &eventLog,
            recordedAt: Date(timeIntervalSince1970: 3_000)
        )
        let replay = eventLog.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: eventLog.envelopes.count),
                streams: [.paper]
            )
        )
        let fillEnvelope = try XCTUnwrap(
            try PaperExecutionReplayProjectionPath.simulatedFillEnvelopes(from: replay).first
        )
        let update = try PaperExecutionReplayProjectionPath.projectPortfolioUpdate(
            from: fillEnvelope,
            updateID: try Identifier("paper-portfolio-update-allowed"),
            portfolioID: try Identifier("portfolio-main"),
            updatedAt: Date(timeIntervalSince1970: 1_900)
        )

        XCTAssertEqual(fillEnvelope, appendResult.simulatedFillEnvelope)
        XCTAssertEqual(update.updateID, try Identifier("paper-portfolio-update-allowed"))
        XCTAssertEqual(update.decisionID, decision.riskDecisionID)
        XCTAssertEqual(update.orderID, try Identifier("paper-execution-log-order"))
        XCTAssertEqual(update.fillID, try Identifier("paper-execution-log-fill"))
        XCTAssertEqual(update.proposalID, decision.proposalID)
        XCTAssertEqual(update.sessionID, decision.sessionID)
        XCTAssertEqual(update.riskProfileID, try Identifier("paper-risk"))
        XCTAssertEqual(update.side, .buy)
        XCTAssertEqual(update.riskDecisionStatus, .allowed)
        XCTAssertEqual(update.executionMode, .paper)
        XCTAssertEqual(update.sourceSequence, 10)
        XCTAssertEqual(update.sourceOrderIntentSequence, 9)
        XCTAssertEqual(update.sourceRiskDecisionSequence, proposalEnvelope.sequence)
        XCTAssertEqual(update.exposure.portfolioID, try Identifier("portfolio-main"))
        XCTAssertEqual(update.exposure.symbol, try Symbol(rawValue: "BTCUSDT"))
        XCTAssertEqual(update.exposure.timeframe, .oneMinute)
        XCTAssertEqual(update.exposure.paperQuantity.rawValue, 0.5, accuracy: 0.00000001)
        XCTAssertEqual(update.exposure.referencePrice.rawValue, 100, accuracy: 0.00000001)
        XCTAssertEqual(update.exposure.grossExposureNotional, 50, accuracy: 0.00000001)
        XCTAssertEqual(update.exposure.source, .paperProjection)
        XCTAssertEqual(update.updatedAt.timeIntervalSince1970, 1_900)
        XCTAssertTrue(update.usesSimulatedFillEvidence)
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

    func testPaperPortfolioProjectionUpdateRejectsCapabilityAndFillBypass() throws {
        // 测试场景：portfolio update 解码不能绕过 simulated fill evidence 来源，也不能
        // 恢复 trading authorization、真实账户余额读取或 broker position sync 能力。
        let allowedUpdate = try PaperPortfolioProjectionUpdate(
            updateID: try Identifier("paper-portfolio-update-allowed"),
            portfolioID: try Identifier("portfolio-main"),
            simulatedFill: PaperSimulatedFillFixture.deterministicAllowed(),
            sourceSimulatedFillSequence: 10,
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

        var fillBypassObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        fillBypassObject["usesSimulatedFillEvidence"] = false
        let fillBypassData = try JSONSerialization.data(withJSONObject: fillBypassObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperPortfolioProjectionUpdate.self, from: fillBypassData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPortfolioProjectionMismatch(
                    field: "usesSimulatedFillEvidence",
                    expected: "true",
                    actual: "false"
                )
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

    private func makePaperExecutionSeedEventLog() throws -> AppendOnlyEventLog {
        var eventLog = try AppendOnlyEventLog()
        for index in 0..<6 {
            try eventLog.append(
                .market(.bar(try makeMarketBar(close: 100 + Double(index), start: TimeInterval(100 + index * 60)))),
                stream: .market,
                recordedAt: Date(timeIntervalSince1970: 2_000 + TimeInterval(index))
            )
        }
        try eventLog.append(
            .paper(.actionProposed(PaperActionProposalFixture.deterministicLong())),
            stream: .paper,
            recordedAt: Date(timeIntervalSince1970: 2_100)
        )
        return eventLog
    }

    private func makeAllowedPaperExecutionDecision(
        proposalEnvelope: EventEnvelope,
        expectedSourceOrderIntentSequence: Int
    ) throws -> PaperExecutionDecision {
        guard case let .paper(.actionProposed(proposal)) = proposalEnvelope.event else {
            throw CoreError.paperExecutionDecisionMismatch(
                field: "proposalEnvelope.event",
                expected: "paper.actionProposed",
                actual: "\(proposalEnvelope.event)"
            )
        }
        let riskDecision = try PaperActionProposalRiskLink.evaluate(
            decisionID: try Identifier("paper-execution-log-risk"),
            proposal: proposal,
            policy: .deterministicAllowingFixture,
            sourceSequence: proposalEnvelope.sequence,
            evaluatedAt: Date(timeIntervalSince1970: 2_200)
        )
        return try PaperExecutionDecisionLink.decide(
            decisionID: try Identifier("paper-execution-log-decision"),
            riskDecision: riskDecision,
            orderID: try Identifier("paper-execution-log-order"),
            fillID: try Identifier("paper-execution-log-fill"),
            simulatedFillAssumption: .deterministicFixture,
            sourceOrderIntentSequence: expectedSourceOrderIntentSequence,
            decidedAt: Date(timeIntervalSince1970: 2_260)
        )
    }

    func testLiveRiskGateBlockedEvidenceDefinesMTP87ReadModelOnlySnapshot() throws {
        // 测试场景：MTP-87 只新增 Future Live Risk gate blocked evidence 的只读快照。
        // exposure、notional、frequency、loss / drawdown、circuit breaker 和 no-trade
        // gate 都必须保持 blocked，供 App 展示但不能生成真实风控决策或交易命令。
        let evidence = LiveRiskGateBlockedEvidence.deterministicFixture

        XCTAssertEqual(evidence.contractID, try Identifier("mtp-87-live-risk-gate-blocked-evidence"))
        XCTAssertEqual(evidence.issueID, try Identifier("MTP-87"))
        XCTAssertEqual(evidence.blockedItems.map(\.gate), LiveRiskGateBlockedGate.allCases)
        XCTAssertEqual(
            evidence.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .paperLiveRiskIsolationEvidence,
                .readModelOnlyBlockedEvidence,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(evidence.validationAnchors, [
            "MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE",
            "MTP-87-LIVE-RISK-GATES-BLOCKED-REASONS",
            "MTP-87-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT",
            "MTP-87-READ-MODEL-ONLY-NO-COMMAND-SURFACE",
            "MTP-87-LIVE-RISK-GATE-VALIDATION",
            "TVM-LIVE-RISK-GATE"
        ])
        XCTAssertEqual(evidence.sourceAnchors, [
            "MTP-82-LIVE-RISK-TERMINOLOGY",
            "MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES",
            "MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES",
            "MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES",
            "MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT",
            "MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY",
            "TVM-LIVE-RISK-GATE"
        ])
        XCTAssertEqual(evidence.deterministicSnapshot, [
            "exposure|blocked|human live risk decision missing;account state source forbidden;broker position source forbidden;margin / leverage source forbidden;paper / live risk isolation required",
            "order notional|blocked|human live risk decision missing;real order notional evaluation forbidden;real pre-trade allow / reject runtime forbidden;read model only boundary required",
            "frequency|blocked|live order frequency runtime forbidden;real pre-trade allow / reject runtime forbidden;read model only boundary required",
            "loss / drawdown|blocked|real PnL / equity source forbidden;real loss / drawdown runtime forbidden;paper / live risk isolation required;read model only boundary required",
            "circuit breaker|blocked|circuit breaker runtime forbidden;stop / emergency command forbidden;risk command surface forbidden;read model only boundary required",
            "no-trade state|blocked|no-trade state runtime forbidden;broker session state mutation forbidden;stop / emergency command forbidden;read model only boundary required"
        ])

        XCTAssertTrue(evidence.blockedEvidenceBoundaryHeld)
        XCTAssertTrue(evidence.allRiskGatesBlocked)
        XCTAssertTrue(evidence.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertTrue(evidence.forbiddenImplementationBoundaryHeld)
        XCTAssertTrue(evidence.isReadModelOnly)
        XCTAssertTrue(evidence.reportConsumesReadModelOnly)
        XCTAssertTrue(evidence.dashboardConsumesViewModelOnly)
        XCTAssertTrue(evidence.eventTimelineConsumesReadModelOnly)
        XCTAssertFalse(evidence.exposesPersistenceSchema)
        XCTAssertFalse(evidence.readsAdapter)
        XCTAssertFalse(evidence.invokesRuntimeControl)
        XCTAssertFalse(evidence.providesCommandSurface)
        XCTAssertFalse(evidence.providesRiskCommandSurface)
        XCTAssertFalse(evidence.providesTradingButton)
        XCTAssertFalse(evidence.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(LiveRiskGateBlockedEvidence.self, from: encoded)
        XCTAssertEqual(decoded, evidence)
    }

    func testLiveRiskGateBlockedEvidenceRejectsMTP87RuntimeAccountAndCommandBypass() throws {
        // 测试场景：MTP-87 的 blocked evidence 初始化和 Codable 解码必须拒绝
        // schema、adapter、runtime、账户 / broker 来源、allow / reject runtime 和交易按钮绕过。
        XCTAssertThrowsError(
            try LiveRiskGateBlockedEvidence(providesCommandSurface: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesCommandSurface"))
        }
        XCTAssertThrowsError(
            try LiveRiskGateBlockedEvidence(readsRealAccountBalance: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRealAccountBalance"))
        }
        XCTAssertThrowsError(
            try LiveRiskGateBlockedEvidence(syncsBrokerPosition: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("syncsBrokerPosition"))
        }
        XCTAssertThrowsError(
            try LiveRiskGateBlockedEvidence(evaluatesRealPreTradeReject: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("evaluatesRealPreTradeReject"))
        }
        XCTAssertThrowsError(
            try LiveRiskGateBlockedEvidence(runsCircuitBreakerRuntime: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsCircuitBreakerRuntime"))
        }
        XCTAssertThrowsError(
            try LiveRiskGateBlockedEvidence(providesTradingButton: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesTradingButton"))
        }
        XCTAssertThrowsError(
            try LiveRiskGateBlockedEvidence(
                blockedItems: Array(LiveRiskGateBlockedEvidence.requiredBlockedItems.dropLast())
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "blockedItems",
                    expected: LiveRiskGateBlockedEvidence
                        .requiredBlockedItems
                        .map(\.gate.rawValue)
                        .joined(separator: ","),
                    actual: Array(LiveRiskGateBlockedEvidence.requiredBlockedItems.dropLast())
                        .map(\.gate.rawValue)
                        .joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveRiskGateBlockedEvidence.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["providesRiskCommandSurface"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveRiskGateBlockedEvidence.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesRiskCommandSurface"))
        }
    }

    func testLiveRiskGateBlockedEvidenceSummarizesMTP87GateReasonsWithoutRiskRuntime() throws {
        // 测试场景：MTP-87 必须逐项解释 Live Risk gates 为什么仍被阻断，
        // 并继续复用 MTP-83 至 MTP-86 的 Future / forbidden contracts。
        let evidence = LiveRiskGateBlockedEvidence.deterministicFixture

        let exposure = try XCTUnwrap(evidence.item(for: .exposure))
        XCTAssertEqual(exposure.blockedReasons, [
            .humanLiveRiskDecisionMissing,
            .accountStateSourceForbidden,
            .brokerPositionSourceForbidden,
            .marginLeverageSourceForbidden,
            .paperLiveRiskIsolationRequired
        ])
        XCTAssertTrue(exposure.readModelOnlyBoundaryHeld)
        XCTAssertFalse(exposure.evaluatesRisk)
        XCTAssertFalse(exposure.readsAccountState)

        let frequency = try XCTUnwrap(evidence.item(for: .frequency))
        XCTAssertEqual(frequency.blockedReasons, [
            .liveOrderFrequencyRuntimeForbidden,
            .realPreTradeAllowRejectRuntimeForbidden,
            .readModelOnlyBoundaryRequired
        ])
        XCTAssertFalse(frequency.invokesRuntimeControl)
        XCTAssertFalse(frequency.authorizesLiveRiskDecision)

        let circuitBreaker = try XCTUnwrap(evidence.item(for: .circuitBreaker))
        XCTAssertEqual(circuitBreaker.blockedReasons, [
            .circuitBreakerRuntimeForbidden,
            .stopEmergencyCommandForbidden,
            .riskCommandSurfaceForbidden,
            .readModelOnlyBoundaryRequired
        ])

        XCTAssertTrue(LiveExposureOrderNotionalGateBoundary.deterministicFixture.allPreTradeDecisionsBlocked)
        XCTAssertTrue(LiveFrequencyLossDrawdownGateBoundary.deterministicFixture.allPreTradeDecisionsBlocked)
        XCTAssertTrue(LiveCircuitBreakerNoTradeGateBoundary.deterministicFixture.allPreTradeDecisionsBlocked)
        XCTAssertTrue(LivePaperRiskLiveDecisionIsolationBoundary.deterministicFixture.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertFalse(evidence.evaluatesRealPreTradeAllow)
        XCTAssertFalse(evidence.evaluatesRealPreTradeReject)
        XCTAssertFalse(evidence.runsCircuitBreakerRuntime)
        XCTAssertFalse(evidence.entersNoTradeStateRuntime)
    }

    func testLiveAuditIncidentStopTerminologyDefinesMTP89FutureOnlyTaxonomy() throws {
        // 测试场景：MTP-89 只定义 Live audit / incident / stop terminology、
        // future taxonomy 和 validation anchors。所有 incident replay、stop command、
        // production operations、Live PRO Console 和交易 UI 旗标都必须保持关闭。
        let boundary = LiveAuditIncidentStopTerminologyBoundary.deterministicFixture

        XCTAssertEqual(
            boundary.contractID,
            try Identifier("mtp-89-live-audit-incident-stop-terminology")
        )
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-89"))
        XCTAssertEqual(boundary.terms, LiveAuditIncidentStopTerm.allCases)
        XCTAssertEqual(
            boundary.taxonomy,
            [
                .signalAuditTrail,
                .orderAuditTrail,
                .riskDecisionAuditTrail,
                .fillAuditTrail,
                .incidentReplay,
                .stopControl,
                .emergencyStop,
                .shutdown,
                .restore,
                .productionOperations
            ]
        )
        XCTAssertEqual(
            boundary.futureGates,
            [
                .humanLiveAuditIncidentStopDecision,
                .liveTradingFoundationBoundarySatisfied,
                .liveExecutionControlBoundarySatisfied,
                .liveRiskGateBoundarySatisfied,
                .auditTrailContractDefined,
                .incidentReplayContractDefined,
                .stopControlContractDefined,
                .emergencyStopShutdownRestoreContractDefined,
                .productionOperationsContractDefined,
                .readModelOnlyBlockedEvidenceDefined,
                .dashboardReportTimelineEvidenceBoundaryDefined,
                .liveProConsoleIndependentProjectDefinition
            ]
        )
        XCTAssertEqual(boundary.forbiddenCapabilities, LiveAuditIncidentStopForbiddenCapability.allCases)
        XCTAssertTrue(boundary.forbidsCapability(.signedEndpoint))
        XCTAssertTrue(boundary.forbidsCapability(.brokerAction))
        XCTAssertTrue(boundary.forbidsCapability(.incidentReplayRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.emergencyStopCommand))
        XCTAssertTrue(boundary.forbidsCapability(.shutdownCommand))
        XCTAssertTrue(boundary.forbidsCapability(.restoreCommand))
        XCTAssertTrue(boundary.forbidsCapability(.liveProConsole))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .validationMatrixCandidate,
                .validationPlanAnchor,
                .deterministicForbiddenTest,
                .futureGateTaxonomy,
                .blockedEvidenceBoundary,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY",
            "MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY",
            "MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES",
            "MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND",
            "MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE",
            "MTP-89-LIVE-AUDIT-INCIDENT-STOP-VALIDATION",
            "TVM-LIVE-AUDIT-INCIDENT-STOP"
        ])
        XCTAssertEqual(boundary.blockedEvidenceSourceAnchors, [
            "TVM-LIVE-TRADING-FOUNDATION",
            "TVM-LIVE-EXECUTION-CONTROL",
            "TVM-LIVE-RISK-GATE",
            "MTP-65-LIVE-BLOCKED-EVIDENCE",
            "MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE",
            "MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE",
            "MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY"
        ])
        XCTAssertTrue(boundary.terminologyBoundaryHeld)
        XCTAssertTrue(boundary.taxonomyBoundaryHeld)
        XCTAssertTrue(boundary.forbiddenCapabilityBoundaryHeld)
        XCTAssertTrue(boundary.productSurfaceBoundaryHeld)
        XCTAssertTrue(boundary.isFutureOnlyTerminology)
        XCTAssertTrue(boundary.representsBlockedEvidenceOnly)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.executesBrokerAction)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.implementsOMS)
        XCTAssertFalse(boundary.implementsRealOrderStateMachine)
        XCTAssertFalse(boundary.providesIncidentReplayRuntime)
        XCTAssertFalse(boundary.runsStopControlRuntime)
        XCTAssertFalse(boundary.runsEmergencyStopCommand)
        XCTAssertFalse(boundary.runsShutdownCommand)
        XCTAssertFalse(boundary.runsRestoreCommand)
        XCTAssertFalse(boundary.runsProductionOperations)
        XCTAssertFalse(boundary.exposesLiveProConsole)
        XCTAssertFalse(boundary.providesLiveCommand)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveAuditIncidentStopTerminologyBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testLiveAuditIncidentStopTerminologyRejectsMTP89RuntimeCommandAndConsoleBypass() throws {
        // 测试场景：MTP-89 fixture 的初始化和 Codable 解码都必须拒绝
        // signed/account/listenKey、broker action、incident replay runtime、stop commands、
        // production operations、Live PRO Console、live command 和交易按钮绕过。
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(callsAccountEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("callsAccountEndpoint"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(createsListenKey: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("createsListenKey"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(executesBrokerAction: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("executesBrokerAction"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(providesIncidentReplayRuntime: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("providesIncidentReplayRuntime")
            )
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(runsEmergencyStopCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsEmergencyStopCommand"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(runsShutdownCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsShutdownCommand"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(runsRestoreCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsRestoreCommand"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(runsProductionOperations: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsProductionOperations"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(exposesLiveProConsole: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesLiveProConsole"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(providesLiveCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesLiveCommand"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(providesTradingButton: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesTradingButton"))
        }
        XCTAssertThrowsError(
            try LiveAuditIncidentStopTerminologyBoundary(
                taxonomy: [.signalAuditTrail, .incidentReplay]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "taxonomy",
                    expected: LiveAuditIncidentStopTerminologyBoundary
                        .requiredTaxonomy
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "signal audit trail,incident replay"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveAuditIncidentStopTerminologyBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["treatsWorkbenchAsLiveProConsole"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveAuditIncidentStopTerminologyBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("treatsWorkbenchAsLiveProConsole")
            )
        }
    }

    func testLiveAuditIncidentStopTerminologyKeepsMTP89BlockedEvidenceFutureOnly() throws {
        // 测试场景：MTP-89 只能引用既有 Live blocked / execution-control / risk gate evidence
        // 作为 source anchor，不能把这些只读证据升级成 incident replay runtime、stop command、
        // production operations、Live PRO Console 或 live command surface。
        let boundary = LiveAuditIncidentStopTerminologyBoundary.deterministicFixture
        let executionEvidence = LiveExecutionControlBlockedEvidence.deterministicFixture
        let riskEvidence = LiveRiskGateBlockedEvidence.deterministicFixture

        XCTAssertTrue(boundary.representsBlockedEvidenceOnly)
        XCTAssertTrue(boundary.blockedEvidenceSourceAnchors.contains("MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE"))
        XCTAssertTrue(boundary.blockedEvidenceSourceAnchors.contains("MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE"))
        XCTAssertTrue(boundary.forbidsCapability(.auditTrailRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.incidentReplayRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.stopControlRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.productionOperationsRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.workbenchLiveProConsoleUpgrade))
        XCTAssertTrue(boundary.forbidsCapability(.dashboardLiveProConsoleUpgrade))

        XCTAssertTrue(executionEvidence.blockedEvidenceBoundaryHeld)
        XCTAssertTrue(executionEvidence.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertFalse(executionEvidence.providesCommandSurface)
        XCTAssertFalse(executionEvidence.submitsRealOrder)

        XCTAssertTrue(riskEvidence.blockedEvidenceBoundaryHeld)
        XCTAssertTrue(riskEvidence.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertFalse(riskEvidence.providesCommandSurface)
        XCTAssertFalse(riskEvidence.providesTradingButton)

        XCTAssertFalse(boundary.recordsAuditTrailRuntime)
        XCTAssertFalse(boundary.providesIncidentReplayRuntime)
        XCTAssertFalse(boundary.runsStopControlRuntime)
        XCTAssertFalse(boundary.runsEmergencyStopCommand)
        XCTAssertFalse(boundary.runsShutdownCommand)
        XCTAssertFalse(boundary.runsRestoreCommand)
        XCTAssertFalse(boundary.runsProductionOperations)
        XCTAssertFalse(boundary.exposesLiveProConsole)
        XCTAssertFalse(boundary.providesLiveCommand)
    }

    func testMTP90LiveAuditTrailFutureGatesDefineSignalOrderRiskDecisionFillBoundary() throws {
        // 测试场景：MTP-90 只定义 signal / order / risk decision / fill 的 Future audit trail gates。
        // 这些 gates 只能作为 contract / validation evidence，不得实现 execution report ingestion、
        // broker fill fact、real order state machine、OMS、broker action 或真实审计 runtime。
        let boundary = LiveAuditTrailFutureGateBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-90-live-audit-trail-future-gates"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-90"))
        XCTAssertEqual(boundary.subjects, [.signal, .order, .riskDecision, .fill])
        XCTAssertEqual(
            boundary.gates(for: .signal),
            [
                .signalSourceContractDefined,
                .signalDecisionPathContractDefined,
                .signalReplayCorrelationContractDefined
            ]
        )
        XCTAssertEqual(
            boundary.gates(for: .order),
            [
                .orderIntentSourceContractDefined,
                .orderStateTransitionContractDefined,
                .orderCommandAuthorizationGateDefined
            ]
        )
        XCTAssertEqual(
            boundary.gates(for: .riskDecision),
            [
                .riskDecisionSourceContractDefined,
                .riskGateOutcomeContractDefined,
                .riskBlockedReasonContractDefined
            ]
        )
        XCTAssertEqual(
            boundary.gates(for: .fill),
            [
                .fillSourceContractDefined,
                .executionReportSourceGateDefined,
                .brokerFillSourceGateDefined
            ]
        )
        XCTAssertEqual(boundary.forbiddenCapabilities, LiveAuditTrailForbiddenCapability.allCases)
        XCTAssertTrue(boundary.forbidsCapability(.executionReportIngestion))
        XCTAssertTrue(boundary.forbidsCapability(.brokerFillFact))
        XCTAssertTrue(boundary.forbidsCapability(.realOrderStateMachine))
        XCTAssertTrue(boundary.forbidsCapability(.oms))
        XCTAssertTrue(boundary.forbidsCapability(.brokerAction))
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES",
            "MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS",
            "MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION",
            "MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE",
            "MTP-90-LIVE-AUDIT-TRAIL-VALIDATION",
            "TVM-LIVE-AUDIT-INCIDENT-STOP"
        ])
        XCTAssertTrue(boundary.auditTrailFutureGateBoundaryHeld)
        XCTAssertTrue(boundary.forbiddenCapabilityBoundaryHeld)
        XCTAssertTrue(boundary.paperEvidenceIsolationBoundaryHeld)
        XCTAssertTrue(boundary.isFutureOnlyAuditTrailContract)
        XCTAssertTrue(boundary.representsBlockedEvidenceOnly)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveAuditTrailFutureGateBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testMTP90LiveAuditTrailFutureGatesRejectExecutionReportBrokerFillOMSAndBrokerAction() throws {
        // 测试场景：MTP-90 的 forbidden capability tests 必须阻断真实 execution report ingestion、
        // broker fill fact / recorder、real order state machine、OMS、broker reconciliation 和 broker action。
        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(ingestsExecutionReport: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("ingestsExecutionReport"))
        }
        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(recordsBrokerFillFact: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("recordsBrokerFillFact"))
        }
        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(recordsBrokerFillRuntime: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("recordsBrokerFillRuntime"))
        }
        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(implementsRealOrderStateMachine: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsRealOrderStateMachine")
            )
        }
        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(implementsOMS: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("implementsOMS"))
        }
        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(performsBrokerReconciliation: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("performsBrokerReconciliation")
            )
        }
        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(executesBrokerAction: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("executesBrokerAction"))
        }
        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(
                futureGates: [.signalSourceContractDefined, .brokerFillSourceGateDefined]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "futureGates",
                    expected: LiveAuditTrailFutureGateBoundary
                        .requiredFutureGates
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "signal source contract defined,broker fill source gate defined"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveAuditTrailFutureGateBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["recordsBrokerFillFact"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveAuditTrailFutureGateBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("recordsBrokerFillFact"))
        }
    }

    func testMTP90LiveAuditTrailFutureGatesKeepPaperEvidenceFromBecomingRealAuditFact() throws {
        // 测试场景：MTP-90 可以引用 paper signal/order/risk/fill evidence 作为 source anchor，
        // 但不能把它们升级为真实 audit fact、broker fill、future live risk decision、
        // execution report runtime 或真实订单状态机。
        let boundary = LiveAuditTrailFutureGateBoundary.deterministicFixture
        let terminology = LiveAuditIncidentStopTerminologyBoundary.deterministicFixture

        XCTAssertTrue(boundary.auditTrailSourceAnchors.contains("PaperOrderIntent"))
        XCTAssertTrue(boundary.auditTrailSourceAnchors.contains("PaperExecutionDecision"))
        XCTAssertTrue(boundary.auditTrailSourceAnchors.contains("RiskBlockerEvidence"))
        XCTAssertTrue(boundary.auditTrailSourceAnchors.contains("PaperSimulatedFillEvidence"))
        XCTAssertTrue(boundary.auditTrailSourceAnchors.contains("MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE"))
        XCTAssertTrue(boundary.auditTrailSourceAnchors.contains("MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE"))
        XCTAssertTrue(terminology.terminologyBoundaryHeld)

        XCTAssertFalse(boundary.upgradesSignalEvidenceToLiveAuditFact)
        XCTAssertFalse(boundary.upgradesPaperOrderToRealOrderAuditFact)
        XCTAssertFalse(boundary.upgradesPaperRiskToLiveRiskDecisionAuditFact)
        XCTAssertFalse(boundary.upgradesSimulatedFillToBrokerFillAuditFact)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.executesBrokerAction)
        XCTAssertFalse(boundary.ingestsExecutionReport)
        XCTAssertFalse(boundary.recordsBrokerFillFact)
        XCTAssertFalse(boundary.implementsRealOrderStateMachine)
        XCTAssertFalse(boundary.implementsOMS)
        XCTAssertFalse(boundary.performsBrokerReconciliation)
        XCTAssertFalse(boundary.recordsAuditTrailRuntime)
        XCTAssertFalse(boundary.submitsCancelsOrReplacesRealOrder)
        XCTAssertFalse(boundary.providesLiveCommand)
        XCTAssertFalse(boundary.exposesOrderLevelCommandUI)
        XCTAssertFalse(boundary.providesTradingButton)

        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(upgradesPaperOrderToRealOrderAuditFact: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("upgradesPaperOrderToRealOrderAuditFact")
            )
        }
        XCTAssertThrowsError(
            try LiveAuditTrailFutureGateBoundary(upgradesSimulatedFillToBrokerFillAuditFact: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("upgradesSimulatedFillToBrokerFillAuditFact")
            )
        }
    }

    func testMTP91IncidentReplayFutureGatesDefineInputScopeEvidenceOutputBoundary() throws {
        // 测试场景：MTP-91 只定义 incident replay 的输入来源、回放范围、回放证据和输出 gates。
        // 当前 Event Log / Replay 仍是 deterministic evidence path，不得被描述为生产事故回放或恢复系统。
        let boundary = LiveIncidentReplayFutureGateBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-91-incident-replay-future-gates"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-91"))
        XCTAssertEqual(
            boundary.futureGates,
            [
                .incidentInputSourceContractDefined,
                .auditTrailInputSourceGateDefined,
                .eventLogEvidenceInputBoundaryDefined,
                .brokerStateInputForbidden,
                .accountStateInputForbidden,
                .replayScopeContractDefined,
                .replayTimeWindowScopeDefined,
                .replayEvidenceSourceContractDefined,
                .deterministicReplayEvidencePathDefined,
                .replayOutputContractDefined,
                .readModelOnlyReplayOutputGateDefined,
                .productionRecoveryOutputForbidden
            ]
        )
        XCTAssertEqual(boundary.forbiddenCapabilities, LiveIncidentReplayForbiddenCapability.allCases)
        XCTAssertTrue(boundary.forbidsCapability(.incidentReplayRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.productionRecoveryRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.brokerReplayRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.accountReplayRuntime))
        XCTAssertTrue(boundary.forbidsCapability(.signedEndpoint))
        XCTAssertEqual(boundary.incidentReplaySourceAnchors, [
            "MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY",
            "MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES",
            "MTP-90-LIVE-AUDIT-TRAIL-VALIDATION",
            "Event Log",
            "Replay",
            "TVM-LIVE-AUDIT-INCIDENT-STOP"
        ])
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-91-INCIDENT-REPLAY-FUTURE-GATES",
            "MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES",
            "MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES",
            "MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS",
            "MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY",
            "MTP-91-INCIDENT-REPLAY-VALIDATION",
            "TVM-LIVE-AUDIT-INCIDENT-STOP"
        ])
        XCTAssertTrue(boundary.incidentReplayFutureGateBoundaryHeld)
        XCTAssertTrue(boundary.deterministicReplayEvidenceBoundaryHeld)
        XCTAssertTrue(boundary.forbiddenCapabilityBoundaryHeld)
        XCTAssertTrue(boundary.isFutureOnlyIncidentReplayContract)
        XCTAssertTrue(boundary.representsDeterministicEvidencePathOnly)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveIncidentReplayFutureGateBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testMTP91IncidentReplayFutureGatesRejectRuntimeRecoveryBrokerAndAccountReplay() throws {
        // 测试场景：MTP-91 的 forbidden capability tests 必须拒绝 incident replay runtime、
        // production recovery、auto restore、broker replay、account replay 和 signed/account/listenKey 绕过。
        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(implementsIncidentReplayRuntime: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("implementsIncidentReplayRuntime")
            )
        }
        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(runsProductionRecovery: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsProductionRecovery"))
        }
        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(runsAutoRestore: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsAutoRestore"))
        }
        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(replaysBrokerEvents: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("replaysBrokerEvents"))
        }
        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(replaysAccountEvents: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("replaysAccountEvents"))
        }
        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(callsAccountEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("callsAccountEndpoint"))
        }
        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(
                futureGates: [.incidentInputSourceContractDefined, .productionRecoveryOutputForbidden]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "futureGates",
                    expected: LiveIncidentReplayFutureGateBoundary
                        .requiredFutureGates
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "incident input source contract defined,production recovery output forbidden"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveIncidentReplayFutureGateBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["readsRealAccountState"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveIncidentReplayFutureGateBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("readsRealAccountState"))
        }
    }

    func testMTP91IncidentReplayFutureGatesKeepCurrentReplayDeterministicEvidenceOnly() throws {
        // 测试场景：MTP-91 可以引用当前 Event Log / Replay 作为 deterministic evidence path，
        // 但不能把它们升级为生产恢复、broker replay、account replay、Live PRO Console 或 live command。
        let boundary = LiveIncidentReplayFutureGateBoundary.deterministicFixture
        let auditTrailBoundary = LiveAuditTrailFutureGateBoundary.deterministicFixture

        XCTAssertTrue(boundary.incidentReplaySourceAnchors.contains("Event Log"))
        XCTAssertTrue(boundary.incidentReplaySourceAnchors.contains("Replay"))
        XCTAssertTrue(boundary.incidentReplaySourceAnchors.contains("MTP-90-LIVE-AUDIT-TRAIL-VALIDATION"))
        XCTAssertTrue(auditTrailBoundary.auditTrailFutureGateBoundaryHeld)
        XCTAssertTrue(boundary.representsDeterministicEvidencePathOnly)

        XCTAssertFalse(boundary.treatsCurrentReplayAsProductionIncidentReplay)
        XCTAssertFalse(boundary.implementsIncidentReplayRuntime)
        XCTAssertFalse(boundary.readsRealAccountState)
        XCTAssertFalse(boundary.readsBrokerState)
        XCTAssertFalse(boundary.replaysBrokerEvents)
        XCTAssertFalse(boundary.replaysAccountEvents)
        XCTAssertFalse(boundary.runsProductionRecovery)
        XCTAssertFalse(boundary.runsAutoRestore)
        XCTAssertFalse(boundary.performsAutoRollback)
        XCTAssertFalse(boundary.mutatesProductionRuntime)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.executesBrokerAction)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.implementsOMS)
        XCTAssertFalse(boundary.implementsRealOrderStateMachine)
        XCTAssertFalse(boundary.ingestsExecutionReport)
        XCTAssertFalse(boundary.recordsBrokerFillFact)
        XCTAssertFalse(boundary.recordsAuditTrailRuntime)
        XCTAssertFalse(boundary.runsProductionOperations)
        XCTAssertFalse(boundary.providesLiveCommand)
        XCTAssertFalse(boundary.exposesLiveProConsole)
        XCTAssertFalse(boundary.providesTradingButton)

        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(treatsCurrentReplayAsProductionIncidentReplay: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("treatsCurrentReplayAsProductionIncidentReplay")
            )
        }
        XCTAssertThrowsError(
            try LiveIncidentReplayFutureGateBoundary(mutatesProductionRuntime: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("mutatesProductionRuntime"))
        }
    }

    func testMTP92StopShutdownRestoreFutureGatesDefineFutureOnlyBoundary() throws {
        // 测试场景：MTP-92 只定义 emergency stop / shutdown / restore 的 Future gates。
        // 这些 gates 只能作为合同、validation anchor 和 forbidden capability evidence，
        // 不能成为当前停机、恢复、生产运维、Live PRO Console、live command 或交易按钮。
        let boundary = LiveStopShutdownRestoreFutureGateBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-92-stop-shutdown-restore-future-gates"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-92"))
        XCTAssertEqual(
            boundary.futureGates,
            [
                .emergencyStopPolicyContractDefined,
                .emergencyStopTriggerSourceGateDefined,
                .emergencyStopAuthorizationGateDefined,
                .emergencyStopReadModelOnlyBlockedEvidenceDefined,
                .shutdownPolicyContractDefined,
                .shutdownScopeContractDefined,
                .shutdownProductionOperationsHandoffGateDefined,
                .restorePolicyContractDefined,
                .restoreReadinessEvidenceGateDefined,
                .restoreAuthorizationGateDefined,
                .circuitBreakerNoTradeSeparationDefined,
                .liveRiskGateNoStopRuntimeSeparationDefined
            ]
        )
        XCTAssertEqual(boundary.forbiddenCapabilities, LiveStopShutdownRestoreForbiddenCapability.allCases)
        XCTAssertTrue(boundary.forbidsCapability(.emergencyStopCommand))
        XCTAssertTrue(boundary.forbidsCapability(.shutdownCommand))
        XCTAssertTrue(boundary.forbidsCapability(.restoreCommand))
        XCTAssertTrue(boundary.forbidsCapability(.globalTradingLock))
        XCTAssertTrue(boundary.forbidsCapability(.brokerSessionMutation))
        XCTAssertTrue(boundary.forbidsCapability(.productionShutdownControl))
        XCTAssertTrue(boundary.forbidsCapability(.liveProConsole))
        XCTAssertEqual(boundary.stopControlSourceAnchors, [
            "MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY",
            "MTP-90-LIVE-AUDIT-TRAIL-VALIDATION",
            "MTP-91-INCIDENT-REPLAY-VALIDATION",
            "MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES",
            "MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE",
            "LiveCircuitBreakerNoTradeGateBoundary",
            "TVM-LIVE-AUDIT-INCIDENT-STOP"
        ])
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES",
            "MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS",
            "MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE",
            "MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN",
            "MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION",
            "TVM-LIVE-AUDIT-INCIDENT-STOP"
        ])
        XCTAssertTrue(boundary.stopShutdownRestoreFutureGateBoundaryHeld)
        XCTAssertTrue(boundary.riskGateSeparationBoundaryHeld)
        XCTAssertTrue(boundary.forbiddenCapabilityBoundaryHeld)
        XCTAssertTrue(boundary.isFutureOnlyStopShutdownRestoreContract)
        XCTAssertTrue(boundary.representsBlockedEvidenceOnly)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveStopShutdownRestoreFutureGateBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testMTP92StopShutdownRestoreFutureGatesRejectCommandsBrokerMutationAndProductionOperations() throws {
        // 测试场景：MTP-92 的 forbidden capability tests 必须拒绝 stop / shutdown / restore command、
        // global trading lock、broker session mutation、production shutdown control、signed endpoint
        // 和 Live PRO Console 绕过。
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(runsEmergencyStopCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsEmergencyStopCommand"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(runsShutdownCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsShutdownCommand"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(runsRestoreCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsRestoreCommand"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(createsGlobalTradingLock: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("createsGlobalTradingLock"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(mutatesBrokerSession: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("mutatesBrokerSession"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(runsProductionShutdownControl: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("runsProductionShutdownControl")
            )
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(exposesLiveProConsole: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesLiveProConsole"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(
                futureGates: [.emergencyStopPolicyContractDefined, .restorePolicyContractDefined]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "futureGates",
                    expected: LiveStopShutdownRestoreFutureGateBoundary
                        .requiredFutureGates
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "emergency stop policy contract defined,restore policy contract defined"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveStopShutdownRestoreFutureGateBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["mutatesBrokerSession"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveStopShutdownRestoreFutureGateBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("mutatesBrokerSession"))
        }
    }

    func testMTP92StopShutdownRestoreFutureGatesKeepRiskCircuitBreakerAndNoTradeSeparate() throws {
        // 测试场景：MTP-92 可以引用 MTP-85 risk gate evidence 作为 source anchor，
        // 但不得把 circuit breaker / no-trade state 写成当前 emergency stop、shutdown、
        // restore decision、live runtime resume 或生产停机控制能力。
        let boundary = LiveStopShutdownRestoreFutureGateBoundary.deterministicFixture
        let riskBoundary = LiveCircuitBreakerNoTradeGateBoundary.deterministicFixture

        XCTAssertTrue(boundary.stopControlSourceAnchors.contains("MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES"))
        XCTAssertTrue(boundary.stopControlSourceAnchors.contains("LiveCircuitBreakerNoTradeGateBoundary"))
        XCTAssertTrue(riskBoundary.circuitBreakerNoTradeBoundaryHeld)
        XCTAssertTrue(boundary.riskGateSeparationBoundaryHeld)

        XCTAssertFalse(boundary.runsLiveRiskEngine)
        XCTAssertFalse(boundary.runsCircuitBreakerRuntime)
        XCTAssertFalse(boundary.entersNoTradeStateRuntime)
        XCTAssertFalse(boundary.treatsCircuitBreakerAsEmergencyStop)
        XCTAssertFalse(boundary.treatsNoTradeStateAsShutdown)
        XCTAssertFalse(boundary.producesRestoreDecision)
        XCTAssertFalse(boundary.resumesLiveRuntime)
        XCTAssertFalse(boundary.providesLiveCommand)
        XCTAssertFalse(boundary.providesStopButton)
        XCTAssertFalse(boundary.providesTradingButton)

        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(runsCircuitBreakerRuntime: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsCircuitBreakerRuntime"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(entersNoTradeStateRuntime: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("entersNoTradeStateRuntime"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(treatsCircuitBreakerAsEmergencyStop: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("treatsCircuitBreakerAsEmergencyStop")
            )
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(treatsNoTradeStateAsShutdown: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("treatsNoTradeStateAsShutdown"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(producesRestoreDecision: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("producesRestoreDecision"))
        }
        XCTAssertThrowsError(
            try LiveStopShutdownRestoreFutureGateBoundary(resumesLiveRuntime: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("resumesLiveRuntime"))
        }
    }

    func testMTP93BlockedEvidenceIsolationDefinesReadModelOnlyBoundary() throws {
        // 测试场景：MTP-93 只定义 Live execution / risk blocked evidence 与 future
        // incident / stop boundary 的隔离合同。该 fixture 只能输出合同、source anchor
        // 和 forbidden capability evidence，不能提供 runtime、command、Live PRO Console 或交易按钮。
        let boundary = LiveBlockedEvidenceIncidentStopIsolationBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-93-blocked-evidence-incident-stop-isolation"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-93"))
        XCTAssertEqual(boundary.isolationGates, [
            .executionControlBlockedEvidenceStaysReadModelOnly,
            .riskGateBlockedEvidenceStaysReadModelOnly,
            .paperOrderIntentStaysPaperOnly,
            .simulatedFillStaysPaperOnly,
            .paperExposureStaysPaperOnly,
            .incidentReplayRuntimeUpgradeForbidden,
            .stopShutdownRestoreCommandUpgradeForbidden,
            .liveConsoleCommandUpgradeForbidden
        ])
        XCTAssertEqual(
            boundary.forbiddenCapabilities,
            LiveBlockedEvidenceIncidentStopForbiddenCapability.allCases
        )
        XCTAssertTrue(boundary.forbidsCapability(.executionBlockedEvidenceToIncidentCommand))
        XCTAssertTrue(boundary.forbidsCapability(.riskBlockedEvidenceToEmergencyStop))
        XCTAssertTrue(boundary.forbidsCapability(.paperExposureToStopDecision))
        XCTAssertTrue(boundary.forbidsCapability(.liveCommandSurface))
        XCTAssertEqual(boundary.blockedEvidenceSourceAnchors, [
            "MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE",
            "LiveExecutionControlBlockedEvidence",
            "MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE",
            "LiveRiskGateBlockedEvidence",
            "RiskBlockerEvidence",
            "PaperOrderIntent",
            "PaperSimulatedFillEvidence",
            "PortfolioExposureSnapshot",
            "MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE",
            "MTP-91-INCIDENT-REPLAY-VALIDATION",
            "MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION",
            "TVM-LIVE-AUDIT-INCIDENT-STOP"
        ])
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION",
            "MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE",
            "MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE",
            "MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS",
            "MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION",
            "TVM-LIVE-AUDIT-INCIDENT-STOP"
        ])
        XCTAssertTrue(boundary.isolationBoundaryHeld)
        XCTAssertTrue(boundary.executionRiskBlockedEvidenceIsolationHeld)
        XCTAssertTrue(boundary.paperEvidenceIsolationHeld)
        XCTAssertTrue(boundary.forbiddenCapabilityBoundaryHeld)
        XCTAssertTrue(boundary.isIsolationContractOnly)
        XCTAssertTrue(boundary.keepsExecutionControlBlockedEvidenceReadModelOnly)
        XCTAssertTrue(boundary.keepsRiskGateBlockedEvidenceReadModelOnly)
        XCTAssertTrue(boundary.keepsPaperEvidencePaperOnly)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(
            LiveBlockedEvidenceIncidentStopIsolationBoundary.self,
            from: encoded
        )
        XCTAssertEqual(decoded, boundary)
    }

    func testMTP93BlockedEvidenceIsolationRejectsCommandRuntimeAndConsoleUpgrade() throws {
        // 测试场景：MTP-93 的 forbidden capability tests 必须拒绝把 blocked evidence
        // 升级成 incident command、stop command、restore decision、runtime、signed endpoint
        // 或 Live PRO Console。
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(
                mapsExecutionBlockedEvidenceToIncidentCommand: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsExecutionBlockedEvidenceToIncidentCommand")
            )
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(mapsExecutionBlockedEvidenceToStopCommand: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsExecutionBlockedEvidenceToStopCommand")
            )
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(mapsRiskBlockedEvidenceToEmergencyStop: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsRiskBlockedEvidenceToEmergencyStop")
            )
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(runsIncidentReplayRuntime: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsIncidentReplayRuntime"))
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(runsStopCommand: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsStopCommand"))
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(exposesLiveProConsole: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesLiveProConsole"))
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(
                isolationGates: [.executionControlBlockedEvidenceStaysReadModelOnly]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryContractMismatch(
                    field: "isolationGates",
                    expected: LiveBlockedEvidenceIncidentStopIsolationBoundary
                        .requiredIsolationGates
                        .map(\.rawValue)
                        .joined(separator: ","),
                    actual: "execution-control blocked evidence stays read-model-only"
                )
            )
        }

        let encoded = try JSONEncoder().encode(LiveBlockedEvidenceIncidentStopIsolationBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["mapsRiskBlockedEvidenceToIncidentReplayRuntime"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveBlockedEvidenceIncidentStopIsolationBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsRiskBlockedEvidenceToIncidentReplayRuntime")
            )
        }
    }

    func testMTP93BlockedEvidenceIsolationKeepsPaperEvidenceAndReadModelsFromIncidentStopUpgrade() throws {
        // 测试场景：MTP-93 可以引用 execution-control blocked evidence、risk gate blocked evidence
        // 和 paper-only evidence 作为 source anchors，但不得把它们写成 incident runtime、
        // stop decision、restore decision、production fact 或 live command。
        let boundary = LiveBlockedEvidenceIncidentStopIsolationBoundary.deterministicFixture
        let executionEvidence = LiveExecutionControlBlockedEvidence.deterministicFixture
        let riskEvidence = LiveRiskGateBlockedEvidence.deterministicFixture
        let paperOrder = try PaperOrderIntentFixture.deterministicAllowed()
        let simulatedFill = try PaperSimulatedFillFixture.deterministicAllowed()

        XCTAssertTrue(executionEvidence.blockedEvidenceBoundaryHeld)
        XCTAssertTrue(riskEvidence.blockedEvidenceBoundaryHeld)
        XCTAssertTrue(boundary.blockedEvidenceSourceAnchors.contains("LiveExecutionControlBlockedEvidence"))
        XCTAssertTrue(boundary.blockedEvidenceSourceAnchors.contains("LiveRiskGateBlockedEvidence"))
        XCTAssertTrue(boundary.blockedEvidenceSourceAnchors.contains("PaperOrderIntent"))
        XCTAssertTrue(boundary.blockedEvidenceSourceAnchors.contains("PaperSimulatedFillEvidence"))
        XCTAssertTrue(boundary.blockedEvidenceSourceAnchors.contains("PortfolioExposureSnapshot"))
        XCTAssertTrue(paperOrder.paperOnlyBoundaryHeld)
        XCTAssertTrue(simulatedFill.isSimulatedFillEvidence)
        XCTAssertFalse(boundary.mapsPaperOrderIntentToIncidentCommand)
        XCTAssertFalse(boundary.mapsSimulatedFillToProductionIncidentFact)
        XCTAssertFalse(boundary.mapsPaperExposureToStopDecision)
        XCTAssertFalse(boundary.runsProductionOperations)
        XCTAssertFalse(boundary.providesLiveCommand)
        XCTAssertFalse(boundary.providesTradingButton)

        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(mapsPaperOrderIntentToIncidentCommand: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsPaperOrderIntentToIncidentCommand")
            )
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(mapsSimulatedFillToProductionIncidentFact: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("mapsSimulatedFillToProductionIncidentFact")
            )
        }
        XCTAssertThrowsError(
            try LiveBlockedEvidenceIncidentStopIsolationBoundary(mapsPaperExposureToStopDecision: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("mapsPaperExposureToStopDecision"))
        }
    }

    func testMTP94LiveIncidentStopBlockedEvidenceDefinesReadModelOnlySnapshot() throws {
        // 测试场景：MTP-94 只输出 Live audit / incident / stop 的 blocked evidence snapshot。
        // 它可以列出 audit trail、incident replay、emergency stop、shutdown、restore 的阻断原因，
        // 但不能提供停机、恢复、事故回放 runtime、Live PRO Console、live command 或交易按钮。
        let evidence = LiveIncidentStopBlockedEvidence.deterministicFixture

        XCTAssertEqual(evidence.contractID, try Identifier("mtp-94-live-incident-stop-blocked-evidence"))
        XCTAssertEqual(evidence.issueID, try Identifier("MTP-94"))
        XCTAssertEqual(evidence.blockedItems.map(\.gate), [
            .auditTrail,
            .incidentReplay,
            .emergencyStop,
            .shutdown,
            .restore
        ])
        XCTAssertEqual(evidence.blockedItems.count, 5)
        XCTAssertEqual(evidence.blockedItems.map(\.gate), LiveIncidentStopBlockedGate.allCases)
        XCTAssertTrue(evidence.blockedItems.allSatisfy(\.isBlocked))
        XCTAssertTrue(evidence.blockedItems.allSatisfy(\.readModelOnlyBoundaryHeld))
        XCTAssertTrue(evidence.allIncidentStopGatesBlocked)
        XCTAssertTrue(evidence.blockedEvidenceBoundaryHeld)
        XCTAssertTrue(evidence.appSurfaceReadModelOnlyBoundaryHeld)
        XCTAssertTrue(evidence.forbiddenImplementationBoundaryHeld)
        XCTAssertEqual(evidence.validationAnchors, [
            "MTP-94-LIVE-INCIDENT-STOP-BLOCKED-EVIDENCE",
            "MTP-94-AUDIT-INCIDENT-STOP-BLOCKED-REASONS",
            "MTP-94-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT",
            "MTP-94-READ-MODEL-ONLY-NO-COMMAND-SURFACE",
            "MTP-94-LIVE-INCIDENT-STOP-VALIDATION",
            "TVM-LIVE-AUDIT-INCIDENT-STOP"
        ])
        XCTAssertTrue(evidence.sourceAnchors.contains("MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES"))
        XCTAssertTrue(evidence.sourceAnchors.contains("MTP-91-INCIDENT-REPLAY-FUTURE-GATES"))
        XCTAssertTrue(evidence.sourceAnchors.contains("MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES"))
        XCTAssertTrue(evidence.sourceAnchors.contains("MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION"))
        XCTAssertTrue(evidence.deterministicSnapshot.first?.hasPrefix("audit trail|blocked|") == true)
        XCTAssertTrue(
            evidence.deterministicSnapshot.contains {
                $0.contains("restore|blocked|") && $0.contains("Live PRO Console forbidden")
            }
        )

        XCTAssertFalse(evidence.providesIncidentReplay)
        XCTAssertFalse(evidence.providesStopControl)
        XCTAssertFalse(evidence.providesEmergencyStopCommand)
        XCTAssertFalse(evidence.providesShutdownCommand)
        XCTAssertFalse(evidence.providesRestoreCommand)
        XCTAssertFalse(evidence.exposesLiveProConsole)
        XCTAssertFalse(evidence.providesStopButton)
        XCTAssertFalse(evidence.providesTradingButton)
        XCTAssertFalse(evidence.usesSignedEndpoint)
        XCTAssertFalse(evidence.callsAccountEndpoint)
        XCTAssertFalse(evidence.createsListenKey)
        XCTAssertFalse(evidence.executesBrokerAction)
        XCTAssertFalse(evidence.implementsLiveExecutionAdapter)
        XCTAssertFalse(evidence.implementsOMS)
        XCTAssertFalse(evidence.implementsRealOrderStateMachine)
        XCTAssertFalse(evidence.runsAuditTrailRuntime)
        XCTAssertFalse(evidence.runsIncidentReplayRuntime)
        XCTAssertFalse(evidence.runsProductionOperations)
        XCTAssertFalse(evidence.mutatesBrokerSessionState)
        XCTAssertFalse(evidence.resumesLiveRuntime)
        XCTAssertFalse(evidence.requiredValidationDependsOnNetwork)

        let encoded = try JSONEncoder().encode(evidence)
        let decoded = try JSONDecoder().decode(LiveIncidentStopBlockedEvidence.self, from: encoded)
        XCTAssertEqual(decoded, evidence)
    }

    func testMTP94LiveIncidentStopBlockedEvidenceRejectsCommandRuntimeAndConsoleSurface() throws {
        // 测试场景：MTP-94 的 deterministic model 必须拒绝任何 stop / shutdown /
        // restore command、incident replay runtime、production operations、Live PRO Console、
        // signed/account/listenKey、broker action 或 stop button。
        XCTAssertThrowsError(
            try LiveIncidentStopBlockedEvidence(providesIncidentReplay: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesIncidentReplay"))
        }
        XCTAssertThrowsError(
            try LiveIncidentStopBlockedEvidence(providesStopControl: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesStopControl"))
        }
        XCTAssertThrowsError(
            try LiveIncidentStopBlockedEvidence(providesEmergencyStopCommand: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("providesEmergencyStopCommand")
            )
        }
        XCTAssertThrowsError(
            try LiveIncidentStopBlockedEvidence(exposesLiveProConsole: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("exposesLiveProConsole"))
        }
        XCTAssertThrowsError(
            try LiveIncidentStopBlockedEvidence(providesStopButton: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("providesStopButton"))
        }
        XCTAssertThrowsError(
            try LiveIncidentStopBlockedEvidence(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try LiveIncidentStopBlockedEvidence(runsProductionOperations: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsProductionOperations"))
        }

        var blockedItems = LiveIncidentStopBlockedEvidence.requiredBlockedItems
        blockedItems[0] = LiveIncidentStopBlockedEvidenceItem(
            gate: .auditTrail,
            blockedReasons: [.auditTrailRuntimeForbidden],
            sourceAnchors: ["MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES"],
            emitsCommand: true
        )

        XCTAssertThrowsError(
            try LiveIncidentStopBlockedEvidence(blockedItems: blockedItems)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .liveTradingBoundaryForbiddenCapability("audit trail.readModelOnlyBoundaryHeld")
            )
        }

        let encoded = try JSONEncoder().encode(LiveIncidentStopBlockedEvidence.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["runsIncidentReplayRuntime"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(LiveIncidentStopBlockedEvidence.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .liveTradingBoundaryForbiddenCapability("runsIncidentReplayRuntime"))
        }
    }

    func testMTP94LiveIncidentStopBlockedEvidenceReferencesPriorFutureGateBoundaries() throws {
        // 测试场景：MTP-94 只能引用 MTP-90 至 MTP-93 已建立的 future gates 和 isolation
        // anchors 作为 blocked reason 来源，不能把这些 anchors 升级为当前 runtime 或 command。
        let evidence = LiveIncidentStopBlockedEvidence.deterministicFixture
        let auditTrail = try XCTUnwrap(evidence.item(for: .auditTrail))
        let incidentReplay = try XCTUnwrap(evidence.item(for: .incidentReplay))
        let emergencyStop = try XCTUnwrap(evidence.item(for: .emergencyStop))
        let shutdown = try XCTUnwrap(evidence.item(for: .shutdown))
        let restore = try XCTUnwrap(evidence.item(for: .restore))

        XCTAssertTrue(auditTrail.sourceAnchors.contains("MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS"))
        XCTAssertTrue(incidentReplay.sourceAnchors.contains("MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS"))
        XCTAssertTrue(emergencyStop.sourceAnchors.contains("MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS"))
        XCTAssertTrue(shutdown.sourceAnchors.contains("MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE"))
        XCTAssertTrue(restore.sourceAnchors.contains("MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE"))
        XCTAssertTrue(evidence.sourceAnchors.contains("TVM-LIVE-AUDIT-INCIDENT-STOP"))

        XCTAssertTrue(auditTrail.blockedReasons.contains(.auditTrailRuntimeForbidden))
        XCTAssertTrue(incidentReplay.blockedReasons.contains(.incidentReplayRuntimeForbidden))
        XCTAssertTrue(emergencyStop.blockedReasons.contains(.emergencyStopCommandForbidden))
        XCTAssertTrue(shutdown.blockedReasons.contains(.shutdownCommandForbidden))
        XCTAssertTrue(restore.blockedReasons.contains(.restoreCommandForbidden))
        XCTAssertTrue(restore.blockedReasons.contains(.liveProConsoleForbidden))

        XCTAssertFalse(evidence.consumesExecutionReport)
        XCTAssertFalse(evidence.recordsBrokerFill)
        XCTAssertFalse(evidence.performsReconciliation)
        XCTAssertFalse(evidence.providesCommandSurface)
        XCTAssertFalse(evidence.authorizesLiveTrading)
    }

    func testMTP96TradingClockDefinesDeterministicReplayTicks() throws {
        // 测试场景：MTP-96 TradingClock 必须由 deterministic fixture / replay tick 驱动，
        // 不能依赖 Date()、exchange clock、broker session clock 或生产调度器。
        let clock = TradingClock.deterministicFixture

        XCTAssertEqual(clock.clockID, try Identifier("mtp-96-trading-clock-deterministic-fixture"))
        XCTAssertEqual(clock.issueID, try Identifier("MTP-96"))
        XCTAssertEqual(clock.ticks.map(\.sequence), [1, 2, 3])
        XCTAssertEqual(clock.instants.map(\.timeIntervalSince1970), [
            1_700_000_000,
            1_700_000_060,
            1_700_000_120
        ])
        XCTAssertEqual(clock.ticks.map(\.source), [.deterministicFixture, .deterministicFixture, .replay])
        XCTAssertNil(clock.ticks[0].replaySourceSequence)
        XCTAssertEqual(clock.ticks[2].replaySourceSequence, 2)
        XCTAssertEqual(clock.instant(for: 2), Date(timeIntervalSince1970: 1_700_000_060))
        XCTAssertTrue(clock.isDeterministic)
        XCTAssertTrue(clock.validationAnchors.contains("MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME"))

        let encoded = try JSONEncoder().encode(clock)
        let decoded = try JSONDecoder().decode(TradingClock.self, from: encoded)
        XCTAssertEqual(decoded, clock)
    }

    func testMTP96PaperRuntimeKernelBoundaryDefinesPaperOnlyFixture() throws {
        // 测试场景：MTP-96 kernel boundary 只定义 paper / local / replay 输入输出、lifecycle 和
        // validation anchors，不实现 MTP-97+ bus routing、Paper RiskEngine、lifecycle coordinator 或 UI。
        let boundary = PaperRuntimeKernelBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-96-paper-runtime-kernel-boundary"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-96"))
        XCTAssertEqual(boundary.lifecycleStates, PaperRuntimeKernelLifecycleState.allCases)
        XCTAssertEqual(boundary.allowedInputs, PaperRuntimeKernelInputKind.allCases)
        XCTAssertEqual(boundary.allowedOutputs, PaperRuntimeKernelOutputKind.allCases)
        XCTAssertEqual(boundary.eventStreams, [.paper, .replay])
        XCTAssertEqual(boundary.validationAnchors, [
            "TVM-PAPER-RUNTIME-KERNEL",
            "MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME",
            "MTP-96-PAPER-RUNTIME-KERNEL-BOUNDARY",
            "MTP-96-PAPER-ONLY-KERNEL-EVENTS",
            "MTP-96-NO-UI-STATE-OR-PERSISTENCE-SCHEMA",
            "MTP-96-NO-LIVE-SIGNED-BROKER-RUNTIME",
            "MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION"
        ])
        XCTAssertTrue(boundary.accepts(.tradingClockTick))
        XCTAssertTrue(boundary.accepts(.paperSessionCommand))
        XCTAssertTrue(boundary.accepts(.eventReplayCommand))
        XCTAssertTrue(boundary.emits(.paperEventEnvelope))
        XCTAssertTrue(boundary.emits(.replayResult))
        XCTAssertTrue(boundary.paperOnlyBoundaryHeld)
        XCTAssertTrue(boundary.moduleBoundaryHeld)
        XCTAssertTrue(boundary.deterministicFixtureBoundaryHeld)
        XCTAssertFalse(boundary.exposesUIState)
        XCTAssertFalse(boundary.exposesPersistenceSchema)
        XCTAssertFalse(boundary.readsAdapterObject)
        XCTAssertFalse(boundary.usesSignedEndpoint)
        XCTAssertFalse(boundary.callsAccountEndpoint)
        XCTAssertFalse(boundary.createsListenKey)
        XCTAssertFalse(boundary.connectsBroker)
        XCTAssertFalse(boundary.implementsLiveExecutionAdapter)
        XCTAssertFalse(boundary.implementsOMS)
        XCTAssertFalse(boundary.implementsRealOrderLifecycle)
        XCTAssertFalse(boundary.submitsRealOrder)
        XCTAssertFalse(boundary.cancelsRealOrder)
        XCTAssertFalse(boundary.replacesRealOrder)
        XCTAssertFalse(boundary.providesLiveCommand)
        XCTAssertFalse(boundary.providesTradingButton)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(PaperRuntimeKernelBoundary.self, from: encoded)
        XCTAssertEqual(decoded, boundary)
    }

    func testMTP96PaperRuntimeKernelBoundaryRejectsLiveSignedBrokerSchemaAndClockBypass() throws {
        // 测试场景：MTP-96 kernel boundary 的 Codable 和 initializer 都必须拒绝 wall-clock、
        // signed/account/listenKey、broker、LiveExecutionAdapter、OMS、真实订单、UI state 和 schema 暴露。
        XCTAssertThrowsError(
            try TradingClockTick(
                sequence: 1,
                instant: Date(timeIntervalSince1970: 1),
                source: .wallClock
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .tradingClockContractMismatch(
                    field: "source",
                    expected: "deterministicFixture or replay",
                    actual: "wallClock"
                )
            )
        }
        XCTAssertThrowsError(
            try TradingClock(
                clockID: try Identifier("invalid-clock"),
                issueID: try Identifier("MTP-96"),
                ticks: [
                    TradingClockTick(
                        sequence: 2,
                        instant: Date(timeIntervalSince1970: 1),
                        source: .deterministicFixture
                    )
                ]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .tradingClockContractMismatch(field: "tick.sequence", expected: "1", actual: "2")
            )
        }

        XCTAssertThrowsError(
            try PaperRuntimeKernelBoundary(
                contractID: try Identifier("invalid-kernel"),
                issueID: try Identifier("MTP-96"),
                clock: .deterministicFixture,
                usesSignedEndpoint: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperRuntimeKernelForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try PaperRuntimeKernelBoundary(
                contractID: try Identifier("invalid-kernel"),
                issueID: try Identifier("MTP-96"),
                clock: .deterministicFixture,
                exposesPersistenceSchema: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperRuntimeKernelForbiddenCapability("exposesPersistenceSchema"))
        }
        XCTAssertThrowsError(
            try PaperRuntimeKernelBoundary(
                contractID: try Identifier("invalid-kernel"),
                issueID: try Identifier("MTP-96"),
                clock: .deterministicFixture,
                eventStreams: [.paper, .market]
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperRuntimeKernelContractMismatch(
                    field: "eventStreams",
                    expected: "paper,replay",
                    actual: "paper,market"
                )
            )
        }

        let encoded = try JSONEncoder().encode(PaperRuntimeKernelBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["providesLiveCommand"] = true
        let data = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(
            try JSONDecoder().decode(PaperRuntimeKernelBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperRuntimeKernelForbiddenCapability("providesLiveCommand"))
        }
    }

    func testMTP97PaperRuntimeBusRoutingContractDefinesPaperOnlyDeterministicBoundary() throws {
        // 测试场景：MTP-97 bus routing 合同必须显式列出 CommandBus / EventBus / MessageBus、
        // 允许的 paper-only route source 和 validation anchors，且所有 live/signed/broker 能力保持关闭。
        let contract = PaperRuntimeBusRoutingContract.deterministicFixture

        XCTAssertEqual(contract.contractID, try Identifier("mtp-97-paper-runtime-bus-routing-contract"))
        XCTAssertEqual(contract.issueID, try Identifier("MTP-97"))
        XCTAssertEqual(contract.buses, [.commandBus, .eventBus, .messageBus])
        XCTAssertEqual(contract.routeSources, [.paperSessionCommand, .paperRiskDecision, .paperLifecycleEvent, .simulatedFillEvent])
        XCTAssertEqual(contract.payloadKinds, [
            .paperSessionCommand,
            .paperRiskEvaluationRequested,
            .paperRiskBlocked,
            .paperLifecycleStarted,
            .paperLifecycleUpdated,
            .paperLifecycleClosed,
            .paperOrderLocalLifecycleTransition,
            .simulatedFillRecorded
        ])
        XCTAssertEqual(contract.eventStreams, [.paper, .risk])
        XCTAssertEqual(contract.validationAnchors, [
            "TVM-PAPER-RUNTIME-KERNEL",
            "MTP-97-COMMANDBUS-EVENTBUS-MESSAGEBUS-ROUTING",
            "MTP-97-DETERMINISTIC-PAPER-ROUTE-ORDER",
            "MTP-97-REPLAYABLE-ROUTE-EVIDENCE",
            "MTP-97-NO-LIVE-SIGNED-BROKER-ROUTING",
            "MTP-97-PAPER-RUNTIME-BUS-VALIDATION"
        ])
        XCTAssertTrue(contract.paperOnlyBoundaryHeld)
        XCTAssertTrue(contract.deterministicRoutingBoundaryHeld)
        XCTAssertFalse(contract.usesLiveCommandBus)
        XCTAssertFalse(contract.routesRealOrderCommand)
        XCTAssertFalse(contract.connectsBroker)
        XCTAssertFalse(contract.routesSignedRequest)
        XCTAssertFalse(contract.callsAccountEndpoint)
        XCTAssertFalse(contract.createsListenKey)
        XCTAssertFalse(contract.routesExecutionReport)
        XCTAssertFalse(contract.routesBrokerFill)
        XCTAssertFalse(contract.routesReconciliation)

        let encoded = try JSONEncoder().encode(contract)
        let decoded = try JSONDecoder().decode(PaperRuntimeBusRoutingContract.self, from: encoded)
        XCTAssertEqual(decoded, contract)
    }

    func testMTP97CommandEventMessageBusRoutesDeterministicallyAndReplaysEvidence() throws {
        // 测试场景：CommandBus 必须按输入顺序确定性展开 paper session command、paper risk decision、
        // lifecycle event 和 simulated fill event；EventBus 发布后，MessageBus replay 能重建同一批 route evidence。
        let inputs = try PaperRuntimeBusRoutingFixture.routeInputs()
        let commandBus = PaperRuntimeCommandBus()
        let eventBus = PaperRuntimeEventBus()
        let messages = try commandBus.route(
            inputs,
            clock: PaperRuntimeBusRoutingFixture.deterministicClock,
            envelopeIDs: PaperRuntimeBusRoutingFixture.envelopeIDs,
            correlationID: PaperRuntimeBusRoutingFixture.correlationID,
            rootCausationID: PaperRuntimeBusRoutingFixture.rootCausationID
        )

        XCTAssertEqual(messages.map(\.routeSequence), [1, 2, 3, 4, 5])
        XCTAssertEqual(messages.map(\.payloadKind), [
            .paperSessionCommand,
            .paperRiskEvaluationRequested,
            .paperRiskBlocked,
            .paperLifecycleStarted,
            .simulatedFillRecorded
        ])
        XCTAssertEqual(messages.map(\.source), [
            .paperSessionCommand,
            .paperRiskDecision,
            .paperRiskDecision,
            .paperLifecycleEvent,
            .simulatedFillEvent
        ])
        XCTAssertEqual(messages.map(\.stream), [.paper, .risk, .risk, .paper, .paper])
        XCTAssertEqual(messages.map(\.recordedAt.timeIntervalSince1970), [3_000, 3_001, 3_002, 3_003, 3_004])
        XCTAssertEqual(messages.map(\.envelopeID), PaperRuntimeBusRoutingFixture.envelopeIDs)
        XCTAssertEqual(
            messages.map(\.correlationID),
            Array(repeating: PaperRuntimeBusRoutingFixture.correlationID, count: 5)
        )
        XCTAssertEqual(messages.map(\.causationID), [
            PaperRuntimeBusRoutingFixture.rootCausationID,
            PaperRuntimeBusRoutingFixture.envelopeIDs[0],
            PaperRuntimeBusRoutingFixture.envelopeIDs[1],
            PaperRuntimeBusRoutingFixture.envelopeIDs[2],
            PaperRuntimeBusRoutingFixture.envelopeIDs[3]
        ])

        var messageBus = try MessageBus()
        let evidence = try eventBus.publish(messages, to: &messageBus)

        XCTAssertEqual(messageBus.envelopes.map(\.sequence), [1, 2, 3, 4, 5])
        XCTAssertEqual(messageBus.envelopes.map(\.id), PaperRuntimeBusRoutingFixture.envelopeIDs)
        XCTAssertEqual(messageBus.envelopes.map(\.stream), [.paper, .risk, .risk, .paper, .paper])
        XCTAssertEqual(evidence.map(\.eventSequence), [1, 2, 3, 4, 5])
        XCTAssertEqual(evidence.map(\.payloadKind), messages.map(\.payloadKind))
        XCTAssertEqual(evidence.map(\.source), messages.map(\.source))
        XCTAssertEqual(evidence.map(\.correlationID), Array(repeating: PaperRuntimeBusRoutingFixture.correlationID, count: 5))

        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: 5),
                streams: [.paper, .risk]
            )
        )
        let replayEvidence = try PaperRuntimeMessageBusRouting.replayEvidence(from: replay)
        XCTAssertEqual(replay.envelopes, messageBus.envelopes)
        XCTAssertEqual(replayEvidence, evidence)

        var oneShotBus = try MessageBus()
        let oneShotEvidence = try PaperRuntimeMessageBusRouting().publish(
            inputs,
            to: &oneShotBus,
            clock: PaperRuntimeBusRoutingFixture.deterministicClock,
            envelopeIDs: PaperRuntimeBusRoutingFixture.envelopeIDs,
            correlationID: PaperRuntimeBusRoutingFixture.correlationID,
            rootCausationID: PaperRuntimeBusRoutingFixture.rootCausationID
        )
        XCTAssertEqual(oneShotEvidence, evidence)
        XCTAssertEqual(oneShotBus.envelopes, messageBus.envelopes)
    }

    func testMTP97PaperRuntimeBusRoutingRejectsLiveSignedBrokerAndInvalidRouteBypass() throws {
        // 测试场景：MTP-97 routing 不能被配置成 live command bus、signed request routing、broker
        // action 或错误 stream；非 lifecycle 的 PaperEvent 也不能伪装成 lifecycle route。
        XCTAssertThrowsError(
            try PaperRuntimeBusRoutingContract(
                contractID: try Identifier("invalid-mtp-97-bus-routing"),
                issueID: try Identifier("MTP-97"),
                routesSignedRequest: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperRuntimeBusRoutingForbiddenCapability("routesSignedRequest"))
        }
        XCTAssertThrowsError(
            try PaperRuntimeBusRoutingContract(
                contractID: try Identifier("invalid-mtp-97-bus-routing"),
                issueID: try Identifier("MTP-97"),
                connectsBroker: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperRuntimeBusRoutingForbiddenCapability("connectsBroker"))
        }

        let inputs = try PaperRuntimeBusRoutingFixture.routeInputs()
        guard case let .paperSessionCommand(command) = inputs[0] else {
            return XCTFail("fixture first input must be paper session command")
        }
        let invalidLifecycleInput = PaperRuntimeRouteInput.paperLifecycleEvent(.sessionRequested(command))
        XCTAssertThrowsError(
            try PaperRuntimeCommandBus().route(
                [invalidLifecycleInput],
                clock: PaperRuntimeBusRoutingFixture.deterministicClock,
                envelopeIDs: [PaperRuntimeBusRoutingFixture.envelopeIDs[0]],
                correlationID: PaperRuntimeBusRoutingFixture.correlationID,
                rootCausationID: PaperRuntimeBusRoutingFixture.rootCausationID
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperRuntimeBusRoutingMismatch(
                    field: "paperLifecycleEvent",
                    expected: "sessionStarted/sessionUpdated/sessionClosed/orderLocalLifecycleTransitionRecorded",
                    actual: "sessionRequested"
                )
            )
        }

        XCTAssertThrowsError(
            try PaperRuntimeRoutedMessage(
                routeSequence: 1,
                envelopeID: PaperRuntimeBusRoutingFixture.envelopeIDs[0],
                source: .paperSessionCommand,
                payloadKind: .paperSessionCommand,
                stream: .risk,
                event: .paper(.sessionRequested(command)),
                recordedAt: Date(timeIntervalSince1970: 3_000),
                correlationID: PaperRuntimeBusRoutingFixture.correlationID,
                causationID: PaperRuntimeBusRoutingFixture.rootCausationID
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperRuntimeBusRoutingMismatch(
                    field: "stream",
                    expected: EventStreamID.paper.rawValue,
                    actual: EventStreamID.risk.rawValue
                )
            )
        }
    }

    func testMTP98PaperPreTradeRiskEngineProducesDeterministicAcceptedRejectedDecisions() throws {
        // 测试场景：MTP-98 Paper Pre-trade RiskEngine 只处理本地 paper proposal，并在同一组
        // deterministic inputs 下稳定输出 accepted / rejected paper risk decision。
        let accepted = try PaperPreTradeRiskEngineFixture.acceptedDecision()
        let rejected = try PaperPreTradeRiskEngineFixture.rejectedDecision()

        XCTAssertEqual(accepted.issueID, try Identifier("MTP-98"))
        XCTAssertEqual(accepted.outcome, .accepted)
        XCTAssertEqual(accepted.riskDecision.status, .allowed)
        XCTAssertTrue(accepted.isAccepted)
        XCTAssertFalse(accepted.isRejected)
        XCTAssertNil(accepted.rejectedRule)
        XCTAssertNil(accepted.riskDecision.blockerEvidence)
        XCTAssertEqual(accepted.ruleEvaluations.count, 4)
        XCTAssertTrue(accepted.ruleEvaluations.allSatisfy(\.passed))
        XCTAssertEqual(accepted.riskDecision.riskEvents.count, 1)
        XCTAssertTrue(accepted.paperOnlyBoundaryHeld)
        XCTAssertFalse(accepted.providesLiveRiskEngine)
        XCTAssertFalse(accepted.readsRealAccountBalance)
        XCTAssertFalse(accepted.syncsBrokerPosition)
        XCTAssertFalse(accepted.usesMargin)
        XCTAssertFalse(accepted.usesLeverage)
        XCTAssertFalse(accepted.runsRealPreTradeAllowReject)
        XCTAssertFalse(accepted.mapsPaperRiskToFutureLiveRiskDecision)
        XCTAssertEqual(accepted.validationAnchors, PaperPreTradeRiskEngineDecision.requiredValidationAnchors)

        XCTAssertEqual(rejected.issueID, try Identifier("MTP-98"))
        XCTAssertEqual(rejected.outcome, .rejected)
        XCTAssertEqual(rejected.riskDecision.status, .blocked)
        XCTAssertFalse(rejected.isAccepted)
        XCTAssertTrue(rejected.isRejected)
        XCTAssertEqual(rejected.rejectedRule?.kind, .maxPaperQuantity)
        XCTAssertEqual(rejected.rejectedRule?.blockerReason, .maxPaperQuantityExceeded)
        XCTAssertEqual(rejected.riskDecision.blockerEvidence?.reason, .maxPaperQuantityExceeded)
        XCTAssertEqual(rejected.ruleEvaluations.count, 4)
        XCTAssertEqual(rejected.ruleEvaluations.filter(\.rejected).count, 1)
        XCTAssertEqual(rejected.riskDecision.riskEvents.count, 2)
        XCTAssertTrue(rejected.paperOnlyBoundaryHeld)
        XCTAssertTrue(rejected.input.sourceAnchors.contains("MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH"))

        let encoded = try JSONEncoder().encode(rejected)
        let decoded = try JSONDecoder().decode(PaperPreTradeRiskEngineDecision.self, from: encoded)
        XCTAssertEqual(decoded, rejected)
    }

    func testMTP98RejectedDecisionPublishesToEventLogAndReplaysRiskEvidence() throws {
        // 测试场景：MTP-98 rejected decision 必须复用 MTP-97 routing 写入 append-only MessageBus，
        // replay 后仍能重建 evaluation requested + blocked evidence。
        let (messageBus, publication) = try PaperPreTradeRiskEngineFixture.publishedRejectedDecision()

        XCTAssertTrue(publication.decision.isRejected)
        XCTAssertTrue(publication.replayMatchesRouteEvidence)
        XCTAssertTrue(publication.rejectedDecisionEnteredReplay)
        XCTAssertEqual(messageBus.envelopes.map(\.sequence), [1, 2])
        XCTAssertEqual(messageBus.envelopes.map(\.stream), [.risk, .risk])
        XCTAssertEqual(publication.routeEvidence.map(\.payloadKind), [
            .paperRiskEvaluationRequested,
            .paperRiskBlocked
        ])
        XCTAssertEqual(publication.routeEvidence.map(\.source), [
            .paperRiskDecision,
            .paperRiskDecision
        ])
        XCTAssertEqual(publication.routeEvidence.map(\.envelopeID), PaperPreTradeRiskEngineFixture.rejectedEnvelopeIDs)
        XCTAssertEqual(
            publication.routeEvidence.map(\.correlationID),
            [PaperPreTradeRiskEngineFixture.correlationID, PaperPreTradeRiskEngineFixture.correlationID]
        )
        XCTAssertEqual(publication.routeEvidence.map(\.causationID), [
            PaperPreTradeRiskEngineFixture.rootCausationID,
            PaperPreTradeRiskEngineFixture.rejectedEnvelopeIDs[0]
        ])

        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: 2),
                streams: [.risk]
            )
        )
        let replayEvidence = try PaperRuntimeMessageBusRouting.replayEvidence(from: replay)
        XCTAssertEqual(replayEvidence, publication.routeEvidence)

        var seededBus = try MessageBus()
        let seededDecision = try PaperActionProposalRiskFixture.deterministicAllowed()
        try seededBus.publish(
            .risk(seededDecision.riskEvents[0]),
            stream: .risk,
            id: try XCTUnwrap(UUID(uuidString: "98000000-0000-4000-8000-000000000999")),
            recordedAt: Date(timeIntervalSince1970: 3_999),
            correlationID: PaperPreTradeRiskEngineFixture.correlationID,
            causationID: nil
        )
        let seededPublication = try PaperPreTradeRiskEngineRuntimePath().evaluateAndPublish(
            decisionID: try Identifier("mtp-98-paper-risk-rejected"),
            input: PaperPreTradeRiskEngineFixture.rejectedInput(),
            to: &seededBus,
            clock: PaperPreTradeRiskEngineFixture.deterministicClock,
            envelopeIDs: PaperPreTradeRiskEngineFixture.rejectedEnvelopeIDs,
            correlationID: PaperPreTradeRiskEngineFixture.correlationID,
            rootCausationID: PaperPreTradeRiskEngineFixture.rootCausationID
        )
        XCTAssertEqual(seededBus.envelopes.count, 3)
        XCTAssertEqual(seededPublication.routeEvidence.map(\.eventSequence), [2, 3])
        XCTAssertEqual(seededPublication.replayEvidence, seededPublication.routeEvidence)

        let encoded = try JSONEncoder().encode(publication)
        let decoded = try JSONDecoder().decode(PaperPreTradeRiskEnginePublication.self, from: encoded)
        XCTAssertEqual(decoded, publication)
    }

    func testMTP98PaperPreTradeRiskEngineRejectsLiveAccountBrokerAndDecodeBypass() throws {
        // 测试场景：MTP-98 的初始化和 Codable 解码都必须拒绝真实账户、broker position、margin、
        // leverage、live risk engine、real pre-trade allow/reject 或 paper -> future live risk decision 升级。
        let input = try PaperPreTradeRiskEngineFixture.acceptedInput()

        XCTAssertThrowsError(
            try PaperPreTradeRiskAccountSnapshot(
                snapshotID: try Identifier("invalid-mtp-98-account-snapshot"),
                sessionID: input.proposal.sessionID,
                availablePaperBalance: 10_000,
                sourceAnchor: "MTP-98-PAPER-ACCOUNT-SNAPSHOT-PAPER-ONLY",
                observedAt: Date(timeIntervalSince1970: 4_000),
                readsRealAccountBalance: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperPreTradeRiskEngineForbiddenCapability("readsRealAccountBalance"))
        }

        XCTAssertThrowsError(
            try PaperPreTradeRiskEngineDecision(
                decisionID: try Identifier("invalid-mtp-98-paper-risk"),
                issueID: try Identifier("MTP-98"),
                input: input,
                outcome: .accepted,
                riskDecision: PaperPreTradeRiskEngineFixture.acceptedDecision().riskDecision,
                ruleEvaluations: PaperPreTradeRiskEngineFixture.acceptedDecision().ruleEvaluations,
                rejectedRule: nil,
                providesLiveRiskEngine: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperPreTradeRiskEngineForbiddenCapability("providesLiveRiskEngine"))
        }

        let encodedInput = try JSONEncoder().encode(input)
        var inputObject = try XCTUnwrap(JSONSerialization.jsonObject(with: encodedInput) as? [String: Any])
        inputObject["sourceAnchors"] = ["TVM-PAPER-RUNTIME-KERNEL"]
        let missingAnchorData = try JSONSerialization.data(withJSONObject: inputObject)
        XCTAssertThrowsError(
            try JSONDecoder().decode(PaperPreTradeRiskEngineInput.self, from: missingAnchorData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineMismatch(
                    field: "sourceAnchors",
                    expected: "MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH",
                    actual: "TVM-PAPER-RUNTIME-KERNEL"
                )
            )
        }

        var invalidRuleObject = try XCTUnwrap(JSONSerialization.jsonObject(with: encodedInput) as? [String: Any])
        var rules = try XCTUnwrap(invalidRuleObject["riskRules"] as? [[String: Any]])
        rules[0]["limit"] = -1
        invalidRuleObject["riskRules"] = rules
        let invalidRuleData = try JSONSerialization.data(withJSONObject: invalidRuleObject)
        XCTAssertThrowsError(
            try JSONDecoder().decode(PaperPreTradeRiskEngineInput.self, from: invalidRuleData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineMismatch(
                    field: "rule.limit",
                    expected: "finite non-negative limit",
                    actual: "-1.0"
                )
            )
        }

        let encodedDecision = try JSONEncoder().encode(PaperPreTradeRiskEngineFixture.acceptedDecision())
        var decisionObject = try XCTUnwrap(JSONSerialization.jsonObject(with: encodedDecision) as? [String: Any])
        decisionObject["mapsPaperRiskToFutureLiveRiskDecision"] = true
        let liveUpgradeData = try JSONSerialization.data(withJSONObject: decisionObject)
        XCTAssertThrowsError(
            try JSONDecoder().decode(PaperPreTradeRiskEngineDecision.self, from: liveUpgradeData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperPreTradeRiskEngineForbiddenCapability("mapsPaperRiskToFutureLiveRiskDecision")
            )
        }
    }

    func testMTP99PaperOrderLocalLifecycleCoordinatorProducesDeterministicAcceptedRejectedTransitions() throws {
        // 测试场景：MTP-99 coordinator 必须把 MTP-98 accepted / rejected paper risk decision
        // 映射成本地 paper order lifecycle，不产生 OMS、broker router 或真实订单状态。
        let acceptedTrace = try PaperOrderLocalLifecycleCoordinatorFixture.acceptedTrace()
        let rejectedTrace = try PaperOrderLocalLifecycleCoordinatorFixture.rejectedTrace()

        XCTAssertEqual(acceptedTrace.orderID, PaperOrderLocalLifecycleCoordinatorFixture.orderID)
        XCTAssertEqual(acceptedTrace.states, [.proposed, .submittedLocal, .acceptedLocal])
        XCTAssertEqual(acceptedTrace.currentState, .acceptedLocal)
        XCTAssertTrue(acceptedTrace.everyTransitionHasEventFact)
        XCTAssertEqual(acceptedTrace.transitions.map(\.trigger), [
            .paperProposalRecorded,
            .submittedLocal,
            .acceptedLocal
        ])
        XCTAssertEqual(acceptedTrace.transitions.map(\.sourceLifecycleSequence), [nil, 1, 2])
        XCTAssertTrue(acceptedTrace.transitions[2].isSimulatedFillPrecondition)
        XCTAssertEqual(
            acceptedTrace.transitions[0].validationAnchors,
            PaperOrderLocalLifecycleTransition.requiredValidationAnchors
        )
        XCTAssertTrue(acceptedTrace.transitions.allSatisfy(\.paperOnlyBoundaryHeld))
        XCTAssertTrue(acceptedTrace.transitions.allSatisfy { $0.implementsOMS == false })
        XCTAssertTrue(acceptedTrace.transitions.allSatisfy { $0.connectsBroker == false })
        XCTAssertTrue(acceptedTrace.transitions.allSatisfy { $0.implementsRealOrderStateMachine == false })
        XCTAssertTrue(acceptedTrace.transitions.allSatisfy { $0.providesRealCancelCommand == false })
        XCTAssertTrue(acceptedTrace.transitions.allSatisfy { $0.providesOrderLevelCommandUI == false })

        let precondition = try PaperOrderLocalLifecycleCoordinator().simulatedFillPrecondition(
            from: acceptedTrace,
            sourceLifecycleSequence: 3
        )
        XCTAssertEqual(precondition.orderID, acceptedTrace.orderID)
        XCTAssertEqual(precondition.localState, .acceptedLocal)
        XCTAssertEqual(precondition.readiness, .readyForSimulatedFill)
        XCTAssertTrue(precondition.ready)
        XCTAssertFalse(precondition.recordsBrokerFill)
        XCTAssertFalse(precondition.consumesExecutionReport)
        XCTAssertFalse(precondition.performsReconciliation)

        XCTAssertEqual(rejectedTrace.orderID, PaperOrderLocalLifecycleCoordinatorFixture.rejectedOrderID)
        XCTAssertEqual(rejectedTrace.states, [.proposed, .rejectedByPaperRisk])
        XCTAssertEqual(rejectedTrace.currentState, .rejectedByPaperRisk)
        XCTAssertTrue(rejectedTrace.transitions[1].toState.isTerminal)
        XCTAssertEqual(rejectedTrace.transitions[1].riskDecisionStatus, .blocked)
        XCTAssertNotNil(rejectedTrace.transitions[1].blockerEvidenceID)
        XCTAssertFalse(rejectedTrace.transitions[1].isSimulatedFillPrecondition)

        let encoded = try JSONEncoder().encode(acceptedTrace.transitions[2])
        let decoded = try JSONDecoder().decode(PaperOrderLocalLifecycleTransition.self, from: encoded)
        XCTAssertEqual(decoded, acceptedTrace.transitions[2])
    }

    func testMTP99LifecycleTransitionsPublishEventFactsAndReplayEvidence() throws {
        // 测试场景：每个 local lifecycle transition 都必须通过 MTP-97 routing 写入 `.paper`
        // append-only facts，并能从 MessageBus replay 重建同一批 route evidence。
        let (messageBus, publication) = try PaperOrderLocalLifecycleCoordinatorFixture.publishedAcceptedTrace()

        XCTAssertTrue(publication.replayMatchesRouteEvidence)
        XCTAssertTrue(publication.everyTransitionHasEventFact)
        XCTAssertEqual(messageBus.envelopes.map(\.sequence), [1, 2, 3])
        XCTAssertEqual(messageBus.envelopes.map(\.id), PaperOrderLocalLifecycleCoordinatorFixture.acceptedEnvelopeIDs)
        XCTAssertEqual(messageBus.envelopes.map(\.stream), [.paper, .paper, .paper])
        XCTAssertEqual(publication.routeEvidence.map(\.eventSequence), [1, 2, 3])
        XCTAssertEqual(publication.routeEvidence.map(\.source), [
            .paperLifecycleEvent,
            .paperLifecycleEvent,
            .paperLifecycleEvent
        ])
        XCTAssertEqual(publication.routeEvidence.map(\.payloadKind), [
            .paperOrderLocalLifecycleTransition,
            .paperOrderLocalLifecycleTransition,
            .paperOrderLocalLifecycleTransition
        ])
        XCTAssertEqual(
            publication.routeEvidence.map(\.correlationID),
            Array(repeating: PaperOrderLocalLifecycleCoordinatorFixture.correlationID, count: 3)
        )
        XCTAssertEqual(publication.routeEvidence.map(\.causationID), [
            PaperOrderLocalLifecycleCoordinatorFixture.rootCausationID,
            PaperOrderLocalLifecycleCoordinatorFixture.acceptedEnvelopeIDs[0],
            PaperOrderLocalLifecycleCoordinatorFixture.acceptedEnvelopeIDs[1]
        ])

        let transitionStates = try messageBus.envelopes.map { envelope -> PaperOrderLocalLifecycleState in
            guard case let .paper(.orderLocalLifecycleTransitionRecorded(transition)) = envelope.event else {
                throw CoreError.paperOrderLocalLifecycleMismatch(
                    field: "event",
                    expected: "paper.orderLocalLifecycleTransitionRecorded",
                    actual: "\(envelope.event)"
                )
            }
            return transition.toState
        }
        XCTAssertEqual(transitionStates, [.proposed, .submittedLocal, .acceptedLocal])

        var seededBus = try MessageBus()
        let routeInputs = try PaperRuntimeBusRoutingFixture.routeInputs()
        guard case let .paperSessionCommand(sessionCommand) = routeInputs[0] else {
            return XCTFail("fixture first input must be paper session command")
        }
        try seededBus.publish(
            .paper(.sessionRequested(sessionCommand)),
            stream: .paper,
            id: try XCTUnwrap(UUID(uuidString: "99000000-0000-4000-8000-000000000999")),
            recordedAt: Date(timeIntervalSince1970: 4_999),
            correlationID: PaperOrderLocalLifecycleCoordinatorFixture.correlationID,
            causationID: nil
        )
        let seededPublication = try PaperOrderLocalLifecycleCoordinator().publish(
            PaperOrderLocalLifecycleCoordinatorFixture.acceptedTrace(),
            to: &seededBus,
            clock: PaperOrderLocalLifecycleCoordinatorFixture.deterministicClock,
            envelopeIDs: PaperOrderLocalLifecycleCoordinatorFixture.acceptedEnvelopeIDs,
            correlationID: PaperOrderLocalLifecycleCoordinatorFixture.correlationID,
            rootCausationID: PaperOrderLocalLifecycleCoordinatorFixture.rootCausationID
        )
        XCTAssertEqual(seededBus.envelopes.count, 4)
        XCTAssertEqual(seededPublication.routeEvidence.map(\.eventSequence), [2, 3, 4])
        XCTAssertEqual(seededPublication.replayEvidence, seededPublication.routeEvidence)

        let encoded = try JSONEncoder().encode(publication)
        let decoded = try JSONDecoder().decode(PaperOrderLocalLifecyclePublication.self, from: encoded)
        XCTAssertEqual(decoded, publication)
    }

    func testMTP99LifecycleCoordinatorRejectsOMSBrokerRealOrderCancelAndInvalidTransitions() throws {
        // 测试场景：MTP-99 lifecycle coordinator 必须拒绝 OMS、broker、真实订单状态机、
        // real cancel command、order-level command UI，以及不合法的 local lifecycle transition。
        let acceptedDecision = try PaperPreTradeRiskEngineFixture.acceptedDecision()
        let rejectedDecision = try PaperPreTradeRiskEngineFixture.rejectedDecision()
        let coordinator = PaperOrderLocalLifecycleCoordinator()

        XCTAssertThrowsError(
            try coordinator.acceptedLocalTrace(
                orderID: PaperOrderLocalLifecycleCoordinatorFixture.orderID,
                decision: rejectedDecision,
                startedAt: Date(timeIntervalSince1970: 5_000)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperOrderLocalLifecycleMismatch(
                    field: "decision.outcome",
                    expected: PaperPreTradeRiskDecisionOutcome.accepted.rawValue,
                    actual: PaperPreTradeRiskDecisionOutcome.rejected.rawValue
                )
            )
        }

        XCTAssertThrowsError(
            try coordinator.cancelLocally(
                orderID: PaperOrderLocalLifecycleCoordinatorFixture.orderID,
                decision: acceptedDecision,
                fromState: .submittedLocal,
                trigger: .submittedLocal,
                sourceLifecycleSequence: 2,
                occurredAt: Date(timeIntervalSince1970: 5_030)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperOrderLocalLifecycleMismatch(
                    field: "cancelledLocal.trigger",
                    expected: "sessionClose/sessionReset/localExpiry/deterministicLocalRule",
                    actual: PaperOrderLocalLifecycleTrigger.submittedLocal.rawValue
                )
            )
        }

        XCTAssertNoThrow(
            try coordinator.cancelLocally(
                orderID: PaperOrderLocalLifecycleCoordinatorFixture.orderID,
                decision: acceptedDecision,
                fromState: .acceptedLocal,
                trigger: .sessionClose,
                sourceLifecycleSequence: 3,
                occurredAt: Date(timeIntervalSince1970: 5_031)
            )
        )
        XCTAssertNoThrow(
            try coordinator.expireLocally(
                orderID: PaperOrderLocalLifecycleCoordinatorFixture.orderID,
                decision: acceptedDecision,
                fromState: .submittedLocal,
                sourceLifecycleSequence: 2,
                occurredAt: Date(timeIntervalSince1970: 5_032)
            )
        )
        XCTAssertNoThrow(
            try coordinator.failLocally(
                orderID: PaperOrderLocalLifecycleCoordinatorFixture.orderID,
                decision: acceptedDecision,
                fromState: .acceptedLocal,
                sourceLifecycleSequence: 3,
                occurredAt: Date(timeIntervalSince1970: 5_033)
            )
        )

        XCTAssertThrowsError(
            try PaperOrderLocalLifecycleTransition(
                transitionID: try Identifier("invalid-mtp-99-real-cancel"),
                orderID: PaperOrderLocalLifecycleCoordinatorFixture.orderID,
                riskDecision: acceptedDecision.riskDecision,
                fromState: .acceptedLocal,
                toState: .cancelledLocal,
                trigger: .sessionClose,
                sourceLifecycleSequence: 3,
                occurredAt: Date(timeIntervalSince1970: 5_040),
                providesRealCancelCommand: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperOrderLocalLifecycleForbiddenCapability("providesRealCancelCommand")
            )
        }

        let encodedTransition = try JSONEncoder().encode(
            PaperOrderLocalLifecycleCoordinatorFixture.acceptedTrace().transitions[2]
        )
        var transitionObject = try XCTUnwrap(JSONSerialization.jsonObject(with: encodedTransition) as? [String: Any])
        transitionObject["implementsOMS"] = true
        let omsData = try JSONSerialization.data(withJSONObject: transitionObject)
        XCTAssertThrowsError(
            try JSONDecoder().decode(PaperOrderLocalLifecycleTransition.self, from: omsData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperOrderLocalLifecycleForbiddenCapability("implementsOMS"))
        }

        XCTAssertThrowsError(
            try PaperOrderSimulatedFillPrecondition(
                orderID: PaperOrderLocalLifecycleCoordinatorFixture.orderID,
                sourceLifecycleSequence: 2,
                localState: .submittedLocal,
                readiness: .waitingForAcceptedLocal,
                acceptedAt: Date(timeIntervalSince1970: 5_050)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperOrderLocalLifecycleMismatch(
                    field: "simulatedFillPrecondition",
                    expected: "acceptedLocal readyForSimulatedFill",
                    actual: "submittedLocal waitingForAcceptedLocal"
                )
            )
        }
    }

    func testMTP100SimulatedFillModelCreatesDeterministicFullAndPartialCostEvidence() throws {
        // 测试场景：MTP-100 simulated fill model 必须消费 MTP-99 accepted-local 前置条件、
        // deterministic market snapshot 和 fixed fee / slippage assumptions，稳定生成 full 与 partial evidence。
        let full = try PaperSimulatedFillFixture.deterministicFullFromLifecycle()
        let partial = try PaperSimulatedFillFixture.deterministicPartialFromLifecycle()
        let orderIntent = try PaperSimulatedFillFixture.lifecycleOrderIntent()
        let marketSnapshot = PaperSimulatedFillMarketSnapshot.deterministicFixture

        XCTAssertEqual(full.fillID, try Identifier("mtp-100-full-simulated-fill"))
        XCTAssertEqual(full.orderID, orderIntent.orderID)
        XCTAssertEqual(full.marketSnapshotID, marketSnapshot.snapshotID)
        XCTAssertEqual(full.localLifecycleState, .acceptedLocal)
        XCTAssertEqual(full.sourceLifecycleSequence, 3)
        XCTAssertEqual(full.fillCompletion, .full)
        XCTAssertEqual(full.fillPriceSource, .orderReference)
        XCTAssertEqual(full.filledQuantity.rawValue, orderIntent.quantity.rawValue, accuracy: 0.00000001)
        XCTAssertEqual(full.remainingQuantity.rawValue, 0, accuracy: 0.00000001)
        XCTAssertEqual(full.feeAssumptionID, try Identifier("mtp-27-fixed-cost-assumptions"))
        XCTAssertEqual(full.slippageAssumptionID, try Identifier("mtp-27-fixed-cost-assumptions"))
        XCTAssertEqual(full.fillPriceAssumptionID, try Identifier("mtp-40-simulated-fill-assumption"))
        XCTAssertEqual(full.costEstimate.feeAmount, 0.01, accuracy: 0.00000001)
        XCTAssertEqual(full.costEstimate.slippageAmount, 0.0075, accuracy: 0.00000001)
        XCTAssertEqual(full.costImpactAmount, full.costEstimate.totalCostAmount, accuracy: 0.00000001)
        XCTAssertTrue(full.paperOnlyBoundaryHeld)
        XCTAssertFalse(full.representsBrokerFill)
        XCTAssertFalse(full.consumesExecutionReport)
        XCTAssertFalse(full.performsReconciliation)
        XCTAssertFalse(full.updatesRealAccountBalance)

        let expectedPartialCost = ExecutionCostCalculator.estimate(
            ExecutionCostEstimateRequest(
                symbol: orderIntent.symbol,
                timeframe: orderIntent.timeframe,
                executionMode: .paper,
                referencePrice: marketSnapshot.askPrice,
                quantity: try Quantity(0.25, field: "test.mtp100.partialQuantity"),
                liquidityRole: .taker
            ),
            assumptions: .deterministicFixture
        )
        XCTAssertEqual(partial.fillID, try Identifier("mtp-100-partial-simulated-fill"))
        XCTAssertEqual(partial.orderID, orderIntent.orderID)
        XCTAssertEqual(partial.localLifecycleState, .acceptedLocal)
        XCTAssertEqual(partial.fillCompletion, .partial)
        XCTAssertEqual(partial.fillPriceSource, .bestAsk)
        XCTAssertEqual(partial.filledQuantity.rawValue, 0.25, accuracy: 0.00000001)
        XCTAssertEqual(partial.remainingQuantity.rawValue, 0.25, accuracy: 0.00000001)
        XCTAssertEqual(partial.fillPrice.rawValue, 100.25, accuracy: 0.00000001)
        XCTAssertEqual(partial.costEstimate, expectedPartialCost)
        XCTAssertEqual(partial.costEstimate.feeRateBps, 5, accuracy: 0.00000001)
        XCTAssertEqual(partial.costEstimate.slippageRateBps, 1.5, accuracy: 0.00000001)
        XCTAssertEqual(partial.costImpactAmount, expectedPartialCost.totalCostAmount, accuracy: 0.00000001)
        XCTAssertTrue(partial.paperOnlyBoundaryHeld)

        let encoded = try JSONEncoder().encode(partial)
        let decoded = try JSONDecoder().decode(PaperSimulatedFillEvidence.self, from: encoded)
        XCTAssertEqual(decoded, partial)
    }

    func testMTP100SimulatedFillEventLogPublishesPartialAndFullFillsAndReplaysEvidence() throws {
        // 测试场景：MTP-100 fill evidence 必须通过既有 paper runtime routing 写入 `.paper` stream，
        // replay 后能够重建同一组 partial / full fill facts 和 route evidence。
        let (messageBus, publication) = try PaperSimulatedFillFixture.publishedPartialAndFullFills()

        XCTAssertTrue(publication.replayMatchesRouteEvidence)
        XCTAssertTrue(publication.coversPartialAndFullFills)
        XCTAssertEqual(messageBus.envelopes.map(\.sequence), [1, 2])
        XCTAssertEqual(messageBus.envelopes.map(\.id), PaperSimulatedFillFixture.envelopeIDs)
        XCTAssertEqual(messageBus.envelopes.map(\.stream), [.paper, .paper])
        XCTAssertEqual(publication.routeEvidence.map(\.source), [.simulatedFillEvent, .simulatedFillEvent])
        XCTAssertEqual(publication.routeEvidence.map(\.payloadKind), [.simulatedFillRecorded, .simulatedFillRecorded])
        XCTAssertEqual(publication.routeEvidence.map(\.eventSequence), [1, 2])
        XCTAssertEqual(publication.routeEvidence.map(\.correlationID), [
            PaperSimulatedFillFixture.correlationID,
            PaperSimulatedFillFixture.correlationID
        ])
        XCTAssertEqual(publication.routeEvidence.map(\.causationID), [
            PaperSimulatedFillFixture.rootCausationID,
            PaperSimulatedFillFixture.envelopeIDs[0]
        ])
        XCTAssertEqual(publication.replayedFills.map(\.fillID), [
            try Identifier("mtp-100-full-simulated-fill"),
            try Identifier("mtp-100-partial-simulated-fill")
        ])

        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: 2),
                streams: [.paper]
            )
        )
        let replayedFills = try PaperSimulatedFillReplayPath.simulatedFills(from: replay)
        XCTAssertEqual(replayedFills, publication.fills)

        let encoded = try JSONEncoder().encode(publication)
        let decoded = try JSONDecoder().decode(PaperSimulatedFillPublication.self, from: encoded)
        XCTAssertEqual(decoded, publication)
    }

    func testMTP100SimulatedFillRejectsBrokerExecutionReportReconciliationAndInvalidPartialBypass() throws {
        // 测试场景：MTP-100 的 market snapshot、precondition、partial fill 和 Codable payload
        // 都不能被伪造成 broker fill、execution report、reconciliation 或真实账户更新。
        XCTAssertThrowsError(
            try PaperSimulatedFillMarketSnapshot(
                snapshotID: try Identifier("invalid-mtp-100-market-snapshot"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                bidPrice: try Price(99.75, field: "test.bid"),
                askPrice: try Price(100.25, field: "test.ask"),
                lastPrice: try Price(100, field: "test.last"),
                observedAt: Date(timeIntervalSince1970: 6_000),
                sourceAnchor: "MTP-100-SIMULATED-FILL-MARKET-SNAPSHOT",
                connectsBroker: true
            )
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperSimulatedFillForbiddenCapability("marketSnapshot.connectsBroker"))
        }

        XCTAssertThrowsError(
            try PaperSimulatedFillEvidence(
                fillID: try Identifier("invalid-mtp-100-partial-full-quantity"),
                orderIntent: PaperSimulatedFillFixture.lifecycleOrderIntent(),
                lifecyclePrecondition: PaperSimulatedFillFixture.lifecyclePrecondition(),
                marketSnapshot: .deterministicFixture,
                assumption: try PaperSimulatedFillAssumption(
                    assumptionID: try Identifier("invalid-mtp-100-partial-assumption"),
                    filledQuantity: try Quantity(0.5, field: "test.invalidPartialQuantity"),
                    fillPrice: try Price(100, field: "test.invalidPartialPrice"),
                    liquidityRole: .maker,
                    completion: .partial,
                    fillPriceSource: .orderReference
                ),
                sourceOrderIntentSequence: 4,
                filledAt: Date(timeIntervalSince1970: 6_030)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSimulatedFillMismatch(field: "partialFill.filledQuantity", expected: "< 0.5", actual: "0.5")
            )
        }

        let wrongOrderPrecondition = try PaperOrderSimulatedFillPrecondition(
            orderID: try Identifier("wrong-mtp-100-order"),
            sourceLifecycleSequence: 3,
            localState: .acceptedLocal,
            readiness: .readyForSimulatedFill,
            acceptedAt: Date(timeIntervalSince1970: 6_010)
        )
        XCTAssertThrowsError(
            try PaperSimulatedFillEvidence(
                fillID: try Identifier("invalid-mtp-100-precondition-order"),
                orderIntent: PaperSimulatedFillFixture.lifecycleOrderIntent(),
                lifecyclePrecondition: wrongOrderPrecondition,
                marketSnapshot: .deterministicFixture,
                assumption: .deterministicFixture,
                sourceOrderIntentSequence: 4,
                filledAt: Date(timeIntervalSince1970: 6_031)
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .paperSimulatedFillMismatch(
                    field: "lifecyclePrecondition.orderID",
                    expected: "mtp-99-paper-order-local",
                    actual: "wrong-mtp-100-order"
                )
            )
        }

        let encoded = try JSONEncoder().encode(PaperSimulatedFillFixture.deterministicPartialFromLifecycle())
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["consumesExecutionReport"] = true
        let executionReportData = try JSONSerialization.data(withJSONObject: object)
        XCTAssertThrowsError(
            try JSONDecoder().decode(PaperSimulatedFillEvidence.self, from: executionReportData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperSimulatedFillForbiddenCapability("consumesExecutionReport"))
        }
    }

    func testMTP101PaperAccountPortfolioPositionProjectionDerivesDeterministicSnapshotFromReplay() throws {
        // 测试场景：MTP-101 只能从 replayed simulated fill evidence 派生 paper account、
        // portfolio、position、exposure 和 PnL snapshot，不能直接读取 risk decision 或真实账户。
        let (messageBus, publication) = try PaperSimulatedFillFixture.publishedPartialAndFullFills()
        let replay = messageBus.replay(
            EventReplayCommand(
                range: try EventSequenceRange(lowerBound: 1, upperBound: messageBus.envelopes.count),
                streams: [.paper]
            )
        )
        let snapshot = try PaperAccountPortfolioProjectionV2Path.project(
            from: replay,
            snapshotID: try Identifier("mtp-101-paper-account-portfolio-snapshot"),
            accountID: try Identifier("mtp-101-paper-account"),
            portfolioID: try Identifier("mtp-101-paper-portfolio"),
            startingCashBalance: 10_000,
            projectedAt: Date(timeIntervalSince1970: 6_100)
        )
        let expectedGross = publication.fills.reduce(0) { $0 + $1.grossNotional }
        let expectedCost = publication.fills.reduce(0) { $0 + $1.costImpactAmount }
        let expectedQuantity = publication.fills.reduce(0) { $0 + $1.filledQuantity.rawValue }
        let lastFillPrice = try XCTUnwrap(publication.fills.last?.fillPrice.rawValue)
        let expectedMarketValue = expectedQuantity * lastFillPrice
        let expectedNetPnL = expectedMarketValue - expectedGross - expectedCost

        XCTAssertEqual(snapshot.snapshotID, try Identifier("mtp-101-paper-account-portfolio-snapshot"))
        XCTAssertEqual(snapshot.portfolioID, try Identifier("mtp-101-paper-portfolio"))
        XCTAssertEqual(snapshot.sourceFillIDs, publication.fills.map(\.fillID))
        XCTAssertEqual(snapshot.sourceSequences, [1, 2])
        XCTAssertEqual(snapshot.positions.count, 1)
        XCTAssertEqual(snapshot.exposures.count, 1)
        XCTAssertTrue(snapshot.usesReplayedSimulatedFillEvidence)
        XCTAssertTrue(snapshot.paperOnlyBoundaryHeld)
        XCTAssertFalse(snapshot.readsRealAccountBalance)
        XCTAssertFalse(snapshot.syncsBrokerPosition)
        XCTAssertFalse(snapshot.usesMargin)
        XCTAssertFalse(snapshot.usesLeverage)
        XCTAssertFalse(snapshot.representsRealAccountState)
        XCTAssertFalse(snapshot.updatesLiveRiskRuntime)

        let account = snapshot.account
        XCTAssertEqual(account.accountID, try Identifier("mtp-101-paper-account"))
        XCTAssertEqual(account.startingCashBalance, 10_000, accuracy: 0.00000001)
        XCTAssertEqual(account.cashBalance, 10_000 - expectedGross - expectedCost, accuracy: 0.00000001)
        XCTAssertEqual(account.availablePaperBalance, account.cashBalance, accuracy: 0.00000001)
        XCTAssertEqual(account.positionMarketValue, expectedMarketValue, accuracy: 0.00000001)
        XCTAssertEqual(account.equity, account.cashBalance + expectedMarketValue, accuracy: 0.00000001)
        XCTAssertEqual(account.pnlSummary.netPaperPnL, expectedNetPnL, accuracy: 0.00000001)

        let position = try XCTUnwrap(snapshot.positions.first)
        XCTAssertEqual(position.positionID, try Identifier("mtp-101-paper-portfolio-BTCUSDT-1m-paper-position"))
        XCTAssertEqual(position.netQuantity.rawValue, expectedQuantity, accuracy: 0.00000001)
        XCTAssertEqual(position.lastFillPrice.rawValue, lastFillPrice, accuracy: 0.00000001)
        XCTAssertEqual(position.marketValue, expectedMarketValue, accuracy: 0.00000001)
        XCTAssertEqual(position.costBasisNotional, expectedGross, accuracy: 0.00000001)
        XCTAssertEqual(position.totalCostImpactAmount, expectedCost, accuracy: 0.00000001)
        XCTAssertEqual(position.unrealizedPaperPnL, expectedNetPnL, accuracy: 0.00000001)
        XCTAssertTrue(position.paperOnlyBoundaryHeld)

        let encoded = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(PaperAccountPortfolioProjectionV2Snapshot.self, from: encoded)
        XCTAssertEqual(decoded, snapshot)
    }

    func testMTP101PaperAccountPortfolioProjectionRejectsRealAccountBrokerMarginLeverageBypass() throws {
        // 测试场景：MTP-101 Codable payload 不能恢复真实账户余额、broker position、margin /
        // leverage、real PnL 或 live risk runtime 语义。
        let snapshot = try PaperAccountPortfolioProjectionV2Fixture.deterministicSnapshot()
        let encoded = try JSONEncoder().encode(snapshot)
        let decoder = JSONDecoder()

        var accountBypassObject = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        var account = try XCTUnwrap(accountBypassObject["account"] as? [String: Any])
        account["readsRealAccountBalance"] = true
        accountBypassObject["account"] = account
        let accountBypassData = try JSONSerialization.data(withJSONObject: accountBypassObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperAccountPortfolioProjectionV2Snapshot.self, from: accountBypassData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperPortfolioProjectionForbiddenCapability("readsRealAccountBalance"))
        }

        var positionBypassObject = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        var positions = try XCTUnwrap(positionBypassObject["positions"] as? [[String: Any]])
        positions[0]["syncsBrokerPosition"] = true
        positionBypassObject["positions"] = positions
        let positionBypassData = try JSONSerialization.data(withJSONObject: positionBypassObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperAccountPortfolioProjectionV2Snapshot.self, from: positionBypassData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperPortfolioProjectionForbiddenCapability("syncsBrokerPosition"))
        }

        var pnlBypassObject = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        var pnlSummary = try XCTUnwrap(pnlBypassObject["pnlSummary"] as? [String: Any])
        pnlSummary["representsRealPnL"] = true
        pnlBypassObject["pnlSummary"] = pnlSummary
        let pnlBypassData = try JSONSerialization.data(withJSONObject: pnlBypassObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperAccountPortfolioProjectionV2Snapshot.self, from: pnlBypassData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperPortfolioProjectionForbiddenCapability("representsRealPnL"))
        }

        var liveRuntimeObject = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        liveRuntimeObject["updatesLiveRiskRuntime"] = true
        let liveRuntimeData = try JSONSerialization.data(withJSONObject: liveRuntimeObject)
        XCTAssertThrowsError(
            try decoder.decode(PaperAccountPortfolioProjectionV2Snapshot.self, from: liveRuntimeData)
        ) { error in
            XCTAssertEqual(error as? CoreError, .paperPortfolioProjectionForbiddenCapability("updatesLiveRiskRuntime"))
        }
    }

    func testMTP103DataCatalogScenarioReplayDefinesTerminologyAndBoundaryAnchors() throws {
        // 测试场景：MTP-103 只定义 local data catalog / scenario replay 的共同语言、
        // 目标引擎职责、source docs anchors 和 validation anchors，不实现后续 manifest 或 replay 行为。
        let boundary = DataCatalogScenarioReplayBoundary.deterministicFixture

        XCTAssertEqual(boundary.contractID, try Identifier("mtp-103-data-catalog-scenario-replay-boundary"))
        XCTAssertEqual(boundary.issueID, try Identifier("MTP-103"))
        XCTAssertEqual(boundary.terms, DataCatalogScenarioReplayTerm.allCases)
        XCTAssertEqual(
            boundary.targetEngines,
            [.dataEngine, .statePersistenceEngine, .workbenchInterface]
        )
        XCTAssertEqual(
            boundary.boundaryPrinciples,
            [
                .localFirst,
                .deterministicReplay,
                .versionedInputIdentity,
                .readModelOnlySurface,
                .noProductionDataPlatform,
                .noLiveBrokerSignedBoundary
            ]
        )
        XCTAssertEqual(boundary.forbiddenCapabilities, DataCatalogScenarioReplayForbiddenCapability.allCases)
        XCTAssertTrue(boundary.forbidsCapability(.signedEndpoint))
        XCTAssertTrue(boundary.forbidsCapability(.accountEndpoint))
        XCTAssertTrue(boundary.forbidsCapability(.brokerIntegration))
        XCTAssertTrue(boundary.forbidsCapability(.liveExecutionAdapter))
        XCTAssertTrue(boundary.forbidsCapability(.oms))
        XCTAssertTrue(boundary.forbidsCapability(.liveCommand))
        XCTAssertTrue(boundary.forbidsCapability(.productionDataPlatform))
        XCTAssertEqual(
            boundary.allowedEvidenceKinds,
            [
                .contractDocumentation,
                .sourceDocsAnchor,
                .validationPlanAnchor,
                .validationMatrixCandidate,
                .deterministicBoundaryFixture,
                .forbiddenCapabilityTest,
                .prBoundaryEvidence
            ]
        )
        XCTAssertEqual(boundary.sourceDocumentAnchors, [
            "GOAL.md",
            "BLUEPRINT.md",
            "docs/architecture.md",
            "docs/roadmap.md",
            "docs/domain/context.md",
            "docs/planning/projects/mtpro-data-catalog-scenario-replay-v1-plan.md",
            "docs/validation/latest-verification-summary.md"
        ])
        XCTAssertEqual(boundary.validationAnchors, [
            "MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY",
            "MTP-103-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY",
            "MTP-103-LOCAL-FIRST-DETERMINISTIC-VERSIONED-BOUNDARY",
            "MTP-103-FORBIDDEN-CAPABILITY-BASELINE",
            "MTP-103-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION",
            "TVM-DATA-CATALOG-SCENARIO-REPLAY"
        ])
        XCTAssertTrue(boundary.terminologyBoundaryHeld)
        XCTAssertTrue(boundary.targetEngineBoundaryHeld)
        XCTAssertTrue(boundary.localFirstDeterministicVersionedBoundaryHeld)
        XCTAssertTrue(boundary.forbiddenCapabilityBoundaryHeld)

        let encoded = try JSONEncoder().encode(boundary)
        let decoded = try JSONDecoder().decode(DataCatalogScenarioReplayBoundary.self, from: encoded)
        XCTAssertEqual(decoded, boundary)
    }

    func testMTP103DataCatalogScenarioReplayRejectsImplementationAndLiveBypass() throws {
        // 测试场景：MTP-103 fixture 的初始化和 Codable 解码必须拒绝 manifest parser、
        // fixture data、replay cursor、report input versioning、signed/account/listenKey、broker、
        // LiveExecutionAdapter、OMS、production data platform 和 Graphify / Figma 绕过。
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(parsesScenarioManifest: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("parsesScenarioManifest")
            )
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(addsFixtureData: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .dataCatalogScenarioReplayForbiddenCapability("addsFixtureData"))
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(implementsReplayCursor: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("implementsReplayCursor")
            )
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(implementsReportInputVersioning: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("implementsReportInputVersioning")
            )
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .dataCatalogScenarioReplayForbiddenCapability("usesSignedEndpoint"))
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(callsAccountEndpoint: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .dataCatalogScenarioReplayForbiddenCapability("callsAccountEndpoint"))
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(createsListenKey: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .dataCatalogScenarioReplayForbiddenCapability("createsListenKey"))
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(connectsBroker: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .dataCatalogScenarioReplayForbiddenCapability("connectsBroker"))
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(implementsLiveExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("implementsLiveExecutionAdapter")
            )
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(implementsOMS: true)
        ) { error in
            XCTAssertEqual(error as? CoreError, .dataCatalogScenarioReplayForbiddenCapability("implementsOMS"))
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(buildsProductionDataPlatform: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("buildsProductionDataPlatform")
            )
        }
        XCTAssertThrowsError(
            try DataCatalogScenarioReplayBoundary(terms: Array(DataCatalogScenarioReplayTerm.allCases.dropLast()))
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayContractMismatch(
                    field: "terms",
                    expected: DataCatalogScenarioReplayBoundary.requiredTerms.map(\.rawValue).joined(separator: ","),
                    actual: Array(DataCatalogScenarioReplayTerm.allCases.dropLast())
                        .map(\.rawValue)
                        .joined(separator: ",")
                )
            )
        }

        let encoded = try JSONEncoder().encode(DataCatalogScenarioReplayBoundary.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["buildsLargeScaleIngestionPipeline"] = true
        let data = try JSONSerialization.data(withJSONObject: object)
        XCTAssertThrowsError(
            try JSONDecoder().decode(DataCatalogScenarioReplayBoundary.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("buildsLargeScaleIngestionPipeline")
            )
        }
    }

    func testMTP103DataCatalogScenarioReplayKeepsTargetEnginesLocalFirstAndReadModelOnly() throws {
        // 测试场景：MTP-103 的 Data Engine、State & Persistence Engine 和 Workbench Interface
        // 职责只能表达 source docs / validation evidence，不得升级为生产数据平台、真实网络下载或 live command。
        let boundary = DataCatalogScenarioReplayBoundary.deterministicFixture

        XCTAssertTrue(boundary.sourceDocumentAnchors.contains("docs/architecture.md"))
        XCTAssertTrue(boundary.sourceDocumentAnchors.contains("docs/roadmap.md"))
        XCTAssertTrue(
            boundary.sourceDocumentAnchors.contains(
                "docs/planning/projects/mtpro-data-catalog-scenario-replay-v1-plan.md"
            )
        )
        XCTAssertTrue(boundary.validationAnchors.contains("MTP-103-FORBIDDEN-CAPABILITY-BASELINE"))
        XCTAssertTrue(boundary.validationAnchors.contains("TVM-DATA-CATALOG-SCENARIO-REPLAY"))
        XCTAssertTrue(boundary.isLocalFirst)
        XCTAssertTrue(boundary.isDeterministic)
        XCTAssertTrue(boundary.isVersioned)
        XCTAssertTrue(boundary.exposesReadModelOnlySurface)
        XCTAssertFalse(boundary.downloadsRealNetworkData)
        XCTAssertFalse(boundary.buildsProductionDataPlatform)
        XCTAssertFalse(boundary.buildsLargeScaleIngestionPipeline)
        XCTAssertFalse(boundary.runsLiveRuntime)
        XCTAssertFalse(boundary.providesLiveCommand)
        XCTAssertFalse(boundary.providesTradingButton)
        XCTAssertFalse(boundary.requiredValidationDependsOnNetwork)
    }

    func testMTP104ScenarioManifestDefinesIdentityVersionAndSerialization() throws {
        // 测试场景：MTP-104 manifest 必须固定 scenario id、dataset version、symbol、timeframe、
        // source anchor 和 deterministic serialization evidence，作为后续 fixture / replay / report input 的稳定来源。
        let manifest = ScenarioManifest.deterministicFixture

        XCTAssertEqual(manifest.contractID, try Identifier("mtp-104-scenario-manifest-contract"))
        XCTAssertEqual(manifest.issueID, try Identifier("MTP-104"))
        XCTAssertEqual(manifest.scenarioID, try ScenarioID("mtp-104-btcusdt-1m-first-scenario"))
        XCTAssertEqual(manifest.datasetVersion, try DatasetVersion("dataset-v1"))
        XCTAssertEqual(manifest.symbol, try Symbol(rawValue: "BTCUSDT"))
        XCTAssertEqual(manifest.timeframe, .oneMinute)
        XCTAssertEqual(manifest.sourceAnchor, "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS")
        XCTAssertEqual(manifest.scope, .singleSymbolSingleTimeframe)
        XCTAssertEqual(manifest.validationAnchors, [
            "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
            "MTP-104-SCENARIO-ID-DATASET-VERSION-STABLE-IDENTITY",
            "MTP-104-SINGLE-SYMBOL-SINGLE-TIMEFRAME-MANIFEST",
            "MTP-104-MANIFEST-DETERMINISTIC-SERIALIZATION",
            "MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY",
            "MTP-104-SCENARIO-MANIFEST-VALIDATION",
            "TVM-DATA-CATALOG-SCENARIO-REPLAY"
        ])
        XCTAssertTrue(manifest.singleSymbolSingleTimeframeBoundaryHeld)
        XCTAssertTrue(manifest.manifestBoundaryHeld)
        XCTAssertTrue(manifest.forbiddenCapabilityBoundaryHeld)

        let serialization = manifest.deterministicSerialization
        XCTAssertEqual(serialization.scenarioID, manifest.scenarioID)
        XCTAssertEqual(serialization.datasetVersion, manifest.datasetVersion)
        XCTAssertEqual(serialization.symbol, manifest.symbol)
        XCTAssertEqual(serialization.timeframe, manifest.timeframe)
        XCTAssertEqual(serialization.sourceAnchor, manifest.sourceAnchor)
        XCTAssertEqual(serialization.scope, manifest.scope)
        XCTAssertEqual(serialization.canonicalFieldOrder, ScenarioManifest.canonicalSerializationFieldOrder)
        XCTAssertEqual(
            serialization.sourceIdentity,
            "mtp-104-btcusdt-1m-first-scenario|dataset-v1|BTCUSDT|1m|MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS|single-symbol / single-timeframe"
        )
    }

    func testMTP104ScenarioManifestRejectsMultiSymbolAndLiveBypass() throws {
        // 测试场景：MTP-104 manifest 的初始化与 Codable 解码必须拒绝多 symbol / 多 timeframe catalog、
        // database schema、adapter request、secret、signed/account/listenKey、broker、order command 和 live runtime 绕过。
        XCTAssertThrowsError(
            try ScenarioManifest(
                scenarioID: try ScenarioID("mtp-104-btcusdt-1m-first-scenario"),
                datasetVersion: try DatasetVersion("dataset-v1"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                sourceAnchor: "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
                exposesDatabaseSchema: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioManifest.exposesDatabaseSchema")
            )
        }
        XCTAssertThrowsError(
            try ScenarioManifest(
                scenarioID: try ScenarioID("mtp-104-btcusdt-1m-first-scenario"),
                datasetVersion: try DatasetVersion("dataset-v1"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                sourceAnchor: "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
                exposesAdapterRequest: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioManifest.exposesAdapterRequest")
            )
        }
        XCTAssertThrowsError(
            try ScenarioManifest(
                scenarioID: try ScenarioID("mtp-104-btcusdt-1m-first-scenario"),
                datasetVersion: try DatasetVersion("dataset-v1"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                sourceAnchor: "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
                usesSignedEndpoint: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioManifest.usesSignedEndpoint")
            )
        }
        XCTAssertThrowsError(
            try ScenarioManifest(
                scenarioID: try ScenarioID("mtp-104-btcusdt-1m-first-scenario"),
                datasetVersion: try DatasetVersion("dataset-v1"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                sourceAnchor: "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
                connectsBroker: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioManifest.connectsBroker")
            )
        }
        XCTAssertThrowsError(
            try ScenarioManifest(
                scenarioID: try ScenarioID("mtp-104-btcusdt-1m-first-scenario"),
                datasetVersion: try DatasetVersion("dataset-v1"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                sourceAnchor: "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
                providesOrderCommand: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioManifest.providesOrderCommand")
            )
        }
        XCTAssertThrowsError(
            try ScenarioManifest(
                scenarioID: try ScenarioID("mtp-104-btcusdt-1m-first-scenario"),
                datasetVersion: try DatasetVersion("dataset-v1"),
                symbol: try Symbol(rawValue: "BTCUSDT"),
                timeframe: .oneMinute,
                sourceAnchor: "MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS",
                usesMultipleSymbols: true
            )
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioManifest.usesMultipleSymbols")
            )
        }

        let encoded = try JSONEncoder().encode(ScenarioManifest.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["createsListenKey"] = true
        let data = try JSONSerialization.data(withJSONObject: object)
        XCTAssertThrowsError(
            try JSONDecoder().decode(ScenarioManifest.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioManifest.createsListenKey")
            )
        }
    }

    func testMTP104ScenarioManifestRoundTripsAsStableSourceIdentity() throws {
        // 测试场景：同一 scenario manifest 经 Codable round-trip 后必须保持相同 deterministic serialization，
        // 且仍不包含 secret、signed/account/listenKey、broker、production registry、真实网络或 live runtime 能力。
        let manifest = ScenarioManifest.deterministicFixture
        let encodedManifest = try JSONEncoder().encode(manifest)
        let decodedManifest = try JSONDecoder().decode(ScenarioManifest.self, from: encodedManifest)

        XCTAssertEqual(decodedManifest, manifest)
        XCTAssertEqual(decodedManifest.deterministicSerialization, manifest.deterministicSerialization)
        XCTAssertEqual(
            decodedManifest.deterministicSerialization.sourceIdentity,
            manifest.deterministicSerialization.sourceIdentity
        )
        XCTAssertFalse(manifest.exposesDatabaseSchema)
        XCTAssertFalse(manifest.exposesAdapterRequest)
        XCTAssertFalse(manifest.readsSecret)
        XCTAssertFalse(manifest.usesSignedEndpoint)
        XCTAssertFalse(manifest.callsAccountEndpoint)
        XCTAssertFalse(manifest.createsListenKey)
        XCTAssertFalse(manifest.connectsBroker)
        XCTAssertFalse(manifest.providesOrderCommand)
        XCTAssertFalse(manifest.runsLiveRuntime)
        XCTAssertFalse(manifest.registersProductionDataset)
        XCTAssertFalse(manifest.downloadsRealNetworkData)
        XCTAssertFalse(manifest.usesMultipleTimeframes)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let encodedSerialization = try encoder.encode(manifest.deterministicSerialization)
        let decodedSerialization = try JSONDecoder().decode(
            ScenarioManifestDeterministicSerialization.self,
            from: encodedSerialization
        )
        XCTAssertEqual(decodedSerialization, manifest.deterministicSerialization)

        var serializationObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encodedSerialization) as? [String: Any]
        )
        serializationObject["canonicalFieldOrder"] = ["scenarioID", "datasetVersion"]
        let serializationBypassData = try JSONSerialization.data(withJSONObject: serializationObject)
        XCTAssertThrowsError(
            try JSONDecoder().decode(ScenarioManifestDeterministicSerialization.self, from: serializationBypassData)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayContractMismatch(
                    field: "serialization.canonicalFieldOrder",
                    expected: ScenarioManifest.canonicalSerializationFieldOrder.joined(separator: ","),
                    actual: "scenarioID,datasetVersion"
                )
            )
        }
    }

    func testMTP105DeterministicScenarioFixtureDefinesSingleSymbolSingleTimeframeRecords() throws {
        // 测试场景：MTP-105 first scenario fixture 必须复用 MTP-104 manifest，
        // 并固定 fixture version、single-symbol / single-timeframe records、fixed window 和 record order。
        let fixture = DeterministicScenarioFixture.deterministicFixture

        XCTAssertEqual(fixture.contractID, try Identifier("mtp-105-deterministic-scenario-fixture"))
        XCTAssertEqual(fixture.issueID, try Identifier("MTP-105"))
        XCTAssertEqual(fixture.manifest, ScenarioManifest.deterministicFixture)
        XCTAssertEqual(fixture.fixtureVersion, try FixtureVersion("fixture-v1"))
        XCTAssertEqual(fixture.sourceKind, .binancePublicReadOnlyLocalFixture)
        XCTAssertEqual(fixture.sourceAnchor, "MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE")
        XCTAssertEqual(fixture.recordOrderPolicy, .fixedAscendingIntervalStart)
        XCTAssertEqual(fixture.records.count, 3)
        XCTAssertEqual(fixture.records.map(\.sequence), [1, 2, 3])
        XCTAssertEqual(fixture.records.map(\.bar.symbol), Array(repeating: try Symbol(rawValue: "BTCUSDT"), count: 3))
        XCTAssertEqual(fixture.records.map(\.bar.timeframe), Array(repeating: Timeframe.oneMinute, count: 3))
        XCTAssertEqual(
            fixture.records.map { Int($0.bar.interval.start.timeIntervalSince1970) },
            [1_704_067_200, 1_704_067_260, 1_704_067_320]
        )
        XCTAssertEqual(Int(fixture.fixedWindow.start.timeIntervalSince1970), 1_704_067_200)
        XCTAssertEqual(Int(fixture.fixedWindow.end.timeIntervalSince1970), 1_704_067_380)
        XCTAssertTrue(fixture.fixtureIdentityAlignedWithManifest)
        XCTAssertTrue(fixture.fixedRecordOrderHeld)
        XCTAssertTrue(fixture.publicReadOnlyLocalFixtureRelationshipHeld)
        XCTAssertTrue(fixture.forbiddenCapabilityBoundaryHeld)
        XCTAssertTrue(fixture.fixtureBoundaryHeld)
    }

    func testMTP105ScenarioFixtureBuildsDeterministicSummaryPrestructure() throws {
        // 测试场景：MTP-105 只建立 deterministic summary / checksum preimage 结构，
        // 不计算 MTP-106 的最终 checksum、replay cursor 或 freshness evidence。
        let fixture = DeterministicScenarioFixture.deterministicFixture
        let summary = fixture.deterministicSummary

        XCTAssertEqual(summary.scenarioID, try ScenarioID("mtp-104-btcusdt-1m-first-scenario"))
        XCTAssertEqual(summary.datasetVersion, try DatasetVersion("dataset-v1"))
        XCTAssertEqual(summary.fixtureVersion, try FixtureVersion("fixture-v1"))
        XCTAssertEqual(summary.symbol, try Symbol(rawValue: "BTCUSDT"))
        XCTAssertEqual(summary.timeframe, .oneMinute)
        XCTAssertEqual(summary.recordCount, 3)
        XCTAssertEqual(summary.orderedRecordStarts, [1_704_067_200, 1_704_067_260, 1_704_067_320])
        XCTAssertEqual(summary.recordOrderIdentity, "1:1704067200|2:1704067260|3:1704067320")
        XCTAssertEqual(summary.canonicalRecordSummary.count, 3)
        XCTAssertEqual(
            summary.canonicalRecordSummary.first,
            "sequence=1|symbol=BTCUSDT|timeframe=1m|window=1704067200...1704067260|open=42000100000|high=42100200000|low=41900300000|close=42050400000|volume=12345000|sourceAnchor=MTP-105-FIXED-WINDOW-RECORD-ORDER"
        )
        XCTAssertTrue(summary.checksumPreimage.contains("sequence=1|symbol=BTCUSDT|timeframe=1m"))
        XCTAssertTrue(summary.checksumPreimage.contains("sequence=3|symbol=BTCUSDT|timeframe=1m"))
        XCTAssertTrue(summary.checksumEvidenceDeferredToMTP106)
        XCTAssertEqual(
            summary.sourceIdentity,
            "mtp-104-btcusdt-1m-first-scenario|dataset-v1|BTCUSDT|1m|MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS|single-symbol / single-timeframe"
        )
        XCTAssertTrue(summary.publicReadOnlyLocalFixtureRelationshipHeld)
        XCTAssertFalse(summary.dependsOnNetwork)
    }

    func testMTP105ScenarioFixtureRejectsNetworkLiveAndRecordOrderBypass() throws {
        // 测试场景：MTP-105 fixture 的初始化和 Codable 解码必须拒绝真实网络、
        // production ingestion、signed/account/listenKey、broker、LiveExecutionAdapter、live command 和乱序记录。
        XCTAssertThrowsError(
            try DeterministicScenarioFixture(downloadsRealNetworkData: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioFixture.downloadsRealNetworkData")
            )
        }
        XCTAssertThrowsError(
            try DeterministicScenarioFixture(usesSignedEndpoint: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioFixture.usesSignedEndpoint")
            )
        }
        XCTAssertThrowsError(
            try DeterministicScenarioFixture(connectsBroker: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioFixture.connectsBroker")
            )
        }
        XCTAssertThrowsError(
            try DeterministicScenarioFixture(implementsLiveExecutionAdapter: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioFixture.implementsLiveExecutionAdapter")
            )
        }
        XCTAssertThrowsError(
            try DeterministicScenarioFixture(providesLiveCommand: true)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioFixture.providesLiveCommand")
            )
        }

        var outOfOrderRecords = DeterministicScenarioFixture.deterministicFixture.records
        outOfOrderRecords.swapAt(1, 2)
        XCTAssertThrowsError(
            try DeterministicScenarioFixture(records: outOfOrderRecords)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayContractMismatch(
                    field: "scenarioFixture.recordSequence",
                    expected: "1,2,3",
                    actual: "1,3,2"
                )
            )
        }

        let encoded = try JSONEncoder().encode(DeterministicScenarioFixture.deterministicFixture)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["callsAccountEndpoint"] = true
        let data = try JSONSerialization.data(withJSONObject: object)
        XCTAssertThrowsError(
            try JSONDecoder().decode(DeterministicScenarioFixture.self, from: data)
        ) { error in
            XCTAssertEqual(
                error as? CoreError,
                .dataCatalogScenarioReplayForbiddenCapability("scenarioFixture.callsAccountEndpoint")
            )
        }
    }

    func testMTP105ScenarioFixtureRoundTripsWithoutForbiddenCapabilityText() throws {
        // 测试场景：first scenario fixture 必须可编码、可比较、可作为后续 replay / report input 的稳定输入，
        // 且 evidence 文本不能混入 signed/account/listenKey/broker/live command 等禁区能力。
        let fixture = DeterministicScenarioFixture.deterministicFixture
        let encoded = try JSONEncoder().encode(fixture)
        let decoded = try JSONDecoder().decode(DeterministicScenarioFixture.self, from: encoded)

        XCTAssertEqual(decoded, fixture)
        XCTAssertEqual(decoded.deterministicSummary, fixture.deterministicSummary)
        XCTAssertTrue(decoded.fixtureBoundaryHeld)
        XCTAssertFalse(decoded.requiredValidationDependsOnNetwork)
        XCTAssertFalse(decoded.downloadsRealNetworkData)
        XCTAssertFalse(decoded.runsProductionIngestionPipeline)
        XCTAssertFalse(decoded.buildsCloudDataLake)
        XCTAssertFalse(decoded.exposesAdapterRequest)
        XCTAssertFalse(decoded.readsSecret)
        XCTAssertFalse(decoded.usesSignedEndpoint)
        XCTAssertFalse(decoded.callsAccountEndpoint)
        XCTAssertFalse(decoded.createsListenKey)
        XCTAssertFalse(decoded.connectsBroker)
        XCTAssertFalse(decoded.instantiatesBrokerExecutionAdapter)
        XCTAssertFalse(decoded.instantiatesExchangeExecutionAdapter)
        XCTAssertFalse(decoded.implementsLiveExecutionAdapter)
        XCTAssertFalse(decoded.implementsOMS)
        XCTAssertFalse(decoded.implementsRealOrderLifecycle)
        XCTAssertFalse(decoded.providesLiveCommand)
        XCTAssertFalse(decoded.providesTradingButton)
        XCTAssertFalse(decoded.usesMultipleSymbols)
        XCTAssertFalse(decoded.usesMultipleTimeframes)
        XCTAssertFalse(
            decoded.containsForbiddenCapabilityText([
                "signed endpoint",
                "account endpoint",
                "listenKey",
                "broker fill",
                "real order",
                "live command",
                "trading button"
            ])
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
