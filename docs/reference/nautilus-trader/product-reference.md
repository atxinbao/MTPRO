# NautilusTrader Product Reference Study

日期：2026-05-19

执行者：@003 / PRD Product Reference Lead

## 角色边界

本文档只执行 MTPRO NautilusTrader Reference Study 的 Product Reference 部分。

本文档不创建 Linear Project / Issue，不推进 `Todo`，不启动 Symphony，不写业务代码，不直接修改 `GOAL.md` 或 `docs/roadmap.md`。

## 研究目标

从产品流程、用户路径、工作台能力角度，提炼 NautilusTrader 对 MTPRO 的参考价值。

MTPRO 不包装 NautilusTrader，不引入 NautilusTrader 作为运行依赖，不复制 NautilusTrader 代码。NautilusTrader 只作为产品能力、工作流组织和用户路径参考。

## NautilusTrader 产品能力摘要

NautilusTrader 是面向专业量化交易的开源算法交易平台。它的产品能力重点不是图形化工作台，而是围绕同一套领域模型、数据模型和执行语义，支持从研究、回测到实盘部署的连续工作流。

核心能力可以概括为：

| 能力 | NautilusTrader 表达 | 对产品的含义 |
| --- | --- | --- |
| 统一交易系统 | 同一套 Trading Node、Data Engine、Risk Engine、Execution Engine、Portfolio、Message Bus 等组件组织交易生命周期 | 用户可以围绕统一语义理解策略、数据、订单、风险和组合 |
| 研究到回测 | 支持 Python 高层 API、Backtest Engine、Backtest Node、数据目录、报告和可视化 | 用户路径从数据准备、策略配置、运行回测到查看结果闭环明确 |
| 回测到实盘一致性 | 官方强调同一策略代码可用于回测和 live trading，并支持多 venue / adapter | 平台价值来自语义一致性，但 MTPRO 第一版必须截断在 Paper，不进入 Live |
| 多市场和多 venue | 支持 crypto、FX、equities、betting、data provider 和 execution venue adapter | 对 MTPRO 是 adapter 边界参考，不是第一版能力目标 |
| 数据能力 | 支持 order book、quote tick、trade tick、bar、instrument metadata、catalog、Parquet 等数据形态 | MTPRO 应学习数据形态分层和 replay 证据，不学习全市场泛化 |
| 回测能力 | 支持高层和低层回测 API、Backtest Node、venue / data / strategy config、分析报告 | MTPRO 应学习 run config、run evidence、report artifact，而不是复制引擎复杂度 |
| 风险和组合观察 | 系统内有 Risk Engine、Portfolio、Account、Order / Position / Fill 等模型 | MTPRO 应把风险、组合、事件作为可观察面，而不是交易控制面 |
| 报告和可视化 | 提供 account / order fill / positions / PnL / stats reports，以及基于 plotly / Jupyter 的 tearsheet | MTPRO 应把 report 作为研究证据输出，而非交易执行入口 |

关键产品判断：

- NautilusTrader 的核心产品资产是“统一交易语义 + 可重放 workflow”，不是现成桌面 UI。
- NautilusTrader 的用户默认具备开发能力，主要通过 Python / Rust API、配置对象、节点和报告工作。
- MTPRO 的差异化应是 macOS 原生工作台，把 Research / Backtest / Report / Paper evidence 做成更直接的可观察产品路径。

## 用户路径 / Workflow 摘要

### 1. 学习和安装路径

NautilusTrader 的入口通常是：

```text
阅读文档
-> 安装 Python package
-> 运行示例
-> 准备数据 catalog
-> 配置 venue / data / strategy
-> 运行 backtest
-> 查看 reports / visualization
-> 选择是否进入 live trading
```

对 MTPRO 的启发：

- 第一屏不应只是“行情表格”，而应展示用户当前处于 Research / Backtest / Report / Paper 的哪一步。
- 新用户路径应先解释数据边界、策略输入和验证证据，而不是引导连接账户或交易所密钥。
- MTPRO 的 onboarding 应强调 paper-only、read-only data、event evidence。

### 2. 数据准备路径

NautilusTrader 把数据能力作为 workflow 的底座，用户需要理解 instrument、venue、data type、catalog、bar / tick / order book 等概念。

典型路径：

```text
选择 venue / instrument
-> 获取或导入数据
-> 存入 catalog
-> 在 backtest config 中声明数据范围
-> 运行并复用同一数据语义
```

对 MTPRO 的启发：

