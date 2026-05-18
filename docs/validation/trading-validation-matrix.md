# Trading Validation Matrix

日期：2026-05-19

执行者：Codex

本文档是 MTP-24 的交易验证矩阵入口，用于把交易语义验证拆成可审计、可自动检查、可回填证据的位置。

本文档不授权执行 Linear issue，不修改 Linear status，不启动 symphony-issue，不创建 Linear Project / Issue，不替代 PR evidence、Linear issue contract 或 Stage Code Audit Report。

## 使用规则

- 每一行的 `Matrix ID` 是稳定锚点，`checks/automation-readiness.sh` 会检查这些锚点是否存在。
- 后续 issue 增加测试、fixtures、read model 或 report evidence 时，必须回填对应矩阵行的 evidence 位置和验证说明。
- 回填证据必须来自本地可重复验证入口，例如 XCTest、fixture、read model snapshot、PR evidence 或 append-only `verification.md` 记录。
- CI 通过、人工观察或 planning notes 不能单独作为交易语义验收证据。
- `bash checks/run.sh` 是统一验证入口；当前 issue 不新增独立 eval 框架。

## 统一边界

- 第一版交易验证只覆盖 Research / Backtest / Paper readiness。
- 标的范围仍为 `BTCUSDT`、`ETHUSDT`、`BNBUSDT`、`SOLUSDT`、`XRPUSDT`。
- 时间粒度仍为 `1m` 和 `5m`。
- Binance 只允许 public read-only market data。
- 禁止 Live trading、signed endpoint、account endpoint、listenKey user data stream、真实 broker action、真实订单提交 / 取消 / 替换、futures leverage / margin action。

## 验证矩阵

