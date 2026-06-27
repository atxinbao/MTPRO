# Release v0.17.0 Beta Safety Policy Profile Evidence Contract

日期：2026-06-27
执行者：Codex

## #1147 / GH-1147

`GH-1147-VERIFY-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE`

GH-1147 只为 `MTPRO Release v0.17.0 Operator Beta Artifact + Status Runtime Hardening` 增加 active safety policy profile evidence。该 evidence 必须显式记录：

- `TVM-RELEASE-V0170-BETA-SAFETY-POLICY-PROFILE-EVIDENCE`
- `V0170-009-ACTIVE-SAFETY-POLICY-PROFILE`
- `V0170-009-VENUE-PRODUCT-SYMBOL-LIMITS`
- `V0170-009-NOTIONAL-LIMIT-EVIDENCE`
- `V0170-009-ORDER-COUNT-LIMIT-EVIDENCE`
- `V0170-009-PRODUCTION-GUARD-STATE`
- `V0170-009-REDACTED-POLICY-EVIDENCE`
- `V0170-009-NO-PRODUCTION-CUTOVER`

## Contract

`ReleaseV0170BetaSafetyPolicyProfileEvidence` 是唯一的 GH-1147 evidence surface。它继承 `ReleaseV0160BetaSafetyGuardEvidence`，并把 operator beta 的 active safety policy profile 固定为：

- venue：`Binance`
- product type：`spot`
- symbol allowlist：`BTCUSDT`、`ETHUSDT`
- quote currency：`USDT`
- max notional：`25.0 USDT`
- max orders per run：`1`
- production guard state：全部 disabled / unauthorized

Evidence 必须同时证明：

- active safety policy profile 已记录；
- venue / product / symbol limit 已记录并通过；
- notional limit 已记录并通过；
- order-count limit 已记录并通过；
- inherited GH-1110 safety guard evidence 已通过；
- production trading、production secret read、production endpoint、broker endpoint、production submit / cancel / replace 和 production cutover 均未启用。

## Validation

```bash
swift test --filter TargetGraphTests/testGH1147ReleaseV0170BetaSafetyPolicyProfileEvidence
bash checks/verify-v0.17.0-beta-safety-policy-profile-evidence.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Boundary

GH-1147 不新增 runtime pipeline，不读取 credential value，不连接 testnet / production endpoint，不发送 testnet 或 production order，不实现 broker adapter，不授权 production cutover，不创建 tag / GitHub Release。
