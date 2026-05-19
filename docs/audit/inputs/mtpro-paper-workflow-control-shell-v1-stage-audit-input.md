# MTP-53 阶段审计输入材料

日期：2026-05-20

执行者：Codex

## 定位

本文档是 `MTPRO Paper Workflow Control Shell v1` 的 MTP-53 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-47`、`MTP-48`、`MTP-49`、`MTP-50`、`MTP-51`、`MTP-52`、`MTP-53` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed` 后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-paper-workflow-control-shell-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一 issue，不启动下一阶段 `symphony-issue`。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Paper Workflow Control Shell v1`。
- Project ID：`323fce8a-70dc-412d-b154-b46508a01414`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-paper-workflow-control-shell-v1-897d657eea2a`。
- `MTP-47`、`MTP-48`、`MTP-49`、`MTP-50`、`MTP-51`、`MTP-52`：`Done`。
- `MTP-53`：`In Progress`。
- 当前 issue scope 仅限 deterministic validation、Dashboard smoke、automation readiness anchor、known boundaries 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-47` | Paper workflow Workbench information architecture、session-level controls 允许集合和 forbidden capability 边界 | [#91 [codex] Define paper workflow workbench IA](https://github.com/atxinbao/MTPRO/pull/91) | `5561b388c1683dd0923142af4bcd820b324a5617` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26117933849/job/76812000343) |
| `MTP-48` | Paper session-level local Command Model、rejected reason 和 no order-level / no broker action 边界 | [#92 MTP-48 add paper session local control command](https://github.com/atxinbao/MTPRO/pull/92) | `94530e1ac8859bd7520247c6071f3beb3f22f000` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26120768663/job/76821854665) |
| `MTP-49` | Session-level control -> paper-only event boundary、accepted / rejected facts 和 append-only `.paper` stream | [#93 MTP-49 Paper session control event boundary](https://github.com/atxinbao/MTPRO/pull/93) | `414bb46d8d2a25b8163532753f22fab0ea36461b` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26122263714/job/76826986462) |
| `MTP-50` | Paper workflow observability Read Model / ViewModel、replay freshness、blocked / allowed evidence 和 schema non-exposure | [#94 [codex] Add paper workflow observability view model](https://github.com/atxinbao/MTPRO/pull/94) | `bfbaa6b4601722daaf0bc63826b39eaff7371425` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26123653505/job/76831746055) |
| `MTP-51` | read-model-only Event Timeline / Evidence Explorer 子集、evidence links、read-only filter 和 no command / no schema 边界 | [#95 MTP-51 add read-model-only evidence explorer](https://github.com/atxinbao/MTPRO/pull/95) | `ef3025ee3edce868f114d66fb60fcba2bf361e15` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26124838199/job/76835764336) |
| `MTP-52` | Dashboard / Workbench shell snapshot、Dashboard smoke workbench evidence 和 no button / no command / schema / runtime / adapter 边界 | [#96 MTP-52 extend dashboard workbench shell](https://github.com/atxinbao/MTPRO/pull/96) | `3b31f268b880a31304950ee3ff289fdd3f76d0bc` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26125845239/job/76839197456) |
| `MTP-53` | validation summary、matrix 收口、automation readiness evidence、Dashboard smoke evidence 和 Stage Code Audit 输入 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Paper workflow control shell validation evidence chain

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-PAPER-WORKFLOW-CONTROL-SHELL` | MTP-47 至 MTP-52 已覆盖 Workbench IA、session-level local Command Model、paper-only event boundary、observability ViewModel、Event Timeline / Evidence Explorer 和 Dashboard / Workbench shell snapshot。 | 审计时确认 PR #91 至 PR #96 共同保持 session-level local control、read-model-only UI 和 paper-only evidence boundary，不引入 order-level command、broker action、signed endpoint、真实订单或 UI schema leakage。 |
| Dashboard smoke | `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 `Dashboard smoke: sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 | 审计时确认 smoke 覆盖八个 Dashboard sections、Workbench read-model-only flag、四个 session-level controls 和 Event Timeline evidence 字段；`timelineItems=0` 来自空启动 read model，不代表缺失 Evidence Explorer fixture coverage。 |
| Deterministic tests | App tests 覆盖 Workbench IA、observability、Evidence Explorer、Dashboard shell snapshot 和 source import boundary；Core tests 覆盖 local command validation、Codable bypass rejection、event boundary accepted / rejected facts 和 append-only sequence。 | 审计时确认 deterministic validation 不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。 |

## Automation readiness evidence

- `checks/automation-readiness.sh` 检查本 MTP-53 输入材料、latest verification summary、Trading Validation Matrix、validation plan 和 Dashboard smoke anchors。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档 / 验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-53 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | 输出 `Dashboard smoke: sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 |
| `bash checks/automation-readiness.sh` | pass | 输出 `MTPRO automation readiness checks passed.`；确认 MTP-53 输入材料、matrix、latest summary、validation plan 和 Dashboard smoke anchors 完整。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test`；106 个 XCTest 通过，输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只覆盖本地 Paper workflow control shell、observability 和 read-model-only Dashboard / Workbench evidence。
- Session-level controls 只允许 `start` / `pause` / `close` / `reset`，且只能作为本地 Paper session-level intent 或 read-only presentation。
- 不接 Live trading、signed endpoint、account endpoint、listenKey user data stream 或真实 broker action。
- 不提交、取消、替换或撮合真实订单，不实现 OMS，不提供 order-level command。
- Observability、Event Timeline / Evidence Explorer 和 Dashboard shell 只消费稳定 read model / ViewModel / Command Model，不暴露 SQLite / DuckDB schema、SQL、ORM model、runtime object、Persistence adapter direct read 或 adapter request。
- Dashboard smoke 中的 `timelineItems=0` 来自空 read model 启动快照；fixture 级 timeline coverage 仍由 `Tests/AppTests/AppTests.swift` 的 deterministic snapshot tests 覆盖。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-53 输入结论 |
| --- | --- |
| `GOAL.md` | 项目目标仍是 Research -> Backtest -> Paper 一致性工作台；本 Project 增加 Paper workflow 可观察性和本地控制壳 evidence，不改变 Live 禁区。 |
| `ENVIRONMENT.md` | 本 Project 未新增本地依赖或验证入口；统一验证入口仍是 `bash checks/run.sh`，并继续包含 Dashboard smoke。 |
| `ARCHITECTURE.md` | Core / App / Dashboard 既有边界继续成立；新增 control shell evidence 沿 Core command / paper event boundary、App read model / ViewModel 和 Dashboard shell snapshot 流动。 |
| `ROADMAP.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条同步已发生事实；MTP-53 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-47`、`MTP-48`、`MTP-49`、`MTP-50`、`MTP-51`、`MTP-52`、`MTP-53`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #91、#92、#93、#94、#95、#96 和 MTP-53 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：Live trading、signed endpoint、account endpoint、listenKey、broker action、真实订单、order-level command、OMS、数据库 schema leakage、Runtime / adapter leakage、Dashboard execution surface 和 report / workbench 授权边界。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-53 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md`。
- Current Phase Progress Bar：Root Docs Refresh Gate closure 后由 `@002 / PAR` 按 `GOAL.md` / `ROADMAP.md` 目标切片输出，不按 Project closure count 直接计算目标完成度。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
