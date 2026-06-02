# MTPRO Strategy / Trader Instance Readiness v1 阶段审计输入材料

日期：2026-05-31

执行者：Codex

## 定位

`MTP-161-STRATEGY-TRADER-READINESS-STAGE-CLOSEOUT`

本文档是 `MTPRO Strategy / Trader Instance Readiness v1` 的 MTP-161 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

`MTP-161-STAGE-AUDIT-INPUT-MATERIAL`

本文档只准备 stage audit input material，集中收口 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence、Workbench / Report / Events strategy readiness surface evidence、no Graphify / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary 和 Parent Codex handoff checklist。

`MTP-161-NO-FINAL-STAGE-CODE-AUDIT`

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-154`、`MTP-155`、`MTP-156`、`MTP-157`、`MTP-158`、`MTP-159`、`MTP-160`、`MTP-161` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed`、`type=completed`、`completedAt` 非空后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-strategy-trader-instance-readiness-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`，不实现 final Stage Code Audit Report、Root Docs Refresh Gate、Strategy runtime、Trader runtime、lifecycle runtime、quoter runtime、hedger runtime、strategy scheduler、trader process manager、Execution Client、broker command、OMS、real order lifecycle、signed endpoint、account endpoint、listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、broker adapter、`LiveExecutionAdapter`、Strategy Console、Live PRO Console、trading button、live command 或 order form。

`MTP-161-STRATEGY-TRADER-READINESS-STAGE-AUDIT-INPUT`

本文档的审计输入范围只覆盖 `MTPRO Strategy / Trader Instance Readiness v1`，不把 closeout material 写成下一阶段 execution authorization。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Strategy / Trader Instance Readiness v1`。
- Project ID：`79cded9e-0ca5-47a7-ba76-985dd552c19e`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-strategy-trader-instance-readiness-v1-2df33ea509cb`。
- `MTP-154`、`MTP-155`、`MTP-156`、`MTP-157`、`MTP-158`、`MTP-159`、`MTP-160`：`Done`。
- `MTP-161`：`In Progress`。
- 当前 issue scope 仅限 validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence、stage audit input material、no final Stage Code Audit、no Graphify / no Figma / no `.codex/*` / no `graphify-out/*` PR boundary。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-154` | Strategy / Trader Instance readiness terminology、readiness-only boundary、proposal / readiness evidence baseline、L3.4 handoff boundary、forbidden capability baseline 和 first executable candidate non-authorization | [#273 MTP-154 define strategy trader readiness boundary](https://github.com/atxinbao/MTPRO/pull/273) | `a74f9cc9bfc7b3fc85fe39eeb048fc8582920b42` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26692345452/job/78670895402) |
| `MTP-155` | Strategy / Trader lifecycle、strategy instance identity、trader instance identity、read-model reference boundary、no lifecycle runtime boundary 和 identity sensitive field guard | [#274 MTP-155 define strategy trader lifecycle identity](https://github.com/atxinbao/MTPRO/pull/274) | `8836dd367de791c70f09784d1d8c505621edd757` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26692683435/job/78671801338) |
| `MTP-156` | quoter / hedger role taxonomy、role responsibility boundary、role proposal / read-model / blocked evidence relationship、no role execution behavior 和 forbidden role command surface | [#275 MTP-156 define quoter hedger role taxonomy](https://github.com/atxinbao/MTPRO/pull/275) | `5f495b00da8fa73aaea2bc4f31d4bc585526d683` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26693032785/job/78672714492) |
| `MTP-157` | account / portfolio / risk read-model input contract、input provenance / evidence trace、fresh / stale / missing / blocked / simulated / future-gated semantics 和 no real account / live risk runtime boundary | [#276 MTP-157 define read-model input contract](https://github.com/atxinbao/MTPRO/pull/276) | `b96c15bda602968991e34f47bae409a2fb7665c0` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26693500453/job/78673927708) |
| `MTP-158` | paper/live-neutral proposal contract、proposal attributes / status semantics、proposal-to-command isolation、no Execution Client / broker / OMS boundary 和 proposal forbidden command field guard | [#277 MTP-158 define proposal command isolation](https://github.com/atxinbao/MTPRO/pull/277) | `d3ee4df8dd03b2e4183b1a114e0cf8552b985f9f` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26693784729/job/78674667160) |
| `MTP-159` | forbidden Strategy -> Execution Client tests、forbidden broker command / OMS tests、forbidden UI command surface tests、proposal-to-command bypass guard、no signed/account endpoint / listenKey guard 和 deterministic local no-network test boundary | [#278 MTP-159 define forbidden command tests](https://github.com/atxinbao/MTPRO/pull/278) | `edab268b07986a96eab0ce331b049ec124f36565` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26694381807/job/78676251692) |
| `MTP-160` | Workbench / Report / Events strategy readiness read-model-only evidence surface、Dashboard smoke handle `strategyTraderReadinessSurface=6`、Event Timeline trace 和 no command / runtime / schema / account boundary | [#279 MTP-160 add strategy readiness evidence surface](https://github.com/atxinbao/MTPRO/pull/279) | `67cb8b9aadf373f490608dcf68ce5d4a0190df68` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26695245118/job/78678549745) |
| `MTP-161` | validation matrix、automation readiness anchors、forbidden capability evidence chain、read-model-only boundary evidence、Stage Code Audit 输入材料和 PR boundary 收口 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Strategy / Trader readiness validation evidence chain

`MTP-161-VALIDATION-EVIDENCE-CHAIN`

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-STRATEGY-TRADER-INSTANCE-READINESS` | MTP-154 定义 terminology / boundary；MTP-155 固定 lifecycle / identity；MTP-156 固定 quoter / hedger role taxonomy；MTP-157 固定 account / portfolio / risk read-model input；MTP-158 固定 paper/live-neutral proposal isolation；MTP-159 固定 forbidden Strategy / Execution / broker / UI command tests；MTP-160 固定 Workbench / Report / Events read-model-only surface；MTP-161 收口 validation matrix、automation readiness 和 stage audit input。 | 审计时确认 L3.4 只建立 Strategy / Trader Instance readiness evidence boundary，不运行 Strategy / Trader runtime，不生成 order command，不连接 broker，不调用 signed/account endpoint，不提供 Strategy Console、Live PRO Console、trading button、live command 或 order form。 |
| `TVM-REPORT-EVIDENCE` | MTP-160 将 strategy readiness surface 接入 Report read model / ViewModel，展示 source anchors、role labels、read-model inputs、proposal isolation、forbidden capability coverage 和 boundary notes。 | 审计时确认 Report 只消费 App read model / ViewModel，不读取 Runtime object、Persistence schema、Adapter request、secret、signed endpoint、account endpoint、listenKey、broker payload、real account state、execution report 或 broker fill。 |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | MTP-160 将 strategy readiness surface 接入 Dashboard Workbench details、Dashboard smoke `strategyTraderReadinessSurface=6` 和 Event Timeline `strategyTraderReadinessEvidenceSurface` section。 | 审计时确认 Workbench / Dashboard / Events 没有新增 Strategy Console、Live PRO Console、trading button、live command、order form、Runtime action、database console、query language、Graphify update 或 Figma change。 |
| Dashboard smoke | MTP-160 后 smoke summary 包含 `strategyTraderReadinessSurface=6`，并保留 read-model-only boundary、Live blocked gates、Live execution control gates、Live risk gates、Live incident / stop gates 和 Live monitoring handles。 | 审计时确认 smoke 能定位 Strategy / Trader readiness read-model-only evidence surface、Event Timeline evidence、read-model-only boundary 和所有 forbidden gates。 |
| Deterministic tests | MTP-160 App test 覆盖 Report / Workbench / Events read-model-only surface；MTP-154 至 MTP-159 的 contract / automation readiness checks 覆盖 terminology、identity、role、input、proposal isolation 和 forbidden capability anchors。 | 审计时确认 deterministic validation 不依赖真实 Binance private API、secret、account endpoint、listenKey、broker、真实账户、production operations、Graphify、Figma 或人工外包验收。 |

## Forbidden capability evidence

`MTP-161-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`

MTP-154 至 MTP-160 继续固定以下能力在当前 Project 中全部禁止：

- no Strategy runtime。
- no Trader runtime。
- no lifecycle runtime。
- no quoter runtime。
- no hedger runtime。
- no strategy scheduler。
- no trader process manager。
- no order generation engine。
- no Execution Client direct path。
- no executable order command。
- no broker command。
- no broker adapter。
- no broker / exchange execution adapter。
- no `LiveExecutionAdapter`。
- no OMS。
- no real order lifecycle。
- no real submit / cancel / replace。
- no execution report。
- no broker fill。
- no reconciliation。
- no signed endpoint。
- no account endpoint。
- no listenKey。
- no listenKey create / keepalive。
- no private WebSocket runtime。
- no private stream runtime。
- no account snapshot runtime。
- no live risk engine。
- no real pre-trade allow / reject runtime。
- no real account read。
- no broker position sync。
- no real account balance。
- no real position。
- no margin。
- no leverage。
- no real PnL runtime。
- no API key input。
- no secret storage。
- no Strategy Console。
- no Live PRO Console。
- no live command。
- no order form。
- no trading button。
- no stop / shutdown / restore executable action。
- no Graphify update。
- no Figma modification。
- no unauthorized next Project planning / Linear creation。

## Read-model-only boundary evidence

`MTP-161-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`

- `Strategy / Trader readiness terminology` 只定义 readiness 语言，不等于 runtime、execution、broker connection 或 trading authorization。
- `Strategy / Trader lifecycle identity` 只定义 configured / ready / blocked / inactive / simulation-only readiness states，不等于 running process、broker session、account session 或 order lifecycle。
- `quoter / hedger role taxonomy` 只定义 structural readiness roles，不输出 quote order、hedge order、broker command、OMS order 或 order-level live command。
- `account / portfolio / risk read-model input` 只来自 Read Model / ViewModel boundary，不读取真实账户、真实持仓、真实余额、margin、leverage、real PnL、account endpoint payload 或 broker state。
- `paper/live-neutral proposal` 只作为 read-model-only / evidence-only intent evidence，不升级为 executable order command、Execution Client request、OMS order 或 broker command。
- `forbidden capability tests` 只机械检查 forbidden evidence strings 和 blocked reasons，不创建 mock broker、Execution Client stub、OMS facade、command bus、Runtime object、Adapter request 或 schema。
- `StrategyTraderReadinessEvidenceSurfaceReadModel` / `StrategyTraderReadinessEvidenceSurfaceViewModel` 只把 MTP-154 至 MTP-159 deterministic evidence 复制到 App / Dashboard / Report / Events read-model-only surface。
- `DashboardShellSnapshot` 的 `strategyTraderReadinessSurface=6` 是 smoke handle，不表示 Strategy / Trader runtime readiness、broker readiness、Live PRO Console readiness、trading authorization 或 live command。

## Automation readiness evidence

`MTP-161-AUTOMATION-READINESS-STAGE-CLOSEOUT`

- `checks/automation-readiness.sh` 检查本 MTP-161 输入材料、contract、Trading Validation Matrix、validation plan、latest verification summary、automation readiness doc、MTP-154 至 MTP-160 source / test / surface anchors、PR #273 至 PR #279 evidence、Dashboard smoke handle `strategyTraderReadinessSurface=6` 和 no final Stage Code Audit boundary。
- GitHub PR Automation 仍负责 required check `checks`、squash merge、branch cleanup 和 Linear bot auto Done。
- `.codex/*`、`.build/*` 与 `graphify-out/*` 不进入 PR。
- MTP-161 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 仍归 Parent Codex closure flow。

## Validation evidence

`MTP-161-STAGE-CLOSEOUT-VALIDATION`

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/automation-readiness.sh` | passed | 输出 `MTPRO automation readiness checks passed.`，并机械检查 MTP-161 stage audit input、contract、matrix、validation plan、latest summary、automation readiness、PR evidence、Dashboard smoke handle 和 forbidden capability anchors。 |
| `git diff --check` | passed | 无输出，确认 MTP-161 diff 无 whitespace / patch error 输出。 |
| `bash checks/run.sh` | passed | 通过 automation readiness、Dashboard build、Dashboard smoke 和 303 个 XCTest；Dashboard smoke 包含 `strategyTraderReadinessSurface=6`；最终输出 `MTPRO checks passed.`。 |

## Known boundaries

`MTP-161-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

- 本 Project 只建立 L3.4 Strategy / Trader Instance readiness evidence boundary，不实现 Strategy runtime、Trader runtime、Execution Client、broker command、OMS 或 Live PRO Console。
- Strategy / Trader readiness evidence 只来自 contract anchors、deterministic local evidence 和 App read-model-only surface，不来自 signed endpoint、account endpoint、listenKey、private WebSocket、broker adapter、broker payload 或 real account payload。
- Workbench / Dashboard / Report / Event Timeline 只展示 read model / ViewModel，不提供 Strategy Console、Live PRO Console、trading button、live command、order form、Runtime action 或 database console。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report，不授权下一阶段 Project planning 或 execution。
- 本 issue 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-161 输入结论 |
| --- | --- |
| `GOAL.md` | 本 Project 完成后只证明 L3.4 Strategy / Trader Instance readiness evidence boundary 已闭环；不代表 Strategy runtime、Trader runtime、broker readiness、Live PRO Console readiness、live runtime readiness 或真实交易授权。 |
| `BLUEPRINT.md` | Strategy / Trader Instance readiness 可以作为 Future Live 路线的 readiness evidence layer；Execution Client、broker command、OMS、production operations 和 Live PRO Console 仍属于 Future Construction Zones。 |
| `environment.md` | 本 Project 未新增 required secret 读取、broker credential、外部写能力、signed endpoint、account endpoint、listenKey、真实账户读取或 production operations；统一验证入口仍是 `bash checks/run.sh`。 |
| `architecture.md` | Core / App / Dashboard 边界继续成立；L3.4 evidence 沿 contract / deterministic evidence -> App read model / ViewModel -> Dashboard / Report / Event Timeline evidence surface 流动，不读取 adapter、Runtime object、SQLite / DuckDB schema、真实账户 / broker state 或 production operations state。 |
| `docs/roadmap.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和 final closure summary 同步已发生事实；MTP-161 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-154`、`MTP-155`、`MTP-156`、`MTP-157`、`MTP-158`、`MTP-159`、`MTP-160`、`MTP-161`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #273、#274、#275、#276、#277、#278、#279 和 MTP-161 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：Strategy / Trader Instance readiness terminology、lifecycle / identity、quoter / hedger role taxonomy、account / portfolio / risk read-model input、paper/live-neutral proposal isolation、forbidden Strategy / Execution / broker / UI command tests、Workbench / Report / Events read-model-only strategy readiness surface、Dashboard smoke `strategyTraderReadinessSurface=6`、Strategy runtime、Trader runtime、lifecycle runtime、Execution Client、broker command、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、real account read、real balance、real position、margin、leverage、real PnL、Strategy Console、Live PRO Console、live command、order form、trading button、Graphify update 和 Figma change 禁区。
- Root Docs Delta：检查 `GOAL.md`、`BLUEPRINT.md`、`environment.md`、`architecture.md`、`docs/roadmap.md`。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
