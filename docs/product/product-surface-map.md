# Product Surface Map

本文档定义 MTPRO 第一版产品面。

## 产品定位

MTPRO 第一版是最小 Trader Workstation Dashboard，用于观察和控制研究到 Paper 的闭环。

UI 第一版只做最小观察和操作入口，不追求完整交易终端。

## 信息架构

| 区域 | 目的 | v1 边界 |
| --- | --- | --- |
| Market | 观察 Binance public market data | 只读 |
| Strategy | 查看策略配置和信号 | EMA cross 优先 |
| Backtest | 运行和查看回测结果 | 第一优先级 |
| Report | 查看研究到回测的最小报告快照 | 只读，报告不授权交易执行 |
| Paper | 查看 paper execution 状态 | 不触发 live broker action |
| Risk | 查看风险限制和拦截原因 | 只读投影 |
| Portfolio | 查看组合投影 | 只读投影 |
| Events | 查看事件流水和验证证据 | append-only |

## 禁止项

- 不提供 live order button。
- 不提供真实 broker action。
- 不直接展示数据库表结构。
- 不让 UI 直接消费 ORM model 或 runtime object。

## MTP-22 macOS 看板壳

日期：2026-05-18

执行者：Codex

当前 macOS 看板壳已提供 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 七个只读区域。

输入边界：

- SwiftUI shell 只接收 `DashboardViewModel`。
- 可运行入口 `Dashboard` 使用空 read model projection 作为安全启动快照。
- shell smoke run 只输出 read-model-only summary，不连接网络、不读取 secret、不触发交易动作。

仍不包含：

- live order button。
- 真实 broker action。
- UI 直连 database table、ORM、runtime object 或行情 adapter。

## MTP-23 最小报告观察面

日期：2026-05-18

执行者：Codex

当前 Dashboard 在既有只读区域基础上新增 Report 快照，用于呈现 Research -> Backtest -> Report 最小路径。

Report 区域：

- 只消费 App 层 `ReportViewModel`。
- 输入来自稳定 projection snapshots / read model：订单簿研究投影、EMA 回测投影、Paper session 投影和 append-only event timeline。
- 展示 report artifact 数、已完成回测数、研究运行数和 Backtest / Paper 投影级一致性证据数。
- 明确报告是研究输出，不是交易执行授权。

仍不包含：

- 完整报表系统。
- Paper execution 工作流扩展。
- live order button。
- 真实 broker action。
- signed endpoint、account endpoint 或真实订单行为。

## MTP-28 Risk / Portfolio 证据观察面

日期：2026-05-18

执行者：Codex

当前 Dashboard 的 Risk / Portfolio 区域补充只读交易验证证据：

- Risk 区域展示 paper blocker 数、rejected paper order IDs 和 blocker reasons。
- Portfolio 区域展示 portfolio 数、updated portfolio 数、exposure 数、gross exposure notional 和 exposure symbols。
- 这些字段只来自 App 层 ViewModel / SQLite runtime projection snapshot。

仍不包含：

- 完整风险引擎。
- 实时风控或仓位管理。
- 保证金、杠杆、真实账户余额或 broker balance。
- live order button、signed endpoint、account endpoint 或真实订单行为。

## MTP-29 Report / Dashboard 交易验证证据汇总

日期：2026-05-18

执行者：Codex

当前 Dashboard 的 Report 区域补充交易验证 evidence 汇总：

- Report artifact 展示 projection-level parity、fees / slippage cost evidence、risk blocker evidence 和 portfolio exposure evidence。
- Report 区域展示 cost evidence 数、risk blocker 数、exposure evidence 数、cost assumption、cost parity、risk blocker evidence ID、exposure symbols 和 gross exposure notional。
- Cost evidence 只由 MTP-27 deterministic fixture 与 paper-only portfolio exposure projection 派生。
- Risk / Portfolio evidence 只来自 App 层 ViewModel / SQLite runtime projection snapshot。

仍不包含：

- 完整报表系统。
- 交易所费率表、动态滑点模型或执行成本优化。
- 完整风险引擎、仓位管理、保证金、杠杆或真实账户余额。
- live order button、signed endpoint、account endpoint、broker action 或真实订单行为。

## MTP-36 Paper Session runtime evidence 汇总

日期：2026-05-19

执行者：Codex

当前 Dashboard 的 Report 区域补充 Paper Session runtime evidence 汇总：

- Report artifact 展示 lifecycle states、proposal IDs、risk blocker evidence IDs、portfolio update IDs、replay streams 和 replay sequence count。
- Report 区域展示 runtime evidence count、replay facts、runtime sessions、proposal IDs、portfolio update IDs、paper-only boundary 和 deterministic replay flag。
- Runtime evidence 只从 append-only event timeline 的 replay summary、SQLite runtime projection snapshot 和 App 层 read model 派生。
- Dashboard shell 仍只消费 `ReportViewModel` / `DashboardShellSnapshot`，不新增按钮、表单、命令出口或交易控制。

仍不包含：

- UI 大改版或完整报告系统。
- Paper execution workflow 扩展。
- live order button。
- database schema、SQL、ORM model、runtime object 或 adapter request 暴露。
- signed endpoint、account endpoint、broker action 或真实订单行为。

## MTP-44 Paper execution workflow evidence 汇总

日期：2026-05-19

执行者：Codex

当前 Dashboard 的 Report 区域补充 Paper execution workflow evidence 汇总：

- Report artifact 展示 paper execution decision IDs、paper order IDs、simulated fill IDs、workflow replay streams 和 portfolio update IDs。
- Report 区域展示 execution workflow evidence count，并把 decision -> order -> simulated fill -> portfolio projection 的链路作为只读证据展示。
- Workflow evidence 只从 append-only event timeline replay summary 和 App 层 read model 派生，不新增 runtime 写入、不读取 database schema、不调用 adapter。
- Dashboard shell 仍只消费 `ReportViewModel` / `DashboardShellSnapshot`，不新增按钮、表单、命令出口或交易控制。

仍不包含：

