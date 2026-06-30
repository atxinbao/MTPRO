# Release v0.20.0 Binance Spot Production-shadow Risk / Kill Switch / No-trade Readiness

日期：2026-06-30
执行者：Codex

## Contract Anchors

- GH-1247-VERIFY-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS
- TVM-RELEASE-V0200-RISK-KILL-SWITCH-NO-TRADE-READINESS
- V0200-009-BINANCE-SPOT-PRODUCTION-SHADOW-RISK-READINESS
- V0200-009-RISK-GATE-VISIBLE-FAIL-CLOSED
- V0200-009-KILL-SWITCH-BLOCKED-VISIBLE
- V0200-009-NO-TRADE-BLOCKED-VISIBLE
- V0200-009-NO-TRADING-AUTHORIZATION
- V0200-009-NO-ORDER-CAPABILITY-BYPASS
- V0200-009-NO-PRODUCTION-CUTOVER

## Scope

GH-1247 / V0200-009 只固定 Binance Spot production-shadow / read-only live readiness 阶段的
RiskEngine、kill switch、no-trade readiness evidence。该 evidence 必须让 operator 看到风险阻断状态，
同时保持 fail closed。

本合同继承：

- #1245 / GH-1245：account snapshot redaction policy 已固定，账号快照 evidence 不保存真实余额、
  account identifier、secret、raw broker payload 或 order payload。
- #1246 / GH-1246：no-order capability guard 已固定，submit / cancel / replace 与 Dashboard / CLI bypass
  均被阻断。

## Readiness Evidence Matrix

| Component | Required state | Failure class | Operator visibility | Trading authorization |
| --- | --- | --- | --- | --- |
| RiskEngine | `risk-gate-visible-fail-closed` | `trading authorization withheld` | visible | withheld |
| Kill switch | `kill-switch-blocked-visible` | `kill switch active blocks orders` | visible | withheld |
| No-trade state | `no-trade-blocked-visible` | `no-trade active blocks orders` | visible | withheld |

## Boundary

- Binance Spot only.
- Production-shadow readiness only.
- Risk / kill switch / no-trade evidence is local and redacted.
- Production trading remains disabled by default.
- No production secret value is read.
- No production endpoint / broker endpoint is connected.
- No `/api/v3/order` touch.
- No signed order material.
- No real order intent.
- No submit / cancel / replace.
- No Dashboard trading button.
- No live command or order form.
- No Spot canary.
- No Futures runtime.
- No OKX active implementation.
- No tag / GitHub Release publication.
- Production cutover not authorized.

## Validation

- `swift test --filter TargetGraphTests/testGH1247ReleaseV0200RiskKillSwitchNoTradeReadiness`
- `bash checks/verify-v0.20.0-risk-kill-switch-no-trade-readiness.sh`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
