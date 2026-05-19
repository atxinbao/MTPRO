# Validation Plan

本文档定义 MTPRO 当前验证计划。

## 统一入口

```bash
bash checks/run.sh
```

该命令必须串联：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- macOS 本地：`swift build --product Dashboard`
- macOS 本地：`DASHBOARD_SMOKE=1 swift run Dashboard`
- Linux CI：跳过 macOS-only SwiftUI shell build / smoke，并继续运行 SwiftPM tests
- `swift test`

## 当前覆盖

当前测试覆盖：

- Swift-only core。
- paper-only execution mode。
- TradingKernel actor boundary。
- MessageBus monotonic event stream。
- DataEngine read-only market event ingest。
- Cache deterministic replay projection。
- Binance public read-only contract 和 fixture decoding。
- Binance public read-only client boundary、mock transport、fixture parity 和 public stream path 断言。
- EMA cross strategy contract。
- Backtest / Paper signal timeline parity。
- Order book imbalance research contract。
- Event Log replay persistence boundary。
- File-backed append-only event log persistence boundary。
- SQLite runtime projection boundary。
- SQLite runtime projection adapter 最小 rebuild / query snapshot 闭环。
- DuckDB analytical projection boundary。
- DuckDB analytical projection adapter 最小 rebuild / query snapshot 闭环。
- Runtime market data ingest -> event log -> replay -> projection snapshots 端到端链路。
- Trader Workstation Dashboard ViewModel contract。
- Trader Workstation Dashboard macOS shell、ViewModel snapshot binding 和 smoke run。
- Research -> Backtest -> Report 最小路径、report artifact / read model 和 Dashboard Report 快照。
- Paper Session lifecycle started / updated / closed facts、paper-only event log 写入边界和 deterministic fixture。
- Paper action proposal 最小模型、long / flat signal 映射、deterministic sizing fixture、fixed cost evidence 复用和 paper-only 不可执行边界。
- Paper action proposal -> risk blocker 本地链路、allowed / blocked deterministic evidence、source sequence、paper-only context 和无 broker / Live fallback 边界。
- Paper-only portfolio projection update path、allowed risk decision -> portfolio update、blocked decision 拒绝、SQLite runtime projection replay 和 read-only ViewModel。
- Paper Session replay evidence summary、append-only facts source、proposal event replay fact、SQLite runtime projection replay、乱序 replay 拒绝和 paper-only boundary flags。
- Paper Session runtime evidence 汇总到 Report / Dashboard read model，覆盖 lifecycle、proposal、risk blocker、portfolio update、portfolio exposure、replay facts、deterministic replay 和 paper-only boundary flags。
- Paper-only execution workflow contract 和事件边界，覆盖 proposal、risk decision、paper execution decision、paper order、simulated fill、portfolio projection 的 stage order、event stream、future issue 占位和 capability 禁区。
- Paper order intent / lifecycle 最小模型，覆盖 allowed / blocked risk result 到 `intentCreated` / `rejectedByRisk` 的 deterministic 映射、paper-only capability flags 和 Codable 禁区。
- Simulated fill evidence 最小模型，覆盖 allowed paper order intent -> deterministic simulated fill evidence、fixed fee / slippage cost evidence、source sequence、paper-only capability flags 和 Codable 禁区。
- Paper execution decision 本地链路，覆盖 allowed risk decision -> paper order intent -> simulated fill evidence、blocked risk decision 不生成 paper order、source sequence、paper-only capability flags 和 Codable 禁区。
- Paper execution event log / replay / projection 串联，覆盖 decision -> order -> simulated fill `.paper` facts、replay deterministic summary、从 replayed simulated fill evidence 更新 portfolio projection，以及无 broker / signed endpoint / account data 边界。
- Paper Session Runtime v1 阶段审计输入材料，覆盖 MTP-31 至 MTP-37 issue / PR evidence、paper runtime validation evidence chain、automation readiness evidence、known boundaries 和 Root Docs Delta input。
- GitHub workflow / PR evidence / WIP=1 / handoff marker / Graphify 边界。
- Linear issue execution contract。
- `.codex/*` 与 `graphify-out/*` 本地输出排除契约。

## Finance / Trading Validation

策略、market data、Backtest、Paper、risk 或 portfolio 相关 issue 必须补充交易语义验证：

- 策略假设。
- market data 时间粒度和 symbol universe。
- fees / slippage 是否进入当前 scope。
- Backtest / Paper parity 验收方式。
- risk metric 或 risk blocker。
- 不触碰 Live trading、signed endpoint 和真实 broker action。

