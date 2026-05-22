# MTPRO Product Surface Split v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 `@003 / PRD` 草案和 `@005 / ARC` 审查结论落仓）

## 1. 文档定位

本文是 `MTPRO Product Surface Split v1`，用于明确 `MTPRO Workbench` 与未来 `MTPRO Live PRO Console` 是两个不同产品面。

本文不是 UI 设计稿、不是组件规范、不是 SwiftUI 实现稿、不是 Linear execution 授权。本文不创建 Project / Issue，不推进 `Todo`，不启动 Symphony，不运行 Graphify，不授权 Live trading，不授权任何实盘执行能力。

`@005 / ARC` 审查结论：通过。P0 / P1 无；P2 为措辞小修，已吸收：

- 将 `Shared Evidence Layer` 收紧为 `Shared Evidence Semantics / Shared Evidence Contract`，避免误读成新的工程层或共享 runtime / persistence 层。
- 在 `Live PRO Console` 定义段前置说明：必须经过 Human decision、独立 Project Definition、signed / account / broker / risk / ops gates 后，才允许进入 IA / UI / implementation。

## 2. 两个产品面定义

### MTPRO Workbench

`MTPRO Workbench` 是当前产品面：本地研究 / 回测 / 报告 / Paper / 风险 / 组合 / 事件 / Live readiness / read-model-only monitoring 工作台。

Workbench 当前范围包括：

- Research。
- Backtest。
- Report。
- Paper。
- Portfolio。
- Risk。
- Events / Audit。
- Live Readiness。
- read-model-only Live Monitoring。

核心任务是帮助个人专业交易者和独立策略研究者每天判断：

- 今天数据、报告、Paper、风险、Live gate 状态是否可信。
- 哪些研究结果可以继续分析，哪些需要重新回放或重新回测。
- Paper session 是否只是本地模拟，状态是否健康。
- 异常从哪个事件、报告、read model 或 gate 产生。
- 为什么当前仍不能实盘。

`MTPRO Workbench` 不是实盘交易终端，不提供真实订单、真实账户、broker action、signed endpoint、Live command 或 emergency stop。

### MTPRO Live PRO Console

`MTPRO Live PRO Console` 是未来产品面：实盘执行 / 实盘风控 / 停机 / 事故处理操作台。

它必须经过 Human decision、独立 Project Definition、signed endpoint / account endpoint / broker adapter / live risk / operations gates 后，才允许进入 IA / UI / implementation。当前它仍是 `Future Gated`，不属于当前 execution scope。任何 Live PRO Console 的 IA、交互、UI 或实现，都必须在 Human 明确授权 future live Project 后单独规划。

未来核心任务可能包括：

- 真实账户状态。
- 真实订单控制。
- execution report。
- broker fill。
- reconciliation。
- live risk。
- no-trade state。
- circuit breaker。
- emergency stop。
- incident replay。

### Shared Evidence Semantics / Shared Evidence Contract

两个产品面可以共享证据语义，但不能共享执行能力。

可以共享的是 evidence semantics、read model contract、report artifact、audit route、source anchor、validation evidence、readiness gate 和 monitoring summary。

不能共享的是 command surface、direct Event Log write access、live runtime、broker adapter、signed API、account stream、listenKey、OMS、real order state machine、real broker position 或 emergency stop command。

## 3. 用户与任务对比

| 维度 | MTPRO Workbench | MTPRO Live PRO Console |
| --- | --- | --- |
| 产品状态 | 当前产品面 | 未来产品面 |
| 用户目标 | 研究、回测、报告、Paper 观察、证据追溯、判断能否实盘 | 实盘执行、实盘风控、事故处置、停机控制 |
| 每天先看什么 | 数据新鲜度、最新报告、Paper 状态、风险摘要、Live readiness / monitoring summary | 真实账户、真实订单、broker fill、execution report、live risk、incident state |
| 允许操作 | 证据 drill-down、本地 Paper session-level control、报告查看、事件追溯 | 未来才可能定义真实 submit / cancel / replace、emergency stop 等 |
| 当前 Live 表达 | blocked、read-model-only、future gated | 不在当前 scope |
| 共同证据 | Event Log 派生证据、Report、Audit、Read Model、Gate Evidence | 可消费同类证据语义，但必须单独建模 |
| 不可共享 | broker action、signed endpoint、account endpoint、listenKey、OMS、real account balance、broker position、Live command | 同左，直到 Future Live Project 单独授权 |

## 4. Surface Boundary Matrix

