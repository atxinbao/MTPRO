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
