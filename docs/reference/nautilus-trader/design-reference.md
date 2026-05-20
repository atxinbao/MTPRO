# NautilusTrader Design Reference Study

日期：2026-05-19

执行者：Codex（@004 / DSG Design Reference Lead）

## 任务边界

本文只从前端页面、信息架构、Dashboard / Workbench 和 ViewModel / Read Model 映射角度提炼 NautilusTrader 对 MTPRO 的参考价值。

本文不修改 Linear，不创建 Project / Issue，不推进 Todo，不启动 Symphony，不写业务代码，不直接修改 `docs/architecture.md` 或 `docs/roadmap.md`，不实现 UI。

## 参考来源

- GitHub source：https://github.com/nautechsystems/nautilus_trader
- GitHub examples：https://github.com/nautechsystems/nautilus_trader/tree/develop/examples
- GitHub docs source：https://github.com/nautechsystems/nautilus_trader/tree/develop/docs
- High-level backtest source：https://github.com/nautechsystems/nautilus_trader/blob/develop/docs/getting_started/backtest_high_level.py
- Backtest example source：https://github.com/nautechsystems/nautilus_trader/blob/develop/examples/backtest/crypto_ema_cross_ethusdt_trade_ticks.py
- Official docs：https://nautilustrader.io/docs/latest/
- Concepts overview：https://nautilustrader.io/docs/latest/concepts/overview/
- Concepts index：https://nautilustrader.io/docs/latest/concepts/
- Data concepts：https://nautilustrader.io/docs/latest/concepts/data/
- Backtesting concepts：https://nautilustrader.io/docs/latest/concepts/backtesting/
- Execution concepts：https://nautilustrader.io/docs/latest/concepts/execution/
- Live trading concepts：https://nautilustrader.io/docs/latest/concepts/live/
- Reports concepts：https://nautilustrader.io/docs/latest/concepts/reports/
- Visualization concepts：https://nautilustrader.io/docs/latest/concepts/visualization/
- Portfolio concepts：https://nautilustrader.io/docs/latest/concepts/portfolio/
- Python API：https://nautechsystems.github.io/nautilus_docs/python-api-latest/
- Python Analysis API：https://nautechsystems.github.io/nautilus_docs/python-api-latest/analysis.html
- Python Backtest API：https://nautechsystems.github.io/nautilus_docs/python-api-latest/backtest.html
- Python Live API：https://nautechsystems.github.io/nautilus_docs/python-api-latest/live.html
- Python Portfolio API：https://nautechsystems.github.io/nautilus_docs/python-api-latest/portfolio.html
- Python Risk API：https://nautechsystems.github.io/nautilus_docs/python-api-latest/risk.html
- Rust API：https://nautechsystems.github.io/nautilus_docs/rust-api-latest/
- Rust analysis crate：https://nautechsystems.github.io/nautilus_docs/rust-api-latest/nautilus_analysis/index.html
- Rust backtest crate：https://nautechsystems.github.io/nautilus_docs/rust-api-latest/nautilus_backtest/index.html
- Rust event store crate：https://nautechsystems.github.io/nautilus_docs/rust-api-latest/nautilus_event_store/index.html
- Rust execution crate：https://nautechsystems.github.io/nautilus_docs/rust-api-latest/nautilus_execution/index.html
- Rust portfolio crate：https://nautechsystems.github.io/nautilus_docs/rust-api-latest/nautilus_portfolio/index.html
- Rust risk crate：https://nautechsystems.github.io/nautilus_docs/rust-api-latest/nautilus_risk/index.html

## NautilusTrader 暴露出的页面 / 工作台 / 使用入口线索

NautilusTrader 不是一个以 Dashboard 为中心的产品。它的 GitHub README 明确把 open-source 项目聚焦在 single-node backtesting 和 live trading，UI dashboards、distributed orchestration、built-in AI / ML tooling 不在当前开源重点内。因此，MTPRO 不应从 NautilusTrader 寻找可直接复制的页面，而应从它暴露的入口、报告形态和运行对象中提炼 Workbench 信息架构。

可观察到的使用入口如下：

