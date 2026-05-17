# MTPRO 引导阶段代码审计报告

日期：2026-05-17

执行者：Parent Codex

审计对象：Linear Project `MTPRO 引导`

审计基线：`48791773b4b954b68121785e83737f9968530273`

## 目的

本报告记录 `MTPRO 引导` Project 完成后的阶段代码审计结果。

它用于支持下一阶段 Human Project Planning，不授权直接进入下一阶段开发，不创建 Linear issue，不替代 PR evidence，不替代 validation。

## 当前阶段结果

`MTPRO 引导` 已完成从项目定义到自动化就绪的第一轮实现闭环：

- `MTP-7` 到 `MTP-15` 全部为 `Done`。
- Linear Project `MTPRO 引导` 已标记为 `Completed`。
- GitHub PR Automation 已验证 PR merge、checks 和 branch cleanup 路径。
- Symphony issue execution 已验证 `Todo -> In Progress -> In Review -> PR -> Done` 路径。
- Post-Issue Ledger 已记录同步和 Graphify resource relationship graph 刷新结果。

## 审计范围

代码范围：

- `Sources/Core/Core.swift`
- `Sources/Adapters/Adapters.swift`
- `Sources/Persistence/Persistence.swift`
- `Sources/App/App.swift`

测试范围：

- `Tests/CoreTests/CoreTests.swift`
- `Tests/AdaptersTests/AdaptersTests.swift`
- `Tests/PersistenceTests/PersistenceTests.swift`
- `Tests/AppTests/AppTests.swift`

文档和自动化范围：

- `docs/architecture/module-boundary.md`
- `docs/contracts/*.md`
- `docs/automation/*.md`
- `docs/validation/validation-plan.md`
- `checks/run.sh`
- `checks/automation-readiness.sh`

## 验证结果

| 命令 | 结果 | 说明 |
| --- | --- | --- |
| `bash checks/run.sh` | passed | 自动化就绪检查、`git diff --check` 和 Swift 测试通过 |
| `graphify update .` | passed | 本地 resource relationship graph 已刷新，`graphify-out/*` 不提交 |
| Linear live query | passed | `MTP-7` 到 `MTP-15` 全部 `Done`，Project 为 `Completed` |

当前 Swift 测试结果：

- `AdaptersTests`：8 个测试通过。
- `AppTests`：4 个测试通过。
- `CoreTests`：22 个测试通过。
- `PersistenceTests`：5 个测试通过。
- 总计：39 个 XCTest 通过。

## 代码结构判断

当前模块边界是健康的：

| 模块 | 当前职责 | 审计判断 |
| --- | --- | --- |
| `Core` | 领域模型、事件、策略契约、message bus、kernel、cache | 功能完整，但单文件已经过大 |
| `Adapters` | Binance public read-only contract、fixture decoder、只读边界 | 边界清楚，尚未接真实网络 client |
| `Persistence` | replay boundary、SQLite runtime projection、DuckDB analytical projection | 投影语义清楚，尚未接真实 SQLite / DuckDB adapter |
| `App` | Dashboard read model 和 ViewModel contract | ViewModel 边界清楚，尚未实现真实 SwiftUI 页面 |

## 主要发现

### 1. Core 单文件已经达到下一阶段拆分门槛

`Sources/Core/Core.swift` 当前约 1752 行，承载了 symbol / timeframe、market events、order book、EMA、backtest、paper、risk、portfolio、event log、message bus、kernel 和 cache。

这在引导阶段可以接受，因为它降低了 early-stage 结构噪音；但下一阶段如果继续新增功能，应先拆分 Core 内部文件，避免后续 Codex 修改时上下文过大、冲突面过宽。

建议下一阶段优先拆分为：

- `Contracts.swift`
- `MarketEvents.swift`
- `Strategies/EMACross.swift`
- `Strategies/OrderBookImbalance.swift`
- `Events.swift`
- `MessageBus.swift`
- `TradingKernel.swift`

### 2. Persistence 目前是投影边界，不是真实数据库 adapter

`Persistence` 当前正确表达了 SQLite / DuckDB 的职责边界和投影语义，但实现仍是内存 projection store，不是真实 SQLite / DuckDB adapter。

这符合引导阶段的 minimum viable contract，但下一阶段如果要进入真实研究工作台，需要明确是否推进真实持久化 adapter。

建议下一阶段不要直接写完整数据库层，而是先做：

- append-only event log 文件落盘 contract。
- SQLite runtime projection adapter 的最小读写闭环。
- DuckDB analytical projection adapter 的最小 rebuild / query 闭环。

