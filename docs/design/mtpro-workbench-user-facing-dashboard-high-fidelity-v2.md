# MTPRO Workbench User-Facing Dashboard High-Fidelity v2

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 `@004 / DSG` Figma 输出和 `@005 / ARC` 审查结论落仓）

## 1. 文档定位

本文档是 `MTPRO Workbench User-Facing Dashboard High-Fidelity v2` 的设计层依据，记录 Figma canonical `85:*` 中已通过 `@005 / ARC` 审查的用户面 dashboard 高保真关键页面。

它承接 `docs/product/mtpro-workbench-user-dashboard-content-model-v1.md`，用于定义更接近最终用户每天使用的 Workbench dashboard：主屏先给用户判断和下一步建议，技术 evidence 下沉到 inspector、Events / Audit 或 docs anchor。

本文档不是 SwiftUI implementation，不是组件库，不是 Linear execution 授权，也不是 Live PRO Console 或实盘操作台。它不创建 Linear Project / Issue，不推进 `Todo`，不启动 Symphony，不运行 Graphify，不授权 Future Live trading 或业务代码开发。

## 2. Canonical Figma Source

| 项 | 内容 |
| --- | --- |
| Figma file | [MTPRO Professional Trading Workbench Blueprint](https://www.figma.com/design/0MkTyZXHmfBaZ2K9fqddCm/MTPRO-Professional-Trading-Workbench-Blueprint?node-id=85-2) |
| File key | `0MkTyZXHmfBaZ2K9fqddCm` |
| Canonical node | `85:2` |
| Canonical title | `MTPRO Workbench User-Facing Dashboard High-Fidelity v2` |
| Review status | `@005 / ARC` 只读审查通过 |

## 3. Frame Node List

| Node | Frame |
| --- | --- |
| `85:2` | MTPRO Workbench User-Facing Dashboard High-Fidelity v2 |
| `85:3` | 总览（Overview） |
| `85:120` | 行情回放（Market Replay） |
| `85:250` | 策略研究（Research） |
| `85:380` | 回测（Backtest） |
| `85:510` | 报告（Report） |
| `85:640` | Paper 模拟执行（Paper） |
| `85:779` | 组合（Portfolio） |
| `85:909` | 风险（Risk） |
| `85:1039` | 事件与审计（Events / Audit） |
| `85:1179` | 实盘准备度（Live Readiness） |
| `85:1309` | 实盘监控台（Live Monitoring） |
| `85:1439` | 未来门禁区（Future Gated） |

## 4. v2 设计定位

v2 的核心变化是从 evidence-heavy 改为用户可读 dashboard：

- 主屏先给今日状态、下一步建议、最新报告、数据状态、Paper 状态、Live readiness / monitoring summary。
- 每页主屏保留 3-5 个用户判断指标，避免把 source / trace / timeline route / validation anchor 铺满主屏。
- `source`、`reason`、`trace id`、`validation anchor` 下沉到 Detail inspector。
- 完整 event sequence / route 由 Events / Audit 承担。
- 技术证据仍可追溯，但不再压过用户每天需要做的判断。

当前 v2 仍属于 Workbench UI Layer。页面只能消费 ViewModel / Read Model / Command Model，不读取 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object。

## 5. Frame 内容摘要

| Frame | 主屏内容定位 | Detail / Audit 分层 | 禁止边界 |
| --- | --- | --- | --- |
| Overview | 今日工作台状态、下一步建议、最新报告、数据状态、Paper 状态、Live readiness / monitoring summary | 详情区承载 source / reason / trace；Events / Audit 承载完整异常路径 | 不展示交易按钮、live command、runtime / adapter 直连 |
| Market Replay | 数据可用性、freshness、retention、replay consistency 和异常入口 | batch id、replay run、checksum、source anchor 下沉 inspector / audit | 不提供真实历史下载控制、production scheduler、signed endpoint |
| Research | 当前策略、输入质量、signal 状态、是否可进入回测 | strategy config、input snapshot、signal source 下沉 inspector | 不做策略市场、黑盒策略执行或真实交易动作 |
| Backtest | 结果摘要、可信度、成本 / 风险 gate、进入报告建议 | input snapshot、cost details、risk evidence、replay source 下沉 inspector / audit | 不做实盘授权、order submit、broker fill 或真实账户引用 |
| Report | 关键结论、覆盖证据、缺口、进入 Paper 的条件 | source links、validation anchors、artifact evidence 下沉 inspector / audit | 报告不作为交易授权，不提供 live order button |
| Paper | session 状态、允许 / 阻断、模拟成交摘要、组合影响、本地控制 | proposal、risk decision、paper order intent、fill detail 进入 inspector / audit | 只允许本地 session-level controls；禁止 submit / cancel / replace、order form、broker action |
| Portfolio | paper exposure 摘要、symbol 分布、gross exposure、latest update | portfolio id、update id、source report、projection reason 下沉 inspector | 不展示 real account balance、broker position、margin / leverage |
| Risk | blocker summary、rejection reason、severity、影响范围 | blocker detail、threshold、source evidence 下沉 inspector / audit | 不提供 live risk command、position command 或 bypass blocker |
| Events / Audit | 按业务主题聚合异常，不默认铺满 raw timeline | 承担完整只读 timeline、event sequence、stream、route | 不提供完整查询语言、事件编辑或命令执行 |
| Live Readiness | 为什么还不能实盘、缺失 gate、禁止能力 | gate reason、source contract、forbidden capability 下沉 inspector / audit | 不提供 API key 输入、signed request、broker connect 或 live command |
| Live Monitoring | health、connection、stream、latency、error、degraded summary | monitoring evidence detail、reason、source anchor、read-model-only boundary 下沉 inspector / audit | 不提供 reconnect、start live、stop live、broker stream、真实 order stream runtime |
| Future Gated | 未来能力、缺失 gate、为什么不能执行、相关文档入口 | 只保留 gate review evidence 和 source docs | 只是 planning / boundary placeholder，不是执行授权、施工入口或控制台 |

## 6. 与 User Dashboard Content Model v1 的映射

| Content Model 要求 | v2 映射 |
| --- | --- |
| Overview 首屏回答今天是否可继续研究 / 回测 / Paper / Live readiness 判断 | `85:3` 用今日状态、下一步建议、最新报告、数据状态、Paper 状态和 Live summary 组织首屏 |
| 每页主屏只保留 3-5 个用户判断指标 | `85:120` 至 `85:1439` 以状态、summary、异常和下一步建议为主，而不是全量 evidence 表 |
| source / trace / validation 下沉 | v2 将 source、reason、trace id、validation anchor 交给 Detail inspector / Events / docs anchor |
| Events / Audit 承担完整 timeline | `85:1039` 聚合异常并承接完整 sequence / route |
| Live Monitoring 只读 | `85:1309` 明确 Complete / read-model-only evidence surface，只展示 monitoring summary |
| Future Gated 非授权 | `85:1439` 改成 gate explanation，不是待办、项目入口或执行控制台 |

## 7. 对 Figma `69:*` 的主要修正

Figma `69:*` 已通过 architecture-safe 审查，但偏 evidence / source / trace / timeline。v2 做了以下修正：

- 降低 evidence table、source、trace、timeline route 的主屏占比。
- 主屏从“证据链查看”改为“用户判断 + 下一步建议”。
- 技术证据仍保留，但放到 inspector / Events / docs anchor。
- Future Gated 从 boundary list 改成边界解释面，避免被理解为待办清单、项目入口或执行控制台。
- Overview 更接近用户每天打开 Workbench 后的判断面板，而不是架构证据索引页。

## 8. @005 / ARC 审查结论

审查结论：通过。

P0 / P1 / P2：

- P0：无。
- P1：无。
- P2：仅有视觉实现层优化建议。多个页面底部 `状态语义` strip 与右侧 `最近异常摘要` 区域距离较紧，后续落 SwiftUI 时建议用真实 layout token 拉开间距，避免小屏或字体缩放下拥挤。

已确认通过的边界：

- v2 主屏已从 evidence-heavy 改为用户可读 dashboard。
- 各页面主屏基本保持 3-5 个用户判断指标。
- source、reason、trace id、validation anchor 已下沉到 Detail inspector；完整 sequence 由 Events / Audit 承担。
- UI 仍停留在 Workbench UI Layer，未暴露 Runtime、Adapter、SQLite / DuckDB schema、exchange payload、broker object 直连。
- Paper 仅保留本地 session-level controls：开始、暂停、关闭、重置。
- Portfolio / Risk 保持 paper projection、blocker / evidence 口径，未出现真实账户、真实仓位或真实订单状态机。
- Live Readiness 保持 Current blocked evidence / 阻断解释区。
- Live Monitoring 标为已完成只读证据面，只展示 health / connection / stream / latency / error / degraded summary。
- Future Gated 明确为 planning / boundary placeholder，不是执行授权、不是施工入口。

## 9. P2 后续实现建议

后续 SwiftUI 实现时，应把 v2 的 dashboard 内容模型固化为页面 ViewModel contract：

- 主屏只给用户判断字段。
- trace / source / validation 只走 inspector、Events / Audit 或 docs anchor。
- 底部状态语义 strip 与最近异常摘要之间应使用稳定 layout token 拉开间距，避免小屏或字体缩放下拥挤。

这些建议不授权当前 PR 进入 SwiftUI 实现。

## 10. Product / Live 边界

当前 v2 是 Workbench 用户面 dashboard，不是 Live PRO Console。

产品面分界以 `docs/product/mtpro-product-surface-split-v1.md` 为准：`MTPRO Workbench` 与未来 `MTPRO Live PRO Console` 是两个产品面，Figma `85:*` 只代表 Workbench dashboard，不代表 Live PRO Console 或实盘操作台。

- Workbench 当前负责 Research、Backtest、Report、Paper、Portfolio、Risk、Events、Live Readiness 和 read-model-only Live Monitoring 的状态判断与证据导航。
- Future Live PRO Console 若需要表达真实账户、真实订单控制、live risk、no-trade state、circuit breaker、emergency stop 或 incident replay，应作为独立 future product surface 单独规划。
- Workbench 不能自然升级为实盘操作台，Paper / evidence UI 也不能升级为实盘控制面。

## 11. Forbidden UI Surface Checklist

Figma `85:*` 和本文档均不包含、也不授权：

- API key / secret storage input。
- signed endpoint。
- account endpoint / listenKey。
- broker adapter / broker action。
- `LiveExecutionAdapter`。
- real order state machine / OMS。
- submit / cancel / replace。
- broker fill / execution report / reconciliation。
- real account balance / broker position。
- trading button / live command / order-level command UI。
- reconnect / start live / stop live。

Paper 只允许本地 session-level controls：`start` / `pause` / `close` / `reset`。

Live Monitoring 只是 Complete / read-model-only evidence surface。

Future Gated 只是 planning / boundary placeholder，不是执行授权。

## 12. 非授权边界

本文档不授权：

- 修改 Figma。
- SwiftUI 实现。
- 组件库实现。
- 创建 Linear Project / Issue。
- 修改 Linear status。
- 推进 `Todo`。
- 启动 `@002 / PAR`。
- 启动 Symphony / symphony-issue。
- 运行 Graphify update。
- 编写业务代码。
- Future Live trading、Live PRO Console 或实盘操作台进入当前 execution scope。
