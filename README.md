# MTPRO

MTPRO 是用于重构 `macos-trader` 的新独立 macOS 交易研究工作台项目。

本项目参考 `nautilus_trader` 的 Kernel / MessageBus / Cache / Engine / Adapter 架构思想，但不引入 NautilusTrader 作为运行依赖，也不复制 `macos-trader` 整仓代码。

## 当前状态

当前仓库已完成 Project Definition、Bootstrap PR、Human review / merge、Linear Project setup 和 GitHub PR Automation setup。

已定义：

- 项目目标
- 架构边界
- 产品面
- contract-first 文档
- SwiftPM 最小模块骨架
- 本地验证入口
- Linear Project：`MTPRO 引导`
- 当前唯一 configured executable issue：`MTP-8`
- GitHub PR Automation：`checks` workflow、`protect-main`、squash merge、auto-merge、branch cleanup

未完成：

- Linear Agent formal mode
- Symphony Issue Automation 启动
- Graphify post-execution scoped update
- Binance 数据接入实现
- 策略实现
- 持久化 adapter
- macOS UI 实现

MTPRO 不创建单独的 test-mode onboarding Project / Issues。后续第一个真实 MTP-8 PR 同时承担 GitHub PR Automation 链路验证。

## 当前执行边界

MTPRO 已完成初始化和 Bootstrap 合并，不再走单独的 onboarding test。

当前项目级路径：

1. Human Project Planning：已完成，Linear Project / Issues 已创建。
2. Linear Project Automation：当前由人工确认 WIP=1，后续接 Linear Agent。
3. Symphony Issue Automation：尚未启动。
4. GitHub PR Automation：已配置，下一次真实 PR 验证。
5. Next Human Project Planning：当前 Project 全部 Done 后再进入。

Agent / Codex 只能执行当前唯一 configured executable Linear issue。`ROADMAP.md`、Linear Draft、Backlog issue、标签、priority、assignee 都不授权执行。

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
