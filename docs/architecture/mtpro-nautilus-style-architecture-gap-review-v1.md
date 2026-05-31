# MTPRO 对照交易系统架构图差距核对 v1

日期：2026-05-31

执行者：Codex

## 文档定位

本文是一份大白话架构差距核对文档，用来回答 Human 提出的两个问题：

1. 当前 MTPRO 和 NautilusTrader 风格的交易系统架构图差距在哪里。
2. 下一步应该先拆分 / 收口模块边界，还是继续进入 L4 planning。

本文不是 Linear Project Draft，不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma，不写业务代码。

本文不授权 signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。

## 一句话结论

MTPRO 现在不是“没有架构”，而是已经有了很多可验证的 evidence / read-model / simulation 能力；但它还没有完全长成图里那种“每个引擎都能独立运行、通过统一消息总线协作”的交易系统。

所以，下一步不建议直接执行 L4 Live Production。更稳的路线是：先做一次 Engine / Runtime 模块边界收口，把现在散在早期 `Core`、`Adapters`、`Persistence`、`Runtime`、`App` target 里的能力迁移到架构图模块结构，再让 Human + `@001 / PLN` 做 L4 planning。

## 当前 MTPRO 大白话状态

当前 MTPRO 已经完成到 `L3.4 Strategy / Trader Instance Readiness v1 complete`。这代表：

- Paper runtime、scenario replay、simulated exchange parity、Workbench beta、Live read-only boundary、account / position / balance read-model-only、private stream simulation gate、Live Monitoring v2 和 Strategy / Trader readiness evidence 都已经闭环。
- Workbench / Report / Events 已经能展示大量只读证据。
- `bash checks/run.sh` 是当前统一验证入口。

但这不代表：

- 已经有真实 Strategy runtime。
- 已经有真实 Trader runtime。
- 已经有 Execution Client。
- 已经有 broker / OMS。
- 已经有真实账户读取。
- 已经有 Live PRO Console。
- 已经可以下真实订单。

更准确地说，MTPRO 现在像是“交易系统的本地证据链和模拟地基已经打好了”，但还不是“实盘生产交易系统”。

## 对照架构图逐项核对

| 架构图模块 | MTPRO 当前已有 | 当前差距 |
| --- | --- | --- |
| DataClient | 已有 Binance public read-only market data client / transport boundary，只允许 public market data。 | 还不是完整多数据源 DataClient 体系；private account stream、listenKey、broker / execution client 仍明确禁止。 |
| DataEngine | `TradingKernel.swift` 中已有最小 `DataEngine`，可把 market event 写入 `MessageBus` 和 `MarketDataCache`；Data Catalog / Scenario Replay 已完成。 | 还不是完整 subscription / request / response / streaming DataEngine；更像 local replay + deterministic evidence 数据地基。 |
| MessageBus | `AppendOnlyEventLog` / `MessageBus` 已存在，L1 Paper Runtime 已有 paper-only CommandBus / EventBus / MessageBus routing evidence。 | 还不是贯穿所有 engine 的统一 runtime message bus；目前更多是 append-only facts source 和 deterministic routing contract。 |
| Cache | `MarketDataCache`、SQLite projection、DuckDB analytical projection、scenario replay evidence 已有。 | 还没有独立 Cache Engine 边界；in-memory cache、snapshot、projection、database 的职责还需要再拆清楚。 |
| Database / Redis | MTPRO 使用 local Event Log、SQLite runtime projection、DuckDB analytical projection。 | 当前不需要 Redis；Database 是 local-first durable backing store，不是 runtime cache；MTPRO 更适合先稳定 SQLite / DuckDB / snapshot contract。 |
| Trader | L3.4 已定义 Trader Instance readiness、identity、lifecycle、read-model input 和 proposal isolation。 | 还没有真正运行中的 Trader runtime；没有把 account、strategy、risk、execution 串成 live runtime coordinator。 |
| Strategies | 已有 EMA / order book signal evidence、strategy readiness surface、quoter / hedger role taxonomy。 | 还没有完整 strategy lifecycle、strategy scheduler、strategy instance runtime，也不能直接生成 broker command；Strategies 应作为独立模块，不内嵌在 Trader。 |
| RiskEngine | Paper Pre-trade RiskEngine、risk blocker evidence、Live Risk Gate blocked evidence 已有。 | 真实 live risk engine 没有实现；当前 risk 主要是 paper / contract / blocked evidence，不是 production risk runtime。 |
| ExecutionEngine | Paper lifecycle coordinator、simulated fill、market / limit simulated execution、backtest-paper parity 已完成。 | 真实 ExecutionEngine、OMS、ExecutionClient、submit / cancel / replace、execution report、broker fill、reconciliation 都没有实现，且仍禁止。 |
| ExecutionClient | 当前只有 public market data adapter；execution client 被 L3.4 明确阻断。 | 这是 L4 以后才可能进入的能力，必须经过 signed/account/broker/risk/ops gates。 |
| Portfolio | Paper account / portfolio / position projection、APB read-model-only evidence、portfolio parity 已有。 | 真实 account / position / balance、margin、leverage、real PnL、broker position sync 没有实现。 |
| Workbench | 这是 MTPRO 当前强项：Dashboard / Report / Events / read-model-only evidence surface 已经多轮成熟。 | Workbench 是只读证据面和本地 paper control shell，不是 Live PRO Console，不是交易操作台。 |

