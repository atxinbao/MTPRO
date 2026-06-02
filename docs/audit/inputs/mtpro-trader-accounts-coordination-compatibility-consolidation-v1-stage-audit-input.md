# MTPRO Trader Accounts / Coordination Compatibility Consolidation v1 阶段审计输入材料

日期：2026-06-03

执行者：Codex

## 定位

`MTP-211-TRADER-ACCOUNTS-COORDINATION-STAGE-CLOSEOUT`

本文档是 `MTPRO Trader Accounts / Coordination Compatibility Consolidation v1` 的 MTP-211 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

`MTP-211-STAGE-AUDIT-INPUT-MATERIAL`

本文档只准备 stage audit input material，集中收口 MTP-205 至 MTP-210 的 Trader Accounts / Coordination compatibility contract、Trader/Accounts account context boundary、validation wiring、StrategyBindings wording retirement、Package stale Strategies exclude cleanup、Trader container completeness validation、validation matrix anchors、automation readiness anchors、compatibility envelope treatment、forbidden implementation audit、no Graphify / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary 和 Parent Codex handoff checklist。

`MTP-211-NO-FINAL-STAGE-CODE-AUDIT`

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-205` 至 `MTP-211` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出。本文档不授权下一 Project planning，不创建 Linear Project / Issue，不推进下一阶段，不启动下一阶段 `@002 / PAR`、Symphony 或 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、SwiftPM target graph split、Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker adapter、real order lifecycle、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Trader Accounts / Coordination Compatibility Consolidation v1`。
- Project status：当前仍为 `planned`；MTP-211 完成前不得设置 Project `Completed`。
- `MTP-205` 至 `MTP-210`：已完成 issue-level gates。
- `MTP-211`：当前 issue execution scope。
- 当前 issue scope 仅限 validation matrix、compatibility envelope、stage audit input material、forbidden capability evidence、no final Stage Code Audit、no Graphify / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary。

## Issue / PR evidence input

`MTP-211-EVIDENCE-CHAIN`

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-205` | Trader Accounts / Coordination compatibility contract | [#338](https://github.com/atxinbao/MTPRO/pull/338) | `ab1e50d382c27893810e9622ebf36291a12162b3` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26840643885/job/79146501636) |
| `MTP-206` | `Sources/Trader/Accounts/` account context boundary | [#339](https://github.com/atxinbao/MTPRO/pull/339) | `8238e9d901b64a793da787d90c27b7f68058029c` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26841789550/job/79150555044) |
| `MTP-207` | Trader account context deterministic validation wiring | [#340](https://github.com/atxinbao/MTPRO/pull/340) | `9657ff3d05a3d108a5088c0bc85e434907d6a324` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26842506527/job/79153152132) |
| `MTP-208` | active `StrategyBindings` wording retirement from root / high-weight docs | [#341](https://github.com/atxinbao/MTPRO/pull/341) | `3b9caa6e4196b2ed30bf21c372c45ad1e530c90a` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26843292105/job/79155969336) |
| `MTP-209` | stale peer-level `Sources/Strategies` Package exclude cleanup | [#342](https://github.com/atxinbao/MTPRO/pull/342) | `5ed52274f84b5dd5e550a6a8b81babf37730f5b4` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26844096923/job/79158797090) |
| `MTP-210` | Trader container completeness deterministic validation | [#343](https://github.com/atxinbao/MTPRO/pull/343) | `5bcd7c67282b2538f6a6a6e8194643a48a5d8881` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26844799535/job/79161296694) |
| `MTP-211` | validation matrix、compatibility envelope 和 stage audit input closeout | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Trader container compatibility closeout

`MTP-211-TRADER-CONTAINER-COMPATIBILITY-CLOSEOUT`

| Boundary | Current evidence | Audit interpretation |
| --- | --- | --- |
| Trader relationship | `Trader = Accounts + Strategies/EMA + Coordination` | 当前 Project 只固定 compatibility relationship，不授权 runtime coordinator。 |
| Accounts source | `Sources/Trader/Accounts/TraderAccountContext.swift` | 只表达 account identity、source identity、source kind、future real account gate 和 local relationship evidence。 |
| Financial state owner | `Sources/Portfolio/` | cash、positions、PnL、margin、leverage、buying power、real account payload 不能归 Trader/Accounts。 |
| Current active strategy | only `EMA` | active concrete strategy source root 只有 `Sources/Trader/Strategies/EMA/`。 |
| Binding / adapter location | `Sources/Trader/Coordination/RiskBinding/` | RiskBinding 只表达 local coordination adapter contract，不是 execution gateway。 |
| Retired paths | no `Sources/Trader/StrategyBindings/`、no peer-level `Sources/Strategies/` | retained references 只能是 historical / compatibility / superseded / migration-source context。 |
| Package compatibility envelope | `Core` 继续编译 `"Trader/Accounts"`、`"Trader/Strategies/EMA"`、`"Trader/Coordination/RiskBinding"` | source roots 被 Core compatibility envelope 编译，不代表 SwiftPM target graph split 已完成。 |

## Validation matrix closeout

`MTP-211-VALIDATION-MATRIX-CLOSEOUT`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION` | MTP-205 固定 Trader Accounts / Coordination contract；MTP-206 新增 account context source boundary；MTP-207 接入 deterministic validation wiring；MTP-208 退休 active `StrategyBindings` wording；MTP-209 清理 stale `Sources/Strategies` Package exclude；MTP-210 增加 Trader container completeness validation；MTP-211 收口 audit input。 | 审计时确认本 Project 只完成 Trader container compatibility consolidation，不完成 SwiftPM target graph split，不实现 Strategy / Trader / Live runtime，不授权 ExecutionClient、broker、OMS、real account read 或 live command capability。 |

