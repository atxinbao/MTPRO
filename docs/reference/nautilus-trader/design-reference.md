# NautilusTrader Design Reference Study

日期：2026-05-19

执行者：@004 / DSG Design Reference Lead

## 任务边界

本文档只保存 NautilusTrader design / information architecture reference 的压缩结论。不创建 Project / Issue，不修改 Figma，不授权 Live PRO Console、交易按钮、live command 或 real order。

## 信息架构参考

| 工作区 | NautilusTrader 线索 | MTPRO 页面语义 |
| --- | --- | --- |
| Research | strategy input、instrument、data range、signal preview | 研究上下文、数据覆盖、信号解释 |
| Backtest | config、run、statistics、fills / orders、PnL | run lifecycle、input snapshot、deterministic replay、result summary |
| Paper | simulated execution、account / positions、risk | paper session、risk blocker、simulated fill、portfolio projection |
| Report | account / order / fill / position reports、tearsheet | artifact center、evidence navigation、export-readiness |
| Portfolio | positions、net positions、exposure | read-model-only exposure / position surface |
| Risk | risk checks、reject / allow semantics | blocked / allowed evidence，不是 live control |
| Events | message / event lifecycle | event timeline、replay integrity、projection freshness |

## Dashboard / Workbench 页面拆分建议

| 页面 | 主要内容 | 禁止内容 |
| --- | --- | --- |
| Overview | 当前 evidence health、latest run、blocked boundary、release status | trading button、account connect CTA |
| Research | symbol / timeframe / strategy / data health / signal preview | direct order intent |
| Backtest | run status、input snapshot、cost assumption、result summary | production endpoint |
| Paper | paper-only lifecycle、risk blocker、simulated fill evidence | broker submit / cancel / replace |
| Report | artifact index、causal chain、validation evidence | real order authorization |
| Portfolio | positions / exposure projection、freshness | real account sync |
| Risk | pre-trade allow / reject evidence、limit context | live risk command |
| Events | event log、replay integrity、projection freshness | runtime object or database schema |

## ViewModel / Read Model 建议

- 所有页面只消费 ViewModel / Read Model，不直接读取 SQLite / DuckDB schema、runtime object、adapter request、broker/account state。
- 页面统一状态字段建议：`readinessState`、`emptyReason`、`failureReason`、`lastAppliedSequence`。
- Report artifact 维度建议：research、backtest、paper session、risk blocker、portfolio exposure、simulated fill、replay evidence。
- Risk / Portfolio / Paper / Report 保留 boundary flags：paper-only、no-live、no-broker、no-signed-endpoint；这些 flag 不可由 UI 用户改写。

## 状态语言

| 状态 | 用户含义 |
| --- | --- |
| empty | 没有可展示 evidence |
| ready | 输入和 projection 可用 |
| running | 本地 run / replay / validation 正在进行 |
| stale | projection 或 data freshness 过期 |
| failed | 本地验证或 projection 失败 |
| invalid | 输入不满足合同 |
| blocked | 被 boundary / risk / production-disabled guard 阻断 |

## 候选 Delta Proposal

| 目标文档 | 建议 |
| --- | --- |
| `docs/product/*` | 将当前 Workbench 区域升级为 Overview、Research、Backtest、Paper、Report、Portfolio、Risk、Events 页面级 IA |
| `docs/contracts/frontend-view-model-contract.md` | 固定 page-level ViewModel fields、artifact taxonomy、boundary flags 和 replay integrity 状态 |
| `architecture.md` | 明确 `Event Log -> Read Models -> Page ViewModels -> SwiftUI Pages`，页面不得直连 runtime / adapter / DB schema |
| `docs/roadmap.md` | 将 Workbench IA hardening 和 Report artifact evidence 作为候选规划输入，不授权 live trading |

## 结论

NautilusTrader 对 MTPRO 的最大设计参考不是 UI 外观，而是 workflow 组织。MTPRO Dashboard / Workbench 应围绕数据准备、研究信号、回测运行、报告分析、风险解释、组合投影、事件审计和 replay evidence 形成只读可追溯链路。