## 最核心的差距

### 1. 代码 target 还是粗粒度，Engine 边界还是偏文档层

当前 SwiftPM target 是：

```text
Core
Adapters
Persistence
Runtime
App
Dashboard
```

目标 Engine map 必须直接按架构图细分到：

```text
DataClient
DataEngine
MessageBus
Cache
Database
Strategies
Trader
Account
Portfolio
RiskEngine
ExecutionEngine
ExecutionClient
Workbench
```

大白话：最终“办公室”不能继续按 `Core / Adapters / Persistence / Runtime / App` 来定。下一版代码结构要直接按架构图模块定房间：`DataClient / DataEngine / MessageBus / Cache / Database / Strategies / Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient / Workbench`。当前 target 只是搬迁来源。

## 目标代码结构应按架构图一次性固定

`MTPRO Engine Module Boundary Consolidation v1` 的核心不是在旧目录里继续补边界，而是把最终目录一次性定成图里的模块结构：

```text
Sources/
  DomainModel/
  DataClient/
    Binance/
      PublicMarketData/
      FuturePrivateStreamGate/
  DataEngine/
  MessageBus/
  Cache/
    Instruments/
    MarketData/
    Orders/
    Positions/
    PortfolioSummary/
  Database/
    AppendOnlyEventLog/
    Snapshots/
    Projections/
      SQLite/
      DuckDB/
  Strategies/
    EMA/
      Lifecycle/
      Quoter/
      Hedger/
      Signals/
      Proposals/
    <future-strategy>/
  Trader/
    Accounts/
    Coordination/
    StrategyBindings/
  Portfolio/
    Positions/
    NetPositions/
    Margin/
    OpenValue/
    PaperProjection/
  RiskEngine/
  ExecutionEngine/
  ExecutionClient/
  Workbench/
  Dashboard/
```

当前 `Core / Adapters / Persistence / Runtime / App` 只能作为迁移来源或 compatibility shell。后续 Linear issue 应该把文件、namespace、type boundary、tests 和 validation guard 逐步迁移到这些目标目录，而不是继续沿用早期 target 作为新增能力落点。

### 2. MTPRO 现在更像 evidence-first 系统，不是 runtime-first 系统

当前大量完成项的关键词是：

- contract。
- deterministic fixture。
- forbidden capability tests。
- read-model-only surface。
- Dashboard smoke evidence。
- Stage Code Audit evidence。

这些非常适合保证边界和可审计性，但不等于每个 engine 都已经是可独立运行的 runtime service。

### 3. Strategy / Trader 已经定义清楚，但还没有真正跑起来

L3.4 已经把 Strategy Instance / Trader Instance 的语义、身份、角色、输入和禁区定义好了。

但它明确不包含：

- Strategy runtime。
- Trader runtime。
- quoter runtime。
- hedger runtime。
- order generation engine。
- Strategy -> Execution Client 直连路径。

大白话：现在知道“策略和交易员实例应该长什么样、不能做什么”，但还没有启动一个真正会调度策略、管理账户上下文、连接风险和执行的 Trader runtime。

### 4. MessageBus 已有事实流，但不是完整系统总线

`MessageBus` 当前很重要：它把 event 写入 append-only facts source，并支持 replay。Paper runtime routing 也已经建立 deterministic route evidence。

但架构图里的 MessageBus 通常意味着：

- engine 之间统一 publish / subscribe。
- command / event / request / response 都走统一边界。
- Data、Strategy、Risk、Execution、Portfolio 都通过它解耦。

MTPRO 当前还没有到这个程度。它现在更偏“可回放事实总线”，不是“完整运行时通信骨架”。

### 5. Execution / Portfolio / Risk 都还停在 paper / simulated / blocked evidence

这不是问题，而是当前边界设计的结果。

当前这些模块已经能证明：

- paper order lifecycle 可以本地闭环。
- simulated fill / fee / slippage 可以 deterministic replay。
- portfolio projection 可以从 simulated fill 推导。
- risk blocker evidence 可以展示。

但它们仍不能证明：

- 可以接真实 broker。
- 可以处理真实 execution report。
- 可以对账 broker fill。
- 可以同步真实 account / position。
- 可以做 real-time live risk allow / reject。

## 应该先拆模块，还是继续 L4 planning

结论：先拆模块 / 收口模块边界，再继续 L4 implementation planning。

理由很简单：

1. L4 是真实交易命令域，风险比 L3 readiness 高很多。
2. 当前代码 target 还是粗粒度，很多 engine 能力仍集中在 `Core` / `App`。
3. 如果直接做 L4，很容易把“read-model-only evidence”误接成“runtime capability”。
4. Strategy / Trader 虽然 readiness 已完成，但真正的 runtime orchestration 还没有拆出来。
5. Execution Client、OMS、broker fill、reconciliation、live risk 需要非常清楚的模块边界，否则后续会难以审计。

