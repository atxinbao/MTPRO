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
