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
- Paper execution workflow evidence 汇总到 Report / Dashboard read model，覆盖 workflow replay streams、decision / order / simulated fill / portfolio update ID、chain coverage、Codable deterministic snapshot 和 read-model-only boundary。
- Paper Execution Workflow v1 阶段审计输入材料，覆盖 MTP-38 至 MTP-45 issue / PR evidence、paper execution workflow validation evidence chain、automation readiness evidence、known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
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

## MTP-44 Paper Execution Workflow Report / Dashboard Evidence Validation

MTP-44 的 required validation：

- Report read model 必须汇总 paper execution workflow、paper order lifecycle、simulated fill、replay 和 portfolio projection evidence。
- Workflow evidence 必须从 append-only replay / projection / read model 派生，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue、真实订单或真实成交回报。
- App tests 必须覆盖 `PaperExecutionWorkflowEvidenceSummary`、`ResearchBacktestReportArtifact.paperExecutionWorkflowEvidence`、`ReportViewModel` 汇总字段和 `DashboardShellSnapshot` Report 区域展示。
- Codable snapshot 必须证明 workflow evidence 可稳定编码 / 解码，且 paper execution workflow 不授权 trading execution、Live trading 或 broker action。
- Dashboard smoke 必须继续只输出 read-model-only summary，不新增 order command、risk control command、position management command 或交易执行入口。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-EXECUTION-WORKFLOW`、`TVM-PAPER-SESSION-REPLAY` 和 `TVM-REPORT-EVIDENCE` 必须回填新增 App 类型、snapshot tests、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行，不暴露 SQLite / DuckDB schema、runtime object 或 adapter request。

## MTP-45 Validation Docs / Stage Audit Input Validation

MTP-45 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-45 当前验证摘要，并引用 MTP-38 至 MTP-44 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-45 Paper Execution Workflow 阶段收口说明，并指向 MTP-45 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-paper-execution-workflow-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Paper execution workflow validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-45 输入材料和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

## MTP-47 Paper Workflow Workbench IA / Control Shell Boundary Validation

MTP-47 的 required validation：

- Workbench information architecture 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- App tests 必须覆盖 `PaperWorkflowSessionControl`、`PaperWorkflowObservabilitySection`、`PaperWorkflowForbiddenCapability` 和 `PaperWorkflowWorkbenchInformationArchitecture.deterministicFixture`。
- Tests 必须证明 session-level controls 只允许 `start` / `pause` / `close` / `reset`。
- Tests 必须证明 Workbench 观察面覆盖 session、proposal、risk decision、paper order、simulated fill、portfolio projection、replay freshness、report artifact status 和 event timeline。
- Tests 必须证明 order-level command、非 read-model-only source、提前实现 Command Model、UI controls 或 Event Timeline 会被合同拒绝。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 App 类型、fixture、tests 和 no order-level command 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 Command Model、不实现 UI 控件、不实现 Event Timeline、不触发 Paper / Live 执行。

## MTP-48 Paper Session Local Control Command Model Validation

MTP-48 的 required validation：

- Command Model 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- Core tests 必须覆盖 `PaperSessionLocalControlAction` 的 `start` / `pause` / `close` / `reset`。
- Tests 必须证明 accepted command 只作用于本地 Paper session，`scope == local paper session`、`controlLevel == session`、`executionMode == paper`。
- Tests 必须证明非 session-level command 被拒绝，并记录 `PaperSessionLocalControlRejectedReason`。
- Tests 必须证明 `submit` / `cancel` / `replace`、order-level command、broker action 和非 paper execution mode 被拒绝。
- Codable tests 必须证明 payload 不能恢复 order-level command、真实交易授权、Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单 submit / cancel / replace capability。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 Core 类型、fixture、tests、rejected reason 和 no order-level / no broker action 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 UI 控件、不实现 Event Timeline、不写 event log、不触发 Paper / Live 执行。

## MTP-49 Paper Session Local Control Event Boundary Validation

MTP-49 的 required validation：

- Core tests 必须覆盖 accepted `start` / `pause` / `close` / `reset` command -> `PaperEvent.sessionControlApplied`。
- Tests 必须证明 accepted control facts 固定写入 `.paper` stream，且保持 `paperOnlyBoundaryHeld == true`。
- Tests 必须覆盖 invalid command -> `PaperEvent.sessionControlRejected`，并保留 `PaperSessionLocalControlRejectedReason`。
- Tests 必须证明 `submit` / `cancel` / `replace`、order-level command、broker action 和非 paper execution mode 只能形成 rejection evidence，不生成 order intent、simulated fill、broker action 或真实订单行为。
- Tests 必须证明 `AppendOnlyEventLog` sequence 保持单调 append-only，不允许重排或覆盖既有 facts。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 Core event boundary、event cases、tests 和 no UI / no workflow engine 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 UI 控件、不实现 Event Timeline、不触发 Paper / Live 执行。

## MTP-50 Paper Workflow Observability Read Model / ViewModel Validation

MTP-50 的 required validation：

- App tests 必须覆盖 `PaperWorkflowObservabilityReadModel` 和 `PaperWorkflowObservabilityViewModel` 的 deterministic snapshot。
- Tests 必须验证 session status、proposal IDs、allowed decision / order / simulated fill evidence、blocked risk evidence、portfolio projection evidence、replay freshness 和 report artifact status 字段完整。
- Tests 必须验证 ViewModel 可 Codable encode / decode，并保持 deterministic equality。
- Tests 必须验证 `readModelOnlyBoundaryHeld`、`paperOnlyBoundaryHeld` 为 true。
- Tests 必须验证不暴露 database schema、runtime object、adapter request、order-level command、Live trading、broker action 或 trading execution authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 App read model / ViewModel、tests、snapshot evidence 和 schema non-exposure evidence。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 UI redesign、不实现 Event Timeline explorer、不触发 Paper / Live 执行。

## MTP-51 Paper Workflow Event Timeline / Evidence Explorer Validation

MTP-51 的 required validation：

- App tests 必须覆盖 `PaperWorkflowEvidenceExplorerReadModel` 和 `PaperWorkflowEvidenceExplorerViewModel` 的 deterministic timeline snapshot。
- Tests 必须验证 market event、strategy signal、risk decision、paper order、simulated fill、portfolio projection 和 report artifact section coverage。
- Tests 必须验证 evidence links 覆盖 report artifact、risk blocker、execution decision、paper order、simulated fill 和 portfolio projection evidence。
- Tests 必须验证 read-only filter snapshot 和 section snapshot 只在 ViewModel 内筛选，不提供 query language 或 command surface。
- Tests 必须验证 ViewModel 可 Codable encode / decode，并保持 deterministic equality。
- Tests 必须验证 `readModelOnlyBoundaryHeld` 为 true。
- Tests 必须验证不暴露 database schema、runtime object、adapter request、Persistence adapter direct read、order-level command、Live trading、broker action 或 trading execution authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 App Event Timeline / Evidence Explorer read model / ViewModel、tests、snapshot evidence 和 no command / no schema evidence。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 UI redesign、不实现 operations console、不实现完整 query language、不触发 Paper / Live 执行。

## MTP-52 Dashboard / Workbench Shell Validation

MTP-52 的 required validation：

- App tests 必须覆盖 `DashboardShellWorkbenchSnapshot` 绑定 session-level controls、observability metrics / details 和 Event Timeline / Evidence Explorer preview。
- Tests 必须验证 `DashboardShellControlSnapshot` 只映射 `start` / `pause` / `close` / `reset`，scope 固定为 local paper session，control level 固定为 session，execution mode 固定为 paper。
- Tests 必须验证 `DashboardShellSnapshot.smokeSummary` 继续包含 `sections=8` 和 `readModelOnly=true`，并新增 `workbenchReadModelOnly=true`、controls 和 timeline item evidence。
- Tests 必须验证 shell source 不导入 Runtime / Adapters，不包含 schema 直连关键词，不包含按钮、文本输入或开关控件。
- Tests 必须验证 Workbench shell 不提供 command surface、order-level command、database schema、runtime object、adapter request、Live trading、broker action 或 trading execution authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填 Dashboard / Workbench shell snapshot、App tests、Dashboard smoke 和 forbidden command evidence。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现完整 UI redesign、不触发 Paper / Live 执行。

## MTP-53 Validation Docs / Stage Audit Input Validation

MTP-53 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-53 当前验证摘要，并引用 MTP-47 至 MTP-52 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-53 Paper Workflow Control Shell 阶段收口说明，并指向 MTP-53 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-paper-workflow-control-shell-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Paper workflow control shell validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-53 输入材料、Dashboard smoke evidence 和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Dashboard smoke 必须继续覆盖 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 timeline item evidence 字段。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不授权下一 Project planning 或 execution。

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

## MTP-54 Binance Market Data Batch / Replay Boundary Validation

MTP-54 的 required validation：

- `BinanceMarketDataBatchReplayBoundary` 必须定义 public read-only、本地 fixture replay 和 required validation 离线可重复边界。
- `BinanceMarketDataBatchReplayContractField` 必须覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- `BinanceMarketDataBatchReplayValidationMode` 必须把 required mock transport / fixture parity / local batch replay 与 optional manual Binance public network smoke 分开。
- Tests 必须验证 required validation 不依赖真实 Binance 网络。
- Tests 必须验证 contract 明确 public read-only、fixture / batch replay 和 local replay operations evidence。
- Tests 必须验证 signed endpoint、account endpoint、listenKey、broker action、真实订单和 production runtime operations 被禁止。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-54 boundary fixture、tests、contract docs 和 public read-only / no signed endpoint / no broker action validation anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现真实历史下载器，不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-55 Market Data Replay Metadata / Batch Replay Contract Validation

MTP-55 的 required validation：

- `BinanceMarketDataReplayOperationsMetadata` 必须覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- `BinanceMarketDataBatchReplayContract` 必须把 metadata 绑定到 `BinanceMarketDataBatchReplayBoundary`，并证明 required fields、required validation mode、optional validation mode 和 forbidden capability 未漂移。
- `BinanceMarketDataReplayOperationsFixture` 必须提供 deterministic metadata / contract evidence，且 Codable round-trip 后保持 equality。
- Tests 必须验证 required validation 只依赖 mock transport / fixture parity / local batch replay，不依赖真实 Binance 网络。
- Tests 必须验证 metadata field values 不包含 signed endpoint、account endpoint、listenKey、broker、real order 或 production runtime operations 字段。
- Tests 必须验证非法 metadata 被拒绝，例如负数 record count、空 checksum / parity hint 或不完整 boundary contract。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-55 metadata value model、batch replay contract、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现真实历史下载器、production scheduler、retention engine、freshness read model、event / projection consistency、UI evidence、Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-56 Market Data Replay Retention / Freshness Evidence Validation

MTP-56 的 required validation：

- `BinanceMarketDataReplayRetentionPolicy` 必须表达最小本地 retention policy，并 deterministic 计算 fresh、stale、expired 和 not retained。
- `BinanceMarketDataReplayFreshnessEvidenceReadModel` 必须从 `BinanceMarketDataBatchReplayContract` 派生，覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count、checksum / parity hint、policy id、retention window、batch age 和 freshness status。
- `BinanceMarketDataReplayBatchFreshnessSummary` 必须聚合多个 batch freshness evidence，输出 fresh / stale / expired / not retained / retained batch ids 和稳定 summary line。
- Tests 必须验证 freshness read model 不暴露 SQLite / DuckDB schema、adapter request、runtime object、storage tiering、cloud archive、production deletion job 或 command surface。
- Tests 必须验证 freshness evidence 保持 public read-only、local fixture replay、required validation local-only，并拒绝非本地 replay contract。
- Tests 必须验证 freshness evidence 不包含 signed endpoint、account endpoint、listenKey、broker、real order、Live trading 或 production runtime operations 字段。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-56 retention policy、freshness read model、batch freshness summary、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现生产 retention engine、真实数据清理任务、云端 archive、storage tiering、event / projection consistency、UI evidence、Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-57 Market Data Replay Fixture Parity / Replay Consistency Validation

MTP-57 的 required validation：

- `BinanceMarketDataBatchReplayConsistencyEvidence` 必须从 `BinanceMarketDataBatchReplayContract` 和本地 replayed `MarketBar` records 派生，不读取真实 Binance 网络、不写 event log、不触发 projection。
- `BinanceMarketDataBatchReplayDeterministicParity` 必须生成 deterministic replay output summary 和 checksum / parity hint，并验证 metadata checksum / parity hint 与 replay output 一致。
- Tests 必须覆盖 fixture parity、metadata record count consistency、symbol / interval / time window consistency、record ordering、checksum / parity hint drift 和 Codable deterministic equality。
- Tests 必须验证 required validation 仍只依赖 mock transport / fixture parity / local batch replay，真实 Binance network smoke 只能作为 optional manual evidence。
- Tests 必须验证 consistency evidence 不触碰 signed endpoint、account endpoint、listenKey、broker action、Live trading、真实订单或 production runtime operations。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-57 replay consistency evidence、deterministic parity helper、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现真实历史下载器、production operations、event log / projection consistency、Dashboard UI、Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-58 Market Data Replay Event Log / Projection Consistency Validation

MTP-58 的 required validation：

- `MarketDataReplayProjectionConsistency` 必须把 MTP-55 metadata、MTP-56 freshness evidence、MTP-57 replay consistency evidence 和 append-only event log facts 对齐。
- `MarketDataReplayEventLogConsistencyEvidence` 必须验证 `.market` stream sequence、replay result sequence、metadata record count 和 event log record count 一致。
- `MarketDataReplayProjectionSnapshotConsistencySummary` 必须验证 replay output summary、event log summary、cache snapshot summary 和 DuckDB analytical projection summary 一致。
- Tests 必须验证 market-only replay 不在 SQLite runtime projection 中产生 Paper / Risk / Portfolio 状态。
- Tests 必须验证 summary 可 Codable encode / decode，并保持 deterministic equality。
- Tests 必须验证 summary 不暴露 SQLite / DuckDB schema、SQL、ORM、Runtime object、adapter request 或 persistence implementation。
- Tests 必须验证 schema / runtime source drift、event log drift 和 projection snapshot drift 会被拒绝。
- Tests 必须验证 consistency evidence 不触碰 signed endpoint、account endpoint、listenKey、broker action、Live trading、真实订单或 production runtime operations。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-58 Runtime 类型、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现完整 schema、不实现 migration framework、不实现 production data pipeline、不实现 Dashboard UI、Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-59 Market Data Replay Report / Dashboard / Event Timeline Evidence Validation

MTP-59 的 required validation：

- `MarketDataReplayOperationsEvidenceReadModel` 必须只复制已验证 replay operations summary 字段，不读取 SQLite / DuckDB schema，不调用 Runtime object 或 adapter request。
- `MarketDataReplayOperationsEvidenceViewModel` 必须展示 batch id、replay run id、freshness status、retention status、event log record count、replayed record count 和 projection consistency summary。
- `ReportViewModel` 必须汇总 replay operations evidence count、batch ids、replay run ids、freshness / retention status 和 read-model-only boundary。
- `PaperWorkflowEvidenceExplorerViewModel` 必须新增 `market data replay operation` timeline item，并保持 filter / section snapshot 只读。
- `DashboardShellSnapshot` 必须展示 replay ops 指标和 details，Dashboard smoke 继续保持八个主 sections、readModelOnly=true 和 workbenchReadModelOnly=true。
- Tests 必须覆盖 Report / Dashboard / Event Timeline replay operations evidence、Codable deterministic snapshot、read-model-only boundary、schema / runtime / adapter non-exposure、无 command surface 和无 Live / broker / real order authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-59 App read model / ViewModel、Dashboard shell、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现完整 UI redesign、不实现 production operations console、不实现 Runtime command、不实现 Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-60 Validation Docs / Stage Audit Input Validation

MTP-60 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-60 当前验证摘要，并引用 MTP-54 至 MTP-59 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-60 Market Data Replay Operations 阶段收口说明，并指向 MTP-60 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-market-data-replay-operations-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Market data replay operations validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-60 输入材料、Dashboard smoke evidence 和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Dashboard smoke 必须继续覆盖 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 `timelineItems=0` evidence 字段。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不授权下一 Project planning 或 execution。

## MTP-61 Live Trading Foundation Taxonomy / Gate Validation

MTP-61 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须存在，并包含 `MTP-61-LIVE-FOUNDATION-TAXONOMY`、`MTP-61-LIVE-GATE-SEQUENCE` 和 `MTP-61-LIVE-SLICE-SEPARATION` 锚点。
- Taxonomy 必须定义 `live capability`、`blocked capability`、`future gate` 和 `forbidden capability`，并明确它们当前都是 non-executable boundary / blocked evidence，不代表可调用能力。
- Gate sequence 必须保持 Gate 0 至 Gate 6 的顺序：taxonomy / blocked boundary -> API key / signed / account / listenKey boundary -> adapter capability isolation -> real order lifecycle terms -> Live readiness blocked read model -> Workbench blocked evidence surface -> Stage validation closeout。
- MTP-61 必须明确 Live trading foundation 与实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制的分界；后四类仍为 future slices。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-TRADING-FOUNDATION`，并回填 MTP-61 contract docs、domain terms、validation anchor 和 automation readiness anchor。
- `checks/automation-readiness.sh` 必须检查 MTP-61 contract / matrix / validation anchors，避免后续 issue 在缺失 foundation taxonomy 时继续施工。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、真实订单、OMS、`LiveExecutionAdapter`、live command 或交易按钮。

