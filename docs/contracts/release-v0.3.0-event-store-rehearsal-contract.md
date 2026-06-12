# Release v0.3.0 Event Store Rehearsal Contract

日期：2026-06-13

执行者：Codex

本文档定义 GH-664 / V030-08 的 Event Store / replay rehearsal evidence 合同。该合同只授权本地 append-only evidence、correlation / causation 链和 replay state；不授权 production Event Store runtime、production trading、production secret、production endpoint、真实 broker connection 或真实订单。

## V030-08-EVENT-STORE-REHEARSAL-EVIDENCE

- Issue：GH-664。
- Upstream：GH-663 / `TVM-RELEASE-V030-BINANCE-ADAPTER-REHEARSAL`。
- Downstream：GH-665。
- Queue range：GH-657..GH-670。
- Release：v0.3.0。
- Project：MTPRO Release v0.3.0 Runtime Rehearsal v1。

GH-664 在 `Database` target 内输出 rehearsal Event Store evidence。该 evidence 不 import Trader、RiskEngine、ExecutionEngine 或 ExecutionClient runtime object，只保存已完成 issue 的 stable evidence anchor。

## V030-08-APPEND-ONLY-REHEARSAL-EVENTS

Event Store rehearsal record 必须 append-only：

- sequence 从 1 开始连续递增。
- 每条 record 保存 previous checksum 和 current checksum。
- out-of-order records 必须被拒绝。
- checksum 只用于 deterministic replay 校验，不是安全签名，不授权交易。

## V030-08-CORRELATION-CAUSATION-LINKS

每条 record 必须保留：

- correlation ID。
- causation ID。
- source issue ID。
- source evidence anchor。
- stage。
- payload type。
- instrument identity。
- strategy identity。

除第一条 root event 外，每条 record 的 causation ID 必须指向前一条 event ID。

## V030-08-REPLAY-RECONSTRUCTS-KEY-STATE

Replay 必须从 append-only records 重建 key state：

- event count。
- stage trail。
- source issue trail。
- final stage。
- latest checksum。
- correlation / causation link health。

## V030-08-STRATEGY-RISK-EXECUTION-OMS-PORTFOLIO-CHAIN

Replay stage trail 必须覆盖：

1. strategy
2. risk
3. execution
4. OMS
5. adapter
6. portfolio

Portfolio stage 只表示 GH-664 的 downstream replay input evidence，不实现 portfolio projection runtime，不执行 reconciliation，不更新真实 account / broker state。

## TVM-RELEASE-V030-EVENT-STORE-REHEARSAL-EVIDENCE

Validation evidence 必须同时落在：

- `Sources/Database/ReleaseV030EventStoreRehearsalEvidence.swift`
- `Tests/TargetGraphTests/TargetGraphTests.swift`
- `docs/validation/trading-validation-matrix.md`
- `docs/validation/validation-plan.md`
- `docs/automation/automation-readiness.md`
- `checks/automation-readiness.sh`

Required validation：

- `swift test --filter TargetGraphTests/testGH664EventStoreReplayReconstructsRehearsalCausalityChain`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

## Boundary

GH-664 不使用 Linear，不启动 Symphony / `symphony-issue`，不运行 Graphify / code-index，不修改 Figma，不创建下一 Project / Issue，不推进下一阶段 Todo。

GH-664 不实现 production Event Store runtime，不保存 raw broker payload，不暴露 raw database schema 给 Dashboard，不连接 production endpoint，不读取 production secret，不发送真实订单，不解析 broker fill，不执行 reconciliation，不打开 Dashboard command surface，不授权 production cutover。
