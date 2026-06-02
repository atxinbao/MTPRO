# MTPRO Trader EMA Strategy Layout Consolidation v1 阶段审计输入材料

日期：2026-06-02

执行者：Codex

## 定位

`MTP-204-TRADER-EMA-LAYOUT-STAGE-CLOSEOUT`

本文档是 `MTPRO Trader EMA Strategy Layout Consolidation v1` 的 MTP-204 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

`MTP-204-STAGE-AUDIT-INPUT-MATERIAL`

本文档只准备 stage audit input material，集中收口 MTP-198 至 MTP-203 的 EMA-only active strategy layout evidence、non-EMA future candidate / historical evidence treatment、Trader Coordination RiskBinding boundary、deterministic path validation、validation matrix anchors、automation readiness anchors、compatibility envelope treatment、forbidden implementation audit、no Graphify / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary 和 Parent Codex handoff checklist。

`MTP-204-NO-FINAL-STAGE-CODE-AUDIT`

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-198` 至 `MTP-204` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出。本文档不授权下一 Project planning，不创建 Linear Project / Issue，不推进下一阶段，不启动下一阶段 `@002 / PAR`、Symphony 或 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、SwiftPM target graph split、Strategy runtime、Trader runtime、ExecutionClient implementation、OMS implementation、broker adapter、real order lifecycle、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Trader EMA Strategy Layout Consolidation v1`。
- Project ID：`2605408e-8af4-4287-9e1c-00176c29715e`。
- `MTP-198` 至 `MTP-203`：`Done`。
- `MTP-204`：当前 issue execution scope。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、compatibility envelope treatment、forbidden implementation audit、stage audit input material、no final Stage Code Audit、no Graphify / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary。

## Issue / PR evidence input

`MTP-204-TRADER-EMA-LAYOUT-EVIDENCE-CHAIN`

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-198` | EMA-only Trader strategy layout contract、canonical active EMA path、non-EMA future candidate boundary | [#327](https://github.com/atxinbao/MTPRO/pull/327) | `42ef1551773eb9787a85b2d727a9bb5c5aaa65a4` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26823446627/job/79084114293) |
| `MTP-199` | root docs non-EMA active anchor cleanup、historical / future-gated non-EMA wording | [#328](https://github.com/atxinbao/MTPRO/pull/328) | `adfcc75b8cc75dfb715f3e9bf5b69ae480bf569f` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26825041471/job/79089965571) |
| `MTP-200` | current source / Package.swift / tests audit for non-EMA and StrategyBindings anchors | [#330](https://github.com/atxinbao/MTPRO/pull/330) | `cf63abe3365ceb7ef345630c967294f2d2deeff4` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26826719687/job/79096194521) |
| `MTP-201` | non-EMA active strategy source retirement、OrderBookImbalance Core research evidence | [#331](https://github.com/atxinbao/MTPRO/pull/331) | `0be6c3b7349faa4f93fefc0bd1528b1a2982611d` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26828470136/job/79102637608) |
| `MTP-202` | StrategyBindings reclassified into Trader Coordination RiskBinding | [#332](https://github.com/atxinbao/MTPRO/pull/332) | `1e6269759134813dbf7fee2d3f1237d093d16160` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26829923187/job/79107983286) |
| `MTP-203` | deterministic EMA-only strategy path validation and drift guard | [#333](https://github.com/atxinbao/MTPRO/pull/333) | `15b4b5f91cbf4a3f09f997949525f516141d9194` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26830969806/job/79111843684) |
| `MTP-204` | validation matrix、compatibility envelope 和 stage audit input material closeout | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## EMA-only active layout closeout

`MTP-204-EMA-ONLY-ACTIVE-LAYOUT-CLOSEOUT`

| Boundary | Current evidence | Audit interpretation |
| --- | --- | --- |
| Current active concrete strategy | only `EMA` | 当前 active strategy 管理和执行前验证口径只允许 EMA。 |
| Canonical active source path | `Sources/Trader/Strategies/EMA/` | EMA lifecycle、signals 和 paper/live-neutral proposal source 位于 Trader-owned strategy root。 |
| Non-EMA strategy names | `RSI`、`OrderBookImbalance`、`Momentum`、`MeanReversion` | 只能作为 future candidate / future-gated label、historical evidence 或 Core research evidence；不得作为 active implementation 回流。 |
| OrderBookImbalance evidence | `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` | 只保留 research parity / persistence evidence，不是 active concrete strategy source。 |
| Binding semantics | `Sources/Trader/Coordination/RiskBinding/` | RiskBinding 只表达 generic binding protocol / coordination adapter contract，不承载 concrete strategy implementation。 |
| Retired first-level binding path | `Sources/Trader/StrategyBindings/` 不存在，`Package.swift` 不包含 `"Trader/StrategyBindings"` | 旧 path 只允许 historical context，不得作为 current / forward-looking source root。 |

## Validation matrix closeout

`MTP-204-VALIDATION-MATRIX-CLOSEOUT`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION` | MTP-198 定义 EMA-only contract；MTP-199 清理 root docs non-EMA active anchors；MTP-200 输出 source / Package.swift / tests audit；MTP-201 退休 non-EMA active source；MTP-202 迁移 StrategyBindings 到 Trader Coordination RiskBinding；MTP-203 增加 deterministic path validation；MTP-204 收口 audit input。 | 审计时确认本 Project 只完成 EMA-only active strategy layout consolidation，不完成 SwiftPM target graph split，不实现 Strategy / Trader runtime，不授权 ExecutionClient、broker、OMS 或 live command capability。 |

## Compatibility envelope closeout