- Market Data 页面应展示 symbol、timeframe、数据新鲜度、缺口、数据来源和 replay 覆盖范围。
- MTPRO 第一版只应固定 Binance public read-only + Top 5 USDT + `1m` / `5m`，避免过早泛化到多 venue。
- 数据不是 UI 直接消费的 exchange payload，而是进入 Event Log / Projection / ViewModel。

### 3. 策略研究路径

NautilusTrader 的策略研究偏向代码和配置驱动：用户定义 strategy、参数、订阅数据、运行 backtest，再通过报告分析。

典型路径：

```text
定义策略
-> 配置参数
-> 选择数据
-> 运行回测
-> 查看订单、成交、仓位、PnL、统计报告
-> 调参并重复
```

对 MTPRO 的启发：

- Strategy Lab 应服务“理解策略输入和信号状态”，不是一开始做完整策略 IDE。
- EMA Cross 是第一版合适的最低可解释策略；Order Book Imbalance 应作为后续研究能力，不应该抢占第一版产品面。
- 参数、数据窗口、信号、run evidence 应串联成一个研究路径。

### 4. 回测路径

NautilusTrader 的 Backtesting 文档区分较直接的高层 API 和更细粒度的配置 / 节点方式。产品上，这意味着它服务两类用户：快速验证用户和高级编排用户。

典型路径：

```text
选择 backtest 模式
-> 定义 venue / data / strategy / risk / execution config
-> 启动 run
-> 产生 account / fills / positions / stats / PnL 报告
-> 对结果做可视化和后续分析
```

对 MTPRO 的启发：

- Backtest 页面应围绕 run lifecycle、输入快照、结果摘要、失败原因和可重放证据设计。
- MTPRO 不需要暴露 NautilusTrader 式复杂 config tree；应把配置收敛为策略、symbol、timeframe、date range、成本假设和数据覆盖。
- 回测报告必须能回答：用什么数据、什么策略、什么成本假设、产生了哪些事件、是否能重放。

### 5. Report / Visualization 路径

NautilusTrader 把报告和 visualization 作为回测分析的重要出口，包含 orders、fills、positions、account、PnL、statistics、tearsheet 等。

对 MTPRO 的启发：

- Report 不是附属页面，而是 Research -> Backtest -> Paper 之间的证据中心。
- Report 应展示 artifact、run id、event range、parity evidence、risk blocker、portfolio exposure、cost assumptions。
- Dashboard 应汇总 Report evidence，而不是只显示市场和组合数字。

### 6. Live 路径

NautilusTrader 的正式产品路径包含 live trading，并强调与 backtest 相同策略代码和相同系统语义。

对 MTPRO 的启发：

- 可以学习“同一语义贯穿 backtest / paper”的产品主张。
- 不学习“同一套能力直接进入 live”的产品路径。
- MTPRO 第一版必须把 Live 作为 blocked boundary 展示，而不是隐藏的未来按钮。

## 对 MTPRO Research / Backtest / Paper / Report / Dashboard 的启发

### Research

MTPRO Research 应服务以下用户任务：

- 明确当前研究对象：symbol、timeframe、strategy、data range。
- 理解策略输入是否充足。
- 看到信号状态、缺口和阻塞原因。
- 生成可复现的 backtest request，而不是直接触发交易。

建议产品能力：

- Research Context Snapshot。
- Strategy Input Health。
- Signal Preview。
- Data Coverage / Freshness。
- Research Run Evidence。

### Backtest

MTPRO Backtest 应服务以下用户任务：

- 运行 EMA Cross 等最小策略回测。
- 看到 run lifecycle：queued / running / completed / failed / blocked。
- 看到输入数据、成本假设、事件范围和结果摘要。
- 可以把报告与 Paper evidence 对齐。

建议产品能力：

- Backtest Run Card。
- Backtest Input Snapshot。
- Deterministic Replay Evidence。
- Cost Assumption Evidence。
- Backtest Result Summary。

### Paper

MTPRO Paper 应服务以下用户任务：

- 在不触发真实 broker action 的前提下，观察 paper-only session。
- 看到 paper order intent、risk decision、simulated fill、portfolio projection。
- 证明 Paper 与 Backtest 使用一致的事件语义。

建议产品能力：

- Paper Session Timeline。
- Paper Order Lifecycle Evidence。
- Risk Blocker Evidence。
- Simulated Fill Evidence。
- Paper-only Portfolio Projection。

### Report

MTPRO Report 应服务以下用户任务：

- 把 Research、Backtest、Paper 的输出汇总成可审计 artifact。
- 展示 run id、event id、projection version、cost assumption、risk blocker、portfolio exposure。
- 作为 Human review、PR evidence、stage audit 的产品级证据。

建议产品能力：

- Report Artifact List。
- Report Detail Snapshot。
- Evidence Chain Panel。
- Backtest / Paper Parity Section。
- Exportable audit summary。

### Dashboard

MTPRO Dashboard 应服务以下用户任务：

- 快速知道当前工作台是否 ready、running、degraded、failed 或 blocked。
- 汇总 Market、Strategy、Backtest、Report、Paper、Risk、Portfolio、Events。
- 显示哪些边界被禁止：Live、signed endpoint、account endpoint、broker action。

建议产品能力：

- Workspace Status Overview。
- Current Research Path。
- Latest Report Evidence。
- Paper-only Boundary Indicator。
- Validation / Replay Health。

## MTPRO 应该学习什么

1. 学习统一语义链路。

   NautilusTrader 的强项是 data、strategy、risk、execution、portfolio、event / report 使用一套交易语义。MTPRO 应保持 Research、Backtest、Paper、Report、Dashboard 的事件和 projection 语义一致。

2. 学习 run / report / evidence 工作流。

   NautilusTrader 的回测和报告能力说明，用户不只是要运行策略，还要看见 orders、fills、positions、PnL、stats 和可视化结果。MTPRO 应把 report artifact 和 validation evidence 作为一等产品能力。

3. 学习数据类型分层。

   NautilusTrader 清晰区分 instrument、bar、tick、order book、quote、trade 等数据形态。MTPRO 应在产品面区分 Market Data snapshot、Order Book research input、Backtest data range、Paper projection，而不是把它们混成一个行情表。

4. 学习 adapter 边界命名。

   NautilusTrader 的 adapter、data client、execution client、venue 等概念有助于 MTPRO 保持 Binance public read-only adapter 与未来其他输入的边界清楚。

5. 学习高层 / 低层使用路径分层。

   NautilusTrader 同时服务快速回测和高级配置。MTPRO 第一版应提供低摩擦最小路径，同时把高级参数留到后续，不在第一版 UI 中暴露完整复杂度。

6. 学习报告与可视化作为验证出口。

   NautilusTrader 的 reports 和 tearsheet 能力说明，可视化不只是展示，而是研究判断和验证证据的一部分。MTPRO Report / Dashboard 应围绕 evidence 组织。

## MTPRO 不应该学习什么

1. 不学习 Live trading 路径。

   NautilusTrader 的产品闭环包含 live trading。MTPRO 第一版 Live 完全禁止，不提供 live order button、broker action、signed endpoint、account endpoint 或 listenKey user data stream。

2. 不学习多 venue / 多资产全覆盖。

   NautilusTrader 支持多市场、多 venue、多 adapter。MTPRO 第一版应固定 Binance public read-only、Top 5 USDT、`1m` / `5m`，优先完成本地证据闭环。

3. 不学习复杂 engine 暴露方式。

   NautilusTrader 面向专业开发者，用户可直接接触较多 engine / config / node 概念。MTPRO SwiftUI 不应直接暴露 runtime engine object、database table、exchange payload 或复杂 config tree。

4. 不学习“文档 / notebook 即产品界面”。

   NautilusTrader 的主要用户界面是 API、配置、报告和 notebook。MTPRO 的产品差异应是 macOS 原生工作台，应把核心用户路径做成 Dashboard / Report / Paper evidence。

5. 不学习 execution venue 能力。

   NautilusTrader adapter 包含 data 与 execution。MTPRO 第一版只能学习 data adapter 的只读边界，不能引入 execution client、account client 或 order management UI。

6. 不学习过早泛化的策略平台。

   NautilusTrader 可承载复杂策略。MTPRO 第一版应先服务 EMA Cross 和后续 Order Book Imbalance 的研究路径，不做通用策略市场或插件系统。

## 对 GOAL.md 的候选 delta proposal

以下为候选修改建议，不在本任务中直接修改 `GOAL.md`。

### Proposal G1：明确目标用户

建议补充：

```text
MTPRO 第一版服务具备交易研究能力的个人或小团队用户，他们需要在 macOS 本地完成 Binance public read-only 数据观察、策略研究、回测报告、Paper evidence 和验证审计，而不是直接进入真实交易。
```

理由：

- NautilusTrader 默认用户偏专业开发者。
- MTPRO 需要明确自己服务“本地研究工作台用户”，而不是交易执行平台用户。

### Proposal G2：强化 Report 是核心结果