| 能力面 | 归属 | 当前状态 | Workbench 表达 | Live PRO Console 表达 |
| --- | --- | --- | --- | --- |
| Research | Workbench | 当前 | 策略假设、参数、研究摘要、证据入口 | 不属于实盘操作台 |
| Backtest | Workbench | 当前 | 回测运行、可信度判断、报告入口 | 未来可作为实盘前证据参考 |
| Report | Workbench / Shared Evidence Contract | 当前 | 用户可读报告、指标、风险和证据摘要 | 未来可作为 audit / reconciliation 参考 |
| Paper | Workbench | 当前 Paper-only | 本地模拟 session 状态和 `start` / `pause` / `close` / `reset` | 不能升级为真实订单控制 |
| Portfolio | Workbench / Shared Evidence Contract | 当前以本地和 Paper 投影为主 | 本地组合、模拟持仓、风险暴露 | 真实账户组合属于未来 Live PRO |
| Risk | Workbench / Future Gated | 当前以研究、回测、Paper 风险为主 | 风险摘要、blocked reason、gate 解释 | Live Risk Control 未来单独产品面 |
| Events / Audit | Shared Evidence Contract | 当前 | 异常追溯、事件时间线、证据链 | 未来可成为事故审计输入 |
| Live Readiness | Workbench / Shared Evidence Contract | 当前 blocked / read-only | 解释为什么不能实盘 | 未来作为 Live PRO gate 输入 |
| Live Monitoring | Workbench / Shared Evidence Contract | 当前 read-model-only | health / connection / stream / latency / error / degraded summary | 不能被理解为 live runtime 操作台 |
| Live Execution Control | Future Gated / Live PRO Console | 当前 contract + blocked evidence only | 只显示 blocked evidence 和缺失 gate | 未来单独定义真实执行控制 |
| Live Risk Control | Future Gated / Live PRO Console | 当前未实现真实能力 | 只解释 future risk gate | 未来单独定义 no-trade / circuit breaker 等 |
| Incident Replay / Stop Controls | Future Gated / Live PRO Console | 当前未执行 | 只解释 future incident / stop gate | 未来单独定义 incident replay / emergency stop |

## 5. 当前 `85:*` 定位

Figma `85:2` 的 section 名称是 `MTPRO Workbench User-Facing Dashboard High-Fidelity v2`。其页面包含总览、行情回放、策略研究、回测、报告、Paper 模拟执行、组合、风险、事件与审计、实盘准备度、实盘监控台、未来门禁区。

因此 `85:*` 定义为 Workbench 用户面板，不是 `MTPRO Live PRO Console`。

`85:*` 可以显示 Live readiness / monitoring summary，但只能作为 blocked、read-model-only、future gated evidence。它不能显示实盘操作控制，不能成为实盘施工入口，不能成为交易入口。Future Gated 页面只能解释缺失 gate、相关文档和 blocked reason。

## 6. 后续设计路线

`Workbench User-Facing Dashboard High-Fidelity v2`：继续完善当前 Workbench，使其更像每天使用的研究 / 回测 / Paper / 证据工作台，而不是交易终端。

`Live PRO Console Product Model v1`：未来单独规划，当前不执行。它需要独立定义用户、任务、状态、风险控制、事故处理和权限边界。

`Live PRO Console IA / Interaction / UI`：只能在 Human 明确授权 future live Project 后进入。设计上必须另开 Figma section / project，并使用独立 IA，不复用 Workbench 页面当实盘控制台。

## 7. 禁止动作

- 不把 Workbench 画成 trading terminal。
- 不把 Live PRO Console 写成当前 scope。
- 不新增 submit / cancel / replace。
- 不新增 order form。
- 不新增 broker action。
- 不新增 API key、signed endpoint、account endpoint / listenKey。
- 不新增 `LiveExecutionAdapter`、OMS、real order state machine。
- 不显示 real account balance、broker position。
- 不新增 live command、reconnect / start live / stop live。
- 不新增 emergency stop 作为当前可执行动作。

## 8. 给 @004 / DSG 的输入

当前 `85:*` 应继续按 Workbench dashboard 优化：首屏回答“今天我该看什么 / 做什么判断”，把 source / trace / timeline 下沉到 inspector、detail、Events / Audit。

Live Readiness 和 Live Monitoring 可以作为摘要与证据入口出现，但必须保持 blocked / read-model-only / future gated 语义。若未来要画 `MTPRO Live PRO Console`，必须另开 Figma section / project，并使用独立 IA，不复用 Workbench 页面作为实盘控制台。

## 9. 给 @005 / ARC 的审查重点

后续审查应重点确认：

- Workbench 与 Future Live PRO Console 是否清楚分离。
- Paper / evidence UI 是否被错误升级为实盘控制。
- read-model-only monitoring 是否被误解为 live runtime。
- Future Live capability 是否被写成当前 execution scope。
- UI 是否仍只消费 ViewModel / Read Model / Command Model，不读取 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object。
- 是否仍然禁止 signed endpoint、account endpoint、listenKey、`LiveExecutionAdapter`、OMS 和真实订单状态机。

## 10. 非授权边界

本文档不授权：

- 修改 Figma。
- 创建 Linear Project / Issue。
- 修改 Linear status。
- 推进 `Todo`。
- 启动 `@002 / PAR`。
- 启动 Symphony / symphony-issue。
- 运行 Graphify update。
- 编写业务代码。
- SwiftUI 实现。
- Future Live trading、Live PRO Console 或实盘操作台进入当前 execution scope。
