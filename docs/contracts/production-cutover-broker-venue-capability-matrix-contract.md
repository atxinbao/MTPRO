# Production Cutover Broker / Venue Capability Matrix Contract

日期：2026-06-07

执行者：Codex

本文档服务 GitHub fallback issue `GH-505 Define broker / venue selection and capability matrix`。

本文档定义 `MTPRO Production Cutover Readiness / Real Broker Enablement Gate v1` 的 broker / venue capability matrix。它只表达候选 broker / venue 的 capability、限制、禁用项和 future gate，不选择真实生产 broker 作为执行授权，不实现 broker adapter，不连接 exchange / broker，不接 signed endpoint、account endpoint / listenKey，不实现 execution report、broker fill、reconciliation 或真实订单生命周期。

## GH-505-BROKER-VENUE-CAPABILITY-MATRIX

`GH-505-BROKER-VENUE-CAPABILITY-MATRIX`

GH-505 依赖 GH-503 credential / secret policy gate 和 GH-504 environment isolation gate。当前权威 source anchor：

- `Sources/ExecutionClient/BrokerCapabilityMatrix/ProductionCutoverBrokerVenueCapabilityMatrix.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH505BrokerVenueCapabilityMatrixBindsCredentialAndEnvironmentGates`
- `Tests/TargetGraphTests/TargetGraphTests.swift` 的 `testGH505BrokerVenueCapabilityMatrixRejectsAdapterEndpointAndOrderBypass`

## GH-505-CAPABILITY-TAXONOMY

`GH-505-CAPABILITY-TAXONOMY`

Capability matrix 必须覆盖：

- public data
- signed trading
- account read
- private stream
- order lifecycle
- execution report
- broker fill
- reconciliation

允许状态只限：

- unsupported
- blocked
- dry-run-only
- future-gated

## GH-505-BROKER-SELECTION-EVIDENCE-BINDS-GH503-GH504

`GH-505-BROKER-SELECTION-EVIDENCE-BINDS-GH503-GH504`

Broker / venue selection evidence 必须同时绑定：

- GH-503 credential / secret policy gate
- GH-504 production environment isolation gate

Matrix row 只能说明 capability state 和 evidence，不得变成 adapter implementation 或 endpoint call。

## GH-505-NO-BROKER-ADAPTER-IMPLEMENTATION

`GH-505-NO-BROKER-ADAPTER-IMPLEMENTATION`

GH-505 不授权：

- broker adapter implementation
- broker connection
- signed endpoint call
- account endpoint call
- listenKey creation
- private WebSocket open

## GH-505-NO-REAL-ENDPOINT-OR-ORDER-CAPABILITY

`GH-505-NO-REAL-ENDPOINT-OR-ORDER-CAPABILITY`

Matrix 不能触发：

- real order lifecycle
- submit / cancel / replace
- execution report parser
- broker fill parser
- reconciliation runtime

Required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS
