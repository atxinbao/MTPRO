# Release v0.3.0 Runtime Environment Config Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-658 V030-02 Add unified runtime environment config`。

本文档定义 `MTPRO Release v0.3.0 Runtime Rehearsal v1` 的统一 runtime environment config 合同。它绑定 GH-657 的 rehearsal contract，只表达 dry-run / testnet / shadow / production-blocked 环境配置和 transition evidence，不打开 production trading，不读取 production secret，不连接 production endpoint，不提交真实订单，不授权 production cutover。

## V030-02-RUNTIME-ENVIRONMENT-CONFIG

`V030-02-RUNTIME-ENVIRONMENT-CONFIG`

GH-658 是 V030 queue `GH-657..GH-670` 的第二个 gate，并依赖 GH-657。当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ReleaseV030RuntimeEnvironmentConfig.swift`
- `docs/contracts/release-v0.3.0-runtime-rehearsal-contract.md`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH658RuntimeEnvironmentConfigDefaultsSafeAndRejectsProductionTransitions`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V030-RUNTIME-ENVIRONMENT-CONFIG`

合同固定：

- upstream issue 固定为 `GH-657`
- downstream issue 固定为 `GH-659`
- queue range 固定为 `GH-657..GH-670`
- project name 继承 `MTPRO Release v0.3.0 Runtime Rehearsal v1`
- default mode 固定为 `dry-run`
- allowed default modes 只能是 `dry-run` 和 `production-blocked`
- mode config 必须覆盖 dry-run、testnet、shadow、production-blocked。

## V030-02-DRYRUN-TESTNET-SHADOW-PRODUCTION-BLOCKED-MODES

`V030-02-DRYRUN-TESTNET-SHADOW-PRODUCTION-BLOCKED-MODES`

每个 mode 必须有明确 endpoint / credential policy：

| Mode | Endpoint policy | Credential policy |
| --- | --- | --- |
| `dry-run` | `local fixture endpoint only` | `local fixture credential reference` |
| `testnet` | `Binance testnet endpoint reference only` | `testnet profile reference` |
| `shadow` | `shadow replay endpoint evidence only` | `shadow redacted reference` |
| `production-blocked` | `production blocked no endpoint` | `production secret unavailable` |

这些 policy 都是 deterministic evidence，不是 production endpoint connector、secret provider、broker adapter 或 order runtime。

## V030-02-SAFE-DEFAULT-MODE

`V030-02-SAFE-DEFAULT-MODE`

Default mode 必须保持 safe default：

- `defaultMode == dry-run`
- `allowedDefaultModes == [dry-run, production-blocked]`
- `productionTradingEnabledByDefault == false`
- `productionOrderSubmissionEnabled == false`
- `productionCutoverAuthorized == false`

`testnet` 和 `shadow` 不能成为默认 mode。Production 不存在可选 mode，只能保持 `production-blocked` evidence。

## V030-02-NO-PRODUCTION-SECRET-AUTO-READ

`V030-02-NO-PRODUCTION-SECRET-AUTO-READ`

GH-658 不读取、探测、打印、保存或推导 production secret。

Required evidence：

- `productionSecretAutoReadEnabled == false`
- every mode config has `readsProductionSecret == false`
- every transition has `readsProductionSecret == false`

## V030-02-NO-PRODUCTION-ENDPOINT-AUTO-CONNECT

`V030-02-NO-PRODUCTION-ENDPOINT-AUTO-CONNECT`

GH-658 不连接 production endpoint，也不允许 dry-run、testnet、shadow、Dashboard、CLI、hidden flag 或 transition 自动切换到 production endpoint。

Required evidence：

- `productionEndpointAutoConnectEnabled == false`
- every mode config has `autoConnectsProductionEndpoint == false`
- every transition has `autoConnectsProductionEndpoint == false`

## V030-02-INVALID-ENVIRONMENT-TRANSITION-FAIL-CLOSED

`V030-02-INVALID-ENVIRONMENT-TRANSITION-FAIL-CLOSED`

Allowed transition 只包含：

- `production-blocked -> dry-run`
- `dry-run -> testnet`
- `dry-run -> shadow`
- `testnet -> shadow`
- `dry-run -> production-blocked`
- `testnet -> production-blocked`
- `shadow -> production-blocked`

不在 allowlist 内的 transition 必须 fail closed。任何 transition 都不得读取 production secret、连接 production endpoint、启用 production trading、提交 production order 或授权 production cutover。

## TVM-RELEASE-V030-RUNTIME-ENVIRONMENT-CONFIG

`TVM-RELEASE-V030-RUNTIME-ENVIRONMENT-CONFIG`

Required validation：

- `swift test --filter TargetGraphTests/testGH658RuntimeEnvironmentConfigDefaultsSafeAndRejectsProductionTransitions`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## V030-02 Non-authorization

GH-658 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- production trading。
- production secret auto-read。
- production endpoint auto-connect。
- production order submission。
- production cutover authorization。
- broker adapter / real broker connection。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS。
- Live PRO Console production command。
- trading button / live command / order form。
- 非 Binance venue。
- Spot / USDⓈ-M Perpetual 之外的 product type。
- EMA / RSI 之外的 active strategy。
- Dashboard / CLI 旁路 CommandGateway。
- Strategy 直连 ExecutionClient 或 Binance adapter。
- 下一 Project / Issue / milestone 自动启动。
