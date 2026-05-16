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
- 当前执行事项：不写死在仓库文档中，运行时以 Linear / symphony-project 中唯一 configured executable issue 为准
- GitHub PR Automation：`checks` workflow、`protect-main`、squash merge、auto-merge、branch cleanup

未完成：

- symphony-project continuation
- Binance 真实网络 adapter 实现
- 策略实现
- 持久化 adapter
- macOS UI 实现

## AEP v2 正式流程状态

当前项目按 AEP v2 正式流程推进：

| 阶段 | MTPRO 当前状态 | 责任边界 |
| --- | --- | --- |
| 1. Human Project Planning | 已完成 | Human 已确认 Project `MTPRO 引导`、issue 顺序和当前阶段目标 |
| 2. symphony-project | 暂不接自动 continuation | 当前不自动把下一个 Backlog issue 推进为 Todo；Codex 不修改 Linear status |
| 3. symphony-issue | 已完成 MTP-8 / MTP-9 链路验证 | 使用 `dangerFullAccess` issue automation profile；可在 Human 明确设置唯一 Todo 后调度当前 issue |
| 4. GitHub PR Automation | 已验证 | `checks`、`protect-main`、auto-merge、squash merge、branch cleanup 和 Linear bot auto Done 已跑通 |
| 5. Next Human Project Planning | 未进入 | 当前 Project 全部 issues Done 后，由 Human 决定下一阶段 |

Agent / Codex 只能执行当前唯一 configured executable Linear issue。`ROADMAP.md`、Linear Draft、Backlog issue、标签、priority、assignee 都不授权执行。

当前唯一 configured executable issue 必须在执行前从 Linear 查询确认；仓库文档不得把某个 issue 永久写成 current issue。

Graphify update 当前由 symphony-issue host-side `before_remove` 在 PR merge / Linear bot Done 后刷新持久本地仓库 `/Users/mac/Documents/MTPRO` 的 resource relationship graph。`graphify-out/*` 仍不进入 PR。

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
