# MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation Notes

日期：2026-06-14

执行者：Codex

## Release Type

v0.5.0 是 `Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge` closure docs。它收口 GitHub fallback queue `GH-726..GH-739` 的 guarded runtime foundation、validation command、operator runbook、Stage Code Audit 和 root docs refresh。

本文档不是 GitHub Release 发布动作，不创建 tag，不移动 tag，不发布 production cutover，不创建下一 Project / Issue。

## Scope

- GH-726：定义 v0.5.0 guarded runtime foundation 顶层合同、dry-run / testnet-guarded / production-blocked mode、Binance-only / Spot + USDⓈ-M Perpetual / EMA + RSI boundary。
- GH-727：建立 strict CLI command parser 和 read-only run-observer route。
- GH-728：建立 EnvironmentProfile / EndpointPolicy / SecretProfileRef fail-closed policy。
- GH-729：建立 fixed-point precision primitives 和 Binance Spot / USDⓈ-M Perpetual InstrumentCatalog。
- GH-730：建立 typed `RuntimeMessageBus` actor 和 runtime event envelope。
- GH-731：建立 durable local run journal shape。
- GH-732：建立 DataEngine operational dry-run path。
- GH-733：建立 testnet read-only integration gate 和 no-submit proof。
- GH-734：建立 RiskEngine runtime runner。
- GH-735：建立 ExecutionEngine / OMS dry-run lifecycle。
- GH-736：建立 Portfolio run journal projection。
- GH-737：建立 Dashboard / CLI run observer。
- GH-738：加固 GitHub Actions Linux / macOS Dashboard / aggregate `checks` reproducibility。
- GH-739：输出 operator runbook、final Stage Code Audit、release notes、root docs refresh 和 v0.5.0 verification command。

## Validation

本 closure 的本地验证入口：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.5.0.sh
bash checks/run.sh
```

`checks/run.sh` 继续运行所有 v0.5 focused verifiers、Dashboard smoke 和 Swift tests。`checks/verify-v0.5.0.sh` 是 v0.5.0 closure 的聚合验证命令，用于 operator / release closeout 复现。

## Release Notes

v0.5.0 closes the guarded testnet runtime foundation:

- Binance-only active venue remains fixed。
- Active products remain Spot + USDⓈ-M Perpetual。
- Active strategies remain EMA + RSI。
- Runtime modes remain dry-run / testnet-guarded / production-blocked。
- DataEngine -> RuntimeMessageBus -> run journal -> RiskEngine -> ExecutionEngine / OMS -> Portfolio -> Dashboard / CLI observer evidence path is documented and guarded。
- Testnet read-only evidence remains explicit, redacted and no-submit。
- Dashboard / CLI run observer remains read-model-only。
- GitHub required `checks` now aggregates Linux full validation and macOS Dashboard build/smoke。
- Operator runbook documents validation, observer inspection, guarded testnet proof and production-disabled proof。

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
