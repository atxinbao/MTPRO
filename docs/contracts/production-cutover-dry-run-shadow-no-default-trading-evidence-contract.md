# Production Cutover Dry-Run / Shadow / No-Default-Trading Evidence Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-509 Define dry-run proof / shadow mode / production no-default-trading evidence`。

本文档定义 `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 的 dry-run proof / shadow mode / production no-default-trading evidence。它证明 production cutover 前默认路径仍然 blocked / dry-run，不会自动进入真实交易；它不实现 production execution、真实 broker shadow trading，不连接 broker，不读取真实 secret，不接 signed endpoint、account endpoint / listenKey，不提交 / 撤销 / 替换真实订单，也不新增 trading button / live command / order form。

## GH-509-DRY-RUN-PROOF-SHADOW-NO-DEFAULT-TRADING-EVIDENCE

`GH-509-DRY-RUN-PROOF-SHADOW-NO-DEFAULT-TRADING-EVIDENCE`

GH-509 依赖：

- GH-506 manual approval / operator confirmation gate
- GH-507 incident stop / rollback / no-trade gate
- GH-508 capital / risk / order notional / exposure limit gate

当前权威 source anchor：

- `Sources/ExecutionClient/FutureGate/ProductionCutoverDryRunShadowNoDefaultTradingEvidence.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH509DryRunShadowNoDefaultTradingEvidenceBindsUpstreamGatesAndReadModelSurfaces`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH509DryRunShadowNoDefaultTradingEvidenceRejectsBrokerSecretAndProductionPromotion`

## GH-509-SANDBOX-DRY-RUN-SHADOW-PRODUCTION-COMMAND-ISOLATION

`GH-509-SANDBOX-DRY-RUN-SHADOW-PRODUCTION-COMMAND-ISOLATION`

Proof mode 只允许：

- sandbox
- dry-run
- shadow
- production blocked

Sandbox / dry-run / shadow 不能 promoted to production command。

## GH-509-REPORT-DASHBOARD-EVENTS-READ-MODEL-ONLY

`GH-509-REPORT-DASHBOARD-EVENTS-READ-MODEL-ONLY`

如需在 Report / Dashboard / Events 展示 GH-509 evidence，必须保持 read-model-only。展示面不得变成 command surface，不得暴露 trading button、live command 或 order form。

## GH-509-NO-BROKER-SECRET-REAL-ORDER

`GH-509-NO-BROKER-SECRET-REAL-ORDER`

GH-509 必须拒绝：

- production execution
- real broker shadow trading
- broker connection
- secret read
- signed endpoint call
- account endpoint call
- listenKey creation
- private WebSocket open
- production trading enabled by default
- real submit / cancel / replace

## GH-509-NO-SANDBOX-TO-PRODUCTION-PROMOTION

`GH-509-NO-SANDBOX-TO-PRODUCTION-PROMOTION`

Dry-run proof 只能证明 no-default-trading remains held。任何 sandbox command、dry-run evidence、shadow evidence 或 UI / script evidence 都不能自动升级为 production command。

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
