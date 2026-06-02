# MTPRO Workbench Screen Layout v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 `@004 / DSG` Figma 输出和 `@005 / ARC` 复审结论落仓）

## 1. 文档定位

本文档是 `MTPRO Workbench Screen Layout v1` 的 Screen Layout Design Reference / 屏幕布局设计依据。

它承接产品层文档：

- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md`
- `docs/product/mtpro-product-interaction-model-v1.md`
- `docs/product/product-surface-map.md`

它用于记录 macOS 工作台 screen layout、页面区域、信息优先级、状态表达和禁止动作。它不是最终 UI / UX 高保真视觉稿，不是组件规范，不是 SwiftUI 实现稿，不创建 Linear Project / Issue，不修改 Linear status，不推进 `Todo`，不启动 `@002 / PAR`，不启动 Symphony，不运行 Graphify update，不授权任何 Future Live trading execution scope。

Figma canonical：

- File URL：`https://www.figma.com/design/0MkTyZXHmfBaZ2K9fqddCm/MTPRO-Professional-Trading-Workbench-Blueprint?node-id=40-2`
- File key：`0MkTyZXHmfBaZ2K9fqddCm`
- 主节点：`40:2`
- 标题：`MTPRO Workbench Screen Layout v1`

## 2. Canonical Frame List

| Node ID | Frame |
| --- | --- |
| `40:2` | `MTPRO Workbench Screen Layout v1` |
| `40:3` | `Screen Layout 信息架构地图（Layout IA Map）` |
| `40:38` | `总览（Overview）- Screen Layout` |
| `40:136` | `行情回放（Market Replay）- Screen Layout` |
| `40:234` | `策略研究（Research）- Screen Layout` |
| `40:332` | `回测（Backtest）- Screen Layout` |
| `40:430` | `报告（Report）- Screen Layout` |
| `40:528` | `Paper 模拟执行（Paper）- Screen Layout` |
| `40:626` | `组合（Portfolio）- Screen Layout` |
| `40:724` | `风险（Risk）- Screen Layout` |
| `40:822` | `事件与审计（Events / Audit）- Screen Layout` |
| `40:920` | `实盘准备度（Live Readiness）- Screen Layout` |
| `40:1018` | `实盘监控台（Live Monitoring）- Screen Layout` |
| `40:1116` | `未来门禁区（Future Gated）- Screen Layout` |
| `40:1214` | `未来实盘执行控制（Future Live Execution）- Screen Layout` |
| `40:1312` | `未来实盘风险控制（Future Live Risk）- Screen Layout` |
| `40:1410` | `未来事故回放与停机控制（Future Incident Replay / Stop Controls）- Screen Layout` |

## 3. macOS Native Workstation Layout Principles

MTPRO Workbench 是 macOS native professional trading workstation，不是 Web SaaS dashboard，也不是交易按钮优先的下单终端。

布局原则：

- Evidence navigation 优先：用户通过 evidence row、card、source link、timeline preview 和 detail inspector 追溯证据。
- 中文优先：页面标题、状态、提示和禁区说明默认中文；英文仅作为技术别名或 canonical term。
- App 边界稳定：页面只消费 ViewModel / Read Model / Command Model，不读取 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object。
- Current / Completed / Future 清楚分区：已完成基础工作台、已完成只读证据面、Future Gated placeholder 不能混在一起。
- 状态可解释：`empty`、`healthy`、`stale`、`blocked`、`degraded`、`error` 必须能在页面上解释来源和下一步。
- Paper 控制只限本地 session-level：`start` / `pause` / `close` / `reset`。
- Live Monitoring 只读：已完成的是 read-model-only evidence surface，不是 live runtime、broker stream 或交易控制。
- Future Gated 只占位：Future Live Execution / Risk / Incident Replay 只解释 gate 和 boundary，不是执行授权。

## 4. Unified Screen Structure

`Workbench Screen Layout v1` 采用统一 macOS split-view 工作台结构：

| 区域 | 作用 | 边界 |
| --- | --- | --- |
| Sidebar / 主导航 | 展示 Overview、Market Replay、Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness、Live Monitoring、Future Gated 等页面入口 | 不放交易按钮，不放 broker/account 输入 |
| Top status / session summary | 展示当前状态、latest evidence、paper session summary、monitoring summary 或 blocked gate summary | 不触发 live command，不启动 runtime |
| Main evidence workspace | 承载页面主要 evidence row / card / table / summary | 只展示 read model / ViewModel 内容 |
| Detail inspector | 展示选中 evidence 的 source、status、reason、trace id、related links | 不暴露 schema、adapter request、exchange payload 或 broker object |
| Events / Audit timeline preview | 展示当前页面相关 timeline preview 和 source evidence link | 不提供完整查询语言、事件编辑或命令执行 |
| Status / blocked / degraded / error presentation | 解释 empty / healthy / stale / blocked / degraded / error 状态 | 不提供绕过 gate 或继续执行真实交易的动作 |
| Future Gated placeholder area | 解释 future gate、planning placeholder、blocked reason 和 source doc | 不授权 Linear execution，不提供 live command |

## 5. Page Layout Summary

