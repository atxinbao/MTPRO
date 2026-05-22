# MTPRO Workbench User Dashboard Content Model v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 Human 提供的 `@003 / PRD` 草案落仓）

## 1. 文档定位

本文档是 MTPRO Workbench 的 Product Dashboard Content Model，用于把 Workbench 从“证据链展示页面”校正为更接近最终用户每天使用的专业交易工作台内容模型。

它回答：用户打开工作台时先看什么、主屏应该先给出哪些结论、哪些证据留在主屏、哪些技术 evidence 下沉到 inspector / drill-down / Events / Audit，以及 Figma High-Fidelity Key Screens v1 `69:*` 后续应该如何重画为用户可读 Dashboard。

它不是 UI 设计稿，不是组件规范，不是 SwiftUI 实现稿，不创建 Linear Project / Issue，不推进 `Todo`，不启动 Symphony，不运行 Graphify，不授权 Future Live trading 进入当前 scope。

输入依据：

- `docs/product/mtpro-workbench-user-flow-blueprint-v1.md`
- `docs/product/mtpro-product-interaction-model-v1.md`
- `docs/design/mtpro-workbench-screen-layout-v1.md`
- `docs/design/mtpro-workbench-ui-ux-design-rules-v1.md`
- `docs/design/mtpro-workbench-component-layout-specification-v1.md`
- `docs/design/mtpro-workbench-visual-style-direction-v1.md`
- Figma High-Fidelity Key Screens v1：`69:*`，仅作为 architecture-safe draft 参考，不作为最终用户面板设计依据

## 2. 用户面板原则

1. 面向个人专业交易者 / 独立策略研究者。
   主屏应回答“今天我该看什么、先判断什么、是否可以继续研究 / 回测 / Paper 观察”。

2. 主屏先给结论，再给证据入口。
   Evidence chain 必须保留，但不应把 source、trace、timeline、validation anchor 全部堆在主屏。

3. 主屏展示用户可读 summary。
   source / reason / trace / timeline 进入 detail inspector、drill-down 或 Events / Audit。

4. 页面分层清楚。
   主屏负责判断；inspector 负责解释；timeline 负责追溯；docs / source anchor 负责边界来源。

5. 中文优先，英文只作技术别名。
   页面标题、状态、说明、blocked reason 和下一步建议默认中文。

6. 仍保持 no live command / no trading button / no broker action。
   任何主屏内容都不得诱导用户认为可以实盘交易、连接 broker、提交订单或绕过 gate。

## 3. Overview Content Model

### 首屏主判断

Overview 打开后应先回答：

```text
今天工作台状态是否可用？
我应该继续研究、重跑回测、观察 Paper，还是先处理数据 / 风险 / Live gate 异常？
```

### 主状态

主屏只保留 5 个核心状态：

| 主状态 | 用户问题 | 主屏表达 |
| --- | --- | --- |
| 今日工作台状态 | 今天能否继续工作 | healthy / stale / blocked / degraded / error 总结 |
| 数据新鲜度 | 数据是否可信 | latest replay freshness + batch 状态 |
| 最新研究结论 | 最近 report 是否可用 | latest report summary |
| Paper 观察状态 | Paper session 是否正常 | session status + blocker count |
| Live 状态 | 为什么还不能实盘 | readiness blocked gates + monitoring read-only summary |

### 默认卡片

| 卡片 | 主屏内容 | 不放在主屏的内容 |
| --- | --- | --- |
| 今日状态 | 总体状态、下一步建议、最近更新时间 | event sequence、trace id |
| 最新报告 | report 名称、结论状态、是否可进入 Paper | artifact source list、完整 parity chain |
| 数据状态 | freshness、retention、replay consistency | batch checksum、fixture details |
| Paper 状态 | session 状态、allowed / blocked 数、portfolio update 摘要 | paper order / fill 全链路明细 |
| Live 状态 | readiness blocked、monitoring read-only health | API / endpoint / broker gate 全字段 |

### 次级信息

- 最近 3 条异常摘要。
- 最近一次 stale / degraded reason。
- 最近 Paper blocker。
- 最近 Live monitoring error count。
- 当前 Future Gated 提示。

### Drill-down 信息

- Report artifact detail。
- Market Replay batch detail。
- Paper session detail。
- Risk blocker detail。
- Live readiness gate detail。
- Live monitoring evidence detail。

### 从主屏移到 inspector / timeline 的 evidence

| 内容 | 移动到 |
| --- | --- |
| source anchor | detail inspector |
| trace id | detail inspector |
| validation anchor | detail inspector / docs link |
| event sequence | Events / Audit |
| timeline route | Events / Audit |
| raw evidence chain list | drill-down |
| long blocked reason | inspector |
| schema / adapter / runtime 相关词 | 不展示 |

## 4. 页面内容模型

