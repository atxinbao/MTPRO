# 最近验证摘要

日期：2026-05-19

执行者：Codex

## 定位

本文档是 MTPRO 最近一次验证摘要。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不是协议事实源，不替代 PR evidence、Linear evidence 或 `verification.md` 完整历史。

## 最近基线

- 最近验证关联 Linear Project：`MTPRO Paper Session Runtime v1`。
- 最近验证对象：`MTP-34` 新增 paper-only portfolio projection update path 的本地 pre-PR 验证。
- Linear 只读查询确认：`MTP-34` 为 `In Progress`；同 Project 内 `MTP-31` / `MTP-32` / `MTP-33` 为 `Done`，`MTP-35` 至 `MTP-37` 均为 `Backlog`。
- 当前 issue 不修改 Linear status，不启动 Symphony，不解锁下一 issue。
- 上一完成 Project 为 `MTPRO Trading Validation and Parity Hardening`，main 为 `4e694f96c56eff07d39267a799083474d7c1c9f5`。
- MTP-24 已定义 `docs/validation/trading-validation-matrix.md`，并把 `TVM-EMA-PARITY`、`TVM-ORDER-BOOK-IMBALANCE-PARITY`、`TVM-FEES-SLIPPAGE`、`TVM-RISK-BLOCKER`、`TVM-PORTFOLIO-EXPOSURE`、`TVM-REPORT-EVIDENCE` 和 `TVM-FUTURE-ISSUE-BACKFILL` 固定为 automation readiness 锚点。
- MTP-25 已完成 EMA Backtest / Paper signal timeline parity 加固，覆盖同一 strategy、同一 `MarketDataQuery`、query range、warm-up 后首个 signal timestamp 和 query range 过窄拒绝边界。
- MTP-26 已完成 Order Book Imbalance research parity 和 bias evidence 加固，覆盖 snapshot / delta input source、direct contract 与 research event flow parity，以及 ask dominance research-only 边界。
- MTP-27 已完成 fixed fees / slippage evidence，使用 deterministic cost assumption `mtp-27-fixed-cost-assumptions`，不代表 Binance 实际费率、真实成交、broker fill 或账户成本。
- MTP-28 已完成 risk blocker evidence 和 paper-only portfolio exposure read model，覆盖 blocker reason、source sequence、gross exposure notional 和 read-only ViewModel。
- MTP-29 已将 projection-level parity、fees / slippage cost evidence、risk blocker evidence 和 portfolio exposure evidence 汇总到 Report / Dashboard read model。
- MTP-30 新增 `docs/validation/mtp-30-stage-audit-input.md`，集中记录 Issue / PR evidence、merge commit、required check、matrix evidence chain、known boundaries、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- MTP-30 更新 `docs/validation/trading-validation-matrix.md` 的阶段收口说明，并在 `docs/validation/validation-plan.md` 记录 MTP-30 required validation。
- Stage Code Audit Report 已记录 `MTP-24` 至 `MTP-30` 全部 Done、PR #52 / #53 / #55 / #56 / #57 / #58 / #59 evidence、validation、boundary audit、Root Docs Delta 和 Next Human Project Planning handoff。
- MTP-31 新增 `PaperSessionLifecycleState`、`PaperSessionStarted`、`PaperSessionUpdated`、`PaperSessionClosed` 和 `PaperSessionEventLogBoundary`，默认 Paper event flow 输出 `started -> signalGenerated... -> updated -> closed`。
- MTP-31 已将 `TVM-PAPER-SESSION-LIFECYCLE` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 paper-only event log 写入边界。
- MTP-32 新增 `PaperActionProposalSide`、`PaperActionProposalSizingAssumption`、`PaperActionProposal`、`PaperActionProposalAuthorization` 和 `PaperActionProposalFixture`。
- MTP-32 将 `long` strategy signal 映射为 paper-only `buy` intent，将 `flat` signal 映射为 `hold` intent，并复用 MTP-27 deterministic fixed cost evidence 生成 notional / fee / slippage evidence。
- MTP-32 已将 `TVM-PAPER-ACTION-PROPOSAL` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 proposal 不代表 order、fill、portfolio update、broker action 或 Live execution。
- MTP-33 新增 `PaperActionProposalRiskPolicy`、`PaperActionProposalRiskDecision`、`PaperActionProposalRiskLink` 和 `PaperActionProposalRiskFixture`。
- MTP-33 将 MTP-32 proposal 转换为 `RiskEvaluationQuery`，并在 deterministic policy 阻断时复用 `RiskBlockerEvidence`，记录 blocker reason、source sequence 和 paper-only context。
- MTP-33 已将 `TVM-RISK-BLOCKER` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 allowed / blocked evidence 不代表真实风控、broker rejection、真实订单授权或 Live fallback。
- MTP-34 新增 `PaperPortfolioProjectionUpdate`，只允许 MTP-33 allowed risk decision 生成 `PortfolioEvent.paperProjectionUpdated`，blocked decision 不更新 portfolio projection。
- MTP-34 已将 `TVM-PORTFOLIO-EXPOSURE` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 replay / SQLite projection / ViewModel 只读链路。
- 上一阶段 Stage Code Audit Report 已记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界，并确认审计报告覆盖完整 Linear Project；本 Project 目前未记录新增临时 CI 平台边界。
- 上一 Project Stage Code Audit Report 已记录 Known CI Boundary：无 main 遗留 failing PR run；`MTP-24` 至 `MTP-30` 对应 PR checks 均已通过并合并。
- 当前 Project 全部 Done 后，Stage Code Audit Report 必须包含 Root Docs Delta，并先完成 Root Docs Refresh Gate，才进入 Next Human Project Planning；MTP-31 不输出阶段审计报告。
- Root Docs Refresh Gate 只允许 `@002 / PAR` 同步 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 中已发生的事实；方向性变化交给 Human + `@001 / PLN`。
- 下一阶段 Project Planning Record 已落仓：`docs/planning/projects/mtpro-paper-session-runtime-v1-plan.md`。
- `MTPRO Paper Session Runtime v1` planning record 只保存 Project 级计划摘要和格式门槛；完整 issue execution contract 以 Linear issue body 为准。
- 历史 planning record 曾记录 `尚未写入 Linear`；该状态只用于解释 planning record 生成时点，不代表当前 MTP-31 执行状态。
- `graphify-out/*` 不提交，`.codex/*` 不提交。
- 本文档不作为 current issue 或 queue pointer 的事实源；当前 issue 状态必须继续从 Linear live read 获取。

