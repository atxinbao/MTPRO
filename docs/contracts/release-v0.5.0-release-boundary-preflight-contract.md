# Release v0.5.0 Boundary / Preflight Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-726 V050-01 Release boundary & preflight contract`。

本文档定义 `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge` 的第一层 release boundary、preflight gate、validation matrix 和 forbidden surfaces。它只授权后续 V050 issues 在 GitHub fallback queue 的 WIP=1 规则下逐步实现 guarded runtime foundation；不实现 runtime、不读取 secret、不连接 testnet 或 production endpoint、不提交 / 取消 / 替换真实订单、不授权 production cutover。

## V050-01-RELEASE-BOUNDARY-PREFLIGHT-CONTRACT

`V050-01-RELEASE-BOUNDARY-PREFLIGHT-CONTRACT`

GH-726 是 V050 queue `GH-726..GH-739` 的第一个 gate。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ReleaseV050ReleaseBoundaryPreflightContract.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH726ReleaseV050BoundaryPreflightContractDefinesGuardedRuntimeFoundation`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V050-BOUNDARY-PREFLIGHT-CONTRACT`
- `checks/verify-v0.5.0-preflight.sh`

合同固定：

- release version 固定为 `v0.5.0`
- project name 固定为 `MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge`
- active venue 只能是 `Binance`
- active product types 只能是 `spot` 和 `usdsPerpetual`
- active strategies 只能是 `EMA` 和 `RSI`
- queue range 固定为 `GH-726..GH-739`
- downstream issue 固定为 `GH-727` 至 `GH-739`
- 后续 issue 执行前必须通过 GitHub fallback queue preflight
- production capability defaults 必须继续关闭。

## V050-01-GUARDED-RUNTIME-FOUNDATION

`V050-01-GUARDED-RUNTIME-FOUNDATION`

v0.5.0 的定位是 guarded runtime foundation / deterministic-to-operational bridge。它允许后续 issue 把 v0.4.0 的 deterministic rehearsal evidence 逐步桥接到 operational dry-run 和 guarded testnet foundation，但每一步仍必须保留：

- 单 issue WIP=1。
- 当前 issue contract first。
- v0.4.0 verification preserved。
- local deterministic validation first。
- no production cutover。
- no real order authorization。

GH-726 本身只定义边界和 preflight，不实现 runtime runner、message bus actor、journal、RiskEngine runner、ExecutionEngine / OMS lifecycle、Dashboard observer 或 CI hardening。

## V050-01-DRYRUN-TESTNET-PRODUCTION-BLOCKED-MODES

`V050-01-DRYRUN-TESTNET-PRODUCTION-BLOCKED-MODES`

v0.5.0 允许的 mode 固定为：

- `dry-run`
- `testnet-guarded`
- `production-blocked`

`dry-run` 必须继续是默认 mode。`testnet-guarded` 只表示后续 issue 可以在显式 operator confirmation 下定义 testnet-only boundary；GH-726 不连接 testnet network，不读取 testnet credential value，不签名请求，不发送 testnet order。`production-blocked` 只表示生产路径阻断证据，不是 production runtime、production endpoint connector、production broker adapter 或 production order authorization。

## V050-01-BINANCE-SPOT-PERP-EMA-RSI-ONLY

`V050-01-BINANCE-SPOT-PERP-EMA-RSI-ONLY`

v0.5.0 继续锁定 release active scope：

- `allowedVenue == Binance`
- `allowedProductTypes == [spot, usdsPerpetual]`
- `allowedStrategies == [EMA, RSI]`

任何非 Binance venue、Spot / USDⓈ-M Perpetual 之外的 product type、EMA / RSI 之外的 active strategy 都不属于 GH-726 scope。

## V050-01-PREFLIGHT-REQUIREMENTS

`V050-01-PREFLIGHT-REQUIREMENTS`

后续 V050 issue 在执行前必须满足：

