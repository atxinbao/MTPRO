# MTP-60 阶段审计输入材料

日期：2026-05-20

执行者：Codex

## 定位

本文档是 `MTPRO Market Data Replay Operations v1` 的 MTP-60 阶段审计输入材料，服务当前 issue 的 PR evidence 和 Project 完成后的 Parent Codex Stage Code Audit Report。

本文档不是最终 Stage Code Audit Report。最终报告必须在 `MTP-54`、`MTP-55`、`MTP-56`、`MTP-57`、`MTP-58`、`MTP-59`、`MTP-60` 全部进入 Linear `Done`，且 Linear Project status 被设置或确认为 `Completed` 后，由 Parent Codex 单独输出到：

```text
docs/audit/mtpro-market-data-replay-operations-v1-stage-code-audit.md
```

本文档不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进下一 issue，不启动下一阶段 `symphony-issue`。

## Linear queue evidence

只读 Linear 查询确认：

- Linear Project：`MTPRO Market Data Replay Operations v1`。
- Project ID：`0110aee8-f6c6-46f6-9140-d8c3048dc886`。
- Project URL：`https://linear.app/atxinbao/project/mtpro-market-data-replay-operations-v1-8bc94eb2edd3`。
- `MTP-54`、`MTP-55`、`MTP-56`、`MTP-57`、`MTP-58`、`MTP-59`：`Done`。
- `MTP-60`：`In Progress`。
- 当前 issue scope 仅限 validation evidence、automation readiness anchor、Dashboard smoke evidence、known boundaries 和 Stage Code Audit 输入材料。

## Issue / PR evidence input