## 上一 Project PR evidence

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
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；MTP-30 Stage Code Audit input、Trading Validation Matrix 和 automation readiness 锚点完整。 |
| `swift build --product MTPRODashboard` | pass | macOS dashboard executable 构建通过。 |
| `MTPRO_DASHBOARD_SMOKE=1 swift run MTPRODashboard` | pass | 输出 `MTPRO Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 77 个 XCTest 通过；新增覆盖 `PaperPortfolioProjectionUpdate` allowed path、blocked decision 拒绝、Codable 交易能力禁区、SQLite replay projection update 和 Portfolio ViewModel read-model-only 边界。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 通过；77 个 XCTest 0 failures，输出 `MTPRO checks passed.` |

## 当前边界

- MTP-31 只定义 Paper Session lifecycle facts 和 event log 写入边界；不实现 action proposal、portfolio projection update 或完整 Paper execution engine。
- MTP-32 只定义 Paper action proposal value model 和 deterministic fixture；不新增 order command、Paper action event log 写入、portfolio projection update 或完整 Paper execution engine。
- MTP-33 只定义 Paper action proposal -> risk blocker 的 Core 本地 evidence 链路；不新增 Paper action event log 写入、portfolio projection update、完整风险引擎、broker rejection fallback 或完整 Paper execution workflow。
- MTP-34 只定义 allowed risk decision -> paper-only portfolio projection update 的本地链路；不新增 Paper action event log 写入、完整 portfolio management、真实账户余额读取、margin、leverage、broker position sync 或完整 Paper execution workflow。
- Paper action proposal 固定 `executionMode == paper`、`executionAuthorization == paperIntentOnly` 且 `isExecutableAsRealOrder == false`。
- Paper action risk decision 的 allowed / blocked 结果都不提供 broker fallback 或 Live execution fallback；allowed 不代表真实订单授权，blocked 不代表真实 broker 拒单。
- Trading Validation Matrix 是 evidence routing 入口，不替代 Linear issue contract、PR evidence 或 Stage Code Audit Report。
- `docs/validation/mtp-30-stage-audit-input.md` 是阶段审计输入材料，不授权下一 Project planning 或 execution。
- `MTPRO Trading Validation and Parity Hardening` planning record 不单独授权执行。
- `MTPRO Paper Session Runtime v1` planning record 不授权执行；当前执行授权来自 Linear live-read 的 `MTP-34` issue contract。
- Paper lifecycle events 只代表本地 paper-only facts，不代表真实订单、broker session、account state、成交、仓位或资金。
- Report 输入只来自 projection snapshots / read model 和 append-only event timeline。
- Report 可汇总 projection-level Backtest / Paper evidence，但不替代 Core 层完整 signal timeline parity。
- `ReportExecutionCostEvidence` 只从 deterministic fixture 和 paper-only exposure projection 派生，不读取交易所费率表、account tier、真实成交或 broker fill。
- `RiskBlockerEvidence` 只代表本地 Paper 风险阻断证据，不代表真实 broker 拒单、account state 或 Live fallback。
- `PortfolioExposureSnapshot` 只代表 Paper projection 派生的 gross exposure evidence，不代表真实账户余额、margin、leverage、broker position 或真实成交。
- `ReportViewModel` / `DashboardShellSnapshot` 只展示稳定 read model projection，不提供 report execution command、risk control command、position management command 或交易执行入口。
- 不做完整报表系统、交易所费率表、动态滑点模型、执行成本优化、完整风险引擎、实时风控、仓位管理、保证金、杠杆、真实账户余额或完整 Paper execution 工作流。
- 不实现 broker rejection fallback。
- 不修改 Linear status。
- 不创建 Linear Project / Issue。
- 不启动 Symphony。
- 不运行 Graphify full rebuild。
- 不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单行为。
- 不提交 `.codex/*`。
- 不提交 `graphify-out/*`。

## 完整历史

完整验证流水账见 `../../verification.md`。
