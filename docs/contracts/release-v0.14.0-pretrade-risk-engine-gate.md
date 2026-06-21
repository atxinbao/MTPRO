# MTPRO Release v0.14.0 Pre-trade RiskEngine Gate Contract

日期：2026-06-21
执行者：Codex

## Scope

GH-1034 定义 `ReleaseV0140PreTradeRiskEngineGate`，用于在任何 ExecutionEngine submit、Binance testnet adapter request 或 OMS event handoff 之前评估 `OrderIntent`。

该 gate 只授权本地 risk decision evidence：

- Binance only。
- Product types 仅允许 Spot 与 USDⓈ-M Perpetual。
- Active strategies 仅允许 EMA 与 RSI。
- `accepted` decision 才能标记为 `adapterSubmitEligible == true`。
- `rejected` / `blocked` decision 必须保持 `adapterSubmitEligible == false`，并且不得到达 adapter submit。

## Validation Anchors

- `GH-1034-PRETRADE-RISKENGINE-GATE`
- `GH-1034-REJECTED-INTENT-NO-ADAPTER-SUBMIT`
- `GH-1034-KILL-SWITCH-NO-TRADE-MODE-GATES`
- `TVM-RELEASE-V0140-PRETRADE-RISK-GATE`

## Gate Order

`OrderIntent` 进入 testnet closed-loop 前必须按下列顺序经过 gate：

1. `OrderIntent` canonical boundary：必须是 pre-RiskEngine intent。
2. Venue / product / strategy allowlist。
3. Explicit testnet mode。
4. No-trade state。
5. Kill switch。
6. Quantity limit。
7. Product-specific notional limit。
8. Accepted decision 才允许进入后续 ExecutionEngine / Binance testnet evidence path。

## Fail-closed Rules

以下情况必须 fail closed：

- 非 Binance venue。
- 非 Spot / USDⓈ-M Perpetual product。
- 非 EMA / RSI strategy。
- explicit testnet mode 缺失。
- no-trade state active。
- kill switch active。
- quantity limit exceeded。
- notional limit exceeded。
- production trading requested。
- execution submit already attempted before risk decision。
- rejected / blocked decision 仍试图标记 adapter submit eligible。

## Boundary

该合同不实现：

- production trading。
- production secret read。
- production endpoint / broker endpoint connection。
- signed endpoint / account endpoint / listenKey。
- private stream runtime。
- real submit / cancel / replace。
- production OMS。
- broker fill / reconciliation runtime。
- Dashboard trading button、live command 或 production order form。
- production cutover authorization。

## Validation

Focused validation:

```bash
bash checks/verify-v0.14.0-pretrade-risk-engine-gate.sh
```

Full closeout validation:

```bash
git diff --check
bash checks/automation-readiness.sh
bash checks/run.sh
```