| 页面 | 用户问题 | 主屏内容 | 主指标 / 主状态 | Detail / Inspector | Timeline / Audit | 禁止动作 |
| --- | --- | --- | --- | --- | --- | --- |
| Market Replay | 当前数据能不能用于研究和回测 | batch 概览、freshness、retention、replay consistency | fresh / stale / expired、latest batch、record count | batch id、replay run、retention policy、checksum、source anchor | replay event、projection consistency、freshness changes | 真实历史下载控制、production scheduler、signed endpoint |
| Research | 当前策略信号是否值得回测 | 策略名称、输入状态、signal summary、研究 run 摘要 | signal health、input freshness、run count | strategy config、input snapshot、signal source | signal generated、input changed、research run events | 策略市场、黑盒策略执行、真实交易动作 |
| Backtest | 回测是否可信，能否生成报告 | run summary、PnL / drawdown 级别摘要、parity、cost、risk 状态 | run status、parity status、cost assumption、risk blocker count | input snapshot、cost details、risk evidence、replay source | run lifecycle、parity event、risk event | 实盘授权、order submit、broker fill、真实账户引用 |
| Report | 是否形成可追溯结论 | report conclusion、artifact status、关键 evidence 摘要、下一步 Paper 建议 | artifact health、covered evidence、blocked count | evidence list、source links、validation anchors | artifact created、source evidence chain | 把报告作为交易授权、live order button |
| Paper | Paper session 是否正常，是否有阻断 | session 状态、allowed / blocked、simulated fill summary、portfolio update 摘要 | session status、proposal count、blocked count、simulated fill count | proposal、risk decision、paper order intent、fill detail | session control、decision -> fill -> portfolio events | submit / cancel / replace、order form、broker action、real order lifecycle |
| Portfolio | 当前 paper exposure 是否可解释 | exposure summary、symbol 分布、gross exposure、latest update | exposure health、gross notional、symbols count | portfolio id、update id、source report、projection reason | portfolio update events | real account balance、broker position、margin / leverage |
| Risk | 当前阻断来自哪里 | blocker summary、rejection reason、risk status、future live gate 提示 | blocker count、severity、affected session / report | blocker detail、threshold、source evidence | risk decision、blocked event | live risk command、position command、bypass blocker |
| Events / Audit | 异常如何追溯 | 默认按业务主题聚合，而不是 raw timeline 全量铺开 | latest abnormal event、stream health、projection freshness | selected event detail、source、reason、related evidence | 完整只读 timeline、sequence、stream、route | 完整查询语言、事件编辑、命令执行 |
| Live Readiness | 为什么还不能实盘 | blocked gates summary、缺失 gate、当前禁止能力 | readiness blocked、gate count、highest risk gate | gate reason、source contract、forbidden capability | blocked gate events、readiness evidence | API key 输入、signed request、broker connect、live command |
| Live Monitoring | 当前只读监控证据说明什么 | health、connection、stream、latency、error、degraded summary | health status、connection status、error count、latency bucket | evidence detail、reason、source anchor、read-model-only boundary | monitoring evidence timeline | reconnect、start live、stop live、broker stream、真实 order stream runtime |
| Future Gated | 哪些未来能力还不能进入当前工作台 | Future Live Execution / Risk / Incident Replay 三块 placeholder | all blocked / gated | missing gate、source docs、required future planning | 只保留 gate review evidence | 执行入口、创建 issue、推进 Todo、交易动作 |

## 5. Content Priority Matrix

| 内容类型 | 主屏展示 | Inspector 展示 | Timeline 展示 | Docs / Source Anchor 展示 | 不展示 |
| --- | --- | --- | --- | --- | --- |
| 用户可读状态总结 | 是 | 可重复 | 否 | 否 | 否 |
| 下一步建议 | 是 | 可重复 | 否 | 否 | 否 |
| KPI / summary metric | 是 | 可解释 | 否 | 否 | 否 |
| source id / source anchor | 否 | 是 | 可关联 | 是 | 否 |
| trace id | 否 | 是 | 是 | 否 | 否 |
| event sequence | 否 | 选中后显示 | 是 | 否 | 否 |
| validation anchor | 否 | 是 | 否 | 是 | 否 |
| full evidence chain | 否 | drill-down | 是 | 可引用 | 否 |
| blocked reason summary | 是 | 是，显示完整原因 | 是 | 是 | 否 |
| raw DB schema / SQL / ORM | 否 | 否 | 否 | 否 | 是 |
| Runtime object / Adapter request | 否 | 否 | 否 | 否 | 是 |
| exchange payload / broker object | 否 | 否 | 否 | 否 | 是 |
| API key / secret / listenKey | 否 | 否 | 否 | 否 | 是 |
| trading button / live command | 否 | 否 | 否 | 否 | 是 |

## 6. 对 Figma `69:*` 的修正建议

Figma High-Fidelity Key Screens v1 `69:*` 已通过架构安全审查，但内容偏 evidence / source / trace / timeline，不作为最终用户面板设计依据。后续 `User-Facing Dashboard High-Fidelity v2` 应保留其安全边界和窗口结构，同时重画信息内容优先级。

