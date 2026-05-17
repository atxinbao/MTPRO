# Module Boundary

本文档定义 MTPRO 第一版模块边界。

## Core

职责：

- 领域事件
- 命令
- 状态模型
- Kernel / Engine 边界
- 策略、风险、组合的核心接口

不负责：

- Binance 网络调用
- SQLite / DuckDB adapter
- SwiftUI View

## Adapters

职责：

- 外部 read-only market data adapter 边界。
- Binance public endpoint mapping。
- Binance public read-only client / transport boundary。

不负责：

- signed endpoint
- account endpoint
- order submit
- listenKey user data stream
- DataEngine ingest 串联
- 策略判断

## Persistence

职责：

- Event Log 边界。
- SQLite projection 边界。
- DuckDB analytical projection 边界。

不负责：

- 直接驱动 UI。
- 直接执行策略。

## Runtime

职责：

- 串联 Binance public read-only client boundary。
- 调用 Core TradingKernel / DataEngine 写入 append-only market event stream。
- 通过 FileEventLogStore 和 PersistenceReplayBoundary 做 replay。
- 输出稳定 SQLite runtime projection snapshot 和 DuckDB analytical projection snapshot。

不负责：

- SwiftUI 页面。
- 真实 Binance 网络 smoke test 的 required validation。
- signed endpoint、account endpoint、listenKey user data stream。
- broker action、真实订单行为或 Live execution。
- 暴露 SQLite / DuckDB schema 给 UI。

## App

职责：

- SwiftUI 产品面。
- ViewModel 输入契约。
- 人类可观察状态。

不负责：

- 直接消费数据库表。
- 直接访问 Binance。
- 执行交易。