### 3. Binance adapter 仍是 public contract + fixture decoder

`Adapters` 已明确只读 public endpoint、禁止 signed endpoint、禁止 order action，并且测试覆盖 fixture decoding。

当前还没有真实 Binance network client。下一阶段如果需要真实行情回放，应先补一个 read-only fetch boundary，而不是直接把网络调用散落到 Core 或 App。

建议下一阶段新增：

- `BinancePublicMarketDataClient` contract。
- network transport abstraction。
- rate limit / retry / clock boundary。
- fixture parity tests，确认真实 response 与 fixture decoder 一致。

### 4. App 层是 ViewModel contract，不是真实产品 UI

`App` 当前已经把 Dashboard read model 和 ViewModel contract 固化，并且明确不暴露 database table、ORM、runtime object、Binance adapter 或 live order action。

但当前仍不是 macOS App UI。下一阶段如果目标是产品可观察入口，应先进入 SwiftUI App shell，而不是继续扩展 ViewModel 字段。

建议下一阶段新增：

- macOS App target 或可运行 executable target。
- Dashboard shell。
- Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 的最小只读页面。
- ViewModel snapshot 驱动 UI 的 smoke test。

### 5. 自动化流程已可用，但父 code 阶段审计应成为固定 gate

本阶段验证了：

- Symphony issue execution。
- GitHub PR Automation。
- Post-Issue Ledger。
- Graphify resource relationship graph refresh。
- Parent Codex host-side fallback。

但 Project Done 后如果直接进入下一阶段规划，会缺少阶段质量判断。

建议把本报告代表的动作固化为：

```text
Project Done
-> Parent Codex Stage Code Audit
-> Stage Audit Report
-> Next Human Project Planning
```

该审计只提供依据，不授权自动创建下一 Project。

## 风险与缺口

| 风险 | 等级 | 说明 | 建议处理 |
| --- | --- | --- | --- |
| Core 单文件过大 | 中 | 后续新增功能会增加冲突和上下文负担 | 下一阶段先拆分 Core 文件 |
| Persistence 未接真实 adapter | 中 | 当前只验证投影语义，不验证真实 SQLite / DuckDB 读写 | 下一阶段按 adapter contract 小步实现 |
| App 无真实 SwiftUI shell | 中 | 当前只能验证 ViewModel，不能验证用户操作流 | 下一阶段建立只读 Dashboard shell |
| Binance 无真实 network boundary | 中 | 当前只验证 endpoint contract 和 fixture decoder | 下一阶段实现 read-only client boundary |
| 自动化报告未固定到 AEP | 低 | 父 code 审计已经需要，但 AEP 尚未明确该 gate | 后续回到 AEP 增加 Stage Code Audit 规则 |

## 下一阶段 Project 建议

建议下一阶段不要直接做大功能，而是创建一个聚焦 Project：

```text
MTPRO Runtime Research Workbench v1
```

建议目标：

- 让当前 contract-first 内核可以被真实 macOS 只读工作台观察。
- 保持 Backtest / Paper / Report / Read-only market data 为主线。
- 不进入 live broker action。

建议 issue 顺序：

1. 拆分 `Core` 单文件，保持 API 与测试行为不变。
2. 建立 read-only Binance network client boundary。
3. 建立 append-only event log 文件落盘和 replay smoke test。
4. 建立 SQLite runtime projection adapter 最小闭环。
5. 建立 DuckDB analytical projection adapter 最小闭环。
6. 建立 macOS Dashboard shell 和只读 ViewModel binding。
7. 建立 Research -> Backtest -> Report 的最小用户路径。
8. 加固 automation readiness 和 stage audit evidence。

## 非目标

本报告不建议下一阶段进入：

- Live trading。
- signed Binance endpoint。
- broker credential management。
- real order execution。
- full strategy marketplace。
- 完整监控系统。
- 大规模数据库 schema 设计。

## 审计结论

`MTPRO 引导` 阶段达成目标：核心合同、只读 Binance 边界、event log、kernel / cache、strategy contract、projection boundary、Dashboard ViewModel 和自动化就绪都已建立，并有测试覆盖。

下一阶段的关键不是继续堆合同，而是把当前合同落到可运行的研究工作台闭环：

```text
真实只读数据入口
-> 持久化 replay
-> 投影查询
-> macOS Dashboard
-> Research / Backtest / Report 最小路径
```

进入下一阶段前，应由 Human 基于本报告确定新的 Linear Project 范围。