| 入口线索 | NautilusTrader 表现 | 对 MTPRO 的设计含义 |
| --- | --- | --- |
| Documentation IA | Getting Started、Concepts、How-To、Tutorials、Integrations、Developer Guide、Rust API、Python API | MTPRO 的 Workbench 应按任务流和系统对象同时组织，避免只按技术模块堆叠 |
| Python script / notebook | `docs/getting_started/backtest_high_level.py` 使用 notebook cell 风格，按下载数据、加载 catalog、配置 venue / data / strategy、运行 backtest 组织 | Research / Backtest 页面应展示分步 pipeline 和每步输入输出状态 |
| Examples directory | `examples/backtest`、`examples/live`、`examples/sandbox`、`examples/other`、`examples/utils` | MTPRO 应区分 Research、Backtest、Paper / Sandbox 和未来 Live 禁区，不把入口混成一个交易按钮 |
| BacktestNode / BacktestEngine | 高级 API 走配置和 catalog，低级 API 直接装配 engine | Dashboard 需要同时呈现“声明式运行配置”和“执行结果快照”，但 UI 不直接触 engine |
| ParquetDataCatalog | 数据准备、查询、写入、streaming 是 backtest 的前置入口 | MTPRO Market / Research 应展示数据来源、时间范围、symbol / timeframe 和数据质量状态 |
| Reports / PortfolioAnalyzer | backtest 后通过 orders / positions / fills report、portfolio stats 和 tearsheet 做分析 | MTPRO Report 应是独立页面，不只是 Backtest 卡片的一段摘要 |
| Visualization / tearsheet | Plotly HTML tearsheet 是可归档、可分享的报告形态 | MTPRO 可以学习“自包含报告 artifact”，但应输出 Swift / read-model 原生报告，不依赖 Plotly 作为核心 UI |
| Python / Rust API index | API 按 Analysis、Backtest、Cache、Data、Execution、Live、Persistence、Portfolio、Risk、Model 等域组织 | MTPRO ViewModel 命名应保持域清晰，页面也应围绕业务域而非存储表结构 |
| Rust crates | analysis、backtest、event_store、execution、portfolio、risk 等 crate 边界清楚 | MTPRO 前端区域应对齐 read model 边界，而不是暴露 runtime object 或 adapter internals |

## Research / Backtest / Paper / Report / Portfolio / Risk / Events 信息架构参考

### Research

NautilusTrader 的 Research 入口主要通过 data loading、wrangler、catalog、strategy configuration 和 notebooks / scripts 暴露。MTPRO 应把 Research 页面定义为“研究输入和信号证据面”，而不是“策略代码编辑器”。

建议区域：

| 区域 | 内容 | ViewModel 来源 |
| --- | --- | --- |
| 数据集概览 | symbol、timeframe、数据类型、起止时间、样本数、last applied sequence | `MarketViewModel` |
| 研究运行 | researchID、strategyID、输入来源、生成信号数、最新 signal direction | `StrategyViewModel` |
| 信号证据 | EMA / order book imbalance 的关键指标和 parity anchor | `StrategyViewModel` + `ReportViewModel` |
| 数据质量状态 | empty、partial、ready、stale、invalid range | `MarketViewModel` / `EventLogViewModel` |

### Backtest

NautilusTrader 清晰区分高层 `BacktestNode` 和低层 `BacktestEngine`。MTPRO 不需要复制双 API，但应学习“配置、数据、venue、strategy、result”分层呈现。

建议区域：

| 区域 | 内容 | ViewModel 来源 |
| --- | --- | --- |
| 运行配置 | runID、strategy、symbol、timeframe、range、cost assumption | `BacktestViewModel` |
| 运行状态 | pending、running、completed、failed、cancelled、本地耗时、event count | `BacktestViewModel` / `EventLogViewModel` |
| 结果摘要 | signal count、latest direction、parity result、cost evidence | `BacktestViewModel` / `ReportViewModel` |
| 失败原因 | invalid data range、missing projection、parity mismatch、fixture missing | `BacktestViewModel` / `EventLogViewModel` |

### Paper

