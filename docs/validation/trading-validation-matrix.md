# Trading Validation Matrix

日期：2026-05-18

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
| `TVM-ORDER-BOOK-IMBALANCE-PARITY` | Order book imbalance research parity 和 bias evidence | `Tests/CoreTests/CoreTests.swift` 中的 `testOrderBookReadModelAppliesSnapshotAndDeltasDeterministically`、`testOrderBookImbalanceStrategyGeneratesStableSignalFixture`、`testOrderBookImbalanceResearchParityEvidenceCoversBiasAndInputSources`、`testOrderBookImbalanceRejectsInvalidConfigurationAndInputs`、`testOrderBookImbalanceResearchFlowPublishesThroughStrategyStream`；`Tests/PersistenceTests/PersistenceTests.swift` 中的 `testTemporaryDuckDBProjectionRebuildsAnalyticalState`、`testDuckDBAnalyticalProjectionAdapterRebuildsAndQueriesSnapshotFromReplay` | 证据必须覆盖 depth、bid / ask notional、imbalance ratio、bias、signal direction、source timestamp、snapshot / delta input source、thin book / mismatched symbol 错误边界；ask dominance 只能作为 research bias，不得映射为真实 short / margin action。 | MTP-26 已回填：Core signal sample 携带 `inputSource`，`OrderBookImbalanceResearchParity` 覆盖 direct contract 与 research event flow parity，DuckDB signal timeline 携带 `orderBookInputSource`；PR evidence 记录 `bash checks/run.sh` 摘要。 |
| `TVM-FEES-SLIPPAGE` | fees / slippage 假设、fixture 和最小计算边界 | `Sources/Core/ExecutionCosts.swift` 中的 `ExecutionCostAssumptions.deterministicFixture`、`ExecutionCostCalculator.estimate`、`ExecutionCostParity.verify`；`Tests/CoreTests/CoreTests.swift` 中的 `testExecutionCostAssumptionsGenerateDeterministicFeesAndSlippageFixture`、`testExecutionCostParityKeepsBacktestAndPaperCostEvidenceConsistent`、`testExecutionCostAssumptionsRejectInvalidRatesAndRounding`。 | 证据覆盖 fixed maker fee、fixed taker fee、fixed slippage、gross notional、total cost、rounding scale、Backtest / Paper cost parity 和 invalid assumption 边界；不得引入完整费用模型、交易所费率表、动态滑点模型、执行成本优化、真实成交或 broker fill。 | MTP-27 已回填：Core deterministic fixture、最小计算输出、parity result、invalid assumption tests 和 PR evidence 边界；MTP-29 如需展示 evidence，只能从该稳定结果派生 read model。 |
| `TVM-RISK-BLOCKER` | risk blocker evidence | `Tests/CoreTests/CoreTests.swift` 中的 `testCommandAndQueryContractsRejectLiveExecutionMode` 覆盖 live 禁区；`Tests/PersistenceTests/PersistenceTests.swift` 和 `Tests/AppTests/AppTests.swift` 覆盖 risk projection / RiskViewModel 只读观察入口。 | 证据必须覆盖 blocker reason、proposed paper action context、risk profile、event / projection 映射，以及 Live / broker / signed endpoint 不可回退边界。 | MTP-28 新增 risk blocker evidence 后回填 Core / Persistence / App test 路径和 read model evidence。 |
| `TVM-PORTFOLIO-EXPOSURE` | portfolio exposure 只读指标 | `Tests/CoreTests/CoreTests.swift` 的 append-only event log / portfolio stream 覆盖、`Tests/PersistenceTests/PersistenceTests.swift` 的 SQLite runtime projection 覆盖、`Tests/AppTests/AppTests.swift` 的 PortfolioViewModel 覆盖。 | 证据必须覆盖 portfolio ID、symbol / timeframe、paper-only exposure 来源、projection last applied sequence 和 read-only ViewModel；不得引入 margin、leverage、account endpoint 或真实 broker balance。 | MTP-28 新增最小 portfolio exposure read model 后回填 projection、ViewModel、fixture 和 PR evidence。 |
| `TVM-REPORT-EVIDENCE` | Report / Dashboard trading validation evidence | `Tests/AppTests/AppTests.swift` 中的 `testReportReadModelMarksMissingPaperProjectionWithoutLiveFallback`、`testDashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell`、`testDashboardShellSourceDoesNotImportForbiddenIntegrationLayers`；`docs/validation/mtp-23-stage-evidence.md` 记录 Research -> Backtest -> Report 最小路径。 | 证据必须从 projection snapshots / read model / append-only event timeline 派生，可表达 projection-level parity，但不得替代 Core 层完整 signal timeline parity；Report 是研究输出，不授权真实交易执行。 | MTP-29 汇总 trading validation evidence 到 Report / Dashboard 后回填 read model 字段、snapshot test 和 PR evidence。 |

## 后续 issue 回填规则

`TVM-FUTURE-ISSUE-BACKFILL`

| Issue | 必须回填的 Matrix ID | 回填内容 |
| --- | --- | --- |
| `MTP-25` | `TVM-EMA-PARITY` | 已新增或加固 EMA parity tests、deterministic fixture、query range edge case；PR evidence 和 `bash checks/run.sh` 摘要由本 issue handoff 提供。 |
| `MTP-26` | `TVM-ORDER-BOOK-IMBALANCE-PARITY` | 已回填 Core parity / bias evidence fixture、snapshot / delta input source、DuckDB projection evidence、research-only 边界和 `bash checks/run.sh` validation 摘要。 |
| `MTP-27` | `TVM-FEES-SLIPPAGE` | 已回填 fees / slippage fixed assumptions、deterministic fixture、最小计算边界、Backtest / Paper cost parity、禁止项和 validation 摘要。 |
| `MTP-28` | `TVM-RISK-BLOCKER`、`TVM-PORTFOLIO-EXPOSURE` | risk blocker evidence、portfolio exposure read model、projection / ViewModel tests 和 validation 摘要。 |
| `MTP-29` | `TVM-REPORT-EVIDENCE` | Report / Dashboard 中交易验证 evidence 字段、snapshot tests、read-only boundary 和 validation 摘要。 |
| `MTP-30` | 全部 Matrix ID | 阶段收口时确认每个已实现验证域都有 test / fixture / evidence / PR 链接，并为 Stage Code Audit Report 准备输入。 |

## Automation readiness anchors

以下锚点必须保留，供 `checks/automation-readiness.sh` 做机械检查：

- `TVM-EMA-PARITY`
- `TVM-ORDER-BOOK-IMBALANCE-PARITY`
- `TVM-FEES-SLIPPAGE`
- `TVM-RISK-BLOCKER`
- `TVM-PORTFOLIO-EXPOSURE`
- `TVM-REPORT-EVIDENCE`
- `TVM-FUTURE-ISSUE-BACKFILL`