当前继续使用 XCTest + fixtures 表达交易语义验证，不引入独立 eval 框架。

交易验证矩阵入口：`docs/validation/trading-validation-matrix.md`。

该矩阵记录 EMA parity、order book imbalance parity、fees / slippage、risk blocker、portfolio exposure 和 report evidence 的现有 coverage、验收证据边界和后续 issue 回填规则。

## Stage Audit Input Location Rule

`docs/validation/` 只保留长期验证入口，例如 latest summary、validation plan、trading validation matrix、eval strategy 和 macOS build / run loop。

Project 级阶段证据和 Stage Code Audit 输入材料必须放在：

```text
docs/audit/inputs/
```

命名规则：

- 使用 Project slug，不使用单个 Linear issue 编号作为文件名主体。
- stage evidence 命名为 `<linear-project-slug>-stage-evidence.md`。
- stage audit input 命名为 `<linear-project-slug>-stage-audit-input.md`。

示例：

- `docs/audit/inputs/mtpro-runtime-research-workbench-v1-stage-evidence.md`
- `docs/audit/inputs/mtpro-trading-validation-and-parity-hardening-stage-audit-input.md`
- `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md`

这些输入材料不替代最终 Stage Code Audit Report。最终 Project 级审计报告仍必须落到：

```text
docs/audit/<linear-project-slug>-stage-code-audit.md
```

`docs/audit/inputs/` 中的文件不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不启动下一阶段 `symphony-issue`。

## MTP-24 Trading Validation Matrix Validation

MTP-24 的 required validation：

- `docs/validation/trading-validation-matrix.md` 必须存在。
- Matrix 必须包含 EMA parity、order book imbalance parity、fees / slippage、risk blocker、portfolio exposure、report evidence 和 future issue backfill 的稳定锚点。
- Matrix 必须记录现有 XCTest / fixture coverage 入口。
- Matrix 必须明确 MTP-25 至 MTP-30 如何回填 evidence。
- `checks/automation-readiness.sh` 必须在 matrix 文件或 required anchors 缺失时失败。

## MTP-25 EMA Backtest / Paper Parity Validation

MTP-25 的 required validation：

- EMA Backtest / Paper parity 必须使用 deterministic fixture，不依赖真实 Binance 网络。
- 测试必须覆盖同一 `EMACrossStrategyConfiguration`、同一 `MarketDataQuery`、同一 symbol、同一 timeframe。
- 测试必须锁定 long EMA warm-up 后的首个 signal timestamp、完整 signal direction timeline 和 Backtest / Paper signalSamples 等价。
- Backtest / Paper event flow 必须拒绝超出 `MarketDataQuery.range` 的 bars，避免使用查询窗口外数据生成 parity 假阳性。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-EMA-PARITY` 必须回填新增测试、edge case 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不接 signed endpoint、broker action 或真实订单行为。

## MTP-26 Order Book Imbalance Parity Validation

MTP-26 的 required validation：

- `OrderBookImbalanceSignalSample` 必须记录 snapshot / delta input source，作为 bias evidence 的一部分。
- Core deterministic tests 必须覆盖 bidDominant、neutral、askDominant、depth、bid / ask notional、imbalance ratio、source timestamp、signal direction 和 input source。
- Core parity evidence 必须比较直接 `OrderBookImbalanceStrategyContract` 与 `OrderBookImbalanceResearchEventFlow` 的 signal samples。
- ask dominance 必须保持 research-only：bias 可为 `askDominant`，signal direction 必须仍为 `.flat`，不得引入 short、margin、futures leverage 或真实订单动作。
- Persistence / DuckDB analytical projection 必须保留 order book input source，且仍只输出稳定 read model snapshot，不暴露 schema 或 adapter internals。
- required validation 不依赖真实 Binance 网络、不读取 secret、不连接 broker、不触发真实交易行为。

## MTP-27 Fees / Slippage Validation

MTP-27 的 required validation：

- fees / slippage assumptions 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker 或交易所账户等级。
- Core 测试必须覆盖 maker fee、taker fee、fixed slippage、gross notional、total cost 和统一 rounding scale。
- Backtest / Paper cost evidence 必须在同一 assumption、同一 symbol / timeframe、同一 reference price、同一 quantity 和同一 liquidity role 下保持一致。
- 无效 assumptions 必须被拒绝，包括负数 bps、非有限 bps 或超出允许范围的 rounding scale。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-FEES-SLIPPAGE` 必须回填新增 Core 类型、测试、fixture 和 PR evidence 边界。
- required validation 不引入完整费用模型、不引入交易所费率表、不引入动态滑点模型、不做执行成本优化、不触发 Paper / Live 执行。