- UI 大改版或完整报告系统。
- live order button。
- risk control command、position management command 或 order command。
- database schema、SQL、ORM model、runtime object 或 adapter request 暴露。
- signed endpoint、account endpoint、broker action 或真实订单行为。

## MTP-47 Paper workflow Workbench 信息架构和控制壳边界

日期：2026-05-20

执行者：Codex

当前产品面新增 Paper workflow Workbench information architecture 合同，但不新增 UI 控件或命令执行入口。

Workbench 观察面必须覆盖：

- session。
- proposal。
- risk decision。
- paper order。
- simulated fill。
- portfolio projection。
- replay freshness。
- report artifact status。
- event timeline。

控制壳边界：

- 后续 session-level local controls 只允许 `start` / `pause` / `close` / `reset`。
- 这些 control 只是后续本地 paper-only session 控制壳入口，不是当前 issue 的 Command Model 或 SwiftUI 控件。
- Workbench 仍只消费 ViewModel / Read Model，不读取 database schema、runtime object 或 adapter request。

仍不包含：

- Command Model。
- UI 控件或 Event Timeline 实现。
- order-level command。
- live order button、risk control command、position management command 或 OMS。
- signed endpoint、account endpoint、listenKey、broker action、真实订单提交 / 撤销 / 替换或 Live execution。

## MTP-48 Paper session 本地控制 Command Model

日期：2026-05-20

执行者：Codex

当前产品面新增 session-level local control Command Model，但仍不新增 SwiftUI 控件、按钮、表单或事件时间线。

Command Model 覆盖：

- `start`：表达本地 Paper session 启动意图。
- `pause`：表达本地 Paper session 暂停意图。
- `close`：表达本地 Paper session 关闭意图。
- `reset`：表达本地 Paper session 重置意图。

拒绝边界：

- 非 session-level control 会被拒绝。
- order-level command 会被拒绝。
- `submit` / `cancel` / `replace` 会被拒绝。
- broker action、signed endpoint、account endpoint、listenKey 和 Live trading 会被拒绝。

仍不包含：

- UI 控件或 Dashboard 交互入口。
- session-level control -> event boundary 串联。
- order-level command、OMS、真实订单提交 / 撤销 / 替换。
- broker / exchange side effect、signed endpoint、account endpoint、listenKey 或 Live execution。

## MTP-49 Paper session 本地控制 Event Boundary

日期：2026-05-20

执行者：Codex

当前产品面把 session-level local control validation 记录为本地 paper-only event facts，但仍不新增 SwiftUI 控件、按钮、表单、Event Timeline 或 Evidence Explorer。

Event boundary 覆盖：

- accepted `start` / `pause` / `close` / `reset` 写入 `PaperEvent.sessionControlApplied`。
- invalid raw request 写入 `PaperEvent.sessionControlRejected`，保留 rejected reason。
- 所有 session control facts 固定进入 `.paper` stream，由 append-only event log 分配 sequence。

仍不包含：

- UI 控件或 Dashboard 交互入口。
- 完整 workflow engine。
- projection schema 或 ViewModel 扩展。
- order-level command、paper order command、OMS、真实订单提交 / 撤销 / 替换。
- broker / exchange side effect、signed endpoint、account endpoint、listenKey 或 Live execution。

## MTP-50 Paper workflow observability Read Model / ViewModel

日期：2026-05-20

执行者：Codex

当前产品面新增 Paper workflow observability read model / ViewModel，但仍不新增 SwiftUI 控件、按钮、表单、Event Timeline explorer 或 order-level command。

可观察字段覆盖：

- session IDs、session status、active / completed session count。
- proposal IDs。
- allowed paper execution decision IDs、paper order IDs、simulated fill IDs。
- blocked risk evidence IDs 和 blocked paper order IDs。
- portfolio update IDs 和 portfolio IDs。
- decision -> order -> simulated fill -> portfolio projection chain coverage。
- replay available、deterministic replay、append-only facts source 和 replay freshness。
- report artifact IDs、artifact parity status、completed artifact count 和 research-only authorization。

仍不包含：

- Dashboard / Workbench UI redesign。
- Event Timeline / Evidence Explorer 实现。
- order-level command、paper order command、OMS、真实订单提交 / 撤销 / 替换。
- SQLite / DuckDB schema、SQL、ORM model、runtime object 或 adapter request 暴露。
- broker / exchange side effect、signed endpoint、account endpoint、listenKey 或 Live execution。

## MTP-51 read-model-only Event Timeline / Evidence Explorer 子集

日期：2026-05-20

执行者：Codex

当前产品面新增 Event Timeline / Evidence Explorer 的只读子集，用于从既有 read model 和 append-only event timeline 汇总 evidence links。该子集不新增 SwiftUI 交互控件，不提供命令，不实现完整查询语言。

可观察字段覆盖：

- market event、strategy signal、risk decision、paper order、simulated fill、portfolio projection 和 report artifact 分区。
- timeline item 的 sequence、recorded time、stream、title、summary 和 evidence link summary。
- report artifact 到 decision / order / fill / portfolio / risk blocker evidence 的 chain links。
- read-only filter snapshot 和 section snapshot。
- read-model-only、no schema、no runtime object、no adapter request、no command surface 和 no trading authorization 边界。

仍不包含：

- Dashboard / Workbench UI redesign、按钮、表单或操作控件。
- 完整查询语言、report archive 或 export 系统。
- order-level command、risk control command、position management command、OMS、真实订单提交 / 撤销 / 替换。
- SQLite / DuckDB schema、SQL、ORM model、runtime object、Persistence adapter direct read 或 adapter request 暴露。
- broker / exchange side effect、signed endpoint、account endpoint、listenKey 或 Live execution。

## MTP-52 Dashboard / Workbench shell 增量扩展

日期：2026-05-20

执行者：Codex

当前产品面把 Paper workflow control shell、observability read model 和 Event Timeline / Evidence Explorer 子集增量呈现在现有 Dashboard / Workbench shell 中，不做完整 UI redesign。

Shell 新增展示：

- session-level local controls：`start` / `pause` / `close` / `reset`。
- Paper workflow observability sections、session status、allowed / blocked evidence、replay freshness 和 report artifact status。
- Event Timeline / Evidence Explorer preview，包括 timeline item count、evidence link count、selected sections、read-only filter 和前若干 timeline rows。
- Dashboard smoke 继续保留八个原有 Dashboard sections，并新增 workbench read-model-only evidence。

仍不包含：

- 真实交易按钮、表单、order submit / cancel / replace 或 order-level command。
- Runtime command、完整 operations console、完整 query language、report archive 或 export 系统。
- SQLite / DuckDB schema、SQL、ORM model、runtime object、Persistence adapter direct read 或 adapter request 暴露。
- broker / exchange side effect、signed endpoint、account endpoint、listenKey 或 Live execution。

## MTP-54 Market Data Replay Operations 边界

日期：2026-05-20

执行者：Codex

当前产品面新增 market data replay operations 的第一层边界定义，但不新增 Dashboard UI、operations console、真实历史下载器或生产调度器。

边界覆盖：

- Binance public read-only market data batch / replay boundary。
- 最小 batch / replay metadata 字段：batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- required validation 固定为 mock transport、fixture parity 和 local batch replay。
- 真实 Binance public network smoke test 只能作为 optional manual evidence。

仍不包含：

- 真实长周期历史下载器、production scheduler、多节点运行或云端数据湖。
- Dashboard / Workbench UI 扩展、Event Timeline evidence 接入或 read model 输出。
- SQLite / DuckDB schema、runtime object 或 adapter request 暴露。
- signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。

## MTP-55 Market Data Replay Metadata / Batch Replay Contract

日期：2026-05-20

执行者：Codex

当前产品面新增本地 replay operations metadata 和 batch replay contract，但仍不新增 Dashboard UI、operations console、真实历史下载器或生产调度器。

边界覆盖：

- 本地 replay operations metadata：batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- batch replay contract：metadata 绑定 MTP-54 public read-only boundary，并固定 required fields、required validation mode、optional validation mode 和 forbidden capability。
- deterministic fixture：BTCUSDT / 1m / 单条本地 fixture，用于 Codable equality、contract completeness 和 forbidden field surface validation。
- required validation 继续固定为 mock transport、fixture parity 和 local batch replay，不依赖真实 Binance 网络。

仍不包含：

- 真实长周期历史下载器、production scheduler、多节点运行或云端数据湖。
- retention policy、freshness read model、fixture parity hardening、event log / projection consistency 或 read-model evidence 接入。
- Dashboard / Workbench UI 扩展、Event Timeline evidence 接入或 operations console。
- SQLite / DuckDB schema、runtime object 或 adapter request 暴露。
- signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。

## MTP-56 Market Data Replay Retention / Freshness Evidence

日期：2026-05-20

执行者：Codex

当前产品面新增本地 retention / freshness evidence read model，让 market data replay operations 可以以稳定 read model 表达本地 batch 是否 retained、stale、expired 或 not retained。

边界覆盖：

- 最小 retention policy：policy id、stale window、expires window、retention window 和本地保留开关。
- freshness status：`fresh`、`stale`、`expired`、`not retained`。
- freshness evidence read model：batch / replay metadata、policy 摘要、batch age、retention evidence、required validation local-only 和 read-model-only boundary flags。
- batch freshness summary：聚合 fresh / stale / expired / not retained / retained batch ids，供后续 Report / Dashboard / Event Timeline 只读消费。

仍不包含：

- 完整 retention engine、生产清理任务、云端 archive、storage tiering、多节点运行或数据湖。
- event log / projection consistency 串联、fixture parity hardening 或 Dashboard UI 接入。
- SQLite / DuckDB schema、runtime object、adapter request 或 persistence adapter direct read。
- signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。

## MTP-57 Market Data Replay Fixture Parity / Replay Consistency

日期：2026-05-20

执行者：Codex

当前产品面新增本地 fixture parity / replay consistency evidence，但仍不新增 Dashboard UI、operations console、真实历史下载器或 production replay operations。

边界覆盖：

- deterministic replay output summary：从本地 replayed `MarketBar` records 生成稳定 summary。
- metadata consistency：record count、symbol、interval、time window 与 batch replay metadata 对齐。
- record ordering：replay records 必须按 interval start 严格递增，乱序 output 被拒绝。
- checksum / parity hint：由本地 replay output 计算并与 metadata checksum / parity hint 匹配。
- network independence：required validation 继续固定为 mock transport、fixture parity 和 local batch replay。

仍不包含：

- 真实 Binance 网络 required validation、真实长周期历史下载器或 production scheduler。
- event log / projection consistency 串联、Dashboard / Report / Event Timeline evidence 接入。
- 数据质量平台、生产数据修复、多节点运行或云端数据湖。
- SQLite / DuckDB schema、runtime object 或 adapter request 暴露。
- signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。

## MTP-58 Market Data Replay Event Log / Projection Consistency

日期：2026-05-20

执行者：Codex

当前产品面新增本地 replay event log / projection snapshot consistency evidence，但仍不新增 Dashboard UI、Report 页面、Event Timeline 接入或 operations console。

边界覆盖：

- replay metadata、freshness evidence 和 deterministic fixture parity evidence 对齐。
- append-only `.market` event log sequence 与 replay result sequence 一致。
- event log 中的 `MarketBar` summary 与 replay output summary 一致。
- cache snapshot 和 DuckDB analytical projection snapshot 均由同一 replay command 重建，并与 replay output summary 一致。
- market-only replay 保持 SQLite runtime projection 空快照。
- projection consistency summary 只作为 read-model-only evidence，供后续 Report / Dashboard / Event Timeline issue 消费。

仍不包含：

- Dashboard / Workbench UI 扩展、Report 接入、Event Timeline 接入或完整 operations console。
- 完整数据库 schema 设计、migration framework、生产数据管线或 production scheduler。
- SQLite / DuckDB schema、SQL、ORM model、runtime object、adapter request 或 persistence adapter direct read 暴露。
- signed endpoint、account endpoint、listenKey、broker action、Live trading 或真实订单提交 / 撤销 / 替换。

## MTP-59 Market Data Replay Report / Dashboard / Event Timeline Evidence

