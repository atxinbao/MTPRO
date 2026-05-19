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
