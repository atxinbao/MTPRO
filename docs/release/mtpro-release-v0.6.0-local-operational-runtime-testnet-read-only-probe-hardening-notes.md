# MTPRO Release v0.6.0 Local Operational Runtime + Testnet Read-only Probe Hardening Notes

日期：2026-06-15

执行者：Codex

## Release Type

v0.6.0 是 `Local Operational Runtime + Testnet Read-only Probe Hardening` closure docs。它收口 GitHub fallback queue `GH-755..GH-766` 的 local operational runtime evidence、testnet read-only probe、validation command、operator runbook、Stage Code Audit 和 root docs refresh。

本文档不是 GitHub Release 发布动作，不创建 tag，不移动 tag，不发布 production cutover，不创建下一 Project / Issue。

## Scope

- GH-755：定义 v0.6.0 no-production 顶层合同和 Binance / Spot + USDⓈ-M Perpetual / EMA + RSI boundary。
- GH-756：建立 local run journal writer。
- GH-757：建立 run manifest 和 artifact checksum validator。
- GH-758：把 runtime message / journal checksum evidence 迁移到 sha256。
- GH-759：建立 DataEngine local dry-run runner。
- GH-760：建立 EMA / RSI strategy runtime runner。
- GH-761：建立 RiskEngine runtime runner。
- GH-762：建立 ExecutionEngine / OMS dry-run runner。
- GH-763：建立 Portfolio projection from real local run journal。
- GH-764：建立 Dashboard / CLI run detail observer。
- GH-765：建立 operator-confirmed Binance testnet read-only probe 和 no-order proof。
- GH-766：输出 final Stage Code Audit、release notes、operator runbook、root docs refresh 和 v0.6.0 aggregate verification command。

## Validation

本 closure 的本地验证入口：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.6.0.sh
bash checks/run.sh
```

`checks/run.sh` 继续运行 v0.1 / v0.3 / v0.4 / v0.5 / v0.6 release verifiers、Dashboard build / smoke 和 Swift tests。`checks/verify-v0.6.0.sh` 是 v0.6.0 closure 的聚合验证命令，用于 operator / release closeout 复现。

## Release Notes

v0.6.0 closes the local operational runtime and testnet read-only probe hardening stage:

- Binance-only active venue remains fixed。
- Active products remain Spot + USDⓈ-M Perpetual。
- Active strategies remain EMA + RSI。
- Runtime modes remain dry-run / testnet-read-only-probe / production-blocked。
- Local run journal writer, manifest checksum validator and sha256 runtime checksum evidence are guarded。
- DataEngine -> Strategy runtime -> RiskEngine -> ExecutionEngine / OMS dry-run -> Portfolio projection -> Dashboard / CLI observer evidence path is documented and guarded。
- Testnet read-only probe requires explicit operator confirmation and approved credential reference flow。
- Testnet endpoint allowlist rejects production endpoints。
- Credential values remain redacted from logs, artifacts, Dashboard and CLI output。
- Private stream / account snapshot evidence remains simulated read-model evidence when websocket is out of scope。
- Dashboard / CLI observer remains read-model-only。
- `checks/verify-v0.6.0.sh` provides a release-level local verification entry point.

## Boundary Evidence

- production trading remains disabled by default。
- no production secret auto-read。
- no production endpoint auto-connect。
- no production broker connection。
- no production order authorization。
- no signed production account endpoint / listenKey / private WebSocket runtime。
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

## Non-Authorization

本 release notes 不创建下一 Project / Issue，不推进 Todo，不启动 Linear / Symphony / Graphify / code-index / Figma，不授权 production cutover，不读取 secret，不连接 production endpoint，不连接 broker endpoint，不发送真实 order。