日期：2026-05-20

执行者：Codex

当前产品面把 market data replay operations、retention / freshness evidence 和 event log / projection consistency summary 接入 Report、Dashboard 和 Event Timeline 的只读展示层。该接入只消费 App 层 read model，不做完整 UI redesign，也不形成 production operations console。

新增观察面：

- Report evidence：展示 replay operations evidence count、batch id、replay run id、freshness status、retention status、event log record count、replayed record count 和 projection consistency summary。
- Dashboard Report section：新增 `Replay ops` 指标和 replay operation details。
- Event Timeline / Evidence Explorer：新增 `market data replay operation` 分区，用于展示 batch / replay / freshness / retention / projection consistency evidence item。
- Boundary evidence：保留 read-model-only、public read-only、local fixture replay、required validation local-only、no schema、no runtime object、no adapter request 和 no trading authorization flags。

仍不包含：

- 完整 UI redesign、生产运营控制台、数据质量平台或可变 query language。
- Runtime command、projection rebuild command、retention cleanup、真实历史下载器或 production scheduler。
- SQLite / DuckDB schema、SQL、ORM model、runtime object、adapter request 或 persistence adapter direct read 暴露。
- 按钮、表单、order-level command、broker action、signed endpoint、account endpoint、listenKey、Live trading 或真实订单提交 / 撤销 / 替换。

## MTP-66 Live blocked evidence Dashboard / Report / Event Timeline 展示面

日期：2026-05-21

执行者：Codex

当前产品面把 Live trading foundation 的 blocked gates 接入 Report、Dashboard 和 Event Timeline 的只读展示层。该接入只消费 App 层 read model，不做实盘监控台、实盘执行控制、实盘风险控制或实盘审计 / 停机控制。

新增观察面：

- Report evidence：展示 Live blocked evidence count、blocked capabilities、gate labels、source anchors、readiness status 和 read-model-only boundary。
- Dashboard Report section：新增 `Live gates` 指标和 Live blocked details。
- Dashboard Workbench：新增 `Live Blocked Gates` 只读 detail group，展示 blocked count、status、capabilities 和 no command / no Live authorization evidence。
- Event Timeline / Evidence Explorer：新增 `live trading blocked evidence` 分区，用于展示 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle blocked evidence item。
- Dashboard smoke：新增 `liveBlockedGates=6` evidence，同时保留八个 Dashboard sections、readModelOnly=true、workbenchReadModelOnly=true 和 session-level controls。

仍不包含：

- 实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制。
- live command、交易按钮、表单、order-level command、risk control command、position management command。
- API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、real order lifecycle、真实订单提交 / 撤销 / 替换或真实交易授权。
- SQLite / DuckDB schema、SQL、ORM model、Runtime object、adapter request 或 persistence adapter direct read 暴露。

## MTP-80 Execution-control blocked evidence Dashboard / Report / Event Timeline 展示面

日期：2026-05-22

执行者：Codex

当前产品面把 Live Execution Control Contract 的 blocked evidence 接入 Report、Dashboard 和 Event Timeline 的只读展示层。该接入只消费 MTP-79 `LiveExecutionControlBlockedEvidence` 的 App read model / ViewModel，不做实盘执行控制台、order form、交易按钮或真实订单命令。

新增观察面：

- Report evidence：展示 execution-control blocked gate count、blocked gate labels、blocked reason labels、source anchors、deterministic snapshot、all-gates-blocked 和 read-model-only boundary。
- Dashboard Report section：新增 `Execution control` 指标和 execution-control no command / no order form / no trading button / no schema / no runtime / no adapter details。
- Dashboard Workbench：新增 `Live Execution Control` 只读 detail group，展示 execution gate count、unique blocked reason count、blocked confirmation 和 read-model-only boundary。
- Event Timeline / Evidence Explorer：新增 `live execution control blocked evidence` 分区，为 submit、cancel、replace、execution report、broker fill、reconciliation 和 incident fallback 生成只读 timeline item / evidence link。
- Dashboard smoke：新增 `liveExecutionControlGates=7` evidence，同时保留八个 Dashboard sections、readModelOnly=true、workbenchReadModelOnly=true、session-level controls、Live blocked gates 和 Live monitoring evidence。

仍不包含：

- API key、secret storage、signed endpoint、account endpoint、listenKey。
- broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS。
- 真实订单 submit / cancel / replace、signed command request、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation。
- live command、交易按钮、order form、order-level command UI、risk control command 或 position management command。
- SQLite / DuckDB schema、SQL、ORM model、Runtime object、adapter request 或 persistence adapter direct read 暴露。

## MTP-68 Live monitoring console information architecture

日期：2026-05-21

执行者：Codex

当前产品面新增 Live monitoring console information architecture 合同，但不实现实盘 runtime、连接器、stream collector、UI redesign、交易按钮或 live command。主合同入口是 `docs/contracts/live-monitoring-console-contract.md`。

`MTP-68-LIVE-MONITORING-CONSOLE-IA`

后续实盘监控台的信息架构必须覆盖：

- Overview：read-model-only readiness、blocked gates 和 operations evidence 总览。
- Runtime Health：future live runtime health status、updatedAt、source anchor。
- Connection：connection status、stale / error evidence、future private connection gate。
- Market Stream：public read-only market stream status、freshness 和 latency evidence。
- Order Stream Evidence：blocked / simulated / future order stream evidence，不表示真实订单状态机。
- Latency：latency bucket、freshness、stale evidence。
- Error / Degraded State：error summary、degraded scope、recovered evidence。
- Operations Evidence：validation、handoff、Stage Audit input、known boundary 和 readiness evidence chain。

仍不包含：

- live runtime、signed endpoint、account endpoint、listenKey、private WebSocket、broker adapter、exchange execution adapter 或 `LiveExecutionAdapter`。
- real order state machine、execution report、broker fill、order reconciliation、OMS、真实账户状态或 broker position sync。
- Dashboard / Workbench UI redesign、按钮、表单、live command、order-level command、submit / cancel / replace、risk control command、position management command 或自动恢复动作。
- Runtime object、adapter request、SQLite / DuckDB schema、SQL、ORM model 或 persistence adapter direct read 暴露。
- `checks/automation-readiness.sh` 的 MTP-68 机械收口；该收口保留给 MTP-74。

