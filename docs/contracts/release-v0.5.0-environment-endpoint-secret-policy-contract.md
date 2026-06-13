# Release v0.5.0 Environment / Endpoint / Secret Policy Contract

日期：2026-06-14

执行者：Codex

本文档服务 GitHub fallback issue `GH-728 V050-03 EnvironmentProfile / EndpointPolicy / SecretProfileRef`。

GH-728 只定义 v0.5.0 的 environment profile、endpoint policy 和 secret profile reference。它不读取 secret、不连接 endpoint、不创建 broker gateway、不发送真实订单、不授权 production cutover。

## V050-03-ENVIRONMENT-PROFILE-ENDPOINT-SECRET-POLICY

`V050-03-ENVIRONMENT-PROFILE-ENDPOINT-SECRET-POLICY`

权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ReleaseV050EnvironmentEndpointSecretPolicy.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH728EnvironmentEndpointSecretPolicyFailsClosed`
- `checks/verify-v0.5.0-environment.sh`
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RELEASE-V050-ENVIRONMENT-ENDPOINT-SECRET-POLICY`

合同固定：

- issue：`GH-728`
- upstream issue：`GH-726`
- previous issue：`GH-727`
- queue range：`GH-726..GH-739`
- downstream issues：`GH-732`、`GH-733`、`GH-738`、`GH-739`
- project：`MTPRO Release v0.5.0 Guarded Testnet Runtime Foundation / Deterministic-to-Operational Bridge`

## V050-03-DRYRUN-NO-SECRET-NO-ENDPOINT

`V050-03-DRYRUN-NO-SECRET-NO-ENDPOINT`

`dry-run` profile 必须满足：

- endpoint policy 不允许 endpoint resolution。
- endpoint reference 为 `none`。
- secret profile kind 为 `no secret required`。
- secret profile 只记录 `local-dry-run-no-secret` reference。
- 不读取 secret value。
- 不连接 endpoint。
- 不 fallback 到 production。

## V050-03-TESTNET-HTTPS-ALLOWLIST-POLICY

`V050-03-TESTNET-HTTPS-ALLOWLIST-POLICY`

`testnet-guarded` profile 必须满足：

- 只允许显式 testnet policy。
- required scheme 必须是 `https`。
- allowed hosts 只能是：
  - `testnet.binance.vision`
  - `testnet.binancefuture.com`
- forbidden production hosts 必须保持：
  - `api.binance.com`
  - `fapi.binance.com`
- product binding 只能是：
  - `spot`
  - `usdsPerpetual`
- non-HTTPS testnet URL 必须失败。
- production host 必须失败。
- 不打开网络连接。

## V050-03-PRODUCTION-BLOCKED-FAILS-CLOSED

`V050-03-PRODUCTION-BLOCKED-FAILS-CLOSED`

`production-blocked` profile 必须 fail closed：

- endpoint resolution 永远不允许。
- production secret resolution 永远被阻断。
- production endpoint connection 仍为 `false`。
- production trading default 仍为 `false`。
- real order authorization 仍为 `false`。
- production cutover 仍为 `false`。

## V050-03-SECRET-PROFILE-REFERENCE-ONLY

`V050-03-SECRET-PROFILE-REFERENCE-ONLY`

`SecretProfileRef` 只允许 reference identity：

- `profileReference` 必须非空。
- `containsSecretValue == false`。
- `resolvesSecretValue == false`。
- `productionSecretResolutionBlocked == true`。
- 不读取环境变量。
- 不读取 keychain。
- 不保存 API key / secret value。

## TVM-RELEASE-V050-ENVIRONMENT-ENDPOINT-SECRET-POLICY

`TVM-RELEASE-V050-ENVIRONMENT-ENDPOINT-SECRET-POLICY`

Required validation：

- `swift test --filter TargetGraphTests/testGH728EnvironmentEndpointSecretPolicyFailsClosed`
- `bash checks/verify-v0.5.0-environment.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## Non-authorization

GH-728 不授权：

- Linear / Symphony / Graphify / code-index / Figma。
- production secret read。
- production endpoint connection。
- broker gateway。
- signed endpoint runtime。
- private stream runtime。
- real submit / cancel / replace。
- production OMS。
- Live PRO Console production command。
- production cutover。
- 下一 Project / Issue / milestone 自动启动。
