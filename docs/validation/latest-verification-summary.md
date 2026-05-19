# 最近验证摘要

日期：2026-05-19

执行者：Codex

## 定位

本文档是 MTPRO 最近一次验证摘要。

Agent / Graphify 默认读取本文档，不默认读取完整 `verification.md`。

完整 `verification.md` 只用于审计、追溯和 debug。

本文档不是协议事实源，不替代 PR evidence、Linear evidence 或 `verification.md` 完整历史。

## 最近基线

- 最近验证关联 Linear Project：MTPRO 历史 Project closure 状态和 Project Completed Gate。
- 最近验证对象：Linear Project `Completed` 状态修正，以及 Parent Codex / Stage Code Audit / Next Human Project Planning 规则收口。
- Stage Code Audit Report 记录：`MTP-31` 至 `MTP-37` 全部为 `Done`，PR #62 至 #68 均通过 GitHub required check 后合并。
- 本轮 Root Docs Refresh Gate 只同步已发生事实；不修改 Linear status，不启动 Symphony，不解锁下一 issue。
- `MTPRO Paper Session Runtime v1` planning record 已落仓到 `docs/planning/projects/mtpro-paper-session-runtime-v1-plan.md`；完整 issue execution contract 以 Linear issue body 为准。
- `MTPRO Runtime Research Workbench v1`、`MTPRO Trading Validation and Parity Hardening`、`MTPRO Paper Session Runtime v1` 已在 Linear 修正为 Project status `Completed`，且 Linear 返回 `type=completed`、`completedAt` 非空。
- `MTPRO Paper Execution Workflow v1` Project-level planning record 已落仓到 `docs/planning/projects/mtpro-paper-execution-workflow-v1-plan.md`，并已写入 Linear；当前 Project status 仍为 `Planned`，尚未完成。
- `MTPRO Paper Execution Workflow v1` 写入 Linear 不单独授权执行；正式执行仍必须来自 Linear live-read 的唯一 configured executable issue。
- `MTPRO Paper Execution Workflow v1` planning record 只保存 Project 级计划摘要和格式门槛，不复制维护完整 Linear issue body；完整 issue execution contract 以后以 Linear issue body 为准。
- Project 写入 Linear 后，所有 issue 初始必须保持 `Backlog / non-executable`；后续由 Parent Codex queue preflight 自动判断唯一 eligible issue，并在 WIP=1、依赖满足、无 active conflict、execution contract 格式完整时推进 Todo。
- Project 全部有效 issues `Done` 只是 Project closure 前置条件；Parent Codex 必须将 Linear Project status 设置或确认为 `Completed`，并记录 `type=completed`、`completedAt` 非空后，才能进入 Stage Code Audit Report。
- Linear Project status `Completed` 是 Stage Code Audit Report 和 Next Human Project Planning 前的 Project closure gate。
- 本轮 MTP-38 paper-only execution workflow contract 已通过 `git diff --check`、`bash checks/automation-readiness.sh`、Dashboard build / smoke 和 `swift test`；MTPRO 本地验证为 82 个 XCTest 0 failures。
- 本轮 Dashboard source naming 收口已将 SwiftPM executable product / target 改为 `Dashboard`，源码目录改为 `Sources/Dashboard`，入口文件改为 `DashboardApplication.swift`，smoke 命令改为 `DASHBOARD_SMOKE=1 swift run Dashboard`。
- 历史 planning record 曾记录 `尚未写入 Linear`；该状态只解释 planning record 生成时点，不代表 Project 完成后的审计状态。
- MTP-30 新增 `docs/audit/inputs/mtpro-trading-validation-and-parity-hardening-stage-audit-input.md`，集中记录 `MTP-24` 至 `MTP-30` 的 Issue / PR evidence、merge commit、required check、matrix evidence chain、known boundaries、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `MTPRO Trading Validation and Parity Hardening` Stage Code Audit Report 已落仓，记录 `MTP-24` 至 `MTP-30` 全部 Done、PR #52 / #53 / #55 / #56 / #57 / #58 / #59 evidence、validation、boundary audit、Root Docs Delta 和 Next Human Project Planning handoff。
- MTP-31 新增 `PaperSessionLifecycleState`、`PaperSessionStarted`、`PaperSessionUpdated`、`PaperSessionClosed` 和 `PaperSessionEventLogBoundary`，默认 Paper event flow 输出 `started -> signalGenerated... -> updated -> closed`。
- MTP-31 已将 `TVM-PAPER-SESSION-LIFECYCLE` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 paper-only event log 写入边界。
- MTP-32 新增 `PaperActionProposalSide`、`PaperActionProposalSizingAssumption`、`PaperActionProposal`、`PaperActionProposalAuthorization` 和 `PaperActionProposalFixture`。
- MTP-32 已将 `TVM-PAPER-ACTION-PROPOSAL` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 proposal 不代表 order、fill、portfolio update、broker action 或 Live execution。
- MTP-33 新增 `PaperActionProposalRiskPolicy`、`PaperActionProposalRiskDecision`、`PaperActionProposalRiskLink` 和 `PaperActionProposalRiskFixture`。
- MTP-33 已将 `TVM-RISK-BLOCKER` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 allowed / blocked evidence 不代表真实风控、broker rejection、真实订单授权或 Live fallback。
- MTP-34 新增 `PaperPortfolioProjectionUpdate`，只允许 MTP-33 allowed risk decision 生成 `PortfolioEvent.paperProjectionUpdated`，blocked decision 不更新 portfolio projection。
- MTP-34 已将 `TVM-PORTFOLIO-EXPOSURE` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 replay / SQLite projection / ViewModel 只读链路。
- MTP-35 新增 `PaperEvent.actionProposed`、`PaperSessionReplayEvidenceSummary`、`PaperSessionReplayPath` 和 `PaperSessionReplayFixture`。
- MTP-35 已将 `TVM-PAPER-SESSION-REPLAY` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 FileEventLogStore facts source、乱序 replay 拒绝、SQLite runtime projection replay 和 paper-only boundary flags。
- MTP-36 新增 `PaperSessionRuntimeEvidenceSummary`，并把 MTP-35 replay summary、Paper lifecycle、proposal、risk blocker、portfolio update 和 portfolio exposure evidence 汇总到 Report read model。
- MTP-36 已将 `TVM-PAPER-SESSION-REPLAY` 和 `TVM-REPORT-EVIDENCE` 回填到 Trading Validation Matrix，并在 contracts / product / validation docs 记录 read-model-only 汇总边界。
- MTP-37 新增 `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md`，集中记录 `MTP-31` 至 `MTP-36` 的 PR evidence、merge commit、required check、paper runtime validation evidence chain、automation readiness evidence、known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- MTP-37 更新 Trading Validation Matrix、validation plan 和 automation readiness gate，使 Project 级 Stage Code Audit input 成为本地机械检查对象。
- MTP-38 新增 `PaperExecutionWorkflowContract`，定义 proposal、risk decision、paper execution decision、paper order、simulated fill 和 portfolio projection 的 paper-only stage order 与 event boundary。
- MTP-38 已将 `TVM-PAPER-EXECUTION-WORKFLOW` 回填到 Trading Validation Matrix，并在 contracts / validation docs 记录 future issue 占位、Codable 禁区和无 signed endpoint / broker / real order 边界。
- Project 级阶段证据和 Stage Code Audit 输入材料统一放在 `docs/audit/inputs/`；`docs/validation/` 只保留长期验证入口，不再放 `MTP-xx` 命名的阶段输入文件。
- 上一阶段 Stage Code Audit Report 已记录 `MTP-18` / `MTP-19` / `MTP-22` 的临时 CI 平台边界，并确认审计报告覆盖完整 Linear Project；本 Project 目前未记录新增临时 CI 平台边界。
- `MTPRO Paper Session Runtime v1` Stage Code Audit Report 已落仓到 `docs/audit/mtpro-paper-session-runtime-v1-stage-code-audit.md`，记录 `MTP-31` 至 `MTP-37` 全部 Done、PR #62 至 #68 evidence、validation、boundary audit、Known CI Boundary、Root Docs Delta 和 Next Human Project Planning handoff。
- Root Docs Refresh Gate closure 已基于该 Stage Code Audit Report 执行：`GOAL.md`、`ENVIRONMENT.md` 和 `ARCHITECTURE.md` 无需事实刷新，`ROADMAP.md` 已同步最近完成 Project 与 canonical audit report 路径。
- Root Docs Refresh Gate 只允许 `@002 / PAR` 同步 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md` 中已发生的事实；方向性变化交给 Human + `@001 / PLN`。
- `graphify-out/*` 不提交，`.codex/*` 不提交。
- 本文档不作为 current issue 或 queue pointer 的事实源；当前 issue 状态必须继续从 Linear live-read 获取。

## 上一 Project PR evidence

| Issue | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- |
| `MTP-24` | [#52 MTP-24 定义 Trading Validation Matrix](https://github.com/atxinbao/MTPRO/pull/52) | `210a8acbc04193ff7782b8d8de7bcfe9f31a8e99` | `checks` success |
| `MTP-25` | [#53 MTP-25 harden EMA parity validation](https://github.com/atxinbao/MTPRO/pull/53) | `0329e7c88b567d369bef3887311c0aba8a992fa7` | `checks` success |
| `MTP-26` | [#55 MTP-26 harden order book imbalance parity evidence](https://github.com/atxinbao/MTPRO/pull/55) | `babd7303f5caa90921e9d5d712d49e330a88b61d` | `checks` success |
| `MTP-27` | [#56 MTP-27 define fixed execution cost evidence](https://github.com/atxinbao/MTPRO/pull/56) | `fdfd25da8a4342ed0a5bc7089737644a6e29d6a4` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26043018278/job/76559557297) |
| `MTP-28` | [#57 Add risk blocker and portfolio exposure evidence](https://github.com/atxinbao/MTPRO/pull/57) | `a42018fc61c65937e4c39a7fe01e732671653b42` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26044260186/job/76564019240) |
| `MTP-29` | [#58 MTP-29 汇总 Report / Dashboard 交易验证证据](https://github.com/atxinbao/MTPRO/pull/58) | `f34fc38c036210ec90f60f5ec465f9482eac027e` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26045291493/job/76567709367) |
| `MTP-30` | [#59 MTP-30 加固验证文档和阶段审计输入](https://github.com/atxinbao/MTPRO/pull/59) | `4e694f96c56eff07d39267a799083474d7c1c9f5` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26046045767/job/76570399101) |

## 本 Project PR evidence

| Issue | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- |
| `MTP-31` | [#62 MTP-31 define Paper Session lifecycle](https://github.com/atxinbao/MTPRO/pull/62) | `b12099de8c28a3fccbc142239b0181da419f1007` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26049266906/job/76581455945) |
| `MTP-32` | [#63 MTP-32 新增 Paper action proposal 最小模型](https://github.com/atxinbao/MTPRO/pull/63) | `4184933fde658fd8dd0dbe81f9820bc69492ed12` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26050249998/job/76584785176) |
| `MTP-33` | [#64 MTP-33 link paper proposals to risk blockers](https://github.com/atxinbao/MTPRO/pull/64) | `840e02230cd8e632c4cd417baa5b824c71bb7e52` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26051040064/job/76587403720) |
| `MTP-34` | [#65 MTP-34 新增 paper-only portfolio projection update path](https://github.com/atxinbao/MTPRO/pull/65) | `8250c7ab088077ff3f9ea277e252ff415a413cdd` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26052078591/job/76590891105) |
| `MTP-35` | [#66 MTP-35 add Paper Session replay evidence](https://github.com/atxinbao/MTPRO/pull/66) | `aa66ff53a6e96b558f2a994a8ec03d514ad8e9b0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26053013626/job/76594084398) |
| `MTP-36` | [#67 MTP-36 汇总 Paper Session runtime evidence 到 Report / Dashboard read model](https://github.com/atxinbao/MTPRO/pull/67) | `7109184503a7b2addfa07f78cd2191a2eeed3ed0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26054145509/job/76597907236) |
| `MTP-37` | [#68 MTP-37 加固 validation docs 和阶段审计输入](https://github.com/atxinbao/MTPRO/pull/68) | `576871832f0951b59f7adbd4f486079810720051` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26054919807/job/76600525605) |

## 最近验证

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | pass | 由 `bash checks/run.sh` 串联执行，当前 diff 无空白问题。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；MTP-37 Stage Code Audit input、Trading Validation Matrix、latest summary 和 automation readiness 锚点完整。 |
| `swift build --product Dashboard` | pass | macOS dashboard executable 构建通过。 |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | 输出 `Dashboard smoke: sections=8; readModelOnly=true; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `swift test` | pass | 82 个 XCTest 通过；新增 MTP-38 paper-only execution workflow contract / boundary tests，回归覆盖既有 Paper Session runtime evidence 和 paper-only boundary。 |
| `bash checks/run.sh` | pass | `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test` 全部通过；82 个 XCTest 0 failures，输出 `MTPRO checks passed.`。 |

## 当前边界

- MTP-31 只定义 Paper Session lifecycle facts 和 event log 写入边界；不实现 action proposal、portfolio projection update 或完整 Paper execution engine。
- MTP-32 只定义 Paper action proposal value model 和 deterministic fixture；不新增 order command、Paper action event log 写入、portfolio projection update 或完整 Paper execution engine。
- MTP-33 只定义 Paper action proposal -> risk blocker 的 Core 本地 evidence 链路；不新增 Paper action event log 写入、portfolio projection update、完整风险引擎、broker rejection fallback 或完整 Paper execution workflow。
- MTP-34 只定义 allowed risk decision -> paper-only portfolio projection update 的本地链路；不新增 Paper action event log 写入、完整 portfolio management、真实账户余额读取、margin、leverage、broker position sync 或完整 Paper execution workflow。
- MTP-35 只定义 Paper Session replay evidence summary 和 proposal event replay fact；不新增生产级 event sourcing 平台、schema migration framework、真实 broker event replay、外部 execution venue、Report / Dashboard 汇总或完整 Paper execution workflow。
- MTP-36 只把 Paper Session runtime evidence 汇总到 Report / Dashboard read model；不新增 UI 大改版、完整报告系统、Paper execution workflow 扩展、risk control command、position management command 或交易执行入口。
- MTP-37 只收口 validation docs、automation evidence、known boundaries 和 Stage Code Audit input；不输出最终 Stage Code Audit Report，不创建下一 Project / Issue。
- MTP-38 只定义 paper-only execution workflow contract、stage order、event boundary 和 deterministic fixture；不实现 paper order lifecycle、simulated fill、完整 OMS、broker action、signed endpoint 或真实订单行为。
- Root Docs Refresh Gate closure 只同步已发生事实；不决定下一阶段方向，不创建 Linear Project / Issue，不推进 Todo，不启动 Symphony。
- Paper action proposal 固定 `executionMode == paper`、`executionAuthorization == paperIntentOnly` 且 `isExecutableAsRealOrder == false`。
- Paper action risk decision 的 allowed / blocked 结果都不提供 broker fallback 或 Live execution fallback；allowed 不代表真实订单授权，blocked 不代表真实 broker 拒单。
- Trading Validation Matrix 是 evidence routing 入口，不替代 Linear issue contract、PR evidence 或 Stage Code Audit Report。
- `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md` 是阶段审计输入材料，不授权下一 Project planning 或 execution。
- `MTPRO Paper Session Runtime v1` planning record、Stage Code Audit Report 和 Root Docs Refresh Gate closure 均不授权下一 issue 执行；后续执行仍必须从 Linear live-read 和 Parent Codex queue preview 获取唯一 eligible issue。
- `MTPRO Paper Execution Workflow v1` planning record 已落仓并已写入 Linear；执行事实仍以 Linear live-read 的唯一 active issue 为准，仓库摘要不固定 current issue。
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
