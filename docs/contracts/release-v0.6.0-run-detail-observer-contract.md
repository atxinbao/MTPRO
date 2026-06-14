# Release v0.6.0 Dashboard / CLI Run Detail Observer Contract

日期：2026-06-15

执行者：Codex

## Scope

GH-764 将 Dashboard / CLI run detail observer 从 v0.5 deterministic observer surface 推进为 v0.6 artifact-backed read-model。observer 只读取 `ReleaseV060LocalRunJournalWriter` 已写入的本地 run 目录，先校验 `manifest.json` 中的 required artifact sha256 / bytes，再读取 `events.jsonl`、`projection.json`、`summary.json` 和 `_RUN_STATUS.json`。

## Validation Anchors

- `V060-010-DASHBOARD-CLI-RUN-DETAIL-OBSERVER`
- `V060-010-ARTIFACT-BACKED-RUN-LIST-STATUS-EVENTS-PROJECTION-RISK`
- `V060-010-DASHBOARD-READS-SAME-MANIFEST-AS-CLI`
- `V060-010-MANIFEST-CORRUPTION-GAP-STATE`
- `V060-010-NO-PRODUCTION-COMMAND-SURFACE`
- `TVM-RELEASE-V060-DASHBOARD-CLI-RUN-DETAIL-OBSERVER`

## CLI Contract

`mtpro run-detail-observer` 是只读命令集合，只允许以下子命令：

- `list`
- `status [runID]`
- `events [runID]`
- `projection [runID]`
- `risk [runID]`

这些命令只能展示本地 run artifact 的状态、event timeline、Portfolio projection 和 risk decisions。它们不得创建、修改、提交、取消或替换任何订单。

## Dashboard Contract

Dashboard 只消费 `ReleaseV060RunDetailObserverEvidence` 并生成 `ReleaseV060DashboardRunDetailObserverViewModel`。ViewModel 必须展示：

- Run Overview
- Event Timeline
- Risk Decisions
- OMS Timeline
- Portfolio Projection
- Boundary / Environment / Secret Policy

Dashboard 与 CLI 必须读取同一份 manifest 和同一个 runID。manifest 缺失、projection 缺失、checksum mismatch 或 byte count mismatch 都必须显示为 gap / error，不能显示为 healthy。

## Boundary

GH-764 不实现 trading button、order form、live command surface、broker write、ExecutionClient call、production endpoint 连接、production secret 读取、真实订单提交或 production cutover 授权。

`productionTradingEnabledByDefault=false`

`productionSecretAutoReadEnabled=false`

`productionEndpointConnected=false`

`productionOrderSubmitted=false`

`productionCutoverAuthorized=false`