- GitHub fallback queue `WIP=1`。
- 当前无 `todo` / `in-progress` / `in-review` active conflict。
- 当前 issue body 已读取，并以 Goal / Scope / Non-goals / Validation / Boundary / Acceptance Criteria 为执行合同。
- dependencies 已完成。
- `main == origin/main`，worktree clean。
- v0.4.0 verification remains preserved。
- `dry-run` remains default mode。
- `testnet-guarded` requires explicit operator confirmation。
- `production-blocked` remains default production posture。
- Binance-only、Spot + USDⓈ-M Perpetual-only、EMA + RSI-only。
- no production secret read。
- no production endpoint connection。
- no real order authorization。
- `checks/verify-v0.5.0-preflight.sh` exists and passes.

Machine-readable preflight requirement IDs：

- GitHub fallback queue WIP=1
- no todo / in-progress / in-review conflict
- previous release verification remains preserved
- current issue contract is read before work
- dry-run remains default mode
- testnet requires explicit operator confirmation
- production remains blocked by default
- Binance-only scope
- Spot and USDⓈ-M Perpetual only
- EMA and RSI only
- no production secret read
- no production endpoint connection
- no real order authorization
- verify-v0.5.0-preflight command exists

## V050-01-FORBIDDEN-PRODUCTION-CAPABILITIES

`V050-01-FORBIDDEN-PRODUCTION-CAPABILITIES`

GH-726 必须保持以下默认关闭或禁止：

- `productionTradingEnabledByDefault == false`
- `productionSecretReadEnabled == false`
- `productionEndpointConnectionEnabled == false`
- `productionBrokerConnectionEnabled == false`
- `realOrderSubmitCancelReplaceEnabled == false`
- `productionCutoverAuthorized == false`
- `startsNextMilestone == false`

Machine-readable forbidden capability IDs：

- production cutover authorization
- production trading enabled by default
- production secret read
- production endpoint connection
- production broker connection
- real submit / cancel / replace
- trading button or order form
- Live PRO Console command
- non-Binance venue
- unsupported product type
- unsupported active strategy
- RiskEngine / ExecutionEngine / OMS bypass
- next milestone auto-start

本文档不创建 secret provider、signed request runtime、listenKey runtime、private stream runtime、broker adapter、production OMS、real submit / cancel / replace path、trading button、order form、Live PRO Console command 或 production cutover path。

## TVM-RELEASE-V050-BOUNDARY-PREFLIGHT-CONTRACT

`TVM-RELEASE-V050-BOUNDARY-PREFLIGHT-CONTRACT`

Required validation：

- `swift test --filter TargetGraphTests/testGH726ReleaseV050BoundaryPreflightContractDefinesGuardedRuntimeFoundation`
- `bash checks/verify-v0.5.0-preflight.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

后续 issues 必须逐项回填：

- V050-02 Strict CLI command parser。
- V050-03 EnvironmentProfile / EndpointPolicy / SecretProfileRef。
- V050-04 Precision primitives / InstrumentCatalog。
- V050-05 Typed RuntimeMessageBus actor。
- V050-06 Durable local run journal。
- V050-07 DataEngine operational dry-run path。
- V050-08 Testnet read-only integration gate。
- V050-09 RiskEngine runtime runner。
- V050-10 ExecutionEngine / OMS dry-run lifecycle。
- V050-11 Portfolio projection from run journal。
- V050-12 Dashboard / CLI run observer。
- V050-13 CI hardening。
- V050-14 Operator runbook / final audit。

## V050-01 Non-authorization

GH-726 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- runtime implementation。
- testnet endpoint connection。
- testnet credential value read。
- production trading。
- production secret read。
- production endpoint connection。
- production broker connection。
- production order submission。
- production cutover authorization。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS。
- Live PRO Console production command。
- trading button / live command / order form。
- 非 Binance venue。
- Spot / USDⓈ-M Perpetual 之外的 product type。
- EMA / RSI 之外的 active strategy。
- 下一 Project / Issue / milestone 自动启动。
