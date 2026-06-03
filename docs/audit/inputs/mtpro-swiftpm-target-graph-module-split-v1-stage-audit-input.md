# MTPRO SwiftPM Target Graph Module Split v1 阶段审计输入材料

日期：2026-06-04

执行者：Codex

## 定位

`MTP-223-SWIFTPM-TARGET-GRAPH-STAGE-CLOSEOUT`

本文档是 `MTPRO SwiftPM Target Graph Module Split v1` 的 MTP-223 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

`MTP-223-STAGE-AUDIT-INPUT-MATERIAL`

本文档只准备 stage audit input material，集中收口 MTP-216 至 MTP-222 的 SwiftPM target graph split contract、foundation / data / trader / execution / workbench target split、compatibility anchor retirement、validation matrix anchors、automation readiness anchors、forbidden capability evidence、no Symphony / no Graphify / no code-index / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary 和 Parent Codex handoff checklist。

`MTP-223-NO-FINAL-STAGE-CODE-AUDIT`

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-216` 至 `MTP-223` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`completedAt` 非空后，由 Parent Codex 单独输出。本文档不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `@002 / PAR`、Symphony 或 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private stream runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO SwiftPM Target Graph Module Split v1`。
- Project status：当前仍为 `planned`；MTP-223 完成前不得设置 Project `Completed`。
- `MTP-216` 至 `MTP-222`：已完成 issue-level gates，均有 PR / required check / merge / root main fast-forward / Linear Done / post-issue ledger evidence。
- `MTP-223`：当前 issue execution scope。
- 当前 issue scope 仅限 validation matrix、automation readiness、stage audit input material、target graph evidence chain summary、forbidden capability evidence、no final Stage Code Audit、no Symphony / no Graphify / no code-index / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary。

## Issue / PR evidence input

`MTP-223-EVIDENCE-CHAIN`

