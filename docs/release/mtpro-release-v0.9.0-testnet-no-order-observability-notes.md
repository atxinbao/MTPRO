# MTPRO Release v0.9.0 Testnet No-order Observability Notes

日期：2026-06-17

执行者：Codex

## Release Type

v0.9.0 是 `Testnet No-order Observability` construction closure docs。它收口 GitHub fallback queue `GH-843..GH-856` 的 testnet read-only no-order observability contract、monitor session persistence、snapshot freshness、private stream heartbeat、recovery workflow、Dashboard / CLI observability、alert read-model、Portfolio reconciliation timeline、Risk policy audit、export bundle、validation lanes、operator UX、Stage Code Audit 和 root docs refresh。

本文档是 v0.9.0 construction closeout 的 release notes evidence。它不创建 Git tag，不创建 GitHub Release，不移动已有 release，不授权 production cutover，不创建下一 Project / Issue。

## Scope

- GH-843：定义 v0.9.0 testnet no-order observability contract。
- GH-844：承接 v0.8.0 stable release publication evidence，但不把 publication 当成 production cutover。
- GH-845：建立 persistent TestnetReadOnlyMonitorSession。
- GH-846：建立 signed account snapshot freshness monitor。
- GH-847：建立 private stream heartbeat and staleness detection。
- GH-848：建立 monitor recovery workflow。
- GH-849：建立 Dashboard observability timeline。
- GH-850：建立 alerting read-model without notification side effects。
- GH-851：建立 Portfolio reconciliation timeline。
- GH-852：建立 Risk policy profile application audit。
- GH-853：建立 run and monitor export bundle。
- GH-854：进一步拆分 deterministic CI lane 和 manual operator testnet lane。
- GH-855：加固 Dashboard and CLI operator UX。
- GH-856：输出 final Stage Code Audit、release notes、operator runbook、root docs refresh 和 v0.9.0 final aggregate verification guard。

## Validation

本 closure 的本地验证入口：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.9.0.sh
bash checks/run.sh
```

`checks/run.sh` 继续运行 historical release verifiers、v0.9 focused verifiers、Dashboard build / smoke 和 Swift tests。`checks/verify-v0.9.0.sh` 是 v0.9.0 closure 的聚合验证命令，用于 operator / release closeout 复现。

## Release Notes

v0.9.0 closes the testnet no-order observability stage:

- Binance-only active venue remains fixed。
- Active products remain Spot + USDⓈ-M Perpetual。
- Active strategies remain EMA + RSI。
- Runtime modes are testnet-read-only-observe / snapshot-freshness-monitor / private-stream-heartbeat-monitor / reconciliation-review / alert-read-model-only / recovery-observe / production-blocked。
- v0.8.0 stable GitHub Release evidence is carried forward only as publication evidence。
- Persistent monitor session store records read-only monitor artifacts and fails closed on corruption。
- Signed account snapshot freshness monitor records redacted freshness evidence。
- Private stream heartbeat monitor records stale / disconnected / recovered evidence without raw listenKey exposure。
- Monitor recovery workflow preserves history and redacted recovery evidence。
- Dashboard observability timeline displays monitor artifact state without commands。
- Alert read-model is read-only and has no notification side effects。
- Portfolio reconciliation timeline remains explain-only and audit-only。
- Risk policy application audit binds local policy version / hash to monitor artifacts。
- Run monitor export bundle is checksum-backed and redacted。
- Validation lanes keep CI deterministic / no-secret / no-network and manual network proof explicit。
- Dashboard / CLI operator UX supports safe local `monitor start/status/stop/recover/export` evidence with no trading button, no order form and no live command。
- `checks/verify-v0.9.0.sh` provides a release-level local verification entry point.

## Boundary Evidence

- production trading remains disabled by default。
- no production secret auto-read。
- no production endpoint auto-connect。
- no production broker connection。
- no production order authorization。
- no signed production account endpoint / listenKey / private WebSocket fallback。
- no raw listenKey, raw private payload or credential value display。
- no testnet or production submit / cancel / replace。
- no testnet order routing。
- no production OMS。
- no broker fill / reconciliation runtime。
- no Dashboard production command。
- no Dashboard trading button / order form / live command。
- no alert notification side effect。
- no automatic recovery command。
- no Live PRO Console runtime authorization。
- no production cutover authorization。
- no non-Binance venue。
- no non-Spot / non-USDSM active product。
- no non-EMA / non-RSI active strategy。

## Non-Authorization

本 release notes 不创建下一 Project / Issue，不推进 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 secret，不连接 production endpoint，不连接 broker endpoint，不发送 testnet 或 production order。
