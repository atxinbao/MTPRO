# Live Monitoring Console Contract

日期：2026-05-21

执行者：Codex

本文档定义 `MTPRO Live Monitoring Console v1` 的 information architecture、术语、状态分类和 read-model-only 边界。它只为后续 runtime health、connection、market stream、order stream、latency、error、degraded state 和 operations evidence 提供统一合同，不实现 live runtime、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、真实订单状态机或任何 live command。

本文档不授权创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `symphony-issue`，不读取 secret，不连接 broker / exchange，不执行真实交易动作。

## MTP-68 Live monitoring console information architecture

`MTP-68-LIVE-MONITORING-CONSOLE-IA`

Live monitoring console 在本 Project 中首先是 read-model-only information architecture。它描述后续界面和报告应如何组织监控 evidence，而不是当前可运行的实盘监控 runtime。

| Console area | 中文目的 | 允许输入 | 允许输出 | 当前禁止 |
| --- | --- | --- | --- | --- |
| Overview / 总览 | 汇总 live monitoring readiness、blocked gates 和最近 operations evidence | App 层 Read Model / ViewModel | 状态摘要、source anchor、只读边界说明 | live command、交易按钮、adapter call |
| Runtime Health / 运行健康 | 展示 future live runtime 是否 nominal / degraded / error / stale | 后续 MTP-69 read model | health status、updatedAt、evidence id | 启动 runtime、读取 runtime actor |
| Connection / 连接 | 展示 public / future private connection 的只读状态 | 后续 connection status read model | disconnected / connected / stale / error evidence | account endpoint、listenKey、private WebSocket |
| Market Stream / 行情流 | 展示 public market stream 的只读健康和延迟 evidence | public read-only market stream evidence | stream status、last event、latency bucket | signed endpoint、生产订阅控制 |
| Order Stream Evidence / 订单流证据 | 展示 blocked / simulated / future order-stream evidence | `LiveReadiness`、paper evidence、future order stream gate | blocked / simulated / future-only evidence | real order state machine、execution report、broker fill |
| Latency / 延迟 | 展示 read model 中已计算的延迟 bucket 和 freshness | 后续 latency evidence read model | nominal / stale / degraded / error bucket | runtime profiler、生产 telemetry agent |
| Error / Degraded State / 错误和降级 | 展示已记录 error / degraded evidence 的只读摘要 | 后续 error evidence read model | error code、scope、source anchor、recoveredAt | incident command、自动恢复动作 |
| Operations Evidence / 运营证据 | 展示 validation、handoff、audit input 和 readiness 证据 | validation docs、Stage Audit input、event timeline links | evidence chain、known boundaries、handoff status | production operations、deployment action |

## MTP-68 live monitoring terminology

`MTP-68-LIVE-MONITORING-TERMS`

以下术语只定义后续 read model 的语言，不代表当前已有实盘连接或可执行能力：

| Term | 中文定义 | 当前状态 | 避免混用 |
| --- | --- | --- | --- |
| `live runtime health` | 后续实盘 runtime 的健康状态读模型，例如 nominal、degraded、error、stale。 | Future / read-model-only | 不等于当前已启动 live runtime 或 actor。 |
| `connection status` | 后续连接状态的只读证据，可覆盖 public market connection 和 future private connection gate。 | Future / read-model-only | 不等于 account endpoint、listenKey 或 broker session。 |
| `market stream status` | Binance public read-only market stream 的可观察状态、freshness 和 latency evidence。 | Future / public-read-only evidence | 不等于 signed endpoint 或交易执行通道。 |
| `order stream evidence` | 订单流相关的 blocked / simulated / future evidence，用于说明真实订单流为什么尚未可用或未来需要哪些 gate。 | Blocked / simulated / future-only | 不等于 real order state machine、execution report、broker fill 或 OMS。 |
| `latency evidence` | 从 read model 派生的延迟 bucket、last update 和 freshness evidence。 | Future / read-model-only | 不等于生产 telemetry agent 或 runtime profiler。 |
| `error evidence` | 后续 Event Timeline / Report 可展示的错误事实摘要。 | Future / read-model-only | 不等于自动恢复命令或 incident handler。 |
| `degraded state` | 系统仍可观察但健康、连接、stream 或 latency evidence 显示降级的状态。 | Future / read-model-only | 不等于允许交易、risk bypass 或执行降级策略。 |
| `operations evidence` | validation、handoff、audit input、known boundary 和 readiness 证据链。 | Current docs evidence / future read model input | 不等于 production operations command、部署或远程运维。 |

## MTP-68 status taxonomy

`MTP-68-LIVE-MONITORING-STATUS-TAXONOMY`

MTP-68 只命名状态分类，后续 issue 才能把这些分类落成具体 Read Model / ViewModel 字段。