## MTP-28 Risk Blocker / Portfolio Exposure Validation

MTP-28 的 required validation：

- risk blocker evidence 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 proposed Paper action context、risk profile、blocker reason、paper-only execution mode 和 Live / broker / signed endpoint 不可回退边界。
- SQLite runtime projection 必须保留 risk blocker evidence、source sequence、projected timestamp 和 rejected paper order ID 派生入口。
- portfolio exposure read model 必须只来自 Paper projection，覆盖 portfolio ID、symbol、timeframe、paper quantity、reference price、gross exposure notional、source sequence 和 read-only ViewModel。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RISK-BLOCKER` 和 `TVM-PORTFOLIO-EXPOSURE` 必须回填新增 Core / Persistence / App 测试、fixture 和 PR evidence 边界。
- required validation 不引入完整风险引擎、不引入实时风控、不引入仓位管理、保证金、杠杆、真实账户余额、broker balance 或 Live execution。

## MTP-29 Report / Dashboard Trading Validation Evidence Validation

MTP-29 的 required validation：

- Report read model 必须汇总 projection-level parity、fees / slippage cost evidence、risk blocker evidence 和 portfolio exposure evidence。
- fees / slippage evidence 必须从 MTP-27 deterministic fixture 和 paper-only portfolio exposure projection 派生，不依赖真实 Binance 网络、secret、broker、account endpoint 或交易所账户等级。
- Report / Dashboard snapshot 必须展示 execution cost evidence count、assumption IDs、cost parity consistency、risk blocker evidence IDs、portfolio exposure symbols 和 gross exposure notional。
- App tests 必须覆盖 trading validation evidence summary 的 Codable / deterministic snapshot、read-model-only 来源、schema leakage 禁区和 research-only execution authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-REPORT-EVIDENCE` 必须回填新增 App 类型、snapshot tests、fixture 和 PR evidence 边界。
- required validation 不新增完整报表系统、不新增交易所费率表、不新增动态滑点模型、不新增执行成本优化、不触发 Paper / Live 执行。

## MTP-30 Stage Audit Input Validation

MTP-30 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-30 当前验证摘要，并引用 MTP-24 至 MTP-29 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-30 阶段收口说明，并指向 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-trading-validation-and-parity-hardening-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Trading validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-30 输入材料和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在 `MTP-24` 至 `MTP-30` 全部 Done 后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

## MTP-31 Paper Session Lifecycle Validation

MTP-31 的 required validation：

- Paper session lifecycle 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 `sessionStarted`、`sessionUpdated`、`sessionClosed` 三类 lifecycle facts。
- Core 测试必须固定 startedAt、updatedAt、closedAt、event log recordedAt 和 stream replay 结果。
- event log 写入边界必须只接受 `PaperEvent` 并固定写入 `.paper` stream。
- `PaperSessionUpdated.signalCount` 必须非负，并只代表本地 signal timeline 数量。
- Persistence / App 只能把 lifecycle facts 投影为稳定 read model state，不得新增交易执行入口。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-SESSION-LIFECYCLE` 必须回填新增 Core 类型、测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-32 Paper Action Proposal Validation

MTP-32 的 required validation：

- Paper action proposal 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 `StrategySignalEvent` 到 proposal side 的映射：`long -> buy`，`flat -> hold`。
- Core 测试必须覆盖 symbol、timeframe、quantity、reference price、notional 和 MTP-27 fixed cost evidence 复用。
- Core 测试必须证明 proposal 固定 `executionMode == paper`、`executionAuthorization == paperIntentOnly` 且 `isExecutableAsRealOrder == false`。
- Codable 解码必须拒绝非 paper mode 或与 signal 不一致的 side，避免绕过 proposal 不变量。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-ACTION-PROPOSAL` 必须回填新增 Core 类型、测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-33 Paper Action Proposal -> Risk Blocker Validation

MTP-33 的 required validation：