NautilusTrader 的 `sandbox` / live node 入口提示 MTPRO 需要把 Paper 与 Live 明确分开。MTPRO 当前边界是 paper-only execution evidence，因此 Paper 页面应呈现 session lifecycle、proposal、risk link、paper order、simulated fill、replay evidence，不提供真实交易动作。

建议区域：

| 区域 | 内容 | ViewModel 来源 |
| --- | --- | --- |
| Session lifecycle | sessionID、started / updated / closed、signalCount、paper-only flag | `PaperViewModel` / `ReportViewModel` |
| Proposal / order intent | proposalID、paperOrderID、side、quantity、reference price、authorization | `PaperViewModel` / `ReportViewModel` |
| Simulated fill | fill evidence ID、cost assumption、fee / slippage、source sequence | 未来 `PaperViewModel` / `ReportViewModel` |
| Replay evidence | replay streams、sequence count、deterministic replay、boundary flags | `ReportViewModel` / `EventLogViewModel` |

### Report

NautilusTrader 的 reports 和 tearsheets 把 backtest 后分析独立成 artifact。MTPRO 已有 `ReportViewModel`，应继续把 Report 作为 Workbench 的独立页面和归档对象，而不是把报告压缩在 Dashboard 首页。

建议区域：

| 区域 | 内容 | ViewModel 来源 |
| --- | --- | --- |
| Report artifacts | artifactID、researchID、backtestRunID、paperSessionID、createdAt | `ReportViewModel` |
| Trading validation evidence | parity、fees / slippage、risk blocker、portfolio exposure、runtime evidence | `ReportViewModel` |
| Report status | empty、ready、partial evidence、invalid evidence、stale projection | `ReportViewModel` |
| Export / archive hint | 本地 artifact 路径、生成时间、来源 sequence | `ReportViewModel`，只读 |

### Portfolio

NautilusTrader 的 Portfolio 是所有策略和工具共享的持仓、PnL、exposure 视图，并且通过 PortfolioAnalyzer 形成统计。MTPRO v1 只能展示 paper-only portfolio projection，不展示真实账户余额、保证金或 broker position。

建议区域：

| 区域 | 内容 | ViewModel 来源 |
| --- | --- | --- |
| Portfolio summary | portfolio IDs、updated count、gross exposure notional、symbols | `PortfolioViewModel` |
| Exposure list | symbol、timeframe、paper quantity、reference price、source sequence | `PortfolioViewModel` |
| Evidence link | 关联 proposal / risk / simulated fill / report artifact | `PortfolioViewModel` / `ReportViewModel` |
| Boundary banner | paper projection only，不代表真实账户余额或 broker position | `PortfolioViewModel` |

### Risk

NautilusTrader 的 RiskEngine 在 submit / modify 路径上执行 pre-trade checks，并有 ACTIVE / REDUCING / HALTED 状态。MTPRO 不应引入真实 pre-trade execution gate，但可以学习风险状态、拦截原因和状态解释的可观察性。

建议区域：

| 区域 | 内容 | ViewModel 来源 |
| --- | --- | --- |
| Risk status | blocker count、latest blocker reason、last applied sequence | `RiskViewModel` |
| Blocker evidence | evidenceID、paperOrderID、proposalID、reason、sourceSequence | `RiskViewModel` |
| Paper-only boundary | no broker fallback、no live fallback、no signed endpoint | `RiskViewModel` / `ReportViewModel` |
| 状态解释 | allowed / blocked 只代表本地 paper evidence | `RiskViewModel` |

### Events

NautilusTrader 的 Rust event store 暴露 append-only event store、tail replay、audit、incident replay 和 correlation headers 等线索。MTPRO 已有 append-only Event Log，因此 Events 页面应成为 Workbench 的事实源观察面。

建议区域：

| 区域 | 内容 | ViewModel 来源 |
| --- | --- | --- |
| Timeline | sequence、stream、event type、recordedAt、correlation | `EventLogViewModel` |
| Replay summary | replayed sequences、streams、deterministic flag、gap / out-of-order 状态 | `EventLogViewModel` / `ReportViewModel` |
| Evidence chain | research -> backtest -> paper -> report 的事件链 | `EventLogViewModel` / `ReportViewModel` |
| Integrity state | empty、ready、gap detected、out-of-order rejected、projection stale | `EventLogViewModel` |