建议补充：

```text
MTPRO 的核心结果不仅是 Backtest / Paper 状态可见，还包括可审计的 Report artifact，用于串联 Research、Backtest、Paper、Risk、Portfolio 和 Event Log evidence。
```

理由：

- NautilusTrader 的 reports / visualization 是回测工作流的重要出口。
- MTPRO 当前产品路线已经包含 Report，应在 Goal 层提升为核心能力。

### Proposal G3：明确“不做 NautilusTrader 替代品”

建议补充：

```text
MTPRO 不试图成为 NautilusTrader 的 Swift 复刻，也不覆盖多 venue / live execution / advanced order management。NautilusTrader 只作为工作流、报告和交易语义参考。
```

理由：

- 防止后续规划膨胀到全功能 trading platform。

## 对 docs/roadmap.md 的候选 delta proposal

以下为候选修改建议，不在本任务中直接修改 `docs/roadmap.md`。

### Proposal R1：下一阶段增加 Product Reference Synthesis Gate

建议在下一阶段规划前增加：

```text
Product Reference Synthesis
-> NautilusTrader PRD / DSG / ARC reference studies
-> GOAL / ROADMAP / product docs delta proposal
-> Human review
-> Next Project Planning
```

理由：

- 当前任务是 Linear 外 reference study，不应直接变成 issue 执行。
- 需要把 PRD、DSG、ARC 三类参考汇总后再进入规划。

### Proposal R2：把 Report 作为 Research -> Backtest -> Paper 的中心节点

建议把产品路线表达为：

```text
Research
-> Backtest
-> Report evidence
-> Paper-only execution evidence
-> Dashboard / Stage Audit
```

理由：

- NautilusTrader 的报告和可视化能力是用户判断回测有效性的关键。
- MTPRO Dashboard 应围绕 Report evidence 汇总，而不是仅显示运行状态。

### Proposal R3：明确未来 Live 仍非默认方向

建议补充：

```text
Live trading 不是默认路线。任何 Live 相关讨论必须先经过 Human 决策、新 Project Definition、安全边界和独立 planning，不得从 Paper workflow 自然滑入 Live。
```

理由：

- NautilusTrader 的产品路径天然通向 Live。
- MTPRO 当前硬边界要求 Live 完全禁止。

## 对 docs/product/* 的候选 delta proposal

以下为候选修改建议，不在本任务中直接修改 `docs/product/*`。

### Proposal P1：新增用户路径页

候选文件：

```text
docs/product/user-workflows.md
```

建议定义：

- Research workflow。
- Backtest workflow。
- Report review workflow。
- Paper evidence workflow。
- Dashboard monitoring workflow。
- Blocked Live workflow。

### Proposal P2：新增 report artifact taxonomy

候选文件：

```text
docs/product/report-artifact-taxonomy.md
```

建议定义：

- Backtest report artifact。
- Paper session report artifact。
- Risk blocker artifact。
- Portfolio exposure artifact。
- Replay / Event Log artifact。
- Stage Audit artifact。

### Proposal P3：补充 Dashboard 状态语言

建议在产品文档中明确：

- ready。
- running。
- degraded。
- failed。
- blocked。
- paper-only。
- read-model-only。

这些状态应该服务用户判断，而不是只服务工程实现。

## 来源 URL

- GitHub source: https://github.com/nautechsystems/nautilus_trader
- Official docs: https://nautilustrader.io/docs/latest/
- Concepts: https://nautilustrader.io/docs/latest/concepts/
- Architecture: https://nautilustrader.io/docs/latest/concepts/architecture/
- Backtesting: https://nautilustrader.io/docs/latest/concepts/backtesting/
- Live trading: https://nautilustrader.io/docs/latest/concepts/live/
- Reports: https://nautilustrader.io/docs/latest/concepts/reports/
- Visualization: https://nautilustrader.io/docs/latest/concepts/visualization/
- Data: https://nautilustrader.io/docs/latest/concepts/data/
- Adapters: https://nautilustrader.io/docs/latest/concepts/adapters/
- Binance integration: https://nautilustrader.io/docs/latest/integrations/binance/
- Rust API: https://nautechsystems.github.io/nautilus_docs/rust-api-latest/
- Rust backtest API: https://nautechsystems.github.io/nautilus_docs/rust-api-latest/nautilus_backtest/
- Python API: https://nautechsystems.github.io/nautilus_docs/python-api-latest/
- Python backtest API: https://nautechsystems.github.io/nautilus_docs/python-api-latest/backtest.html
