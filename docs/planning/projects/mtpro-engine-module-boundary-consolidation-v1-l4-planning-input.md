# MTPRO Engine Module Boundary Consolidation v1 L4 Planning Input

日期：2026-06-01

执行者：Codex

本文是 MTP-181 的 L4 planning input material。它只汇总已经完成的 Engine Module Boundary Consolidation evidence，供 Human + `@001 / PLN` 后续独立规划 L4 使用；它不创建 L4 Linear Project / Issue，不推进 Todo，不授权 live runtime、broker path、production operations 或真实交易能力。

## MTP-181-L4-PLANNING-INPUT-MATERIAL

L4 planning input material 的输入来源是 MTP-162 至 MTP-180 已落仓的 architecture boundary、domain context、validation matrix、automation readiness 和 latest verification evidence。MTP-181 只把这些证据整理为 planning handoff，不新增 runtime source、不移动 production source、不修改 `Package.swift` target graph。

## MTP-181-ENGINE-MODULE-BOUNDARY-MAP

| Module boundary | L4 planning input | 当前 forbidden baseline |
| --- | --- | --- |
| DataClient | 一个 venue 一个 `Sources/DataClient/<venue>/`；public market data 与 future private stream gate 分离。 | signed endpoint、account endpoint / listenKey、private stream runtime、broker adapter、ExecutionClient。 |
| DataEngine | ingest、request / response、scenario replay、catalog、freshness、quality gates 到 MessageBus。 | 直接服务 UI / Trader、private endpoint runtime、account snapshot runtime、broker payload。 |
| MessageBus | facts / events / commands / request-response、paper routing、replay invariant。 | 绕过 RiskEngine / ExecutionEngine、发布 broker command、UI live command。 |
| Cache | runtime-derived read state；只消费 MessageBus facts 和 Database projection。 | durability / schema ownership、real account cache、broker state cache。 |
| Database | durable facts、snapshots、SQLite / DuckDB projection、replay projection。 | Workbench schema contract、account payload persistence、broker payload persistence。 |
| Strategies | `Sources/Strategies/<strategy>/`，以 EMA 为示例，表达 lifecycle / quoter / hedger / signals / proposals。 | Strategy runtime、scheduler、live quoter / hedger、ExecutionClient request、broker command。 |
| Trader / Account context | Trader coordination、account context / identity、strategy binding。 | live coordinator、OMS gateway、broker gateway、real account state owner。 |
| Portfolio | positions、net positions、cash/equity、PnL、exposure、paper projection。 | broker portfolio sync、real account read、real PnL source、live reconciliation。 |
| RiskEngine | paper pre-trade risk、blocked evidence、future live risk gate。 | live risk runtime、real pre-trade allow/reject, circuit breaker runtime。 |
| ExecutionEngine | paper / simulated lifecycle、simulated fill、fee / slippage、Portfolio projection output、OMS future gate。 | broker submit/cancel/replace、ExecutionClient request、real order lifecycle。 |
| ExecutionClient / OMS | future-gated venue API client and future OMS boundary. | current implementation、signed request、execution report parser、broker fill parser、reconciliation runtime。 |
| Workbench / Report / Events | read-model-only consumption surface for ViewModel / evidence surface. | runtime object, Adapter request, SQLite / DuckDB schema, account payload, broker payload, broker state, live command surface. |
| Future Live PRO Console | 独立 future product surface candidate。 | current Workbench extension、trading button、live command、order form、emergency stop、shutdown、restore。 |

## MTP-181-DEPENDENCY-DIRECTION-SUMMARY

L4 planning 必须保留以下依赖方向：

1. `DataClient -> DataEngine -> MessageBus -> Cache / Database -> ReadModel / ViewModel -> Workbench / Report / Events`。
2. `Strategies -> MessageBus / Cache / Portfolio / RiskEngine read models -> proposal evidence`，不得直连 ExecutionClient。
3. `Trader -> Strategies / Account context / Portfolio / RiskEngine / ExecutionEngine coordination`，不得成为 live coordinator、OMS 或 broker gateway。
4. `RiskEngine -> ExecutionEngine -> Portfolio projection / MessageBus facts`，不得跳过 risk 进入 broker path。
5. `ExecutionEngine -> OMSFutureGate / ExecutionClientFutureGate` 只能表达 future split，不授权 current broker adapter。
6. `Future Live PRO Console` 必须在 future Product / Operations / Execution gate 之后独立规划，不能复用 current Workbench read-model-only surface 作为 command surface。

## MTP-181-FORBIDDEN-CAPABILITY-AUDIT

MTP-181 对 L4 planning 的 forbidden audit 输入如下：

- Endpoint / credential：API key、secret storage、credential provider、signed endpoint、account endpoint、listenKey、private WebSocket runtime 均未授权。
- Broker / execution：broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、ExecutionClient implementation、OMS implementation、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation 均未授权。
- Account / portfolio：real account read、broker position sync、real balance、margin、leverage、buying power、real PnL、broker portfolio sync 均未授权。
- UI / operations：Live PRO Console、trading button、live command、order form、position command、emergency stop、shutdown、restore、broker connect UI、account connect UI、production operations command 均未授权。
- Exposure：Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload、broker state 不得成为 Workbench / Report / Events product surface contract。

## MTP-181-VALIDATION-GAPS-FUTURE-GATES

后续 L4 planning 至少需要独立回答这些 gap / gate：

- L4 Project Definition：Human + `@001 / PLN` 必须单独定义目标、scope、issue order、dependencies、validation 和 boundary。
- Signed / account gate：是否允许 credential、signed endpoint、account endpoint、listenKey 或 private stream，需要独立 Human decision 和 validation matrix。
- Broker / execution gate：是否允许 ExecutionClient、broker adapter、OMS、real order lifecycle、execution report、broker fill 或 reconciliation，需要独立 Project 和 forbidden capability audit。
- Product surface gate：Future Live PRO Console 是否进入规划、如何与 Workbench read-model-only surface 分离、哪些 command controls 仍保持 forbidden。
- Operations gate：emergency stop、shutdown、restore、production operations、audit trail、incident replay 和 recovery 只能在独立 operations plan 中评估。
- Validation gate：L4 不得复用当前 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 作为 execution authorization；需要新的 issue-specific validation matrix、local deterministic tests 和 post-issue evidence chain。

## MTP-181-NO-L4-PROJECT-ISSUE-AUTHORIZATION

本文件不创建 L4 Linear Project / Issue，不把任何 issue promote 到 Todo，不启动 `@002 / PAR` 新阶段，不启动 Symphony，不运行 Graphify，不修改 Figma，不授权业务代码实现。L4 必须由 Human + `@001 / PLN` 独立规划，之后再由 Parent Codex queue preflight 判定唯一 eligible issue。

## MTP-181-L4-PLANNING-INPUT-VALIDATION

MTP-181 validation 必须证明本文件、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/validation-plan.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 均包含 L4 planning input anchors，并且 `bash checks/automation-readiness.sh`、`git diff --check` 和 `bash checks/run.sh` 通过。
