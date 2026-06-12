# Release v0.3.0 Binance Adapter Rehearsal Contract

日期：2026-06-13

执行者：Codex

本文档定义 GH-663 / V030-07 的 Binance testnet / dry-run adapter rehearsal 合同。该合同只授权本地 deterministic evidence、redacted request mapping 和 testnet acknowledgement evidence；不授权 production trading、production secret、production endpoint、真实 broker connection 或真实订单。

## V030-07-BINANCE-TESTNET-DRYRUN-ADAPTER-REHEARSAL

- Issue：GH-663。
- Upstream：GH-662 / `TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE`。
- Downstream：GH-664。
- Queue range：GH-657..GH-670。
- Release：v0.3.0。
- Project：MTPRO Release v0.3.0 Runtime Rehearsal v1。

GH-663 只能消费 GH-662 的 OMS rehearsal identity / event log / order ID / validation anchor。`ExecutionClient` target 不依赖 `ExecutionEngine` target，因此本合同要求 adapter rehearsal 保存稳定 handoff identity，而不是跨 target import `ReleaseV030ExecutionOMSRehearsalEvidence`。

## V030-07-SUBMIT-CANCEL-REPLACE-MAPPING

GH-663 必须覆盖以下 command mapping：

- Spot submit / cancel / replace。
- USDⓈ-M Perpetual submit / cancel / replace。
- dry-run mapping。
- testnet mapping。

Mapping 只允许保存 redacted query items、HTTP method、endpoint path、testnet host identity、client order ID 和 source OMS handoff identity。Mapping 不保存 signature value、API key、secret value、raw broker payload、production host 或 response payload。

## V030-07-DRYRUN-EVIDENCE

Dry-run evidence 必须满足：

- 不执行 network call。
- 不连接 production endpoint。
- 不读取 production secret。
- 不提交 production order。
- 保留 Spot / Perp product identity。
- 保留 submit / cancel / replace command identity。
- 保留 GH-662 source OMS handoff identity。

## V030-07-TESTNET-EVIDENCE

Testnet evidence 必须满足：

- 使用 Binance testnet host identity。
- 只输出 deterministic acknowledgement evidence。
- submit / cancel / replace 均有 acknowledgement。
- acknowledgement 不代表 broker fill、execution report、portfolio reconciliation 或 production order lifecycle。
- MessageBus append-only replay 必须能恢复 mapping / acknowledgement evidence sequence。

## V030-07-PRODUCTION-ENDPOINT-BLOCKED

Production endpoint 必须默认阻断：

- 不允许 `api.binance.com`。
- 不允许 `fapi.binance.com`。
- 不允许 production endpoint auto-connect。
- 不允许 production secret auto-read。
- 不允许 production order submission。
- 不允许 production cutover authorization。

## V030-07-NO-RAW-BROKER-PAYLOAD-DASHBOARD

Dashboard / CLI 只能消费后续 read-model evidence，不能消费 raw broker payload。本合同禁止：

- raw broker payload 暴露给 Dashboard。
- Dashboard / CLI bypass CommandGateway。
- Strategy 直接访问 ExecutionClient 或 Binance adapter。
- RiskEngine / OMS / Event Store gate bypass。

## TVM-RELEASE-V030-BINANCE-ADAPTER-REHEARSAL

Validation evidence 必须同时落在：

- `Sources/ExecutionClient/FutureGate/ReleaseV030BinanceAdapterRehearsal.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/automation/automation-readiness.md`
- `checks/automation-readiness.sh`

Required validation：

- `swift test --filter TargetGraphTests/testGH663BinanceAdapterRehearsalMapsDryRunAndTestnetSubmitCancelReplace`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-663 不使用 Linear，不启动 Symphony / `symphony-issue`，不运行 Graphify / code-index，不修改 Figma，不创建下一 Project / Issue，不推进下一阶段 Todo。

GH-663 不实现 production trading，不读取 production secret，不连接 production endpoint，不发送真实订单，不解析 execution report / broker fill，不执行 reconciliation，不打开 Dashboard command surface，不授权 production cutover。
