# MTPRO Real Target Source Ownership / Core Envelope Retirement v1 — Stage Audit Input

日期：2026-06-06

执行者：Codex

GitHub Issue：[#401](https://github.com/atxinbao/MTPRO/issues/401)

类型：project-level evidence matrix / stage audit input material

## 定位

本文档服务 GitHub fallback project `MTPRO Real Target Source Ownership Validation / Core Envelope Retirement v1` 的 GH-401 closeout input。

这只是 Stage Code Audit 的输入材料，不是最终 Stage Code Audit Report，不设置 Project closure，不推进下一 Project / Issue，不授权 L4。

## GH-401-ISSUE-EVIDENCE-CHAIN

| Issue | Evidence | Result |
| --- | --- | --- |
| GH-391 | `83ce90d` | 定义 real target ownership / Core envelope retirement contract。 |
| GH-392 | PR #403 / `b80778d` | 移除 direct `Trader -> ExecutionEngine` dependency。 |
| GH-393 | PR #404 / `c7651de` | 增加 foundation real target smoke tests。 |
| GH-394 | PR #405 / `6528be6` | 迁移 DomainModel / MessageBus implementation ownership。 |
| GH-395 | PR #406 / `9193ff9` | 增加 data target real smoke tests。 |
| GH-396 | PR #407 / `19430dd` | 迁移 DataClient / Cache implementation ownership，并明确 DataEngine retained envelope。 |
| GH-397 | PR #408 / `f0ad2fd` | 增加 Trader / Portfolio / Risk / Execution target smoke tests。 |
| GH-398 | PR #409 / `12be171` | 迁移 Trader / Portfolio / RiskEngine / ExecutionEngine / ExecutionClient implementation ownership。 |
| GH-399 | PR #410 / `861cd6c` | 清理 Dashboard active source 中的 Workbench 命名 residue。 |
| GH-400 | PR #411 / `d210e9b` | 增加 `try!` / `preconditionFailure` allowed-path validation。 |
| GH-401 | current issue | 汇总 Core envelope retirement matrix、L4 blocker 和 stage audit input。 |

## GH-401-CORE-ENVELOPE-RETIREMENT-MATRIX

| Module / Envelope | Current ownership result | Remaining envelope |
| --- | --- | --- |
| `DomainModel` | Foundation model / market primitives / domain errors 已由 `DomainModel` target 承载。 | `Core` 仍保留 compatibility import surface。 |
| `MessageBus` | Foundation message stream、append-only journal、strategy signal / paper action proposal、risk / portfolio contracts 已迁入 `MessageBus`。 | Rich legacy command / event surface 仍按后续拆分处理，不能反向依赖下游 runtime。 |
| `Database` | `Database` target 已有 foundation checkpoint API。 | SQLite / DuckDB projection implementation 仍在 `Persistence` envelope；replay projection 仍在 `Runtime` envelope。 |
| `DataClient` | Binance public read-only implementation 已由 `DataClient` target 承载。 | `Adapters` 保留 compatibility re-export，不拥有 active implementation。 |
| `Cache` | Market-data cache / order-book read model 已由 `Cache` target 承载。 | `Core` 仅保留 legacy replay helper bridge。 |
| `DataEngine` | Read-only replay plan 已在 `DataEngine` target。 | ScenarioReplay / DataQuality 仍在 `Core` envelope；Ingest 仍在 `Runtime` envelope。 |
| `TraderStrategies` | 当前唯一 active concrete strategy 是 `EMA`，canonical path 为 `Sources/Trader/Strategies/EMA/`。 | 非 EMA strategy 不进入 active source。 |
| `Trader` | `Trader = Accounts + Strategies/EMA + Coordination`，RiskBinding 位于 `Trader/Coordination/RiskBinding`。 | 不拥有 ExecutionEngine / ExecutionClient implementation。 |
| `Portfolio` | Portfolio financial state projection ownership 已迁入 `Portfolio` target。 | 不拥有真实账户 cash、positions、PnL、margin 或 leverage runtime。 |
| `RiskEngine` | Pre-trade risk ownership 已迁入 `RiskEngine` target。 | 不提交订单，不连接 broker，不实现 live risk runtime。 |
| `ExecutionEngine` | Paper / simulated lifecycle ownership 已迁入 `ExecutionEngine` target。 | 只到 paper / simulated boundary，不实现 real order lifecycle。 |
| `ExecutionClient` | 仍是 future gate / protocol boundary。 | 不实现 broker gateway、OMS、signed endpoint、listenKey、private WebSocket 或 submit / cancel / replace。 |
| `Dashboard` | Active UI surface 是 `Dashboard read-model-only boundary`。 | `Workbench` / `AppCompatibility` 已退休，不再作为 active module。 |
| `Core` | 已不再是所有模块的唯一 implementation owner。 | 仍保留 compatibility envelope，等待后续按证据拆分残余 surfaces。 |
| `Adapters` | 已退为 DataClient compatibility re-export。 | 仍作为 retained compatibility envelope 存在。 |
| `Persistence` | 仍承载 Database projection implementation。 | 后续 Database ownership project 才能迁移。 |
| `Runtime` | 仍承载 DataEngine ingest / replay projection workflow。 | 后续 Runtime envelope retirement 才能迁移。 |

## GH-401-RETAINED-COMPATIBILITY-ENVELOPE-SNAPSHOT

本阶段完成了 real target ownership 的关键迁移，但没有宣称 `Core`、`Adapters`、`Persistence`、`Runtime` 全部退休：

- `Core` 仍是 retained compatibility envelope，用于 legacy import surface 和仍未迁移的 rich evidence / routing surfaces。
- `Adapters` 仍是 DataClient compatibility re-export envelope。
- `Persistence` 仍承载 SQLite / DuckDB projection implementation。
- `Runtime` 仍承载 DataEngine ingest / replay projection workflow。

这些 envelope 是 L4 前置 blocker / debt inventory，不是 L4 execution authorization。

## GH-401-L4-READINESS-BLOCKERS

L4 仍然 future gated。进入 L4 planning 前至少需要单独评估：

- 是否继续退休 `Core` 中 residual rich MessageBus / Live / evidence surfaces。
- 是否把 `Database` SQLite / DuckDB projection implementation 从 `Persistence` 迁入 `Database` target。
- 是否把 `DataEngine` ScenarioReplay / DataQuality / Ingest 从 `Core` / `Runtime` 迁入 `DataEngine` target。
- 是否保留 `ExecutionClient` 为 future gate，或另立 broker / OMS planning project。
- 是否继续拆分大型 read-model / live boundary 文件以降低维护风险。

## GH-401-STAGE-AUDIT-INPUT

后续最终 Stage Code Audit Report 必须读取：

- `docs/contracts/real-target-source-ownership-core-envelope-retirement-contract.md`
- `docs/audit/inputs/mtpro-real-target-source-ownership-core-envelope-retirement-v1-stage-audit-input.md`
- `docs/validation/latest-verification-summary.md`
- `verification.md`
- PR #403 到 #411 的 merge / check evidence。

GH-401 只准备上述材料，不输出最终 Stage Code Audit Report。

## Boundary Evidence

- No Trader runtime.
- No Strategy runtime.
- No Live runtime.
- No ExecutionClient implementation.
- No OMS.
- No broker gateway.
- No signed endpoint.
- No account endpoint / listenKey.
- No private WebSocket runtime.
- No real account read.
- No real order lifecycle.
- No submit / cancel / replace.
- No execution report / broker fill / reconciliation.
- No Live PRO Console / trading button / live command / order form.
- No L4 implementation.
- No Symphony / symphony-issue.
- No Graphify / code-index.
- No Figma changes.
- No `.codex/*` or `graphify-out/*` submission.