| Issue | Evidence domain | PR | Merge commit | GitHub required check | Linear Done |
| --- | --- | --- | --- | --- | --- |
| `MTP-216` | SwiftPM target graph split contract and dependency direction | [#352](https://github.com/atxinbao/MTPRO/pull/352) | `2bba68e6ae09e55aaea8e28572492560ea2984ea` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26904435891/job/79365328401) | `2026-06-03T18:23:37.793Z` |
| `MTP-217` | `DomainModel` / `MessageBus` / `Database` foundation targets | [#353](https://github.com/atxinbao/MTPRO/pull/353) | `572d7be1ab855af978f253924e404c414fe9499b` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26905775123/job/79370152572) | `2026-06-03T18:48:27.490Z` |
| `MTP-218` | `DataClient` / `DataEngine` / `Cache` targets | [#354](https://github.com/atxinbao/MTPRO/pull/354) | `48574db23119cf1250694995704fdc6cda15a95f` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26906750017/job/79373591564) | `2026-06-03T19:06:36.273Z` |
| `MTP-219` | `TraderStrategies` / `Trader` / `Portfolio` / `RiskEngine` targets with EMA-only boundary | [#355](https://github.com/atxinbao/MTPRO/pull/355) | `440118c39ce81c12d0c591b8bfd38cf04efa1043` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26907825271/job/79377458297) | `2026-06-03T19:28:11.199Z` |
| `MTP-220` | `ExecutionEngine` / `ExecutionClient` future gate targets | [#356](https://github.com/atxinbao/MTPRO/pull/356) | `7e4a9931e9d1d204b4ddf53f16f626ad46cbe943` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26908766028/job/79380794836) | `2026-06-03T19:46:04.037Z` |
| `MTP-221` | `Workbench` / `Dashboard` read-model-only consumption targets | [#357](https://github.com/atxinbao/MTPRO/pull/357) | `e48b9eaf1225489450cb33971cfe22dfb31c37eb` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26909676915/job/79384009574) | `2026-06-03T20:03:30.774Z` |
| `MTP-222` | obsolete compatibility wording / stale active anchor retirement | [#358](https://github.com/atxinbao/MTPRO/pull/358) | `1d7acfdb77613a1c10c3bf77794227e227583a5e` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26910501794/job/79386924885) | `2026-06-03T20:20:04.552Z` |
| `MTP-223` | validation matrix、automation readiness 和 stage audit input closeout | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` | 当前 issue 完成后由 Linear bot / Parent Codex gate 确认 |

## Target graph closeout

`MTP-223-TARGET-GRAPH-CLOSEOUT`

| Segment | Evidence | Audit interpretation |
| --- | --- | --- |
| Contract-first baseline | `MTP-216-SWIFTPM-TARGET-GRAPH-SPLIT-CONTRACT` | 固定 canonical target graph、dependency direction、forbidden import paths 和 issue sequence；MTP-216 before-state snapshot 保留为 historical evidence。 |
| Foundation targets | `DomainModel`、`MessageBus`、`Database` | Foundation target buildability、dependency direction 和 no higher-layer runtime / broker / UI drift 已由 TargetGraphTests 验证。 |
| Data targets | `DataClient`、`DataEngine`、`Cache` | Public read-only data input、ingest / replay / quality 和 read-model cache boundary 已拆出 target graph evidence；不接 signed/account/listenKey/private stream。 |
| Trader / financial / risk targets | `TraderStrategies`、`Trader`、`Portfolio`、`RiskEngine` | EMA-only active strategy、Trader container、Portfolio financial state 和 RiskEngine pre-execution boundary 已拆出 target graph evidence；Strategy / Trader 不直连 ExecutionClient、broker、OMS 或 UI command。 |
| Execution targets | `ExecutionEngine`、`ExecutionClient` | ExecutionEngine 只表达 paper / simulated lifecycle；ExecutionClient 只表达 future gate / capability boundary；不实现 broker / OMS / real order lifecycle。 |
| Workbench / Dashboard targets | `Workbench`、`Dashboard` | Workbench 只消费 read model / ViewModel exports；Dashboard 只依赖 Workbench；App 只是 compatibility re-export。 |
| Compatibility anchor retirement | `MTP-222-CURRENT-TARGET-GRAPH-SNAPSHOT` | 旧 `Core / Adapters / Persistence / Runtime / App / Dashboard`、`Dashboard -> App`、`Sources/Strategies/<strategy>` 和 `StrategyBindings` references 只能作为 historical / compatibility / before-state evidence 保留。 |

## Current active target graph snapshot

`MTP-223-CURRENT-TARGET-GRAPH-SNAPSHOT`

```text
DomainModel
MessageBus -> DomainModel
Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)
DataClient -> DomainModel
Cache -> DomainModel / MessageBus
DataEngine -> DomainModel / DataClient / MessageBus / Cache
Portfolio -> DomainModel / MessageBus / Cache / Database
RiskEngine -> DomainModel / MessageBus / Cache / Portfolio
ExecutionClient -> DomainModel / MessageBus
ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient
TraderStrategies -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine
Trader -> DomainModel / MessageBus / Cache / TraderStrategies / Portfolio / RiskEngine / ExecutionEngine
Workbench -> Core / Persistence read-model and ViewModel exports only
App -> Workbench compatibility re-export
Dashboard -> Workbench
```

## Validation matrix closeout

`MTP-223-VALIDATION-MATRIX-CLOSEOUT`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-SWIFTPM-TARGET-GRAPH-MODULE-SPLIT` | MTP-216 固定合同；MTP-217 至 MTP-221 建立 buildable split targets；MTP-222 退休 stale active compatibility anchors；MTP-223 收口 stage audit input。 | 审计时确认本 Project 完成 SwiftPM target graph split evidence chain，但不代表 production runtime、Live runtime、broker integration、OMS implementation、real order lifecycle 或 L4 capability 已实现或获授权。 |

## Automation readiness evidence

`MTP-223-AUTOMATION-READINESS-CLOSEOUT`

- `checks/automation-readiness.sh` 必须机械检查本 MTP-223 输入材料、MTP-216 至 MTP-222 anchors、validation matrix、validation plan、latest verification summary、automation readiness doc、current target graph snapshot、no final Stage Code Audit boundary 和 no next-stage mutation boundary。
- GitHub PR Automation 仍负责 required check `checks`、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*` 与 `graphify-out/*` 不进入 PR。
- MTP-223 不设置 Linear Project `Completed`；Project closure、最终 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 仍归 Parent Codex closure flow。

## Forbidden implementation audit

`MTP-223-FORBIDDEN-IMPLEMENTATION-AUDIT`

本 Project 的 forbidden implementation audit 继续固定以下能力在当前 scope 中全部禁止：

- no Strategy runtime、Trader runtime、Live runtime、strategy scheduler、account session runtime、live coordinator、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation 或 broker adapter。
- no signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、credential provider、API key input 或 secret storage。
- no real account read、broker position sync、real balance、real position、margin、leverage、buying power、real PnL、execution report、broker fill 或 reconciliation。
- no direct Strategy / Trader / RiskBinding / Accounts to ExecutionClient、broker command、OMS command、real order lifecycle、executable order command 或 live command path。
- no Live PRO Console implementation、trading button、live command、order form、broker connect UI、account connect UI、ExecutionClient request UI、OMS command UI 或 production operations command。
- no Symphony、no Graphify、no code-index、no Figma update、no next Project / Issue creation、no next Todo promotion from this issue.

## Validation evidence

`MTP-223-STAGE-CLOSEOUT-VALIDATION`

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | 通过，无输出 | 确认本 PR diff 不含 whitespace error。 |
| `bash checks/automation-readiness.sh` | 通过，输出 `MTPRO automation readiness checks passed.` | 已机械检查 MTP-223 stage audit input、matrix、validation plan、latest summary 和 automation readiness anchors。 |
| `bash checks/run.sh` | 通过，最终输出 `MTPRO checks passed.` | 已通过 automation readiness、Dashboard build、Dashboard smoke 和 325 个 XCTest；Dashboard smoke 输出包含 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`timelineItems=82`、`strategyTraderReadinessSurface=6` 和 `liveMonitoringReadOnlyConsoleV2Surface=4`。 |

## Known boundaries

`MTP-223-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`

- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。
- 本 issue 不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR`、Symphony 或 `symphony-issue`。
- 本 issue 不运行 Graphify、不运行 code-index、不修改 Figma、不提交 `.codex/*` 或 `graphify-out/*`。

## Root Docs Delta input

`MTP-223-ROOT-DOCS-DELTA-INPUT`

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-223 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 SwiftPM target graph evidence chain；不代表 Strategy runtime、Trader runtime、broker readiness、Live PRO Console readiness、live runtime readiness 或真实交易授权。 |
| `BLUEPRINT.md` | Target graph 可以表达 DomainModel / MessageBus / DataClient / DataEngine / Cache / Database / TraderStrategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench / Dashboard boundaries；ExecutionClient、broker command、OMS、production operations 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `environment.md` | 本 Project 未新增 required secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或 production operations；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | 当前 active SwiftPM target graph 已有 MTP-217 至 MTP-221 split targets；retained compatibility envelopes 只解释 existing implementation / import surface；不得把 target graph evidence 误写成 runtime implementation 完成。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 同步已发生事实；MTP-223 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

`MTP-223-STAGE-CODE-AUDIT-HANDOFF`

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-216` 至 `MTP-223`。
- Linear Project completion evidence：Project status `Completed`、`completedAt` 非空。
- Issue / PR evidence：PR #352、PR #353、PR #354、PR #355、PR #356、PR #357、PR #358 和 MTP-223 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：current target graph snapshot、retained compatibility envelopes、Trader-owned strategy path、Workbench / Dashboard read-model-only boundary、ExecutionClient future gate、forbidden implementation audit 和 unresolved future gates。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`。
- Residual Notes For Human Planning：Strategy runtime、Trader runtime、Live runtime、ExecutionClient / broker / OMS / Live PRO Console 和 L4 Live Production / Trading Commands 仍只能作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