## MTP-62 API Key / Signed / Account / ListenKey Boundary Validation

MTP-62 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY`、`MTP-62-LIVE-CREDENTIAL-FUTURE-GATES` 和 `MTP-62-PUBLIC-READ-ONLY-SEPARATION` 锚点。
- `Sources/Core/LiveTradingBoundary.swift` 必须定义 `LiveTradingCredentialEndpointBoundary`、`LiveTradingCredentialEndpointCapability`、`LiveTradingCredentialEndpointFutureGate` 和 `LiveTradingCredentialEndpointEvidenceKind`。
- `LiveTradingCredentialEndpointBoundary` 必须把 API key、secret storage、request signature、signed endpoint、account endpoint、listenKey user data stream 和 real account payload 固定为 forbidden capability。
- `LiveTradingCredentialEndpointBoundary` 的 `readsAPIKey`、`storesSecret`、`signsRequests`、`callsSignedEndpoint`、`callsAccountEndpoint`、`createsListenKey`、`consumesRealAccountPayload`、`upgradesPublicReadOnlyAdapter` 和 `requiredValidationDependsOnNetwork` 必须全部为 `false`。
- `Tests/CoreTests/CoreTests.swift` 必须覆盖 deterministic fixture、Codable round trip、forbidden capability flag bypass rejection 和 forbidden capability list drift rejection。
- `Tests/AdaptersTests/AdaptersTests.swift` 必须验证 `BinanceReadOnlyAdapterBoundary` 继续禁止 API key、signed endpoint、account endpoint 和 listenKey user data stream，并且 `BinancePublicMarketDataClient` 在 transport 前拒绝 keyed / signature / account / listenKey contract。
- `docs/validation/trading-validation-matrix.md` 必须在 `TVM-LIVE-TRADING-FOUNDATION` 回填 MTP-62 Core contract、Adapters rejection tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker adapter、真实订单、OMS、`LiveExecutionAdapter`、live command 或交易按钮。

## MTP-63 Adapter Capability Isolation Validation

MTP-63 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-63-ADAPTER-CAPABILITY-ISOLATION`、`MTP-63-LIVE-ADAPTER-FUTURE-GATES`、`MTP-63-BROKER-EXCHANGE-FUTURE-ONLY` 和 `MTP-63-LIVEEXECUTIONADAPTER-NON-IMPLEMENTATION` 锚点。
- `LiveAdapterCapabilityIsolationBoundary` 必须固定 Gate 2 adapter capability isolation，并证明 current `Binance public market data` adapter 只保留 exchangeInfo、klines、recent trades、best bid / ask、depth snapshot 和 depth delta public read-only capabilities。
- Core tests 必须覆盖 `LiveAdapterCapabilityIsolationBoundary` deterministic fixture、Codable round trip、`LiveExecutionAdapter` non-implementation flag、broker / exchange execution adapter instantiation rejection、execution venue rejection 和 submit / cancel / replace bypass rejection。
- Adapters tests 必须覆盖 `BinanceReadOnlyAdapterBoundary` 仍只暴露 public market data allowed capabilities，且 forbidden capabilities 包含 `LiveExecutionAdapter`、broker execution adapter、exchange execution adapter、execution venue connection、real order lifecycle 和 OMS。
- `BinancePublicMarketDataClient` 必须在 transport 前拒绝 broker、LiveExecutionAdapter、submit、cancel 和 replace 执行语义片段；验证不得依赖真实 Binance 网络。
- `checks/automation-readiness.sh` 必须检查 MTP-63 contract / matrix / validation anchors，并拒绝 `Sources/` 或 `Tests/` 中新增 `LiveExecutionAdapter` public type declaration。
- `docs/validation/trading-validation-matrix.md` 必须在 `TVM-LIVE-TRADING-FOUNDATION` 回填 MTP-63 Core contract、Adapters rejection tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 future live adapter，不实现 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`，不连接 execution venue，不提交 / 撤销 / 替换真实订单。

## MTP-64 Real Order Lifecycle Terminology / Future Gate Validation

MTP-64 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY`、`MTP-64-REAL-ORDER-LIFECYCLE-FUTURE-GATES`、`MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION` 和 `MTP-64-FORBIDDEN-CAPABILITY-TESTS` 锚点。
- `Sources/Core/LiveTradingBoundary.swift` 必须定义 `RealOrderLifecycleBoundary`、`RealOrderLifecycleTerm`、`RealOrderLifecycleFutureGate`、`RealOrderLifecycleForbiddenCapability` 和 `RealOrderLifecycleEvidenceKind`。
- `RealOrderLifecycleBoundary` 必须固定 Gate 3 real order lifecycle terms，并证明 submit、cancel、replace、execution report、broker fill、reconciliation、OMS、real account state、broker position sync 和 paper evidence upgrade flags 全部为 `false`。
- Core tests 必须覆盖 `RealOrderLifecycleBoundary` deterministic fixture、Codable round trip、forbidden capability flag bypass rejection、terminology drift rejection，以及 `PaperOrderIntent` / `PaperSimulatedFillEvidence` / `PaperPortfolioProjectionUpdate` 不可升级为 real order lifecycle。
- Adapters tests 必须覆盖 `BinanceReadOnlyAdapterBoundary` 继续禁止 execution report、broker fill、order reconciliation、real account state 和 broker position sync，并且 `BinancePublicMarketDataClient` 在 transport 前拒绝 execution report、broker fill、reconciliation 和 OMS 语义片段。
- `checks/automation-readiness.sh` 必须检查 MTP-64 contract / matrix / validation anchors，并拒绝 `Sources/` 或 `Tests/` 中新增 `RealOrderStateMachine` public type declaration。
- `docs/validation/trading-validation-matrix.md` 必须在 `TVM-LIVE-TRADING-FOUNDATION` 回填 MTP-64 Core contract、Adapters rejection tests、paper / real lifecycle isolation tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 real order state machine，不实现 submit / cancel / replace，不实现 execution report、broker fill、reconciliation、OMS、真实账户状态、broker position sync 或真实订单行为。

