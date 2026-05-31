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

## MTP-84 Frequency / Loss / Drawdown Gates Validation

日期：2026-05-22

执行者：Codex

MTP-84 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES`、`MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS`、`MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT`、`MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE` 和 `MTP-84-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/Core/LiveRiskGateContract.swift` 必须定义 `LiveFrequencyLossDrawdownFutureGate`、`LiveFrequencyLossDrawdownForbiddenCapability` 和 `LiveFrequencyLossDrawdownGateBoundary`。
- `LiveFrequencyLossDrawdownGateBoundary` 必须固定 frequency / loss / drawdown future gates、forbidden capability list、validation anchors、source anchors、frequency runtime flags、loss / drawdown runtime flags 和 paper risk / exposure isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、terms drift rejection、真实下单频率计数 rejection、production frequency throttling rejection、真实 PnL / equity 读取 rejection、real loss / drawdown limit evaluation rejection、drawdown circuit breaker rejection、stop / emergency command rejection，以及 `RiskBlockerEvidence` / `PortfolioExposureSnapshot` 不可升级为 future live frequency / loss / drawdown gate、真实 PnL / equity 或 pre-trade runtime。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-84 回填到 `TVM-LIVE-RISK-GATE` candidate entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-84 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real PnL read、real account equity read、live order frequency counter、production frequency throttling、real loss / drawdown allow / reject runtime、drawdown circuit breaker runtime、circuit breaker command、stop trading command、emergency stop command、live command、risk command、position management command、order form 或交易按钮。

MTP-84 必须建立的主要 anchors：

- `MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES`
- `MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS`
- `MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT`
- `MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE`
- `MTP-84-LIVE-RISK-GATE-VALIDATION`

## MTP-84 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不读取真实 PnL 或真实账户权益。
- 不统计真实下单频率。
- 不执行生产限频或 broker-side throttling。
- 不执行真实亏损阈值或回撤阈值 allow / reject。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 drawdown circuit breaker runtime。
- 不实现 circuit breaker command、stop trading command 或 emergency stop command。
- 不新增 live command、risk command、position management command、order form 或交易按钮。
- 不把 paper risk blocker 或 paper exposure 升级为 future frequency / loss / drawdown gate、future live risk decision、real PnL、real account equity 或 pre-trade runtime。

## MTP-85 Circuit Breaker / No-Trade State Gates Validation

日期：2026-05-22

执行者：Codex

MTP-85 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`、`MTP-85-FORBIDDEN-CIRCUIT-BREAKER-NO-TRADE-RUNTIME-TESTS`、`MTP-85-NO-CIRCUIT-BREAKER-OR-NO-TRADE-STATE-RUNTIME`、`MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE` 和 `MTP-85-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/Core/LiveRiskGateContract.swift` 必须定义 `LiveCircuitBreakerNoTradeFutureGate`、`LiveCircuitBreakerNoTradeForbiddenCapability` 和 `LiveCircuitBreakerNoTradeGateBoundary`。
- `LiveCircuitBreakerNoTradeGateBoundary` 必须固定 circuit breaker / no-trade state future gates、forbidden capability list、validation anchors、source anchors、circuit breaker runtime flags、no-trade state runtime flags、operations command flags 和 paper risk / exposure isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、terms drift rejection、circuit breaker runtime rejection、no-trade state runtime rejection、global trading lock rejection、broker session state mutation rejection、stop / emergency / recovery / production shutdown command rejection，以及 `RiskBlockerEvidence` / `PortfolioExposureSnapshot` 不可升级为 future live circuit breaker / no-trade state gate、真实账户状态、真实 PnL / equity 或 pre-trade runtime。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-85 回填到 `TVM-LIVE-RISK-GATE` candidate entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-85 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real PnL read、real account equity read、real loss / drawdown allow / reject runtime、circuit breaker runtime、no-trade state runtime、global trading lock、broker session state mutation、circuit breaker command、stop trading command、emergency stop command、automatic recovery command、production shutdown control、live command、risk command、position management command、order form 或交易按钮。

MTP-85 必须建立的主要 anchors：

- `MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`
- `MTP-85-FORBIDDEN-CIRCUIT-BREAKER-NO-TRADE-RUNTIME-TESTS`
- `MTP-85-NO-CIRCUIT-BREAKER-OR-NO-TRADE-STATE-RUNTIME`
- `MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE`
- `MTP-85-LIVE-RISK-GATE-VALIDATION`

## MTP-85 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不读取真实 PnL 或真实账户权益。
- 不执行真实亏损阈值或回撤阈值 allow / reject。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 circuit breaker runtime。
- 不实现 no-trade state runtime 或 no-trade state transition runtime。
- 不实现 global trading lock 或 broker session state mutation。
- 不实现 circuit breaker command、stop trading command、emergency stop command、automatic recovery command 或 production shutdown control。
- 不提交、撤销、替换真实订单。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 paper risk blocker 或 paper exposure 升级为 future circuit breaker / no-trade state gate、future live risk decision、real PnL、real account equity、真实账户状态或 pre-trade runtime。

## MTP-86 Paper Risk / Future Live Risk Decision Isolation Validation

日期：2026-05-22

执行者：Codex

MTP-86 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT`、`MTP-86-PAPER-RISK-EVIDENCE-NO-FUTURE-LIVE-RISK-DECISION`、`MTP-86-PAPER-EXPOSURE-NO-REAL-ACCOUNT-RISK-INPUT`、`MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY` 和 `MTP-86-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/Core/LiveRiskGateContract.swift` 必须定义 `LivePaperRiskLiveDecisionIsolationEvidenceSource`、`LivePaperRiskLiveDecisionForbiddenCapability` 和 `LivePaperRiskLiveDecisionIsolationBoundary`。
- `LivePaperRiskLiveDecisionIsolationBoundary` 必须固定 paper-only evidence sources、forbidden capability list、validation anchors、source anchors、paper risk / exposure no-upgrade flags、future live risk decision blocked flags 和 read-model-only App surface flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、evidence source drift rejection、paper risk blocker -> future risk decision rejection、paper exposure -> future risk decision rejection、paper risk decision -> real pre-trade allow / reject rejection、paper exposure -> real account exposure rejection、live risk engine rejection、signed endpoint / account endpoint / `LiveExecutionAdapter` rejection、risk command surface rejection，以及 `RiskBlockerEvidence` / `PortfolioExposureSnapshot` 不可升级为 future live risk decision、真实账户风险输入、circuit breaker trigger 或 no-trade state trigger。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-86 回填到 `TVM-LIVE-RISK-GATE` candidate entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-86 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real PnL / equity read、real pre-trade risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade state runtime、live command、risk command、position management command、order form 或交易按钮。

MTP-86 必须建立的主要 anchors：

- `MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT`
- `MTP-86-PAPER-RISK-EVIDENCE-NO-FUTURE-LIVE-RISK-DECISION`
- `MTP-86-PAPER-EXPOSURE-NO-REAL-ACCOUNT-RISK-INPUT`
- `MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY`
- `MTP-86-LIVE-RISK-GATE-VALIDATION`

## MTP-86 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不读取真实 PnL 或真实账户权益。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 circuit breaker runtime。
- 不实现 no-trade state runtime。
- 不提交、撤销、替换真实订单。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 paper risk blocker、paper exposure 或 paper risk decision 升级为 future live risk decision、real account exposure、broker position、real pre-trade allow / reject、circuit breaker trigger、no-trade state trigger 或 live risk runtime input。

## MTP-87 Live Risk Gate Blocked Evidence Surface Validation

日期：2026-05-22

执行者：Codex

MTP-87 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE`、`MTP-87-LIVE-RISK-GATES-BLOCKED-REASONS`、`MTP-87-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`、`MTP-87-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-87-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/Core/LiveRiskGateContract.swift` 必须定义 `LiveRiskGateBlockedGate`、`LiveRiskGateBlockedReason`、`LiveRiskGateBlockedEvidenceItem` 和 `LiveRiskGateBlockedEvidence`。
- `LiveRiskGateBlockedEvidence` 必须固定 exposure、order notional、frequency、loss / drawdown、circuit breaker、no-trade state 的 blocked reason、source anchors、validation anchors、deterministic snapshot、read-model-only App surface flags 和 forbidden live risk runtime flags。
- `Sources/App/LiveRiskGateBlockedEvidence.swift` 必须把 Core fixture 复制成 `LiveRiskGateBlockedEvidenceReadModel` / `LiveRiskGateBlockedEvidenceViewModel`，并只通过 `ReportViewModel`、`DashboardShellSnapshot` 和 `PaperWorkflowEvidenceExplorerViewModel` 进入只读展示面。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、blocked items drift rejection、真实账户 / broker position / allow-reject runtime / circuit breaker runtime / command surface rejection，以及 MTP-83 至 MTP-86 boundary regression。
- App tests 必须覆盖 Dashboard / Report / Event Timeline blocked evidence、ViewModel Codable boundary、`liveRiskGates=6` smoke anchor、无 risk command、无 order form、无交易按钮、无 schema / adapter / Runtime object 暴露。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-87 回填到 `TVM-LIVE-RISK-GATE` candidate entry；MTP-88 仍负责 Project 级 automation readiness 和 stage audit input material 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增真实网络 smoke，不读取真实账户，不实现 live risk runtime。

MTP-87 必须建立的主要 anchors：

- `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE`
- `MTP-87-LIVE-RISK-GATES-BLOCKED-REASONS`
- `MTP-87-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`
- `MTP-87-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-87-LIVE-RISK-GATE-VALIDATION`

## MTP-87 禁止

- 不读取真实账户余额、broker position、margin、leverage、PnL 或 equity。
- 不实现 real pre-trade risk engine、real pre-trade allow / reject runtime、真实 order notional evaluation 或真实 frequency / loss / drawdown runtime。
- 不实现 circuit breaker runtime、no-trade state runtime、broker session state mutation、stop trading command 或 emergency stop command。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不让 UI 消费 database schema、adapter、Runtime object 或 command model。

## MTP-88 Validation Docs / Stage Audit Input Validation

日期：2026-05-22

执行者：Codex

MTP-88 的 required validation：

- `docs/audit/inputs/mtpro-live-risk-gate-contract-v1-stage-audit-input.md` 必须存在，并包含 `MTP-88-LIVE-RISK-GATE-STAGE-AUDIT-INPUT`、Issue / PR evidence input、Live risk gate validation evidence chain、Forbidden capability evidence、Read-model-only boundary evidence、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-88-LIVE-RISK-GATE-STAGE-CLOSEOUT`、`MTP-88-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-88-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-88-LIVE-RISK-GATE-VALIDATION-EVIDENCE-CHAIN` 和 `MTP-88-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-88 Live Risk Gate Contract 阶段收口说明，并指向 MTP-88 Stage Code Audit 输入材料。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-88 只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口，不输出最终 Stage Code Audit Report。
- `checks/automation-readiness.sh` 必须机械检查 MTP-82 至 MTP-88 的 contract、matrix、validation plan、latest summary、stage audit input、Core / App source anchors、Core / App deterministic test anchors 和 Dashboard smoke `liveRiskGates=6`。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在 `MTP-82` 至 `MTP-88` 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现真实 live risk runtime、真实账户读取、broker position sync、margin / leverage / PnL / equity read、circuit breaker command、stop trading command、emergency stop、risk command、order form 或交易按钮。

MTP-88 必须建立的主要 anchors：

- `MTP-88-LIVE-RISK-GATE-STAGE-CLOSEOUT`
- `MTP-88-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-88-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-88-LIVE-RISK-GATE-STAGE-AUDIT-INPUT`
- `MTP-88-LIVE-RISK-GATE-VALIDATION-EVIDENCE-CHAIN`
- `MTP-88-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-88 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不读取 API key、secret、真实账户余额、broker position、margin、leverage、PnL 或 equity。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 real pre-trade risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade state runtime、risk command surface、position management command、order form、交易按钮、stop trading command 或 emergency stop。

## MTP-89 Live Audit Incident Stop Terminology / Taxonomy Validation

日期：2026-05-23

执行者：Codex

MTP-89 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`、`MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`、`MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES`、`MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND`、`MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE` 和 `MTP-89-LIVE-AUDIT-INCIDENT-STOP-VALIDATION` anchors。
- `Sources/Core/LiveAuditIncidentStopContract.swift` 必须只定义 `LiveAuditIncidentStopTerm`、`FutureAuditIncidentStopTaxonomyTerm`、`LiveAuditIncidentStopFutureGate`、`LiveAuditIncidentStopForbiddenCapability`、`LiveAuditIncidentStopEvidenceKind` 和 `LiveAuditIncidentStopTerminologyBoundary`。
- Core deterministic tests 必须覆盖 `testLiveAuditIncidentStopTerminologyDefinesMTP89FutureOnlyTaxonomy`、`testLiveAuditIncidentStopTerminologyRejectsMTP89RuntimeCommandAndConsoleBypass` 和 `testLiveAuditIncidentStopTerminologyKeepsMTP89BlockedEvidenceFutureOnly`。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-AUDIT-INCIDENT-STOP` 和 MTP-89 issue backfill。
- `docs/domain/context.md` 必须包含 Live Audit Incident Stop Terms 和 MTP-89 anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-89 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-89 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、signed endpoint、account endpoint、listenKey、broker action、live command、order form 或交易按钮。

MTP-89 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`
- `MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`
- `MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES`
- `MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND`
- `MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE`
- `MTP-89-LIVE-AUDIT-INCIDENT-STOP-VALIDATION`

## MTP-89 禁止

- 不实现 incident replay runtime。
- 不实现 emergency stop、shutdown、restore 或 stop control runtime。
- 不实现 production operations、alerting / paging、auto recovery 或 broker session mutation。
- 不把 Workbench、Dashboard、Report、Event Timeline 或 Evidence Explorer 描述成当前 Live PRO Console。
- 不接 API key、secret storage、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order state machine、real order submit / cancel / replace、execution report runtime、broker fill runtime 或 reconciliation runtime。
- 不新增 live command、order-level command UI、order form、交易按钮、broker action 或真实交易授权。

## MTP-90 Live Audit Trail Future Gates Validation

日期：2026-05-23

执行者：Codex

MTP-90 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`、`MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS`、`MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION`、`MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE` 和 `MTP-90-LIVE-AUDIT-TRAIL-VALIDATION` anchors。
- `Sources/Core/LiveAuditIncidentStopContract.swift` 必须定义 `LiveAuditTrailSubject`、`LiveAuditTrailFutureGate`、`LiveAuditTrailForbiddenCapability` 和 `LiveAuditTrailFutureGateBoundary`，并保持这些类型只表达 Future / gated audit trail contract。
- Core deterministic tests 必须覆盖 `testMTP90LiveAuditTrailFutureGatesDefineSignalOrderRiskDecisionFillBoundary`、`testMTP90LiveAuditTrailFutureGatesRejectExecutionReportBrokerFillOMSAndBrokerAction` 和 `testMTP90LiveAuditTrailFutureGatesKeepPaperEvidenceFromBecomingRealAuditFact`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-90 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-90 audit trail future gates、forbidden execution report / broker fill / OMS tests、no real order state machine / broker action、paper evidence no real audit fact upgrade 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-90 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-90 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现真实 audit trail runtime、execution report parser / ingestion、broker fill recorder、OMS、real order state machine、broker reconciliation、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、live command、order form 或交易按钮。

MTP-90 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`
- `MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS`
- `MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION`
- `MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE`
- `MTP-90-LIVE-AUDIT-TRAIL-VALIDATION`

## MTP-90 禁止

- 不实现真实 audit trail runtime。
- 不实现 execution report parser / ingestion、execution report runtime 或 broker fill recorder。
- 不记录 broker fill fact，不执行 broker reconciliation。
- 不实现 OMS、real order state machine 或 real order submit / cancel / replace。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不把 strategy signal、`PaperOrderIntent`、`PaperExecutionDecision`、`RiskBlockerEvidence` 或 `PaperSimulatedFillEvidence` 升级为真实 audit fact。
- 不新增 live command、order-level command UI、order form、交易按钮或真实交易授权。

## MTP-91 Incident Replay Future Gates Validation

日期：2026-05-23

执行者：Codex

MTP-91 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-91-INCIDENT-REPLAY-FUTURE-GATES`、`MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES`、`MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES`、`MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS`、`MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY` 和 `MTP-91-INCIDENT-REPLAY-VALIDATION` anchors。
- `Sources/Core/LiveAuditIncidentStopContract.swift` 必须定义 `LiveIncidentReplayFutureGate`、`LiveIncidentReplayForbiddenCapability` 和 `LiveIncidentReplayFutureGateBoundary`，并保持这些类型只表达 Future / gated incident replay contract。
- Core deterministic tests 必须覆盖 `testMTP91IncidentReplayFutureGatesDefineInputScopeEvidenceOutputBoundary`、`testMTP91IncidentReplayFutureGatesRejectRuntimeRecoveryBrokerAndAccountReplay` 和 `testMTP91IncidentReplayFutureGatesKeepCurrentReplayDeterministicEvidenceOnly`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-91 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-91 incident replay future gates、input source gates、scope / evidence / output gates、forbidden recovery / broker / account replay tests、deterministic replay no production recovery 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-91 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-91 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 incident replay runtime、production recovery、auto restore、auto rollback、broker replay、account replay、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、Live PRO Console、live command、order form 或交易按钮。

MTP-91 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-91-INCIDENT-REPLAY-FUTURE-GATES`
- `MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES`
- `MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES`
- `MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS`
- `MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY`
- `MTP-91-INCIDENT-REPLAY-VALIDATION`

## MTP-91 禁止

- 不实现 incident replay runtime。
- 不实现 production recovery、auto restore、auto rollback 或 live runtime resume。
- 不实现 broker replay runtime、account replay runtime、broker state reader 或 real account state reader。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不实现 OMS、real order state machine、execution report ingestion、broker fill fact 或 audit trail runtime。
- 不把当前 `Event Log` / `Replay` 升级为 production incident replay、production recovery、broker replay 或 account replay。
- 不新增 Live PRO Console、live command、order-level command UI、order form、交易按钮或真实交易授权。

## MTP-92 Stop / Shutdown / Restore Future Gates Validation

日期：2026-05-23

执行者：Codex

MTP-92 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES`、`MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS`、`MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE`、`MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN` 和 `MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION` anchors。
- `Sources/Core/LiveAuditIncidentStopContract.swift` 必须包含 `LiveStopShutdownRestoreFutureGate`、`LiveStopShutdownRestoreForbiddenCapability` 和 `LiveStopShutdownRestoreFutureGateBoundary`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-92 focused tests，验证 no emergency stop、no shutdown、no restore command、no live command、no trading button、no broker session mutation、no production operations、no signed endpoint / account endpoint / listenKey / broker action。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-92 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-92 stop / shutdown / restore future gates、forbidden capability tests、risk circuit breaker / no-trade separation、broker session mutation / production shutdown boundary 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-92 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-92 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。

MTP-92 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES`
- `MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS`
- `MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE`
- `MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN`
- `MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION`

## MTP-92 禁止

- 不实现 emergency stop command、shutdown command 或 restore command。
- 不实现 stop control runtime、production shutdown control、production operations runtime、global trading lock 或 broker session mutation。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不实现 OMS、real order state machine、live risk engine、circuit breaker runtime、no-trade state runtime、restore decision runtime 或 live runtime resume。
- 不把 `LiveCircuitBreakerNoTradeGateBoundary`、risk gate blocked evidence、circuit breaker 或 no-trade state 升级为当前 emergency stop、shutdown、restore 或 production shutdown control。
- 不新增 Live PRO Console、live command、order-level command UI、stop button、order form、交易按钮或真实交易授权。

## MTP-93 Blocked Evidence Incident / Stop Isolation Validation

日期：2026-05-23

执行者：Codex

MTP-93 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION`、`MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE`、`MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE`、`MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS` 和 `MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION` anchors。
- `Sources/Core/LiveAuditIncidentStopContract.swift` 必须包含 `LiveBlockedEvidenceIncidentStopIsolationGate`、`LiveBlockedEvidenceIncidentStopForbiddenCapability` 和 `LiveBlockedEvidenceIncidentStopIsolationBoundary`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-93 focused tests，验证 Live execution / risk blocked evidence 不能升级为 incident replay runtime、stop command、shutdown command、restore command、production operation、live command、trading button 或 Live PRO Console。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-93 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-93 blocked evidence isolation、no blocked evidence to incident / stop command upgrade、paper evidence no incident / stop upgrade、forbidden command / runtime tests 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-93 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-93 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 incident command、stop / shutdown / restore command、live risk engine、execution runtime、production operations、Live PRO Console、signed endpoint、account endpoint、listenKey、broker action、live command、order form 或交易按钮。

MTP-93 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION`
- `MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE`
- `MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE`
- `MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS`
- `MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION`

## MTP-93 禁止

- 不把 `LiveExecutionControlBlockedEvidence` 升级为 incident command、stop command、restore decision、execution runtime、live command 或交易按钮。
- 不把 `LiveRiskGateBlockedEvidence` 升级为 incident replay runtime、emergency stop、shutdown command、live risk engine、risk command、stop command 或 production operations。
- 不把 `PaperOrderIntent`、`PaperSimulatedFillEvidence`、`RiskBlockerEvidence` 或 `PortfolioExposureSnapshot` 升级为 production incident fact、stop decision、restore readiness、broker fill fact、real account state 或 future live risk decision。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不实现 OMS、real order state machine、execution runtime、live risk engine、incident replay runtime、stop command、shutdown command、restore command 或 production operations runtime。
- 不新增 Live PRO Console、live command、order-level command UI、stop button、order form、交易按钮或真实交易授权。

## MTP-94 Live Incident / Stop Blocked Evidence Validation

日期：2026-05-23

执行者：Codex

MTP-94 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-94-LIVE-INCIDENT-STOP-BLOCKED-EVIDENCE`、`MTP-94-AUDIT-INCIDENT-STOP-BLOCKED-REASONS`、`MTP-94-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`、`MTP-94-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-94-LIVE-INCIDENT-STOP-VALIDATION` anchors。
- `Sources/Core/LiveAuditIncidentStopContract.swift` 必须包含 `LiveIncidentStopBlockedGate`、`LiveIncidentStopBlockedReason`、`LiveIncidentStopBlockedEvidenceItem` 和 `LiveIncidentStopBlockedEvidence`。
- `Sources/App/LiveIncidentStopBlockedEvidence.swift` 必须包含 `LiveIncidentStopBlockedEvidenceReadModel` 和 `LiveIncidentStopBlockedEvidenceViewModel`，并保持 Dashboard / Report / Event Timeline 只消费 read model。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-94 focused Core tests，验证 deterministic snapshot、forbidden command / runtime / console flags 和 prior future gate source anchors。
- `Tests/AppTests/AppTests.swift` 必须包含 MTP-94 focused App tests，验证 ViewModel aggregation 和 Event Timeline read-only items。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-94 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-94 live incident / stop blocked evidence、blocked reasons、deterministic snapshot、read-model-only no command surface 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-94 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-94 contract、matrix、validation plan、domain context、latest summary、Core/App source、Dashboard / Event Timeline wiring 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 audit trail runtime、incident replay runtime、emergency stop / shutdown / restore command、production operations、Live PRO Console、signed endpoint、account endpoint、listenKey、broker action、live command、order form、stop button 或交易按钮。

MTP-94 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-94-LIVE-INCIDENT-STOP-BLOCKED-EVIDENCE`
- `MTP-94-AUDIT-INCIDENT-STOP-BLOCKED-REASONS`
- `MTP-94-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`
- `MTP-94-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-94-LIVE-INCIDENT-STOP-VALIDATION`

