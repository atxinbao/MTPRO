# MTPRO Reference Alignment & Product Gap Map v1

日期：2026-05-20

执行者：Codex

## 1. 文档定位

本文档是 MTPRO 对照 `nautilus_trader` 后形成的 product / architecture gap map 摘要。它只作为 planning input，不创建 Project / Issue，不推进 `Todo`，不授权 Live runtime、broker、OMS、Live PRO Console、trading button 或 real order。

## 2. 输入快照

| 输入 | 用途 |
| --- | --- |
| `docs/reference/nautilus-trader/product-reference.md` | 产品路径和用户任务参考 |
| `docs/reference/nautilus-trader/architecture-reference.md` | engine / adapter / message bus / cache / execution / risk / portfolio 参考 |
| `docs/reference/nautilus-trader/design-reference.md` | Workbench IA、状态语言、read model UI 参考 |
| `GOAL.md` / `BLUEPRINT.md` / `architecture.md` / `docs/roadmap.md` | MTPRO 当前目标、蓝图、模块边界和施工路线 |

## 3. 结论摘要

MTPRO 需要学习的是 workflow 和 evidence chain，不是 NautilusTrader 的整套 runtime。产品差距集中在四个分区：Workbench productization、release / beta readiness、engine parity hardening、Future Live PRO Console boundary。

## 4. Gap Matrix

| 分区 | Gap | 建议 |
| --- | --- | --- |
| Workbench Productization Map | 当前页面更像 evidence shell，用户路径和页面级 IA 需要更清楚 | 固定 Overview、Research、Backtest、Paper、Report、Portfolio、Risk、Events |
| Release / Beta Readiness Map | release readiness 需要把 validation、runbook、operator boundary 和 no-default-production-trading 串起来 | 每个 release 保留 Stage Audit、operator runbook、release notes、verify script |
| Engine Parity Hardening Map | MTPRO 不是完整 NautilusTrader runtime，仍需 module ownership / target graph / retained envelope 证据 | 保持 module boundary 和 compatibility envelope audit |
| Future Live PRO Console Boundary Map | Live PRO Console 是未来产品面，不是当前 Dashboard | 只记录 Future Construction Zone，禁止 trading button / live command 自动出现 |

## 5. Product Surface Comparison

| NautilusTrader reference | MTPRO product surface |
| --- | --- |
| Data catalog / data engine | Market data ingest、scenario replay、freshness / gap evidence |
| Strategy research | Strategy signal preview、parameter snapshot、research context |
| Backtesting | deterministic backtest run、cost assumptions、report artifact |
| Execution / risk / portfolio | paper / simulated / guarded testnet evidence；production remains gated |
| Reports / visualization | Report artifact center、causal chain、export-readiness |
| Live node / adapters | Future gated production capability；no default production trading |

## 6. Gap Dependency Graph

```text
Workbench IA
-> Report artifact taxonomy
-> Event / replay / projection evidence
-> Engine parity hardening
-> guarded testnet release evidence
-> production cutover readiness-only gate
```

## 7. 地图阅读顺序

1. 先读 `README.md` 和 `BLUEPRINT.md`，确认 current / future boundary。
2. 再读 `architecture.md`，确认 module boundary。
3. 读本文件，只把 gap 当作候选 planning input。
4. 进入执行前必须由 Human + `@001 / PLN` 生成 Project / Issue contract，再由 Parent Codex queue preflight。

## 8. 非授权边界

本文档不授权：

- Linear / GitHub issue 创建或状态推进。
- Strategy runtime、Trader runtime、Live runtime。
- signed endpoint、account endpoint / listenKey、private WebSocket runtime。
- ExecutionClient production implementation、OMS、broker gateway。
- Live PRO Console、trading button、live command、order form。
- real submit / cancel / replace、broker fill、reconciliation runtime。
- production secret read、production endpoint、production broker connection、production cutover。