| Status | 中文含义 | 允许展示 | 禁止解释 |
| --- | --- | --- | --- |
| `blocked` | 必要 gate 未满足，能力当前被阻断。 | blocked gate、source anchor、reason | partial live readiness、可执行 fallback |
| `simulated` | 仅来自 paper-only / deterministic fixture 的模拟证据。 | simulated source、paper evidence id | broker fill、真实订单状态 |
| `futureOnly` | 术语已定义，但当前 Project 不实现。 | future gate、required evidence | 当前可调用能力 |
| `unknown` | 没有足够 read model evidence 判断状态。 | unknown summary、missing evidence | silent success、默认 nominal |
| `nominal` | 后续 read model 可表示观察值在预期范围内。 | status label、updatedAt、source anchor | 交易授权、live command |
| `stale` | read model evidence 过期或 freshness 不足。 | stale duration、last update | 自动重连、真实状态修复 |
| `degraded` | health / connection / stream / latency / error evidence 显示降级。 | degraded scope、reason、source anchor | risk bypass、继续执行真实订单 |
| `error` | read model 中存在错误事实或失败证据。 | error code、message、scope | incident command、自动恢复动作 |
| `recovered` | 后续 evidence 显示从 error / degraded 恢复。 | recoveredAt、source anchor | 清除审计证据、跳过 incident review |

## MTP-68 read-model-only boundary

`MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`

Dashboard、Report 和 Event Timeline 在 MTP-68 之后只能展示 read model / ViewModel：

- Dashboard 只能展示 status summary、section counts、source anchors 和 known boundaries。
- Report 只能汇总 read model evidence、validation anchor 和 audit input evidence。
- Event Timeline 只能展示 evidence item、source sequence、source anchor 和 read-only link summary。
- App / Dashboard 不得读取 adapter request、adapter instance、Runtime object、actor、workflow object、SQLite / DuckDB schema、SQL、ORM、table、column 或 persistence implementation。
- App / Dashboard 不得读取 API key、secret、account payload、listenKey、broker state、execution venue connection 或 real account state。
- App / Dashboard 不得提供 live command、order-level command、risk control command、position management command、submit / cancel / replace、交易按钮、表单或自动恢复动作。

## MTP-68 order stream evidence boundary

`MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`

订单流 / 订单事件流在 MTP-68 中只能表达三类 evidence：

| Evidence type | 允许含义 | 禁止含义 |
| --- | --- | --- |
| `blocked order stream evidence` | 真实订单流仍被 credential、adapter、real order lifecycle 和 risk / operations gate 阻断。 | 当前存在 private order stream、listenKey 或 broker stream。 |
| `simulated order stream evidence` | paper order / simulated fill / paper portfolio 等本地模拟证据可被只读展示。 | broker fill、execution report、真实账户更新。 |
| `future order stream evidence` | 后续 Project Definition 需要定义 order stream contract、reconciliation 和 incident/audit evidence。 | 当前实现 real order state machine、OMS 或 submit / cancel / replace。 |

## MTP-68 validation anchors

`MTP-68-LIVE-MONITORING-VALIDATION-ANCHORS`

MTP-68 只定义 validation anchor 名称和入口，不实际修改 `checks/automation-readiness.sh`。automation readiness 的机械收口保留给 MTP-74。

候选 Matrix ID：

- `TVM-LIVE-MONITORING-CONSOLE`

候选 contract anchors：

- `MTP-68-LIVE-MONITORING-CONSOLE-IA`
- `MTP-68-LIVE-MONITORING-TERMS`
- `MTP-68-LIVE-MONITORING-STATUS-TAXONOMY`
- `MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`
- `MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`
- `MTP-68-LIVE-MONITORING-VALIDATION-ANCHORS`
- `MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT`

MTP-68 验证入口：

- `docs/contracts/live-monitoring-console-contract.md` 必须包含以上 anchors。
- `docs/product/product-surface-map.md` 必须能定位 Live monitoring console information architecture。
- `docs/contracts/frontend-view-model-contract.md` 必须说明 Dashboard / Report / Event Timeline 的 read-model-only 边界。
- `docs/domain/context.md` 必须说明 live monitoring 术语和 order stream evidence 语义。
- `docs/validation/validation-plan.md` 和 `docs/validation/trading-validation-matrix.md` 必须列出 MTP-68 候选 validation anchor。
- `checks/automation-readiness.sh` 在本 issue 中保持不改；不得提前机械收口 MTP-68 anchors。
- `bash checks/run.sh` 必须通过。

`MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT`

本 issue 只提供候选 anchor 和文档入口，不把这些 anchor 加入 `checks/automation-readiness.sh`。后续 MTP-74 收口 validation matrix、automation readiness 和 stage audit input material 时，才允许把 MTP-68 至 MTP-73 的 anchors 统一机械化。
