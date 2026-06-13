# Release v0.4.0 RehearsalRunContext / Unified Evidence Envelope Contract

日期：2026-06-13

执行者：Codex

本文档服务 GitHub fallback issue `GH-695 V040-02 Add RehearsalRunContext and unified evidence envelope`。

本文档定义 `MTPRO Release v0.4.0 Unified Runtime Rehearsal Pipeline` 的共享 run context 和 unified evidence envelope。它只新增 deterministic value contract，不构建 orchestrator，不连接 network endpoint，不读取 secret，不实现 production trading。

## V040-02-REHEARSAL-RUN-CONTEXT

`V040-02-REHEARSAL-RUN-CONTEXT`

`Sources/DomainModel/ReleaseV040RehearsalRunContext.swift` 定义 `ReleaseV040RehearsalRunContext`。该类型是所有 v0.4.0 module evidence 的共享上下文，字段必须包含：

- `runID`
- `mode`
- `venue`
- `productType`
- `strategy`
- `correlationID`
- `causationID`

默认 deterministic context 固定：

- mode：`dry-run`
- venue：`Binance`
- product type：`spot`
- strategy：`EMA`
- production trading：disabled by default
- production secret auto-read：disabled
- production endpoint auto-connect：disabled
- production broker connection：disabled
- production order submission：disabled
- production cutover authorization：false

## V040-02-UNIFIED-EVIDENCE-ENVELOPE

`V040-02-UNIFIED-EVIDENCE-ENVELOPE`

`ReleaseV040UnifiedEvidenceEnvelope` 是所有 v0.4.0 module evidence 的共同外壳。每个 envelope 必须携带：

- `envelopeID`
- `runContext`
- `module`
- `sourceIssueID`
- `evidenceID`
- `upstreamEvidenceID`
- `validationAnchor`
- `sequence`

Envelope 的 `runID`、`mode`、`venue`、`productType`、`strategy`、`correlationID` 和 `causationID` 必须来自同一个 run context 或 upstream evidence chain，不允许每个模块私自生成独立 run identity。

## V040-02-MODULE-EVIDENCE-COVERAGE

`V040-02-MODULE-EVIDENCE-COVERAGE`

统一 envelope 必须覆盖以下 module：

- DataEngine
- MessageBus
- Trader
- RiskEngine
- ExecutionEngine
- OMS
- ExecutionClient
- Event Store
- Portfolio
- Dashboard
- CLI

`ReleaseV040UnifiedEvidenceEnvelopeFixture.deterministicEnvelopes()` 生成所有 module 的 deterministic envelope，并由 `allEvidenceSharesOneRunID` 验证所有 evidence 共享同一 runID、同一 context boundary 和固定 module 顺序。

## V040-02-PRODUCT-STRATEGY-MODE-IDENTITY

`V040-02-PRODUCT-STRATEGY-MODE-IDENTITY`

v0.4.0 run context 继续锁定：

- active venue：`Binance`
- active product types：`spot`、`usdsPerpetual`
- active strategies：`EMA`、`RSI`
- run modes：`dry-run`、`shadow`、`testnet-guarded`、`production-blocked`

任何非 Binance venue、Spot / USDⓈ-M Perpetual 之外的 product type、EMA / RSI 之外的 active strategy 或 production-enabled mode 都必须 fail closed。

## V040-02-FORBIDDEN-PRODUCTION-RUNTIME

`V040-02-FORBIDDEN-PRODUCTION-RUNTIME`

GH-695 必须保持以下默认关闭或禁止：

- `productionTradingEnabledByDefault == false`
- `productionSecretAutoReadEnabled == false`
- `productionEndpointAutoConnectEnabled == false`
- `productionBrokerConnectionEnabled == false`
- `productionOrderSubmissionEnabled == false`
- `productionCutoverAuthorized == false`

本文档不创建 orchestrator、secret provider、signed request runtime、listenKey runtime、private stream runtime、broker adapter、production OMS、real submit / cancel / replace path 或 production cutover path。

## TVM-RELEASE-V040-REHEARSAL-RUN-CONTEXT-ENVELOPE

`TVM-RELEASE-V040-REHEARSAL-RUN-CONTEXT-ENVELOPE`

Required validation：

- `swift test --filter TargetGraphTests/testGH695ReleaseV040RehearsalRunContextAndEnvelopeShareOneRunID`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`
- GitHub required check `checks` SUCCESS

## V040-02 Non-authorization

GH-695 不授权：

- Linear 使用或 Linear 状态修改。
- Symphony / `symphony-issue`。
- Graphify / code-index。
- Figma。
- RuntimeKernel / orchestrator 实现。
- network endpoint 连接。
- testnet credential 读取。
- production trading。
- production secret auto-read。
- production endpoint auto-connect。
- production broker connection。
- production order submission。
- production cutover authorization。
- signed endpoint / account endpoint / listenKey。
- private WebSocket runtime。
- real submit / cancel / replace。
- production OMS。
- trading button / live command / order form。
