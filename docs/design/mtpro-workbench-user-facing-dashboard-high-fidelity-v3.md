# MTPRO Workbench User-Facing Dashboard High-Fidelity v3

日期：2026-05-23

执行者：Codex（`@000 / AIE`，基于 `@004 / DSG` Figma 输出、macOS native refinement 修正结果和 `@005 / ARC` 复审结论落仓）

## 1. 文档定位

本文档是 `MTPRO Workbench User-Facing Dashboard High-Fidelity v3` 的 User-Facing Business Dashboard High-Fidelity Design Reference / 业务判断工作台高保真设计依据。

它承接 `MTPRO Workbench Business Dashboard Content Model v2` 草案，用于记录 Figma canonical `91:*` 中已通过 `@005 / ARC` 复审的 Workbench business dashboard 关键页面。v3 的重点是把 v2 的用户可读 dashboard 进一步推进为更接近原生 macOS 专业桌面客户端的工作台：以 sidebar / toolbar / workspace / inspector 为基础，优先展示业务判断、核心指标、可扫描列表和只读追溯入口。

本文档不是 SwiftUI implementation，不是组件库，不是 Linear execution 授权，也不是 `MTPRO Live PRO Console` 或实盘操作台。它不创建 Linear Project / Issue，不推进 `Todo`，不启动 Symphony，不运行 Graphify，不授权 Future Live trading 或业务代码开发。

## 2. Canonical Figma Source