## Compatibility envelope closeout

`MTP-211-COMPATIBILITY-ENVELOPE-CLOSEOUT`

- `Core` SwiftPM product / target 仍作为 compatibility envelope 编译 `Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Coordination/RiskBinding/`。
- `Package.swift` 不包含 `"Trader/StrategyBindings"`、peer-level `"Strategies"` exclude、`"Strategies/EMA"`、non-EMA active strategy source root、`Strategies` target 或 `Trader` target。
- `Sources/Trader/StrategyBindings/` 和 `Sources/Strategies/` 当前均不得作为 active source path 回流。
- 本 Project 不完成 SwiftPM target graph split；真实 `Trader` / `Strategies` target graph 仍需未来 Human + `@001 / PLN` planning。

## Automation readiness evidence

`MTP-211-AUTOMATION-READINESS-CLOSEOUT`

- `checks/automation-readiness.sh` 必须机械检查本 MTP-211 输入材料、MTP-205 至 MTP-210 anchors、validation matrix、validation plan、latest verification summary、automation readiness doc、current source file locations、old path absence、RiskBinding role 和 no final Stage Code Audit boundary。
- GitHub PR Automation 仍负责 required check `checks`、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*` 与 `graphify-out/*` 不进入 PR。
- MTP-211 不设置 Linear Project `Completed`；Project closure、最终 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 仍归 Parent Codex closure flow。

## Forbidden implementation audit

`MTP-211-FORBIDDEN-IMPLEMENTATION-AUDIT`

本 Project 的 forbidden implementation audit 继续固定以下能力在当前 scope 中全部禁止：

- no SwiftPM target graph split as completion claim；no new product / dependency / target beyond compatibility envelope.
- no Strategy runtime、Trader runtime、Live runtime、strategy scheduler、account session runtime、live coordinator、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation 或 broker adapter。
- no signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、credential provider、API key input 或 secret storage。
- no real account read、broker position sync、real balance、real position、margin、leverage、buying power、real PnL、execution report、broker fill 或 reconciliation。
- no direct Strategy / Trader / RiskBinding / Accounts to ExecutionClient、broker command、OMS command、real order lifecycle、executable order command 或 live command path。
- no Live PRO Console implementation、trading button、live command、order form、broker connect UI、account connect UI、ExecutionClient request UI、OMS command UI 或 production operations command。
- no Graphify update、no Figma modification、no next Project / Issue creation、no next Todo promotion from this issue.

## Validation evidence

`MTP-211-STAGE-CLOSEOUT-VALIDATION`

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过 | 无输出。 |
| `bash checks/automation-readiness.sh` | 通过 | 输出 `MTPRO automation readiness checks passed.`，并机械检查 MTP-211 stage audit input、matrix、validation plan、latest summary 和 automation readiness anchors。 |
| `bash checks/run.sh` | 通过 | 通过 automation readiness、Dashboard build、Dashboard smoke 和 315 个 XCTest；Dashboard smoke 输出包含 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`timelineItems=82`、`strategyTraderReadinessSurface=6` 和 `liveMonitoringReadOnlyConsoleV2Surface=4`，最终输出 `MTPRO checks passed.`。 |

## Known boundaries

`MTP-211-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`

- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。
- 本 issue 不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR`、Symphony 或 `symphony-issue`。
- 本 issue 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## Root Docs Delta input

`MTP-211-ROOT-DOCS-DELTA-INPUT`

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-211 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 Trader Accounts / Coordination compatibility consolidation；不代表 Trader runtime、Strategy runtime、broker readiness、Live PRO Console readiness、live runtime readiness 或真实交易授权。 |
| `BLUEPRINT.md` | Trader container 可以继续表达 `Trader = Accounts + Strategies/EMA + Coordination`；Accounts 只表达 identity / source / future gate，RiskBinding 只负责 coordination adapter contract，ExecutionClient、broker command、OMS、production operations 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `environment.md` | 本 Project 未新增 required secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或 production operations；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | 当前 source tree 已把 Trader compatibility container 收口为 Accounts / EMA / Coordination，但 SwiftPM target graph 仍保留 compatibility envelope；不得把目录/validation 收口误写成 runtime implementation 完成。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 同步已发生事实；MTP-211 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

`MTP-211-STAGE-CODE-AUDIT-HANDOFF`

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-205` 至 `MTP-211`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #338、PR #339、PR #340、PR #341、PR #342、PR #343 和 MTP-211 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：Trader relationship、Accounts identity/source/future gate、EMA-only active strategy、RiskBinding coordination adapter、retired `StrategyBindings` / peer-level `Sources/Strategies` paths、Package stale exclude cleanup、remaining compatibility envelope、forbidden implementation audit 和 unresolved future gates。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`。
- Residual Notes For Human Planning：SwiftPM target split、Strategy runtime、Trader runtime、ExecutionClient / broker / OMS / Live PRO Console 仍只能作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