## MTP-72 Dashboard / Report live monitoring evidence 区块

日期：2026-05-21

执行者：Codex

当前产品面把 MTP-69 / MTP-70 / MTP-71 的 live monitoring evidence 接入 Report 和 Dashboard 的只读展示层。该接入只消费 App 层 read model，不做完整实盘监控台 redesign，不提供 live command 或交易按钮。

新增观察面：

- Report evidence：展示 runtime health status、connection statuses、market / order stream evidence count、latency buckets、error codes、degraded states 和 read-model-only boundary。
- Dashboard Report section：新增 `Monitoring` 指标和 monitoring details。
- Dashboard Workbench：新增 `Live Monitoring` 只读 detail group，展示 health、connections、streams、latency、errors、degraded counts 和 no command / no schema / no adapter / no runtime evidence。
- Dashboard smoke：新增 `liveMonitoringHealth=blocked` 和 `liveMonitoringErrors=3` evidence，同时保留八个 Dashboard sections、readModelOnly=true、workbenchReadModelOnly=true、session-level controls、timelineItems 和 liveBlockedGates。

仍不包含：

- 完整实盘监控台页面重设计、实盘执行控制、实盘风险控制或停机控制。
- live command、交易按钮、表单、order-level command、risk command、position command、alert / paging / reconnect / stop control、incident command 或自动恢复动作。
- production telemetry、runtime profiler、external metrics service、真实 runtime monitoring 或真实网络连接。
- signed endpoint、account endpoint、listenKey、API key、secret、account payload、broker adapter、`LiveExecutionAdapter`、execution report、broker fill、real order state machine、OMS 或真实交易授权。
- Runtime object、adapter request、SQLite / DuckDB schema、SQL、ORM model 或 persistence adapter direct read 暴露。

## MTP-73 Event Timeline live monitoring evidence preview

日期：2026-05-21

执行者：Codex

当前产品面把 MTP-69 / MTP-70 / MTP-71 的 live monitoring evidence 接入 Event Timeline / Evidence Explorer 的只读预览。该接入复用 App 层 `LiveMonitoringEvidenceReadModel`，不做完整实盘监控台 redesign，不提供 live audit、incident replay 或 stop control。

新增观察面：

- Event Timeline / Evidence Explorer：新增 `live monitoring evidence` 分区，展示 runtime health、connection、market / order stream、latency、error 和 degraded state timeline rows。
- Evidence links：每条 monitoring timeline row 只保留 evidence ID、label 和 source sequence，供 read-only navigation 使用。
- Dashboard / Workbench preview：全量 fixture `timelineItems=42`，其中 live monitoring evidence 分区 18 条；空启动 snapshot 仍展示静态 Live blocked / Live monitoring evidence，`timelineItems=24`。

仍不包含：

- live command、交易按钮、表单、order-level command、risk command、position command、alert / paging / reconnect、incident command、auto recovery、live audit、incident replay 或 stop control。
- production telemetry、runtime profiler、external metrics service、真实 runtime monitoring、真实网络连接或 WebSocket。
- signed endpoint、account endpoint、listenKey、API key、secret、account payload、broker adapter、`LiveExecutionAdapter`、execution report、broker fill、real order state machine、OMS 或真实交易授权。
- Runtime object、adapter request、SQLite / DuckDB schema、SQL、ORM model 或 persistence adapter direct read 暴露。

## MTP-78 paper / real command isolation product surface

日期：2026-05-22

执行者：Codex

当前产品面把 paper order intent、paper execution decision、simulated fill 和 paper portfolio projection 继续限制在 Report / Dashboard / Event Timeline 的只读 evidence 展示中。MTP-78 只定义 paper evidence 与 future real order command 的隔离合同，不新增执行控制台、order form、order-level command UI 或交易按钮。

新增观察面：

- Report evidence：继续展示 paper execution workflow decision IDs、paper order IDs、simulated fill IDs、portfolio update IDs 和 paper-only boundary。
- Dashboard / Workbench：继续展示 session-level local paper controls 和 read-model-only evidence group；`start` / `pause` / `close` / `reset` 仍只表示本地 paper session-level presentation。
- Event Timeline / Evidence Explorer：继续展示 `paper order`、`simulated fill` 和 `portfolio projection` 分区的 evidence links，不提供 real order command、query language 或 Runtime command。

仍不包含：

- real order command、submit / cancel / replace、signed command request、order form、order-level command UI、live command 或交易按钮。
- execution report ingestion、broker fill event fact、reconciliation runtime、account sync、real account balance read 或 broker position sync。
- signed endpoint、account endpoint、listenKey、API key、secret、account payload、broker adapter、`LiveExecutionAdapter`、real order state machine、OMS 或真实交易授权。
- Runtime object、adapter request、SQLite / DuckDB schema、SQL、ORM model 或 persistence adapter direct read 暴露。

## MTPRO Workbench User Flow Blueprint v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

当前产品层新增 `MTPRO Workbench User Flow Blueprint v1`，路径为 `docs/product/mtpro-workbench-user-flow-blueprint-v1.md`。该文档记录 Figma canonical `15:2` 的用户动线蓝图，作为后续 Workbench / Dashboard / UI planning 的产品层输入。

该蓝图只定义：

- 目标用户。
- 六条用户动线。
- 页面角色。
- Current completed / Completed read-model-only evidence surfaces / Future Gated 分区。
- 禁止动作和 read-model-only 边界。

该蓝图不定义：

- 最终视觉风格。
- UI 组件规范。
- macOS 高保真界面。
- SwiftUI 实现方式。
- Linear execution scope。

产品层页面角色：