## MTPRO Dashboard / Workbench 页面拆分建议

### 一级导航

建议 MTPRO 将 Dashboard / Workbench 拆为 7 个一级页面和 1 个全局状态页：

| 页面 | 目的 | 默认状态 |
| --- | --- | --- |
| Overview | 聚合当前 research / backtest / paper / report readiness，不承载深操作 | 首页 |
| Research | 数据、策略信号和研究 evidence | 独立页 |
| Backtest | 回测配置、运行状态和结果摘要 | 独立页 |
| Paper | Paper session / proposal / order intent / simulated fill evidence | 独立页 |
| Report | 研究、回测、Paper、trading validation 的归档报告 | 独立页 |
| Portfolio | paper-only portfolio projection 和 exposure | 独立页 |
| Risk | blocker evidence 和 paper-only risk context | 独立页 |
| Events | append-only timeline、replay、projection freshness | 全局事实页 |

### Overview 结构

Overview 不应是完整交易终端。它应只回答：

- 当前数据是否 ready。
- 最近 backtest 是否完成。
- 是否存在 report artifact。
- Paper session 是否处于 paper-only 可观察状态。
- Risk / Portfolio 是否存在 blocker 或 exposure evidence。
- Event log / replay 是否 deterministic。

### Workbench 主流程

推荐主流程：

```text
Research
-> Backtest
-> Report
-> Paper
-> Risk / Portfolio
-> Events
```

Paper 可以从 Report 进入，也可以从侧边导航进入，但不能在 Report 里出现真实交易按钮。Events 应作为所有页面的证据抽屉或详情页来源。

### 页面内通用结构

每个页面建议统一为：

```text
Header summary
-> Status strip
-> Primary evidence table / list
-> Detail inspector
-> Event / Report links
```

该结构对应 NautilusTrader “配置 -> 运行 -> 报告 -> 事件 / 分析” 的入口组织方式，同时符合 MTPRO read-model-only 边界。

## ViewModel / Read Model 映射建议

MTPRO 当前 `frontend-view-model-contract.md` 已定义 8 个 ViewModel。建议保持它们作为页面输入边界，并补充以下映射规则：

| 页面 | 主 ViewModel | 辅助 ViewModel | 说明 |
| --- | --- | --- | --- |
| Overview | `DashboardViewModel` / `DashboardShellSnapshot` | 全部 section snapshot | 只聚合摘要，不暴露 runtime object |
| Research | `MarketViewModel`、`StrategyViewModel` | `EventLogViewModel` | 数据质量和 signal evidence 是主线 |
| Backtest | `BacktestViewModel` | `ReportViewModel`、`EventLogViewModel` | 回测结果与 report artifact 解耦 |
| Paper | `PaperViewModel` | `RiskViewModel`、`PortfolioViewModel`、`ReportViewModel` | Paper page 展示 lifecycle / proposal / order / fill evidence |
| Report | `ReportViewModel` | `BacktestViewModel`、`PaperViewModel`、`EventLogViewModel` | Report 是 artifact 聚合页 |
| Portfolio | `PortfolioViewModel` | `ReportViewModel` | 只展示 paper projection exposure |
| Risk | `RiskViewModel` | `PaperViewModel`、`EventLogViewModel` | 风险状态只解释 paper blocker |
| Events | `EventLogViewModel` | `ReportViewModel` | 事实源、replay 和 integrity 状态 |

建议新增或扩展的只读状态字段：

| 状态字段 | 适用 ViewModel | 用途 |
| --- | --- | --- |
| `readinessState` | 全部页面级 ViewModel | empty / partial / ready / stale / invalid |
| `lastAppliedSequence` | 全部来自 projection 的 ViewModel | 标识投影新鲜度 |
| `sourceStreams` | `EventLogViewModel`、`ReportViewModel` | 呈现 evidence 来源 |
| `deterministicReplay` | `ReportViewModel`、`EventLogViewModel` | 明确 replay 是否可复现 |
| `boundaryFlags` | `PaperViewModel`、`RiskViewModel`、`PortfolioViewModel`、`ReportViewModel` | 固定 paper-only / no-live / no-broker / no-signed-endpoint |
| `emptyReason` | 全部页面级 ViewModel | 避免空状态被误解为失败 |
| `failureReason` | Backtest / Paper / Report / Events | 展示本地错误或验证失败原因 |

