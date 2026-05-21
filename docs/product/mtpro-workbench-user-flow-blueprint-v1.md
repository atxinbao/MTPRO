# MTPRO Workbench User Flow Blueprint v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

## 定位

本文档是 MTPRO 产品层用户动线蓝图，记录 Figma canonical `15:*` 设计源中通过 `@005 / ARC` 审查的 `MTPRO Workbench User Flow Blueprint v1`。

它回答：目标用户是谁、用户为什么打开工作台、用户从哪个页面进入、每个页面帮助用户做什么判断、Current / Completed / Future Gated 边界如何表达，以及哪些动作绝对不能出现。

它不回答：最终视觉风格、UI 组件规范、macOS 高保真界面、SwiftUI 实现方式或 Linear execution scope。本文档不创建 Linear Project / Issue，不推进 `Todo`，不启动 Symphony，不授权任何真实 Live trading 能力。

## Canonical Figma Source

| 项 | 内容 |
| --- | --- |
| Figma file | [MTPRO Professional Trading Workbench Blueprint](https://www.figma.com/design/0MkTyZXHmfBaZ2K9fqddCm/MTPRO-Professional-Trading-Workbench-Blueprint?node-id=15-2) |
| File key | `0MkTyZXHmfBaZ2K9fqddCm` |
| Canonical node | `15:2` |
| Canonical title | `MTPRO 用户动线工作台蓝图 v1` |
| Review status | `@005 / ARC` 复审通过 |

## Target Users

| 用户类型 | 核心动机 | 工作台需要帮助用户判断什么 |
| --- | --- | --- |
| 个人专业交易者 | 在本地 Mac 上研究、验证、观察策略 | 今天系统状态是否可用，哪些证据可信，哪些能力仍被阻断 |
| 独立策略研究者 | 使用 Binance public read-only market data 做策略研究和回测 | 数据来源、signal、回测、成本、风险和报告是否可复现 |
| Paper readiness 用户 | 不碰真实资金前观察模拟执行链路 | Paper session、order intent、simulated fill、portfolio projection 是否一致 |
| 未来 Live 用户 | 想最终进入实盘，但需要知道为什么现在还不能 | Live readiness 缺哪些 gate，Live monitoring 只能观察什么，不能执行什么 |

## User Flows

| 动线 | 路径 | 用户判断 |
| --- | --- | --- |
| 今日状态检查 | 总览 -> 行情回放 -> 风险 -> 实盘准备度 -> 实盘监控台 | 今天是否继续研究、重跑回测、观察 Paper，还是先处理异常 |
| 策略研究到回测 | 行情回放 -> 策略研究 -> 回测 | 数据批次、freshness、signal evidence 和回测输出是否可信 |
| 回测到报告 | 回测 -> 报告 -> 事件与审计 | 回测是否可复现，结论是否能沉淀为 evidence artifact |
| Paper session 观察 | 报告 -> Paper 模拟执行 -> 组合 -> 风险 | Paper lifecycle、risk decision、simulated fill 和 paper projection 是否一致 |
| 异常追溯 | 总览 -> 事件与审计 -> 报告 / Paper / 风险 | 异常来自数据、策略、回测、Paper、风险还是投影 |
| Live readiness / monitoring 判断 | 实盘准备度 -> 实盘监控台 -> 未来门禁区 | 为什么还不能实盘，当前能看到哪些只读监控证据，下一步 gate 在哪里 |

## Page Roles

| 页面 | 页面角色 | 产品层判断 |
| --- | --- | --- |
| 总览 / Overview | 工作台入口 | 汇总当前 evidence 状态、progress、blocker 和下一步路径 |
| 行情回放 / Market Replay | 数据可信入口 | 判断 batch、retention、freshness 和 replay consistency 是否可用 |
| 策略研究 / Research | 信号证据入口 | 判断策略输入、配置、signal evidence 和研究 run 是否可信 |
| 回测 / Backtest | 历史验证入口 | 判断 parity、cost、risk、输入快照和 replay evidence 是否满足进入报告或 Paper 的条件 |
| 报告 / Report | Evidence artifact 中心 | 把 Research / Backtest / Paper / Risk / Portfolio 串成可追溯结论 |
| Paper 模拟执行 / Paper | Paper session 观察面 | 观察 paper-only session、intent、simulated fill 和 session-level local control 语义 |
| 组合 / Portfolio | 模拟敞口解释面 | 解释 paper exposure 和 portfolio projection，不展示真实账户余额 |
| 风险 / Risk | 阻断和降级解释面 | 解释 blocker、rejection reason、paper-only risk evidence 和 future live gate |
| 事件与审计 / Events / Audit | 异常追溯入口 | 按 event timeline、replay、projection freshness 和 evidence links 回溯 |
| 实盘准备度 / Live Readiness | Current blocked evidence | 解释 API key、signed endpoint、account endpoint、listenKey、broker adapter、real order lifecycle 为什么 blocked |
| 实盘监控台 / Live Monitoring | Completed read-model-only evidence surface | 展示 health、connection、stream、latency、error、degraded evidence；不代表真实 live runtime |
| 未来门禁区 / Future Gated | Planning / boundary placeholder | 展示 Future Live Execution / Risk / Incident Replay 的门禁说明，不授权执行 |

## State Partition

| 分区 | 含义 | 当前页面 |
| --- | --- | --- |
| Current completed | 已完成基础工作台能力，用户可以观察已落地证据 | Overview、Market Replay、Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness |
| Completed read-model-only evidence surfaces | 已完成但只能只读展示的 evidence surface | Live Monitoring |
| Future Gated | 未来门禁区，只能作为 planning / boundary placeholder | Future Live Execution、Future Live Risk、Future Incident Replay / Stop Controls |

`Live Monitoring` 已完成，但只表示 read-model-only evidence surface。订单事件只表达 blocked / simulated / future evidence，不表示真实 order stream runtime，不提供 reconnect、start live、stop live、broker action、live command 或交易按钮。

## Canonical Frame List

| Node | Frame |
| --- | --- |
| `15:2` | MTPRO 用户动线工作台蓝图 v1 |
| `15:3` | 工作台信息架构地图（Workbench IA Map） |
| `15:50` | 总览（Overview）- 今日状态检查 |
| `15:125` | 行情回放（Market Replay）- 数据新鲜度判断 |
| `15:196` | 策略研究（Research）- 信号证据判断 |
| `15:*` | 回测（Backtest）- 可重放结果判断 |
| `15:*` | 报告（Report）- 证据汇总判断 |
| `15:*` | Paper 模拟执行（Paper）- session 观察 |
| `15:*` | 组合（Portfolio）- 模拟敞口判断 |
| `15:*` | 风险（Risk）- 阻断与降级判断 |
| `15:*` | 事件与审计（Events / Audit）- 异常追溯 |
| `15:*` | 实盘准备度（Live Readiness）- Current 阻断解释 |
| `15:758` | 实盘监控台（Live Monitoring）- 只读监控证据 |
| `15:829` | 未来门禁区（Future Gated）- 总览 |
| `15:872` | 未来实盘执行控制（Future Live Execution）- Placeholder |
| `15:915` | 未来实盘风险控制（Future Live Risk）- Placeholder |
| `15:958` | 未来事故回放与停机控制（Future Incident Replay / Stop Controls）- Placeholder |

`15:*` 表示该 frame 属于 canonical `15:2` 节点组；落仓时只需要固定产品层页面清单和主节点，不把 Figma 内部所有子节点当成仓库合同。

## Architecture Review

`@005 / ARC` 对 canonical `15:*` 节点只读复审结论：通过。

复审确认：

- 未发现真实交易入口、`submit / cancel / replace`、order form、broker action、signed endpoint、account endpoint、listenKey、真实账户余额、真实仓位、真实订单状态机、reconnect / start live / stop live / live command。
- Workbench 三态分区已修正为 `Current completed`、`Completed read-model-only evidence surfaces`、`Future Gated`。
- `Live Monitoring` 已修正为 `Complete / read-model-only evidence surface`。
- `Live Readiness -> Live Monitoring -> Future Gated` 动线成立，仍是 evidence navigation，不是交易入口。
- UI contract 已明确：页面只消费 ViewModel / Read Model / Command Model，不读取 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object。
- Future Live Execution / Future Live Risk / Future Incident Replay 均保持 placeholder / non-authorization record。

## Hard Boundaries

本文档和 Figma canonical `15:*` 均不授权以下能力：

- API key / secret storage。
- signed endpoint / account endpoint / listenKey。
- broker / exchange execution adapter。
- `LiveExecutionAdapter`。
- real order state machine / OMS。
- submit / cancel / replace。
- broker fill / execution report / reconciliation。
- trading button、order form、live command、order-level command UI。
- emergency stop、restore live、incident command 或真实 stop control。
- Runtime、Adapter、SQLite / DuckDB schema、exchange payload、broker object 直连 UI。

## Design-Layer Handoff

下一层设计不应继续扩写本文档，而应单独进入设计层：

- `Workbench Screen Layout v1`：把用户动线翻译为 macOS 工作台屏幕布局。
- `UI/UX design rules`：定义状态语言、密度、导航、inspector、表格、timeline、空状态和错误状态。
- `macOS native component / layout specification`：定义 SwiftUI / macOS 组件、split view、toolbar、sidebar、detail panel 和尺寸规则。
- `high-fidelity visual design`：在产品动线和 layout 确认后再进入。