## MTP-94 禁止

- 不实现 audit trail runtime、incident replay runtime、stop control runtime、emergency stop command、shutdown command 或 restore command。
- 不实现 production operations runtime、production shutdown control、broker session mutation、restore decision runtime 或 live runtime resume。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不实现 OMS、real order state machine、execution runtime、live risk engine、audit service、broker replay、account replay 或 production recovery。
- 不把 Dashboard、Report、Workbench、Event Timeline 或 Evidence Explorer 升级为 Live PRO Console、operator workflow、command model、adapter status、runtime status 或 database schema browser。
- 不新增 live command、order-level command UI、stop button、order form、交易按钮或真实交易授权。

## MTP-95 Validation Docs / Stage Audit Input Validation

日期：2026-05-23

执行者：Codex

MTP-95 的 required validation：

- `docs/audit/inputs/mtpro-live-audit-incident-stop-boundary-v1-stage-audit-input.md` 必须包含 `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-AUDIT-INPUT`、Linear queue evidence、Issue / PR evidence input、Live audit incident stop validation evidence chain、Forbidden capability evidence、Read-model-only boundary evidence、Automation readiness evidence、Validation evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-CLOSEOUT`、`MTP-95-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-95-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-95-LIVE-AUDIT-INCIDENT-STOP-VALIDATION-EVIDENCE-CHAIN` 和 `MTP-95-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-95 回填到 `TVM-LIVE-AUDIT-INCIDENT-STOP` candidate entry，并新增 Project 级 stage closeout section。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-95 只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口，不输出最终 Stage Code Audit Report。
- `checks/automation-readiness.sh` 必须机械检查 MTP-89 至 MTP-95 的 contract、matrix、validation plan、latest summary、stage audit input、Core / App source anchors、Core / App deterministic test anchors、Dashboard smoke `liveIncidentStopGates=5` 和 PR evidence chain。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、signed endpoint、account endpoint、listenKey、broker action、live command、stop button、order form 或交易按钮。
- 必须验证 `.codex/*` 和 `graphify-out/*` 不进入 PR。

MTP-95 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-AUDIT-INPUT`
- `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-CLOSEOUT`
- `MTP-95-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-95-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-95-LIVE-AUDIT-INCIDENT-STOP-VALIDATION-EVIDENCE-CHAIN`
- `MTP-95-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-95 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不读取 API key、secret、真实账户、broker state 或 production runtime state。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 audit trail runtime、incident replay runtime、broker replay runtime、account replay runtime、production recovery runtime、stop control runtime、production operations runtime、Live PRO Console、live command、stop button、order form、交易按钮、emergency stop command、shutdown command 或 restore command。

## MTP-96 TradingClock / Paper Runtime Kernel Boundary Validation

日期：2026-05-25

执行者：Codex

MTP-96 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME`、`MTP-96-PAPER-RUNTIME-KERNEL-BOUNDARY`、`MTP-96-PAPER-ONLY-KERNEL-EVENTS`、`MTP-96-NO-UI-STATE-OR-PERSISTENCE-SCHEMA`、`MTP-96-NO-LIVE-SIGNED-BROKER-RUNTIME` 和 `MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION` anchors。
- `Sources/Core/PaperRuntimeKernelBoundary.swift` 必须定义 `TradingClock`、`TradingClockTick`、`PaperRuntimeKernelBoundary`、`PaperRuntimeKernelLifecycleState`、`PaperRuntimeKernelInputKind` 和 `PaperRuntimeKernelOutputKind`，并保持这些类型只表达 Core paper-only boundary。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-96 focused tests，验证 deterministic TradingClock、paper-only kernel fixture、forbidden signed/account/listenKey/broker/LiveExecutionAdapter/OMS/live command/trading button、以及 no UI state / no persistence schema。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-PAPER-RUNTIME-KERNEL` 和 MTP-96 issue backfill。
- `docs/domain/context.md` 必须包含 `MTP-96-PAPER-RUNTIME-KERNEL-TERMS`。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-96 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-96 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 CommandBus / EventBus / MessageBus、Paper RiskEngine、paper lifecycle coordinator、simulated fill、paper account projection、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order lifecycle、live command 或交易按钮。

MTP-96 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME`
- `MTP-96-PAPER-RUNTIME-KERNEL-BOUNDARY`
- `MTP-96-PAPER-ONLY-KERNEL-EVENTS`
- `MTP-96-NO-UI-STATE-OR-PERSISTENCE-SCHEMA`
- `MTP-96-NO-LIVE-SIGNED-BROKER-RUNTIME`
- `MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION`

## MTP-96 禁止

- 不实现真实 live runtime、production scheduler、exchange clock 或 broker session clock。
- 不实现 CommandBus / EventBus / MessageBus routing。
- 不实现 Paper Pre-trade RiskEngine runtime path、paper lifecycle coordinator、simulated fill / fee / slippage model 或 paper account / portfolio projection v2。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、真实 submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不暴露 UI state、Runtime object、Adapter object、SQLite / DuckDB schema 或 broker object。
- 不新增 Live PRO Console、live command、order-level command UI、order form、交易按钮或真实交易授权。

## MTP-97 CommandBus / EventBus / MessageBus Routing Validation

日期：2026-05-25

执行者：Codex

MTP-97 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-97-COMMANDBUS-EVENTBUS-MESSAGEBUS-ROUTING`、`MTP-97-DETERMINISTIC-PAPER-ROUTE-ORDER`、`MTP-97-REPLAYABLE-ROUTE-EVIDENCE`、`MTP-97-NO-LIVE-SIGNED-BROKER-ROUTING` 和 `MTP-97-PAPER-RUNTIME-BUS-VALIDATION` anchors。
- `Sources/Core/PaperRuntimeBusRouting.swift` 必须定义 `PaperRuntimeCommandBus`、`PaperRuntimeEventBus`、`PaperRuntimeMessageBusRouting`、`PaperRuntimeRouteEvidence`、`PaperRuntimeBusRoutingContract` 和 deterministic fixture，并保持 routing 只覆盖 paper session command、paper risk decision、paper lifecycle event 和 simulated fill event。
- `Sources/Core/EventLog.swift` / `MessageBus.publish` 可接收 deterministic envelope `id`，用于 replay evidence 固定 source / correlation / causation；默认行为仍保持 append-only event log 分配 sequence。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-97 focused tests，验证 routing 顺序 deterministic、Event Log / Replay 后 route evidence 可复现、以及 live command bus / signed request / broker / invalid stream bypass 均被拒绝。
- `docs/domain/context.md` 必须包含 `MTP-97-PAPER-RUNTIME-BUS-ROUTING-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-97 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-97 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-97 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 Paper RiskEngine、paper lifecycle coordinator、simulated fill / fee / slippage model、paper account projection、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、live command 或交易按钮。

MTP-97 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-97-COMMANDBUS-EVENTBUS-MESSAGEBUS-ROUTING`
- `MTP-97-DETERMINISTIC-PAPER-ROUTE-ORDER`
- `MTP-97-REPLAYABLE-ROUTE-EVIDENCE`
- `MTP-97-NO-LIVE-SIGNED-BROKER-ROUTING`
- `MTP-97-PAPER-RUNTIME-BUS-VALIDATION`

## MTP-97 禁止

- 不实现 live command bus、order-level real command 或真实 submit / cancel / replace。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 execution report parser / ingestion、broker fill recorder、reconciliation service、OMS 或 real order lifecycle。
- 不实现 Paper RiskEngine runtime path、paper lifecycle coordinator、simulated fill / fee / slippage model 或 paper account / portfolio projection v2。
- 不暴露 Runtime object、Adapter object、SQLite / DuckDB schema、broker acknowledgement、UI state 或 Live PRO Console。
- 不新增 live command、order-level command UI、order form、交易按钮或真实交易授权。

## MTP-98 Paper Pre-trade RiskEngine Runtime Path Validation

日期：2026-05-25

执行者：Codex

MTP-98 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH`、`MTP-98-ACCEPTED-REJECTED-PAPER-RISK-DECISION`、`MTP-98-REJECTED-DECISION-EVENTLOG-REPLAY`、`MTP-98-PAPER-RISK-NO-LIVE-ACCOUNT-BROKER-UPGRADE` 和 `MTP-98-PAPER-RISKENGINE-VALIDATION` anchors。
- `Sources/Core/PaperPreTradeRiskEngine.swift` 必须定义 `PaperPreTradeRiskEngineInput`、`PaperPreTradeRiskEngineDecision`、`PaperPreTradeRiskEngineRuntimePath`、`PaperPreTradeRiskEnginePublication` 和 deterministic fixture，并保持输入只来自 paper proposal、paper account snapshot、paper exposure 和 deterministic paper risk rules。
- MTP-98 必须复用 MTP-97 `PaperRuntimeMessageBusRouting`，让 rejected paper risk decision 进入 `.risk` stream 的 `evaluationRequested` / `blocked` facts，并可由 Event Log / Replay 重建 route evidence。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-98 focused tests，验证 accepted / rejected paper risk decision deterministic、rejected decision 进入 Event Log / Replay、以及真实账户、broker position、margin、leverage、live risk engine、real pre-trade allow / reject 和 paper -> future live risk decision decode bypass 均被拒绝。
- `docs/domain/context.md` 必须包含 `MTP-98-PAPER-PRETRADE-RISKENGINE-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-98 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-98 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-98 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 paper lifecycle coordinator、simulated fill / fee / slippage model、paper account / portfolio projection、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、live command 或交易按钮。

MTP-98 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH`
- `MTP-98-ACCEPTED-REJECTED-PAPER-RISK-DECISION`
- `MTP-98-REJECTED-DECISION-EVENTLOG-REPLAY`
- `MTP-98-PAPER-RISK-NO-LIVE-ACCOUNT-BROKER-UPGRADE`
- `MTP-98-PAPER-RISKENGINE-VALIDATION`

## MTP-98 禁止

- 不实现 live risk engine、真实账户风控、real pre-trade allow / reject runtime、circuit breaker command、stop trading command 或 emergency stop。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL 或 equity。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、真实 submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 paper lifecycle coordinator、simulated fill / fee / slippage model 或 paper account / portfolio projection v2。
- 不把 paper risk blocker、paper exposure 或 paper account snapshot 升级为 future live risk decision、真实账户 exposure、broker position、risk command、live command UI、order form、交易按钮或真实交易授权。

## MTP-99 Paper-only Lifecycle Coordinator / Local Order Lifecycle Validation

日期：2026-05-25

执行者：Codex

MTP-99 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-99-PAPER-ONLY-LIFECYCLE-COORDINATOR`、`MTP-99-LOCAL-ORDER-LIFECYCLE-STATES`、`MTP-99-LIFECYCLE-TRANSITION-EVENT-FACTS`、`MTP-99-SIMULATED-FILL-PRECONDITION`、`MTP-99-NO-OMS-BROKER-REAL-CANCEL` 和 `MTP-99-PAPER-LIFECYCLE-COORDINATOR-VALIDATION` anchors。
- `Sources/Core/PaperOrderLifecycleCoordinator.swift` 必须定义 `PaperOrderLocalLifecycleState`、`PaperOrderLocalLifecycleTransition`、`PaperOrderLocalLifecycleCoordinator`、`PaperOrderLocalLifecyclePublication`、`PaperOrderSimulatedFillPrecondition` 和 deterministic fixture。
- `PaperOrderLocalLifecycleCoordinator` 必须消费 MTP-98 `PaperPreTradeRiskEngineDecision`，accepted path 产生 `proposed -> submittedLocal -> acceptedLocal`，rejected path 产生 `proposed -> rejectedByPaperRisk`。
- 每个 transition 必须通过 `PaperEvent.orderLocalLifecycleTransitionRecorded` 写入 `.paper` stream，并可由 Event Log / Replay 重建 route evidence。
- `cancelledLocal` 只能来自 session close / reset、local expiry 或 deterministic local rule；不得新增单笔 order cancel button 或 real cancel command。
- `PaperOrderSimulatedFillPrecondition` 只能从 `acceptedLocal` 生成，且不生成 simulated fill / fee / slippage。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-99 focused tests，验证 deterministic accepted / rejected lifecycle、transition event facts、replay evidence、simulated fill precondition，以及 OMS / broker / real order state machine / real cancel / order-level command UI bypass 均被拒绝。
- `docs/domain/context.md` 必须包含 `MTP-99-PAPER-LOCAL-LIFECYCLE-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-99 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-99 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-99 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、single-order cancel UI、order-level command UI、live command 或交易按钮。

MTP-99 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-99-PAPER-ONLY-LIFECYCLE-COORDINATOR`
- `MTP-99-LOCAL-ORDER-LIFECYCLE-STATES`
- `MTP-99-LIFECYCLE-TRANSITION-EVENT-FACTS`
- `MTP-99-SIMULATED-FILL-PRECONDITION`
- `MTP-99-NO-OMS-BROKER-REAL-CANCEL`
- `MTP-99-PAPER-LIFECYCLE-COORDINATOR-VALIDATION`

## MTP-99 禁止

- 不实现 simulated fill / fee / slippage model 或 paper account / portfolio projection v2。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增单笔 order cancel button、order-level command UI、order form、live command、Live PRO Console 或交易按钮。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL 或 equity。
- 不把 `acceptedLocal` 写成 exchange accepted、broker submitted、broker accepted 或真实执行授权。

## MTP-100 Simulated Fill / Fee / Slippage Deterministic Model Validation

日期：2026-05-26

执行者：Codex

MTP-100 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-100-SIMULATED-FILL-MARKET-SNAPSHOT`、`MTP-100-PARTIAL-FULL-SIMULATED-FILL-EVIDENCE`、`MTP-100-FEE-SLIPPAGE-COST-IMPACT`、`MTP-100-SIMULATED-FILL-EVENTLOG-REPLAY`、`MTP-100-NO-BROKER-EXECUTION-REPORT-RECONCILIATION` 和 `MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-VALIDATION` anchors。
- `Sources/Core/PaperSimulatedFillEvidence.swift` 必须定义 `PaperSimulatedFillMarketSnapshot`、`PaperSimulatedFillCompletion`、`PaperSimulatedFillPriceSource`、`PaperSimulatedFillEventLogBoundary`、`PaperSimulatedFillPublication`、`PaperSimulatedFillReplayPath` 和 deterministic fixture。
- simulated fill 输入必须包含 market snapshot、allowed paper order intent、MTP-99 `PaperOrderSimulatedFillPrecondition` 和 deterministic fill assumption。
- fee / slippage 必须复用 MTP-27 `ExecutionCostAssumptions.deterministicFixture`，不得引入交易所费率表、真实 fee statement、dynamic slippage 或 execution optimizer。
- partial / full fill evidence 必须可区分：full 的 remaining quantity 为 0；partial 的 remaining quantity 大于 0。
- simulated fill result 必须通过 MTP-97 `PaperRuntimeMessageBusRouting` 写入 `.paper` stream，并可从 Event Log / Replay 重建 route evidence 和 fill facts。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-100 focused tests，验证 deterministic full / partial cost evidence、Event Log / Replay evidence，以及 broker fill / execution report / reconciliation / real account update bypass 均被拒绝。
- `docs/domain/context.md` 必须包含 `MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-100 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-100 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-100 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation、signed endpoint、account endpoint、broker action 或 real account update。

MTP-100 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-100-SIMULATED-FILL-MARKET-SNAPSHOT`
- `MTP-100-PARTIAL-FULL-SIMULATED-FILL-EVIDENCE`
- `MTP-100-FEE-SLIPPAGE-COST-IMPACT`
- `MTP-100-SIMULATED-FILL-EVENTLOG-REPLAY`
- `MTP-100-NO-BROKER-EXECUTION-REPORT-RECONCILIATION`
- `MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-VALIDATION`

## MTP-100 禁止

- 不实现 paper account / portfolio / position projection v2。
- 不新增 App / Dashboard surface。
- 不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation 或 real account update。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、Live PRO Console、live command、order form 或交易按钮。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL 或 equity。
- 不把 `PaperSimulatedFillEvidence` 写成真实成交、broker fill、execution report 或 account update。

## MTP-101 Paper Account / Portfolio / Position Projection v2 Validation

日期：2026-05-26

执行者：Codex

MTP-101 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-101-PAPER-ACCOUNT-PORTFOLIO-POSITION-PROJECTION`、`MTP-101-REPLAYED-SIMULATED-FILL-PROJECTION`、`MTP-101-PAPER-PNL-SNAPSHOT`、`MTP-101-READ-MODEL-CONSUMPTION`、`MTP-101-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE` 和 `MTP-101-PAPER-ACCOUNT-PORTFOLIO-VALIDATION` anchors。
- `Sources/Core/PaperAccountPortfolioProjectionV2.swift` 必须定义 `PaperAccountProjectionSnapshot`、`PaperPositionProjectionSnapshot`、`PaperPortfolioPnLSummary`、`PaperAccountPortfolioProjectionV2Snapshot`、`PaperAccountPortfolioProjectionV2Path` 和 deterministic fixture。
- Projection v2 必须从 replayed `.paper.simulatedFillRecorded` facts 派生 account cash、available paper balance、equity、position quantity、average entry、exposure、cost basis 和 paper PnL summary。
- Persistence 只能保存 Core snapshot 派生的 runtime projection；App / Dashboard / Report / Risk / Portfolio 只能消费 read model / ViewModel。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-101 focused tests，验证 replay -> projection deterministic 和 Codable forbidden capability bypass rejection。
- `Tests/AppTests/AppTests.swift` 必须包含 MTP-101 focused test，验证 Report / Dashboard / Risk / Portfolio read model consumption。
- `docs/domain/context.md` 必须包含 `MTP-101-PAPER-ACCOUNT-PORTFOLIO-PROJECTION-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-101 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-101 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-101 contract、matrix、validation plan、domain context、latest summary、Core/App source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现真实账户余额读取、broker position sync、margin、leverage、real PnL、live risk runtime、signed endpoint、account endpoint、broker action 或真实订单行为。

MTP-101 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-101-PAPER-ACCOUNT-PORTFOLIO-POSITION-PROJECTION`
- `MTP-101-REPLAYED-SIMULATED-FILL-PROJECTION`
- `MTP-101-PAPER-PNL-SNAPSHOT`
- `MTP-101-READ-MODEL-CONSUMPTION`
- `MTP-101-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`
- `MTP-101-PAPER-ACCOUNT-PORTFOLIO-VALIDATION`

## MTP-101 禁止

- 不实现 Event Log / Replay / Report / Dashboard evidence stage closeout；该收口留给 MTP-102。
- 不新增 order-level App / Dashboard command surface，不新增 position command、order form、live command 或交易按钮。
- 不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation 或 real account update。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、Live PRO Console、live command、order form 或交易按钮。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL 或 equity。

## MTP-102 Event Log / Replay / Report / Dashboard Evidence Stage Closeout Validation

日期：2026-05-26

执行者：Codex

MTP-102 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-102-EVENTLOG-REPLAY-PROJECTION-EVIDENCE-CLOSEOUT`、`MTP-102-REPORT-DASHBOARD-PAPER-RUNTIME-EVIDENCE`、`MTP-102-EVENT-TIMELINE-COMPLETE-SEQUENCE`、`MTP-102-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-102-NO-FINAL-STAGE-CODE-AUDIT` 和 `MTP-102-PAPER-RUNTIME-STAGE-CLOSEOUT-VALIDATION` anchors。
- `Sources/App/App.swift` 必须把 local lifecycle transition IDs、paper risk decision IDs、paper order IDs、simulated fill IDs、account portfolio snapshot IDs、gross notional、fee、slippage、cost impact、paper account、position 和 paper PnL evidence 汇总到 `ReportViewModel`。
- `Sources/App/PaperWorkflowEvidenceExplorer.swift` 必须把 `.paper.orderLocalLifecycleTransitionRecorded` 映射为 `Paper local lifecycle transition` Event Timeline item，并保留 risk decision / paper order evidence links。
- `Sources/App/DashboardShell.swift` 必须在 Report metrics / details 和 `smokeSummary` 中输出 paper runtime evidence、paper workflow evidence 和 paper portfolio impact handles。
- `Tests/AppTests/AppTests.swift` 必须包含 `testMTP102PaperRuntimeEvidenceChainFeedsReportDashboardAndEventTimeline`，验证 risk -> lifecycle -> simulated fill -> account portfolio projection 的 deterministic replay chain 被 Report / Dashboard / Event Timeline 只读消费。
- `docs/audit/inputs/mtpro-event-driven-paper-trading-runtime-v1-stage-audit-input.md` 必须作为 Parent Codex Stage Code Audit 输入材料落仓；不得生成最终 Stage Code Audit Report。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-102 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-102 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-102 contract、matrix、validation plan、latest summary、stage audit input、App source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 final Stage Code Audit Report、Project closure、Root Docs Refresh Gate、OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、real account update、signed endpoint、account endpoint、broker action、Live PRO Console、live command、order form、position command 或交易按钮。

MTP-102 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-102-EVENTLOG-REPLAY-PROJECTION-EVIDENCE-CLOSEOUT`
- `MTP-102-REPORT-DASHBOARD-PAPER-RUNTIME-EVIDENCE`
- `MTP-102-EVENT-TIMELINE-COMPLETE-SEQUENCE`
- `MTP-102-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-102-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-102-PAPER-RUNTIME-STAGE-CLOSEOUT-VALIDATION`

## MTP-102 禁止

- 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一 issue，不启动下一阶段 `symphony-issue`。
- 不新增 order-level App / Dashboard command surface，不新增 position command、order form、live command、Live PRO Console、stop button 或交易按钮。
- 不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation 或 real account update。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、live risk runtime、production runtime 或真实交易授权。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL、equity、secret 或 API key。

## MTP-103 Data Catalog / Scenario Replay Terminology / Boundary Validation

日期：2026-05-26

执行者：Codex

MTP-103 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY`、`MTP-103-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`、`MTP-103-LOCAL-FIRST-DETERMINISTIC-VERSIONED-BOUNDARY`、`MTP-103-FORBIDDEN-CAPABILITY-BASELINE` 和 `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION` anchors。
- `Sources/Core/DataCatalogScenarioReplayBoundary.swift` 必须定义 `DataCatalogScenarioReplayTerm`、`DataCatalogScenarioReplayTargetEngine`、`DataCatalogScenarioReplayBoundaryPrinciple`、`DataCatalogScenarioReplayForbiddenCapability`、`DataCatalogScenarioReplayEvidenceKind` 和 `DataCatalogScenarioReplayBoundary.deterministicFixture`。
- `DataCatalogScenarioReplayBoundary` 必须固定 Data Engine、State & Persistence Engine 和 Workbench Interface 三类目标引擎职责。
- Boundary fixture 必须保持 `local-first`、`deterministic`、`versioned` 和 `read-model-only` flags 为 true。
- Boundary fixture 必须保持 manifest parser、fixture data、replay cursor、report input versioning、production data platform、large-scale ingestion pipeline、real network download、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、live command、trading button、Graphify update 和 Figma change flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-103 focused tests，验证 terminology / boundary anchors、forbidden capability bypass rejection、Codable decode bypass rejection 和 local-first read-model-only target engine boundary。
- `docs/domain/context.md` 必须包含 `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY` 和 `MTP-103-FORBIDDEN-CAPABILITY-BASELINE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-DATA-CATALOG-SCENARIO-REPLAY` 和 MTP-103 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-103 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-103 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 manifest parser、fixture data、replay cursor、report input versioning、production data platform、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-103 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY`
- `MTP-103-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`
- `MTP-103-LOCAL-FIRST-DETERMINISTIC-VERSIONED-BOUNDARY`
- `MTP-103-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION`