- Paper action risk link 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 allowed paper proposal evidence：proposal、risk query、risk profile、source sequence、paper-only context 和无 broker / Live fallback。
- Core 测试必须覆盖 blocked paper proposal evidence：blocker reason、`RiskBlockerEvidence`、source sequence、paper-only execution mode 和无 broker / Live fallback。
- Codable 解码必须拒绝 allowed decision 携带 blocker evidence，且 source sequence 必须为正数。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RISK-BLOCKER` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-34 Paper-only Portfolio Projection Update Validation

MTP-34 的 required validation：

- Paper-only portfolio update 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 replayed paper-only simulated fill evidence 生成 `PaperPortfolioProjectionUpdate` 和 `PortfolioEvent.paperProjectionUpdated`；MTP-42 后不再允许直接由 risk decision 更新 portfolio projection。
- Core 测试必须覆盖 Codable 解码不能绕过 simulated fill evidence 来源，也不能恢复交易授权、真实账户余额读取或 broker position sync。
- Persistence 测试必须覆盖 replay envelope 驱动 SQLite runtime projection update，并保留 simulated fill event source sequence。
- App 测试必须覆盖 Portfolio ViewModel 只消费 read model projection，不直连 database schema、runtime object、adapter、broker 或交易动作。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PORTFOLIO-EXPOSURE` 必须回填新增 Core / Persistence / App 测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-35 Paper Session Replay Evidence Validation

MTP-35 的 required validation：

- Paper Session replay 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- Core 测试必须覆盖 `PaperEvent.actionProposed`、`PaperSessionReplayEvidenceSummary` 和 `PaperSessionReplayPath.summarize`。
- Replay summary 必须覆盖 session lifecycle events、proposal events、risk blocker events 和 portfolio projection events。
- Replay summary 必须固定 replayed sequences、streams、session IDs、proposal IDs、risk blocker evidence IDs、portfolio update IDs 和 paper-only boundary flags。
- 测试必须证明乱序 replay result 被拒绝，避免非 append-only 顺序输入被标记为 deterministic evidence。
- Persistence 测试必须证明 `FileEventLogStore` append-only facts source 经 replay 后生成同一 deterministic summary，并可驱动 SQLite runtime projection。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-SESSION-REPLAY` 必须回填新增 Core / Persistence 测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-36 Paper Session Runtime Evidence Report / Dashboard Validation

MTP-36 的 required validation：

- Report read model 必须汇总 Paper Session lifecycle、proposal、risk blocker、portfolio exposure 和 replay evidence。
- Runtime evidence 必须使用 MTP-35 deterministic replay fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- App tests 必须覆盖 `PaperSessionRuntimeEvidenceSummary`、`ResearchBacktestReportArtifact.paperRuntimeEvidence`、`ReportViewModel` 汇总字段和 `DashboardShellSnapshot` Report 区域展示。
- Codable snapshot 必须证明 runtime evidence 可稳定编码 / 解码，且 `paperRuntimeAuthorizesTradingExecution`、`paperRuntimeAuthorizesLiveTrading`、`paperRuntimeTouchesBrokerAction` 保持 false。
- Dashboard smoke 必须继续只输出 read-model-only summary，不新增按钮、表单、risk control command、position management command 或交易执行入口。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-REPORT-EVIDENCE` 和 `TVM-PAPER-SESSION-REPLAY` 必须回填新增 App 类型、snapshot tests、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-37 Validation Docs / Stage Audit Input Validation

MTP-37 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-37 当前验证摘要，并引用 MTP-31 至 MTP-36 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-37 Paper Session Runtime 阶段收口说明，并指向 MTP-37 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Paper runtime validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-37 输入材料和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在 `MTP-31` 至 `MTP-37` 全部 Done 后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

## MTP-38 Paper-only Execution Workflow Contract Validation

MTP-38 的 required validation：