## MTP-65 LiveReadiness / LiveBlockedEvidence Read Model Validation

MTP-65 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-65-LIVE-READINESS-BLOCKED-READ-MODEL`、`MTP-65-LIVE-BLOCKED-EVIDENCE-GATES`、`MTP-65-READ-MODEL-ONLY-NON-COMMAND` 和 `MTP-65-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE` 锚点。
- `Sources/Core/LiveTradingBoundary.swift` 必须定义 `LiveReadiness`、`LiveReadinessStatus`、`LiveBlockedEvidence`、`LiveBlockedCapability` 和 `LiveBlockedEvidenceKind`。
- `LiveReadiness` 必须固定 Gate 4 live readiness blocked read model，并证明 API key、signed endpoint、account endpoint、listenKey user data stream、broker adapter 和 real order lifecycle evidence 全部为 blocked。
- `LiveReadiness` 和 `LiveBlockedEvidence` 的 read-model-only / no command / no Live authorization / no adapter / no runtime / no SQLite / no DuckDB / no API key / no signed / no account / no listenKey / no broker / no real order lifecycle flags 必须保持 `false` 或只读 blocked 状态。
- Core tests 必须覆盖 `LiveReadiness` deterministic fixture、`LiveBlockedEvidence` deterministic evidence、Codable round trip、blocked capability list drift rejection、command surface rejection、schema / adapter / runtime non-exposure、API key / signed / account / listenKey / broker / real order lifecycle bypass rejection。
- `checks/automation-readiness.sh` 必须检查 MTP-65 contract / matrix / validation anchors、Core type anchors 和 deterministic test anchors。
- `docs/validation/trading-validation-matrix.md` 必须在 `TVM-LIVE-TRADING-FOUNDATION` 回填 MTP-65 Core read model、deterministic tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 live command，不新增交易按钮，不读取 API key，不实现 secret storage、signed endpoint、account endpoint、listenKey、broker adapter、Runtime object exposure、persistence schema exposure、真实订单生命周期或真实交易授权。

## MTP-66 Dashboard / Report / Event Timeline Live Blocked Evidence Validation

日期：2026-05-21

执行者：Codex

MTP-66 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-66-LIVE-BLOCKED-EVIDENCE-SURFACE`、`MTP-66-DASHBOARD-REPORT-EVENT-TIMELINE-READ-MODEL`、`MTP-66-NO-LIVE-COMMAND-OR-BUTTON` 和 `MTP-66-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE` 锚点。
- `Sources/App/LiveTradingBlockedEvidence.swift` 必须定义 `LiveTradingBlockedEvidenceItem`、`LiveTradingBlockedEvidenceReadModel` 和 `LiveTradingBlockedEvidenceViewModel`，且只消费 Core `LiveReadiness` / `LiveBlockedEvidence`。
- `ReportViewModel` 必须展示 Live blocked evidence count、blocked capability labels、gate labels、source anchors、status、all gates blocked 和 read-model-only boundary flags。
- `PaperWorkflowEvidenceExplorerViewModel` 必须新增 `live trading blocked evidence` 分区，并为 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle 各生成只读 timeline item / evidence link。
- `DashboardShellSnapshot` 必须展示 `Live gates` 指标、Live blocked details 和 Dashboard smoke `liveBlockedGates` evidence，同时继续保持八个 Dashboard sections、readModelOnly=true、workbenchReadModelOnly=true 和 session-level controls。
- App tests 必须覆盖 `LiveTradingBlockedEvidenceViewModel` deterministic Codable snapshot、Report / Dashboard / Event Timeline blocked evidence、read-model-only boundary、无 live command、无交易按钮、无真实订单入口、无 adapter / runtime / SQLite / DuckDB schema 暴露。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 live monitoring console、live execution control、live risk control、live audit、live command、交易按钮、API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、Runtime object exposure、persistence schema exposure、真实订单生命周期或真实交易授权。

