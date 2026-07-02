# Release v0.21.0 Binance Spot Canary Hard Limits

日期：2026-07-02

执行者：Codex

本文档服务 GitHub fallback issue `GH-1278 V0210-006 Add canary symbol / notional / order type hard limits`。

GH-1278 固定 `MTPRO Release v0.21.0 Binance Spot Controlled Production Canary`
的 canary symbol / notional / order type hard limits。它消费 GH-1277 的
redacted live account snapshot artifact，只输出本地 pre-trade eligibility 和
fail-closed rejection evidence；不创建真实 broker order，不触达 order endpoint，
不提交 / 取消 / 替换订单，不创建 tag / GitHub Release，不授权 production cutover。

## Anchors

- `GH-1278-VERIFY-V0210-CANARY-HARD-LIMITS`
- `TVM-RELEASE-V0210-CANARY-HARD-LIMITS`
- `V0210-006-CANARY-SYMBOL-ALLOWLIST`
- `V0210-006-NOTIONAL-QUANTITY-CAPS`
- `V0210-006-ORDER-TYPE-COUNT-WINDOW-LIMITS`
- `V0210-006-PRE-TRADE-FAIL-CLOSED`
- `V0210-006-NO-SUBMIT-CANCEL-REPLACE`
- `V0210-006-NO-PRODUCTION-CUTOVER`

## Scope

GH-1278 是 Binance Spot controlled production canary 的 hard-limit pre-trade
gate。它固定以下 deterministic limits，并显式覆盖 symbol allowlist、notional、
quantity、order count 和 time window：

| Field | Required value | Purpose |
| --- | --- | --- |
| Issue | `GH-1278` | 当前 GitHub fallback issue |
| Upstream | `GH-1276`, `GH-1277` | Signed account read-only preflight 和 live account snapshot redaction |
| Downstream | `GH-1279` | Guarded Binance Spot small canary submit path |
| Venue / product | `Binance` / `spot` | v0.21.0 唯一 active production canary product |
| Trading environment | `production-live` | 只作为 gated canary identity，不代表 production cutover |
| Symbol allowlist | `BTCUSDT` | 不允许动态 symbol universe |
| Allowed order type | `LIMIT` | `MARKET` / stop variants 必须 fail closed |
| Max notional | `1000` minor quote units, scale `2` | 也就是 `10.00 USDT` 上限 |
| Max quantity | `100000` base minor units, scale `8` | 也就是 `0.00100000 BTC` 上限 |
| Max order count | `1` per window | 同一窗口内最多一个 canary candidate |
| Time window | `300` seconds | 超出窗口必须 fail closed |

## Required fail-closed cases

GH-1278 必须记录以下 rejection evidence：

- Symbol not allowed：非 `BTCUSDT` candidate fail closed。
- Notional limit exceeded：`notionalMinorUnits > 1000` fail closed。
- Quantity limit exceeded：`quantityBaseMinorUnits > 100000` fail closed。
- Order type not allowed：非 `LIMIT` fail closed。
- Order count limit exceeded：同一窗口 `orderCountInWindow > 1` fail closed。
- Time window closed：`requestedAt - windowStartedAt` 不在 `0...300` 秒内 fail closed。

Accepted candidate 只能表示 `canaryOrderCreationEligible=true` 的本地 eligibility。
它仍然保持 `forwardsToExecutionEngine=false`、`adapterSubmitEligible=false`、
`submitCancelReplaceEnabled=false` 和 `productionCutoverAuthorized=false`。

## Boundary

GH-1278 does not read production secret value, does not persist credential value,
does not connect production endpoint / broker endpoint, does not persist raw order
payload, does not touch order endpoint, does not submit / cancel / replace, does
not add Dashboard trading button / order form / live command, does not include
Futures or OKX active implementation, does not create tag / GitHub Release and
does not authorize production cutover.

## Validation

- `swift test --filter TargetGraphTests/testGH1278ReleaseV0210CanaryHardLimitPreTradeGate`
- `bash checks/verify-v0.21.0-canary-hard-limits.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
