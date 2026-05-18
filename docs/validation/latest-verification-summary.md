# 最近验证摘要

日期：2026-05-19

执行者：Codex

## 定位

本文档是 MTPRO 最近一次验证摘要。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不是协议事实源，不替代 PR evidence、Linear evidence 或 `verification.md` 完整历史。

## 最近基线

- 最近验证关联 Linear Project：`MTPRO Trading Validation and Parity Hardening`。
- 最近验证对象：Project 级 Stage Code Audit Report 落仓。
- Project Planning Record：`docs/planning/projects/mtpro-trading-validation-and-parity-hardening-plan.md`。
- Stage Code Audit Report：`docs/audit/mtpro-trading-validation-and-parity-hardening-stage-code-audit.md`。
- Linear 只读查询确认：`MTP-24` 至 `MTP-30` 全部为 `Done`。
- 当前 Project 无 `Todo` / `In Progress` / `In Review` active conflict。
- Project 完成时 main 为 `4e694f96c56eff07d39267a799083474d7c1c9f5`。
- MTP-24 已定义 `docs/validation/trading-validation-matrix.md`，并把 `TVM-EMA-PARITY`、`TVM-ORDER-BOOK-IMBALANCE-PARITY`、`TVM-FEES-SLIPPAGE`、`TVM-RISK-BLOCKER`、`TVM-PORTFOLIO-EXPOSURE`、`TVM-REPORT-EVIDENCE` 和 `TVM-FUTURE-ISSUE-BACKFILL` 固定为 automation readiness 锚点。
- MTP-25 已完成 EMA Backtest / Paper signal timeline parity 加固，覆盖同一 strategy、同一 `MarketDataQuery`、query range、warm-up 后首个 signal timestamp 和 query range 过窄拒绝边界。
- MTP-26 已完成 Order Book Imbalance research parity 和 bias evidence 加固，覆盖 snapshot / delta input source、direct contract 与 research event flow parity，以及 ask dominance research-only 边界。
- MTP-27 已完成 fixed fees / slippage evidence，使用 deterministic cost assumption `mtp-27-fixed-cost-assumptions`，不代表 Binance 实际费率、真实成交、broker fill 或账户成本。
- MTP-28 已完成 risk blocker evidence 和 paper-only portfolio exposure read model，覆盖 blocker reason、source sequence、gross exposure notional 和 read-only ViewModel。
- MTP-29 已将 projection-level parity、fees / slippage cost evidence、risk blocker evidence 和 portfolio exposure evidence 汇总到 Report / Dashboard read model。
- MTP-30 新增 `docs/validation/mtp-30-stage-audit-input.md`，集中记录 Issue / PR evidence、merge commit、required check、matrix evidence chain、known boundaries、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- MTP-30 更新 `docs/validation/trading-validation-matrix.md` 的阶段收口说明，并在 `docs/validation/validation-plan.md` 记录 MTP-30 required validation。
- Stage Code Audit Report 已记录 `MTP-24` 至 `MTP-30` 全部 Done、PR #52 / #53 / #55 / #56 / #57 / #58 / #59 evidence、validation、boundary audit、Root Docs Delta 和 Next Human Project Planning handoff。
- 上一阶段 Stage Code Audit Report 已记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界，并确认审计报告覆盖完整 Linear Project；本 Project 目前未记录新增临时 CI 平台边界。
- 本 Project Stage Code Audit Report 已记录 Known CI Boundary：无当前 main 遗留 failing PR run；`MTP-24` 至 `MTP-30` 对应 PR checks 均已通过并合并。
- Project 全部 Done 后，Stage Code Audit Report 必须包含 Root Docs Delta，并先完成 Root Docs Refresh Gate，才进入 Next Human Project Planning；本轮已完成该落仓动作。
- Root Docs Refresh Gate 只允许 `@002 / PAR` 同步 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 中已发生的事实；方向性变化交给 Human + `@001 / PLN`。
- `graphify-out/*` 未提交，`.codex/*` 未提交。
- 本轮执行上下文中的 `symphony-issue` active Project pointer 指向 `mtpro-trading-validation-and-parity-hardening-4286a197bec0`；child Codex 不修改 pointer，本文档不作为 current issue 或 queue pointer 的事实源。
- 下一阶段 Project Planning Record 已落仓：`docs/planning/projects/mtpro-paper-session-runtime-v1-plan.md`。
- `MTPRO Paper Session Runtime v1` 尚未写入 Linear；未创建 Linear Project / Issues，未修改 Linear status，未推进 Todo，未启动 Symphony。
- `MTPRO Paper Session Runtime v1` planning record 只保存 Project 级计划摘要和格式门槛；完整 issue execution contract 以 Linear issue body 为准。