## 空状态 / 错误状态 / 运行状态建议

### 空状态

| 页面 | 空状态文案方向 | 禁止误导 |
| --- | --- | --- |
| Research | 尚无可用 market / signal read model | 不提示连接真实交易所账户 |
| Backtest | 尚无 backtest run projection | 不提示 live 运行 |
| Paper | 尚无 paper session evidence | 不提示下单 |
| Report | 尚无 report artifact | 不提示交易授权 |
| Portfolio | 尚无 paper exposure projection | 不显示真实余额占位 |
| Risk | 尚无 blocker evidence | 不显示“风险通过” |
| Events | Event log 为空或 projection 未生成 | 不伪造 sequence |

### 错误状态

错误状态应分为四类：

| 类型 | 示例 | 展示方式 |
| --- | --- | --- |
| Data error | missing symbol、invalid time range、partial catalog | Research / Backtest 顶部状态条 |
| Projection error | stale sequence、missing SQLite / DuckDB projection | 页面级错误 + Events 链接 |
| Validation error | parity mismatch、cost evidence mismatch、out-of-order replay | Report / Events 高优先级状态 |
| Boundary violation | UI 输入含 broker action、signed endpoint、live flag | 阻断展示为 invalid，不提供修复按钮 |

### 运行状态

运行状态建议统一：

| 状态 | 含义 | UI 行为 |
| --- | --- | --- |
| `empty` | 没有 read model evidence | 显示空状态 |
| `ready` | projection 已完成且 sequence 可解释 | 显示摘要和详情 |
| `running` | 本地任务正在生成 projection | 显示只读进度，不暴露 runtime object |
| `stale` | projection sequence 落后于 event log | 显示刷新需求，但不自动触发未授权流程 |
| `failed` | 本地验证或 projection 失败 | 显示失败原因和 evidence link |
| `invalid` | 触碰 live / broker / signed endpoint 禁区 | 显示边界违规，不提供交易出口 |

## MTPRO 应该学习什么

- 学习 NautilusTrader 以 Research -> deterministic simulation -> execution / portfolio / report 为一条语义链，而不是把页面按数据库表拆分。
- 学习 High-Level API 的声明式配置思想：Backtest / Paper 页面应围绕 run config、data config、strategy config、venue / paper context 和 result artifact 呈现。
- 学习 Data Catalog 的数据准备和查询意识：Research 页面应把数据范围、数据类型、symbol / timeframe 和可用性作为一等信息。
- 学习 Reports / PortfolioAnalyzer / tearsheet 的报告 artifact 形态：MTPRO Report 应可归档、可追溯、可链接事件证据。
- 学习 RiskEngine 的状态解释方式：Risk 页面要能解释 blocker reason、trading state 语义和 allowed / blocked 的上下文。
- 学习 Event Store 的 append-only、tail replay、audit、incident replay 语义：Events 页面应成为所有 Dashboard 状态的来源解释器。
- 学习 Python / Rust API 的领域命名：Analysis、Backtest、Data、Execution、Portfolio、Risk、Persistence、Model 等域可以帮助 MTPRO 保持 ViewModel 命名稳定。

## MTPRO 不应该学习什么

- 不学习 NautilusTrader 的 live trading “research-to-live no code changes” 产品承诺。MTPRO v1 必须继续禁止 Live trading、signed endpoint、account endpoint、broker action 和真实订单。
- 不复制 NautilusTrader 的 Python control plane 或 Rust crate 结构。MTPRO 是 SwiftPM-first macOS 工作台，NautilusTrader 只作为参考。
- 不把 NautilusTrader 的 reports / tearsheet 直接作为 MTPRO UI 技术路线。MTPRO 可以学习报告结构，但 UI 应继续消费 Swift App 层 ViewModel / Read Model。
- 不把 BacktestEngine / TradingNode / RiskEngine 等运行对象暴露给 UI。MTPRO 页面只读消费 ViewModel，不读取 runtime object。
- 不用 NautilusTrader 的 Portfolio 概念展示真实账户、margin、leverage、broker balance。MTPRO 当前 Portfolio 只代表 paper-only projection evidence。
- 不将 Examples 中的 live / sandbox 入口混入 MTPRO 当前 Dashboard。它们只能作为未来 Human 授权后的边界讨论材料。
- 不在 reference study 中创建 Linear Project / Issue，也不把本文建议当作 ROADMAP 授权。