### 保留

- macOS window、sidebar、top status、main workspace、detail inspector、timeline preview 的结构。
- 中文导航和中文状态标签。
- Overview 的 5 个指标卡方向。
- Market Replay 的 batch / retention / replay consistency 分组。
- Live Monitoring 的 read-model-only evidence surface 表达。
- Future Gated 的 blocked / placeholder / non-authorization 表达。
- 无 trading button、无 broker action、无 submit / cancel / replace 的边界。

### 降级到 detail / inspector

| 当前 `69:*` 倾向 | 建议 |
| --- | --- |
| source、reason、trace、timeline route 常驻主屏 | 移到 inspector，仅在选中行后显示 |
| evidence table 在主屏占比过高 | 主屏改为 summary + top exceptions，完整表进入 drill-down |
| timeline preview 每页都很强 | Overview 只放最近异常摘要；完整 timeline 进入 Events / Audit |
| validation / source 文案偏架构 | 改为用户可读原因，技术 anchor 放 inspector |
| Future boundary list 太像可操作清单 | 改成“为什么还不能做”的 gate summary |

### 改成用户可读 summary

| 原表达方向 | 用户可读方向 |
| --- | --- |
| `source / trace / timeline route` | 来源可追溯：点击查看详情 |
| `Replay evidence table` | 数据可用性：新鲜 / 过期 / 不一致 |
| `Monitoring evidence table` | 监控状态：健康、连接、延迟、错误 |
| `Future boundary list` | 未来能力仍被门禁阻断 |
| `selected evidence` | 当前选中的证据详情 |
| `read-model-only boundary` | 只读证据，不提供实盘控制 |

### 需要重画为 User-Facing Dashboard High-Fidelity v2 的页面

| 页面 | v2 重画目标 |
| --- | --- |
| Overview | 从 evidence table 改为每日工作台总览：今日状态、下一步建议、最新报告、数据状态、Paper 状态、Live 状态 |
| Market Replay | 从 replay evidence table 改为数据可用性面板：批次健康、freshness、retention、回放一致性和异常入口 |
| Research | 从 signal evidence 列表改为策略研究摘要：当前策略、输入质量、信号状态、可进入回测条件 |
| Backtest | 从 evidence chain 改为回测判断面板：结果摘要、可信度、成本 / 风险 gate、进入报告建议 |
| Report | 从 artifact evidence 列表改为结论中心：关键结论、覆盖证据、缺口、进入 Paper 的条件 |
| Paper | 从链路明细改为 session 观察台：session 状态、允许 / 阻断、模拟成交摘要、组合影响、本地控制 |
| Live Monitoring | 从 monitoring evidence table 改为只读监控面板：health、connection、stream、latency、error、degraded 摘要 |
| Future Gated | 从 boundary list 改为 gate explanation：未来能力、缺失 gate、为什么不能执行、相关文档入口 |

## 7. 给 `@004 / DSG` 的 High-Fidelity v2 输入摘要

- v2 的目标不是继续增加证据密度，而是把 `69:*` 改成用户每日可用 Dashboard。
- Overview 首屏优先级：今日状态、下一步建议、最新报告、数据状态、Paper 状态、Live readiness / monitoring。
- 每页主屏保留 3-5 个用户判断指标；source、trace、timeline route、validation anchor 进入 inspector。
- Events / Audit 是完整追溯页，不应让所有页面都像 timeline 页面。
- Live Monitoring 主屏只展示 read-model-only monitoring summary，不做 broker stream / reconnect / start live / stop live。
- Future Gated 页面要像边界解释页，不像待办清单、项目入口或执行控制台。
- 任何按钮、菜单、toolbar、快捷操作都不得表达 submit / cancel / replace、broker action、live command、order form。

## 8. 给 `@005 / ARC` 的后续审查重点

- v2 是否仍只消费 ViewModel / Read Model / Command Model。
- 主屏 summary 是否避免暴露 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object。
- source / trace / timeline 是否已经下沉到 inspector / Events，而不是主屏堆叠。
- Paper 页面是否只保留 `start` / `pause` / `close` / `reset` 本地 session-level controls。
- Live Monitoring 是否只读，且没有 reconnect / start live / stop live / broker stream 操作。
- Future Gated 是否没有 start planning / create issue / begin build / execution hint。
- 用户可读 summary 是否仍能保持 evidence trail，不丢失追溯入口。

## 9. 非授权边界

本文档不授权：

- 修改 Figma。
- 创建 Linear Project / Issue。
- 修改 Linear status。
- 推进 `Todo`。
- 启动 `@002 / PAR`。
- 启动 Symphony / symphony-issue。
- 运行 Graphify update。
- 编写业务代码或 SwiftUI 实现。
- 把 Future Live trading 写成当前 execution scope。
- API key / secret storage、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、real order state machine、submit / cancel / replace、trading button、live command 或 order-level command UI。