## MTP-103 禁止

- 不实现 scenario manifest parser、scenario manifest 最终字段解析、fixture 数据、replay cursor、checksum 计算、freshness evidence runtime、data quality gate runtime 或 report input versioning runtime。
- 不实现 Simulated Exchange / Backtest Parity runtime；该能力必须由后续独立 Project / issue 授权。
- 不新增 production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production retention cleanup 或数据修复平台。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-104 Scenario Manifest / Scenario ID / Dataset Version Contract Validation

日期：2026-05-26

执行者：Codex

MTP-104 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS`、`MTP-104-SCENARIO-ID-DATASET-VERSION-STABLE-IDENTITY`、`MTP-104-SINGLE-SYMBOL-SINGLE-TIMEFRAME-MANIFEST`、`MTP-104-MANIFEST-DETERMINISTIC-SERIALIZATION`、`MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY` 和 `MTP-104-SCENARIO-MANIFEST-VALIDATION` anchors。
- `Sources/Core/ScenarioManifest.swift` 必须定义 `ScenarioID`、`DatasetVersion`、`ScenarioManifestScope`、`ScenarioManifestDeterministicSerialization` 和 `ScenarioManifest.deterministicFixture`。
- `ScenarioManifest` 必须固定 `scenarioID`、`datasetVersion`、`symbol`、`timeframe`、`sourceAnchor` 和 `single-symbol / single-timeframe` scope。
- `ScenarioManifest.deterministicSerialization` 必须固定 canonical field order，并生成可比较的 stable source identity。
- Manifest fixture 必须保持 database schema exposure、adapter request exposure、secret、signed endpoint、account endpoint、listenKey、broker、order command、live runtime、production dataset registry、real network download、multi-symbol catalog 和 multi-timeframe catalog flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-104 focused tests，验证 manifest 最小字段、scenario id / dataset version stable identity、single-symbol / single-timeframe scope、deterministic serialization / equality evidence、forbidden capability bypass rejection 和 Codable decode bypass rejection。
- `docs/domain/context.md` 必须包含 `MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS` 和 `MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-104 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-104 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-104 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 fixture data、replay cursor、report input versioning runtime、production dataset registry、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-104 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS`
- `MTP-104-SCENARIO-ID-DATASET-VERSION-STABLE-IDENTITY`
- `MTP-104-SINGLE-SYMBOL-SINGLE-TIMEFRAME-MANIFEST`
- `MTP-104-MANIFEST-DETERMINISTIC-SERIALIZATION`
- `MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY`
- `MTP-104-SCENARIO-MANIFEST-VALIDATION`

## MTP-104 禁止

- 不实现 manifest file parser、fixture data、replay cursor、checksum calculation runtime、freshness evidence runtime、data quality gate runtime 或 report input versioning runtime。
- 不新增 multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器或 production retention cleanup。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-105 Single-Symbol / Single-Timeframe Deterministic Scenario Fixture Validation

日期：2026-05-26

执行者：Codex

MTP-105 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE`、`MTP-105-FIXTURE-VERSION-SOURCE-ANCHOR`、`MTP-105-FIXED-WINDOW-RECORD-ORDER`、`MTP-105-PUBLIC-READ-ONLY-LOCAL-FIXTURE-RELATIONSHIP`、`MTP-105-DETERMINISTIC-SUMMARY-PRESTRUCTURE`、`MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE` 和 `MTP-105-SCENARIO-FIXTURE-VALIDATION` anchors。
- `Sources/Core/ScenarioFixture.swift` 必须定义 `FixtureVersion`、`ScenarioFixtureSourceKind`、`ScenarioFixtureRecordOrderPolicy`、`ScenarioFixtureRecord`、`ScenarioFixtureDeterministicSummary` 和 `DeterministicScenarioFixture.deterministicFixture`。
- `DeterministicScenarioFixture` 必须复用 `ScenarioManifest.deterministicFixture`，并固定 `fixture-v1`、BTCUSDT、1m、fixed window、record sequence `1,2,3`、strictly ascending interval starts 和 local public-read-only source relationship。
- `ScenarioFixtureDeterministicSummary` 必须固定 record count、ordered starts、record order identity、canonical record summary、checksum preimage 和 MTP-104 source identity；`checksumEvidenceDeferredToMTP106` 必须为 `true`。
- Fixture 必须保持 required validation network-independent，且 real network download、production ingestion pipeline、cloud data lake、adapter request exposure、secret、signed endpoint、account endpoint、listenKey、broker、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、live command、trading button、multi-symbol 和 multi-timeframe flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-105 focused tests，验证 first scenario records、fixture version / source anchor、fixed window / record order、deterministic summary pre-structure、forbidden capability bypass rejection、Codable decode bypass rejection 和 forbidden text absence。
- `docs/domain/context.md` 必须包含 `MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE` 和 `MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-105 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-105 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-105 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 replay cursor、final checksum evidence、freshness evidence、data quality gate、report input versioning runtime、production dataset registry、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-105 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE`
- `MTP-105-FIXTURE-VERSION-SOURCE-ANCHOR`
- `MTP-105-FIXED-WINDOW-RECORD-ORDER`
- `MTP-105-PUBLIC-READ-ONLY-LOCAL-FIXTURE-RELATIONSHIP`
- `MTP-105-DETERMINISTIC-SUMMARY-PRESTRUCTURE`
- `MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE`
- `MTP-105-SCENARIO-FIXTURE-VALIDATION`

## MTP-105 禁止

- 不实现 manifest file parser、replay cursor、final checksum evidence、freshness evidence runtime、data quality gate runtime 或 report input versioning runtime。
- 不新增 multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器或 production retention cleanup。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-106 Replay Window / Cursor / Checksum / Freshness Evidence Validation

日期：2026-05-26

执行者：Codex

MTP-106 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-106-DETERMINISTIC-REPLAY-WINDOW`、`MTP-106-REPLAY-CURSOR-SUMMARY`、`MTP-106-CHECKSUM-PARITY-EVIDENCE`、`MTP-106-FIXTURE-FRESHNESS-EVIDENCE`、`MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE` 和 `MTP-106-SCENARIO-REPLAY-EVIDENCE-VALIDATION` anchors。
- `Sources/Core/ScenarioReplayEvidence.swift` 必须定义 `ScenarioReplayWindow`、`ScenarioReplayCursor`、`ScenarioReplayCursorSummary`、`ScenarioReplayChecksumEvidence`、`ScenarioReplayFreshnessPolicy`、`ScenarioReplayFreshnessEvidence` 和 `ScenarioReplayEvidence.deterministicFixture`。
- `ScenarioReplayWindow` 必须复用 MTP-105 deterministic fixture 的 fixed window `1704067200...1704067380`、record sequence `1,2,3`、ordered starts 和 record order identity。
- `ScenarioReplayCursor` 必须只表达本地 fixture record progress，支持 Codable round-trip 和 Comparable，并拒绝 `1...4` 之外的 next sequence。
- `ScenarioReplayChecksumEvidence` 必须从 MTP-105 checksum preimage 生成 final checksum `fnv1a64:3c6cd4ff13cd4062`，并拒绝 checksum drift。
- `ScenarioReplayFreshnessEvidence` 必须固定 local fixture freshness policy、evaluatedAt `1704067500`、age `120` seconds 和 status `fresh`，并拒绝 production retention / network / archive bypass。
- `ScenarioReplayEvidence` 必须输出可被 MTP-107 data quality gates 消费的 `dataQualityGateInputIdentity`，但不得实现 data quality gate runtime 或 report input versioning runtime。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-106 focused tests，验证 replay window deterministic、cursor 可复现 / 可编码 / 可比较、checksum / freshness evidence 稳定、drift rejection、forbidden capability bypass rejection 和 forbidden text absence。
- `docs/domain/context.md` 必须包含 `MTP-106-DETERMINISTIC-REPLAY-WINDOW`、`MTP-106-CHECKSUM-PARITY-EVIDENCE`、`MTP-106-FIXTURE-FRESHNESS-EVIDENCE` 和 `MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-106 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-106 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-106 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 data quality gate runtime、report input versioning runtime、production retention engine、production dataset registry、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-106 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-106-DETERMINISTIC-REPLAY-WINDOW`
- `MTP-106-REPLAY-CURSOR-SUMMARY`
- `MTP-106-CHECKSUM-PARITY-EVIDENCE`
- `MTP-106-FIXTURE-FRESHNESS-EVIDENCE`
- `MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE`
- `MTP-106-SCENARIO-REPLAY-EVIDENCE-VALIDATION`

## MTP-106 禁止

- 不实现 manifest file parser、data quality gate runtime 或 report input versioning runtime。
- 不新增 multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production scheduler、production retention cleanup、cloud archive 或 storage tiering。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-107 Data Quality Gates / Report Input Versioning Validation

日期：2026-05-26

执行者：Codex

MTP-107 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-107-DATA-QUALITY-GATE-TAXONOMY`、`MTP-107-MINIMAL-DATA-QUALITY-GATES`、`MTP-107-REPORT-INPUT-VERSIONING`、`MTP-107-REPORT-REPRODUCIBILITY-EVIDENCE`、`MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM` 和 `MTP-107-DATA-QUALITY-REPORT-INPUT-VALIDATION` anchors。
- `Sources/Core/ScenarioDataQualityReportInput.swift` 必须定义 `ScenarioDataQualityGateKind`、`ScenarioDataQualityGateVerdict`、`ScenarioDataQualityVerdict`、`ScenarioDataQualityGateEvaluation`、`ScenarioReportInputVersion` 和 `ScenarioDataQualityReportInputEvidence.deterministicFixture`。
- `ScenarioDataQualityGateEvaluation` 必须消费 MTP-106 `ScenarioReplayEvidence`，并固定 record order、window coverage、checksum match、freshness status、missing data 和 duplicate data 六个最小 gates。
- 默认 deterministic fixture 必须全部 passed，整体 `qualityVerdict == accepted`；checksum mismatch、bad record order、missing data 和 duplicate data 必须 rejected；stale freshness 必须 marked；expired freshness 必须 rejected。
- `ScenarioReportInputVersion` 必须复制 scenario id、dataset version、fixture version、symbol、timeframe、replay window、checksum、freshness status、quality verdict 和 quality summary，并固定 canonical field order。
- Report input versioning 必须保持 stable contract，不暴露 SQLite / DuckDB schema、adapter request 或 Runtime object。
- `ScenarioDataQualityReportInputEvidence` 必须把 replay evidence、quality evaluation 和 report input version 绑定到同一 deterministic identity，并保持 `reportReproducibilityEvidenceHeld == true`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-107 focused tests，验证 gate taxonomy、deterministic accepted verdict、report input version tracing、bad fixture / checksum mismatch / missing / duplicate data rejection、stale marking、expired rejection、forbidden capability bypass rejection 和 Codable decode bypass rejection。
- `docs/domain/context.md` 必须包含 `MTP-107-DATA-QUALITY-GATE-TAXONOMY`、`MTP-107-REPORT-INPUT-VERSIONING` 和 `MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-107 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-107 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-107 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 production data platform、production data observability、automatic download / repair、broker / account reconciliation、Simulated Exchange / Backtest Parity runtime、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-107 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-107-DATA-QUALITY-GATE-TAXONOMY`
- `MTP-107-MINIMAL-DATA-QUALITY-GATES`
- `MTP-107-REPORT-INPUT-VERSIONING`
- `MTP-107-REPORT-REPRODUCIBILITY-EVIDENCE`
- `MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM`
- `MTP-107-DATA-QUALITY-REPORT-INPUT-VALIDATION`

## MTP-107 禁止

- 不实现 manifest file parser、production data quality platform、production data observability、automatic download、automatic repair、broker / account reconciliation 或 Simulated Exchange / Backtest Parity runtime。
- 不新增 multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production scheduler、production retention cleanup、cloud archive 或 storage tiering。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-108 Workbench / Report / Events Scenario Replay Evidence Surface Validation

日期：2026-05-26

执行者：Codex

MTP-108 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE`、`MTP-108-REPORT-SCENARIO-REPLAY-EVIDENCE`、`MTP-108-WORKBENCH-SCENARIO-REPLAY-SUMMARY-DRILLDOWN`、`MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS`、`MTP-108-QUALITY-GATE-TIMELINE`、`MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-108-SCENARIO-REPLAY-SURFACE-VALIDATION` anchors。
- `Sources/App/ScenarioReplayEvidenceSurface.swift` 必须定义 `ScenarioReplayEvidenceReadModel`、`ScenarioReplayEvidenceViewModel` 和 MTP-108 validation anchors，并且只消费 MTP-107 `ScenarioDataQualityReportInputEvidence.deterministicFixture` 的 stable fields。
- `ReportReadModel` / `ReportViewModel` 必须输出 scenario id、dataset version、fixture version、replay window、checksum、freshness status、quality verdict、report input version identity、drill-down entry、timeline count 和 quality gate timeline count。
- `DashboardShellWorkbenchSnapshot` 必须输出 scenario replay summary、drill-down evidence、read-model-only source 和 Dashboard smoke handles `scenarioReplayEvidence` / `scenarioQualityGates`。
- `PaperWorkflowEvidenceExplorer` 必须新增 `scenario replay evidence` section，并输出 replay window、cursor、checksum、freshness 和六个 quality gate timeline rows。
- `Tests/AppTests/AppTests.swift` 必须包含 `testMTP108ScenarioReplayEvidenceFeedsReportWorkbenchAndEventsReadOnly`，覆盖 Report、Workbench、Events、Dashboard smoke、Codable stable snapshot、read-model-only boundary、no command surface、no query language、no trading button、no live command、no broker action。
- `docs/domain/context.md` 必须包含 `MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE` 和 `MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-108 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-108 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-108 contract、matrix、validation plan、domain context、latest summary、App source、Dashboard / Events source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 Runtime / Adapter / Persistence schema、不实现 database console、query language、command surface、production data platform、automatic download / repair、broker / account reconciliation、Simulated Exchange / Backtest Parity runtime、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-108 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE`
- `MTP-108-REPORT-SCENARIO-REPLAY-EVIDENCE`
- `MTP-108-WORKBENCH-SCENARIO-REPLAY-SUMMARY-DRILLDOWN`
- `MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS`
- `MTP-108-QUALITY-GATE-TIMELINE`
- `MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-108-SCENARIO-REPLAY-SURFACE-VALIDATION`

## MTP-108 禁止

- 不实现 manifest parser、Runtime replay job、Adapter request、Persistence schema、database console、query language 或 command model。
- 不新增 multi-symbol / multi-timeframe production catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production scheduler、production retention cleanup、cloud archive 或 storage tiering。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console、schema inspector、Runtime inspector 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-109 Validation Docs / Stage Audit Input Validation

日期：2026-05-26

执行者：Codex

MTP-109 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-CLOSEOUT`、`MTP-109-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-109-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-AUDIT-INPUT`、`MTP-109-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION-EVIDENCE-CHAIN`、`MTP-109-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN` 和 `MTP-109-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/audit/inputs/mtpro-data-catalog-scenario-replay-v1-stage-audit-input.md` 必须存在，并包含 MTP-103 至 MTP-108 issue / PR evidence、Project validation evidence chain、forbidden capability evidence、read-model-only boundary evidence、automation readiness evidence、known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-109 的当前 issue execution evidence，并明确 MTP-109 只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口，不输出最终 Stage Code Audit Report。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-109 issue backfill 和 MTP-109 Data Catalog / Scenario Replay 阶段收口说明，并指向 MTP-109 Stage Code Audit 输入材料。
- `docs/automation/automation-readiness.md` 必须包含 Data Catalog / Scenario Replay stage audit input anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-103 至 MTP-109 的 contract、matrix、validation plan、latest summary、stage audit input、Core / App source anchors、Core / App deterministic test anchors 和 Dashboard smoke `scenarioReplayEvidence` / `scenarioQualityGates` handles。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

MTP-109 必须收口的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-CLOSEOUT`
- `MTP-109-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-109-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-AUDIT-INPUT`
- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION-EVIDENCE-CHAIN`
- `MTP-109-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-109-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-109 禁止

- 不输出最终 Stage Code Audit Report，不创建 `docs/audit/mtpro-data-catalog-scenario-replay-v1-stage-code-audit.md`，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一 issue，不启动下一阶段 `symphony-issue`。
- 不实现 Simulated Exchange / Backtest Parity、production data platform、production data observability、large-scale ingestion pipeline、cloud data lake、automatic download、automatic repair、production scheduler、retention cleanup、cloud archive 或 storage tiering。
- 不实现 manifest parser、Runtime replay job、Adapter request、Persistence schema、database console、query language 或 command model。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console、schema inspector、Runtime inspector 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不进行 unauthorized Linear mutation。

## MTP-110 Simulated Exchange / Backtest Parity Terminology / Boundary Validation

日期：2026-05-26

执行者：Codex

MTP-110 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY`、`MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`、`MTP-110-L1-L15-L2-HANDOFF-BOUNDARY`、`MTP-110-FORBIDDEN-CAPABILITY-BASELINE` 和 `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION` anchors。
- `Sources/Core/SimulatedExchangeBacktestParityBoundary.swift` 必须定义 `SimulatedExchangeBacktestParityTerm`、`SimulatedExchangeBacktestParityTargetEngine`、`SimulatedExchangeBacktestParityBoundaryPrinciple`、`SimulatedExchangeBacktestParityForbiddenCapability`、`SimulatedExchangeBacktestParityEvidenceKind` 和 `SimulatedExchangeBacktestParityBoundary.deterministicFixture`。
- `SimulatedExchangeBacktestParityBoundary` 必须固定 Simulation / Backtest Engine、Execution Engine（paper-only / simulated）、Portfolio Engine、Data Engine、State & Persistence Engine 和 Workbench Interface 六类目标引擎职责。
- Boundary fixture 必须保持 deterministic simulation、backtest-paper shared simulation semantics、L1 Paper Runtime handoff、L1.5 Data Catalog / Scenario Replay handoff 和 read-model-only parity evidence flags 为 true。
- Boundary fixture 必须保持 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、trading button、emergency stop / shutdown / restore、Graphify update 和 Figma change flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-110 focused tests，验证 terminology / boundary anchors、forbidden capability bypass rejection、Codable decode bypass rejection 和 L1 / L1.5 / L2 deterministic handoff boundary。
- `docs/domain/context.md` 必须包含 `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY` 和 `MTP-110-FORBIDDEN-CAPABILITY-BASELINE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY` 和 MTP-110 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-110 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-110 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现撮合、订单执行、portfolio projection、UI、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-110 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY`
- `MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`
- `MTP-110-L1-L15-L2-HANDOFF-BOUNDARY`
- `MTP-110-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION`

## MTP-110 禁止

- 不实现 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command 或交易按钮。
- 不实现 emergency stop、shutdown、restore、production operations、production data platform、large-scale ingestion pipeline、真实交易所接入或 live readiness。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-111 Shared Backtest-Paper Order Semantics Validation

日期：2026-05-26

执行者：Codex

MTP-111 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`、`MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`、`MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT`、`MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE` 和 `MTP-111-SHARED-ORDER-SEMANTICS-VALIDATION` anchors。
- `Sources/Core/BacktestPaperSharedOrderSemantics.swift` 必须定义 `BacktestPaperSharedOrderInputSource`、`BacktestPaperSharedOrderField`、`BacktestPaperSharedOrderState`、`BacktestPaperSharedOrderEventKind`、`BacktestPaperLifecycleReplayAlignmentRule`、`BacktestPaperSharedOrderForbiddenCapability`、`BacktestPaperSharedOrderSemanticsContract.deterministicFixture` 和 `BacktestPaperSharedOrderInput.deterministicFixture`。
- `BacktestPaperSharedOrderSemanticsContract` 必须固定 paper order intent 与 backtest replay order input 的共享字段、simulated order state taxonomy、simulated event kind taxonomy、paper lifecycle / fill completion 到 backtest replay 的 alignment rules、source docs anchors 和 validation anchors。
- `BacktestPaperSharedOrderInput` 必须从既有 `PaperOrderIntent` 复制 order / proposal / session / symbol / timeframe / side / quantity / reference price / notional / risk decision sequence，并绑定 `DeterministicScenarioFixture` 的 scenario id、dataset version 和 fixture version。
- `BacktestPaperSharedOrderSemanticsContract.sharedState(...)` 必须固定 `PaperOrderLifecycleState`、`PaperOrderLocalLifecycleState` 和 `PaperSimulatedFillCompletion` 到 shared simulated order state 的映射。
- Core fixture 必须保持 shared field、lifecycle replay alignment 和 append-only replay facts flags 为 true。
- Core fixture 和 shared input 必须保持 matching runtime、order execution runtime、portfolio projection runtime、real order command、real order lifecycle、real submit / cancel / replace、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、execution report、broker fill、reconciliation、live command、order-level command UI、trading button 和 required network validation flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-111 focused tests，验证 shared fields / states / anchors、paper intent 到 scenario replay input 对齐、state / event 映射、forbidden capability bypass rejection 和 Codable decode bypass rejection。
- `docs/domain/context.md` 必须包含 `MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`、`MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`、`MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT` 和 `MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-111 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-111 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-111 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 matching runtime、order execution runtime、portfolio projection runtime、Report / Dashboard / Events surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、order-level command UI、Live PRO Console 或交易按钮。

MTP-111 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`
- `MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`
- `MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT`
- `MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE`
- `MTP-111-SHARED-ORDER-SEMANTICS-VALIDATION`

## MTP-111 禁止

- 不实现 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不实现 emergency stop、shutdown、restore、production operations、production data platform、large-scale ingestion pipeline、真实交易所接入或 live readiness。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-112 Scenario Replay Deterministic Matching Validation

日期：2026-05-26

执行者：Codex

