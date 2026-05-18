# 最近验证摘要

日期：2026-05-18

执行者：Codex

## 定位

本文档是 MTPRO 最近一次验证摘要。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不是协议事实源，不替代 PR evidence、Linear evidence 或 `verification.md` 完整历史。

## 最近基线

- 最近验证关联 Linear Project：`MTPRO Trading Validation and Parity Hardening`。
- 最近验证对象：`MTP-27`，目标是定义 fees / slippage assumptions、deterministic fixture 和最小计算边界。
- Project Planning Record：`docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`。
- 执行事实源是 Linear `MTP-27` issue body；planning record 不单独授权执行。
- Linear 只读查询确认：`MTP-24`、`MTP-25` 和 `MTP-26` 为 `Done`，`MTP-27` 为 `In Progress`，`MTP-28` 至 `MTP-30` 仍为 `Backlog`。
- 本轮新增 Core-only `ExecutionCostAssumptions`、`ExecutionCostEstimateRequest`、`ExecutionCostCalculator`、`ExecutionCostParity` 和 `ExecutionCostParityResult`。
- 本轮 deterministic fixture 固定 maker fee `2 bps`、taker fee `5 bps`、fixed slippage `1.5 bps` 和 `8` 位小数 rounding scale；该 fixture 只服务本地测试和 PR evidence，不代表 Binance 实际费率。
- 本轮更新 `docs/validation/trading-validation-matrix.md` 中 `TVM-FEES-SLIPPAGE` 的 MTP-27 回填证据，并在 `docs/validation/validation-plan.md` 记录 MTP-27 required validation。
- MTP-25 已完成并加固 EMA Backtest / Paper signal timeline parity；MTP-26 已完成并加固 Order Book Imbalance research parity 和 bias evidence。
- 上一阶段 Stage Code Audit Report 已记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界，并确认审计报告覆盖完整 Linear Project；本轮 MTP-27 未新增临时 CI 平台边界。
- Project 全部 Done 后，Stage Code Audit Report 必须包含 Root Docs Delta，并先完成 Root Docs Refresh Gate，才进入 Next Human Project Planning。
- Root Docs Refresh Gate 只允许 `@002 / PAR` 同步 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 中已发生的事实；方向性变化交给 Human + `@001 / PLN`。
- `graphify-out/*` 未提交，`.codex/*` 未提交。
- 本轮执行上下文中的 `symphony-issue` active Project pointer 指向 `mtpro-trading-validation-and-parity-hardening-4286a197bec0`；child Codex 不修改 pointer，本文档不作为 current issue 或 queue pointer 的事实源。

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `swift test --filter CoreTests/testExecutionCost` | pass | 3 个 CoreTests 通过；覆盖 maker / taker fee、fixed slippage、gross notional、total cost、rounding scale、Backtest / Paper cost parity 和 invalid assumptions。 |
| `git diff --check` | pass | 由 `bash checks/run.sh` 串联执行，当前 diff 无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；Trading Validation Matrix 锚点仍完整。 |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 65 个 XCTest 通过；新增 MTP-27 fixed execution cost evidence coverage。 |
| `bash checks/run.sh` | pass | macOS 本地执行 `git diff --check`、automation readiness、dashboard build、dashboard smoke run 和 `swift test` 通过；输出 `MTPRO checks passed.` |
| Stage Code Audit Report | n/a | 当前 Project 尚未全部 Done；Project 级 Stage Code Audit Report 仍须在 MTP-24 至 MTP-30 全部 Done 后由 Parent Codex 输出。 |

## 当前边界

- MTP-27 只定义 fixed fees / slippage assumptions、deterministic fixture、最小计算输出、Backtest / Paper cost parity 和矩阵回填，不授权 MTP-28 或其他后续 issue。
- Trading Validation Matrix 是 evidence routing 入口，不替代 Linear issue contract、PR evidence 或 Stage Code Audit Report。
- `MTPRO Trading Validation and Parity Hardening` planning record 不单独授权执行。
- 当前 planning record 不创建 Linear Project / Issues，不替代 Linear issue body。
- `ExecutionCostAssumptions.deterministicFixture` 只代表本地测试假设，不代表 Binance 实际费率、账户等级、交易所费率表或真实成交成本。
- `ExecutionCostCalculator` 只计算 gross notional、fee amount、slippage amount 和 total cost evidence，不生成 order、fill、position、account balance 或 broker action。
- `ExecutionCostParity` 只比较 Backtest / Paper fixed cost evidence，不触发 Paper execution 工作流或 Live execution。
- Report 输入只来自 projection snapshots / read model 和 append-only event timeline。
- Report 只表达 projection-level Backtest / Paper evidence，不替代 Core 层完整 signal timeline parity。
- 不做完整费用模型、动态滑点模型、执行成本优化或完整 Paper execution 工作流。
- 不修改 Linear status。
- 不创建 Linear Project / Issue。
- 不启动 Symphony。
- 不运行 Graphify full rebuild。
- 不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## 完整历史

完整验证流水账见 `../../verification.md`。