| Matrix ID | 验证域 | 当前 coverage 入口 | 验收证据边界 | 后续回填责任 |
| --- | --- | --- | --- | --- |
| `TVM-EMA-PARITY` | EMA Backtest / Paper signal timeline parity | `Tests/CoreTests/CoreTests.swift` 中的 `testEMACrossStrategyContractGeneratesDeterministicSignalFixture`、`testEMACrossStrategyRejectsInvalidConfigurationAndMismatchedMarketData`、`testBacktestAndPaperEventFlowsShareSignalTimelineForParity`、`testEMABacktestPaperParityLocksStrategyQueryWarmupAndSignalTimeline`、`testEMAEventFlowsRejectBarsOutsideMarketDataQueryRange`、`testBacktestAndPaperEventFlowsCanPublishThroughMessageBusStreams` | 证据覆盖同一 strategy、同一 `MarketDataQuery`、`marketData.range`、warm-up、signal direction、timestamp、完整 signal timeline，以及 mismatch / insufficient data / query range too narrow 的错误边界。 | MTP-25 已回填 deterministic fixture 和 edge case；PR evidence 必须继续附 `bash checks/run.sh` 摘要，并确认 symbol、timeframe、warm-up、timestamp 和 query range 均由本地测试覆盖。 |
| `TVM-PAPER-SESSION-LIFECYCLE` | Paper Session lifecycle facts 和 event log 写入边界 | `Sources/Core/PaperSessionLifecycle.swift` 中的 `PaperSessionLifecycleState`、`PaperSessionStarted`、`PaperSessionUpdated`、`PaperSessionClosed`、`PaperSessionEventLogBoundary`；`Sources/Core/DomainEvents.swift` 中的 `PaperEvent.sessionStarted / sessionUpdated / sessionClosed`；`Tests/CoreTests/CoreTests.swift` 中的 `testPaperSessionLifecycleEmitsStartedUpdatedClosedFactsDeterministically` 和 `testPaperSessionEventLogBoundaryWritesOnlyPaperStreamFacts`。 | 证据覆盖 started / updated / closed 三类 paper-only lifecycle facts、固定 timestamp fixture、非负 signalCount、`.paper` stream append-only 写入、stream replay 过滤和 Live / broker / signed endpoint 禁区。 | MTP-31 已回填 Core lifecycle facts、event log 写入边界、deterministic tests 和 PR evidence 边界；后续 MTP-32 至 MTP-36 只能消费这些 facts，不得把 lifecycle event 解释为真实订单、broker action 或 Live fallback。 |
| `TVM-PAPER-ACTION-PROPOSAL` | Paper action proposal 最小模型和 deterministic fixture | `Sources/Core/PaperActionProposal.swift` 中的 `PaperActionProposalSide`、`PaperActionProposalSizingAssumption`、`PaperActionProposal`、`PaperActionProposalAuthorization`、`PaperActionProposalFixture`；`Tests/CoreTests/CoreTests.swift` 中的 `testPaperActionProposalMapsStrategySignalToPaperOnlyIntentDeterministically` 和 `testPaperActionProposalDecodingRejectsNonPaperOrMismatchedIntent`。 | 证据覆盖 strategy signal 到 paper-only side 的映射、symbol / timeframe、quantity、reference price、notional、MTP-27 fixed cost evidence 复用、Codable 不变量、`executionMode == paper`、`paperIntentOnly` 和 `isExecutableAsRealOrder == false`；不得引入 order command、broker action、真实 fill、portfolio update、signed endpoint 或 Live execution。 | MTP-32 已回填 Core proposal model、deterministic long / flat fixture、paper-only 不可执行边界和 PR evidence 边界；后续 MTP-33 至 MTP-36 只能消费该 proposal evidence，不得把 proposal 解释为真实订单或执行授权。 |
| `TVM-PAPER-SESSION-REPLAY` | Paper Session replay evidence | `Sources/Core/PaperSessionReplay.swift` 中的 `PaperSessionReplayEvidenceSummary`、`PaperSessionReplayPath` 和 `PaperSessionReplayFixture`；`Sources/Core/DomainEvents.swift` 中的 `PaperEvent.actionProposed`；`Sources/App/App.swift` 中的 `PaperSessionRuntimeEvidenceSummary`；`Tests/CoreTests/CoreTests.swift` 中的 `testPaperSessionReplayEvidenceSummarizesRuntimeEventsDeterministically` 和 `testPaperSessionReplayEvidenceRejectsOutOfOrderReplayResult`；`Tests/PersistenceTests/PersistenceTests.swift` 中的 `testPaperSessionReplayEvidenceUsesFileAppendOnlyFactsSource`；`Tests/AppTests/AppTests.swift` 中的 `testReadModelProjectionMapsAllDashboardSections`、`testDashboardViewModelStateSnapshotIsCodableAndDeterministic` 和 `testDashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell`。 | 证据覆盖 append-only replay sequences / streams、session lifecycle、proposal、risk blocker、portfolio projection update、Codable deterministic summary、乱序 replay 拒绝、FileEventLogStore facts source、SQLite runtime projection replay、Report / Dashboard runtime evidence summary 和 paper-only boundary flags；不得引入生产级 event sourcing、schema migration、真实 broker event replay、外部 execution venue、signed endpoint、broker action 或真实订单行为。 | MTP-35 已回填 Paper Session replay path、proposal event replay fact、deterministic summary fixture、Core / Persistence tests 和 PR evidence 边界；MTP-36 已回填 Report / Dashboard 对该 summary / projection evidence 的只读消费，不得绕过 append-only facts source 或暴露 database schema。 |
| `TVM-ORDER-BOOK-IMBALANCE-PARITY` | Order book imbalance research parity 和 bias evidence | `Tests/CoreTests/CoreTests.swift` 中的 `testOrderBookReadModelAppliesSnapshotAndDeltasDeterministically`、`testOrderBookImbalanceStrategyGeneratesStableSignalFixture`、`testOrderBookImbalanceResearchParityEvidenceCoversBiasAndInputSources`、`testOrderBookImbalanceRejectsInvalidConfigurationAndInputs`、`testOrderBookImbalanceResearchFlowPublishesThroughStrategyStream`；`Tests/PersistenceTests/PersistenceTests.swift` 中的 `testTemporaryDuckDBProjectionRebuildsAnalyticalState`、`testDuckDBAnalyticalProjectionAdapterRebuildsAndQueriesSnapshotFromReplay` | 证据必须覆盖 depth、bid / ask notional、imbalance ratio、bias、signal direction、source timestamp、snapshot / delta input source、thin book / mismatched symbol 错误边界；ask dominance 只能作为 research bias，不得映射为真实 short / margin action。 | MTP-26 已回填：Core signal sample 携带 `inputSource`，`OrderBookImbalanceResearchParity` 覆盖 direct contract 与 research event flow parity，DuckDB signal timeline 携带 `orderBookInputSource`；PR evidence 记录 `bash checks/run.sh` 摘要。 |
| `TVM-FEES-SLIPPAGE` | fees / slippage 假设、fixture 和最小计算边界 | `Sources/Core/ExecutionCosts.swift` 中的 `ExecutionCostAssumptions.deterministicFixture`、`ExecutionCostCalculator.estimate`、`ExecutionCostParity.verify`；`Tests/CoreTests/CoreTests.swift` 中的 `testExecutionCostAssumptionsGenerateDeterministicFeesAndSlippageFixture`、`testExecutionCostParityKeepsBacktestAndPaperCostEvidenceConsistent`、`testExecutionCostAssumptionsRejectInvalidRatesAndRounding`。 | 证据覆盖 fixed maker fee、fixed taker fee、fixed slippage、gross notional、total cost、rounding scale、Backtest / Paper cost parity 和 invalid assumption 边界；不得引入完整费用模型、交易所费率表、动态滑点模型、执行成本优化、真实成交或 broker fill。 | MTP-27 已回填：Core deterministic fixture、最小计算输出、parity result、invalid assumption tests 和 PR evidence 边界；MTP-29 如需展示 evidence，只能从该稳定结果派生 read model。 |
| `TVM-RISK-BLOCKER` | risk blocker evidence | `Sources/Core/DomainEvents.swift` 中的 `RiskBlockerEvidence`；`Sources/Core/PaperActionRiskLink.swift` 中的 `PaperActionProposalRiskPolicy`、`PaperActionProposalRiskDecision`、`PaperActionProposalRiskLink` 和 `PaperActionProposalRiskFixture`；`Sources/Persistence/Persistence.swift` 中的 `SQLiteRiskBlockerEvidenceProjection`、`Sources/App/App.swift` 中的 `RiskBlockerEvidenceViewModel`；`Tests/CoreTests/CoreTests.swift` 中的 `testRiskBlockerEvidenceAndPortfolioExposureRemainPaperOnlyReadModels`、`testPaperActionRiskLinkAllowsPaperProposalWithTraceableContext`、`testPaperActionRiskLinkBlocksOversizedPaperProposalWithEvidence`、`testPaperActionRiskDecisionDecodingRejectsMismatchedEvidence`，`Tests/PersistenceTests/PersistenceTests.swift` 中的 `testSQLiteRuntimeProjectionAdapterRebuildsAndQueriesSnapshotFromReplay`、`testTemporarySQLiteProjectionRebuildsRuntimeState`，`Tests/AppTests/AppTests.swift` 中的 `testReadModelProjectionMapsAllDashboardSections`、`testDashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell`。 | 证据覆盖 blocker reason、proposed paper action context、risk profile、paper-only execution mode、event / projection source sequence、allowed / blocked decision、Codable 不变量、read-only ViewModel，以及 Live / broker / signed endpoint 不可回退边界。 | MTP-28 已回填 Core evidence fixture、SQLite runtime projection、RiskViewModel / shell snapshot 和 PR evidence 边界；MTP-33 已回填 strategy signal -> proposal -> risk blocker 本地链路、allowed / blocked deterministic fixtures、source sequence 和无 Live / broker fallback 证据。后续 issue 只能消费稳定 read model，不得引入完整风险引擎或 Live fallback。 |
| `TVM-PORTFOLIO-EXPOSURE` | portfolio exposure 只读指标 | `Sources/Core/DomainEvents.swift` 中的 `PortfolioExposureSnapshot`、`Sources/Core/PaperPortfolioProjectionUpdate.swift` 中的 `PaperPortfolioProjectionUpdate`、`Sources/Persistence/Persistence.swift` 中的 `SQLitePortfolioExposureProjection`、`Sources/App/App.swift` 中的 `PortfolioExposureViewModel`；`Tests/CoreTests/CoreTests.swift` 中的 `testRiskBlockerEvidenceAndPortfolioExposureRemainPaperOnlyReadModels`、`testPaperPortfolioProjectionUpdateEmitsPaperOnlyPortfolioEventFromAllowedDecision`、`testPaperPortfolioProjectionUpdateRejectsBlockedDecisionAndCapabilityBypass`，`Tests/PersistenceTests/PersistenceTests.swift` 中的 `testSQLiteRuntimeProjectionAdapterRebuildsAndQueriesSnapshotFromReplay`、`testTemporarySQLiteProjectionRebuildsRuntimeState`、`testSQLiteRuntimeProjectionAppliesPaperPortfolioProjectionUpdateFromReplay`，`Tests/AppTests/AppTests.swift` 中的 `testReadModelProjectionMapsAllDashboardSections`、`testPortfolioViewModelConsumesPaperPortfolioUpdateProjectionReadOnly`、`testDashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell`。 | 证据覆盖 allowed risk decision -> paper-only portfolio update、blocked decision 拒绝、portfolio ID、symbol / timeframe、paper quantity、reference price、gross exposure notional、paper-only exposure 来源、risk decision source sequence、projection last applied sequence 和 read-only ViewModel；不得引入 margin、leverage、account endpoint、真实 broker balance、broker position sync 或交易执行授权。 | MTP-28 已回填最小 portfolio exposure read model、projection、ViewModel、shell snapshot 和 validation 摘要；MTP-29 已从该稳定结果派生 report / dashboard evidence；MTP-34 已回填 allowed risk decision 驱动的 paper-only portfolio update path、replay / SQLite projection 和 read-only ViewModel tests。 |
| `TVM-REPORT-EVIDENCE` | Report / Dashboard trading validation evidence | `Sources/App/App.swift` 中的 `ReportExecutionCostEvidence`、`TradingValidationEvidenceSummary`、`PaperSessionRuntimeEvidenceSummary`、`ResearchBacktestReportArtifact.paperRuntimeEvidence`、`ReportArtifactViewModel.tradingValidationEvidence` 和 `ReportViewModel` 汇总字段；`Sources/App/DashboardShell.swift` 中的 Report shell snapshot；`Tests/AppTests/AppTests.swift` 中的 `testReadModelProjectionMapsAllDashboardSections`、`testDashboardViewModelStateSnapshotIsCodableAndDeterministic`、`testReportReadModelMarksMissingPaperProjectionWithoutLiveFallback`、`testDashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell`、`testDashboardShellSourceDoesNotImportForbiddenIntegrationLayers`。 | 证据必须从 projection snapshots / read model / append-only event timeline 派生；Report 可汇总 projection-level parity、MTP-27 deterministic cost evidence、risk blocker evidence、paper-only portfolio exposure evidence 和 Paper Session replay runtime evidence，但不得替代 Core 层完整 signal timeline parity，不得暴露数据库 schema，不得授权真实交易执行。 | MTP-29 已回填 Report / Dashboard trading validation evidence summary、cost assumption IDs、cost parity consistency、risk blocker evidence IDs、portfolio exposure symbols、gross exposure notional、snapshot tests 和 PR evidence 边界；MTP-36 已回填 Paper Session runtime evidence summary、replay facts、proposal IDs、portfolio update IDs、paper-only boundary flags 和 Dashboard snapshot evidence。 |