`MTP-204-COMPATIBILITY-ENVELOPE-CLOSEOUT`

- `Core` SwiftPM product / target 仍作为 compatibility envelope 编译 EMA strategy source、OrderBookImbalance Core research evidence、Trader Coordination RiskBinding、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient future gates 和 Workbench read-model evidence。
- `Package.swift` 当前 active strategy source root 只包含 `"Trader/Strategies/EMA"`；`"Trader/Coordination/RiskBinding"` 只用于 binding / adapter semantics。
- 保留 `"Strategies"` exclude 只是 historical peer-level path 的 compatibility exclusion / warning source，不表示 `Sources/Strategies/<strategy>` 仍是 current source root。
- 本 Project 不完成 SwiftPM target graph split；真实 `Strategies` / `Trader` target graph 仍需未来 Human + `@001 / PLN` planning。

## Automation readiness evidence

`MTP-204-AUTOMATION-READINESS-CLOSEOUT`

- `checks/automation-readiness.sh` 必须机械检查本 MTP-204 输入材料、MTP-198 至 MTP-203 anchors、validation matrix、validation plan、latest verification summary、automation readiness doc、current source file locations、old path absence、RiskBinding role 和 no final Stage Code Audit boundary。
- GitHub PR Automation 仍负责 required check `checks`、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*` 与 `graphify-out/*` 不进入 PR。
- MTP-204 不设置 Linear Project `Completed`；Project closure、最终 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 仍归 Parent Codex closure flow。

## Forbidden implementation audit

`MTP-204-FORBIDDEN-IMPLEMENTATION-AUDIT`

本 Project 的 forbidden implementation audit 继续固定以下能力在当前 scope 中全部禁止：

- no SwiftPM target graph split as completion claim；no new product / dependency / target beyond compatibility envelope.
- no Strategy runtime、Trader runtime、strategy scheduler、live quoter、live hedger、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter 或 live coordinator。
- no signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、credential provider、API key input 或 secret storage。
- no real account read、broker position sync、real balance、real position、margin、leverage、buying power、real PnL、execution report、broker fill 或 reconciliation。
- no direct Strategy / Trader / RiskBinding to ExecutionClient、broker command、OMS command、real order lifecycle、executable order command 或 live command path。
- no Live PRO Console implementation、trading button、live command、order form、broker connect UI、account connect UI、ExecutionClient request UI、OMS command UI 或 production operations command。
- no Graphify update、no Figma modification、no next Project / Issue creation、no next Todo promotion from this issue.

## Unresolved future gates

`MTP-204-UNRESOLVED-FUTURE-GATES`

后续仍必须独立处理：

- SwiftPM Target Split gate：把 `Core` compatibility envelope 转成真实 `Strategies` / `Trader` target graph 需要新的 Project Definition、dependency audit、migration order 和 validation matrix。
- Strategy runtime gate：strategy lifecycle runtime、scheduler、live quoter、live hedger 和 strategy process ownership 仍未授权。
- Trader runtime gate：Trader coordinator、account session runtime、broker gateway、OMS gateway 和 live coordinator 仍未授权。
- Execution gate：ExecutionClient、broker adapter、OMS、real order lifecycle、execution report、broker fill 和 reconciliation 仍未授权。
- Product surface gate：Future Live PRO Console、trading button、live command、order form 和 operations controls 仍未授权。
- Planning gate：下一阶段必须由 Human + `@001 / PLN` 规划，写入 Linear 后再由 Parent Codex queue preflight；本 closeout 不自动创建或推进下一 Project。

## Validation evidence

`MTP-204-STAGE-CLOSEOUT-VALIDATION`

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无输出。 |
| `bash checks/automation-readiness.sh` | 通过 | 输出 `MTPRO automation readiness checks passed.`，并机械检查 MTP-204 stage audit input、matrix、validation plan、latest summary 和 automation readiness anchors。 |
| `bash checks/run.sh` | 通过 | 通过 automation readiness、Dashboard build、Dashboard smoke 和 309 个 XCTest；Dashboard smoke 输出包含 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`timelineItems=82`、`strategyTraderReadinessSurface=6` 和 `liveMonitoringReadOnlyConsoleV2Surface=4`，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

`MTP-204-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`

- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。
- 本 issue 不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR`、Symphony 或 `symphony-issue`。
- 本 issue 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-204 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 EMA-only active strategy layout consolidation；不代表 Strategy runtime、Trader runtime、broker readiness、Live PRO Console readiness、live runtime readiness 或真实交易授权。 |
| `BLUEPRINT.md` | Trader container 可以继续表达 `Accounts + Strategies + Coordination`；具体 active strategy 当前只允许 EMA，RiskBinding 只负责 coordination adapter contract，ExecutionClient、broker command、OMS、production operations 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `environment.md` | 本 Project 未新增 required secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或 production operations；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | 当前 source tree 已把 active strategy layout 收口为 EMA-only，但 SwiftPM target graph 仍保留 compatibility envelope；不得把目录/validation 收口误写成 runtime implementation 完成。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 同步已发生事实；MTP-204 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-198` 至 `MTP-204`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #327、#328、#330、#331、#332、#333 和 MTP-204 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：EMA-only active concrete strategy path、non-EMA future candidate / historical evidence treatment、OrderBookImbalance Core research evidence、Trader Coordination RiskBinding boundary、path validation、remaining compatibility envelope、forbidden implementation audit 和 unresolved future gates。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`。
- Residual Notes For Human Planning：SwiftPM target split、Strategy runtime、Trader runtime、ExecutionClient / broker / OMS / Live PRO Console 仍只能作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
