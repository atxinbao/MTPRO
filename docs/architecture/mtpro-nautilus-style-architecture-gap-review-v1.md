# MTPRO 对照交易系统架构图差距核对 v1

日期：2026-05-31

执行者：Codex

## 文档定位

本文档是对 MTPRO 与 NautilusTrader 风格交易系统架构图的差距核对摘要。它是 planning / architecture review evidence，不创建 Project / Issue，不推进 `Todo`，不授权 L4、Live runtime、broker、OMS 或 real order。

## 一句话结论

MTPRO 已经建立 evidence-first 的 module boundary、read model、validation 和 release guard，但仍不是 runtime-first 的完整交易系统。要进入真正生产能力，必须先把 module ownership、runtime orchestration、ExecutionClient / OMS、risk gate、kill switch、reconciliation 和 production cutover gates 严格拆开。

## 当前 MTPRO 状态

| 维度 | 当前状态 | 结论 |
| --- | --- | --- |
| Module target | SwiftPM target graph 已拆出真实模块边界，仍保留 compatibility envelope 证据 | 可继续按真实模块收口 |
| Data / replay | DataEngine、Cache、Event Log、projection、scenario replay 已形成 local-first 证据链 | 适合作为 runtime input foundation |
| Trader / Strategy | Trader-owned strategy layout 已固定，active strategy 已从 EMA 扩展到 release-gated EMA / RSI | 不能允许 strategy 直连 broker / OMS |
| Execution / Risk / Portfolio | paper / simulated / guarded testnet evidence 已存在 | production path 仍需独立 gate |
| Dashboard | read-model-only Dashboard / CLI surfaces 已闭合多轮 release evidence | 不等于 Live PRO Console production command |
| Production | production trading disabled by default；secret / endpoint / broker connection 不自动启用 | cutover 仍需 Human + gated project |

## 核心差距

| 差距 | 当前表现 | 推荐处理 |
| --- | --- | --- |
| Runtime-first orchestration | 现有系统更偏 deterministic evidence / validation pipeline | 用 release-gated runtime rehearsal 逐步固化，不一次性打开 production |
| ExecutionClient / OMS | 已有 sandbox / testnet guarded evidence，但 production broker adapter 未授权 | 先保持 testnet / dry-run / shadow，production 独立 cutover |
| Strategy lifecycle | Strategy 位置和 active set 已清楚，runtime lifecycle 需要受 Trader / Risk / Execution gate 约束 | 保持 `Trader = Accounts + Strategies + Coordination`，禁止 strategy shortcut |
| MessageBus | facts / command / event 已建立，但不是完整 live system bus | 继续限定为本地可审计 causal chain |
| Portfolio / reconciliation | projection 和 simulated evidence 已有，real broker reconciliation 未授权 | 生产 reconciliation 需要 broker report + OMS + Portfolio 三方 gate |

## 推荐模块收口顺序

1. Real module ownership / compatibility envelope audit。
2. Runtime rehearsal pipeline：dry-run -> shadow -> guarded testnet -> production-blocked。
3. ExecutionClient testnet capability matrix。
4. OMS local lifecycle evidence。
5. RiskEngine pre-trade / kill switch / no-trade guards。
6. Reconciliation / Event Store / Portfolio projection causal chain。
7. Dashboard / CLI read-only-to-command split。
8. Production cutover readiness-only gate。

## L4 Planning Gate

只有同时满足以下条件，才允许进入 L4 planning：

- `main` clean，open PR / active issue = 0。
- 当前 release evidence 已关闭，required checks 通过。
- production trading 仍默认关闭。
- no-default-production-trading automation guard 存在。
- secret / endpoint / broker / OMS / real order 均有 forbidden capability evidence。
- Human + `@001 / PLN` 明确创建下一阶段 planning，不从本文档自动转为 execution。

## 最终建议

不要把架构图当成“马上实现完整 live trading”的授权。正确路径是先完成 module ownership 与 release rehearsal，再逐步把 dry-run、shadow、guarded testnet 和 production-blocked evidence 变成可验证 pipeline；production cutover 继续保持独立 Human gate。