| 页面 | 用户判断 |
| --- | --- |
| 总览 / Overview | 今天系统状态、latest evidence、blocker 和下一步路径是否清楚 |
| 行情回放 / Market Replay | batch、retention、freshness 和 replay consistency 是否可信 |
| 策略研究 / Research | 策略输入、配置、signal evidence 和研究 run 是否可信 |
| 回测 / Backtest | parity、cost、risk、输入快照和 replay evidence 是否满足进入报告或 Paper 的条件 |
| 报告 / Report | Research / Backtest / Paper / Risk / Portfolio evidence 是否能形成可追溯结论 |
| Paper 模拟执行 / Paper | paper-only session、intent、simulated fill 和 session-level local control 语义是否一致 |
| 组合 / Portfolio | paper exposure 和 portfolio projection 是否可解释 |
| 风险 / Risk | blocker、rejection reason、paper-only risk evidence 和 future live gate 是否清楚 |
| 事件与审计 / Events / Audit | 是否能沿 event timeline、replay、projection freshness 和 evidence links 回溯 |
| 实盘准备度 / Live Readiness | API key、signed endpoint、account endpoint、listenKey、broker adapter、real order lifecycle 为什么 blocked |
| 实盘监控台 / Live Monitoring | 已完成的 read-model-only health、connection、stream、latency、error、degraded evidence；不代表真实 live runtime |
| 未来门禁区 / Future Gated | Future Live Execution / Risk / Incident Replay 的 planning / boundary placeholder，不授权执行 |

仍不包含：

- 真实交易按钮、order form、live command 或 order-level command UI。
- API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter 或 `LiveExecutionAdapter`。
- real order state machine、OMS、submit / cancel / replace、broker fill、execution report 或 reconciliation。
- Runtime、Adapter、SQLite / DuckDB schema、exchange payload 或 broker object 直连 UI。

## MTPRO Product Interaction Model v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 Human 提供的 `@003 / PRD` 草案落仓）

当前产品层新增 `MTPRO Product Interaction Model v1`，路径为 `docs/product/mtpro-product-interaction-model-v1.md`。该文档承接 `MTPRO Workbench User Flow Blueprint v1`，用于定义用户在每个页面能看什么、判断什么、点什么、不能点什么，以及页面之间如何通过 evidence navigation 串联。

该交互模型用于指导后续 `@004 / DSG` 的 `Workbench Screen Layout v1`，不是最终 UI/UX 规范、视觉稿、组件规范或 SwiftUI 实现稿。

交互模型覆盖：

- 全局交互原则：evidence navigation 优先、中文优先、页面只消费 ViewModel / Read Model / Command Model。
- 状态语言：`empty`、`healthy`、`stale`、`blocked`、`degraded`、`error`。
- 页面级交互模型：Overview、Market Replay、Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness、Live Monitoring、Future Gated 和三类 Future placeholder。
- 六条核心动线的交互规则：今日状态检查、策略研究到回测、回测到报告、Paper session 观察、异常追溯、Live readiness / monitoring 判断。
- 控制面边界：read-only evidence interaction、local paper session-level control、blocked / unavailable future action、forbidden live trading action。
- Live Monitoring 和 Future Gated 的交互边界。

仍不包含：

- 最终视觉风格、macOS 高保真 UI、组件规范或 SwiftUI 实现。
- Linear Project / Issue、Todo 推进、Symphony 启动或业务代码 scope。
- submit / cancel / replace、order form、broker action、signed endpoint、account endpoint / listenKey、reconnect / start live / stop live、live command、trading button、real order state machine、real account balance 或 real broker position。

## MTPRO Workbench Screen Layout v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

当前设计层新增 `MTPRO Workbench Screen Layout v1`，路径为 `docs/design/mtpro-workbench-screen-layout-v1.md`。该文档记录 Figma canonical `40:2`，承接产品用户动线和产品交互模型，用于定义 macOS 工作台 screen layout、页面区域、信息优先级、状态表达和禁止动作。

该文档是设计层 screen layout 依据，不是最终 UI / UX 规范、视觉稿、组件规范或 SwiftUI 实现。

统一 screen layout 结构：

- Sidebar / 主导航。
- Top status / session summary。
- Main evidence workspace。
- Detail inspector。
- Events / Audit timeline preview。
- Status / blocked / degraded / error presentation。
- Future Gated placeholder area。

覆盖页面：

- Overview、Market Replay、Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness、Live Monitoring、Future Gated、Future Live Execution、Future Live Risk、Future Incident Replay / Stop Controls。

`@005 / ARC` 复审结论：通过。P1 文案 `future gate opened` 已修正为 `future gate reviewed`，相关 `opened` 文案已统一改为 `linked` / `reviewed`，避免 Future Gated 被误读为已授权或已打开。

仍不包含：

- 最终视觉风格、macOS 高保真 UI、组件规范或 SwiftUI 实现。
- Linear Project / Issue、Todo 推进、Symphony 启动或业务代码 scope。
- submit / cancel / replace、order form、broker action、signed endpoint、account endpoint / listenKey、reconnect / start live / stop live、live command、trading button、real order state machine、real account balance 或 real broker position。

## MTPRO Workbench UI/UX Design Rules v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

当前设计层新增 `MTPRO Workbench UI/UX Design Rules v1`，路径为 `docs/design/mtpro-workbench-ui-ux-design-rules-v1.md`。该文档记录 Figma canonical `51:2`，承接 Product User Flow Blueprint、Product Interaction Model 和 Screen Layout v1，用于定义 macOS native 工作台的 UI/UX 设计规则。

该文档是设计层 UI/UX rules 依据，不是高保真最终视觉稿、组件规范或 SwiftUI 实现。

规则覆盖：

- macOS native workstation 视觉方向：克制、紧凑、split-view、sidebar、detail inspector 和 timeline preview。
- 统一布局规则：Sidebar、Top status、Main evidence workspace、Detail inspector、Events / Audit preview 和 Future placeholder area。
- Typography / spacing / density：工作台密度、文字层级、状态标签和中文优先表达。
- Evidence components：evidence row、card、table、inspector、source link 和 timeline preview。
- 状态标签：`empty`、`healthy`、`stale`、`blocked`、`degraded`、`error`。
- 三态分区：Current completed、Completed read-model-only evidence surface、Future Gated。
- Paper 本地 session-level controls：只允许 `start` / `pause` / `close` / `reset`，且视觉权重必须弱于 evidence navigation。
- Live Monitoring：Complete / read-model-only evidence surface，只展示 health / connection / stream / latency / error / degraded evidence，不表达外部运行时控制。
- Future Gated：planning / boundary placeholder，不是执行授权，不创建规划或施工入口。
- Forbidden UI Surface Checklist：API key / secret storage input、signed endpoint、account endpoint / listenKey、broker adapter / broker action、`LiveExecutionAdapter`、real order state machine / OMS、submit / cancel / replace、broker fill / execution report / reconciliation、real account balance / broker position、trading button / live command / order-level command UI 均禁止出现在当前 UI surface。