## MTP-67 Validation Docs / Stage Audit Input Validation

日期：2026-05-21

执行者：Codex

MTP-67 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-67 当前验证摘要，并引用 MTP-61 至 MTP-66 的 Project evidence。
- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-67-LIVE-BOUNDARY-STAGE-CLOSEOUT`、`MTP-67-STAGE-AUDIT-INPUT-MATERIAL` 和 `MTP-67-NO-FINAL-STAGE-CODE-AUDIT` 锚点。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-67 Live Trading Boundary Definition 阶段收口说明，并指向 MTP-67 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-live-trading-boundary-definition-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Live trading boundary validation evidence chain、Automation readiness evidence、Dashboard smoke evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-67 输入材料、Live boundary contract、latest summary、validation plan、matrix、Dashboard smoke evidence 和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Dashboard smoke 必须继续覆盖 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 `liveBlockedGates=6` evidence 字段。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done、Linear Project status `Completed`、`type=completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不授权下一 Project planning 或 execution，不实现任何 Live capability。

## MTP-68 Live Monitoring Console Information Architecture Validation

日期：2026-05-21

执行者：Codex

MTP-68 的 required validation：

- `docs/contracts/live-monitoring-console-contract.md` 必须存在，并包含 `MTP-68-LIVE-MONITORING-CONSOLE-IA`、`MTP-68-LIVE-MONITORING-TERMS`、`MTP-68-LIVE-MONITORING-STATUS-TAXONOMY`、`MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`、`MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`、`MTP-68-LIVE-MONITORING-VALIDATION-ANCHORS` 和 `MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT` 锚点。
- Information architecture 必须覆盖 Overview、Runtime Health、Connection、Market Stream、Order Stream Evidence、Latency、Error / Degraded State 和 Operations Evidence。
- 术语必须定义 live runtime health、connection status、market stream status、order stream evidence、latency evidence、error evidence、degraded state 和 operations evidence。
- Dashboard / Report / Event Timeline 必须保持 read-model-only / ViewModel 边界，不暴露 adapter request、Runtime object、actor、workflow object、SQLite / DuckDB schema、SQL、ORM 或 persistence implementation。
- 订单流 / 订单事件流只能表示 blocked / simulated / future evidence，不得表示 real order state machine、execution report、broker fill、order reconciliation、OMS、真实账户状态或 broker position sync。
- `docs/product/product-surface-map.md`、`docs/contracts/frontend-view-model-contract.md`、`docs/domain/context.md` 和 `docs/validation/trading-validation-matrix.md` 必须能定位 MTP-68 information architecture 和 candidate validation anchor。
- `checks/automation-readiness.sh` 在本 issue 中不得修改；MTP-68 只定义 validation anchor 名称 / 入口，automation readiness 机械收口保留给 MTP-74。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 live runtime、connection runtime、stream collector、latency collector、error handler、operations console、live command、交易按钮、API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、Runtime object exposure、persistence schema exposure、真实订单生命周期或真实交易授权。