MTP-112 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`、`MTP-112-DETERMINISTIC-MATCHING-ORDERING`、`MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`、`MTP-112-REPEATABLE-MATCHING-OUTPUT`、`MTP-112-NO-NETWORK-BROKER-LIVE` 和 `MTP-112-SCENARIO-REPLAY-MATCHING-VALIDATION` anchors。
- `Sources/Core/ScenarioReplayDeterministicMatching.swift` 必须定义 `ScenarioReplayDeterministicMatchingContract`、`ScenarioReplayDeterministicMatchingInput`、`ScenarioReplayMatchingMarketState`、`ScenarioReplaySimulatedExchangeEvent`、`ScenarioReplayDeterministicMatchingOutput`、`ScenarioReplayDeterministicMatchingModel`、`ScenarioReplayMatchingOrderingRule` 和 `ScenarioReplayMatchingOutputKind`。
- `ScenarioReplayDeterministicMatchingInput` 必须绑定 MTP-111 shared order input、MTP-106 replay window / cursor / checksum / freshness evidence 和 MTP-105 deterministic fixture record sequence `2`。
- `ScenarioReplayDeterministicMatchingModel.match` 必须对相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input 输出相同 `ScenarioReplayDeterministicMatchingOutput`。
- Deterministic result identity 必须固定 scenario id、dataset version、fixture version、window、cursor sequence、record sequence、order id、scaled price 和 scaled quantity。
- Core fixture 和 Codable decode 必须拒绝 required validation network dependency、wall clock、randomness、signed endpoint、account endpoint、listenKey、broker / exchange adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、live command 和交易按钮绕过。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-112 focused tests，验证 input / output anchors、repeatable output identity、Codable round-trip 和 forbidden capability / cursor mismatch rejection。
- `docs/domain/context.md` 必须包含 `MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`、`MTP-112-DETERMINISTIC-MATCHING-ORDERING`、`MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`、`MTP-112-REPEATABLE-MATCHING-OUTPUT` 和 `MTP-112-NO-NETWORK-BROKER-LIVE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-112 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-112 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-112 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现真实撮合引擎、market / limit execution、partial fill / latency / fee / slippage parity、portfolio projection parity、Report / Dashboard / Events evidence surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-112 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`
- `MTP-112-DETERMINISTIC-MATCHING-ORDERING`
- `MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`
- `MTP-112-REPEATABLE-MATCHING-OUTPUT`
- `MTP-112-NO-NETWORK-BROKER-LIVE`
- `MTP-112-SCENARIO-REPLAY-MATCHING-VALIDATION`

## MTP-112 禁止

- 不实现真实 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不实现 market / limit order execution semantics、partial fill、latency、fee / slippage parity、portfolio projection parity、emergency stop、shutdown、restore、production operations、production data platform、large-scale ingestion pipeline、真实交易所接入或 live readiness。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-113 Market / Limit Simulated Execution Validation

日期：2026-05-26

执行者：Codex

MTP-113 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`、`MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`、`MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`、`MTP-113-DETERMINISTIC-EXECUTION-REPLAY`、`MTP-113-NO-REAL-ORDER-LIVE-COMMAND` 和 `MTP-113-MARKET-LIMIT-SIMULATED-EXECUTION-VALIDATION` anchors。
- `Sources/Core/MarketLimitSimulatedExecutionSemantics.swift` 必须定义 `MarketLimitSimulatedExecutionContract`、`MarketLimitSimulatedExecutionInput`、`MarketLimitSimulatedExecutionEvent`、`MarketLimitSimulatedExecutionOutput`、`MarketLimitSimulatedExecutionModel`、`MarketLimitSimulatedOrderType`、`MarketLimitSimulatedExecutionOutcome`、`MarketLimitSimulatedExecutionRule` 和 `MarketLimitSimulatedExecutionRejectReason`。
- `MarketLimitSimulatedExecutionInput` 必须绑定 MTP-112 deterministic matching input 和 MTP-111 shared order input；market order 不能带 limit price，limit order 必须带 explicit limit price。
- `MarketLimitSimulatedExecutionModel.execute` 必须对 market order 输出 deterministic full fill；对 buy limit price 大于等于 matched price 输出 full fill；对 buy limit price 低于 matched price 输出 expired simulated；对 rejected initial state 输出 rejected simulated。
- `MarketLimitSimulatedExecutionOutput.deterministicResultIdentity` 必须固定 scenario id、dataset version、fixture version、window、cursor sequence、record sequence、order id、order type、limit price、initial state、outcome、matched price、filled quantity 和 remaining quantity。
- Core fixture 和 Codable decode 必须拒绝 advanced order types、真实 order execution runtime、matching runtime、portfolio projection runtime、partial fill bypass、signed endpoint、account endpoint、listenKey、broker / exchange adapter、`LiveExecutionAdapter`、OMS、real submit / cancel / replace、execution report、broker fill、reconciliation、live command、order-level command UI 和交易按钮绕过。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-113 focused tests，验证 market / limit semantics anchors、market full fill、limit full fill、limit expire、reject evidence、deterministic replay identity、Codable round-trip 和 forbidden capability rejection。
- `docs/domain/context.md` 必须包含 `MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`、`MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`、`MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`、`MTP-113-DETERMINISTIC-EXECUTION-REPLAY` 和 `MTP-113-NO-REAL-ORDER-LIVE-COMMAND`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-113 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-113 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-113 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 stop / OCO / advanced order types、partial fill、latency、fee / slippage parity、portfolio projection parity、Report / Dashboard / Events evidence surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-113 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`
- `MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`
- `MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`
- `MTP-113-DETERMINISTIC-EXECUTION-REPLAY`
- `MTP-113-NO-REAL-ORDER-LIVE-COMMAND`
- `MTP-113-MARKET-LIMIT-SIMULATED-EXECUTION-VALIDATION`

## MTP-113 禁止

- 不实现 stop / OCO / advanced order types、真实 order execution runtime、matching runtime、portfolio projection runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不实现 partial fill、latency、fee / slippage parity、portfolio projection parity、emergency stop、shutdown、restore、production operations、production data platform、large-scale ingestion pipeline、真实交易所接入或 live readiness。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-114 Partial Fill / Latency / Fee / Slippage Parity Validation

日期：2026-05-26

执行者：Codex

MTP-114 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-114-PARTIAL-FULL-FILL-PARITY`、`MTP-114-DETERMINISTIC-LATENCY-MODEL`、`MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`、`MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE`、`MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION` 和 `MTP-114-PARTIAL-FILL-LATENCY-FEE-SLIPPAGE-VALIDATION` anchors。
- `Sources/Core/PartialFillLatencyFeeSlippageParity.swift` 必须定义 `PartialFillLatencyFeeSlippageParityContract`、`PartialFillLatencyFeeSlippageParityInput`、`PartialFillLatencyFeeSlippageLatencyAssumption`、`PartialFillLatencyFeeSlippageParityEvent`、`PartialFillLatencyFeeSlippageParityReportEvidence`、`PartialFillLatencyFeeSlippageParityModel`、`PartialFillLatencyFeeSlippageParityRule` 和 `PartialFillLatencyFeeSlippageForbiddenCapability`。
- `PartialFillLatencyFeeSlippageParityInput` 必须绑定 MTP-113 market / limit simulated execution input、deterministic simulated liquidity cap、fixed latency assumption、liquidity role 和 MTP-27 fixed execution cost assumptions。
- `PartialFillLatencyFeeSlippageParityModel.evaluate` 必须在 available simulated liquidity 小于 order quantity 时输出 partial fill / remaining quantity evidence，在 available simulated liquidity 等于 order quantity 时输出 full fill evidence。
- Latency evidence 必须由 replay record sequence 和 fixed tick offset 推导，默认 `2 -> 3`、`250ms`；不得使用 wall clock、randomness、真实网络、exchange latency 或 broker SLA。
- Fee / slippage evidence 必须复用 `ExecutionCostAssumptions.deterministicFixture` 和 `ExecutionCostParity.verify`，证明 Backtest / Paper 两侧 assumption、输入、fee amount、slippage amount、total cost 和 rounding scale 一致。
- `PartialFillLatencyFeeSlippageParityReportEvidence.deterministicResultIdentity` 必须固定 scenario id、dataset version、fixture version、window、cursor sequence、record sequence、order id、order type、available liquidity、latency assumption、liquidity role、cost assumption、fill completion、latency output、filled quantity、remaining quantity、fee、slippage 和 total cost。
- Core fixture 和 Codable decode 必须拒绝真实费率表、动态滑点模型、真实流动性消耗、执行成本优化、signed endpoint、account endpoint、listenKey、broker fill、execution report、reconciliation、`LiveExecutionAdapter`、OMS、portfolio projection runtime、live command、order-level command UI 和交易按钮绕过。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-114 focused tests，验证 contract anchors、partial fill evidence、full fill evidence、latency evidence、fee / slippage parity、deterministic identity、Codable round-trip 和 forbidden capability rejection。
- `docs/domain/context.md` 必须包含 `MTP-114-PARTIAL-FULL-FILL-PARITY`、`MTP-114-DETERMINISTIC-LATENCY-MODEL`、`MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`、`MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE` 和 `MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-114 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-114 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-114 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现完整交易所费率表、动态滑点模型、真实流动性消耗、执行成本优化、portfolio projection runtime、Report / Dashboard / Events evidence surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-114 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-114-PARTIAL-FULL-FILL-PARITY`
- `MTP-114-DETERMINISTIC-LATENCY-MODEL`
- `MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`
- `MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE`
- `MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION`
- `MTP-114-PARTIAL-FILL-LATENCY-FEE-SLIPPAGE-VALIDATION`

## MTP-114 禁止

- 不实现完整交易所费率表、动态滑点模型、真实流动性消耗、执行成本优化、真实 order execution runtime、matching runtime、portfolio projection runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不把 fee / slippage parity 写成 live fee schedule、真实成交成本、真实成交质量分析、broker fee statement、live readiness 或 production execution optimizer。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-115 Simulated Exchange Portfolio Projection Parity Validation

日期：2026-05-26

执行者：Codex

MTP-115 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`、`MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`、`MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`、`MTP-115-REPORT-INPUT-REPLAY-EVIDENCE`、`MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE` 和 `MTP-115-SIMULATED-EXCHANGE-PORTFOLIO-PROJECTION-VALIDATION` anchors。
- `Sources/Core/SimulatedExchangePortfolioProjectionParity.swift` 必须定义 `SimulatedExchangePortfolioProjectionParityContract`、`SimulatedExchangePortfolioProjectionParityInput`、`SimulatedExchangePortfolioProjectionSnapshot`、`SimulatedExchangePortfolioProjectionParityEvidence`、`SimulatedExchangePortfolioProjectionParityModel`、`SimulatedExchangePortfolioProjectionRule`、`SimulatedExchangePortfolioProjectionMode`、`SimulatedExchangePortfolioProjectionForbiddenCapability` 和 `SimulatedExchangePortfolioProjectionParityFixture`。
- `SimulatedExchangePortfolioProjectionParityInput` 必须消费 MTP-114 `PartialFillLatencyFeeSlippageParityReportEvidence`，绑定 MTP-107 `ScenarioReportInputVersion` 和 source replay sequence `3`；不得读取真实账户、broker position、margin、leverage、Runtime object 或 persistence schema。
- `SimulatedExchangePortfolioProjectionParityModel.project` 必须从同一个 simulated exchange parity event 同时生成 backtest 与 paper projection，并保证两侧 `parityComparableIdentity` 一致。
- Projection snapshot 必须输出 position、cash、available simulated cash、equity、gross exposure、realized / unrealized / net simulated PnL 和 `PortfolioExposureSnapshot`；默认 partial fixture 必须固定 cash `39462.98038625`、equity `49993.15538625`、gross exposure `10530.175` 和 net simulated PnL `-6.84461375`。
- Core fixture 和 Codable decode 必须拒绝 real account balance read / sync、broker position read、margin read、leverage read、broker reconciliation、signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、live runtime、live command、order-level command UI、trading button、database schema exposure、runtime object read 和 network validation 绕过。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-115 focused tests，验证 contract anchors、report input / replay evidence、backtest / paper portfolio parity、position / cash / PnL / exposure numeric summary、full / partial fixtures、Codable round-trip 和 forbidden capability rejection。
- `docs/domain/context.md` 必须包含 `MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`、`MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`、`MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`、`MTP-115-REPORT-INPUT-REPLAY-EVIDENCE` 和 `MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-115 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-115 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-115 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 portfolio projection runtime、Report / Dashboard / Events evidence surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-115 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`
- `MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`
- `MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`
- `MTP-115-REPORT-INPUT-REPLAY-EVIDENCE`
- `MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`
- `MTP-115-SIMULATED-EXCHANGE-PORTFOLIO-PROJECTION-VALIDATION`

## MTP-115 禁止

- 不实现 portfolio projection runtime、真实 order execution runtime、matching runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、real account balance sync、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不把 simulated portfolio projection 写成真实账户资产、broker statement、margin / leverage、live readiness、production account reconciliation 或 trading command state。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-116 Report / Dashboard / Events Parity Evidence Surface Validation

日期：2026-05-26

执行者：Codex

MTP-116 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-116-PARITY-EVIDENCE-READ-MODEL`、`MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE`、`MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT`、`MTP-116-READ-MODEL-ONLY-NO-COMMAND-SURFACE`、`MTP-116-NO-LIVE-BROKER-SIGNED-ENDPOINT` 和 `MTP-116-SIMULATED-EXCHANGE-PARITY-SURFACE-VALIDATION` anchors。
- `Sources/App/SimulatedExchangeParityEvidenceSurface.swift` 必须定义 `SimulatedExchangeParityEvidenceItem`、`SimulatedExchangeParityEvidenceReadModel`、`SimulatedExchangeParityEvidenceViewModel` 和 timeline entry，且只消费 MTP-112 至 MTP-115 deterministic Core evidence。
- Report ViewModel 必须展示 scenario id、dataset / fixture version、replay window、matching result、matching event、order id / type、partial / full / reject / expire outcomes、latency、fee、slippage、portfolio projection parity、report input version identity、source replay sequence 和 read-model-only boundary flags。
- Dashboard / Workbench 必须展示 parity evidence、outcomes、timeline、portfolio parity、cost parity metrics 和 no-command/no-trading/no-schema/no-runtime/no-adapter details。
- Events / Evidence Explorer 必须新增 `simulated exchange parity evidence` 只读 section，并输出 scenario、matching、fill summary、reject / expire、latency / cost、portfolio parity、report input / replay consistency timeline rows。
- App tests 必须覆盖 Report / Dashboard / Events wiring、Dashboard smoke `simulatedParityEvidence=1`、focused MTP-116 deterministic field snapshot、Codable round-trip、read-model-only boundary、无 command surface、无 order-level command UI、无交易按钮、无 signed endpoint / account endpoint / listenKey / broker / live capability。
- `docs/domain/context.md` 必须包含 `MTP-116-PARITY-EVIDENCE-READ-MODEL`、`MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE`、`MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT`、`MTP-116-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-116-NO-LIVE-BROKER-SIGNED-ENDPOINT`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-116 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-116 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-116 contract、matrix、validation plan、domain context、latest summary、App source、Dashboard / Events source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 matching runtime、order execution runtime、portfolio projection runtime、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console、order-level command UI 或交易按钮。

MTP-116 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-116-PARITY-EVIDENCE-READ-MODEL`
- `MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE`
- `MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT`
- `MTP-116-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-116-NO-LIVE-BROKER-SIGNED-ENDPOINT`
- `MTP-116-SIMULATED-EXCHANGE-PARITY-SURFACE-VALIDATION`

## MTP-116 禁止

- 不实现 matching runtime、order execution runtime、portfolio projection runtime、真实 order command、order form、command model、Runtime replay job、database console 或 schema browser。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-117 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-27

执行者：Codex

MTP-117 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-CLOSEOUT`、`MTP-117-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-117-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-AUDIT-INPUT`、`MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION-EVIDENCE-CHAIN`、`MTP-117-FORBIDDEN-LIVE-CAPABILITY-EVIDENCE-CHAIN`、`MTP-117-L2-PARITY-EVIDENCE-COMPLETE` 和 `MTP-117-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/audit/inputs/mtpro-simulated-exchange-backtest-parity-v1-stage-audit-input.md` 必须记录 MTP-110 至 MTP-116 的 PR evidence、merge commit、required check、L2 parity validation evidence chain、forbidden live capability evidence chain、read-model-only boundary evidence、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-117 的当前 issue execution evidence，并明确 MTP-117 只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口，不输出最终 Stage Code Audit Report。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-117 issue backfill 和 MTP-117 Simulated Exchange / Backtest Parity 阶段收口说明，并指向 MTP-117 Stage Code Audit 输入材料。
- `docs/automation/automation-readiness.md` 必须新增 Simulated Exchange / Backtest Parity stage audit input anchor，确认该输入材料是 automation readiness 的已验证入口之一。
- `checks/automation-readiness.sh` 必须机械检查 MTP-110 至 MTP-117 的 contract、matrix、validation plan、latest summary、stage audit input、Core / App source anchors、Core / App deterministic test anchors、Dashboard smoke `simulatedParityEvidence` handle 和 forbidden capability boundary strings。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不输出最终 Stage Code Audit Report，不实现 signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console、order-level command UI 或交易按钮。

MTP-117 必须收口的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-CLOSEOUT`
- `MTP-117-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-117-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-AUDIT-INPUT`
- `MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION-EVIDENCE-CHAIN`
- `MTP-117-FORBIDDEN-LIVE-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-117-L2-PARITY-EVIDENCE-COMPLETE`
- `MTP-117-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-117 禁止

- 不输出最终 Stage Code Audit Report，不创建 `docs/audit/mtpro-simulated-exchange-backtest-parity-v1-stage-code-audit.md`。
- 不设置 Linear Project `Completed`，不修改 Linear status，不创建下一 Project / Issue，不推进下一阶段。
- 不实现 matching runtime、order execution runtime、portfolio projection runtime、真实 order command、order form、command model、Runtime replay job、database console 或 schema browser。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不运行 Graphify，不修改 Figma。

## MTP-118 Workbench Beta Readiness Contract / Acceptance Boundary Validation

日期：2026-05-27

执行者：Codex

MTP-118 的 required validation：

- `docs/contracts/workbench-beta-readiness-contract.md` 必须包含 `MTP-118-WORKBENCH-BETA-READINESS-TERMINOLOGY`、`MTP-118-BETA-ACCEPTANCE-BOUNDARY`、`MTP-118-LOCAL-ONLY-BETA-DEMO-PATH`、`MTP-118-L1-L15-L2-L2PLUS-HANDOFF`、`MTP-118-FORBIDDEN-CAPABILITY-BASELINE`、`MTP-118-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION` 和 `MTP-118-WORKBENCH-BETA-READINESS-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 Workbench Beta Readiness Terms 和 MTP-118 anchors，明确 beta readiness 是 local macOS Workbench demo / acceptance path，不是 production release 或 live readiness。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-WORKBENCH-BETA-READINESS` 和 MTP-118 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-118 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Workbench Beta Readiness contract anchor，确认 MTP-118 只是合同 / 边界入口，不实现 install / run、engine core、production release 或 live readiness。
- `checks/automation-readiness.sh` 必须机械检查 MTP-118 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不启动下一 issue，不运行 Graphify，不修改 Figma，不实现 install / run 逻辑，不新增 engine core capability，不实现 production release、notarization、App Store distribution、auto-update、production operations、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button 或 live command。

MTP-118 必须建立的主要 anchors：

- `TVM-WORKBENCH-BETA-READINESS`
- `MTP-118-WORKBENCH-BETA-READINESS-TERMINOLOGY`
- `MTP-118-BETA-ACCEPTANCE-BOUNDARY`
- `MTP-118-LOCAL-ONLY-BETA-DEMO-PATH`
- `MTP-118-L1-L15-L2-L2PLUS-HANDOFF`
- `MTP-118-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-118-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-118-WORKBENCH-BETA-READINESS-VALIDATION`

## MTP-118 禁止

- 不实现 install / run 逻辑、release package、production release、notarization、App Store distribution、auto-update、production operations、Core / Runtime / App / Dashboard behavior、Dashboard smoke handle、App read model 或 stage audit input。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不把 Workbench beta readiness 写成 production release、live readiness、production trading engine、production data platform、production matching runtime、真实 exchange runtime、broker / OMS readiness 或真实交易授权。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-119。

## MTP-119 Local Launch / Install / Environment Verification Validation

日期：2026-05-27

执行者：Codex

MTP-119 的 required validation：

- `docs/contracts/workbench-beta-readiness-contract.md` 必须包含 `MTP-119-LOCAL-LAUNCH-INSTALL-ENVIRONMENT-PATH`、`MTP-119-LOCAL-ENVIRONMENT-VERIFICATION`、`MTP-119-LOCAL-INSTALL-RUN-NOTES`、`MTP-119-LAUNCH-COMMAND-RUNBOOK`、`MTP-119-DASHBOARD-SMOKE-EXPECTATION`、`MTP-119-REPRODUCIBLE-LAUNCH-EVIDENCE`、`MTP-119-TROUBLESHOOTING-BOUNDARY` 和 `MTP-119-LOCAL-LAUNCH-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-119 local launch / install terms，明确 local install 只表示 SwiftPM dependency resolution 和本地 `.build` artifact。
- `docs/validation/macos-build-run-loop.md` 必须包含 MTP-119 local beta launch / install / environment verification path、Dashboard smoke expectation 和 troubleshooting boundary。
- `docs/validation/trading-validation-matrix.md` 必须包含 `MTP-119` issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-119 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须包含 Workbench Beta Readiness local launch / install anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-119 contract、domain context、macOS run-loop、validation plan、matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- Required validation 仍是 `bash checks/run.sh`，并补充 focused local smoke `DASHBOARD_SMOKE=1 swift run Dashboard` 作为 MTP-119 launch path evidence。

MTP-119 必须建立的主要 anchors：

- `MTP-119-LOCAL-LAUNCH-INSTALL-ENVIRONMENT-PATH`
- `MTP-119-LOCAL-ENVIRONMENT-VERIFICATION`
- `MTP-119-LOCAL-INSTALL-RUN-NOTES`
- `MTP-119-LAUNCH-COMMAND-RUNBOOK`
- `MTP-119-DASHBOARD-SMOKE-EXPECTATION`
- `MTP-119-REPRODUCIBLE-LAUNCH-EVIDENCE`
- `MTP-119-TROUBLESHOOTING-BOUNDARY`
- `MTP-119-LOCAL-LAUNCH-VALIDATION`

## MTP-119 禁止

- 不创建 production installer、release package、notarized artifact、App Store build、auto-update channel、production deployment 或 cloud operations workflow。
- 不新增 Dashboard smoke handle、不新增 App read model、不新增 Core / Runtime / Dashboard behavior、不新增 engine core capability、不新增 stage audit input。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不把 local launch / install path 写成 production release pipeline、notarization readiness、App Store distribution readiness、cloud operations readiness、live readiness 或真实交易授权。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-120。

## MTP-120 Demo Scenario Selection / Fixture Wiring Validation

日期：2026-05-27

执行者：Codex

MTP-120 的 required validation：

- `swift test --filter MTP120`
- `bash checks/run.sh`

MTP-120 必须建立的主要 anchors：

- `MTP-120-DEMO-SCENARIO-SELECTION`
- `MTP-120-DATASET-FIXTURE-VERSION-LOCK`
- `MTP-120-SCENARIO-REPLAY-FIXTURE-WIRING`
- `MTP-120-CHECKSUM-FRESHNESS-EVIDENCE`
- `MTP-120-L15-L2-EVIDENCE-RELATIONSHIP`
- `MTP-120-NO-NETWORK-DOWNLOAD-LIVE-BROKER`
- `MTP-120-DEMO-SCENARIO-FIXTURE-VALIDATION`

MTP-120 的验收要求：

- `Sources/Core/WorkbenchBetaDemoScenario.swift` 必须定义 `WorkbenchBetaDemoScenarioSelection` 和 `WorkbenchBetaDemoFixtureEvidence`，固定 `mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`。
- `WorkbenchBetaDemoFixtureEvidence` 必须复用 `ScenarioDataQualityReportInputEvidence.deterministicFixture` 和 `SimulatedExchangePortfolioProjectionParityFixture.deterministicEvidence()`，并输出 checksum `fnv1a64:3c6cd4ff13cd4062`、freshness `fresh`、quality `accepted`、report input version identity 和 simulated parity deterministic identity。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-120 focused tests，覆盖 deterministic selection、fixture wiring、L1.5 / L2 relationship、Codable round-trip、scenario mismatch rejection、automatic download / signed endpoint / broker bypass rejection。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-120 mechanical anchors。

## MTP-120 禁止

- 不新增 fixture records、不新增大规模 ingestion、不自动下载真实历史数据、不实现 production data platform、production dataset registry、production data quality monitor 或 Runtime replay scheduler。
- 不提前实现 Workbench first-run state、Report / Dashboard / Events acceptance path、Dashboard smoke handle、App read model、Runtime / Dashboard behavior 或 stage audit input。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-121。

## MTP-121 Workbench First-Run / Default Demo State Validation

日期：2026-05-27

执行者：Codex

MTP-121 的 required validation：

- `swift test --filter MTP121`
- `DASHBOARD_SMOKE=1 swift run Dashboard`
- `bash checks/run.sh`

MTP-121 必须建立的主要 anchors：

- `MTP-121-DEFAULT-SELECTED-SCENARIO`
- `MTP-121-READ-MODEL-ONLY-DASHBOARD-STATE`
- `MTP-121-FIRST-RUN-FALLBACK-STATES`
- `MTP-121-FIRST-RUN-EVIDENCE-SUMMARY`
- `MTP-121-DEMO-FIXTURE-ALIGNMENT`
- `MTP-121-NO-LIVE-PRO-CONSOLE-TRADING-COMMAND`
- `MTP-121-DASHBOARD-SMOKE-DEFAULT-DEMO-VALIDATION`

MTP-121 的验收要求：

- `Sources/App/WorkbenchBetaFirstRunState.swift` 必须定义 `WorkbenchBetaFirstRunReadModel`、`WorkbenchBetaFirstRunViewModel`、`WorkbenchBetaFirstRunEvidenceSummary` 和 `WorkbenchBetaFirstRunFallbackState`。
- First-run 默认状态必须选择 `mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`，并输出 checksum `fnv1a64:3c6cd4ff13cd4062`、freshness `fresh`、quality `accepted` 和 report input version identity。
- `DashboardReadModel.defaultWorkbenchBetaDemo` 和 `DashboardViewModel.defaultWorkbenchBetaDemo` 必须通过 App Read Model / ViewModel 提供 first-run state，不直接暴露 Core fixture、Persistence schema、Runtime object 或 Adapter request。
- `Sources/Dashboard/DashboardApplication.swift` 必须使用 `DashboardViewModel.defaultWorkbenchBetaDemo`，使 `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 `defaultDemoState=default demo`、`defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaFirstRunFallbacks=3`、`scenarioReplayEvidence=1` 和 `simulatedParityEvidence=1`。
- `Tests/AppTests/AppTests.swift` 必须包含 MTP-121 focused tests，覆盖 default selected scenario、read-model-only Dashboard state、empty / loading / error fallback、first-run evidence summary、Dashboard smoke handles 和 forbidden capability flags。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-121 mechanical anchors。

