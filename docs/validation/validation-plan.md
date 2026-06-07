# Validation Plan

本文档定义 MTPRO 当前验证计划。

## 统一入口

```bash
bash checks/run.sh
```

该命令必须串联：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- macOS 本地：`swift build --product Dashboard`
- macOS 本地：`DASHBOARD_SMOKE=1 swift run Dashboard`
- Linux CI：跳过 macOS-only SwiftUI shell build / smoke，并继续运行 SwiftPM tests
- `swift test`

## 当前覆盖

当前测试覆盖：

- Swift-only core。
- paper-only execution mode。
- TradingKernel actor boundary。
- MessageBus monotonic event stream。
- DataEngine read-only market event ingest。
- Cache deterministic replay projection。
- Binance public read-only contract 和 fixture decoding。
- Binance public read-only client boundary、mock transport、fixture parity 和 public stream path 断言。
- EMA cross strategy contract。
- Backtest / Paper signal timeline parity。
- Order book imbalance research contract。
- Event Log replay persistence boundary。
- File-backed append-only event log persistence boundary。
- SQLite runtime projection boundary。
- SQLite runtime projection adapter 最小 rebuild / query snapshot 闭环。
- DuckDB analytical projection boundary。
- DuckDB analytical projection adapter 最小 rebuild / query snapshot 闭环。
- Runtime market data ingest -> event log -> replay -> projection snapshots 端到端链路。
- Trader Workstation Dashboard ViewModel contract。
- Trader Workstation Dashboard macOS shell、ViewModel snapshot binding 和 smoke run。
- Research -> Backtest -> Report 最小路径、report artifact / read model 和 Dashboard Report 快照。
- Paper Session lifecycle started / updated / closed facts、paper-only event log 写入边界和 deterministic fixture。
- Paper action proposal 最小模型、long / flat signal 映射、deterministic sizing fixture、fixed cost evidence 复用和 paper-only 不可执行边界。
- Paper action proposal -> risk blocker 本地链路、allowed / blocked deterministic evidence、source sequence、paper-only context 和无 broker / Live fallback 边界。
- Paper-only portfolio projection update path、allowed risk decision -> portfolio update、blocked decision 拒绝、SQLite runtime projection replay 和 read-only ViewModel。
- Paper Session replay evidence summary、append-only facts source、proposal event replay fact、SQLite runtime projection replay、乱序 replay 拒绝和 paper-only boundary flags。
- Paper Session runtime evidence 汇总到 Report / Dashboard read model，覆盖 lifecycle、proposal、risk blocker、portfolio update、portfolio exposure、replay facts、deterministic replay 和 paper-only boundary flags。
- Paper-only execution workflow contract 和事件边界，覆盖 proposal、risk decision、paper execution decision、paper order、simulated fill、portfolio projection 的 stage order、event stream、future issue 占位和 capability 禁区。
- Paper order intent / lifecycle 最小模型，覆盖 allowed / blocked risk result 到 `intentCreated` / `rejectedByRisk` 的 deterministic 映射、paper-only capability flags 和 Codable 禁区。
- Simulated fill evidence 最小模型，覆盖 allowed paper order intent -> deterministic simulated fill evidence、fixed fee / slippage cost evidence、source sequence、paper-only capability flags 和 Codable 禁区。
- Paper execution decision 本地链路，覆盖 allowed risk decision -> paper order intent -> simulated fill evidence、blocked risk decision 不生成 paper order、source sequence、paper-only capability flags 和 Codable 禁区。
- Paper execution event log / replay / projection 串联，覆盖 decision -> order -> simulated fill `.paper` facts、replay deterministic summary、从 replayed simulated fill evidence 更新 portfolio projection，以及无 broker / signed endpoint / account data 边界。
- Paper execution workflow evidence 汇总到 Report / Dashboard read model，覆盖 workflow replay streams、decision / order / simulated fill / portfolio update ID、chain coverage、Codable deterministic snapshot 和 read-model-only boundary。
- Paper Execution Workflow v1 阶段审计输入材料，覆盖 MTP-38 至 MTP-45 issue / PR evidence、paper execution workflow validation evidence chain、automation readiness evidence、known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- Paper Session Runtime v1 阶段审计输入材料，覆盖 MTP-31 至 MTP-37 issue / PR evidence、paper runtime validation evidence chain、automation readiness evidence、known boundaries 和 Root Docs Delta input。
- GitHub workflow / PR evidence / WIP=1 / handoff marker / Graphify 边界。
- Linear issue execution contract。
- `.codex/*` 与 `graphify-out/*` 本地输出排除契约。

## Finance / Trading Validation

策略、market data、Backtest、Paper、risk 或 portfolio 相关 issue 必须补充交易语义验证：

- 策略假设。
- market data 时间粒度和 symbol universe。
- fees / slippage 是否进入当前 scope。
- Backtest / Paper parity 验收方式。
- risk metric 或 risk blocker。
- 不触碰 Live trading、signed endpoint 和真实 broker action。

当前继续使用 XCTest + fixtures 表达交易语义验证，不引入独立 eval 框架。

交易验证矩阵入口：`docs/validation/trading-validation-matrix.md`。

该矩阵记录 EMA parity、order book imbalance parity、fees / slippage、risk blocker、portfolio exposure 和 report evidence 的现有 coverage、验收证据边界和后续 issue 回填规则。

## Stage Audit Input Location Rule

`docs/validation/` 只保留长期验证入口，例如 latest summary、validation plan、trading validation matrix、eval strategy 和 macOS build / run loop。

Project 级阶段证据和 Stage Code Audit 输入材料必须放在：

```text
docs/audit/inputs/
```

命名规则：

- 使用 Project slug，不使用单个 Linear issue 编号作为文件名主体。
- stage evidence 命名为 `<linear-project-slug>-stage-evidence.md`。
- stage audit input 命名为 `<linear-project-slug>-stage-audit-input.md`。

示例：

- `docs/audit/inputs/mtpro-runtime-research-workbench-v1-stage-evidence.md`
- `docs/audit/inputs/mtpro-trading-validation-and-parity-hardening-stage-audit-input.md`
- `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md`

这些输入材料不替代最终 Stage Code Audit Report。最终 Project 级审计报告仍必须落到：

```text
docs/audit/<linear-project-slug>-stage-code-audit.md
```

`docs/audit/inputs/` 中的文件不授权下一 Project planning，不创建 Linear Project / Issue，不修改 Linear status，不推进 Todo，不启动下一阶段 `symphony-issue`。

## GH-452 L4 Live Production Command Contract Validation

GH-452 的 required validation：

- `docs/contracts/l4-live-production-command-contract.md` 必须存在，并包含 `GH-452-L4-LIVE-PRODUCTION-COMMAND-CONTRACT`、`GH-452-READONLY-TO-GUARDED-COMMAND-RULE`、`GH-452-SANDBOX-PRODUCTION-GATE`、`GH-452-COMMAND-AUTHORIZATION-EVIDENCE-IDENTITY`、`GH-452-ACCEPTANCE-MATRIX`、`GH-452-NO-DEFAULT-REAL-TRADING-POLICY`、`GH-452-VALIDATION-ANCHORS` 和 `GH-452-NON-AUTHORIZATION`。
- `Sources/ExecutionClient/FutureGate/L4LiveProductionCommandContract.swift` 必须定义 `L4LiveProductionCommandContract`、`L4LiveProductionAcceptanceMatrixEntry`、`L4LiveProductionAcceptanceDomain`、`L4LiveProductionCommandGate` 和 `L4LiveProductionForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH452L4LiveProductionCommandContractDefinesDisabledProductionMatrix` 和 `testGH452L4LiveProductionCommandContractRejectsProductionBypass`。
- Acceptance matrix 必须覆盖 command、risk、execution、audit、rollback、credential、private stream、dashboard command surface 和 production cutover。
- Production 默认必须禁用：不得打开 signed endpoint、private stream、ExecutionClient adapter、OMS、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console command surface、order form 或 production endpoint。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、真实 Binance private endpoint、broker、production credential 或人工验收。

GH-452 必须建立的主要 anchors：

- `GH-452-L4-LIVE-PRODUCTION-COMMAND-CONTRACT`
- `GH-452-READONLY-TO-GUARDED-COMMAND-RULE`
- `GH-452-SANDBOX-PRODUCTION-GATE`
- `GH-452-COMMAND-AUTHORIZATION-EVIDENCE-IDENTITY`
- `GH-452-ACCEPTANCE-MATRIX`
- `GH-452-NO-DEFAULT-REAL-TRADING-POLICY`
- `TVM-L4-LIVE-PRODUCTION-COMMANDS`

## GH-453 L4 Credential Environment Gate Validation

GH-453 的 required validation：

- `docs/contracts/l4-credential-environment-gate-contract.md` 必须存在，并包含 `GH-453-L4-CREDENTIAL-ENVIRONMENT-GATE-CONTRACT`、`GH-453-CREDENTIAL-SOURCE-IDENTITY`、`GH-453-SANDBOX-ONLY-ENABLEMENT-GATE`、`GH-453-PRODUCTION-CUTOVER-BLOCKED-UNTIL-GH-471`、`GH-453-LOCAL-CI-SECRET-PRODUCTION-VALIDATION` 和 `GH-453-NON-AUTHORIZATION`。
- `Sources/ExecutionClient/FutureGate/L4CredentialEnvironmentGateContract.swift` 必须定义 `L4CredentialEnvironmentGateContract`、`L4CredentialEnvironmentValidationRule`、`L4CredentialEnvironmentScope`、`L4CredentialSourceIdentity`、`L4CredentialEnvironmentGate` 和 `L4CredentialEnvironmentForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH453L4CredentialEnvironmentGateDefinesSandboxOnlyContract` 和 `testGH453L4CredentialEnvironmentGateRejectsSecretAndProductionDefault`。
- Credential source identity 只能保存 environment key / external reference / sandbox-only flag / production cutover flag / forbidden credential value marker，不得保存真实 API key、secret value、signed payload、listenKey、account payload 或 broker credential。
- Sandbox-only gate 必须保持 validation-only：不得连接 sandbox network，不得实现 signed account runtime，不得实现 ExecutionClient adapter。
- Production gate 必须保持 blocked until `GH-471`：不得通过环境变量、配置、fixture、UI 或 hidden flag 默认打开 production trading。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、真实 Binance private endpoint、broker、production credential 或人工验收。

GH-453 必须建立的主要 anchors：

- `GH-453-L4-CREDENTIAL-ENVIRONMENT-GATE-CONTRACT`
- `GH-453-CREDENTIAL-SOURCE-IDENTITY`
- `GH-453-SANDBOX-ONLY-ENABLEMENT-GATE`
- `GH-453-PRODUCTION-CUTOVER-BLOCKED-UNTIL-GH-471`
- `GH-453-LOCAL-CI-SECRET-PRODUCTION-VALIDATION`
- `TVM-L4-CREDENTIAL-ENVIRONMENT-GATE`

## GH-454 L4 Signed Endpoint Private Stream Boundary Validation

GH-454 的 required validation：

- `docs/contracts/l4-signed-endpoint-private-stream-boundary-contract.md` 必须存在，并包含 `GH-454-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY`、`GH-454-SIGNED-REQUEST-CAPABILITY-TAXONOMY`、`GH-454-LISTENKEY-PRIVATE-WEBSOCKET-FUTURE-CONTRACT`、`GH-454-ACCOUNT-SNAPSHOT-PRIVATE-EVENT-SOURCE-IDENTITY`、`GH-454-FORBIDDEN-ENDPOINT-PATHS` 和 `GH-454-NON-AUTHORIZATION`。
- `Sources/ExecutionClient/FutureGate/L4SignedEndpointPrivateStreamBoundaryContract.swift` 必须定义 `L4SignedEndpointPrivateStreamBoundaryContract`、`L4SignedPrivateBoundaryEntry`、`L4SignedPrivateRuntimeKind`、`L4SignedRequestCapabilityTaxonomy`、`L4PrivateStreamLifecycleGate`、`L4AccountPrivateEventSourceIdentity` 和 `L4SignedPrivateForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH454L4SignedEndpointPrivateStreamBoundarySeparatesRuntimeKinds` 和 `testGH454L4SignedEndpointPrivateStreamBoundaryRejectsEndpointRuntimeBypass`。
- Boundary 必须明确区分 signed read-only、private stream 和 command runtime；GH-454 不能把 account read-only、private event stream 和 submit / cancel / replace command 合并成单一 runtime。
- Forbidden endpoint tests 必须证明 credential value read、API-key header construction、request signature generation、signed endpoint call、account endpoint call、listenKey creation / keep-alive / close、private WebSocket open / reconnect、real account snapshot read、real private event consumption 和 command runtime 全部关闭。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、真实 Binance private endpoint、broker、production credential 或人工验收。

GH-454 必须建立的主要 anchors：

- `GH-454-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY`
- `GH-454-SIGNED-REQUEST-CAPABILITY-TAXONOMY`
- `GH-454-LISTENKEY-PRIVATE-WEBSOCKET-FUTURE-CONTRACT`
- `GH-454-ACCOUNT-SNAPSHOT-PRIVATE-EVENT-SOURCE-IDENTITY`
- `GH-454-FORBIDDEN-ENDPOINT-PATHS`
- `TVM-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY`

## GH-455 L4 Signed Account Read-only Runtime Validation

GH-455 的 required validation：

- `docs/contracts/l4-signed-account-read-only-runtime-contract.md` 必须存在，并包含 `GH-455-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME`、`GH-455-DISABLED-BY-DEFAULT-RUNTIME-GATE`、`GH-455-SANDBOX-FIXTURE-FIRST-READ`、`GH-455-CANONICAL-ACCOUNT-EVIDENCE`、`GH-455-FORBIDDEN-PRODUCTION-DEFAULT-TESTS` 和 `GH-455-NON-AUTHORIZATION`。
- `Sources/ExecutionClient/FutureGate/L4SignedAccountReadOnlyRuntime.swift` 必须定义 `L4SignedAccountReadOnlyRuntime`、`L4SignedAccountReadOnlyRuntimeConfiguration`、`L4SignedAccountReadOnlyEvidence`、`L4SignedAccountReadOnlyEvidenceRecord`、`L4SignedAccountReadOnlyRuntimeMode`、`L4SignedAccountReadOnlyEvidenceComponent` 和 `L4SignedAccountReadOnlyForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH455SignedAccountReadOnlyRuntimeDefaultsDisabledAndReturnsCanonicalEvidence` 和 `testGH455SignedAccountReadOnlyRuntimeRejectsProductionSecretAndPayloadBypass`。
- Runtime 默认必须 disabled；未配置 credential reference、sandbox gate 和 fixture read gate 时不可触发 signed account read。
- Sandbox / local configured gate 只能返回 canonical account / balance / position / margin evidence，不得暴露 raw signed payload、secret、broker state 或 Dashboard raw payload。
- Forbidden production default tests 必须拒绝 production mode、production gate、secret material、raw payload exposure、network connection、missing credential reference 和 command runtime。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、真实 Binance private endpoint、broker、production credential 或人工验收。

GH-455 必须建立的主要 anchors：

- `GH-455-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME`
- `GH-455-DISABLED-BY-DEFAULT-RUNTIME-GATE`
- `GH-455-SANDBOX-FIXTURE-FIRST-READ`
- `GH-455-CANONICAL-ACCOUNT-EVIDENCE`
- `GH-455-FORBIDDEN-PRODUCTION-DEFAULT-TESTS`
- `TVM-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME`

## GH-456 L4 Private Stream Account Snapshot Read-only Runtime Validation

GH-456 的 required validation：

- `docs/contracts/l4-private-stream-account-snapshot-read-only-runtime-contract.md` 必须存在，并包含 `GH-456-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME`、`GH-456-PRIVATE-STREAM-SOURCE-IDENTITY`、`GH-456-ACCOUNT-SNAPSHOT-READ-MODEL-UPDATE`、`GH-456-FRESHNESS-STALE-BLOCKED-MISSING-DISCONNECT-EVIDENCE`、`GH-456-LISTENKEY-LIFECYCLE-NO-COMMAND-SURFACE` 和 `GH-456-NON-AUTHORIZATION`。
- `Sources/ExecutionClient/FutureGate/L4PrivateStreamAccountSnapshotReadOnlyRuntime.swift` 必须定义 `L4PrivateStreamAccountSnapshotReadOnlyRuntime`、`L4PrivateStreamReadOnlyRuntimeConfiguration`、`L4PrivateStreamAccountSnapshotReadOnlyEvidence`、`L4PrivateStreamAccountSnapshotReadModelRecord`、`L4PrivateStreamSourceIdentity`、`L4PrivateStreamFreshnessStatus` 和 `L4PrivateStreamReadOnlyForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH456PrivateStreamAccountSnapshotReadOnlyRuntimeProducesFreshnessEvidence` 和 `testGH456PrivateStreamAccountSnapshotReadOnlyRuntimeRejectsListenKeyPayloadAndCommandBypass`。
- Runtime 默认必须 disabled；未配置 credential reference、sandbox gate、fixture stream gate 和 account snapshot mapping gate 时不可触发 private stream evidence。
- Runtime 必须引用 GH-455 canonical signed account evidence，只输出 source identity、freshness、stale / blocked / missing / disconnected 和 account snapshot read-model update evidence。
- Forbidden lifecycle tests 必须拒绝 production mode、listenKey lifecycle、private WebSocket、raw payload exposure、command runtime、missing credential reference、raw private payload record 和 raw broker payload evidence。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、listenKey、private WebSocket、broker、production credential 或人工验收。

GH-456 必须建立的主要 anchors：

- `GH-456-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME`
- `GH-456-PRIVATE-STREAM-SOURCE-IDENTITY`
- `GH-456-ACCOUNT-SNAPSHOT-READ-MODEL-UPDATE`
- `GH-456-FRESHNESS-STALE-BLOCKED-MISSING-DISCONNECT-EVIDENCE`
- `GH-456-LISTENKEY-LIFECYCLE-NO-COMMAND-SURFACE`
- `TVM-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME`

## GH-457 L4 Live Account Read-model Mapping Validation

GH-457 的 required validation：

- `docs/contracts/l4-live-account-read-model-mapping-contract.md` 必须存在，并包含 `GH-457-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING`、`GH-457-APB-MARGIN-CANONICAL-COMPONENTS`、`GH-457-FRESHNESS-SOURCE-EVIDENCE-IDENTITY`、`GH-457-DASHBOARD-READ-MODEL-ONLY-CONSUMPTION`、`GH-457-FIXTURE-SANDBOX-REAL-ACCOUNT-INTERPRETATION-SEPARATION`、`GH-457-FORBIDDEN-RAW-PAYLOAD-BROKER-STATE-TESTS` 和 `GH-457-NON-AUTHORIZATION`。
- `Sources/ExecutionClient/FutureGate/L4LiveAccountReadModelMapping.swift` 必须定义 `L4LiveAccountReadModelMapping`、`L4LiveAccountReadModel`、`L4LiveAccountReadModelRecord`、`L4LiveAccountReadModelComponent`、`L4LiveAccountReadModelSourceKind`、`L4LiveAccountReadModelInterpretationMode` 和 `L4LiveAccountReadModelForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH457LiveAccountReadModelMappingMapsAPBMarginEvidenceReadOnly` 和 `testGH457LiveAccountReadModelMappingRejectsRawPayloadBrokerStateAndRuntimeBypass`。
- Mapper 必须只消费 GH-455 signed account evidence 和 GH-456 private stream account snapshot evidence，并输出 account / position / balance / margin 四类 canonical read-model records。
- Read model 必须保留 source identity、evidence identity、freshness statuses 和 fixture / sandbox vs future real account interpretation separation。
- Forbidden mapping tests 必须拒绝 raw account payload、raw private payload、broker state、Runtime object、Adapter request、schema、real PnL runtime、command surface、reconciliation、ExecutionClient adapter 和 OMS bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、真实 account endpoint、broker state、Runtime object、schema、production credential 或人工验收。

GH-457 必须建立的主要 anchors：

- `GH-457-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING`
- `GH-457-APB-MARGIN-CANONICAL-COMPONENTS`
- `GH-457-FRESHNESS-SOURCE-EVIDENCE-IDENTITY`
- `GH-457-DASHBOARD-READ-MODEL-ONLY-CONSUMPTION`
- `GH-457-FIXTURE-SANDBOX-REAL-ACCOUNT-INTERPRETATION-SEPARATION`
- `GH-457-FORBIDDEN-RAW-PAYLOAD-BROKER-STATE-TESTS`
- `TVM-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING`

## GH-458 L4 ExecutionClient Venue Adapter Contract Validation

GH-458 的 required validation：

- `docs/contracts/l4-executionclient-venue-adapter-contract.md` 必须存在，并包含 `GH-458-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT`、`GH-458-EXECUTIONENGINE-INTERNAL-LIFECYCLE-BOUNDARY`、`GH-458-SANDBOX-PRODUCTION-VENUE-GATE`、`GH-458-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT` 和 `TVM-L4-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT`。
- `Sources/ExecutionClient/FutureGate/L4ExecutionClientVenueAdapterContract.swift` 必须定义 `L4ExecutionClientVenueAdapterContract`、`L4ExecutionClientVenueOperationContract`、`L4ExecutionClientVenueAdapterOperation`、`L4ExecutionClientVenueAdapterGate` 和 `L4ExecutionClientVenueAdapterForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH458ExecutionClientVenueAdapterContractDefinesEngineClientBoundary` 和 `testGH458ExecutionClientVenueAdapterContractRejectsDirectAccessAndRuntimeBypass`。
- 合同必须证明 ExecutionClient 是外部 venue adapter contract，ExecutionEngine 是内部 lifecycle coordinator，submit / cancel / replace / status / execution report / broker fill 只作为 operation contract 行存在。
- 合同必须证明 sandbox venue gate 和 production venue gate 分离，production venue 默认关闭，production cutover 在 GH-471 前保持 blocked。
- Forbidden capability tests 必须拒绝 direct Trader / Strategy to ExecutionClient、sandbox submit / cancel / replace runtime、production venue、execution report runtime parser、broker fill parser、OMS、reconciliation、Live PRO Console 和 order form bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-458 必须建立的主要 anchors：

- `GH-458-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT`
- `GH-458-EXECUTIONENGINE-INTERNAL-LIFECYCLE-BOUNDARY`
- `GH-458-SANDBOX-PRODUCTION-VENUE-GATE`
- `GH-458-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT`
- `TVM-L4-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT`

## GH-459 L4 ExecutionClient Sandbox Submit Cancel Replace Validation

GH-459 的 required validation：

- `docs/contracts/l4-executionclient-sandbox-submit-cancel-replace-contract.md` 必须存在，并包含 `GH-459-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE`、`GH-459-SANDBOX-REQUEST-ENVELOPE`、`GH-459-DETERMINISTIC-COMMAND-EVIDENCE`、`GH-459-PRODUCTION-VENUE-DISABLED`、`GH-459-NON-AUTHORIZATION` 和 `TVM-L4-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE`。
- `Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxVenueAdapter.swift` 必须定义 `L4ExecutionClientSandboxVenueAdapter`、`L4ExecutionClientSandboxRequestEnvelope`、`L4ExecutionClientSandboxCommandResponse`、`L4ExecutionClientSandboxCommandEvidence`、`L4ExecutionClientSandboxCommandKind`、`L4ExecutionClientSandboxVenueMode` 和 `L4ExecutionClientSandboxForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH459ExecutionClientSandboxVenueAdapterProducesDeterministicCommandEvidence` 和 `testGH459ExecutionClientSandboxVenueAdapterRejectsProductionAndBrokerBypass`。
- Sandbox adapter 必须只接受 sandbox request envelope，并输出 submit / cancel / replace 三类 deterministic command evidence。
- Evidence 必须证明 request / response identity 可审计、production venue disabled、signed endpoint / broker / real order lifecycle / OMS / Live command surface 全部未触碰。
- Forbidden capability tests 必须拒绝 production mode、signed request generation、broker gateway touch、command kind mismatch 和 incomplete evidence bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-459 必须建立的主要 anchors：

- `GH-459-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE`
- `GH-459-SANDBOX-REQUEST-ENVELOPE`
- `GH-459-DETERMINISTIC-COMMAND-EVIDENCE`
- `GH-459-PRODUCTION-VENUE-DISABLED`
- `TVM-L4-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE`

## GH-460 L4 Execution Report Broker Fill Parser Validation

GH-460 的 required validation：

- `docs/contracts/l4-execution-report-broker-fill-parser-contract.md` 必须存在，并包含 `GH-460-EXECUTION-REPORT-BROKER-FILL-PARSER`、`GH-460-SANDBOX-REPORT-KIND-COVERAGE`、`GH-460-REPLAYABLE-AUDIT-EVIDENCE`、`GH-460-RAW-PAYLOAD-DASHBOARD-BLOCK`、`GH-460-PRODUCTION-PARSER-DISABLED`、`GH-460-NON-AUTHORIZATION` 和 `TVM-L4-EXECUTION-REPORT-BROKER-FILL-PARSER`。
- `Sources/ExecutionClient/FutureGate/L4ExecutionClientSandboxReportParser.swift` 必须定义 `L4ExecutionClientSandboxReportParser`、`L4ExecutionClientSandboxReportFixture`、`L4ExecutionClientSandboxParsedReportEvent`、`L4ExecutionClientSandboxReportReplayEvidence`、`L4ExecutionClientSandboxReportKind`、`L4ExecutionClientSandboxReportSourceKind` 和 `L4ExecutionClientSandboxReportForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH460ExecutionClientSandboxReportParserProducesReplayableAuditEvidence` 和 `testGH460ExecutionClientSandboxReportParserRejectsProductionRawPayloadAndDashboardBypass`。
- Sandbox parser 必须覆盖 fill、partial fill、reject 和 cancel acknowledgement，并输出 replayable parsed event / audit evidence。
- Evidence 必须证明 raw payload 不进入 Dashboard、production parser disabled、broker gateway / real broker fill / OMS / reconciliation / Live command surface 全部未触碰。
- Forbidden capability tests 必须拒绝 production parser、production raw payload source、raw Dashboard payload、OMS state transition 和 incomplete replay evidence bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-460 必须建立的主要 anchors：

- `GH-460-EXECUTION-REPORT-BROKER-FILL-PARSER`
- `GH-460-SANDBOX-REPORT-KIND-COVERAGE`
- `GH-460-REPLAYABLE-AUDIT-EVIDENCE`
- `GH-460-RAW-PAYLOAD-DASHBOARD-BLOCK`
- `GH-460-PRODUCTION-PARSER-DISABLED`
- `TVM-L4-EXECUTION-REPORT-BROKER-FILL-PARSER`

## GH-461 L4 OMS Order Lifecycle Contract Validation

GH-461 的 required validation：

- `docs/contracts/l4-oms-order-lifecycle-contract.md` 必须存在，并包含 `GH-461-OMS-ORDER-LIFECYCLE-STATE-MACHINE`、`GH-461-LOCAL-ORDER-BROKER-REPORT-RELATIONSHIP`、`GH-461-ILLEGAL-TRANSITION-EVIDENCE`、`GH-461-OMS-ENGINE-CLIENT-PORTFOLIO-BOUNDARY`、`GH-461-ROLLBACK-INCIDENT-EVIDENCE`、`GH-461-NON-AUTHORIZATION` 和 `TVM-L4-OMS-ORDER-LIFECYCLE-CONTRACT`。
- `Sources/ExecutionEngine/OMSFutureGate/L4OMSOrderLifecycleContract.swift` 必须定义 `L4OMSOrderLifecycleContract`、`L4OMSOrderLifecycleState`、`L4OMSOrderLifecycleTrigger`、`L4OMSOrderStateTransitionRule`、`L4OMSIllegalTransitionEvidence`、`L4OMSRollbackIncidentEvidence` 和 `L4OMSForbiddenCapability`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH461OMSOrderLifecycleContractDefinesStateMachineAndBoundaries` 和 `testGH461OMSOrderLifecycleContractRejectsIllegalTransitionAndBypass`。
- OMS state machine 必须覆盖 accepted、submitted、partially filled、filled、cancelled 和 rejected。
- Transition graph 必须定义 local order / broker report relationship，并引用 GH-459 command evidence 和 GH-460 parser evidence。
- Illegal transition evidence 必须拒绝 filled -> submitted、cancelled -> partially filled、rejected -> filled。
- Boundary tests 必须拒绝 production order manager、RiskEngine bypass、Portfolio mutation、缺失 transition rule 和 automatic retry bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-461 必须建立的主要 anchors：

- `GH-461-OMS-ORDER-LIFECYCLE-STATE-MACHINE`
- `GH-461-LOCAL-ORDER-BROKER-REPORT-RELATIONSHIP`
- `GH-461-ILLEGAL-TRANSITION-EVIDENCE`
- `GH-461-OMS-ENGINE-CLIENT-PORTFOLIO-BOUNDARY`
- `GH-461-ROLLBACK-INCIDENT-EVIDENCE`
- `TVM-L4-OMS-ORDER-LIFECYCLE-CONTRACT`

## GH-462 L4 OMS Local Order Transition Evidence Validation

GH-462 的 required validation：

- `docs/contracts/l4-oms-local-order-transition-evidence-contract.md` 必须存在，并包含 `GH-462-OMS-LOCAL-ORDER-STATE-RECORD`、`GH-462-DETERMINISTIC-TRANSITION-EVIDENCE`、`GH-462-SANDBOX-FILL-CANCEL-REJECT-EVIDENCE`、`GH-462-ILLEGAL-TRANSITION-REJECTION`、`GH-462-BROKER-INDEPENDENT-LOCAL-STATE`、`GH-462-NON-AUTHORIZATION` 和 `TVM-L4-OMS-LOCAL-ORDER-TRANSITION-EVIDENCE`。
- `Sources/ExecutionEngine/OMSFutureGate/L4OMSLocalOrderTransitionEvidence.swift` 必须定义 `L4OMSLocalOrderStateRecord`、`L4OMSLocalOrderTransitionRecord`、`L4OMSLocalOrderIllegalTransitionRejection`、`L4OMSLocalOrderTransitionEvidence` 和 `L4OMSLocalOrderTransitionEvidenceBuilder`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH462OMSLocalOrderTransitionEvidenceBuildsDeterministicSandboxLifecycle` 和 `testGH462OMSLocalOrderTransitionEvidenceRejectsIllegalTransitionAndRuntimeBypass`。
- Local transition evidence 必须复用 GH-461 allowed transition graph，并引用 GH-459 sandbox submit evidence 和 GH-460 parsed report event。
- Fill / cancel / reject path 必须 deterministic，且非法转换 rejection 不产生 state mutation。
- Boundary tests 必须拒绝 production runtime、real order state store、broker gateway、production broker report、Portfolio mutation、reconciliation 和 Live command surface bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-462 必须建立的主要 anchors：

- `GH-462-OMS-LOCAL-ORDER-STATE-RECORD`
- `GH-462-DETERMINISTIC-TRANSITION-EVIDENCE`
- `GH-462-SANDBOX-FILL-CANCEL-REJECT-EVIDENCE`
- `GH-462-ILLEGAL-TRANSITION-REJECTION`
- `GH-462-BROKER-INDEPENDENT-LOCAL-STATE`
- `TVM-L4-OMS-LOCAL-ORDER-TRANSITION-EVIDENCE`

## GH-463 L4 ExecutionEngine ExecutionClient Sandbox Path Validation

GH-463 的 required validation：

- `docs/contracts/l4-executionengine-executionclient-sandbox-path-contract.md` 必须存在，并包含 `GH-463-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH`、`GH-463-RISKENGINE-APPROVED-COMMAND-PROPOSAL`、`GH-463-SANDBOX-EXECUTIONCLIENT-HANDOFF`、`GH-463-COMMAND-RESPONSE-EVENT-EVIDENCE`、`GH-463-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT`、`GH-463-NON-AUTHORIZATION` 和 `TVM-L4-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH`。
- `Sources/ExecutionEngine/OMSFutureGate/L4ExecutionEngineSandboxPathEvidence.swift` 必须定义 `L4ExecutionEngineSandboxCommandProposal`、`L4ExecutionEngineSandboxPathEvent`、`L4ExecutionEngineSandboxPathEvidence` 和 `L4ExecutionEngineSandboxPathCoordinator`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH463ExecutionEngineSandboxPathWiresRiskApprovedCommandEvidence` 和 `testGH463ExecutionEngineSandboxPathRejectsDirectAccessAndBoundaryBypass`。
- Evidence 必须覆盖 RiskEngine-approved proposal、ExecutionEngine handoff、GH-459 sandbox ExecutionClient request / response 和 GH-462 local transition evidence link。
- Command evidence 必须覆盖 submit / cancel / replace，execution event evidence 必须覆盖 proposal accepted、request dispatched、response recorded 和 local transition evidence linked。
- Boundary tests 必须拒绝 direct Trader / Strategy / Live PRO Console access、skip OMS、production execution、Portfolio mutation、reconciliation 和 Live command surface bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-463 必须建立的主要 anchors：

- `GH-463-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH`
- `GH-463-RISKENGINE-APPROVED-COMMAND-PROPOSAL`
- `GH-463-SANDBOX-EXECUTIONCLIENT-HANDOFF`
- `GH-463-COMMAND-RESPONSE-EVENT-EVIDENCE`
- `GH-463-NO-DIRECT-TRADER-STRATEGY-EXECUTIONCLIENT`
- `TVM-L4-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH`

## GH-464 L4 Live RiskEngine Pre-trade Gate Validation

GH-464 的 required validation：

- `docs/contracts/l4-live-riskengine-pre-trade-gate-contract.md` 必须存在，并包含 `GH-464-LIVE-RISKENGINE-PRE-TRADE-GATE`、`GH-464-ORDER-PROPOSAL-RISK-INPUT`、`GH-464-APB-MARGIN-READ-MODEL-GATE`、`GH-464-ALLOW-REJECT-BLOCKED-INCIDENT-EVIDENCE`、`GH-464-COMMAND-PATH-RISKENGINE-REQUIRED`、`GH-464-NON-AUTHORIZATION` 和 `TVM-L4-LIVE-RISKENGINE-PRE-TRADE-GATE`。
- `Sources/RiskEngine/LiveGate/L4LiveRiskPreTradeGate.swift` 必须定义 `L4LiveRiskPreTradeReadModelInput`、`L4LiveRiskOrderProposalInput`、`L4LiveRiskPreTradeDecisionEvidence`、`L4LiveRiskPreTradeGateEvidence` 和 `L4LiveRiskPreTradeGateRuntime`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH464LiveRiskPreTradeGateProducesAllowRejectBlockedIncidentEvidence` 和 `testGH464LiveRiskPreTradeGateRejectsBypassAndForbiddenRuntime`。
- Evidence 必须覆盖 GH-457 APB / margin read-model identity、GH-461 OMS identity、allow / reject / blocked / incident stop decision evidence 和 command path RiskEngine required。
- RiskEngine target 必须继续不依赖 ExecutionClient；APB / margin read-model input 只能携带 canonical values，不能携带 raw account payload、broker state、Runtime object 或 Adapter request。
- Boundary tests 必须拒绝 production risk enablement、risk gate bypass、missing APB / margin components、command execution、ExecutionClient call、Portfolio mutation、reconciliation 和 Live command surface bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-464 必须建立的主要 anchors：

- `GH-464-LIVE-RISKENGINE-PRE-TRADE-GATE`
- `GH-464-ORDER-PROPOSAL-RISK-INPUT`
- `GH-464-APB-MARGIN-READ-MODEL-GATE`
- `GH-464-ALLOW-REJECT-BLOCKED-INCIDENT-EVIDENCE`
- `GH-464-COMMAND-PATH-RISKENGINE-REQUIRED`
- `TVM-L4-LIVE-RISKENGINE-PRE-TRADE-GATE`

## GH-465 L4 Kill Switch Incident Shutdown Gate Validation

GH-465 的 required validation：

- `docs/contracts/l4-kill-switch-incident-shutdown-gate-contract.md` 必须存在，并包含 `GH-465-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE`、`GH-465-INCIDENT-STOP-SOURCE-IDENTITY`、`GH-465-SUBMIT-CANCEL-REPLACE-SHUTDOWN-RULES`、`GH-465-DASHBOARD-AUDIT-SHUTDOWN-EVIDENCE`、`GH-465-NO-AUTOMATIC-RECOVERY`、`GH-465-NON-AUTHORIZATION` 和 `TVM-L4-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE`。
- `Sources/RiskEngine/LiveGate/L4KillSwitchIncidentShutdownGate.swift` 必须定义 `L4IncidentStopSourceEvidence`、`L4CommandShutdownGateDecisionEvidence`、`L4KillSwitchIncidentShutdownGateEvidence` 和 `L4KillSwitchIncidentShutdownGateRuntime`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH465KillSwitchIncidentShutdownGateBlocksAllCommandsAndDefinesRecoveryBoundary` 和 `testGH465KillSwitchIncidentShutdownGateRejectsAutoRecoveryAndCommandBypass`。
- Evidence 必须绑定 GH-464 incident stop decision、source identity、submit / cancel / replace shutdown rules、Dashboard / audit explanation 和 no automatic recovery boundary。
- Shutdown gate 必须继续不依赖 ExecutionClient；它不能触碰 broker gateway、production operations runtime、real emergency broker API、Live PRO Console command surface、order form 或 trading button。
- Boundary tests 必须拒绝 auto recovery、non-incident risk decision source、command execution、missing submit / cancel / replace coverage、ExecutionClient call、broker touch、production trading 和 Live command surface bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-465 必须建立的主要 anchors：

- `GH-465-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE`
- `GH-465-INCIDENT-STOP-SOURCE-IDENTITY`
- `GH-465-SUBMIT-CANCEL-REPLACE-SHUTDOWN-RULES`
- `GH-465-DASHBOARD-AUDIT-SHUTDOWN-EVIDENCE`
- `GH-465-NO-AUTOMATIC-RECOVERY`
- `TVM-L4-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE`

## GH-466 L4 OMS Broker Portfolio Reconciliation Validation

GH-466 的 required validation：

- `docs/contracts/l4-oms-broker-portfolio-reconciliation-contract.md` 必须存在，并包含 `GH-466-OMS-BROKER-PORTFOLIO-RECONCILIATION`、`GH-466-RECONCILIATION-FIELD-MATRIX`、`GH-466-MATCHED-MISMATCHED-STALE-MISSING-EVIDENCE`、`GH-466-PARTIAL-CANCEL-REJECT-PATHS`、`GH-466-PORTFOLIO-PROJECTION-NO-BROKER-PAYLOAD`、`GH-466-NON-AUTHORIZATION` 和 `TVM-L4-OMS-BROKER-PORTFOLIO-RECONCILIATION`。
- `Sources/ExecutionEngine/OMSFutureGate/L4OMSBrokerPortfolioReconciliationEvidence.swift` 必须定义 `L4OMSBrokerPortfolioReconciliationRecord`、`L4PortfolioProjectionReconciliationSnapshot`、`L4OMSBrokerPortfolioReconciliationEvidence` 和 `L4OMSBrokerPortfolioReconciliationRuntime`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH466OMSBrokerPortfolioReconciliationBuildsDeterministicEvidence` 和 `testGH466OMSBrokerPortfolioReconciliationRejectsProductionBrokerPayloadAndCoverageBypass`。
- Evidence 必须绑定 GH-460 parser evidence、GH-462 OMS local transition evidence 和 GH-463 sandbox path evidence，并覆盖 matched / mismatched / stale / missing。
- Reconciliation path 必须覆盖 partial fill、cancel 和 reject；fill 只能作为 additional missing evidence，不替代 required paths。
- Portfolio projection snapshot 必须证明不读取 raw broker payload、不读取真实账户、不计算 real PnL、不写 Portfolio runtime、不调用 broker gateway、不输出 repair command。
- Boundary tests 必须拒绝 production reconciliation enablement、production broker report consumption、raw broker payload read、matched evidence mismatch 和 incomplete status coverage bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-466 必须建立的主要 anchors：

- `GH-466-OMS-BROKER-PORTFOLIO-RECONCILIATION`
- `GH-466-RECONCILIATION-FIELD-MATRIX`
- `GH-466-MATCHED-MISMATCHED-STALE-MISSING-EVIDENCE`
- `GH-466-PARTIAL-CANCEL-REJECT-PATHS`
- `GH-466-PORTFOLIO-PROJECTION-NO-BROKER-PAYLOAD`
- `TVM-L4-OMS-BROKER-PORTFOLIO-RECONCILIATION`

## GH-467 L4 Audit Trail Incident Replay Validation

GH-467 的 required validation：

- `docs/contracts/l4-audit-trail-incident-replay-contract.md` 必须存在，并包含 `GH-467-AUDIT-TRAIL-INCIDENT-REPLAY`、`GH-467-COMMAND-EVIDENCE-TRACE`、`GH-467-APPEND-ONLY-AUDIT-TRAIL`、`GH-467-DETERMINISTIC-INCIDENT-REPLAY`、`GH-467-NO-SECRET-RAW-PAYLOAD`、`GH-467-NON-AUTHORIZATION` 和 `TVM-L4-AUDIT-TRAIL-INCIDENT-REPLAY`。
- `Sources/ExecutionEngine/OMSFutureGate/L4AuditTrailIncidentReplayEvidence.swift` 必须定义 `L4CommandAuditTrailEntry`、`L4IncidentReplayInput`、`L4IncidentReplayOutput`、`L4AuditTrailIncidentReplayEvidence` 和 `L4AuditTrailIncidentReplayRuntime`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH467AuditTrailIncidentReplayBuildsAppendOnlyReplayEvidence` 和 `testGH467AuditTrailIncidentReplayRejectsExternalAuditRawPayloadAndReplayBypass`。
- Evidence 必须绑定 GH-463 sandbox command path evidence 和 GH-466 reconciliation evidence。
- Audit trail 必须覆盖 command intent、risk decision、execution request、broker report、OMS transition 和 reconciliation outcome。
- Replay 必须证明 append-only sequence 连续、submit / cancel / replace command kinds 覆盖、所有 audit stage 覆盖，以及 matched / mismatched / stale / missing reconciliation status 覆盖。
- Boundary tests 必须拒绝 external audit upload、secret capture、raw broker payload capture、production incident ops、production broker replay、mutable audit trail、repair command、ExecutionClient call、broker gateway touch 和 Live command surface bypass。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-467 必须建立的主要 anchors：

- `GH-467-AUDIT-TRAIL-INCIDENT-REPLAY`
- `GH-467-COMMAND-EVIDENCE-TRACE`
- `GH-467-APPEND-ONLY-AUDIT-TRAIL`
- `GH-467-DETERMINISTIC-INCIDENT-REPLAY`
- `GH-467-NO-SECRET-RAW-PAYLOAD`
- `TVM-L4-AUDIT-TRAIL-INCIDENT-REPLAY`

## GH-468 L4 Dashboard Live PRO Console Command Split Validation

GH-468 的 required validation：

- `docs/contracts/l4-dashboard-livepro-command-split-contract.md` 必须存在，并包含 `GH-468-DASHBOARD-LIVEPRO-READONLY-COMMAND-SPLIT`、`GH-468-DASHBOARD-READ-MODEL-ONLY`、`GH-468-LIVEPRO-CONSOLE-COMMAND-GATE`、`GH-468-READONLY-ARMED-BLOCKED-INCIDENT-STATES`、`GH-468-NO-DASHBOARD-SUBMIT-CANCEL-REPLACE`、`GH-468-NON-AUTHORIZATION` 和 `TVM-L4-DASHBOARD-LIVEPRO-COMMAND-SPLIT`。
- `Sources/Dashboard/FutureLiveProConsole/L4DashboardCommandSplit.swift` 必须定义 `L4DashboardLivePROConsoleCommandSplitContract`、`L4LivePROConsoleCommandGateViewModel`、`L4DashboardLivePROConsoleCommandSplitEvidence` 和 `L4DashboardCommandSplitRuntime`。
- `Tests/AppTests/AppTests.swift` 必须包含 `testGH468DashboardLivePROConsoleSplitKeepsDashboardReadModelOnly` 和 `testGH468DashboardLivePROConsoleSplitRejectsDashboardCommandsAndGateBypass`。
- Dashboard 必须继续 read-model-only，且不得提供 submit / cancel / replace、trading button、order form、broker connect、signed endpoint、account endpoint 或 private stream control。
- Future Live PRO Console gate 必须表达 read-only、armed、blocked、incident 四类状态，并保持 command surface default invisible or disabled until GH-469。
- Evidence 必须证明 UI 只消费 ViewModel / ReadModel / CommandGate state，并继续要求 RiskEngine gate、OMS gate、kill switch gate、reconciliation evidence 和 audit trail evidence。
- Boundary tests 必须拒绝 Dashboard command surface、提前启用 Live PRO Console command UI、production command、RiskEngine bypass、OMS bypass、broker gateway touch、signed endpoint call 和 real order submit。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-468 必须建立的主要 anchors：

- `GH-468-DASHBOARD-LIVEPRO-READONLY-COMMAND-SPLIT`
- `GH-468-DASHBOARD-READ-MODEL-ONLY`
- `GH-468-LIVEPRO-CONSOLE-COMMAND-GATE`
- `GH-468-READONLY-ARMED-BLOCKED-INCIDENT-STATES`
- `GH-468-NO-DASHBOARD-SUBMIT-CANCEL-REPLACE`
- `TVM-L4-DASHBOARD-LIVEPRO-COMMAND-SPLIT`

## GH-469 L4 Guarded Command UI Surface Validation

GH-469 的 required validation：

- `docs/contracts/l4-guarded-command-ui-surface-contract.md` 必须存在，并包含 `GH-469-GUARDED-SUBMIT-CANCEL-REPLACE-UI-SURFACE`、`GH-469-SANDBOX-GATE-ONLY-COMMANDS`、`GH-469-CONFIRMATION-BLOCKED-INCIDENT-EVIDENCE`、`GH-469-NO-PRODUCTION-COMMAND-DEFAULT`、`GH-469-NON-AUTHORIZATION` 和 `TVM-L4-GUARDED-COMMAND-UI-SURFACE`。
- `Sources/Dashboard/FutureLiveProConsole/L4GuardedCommandUISurface.swift` 必须定义 `L4GuardedCommandControlViewModel`、`L4GuardedCommandUISurfaceEvidence` 和 `L4GuardedCommandUISurfaceRuntime`。
- `Tests/AppTests/AppTests.swift` 必须包含 `testGH469GuardedCommandUISurfaceAllowsSandboxOnlySubmitCancelReplace` 和 `testGH469GuardedCommandUISurfaceRejectsProductionBypassAndMissingEvidence`。
- Guarded controls 必须覆盖 submit / cancel / replace，并保持 default disabled、sandbox gate only、production gate disabled。
- 每个 control 必须展示 confirmation prompt、confirmation evidence ID、blocked reason、incident stop reason 和 audit evidence ID。
- Evidence 必须消费 GH-468 split evidence，并以 anchor 方式绑定 GH-464 RiskEngine、GH-461 / GH-462 OMS、GH-463 ExecutionEngine sandbox path 和 GH-467 audit trail evidence；Dashboard target 不直接依赖 RiskEngine / OMS / ExecutionEngine target。
- Boundary tests 必须拒绝 production command、Dashboard command surface、missing confirmation、missing audit evidence、ExecutionEngine sandbox evidence bypass、secret storage、signed endpoint call、broker gateway touch 和 real submit / cancel / replace。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。

GH-469 必须建立的主要 anchors：

- `GH-469-GUARDED-SUBMIT-CANCEL-REPLACE-UI-SURFACE`
- `GH-469-SANDBOX-GATE-ONLY-COMMANDS`
- `GH-469-CONFIRMATION-BLOCKED-INCIDENT-EVIDENCE`
- `GH-469-NO-PRODUCTION-COMMAND-DEFAULT`
- `TVM-L4-GUARDED-COMMAND-UI-SURFACE`

## GH-470 L4 Sandbox Validation Matrix Closeout Validation

GH-470 的 required validation：

- `docs/audit/inputs/mtpro-l4-live-production-trading-commands-v1-gh-470-sandbox-validation-closeout.md` 必须存在，并包含 `GH-470-SANDBOX-VALIDATION-MATRIX-CLOSEOUT`、`GH-470-READ-RISK-EXECUTION-OMS-RECONCILIATION-AUDIT-UI-GATE`、`GH-470-NO-DEFAULT-PRODUCTION-TRADING`、`GH-470-NO-SECRET-RAW-BROKER-PAYLOAD`、`GH-470-NON-AUTHORIZATION` 和 `TVM-L4-SANDBOX-VALIDATION-MATRIX-CLOSEOUT`。
- `docs/validation/trading-validation-matrix.md` 必须包含 GH-452 至 GH-470 的 L4 matrix entries，并明确 read、risk、execution、OMS、reconciliation、audit 和 UI gate coverage。
- Automation readiness 必须机械检查 GH-470 closeout input、matrix、validation plan、domain context 和 latest summary anchors。
- Closeout 必须确认 no default production trading、no production cutover、no secret exposure、no raw broker payload exposure、no real broker gateway、no real submit / cancel / replace。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。
- GH-470 不输出 final Stage Code Audit Report，不授权 GH-471 production cutover，不授权 GH-472 Stage Audit input closure，不创建下一 Project / Issue。

GH-470 必须建立的主要 anchors：

- `GH-470-SANDBOX-VALIDATION-MATRIX-CLOSEOUT`
- `GH-470-READ-RISK-EXECUTION-OMS-RECONCILIATION-AUDIT-UI-GATE`
- `GH-470-NO-DEFAULT-PRODUCTION-TRADING`
- `GH-470-NO-SECRET-RAW-BROKER-PAYLOAD`
- `TVM-L4-SANDBOX-VALIDATION-MATRIX-CLOSEOUT`

## GH-471 L4 Production Cutover Gate Validation

GH-471 的 required validation：

- `docs/contracts/l4-production-cutover-no-default-real-trading-policy.md` 必须存在，并包含 `GH-471-PRODUCTION-CUTOVER-FUTURE-GATE`、`GH-471-NO-DEFAULT-REAL-TRADING-POLICY`、`GH-471-HUMAN-ACCEPTANCE-CRITERIA`、`GH-471-ENVIRONMENT-CREDENTIAL-INCIDENT-STOP-GATES`、`GH-471-NON-AUTHORIZATION` 和 `TVM-L4-PRODUCTION-CUTOVER-GATE`。
- `Sources/ExecutionClient/FutureGate/L4ProductionCutoverGatePolicy.swift` 必须定义 `L4ProductionCutoverPrerequisite`、`L4ProductionCutoverAcceptanceCriterion`、`L4ProductionCutoverForbiddenCapability` 和 `L4ProductionCutoverGatePolicy`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH471ProductionCutoverGatePolicyDefinesNoDefaultRealTradingBoundary` 和 `testGH471ProductionCutoverGatePolicyRejectsAutomaticCutoverAndProductionBypass`。
- Production cutover 必须是独立 future gate；当前 L4 sandbox 不得默认变成 real trading。
- Human acceptance criteria 必须清晰，并保持 `requiresHumanAcceptance == true`、`allowsAutomationOnlyCutover == false`。
- Boundary tests 必须拒绝 production trading default、automatic cutover、production endpoint connection、automation-only cutover、secret read / storage、broker gateway、Dashboard / Live PRO Console production command、order form、trading button 和 real submit / cancel / replace。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。
- GH-471 不执行 production cutover，不授权 GH-472 Stage Audit input closure 之外的下一 Project / Issue。

GH-471 必须建立的主要 anchors：

- `GH-471-PRODUCTION-CUTOVER-FUTURE-GATE`
- `GH-471-NO-DEFAULT-REAL-TRADING-POLICY`
- `GH-471-HUMAN-ACCEPTANCE-CRITERIA`
- `GH-471-ENVIRONMENT-CREDENTIAL-INCIDENT-STOP-GATES`
- `TVM-L4-PRODUCTION-CUTOVER-GATE`

## GH-472 L4 Stage Audit Input Validation

GH-472 的 required validation：

- `docs/audit/inputs/mtpro-l4-live-production-trading-commands-v1-stage-audit-input.md` 必须存在，并包含 `GH-472-L4-STAGE-AUDIT-INPUT`、`GH-472-EVIDENCE-CHAIN-TRACE`、`GH-472-COMMAND-RISK-EXECUTION-AUDIT-UI-GATE-TRACE`、`GH-472-NO-DEFAULT-PRODUCTION-TRADING`、`GH-472-NO-NEXT-PROJECT-AUTO-PROMOTION`、`GH-472-NON-AUTHORIZATION` 和 `TVM-L4-STAGE-AUDIT-INPUT-CLOSEOUT`。
- Stage Audit input 必须汇总 GH-452 至 GH-471 的 issue / PR / merge evidence chain。
- Stage Audit input 必须证明 command / risk / execution / OMS / reconciliation / audit / UI gate evidence 可追溯。
- Stage Audit input 必须提供 Root Docs Delta input，但不得执行 root docs refresh。
- Stage Audit input 必须确认 no default production trading、no production cutover execution、no next Project / Issue auto promotion。
- Required validation 仍为 `git diff --check`、`bash checks/automation-readiness.sh` 和 `bash checks/run.sh`，不依赖真实 secret、broker credential、signed/account endpoint、listenKey、private WebSocket、production endpoint 或人工验收。
- GH-472 不输出最终 production approval，不打开 production gate，不自动推进下一 Project / Issue。

GH-472 必须建立的主要 anchors：

- `GH-472-L4-STAGE-AUDIT-INPUT`
- `GH-472-EVIDENCE-CHAIN-TRACE`
- `GH-472-COMMAND-RISK-EXECUTION-AUDIT-UI-GATE-TRACE`
- `GH-472-NO-DEFAULT-PRODUCTION-TRADING`
- `GH-472-NO-NEXT-PROJECT-AUTO-PROMOTION`
- `TVM-L4-STAGE-AUDIT-INPUT-CLOSEOUT`

## MTP-24 Trading Validation Matrix Validation

MTP-24 的 required validation：

- `docs/validation/trading-validation-matrix.md` 必须存在。
- Matrix 必须包含 EMA parity、order book imbalance parity、fees / slippage、risk blocker、portfolio exposure、report evidence 和 future issue backfill 的稳定锚点。
- Matrix 必须记录现有 XCTest / fixture coverage 入口。
- Matrix 必须明确 MTP-25 至 MTP-30 如何回填 evidence。
- `checks/automation-readiness.sh` 必须在 matrix 文件或 required anchors 缺失时失败。

## MTP-25 EMA Backtest / Paper Parity Validation

MTP-25 的 required validation：

- EMA Backtest / Paper parity 必须使用 deterministic fixture，不依赖真实 Binance 网络。
- 测试必须覆盖同一 `EMACrossStrategyConfiguration`、同一 `MarketDataQuery`、同一 symbol、同一 timeframe。
- 测试必须锁定 long EMA warm-up 后的首个 signal timestamp、完整 signal direction timeline 和 Backtest / Paper signalSamples 等价。
- Backtest / Paper event flow 必须拒绝超出 `MarketDataQuery.range` 的 bars，避免使用查询窗口外数据生成 parity 假阳性。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-EMA-PARITY` 必须回填新增测试、edge case 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不接 signed endpoint、broker action 或真实订单行为。

## MTP-26 Order Book Imbalance Parity Validation

MTP-26 的 required validation：

- `OrderBookImbalanceSignalSample` 必须记录 snapshot / delta input source，作为 bias evidence 的一部分。
- Core deterministic tests 必须覆盖 bidDominant、neutral、askDominant、depth、bid / ask notional、imbalance ratio、source timestamp、signal direction 和 input source。
- Core parity evidence 必须比较直接 `OrderBookImbalanceStrategyContract` 与 `OrderBookImbalanceResearchEventFlow` 的 signal samples。
- ask dominance 必须保持 research-only：bias 可为 `askDominant`，signal direction 必须仍为 `.flat`，不得引入 short、margin、futures leverage 或真实订单动作。
- Persistence / DuckDB analytical projection 必须保留 order book input source，且仍只输出稳定 read model snapshot，不暴露 schema 或 adapter internals。
- required validation 不依赖真实 Binance 网络、不读取 secret、不连接 broker、不触发真实交易行为。

## MTP-27 Fees / Slippage Validation

MTP-27 的 required validation：

- fees / slippage assumptions 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker 或交易所账户等级。
- Core 测试必须覆盖 maker fee、taker fee、fixed slippage、gross notional、total cost 和统一 rounding scale。
- Backtest / Paper cost evidence 必须在同一 assumption、同一 symbol / timeframe、同一 reference price、同一 quantity 和同一 liquidity role 下保持一致。
- 无效 assumptions 必须被拒绝，包括负数 bps、非有限 bps 或超出允许范围的 rounding scale。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-FEES-SLIPPAGE` 必须回填新增 Core 类型、测试、fixture 和 PR evidence 边界。
- required validation 不引入完整费用模型、不引入交易所费率表、不引入动态滑点模型、不做执行成本优化、不触发 Paper / Live 执行。

## MTP-28 Risk Blocker / Portfolio Exposure Validation

MTP-28 的 required validation：

- risk blocker evidence 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 proposed Paper action context、risk profile、blocker reason、paper-only execution mode 和 Live / broker / signed endpoint 不可回退边界。
- SQLite runtime projection 必须保留 risk blocker evidence、source sequence、projected timestamp 和 rejected paper order ID 派生入口。
- portfolio exposure read model 必须只来自 Paper projection，覆盖 portfolio ID、symbol、timeframe、paper quantity、reference price、gross exposure notional、source sequence 和 read-only ViewModel。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RISK-BLOCKER` 和 `TVM-PORTFOLIO-EXPOSURE` 必须回填新增 Core / Persistence / App 测试、fixture 和 PR evidence 边界。
- required validation 不引入完整风险引擎、不引入实时风控、不引入仓位管理、保证金、杠杆、真实账户余额、broker balance 或 Live execution。

## MTP-29 Report / Dashboard Trading Validation Evidence Validation

MTP-29 的 required validation：

- Report read model 必须汇总 projection-level parity、fees / slippage cost evidence、risk blocker evidence 和 portfolio exposure evidence。
- fees / slippage evidence 必须从 MTP-27 deterministic fixture 和 paper-only portfolio exposure projection 派生，不依赖真实 Binance 网络、secret、broker、account endpoint 或交易所账户等级。
- Report / Dashboard snapshot 必须展示 execution cost evidence count、assumption IDs、cost parity consistency、risk blocker evidence IDs、portfolio exposure symbols 和 gross exposure notional。
- App tests 必须覆盖 trading validation evidence summary 的 Codable / deterministic snapshot、read-model-only 来源、schema leakage 禁区和 research-only execution authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-REPORT-EVIDENCE` 必须回填新增 App 类型、snapshot tests、fixture 和 PR evidence 边界。
- required validation 不新增完整报表系统、不新增交易所费率表、不新增动态滑点模型、不新增执行成本优化、不触发 Paper / Live 执行。

## MTP-30 Stage Audit Input Validation

MTP-30 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-30 当前验证摘要，并引用 MTP-24 至 MTP-29 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-30 阶段收口说明，并指向 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-trading-validation-and-parity-hardening-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Trading validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-30 输入材料和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在 `MTP-24` 至 `MTP-30` 全部 Done 后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

## MTP-31 Paper Session Lifecycle Validation

MTP-31 的 required validation：

- Paper session lifecycle 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 `sessionStarted`、`sessionUpdated`、`sessionClosed` 三类 lifecycle facts。
- Core 测试必须固定 startedAt、updatedAt、closedAt、event log recordedAt 和 stream replay 结果。
- event log 写入边界必须只接受 `PaperEvent` 并固定写入 `.paper` stream。
- `PaperSessionUpdated.signalCount` 必须非负，并只代表本地 signal timeline 数量。
- Persistence / App 只能把 lifecycle facts 投影为稳定 read model state，不得新增交易执行入口。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-SESSION-LIFECYCLE` 必须回填新增 Core 类型、测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-32 Paper Action Proposal Validation

MTP-32 的 required validation：

- Paper action proposal 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 `StrategySignalEvent` 到 proposal side 的映射：`long -> buy`，`flat -> hold`。
- Core 测试必须覆盖 symbol、timeframe、quantity、reference price、notional 和 MTP-27 fixed cost evidence 复用。
- Core 测试必须证明 proposal 固定 `executionMode == paper`、`executionAuthorization == paperIntentOnly` 且 `isExecutableAsRealOrder == false`。
- Codable 解码必须拒绝非 paper mode 或与 signal 不一致的 side，避免绕过 proposal 不变量。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-ACTION-PROPOSAL` 必须回填新增 Core 类型、测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-33 Paper Action Proposal -> Risk Blocker Validation

MTP-33 的 required validation：

- Paper action risk link 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 allowed paper proposal evidence：proposal、risk query、risk profile、source sequence、paper-only context 和无 broker / Live fallback。
- Core 测试必须覆盖 blocked paper proposal evidence：blocker reason、`RiskBlockerEvidence`、source sequence、paper-only execution mode 和无 broker / Live fallback。
- Codable 解码必须拒绝 allowed decision 携带 blocker evidence，且 source sequence 必须为正数。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-RISK-BLOCKER` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-34 Paper-only Portfolio Projection Update Validation

MTP-34 的 required validation：

- Paper-only portfolio update 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 replayed paper-only simulated fill evidence 生成 `PaperPortfolioProjectionUpdate` 和 `PortfolioEvent.paperProjectionUpdated`；MTP-42 后不再允许直接由 risk decision 更新 portfolio projection。
- Core 测试必须覆盖 Codable 解码不能绕过 simulated fill evidence 来源，也不能恢复交易授权、真实账户余额读取或 broker position sync。
- Persistence 测试必须覆盖 replay envelope 驱动 SQLite runtime projection update，并保留 simulated fill event source sequence。
- App 测试必须覆盖 Portfolio ViewModel 只消费 read model projection，不直连 database schema、runtime object、adapter、broker 或交易动作。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PORTFOLIO-EXPOSURE` 必须回填新增 Core / Persistence / App 测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-35 Paper Session Replay Evidence Validation

MTP-35 的 required validation：

- Paper Session replay 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- Core 测试必须覆盖 `PaperEvent.actionProposed`、`PaperSessionReplayEvidenceSummary` 和 `PaperSessionReplayPath.summarize`。
- Replay summary 必须覆盖 session lifecycle events、proposal events、risk blocker events 和 portfolio projection events。
- Replay summary 必须固定 replayed sequences、streams、session IDs、proposal IDs、risk blocker evidence IDs、portfolio update IDs 和 paper-only boundary flags。
- 测试必须证明乱序 replay result 被拒绝，避免非 append-only 顺序输入被标记为 deterministic evidence。
- Persistence 测试必须证明 `FileEventLogStore` append-only facts source 经 replay 后生成同一 deterministic summary，并可驱动 SQLite runtime projection。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-SESSION-REPLAY` 必须回填新增 Core / Persistence 测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-36 Paper Session Runtime Evidence Report / Dashboard Validation

MTP-36 的 required validation：

- Report read model 必须汇总 Paper Session lifecycle、proposal、risk blocker、portfolio exposure 和 replay evidence。
- Runtime evidence 必须使用 MTP-35 deterministic replay fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- App tests 必须覆盖 `PaperSessionRuntimeEvidenceSummary`、`ResearchBacktestReportArtifact.paperRuntimeEvidence`、`ReportViewModel` 汇总字段和 `DashboardShellSnapshot` Report 区域展示。
- Codable snapshot 必须证明 runtime evidence 可稳定编码 / 解码，且 `paperRuntimeAuthorizesTradingExecution`、`paperRuntimeAuthorizesLiveTrading`、`paperRuntimeTouchesBrokerAction` 保持 false。
- Dashboard smoke 必须继续只输出 read-model-only summary，不新增按钮、表单、risk control command、position management command 或交易执行入口。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-REPORT-EVIDENCE` 和 `TVM-PAPER-SESSION-REPLAY` 必须回填新增 App 类型、snapshot tests、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行。

## MTP-37 Validation Docs / Stage Audit Input Validation

MTP-37 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-37 当前验证摘要，并引用 MTP-31 至 MTP-36 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-37 Paper Session Runtime 阶段收口说明，并指向 MTP-37 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Paper runtime validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-37 输入材料和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在 `MTP-31` 至 `MTP-37` 全部 Done 后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

## MTP-38 Paper-only Execution Workflow Contract Validation

MTP-38 的 required validation：

- Paper-only execution workflow contract 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint 或真实订单。
- Core 测试必须覆盖 `PaperExecutionWorkflowStage`、`PaperExecutionWorkflowStageBoundary`、`PaperExecutionWorkflowContract.deterministicFixture` 和 stage order。
- Contract 必须明确 proposal、risk decision、paper execution decision、paper order、simulated fill 和 portfolio projection 的关系。
- Event boundary 必须固定 `.paper` / `.risk` / `.portfolio` stream 归属，并记录未来 issue 只能在合同内补充本地 paper-only evidence。
- Codable snapshot 必须拒绝 `authorizesTradingExecution`、Live trading、signed endpoint、broker action 或 real order capability 绕过。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-EXECUTION-WORKFLOW` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 simulated fill、完整 OMS 或真实交易行为。

## MTP-39 Paper Order Intent / Lifecycle Validation

MTP-39 的 required validation：

- Paper order intent / lifecycle 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- Core 测试必须覆盖 `PaperOrderLifecycleState`、`PaperOrderIntent` 和 `PaperOrderIntentFixture`。
- Tests 必须覆盖 allowed risk decision -> `intentCreated`、blocked risk decision -> `rejectedByRisk`，并锁定 blocker evidence ID、source risk decision sequence、symbol、timeframe、quantity、reference price 和 notional。
- Tests 必须证明 paper order intent 固定 `executionMode == paper`、`proposalAuthorization == paperIntentOnly`、`workflowStage == paperOrder`、`eventStream == .paper` 和 `evidenceKind == paperOrder`。
- Codable snapshot 必须拒绝非 paper mode、risk result / lifecycle 不一致、trading authorization、Live trading、signed endpoint、broker action、real order 或 simulated fill capability 绕过。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-ORDER-LIFECYCLE` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 paper execution decision、simulated fill、完整 OMS、cancel / replace 或真实交易行为。

## MTP-40 Simulated Fill Evidence Validation

MTP-40 的 required validation：

- Simulated fill evidence 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue、真实订单或真实成交回报。
- Core 测试必须覆盖 `PaperSimulatedFillAssumption`、`PaperSimulatedFillEvidence` 和 `PaperSimulatedFillFixture`。
- Tests 必须覆盖 allowed paper order intent -> simulated fill evidence，并锁定 fill ID、order ID、proposal ID、risk decision ID、source order intent sequence、source risk decision sequence、symbol、timeframe、filled quantity、fill price、gross notional 和 filledAt。
- Tests 必须证明 fixed cost evidence 复用 MTP-27 deterministic assumptions，并锁定 fee / slippage / total cost。
- Tests 必须证明 risk-rejected order intent 不得生成 simulated fill。
- Codable snapshot 必须拒绝非 paper mode、real fill、broker fill、account update、trading authorization、Live trading、signed endpoint、broker action 或 real order capability 绕过。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-SIMULATED-FILL` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 paper execution decision、event log 写入、replay、portfolio projection、完整 OMS、动态滑点、交易所费率表或真实交易行为。

## MTP-41 Paper Execution Decision Validation

MTP-41 的 required validation：

- Paper execution decision 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue、真实订单或真实成交回报。
- Core 测试必须覆盖 `PaperExecutionDecisionStatus`、`PaperExecutionDecision`、`PaperExecutionDecisionLink` 和 `PaperExecutionDecisionFixture`。
- Tests 必须覆盖 allowed risk decision -> paper execution decision -> paper order intent -> simulated fill evidence，并锁定 proposal ID、risk decision ID、order ID、fill ID、source risk decision sequence、source order intent sequence、symbol、timeframe、quantity、reference price 和 decidedAt。
- Tests 必须覆盖 blocked risk decision 不生成 paper order intent、simulated fill assumption 或 simulated fill evidence。
- Codable snapshot 必须拒绝 status mismatch、blocked order bypass、trading authorization、Live trading、signed endpoint、broker action、real order、real fill、broker fill 或 account update capability 绕过。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-EXECUTION-DECISION` 和 `TVM-PAPER-EXECUTION-WORKFLOW` 必须回填新增 Core 类型、fixture、测试和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不写 event log、不新增 replay / projection / ViewModel、不实现完整 execution engine、完整风险引擎、broker rejection fallback 或真实交易行为。

## MTP-42 Paper Execution Event Replay Projection Validation

MTP-42 的 required validation：

- Paper execution event log / replay / projection 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue、真实订单或真实成交回报。
- Core 测试必须覆盖 `PaperExecutionEventLogBoundary` 按 decision -> order intent -> simulated fill 写入 `.paper` stream，并校验 source order sequence。
- Core 测试必须覆盖乱序或 source sequence mismatch 被拒绝，避免不可追溯 fill evidence 进入 replay。
- Core / Persistence 测试必须覆盖 replay 后的 `simulatedFillRecorded` fact 才能生成 `PaperPortfolioProjectionUpdate`；portfolio projection 不得直接从 risk decision、broker fill、account update 或真实账户状态派生。
- Replay summary 必须覆盖 execution decision IDs、paper order IDs、simulated fill IDs、portfolio update IDs 和 paper-only boundary flags。
- SQLite runtime projection 必须继续只消费 replay envelope / portfolio projection fact，并输出稳定 snapshot，不暴露 schema。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-EXECUTION-WORKFLOW`、`TVM-PAPER-SESSION-REPLAY` 和 `TVM-PORTFOLIO-EXPOSURE` 必须回填新增 Core / Persistence / App 测试、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现生产级 event sourcing、schema migration framework、FileEventLogStore 重写、broker event replay 或真实交易行为。

## MTP-44 Paper Execution Workflow Report / Dashboard Evidence Validation

MTP-44 的 required validation：

- Report read model 必须汇总 paper execution workflow、paper order lifecycle、simulated fill、replay 和 portfolio projection evidence。
- Workflow evidence 必须从 append-only replay / projection / read model 派生，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue、真实订单或真实成交回报。
- App tests 必须覆盖 `PaperExecutionWorkflowEvidenceSummary`、`ResearchBacktestReportArtifact.paperExecutionWorkflowEvidence`、`ReportViewModel` 汇总字段和 `DashboardShellSnapshot` Report 区域展示。
- Codable snapshot 必须证明 workflow evidence 可稳定编码 / 解码，且 paper execution workflow 不授权 trading execution、Live trading 或 broker action。
- Dashboard smoke 必须继续只输出 read-model-only summary，不新增 order command、risk control command、position management command 或交易执行入口。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-EXECUTION-WORKFLOW`、`TVM-PAPER-SESSION-REPLAY` 和 `TVM-REPORT-EVIDENCE` 必须回填新增 App 类型、snapshot tests、fixture 和 PR evidence 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不触发 Paper / Live 执行，不暴露 SQLite / DuckDB schema、runtime object 或 adapter request。

## MTP-45 Validation Docs / Stage Audit Input Validation

MTP-45 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-45 当前验证摘要，并引用 MTP-38 至 MTP-44 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-45 Paper Execution Workflow 阶段收口说明，并指向 MTP-45 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-paper-execution-workflow-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Paper execution workflow validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-45 输入材料和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

## MTP-47 Paper Workflow Dashboard IA / Control Shell Boundary Validation

MTP-47 的 required validation：

- Dashboard information architecture 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- App tests 必须覆盖 `PaperWorkflowSessionControl`、`PaperWorkflowObservabilitySection`、`PaperWorkflowForbiddenCapability` 和 `PaperWorkflowDashboardInformationArchitecture.deterministicFixture`。
- Tests 必须证明 session-level controls 只允许 `start` / `pause` / `close` / `reset`。
- Tests 必须证明 Dashboard 观察面覆盖 session、proposal、risk decision、paper order、simulated fill、portfolio projection、replay freshness、report artifact status 和 event timeline。
- Tests 必须证明 order-level command、非 read-model-only source、提前实现 Command Model、UI controls 或 Event Timeline 会被合同拒绝。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 App 类型、fixture、tests 和 no order-level command 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 Command Model、不实现 UI 控件、不实现 Event Timeline、不触发 Paper / Live 执行。

## MTP-48 Paper Session Local Control Command Model Validation

MTP-48 的 required validation：

- Command Model 必须使用 deterministic fixture，不依赖真实 Binance 网络、secret、broker、account endpoint、外部 execution venue 或真实订单。
- Core tests 必须覆盖 `PaperSessionLocalControlAction` 的 `start` / `pause` / `close` / `reset`。
- Tests 必须证明 accepted command 只作用于本地 Paper session，`scope == local paper session`、`controlLevel == session`、`executionMode == paper`。
- Tests 必须证明非 session-level command 被拒绝，并记录 `PaperSessionLocalControlRejectedReason`。
- Tests 必须证明 `submit` / `cancel` / `replace`、order-level command、broker action 和非 paper execution mode 被拒绝。
- Codable tests 必须证明 payload 不能恢复 order-level command、真实交易授权、Live trading、signed endpoint、account endpoint、listenKey、broker action 或真实订单 submit / cancel / replace capability。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 Core 类型、fixture、tests、rejected reason 和 no order-level / no broker action 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 UI 控件、不实现 Event Timeline、不写 event log、不触发 Paper / Live 执行。

## MTP-49 Paper Session Local Control Event Boundary Validation

MTP-49 的 required validation：

- Core tests 必须覆盖 accepted `start` / `pause` / `close` / `reset` command -> `PaperEvent.sessionControlApplied`。
- Tests 必须证明 accepted control facts 固定写入 `.paper` stream，且保持 `paperOnlyBoundaryHeld == true`。
- Tests 必须覆盖 invalid command -> `PaperEvent.sessionControlRejected`，并保留 `PaperSessionLocalControlRejectedReason`。
- Tests 必须证明 `submit` / `cancel` / `replace`、order-level command、broker action 和非 paper execution mode 只能形成 rejection evidence，不生成 order intent、simulated fill、broker action 或真实订单行为。
- Tests 必须证明 `AppendOnlyEventLog` sequence 保持单调 append-only，不允许重排或覆盖既有 facts。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 Core event boundary、event cases、tests 和 no UI / no workflow engine 边界。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 UI 控件、不实现 Event Timeline、不触发 Paper / Live 执行。

## MTP-50 Paper Workflow Observability Read Model / ViewModel Validation

MTP-50 的 required validation：

- App tests 必须覆盖 `PaperWorkflowObservabilityReadModel` 和 `PaperWorkflowObservabilityViewModel` 的 deterministic snapshot。
- Tests 必须验证 session status、proposal IDs、allowed decision / order / simulated fill evidence、blocked risk evidence、portfolio projection evidence、replay freshness 和 report artifact status 字段完整。
- Tests 必须验证 ViewModel 可 Codable encode / decode，并保持 deterministic equality。
- Tests 必须验证 `readModelOnlyBoundaryHeld`、`paperOnlyBoundaryHeld` 为 true。
- Tests 必须验证不暴露 database schema、runtime object、adapter request、order-level command、Live trading、broker action 或 trading execution authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 App read model / ViewModel、tests、snapshot evidence 和 schema non-exposure evidence。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 UI redesign、不实现 Event Timeline explorer、不触发 Paper / Live 执行。

## MTP-51 Paper Workflow Event Timeline / Evidence Explorer Validation

MTP-51 的 required validation：

- App tests 必须覆盖 `PaperWorkflowEvidenceExplorerReadModel` 和 `PaperWorkflowEvidenceExplorerViewModel` 的 deterministic timeline snapshot。
- Tests 必须验证 market event、strategy signal、risk decision、paper order、simulated fill、portfolio projection 和 report artifact section coverage。
- Tests 必须验证 evidence links 覆盖 report artifact、risk blocker、execution decision、paper order、simulated fill 和 portfolio projection evidence。
- Tests 必须验证 read-only filter snapshot 和 section snapshot 只在 ViewModel 内筛选，不提供 query language 或 command surface。
- Tests 必须验证 ViewModel 可 Codable encode / decode，并保持 deterministic equality。
- Tests 必须验证 `readModelOnlyBoundaryHeld` 为 true。
- Tests 必须验证不暴露 database schema、runtime object、adapter request、Persistence adapter direct read、order-level command、Live trading、broker action 或 trading execution authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填新增 App Event Timeline / Evidence Explorer read model / ViewModel、tests、snapshot evidence 和 no command / no schema evidence。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 UI redesign、不实现 operations console、不实现完整 query language、不触发 Paper / Live 执行。

## MTP-52 Dashboard / Workbench Shell Validation

MTP-52 的 required validation：

- App tests 必须覆盖 `DashboardShellWorkbenchSnapshot` 绑定 session-level controls、observability metrics / details 和 Event Timeline / Evidence Explorer preview。
- Tests 必须验证 `DashboardShellControlSnapshot` 只映射 `start` / `pause` / `close` / `reset`，scope 固定为 local paper session，control level 固定为 session，execution mode 固定为 paper。
- Tests 必须验证 `DashboardShellSnapshot.smokeSummary` 继续包含 `sections=8` 和 `readModelOnly=true`，并新增 `workbenchReadModelOnly=true`、controls 和 timeline item evidence。
- Tests 必须验证 shell source 不导入 Runtime / Adapters，不包含 schema 直连关键词，不包含按钮、文本输入或开关控件。
- Tests 必须验证 Workbench shell 不提供 command surface、order-level command、database schema、runtime object、adapter request、Live trading、broker action 或 trading execution authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-PAPER-WORKFLOW-CONTROL-SHELL` 必须回填 Dashboard / Workbench shell snapshot、App tests、Dashboard smoke 和 forbidden command evidence。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现完整 UI redesign、不触发 Paper / Live 执行。

## MTP-53 Validation Docs / Stage Audit Input Validation

MTP-53 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-53 当前验证摘要，并引用 MTP-47 至 MTP-52 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-53 Paper Workflow Control Shell 阶段收口说明，并指向 MTP-53 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-paper-workflow-control-shell-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Paper workflow control shell validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-53 输入材料、Dashboard smoke evidence 和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Dashboard smoke 必须继续覆盖 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 timeline item evidence 字段。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不授权下一 Project planning 或 execution。

## Codex / Automation Validation

- Codex use-cases 对齐：`docs/automation/codex-use-cases-alignment.md`。
- Verified operations：`docs/automation/verified-operations.md`。
- Eval 引入策略：`docs/validation/eval-strategy.md`。
- macOS build / run / telemetry 闭环：`docs/validation/macos-build-run-loop.md`。

新增或修改 production code 时，验证前必须检查详细中文注释是否覆盖业务目的、输入输出、领域不变量、外部系统边界和交易能力禁区。

## 后续验证方向

后续按 Linear issue 增加：

- market data replay tests。
- EMA cross backtest tests。
- paper / backtest parity tests。
- risk decision tests。
- persistence projection rebuild tests。
- file event log corruption / recovery tests。
- UI ViewModel snapshot tests。
- macOS App shell build / run / telemetry tests。

## MTP-20 Binance Client Validation

MTP-20 的 required validation：

- 使用 mock transport 覆盖 REST public endpoint request。
- 使用 mock transport 覆盖 public depth stream request path。
- 使用 fixture parity 验证 client decode 结果与 `BinancePublicMarketDataPayloadDecoder` 一致。
- 断言 transport request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- 断言 mutable 或 `requiresAPIKey == true` 的 request contract 在 transport 前被拒绝。
- 断言非 public market data allowlist 的 Binance path 在 transport 前被拒绝。
- required validation 不依赖真实 Binance 网络；真实网络 smoke test 只能作为可选人工证据。

## MTP-21 Runtime Ingest Validation

MTP-21 的 required validation：

- 使用 mock transport 覆盖 Binance public REST / public depth stream request。
- 使用 fixture parity 验证 workflow ingest events 与 `BinancePublicMarketDataPayloadDecoder` 输出一致。
- 验证 event log sequence 从 1 开始连续递增。
- 验证 replay result 与写入 envelopes 一致，且 market cache projection deterministic。
- 验证 DuckDB analytical snapshot 来自 replay，并包含 market bars、trades、best bid / ask、order book snapshot 和 delta。
- 验证 SQLite runtime snapshot 在 market-only ingest 下保持稳定空 snapshot，且仍由 replay 驱动。
- 断言 request 不携带 API key、signature、listenKey、account、order、SAPI、FAPI 或 DAPI 片段。
- required validation 不依赖真实 Binance 网络；真实网络 smoke test 只能作为可选人工证据。

## MTP-22 macOS Dashboard Shell Validation

MTP-22 的 required validation：

- 使用 SwiftUI shell 绑定 `DashboardViewModel` snapshot。
- 验证 Market / Strategy / Backtest / Paper / Risk / Portfolio / Events 七个只读区域都来自 ViewModel / Read Model。
- 验证 shell source 不导入 Runtime / Adapters，也不直接引用数据库实现名或 public market data client 类型。
- 验证 `swift build --product Dashboard` 可构建 macOS 看板入口。
- 验证 `DASHBOARD_SMOKE=1 swift run Dashboard` 可输出 read-model-only smoke summary 并退出。
- 验证 Linux CI 可通过非 SwiftUI fallback 编译 App target、executable target 和 AppTests；真实 SwiftUI shell 只在 macOS 本地构建。
- required validation 不接真实网络、不读取 secret、不连接 broker、不触发真实交易行为。

## MTP-23 Research -> Backtest -> Report Validation

MTP-23 的 required validation：

- 验证 `ReportReadModel` 只能从 projection snapshots / read model 和 append-only event timeline 生成。
- 验证 report artifact 绑定 backtest run、research run、Paper session、event count 和 last applied sequence。
- 验证 projection-level Backtest / Paper parity evidence 保持一致，同时不替代 Core 层完整时间线 parity 测试。
- 验证 Dashboard shell 呈现 Report 快照，且 shell 不导入 Runtime / Adapters、不引用数据库实现名、不调用行情 adapter。
- 验证缺失 Paper projection 时报告标记为 missing paper projection，不回退到 Live、broker、signed endpoint 或真实订单路径。
- 验证 Issue 8 只准备阶段证据材料；Stage Code Audit Report 仍须在 Project 全部 Done 后由父 Codex 单独输出。
- required validation 不接真实网络、不读取 secret、不连接 broker、不触发真实交易行为。

## MTP-54 Binance Market Data Batch / Replay Boundary Validation

MTP-54 的 required validation：

- `BinanceMarketDataBatchReplayBoundary` 必须定义 public read-only、本地 fixture replay 和 required validation 离线可重复边界。
- `BinanceMarketDataBatchReplayContractField` 必须覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- `BinanceMarketDataBatchReplayValidationMode` 必须把 required mock transport / fixture parity / local batch replay 与 optional manual Binance public network smoke 分开。
- Tests 必须验证 required validation 不依赖真实 Binance 网络。
- Tests 必须验证 contract 明确 public read-only、fixture / batch replay 和 local replay operations evidence。
- Tests 必须验证 signed endpoint、account endpoint、listenKey、broker action、真实订单和 production runtime operations 被禁止。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-54 boundary fixture、tests、contract docs 和 public read-only / no signed endpoint / no broker action validation anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现真实历史下载器，不接 Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-55 Market Data Replay Metadata / Batch Replay Contract Validation

MTP-55 的 required validation：

- `BinanceMarketDataReplayOperationsMetadata` 必须覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count 和 checksum / parity hint。
- `BinanceMarketDataBatchReplayContract` 必须把 metadata 绑定到 `BinanceMarketDataBatchReplayBoundary`，并证明 required fields、required validation mode、optional validation mode 和 forbidden capability 未漂移。
- `BinanceMarketDataReplayOperationsFixture` 必须提供 deterministic metadata / contract evidence，且 Codable round-trip 后保持 equality。
- Tests 必须验证 required validation 只依赖 mock transport / fixture parity / local batch replay，不依赖真实 Binance 网络。
- Tests 必须验证 metadata field values 不包含 signed endpoint、account endpoint、listenKey、broker、real order 或 production runtime operations 字段。
- Tests 必须验证非法 metadata 被拒绝，例如负数 record count、空 checksum / parity hint 或不完整 boundary contract。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-55 metadata value model、batch replay contract、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现真实历史下载器、production scheduler、retention engine、freshness read model、event / projection consistency、UI evidence、Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-56 Market Data Replay Retention / Freshness Evidence Validation

MTP-56 的 required validation：

- `BinanceMarketDataReplayRetentionPolicy` 必须表达最小本地 retention policy，并 deterministic 计算 fresh、stale、expired 和 not retained。
- `BinanceMarketDataReplayFreshnessEvidenceReadModel` 必须从 `BinanceMarketDataBatchReplayContract` 派生，覆盖 batch id、replay run id、symbol、interval、time window、fixture source、record count、checksum / parity hint、policy id、retention window、batch age 和 freshness status。
- `BinanceMarketDataReplayBatchFreshnessSummary` 必须聚合多个 batch freshness evidence，输出 fresh / stale / expired / not retained / retained batch ids 和稳定 summary line。
- Tests 必须验证 freshness read model 不暴露 SQLite / DuckDB schema、adapter request、runtime object、storage tiering、cloud archive、production deletion job 或 command surface。
- Tests 必须验证 freshness evidence 保持 public read-only、local fixture replay、required validation local-only，并拒绝非本地 replay contract。
- Tests 必须验证 freshness evidence 不包含 signed endpoint、account endpoint、listenKey、broker、real order、Live trading 或 production runtime operations 字段。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-56 retention policy、freshness read model、batch freshness summary、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现生产 retention engine、真实数据清理任务、云端 archive、storage tiering、event / projection consistency、UI evidence、Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-57 Market Data Replay Fixture Parity / Replay Consistency Validation

MTP-57 的 required validation：

- `BinanceMarketDataBatchReplayConsistencyEvidence` 必须从 `BinanceMarketDataBatchReplayContract` 和本地 replayed `MarketBar` records 派生，不读取真实 Binance 网络、不写 event log、不触发 projection。
- `BinanceMarketDataBatchReplayDeterministicParity` 必须生成 deterministic replay output summary 和 checksum / parity hint，并验证 metadata checksum / parity hint 与 replay output 一致。
- Tests 必须覆盖 fixture parity、metadata record count consistency、symbol / interval / time window consistency、record ordering、checksum / parity hint drift 和 Codable deterministic equality。
- Tests 必须验证 required validation 仍只依赖 mock transport / fixture parity / local batch replay，真实 Binance network smoke 只能作为 optional manual evidence。
- Tests 必须验证 consistency evidence 不触碰 signed endpoint、account endpoint、listenKey、broker action、Live trading、真实订单或 production runtime operations。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-57 replay consistency evidence、deterministic parity helper、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现真实历史下载器、production operations、event log / projection consistency、Dashboard UI、Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-58 Market Data Replay Event Log / Projection Consistency Validation

MTP-58 的 required validation：

- `MarketDataReplayProjectionConsistency` 必须把 MTP-55 metadata、MTP-56 freshness evidence、MTP-57 replay consistency evidence 和 append-only event log facts 对齐。
- `MarketDataReplayEventLogConsistencyEvidence` 必须验证 `.market` stream sequence、replay result sequence、metadata record count 和 event log record count 一致。
- `MarketDataReplayProjectionSnapshotConsistencySummary` 必须验证 replay output summary、event log summary、cache snapshot summary 和 DuckDB analytical projection summary 一致。
- Tests 必须验证 market-only replay 不在 SQLite runtime projection 中产生 Paper / Risk / Portfolio 状态。
- Tests 必须验证 summary 可 Codable encode / decode，并保持 deterministic equality。
- Tests 必须验证 summary 不暴露 SQLite / DuckDB schema、SQL、ORM、Runtime object、adapter request 或 persistence implementation。
- Tests 必须验证 schema / runtime source drift、event log drift 和 projection snapshot drift 会被拒绝。
- Tests 必须验证 consistency evidence 不触碰 signed endpoint、account endpoint、listenKey、broker action、Live trading、真实订单或 production runtime operations。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-58 Runtime 类型、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现完整 schema、不实现 migration framework、不实现 production data pipeline、不实现 Dashboard UI、Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-59 Market Data Replay Report / Dashboard / Event Timeline Evidence Validation

MTP-59 的 required validation：

- `MarketDataReplayOperationsEvidenceReadModel` 必须只复制已验证 replay operations summary 字段，不读取 SQLite / DuckDB schema，不调用 Runtime object 或 adapter request。
- `MarketDataReplayOperationsEvidenceViewModel` 必须展示 batch id、replay run id、freshness status、retention status、event log record count、replayed record count 和 projection consistency summary。
- `ReportViewModel` 必须汇总 replay operations evidence count、batch ids、replay run ids、freshness / retention status 和 read-model-only boundary。
- `PaperWorkflowEvidenceExplorerViewModel` 必须新增 `market data replay operation` timeline item，并保持 filter / section snapshot 只读。
- `DashboardShellSnapshot` 必须展示 replay ops 指标和 details，Dashboard smoke 继续保持八个主 sections、readModelOnly=true 和 workbenchReadModelOnly=true。
- Tests 必须覆盖 Report / Dashboard / Event Timeline replay operations evidence、Codable deterministic snapshot、read-model-only boundary、schema / runtime / adapter non-exposure、无 command surface 和无 Live / broker / real order authorization。
- `docs/validation/trading-validation-matrix.md` 的 `TVM-MARKET-DATA-REPLAY-OPERATIONS` 必须回填 MTP-59 App read model / ViewModel、Dashboard shell、focused tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现完整 UI redesign、不实现 production operations console、不实现 Runtime command、不实现 Live trading、signed endpoint、account endpoint、broker action 或真实订单。

## MTP-60 Validation Docs / Stage Audit Input Validation

MTP-60 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-60 当前验证摘要，并引用 MTP-54 至 MTP-59 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-60 Market Data Replay Operations 阶段收口说明，并指向 MTP-60 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-market-data-replay-operations-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Market data replay operations validation evidence chain、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-60 输入材料、Dashboard smoke evidence 和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Dashboard smoke 必须继续覆盖 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 `timelineItems=0` evidence 字段。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不授权下一 Project planning 或 execution。

## MTP-61 Live Trading Foundation Taxonomy / Gate Validation

MTP-61 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须存在，并包含 `MTP-61-LIVE-FOUNDATION-TAXONOMY`、`MTP-61-LIVE-GATE-SEQUENCE` 和 `MTP-61-LIVE-SLICE-SEPARATION` 锚点。
- Taxonomy 必须定义 `live capability`、`blocked capability`、`future gate` 和 `forbidden capability`，并明确它们当前都是 non-executable boundary / blocked evidence，不代表可调用能力。
- Gate sequence 必须保持 Gate 0 至 Gate 6 的顺序：taxonomy / blocked boundary -> API key / signed / account / listenKey boundary -> adapter capability isolation -> real order lifecycle terms -> Live readiness blocked read model -> Workbench blocked evidence surface -> Stage validation closeout。
- MTP-61 必须明确 Live trading foundation 与实盘监控台、实盘执行控制、实盘风险控制、实盘审计 / 事故回放 / 停机控制的分界；后四类仍为 future slices。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-TRADING-FOUNDATION`，并回填 MTP-61 contract docs、domain terms、validation anchor 和 automation readiness anchor。
- `checks/automation-readiness.sh` 必须检查 MTP-61 contract / matrix / validation anchors，避免后续 issue 在缺失 foundation taxonomy 时继续施工。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、真实订单、OMS、`LiveExecutionAdapter`、live command 或交易按钮。

## MTP-62 API Key / Signed / Account / ListenKey Boundary Validation

MTP-62 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-62-CREDENTIAL-ENDPOINT-BOUNDARY`、`MTP-62-LIVE-CREDENTIAL-FUTURE-GATES` 和 `MTP-62-PUBLIC-READ-ONLY-SEPARATION` 锚点。
- `Sources/Core/LiveTradingBoundary.swift` 必须定义 `LiveTradingCredentialEndpointBoundary`、`LiveTradingCredentialEndpointCapability`、`LiveTradingCredentialEndpointFutureGate` 和 `LiveTradingCredentialEndpointEvidenceKind`。
- `LiveTradingCredentialEndpointBoundary` 必须把 API key、secret storage、request signature、signed endpoint、account endpoint、listenKey user data stream 和 real account payload 固定为 forbidden capability。
- `LiveTradingCredentialEndpointBoundary` 的 `readsAPIKey`、`storesSecret`、`signsRequests`、`callsSignedEndpoint`、`callsAccountEndpoint`、`createsListenKey`、`consumesRealAccountPayload`、`upgradesPublicReadOnlyAdapter` 和 `requiredValidationDependsOnNetwork` 必须全部为 `false`。
- `Tests/CoreTests/CoreTests.swift` 必须覆盖 deterministic fixture、Codable round trip、forbidden capability flag bypass rejection 和 forbidden capability list drift rejection。
- `Tests/AdaptersTests/AdaptersTests.swift` 必须验证 `BinanceReadOnlyAdapterBoundary` 继续禁止 API key、signed endpoint、account endpoint 和 listenKey user data stream，并且 `BinancePublicMarketDataClient` 在 transport 前拒绝 keyed / signature / account / listenKey contract。
- `docs/validation/trading-validation-matrix.md` 必须在 `TVM-LIVE-TRADING-FOUNDATION` 回填 MTP-62 Core contract、Adapters rejection tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker adapter、真实订单、OMS、`LiveExecutionAdapter`、live command 或交易按钮。

## MTP-63 Adapter Capability Isolation Validation

MTP-63 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-63-ADAPTER-CAPABILITY-ISOLATION`、`MTP-63-LIVE-ADAPTER-FUTURE-GATES`、`MTP-63-BROKER-EXCHANGE-FUTURE-ONLY` 和 `MTP-63-LIVEEXECUTIONADAPTER-NON-IMPLEMENTATION` 锚点。
- `LiveAdapterCapabilityIsolationBoundary` 必须固定 Gate 2 adapter capability isolation，并证明 current `Binance public market data` adapter 只保留 exchangeInfo、klines、recent trades、best bid / ask、depth snapshot 和 depth delta public read-only capabilities。
- Core tests 必须覆盖 `LiveAdapterCapabilityIsolationBoundary` deterministic fixture、Codable round trip、`LiveExecutionAdapter` non-implementation flag、broker / exchange execution adapter instantiation rejection、execution venue rejection 和 submit / cancel / replace bypass rejection。
- Adapters tests 必须覆盖 `BinanceReadOnlyAdapterBoundary` 仍只暴露 public market data allowed capabilities，且 forbidden capabilities 包含 `LiveExecutionAdapter`、broker execution adapter、exchange execution adapter、execution venue connection、real order lifecycle 和 OMS。
- `BinancePublicMarketDataClient` 必须在 transport 前拒绝 broker、LiveExecutionAdapter、submit、cancel 和 replace 执行语义片段；验证不得依赖真实 Binance 网络。
- `checks/automation-readiness.sh` 必须检查 MTP-63 contract / matrix / validation anchors，并拒绝 `Sources/` 或 `Tests/` 中新增 `LiveExecutionAdapter` public type declaration。
- `docs/validation/trading-validation-matrix.md` 必须在 `TVM-LIVE-TRADING-FOUNDATION` 回填 MTP-63 Core contract、Adapters rejection tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 future live adapter，不实现 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`，不连接 execution venue，不提交 / 撤销 / 替换真实订单。

## MTP-64 Real Order Lifecycle Terminology / Future Gate Validation

MTP-64 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-64-REAL-ORDER-LIFECYCLE-TERMINOLOGY`、`MTP-64-REAL-ORDER-LIFECYCLE-FUTURE-GATES`、`MTP-64-PAPER-REAL-LIFECYCLE-ISOLATION` 和 `MTP-64-FORBIDDEN-CAPABILITY-TESTS` 锚点。
- `Sources/Core/LiveTradingBoundary.swift` 必须定义 `RealOrderLifecycleBoundary`、`RealOrderLifecycleTerm`、`RealOrderLifecycleFutureGate`、`RealOrderLifecycleForbiddenCapability` 和 `RealOrderLifecycleEvidenceKind`。
- `RealOrderLifecycleBoundary` 必须固定 Gate 3 real order lifecycle terms，并证明 submit、cancel、replace、execution report、broker fill、reconciliation、OMS、real account state、broker position sync 和 paper evidence upgrade flags 全部为 `false`。
- Core tests 必须覆盖 `RealOrderLifecycleBoundary` deterministic fixture、Codable round trip、forbidden capability flag bypass rejection、terminology drift rejection，以及 `PaperOrderIntent` / `PaperSimulatedFillEvidence` / `PaperPortfolioProjectionUpdate` 不可升级为 real order lifecycle。
- Adapters tests 必须覆盖 `BinanceReadOnlyAdapterBoundary` 继续禁止 execution report、broker fill、order reconciliation、real account state 和 broker position sync，并且 `BinancePublicMarketDataClient` 在 transport 前拒绝 execution report、broker fill、reconciliation 和 OMS 语义片段。
- `checks/automation-readiness.sh` 必须检查 MTP-64 contract / matrix / validation anchors，并拒绝 `Sources/` 或 `Tests/` 中新增 `RealOrderStateMachine` public type declaration。
- `docs/validation/trading-validation-matrix.md` 必须在 `TVM-LIVE-TRADING-FOUNDATION` 回填 MTP-64 Core contract、Adapters rejection tests、paper / real lifecycle isolation tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 real order state machine，不实现 submit / cancel / replace，不实现 execution report、broker fill、reconciliation、OMS、真实账户状态、broker position sync 或真实订单行为。

## MTP-65 LiveReadiness / LiveBlockedEvidence Read Model Validation

MTP-65 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-65-LIVE-READINESS-BLOCKED-READ-MODEL`、`MTP-65-LIVE-BLOCKED-EVIDENCE-GATES`、`MTP-65-READ-MODEL-ONLY-NON-COMMAND` 和 `MTP-65-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE` 锚点。
- `Sources/Core/LiveTradingBoundary.swift` 必须定义 `LiveReadiness`、`LiveReadinessStatus`、`LiveBlockedEvidence`、`LiveBlockedCapability` 和 `LiveBlockedEvidenceKind`。
- `LiveReadiness` 必须固定 Gate 4 live readiness blocked read model，并证明 API key、signed endpoint、account endpoint、listenKey user data stream、broker adapter 和 real order lifecycle evidence 全部为 blocked。
- `LiveReadiness` 和 `LiveBlockedEvidence` 的 read-model-only / no command / no Live authorization / no adapter / no runtime / no SQLite / no DuckDB / no API key / no signed / no account / no listenKey / no broker / no real order lifecycle flags 必须保持 `false` 或只读 blocked 状态。
- Core tests 必须覆盖 `LiveReadiness` deterministic fixture、`LiveBlockedEvidence` deterministic evidence、Codable round trip、blocked capability list drift rejection、command surface rejection、schema / adapter / runtime non-exposure、API key / signed / account / listenKey / broker / real order lifecycle bypass rejection。
- `checks/automation-readiness.sh` 必须检查 MTP-65 contract / matrix / validation anchors、Core type anchors 和 deterministic test anchors。
- `docs/validation/trading-validation-matrix.md` 必须在 `TVM-LIVE-TRADING-FOUNDATION` 回填 MTP-65 Core read model、deterministic tests、contract docs 和 automation readiness anchor。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 live command，不新增交易按钮，不读取 API key，不实现 secret storage、signed endpoint、account endpoint、listenKey、broker adapter、Runtime object exposure、persistence schema exposure、真实订单生命周期或真实交易授权。

## MTP-66 Dashboard / Report / Event Timeline Live Blocked Evidence Validation

日期：2026-05-21

执行者：Codex

MTP-66 的 required validation：

- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-66-LIVE-BLOCKED-EVIDENCE-SURFACE`、`MTP-66-DASHBOARD-REPORT-EVENT-TIMELINE-READ-MODEL`、`MTP-66-NO-LIVE-COMMAND-OR-BUTTON` 和 `MTP-66-SCHEMA-ADAPTER-RUNTIME-NON-EXPOSURE` 锚点。
- `Sources/Dashboard/Report/LiveTradingBlockedEvidence.swift` 必须定义 `LiveTradingBlockedEvidenceItem`、`LiveTradingBlockedEvidenceReadModel` 和 `LiveTradingBlockedEvidenceViewModel`，且只消费 Core `LiveReadiness` / `LiveBlockedEvidence`。
- `ReportViewModel` 必须展示 Live blocked evidence count、blocked capability labels、gate labels、source anchors、status、all gates blocked 和 read-model-only boundary flags。
- `PaperWorkflowEvidenceExplorerViewModel` 必须新增 `live trading blocked evidence` 分区，并为 API key、signed endpoint、account endpoint、listenKey、broker adapter 和 real order lifecycle 各生成只读 timeline item / evidence link。
- `DashboardShellSnapshot` 必须展示 `Live gates` 指标、Live blocked details 和 Dashboard smoke `liveBlockedGates` evidence，同时继续保持八个 Dashboard sections、readModelOnly=true、workbenchReadModelOnly=true 和 session-level controls。
- App tests 必须覆盖 `LiveTradingBlockedEvidenceViewModel` deterministic Codable snapshot、Report / Dashboard / Event Timeline blocked evidence、read-model-only boundary、无 live command、无交易按钮、无真实订单入口、无 adapter / runtime / SQLite / DuckDB schema 暴露。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 live monitoring console、live execution control、live risk control、live audit、live command、交易按钮、API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、Runtime object exposure、persistence schema exposure、真实订单生命周期或真实交易授权。

## MTP-67 Validation Docs / Stage Audit Input Validation

日期：2026-05-21

执行者：Codex

MTP-67 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-67 当前验证摘要，并引用 MTP-61 至 MTP-66 的 Project evidence。
- `docs/contracts/live-trading-boundary-contract.md` 必须包含 `MTP-67-LIVE-BOUNDARY-STAGE-CLOSEOUT`、`MTP-67-STAGE-AUDIT-INPUT-MATERIAL` 和 `MTP-67-NO-FINAL-STAGE-CODE-AUDIT` 锚点。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-67 Live Trading Boundary Definition 阶段收口说明，并指向 MTP-67 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-live-trading-boundary-definition-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Live trading boundary validation evidence chain、Automation readiness evidence、Dashboard smoke evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须检查 MTP-67 输入材料、Live boundary contract、latest summary、validation plan、matrix、Dashboard smoke evidence 和关键锚点，避免 Stage Code Audit 输入材料缺失。
- Dashboard smoke 必须继续覆盖 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`controls=start,pause,close,reset` 和 `liveBlockedGates=6` evidence 字段。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done、Linear Project status `Completed`、`type=completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不授权下一 Project planning 或 execution，不实现任何 Live capability。

## MTP-68 Live Monitoring Console Information Architecture Validation

日期：2026-05-21

执行者：Codex

MTP-68 的 required validation：

- `docs/contracts/live-monitoring-console-contract.md` 必须存在，并包含 `MTP-68-LIVE-MONITORING-CONSOLE-IA`、`MTP-68-LIVE-MONITORING-TERMS`、`MTP-68-LIVE-MONITORING-STATUS-TAXONOMY`、`MTP-68-LIVE-MONITORING-READ-MODEL-ONLY`、`MTP-68-ORDER-STREAM-EVIDENCE-NOT-REAL-ORDER-STATE`、`MTP-68-LIVE-MONITORING-VALIDATION-ANCHORS` 和 `MTP-68-NO-AUTOMATION-READINESS-CLOSEOUT` 锚点。
- Information architecture 必须覆盖 Overview、Runtime Health、Connection、Market Stream、Order Stream Evidence、Latency、Error / Degraded State 和 Operations Evidence。
- 术语必须定义 live runtime health、connection status、market stream status、order stream evidence、latency evidence、error evidence、degraded state 和 operations evidence。
- Dashboard / Report / Event Timeline 必须保持 read-model-only / ViewModel 边界，不暴露 adapter request、Runtime object、actor、workflow object、SQLite / DuckDB schema、SQL、ORM 或 persistence implementation。
- 订单流 / 订单事件流只能表示 blocked / simulated / future evidence，不得表示 real order state machine、execution report、broker fill、order reconciliation、OMS、真实账户状态或 broker position sync。
- `docs/product/product-surface-map.md`、`docs/contracts/frontend-view-model-contract.md`、`docs/domain/context.md` 和 `docs/validation/trading-validation-matrix.md` 必须能定位 MTP-68 information architecture 和 candidate validation anchor。
- `checks/automation-readiness.sh` 在本 issue 中不得修改；MTP-68 只定义 validation anchor 名称 / 入口，automation readiness 机械收口保留给 MTP-74。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不实现 live runtime、connection runtime、stream collector、latency collector、error handler、operations console、live command、交易按钮、API key、secret storage、signed endpoint、account endpoint、listenKey、broker adapter、Runtime object exposure、persistence schema exposure、真实订单生命周期或真实交易授权。

## 禁止

- 不接 Binance signed endpoint。
- 不运行 live execution。
- 不把 eval 框架作为业务实现前置依赖。
- 不把 validation result 当作 Linear 执行授权。

## MTP-69 Live Runtime Health / Connection Status Read Model Validation

日期：2026-05-21

执行者：Codex

MTP-69 的 required validation：

- Core 层必须新增 `LiveRuntimeHealthReadModel` 和 `LiveConnectionStatusReadModel`，并保持 Codable / Equatable / Sendable value model。
- `LiveMonitoringStatus` 必须覆盖 `healthy`、`blocked`、`disconnected`、`degraded` 和 `unavailable`。
- Deterministic fixture 默认必须保持 runtime health `blocked`，connection evidence 必须保持 public market data `disconnected`、future private user data `blocked`、future broker session `unavailable`。
- Tests 必须覆盖 deterministic fixture、Codable round trip、connection source anchors、command surface rejection、network connection rejection、secret / account endpoint / listenKey rejection、broker adapter rejection、Runtime object / SQLite / DuckDB schema rejection。
- Focused validation：`swift test --filter MTP69`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 在本 issue 中不得新增 MTP-69 机械收口；MTP-74 统一收口 MTP-68 至 MTP-73 anchors。

## MTP-69 禁止

- 不实现 live runtime。
- 不建立真实网络连接、WebSocket 或 private WebSocket。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker、broker session、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不提供 reconnect、start / stop live command、交易按钮或真实交易授权。

## MTP-70 Market Stream / Order Stream Blocked Evidence Read Model Validation

日期：2026-05-21

执行者：Codex

MTP-70 的 required validation：

- Core 层必须新增 `LiveStreamMonitoringEvidenceReadModel` 和 `LiveStreamMonitoringEvidenceItem`，并保持 Codable / Equatable / Sendable value model。
- Market stream evidence 必须只表达 public read-only / fixture evidence；deterministic fixture 默认保持 public market stream `disconnected`，不得打开 market WebSocket、生产订阅控制、signed endpoint 或 execution venue。
- Order stream evidence 必须固定为 blocked / simulated / future-only 三类：blocked order stream、simulated paper order evidence 和 future order stream gate。
- Simulated order stream 只能引用 paper order / simulated fill evidence，不得升级为 execution report、broker fill、真实账户更新或 real order lifecycle。
- Tests 必须覆盖 deterministic fixture、Codable round trip、source anchors、market stream public read-only boundary、order stream blocked / simulated / future-only boundary、listenKey / account endpoint / broker fill / execution report / real order state machine / order command rejection。
- Focused validation：`swift test --filter MTP70`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 在本 issue 中不得新增 MTP-70 机械收口；MTP-74 统一收口 MTP-68 至 MTP-73 anchors。

## MTP-70 禁止

- 不实现 market streaming runtime 或 production subscription control。
- 不实现 account/order streaming runtime。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker、broker session、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不消费 execution report，不记录 broker fill，不实现 real order state machine、OMS 或 submit / cancel / replace。
- 不提供 order command、live command、交易按钮或真实交易授权。

## MTP-71 Latency / Error / Degraded State Monitoring Evidence Validation

日期：2026-05-21

执行者：Codex

MTP-71 的 required validation：

- Core 层必须新增 `LiveLatencyErrorDegradedMonitoringEvidenceReadModel`、`LiveMonitoringLatencyEvidenceItem`、`LiveMonitoringErrorEvidenceItem` 和 `LiveMonitoringDegradedStateEvidenceItem`，并保持 Codable / Equatable / Sendable value model。
- Latency evidence 必须只表达本地 deterministic bucket / freshness evidence；fixture 覆盖 runtime health `stale`、public market stream `degraded`、simulated order stream `nominal`、future private user data `unavailable` 和 future broker session `unavailable`。
- Error evidence 必须只表达 deterministic error summary；fixture 覆盖 public market stream disconnected、private user data blocked 和 broker session unavailable。
- Degraded / unavailable state evidence 必须只把 latency 和 error evidence 串成只读状态摘要；fixture 覆盖 public market stream `degraded` 和 future broker session `unavailable`。
- Tests 必须覆盖 deterministic fixture、Codable round trip、latency / error / degraded source anchors、production telemetry rejection、external metrics rejection、alert / paging / reconnect / stop control rejection、signed endpoint / account endpoint / listenKey rejection、broker adapter / Runtime object / SQLite / DuckDB schema rejection、no live risk control、no incident command、no auto recovery。
- Focused validation：`swift test --filter MTP71`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 在本 issue 中不得新增 MTP-71 机械收口；MTP-74 统一收口 MTP-68 至 MTP-73 anchors。

## MTP-71 禁止

- 不实现 production telemetry、runtime profiler 或 external metrics service。
- 不实现真实 runtime monitoring、runtime polling 或 production monitor。
- 不建立真实网络连接、WebSocket 或 private user data stream。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker、broker session、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不提供 alerting、paging、reconnect、stop control、incident command、auto recovery、live risk control、live command、交易按钮或真实交易授权。

## MTP-72 Dashboard / Report Live Monitoring Evidence Validation

日期：2026-05-21

执行者：Codex

MTP-72 的 required validation：

- App 层必须新增 `LiveMonitoringEvidenceReadModel` 和 `LiveMonitoringEvidenceViewModel`，并保持 Codable / Equatable / Sendable ViewModel snapshot。
- `ReportReadModel.liveMonitoringEvidence` 和 `ReportViewModel.liveMonitoringEvidence` 必须接入 MTP-69 / MTP-70 / MTP-71 Core evidence。
- Report 必须展示 runtime health、connection statuses、stream evidence、latency buckets、error codes、degraded state 和 read-model-only boundary。
- `DashboardShellSnapshot` 必须在 Report section 展示 `Monitoring` 指标，在 Workbench 展示 `Live Monitoring` 只读组，并在 Dashboard smoke 中记录 `liveMonitoringHealth=blocked` 和 `liveMonitoringErrors=3`。
- Tests 必须验证 Dashboard / Report 只消费 ViewModel / Read Model，且不暴露 adapter、Runtime object、SQLite / DuckDB schema。
- Tests 必须验证无 live command、无交易按钮、无 order-level command、无 risk command、无 position command、无 alert / paging / reconnect / stop control、无 incident command、无自动恢复、无 production telemetry、无 external metrics service、无真实网络连接。
- Tests 必须验证无 signed endpoint、account endpoint、listenKey、API key、secret、account payload、broker adapter、`LiveExecutionAdapter`、real order state machine 或真实交易授权。
- Focused validation：`swift test --filter AppTests`。
- Required validation：`bash checks/run.sh`。
- `checks/automation-readiness.sh` 的 MTP-68 至 MTP-73 机械收口仍保留给 MTP-74；MTP-72 只回填 Dashboard / Report evidence 和本地验证证据。

## MTP-72 禁止

- 不新增交易按钮。
- 不新增 live command。
- 不做完整实盘监控台页面重设计。
- 不读取 adapter、Runtime object、SQLite / DuckDB schema。
- 不连接真实外部系统。
- 不实现 execution control、risk control、stop control、alerting、paging、reconnect、incident command 或自动恢复。

## MTP-73 Event Timeline Live Monitoring Evidence Preview Validation

日期：2026-05-21

执行者：Codex

MTP-73 的 required validation：

- App 层必须新增 `PaperWorkflowEvidenceExplorerSection.liveMonitoringEvidence`，并保持 Event Timeline / Evidence Explorer 为 read-model-only ViewModel snapshot。
- `PaperWorkflowEvidenceExplorerReadModel.liveMonitoringEvidence` 必须默认从 `ReportReadModel.liveMonitoringEvidence` 派生，也允许 deterministic tests 显式注入同形 read model。
- `PaperWorkflowEvidenceExplorerViewModel` 必须设置 `coversLiveMonitoringEvidence == true`，并把 live monitoring evidence 分区纳入 `sectionSnapshots` 和 `filterSnapshot`。
- Live monitoring evidence 分区必须生成 18 条 timeline item：runtime health 1 条、connection 3 条、stream 4 条、latency 5 条、error 3 条、degraded state 2 条。
- Full dashboard fixture 必须保持 `timelineItems=42`；empty dashboard snapshot 必须保持 `timelineItems=24`；Dashboard smoke 必须继续输出 `liveBlockedGates=6`、`liveMonitoringHealth=blocked` 和 `liveMonitoringErrors=3`。
- Tests 必须验证 no command surface、no order-level command、no query language、no live audit、no incident replay、no stop control、no broker action、no Live trading authorization 和 no trading execution。
- Focused validation：`swift test --filter AppTests/testLiveMonitoringEvidenceExplorerPreviewDefinesMTP73ReadOnlyTimelineItems`。
- Required validation：`swift test --filter AppTests` 和 `bash checks/run.sh`。
- `checks/automation-readiness.sh` 的 MTP-68 至 MTP-73 机械收口仍保留给 MTP-74；MTP-73 只回填 Event Timeline preview evidence 和本地验证证据。

## MTP-73 禁止

- 不新增 live command、交易按钮、表单、order-level command、risk command 或 position command。
- 不实现 live audit、incident replay、stop control、alert / paging / reconnect、incident command 或自动恢复。
- 不实现 production telemetry、runtime profiler、external metrics service、真实 runtime monitoring、真实网络连接或 WebSocket。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不读取 API key、secret 或 account payload。
- 不连接 broker、broker session、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不消费 execution report，不记录 broker fill，不实现 real order state machine、OMS 或 submit / cancel / replace。

## MTP-74 Validation Docs / Stage Audit Input Validation

日期：2026-05-21

执行者：Codex

MTP-74 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-74 当前验证摘要，并引用 MTP-68 至 MTP-73 的 Project evidence。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-MONITORING-CONSOLE` 的 MTP-74 阶段收口说明，并指向 MTP-74 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-live-monitoring-console-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Live monitoring validation evidence chain、Dashboard smoke、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须机械检查 MTP-68 至 MTP-74 的 contract、matrix、validation plan、latest summary、source / test anchors、Dashboard smoke evidence 和 stage audit input material。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done 且 Linear Project `Completed`、`type=completed`、`completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

MTP-74 必须收口的主要 anchors：

- `MTP-74-LIVE-MONITORING-STAGE-CLOSEOUT`
- `MTP-74-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-74-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-74-LIVE-MONITORING-STAGE-AUDIT-INPUT`
- `MTP-74-LIVE-MONITORING-VALIDATION-EVIDENCE-CHAIN`
- `MTP-74-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-74 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project 或下一 Project issues。
- 不推进下一 Project / Issue。
- 不把 planning notes 当执行授权。
- 不启动下一阶段 `symphony-issue`。
- 不写业务功能扩展。
- 不实现任何 Live trading、execution control、risk control、live audit、incident replay 或 stop control capability。
- 不接 signed endpoint、account endpoint、listenKey、broker adapter、`LiveExecutionAdapter`、real order state machine 或真实订单行为。

## MTP-75 Live Execution Control Terminology / Taxonomy Validation

日期：2026-05-22

执行者：Codex

MTP-75 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须存在，并包含 `MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY`、`MTP-75-REAL-ORDER-COMMAND-TAXONOMY`、`MTP-75-PAPER-REAL-COMMAND-ISOLATION`、`MTP-75-NO-EXECUTABLE-COMMAND-SURFACE` 和 `MTP-75-LIVE-EXECUTION-CONTROL-VALIDATION` 锚点。
- `Sources/ExecutionClient/FutureGate/LiveExecutionControlContract.swift` 必须定义 `LiveExecutionControlTerm`、`FutureRealOrderCommandTaxonomyTerm`、`LiveExecutionControlFutureGate`、`LiveExecutionControlForbiddenCapability`、`LiveExecutionControlEvidenceKind` 和 `LiveExecutionControlTerminologyBoundary`。
- `LiveExecutionControlTerminologyBoundary` 必须固定 execution-control terminology、real order command taxonomy、future gates、forbidden capability baseline、validation anchors 和 paper / real command isolation anchors。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、taxonomy drift rejection、command surface rejection、submit / cancel / replace / execution report / reconciliation / `LiveExecutionAdapter` / real order state machine / OMS bypass rejection，以及 `PaperOrderIntent` / `PaperExecutionDecision` / `PaperSimulatedFillEvidence` 不可升级为 real order command。
- `docs/validation/trading-validation-matrix.md` 必须新增 `TVM-LIVE-EXECUTION-CONTROL` candidate entry，并回填 MTP-75 Core contract、deterministic tests、contract docs 和 validation-plan anchor。
- MTP-75 只定义 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report、broker fill、reconciliation、incident fallback automation、live command、order-level command UI、order form 或交易按钮。

MTP-75 必须建立的主要 anchors：

- `TVM-LIVE-EXECUTION-CONTROL`
- `MTP-75-LIVE-EXECUTION-CONTROL-TERMINOLOGY`
- `MTP-75-REAL-ORDER-COMMAND-TAXONOMY`
- `MTP-75-PAPER-REAL-COMMAND-ISOLATION`
- `MTP-75-NO-EXECUTABLE-COMMAND-SURFACE`
- `MTP-75-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-75 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不实现 broker fill、execution report、reconciliation。
- 不实现 incident fallback automation、stop control、live audit 或 live risk。
- 不新增交易按钮、order form、live command 或 order-level command UI。
- 不把 paper order intent、paper execution decision 或 simulated fill 升级为 future real order command。

## MTP-76 Submit / Cancel / Replace Future Gates Validation

日期：2026-05-22

执行者：Codex

MTP-76 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES`、`MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS`、`MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE`、`MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE` 和 `MTP-76-LIVE-EXECUTION-CONTROL-VALIDATION` anchors。
- `Sources/ExecutionClient/FutureGate/LiveExecutionControlContract.swift` 必须定义 `LiveSubmitCancelReplaceFutureGate`、`LiveSubmitCancelReplaceForbiddenCapability` 和 `LiveSubmitCancelReplaceCommandBoundary`。
- `LiveSubmitCancelReplaceCommandBoundary` 必须固定 submit / cancel / replace command taxonomy subset、future gates、forbidden capability list、validation anchors、source anchors 和 paper intent isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、command taxonomy drift rejection、真实 submit / cancel / replace rejection、signed submit / cancel / replace request rejection、broker / `LiveExecutionAdapter` / real order state machine / OMS / order form / trading button bypass rejection，以及 `PaperOrderIntent` / `PaperExecutionDecision` / `PaperSimulatedFillEvidence` 不可升级为 real submit / cancel / replace。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-76 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-76 只定义 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report、broker fill、reconciliation、incident fallback automation、live command、order-level command UI、order form 或交易按钮。

MTP-76 必须建立的主要 anchors：

- `MTP-76-SUBMIT-CANCEL-REPLACE-FUTURE-GATES`
- `MTP-76-FORBIDDEN-SUBMIT-CANCEL-REPLACE-CAPABILITY-TESTS`
- `MTP-76-NO-REAL-SUBMIT-CANCEL-REPLACE`
- `MTP-76-PAPER-INTENT-NO-REAL-COMMAND-UPGRADE`
- `MTP-76-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-76 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed submit / cancel / replace request。
- 不实现 broker submit / cancel / replace action。
- 不新增交易按钮、order form、live command 或 order-level command UI。
- 不把 paper order intent、paper execution decision 或 simulated fill 升级为 real submit / cancel / replace。

## MTP-77 Execution Report / Broker Fill / Reconciliation Future Gates Validation

日期：2026-05-22

执行者：Codex

MTP-77 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES`、`MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS`、`MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT`、`MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY` 和 `MTP-77-LIVE-EXECUTION-CONTROL-VALIDATION` anchors。
- `Sources/ExecutionClient/FutureGate/LiveExecutionControlContract.swift` 必须定义 `LiveExecutionReportBrokerFillReconciliationFutureGate`、`LiveExecutionReportBrokerFillReconciliationForbiddenCapability` 和 `LiveExecutionReportBrokerFillReconciliationBoundary`。
- `LiveExecutionReportBrokerFillReconciliationBoundary` 必须固定 execution report / broker fill / reconciliation terms、future gates、forbidden capability list、validation anchors、source anchors、blocked evidence flags 和 simulated fill / paper portfolio isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、terms drift rejection、execution report consumption / parser / ingestion rejection、broker fill recorder / event fact rejection、reconciliation runtime rejection、real account balance read rejection、broker position sync rejection、broker / `LiveExecutionAdapter` bypass rejection，以及 `PaperSimulatedFillEvidence` / `PaperPortfolioProjectionUpdate` 不可升级为 broker fill、execution report、real account 或 broker position。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-77 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-77 只定义 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report parser、execution report ingestion、broker fill recorder、broker fill event fact、reconciliation service、account sync、real account balance read、broker position sync、live command、order-level command UI、order form 或交易按钮。

MTP-77 必须建立的主要 anchors：

- `MTP-77-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-FUTURE-GATES`
- `MTP-77-FORBIDDEN-REPORT-FILL-RECONCILIATION-CAPABILITY-TESTS`
- `MTP-77-SIMULATED-FILL-NO-BROKER-FILL-OR-EXECUTION-REPORT`
- `MTP-77-RECONCILIATION-BLOCKED-EVIDENCE-ONLY`
- `MTP-77-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-77 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不新增交易按钮、order form、live command 或 order-level command UI。
- 不把 simulated fill 升级为 broker fill 或 execution report。
- 不把 paper portfolio projection 升级为 broker position 或 real account state。

## MTP-78 Paper / Real Command Isolation Contract Validation

日期：2026-05-22

执行者：Codex

MTP-78 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT`、`MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`、`MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY`、`MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY` 和 `MTP-78-LIVE-EXECUTION-CONTROL-VALIDATION` anchors。
- `Sources/ExecutionClient/FutureGate/LiveExecutionControlContract.swift` 必须定义 `LivePaperRealCommandIsolationEvidenceSource`、`LivePaperRealCommandIsolationForbiddenCapability` 和 `LivePaperRealCommandIsolationBoundary`。
- `LivePaperRealCommandIsolationBoundary` 必须固定 paper order intent、paper execution decision、simulated fill evidence、paper portfolio projection、Report read model、Dashboard ViewModel 和 Event Timeline read model 的隔离证据来源。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、evidence source drift rejection、paper order intent / paper execution decision / simulated fill / paper portfolio projection upgrade rejection、real command / submit / execution report / broker fill / reconciliation bypass rejection，以及 paper-only fixture 不可升级为 future real order command。
- App tests 必须覆盖 `ReportViewModel`、`DashboardShellSnapshot` 和 `PaperWorkflowEvidenceExplorerViewModel` 仍只消费 read model / ViewModel，并且没有 command surface、order-level command、order form、trading button、broker action 或真实交易授权。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-78 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-78 只定义 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、account sync、real account balance read、broker position sync、live command、order-level command UI、order form 或交易按钮。

MTP-78 必须建立的主要 anchors：

- `MTP-78-PAPER-REAL-COMMAND-ISOLATION-CONTRACT`
- `MTP-78-PAPER-EVIDENCE-NO-REAL-COMMAND-UPGRADE`
- `MTP-78-PAPER-PROJECTION-READ-MODEL-ONLY`
- `MTP-78-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY`
- `MTP-78-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-78 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed command request。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不新增交易按钮、order form、live command 或 order-level command UI。
- 不把 paper order intent、paper execution decision、simulated fill 或 paper portfolio projection 升级为 real order command、execution report、broker fill、broker position 或 real account state。

## MTP-79 Live Execution Control Blocked Evidence Validation

日期：2026-05-22

执行者：Codex

MTP-79 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`、`MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS`、`MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`、`MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-79-LIVE-EXECUTION-CONTROL-VALIDATION` anchors。
- `Sources/ExecutionClient/FutureGate/LiveExecutionControlContract.swift` 必须定义 `LiveExecutionControlBlockedGate`、`LiveExecutionControlBlockedReason`、`LiveExecutionControlBlockedEvidenceItem` 和 `LiveExecutionControlBlockedEvidence`。
- `LiveExecutionControlBlockedEvidence` 必须固定 submit / cancel / replace / execution report / broker fill / reconciliation / incident fallback 的 blocked reason、source anchors、validation anchors 和 deterministic snapshot。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、blocked item drift rejection、schema / adapter / runtime / command bypass rejection、真实订单 / execution report / broker fill / reconciliation / incident fallback bypass rejection，以及 MTP-76 / MTP-77 / MTP-78 boundary regression。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-79 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-79 只定义 read-model-only blocked evidence 和 validation anchor 名称 / 入口，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation、account sync、real account balance read、broker position sync、live command、order-level command UI、order form 或交易按钮。

MTP-79 必须建立的主要 anchors：

- `MTP-79-LIVE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`
- `MTP-79-EXECUTION-CONTROL-GATES-BLOCKED-REASONS`
- `MTP-79-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`
- `MTP-79-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-79-LIVE-EXECUTION-CONTROL-VALIDATION`

## MTP-79 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed command request。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不实现 incident fallback automation 或 incident command。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter 或 runtime control。
- 不新增交易按钮、order form、live command 或 order-level command UI。

## MTP-80 Dashboard / Report / Event Timeline Execution-Control Blocked Evidence Validation

日期：2026-05-22

执行者：Codex

MTP-80 的 required validation：

- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-80-DASHBOARD-REPORT-TIMELINE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`、`MTP-80-EXECUTION-CONTROL-READ-MODEL-ONLY-SURFACE`、`MTP-80-NO-LIVE-COMMAND-OR-ORDER-FORM` 和 `MTP-80-LIVE-EXECUTION-CONTROL-DASHBOARD-REPORT-TIMELINE-VALIDATION` anchors。
- `Sources/Dashboard/Report/LiveExecutionControlBlockedEvidence.swift` 必须把 MTP-79 Core blocked evidence 复制成 App 层 read model / ViewModel，不读取 secret、schema、adapter 或 Runtime object。
- `ReportViewModel` 必须展示 execution-control blocked gate count、blocked gate labels、blocked reason labels、source anchors、deterministic snapshot、all-gates-blocked evidence 和 read-model-only boundary flags。
- `DashboardShellSnapshot` 必须展示 `Execution control` report metric、`liveExecutionControlGates=7` smoke evidence 和 `Live Execution Control` workbench detail group。
- `PaperWorkflowEvidenceExplorerViewModel` 必须新增 `live execution control blocked evidence` section，为 submit、cancel、replace、execution report、broker fill、reconciliation 和 incident fallback 生成只读 timeline item / evidence link。
- App tests 必须覆盖 MTP-80 ViewModel deterministic snapshot、Event Timeline preview、Dashboard Shell Report / Workbench binding、Codable round trip，以及 MTP-78 read-model-only regression。
- `docs/validation/trading-validation-matrix.md` 必须继续把 MTP-80 回填到 `TVM-LIVE-EXECUTION-CONTROL` candidate entry。
- MTP-80 只接入 Dashboard / Report / Event Timeline 展示面，不修改 `checks/automation-readiness.sh` 做最终机械收口；automation readiness 实际收口保留给 Issue 7。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real order state machine、OMS、submit / cancel / replace、execution report ingestion、broker fill event fact、reconciliation runtime、incident fallback automation、account sync、real account balance read、broker position sync、live command、order-level command UI、order form 或交易按钮。

MTP-80 必须建立的主要 anchors：

- `MTP-80-DASHBOARD-REPORT-TIMELINE-EXECUTION-CONTROL-BLOCKED-EVIDENCE`
- `MTP-80-EXECUTION-CONTROL-READ-MODEL-ONLY-SURFACE`
- `MTP-80-NO-LIVE-COMMAND-OR-ORDER-FORM`
- `MTP-80-LIVE-EXECUTION-CONTROL-DASHBOARD-REPORT-TIMELINE-VALIDATION`

## MTP-80 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed command request。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不实现 incident fallback automation 或 incident command。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter 或 runtime control。
- 不新增交易按钮、order form、live command 或 order-level command UI。

## MTP-81 Validation Docs / Stage Audit Input Validation

日期：2026-05-22

执行者：Codex

MTP-81 的 required validation：

- `docs/validation/latest-verification-summary.md` 必须更新为 MTP-81 当前验证摘要，并引用 MTP-75 至 MTP-80 的 Project evidence。
- `docs/contracts/live-execution-control-contract.md` 必须包含 `MTP-81-LIVE-EXECUTION-CONTROL-STAGE-CLOSEOUT`、`MTP-81-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-81-NO-FINAL-STAGE-CODE-AUDIT` 和 `MTP-81-LIVE-EXECUTION-CONTROL-VALIDATION-EVIDENCE-CHAIN` anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-81 Live Execution Control Contract 阶段收口说明，并指向 MTP-81 Stage Code Audit 输入材料。
- `docs/audit/inputs/mtpro-live-execution-control-contract-v1-stage-audit-input.md` 必须存在，并包含 Issue / PR evidence、Live execution control validation evidence chain、Dashboard smoke、Forbidden capability evidence、Read-model-only boundary evidence、Automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `checks/automation-readiness.sh` 必须机械检查 MTP-75 至 MTP-81 的 contract、matrix、validation plan、latest summary、source / test anchors、Dashboard smoke evidence 和 stage audit input material。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在有效 issue 全部 Done 且 Linear Project `Completed`、`type=completed`、`completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`。

MTP-81 必须收口的主要 anchors：

- `MTP-81-LIVE-EXECUTION-CONTROL-STAGE-CLOSEOUT`
- `MTP-81-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-81-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-81-LIVE-EXECUTION-CONTROL-STAGE-AUDIT-INPUT`
- `MTP-81-LIVE-EXECUTION-CONTROL-VALIDATION-EVIDENCE-CHAIN`
- `MTP-81-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-81 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project 或下一 Project issues。
- 不推进下一 Project / Issue。
- 不把 planning notes 当执行授权。
- 不启动下一阶段 `symphony-issue`。
- 不写业务功能扩展。
- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不实现 real order state machine / OMS。
- 不提交、撤销、替换真实订单。
- 不发送 signed command request。
- 不消费、解析或 ingest execution report。
- 不记录 broker fill，不写 broker fill event fact。
- 不实现 reconciliation service / runtime。
- 不实现 incident fallback automation 或 incident command。
- 不读取真实账户余额，不执行 account sync，不执行 broker position sync。
- 不暴露 persistence schema、adapter 或 runtime control。
- 不新增交易按钮、order form、live command 或 order-level command UI。

## MTP-82 Live Risk Terminology / Future Risk Decision Taxonomy Validation

日期：2026-05-22

执行者：Codex

MTP-82 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-82-LIVE-RISK-TERMINOLOGY`、`MTP-82-FUTURE-RISK-DECISION-TAXONOMY`、`MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`、`MTP-82-NO-LIVE-RISK-RUNTIME` 和 `MTP-82-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveRiskGateContract.swift` 必须定义 `LiveRiskTerm`、`FutureRiskDecisionTaxonomyTerm`、`LiveRiskGateFutureGate`、`LiveRiskForbiddenCapability`、`LiveRiskEvidenceKind` 和 `LiveRiskTerminologyBoundary`。
- `LiveRiskTerminologyBoundary` 必须固定 live pre-trade risk terminology、future risk decision taxonomy、future gates、forbidden capability list、validation anchors 和 paper / live risk isolation source anchors。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、taxonomy drift rejection、真实账户 / broker position / margin / leverage 读取 rejection、real pre-trade allow / reject runtime rejection、signed endpoint / `LiveExecutionAdapter` bypass rejection、risk command / trading button rejection，以及 `RiskBlockerEvidence` / `PortfolioExposureSnapshot` 不可升级为 future live risk decision、real account state 或 broker position。
- `docs/validation/trading-validation-matrix.md` 必须新增 `TVM-LIVE-RISK-GATE` candidate entry，并把 MTP-82 回填到该 entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-82 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real pre-trade risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade state runtime、live command、risk command、position management command、order form 或交易按钮。

MTP-82 必须建立的主要 anchors：

- `MTP-82-LIVE-RISK-TERMINOLOGY`
- `MTP-82-FUTURE-RISK-DECISION-TAXONOMY`
- `MTP-82-PAPER-RISK-LIVE-RISK-SEPARATION`
- `MTP-82-NO-LIVE-RISK-RUNTIME`
- `MTP-82-LIVE-RISK-GATE-VALIDATION`

## MTP-82 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 circuit breaker runtime 或 no-trade state runtime。
- 不新增 live command、risk command、position management command、order form 或交易按钮。
- 不把 paper risk blocker、paper exposure、paper execution decision 或 simulated fill 升级为 future live risk decision、real account state、broker position 或 live risk input。

## MTP-83 Exposure / Order Notional Gates Validation

日期：2026-05-22

执行者：Codex

MTP-83 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`、`MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS`、`MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT`、`MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE` 和 `MTP-83-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveRiskGateContract.swift` 必须定义 `LiveExposureOrderNotionalFutureGate`、`LiveExposureOrderNotionalForbiddenCapability` 和 `LiveExposureOrderNotionalGateBoundary`。
- `LiveExposureOrderNotionalGateBoundary` 必须固定 exposure / order notional future gates、forbidden capability list、validation anchors、source anchors 和 paper exposure isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、terms drift rejection、真实账户余额 / broker position / margin / leverage 读取 rejection、real account exposure calculation rejection、real order notional limit evaluation rejection、real pre-trade allow / reject runtime rejection、account endpoint decode bypass rejection，以及 `PortfolioExposureSnapshot` 不可升级为 future live exposure gate、real account state 或 broker position。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-83 回填到 `TVM-LIVE-RISK-GATE` candidate entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-83 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real account exposure calculation、real order notional allow / reject runtime、real pre-trade risk engine、live command、risk command、position management command、order form 或交易按钮。

MTP-83 必须建立的主要 anchors：

- `MTP-83-EXPOSURE-ORDER-NOTIONAL-FUTURE-GATES`
- `MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS`
- `MTP-83-NO-REAL-PRE-TRADE-ALLOW-REJECT`
- `MTP-83-PAPER-EXPOSURE-NO-LIVE-EXPOSURE-UPGRADE`
- `MTP-83-LIVE-RISK-GATE-VALIDATION`

## MTP-83 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不计算真实账户 exposure。
- 不执行真实订单 notional allow / reject。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不新增 live command、risk command、position management command、order form 或交易按钮。
- 不把 paper exposure 或 paper risk blocker 升级为 future live exposure gate、future live risk decision、real account state、broker position、margin 或 leverage。

## MTP-84 Frequency / Loss / Drawdown Gates Validation

日期：2026-05-22

执行者：Codex

MTP-84 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES`、`MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS`、`MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT`、`MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE` 和 `MTP-84-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveRiskGateContract.swift` 必须定义 `LiveFrequencyLossDrawdownFutureGate`、`LiveFrequencyLossDrawdownForbiddenCapability` 和 `LiveFrequencyLossDrawdownGateBoundary`。
- `LiveFrequencyLossDrawdownGateBoundary` 必须固定 frequency / loss / drawdown future gates、forbidden capability list、validation anchors、source anchors、frequency runtime flags、loss / drawdown runtime flags 和 paper risk / exposure isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、terms drift rejection、真实下单频率计数 rejection、production frequency throttling rejection、真实 PnL / equity 读取 rejection、real loss / drawdown limit evaluation rejection、drawdown circuit breaker rejection、stop / emergency command rejection，以及 `RiskBlockerEvidence` / `PortfolioExposureSnapshot` 不可升级为 future live frequency / loss / drawdown gate、真实 PnL / equity 或 pre-trade runtime。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-84 回填到 `TVM-LIVE-RISK-GATE` candidate entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-84 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real PnL read、real account equity read、live order frequency counter、production frequency throttling、real loss / drawdown allow / reject runtime、drawdown circuit breaker runtime、circuit breaker command、stop trading command、emergency stop command、live command、risk command、position management command、order form 或交易按钮。

MTP-84 必须建立的主要 anchors：

- `MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES`
- `MTP-84-FORBIDDEN-FREQUENCY-LOSS-DRAWDOWN-RUNTIME-TESTS`
- `MTP-84-NO-REAL-PNL-EQUITY-OR-DRAWDOWN-ENFORCEMENT`
- `MTP-84-PAPER-RISK-EXPOSURE-NO-LIVE-RISK-UPGRADE`
- `MTP-84-LIVE-RISK-GATE-VALIDATION`

## MTP-84 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不读取真实 PnL 或真实账户权益。
- 不统计真实下单频率。
- 不执行生产限频或 broker-side throttling。
- 不执行真实亏损阈值或回撤阈值 allow / reject。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 drawdown circuit breaker runtime。
- 不实现 circuit breaker command、stop trading command 或 emergency stop command。
- 不新增 live command、risk command、position management command、order form 或交易按钮。
- 不把 paper risk blocker 或 paper exposure 升级为 future frequency / loss / drawdown gate、future live risk decision、real PnL、real account equity 或 pre-trade runtime。

## MTP-85 Circuit Breaker / No-Trade State Gates Validation

日期：2026-05-22

执行者：Codex

MTP-85 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`、`MTP-85-FORBIDDEN-CIRCUIT-BREAKER-NO-TRADE-RUNTIME-TESTS`、`MTP-85-NO-CIRCUIT-BREAKER-OR-NO-TRADE-STATE-RUNTIME`、`MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE` 和 `MTP-85-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveRiskGateContract.swift` 必须定义 `LiveCircuitBreakerNoTradeFutureGate`、`LiveCircuitBreakerNoTradeForbiddenCapability` 和 `LiveCircuitBreakerNoTradeGateBoundary`。
- `LiveCircuitBreakerNoTradeGateBoundary` 必须固定 circuit breaker / no-trade state future gates、forbidden capability list、validation anchors、source anchors、circuit breaker runtime flags、no-trade state runtime flags、operations command flags 和 paper risk / exposure isolation flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、terms drift rejection、circuit breaker runtime rejection、no-trade state runtime rejection、global trading lock rejection、broker session state mutation rejection、stop / emergency / recovery / production shutdown command rejection，以及 `RiskBlockerEvidence` / `PortfolioExposureSnapshot` 不可升级为 future live circuit breaker / no-trade state gate、真实账户状态、真实 PnL / equity 或 pre-trade runtime。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-85 回填到 `TVM-LIVE-RISK-GATE` candidate entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-85 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real PnL read、real account equity read、real loss / drawdown allow / reject runtime、circuit breaker runtime、no-trade state runtime、global trading lock、broker session state mutation、circuit breaker command、stop trading command、emergency stop command、automatic recovery command、production shutdown control、live command、risk command、position management command、order form 或交易按钮。

MTP-85 必须建立的主要 anchors：

- `MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES`
- `MTP-85-FORBIDDEN-CIRCUIT-BREAKER-NO-TRADE-RUNTIME-TESTS`
- `MTP-85-NO-CIRCUIT-BREAKER-OR-NO-TRADE-STATE-RUNTIME`
- `MTP-85-PAPER-RISK-EXPOSURE-NO-CIRCUIT-BREAKER-UPGRADE`
- `MTP-85-LIVE-RISK-GATE-VALIDATION`

## MTP-85 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不读取真实 PnL 或真实账户权益。
- 不执行真实亏损阈值或回撤阈值 allow / reject。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 circuit breaker runtime。
- 不实现 no-trade state runtime 或 no-trade state transition runtime。
- 不实现 global trading lock 或 broker session state mutation。
- 不实现 circuit breaker command、stop trading command、emergency stop command、automatic recovery command 或 production shutdown control。
- 不提交、撤销、替换真实订单。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 paper risk blocker 或 paper exposure 升级为 future circuit breaker / no-trade state gate、future live risk decision、real PnL、real account equity、真实账户状态或 pre-trade runtime。

## MTP-86 Paper Risk / Future Live Risk Decision Isolation Validation

日期：2026-05-22

执行者：Codex

MTP-86 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT`、`MTP-86-PAPER-RISK-EVIDENCE-NO-FUTURE-LIVE-RISK-DECISION`、`MTP-86-PAPER-EXPOSURE-NO-REAL-ACCOUNT-RISK-INPUT`、`MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY` 和 `MTP-86-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveRiskGateContract.swift` 必须定义 `LivePaperRiskLiveDecisionIsolationEvidenceSource`、`LivePaperRiskLiveDecisionForbiddenCapability` 和 `LivePaperRiskLiveDecisionIsolationBoundary`。
- `LivePaperRiskLiveDecisionIsolationBoundary` 必须固定 paper-only evidence sources、forbidden capability list、validation anchors、source anchors、paper risk / exposure no-upgrade flags、future live risk decision blocked flags 和 read-model-only App surface flags。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、evidence source drift rejection、paper risk blocker -> future risk decision rejection、paper exposure -> future risk decision rejection、paper risk decision -> real pre-trade allow / reject rejection、paper exposure -> real account exposure rejection、live risk engine rejection、signed endpoint / account endpoint / `LiveExecutionAdapter` rejection、risk command surface rejection，以及 `RiskBlockerEvidence` / `PortfolioExposureSnapshot` 不可升级为 future live risk decision、真实账户风险输入、circuit breaker trigger 或 no-trade state trigger。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-86 回填到 `TVM-LIVE-RISK-GATE` candidate entry。
- `checks/automation-readiness.sh` 必须机械检查 MTP-86 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-88 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不读取真实 API key，不新增 secret config，不实现 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter、`LiveExecutionAdapter`、real account balance read、broker position sync、margin / leverage、real PnL / equity read、real pre-trade risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade state runtime、live command、risk command、position management command、order form 或交易按钮。

MTP-86 必须建立的主要 anchors：

- `MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT`
- `MTP-86-PAPER-RISK-EVIDENCE-NO-FUTURE-LIVE-RISK-DECISION`
- `MTP-86-PAPER-EXPOSURE-NO-REAL-ACCOUNT-RISK-INPUT`
- `MTP-86-REPORT-DASHBOARD-TIMELINE-READ-MODEL-ONLY`
- `MTP-86-LIVE-RISK-GATE-VALIDATION`

## MTP-86 禁止

- 不实现 API key / secret storage。
- 不实现 signed endpoint / account endpoint / listenKey。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`。
- 不读取真实账户余额。
- 不执行 broker position sync。
- 不读取 margin / leverage。
- 不读取真实 PnL 或真实账户权益。
- 不实现 real pre-trade risk engine。
- 不实现 real pre-trade allow / reject runtime。
- 不实现 circuit breaker runtime。
- 不实现 no-trade state runtime。
- 不提交、撤销、替换真实订单。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不把 paper risk blocker、paper exposure 或 paper risk decision 升级为 future live risk decision、real account exposure、broker position、real pre-trade allow / reject、circuit breaker trigger、no-trade state trigger 或 live risk runtime input。

## MTP-87 Live Risk Gate Blocked Evidence Surface Validation

日期：2026-05-22

执行者：Codex

MTP-87 的 required validation：

- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE`、`MTP-87-LIVE-RISK-GATES-BLOCKED-REASONS`、`MTP-87-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`、`MTP-87-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-87-LIVE-RISK-GATE-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveRiskGateContract.swift` 必须定义 `LiveRiskGateBlockedGate`、`LiveRiskGateBlockedReason`、`LiveRiskGateBlockedEvidenceItem` 和 `LiveRiskGateBlockedEvidence`。
- `LiveRiskGateBlockedEvidence` 必须固定 exposure、order notional、frequency、loss / drawdown、circuit breaker、no-trade state 的 blocked reason、source anchors、validation anchors、deterministic snapshot、read-model-only App surface flags 和 forbidden live risk runtime flags。
- `Sources/Dashboard/Report/LiveRiskGateBlockedEvidence.swift` 必须把 Core fixture 复制成 `LiveRiskGateBlockedEvidenceReadModel` / `LiveRiskGateBlockedEvidenceViewModel`，并只通过 `ReportViewModel`、`DashboardShellSnapshot` 和 `PaperWorkflowEvidenceExplorerViewModel` 进入只读展示面。
- Core tests 必须覆盖 deterministic fixture、Codable round trip、blocked items drift rejection、真实账户 / broker position / allow-reject runtime / circuit breaker runtime / command surface rejection，以及 MTP-83 至 MTP-86 boundary regression。
- App tests 必须覆盖 Dashboard / Report / Event Timeline blocked evidence、ViewModel Codable boundary、`liveRiskGates=6` smoke anchor、无 risk command、无 order form、无交易按钮、无 schema / adapter / Runtime object 暴露。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-87 回填到 `TVM-LIVE-RISK-GATE` candidate entry；MTP-88 仍负责 Project 级 automation readiness 和 stage audit input material 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增真实网络 smoke，不读取真实账户，不实现 live risk runtime。

MTP-87 必须建立的主要 anchors：

- `MTP-87-LIVE-RISK-GATE-BLOCKED-EVIDENCE`
- `MTP-87-LIVE-RISK-GATES-BLOCKED-REASONS`
- `MTP-87-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`
- `MTP-87-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-87-LIVE-RISK-GATE-VALIDATION`

## MTP-87 禁止

- 不读取真实账户余额、broker position、margin、leverage、PnL 或 equity。
- 不实现 real pre-trade risk engine、real pre-trade allow / reject runtime、真实 order notional evaluation 或真实 frequency / loss / drawdown runtime。
- 不实现 circuit breaker runtime、no-trade state runtime、broker session state mutation、stop trading command 或 emergency stop command。
- 不新增 live command、risk command surface、position management command、order form 或交易按钮。
- 不让 UI 消费 database schema、adapter、Runtime object 或 command model。

## MTP-88 Validation Docs / Stage Audit Input Validation

日期：2026-05-22

执行者：Codex

MTP-88 的 required validation：

- `docs/audit/inputs/mtpro-live-risk-gate-contract-v1-stage-audit-input.md` 必须存在，并包含 `MTP-88-LIVE-RISK-GATE-STAGE-AUDIT-INPUT`、Issue / PR evidence input、Live risk gate validation evidence chain、Forbidden capability evidence、Read-model-only boundary evidence、Automation readiness evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/contracts/live-risk-gate-contract.md` 必须包含 `MTP-88-LIVE-RISK-GATE-STAGE-CLOSEOUT`、`MTP-88-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-88-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-88-LIVE-RISK-GATE-VALIDATION-EVIDENCE-CHAIN` 和 `MTP-88-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-88 Live Risk Gate Contract 阶段收口说明，并指向 MTP-88 Stage Code Audit 输入材料。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-88 只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口，不输出最终 Stage Code Audit Report。
- `checks/automation-readiness.sh` 必须机械检查 MTP-82 至 MTP-88 的 contract、matrix、validation plan、latest summary、stage audit input、Core / App source anchors、Core / App deterministic test anchors 和 Dashboard smoke `liveRiskGates=6`。
- Stage Code Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在 `MTP-82` 至 `MTP-88` 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现真实 live risk runtime、真实账户读取、broker position sync、margin / leverage / PnL / equity read、circuit breaker command、stop trading command、emergency stop、risk command、order form 或交易按钮。

MTP-88 必须建立的主要 anchors：

- `MTP-88-LIVE-RISK-GATE-STAGE-CLOSEOUT`
- `MTP-88-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-88-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-88-LIVE-RISK-GATE-STAGE-AUDIT-INPUT`
- `MTP-88-LIVE-RISK-GATE-VALIDATION-EVIDENCE-CHAIN`
- `MTP-88-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-88 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不读取 API key、secret、真实账户余额、broker position、margin、leverage、PnL 或 equity。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 real pre-trade risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade state runtime、risk command surface、position management command、order form、交易按钮、stop trading command 或 emergency stop。

## MTP-89 Live Audit Incident Stop Terminology / Taxonomy Validation

日期：2026-05-23

执行者：Codex

MTP-89 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`、`MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`、`MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES`、`MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND`、`MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE` 和 `MTP-89-LIVE-AUDIT-INCIDENT-STOP-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveAuditIncidentStopContract.swift` 必须只定义 `LiveAuditIncidentStopTerm`、`FutureAuditIncidentStopTaxonomyTerm`、`LiveAuditIncidentStopFutureGate`、`LiveAuditIncidentStopForbiddenCapability`、`LiveAuditIncidentStopEvidenceKind` 和 `LiveAuditIncidentStopTerminologyBoundary`。
- Core deterministic tests 必须覆盖 `testLiveAuditIncidentStopTerminologyDefinesMTP89FutureOnlyTaxonomy`、`testLiveAuditIncidentStopTerminologyRejectsMTP89RuntimeCommandAndConsoleBypass` 和 `testLiveAuditIncidentStopTerminologyKeepsMTP89BlockedEvidenceFutureOnly`。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-AUDIT-INCIDENT-STOP` 和 MTP-89 issue backfill。
- `docs/domain/context.md` 必须包含 Live Audit Incident Stop Terms 和 MTP-89 anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-89 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-89 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、signed endpoint、account endpoint、listenKey、broker action、live command、order form 或交易按钮。

MTP-89 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-89-LIVE-AUDIT-INCIDENT-STOP-TERMINOLOGY`
- `MTP-89-FUTURE-AUDIT-INCIDENT-STOP-TAXONOMY`
- `MTP-89-BLOCKED-EVIDENCE-ONLY-FUTURE-GATES`
- `MTP-89-NO-INCIDENT-REPLAY-OR-STOP-COMMAND`
- `MTP-89-NO-LIVE-PRO-CONSOLE-SURFACE`
- `MTP-89-LIVE-AUDIT-INCIDENT-STOP-VALIDATION`

## MTP-89 禁止

- 不实现 incident replay runtime。
- 不实现 emergency stop、shutdown、restore 或 stop control runtime。
- 不实现 production operations、alerting / paging、auto recovery 或 broker session mutation。
- 不把 Workbench、Dashboard、Report、Event Timeline 或 Evidence Explorer 描述成当前 Live PRO Console。
- 不接 API key、secret storage、signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order state machine、real order submit / cancel / replace、execution report runtime、broker fill runtime 或 reconciliation runtime。
- 不新增 live command、order-level command UI、order form、交易按钮、broker action 或真实交易授权。

## MTP-90 Live Audit Trail Future Gates Validation

日期：2026-05-23

执行者：Codex

MTP-90 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`、`MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS`、`MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION`、`MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE` 和 `MTP-90-LIVE-AUDIT-TRAIL-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveAuditIncidentStopContract.swift` 必须定义 `LiveAuditTrailSubject`、`LiveAuditTrailFutureGate`、`LiveAuditTrailForbiddenCapability` 和 `LiveAuditTrailFutureGateBoundary`，并保持这些类型只表达 Future / gated audit trail contract。
- Core deterministic tests 必须覆盖 `testMTP90LiveAuditTrailFutureGatesDefineSignalOrderRiskDecisionFillBoundary`、`testMTP90LiveAuditTrailFutureGatesRejectExecutionReportBrokerFillOMSAndBrokerAction` 和 `testMTP90LiveAuditTrailFutureGatesKeepPaperEvidenceFromBecomingRealAuditFact`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-90 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-90 audit trail future gates、forbidden execution report / broker fill / OMS tests、no real order state machine / broker action、paper evidence no real audit fact upgrade 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-90 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-90 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现真实 audit trail runtime、execution report parser / ingestion、broker fill recorder、OMS、real order state machine、broker reconciliation、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、live command、order form 或交易按钮。

MTP-90 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-90-SIGNAL-ORDER-RISK-FILL-AUDIT-TRAIL-FUTURE-GATES`
- `MTP-90-FORBIDDEN-EXECUTION-REPORT-BROKER-FILL-OMS-TESTS`
- `MTP-90-NO-REAL-ORDER-STATE-MACHINE-OR-BROKER-ACTION`
- `MTP-90-PAPER-EVIDENCE-NO-REAL-AUDIT-FACT-UPGRADE`
- `MTP-90-LIVE-AUDIT-TRAIL-VALIDATION`

## MTP-90 禁止

- 不实现真实 audit trail runtime。
- 不实现 execution report parser / ingestion、execution report runtime 或 broker fill recorder。
- 不记录 broker fill fact，不执行 broker reconciliation。
- 不实现 OMS、real order state machine 或 real order submit / cancel / replace。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不把 strategy signal、`PaperOrderIntent`、`PaperExecutionDecision`、`RiskBlockerEvidence` 或 `PaperSimulatedFillEvidence` 升级为真实 audit fact。
- 不新增 live command、order-level command UI、order form、交易按钮或真实交易授权。

## MTP-91 Incident Replay Future Gates Validation

日期：2026-05-23

执行者：Codex

MTP-91 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-91-INCIDENT-REPLAY-FUTURE-GATES`、`MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES`、`MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES`、`MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS`、`MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY` 和 `MTP-91-INCIDENT-REPLAY-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveAuditIncidentStopContract.swift` 必须定义 `LiveIncidentReplayFutureGate`、`LiveIncidentReplayForbiddenCapability` 和 `LiveIncidentReplayFutureGateBoundary`，并保持这些类型只表达 Future / gated incident replay contract。
- Core deterministic tests 必须覆盖 `testMTP91IncidentReplayFutureGatesDefineInputScopeEvidenceOutputBoundary`、`testMTP91IncidentReplayFutureGatesRejectRuntimeRecoveryBrokerAndAccountReplay` 和 `testMTP91IncidentReplayFutureGatesKeepCurrentReplayDeterministicEvidenceOnly`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-91 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-91 incident replay future gates、input source gates、scope / evidence / output gates、forbidden recovery / broker / account replay tests、deterministic replay no production recovery 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-91 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-91 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 incident replay runtime、production recovery、auto restore、auto rollback、broker replay、account replay、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、Live PRO Console、live command、order form 或交易按钮。

MTP-91 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-91-INCIDENT-REPLAY-FUTURE-GATES`
- `MTP-91-INCIDENT-REPLAY-INPUT-SOURCE-GATES`
- `MTP-91-REPLAY-SCOPE-EVIDENCE-OUTPUT-GATES`
- `MTP-91-FORBIDDEN-RECOVERY-BROKER-ACCOUNT-REPLAY-TESTS`
- `MTP-91-DETERMINISTIC-REPLAY-NO-PRODUCTION-RECOVERY`
- `MTP-91-INCIDENT-REPLAY-VALIDATION`

## MTP-91 禁止

- 不实现 incident replay runtime。
- 不实现 production recovery、auto restore、auto rollback 或 live runtime resume。
- 不实现 broker replay runtime、account replay runtime、broker state reader 或 real account state reader。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不实现 OMS、real order state machine、execution report ingestion、broker fill fact 或 audit trail runtime。
- 不把当前 `Event Log` / `Replay` 升级为 production incident replay、production recovery、broker replay 或 account replay。
- 不新增 Live PRO Console、live command、order-level command UI、order form、交易按钮或真实交易授权。

## MTP-92 Stop / Shutdown / Restore Future Gates Validation

日期：2026-05-23

执行者：Codex

MTP-92 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES`、`MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS`、`MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE`、`MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN` 和 `MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveAuditIncidentStopContract.swift` 必须包含 `LiveStopShutdownRestoreFutureGate`、`LiveStopShutdownRestoreForbiddenCapability` 和 `LiveStopShutdownRestoreFutureGateBoundary`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-92 focused tests，验证 no emergency stop、no shutdown、no restore command、no live command、no trading button、no broker session mutation、no production operations、no signed endpoint / account endpoint / listenKey / broker action。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-92 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-92 stop / shutdown / restore future gates、forbidden capability tests、risk circuit breaker / no-trade separation、broker session mutation / production shutdown boundary 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-92 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-92 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。

MTP-92 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-92-EMERGENCY-STOP-SHUTDOWN-RESTORE-FUTURE-GATES`
- `MTP-92-FORBIDDEN-STOP-SHUTDOWN-RESTORE-CAPABILITY-TESTS`
- `MTP-92-NO-LIVE-RISK-CIRCUIT-BREAKER-OR-NO-TRADE-UPGRADE`
- `MTP-92-NO-BROKER-SESSION-MUTATION-OR-PRODUCTION-SHUTDOWN`
- `MTP-92-STOP-SHUTDOWN-RESTORE-VALIDATION`

## MTP-92 禁止

- 不实现 emergency stop command、shutdown command 或 restore command。
- 不实现 stop control runtime、production shutdown control、production operations runtime、global trading lock 或 broker session mutation。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不实现 OMS、real order state machine、live risk engine、circuit breaker runtime、no-trade state runtime、restore decision runtime 或 live runtime resume。
- 不把 `LiveCircuitBreakerNoTradeGateBoundary`、risk gate blocked evidence、circuit breaker 或 no-trade state 升级为当前 emergency stop、shutdown、restore 或 production shutdown control。
- 不新增 Live PRO Console、live command、order-level command UI、stop button、order form、交易按钮或真实交易授权。

## MTP-93 Blocked Evidence Incident / Stop Isolation Validation

日期：2026-05-23

执行者：Codex

MTP-93 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION`、`MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE`、`MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE`、`MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS` 和 `MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveAuditIncidentStopContract.swift` 必须包含 `LiveBlockedEvidenceIncidentStopIsolationGate`、`LiveBlockedEvidenceIncidentStopForbiddenCapability` 和 `LiveBlockedEvidenceIncidentStopIsolationBoundary`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-93 focused tests，验证 Live execution / risk blocked evidence 不能升级为 incident replay runtime、stop command、shutdown command、restore command、production operation、live command、trading button 或 Live PRO Console。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-93 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-93 blocked evidence isolation、no blocked evidence to incident / stop command upgrade、paper evidence no incident / stop upgrade、forbidden command / runtime tests 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-93 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-93 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 incident command、stop / shutdown / restore command、live risk engine、execution runtime、production operations、Live PRO Console、signed endpoint、account endpoint、listenKey、broker action、live command、order form 或交易按钮。

MTP-93 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-93-LIVE-RISK-EXECUTION-BLOCKED-EVIDENCE-ISOLATION`
- `MTP-93-NO-BLOCKED-EVIDENCE-TO-INCIDENT-OR-STOP-COMMAND-UPGRADE`
- `MTP-93-PAPER-EVIDENCE-NO-INCIDENT-STOP-UPGRADE`
- `MTP-93-FORBIDDEN-COMMAND-RUNTIME-UPGRADE-TESTS`
- `MTP-93-BLOCKED-EVIDENCE-ISOLATION-VALIDATION`

## MTP-93 禁止

- 不把 `LiveExecutionControlBlockedEvidence` 升级为 incident command、stop command、restore decision、execution runtime、live command 或交易按钮。
- 不把 `LiveRiskGateBlockedEvidence` 升级为 incident replay runtime、emergency stop、shutdown command、live risk engine、risk command、stop command 或 production operations。
- 不把 `PaperOrderIntent`、`PaperSimulatedFillEvidence`、`RiskBlockerEvidence` 或 `PortfolioExposureSnapshot` 升级为 production incident fact、stop decision、restore readiness、broker fill fact、real account state 或 future live risk decision。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不实现 OMS、real order state machine、execution runtime、live risk engine、incident replay runtime、stop command、shutdown command、restore command 或 production operations runtime。
- 不新增 Live PRO Console、live command、order-level command UI、stop button、order form、交易按钮或真实交易授权。

## MTP-94 Live Incident / Stop Blocked Evidence Validation

日期：2026-05-23

执行者：Codex

MTP-94 的 required validation：

- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-94-LIVE-INCIDENT-STOP-BLOCKED-EVIDENCE`、`MTP-94-AUDIT-INCIDENT-STOP-BLOCKED-REASONS`、`MTP-94-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`、`MTP-94-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-94-LIVE-INCIDENT-STOP-VALIDATION` anchors。
- `Sources/RiskEngine/LiveGate/LiveAuditIncidentStopContract.swift` 必须包含 `LiveIncidentStopBlockedGate`、`LiveIncidentStopBlockedReason`、`LiveIncidentStopBlockedEvidenceItem` 和 `LiveIncidentStopBlockedEvidence`。
- `Sources/Dashboard/Report/LiveIncidentStopBlockedEvidence.swift` 必须包含 `LiveIncidentStopBlockedEvidenceReadModel` 和 `LiveIncidentStopBlockedEvidenceViewModel`，并保持 Dashboard / Report / Event Timeline 只消费 read model。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-94 focused Core tests，验证 deterministic snapshot、forbidden command / runtime / console flags 和 prior future gate source anchors。
- `Tests/AppTests/AppTests.swift` 必须包含 MTP-94 focused App tests，验证 ViewModel aggregation 和 Event Timeline read-only items。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-94 issue backfill。
- `docs/domain/context.md` 必须包含 MTP-94 live incident / stop blocked evidence、blocked reasons、deterministic snapshot、read-model-only no command surface 和 validation anchors。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-94 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-94 contract、matrix、validation plan、domain context、latest summary、Core/App source、Dashboard / Event Timeline wiring 和 focused test anchors；后续 MTP-95 仍负责 Project 级 stage closeout 和完整 automation readiness 收口。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 audit trail runtime、incident replay runtime、emergency stop / shutdown / restore command、production operations、Live PRO Console、signed endpoint、account endpoint、listenKey、broker action、live command、order form、stop button 或交易按钮。

MTP-94 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-94-LIVE-INCIDENT-STOP-BLOCKED-EVIDENCE`
- `MTP-94-AUDIT-INCIDENT-STOP-BLOCKED-REASONS`
- `MTP-94-DETERMINISTIC-BLOCKED-EVIDENCE-SNAPSHOT`
- `MTP-94-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-94-LIVE-INCIDENT-STOP-VALIDATION`

## MTP-94 禁止

- 不实现 audit trail runtime、incident replay runtime、stop control runtime、emergency stop command、shutdown command 或 restore command。
- 不实现 production operations runtime、production shutdown control、broker session mutation、restore decision runtime 或 live runtime resume。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不连接 broker，不执行 broker action。
- 不实现 OMS、real order state machine、execution runtime、live risk engine、audit service、broker replay、account replay 或 production recovery。
- 不把 Dashboard、Report、Workbench、Event Timeline 或 Evidence Explorer 升级为 Live PRO Console、operator workflow、command model、adapter status、runtime status 或 database schema browser。
- 不新增 live command、order-level command UI、stop button、order form、交易按钮或真实交易授权。

## MTP-95 Validation Docs / Stage Audit Input Validation

日期：2026-05-23

执行者：Codex

MTP-95 的 required validation：

- `docs/audit/inputs/mtpro-live-audit-incident-stop-boundary-v1-stage-audit-input.md` 必须包含 `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-AUDIT-INPUT`、Linear queue evidence、Issue / PR evidence input、Live audit incident stop validation evidence chain、Forbidden capability evidence、Read-model-only boundary evidence、Automation readiness evidence、Validation evidence、Known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/contracts/live-audit-incident-stop-contract.md` 必须包含 `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-CLOSEOUT`、`MTP-95-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-95-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-95-LIVE-AUDIT-INCIDENT-STOP-VALIDATION-EVIDENCE-CHAIN` 和 `MTP-95-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-95 回填到 `TVM-LIVE-AUDIT-INCIDENT-STOP` candidate entry，并新增 Project 级 stage closeout section。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-95 只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口，不输出最终 Stage Code Audit Report。
- `checks/automation-readiness.sh` 必须机械检查 MTP-89 至 MTP-95 的 contract、matrix、validation plan、latest summary、stage audit input、Core / App source anchors、Core / App deterministic test anchors、Dashboard smoke `liveIncidentStopGates=5` 和 PR evidence chain。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 audit trail runtime、incident replay runtime、emergency stop、shutdown、restore、production operations、Live PRO Console、signed endpoint、account endpoint、listenKey、broker action、live command、stop button、order form 或交易按钮。
- 必须验证 `.codex/*` 和 `graphify-out/*` 不进入 PR。

MTP-95 必须建立的主要 anchors：

- `TVM-LIVE-AUDIT-INCIDENT-STOP`
- `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-AUDIT-INPUT`
- `MTP-95-LIVE-AUDIT-INCIDENT-STOP-STAGE-CLOSEOUT`
- `MTP-95-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-95-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-95-LIVE-AUDIT-INCIDENT-STOP-VALIDATION-EVIDENCE-CHAIN`
- `MTP-95-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-95 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不读取 API key、secret、真实账户、broker state 或 production runtime state。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 audit trail runtime、incident replay runtime、broker replay runtime、account replay runtime、production recovery runtime、stop control runtime、production operations runtime、Live PRO Console、live command、stop button、order form、交易按钮、emergency stop command、shutdown command 或 restore command。

## MTP-96 TradingClock / Paper Runtime Kernel Boundary Validation

日期：2026-05-25

执行者：Codex

MTP-96 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME`、`MTP-96-PAPER-RUNTIME-KERNEL-BOUNDARY`、`MTP-96-PAPER-ONLY-KERNEL-EVENTS`、`MTP-96-NO-UI-STATE-OR-PERSISTENCE-SCHEMA`、`MTP-96-NO-LIVE-SIGNED-BROKER-RUNTIME` 和 `MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION` anchors。
- `Sources/ExecutionEngine/PaperLifecycle/PaperRuntimeKernelBoundary.swift` 必须定义 `TradingClock`、`TradingClockTick`、`PaperRuntimeKernelBoundary`、`PaperRuntimeKernelLifecycleState`、`PaperRuntimeKernelInputKind` 和 `PaperRuntimeKernelOutputKind`，并保持这些类型只表达 Core paper-only boundary。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-96 focused tests，验证 deterministic TradingClock、paper-only kernel fixture、forbidden signed/account/listenKey/broker/LiveExecutionAdapter/OMS/live command/trading button、以及 no UI state / no persistence schema。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-PAPER-RUNTIME-KERNEL` 和 MTP-96 issue backfill。
- `docs/domain/context.md` 必须包含 `MTP-96-PAPER-RUNTIME-KERNEL-TERMS`。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-96 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-96 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 CommandBus / EventBus / MessageBus、Paper RiskEngine、paper lifecycle coordinator、simulated fill、paper account projection、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order lifecycle、live command 或交易按钮。

MTP-96 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-96-TRADING-CLOCK-DETERMINISTIC-TIME`
- `MTP-96-PAPER-RUNTIME-KERNEL-BOUNDARY`
- `MTP-96-PAPER-ONLY-KERNEL-EVENTS`
- `MTP-96-NO-UI-STATE-OR-PERSISTENCE-SCHEMA`
- `MTP-96-NO-LIVE-SIGNED-BROKER-RUNTIME`
- `MTP-96-PAPER-RUNTIME-KERNEL-VALIDATION`

## MTP-96 禁止

- 不实现真实 live runtime、production scheduler、exchange clock 或 broker session clock。
- 不实现 CommandBus / EventBus / MessageBus routing。
- 不实现 Paper Pre-trade RiskEngine runtime path、paper lifecycle coordinator、simulated fill / fee / slippage model 或 paper account / portfolio projection v2。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、真实 submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不暴露 UI state、Runtime object、Adapter object、SQLite / DuckDB schema 或 broker object。
- 不新增 Live PRO Console、live command、order-level command UI、order form、交易按钮或真实交易授权。

## MTP-97 CommandBus / EventBus / MessageBus Routing Validation

日期：2026-05-25

执行者：Codex

MTP-97 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-97-COMMANDBUS-EVENTBUS-MESSAGEBUS-ROUTING`、`MTP-97-DETERMINISTIC-PAPER-ROUTE-ORDER`、`MTP-97-REPLAYABLE-ROUTE-EVIDENCE`、`MTP-97-NO-LIVE-SIGNED-BROKER-ROUTING` 和 `MTP-97-PAPER-RUNTIME-BUS-VALIDATION` anchors。
- `Sources/MessageBus/PaperRuntimeBusRouting.swift` 必须定义 `PaperRuntimeCommandBus`、`PaperRuntimeEventBus`、`PaperRuntimeMessageBusRouting`、`PaperRuntimeRouteEvidence`、`PaperRuntimeBusRoutingContract` 和 deterministic fixture，并保持 routing 只覆盖 paper session command、paper risk decision、paper lifecycle event 和 simulated fill event。
- `Sources/MessageBus/EventLog.swift` / `MessageBus.publish` 可接收 deterministic envelope `id`，用于 replay evidence 固定 source / correlation / causation；默认行为仍保持 append-only event log 分配 sequence。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-97 focused tests，验证 routing 顺序 deterministic、Event Log / Replay 后 route evidence 可复现、以及 live command bus / signed request / broker / invalid stream bypass 均被拒绝。
- `docs/domain/context.md` 必须包含 `MTP-97-PAPER-RUNTIME-BUS-ROUTING-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-97 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-97 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-97 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 Paper RiskEngine、paper lifecycle coordinator、simulated fill / fee / slippage model、paper account projection、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、live command 或交易按钮。

MTP-97 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-97-COMMANDBUS-EVENTBUS-MESSAGEBUS-ROUTING`
- `MTP-97-DETERMINISTIC-PAPER-ROUTE-ORDER`
- `MTP-97-REPLAYABLE-ROUTE-EVIDENCE`
- `MTP-97-NO-LIVE-SIGNED-BROKER-ROUTING`
- `MTP-97-PAPER-RUNTIME-BUS-VALIDATION`

## MTP-97 禁止

- 不实现 live command bus、order-level real command 或真实 submit / cancel / replace。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 execution report parser / ingestion、broker fill recorder、reconciliation service、OMS 或 real order lifecycle。
- 不实现 Paper RiskEngine runtime path、paper lifecycle coordinator、simulated fill / fee / slippage model 或 paper account / portfolio projection v2。
- 不暴露 Runtime object、Adapter object、SQLite / DuckDB schema、broker acknowledgement、UI state 或 Live PRO Console。
- 不新增 live command、order-level command UI、order form、交易按钮或真实交易授权。

## MTP-98 Paper Pre-trade RiskEngine Runtime Path Validation

日期：2026-05-25

执行者：Codex

MTP-98 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH`、`MTP-98-ACCEPTED-REJECTED-PAPER-RISK-DECISION`、`MTP-98-REJECTED-DECISION-EVENTLOG-REPLAY`、`MTP-98-PAPER-RISK-NO-LIVE-ACCOUNT-BROKER-UPGRADE` 和 `MTP-98-PAPER-RISKENGINE-VALIDATION` anchors。
- `Sources/RiskEngine/PreTrade/PaperPreTradeRiskEngine.swift` 必须定义 `PaperPreTradeRiskEngineInput`、`PaperPreTradeRiskEngineDecision`、`PaperPreTradeRiskEngineRuntimePath`、`PaperPreTradeRiskEnginePublication` 和 deterministic fixture，并保持输入只来自 paper proposal、paper account snapshot、paper exposure 和 deterministic paper risk rules。
- MTP-98 必须复用 MTP-97 `PaperRuntimeMessageBusRouting`，让 rejected paper risk decision 进入 `.risk` stream 的 `evaluationRequested` / `blocked` facts，并可由 Event Log / Replay 重建 route evidence。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-98 focused tests，验证 accepted / rejected paper risk decision deterministic、rejected decision 进入 Event Log / Replay、以及真实账户、broker position、margin、leverage、live risk engine、real pre-trade allow / reject 和 paper -> future live risk decision decode bypass 均被拒绝。
- `docs/domain/context.md` 必须包含 `MTP-98-PAPER-PRETRADE-RISKENGINE-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-98 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-98 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-98 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 paper lifecycle coordinator、simulated fill / fee / slippage model、paper account / portfolio projection、signed endpoint、account endpoint、listenKey、broker action、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、live command 或交易按钮。

MTP-98 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-98-PAPER-PRETRADE-RISKENGINE-RUNTIME-PATH`
- `MTP-98-ACCEPTED-REJECTED-PAPER-RISK-DECISION`
- `MTP-98-REJECTED-DECISION-EVENTLOG-REPLAY`
- `MTP-98-PAPER-RISK-NO-LIVE-ACCOUNT-BROKER-UPGRADE`
- `MTP-98-PAPER-RISKENGINE-VALIDATION`

## MTP-98 禁止

- 不实现 live risk engine、真实账户风控、real pre-trade allow / reject runtime、circuit breaker command、stop trading command 或 emergency stop。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL 或 equity。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、真实 submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 paper lifecycle coordinator、simulated fill / fee / slippage model 或 paper account / portfolio projection v2。
- 不把 paper risk blocker、paper exposure 或 paper account snapshot 升级为 future live risk decision、真实账户 exposure、broker position、risk command、live command UI、order form、交易按钮或真实交易授权。

## MTP-99 Paper-only Lifecycle Coordinator / Local Order Lifecycle Validation

日期：2026-05-25

执行者：Codex

MTP-99 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-99-PAPER-ONLY-LIFECYCLE-COORDINATOR`、`MTP-99-LOCAL-ORDER-LIFECYCLE-STATES`、`MTP-99-LIFECYCLE-TRANSITION-EVENT-FACTS`、`MTP-99-SIMULATED-FILL-PRECONDITION`、`MTP-99-NO-OMS-BROKER-REAL-CANCEL` 和 `MTP-99-PAPER-LIFECYCLE-COORDINATOR-VALIDATION` anchors。
- `Sources/ExecutionEngine/PaperLifecycle/PaperOrderLifecycleCoordinator.swift` 必须定义 `PaperOrderLocalLifecycleState`、`PaperOrderLocalLifecycleTransition`、`PaperOrderLocalLifecycleCoordinator`、`PaperOrderLocalLifecyclePublication`、`PaperOrderSimulatedFillPrecondition` 和 deterministic fixture。
- `PaperOrderLocalLifecycleCoordinator` 必须消费 MTP-98 `PaperPreTradeRiskEngineDecision`，accepted path 产生 `proposed -> submittedLocal -> acceptedLocal`，rejected path 产生 `proposed -> rejectedByPaperRisk`。
- 每个 transition 必须通过 `PaperEvent.orderLocalLifecycleTransitionRecorded` 写入 `.paper` stream，并可由 Event Log / Replay 重建 route evidence。
- `cancelledLocal` 只能来自 session close / reset、local expiry 或 deterministic local rule；不得新增单笔 order cancel button 或 real cancel command。
- `PaperOrderSimulatedFillPrecondition` 只能从 `acceptedLocal` 生成，且不生成 simulated fill / fee / slippage。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-99 focused tests，验证 deterministic accepted / rejected lifecycle、transition event facts、replay evidence、simulated fill precondition，以及 OMS / broker / real order state machine / real cancel / order-level command UI bypass 均被拒绝。
- `docs/domain/context.md` 必须包含 `MTP-99-PAPER-LOCAL-LIFECYCLE-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-99 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-99 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-99 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、single-order cancel UI、order-level command UI、live command 或交易按钮。

MTP-99 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-99-PAPER-ONLY-LIFECYCLE-COORDINATOR`
- `MTP-99-LOCAL-ORDER-LIFECYCLE-STATES`
- `MTP-99-LIFECYCLE-TRANSITION-EVENT-FACTS`
- `MTP-99-SIMULATED-FILL-PRECONDITION`
- `MTP-99-NO-OMS-BROKER-REAL-CANCEL`
- `MTP-99-PAPER-LIFECYCLE-COORDINATOR-VALIDATION`

## MTP-99 禁止

- 不实现 simulated fill / fee / slippage model 或 paper account / portfolio projection v2。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增单笔 order cancel button、order-level command UI、order form、live command、Live PRO Console 或交易按钮。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL 或 equity。
- 不把 `acceptedLocal` 写成 exchange accepted、broker submitted、broker accepted 或真实执行授权。

## MTP-100 Simulated Fill / Fee / Slippage Deterministic Model Validation

日期：2026-05-26

执行者：Codex

MTP-100 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-100-SIMULATED-FILL-MARKET-SNAPSHOT`、`MTP-100-PARTIAL-FULL-SIMULATED-FILL-EVIDENCE`、`MTP-100-FEE-SLIPPAGE-COST-IMPACT`、`MTP-100-SIMULATED-FILL-EVENTLOG-REPLAY`、`MTP-100-NO-BROKER-EXECUTION-REPORT-RECONCILIATION` 和 `MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-VALIDATION` anchors。
- `Sources/ExecutionEngine/SimulatedExchange/PaperSimulatedFillEvidence.swift` 必须定义 `PaperSimulatedFillMarketSnapshot`、`PaperSimulatedFillCompletion`、`PaperSimulatedFillPriceSource`、`PaperSimulatedFillEventLogBoundary`、`PaperSimulatedFillPublication`、`PaperSimulatedFillReplayPath` 和 deterministic fixture。
- simulated fill 输入必须包含 market snapshot、allowed paper order intent、MTP-99 `PaperOrderSimulatedFillPrecondition` 和 deterministic fill assumption。
- fee / slippage 必须复用 MTP-27 `ExecutionCostAssumptions.deterministicFixture`，不得引入交易所费率表、真实 fee statement、dynamic slippage 或 execution optimizer。
- partial / full fill evidence 必须可区分：full 的 remaining quantity 为 0；partial 的 remaining quantity 大于 0。
- simulated fill result 必须通过 MTP-97 `PaperRuntimeMessageBusRouting` 写入 `.paper` stream，并可从 Event Log / Replay 重建 route evidence 和 fill facts。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-100 focused tests，验证 deterministic full / partial cost evidence、Event Log / Replay evidence，以及 broker fill / execution report / reconciliation / real account update bypass 均被拒绝。
- `docs/domain/context.md` 必须包含 `MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-100 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-100 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-100 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation、signed endpoint、account endpoint、broker action 或 real account update。

MTP-100 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-100-SIMULATED-FILL-MARKET-SNAPSHOT`
- `MTP-100-PARTIAL-FULL-SIMULATED-FILL-EVIDENCE`
- `MTP-100-FEE-SLIPPAGE-COST-IMPACT`
- `MTP-100-SIMULATED-FILL-EVENTLOG-REPLAY`
- `MTP-100-NO-BROKER-EXECUTION-REPORT-RECONCILIATION`
- `MTP-100-SIMULATED-FILL-FEE-SLIPPAGE-VALIDATION`

## MTP-100 禁止

- 不实现 paper account / portfolio / position projection v2。
- 不新增 App / Dashboard surface。
- 不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation 或 real account update。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、Live PRO Console、live command、order form 或交易按钮。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL 或 equity。
- 不把 `PaperSimulatedFillEvidence` 写成真实成交、broker fill、execution report 或 account update。

## MTP-101 Paper Account / Portfolio / Position Projection v2 Validation

日期：2026-05-26

执行者：Codex

MTP-101 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-101-PAPER-ACCOUNT-PORTFOLIO-POSITION-PROJECTION`、`MTP-101-REPLAYED-SIMULATED-FILL-PROJECTION`、`MTP-101-PAPER-PNL-SNAPSHOT`、`MTP-101-READ-MODEL-CONSUMPTION`、`MTP-101-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE` 和 `MTP-101-PAPER-ACCOUNT-PORTFOLIO-VALIDATION` anchors。
- `Sources/Portfolio/PaperAccountPortfolioProjectionV2.swift` 必须定义 `PaperAccountProjectionSnapshot`、`PaperPositionProjectionSnapshot`、`PaperPortfolioPnLSummary`、`PaperAccountPortfolioProjectionV2Snapshot`、`PaperAccountPortfolioProjectionV2Path` 和 deterministic fixture。
- Projection v2 必须从 replayed `.paper.simulatedFillRecorded` facts 派生 account cash、available paper balance、equity、position quantity、average entry、exposure、cost basis 和 paper PnL summary。
- Persistence 只能保存 Core snapshot 派生的 runtime projection；App / Dashboard / Report / Risk / Portfolio 只能消费 read model / ViewModel。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-101 focused tests，验证 replay -> projection deterministic 和 Codable forbidden capability bypass rejection。
- `Tests/AppTests/AppTests.swift` 必须包含 MTP-101 focused test，验证 Report / Dashboard / Risk / Portfolio read model consumption。
- `docs/domain/context.md` 必须包含 `MTP-101-PAPER-ACCOUNT-PORTFOLIO-PROJECTION-TERMS`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-101 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-101 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-101 contract、matrix、validation plan、domain context、latest summary、Core/App source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现真实账户余额读取、broker position sync、margin、leverage、real PnL、live risk runtime、signed endpoint、account endpoint、broker action 或真实订单行为。

MTP-101 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-101-PAPER-ACCOUNT-PORTFOLIO-POSITION-PROJECTION`
- `MTP-101-REPLAYED-SIMULATED-FILL-PROJECTION`
- `MTP-101-PAPER-PNL-SNAPSHOT`
- `MTP-101-READ-MODEL-CONSUMPTION`
- `MTP-101-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`
- `MTP-101-PAPER-ACCOUNT-PORTFOLIO-VALIDATION`

## MTP-101 禁止

- 不实现 Event Log / Replay / Report / Dashboard evidence stage closeout；该收口留给 MTP-102。
- 不新增 order-level App / Dashboard command surface，不新增 position command、order form、live command 或交易按钮。
- 不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation 或 real account update。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、Live PRO Console、live command、order form 或交易按钮。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL 或 equity。

## MTP-102 Event Log / Replay / Report / Dashboard Evidence Stage Closeout Validation

日期：2026-05-26

执行者：Codex

MTP-102 的 required validation：

- `docs/contracts/paper-runtime-kernel-contract.md` 必须包含 `MTP-102-EVENTLOG-REPLAY-PROJECTION-EVIDENCE-CLOSEOUT`、`MTP-102-REPORT-DASHBOARD-PAPER-RUNTIME-EVIDENCE`、`MTP-102-EVENT-TIMELINE-COMPLETE-SEQUENCE`、`MTP-102-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-102-NO-FINAL-STAGE-CODE-AUDIT` 和 `MTP-102-PAPER-RUNTIME-STAGE-CLOSEOUT-VALIDATION` anchors。
- `Sources/Dashboard/ReadModels/App.swift` 必须把 local lifecycle transition IDs、paper risk decision IDs、paper order IDs、simulated fill IDs、account portfolio snapshot IDs、gross notional、fee、slippage、cost impact、paper account、position 和 paper PnL evidence 汇总到 `ReportViewModel`。
- `Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift` 必须把 `.paper.orderLocalLifecycleTransitionRecorded` 映射为 `Paper local lifecycle transition` Event Timeline item，并保留 risk decision / paper order evidence links。
- `Sources/Dashboard/DashboardShell.swift` 必须在 Report metrics / details 和 `smokeSummary` 中输出 paper runtime evidence、paper workflow evidence 和 paper portfolio impact handles。
- `Tests/AppTests/AppTests.swift` 必须包含 `testMTP102PaperRuntimeEvidenceChainFeedsReportDashboardAndEventTimeline`，验证 risk -> lifecycle -> simulated fill -> account portfolio projection 的 deterministic replay chain 被 Report / Dashboard / Event Timeline 只读消费。
- `docs/audit/inputs/mtpro-event-driven-paper-trading-runtime-v1-stage-audit-input.md` 必须作为 Parent Codex Stage Code Audit 输入材料落仓；不得生成最终 Stage Code Audit Report。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-102 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-102 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-102 contract、matrix、validation plan、latest summary、stage audit input、App source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不实现 final Stage Code Audit Report、Project closure、Root Docs Refresh Gate、OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、execution report、broker fill、reconciliation、real account update、signed endpoint、account endpoint、broker action、Live PRO Console、live command、order form、position command 或交易按钮。

MTP-102 必须建立的主要 anchors：

- `TVM-PAPER-RUNTIME-KERNEL`
- `MTP-102-EVENTLOG-REPLAY-PROJECTION-EVIDENCE-CLOSEOUT`
- `MTP-102-REPORT-DASHBOARD-PAPER-RUNTIME-EVIDENCE`
- `MTP-102-EVENT-TIMELINE-COMPLETE-SEQUENCE`
- `MTP-102-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-102-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-102-PAPER-RUNTIME-STAGE-CLOSEOUT-VALIDATION`

## MTP-102 禁止

- 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一 issue，不启动下一阶段 `symphony-issue`。
- 不新增 order-level App / Dashboard command surface，不新增 position command、order form、live command、Live PRO Console、stop button 或交易按钮。
- 不实现 broker fill、execution report parser、真实 fee statement、真实成交质量分析、live reconciliation 或 real account update。
- 不实现 OMS、broker router、真实 order lifecycle、真实 submit / cancel / replace、live risk runtime、production runtime 或真实交易授权。
- 不接 signed endpoint、account endpoint、listenKey、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不读取真实账户余额、broker position、margin、leverage、真实 PnL、equity、secret 或 API key。

## MTP-103 Data Catalog / Scenario Replay Terminology / Boundary Validation

日期：2026-05-26

执行者：Codex

MTP-103 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY`、`MTP-103-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`、`MTP-103-LOCAL-FIRST-DETERMINISTIC-VERSIONED-BOUNDARY`、`MTP-103-FORBIDDEN-CAPABILITY-BASELINE` 和 `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION` anchors。
- `Sources/DataEngine/ScenarioReplay/DataCatalogScenarioReplayBoundary.swift` 必须定义 `DataCatalogScenarioReplayTerm`、`DataCatalogScenarioReplayTargetEngine`、`DataCatalogScenarioReplayBoundaryPrinciple`、`DataCatalogScenarioReplayForbiddenCapability`、`DataCatalogScenarioReplayEvidenceKind` 和 `DataCatalogScenarioReplayBoundary.deterministicFixture`。
- `DataCatalogScenarioReplayBoundary` 必须固定 Data Engine、State & Persistence Engine 和 Workbench Interface 三类目标引擎职责。
- Boundary fixture 必须保持 `local-first`、`deterministic`、`versioned` 和 `read-model-only` flags 为 true。
- Boundary fixture 必须保持 manifest parser、fixture data、replay cursor、report input versioning、production data platform、large-scale ingestion pipeline、real network download、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、live command、trading button、Graphify update 和 Figma change flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-103 focused tests，验证 terminology / boundary anchors、forbidden capability bypass rejection、Codable decode bypass rejection 和 local-first read-model-only target engine boundary。
- `docs/domain/context.md` 必须包含 `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY` 和 `MTP-103-FORBIDDEN-CAPABILITY-BASELINE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-DATA-CATALOG-SCENARIO-REPLAY` 和 MTP-103 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-103 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-103 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 manifest parser、fixture data、replay cursor、report input versioning、production data platform、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-103 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-TERMINOLOGY`
- `MTP-103-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`
- `MTP-103-LOCAL-FIRST-DETERMINISTIC-VERSIONED-BOUNDARY`
- `MTP-103-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-103-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION`

## MTP-103 禁止

- 不实现 scenario manifest parser、scenario manifest 最终字段解析、fixture 数据、replay cursor、checksum 计算、freshness evidence runtime、data quality gate runtime 或 report input versioning runtime。
- 不实现 Simulated Exchange / Backtest Parity runtime；该能力必须由后续独立 Project / issue 授权。
- 不新增 production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production retention cleanup 或数据修复平台。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-104 Scenario Manifest / Scenario ID / Dataset Version Contract Validation

日期：2026-05-26

执行者：Codex

MTP-104 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS`、`MTP-104-SCENARIO-ID-DATASET-VERSION-STABLE-IDENTITY`、`MTP-104-SINGLE-SYMBOL-SINGLE-TIMEFRAME-MANIFEST`、`MTP-104-MANIFEST-DETERMINISTIC-SERIALIZATION`、`MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY` 和 `MTP-104-SCENARIO-MANIFEST-VALIDATION` anchors。
- `Sources/DataEngine/ScenarioReplay/ScenarioManifest.swift` 必须定义 `ScenarioID`、`DatasetVersion`、`ScenarioManifestScope`、`ScenarioManifestDeterministicSerialization` 和 `ScenarioManifest.deterministicFixture`。
- `ScenarioManifest` 必须固定 `scenarioID`、`datasetVersion`、`symbol`、`timeframe`、`sourceAnchor` 和 `single-symbol / single-timeframe` scope。
- `ScenarioManifest.deterministicSerialization` 必须固定 canonical field order，并生成可比较的 stable source identity。
- Manifest fixture 必须保持 database schema exposure、adapter request exposure、secret、signed endpoint、account endpoint、listenKey、broker、order command、live runtime、production dataset registry、real network download、multi-symbol catalog 和 multi-timeframe catalog flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-104 focused tests，验证 manifest 最小字段、scenario id / dataset version stable identity、single-symbol / single-timeframe scope、deterministic serialization / equality evidence、forbidden capability bypass rejection 和 Codable decode bypass rejection。
- `docs/domain/context.md` 必须包含 `MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS` 和 `MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-104 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-104 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-104 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 fixture data、replay cursor、report input versioning runtime、production dataset registry、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-104 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-104-SCENARIO-MANIFEST-MINIMAL-FIELDS`
- `MTP-104-SCENARIO-ID-DATASET-VERSION-STABLE-IDENTITY`
- `MTP-104-SINGLE-SYMBOL-SINGLE-TIMEFRAME-MANIFEST`
- `MTP-104-MANIFEST-DETERMINISTIC-SERIALIZATION`
- `MTP-104-MANIFEST-NO-SCHEMA-ADAPTER-LIVE-CAPABILITY`
- `MTP-104-SCENARIO-MANIFEST-VALIDATION`

## MTP-104 禁止

- 不实现 manifest file parser、fixture data、replay cursor、checksum calculation runtime、freshness evidence runtime、data quality gate runtime 或 report input versioning runtime。
- 不新增 multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器或 production retention cleanup。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-105 Single-Symbol / Single-Timeframe Deterministic Scenario Fixture Validation

日期：2026-05-26

执行者：Codex

MTP-105 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE`、`MTP-105-FIXTURE-VERSION-SOURCE-ANCHOR`、`MTP-105-FIXED-WINDOW-RECORD-ORDER`、`MTP-105-PUBLIC-READ-ONLY-LOCAL-FIXTURE-RELATIONSHIP`、`MTP-105-DETERMINISTIC-SUMMARY-PRESTRUCTURE`、`MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE` 和 `MTP-105-SCENARIO-FIXTURE-VALIDATION` anchors。
- `Sources/DataEngine/ScenarioReplay/ScenarioFixture.swift` 必须定义 `FixtureVersion`、`ScenarioFixtureSourceKind`、`ScenarioFixtureRecordOrderPolicy`、`ScenarioFixtureRecord`、`ScenarioFixtureDeterministicSummary` 和 `DeterministicScenarioFixture.deterministicFixture`。
- `DeterministicScenarioFixture` 必须复用 `ScenarioManifest.deterministicFixture`，并固定 `fixture-v1`、BTCUSDT、1m、fixed window、record sequence `1,2,3`、strictly ascending interval starts 和 local public-read-only source relationship。
- `ScenarioFixtureDeterministicSummary` 必须固定 record count、ordered starts、record order identity、canonical record summary、checksum preimage 和 MTP-104 source identity；`checksumEvidenceDeferredToMTP106` 必须为 `true`。
- Fixture 必须保持 required validation network-independent，且 real network download、production ingestion pipeline、cloud data lake、adapter request exposure、secret、signed endpoint、account endpoint、listenKey、broker、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、live command、trading button、multi-symbol 和 multi-timeframe flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-105 focused tests，验证 first scenario records、fixture version / source anchor、fixed window / record order、deterministic summary pre-structure、forbidden capability bypass rejection、Codable decode bypass rejection 和 forbidden text absence。
- `docs/domain/context.md` 必须包含 `MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE` 和 `MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-105 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-105 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-105 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 replay cursor、final checksum evidence、freshness evidence、data quality gate、report input versioning runtime、production dataset registry、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-105 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-105-SINGLE-SYMBOL-SINGLE-TIMEFRAME-FIXTURE`
- `MTP-105-FIXTURE-VERSION-SOURCE-ANCHOR`
- `MTP-105-FIXED-WINDOW-RECORD-ORDER`
- `MTP-105-PUBLIC-READ-ONLY-LOCAL-FIXTURE-RELATIONSHIP`
- `MTP-105-DETERMINISTIC-SUMMARY-PRESTRUCTURE`
- `MTP-105-NO-NETWORK-SIGNED-BROKER-LIVE`
- `MTP-105-SCENARIO-FIXTURE-VALIDATION`

## MTP-105 禁止

- 不实现 manifest file parser、replay cursor、final checksum evidence、freshness evidence runtime、data quality gate runtime 或 report input versioning runtime。
- 不新增 multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器或 production retention cleanup。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-106 Replay Window / Cursor / Checksum / Freshness Evidence Validation

日期：2026-05-26

执行者：Codex

MTP-106 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-106-DETERMINISTIC-REPLAY-WINDOW`、`MTP-106-REPLAY-CURSOR-SUMMARY`、`MTP-106-CHECKSUM-PARITY-EVIDENCE`、`MTP-106-FIXTURE-FRESHNESS-EVIDENCE`、`MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE` 和 `MTP-106-SCENARIO-REPLAY-EVIDENCE-VALIDATION` anchors。
- `Sources/DataEngine/ScenarioReplay/ScenarioReplayEvidence.swift` 必须定义 `ScenarioReplayWindow`、`ScenarioReplayCursor`、`ScenarioReplayCursorSummary`、`ScenarioReplayChecksumEvidence`、`ScenarioReplayFreshnessPolicy`、`ScenarioReplayFreshnessEvidence` 和 `ScenarioReplayEvidence.deterministicFixture`。
- `ScenarioReplayWindow` 必须复用 MTP-105 deterministic fixture 的 fixed window `1704067200...1704067380`、record sequence `1,2,3`、ordered starts 和 record order identity。
- `ScenarioReplayCursor` 必须只表达本地 fixture record progress，支持 Codable round-trip 和 Comparable，并拒绝 `1...4` 之外的 next sequence。
- `ScenarioReplayChecksumEvidence` 必须从 MTP-105 checksum preimage 生成 final checksum `fnv1a64:3c6cd4ff13cd4062`，并拒绝 checksum drift。
- `ScenarioReplayFreshnessEvidence` 必须固定 local fixture freshness policy、evaluatedAt `1704067500`、age `120` seconds 和 status `fresh`，并拒绝 production retention / network / archive bypass。
- `ScenarioReplayEvidence` 必须输出可被 MTP-107 data quality gates 消费的 `dataQualityGateInputIdentity`，但不得实现 data quality gate runtime 或 report input versioning runtime。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-106 focused tests，验证 replay window deterministic、cursor 可复现 / 可编码 / 可比较、checksum / freshness evidence 稳定、drift rejection、forbidden capability bypass rejection 和 forbidden text absence。
- `docs/domain/context.md` 必须包含 `MTP-106-DETERMINISTIC-REPLAY-WINDOW`、`MTP-106-CHECKSUM-PARITY-EVIDENCE`、`MTP-106-FIXTURE-FRESHNESS-EVIDENCE` 和 `MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-106 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-106 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-106 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 data quality gate runtime、report input versioning runtime、production retention engine、production dataset registry、large-scale ingestion pipeline、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-106 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-106-DETERMINISTIC-REPLAY-WINDOW`
- `MTP-106-REPLAY-CURSOR-SUMMARY`
- `MTP-106-CHECKSUM-PARITY-EVIDENCE`
- `MTP-106-FIXTURE-FRESHNESS-EVIDENCE`
- `MTP-106-NO-PRODUCTION-NETWORK-BROKER-LIVE`
- `MTP-106-SCENARIO-REPLAY-EVIDENCE-VALIDATION`

## MTP-106 禁止

- 不实现 manifest file parser、data quality gate runtime 或 report input versioning runtime。
- 不新增 multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production scheduler、production retention cleanup、cloud archive 或 storage tiering。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-107 Data Quality Gates / Report Input Versioning Validation

日期：2026-05-26

执行者：Codex

MTP-107 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-107-DATA-QUALITY-GATE-TAXONOMY`、`MTP-107-MINIMAL-DATA-QUALITY-GATES`、`MTP-107-REPORT-INPUT-VERSIONING`、`MTP-107-REPORT-REPRODUCIBILITY-EVIDENCE`、`MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM` 和 `MTP-107-DATA-QUALITY-REPORT-INPUT-VALIDATION` anchors。
- `Sources/DataEngine/DataQuality/ScenarioDataQualityReportInput.swift` 必须定义 `ScenarioDataQualityGateKind`、`ScenarioDataQualityGateVerdict`、`ScenarioDataQualityVerdict`、`ScenarioDataQualityGateEvaluation`、`ScenarioReportInputVersion` 和 `ScenarioDataQualityReportInputEvidence.deterministicFixture`。
- `ScenarioDataQualityGateEvaluation` 必须消费 MTP-106 `ScenarioReplayEvidence`，并固定 record order、window coverage、checksum match、freshness status、missing data 和 duplicate data 六个最小 gates。
- 默认 deterministic fixture 必须全部 passed，整体 `qualityVerdict == accepted`；checksum mismatch、bad record order、missing data 和 duplicate data 必须 rejected；stale freshness 必须 marked；expired freshness 必须 rejected。
- `ScenarioReportInputVersion` 必须复制 scenario id、dataset version、fixture version、symbol、timeframe、replay window、checksum、freshness status、quality verdict 和 quality summary，并固定 canonical field order。
- Report input versioning 必须保持 stable contract，不暴露 SQLite / DuckDB schema、adapter request 或 Runtime object。
- `ScenarioDataQualityReportInputEvidence` 必须把 replay evidence、quality evaluation 和 report input version 绑定到同一 deterministic identity，并保持 `reportReproducibilityEvidenceHeld == true`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-107 focused tests，验证 gate taxonomy、deterministic accepted verdict、report input version tracing、bad fixture / checksum mismatch / missing / duplicate data rejection、stale marking、expired rejection、forbidden capability bypass rejection 和 Codable decode bypass rejection。
- `docs/domain/context.md` 必须包含 `MTP-107-DATA-QUALITY-GATE-TAXONOMY`、`MTP-107-REPORT-INPUT-VERSIONING` 和 `MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-107 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-107 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-107 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 production data platform、production data observability、automatic download / repair、broker / account reconciliation、Simulated Exchange / Backtest Parity runtime、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-107 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-107-DATA-QUALITY-GATE-TAXONOMY`
- `MTP-107-MINIMAL-DATA-QUALITY-GATES`
- `MTP-107-REPORT-INPUT-VERSIONING`
- `MTP-107-REPORT-REPRODUCIBILITY-EVIDENCE`
- `MTP-107-NO-PRODUCTION-LIVE-BROKER-DATA-PLATFORM`
- `MTP-107-DATA-QUALITY-REPORT-INPUT-VALIDATION`

## MTP-107 禁止

- 不实现 manifest file parser、production data quality platform、production data observability、automatic download、automatic repair、broker / account reconciliation 或 Simulated Exchange / Backtest Parity runtime。
- 不新增 multi-symbol / multi-timeframe catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production scheduler、production retention cleanup、cloud archive 或 storage tiering。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-108 Workbench / Report / Events Scenario Replay Evidence Surface Validation

日期：2026-05-26

执行者：Codex

MTP-108 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE`、`MTP-108-REPORT-SCENARIO-REPLAY-EVIDENCE`、`MTP-108-WORKBENCH-SCENARIO-REPLAY-SUMMARY-DRILLDOWN`、`MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS`、`MTP-108-QUALITY-GATE-TIMELINE`、`MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-108-SCENARIO-REPLAY-SURFACE-VALIDATION` anchors。
- `Sources/Dashboard/Report/ScenarioReplayEvidenceSurface.swift` 必须定义 `ScenarioReplayEvidenceReadModel`、`ScenarioReplayEvidenceViewModel` 和 MTP-108 validation anchors，并且只消费 MTP-107 `ScenarioDataQualityReportInputEvidence.deterministicFixture` 的 stable fields。
- `ReportReadModel` / `ReportViewModel` 必须输出 scenario id、dataset version、fixture version、replay window、checksum、freshness status、quality verdict、report input version identity、drill-down entry、timeline count 和 quality gate timeline count。
- `DashboardShellWorkbenchSnapshot` 必须输出 scenario replay summary、drill-down evidence、read-model-only source 和 Dashboard smoke handles `scenarioReplayEvidence` / `scenarioQualityGates`。
- `PaperWorkflowEvidenceExplorer` 必须新增 `scenario replay evidence` section，并输出 replay window、cursor、checksum、freshness 和六个 quality gate timeline rows。
- `Tests/AppTests/AppTests.swift` 必须包含 `testMTP108ScenarioReplayEvidenceFeedsReportWorkbenchAndEventsReadOnly`，覆盖 Report、Workbench、Events、Dashboard smoke、Codable stable snapshot、read-model-only boundary、no command surface、no query language、no trading button、no live command、no broker action。
- `docs/domain/context.md` 必须包含 `MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE` 和 `MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-108 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-108 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-108 contract、matrix、validation plan、domain context、latest summary、App source、Dashboard / Events source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 Runtime / Adapter / Persistence schema、不实现 database console、query language、command surface、production data platform、automatic download / repair、broker / account reconciliation、Simulated Exchange / Backtest Parity runtime、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command 或交易按钮。

MTP-108 必须建立的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-108-SCENARIO-REPLAY-READ-MODEL-EVIDENCE`
- `MTP-108-REPORT-SCENARIO-REPLAY-EVIDENCE`
- `MTP-108-WORKBENCH-SCENARIO-REPLAY-SUMMARY-DRILLDOWN`
- `MTP-108-EVENTS-REPLAY-WINDOW-CURSOR-CHECKSUM-FRESHNESS`
- `MTP-108-QUALITY-GATE-TIMELINE`
- `MTP-108-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-108-SCENARIO-REPLAY-SURFACE-VALIDATION`

## MTP-108 禁止

- 不实现 manifest parser、Runtime replay job、Adapter request、Persistence schema、database console、query language 或 command model。
- 不新增 multi-symbol / multi-timeframe production catalog、production dataset registry、production data platform、cloud data lake、large-scale ingestion pipeline、真实历史下载器、production scheduler、production retention cleanup、cloud archive 或 storage tiering。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console、schema inspector、Runtime inspector 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-109 Validation Docs / Stage Audit Input Validation

日期：2026-05-26

执行者：Codex

MTP-109 的 required validation：

- `docs/contracts/data-catalog-scenario-replay-contract.md` 必须包含 `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-CLOSEOUT`、`MTP-109-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-109-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-AUDIT-INPUT`、`MTP-109-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION-EVIDENCE-CHAIN`、`MTP-109-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN` 和 `MTP-109-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/audit/inputs/mtpro-data-catalog-scenario-replay-v1-stage-audit-input.md` 必须存在，并包含 MTP-103 至 MTP-108 issue / PR evidence、Project validation evidence chain、forbidden capability evidence、read-model-only boundary evidence、automation readiness evidence、known boundaries、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-109 的当前 issue execution evidence，并明确 MTP-109 只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口，不输出最终 Stage Code Audit Report。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-109 issue backfill 和 MTP-109 Data Catalog / Scenario Replay 阶段收口说明，并指向 MTP-109 Stage Code Audit 输入材料。
- `docs/automation/automation-readiness.md` 必须包含 Data Catalog / Scenario Replay stage audit input anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-103 至 MTP-109 的 contract、matrix、validation plan、latest summary、stage audit input、Core / App source anchors、Core / App deterministic test anchors 和 Dashboard smoke `scenarioReplayEvidence` / `scenarioQualityGates` handles。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

MTP-109 必须收口的主要 anchors：

- `TVM-DATA-CATALOG-SCENARIO-REPLAY`
- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-CLOSEOUT`
- `MTP-109-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-109-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-STAGE-AUDIT-INPUT`
- `MTP-109-DATA-CATALOG-SCENARIO-REPLAY-VALIDATION-EVIDENCE-CHAIN`
- `MTP-109-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-109-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-109 禁止

- 不输出最终 Stage Code Audit Report，不创建 `docs/audit/mtpro-data-catalog-scenario-replay-v1-stage-code-audit.md`，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一 issue，不启动下一阶段 `symphony-issue`。
- 不实现 Simulated Exchange / Backtest Parity、production data platform、production data observability、large-scale ingestion pipeline、cloud data lake、automatic download、automatic repair、production scheduler、retention cleanup、cloud archive 或 storage tiering。
- 不实现 manifest parser、Runtime replay job、Adapter request、Persistence schema、database console、query language 或 command model。
- 不暴露 SQLite / DuckDB schema、adapter request、Runtime object、database console、schema inspector、Runtime inspector 或 UI command surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position read、live runtime、live command、order form、Live PRO Console 或交易按钮。
- 不运行 Graphify，不修改 Figma，不进行 unauthorized Linear mutation。

## MTP-110 Simulated Exchange / Backtest Parity Terminology / Boundary Validation

日期：2026-05-26

执行者：Codex

MTP-110 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY`、`MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`、`MTP-110-L1-L15-L2-HANDOFF-BOUNDARY`、`MTP-110-FORBIDDEN-CAPABILITY-BASELINE` 和 `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION` anchors。
- `Sources/ExecutionEngine/SimulatedExchange/SimulatedExchangeBacktestParityBoundary.swift` 必须定义 `SimulatedExchangeBacktestParityTerm`、`SimulatedExchangeBacktestParityTargetEngine`、`SimulatedExchangeBacktestParityBoundaryPrinciple`、`SimulatedExchangeBacktestParityForbiddenCapability`、`SimulatedExchangeBacktestParityEvidenceKind` 和 `SimulatedExchangeBacktestParityBoundary.deterministicFixture`。
- `SimulatedExchangeBacktestParityBoundary` 必须固定 Simulation / Backtest Engine、Execution Engine（paper-only / simulated）、Portfolio Engine、Data Engine、State & Persistence Engine 和 Workbench Interface 六类目标引擎职责。
- Boundary fixture 必须保持 deterministic simulation、backtest-paper shared simulation semantics、L1 Paper Runtime handoff、L1.5 Data Catalog / Scenario Replay handoff 和 read-model-only parity evidence flags 为 true。
- Boundary fixture 必须保持 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、trading button、emergency stop / shutdown / restore、Graphify update 和 Figma change flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-110 focused tests，验证 terminology / boundary anchors、forbidden capability bypass rejection、Codable decode bypass rejection 和 L1 / L1.5 / L2 deterministic handoff boundary。
- `docs/domain/context.md` 必须包含 `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY` 和 `MTP-110-FORBIDDEN-CAPABILITY-BASELINE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY` 和 MTP-110 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-110 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-110 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现撮合、订单执行、portfolio projection、UI、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-110 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-TERMINOLOGY`
- `MTP-110-TARGET-ENGINE-RESPONSIBILITY-BOUNDARY`
- `MTP-110-L1-L15-L2-HANDOFF-BOUNDARY`
- `MTP-110-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-110-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION`

## MTP-110 禁止

- 不实现 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command 或交易按钮。
- 不实现 emergency stop、shutdown、restore、production operations、production data platform、large-scale ingestion pipeline、真实交易所接入或 live readiness。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-111 Shared Backtest-Paper Order Semantics Validation

日期：2026-05-26

执行者：Codex

MTP-111 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`、`MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`、`MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT`、`MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE` 和 `MTP-111-SHARED-ORDER-SEMANTICS-VALIDATION` anchors。
- `Sources/ExecutionEngine/SimulatedExchange/BacktestPaperSharedOrderSemantics.swift` 必须定义 `BacktestPaperSharedOrderInputSource`、`BacktestPaperSharedOrderField`、`BacktestPaperSharedOrderState`、`BacktestPaperSharedOrderEventKind`、`BacktestPaperLifecycleReplayAlignmentRule`、`BacktestPaperSharedOrderForbiddenCapability`、`BacktestPaperSharedOrderSemanticsContract.deterministicFixture` 和 `BacktestPaperSharedOrderInput.deterministicFixture`。
- `BacktestPaperSharedOrderSemanticsContract` 必须固定 paper order intent 与 backtest replay order input 的共享字段、simulated order state taxonomy、simulated event kind taxonomy、paper lifecycle / fill completion 到 backtest replay 的 alignment rules、source docs anchors 和 validation anchors。
- `BacktestPaperSharedOrderInput` 必须从既有 `PaperOrderIntent` 复制 order / proposal / session / symbol / timeframe / side / quantity / reference price / notional / risk decision sequence，并绑定 `DeterministicScenarioFixture` 的 scenario id、dataset version 和 fixture version。
- `BacktestPaperSharedOrderSemanticsContract.sharedState(...)` 必须固定 `PaperOrderLifecycleState`、`PaperOrderLocalLifecycleState` 和 `PaperSimulatedFillCompletion` 到 shared simulated order state 的映射。
- Core fixture 必须保持 shared field、lifecycle replay alignment 和 append-only replay facts flags 为 true。
- Core fixture 和 shared input 必须保持 matching runtime、order execution runtime、portfolio projection runtime、real order command、real order lifecycle、real submit / cancel / replace、signed endpoint、account endpoint、listenKey、broker、`LiveExecutionAdapter`、OMS、execution report、broker fill、reconciliation、live command、order-level command UI、trading button 和 required network validation flags 全部为 false。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-111 focused tests，验证 shared fields / states / anchors、paper intent 到 scenario replay input 对齐、state / event 映射、forbidden capability bypass rejection 和 Codable decode bypass rejection。
- `docs/domain/context.md` 必须包含 `MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`、`MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`、`MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT` 和 `MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-111 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-111 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-111 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 matching runtime、order execution runtime、portfolio projection runtime、Report / Dashboard / Events surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、order-level command UI、Live PRO Console 或交易按钮。

MTP-111 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-111-SHARED-BACKTEST-PAPER-ORDER-FIELDS`
- `MTP-111-SIMULATED-ORDER-STATE-SEMANTICS`
- `MTP-111-PAPER-LIFECYCLE-BACKTEST-REPLAY-ALIGNMENT`
- `MTP-111-NO-REAL-ORDER-COMMAND-UPGRADE`
- `MTP-111-SHARED-ORDER-SEMANTICS-VALIDATION`

## MTP-111 禁止

- 不实现 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不实现 emergency stop、shutdown、restore、production operations、production data platform、large-scale ingestion pipeline、真实交易所接入或 live readiness。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-112 Scenario Replay Deterministic Matching Validation

日期：2026-05-26

执行者：Codex

MTP-112 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`、`MTP-112-DETERMINISTIC-MATCHING-ORDERING`、`MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`、`MTP-112-REPEATABLE-MATCHING-OUTPUT`、`MTP-112-NO-NETWORK-BROKER-LIVE` 和 `MTP-112-SCENARIO-REPLAY-MATCHING-VALIDATION` anchors。
- `Sources/DataEngine/ScenarioReplay/ScenarioReplayDeterministicMatching.swift` 必须定义 `ScenarioReplayDeterministicMatchingContract`、`ScenarioReplayDeterministicMatchingInput`、`ScenarioReplayMatchingMarketState`、`ScenarioReplaySimulatedExchangeEvent`、`ScenarioReplayDeterministicMatchingOutput`、`ScenarioReplayDeterministicMatchingModel`、`ScenarioReplayMatchingOrderingRule` 和 `ScenarioReplayMatchingOutputKind`。
- `ScenarioReplayDeterministicMatchingInput` 必须绑定 MTP-111 shared order input、MTP-106 replay window / cursor / checksum / freshness evidence 和 MTP-105 deterministic fixture record sequence `2`。
- `ScenarioReplayDeterministicMatchingModel.match` 必须对相同 scenario id / dataset version / fixture version / replay window / cursor / shared order input 输出相同 `ScenarioReplayDeterministicMatchingOutput`。
- Deterministic result identity 必须固定 scenario id、dataset version、fixture version、window、cursor sequence、record sequence、order id、scaled price 和 scaled quantity。
- Core fixture 和 Codable decode 必须拒绝 required validation network dependency、wall clock、randomness、signed endpoint、account endpoint、listenKey、broker / exchange adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、live command 和交易按钮绕过。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-112 focused tests，验证 input / output anchors、repeatable output identity、Codable round-trip 和 forbidden capability / cursor mismatch rejection。
- `docs/domain/context.md` 必须包含 `MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`、`MTP-112-DETERMINISTIC-MATCHING-ORDERING`、`MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`、`MTP-112-REPEATABLE-MATCHING-OUTPUT` 和 `MTP-112-NO-NETWORK-BROKER-LIVE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-112 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-112 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-112 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现真实撮合引擎、market / limit execution、partial fill / latency / fee / slippage parity、portfolio projection parity、Report / Dashboard / Events evidence surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-112 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-112-SCENARIO-REPLAY-MATCHING-INPUT`
- `MTP-112-DETERMINISTIC-MATCHING-ORDERING`
- `MTP-112-SIMULATED-EXCHANGE-MATCHING-EVENT`
- `MTP-112-REPEATABLE-MATCHING-OUTPUT`
- `MTP-112-NO-NETWORK-BROKER-LIVE`
- `MTP-112-SCENARIO-REPLAY-MATCHING-VALIDATION`

## MTP-112 禁止

- 不实现真实 matching runtime、order execution runtime、portfolio projection runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不实现 market / limit order execution semantics、partial fill、latency、fee / slippage parity、portfolio projection parity、emergency stop、shutdown、restore、production operations、production data platform、large-scale ingestion pipeline、真实交易所接入或 live readiness。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-113 Market / Limit Simulated Execution Validation

日期：2026-05-26

执行者：Codex

MTP-113 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`、`MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`、`MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`、`MTP-113-DETERMINISTIC-EXECUTION-REPLAY`、`MTP-113-NO-REAL-ORDER-LIVE-COMMAND` 和 `MTP-113-MARKET-LIMIT-SIMULATED-EXECUTION-VALIDATION` anchors。
- `Sources/ExecutionEngine/SimulatedExchange/MarketLimitSimulatedExecutionSemantics.swift` 必须定义 `MarketLimitSimulatedExecutionContract`、`MarketLimitSimulatedExecutionInput`、`MarketLimitSimulatedExecutionEvent`、`MarketLimitSimulatedExecutionOutput`、`MarketLimitSimulatedExecutionModel`、`MarketLimitSimulatedOrderType`、`MarketLimitSimulatedExecutionOutcome`、`MarketLimitSimulatedExecutionRule` 和 `MarketLimitSimulatedExecutionRejectReason`。
- `MarketLimitSimulatedExecutionInput` 必须绑定 MTP-112 deterministic matching input 和 MTP-111 shared order input；market order 不能带 limit price，limit order 必须带 explicit limit price。
- `MarketLimitSimulatedExecutionModel.execute` 必须对 market order 输出 deterministic full fill；对 buy limit price 大于等于 matched price 输出 full fill；对 buy limit price 低于 matched price 输出 expired simulated；对 rejected initial state 输出 rejected simulated。
- `MarketLimitSimulatedExecutionOutput.deterministicResultIdentity` 必须固定 scenario id、dataset version、fixture version、window、cursor sequence、record sequence、order id、order type、limit price、initial state、outcome、matched price、filled quantity 和 remaining quantity。
- Core fixture 和 Codable decode 必须拒绝 advanced order types、真实 order execution runtime、matching runtime、portfolio projection runtime、partial fill bypass、signed endpoint、account endpoint、listenKey、broker / exchange adapter、`LiveExecutionAdapter`、OMS、real submit / cancel / replace、execution report、broker fill、reconciliation、live command、order-level command UI 和交易按钮绕过。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-113 focused tests，验证 market / limit semantics anchors、market full fill、limit full fill、limit expire、reject evidence、deterministic replay identity、Codable round-trip 和 forbidden capability rejection。
- `docs/domain/context.md` 必须包含 `MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`、`MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`、`MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`、`MTP-113-DETERMINISTIC-EXECUTION-REPLAY` 和 `MTP-113-NO-REAL-ORDER-LIVE-COMMAND`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-113 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-113 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-113 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 stop / OCO / advanced order types、partial fill、latency、fee / slippage parity、portfolio projection parity、Report / Dashboard / Events evidence surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-113 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-113-MARKET-ORDER-SIMULATED-EXECUTION`
- `MTP-113-LIMIT-ORDER-SIMULATED-EXECUTION`
- `MTP-113-FULL-FILL-REJECT-EXPIRE-SEMANTICS`
- `MTP-113-DETERMINISTIC-EXECUTION-REPLAY`
- `MTP-113-NO-REAL-ORDER-LIVE-COMMAND`
- `MTP-113-MARKET-LIMIT-SIMULATED-EXECUTION-VALIDATION`

## MTP-113 禁止

- 不实现 stop / OCO / advanced order types、真实 order execution runtime、matching runtime、portfolio projection runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不实现 partial fill、latency、fee / slippage parity、portfolio projection parity、emergency stop、shutdown、restore、production operations、production data platform、large-scale ingestion pipeline、真实交易所接入或 live readiness。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-114 Partial Fill / Latency / Fee / Slippage Parity Validation

日期：2026-05-26

执行者：Codex

MTP-114 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-114-PARTIAL-FULL-FILL-PARITY`、`MTP-114-DETERMINISTIC-LATENCY-MODEL`、`MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`、`MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE`、`MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION` 和 `MTP-114-PARTIAL-FILL-LATENCY-FEE-SLIPPAGE-VALIDATION` anchors。
- `Sources/ExecutionEngine/SimulatedExchange/PartialFillLatencyFeeSlippageParity.swift` 必须定义 `PartialFillLatencyFeeSlippageParityContract`、`PartialFillLatencyFeeSlippageParityInput`、`PartialFillLatencyFeeSlippageLatencyAssumption`、`PartialFillLatencyFeeSlippageParityEvent`、`PartialFillLatencyFeeSlippageParityReportEvidence`、`PartialFillLatencyFeeSlippageParityModel`、`PartialFillLatencyFeeSlippageParityRule` 和 `PartialFillLatencyFeeSlippageForbiddenCapability`。
- `PartialFillLatencyFeeSlippageParityInput` 必须绑定 MTP-113 market / limit simulated execution input、deterministic simulated liquidity cap、fixed latency assumption、liquidity role 和 MTP-27 fixed execution cost assumptions。
- `PartialFillLatencyFeeSlippageParityModel.evaluate` 必须在 available simulated liquidity 小于 order quantity 时输出 partial fill / remaining quantity evidence，在 available simulated liquidity 等于 order quantity 时输出 full fill evidence。
- Latency evidence 必须由 replay record sequence 和 fixed tick offset 推导，默认 `2 -> 3`、`250ms`；不得使用 wall clock、randomness、真实网络、exchange latency 或 broker SLA。
- Fee / slippage evidence 必须复用 `ExecutionCostAssumptions.deterministicFixture` 和 `ExecutionCostParity.verify`，证明 Backtest / Paper 两侧 assumption、输入、fee amount、slippage amount、total cost 和 rounding scale 一致。
- `PartialFillLatencyFeeSlippageParityReportEvidence.deterministicResultIdentity` 必须固定 scenario id、dataset version、fixture version、window、cursor sequence、record sequence、order id、order type、available liquidity、latency assumption、liquidity role、cost assumption、fill completion、latency output、filled quantity、remaining quantity、fee、slippage 和 total cost。
- Core fixture 和 Codable decode 必须拒绝真实费率表、动态滑点模型、真实流动性消耗、执行成本优化、signed endpoint、account endpoint、listenKey、broker fill、execution report、reconciliation、`LiveExecutionAdapter`、OMS、portfolio projection runtime、live command、order-level command UI 和交易按钮绕过。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-114 focused tests，验证 contract anchors、partial fill evidence、full fill evidence、latency evidence、fee / slippage parity、deterministic identity、Codable round-trip 和 forbidden capability rejection。
- `docs/domain/context.md` 必须包含 `MTP-114-PARTIAL-FULL-FILL-PARITY`、`MTP-114-DETERMINISTIC-LATENCY-MODEL`、`MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`、`MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE` 和 `MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-114 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-114 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-114 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现完整交易所费率表、动态滑点模型、真实流动性消耗、执行成本优化、portfolio projection runtime、Report / Dashboard / Events evidence surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-114 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-114-PARTIAL-FULL-FILL-PARITY`
- `MTP-114-DETERMINISTIC-LATENCY-MODEL`
- `MTP-114-FEE-SLIPPAGE-PARITY-ASSUMPTIONS`
- `MTP-114-REPEATABLE-FILL-LATENCY-COST-EVIDENCE`
- `MTP-114-NO-REAL-FEE-SCHEDULE-BROKER-RECONCILIATION`
- `MTP-114-PARTIAL-FILL-LATENCY-FEE-SLIPPAGE-VALIDATION`

## MTP-114 禁止

- 不实现完整交易所费率表、动态滑点模型、真实流动性消耗、执行成本优化、真实 order execution runtime、matching runtime、portfolio projection runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不把 fee / slippage parity 写成 live fee schedule、真实成交成本、真实成交质量分析、broker fee statement、live readiness 或 production execution optimizer。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-115 Simulated Exchange Portfolio Projection Parity Validation

日期：2026-05-26

执行者：Codex

MTP-115 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`、`MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`、`MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`、`MTP-115-REPORT-INPUT-REPLAY-EVIDENCE`、`MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE` 和 `MTP-115-SIMULATED-EXCHANGE-PORTFOLIO-PROJECTION-VALIDATION` anchors。
- `Sources/Portfolio/SimulatedExchangePortfolioProjectionParity.swift` 必须定义 `SimulatedExchangePortfolioProjectionParityContract`、`SimulatedExchangePortfolioProjectionParityInput`、`SimulatedExchangePortfolioProjectionSnapshot`、`SimulatedExchangePortfolioProjectionParityEvidence`、`SimulatedExchangePortfolioProjectionParityModel`、`SimulatedExchangePortfolioProjectionRule`、`SimulatedExchangePortfolioProjectionMode`、`SimulatedExchangePortfolioProjectionForbiddenCapability` 和 `SimulatedExchangePortfolioProjectionParityFixture`。
- `SimulatedExchangePortfolioProjectionParityInput` 必须消费 MTP-114 `PartialFillLatencyFeeSlippageParityReportEvidence`，绑定 MTP-107 `ScenarioReportInputVersion` 和 source replay sequence `3`；不得读取真实账户、broker position、margin、leverage、Runtime object 或 persistence schema。
- `SimulatedExchangePortfolioProjectionParityModel.project` 必须从同一个 simulated exchange parity event 同时生成 backtest 与 paper projection，并保证两侧 `parityComparableIdentity` 一致。
- Projection snapshot 必须输出 position、cash、available simulated cash、equity、gross exposure、realized / unrealized / net simulated PnL 和 `PortfolioExposureSnapshot`；默认 partial fixture 必须固定 cash `39462.98038625`、equity `49993.15538625`、gross exposure `10530.175` 和 net simulated PnL `-6.84461375`。
- Core fixture 和 Codable decode 必须拒绝 real account balance read / sync、broker position read、margin read、leverage read、broker reconciliation、signed endpoint、account endpoint、listenKey、broker integration、`LiveExecutionAdapter`、OMS、live runtime、live command、order-level command UI、trading button、database schema exposure、runtime object read 和 network validation 绕过。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-115 focused tests，验证 contract anchors、report input / replay evidence、backtest / paper portfolio parity、position / cash / PnL / exposure numeric summary、full / partial fixtures、Codable round-trip 和 forbidden capability rejection。
- `docs/domain/context.md` 必须包含 `MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`、`MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`、`MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`、`MTP-115-REPORT-INPUT-REPLAY-EVIDENCE` 和 `MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-115 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-115 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-115 contract、matrix、validation plan、domain context、latest summary、Core source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 portfolio projection runtime、Report / Dashboard / Events evidence surface、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console 或交易按钮。

MTP-115 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-115-SIMULATED-EVENT-TO-PORTFOLIO-PROJECTION`
- `MTP-115-BACKTEST-PAPER-PORTFOLIO-PARITY`
- `MTP-115-POSITION-CASH-PNL-EXPOSURE-SUMMARY`
- `MTP-115-REPORT-INPUT-REPLAY-EVIDENCE`
- `MTP-115-NO-REAL-ACCOUNT-BROKER-MARGIN-LEVERAGE`
- `MTP-115-SIMULATED-EXCHANGE-PORTFOLIO-PROJECTION-VALIDATION`

## MTP-115 禁止

- 不实现 portfolio projection runtime、真实 order execution runtime、matching runtime、UI implementation、Report / Dashboard / Events evidence surface、order form、command model、Runtime replay job 或 database console。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、real account balance sync、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不把 simulated portfolio projection 写成真实账户资产、broker statement、margin / leverage、live readiness、production account reconciliation 或 trading command state。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-116 Report / Dashboard / Events Parity Evidence Surface Validation

日期：2026-05-26

执行者：Codex

MTP-116 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-116-PARITY-EVIDENCE-READ-MODEL`、`MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE`、`MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT`、`MTP-116-READ-MODEL-ONLY-NO-COMMAND-SURFACE`、`MTP-116-NO-LIVE-BROKER-SIGNED-ENDPOINT` 和 `MTP-116-SIMULATED-EXCHANGE-PARITY-SURFACE-VALIDATION` anchors。
- `Sources/Dashboard/Report/SimulatedExchangeParityEvidenceSurface.swift` 必须定义 `SimulatedExchangeParityEvidenceItem`、`SimulatedExchangeParityEvidenceReadModel`、`SimulatedExchangeParityEvidenceViewModel` 和 timeline entry，且只消费 MTP-112 至 MTP-115 deterministic Core evidence。
- Report ViewModel 必须展示 scenario id、dataset / fixture version、replay window、matching result、matching event、order id / type、partial / full / reject / expire outcomes、latency、fee、slippage、portfolio projection parity、report input version identity、source replay sequence 和 read-model-only boundary flags。
- Dashboard / Workbench 必须展示 parity evidence、outcomes、timeline、portfolio parity、cost parity metrics 和 no-command/no-trading/no-schema/no-runtime/no-adapter details。
- Events / Evidence Explorer 必须新增 `simulated exchange parity evidence` 只读 section，并输出 scenario、matching、fill summary、reject / expire、latency / cost、portfolio parity、report input / replay consistency timeline rows。
- App tests 必须覆盖 Report / Dashboard / Events wiring、Dashboard smoke `simulatedParityEvidence=1`、focused MTP-116 deterministic field snapshot、Codable round-trip、read-model-only boundary、无 command surface、无 order-level command UI、无交易按钮、无 signed endpoint / account endpoint / listenKey / broker / live capability。
- `docs/domain/context.md` 必须包含 `MTP-116-PARITY-EVIDENCE-READ-MODEL`、`MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE`、`MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT`、`MTP-116-READ-MODEL-ONLY-NO-COMMAND-SURFACE` 和 `MTP-116-NO-LIVE-BROKER-SIGNED-ENDPOINT`。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-116 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-116 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-116 contract、matrix、validation plan、domain context、latest summary、App source、Dashboard / Events source 和 focused test anchors。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不实现 matching runtime、order execution runtime、portfolio projection runtime、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console、order-level command UI 或交易按钮。

MTP-116 必须建立的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-116-PARITY-EVIDENCE-READ-MODEL`
- `MTP-116-REPORT-DASHBOARD-EVENTS-PARITY-SURFACE`
- `MTP-116-SCENARIO-MATCHING-FILL-COST-PORTFOLIO-SNAPSHOT`
- `MTP-116-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `MTP-116-NO-LIVE-BROKER-SIGNED-ENDPOINT`
- `MTP-116-SIMULATED-EXCHANGE-PARITY-SURFACE-VALIDATION`

## MTP-116 禁止

- 不实现 matching runtime、order execution runtime、portfolio projection runtime、真实 order command、order form、command model、Runtime replay job、database console 或 schema browser。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage read、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进下一 issue。

## MTP-117 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-27

执行者：Codex

MTP-117 的 required validation：

- `docs/contracts/simulated-exchange-backtest-parity-contract.md` 必须包含 `MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-CLOSEOUT`、`MTP-117-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-117-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-AUDIT-INPUT`、`MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION-EVIDENCE-CHAIN`、`MTP-117-FORBIDDEN-LIVE-CAPABILITY-EVIDENCE-CHAIN`、`MTP-117-L2-PARITY-EVIDENCE-COMPLETE` 和 `MTP-117-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/audit/inputs/mtpro-simulated-exchange-backtest-parity-v1-stage-audit-input.md` 必须记录 MTP-110 至 MTP-116 的 PR evidence、merge commit、required check、L2 parity validation evidence chain、forbidden live capability evidence chain、read-model-only boundary evidence、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-117 的当前 issue execution evidence，并明确 MTP-117 只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口，不输出最终 Stage Code Audit Report。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-117 issue backfill 和 MTP-117 Simulated Exchange / Backtest Parity 阶段收口说明，并指向 MTP-117 Stage Code Audit 输入材料。
- `docs/automation/automation-readiness.md` 必须新增 Simulated Exchange / Backtest Parity stage audit input anchor，确认该输入材料是 automation readiness 的已验证入口之一。
- `checks/automation-readiness.sh` 必须机械检查 MTP-110 至 MTP-117 的 contract、matrix、validation plan、latest summary、stage audit input、Core / App source anchors、Core / App deterministic test anchors、Dashboard smoke `simulatedParityEvidence` handle 和 forbidden capability boundary strings。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不修改 Linear status，不启动下一阶段 `symphony-issue`，不运行 Graphify，不修改 Figma，不输出最终 Stage Code Audit Report，不实现 signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、live runtime、live command、Live PRO Console、order-level command UI 或交易按钮。

MTP-117 必须收口的主要 anchors：

- `TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY`
- `MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-CLOSEOUT`
- `MTP-117-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-117-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-STAGE-AUDIT-INPUT`
- `MTP-117-SIMULATED-EXCHANGE-BACKTEST-PARITY-VALIDATION-EVIDENCE-CHAIN`
- `MTP-117-FORBIDDEN-LIVE-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-117-L2-PARITY-EVIDENCE-COMPLETE`
- `MTP-117-AUTOMATION-READINESS-STAGE-CLOSEOUT`

## MTP-117 禁止

- 不输出最终 Stage Code Audit Report，不创建 `docs/audit/mtpro-simulated-exchange-backtest-parity-v1-stage-code-audit.md`。
- 不设置 Linear Project `Completed`，不修改 Linear status，不创建下一 Project / Issue，不推进下一阶段。
- 不实现 matching runtime、order execution runtime、portfolio projection runtime、真实 order command、order form、command model、Runtime replay job、database console 或 schema browser。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live runtime、Live PRO Console、live command、order-level command UI 或交易按钮。
- 不运行 Graphify，不修改 Figma。

## MTP-118 Workbench Beta Readiness Contract / Acceptance Boundary Validation

日期：2026-05-27

执行者：Codex

MTP-118 的 required validation：

- `docs/contracts/workbench-beta-readiness-contract.md` 必须包含 `MTP-118-WORKBENCH-BETA-READINESS-TERMINOLOGY`、`MTP-118-BETA-ACCEPTANCE-BOUNDARY`、`MTP-118-LOCAL-ONLY-BETA-DEMO-PATH`、`MTP-118-L1-L15-L2-L2PLUS-HANDOFF`、`MTP-118-FORBIDDEN-CAPABILITY-BASELINE`、`MTP-118-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION` 和 `MTP-118-WORKBENCH-BETA-READINESS-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 Workbench Beta Readiness Terms 和 MTP-118 anchors，明确 beta readiness 是 local macOS Workbench demo / acceptance path，不是 production release 或 live readiness。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-WORKBENCH-BETA-READINESS` 和 MTP-118 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-118 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Workbench Beta Readiness contract anchor，确认 MTP-118 只是合同 / 边界入口，不实现 install / run、engine core、production release 或 live readiness。
- `checks/automation-readiness.sh` 必须机械检查 MTP-118 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。
- Required validation 仍是 `bash checks/run.sh`，不新增独立 eval 框架，不启动下一 issue，不运行 Graphify，不修改 Figma，不实现 install / run 逻辑，不新增 engine core capability，不实现 production release、notarization、App Store distribution、auto-update、production operations、signed endpoint、account endpoint / listenKey、broker、`LiveExecutionAdapter`、OMS、real order lifecycle、Live PRO Console、trading button 或 live command。

MTP-118 必须建立的主要 anchors：

- `TVM-WORKBENCH-BETA-READINESS`
- `MTP-118-WORKBENCH-BETA-READINESS-TERMINOLOGY`
- `MTP-118-BETA-ACCEPTANCE-BOUNDARY`
- `MTP-118-LOCAL-ONLY-BETA-DEMO-PATH`
- `MTP-118-L1-L15-L2-L2PLUS-HANDOFF`
- `MTP-118-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-118-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-118-WORKBENCH-BETA-READINESS-VALIDATION`

## MTP-118 禁止

- 不实现 install / run 逻辑、release package、production release、notarization、App Store distribution、auto-update、production operations、Core / Runtime / App / Dashboard behavior、Dashboard smoke handle、App read model 或 stage audit input。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不把 Workbench beta readiness 写成 production release、live readiness、production trading engine、production data platform、production matching runtime、真实 exchange runtime、broker / OMS readiness 或真实交易授权。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-119。

## MTP-119 Local Launch / Install / Environment Verification Validation

日期：2026-05-27

执行者：Codex

MTP-119 的 required validation：

- `docs/contracts/workbench-beta-readiness-contract.md` 必须包含 `MTP-119-LOCAL-LAUNCH-INSTALL-ENVIRONMENT-PATH`、`MTP-119-LOCAL-ENVIRONMENT-VERIFICATION`、`MTP-119-LOCAL-INSTALL-RUN-NOTES`、`MTP-119-LAUNCH-COMMAND-RUNBOOK`、`MTP-119-DASHBOARD-SMOKE-EXPECTATION`、`MTP-119-REPRODUCIBLE-LAUNCH-EVIDENCE`、`MTP-119-TROUBLESHOOTING-BOUNDARY` 和 `MTP-119-LOCAL-LAUNCH-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-119 local launch / install terms，明确 local install 只表示 SwiftPM dependency resolution 和本地 `.build` artifact。
- `docs/validation/macos-build-run-loop.md` 必须包含 MTP-119 local beta launch / install / environment verification path、Dashboard smoke expectation 和 troubleshooting boundary。
- `docs/validation/trading-validation-matrix.md` 必须包含 `MTP-119` issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-119 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须包含 Workbench Beta Readiness local launch / install anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-119 contract、domain context、macOS run-loop、validation plan、matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- Required validation 仍是 `bash checks/run.sh`，并补充 focused local smoke `DASHBOARD_SMOKE=1 swift run Dashboard` 作为 MTP-119 launch path evidence。

MTP-119 必须建立的主要 anchors：

- `MTP-119-LOCAL-LAUNCH-INSTALL-ENVIRONMENT-PATH`
- `MTP-119-LOCAL-ENVIRONMENT-VERIFICATION`
- `MTP-119-LOCAL-INSTALL-RUN-NOTES`
- `MTP-119-LAUNCH-COMMAND-RUNBOOK`
- `MTP-119-DASHBOARD-SMOKE-EXPECTATION`
- `MTP-119-REPRODUCIBLE-LAUNCH-EVIDENCE`
- `MTP-119-TROUBLESHOOTING-BOUNDARY`
- `MTP-119-LOCAL-LAUNCH-VALIDATION`

## MTP-119 禁止

- 不创建 production installer、release package、notarized artifact、App Store build、auto-update channel、production deployment 或 cloud operations workflow。
- 不新增 Dashboard smoke handle、不新增 App read model、不新增 Core / Runtime / Dashboard behavior、不新增 engine core capability、不新增 stage audit input。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不把 local launch / install path 写成 production release pipeline、notarization readiness、App Store distribution readiness、cloud operations readiness、live readiness 或真实交易授权。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-120。

## MTP-120 Demo Scenario Selection / Fixture Wiring Validation

日期：2026-05-27

执行者：Codex

MTP-120 的 required validation：

- `swift test --filter MTP120`
- `bash checks/run.sh`

MTP-120 必须建立的主要 anchors：

- `MTP-120-DEMO-SCENARIO-SELECTION`
- `MTP-120-DATASET-FIXTURE-VERSION-LOCK`
- `MTP-120-SCENARIO-REPLAY-FIXTURE-WIRING`
- `MTP-120-CHECKSUM-FRESHNESS-EVIDENCE`
- `MTP-120-L15-L2-EVIDENCE-RELATIONSHIP`
- `MTP-120-NO-NETWORK-DOWNLOAD-LIVE-BROKER`
- `MTP-120-DEMO-SCENARIO-FIXTURE-VALIDATION`

MTP-120 的验收要求：

- `Sources/Core/DashboardBetaDemoScenario.swift` 必须定义 `DashboardBetaDemoScenarioSelection` 和 `DashboardBetaDemoFixtureEvidence`，固定 `mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`。
- `DashboardBetaDemoFixtureEvidence` 必须复用 `ScenarioDataQualityReportInputEvidence.deterministicFixture` 和 `SimulatedExchangePortfolioProjectionParityFixture.deterministicEvidence()`，并输出 checksum `fnv1a64:3c6cd4ff13cd4062`、freshness `fresh`、quality `accepted`、report input version identity 和 simulated parity deterministic identity。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-120 focused tests，覆盖 deterministic selection、fixture wiring、L1.5 / L2 relationship、Codable round-trip、scenario mismatch rejection、automatic download / signed endpoint / broker bypass rejection。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-120 mechanical anchors。

## MTP-120 禁止

- 不新增 fixture records、不新增大规模 ingestion、不自动下载真实历史数据、不实现 production data platform、production dataset registry、production data quality monitor 或 Runtime replay scheduler。
- 不提前实现 Workbench first-run state、Report / Dashboard / Events acceptance path、Dashboard smoke handle、App read model、Runtime / Dashboard behavior 或 stage audit input。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-121。

## MTP-121 Workbench First-Run / Default Demo State Validation

日期：2026-05-27

执行者：Codex

MTP-121 的 required validation：

- `swift test --filter MTP121`
- `DASHBOARD_SMOKE=1 swift run Dashboard`
- `bash checks/run.sh`

MTP-121 必须建立的主要 anchors：

- `MTP-121-DEFAULT-SELECTED-SCENARIO`
- `MTP-121-READ-MODEL-ONLY-DASHBOARD-STATE`
- `MTP-121-FIRST-RUN-FALLBACK-STATES`
- `MTP-121-FIRST-RUN-EVIDENCE-SUMMARY`
- `MTP-121-DEMO-FIXTURE-ALIGNMENT`
- `MTP-121-NO-LIVE-PRO-CONSOLE-TRADING-COMMAND`
- `MTP-121-DASHBOARD-SMOKE-DEFAULT-DEMO-VALIDATION`

MTP-121 的验收要求：

- `Sources/Dashboard/DashboardBetaFirstRunState.swift` 必须定义 `DashboardBetaFirstRunReadModel`、`DashboardBetaFirstRunViewModel`、`DashboardBetaFirstRunEvidenceSummary` 和 `DashboardBetaFirstRunFallbackState`。
- First-run 默认状态必须选择 `mtp-104-btcusdt-1m-first-scenario`、`dataset-v1`、`fixture-v1`、`BTCUSDT` / `1m`，并输出 checksum `fnv1a64:3c6cd4ff13cd4062`、freshness `fresh`、quality `accepted` 和 report input version identity。
- `DashboardReadModel.defaultDashboardBetaDemo` 和 `DashboardViewModel.defaultDashboardBetaDemo` 必须通过 App Read Model / ViewModel 提供 first-run state，不直接暴露 Core fixture、Persistence schema、Runtime object 或 Adapter request。
- `Sources/Dashboard/DashboardApplication.swift` 必须使用 `DashboardViewModel.defaultDashboardBetaDemo`，使 `DASHBOARD_SMOKE=1 swift run Dashboard` 输出 `defaultDemoState=default demo`、`defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaFirstRunFallbacks=3`、`scenarioReplayEvidence=1` 和 `simulatedParityEvidence=1`。
- `Tests/AppTests/AppTests.swift` 必须包含 MTP-121 focused tests，覆盖 default selected scenario、read-model-only Dashboard state、empty / loading / error fallback、first-run evidence summary、Dashboard smoke handles 和 forbidden capability flags。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-121 mechanical anchors。

## MTP-121 禁止

- 不重设计 UI、不新增完整页面 redesign、不新增 MTP-122 Report / Dashboard / Events acceptance path、不新增 stage audit input。
- 不新增 fixture records、不新增大规模 ingestion、不自动下载真实历史数据、不实现 production data platform、production dataset registry、production data quality monitor 或 Runtime replay scheduler。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-122。

## MTP-122 Report / Dashboard / Events Beta Acceptance Path Validation

日期：2026-05-27

执行者：Codex

MTP-122 的 required validation：

- `swift test --filter MTP122`
- `DASHBOARD_SMOKE=1 swift run Dashboard`
- `bash checks/run.sh`

MTP-122 必须建立的主要 anchors：

- `MTP-122-REPORT-BETA-ACCEPTANCE-SUMMARY`
- `MTP-122-DASHBOARD-BETA-EVIDENCE-PANELS`
- `MTP-122-EVENTS-BETA-ACCEPTANCE-TRACE`
- `MTP-122-SAME-DEMO-SCENARIO-EVIDENCE`
- `MTP-122-SCENARIO-PARITY-PORTFOLIO-TRACE`
- `MTP-122-READ-MODEL-ONLY-NO-RUNTIME-COMMAND`
- `MTP-122-BETA-ACCEPTANCE-PATH-VALIDATION`

MTP-122 的验收要求：

- `Sources/Dashboard/DashboardBetaAcceptancePath.swift` 必须定义 `DashboardBetaAcceptancePathReadModel` 和 `DashboardBetaAcceptancePathViewModel`，只从 `ReportReadModel` 与 `DashboardBetaFirstRunReadModel.defaultDemo` 生成 acceptance path。
- Acceptance path 必须证明 Report、Dashboard 和 Events 使用同一 scenario `mtp-104-btcusdt-1m-first-scenario`、dataset `dataset-v1`、fixture `fixture-v1`、report input version `mtp-104-btcusdt-1m-first-scenario|dataset-v1|fixture-v1|1704067200...1704067380|fnv1a64:3c6cd4ff13cd4062|fresh|accepted`。
- `DashboardViewModel.defaultDashboardBetaDemo` 必须输出 `workbenchBetaAcceptancePath.acceptancePathCount=1`、Report summary、Dashboard panel summaries、Events trace 和 portfolio projection parity evidence。
- `Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift` 必须新增 `workbench beta acceptance path` section，输出 Report summary、Scenario Replay evidence、Simulated Exchange / Backtest Parity evidence、Portfolio evidence 和 boundary summary 五条 timeline rows。
- `Sources/Dashboard/DashboardShell.swift` 必须输出 Dashboard smoke handles `betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。
- `Tests/AppTests/AppTests.swift` 必须包含 MTP-122 focused test，覆盖 Report summary、Dashboard panels、Events trace、same demo scenario、portfolio evidence、validation anchors 和 forbidden capability flags。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-122 mechanical anchors。

## MTP-122 禁止

- 不新增 engine core capability、Runtime replay job、matching runtime、order execution runtime、portfolio projection runtime 或 production report engine。
- 不暴露 Persistence schema、database console、Runtime object inspector、Adapter request、Core object inspector 或 query surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不新增 stage audit input，不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-123。

## MTP-123 Reproducible Beta Acceptance Checklist / Script Validation

日期：2026-05-27

执行者：Codex

MTP-123 的 required validation：

- `bash checks/workbench-beta-acceptance.sh`
- `bash checks/run.sh`

MTP-123 必须建立的主要 anchors：

- `MTP-123-REPRODUCIBLE-BETA-ACCEPTANCE-WORKFLOW`
- `MTP-123-BETA-ACCEPTANCE-CHECKLIST`
- `MTP-123-LOCAL-COMMANDS-EXPECTED-OUTPUTS`
- `MTP-123-OPERATOR-REPRODUCIBILITY-EVIDENCE`
- `MTP-123-FAILURE-TRIAGE-HINTS`
- `MTP-123-NO-GRAPHIFY-FIGMA-PRODUCTION-OPS`
- `MTP-123-BETA-ACCEPTANCE-SCRIPT-VALIDATION`

MTP-123 的验收要求：

- `checks/workbench-beta-acceptance.sh` 必须复用现有 local commands：`uname -s`、`swift --version`、`swift package resolve`、`DASHBOARD_SMOKE=1 swift run Dashboard` 和 `bash checks/run.sh`。
- `docs/validation/workbench-beta-acceptance-checklist.md` 必须记录 operator checklist、local commands、expected outputs、operator reproducibility evidence、failure triage hints 和 boundary evidence。
- Script 必须校验 `sections=8`、`readModelOnly=true`、`workbenchReadModelOnly=true`、`defaultDemoScenario=mtp-104-btcusdt-1m-first-scenario`、`betaAcceptancePaths=1`、`betaAcceptanceScenario=mtp-104-btcusdt-1m-first-scenario` 和 `betaAcceptanceTrace=5`。
- Script 必须把 transcript 写入 `.codex/beta-acceptance/<run-id>/`，且这些本地 evidence 不进入 PR。
- `bash checks/run.sh` 仍是 PR 前最终 gate；MTP-123 script 不替代 CI 或 GitHub required check。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-123 mechanical anchors。

## MTP-123 禁止

- 不新增 engine core capability、Runtime replay job、matching runtime、order execution runtime、portfolio projection runtime、App read model 或 Dashboard behavior。
- 不暴露 Persistence schema、database console、Runtime object inspector、Adapter request、Core object inspector 或 query surface。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不新增 stage audit input，不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-124。

## MTP-124 Docs Index / Operator Guide Validation

日期：2026-05-27

执行者：Codex

MTP-124 的 required validation：

- `bash checks/run.sh`

MTP-124 必须建立的主要 anchors：

- `MTP-124-DOCS-INDEX`
- `MTP-124-OPERATOR-GUIDE`
- `MTP-124-DEMO-WORKFLOW-GUIDE`
- `MTP-124-KNOWN-LIMITATIONS`
- `MTP-124-FORBIDDEN-CAPABILITY-BOUNDARY`
- `MTP-124-TROUBLESHOOTING-POINTERS`
- `MTP-124-BETA-NOT-LIVE-READINESS`
- `MTP-124-ACCEPTANCE-WORKFLOW-REFERENCE`
- `MTP-124-DOCS-OPERATOR-GUIDE-VALIDATION`

MTP-124 的验收要求：

- `docs/index.md` 必须作为 docs index，指向 root docs、Workbench Beta Readiness operator guide、demo workflow guide、MTP-123 acceptance checklist / script 和 required validation。
- `docs/validation/workbench-beta-operator-guide.md` 必须记录 operator quick path、manual runbook、expected smoke handles、known limitations、forbidden capabilities、troubleshooting pointers 和 handoff evidence。
- `docs/validation/workbench-beta-demo-workflow-guide.md` 必须记录 MTP-119 至 MTP-123 demo workflow map、stable demo identity、evidence chain、operator demo steps、known limitations、forbidden boundary 和 troubleshooting pointers。
- `docs/contracts/workbench-beta-readiness-contract.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-124 mechanical anchors。
- Validation 必须证明 docs anchor、boundary text 和 acceptance workflow 引用完整，且文档不授权 production release、Live PRO Console、signed endpoint、account endpoint / listenKey、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、trading button 或 live command。

## MTP-124 禁止

- 不写 marketing landing page、不写 Live PRO Console docs、不写 production deployment guide、不写 notarization / App Store / auto-update guide。
- 不新增 production code、不新增 engine core capability、不新增 Runtime replay job、不新增 App read model、不新增 Dashboard behavior。
- 不新增 stage audit input；Project stage closeout 仍归属 MTP-125。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、live readiness、live runtime、Live PRO Console、trading button、live command、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不创建下一 Project / Issue，不推进 MTP-125。

## MTP-125 Automation Readiness / Validation Evidence / Stage Audit Input Validation

日期：2026-05-27

执行者：Codex

MTP-125 的 required validation：

- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-125 必须建立的主要 anchors：

- `MTP-125-WORKBENCH-BETA-READINESS-STAGE-CLOSEOUT`
- `MTP-125-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-125-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-125-WORKBENCH-BETA-READINESS-STAGE-AUDIT-INPUT`
- `MTP-125-WORKBENCH-BETA-READINESS-VALIDATION-EVIDENCE-CHAIN`
- `MTP-125-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-125-BETA-READINESS-EVIDENCE-COMPLETE`
- `MTP-125-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-125-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`
- `MTP-125-WORKBENCH-BETA-READINESS-CLOSEOUT-VALIDATION`

MTP-125 的验收要求：

- `docs/audit/inputs/mtpro-workbench-beta-readiness-v1-stage-audit-input.md` 必须存在，并包含 Linear queue evidence、PR #222 至 #228 evidence、merge commit、required check、Workbench Beta Readiness validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness evidence、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/contracts/workbench-beta-readiness-contract.md` 必须包含 MTP-125 closeout anchors，并明确 MTP-125 只准备 stage audit input material，不输出最终 Stage Code Audit Report。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-125 issue backfill，指向 `TVM-WORKBENCH-BETA-READINESS` 并说明 MTP-125 收口 validation matrix、automation readiness 和 stage audit input material。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-125 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Workbench Beta Readiness stage audit input anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-125 stage audit input、contract、validation plan、matrix、latest summary、automation readiness doc、PR evidence、Dashboard smoke handles 和 no Graphify / Figma / Linear mutation boundary。
- `verification.md` 必须 append-only 记录本地 validation result。

## MTP-125 禁止

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。
- 不修改 Linear status、不创建 Linear Project / Issue、不启动 `@002 / PAR`、不启动 Symphony / symphony-issue、不推进下一阶段。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不新增 production code、不新增 engine core capability、不新增 Runtime replay job、不新增 App read model、不新增 Dashboard behavior。
- 不创建 production release、release package、notarization、App Store distribution、auto-update、production deployment、cloud operations 或 production operations command。
- 不接 signed endpoint、account endpoint、listenKey、secret、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、real PnL、live readiness、live runtime、Live PRO Console、trading button、live command、order-level command UI、order form、emergency stop、shutdown 或 restore。

## MTP-126 Live Read-only Readiness Terminology / Boundary Validation

日期：2026-05-27

执行者：Codex

MTP-126 的 required validation：

- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-126 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY`、`MTP-126-TARGET-ENGINE-LAYER-BOUNDARY`、`MTP-126-L30-L31-L32-L33-HANDOFF`、`MTP-126-FORBIDDEN-CAPABILITY-BASELINE`、`MTP-126-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION` 和 `MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 Live read-only readiness terms 和 MTP-126 anchors，明确 L3.0 只定义 boundary，不实现 endpoint、secret、adapter、account read model、UI 或 live runtime。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-READ-ONLY-READINESS` 和 MTP-126 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-126 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only Readiness contract anchor，确认 MTP-126 只是合同 / 边界入口，不实现 L3.1 / L3.2 / L3.3 内容。
- `checks/automation-readiness.sh` 必须机械检查 MTP-126 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。

MTP-126 必须建立的主要 anchors：

- `TVM-LIVE-READ-ONLY-READINESS`
- `MTP-126-LIVE-READ-ONLY-READINESS-TERMINOLOGY`
- `MTP-126-TARGET-ENGINE-LAYER-BOUNDARY`
- `MTP-126-L30-L31-L32-L33-HANDOFF`
- `MTP-126-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-126-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-126-LIVE-READ-ONLY-READINESS-VALIDATION`

## MTP-126 禁止

- 不实现 API key / secret storage，不读取本地 secret。
- 不实现 signed endpoint、account endpoint、listenKey、private WebSocket runtime 或 account snapshot runtime。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不读取 real account、broker position、margin、leverage、real PnL 或 equity。
- 不实现 account / position / balance read model、Live Monitoring Console v2、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-127。

## MTP-127 Credential / Secret Policy and Endpoint Capability Taxonomy Validation

日期：2026-05-27

执行者：Codex

MTP-127 的 required validation：

- `swift test --filter LiveReadOnlyCredentialEndpointTaxonomy`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-127 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-127-CREDENTIAL-SECRET-POLICY-FUTURE-GATE`、`MTP-127-ENDPOINT-CAPABILITY-TAXONOMY`、`MTP-127-PUBLIC-READ-ONLY-PRIVATE-ENDPOINT-ISOLATION`、`MTP-127-FORBIDDEN-CAPABILITY-TESTS` 和 `MTP-127-LIVE-READ-ONLY-CREDENTIAL-ENDPOINT-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyCredentialEndpointTaxonomyBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、public read-only 唯一 allowed capability 和 forbidden endpoint taxonomy。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyCredentialEndpointTaxonomyDefinesMTP127FutureGates` 和 `testLiveReadOnlyCredentialEndpointTaxonomyRejectsSecretEndpointAndBrokerBypass`。
- `docs/domain/context.md` 必须包含 MTP-127 credential / endpoint taxonomy terms，明确 no secret read、no API key / secret storage、no signed/account/listenKey/private websocket/broker action。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-127 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-127 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only credential / endpoint taxonomy anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-127 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-127 必须建立的主要 anchors：

- `MTP-127-CREDENTIAL-SECRET-POLICY-FUTURE-GATE`
- `MTP-127-ENDPOINT-CAPABILITY-TAXONOMY`
- `MTP-127-PUBLIC-READ-ONLY-PRIVATE-ENDPOINT-ISOLATION`
- `MTP-127-FORBIDDEN-CAPABILITY-TESTS`
- `MTP-127-LIVE-READ-ONLY-CREDENTIAL-ENDPOINT-VALIDATION`

## MTP-127 禁止

- 不实现 API key / secret storage，不读取本地 secret。
- 不新增 env / keychain / config secret path，不实现 credential provider runtime。
- 不实现 signed request、signed endpoint、account endpoint、listenKey、private WebSocket runtime 或 account snapshot runtime。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`，不执行 broker action。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 account / position / balance read model、Live Monitoring Console v2、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-128。

## MTP-128 Adapter Capability Matrix Validation

日期：2026-05-27

执行者：Codex

MTP-128 的 required validation：

- `swift test --filter LiveReadOnlyAdapterCapabilityMatrix`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-128 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-128-ADAPTER-CAPABILITY-MATRIX`、`MTP-128-PUBLIC-READ-ONLY-ADAPTER-PRIVATE-GATE-ISOLATION`、`MTP-128-FORBIDDEN-ADAPTER-CAPABILITY-TESTS` 和 `MTP-128-LIVE-READ-ONLY-ADAPTER-CAPABILITY-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyAdapterCapabilityMatrixBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、public market data 唯一 allowed capability、future private account read-only gated capability 和 forbidden adapter capability matrix。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyAdapterCapabilityMatrixDefinesMTP128ReadOnlyBoundary` 和 `testLiveReadOnlyAdapterCapabilityMatrixRejectsWriteAndExecutionAdapterBypass`。
- `docs/domain/context.md` 必须包含 MTP-128 adapter matrix terms，明确 public read-only adapter 不能升级为 broker / exchange execution adapter。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-128 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-128 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only adapter capability matrix anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-128 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-128 必须建立的主要 anchors：

- `MTP-128-ADAPTER-CAPABILITY-MATRIX`
- `MTP-128-PUBLIC-READ-ONLY-ADAPTER-PRIVATE-GATE-ISOLATION`
- `MTP-128-FORBIDDEN-ADAPTER-CAPABILITY-TESTS`
- `MTP-128-LIVE-READ-ONLY-ADAPTER-CAPABILITY-VALIDATION`

## MTP-128 禁止

- 不创建 broker adapter、exchange execution adapter 或 `LiveExecutionAdapter`。
- 不把 public adapter 升级为 execution adapter。
- 不实现 signed endpoint、account endpoint / listenKey 或 private account read runtime。
- 不实现 real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 real account / broker position / margin / leverage runtime。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-129。

## MTP-129 Account / Position / Balance Read-model-only Future Gates Validation

日期：2026-05-27

执行者：Codex

MTP-129 的 required validation：

- `swift test --filter LiveReadOnlyAccountPositionBalance`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-129 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-129-ACCOUNT-POSITION-BALANCE-FUTURE-GATES`、`MTP-129-SOURCE-FRESHNESS-EVIDENCE-IDENTITY-BOUNDARY`、`MTP-129-FORBIDDEN-ACCOUNT-DATA-INTERPRETATION-TESTS` 和 `MTP-129-LIVE-READ-ONLY-ACCOUNT-POSITION-BALANCE-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyAccountPositionBalanceFutureGateBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、account / position / balance read-model-only future gates、source identity、snapshot freshness、evidence identity 和 forbidden account-data interpretation tests。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyAccountPositionBalanceFutureGatesDefineMTP129Boundary` 和 `testLiveReadOnlyAccountPositionBalanceFutureGatesRejectRealAccountAndFixtureBypass`。
- `docs/domain/context.md` 必须包含 MTP-129 account / position / balance shared language，明确 paper / simulated / fixture evidence 不能被解释为 real account data。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-129 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-129 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only account / position / balance future gate anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-129 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-129 必须建立的主要 anchors：

- `MTP-129-ACCOUNT-POSITION-BALANCE-FUTURE-GATES`
- `MTP-129-SOURCE-FRESHNESS-EVIDENCE-IDENTITY-BOUNDARY`
- `MTP-129-FORBIDDEN-ACCOUNT-DATA-INTERPRETATION-TESTS`
- `MTP-129-LIVE-READ-ONLY-ACCOUNT-POSITION-BALANCE-VALIDATION`

## MTP-129 禁止

- 不实现 account / position / balance read model runtime。
- 不读取 real account，不同步 broker position，不读取 real account balance、margin、leverage 或 real PnL。
- 不实现 signed endpoint、account endpoint / listenKey、private WebSocket 或 account snapshot runtime。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、trading button 或 live command。
- 不把 paper portfolio、simulated fill、fixture evidence、Report read model 或 Dashboard ViewModel 解释为真实 account / position / balance data。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-130。

## MTP-130 Private Stream / Account Snapshot Simulation Gate Input Validation

日期：2026-05-27

执行者：Codex

MTP-130 的 required validation：

- `swift test --filter LiveReadOnlyPrivateStreamAccountSnapshot`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-130 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-130-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE`、`MTP-130-FUTURE-FIXTURE-REQUIREMENTS`、`MTP-130-SIMULATION-GATE-LIVE-STREAM-ISOLATION`、`MTP-130-LISTENKEY-FORBIDDEN-TESTS` 和 `MTP-130-LIVE-READ-ONLY-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyPrivateStreamAccountSnapshotSimulationGateBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、private stream / account snapshot simulation gate input material、future fixture requirements、listenKey forbidden tests 和 simulation gate / live stream isolation。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyPrivateStreamAccountSnapshotDefinesMTP130SimulationGateInput` 和 `testLiveReadOnlyPrivateStreamAccountSnapshotRejectsListenKeyAndRuntimeBypass`。
- `docs/domain/context.md` 必须包含 MTP-130 private stream / account snapshot simulation gate shared language，明确 simulation gate input material 不能被解释为 live private stream implementation。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-130 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-130 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only private stream / account snapshot simulation gate anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-130 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture 和 focused test anchors。

MTP-130 必须建立的主要 anchors：

- `MTP-130-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE`
- `MTP-130-FUTURE-FIXTURE-REQUIREMENTS`
- `MTP-130-SIMULATION-GATE-LIVE-STREAM-ISOLATION`
- `MTP-130-LISTENKEY-FORBIDDEN-TESTS`
- `MTP-130-LIVE-READ-ONLY-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-VALIDATION`

## MTP-130 禁止

- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不运行 account snapshot runtime，不读取 real account 或 consumes real account payload。
- 不调用 signed endpoint、account endpoint / listenKey。
- 不同步 broker position，不读取 margin / leverage。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS 或 real order write。
- 不把 simulation gate input material 写成 live private stream implementation。
- 不把 fixture account snapshot 写成真实 account snapshot。
- 不新增 Live PRO Console、trading button 或 live command。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-131。

## MTP-131 Workbench Live Readiness Read-model-only Boundary Validation

日期：2026-05-27

执行者：Codex

MTP-131 的 required validation：

- `swift test --filter LiveReadOnlyWorkbench`
- `swift test --filter AppTests/testLiveReadOnlyDashboardBoundaryViewModelAggregatesMTP131ReadOnlySurface`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-131 的验收要求：

- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY`、`MTP-131-READ-MODEL-VIEWMODEL-INPUT-BOUNDARY`、`MTP-131-FORBIDDEN-UI-SURFACE`、`MTP-131-DETAIL-AUDIT-ROUTING`、`MTP-131-L31-L32-L33-HANDOFF` 和 `MTP-131-LIVE-READ-ONLY-WORKBENCH-VALIDATION` anchors。
- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `LiveReadOnlyWorkbenchReadModelBoundary` deterministic fixture，并固定 `TVM-LIVE-READ-ONLY-READINESS`、Workbench boundary surfaces、ReadModel / ViewModel input boundary、forbidden UI surface、detail / audit route、L3 handoff 和 forbidden flags。
- `Sources/Dashboard/FutureLiveProConsole/LiveReadOnlyDashboardBoundary.swift` 必须包含 `LiveReadOnlyDashboardBoundaryReadModel` 和 `LiveReadOnlyDashboardBoundaryViewModel`，只输出 read-model-only Dashboard / Report / Event Timeline evidence。
- `Sources/Dashboard/ReadModels/App.swift`、`Sources/Dashboard/DashboardShell.swift` 和 `Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift` 必须接入 MTP-131 read model / ViewModel、Dashboard shell metrics / details / smoke handle 和 Event Timeline evidence item。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveReadOnlyWorkbenchReadModelBoundaryDefinesMTP131Surface` 和 `testLiveReadOnlyWorkbenchReadModelBoundaryRejectsForbiddenUISurfaceBypass`。
- `Tests/AppTests/AppTests.swift` 必须包含 `testLiveReadOnlyDashboardBoundaryViewModelAggregatesMTP131ReadOnlySurface`，并覆盖 Dashboard shell、Report snapshot 和 Evidence Explorer read-only integration。
- `docs/domain/context.md` 必须包含 MTP-131 Workbench Live readiness shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-131 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-131 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only Dashboard read-model-only boundary anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-131 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、Core fixture、App read model / ViewModel、Dashboard shell、Event Timeline 和 focused test anchors。

MTP-131 必须建立的主要 anchors：

- `MTP-131-WORKBENCH-LIVE-READINESS-READ-MODEL-ONLY-BOUNDARY`
- `MTP-131-READ-MODEL-VIEWMODEL-INPUT-BOUNDARY`
- `MTP-131-FORBIDDEN-UI-SURFACE`
- `MTP-131-DETAIL-AUDIT-ROUTING`
- `MTP-131-L31-L32-L33-HANDOFF`
- `MTP-131-LIVE-READ-ONLY-WORKBENCH-VALIDATION`

## MTP-131 禁止

- 不新增 API key input、secret storage、local secret read 或 credential provider。
- 不新增 broker connect、account connect、Live PRO Console、trading button、live command 或 order form。
- 不调用 signed endpoint、account endpoint / listenKey，不创建 private WebSocket。
- 不读取 real account balance、broker position、margin、leverage、real PnL 或 account payload。
- 不暴露 Runtime object、database schema、Persistence schema、ORM model 或 adapter request。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不提交、取消或替换真实订单，不授权 broker action 或 production operation。
- 不运行 Graphify，不修改 Figma，不修改 Linear status，不推进 MTP-132。

## MTP-132 Automation Readiness / Validation Matrix / Stage Audit Input Validation

日期：2026-05-27

执行者：Codex

MTP-132 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-132 的验收要求：

- `docs/audit/inputs/mtpro-live-read-only-readiness-boundary-v1-stage-audit-input.md` 必须存在，并包含 `MTP-132-LIVE-READ-ONLY-READINESS-STAGE-CLOSEOUT`、`MTP-132-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-132-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-132-LIVE-READ-ONLY-READINESS-STAGE-AUDIT-INPUT`、`MTP-132-LIVE-READ-ONLY-READINESS-VALIDATION-EVIDENCE-CHAIN`、`MTP-132-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-132-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`、`MTP-132-AUTOMATION-READINESS-STAGE-CLOSEOUT` 和 `MTP-132-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION` anchors。
- `docs/contracts/live-read-only-readiness-boundary-contract.md` 必须包含 `MTP-132-LIVE-READ-ONLY-READINESS-STAGE-CLOSEOUT`、`MTP-132-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-132-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-132-LIVE-READ-ONLY-READINESS-VALIDATION-EVIDENCE-CHAIN`、`MTP-132-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN` 和 `MTP-132-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-132 issue backfill，并指向 MTP-132 Stage Code Audit 输入材料。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-132 的当前 issue execution evidence，明确只做 Project 级 validation matrix、automation readiness 和 stage audit input material 收口。
- `docs/automation/automation-readiness.md` 必须新增 Live Read-only Readiness stage audit input anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-126 至 MTP-132 的 contract、matrix、validation plan、latest summary、automation readiness doc、stage audit input、Core / App source anchors、Core / App deterministic test anchors 和 Dashboard smoke `liveReadOnlyWorkbenchBoundary`。
- Stage Audit input 必须明确：最终 Stage Code Audit Report 仍由 Parent Codex 在 `MTP-126` 至 `MTP-132` 全部 Done、Linear Project status `Completed` 且 `completedAt` 非空后单独输出。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-132 必须建立的主要 anchors：

- `MTP-132-LIVE-READ-ONLY-READINESS-STAGE-CLOSEOUT`
- `MTP-132-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-132-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-132-LIVE-READ-ONLY-READINESS-STAGE-AUDIT-INPUT`
- `MTP-132-LIVE-READ-ONLY-READINESS-VALIDATION-EVIDENCE-CHAIN`
- `MTP-132-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-132-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-132-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-132-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

## MTP-132 禁止

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed` 后单独输出。
- 不修改 Linear status、不创建 Linear Project / Issue、不启动 `@002 / PAR`、不启动 Symphony / symphony-issue、不推进下一阶段。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不新增 production code、不新增 Live read-only runtime、不新增 account / position / balance runtime、不新增 private stream runtime、不新增 Dashboard command surface。
- 不实现 API key / secret storage，不读取本地 secret，不新增 env / keychain / config secret path。
- 不接 signed endpoint、account endpoint、listenKey、private WebSocket、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account balance、broker position、margin、leverage、real PnL、Live Monitoring Console v2 runtime、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。

## MTP-133 Account / Position / Balance Read-model-only Terminology Validation

日期：2026-05-28

执行者：Codex

MTP-133 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-133 的验收要求：

- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须存在，并包含 `MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-TERMINOLOGY`、`MTP-133-SOURCE-SEMANTICS-BOUNDARY`、`MTP-133-EVIDENCE-INTERPRETATION-BOUNDARY`、`MTP-133-L31-L32-HANDOFF-BOUNDARY`、`MTP-133-FORBIDDEN-CAPABILITY-BASELINE`、`MTP-133-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION` 和 `MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-133 account / position / balance read-model-only shared language，明确 fixture / paper / simulated evidence 不等于真实账户、broker position、margin、leverage 或 real PnL。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY` 和 MTP-133 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-133 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Account / Position / Balance read-model-only terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-133 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-133 必须建立的主要 anchors：

- `MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-TERMINOLOGY`
- `MTP-133-SOURCE-SEMANTICS-BOUNDARY`
- `MTP-133-EVIDENCE-INTERPRETATION-BOUNDARY`
- `MTP-133-L31-L32-HANDOFF-BOUNDARY`
- `MTP-133-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-133-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-133-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY-VALIDATION`

## MTP-133 禁止

- 不实现 account / position / balance runtime、Live read-only runtime、private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、margin、leverage、buying power 或 real PnL。
- 不接 signed endpoint、account endpoint / listenKey、private WebSocket、broker / exchange execution adapter 或 `LiveExecutionAdapter`。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不推进 MTP-134，不创建下一 Project / Issue。

## MTP-134 Account Snapshot Identity / Freshness Evidence Validation

日期：2026-05-28

执行者：Codex

MTP-134 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-134 的验收要求：

- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-134-ACCOUNT-SNAPSHOT-IDENTITY`、`MTP-134-SOURCE-IDENTITY-FRESHNESS-EVIDENCE`、`MTP-134-STALE-MISSING-BLOCKED-ACCOUNT-EVIDENCE`、`MTP-134-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`、`MTP-134-ACCOUNT-SNAPSHOT-NOT-RUNTIME` 和 `MTP-134-ACCOUNT-SNAPSHOT-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-134 account snapshot identity shared language，明确 account snapshot identity 是 evidence identity，不是 runtime snapshot。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-134 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-134 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Account snapshot identity / freshness evidence anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-134 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-134 必须建立的主要 anchors：

- `MTP-134-ACCOUNT-SNAPSHOT-IDENTITY`
- `MTP-134-SOURCE-IDENTITY-FRESHNESS-EVIDENCE`
- `MTP-134-STALE-MISSING-BLOCKED-ACCOUNT-EVIDENCE`
- `MTP-134-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`
- `MTP-134-ACCOUNT-SNAPSHOT-NOT-RUNTIME`
- `MTP-134-ACCOUNT-SNAPSHOT-IDENTITY-VALIDATION`

## MTP-134 禁止

- 不实现 account snapshot runtime、Live read-only runtime、private stream runtime 或 account endpoint runtime。
- 不调用 account endpoint，不创建 listenKey，不读取 secret，不连接 private WebSocket。
- 不读取真实账户余额、margin、leverage、buying power 或 real PnL。
- 不新增 secret storage、credential provider、signed request、signed endpoint、broker connection、broker adapter 或 `LiveExecutionAdapter`。
- 不暴露 exchange payload、broker payload、Runtime object 或 Adapter request 给 UI。
- 不实现 OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不新增 account fixture payload、不新增 App surface、不新增 Dashboard smoke handle；fixture contract 仍归属 MTP-137，Workbench / Report / Events surface 仍归属 MTP-138。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-135 Position Snapshot Identity / Exposure Evidence Validation

日期：2026-05-28

执行者：Codex

MTP-135 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-135 的验收要求：

- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-135-POSITION-SNAPSHOT-IDENTITY`、`MTP-135-POSITION-EXPOSURE-EVIDENCE`、`MTP-135-PAPER-SIMULATED-FUTURE-REAL-POSITION-ISOLATION`、`MTP-135-STALE-BLOCKED-SIMULATED-POSITION-EVIDENCE`、`MTP-135-FORBIDDEN-BROKER-POSITION-INTERPRETATION` 和 `MTP-135-POSITION-SNAPSHOT-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-135 position snapshot identity shared language，明确 position evidence 不能表示 broker position。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-135 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-135 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Position snapshot identity / exposure evidence anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-135 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-135 必须建立的主要 anchors：

- `MTP-135-POSITION-SNAPSHOT-IDENTITY`
- `MTP-135-POSITION-EXPOSURE-EVIDENCE`
- `MTP-135-PAPER-SIMULATED-FUTURE-REAL-POSITION-ISOLATION`
- `MTP-135-STALE-BLOCKED-SIMULATED-POSITION-EVIDENCE`
- `MTP-135-FORBIDDEN-BROKER-POSITION-INTERPRETATION`
- `MTP-135-POSITION-SNAPSHOT-IDENTITY-VALIDATION`

## MTP-135 禁止

- 不同步 broker position。
- 不读取 real position、margin、leverage、real account balance、broker portfolio 或 real PnL。
- 不实现 broker adapter、account endpoint、listenKey、private stream、private WebSocket runtime、account snapshot runtime 或 live risk engine。
- 不把 paper portfolio projection、simulated fill 或 simulated exchange exposure 升级为 real position、broker fill、execution report 或 reconciliation。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace。
- 不新增 Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不新增 position fixture payload、不新增 App surface、不新增 Dashboard smoke handle；fixture contract 仍归属 MTP-137，Workbench / Report / Events surface 仍归属 MTP-138。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-136 Balance Snapshot Identity / Paper-vs-real Boundary Validation

日期：2026-05-28

执行者：Codex

MTP-136 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-136 的验收要求：

- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-136-BALANCE-SNAPSHOT-IDENTITY`、`MTP-136-PAPER-SIMULATED-FUTURE-REAL-BALANCE-TERMINOLOGY`、`MTP-136-PAPER-VS-REAL-INTERPRETATION-BOUNDARY`、`MTP-136-REAL-PNL-MARGIN-LEVERAGE-BUYING-POWER-FORBIDDEN`、`MTP-136-BALANCE-STALE-BLOCKED-EVIDENCE` 和 `MTP-136-BALANCE-SNAPSHOT-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-136 balance snapshot identity shared language，明确 balance evidence 是 read-model-only evidence，不是 live account balance。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-136 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-136 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Balance snapshot identity / paper-vs-real boundary anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-136 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-136 必须建立的主要 anchors：

- `MTP-136-BALANCE-SNAPSHOT-IDENTITY`
- `MTP-136-PAPER-SIMULATED-FUTURE-REAL-BALANCE-TERMINOLOGY`
- `MTP-136-PAPER-VS-REAL-INTERPRETATION-BOUNDARY`
- `MTP-136-REAL-PNL-MARGIN-LEVERAGE-BUYING-POWER-FORBIDDEN`
- `MTP-136-BALANCE-STALE-BLOCKED-EVIDENCE`
- `MTP-136-BALANCE-SNAPSHOT-IDENTITY-VALIDATION`

## MTP-136 禁止

- 不读取真实账户余额。
- 不实现 real PnL runtime。
- 不读取 margin、leverage、buying power 或 broker cash statement。
- 不接 signed endpoint、account endpoint、listenKey、private stream 或 private WebSocket runtime。
- 不连接 broker，不实现 account snapshot runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不把 paper account model 输出解释为真实账户余额、可交易资金、broker equity、margin equity 或 buying power。
- 不新增 Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore。
- 不新增 balance fixture payload、不新增 App surface、不新增 Dashboard smoke handle；fixture contract 仍归属 MTP-137，Workbench / Report / Events surface 仍归属 MTP-138。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-137 Fixture / Forbidden Real Account Tests Validation

日期：2026-05-28

执行者：Codex

MTP-137 的 required validation：

- `swift test --filter AccountPositionBalanceReadModelOnlyFixture`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-137 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `AccountPositionBalanceReadModelOnlyFixtureContract`、`AccountPositionBalanceReadModelOnlyFixtureRecord`、`AccountPositionBalanceReadModelOnlyForbiddenCapability` 和 deterministic fixture checksum / freshness / source identity validation。
- `Tests/CoreTests/CoreTests.swift` 必须包含 MTP-137 deterministic fixture contract、forbidden real account bypass 和 payload / schema / runtime mapping isolation tests。
- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-137-DETERMINISTIC-FIXTURE-SHAPE`、`MTP-137-FIXTURE-CHECKSUM-FRESHNESS-SOURCE`、`MTP-137-FORBIDDEN-REAL-ACCOUNT-TESTS`、`MTP-137-FIXTURE-TO-READ-MODEL-MAPPING-ISOLATION`、`MTP-137-REAL-ACCOUNT-PAYLOAD-ISOLATION` 和 `MTP-137-FIXTURE-FORBIDDEN-REAL-ACCOUNT-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-137 fixture / forbidden real account tests shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-137 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-137 当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Account / Position / Balance fixture / forbidden real account tests anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-137 source、test、contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-137 必须建立的主要 anchors：

- `MTP-137-DETERMINISTIC-FIXTURE-SHAPE`
- `MTP-137-FIXTURE-CHECKSUM-FRESHNESS-SOURCE`
- `MTP-137-FORBIDDEN-REAL-ACCOUNT-TESTS`
- `MTP-137-FIXTURE-TO-READ-MODEL-MAPPING-ISOLATION`
- `MTP-137-REAL-ACCOUNT-PAYLOAD-ISOLATION`
- `MTP-137-FIXTURE-FORBIDDEN-REAL-ACCOUNT-VALIDATION`

## MTP-137 禁止

- 不实现真实账户 fixture importer。
- 不导入 broker payload。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不连接 private WebSocket。
- 不实现 account snapshot runtime。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不读取真实账户、broker position、real PnL、margin 或 leverage。
- 不暴露 payload、schema、Runtime object、adapter request 或 account endpoint response。
- 不新增 App surface、不新增 Dashboard smoke handle；Workbench / Report / Events surface 仍归属 MTP-138。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-138 Workbench / Report / Events Read-model-only Surface Validation

日期：2026-05-28

执行者：Codex

MTP-138 的 required validation：

- `swift test --filter AccountPositionBalanceReadModelOnlySurface`
- `swift test --filter PaperWorkflowEvidenceExplorerTimelineSnapshotAggregatesReadModelOnlyEvidence`
- `swift test --filter DashboardShellWorkbenchSnapshotBindsControlsObservabilityAndExplorerReadOnly`
- `git diff --check`
- `bash checks/run.sh`

MTP-138 的验收要求：

- `Sources/Dashboard/Report/AccountPositionBalanceReadModelOnlySurface.swift` 必须包含 `AccountPositionBalanceReadModelOnlySurfaceReadModel`、`AccountPositionBalanceReadModelOnlySurfaceViewModel` 和 `AccountPositionBalanceReadModelOnlySurfaceTraceItem`。
- `Sources/Dashboard/ReadModels/App.swift` 必须把 APB surface 接入 `ReportReadModel`、`ReportViewModel` 和 `DashboardViewModel` read-model-only source chain。
- `Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift` 必须新增 `accountPositionBalanceReadModelOnlySurface` section、coverage flag 和三条 APB timeline items。
- `Sources/Dashboard/DashboardShell.swift` 必须在 Workbench、Report 和 Dashboard smoke 中展示 APB read-model-only evidence。
- `Tests/AppTests/AppTests.swift` 必须覆盖 ViewModel、Workbench metrics / details、Report APB details、Event Timeline APB section 和 forbidden UI / runtime flags。
- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 `MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`、`MTP-138-DASHBOARD-REPORT-EVENTS-EVIDENCE`、`MTP-138-FORBIDDEN-UI-RUNTIME-SURFACE` 和 `MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-138 Workbench / Report / Events read-model-only surface shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-138 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Account / Position / Balance Workbench / Report / Events read-model-only surface anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-138 source、test、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-138 必须建立的主要 anchors：

- `MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`
- `MTP-138-DASHBOARD-REPORT-EVENTS-EVIDENCE`
- `MTP-138-FORBIDDEN-UI-RUNTIME-SURFACE`
- `MTP-138-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-VALIDATION`

## MTP-138 禁止

- 不实现 account / position / balance runtime。
- 不读取真实账户、broker position、real PnL、margin 或 leverage。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不连接 private WebSocket。
- 不实现 account snapshot runtime。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不暴露 account endpoint payload、broker payload、schema、Runtime object、adapter request 或 broker state。
- 不新增 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command 或 order form。
- 不推进 MTP-139。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-139 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-28

执行者：Codex

MTP-139 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-139 的验收要求：

- `docs/audit/inputs/mtpro-account-position-balance-read-model-only-v1-stage-audit-input.md` 必须存在，并包含 `MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT`、`MTP-139-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-139-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-AUDIT-INPUT`、`MTP-139-VALIDATION-EVIDENCE-CHAIN`、`MTP-139-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-139-READ-MODEL-ONLY-BOUNDARY-EVIDENCE` 和 `MTP-139-AUTOMATION-READINESS-STAGE-CLOSEOUT` anchors。
- `docs/contracts/account-position-balance-read-model-only-contract.md` 必须包含 MTP-139 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、automation readiness stage closeout 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-139 stage closeout shared language。
- `docs/validation/trading-validation-matrix.md` 必须把 MTP-139 回填到 `TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY`。
- `docs/automation/automation-readiness.md` 必须新增 Account / Position / Balance stage audit input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-139 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-139 input、contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc、MTP-133 至 MTP-138 PR evidence 和 Dashboard smoke `accountPositionBalanceEvidence=3` handle。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-139 必须建立的主要 anchors：

- `MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT`
- `MTP-139-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-139-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-AUDIT-INPUT`
- `MTP-139-VALIDATION-EVIDENCE-CHAIN`
- `MTP-139-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-139-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-139-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-139-ACCOUNT-POSITION-BALANCE-STAGE-CLOSEOUT-VALIDATION`

## MTP-139 禁止

- 不输出最终 Stage Code Audit Report。
- 不创建 `docs/audit/mtpro-account-position-balance-read-model-only-v1-stage-code-audit.md`。
- 不设置 Linear Project `Completed`，不写 Root Docs Refresh Gate。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard behavior。
- 不实现 account / position / balance runtime。
- 不读取真实账户、broker position、real PnL、margin 或 leverage。
- 不调用 signed endpoint、account endpoint 或 listenKey。
- 不连接 private WebSocket。
- 不实现 account snapshot runtime。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS 或 real order lifecycle。
- 不新增 API key input、secret storage、broker connect、account connect、Live PRO Console、trading button、live command 或 order form。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-140 Private Stream / Account Snapshot Simulation Gate Terminology Validation

日期：2026-05-29

执行者：Codex

MTP-140 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-140 的验收要求：

- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-140-PRIVATE-STREAM-SIMULATION-GATE-TERMINOLOGY`、`MTP-140-ACCOUNT-SNAPSHOT-SIMULATION-GATE-TERMINOLOGY`、`MTP-140-FIXTURE-SIMULATED-FUTURE-REAL-PRIVATE-STREAM-BOUNDARY`、`MTP-140-L31-APB-L32-SIMULATION-GATE-RELATIONSHIP`、`MTP-140-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`、`MTP-140-FORBIDDEN-CAPABILITY-BASELINE` 和 `MTP-140-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-140 private stream / account snapshot simulation gate shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE` 和 MTP-140 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate terminology anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-140 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-140 contract、domain context、validation plan、trading matrix、latest summary、automation readiness doc 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-140 必须建立的主要 anchors：

- `MTP-140-PRIVATE-STREAM-SIMULATION-GATE-TERMINOLOGY`
- `MTP-140-ACCOUNT-SNAPSHOT-SIMULATION-GATE-TERMINOLOGY`
- `MTP-140-FIXTURE-SIMULATED-FUTURE-REAL-PRIVATE-STREAM-BOUNDARY`
- `MTP-140-L31-APB-L32-SIMULATION-GATE-RELATIONSHIP`
- `MTP-140-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-140-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-140-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE-VALIDATION`

## MTP-140 禁止

- 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard behavior。
- 不实现 private WebSocket runtime 或 private stream runtime。
- 不实现 account snapshot runtime 或 account / position / balance runtime。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不调用 signed endpoint 或 account endpoint。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不推进 MTP-141，不输出 stage audit input。

## MTP-141 Simulated Private Account Event Source Identity Validation

日期：2026-05-29

执行者：Codex

MTP-141 的 required validation：

- `swift test --filter SimulatedPrivateAccountEventSourceIdentity`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-141 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedPrivateAccountEventSourceIdentityContract`、`SimulatedPrivateAccountEventSourceIdentityRecord`、`SimulatedPrivateAccountEventSourceKind` 和 `SimulatedPrivateAccountEventSourceForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testSimulatedPrivateAccountEventSourceIdentityDefinesMTP141DeterministicSource` 和 `testSimulatedPrivateAccountEventSourceIdentityRejectsMTP141ForbiddenLiveSourceBypass`。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`、`MTP-141-FIXTURE-SCENARIO-VERSION-CHECKSUM-FRESHNESS-LINKAGE`、`MTP-141-FUTURE-REAL-PRIVATE-STREAM-LABEL-GATE`、`MTP-141-FORBIDDEN-LIVE-STREAM-SOURCE-TESTS`、`MTP-141-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD` 和 `MTP-141-SOURCE-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-141 source identity shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-141 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate source identity anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-141 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-141 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-141 必须建立的主要 anchors：

- `MTP-141-SIMULATED-PRIVATE-ACCOUNT-EVENT-SOURCE-IDENTITY`
- `MTP-141-FIXTURE-SCENARIO-VERSION-CHECKSUM-FRESHNESS-LINKAGE`
- `MTP-141-FUTURE-REAL-PRIVATE-STREAM-LABEL-GATE`
- `MTP-141-FORBIDDEN-LIVE-STREAM-SOURCE-TESTS`
- `MTP-141-ADAPTER-CAPABILITY-MATRIX-BYPASS-GUARD`
- `MTP-141-SOURCE-IDENTITY-VALIDATION`

## MTP-141 禁止

- 不创建 listenKey，不执行 listenKey keepalive。
- 不连接 private WebSocket，不实现 private stream runtime。
- 不调用 signed endpoint 或 account endpoint。
- 不实现 account snapshot runtime 或 simulated account snapshot input contract；MTP-142 才能深化 snapshot input shape。
- 不读取真实 account payload 或 broker payload。
- 不暴露 Adapter request、SQLite / DuckDB schema 或 Runtime object。
- 不绕过 adapter capability matrix。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-142 Simulated Account Snapshot Input Contract Validation

日期：2026-05-29

执行者：Codex

MTP-142 的 required validation：

- `swift test --filter SimulatedAccountSnapshotInput`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-142 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedAccountSnapshotInputContract`、`SimulatedAccountSnapshotInputRecord`、`SimulatedAccountSnapshotInputState` 和 `SimulatedAccountSnapshotInputForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testSimulatedAccountSnapshotInputDefinesMTP142DeterministicContract`、`testSimulatedAccountSnapshotInputRejectsMTP142EndpointRuntimeAndPayloadBypass` 和 `testSimulatedAccountSnapshotInputRejectsMTP142PayloadSchemaRuntimeMapping`。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-SHAPE`、`MTP-142-SNAPSHOT-ID-SOURCE-OBSERVEDAT-FRESHNESS-STATE`、`MTP-142-FIXTURE-VERSION-CHECKSUM-DETERMINISTIC-REPLAY-LINKAGE`、`MTP-142-FIXTURE-TO-READ-MODEL-MAPPING-BOUNDARY`、`MTP-142-ACCOUNT-PAYLOAD-ISOLATION-TESTS` 和 `MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-142 simulated account snapshot input shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-142 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate snapshot input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-142 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-142 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-142 必须建立的主要 anchors：

- `MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-SHAPE`
- `MTP-142-SNAPSHOT-ID-SOURCE-OBSERVEDAT-FRESHNESS-STATE`
- `MTP-142-FIXTURE-VERSION-CHECKSUM-DETERMINISTIC-REPLAY-LINKAGE`
- `MTP-142-FIXTURE-TO-READ-MODEL-MAPPING-BOUNDARY`
- `MTP-142-ACCOUNT-PAYLOAD-ISOLATION-TESTS`
- `MTP-142-SIMULATED-ACCOUNT-SNAPSHOT-INPUT-VALIDATION`

## MTP-142 禁止

- 不实现 account snapshot runtime 或 private stream runtime。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不调用 signed endpoint 或 account endpoint。
- 不读取真实账户、真实余额、margin、leverage 或 real PnL。
- 不暴露 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不新增 App、Dashboard、Workbench、Report 或 Events behavior；MTP-145 才能深化 read-model-only surface。
- 不定义 balance / position update fixture semantics；MTP-143 才能深化该 scope。
- 不深化 freshness / stale / blocked forbidden endpoint tests；MTP-144 才能深化该 scope。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-143 Simulated Account Snapshot Update Fixture Validation

日期：2026-05-29

执行者：Codex

MTP-143 的 required validation：

- `swift test --filter SimulatedAccountSnapshotUpdateFixture`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-143 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedAccountSnapshotUpdateFixture`、`SimulatedAccountSnapshotUpdateFixtureRecord`、`SimulatedAccountSnapshotUpdateFixtureKind`、`SimulatedAccountSnapshotUpdateInterpretationBoundary` 和 `SimulatedAccountSnapshotUpdateFixtureForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testSimulatedAccountSnapshotUpdateFixtureDefinesMTP143DeterministicContract` 和 `testSimulatedAccountSnapshotUpdateFixtureRejectsMTP143RealAccountBrokerPnLBypass`。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-SEMANTICS`、`MTP-143-MTP141-MTP142-LINKAGE-CHECKSUM-BOUNDARY`、`MTP-143-BALANCE-POSITION-UPDATE-READ-MODEL-ONLY-BOUNDARY`、`MTP-143-UPDATE-FIXTURE-INTERPRETATION-ISOLATION-TESTS` 和 `MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-143 simulated account snapshot update fixture shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-143 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate update fixture anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-143 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-143 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-143 必须建立的主要 anchors：

- `MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-SEMANTICS`
- `MTP-143-MTP141-MTP142-LINKAGE-CHECKSUM-BOUNDARY`
- `MTP-143-BALANCE-POSITION-UPDATE-READ-MODEL-ONLY-BOUNDARY`
- `MTP-143-UPDATE-FIXTURE-INTERPRETATION-ISOLATION-TESTS`
- `MTP-143-SIMULATED-ACCOUNT-SNAPSHOT-UPDATE-FIXTURE-VALIDATION`

## MTP-143 禁止

- 不实现 account snapshot runtime 或 private stream runtime。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不调用 signed endpoint 或 account endpoint。
- 不读取真实账户、真实余额、真实持仓、broker position、margin、leverage 或 real PnL。
- 不把 balance update fixture 或 position update fixture 解释为真实余额更新、真实持仓更新、broker position sync、execution report、broker fill 或 reconciliation。
- 不暴露 account endpoint payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 App、Dashboard、Workbench、Report 或 Events behavior；MTP-145 才能深化 read-model-only surface。
- 不深化 freshness / stale / blocked forbidden endpoint tests；MTP-144 才能深化该 scope。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-144 Simulated Account Snapshot Freshness Evidence Validation

日期：2026-05-30

执行者：Codex

MTP-144 的 required validation：

- `swift test --filter SimulatedAccountSnapshotFreshnessEvidence`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-144 的验收要求：

- `Sources/Core/LiveTradingBoundary.swift` 必须包含 `SimulatedAccountSnapshotFreshnessEvidenceContract`、`SimulatedAccountSnapshotFreshnessEvidenceItem`、`SimulatedAccountSnapshotFreshnessEvidenceStatus` 和 `SimulatedAccountSnapshotFreshnessEvidenceForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testSimulatedAccountSnapshotFreshnessEvidenceDefinesMTP144DeterministicStates`、`testSimulatedAccountSnapshotFreshnessEvidenceRejectsMTP144EndpointRuntimeAndBrokerBypass` 和 `testSimulatedAccountSnapshotFreshnessEvidenceRejectsMTP144PayloadSchemaRuntimeExposure`。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 `MTP-144-FRESHNESS-STALE-BLOCKED-MISSING-EVIDENCE`、`MTP-144-MTP141-MTP142-MTP143-FRESHNESS-CHECKSUM-BOUNDARY`、`MTP-144-FORBIDDEN-ENDPOINT-RUNTIME-TESTS`、`MTP-144-PAYLOAD-SCHEMA-RUNTIME-NON-EXPOSURE-TESTS` 和 `MTP-144-SIMULATED-ACCOUNT-SNAPSHOT-FRESHNESS-EVIDENCE-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-144 simulated account snapshot freshness evidence shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-144 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate freshness evidence anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-144 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-144 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-144 必须建立的主要 anchors：

- `MTP-144-FRESHNESS-STALE-BLOCKED-MISSING-EVIDENCE`
- `MTP-144-MTP141-MTP142-MTP143-FRESHNESS-CHECKSUM-BOUNDARY`
- `MTP-144-FORBIDDEN-ENDPOINT-RUNTIME-TESTS`
- `MTP-144-PAYLOAD-SCHEMA-RUNTIME-NON-EXPOSURE-TESTS`
- `MTP-144-SIMULATED-ACCOUNT-SNAPSHOT-FRESHNESS-EVIDENCE-VALIDATION`

## MTP-144 禁止

- 不实现 account snapshot runtime、private stream runtime 或 freshness runtime。
- 不创建 listenKey，不执行 listenKey keepalive。
- 不调用 signed endpoint 或 account endpoint。
- 不读取真实账户、真实余额、真实持仓、broker position、margin、leverage 或 real PnL。
- 不暴露 account endpoint payload、real account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不连接 broker / exchange execution adapter。
- 不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 App、Dashboard、Workbench、Report 或 Events behavior；MTP-145 才能深化 read-model-only surface。
- 不新增 Live PRO Console、trading button、live command、order form、account connect 或 broker connect。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-145 Workbench / Report / Events Read-model-only Simulation Gate Evidence Surface Validation

日期：2026-05-30

执行者：Codex

MTP-145 的 required validation：

- `swift test --filter PrivateStreamSimulationGateEvidenceSurface`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-145 的验收要求：

- `Sources/Dashboard/Report/PrivateStreamSimulationGateEvidenceSurface.swift` 必须包含 `PrivateStreamSimulationGateEvidenceSurfaceReadModel`、`PrivateStreamSimulationGateEvidenceSurfaceViewModel`、`PrivateStreamSimulationGateFreshnessRecordViewModel` 和 `PrivateStreamSimulationGateEvidenceTraceItem`。
- `Sources/Dashboard/ReadModels/App.swift` 必须把 MTP-145 surface 接入 `ReportReadModel`、`ReportViewModel` 和 `DashboardViewModel` source chain。
- `Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift` 必须包含 `privateStreamSimulationGateEvidenceSurface` section，并输出 MTP-145 Event Timeline read-model-only evidence item。
- `Sources/Dashboard/DashboardShell.swift` 必须包含 Workbench / Report simulation gate metrics、details 和 Dashboard smoke handle `privateStreamSimulationGateEvidence=4`。
- `Tests/AppTests/AppTests.swift` 必须包含 `testPrivateStreamSimulationGateEvidenceSurfaceAggregatesMTP145ReadOnlySurface`，覆盖 Report / Workbench / Events surface、forbidden UI/runtime flags 和 Codable deterministic snapshot。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-145 read-model-only surface、Dashboard / Report / Events evidence、forbidden UI/runtime surface 和 validation anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-145 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate Workbench / Report / Events surface anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-145 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-145 App source、focused tests、contract、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-145 必须建立的主要 anchors：

- `MTP-145-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SIMULATION-GATE-SURFACE`
- `MTP-145-DASHBOARD-REPORT-EVENTS-SIMULATION-GATE-EVIDENCE`
- `MTP-145-FORBIDDEN-UI-RUNTIME-SURFACE`
- `MTP-145-PRIVATE-STREAM-SIMULATION-GATE-SURFACE-VALIDATION`

## MTP-145 禁止

- 不新增或修改 Core semantics；MTP-145 只消费 MTP-141 至 MTP-144 deterministic Core evidence。
- 不新增 Adapters、Persistence、Runtime、broker / exchange adapter implementation、secret / credential / endpoint code。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey、real account read、broker position sync、real balance、real position、margin、leverage、real PnL、execution report、broker fill 或 reconciliation。
- 不暴露 account endpoint payload、real account payload、broker payload、Adapter request、Runtime object、SQLite / DuckDB schema 或 broker state。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、command surface 或 order-level command。
- 不输出 Stage Code Audit Report，不执行 Project closeout；MTP-146 才能收口 stage closeout。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-146 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-30

执行者：Codex

MTP-146 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-146 的验收要求：

- `docs/audit/inputs/mtpro-private-stream-account-snapshot-simulation-gate-v1-stage-audit-input.md` 必须包含 `MTP-146-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-STAGE-CLOSEOUT`、`MTP-146-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-146-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-146-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-STAGE-AUDIT-INPUT`、`MTP-146-VALIDATION-EVIDENCE-CHAIN`、`MTP-146-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-146-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`、`MTP-146-AUTOMATION-READINESS-STAGE-CLOSEOUT`、`MTP-146-STAGE-CLOSEOUT-VALIDATION` 和 `MTP-146-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION` anchors。
- `docs/contracts/private-stream-account-snapshot-simulation-gate-contract.md` 必须包含 MTP-146 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness stage closeout 和 validation anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE` 的 MTP-146 issue backfill 和 `MTP-146 Private Stream / Account Snapshot 阶段收口`。
- `docs/automation/automation-readiness.md` 必须新增 Private Stream / Account Snapshot Simulation Gate stage audit input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-146 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-146 stage audit input、contract、validation matrix、validation plan、latest summary、automation readiness doc、MTP-140 至 MTP-145 PR evidence、Dashboard smoke handle 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-146 必须建立的主要 anchors：

- `MTP-146-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-STAGE-CLOSEOUT`
- `MTP-146-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-146-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-146-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-STAGE-AUDIT-INPUT`
- `MTP-146-VALIDATION-EVIDENCE-CHAIN`
- `MTP-146-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-146-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-146-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-146-STAGE-CLOSEOUT-VALIDATION`
- `MTP-146-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

## MTP-146 禁止

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed/type=completed` 后单独输出。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不修改 production code，不新增 Core / App business capability。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、Live read-only runtime、signed endpoint、account endpoint、listenKey、real account read、broker position sync、real balance、real position、margin、leverage、real PnL、execution report、broker fill 或 reconciliation。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、command surface 或 order-level command。

## MTP-147 Live Monitoring Read-only Console v2 Terminology Validation

日期：2026-05-30

执行者：Codex

MTP-147 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-147 的验收要求：

- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-TERMINOLOGY`、`MTP-147-MONITORING-EVIDENCE-SOURCE-BOUNDARY`、`MTP-147-READ-MODEL-VIEWMODEL-CONSUMPTION-BOUNDARY`、`MTP-147-L33-HANDOFF-BOUNDARY`、`MTP-147-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`、`MTP-147-FORBIDDEN-CAPABILITY-BASELINE` 和 `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-147 Live Monitoring Read-only Console v2 shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2` 和 MTP-147 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-147 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring Read-only Console v2 terminology anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-147 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-147 必须建立的主要 anchors：

- `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-TERMINOLOGY`
- `MTP-147-MONITORING-EVIDENCE-SOURCE-BOUNDARY`
- `MTP-147-READ-MODEL-VIEWMODEL-CONSUMPTION-BOUNDARY`
- `MTP-147-L33-HANDOFF-BOUNDARY`
- `MTP-147-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-147-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-147-LIVE-MONITORING-READ-ONLY-CONSOLE-V2-VALIDATION`

## MTP-147 禁止

- 不新增 Swift production code、不新增 focused XCTest、不新增 Dashboard smoke handle、不新增 App read model、不新增 Core / Runtime / Dashboard behavior、不新增 stage audit input。
- 不实现 monitoring evidence surface；MTP-152 才能接入 Workbench / Report / Events read-model-only surface。
- 不实现 live readiness runtime、Live Monitoring runtime、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不接 signed endpoint、account endpoint / listenKey，不创建 listenKey，不执行 listenKey keepalive。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不实现 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、emergency stop、shutdown 或 restore command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-148 Live Monitoring Source Identity Validation

日期：2026-05-30

执行者：Codex

MTP-148 的 required validation：

- `swift test --filter LiveMonitoringSourceIdentity`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-148 的验收要求：

- `Sources/Core/LiveMonitoringSourceIdentity.swift` 必须包含 `LiveMonitoringSourceIdentityContract`、`LiveMonitoringSourceIdentityRecord`、`LiveMonitoringSourceEvidenceLayer`、`LiveMonitoringSourceEvidenceOrigin`、`LiveMonitoringSourceStatus`、`LiveMonitoringSourceFreshnessSemantics` 和 `LiveMonitoringSourceIdentityForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringSourceIdentityDefinesMTP148DeterministicSource` 和 `testLiveMonitoringSourceIdentityRejectsMTP148RealSourceEndpointAndPayloadBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-148-MONITORING-SOURCE-IDENTITY`、`MTP-148-EVIDENCE-ORIGIN-BOUNDARY-FIXTURE-SIMULATED-READ-MODEL-ONLY`、`MTP-148-SOURCE-FRESHNESS-STATUS-UNAVAILABLE-SEMANTICS`、`MTP-148-SIMULATED-FIXTURE-NOT-REAL-ACCOUNT-GUARD` 和 `MTP-148-LIVE-MONITORING-SOURCE-IDENTITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-148 monitoring source identity shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-148 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-148 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring source identity anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-148 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-148 必须建立的主要 anchors：

- `MTP-148-MONITORING-SOURCE-IDENTITY`
- `MTP-148-EVIDENCE-ORIGIN-BOUNDARY-FIXTURE-SIMULATED-READ-MODEL-ONLY`
- `MTP-148-SOURCE-FRESHNESS-STATUS-UNAVAILABLE-SEMANTICS`
- `MTP-148-SIMULATED-FIXTURE-NOT-REAL-ACCOUNT-GUARD`
- `MTP-148-LIVE-MONITORING-SOURCE-IDENTITY-VALIDATION`

## MTP-148 禁止

- 不创建真实 source adapter，不读取真实 account / position / balance。
- 不接 private stream、listenKey、signed endpoint 或 account endpoint。
- 不暴露 Runtime object、Adapter request、数据库 schema、account payload、broker payload 或 broker state。
- 不实现 Live Monitoring runtime、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 App / Dashboard behavior、Workbench / Report / Events surface、Dashboard smoke handle、API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command 或 order form。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-149 Live Monitoring Simulation Gate Health Validation

日期：2026-05-30

执行者：Codex

MTP-149 的 required validation：

- `swift test --filter LiveMonitoringSimulationGateHealth`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-149 的验收要求：

- `Sources/Core/LiveMonitoringSimulationGateHealth.swift` 必须包含 `LiveMonitoringSimulationGateHealthContract`、`LiveMonitoringSimulationGateHealthEvidenceItem`、`LiveMonitoringSimulationGateHealthStatus`、`LiveMonitoringSimulationGateFreshnessExplanation` 和 `LiveMonitoringSimulationGateHealthForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringSimulationGateHealthDefinesMTP149DeterministicEvidence` 和 `testLiveMonitoringSimulationGateHealthRejectsMTP149RuntimeEndpointPayloadAndSchemaBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-149-SIMULATION-GATE-HEALTH-FRESHNESS-EVIDENCE`、`MTP-149-HEALTH-FRESHNESS-NOT-REAL-ACCOUNT-HEALTH`、`MTP-149-READ-MODEL-ONLY-NON-EXPOSURE` 和 `MTP-149-LIVE-MONITORING-SIMULATION-GATE-HEALTH-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-149 simulation gate health shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-149 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-149 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring simulation gate health evidence anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-149 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-149 必须建立的主要 anchors：

- `MTP-149-SIMULATION-GATE-HEALTH-FRESHNESS-EVIDENCE`
- `MTP-149-HEALTH-FRESHNESS-NOT-REAL-ACCOUNT-HEALTH`
- `MTP-149-READ-MODEL-ONLY-NON-EXPOSURE`
- `MTP-149-LIVE-MONITORING-SIMULATION-GATE-HEALTH-VALIDATION`

## MTP-149 禁止

- 不把 health / freshness evidence 写成 real account health、broker connectivity、private stream health、live connection status 或 production monitoring runtime。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey 或 listenKey keepalive。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、broker payload 或 account endpoint payload。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 App / Dashboard behavior、Workbench / Report / Events surface、Dashboard smoke handle、API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、reconnect、recovery 或 fallback action。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-150 Live Monitoring Connection Readiness Explanation Validation

日期：2026-05-30

执行者：Codex

MTP-150 的 required validation：

- `swift test --filter LiveMonitoringConnectionReadiness`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-150 的验收要求：

- `Sources/Core/LiveMonitoringConnectionReadinessExplanation.swift` 必须包含 `LiveMonitoringConnectionReadinessExplanationContract`、`LiveMonitoringConnectionReadinessExplanationItem`、`LiveMonitoringConnectionReadinessExplanationState`、`LiveMonitoringConnectionReadinessDisplaySemantics` 和 `LiveMonitoringConnectionReadinessForbiddenCapability`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringConnectionReadinessExplanationDefinesMTP150DeterministicEvidence` 和 `testLiveMonitoringConnectionReadinessExplanationRejectsMTP150RuntimeEndpointAndCommandBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-150-CONNECTION-READINESS-EXPLANATION`、`MTP-150-STALE-BLOCKED-MISSING-UI-REPORT-SEMANTICS`、`MTP-150-NO-RUNTIME-CONNECTION-BOUNDARY`、`MTP-150-READINESS-EXPLANATION-NOT-LIVE-READINESS` 和 `MTP-150-LIVE-MONITORING-CONNECTION-READINESS-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-150 connection readiness explanation shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-150 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-150 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring connection readiness explanation anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-150 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-150 必须建立的主要 anchors：

- `MTP-150-CONNECTION-READINESS-EXPLANATION`
- `MTP-150-STALE-BLOCKED-MISSING-UI-REPORT-SEMANTICS`
- `MTP-150-NO-RUNTIME-CONNECTION-BOUNDARY`
- `MTP-150-READINESS-EXPLANATION-NOT-LIVE-READINESS`
- `MTP-150-LIVE-MONITORING-CONNECTION-READINESS-VALIDATION`

## MTP-150 禁止

- 不把 readiness explanation 写成真实连接状态、live readiness implementation、broker connectivity、private stream health、account endpoint health 或 production monitoring runtime。
- 不实现 connection manager，不打开 runtime connection，不实现 Live Monitoring runtime 或 live readiness runtime。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey 或 listenKey keepalive。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、broker payload 或 account endpoint payload。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 App / Dashboard behavior、Workbench / Report / Events surface、Dashboard smoke handle、API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、reconnect、recovery 或 fallback action。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-151 Live Monitoring Forbidden Capability Validation

日期：2026-05-30

执行者：Codex

MTP-151 的 required validation：

- `swift test --filter LiveMonitoringForbiddenCapability`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-151 的验收要求：

- `Sources/Core/LiveMonitoringForbiddenCapabilityTests.swift` 必须包含 `LiveMonitoringForbiddenCapabilityTestContract`、`LiveMonitoringForbiddenCapabilityTestCase`、`LiveMonitoringForbiddenCapabilityTestDomain` 和 `LiveMonitoringForbiddenCapabilityTestAssertion`。
- `Tests/CoreTests/CoreTests.swift` 必须包含 `testLiveMonitoringForbiddenCapabilityTestsDefineMTP151CoverageMatrix` 和 `testLiveMonitoringForbiddenCapabilityTestsRejectMTP151RuntimeEndpointAndUIBypass`。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-151-FORBIDDEN-LIVE-MONITORING-CAPABILITY-TESTS`、`MTP-151-FORBIDDEN-ENDPOINT-RUNTIME-BROKER-UI-COVERAGE`、`MTP-151-MONITORING-EVIDENCE-NOT-LIVE-RUNTIME-GUARD` 和 `MTP-151-LIVE-MONITORING-FORBIDDEN-CAPABILITY-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-151 forbidden capability tests shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-151 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-151 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring forbidden capability tests anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-151 Core source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-151 必须建立的主要 anchors：

- `MTP-151-FORBIDDEN-LIVE-MONITORING-CAPABILITY-TESTS`
- `MTP-151-FORBIDDEN-ENDPOINT-RUNTIME-BROKER-UI-COVERAGE`
- `MTP-151-MONITORING-EVIDENCE-NOT-LIVE-RUNTIME-GUARD`
- `MTP-151-LIVE-MONITORING-FORBIDDEN-CAPABILITY-VALIDATION`

## MTP-151 禁止

- 不实现真实 endpoint、adapter、UI command、完整实盘监控台页面重设计、stop / shutdown / restore。
- 不把 forbidden tests 写成可执行 runtime、connection manager、runtime connection、live readiness runtime 或 Live Monitoring runtime。
- 不实现 private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey 或 listenKey keepalive。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、broker payload 或 account endpoint payload。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 App / Dashboard behavior、Workbench / Report / Events surface、Dashboard smoke handle、API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、reconnect、recovery 或 fallback action。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-152 Live Monitoring Workbench / Report / Events Surface Validation

日期：2026-05-31

执行者：Codex

MTP-152 的 required validation：

- `swift test --filter LiveMonitoringReadOnlyConsoleV2`
- `swift test --filter AppTests`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-152 的验收要求：

- `Sources/Dashboard/Report/LiveMonitoringReadOnlyConsoleV2Surface.swift` 必须包含 `LiveMonitoringReadOnlyConsoleV2SurfaceReadModel`、`LiveMonitoringReadOnlyConsoleV2SurfaceViewModel` 和 `LiveMonitoringReadOnlyConsoleV2TraceItem`。
- `Sources/Dashboard/ReadModels/App.swift` 必须把 `liveMonitoringReadOnlyConsoleV2Surface` 接入 Report / Dashboard read model 和 view model。
- `Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift` 必须包含 `liveMonitoringReadOnlyConsoleV2Surface` section，并输出 MTP-152 Event Timeline read-model-only evidence item。
- `Sources/Dashboard/DashboardShell.swift` 必须包含 Workbench / Report metrics、details 和 smoke handle `liveMonitoringReadOnlyConsoleV2Surface=4`。
- `Tests/AppTests/AppTests.swift` 必须包含 `testLiveMonitoringReadOnlyConsoleV2SurfaceAggregatesMTP152WorkbenchReportEventsEvidence`，并验证 Workbench / Report / Events 只消费 Read Model / ViewModel。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 `MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`、`MTP-152-MONITORING-SOURCE-FRESHNESS-EXPLANATION-SURFACE`、`MTP-152-NO-RUNTIME-ADAPTER-SCHEMA-PAYLOAD-BROKER-STATE-SURFACE` 和 `MTP-152-LIVE-MONITORING-V2-SURFACE-VALIDATION` anchors。
- `docs/domain/context.md` 必须包含 MTP-152 Workbench / Report / Events shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-152 issue backfill。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-152 的当前 issue execution evidence。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring Workbench / Report / Events read-model-only surface anchor。
- `checks/automation-readiness.sh` 必须机械检查 MTP-152 App source、focused tests、contract、domain context、validation plan、trading matrix、latest summary 和 automation readiness doc anchors。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-152 必须建立的主要 anchors：

- `MTP-152-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`
- `MTP-152-MONITORING-SOURCE-FRESHNESS-EXPLANATION-SURFACE`
- `MTP-152-NO-RUNTIME-ADAPTER-SCHEMA-PAYLOAD-BROKER-STATE-SURFACE`
- `MTP-152-LIVE-MONITORING-V2-SURFACE-VALIDATION`

## MTP-152 禁止

- 不新增 Adapters、Runtime、Core semantics、Persistence schema、真实 endpoint、真实 network validation 或完整实盘监控台页面重设计。
- 不实现 signed endpoint、account endpoint、listenKey、private WebSocket runtime、private stream runtime、account snapshot runtime、connection manager、runtime connection、live readiness runtime 或 Live Monitoring runtime。
- 不读取真实账户、真实持仓、真实余额、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker state、broker payload 或 account endpoint payload。
- 不连接 broker adapter、broker / exchange execution adapter，不实现 `LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、reconnect、recovery 或 fallback action。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-153 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-31

执行者：Codex

MTP-153 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-153 的验收要求：

- `docs/audit/inputs/mtpro-live-monitoring-read-only-console-v2-stage-audit-input.md` 必须包含 `MTP-153-LIVE-MONITORING-V2-STAGE-CLOSEOUT`、`MTP-153-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-153-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-153-LIVE-MONITORING-V2-STAGE-AUDIT-INPUT`、`MTP-153-VALIDATION-EVIDENCE-CHAIN`、`MTP-153-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-153-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`、`MTP-153-AUTOMATION-READINESS-STAGE-CLOSEOUT`、`MTP-153-STAGE-CLOSEOUT-VALIDATION` 和 `MTP-153-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION` anchors。
- `docs/contracts/live-monitoring-read-only-console-v2-contract.md` 必须包含 MTP-153 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness stage closeout 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-153 Live Monitoring v2 stage closeout shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2` 的 MTP-153 issue backfill 和 `MTP-153 Live Monitoring v2 阶段收口`。
- `docs/automation/automation-readiness.md` 必须新增 Live Monitoring Read-only Console v2 stage audit input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-153 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-153 stage audit input、contract、validation matrix、validation plan、latest summary、automation readiness doc、MTP-147 至 MTP-152 PR evidence、Dashboard smoke handle 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-153 必须建立的主要 anchors：

- `MTP-153-LIVE-MONITORING-V2-STAGE-CLOSEOUT`
- `MTP-153-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-153-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-153-LIVE-MONITORING-V2-STAGE-AUDIT-INPUT`
- `MTP-153-VALIDATION-EVIDENCE-CHAIN`
- `MTP-153-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-153-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-153-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-153-STAGE-CLOSEOUT-VALIDATION`
- `MTP-153-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

## MTP-153 禁止

- 不输出最终 Stage Code Audit Report；最终报告仍由 Parent Codex 在 Project 全部 Done 且 Linear Project `Completed/type=completed` 后单独输出。
- 不创建下一 Project / Issue，不推进下一阶段，不启动下一阶段 `symphony-issue`。
- 不修改 production code，不新增 Core / App business capability。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。
- 不实现 Live Monitoring runtime、live readiness runtime、connection manager、runtime connection、private WebSocket runtime、private stream runtime、account snapshot runtime、signed endpoint、account endpoint、listenKey、listenKey keepalive、real account read、broker position sync、real balance、real position、margin、leverage 或 real PnL。
- 不实现 broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 API key input、secret storage、account connect、broker connect、Live PRO Console、trading button、live command、order form、stop / shutdown / restore、command surface 或 order-level command。

## MTP-154 Strategy / Trader Instance Readiness Terminology Validation

日期：2026-05-31

执行者：Codex

MTP-154 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-154 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-154 terminology、readiness-only boundary、proposal / readiness evidence baseline、L3.4 handoff boundary、first executable candidate non-authorization、forbidden capability baseline 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-154 Strategy / Trader Instance Readiness shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 和 MTP-154 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Strategy / Trader Instance readiness terminology anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-154 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-154 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、planning record、Linear write evidence 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-154 必须建立的主要 anchors：

- `MTP-154-STRATEGY-TRADER-INSTANCE-READINESS-TERMINOLOGY`
- `MTP-154-READINESS-ONLY-BOUNDARY`
- `MTP-154-PROPOSAL-READINESS-EVIDENCE-BASELINE`
- `MTP-154-L34-HANDOFF-BOUNDARY`
- `MTP-154-FIRST-EXECUTABLE-CANDIDATE-NON-AUTHORIZATION`
- `MTP-154-FORBIDDEN-CAPABILITY-BASELINE`
- `MTP-154-STRATEGY-TRADER-INSTANCE-READINESS-VALIDATION`

## MTP-154 禁止

- 不实现 Strategy runtime、Trader runtime、strategy scheduler、trader process manager 或 direct Strategy Instance -> Execution Client path。
- 不输出 broker command、executable order command、OMS order、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage 或 real PnL。
- 不新增 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、stop / shutdown / restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-156 Quoter / Hedger Role Taxonomy Validation

日期：2026-05-31

执行者：Codex

MTP-156 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-156 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-156 quoter / hedger role taxonomy、role responsibility boundary、role proposal / read-model / blocked evidence relationship、no role execution behavior、forbidden role command surface 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-156 quoter / hedger role taxonomy shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-156 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 quoter / hedger role taxonomy anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-156 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-156 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、forbidden role command surface 和 no role execution behavior。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-156 必须建立的主要 anchors：

- `MTP-156-QUOTER-HEDGER-ROLE-TAXONOMY`
- `MTP-156-ROLE-RESPONSIBILITY-BOUNDARY`
- `MTP-156-ROLE-PROPOSAL-READ-MODEL-BLOCKED-EVIDENCE`
- `MTP-156-NO-ROLE-EXECUTION-BEHAVIOR`
- `MTP-156-FORBIDDEN-ROLE-COMMAND-SURFACE`
- `MTP-156-ROLE-TAXONOMY-VALIDATION`

## MTP-156 禁止

- 不实现 quoter runtime、hedger runtime、strategy marketplace、strategy manager、strategy scheduler、trader process manager、order generation engine 或 direct Strategy Instance -> Execution Client path。
- 不输出 broker command、order-level live command、executable order command、Execution Client request、OMS order、quote order request、hedge order request、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage 或 real PnL。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、broker payload、account endpoint payload、credential、secret 或 API key。
- 不新增 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、stop / shutdown / restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-155 Strategy / Trader Lifecycle Identity Validation

日期：2026-05-31

执行者：Codex

MTP-155 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-155 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-155 lifecycle / identity、instance identity boundary、lifecycle readiness state semantics、read-model reference boundary、no lifecycle runtime boundary、identity sensitive field guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-155 Strategy / Trader lifecycle / identity shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-155 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Strategy / Trader lifecycle identity anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-155 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-155 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、no lifecycle runtime boundary 和 identity sensitive field guard。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-155 必须建立的主要 anchors：

- `MTP-155-STRATEGY-TRADER-LIFECYCLE-IDENTITY`
- `MTP-155-INSTANCE-IDENTITY-BOUNDARY`
- `MTP-155-LIFECYCLE-READINESS-STATE-SEMANTICS`
- `MTP-155-READ-MODEL-REFERENCE-BOUNDARY`
- `MTP-155-NO-LIFECYCLE-RUNTIME-BOUNDARY`
- `MTP-155-IDENTITY-SENSITIVE-FIELD-GUARD`
- `MTP-155-STRATEGY-TRADER-LIFECYCLE-VALIDATION`

## MTP-155 禁止

- 不实现 lifecycle runtime、Strategy runtime、Trader runtime、strategy scheduler、trader process manager、broker connection、account session 或 direct Strategy Instance -> Execution Client path。
- 不输出 broker command、executable order command、OMS order、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 signed endpoint、account endpoint / listenKey、listenKey create / keepalive、private WebSocket runtime、private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage 或 real PnL。
- 不暴露 credential、secret、API key、listenKey、account id、broker account id、private stream cursor、Runtime object、Adapter request、SQLite / DuckDB schema、broker payload 或 account endpoint payload。
- 不新增 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、stop / shutdown / restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-157 Account / Portfolio / Risk Read-model Input Validation

日期：2026-05-31

执行者：Codex

MTP-157 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-157 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-157 account / portfolio / risk read-model input contract、input provenance / evidence trace、freshness / blocked / simulated / future-gated semantics、Read Model / ViewModel boundary、no real account / live risk runtime boundary、broker state / payload / schema exposure guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-157 account / portfolio / risk read-model input shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-157 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 account / portfolio / risk read-model input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-157 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-157 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、Read Model / ViewModel boundary、no real account / live risk runtime boundary 和 broker state / payload / schema exposure guard。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-157 必须建立的主要 anchors：

- `MTP-157-ACCOUNT-PORTFOLIO-RISK-READ-MODEL-INPUT`
- `MTP-157-INPUT-PROVENANCE-EVIDENCE-TRACE`
- `MTP-157-FRESHNESS-BLOCKED-SIMULATED-FUTURE-GATED-SEMANTICS`
- `MTP-157-READ-MODEL-VIEWMODEL-BOUNDARY`
- `MTP-157-NO-REAL-ACCOUNT-RISK-RUNTIME`
- `MTP-157-BROKER-STATE-PAYLOAD-SCHEMA-EXPOSURE-GUARD`
- `MTP-157-READ-MODEL-INPUT-VALIDATION`

## MTP-157 禁止

- 不读取真实账户，不同步 broker position，不读取真实 balance、real position、margin、leverage、buying power 或 real PnL。
- 不实现 live risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、stop trading command、account snapshot runtime、private stream runtime 或 Strategy / Trader runtime input。
- 不接 signed endpoint、account endpoint / listenKey，不创建 listenKey，不连接 private WebSocket，不连接 broker。
- 不暴露 real account payload、account endpoint payload、broker payload、broker state、Runtime object、Adapter request、SQLite / DuckDB schema、credential、secret、API key、listenKey 或 private WebSocket cursor。
- 不输出 broker command、executable order command、OMS order、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不新增 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、Live PRO Console、trading button、live command、order form、stop / shutdown / restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-158 Paper / Live-neutral Proposal Command Isolation Validation

日期：2026-05-31

执行者：Codex

MTP-158 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-158 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-158 paper/live-neutral proposal contract、proposal attributes / status semantics、proposal-to-command isolation、no Execution Client / broker / OMS boundary、proposal forbidden command field guard 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-158 paper/live-neutral proposal shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-158 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 paper/live-neutral proposal command isolation anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-158 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-158 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、proposal-to-command isolation、no Execution Client / broker / OMS boundary 和 forbidden command field guard。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-158 必须建立的主要 anchors：

- `MTP-158-PAPER-LIVE-NEUTRAL-PROPOSAL-CONTRACT`
- `MTP-158-PROPOSAL-ATTRIBUTES-STATUS-SEMANTICS`
- `MTP-158-PROPOSAL-TO-COMMAND-ISOLATION`
- `MTP-158-NO-EXECUTION-CLIENT-BROKER-OMS`
- `MTP-158-PROPOSAL-FORBIDDEN-COMMAND-FIELD-GUARD`
- `MTP-158-PROPOSAL-CONTRACT-VALIDATION`

## MTP-158 禁止

- 不实现 order command、submit / cancel / replace、broker command、Execution Client、OMS、order generation engine、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不连接 broker / exchange execution adapter，不实现 `LiveExecutionAdapter`，不调用 signed endpoint、account endpoint / listenKey，不读取真实账户、broker position、margin、leverage、real PnL。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、stop / shutdown / restore 或 production operations command。
- 不暴露 executable order command、Execution Client request、OMS order、order id、client order id、broker order id、account id、broker account id、account endpoint payload、signed request、listenKey、Runtime object、Adapter request、broker adapter request 或 SQLite / DuckDB schema。
- 不把 price / quantity / side / timeInForce / orderType / venue 写成 executable order tuple。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-159 Forbidden Strategy / Execution / Broker / UI Command Tests Validation

日期：2026-05-31

执行者：Codex

MTP-159 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-159 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-159 forbidden Strategy -> Execution Client tests、forbidden broker command / OMS tests、forbidden UI command surface tests、proposal-to-command bypass guard、no signed/account endpoint / listenKey guard、deterministic local no-network test boundary 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-159 forbidden capability tests shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-159 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 forbidden Strategy / Execution / broker / UI command tests anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-159 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-159 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、proposal-to-command bypass guard、no endpoint / listenKey guard 和 local no-network boundary。
- PR 前必须确认 `.codex/*` 和 `graphify-out/*` 未进入 PR。

MTP-159 必须建立的主要 anchors：

- `MTP-159-FORBIDDEN-STRATEGY-EXECUTION-CLIENT-TESTS`
- `MTP-159-FORBIDDEN-BROKER-COMMAND-OMS-TESTS`
- `MTP-159-FORBIDDEN-UI-COMMAND-SURFACE-TESTS`
- `MTP-159-PROPOSAL-TO-COMMAND-BYPASS-GUARD`
- `MTP-159-NO-SIGNED-ACCOUNT-ENDPOINT-LISTENKEY-GUARD`
- `MTP-159-DETERMINISTIC-LOCAL-NO-NETWORK-TEST-BOUNDARY`
- `MTP-159-FORBIDDEN-CAPABILITY-TESTS-VALIDATION`

## MTP-159 禁止

- 不实现 Strategy runtime、Trader runtime、order generation engine、Execution Client、broker command、OMS、order command、submit / cancel / replace、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不创建 broker adapter、broker / exchange execution adapter、`LiveExecutionAdapter`、adapter request、Runtime object、OMS facade、Execution Client stub、command bus、mock broker 或 hidden live fallback。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不新增 Swift production code、focused XCTest、App read model、Dashboard surface、Dashboard smoke handle 或 stage audit input；Project stage closeout 仍归属 MTP-161。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

## MTP-160 Strategy Readiness Workbench / Report / Events Surface Validation

日期：2026-05-31

执行者：Codex

MTP-160 的 required validation：

- `swift test`
- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-160 的验收要求：

- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-160 Workbench / Report / Events strategy readiness read-model-only evidence surface、strategy readiness source chain、no command / runtime / schema / account boundary 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-160 strategy readiness surface shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-160 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Strategy readiness Workbench / Report / Events surface anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-160 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-160 contract、matrix、validation plan、domain context、latest summary、automation readiness doc、source / test anchors、Dashboard smoke handle 和 no command / runtime / schema / account boundary strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-160 必须建立的主要 anchors：

- `MTP-160-WORKBENCH-REPORT-EVENTS-READ-MODEL-ONLY-SURFACE`
- `MTP-160-STRATEGY-READINESS-SOURCE-CHAIN`
- `MTP-160-NO-COMMAND-RUNTIME-SCHEMA-ACCOUNT-BOUNDARY`
- `MTP-160-STRATEGY-TRADER-READINESS-SURFACE-VALIDATION`

MTP-160 的 App evidence：

- `Sources/Dashboard/Report/StrategyTraderReadinessEvidenceSurface.swift` 提供 deterministic read-model-only evidence surface 和 ViewModel。
- `Sources/Dashboard/ReadModels/App.swift` 将 surface 接入 Report / Dashboard read model 和 ViewModel，并保持 trading authorization 为 false。
- `Sources/Dashboard/Events/PaperWorkflowEvidenceExplorer.swift` 新增 strategy readiness timeline section 和六条 read-model-only event items。
- `Sources/Dashboard/DashboardShell.swift` 将 surface 汇入 Workbench / Report metrics、details、boundary flags 和 Dashboard smoke handle `strategyTraderReadinessSurface=6`。
- `Tests/AppTests/AppTests.swift` 的 `testStrategyTraderReadinessSurfaceAggregatesMTP160WorkbenchReportEventsEvidence` 覆盖 record count、timeline items、Dashboard smoke、forbidden flags 和 Codable round trip。

## MTP-160 禁止

- 不新增或修改 Core semantics，不实现 Strategy runtime、Trader runtime、Execution Client、broker command、broker adapter、`LiveExecutionAdapter`、OMS、order command、submit / cancel / replace、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account endpoint payload、broker payload、broker state、credential、secret、API key 或 listenKey。
- 不新增 Strategy Console、Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-161 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-05-31

执行者：Codex

MTP-161 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-161 的验收要求：

- `docs/audit/inputs/mtpro-strategy-trader-instance-readiness-v1-stage-audit-input.md` 必须包含 `MTP-161-STRATEGY-TRADER-READINESS-STAGE-CLOSEOUT`、`MTP-161-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-161-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-161-STRATEGY-TRADER-READINESS-STAGE-AUDIT-INPUT`、`MTP-161-VALIDATION-EVIDENCE-CHAIN`、`MTP-161-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`、`MTP-161-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`、`MTP-161-AUTOMATION-READINESS-STAGE-CLOSEOUT`、`MTP-161-STAGE-CLOSEOUT-VALIDATION` 和 `MTP-161-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION` anchors。
- `docs/contracts/strategy-trader-instance-readiness-contract.md` 必须包含 MTP-161 stage closeout、stage audit input material、no final Stage Code Audit、validation evidence chain、forbidden capability evidence chain、read-model-only boundary evidence、automation readiness stage closeout 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-161 Strategy / Trader readiness stage closeout shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-STRATEGY-TRADER-INSTANCE-READINESS` 的 MTP-161 issue backfill 和 `MTP-161 Strategy / Trader Readiness 阶段收口`。
- `docs/automation/automation-readiness.md` 必须新增 Strategy / Trader Instance readiness stage audit input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-161 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-161 stage audit input、contract、validation matrix、validation plan、latest summary、automation readiness doc、MTP-154 至 MTP-160 PR evidence、Dashboard smoke handle 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-161 必须建立的主要 anchors：

- `MTP-161-STRATEGY-TRADER-READINESS-STAGE-CLOSEOUT`
- `MTP-161-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-161-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-161-STRATEGY-TRADER-READINESS-STAGE-AUDIT-INPUT`
- `MTP-161-VALIDATION-EVIDENCE-CHAIN`
- `MTP-161-FORBIDDEN-CAPABILITY-EVIDENCE-CHAIN`
- `MTP-161-READ-MODEL-ONLY-BOUNDARY-EVIDENCE`
- `MTP-161-AUTOMATION-READINESS-STAGE-CLOSEOUT`
- `MTP-161-STAGE-CLOSEOUT-VALIDATION`
- `MTP-161-NO-GRAPHIFY-FIGMA-LINEAR-MUTATION`

## MTP-161 禁止

- 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不启动 Root Docs Refresh Gate，不启动下一阶段 planning 或 execution。
- 不新增或修改 production code，不实现 Strategy runtime、Trader runtime、lifecycle runtime、quoter runtime、hedger runtime、Execution Client、broker command、broker adapter、`LiveExecutionAdapter`、OMS、order command、submit / cancel / replace、real order lifecycle、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不暴露 Runtime object、Adapter request、SQLite / DuckDB schema、account endpoint payload、broker payload、broker state、credential、secret、API key 或 listenKey。
- 不新增 Strategy Console、Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-162 Architecture Module Boundary Terminology Validation

日期：2026-06-01

执行者：Codex

MTP-162 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-162 的验收要求：

- `docs/domain/context.md` 必须包含 architecture-graph-aligned module boundary terminology、old-to-target module mapping、future-gated module name non-authorization 和 validation anchors。
- `docs/architecture/module-boundary.md` 必须包含 MTP-162 terminology contract 和 current runtime non-authorization anchors。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 和 MTP-162 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Architecture graph module terminology anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-162 的当前 issue execution evidence，并把 Engine Module Boundary Consolidation 从 docs-only planning candidate 更新为 Linear-controlled active Project evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-162 domain context、architecture boundary、validation plan、validation matrix、latest summary、automation readiness doc、planning record、old target mapping、future-gated non-authorization 和 forbidden capability boundary strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-162 必须建立的主要 anchors：

- `MTP-162-ARCHITECTURE-GRAPH-ALIGNED-MODULE-BOUNDARY-TERMS`
- `MTP-162-OLD-TO-TARGET-MODULE-MAPPING`
- `MTP-162-FUTURE-GATED-MODULE-NAME-NON-AUTHORIZATION`
- `MTP-162-ARCHITECTURE-MODULE-TERMINOLOGY-VALIDATION`
- `MTP-162-TERMINOLOGY-CONTRACT`
- `MTP-162-CURRENT-RUNTIME-NON-AUTHORIZATION`

## MTP-162 禁止

- 不移动业务代码，不新增或修改 Swift production code，不修改 SwiftPM target，不做 source layout move。
- 不实现 Strategy runtime、Trader runtime、Live runtime、Portfolio runtime、Risk runtime、complete runtime MessageBus 或 current ExecutionClient implementation。
- 不实现 OMS implementation、broker / exchange execution adapter、`LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-163 Fixed Target Source Module Layout Validation

日期：2026-06-01

执行者：Codex

MTP-163 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-163 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 fixed target source module layout、dependency direction contract、forbidden path taxonomy、DataClient venue rule、Strategies strategy directory rule、Trader / Account / Portfolio split、ExecutionEngine / ExecutionClient split 和 validation anchors。
- `docs/domain/context.md` 必须包含 MTP-163 fixed source layout shared language。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 的 MTP-163 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Fixed target source module layout anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-163 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-163 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、target directory strings、dependency direction strings 和 forbidden path taxonomy strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-163 必须建立的主要 anchors：

- `MTP-163-FIXED-TARGET-SOURCE-MODULE-LAYOUT`
- `MTP-163-DEPENDENCY-DIRECTION-CONTRACT`
- `MTP-163-FORBIDDEN-PATH-TAXONOMY`
- `MTP-163-DATACLIENT-VENUE-STRATEGIES-STRATEGY-DIRECTORY-RULE`
- `MTP-163-TRADER-ACCOUNT-PORTFOLIO-SPLIT`
- `MTP-163-EXECUTIONENGINE-EXECUTIONCLIENT-SPLIT`
- `MTP-163-FIXED-LAYOUT-VALIDATION`

## MTP-163 禁止

- 不进行大规模文件移动，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不把旧 `Core / Adapters / Persistence / Runtime / App` 继续作为目标结构。
- 不实现 Strategy runtime、Trader runtime、Live runtime、Portfolio runtime、Risk runtime、MessageBus runtime 或 current ExecutionClient implementation。
- 不实现 OMS implementation、broker / exchange execution adapter、`LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-164 Architecture Boundary Validation Anchors

日期：2026-06-01

执行者：Codex

MTP-164 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-164 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 architecture boundary validation anchors、old path drift guard、future-gated implementation drift guard、forbidden capability drift guard、cross-milestone validation input 和 validation non-authorization。
- `docs/domain/context.md` 必须包含 MTP-164 shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-164 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Architecture boundary validation anchors row。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-164 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-164 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、old path drift guard、future-gated implementation drift guard 和 forbidden capability drift guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-164 必须建立的主要 anchors：

- `MTP-164-ARCHITECTURE-BOUNDARY-VALIDATION-ANCHORS`
- `MTP-164-OLD-PATH-DRIFT-GUARD`
- `MTP-164-FUTURE-GATED-IMPLEMENTATION-DRIFT-GUARD`
- `MTP-164-FORBIDDEN-CAPABILITY-DRIFT-GUARD`
- `MTP-164-CROSS-MILESTONE-VALIDATION-INPUT`
- `MTP-164-ARCHITECTURE-BOUNDARY-VALIDATION`

## MTP-164 禁止

- 不执行业务代码迁移，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不推进 M2-M6 后续 issue，不创建 L4 Project / Issue，不设置 Linear Project Completed。
- 不把 `Core / Adapters / Persistence / Runtime / App / Dashboard / CSQLite` 继续作为最终目标结构、长期新增能力落点或新 architecture module name。
- 不把 `ExecutionClient`、`OMSFutureGate`、`FuturePrivateStreamGate`、`FutureLiveProConsole`、`Strategy runtime`、`Trader runtime`、`Portfolio runtime`、`Risk runtime` 或完整 `MessageBus` 写成 current runtime implementation。
- 不实现 Strategy runtime、Trader runtime、Live runtime、Portfolio runtime、Risk runtime、MessageBus runtime 或 current ExecutionClient implementation。
- 不实现 OMS implementation、broker / exchange execution adapter、`LiveExecutionAdapter`、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-165 MessageBus / Command / Event Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-165 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-165 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 MessageBus facts / commands / events / request-response / paper routing / replay invariant 和 risk / execution bypass guard anchors。
- `docs/domain/context.md` 必须包含 MTP-165 MessageBus shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-165 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 MessageBus command event boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-165 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-165 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、facts / commands / events、request-response、paper routing / replay invariant、engine dependency bridge 和 risk / execution bypass guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-165 必须建立的主要 anchors：

- `MTP-165-MESSAGEBUS-FACTS-COMMANDS-EVENTS-CONTRACT`
- `MTP-165-REQUEST-RESPONSE-CONTRACT`
- `MTP-165-PAPER-ROUTING-REPLAY-INVARIANT`
- `MTP-165-ENGINE-DEPENDENCY-BRIDGE`
- `MTP-165-RISK-EXECUTION-BYPASS-GUARD`
- `MTP-165-MESSAGEBUS-BOUNDARY-VALIDATION`

## MTP-165 禁止

- 不实现完整 runtime MessageBus，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不把 MessageBus 写成 external message broker、live command bus、OMS bus、ExecutionClient request queue 或 UI command surface。
- 不通过 MessageBus 绕过 RiskEngine / ExecutionEngine boundary。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS implementation、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-166 Cache Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-166 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-166 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 Cache runtime-derived state、durability / schema separation、Database / MessageBus relationship 和 real account cache forbidden guard anchors。
- `docs/domain/context.md` 必须包含 MTP-166 Cache shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-166 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Cache runtime-derived state boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-166 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-166 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、runtime-derived state、durability / schema separation、Database / MessageBus relationship 和 real account cache forbidden guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-166 必须建立的主要 anchors：

- `MTP-166-CACHE-RUNTIME-DERIVED-STATE-CONTRACT`
- `MTP-166-CACHE-DURABILITY-SCHEMA-SEPARATION`
- `MTP-166-CACHE-DATABASE-MESSAGEBUS-RELATIONSHIP`
- `MTP-166-REAL-ACCOUNT-CACHE-FORBIDDEN-GUARD`
- `MTP-166-CACHE-BOUNDARY-VALIDATION`

## MTP-166 禁止

- 不实现 Redis、external cache service，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不把 Cache 写成 durable source of truth、Database schema owner、DB adapter、UI contract、broker account cache、real account cache 或 broker state mirror。
- 不通过 Cache 绕过 MessageBus、Database、DataEngine、Portfolio、RiskEngine 或 ExecutionEngine boundary。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS implementation、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、buying power、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-167 Database Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-167 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-167 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 Database durable facts / snapshots / projections、SQLite / DuckDB schema-version separation、Database / MessageBus / Cache / Portfolio relationship、Workbench schema bypass guard 和 account / broker persistence forbidden guard anchors。
- `docs/domain/context.md` 必须包含 MTP-167 Database shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-167 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Database durable backing store boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-167 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-167 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、Event Log、Snapshot、Projection、SQLite、DuckDB、schema/version、Workbench schema bypass guard 和 account / broker persistence forbidden guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-167 必须建立的主要 anchors：

- `MTP-167-DATABASE-DURABLE-FACTS-SNAPSHOT-PROJECTION-CONTRACT`
- `MTP-167-SQLITE-DUCKDB-SCHEMA-VERSION-CONTRACT`
- `MTP-167-DATABASE-MESSAGEBUS-CACHE-PORTFOLIO-RELATIONSHIP`
- `MTP-167-WORKBENCH-SCHEMA-BYPASS-GUARD`
- `MTP-167-ACCOUNT-BROKER-PERSISTENCE-FORBIDDEN-GUARD`
- `MTP-167-DATABASE-BOUNDARY-VALIDATION`

## MTP-167 禁止

- 不实现 Database migration，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不把 Database 写成 Redis clone、broker database、production datastore、UI state store、account payload archive 或 broker state mirror。
- 不把 SQLite / DuckDB schema、table、column、raw SQL query、DB adapter、file handle 或 migration version 暴露给 Workbench / Report / Dashboard / Events。
- 不通过 Database 绕过 MessageBus、Cache、Portfolio projection、ReadModel / ViewModel 或 report input contract。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS implementation、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不持久化真实账户、真实持仓、真实余额、broker position、margin、leverage、buying power、real PnL、account endpoint payload、broker payload、broker state、signed request、listenKey state 或 private WebSocket runtime message。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-168 DataClient Exchange Adapter Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-168 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-168 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 DataClient venue adapter boundary、Binance public market data boundary、FuturePrivateStreamGate、provider / exchange capability taxonomy、dependency isolation guard 和 signed/account/listenKey forbidden guard anchors。
- `docs/domain/context.md` 必须包含 MTP-168 DataClient shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-168 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 DataClient exchange adapter boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-168 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-168 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/DataClient/<venue>/`、Binance、PublicMarketData、FuturePrivateStreamGate、provider / exchange capability taxonomy、dependency isolation 和 signed/account/listenKey forbidden guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-168 必须建立的主要 anchors：

- `MTP-168-DATACLIENT-VENUE-ADAPTER-BOUNDARY-CONTRACT`
- `MTP-168-BINANCE-PUBLIC-MARKET-DATA-BOUNDARY`
- `MTP-168-FUTURE-PRIVATE-STREAM-GATE-CONTRACT`
- `MTP-168-PROVIDER-EXCHANGE-CAPABILITY-TAXONOMY`
- `MTP-168-DATACLIENT-DEPENDENCY-ISOLATION-GUARD`
- `MTP-168-SIGNED-ACCOUNT-LISTENKEY-FORBIDDEN-GUARD`
- `MTP-168-DATACLIENT-BOUNDARY-VALIDATION`

## MTP-168 禁止

- 不实现 source move，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不把 DataClient 写成 DataEngine、Trader、ExecutionEngine、ExecutionClient、Workbench、Cache、Database、Portfolio 或 MessageBus 的 runtime dependency owner。
- 不把 Binance DataClient 写成 signed client、account client、listenKey client、private WebSocket runtime、account snapshot runtime、broker adapter、ExecutionClient 或 OMS。
- 不通过 DataClient 绕过 DataEngine ingest / request boundary，不 publish MessageBus facts，不写 Database，不驱动 Workbench，不服务 Trader / Strategy / UI。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS implementation、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、buying power、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-169 DataEngine Ingest / Replay / Quality Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-169 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-169 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 DataEngine ingest / replay / quality boundary、market data ingest request-response、scenario replay / catalog / freshness / quality gates、MessageBus publishing contract、DataClient / MessageBus / Cache relationship、UI / Trader direct service guard 和 signed/account/broker path forbidden guard anchors。
- `docs/domain/context.md` 必须包含 MTP-169 DataEngine shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-169 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 DataEngine ingest replay quality boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-169 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-169 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/DataEngine/`、ingest、request / response、scenario replay、catalog、freshness、quality gates、MessageBus publishing、DataClient / MessageBus / Cache relationship、UI / Trader direct service guard 和 signed/account/broker forbidden path strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-169 必须建立的主要 anchors：

- `MTP-169-DATAENGINE-INGEST-REPLAY-QUALITY-CONTRACT`
- `MTP-169-MARKET-DATA-INGEST-REQUEST-RESPONSE-CONTRACT`
- `MTP-169-SCENARIO-REPLAY-CATALOG-FRESHNESS-QUALITY-GATES`
- `MTP-169-DATAENGINE-MESSAGEBUS-PUBLISHING-CONTRACT`
- `MTP-169-DATACLIENT-MESSAGEBUS-CACHE-RELATIONSHIP`
- `MTP-169-UI-TRADER-DIRECT-SERVICE-FORBIDDEN-GUARD`
- `MTP-169-SIGNED-ACCOUNT-BROKER-PATH-FORBIDDEN-GUARD`
- `MTP-169-DATAENGINE-BOUNDARY-VALIDATION`

## MTP-169 禁止

- 不实现完整 streaming DataEngine runtime，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不把 DataEngine 写成 UI / Trader / Strategy / RiskEngine / ExecutionEngine 直接服务层，不绕过 MessageBus / Cache / ReadModel / ViewModel / report input contract。
- 不把 request / response 写成 Runtime object、Adapter request、HTTP API、Workbench ViewModel、UI command contract、broker payload 或 account payload。
- 不通过 DataEngine 触发 network refresh、listenKey keepalive、broker sync、private stream reconnect、live command 或 executable order path。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS implementation、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、buying power、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-170 Adapter Capability and Data-source Guard Validation

日期：2026-06-01

执行者：Codex

MTP-170 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-170 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 adapter capability guard、forbidden endpoint/runtime coverage、source identity labeling、fixture / public / future-gated source labels、DataClient / DataEngine boundary guard 和 no credential / secret / private network test guard anchors。
- `docs/domain/context.md` 必须包含 MTP-170 adapter capability shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-170 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Adapter capability and data-source guard anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-170 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-170 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、capability guard、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、broker adapter、source identity、fixture-source、public-market-data-source、future-gated-private-source-label 和 no credential / secret / private network test guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-170 必须建立的主要 anchors：

- `MTP-170-ADAPTER-CAPABILITY-GUARD-CONTRACT`
- `MTP-170-FORBIDDEN-ENDPOINT-RUNTIME-COVERAGE`
- `MTP-170-SOURCE-IDENTITY-LABELING-CONTRACT`
- `MTP-170-FIXTURE-PUBLIC-FUTURE-GATED-SOURCE-LABELS`
- `MTP-170-DATACLIENT-DATAENGINE-BOUNDARY-GUARD`
- `MTP-170-NO-CREDENTIAL-SECRET-PRIVATE-NETWORK-TEST-GUARD`
- `MTP-170-ADAPTER-CAPABILITY-VALIDATION`

## MTP-170 禁止

- 不新增 endpoint implementation，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不新增真实网络私有接口测试，不依赖真实凭证、真实 Binance 私有接口或外部 account data。
- 不引入 secret / credential / keychain storage、API key input、signed request fixture、listenKey fixture、private WebSocket fixture、account endpoint fixture、broker payload fixture 或 real account fixture。
- 不把 future-gated private source label 写成 current private stream、account snapshot runtime、secret storage、signed request、account endpoint read、listenKey lifecycle、broker sync 或 private network test fixture。
- 不实现 broker / exchange execution adapter、`LiveExecutionAdapter`、OMS implementation、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不创建或 keepalive listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、buying power、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-171 Strategies Lifecycle and Proposal Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-171 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-171 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 Strategies lifecycle and proposal boundary、EMA strategy directory example、Lifecycle / Quoter / Hedger / Signals / Proposals split、Strategy read-model input contract、no direct ExecutionClient path guard 和 no runtime scheduler / live quoter / hedger guard anchors。
- `docs/domain/context.md` 必须包含 MTP-171 Strategies shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-171 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Strategies lifecycle and proposal boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-171 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-171 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/Strategies/<strategy>/`、`Sources/Strategies/EMA/`、`Lifecycle/`、`Quoter/`、`Hedger/`、`Signals/`、`Proposals/`、paper/live-neutral proposals、read-model inputs、no direct ExecutionClient path 和 no runtime scheduler / live quoter / hedger guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-171 必须建立的主要 anchors：

- `MTP-171-STRATEGIES-LIFECYCLE-PROPOSAL-BOUNDARY-CONTRACT`
- `MTP-171-EMA-STRATEGY-DIRECTORY-EXAMPLE`
- `MTP-171-LIFECYCLE-QUOTER-HEDGER-SIGNALS-PROPOSALS-SPLIT`
- `MTP-171-STRATEGY-READ-MODEL-INPUT-CONTRACT`
- `MTP-171-NO-DIRECT-EXECUTIONCLIENT-PATH-GUARD`
- `MTP-171-NO-RUNTIME-SCHEDULER-LIVE-QUOTER-HEDGER-GUARD`
- `MTP-171-STRATEGIES-BOUNDARY-VALIDATION`

## MTP-171 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 strategy runtime、scheduler、live quoter runtime、live hedger runtime、Trader runtime、ExecutionClient implementation 或 OMS implementation。
- 不输出 broker command、executable order command、ExecutionClient request、OMS order、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不把 `Sources/Strategies/EMA/` 写成 current runtime implementation；它只能作为 target directory example 和 validation label。
- 不调用 signed endpoint、account endpoint / listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不读取真实账户、真实持仓、真实余额、broker position、margin、leverage、buying power、real PnL、account endpoint payload、broker payload 或 broker state。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-172 Trader Coordination Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-172 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-172 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 Trader coordination boundary、Accounts / Coordination / historical StrategyBindings split、strategy / account / risk / execution context coordination、Trader account context identity-only guard、no live coordinator / OMS / broker gateway guard 和 no direct ExecutionClient / broker command path anchors；MTP-202 / MTP-205 后 current binding location 只能写为 `Trader/Coordination/RiskBinding`。
- `docs/domain/context.md` 必须包含 MTP-172 Trader shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-172 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Trader coordination boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-172 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-172 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/Trader/`、`Accounts/`、`Coordination/`、legacy `StrategyBindings` historical/superseded wording、strategy / account / risk / execution context、Trader/Accounts identity-only guard、no direct ExecutionClient path、no broker command、no OMS、no order form、no live coordinator 和 no real account / broker position strings；不得把 `Sources/Trader/StrategyBindings/` 写回 current active source path。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-172 必须建立的主要 anchors：

- `MTP-172-TRADER-COORDINATION-BOUNDARY-CONTRACT`
- `MTP-172-ACCOUNTS-COORDINATION-STRATEGYBINDINGS-SPLIT`
- `MTP-172-STRATEGY-ACCOUNT-RISK-EXECUTION-CONTEXT-COORDINATION`
- `MTP-172-TRADER-ACCOUNT-CONTEXT-IDENTITY-ONLY-GUARD`
- `MTP-172-NO-LIVE-COORDINATOR-OMS-BROKER-GATEWAY-GUARD`
- `MTP-172-NO-DIRECT-EXECUTIONCLIENT-BROKER-COMMAND-PATH`
- `MTP-172-TRADER-BOUNDARY-VALIDATION`

## MTP-172 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 Trader runtime、live coordinator、OMS、broker gateway、broker session manager、private stream coordinator、account snapshot runtime 或 real account synchronizer。
- 不读取真实 account、真实持仓、真实余额、broker position、broker account id、broker payload、broker state、margin、leverage、buying power 或 real PnL。
- 不输出 broker command、executable order command、ExecutionClient request、OMS order、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不调用 signed endpoint、account endpoint / listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不新增 Live PRO Console backend、trading button handler、live command、order form、order-level command UI、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-173 Account / Portfolio Context Read-model Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-173 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-173 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 Account / Portfolio read-model boundary、Trader account context identity contract、Portfolio financial state ownership、cash / position / PnL / exposure / projection split、real account broker portfolio future gate 和 no broker account state read guard anchors。
- `docs/domain/context.md` 必须包含 MTP-173 Account / Portfolio shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-173 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Account / Portfolio context read-model boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-173 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-173 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/Trader/Accounts/`、`Sources/Portfolio/`、account context、account identity、source identity、Portfolio financial state、cash、positions、PnL、exposure、paper projection、future-gated real account 和 no broker account state read guard strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-173 必须建立的主要 anchors：

- `MTP-173-ACCOUNT-PORTFOLIO-READMODEL-BOUNDARY-CONTRACT`
- `MTP-173-TRADER-ACCOUNT-CONTEXT-IDENTITY-CONTRACT`
- `MTP-173-PORTFOLIO-FINANCIAL-STATE-OWNERSHIP`
- `MTP-173-CASH-POSITION-PNL-EXPOSURE-PROJECTION-SPLIT`
- `MTP-173-REAL-ACCOUNT-BROKER-PORTFOLIO-FUTURE-GATE`
- `MTP-173-NO-BROKER-ACCOUNT-STATE-READ-GUARD`
- `MTP-173-ACCOUNT-PORTFOLIO-BOUNDARY-VALIDATION`

## MTP-173 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 Portfolio runtime、real account runtime、broker position sync、Portfolio live reconciliation、private stream runtime 或 account snapshot runtime。
- 不读取真实 account、真实持仓、真实余额、broker position、broker portfolio、broker account state、account endpoint payload、broker payload、margin、leverage、buying power 或 real PnL。
- 不把 cash、positions、PnL、exposure、margin、open value 或 paper projection 放进 Trader/Accounts。
- 不调用 signed endpoint、account endpoint / listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不新增 broker reconciliation、execution report、broker fill、real order lifecycle、Live PRO Console、trading button、live command、order form、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-174 Strategies / Trader No-direct-execution Guard Evidence Validation

日期：2026-06-01

执行者：Codex

MTP-174 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-174 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 Strategies / Trader no-direct-execution guard、proposal / order command semantic isolation、Trader not live coordinator / broker gateway guard、forbidden UI command surface guard、ExecutionClient / OMS / broker blocklist、no runtime / endpoint / credential bypass 和 no-direct-execution validation anchors。
- `docs/domain/context.md` 必须包含 MTP-174 Strategies / Trader guard shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-174 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Strategies / Trader no-direct-execution guard anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-174 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-174 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、Strategies / Trader no-direct-execution guard、proposal / order command isolation、no ExecutionClient、no broker command、no OMS、no trading button、no live command、no order form 和 no credential / endpoint bypass strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-174 必须建立的主要 anchors：

- `MTP-174-STRATEGIES-TRADER-NO-DIRECT-EXECUTION-GUARD`
- `MTP-174-PROPOSAL-ORDER-COMMAND-SEMANTIC-ISOLATION`
- `MTP-174-TRADER-NOT-LIVE-COORDINATOR-BROKER-GATEWAY`
- `MTP-174-FORBIDDEN-UI-COMMAND-SURFACE-GUARD`
- `MTP-174-EXECUTIONCLIENT-OMS-BROKER-PATH-BLOCKLIST`
- `MTP-174-NO-RUNTIME-ENDPOINT-CREDENTIAL-BYPASS`
- `MTP-174-NO-DIRECT-EXECUTION-GUARD-VALIDATION`

## MTP-174 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 Strategy runtime、Trader runtime、ExecutionClient implementation、OMS implementation、broker adapter、broker command、real order lifecycle、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不把 Strategy proposal、Trader proposal、Trader coordination context 或 account context 升级为 executable order command、ExecutionClient request、OMS order、broker order 或 order form payload。
- 不调用 signed endpoint、account endpoint / listenKey，不连接 private WebSocket，不启动 private stream runtime 或 account snapshot runtime。
- 不新增 Live PRO Console、trading button、live command、order form、order-level command UI、position command、emergency stop、shutdown、restore 或 production operations command。
- 不新增 API key input、secret storage、credential provider、keychain storage、private network test 或 broker connect UI。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-175 RiskEngine Pre-execution Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-175 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-175 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 RiskEngine pre-execution boundary、paper risk / blocked evidence contract、RiskEngine before ExecutionEngine dependency、future live risk gate boundary、no broker / ExecutionClient risk path guard、no live risk runtime / circuit breaker guard 和 RiskEngine boundary validation anchors。
- `docs/domain/context.md` 必须包含 MTP-175 RiskEngine shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-175 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 RiskEngine pre-execution boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-175 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-175 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/RiskEngine/`、paper pre-trade risk、blocked evidence、future live risk gate、RiskEngine before ExecutionEngine dependency、no broker、no ExecutionClient、no live risk runtime、no circuit breaker runtime、no real account / broker position / margin / leverage / real PnL 和 no executable order command strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-175 必须建立的主要 anchors：

- `MTP-175-RISKENGINE-PRE-EXECUTION-BOUNDARY-CONTRACT`
- `MTP-175-PAPER-RISK-BLOCKED-EVIDENCE-CONTRACT`
- `MTP-175-RISKENGINE-BEFORE-EXECUTIONENGINE-DEPENDENCY`
- `MTP-175-FUTURE-LIVE-RISK-GATE-BOUNDARY`
- `MTP-175-NO-BROKER-EXECUTIONCLIENT-RISK-PATH-GUARD`
- `MTP-175-NO-LIVE-RISK-RUNTIME-CIRCUIT-BREAKER-GUARD`
- `MTP-175-RISKENGINE-BOUNDARY-VALIDATION`

## MTP-175 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 RiskEngine runtime、live risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、no-trade state runtime、loss / drawdown enforcement runtime、frequency enforcement runtime、global trading lock、stop trading command 或 emergency stop。
- 不读取真实 account、真实持仓、真实余额、broker position、broker account state、margin、leverage、buying power、real PnL、account endpoint payload、broker payload 或 broker state。
- 不调用 signed endpoint、account endpoint / listenKey，不连接 private WebSocket，不启动 private stream runtime、account snapshot runtime、broker session manager 或 private network test。
- 不让 RiskEngine 调用 ExecutionClient、broker adapter、OMS、broker command、real submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不把 paper risk evidence、blocked reason、Portfolio exposure reference 或 future live risk gate label 升级为 executable order command、order form payload、live command、position command、trading button 或 Live PRO Console。
- 不新增 API key input、secret storage、credential provider、keychain storage 或 broker connect UI。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-176 ExecutionEngine Paper / Simulated Lifecycle Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-176 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-176 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 ExecutionEngine paper / simulated lifecycle boundary、paper lifecycle state contract、simulated fill / fee / slippage contract、Portfolio projection evidence output、OMS future gate boundary、no real order lifecycle / broker path guard 和 ExecutionEngine boundary validation anchors。
- `docs/domain/context.md` 必须包含 MTP-176 ExecutionEngine shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-176 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 ExecutionEngine paper / simulated lifecycle boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-176 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-176 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/ExecutionEngine/`、paper lifecycle、simulated fill、fee / slippage、Portfolio projection、OMSFutureGate、no real order lifecycle、no broker submit / cancel / replace、no execution report、no broker fill、no reconciliation 和 no ExecutionClient request strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-176 必须建立的主要 anchors：

- `MTP-176-EXECUTIONENGINE-PAPER-SIMULATED-LIFECYCLE-BOUNDARY`
- `MTP-176-PAPER-LIFECYCLE-STATE-CONTRACT`
- `MTP-176-SIMULATED-FILL-FEE-SLIPPAGE-CONTRACT`
- `MTP-176-PORTFOLIO-PROJECTION-EVIDENCE-OUTPUT`
- `MTP-176-OMS-FUTURE-GATE-BOUNDARY`
- `MTP-176-NO-REAL-ORDER-LIFECYCLE-BROKER-PATH-GUARD`
- `MTP-176-EXECUTIONENGINE-BOUNDARY-VALIDATION`

## MTP-176 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter、broker / exchange execution adapter、order router、execution venue routing、real order lifecycle 或 production execution audit trail。
- 不实现 real submit / cancel / replace、execution report ingestion、broker fill ingestion、reconciliation runtime、settlement record、broker statement、real PnL source 或 live fill event。
- 不调用 signed endpoint、account endpoint / listenKey，不连接 private WebSocket，不启动 private stream runtime、account snapshot runtime、broker session manager 或 private network test。
- 不把 paper lifecycle state、simulated fill、fee、slippage、Portfolio projection trigger 或 OMSFutureGate 升级为 broker order、ExecutionClient request、OMS order、order form payload、live command、position command、trading button 或 Live PRO Console。
- 不新增 API key input、secret storage、credential provider、keychain storage 或 broker connect UI。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-177 ExecutionClient / OMS Future Gate Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-177 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-177 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 ExecutionClient future-gated boundary、BrokerCapabilityMatrix future gate、OMS future gate / ExecutionEngine split、ExecutionEngine vs ExecutionClient plain-language boundary、no broker client / signed request guard、no execution report / fill / reconciliation runtime guard 和 ExecutionClient / OMS future gate validation anchors。
- `docs/domain/context.md` 必须包含 MTP-177 ExecutionClient / OMS shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-177 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 ExecutionClient / OMS future gate boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-177 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-177 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/ExecutionClient/`、BrokerCapabilityMatrix、OMSFutureGate、ExecutionEngine vs ExecutionClient plain-language boundary、no broker client、no signed request、no order submit / cancel / replace、no execution report parser、no broker fill parser 和 no reconciliation runtime strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-177 必须建立的主要 anchors：

- `MTP-177-EXECUTIONCLIENT-FUTURE-GATED-BOUNDARY-CONTRACT`
- `MTP-177-BROKER-CAPABILITY-MATRIX-FUTURE-GATE`
- `MTP-177-OMS-FUTURE-GATE-EXECUTIONENGINE-SPLIT`
- `MTP-177-EXECUTIONENGINE-VS-EXECUTIONCLIENT-PLAIN-LANGUAGE`
- `MTP-177-NO-BROKER-CLIENT-SIGNED-REQUEST-GUARD`
- `MTP-177-NO-EXECUTION-REPORT-FILL-RECONCILIATION-RUNTIME`
- `MTP-177-EXECUTIONCLIENT-OMS-FUTURE-GATE-VALIDATION`

## MTP-177 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 ExecutionClient、OMS、broker adapter、broker / exchange execution adapter、order router、order state store、order amendment engine、execution venue routing 或 live execution runtime。
- 不实现 signed request、account endpoint / listenKey、private WebSocket runtime、broker client、order submit / cancel / replace、execution report parser、broker fill parser、broker acknowledgement decoder、order status poller、fill / position reconciliation job、settlement importer 或 broker statement reader。
- 不新增 capability discovery runtime、credential check、network probe、private endpoint test、API key input、secret storage、credential provider、keychain storage 或 broker connect UI。
- 不把 ExecutionClient、BrokerCapabilityMatrix、OMSFutureGate、ExecutionEngine vs ExecutionClient plain-language boundary 或 future venue API client boundary 升级为 current runtime implementation。
- 不新增 Live PRO Console、trading button、live command、order form、position command、emergency stop、shutdown、restore 或 production operations command。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-178 Broker / Real Order Forbidden Guard Evidence Validation

日期：2026-06-01

执行者：Codex

MTP-178 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-178 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 broker / real order forbidden guard、signed / account / listenKey endpoint blocklist、broker / exchange execution adapter blocklist、real submit / cancel / replace forbidden、execution report / broker fill / reconciliation blocklist、LiveExecutionAdapter future gate 和 broker / real order guard validation anchors。
- `docs/domain/context.md` 必须包含 MTP-178 broker / real order forbidden guard shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-178 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Broker / real order forbidden guard evidence anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-178 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-178 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、broker / real order forbidden guard、signed / account / listenKey endpoint blocklist、broker / exchange execution adapter blocklist、real submit / cancel / replace forbidden、execution report / broker fill / reconciliation blocklist、LiveExecutionAdapter future gate、no source target creation、no broker adapter type declarations 和 no real order lifecycle implementation declarations。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-178 必须建立的主要 anchors：

- `MTP-178-BROKER-REAL-ORDER-FORBIDDEN-GUARD`
- `MTP-178-SIGNED-ACCOUNT-LISTENKEY-ENDPOINT-BLOCKLIST`
- `MTP-178-BROKER-EXCHANGE-EXECUTION-ADAPTER-BLOCKLIST`
- `MTP-178-REAL-SUBMIT-CANCEL-REPLACE-FORBIDDEN`
- `MTP-178-EXECUTION-REPORT-BROKER-FILL-RECONCILIATION-BLOCKLIST`
- `MTP-178-LIVEEXECUTIONADAPTER-FUTURE-GATE`
- `MTP-178-BROKER-REAL-ORDER-GUARD-VALIDATION`

## MTP-178 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 broker adapter、broker client、broker SDK wrapper、exchange execution adapter、exchange venue client、ExecutionClient、OMS、LiveExecutionAdapter、broker gateway、OMS gateway、order router、execution venue routing、broker session manager 或 broker connect UI。
- 不实现 signed request builder、API key input、secret storage、credential provider、keychain storage、account endpoint client、listenKey lifecycle、private WebSocket runtime、account snapshot runtime、private endpoint network test、broker account payload 或 broker state payload。
- 不实现真实 submit / cancel / replace、order amendment、order status poll、broker acknowledgement、exchange order id、client order id、broker order id、real order state machine 或 production execution audit trail。
- 不实现 execution report parser、broker fill parser、broker fill fact、fill reconciliation job、position reconciliation job、settlement importer、broker statement reader、real PnL source、broker portfolio sync、account position sync 或 broker evidence pipeline。
- 不把 paper lifecycle、simulated fill、RiskEngine blocked evidence、Strategy proposal、ExecutionClient future gate、BrokerCapabilityMatrix、OMSFutureGate 或 LiveExecutionAdapter future gate 升级为 executable order command、order form payload、live command、trading button、Live PRO Console action 或真实订单能力。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-179 Workbench Read-Model-Only Consumption Boundary Validation

日期：2026-06-01

执行者：Codex

MTP-179 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-179 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 Workbench read-model-only consumption boundary、ReadModel / ViewModel only input contract、Workbench / Report / Events surface split、no runtime / adapter / schema / payload exposure、no live command surface guard、UI copy read-model-only labeling 和 Workbench readmodel boundary validation anchors。
- `docs/domain/context.md` 必须包含 MTP-179 Workbench read-model-only shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-179 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Workbench read-model-only consumption boundary anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-179 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-179 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/Workbench/` target boundary、ReadModel / ViewModel input、Workbench / Report / Events surface split、no runtime object、no Adapter request、no SQLite / DuckDB schema、no account payload、no broker state、no live command surface、no Live PRO Console、no trading button 和 no order form strings。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-179 必须建立的主要 anchors：

- `MTP-179-WORKBENCH-READ-MODEL-ONLY-CONSUMPTION-BOUNDARY`
- `MTP-179-READMODEL-VIEWMODEL-ONLY-INPUT-CONTRACT`
- `MTP-179-WORKBENCH-REPORT-EVENTS-SURFACE-SPLIT`
- `MTP-179-NO-RUNTIME-ADAPTER-SCHEMA-PAYLOAD-EXPOSURE`
- `MTP-179-NO-LIVE-COMMAND-SURFACE-GUARD`
- `MTP-179-UI-COPY-READ-MODEL-ONLY-LABELING`
- `MTP-179-WORKBENCH-READMODEL-BOUNDARY-VALIDATION`

## MTP-179 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 Workbench runtime、Workbench command surface、Live PRO Console、trading button、live command、order form、position command、stop trading command、emergency stop、shutdown / restore command、broker connect UI、signed endpoint trigger、account endpoint trigger 或 ExecutionClient trigger。
- 不让 Workbench / Report / Dashboard / Events 读取 Runtime object、Adapter request、SQLite / DuckDB schema、SQL table / column contract、account endpoint payload、broker payload、broker state、ExecutionClient request、OMS order 或 live command payload。
- 不把 MessageBus facts projection、Portfolio / Risk / Execution evidence read model、local fixture summary、deterministic validation summary 或 ViewModel export 升级成 runtime command surface、database browser、adapter console、broker console 或 live operations console。
- 不新增 execute、submit、cancel、replace、trade、connect broker、sync account、start live、stop live、emergency stop 或 production operation UI 文案。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-180 Future Live PRO Console Product-Surface Split Validation

日期：2026-06-01

执行者：Codex

MTP-180 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-180 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 Future Live PRO Console product-surface split、FutureLiveProConsole boundary label、current Workbench vs future command surface、live command controls future-only、no current Live PRO Console implementation、next-stage product-surface readiness input 和 Future Live PRO Console validation anchors。
- `docs/domain/context.md` 必须包含 MTP-180 Future Live PRO Console shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-180 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Future Live PRO Console product-surface split anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-180 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-180 architecture boundary、domain context、validation plan、validation matrix、latest summary、automation readiness doc、`Sources/Dashboard/FutureLiveProConsole/` future boundary label、current Workbench read-model-only vs future command surface split、live command controls future-only guard、no current Live PRO Console implementation 和 next-stage product-surface readiness input。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-180 必须建立的主要 anchors：

- `MTP-180-FUTURE-LIVE-PRO-CONSOLE-PRODUCT-SURFACE-SPLIT`
- `MTP-180-FUTURELIVEPROCONSOLE-BOUNDARY-LABEL`
- `MTP-180-CURRENT-WORKBENCH-VS-FUTURE-COMMAND-SURFACE`
- `MTP-180-LIVE-COMMAND-CONTROLS-FUTURE-ONLY`
- `MTP-180-NO-CURRENT-LIVE-PRO-CONSOLE-IMPLEMENTATION`
- `MTP-180-NEXT-STAGE-PRODUCT-SURFACE-READINESS-INPUT`
- `MTP-180-FUTURE-LIVE-PRO-CONSOLE-VALIDATION`

## MTP-180 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不创建 `Sources/Dashboard/FutureLiveProConsole/`、`Sources/LivePROConsole/`、`Sources/OperationsConsole/` 或任何 current command-capable UI target。
- 不实现 Live PRO Console、FutureLiveProConsole runtime、trading button、live command、order form、position command、emergency stop、shutdown、restore、broker connect UI、account connect UI、ExecutionClient request UI、OMS command UI 或 production operations command。
- 不把 current Workbench read-model-only controls、Report summary、Events timeline、Dashboard smoke、RiskEngine blocked evidence、ExecutionEngine paper lifecycle 或 Strategy proposal 升级为 command-capable surface。
- 不创建 L4 Project / Issue，不授权下一阶段，不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-181 L4 Planning Input Material Validation

日期：2026-06-01

执行者：Codex

MTP-181 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-181 的验收要求：

- `docs/planning/projects/mtpro-engine-module-boundary-consolidation-v1-l4-planning-input.md` 必须存在，并包含 L4 planning input material、Engine module boundary map、dependency direction summary、forbidden capability audit、validation gaps / future gates、no L4 Project / Issue authorization 和 L4 planning input validation anchors。
- `docs/architecture/module-boundary.md` 必须包含 MTP-181 L4 planning input material anchors。
- `docs/domain/context.md` 必须包含 MTP-181 L4 planning input shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-181 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 L4 planning input material anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-181 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-181 planning input file、architecture boundary、domain context、validation plan、validation matrix、latest summary 和 automation readiness doc。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-181 必须建立的主要 anchors：

- `MTP-181-L4-PLANNING-INPUT-MATERIAL`
- `MTP-181-ENGINE-MODULE-BOUNDARY-MAP`
- `MTP-181-DEPENDENCY-DIRECTION-SUMMARY`
- `MTP-181-FORBIDDEN-CAPABILITY-AUDIT`
- `MTP-181-VALIDATION-GAPS-FUTURE-GATES`
- `MTP-181-NO-L4-PROJECT-ISSUE-AUTHORIZATION`
- `MTP-181-L4-PLANNING-INPUT-VALIDATION`

## MTP-181 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不创建 L4 Linear Project / Issue，不推进 Todo，不启动下一阶段 `@002 / PAR`，不启动 Symphony。
- 不实现 L4 runtime、live production path、broker path、ExecutionClient implementation、OMS implementation、real order lifecycle、Live PRO Console、trading button、live command、order form、emergency stop、shutdown、restore 或 production operations command。
- 不输出最终 Stage Code Audit Report；MTP-182 仍负责 validation matrix / automation readiness / stage audit input material 收口，最终 Stage Code Audit Report 仍由 Parent Codex 在 Project closure 后单独输出。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-182 Validation Matrix / Automation Readiness / Stage Audit Input Validation

日期：2026-06-01

执行者：Codex

MTP-182 的 required validation：

- `bash checks/automation-readiness.sh`
- `git diff --check`
- `bash checks/run.sh`

MTP-182 的验收要求：

- `docs/audit/inputs/mtpro-engine-module-boundary-consolidation-v1-stage-audit-input.md` 必须存在，并包含 stage closeout、stage audit input material、no final Stage Code Audit、M1-M6 evidence chain、validation matrix closeout、automation readiness closeout、forbidden implementation audit、unresolved future gates、stage closeout validation 和 no Graphify / Figma / next-stage mutation anchors。
- `docs/architecture/module-boundary.md` 必须包含 MTP-182 stage closeout anchors。
- `docs/domain/context.md` 必须包含 MTP-182 shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-182 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Engine Module Boundary Consolidation stage audit input anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-182 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-182 stage audit input、architecture boundary、domain context、validation plan、validation matrix、latest summary 和 automation readiness doc。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-182 必须建立的主要 anchors：

- `MTP-182-ENGINE-MODULE-BOUNDARY-STAGE-CLOSEOUT`
- `MTP-182-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-182-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-182-VALIDATION-MATRIX-CLOSEOUT`
- `MTP-182-AUTOMATION-READINESS-CLOSEOUT`
- `MTP-182-M1-M6-EVIDENCE-CHAIN`
- `MTP-182-FORBIDDEN-IMPLEMENTATION-AUDIT`
- `MTP-182-UNRESOLVED-FUTURE-GATES`
- `MTP-182-STAGE-CLOSEOUT-VALIDATION`
- `MTP-182-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`

## MTP-182 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不启动 Root Docs Refresh Gate，不创建 L4 Linear Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR` 或 Symphony。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker adapter、real order lifecycle、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、Live PRO Console、trading button、live command、order form、emergency stop、shutdown、restore 或 production operations command。
- 不把 `TVM-ARCHITECTURE-MODULE-BOUNDARY`、L4 planning input material、Workbench read-model-only boundary 或 Future Live PRO Console product-surface split 写成 execution authorization。
- 不运行 Graphify，不修改 Figma，不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-183 Target Physical Layout / SwiftPM Migration Contract Validation

日期：2026-06-01

执行者：Codex

MTP-183 的 required validation：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-183 的验收要求：

- `docs/contracts/target-module-physical-layout-source-migration-contract.md` 必须存在，并包含 target physical layout、current SwiftPM snapshot、SwiftPM migration contract、old-to-new source map、compatibility shell policy、import direction guard、tests placement、validation anchors 和 no source move / Package.swift / business code boundary。
- `docs/architecture/module-boundary.md` 必须包含 MTP-183 target layout / SwiftPM migration anchors。
- `docs/domain/context.md` 必须包含 MTP-183 shared language anchors。
- `docs/validation/trading-validation-matrix.md` 必须把 `TVM-ARCHITECTURE-MODULE-BOUNDARY` 扩展到 MTP-183 issue backfill。
- `docs/automation/automation-readiness.md` 必须新增 Target module migration contract anchor。
- `docs/validation/latest-verification-summary.md` 必须记录 MTP-183 的当前 issue execution evidence。
- `checks/automation-readiness.sh` 必须机械检查 MTP-183 contract file、architecture boundary、domain context、validation plan、validation matrix、latest summary 和 automation readiness doc。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-183 必须建立的主要 anchors：

- `MTP-183-TARGET-PHYSICAL-LAYOUT-CONTRACT`
- `MTP-183-CURRENT-SWIFTPM-SNAPSHOT`
- `MTP-183-SWIFTPM-MIGRATION-CONTRACT`
- `MTP-183-OLD-TO-NEW-SOURCE-MAP`
- `MTP-183-COMPATIBILITY-SHELL-POLICY`
- `MTP-183-IMPORT-DIRECTION-GUARD`
- `MTP-183-TESTS-PLACEMENT-CONTRACT`
- `MTP-183-VALIDATION-ANCHORS`
- `MTP-183-NO-SOURCE-MOVE-PACKAGE-BUSINESS-CODE`

## MTP-183 禁止

- 不移动 `Sources` 文件，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、broker adapter、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、real account / broker position / margin / leverage、real PnL、Live PRO Console、trading button、live command 或 order form。
- 不把 `ExecutionClient`、`OMSFutureGate`、`FuturePrivateStreamGate`、`FutureLiveProConsole` 或 compatibility shell 写成当前 runtime implementation。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-184 DomainModel / MessageBus Physical Migration Validation

日期：2026-06-01

执行者：Codex

MTP-184 的 required validation：

- `swift test --filter CoreTests`
- `swift test --filter CoreTests/testMTP188`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-184 的验收要求：

- `Sources/DomainModel/MarketPrimitives.swift`、`Sources/DomainModel/MarketDataModels.swift` 和 `Sources/DomainModel/CoreBaseline.swift` 必须存在。
- `Sources/MessageBus/DomainEvents.swift`、`Sources/MessageBus/CommandsAndQueries.swift`、`Sources/MessageBus/EventLog.swift` 和 `Sources/MessageBus/PaperRuntimeBusRouting.swift` 必须存在。
- `Package.swift` 必须保留现有 `Core` target / product / dependency graph，只把 `Core` target source roots 扩展为 `Core`、`DomainModel` 和 `MessageBus`，并显式排除其他 target 目录。
- `docs/architecture/module-boundary.md` 和 `docs/domain/context.md` 必须记录 MTP-184 physical migration、Core target compatibility envelope、no behavior change import boundary 和 higher-module migration forbidden boundary。
- `docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-184 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-184 必须建立的主要 anchors：

- `MTP-184-DOMAINMODEL-MESSAGEBUS-PHYSICAL-MIGRATION`
- `MTP-184-CORE-TARGET-COMPATIBILITY-ENVELOPE`
- `MTP-184-NO-BEHAVIOR-CHANGE-IMPORT-BOUNDARY`
- `MTP-184-REMAINING-COMPATIBILITY-SHELL`
- `MTP-184-FORBIDDEN-HIGHER-MODULE-MIGRATION`

## MTP-184 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不迁移 DataClient、DataEngine、Cache、Database、Strategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard。
- 不实现 runtime MessageBus、Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker / live / order capability、signed endpoint、account endpoint / listenKey、private WebSocket runtime、Live PRO Console、trading button、live command 或 order form。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-185 DataClient / DataEngine Physical Migration Validation

日期：2026-06-01

执行者：Codex

MTP-185 的 required validation：

- `swift test --filter AdaptersTests`
- `swift test --filter RuntimeTests/testMarketDataIngestReplayProjectionWorkflowUsesMockTransportAndStableSnapshots`
- `swift test --filter CoreTests/testMTP103DataCatalogScenarioReplayDefinesTerminologyAndBoundaryAnchors`
- `swift test --filter CoreTests/testMTP107ScenarioDataQualityGatesDefineTaxonomyAndDeterministicVerdict`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-185 的验收要求：

- `Sources/DataClient/Binance/PublicMarketData/` 必须包含 Binance public read-only client、batch replay boundary、replay metadata、freshness 和 deterministic parity 文件；旧 `Sources/Adapters/` 不得继续保存这些 migrated files。
- `Sources/DataEngine/ScenarioReplay/` 必须包含 Data Catalog / Scenario Replay、Scenario Manifest、Scenario Fixture、Scenario Replay Evidence 和 deterministic matching 文件。
- `Sources/DataEngine/DataQuality/` 必须包含 Scenario Data Quality / Report Input 文件。
- `Sources/DataEngine/Ingest/` 必须包含 public market data ingest workflow；旧 `Sources/Runtime/Runtime.swift` 不得保留。
- `Package.swift` 必须保留现有 `Core`、`Adapters` 和 `Runtime` product / target 名称作为 compatibility envelope，不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-185 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-185 必须建立的主要 anchors：

- `MTP-185-DATACLIENT-DATAENGINE-PHYSICAL-MIGRATION`
- `MTP-185-DATACLIENT-COMPATIBILITY-ENVELOPE`
- `MTP-185-DATAENGINE-COMPATIBILITY-ENVELOPE`
- `MTP-185-PUBLIC-READ-ONLY-GUARD`
- `MTP-185-DATAENGINE-BOUNDARY-GUARD`
- `MTP-185-REMAINING-COMPATIBILITY-SHELL`

## MTP-185 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 signed endpoint、account endpoint、listenKey、private WebSocket runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、real submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不把 DataEngine 写成完整 streaming runtime，不让 DataEngine 直接服务 UI / Trader / Strategy / RiskEngine / ExecutionEngine，不绕过 MessageBus / Cache / Database / ReadModel / ViewModel。
- 不迁移 Cache、Database、Strategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard，除非是保持现有 target buildability 的最小 import compatibility。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-186 Cache / Database Physical Migration Validation

日期：2026-06-01

执行者：Codex

MTP-186 的 required validation：

- `swift test --filter PersistenceTests`
- `swift test --filter RuntimeTests/testMarketDataReplayProjectionConsistency`
- `swift test --filter RuntimeTests/testWorkflowCanPersistRuntimeProjectionThroughSQLiteAdapterFromReplay`
- `swift test --filter CoreTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-186 的验收要求：

- `Sources/Cache/MarketData/` 必须包含 runtime-derived market data cache 和 order book read model；旧 `Sources/Core/MarketDataCache.swift` 与 `Sources/Core/OrderBookReadModel.swift` 不得保留。
- `Sources/Database/Projections/SQLite/`、`Sources/Database/Projections/DuckDB/` 和 `Sources/Database/ReplayProjection/` 必须分别包含 SQLite projection、DuckDB projection 和 replay projection consistency evidence。
- `Sources/Database/Projections/SQLite/CSQLite/` 必须承载 CSQLite system library module map 和 public shim header；旧 `Sources/CSQLite/` 不得保留。
- `Package.swift` 必须保留现有 `Core`、`Persistence`、`CSQLite` 和 `Runtime` product / target 名称作为 compatibility envelope，不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-186 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-186 必须建立的主要 anchors：

- `MTP-186-CACHE-DATABASE-PHYSICAL-MIGRATION`
- `MTP-186-CACHE-COMPATIBILITY-ENVELOPE`
- `MTP-186-DATABASE-COMPATIBILITY-ENVELOPE`
- `MTP-186-CSQLITE-SYSTEM-LIBRARY-BOUNDARY`
- `MTP-186-SCHEMA-NON-EXPOSURE-GUARD`
- `MTP-186-REMAINING-COMPATIBILITY-SHELL`

## MTP-186 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 schema exposure、Database runtime migration、real account persistence、broker payload persistence、private stream persistence、Runtime object exposure、Adapter request exposure、real broker sync、real account / position / balance read、signed endpoint、account endpoint、listenKey、private WebSocket runtime、broker / exchange execution adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不把 Cache 写成 external cache service、Redis clone、real account cache 或 broker state cache；不把 Database 直连 UI / Trader / Strategy / RiskEngine / ExecutionEngine。
- 不迁移 Strategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard，除非是保持现有 target buildability 的最小 import compatibility。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-187 Strategies / Trader / Portfolio Physical Migration Validation

日期：2026-06-01

执行者：Codex

MTP-187 的 required validation：

- `swift test --filter CoreTests/testEMACrossStrategyContractGeneratesDeterministicSignalFixture`
- `swift test --filter CoreTests/testPaperActionProposalMapsStrategySignalToPaperOnlyIntentDeterministically`
- `swift test --filter CoreTests/testPaperActionRiskLinkAllowsPaperProposalWithTraceableContext`
- `swift test --filter CoreTests/testPaperExecutionReplayProjectsPortfolioOnlyFromSimulatedFillEvidence`
- `swift test --filter CoreTests/testMTP115SimulatedExchangePortfolioProjectionProducesBacktestPaperParity`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-187 的验收要求：

- MTP-187 historical evidence 记录 EMA lifecycle、strategy signal、paper proposal source 和 order-book imbalance research strategy 曾迁入 `Sources/Strategies/EMA/` 与 `Sources/Strategies/OrderBookImbalance/`；MTP-193 后 EMA current active source path 必须是 `Sources/Trader/Strategies/EMA/`，MTP-194 后 OrderBookImbalance placement 只作为 historical / compatibility evidence，MTP-198 后不得写成 current active strategy。
- MTP-187 historical evidence 曾记录 proposal-to-risk binding 位于 `Sources/Trader/StrategyBindings/`；MTP-202 / MTP-205 后 current binding location 为 `Sources/Trader/Coordination/RiskBinding/`，Trader 仍只表示 coordination evidence，不实现 live coordinator、broker gateway、OMS gateway 或 ExecutionClient gateway。
- `Sources/Portfolio/` 必须包含 paper account / portfolio projection、portfolio projection update 和 simulated exchange portfolio projection parity；Portfolio 仍只持有 paper / simulated / read-model financial state。
- `Package.swift` 必须保留现有 `Core` product / target 名称作为 compatibility envelope，不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 旧 `Sources/Core/EMACross.swift`、`Sources/Core/StrategySignals.swift`、`Sources/Core/PaperActionProposal.swift`、`Sources/Core/OrderBookImbalance.swift`、`Sources/Core/PaperActionRiskLink.swift`、`Sources/Core/PaperAccountPortfolioProjectionV2.swift`、`Sources/Core/PaperPortfolioProjectionUpdate.swift` 和 `Sources/Core/SimulatedExchangePortfolioProjectionParity.swift` 不得保留；MTP-193 后 `Sources/Strategies/EMA/` 不得保留 production source，MTP-194 后 `Sources/Strategies/OrderBookImbalance/` 也不得保留 production source。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-187 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-187 必须建立的主要 anchors：

- `MTP-187-STRATEGIES-TRADER-PORTFOLIO-PHYSICAL-MIGRATION`
- `MTP-187-STRATEGIES-COMPATIBILITY-ENVELOPE`
- `MTP-187-TRADER-COMPATIBILITY-ENVELOPE`
- `MTP-187-PORTFOLIO-COMPATIBILITY-ENVELOPE`
- `MTP-187-NO-DIRECT-EXECUTION-GUARD`
- `MTP-187-REMAINING-COMPATIBILITY-SHELL`

## MTP-187 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、Trader runtime、strategy scheduler、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、Portfolio runtime、real account runtime、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 position command。
- 不把 strategy proposal、Trader binding、risk decision、Portfolio projection、paper account snapshot 或 simulated parity evidence 升级为 executable order command、ExecutionClient request、OMS order、broker order 或 order form payload。
- 不迁移 RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard，除非是保持现有 target buildability 的最小 import compatibility。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-188 RiskEngine / ExecutionEngine / ExecutionClient Physical Migration Validation

MTP-188 必须运行：

- `swift test --filter CoreTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-188 的验收要求：

- `Sources/RiskEngine/PreTrade/` 必须包含 paper pre-trade risk source；`Sources/RiskEngine/LiveGate/` 必须包含 live risk gate 和 incident / stop blocked evidence source。
- `Sources/ExecutionEngine/PaperLifecycle/` 必须包含 paper workflow、runtime kernel、session lifecycle、order lifecycle、execution decision 和 event log source；`Sources/ExecutionEngine/SimulatedExchange/` 必须包含 simulated fill、shared order semantics、market / limit simulated execution、partial fill / latency / fee / slippage parity 和 execution costs source。
- `Sources/ExecutionEngine/OMSFutureGate/` 必须只包含 OMS future gate boundary evidence，不实现 OMS。
- `Sources/ExecutionClient/FutureGate/` 和 `Sources/ExecutionClient/BrokerCapabilityMatrix/` 必须只包含 future-gated ExecutionClient / BrokerCapabilityMatrix boundary evidence，不实现 ExecutionClient。
- `Package.swift` 必须保留现有 `Core` product / target 名称作为 compatibility envelope，不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 旧 MTP-188 source migration files 不得继续保留在 `Sources/Core/`。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-188 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-188 必须建立的主要 anchors：

- `MTP-188-RISK-EXECUTION-PHYSICAL-MIGRATION`
- `MTP-188-RISKENGINE-COMPATIBILITY-ENVELOPE`
- `MTP-188-EXECUTIONENGINE-COMPATIBILITY-ENVELOPE`
- `MTP-188-EXECUTIONCLIENT-FUTURE-GATE-ENVELOPE`
- `MTP-188-BROKER-REAL-ORDER-FORBIDDEN-GUARD`
- `MTP-188-REMAINING-COMPATIBILITY-SHELL`

## MTP-188 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 RiskEngine runtime、live risk engine、real pre-trade allow / reject runtime、circuit breaker runtime、stop trading command、emergency stop、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter、broker client、signed request、account endpoint、listenKey、private WebSocket runtime、real order lifecycle、real submit / cancel / replace、execution report parser、broker fill parser、reconciliation runtime、credential / secret / keychain storage、Live PRO Console、trading button、live command 或 order form。
- 不把 paper risk decision、paper order intent、paper lifecycle state、simulated fill、fee / slippage evidence、OMSFutureGate 或 BrokerCapabilityMatrix 升级为 executable order command、ExecutionClient request、OMS order、broker order、order form payload、live command 或 trading button。
- 不迁移 Workbench 或 Dashboard，除非是保持现有 target buildability 的最小 import compatibility。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-189 Workbench / Dashboard Physical Migration Validation

MTP-189 必须运行：

- `swift test --filter AppTests/testMTP189`
- `swift test --filter AppTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-189 的验收要求：

- `Sources/Dashboard/ReadModels/`、`Sources/Dashboard/Report/`、`Sources/Dashboard/`、`Sources/Dashboard/Events/` 和 `Sources/Dashboard/FutureLiveProConsole/` 必须承载 Workbench read-model-only source roots。
- `Sources/Dashboard/` 必须承载 macOS shell / smoke source；Dashboard 只能消费 `DashboardViewModel` / `DashboardShellSnapshot`。
- `Package.swift` 必须保留现有 `App` product / target 名称作为 compatibility envelope，不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 旧 `Sources/App/` 不得继续作为 Workbench source owner 保留。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-189 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-189 必须建立的主要 anchors：

- `MTP-189-WORKBENCH-DASHBOARD-PHYSICAL-MIGRATION`
- `MTP-189-APP-COMPATIBILITY-ENVELOPE`
- `MTP-189-DASHBOARD-SHELL-BOUNDARY`
- `MTP-189-WORKBENCH-READMODEL-ONLY-GUARD`

## MTP-189 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Workbench runtime、Live PRO Console、trading button、live command、order form、broker connect UI、account connect UI、Runtime object exposure、Adapter request exposure、SQLite / DuckDB schema exposure、account payload exposure、broker state exposure、ExecutionClient request UI、OMS command UI、emergency stop、shutdown、restore 或 production operations command。
- 不把 Report / Dashboard / Events evidence surface 升级为 command surface、broker payload viewer、database schema viewer、adapter request viewer 或 real account console。
- 不迁移 MTP-190 stage closeout material，不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-190 Target Module Source Migration Stage Closeout Validation

MTP-190 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-190 的验收要求：

- `docs/audit/inputs/mtpro-target-module-physical-layout-source-migration-v1-stage-audit-input.md` 必须存在，并包含 MTP-183 至 MTP-189 PR evidence、source migration closeout、validation matrix closeout、automation readiness closeout、remaining compatibility shell audit、forbidden implementation audit、unresolved future gates、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-190 mechanical anchors。
- `TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION` 必须明确 MTP-190 只收口 validation matrix、automation readiness 和 audit input，不授权 SwiftPM target graph split、L4 execution、broker runtime、live runtime 或 command-capable product surface。
- Stage audit input 必须明确 final Stage Code Audit Report 仍由 Parent Codex 在 Project Done / Completed evidence 后单独输出。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-190 必须建立的主要 anchors：

- `MTP-190-TARGET-MODULE-SOURCE-MIGRATION-STAGE-CLOSEOUT`
- `MTP-190-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-190-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-190-SOURCE-MIGRATION-EVIDENCE-CHAIN`
- `MTP-190-SOURCE-MIGRATION-CLOSEOUT`
- `MTP-190-VALIDATION-MATRIX-CLOSEOUT`
- `MTP-190-AUTOMATION-READINESS-CLOSEOUT`
- `MTP-190-REMAINING-COMPATIBILITY-SHELL-AUDIT`
- `MTP-190-FORBIDDEN-IMPLEMENTATION-AUDIT`
- `MTP-190-UNRESOLVED-FUTURE-GATES`
- `MTP-190-STAGE-CLOSEOUT-VALIDATION`

## MTP-190 禁止

- 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段 Todo。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、Trader runtime、Portfolio runtime、RiskEngine runtime、ExecutionEngine runtime、ExecutionClient implementation、OMS implementation、broker adapter、signed endpoint、account endpoint / listenKey、private stream runtime、account snapshot runtime、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、emergency stop、shutdown、restore 或 production operations command。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-191 Trader-owned Strategy Module Boundary Correction Validation

MTP-191 必须运行：

- `git diff --check`
- `bash checks/run.sh`

MTP-191 的验收要求：

- `docs/architecture/module-boundary.md` 必须包含 `MTP-191-TRADER-OWNED-STRATEGY-CANONICAL-PATH`、`MTP-191-TRADER-CONTAINER-SPLIT`、`MTP-191-STRATEGYBINDINGS-NON-LANDING-GUARD`、`MTP-191-INDEPENDENT-ENGINE-MODULES-GUARD`、`MTP-191-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD` 和 `MTP-191-BOUNDARY-CORRECTION-VALIDATION`。
- `docs/domain/context.md` 必须包含同名 shared language anchors。
- `docs/contracts/target-module-physical-layout-source-migration-contract.md` 必须把 forward-looking concrete strategy canonical path 修正为 `Sources/Trader/Strategies/<strategy>/`。
- `Sources/Strategies/<strategy>/`、`Sources/Strategies/EMA/` 和 `Sources/Strategies/OrderBookImbalance/` 只能作为 compatibility / superseded / historical path 出现，不再作为 canonical path。
- `Sources/Trader/StrategyBindings/` 必须只作为 generic binding protocol / coordination adapter contract，不作为具体 strategy implementation landing path。
- PR 前必须确认本 issue 没有移动 `Sources`、没有修改 `Package.swift`、没有写业务代码，没有提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

MTP-191 必须建立的主要 anchors：

- `MTP-191-TRADER-OWNED-STRATEGY-CANONICAL-PATH`
- `MTP-191-TRADER-CONTAINER-SPLIT`
- `MTP-191-STRATEGYBINDINGS-NON-LANDING-GUARD`
- `MTP-191-INDEPENDENT-ENGINE-MODULES-GUARD`
- `MTP-191-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`
- `MTP-191-BOUNDARY-CORRECTION-VALIDATION`

## MTP-191 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 Strategy runtime、Trader runtime、live coordinator、broker gateway、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。
- 不把 `Sources/Trader/StrategyBindings/` 写成 EMA、OrderBookImbalance 或未来具体策略的源码落点。
- 不把 Portfolio、RiskEngine、ExecutionEngine 或 ExecutionClient 并入 Trader。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-192 Root Docs Strategy Path Anchor Correction Validation

MTP-192 必须运行：

- `git diff --check`
- `bash checks/run.sh`

MTP-192 的验收要求：

- `BLUEPRINT.md`、`docs/planning/projects/mtpro-trader-owned-strategies-layout-correction-v1-plan.md`、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/latest-verification-summary.md` 和 `docs/automation/automation-readiness.md` 必须把 forward-looking concrete strategy canonical path 写成 `Sources/Trader/Strategies/<strategy>/`。
- Root docs 中保留的 `Sources/Strategies/<strategy>`、`Sources/Strategies/EMA/` 和 `Sources/Strategies/OrderBookImbalance/` 必须明确为 historical / compatibility / superseded / migration-source path，不得表达 MTP-191 之后的 canonical future layout。
- Root docs 中的 MTP-192-era `Trader = Accounts + Strategies + StrategyBindings + Coordination` 只能作为 historical / superseded wording；MTP-205 后 current authoritative relationship 是 `Trader = Accounts + Strategies/EMA + Coordination`。
- `StrategyBindings` retained references, if any, 必须描述为 historical / compatibility / superseded evidence；current binding / adapter semantics 必须写为 `Trader/Coordination/RiskBinding`，不得作为 concrete strategy implementation landing path。
- PR 前必须确认本 issue 没有移动 production source、没有修改 `Package.swift`、没有拆 SwiftPM target graph、没有写业务代码、没有提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

MTP-192 必须建立的主要 anchors：

- `MTP-192-ROOT-DOCS-STRATEGY-PATH-ANCHOR-CORRECTION`
- `MTP-192-HISTORICAL-STRATEGIES-COMPATIBILITY-NOTE`
- `MTP-192-TRADER-CONTAINER-STRATEGYBINDINGS-ROOT-DOCS`
- `MTP-192-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`
- `MTP-192-ROOT-DOCS-ANCHOR-VALIDATION`

## MTP-192 禁止

- 不移动 production source，不新增或修改 Swift production code，不修改 `Package.swift` target graph，不创建 SwiftPM target。
- 不实现 Strategy runtime、Trader runtime、live coordinator、broker gateway、ExecutionClient implementation、OMS implementation、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、Live PRO Console、trading button、live command 或 order form。
- 不把历史 `Sources/Strategies/<strategy>` 改写成当前 canonical path；只能加 forward-looking supersession / compatibility note。
- 不把 `Sources/Trader/StrategyBindings/` 写成 EMA、OrderBookImbalance 或未来具体策略的源码落点。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-193 EMA Trader Strategy Physical Migration Validation

MTP-193 必须运行：

- `git diff --check`
- `swift test --filter CoreTests/testEMACrossStrategyContractGeneratesDeterministicSignalFixture`
- `swift test --filter CoreTests/testPaperActionProposalMapsStrategySignalToPaperOnlyIntentDeterministically`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-193 的验收要求：

- `Sources/Trader/Strategies/EMA/` 必须包含 `EMACross.swift`、`StrategySignals.swift` 和 `PaperActionProposal.swift`。
- `Sources/Strategies/EMA/` 不得继续保留 production source；root docs 中保留的 `Sources/Strategies/EMA/` 必须明确为 MTP-171 / MTP-187 historical evidence、superseded path 或 migration-source path。
- `Package.swift` 必须使用 `"Trader/Strategies/EMA"` 作为 EMA source root，并且不再包含 `"Strategies/EMA"`。
- `Core` SwiftPM product / target 名称继续作为 compatibility envelope，不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- EMA lifecycle、strategy signal、paper/live-neutral proposal、proposal authorization、deterministic fixtures、paper-only no-executable-order boundary 和现有 focused tests 行为必须保持不变。
- MTP-193 不迁移 OrderBookImbalance；MTP-194 后 `Sources/Strategies/OrderBookImbalance/` 不再保留 production source。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-193 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-193 必须建立的主要 anchors：

- `MTP-193-EMA-TRADER-STRATEGIES-PHYSICAL-MIGRATION`
- `MTP-193-EMA-OLD-PATH-REMOVAL-GUARD`
- `MTP-193-CORE-COMPATIBILITY-ENVELOPE-SOURCE-PATH`
- `MTP-193-BEHAVIOR-UNCHANGED-GUARD`
- `MTP-193-NO-RUNTIME-TARGET-GRAPH-GUARD`
- `MTP-193-EMA-PATH-MIGRATION-VALIDATION`

## MTP-193 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 position command。
- 不把 strategy proposal、signal 或 fixture evidence 升级为 executable order command、ExecutionClient request、OMS order、broker order 或 order form payload。
- 不迁移 OrderBookImbalance、StrategyBindings、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-194 OrderBookImbalance Trader Strategy Physical Migration Validation

MTP-194 必须运行：

- `git diff --check`
- `swift test --filter CoreTests/testOrderBookImbalanceStrategyGeneratesStableSignalFixture`
- `swift test --filter CoreTests/testOrderBookImbalanceResearchParityEvidenceCoversBiasAndInputSources`
- `swift test --filter CoreTests/testOrderBookImbalanceRejectsInvalidConfigurationAndInputs`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-194 的验收要求：

- MTP-194 当时必须证明 `Sources/Trader/Strategies/OrderBookImbalance/` 包含 `OrderBookImbalance.swift`；MTP-201 后该路径只作为 historical placement evidence，不再是 current active source root。
- `Sources/Strategies/OrderBookImbalance/` 不得继续保留 production source；root docs 中保留的 `Sources/Strategies/OrderBookImbalance/` 必须明确为 MTP-183 / MTP-187 historical evidence、superseded path 或 migration-source path。
- MTP-194 当时必须证明 `Package.swift` 使用 `"Trader/Strategies/OrderBookImbalance"` 作为 OrderBookImbalance source root，并且不再包含 `"Strategies/OrderBookImbalance"`；MTP-201 后 `Package.swift` 不得再包含 `"Trader/Strategies/OrderBookImbalance"`。
- `Core` SwiftPM product / target 名称继续作为 compatibility envelope，不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- OrderBookImbalance strategy contract、configuration validation、signal sample、bias calculation、snapshot / delta input source evidence、research-only no-short / no-margin / no-real-execution boundary 和现有 focused tests 行为必须保持不变。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-194 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-194 必须建立的主要 anchors：

- `MTP-194-ORDERBOOKIMBALANCE-TRADER-STRATEGIES-PHYSICAL-MIGRATION`
- `MTP-194-ORDERBOOKIMBALANCE-OLD-PATH-REMOVAL-GUARD`
- `MTP-194-CORE-COMPATIBILITY-ENVELOPE-SOURCE-PATH`
- `MTP-194-BEHAVIOR-UNCHANGED-GUARD`
- `MTP-194-NO-RUNTIME-TARGET-GRAPH-GUARD`
- `MTP-194-ORDERBOOKIMBALANCE-PATH-MIGRATION-VALIDATION`

## MTP-194 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不把 research signal、bias、sample 或 fixture evidence 升级为 executable order command、ExecutionClient request、OMS order、broker order、short / margin signal 或 order form payload。
- 不迁移 StrategyBindings、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-195 StrategyBindings Binding Protocol / Coordination Adapter Validation

MTP-195 必须运行：

- `git diff --check`
- `swift test --filter CoreTests/testStrategyBindingsBoundaryEvidenceKeepsConcreteStrategiesOutOfBindings`
- `swift test --filter CoreTests/testPaperActionRiskLinkAllowsPaperProposalWithTraceableContext`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-195 的验收要求：

- MTP-195 historical evidence 曾要求 `Sources/Trader/StrategyBindings/PaperActionRiskLink.swift` 明确 `StrategyBindings` 只表达 generic binding protocol / coordination adapter contract；MTP-202 后该 evidence 由 `Sources/Trader/Coordination/RiskBinding/PaperActionRiskLink.swift` 和 `TraderCoordinationRiskBindingBoundaryEvidence` 接管。
- Current validation 必须证明 `Sources/Trader/StrategyBindings/` 不再作为 active source root 回流，`Sources/Trader/Coordination/RiskBinding/` 不承载 concrete strategy implementation。
- MTP-201 后 concrete active strategy roots 必须只包含 `Sources/Trader/Strategies/EMA/`；OrderBookImbalance 只保留为 `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` historical research evidence。
- `StrategyBindings` 不得直连 ExecutionClient、broker command、OMS command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command、order form 或 executable order command。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-195 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-195 必须建立的主要 anchors：

- `MTP-195-STRATEGYBINDINGS-BINDING-PROTOCOL-ADAPTER-CONTRACT`
- `MTP-195-CONCRETE-STRATEGY-NON-LANDING-GUARD`
- `MTP-195-STRATEGYBINDINGS-COMPATIBILITY-ENVELOPE`
- `MTP-195-NO-DIRECT-EXECUTION-BROKER-OMS-LIVE-GUARD`
- `MTP-195-STRATEGYBINDINGS-BOUNDARY-VALIDATION`

## MTP-195 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不把 StrategyBindings 写成 EMA、OrderBookImbalance 或未来具体 strategy implementation landing path。
- 不把 `PaperActionRiskLink` 升级为真实风险引擎、ExecutionClient request、broker fallback、OMS order、broker order 或 executable order command。
- 不迁移 EMA、OrderBookImbalance、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-196 Trader-owned Strategy Path Validation

MTP-196 必须运行：

- `git diff --check`
- `swift test --filter CoreTests/testTraderOwnedStrategyPathValidationCoversCanonicalOldBindingAndExecutionGuards`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-196 的验收要求：

- Validation 必须直接检查 `Sources/Trader/Strategies/EMA/` 当前 active implementation files，并确认 `Sources/Trader/Strategies/OrderBookImbalance/` 已退休、OrderBookImbalance 只作为 Core research evidence 保留。
- Validation 必须在 `Sources/Strategies/EMA/` 或 `Sources/Strategies/OrderBookImbalance/` 作为当前 implementation directory 回流时失败。
- Validation 必须检查 `Package.swift` current source roots 只使用 `"Trader/Strategies/EMA"` 和 `"Trader/Coordination/RiskBinding"` 相关 source roots，不使用旧 `"Strategies/EMA"`、`"Strategies/OrderBookImbalance"`、`"Trader/Strategies/OrderBookImbalance"` 或 `"Trader/StrategyBindings"` roots。
- Validation 必须覆盖 legacy StrategyBindings references as historical / compatibility / superseded evidence；current non-concrete binding location 是 `Trader/Coordination/RiskBinding`。
- Validation 必须覆盖 no direct ExecutionClient / broker / OMS / live command path。
- `docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-196 mechanical anchors。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-196 必须建立的主要 anchors：

- `MTP-196-TRADER-OWNED-STRATEGY-PATH-VALIDATION`
- `MTP-196-SUPERSEDED-STRATEGIES-PATH-NON-CANONICAL-GUARD`
- `MTP-196-STRATEGYBINDINGS-NON-CONCRETE-STRATEGY-VALIDATION`
- `MTP-196-NO-DIRECT-EXECUTION-PATH-VALIDATION`
- `MTP-196-VALIDATION-ONLY-GUARD`

## MTP-196 禁止

- 不移动 source files，不修改 `Package.swift` source roots。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不把 `Sources/Strategies/<strategy>` 写回 canonical future path。
- 不把 StrategyBindings 写成 EMA、OrderBookImbalance 或未来具体 strategy implementation landing path。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-197 Validation Matrix / Compatibility Envelope / Stage Audit Input Validation

MTP-197 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-197 的验收要求：

- `docs/audit/inputs/mtpro-trader-owned-strategies-layout-correction-v1-stage-audit-input.md` 必须准备 MTP-191 至 MTP-196 的 issue / PR evidence chain、Trader-owned strategy layout closeout、validation matrix closeout、automation readiness closeout、compatibility envelope audit、forbidden implementation audit、unresolved future gates、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- `docs/validation/trading-validation-matrix.md` 必须包含 MTP-197 issue backfill，并把本 Project 的 matrix coverage 固定为 Trader-owned strategy canonical paths、historical `Sources/Strategies/<strategy>` compatibility treatment、StrategyBindings non-landing guard、forbidden direct execution path 和 no runtime / live capability。
- `docs/automation/automation-readiness.md` 与 `checks/automation-readiness.sh` 必须机械检查 MTP-197 audit input、validation matrix、validation plan、latest verification summary 和 no final Stage Code Audit / no next stage boundary。
- MTP-197 只准备 Parent Codex Stage Code Audit 输入材料，不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段 Todo。
- PR 前必须确认 `.codex/*`、`.build/*` 和 `graphify-out/*` 未进入 PR。

MTP-197 必须建立的主要 anchors：

- `MTP-197-TRADER-OWNED-STRATEGIES-LAYOUT-STAGE-CLOSEOUT`
- `MTP-197-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-197-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-197-TRADER-OWNED-STRATEGIES-EVIDENCE-CHAIN`
- `MTP-197-TRADER-OWNED-STRATEGY-LAYOUT-CLOSEOUT`
- `MTP-197-VALIDATION-MATRIX-CLOSEOUT`
- `MTP-197-AUTOMATION-READINESS-CLOSEOUT`
- `MTP-197-FORBIDDEN-IMPLEMENTATION-AUDIT`
- `MTP-197-UNRESOLVED-FUTURE-GATES`
- `MTP-197-STAGE-CLOSEOUT-VALIDATION`

## MTP-197 禁止

- 不移动 source files，不修改 `Package.swift` source roots。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不把 `Sources/Strategies/<strategy>` 写回 canonical future path。
- 不把 StrategyBindings 写成 EMA、OrderBookImbalance 或未来具体 strategy implementation landing path。
- 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段 Todo。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-198 EMA-only Trader Strategy Layout Contract Validation

MTP-198 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-198 的验收要求：

- `docs/contracts/trader-ema-strategy-layout-contract.md` 必须包含 EMA-only Trader strategy layout contract、canonical active EMA path、non-EMA future candidate boundary、StrategyBindings not first-level strategy directory、Trader/Coordination binding responsibility、forbidden strategy path execution bypass taxonomy、no source move / Package.swift / runtime guard 和 validation anchors。
- `docs/architecture/module-boundary.md` 与 `docs/domain/context.md` 必须明确 current active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`。
- `RSI`、`OrderBookImbalance`、`Momentum` 和 `MeanReversion` 必须被描述为 future candidate / future-gated strategy label，不得被写成 current active strategy。
- MTP-201 后 `Sources/Trader/Strategies/OrderBookImbalance/` 必须被描述为已退休，OrderBookImbalance 只保留为 Core research evidence。
- `Sources/Trader/StrategyBindings/` 必须明确不是 first-level Trader strategy directory；binding / adapter semantics 归 `Sources/Trader/Coordination/` responsibility。
- PR 前必须确认本 issue 没有移动 `Sources`、没有修改 `Package.swift`、没有写 Swift business code、没有提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

MTP-198 必须建立的主要 anchors：

- `MTP-198-EMA-ONLY-TRADER-STRATEGY-LAYOUT-CONTRACT`
- `MTP-198-CANONICAL-ACTIVE-EMA-PATH`
- `MTP-198-NON-EMA-FUTURE-CANDIDATE-BOUNDARY`
- `MTP-198-STRATEGYBINDINGS-NOT-FIRST-LEVEL-STRATEGY-DIRECTORY`
- `MTP-198-TRADER-COORDINATION-BINDING-RESPONSIBILITY`
- `MTP-198-FORBIDDEN-STRATEGY-PATH-EXECUTION-BYPASS-TAXONOMY`
- `MTP-198-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`
- `MTP-198-EMA-ONLY-LAYOUT-VALIDATION`

## MTP-198 禁止

- 对 MTP-198 执行本身，不移动 source files、不删除当时仍存在的 `Sources/Trader/Strategies/OrderBookImbalance/`、不移动 `Sources/Trader/StrategyBindings/`、不修改 `Package.swift` source roots；MTP-201 后由 retirement gate 接管并删除 non-EMA active source root。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不把 `RSI`、`OrderBookImbalance`、`Momentum` 或 `MeanReversion` 写成 current active concrete strategy。
- 不把 StrategyBindings 写成 first-level strategy directory 或未来具体 strategy implementation landing path。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-200 Non-EMA Strategy Anchor Audit Validation

MTP-200 必须运行：

- `git diff --check`
- `bash checks/run.sh`

MTP-200 的验收要求：

- `docs/audit/inputs/mtpro-trader-ema-strategy-layout-consolidation-v1-mtp-200-non-ema-anchor-audit.md` 必须枚举 `OrderBookImbalance`、`RSI`、`Momentum`、`MeanReversion` 和 `StrategyBindings` 在 `Sources`、`Tests`、`Package.swift` 和 validation anchors 中的当前状态。
- Audit 必须明确 MTP-200 当时 `OrderBookImbalance` 仍有 active compiled source placement debt、Package compatibility root、research flow / event / persistence / tests dependency；MTP-201 后该 debt 由 retirement gate 关闭，只保留 Core research evidence。
- Audit 必须明确 `RSI`、`Momentum` 和 `MeanReversion` 在 `Sources`、`Tests` 和 `Package.swift` 中没有 exact active anchors。
- Audit 必须明确 `StrategyBindings` 是 binding / coordination adapter evidence，不是 concrete strategy source root，并作为 MTP-202 输入。
- PR 前必须确认本 issue 没有移动 `Sources`、没有修改 `Package.swift`、没有写 Swift business code、没有提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

MTP-200 必须建立的主要 anchors：

- `MTP-200-NON-EMA-STRATEGY-ANCHOR-AUDIT`
- `MTP-200-SOURCE-PACKAGE-CLASSIFICATION`
- `MTP-200-RUNTIME-TEST-DEPENDENCY-CLASSIFICATION`
- `MTP-200-VALIDATION-ANCHOR-CLASSIFICATION`
- `MTP-200-MTP-201-INPUT`
- `MTP-200-MTP-202-INPUT`
- `MTP-200-AUDIT-VALIDATION`
- `MTP-200-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`

## MTP-200 禁止

- 对 MTP-200 audit 本身，不移动 source files、不删除当时仍存在的 `Sources/Trader/Strategies/OrderBookImbalance/`、不移动 `Sources/Trader/StrategyBindings/`、不修改 `Package.swift` source roots；MTP-201 后由 retirement gate 执行 non-EMA active source removal。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不把 `RSI`、`OrderBookImbalance`、`Momentum` 或 `MeanReversion` 写成 current active concrete strategy。
- 不把 StrategyBindings 写成 first-level strategy directory 或未来具体 strategy implementation landing path。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-201 Non-EMA Active Strategy Source Retirement Validation

MTP-201 必须运行：

- `swift test --filter CoreTests/testTraderOwnedStrategyPathValidationCoversCanonicalOldBindingAndExecutionGuards`
- `swift test --filter CoreTests/testOrderBookImbalanceStrategyGeneratesStableSignalFixture`
- `swift test --filter CoreTests/testOrderBookImbalanceResearchParityEvidenceCoversBiasAndInputSources`
- `swift test --filter CoreTests/testOrderBookImbalanceRejectsInvalidConfigurationAndInputs`
- `git diff --check`
- `bash checks/run.sh`

MTP-201 的验收要求：

- Current active concrete strategy source layout 必须 only `Sources/Trader/Strategies/EMA/`。
- `Sources/Trader/Strategies/OrderBookImbalance/` 必须不存在。
- `Package.swift` 必须不包含 `"Trader/Strategies/OrderBookImbalance"` 或 `"Strategies/OrderBookImbalance"`。
- `Sources/Core/Research/OrderBookImbalanceResearchEvidence.swift` 必须保留 OrderBookImbalance research / parity / persistence evidence，且不得被写成 current active strategy source。
- `TraderStrategyBindingsBoundaryFixture` 的 concrete active strategy roots 必须 only EMA；MTP-202 后该 fixture 已由 `TraderCoordinationRiskBindingBoundaryFixture` current fixture 接管。

MTP-201 必须建立的主要 anchors：

- `MTP-201-NON-EMA-ACTIVE-SOURCE-RETIREMENT`
- `MTP-201-EMA-ONLY-ACTIVE-SOURCE-LAYOUT`
- `MTP-201-ORDERBOOKIMBALANCE-RESEARCH-EVIDENCE-RECLASSIFICATION`
- `MTP-201-SOURCE-RETIREMENT-VALIDATION`
- `MTP-201-FORBIDDEN-RUNTIME-GUARD`

## MTP-201 禁止

- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不把 `RSI`、`OrderBookImbalance`、`Momentum` 或 `MeanReversion` 写成 current active concrete strategy。
- 不移动 `Sources/Trader/StrategyBindings/`；该 boundary 由 MTP-202 处理。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-202 Trader Coordination RiskBinding Boundary Validation

MTP-202 必须运行：

- `swift test --filter CoreTests/testTraderCoordinationRiskBindingEvidenceKeepsConcreteStrategiesOutOfBindings`
- `swift test --filter CoreTests/testTraderOwnedStrategyPathValidationCoversCanonicalOldBindingAndExecutionGuards`
- `swift test --filter CoreTests/testPaperActionRiskLinkAllowsPaperProposalWithTraceableContext`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-202 的验收要求：

- `Sources/Trader/Coordination/RiskBinding/PaperActionRiskLink.swift` 必须存在，并继续只表达 paper proposal -> risk query / blocker evidence 的 local coordination adapter。
- `Sources/Trader/StrategyBindings/` 必须不存在，`Package.swift` 必须不包含 `"Trader/StrategyBindings"` source root。
- `Package.swift` 必须包含 `"Trader/Coordination/RiskBinding"` source root，不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- `TraderCoordinationRiskBindingBoundaryEvidence` 必须证明 RiskBinding 不是 concrete strategy implementation landing path，当前 active concrete strategy roots only EMA。
- RiskBinding 不得直连 ExecutionClient、broker command、OMS command、signed/account endpoint、private stream runtime、Live PRO Console、trading button、live command、order form 或 executable order command。
- Docs / automation readiness / validation matrix / latest verification summary 必须包含 MTP-202 anchors。

MTP-202 必须建立的主要 anchors：

- `MTP-202-TRADER-COORDINATION-RISKBINDING-SOURCE-RECLASSIFICATION`
- `MTP-202-STRATEGYBINDINGS-FIRST-LEVEL-PATH-RETIREMENT`
- `MTP-202-RISKBINDING-NO-EXECUTION-GATEWAY-GUARD`
- `MTP-202-RISKBINDING-VALIDATION`

## MTP-202 禁止

- 不移动 EMA source root，不引入 RSI、OrderBookImbalance、Momentum 或 MeanReversion 为 current active concrete strategy。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不把 RiskBinding 升级为真实风险引擎、ExecutionClient request、broker fallback、OMS order、broker order 或 executable order command。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-203 EMA-only Strategy Path Validation

MTP-203 必须运行：

- `swift test --filter CoreTests/testEMAOnlyActiveStrategyPathValidationRejectsNonEMAAndBindingDrift`
- `swift test --filter 'CoreTests/(testTraderOwnedStrategyPathValidationCoversCanonicalOldBindingAndExecutionGuards|testTraderCoordinationRiskBindingEvidenceKeepsConcreteStrategiesOutOfBindings)'`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-203 的验收要求：

- `Sources/Trader/Strategies/` 的 current active concrete strategy directory set 必须等于 only `EMA`。
- `Sources/Trader/Strategies/EMA/` 必须继续包含 EMA lifecycle、signal 和 paper proposal source files。
- `Sources/Trader/Strategies/RSI/`、`Sources/Trader/Strategies/OrderBookImbalance/`、`Sources/Trader/Strategies/Momentum/`、`Sources/Trader/Strategies/MeanReversion/`、`Sources/Strategies/<non-EMA>/`、`Tests/Trader/Strategies/<non-EMA>/` 和 `Tests/Strategies/<non-EMA>/` 不得作为 active source / active test root 回流。
- `Package.swift` 必须只包含 `"Trader/Strategies/EMA"` 这一条 active Trader strategy source root；不得包含 `"Trader/Strategies/<non-EMA>"`、`"Strategies/<non-EMA>"` 或 `"Trader/StrategyBindings"`。
- `Sources/Trader/StrategyBindings/` 必须继续不存在；binding semantics 必须继续位于 `Sources/Trader/Coordination/RiskBinding/`。
- Validation 不得建立 network-dependent tests，不得启动 runtime、live endpoint、ExecutionClient、OMS、broker gateway、live command 或 real order lifecycle。
- Docs / automation readiness / validation matrix / latest verification summary 必须包含 MTP-203 anchors。

MTP-203 必须建立的主要 anchors：

- `MTP-203-EMA-ONLY-ACTIVE-STRATEGY-DIRECTORY-GUARD`
- `MTP-203-NON-EMA-ACTIVE-SOURCE-TEST-PACKAGE-DRIFT-GUARD`
- `MTP-203-STRATEGYBINDINGS-FIRST-LEVEL-DRIFT-GUARD`
- `MTP-203-EMA-ONLY-PATH-VALIDATION`

## MTP-203 禁止

- 不移动 production source，不新增或删除 concrete strategy implementation。
- 不把 RSI、OrderBookImbalance、Momentum 或 MeanReversion 引入为 current active concrete strategy。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-204 Trader EMA Strategy Layout Stage Closeout Validation

MTP-204 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-204 的验收要求：

- `docs/audit/inputs/mtpro-trader-ema-strategy-layout-consolidation-v1-stage-audit-input.md` 必须存在，并明确是 stage audit input material，不是最终 Stage Code Audit Report。
- Stage audit input 必须汇总 MTP-198 至 MTP-203 的 issue / PR / merge commit / required check evidence。
- Validation matrix 必须覆盖 EMA-only active layout、non-EMA future candidate / historical evidence、OrderBookImbalance Core research evidence、Trader Coordination RiskBinding boundary 和 deterministic path validation。
- Compatibility envelope 必须明确 `Core` 仍是 compatibility envelope，不表示 SwiftPM target graph split、Strategy runtime 或 Trader runtime 完成。
- Stage audit input 必须包含 forbidden implementation audit、unresolved future gates、Root Docs Delta input 和 Parent Codex Stage Code Audit handoff checklist。
- MTP-204 不得输出最终 Stage Code Audit Report，不得设置 Linear Project `Completed`，不得创建下一 Project / Issue，不得推进下一阶段 Todo。
- Docs / automation readiness / validation matrix / latest verification summary 必须包含 MTP-204 anchors。

MTP-204 必须建立的主要 anchors：

- `MTP-204-TRADER-EMA-LAYOUT-STAGE-CLOSEOUT`
- `MTP-204-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-204-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-204-VALIDATION-MATRIX-CLOSEOUT`
- `MTP-204-COMPATIBILITY-ENVELOPE-CLOSEOUT`
- `MTP-204-AUTOMATION-READINESS-CLOSEOUT`
- `MTP-204-FORBIDDEN-IMPLEMENTATION-AUDIT`
- `MTP-204-UNRESOLVED-FUTURE-GATES`
- `MTP-204-STAGE-CLOSEOUT-VALIDATION`
- `MTP-204-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`

## MTP-204 禁止

- 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`。
- 不创建下一 Project / Issue，不推进下一阶段 Todo，不启动新的 `@002 / PAR`。
- 不移动 production source，不新增或删除 concrete strategy implementation。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command 或 order form。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-205 Trader Accounts / Coordination Compatibility Contract Validation

MTP-205 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-205 的验收要求：

- `docs/contracts/trader-accounts-coordination-compatibility-contract.md` 必须存在，并定义 `Trader = Accounts + Strategies/EMA + Coordination`。
- `docs/planning/projects/mtpro-trader-accounts-coordination-compatibility-consolidation-v1-plan.md` 必须存在，并记录 MTP-205 至 MTP-211 canonical issue order、dependencies、WIP=1 和 non-executable boundary。
- `Trader/Accounts` 必须只表达 account identity、source identity 和 future real account gate，不拥有 cash、positions、PnL、margin、leverage、real account payload、account endpoint payload、listenKey state 或 private stream runtime state。
- 当前 active concrete strategy 必须 only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`。
- `RiskBinding` 必须固定在 `Sources/Trader/Coordination/RiskBinding/`，只作为 local coordination adapter contract。
- `Sources/Trader/StrategyBindings/` 和 `Sources/Strategies/` 必须退休 active source path 语义，只能作为 historical / compatibility / superseded / migration-source context。
- MTP-205 不得移动 production source，不得修改 `Package.swift`，不得新增 SwiftPM target、product 或 dependency，不得做 target graph split。
- Docs / automation readiness / validation matrix / latest verification summary 必须包含 MTP-205 anchors。

MTP-205 必须建立的主要 anchors：

- `MTP-205-TRADER-ACCOUNTS-COORDINATION-COMPATIBILITY-CONTRACT`
- `MTP-205-TRADER-CONTAINER-AUTHORITATIVE-RELATIONSHIP`
- `MTP-205-TRADER-ACCOUNTS-IDENTITY-SOURCE-FUTURE-GATE`
- `MTP-205-EMA-ONLY-STRATEGY-CURRENT-ACTIVE-GUARD`
- `MTP-205-RISKBINDING-COORDINATION-BOUNDARY`
- `MTP-205-STRATEGYBINDINGS-SOURCES-STRATEGIES-RETIRED-ACTIVE-PATHS`
- `MTP-205-PACKAGE-COMPATIBILITY-ENVELOPE-CLEANUP-ENTRY`
- `MTP-205-FORBIDDEN-CAPABILITY-TAXONOMY`
- `MTP-205-TRADER-ACCOUNTS-COORDINATION-COMPATIBILITY-VALIDATION`

## MTP-205 禁止

- 不移动 production source，不写 Swift business code。
- 不修改 `Package.swift`；Package cleanup 只能由后续唯一 executable `MTP-209` 授权。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Strategy runtime、strategy scheduler、live quoter、live hedger、Trader runtime、live coordinator、broker gateway、ExecutionClient gateway、OMS gateway、account session runtime、broker position sync、signed endpoint、account endpoint、listenKey、private stream runtime、broker adapter、`LiveExecutionAdapter`、OMS、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form、short command、margin command 或 futures command。
- 不把 `Sources/Trader/StrategyBindings/` 或 `Sources/Strategies/` 写回 current active source path。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-206 Trader Accounts Source Boundary Validation

MTP-206 必须运行：

- `git diff --check`
- `swift test --filter CoreTests/testMTP206`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-206 的验收要求：

- `Sources/Trader/Accounts/TraderAccountContext.swift` 必须存在。
- `Package.swift` 必须把 `"Trader/Accounts"` 纳入 `Core` compatibility envelope source root。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- `TraderAccountContext` 必须包含 account identity、source identity、source kind 和 future real account gate。
- `TraderAccountContext` 必须拒绝 cash、positions、PnL、margin、leverage ownership。
- `TraderAccountContext` 必须拒绝 signed endpoint、account endpoint、listenKey、broker payload、ExecutionClient、OMS、broker gateway、account snapshot runtime、Trader runtime 和 Live runtime bypass。
- Docs / automation readiness / validation matrix / latest verification summary 必须包含 MTP-206 anchors。

MTP-206 必须建立的主要 anchors：

- `MTP-206-TRADER-ACCOUNTS-SOURCE-BOUNDARY`
- `MTP-206-ACCOUNT-IDENTITY-SOURCE-FUTURE-GATE`
- `MTP-206-NO-FINANCIAL-STATE-OWNERSHIP`
- `MTP-206-NO-ENDPOINT-LISTENKEY-BROKER-RUNTIME`
- `MTP-206-PORTFOLIO-RISK-EXECUTION-RELATIONSHIP`
- `MTP-206-TRADER-ACCOUNTS-BOUNDARY-VALIDATION`

## MTP-206 禁止

- 不读取真实账户，不读取 broker/account payload。
- 不拥有 cash、positions、PnL、margin、leverage、buying power、broker position 或 broker account state。
- 不接 signed endpoint、account endpoint、listenKey 或 private WebSocket runtime。
- 不实现 account snapshot runtime、Trader runtime、Strategy runtime、Live runtime、ExecutionClient、OMS、broker gateway、real order lifecycle、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command 或 order form。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-207 Trader Account Context Validation Wiring

MTP-207 必须运行：

- `git diff --check`
- `swift test --filter CoreTests/testMTP207`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-207 的验收要求：

- Focused tests 必须覆盖 `Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Coordination/RiskBinding/` 的 validation wiring。
- Tests 必须证明 `TraderAccountContext` 不拥有 cash、positions、PnL、margin、leverage。
- Tests 必须证明 no broker/account payload dependency、no listenKey、no signed/account endpoint。
- Tests 必须证明 no ExecutionClient / OMS / broker gateway / Trader runtime / Live runtime bypass。
- Docs / automation readiness / validation matrix / latest verification summary 必须包含 MTP-207 anchors。

MTP-207 必须建立的主要 anchors：

- `MTP-207-TRADER-ACCOUNT-CONTEXT-VALIDATION-WIRING`
- `MTP-207-ACCOUNTS-EMA-RISKBINDING-COVERAGE`
- `MTP-207-BROKER-PAYLOAD-LISTENKEY-BYPASS-GUARD`
- `MTP-207-VALIDATION-ONLY-NO-RUNTIME-GUARD`
- `MTP-207-TRADER-ACCOUNT-CONTEXT-VALIDATION`

## MTP-207 禁止

- 不实现 account runtime、Trader runtime、Strategy runtime 或 Live runtime。
- 不读取真实账户，不读取 broker/account payload。
- 不接 signed endpoint、account endpoint / listenKey，不实现 private WebSocket runtime。
- 不实现 ExecutionClient、OMS、broker gateway、real order lifecycle、Live PRO Console、trading button、live command 或 order form。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-208 Root Docs StrategyBindings Wording Retirement Validation

MTP-208 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-208 的验收要求：

- Root / high-weight docs 不得把 `StrategyBindings` 写成 current active source path、Trader 下一级策略目录或 concrete strategy implementation landing path。
- Retained `StrategyBindings` references 必须明确为 historical / compatibility / superseded evidence。
- Current binding / adapter location 必须写为 `Sources/Trader/Coordination/RiskBinding/`。
- Current active concrete strategy 必须 only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`。
- 不修改 `Package.swift`，不移动 production source，不实现 runtime / live / broker / L4 capability。

MTP-208 必须建立的主要 anchors：

- `MTP-208-STRATEGYBINDINGS-ACTIVE-WORDING-RETIREMENT`
- `MTP-208-TRADER-COORDINATION-RISKBINDING-CURRENT-LOCATION`
- `MTP-208-EMA-ONLY-ACTIVE-STRATEGY-DOC-GUARD`
- `MTP-208-NO-SOURCE-MOVE-PACKAGE-RUNTIME-GUARD`
- `MTP-208-ROOT-DOCS-WORDING-VALIDATION`

## MTP-208 禁止

- 不移动 production source，不修改 `Package.swift`，不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不实现 Trader runtime、Strategy runtime、Live runtime、ExecutionClient、OMS、broker gateway、real order lifecycle、Live PRO Console、trading button、live command 或 order form。
- 不把 `StrategyBindings` 写成 current active source path、Trader 下一级策略目录、concrete strategy implementation landing path 或 execution shortcut。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-209 Package Stale Strategies Compatibility Exclude Cleanup Validation

MTP-209 必须运行：

- `swift package describe`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-209 的验收要求：

- `Package.swift` 不得再包含 Runtime / App target exclude list 中的 stale peer-level `"Strategies"` entry。
- `swift package describe` 不得再输出 `Sources/Strategies` invalid exclude warning。
- `Package.swift` 必须继续保留 `"Trader/Accounts"`、`"Trader/Strategies/EMA"` 和 `"Trader/Coordination/RiskBinding"` source roots。
- `Sources/Strategies/` 目录不得回流为 active source root。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不移动 production source，不实现 runtime / live / broker / L4 capability。
- Docs / automation readiness / validation matrix / latest verification summary 必须包含 MTP-209 anchors。

MTP-209 必须建立的主要 anchors：

- `MTP-209-PACKAGE-STALE-STRATEGIES-EXCLUDE-CLEANUP`
- `MTP-209-COMPATIBILITY-ENVELOPE-TARGET-GRAPH-PRESERVATION`
- `MTP-209-NO-ACTIVE-SOURCES-STRATEGIES-GUARD`
- `MTP-209-NO-RUNTIME-LIVE-BROKER-L4-GUARD`
- `MTP-209-PACKAGE-CLEANUP-VALIDATION`

## MTP-209 禁止

- 不新增、不删除、不重命名 SwiftPM target、product 或 dependency。
- 不把 `Strategies` 或 `Trader` 拆成独立 SwiftPM target。
- 不移动 production source，不恢复 `Sources/Strategies/` active root。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-210 Trader Container Completeness Validation

MTP-210 必须运行：

- `git diff --check`
- `swift test --filter CoreTests/testMTP210`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-210 的验收要求：

- Focused XCTest 必须验证 `Sources/Trader/` current directory set 只包含 `Accounts`、`Coordination` 和 `Strategies`。
- Focused XCTest 必须验证 `Sources/Trader/Accounts/TraderAccountContext.swift` exists。
- Focused XCTest 必须验证 `Sources/Trader/Strategies/EMA/` is only active strategy root。
- Focused XCTest 必须验证 `Sources/Trader/Coordination/RiskBinding/` is binding location。
- Validation 必须阻断 active `Sources/Trader/StrategyBindings`、peer-level `Sources/Strategies`、`Tests/Trader/StrategyBindings` 和 `Tests/Strategies` 回流。
- Validation 必须阻断 stale Package `"Strategies"` exclude、`"Trader/StrategyBindings"` source root、non-EMA strategy root、`Strategies` target 和 `Trader` target 回流。
- 不新增 SwiftPM target、product 或 dependency，不做 target graph split。
- 不移动 production source，不实现 runtime / live / broker / L4 capability。
- Docs / automation readiness / validation matrix / latest verification summary 必须包含 MTP-210 anchors。

MTP-210 必须建立的主要 anchors：

- `MTP-210-TRADER-CONTAINER-COMPLETENESS-VALIDATION`
- `MTP-210-ACCOUNTS-EMA-RISKBINDING-ONLY-COVERAGE`
- `MTP-210-RETIRED-PATH-DRIFT-BLOCK`
- `MTP-210-NO-TARGET-GRAPH-RUNTIME-LIVE-GUARD`
- `MTP-210-TRADER-COMPLETENESS-VALIDATION`

## MTP-210 禁止

- 不新增、不删除、不重命名 SwiftPM target、product 或 dependency。
- 不把 `Strategies` 或 `Trader` 拆成独立 SwiftPM target。
- 不移动 production source，不恢复 `Sources/Strategies/`、`Sources/Trader/StrategyBindings/` 或 non-EMA active strategy root。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-211 Trader Accounts / Coordination Stage Closeout Validation

MTP-211 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-211 的验收要求：

- `docs/audit/inputs/mtpro-trader-accounts-coordination-compatibility-consolidation-v1-stage-audit-input.md` 必须存在。
- Stage audit input material 必须覆盖 MTP-205 至 MTP-210 的 PR evidence、merge commit、required check、Trader container compatibility closeout、validation matrix closeout、compatibility envelope closeout、forbidden implementation audit、Root Docs Delta input 和 Stage Code Audit handoff checklist。
- Validation matrix 必须包含 MTP-211 issue backfill。
- Automation readiness、module-boundary、domain context、validation plan 和 latest verification summary 必须包含 MTP-211 anchors。
- Stage audit input 必须明确本文档不是最终 Stage Code Audit Report，最终报告仍由 Parent Codex 在全部 issue Done 且 Project Completed 后单独输出。
- 必须确认 no Graphify、no Figma、no `.codex/*`、no `graphify-out/*`、no next Project / Issue、no next Todo、no runtime、no live、no broker、no L4 capability。

MTP-211 必须建立的主要 anchors：

- `MTP-211-TRADER-ACCOUNTS-COORDINATION-STAGE-CLOSEOUT`
- `MTP-211-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-211-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-211-EVIDENCE-CHAIN`
- `MTP-211-TRADER-CONTAINER-COMPATIBILITY-CLOSEOUT`
- `MTP-211-VALIDATION-MATRIX-CLOSEOUT`
- `MTP-211-COMPATIBILITY-ENVELOPE-CLOSEOUT`
- `MTP-211-FORBIDDEN-IMPLEMENTATION-AUDIT`
- `MTP-211-STAGE-CLOSEOUT-VALIDATION`
- `MTP-211-NO-GRAPHIFY-FIGMA-NEXT-STAGE-MUTATION`
- `MTP-211-ROOT-DOCS-DELTA-INPUT`
- `MTP-211-STAGE-CODE-AUDIT-HANDOFF`

## MTP-211 禁止

- 不输出最终 Stage Code Audit Report。
- 不设置 Linear Project `Completed`。
- 不创建下一 Project / Issue。
- 不推进下一阶段 Todo。
- 不新增、不删除、不重命名 SwiftPM target、product 或 dependency。
- 不拆 SwiftPM target graph，不移动 production source。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、real order lifecycle、real account read、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-216 SwiftPM Target Graph Split Contract Validation

MTP-216 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-216 的验收要求：

- `docs/contracts/swiftpm-target-graph-split-contract.md` 必须存在。
- Contract 必须定义 current compatibility envelope snapshot、canonical target graph baseline、dependency direction contract、forbidden import paths、Trader-owned strategies target boundary、downstream split sequence、Package split non-authorization 和 no runtime / live / broker / L4 boundary。
- `architecture.md`、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-216 anchors。
- MTP-216 不得修改 `Package.swift` target graph、products、dependencies、source roots 或 exclude list。
- MTP-216 不得移动 production source 或 tests，不得新增 SwiftPM target / product / dependency，不得退休 compatibility envelope。
- Contract 必须保留 current active concrete strategy only `EMA`，canonical active path only `Sources/Trader/Strategies/EMA/`，后续多策略 path 为 `Sources/Trader/Strategies/<strategy>/`。
- Contract 必须禁止 TraderStrategies / Trader direct ExecutionClient、broker、OMS、Workbench / Dashboard command path。

MTP-216 必须建立的主要 anchors：

- `MTP-216-SWIFTPM-TARGET-GRAPH-SPLIT-CONTRACT`
- `MTP-216-CURRENT-COMPATIBILITY-ENVELOPE-SNAPSHOT`
- `MTP-216-CANONICAL-TARGET-GRAPH-BASELINE`
- `MTP-216-DEPENDENCY-DIRECTION-CONTRACT`
- `MTP-216-FORBIDDEN-IMPORT-PATHS`
- `MTP-216-TRADER-OWNED-STRATEGIES-TARGET-BOUNDARY`
- `MTP-216-MODULE-TO-TARGET-SPLIT-SEQUENCE`
- `MTP-216-PACKAGE-SPLIT-NON-AUTHORIZATION`
- `MTP-216-NO-RUNTIME-LIVE-BROKER-L4`
- `MTP-216-TARGET-GRAPH-CONTRACT-VALIDATION`

## MTP-216 禁止

- 不修改 `Package.swift`。
- 不新增、不删除、不重命名 SwiftPM target、product 或 dependency。
- 不移动 production source，不移动 tests，不退休 compatibility envelope。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-217 Foundation Target Split Validation

MTP-217 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-217 的验收要求：

- `Package.swift` 必须新增 `DomainModel`、`MessageBus` 和 `Database` library products / targets。
- `DomainModel` target 必须能独立编译，且不依赖任何业务 target。
- `MessageBus` target 必须只依赖 `DomainModel`。
- `Database` target 必须依赖 `DomainModel`、`MessageBus`、`CSQLite` 和 macOS 条件 `DuckDB` implementation dependency。
- `Core` / `Persistence` compatibility envelope 必须保留，既有 `Sources/DomainModel/`、`Sources/MessageBus/` 和 `Sources/Database/Projections/` behavior 不得改变。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须直接 import `DomainModel`、`MessageBus` 和 `Database`，验证 dependency direction、retained compatibility envelope 和 no higher-layer runtime / broker / UI drift。
- `docs/contracts/swiftpm-target-graph-split-contract.md`、`architecture.md`、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-217 anchors。

MTP-217 必须建立的主要 anchors：

- `MTP-217-FOUNDATION-TARGET-SPLIT-EVIDENCE`
- `MTP-217-DOMAINMODEL-TARGET-SPLIT`
- `MTP-217-MESSAGEBUS-TARGET-SPLIT`
- `MTP-217-DATABASE-TARGET-SPLIT`
- `MTP-217-FOUNDATION-DEPENDENCY-DIRECTION`
- `MTP-217-FOUNDATION-COMPATIBILITY-ENVELOPE-RETAINED`
- `MTP-217-TARGETGRAPH-TEST-EVIDENCE`
- `MTP-217-NO-RUNTIME-LIVE-BROKER-L4-GUARD`
- `MTP-217-FOUNDATION-TARGET-SPLIT-VALIDATION`

## MTP-217 禁止

- 不退休 `Core`、`Persistence` 或其他 compatibility envelope。
- 不把既有 `Sources/MessageBus/` paper routing / strategy / portfolio / risk / execution evidence coupling 强行搬入 foundation target。
- 不把既有 SQLite / DuckDB projection implementation 改成 Workbench schema、broker payload store、account payload archive 或 live runtime persistence。
- 不迁移 DataClient、DataEngine、Cache、TraderStrategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-218 Data Target Split Validation

MTP-218 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-218 的验收要求：

- `Package.swift` 必须新增 `DataClient`、`DataEngine` 和 `Cache` library products / targets。
- `DataClient` target 必须只依赖 `DomainModel`，且只表达 public read-only data boundary。
- `Cache` target 必须只依赖 `DomainModel` 和 `MessageBus`，且只表达 read-model state surface。
- `DataEngine` target 必须依赖 `DomainModel`、`DataClient`、`MessageBus` 和 `Cache`，且只表达 ingest / replay / quality boundary。
- `Adapters` / `Core` / `Runtime` compatibility envelope 必须保留，既有 Binance public data、cache、scenario replay、data quality 和 ingest behavior 不得改变。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须直接 import `DataClient`、`DataEngine` 和 `Cache`，验证 dependency direction、retained compatibility envelope 和 no signed / account / listenKey / broker / runtime drift。
- `docs/contracts/swiftpm-target-graph-split-contract.md`、`architecture.md`、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-218 anchors。

MTP-218 必须建立的主要 anchors：

- `MTP-218-DATA-TARGET-SPLIT-EVIDENCE`
- `MTP-218-DATACLIENT-TARGET-SPLIT`
- `MTP-218-CACHE-TARGET-SPLIT`
- `MTP-218-DATAENGINE-TARGET-SPLIT`
- `MTP-218-DATACLIENT-DATAENGINE-CACHE-DEPENDENCY-DIRECTION`
- `MTP-218-PUBLIC-READ-ONLY-DATA-BOUNDARY`
- `MTP-218-READMODEL-STATE-SURFACE`
- `MTP-218-DATA-COMPATIBILITY-ENVELOPE-RETAINED`
- `MTP-218-TARGETGRAPH-TEST-EVIDENCE`
- `MTP-218-NO-SIGNED-ACCOUNT-BROKER-GUARD`
- `MTP-218-DATA-TARGET-SPLIT-VALIDATION`

## MTP-218 禁止

- 不退休 `Core`、`Adapters`、`Runtime` 或其他 compatibility envelope。
- 不把既有 Binance public market data implementation 搬成 signed/account/private stream runtime。
- 不把 Cache 改成 durable store、Database schema owner、broker state cache、account payload store 或 UI command source。
- 不把 DataEngine 改成 streaming runtime、private stream runtime、broker route、account endpoint route 或 Workbench / Dashboard route。
- 不迁移 TraderStrategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-219 Trader / Portfolio / Risk Target Split Validation

MTP-219 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-219 的验收要求：

- `Package.swift` 必须新增 `TraderStrategies`、`Trader`、`Portfolio` 和 `RiskEngine` library products / targets。
- `TraderStrategies` target 必须依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio` 和 `RiskEngine`，并保持 current active concrete strategy only `EMA`。
- `Trader` target 必须依赖 `DomainModel`、`MessageBus`、`Cache`、`TraderStrategies`、`Portfolio` 和 `RiskEngine`，并把 `ExecutionEngine` dependency 延后到 MTP-220。
- `Portfolio` target 必须依赖 `DomainModel`、`MessageBus`、`Cache` 和 `Database`，且保持独立 financial state projection boundary。
- `RiskEngine` target 必须依赖 `DomainModel`、`MessageBus`、`Cache` 和 `Portfolio`，且保持 pre-execution risk boundary。
- `Core` compatibility envelope 必须保留，既有 Trader / EMA / RiskBinding / Portfolio / RiskEngine behavior 不得改变。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须直接 import `TraderStrategies`、`Trader`、`Portfolio` 和 `RiskEngine`，验证 dependency direction、Trader container completeness、EMA-only active strategy 和 no direct execution / broker / runtime drift。
- `docs/contracts/swiftpm-target-graph-split-contract.md`、`architecture.md`、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-219 anchors。

MTP-219 必须建立的主要 anchors：

- `MTP-219-TRADER-PORTFOLIO-RISK-TARGET-SPLIT-EVIDENCE`
- `MTP-219-TRADERSTRATEGIES-TARGET-SPLIT`
- `MTP-219-TRADER-TARGET-SPLIT`
- `MTP-219-PORTFOLIO-TARGET-SPLIT`
- `MTP-219-RISKENGINE-TARGET-SPLIT`
- `MTP-219-TRADER-PORTFOLIO-RISK-DEPENDENCY-DIRECTION`
- `MTP-219-EMA-ONLY-ACTIVE-STRATEGY-BOUNDARY`
- `MTP-219-TRADER-CONTAINER-ACCOUNTS-EMA-COORDINATION`
- `MTP-219-PORTFOLIO-SEPARATE-FROM-TRADER-ACCOUNT`
- `MTP-219-PRE-EXECUTION-RISK-BOUNDARY`
- `MTP-219-TRADER-PORTFOLIO-RISK-COMPATIBILITY-ENVELOPE-RETAINED`
- `MTP-219-TARGETGRAPH-TEST-EVIDENCE`
- `MTP-219-NO-DIRECT-EXECUTION-GUARD`
- `MTP-219-TRADER-PORTFOLIO-RISK-TARGET-SPLIT-VALIDATION`

## MTP-219 禁止

- 不退休 `Core` 或其他 compatibility envelope。
- 不把 `TraderStrategies` 改成 Strategy runtime、strategy scheduler、broker command producer 或 UI command source。
- 不把 `Trader` 改成 Trader runtime、live coordinator、ExecutionClient direct caller、OMS gateway、broker gateway 或 account endpoint reader。
- 不把 `Portfolio` 改成 Trader account context、real account state reader、broker payload store 或 account endpoint payload store。
- 不把 `RiskEngine` 改成 live risk runtime、ExecutionClient wrapper、broker gateway、OMS path 或 executable order command source。
- 不新增 RSI、OrderBookImbalance、Momentum、MeanReversion 或其他 active concrete strategy source。
- 不迁移 ExecutionEngine、ExecutionClient、Workbench 或 Dashboard。
- 不实现 Live runtime、ExecutionClient implementation、OMS、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-220 ExecutionEngine / ExecutionClient Target Split Validation

MTP-220 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-220 的验收要求：

- `Package.swift` 必须新增 `ExecutionClient` 和 `ExecutionEngine` library products / targets。
- `ExecutionClient` target 必须依赖 `DomainModel` 和 `MessageBus`，并保持 future gate / protocol boundary only。
- `ExecutionEngine` target 必须依赖 `DomainModel`、`MessageBus`、`Cache`、`Portfolio`、`RiskEngine` 和 `ExecutionClient`，并保持 paper / simulated lifecycle boundary。
- `Trader` target 必须把 MTP-219 延后的 `ExecutionEngine` dependency 解析为正式 target dependency，但仍不得直连 `ExecutionClient`、broker、OMS 或 UI command surface。
- `Core` compatibility envelope 必须保留，既有 ExecutionEngine / ExecutionClient future gate implementation 不得迁移或升级为 live runtime。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须直接 import `ExecutionClient` 和 `ExecutionEngine`，验证 dependency direction、Trader dependency resolution、ExecutionClient future gate 和 no broker / OMS / real order / endpoint drift。
- `docs/contracts/swiftpm-target-graph-split-contract.md`、`architecture.md`、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-220 anchors。

MTP-220 必须建立的主要 anchors：

- `MTP-220-EXECUTION-TARGET-SPLIT-EVIDENCE`
- `MTP-220-EXECUTIONCLIENT-TARGET-SPLIT`
- `MTP-220-EXECUTIONENGINE-TARGET-SPLIT`
- `MTP-220-RISKENGINE-EXECUTIONENGINE-EXECUTIONCLIENT-DIRECTION`
- `MTP-220-TRADER-EXECUTIONENGINE-DEPENDENCY-RESOLVED`
- `MTP-220-EXECUTIONCLIENT-FUTURE-GATE-ONLY`
- `MTP-220-EXECUTION-COMPATIBILITY-ENVELOPE-RETAINED`
- `MTP-220-TARGETGRAPH-TEST-EVIDENCE`
- `MTP-220-NO-BROKER-OMS-REAL-ORDER-GUARD`
- `MTP-220-EXECUTION-TARGET-SPLIT-VALIDATION`

## MTP-220 禁止

- 不退休 `Core` 或其他 compatibility envelope。
- 不把 `ExecutionClient` 改成 broker SDK wrapper、exchange venue client、signed request builder、credential / secret / keychain storage、account endpoint reader、listenKey manager、private WebSocket connector、order submit / cancel / replace、execution report parser、broker fill parser 或 reconciliation runtime。
- 不把 `ExecutionEngine` 改成 live execution runtime、OMS implementation、broker gateway、real order state machine、execution report ingestion、broker fill ingestion 或 reconciliation runtime。
- 不让 `RiskEngine` 直连 broker / ExecutionClient，不让 `Trader` 直连 ExecutionClient / broker / OMS / UI command surface。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-221 Dashboard Read-model-only Target Validation

MTP-221 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-221 的验收要求：

- `Package.swift` 不得包含 `Workbench` library product / target。
- `Sources/Workbench/` 和 `Sources/Workbench/TargetGraph/WorkbenchTargetBoundary.swift` 必须不存在。
- `Dashboard` executable target 必须直接依赖 `Core` / `Persistence`，并编译 `DashboardApplication`、`DashboardTargetBoundary`、`DashboardShell`、`ReadModels`、`Report`、`Events` 和 `FutureLiveProConsole`。
- `App` product / target 和 `Sources/AppCompatibility` 必须已退休；`Tests/AppTests` 必须直接 import `Dashboard`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须直接 import `Dashboard`，验证 dependency direction、read-model-only consumption、Workbench retirement 和 no runtime / adapter / schema / UI command drift。
- `docs/contracts/swiftpm-target-graph-split-contract.md`、`architecture.md`、`docs/architecture/module-boundary.md`、`docs/domain/context.md`、`docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-221 anchors。

MTP-221 必须建立的主要 anchors：

- `MTP-221-DASHBOARD-TARGET-SPLIT-EVIDENCE`
- `MTP-221-WORKBENCH-TARGET-RETIRED`
- `MTP-221-DASHBOARD-TARGET-SPLIT`
- `MTP-221-DASHBOARD-READ-MODEL-DEPENDENCY-DIRECTION`
- `MTP-221-READ-MODEL-VIEWMODEL-ONLY`
- `MTP-221-APP-COMPATIBILITY-EXPORT-RETIRED`
- `MTP-221-TARGETGRAPH-TEST-EVIDENCE`
- `MTP-221-NO-UI-COMMAND-RUNTIME-SCHEMA-GUARD`
- `MTP-221-DASHBOARD-TARGET-SPLIT-VALIDATION`

## MTP-221 禁止

- 不恢复 `App` compatibility export；`App` product / target 和 `Sources/AppCompatibility` 必须保持退休。
- 不把 Dashboard 改成 Runtime object owner、Adapter request caller、SQLite / DuckDB schema reader、broker payload reader、account payload reader 或 broker state reader。
- 不新增 Live PRO Console、trading button、live command、order form、stop / shutdown / restore command 或 real trading UI。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-222 Compatibility Anchor Retirement Validation

MTP-222 必须运行：

- scoped fixed-string grep / automation readiness stale anchor checks
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-222 的验收要求：

- `docs/contracts/swiftpm-target-graph-split-contract.md`、`architecture.md`、`docs/architecture/module-boundary.md` 和 `docs/domain/context.md` 必须包含 `MTP-222-CURRENT-TARGET-GRAPH-SNAPSHOT`、`MTP-222-HISTORICAL-COMPATIBILITY-EVIDENCE-RETAINED`、`MTP-222-STALE-ACTIVE-ANCHOR-RETIREMENT` 和 `MTP-222-NO-BEHAVIOR-RUNTIME-LIVE-GUARD`。
- Active target graph snapshot 必须指向 MTP-217 至 MTP-221 已建立并经后续 cleanup 收口的 buildable targets：`DomainModel`、`MessageBus`、`Database`、`DataClient`、`Cache`、`DataEngine`、`Portfolio`、`RiskEngine`、`ExecutionClient`、`ExecutionEngine`、`TraderStrategies`、`Trader` 和 `Dashboard`。
- Retained `Core`、`Adapters`、`Persistence`、`Runtime` 和 `App` targets 只能表达 existing implementation / import compatibility；旧 `Core / Adapters / Persistence / Runtime / App / Dashboard` graph、`Dashboard -> App` 和 `App -> Core, Persistence` 只能作为 historical / before-state evidence 保留。
- 旧 `Sources/Strategies/<strategy>` 和旧 `Sources/Trader/StrategyBindings/` 只能作为 historical / compatibility / superseded evidence；active source anchors 必须指向 `Sources/Trader/Strategies/EMA/` 和 `Sources/Trader/Coordination/RiskBinding/`。
- `docs/validation/trading-validation-matrix.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md` 和 `checks/automation-readiness.sh` 必须包含 MTP-222 anchors。

MTP-222 必须建立的主要 anchors：

- `MTP-222-COMPATIBILITY-ANCHOR-RETIREMENT-EVIDENCE`
- `MTP-222-CURRENT-TARGET-GRAPH-SNAPSHOT`
- `MTP-222-HISTORICAL-COMPATIBILITY-EVIDENCE-RETAINED`
- `MTP-222-STALE-ACTIVE-ANCHOR-RETIREMENT`
- `MTP-222-NO-BEHAVIOR-RUNTIME-LIVE-GUARD`
- `MTP-222-COMPATIBILITY-ANCHOR-RETIREMENT-VALIDATION`

## MTP-222 禁止

- 不移动 production source，不新增、不删除、不重命名 SwiftPM target / product / dependency。
- 不删除 retained `Core`、`Adapters`、`Persistence`、`Runtime` 或 `App` compatibility exports。
- 不把 wording cleanup 升级成 source migration、target deletion、runtime behavior change 或 L4 implementation。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-228 Trader / Portfolio / Risk Targets Real Module Root Migration Validation

MTP-228 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests/testMTP228TraderPortfolioRiskTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-228 的验收要求：

- `Package.swift` 中 `TraderStrategies` target path 必须为 `Sources/Trader/Strategies/EMA`，并且 explicit source 必须为 `TargetGraph/TraderStrategiesTargetBoundary.swift`。
- `Package.swift` 中 `Trader` target path 必须为 `Sources/Trader`，并且 explicit source 必须为 `TargetGraph/TraderTargetBoundary.swift`。
- `Package.swift` 中 `Portfolio` target path 必须为 `Sources/Portfolio`，并且 explicit source 必须为 `TargetGraph/PortfolioTargetBoundary.swift`。
- `Package.swift` 中 `RiskEngine` target path 必须为 `Sources/RiskEngine`，并且 explicit source 必须为 `TargetGraph/RiskEngineTargetBoundary.swift`。
- `Package.swift` 不得再包含 `path: "Sources/TargetGraph/TraderStrategies"`、`path: "Sources/TargetGraph/Trader"`、`path: "Sources/TargetGraph/Portfolio"` 或 `path: "Sources/TargetGraph/RiskEngine"`。
- `Sources/Trader/Strategies/EMA/TargetGraph/TraderStrategiesTargetBoundary.swift`、`Sources/Trader/TargetGraph/TraderTargetBoundary.swift`、`Sources/Portfolio/TargetGraph/PortfolioTargetBoundary.swift` 和 `Sources/RiskEngine/TargetGraph/RiskEngineTargetBoundary.swift` 必须存在。
- `Sources/TargetGraph/TraderStrategies/TraderStrategiesTargetBoundary.swift`、`Sources/TargetGraph/Trader/TraderTargetBoundary.swift`、`Sources/TargetGraph/Portfolio/PortfolioTargetBoundary.swift` 和 `Sources/TargetGraph/RiskEngine/RiskEngineTargetBoundary.swift` 必须不存在。
- `TargetGraphTests` 必须包含 `testMTP228TraderPortfolioRiskTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`，验证 package target path、new boundary file location、retired TargetGraph path、`Trader = Accounts + Strategies/EMA + Coordination` 和 EMA-only active strategy。
- `swift package describe` 不得输出 migrated Trader / Portfolio / Risk roots 的 unhandled-file warnings。
- Dependency direction 必须保持 Portfolio、RiskEngine、TraderStrategies 和 Trader 的 MTP-219 / MTP-220 direction。
- Compatibility envelope 必须保留：`Core` 继续编译 Trader Accounts / EMA / Coordination、Portfolio projection 和 RiskEngine pre-trade / live gate evidence implementation。
- MTP-228 PR evidence 必须确认不迁移 execution / UI targets，不实现 Trader runtime、Strategy runtime、Live runtime、direct strategy-to-execution path、broker / OMS path 或 L4 capability。

MTP-228 必须建立的主要 anchors：

- `MTP-228-TRADER-PORTFOLIO-RISK-REAL-ROOT-TARGET-MIGRATION`
- `MTP-228-TRADER-CONTAINER-DEPENDENCY-DIRECTION-PRESERVED`
- `MTP-228-TARGETGRAPH-TRADER-PORTFOLIO-RISK-ACTIVE-PATH-RETIREMENT`
- `MTP-228-TRADER-PORTFOLIO-RISK-REAL-ROOT-VALIDATION`
- `MTP-228-TRADERSTRATEGIES-REAL-ROOT-TARGET-PATH`
- `MTP-228-TRADER-REAL-ROOT-TARGET-PATH`
- `MTP-228-PORTFOLIO-REAL-ROOT-TARGET-PATH`
- `MTP-228-RISKENGINE-REAL-ROOT-TARGET-PATH`

## MTP-228 禁止

- 不迁移 ExecutionEngine、ExecutionClient、Workbench 或 Dashboard target paths。
- 不新增非 EMA active strategy。
- 不实现 Trader runtime、Strategy runtime 或 Live runtime。
- 不实现 direct strategy-to-execution / broker / OMS path。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不实现 private stream runtime。
- 不删除 `Sources/TargetGraph` 或退休非 Trader / Portfolio / Risk TargetGraph active paths。
- 不新增、删除、重命名 SwiftPM target / product / dependency。
- 不实现 ExecutionClient implementation、OMS implementation、broker gateway、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-229 Execution Targets Real Module Root Migration Validation

MTP-229 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests/testMTP229ExecutionTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-229 的验收要求：

- `Package.swift` 中 `ExecutionClient` target path 必须为 `Sources/ExecutionClient`，并且 explicit source 必须为 `TargetGraph/ExecutionClientTargetBoundary.swift`。
- `Package.swift` 中 `ExecutionEngine` target path 必须为 `Sources/ExecutionEngine`，并且 explicit source 必须为 `TargetGraph/ExecutionEngineTargetBoundary.swift`。
- `Package.swift` 不得再包含 `path: "Sources/TargetGraph/ExecutionClient"` 或 `path: "Sources/TargetGraph/ExecutionEngine"`。
- `Sources/ExecutionClient/TargetGraph/ExecutionClientTargetBoundary.swift` 和 `Sources/ExecutionEngine/TargetGraph/ExecutionEngineTargetBoundary.swift` 必须存在。
- `Sources/TargetGraph/ExecutionClient/ExecutionClientTargetBoundary.swift` 和 `Sources/TargetGraph/ExecutionEngine/ExecutionEngineTargetBoundary.swift` 必须不存在。
- `TargetGraphTests` 必须包含 `testMTP229ExecutionTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`，验证 package target path、new boundary file location、retired TargetGraph path 和 ExecutionClient future gate / no real order lifecycle boundary。
- `swift package describe` 不得输出 migrated Execution target roots 的 unhandled-file warnings。
- Dependency direction 必须保持 `ExecutionClient -> DomainModel / MessageBus` 和 `ExecutionEngine -> DomainModel / MessageBus / Cache / Portfolio / RiskEngine / ExecutionClient`。
- Compatibility envelope 必须保留：`Core` 继续编译 `ExecutionEngine/PaperLifecycle`、`ExecutionEngine/SimulatedExchange`、`ExecutionEngine/OMSFutureGate`、`ExecutionClient/FutureGate` 和 `ExecutionClient/BrokerCapabilityMatrix` implementation / future gate evidence。
- MTP-229 PR evidence 必须确认不迁移 Workbench / Dashboard targets，不实现 ExecutionClient implementation、OMS implementation、broker gateway、real order lifecycle、live command 或 L4 capability。

MTP-229 必须建立的主要 anchors：

- `MTP-229-EXECUTION-REAL-ROOT-TARGET-MIGRATION`
- `MTP-229-EXECUTION-FUTURE-GATE-DEPENDENCY-DIRECTION-PRESERVED`
- `MTP-229-TARGETGRAPH-EXECUTION-ACTIVE-PATH-RETIREMENT`
- `MTP-229-EXECUTION-REAL-ROOT-VALIDATION`
- `MTP-229-EXECUTIONCLIENT-REAL-ROOT-TARGET-PATH`
- `MTP-229-EXECUTIONENGINE-REAL-ROOT-TARGET-PATH`

## MTP-229 禁止

- 不迁移 Workbench 或 Dashboard target paths。
- 不实现 ExecutionClient implementation、OMS implementation 或 broker gateway。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不实现 private stream runtime。
- 不实现 real order lifecycle、submit / cancel / replace、execution report、broker fill 或 reconciliation。
- 不实现 Trader runtime、Strategy runtime、Live runtime、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不删除 `Sources/TargetGraph` 或退休非 Execution TargetGraph active paths。
- 不新增、删除、重命名 SwiftPM target / product / dependency。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-230 Dashboard Target Real Module Root Migration Validation

MTP-230 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests/testMTP230DashboardTargetUsesRealModuleRootAndRetiresWorkbenchTarget`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-230 的验收要求：

- `Package.swift` 中不得包含 `Workbench` target / product 或 `path: "Sources/Workbench"`。
- `Package.swift` 中 `Dashboard` executable target path 必须为 `Sources/Dashboard`，并显式编译 `DashboardApplication.swift`、`DashboardTargetBoundary.swift`、`DashboardShell.swift`、`ReadModels`、`Report`、`Events` 和 `FutureLiveProConsole`。
- `Sources/Workbench/` 和 `Sources/Workbench/TargetGraph/WorkbenchTargetBoundary.swift` 必须不存在。
- `Sources/Dashboard/DashboardShell.swift` 必须存在。
- `DashboardTargetBoundary` 必须包含 `MTP-230-DASHBOARD-REAL-ROOT-TARGET-PATH` 和 `MTP-230-DASHBOARD-OWNS-READ-MODEL-SHELL`。
- `TargetGraphTests` 必须包含 `testMTP230DashboardTargetUsesRealModuleRootAndRetiresWorkbenchTarget`，验证 package target path、new shell location、retired mixed shell path 和 no runtime / live command boundary。
- `swift package describe` 不得输出 Dashboard root 的 unhandled-file warnings。
- Dependency direction 必须保持 `Dashboard -> Core / Persistence`；不得恢复 `App -> Workbench` compatibility re-export 或 `Dashboard -> Workbench`。
- MTP-230 PR evidence 必须确认 UI 仍只消费 Read Model / ViewModel / projection snapshot，不读取 Runtime object、Adapter request、schema、account payload、broker payload 或 broker state，不新增 Live PRO Console、trading button、live command、order form 或 L4 capability。

MTP-230 必须建立的主要 anchors：

- `MTP-230-DASHBOARD-REAL-ROOT-TARGET-MIGRATION`
- `MTP-230-UI-READ-MODEL-ONLY-DEPENDENCY-DIRECTION-PRESERVED`
- `MTP-230-TARGETGRAPH-UI-MIXED-PATH-RETIREMENT`
- `MTP-230-DASHBOARD-REAL-ROOT-VALIDATION`
- `MTP-230-DASHBOARD-REAL-ROOT-TARGET-PATH`

## MTP-230 禁止

- 不实现 Workbench runtime、Dashboard runtime inspector、Live PRO Console、trading button、live command、order form、broker connect UI 或 account connect UI。
- 不读取 Runtime object、Adapter request、SQLite / DuckDB schema、account payload、broker payload 或 broker state。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、real order lifecycle 或 L4 capability。
- 不删除 `Sources/TargetGraph` historical term，不执行 MTP-231 final active path reference retirement。
- 不新增、删除、重命名 SwiftPM target / product / dependency。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-231 TargetGraph Active Path Reference Retirement Validation

MTP-231 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests/testMTP231TargetGraphActivePathReferencesAreRetiredAndRealRootsRemainCurrent`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-231 的验收要求：

- `Sources/TargetGraph/` directory 必须不存在，且不得作为 active source directory 回流。
- `Package.swift` 不得包含 `path: "Sources/TargetGraph..."` 或 active `Sources/TargetGraph/` target path。
- `Package.swift` 必须继续使用真实 module roots：`Sources/DomainModel`、`Sources/MessageBus`、`Sources/Database`、`Sources/DataClient`、`Sources/Cache`、`Sources/DataEngine`、`Sources/Trader/Strategies/EMA`、`Sources/Trader`、`Sources/Portfolio`、`Sources/RiskEngine`、`Sources/ExecutionClient`、`Sources/ExecutionEngine` 和 `Sources/Dashboard`；`Sources/Workbench` 必须保持退休。
- `TargetGraphTests` 必须包含 `testMTP231TargetGraphActivePathReferencesAreRetiredAndRealRootsRemainCurrent`，验证 no active `Sources/TargetGraph` directory、no active package path、real module roots 和 MTP-231 contract anchors。
- Root architecture、module-boundary、contract、validation matrix、latest verification summary、automation readiness 和 `checks/automation-readiness.sh` 必须包含 `MTP-231-TARGETGRAPH-ACTIVE-PATH-REFERENCE-RETIREMENT`、`MTP-231-REAL-MODULE-ROOT-ACTIVE-SNAPSHOT` 和 `MTP-231-TARGETGRAPH-RETIREMENT-VALIDATION` anchors。
- 旧 `Sources/TargetGraph/<Module>` 文字只能作为 MTP-224 至 MTP-230 的 historical / before-state / retired evidence 保留，不得描述 current compiler owner、final module root、feature landing path、runtime owner 或 L4 capability source。
- `swift package describe` 必须 exit 0 且 stderr 为空。
- MTP-231 PR evidence 必须确认 no Symphony、no Graphify、no code-index、no Figma、no `.codex/*`、no `graphify-out/*`。

MTP-231 必须建立的主要 anchors：

- `MTP-231-TARGETGRAPH-ACTIVE-PATH-REFERENCE-RETIREMENT`
- `MTP-231-REAL-MODULE-ROOT-ACTIVE-SNAPSHOT`
- `MTP-231-NO-RUNTIME-LIVE-BROKER-L4-GUARD`
- `MTP-231-TARGETGRAPH-RETIREMENT-VALIDATION`

## MTP-231 禁止

- 不删除 retained compatibility implementation。
- 不引入新的 module layout。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-232 TargetGraph Stage Closeout Validation

MTP-232 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-232 的验收要求：

- `docs/audit/inputs/mtpro-targetgraph-anchor-retirement-real-module-source-root-migration-v1-stage-audit-input.md` 必须存在。
- Stage audit input material 必须包含 `MTP-232-TARGETGRAPH-STAGE-CLOSEOUT`、`MTP-232-ISSUE-PR-EVIDENCE-CHAIN`、`MTP-232-VALIDATION-MATRIX-CLOSEOUT`、`MTP-232-COMPATIBILITY-ENVELOPE-CLOSEOUT`、`MTP-232-AUTOMATION-READINESS-CLOSEOUT`、`MTP-232-FORBIDDEN-IMPLEMENTATION-AUDIT`、`MTP-232-STAGE-CODE-AUDIT-HANDOFF` 和 `MTP-232-STAGE-CLOSEOUT-VALIDATION` anchors。
- Evidence chain 必须覆盖 MTP-224 至 MTP-231 的 PR、required check、merge commit、Linear Done 和 post-issue ledger evidence。
- Validation matrix 必须包含 MTP-232 issue backfill，并把 `TVM-TARGETGRAPH-ANCHOR-RETIREMENT-REAL-MODULE-SOURCE-ROOT-MIGRATION` 收口到 MTP-232 stage audit input。
- Automation readiness 必须覆盖 no active `Sources/TargetGraph` path、no runtime、no L4、no final Stage Code Audit、no Project Completed mutation、no next Project / Issue、no next Todo、no Symphony、no Graphify、no code-index、no Figma 和 no `.codex/*` / `.build/*` / `graphify-out/*` PR submission。
- Latest verification summary 必须记录 MTP-232 当前 issue execution evidence 和本地验证输出。

MTP-232 必须建立的主要 anchors：

- `MTP-232-TARGETGRAPH-STAGE-CLOSEOUT`
- `MTP-232-ISSUE-PR-EVIDENCE-CHAIN`
- `MTP-232-VALIDATION-MATRIX-CLOSEOUT`
- `MTP-232-COMPATIBILITY-ENVELOPE-CLOSEOUT`
- `MTP-232-AUTOMATION-READINESS-CLOSEOUT`
- `MTP-232-FORBIDDEN-IMPLEMENTATION-AUDIT`
- `MTP-232-STAGE-CODE-AUDIT-HANDOFF`
- `MTP-232-STAGE-CLOSEOUT-VALIDATION`

## MTP-232 禁止

- 不输出最终 Stage Code Audit Report。
- 不设置 Linear Project `Completed`。
- 不创建下一 Project / Issue。
- 不推进下一阶段或下一 Todo。
- 不删除 retained compatibility implementation，不引入新的 module layout。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-227 Data Targets Real Module Root Migration Validation

MTP-227 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests/testMTP227DataTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-227 的验收要求：

- `Package.swift` 中 `DataClient` target path 必须为 `Sources/DataClient`，并且 explicit source 必须为 `TargetGraph/DataClientTargetBoundary.swift`。
- `Package.swift` 中 `Cache` target path 必须为 `Sources/Cache`，并且 explicit source 必须为 `TargetGraph/CacheTargetBoundary.swift`。
- `Package.swift` 中 `DataEngine` target path 必须为 `Sources/DataEngine`，并且 explicit source 必须为 `TargetGraph/DataEngineTargetBoundary.swift`。
- `Package.swift` 不得再包含 `path: "Sources/TargetGraph/DataClient"`、`path: "Sources/TargetGraph/Cache"` 或 `path: "Sources/TargetGraph/DataEngine"`。
- `Sources/DataClient/TargetGraph/DataClientTargetBoundary.swift`、`Sources/Cache/TargetGraph/CacheTargetBoundary.swift` 和 `Sources/DataEngine/TargetGraph/DataEngineTargetBoundary.swift` 必须存在。
- `Sources/TargetGraph/DataClient/DataClientTargetBoundary.swift`、`Sources/TargetGraph/Cache/CacheTargetBoundary.swift` 和 `Sources/TargetGraph/DataEngine/DataEngineTargetBoundary.swift` 必须不存在。
- `TargetGraphTests` 必须包含 `testMTP227DataTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`，验证 package target path、new boundary file location 和 retired data TargetGraph path。
- `swift package describe` 不得输出 migrated data roots 的 unhandled-file warnings。
- Dependency direction 必须保持 `DataClient -> DomainModel`、`Cache -> DomainModel / MessageBus`、`DataEngine -> DomainModel / DataClient / MessageBus / Cache`。
- Compatibility envelope 必须保留：`Adapters` 继续编译 Binance public market data implementation，`Core` 继续编译 Cache MarketData / DataEngine replay and quality implementation，`Runtime` 继续编译 DataEngine ingest implementation。
- MTP-227 PR evidence 必须确认不迁移 trader / portfolio / risk / execution / UI targets，不实现 signed endpoint、account endpoint、listenKey、private stream runtime、broker gateway、runtime、live 或 L4 capability。

MTP-227 必须建立的主要 anchors：

- `MTP-227-DATA-REAL-ROOT-TARGET-MIGRATION`
- `MTP-227-DATA-DEPENDENCY-DIRECTION-PRESERVED`
- `MTP-227-TARGETGRAPH-DATA-ACTIVE-PATH-RETIREMENT`
- `MTP-227-DATA-REAL-ROOT-VALIDATION`
- `MTP-227-DATACLIENT-REAL-ROOT-TARGET-PATH`
- `MTP-227-CACHE-REAL-ROOT-TARGET-PATH`
- `MTP-227-DATAENGINE-REAL-ROOT-TARGET-PATH`

## MTP-227 禁止

- 不迁移 TraderStrategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard target paths。
- 不接 signed endpoint、account endpoint 或 listenKey。
- 不实现 private stream runtime。
- 不连接 broker 或 execution adapter。
- 不删除 `Sources/TargetGraph` 或退休非 data TargetGraph active paths。
- 不新增、删除、重命名 SwiftPM target / product / dependency。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-223 Target Graph Stage Closeout Validation

MTP-223 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-223 的验收要求：

- `docs/audit/inputs/mtpro-swiftpm-target-graph-module-split-v1-stage-audit-input.md` 必须存在，并包含 `MTP-223-SWIFTPM-TARGET-GRAPH-STAGE-CLOSEOUT`、`MTP-223-STAGE-AUDIT-INPUT-MATERIAL`、`MTP-223-NO-FINAL-STAGE-CODE-AUDIT`、`MTP-223-TARGET-GRAPH-CLOSEOUT`、`MTP-223-VALIDATION-MATRIX-CLOSEOUT`、`MTP-223-AUTOMATION-READINESS-CLOSEOUT`、`MTP-223-FORBIDDEN-IMPLEMENTATION-AUDIT`、`MTP-223-ROOT-DOCS-DELTA-INPUT` 和 `MTP-223-STAGE-CODE-AUDIT-HANDOFF`。
- Stage audit input material 必须汇总 MTP-216 至 MTP-222 的 PR / checks / merge / Linear Done evidence chain。
- Validation matrix 必须包含 `MTP-223 issue backfill`，并把 `TVM-SWIFTPM-TARGET-GRAPH-MODULE-SPLIT` 收口到 MTP-223。
- Automation readiness 必须包含 MTP-223 stage closeout anchor，并机械检查 no final Stage Code Audit、no Project Completed mutation、no next Project / Issue creation、no next Todo promotion、no Symphony、no Graphify、no code-index、no Figma 和 no `.codex/*` / `graphify-out/*` PR submission。
- Latest verification summary 必须记录 MTP-223 当前 issue execution evidence 和本地验证输出。

MTP-223 必须建立的主要 anchors：

- `MTP-223-SWIFTPM-TARGET-GRAPH-STAGE-CLOSEOUT`
- `MTP-223-STAGE-AUDIT-INPUT-MATERIAL`
- `MTP-223-NO-FINAL-STAGE-CODE-AUDIT`
- `MTP-223-TARGET-GRAPH-CLOSEOUT`
- `MTP-223-VALIDATION-MATRIX-CLOSEOUT`
- `MTP-223-AUTOMATION-READINESS-CLOSEOUT`
- `MTP-223-FORBIDDEN-IMPLEMENTATION-AUDIT`
- `MTP-223-STAGE-CLOSEOUT-VALIDATION`

## MTP-223 禁止

- 不输出最终 Stage Code Audit Report，不设置 Linear Project `Completed`，不创建下一 Project / Issue，不推进下一阶段 Todo。
- 不把 stage audit input material 当成 Root Docs Refresh Gate 或 closure progress summary。
- 不移动 production source，不新增、不删除、不重命名 SwiftPM target / product / dependency。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-224 TargetGraph Retirement / Real Module Source Root Migration Contract Validation

MTP-224 必须运行：

- `git diff --check`
- `bash checks/run.sh`

MTP-224 的验收要求：

- `docs/contracts/targetgraph-anchor-retirement-real-module-source-root-migration-contract.md` 必须包含 `MTP-224-TARGETGRAPH-RETIREMENT-CONTRACT`、`MTP-224-REAL-MODULE-SOURCE-ROOT-TARGET`、`MTP-224-MIGRATION-SEQUENCE-COMPATIBILITY-RULE`、`MTP-224-DEPENDENCY-DIRECTION-AND-FORBIDDEN-PATH-TAXONOMY`、`MTP-224-NO-PACKAGE-SOURCE-MOVE-RUNTIME-GUARD` 和 `MTP-224-VALIDATION-ANCHORS`。
- Root docs / validation docs 必须明确 `Sources/TargetGraph` 是 transitional compile anchor / historical evidence，不是最终架构模块、长期 source ownership、新 engine layer 或 future feature landing path。
- 真实模块 source root 必须指向 `Sources/DomainModel/`、`Sources/MessageBus/`、`Sources/Database/`、`Sources/DataClient/`、`Sources/DataEngine/`、`Sources/Cache/`、`Sources/Portfolio/`、`Sources/RiskEngine/`、`Sources/ExecutionClient/`、`Sources/ExecutionEngine/`、`Sources/Trader/Strategies/EMA/`、`Sources/Trader/Accounts/`、`Sources/Trader/Coordination/` 和 `Sources/Dashboard/`；`Sources/Workbench/` 当前已退休，只能作为 historical / forbidden active path evidence。
- Migration sequence 必须明确 MTP-225 audit、MTP-226 foundation、MTP-227 data、MTP-228 trader / portfolio / risk、MTP-229 execution future gate、MTP-230 Dashboard real root、MTP-231 TargetGraph active path retirement 和 MTP-232 validation / stage audit input closeout。
- MTP-224 PR evidence 必须确认 `Package.swift` 无 diff、未移动 `Sources` 文件、未新增 SwiftPM target/product/dependency、未退休 active `Sources/TargetGraph/*` path references。
- MTP-224 PR evidence 必须确认 no Symphony、no Graphify、no code-index、no Figma、no `.codex/*`、no `graphify-out/*`、no runtime、no live、no broker、no L4 capability。

MTP-224 必须建立的主要 anchors：

- `MTP-224-TARGETGRAPH-RETIREMENT-CONTRACT`
- `MTP-224-REAL-MODULE-SOURCE-ROOT-TARGET`
- `MTP-224-MIGRATION-SEQUENCE-COMPATIBILITY-RULE`
- `MTP-224-DEPENDENCY-DIRECTION-AND-FORBIDDEN-PATH-TAXONOMY`
- `MTP-224-NO-PACKAGE-SOURCE-MOVE-RUNTIME-GUARD`
- `MTP-224-VALIDATION-ANCHORS`

## MTP-224 禁止

- 不修改 `Package.swift` target graph、products、dependencies、source roots 或 exclude list。
- 不移动 production source 或 tests。
- 不新增、删除、重命名 SwiftPM target / product / dependency。
- 不删除 `Sources/TargetGraph`，不退休 active `Sources/TargetGraph/*` path references。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-225 TargetGraph Anchor / Real Root / Package / Tests Audit Validation

MTP-225 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-225 的验收要求：

- `docs/audit/inputs/mtpro-targetgraph-anchor-retirement-real-module-source-root-migration-v1-mtp-225-audit.md` 必须包含 `MTP-225-TARGETGRAPH-ANCHOR-AUDIT`、`MTP-225-TARGETGRAPH-ACTIVE-ANCHOR-INVENTORY`、`MTP-225-REAL-MODULE-ROOT-AUDIT`、`MTP-225-PACKAGE-TARGET-PATH-AUDIT`、`MTP-225-TARGETGRAPH-TEST-COVERAGE-AUDIT`、`MTP-225-MIGRATION-RISK-REGISTER`、`MTP-225-NO-MIGRATION-GUARD` 和 `MTP-225-AUDIT-VALIDATION`。
- Audit 必须列出当前 active `Sources/TargetGraph/*` boundary anchors，并明确它们只是 transitional compile anchor / historical evidence。
- Audit 必须列出真实 module source roots：`Sources/DomainModel/`、`Sources/MessageBus/`、`Sources/Database/`、`Sources/DataClient/`、`Sources/DataEngine/`、`Sources/Cache/`、`Sources/Portfolio/`、`Sources/RiskEngine/`、`Sources/ExecutionClient/`、`Sources/ExecutionEngine/`、`Sources/Trader/Accounts/`、`Sources/Trader/Strategies/EMA/`、`Sources/Trader/Coordination/` 和 `Sources/Dashboard/`；`Sources/Workbench/` 当前已退休，只能作为 historical / forbidden active path evidence。
- Audit 必须记录 `Package.swift` 当前 active target paths / dependencies，且 MTP-225 PR evidence 必须确认 `Package.swift` 无 diff。
- Audit 必须记录 `Tests/TargetGraphTests/TargetGraphTests.swift` 当前 coverage，并说明 tests 当前证明 target boundary contracts，不证明 real source root ownership。
- MTP-225 PR evidence 必须确认未移动、删除或重命名 production source / tests，未退休 active `Sources/TargetGraph/*` path references，未新增 SwiftPM target/product/dependency。
- MTP-225 PR evidence 必须确认 no Symphony、no Graphify、no code-index、no Figma、no `.codex/*`、no `graphify-out/*`、no runtime、no live、no broker、no L4 capability。

MTP-225 必须建立的主要 anchors：

- `MTP-225-TARGETGRAPH-ANCHOR-AUDIT`
- `MTP-225-TARGETGRAPH-ACTIVE-ANCHOR-INVENTORY`
- `MTP-225-REAL-MODULE-ROOT-AUDIT`
- `MTP-225-PACKAGE-TARGET-PATH-AUDIT`
- `MTP-225-TARGETGRAPH-TEST-COVERAGE-AUDIT`
- `MTP-225-MIGRATION-RISK-REGISTER`
- `MTP-225-NO-MIGRATION-GUARD`
- `MTP-225-AUDIT-VALIDATION`

## MTP-225 禁止

- 不修改 `Package.swift` target graph、products、dependencies、source roots 或 exclude list。
- 不移动 production source 或 tests。
- 不新增、删除、重命名 SwiftPM target / product / dependency。
- 不删除 `Sources/TargetGraph`，不退休 active `Sources/TargetGraph/*` path references。
- 不修复 production code。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## MTP-226 Foundation Targets Real Module Root Migration Validation

MTP-226 必须运行：

- `swift package describe`
- `swift test --filter TargetGraphTests/testMTP226FoundationTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

MTP-226 的验收要求：

- `Package.swift` 中 `DomainModel` target path 必须为 `Sources/DomainModel`，并且 explicit source 必须为 `TargetGraph/DomainModelTargetBoundary.swift`。
- `Package.swift` 中 `MessageBus` target path 必须为 `Sources/MessageBus`，并且 explicit source 必须为 `TargetGraph/MessageBusTargetBoundary.swift`。
- `Package.swift` 中 `Database` target path 必须为 `Sources/Database`，并且 explicit source 必须为 `TargetGraph/DatabaseTargetBoundary.swift`。
- `Package.swift` 不得再包含 `path: "Sources/TargetGraph/DomainModel"`、`path: "Sources/TargetGraph/MessageBus"` 或 `path: "Sources/TargetGraph/Database"`。
- `Sources/DomainModel/TargetGraph/DomainModelTargetBoundary.swift`、`Sources/MessageBus/TargetGraph/MessageBusTargetBoundary.swift` 和 `Sources/Database/TargetGraph/DatabaseTargetBoundary.swift` 必须存在。
- `Sources/TargetGraph/DomainModel/DomainModelTargetBoundary.swift`、`Sources/TargetGraph/MessageBus/MessageBusTargetBoundary.swift` 和 `Sources/TargetGraph/Database/DatabaseTargetBoundary.swift` 必须不存在。
- `TargetGraphTests` 必须包含 `testMTP226FoundationTargetsUseRealModuleRootsAndRetireTargetGraphPathReferences`，验证 package target path、new boundary file location 和 retired foundation TargetGraph path。
- `swift package describe` 不得输出 migrated foundation roots 的 unhandled-file warnings。
- Dependency direction 必须保持 `DomainModel`、`MessageBus -> DomainModel`、`Database -> DomainModel / MessageBus / CSQLite / DuckDB(macOS)`。
- Compatibility envelope 必须保留：`Core` 继续编译 DomainModel / MessageBus implementation source，`Persistence` 继续编译 Database projections，`Runtime` 继续编译 Database replay projection。
- MTP-226 PR evidence 必须确认不迁移 data / trader / execution / UI targets，不改变 persistence behavior，不实现 runtime、live、broker 或 L4 capability。

MTP-226 必须建立的主要 anchors：

- `MTP-226-FOUNDATION-REAL-ROOT-TARGET-MIGRATION`
- `MTP-226-FOUNDATION-DEPENDENCY-DIRECTION-PRESERVED`
- `MTP-226-TARGETGRAPH-FOUNDATION-ACTIVE-PATH-RETIREMENT`
- `MTP-226-FOUNDATION-REAL-ROOT-VALIDATION`
- `MTP-226-DOMAINMODEL-REAL-ROOT-TARGET-PATH`
- `MTP-226-MESSAGEBUS-REAL-ROOT-TARGET-PATH`
- `MTP-226-DATABASE-REAL-ROOT-TARGET-PATH`

## MTP-226 禁止

- 不迁移 DataClient、DataEngine、Cache、TraderStrategies、Trader、Portfolio、RiskEngine、ExecutionEngine、ExecutionClient、Workbench 或 Dashboard target paths。
- 不改变 persistence behavior。
- 不删除 `Sources/TargetGraph` 或退休非 foundation TargetGraph active paths。
- 不新增、删除、重命名 SwiftPM target / product / dependency。
- 不实现 Strategy runtime、Trader runtime、Live runtime、ExecutionClient implementation、OMS implementation、broker gateway、signed endpoint、account endpoint / listenKey、private WebSocket runtime、account snapshot runtime、real account read、real order lifecycle、submit / cancel / replace、execution report、broker fill、reconciliation、Live PRO Console、trading button、live command、order form 或 L4 capability。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-521 Release v0.1.0 Binance EMA Runtime Contract Validation

GH-521 必须运行：

- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-521 的验收要求：

- `docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md` 必须存在，并包含 `GH-521-RELEASE-V010-BINANCE-EMA-RUNTIME-CONTRACT`、`GH-521-BINANCE-EMA-ACTIVE-SCOPE`、`GH-521-TESTNET-DRY-RUN-FIRST-GATE`、`GH-521-ACCEPTANCE-MATRIX`、`GH-521-NO-DEFAULT-PRODUCTION-TRADING`、`GH-521-VALIDATION-ANCHORS`、`GH-521-NON-AUTHORIZATION` 和 `TVM-RELEASE-V010-BINANCE-EMA-RUNTIME`。
- Acceptance matrix 必须覆盖 DataClient / DataEngine / Cache、signed account read、private stream / account snapshot、Trader lifecycle、EMA proposal、RiskEngine pre-trade gate、ExecutionEngine / OMS、Binance ExecutionClient testnet submit / cancel / replace、execution report / broker fill parser、reconciliation / portfolio update、Dashboard live monitoring、controlled command surface、kill switch / no-trade / rollback、dry-run / testnet validation、no-default-production-trading automation guard、release docs、operator runbook、validation matrix、stage audit input、final Stage Code Audit 和 Root Docs Refresh。
- Contract 必须明确 Binance 是 release v0.1.0 唯一 active venue，EMA 是 release v0.1.0 唯一 active concrete strategy。
- Contract 必须明确 production trading 默认关闭，production secret、production endpoint、production order submit / cancel / replace、production OMS 和 production Dashboard command surface 均不得默认启用。
- GH-521 PR evidence 必须确认不实现 runtime，不读取 production secret，不连接 production endpoint，不提交真实订单，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-521 必须建立的主要 anchors：

- `GH-521-RELEASE-V010-BINANCE-EMA-RUNTIME-CONTRACT`
- `GH-521-BINANCE-EMA-ACTIVE-SCOPE`
- `GH-521-TESTNET-DRY-RUN-FIRST-GATE`
- `GH-521-ACCEPTANCE-MATRIX`
- `GH-521-NO-DEFAULT-PRODUCTION-TRADING`
- `TVM-RELEASE-V010-BINANCE-EMA-RUNTIME`

## GH-521 禁止

- 不实现 release runtime。
- 不读取、打印、保存或推导 production secret。
- 不连接 production endpoint、production broker endpoint、signed endpoint、account endpoint 或 listenKey。
- 不提交、取消或替换真实订单。
- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-531 Binance ExecutionClient Testnet SCR Validation

GH-531 必须运行：

- `swift test --filter TargetGraphTests/testGH531BinanceExecutionClientTestnetSubmitCancelReplaceRequiresCredentialGuardAndOMS`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-531 的验收要求：

- `Sources/ExecutionClient/FutureGate/ReleaseV010BinanceExecutionClientTestnetCommands.swift` 必须存在，并包含 `GH-531-BINANCE-TESTNET-SUBMIT-CANCEL-REPLACE` 和 `TVM-RELEASE-V010-BINANCE-EXECUTIONCLIENT-TESTNET-SCR` anchors。
- `Package.swift` 必须让 `ExecutionClient` target 显式拥有 `FutureGate` source root，并保持 `dependencies: ["DomainModel", "MessageBus"]`，不得新增 DataClient、ExecutionEngine、RiskEngine、Crypto、Dashboard 或 broker dependency。
- Adapter 必须覆盖 Binance Spot testnet submit / cancel / replace request mapping：submit `POST /api/v3/order`、cancel `DELETE /api/v3/order`、replace `POST /api/v3/order/cancelReplace`。
- Request mapping 必须引用 #530 OMS order / event log / source risk decision identity，不能由 Trader、Strategy、Dashboard 或 MessageBus direct command 直接创建。
- Credential guard 必须只保存 testnet credential reference，不保存、不打印、不暴露 credential value 或 signature value，不读取 production secret，不允许 testnet credential 升级为 production credential。
- Capability matrix 必须保持 `productionEndpointEnabledByDefault == false`、`productionTradingEnabledByDefault == false`、`productionSecretReadEnabledByDefault == false`、`productionSubmitEnabledByDefault == false`、`productionCancelEnabledByDefault == false`、`productionReplaceEnabledByDefault == false`、`brokerGatewayTouched == false`、`liveCommandSurfaceTouched == false`、`bypassesRiskEngine == false`、`bypassesOMS == false`、`bypassesKillSwitch == false`、`nonBinanceVenueEnabled == false` 和 `nonEMAStrategyEnabled == false`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH531BinanceExecutionClientTestnetSubmitCancelReplaceRequiresCredentialGuardAndOMS`，验证 ExecutionClient source ownership、testnet endpoint mapping、credential guard、#530 OMS source identity、production endpoint rejection、signature value rejection 和 mismatched command rejection。
- GH-531 PR evidence 必须确认不读取 production secret，不连接 production endpoint，不连接 production broker，不暴露 signature value，不解析 execution report / broker fill，不执行 reconciliation，不启用 production trading，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-531 必须建立的主要 anchors：

- `GH-531-BINANCE-TESTNET-SUBMIT-CANCEL-REPLACE`
- `GH-531-BINANCE-TESTNET-REQUEST-MAPPING`
- `GH-531-TESTNET-CREDENTIAL-GUARD`
- `GH-531-BINANCE-TESTNET-CAPABILITY-MATRIX`
- `GH-531-TESTNET-SUBMIT-CANCEL-REPLACE-EVIDENCE`
- `GH-531-PRODUCTION-ENDPOINT-EXPLICIT-GATE`
- `TVM-RELEASE-V010-BINANCE-EXECUTIONCLIENT-TESTNET-SCR`
- `testGH531BinanceExecutionClientTestnetSubmitCancelReplaceRequiresCredentialGuardAndOMS`

## GH-531 禁止

- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不读取、打印、保存或推导 production secret。
- 不接受 production endpoint、production stream endpoint 或 production broker endpoint。
- 不连接 production broker 或 broker gateway。
- 不暴露 signature value、credential value 或 raw secret material。
- 不把 testnet mapping 扩大成 production submit / cancel / replace。
- 不解析 execution report 或 broker fill；该能力留给 GH-532。
- 不执行 reconciliation 或 Portfolio update；该能力留给 GH-533。
- 不暴露 Dashboard command surface、trading button、live command 或 order form。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-522 Release v0.1.0 Ownership Gap Retirement Validation

GH-522 必须运行：

- `swift test --filter TargetGraphTests/testGH522ReleaseV010OwnershipGapsAreRetiredOrExplicitlyDeferred`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-522 的验收要求：

- `docs/contracts/release-v0.1.0-ownership-gap-retirement-contract.md` 必须存在，并包含 `GH-522-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT`、`GH-522-RELEASE-OWNERSHIP-AUTHORITY`、`GH-522-COMPATIBILITY-ENVELOPE-MATRIX`、`GH-522-DEFERRED-OWNERSHIP-REGISTER`、`GH-522-NO-PRODUCTION-AUTHORIZATION`、`GH-522-VALIDATION-ANCHORS`、`GH-522-NON-AUTHORIZATION` 和 `TVM-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT`。
- Release ownership matrix 必须把 `Adapters` 收口为 compatibility re-export only，并把 `Runtime` 的 `DataEngine/Ingest` / `Database/ReplayProjection`、`Persistence` 的 SQLite / DuckDB projection adapter 和 `Core` 的 legacy compatibility surfaces 显式标为 deferred / compatibility bridge，而不是 release active runtime owner。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH522ReleaseV010OwnershipGapsAreRetiredOrExplicitlyDeferred`，验证 contract anchor、Package target source snapshot 和 deferred ownership register。
- GH-522 PR evidence 必须确认不实现 runtime，不移动 production source，不读取 production secret，不连接 production endpoint，不提交真实订单，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-522 必须建立的主要 anchors：

- `GH-522-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT`
- `GH-522-RELEASE-OWNERSHIP-AUTHORITY`
- `GH-522-COMPATIBILITY-ENVELOPE-MATRIX`
- `GH-522-DEFERRED-OWNERSHIP-REGISTER`
- `GH-522-NO-PRODUCTION-AUTHORIZATION`
- `TVM-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT`

## GH-522 禁止

- 不实现 release runtime。
- 不移动 production source 或改变 SwiftPM dependency graph。
- 不读取、打印、保存或推导 production secret。
- 不连接 production endpoint、production broker endpoint、signed endpoint、account endpoint 或 listenKey。
- 不提交、取消或替换真实订单。
- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不把 `Core`、`Adapters`、`Persistence` 或 `Runtime` 写成 release v0.1.0 active runtime owner。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-523 Release v0.1.0 Real Target Smoke Coverage Validation

GH-523 必须运行：

- `swift test --filter TargetGraphTests/testGH523ReleaseV010TargetsExposeRealSmokeCoverage`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-523 的验收要求：

- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH523ReleaseV010TargetsExposeRealSmokeCoverage`，并通过真实 public API 覆盖 `DomainModel`、`MessageBus`、`Database`、`DataClient`、`DataEngine`、`Cache`、`Trader`、`TraderStrategies`、`Portfolio`、`RiskEngine`、`ExecutionEngine`、`ExecutionClient` 和 `Dashboard`。
- `docs/contracts/release-v0.1.0-binance-ema-runtime-contract.md` 必须包含 `GH-523-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE`，并明确 smoke coverage 不授权 runtime implementation 或 production trading。
- `docs/validation/trading-validation-matrix.md` 必须包含 `TVM-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE` 和 `GH-523` backfill row。
- GH-523 PR evidence 必须确认不实现 release runtime，不读取 production secret，不连接 production endpoint，不创建 signed endpoint / listenKey，不提交、取消或替换真实订单，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-523 必须建立的主要 anchors：

- `GH-523-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE`
- `TVM-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE`
- `testGH523ReleaseV010TargetsExposeRealSmokeCoverage`

## GH-523 禁止

- 不实现 release runtime。
- 不新增 broker gateway、signed endpoint client、account endpoint client、listenKey lifecycle 或 private WebSocket runtime。
- 不读取、打印、保存或推导 production secret。
- 不连接 production endpoint 或 production broker endpoint。
- 不提交、取消或替换真实订单。
- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不把 smoke test 写成 runtime 已完成证据。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-524 Binance Public Market Data Runtime Path Validation

GH-524 必须运行：

- `swift test --filter TargetGraphTests/testGH524BinancePublicMarketDataRuntimePathProjectsIntoCacheReadModel`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-524 的验收要求：

- `Sources/DataEngine/BinancePublicMarketDataRuntimePath.swift` 必须存在，并包含 `GH-524-BINANCE-PUBLIC-MARKET-DATA-RUNTIME-PATH` 和 `TVM-RELEASE-V010-BINANCE-PUBLIC-MARKET-DATA-PATH` anchors。
- `Package.swift` 必须把 `BinancePublicMarketDataRuntimePath.swift` 纳入 `DataEngine` target，并从 `Core` / `Runtime` compatibility envelopes 显式 exclude。
- `Sources/Cache/MarketData/MarketDataCache.swift` 必须提供 public market events batch projection helper，让 Cache target 能从 `[MarketEvent]` 生成 deterministic `MarketDataCacheSnapshot`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH524BinancePublicMarketDataRuntimePathProjectsIntoCacheReadModel`，用 mock `BinancePublicMarketDataTransport` 验证 Binance public kline、recent trade、best bid / ask、depth snapshot 和 depth delta 经 DataClient -> DataEngine neutral journal -> Cache read model。
- GH-524 PR evidence 必须确认不读取 private account，不调用 signed endpoint，不创建 listenKey，不连接 private WebSocket / broker，不提交、取消或替换订单，不启用 production trading，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-524 必须建立的主要 anchors：

- `GH-524-BINANCE-PUBLIC-MARKET-DATA-RUNTIME-PATH`
- `TVM-RELEASE-V010-BINANCE-PUBLIC-MARKET-DATA-PATH`
- `testGH524BinancePublicMarketDataRuntimePathProjectsIntoCacheReadModel`

## GH-524 禁止

- 不读取私有账户、account endpoint、account snapshot 或 broker account state。
- 不新增 signed endpoint client、listenKey lifecycle 或 private WebSocket runtime。
- 不读取、打印、保存或推导 production secret。
- 不连接 production endpoint 或 production broker endpoint。
- 不提交、取消或替换真实订单。
- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-525 Binance Signed Account Read Runtime Validation

GH-525 必须运行：

- `swift test --filter TargetGraphTests/testGH525BinanceSignedAccountReadRuntimeMapsCanonicalSnapshotWithoutCommandSurface`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-525 的验收要求：

- `Sources/DataClient/Binance/SignedAccount/BinanceSignedAccountReadRuntime.swift` 必须存在，并包含 `GH-525-BINANCE-SIGNED-ACCOUNT-READ-RUNTIME` 和 `TVM-RELEASE-V010-BINANCE-SIGNED-ACCOUNT-READ` anchors。
- `Package.swift` 必须把 `swift-crypto` 的 `Crypto` product 纳入 `DataClient` target，并让 `DataClient` 显式拥有 `Binance/SignedAccount/BinanceSignedAccountReadRuntime.swift` source。
- Signed account read configuration 必须默认使用 Binance Spot testnet / local fixture-first path，并拒绝 production host `api.binance.com`。
- Runtime 只能构造 `/api/v3/account` signed GET request，允许 `X-MBX-APIKEY` header 和 HMAC-SHA256 signature query item，但不得创建 `/api/v3/order`、`/api/v3/userDataStream`、listenKey、private WebSocket、broker gateway 或 command runtime。
- Account payload 必须被映射为 canonical read model snapshot，只暴露 account type、balances、credential reference、source path 和 validation anchors，不暴露 raw signed payload、API key header value、secret material、broker state 或 command state。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH525BinanceSignedAccountReadRuntimeMapsCanonicalSnapshotWithoutCommandSurface`，用 mock transport 验证 request/signature/header/snapshot mapping、secret non-exposure、production endpoint rejection 和 no submit / cancel / replace boundary。
- GH-525 PR evidence 必须确认不读取 production secret，不连接 production endpoint，不创建 listenKey，不启动 private stream，不连接 broker，不提交、取消或替换订单，不启用 production trading，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-525 必须建立的主要 anchors：

- `GH-525-BINANCE-SIGNED-ACCOUNT-READ-RUNTIME`
- `TVM-RELEASE-V010-BINANCE-SIGNED-ACCOUNT-READ`
- `testGH525BinanceSignedAccountReadRuntimeMapsCanonicalSnapshotWithoutCommandSurface`

## GH-525 禁止

- 不读取、打印、保存或推导 production secret。
- 不接受 production endpoint 或 production broker endpoint。
- 不创建 listenKey lifecycle 或 private WebSocket runtime。
- 不把 signed account read 扩大成 private stream、account snapshot runtime、broker account state 或 command runtime。
- 不连接 broker gateway、OMS 或 ExecutionClient order path。
- 不提交、取消或替换真实订单。
- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-526 Binance Private Stream Account Snapshot Runtime Validation

GH-526 必须运行：

- `swift test --filter TargetGraphTests/testGH526BinancePrivateStreamAccountSnapshotRuntimeMapsEventsWithoutCommandSurface`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-526 的验收要求：

- `Sources/DataClient/Binance/PrivateStream/BinancePrivateStreamAccountSnapshotRuntime.swift` 必须存在，并包含 `GH-526-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-RUNTIME` 和 `TVM-RELEASE-V010-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT` anchors。
- `Package.swift` 必须让 `DataClient` 显式拥有 `Binance/PrivateStream/BinancePrivateStreamAccountSnapshotRuntime.swift` source。
- Runtime configuration 必须默认使用 Binance Spot testnet / local fixture-first path，并拒绝 production REST host `api.binance.com` 和 production stream host `stream.binance.com`。
- ListenKey lifecycle request 只能访问 `/api/v3/userDataStream`，只能携带 API key header，不得生成 `/api/v3/order`、broker path、order signature 或 production authorization。
- ListenKey value 必须只存在于 transport lease 内部；read model、subscription evidence、Dashboard、MessageBus、logs 和 verification evidence 只能暴露 redacted listenKey reference。
- Private stream event ingest 必须使用 mock/source-driven frames 覆盖 `outboundAccountPosition` 和 `balanceUpdate`，并映射为 account / balance / position read-model records。
- Runtime 必须输出 stale / blocked / missing / disconnected freshness evidence，且不得把这些状态解释为 reconnect command、order retry、broker fallback 或 command path。
- `executionReport`、order update、broker fill 或未知 private event frame 必须被拒绝。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH526BinancePrivateStreamAccountSnapshotRuntimeMapsEventsWithoutCommandSurface`，验证 request lifecycle、redacted listenKey reference、private event mapping、freshness evidence、forbidden event rejection 和 no submit / cancel / replace boundary。
- GH-526 PR evidence 必须确认不读取 production secret，不连接 production endpoint，不暴露 raw listenKey，不暴露 raw private payload，不连接 broker，不提交、取消或替换订单，不启用 production trading，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-526 必须建立的主要 anchors：

- `GH-526-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-RUNTIME`
- `TVM-RELEASE-V010-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT`
- `testGH526BinancePrivateStreamAccountSnapshotRuntimeMapsEventsWithoutCommandSurface`

## GH-526 禁止

- 不读取、打印、保存或推导 production secret。
- 不接受 production endpoint、production stream endpoint 或 production broker endpoint。
- 不把 listenKey value 写入 read model、Dashboard、MessageBus、日志或 verification evidence。
- 不暴露 raw private payload、raw broker payload、execution report payload 或 order update payload。
- 不连接 broker gateway、OMS 或 ExecutionClient order path。
- 不提交、取消或替换真实订单。
- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-527 Trader Runtime Lifecycle Validation

GH-527 必须运行：

- `swift test --filter TargetGraphTests/testGH527TraderRuntimeLifecycleManagesAccountsEMAAndCoordinationWithoutOrderSubmission`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-527 的验收要求：

- `Sources/Trader/Runtime/TraderRuntimeLifecycle.swift` 必须存在，并包含 `GH-527-TRADER-RUNTIME-LIFECYCLE` 和 `TVM-RELEASE-V010-TRADER-RUNTIME-LIFECYCLE` anchors。
- `Package.swift` 必须让 `Trader` target 显式拥有 `Runtime/TraderRuntimeLifecycle.swift` source，且 `Trader` target 不得依赖 `ExecutionClient`。
- Lifecycle 必须覆盖 startup / shutdown、account context binding、EMA strategy instance registration 和 Coordination/RiskBinding handoff。
- Lifecycle report 必须保持 `directExecutionClientEnabled == false`、`brokerCommandEnabled == false`、`omsBypassEnabled == false`、`productionTradingEnabledByDefault == false`、`nonBinanceVenueEnabled == false` 和 `nonEMAStrategyEnabled == false`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH527TraderRuntimeLifecycleManagesAccountsEMAAndCoordinationWithoutOrderSubmission`，验证 lifecycle event sequence、account / EMA 管理、RiskBinding handoff、no-command flags 和 production default rejection。
- GH-527 PR evidence 必须确认不读取 production secret，不连接 production endpoint，不直连 ExecutionClient / broker / OMS，不提交、取消或替换订单，不启用 production trading，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-527 必须建立的主要 anchors：

- `GH-527-TRADER-RUNTIME-LIFECYCLE`
- `GH-527-TRADER-ACCOUNTS-EMA-COORDINATION-LIFECYCLE`
- `GH-527-NO-DIRECT-ORDER-SUBMISSION`
- `TVM-RELEASE-V010-TRADER-RUNTIME-LIFECYCLE`
- `testGH527TraderRuntimeLifecycleManagesAccountsEMAAndCoordinationWithoutOrderSubmission`

## GH-527 禁止

- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不读取、打印、保存或推导 production secret。
- 不接受 production endpoint、production stream endpoint 或 production broker endpoint。
- 不直连 ExecutionClient、broker gateway 或 OMS。
- 不提交、取消或替换真实订单。
- 不把 private stream read-model evidence 扩大成 command runtime。
- 不暴露 Dashboard command surface、trading button、live command 或 order form。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-528 EMA Proposal Runtime Validation

GH-528 必须运行：

- `swift test --filter TargetGraphTests/testGH528EMAProposalRuntimeGeneratesRiskConsumableProposalWithoutExecutionPath`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-528 的验收要求：

- `Sources/Trader/Strategies/EMA/EMAProposalRuntime.swift` 必须存在，并包含 `GH-528-EMA-STRATEGY-PROPOSAL-RUNTIME` 和 `TVM-RELEASE-V010-EMA-PROPOSAL-RUNTIME` anchors。
- `Package.swift` 必须让 `TraderStrategies` target 显式拥有 `EMAProposalRuntime.swift` source，且 `TraderStrategies` target 不得依赖 `ExecutionClient`。
- Runtime 必须覆盖 live-read compatible market bars / EMA signal sample 输入、paper-only `PaperActionProposal` 生成和 RiskEngine 可消费 `RiskEvaluationQuery` evidence。
- Proposal 必须保持 `executionMode == .paper`、`executionAuthorization == .paperIntentOnly`、`isExecutableAsRealOrder == false`。
- Runtime evidence 必须保持 `directExecutionClientEnabled == false`、`brokerCommandEnabled == false`、`omsBypassEnabled == false`、`productionTradingEnabledByDefault == false`、`nonBinanceVenueEnabled == false` 和 `nonEMAStrategyEnabled == false`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH528EMAProposalRuntimeGeneratesRiskConsumableProposalWithoutExecutionPath`，验证 Package ownership、EMA-only / Binance-only identity、RiskEngine consumable query、paper-only proposal boundary、production default rejection 和 mismatched reference price rejection。
- GH-528 PR evidence 必须确认不读取 production secret，不连接 production endpoint，不直连 ExecutionClient / broker / OMS，不提交、取消或替换订单，不启用 production trading，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-528 必须建立的主要 anchors：

- `GH-528-EMA-STRATEGY-PROPOSAL-RUNTIME`
- `GH-528-EMA-SIGNAL-TO-PAPER-PROPOSAL`
- `GH-528-RISKENGINE-CONSUMABLE-PROPOSAL`
- `TVM-RELEASE-V010-EMA-PROPOSAL-RUNTIME`
- `testGH528EMAProposalRuntimeGeneratesRiskConsumableProposalWithoutExecutionPath`

## GH-528 禁止

- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不读取、打印、保存或推导 production secret。
- 不接受 production endpoint、production stream endpoint 或 production broker endpoint。
- 不直连 ExecutionClient、broker gateway 或 OMS。
- 不提交、取消或替换真实订单。
- 不把 RiskEngine consumable proposal 扩大成 RiskEngine bypass 或 ExecutionEngine command。
- 不暴露 Dashboard command surface、trading button、live command 或 order form。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-529 RiskEngine Pre-Trade Gate Validation

GH-529 必须运行：

- `swift test --filter TargetGraphTests/testGH529RiskEnginePreTradeGateConsumesEMAProposalBeforeExecutionPath`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-529 的验收要求：

- `Sources/RiskEngine/LiveGate/ReleaseV010RiskPreTradeGate.swift` 必须存在，并包含 `GH-529-RISKENGINE-LIVE-PRETRADE-GATE` 和 `TVM-RELEASE-V010-RISKENGINE-PRETRADE-GATE` anchors。
- `Package.swift` 必须让 `RiskEngine` target 显式拥有 `LiveGate` source root，且 `RiskEngine` target 不得依赖 `ExecutionClient`。
- Gate 必须消费 #528 生成的 neutral `PaperActionProposal` / `RiskEvaluationQuery`，并验证 proposal 与 risk query 完全匹配。
- Gate 必须输出 approved / rejected / blocked 三类 deterministic evidence；rejected 必须带 quantity / notional / available balance 等可审计原因，blocked 必须覆盖 no-trade guard。
- Approved decision 只表示 RiskEngine 本地 pre-trade gate 通过，不授权 ExecutionEngine command、OMS lifecycle、broker submit / cancel / replace 或 production trading。
- Runtime evidence 必须保持 `authorizesExecutionCommand == false`、`productionTradingEnabledByDefault == false`、`callsExecutionClient == false`、`touchesBrokerGateway == false`、`bypassesOMS == false`、`submitsRealOrder == false`、`exposesLiveCommandSurface == false`、`nonBinanceVenueEnabled == false` 和 `nonEMAStrategyEnabled == false`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH529RiskEnginePreTradeGateConsumesEMAProposalBeforeExecutionPath`，验证 RiskEngine source ownership、no ExecutionClient dependency、EMA proposal -> risk input handoff、approved / rejected / blocked evidence、production default rejection 和 mismatched risk query rejection。
- GH-529 PR evidence 必须确认不读取 production secret，不连接 production endpoint，不调用 ExecutionClient / broker / OMS，不提交、取消或替换订单，不启用 production trading，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-529 必须建立的主要 anchors：

- `GH-529-RISKENGINE-LIVE-PRETRADE-GATE`
- `GH-529-EMA-PROPOSAL-RISK-DECISION`
- `GH-529-NO-TRADE-GUARD`
- `TVM-RELEASE-V010-RISKENGINE-PRETRADE-GATE`
- `testGH529RiskEnginePreTradeGateConsumesEMAProposalBeforeExecutionPath`

## GH-529 禁止

- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不读取、打印、保存或推导 production secret。
- 不接受 production endpoint、production stream endpoint 或 production broker endpoint。
- 不调用 ExecutionClient、broker gateway 或 OMS。
- 不提交、取消或替换真实订单。
- 不把 approved risk decision 扩大成 ExecutionEngine command、OMS bypass、broker submit 或 Dashboard command runtime。
- 不暴露 Dashboard command surface、trading button、live command 或 order form。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-532 Binance Execution Report Broker Fill Parser Validation

GH-532 必须运行：

- `swift test --filter TargetGraphTests/testGH532BinanceExecutionReportParserMapsBrokerFillAndInvalidEvidence`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-532 的验收要求：

- `Sources/ExecutionClient/FutureGate/ReleaseV010BinanceExecutionReportBrokerFillParser.swift` 必须存在，并包含 `GH-532-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER` 和 `TVM-RELEASE-V010-EXECUTION-REPORT-BROKER-FILL-PARSER` anchors。
- `Package.swift` 必须让 `ExecutionClient` target 继续显式拥有 `FutureGate` source root，并保持依赖方向不反转；parser 不能让 `ExecutionClient` 依赖 `ExecutionEngine`、`Portfolio`、`Dashboard` 或 broker runtime。
- Parser 必须绑定 #531 `ReleaseV010BinanceExecutionClientTestnetCommandEvidence`，并覆盖 full fill、partial fill、canceled 和 rejected report kinds。
- Parsed event 必须可进入 ExecutionEngine 本地 event model evidence，且保持 `eventStream == .paper`、`executionEngineEventModelReady == true`。
- Broker fill mapping 只允许 full fill / partial fill 为 true；cancel / reject 必须保持 `brokerFillMapped == false`。
- 异常回报必须形成 blocked / invalid evidence，且不能产生 ExecutionEngine event、broker fill fact、Portfolio update 或 reconciliation input。
- PR evidence 必须确认不解析 production raw payload，不保存 raw payload，不读取 production secret，不连接 production endpoint / broker gateway，不执行 reconciliation，不更新 Portfolio，不暴露 Dashboard command surface，不启用 production trading，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-532 必须建立的主要 anchors：

- `GH-532-BINANCE-EXECUTION-REPORT-BROKER-FILL-PARSER`
- `GH-532-EXECUTIONENGINE-EVENT-MODEL-HANDOFF`
- `GH-532-BROKER-FILL-MAPPING`
- `GH-532-PARTIAL-CANCEL-REJECT-EVIDENCE`
- `GH-532-INVALID-REPORT-BLOCKED-EVIDENCE`
- `GH-532-PRODUCTION-PARSER-DISABLED`
- `TVM-RELEASE-V010-EXECUTION-REPORT-BROKER-FILL-PARSER`
- `testGH532BinanceExecutionReportParserMapsBrokerFillAndInvalidEvidence`

## GH-532 禁止

- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不读取、打印、保存或推导 production secret。
- 不接受 production raw execution report、production endpoint、production stream endpoint 或 production broker endpoint。
- 不连接 production broker 或 broker gateway。
- 不把 #531 testnet command evidence 扩大成 production submit / cancel / replace。
- 不执行 reconciliation 或 Portfolio update；该能力留给 GH-533。
- 不暴露 Dashboard command surface、trading button、live command 或 order form。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-533 Portfolio Reconciliation Update Path Validation

GH-533 必须运行：

- `swift test --filter TargetGraphTests/testGH533PortfolioReconciliationUpdatesFromExecutionAndAccountEvidence`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-533 的验收要求：

- `Sources/ExecutionEngine/OMSFutureGate/ReleaseV010PortfolioReconciliationUpdatePath.swift` 必须存在，并包含 `GH-533-EXECUTION-ACCOUNT-PORTFOLIO-RECONCILIATION` 和 `TVM-RELEASE-V010-PORTFOLIO-RECONCILIATION-UPDATE-PATH` anchors。
- `ExecutionEngine` target 必须继续通过 `OMSFutureGate` 拥有该 path，并只使用既有 `Portfolio` / `ExecutionClient` dependency；不得新增 `DataClient`、`Dashboard`、broker runtime 或 production endpoint dependency。
- Evidence 必须消费 #532 normalized execution event evidence 和 GH-526 account / balance / position read-model evidence identity，输出 Portfolio update projection。
- Portfolio update evidence 必须覆盖 positions、net positions、margin requirement 和 open value。
- Matched / mismatched / stale / blocked 状态必须可审计，不得隐藏 mismatch，不得生成 repair command。
- PR evidence 必须确认不读取 production account endpoint，不连接 production broker，不读取 raw private payload、listenKey value 或 production secret，不启用 production trading，不暴露 Dashboard command surface，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-533 必须建立的主要 anchors：

- `GH-533-EXECUTION-ACCOUNT-PORTFOLIO-RECONCILIATION`
- `GH-533-ACCOUNT-POSITION-BALANCE-SNAPSHOT-EVIDENCE`
- `GH-533-PORTFOLIO-UPDATE-PATH`
- `GH-533-MISMATCH-STALE-BLOCKED-AUDIT-EVIDENCE`
- `GH-533-PRODUCTION-TRADING-STAYS-DISABLED`
- `TVM-RELEASE-V010-PORTFOLIO-RECONCILIATION-UPDATE-PATH`
- `testGH533PortfolioReconciliationUpdatesFromExecutionAndAccountEvidence`

## GH-533 禁止

- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不读取、打印、保存或推导 production secret。
- 不接受 production account endpoint、production private payload、production stream endpoint 或 production broker endpoint。
- 不连接 production broker 或 broker gateway。
- 不把 #532 parser evidence 扩大成 production report parser。
- 不生成 repair command，不隐藏 reconciliation mismatch。
- 不暴露 Dashboard command surface、trading button、live command 或 order form。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-534 Dashboard Live Monitoring Surface Validation

GH-534 必须运行：

- `swift test --filter AppTests/testGH534ReleaseV010DashboardLiveMonitoringSurfaceIsReadModelOnly`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-534 的验收要求：

- `Sources/Dashboard/Report/ReleaseV010LiveMonitoringSurface.swift` 必须存在，并包含 `GH-534-DASHBOARD-LIVE-MONITORING-SURFACE` 和 `TVM-RELEASE-V010-DASHBOARD-LIVE-MONITORING-SURFACE` anchors。
- Dashboard target 必须继续只依赖 `Core` / `Persistence`；不得新增 DataClient、Trader、RiskEngine、ExecutionEngine、ExecutionClient、broker、OMS 或 runtime target dependency。
- Surface 必须覆盖 connection health、account/private stream status、Trader/EMA、RiskEngine、ExecutionEngine / OMS、execution report / broker fill 和 Portfolio reconciliation summary。
- Dashboard report / shell smoke 必须能读取 release live monitoring evidence，并保留 read-model-only boundary。
- PR evidence 必须确认不读取 production secret，不连接 production endpoint，不直接消费 runtime object，不暴露 command surface、trading button、live command、order form 或 secret editor，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-534 必须建立的主要 anchors：

- `GH-534-DASHBOARD-LIVE-MONITORING-SURFACE`
- `GH-534-CONNECTION-HEALTH-READ-MODEL`
- `GH-534-ACCOUNT-PRIVATE-STREAM-STATUS`
- `GH-534-TRADER-EMA-RISK-EXECUTION-PORTFOLIO-SUMMARY`
- `GH-534-READ-MODEL-ONLY-NO-COMMAND-SURFACE`
- `TVM-RELEASE-V010-DASHBOARD-LIVE-MONITORING-SURFACE`
- `testGH534ReleaseV010DashboardLiveMonitoringSurfaceIsReadModelOnly`

## GH-534 禁止

- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不读取、打印、保存或推导 production secret。
- 不接受 production account endpoint、production private payload、production stream endpoint 或 production broker endpoint。
- 不让 Dashboard 直接 import / consume runtime object、adapter request、broker state、OMS store 或 ExecutionClient command object。
- 不暴露 secret editor、broker connect、account connect、trading button、live command 或 order form。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-535 Dashboard Controlled Command Surface Validation

GH-535 必须运行：

- `swift test --filter AppTests/testGH535ReleaseV010DashboardControlledCommandSurfaceDefaultsNoTrade`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-535 的验收要求：

- `Sources/Dashboard/Report/ReleaseV010ControlledCommandSurface.swift` 必须存在，并包含 `GH-535-DASHBOARD-CONTROLLED-COMMAND-SURFACE` 和 `TVM-RELEASE-V010-DASHBOARD-CONTROLLED-COMMAND-SURFACE` anchors。
- Dashboard report / shell smoke 必须暴露受控 command entry 数量，并证明默认 no-trade。
- Surface 必须展示 dry-run / Binance testnet gate、production disabled explanation、RiskEngine / ExecutionEngine / OMS / kill switch gate requirement。
- Production command 必须继续 disabled；不得读取 secret、连接 production endpoint、调用 ExecutionClient、连接 broker、提交 / 取消 / 替换真实订单。
- PR evidence 必须确认不使用 Linear，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-535 必须建立的主要 anchors：

- `GH-535-DASHBOARD-CONTROLLED-COMMAND-SURFACE`
- `GH-535-DEFAULT-NO-TRADE-COMMAND-ENTRY`
- `GH-535-DRYRUN-TESTNET-GATE`
- `GH-535-PRODUCTION-DISABLED-BY-DEFAULT`
- `GH-535-NO-RISK-EXECUTION-KILLSWITCH-BYPASS`
- `TVM-RELEASE-V010-DASHBOARD-CONTROLLED-COMMAND-SURFACE`
- `testGH535ReleaseV010DashboardControlledCommandSurfaceDefaultsNoTrade`

## GH-535 禁止

- 不启用 production trading。
- 不读取、打印、保存或推导 production secret。
- 不连接 production endpoint、production broker endpoint、account endpoint、listenKey 或 private WebSocket runtime。
- 不让 Dashboard 直接调用 ExecutionClient、broker gateway、OMS store 或真实 order lifecycle。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch、operator confirmation 或 no-trade state。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。

## GH-530 ExecutionEngine OMS Lifecycle Validation

GH-530 必须运行：

- `swift test --filter TargetGraphTests/testGH530ExecutionEngineOMSStateMachineRequiresRiskApprovedEvidence`
- `git diff --check`
- `bash checks/automation-readiness.sh`
- `bash checks/run.sh`

GH-530 的验收要求：

- `Sources/ExecutionEngine/OMSFutureGate/ReleaseV010ExecutionOMSStateMachine.swift` 必须存在，并包含 `GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE` 和 `TVM-RELEASE-V010-EXECUTIONENGINE-OMS-LIFECYCLE` anchors。
- `Package.swift` 必须让 `ExecutionEngine` target 显式拥有 `OMSFutureGate` source root，并保持 `RiskEngine` dependency。
- State machine 必须消费 #529 `ReleaseV010RiskPreTradeDecisionEvidence`；只有 `approved` decision 能创建 local order intent 并进入 accepted / canceled / replaced / filled path。
- `rejected` 或 `blocked` risk decision 只能进入 rejected path，不得 fallback 到 ExecutionClient、broker retry、OMS bypass 或 Dashboard command surface。
- Evidence 必须覆盖 `new`、`accepted`、`rejected`、`canceled`、`replaced`、`filled` 状态，以及 append-only OMS event log / audit evidence。
- Runtime evidence 必须保持 `productionTradingEnabledByDefault == false`、`productionOMSRuntimeEnabledByDefault == false`、`callsExecutionClient == false`、`touchesBrokerGateway == false`、`submitsRealOrder == false`、`cancelsRealOrder == false`、`replacesRealOrder == false`、`performsReconciliation == false`、`exposesLiveCommandSurface == false`、`nonBinanceVenueEnabled == false` 和 `nonEMAStrategyEnabled == false`。
- `Tests/TargetGraphTests/TargetGraphTests.swift` 必须包含 `testGH530ExecutionEngineOMSStateMachineRequiresRiskApprovedEvidence`，验证 ExecutionEngine source ownership、RiskEngine dependency、risk-approved order intent、state coverage、event log audit evidence、blocked risk rejection path、production OMS default rejection 和 illegal transition rejection。
- GH-530 PR evidence 必须确认不读取 production secret，不连接 production endpoint，不调用 ExecutionClient / broker，不提交、取消或替换真实订单，不执行 reconciliation，不启用 production trading，不启动 Symphony，不运行 Graphify / code-index，不修改 Figma，不提交 `.codex/*` 或 `graphify-out/*`。

GH-530 必须建立的主要 anchors：

- `GH-530-EXECUTIONENGINE-OMS-STATE-MACHINE`
- `GH-530-RISK-APPROVED-ORDER-INTENT`
- `GH-530-OMS-EVENT-LOG-AUDIT-EVIDENCE`
- `GH-530-NO-PRODUCTION-OMS-RUNTIME`
- `TVM-RELEASE-V010-EXECUTIONENGINE-OMS-LIFECYCLE`
- `testGH530ExecutionEngineOMSStateMachineRequiresRiskApprovedEvidence`

## GH-530 禁止

- 不启用 non-Binance venue。
- 不启用 non-EMA active strategy。
- 不读取、打印、保存或推导 production secret。
- 不接受 production endpoint、production stream endpoint 或 production broker endpoint。
- 不调用 ExecutionClient 或 broker gateway。
- 不提交、取消或替换真实订单。
- 不把 local OMS event log 扩大成 production OMS runtime、production order store、execution report parser、broker fill parser 或 reconciliation runtime。
- 不暴露 Dashboard command surface、trading button、live command 或 order form。
- 不绕过 RiskEngine、ExecutionEngine、OMS、kill switch 或 no-trade gate。
- 不创建下一 Project / Issue，不推进 release v0.1.0 之后的阶段。
- 不启动 Symphony / symphony-issue，不运行 Graphify，不运行 code-index，不修改 Figma。
- 不提交 `.codex/*`、`.build/*` 或 `graphify-out/*`。
