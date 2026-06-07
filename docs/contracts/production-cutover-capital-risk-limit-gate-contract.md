# Production Cutover Capital / Risk / Order Notional / Exposure Limit Gate Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-508 Define capital / risk / order notional / exposure limit gate`。

本文档定义 `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 的 capital / risk / order notional / exposure limit gate。它只用 readiness evidence 表达资金、风险、订单名义金额和敞口限制，不实现真实 live risk engine、production pre-trade allow / reject runtime、capital allocation runtime、OMS、broker gateway、真实账户读取、broker position / margin / leverage / PnL 读取或真实 submit / cancel / replace。

## GH-508-CAPITAL-RISK-NOTIONAL-EXPOSURE-LIMIT-GATE

`GH-508-CAPITAL-RISK-NOTIONAL-EXPOSURE-LIMIT-GATE`

GH-508 依赖：

- GH-505 broker / venue capability matrix
- GH-506 manual approval / operator confirmation gate

当前权威 source anchor：

- `Sources/RiskEngine/LiveGate/ProductionCutoverCapitalRiskLimitGate.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH508CapitalRiskLimitGateBindsBrokerMatrixAndManualApproval`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH508CapitalRiskLimitGateRejectsLiveRiskRuntimeAndAccountReads`

## GH-508-BINDS-GH505-GH506

`GH-508-BINDS-GH505-GH506`

Limit evidence 必须同时绑定：

- GH-505 broker / venue capability matrix
- GH-506 manual approval gate

RiskEngine target 不依赖 ExecutionClient；该绑定通过 issue ID 和 readiness evidence 完成，不形成 target graph 反向依赖。

## GH-508-DRY-RUN-BLOCKED-NO-TRADE-LIMIT-EVIDENCE

`GH-508-DRY-RUN-BLOCKED-NO-TRADE-LIMIT-EVIDENCE`

Limit state 只允许：

- blocked
- dry-run-only
- no-trade
- future-gated

覆盖维度必须包含：

- capital
- risk
- order notional
- exposure

## GH-508-NO-LIVE-RISK-PRETRADE-RUNTIME

`GH-508-NO-LIVE-RISK-PRETRADE-RUNTIME`

GH-508 不授权 live risk engine 或 production pre-trade allow / reject runtime。Production default 必须保持 no-trading / blocked / dry-run，不能默认允许真实交易。

## GH-508-NO-REAL-ACCOUNT-BROKER-MARGIN-READ

`GH-508-NO-REAL-ACCOUNT-BROKER-MARGIN-READ`

GH-508 必须拒绝：

- real account balance read
- broker position read
- margin / leverage read
- real PnL read
- capital allocation runtime
- broker connection
- OMS implementation
- broker gateway implementation
- production trading enabled by default
- real submit / cancel / replace

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