## Project PR evidence

| Issue | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- |
| `MTP-24` | [#52 MTP-24 定义 Trading Validation Matrix](https://github.com/atxinbao/MTPRO/pull/52) | `210a8acbc04193ff7782b8d8de7bcfe9f31a8e99` | `checks` success |
| `MTP-25` | [#53 MTP-25 harden EMA parity validation](https://github.com/atxinbao/MTPRO/pull/53) | `0329e7c88b567d369bef3887311c0aba8a992fa7` | `checks` success |
| `MTP-26` | [#55 MTP-26 harden order book imbalance parity evidence](https://github.com/atxinbao/MTPRO/pull/55) | `babd7303f5caa90921e9d5d712d49e330a88b61d` | `checks` success |
| `MTP-27` | [#56 MTP-27 define fixed execution cost evidence](https://github.com/atxinbao/MTPRO/pull/56) | `fdfd25da8a4342ed0a5bc7089737644a6e29d6a4` | `checks` success |
| `MTP-28` | [#57 Add risk blocker and portfolio exposure evidence](https://github.com/atxinbao/MTPRO/pull/57) | `a42018fc61c65937e4c39a7fe01e732671653b42` | `checks` success |
| `MTP-29` | [#58 MTP-29 汇总 Report / Dashboard 交易验证证据](https://github.com/atxinbao/MTPRO/pull/58) | `f34fc38c036210ec90f60f5ec465f9482eac027e` | `checks` success |
| `MTP-30` | [#59 MTP-30 加固验证文档和阶段审计输入](https://github.com/atxinbao/MTPRO/pull/59) | `4e694f96c56eff07d39267a799083474d7c1c9f5` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26046045767/job/76570399101) |

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 由 `bash checks/run.sh` 串联执行，当前 diff 无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；MTP-30 Stage Code Audit input 锚点、Trading Validation Matrix 锚点和 automation readiness 锚点完整。 |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 66 个 XCTest 通过；验证既有 Core / Adapters / Persistence / Runtime / App coverage 在 MTP-30 文档收口后未回归。 |
| `bash checks/run.sh` | pass | 首次本地增量构建在 `swift test` 链接阶段命中旧符号缓存；执行 `swift package clean` 后重新运行同一入口通过，66 个 XCTest 0 failures，输出 `MTPRO checks passed.` |
| Stage Code Audit Report | pass | 已落仓到 `docs/audit/mtpro-trading-validation-and-parity-hardening-stage-code-audit.md`；覆盖 Project 结论、Issue / PR evidence、Validation、Boundary Audit、Known CI Boundary、Root Docs Delta 和 Next Human Project Planning handoff。 |

## 当前边界

- MTP-30 只收口 validation summary、trading validation matrix、automation evidence 和 Stage Code Audit input；最终 Stage Code Audit Report 已由 Parent Codex 单独落仓。
- Trading Validation Matrix 是 evidence routing 入口，不替代 Linear issue contract、PR evidence 或 Stage Code Audit Report。
- `docs/validation/mtp-30-stage-audit-input.md` 是阶段审计输入材料，不授权下一 Project planning 或 execution。
- `MTPRO Trading Validation and Parity Hardening` planning record 不单独授权执行。
- `MTPRO Paper Session Runtime v1` planning record 不授权执行，不创建 Linear Project / Issues，不修改 Linear status，不推进 Todo。
- Report 输入只来自 projection snapshots / read model 和 append-only event timeline。
- Report 可汇总 projection-level Backtest / Paper evidence，但不替代 Core 层完整 signal timeline parity。
- `ReportExecutionCostEvidence` 只从 deterministic fixture 和 paper-only exposure projection 派生，不读取交易所费率表、account tier、真实成交或 broker fill。
- `RiskBlockerEvidence` 只代表本地 Paper 风险阻断证据，不代表真实 broker 拒单、account state 或 Live fallback。
- `PortfolioExposureSnapshot` 只代表 Paper projection 派生的 gross exposure evidence，不代表真实账户余额、margin、leverage、broker position 或真实成交。
- `ReportViewModel` / `DashboardShellSnapshot` 只展示稳定 read model projection，不提供 report execution command、risk control command、position management command 或交易执行入口。
- 不做完整报表系统、交易所费率表、动态滑点模型、执行成本优化、完整风险引擎、实时风控、仓位管理、保证金、杠杆、真实账户余额或完整 Paper execution 工作流。
- 不修改 Linear status。
- 不创建 Linear Project / Issue。
- 不启动 Symphony。
- 不运行 Graphify full rebuild。
- 不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## 完整历史

完整验证流水账见 `../../verification.md`。
