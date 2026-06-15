# MTPRO Release v0.8.0 Persistent Operator Runtime + Testnet Read-only Monitoring Notes

日期：2026-06-15

执行者：Codex

## Release Type

v0.8.0 是 `Persistent Operator Runtime + Testnet Read-only Monitoring` construction closure docs。它收口 GitHub fallback queue `GH-807..GH-820` 的 persistent no-order operator runtime、testnet read-only monitoring proof、Dashboard / CLI local observer、risk policy profile、Portfolio reconciliation review workflow、validation lanes split、Stage Code Audit 和 root docs refresh。

本文档是 v0.8.0 construction closeout 的 release notes evidence。它不创建 Git tag，不创建 GitHub Release，不移动已有 release，不授权 production cutover，不创建下一 Project / Issue。v0.8.0 public release publication 仍然必须走独立 release publication gate。

## Scope

- GH-807：定义 v0.8.0 persistent operator runtime no-order contract。
- GH-808：对齐 v0.7.0 / v0.8.0 release publication docs and policy。
- GH-809：建立 persistent RunRegistryStore。
- GH-810：绑定 top-level CLI local run session actions。
- GH-811：建立 OperationalRunSessionStore。
- GH-812：加固 EventLogWriter local crash recovery。
- GH-813：建立 manual Binance testnet signed account read-only network proof。
- GH-814：建立 manual Binance testnet private stream read-only monitoring proof。
- GH-815：建立 Dashboard testnet read-only monitor surface。
- GH-816：建立 local Risk policy profile management。
- GH-817：建立 Portfolio reconciliation review workflow。
- GH-818：把 Dashboard safe local controls 绑定到 session store。
- GH-819：拆分 deterministic CI proof lane 和 manual operator network proof lane。
- GH-820：输出 final Stage Code Audit、release notes、operator runbook、root docs refresh 和 v0.8.0 final aggregate verification guard。

## Validation

本 closure 的本地验证入口：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.8.0.sh
bash checks/run.sh
```

`checks/run.sh` 继续运行 historical release verifiers、v0.8 focused verifiers、Dashboard build / smoke 和 Swift tests。`checks/verify-v0.8.0.sh` 是 v0.8.0 closure 的聚合验证命令，用于 operator / release closeout 复现。

## Release Notes

v0.8.0 closes the persistent operator runtime and testnet read-only monitoring stage:

- Binance-only active venue remains fixed。
- Active products remain Spot + USDⓈ-M Perpetual。
- Active strategies remain EMA + RSI。
- Runtime modes are local-dry-run / testnet-read-only-monitor / recovery-observe / production-blocked。
- Persistent operator runtime contract fixes `noOrder=true` and production-disabled defaults。
- v0.8.0 construction closeout remains separate from public GitHub Release publication。
- RunRegistryStore persists local run registry entries with deterministic checksums。
- CLI local session actions create and observe local artifacts only。
- OperationalRunSessionStore persists session, session events and session status evidence。
- EventLogWriter crash recovery keeps append-only evidence and quarantines corrupt complete lines。
- Manual Binance Spot testnet signed account proof remains read-only, explicit and redacted。
- Manual Binance Spot testnet private stream monitoring observes listenKey lifecycle without execution command path。
- Dashboard testnet read-only monitor shows account snapshot and private stream freshness without trading controls。
- Risk policy profile management records local versioned profile, deterministic diff and operator metadata。
- Portfolio reconciliation review is explain-only and audit-only。
- Dashboard safe local controls mutate or read only `.local/mtpro/runs/...` evidence。
- Validation lanes keep CI deterministic / no-secret / no-network and manual network proof explicit。
- `checks/verify-v0.8.0.sh` provides a release-level local verification entry point.

## Boundary Evidence

- production trading remains disabled by default。
- no production secret auto-read。
- no production endpoint auto-connect。
- no production broker connection。
- no production order authorization。
- no signed production account endpoint / listenKey / private WebSocket fallback。
- no testnet or production submit / cancel / replace。
- no testnet order routing。
- no production OMS。
- no broker fill / reconciliation runtime。
- no Dashboard production command。
- no Dashboard trading button / order form / live command。
- no Live PRO Console runtime authorization。
- no production cutover authorization。
- no non-Binance venue。
- no non-Spot / non-USDSM active product。
- no non-EMA / non-RSI active strategy。

## Non-Authorization

本 release notes 不创建下一 Project / Issue，不推进 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 secret，不连接 production endpoint，不连接 broker endpoint，不发送真实 order。