- Paper-only execution workflow contract 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 `PaperExecutionWorkflowStage`、`PaperExecutionWorkflowStageBoundary`、`PaperExecutionWorkflowContract.deterministicFixture` 和 stage order。
- Contract 必须明确 proposal、risk decision、paper execution decision、paper order、simulated fill 和 portfolio projection 的关系。
- Event boundary 必须固定 `.paper` / `.risk` / `.portfolio` stream 归属，并记录未来 issue 只能在合同内补充本地 paper-only evidence。
- Codable snapshot 必须拒绝 `authorizesTradingExecution`、Live trading、signed endpoint、broker action 或 real order capability 绕过。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-EXECUTION-WORKFLOW` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 simulated fill、完整 OMS 或真实交易行为。

## MTP-39 Paper Order Intent / Lifecycle Validation

MTP-39 的 required validation：

- Paper order intent / lifecycle 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- Core 测试必须覆盖 `PaperOrderLifecycleState`、`PaperOrderIntent` 和 `PaperOrderIntentFixture`。
- Tests 必须覆盖 allowed risk decision -> `intentCreated`、blocked risk decision -> `rejectedByRisk`，并锁定 blocker evidence ID、source risk decision sequence、symbol、timeframe、quantity、reference price 和 notional。
- Tests 必须证明 paper order intent 固定 `executionMode == paper`、`proposalAuthorization == paperIntentOnly`、`workflowStage == paperOrder`、`eventStream == .paper` 和 `evidenceKind == paperOrder`。
- Codable snapshot 必须拒绝非 paper mode、risk result / lifecycle 不一致、trading authorization、Live trading、signed endpoint、broker action、real order 或 simulated fill capability 绕过。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-ORDER-LIFECYCLE` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 paper execution decision、simulated fill、完整 OMS、cancel / replace 或真实交易行为。

## MTP-40 Simulated Fill Evidence Validation

MTP-40 的 required validation：

- Simulated fill evidence 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue、真实订单或真实成交回报。
- Core 测试必须覆盖 `PaperSimulatedFillAssumption`、`PaperSimulatedFillEvidence` 和 `PaperSimulatedFillFixture`。
- Tests 必须覆盖 allowed paper order intent -> simulated fill evidence，并锁定 fill ID、order ID、proposal ID、risk decision ID、source order intent sequence、source risk decision sequence、symbol、timeframe、filled quantity、fill price、gross notional 和 filledAt。
- Tests 必须证明 fixed cost evidence 复用 MTP-27 deterministic assumptions，并锁定 fee / slippage / total cost。
- Tests 必须证明 risk-rejected order intent 不得生成 simulated fill。
- Codable snapshot 必须拒绝非 paper mode、real fill、broker fill、account update、trading authorization、Live trading、signed endpoint、broker action 或 real order capability 绕过。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-SIMULATED-FILL` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 paper execution decision、event log 写入、replay、portfolio projection、完整 OMS、动态滑点、交易所费率表或真实交易行为。

## MTP-41 Paper Execution Decision Validation

MTP-41 的 required validation：

- Paper execution decision 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue、真实订单或真实成交回报。
- Core 测试必须覆盖 `PaperExecutionDecisionStatus`、`PaperExecutionDecision`、`PaperExecutionDecisionLink` 和 `PaperExecutionDecisionFixture`。
- Tests 必须覆盖 allowed risk decision -> paper execution decision -> paper order intent -> simulated fill evidence，并锁定 proposal ID、risk decision ID、order ID、fill ID、source risk decision sequence、source order intent sequence、symbol、timeframe、quantity、reference price 和 decidedAt。
- Tests 必须覆盖 blocked risk decision 不生成 paper order intent、simulated fill assumption 或 simulated fill evidence。
- Codable snapshot 必须拒绝 status mismatch、blocked order bypass、trading authorization、Live trading、signed endpoint、broker action、real order、real fill、broker fill 或 account update capability 绕过。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-EXECUTION-DECISION` 和 `TVM-PAPER-EXECUTION-WORKFLOW` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不写 event log、不新增 replay / projection / ViewModel、不实现完整 execution engine、完整风险引擎、broker rejection fallback 或真实交易行为。

## MTP-42 Paper Execution Event Replay Projection Validation

MTP-42 的 required validation：