## MTP-121 禁止

- 不重设计 UI、不新增完整页面 redesign、不新增 MTP-122 Report / Dashboard / Events acceptance path、不新增 stage audit input。
- 不新增 fixture records、不新增大规模 ingestion、不自动下载真实历史数据、不实现 production data platform、production dataset registry、production data quality monitor 或 Runtime replay scheduler。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-122。

## MTP-122 Report / Dashboard / Events Beta Acceptance Path Validation

日期：2026-05-27

执行者：Codex

MTP-122 的 required validation：

- `swift test --filter MTP122`
- `DASHBOARD_SMOKE=1 swift run Dashboard`
- `bash checks/run.sh`

MTP-122 必须建立的主要 anchors：

- `MTP-122-REPORT-BETA-ACCEPTANCE-SUMMARY`
- `MTP-122-DASHBOARD-BETA-EVIDENCE-PANELS`
- `MTP-122-EVENTS-BETA-ACCEPTANCE-TRACE`
- `MTP-122-SAME-DEMO-SCENARIO-EVIDENCE`
- `MTP-122-SCENARIO-PARITY-PORTFOLIO-TRACE`
- `MTP-122-READ-MODEL-ONLY-NO-RUNTIME-COMMAND`
- `MTP-122-BETA-ACCEPTANCE-PATH-VALIDATION`

MTP-122 的验收要求：

- `Sources/App/WorkbenchBetaAcceptancePath.swift` 必须定义 `WorkbenchBetaAcceptancePathReadModel` 和 `WorkbenchBetaAcceptancePathViewModel`，只从 `ReportReadModel` 与 `WorkbenchBetaFirstRunReadModel.defaultDemo` 生成 acceptance path。
- Acceptance path 必须证明 Report、Dashboard 和 Events 使用同一 scenario `mtp-104-btcusdt-1m-first-scenario`、dataset `dataset-v1`、fixture `fixture-v1`、report input version `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted`。
- `DashboardViewModel.defaultWorkbenchBetaDemo` 必须输出 `workbenchBetaAcceptancePath.acceptancePathCount=1`、Report summary、Dashboard panel summaries、Events trace 和 portfolio projection parity evidence。
- `Sources/App/PaperWorkflowEvidenceExplorer.swift` 必须新增 `workbench beta acceptance path` section，输出 Report summary、Scenario Replay evidence、Simulated Exchange / Backtest Parity evidence、Portfolio evidence 和 boundary summary 五条 timeline rows。
- `Sources/App/DashboardShell.swift` 必须输出 Dashboard smoke handles `betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。
- `Tests/AppTests/AppTests.swift` 必须包含 MTP-122 focused test，覆盖 Report summary、Dashboard panels、Events trace、same demo scenario、portfolio evidence、validation anchors 和 forbidden capability flags。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-122 mechanical anchors。

## MTP-122 禁止

- 不新增 engine core capability、Runtime replay job、matching runtime、order execution runtime、portfolio projection runtime 或 production report engine。
- 不暴露 Persistence schema、database console、Runtime object inspector、Adapter request、Core object inspector 或 query surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不新增 stage audit input，不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-123。

## MTP-123 Reproducible Beta Acceptance Checklist / Script Validation

日期：2026-05-27

执行者：Codex

MTP-123 的 required validation：

- `bash checks/workbench-beta-acceptance.sh`
- `bash checks/run.sh`

MTP-123 必须建立的主要 anchors：

- `MTP-123-REPRODUCIBLE-BETA-ACCEPTANCE-WORKFLOW`
- `MTP-123-BETA-ACCEPTANCE-CHECKLIST`
- `MTP-123-LOCAL-COMMANDS-EXPECTED-OUTPUTS`
- `MTP-123-OPERATOR-REPRODUCIBILITY-EVIDENCE`
- `MTP-123-FAILURE-TRIAGE-HINTS`
- `MTP-123-NO-GRAPHIFY-FIGMA-PRODUCTION-OPS`
- `MTP-123-BETA-ACCEPTANCE-SCRIPT-VALIDATION`

MTP-123 的验收要求：

- `checks/workbench-beta-acceptance.sh` 必须复用现有 local commands：`uname -s`、`swift --version`、`swift package resolve`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `bash checks/run.sh`。
- `docs/validation/workbench-beta-acceptance-checklist.md` 必须记录 operator checklist、local commands、expected outputs、operator reproducibility evidence、failure triage hints 和 boundary evidence。
- Script 必须校验 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。
- Script 必须把 transcript 写入 `.codex/beta-acceptance/<run-id>/`，且这些本地 evidence 不进入 PR。
- `bash checks/run.sh` 仍是 PR 前最终 gate；MTP-123 script 不替代 CI 或 GitHub required check。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-123 mechanical anchors。

## MTP-123 禁止

- 不新增 engine core capability、Runtime replay job、matching runtime、order execution runtime、portfolio projection runtime、App read model 或 Dashboard behavior。
- 不暴露 Persistence schema、database console、Runtime object inspector、Adapter request、Core object inspector 或 query surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不新增 stage audit input，不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-124。

## MTP-124 Docs Index / Operator Guide Validation

日期：2026-05-27

执行者：Codex

MTP-124 的 required validation：

- `bash checks/run.sh`

MTP-124 必须建立的主要 anchors：

- `MTP-124-DOCS-INDEX`
- `MTP-124-OPERATOR-GUIDE`
- `MTP-124-DEMO-WORKFLOW-GUIDE`
- `MTP-124-KNOWN-LIMITATIONS`
- `MTP-124-FORBIDDEN-CAPABILITY-BOUNDARY`
- `MTP-124-TROUBLESHOOTING-POINTERS`
- `MTP-124-BETA-NOT-LIVE-READINESS`
- `MTP-124-ACCEPTANCE-WORKFLOW-REFERENCE`
- `MTP-124-DOCS-OPERATOR-GUIDE-VALIDATION`

MTP-124 的验收要求：

- `docs/index.md` 必须作为 docs index，指向 root docs、Workbench Beta Readiness operator guide、demo workflow guide、MTP-123 acceptance checklist / script 和 required validation。
- `docs/validation/workbench-beta-operator-guide.md` 必须记录 operator quick path、manual runbook、expected smoke handles、known limitations、forbidden capabilities、troubleshooting pointers 和 handoff evidence。
- `docs/validation/workbench-beta-demo-workflow-guide.md` 必须记录 MTP-119 至 MTP-123 demo workflow map、stable demo identity、evidence chain、operator demo steps、known limitations、forbidden boundary 和 troubleshooting pointers。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-124 mechanical anchors。
- Validation 必须证明 docs anchor、boundary text 和 acceptance workflow 引用完整，且文档不授权 production release、Live PRO Console、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、trading button 或 live command。

## MTP-124 禁止

- 不写 marketing landing page、不写 Live PRO Console docs、不写 production deployment guide、不写 notarization / App Store / auto-update guide。
- 不新增 production code、不新增 engine core capability、不新增 Runtime replay job、不新增 App read model、不新增 Dashboard behavior。
- 不新增 stage audit input；Project stage closeout 仍归属 MTP-125。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-125。

## MTP-125 Automation Readiness / Validation Evidence / Stage Audit Input Validation

日期：2026-05-27

执行者：Codex

MTP-125 的 required validation：

- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-125 必须建立的主要 anchors：

- `MTP-125-WORKBENCH-BETA-READINESS-STAGE-CLOSEOUT`
- `MTP-125-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-125-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-125-WORKBENCH-BETA-READINESS-STAGE-AUDIT-INPUT`
- `MTP-125-WORKBENCH-BETA-READINESS-VALIDATION-EVIDENCE-CHAIN`
- `MTP-125-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-125-BETA-READINESS-EVIDENCE-COMPLETE`
- `MTP-125-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-125-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`
- `MTP-125-WORKBENCH-BETA-READINESS-CLOSEOUT-VALIDATION`

MTP-125 的验收要求：

- `docs/audit/inputs/mtpro-workbench-beta-readiness-v1-stage-audit-input.md` 必须存在，并包含 Linear queue evidence、PR #222 至 #228 evidence、merge commit、required check、Workbench Beta Readiness validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/contracts/workbench-beta-readiness-contract.md` 必须包含 MTP-125 closeout anchors，并明确 MTP-125 只准备 stage audit input material，不输出最终 Stage Code Audit Report。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-125 issue backfill，指向 `TVM-WORKBENCH-BETA-READINESS` 并说明 MTP-125 收口 validation matrix、automation readiness 和 stage audit input material。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-125 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Workbench Beta Readiness stage audit input anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-125 stage audit input、contract、validation plan、matrix、latest summary、automation readiness doc、PR evidence、Dashboard smoke handles 和 no Graphify / Figma / Linear mutation boundary。
- `verification.md` 必须 append-only 记录本地 validation result。

## MTP-125 禁止

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。
- 不修改 Linear status、不创建 Linear Project / Issue、不启动 `@002 / PAR`、不启动 Symphony / symphony-issue、不推进下一阶段。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不新增 production code、不新增 engine core capability、不新增 Runtime replay job、不新增 App read model、不新增 Dashboard behavior。
- 不创建 production release、release package、notarization、App Store distribution、auto-update、production deployment、cloud operations 或 production operations command。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、real PnL、live readiness、live runtime、Live PRO Console、trading button、live command、order-level command UI、order form、emergency stop、shutdown 或 restore。

## MTP-126 Live Read-only Readiness Terminology / Boundary Validation

日期：2026-05-27

执行者：Codex

MTP-126 的 required validation：

- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-126 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY`、`MTP-126-TARGET-ENGINE-LAYER-BOUNDARY`、`MTP-126-L30-L31-L32-L33-HANDOFF`、`MTP-126-FORBIDDEN-CAPABILITY-BASELINE`、`MTP-126-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION` 和 `MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 Live read-only readiness terms 和 MTP-126 anchors，明确 L3.0 只定义 boundary，不实现 endpoint、secret、adapter、account read model、UI 或 live runtime。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-READ-ONLY-READINESS` 和 MTP-126 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-126 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only Readiness contract anchor，确认 MTP-126 只是合同 / 边界入口，不实现 L3.1 / L3.2 / L3.3 内容。
- `checks/automation-readiness.sh` 必须机械检查 MTP-126 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。

MTP-126 必须建立的主要 anchors：

- `TVM-LIVE-READ-ONLY-READINESS`
- `MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY`
- `MTP-126-TARGET-ENGINE-LAYER-BOUNDARY`
- `MTP-126-L30-L31-L32-L33-HANDOFF`
- `MTP-126-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-126-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION`

## MTP-126 禁止

- 不实现 API key / secret storage，不读取本地 secret。
- 不实现 signed endpoint、account endpoint、listenKey、private WebSocket runtime 或 account snapshot runtime。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不读取 real account、broker position、margin、leverage、real PnL 或 equity。
- 不实现 account / position / balance read model、Live Monitoring Console v2、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-127。

## MTP-127 Credential / Secret Policy and Endpoint Capability Taxonomy Validation

日期：2026-05-27

执行者：Codex

MTP-127 的 required validation：

- `swift test --filter LiveReadOnlyCredentialEndpointTaxonomy`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-127 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-127-CREDENTIAL-SECRET-POLICY-FUTURE-GATE`、`MTP-127-ENDPOINT-CAPABILITY-TAXONOMY`、`MTP-127-PUBLIC-READ-ONLY-PRIVATE-ENDPOINT-ISOLATION`、`MTP-127-FORBIDDEN-CAPABILITY-TESTS` 和 `MTP-127-LIVE-READ-ONLY-CREDENTIAL-ENDPOINT-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyCredentialEndpointTaxonomyBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、public read-only 唯一 allowed capability 和 forbidden endpoint taxonomy。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyCredentialEndpointTaxonomyDefinesMTP127FutureGates` 和 `testLiveReadOnlyCredentialEndpointTaxonomyRejectsSecretEndpointAndBrokerBypass`。
- `docs/domain/context.md` 必须包含 MTP-127 credential / endpoint taxonomy terms，明确 no secret read、no API key / secret storage、no signed/account/listenKey/private websocket/broker action。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-127 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-127 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only credential / endpoint taxonomy anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-127 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-127 必须建立的主要 anchors：

- `MTP-127-CREDENTIAL-SECRET-POLICY-FUTURE-GATE`
- `MTP-127-ENDPOINT-CAPABILITY-TAXONOMY`
- `MTP-127-PUBLIC-READ-ONLY-PRIVATE-ENDPOINT-ISOLATION`
- `MTP-127-FORBIDDEN-CAPABILITY-TESTS`
- `MTP-127-LIVE-READ-ONLY-CREDENTIAL-ENDPOINT-VALIDATION`

## MTP-127 禁止

- 不实现 API key / secret storage，不读取本地 secret。
- 不新增 env / keychain / config secret path，不实现 credential provider runtime。
- 不实现 signed request、signed endpoint、account endpoint、listenKey、private WebSocket runtime 或 account snapshot runtime。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`，不执行 broker action。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 account / position / balance read model、Live Monitoring Console v2、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-128。

## MTP-128 Adapter Capability Matrix Validation

日期：2026-05-27

执行者：Codex

MTP-128 的 required validation：

- `swift test --filter LiveReadOnlyAdapterCapabilityMatrix`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-128 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-128-ADAPTER-CAPABILITY-MATRIX`、`MTP-128-PUBLIC-READ-ONLY-ADAPTER-PRIVATE-GATE-ISOLATION`、`MTP-128-FORBIDDEN-ADAPTER-CAPABILITY-TESTS` 和 `MTP-128-LIVE-READ-ONLY-ADAPTER-CAPABILITY-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyAdapterCapabilityMatrixBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、public market data 唯一 allowed capability、future private account read-only gated capability 和 forbidden adapter capability matrix。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyAdapterCapabilityMatrixDefinesMTP128ReadOnlyBoundary` 和 `testLiveReadOnlyAdapterCapabilityMatrixRejectsWriteAndExecutionAdapterBypass`。
- `docs/domain/context.md` 必须包含 MTP-128 adapter matrix terms，明确 public read-only adapter 不能升级为 broker / exchange execution adapter。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-128 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-128 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only adapter capability matrix anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-128 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-128 必须建立的主要 anchors：

- `MTP-128-ADAPTER-CAPABILITY-MATRIX`
- `MTP-128-PUBLIC-READ-ONLY-ADAPTER-PRIVATE-GATE-ISOLATION`
- `MTP-128-FORBIDDEN-ADAPTER-CAPABILITY-TESTS`
- `MTP-128-LIVE-READ-ONLY-ADAPTER-CAPABILITY-VALIDATION`

## MTP-128 禁止

- 不创建 broker adapter、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不把 public adapter 升级为 execution adapter。
- 不实现 signed endpoint、account endpoint / listenKey 或 private account read runtime。
- 不实现 real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 real account / broker position / margin / leverage runtime。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-129。

## MTP-129 Account / Position / Balance Read-model-only Future Gates Validation

日期：2026-05-27

执行者：Codex

MTP-129 的 required validation：

- `swift test --filter LiveReadOnlyAccountPositionBalance`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-129 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-129-ACCOUNT-POSITION-BALANCE-FUTURE-GATES`、`MTP-129-SOURCE-FRESHNESS-EVIDENCE-IDENTITY-BOUNDARY`、`MTP-129-FORBIDDEN-ACCOUNT-DATA-INTERPRETATION-TESTS` 和 `MTP-129-LIVE-READ-ONLY-ACCOUNT-POSITION-BALANCE-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyAccountPositionBalanceFutureGateBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、account / position / balance read-model-only future gates、source identity、snapshot freshness、evidence identity 和 forbidden account-data interpretation tests。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyAccountPositionBalanceFutureGatesDefineMTP129Boundary` 和 `testLiveReadOnlyAccountPositionBalanceFutureGatesRejectRealAccountAndFixtureBypass`。
- `docs/domain/context.md` 必须包含 MTP-129 account / position / balance shared language，明确 paper / simulated / fixture evidence 不能被解释为 real account data。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-129 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-129 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only account / position / balance future gate anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-129 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-129 必须建立的主要 anchors：

- `MTP-129-ACCOUNT-POSITION-BALANCE-FUTURE-GATES`
- `MTP-129-SOURCE-FRESHNESS-EVIDENCE-IDENTITY-BOUNDARY`
- `MTP-129-FORBIDDEN-ACCOUNT-DATA-INTERPRETATION-TESTS`
- `MTP-129-LIVE-READ-ONLY-ACCOUNT-POSITION-BALANCE-VALIDATION`

## MTP-129 禁止

- 不实现 account / position / balance read model runtime。
- 不读取 real account，不同步 broker position，不读取 real account balance、margin、leverage 或 real PnL。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket 或 account snapshot runtime。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、trading button 或 live command。
- 不把 paper portfolio、simulated fill、fixture evidence、Report read model 或 Dashboard ViewModel 解释为真实 account / position / balance data。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-130。

## MTP-130 Private Stream / Account Snapshot Simulation Gate Input Validation

日期：2026-05-27

执行者：Codex

MTP-130 的 required validation：

- `swift test --filter LiveReadOnlyPrivateStreamAccountSnapshot`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-130 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-130-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE`、`MTP-130-FUTURE-FIXTURE-REQUIREMENTS`、`MTP-130-SIMULATION-GATE-LIVE-STREAM-ISOLATION`、`MTP-130-LISTENKEY-FORBIDDEN-TESTS` 和 `MTP-130-LIVE-READ-ONLY-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、private stream / account snapshot simulation gate input material、future fixture requirements、listenKey forbidden tests 和 simulation gate / live stream isolation。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyPrivateStreamAccountSnapshotDefinesMTP130SimulationGateInput` 和 `testLiveReadOnlyPrivateStreamAccountSnapshotRejectsListenKeyAndRuntimeBypass`。
- `docs/domain/context.md` 必须包含 MTP-130 private stream / account snapshot simulation gate shared language，明确 simulation gate input material 不能被解释为 live private stream implementation。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-130 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-130 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only private stream / account snapshot simulation gate anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-130 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-130 必须建立的主要 anchors：

- `MTP-130-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE`
- `MTP-130-FUTURE-FIXTURE-REQUIREMENTS`
- `MTP-130-SIMULATION-GATE-LIVE-STREAM-ISOLATION`
- `MTP-130-LISTENKEY-FORBIDDEN-TESTS`
- `MTP-130-LIVE-READ-ONLY-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-VALIDATION`

## MTP-130 禁止

- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不运行 account snapshot runtime，不读取 real account 或 consumes real account payload。
- 不调用 signed endpoint、account endpoint / listenKey。
- 不同步 broker position，不读取 margin / leverage。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS 或 real order write。
- 不把 simulation gate input material 写成 live private stream implementation。
- 不把 fixture account snapshot 写成真实 account snapshot。
- 不新增 Live PRO Console、trading button 或 live command。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-131。

## MTP-131 Workbench Live Readiness Read-model-only Boundary Validation

日期：2026-05-27

执行者：Codex

MTP-131 的 required validation：