`@005 / ARC` 审查结论：通过。P0 / P1 / P2 均未发现问题。

仍不包含：

- 高保真最终视觉稿、组件规范或 SwiftUI 实现。
- Linear Project / Issue、Todo 推进、Symphony 启动或业务代码 scope。
- submit / cancel / replace、order form、broker action、signed endpoint、account endpoint / listenKey、reconnect / start live / stop live、live command、trading button、real order state machine、real account balance 或 real broker position。

## MTPRO Workbench Component / Layout Specification v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

当前设计层新增 `MTPRO Workbench Component / Layout Specification v1`，路径为 `docs/design/mtpro-workbench-component-layout-specification-v1.md`。该文档记录 Figma canonical `57:2`，承接 Product User Flow Blueprint、Product Interaction Model、Screen Layout v1 和 UI/UX Design Rules v1，用于定义 macOS native 工作台的组件 / 布局规格。

该文档是设计层组件 / 布局规格依据，不是高保真最终视觉稿、SwiftUI 实现或 Linear execution 授权。

规格覆盖：

- Layout primitives：Sidebar、Top status、Main evidence workspace、Detail inspector、Events / Audit preview、Future placeholder area。
- Evidence components：evidence row、evidence card、evidence table、source link、blocked reason panel、inspector section、timeline preview row。
- State components：`empty`、`healthy`、`stale`、`blocked`、`degraded`、`error`。
- Partition components：Current completed、Completed read-model-only evidence surface、Future Gated。
- Paper local session controls：只允许 `start` / `pause` / `close` / `reset`，且视觉权重弱于 evidence navigation。
- Live Monitoring read-only evidence components：health / connection / stream / latency / error / degraded。
- Future Gated placeholder：planning / boundary placeholder、不是执行授权、不创建规划或施工入口。
- Sizing / spacing / density tokens：服务高频扫描和稳定布局，不做营销式大留白。

`@005 / ARC` 审查结论：通过。P0 / P1 / P2 均未发现问题。

禁止 UI Surface 检查结果：无 API key / secret storage input、无 signed endpoint、无 account endpoint / listenKey、无 broker adapter / broker action、无 `LiveExecutionAdapter`、无 real order state machine / OMS、无 submit / cancel / replace、无 broker fill / execution report / reconciliation、无 real account balance / broker position、无 trading button / live command / order-level command UI、无 reconnect / start live / stop live。

仍不包含：

- 高保真最终视觉稿、SwiftUI 实现或业务代码开发。
- Linear Project / Issue、Todo 推进、Symphony 启动或 Future Live trading execution scope。
- submit / cancel / replace、order form、broker action、signed endpoint、account endpoint / listenKey、reconnect / start live / stop live、live command、trading button、real order state machine、real account balance 或 real broker position。

## MTPRO Workbench Visual Style Direction v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

当前设计层新增 `MTPRO Workbench Visual Style Direction v1`，路径为 `docs/design/mtpro-workbench-visual-style-direction-v1.md`。该文档记录 Figma canonical `64:2`，承接 Product User Flow Blueprint、Product Interaction Model、Screen Layout v1、UI/UX Design Rules v1 和 Component / Layout Specification v1，用于定义 macOS native 专业交易工作台的视觉方向、色彩语义、typography、density、核心组件视觉样例和关键页面视觉样例。

该文档是设计层视觉方向依据，不是最终高保真 UI、组件库、SwiftUI 实现或 Linear execution 授权。

视觉方向覆盖：

- macOS native professional workstation。
- evidence-first。
- compact / dense but readable。
- restrained visual language。
- 中文优先，英文作为技术别名。
- 不是 Web SaaS dashboard。

设计语义覆盖：

- 色彩语义：neutral surface、evidence emphasis、healthy、stale、blocked、degraded、error、Future Gated、read-model-only。
- 状态不能只靠颜色，必须配合中文标签、原因和 source。
- Typography hierarchy：page title、section title、evidence row title、metadata / trace id、status label、warning / blocked copy。
- Density：sidebar density、top status density、evidence table density、inspector density、timeline preview density。
- 核心组件视觉样例：evidence row、evidence card、evidence table、status label、blocked reason panel、detail inspector section、timeline preview row、Future Gated placeholder。
- 关键页面视觉样例：Overview、Paper、Live Monitoring、Future Gated。

`runtime health: blocked` 这类文案是 read-model evidence label，不是底层 Runtime object。

`@005 / ARC` 复审结论：通过。P0 / P1 均未发现，P2 无阻断项。

禁止 UI Surface 检查结果：无 API key / secret storage input、无 signed endpoint、无 account endpoint / listenKey、无 broker adapter / broker action、无 `LiveExecutionAdapter`、无 real order state machine / OMS、无 submit / cancel / replace、无 broker fill / execution report / reconciliation、无 real account balance / broker position、无 trading button / live command / order-level command UI、无 reconnect / start live / stop live。

仍不包含：

- 最终高保真 UI、组件库、SwiftUI 实现或业务代码开发。
- Linear Project / Issue、Todo 推进、Symphony 启动或 Future Live trading execution scope。
- submit / cancel / replace、order form、broker action、signed endpoint、account endpoint / listenKey、reconnect / start live / stop live、live command、trading button、real order state machine、real account balance 或 real broker position。

## MTPRO Workbench User Dashboard Content Model v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 Human 提供的 `@003 / PRD` 草案落仓）

