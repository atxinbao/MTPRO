# Frontend ViewModel Contract

日期：2026-05-17

执行者：Codex

## ViewModel 来源

Frontend / Dashboard 只能消费 Backend Use Case 输出的稳定 ViewModel / Read Model。ViewModel 不得直接绑定：

- adapter request / exchange payload
- SQLite / DuckDB schema、SQL row、ORM model
- runtime object
- broker / account state
- signed endpoint / listenKey

## 第一版 ViewModel

| ViewModel | 主要内容 |
| --- | --- |
| Overview / Dashboard | release status、readiness state、blocked boundary、latest evidence |
| Research | symbol、timeframe、strategy、data health、signal preview |
| Backtest | run lifecycle、input snapshot、cost assumption、result summary |
| Paper | paper-only lifecycle、risk blocker、simulated fill evidence |
| Report | artifact index、causal chain、validation evidence |
| Portfolio | position / exposure projection、freshness |
| Risk | pre-trade allow / reject evidence、limit context |
| Events | event log、timeline item、replay integrity、projection freshness |

## 通用边界

- ViewModel 是 UI contract，不是 storage schema。
- Dashboard / Workbench shell 不直接读 adapter、database schema 或 runtime object。
- Paper / Report / Risk / Portfolio / Events 均保持 read-model-only。
- Live blocked / monitoring evidence 只能展示 blocked / read-only evidence，不产生 command surface。

## Issue Boundary Table

| Issue anchor | 压缩契约 |
| --- | --- |
| MTP-14 ViewModel 契约细化 | 明确 UI 只消费 stable ViewModel，禁止直接读取 DB / adapter / runtime |
| MTP-22 macOS Dashboard Shell | Dashboard shell 只组合 ViewModel snapshot，不实现交易能力 |
| MTP-23 Report ViewModel 契约 | Report 是 evidence artifact center，不是 command surface |
| MTP-28 Risk / Portfolio ViewModel 契约 | Risk / Portfolio 只展示 paper / projection evidence |
| MTP-29 Report / Dashboard Trading Validation Evidence 契约 | trading validation evidence 通过 read model 呈现 |
| MTP-34 Paper-only Portfolio Projection Update ViewModel 契约 | portfolio update 来自 paper-only projection，不升级为 real account state |
| MTP-36 Paper Session Runtime Evidence ViewModel 契约 | paper session evidence 只显示本地 runtime facts |
| MTP-44 Paper Execution Workflow Evidence ViewModel 契约 | paper execution workflow 不暴露 broker submit / cancel / replace |
| MTP-47 Paper Workflow Dashboard IA ViewModel 契约 | Paper Workflow Dashboard IA 只组织 paper evidence 和 blocked actions |
| MTP-50 Paper Workflow Observability ViewModel 契约 | Observability 只解释状态、freshness、blocker 和 evidence |
| MTP-51 Paper Workflow Event Timeline / Evidence Explorer ViewModel 契约 | Timeline / Explorer 显示 event evidence，不发命令 |
| MTP-52 Dashboard / Workbench Shell ViewModel 契约 | Dashboard / Workbench shell 是 read-only composition shell |
| MTP-59 Market Data Replay Operations Read Model / ViewModel 契约 | Market replay operations 通过 read model / ViewModel 展示 |
| MTP-66 Live Blocked Evidence Read Model / ViewModel 契约 | Live blocked evidence 只显示 gate / blocked reason，不产生 live command |
| MTP-68 Live Monitoring Console IA / ViewModel 边界契约 | Live monitoring console IA 是 read-model-only |
| MTP-72 Live Monitoring Evidence Read Model / ViewModel 契约 | Live monitoring evidence 只来自 read model / ViewModel |
| MTP-73 Event Timeline Live Monitoring Evidence ViewModel 契约 | Event Timeline preview 只显示 monitoring evidence，不授权 incident / stop runtime |

## 状态字段建议

- `readinessState`
- `emptyReason`
- `failureReason`
- `lastAppliedSequence`
- `freshness`
- `boundaryFlags`
- `evidenceLinks`

## 禁止 Surface

- trading button。
- live command。
- order form。
- production endpoint connect。
- secret input as default path。
- broker account mutation。
- real submit / cancel / replace。
