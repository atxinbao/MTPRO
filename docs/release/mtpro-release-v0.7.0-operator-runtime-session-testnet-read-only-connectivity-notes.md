# MTPRO Release v0.7.0 Operator Runtime Session + Real Testnet Read-only Connectivity Notes

日期：2026-06-15

执行者：Codex

## Release Type

v0.7.0 是 `Operator Runtime Session + Real Testnet Read-only Connectivity` closure docs。它收口 GitHub fallback queue `GH-779..GH-792` 的 no-order runtime session、real Binance testnet read-only probe、operator observe / recovery、read-only Dashboard / CLI evidence surface、validation command、operator runbook、Stage Code Audit 和 root docs refresh。

本文档不是 GitHub Release 发布动作，不创建 tag，不移动 tag，不发布 production cutover，不创建下一 Project / Issue。

## Scope

- GH-779：定义 v0.7.0 no-order runtime session contract。
- GH-780：加固 testnet read-only endpoint canonical policy。
- GH-781：对齐 top-level CLI run / status / verify surface。
- GH-782：加入 Dashboard / macOS CI focused guards。
- GH-783：建立 OperationalRunSession lifecycle。
- GH-784：加固 EventLogWriter runtime append / recovery。
- GH-785：建立 RunRegistry / RunSupervisor。
- GH-786：建立 real Binance testnet signed account read-only probe。
- GH-787：建立 testnet private stream read-only probe。
- GH-788：建立 Dashboard read-only run operations surface。
- GH-789：建立 local Risk policy config。
- GH-790：建立 Portfolio read-only reconciliation projection。
- GH-791：建立 v0.7.0 aggregate CI / release validation gate。
- GH-792：输出 final Stage Code Audit、release notes、operator runbook、root docs refresh 和 v0.7.0 final aggregate verification guard。

## Validation

本 closure 的本地验证入口：

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/verify-v0.7.0.sh
bash checks/run.sh
```

`checks/run.sh` 继续运行 v0.1 / v0.3 / v0.4 / v0.5 / v0.6 / v0.7 release verifiers、Dashboard build / smoke 和 Swift tests。`checks/verify-v0.7.0.sh` 是 v0.7.0 closure 的聚合验证命令，用于 operator / release closeout 复现。

## Release Notes

v0.7.0 closes the operator runtime session and real testnet read-only connectivity stage:

- Binance-only active venue remains fixed。
- Active products remain Spot + USDⓈ-M Perpetual。
- Active strategies remain EMA + RSI。
- Runtime modes remain local-dry-run / testnet-read-only-probe / recovery-observe / production-blocked。
- No-order runtime session contract fixes `noOrder=true` and production-disabled defaults。
- CLI run / status / verify surface uses v0.7.0 runtime-session semantics。
- OperationalRunSession, EventLogWriter recovery and RunRegistry / RunSupervisor evidence are guarded。
- Real Binance testnet signed account read-only probe requires explicit operator confirmation and redacts credential values。
- Testnet private stream read-only probe observes listenKey lifecycle and read-model evidence without execution command path。
- Dashboard read-only run operations expose run list / details / safe local start-stop-recover controls without trading surface。
- Local Risk policy config records max notional / exposure / kill switch / no-trade evidence。
- Portfolio read-only reconciliation explains expected vs observed state without correction command or broker write path。
- `checks/verify-v0.7.0.sh` provides a release-level local verification entry point.

## Boundary Evidence

- production trading remains disabled by default。
- no production secret auto-read。
- no production endpoint auto-connect。
- no production broker connection。
- no production order authorization。
- no signed production account endpoint / listenKey / private WebSocket runtime。
- no testnet or production submit / cancel / replace。
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
