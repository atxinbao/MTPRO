# MTPRO Trading Validation and Parity Hardening

日期：2026-05-18

执行者：Codex

本文档是写入 Linear 前的 Project Planning Record，只记录 Project 级计划摘要和 issue 列表摘要。

本文档不授权执行，不创建 Linear Project，不创建 Linear Issues，不修改 Linear status，不启动 symphony-issue，不运行 Graphify update，不写业务代码。

完整 issue execution contract 以 Linear 为准。

## Project name

`MTPRO Trading Validation and Parity Hardening`

## Project goal

将 `MTPRO Runtime Research Workbench v1` 已完成的 projection-level research workflow，推进为更可信的交易语义验证层，重点加固：

- Core 层 Backtest / Paper signal timeline parity。
- fees / slippage 假设、测试夹具和最小计算边界。
- risk blocker / evidence。
- 最小 portfolio-level exposure 只读指标。
- Report / Dashboard 中交易验证证据的可追溯性。

本 Project 只做 research / backtest / paper readiness 验证，不进入 Live trading。

## Scope

- 建立可落仓、可被 automation readiness 检查的 trading validation matrix。
- 加固 EMA / order book imbalance 的 Backtest / Paper parity 验证。
- 定义 fees / slippage 假设、fixture 和最小计算边界。
- 建立 risk blocker evidence 和最小 portfolio exposure read model。
- 将交易验证 evidence 汇入 Report / Dashboard read model。
- 加固验证文档、PR evidence 和 Stage Code Audit 输入。

## Non-goals

- 不实现 `LiveExecutionAdapter`。
- 不接 signed endpoint / account endpoint。
- 不做真实 broker action。
- 不提交、取消或替换真实订单。
- 不做完整费用模型。
- 不做交易所费率表。
- 不做动态滑点模型。
- 不做执行成本优化。
- 不做完整风险引擎。
- 不做实时风控、仓位管理、保证金、杠杆。
- 不做完整 Paper execution 工作流。
- 不做 UI 大改版。

## Issue order

| 顺序 | Issue 标题 | 目标摘要 | 依赖摘要 |
| --- | --- | --- | --- |
| 1 | 定义 Trading Validation Matrix 和验收证据边界 | 新增或更新 `docs/validation/trading-validation-matrix.md`，记录交易验证矩阵、automation readiness 锚点和现有测试 / fixture coverage 入口。 | 无 |
| 2 | 加固 EMA Backtest / Paper signal timeline parity | 加固 EMA strategy config、market data query、warm-up、signal direction、timestamp 的一致性断言，并映射回 trading validation matrix。 | 依赖 Issue 1 |
| 3 | 加固 Order Book Imbalance research parity 和 bias evidence | 加固 order book imbalance fixture、bias evidence 和 research-only 边界，并映射回 trading validation matrix。 | 依赖 Issue 1 |
| 4 | 定义 fees / slippage 假设、fixture 和最小计算边界 | 定义 fee / slippage 假设、fixture 和最小计算接口，不进入完整费用模型或动态滑点。 | 依赖 Issue 1 |
| 5 | 新增 risk blocker evidence 和最小 portfolio exposure 只读指标 | 建立 risk blocker evidence 和最小 portfolio-level exposure read model。 | 依赖 Issue 2、Issue 3、Issue 4 |
| 6 | 汇总 trading validation evidence 到 Report / Dashboard read model | 将 parity、fees / slippage、risk blocker 和 exposure evidence 汇入 Report / Dashboard read model。 | 依赖 Issue 5 |
| 7 | 加固验证文档、automation evidence 和阶段审计输入 | 收口 validation summary、evidence matrix、已知边界和 Stage Code Audit 输入。 | 依赖 Issue 6 |

仓库不复制维护 7 个 issue 的完整正文。后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。

## Dependencies

- Issue 2 依赖 Issue 1。
- Issue 3 依赖 Issue 1。
- Issue 4 依赖 Issue 1。
- Issue 5 依赖 Issue 2、Issue 3、Issue 4。
- Issue 6 依赖 Issue 5。
- Issue 7 依赖 Issue 6。

## Validation requirements

每个 issue 都必须运行：

```bash
bash checks/run.sh
```

交易相关 issue 必须补充：

- 策略假设。
- market data symbol / timeframe 范围。
- Backtest / Paper parity 验收方式。
- fees / slippage 是否进入当前 scope。
- risk blocker 或 exposure evidence。
- 不触碰 Live trading / signed endpoint / broker action 的证据。

## Evidence requirements

每个 PR 必须包含：

- Linked Linear Issue。
- Scope / Non-goals 确认。
- `bash checks/run.sh` 摘要。
- Pre-PR Codex Code Review。
- GitHub PR Automation evidence。
- `.codex/*` 未进入 PR。
- `graphify-out/*` 未进入 PR。
- 如由 symphony-issue 执行，需 handoff marker evidence。
- 涉及生产代码时，必须包含详细中文注释。

## First executable issue candidate

第一个可执行候选 issue：

```text
定义 Trading Validation Matrix 和验收证据边界
```

初始状态仍必须是 `Backlog / non-executable`。@001 / PLN 不操作 `Backlog -> Todo`。

## WIP=1

- 所有 issue 初始状态必须是 `Backlog / non-executable`。
- 同一时间最多一个 issue 可进入 `Todo`。
- @001 / PLN 不操作 `Backlog -> Todo`。
- 只有 Parent Codex 在 Human-approved Project 内通过 queue preflight 后，才能推进唯一 eligible issue。
- 本文档不授权执行。

## Linear write boundary

- 本文档不创建 Linear Project。
- 本文档不创建 Linear Issues。
- 本文档不修改 Linear status。
- Human review / merge 后，才允许进入 Linear 写入。
- Linear 写入后，所有 issue 初始必须保持 Backlog / non-executable。
- 完整 issue execution contract 以 Linear 为准。

## Repository record boundary

- 仓库只保存 Project 级计划摘要和格式门槛。
- 仓库不复制维护完整 issue 正文。
- 后续 issue scope、Codex instructions、validation、boundary、PR requirements 以 Linear issue body 为准。
- 本文档不授权执行。