当前产品层新增 `MTPRO Workbench User Dashboard Content Model v1`，路径为 `docs/product/mtpro-workbench-user-dashboard-content-model-v1.md`。该文档承接 Product User Flow Blueprint、Product Interaction Model 和已落仓的设计层依据，用于把 Workbench 从 evidence-heavy 页面校正为用户每天可用的专业交易工作台内容模型。

该文档是产品层 dashboard content model，不是 UI 设计稿、组件规范、SwiftUI 实现稿或 Linear execution 授权。

产品 / 设计依据链路：

```text
Product User Flow Blueprint v1
-> Product Interaction Model v1
-> User Dashboard Content Model v1
-> User-Facing Dashboard High-Fidelity v2
```

Content Model 覆盖：

- 用户面板原则：主屏先给结论，再给证据入口；主屏展示用户可读 summary；source / trace / timeline 下沉到 inspector、drill-down 或 Events / Audit。
- Overview Content Model：今日工作台状态、数据新鲜度、最新研究结论、Paper 观察状态和 Live 状态五个核心状态。
- 页面内容模型：Market Replay、Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness、Live Monitoring、Future Gated 的主屏内容、主指标、inspector、timeline 和禁止动作。
- Content Priority Matrix：区分主屏、inspector、timeline、docs / source anchor 和完全不展示的内容。
- Figma `69:*` 修正建议：`69:*` 只作为 architecture-safe draft 参考，不作为最终用户面板设计依据；后续需要重画为 `User-Facing Dashboard High-Fidelity v2`。

仍不包含：

- Figma 修改或高保真重画本身。
- 最终视觉稿、组件规范、SwiftUI 实现或业务代码开发。
- Linear Project / Issue、Todo 推进、Symphony 启动或 Future Live trading execution scope。
- submit / cancel / replace、order form、broker action、signed endpoint、account endpoint / listenKey、reconnect / start live / stop live、live command、trading button、real order state machine、real account balance 或 real broker position。

## MTPRO Workbench User-Facing Dashboard High-Fidelity v2

日期：2026-05-22

执行者：Codex（`@000 / AIE`）

当前设计层新增 `MTPRO Workbench User-Facing Dashboard High-Fidelity v2`，路径为 `docs/design/mtpro-workbench-user-facing-dashboard-high-fidelity-v2.md`。该文档记录 Figma canonical `85:2`，承接 `MTPRO Workbench User Dashboard Content Model v1`，用于定义更接近最终用户每天使用的 Workbench dashboard 高保真关键页面。

该文档是设计层用户面 dashboard 高保真关键页面依据，不是 Live PRO Console，不是实盘操作台，不是 SwiftUI 实现或 Linear execution 授权。

Figma `85:*` 覆盖页面：

- Overview。
- Market Replay。
- Research。
- Backtest。
- Report。
- Paper。
- Portfolio。
- Risk。
- Events / Audit。
- Live Readiness。
- Live Monitoring。
- Future Gated。

v2 设计重点：

- 从 evidence-heavy 改为用户可读 dashboard。
- 主屏先给今日状态、下一步建议、最新报告、数据状态、Paper 状态、Live readiness / monitoring summary。
- 每页主屏保留 3-5 个用户判断指标。
- source、reason、trace id、validation anchor 下沉到 Detail inspector。
- 完整 event sequence / route 由 Events / Audit 承担。
- Future Gated 从 boundary list 改成边界解释面，不是执行授权、项目入口或施工入口。

`@005 / ARC` 审查结论：通过。P0 / P1 均未发现；P2 仅建议后续 SwiftUI 实现时拉开底部状态语义 strip 与最近异常摘要的间距，避免小屏或字体缩放下拥挤。

仍不包含：

- SwiftUI 实现、组件库实现或业务代码开发。
- Live PRO Console、实盘操作台或真实 Live trading execution scope。
- Linear Project / Issue、Todo 推进、Symphony 启动。
- API key / secret storage input、signed endpoint、account endpoint / listenKey、broker adapter / broker action、`LiveExecutionAdapter`、real order state machine / OMS。
- submit / cancel / replace、order form、broker fill、execution report、reconciliation、real account balance、broker position、trading button、live command、order-level command UI、reconnect / start live / stop live。

## MTPRO Product Surface Split v1

日期：2026-05-22

执行者：Codex（`@000 / AIE`，基于 `@003 / PRD` 草案和 `@005 / ARC` 审查结论落仓）

当前产品层新增 `MTPRO Product Surface Split v1`，路径为 `docs/product/mtpro-product-surface-split-v1.md`。该文档是产品层 surface boundary 文档，用于明确当前 `MTPRO Workbench` 与未来 `MTPRO Live PRO Console` 是两个产品面。

核心分界：

- `MTPRO Workbench` 是当前产品面，承载 Research、Backtest、Report、Paper、Portfolio、Risk、Events / Audit、Live Readiness 和 read-model-only Live Monitoring。
- `MTPRO Live PRO Console` 是未来产品面，只有经过 Human decision、独立 Project Definition、signed / account / broker / risk / ops gates 后，才允许进入 IA / UI / implementation。
- Figma `85:*` 只代表 Workbench 用户面 dashboard，不代表 Live PRO Console 或实盘操作台。
- 两个产品面可以共享 `Shared Evidence Semantics / Shared Evidence Contract`，包括 evidence semantics、read model contract、report artifact 和 audit route；不能共享 command surface、direct Event Log write access、live runtime、broker adapter、signed API、account stream、listenKey、OMS、real order state machine、real broker position 或 emergency stop command。

该文档为后续产品 / 设计审查提供以下判断依据：

- Workbench dashboard 不应被画成 trading terminal。
- Paper / evidence UI 不能升级成实盘控制。
- read-model-only monitoring 不能被解释成 live runtime 操作台。
- Future Live PRO Console 必须另开产品面和独立 planning，不复用 Workbench 页面作为实盘控制台。

仍不包含：

- Figma 修改、SwiftUI 实现、组件库实现或业务代码开发。
- Linear Project / Issue、Todo 推进、Symphony 启动或 Future Live trading execution scope。
- Live PRO Console 当前可实现授权、实盘操作台授权、真实账户 / 真实订单 / broker / OMS / emergency stop 能力。
