# MTPRO

MTPRO 是用于重构 `macos-trader` 的新独立 macOS 交易研究工作台项目。

本项目参考 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 架构思想，但不引入 NautilusTrader 作为运行依赖，也不复制 `macos-trader` 整仓代码。

## 当前状态

当前仓库处于 Project Definition / Bootstrap Skeleton 阶段。

已定义：

- 项目目标
- 架构边界
- 产品面
- contract-first 文档
- SwiftPM 最小模块骨架
- 本地验证入口

未完成：

- Human Review
- Linear Setup
- Automation Readiness
- Binance 数据接入实现
- 策略实现
- 持久化 adapter
- macOS UI 实现

因此当前不允许进入正式开发执行。

## 新项目引导边界

MTPRO 必须先完整走完新项目引导流程，才允许进入正式开发流程。

顺序：

1. Project Definition
2. Bootstrap PR
3. Human Review
4. Linear Setup
5. Automation Readiness

只有这些完成后，才允许进入：

```text
Symphony Preflight -> Codex Execution -> PR -> Authorized Merge -> Linear Done
```

在引导流程完成前，Agent / Codex 不得实现前端页面、后端 API、数据库 adapter、真实市场数据接入或业务功能。

## 第一版产品边界

第一版只做策略研究到 Paper 的一致性闭环。

- UI：最小观察和操作入口。
- Backtest / Paper：第一优先级。
- Live：完全禁止，不保留真实 broker action。
- 数据源：Binance public market data read-only。
- 策略：先做 EMA cross，再做 order book imbalance。
- 时间粒度：`1m` 和 `5m`。
- 标的：`BTCUSDT`、`ETHUSDT`、`BNBUSDT`、`SOLUSDT`、`XRPUSDT`。

## 模块

```text
Sources/
  MTPROCore/          领域模型、事件、Kernel 边界
  MTPROAdapters/      外部数据源 adapter 边界
  MTPROPersistence/   Event Log / SQLite / DuckDB 边界
  MTPROApp/           macOS 产品面和 ViewModel 边界

Tests/
  MTPROCoreTests/
  MTPROAdaptersTests/
  MTPROPersistenceTests/
  MTPROAppTests/
```

## 文档入口

- `GOAL.md`：项目目标。
- `ARCHITECTURE.md`：模块地图和边界。
- `ROADMAP.md`：阶段推进顺序。
- `docs/product/product-surface-map.md`：产品面。
- `docs/contracts/`：contract-first 输入。
- `docs/validation/validation-plan.md`：验证计划。
- `verification.md`：append-only 验证流水账。

## 本地验证

```bash
swift test
```

本地验证只证明当前 skeleton 可构建和基础边界测试通过，不代表业务实现完成。