- Paper execution event log / replay / projection 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue、真实订单或真实成交回报。
- Core 测试必须覆盖 `PaperExecutionEventLogBoundary` 按 decision -> order intent -> simulated fill 写入 `.paper` stream，并校验 source order sequence。
- Core 测试必须覆盖乱序或 source sequence mismatch 被拒绝，避免不可追溯 fill evidence 进入 replay。
- Core / Persistence 测试必须覆盖 replay 后的 `simulatedFillRecorded` fact 才能生成 `PaperPortfolioProjectionUpdate`；portfolio projection 不得直接从 risk decision、broker fill、account update 或真实账户状态派生。
- Replay summary 必须覆盖 execution decision IDs、paper order IDs、simulated fill IDs、portfolio update IDs 和 paper-only boundary flags。
- SQLite runtime projection 必须继续只消费 replay envelope / portfolio projection fact，并输出稳定 snapshot，不暴露 schema。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-EXECUTION-WORKFLOW`、`TVM-PAPER-SESSION-REPLAY` 和 `TVM-PORTFOLIO-EXPOSURE` 必须回填新增 Core / Persistence / App 测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现生产级 event sourcing、schema migration framework、FileEventLogStore 重写、broker event replay 或真实交易行为。

## Codex / Automation Validation

- Codex use-cases 对齐：`docs/automation/codex-use-cases-alignment.md`。
- Verified operations：`docs/automation/verified-operations.md`。
- Eval 引入策略：`docs/validation/eval-strategy.md`。
- macOS build / run / telemetry 闭环：`docs/validation/macos-build-run-loop.md`。

新增或修改 production code 时，验证前必须检查详细中文注释是否覆盖业务目的、输入输出、领域不变量、外部系统边界和交易能力禁区。

## 后续验证方向

后续按 Linear issue 增加：

- market data replay tests。
- EMA cross backtest tests。
- paper / backtest parity tests。
- risk decision tests。
- persistence projection rebuild tests。
- file event log corruption / recovery tests。
- UI ViewModel snapshot tests。
- macOS App shell build / run / telemetry tests。

## MTP-20 Binance Client Validation

MTP-20 的 required validation：

- 使用 mock transport 覆盖 REST public endpoint request。
- 使用 mock transport 覆盖 public depth stream request path。
- 使用 fixture parity 验证 client decode 结果与 `BinancePublicMarketDataPayloadDecoder` 一致。
- 断言 transport request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- 断言 mutable 或 `requiresAPIKey == true` 的 request contract 在 transport 前被拒绝。
- 断言非 public market data allowlist 的 Binance path 在 transport 前被拒绝。
- required validation 不依赖真实 Binance 网络；真实网络 smoke test 只能作为可选人工证据。

## MTP-21 Runtime Ingest Validation

MTP-21 的 required validation：

- 使用 mock transport 覆盖 Binance public REST / public depth stream request。
- 使用 fixture parity 验证 workflow ingest events 与 `BinancePublicMarketDataPayloadDecoder` 输出一致。
- 验证 event log sequence 从 1 开始连续递增。
- 验证 replay result 与写入 envelopes 一致，且 market cache projection deterministic。
- 验证 DuckDB analytical snapshot 来自 replay，并包含 market bars、trades、best bid / ask、order book snapshot 和 delta。
- 验证 SQLite runtime snapshot 在 market-only ingest 下保持稳定空 snapshot，且仍由 replay 驱动。
- 断言 request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- required validation 不依赖真实 Binance 网络；真实网络 smoke test 只能作为可选人工证据。

## MTP-22 macOS Dashboard Shell Validation

MTP-22 的 required validation：

- 使用 SwiftUI shell 绑定 `DashboardViewModel` snapshot。
- 验证 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 七个只读区域都来自 ViewModel / Read Model。
- 验证 shell source 不导入 Runtime / Adapters，也不直接引用数据库实现名或 public market data client 类型。
- 验证 `swift build --product Dashboard` 可构建 macOS 看板入口。
- 验证 `DASHBOARD_SMOKE=1 swift run Dashboard` 可输出 read-model-only smoke summary 并退出。
- 验证 Linux CI 可通过非 SwiftUI fallback 编译 App target、executable target 和 AppTests；真实 SwiftUI shell 只在 macOS 本地构建。
- required validation 不接真实网络、不读取 secret、不连接 broker、不触发真实交易行为。

## MTP-23 Research -> Backtest -> Report Validation

MTP-23 的 required validation：

- 验证 `ReportReadModel` 只能从 projection snapshots / read model 和 append-only event timeline 生成。
- 验证 report artifact 绑定 backtest run、research run、Paper session、event count 和 last applied sequence。
- 验证 projection-level Backtest / Paper parity evidence 保持一致，同时不替代 Core 层完整时间线 parity 测试。
- 验证 Dashboard shell 呈现 Report 快照，且 shell 不导入 Runtime / Adapters、不引用数据库实现名、不调用行情 adapter。
- 验证缺失 Paper projection 时报告标记为 missing paper projection，不回退到 Live、broker、signed endpoint 或真实订单路径。
- 验证 Issue 8 只准备阶段证据材料；Stage Code Audit Report 仍须在 Project 全部 Done 后由父 Codex 单独输出。
- required validation 不接真实网络、不读取 secret、不连接 broker、不触发真实交易行为。

## 禁止

- 不接 Binance signed endpoint。
- 不运行 live execution。
- 不把 eval 框架作为业务实现前置依赖。
- 不把 validation result 当作 Linear 执行授权。
