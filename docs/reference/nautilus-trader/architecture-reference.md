# NautilusTrader Architecture Reference

日期：2026-05-19

执行者：@005 / ARC Architecture Reference Lead

## 研究边界

本文档只保存 NautilusTrader architecture reference 的压缩结论。它不授权 MTPRO 引入 NautilusTrader，不复制其代码，不创建 Project / Issue，不推进 `Todo`，不启动 Symphony / Graphify / code-index。

## 核心系统结构参考

| NautilusTrader 概念 | 架构意义 | MTPRO 映射 |
| --- | --- | --- |
| Kernel / Trading Node | 统一 lifecycle、clock、message routing、engine composition | `MessageBus`、runtime orchestration 和 release rehearsal 的长期参考 |
| Message Bus | command / event / request-response spine | MTPRO 内部 `MessageBus` 只承载本地可审计事实，不绕过 issue scope |
| Cache | instruments、market data、orders、positions 的快速状态层 | MTPRO `Cache` 是 projection / read-model input，不给 UI 直连 |
| Adapter | data / execution venue 边界 | MTPRO `DataClient` / `ExecutionClient` 分离，production broker 仍 gated |
| Data Engine | ingest、subscription、request / response、catalog / replay | MTPRO `DataEngine` 维护 local-first ingest / replay / data quality |
| Execution | order lifecycle、client adapter、execution report | MTPRO `ExecutionEngine` 先 paper / simulated / testnet guarded，不默认 production |
| Risk | pre-trade checks、risk commands、reject evidence | MTPRO `RiskEngine` 必须阻断越界 command |
| Portfolio | positions、PnL、exposure、account state | MTPRO `Portfolio` 是 read-model / projection context |
| Persistence | catalog、event / state persistence | MTPRO Event Log 是 facts source；SQLite / DuckDB 只做 projection |

## Event / Replay / Backtest / Paper / Live 分层

| 层 | 参考价值 | MTPRO 边界 |
| --- | --- | --- |
| Event-driven | 统一因果链、可审计状态转换 | Event Log / MessageBus 只保存本地 facts，不触发 broker action |
| Replay | 从 facts 重建状态和报告 | replay 必须 deterministic，projection 可重建 |
| Backtest | 以相同数据和策略语义产出结果 | MTPRO 压缩为 deterministic backtest / report evidence |
| Paper | 用模拟执行验证 lifecycle | paper / simulated 不等于 real order |
| Live | production trading runtime | 只作为 Future Construction Zone；需要 Human decision、secret / broker / risk / ops gates |

## MTPRO 应学习 / 不应学习

| 应学习 | 不应学习 |
| --- | --- |
| Engine / Adapter / Cache / MessageBus 的清晰职责分层 | 复制 NautilusTrader 整体 runtime |
| 同一事件语义贯穿 research、backtest、paper、report | 把 backtest 一致性直接解释成 live 授权 |
| Adapter capability matrix 和 venue boundary | 过早扩展多 venue 或多 broker |
| Report / replay / state projection 的 causal evidence | UI 直连 cache、database schema、adapter request |
| Live gates 作为独立架构能力 | 默认读取 secret、连接 production endpoint 或发送真实订单 |

## 候选 Delta Proposal

| 目标文档 | 建议 |
| --- | --- |
| `architecture.md` | 继续保持 `DataClient -> DataEngine -> Cache / Event Log -> Read Model -> Dashboard` 与 `ExecutionClient -> ExecutionEngine -> OMS / Event Store` 分层 |
| `environment.md` | 明确 production secret、production endpoint、broker connection 默认不可用 |
| `docs/roadmap.md` | 把 Live capability 放入 gated future planning，不由 reference study 自动授权 |
| `docs/contracts/api-contract.md` | external API 只暴露 stable command / read model boundary |
| `docs/contracts/backend-use-case-contract.md` | use case contract 记录 causal chain，不暴露 runtime object |
| `docs/contracts/binance-market-data-contract.md` | Binance public read-only 与 signed/private/prod endpoint 必须分开 |
| `docs/contracts/persistence-boundary.md` | 增加 projection disposable 原则：projection 可由 append-only event log 重建 |
| `docs/contracts/frontend-view-model-contract.md` | ViewModel 只能消费 read model，不读取 Cache / Runtime / Adapter / DB schema |

## 来源 URL

- NautilusTrader GitHub repository：https://github.com/nautechsystems/nautilus_trader
- NautilusTrader official docs：https://nautilustrader.io/docs/latest/
- Architecture：https://nautilustrader.io/docs/latest/concepts/architecture/
- Events：https://nautilustrader.io/docs/latest/concepts/events/
- Message Bus：https://nautilustrader.io/docs/latest/concepts/message_bus/
- Cache：https://nautilustrader.io/docs/latest/concepts/cache/
- Execution：https://nautilustrader.io/docs/latest/concepts/execution/
- Portfolio：https://nautilustrader.io/docs/latest/concepts/portfolio/
- Backtesting：https://nautilustrader.io/docs/latest/concepts/backtesting/
- Live Trading：https://nautilustrader.io/docs/latest/concepts/live/
- Adapters：https://nautilustrader.io/docs/latest/concepts/adapters/