## 后续 issue 回填规则

`TVM-FUTURE-ISSUE-BACKFILL`

| Issue | 必须回填的 Matrix ID | 回填内容 |
| --- | --- | --- |
| `MTP-25` | `TVM-EMA-PARITY` | 已新增或加固 EMA parity tests、deterministic fixture、query range edge case；PR evidence 和 `bash checks/run.sh` 摘要由本 issue handoff 提供。 |
| `MTP-26` | `TVM-ORDER-BOOK-IMBALANCE-PARITY` | 已回填 Core parity / bias evidence fixture、snapshot / delta input source、DuckDB projection evidence、research-only 边界和 `bash checks/run.sh` validation 摘要。 |
| `MTP-27` | `TVM-FEES-SLIPPAGE` | 已回填 fees / slippage fixed assumptions、deterministic fixture、最小计算边界、Backtest / Paper cost parity、禁止项和 validation 摘要。 |
| `MTP-28` | `TVM-RISK-BLOCKER`、`TVM-PORTFOLIO-EXPOSURE` | 已回填 risk blocker evidence、portfolio exposure read model、Core / Persistence / App tests、shell snapshot、禁止项和 validation 摘要。 |
| `MTP-29` | `TVM-REPORT-EVIDENCE` | 已回填 Report / Dashboard 中交易验证 evidence summary、execution cost evidence、risk blocker evidence、portfolio exposure evidence、snapshot tests、read-only boundary 和 validation 摘要。 |
| `MTP-30` | 全部 Matrix ID | 已新增 `docs/validation/mtp-30-stage-audit-input.md`，集中记录 MTP-24 至 MTP-29 的 PR evidence、merge commit、required check、matrix evidence chain、known boundaries、automation readiness evidence 和 Stage Code Audit handoff checklist；最终 Stage Code Audit Report 仍由 Parent Codex 在 Project 全部 Done 后单独输出。 |
| `MTP-31` | `TVM-PAPER-SESSION-LIFECYCLE` | 已回填 Paper session lifecycle state、started / updated / closed events、event log 写入边界、deterministic fixture tests、paper-only 禁区和 validation 摘要。 |
| `MTP-32` | `TVM-PAPER-ACTION-PROPOSAL` | 已回填 Paper action proposal 最小模型、deterministic sizing fixture、long / flat signal 映射、MTP-27 cost evidence 复用、Codable 不变量和 paper-only 不可执行边界。 |
| `MTP-33` | `TVM-RISK-BLOCKER` | 已回填 Paper action risk link、allowed / blocked deterministic fixtures、`RiskEvaluationQuery` 串联、`RiskBlockerEvidence` 复用、source sequence、Codable 不变量和无 broker / Live fallback 边界。 |
| `MTP-34` | `TVM-PORTFOLIO-EXPOSURE` | 已回填 allowed paper risk decision -> `PaperPortfolioProjectionUpdate` -> `PortfolioEvent.paperProjectionUpdated` -> SQLite runtime projection -> Portfolio ViewModel 的本地链路、blocked decision 拒绝、source sequence、Codable 禁区和无真实账户 / broker sync / Live fallback 边界。 |
| `MTP-35` | `TVM-PAPER-SESSION-REPLAY` | 已回填 append-only event log replay -> Paper Session replay summary、`PaperEvent.actionProposed`、session / proposal / risk blocker / portfolio projection events、FileEventLogStore facts source、SQLite runtime projection replay、乱序 replay 拒绝和 paper-only boundary flags。 |
| `MTP-36` | `TVM-PAPER-SESSION-REPLAY`、`TVM-REPORT-EVIDENCE` | 已回填 Paper Session runtime evidence -> Report / Dashboard read model 汇总、`PaperSessionRuntimeEvidenceSummary`、report artifact / ViewModel / shell snapshot 字段、Codable deterministic snapshot、read-model-only boundary、无 UI execution surface 和无 broker / Live fallback 边界。 |