- `swift test --filter LiveReadOnlyWorkbench`
- `swift test --filter AppTests/testLiveReadOnlyWorkbenchBoundaryViewModelAggregatesMTP131ReadOnlySurface`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-131 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY`、`MTP-131-READ-MODEL-VIEWMODEL-INPUT-BOUNDARY`、`MTP-131-FORBIDDEN-UI-SURFACE`、`MTP-131-DETAIL-AUDIT-ROUTING`、`MTP-131-L31-L32-L33-HANDOFF` 和 `MTP-131-LIVE-READ-ONLY-WORKBENCH-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyWorkbenchReadModelBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、Workbench boundary surfaces、ReadModel / ViewModel input boundary、forbidden UI surface、detail / audit route、L3 handoff 和 forbidden flags。
- `Sources/App/LiveReadOnlyWorkbenchBoundary.swift` 必须包含 `LiveReadOnlyWorkbenchBoundaryReadModel` 和 `LiveReadOnlyWorkbenchBoundaryViewModel`，只输出 read-model-only Dashboard / Report / Event Timeline evidence。
- `Sources/App/App.swift`、`Sources/App/DashboardShell.swift` 和 `Sources/App/PaperWorkflowEvidenceExplorer.swift` 必须接入 MTP-131 read model / ViewModel、Dashboard shell metrics / details / smoke handle 和 Event Timeline evidence item。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyWorkbenchReadModelBoundaryDefinesMTP131Surface` 和 `testLiveReadOnlyWorkbenchReadModelBoundaryRejectsForbiddenUISurfaceBypass`。
- `Tests/AppTests/AppTests.swift` 必须包含 `testLiveReadOnlyWorkbenchBoundaryViewModelAggregatesMTP131ReadOnlySurface`，并覆盖 Dashboard shell、Report snapshot 和 Evidence Explorer read-only integration。
- `docs/domain/context.md` 必须包含 MTP-131 Workbench Live readiness shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-131 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-131 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only Workbench read-model-only boundary anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-131 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture、App read model / ViewModel、Dashboard shell、Event Timeline 和 focused test anchors。

MTP-131 必须建立的主要 anchors：

- `MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY`
- `MTP-131-READ-MODEL-VIEWMODEL-INPUT-BOUNDARY`
- `MTP-131-FORBIDDEN-UI-SURFACE`
- `MTP-131-DETAIL-AUDIT-ROUTING`
- `MTP-131-L31-L32-L33-HANDOFF`
- `MTP-131-LIVE-READ-ONLY-WORKBENCH-VALIDATION`

## MTP-131 禁止

- 不新增 API key input、secret storage、local secret read 或 credential provider。
- 不新增 broker connect、account connect、Live PRO Console、trading button、live command 或 order form。
- 不调用 signed endpoint、account endpoint / listenKey，不创建 private WebSocket。
- 不读取 real account balance、broker position、margin、leverage、real PnL 或 account payload。
- 不暴露 Runtime object、database schema、Persistence schema、ORM model 或 adapter request。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不提交、取消或替换真实订单，不授权 broker action 或 production operation。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-132。

## MTP-132 Automation Readiness / Validation Matrix / Stage Audit Input Validation

日期：2026-05-27

执行者：Codex

MTP-132 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-132 的验收要求：

- `docs/audit/inputs/mtpro-live-read-only-readiness-boundary-v1-stage-audit-input.md` 必须存在，并包含 `MTP-132-LIVE-READ-ONLY-READINESS-STAGE-CLOSEOUT`、`MTP-132-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-132-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-132-LIVE-READ-ONLY-READINESS-STAGE-AUDIT-INPUT`、`MTP-132-LIVE-READ-ONLY-READINESS-VALIDATION-EVIDENCE-CHAIN`、`MTP-132-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-132-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`、`MTP-132-AUTOMATION-READINESS-STAGE-CLOSEOUT` 和 `MTP-132-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION` anchors。
- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-132-LIVE-READ-ONLY-READINESS-STAGE-CLOSEOUT`、`MTP-132-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-132-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-132-LIVE-READ-ONLY-READINESS-VALIDATION-EVIDENCE-CHAIN`、`MTP-132-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN` 和 `MTP-132-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-132 issue backfill，并指向 MTP-132 Stage Code Audit 输入材料。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-132 的当前 issue execution evidence，明确只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only Readiness stage audit input anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-126 至 MTP-132 的 contract、matrix、validation plan、latest summary、automation readiness doc、stage audit input、Core / App source anchors、Core / App deterministic test anchors 和 Dashboard smoke `liveReadOnlyWorkbenchBoundary`。
- Stage Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在 `MTP-126` 至 `MTP-132` 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-132 必须建立的主要 anchors：

- `MTP-132-LIVE-READ-ONLY-READINESS-STAGE-CLOSEOUT`
- `MTP-132-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-132-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-132-LIVE-READ-ONLY-READINESS-STAGE-AUDIT-INPUT`
- `MTP-132-LIVE-READ-ONLY-READINESS-VALIDATION-EVIDENCE-CHAIN`
- `MTP-132-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-132-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-132-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-132-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

## MTP-132 禁止

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。
- 不修改 Linear status、不创建 Linear Project / Issue、不启动 `@002 / PAR`、不启动 Symphony / symphony-issue、不推进下一阶段。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不新增 production code、不新增 Live read-only runtime、不新增 account / position / balance runtime、不新增 private stream runtime、不新增 Dashboard command surface。
- 不实现 API key / secret storage，不读取本地 secret，不新增 env / keychain / config secret path。
- 不接 signed endpoint、account endpoint、listenKey、private WebSocket、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、real PnL、Live Monitoring Console v2 runtime、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。

## MTP-133 Account / Position / Balance Read-model-only Terminology Validation

日期：2026-05-28

执行者：Codex

MTP-133 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-133 的验收要求：

- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须存在，并包含 `MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-TERMINOLOGY`、`MTP-133-SOURCE-SEMANTICS-BOUNDARY`、`MTP-133-EVIDENCE-INTERPRETATION-BOUNDARY`、`MTP-133-L31-L32-HANDOFF-BOUNDARY`、`MTP-133-FORBIDDEN-CAPABILITY-BASELINE`、`MTP-133-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION` 和 `MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-133 account / position / balance read-model-only shared language，明确 fixture / paper / simulated evidence 不等于真实账户、broker position、margin、leverage 或 real PnL。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY` 和 MTP-133 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-133 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Account / Position / Balance read-model-only terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-133 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-133 必须建立的主要 anchors：

- `MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-TERMINOLOGY`
- `MTP-133-SOURCE-SEMANTICS-BOUNDARY`
- `MTP-133-EVIDENCE-INTERPRETATION-BOUNDARY`
- `MTP-133-L31-L32-HANDOFF-BOUNDARY`
- `MTP-133-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-133-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-VALIDATION`

## MTP-133 禁止

- 不实现 account / position / balance runtime、Live read-only runtime、private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、margin、leverage、buying power 或 real PnL。
- 不接 signed endpoint、account endpoint / listenKey、private WebSocket、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不推进 MTP-134，不创建下一 Project / Issue。

## MTP-134 Account Snapshot Identity / Freshness Evidence Validation

日期：2026-05-28

执行者：Codex

MTP-134 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-134 的验收要求：

- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-134-ACCOUNT-SNAPSHOT-IDENTITY`、`MTP-134-SOURCE-IDENTITY-FRESHNESS-EVIDENCE`、`MTP-134-STALE-MISSING-BLOCKED-ACCOUNT-EVIDENCE`、`MTP-134-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`、`MTP-134-ACCOUNT-SNAPSHOT-NOT-RUNTIME` 和 `MTP-134-ACCOUNT-SNAPSHOT-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-134 account snapshot identity shared language，明确 account snapshot identity 是 evidence identity，不是 runtime snapshot。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-134 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-134 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Account snapshot identity / freshness evidence anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-134 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-134 必须建立的主要 anchors：

- `MTP-134-ACCOUNT-SNAPSHOT-IDENTITY`
- `MTP-134-SOURCE-IDENTITY-FRESHNESS-EVIDENCE`
- `MTP-134-STALE-MISSING-BLOCKED-ACCOUNT-EVIDENCE`
- `MTP-134-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`
- `MTP-134-ACCOUNT-SNAPSHOT-NOT-RUNTIME`
- `MTP-134-ACCOUNT-SNAPSHOT-IDENTITY-VALIDATION`

## MTP-134 禁止

- 不实现 account snapshot runtime、Live read-only runtime、private stream runtime 或 account endpoint runtime。
- 不调用 account endpoint，不创建 listenKey，不读取 secret，不连接 private WebSocket。
- 不读取真实账户余额、margin、leverage、buying power 或 real PnL。
- 不新增 secret storage、credential provider、signed request、signed endpoint、broker connection、broker adapter 或 `LiveExecutionAdapter`。
- 不暴露 exchange payload、broker payload、Runtime object 或 Adapter request 给 UI。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不新增 account fixture payload、不新增 App surface、不新增 Dashboard smoke handle；fixture contract 仍归属 MTP-137，Workbench / Report / Events surface 仍归属 MTP-138。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-135 Position Snapshot Identity / Exposure Evidence Validation

日期：2026-05-28

执行者：Codex

MTP-135 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-135 的验收要求：

- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-135-POSITION-SNAPSHOT-IDENTITY`、`MTP-135-POSITION-EXPOSURE-EVIDENCE`、`MTP-135-PAPER-SIMULATED-FUTURE-REAL-POSITION-ISOLATION`、`MTP-135-STALE-BLOCKED-SIMULATED-POSITION-EVIDENCE`、`MTP-135-FORBIDDEN-BROKER-POSITION-INTERPRETATION` 和 `MTP-135-POSITION-SNAPSHOT-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-135 position snapshot identity shared language，明确 position evidence 不能表示 broker position。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-135 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-135 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Position snapshot identity / exposure evidence anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-135 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-135 必须建立的主要 anchors：

- `MTP-135-POSITION-SNAPSHOT-IDENTITY`
- `MTP-135-POSITION-EXPOSURE-EVIDENCE`
- `MTP-135-PAPER-SIMULATED-FUTURE-REAL-POSITION-ISOLATION`
- `MTP-135-STALE-BLOCKED-SIMULATED-POSITION-EVIDENCE`
- `MTP-135-FORBIDDEN-BROKER-POSITION-INTERPRETATION`
- `MTP-135-POSITION-SNAPSHOT-IDENTITY-VALIDATION`

## MTP-135 禁止

- 不同步 broker position。
- 不读取 real position、margin、leverage、real account balance、broker portfolio 或 real PnL。
- 不实现 broker adapter、account endpoint、listenKey、private stream、private WebSocket runtime、account snapshot runtime 或 live risk engine。
- 不把 paper portfolio projection、simulated fill 或 simulated exchange exposure 升级为 real position、broker fill、execution report 或 reconciliation。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace。
- 不新增 Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不新增 position fixture payload、不新增 App surface、不新增 Dashboard smoke handle；fixture contract 仍归属 MTP-137，Workbench / Report / Events surface 仍归属 MTP-138。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-136 Balance Snapshot Identity / Paper-vs-real Boundary Validation

日期：2026-05-28

执行者：Codex

MTP-136 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-136 的验收要求：

- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-136-BALANCE-SNAPSHOT-IDENTITY`、`MTP-136-PAPER-SIMULATED-FUTURE-REAL-BALANCE-TERMINOLOGY`、`MTP-136-PAPER-VS-REAL-INTERPRETATION-BOUNDARY`、`MTP-136-REAL-PNL-MARGIN-LEVERAGE-BUYING-POWER-FORBIDDEN`、`MTP-136-BALANCE-STALE-BLOCKED-EVIDENCE` 和 `MTP-136-BALANCE-SNAPSHOT-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-136 balance snapshot identity shared language，明确 balance evidence 是 read-model-only evidence，不是 live account balance。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-136 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-136 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Balance snapshot identity / paper-vs-real boundary anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-136 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-136 必须建立的主要 anchors：

- `MTP-136-BALANCE-SNAPSHOT-IDENTITY`
- `MTP-136-PAPER-SIMULATED-FUTURE-REAL-BALANCE-TERMINOLOGY`
- `MTP-136-PAPER-VS-REAL-INTERPRETATION-BOUNDARY`
- `MTP-136-REAL-PNL-MARGIN-LEVERAGE-BUYING-POWER-FORBIDDEN`
- `MTP-136-BALANCE-STALE-BLOCKED-EVIDENCE`
- `MTP-136-BALANCE-SNAPSHOT-IDENTITY-VALIDATION`

## MTP-136 禁止

- 不读取真实账户余额。
- 不实现 real PnL runtime。
- 不读取 margin、leverage、buying power 或 broker cash statement。
- 不接 signed endpoint、account endpoint、listenKey、private stream 或 private WebSocket runtime。
- 不连接 broker，不实现 account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不把 paper account model 输出解释为真实账户余额、可交易资金、broker equity、margin equity 或 buying power。
- 不新增 Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不新增 balance fixture payload、不新增 App surface、不新增 Dashboard smoke handle；fixture contract 仍归属 MTP-137，Workbench / Report / Events surface 仍归属 MTP-138。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-137 Fixture / Forbidden Real Account Tests Validation

日期：2026-05-28

执行者：Codex

MTP-137 的 required validation：

- `swift test --filter AccountPositionBalanceReadModelOnlyFixture`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-137 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `AccountPositionBalanceReadModelOnlyFixtureContract`、`AccountPositionBalanceReadModelOnlyFixtureRecord`、`AccountPositionBalanceReadModelOnlyForbiddenCapability` 和 deterministic fixture checksum / freshness / source identity validation。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-137 deterministic fixture contract、forbidden real account bypass 和 payload / schema / runtime mapping isolation tests。
- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-137-DETERMINISTIC-FIXTURE-SHAPE`、`MTP-137-FIXTURE-CHECKSUM-FRESHNESS-SOURCE`、`MTP-137-FORBIDDEN-REAL-ACCOUNT-TESTS`、`MTP-137-FIXTURE-TO-READ-MODEL-MAPPING-ISOLATION`、`MTP-137-REAL-ACCOUNT-PAYLOAD-ISOLATION` 和 `MTP-137-FIXTURE-FORBIDDEN-REAL-ACCOUNT-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-137 fixture / forbidden real account tests shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-137 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-137 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Account / Position / Balance fixture / forbidden real account tests anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-137 source、test、contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-137 必须建立的主要 anchors：

- `MTP-137-DETERMINISTIC-FIXTURE-SHAPE`
- `MTP-137-FIXTURE-CHECKSUM-FRESHNESS-SOURCE`
- `MTP-137-FORBIDDEN-REAL-ACCOUNT-TESTS`
- `MTP-137-FIXTURE-TO-READ-MODEL-MAPPING-ISOLATION`
- `MTP-137-REAL-ACCOUNT-PAYLOAD-ISOLATION`
- `MTP-137-FIXTURE-FORBIDDEN-REAL-ACCOUNT-VALIDATION`

## MTP-137 禁止

- 不实现真实账户 fixture importer。
- 不导入 broker payload。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不连接 private WebSocket。
- 不实现 account snapshot runtime。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不读取真实账户、broker position、real PnL、margin 或 leverage。
- 不暴露 payload、schema、Runtime object、adapter request 或 account endpoint response。
- 不新增 App surface、不新增 Dashboard smoke handle；Workbench / Report / Events surface 仍归属 MTP-138。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-138 Workbench / Report / Events Read-model-only Surface Validation

日期：2026-05-28

执行者：Codex

MTP-138 的 required validation：

- `swift test --filter AccountPositionBalanceReadModelOnlySurface`
- `swift test --filter PaperWorkflowEvidenceExplorerTimelineSnapshotAggregatesReadModelOnlyEvidence`
- `swift test --filter DashboardShellWorkbenchSnapshotBindsControlsObservabilityAndExplorerReadOnly`
- `git diff --check`
- `bash checks/run.sh`

MTP-138 的验收要求：

- `Sources/App/AccountPositionBalanceReadModelOnlySurface.swift` 必须包含 `AccountPositionBalanceReadModelOnlySurfaceReadModel`、`AccountPositionBalanceReadModelOnlySurfaceViewModel` 和 `AccountPositionBalanceReadModelOnlySurfaceTraceItem`。
- `Sources/App/App.swift` 必须把 APB surface 接入 `ReportReadModel`、`ReportViewModel` 和 `DashboardViewModel` read-model-only source chain。
- `Sources/App/PaperWorkflowEvidenceExplorer.swift` 必须新增 `accountPositionBalanceReadModelOnlySurface` section、coverage flag 和三条 APB timeline items。
- `Sources/App/DashboardShell.swift` 必须在 Workbench、Report 和 Dashboard smoke 中展示 APB read-model-only evidence。
- `Tests/AppTests/AppTests.swift` 必须覆盖 ViewModel、Workbench metrics / details、Report APB details、Event Timeline APB section 和 forbidden UI / runtime flags。
- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`、`MTP-138-DASHBOARD-REPORT-EVENTS-EVIDENCE`、`MTP-138-FORBIDDEN-UI-RUNTIME-SURFACE` 和 `MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-138 Workbench / Report / Events read-model-only surface shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-138 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Account / Position / Balance Workbench / Report / Events read-model-only surface anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-138 source、test、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-138 必须建立的主要 anchors：

- `MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`
- `MTP-138-DASHBOARD-REPORT-EVENTS-EVIDENCE`
- `MTP-138-FORBIDDEN-UI-RUNTIME-SURFACE`
- `MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-VALIDATION`

## MTP-138 禁止

- 不实现 account / position / balance runtime。
- 不读取真实账户、broker position、real PnL、margin 或 leverage。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不连接 private WebSocket。
- 不实现 account snapshot runtime。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不暴露 account endpoint payload、broker payload、schema、Runtime object、adapter request 或 broker state。
- 不新增 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command 或 order form。
- 不推进 MTP-139。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-139 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-28

执行者：Codex

MTP-139 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-139 的验收要求：

- `docs/audit/inputs/mtpro-account-position-balance-read-model-only-v1-stage-audit-input.md` 必须存在，并包含 `MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT`、`MTP-139-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-139-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-AUDIT-INPUT`、`MTP-139-VALIDATION-EVIDENCE-CHAIN`、`MTP-139-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-139-READ-MODEL-ONLY-BOUNDARY-EVIDENCE` 和 `MTP-139-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 MTP-139 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、automation readiness stage closeout 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-139 stage closeout shared language。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-139 回填到 `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY`。
- `docs/automation/automation-readiness.md` 必须新增 Account / Position / Balance stage audit input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-139 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-139 input、contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、MTP-133 至 MTP-138 PR evidence 和 Dashboard smoke `accountPositionBalanceEvidence=3` handle。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-139 必须建立的主要 anchors：

- `MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT`
- `MTP-139-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-139-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-AUDIT-INPUT`
- `MTP-139-VALIDATION-EVIDENCE-CHAIN`
- `MTP-139-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-139-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-139-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT-VALIDATION`

## MTP-139 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建 `docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md`。
- 不设置 Linear Project `Completed`，不写 Root Docs Refresh Gate。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard behavior。
- 不实现 account / position / balance runtime。
- 不读取真实账户、broker position、real PnL、margin 或 leverage。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不连接 private WebSocket。
- 不实现 account snapshot runtime。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不新增 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command 或 order form。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-140 Private Stream / Account Snapshot Simulation Gate Terminology Validation

日期：2026-05-29

执行者：Codex

MTP-140 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-140 的验收要求：

- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-140-PRIVATE-STREAM-SIMULATION-GATE-TERMINOLOGY`、`MTP-140-ACCOUNT-SNAPSHOT-SIMULATION-GATE-TERMINOLOGY`、`MTP-140-FIXTURE-SIMULATED-FUTURE-REAL-PRIVATE-STREAM-BOUNDARY`、`MTP-140-L31-APB-L32-SIMULATION-GATE-RELATIONSHIP`、`MTP-140-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`、`MTP-140-FORBIDDEN-CAPABILITY-BASELINE` 和 `MTP-140-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-140 private stream / account snapshot simulation gate shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE` 和 MTP-140 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate terminology anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-140 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-140 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-140 必须建立的主要 anchors：

- `MTP-140-PRIVATE-STREAM-SIMULATION-GATE-TERMINOLOGY`
- `MTP-140-ACCOUNT-SNAPSHOT-SIMULATION-GATE-TERMINOLOGY`
- `MTP-140-FIXTURE-SIMULATED-FUTURE-REAL-PRIVATE-STREAM-BOUNDARY`
- `MTP-140-L31-APB-L32-SIMULATION-GATE-RELATIONSHIP`
- `MTP-140-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-140-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-140-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE-VALIDATION`

## MTP-140 禁止

- 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard behavior。
- 不实现 private WebSocket runtime 或 private stream runtime。
- 不实现 account snapshot runtime 或 account / position / balance runtime。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不调用 signed endpoint 或 account endpoint。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不推进 MTP-141，不输出 stage audit input。

## MTP-141 Simulated Private Account Event Source Identity Validation

日期：2026-05-29

执行者：Codex

MTP-141 的 required validation：

- `swift test --filter SimulatedPrivateAccountEventSourceIdentity`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-141 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedPrivateAccountEventSourceIdentityContract`、`SimulatedPrivateAccountEventSourceIdentityRecord`、`SimulatedPrivateAccountEventSourceKind` 和 `SimulatedPrivateAccountEventSourceForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testSimulatedPrivateAccountEventSourceIdentityDefinesMTP141DeterministicSource` 和 `testSimulatedPrivateAccountEventSourceIdentityRejectsMTP141ForbiddenLiveSourceBypass`。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`、`MTP-141-FIXTURE-SCENARIO-VERSION-CHECKSUM-FRESHNESS-LINKAGE`、`MTP-141-FUTURE-REAL-PRIVATE-STREAM-LABEL-GATE`、`MTP-141-FORBIDDEN-LIVE-STREAM-SOURCE-TESTS`、`MTP-141-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD` 和 `MTP-141-SOURCE-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-141 source identity shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-141 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate source identity anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-141 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-141 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-141 必须建立的主要 anchors：

- `MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`
- `MTP-141-FIXTURE-SCENARIO-VERSION-CHECKSUM-FRESHNESS-LINKAGE`
- `MTP-141-FUTURE-REAL-PRIVATE-STREAM-LABEL-GATE`
- `MTP-141-FORBIDDEN-LIVE-STREAM-SOURCE-TESTS`
- `MTP-141-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`
- `MTP-141-SOURCE-IDENTITY-VALIDATION`

## MTP-141 禁止

- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不调用 signed endpoint 或 account endpoint。
- 不实现 account snapshot runtime 或 simulated account snapshot input contract；MTP-142 才能深化 snapshot input shape。
- 不读取真实 account payload 或 broker payload。
- 不暴露 Adapter request、SQLite / DuckDB schema 或 Runtime object。
- 不绕过 adapter capability matrix。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-142 Simulated Account Snapshot Input Contract Validation

日期：2026-05-29

执行者：Codex

MTP-142 的 required validation：

- `swift test --filter SimulatedAccountSnapshotInput`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-142 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedAccountSnapshotInputContract`、`SimulatedAccountSnapshotInputRecord`、`SimulatedAccountSnapshotInputState` 和 `SimulatedAccountSnapshotInputForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testSimulatedAccountSnapshotInputDefinesMTP142DeterministicContract`、`testSimulatedAccountSnapshotInputRejectsMTP142EndpointRuntimeAndPayloadBypass` 和 `testSimulatedAccountSnapshotInputRejectsMTP142PayloadSchemaRuntimeMapping`。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-SHAPE`、`MTP-142-SNAPSHOT-ID-SOURCE-OBSERVEDAT-FRESHNESS-STATE`、`MTP-142-FIXTURE-VERSION-CHECKSUM-DETERMINISTIC-REPLAY-LINKAGE`、`MTP-142-FIXTURE-TO-READ-MODEL-MAPPING-BOUNDARY`、`MTP-142-ACCOUNT-PAYLOAD-ISOLATION-TESTS` 和 `MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-142 simulated account snapshot input shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-142 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate snapshot input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-142 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-142 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-142 必须建立的主要 anchors：

