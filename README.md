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
- 当前执行事项：不写死在仓库文档中，运行时以 Linear / Parent Codex queue preview 中唯一 configured executable issue 为准
- GitHub PR Automation：`checks` workflow、`protect-main`、squash merge、auto-merge、branch cleanup

未完成：

- 独立 Project 级自动 continuation 程序（当前由父 Codex 监督替代）
- Binance 真实网络 adapter 实现
- 策略实现
- 持久化 adapter
- macOS UI 实现

## AEP v2 正式流程状态

当前项目按 AEP v2 正式流程推进：

| 阶段 | MTPRO 当前状态 | 责任边界 |
| --- | --- | --- |
| 1. Human Project Planning | 已完成 | Human 已确认 Project `MTPRO 引导`、issue 顺序和当前阶段目标 |
| 2. Parent Codex Automation Supervision | 已启用人工监督模式 | 父 Codex 做 queue preview、监控 child Codex、代码审查和 host-side fallback；只有 Human 明确授权后，才可把 eligible Backlog issue 推进为唯一 Todo |
| 3. symphony-issue | 已完成 MTP-8 / MTP-9 / MTP-10 链路验证 | 使用 `dangerFullAccess` issue automation profile；可在 Human 明确设置唯一 Todo 后调度当前 issue |
| 4. GitHub PR Automation | 已验证 | `checks`、`protect-main`、auto-merge、squash merge、branch cleanup 和 Linear bot auto Done 已跑通 |
| 5. Next Human Project Planning | 未进入 | 当前 Project 全部 issues Done 后，由 Human 决定下一阶段 |

Agent / Codex 只能执行当前唯一 configured executable Linear issue。`ROADMAP.md`、Linear Draft、Backlog issue、标签、priority、assignee 都不授权执行。

当前唯一 configured executable issue 必须在执行前从 Linear 查询确认；仓库文档不得把某个 issue 永久写成 current issue。

PR merge / Linear bot Done 后，symphony-issue host-side `before_remove` 执行 Post-Issue Ledger / 施工后记账：同步持久本地仓库、刷新 Graphify resource relationship graph，并写入本地结构化摘要 `.codex/post-issue-ledger/latest.json`。摘要只读，不授权下一个 issue；`graphify-out/*` 仍不进入 PR。详见 `docs/automation/post-issue-ledger.md`。

Parent Codex Automation Supervision 负责监督 `symphony-issue` 和 child Codex 的执行质量，处理受控 host-side fallback，并把真实失败反馈用于流程迭代。详见 `docs/automation/parent-codex-supervision.md`。

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
- `docs/automation/parent-codex-supervision.md`：父 Codex 自动化监督职责。
- `docs/automation/post-issue-ledger.md`：PR merge 后的施工后记账规则。
- `verification.md`：append-only 验证流水账。

## 本地验证

```bash
swift test
```

本地验证只证明当前 skeleton 可构建和基础边界测试通过，不代表业务实现完成。