## 禁止

- 不接 Binance signed endpoint。
- 不运行 live execution。
- 不把 eval 框架作为业务实现前置依赖。
- 不把 validation result 当作 Linear 执行授权。

## MTP-69 Live Runtime Health / Connection Status Read Model Validation

日期：2026-05-21

执行者：Codex

MTP-69 的 required validation：

- Core 层必须新增 `LiveRuntimeHealthReadModel` 和 `LiveConnectionStatusReadModel`，并保持 Codable / Equatable / Sendable value model。
- `LiveMonitoringStatus` 必须覆盖 `healthy`、`blocked`、`disconnected`、`degraded` 和 `unavailable`。
- Deterministic fixture 默认必须保持 runtime health `blocked`，connection evidence 必须保持 public market data `disconnected`、future private user data `blocked`、future broker session `unavailable`。
- Tests 必须覆盖 deterministic fixture、Codable round trip、connection source anchors、command surface rejection、network connection rejection、secret / account endpoint / listenKey rejection、broker adapter rejection、Runtime object / SQLite / DuckDB schema rejection。
- Focused validation：`swift test --filter MTP69`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 在本 issue 中不得新增 MTP-69 机械收口；MTP-74 统一收口 MTP-68 至 MTP-73 anchors。

## MTP-69 禁止

- 不实现 live runtime。
- 不建立真实网络连接、WebSocket 或 private WebSocket。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker、broker session、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不提供 reconnect、start / stop live command、交易按钮或真实交易授权。

## MTP-70 Market Stream / Order Stream Blocked Evidence Read Model Validation

日期：2026-05-21

执行者：Codex

MTP-70 的 required validation：

- Core 层必须新增 `LiveStreamMonitoringEvidenceReadModel` 和 `LiveStreamMonitoringEvidenceItem`，并保持 Codable / Equatable / Sendable value model。
- Market stream evidence 必须只表达 public read-only / fixture evidence；deterministic fixture 默认保持 public market stream `disconnected`，不得打开 market WebSocket、生产订阅控制、signed endpoint 或 execution venue。
- Order stream evidence 必须固定为 blocked / simulated / future-only 三类：blocked order stream、simulated paper order evidence 和 future order stream gate。
- Simulated order stream 只能引用 paper order / simulated fill evidence，不得升级为 execution report、broker fill、真实账户更新或 real order lifecycle。
- Tests 必须覆盖 deterministic fixture、Codable round trip、source anchors、market stream public read-only boundary、order stream blocked / simulated / future-only boundary、listenKey / account endpoint / broker fill / execution report / real order state machine / order command rejection。
- Focused validation：`swift test --filter MTP70`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 在本 issue 中不得新增 MTP-70 机械收口；MTP-74 统一收口 MTP-68 至 MTP-73 anchors。

## MTP-70 禁止

- 不实现 market streaming runtime 或 production subscription control。
- 不实现 account/order streaming runtime。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker、broker session、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不消费 execution report，不记录 broker fill，不实现 real order state machine、OMS 或 submit / cancel / replace。
- 不提供 order command、live command、交易按钮或真实交易授权。

## MTP-71 Latency / Error / Degraded State Monitoring Evidence Validation

日期：2026-05-21

执行者：Codex

MTP-71 的 required validation：

- Core 层必须新增 `LiveLatencyErrorDegradedMonitoringEvidenceReadModel`、`LiveMonitoringLatencyEvidenceItem`、`LiveMonitoringErrorEvidenceItem` 和 `LiveMonitoringDegradedStateEvidenceItem`，并保持 Codable / Equatable / Sendable value model。
- Latency evidence 必须只表达本地 deterministic bucket / freshness evidence；fixture 覆盖 runtime health `stale`、public market stream `degraded`、simulated order stream `nominal`、future private user data `unavailable` 和 future broker session `unavailable`。
- Error evidence 必须只表达 deterministic error summary；fixture 覆盖 public market stream disconnected、private user data blocked 和 broker session unavailable。
- Degraded / unavailable state evidence 必须只把 latency 和 error evidence 串成只读状态摘要；fixture 覆盖 public market stream `degraded` 和 future broker session `unavailable`。
- Tests 必须覆盖 deterministic fixture、Codable round trip、latency / error / degraded source anchors、production telemetry rejection、external metrics rejection、alert / paging / reconnect / stop control rejection、signed endpoint / account endpoint / listenKey rejection、broker adapter / Runtime object / SQLite / DuckDB schema rejection、no live risk control、no incident command、no auto recovery。
- Focused validation：`swift test --filter MTP71`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 在本 issue 中不得新增 MTP-71 机械收口；MTP-74 统一收口 MTP-68 至 MTP-73 anchors。

## MTP-71 禁止

- 不实现 production telemetry、runtime profiler 或 external metrics service。
- 不实现真实 runtime monitoring、runtime polling 或 production monitor。
- 不建立真实网络连接、WebSocket 或 private user data stream。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker、broker session、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不提供 alerting、paging、reconnect、stop control、incident command、auto recovery、live risk control、live command、交易按钮或真实交易授权。

## MTP-72 Dashboard / Report Live Monitoring Evidence Validation

日期：2026-05-21

执行者：Codex

MTP-72 的 required validation：

- App 层必须新增 `LiveMonitoringEvidenceReadModel` 和 `LiveMonitoringEvidenceViewModel`，并保持 Codable / Equatable / Sendable ViewModel snapshot。
- `ReportReadModel.liveMonitoringEvidence` 和 `ReportViewModel.liveMonitoringEvidence` 必须接入 MTP-69 / MTP-70 / MTP-71 Core evidence。
- Report 必须展示 runtime health、connection statuses、stream evidence、latency buckets、error codes、degraded state 和 read-model-only boundary。
- `DashboardShellSnapshot` 必须在 Report section 展示 `Monitoring` 指标，在 Workbench 展示 `Live Monitoring` 只读组，并在 Dashboard smoke 中记录 `liveMonitoringHealth=blocked` 和 `liveMonitoringErrors=3`。
- Tests 必须验证 Dashboard / Report 只消费 ViewModel / Read Model，且不暴露 adapter、Runtime object、SQLite / DuckDB schema。
- Tests 必须验证无 live command、无交易按钮、无 order-level command、无 risk command、无 position command、无 alert / paging / reconnect / stop control、无 incident command、无自动恢复、无 production telemetry、无 external metrics service、无真实网络连接。
- Tests 必须验证无 signed endpoint、account endpoint、listenKey、API key、secret、account payload、broker adapter、`LiveExecutionAdapter`、real order state machine 或真实交易授权。
- Focused validation：`swift test --filter AppTests`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 的 MTP-68 至 MTP-73 机械收口仍保留给 MTP-74；MTP-72 只回填 Dashboard / Report evidence 和本地验证证据。