| Issue | Evidence domain | PR | Merge commit | GitHub required check |
| --- | --- | --- | --- | --- |
| `MTP-54` | Binance public read-only market data batch / replay boundary、最小字段集合和 forbidden capability | [#101 MTP-54 Define market data batch replay boundary](https://github.com/atxinbao/MTPRO/pull/101) | `01e9abc16496ed89c6a5fc118fff64ffe4849584` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26144135901/job/76895623993) |
| `MTP-55` | Local replay operations metadata、batch replay contract 和 deterministic metadata fixture | [#102 MTP-55 local replay metadata contract](https://github.com/atxinbao/MTPRO/pull/102) | `2a744ac399c9088c89b8c100453802508f2a6d3f` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26145067408/job/76898613655) |
| `MTP-56` | Retention policy、freshness evidence read model 和 batch freshness summary | [#103 [codex] Add market data replay freshness evidence](https://github.com/atxinbao/MTPRO/pull/103) | `bd3b77750c98a9ddf50a90f80e864c8006bdea2b` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26146081379/job/76901843799) |
| `MTP-57` | Deterministic fixture parity、replay consistency、ordering / checksum drift rejection 和 network independence evidence | [#104 [codex] Add deterministic batch replay parity evidence](https://github.com/atxinbao/MTPRO/pull/104) | `5280ed2445fc3384d9f252464472882634812320` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26147081511/job/76905049950) |
| `MTP-58` | Event log / projection snapshot consistency、append-only `.market` sequence 和 schema non-exposure | [#105 [codex] Add market data replay projection consistency evidence](https://github.com/atxinbao/MTPRO/pull/105) | `d4780e98d854cda4100d79edf9934e4c81d9e7e3` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26148314467/job/76909137437) |
| `MTP-59` | Report / Dashboard / Event Timeline read-model-only replay operations evidence 和 Dashboard smoke | [#106 MTP-59 wire replay operations read models](https://github.com/atxinbao/MTPRO/pull/106) | `63b4500550bd8af07c7fb16d8ad1e9e04d1ae41a` | [checks success](https://github.com/atxinbao/MTPRO/actions/runs/26149396097/job/76912704903) |
| `MTP-60` | validation summary、matrix 收口、automation readiness evidence、Dashboard smoke evidence 和 Stage Code Audit 输入 | 当前 issue PR | 当前 issue merge commit 待 GitHub PR Automation 产生 | 当前 issue PR 必须通过 `checks` |

## Market data replay operations validation evidence chain

| Matrix ID | 已落地 evidence | Stage Code Audit 输入 |
| --- | --- | --- |
| `TVM-MARKET-DATA-REPLAY-OPERATIONS` | MTP-54 至 MTP-58 已覆盖 public read-only batch / replay boundary、local metadata、retention / freshness evidence、fixture parity、event log / projection consistency 和 schema non-exposure；MTP-59 将该 evidence 复制为 App 层 read-model-only 展示。 | 审计时确认 PR #101 至 PR #106 共同保持 public-read-only、local fixture replay、network-independent required validation、append-only facts source 和 read-model-only presentation，不引入 signed endpoint、broker action、真实订单或 production runtime operations。 |
| `TVM-REPORT-EVIDENCE` | MTP-59 把 replay operations evidence 接入 `ReportViewModel`、Dashboard shell snapshot 和 Event Timeline item，展示 batch id、replay run id、freshness / retention status、event log / replay record counts 和 projection consistency summary。 | 审计时确认 Report / Dashboard / Event Timeline 只消费 App read model，不读取 Runtime object、adapter request、SQLite / DuckDB schema、SQL、ORM 或 persistence implementation。 |
| Dashboard smoke | `DASHBOARD_SMOKE=1 swift run Dashboard` 在 MTP-59 后输出 `Dashboard smoke: sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0; sections=Market,Strategy,Backtest,Report,Paper,Risk,Portfolio,Events`。 | 审计时确认 smoke 保持八个 Dashboard sections、readModelOnly / workbenchReadModelOnly flags 和 no command surface；`timelineItems=0` 来自空启动 read model，fixture 级 replay operations timeline coverage 由 App deterministic tests 覆盖。 |
| Deterministic tests | Adapters tests 覆盖 boundary / metadata / retention / freshness / fixture parity；Runtime tests 覆盖 event log / projection consistency；App tests 覆盖 Report / Dashboard / Event Timeline read-model-only evidence。 | 审计时确认 deterministic validation 不依赖真实 Binance 网络、secret、account endpoint、broker、production scheduler、retention cleanup、真实订单或 Live trading。 |

## Automation readiness evidence

- `checks/automation-readiness.sh` 检查本 MTP-60 输入材料、latest verification summary、Trading Validation Matrix、validation plan、Dashboard smoke evidence 和 MTP-54 至 MTP-59 market data replay anchors。
- GitHub PR Automation 仍负责 required check `checks`、squash auto-merge、branch cleanup 和 Linear bot auto Done。
- child Codex 只在当前 issue workspace 内提交文档 / 验证证据和 handoff marker；`.codex/*` 与 `graphify-out/*` 不进入 PR。
- Graphify post-merge resource relationship graph refresh 仍由 Symphony host-side Post-Issue Ledger 执行，不由 child Codex 在 sandbox 内强制执行。
- MTP-60 不修改 active Project pointer；Project closure、Linear Project `Completed` status、最终 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条仍归 Parent Codex 边界。

## Validation evidence

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `DASHBOARD_SMOKE=1 swift run Dashboard` | pass | MTP-59 后已有 Dashboard smoke evidence：`sections=8; readModelOnly=true; workbenchReadModelOnly=true; controls=start,pause,close,reset; timelineItems=0`。 |
| `bash checks/automation-readiness.sh` | pass | 本 issue 加固 MTP-60 stage audit input、validation plan、matrix、latest summary 和 Dashboard smoke anchors 后通过，输出 `MTPRO automation readiness checks passed.`。 |
| `bash checks/run.sh` | pass | 串联 `git diff --check`、automation readiness、dashboard build、dashboard smoke 和 `swift test`；121 个 XCTest 通过，输出 `MTPRO checks passed.`。 |

## Known boundaries

- 本 Project 只覆盖本地 market data replay operations evidence，不实现 production data platform、production scheduler、真实历史下载规模、retention cleanup job、projection rebuild command 或 operations console。
- Binance 边界只允许 public read-only market data；required validation 只依赖 mock transport / fixture parity / local batch replay，真实 Binance public network smoke 只能作为 optional manual evidence。
- 不接 API key、signed endpoint、account endpoint、listenKey user data stream、broker action、Live trading 或真实订单 submit / cancel / replace。
- Local replay metadata、freshness evidence、fixture parity 和 projection consistency 只描述本地 deterministic evidence，不代表生产运行、真实交易授权、broker reconciliation 或真实账户状态。
- Event log / projection consistency 只消费 append-only `.market` facts source 和 projection snapshot summary；不暴露 SQLite / DuckDB schema、SQL、ORM、Runtime object、adapter request 或 persistence implementation。
- Report / Dashboard / Event Timeline 只消费 App read model / ViewModel，不提供 command surface、retention cleanup、projection rebuild、order-level command、按钮、表单或交易执行入口。
- Stage audit input 只准备 Parent Codex 审计材料，不替代最终 Stage Code Audit Report。

## Root Docs Delta input

Parent Codex 输出最终 Stage Code Audit Report 时必须检查：

| Root doc | MTP-60 输入结论 |
| --- | --- |
| `GOAL.md` | Project 完成后可将 “更长周期 market data replay / operations” 从 Pending 更新为已形成本地 evidence baseline；不改变 no Live / no signed endpoint / no broker action 禁区。 |
| `ENVIRONMENT.md` | 本 Project 未新增外部依赖或验证入口；统一验证入口仍是 `bash checks/run.sh`，required validation 仍不依赖真实 Binance 网络。 |
| `ARCHITECTURE.md` | Adapters / Runtime / App / Dashboard 既有边界继续成立；market data replay operations evidence 沿 public read-only adapter contract、本地 replay metadata、append-only event log / projection consistency 和 read-model-only Dashboard 路径流动。 |
| `ROADMAP.md` | Project 完成后需要由 Parent Codex 设置或确认 Linear Project `Completed`，再通过 Stage Code Audit Report、Root Docs Refresh Gate 和当前阶段完成进度条同步已发生事实；MTP-60 不直接修改下一阶段路线，不创建下一 Project / Issue。 |

## Stage Code Audit handoff checklist

最终 Stage Code Audit Report 至少应覆盖：

- Project scope / issue range：`MTP-54`、`MTP-55`、`MTP-56`、`MTP-57`、`MTP-58`、`MTP-59`、`MTP-60`。
- Linear Project completion evidence：Project status `Completed`、`type=completed`、`completedAt` 非空。
- Issue / PR evidence：PR #101、#102、#103、#104、#105、#106 和 MTP-60 PR。
- Validation：每个 PR 的 GitHub required check `checks`，以及最终本地 `bash checks/run.sh`。
- Boundary Audit：public read-only market data、local fixture replay、network-independent required validation、retention / freshness read model、event log / projection consistency、Report / Dashboard / Event Timeline read-model-only evidence、Live trading、signed endpoint、account endpoint、listenKey、broker action、真实订单、production operations、schema leakage 和 command surface 禁区。
- Known CI Boundary：如本 Project 没有新增临时 CI 平台边界，应明确记录无新增；若 MTP-60 PR 暴露失败，按事实记录。
- Root Docs Delta：检查 `GOAL.md`、`ENVIRONMENT.md`、`ARCHITECTURE.md`、`ROADMAP.md`。
- Current Phase Progress Bar：Root Docs Refresh Gate closure 后由 `@002 / PAR` 按 `GOAL.md` / `ROADMAP.md` 目标切片输出，不按 Project closure count 直接计算目标完成度。
- Residual Notes For Human Planning：下一阶段只作为 Human + `@001 / PLN` planning input，不授权自动创建或推进 issue。