## 对早期边界限制的修正

Human 已确认：MTPRO 后续要按照架构图方向补齐。这里需要修正一个容易误解的点。

早期文档里很多边界写法是：

```text
不实现 Execution Client。
不实现 OMS。
不实现 Strategy runtime。
不实现 Trader runtime。
不实现 Live PRO Console。
```

这些限制在当时是为了防止 L1 / L2 / L3 阶段越界，不代表目标架构里永远不能出现这些模块。新的理解应该是：

```text
这些模块可以进入目标架构图和模块边界设计。
当前阶段只能定义职责、接口、依赖方向、禁止路径和验证锚点。
不能把它们实现成真实 broker / signed endpoint / live command runtime。
```

也就是说，下一阶段要做的不是继续把这些模块排除在文档外，而是把它们正式放进架构图，但标清楚：

- 哪些是 current paper / simulated / read-model-only 能力。
- 哪些是 future gated module boundary。
- 哪些路径必须被 validation 阻断。
- 哪些模块未来进入 L4 前需要独立 Human decision 和 Linear issue contract。

这就是 `MTPRO Engine Module Boundary Consolidation v1` 的核心价值。

## 推荐下一步

建议下一步不是 `L4 Live Production / Trading Commands` execution，而是先开一个模块边界收口阶段，例如：

```text
MTPRO Engine Module Boundary Consolidation v1
```

或者：

```text
MTPRO Runtime Module Boundary Split Readiness v1
```

该阶段仍然是 L4 前置，不是 L4。

建议目标：

- 把当前 `Core` / `Adapters` / `Persistence` / `Runtime` / `App` 中已经成熟的能力按架构图模块职责重新梳理。
- 明确哪些旧 target 只能作为迁移来源，哪些文件 / namespace / type boundary 需要迁入固定目标目录。
- 把 DataClient、DataEngine、MessageBus、Cache、Database、Strategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 的边界写清楚。
- 给 L4 planning 提供清晰的 module boundary input。

建议非目标：

- 不实现 live execution。
- 不实现 broker adapter。
- 不实现 signed endpoint。
- 不实现 account endpoint / listenKey。
- 不实现 Strategy runtime / Trader runtime。
- 不实现 OMS。
- 不实现 Live PRO Console。
- 不新增 trading button / live command。

## 推荐模块收口顺序

如果 Human 同意先做模块边界收口，建议按这个顺序处理：

1. `Architecture Boundary Contract`：先固定图里的目标模块名、目录、依赖方向和 forbidden path taxonomy。
2. `MessageBus / Cache / Database Spine`：确认 facts source、command / event、replay、snapshot、projection、SQLite、DuckDB、runtime cache 的职责。
3. `DataClient / DataEngine Boundary`：区分 public data client、future private source、DataEngine ingest、scenario replay 和 data quality。
4. `Strategies / Trader / Account / Portfolio Context`：把 readiness evidence、independent strategy lifecycle、Trader coordination、account context 和 portfolio projection 分开。
5. `RiskEngine / ExecutionEngine / ExecutionClient Future Gate`：明确 risk-before-execution、paper / simulated execution、future OMS、future execution client 的分界。
6. `Workbench Surface / L4 Handoff`：继续保持 UI 只消费 Read Model / ViewModel，并把 Live PRO Console 留作独立 future surface。

这样做完后，再让 `@001 / PLN` 做 L4 planning，L4 issue body 才能更精确地写清楚：

- 哪个模块能写。
- 哪个模块只能读。
- 哪个模块仍然 forbidden。
- 哪些路径不能从 paper / simulated evidence 升级为 live runtime。

## 如果坚持现在就做 L4 planning

可以做，但只能是 Human + `@001 / PLN` 的 docs-only planning，不建议进入 Linear execution。

L4 planning 至少要先回答这些问题：

- Execution Client 放在哪个 target / module。
- OMS 和 paper lifecycle coordinator 如何隔离。
- Strategy / Trader runtime 是否先独立于 broker execution。
- Live risk engine 如何先于真实 submit / cancel / replace。
- Broker fill / execution report / reconciliation 的 facts source 如何进入 Event Log。
- Live PRO Console 是否作为独立 product surface，而不是 Workbench 的自然扩展。

这些问题如果不先靠模块边界收口回答，L4 planning 会变成一组很危险的“大能力标题”，不适合直接执行。

## 最终建议

大白话版本：

```text
先别急着上 L4。

MTPRO 现在已经把证据链、模拟链、只读边界和策略/交易员 readiness 做得很扎实。
但对照交易系统架构图，真正缺的是“模块边界变成清楚的 runtime 骨架”。

先做一次 Engine Module Boundary Consolidation。
等 Data / MessageBus / Strategy / Trader / Risk / Execution / Portfolio / Persistence 的边界更稳，
再进入 L4 Live Production / Trading Commands planning。
```

推荐决策：

```text
Next step: module boundary consolidation before L4.
L4 status: Future Gated planning candidate only.
```