## MTP-72 禁止

- 不新增交易按钮。
- 不新增 live command。
- 不做完整实盘监控台页面重设计。
- 不读取 adapter、Runtime object、SQLite / DuckDB schema。
- 不连接真实外部系统。
- 不实现 execution control、risk control、stop control、alerting、paging、reconnect、incident command 或自动恢复。

## MTP-73 Event Timeline Live Monitoring Evidence Preview Validation

日期：2026-05-21

执行者：Codex

MTP-73 的 required validation：

- App 层必须新增 `PaperWorkflowEvidenceExplorerSection.liveMonitoringEvidence`，并保持 Event Timeline / Evidence Explorer 为 read-model-only ViewModel snapshot。
- `PaperWorkflowEvidenceExplorerReadModel.liveMonitoringEvidence` 必须默认从 `ReportReadModel.liveMonitoringEvidence` 派生，也允许 deterministic tests 显式注入同形 read model。
- `PaperWorkflowEvidenceExplorerViewModel` 必须设置 `coversLiveMonitoringEvidence == true`，并把 live monitoring evidence 分区纳入 `sectionSnapshots` 和 `filterSnapshot`。
- Live monitoring evidence 分区必须生成 18 条 timeline item：runtime health 1 条、connection 3 条、stream 4 条、latency 5 条、error 3 条、degraded state 2 条。
- Full dashboard fixture 必须保持 `timelineItems=42`；empty dashboard snapshot 必须保持 `timelineItems=24`；Dashboard smoke 必须继续输出 `liveBlockedGates=6`、`liveMonitoringHealth=blocked` 和 `liveMonitoringErrors=3`。
- Tests 必须验证 no command surface、no order-level command、no query language、no live audit、no incident replay、no stop control、no broker action、no Live trading authorization 和 no trading execution。
- Focused validation：`swift test --filter AppTests/testLiveMonitoringEvidenceExplorerPreviewDefinesMTP73ReadOnlyTimelineItems`。
- Required validation：`swift test --filter AppTests` 和 `bash checks/run.sh`。
- `checks/automation-readiness.sh` 的 MTP-68 至 MTP-73 机械收口仍保留给 MTP-74；MTP-73 只回填 Event Timeline preview evidence 和本地验证证据。

## MTP-73 禁止

- 不新增 live command、交易按钮、表单、order-level command、risk command 或 position command。
- 不实现 live audit、incident replay、stop control、alert / paging / reconnect、incident command 或自动恢复。
- 不实现 production telemetry、runtime profiler、external metrics service、真实 runtime monitoring、真实网络连接或 WebSocket。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker、broker session、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不消费 execution report，不记录 broker fill，不实现 real order state machine、OMS 或 submit / cancel / replace。

## MTP-74 Validation Docs / Stage Audit Input Validation

日期：2026-05-21

执行者：Codex

MTP-74 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-74 当前验证摘要，并引用 MTP-68 至 MTP-73 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-MONITORING-CONSOLE` 的 MTP-74 阶段收口说明，并指向 MTP-74 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-live-monitoring-console-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Live monitoring validation evidence chain、Dashboard smoke、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须机械检查 MTP-68 至 MTP-74 的 contract、matrix、validation plan、latest summary、source / test anchors、Dashboard smoke evidence 和 stage audit input material。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done 且 Linear Project `Completed`、`type=completed`、`completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

MTP-74 必须收口的主要 anchors：

- `MTP-74-LIVE-MONITORING-STAGE-CLOSEOUT`
- `MTP-74-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-74-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-74-LIVE-MONITORING-STAGE-AUDIT-INPUT`
- `MTP-74-LIVE-MONITORING-VALIDATION-EVIDENCE-CHAIN`
- `MTP-74-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-74 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project 或下一 Project issues。
- 不推进下一 Project / Issue。
- 不把 planning notes 当执行授权。
- 不启动下一阶段 `symphony-issue`。
- 不写业务功能扩展。
- 不实现任何 Live trading、execution control、risk control、live audit、incident replay 或 stop control capability。
- 不接 signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、real order state machine 或真实订单行为。

## MTP-75 Live Execution Control Terminology / Taxonomy Validation

日期：2026-05-22

执行者：Codex

MTP-75 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须存在，并包含 `MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY`、`MTP-75-REAL-ORDER-COMMAND-TAXONOMY`、`MTP-75-PAPER-REAL-COMMAND-ISOLATION`、`MTP-75-NO-EXECUTABLE-COMMAND-SURFACE` 和 `MTP-75-LIVE-EXECUTION-CONTROL-VALIDATION` 锚点。
- `Sources/Core/LiveExecutionControlContract.swift` 必须定义 `LiveExecutionControlTerm`、`FutureRealOrderCommandTaxonomyTerm`、`LiveExecutionControlFutureGate`、`LiveExecutionControlForbiddenCapability`、`LiveExecutionControlEvidenceKind` 和 `LiveExecutionControlTerminologyBoundary`。
- `LiveExecutionControlTerminologyBoundary` 必须固定 execution-control terminology、real order command taxonomy、future gates、forbidden capability baseline、validation anchors 和 paper / real command isolation anchors。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、taxonomy drift rejection、command surface rejection、submit / cancel / replace / execution report / reconciliation / `LiveExecutionAdapter` / real order state machine / OMS bypass rejection，以及 `PaperOrderIntent` / `PaperExecutionDecision` / `PaperSimulatedFillEvidence` 不可升级为 real order command。
- `docs/validation/trading-validation-matrix.md` 必须新增 `TVM-LIVE-EXECUTION-CONTROL` candidate entry，并回填 MTP-75 Core contract、deterministic tests、contract docs 和 validation-plan anchor。
- MTP-75 只定义 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report、broker fill、reconciliation、incident fallback automation、live command、order-level command UI、order form 或交易按钮。

MTP-75 必须建立的主要 anchors：

- `TVM-LIVE-EXECUTION-CONTROL`
- `MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY`
- `MTP-75-REAL-ORDER-COMMAND-TAXONOMY`
- `MTP-75-PAPER-REAL-COMMAND-ISOLATION`
- `MTP-75-NO-EXECUTABLE-COMMAND-SURFACE`
- `MTP-75-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-75 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不实现 broker fill、execution report、reconciliation。
- 不实现 incident fallback automation、stop control、live audit 或 live risk。
- 不新增交易按钮、order form、live command 或 order-level command UI。
- 不把 paper order intent、paper execution decision 或 simulated fill 升级为 future real order command。

## MTP-76 Submit / Cancel / Replace Future Gates Validation

