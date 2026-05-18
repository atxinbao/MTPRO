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
- 可运行入口 `MTPRODashboard` 使用空 read model projection 作为安全启动快照。
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