- `MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-SHAPE`
- `MTP-142-SNAPSHOT-ID-SOURCE-OBSERVEDAT-FRESHNESS-STATE`
- `MTP-142-FIXTURE-VERSION-CHECKSUM-DETERMINISTIC-REPLAY-LINKAGE`
- `MTP-142-FIXTURE-TO-READ-MODEL-MAPPING-BOUNDARY`
- `MTP-142-ACCOUNT-PAYLOAD-ISOLATION-TESTS`
- `MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-VALIDATION`

## MTP-142 禁止

- 不实现 account snapshot runtime 或 private stream runtime。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不调用 signed endpoint 或 account endpoint。
- 不读取真实账户、真实余额、margin、leverage 或 real PnL。
- 不暴露 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不新增 App、Dashboard、Workbench、Report 或 Events behavior；MTP-145 才能深化 read-model-only surface。
- 不定义 balance / position update fixture semantics；MTP-143 才能深化该 scope。
- 不深化 freshness / stale / blocked forbidden endpoint tests；MTP-144 才能深化该 scope。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-143 Simulated Account Snapshot Update Fixture Validation

日期：2026-05-29

执行者：Codex

MTP-143 的 required validation：

- `swift test --filter SimulatedAccountSnapshotUpdateFixture`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-143 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedAccountSnapshotUpdateFixture`、`SimulatedAccountSnapshotUpdateFixtureRecord`、`SimulatedAccountSnapshotUpdateFixtureKind`、`SimulatedAccountSnapshotUpdateInterpretationBoundary` 和 `SimulatedAccountSnapshotUpdateFixtureForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testSimulatedAccountSnapshotUpdateFixtureDefinesMTP143DeterministicContract` 和 `testSimulatedAccountSnapshotUpdateFixtureRejectsMTP143RealAccountBrokerPnLBypass`。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-SEMANTICS`、`MTP-143-MTP141-MTP142-LINKAGE-CHECKSUM-BOUNDARY`、`MTP-143-BALANCE-POSITION-UPDATE-READ-MODEL-ONLY-BOUNDARY`、`MTP-143-UPDATE-FIXTURE-INTERPRETATION-ISOLATION-TESTS` 和 `MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-143 simulated account snapshot update fixture shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-143 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate update fixture anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-143 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-143 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-143 必须建立的主要 anchors：

- `MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-SEMANTICS`
- `MTP-143-MTP141-MTP142-LINKAGE-CHECKSUM-BOUNDARY`
- `MTP-143-BALANCE-POSITION-UPDATE-READ-MODEL-ONLY-BOUNDARY`
- `MTP-143-UPDATE-FIXTURE-INTERPRETATION-ISOLATION-TESTS`
- `MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-VALIDATION`

## MTP-143 禁止

- 不实现 account snapshot runtime 或 private stream runtime。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不调用 signed endpoint 或 account endpoint。
- 不读取真实账户、真实余额、真实持仓、broker position、margin、leverage 或 real PnL。
- 不把 balance update fixture 或 position update fixture 解释为真实余额更新、真实持仓更新、broker position sync、execution report、broker fill 或 reconciliation。
- 不暴露 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 App、Dashboard、Workbench、Report 或 Events behavior；MTP-145 才能深化 read-model-only surface。
- 不深化 freshness / stale / blocked forbidden endpoint tests；MTP-144 才能深化该 scope。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-144 Simulated Account Snapshot Freshness Evidence Validation

日期：2026-05-30

执行者：Codex

MTP-144 的 required validation：

- `swift test --filter SimulatedAccountSnapshotFreshnessEvidence`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-144 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedAccountSnapshotFreshnessEvidenceContract`、`SimulatedAccountSnapshotFreshnessEvidenceItem`、`SimulatedAccountSnapshotFreshnessEvidenceStatus` 和 `SimulatedAccountSnapshotFreshnessEvidenceForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testSimulatedAccountSnapshotFreshnessEvidenceDefinesMTP144DeterministicStates`、`testSimulatedAccountSnapshotFreshnessEvidenceRejectsMTP144EndpointRuntimeAndBrokerBypass` 和 `testSimulatedAccountSnapshotFreshnessEvidenceRejectsMTP144PayloadSchemaRuntimeExposure`。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-144-FRESHNESS-STALE-BLOCKED-MISSING-EVIDENCE`、`MTP-144-MTP141-MTP142-MTP143-FRESHNESS-CHECKSUM-BOUNDARY`、`MTP-144-FORBIDDEN-ENDPOINT-RUNTIME-TESTS`、`MTP-144-PAYLOAD-SCHEMA-RUNTIME-NON-EXPOSURE-TESTS` 和 `MTP-144-SIMULATED-ACCOUNT-SNAPSHOT-FRESHNESS-EVIDENCE-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-144 simulated account snapshot freshness evidence shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-144 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate freshness evidence anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-144 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-144 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-144 必须建立的主要 anchors：

- `MTP-144-FRESHNESS-STALE-BLOCKED-MISSING-EVIDENCE`
- `MTP-144-MTP141-MTP142-MTP143-FRESHNESS-CHECKSUM-BOUNDARY`
- `MTP-144-FORBIDDEN-ENDPOINT-RUNTIME-TESTS`
- `MTP-144-PAYLOAD-SCHEMA-RUNTIME-NON-EXPOSURE-TESTS`
- `MTP-144-SIMULATED-ACCOUNT-SNAPSHOT-FRESHNESS-EVIDENCE-VALIDATION`

## MTP-144 禁止

- 不实现 account snapshot runtime、private stream runtime 或 freshness runtime。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不调用 signed endpoint 或 account endpoint。
- 不读取真实账户、真实余额、真实持仓、broker position、margin、leverage 或 real PnL。
- 不暴露 account endpoint payload、real account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 App、Dashboard、Workbench、Report 或 Events behavior；MTP-145 才能深化 read-model-only surface。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-145 Workbench / Report / Events Read-model-only Simulation Gate Evidence Surface Validation

日期：2026-05-30

执行者：Codex

MTP-145 的 required validation：

- `swift test --filter PrivateStreamSimulationGateEvidenceSurface`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-145 的验收要求：

- `Sources/App/PrivateStreamSimulationGateEvidenceSurface.swift` 必须包含 `PrivateStreamSimulationGateEvidenceSurfaceReadModel`、`PrivateStreamSimulationGateEvidenceSurfaceViewModel`、`PrivateStreamSimulationGateFreshnessRecordViewModel` 和 `PrivateStreamSimulationGateEvidenceTraceItem`。
- `Sources/App/App.swift` 必须把 MTP-145 surface 接入 `ReportReadModel`、`ReportViewModel` 和 `DashboardViewModel` source chain。
- `Sources/App/PaperWorkflowEvidenceExplorer.swift` 必须包含 `privateStreamSimulationGateEvidenceSurface` section，并输出 MTP-145 Event Timeline read-model-only evidence item。
- `Sources/App/DashboardShell.swift` 必须包含 Workbench / Report simulation gate metrics、details 和 Dashboard smoke handle `privateStreamSimulationGateEvidence=4`。
- `Tests/AppTests/AppTests.swift` 必须包含 `testPrivateStreamSimulationGateEvidenceSurfaceAggregatesMTP145ReadOnlySurface`，覆盖 Report / Workbench / Events surface、forbidden UI/runtime flags 和 Codable deterministic snapshot。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-145 read-model-only surface、Dashboard / Report / Events evidence、forbidden UI/runtime surface 和 validation anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-145 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate Workbench / Report / Events surface anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-145 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-145 App source、focused tests、contract、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-145 必须建立的主要 anchors：

- `MTP-145-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SIMULATION-GATE-SURFACE`
- `MTP-145-DASHBOARD-REPORT-EVENTS-SIMULATION-GATE-EVIDENCE`
- `MTP-145-FORBIDDEN-UI-RUNTIME-SURFACE`
- `MTP-145-PRIVATE-STREAM-SIMULATION-GATE-SURFACE-VALIDATION`

## MTP-145 禁止

- 不新增或修改 Core semantics；MTP-145 只消费 MTP-141 至 MTP-144 deterministic Core evidence。
- 不新增 Adapters、Persistence、Runtime、broker / exchange adapter implementation、secret / credential / endpoint code。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey、real account read、broker position sync、real balance、real position、margin、leverage、real PnL、execution report、broker fill 或 reconciliation。
- 不暴露 account endpoint payload、real account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、command surface 或 order-level command。
- 不输出 Stage Code Audit Report，不执行 Project closeout；MTP-146 才能收口 stage closeout。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-146 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-30

执行者：Codex

MTP-146 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-146 的验收要求：

- `docs/audit/inputs/mtpro-private-stream-account-snapshot-simulation-gate-v1-stage-audit-input.md` 必须包含 `MTP-146-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-STAGE-CLOSEOUT`、`MTP-146-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-146-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-146-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-STAGE-AUDIT-INPUT`、`MTP-146-VALIDATION-EVIDENCE-CHAIN`、`MTP-146-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-146-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`、`MTP-146-AUTOMATION-READINESS-STAGE-CLOSEOUT`、`MTP-146-STAGE-CLOSEOUT-VALIDATION` 和 `MTP-146-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION` anchors。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-146 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness stage closeout 和 validation anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE` 的 MTP-146 issue backfill 和 `MTP-146 Private Stream / Account Snapshot 阶段收口`。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate stage audit input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-146 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-146 stage audit input、contract、validation matrix、validation plan、latest summary、automation readiness doc、MTP-140 至 MTP-145 PR evidence、Dashboard smoke handle 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-146 必须建立的主要 anchors：

- `MTP-146-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-STAGE-CLOSEOUT`
- `MTP-146-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-146-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-146-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-STAGE-AUDIT-INPUT`
- `MTP-146-VALIDATION-EVIDENCE-CHAIN`
- `MTP-146-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-146-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-146-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-146-STAGE-CLOSEOUT-VALIDATION`
- `MTP-146-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

## MTP-146 禁止

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed/type=completed` 后单独输出。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不修改 production code，不新增 Core / App business capability。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、Live read-only runtime、signed endpoint、account endpoint、listenKey、real account read、broker position sync、real balance、real position、margin、leverage、real PnL、execution report、broker fill 或 reconciliation。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、command surface 或 order-level command。

## MTP-147 Live Monitoring Read-only Console v2 Terminology Validation

日期：2026-05-30

执行者：Codex

MTP-147 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-147 的验收要求：

- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-TERMINOLOGY`、`MTP-147-MONITORING-EVIDENCE-SOURCE-BOUNDARY`、`MTP-147-READ-MODEL-VIEWMODEL-CONSUMPTION-BOUNDARY`、`MTP-147-L33-HANDOFF-BOUNDARY`、`MTP-147-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`、`MTP-147-FORBIDDEN-CAPABILITY-BASELINE` 和 `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-147 Live Monitoring Read-only Console v2 shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2` 和 MTP-147 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-147 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring Read-only Console v2 terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-147 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-147 必须建立的主要 anchors：

- `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-TERMINOLOGY`
- `MTP-147-MONITORING-EVIDENCE-SOURCE-BOUNDARY`
- `MTP-147-READ-MODEL-VIEWMODEL-CONSUMPTION-BOUNDARY`
- `MTP-147-L33-HANDOFF-BOUNDARY`
- `MTP-147-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-147-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-VALIDATION`

## MTP-147 禁止

- 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 App read model、不新增 Core / Runtime / Dashboard behavior、不新增 stage audit input。
- 不实现 monitoring evidence surface；MTP-152 才能接入 Workbench / Report / Events read-model-only surface。
- 不实现 live readiness runtime、Live Monitoring runtime、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不接 signed endpoint、account endpoint / listenKey，不创建 listenKey，不执行 listenKey keepalive。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不实现 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-148 Live Monitoring Source Identity Validation

日期：2026-05-30

执行者：Codex

MTP-148 的 required validation：

- `swift test --filter LiveMonitoringSourceIdentity`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-148 的验收要求：

- `Sources/Core/LiveMonitoringSourceIdentity.swift` 必须包含 `LiveMonitoringSourceIdentityContract`、`LiveMonitoringSourceIdentityRecord`、`LiveMonitoringSourceEvidenceLayer`、`LiveMonitoringSourceEvidenceOrigin`、`LiveMonitoringSourceStatus`、`LiveMonitoringSourceFreshnessSemantics` 和 `LiveMonitoringSourceIdentityForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringSourceIdentityDefinesMTP148DeterministicSource` 和 `testLiveMonitoringSourceIdentityRejectsMTP148RealSourceEndpointAndPayloadBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-148-MONITORING-SOURCE-IDENTITY`、`MTP-148-EVIDENCE-ORIGIN-BOUNDARY-FIXTURE-SIMULATED-READ-MODEL-ONLY`、`MTP-148-SOURCE-FRESHNESS-STATUS-UNAVAILABLE-SEMANTICS`、`MTP-148-SIMULATED-FIXTURE-NOT-REAL-ACCOUNT-GUARD` 和 `MTP-148-LIVE-MONITORING-SOURCE-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-148 monitoring source identity shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-148 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-148 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring source identity anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-148 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-148 必须建立的主要 anchors：

- `MTP-148-MONITORING-SOURCE-IDENTITY`
- `MTP-148-EVIDENCE-ORIGIN-BOUNDARY-FIXTURE-SIMULATED-READ-MODEL-ONLY`
- `MTP-148-SOURCE-FRESHNESS-STATUS-UNAVAILABLE-SEMANTICS`
- `MTP-148-SIMULATED-FIXTURE-NOT-REAL-ACCOUNT-GUARD`
- `MTP-148-LIVE-MONITORING-SOURCE-IDENTITY-VALIDATION`

## MTP-148 禁止

- 不创建真实 source adapter，不读取真实 account / position / balance。
- 不接 private stream、listenKey、signed endpoint 或 account endpoint。
- 不暴露 Runtime object、Adapter request、数据库 schema、account payload、broker payload 或 broker state。
- 不实现 Live Monitoring runtime、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 App / Dashboard behavior、Workbench / Report / Events surface、Dashboard smoke handle、API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command 或 order form。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-149 Live Monitoring Simulation Gate Health Validation

日期：2026-05-30

执行者：Codex

MTP-149 的 required validation：

- `swift test --filter LiveMonitoringSimulationGateHealth`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-149 的验收要求：

- `Sources/Core/LiveMonitoringSimulationGateHealth.swift` 必须包含 `LiveMonitoringSimulationGateHealthContract`、`LiveMonitoringSimulationGateHealthEvidenceItem`、`LiveMonitoringSimulationGateHealthStatus`、`LiveMonitoringSimulationGateFreshnessExplanation` 和 `LiveMonitoringSimulationGateHealthForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringSimulationGateHealthDefinesMTP149DeterministicEvidence` 和 `testLiveMonitoringSimulationGateHealthRejectsMTP149RuntimeEndpointPayloadAndSchemaBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-149-SIMULATION-GATE-HEALTH-FRESHNESS-EVIDENCE`、`MTP-149-HEALTH-FRESHNESS-NOT-REAL-ACCOUNT-HEALTH`、`MTP-149-READ-MODEL-ONLY-NON-EXPOSURE` 和 `MTP-149-LIVE-MONITORING-SIMULATION-GATE-HEALTH-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-149 simulation gate health shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-149 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-149 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring simulation gate health evidence anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-149 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-149 必须建立的主要 anchors：

- `MTP-149-SIMULATION-GATE-HEALTH-FRESHNESS-EVIDENCE`
- `MTP-149-HEALTH-FRESHNESS-NOT-REAL-ACCOUNT-HEALTH`
- `MTP-149-READ-MODEL-ONLY-NON-EXPOSURE`
- `MTP-149-LIVE-MONITORING-SIMULATION-GATE-HEALTH-VALIDATION`

## MTP-149 禁止

- 不把 health / freshness evidence 写成 real account health、broker connectivity、private stream health、live connection status 或 production monitoring runtime。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey 或 listenKey keepalive。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、broker payload 或 account endpoint payload。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 App / Dashboard behavior、Workbench / Report / Events surface、Dashboard smoke handle、API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、reconnect、recovery 或 fallback action。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-150 Live Monitoring Connection Readiness Explanation Validation

日期：2026-05-30

执行者：Codex

MTP-150 的 required validation：

- `swift test --filter LiveMonitoringConnectionReadiness`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-150 的验收要求：

- `Sources/Core/LiveMonitoringConnectionReadinessExplanation.swift` 必须包含 `LiveMonitoringConnectionReadinessExplanationContract`、`LiveMonitoringConnectionReadinessExplanationItem`、`LiveMonitoringConnectionReadinessExplanationState`、`LiveMonitoringConnectionReadinessDisplaySemantics` 和 `LiveMonitoringConnectionReadinessForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringConnectionReadinessExplanationDefinesMTP150DeterministicEvidence` 和 `testLiveMonitoringConnectionReadinessExplanationRejectsMTP150RuntimeEndpointAndCommandBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-150-CONNECTION-READINESS-EXPLANATION`、`MTP-150-STALE-BLOCKED-MISSING-UI-REPORT-SEMANTICS`、`MTP-150-NO-RUNTIME-CONNECTION-BOUNDARY`、`MTP-150-READINESS-EXPLANATION-NOT-LIVE-READINESS` 和 `MTP-150-LIVE-MONITORING-CONNECTION-READINESS-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-150 connection readiness explanation shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-150 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-150 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring connection readiness explanation anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-150 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-150 必须建立的主要 anchors：

- `MTP-150-CONNECTION-READINESS-EXPLANATION`
- `MTP-150-STALE-BLOCKED-MISSING-UI-REPORT-SEMANTICS`
- `MTP-150-NO-RUNTIME-CONNECTION-BOUNDARY`
- `MTP-150-READINESS-EXPLANATION-NOT-LIVE-READINESS`
- `MTP-150-LIVE-MONITORING-CONNECTION-READINESS-VALIDATION`

## MTP-150 禁止

- 不把 readiness explanation 写成真实连接状态、live readiness implementation、broker connectivity、private stream health、account endpoint health 或 production monitoring runtime。
- 不实现 connection manager，不打开 runtime connection，不实现 Live Monitoring runtime 或 live readiness runtime。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey 或 listenKey keepalive。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、broker payload 或 account endpoint payload。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 App / Dashboard behavior、Workbench / Report / Events surface、Dashboard smoke handle、API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、reconnect、recovery 或 fallback action。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-151 Live Monitoring Forbidden Capability Validation

日期：2026-05-30

执行者：Codex

MTP-151 的 required validation：

- `swift test --filter LiveMonitoringForbiddenCapability`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-151 的验收要求：

- `Sources/Core/LiveMonitoringForbiddenCapabilityTests.swift` 必须包含 `LiveMonitoringForbiddenCapabilityTestContract`、`LiveMonitoringForbiddenCapabilityTestCase`、`LiveMonitoringForbiddenCapabilityTestDomain` 和 `LiveMonitoringForbiddenCapabilityTestAssertion`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringForbiddenCapabilityTestsDefineMTP151CoverageMatrix` 和 `testLiveMonitoringForbiddenCapabilityTestsRejectMTP151RuntimeEndpointAndUIBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-151-FORBIDDEN-LIVE-MONITORING-CAPABILITY-TESTS`、`MTP-151-FORBIDDEN-ENDPOINT-RUNTIME-BROKER-UI-COVERAGE`、`MTP-151-MONITORING-EVIDENCE-NOT-LIVE-RUNTIME-GUARD` 和 `MTP-151-LIVE-MONITORING-FORBIDDEN-CAPABILITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-151 forbidden capability tests shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-151 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-151 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring forbidden capability tests anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-151 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-151 必须建立的主要 anchors：

- `MTP-151-FORBIDDEN-LIVE-MONITORING-CAPABILITY-TESTS`
- `MTP-151-FORBIDDEN-ENDPOINT-RUNTIME-BROKER-UI-COVERAGE`
- `MTP-151-MONITORING-EVIDENCE-NOT-LIVE-RUNTIME-GUARD`
- `MTP-151-LIVE-MONITORING-FORBIDDEN-CAPABILITY-VALIDATION`

## MTP-151 禁止

- 不实现真实 endpoint、adapter、UI command、完整实盘监控台页面重设计、stop / shutdown / restore。
- 不把 forbidden tests 写成可执行 runtime、connection manager、runtime connection、live readiness runtime 或 Live Monitoring runtime。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey 或 listenKey keepalive。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、broker payload 或 account endpoint payload。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 App / Dashboard behavior、Workbench / Report / Events surface、Dashboard smoke handle、API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、reconnect、recovery 或 fallback action。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-152 Live Monitoring Workbench / Report / Events Surface Validation

日期：2026-05-31

执行者：Codex

MTP-152 的 required validation：

- `swift test --filter LiveMonitoringReadOnlyConsoleV2`
- `swift test --filter AppTests`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-152 的验收要求：

- `Sources/App/LiveMonitoringReadOnlyConsoleV2Surface.swift` 必须包含 `LiveMonitoringReadOnlyConsoleV2SurfaceReadModel`、`LiveMonitoringReadOnlyConsoleV2SurfaceViewModel` 和 `LiveMonitoringReadOnlyConsoleV2TraceItem`。
- `Sources/App/App.swift` 必须把 `liveMonitoringReadOnlyConsoleV2Surface` 接入 Report / Dashboard read model 和 view model。
- `Sources/App/PaperWorkflowEvidenceExplorer.swift` 必须包含 `liveMonitoringReadOnlyConsoleV2Surface` section，并输出 MTP-152 Event Timeline read-model-only evidence item。
- `Sources/App/DashboardShell.swift` 必须包含 Workbench / Report metrics、details 和 smoke handle `liveMonitoringReadOnlyConsoleV2Surface=4`。
- `Tests/AppTests/AppTests.swift` 必须包含 `testLiveMonitoringReadOnlyConsoleV2SurfaceAggregatesMTP152WorkbenchReportEventsEvidence`，并验证 Workbench / Report / Events 只消费 Read Model / ViewModel。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`、`MTP-152-MONITORING-SOURCE-FRESHNESS-EXPLANATION-SURFACE`、`MTP-152-NO-RUNTIME-ADAPTER-SCHEMA-PAYLOAD-BROKER-STATE-SURFACE` 和 `MTP-152-LIVE-MONITORING-V2-SURFACE-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-152 Workbench / Report / Events shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-152 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-152 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring Workbench / Report / Events read-model-only surface anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-152 App source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-152 必须建立的主要 anchors：

- `MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`
- `MTP-152-MONITORING-SOURCE-FRESHNESS-EXPLANATION-SURFACE`
- `MTP-152-NO-RUNTIME-ADAPTER-SCHEMA-PAYLOAD-BROKER-STATE-SURFACE`
- `MTP-152-LIVE-MONITORING-V2-SURFACE-VALIDATION`

## MTP-152 禁止

- 不新增 Adapters、Runtime、Core semantics、Persistence schema、真实 endpoint、真实 network validation 或完整实盘监控台页面重设计。
- 不实现 signed endpoint、account endpoint、listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、connection manager、runtime connection、live readiness runtime 或 Live Monitoring runtime。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、broker payload 或 account endpoint payload。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、reconnect、recovery 或 fallback action。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-153 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-31

执行者：Codex

MTP-153 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-153 的验收要求：

- `docs/audit/inputs/mtpro-live-monitoring-read-only-console-v2-stage-audit-input.md` 必须包含 `MTP-153-LIVE-MONITORING-V2-STAGE-CLOSEOUT`、`MTP-153-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-153-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-153-LIVE-MONITORING-V2-STAGE-AUDIT-INPUT`、`MTP-153-VALIDATION-EVIDENCE-CHAIN`、`MTP-153-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-153-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`、`MTP-153-AUTOMATION-READINESS-STAGE-CLOSEOUT`、`MTP-153-STAGE-CLOSEOUT-VALIDATION` 和 `MTP-153-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION` anchors。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 MTP-153 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness stage closeout 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-153 Live Monitoring v2 stage closeout shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2` 的 MTP-153 issue backfill 和 `MTP-153 Live Monitoring v2 阶段收口`。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring Read-only Console v2 stage audit input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-153 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-153 stage audit input、contract、validation matrix、validation plan、latest summary、automation readiness doc、MTP-147 至 MTP-152 PR evidence、Dashboard smoke handle 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-153 必须建立的主要 anchors：