| 项 | 内容 |
| --- | --- |
| Figma file | [MTPRO Professional Trading Workbench Blueprint](https://www.figma.com/design/0MkTyZXHmfBaZ2K9fqddCm/MTPRO-Professional-Trading-Workbench-Blueprint?node-id=91-2) |
| File key | `0MkTyZXHmfBaZ2K9fqddCm` |
| Canonical node | `91:2` |
| Canonical title | `MTPRO Workbench User-Facing Dashboard High-Fidelity v3` |
| Review status | `@005 / ARC` 复审通过 |

## 3. Frame Node List

| Node | Frame |
| --- | --- |
| `91:2` | MTPRO Workbench User-Facing Dashboard High-Fidelity v3 |
| `91:3` | 总览（Overview） |
| `91:149` | 行情回放（Market Replay） |
| `91:283` | 策略研究（Research） |
| `91:417` | 回测（Backtest） |
| `91:551` | 报告（Report） |
| `91:685` | Paper 模拟执行（Paper） |
| `91:828` | 组合（Portfolio） |
| `91:962` | 风险（Risk） |
| `91:1096` | 事件与审计（Events / Audit） |
| `91:1229` | 实盘准备度（Live Readiness） |
| `91:1363` | 实盘监控台（Live Monitoring） |
| `91:1497` | 未来门禁区（Future Gated） |

## 4. v3 设计定位

v3 相对 v2 的核心变化是从 system health / evidence / gate dashboard 推进为 business decision dashboard，并进一步经过 macOS native desktop refinement。

- Overview 覆盖今日数据、当前策略 / signal、最新回测、报告、Paper、Portfolio / Risk、Live readiness / monitoring summary。
- Research -> Backtest -> Report -> Paper 形成业务判断链：策略假设 -> 回测可信度 -> 报告结论 -> Paper 观察。
- `source`、`trace id`、`validation anchor` 下沉到 Detail inspector / Events / Audit，避免主屏回退为 evidence-heavy 页面。
- Paper / Portfolio 统一使用 `simulated PnL`、`paper-only PnL`、`paper exposure`、`simulated exposure` 口径，不表达真实账户或真实仓位。
- Live Readiness 主屏只保留 blocked gate summary / highest blocking reason，完整 capability taxonomy 下沉到 inspector 或 docs anchor。
- Live Monitoring 仍是 Complete / read-model-only evidence surface，不提供 runtime control。
- Future Gated 仍是 planning / boundary placeholder，不是 planning / execution / Linear 授权入口。

当前 v3 仍属于 Workbench UI Layer。页面只能消费 ViewModel / Read Model / Command Model，不读取 Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object。

## 5. macOS Native Desktop Refinement

`@004 / DSG` 在 `91:*` 上完成了 macOS native desktop refinement，目标是把 v3 从 Web dashboard card 模板推进为原生 macOS 专业桌面工作台形态。

已确认的 native workstation 结构：

- Sidebar / source-list：承载 Workbench 当前产品面页面导航。
- Toolbar：承载业务 / 只读证据 / 审计追溯分段语义和搜索 / 快速定位入口。
- Workspace：承载业务判断、列表 / 表格 / outline、selected row 语义和页面主工作区。
- Inspector：承载 source、reason、trace、validation、read-model-only boundary 等下钻信息。
- Events / Audit route：承接完整 source / trace / validation / event sequence，而不是散落在所有主屏。

修正记录：

- 行级状态 pill 对齐已修正。
- 漂浮状态残留已修正。
- Future Gated 底部 `边界说明` 与 `异常与审计入口` 重叠已修正。
- hidden legacy layers 仍存在，但均为 hidden，不进入最终截图；后续设计清理阶段可删除，降低后续 metadata 误读风险。

## 6. Frame 内容摘要

| Frame | 主屏业务定位 | Inspector / Audit 分层 | 禁止边界 |
| --- | --- | --- | --- |
| Overview | 每日交易研究工作台：今日数据、当前策略 / signal、最新回测、最新报告、Paper 表现、Portfolio / Risk 和 Live summary | 详情区承载 source / reason / trace / validation；Events / Audit 承载完整异常路径 | 不展示交易按钮、live command、runtime / adapter 直连 |
| Market Replay | 判断今天数据是否足够支持研究和回测，突出 batch / replay run / freshness / consistency | batch、checksum、source anchor、replay events 下沉 inspector / audit | 不提供真实历史下载控制、production scheduler、signed endpoint |
| Research | 判断策略假设、signal 方向 / 强度、输入质量是否值得进入回测 | strategy config、input snapshot、signal source 下沉 inspector | 不做策略市场、黑盒策略执行或真实交易动作 |
| Backtest | 判断 return、drawdown、trade count、cost impact、risk blocker、parity 是否支持形成报告 | input snapshot、cost detail、risk evidence、run lifecycle 下沉 inspector / audit | 不做实盘授权、order submit、broker fill 或真实账户引用 |
| Report | 判断 verdict、covered evidence、缺口、风险说明和 Paper 条件 | artifact source、validation anchor、evidence chain 下沉 inspector / audit | 报告不作为交易授权，不提供 live order button |
| Paper | 本地模拟执行观察台：session 状态、simulated fill、paper-only PnL、paper exposure、portfolio impact 和 blocker | proposal、risk decision、paper order intent、fill detail 进入 inspector / audit | 只允许本地 session-level controls；禁止 submit / cancel / replace、order form、broker action |
| Portfolio | 判断 paper exposure、simulated exposure、集中度、latest update 和 paper position summary | portfolio projection、source report、update events 下沉 inspector / audit | 不展示 real account balance、broker position、margin / leverage |
| Risk | 判断 blocker count、severity、affected workflow 和 threshold summary | blocker detail、threshold、source evidence 下沉 inspector / audit | 不提供 live risk command、position command 或 bypass blocker |
| Events / Audit | 只读追溯工作区，承接 source / trace / validation / event sequence | 展示完整 timeline、event table、source route 和 validation route | 不提供完整查询语言、事件编辑或命令执行 |
| Live Readiness | 只解释为什么还不能实盘：blocked gate summary / highest blocking reason / monitoring handoff | gate source、contract anchor、forbidden evidence 下沉 inspector / docs anchor | 不提供 API key 输入、signed request、broker connect 或 live command |
| Live Monitoring | Complete / read-model-only monitoring summary：health、connection、stream、latency、error、degraded | monitoring source、read-model-only boundary、Events / Audit route 下沉 inspector | 不提供 reconnect、start live、stop live、broker stream 或真实 order stream runtime |
| Future Gated | 边界解释页：未来能力为什么不能进入当前 Workbench | docs anchor、missing gate、non-authorization evidence 下沉 inspector | 不是 planning queue、execution surface、Linear 授权入口或控制台 |

## 7. 与 Business Dashboard Content Model v2 的映射

| Business Dashboard Content Model v2 要求 | v3 映射 |
| --- | --- |
| Workbench 从系统状态 / 证据链 / gate 展示页推进为专业交易研究者每天可用的业务判断工作台 | `91:*` 把主屏重心放到今日业务判断、策略 / signal、回测、报告、Paper、Portfolio / Risk 和 Live 边界摘要 |
| Overview 优先回答今日数据、当前策略 / signal、最新回测、最新报告、Paper 表现、Portfolio / Risk、Live readiness / monitoring summary | `91:3` 改为每日交易研究工作台，覆盖今日业务指标和今日业务判断 |
| Research / Backtest / Report / Paper 形成业务判断链 | `91:283`、`91:417`、`91:551`、`91:685` 分别承接 signal -> run -> verdict -> paper-only observation |
| 主屏减少 source / trace / validation anchor | v3 将 source / trace / validation 放入 inspector / Events / Audit，而不是常驻主屏 |
| Paper / Portfolio 必须避免真实账户误读 | v3 使用 `simulated PnL`、`paper-only PnL`、`paper exposure`、`simulated exposure` |
| Live Readiness 不回退为 gate taxonomy dashboard | `91:1229` 主屏只展示 blocked gate summary 和 highest blocking reason |
| Future Gated 不是 planning / execution 入口 | `91:1497` 明确为 boundary placeholder，不授权 planning、execution 或 Linear |

## 8. 对 Figma `85:*` 的主要修正

Figma `85:*` 已作为 User-Facing Dashboard High-Fidelity v2 落仓，但仍偏 system health / evidence / gate dashboard。v3 做了以下修正：

- 提高 business decision density：主屏优先呈现业务判断、核心指标和下一步。
- 降低 system health / gate / evidence table 主屏占比。
- Overview 从“今日工作台状态”改为“每日交易研究工作台”。
- Research -> Backtest -> Report -> Paper 形成更清晰的业务链路。
- Paper / Portfolio 统一使用 simulated / paper-only 口径。
- Live Readiness 主屏只保留 blocked gate summary / highest blocking reason。
- 从 Web dashboard card 模板推进到 macOS native desktop workstation：sidebar / toolbar / workspace / inspector。

## 9. @005 / ARC 审查结论

初审结论：需修改。

- P0：无。
- P1：状态 pill 可见错位 / 叠放；Future Gated 底部 `边界说明` 与 `异常与审计入口` 叠层。
- P2：hidden legacy layers 仍在 metadata 中存在；只要最终截图不显示，不作为阻断。

复审结论：通过。

- P0 / P1：无。
- 上轮 P1 视觉问题已关闭。
- 已复查 `91:3`、`91:283`、`91:685`、`91:1229`、`91:1363`、`91:1497`，行级状态 pill 对齐、漂浮状态残留、Future Gated 底部重叠均已修正。
- P2：hidden legacy layers 仍存在，但均为 hidden，不进入最终截图；后续可在设计清理阶段删除，降低后续误读风险。

已确认通过的边界：

- `91:*` 保持 macOS native Workbench 结构：sidebar / toolbar / workspace / inspector。
- 页面仍是业务判断工作台，不是 Live PRO Console。
- Paper 只保留本地 session-level controls：开始观察、暂停观察、关闭 session、重置本地状态。
- Live Monitoring 保持 read-model-only evidence surface，只展示 health / connection / stream / latency / error / degraded summary，不提供 reconnect / start live / stop live。
- Future Gated 仍是 boundary placeholder，不是 planning / execution / Linear 授权入口。
- 未发现 submit / cancel / replace、order form、broker action、signed endpoint、account endpoint / listenKey、OMS、`LiveExecutionAdapter`、真实账户、真实仓位、live command 等越界能力。

## 10. Product / Live 边界

当前 v3 是 Workbench business dashboard，不是 `MTPRO Live PRO Console`。

产品面分界以 `docs/product/mtpro-product-surface-split-v1.md` 为准：`MTPRO Workbench` 与未来 `MTPRO Live PRO Console` 是两个产品面，Figma `91:*` 只代表 Workbench dashboard，不代表 Live PRO Console 或实盘操作台。

- Workbench 当前负责 Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness 和 read-model-only Live Monitoring 的业务判断、状态解释和证据导航。
- Future Live PRO Console 若需要表达真实账户、真实订单控制、live risk、no-trade state、circuit breaker、emergency stop 或 incident replay，应作为独立 future product surface 单独规划。
- Workbench 不能自然升级为实盘操作台，Paper / evidence UI 也不能升级为实盘控制面。

## 11. Forbidden UI Surface Checklist

Figma `91:*` 和本文档均不包含、也不授权：

- trading button。
- order form。
- submit / cancel / replace。
- broker action。
- signed endpoint。
- account endpoint / listenKey。
- real account balance。
- broker position。
- OMS。
- `LiveExecutionAdapter`。
- real order state machine。
- reconnect / start live / stop live。
- live command。
- emergency stop 当前可执行动作。

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
