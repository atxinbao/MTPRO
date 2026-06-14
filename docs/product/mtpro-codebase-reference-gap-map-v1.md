# MTPRO Codebase Reference Gap Map v1

日期：2026-05-20

执行者：Codex

## 1. 文档定位

本文保存 MTPRO 与 `nautilus_trader` 代码级 reference gap map 的压缩结论。它只作为 product / architecture planning input，不创建 Project / Issue，不推进 `Todo`，不授权 runtime、broker、OMS、Live PRO Console 或 production trading。

## 2. 读取快照

| Repo | 读取范围 |
| --- | --- |
| MTPRO | root docs、Package.swift、Sources/Core、DataClient、Persistence、Runtime、Dashboard、contracts、validation |
| nautilus_trader | core/common/system/model/data/adapters/backtest/risk/execution/portfolio/event_store/testkit/cli/infrastructure |

## 3. 总结判断

当前缺口不是“补更多 Live 实现”，而是把代码结构、产品路径和 evidence chain 对齐：MTPRO 应继续保持 Swift / local-first / evidence-first，而不是变成 NautilusTrader 的 Swift 复刻。

## 4. 代码级差距矩阵

| Gap | 说明 | 建议 |
| --- | --- | --- |
| Module ownership | MTPRO 历史上存在 compatibility envelope 和 docs-first target boundary | 继续用 real module source root / target graph / retained envelope audit 收口 |
| Runtime orchestration | NautilusTrader 有完整 kernel / node lifecycle；MTPRO 是 guarded rehearsal evidence | 先强化 dry-run / shadow / testnet / production-blocked pipeline |
| Strategy lifecycle | NautilusTrader strategy lifecycle 完整；MTPRO 只激活 release-gated strategy evidence | 保持 Trader-owned strategies，禁止 strategy 直连 broker / OMS |
| Execution / OMS | NautilusTrader execution engine 完整；MTPRO production execution gated | 只在 explicit issue scope 内做 sandbox / testnet / blocked evidence |
| Portfolio / reconciliation | NautilusTrader 有 account / position / PnL 真实路径；MTPRO 先 projection / read model | production reconciliation 继续独立 gate |
| UI / operations | NautilusTrader 偏 API / CLI；MTPRO 要做 macOS Workbench | UI 只消费 ViewModel / Read Model |

## 5. 蓝图补图输入

- `Event Log -> Read Models -> Page ViewModels -> Dashboard / CLI`。
- `DataClient -> DataEngine -> Cache / Database -> Report`。
- `Trader Strategies -> RiskEngine -> ExecutionEngine -> OMS / Event Store`，production 默认 blocked。
- `ExecutionClient` 与 broker / endpoint / secret / real order 必须受 capability gate 控制。

## 6. 建议阅读顺序

1. `README.md`
2. `BLUEPRINT.md`
3. `architecture.md`
4. `docs/architecture/module-boundary.md`
5. 本文件
6. 相关 Project Planning Record / Stage Audit

## 7. 非授权边界

本文不授权 source move、target graph change、Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint、private WebSocket、real order、trading button、live command 或 production trading。