日期：2026-05-22

执行者：Codex

MTP-76 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES`、`MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS`、`MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE`、`MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE` 和 `MTP-76-LIVE-EXECUTION-CONTROL-VALIDATION` anchors。
- `Sources/Core/LiveExecutionControlContract.swift` 必须定义 `LiveSubmitCancelReplaceFutureGate`、`LiveSubmitCancelReplaceForbiddenCapability` 和 `LiveSubmitCancelReplaceCommandBoundary`。
- `LiveSubmitCancelReplaceCommandBoundary` 必须固定 submit / cancel / replace command taxonomy subset、future gates、forbidden capability list、validation anchors、source anchors 和 paper intent isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、command taxonomy drift rejection、真实 submit / cancel / replace rejection、signed submit / cancel / replace request rejection、broker / `LiveExecutionAdapter` / real order state machine / OMS / order form / trading button bypass rejection，以及 `PaperOrderIntent` / `PaperExecutionDecision` / `PaperSimulatedFillEvidence` 不可升级为 real submit / cancel / replace。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-76 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-76 只定义 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report、broker fill、reconciliation、incident fallback automation、live command、order-level command UI、order form 或交易按钮。

MTP-76 必须建立的主要 anchors：

- `MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES`
- `MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS`
- `MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE`
- `MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE`
- `MTP-76-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-76 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed submit / cancel / replace request。
- 不实现 broker submit / cancel / replace action。
- 不新增交易按钮、order form、live command 或 order-level command UI。
- 不把 paper order intent、paper execution decision 或 simulated fill 升级为 real submit / cancel / replace。

## MTP-77 Execution Report / Broker Fill / Reconciliation Future Gates Validation

日期：2026-05-22

执行者：Codex

MTP-77 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES`、`MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS`、`MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT`、`MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY` 和 `MTP-77-LIVE-EXECUTION-CONTROL-VALIDATION` anchors。
- `Sources/Core/LiveExecutionControlContract.swift` 必须定义 `LiveExecutionReportBrokerFillReconciliationFutureGate`、`LiveExecutionReportBrokerFillReconciliationForbiddenCapability` 和 `LiveExecutionReportBrokerFillReconciliationBoundary`。
- `LiveExecutionReportBrokerFillReconciliationBoundary` 必须固定 execution report / broker fill / reconciliation terms、future gates、forbidden capability list、validation anchors、source anchors、blocked evidence flags 和 simulated fill / paper portfolio isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、terms drift rejection、execution report consumption / parser / ingestion rejection、broker fill recorder / event fact rejection、reconciliation runtime rejection、real account balance read rejection、broker position sync rejection、broker / `LiveExecutionAdapter` bypass rejection，以及 `PaperSimulatedFillEvidence` / `PaperPortfolioProjectionUpdate` 不可升级为 broker fill、execution report、real account 或 broker position。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-77 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-77 只定义 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report parser、execution report ingestion、broker fill recorder、broker fill event fact、reconciliation service、account sync、real account balance read、broker position sync、live command、order-level command UI、order form 或交易按钮。

MTP-77 必须建立的主要 anchors：

- `MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES`
- `MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS`
- `MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT`
- `MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY`
- `MTP-77-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-77 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不新增交易按钮、order form、live command 或 order-level command UI。
- 不把 simulated fill 升级为 broker fill 或 execution report。
- 不把 paper portfolio projection 升级为 broker position 或 real account state。

## MTP-78 Paper / Real Command Isolation Contract Validation

日期：2026-05-22

执行者：Codex

MTP-78 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT`、`MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`、`MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY`、`MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY` 和 `MTP-78-LIVE-EXECUTION-CONTROL-VALIDATION` anchors。
- `Sources/Core/LiveExecutionControlContract.swift` 必须定义 `LivePaperRealCommandIsolationEvidenceSource`、`LivePaperRealCommandIsolationForbiddenCapability` 和 `LivePaperRealCommandIsolationBoundary`。
- `LivePaperRealCommandIsolationBoundary` 必须固定 paper order intent、paper execution decision、simulated fill evidence、paper portfolio projection、Report read model、Dashboard ViewModel 和 Event Timeline read model 的隔离证据来源。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、evidence source drift rejection、paper order intent / paper execution decision / simulated fill / paper portfolio projection upgrade rejection、real command / submit / execution report / broker fill / reconciliation bypass rejection，以及 paper-only fixture 不可升级为 future real order command。
- App tests 必须覆盖 `ReportViewModel`、`DashboardShellSnapshot` 和 `PaperWorkflowEvidenceExplorerViewModel` 仍只消费 read model / ViewModel，并且没有 command surface、order-level command、order form、trading button、broker action 或真实交易授权。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-78 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-78 只定义 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、account sync、real account balance read、broker position sync、live command、order-level command UI、order form 或交易按钮。

MTP-78 必须建立的主要 anchors：

- `MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT`
- `MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`
- `MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY`
- `MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY`
- `MTP-78-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-78 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed command request。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不新增交易按钮、order form、live command 或 order-level command UI。
- 不把 paper order intent、paper execution decision、simulated fill 或 paper portfolio projection 升级为 real order command、execution report、broker fill、broker position 或 real account state。

## MTP-79 Live Execution Control Blocked Evidence Validation

日期：2026-05-22

执行者：Codex

MTP-79 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`、`MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS`、`MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`、`MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-79-LIVE-EXECUTION-CONTROL-VALIDATION` anchors。
- `Sources/Core/LiveExecutionControlContract.swift` 必须定义 `LiveExecutionControlBlockedGate`、`LiveExecutionControlBlockedReason`、`LiveExecutionControlBlockedEvidenceItem` 和 `LiveExecutionControlBlockedEvidence`。
- `LiveExecutionControlBlockedEvidence` 必须固定 submit / cancel / replace / execution report / broker fill / reconciliation / incident fallback 的 blocked reason、source anchors、validation anchors 和 deterministic snapshot。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、blocked item drift rejection、schema / adapter / runtime / command bypass rejection、真实订单 / execution report / broker fill / reconciliation / incident fallback bypass rejection，以及 MTP-76 / MTP-77 / MTP-78 boundary regression。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-79 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-79 只定义 read-model-only blocked evidence 和 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation、account sync、real account balance read、broker position sync、live command、order-level command UI、order form 或交易按钮。

MTP-79 必须建立的主要 anchors：

- `MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`
- `MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS`
- `MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`
- `MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-79-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-79 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed command request。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不实现 incident fallback automation 或 incident command。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter 或 runtime control。
- 不新增交易按钮、order form、live command 或 order-level command UI。

## MTP-80 Dashboard / Report / Event Timeline Execution-Control Blocked Evidence Validation

日期：2026-05-22

执行者：Codex

