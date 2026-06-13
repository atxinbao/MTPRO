# MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline Notes

日期：2026-06-13

执行者：Codex

## Release Type

v0.4.0 是 unified runtime rehearsal pipeline closure docs。它收口 GitHub fallback queue `GH-694..GH-709` 的 deterministic local rehearsal evidence、validation suite、operator runbook、Stage Code Audit 和 root docs refresh。

本文档不是 GitHub Release 发布动作，不创建 tag，不移动 tag，不发布 production cutover，不创建下一 Project / Issue。

## Scope

- GH-694：定义 v0.4.0 unified runtime rehearsal pipeline 顶层合同、single runID、Binance-only / Spot + USDⓈ-M Perpetual / EMA + RSI boundary、dry-run / shadow / testnet-guarded / production-blocked semantics。
- GH-695：定义 RehearsalRunContext 和 unified evidence envelope。
- GH-696：定义 RuntimeKernel dry-run orchestrator。
- GH-697：接入 DataEngine -> MessageBus run-scoped market event evidence。
- GH-698：接入 Trader-owned EMA / RSI actor intent evidence。
- GH-699：接入 RiskEngine allow / reject / blocked pre-trade evidence。
- GH-700：接入 ExecutionEngine / OMS local dry-run lifecycle evidence。
- GH-701：接入 Binance dry-run ExecutionClient adapter boundary。
- GH-702：接入 explicit testnet-guarded boundary，default remains dry-run。
- GH-703：接入 Event Store append-only run journal。
- GH-704：接入 Portfolio replay projection。
- GH-705：接入 Dashboard / CLI unified run read-model surface。
- GH-706：接入 shadow replay mode proof。
- GH-707：新增 `checks/verify-v0.4.0.sh` release validation suite。
- GH-708：新增 operator runtime rehearsal runbook。
- GH-709：输出 final Stage Code Audit、release notes、root docs refresh 和 closure guard。

## Validation

本 release closure 的本地验证入口：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.4.0.sh
bash checks/run.sh
```

Closure focused guard：

```bash
swift test --filter TargetGraphTests/testGH709ReleaseV040StageAuditAndReleaseDocsCloseCompletedFactsOnly
```

`checks/run.sh` 必须覆盖 `checks/verify-v0.4.0.sh`，使 v0.4.0 unified runtime rehearsal validation suite 成为 required local validation path 的一部分。

## Boundary Evidence

- production trading remains disabled by default。
- no production secret auto-read。
- no production endpoint auto-connect。
- no production broker connection。
- no production order authorization。
- no signed endpoint / account endpoint / listenKey / private WebSocket runtime。
- no real submit / cancel / replace。
- no production OMS。
- no broker fill / reconciliation runtime。
- no Dashboard production command。
- no Live PRO Console runtime authorization。
- no trading button / live command / order form。
- no production cutover authorization。
- no non-Binance venue。
- no non-Spot / non-USDSM active product。
- no non-EMA / non-RSI active strategy。

## Release Notes

v0.4.0 closes the local unified runtime rehearsal pipeline:

- Binance-only active venue remains fixed。
- Active products remain Spot + USDⓈ-M Perpetual。
- Active strategies remain EMA + RSI。
- One `runID` ties DataEngine, MessageBus, Trader / Strategy, RiskEngine, ExecutionEngine / OMS, ExecutionClient dry-run / testnet-gated evidence, Event Store, Portfolio projection, Dashboard and CLI evidence。
- Shadow replay remains deterministic proof and is not production approval。
- Testnet remains explicit `testnet-guarded` proof and defaults to dry-run。
- `mtpro unified-run-status` remains read-model-only blocked evidence。
- Operator runbook documents start / observe / stop / replay / audit flow without production access。
- `checks/verify-v0.4.0.sh` and `checks/run.sh` provide the required validation entrypoint。

## Non-Authorization

本 release notes 不创建下一 Project / Issue，不推进 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 secret，不连接 production endpoint，不连接 broker endpoint，不发送真实 order。
