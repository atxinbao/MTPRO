# MTPRO Target Module Physical Layout / Source Migration v1 阶段审计输入材料

日期：2026-06-01

执行者：Codex

## 定位

`MTP-190-TARGET-MODULE-SOURCE-MIGRATION-STAGE-CLOSEOUT`

本文档是 `MTPRO Target Module Physical Layout / Source Migration v1` 的 MTP-190 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

`MTP-190-STAGE-AUDIT-INPUT-MATERIAL`

本文档只准备 stage audit input material，集中收口 MTP-183 至 MTP-189 source migration evidence chain、`TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION` validation matrix、automation readiness anchors、remaining compatibility shell audit、forbidden live / broker / order capability audit、deferred target graph split gates、no Graphify / no Figma / no `.codex/*` / no `.build/*` / no `graphify-out/*` PR boundary 和 Parent Codex handoff checklist。

`MTP-190-NO-FINAL-STAGE-CODE-AUDIT`

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-183` 至 `MTP-190` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-target-module-physical-layout-source-migration-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 L4 Linear Project / Issue，不推进下一阶段，不启动下一阶段 `@002 / PAR` 或 Symphony，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、SwiftPM target graph split、Strategy runtime、Trader runtime、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter、real order lifecycle、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Target Module Physical Layout / Source Migration v1`。
- Project ID：`b102a190-158a-4336-abb2-524f8f050153`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-target-module-physical-layout-source-migration-v1-266c4816df2f`。
- `MTP-183` 至 `MTP-189`：`Done`。
- `MTP-190`：当前 issue execution scope。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、source migration evidence chain、remaining compatibility shell audit、forbidden capability audit、stage audit input material、no final Stage Code Audit、no Graphify / no Figma / no `.codex/*` / no `.build/*` / no `graphify-out/*` PR boundary。

## Issue / PR evidence input

`MTP-190-SOURCE-MIGRATION-EVIDENCE-CHAIN`

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-183` | target physical layout、SwiftPM migration contract、old-to-new source map | [#306](https://github.com/atxinbao/MTPRO/pull/306) | `69b538ffdb1a4666cda82caa12cb5a2a057249e5` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26762016917/job/78877926700) |
| `MTP-184` | DomainModel / MessageBus spine source migration | [#307](https://github.com/atxinbao/MTPRO/pull/307) | `12a6fb57e0f996d6e90f484a9a13600a5dbd3ab8` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26763375478/job/78882873762) |
| `MTP-185` | DataClient / DataEngine source migration | [#308](https://github.com/atxinbao/MTPRO/pull/308) | `72cc046f5fdba866cda1350411a45a34ec9fbec6` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26765129617/job/78889266742) |
| `MTP-186` | Cache / Database source migration | [#309](https://github.com/atxinbao/MTPRO/pull/309) | `4861304b0808ce2772b0726a05296a8229f91396` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26766963635/job/78895883955) |
| `MTP-187` | Strategies / Trader / Portfolio source migration | [#310](https://github.com/atxinbao/MTPRO/pull/310) | `879ea3c08acbceec7659ae4b9dd41eefb50c8776` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26768553471/job/78901503316) |
| `MTP-188` | RiskEngine / ExecutionEngine / ExecutionClient future gate source migration | [#311](https://github.com/atxinbao/MTPRO/pull/311) | `794eb16d91f521e725abf6e23af621fb79f27fab` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26770246101/job/78907483195) |
| `MTP-189` | Workbench / Dashboard source migration | [#312](https://github.com/atxinbao/MTPRO/pull/312) | `b54cd5a501d27ec3341b657f1916ce25fee26f59` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26771715539/job/78912634777) |
| `MTP-190` | validation matrix、automation readiness、stage audit input material closeout | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Source migration closeout

`MTP-190-SOURCE-MIGRATION-CLOSEOUT`

| Target module | Current placement evidence | Compatibility / deferred state |
| --- | --- | --- |
| DomainModel | `Sources/DomainModel/` | 仍由现有 `Core` target compatibility envelope 编译；未拆出独立 SwiftPM target。 |
| MessageBus | `Sources/MessageBus/` | 仍由 `Core` target compatibility envelope 编译；未实现完整 runtime MessageBus。 |
| DataClient | `Sources/DataClient/Binance/PublicMarketData/` | `Adapters` target 仍是 compatibility envelope；private / signed / account client 仍 future-gated。 |
| DataEngine | `Sources/DataEngine/ScenarioReplay/`、`Sources/DataEngine/DataQuality/`、`Sources/DataEngine/Ingest/` | `Core` / `Runtime` compatibility envelope 仍保留；未实现 production streaming DataEngine runtime。 |
| Cache | `Sources/Cache/MarketData/` | `Core` compatibility envelope 仍保留；未实现 external cache service。 |
| Database | `Sources/Database/Projections/SQLite/`、`Sources/Database/Projections/DuckDB/`、`Sources/Database/ReplayProjection/` | `Persistence` / `CSQLite` target name 不再作为 source owner；schema 不暴露给 UI。 |
| Strategies | `Sources/Strategies/EMA/`、`Sources/Strategies/OrderBookImbalance/` | `Core` compatibility envelope 仍保留；未实现 Strategy runtime。 |
| Trader | `Sources/Trader/StrategyBindings/` | 只保留 deterministic local strategy / risk / portfolio coordination evidence；未实现 Trader runtime。 |
| Portfolio | `Sources/Portfolio/` | 当前只持有 paper / simulated / read-model financial state；未读取 broker account state。 |
| RiskEngine | `Sources/RiskEngine/PreTrade/`、`Sources/RiskEngine/LiveGate/` | `Core` compatibility envelope 仍保留；未实现 live RiskEngine runtime。 |
| ExecutionEngine | `Sources/ExecutionEngine/PaperLifecycle/`、`Sources/ExecutionEngine/SimulatedExchange/`、`Sources/ExecutionEngine/OMSFutureGate/` | 当前只表示 paper / simulated lifecycle evidence 与 OMS future gate；未实现 real order runtime。 |
| ExecutionClient | `Sources/ExecutionClient/FutureGate/`、`Sources/ExecutionClient/BrokerCapabilityMatrix/` | 仅保存 future-gated taxonomy / boundary evidence；未实现 broker / exchange execution adapter。 |
| Workbench | `Sources/Workbench/ReadModels/`、`Sources/Workbench/Report/`、`Sources/Workbench/Dashboard/`、`Sources/Workbench/Events/`、`Sources/Workbench/FutureLiveProConsole/` | `App` target compatibility envelope 仍保留；Workbench 只消费 ReadModel / ViewModel。 |
| Dashboard | `Sources/Dashboard/` | Dashboard executable 只保留 shell / smoke source；不形成 live command surface。 |

`MTP-190-REMAINING-COMPATIBILITY-SHELL-AUDIT`

当前 Project 完成的是 source directory ownership migration，不是 final SwiftPM target graph split。`Core`、`Adapters`、`Runtime`、`App`、`Dashboard` 等 target / product name 仍可作为 compatibility envelope 保持 buildability；后续拆分为真实 target graph 必须由新的 Project Definition、dependency audit、validation matrix 和 Parent Codex queue preflight 单独授权。

## Validation matrix closeout

`MTP-190-VALIDATION-MATRIX-CLOSEOUT`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION` | MTP-183 固定 target physical layout 和 SwiftPM migration contract；MTP-184 至 MTP-189 分批完成 DomainModel / MessageBus、DataClient / DataEngine、Cache / Database、Strategies / Trader / Portfolio、RiskEngine / ExecutionEngine / ExecutionClient future gate、Workbench / Dashboard physical source migration；MTP-190 收口 matrix、automation readiness 和 stage audit input。 | 审计时确认本 Project 只完成 boundary-preserving physical source migration，不完成 final target graph split，不新增 SwiftPM product / dependency，不实现 future-gated runtime / broker / live / command capability。 |

## Automation readiness evidence

`MTP-190-AUTOMATION-READINESS-CLOSEOUT`

- `checks/automation-readiness.sh` 必须机械检查本 MTP-190 stage audit input、MTP-190 domain context、module-boundary docs、validation matrix、validation plan、latest verification summary、automation readiness doc、MTP-183 至 MTP-189 issue backfill、PR #306 至 PR #312 evidence 和 no final Stage Code Audit boundary。
- GitHub PR Automation 仍负责 required check `checks`、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*`、`.build/*` 与 `graphify-out/*` 不进入 PR。
- MTP-190 不设置 Linear Project `Completed`；Project closure、最终 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 仍归 Parent Codex closure flow。

## Forbidden implementation audit

`MTP-190-FORBIDDEN-IMPLEMENTATION-AUDIT`

本 Project 的 forbidden implementation audit 继续固定以下能力在当前 scope 中全部禁止：

- no SwiftPM target graph split as completion claim；no new product / dependency / target beyond compatibility envelopes.
- no Strategy runtime、Trader runtime、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter 或 live coordinator。
- no signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime、account snapshot runtime、credential provider、API key input 或 secret storage。
- no real account read、broker position sync、real balance、real position、margin、leverage、buying power、real PnL、execution report、broker fill 或 reconciliation。
- no Live PRO Console implementation、trading button、live command、order form、emergency stop、shutdown、restore、broker connect UI、account connect UI、ExecutionClient request UI、OMS command UI 或 production operations command。
- no Runtime object、Adapter request、SQLite / DuckDB schema、account endpoint payload、broker payload、broker state 或 database schema exposure in Workbench / Report / Events。

## Unresolved future gates

`MTP-190-UNRESOLVED-FUTURE-GATES`

后续仍必须独立处理：

- SwiftPM Target Split gate：把 compatibility envelope 转成真实 module target graph 需要新的 Project Definition、migration order、dependency audit 和 validation matrix。
- L4 Project Definition gate：live production / trading command 目标、scope、issue order、dependencies、validation 和 boundary 需由 Human + `@001 / PLN` 重新规划。
- Signed / account gate：credential、signed endpoint、account endpoint、listenKey、private stream 和 account snapshot runtime 仍未授权。
- Broker / execution gate：ExecutionClient、broker adapter、OMS、real order lifecycle、execution report、broker fill 和 reconciliation 仍未授权。
- Product surface gate：Future Live PRO Console、trading button、live command、order form、emergency stop、shutdown、restore 和 operations controls 仍未授权。
- Validation gate：后续 Project 需要新的 issue-specific validation matrix、local deterministic tests、read-model / command boundary checks 和 post-issue evidence chain；不得复用 `TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION` 作为 execution authorization。

## Validation evidence

`MTP-190-STAGE-CLOSEOUT-VALIDATION`

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `git diff --check` | passed | 无输出，确认 MTP-190 diff 无 whitespace / patch error 输出。 |
| `bash checks/automation-readiness.sh` | passed | 输出 `MTPRO automation readiness checks passed.`，并机械检查 MTP-190 stage audit input、module-boundary docs、domain context、validation matrix、validation plan、latest summary 和 automation readiness anchors。 |
| `bash checks/run.sh` | passed | 通过 automation readiness、Dashboard build、Dashboard smoke 和 306 个 XCTest；Dashboard smoke 包含 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`timelineItems=82`、`strategyTraderReadinessSurface=6` 和 `liveMonitoringReadOnlyConsoleV2Surface=4`；最终输出 `MTPRO checks passed.`。 |

## Known boundaries

`MTP-190-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`

- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。
- 本 issue 不设置 Linear Project `Completed`，不创建 L4 Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR` 或 Symphony。
- 本 issue 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-190 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 Target Module Physical Layout / Source Migration before L4；不代表 L4 runtime、broker readiness、Live PRO Console readiness、live runtime readiness 或真实交易授权。 |
| `BLUEPRINT.md` | Target module physical layout 已迁入 `Sources/*` 目录结构，可作为后续 SwiftPM target split 和 L4 planning input；signed endpoint、broker command、OMS、production operations 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `environment.md` | 本 Project 未新增 required secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或 production operations；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | 当前 source tree 已从旧粗粒度目录迁往目标 module directories，但 SwiftPM target graph 仍保留 compatibility envelope；不得把目录迁移误写成 runtime implementation 完成。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 同步已发生事实；MTP-190 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-183` 至 `MTP-190`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #306 至 #312 和 MTP-190 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：target physical layout、SwiftPM migration contract、old-to-new source map、DomainModel / MessageBus、DataClient / DataEngine、Cache / Database、Strategies / Trader / Portfolio、RiskEngine / ExecutionEngine / ExecutionClient future gate、Workbench / Dashboard physical migration、remaining compatibility shells、forbidden implementation audit 和 unresolved future gates。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`。
- Residual Notes For Human Planning：L4 和 SwiftPM target split 仍只能作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