| 页面 | Screen layout 摘要 |
| --- | --- |
| Overview | 展示整体状态、最新证据、下一步路径和 timeline preview。首屏回答今天是否继续研究、回测、观察 Paper，还是先处理 stale / blocked / degraded / error。 |
| Market Replay | 展示 batch、freshness、retention、replay consistency 和 projection consistency。主区是行情批次和回放证据，detail inspector 解释 batch / replay run / freshness source。 |
| Research | 展示 strategy input、signal evidence、research run 和 source link。用户从策略输入和 signal evidence 进入 Backtest 或 Report。 |
| Backtest | 展示 run summary、parity、cost、risk evidence 和 input snapshot。页面强调回测可重放性和进入 Report / Paper 前的 evidence gate。 |
| Report | 展示 report artifact、evidence summary、source link 和 audit trail。Report 是 Research / Backtest / Paper / Risk / Portfolio evidence 的汇总中心，不是交易授权页。 |
| Paper | 展示 paper-only session、proposal、risk decision、paper order intent、simulated fill 和 portfolio projection。仅保留本地 `start` / `pause` / `close` / `reset` session-level controls。 |
| Portfolio | 展示 paper exposure、portfolio projection 和 source report link。不得展示真实账户余额、broker position、margin 或 leverage controls。 |
| Risk | 展示 blocker、reason、paper-only risk evidence 和 future gate。不得提供 live risk command、position command 或 bypass blocker。 |
| Events / Audit | 展示 timeline、stream、sequence、source evidence 和 projection freshness。用于异常追溯，不暴露 schema browser、事件编辑器或完整查询语言。 |
| Live Readiness | 展示 blocked gate、source anchor 和 monitoring handoff。解释 API key、signed endpoint、account endpoint、listenKey、broker adapter、real order lifecycle 为什么仍被 gate 阻断。 |
| Live Monitoring | 展示 Complete / read-model-only evidence surface：health、connection、stream、latency、error 和 degraded evidence。不得提供 reconnect、start live、stop live 或 broker stream 操作。 |
| Future Gated | 展示 planning / boundary placeholder，不是执行授权。用户只能查看 gate explanation、source docs 和 blocked reason。 |
| Future Live Execution | 展示真实订单执行控制的未来门禁说明，不形成当前控制面。不得出现 submit / cancel / replace、order form 或 real order state machine。 |
| Future Live Risk | 展示实盘风控的未来门禁说明，不替代当前 paper-only risk evidence。不得出现 live risk command、position management 或禁交易开关。 |
| Future Incident Replay / Stop Controls | 展示事故回放与停机控制的未来门禁说明，不替代当前 Events / Audit timeline。不得出现 emergency stop、restore live 或 incident command。 |

## 6. Product Interaction Model Mapping

`Workbench Screen Layout v1` 已承接 `docs/product/mtpro-product-interaction-model-v1.md`：

- 每页都包含首屏判断目标。
- 每页都有主要 evidence workspace。
- 每页都有次要状态区或 summary。
- 每页支持可点击 evidence row / card / link。
- 每页有 detail inspector，用于展示 source、reason、trace 和 related links。
- 每页保留 Events / Audit preview 或 timeline 入口。
- 每页保留 `empty` / `healthy` / `stale` / `blocked` / `degraded` / `error` 状态表达。
- 每页保留禁止动作提示，避免把 future gate 或 read-model-only surface 误读为执行能力。

## 7. `@005 / ARC` Review Result

`@005 / ARC` 对 Figma canonical `40:*` 的 `MTPRO Workbench Screen Layout v1` 做了只读架构审查。

初审结论：需修改。整体架构方向通过，但发现 1 个 P1 文案问题：`40:1194` 的 `future gate opened` 容易被理解为“未来门禁已打开”，与 Future Gated 只能是 planning / boundary placeholder、不授权执行的边界冲突。

P1 修正记录：

| Node ID | 修正前 | 修正后 |
| --- | --- | --- |
| `40:1194` | `future gate opened` | `future gate reviewed` |
| `40:1294` | `boundary source opened` | `boundary source linked` |
| `40:1492` | `policy placeholder opened` | `policy placeholder reviewed` |
| `40:902` | `source evidence opened` | `source evidence linked` |
| `40:1000` | `source anchor opened` | `source anchor linked` |

复审结论：通过。

复审确认：

- P1 已关闭。
- 未发现会导致 Future Gated 被误读为“已授权 / 已打开”的 `opened` 残留。
- Future Live Execution / Risk / Incident Replay 仍保持 `Future Gated`、`blocked`、`planning / boundary placeholder，不是执行授权`。
- 未发现执行入口、live command、交易按钮或真实控制能力。

## 8. Hard Boundaries

`Workbench Screen Layout v1` 明确禁止：

- submit / cancel / replace。
- order form。
- broker action。
- signed endpoint。
- account endpoint / listenKey。
- reconnect / start live / stop live。
- live command。
- trading button。
- real order state machine。
- real account balance / broker position。
- Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object 直连 UI。

## 9. Maintenance Boundary

本文档是设计层 screen layout 依据，可作为后续 UI / UX 规则、macOS native component / layout specification 和 high-fidelity visual design 的输入。

它不替代：

- `BLUEPRINT.md` 的 Root / Complete Blueprint 地位。
- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md` 的产品用户动线依据。
- `docs/product/mtpro-product-interaction-model-v1.md` 的产品交互模型。
- `architecture.md` 的 Engineering Module Map。
- Linear issue body 的 execution contract。

后续如果要进入 SwiftUI 实现，必须先通过 Human + `@001 / PLN` 形成 Project / Issue draft，并由 Linear live-read、Parent Codex queue preflight 和唯一 configured executable issue 授权。
