# MTPRO Architecture Graph Completion Review / L4 Readiness Planning v1 — GH-379 Trader / Execution Future Gates Review

日期：2026-06-05

执行者：Codex

GitHub Issue：[#379](https://github.com/atxinbao/MTPRO/issues/379)

类型：Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient future gate review

## 定位

本文档复核 architecture graph 中部和右侧路径：

```text
Trader = Accounts + Strategies/EMA + Coordination
Trader -> Portfolio / RiskEngine / ExecutionEngine context
RiskEngine -> ExecutionEngine -> ExecutionClient future gate
```

本轮只做 review，不实现 Trader runtime、Strategy runtime、Live runtime、ExecutionClient implementation、OMS 或 broker gateway。

## 结论

当前 Trader / Portfolio / Risk / Execution path 已完成 architecture-aligned target 和 source root 基线，但仍然处于 pre-L4 / compatibility-envelope 状态：

- `Trader` 当前明确是 `Accounts + Strategies/EMA + Coordination/RiskBinding` 容器。
- `EMA` 是唯一 active concrete strategy。
- `TraderStrategies` 不允许直接调用 `ExecutionClient`、broker、OMS 或 UI command surface。
- `Portfolio` 是 financial state projection boundary，不拥有 account identity，不读取真实 broker/account payload。
- `RiskEngine` 是 pre-execution guard，不是 live risk runtime，不调用 broker 或 ExecutionClient。
- `ExecutionEngine` 只表达 paper / simulated execution lifecycle boundary，连接 RiskEngine 与 ExecutionClient future gate。
- `ExecutionClient` 是 future-gated outgoing adapter contract，不是 broker SDK wrapper 或真实订单 runtime。

## Alignment matrix

| Module | Graph role | Current source root | Current allowed direction | Current forbidden capability | Remaining debt |
| --- | --- | --- | --- | --- | --- |
| `Trader` | account + strategy + coordination container | `Sources/Trader` | `DomainModel`, `MessageBus`, `Cache`, `TraderStrategies`, `Portfolio`, `RiskEngine`, `ExecutionEngine` | direct `ExecutionClient`, broker, OMS, endpoint, Trader runtime, Strategy runtime, live command surface | implementation compiled by `Core` compatibility envelope |
| `TraderStrategies` | Trader-owned concrete strategy definitions | `Sources/Trader/Strategies/EMA` | `DomainModel`, `MessageBus`, `Cache`, `Portfolio`, `RiskEngine` | non-EMA active strategies, direct execution, broker, OMS, UI command surface | EMA implementation compiled by `Core` compatibility envelope |
| `Portfolio` | financial state projection | `Sources/Portfolio` | `DomainModel`, `MessageBus`, `Cache`, `Database` | Trader account identity ownership, real broker/account read, endpoint payload | implementation compiled by `Core` compatibility envelope |
| `RiskEngine` | pre-execution risk guard | `Sources/RiskEngine` | `DomainModel`, `MessageBus`, `Cache`, `Portfolio` | broker, ExecutionClient, executable order command, live risk runtime | implementation compiled by `Core` compatibility envelope |
| `ExecutionEngine` | paper / simulated lifecycle | `Sources/ExecutionEngine` | `DomainModel`, `MessageBus`, `Cache`, `Portfolio`, `RiskEngine`, `ExecutionClient` | live execution runtime, OMS implementation, broker gateway, signed/account endpoint, real order lifecycle | implementation compiled by `Core` compatibility envelope |
| `ExecutionClient` | outgoing adapter future gate | `Sources/ExecutionClient` | `DomainModel`, `MessageBus` | broker gateway, signed endpoint, account endpoint, listenKey, private websocket, submit/cancel/replace, execution report, reconciliation | future gate only; implementation intentionally absent |

## EMA-only strategy review

Current active strategy source root:

```text
Sources/Trader/Strategies/EMA
```

Current active strategy set:

```text
EMA only
```

Observed constraints:

- no active `Sources/Strategies`;
- no active `Sources/Trader/StrategyBindings`;
- no active RSI / OrderBookImbalance / Momentum / MeanReversion source root;
- strategy code remains under Trader-owned strategy path;
- direct execution remains forbidden.

## ExecutionClient explanation

`ExecutionClient` is the future outgoing adapter boundary. In plain terms:

- `DataClient` brings public market data into the system.
- Internal modules turn that input into read models, strategy signals, proposals, paper / simulated decisions, and risk-checked execution evidence.
- `ExecutionClient` would be the future output-side adapter that sends approved orders to an external venue.
- Current MTPRO deliberately does not implement that output adapter. It only keeps a protocol / future-gate boundary so L4 planning can discuss it without accidentally enabling live trading.

## L4 blocker candidates from Trader / Execution path

Before L4 implementation planning can start, these questions must stay explicit:

1. Whether `Trader` can keep implementation under `Core` while L4 planning begins.
2. Whether `TraderStrategies` should continue compiling EMA through `Core` or move to direct target ownership first.
3. Whether `ExecutionEngine` paper / simulated lifecycle must move out of `Core` before any live planning.
4. Whether `ExecutionClient` should remain protocol-only until a separate broker-gateway project is explicitly planned.
5. Whether any future L4 issue must first define OMS, broker gateway, credentials and endpoint safety as separate contracts before implementation.

## Acceptance criteria evidence

- AC1：Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient future gate status is documented above.
- AC2：EMA-only and no-direct-execution boundaries are verified.
- AC3：validation output is recorded in `verification.md`.

## Boundary evidence

- No Linear write.
- No downstream GitHub issue promotion.
- No Symphony / symphony-issue.
- No Graphify / code-index.
- No Figma changes.
- No business code changes.
- No `Package.swift` changes.
- No `Sources` move.
- No SwiftPM target graph split.
- No Trader runtime.
- No Strategy runtime.
- No Live runtime.
- No `ExecutionClient` implementation.
- No OMS.
- No broker gateway.
- No signed endpoint.
- No account endpoint / listenKey.
- No private WebSocket runtime.
- No real order lifecycle, submit / cancel / replace, execution report, broker fill or reconciliation.
- No Live PRO Console, trading button, live command or order form.
- No L4 implementation.