MTP-80 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-80-DASHBOARD-REPORT-TIMELINE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`、`MTP-80-EXECUTION-CONTROL-READ-MODEL-ONLY-SURFACE`、`MTP-80-NO-LIVE-COMMAND-OR-ORDER-FORM` 和 `MTP-80-LIVE-EXECUTION-CONTROL-DASHBOARD-REPORT-TIMELINE-VALIDATION` anchors。
- `Sources/App/LiveExecutionControlBlockedEvidence.swift` 必须把 MTP-79 Core blocked evidence 复制成 App 层 read model / ViewModel，不读取 secret、schema、adapter 或 Runtime object。
- `ReportViewModel` 必须展示 execution-control blocked gate count、blocked gate labels、blocked reason labels、source anchors、deterministic snapshot、all-gates-blocked evidence 和 read-model-only boundary flags。
- `DashboardShellSnapshot` 必须展示 `Execution control` report metric、`liveExecutionControlGates=7` smoke evidence 和 `Live Execution Control` workbench detail group。
- `PaperWorkflowEvidenceExplorerViewModel` 必须新增 `live execution control blocked evidence` section，为 submit、cancel、replace、execution report、broker fill、reconciliation 和 incident fallback 生成只读 timeline item / evidence link。
- App tests 必须覆盖 MTP-80 ViewModel deterministic snapshot、Event Timeline preview、Dashboard Shell Report / Workbench binding、Codable round trip，以及 MTP-78 read-model-only regression。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-80 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-80 只接入 Dashboard / Report / Event Timeline 展示面，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation、account sync、real account balance read、broker position sync、live command、order-level command UI、order form 或交易按钮。

MTP-80 必须建立的主要 anchors：

- `MTP-80-DASHBOARD-REPORT-TIMELINE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`
- `MTP-80-EXECUTION-CONTROL-READ-MODEL-ONLY-SURFACE`
- `MTP-80-NO-LIVE-COMMAND-OR-ORDER-FORM`
- `MTP-80-LIVE-EXECUTION-CONTROL-DASHBOARD-REPORT-TIMELINE-VALIDATION`

## MTP-80 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed command request。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不实现 incident fallback automation 或 incident command。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter 或 runtime control。
- 不新增交易按钮、order form、live command 或 order-level command UI。

## MTP-81 Validation Docs / Stage Audit Input Validation

日期：2026-05-22

执行者：Codex

MTP-81 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-81 当前验证摘要，并引用 MTP-75 至 MTP-80 的 Project evidence。
- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-81-LIVE-EXECUTION-CONTROL-STAGE-CLOSEOUT`、`MTP-81-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-81-NO-FINAL-STAGE-CODE-AUDIT` 和 `MTP-81-LIVE-EXECUTION-CONTROL-VALIDATION-EVIDENCE-CHAIN` anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-81 Live Execution Control Contract 阶段收口说明，并指向 MTP-81 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-live-execution-control-contract-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Live execution control validation evidence chain、Dashboard smoke、Forbidden capability evidence、Read-model-only boundary evidence、Automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须机械检查 MTP-75 至 MTP-81 的 contract、matrix、validation plan、latest summary、source / test anchors、Dashboard smoke evidence 和 stage audit input material。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done 且 Linear Project `Completed`、`type=completed`、`completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

MTP-81 必须收口的主要 anchors：

- `MTP-81-LIVE-EXECUTION-CONTROL-STAGE-CLOSEOUT`
- `MTP-81-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-81-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-81-LIVE-EXECUTION-CONTROL-STAGE-AUDIT-INPUT`
- `MTP-81-LIVE-EXECUTION-CONTROL-VALIDATION-EVIDENCE-CHAIN`
- `MTP-81-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-81 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project 或下一 Project issues。
- 不推进下一 Project / Issue。
- 不把 planning notes 当执行授权。
- 不启动下一阶段 `symphony-issue`。
- 不写业务功能扩展。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed command request。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不实现 incident fallback automation 或 incident command。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter 或 runtime control。
- 不新增交易按钮、order form、live command 或 order-level command UI。

## MTP-82 Live Risk Terminology / Future Risk Decision Taxonomy Validation

日期：2026-05-22

执行者：Codex

MTP-82 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-82-LIVE-RISK-TERMINOLOGY`、`MTP-82-FUTURE-RISK-DECISION-TAXONOMY`、`MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`、`MTP-82-NO-LIVE-RISK-RUNTIME` 和 `MTP-82-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/Core/LiveRiskGateContract.swift` 必须定义 `LiveRiskTerm`、`FutureRiskDecisionTaxonomyTerm`、`LiveRiskGateFutureGate`、`LiveRiskForbiddenCapability`、`LiveRiskEvidenceKind` 和 `LiveRiskTerminologyBoundary`。
- `LiveRiskTerminologyBoundary` 必须固定 live pre-trade risk terminology、future risk decision taxonomy、future gates、forbidden capability list、validation anchors 和 paper / live risk isolation source anchors。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、taxonomy drift rejection、真实账户 / broker position / margin / leverage 读取 rejection、real pre-trade allow / reject runtime rejection、signed endpoint / `LiveExecutionAdapter` bypass rejection、risk command / trading button rejection，以及 `RiskBlockerEvidence` / `PortfolioExposureSnapshot` 不可升级为 future live risk decision、real account state 或 broker position。
- `docs/validation/trading-validation-matrix.md` 必须新增 `TVM-LIVE-RISK-GATE` candidate entry，并把 MTP-82 回填到该 entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-82 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real pre-trade risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade state runtime、live command、risk command、position management command、order form 或交易按钮。

MTP-82 必须建立的主要 anchors：

- `MTP-82-LIVE-RISK-TERMINOLOGY`
- `MTP-82-FUTURE-RISK-DECISION-TAXONOMY`
- `MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`
- `MTP-82-NO-LIVE-RISK-RUNTIME`
- `MTP-82-LIVE-RISK-GATE-VALIDATION`

## MTP-82 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 circuit breaker runtime 或 no-trade state runtime。
- 不新增 live command、risk command、position management command、order form 或交易按钮。
- 不把 paper risk blocker、paper exposure、paper execution decision 或 simulated fill 升级为 future live risk decision、real account state、broker position 或 live risk input。

## MTP-83 Exposure / Order Notional Gates Validation

日期：2026-05-22

执行者：Codex

MTP-83 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`、`MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS`、`MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT`、`MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE` 和 `MTP-83-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/Core/LiveRiskGateContract.swift` 必须定义 `LiveExposureOrderNotionalFutureGate`、`LiveExposureOrderNotionalForbiddenCapability` 和 `LiveExposureOrderNotionalGateBoundary`。
- `LiveExposureOrderNotionalGateBoundary` 必须固定 exposure / order notional future gates、forbidden capability list、validation anchors、source anchors 和 paper exposure isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、terms drift rejection、真实账户余额 / broker position / margin / leverage 读取 rejection、real account exposure calculation rejection、real order notional limit evaluation rejection、real pre-trade allow / reject runtime rejection、account endpoint decode bypass rejection，以及 `PortfolioExposureSnapshot` 不可升级为 future live exposure gate、real account state 或 broker position。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-83 回填到 `TVM-LIVE-RISK-GATE` candidate entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-83 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real account exposure calculation、real order notional allow / reject runtime、real pre-trade risk engine、live command、risk command、position management command、order form 或交易按钮。

MTP-83 必须建立的主要 anchors：

- `MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`
- `MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS`
- `MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT`
- `MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE`
- `MTP-83-LIVE-RISK-GATE-VALIDATION`

## MTP-83 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不计算真实账户 exposure。
- 不执行真实订单 notional allow / reject。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不新增 live command、risk command、position management command、order form 或交易按钮。
- 不把 paper exposure 或 paper risk blocker 升级为 future live exposure gate、future live risk decision、real account state、broker position、margin 或 leverage。
