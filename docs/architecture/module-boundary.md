# Module Boundary

本文档定义 MTPRO 第一版模块边界。

## MTPROCore

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

## MTPROAdapters

职责：

- 外部 read-only market data adapter 边界。
- Binance public endpoint mapping。

不负责：

- signed endpoint
- account endpoint
- order submit
- 策略判断

## MTPROPersistence

职责：

- Event Log 边界。
- SQLite projection 边界。
- DuckDB analytical projection 边界。

不负责：

- 直接驱动 UI。
- 直接执行策略。

## MTPROApp

职责：

- SwiftUI 产品面。
- ViewModel 输入契约。
- 人类可观察状态。

不负责：

- 直接消费数据库表。
- 直接访问 Binance。
- 执行交易。
