# Release v0.21.0 Binance Spot Canary Environment Profile

日期：2026-07-01  
执行者：Codex

## Scope

GH-1274 固定 `MTPRO Release v0.21.0 Binance Spot Controlled Production Canary`
的 environment profile。该 profile 只表达 Binance Spot、`productionLive` typed
identity、default-off fail-closed policy 和显式 Human operator opt-in evidence 需求。

验证锚点：

- `GH-1274-VERIFY-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE`
- `TVM-RELEASE-V0210-SPOT-CANARY-ENVIRONMENT-PROFILE`
- `V0210-002-BINANCE-SPOT-CANARY-PROFILE`
- `V0210-002-DEFAULT-OFF-FAIL-CLOSED`
- `V0210-002-OPERATOR-OPT-IN-EVIDENCE`
- `V0210-002-NO-SECRET-ENDPOINT-ORDER`
- `V0210-002-NO-PRODUCTION-CUTOVER`

## Contract

GH-1274 依赖 GH-1273 的 controlled canary contract，并为 GH-1275 之后的
credential / preflight / read-only / guarded command gate 提供环境 profile 输入。

| Field | Required Value |
| --- | --- |
| Issue | `GH-1274` |
| Upstream | `GH-1273` |
| Downstream | `GH-1275` |
| Queue | `GH-1273..GH-1286` |
| Venue | Binance |
| Product | Spot |
| Environment identity | `productionLive` identity only |
| Activation default | off / fail-closed |
| Operator evidence | explicit Human operator opt-in evidence required |
| Production cutover | not authorized |

## Fail-Closed Rules

- `ReleaseV0210SpotCanaryEnvironmentProfile` defaults to
  `defaultOffAwaitingOperatorOptInEvidence`.
- `canaryActivationEnabled` must remain false in GH-1274.
- A canary activation request without explicit operator opt-in evidence is rejected.
- Recording operator opt-in evidence still leaves GH-1274 fail-closed; later issues must
  prove credential, endpoint, RiskEngine, kill switch, no-trade, hard-limit and command gates.

## Forbidden Capabilities

GH-1274 does not read production secret, does not store raw credential, does not connect
production endpoint / broker endpoint, does not implement signed account endpoint runtime,
does not implement private stream runtime, does not submit / cancel / replace orders, does
not add Dashboard trading button / order form / live command, does not include Futures or
OKX active implementation, does not create tag / GitHub Release and does not authorize
production cutover.

This document intentionally contains no API key, no secret key and no production endpoint
connection instruction.

## Validation

Required commands:

- `swift test --filter TargetGraphTests/testGH1274ReleaseV0210SpotCanaryEnvironmentProfile`
- `bash checks/verify-v0.21.0-spot-canary-environment-profile.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
