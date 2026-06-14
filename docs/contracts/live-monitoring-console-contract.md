# Live Monitoring Console Contract

日期：2026-05-21

执行者：Codex

本文档定义 `MTPRO Live Monitoring Console v1` 的 information architecture、术语、状态分类和 read-model-only 边界。它只为 runtime health、connection、market stream、order stream、latency、error、degraded state 和 operations evidence 提供统一合同，不实现 live runtime、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、真实订单状态机或 live command。

本文档不授权创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `symphony-issue`，不读取 secret，不连接 broker / exchange，不执行真实交易动作。

## Shared Boundary

| Area | 允许展示 | 当前禁止 |
| --- | --- | --- |
| Overview | readiness、blocked gates、operations evidence | live command、交易按钮、adapter call |
| Runtime Health | health status、updatedAt、evidence id | 启动 runtime、读取 runtime actor |
| Connection | disconnected / connected / stale / error evidence | account endpoint、listenKey、private WebSocket |
| Market Stream | public read-only stream status / latency | signed endpoint、生产订阅控制 |
| Order Stream Evidence | blocked / simulated / future-only evidence | real order state machine、execution report、broker fill |
| Latency / Error / Degraded | read-model-derived evidence | production telemetry agent、incident command、自动恢复 |
| Operations Evidence | validation、handoff、audit input | production operations / deployment action |

## Status Taxonomy

`blocked`、`simulated`、`futureOnly`、`unknown`、`nominal`、`stale`、`degraded`、`error`、`recovered` 都只是 read model label，不代表 trading authorization。

## Anchor Ledger

| Anchor | 压缩说明 |
| --- | --- |
| MTP-68-LIVE-MONITORING-CONSOLE-IA | Live monitoring console information architecture |
| MTP-68-LIVE-MONITORING-READ-MODEL-ONLY | Dashboard / Report / Event Timeline 只展示 read model / ViewModel |
| MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE | order stream evidence 不等于真实订单状态 |
| MTP-69-LIVE-RUNTIME-HEALTH-READ-MODEL | `LiveRuntimeHealthReadModel` 只表达 future health evidence |
| MTP-69-CONNECTION-STATUS-READ-MODEL | `LiveConnectionStatusReadModel` 只表达 connection evidence |
| MTP-69-NO-LIVE-CONNECTION-OR-COMMAND | 不建立 live connection，不提供 command |
| MTP-70-MARKET-STREAM-ORDER-STREAM-READ-MODEL | market / order stream 都是 read-model-only |
| MTP-70-MARKET-STREAM-PUBLIC-READ-ONLY-EVIDENCE | market stream 只允许 public read-only evidence |
| MTP-70-ORDER-STREAM-BLOCKED-SIMULATED-FUTURE-EVIDENCE | order stream 只能 blocked / simulated / future evidence |
| MTP-70-NO-LISTENKEY-ACCOUNT-ENDPOINT-REAL-ORDER-STATE | 不创建 listenKey，不调用 account endpoint，不表达 real order state |
| MTP-71-LATENCY-ERROR-DEGRADED-READ-MODEL | latency / error / degraded state 都是 read model |
| MTP-71-LATENCY-EVIDENCE-READ-MODEL | latency evidence 不等于 production telemetry |
| MTP-71-ERROR-EVIDENCE-READ-MODEL | error evidence 不等于 incident command |
| MTP-71-DEGRADED-STATE-READ-MODEL | degraded state 不等于允许交易 |
| MTP-71-NO-PRODUCTION-TELEMETRY-OR-COMMAND | 不接 production telemetry 或 command |
| MTP-72-DASHBOARD-REPORT-LIVE-MONITORING-EVIDENCE | Dashboard / Report 展示 monitoring evidence |
| MTP-72-LIVE-MONITORING-READ-MODEL-VIEWMODEL | monitoring evidence 通过 read model / ViewModel |
| MTP-72-NO-LIVE-COMMAND-OR-BUTTON | 无 live command 或 button |
| MTP-72-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE | 不暴露 schema、adapter、runtime object |
| MTP-73-EVENT-TIMELINE-LIVE-MONITORING-EVIDENCE-PREVIEW | Event Timeline 预览 monitoring evidence |
| MTP-73-LIVE-MONITORING-TIMELINE-ITEMS | timeline item 只包含 evidence metadata |
| MTP-73-NO-LIVE-AUDIT-INCIDENT-REPLAY-STOP-CONTROL | 不授权 live audit、incident replay 或 stop control |
| MTP-74-LIVE-MONITORING-STAGE-CLOSEOUT | stage closeout 只收 validation input |
| MTP-74-STAGE-AUDIT-INPUT-MATERIAL | Stage Audit input material |
| MTP-74-NO-FINAL-STAGE-CODE-AUDIT | 不生成 final Stage Code Audit |

## Validation Contract

- Core read model 必须拒绝 live command、reconnect command、start / stop live command。
- 不启动 runtime、不轮询 production health、不建立网络连接、不读取 secret / account payload。
- Dashboard / Report / Event Timeline 不得读取 adapter instance、Runtime actor、SQLite / DuckDB schema、SQL、ORM、broker state 或 real account state。