- `MTP-153-LIVE-MONITORING-V2-STAGE-CLOSEOUT`
- `MTP-153-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-153-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-153-LIVE-MONITORING-V2-STAGE-AUDIT-INPUT`
- `MTP-153-VALIDATION-EVIDENCE-CHAIN`
- `MTP-153-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-153-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-153-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-153-STAGE-CLOSEOUT-VALIDATION`
- `MTP-153-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

## MTP-153 禁止

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed/type=completed` 后单独输出。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不修改 production code，不新增 Core / App business capability。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 Live Monitoring runtime、live readiness runtime、connection manager、runtime connection、private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey、listenKey keepalive、real account read、broker position sync、real balance、real position、margin、leverage 或 real PnL。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、stop / shutdown / restore、command surface 或 order-level command。

## MTP-154 Strategy / Trader Instance Readiness Terminology Validation

日期：2026-05-31

执行者：Codex

MTP-154 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-154 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-154 terminology、readiness-only boundary、proposal / readiness evidence baseline、L3.4 handoff boundary、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-154 Strategy / Trader Instance Readiness shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 和 MTP-154 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Strategy / Trader Instance readiness terminology anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-154 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-154 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record、Linear write evidence 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-154 必须建立的主要 anchors：

- `MTP-154-STRATEGY-TRADER-INSTANCE-READINESS-TERMINOLOGY`
- `MTP-154-READINESS-ONLY-BOUNDARY`
- `MTP-154-PROPOSAL-READINESS-EVIDENCE-BASELINE`
- `MTP-154-L34-HANDOFF-BOUNDARY`
- `MTP-154-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-154-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-154-STRATEGY-TRADER-INSTANCE-READINESS-VALIDATION`

## MTP-154 禁止

- 不实现 Strategy runtime、Trader runtime、strategy scheduler、trader process manager 或 direct Strategy Instance -> Execution Client path。
- 不输出 broker command、executable order command、OMS order、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage 或 real PnL。
- 不新增 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、stop / shutdown / restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-156 Quoter / Hedger Role Taxonomy Validation

日期：2026-05-31

执行者：Codex

MTP-156 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-156 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-156 quoter / hedger role taxonomy、role responsibility boundary、role proposal / read-model / blocked evidence relationship、no role execution behavior、forbidden role command surface 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-156 quoter / hedger role taxonomy shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-156 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 quoter / hedger role taxonomy anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-156 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-156 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、forbidden role command surface 和 no role execution behavior。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-156 必须建立的主要 anchors：

- `MTP-156-QUOTER-HEDGER-ROLE-TAXONOMY`
- `MTP-156-ROLE-RESPONSIBILITY-BOUNDARY`
- `MTP-156-ROLE-PROPOSAL-READ-MODEL-BLOCKED-EVIDENCE`
- `MTP-156-NO-ROLE-EXECUTION-BEHAVIOR`
- `MTP-156-FORBIDDEN-ROLE-COMMAND-SURFACE`
- `MTP-156-ROLE-TAXONOMY-VALIDATION`

## MTP-156 禁止

- 不实现 quoter runtime、hedger runtime、strategy marketplace、strategy manager、strategy scheduler、trader process manager、order generation engine 或 direct Strategy Instance -> Execution Client path。
- 不输出 broker command、order-level live command、executable order command、Execution Client request、OMS order、quote order request、hedge order request、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、broker payload、account endpoint payload、credential、secret 或 API key。
- 不新增 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、stop / shutdown / restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-155 Strategy / Trader Lifecycle Identity Validation

日期：2026-05-31

执行者：Codex

MTP-155 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-155 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-155 lifecycle / identity、instance identity boundary、lifecycle readiness state semantics、read-model reference boundary、no lifecycle runtime boundary、identity sensitive field guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-155 Strategy / Trader lifecycle / identity shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-155 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Strategy / Trader lifecycle identity anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-155 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-155 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、no lifecycle runtime boundary 和 identity sensitive field guard。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-155 必须建立的主要 anchors：

- `MTP-155-STRATEGY-TRADER-LIFECYCLE-IDENTITY`
- `MTP-155-INSTANCE-IDENTITY-BOUNDARY`
- `MTP-155-LIFECYCLE-READINESS-STATE-SEMANTICS`
- `MTP-155-READ-MODEL-REFERENCE-BOUNDARY`
- `MTP-155-NO-LIFECYCLE-RUNTIME-BOUNDARY`
- `MTP-155-IDENTITY-SENSITIVE-FIELD-GUARD`
- `MTP-155-STRATEGY-TRADER-LIFECYCLE-VALIDATION`

## MTP-155 禁止

- 不实现 lifecycle runtime、Strategy runtime、Trader runtime、strategy scheduler、trader process manager、broker connection、account session 或 direct Strategy Instance -> Execution Client path。
- 不输出 broker command、executable order command、OMS order、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage 或 real PnL。
- 不暴露 credential、secret、API key、listenKey、account id、broker account id、private stream cursor、Runtime object、Adapter request、SQLite / DuckDB schema、broker payload 或 account endpoint payload。
- 不新增 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、stop / shutdown / restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-157 Account / Portfolio / Risk Read-model Input Validation

日期：2026-05-31

执行者：Codex

MTP-157 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-157 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-157 account / portfolio / risk read-model input contract、input provenance / evidence trace、freshness / blocked / simulated / future-gated semantics、Read Model / ViewModel boundary、no real account / live risk runtime boundary、broker state / payload / schema exposure guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-157 account / portfolio / risk read-model input shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-157 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 account / portfolio / risk read-model input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-157 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-157 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、Read Model / ViewModel boundary、no real account / live risk runtime boundary 和 broker state / payload / schema exposure guard。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-157 必须建立的主要 anchors：

- `MTP-157-ACCOUNT-PORTFOLIO-RISK-READ-MODEL-INPUT`
- `MTP-157-INPUT-PROVENANCE-EVIDENCE-TRACE`
- `MTP-157-FRESHNESS-BLOCKED-SIMULATED-FUTURE-GATED-SEMANTICS`
- `MTP-157-READ-MODEL-VIEWMODEL-BOUNDARY`
- `MTP-157-NO-REAL-ACCOUNT-RISK-RUNTIME`
- `MTP-157-BROKER-STATE-PAYLOAD-SCHEMA-EXPOSURE-GUARD`
- `MTP-157-READ-MODEL-INPUT-VALIDATION`

## MTP-157 禁止

- 不读取真实账户，不同步 broker position，不读取真实 balance、real position、margin、leverage、buying power 或 real PnL。
- 不实现 live risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、stop trading command、account snapshot runtime、private stream runtime 或 Strategy / Trader runtime input。
- 不接 signed endpoint、account endpoint / listenKey，不创建 listenKey，不连接 private WebSocket，不连接 broker。
- 不暴露 real account payload、account endpoint payload、broker payload、broker state、Runtime object、Adapter request、SQLite / DuckDB schema、credential、secret、API key、listenKey 或 private WebSocket cursor。
- 不输出 broker command、executable order command、OMS order、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、stop / shutdown / restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-158 Paper / Live-neutral Proposal Command Isolation Validation

日期：2026-05-31

执行者：Codex

MTP-158 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-158 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-158 paper/live-neutral proposal contract、proposal attributes / status semantics、proposal-to-command isolation、no Execution Client / broker / OMS boundary、proposal forbidden command field guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-158 paper/live-neutral proposal shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-158 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 paper/live-neutral proposal command isolation anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-158 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-158 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、proposal-to-command isolation、no Execution Client / broker / OMS boundary 和 forbidden command field guard。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-158 必须建立的主要 anchors：

- `MTP-158-PAPER-LIVE-NEUTRAL-PROPOSAL-CONTRACT`
- `MTP-158-PROPOSAL-ATTRIBUTES-STATUS-SEMANTICS`
- `MTP-158-PROPOSAL-TO-COMMAND-ISOLATION`
- `MTP-158-NO-EXECUTION-CLIENT-BROKER-OMS`
- `MTP-158-PROPOSAL-FORBIDDEN-COMMAND-FIELD-GUARD`
- `MTP-158-PROPOSAL-CONTRACT-VALIDATION`

## MTP-158 禁止

- 不实现 order command、submit / cancel / replace、broker command、Execution Client、OMS、order generation engine、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`，不调用 signed endpoint、account endpoint / listenKey，不读取真实账户、broker position、margin、leverage、real PnL。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、stop / shutdown / restore 或 production operations command。
- 不暴露 executable order command、Execution Client request、OMS order、order id、client order id、broker order id、account id、broker account id、account endpoint payload、signed request、listenKey、Runtime object、Adapter request、broker adapter request 或 SQLite / DuckDB schema。
- 不把 price / quantity / side / timeInForce / orderType / venue 写成 executable order tuple。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-159 Forbidden Strategy / Execution / Broker / UI Command Tests Validation

日期：2026-05-31

执行者：Codex

MTP-159 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-159 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-159 forbidden Strategy -> Execution Client tests、forbidden broker command / OMS tests、forbidden UI command surface tests、proposal-to-command bypass guard、no signed/account endpoint / listenKey guard、deterministic local no-network test boundary 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-159 forbidden capability tests shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-159 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 forbidden Strategy / Execution / broker / UI command tests anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-159 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-159 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、proposal-to-command bypass guard、no endpoint / listenKey guard 和 local no-network boundary。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-159 必须建立的主要 anchors：

- `MTP-159-FORBIDDEN-STRATEGY-EXECUTION-CLIENT-TESTS`
- `MTP-159-FORBIDDEN-BROKER-COMMAND-OMS-TESTS`
- `MTP-159-FORBIDDEN-UI-COMMAND-SURFACE-TESTS`
- `MTP-159-PROPOSAL-TO-COMMAND-BYPASS-GUARD`
- `MTP-159-NO-SIGNED-ACCOUNT-ENDPOINT-LISTENKEY-GUARD`
- `MTP-159-DETERMINISTIC-LOCAL-NO-NETWORK-TEST-BOUNDARY`
- `MTP-159-FORBIDDEN-CAPABILITY-TESTS-VALIDATION`

## MTP-159 禁止

- 不实现 Strategy runtime、Trader runtime、order generation engine、Execution Client、broker command、OMS、order command、submit / cancel / replace、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不创建 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、adapter request、Runtime object、OMS facade、Execution Client stub、command bus、mock broker 或 hidden live fallback。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-160 Strategy Readiness Workbench / Report / Events Surface Validation

日期：2026-05-31

执行者：Codex

MTP-160 的 required validation：

- `swift test`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-160 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-160 Workbench / Report / Events strategy readiness read-model-only evidence surface、strategy readiness source chain、no command / runtime / schema / account boundary 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-160 strategy readiness surface shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-160 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Strategy readiness Workbench / Report / Events surface anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-160 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-160 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、source / test anchors、Dashboard smoke handle 和 no command / runtime / schema / account boundary strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-160 必须建立的主要 anchors：

- `MTP-160-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`
- `MTP-160-STRATEGY-READINESS-SOURCE-CHAIN`
- `MTP-160-NO-COMMAND-RUNTIME-SCHEMA-ACCOUNT-BOUNDARY`
- `MTP-160-STRATEGY-TRADER-READINESS-SURFACE-VALIDATION`

MTP-160 的 App evidence：

- `Sources/App/StrategyTraderReadinessEvidenceSurface.swift` 提供 deterministic read-model-only evidence surface 和 ViewModel。
- `Sources/App/App.swift` 将 surface 接入 Report / Dashboard read model 和 ViewModel，并保持 trading authorization 为 false。
- `Sources/App/PaperWorkflowEvidenceExplorer.swift` 新增 strategy readiness timeline section 和六条 read-model-only event items。
- `Sources/App/DashboardShell.swift` 将 surface 汇入 Workbench / Report metrics、details、boundary flags 和 Dashboard smoke handle `strategyTraderReadinessSurface=6`。
- `Tests/AppTests/AppTests.swift` 的 `testStrategyTraderReadinessSurfaceAggregatesMTP160WorkbenchReportEventsEvidence` 覆盖 record count、timeline items、Dashboard smoke、forbidden flags 和 Codable round trip。

## MTP-160 禁止

- 不新增或修改 Core semantics，不实现 Strategy runtime、Trader runtime、Execution Client、broker command、broker adapter、`LiveExecutionAdapter`、OMS、order command、submit / cancel / replace、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account endpoint payload、broker payload、broker state、credential、secret、API key 或 listenKey。
- 不新增 Strategy Console、Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-161 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-31

执行者：Codex

MTP-161 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-161 的验收要求：

- `docs/audit/inputs/mtpro-strategy-trader-instance-readiness-v1-stage-audit-input.md` 必须包含 `MTP-161-STRATEGY-TRADER-READINESS-STAGE-CLOSEOUT`、`MTP-161-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-161-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-161-STRATEGY-TRADER-READINESS-STAGE-AUDIT-INPUT`、`MTP-161-VALIDATION-EVIDENCE-CHAIN`、`MTP-161-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-161-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`、`MTP-161-AUTOMATION-READINESS-STAGE-CLOSEOUT`、`MTP-161-STAGE-CLOSEOUT-VALIDATION` 和 `MTP-161-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION` anchors。
- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-161 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness stage closeout 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-161 Strategy / Trader readiness stage closeout shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-161 issue backfill 和 `MTP-161 Strategy / Trader Readiness 阶段收口`。
- `docs/automation/automation-readiness.md` 必须新增 Strategy / Trader Instance readiness stage audit input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-161 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-161 stage audit input、contract、validation matrix、validation plan、latest summary、automation readiness doc、MTP-154 至 MTP-160 PR evidence、Dashboard smoke handle 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-161 必须建立的主要 anchors：

- `MTP-161-STRATEGY-TRADER-READINESS-STAGE-CLOSEOUT`
- `MTP-161-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-161-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-161-STRATEGY-TRADER-READINESS-STAGE-AUDIT-INPUT`
- `MTP-161-VALIDATION-EVIDENCE-CHAIN`
- `MTP-161-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-161-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-161-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-161-STAGE-CLOSEOUT-VALIDATION`
- `MTP-161-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

## MTP-161 禁止

- 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不启动 Root Docs Refresh Gate，不启动下一阶段 planning 或 execution。
- 不新增或修改 production code，不实现 Strategy runtime、Trader runtime、lifecycle runtime、quoter runtime、hedger runtime、Execution Client、broker command、broker adapter、`LiveExecutionAdapter`、OMS、order command、submit / cancel / replace、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account endpoint payload、broker payload、broker state、credential、secret、API key 或 listenKey。
- 不新增 Strategy Console、Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-162 Architecture Module Boundary Terminology Validation

日期：2026-06-01

执行者：Codex

MTP-162 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-162 的验收要求：

- `docs/domain/context.md` 必须包含 architecture-graph-aligned module boundary terminology、old-to-target module mapping、future-gated module name non-authorization 和 validation anchors。
- `docs/architecture/module-boundary.md` 必须包含 MTP-162 terminology contract 和 current runtime non-authorization anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 和 MTP-162 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Architecture graph module terminology anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-162 的当前 issue execution evidence，并把 Engine Module Boundary Consolidation 从 docs-only planning candidate 更新为 Linear-controlled active Project evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-162 domain context、architecture boundary、validation plan、validation matrix、latest summary、automation readiness doc、planning record、old target mapping、future-gated non-authorization 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-162 必须建立的主要 anchors：

- `MTP-162-ARCHITECTURE-GRAPH-ALIGNED-MODULE-BOUNDARY-TERMS`
- `MTP-162-OLD-TO-TARGET-MODULE-MAPPING`
- `MTP-162-FUTURE-GATED-MODULE-NAME-NON-AUTHORIZATION`
- `MTP-162-ARCHITECTURE-MODULE-TERMINOLOGY-VALIDATION`
- `MTP-162-TERMINOLOGY-CONTRACT`
- `MTP-162-CURRENT-RUNTIME-NON-AUTHORIZATION`

## MTP-162 禁止

- 不移动业务代码，不新增或修改 Swift production code，不修改 SwiftPM target，不做 source layout move。
- 不实现 Strategy runtime、Trader runtime、Live runtime、Portfolio runtime、Risk runtime、complete runtime MessageBus 或 current ExecutionClient implementation。
- 不实现 OMS implementation、broker / exchange execution adapter、`LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-163 Fixed Target Source Module Layout Validation

日期：2026-06-01

执行者：Codex

MTP-163 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-163 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 fixed target source module layout、dependency direction contract、forbidden path taxonomy、DataClient venue rule、Strategies strategy directory rule、Trader / Account / Portfolio split、ExecutionEngine / ExecutionClient split 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-163 fixed source layout shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 的 MTP-163 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Fixed target source module layout anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-163 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-163 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、target directory strings、dependency direction strings 和 forbidden path taxonomy strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-163 必须建立的主要 anchors：

- `MTP-163-FIXED-TARGET-SOURCE-MODULE-LAYOUT`
- `MTP-163-DEPENDENCY-DIRECTION-CONTRACT`
- `MTP-163-FORBIDDEN-PATH-TAXONOMY`
- `MTP-163-DATACLIENT-VENUE-STRATEGIES-STRATEGY-DIRECTORY-RULE`
- `MTP-163-TRADER-ACCOUNT-PORTFOLIO-SPLIT`
- `MTP-163-EXECUTIONENGINE-EXECUTIONCLIENT-SPLIT`
- `MTP-163-FIXED-LAYOUT-VALIDATION`

## MTP-163 禁止

- 不进行大规模文件移动，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不把旧 `Core / Adapters / Persistence / Runtime / App` 继续作为目标结构。
- 不实现 Strategy runtime、Trader runtime、Live runtime、Portfolio runtime、Risk runtime、MessageBus runtime 或 current ExecutionClient implementation。
- 不实现 OMS implementation、broker / exchange execution adapter、`LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-164 Architecture Boundary Validation Anchors

日期：2026-06-01

执行者：Codex

MTP-164 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-164 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 architecture boundary validation anchors、old path drift guard、future-gated implementation drift guard、forbidden capability drift guard、cross-milestone validation input 和 validation non-authorization。
- `docs/domain/context.md` 必须包含 MTP-164 shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-164 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Architecture boundary validation anchors row。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-164 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-164 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、old path drift guard、future-gated implementation drift guard 和 forbidden capability drift guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-164 必须建立的主要 anchors：

- `MTP-164-ARCHITECTURE-BOUNDARY-VALIDATION-ANCHORS`
- `MTP-164-OLD-PATH-DRIFT-GUARD`
- `MTP-164-FUTURE-GATED-IMPLEMENTATION-DRIFT-GUARD`
- `MTP-164-FORBIDDEN-CAPABILITY-DRIFT-GUARD`
- `MTP-164-CROSS-MILESTONE-VALIDATION-INPUT`
- `MTP-164-ARCHITECTURE-BOUNDARY-VALIDATION`

## MTP-164 禁止

- 不执行业务代码迁移，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不推进 M2-M6 后续 issue，不创建 L4 Project / Issue，不设置 Linear Project Completed。
- 不把 `Core / Adapters / Persistence / Runtime / App / Dashboard / CSQLite` 继续作为最终目标结构、长期新增能力落点或新 architecture module name。
- 不把 `ExecutionClient`、`OMSFutureGate`、`FuturePrivateStreamGate`、`FutureLiveProConsole`、`Strategy runtime`、`Trader runtime`、`Portfolio runtime`、`Risk runtime` 或完整 `MessageBus` 写成 current runtime implementation。
- 不实现 Strategy runtime、Trader runtime、Live runtime、Portfolio runtime、Risk runtime、MessageBus runtime 或 current ExecutionClient implementation。
- 不实现 OMS implementation、broker / exchange execution adapter、`LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-165 MessageBus / Command / Event Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-165 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-165 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 MessageBus facts / commands / events / request-response / paper routing / replay invariant 和 risk / execution bypass guard anchors。
- `docs/domain/context.md` 必须包含 MTP-165 MessageBus shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-165 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 MessageBus command event boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-165 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-165 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、facts / commands / events、request-response、paper routing / replay invariant、engine dependency bridge 和 risk / execution bypass guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-165 必须建立的主要 anchors：

- `MTP-165-MESSAGEBUS-FACTS-COMMANDS-EVENTS-CONTRACT`
- `MTP-165-REQUEST-RESPONSE-CONTRACT`
- `MTP-165-PAPER-ROUTING-REPLAY-INVARIANT`
- `MTP-165-ENGINE-DEPENDENCY-BRIDGE`
- `MTP-165-RISK-EXECUTION-BYPASS-GUARD`
- `MTP-165-MESSAGEBUS-BOUNDARY-VALIDATION`

## MTP-165 禁止

- 不实现完整 runtime MessageBus，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不把 MessageBus 写成 external message broker、live command bus、OMS bus、ExecutionClient request queue 或 UI command surface。
- 不通过 MessageBus 绕过 RiskEngine / ExecutionEngine boundary。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS implementation、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-166 Cache Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-166 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-166 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 Cache runtime-derived state、durability / schema separation、Database / MessageBus relationship 和 real account cache forbidden guard anchors。
- `docs/domain/context.md` 必须包含 MTP-166 Cache shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-166 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Cache runtime-derived state boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-166 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-166 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、runtime-derived state、durability / schema separation、Database / MessageBus relationship 和 real account cache forbidden guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-166 必须建立的主要 anchors：

- `MTP-166-CACHE-RUNTIME-DERIVED-STATE-CONTRACT`
- `MTP-166-CACHE-DURABILITY-SCHEMA-SEPARATION`
- `MTP-166-CACHE-DATABASE-MESSAGEBUS-RELATIONSHIP`
- `MTP-166-REAL-ACCOUNT-CACHE-FORBIDDEN-GUARD`
- `MTP-166-CACHE-BOUNDARY-VALIDATION`

## MTP-166 禁止

- 不实现 Redis、external cache service，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不把 Cache 写成 durable source of truth、Database schema owner、DB adapter、UI contract、broker account cache、real account cache 或 broker state mirror。
- 不通过 Cache 绕过 MessageBus、Database、DataEngine、Portfolio、RiskEngine 或 ExecutionEngine boundary。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS implementation、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、buying power、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。
