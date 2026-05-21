# MTPRO Product Interaction Model v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 Human 提供的 `@003 / PRD` 草案落仓）

## 1. 文档定位

本文档是 MTPRO macOS 工作台的 Product Interaction Model，不是 UI design、不是视觉稿、不是组件规范、不是 SwiftUI 实现稿。

它用于指导后续 `@004 / DSG` 输出 `Workbench Screen Layout v1`，重点定义用户在每个页面能看什么、判断什么、点什么、不能点什么，以及页面之间如何通过 evidence navigation 串联。

本文档不定义最终视觉风格，不定义 macOS 组件细节，不写 SwiftUI，不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不授权任何 Future Live trading execution scope。

依据：

- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md`
- `docs/product/product-surface-map.md`
- `BLUEPRINT.md`
- `docs/architecture.md`
- Figma canonical `15:2`

## 2. 全局交互原则

1. Evidence navigation 优先，不以交易按钮为中心。
   工作台主交互是查看证据、进入详情、沿 evidence trail 回溯，而不是提交交易动作。

2. 中文优先，英文只作技术别名。
   页面标题、状态、提示、禁止动作、空状态、错误状态默认中文；英文保留在括号或技术别名中，例如“实盘监控台 / Live Monitoring”。

3. 页面只消费稳定 App 层边界。
   页面只能消费 ViewModel / Read Model / Command Model，不读取 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object。

4. Current completed 页面可以进入证据详情。
   Overview、Market Replay、Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness 允许通过证据卡片、状态行、artifact link、timeline link 进入详情或相关页面。

5. Completed read-model-only evidence surfaces 只能查看状态和证据。
   Live Monitoring 已完成，但只允许展示 health / connection / stream / latency / error / degraded evidence，不提供 reconnect、start live、stop live 或 broker stream 操作。

6. Future Gated 只能解释 gate / placeholder / blocked reason。
   Future Live Execution、Future Live Risk、Future Incident Replay / Stop Controls 只能解释缺失 gate、当前禁止能力和后续规划条件，不能提供动作入口，不能被理解为下一步自动执行授权。

## 3. 状态语言

| 状态 | 产品含义 | 允许交互 |
| --- | --- | --- |
| `empty` | 当前没有可展示证据或还没有生成 artifact | 查看说明、跳转到上游页面 |
| `healthy` | 证据链可用，状态正常 | 查看详情、进入下游页面、进入 Events / Audit |
| `stale` | 数据、projection、report 或 monitoring evidence 已过期 | 查看 stale reason、跳转 Market Replay / Events / Audit |
| `blocked` | 能力被 gate、risk blocker 或 hard boundary 阻断 | 查看 blocked reason、source anchor、相关文档或 Events / Audit |
| `degraded` | 仍可观察但存在局部异常、延迟或不一致风险 | 查看 degraded scope、相关 evidence、进入追溯 |
| `error` | evidence 生成或读取失败 | 查看 error evidence、进入 Events / Audit；不得提供绕过按钮 |

## 4. 页面级交互模型

| 页面 | 用户要判断什么 | 主要 evidence | 允许点击 | 点击后去哪里 | 状态 | 禁止动作 |
| --- | --- | --- | --- | --- | --- | --- |
| Overview | 今天是否继续研究、回测、观察 Paper，还是先处理异常 | latest report、replay freshness、Paper session、Risk blocker、Live gates、Live monitoring summary | 状态卡、latest report、blocked gate、monitoring summary、timeline preview | Report、Market Replay、Paper、Risk、Live Readiness、Live Monitoring、Events / Audit | empty / healthy / stale / blocked / degraded / error | 交易按钮、live command、order form、DB / runtime 直连 |
| Market Replay | 数据批次、retention、freshness、replay consistency 是否可信 | batch、replay run、freshness、retention、fixture parity、projection consistency | batch row、freshness badge、replay evidence、consistency evidence | Research、Backtest、Report、Events / Audit | empty / healthy / stale / degraded / error | 真实历史下载控制、production scheduler、signed endpoint |
| Research | 策略输入、配置、signal evidence 和 research run 是否可信 | strategy input、signal evidence、research run、market source link | signal row、input snapshot、run evidence | Backtest、Report、Events / Audit | empty / healthy / stale / degraded / error | 策略市场、黑盒策略执行、真实交易动作 |
| Backtest | parity、cost、risk、输入快照和 replay evidence 是否满足进入报告或 Paper | run summary、input snapshot、parity、cost assumption、risk evidence | run card、parity evidence、cost evidence、risk blocker link | Report、Paper、Risk、Events / Audit | empty / healthy / stale / blocked / degraded / error | 实盘授权、order submit、broker fill、真实账户引用 |
| Report | Research / Backtest / Paper / Risk / Portfolio evidence 是否形成可追溯结论 | report artifact、evidence summary、parity、cost、risk、portfolio、monitoring summary | artifact、evidence section、source link、timeline link | Backtest、Paper、Portfolio、Risk、Live Monitoring、Events / Audit | empty / healthy / stale / blocked / degraded / error | 把报告作为交易授权、live order button |
| Paper | paper-only session、intent、simulated fill、portfolio projection 是否一致 | session lifecycle、proposal、risk decision、paper order intent、simulated fill、portfolio projection | session row、proposal、risk decision、simulated fill、`start / pause / close / reset` | Portfolio、Risk、Report、Events / Audit | empty / healthy / blocked / degraded / error | submit / cancel / replace、order form、broker action、real order lifecycle |
| Portfolio | paper exposure 和 portfolio projection 是否可解释 | paper exposure、portfolio update、gross exposure、symbols | exposure row、portfolio update、source report link | Paper、Risk、Report、Events / Audit | empty / healthy / stale / degraded / error | real account balance、broker position、margin / leverage control |
| Risk | blocker、rejection reason、paper-only risk evidence 和 future live gate 是否清楚 | risk blocker、rejected paper order id、blocker reason、future live gate | blocker row、rejection reason、source evidence | Paper、Portfolio、Report、Live Readiness、Events / Audit | empty / healthy / blocked / degraded / error | live risk command、position command、绕过 blocker |
| Events / Audit | 异常来自数据、策略、回测、Paper、风险、投影还是 Live evidence | event timeline、stream、sequence、replay、projection freshness、evidence links | timeline row、section filter、evidence link、source anchor | 原页面详情、Report、Live Readiness、Live Monitoring | empty / healthy / stale / blocked / degraded / error | 完整查询语言、schema 浏览器、事件编辑、命令执行 |
| Live Readiness | 为什么还不能实盘，哪些 capability 被 gate 阻断 | API key、signed endpoint、account endpoint、listenKey、broker adapter、real order lifecycle blocked evidence | blocked gate、source anchor、related contract link、timeline link | Live Monitoring、Future Gated、Events / Audit、Product / Architecture docs | empty / blocked / degraded / error | API key 输入、secret storage、signed request、broker connect、live command |
| Live Monitoring | 只读监控证据是否说明 health / connection / stream / latency / error 状态 | runtime health、connection、market stream、order stream evidence、latency、error、degraded state | evidence card、connection row、stream row、latency bucket、error row | Events / Audit、Live Readiness、Report | empty / healthy / stale / blocked / degraded / error | reconnect、start live、stop live、broker stream 操作、真实 order stream runtime |
| Future Gated | 后续 Live capability 缺哪些 gate，为什么不能执行 | gate list、blocked reason、planning placeholder、source doc | gate explanation、Product / Architecture doc link | Live Readiness、Live Monitoring、相关 docs | empty / blocked | 执行入口、创建 Linear、推进 Todo、授权开发 |
| Future Live Execution | 真实订单执行控制为什么仍是未来门禁 | submit / cancel / replace gate、adapter capability、reconciliation gate | gate explanation、architecture link | Future Gated、Live Readiness、docs | blocked | submit / cancel / replace、order form、real order state machine |
| Future Live Risk | 实盘风控为什么仍是未来门禁 | live pre-trade risk、position、loss、frequency、circuit breaker gates | gate explanation、risk boundary link | Future Gated、Risk、docs | blocked | live risk command、position management、禁交易开关 |
| Future Incident Replay / Stop Controls | 事故回放、停机、恢复为什么仍是未来门禁 | audit trail、incident replay、shutdown / restore policy gates | gate explanation、audit boundary link | Future Gated、Events / Audit、docs | blocked | emergency stop、restore live、incident command、自动恢复 |

## 5. 六条核心动线的交互规则

| 动线 | 起点页面 | 判断目标 | 关键点击路径 | 必须保留的 evidence trail | 结束状态 / 下一步 |
| --- | --- | --- | --- | --- | --- |
| 今日状态检查 | Overview | 今天是否继续研究、回测、Paper 或先处理异常 | Overview 状态卡 -> Market Replay freshness -> Risk blocker -> Live Readiness -> Live Monitoring | latest report id、batch id、risk blocker id、live gate id、monitoring evidence id | healthy 时继续 Research / Backtest；stale / degraded / error 时进入 Events / Audit |
| 策略研究到回测 | Market Replay | 数据和 signal 是否足够可信 | Market Replay batch -> Research signal -> Backtest run | batch / replay run id、signal id、strategy config snapshot、backtest run id | healthy 时生成或查看 Report；stale 时回到 Market Replay |
| 回测到报告 | Backtest | 回测结论是否可复现、可沉淀 | Backtest run -> parity / cost / risk evidence -> Report artifact -> Events / Audit | backtest run id、parity id、cost assumption id、risk evidence id、artifact id | artifact healthy 时进入 Paper；blocked 时查看 Risk |
| Paper session 观察 | Report 或 Paper | Paper lifecycle 和 projection 是否一致 | Report paper evidence -> Paper session -> Portfolio -> Risk -> Events / Audit | session id、proposal id、paper order intent id、simulated fill id、portfolio update id | healthy 时继续观察；blocked / degraded 时进入 Risk 或 Events / Audit |
| 异常追溯 | Overview | 异常来源在哪里 | Overview degraded / error -> Events / Audit timeline -> source page detail | event sequence、stream、source evidence id、projection freshness id | 找到 source 后返回原页面处理；不能提供绕过动作 |
| Live readiness / monitoring 判断 | Live Readiness | 为什么还不能实盘，当前能观察什么 | Live Readiness gate -> Live Monitoring evidence -> Future Gated placeholder -> Events / Audit | blocked gate id、monitoring evidence id、source anchor、future gate link | 结论只能是 blocked / read-model-only / future gated；不得进入执行 |

## 6. 控制面边界

| 控制类型 | 允许内容 | 产品表现 | 禁止内容 |
| --- | --- | --- | --- |
| Read-only evidence interaction | 查看状态、展开详情、进入 timeline、跳转 source evidence | link、row selection、detail inspector、filter snapshot | 修改事实、重建 projection、直接查 DB、触发 adapter |
| Local paper session-level control | `start` / `pause` / `close` / `reset` | 仅 Paper session 本地控制壳，写入 paper-only event boundary | submit / cancel / replace、order-level command、broker action |
| Blocked / unavailable future action | 展示 blocked reason、gate、source doc | disabled / placeholder / explanation | 隐式启用、灰按钮诱导、自动创建 issue |
| Forbidden live trading action | 无允许动作 | 只能展示“当前禁止 / Future gated” | signed endpoint、account endpoint、listenKey、live command、交易按钮、real order state machine、real account balance、real broker position |

Paper 页面特别边界：只允许 session-level local controls：`start`、`pause`、`close`、`reset`。禁止出现 `submit` / `cancel` / `replace`、order form、broker action、signed endpoint、account endpoint / listenKey、reconnect / start live / stop live、live command、trading button、real order state machine、real account balance / real broker position。

## 7. Live Monitoring 交互边界

Live Monitoring 已完成，但只是 read-model-only evidence surface。

允许：

- 展示 runtime health、connection、market stream、order stream evidence、latency、error、degraded state。
- 展示 blocked / simulated / future evidence。
- 跳转 Events / Audit 查看 evidence trail。
- 跳转 Live Readiness 查看 gate / blocked reason。
- 在 Report / Overview 中被聚合展示 monitoring summary。

禁止：

- reconnect。
- start live / stop live。
- broker stream 操作。
- private WebSocket / listenKey 操作。
- signed endpoint / account endpoint。
- live command。
- 交易按钮。
- order-level command。
- 把 order stream / order events 表达成真实 order stream runtime。

## 8. Future Gated 交互边界

Future Live Execution、Future Live Risk、Future Incident Replay / Stop Controls 都是 planning / boundary placeholder。

允许：

- 解释缺失 gate。
- 展示 required gate、blocked reason、source anchor。
- 链接到相关 Product / Architecture 文档。
- 回到 Live Readiness / Live Monitoring / Events / Audit 查看当前证据。

禁止：

- 提供执行入口。
- 提供交易动作。
- 提供 live control。
- 自动创建 Linear Project / Issue。
- 自动推进 Todo。
- 被理解为下一步自动执行授权。

## 9. `@004 / DSG` 后续输入摘要

- `Workbench Screen Layout v1` 应从 Figma canonical `15:2` 的页面清单和三态分区出发。
- 每页至少需要：判断目标区、主要 evidence 区、下一步导航区、状态区、禁止动作区、ViewModel / Read Model 边界说明。
- 中文为主语言；英文只作为技术别名。
- 布局要突出 evidence navigation、timeline、detail inspector、source link，而不是交易控制。
- Live Monitoring 必须视觉上区别于 Future Live Execution / Risk / Incident Replay：前者已完成但只读，后者是未来门禁占位。

## 10. `@005 / ARC` 需要审查的重点

- 页面是否只消费 ViewModel / Read Model / Command Model。
- 是否有任何 UI 暗示 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object 直连。
- Paper control 是否严格限定为 `start / pause / close / reset`。
- Live Monitoring 是否保持 read-model-only，不含 reconnect / start live / stop live。
- Future Gated 是否只表达 gate / placeholder / blocked reason，不授权 Linear execution。
- Evidence trail 是否能沿 `Input source -> Event fact -> Event Log -> Replay -> Projection -> Read Model -> ViewModel -> Workbench` 回溯。

## 11. 后续落仓和维护边界

本文档已经作为产品层交互模型落仓。后续若 `@004 / DSG` 产出 `Workbench Screen Layout v1`，必须把本文档作为输入，而不是直接从 Figma 用户动线图推导最终 UI。

维护边界：

- 可作为 `docs/product/product-surface-map.md`、`BLUEPRINT.md` 和后续 `docs/design/` 的引用源。
- 不替代 `BLUEPRINT.md` 的总蓝图地位。
- 不替代 `docs/architecture.md` 的工程模块地图。
- 不授权 Linear Project / Issue、Todo 推进、Symphony 启动或业务代码实现。