## 对 `docs/product/*` 的建议

候选 delta proposal：

- 在 `docs/product/product-surface-map.md` 中把当前 8 个区域升级为页面级 IA：Overview、Research、Backtest、Paper、Report、Portfolio、Risk、Events。
- 为每个页面补充统一状态：empty、ready、running、stale、failed、invalid。
- 在 Report 区域补充 “artifact / evidence / export-readiness” 的只读概念，强调 Report 不是交易授权。
- 在 Events 区域补充 replay integrity、projection freshness、evidence chain 三类观察面。
- 在 Paper 区域为未来 paper order intent / simulated fill evidence 预留只读展示位置，但不新增命令出口。

## 对 `docs/contracts/frontend-view-model-contract.md` 的建议

候选 delta proposal：

- 保持现有 8 个 ViewModel，不新增 UI 对 runtime / adapter / database schema 的直接依赖。
- 为页面级 ViewModel 增补统一状态字段：`readinessState`、`emptyReason`、`failureReason`、`lastAppliedSequence`。
- 为 `ReportViewModel` 明确 artifact 维度：research、backtest、paper session、risk blocker、portfolio exposure、simulated fill、replay evidence。
- 为 `PaperViewModel` 预留 paper order intent 和 simulated fill evidence 的只读字段，但字段必须来自 future read model projection，不直接来自 execution runtime。
- 为 `EventLogViewModel` 增补 replay integrity 状态：gap、out-of-order、deterministicReplay、sourceStreams。
- 为 Risk / Portfolio / Paper / Report 增补 boundary flags：paper-only、no-live、no-broker、no-signed-endpoint，且这些 flag 不可由 UI 用户改写。

## 对 `docs/architecture.md` 的候选 delta proposal

不直接修改 `docs/architecture.md`。建议未来由 `@000 / AIE` 或 `@001 / PLN` 汇总后评估是否加入：

- 在 `App` 模块说明中补充 “Workbench IA / page-level ViewModel composition”。
- 在 `Dashboard` 模块说明中补充 “只读 shell 可拆成页面，但每页仍只消费 App 层 ViewModel snapshot”。
- 在目标数据流中明确 `Event Log -> Read Models -> Page ViewModels -> SwiftUI Pages`，把页面级 ViewModel 与 read model 的边界写清楚。
- 在不变量中补充 “Workbench 页面不得直接绑定 runtime object、adapter request、database schema、SQL、ORM model 或 broker/account state”。

## 对 `docs/roadmap.md` 的候选 delta proposal

不直接修改 `docs/roadmap.md`。建议未来汇总时只作为候选规划输入：

- 在产品路线中将 “Paper workflow 可观察性和本地控制壳” 拆成 “Workbench IA hardening” 和 “Paper workflow read-only evidence expansion” 两类。
- 为下一阶段 planning 增加一个候选主题：Dashboard / Workbench IA v1，将现有 8 个区域稳定为页面级信息架构和状态契约。
- 明确该候选主题不授权 live trading，不新增真实 broker action，不解锁交易按钮。
- 将 Report artifact 和 Events evidence chain 作为下一阶段 UX / validation 的共同主线，而不是只扩展单个页面。

## 结论

NautilusTrader 对 MTPRO 的最大参考价值不在 UI 外观，而在工作流组织：数据准备、研究信号、回测运行、报告分析、风险解释、组合投影、事件审计和 replay evidence 应形成同一条可追溯链路。

MTPRO Dashboard / Workbench 应从当前 8 个只读区域演进为页面级信息架构，但所有页面仍必须坚持 read-model-only：页面只消费 ViewModel / Read Model，不暴露 SQLite / DuckDB schema、runtime object、adapter request、Binance signed endpoint、broker action 或真实订单能力。
