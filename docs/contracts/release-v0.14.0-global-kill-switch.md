# MTPRO Release v0.14.0 Global Kill Switch Contract

日期：2026-06-21
执行者：Codex

## Scope

GH-1035 定义 `ReleaseV0140GlobalKillSwitch`，用于在 v0.14.0 testnet closed loop 中统一阻断 submit / cancel / replace。

该 gate 只授权本地 command shutdown evidence：

- Binance only。
- Command kinds 固定为 submit、cancel、replace。
- Kill switch active 时，三类 command 都必须 `requestMappingAllowed == false` 且 `adapterActionAllowed == false`。
- Cancel / replace 必须显式携带本地 OMS order identity；缺失 identity 时必须 fail closed。
- 每个 blocked decision 都必须输出 audit evidence。

## Validation Anchors

- `GH-1035-GLOBAL-KILL-SWITCH`
- `GH-1035-SUBMIT-CANCEL-REPLACE-BLOCKED`
- `GH-1035-AUDIT-EVIDENCE`
- `TVM-RELEASE-V0140-GLOBAL-KILL-SWITCH`

## Gate Order

Global kill switch 必须位于任何 adapter request mapping / adapter action 之前：

1. Submit 先消费 GH-1034 `ReleaseV0140PreTradeRiskDecision`。
2. Cancel / replace 先证明本地 OMS order identity 存在。
3. Global kill switch / no-trade state 统一评估。
4. 被阻断 command 必须进入 `.failedClosed` evidence。
5. 只有 gate inactive 且前置 evidence 齐备时，才允许后续 testnet-only evidence 继续评估。

## Cancel / Replace Boundary

Cancel / replace 的行为必须显式：

- `localOrderID == nil` 时，block reason 必须包含 `missingLocalOMSOrderIdentity`。
- `killSwitchActive == true` 时，即使 local order identity 存在，也必须阻断。
- `noTradeStateActive == true` 时，必须阻断。
- Blocked cancel / replace 不得创建 request mapping、adapter request、network action 或 production command。

## Forbidden Boundary

本 issue 不授权：

- production trading。
- production secret read。
- production endpoint / broker endpoint connection。
- real submit / cancel / replace。
- broker fill / reconciliation runtime。
- Dashboard trading button、order form 或 live command。
- production cutover。

## Validation

必须通过：

```bash
swift test --filter TargetGraphTests/testGH1035ReleaseV0140GlobalKillSwitchBlocksSubmitCancelReplaceAndAudits
bash checks/verify-v0.14.0-global-kill-switch.sh
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```

## Rollback

回滚本 issue 时，删除：

- `Sources/RiskEngine/LiveGate/ReleaseV0140GlobalKillSwitch.swift`
- `checks/verify-v0.14.0-global-kill-switch.sh`
- `TargetGraphTests/testGH1035ReleaseV0140GlobalKillSwitchBlocksSubmitCancelReplaceAndAudits`
- 本合同文档

不得移动 v0.14.0 release gate，不得打开 production trading。