## MTP-30 阶段收口

MTP-30 对已实现验证域做阶段收口，不新增业务交易能力，不替代最终 Stage Code Audit Report。

| 收口项 | Evidence location | 审计用途 |
| --- | --- | --- |
| Issue / PR evidence | `docs/validation/mtp-30-stage-audit-input.md` 的 `Issue / PR evidence input` | 为 Parent Codex 汇总 PR #52、#53、#55、#56、#57、#58 和 MTP-30 PR 提供输入。 |
| Matrix coverage | `docs/validation/mtp-30-stage-audit-input.md` 的 `Trading validation evidence chain` | 确认所有 Matrix ID 都有 test / fixture / read model / PR evidence。 |
| Known boundaries | `docs/validation/mtp-30-stage-audit-input.md` 的 `Known boundaries` | 为 Stage Code Audit 的交易禁区、schema leakage 禁区和 Report 授权边界提供输入。 |
| Automation readiness | `checks/automation-readiness.sh`、`docs/automation/verified-operations.md`、`.github/pull_request_template.md` | 确认 `checks`、WIP=1、handoff marker、Post-Issue Ledger、Graphify ignore 和 PR Automation 证据链仍完整。 |
| Root Docs Delta input | `docs/validation/mtp-30-stage-audit-input.md` 的 `Root Docs Delta input` | 提醒 Parent Codex 在最终 Stage Code Audit Report 中检查 root docs，只同步已发生事实。 |

## Automation readiness anchors

以下锚点必须保留，供 `checks/automation-readiness.sh` 做机械检查：

- `TVM-EMA-PARITY`
- `TVM-PAPER-SESSION-LIFECYCLE`
- `TVM-PAPER-ACTION-PROPOSAL`
- `TVM-PAPER-SESSION-REPLAY`
- `TVM-ORDER-BOOK-IMBALANCE-PARITY`
- `TVM-FEES-SLIPPAGE`
- `TVM-RISK-BLOCKER`
- `TVM-PORTFOLIO-EXPOSURE`
- `TVM-REPORT-EVIDENCE`
- `TVM-FUTURE-ISSUE-BACKFILL`
