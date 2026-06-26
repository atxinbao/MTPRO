# Trading Validation Matrix

日期：2026-06-14

执行者：Codex

本文档是交易验证矩阵的压缩索引，只保留 Matrix ID、issue backfill、release guard、required exact strings 和少量边界词。它不授权 Linear issue，不修改状态，不启动 Symphony，不创建 Project / Issue，不替代 PR evidence 或 Stage Code Audit。

## TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC

- TVM-RELEASE-V0161-V0160-RELEASE-FACT-SYNC
- GH-1133-VERIFY-V0161-V0160-RELEASE-FACT-SYNC
- V0161-001-V0160-RELEASE-FACT-SYNC-GUARD
- V0161-001-V0160-TAG-FIXED
- V0161-001-PATCH-QUEUE-NOT-PUBLICATION
- V0161-001-NO-PRODUCTION-CUTOVER
- GH-1133 Release v0.16.1 v0.16.0 Release Fact Sync Guard
- `bash checks/verify-v0.16.1-release-fact-sync.sh`
- `swift test --filter TargetGraphTests/testGH1133ReleaseV0161V0160ReleaseFactSyncGuard`
- Evidence files: `docs/release/mtpro-release-v0.16.1-operator-beta-evidence-hardening-patch-notes.md`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`docs/automation/automation-readiness.md`、`docs/release/release-publication-policy.md`、`checks/verify-v0.16.1-release-fact-sync.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1133 fixes v0.16.0 publication facts for v0.16.1 patch evidence. `https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0` remains the v0.16.0 stable GitHub Release, tag peeled commit remains `28779236262bd7ffaf71e286b27b95854c5cd3e1`, publication timestamp remains `2026-06-26T01:29:21Z`. v0.16.1 is patch evidence only; it does not move tag, overwrite release, or authorize production cutover. production cutover not authorized.

## TVM-RELEASE-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT

- TVM-RELEASE-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT
- GH-1134-VERIFY-V0161-MANUAL-EVIDENCE-BUNDLE-CONTENT
- V0161-002-BUNDLE-SCHEMA-PARSED
- V0161-002-ACTION-SEQUENCE-CHECKED
- V0161-002-CHECKSUM-REFERENCES-CHECKED
- V0161-002-NO-SECRET-NO-PRODUCTION-MARKERS
- V0161-002-NO-PRODUCTION-CUTOVER
- GH-1134 Release v0.16.1 Manual Evidence Bundle Content Guard
- `bash checks/verify-v0.16.1-manual-evidence-bundle-content.sh`
- `swift test --filter TargetGraphTests/testGH1134ReleaseV0161ManualEvidenceBundleContentValidationReadsBundle`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0160ManualTestnetValidationWorkflow.swift`、`Sources/MTPROCLI/main.swift`、`.github/workflows/release-v0.16.0-manual-testnet-validation.yml`、`docs/contracts/release-v0.16.0-manual-testnet-validation-workflow-contract.md`、`docs/operators/release-v0.16.0-manual-testnet-validation-workflow-runbook.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`docs/automation/automation-readiness.md`、`docs/release/release-publication-policy.md`、`checks/verify-v0.16.1-manual-evidence-bundle-content.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1134 hardens the v0.16 manual validation workflow by reading the redacted bundle JSON content and checking schema, action sequence, checksum references, reconciliation and no-secret / no-production markers. It does not read production secret, connect production endpoint / broker endpoint, send testnet or production order, or authorize production cutover.

## TVM-RELEASE-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY

- TVM-RELEASE-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY
- GH-1135-VERIFY-V0161-CENTRAL-ARTIFACT-REDACTION-POLICY
- V0161-003-SHARED-REDACTION-POLICY-SOURCE
- V0161-003-ARTIFACT-STORE-POLICY-USES-SHARED-SOURCE
- V0161-003-WORKFLOW-BUNDLE-POLICY-USES-SHARED-SOURCE
- V0161-003-DASHBOARD-READ-MODEL-POLICY-USES-SHARED-SOURCE
- V0161-003-NO-SECRET-NO-PRODUCTION-MARKERS
- V0161-003-NO-PRODUCTION-CUTOVER
- GH-1135 Release v0.16.1 Central Artifact Redaction Policy Guard
- `bash checks/verify-v0.16.1-central-artifact-redaction-policy.sh`
- `swift test --filter TargetGraphTests/testGH1135ReleaseV0161CentralArtifactRedactionPolicyIsSharedAcrossSurfaces`
- Evidence files: `Sources/DomainModel/ReleaseV0161OperatorBetaArtifactRedactionPolicy.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0160ManualTestnetValidationWorkflow.swift`、`Sources/Dashboard/Report/ReleaseV0160DashboardArtifactBackedExecutionView.swift`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`docs/automation/automation-readiness.md`、`docs/release/release-publication-policy.md`、`docs/release/mtpro-release-v0.16.1-operator-beta-evidence-hardening-patch-notes.md`、`checks/verify-v0.16.1-central-artifact-redaction-policy.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1135 centralizes the v0.16 operator beta artifact redaction policy in DomainModel and reuses it from artifact store, manual workflow validator, Dashboard read model and tests. It does not read production secret, connect production endpoint / broker endpoint, send testnet or production order, or authorize production cutover.

## TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT

- TVM-RELEASE-V0160-OPERATOR-BETA-CONTRACT
- GH-1101-VERIFY-V0160-OPERATOR-BETA-CONTRACT
- V0160-001-V0151-PREFLIGHT-GATE
- V0160-001-BINANCE-SPOT-TESTNET-ONLY
- V0160-001-OPERATOR-CONFIRMATION-REQUIRED
- V0160-001-REDACTED-EVIDENCE-REQUIRED
- V0160-001-QUEUE-ORDER
- V0160-001-NO-PRODUCTION-CUTOVER
- GH-1101 Release v0.16.0 Operator Beta Contract / Preflight Guard
- `bash checks/verify-v0.16.0-operator-beta-contract.sh`
- `swift test --filter TargetGraphTests/testGH1101ReleaseV0160OperatorBetaContractBlocksProductionCutover`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorBetaContract.swift`、`docs/contracts/release-v0.16.0-binance-spot-testnet-operator-beta-contract.md`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.16.0-operator-beta-contract.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1101 is the v0.16.0 contract / preflight issue only. It requires v0.15.1 / GH-1100 closeout, keeps WIP=1 queue order #1101..#1112, limits the release to Binance Spot Testnet operator beta, requires explicit operator confirmation and redacted evidence, and keeps production cutover unauthorized. Credential value read, testnet network connection and testnet order submission are deferred to later explicitly scoped issues.

## TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS

- TVM-RELEASE-V0160-STAGE-AUDIT-RELEASE-DOCS
- GH-1112-VERIFY-V0160-STAGE-AUDIT-RELEASE-DOCS
- V0160-012-STAGE-CODE-AUDIT
- V0160-012-RELEASE-NOTES
- V0160-012-OPERATOR-RUNBOOK
- V0160-012-VALIDATION-MATRIX
- V0160-012-STALE-WORDING-GUARD
- V0160-012-NO-PRODUCTION-CUTOVER
- V0160-012-NO-TAG-OR-RELEASE-PUBLICATION
- GH-1112 Release v0.16.0 Stage Audit / Release Docs Closeout
- `bash checks/verify-v0.16.0-stage-audit-release-docs.sh`
- `swift test --filter TargetGraphTests/testGH1112ReleaseV0160StageAuditReleaseDocsCloseout`
- Evidence files: `docs/audit/mtpro-release-v0.16.0-binance-spot-testnet-operator-execution-beta-stage-code-audit.md`、`docs/release/mtpro-release-v0.16.0-binance-spot-testnet-operator-execution-beta-notes.md`、`docs/operators/release-v0.16.0-binance-spot-testnet-operator-execution-beta-runbook.md`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`docs/automation/automation-readiness.md`、`docs/release/release-publication-policy.md`、`checks/verify-v0.16.0-stage-audit-release-docs.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1112 closes v0.16.0 construction evidence only. The #1112 closeout itself does not create a tag / GitHub Release, does not create the next Project / Issue, does not authorize production cutover, does not read production secrets, does not connect production endpoint / broker endpoint, and does not submit production orders. A subsequent independent Release Publication Gate published the stable v0.16.0 GitHub Release at `https://github.com/atxinbao/MTPRO/releases/tag/v0.16.0`, tag peeled commit `28779236262bd7ffaf71e286b27b95854c5cd3e1`, without authorizing production cutover.

## TVM-RELEASE-V0160-OPERATOR-RUN-MODEL

- TVM-RELEASE-V0160-OPERATOR-RUN-MODEL
- GH-1102-VERIFY-V0160-OPERATOR-RUN-MODEL
- V0160-002-RUN-ID-LIFECYCLE
- V0160-002-ACTION-SEQUENCE
- V0160-002-ARTIFACT-LINKAGE
- V0160-002-INVALID-TRANSITION-FAILS-CLOSED
- V0160-002-REDACTED-METADATA
- V0160-002-NO-NETWORK-BY-THIS-ISSUE
- V0160-002-NO-PRODUCTION-CUTOVER
- GH-1102 Release v0.16.0 Operator Run Model Guard
- `bash checks/verify-v0.16.0-operator-run-model.sh`
- `swift test --filter TargetGraphTests/testGH1102ReleaseV0160OperatorRunModelDefinesRunIDLifecycleAndFailsClosed`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0160OperatorRunModel.swift`、`docs/contracts/release-v0.16.0-binance-spot-testnet-operator-run-model-contract.md`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.16.0-operator-run-model.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1102 is the v0.16.0 operator run model issue only. It defines durable run id lifecycle, action sequence, artifact linkage, redacted metadata and invalid transition fail-closed guards. It does not read credential values, connect to testnet endpoints, submit testnet orders or authorize production cutover.

## TVM-RELEASE-V0160-CLI-SUBMIT-FLOW

- TVM-RELEASE-V0160-CLI-SUBMIT-FLOW
- GH-1103-VERIFY-V0160-CLI-SUBMIT-FLOW
- V0160-003-STABLE-CLI-SUBMIT
- V0160-003-V0151-RUNTIME-DELEGATION
- V0160-003-EXPLICIT-OPERATOR-CONFIRMATION
- V0160-003-TESTNET-CREDENTIAL-PROFILE
- V0160-003-REDACTED-OUTPUT-ARTIFACT-CHECKSUM
- V0160-003-MISSING-GATE-CREDENTIAL-CONFIRMATION-FAILS-CLOSED
- V0160-003-NO-PRODUCTION-CUTOVER
- GH-1103 Release v0.16.0 CLI Submit Flow Guard
- `bash checks/verify-v0.16.0-cli-submit-flow.sh`
- `swift test --filter TargetGraphTests/testGH1103ReleaseV0160CLISubmitFlowUsesStableOperatorSubmitAndFailsClosed`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0160CLISubmitExecutionFlow.swift`、`Sources/MTPROCLI/main.swift`、`docs/contracts/release-v0.16.0-binance-spot-testnet-cli-submit-flow-contract.md`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.16.0-cli-submit-flow.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1103 is the v0.16.0 stable CLI submit flow issue only. It exposes `spot-testnet-submit`, delegates submit to the v0.15.1 guarded runtime, requires explicit v0.16 operator confirmation and testnet-env credential profile, and returns redacted artifact path / checksum evidence. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0160-CLI-CANCEL-FLOW

- TVM-RELEASE-V0160-CLI-CANCEL-FLOW
- GH-1104-VERIFY-V0160-CLI-CANCEL-FLOW
- V0160-004-STABLE-CLI-CANCEL
- V0160-004-SUBMIT-ARTIFACT-IDENTITY
- V0160-004-V0151-RUNTIME-DELEGATION
- V0160-004-EXPLICIT-OPERATOR-CONFIRMATION
- V0160-004-TESTNET-CREDENTIAL-PROFILE
- V0160-004-REDACTED-ORDER-REFERENCE
- V0160-004-APPEND-ONLY-EVENT-EVIDENCE
- V0160-004-MISSING-PRIOR-ARTIFACT-FAILS-CLOSED
- V0160-004-NO-PRODUCTION-CUTOVER
- GH-1104 Release v0.16.0 CLI Cancel Flow Guard
- `bash checks/verify-v0.16.0-cli-cancel-flow.sh`
- `swift test --filter TargetGraphTests/testGH1104ReleaseV0160CLICancelFlowConsumesSubmitArtifactAndFailsClosed`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0160CLICancelExecutionFlow.swift`、`Sources/MTPROCLI/main.swift`、`docs/contracts/release-v0.16.0-binance-spot-testnet-cli-cancel-flow-contract.md`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.16.0-cli-cancel-flow.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1104 is the v0.16.0 stable CLI cancel flow issue only. It exposes `spot-testnet-cancel`, consumes source submit evidence JSON and network event log JSON, delegates cancel to the v0.15.1 guarded runtime, requires explicit v0.16 operator confirmation and testnet-env credential profile, and returns redacted order reference / artifact path / checksum evidence. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0160-SIGNED-ORDER-STATUS-QUERY

- TVM-RELEASE-V0160-SIGNED-ORDER-STATUS-QUERY
- GH-1105-VERIFY-V0160-SIGNED-ORDER-STATUS-QUERY
- V0160-005-SIGNED-GET-ORDER-STATUS
- V0160-005-TESTNET-ENDPOINT-ALLOWLIST
- V0160-005-REDACTED-REQUEST-RESPONSE-EVIDENCE
- V0160-005-NO-RAW-SECRET-PERSISTENCE
- V0160-005-PRODUCTION-HOST-REJECTED
- V0160-005-NO-PRODUCTION-CUTOVER
- GH-1105 Release v0.16.0 Signed Order Status Query Guard
- `bash checks/verify-v0.16.0-order-status-query.sh`
- `swift test --filter TargetGraphTests/testGH1105ReleaseV0160SignedOrderStatusQueryUsesGETAllowlistAndRedaction`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0160CLIOrderStatusQueryFlow.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift`、`Sources/MTPROCLI/main.swift`、`docs/contracts/release-v0.16.0-binance-spot-testnet-order-status-query-contract.md`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.16.0-order-status-query.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1105 is the v0.16.0 stable signed order status query issue only. It exposes `spot-testnet-status-query`, consumes source submit evidence JSON and network event log JSON, constructs allowlisted signed GET `/api/v3/order`, and returns redacted request / response evidence plus artifact path / checksum evidence. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0160-LOCAL-EXECUTION-ARTIFACT-STORE

- TVM-RELEASE-V0160-LOCAL-EXECUTION-ARTIFACT-STORE
- GH-1106-VERIFY-V0160-LOCAL-EXECUTION-ARTIFACT-STORE
- V0160-006-APPEND-ONLY-ARTIFACT-PERSISTENCE
- V0160-006-CHECKSUM-MANIFEST
- V0160-006-CHECKSUM-MISMATCH-REJECTED
- V0160-006-REPLAY-VALIDATION
- V0160-006-REDACTED-EXPORT-BUNDLE
- V0160-006-NO-PRODUCTION-CUTOVER
- GH-1106 Release v0.16.0 Local Execution Artifact Store Guard
- `bash checks/verify-v0.16.0-local-execution-artifact-store.sh`
- `swift test --filter TargetGraphTests/testGH1106ReleaseV0160LocalExecutionArtifactStorePersistsValidatesReplaysAndExports`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0160LocalExecutionArtifactStore.swift`、`docs/contracts/release-v0.16.0-local-execution-artifact-store-contract.md`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.16.0-local-execution-artifact-store.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1106 is the v0.16.0 local execution artifact store issue only. It persists submit / cancel / status / reconciliation redacted evidence as append-only JSONL, writes checksum manifest, rejects checksum mismatch, validates replay, and exports redacted evidence bundles. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0160-OMS-OBSERVED-STATUS-RECONCILIATION

- TVM-RELEASE-V0160-OMS-OBSERVED-STATUS-RECONCILIATION
- GH-1107-VERIFY-V0160-OMS-OBSERVED-STATUS-RECONCILIATION
- V0160-007-SUBMIT-OBSERVED-RECONCILIATION
- V0160-007-CANCEL-OBSERVED-RECONCILIATION
- V0160-007-UNKNOWN-STATUS-FAILS-CLOSED
- V0160-007-MISMATCH-FAILS-CLOSED
- V0160-007-LOCAL-ARTIFACTS-ONLY
- V0160-007-NO-PRODUCTION-CUTOVER
- GH-1107 Release v0.16.0 OMS Observed Status Reconciliation Guard
- `bash checks/verify-v0.16.0-oms-observed-status-reconciliation.sh`
- `swift test --filter TargetGraphTests/testGH1107ReleaseV0160OMSObservedStatusReconciliationFromLocalArtifactsFailsClosed`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0160OMSObservedStatusReconciliation.swift`、`docs/contracts/release-v0.16.0-oms-observed-status-reconciliation-contract.md`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.16.0-oms-observed-status-reconciliation.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1107 is the v0.16.0 OMS observed-status reconciliation issue only. It consumes local submit / cancel / status artifacts from the #1106 replay surface and produces deterministic pass / fail-closed reconciliation reports for submit observed, cancel observed, unknown status, expected-state mismatch, missing cancel artifact and non-status evidence. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW

- TVM-RELEASE-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW
- GH-1108-VERIFY-V0160-DASHBOARD-ARTIFACT-BACKED-EXECUTION-VIEW
- V0160-008-LOCAL-ARTIFACT-BACKED-ROWS
- V0160-008-ACTION-SEQUENCE-VISIBLE
- V0160-008-CHECKSUMS-VISIBLE
- V0160-008-OMS-RECONCILIATION-RESULT-VISIBLE
- V0160-008-DASHBOARD-READ-ONLY-NO-COMMANDS
- V0160-008-NO-PRODUCTION-CUTOVER
- GH-1108 Release v0.16.0 Dashboard Artifact-backed Execution View Guard
- `bash checks/verify-v0.16.0-dashboard-artifact-backed-execution-view.sh`
- `swift test --filter AppTests/testGH1108DashboardArtifactBackedExecutionViewShowsLocalArtifactsWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1108DashboardArtifactBackedExecutionViewIsAnchoredInV0160Guards`
- Evidence files: `Sources/Dashboard/Report/ReleaseV0160DashboardArtifactBackedExecutionView.swift`、`Sources/Dashboard/DashboardShell.swift`、`docs/contracts/release-v0.16.0-dashboard-artifact-backed-execution-view-contract.md`、`Tests/AppTests/AppTests.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.16.0-dashboard-artifact-backed-execution-view.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1108 is the v0.16.0 Dashboard artifact-backed execution view issue only. It consumes local read-model artifacts and renders artifact-backed rows, action sequence, checksums, artifact paths and OMS reconciliation result as read-only Dashboard evidence. Dashboard command surface, trading button, order form, live command, production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0151-V0150-RELEASE-FACT-SYNC

- TVM-RELEASE-V0151-V0150-RELEASE-FACT-SYNC
- GH-1094-VERIFY-V0151-V0150-RELEASE-FACT-SYNC
- V0151-001-V0150-RELEASE-FACT-SYNC-GUARD
- GH-1094 Release v0.15.1 v0.15.0 Release Fact Sync / Stale Wording Guard
- `bash checks/verify-v0.15.1-v0150-release-fact-sync.sh`
- `swift test --filter TargetGraphTests/testGH1094ReleaseV0151V0150ReleaseFactSyncGuardRejectsStalePublicationWording`
- Evidence files: `README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/validation/latest-verification-summary.md`、`docs/release/release-publication-policy.md`、`docs/release/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-notes.md`、`docs/automation/automation-readiness.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.15.1-v0150-release-fact-sync.sh`、`checks/run.sh`、`checks/automation-readiness.sh` 和 `Tests/TargetGraphTests/TargetGraphTests.swift`。
- Boundary: GH-1094 只允许同步 v0.15.0 stable GitHub Release 已发布事实：release URL `https://github.com/atxinbao/MTPRO/releases/tag/v0.15.0`，tag peeled commit `1590b6c40e6ca7887cff0ca59b2f74e4fe7e3ece`，publication timestamp `2026-06-23T01:26:30Z`。#1076 historical closeout 仍不是 release publication gate；未限定为 #1076 的 v0.15.0 stale publication wording 必须 fail。该 guard 不移动 tag、不覆盖 release、不授权 production cutover、不读取 production secret、不连接 production endpoint / broker endpoint、不提交 production order。

## TVM-RELEASE-V0151-INJECTED-TRANSPORT-WORDING

- TVM-RELEASE-V0151-INJECTED-TRANSPORT-WORDING
- GH-1095-VERIFY-V0151-INJECTED-TRANSPORT-WORDING
- V0151-002-INJECTED-TRANSPORT-NOT-BUILTIN-RUNNER
- V0151-002-MOCK-MANUAL-PROOF-SPLIT
- V0151-002-FUTURE-URLSESSION-RUNNER-DEFERRED
- GH-1095 Release v0.15.1 Injected Transport / Built-in Runner Wording Guard
- `bash checks/verify-v0.15.1-transport-wording.sh`
- `swift test --filter TargetGraphTests/testGH1095ReleaseV0151InjectedTransportWordingRejectsBuiltinRunnerClaims`
- Evidence files: `README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/validation/latest-verification-summary.md`、`docs/release/release-publication-policy.md`、`docs/release/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-notes.md`、`docs/audit/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-stage-code-audit.md`、`docs/operators/release-v0.15.0-real-binance-testnet-execution-mvp-runbook.md`、`docs/automation/automation-readiness.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.15.1-transport-wording.sh`、`checks/run.sh`、`checks/automation-readiness.sh` 和 `Tests/TargetGraphTests/TargetGraphTests.swift`。
- Boundary: v0.15.0 signed execution evidence must be described as injected Spot Testnet transport protocol, deterministic mock proof, or operator manual proof. Built-in network runner, CLI default real-network runner, production broker connector, production endpoint, production secret and production order remain unauthorized and must not be implied by v0.15.0 wording. #1096 is the later concrete network transport hardening slice.

## TVM-RELEASE-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT

- TVM-RELEASE-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT
- GH-1096-VERIFY-V0151-URLSESSION-SPOT-TESTNET-TRANSPORT
- V0151-003-URLSESSION-SPOT-TESTNET-ALLOWLIST
- V0151-003-SUBMIT-CANCEL-URLSESSION-TRANSPORT
- V0151-003-REDACTED-RESPONSE-DIGEST
- V0151-003-NO-SECRET-PERSISTENCE
- V0151-003-PRODUCTION-ENDPOINT-REJECTED
- V0151-003-NO-PRODUCTION-CUTOVER
- GH-1096 Release v0.15.1 URLSession Spot Testnet Transport Guard
- `bash checks/verify-v0.15.1-urlsession-spot-testnet-transport.sh`
- `swift test --filter TargetGraphTests/testGH1096ReleaseV0151URLSessionSpotTestnetTransportUsesAllowlistAndRedaction`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.15.1-urlsession-spot-testnet-transport.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1096 only authorizes Binance Spot Testnet `https://testnet.binance.vision/api/v3/order` URLSession submit / cancel transport. Host / scheme / path are allowlisted; production hosts are rejected fail-closed; response body becomes `response-sha256` redacted digest; API key, secret and raw order identity are not persisted. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0151-CLI-TESTNET-EXECUTION-RUNTIME

- TVM-RELEASE-V0151-CLI-TESTNET-EXECUTION-RUNTIME
- GH-1097-VERIFY-V0151-CLI-TESTNET-EXECUTION-RUNTIME
- V0151-004-CLI-GUARDED-RUNTIME-INVOKED
- V0151-004-TESTNET-ONLY-CREDENTIAL-PROVIDER
- V0151-004-SUBMIT-CANCEL-CANCEL-REPLACE-RUNTIME
- V0151-004-EXPLICIT-OPERATOR-CONFIRMATION
- V0151-004-REDACTED-OUTPUT
- V0151-004-MISSING-CREDENTIAL-FAIL-CLOSED
- V0151-004-RUN-ID-ARTIFACT-CHECKSUM
- V0151-004-NO-PRODUCTION-CUTOVER
- GH-1097 Release v0.15.1 CLI Testnet Execution Runtime Guard
- `bash checks/verify-v0.15.1-cli-testnet-execution-runtime.sh`
- `swift test --filter TargetGraphTests/testGH1097ReleaseV0151CLITestnetExecutionInvokesGuardedRuntime`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.swift`、`Sources/MTPROCLI/main.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.15.1-cli-testnet-execution-runtime.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1097 only authorizes CLI wiring from `mtpro testnet-execution` to v0.15 guarded runtime for Binance Spot Testnet submit / cancel / cancel-replace. `testnet-env` is the only provider, missing testnet credential or confirmation fails closed, output is redacted and returns run id / artifact path / checksum. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0151-RUNTIME-INTERNAL-GATES

- TVM-RELEASE-V0151-RUNTIME-INTERNAL-GATES
- GH-1098-VERIFY-V0151-RUNTIME-INTERNAL-GATES
- V0151-005-RISKENGINE-GATE-IN-RUNTIME
- V0151-005-KILL-SWITCH-GATE-IN-RUNTIME
- V0151-005-NO-TRADE-GATE-IN-RUNTIME
- V0151-005-OPERATOR-CONFIRMATION-IN-RUNTIME
- V0151-005-TRANSPORT-NOT-INVOKED-WHEN-BLOCKED
- V0151-005-NO-PRODUCTION-CUTOVER
- GH-1098 Release v0.15.1 Runtime Internal Gate Guard
- `bash checks/verify-v0.15.1-runtime-internal-gates.sh`
- `swift test --filter TargetGraphTests/testGH1098ReleaseV0151RuntimeInternalGatesBlockTransportBeforeInvocation`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetRuntimeInternalGate.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.15.1-runtime-internal-gates.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1098 only authorizes internal pre-transport gates for Binance Spot Testnet submit / cancel / cancel-replace runtime. Risk rejection, active kill switch, active no-trade and missing confirmation must block before any transport invocation. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN

- TVM-RELEASE-V0151-CLIENT-ORDER-IDENTITY-CHAIN
- GH-1099-VERIFY-V0151-CLIENT-ORDER-IDENTITY-CHAIN
- V0151-006-DETERMINISTIC-NEW-CLIENT-ORDER-ID
- V0151-006-REDACTED-CLIENT-ORDER-REFERENCE
- V0151-006-SUBMIT-TO-CANCEL-IDENTITY-HANDOFF
- V0151-006-RAW-UNTRACKED-ORDER-ID-REJECTED
- V0151-006-NO-PRODUCTION-CUTOVER
- GH-1099 Release v0.15.1 Client Order Identity Chain Guard
- `bash checks/verify-v0.15.1-client-order-identity-chain.sh`
- `swift test --filter TargetGraphTests/testGH1099ReleaseV0151ClientOrderIdentityChainDerivesCancelIdentityFromSubmitEvidence`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetURLSessionTransport.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0151BinanceSpotTestnetCLIGuardedRuntimeFlow.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`checks/verify-v0.15.1-client-order-identity-chain.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1099 only authorizes deterministic Binance Spot Testnet client order identity handoff. Submit evidence stores redacted/hash `newClientOrderId` reference, cancel derives short-lived identity material from submit evidence, and raw / untracked order ids fail closed. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT

- TVM-RELEASE-V0151-CODABLE-DECODE-CLOSEOUT
- GH-1100-VERIFY-V0151-CODABLE-DECODE-CLOSEOUT
- V0151-007-CODABLE-DECODE-VALIDATION
- V0151-007-CORRUPTED-JSON-FAILS-CLOSED
- V0151-007-CHECKSUM-MISMATCH-FAILS-CLOSED
- V0151-007-PRODUCTION-HOST-MUTATION-REJECTED
- V0151-007-NO-PRODUCTION-CUTOVER
- GH-1100 Release v0.15.1 Codable Decode Closeout Guard
- `bash checks/verify-v0.15.1-codable-decode-closeout.sh`
- `swift test --filter TargetGraphTests/testGH1100ReleaseV0151CodableDecodeValidationFailsClosedOnMutatedArtifacts`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0151CodableDecodeBoundary.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetOMSStateReconciliation.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`README.md`、`GOAL.md`、`BLUEPRINT.md`、`docs/roadmap.md`、`docs/release/release-publication-policy.md`、`docs/automation/automation-readiness.md`、`docs/validation/latest-verification-summary.md`、`docs/validation/validation-plan.md`、`docs/audit/mtpro-release-v0.15.1-real-testnet-execution-hardening-patch-stage-code-audit.md`、`checks/verify-v0.15.1-codable-decode-closeout.sh`、`checks/run.sh` 和 `checks/automation-readiness.sh`。
- Boundary: GH-1100 only authorizes decode-time validation and patch closeout for v0.15/v0.15.1 Binance Spot Testnet execution evidence. Corrupted JSON, checksum mismatch, production host mutation and production boundary mutation fail closed. Production cutover, production secret read, production endpoint / broker endpoint connection and production order remain unauthorized.

## TVM-RELEASE-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT

- TVM-RELEASE-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT
- GH-1076-VERIFY-V0150-RELEASE-CI-MANUAL-TESTNET-AUDIT
- V0150-011-STAGE-CODE-AUDIT
- V0150-011-MANUAL-TESTNET-WORKFLOW
- V0150-011-RELEASE-NOTES
- V0150-011-VALIDATION-SUITE
- V0150-011-PRODUCTION-DISABLED-PROOF
- V0150-011-NO-PRODUCTION-CUTOVER
- GH-1076 Release v0.15.0 Release CI + Manual Testnet Workflow + Audit Evidence
- `bash checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh`
- `swift test --filter TargetGraphTests/testGH1076ReleaseV0150FinalAuditManualWorkflowCloseout`
- Evidence files: `docs/audit/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-stage-code-audit.md`、`docs/release/mtpro-release-v0.15.0-real-binance-testnet-execution-mvp-notes.md`、`docs/operators/release-v0.15.0-real-binance-testnet-execution-mvp-runbook.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-release-ci-manual-testnet-audit.sh`、`docs/automation/automation-readiness.md`、`docs/validation/validation-plan.md` 和 `Tests/TargetGraphTests/TargetGraphTests.swift`。
- Boundary: GH-1076 只允许 release CI、manual Spot Testnet workflow、Stage Code Audit、release notes 和 production-disabled proof closeout。`productionTradingEnabledByDefault=false`，`productionSecretAutoRead=false`，`productionEndpointConnected=false`，`brokerEndpointConnected=false`，`productionOrderSubmitted=false`，`productionCutoverAuthorized=false`；不创建 tag / GitHub Release，不推进下一阶段，不授权 production cutover。

## TVM-RELEASE-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT

- TVM-RELEASE-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT
- GH-1075-VERIFY-V0150-FAILURE-SIMULATION-REAL-SIGNED-TRANSPORT
- V0150-010-REJECTED-TIMEOUT-RATELIMIT
- V0150-010-CREDENTIAL-SIGNATURE-FAILURES
- V0150-010-CANCEL-NOT-FOUND
- V0150-010-RECONCILIATION-MISMATCH
- V0150-010-APPEND-ONLY-REDACTED-FAILURE-EVIDENCE
- V0150-010-NO-PRODUCTION-CUTOVER
- GH-1075 Release v0.15.0 Failure Simulation for Real Signed Transport
- `bash checks/verify-v0.15.0-failure-simulation-real-signed-transport.sh`
- `swift test --filter TargetGraphTests/testGH1075ReleaseV0150FailureSimulationCoversSignedTransportAndReconciliationFailures`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetFailureSimulation.swift`、`docs/contracts/release-v0.15.0-failure-simulation-real-signed-transport-contract.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-failure-simulation-real-signed-transport.sh`、`docs/automation/automation-readiness.md`、`docs/validation/validation-plan.md` 和 `Tests/TargetGraphTests/TargetGraphTests.swift`。
- Boundary: GH-1075 允许且只允许本地 deterministic failure simulation，覆盖 rejected request、timeout、rate-limit、stale credential、bad signature、cancel-not-found 和 reconciliation mismatch。`failureSimulationOnly=true`，`deterministicFailureSimulation=true`，`appendOnlyFailureEvidence=true`，`redactedRequestIdentity=true`，`redactedResponseIdentity=true`，`omsStateExplainable=true`，`reconciliationMismatchFailClosed=true`；`rawSecretPersisted=false`，`productionTradingEnabledByDefault=false`，`productionSecretAutoRead=false`，`productionEndpointConnected=false`，`brokerEndpointConnected=false`，`productionOrderSubmitted=false`；不授权 network action execution、production cutover、production order 或 broker endpoint。

## TVM-RELEASE-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS

- TVM-RELEASE-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS
- GH-1074-VERIFY-V0150-DASHBOARD-TESTNET-EXECUTION-STATUS
- V0150-009-DASHBOARD-READ-MODEL-ARTIFACT
- V0150-009-SUBMIT-CANCEL-CANCEL-REPLACE-STATUS
- V0150-009-OMS-RECONCILIATION-FAILURE-REASONS
- V0150-009-DASHBOARD-READ-ONLY-NO-COMMANDS
- V0150-009-NO-PRODUCTION-CUTOVER
- GH-1074 Release v0.15.0 Dashboard Testnet Execution Status
- `bash checks/verify-v0.15.0-dashboard-testnet-execution-status.sh`
- `swift test --filter AppTests/testGH1074DashboardTestnetExecutionStatusSurfaceShowsReadOnlyStatusWithoutCommands`
- `swift test --filter TargetGraphTests/testGH1074DashboardTestnetExecutionStatusSurfaceIsAnchoredInV0150Guards`
- Evidence files: `Sources/Dashboard/Report/ReleaseV0150DashboardTestnetExecutionStatusSurface.swift`、`Sources/Dashboard/DashboardShell.swift`、`docs/contracts/release-v0.15.0-dashboard-testnet-execution-status-contract.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-dashboard-testnet-execution-status.sh`、`docs/automation/automation-readiness.md`、`docs/validation/validation-plan.md`、`Tests/AppTests/AppTests.swift` 和 `Tests/TargetGraphTests/TargetGraphTests.swift`。
- Boundary: GH-1074 允许且只允许 Dashboard 读取本地 read-model artifact 并展示 submit / cancel / cancel-replace status、OMS state、reconciliation state 和 failure reasons。`dashboardConsumesReadModelArtifactsOnly=true`，`submitCancelCancelReplaceStatusVisible=true`，`omsStateVisible=true`，`reconciliationStateVisible=true`，`failureReasonsVisible=true`；`dashboardCommandSurfaceEnabled=false`，`tradingButtonVisible=false`，`orderFormVisible=false`，`liveCommandVisible=false`，`productionTradingEnabledByDefault=false`，`productionSecretRead=false`，`productionEndpointConnected=false`，`brokerEndpointConnected=false`，`productionSubmitCancelReplaceEnabled=false`；不授权 production cutover、new network action、production order、broker fill 或 Dashboard command surface。

## TVM-RELEASE-V0150-OMS-STATE-SYNC-RECONCILIATION

- TVM-RELEASE-V0150-OMS-STATE-SYNC-RECONCILIATION
- GH-1072-VERIFY-V0150-OMS-STATE-SYNC-RECONCILIATION
- V0150-007-CONSUMES-NETWORK-EVENT-LOG
- V0150-007-OMS-STATE-SYNC-FROM-APPEND-ONLY-EVIDENCE
- V0150-007-EXPECTED-OBSERVED-RECONCILIATION
- V0150-007-MISMATCH-FAIL-CLOSED
- V0150-007-SUBMIT-CANCEL-CANCEL-REPLACE-COVERAGE
- V0150-007-NO-PRODUCTION-CUTOVER
- GH-1072 Release v0.15.0 OMS State Sync + Reconciliation
- `bash checks/verify-v0.15.0-oms-state-sync-reconciliation.sh`
- `swift test --filter TargetGraphTests/testGH1072ReleaseV0150OMSStateReconciliationConsumesNetworkEventLog`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetOMSStateReconciliation.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift`、`docs/contracts/release-v0.15.0-oms-state-sync-reconciliation-contract.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-oms-state-sync-reconciliation.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1072 允许且只允许从 #1071 append-only network event log 生成本地 OMS state snapshot 和 expected / observed reconciliation evidence。`derivedFromNetworkEventLogOnly=true`，`appendOnlyNetworkExecutionEventLog=true`，`expectedObservedReconciliation=true`，`mismatchesFailClosed=true`，`submitCancelCancelReplaceCoverage=true`；`rawBrokerPayloadIncluded=false`，`brokerFillIncluded=false`，`productionTradingEnabledByDefault=false`，`productionSecretAutoRead=false`，`productionEndpointConnected=false`，`brokerEndpointConnected=false`，`productionOrderSubmitted=false`；不授权新 network action、production cutover、production order、broker fill 或 Dashboard command surface。

## TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE

- TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE
- GH-1070-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-REPLACE-RUNTIME
- V0150-005-CANCEL-REPLACE-EMULATION
- V0150-005-CANCEL-THEN-NEW-SUBMIT
- V0150-005-OMS-REPLACE-STATE-TRANSITION
- V0150-005-APPEND-ONLY-CANCEL-REPLACE-EVENT
- V0150-005-UNSUPPORTED-NATIVE-REPLACE-FAIL-CLOSED
- V0150-005-PRODUCTION-ENDPOINT-BLOCKED
- V0150-005-NO-PRODUCTION-CUTOVER
- GH-1070 Release v0.15.0 Real Spot Testnet Cancel-Replace Runtime
- `bash checks/verify-v0.15.0-real-spot-testnet-cancel-replace-runtime.sh`
- `swift test --filter TargetGraphTests/testGH1070ReleaseV0150SpotTestnetCancelReplaceRuntimeEmulatesCancelThenSubmit`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelReplaceRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift`、`docs/contracts/release-v0.15.0-real-spot-testnet-cancel-replace-runtime-contract.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-real-spot-testnet-cancel-replace-runtime.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1070 允许且只允许 Binance Spot Testnet cancel + new submit emulation。`nativeCancelReplaceSupported=false`，`nativeReplaceRejectedFailClosed=true`，`cancelThenNewSubmitEmulationUsed=true`，`testnetNetworkCancelPerformed=true`，`testnetNetworkSubmitPerformed=true`，`appendOnlyCancelReplaceEvidenceCreated=true`，`omsStateTransitionIntegrated=true`；`productionTradingEnabledByDefault=false`，`productionSecretAutoRead=false`，`productionEndpointConnected=false`，`brokerEndpointConnected=false`，`productionOrderSubmitted=false`；不授权 production cutover、native cancelReplace endpoint、broker fill、reconciliation 或 Dashboard command surface。

## TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL

- TVM-RELEASE-V0150-REAL-SPOT-TESTNET-CANCEL
- GH-1069-VERIFY-V0150-REAL-SPOT-TESTNET-CANCEL-RUNTIME
- V0150-004-CANCEL-REQUEST-CONSTRUCTION
- V0150-004-SIGNED-TESTNET-TRANSPORT
- V0150-004-REDACTED-CANCEL-RESPONSE-EVIDENCE
- V0150-004-OMS-CANCEL-STATE-TRANSITION
- V0150-004-APPEND-ONLY-CANCEL-EVENT
- V0150-004-PRODUCTION-ENDPOINT-BLOCKED
- V0150-004-NO-PRODUCTION-CUTOVER
- GH-1069 Release v0.15.0 Real Spot Testnet Cancel Runtime
- `bash checks/verify-v0.15.0-real-spot-testnet-cancel-runtime.sh`
- `swift test --filter TargetGraphTests/testGH1069ReleaseV0150SpotTestnetCancelRuntimeAppendsRedactedCancelEvidence`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetCancelRuntime.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift`、`docs/contracts/release-v0.15.0-real-spot-testnet-cancel-runtime-contract.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-real-spot-testnet-cancel-runtime.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1069 允许且只允许 Binance Spot Testnet cancel runtime evidence。`httpMethod=DELETE`，`testnetNetworkCancelPerformed=true`，`appendOnlyCancelEvidenceCreated=true`，`omsStateTransitionIntegrated=true`，redacted order identity material only；`productionTradingEnabledByDefault=false`，`productionSecretAutoRead=false`，`productionEndpointConnected=false`，`brokerEndpointConnected=false`，`productionOrderSubmitted=false`；不授权 production cutover、production order、cancel-replace 或 Dashboard command surface。

## TVM-RELEASE-V0150-NETWORK-EXECUTION-EVENT-LOG

- TVM-RELEASE-V0150-NETWORK-EXECUTION-EVENT-LOG
- GH-1071-VERIFY-V0150-NETWORK-EXECUTION-EVENT-LOG
- V0150-006-APPEND-ONLY-NETWORK-EVENT-LOG
- V0150-006-REQUEST-RESPONSE-IDENTITY
- V0150-006-CHECKSUM-CHAIN
- V0150-006-RAW-SECRET-NOT-PERSISTED
- V0150-006-NO-PRODUCTION-CUTOVER
- GH-1071 Release v0.15.0 Network Execution Event Log
- `bash checks/verify-v0.15.0-network-execution-event-log.sh`
- `swift test --filter TargetGraphTests/testGH1071ReleaseV0150NetworkExecutionEventLogChainsRedactedArtifacts`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetNetworkExecutionEventLog.swift`、`docs/contracts/release-v0.15.0-network-execution-event-log-contract.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-network-execution-event-log.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1071 允许且只允许 append-only redacted checksum event log 记录已完成的 Spot Testnet network action evidence。它记录 request / response identity、sequence、previous checksum 和 artifact checksum；不保存 raw secret、raw request body 或 raw response body；不实现 cancel-replace runtime，不授权 production cutover、production order 或 Dashboard command surface。

## TVM-RELEASE-V0150-REAL-SPOT-TESTNET-SUBMIT

- TVM-RELEASE-V0150-REAL-SPOT-TESTNET-SUBMIT
- GH-1068-VERIFY-V0150-REAL-SPOT-TESTNET-SUBMIT-RUNTIME
- V0150-003-ORDERINTENT-TO-SIGNED-SUBMIT
- V0150-003-REDACTED-RESPONSE-EVIDENCE
- V0150-003-TESTNET-NETWORK-SUBMIT-PERFORMED
- V0150-003-PRODUCTION-ENDPOINT-BLOCKED
- V0150-003-NO-PRODUCTION-CUTOVER
- GH-1068 Release v0.15.0 Real Spot Testnet Submit Runtime
- `bash checks/verify-v0.15.0-real-spot-testnet-submit-runtime.sh`
- `swift test --filter TargetGraphTests/testGH1068ReleaseV0150SpotTestnetSubmitRuntimeProducesRedactedNetworkEvidence`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSubmitRuntime.swift`、`docs/contracts/release-v0.15.0-real-spot-testnet-submit-runtime-contract.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-real-spot-testnet-submit-runtime.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1068 允许且只允许 Binance Spot Testnet submit runtime evidence。`testnetNetworkSubmitPerformed=true`，`appendOnlyEvidenceCreated=true`，`endpointHost == testnet.binance.vision`，Spot Testnet order endpoint path 只在 GH-1068 source / contract 中作为 scoped submit evidence 断言，避免污染 GH-845 no-order matrix guard；`productionTradingEnabledByDefault=false`，`productionSecretAutoRead=false`，`productionEndpointConnected=false`，`brokerEndpointConnected=false`，`productionOrderSubmitted=false`；不授权 production cutover、production order、cancel / replace 或 Dashboard command surface。

## TVM-RELEASE-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST

- TVM-RELEASE-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST
- GH-1067-VERIFY-V0150-TESTNET-CREDENTIAL-SIGNED-REQUEST
- V0150-002-CREDENTIAL-REFERENCE
- V0150-002-HMAC-SHA256-SIGNED-REQUEST
- V0150-002-BINANCE-SPOT-TESTNET-ONLY
- V0150-002-NO-PRODUCTION-SECRET-AUTO-READ
- V0150-002-PRODUCTION-ENDPOINT-BLOCKED
- V0150-002-REDACTED-EVIDENCE
- V0150-002-NO-NETWORK-ACTION
- GH-1067 Release v0.15.0 Testnet Credential / Signed Request Builder
- `bash checks/verify-v0.15.0-testnet-credential-signed-request.sh`
- `swift test --filter TargetGraphTests/testGH1067ReleaseV0150SpotTestnetSignedRequestBuilderIsRedactedAndDeterministic`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0150BinanceSpotTestnetSignedRequestBuilder.swift`、`docs/contracts/release-v0.15.0-testnet-credential-provider-signed-request-builder-contract.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-testnet-credential-signed-request.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1067 只允许 Spot Testnet signed request construction evidence。`activeVenue == Binance`，`v0150ExecutionProductScope == Binance Spot Testnet only`，`endpointHost == testnet.binance.vision`，`productionTradingEnabledByDefault=false`，`productionSecretAutoRead=false`，`productionEndpointConnected=false`，`brokerEndpointConnected=false`，`productionOrderSubmitted=false`；不授权 production cutover，不执行 network action。

## TVM-RELEASE-V0150-CONTRACT-PREFLIGHT

- TVM-RELEASE-V0150-CONTRACT-PREFLIGHT
- GH-1066-VERIFY-V0150-CONTRACT-PREFLIGHT
- V0150-001-RELEASE-CONTRACT
- V0150-001-V0141-PREFLIGHT-GATE
- V0150-001-BINANCE-SPOT-TESTNET-ONLY
- V0150-001-SIGNED-TESTNET-BOUNDARY
- V0150-001-PRODUCTION-FAIL-CLOSED
- V0150-001-CHILDREN-BACKLOG-NON-EXECUTABLE
- V0150-001-NO-PRODUCTION-CUTOVER
- V0150-001-NO-DASHBOARD-COMMAND-SURFACE
- GH-1066 Release v0.15.0 Contract / v0.14.1 Preflight Gate
- `bash checks/verify-v0.15.0-contract-preflight.sh`
- `swift test --filter TargetGraphTests/testGH1066ReleaseV0150ContractAndV0141PreflightGate`
- Evidence files: `docs/contracts/release-v0.15.0-real-binance-spot-testnet-execution-mvp-contract.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.15.0-contract-preflight.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1066 只允许 v0.15.0 从 local execution evidence chain 进入 Binance Spot Testnet signed execution planning。`activeVenue == Binance`，`v0150ExecutionProductScope == Binance Spot Testnet only`，`productionTradingEnabledByDefault=false`，`operatorConfirmationRequired=true`，`testnetEndpointAllowlistOnly=true`，`productionSecretRead=false`，`productionEndpointConnected=false`，`brokerEndpointConnected=false`，`dashboardCommandSurfaceEnabled=false`；不授权 production cutover，不提交 production order。

## TVM-RELEASE-V0141-PATCH-AUDIT-RELEASE-NOTES

- TVM-RELEASE-V0141-PATCH-AUDIT-RELEASE-NOTES
- GH-1064-VERIFY-V0141-PATCH-AUDIT-RELEASE-NOTES
- V0141-006-PATCH-AUDIT
- V0141-006-RELEASE-NOTES
- V0141-006-VALIDATION-SUMMARY
- V0141-006-LOCAL-EVIDENCE-WORDING
- V0141-006-NO-PRODUCTION-CUTOVER
- V0141-006-NO-TAG-OR-RELEASE-PUBLICATION
- GH-1064 Release v0.14.1 Patch Audit / Release Notes Closeout
- `bash checks/verify-v0.14.1-patch-audit-release-notes.sh`
- `swift test --filter TargetGraphTests/testGH1064ReleaseV0141PatchAuditReleaseNotesCloseout`
- Evidence files: `docs/audit/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-stage-code-audit.md`、`docs/release/mtpro-release-v0.14.1-local-execution-evidence-hardening-patch-notes.md`、`docs/release/release-publication-policy.md`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.14.1-patch-audit-release-notes.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1064 只固定 v0.14.1 patch audit / release notes closeout、local evidence wording 和 release publication separation。v0.14.1 是 local execution evidence chain / testnet evidence only，不是真实 signed Binance testnet execution release；不读取 production secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order，不授权 production cutover。GH-1064 PR 本身不创建 `v0.14.1` tag 或 GitHub Release。

## TVM-RELEASE-V0141-SUBMIT-EVIDENCE-NETWORK-GUARDS

- TVM-RELEASE-V0141-SUBMIT-EVIDENCE-NETWORK-GUARDS
- GH-1061-VERIFY-V0141-SUBMIT-EVIDENCE-NETWORK-GUARDS
- V0141-003-ADAPTER-SUBMIT-EVIDENCE-CREATED
- V0141-003-NETWORK-SUBMIT-ATTEMPTED-FALSE
- V0141-003-NETWORK-CANCEL-REPLACE-ATTEMPTED-FALSE
- V0141-003-EVIDENCE-ONLY-WORDING
- V0141-003-NO-PRODUCTION-CUTOVER
- GH-1061 Release v0.14.1 Submit Evidence Network Guards
- `bash checks/verify-v0.14.1-submit-evidence-network-guards.sh`
- `swift test --filter TargetGraphTests/testGH1037ReleaseV0140SignalToExecutionPipelineLinksAcceptedSignalAndFailsClosedRejectedSignal`
- `swift test --filter TargetGraphTests/testGH1039ReleaseV0140FailureSimulationSuiteCoversSixFailClosedModes`
- Evidence files: `Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140SignalToExecutionPipeline.swift`、`Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140FailureSimulationSuite.swift`、`Sources/ExecutionEngine/OMSFutureGate/ReleaseV0140FullE2ETestnetSuite.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`checks/run.sh`、`checks/verify-v0.14.1-submit-evidence-network-guards.sh`、`docs/contracts/release-v0.14.0-signal-to-execution-pipeline.md`、`docs/contracts/release-v0.14.0-failure-simulation-suite.md`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1061 只修正 v0.14.x local execution evidence wording / field semantics。`adapterSubmitEvidenceCreated` 只表示本地 adapter evidence 已创建，`networkSubmitAttempted` 与 `networkCancelReplaceAttempted` 必须保持 false；不读取 production secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0141-CODABLE-DECODE-VALIDATION

- TVM-RELEASE-V0141-CODABLE-DECODE-VALIDATION
- GH-1060-VERIFY-V0141-CODABLE-DECODE-VALIDATION
- V0141-002-CODABLE-DECODE-VALIDATION
- V0141-002-BOUNDARYHELD-COMPUTED
- V0141-002-CORRUPTED-JSON-FAILS-CLOSED
- V0141-002-NO-PRODUCTION-CUTOVER
- GH-1060 Release v0.14.1 Codable Decode Validation
- `bash checks/verify-v0.14.1-codable-decode-validation.sh`
- `swift test --filter TargetGraphTests/testGH1060ReleaseV0141CodableDecodeValidationRejectsCorruptedV0140Evidence`
- Evidence files: `Sources/Dashboard/Report/ReleaseV0140ReadOnlyExecutionDashboardSurface.swift`、`Sources/ExecutionClient/FutureGate/ReleaseV0140BinanceTestnetSubmitPath.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`checks/run.sh`、`checks/verify-v0.14.1-codable-decode-validation.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1060 只固定 v0.14.x local execution evidence / read-model decode validation。Dashboard `boundaryHeld` 不再信任外部字段注入，submit evidence decode 重新验证 network-submit / production-disabled facts，corrupted JSON 必须 fail closed；不读取 production secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0141-RELEASE-CI-DASHBOARD-EVIDENCE

- TVM-RELEASE-V0141-RELEASE-CI-DASHBOARD-EVIDENCE
- GH-1059-VERIFY-V0141-RELEASE-CI-DASHBOARD-EVIDENCE
- V0141-001-RELEASE-CI-DASHBOARD-EVIDENCE
- V0141-001-V0140-TAG-RELEASE-CHECKS
- V0141-001-DASHBOARD-MACOS-EVIDENCE
- V0141-001-NO-PRODUCTION-CUTOVER
- GH-1059 Release v0.14.1 Release CI / Dashboard Evidence Validation
- `bash checks/verify-v0.14.1-release-ci-dashboard-evidence.sh`
- `swift test --filter TargetGraphTests/testGH1059ReleaseV0141CIAndDashboardEvidenceAnchorsV0140ReleaseFacts`
- Evidence files: `docs/audit/inputs/mtpro-release-v0.14.1-release-ci-dashboard-evidence.md`、`.github/workflows/checks.yml`、`checks/run.sh`、`checks/verify-v0.14.1-release-ci-dashboard-evidence.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-1059 只固定 v0.14.x release evidence chain。v0.14.0 public Release、PR #1058、workflow run `27919195332`、tag push run `27919993831`、`linux-checks`、`dashboard-macos`、`checks` 和 `bash checks/run.sh` 是 evidence；该 evidence 不读取 production secret，不连接 production endpoint / broker endpoint，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0111-PATCH-AUDIT-RELEASE-NOTES

- TVM-RELEASE-V0111-PATCH-AUDIT-RELEASE-NOTES
- GH-951-VERIFY-V0111-PATCH-AUDIT-RELEASE-NOTES
- V0111-007-PATCH-AUDIT
- V0111-007-RELEASE-NOTES
- V0111-007-VALIDATION-SUMMARY
- V0111-007-AGGREGATE-VERIFY
- V0111-007-NO-PRODUCTION-CUTOVER
- V0111-007-NO-TAG-OR-RELEASE-MOVE
- GH-951 Release v0.11.1 Patch Audit / Release Notes Closeout Validation
- `bash checks/verify-v0.11.1.sh`
- `swift test --filter TargetGraphTests/testGH951ReleaseV0111PatchAuditReleaseNotesCloseout`
- Evidence files: `docs/audit/mtpro-release-v0.11.1-readiness-runtime-guard-patch-stage-code-audit.md`、`docs/release/mtpro-release-v0.11.1-readiness-runtime-guard-patch-notes.md`、`docs/validation/latest-verification-summary.md`、`docs/release/release-publication-policy.md`、`checks/verify-v0.11.1.sh`、`checks/automation-readiness.sh` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-951 只固定 v0.11.1 patch closeout evidence；#945..#950 已 closed / done，PR #966..#971 merged / checks SUCCESS。该 closeout 不创建 / 移动 / 重写 tag 或 GitHub Release，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover，也不推进 v0.12.0。

## TVM-RELEASE-V0111-PATCH-AGGREGATE-GUARD

- TVM-RELEASE-V0111-PATCH-AGGREGATE-GUARD
- GH-950-VERIFY-V0111-PATCH-AGGREGATE-GUARD
- V0111-006-PATCH-AGGREGATE-VERIFY
- V0111-006-RELEASE-FACT-SYNC
- V0111-006-DASHBOARD-MACOS-SHA256-STATE
- V0111-006-ARTIFACT-SYMLINK-PERMISSIONS
- V0111-006-NO-PRODUCTION-CUTOVER
- GH-950 Release v0.11.1 Patch Aggregate Guard Validation
- `bash checks/verify-v0.11.1.sh`
- `swift test --filter TargetGraphTests/testGH950ReleaseV0111PatchAggregateVerifierAnchors`
- Evidence files: `checks/verify-v0.11.1.sh`、`checks/run.sh`、`checks/automation-readiness.sh`、`checks/verify-v0.11.1-release-fact-sync.sh`、`checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh`、`checks/verify-v0.11.1-readiness-artifact-symlink-root.sh`、`checks/verify-v0.11.1-readiness-artifact-permissions.sh` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-950 只聚合 v0.11.1 readiness runtime guard patch 验证入口；release fact sync、Dashboard checksum / state、symlink confinement 和 owner-only permission hardening 均保持本地 evidence / read-model / filesystem guard 语义。该 guard 不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0111-READINESS-ARTIFACT-PERMISSIONS

- TVM-RELEASE-V0111-READINESS-ARTIFACT-PERMISSIONS
- GH-949-VERIFY-V0111-READINESS-ARTIFACT-PERMISSIONS
- V0111-005-OWNER-ONLY-DIRECTORIES
- V0111-005-OWNER-ONLY-FILES
- V0111-005-PERMISSION-REPAIR
- V0111-005-NO-PRODUCTION-CUTOVER
- GH-949 Release v0.11.1 Readiness Artifact Permission Validation
- `bash checks/verify-v0.11.1-readiness-artifact-permissions.sh`
- `swift test --filter TargetGraphTests/testGH949ProductionReadinessArtifactStoreEnforcesOwnerOnlyPermissions`
- `swift test --filter TargetGraphTests/testGH949ReadinessArtifactPermissionGuardAnchors`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`checks/verify-v0.11.1-readiness-artifact-permissions.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-949 只固定本地 readiness artifact directory / file permission guard；approved root 到 artifact parent directories 必须 owner-only `0700`，artifact file 必须 owner-only `0600`。该 guard 不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0111-READINESS-ARTIFACT-SYMLINK-ROOT

- TVM-RELEASE-V0111-READINESS-ARTIFACT-SYMLINK-ROOT
- GH-948-VERIFY-V0111-READINESS-ARTIFACT-SYMLINK-ROOT
- V0111-004-CANONICAL-EVIDENCE-ROOT
- V0111-004-NO-SYMLINK-PATH-COMPONENTS
- V0111-004-RESOLVED-TARGET-STAYS-IN-ROOT
- V0111-004-NO-PRODUCTION-CUTOVER
- GH-948 Release v0.11.1 Readiness Artifact Symlink Root Validation
- `bash checks/verify-v0.11.1-readiness-artifact-symlink-root.sh`
- `swift test --filter TargetGraphTests/testGH948ProductionReadinessArtifactStoreRejectsSymlinkEscapes`
- `swift test --filter TargetGraphTests/testGH948ReadinessArtifactSymlinkRootGuardAnchors`
- Evidence files: `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`checks/verify-v0.11.1-readiness-artifact-symlink-root.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-948 只固定本地 readiness artifact root / path symlink escape guard；approved root、path component 和 artifact target 都不能通过 symlink 逃逸，resolved target 必须留在 canonical root 内。该 guard 不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0111-DASHBOARD-SHA256-STATE-INVARIANTS

- TVM-RELEASE-V0111-DASHBOARD-SHA256-STATE-INVARIANTS
- GH-947-VERIFY-V0111-DASHBOARD-SHA256-STATE-INVARIANTS
- V0111-003-DASHBOARD-SHA256-STATE-INVARIANTS
- V0111-003-STRICT-SHA256-LOWERCASE-HEX
- V0111-003-VALID-STALE-INVALID-CHECKSUM-MAPPING
- V0111-003-MISSING-BLOCKED-CHECKSUM-MISMATCH-FAIL-CLOSED
- V0111-003-NO-PRODUCTION-CUTOVER
- GH-947 Release v0.11.1 Dashboard SHA-256 State Invariant Validation
- `bash checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh`
- `swift test --filter AppTests/testGH947DashboardReadinessArtifactStateInvariantsRequireStrictSHA256AndExplicitStateMapping`
- `swift test --filter TargetGraphTests/testGH947DashboardSHA256AndReadinessStateInvariantsAreGuarded`
- Evidence files: `Sources/Dashboard/Report/ReleaseV0100DashboardProductionReadinessCenter.swift`、`Tests/AppTests/AppTests.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift`、`checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh`、`docs/automation/automation-readiness.md` 和 `docs/validation/validation-plan.md`。
- Boundary: GH-947 只固定 Dashboard 本地 readiness artifact SHA-256 reference 与 state invariant；`valid`、`stale`、`invalid` 必须有 evidence 且 checksum matches，`checksum-mismatch` 必须有 evidence 且 checksum 不匹配，`missing`、`blocked`、`not-evaluated` 必须 fail closed 且不声明 evidence。该 guard 不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0111-DASHBOARD-MACOS-V0110-GUARDS

- TVM-RELEASE-V0111-DASHBOARD-MACOS-V0110-GUARDS
- GH-946-VERIFY-V0111-DASHBOARD-MACOS-V0110-GUARDS
- V0111-002-DASHBOARD-MACOS-V0110-GUARDS
- V0111-002-READINESS-ARTIFACT-STATE-SURFACE
- V0111-002-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
- V0111-002-NO-PRODUCTION-CUTOVER
- GH-946 Release v0.11.1 Dashboard macOS v0.11 Focused Guard Validation
- `bash checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh`
- `swift test --filter AppTests/testGH919DashboardProductionReadinessCenterBindsRealLocalArtifactStatesReadOnly`
- `swift test --filter TargetGraphTests/testGH919DashboardProductionReadinessCenterBindsRealArtifactStateAnchors`
- workflow evidence: required `dashboard-macos` job runs `checks/verify-v0.11.1-dashboard-macos-v0110-guards.sh` after v0.10 Dashboard guard and before Dashboard build / smoke.
- Boundary: v0.11.1 Dashboard macOS v0.11 guard 只固定 Dashboard readiness artifact state surface 和 required workflow 顺序；不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0111-RELEASE-FACT-SYNC-GUARD

- TVM-RELEASE-V0111-RELEASE-FACT-SYNC-GUARD
- GH-945-VERIFY-V0111-RELEASE-FACT-STALE-WORDING-GUARD
- V0111-001-RELEASE-FACT-SYNC-GUARD
- V0111-001-FOUR-GATE-RELEASE-FLOW
- GH-945 Release v0.11.1 Release Fact Sync / Stale Wording Guard Validation
- `bash checks/verify-v0.11.1-release-fact-sync.sh`
- `swift test --filter TargetGraphTests/testGH945ReleaseFactSyncGuardRejectsV0110StalePublicationWording`
- Evidence docs: `docs/release/release-publication-policy.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md`、`docs/validation/validation-plan.md`、`docs/audit/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-stage-code-audit.md` 和 `docs/release/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-notes.md`。
- Boundary: GH-945 只固定 v0.11.0 publication fact sync / stale wording guard；v0.11.0 已通过独立 Release Publication Gate 发布 public GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`；tag peeled commit `13f592d0710de91351286e5c5490bfacb63c19b0`；publication timestamp `2026-06-19T01:20:58Z`。该 guard 不移动 tag、不重写 release、不读取 production secret、不连接 production endpoint / broker、不提交 testnet 或 production order、不授权 production cutover。

## TVM-RELEASE-V0110-FINAL-AUDIT-RELEASE-DOCS

- TVM-RELEASE-V0110-FINAL-AUDIT-RELEASE-DOCS
- GH-924-VERIFY-V0110-FINAL-AUDIT-RELEASE-DOCS
- V0110-012-STAGE-CODE-AUDIT
- V0110-012-RELEASE-NOTES
- V0110-012-VALIDATION-SUMMARY
- V0110-012-AGGREGATE-VERIFY
- V0110-012-ROOT-DOCS-REFRESH
- V0110-012-NO-PRODUCTION-CUTOVER
- V0110-012-NO-PUBLIC-RELEASE-PUBLICATION
- GH-924 Release v0.11.0 Final Audit / Release Docs Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH924ReleaseV0110FinalAuditReleaseDocsCloseout`
- Evidence docs: `docs/audit/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-stage-code-audit.md`、`docs/release/mtpro-release-v0.11.0-production-readiness-evidence-runtime-integrity-hardening-notes.md`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md`、`docs/validation/validation-plan.md` 和 `checks/verify-v0.11.0.sh`。
- Boundary: GH-924 只收口 v0.11.0 validation suite、Stage Code Audit、release notes、root docs refresh 和 aggregate verifier guard；GH-924 本身不创建 `v0.11.0` tag / GitHub Release。后续独立 Release Publication Gate 已发布 `v0.11.0` public GitHub Release：`https://github.com/atxinbao/MTPRO/releases/tag/v0.11.0`；该 publication 不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS

- TVM-RELEASE-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS
- GH-923-VERIFY-V0110-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS
- V0110-011-AUDITABLE-APPROVAL-WORKFLOW-TRANSITIONS
- V0110-011-REQUEST-REVIEW-APPROVE-REVOKE-EXPIRE
- V0110-011-QUORUM-EXPIRY-REVOCATION-FAIL-CLOSED
- V0110-011-LOCAL-APPROVAL-EVIDENCE-ARTIFACT
- V0110-011-NO-PRODUCTION-CUTOVER-ORDER
- GH-923 Release v0.11.0 Auditable Approval Workflow Transitions Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH923AuditableApprovalWorkflowTransitionsFailClosedAndExportLocalEvidence`
- Approval workflow evidence: `ReleaseV0110AuditableApprovalWorkflowStateModel`、`ReleaseV0110ApprovalWorkflowTransition`、`requestedBy`、`reviewedBy`、`approvedBy`、`quorumRequired`、`expiresAt`、`revokedReason` 和 `approval_workflow_transitions.json`。
- Boundary: v0.11.0 approval workflow transition model 只强化本地 readiness evidence；missing quorum、expired、revoked 或 incomplete review state 必须 fail closed；approved evidence 仍不授权 production cutover，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order。

## TVM-RELEASE-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL

- TVM-RELEASE-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL
- GH-922-VERIFY-V0110-KILL-SWITCH-NO-TRADE-STATE-MODEL
- V0110-010-KILL-SWITCH-NO-TRADE-STATE-MODEL
- V0110-010-UNKNOWN-STALE-UNAVAILABLE-FAIL-CLOSED
- V0110-010-INACTIVE-FRESH-REVIEWED-APPROVAL-REQUEST-ELIGIBILITY
- V0110-010-NO-PRODUCTION-CUTOVER-ORDER
- GH-922 Release v0.11.0 Kill Switch / No-trade State Model Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH922KillSwitchNoTradeStateModelFailsClosedAndOnlyAllowsApprovalRequestEligibility`
- Kill switch / no-trade state model evidence: `ReleaseV0110KillSwitchNoTradeReadinessStateModel`、`ReleaseV0110KillSwitchNoTradeEvidenceFreshnessState`、`ReleaseV0110KillSwitchNoTradeReviewState`、`eligibleForApprovalRequest`、`case inactive`、`case unknown`、`case stale`、`case unavailable`、`productionCutoverBlocked` 和 `orderSubmissionEnabled`。
- Boundary: v0.11.0 kill switch / no-trade state model 只强化本地 readiness evidence 的 fail-closed 状态分类；active、unknown、stale、unavailable 或未 reviewed 状态必须 fail closed；只有 inactive + fresh + reviewed 可进入 approval-request eligibility；不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0110-FIXED-POINT-CAPITAL-EXPOSURE-POLICY

- TVM-RELEASE-V0110-FIXED-POINT-CAPITAL-EXPOSURE-POLICY
- GH-921-VERIFY-V0110-FIXED-POINT-CAPITAL-EXPOSURE-POLICY
- V0110-009-FIXED-POINT-CAPITAL-EXPOSURE-POLICY
- V0110-009-POLICY-UNITS-SCALE
- V0110-009-NUMERIC-RELATIONSHIP-VALIDATION
- V0110-009-POLICY-HASH-INPUTS
- V0110-009-NO-PRODUCTION-CUTOVER-ORDER
- GH-921 Release v0.11.0 Fixed-point Capital / Exposure Policy Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH921CapitalExposureReadinessUsesFixedPointPolicyValuesAndSafeComparisons`
- fixed capital / exposure policy evidence: `ReleaseV0110FixedPointPolicyValue`、`minorUnits`、`scale`、`unit`、`fixedPointPolicyHeld`、`numericRelationshipHeld` 和 `policyHashInputs`。
- Boundary: v0.11.0 fixed-point policy 只强化本地 readiness evidence 的金额、敞口和杠杆比较；invalid unit、scale、numeric relationship 或 policy hash inputs 必须 fail closed；不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0110-READINESS-CLI-LOCAL-ARTIFACTS

- TVM-RELEASE-V0110-READINESS-CLI-LOCAL-ARTIFACTS
- GH-920-VERIFY-V0110-READINESS-CLI-LOCAL-ARTIFACTS
- V0110-008-READINESS-CLI-LOCAL-ARTIFACTS
- V0110-008-BUILD-STATUS-VALIDATE-EXPORT-APPROVAL-STATUS
- V0110-008-LOCAL-ARTIFACT-STORE-BUNDLE-VALIDATION
- V0110-008-MISSING-INVALID-STALE-CHECKSUM-MISMATCH
- V0110-008-NO-PRODUCTION-SECRET-ENDPOINT-ORDER
- GH-920 Release v0.11.0 Readiness CLI Local Artifact Commands Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH920ReadinessCLIOperatesOnLocalArtifactsWithoutProductionCapabilities`
- `mtpro readiness build/status/validate/export/approval-status` 只读写本地 readiness JSON artifacts、manifest 和 bundle validation；`valid` 只表示 local artifact integrity pass。
- Boundary: 不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover；`MTPROCLI -> ExecutionClient` 只允许访问本地 `ProductionReadinessArtifactStore` API。

## TVM-RELEASE-V0110-DASHBOARD-REAL-ARTIFACT-STATE

- TVM-RELEASE-V0110-DASHBOARD-REAL-ARTIFACT-STATE
- GH-919-VERIFY-V0110-DASHBOARD-REAL-ARTIFACT-STATE
- V0110-007-DASHBOARD-REAL-ARTIFACT-STATE
- V0110-007-LOCAL-MANIFEST-BUNDLE-STATE
- V0110-007-MISSING-CORRUPT-STALE-CHECKSUM-MISMATCH
- V0110-007-NO-STATIC-EVIDENCE-EXISTS
- V0110-007-READ-ONLY-NO-PRODUCTION-CUTOVER
- GH-919 Release v0.11.0 Dashboard Real Artifact State Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter AppTests/testGH919DashboardProductionReadinessCenterBindsRealLocalArtifactStatesReadOnly`
- `swift test --filter TargetGraphTests/testGH919DashboardProductionReadinessCenterBindsRealArtifactStateAnchors`
- fixed Dashboard real artifact state evidence: `Sources/Dashboard/Report/ReleaseV0100DashboardProductionReadinessCenter.swift`、`Tests/AppTests/AppTests.swift`、`Tests/TargetGraphTests/TargetGraphTests.swift` 和 `checks/verify-v0.11.0.sh`。
- Boundary: v0.11.0 Dashboard real artifact state 只把本地 manifest / bundle validation JSON 映射为 read-model-only cards；missing / corrupt / stale / checksum mismatch 都必须显式展示；不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0110-SHADOW-DRY-RUN-PARITY-RUNNER

- TVM-RELEASE-V0110-SHADOW-DRY-RUN-PARITY-RUNNER
- GH-918-VERIFY-V0110-SHADOW-DRY-RUN-PARITY-RUNNER
- V0110-006-SHADOW-DRY-RUN-PARITY-RUNNER
- V0110-006-LOCAL-RUN-EVIDENCE
- V0110-006-SHADOW-PARITY-ARTIFACT
- V0110-006-MISSING-INCOMPLETE-BLOCKED
- V0110-006-NO-PRODUCTION-ENDPOINT-SECRET-ORDER
- GH-918 Release v0.11.0 Shadow Dry-run Parity Runner Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH918ShadowDryRunParityRunnerBuildsArtifactFromLocalRunEvidence`
- fixed shadow parity runner evidence: `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`、`docs/contracts/release-v0.11.0-production-readiness-evidence-runtime-contract.md`、`checks/verify-v0.11.0.sh` 和 TargetGraph focused test。
- Boundary: v0.11.0 shadow dry-run parity runner 只读取本地 run evidence，生成 `shadow_dry_run_parity.json` 和 manifest；missing evidence 输出 `blocked`，incomplete evidence 输出 `invalid`；不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0110-READINESS-BUNDLE-VALIDATION

- TVM-RELEASE-V0110-READINESS-BUNDLE-VALIDATION
- GH-917-VERIFY-V0110-READINESS-BUNDLE-VALIDATION
- V0110-005-READINESS-BUNDLE-VALIDATION
- V0110-005-REQUIRED-ARTIFACT-SET
- V0110-005-BUNDLE-VALIDATION-STATES
- V0110-005-POLICY-VERSION-BLOCKED
- V0110-005-CHECKSUM-MISMATCH-STATE
- V0110-005-NO-PRODUCTION-CUTOVER
- GH-917 Release v0.11.0 Readiness Bundle Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH917ReadinessBundleValidationClassifiesRequiredArtifactsPolicyAndChecksum`
- fixed bundle validation evidence: `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`、`docs/contracts/release-v0.11.0-production-readiness-evidence-runtime-contract.md`、`checks/verify-v0.11.0.sh` 和 TargetGraph focused test。
- Boundary: v0.11.0 readiness bundle validation 只读取本地 manifest 和本地 artifacts，输出 `not-evaluated`、`valid`、`blocked`、`stale`、`missing`、`invalid`、`checksum-mismatch`；不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0110-CANONICAL-JSON-SHA256-CHECKSUM

- TVM-RELEASE-V0110-CANONICAL-JSON-SHA256-CHECKSUM
- GH-916-VERIFY-V0110-CANONICAL-JSON-SHA256-CHECKSUM
- V0110-004-CANONICAL-JSON-SHA256
- V0110-004-CHECKSUM-FORMAT-VALIDATION
- V0110-004-CHECKSUM-MISMATCH-FAILS-CLOSED
- V0110-004-NO-PLACEHOLDER-CHECKSUMS
- GH-916 Release v0.11.0 Canonical JSON SHA256 Checksum Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH916CanonicalJSONSHA256RejectsPlaceholderAndMismatchChecksums`
- fixed checksum evidence: `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`、`Package.swift`、`docs/contracts/release-v0.11.0-production-readiness-evidence-runtime-contract.md`、`checks/verify-v0.11.0.sh` 和 TargetGraph focused test。
- Boundary: v0.11.0 checksum policy 只计算本地 canonical JSON SHA256，格式固定为 `sha256:<64 hex>`；placeholder checksum 和 checksum mismatch 必须 fail closed；不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0110-READINESS-MANIFEST-ATOMIC-IO

- TVM-RELEASE-V0110-READINESS-MANIFEST-ATOMIC-IO
- GH-915-VERIFY-V0110-READINESS-MANIFEST-ATOMIC-IO
- V0110-003-READINESS-MANIFEST-SCHEMA
- V0110-003-ATOMIC-JSON-ARTIFACT-IO
- V0110-003-MANIFEST-POLICY-VERSION
- V0110-003-MANIFEST-ENTRY-STATE-VALIDATION
- V0110-003-EVIDENCE-EXISTS-IS-NOT-SUFFICIENT
- GH-915 Release v0.11.0 Readiness Manifest Atomic IO Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH915ReadinessManifestSchemaAndAtomicIORequireRealArtifacts`
- fixed manifest evidence: `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`、`docs/contracts/release-v0.11.0-production-readiness-evidence-runtime-contract.md`、`checks/verify-v0.11.0.sh` 和 TargetGraph focused test。
- Boundary: v0.11.0 manifest 只校验本地 readiness artifact schema、policyVersion、state、size 和 checksum 重新计算；`evidenceExists` 不能单独证明 artifact valid；最终 checksum policy 已由 GH-916 固定为 canonical JSON SHA256；不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0110-PRODUCTION-READINESS-ARTIFACT-STORE

- TVM-RELEASE-V0110-PRODUCTION-READINESS-ARTIFACT-STORE
- GH-914-VERIFY-V0110-PRODUCTION-READINESS-ARTIFACT-STORE
- V0110-002-PRODUCTION-READINESS-ARTIFACT-STORE
- V0110-002-LOCAL-EVIDENCE-ROOT
- V0110-002-ARTIFACT-STATES
- V0110-002-READ-WRITE-PRIMITIVES
- V0110-002-NO-PRODUCTION-SECRET-ENDPOINT-ORDER
- GH-914 Release v0.11.0 Production Readiness Artifact Store Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH914ProductionReadinessArtifactStoreUsesLocalExplicitStates`
- fixed artifact store evidence: `Sources/ExecutionClient/FutureGate/ReleaseV0110ProductionReadinessArtifactStore.swift`、`docs/contracts/release-v0.11.0-production-readiness-evidence-runtime-contract.md`、`checks/verify-v0.11.0.sh` 和 TargetGraph focused test。
- Boundary: v0.11.0 artifact store 只读写 approved local evidence root 下的 local JSON / text evidence，显式输出 missing / invalid / stale / valid 状态；不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT

- TVM-RELEASE-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT
- GH-913-VERIFY-V0110-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT
- V0110-001-PRODUCTION-READINESS-EVIDENCE-RUNTIME-CONTRACT
- V0110-001-LOCAL-READINESS-ARTIFACT-RUNTIME
- V0110-001-READINESS-ARTIFACT-LIFECYCLE
- V0110-001-RUNTIME-STATES
- V0110-001-MANIFEST-CHECKSUM-RULES
- V0110-001-ALLOWED-LOCAL-COMMANDS
- V0110-001-FORBIDDEN-PRODUCTION-CAPABILITIES
- V0110-001-DASHBOARD-CLI-POLICY-KILL-SWITCH-APPROVAL-SHADOW-PARITY-BOUNDARIES
- V0110-001-DOWNSTREAM-QUEUE-ORDER
- V0110-001-RELEASE-VALIDATION-MATRIX
- GH-913 Release v0.11.0 Production Readiness Evidence Runtime Contract Validation
- `bash checks/verify-v0.11.0.sh`
- `swift test --filter TargetGraphTests/testGH913ReleaseV0110ProductionReadinessEvidenceRuntimeContract`
- fixed contract evidence: `docs/contracts/release-v0.11.0-production-readiness-evidence-runtime-contract.md`、`checks/verify-v0.11.0.sh`、`docs/validation/latest-verification-summary.md`、`docs/automation/automation-readiness.md`、`docs/validation/validation-plan.md` 和 TargetGraph focused test。
- Boundary: v0.11.0 contract 只定义 local readiness evidence runtime、artifact store、manifest、canonical JSON SHA256、Dashboard read-model、readonly readiness CLI、policy、kill switch / no-trade、approval workflow 和 shadow parity boundaries；不实现 runtime artifact writing in GH-913，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不实现 production OMS、trading button、order form 或 live command，不授权 production cutover。

## TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK

- TVM-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK
- GH-891-VERIFY-V0100-FINAL-AUDIT-DOCS-RUNBOOK
- GH-891-RELEASE-V0100-FINAL-AUDIT-DOCS-RUNBOOK
- V0100-014-VALIDATION-SUMMARY
- V0100-014-STAGE-CODE-AUDIT
- V0100-014-RELEASE-NOTES
- V0100-014-OPERATOR-RUNBOOK
- V0100-014-ROOT-DOCS-REFRESH
- V0100-014-AGGREGATE-VERIFY
- V0100-014-NO-PRODUCTION-CUTOVER
- GH-891 Release v0.10.0 Final Audit / Docs / Runbook Validation
- `bash checks/verify-v0.10.0.sh`
- fixed release evidence: `docs/audit/mtpro-release-v0.10.0-production-cutover-readiness-gate-stage-code-audit.md`、`docs/release/mtpro-release-v0.10.0-production-cutover-readiness-gate-notes.md`、`docs/operators/release-v0.10.0-production-cutover-readiness-gate-runbook.md`、Project Closure Count `44 / 44 (100%)` 和 aggregate verifier。
- Boundary: v0.10.0 final closeout 只证明 production cutover readiness assessment、reference-only production profile、secret readiness、endpoint policy、capital / exposure limits、kill switch / no-trade、disabled command surface、shadow dry-run parity、readiness bundle、approval workflow、incident / rollback runbook 和 Dashboard readiness center 已闭环；不读取 production secret，不连接 production endpoint / broker，不显示 trading button / order form / live command，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0101-PATCH-AUDIT-RELEASE-NOTES

- TVM-RELEASE-V0101-PATCH-AUDIT-RELEASE-NOTES
- GH-912-VERIFY-V0101-PATCH-AUDIT-RELEASE-NOTES
- V0101-007-PATCH-AUDIT
- V0101-007-RELEASE-NOTES
- V0101-007-VALIDATION-SUMMARY
- V0101-007-AGGREGATE-VERIFY
- V0101-007-NO-PRODUCTION-CUTOVER
- V0101-007-V0110-RUNTIME-OWNERSHIP
- GH-912 Release v0.10.1 Patch Audit / Release Notes Validation
- `bash checks/verify-v0.10.1.sh`
- `swift test --filter TargetGraphTests/testGH912ReleaseV0101PatchAuditReleaseNotesCloseout`
- fixed patch evidence: `docs/audit/mtpro-release-v0.10.1-production-readiness-audit-hardening-patch-stage-code-audit.md`、`docs/release/mtpro-release-v0.10.1-production-readiness-audit-hardening-patch-notes.md`、`checks/verify-v0.10.1.sh` 和 latest summary closeout。
- Boundary: v0.10.1 patch closeout 只证明 release fact sync、Dashboard macOS v0.10 guard、CLI verify wording、readiness CLI placeholder 和 v0.10.0 release body refresh 已闭环；不实现 readiness artifact runtime、不读取 production secret、不连接 production endpoint / broker、不提交 testnet 或 production order、不授权 production cutover。v0.11.0 owns real readiness artifact runtime + integrity hardening。

## TVM-RELEASE-V0101-READINESS-CLI-HELP

- TVM-RELEASE-V0101-READINESS-CLI-HELP
- GH-910-VERIFY-V0101-READINESS-CLI-HELP
- V0101-005-READINESS-CLI-HELP-PLACEHOLDER
- V0101-005-BUILD-STATUS-VALIDATE-EXPORT-APPROVAL-STATUS
- V0101-005-NON-MUTATING-NO-ARTIFACT-WRITE
- V0101-005-NO-PRODUCTION-CUTOVER
- V0101-005-NO-PRODUCTION-SECRET-ENDPOINT-ORDER
- V0101-005-NO-READINESS-ARTIFACT-RUNTIME
- GH-910 Release v0.10.1 Readiness CLI Help Placeholder Retirement Validation
- `bash checks/verify-v0.10.1-readiness-cli-help.sh`
- `swift test --filter TargetGraphTests/testGH910ReadinessCLIHelpPlaceholderIsNonMutatingAndFailsClosed`
- v0.10.1 `mtpro readiness help/build/status/validate/export/approval-status` placeholder 合同已由 GH-920 退休；当前 guard 固定 `readinessPlaceholderContract=retired-by-v0.11.0`，并确认本地 readiness artifact runtime 仍不授权 production cutover。
- Boundary: Readiness CLI local artifact runtime 不读取 production secret、不连接 production endpoint / broker、不提交 testnet 或 production order、不授权 production cutover。

## TVM-RELEASE-V0101-CLI-V0100-WORDING

- TVM-RELEASE-V0101-CLI-V0100-WORDING
- GH-909-VERIFY-V0101-CLI-V0100-WORDING
- V0101-004-CLI-V0100-READINESS-CONTRACT-WORDING
- V0101-004-REFERENCE-EVIDENCE-MODEL
- V0101-004-NOT-OPERATIONAL-PRODUCTION-READINESS
- V0101-004-NO-PRODUCTION-CUTOVER
- V0101-004-NO-ENDPOINT-READINESS-CLAIM
- V0101-004-NO-LIVE-ORDER-AUTHORIZATION
- GH-909 Release v0.10.1 CLI verify v0.10.0 Wording Validation
- `bash checks/verify-v0.10.1-cli-verify-v0100-wording.sh`
- `swift test --filter TargetGraphTests/testGH909CLIVerifyV0100WordingUsesReadinessContractReferenceEvidence`
- `mtpro verify` 输出 v0.10.0 readiness contract / reference evidence model，并固定 `operationalProductionReadiness=false`、`productionCutoverReadinessClaim=false`、`productionEndpointReadinessClaim=false` 和 `liveOrderAuthorization=false`。
- Boundary: CLI wording 不授权 production cutover、不读取 production secret、不连接 production endpoint / broker、不提交 testnet 或 production order、不提供 live order authorization。

## TVM-RELEASE-V0101-DASHBOARD-MACOS-V0100-GUARDS

- TVM-RELEASE-V0101-DASHBOARD-MACOS-V0100-GUARDS
- GH-908-VERIFY-V0101-DASHBOARD-MACOS-V0100-GUARDS
- V0101-003-DASHBOARD-MACOS-V0100-GUARDS
- V0101-003-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
- V0101-003-NO-PRODUCTION-CUTOVER
- GH-908 Release v0.10.1 Dashboard macOS v0.10 Focused Guard Validation
- `bash checks/verify-v0.10.1-dashboard-macos-v0100-guards.sh`
- `swift test --filter TargetGraphTests/testGH908DashboardMacOSV0100GuardRunsReadinessCenterBeforeBuildAndSmoke`
- required `dashboard-macos` job runs v0.10 Production Readiness Center focused guard before Dashboard build / smoke.
- Boundary: guard 只证明 Dashboard Production Readiness Center remains read-model-only / readiness-only；不显示 trading button / order form / live command，不生成 submit / cancel / replace command，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover。

## TVM-RELEASE-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER

- TVM-RELEASE-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER
- GH-890-VERIFY-V0100-DASHBOARD-PRODUCTION-READINESS-CENTER
- V0100-013-DASHBOARD-PRODUCTION-READINESS-CENTER
- V0100-013-READINESS-OVERVIEW
- V0100-013-ENVIRONMENT-PROFILE
- V0100-013-SECRET-READINESS
- V0100-013-ENDPOINT-POLICY
- V0100-013-RISK-CAPITAL-LIMITS
- V0100-013-KILL-SWITCH-NO-TRADE
- V0100-013-COMMAND-SURFACE-DISABLED
- V0100-013-SHADOW-DRY-RUN-PARITY
- V0100-013-APPROVAL-WORKFLOW
- V0100-013-READINESS-BUNDLE
- V0100-013-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
- V0100-013-NO-SUBMIT-CANCEL-REPLACE
- V0100-013-NO-PRODUCTION-CUTOVER
- GH-890 Release v0.10.0 Dashboard Production Readiness Center Validation
- `bash checks/verify-v0.10.0-dashboard-production-readiness-center.sh`
- `swift test --filter AppTests/testGH890DashboardProductionReadinessCenterShowsReadinessWithoutCommands`
- `swift test --filter TargetGraphTests/testGH890DashboardProductionReadinessCenterIsAnchoredInV0100Guards`
- fixed Dashboard readiness center surface: `ReleaseV0100DashboardProductionReadinessCenterViewModel`、`production-readiness-bundle.json`、`incident_rollback_readiness.json`、readiness overview、environment profile、secret readiness、endpoint policy、risk / capital limits、kill switch / no-trade、command surface disabled、shadow dry-run parity、approval workflow 和 readiness bundle。
- Boundary: Dashboard center 只读展示 production readiness evidence，不读取 production secret，不连接 production endpoint / broker，不显示 trading button / order form / live command，不提交 testnet 或 production order，不生成 submit / cancel / replace command，不授权 production cutover。

## TVM-RELEASE-V0100-INCIDENT-ROLLBACK-RUNBOOK

- TVM-RELEASE-V0100-INCIDENT-ROLLBACK-RUNBOOK
- GH-889-VERIFY-V0100-INCIDENT-ROLLBACK-RUNBOOK
- V0100-012-INCIDENT-ROLLBACK-READINESS-RUNBOOK
- V0100-012-PRODUCTION-READINESS-RUNBOOK-MD
- V0100-012-INCIDENT-ROLLBACK-READINESS-JSON
- V0100-012-INCIDENT-CLASSIFICATION
- V0100-012-STOP-PROCEDURE
- V0100-012-ROLLBACK-PROCEDURE
- V0100-012-OPERATOR-CHAIN
- V0100-012-EVIDENCE-EXPORT
- V0100-012-POST-INCIDENT-AUDIT
- V0100-012-KILL-SWITCH-CHECKLIST
- V0100-012-NO-TRADE-CHECKLIST
- V0100-012-PRODUCTION-CAPABILITIES-DISABLED
- GH-889 Release v0.10.0 Incident / Rollback Readiness Runbook Validation
- `bash checks/verify-v0.10.0-incident-rollback-runbook.sh`
- `swift test --filter TargetGraphTests/testGH889IncidentRollbackReadinessRunbookKeepsProductionCutoverDisabled`
- fixed incident / rollback schema: `docs/operators/release-v0.10.0-production-readiness-runbook.md`、`incident_rollback_readiness.json`、incident classification、stop procedure、rollback procedure、operator chain、evidence export、post-incident audit、kill switch checklist、no-trade checklist、`productionCutoverAuthorized=false`、`orderSubmissionEnabled=false`、`productionTradingEnabled=false`、`production_cutover_blocked=true`。
- Boundary: incident / rollback readiness evidence 只记录人工操作路径，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不生成 order payload，不授权 production cutover、production OMS、trading button、order form 或 live command。

## TVM-RELEASE-V0100-CUTOVER-APPROVAL-WORKFLOW

- TVM-RELEASE-V0100-CUTOVER-APPROVAL-WORKFLOW
- GH-888-VERIFY-V0100-CUTOVER-APPROVAL-WORKFLOW
- V0100-011-CUTOVER-APPROVAL-WORKFLOW
- V0100-011-CUTOVER-APPROVAL-WORKFLOW-JSON
- V0100-011-APPROVAL-STATES-REPRESENTED
- V0100-011-APPROVED-NOT-CUTOVER-AUTHORIZED
- V0100-011-APPROVED-NOT-ORDER-SUBMISSION-ENABLED
- V0100-011-APPROVED-NOT-PRODUCTION-TRADING-ENABLED
- V0100-011-PRODUCTION-CUTOVER-AUTHORIZED-FALSE
- V0100-011-ORDER-SUBMISSION-ENABLED-FALSE
- V0100-011-PRODUCTION-TRADING-ENABLED-FALSE
- V0100-011-PRODUCTION-CAPABILITIES-DISABLED
- GH-888 Release v0.10.0 Cutover Approval Workflow Validation
- `bash checks/verify-v0.10.0-cutover-approval-workflow.sh`
- `swift test --filter TargetGraphTests/testGH888CutoverApprovalWorkflowRepresentsApprovalWithoutTradingPermission`
- fixed approval workflow schema: `cutover_approval_workflow.json`、requested / reviewing / approved / rejected / expired / revoked、`approvedStateIsReviewEvidenceOnly=true`、`productionCutoverAuthorized=false`、`orderSubmissionEnabled=false`、`productionTradingEnabled=false`、`production_cutover_blocked=true`。
- Boundary: approval workflow evidence 只记录 review 状态，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不生成 order payload，不授权 production cutover、production OMS、trading button、order form 或 live command。

## TVM-RELEASE-V0100-PRODUCTION-READINESS-BUNDLE

- TVM-RELEASE-V0100-PRODUCTION-READINESS-BUNDLE
- GH-887-VERIFY-V0100-PRODUCTION-READINESS-BUNDLE
- V0100-010-PRODUCTION-READINESS-AUDIT-BUNDLE
- V0100-010-PRODUCTION-READINESS-BUNDLE-JSON
- V0100-010-BUNDLE-SHA256-CHECKSUM
- V0100-010-ENVIRONMENT-SECRET-ENDPOINT-EVIDENCE
- V0100-010-CAPITAL-KILL-SWITCH-NO-TRADE-EVIDENCE
- V0100-010-COMMAND-SURFACE-SHADOW-DRY-RUN-EVIDENCE
- V0100-010-RISK-POLICY-SNAPSHOT
- V0100-010-PORTFOLIO-RECONCILIATION-SNAPSHOT
- V0100-010-REDACTION-PROOF-TRUE
- V0100-010-NO-SECRET-VALUE-TRUE
- V0100-010-NO-ORDER-PAYLOAD-TRUE
- V0100-010-PRODUCTION-CAPABILITIES-DISABLED
- GH-887 Release v0.10.0 Production Readiness Audit Bundle Validation
- `bash checks/verify-v0.10.0-production-readiness-bundle.sh`
- `swift test --filter TargetGraphTests/testGH887ProductionReadinessAuditBundleAggregatesRedactedNoOrderEvidence`
- fixed bundle schema: `production_readiness_bundle.json`、sha256 checksum、environment / secret / endpoint / capital / kill switch / no-trade / command surface / shadow dry-run / risk policy / portfolio reconciliation entries、`redaction_proof=true`、`no_secret_value=true`、`no_order_payload=true`、`production_cutover_blocked=true`。
- Boundary: bundle evidence 不包含 broker / account response，不来自 endpoint connection，不包含 order payload，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover、production OMS、trading button、order form 或 live command。

## TVM-RELEASE-V0100-SHADOW-DRY-RUN-PARITY

- TVM-RELEASE-V0100-SHADOW-DRY-RUN-PARITY
- GH-886-VERIFY-V0100-SHADOW-DRY-RUN-PARITY
- V0100-009-SHADOW-DRY-RUN-PARITY-ASSESSMENT
- V0100-009-SHADOW-DRY-RUN-PARITY-JSON
- V0100-009-MARKET-READONLY-OBSERVATION
- V0100-009-STRATEGY-INTENT
- V0100-009-RISK-DECISION-AUDITED
- V0100-009-OMS-DRY-RUN-LIFECYCLE
- V0100-009-PORTFOLIO-PROJECTION-AUDITED
- V0100-009-RECONCILIATION-TIMELINE-AUDITED
- V0100-009-READINESS-DIFF-AUDITED
- V0100-009-ORDERS-SUBMITTED-FALSE
- V0100-009-BROKER-COMMAND-CREATED-FALSE
- V0100-009-PRODUCTION-CAPABILITIES-DISABLED
- GH-886 Release v0.10.0 Shadow Dry-run Parity Assessment Validation
- `bash checks/verify-v0.10.0-shadow-dry-run-parity.sh`
- `swift test --filter TargetGraphTests/testGH886ShadowDryRunParityAssessmentAuditsNearProductionPathWithoutOrders`
- fixed shadow dry-run parity schema: `shadow_dry_run_parity.json`、market/read-only observation、strategy intent、risk decision、OMS dry-run lifecycle、portfolio projection、reconciliation timeline、readiness diff、`riskDecisionAudited=true`、`portfolioProjectionAudited=true`、`reconciliationTimelineAudited=true`、`readinessDiffAudited=true`、`ordersSubmitted=false`、`brokerCommandCreated=false`、`production_cutover_blocked=true`。
- Boundary: parity evidence 不包含 broker / account response，不来自 endpoint connection，不包含 order payload，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover、production OMS、trading button、order form 或 live command。

## TVM-RELEASE-V0100-COMMAND-SURFACE-DISABLED

- TVM-RELEASE-V0100-COMMAND-SURFACE-DISABLED
- GH-885-VERIFY-V0100-COMMAND-SURFACE-DISABLED
- V0100-008-PRODUCTION-COMMAND-SURFACE-DISABLED-PROOF
- V0100-008-DASHBOARD-PRODUCTION-SURFACE-DISABLED-JSON
- V0100-008-CLI-PRODUCTION-SURFACE-DISABLED-JSON
- V0100-008-TRADING-BUTTON-VISIBLE-FALSE
- V0100-008-ORDER-FORM-VISIBLE-FALSE
- V0100-008-LIVE-COMMAND-ENABLED-FALSE
- V0100-008-SUBMIT-CANCEL-REPLACE-COMMANDS-DISABLED
- V0100-008-PRODUCTION-COMMAND-ENABLED-FALSE
- V0100-008-PRODUCTION-CUTOVER-BLOCKED
- V0100-008-PRODUCTION-CAPABILITIES-DISABLED
- GH-885 Release v0.10.0 Production Command Surface Disabled Proof Validation
- `bash checks/verify-v0.10.0-command-surface-disabled.sh`
- `swift test --filter TargetGraphTests/testGH885ProductionCommandSurfaceDisabledProofKeepsDashboardAndCLIReadOnly`
- fixed Dashboard / CLI proof schema: `dashboard_production_surface_disabled.json`、`cli_production_surface_disabled.json`、`tradingButtonVisible=false`、`orderFormVisible=false`、`liveCommandEnabled=false`、`submitCommandEnabled=false`、`cancelCommandEnabled=false`、`replaceCommandEnabled=false`、`productionCommandEnabled=false`、`production_cutover_blocked=true`。
- Boundary: disabled evidence 不包含 broker / account response，不来自 endpoint connection，不包含 order payload，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover、production OMS、trading button、order form 或 live command。

## TVM-RELEASE-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE

- TVM-RELEASE-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE
- GH-884-VERIFY-V0100-KILL-SWITCH-NO-TRADE-READINESS-GATE
- V0100-007-KILL-SWITCH-NO-TRADE-READINESS-GATE
- V0100-007-KILL-SWITCH-STATE
- V0100-007-NO-TRADE-STATE
- V0100-007-LAST-OPERATOR-REVIEW
- V0100-007-RISK-APPROVAL-REQUIRED
- V0100-007-CUTOVER-BLOCKED-IF-KILL-SWITCH-ACTIVE
- V0100-007-CUTOVER-BLOCKED-IF-NO-TRADE-ACTIVE
- V0100-007-KILL-SWITCH-READINESS-JSON
- V0100-007-NO-TRADE-READINESS-JSON
- V0100-007-PRODUCTION-CUTOVER-BLOCKED
- V0100-007-PRODUCTION-CAPABILITIES-DISABLED
- GH-884 Release v0.10.0 Kill Switch / No-trade Readiness Gate Validation
- `bash checks/verify-v0.10.0-kill-switch-no-trade-readiness-gate.sh`
- `swift test --filter TargetGraphTests/testGH884KillSwitchNoTradeReadinessGateBlocksCutoverAndOrders`
- fixed kill switch / no-trade schema: `kill_switch_readiness.json`、`no_trade_readiness.json`、`killSwitchState=active`、`noTradeState=active`、`lastOperatorReview=manual-operator-review-required-before-production-cutover`、`riskApprovalRequired=true`、`cutoverBlockedIfKillSwitchActive=true`、`cutoverBlockedIfNoTradeActive=true` 和 `production_cutover_blocked=true`。
- Boundary: readiness evidence 不包含 broker / account response，不来自 endpoint connection，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover、production OMS、trading button、order form 或 live command。

## TVM-RELEASE-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE

- TVM-RELEASE-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE
- GH-883-VERIFY-V0100-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE
- V0100-006-CAPITAL-EXPOSURE-LIMIT-READINESS-GATE
- V0100-006-MAX-CAPITAL-LIMIT
- V0100-006-MAX-NOTIONAL-LIMIT
- V0100-006-MAX-SINGLE-ORDER-NOTIONAL-LIMIT
- V0100-006-MAX-SYMBOL-EXPOSURE-LIMIT
- V0100-006-MAX-PRODUCT-EXPOSURE-LIMIT
- V0100-006-MAX-DAILY-LOSS-LIMIT
- V0100-006-MAX-OPEN-ORDERS-LEVERAGE-LIMIT
- V0100-006-ALLOWED-SYMBOLS-PRODUCT-TYPES
- V0100-006-RISK-POLICY-HASH-BINDING
- V0100-006-CAPITAL-EXPOSURE-LIMITS-JSON
- V0100-006-PRODUCTION-CAPABILITIES-DISABLED
- GH-883 Release v0.10.0 Capital / Exposure Limit Readiness Gate Validation
- `bash checks/verify-v0.10.0-capital-exposure-limit-readiness-gate.sh`
- `swift test --filter TargetGraphTests/testGH883CapitalExposureLimitReadinessGateBindsRiskPolicyAndDisablesOrders`
- fixed capital / exposure schema: `capital_exposure_limits.json`、`maxCapital=100000.00`、`maxNotional=25000.00`、`maxSingleOrderNotional=5000.00`、`maxSymbolExposure=15000.00`、`maxProductExposure=50000.00`、`maxDailyLoss=2500.00`、`maxOpenOrders=10`、`maxLeverage=3.0`、`allowedSymbols=BTCUSDT,ETHUSDT`、`allowedProductTypes=spot,usdsPerpetual`、`riskPolicyHash=sha256:v0100-capital-exposure-risk-policy-reference`、`risk_policy_hash_bound=true`、`operator_review_required=true` 和 `order_submission_enabled=false`。
- Boundary: readiness evidence 不包含 broker / account response，不来自 endpoint connection，不读取 production secret，不连接 production endpoint / broker，不提交 testnet 或 production order，不授权 production cutover、production OMS、trading button、order form 或 live command。

## TVM-RELEASE-V0100-ENDPOINT-POLICY-READINESS-GATE

- TVM-RELEASE-V0100-ENDPOINT-POLICY-READINESS-GATE
- GH-882-VERIFY-V0100-ENDPOINT-POLICY-READINESS-GATE
- V0100-005-ENDPOINT-POLICY-READINESS-GATE
- V0100-005-TESTNET-ENDPOINT-ALLOWLIST
- V0100-005-PRODUCTION-ENDPOINT-ALLOWLIST
- V0100-005-ENVIRONMENT-BINDING
- V0100-005-HOST-VALIDATION
- V0100-005-SCHEME-VALIDATION
- V0100-005-NO-SILENT-FALLBACK
- V0100-005-ENDPOINT-POLICY-READINESS-JSON
- V0100-005-PRODUCTION-CAPABILITIES-DISABLED
- GH-882 Release v0.10.0 Endpoint Policy Readiness Gate Validation
- testGH882EndpointPolicyReadinessGateRejectsProductionConnectionAndSilentFallback
- `bash checks/verify-v0.10.0-endpoint-policy-readiness-gate.sh`
- fixed endpoint policy schema: `endpoint_policy_readiness.json`、`environment=testnet`、`environment=production`、`testnetEndpointHost=testnet.binance.vision`、`testnetEndpointHost=testnet.binancefuture.com`、production endpoint allowlist is fixed in the GH-882 contract artifact without authorizing matrix-level production connectivity。
- fixed validation proof: `scheme=https`、`productTypes=spot,usdsPerpetual`、`environmentBound=true`、`hostValidationRequired=true`、`schemeValidationRequired=true`、`endpointConnectionAllowed=false`。
- fixed fallback proof: `production_endpoint_connected=false`、`fallback_to_production=false`、`testnet_to_production_fallback_forbidden=true`、`no_silent_fallback_required=true`。
- forbidden scope: no production endpoint / broker connection, no production secret read, no silent fallback to production, no testnet or production submit / cancel / replace order, no production OMS, no trading button, no order form, no live command, no production cutover.

## TVM-RELEASE-V0100-SECRET-PROVIDER-READINESS-GATE

- TVM-RELEASE-V0100-SECRET-PROVIDER-READINESS-GATE
- GH-881-VERIFY-V0100-SECRET-PROVIDER-READINESS-GATE
- V0100-004-SECRET-PROVIDER-READINESS-GATE
- V0100-004-CREDENTIAL-REFERENCE-EXISTS
- V0100-004-PROVIDER-TYPE-REFERENCE-ONLY
- V0100-004-REDACTION-POLICY-REQUIRED
- V0100-004-SECRET-READINESS-JSON
- V0100-004-REDACTION-PROOF-JSON
- V0100-004-CI-NO-SECRET-PROOF
- V0100-004-MANUAL-SECRET-GATE-REQUIRED
- V0100-004-PRODUCTION-CAPABILITIES-DISABLED
- GH-881 Release v0.10.0 Secret Provider Readiness Gate Validation
- testGH881SecretProviderReadinessGateKeepsSecretsOutOfRuntimeCIDashboardAndEvidence
- `bash checks/verify-v0.10.0-secret-provider-readiness-gate.sh`
- fixed secret provider schema: `credentialReferenceExists=true`、`providerType=environmentVariableReference`、`providerType=keychainItemReference`、`providerType=operatorManualReference`、`redactionPolicy=redactedIdentifierOnly`、`secret_readiness.json`、`redaction_proof.json`。
- fixed gate proof: `ci_no_secret_proof=true`、`manual_secret_gate_required=true`、`storesSecretValue=false`、`readsSecretValue=false`、`printsSecretValue=false`、`dashboardDisplaysSecretValue=false`、`ciSecretAvailable=false`。
- forbidden scope: no secret value persistence, no production secret read, no CI secret availability, no Dashboard secret display, no production endpoint / broker connection, no production cutover, no testnet or production submit / cancel / replace order, no production OMS, no trading button, no order form, no live command.

## TVM-RELEASE-V0100-PRODUCTION-ENVIRONMENT-PROFILE

- TVM-RELEASE-V0100-PRODUCTION-ENVIRONMENT-PROFILE
- GH-880-VERIFY-V0100-PRODUCTION-ENVIRONMENT-PROFILE
- V0100-003-PRODUCTION-ENVIRONMENT-PROFILE-CONTRACT
- V0100-003-REFERENCE-ONLY-POLICY-REFS
- V0100-003-BINANCE-SPOT-USDSM-PERPETUAL-SCOPE
- V0100-003-PRODUCTION-CUTOVER-DISABLED
- V0100-003-ORDER-SUBMISSION-DISABLED
- V0100-003-PRODUCTION-ENDPOINT-CONNECTION-DISABLED
- GH-880 Release v0.10.0 Production Environment Profile Validation
- testGH880ProductionEnvironmentProfilePersistsReferencesOnlyAndKeepsProductionDisabled
- `bash checks/verify-v0.10.0-production-environment-profile.sh`
- fixed profile schema: `environment=production`、`venue=Binance`、`productTypes=spot,usdsPerpetual`、`endpointPolicyRef=v0.10.0-production-endpoint-policy-ref`、`secretPolicyRef=v0.10.0-production-secret-policy-ref`、`riskPolicyRef=v0.10.0-production-risk-policy-ref`。
- fixed disabled flags: `referencesOnlyPersisted=true`、`cutoverAuthorized=false`、`orderSubmissionEnabled=false`、`productionEndpointConnectionEnabled=false`、`productionBrokerConnectionEnabled=false`、`productionSecretValueRead=false`、`productionSecretValueStored=false`、`testnetOrderSubmissionEnabled=false`。
- forbidden scope: no secret value persistence, no production endpoint / broker connection, no production cutover, no testnet or production submit / cancel / replace order, no production OMS, no trading button, no order form, no live command.

## TVM-RELEASE-V0100-V091-PUBLICATION-POLICY

- TVM-RELEASE-V0100-V091-PUBLICATION-POLICY
- GH-879-VERIFY-V0100-V091-PUBLICATION-POLICY
- GH-879-V0100-V091-ACTUAL-GITHUB-RELEASE
- V0100-002-V091-PUBLICATION-FACT
- V0100-002-V0100-RELEASE-POLICY-ANCHOR
- GH-879 Release v0.10.0 v0.9.1 Publication Policy Validation
- testGH879ReleaseV0100V091PublicationPolicyRecordsPublishedTagAndCutoverSeparation
- `bash checks/verify-v0.10.0-release-policy.sh`
- v0.9.1 stable GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.9.1`；tag peeled commit `d041f0dd304075562a85e494695697290972288f`；publication timestamp `2026-06-17T19:45:42Z`。
- release gate split: construction / readiness closeout、public GitHub Release publication 和 production cutover 是三个独立 gate。
- forbidden scope: no tag rewrite, no production cutover, no production trading, no production secret read, no production endpoint / broker connection, no testnet or production submit / cancel / replace order, no production OMS, no trading button, no order form, no live command.

## TVM-RELEASE-V0101-RELEASE-FACT-SYNC-GUARD

- TVM-RELEASE-V0101-RELEASE-FACT-SYNC-GUARD
- GH-907-VERIFY-V0101-RELEASE-FACT-STALE-WORDING-GUARD
- V0101-002-RELEASE-FACT-SYNC-GUARD
- V0101-002-FOUR-GATE-RELEASE-FLOW
- GH-907 Release v0.10.1 Release Fact Sync / Stale Wording Guard Validation
- testGH907ReleaseFactSyncGuardRejectsV0100StalePublicationWording
- `bash checks/verify-v0.10.1-release-fact-sync.sh`
- release fact flow: construction closeout、release publication、release fact sync、stale wording guard。
- v0.10.0 stable GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.10.0`；tag target commit `7b0e1f8bb6a671cd3b96f7e7b020b803f8cea4b4`。
- forbidden scope: no tag rewrite, no release rewrite, no production cutover, no production trading, no production secret read, no production endpoint / broker connection, no testnet or production submit / cancel / replace order, no production OMS, no trading button, no order form, no live command.

## TVM-RELEASE-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT

- TVM-RELEASE-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT
- GH-878-VERIFY-V0100-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT
- V0100-001-PRODUCTION-READINESS-NO-AUTHORIZATION-CONTRACT
- V0100-001-READINESS-ASSESSMENT-NOT-CUTOVER
- V0100-001-DOWNSTREAM-QUEUE-ORDER
- V0100-001-FORBIDDEN-CAPABILITIES
- V0100-001-RELEASE-VALIDATION-MATRIX
- GH-878 Release v0.10.0 Production Readiness No-authorization Contract Validation
- testGH878ReleaseV0100ProductionReadinessContractDoesNotAuthorizeCutover
- `bash checks/verify-v0.10.0-contract.sh`
- allowed readiness flags: `productionReadinessAssessmentAllowed=true`、`productionCutoverRequiresSeparateApproval=true`、`readinessEvidenceOnly=true`、`manualApprovalEvidenceAllowed=true` 和 `readinessDashboardReadModelAllowed=true`。
- fixed disabled flags: `productionTradingEnabledByDefault=false`、`productionCutoverAuthorized=false`、`productionSecretRead=false`、`productionEndpointConnected=false`、`productionBrokerConnected=false`、`productionOrderSubmitted=false`、`realOrderSubmissionEnabled=false`、`testnetOrderSubmissionAllowed=false` 和 `testnetOrderRoutingAllowed=false`。
- forbidden scope: readiness assessment is not production cutover; no production trading, no production secret value read, no production endpoint / broker connection, no testnet or production submit / cancel / replace order, no production OMS, no trading button, no order form, no live command.

## TVM-RELEASE-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT

- TVM-RELEASE-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT
- GH-843-VERIFY-V090-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT
- V090-001-TESTNET-NO-ORDER-OBSERVABILITY-CONTRACT
- V090-001-ALLOWED-MONITOR-MODES
- V090-001-ARTIFACT-BOUNDARY
- V090-001-FRESHNESS-STALENESS-SEMANTICS
- V090-001-CI-MANUAL-LANE-SPLIT
- V090-001-RECONCILIATION-HARDENING-SCOPE
- V090-001-DOWNSTREAM-QUEUE-ORDER
- V090-001-FORBIDDEN-CAPABILITIES
- V090-001-RELEASE-VALIDATION-MATRIX
- GH-843 Release v0.9.0 Testnet No-order Observability Contract Validation
- testGH843ReleaseV090TestnetNoOrderObservabilityContractDefinesMonitorModesAndForbiddenCapabilities
- monitor modes: `testnet-read-only-observe`、`snapshot-freshness-monitor`、`private-stream-heartbeat-monitor`、`reconciliation-review`、`alert-read-model-only`、`recovery-observe` 和 `production-blocked`。
- freshness semantics: `fresh`、`stale`、`disconnected`、`recovering`、`recovered`、`blocked` 和 `unavailable` 必须只描述 read-only monitor / local recovery state。
- CI lane: `ciNetworkRequired=false`、`ciSecretRead=false`、`ciOrderSubmissionAllowed=false`；manual lane: `manualOperatorConfirmationRequired=true`、`manualProofRedacted=true`、`manualOrderSubmissionAllowed=false`。
- reconciliation hardening: matched / delta / missing / stale / blocked 只作为 explain-only review evidence，不创建 correction command 或 broker write。
- forbidden scope: no production trading, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet order submission, no real order, no production cutover, no notification side effect, no automatic recovery command.

## TVM-RELEASE-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD

- TVM-RELEASE-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD
- GH-844-VERIFY-V090-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD
- V090-002-V080-PUBLICATION-ALIGNMENT-CARRYFORWARD
- GH-835-V081-V080-ACTUAL-GITHUB-RELEASE
- V081-001-V080-PUBLICATION-DOCS-ALIGNMENT
- GH-844 Release v0.9.0 v0.8.0 Publication Alignment Carry-forward Validation
- testGH844ReleaseV090CarriesForwardV080PublicationAlignmentWithoutCutover
- `bash checks/verify-v0.9.0-v080-publication-alignment.sh`
- v0.8.0 stable GitHub Release exists at `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0` and points to peeled commit `d83b3b564096a5427db15a437921fc797b22564d`。
- v0.9.0 dependency posture: construction closeout、public GitHub Release publication 和 production cutover remain separate gates; v0.9.0 can cite v0.8.0 stable publication evidence but cannot treat it as runtime capability or cutover authorization.
- forbidden scope: no tag move, no release rewrite, no new release creation, no runtime change, no production cutover, no production secret read, no production endpoint / broker connection, no testnet or production submit / cancel / replace order.

## TVM-RELEASE-V090-TESTNET-MONITOR-SESSION-STORE

- TVM-RELEASE-V090-TESTNET-MONITOR-SESSION-STORE
- GH-845-VERIFY-V090-TESTNET-MONITOR-SESSION-STORE
- V090-003-TESTNET-READONLY-MONITOR-SESSION
- V090-003-MONITOR-SESSION-JSON
- V090-003-MONITOR-EVENTS-JSONL
- V090-003-MONITOR-STATUS-JSON
- V090-003-MONITOR-STATE-TAXONOMY
- V090-003-APPEND-ONLY-MONITOR-EVENTS
- V090-003-CORRUPTED-ARTIFACTS-FAIL-CLOSED
- GH-845 Release v0.9.0 TestnetReadOnlyMonitorSession Store Validation
- testGH845TestnetReadOnlyMonitorSessionStorePersistsArtifactsAndFailsClosed
- `bash checks/verify-v0.9.0-monitor-session-store.sh`
- artifact path: `.local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor_session.json`、`monitor_events.jsonl`、`monitor_status.json`。
- state taxonomy: created / connecting / observing / stale / disconnected / recovering / stopped / failed。
- fail-closed scope: corrupted monitor_session.json、monitor_events.jsonl、monitor_status.json、checksum mismatch、event history mismatch 和 invalid transition 均必须 fail closed，不写入新事件。
- forbidden scope: no runtime startup, no automatic reconnect command, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace, no production order, no production OMS, no trading button, no order form, no production cutover.

## TVM-RELEASE-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS

- TVM-RELEASE-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS
- GH-846-VERIFY-V090-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS
- V090-004-SIGNED-ACCOUNT-SNAPSHOT-FRESHNESS
- V090-004-ACCOUNT-SNAPSHOT-FRESHNESS-JSON
- V090-004-REDACTED-CREDENTIAL-REFERENCE
- V090-004-NO-RAW-PAYLOAD-PERSISTENCE
- GH-846 Release v0.9.0 Signed Account Snapshot Freshness Monitor Validation
- testGH846SignedAccountSnapshotFreshnessMonitorPersistsRedactedEvidence
- `bash checks/verify-v0.9.0-snapshot-freshness-monitor.sh`
- artifact path: `.local/mtpro/runs/<runID>/testnet-readonly-monitor/account-snapshot-freshness.json`。
- freshness evidence: snapshotObservedAt、recordedAt、latencyMilliseconds、ageSeconds、staleThresholdSeconds、freshnessStatus、ageBucket、staleReason 和 monitorSessionChecksum 必须可 inspect。
- redaction: redactedCredentialReference 必须以 `:<redacted>` 结尾，raw credential value、raw payload、raw account payload、secret、API key、token、listenKey 和 signature 均不得进入 artifact。
- fail-closed scope: corrupted account-snapshot-freshness.json、checksum mismatch、monitorSessionChecksum mismatch 和 unsafe credential reference 均必须 fail closed。
- forbidden scope: no CI network access, no production account read, no raw account payload persistence, no credential value persistence, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace, no production order, no production OMS, no trading button, no order form, no production cutover.

## TVM-RELEASE-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS

- TVM-RELEASE-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS
- GH-847-VERIFY-V090-PRIVATE-STREAM-HEARTBEAT-STALENESS
- V090-005-PRIVATE-STREAM-HEARTBEAT-STALENESS
- V090-005-PRIVATE-STREAM-HEARTBEAT-JSON
- V090-005-REDACTED-LISTENKEY-REFERENCE
- V090-005-NO-RAW-PRIVATE-PAYLOAD-PERSISTENCE
- GH-847 Release v0.9.0 Private Stream Heartbeat Staleness Monitor Validation
- testGH847PrivateStreamHeartbeatMonitorPersistsStalenessAndRedactedEvidence
- `bash checks/verify-v0.9.0-private-stream-heartbeat-monitor.sh`
- artifact path: `.local/mtpro/runs/<runID>/testnet-readonly-monitor/private-stream-heartbeat.json`。
- heartbeat evidence: lastEventObservedAt、heartbeatRecordedAt、heartbeatIntervalSeconds、lastEventAgeSeconds、staleThresholdSeconds、heartbeatStatus、streamStale、streamRecovered 和 monitorSessionChecksum 必须可 inspect。
- listenKey lifecycle evidence: listenKeyCreatedAt、listenKeyExpiresAt、listenKeyAgeSeconds、listenKeySecondsUntilExpiry、listenKeyAgeBucket、redactedListenKeyReference 和 listenKeyReferenceHash 必须可 inspect。
- redaction: redactedListenKeyReference 必须以 `:<redacted>` 结尾，raw listenKey、raw private payload、credential value、secret、API key、token 和 signature 均不得进入 artifact。
- fail-closed scope: corrupted private-stream-heartbeat.json、checksum mismatch、monitorSessionChecksum mismatch 和 unsafe listenKey reference 均必须 fail closed。
- forbidden scope: no private WebSocket CI runtime, no executionReport command path, no order command, no raw listenKey persistence, no raw private payload persistence, no credential value persistence, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace, no production order, no production OMS, no trading button, no order form, no production cutover.

## TVM-RELEASE-V090-MONITOR-RECOVERY-WORKFLOW

- TVM-RELEASE-V090-MONITOR-RECOVERY-WORKFLOW
- GH-848-VERIFY-V090-MONITOR-RECOVERY-WORKFLOW
- V090-006-MONITOR-RECOVERY-WORKFLOW
- V090-006-MONITOR-RECOVERY-JSON
- V090-006-PRESERVE-MONITOR-EVENT-HISTORY
- V090-006-LOCAL-MANUAL-RECOVERY-ONLY
- GH-848 Release v0.9.0 Monitor Recovery Workflow Validation
- testGH848MonitorRecoveryWorkflowPreservesHistoryAndRedactedEvidence
- `bash checks/verify-v0.9.0-monitor-recovery-workflow.sh`
- artifact path: `.local/mtpro/runs/<runID>/testnet-readonly-monitor/monitor-recovery.json`。
- transition evidence: recoveryAction、fromState、intermediateState、toState、recoveryReason、preRecoveryMonitorSessionChecksum 和 recoveredMonitorSessionChecksum 必须可 inspect，并且只允许 stale / disconnected -> recovering -> observing。
- event history evidence: previousEventChecksums 必须完整保留为 recoveredEventChecksums 前缀，recovery 只能追加 recover 与 observe 两个本地事件，eventHistoryPreserved 必须为 true。
- redaction: redactedListenKeyReference 必须以 `:<redacted>` 结尾，listenKeyReferenceHash 必须为 stable sha256；raw listenKey、raw private payload、credential value、secret、API key、token 和 signature 均不得进入 artifact。
- fail-closed scope: invalid transition、corrupted monitor-recovery.json、checksum mismatch、recoveredMonitorSessionChecksum mismatch、event history mismatch 和 unsafe listenKey reference 均必须 fail closed。
- forbidden scope: no automatic reconnect command, no private WebSocket CI runtime, no broker recovery operation, no order command, no raw listenKey persistence, no raw private payload persistence, no credential value persistence, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace, no production order, no production OMS, no trading button, no order form, no production cutover.

## TVM-RELEASE-V090-DASHBOARD-OBSERVABILITY-TIMELINE

- TVM-RELEASE-V090-DASHBOARD-OBSERVABILITY-TIMELINE
- GH-849-VERIFY-V090-DASHBOARD-OBSERVABILITY-TIMELINE
- V090-007-DASHBOARD-OBSERVABILITY-TIMELINE
- V090-007-MONITOR-SESSION-ARTIFACTS-ONLY
- V090-007-SNAPSHOT-PRIVATE-STREAM-FRESHNESS-TIMELINES
- V090-007-STALE-DISCONNECTED-RECOVERED-EVENTS
- V090-007-LAST-OBSERVED-EVENT-KIND
- V090-007-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
- V090-007-NO-TESTNET-ORDER-ROUTING
- V090-007-NO-PRODUCTION-CUTOVER
- GH-849 Release v0.9.0 Dashboard Observability Timeline Validation
- testGH849DashboardObservabilityTimelineShowsMonitorArtifactsWithoutCommands
- testGH849DashboardObservabilityTimelineIsAnchoredInV090Guards
- `bash checks/verify-v0.9.0-dashboard-observability-timeline.sh`
- Dashboard timeline evidence: snapshot timeline、private stream timeline、freshness timeline、stale / disconnected / recovered events 和 last observed event kind 必须可 inspect。
- artifact boundary: Dashboard 只展示 `monitor_session.json`、`monitor_events.jsonl`、`monitor_status.json`、`account-snapshot-freshness.json`、`private-stream-heartbeat.json` 和 `monitor-recovery.json` 的 read-model summary，不保存 raw payload。
- dependency boundary: Dashboard target 不新增 DataClient 或 Database runtime dependency；该 surface 只绑定 Dashboard-safe ViewModel source 和 checksum reference。
- forbidden scope: no Dashboard command surface, no trading button, no order form, no live command, no notification side effect, no automatic reconnect command, no raw listenKey, no raw private payload, no credential value, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace, no production order, no production OMS, no production cutover.

## TVM-RELEASE-V090-ALERT-READ-MODEL

- TVM-RELEASE-V090-ALERT-READ-MODEL
- GH-850-VERIFY-V090-ALERT-READ-MODEL
- V090-008-ALERT-READ-MODEL
- V090-008-ALERT-FIELDS
- V090-008-MONITOR-SESSION-EVIDENCE-BINDING
- V090-008-LOCAL-READ-MODEL-ONLY
- V090-008-NO-NOTIFICATION-SIDE-EFFECTS
- V090-008-NO-AUTOMATED-TRADING-REACTION
- V090-008-NO-PRODUCTION-CUTOVER
- GH-850 Release v0.9.0 Alert Read-model Validation
- testGH850MonitorAlertReadModelBindsFreshnessAndHeartbeatWithoutNotificationSideEffects
- `bash checks/verify-v0.9.0-alert-read-model.sh`
- alert fields: `alert_id`、`severity`、`reason`、`source`、`ack_required` 和 `lifecycle` 必须可 inspect，且只表示本地 read-model state。
- evidence binding: alert 必须绑定 `monitorSessionChecksum`、`accountSnapshotFreshnessChecksum`、`privateStreamHeartbeatChecksum` 和 source artifact checksum，snapshot stale 只能来自 `account-snapshot-freshness.json`，private stream stale / disconnected / expired / recovered 只能来自 `private-stream-heartbeat.json`。
- no notification side effects: `notificationSideEffectsEnabled=false`、`smsNotificationSent=false`、`emailNotificationSent=false`、`webhookNotificationSent=false`、`pushNotificationSent=false` 和 `externalServiceCalled=false`。
- forbidden scope: no SMS, no email, no webhook, no push notification, no external service call, no paging command, no incident command, no automatic recovery command, no automated trading reaction, no trading button, no order form, no live command, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace, no production order, no production OMS, no production cutover.

## TVM-RELEASE-V090-PORTFOLIO-RECONCILIATION-TIMELINE

- TVM-RELEASE-V090-PORTFOLIO-RECONCILIATION-TIMELINE
- GH-851-VERIFY-V090-PORTFOLIO-RECONCILIATION-TIMELINE
- V090-009-PORTFOLIO-RECONCILIATION-TIMELINE
- V090-009-EXPECTED-OBSERVED-DELTA
- V090-009-STALE-REASON-REVIEW-HISTORY
- V090-009-OPERATOR-ACKNOWLEDGEMENT-METADATA-ONLY
- V090-009-MONITOR-SESSION-EVIDENCE-BINDING
- V090-009-NO-CORRECTION-COMMAND
- V090-009-NO-BROKER-WRITE
- V090-009-NO-ACCOUNT-MUTATION
- V090-009-NO-TRADING-ADJUSTMENT
- V090-009-NO-PRODUCTION-CUTOVER
- GH-851 Release v0.9.0 Portfolio Reconciliation Timeline Validation
- testGH851PortfolioReconciliationTimelineBindsExpectedObservedDeltaAndAckMetadata
- `bash checks/verify-v0.9.0-portfolio-reconciliation-timeline.sh`
- timeline evidence: matched / delta / missing / stale 四类状态必须可 inspect，且每条 record 必须包含 expected state、observed state、delta、stale reason、operator acknowledgement metadata 和 review history。
- evidence binding: timeline 必须绑定 `monitorSessionChecksum`、`accountSnapshotFreshnessChecksum` 和 `privateStreamHeartbeatChecksum`，observed state 只能来自 redacted read-only monitor evidence。
- acknowledgement boundary: acknowledgement 只保存 acknowledgedAt、acknowledgedBy 和 operatorNote metadata，不创建 correction command、broker write、account mutation 或 trading adjustment。
- forbidden scope: no correction command, no broker write, no account mutation, no trading adjustment, no trading button, no order form, no live command, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace, no production order, no production OMS, no production cutover.

## TVM-RELEASE-V090-RISK-POLICY-APPLICATION-AUDIT

- TVM-RELEASE-V090-RISK-POLICY-APPLICATION-AUDIT
- GH-852-VERIFY-V090-RISK-POLICY-APPLICATION-AUDIT
- V090-010-RISK-POLICY-APPLICATION-AUDIT
- V090-010-RISK-POLICY-VERSION-HASH
- V090-010-POLICY-APPLIED-AT
- V090-010-OPERATOR-CHANGE-REFERENCE
- V090-010-MONITOR-SESSION-EVIDENCE-BINDING
- V090-010-LOCAL-PROFILE-EVIDENCE
- V090-010-NO-POLICY-DRIVEN-ORDER-EXECUTION
- V090-010-NO-BROKER-PRODUCTION-PATH
- V090-010-NO-PRODUCTION-CUTOVER
- GH-852 Release v0.9.0 Risk Policy Application Audit Validation
- testGH852RiskPolicyApplicationAuditBindsPolicyVersionHashAndMonitorArtifacts
- `bash checks/verify-v0.9.0-risk-policy-application-audit.sh`
- profile evidence: audit 必须记录 `risk_policy_version`、`risk_policy_hash`、`policy_applied_at` 和 `operator_change_reference`，并引用 `.local/mtpro/risk_policy.json` 本地 profile evidence。
- evidence binding: monitor session、account snapshot freshness、private stream heartbeat 和 Portfolio reconciliation timeline artifact 必须绑定同一 risk policy version/hash 和 monitorSessionChecksum。
- audit boundary: policy change 只作为 audit metadata，不表示 order authorization，不驱动 automated policy-driven order execution。
- forbidden scope: no broker / production path, no trading button, no order form, no live command, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace, no production order, no production OMS, no production cutover.

## TVM-RELEASE-V090-RUN-MONITOR-EXPORT-BUNDLE

- TVM-RELEASE-V090-RUN-MONITOR-EXPORT-BUNDLE
- GH-853-VERIFY-V090-RUN-MONITOR-EXPORT-BUNDLE
- V090-011-RUN-MONITOR-EXPORT-BUNDLE
- V090-011-RUN-BUNDLE-CHECKSUM
- V090-011-MONITOR-BUNDLE-CHECKSUM
- V090-011-RISK-POLICY-BUNDLE-CHECKSUM
- V090-011-RECONCILIATION-BUNDLE-CHECKSUM
- V090-011-REDACTION-PROOF
- V090-011-LOCAL-EXPORT-ONLY
- V090-011-NO-UPLOAD-NOTIFICATION-SIDE-EFFECT
- V090-011-NO-RAW-SECRET-LISTENKEY-PRIVATE-PAYLOAD
- V090-011-NO-PRODUCTION-DATA-EXPORT
- V090-011-NO-PRODUCTION-CUTOVER
- GH-853 Release v0.9.0 Run Monitor Export Bundle Validation
- testGH853RunMonitorExportBundleIsChecksumBackedAndRedacted
- `bash checks/verify-v0.9.0-run-monitor-export-bundle.sh`
- bundle evidence: export bundle 必须包含 run、monitor、Risk policy 和 reconciliation 四类 checksum-backed entry。
- redaction proof: manifest 必须记录 aggregate redaction proof checksum，并证明 raw secret、raw listenKey、raw private payload、broker command payload 和 order request payload 未进入 export artifact。
- forbidden scope: no upload, no external sharing, no notification / webhook, no production data export, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace, no production order, no production OMS, no production cutover.

## TVM-RELEASE-V090-VALIDATION-LANES

- TVM-RELEASE-V090-VALIDATION-LANES
- GH-854-VERIFY-V090-VALIDATION-LANES
- V090-012-VALIDATION-LANES
- V090-012-DETERMINISTIC-CI-LANE
- V090-012-MANUAL-OPERATOR-TESTNET-LANE
- V090-012-MANUAL-PROOF-NOT-CI-REPLAYABLE
- V090-012-CI-NO-NETWORK-SECRET-ORDER
- V090-012-MANUAL-NO-ORDER-PRODUCTION-CUTOVER
- GH-854 Release v0.9.0 Validation Lanes Hardening Validation
- testGH854ValidationLanesKeepManualProofOutOfCIReplay
- `bash checks/verify-v0.9.0-validation-lanes.sh`
- CI lane: deterministic fixture only; `ciNetworkRequired=false`、`ciSecretRead=false`、`ciOrderSubmissionAllowed=false`、`workflowDispatchCanInjectSecret=false`。
- manual lane: operator confirmed testnet read-only proof reference only; `manualOperatorConfirmationRequired=true`、`manualProofRedacted=true`、`manualOrderSubmissionAllowed=false`、`manualProofReplayableByCI=false`。
- forbidden scope: manual proof cannot be replayed by CI, cannot satisfy required checks, cannot inject secret through workflow_dispatch, no testnet submit / cancel / replace, no production secret read, no production endpoint / broker connection, no production cutover.

## TVM-RELEASE-V090-DASHBOARD-CLI-OPERATOR-UX

- TVM-RELEASE-V090-DASHBOARD-CLI-OPERATOR-UX
- GH-855-VERIFY-V090-DASHBOARD-CLI-OPERATOR-UX
- V090-013-DASHBOARD-CLI-OPERATOR-UX
- V090-013-MONITOR-START-STATUS-STOP-RECOVER-EXPORT
- V090-013-DASHBOARD-READ-STATE-TIMELINES-ALERTS-EXPORT
- V090-013-SAFE-LOCAL-READONLY-CONTROLS
- V090-013-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
- V090-013-NO-TESTNET-ORDER-ROUTING
- V090-013-NO-PRODUCTION-CUTOVER
- GH-855 Release v0.9.0 Dashboard / CLI Operator UX Validation
- testGH855DashboardOperatorUXShowsMonitorOperationsWithoutCommands
- testGH855DashboardCLIOperatorUXIsAnchoredInV090Guards
- `bash checks/verify-v0.9.0-dashboard-cli-operator-ux.sh`
- CLI monitor commands: `monitor start`、`monitor status`、`monitor stop`、`monitor recover` and `monitor export` must only output local artifact paths, checksum references and no-order flags.
- Dashboard operator UX: monitor state、timelines、alerts、export status and safe local controls must be visible as read-model-only rows.
- artifact boundary: all UX rows must stay under `.local/mtpro/runs/<runID>/testnet-readonly-monitor/...` and must not persist raw credential, raw listenKey, raw private payload, broker state or order request.
- forbidden scope: no trading button, no order form, no live command, no broker command, no notification side effect, no automatic recovery command, no testnet order routing, no testnet submit / cancel / replace, no production secret read, no production endpoint / broker connection, no production order, no production OMS, no production cutover.

## TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK

- TVM-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK
- GH-856-VERIFY-V090-FINAL-AUDIT-DOCS-RUNBOOK
- GH-856-RELEASE-V090-FINAL-AUDIT-DOCS-RUNBOOK
- V090-014-VALIDATION-SUMMARY
- V090-014-STAGE-CODE-AUDIT
- V090-014-RELEASE-NOTES
- V090-014-OPERATOR-RUNBOOK
- V090-014-ROOT-DOCS-REFRESH
- V090-014-AGGREGATE-VERIFY
- V090-014-NO-PRODUCTION-CUTOVER
- GH-856 Release v0.9.0 Final Audit / Docs / Runbook Validation
- testGH856ReleaseV090FinalAuditDocsRunbookCloseCompletedFactsOnly
- `bash checks/verify-v0.9.0.sh`
- audit docs: `docs/audit/mtpro-release-v0.9.0-testnet-no-order-observability-stage-code-audit.md`
- release notes: `docs/release/mtpro-release-v0.9.0-testnet-no-order-observability-notes.md`
- operator runbook: `docs/operators/release-v0.9.0-testnet-no-order-observability-runbook.md`
- root docs refresh: latest completed release construction scope must be v0.9.0 and Project Closure Count must be `43 / 43 (100%)`
- forbidden scope: GH-856 construction closeout does not publish a tag. no next Project / Issue, no production cutover, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet submit / cancel / replace order, no real submit / cancel / replace order.

## TVM-RELEASE-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT

- TVM-RELEASE-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT
- GH-807-VERIFY-V080-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT
- V080-001-PERSISTENT-OPERATOR-RUNTIME-NO-ORDER-CONTRACT
- V080-001-ALLOWED-MODES
- V080-001-PERSISTENT-LOCAL-ARTIFACTS
- V080-001-TESTNET-READONLY-MONITORING
- V080-001-SAFE-OPERATOR-CONTROLS
- V080-001-DOWNSTREAM-QUEUE-ORDER
- V080-001-FORBIDDEN-CAPABILITIES
- V080-001-EVIDENCE-ENVELOPE
- GH-807 Release v0.8.0 Persistent Operator Runtime No-order Contract Validation
- testGH807ReleaseV080PersistentOperatorRuntimeNoOrderContractDefinesAllowedModesAndForbiddenCapabilities
- persistent local runtime: run registry、operator session store、event log、manifest、status、Risk policy profile、reconciliation review 和 Dashboard read-only snapshot 可以作为 local artifacts。
- testnet read-only monitoring: `testnetReadOnlyMonitoringAllowed=true` 只授权 read-only monitor / manual proof evidence；`testnetOrderSubmissionAllowed=false` 和 `testnetOrderRoutingAllowed=false` 必须同时成立。
- safe local controls: start / stop / recover / archive local session、refresh read-only monitor、record manual proof summary 和 open reconciliation review 不得触发 ExecutionClient、broker、OMS production handoff、submit / cancel / replace、trading button、order form 或 live command。
- forbidden scope: no production trading, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet order submission, no real order, no production cutover.

## TVM-RELEASE-V080-RELEASE-PUBLICATION-POLICY

- TVM-RELEASE-V080-RELEASE-PUBLICATION-POLICY
- GH-808-RELEASE-PUBLICATION-POLICY
- V080-002-V070-ACTUAL-GITHUB-RELEASE
- V080-002-V080-CONSTRUCTION-VS-PUBLICATION
- V080-002-TAG-NAMING-RULES
- V080-002-GITHUB-RELEASE-CHECKLIST
- V080-002-SOURCE-CHECKSUM-EXPECTATIONS
- V080-002-RELEASE-NOTES-PUBLISHING-GATE
- GH-808 Release v0.7.0 / v0.8.0 Publication Policy Validation
- testGH808ReleasePublicationPolicySeparatesConstructionCloseoutFromGitHubRelease
- v0.7.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.7.0`; stable release；tag peeled commit `79bd7309b5d644599b6879e615489562455cd3fe`。
- v0.8.0 GitHub Release: `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0`; stable release；tag peeled commit `d83b3b564096a5427db15a437921fc797b22564d`。
- v0.8.0 policy: construction closeout、public release publication 和 production cutover remain separate gates; source checksum expectation binds exact tag archive, not mutable branch.
- forbidden scope: GH-808 creates no tag, no GitHub Release, no next Project / Issue, no production cutover, no production secret read, no production endpoint / broker connection, no testnet or production submit / cancel / replace order.

## TVM-RELEASE-V081-V080-PUBLICATION-DOCS-ALIGNMENT

- TVM-RELEASE-V081-V080-PUBLICATION-DOCS-ALIGNMENT
- GH-835-V081-V080-ACTUAL-GITHUB-RELEASE
- V081-001-V080-PUBLICATION-DOCS-ALIGNMENT
- V081-001-NO-PRODUCTION-CUTOVER
- GH-835 Release v0.8.0 Public GitHub Release Docs Alignment Validation
- `bash checks/verify-v0.8.1-v080-release-publication-docs.sh`
- v0.8.0 stable GitHub Release exists at `https://github.com/atxinbao/MTPRO/releases/tag/v0.8.0` and points to peeled commit `d83b3b564096a5427db15a437921fc797b22564d`。
- forbidden scope: docs-only release fact alignment; no tag move, no release rewrite, no next Project / Issue, no production cutover, no production secret read, no production endpoint / broker connection, no testnet or production submit / cancel / replace order.

## TVM-RELEASE-V080-RUN-REGISTRY-STORE

- TVM-RELEASE-V080-RUN-REGISTRY-STORE
- GH-809-VERIFY-V080-RUN-REGISTRY-STORE
- V080-003-RUN-REGISTRY-STORE
- V080-003-REGISTRY-JSON-PATH
- V080-003-REGISTRY-LOCK
- V080-003-REGISTRY-CHECKSUM
- V080-003-LIST-INSPECT-ARCHIVE-RECOVER
- V080-003-MISSING-CORRUPTED-FAILS-CLOSED
- V080-003-NO-PRODUCTION-BROKER-ORDER-FIELDS
- GH-809 Release v0.8.0 Persistent RunRegistryStore Validation
- testGH809RunRegistryStorePersistsRegistryJSONChecksumAndFailClosedStates
- persistent registry path: `.local/mtpro/runs/registry.json`
- local lock path: `.local/mtpro/runs/registry.lock`
- failure states: missing registry、corrupted registry、checksum mismatch、lock unavailable、archived mutation 和 incomplete run 必须 fail closed.
- operations: list / inspect / archive / recover only mutate local registry metadata and checksums.
- forbidden scope: no runtime start, no production trading, no production secret read, no production endpoint / broker connection, no testnet order routing, no testnet order submission, no real order, no production cutover.

## TVM-RELEASE-V080-CLI-LOCAL-SESSION

- TVM-RELEASE-V080-CLI-LOCAL-SESSION
- GH-810-VERIFY-V080-CLI-LOCAL-SESSION
- V080-004-CLI-LOCAL-SESSION-ACTIONS
- V080-004-RUN-CREATES-LOCAL-ARTIFACTS
- V080-004-STATUS-READS-REGISTRY
- V080-004-STOP-RECOVER-LOCAL-ONLY
- V080-004-NO-ENDPOINT-BROKER-ORDER-PATH
- GH-810 Release v0.8.0 CLI Local Session Action Validation
- testGH810TopLevelCLICreatesAndMutatesPersistentLocalSessionArtifacts
- CLI run action: `mtpro run --mode dry-run` creates local runID, registry entry, `_RUN_STATUS.json`, `status.json`, `events.jsonl` and `manifest.json`.
- CLI status action: `mtpro status <runID>` reads registry / status artifact only.
- CLI stop / recover action: `mtpro stop <runID>` and `mtpro recover <runID>` mutate only local session state evidence.
- forbidden scope: no endpoint connection, no broker connection, no ExecutionClient order path, no testnet order submission, no production trading, no production secret read, no production cutover.

## TVM-RELEASE-V080-OPERATIONAL-SESSION-STORE

- TVM-RELEASE-V080-OPERATIONAL-SESSION-STORE
- GH-811-VERIFY-V080-OPERATIONAL-SESSION-STORE
- V080-005-OPERATIONAL-RUN-SESSION-STORE
- V080-005-SESSION-JSON
- V080-005-SESSION-EVENTS-JSONL
- V080-005-SESSION-STATUS-JSON
- V080-005-INVALID-TRANSITION-FAILS-CLOSED
- V080-005-RECOVERY-PRESERVES-HISTORY
- GH-811 Release v0.8.0 OperationalRunSessionStore Validation
- testGH811OperationalRunSessionStorePersistsLifecycleAndRejectsInvalidTransitions
- local artifacts: `.local/mtpro/runs/<runID>/session.json`、`session_events.jsonl` 和 `session_status.json`.
- lifecycle coverage: created / starting / running / stopping / stopped / failed / recovered / completed states persist locally.
- fail-closed coverage: invalid transitions throw before new state / event writes.
- recovery coverage: recovered sessions preserve prior event history and recovery reason.
- forbidden scope: no runtime start, no endpoint connection, no broker connection, no ExecutionClient order path, no testnet order submission, no production trading, no production secret read, no production cutover.

## TVM-RELEASE-V080-EVENT-LOG-WRITER-CRASH-RECOVERY

- TVM-RELEASE-V080-EVENT-LOG-WRITER-CRASH-RECOVERY
- GH-812-VERIFY-V080-EVENT-LOG-WRITER-CRASH-RECOVERY
- V080-006-EVENT-LOG-WRITER-CRASH-RECOVERY
- V080-006-EVENT-SCHEMA-VERSION
- V080-006-CORRUPTED-LINE-QUARANTINE
- V080-006-NO-COMPACTION-POLICY
- V080-006-DUPLICATE-RUN-EVENT-FAILS-CLOSED
- GH-812 Release v0.8.0 EventLogWriter Crash Recovery Validation
- testGH812RuntimeEventLogWriterHardensCrashRecoverySchemaQuarantineAndCompactionPolicy
- event schema: runtime `events.jsonl` records carry explicit schema version.
- multi-batch append: checksum chain remains valid across multiple append batches.
- duplicate protection: duplicate event IDs are rejected from existing log and same batch; duplicate run evidence remains runID-bound.
- recovery evidence: partial line truncation stays deterministic; complete corrupted lines are written to `events.jsonl.quarantine` without silent loss.
- compaction policy: append-only no-compaction for v0.8.0.
- forbidden scope: no distributed log service, no broker event ingestion, no production persistence cutover, no production endpoint / broker connection, no production secret read, no real order, no production cutover.

## TVM-RELEASE-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF

- TVM-RELEASE-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF
- GH-813-VERIFY-V080-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF
- V080-007-MANUAL-TESTNET-SIGNED-ACCOUNT-NETWORK-PROOF
- V080-007-NETWORK-ATTEMPTED-AND-SNAPSHOT-READ
- V080-007-REDACTED-CREDENTIAL-REFERENCE
- V080-007-CI-DETERMINISTIC-NO-NETWORK-SECRET
- V080-007-NO-TESTNET-ORDER-ROUTING
- V080-007-NO-PRODUCTION-CUTOVER
- GH-813 Release v0.8.0 Manual Testnet Signed Account Network Proof Validation
- testGH813ManualBinanceTestnetSignedAccountNetworkProofIsRedactedAndNoOrder
- manual proof artifact: records `networkAttempted=true` and `signedAccountSnapshotRead=true` from a GH-786 network read-only source artifact.
- redaction evidence: artifact stores redacted credential reference and does not store API key、secret or raw account payload.
- CI split: focused verifier uses deterministic mock transport only; CI does not require network or secret.
- order boundary: `ordersSubmitted=false`、`testnetOrderSubmissionAllowed=false`、`testnetOrderRoutingAllowed=false` and `testnetCancelReplaceAllowed=false`.
- forbidden scope: no production trading, no production secret read, no production endpoint / broker connection, no testnet order submission, no real order, no production cutover.

## TVM-RELEASE-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING

- TVM-RELEASE-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING
- GH-814-VERIFY-V080-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING
- V080-008-MANUAL-TESTNET-PRIVATE-STREAM-MONITORING
- V080-008-LISTENKEY-LIFECYCLE-OPEN-OBSERVE-CLOSE
- V080-008-ACCOUNT-BALANCE-POSITION-READMODEL
- V080-008-REDACTED-LISTENKEY-CREDENTIAL-REFERENCE
- V080-008-EXECUTIONREPORT-COMMAND-PATH-REJECTION
- V080-008-NO-TESTNET-ORDER-ROUTING
- V080-008-NO-PRODUCTION-CUTOVER
- GH-814 Release v0.8.0 Manual Testnet Private Stream Monitoring Validation
- testGH814ManualBinanceTestnetPrivateStreamMonitoringProofIsRedactedAndNoOrder
- manual proof artifact: records open / observe / close lifecycle from a GH-787 network read-only source artifact.
- read-model evidence: records account snapshot、balance update、position update and private stream freshness statuses without raw private payload.
- redaction evidence: artifact stores redacted credential and listenKey references and does not store API key、secret、raw listenKey or raw private payload.
- command boundary: `executionReportCommandPathEnabled=false`、`ordersSubmitted=false`、`testnetOrderSubmissionAllowed=false`、`testnetOrderRoutingAllowed=false` and `testnetCancelReplaceAllowed=false`.
- forbidden scope: no production trading, no production secret read, no production endpoint / broker connection, no testnet order submission, no executionReport command handling, no real order, no production cutover.

## TVM-RELEASE-V080-DASHBOARD-TESTNET-READONLY-MONITOR

- TVM-RELEASE-V080-DASHBOARD-TESTNET-READONLY-MONITOR
- GH-815-VERIFY-V080-DASHBOARD-TESTNET-READONLY-MONITOR
- V080-009-DASHBOARD-TESTNET-READONLY-MONITOR-SURFACE
- V080-009-ACCOUNT-SNAPSHOT-FRESHNESS
- V080-009-PRIVATE-STREAM-FRESHNESS
- V080-009-LISTENKEY-LIFECYCLE-VISIBLE
- V080-009-STALE-DISCONNECTED-RECOVERED-STATES
- V080-009-CREDENTIAL-LISTENKEY-REDACTION-STATUS
- V080-009-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
- V080-009-NO-TESTNET-ORDER-ROUTING
- V080-009-NO-PRODUCTION-CUTOVER
- GH-815 Release v0.8.0 Dashboard Testnet Read-only Monitor Validation
- testGH815DashboardTestnetReadOnlyMonitorSurfaceShowsFreshnessLifecycleAndRedactionWithoutCommands
- testGH815DashboardTestnetReadOnlyMonitorSurfaceIsAnchoredInV080Guards
- Dashboard evidence: shows account snapshot freshness, private stream freshness, listenKey open / observe / close lifecycle, last observed event, stale / disconnected / recovered state, and credential / listenKey redaction status.
- dependency boundary: Dashboard target consumes Dashboard-safe read model fields and does not depend on DataClient, DataClient runtime object, endpoint transport, credential provider, or raw proof payload.
- command boundary: `tradingButtonVisible=false`、`orderFormVisible=false`、`liveCommandEnabled=false`、`orderSubmitVisible=false`、`orderCancelVisible=false`、`orderReplaceVisible=false` and `testnetOrderRoutingAllowed=false`.
- forbidden scope: no credential value display, no raw listenKey display, no raw private payload display, no production trading, no production secret read, no production endpoint / broker connection, no testnet order submission, no real order, no production cutover.

## TVM-RELEASE-V080-RISK-POLICY-PROFILE-MANAGEMENT

- TVM-RELEASE-V080-RISK-POLICY-PROFILE-MANAGEMENT
- GH-816-VERIFY-V080-RISK-POLICY-PROFILE-MANAGEMENT
- V080-010-RISK-POLICY-PROFILE-MANAGEMENT
- V080-010-RISK-POLICY-JSON-VERSION-HASH
- V080-010-DETERMINISTIC-POLICY-DIFF
- V080-010-OPERATOR-CHANGE-METADATA
- V080-010-RUN-APPLICATION-POLICY-REFERENCE
- V080-010-CLI-SHOW-VALIDATE-DIFF
- V080-010-NO-BROKER-ENDPOINT-OMS-ORDER-PATH
- GH-816 Release v0.8.0 Risk Policy Profile Management Validation
- testGH816RiskPolicyProfilesVersionHashDiffAndRunApplicationEvidence
- profile evidence: records local `risk_policy.json` version, deterministic policy hash, operator change metadata, allowed symbols / product types, and applied run IDs.
- diff evidence: shows deterministic changed fields for profile version, max notional, max exposure, and applied run IDs.
- CLI evidence: `risk-policy show`、`risk-policy validate` and `risk-policy diff` expose local read-only profile state without reading secret values or connecting endpoint transports.
- forbidden scope: no broker enablement, no production endpoint, no OMS bypass, no order command path, no testnet order routing, no production trading, no production secret read, no real order, no production cutover.

## TVM-RELEASE-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW

- TVM-RELEASE-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW
- GH-817-VERIFY-V080-PORTFOLIO-RECONCILIATION-REVIEW-WORKFLOW
- V080-011-RECONCILIATION-STATUS-MATCHED-DELTA-MISSING-STALE
- V080-011-REVIEW-REQUIRED-OPERATOR-NOTE-ACK
- V080-011-STALE-OBSERVED-STATE
- V080-011-AUDIT-TRAIL-ARTIFACTS
- V080-011-NO-CORRECTION-COMMAND-BROKER-WRITE
- V080-011-PORTFOLIO-REVIEW-WORKFLOW
- GH-817 Release v0.8.0 Portfolio Reconciliation Review Workflow Validation
- testGH817PortfolioReconciliationReviewWorkflowRequiresAuditOnlyAcknowledgement
- review evidence: maps GH-790 read-only reconciliation diffs into matched / delta / missing / stale statuses and review_required rows.
- acknowledgement evidence: records operator_note, acknowledged_at and acknowledged_by as audit-only metadata.
- audit trail evidence: creates local reconciliation-review artifact paths for every reviewed diff without command side effects.
- forbidden scope: no correction command, no broker write, no account mutation, no trading adjustment, no testnet order routing, no production trading, no production secret read, no production endpoint / broker connection, no real order, no production cutover.

## TVM-RELEASE-V080-DASHBOARD-SAFE-LOCAL-CONTROLS

- TVM-RELEASE-V080-DASHBOARD-SAFE-LOCAL-CONTROLS
- GH-818-VERIFY-V080-DASHBOARD-SAFE-LOCAL-CONTROLS
- V080-012-DASHBOARD-SAFE-LOCAL-CONTROLS
- V080-012-START-STOP-RECOVER-ARCHIVE-OPEN-DETAIL
- V080-012-RUN-REGISTRY-SESSION-STORE-BINDING
- V080-012-LOCAL-ARTIFACT-MUTATION-ONLY
- V080-012-DETAIL-READONLY-SNAPSHOT
- V080-012-NO-ORDER-PRODUCTION-COMMAND
- V080-012-NO-TRADING-BUTTON-ORDER-FORM
- V080-012-NO-TESTNET-ORDER-ROUTING
- V080-012-NO-PRODUCTION-CUTOVER
- GH-818 Release v0.8.0 Dashboard Safe Local Controls Validation
- testGH818DashboardSafeLocalControlsBindSessionStoresWithoutCommands
- testGH818DashboardSafeLocalControlsSurfaceIsAnchoredInV080Guards
- control evidence: records start, stop, recover, archive and open-detail controls as Dashboard-safe local store bindings.
- store evidence: binds controls to local RunRegistryStore and OperationalRunSessionStore paths including `registry.json`, `session.json`, `session_events.jsonl`, `session_status.json`, `operator-session-store.json` and `dashboard-readonly-snapshot.json`.
- mutation evidence: start / stop / recover / archive only affect local run artifacts; open-detail reads registry / session status and readonly snapshot without session lifecycle write.
- command boundary: `orderSubmitVisible=false`、`orderCancelVisible=false`、`orderReplaceVisible=false`、`testnetOrderRoutingAllowed=false`、`productionCommandEnabled=false` and `productionCutoverAuthorized=false`.
- forbidden scope: no credential value display, no raw listenKey display, no raw private payload display, no DataClient Dashboard dependency, no broker command, no testnet order routing, no production trading, no production secret read, no production endpoint / broker connection, no real order, no production cutover.

## TVM-RELEASE-V081-DASHBOARD-MACOS-V080-GUARDS

- TVM-RELEASE-V081-DASHBOARD-MACOS-V080-GUARDS
- GH-836-VERIFY-V081-DASHBOARD-MACOS-V080-GUARDS
- V081-002-DASHBOARD-MACOS-V080-GUARDS
- V081-002-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
- V081-002-NO-PRODUCTION-CUTOVER
- GH-836 Release v0.8.1 Dashboard macOS v0.8 Focused Guard Validation
- testGH836DashboardMacOSChecksRunV080FocusedGuards
- workflow evidence: required `dashboard-macos` job runs `checks/verify-v0.8.1-dashboard-macos-v080-guards.sh` before Dashboard build / smoke.
- coverage evidence: focused guard runs `checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh` and `checks/verify-v0.8.0-dashboard-safe-local-controls.sh`.
- forbidden scope: no UI trading command, no order form, no live command, no broker command, no production command, no testnet order routing, no production trading, no production secret read, no production endpoint / broker connection, no real order, no production cutover.

## TVM-RELEASE-V081-CLI-VERIFY-V080-WORDING

- TVM-RELEASE-V081-CLI-VERIFY-V080-WORDING
- GH-837-VERIFY-V081-CLI-VERIFY-V080-WORDING
- V081-003-CLI-VERIFY-V080-WORDING
- V081-003-HISTORICAL-V070-GUARDS
- V081-003-NO-PRODUCTION-CUTOVER
- GH-837 Release v0.8.1 CLI Verify v0.8.0 Wording Validation
- testGH837TopLevelCLIVerifyUsesV080ReleaseVerificationWording
- CLI evidence: `mtpro verify` prints `mtpro verify v0.8.0`, `issue=GH-820`, `validationAnchor=TVM-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK` and `verificationAnchor=GH-820-VERIFY-V080-FINAL-AUDIT-DOCS-RUNBOOK`.
- historical evidence: v0.7 focused CLI checks remain visible only through `historicalV070Checks=verify-v0.7.0-contract,verify-v0.7.0-testnet-endpoint-policy,verify-v0.7.0-cli`.
- forbidden scope: no runtime behavior change, no network call, no production trading, no production secret read, no production endpoint / broker connection, no testnet or production order, no production cutover.

## TVM-RELEASE-V081-LOCAL-VS-BROKER-SESSION

- TVM-RELEASE-V081-LOCAL-VS-BROKER-SESSION
- GH-838-VERIFY-V081-LOCAL-VS-BROKER-SESSION
- V081-004-LOCAL-SESSION-CREATED
- V081-004-BROKER-SESSION-NOT-STARTED
- V081-004-NO-AMBIGUOUS-SESSION-STARTED-FIELD
- V081-004-NO-ENDPOINT-BROKER-ORDER-PATH
- GH-838 Release v0.8.1 Local vs Broker Session Wording Validation
- testGH838TopLevelCLIRunSeparatesLocalSessionCreatedFromBrokerSessionStarted
- CLI evidence: `mtpro run --mode dry-run` prints `localSessionCreated=true` for local operator artifacts and `brokerSessionStarted=false` for broker connectivity.
- wording guard: `sessionStarted=false` is forbidden in CLI source and run output because it does not distinguish local operator session state from broker session state.
- forbidden scope: no broker session start, no endpoint connection, no ExecutionClient / OMS handoff, no testnet order routing, no production trading, no production secret read, no production endpoint / broker connection, no real order, no production cutover.

## TVM-RELEASE-V081-STATUS-ARTIFACT-ROLE

- TVM-RELEASE-V081-STATUS-ARTIFACT-ROLE
- GH-839-VERIFY-V081-STATUS-ARTIFACT-ROLE
- GH-839 Release v0.8.1 Status Artifact Role Validation
- testGH839TopLevelCLIStatusArtifactRolesAreExplicit
- canonical status artifact: `status.json` is the v0.8+ operator status artifact and is the path exposed as `statusJSONPath` in `manifest.json`.
- compatibility artifact: `_RUN_STATUS.json` remains a compatibility run-status mirror for v0.6/v0.7 artifact readers and is exposed as `runStatusJSONPath` in `manifest.json`.
- CLI evidence: `mtpro run --mode dry-run` and `mtpro status <runID>` both print `statusArtifactRole=status.json=canonical-v0.8;_RUN_STATUS.json=compatibility-run-status-mirror`.
- forbidden scope: no artifact deletion migration, no broker/order behavior change, no endpoint connection, no ExecutionClient / OMS handoff, no testnet order routing, no production trading, no production secret read, no production endpoint / broker connection, no real order, no production cutover.

## TVM-RELEASE-V081-PRIVATE-STREAM-REDACTION

- TVM-RELEASE-V081-PRIVATE-STREAM-REDACTION
- GH-840-VERIFY-V081-PRIVATE-STREAM-REDACTION
- V081-006-PRIVATE-STREAM-REDACTED-URL-HASH
- V081-006-NO-LISTENKEY-REFERENCE-IN-STREAM-URL
- V081-006-NO-NETWORK-SECRET-ORDER-PATH
- GH-840 Release v0.8.1 Private Stream Redaction Validation
- testGH814ManualBinanceTestnetPrivateStreamMonitoringProofIsRedactedAndNoOrder
- redaction evidence: GH-814 proof artifact stores `listenKeyReferenceHash` and emits `redactedStreamURL` as `<redacted-listen-key>` placeholder plus stable hash only.
- leakage guard: `redactedStreamURL` must not contain raw listenKey, `listenKeyReference`, `redactedListenKeyReference` or `listen-key:` marker.
- forbidden scope: no network connection in CI, no secret read, no private WebSocket runtime enablement, no endpoint connection, no ExecutionClient / OMS handoff, no testnet order routing, no production trading, no production secret read, no production endpoint / broker connection, no real order, no production cutover.

## TVM-RELEASE-V081-PATCH-CLOSEOUT

- TVM-RELEASE-V081-PATCH-CLOSEOUT
- GH-841-VERIFY-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES
- GH-841-RELEASE-V081-PATCH-AUDIT-DOCS-RELEASE-NOTES
- V081-007-PATCH-EVIDENCE-CHAIN
- V081-007-PATCH-AUDIT
- V081-007-PATCH-RELEASE-NOTES
- V081-007-QUEUE-CLOSURE-STATE
- V081-007-NO-RELEASE-TAG-CREATION
- V081-007-NO-PRODUCTION-CUTOVER
- GH-841 Release v0.8.1 Patch Audit / Docs / Release Notes Validation
- aggregate evidence: `checks/verify-v0.8.1.sh` runs all v0.8.1 focused guards and checks patch audit / release notes / latest verification summary anchors.
- queue evidence: GH-835..GH-840 are documented as completed before #841 closure PR; #841 PR must pass required `checks` before issue closure.
- forbidden scope: no release tag creation, no GitHub Release creation, no v0.9.0 execution, no production trading, no production secret read, no production endpoint / broker connection, no testnet or production order, no production cutover.

## TVM-RELEASE-V080-VALIDATION-LANES

- TVM-RELEASE-V080-VALIDATION-LANES
- GH-819-VERIFY-V080-VALIDATION-LANES
- V080-013-VALIDATION-LANES
- V080-013-DETERMINISTIC-CI-PROOF-LANE
- V080-013-MANUAL-OPERATOR-NETWORK-PROOF-LANE
- V080-013-WORKFLOW-DISPATCH-OPERATOR-CONFIRMATION
- V080-013-REDACTED-PROOF-ARTIFACTS
- V080-013-CI-NO-SECRET-NO-NETWORK
- V080-013-MANUAL-NO-ORDER-SUBMISSION
- V080-013-NO-PRODUCTION-CUTOVER
- GH-819 Release v0.8.0 Validation Lanes Split Validation
- testGH819ValidationLanesSeparateDeterministicCIAndManualOperatorNetworkProof
- Deterministic CI lane commands: `bash checks/verify-v0.8.0-manual-testnet-signed-account-proof.sh`、`bash checks/verify-v0.8.0-manual-testnet-private-stream-monitoring.sh`、`bash checks/verify-v0.8.0-dashboard-testnet-readonly-monitor.sh`、`bash checks/verify-v0.8.0-dashboard-safe-local-controls.sh`
- CI evidence: required checks and workflow_dispatch run the same no-secret / no-network deterministic guards, using mock source artifacts and redaction assertions only.
- manual evidence: operator network proof requires explicit confirmation, credential reference and manual proof reference, then stores only redacted signed account / private stream summary artifacts.
- command boundary: `ordersSubmitted=false`、`testnetOrderSubmissionAllowed=false`、`testnetOrderRoutingAllowed=false`、`testnetCancelReplaceAllowed=false` and `productionCutoverAuthorized=false`.
- forbidden scope: no production trading, no production secret read, no production endpoint / broker connection, no testnet order submission, no real order, no production cutover.

## TVM-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK

- TVM-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK
- GH-820-VERIFY-V080-FINAL-AUDIT-DOCS-RUNBOOK
- GH-820-RELEASE-V080-FINAL-AUDIT-DOCS-RUNBOOK
- V080-014-VALIDATION-SUMMARY
- V080-014-STAGE-CODE-AUDIT
- V080-014-RELEASE-NOTES
- V080-014-OPERATOR-RUNBOOK
- V080-014-ROOT-DOCS-REFRESH
- V080-014-AGGREGATE-VERIFY
- V080-014-NO-PRODUCTION-CUTOVER
- GH-820 Release v0.8.0 Final Audit / Docs / Runbook Validation
- `bash checks/verify-v0.8.0.sh`
- focused test: `testGH820ReleaseV080FinalAuditDocsRunbookCloseCompletedFactsOnly`
- audit docs: `docs/audit/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-stage-code-audit.md`
- release notes: `docs/release/mtpro-release-v0.8.0-persistent-operator-runtime-testnet-read-only-monitoring-notes.md`
- operator runbook: `docs/operators/release-v0.8.0-operator-persistent-runtime-testnet-readonly-monitoring-runbook.md`
- root docs refresh: latest completed release construction scope must be v0.8.0 and Project Closure Count must be `42 / 42 (100%)`
- forbidden scope: GH-820 construction closeout did not publish a tag; v0.8.0 was later published through a separate stable GitHub Release gate. no next Project / Issue, no production cutover, no production secret read, no production endpoint / broker connection, no testnet or production submit / cancel / replace order

## 使用规则

- Matrix ID 是稳定锚点；`checks/automation-readiness.sh` 和 TargetGraphTests 会检查这些字符串。
- `bash checks/run.sh` 是统一验证入口；本文档不引入独立 eval 框架。
- production cutover 仍需独立授权；production trading disabled by default。

## Required Matrix Anchors

- MTP-24
- MTP-25
- MTP-26
- MTP-27
- MTP-28
- MTP-29
- MTP-30
- MTP-30 阶段收口
- MTP-31
- MTP-32
- MTP-33
- MTP-34
- MTP-35
- MTP-36
- MTP-37
- MTP-37 Paper Session Runtime 阶段收口
- MTP-38
- MTP-39
- MTP-40
- MTP-41
- MTP-42
- MTP-43
- MTP-44
- MTP-45
- MTP-45 Paper Execution Workflow 阶段收口
- MTP-46
- MTP-47
- MTP-48
- MTP-49
- MTP-50
- MTP-51
- MTP-52
- MTP-53
- MTP-53 Paper Workflow Control Shell 阶段收口
- MTP-54
- MTP-55
- MTP-56
- MTP-57
- MTP-58
- MTP-59
- MTP-60
- MTP-60 Market Data Replay Operations 阶段收口
- MTP-61
- MTP-62
- MTP-63
- MTP-64
- MTP-65
- MTP-66
- MTP-67
- MTP-67 Live Trading Boundary Definition 阶段收口
- MTP-68
- MTP-68 issue backfill
- MTP-69
- MTP-70
- MTP-71
- MTP-72
- MTP-73
- MTP-74
- MTP-74 Live Monitoring Console 阶段收口
- MTP-75
- MTP-76
- MTP-77
- MTP-78
- MTP-79
- MTP-80
- MTP-81
- MTP-81 Live Execution Control Contract 阶段收口
- MTP-82
- MTP-82 Live Risk Gate 候选矩阵入口
- MTP-82 issue backfill
- MTP-83
- MTP-83 已回填 exposure / order notional gates
- MTP-83-FORBIDDEN-ACCOUNT-POSITION-MARGIN-LEVERAGE-TESTS
- MTP-84
- MTP-84 已定义 frequency / loss / drawdown future gates
- MTP-84-FREQUENCY-LOSS-DRAWDOWN-FUTURE-GATES
- MTP-85
- MTP-85 已定义 circuit breaker / no-trade state future gates
- MTP-85-CIRCUIT-BREAKER-NO-TRADE-FUTURE-GATES
- MTP-86
- MTP-86 已定义 paper risk blocker / paper exposure
- MTP-86-PAPER-RISK-LIVE-DECISION-ISOLATION-CONTRACT
- MTP-87
- MTP-87 已把 `LiveRiskGateBlockedEvidence` 接入 Dashboard / Report / Event Timeline
- MTP-88
- MTP-88 Live Risk Gate Contract 阶段收口
- MTP-89
- MTP-89 Live Audit Incident Stop 候选矩阵入口
- MTP-89 issue backfill
- MTP-90
- MTP-90 / MTP-91 issue backfill
- MTP-90 issue backfill
- MTP-91
- MTP-91 issue backfill
- MTP-92
- MTP-92 issue backfill
- MTP-93
- MTP-93 issue backfill
- MTP-94
- MTP-94 issue backfill
- MTP-95
- MTP-95 Live Audit Incident Stop Boundary 阶段收口
- MTP-95-LIVE-AUDIT-INCIDENT-STOP-VALIDATION-EVIDENCE-CHAIN
- MTP-96
- MTP-96 issue backfill
- MTP-97
- MTP-97 issue backfill
- MTP-98
- MTP-98 issue backfill
- MTP-99
- MTP-99 issue backfill
- MTP-100
- MTP-100 issue backfill
- MTP-101
- MTP-101 issue backfill
- MTP-102
- MTP-102 issue backfill
- MTP-103
- MTP-103 issue backfill
- MTP-104
- MTP-104 issue backfill
- MTP-105
- MTP-105 issue backfill
- MTP-106
- MTP-106 issue backfill
- MTP-107
- MTP-107 issue backfill
- MTP-108
- MTP-108 issue backfill
- MTP-109
- MTP-109 Data Catalog / Scenario Replay 阶段收口
- MTP-109 issue backfill
- MTP-110
- MTP-110 issue backfill
- MTP-111
- MTP-111 issue backfill
- MTP-112
- MTP-112 issue backfill
- MTP-113
- MTP-113 issue backfill
- MTP-114
- MTP-114 issue backfill
- MTP-115
- MTP-115 issue backfill
- MTP-116
- MTP-116 issue backfill
- MTP-117
- MTP-117 Simulated Exchange / Backtest Parity 阶段收口
- MTP-117 issue backfill
- MTP-118
- MTP-118 issue backfill
- MTP-119
- MTP-119 issue backfill
- MTP-120
- MTP-120 issue backfill
- MTP-121
- MTP-121 issue backfill
- MTP-122
- MTP-122 issue backfill
- MTP-123
- MTP-123 issue backfill
- MTP-124
- MTP-124 issue backfill
- MTP-125
- MTP-125 issue backfill
- MTP-126
- MTP-126 issue backfill
- MTP-127
- MTP-127 issue backfill
- MTP-128
- MTP-128 issue backfill
- MTP-129
- MTP-129 issue backfill
- MTP-130
- MTP-130 issue backfill
- MTP-131
- MTP-131 issue backfill
- MTP-132
- MTP-132 issue backfill
- MTP-133
- MTP-133 issue backfill
- MTP-134
- MTP-134 issue backfill
- MTP-135
- MTP-135 issue backfill
- MTP-136
- MTP-136 issue backfill
- MTP-137
- MTP-137 issue backfill
- MTP-138
- MTP-138 issue backfill
- MTP-139
- MTP-139 Account / Position / Balance 阶段收口
- MTP-139 issue backfill
- MTP-140
- MTP-140 issue backfill
- MTP-141
- MTP-141 issue backfill
- MTP-142
- MTP-142 issue backfill
- MTP-143
- MTP-143 issue backfill
- MTP-144
- MTP-144 issue backfill
- MTP-145
- MTP-145 issue backfill
- MTP-146
- MTP-146 Private Stream / Account Snapshot 阶段收口
- MTP-146 issue backfill
- MTP-147
- MTP-147 issue backfill
- MTP-148
- MTP-148 issue backfill
- MTP-149
- MTP-149 issue backfill
- MTP-150
- MTP-150 issue backfill
- MTP-151
- MTP-151 issue backfill
- MTP-152
- MTP-152 issue backfill
- MTP-153
- MTP-153 Live Monitoring v2 阶段收口
- MTP-153 issue backfill
- MTP-154
- MTP-154 issue backfill
- MTP-155
- MTP-155 issue backfill
- MTP-156
- MTP-156 issue backfill
- MTP-157
- MTP-157 issue backfill
- MTP-158
- MTP-158 issue backfill
- MTP-159
- MTP-159 issue backfill
- MTP-160
- MTP-160 issue backfill
- MTP-161
- MTP-161 Strategy / Trader Readiness 阶段收口
- MTP-161 issue backfill
- MTP-162
- MTP-162 issue backfill
- MTP-163
- MTP-163 issue backfill
- MTP-164
- MTP-164 issue backfill
- MTP-165
- MTP-165 issue backfill
- MTP-166
- MTP-166 issue backfill
- MTP-167
- MTP-167 issue backfill
- MTP-168
- MTP-168 issue backfill
- MTP-169
- MTP-169 issue backfill
- MTP-170
- MTP-170 issue backfill
- MTP-171
- MTP-171 issue backfill
- MTP-172
- MTP-172 issue backfill
- MTP-173
- MTP-173 issue backfill
- MTP-174
- MTP-174 issue backfill
- MTP-175
- MTP-175 issue backfill
- MTP-176
- MTP-176 issue backfill
- MTP-177
- MTP-177 issue backfill
- MTP-178
- MTP-178 issue backfill
- MTP-179
- MTP-179 issue backfill
- MTP-180
- MTP-180 issue backfill
- MTP-181
- MTP-181 issue backfill
- MTP-182
- MTP-182 issue backfill
- MTP-183
- MTP-183 issue backfill
- MTP-184
- MTP-184 issue backfill
- MTP-185
- MTP-185 issue backfill
- MTP-186
- MTP-186 issue backfill
- MTP-187
- MTP-187 issue backfill
- MTP-188
- MTP-188 issue backfill
- MTP-189
- MTP-189 issue backfill
- MTP-190
- MTP-190 Target Module Source Migration 阶段收口
- MTP-190 issue backfill
- MTP-191
- MTP-191 issue backfill
- MTP-192
- MTP-192 issue backfill
- MTP-193
- MTP-193 issue backfill
- MTP-194
- MTP-194 issue backfill
- MTP-195
- MTP-195 issue backfill
- MTP-196
- MTP-196 issue backfill
- MTP-197
- MTP-197 issue backfill
- MTP-198
- MTP-198 issue backfill
- MTP-199
- MTP-200
- MTP-201
- MTP-202
- MTP-203
- MTP-204
- MTP-205
- MTP-205 issue backfill
- MTP-206
- MTP-206 issue backfill
- MTP-207
- MTP-207 issue backfill
- MTP-208
- MTP-208 issue backfill
- MTP-209
- MTP-209 issue backfill
- MTP-210
- MTP-210 issue backfill
- MTP-211
- MTP-211 issue backfill
- MTP-216
- MTP-216 issue backfill
- MTP-217
- MTP-217 issue backfill
- MTP-218
- MTP-218 issue backfill
- MTP-219
- MTP-219 issue backfill
- MTP-220
- MTP-220 issue backfill
- MTP-221
- MTP-221 issue backfill
- MTP-222
- MTP-222 issue backfill
- MTP-223
- MTP-223 issue backfill
- MTP-224
- MTP-224 issue backfill
- MTP-225
- MTP-225 issue backfill
- MTP-226
- MTP-226 issue backfill
- MTP-227
- MTP-227 issue backfill
- MTP-228
- MTP-228 issue backfill
- MTP-229
- MTP-229 issue backfill
- MTP-230
- MTP-230 issue backfill
- MTP-231
- MTP-231 issue backfill
- MTP-231 退休 final active
- MTP-232
- MTP-232 issue backfill
- MTP-232 新增
- GH-452
- GH-453
- GH-454
- GH-455
- GH-456
- GH-457
- GH-458
- GH-459
- GH-460
- GH-461
- GH-462
- GH-463
- GH-464
- GH-465
- GH-466
- GH-467
- GH-468
- GH-469
- GH-470
- GH-471
- GH-472
- GH-503
- GH-503..GH-510
- GH-503..GH-510 issue backfill
- GH-504
- GH-505
- GH-506
- GH-507
- GH-508
- GH-509
- GH-510
- GH-521
- GH-521..GH-541
- GH-522
- GH-523
- GH-524
- GH-525
- GH-526
- GH-527
- GH-528
- GH-529
- GH-530
- GH-531
- GH-532
- GH-533
- GH-534
- GH-535
- GH-536
- GH-537
- GH-538
- GH-539
- GH-540
- GH-541
- GH-563
- GH-563..GH-596
- GH-563..GH-596 issue backfill
- `GH-563`
- GH-564
- `GH-564`
- GH-565
- `GH-565`
- GH-566
- `GH-566`
- GH-567
- `GH-567`
- GH-568
- `GH-568`
- GH-569
- `GH-569`
- GH-570
- `GH-570`
- GH-571
- `GH-571`
- GH-572
- `GH-572`
- GH-573
- `GH-573`
- GH-574
- `GH-574`
- GH-575
- `GH-575`
- GH-576
- `GH-576`
- GH-577
- `GH-577`
- GH-578
- `GH-578`
- GH-579
- `GH-579`
- GH-580
- `GH-580`
- GH-581
- `GH-581`
- GH-582
- `GH-582`
- GH-583
- `GH-583`
- GH-584
- `GH-584`
- GH-585
- `GH-585`
- GH-586
- `GH-586`
- GH-587
- `GH-587`
- GH-588
- `GH-588`
- GH-589
- `GH-589`
- GH-590
- `GH-590`
- GH-591
- GH-592
- `GH-592`
- GH-593
- `GH-593`
- GH-594
- `GH-594`
- GH-595
- `GH-595`
- GH-596
- `GH-596`
- GH-631
- GH-632
- GH-633
- GH-634
- GH-635
- GH-636
- GH-643
- GH-644
- GH-645
- GH-646
- GH-647
- GH-648
- GH-649
- GH-657
- GH-657..GH-670
- GH-658
- GH-659
- GH-660
- GH-661
- GH-662
- GH-663
- GH-664
- GH-665
- GH-666
- GH-667
- GH-668
- GH-669
- GH-670
- GH-694
- GH-694..GH-709
- GH-695
- GH-696
- GH-697
- GH-698
- GH-699
- GH-700
- GH-701
- GH-702
- GH-703
- GH-704
- GH-705
- GH-706
- GH-707
- GH-708
- GH-709
- GH-726
- GH-726..GH-739
- GH-727
- GH-728
- GH-729
- GH-730
- GH-731
- GH-732
- GH-733
- GH-734
- GH-735
- GH-736
- GH-737
- GH-738
- GH-739
- Account / Portfolio read-model boundary
- AccountPositionBalanceReadModelOnlyFixtureContract
- AccountPositionBalanceReadModelOnlySurfaceReadModel
- BinanceMarketDataBatchReplayBoundary
- BinanceMarketDataBatchReplayConsistencyEvidence
- BinanceMarketDataBatchReplayContract
- BinanceMarketDataBatchReplayDeterministicParity
- BinanceMarketDataReplayBatchFreshnessSummary
- BinanceMarketDataReplayFreshnessEvidenceReadModel
- BinanceMarketDataReplayOperationsMetadata
- BinanceMarketDataReplayRetentionPolicy
- Cache runtime-derived state
- DashboardShellReadModelSurfaceSnapshot
- DataClient venue adapter boundary
- DataEngine ingest / replay / quality
- Database durable facts / snapshots / projections
- EMA-only Trader strategy layout contract
- ExecutionClient future-gated boundary
- ExecutionEngine paper / simulated lifecycle boundary
- Future Live PRO Console product-surface split
- L4 planning input material
- Live PRO Console、trading button 或 live command
- LiveAuditTrailFutureGateBoundary
- LiveBlockedEvidenceIncidentStopIsolationBoundary
- LiveIncidentReplayFutureGateBoundary
- LiveIncidentStopBlockedEvidence
- LiveMonitoringConnectionReadinessExplanationContract
- LiveMonitoringForbiddenCapabilityTestContract
- LiveMonitoringReadOnlyConsoleV2SurfaceReadModel
- LiveMonitoringSimulationGateHealthContract
- LiveMonitoringSourceIdentityContract
- LiveStopShutdownRestoreFutureGateBoundary
- LiveTradingBlockedEvidenceReadModel
- LiveTradingCredentialEndpointBoundary
- LiveTradingCredentialEndpointCapability
- LiveTradingCredentialEndpointEvidenceKind
- LiveTradingCredentialEndpointFutureGate
- MarketDataReplayOperationsEvidenceReadModel
- MarketDataReplayOperationsEvidenceViewModel
- MarketDataReplayProjectionConsistency
- MarketDataReplayProjectionSnapshotConsistencySummary
- MessageBus facts / commands / events / request-response
- PaperSessionLocalControlCommand
- PaperSessionLocalControlEventLogBoundary
- PaperWorkflowDashboardInformationArchitecture
- PaperWorkflowEvidenceExplorerSection.liveTradingBlockedEvidence
- PaperWorkflowEvidenceExplorerSection.marketDataReplayOperation
- RiskEngine pre-execution boundary
- Strategies / Trader no-direct-execution guard
- Strategies lifecycle and proposal boundary
- TVM-ACCOUNT-POSITION-BALANCE-READ-MODEL-ONLY
- TVM-ARCHITECTURE-MODULE-BOUNDARY
- TVM-CEFR-DATAENGINE-SCENARIO-QUALITY-OWNERSHIP
- TVM-CEFR-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT
- TVM-CEFR-FINAL-ENVELOPE-RETIREMENT-CONTRACT
- TVM-CEFR-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY
- TVM-CEFR-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT
- TVM-CEFR-PORTFOLIO-EXECUTION-PARITY-OWNERSHIP
- TVM-DATA-CATALOG-SCENARIO-REPLAY
- TVM-EMA-PARITY
- TVM-FEES-SLIPPAGE
- TVM-FUTURE-ISSUE-BACKFILL
- TVM-L4-AUDIT-TRAIL-INCIDENT-REPLAY
- TVM-L4-CREDENTIAL-ENVIRONMENT-GATE
- TVM-L4-DASHBOARD-LIVEPRO-COMMAND-SPLIT
- TVM-L4-EXECUTION-REPORT-BROKER-FILL-PARSER
- TVM-L4-EXECUTIONCLIENT-SANDBOX-SUBMIT-CANCEL-REPLACE
- TVM-L4-EXECUTIONCLIENT-VENUE-ADAPTER-CONTRACT
- TVM-L4-EXECUTIONENGINE-EXECUTIONCLIENT-SANDBOX-PATH
- TVM-L4-GUARDED-COMMAND-UI-SURFACE
- TVM-L4-KILL-SWITCH-INCIDENT-SHUTDOWN-GATE
- TVM-L4-LIVE-ACCOUNT-READ-MODEL-MAPPING
- TVM-L4-LIVE-PRODUCTION-COMMANDS
- TVM-L4-LIVE-RISKENGINE-PRE-TRADE-GATE
- TVM-L4-OMS-BROKER-PORTFOLIO-RECONCILIATION
- TVM-L4-OMS-LOCAL-ORDER-TRANSITION-EVIDENCE
- TVM-L4-OMS-ORDER-LIFECYCLE-CONTRACT
- TVM-L4-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-READ-ONLY-RUNTIME
- TVM-L4-PRODUCTION-CUTOVER-GATE
- TVM-L4-SANDBOX-VALIDATION-MATRIX-CLOSEOUT
- TVM-L4-SIGNED-ACCOUNT-READ-ONLY-RUNTIME
- TVM-L4-SIGNED-ENDPOINT-PRIVATE-STREAM-BOUNDARY
- TVM-L4-STAGE-AUDIT-INPUT-CLOSEOUT
- TVM-LIVE-AUDIT-INCIDENT-STOP
- TVM-LIVE-EXECUTION-CONTROL
- TVM-LIVE-MONITORING-CONSOLE
- TVM-LIVE-MONITORING-READ-ONLY-CONSOLE-V2
- TVM-LIVE-READ-ONLY-READINESS
- TVM-LIVE-RISK-GATE
- TVM-LIVE-TRADING-FOUNDATION
- TVM-MARKET-DATA-REPLAY-OPERATIONS
- TVM-ORDER-BOOK-IMBALANCE-PARITY
- TVM-PAPER-ACTION-PROPOSAL
- TVM-PAPER-EXECUTION-DECISION
- TVM-PAPER-EXECUTION-WORKFLOW
- TVM-PAPER-ORDER-LIFECYCLE
- TVM-PAPER-RUNTIME-KERNEL
- TVM-PAPER-SESSION-LIFECYCLE
- TVM-PAPER-SESSION-REPLAY
- TVM-PAPER-SIMULATED-FILL
- TVM-PAPER-WORKFLOW-CONTROL-SHELL
- TVM-PCHR-BROKER-SHADOW-DRY-RUN-PROOF
- TVM-PCHR-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE
- TVM-PCHR-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION
- TVM-PCHR-OMS-EVENT-STORE-AUDIT-TRAIL
- TVM-PCHR-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT
- TVM-PCHR-PRODUCTION-ENDPOINT-CONNECTION-GATE
- TVM-PCHR-PRODUCTION-HARDENING-READINESS-CLOSEOUT
- TVM-PORTFOLIO-EXPOSURE
- TVM-PRIVATE-STREAM-ACCOUNT-SNAPSHOT-SIMULATION-GATE
- TVM-PRODUCTION-CUTOVER-READINESS-REAL-BROKER-GATE
- TVM-RELEASE-V010-BINANCE-DRYRUN-TESTNET-VALIDATION
- TVM-RELEASE-V010-BINANCE-EMA-RUNTIME
- TVM-RELEASE-V010-BINANCE-EXECUTIONCLIENT-TESTNET-SCR
- TVM-RELEASE-V010-BINANCE-PRIVATE-STREAM-ACCOUNT-SNAPSHOT
- TVM-RELEASE-V010-BINANCE-PUBLIC-MARKET-DATA-PATH
- TVM-RELEASE-V010-BINANCE-SIGNED-ACCOUNT-READ
- TVM-RELEASE-V010-DASHBOARD-CONTROLLED-COMMAND-SURFACE
- TVM-RELEASE-V010-DASHBOARD-LIVE-MONITORING-SURFACE
- TVM-RELEASE-V010-EMA-PROPOSAL-RUNTIME
- TVM-RELEASE-V010-EXECUTION-REPORT-BROKER-FILL-PARSER
- TVM-RELEASE-V010-EXECUTIONENGINE-OMS-LIFECYCLE
- TVM-RELEASE-V010-FINAL-STAGE-CODE-AUDIT-ROOT-DOCS
- TVM-RELEASE-V010-KILL-SWITCH-NO-TRADE-ROLLBACK
- TVM-RELEASE-V010-NO-DEFAULT-PRODUCTION-TRADING-GUARD
- TVM-RELEASE-V010-OPERATOR-RUNBOOK
- TVM-RELEASE-V010-OWNERSHIP-GAP-RETIREMENT
- TVM-RELEASE-V010-PORTFOLIO-RECONCILIATION-UPDATE-PATH
- TVM-RELEASE-V010-REAL-TARGET-SMOKE-COVERAGE
- TVM-RELEASE-V010-RISKENGINE-PRETRADE-GATE
- TVM-RELEASE-V010-STAGE-AUDIT-INPUT-CLOSEOUT
- TVM-RELEASE-V010-TRADER-RUNTIME-LIFECYCLE
- TVM-RELEASE-V020-AGGREGATE-PORTFOLIO-ATTRIBUTION
- TVM-RELEASE-V020-BINANCE-SPOT-DATAENGINE-CACHE-PATH
- TVM-RELEASE-V020-BINANCE-SPOT-EXECUTIONCLIENT-ADAPTER
- TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY-GUARD
- TVM-RELEASE-V020-BINANCE-SPOT-PERP-EMA-RSI-NTPRO-ALIGNMENT
- TVM-RELEASE-V020-BINANCE-USDM-PERP-DATAENGINE-CACHE-PATH
- TVM-RELEASE-V020-BINANCE-USDM-PERP-EXECUTIONCLIENT-ADAPTER
- TVM-RELEASE-V020-CLI-PRODUCT-SURFACE
- TVM-RELEASE-V020-DASHBOARD-COMMANDGATEWAY-SURFACE
- TVM-RELEASE-V020-EMA-TARGET-EXPOSURE-INTENT
- TVM-RELEASE-V020-EXECUTION-REPORT-BROKER-FILL-PARSER
- TVM-RELEASE-V020-FINAL-STAGE-CODE-AUDIT-ROOT-DOCS
- TVM-RELEASE-V020-PERP-EXECUTION-ALGORITHM
- TVM-RELEASE-V020-PERP-MARK-FUNDING-OI-READ-MODEL
- TVM-RELEASE-V020-PERP-RISK-CHECKS
- TVM-RELEASE-V020-PERPETUAL-PORTFOLIO-PROJECTION
- TVM-RELEASE-V020-PRODUCT-AWARE-CACHE-STATE
- TVM-RELEASE-V020-PRODUCT-AWARE-EVENT-STORE-SCHEMA
- TVM-RELEASE-V020-PRODUCT-AWARE-OMS-STATE-MACHINE
- TVM-RELEASE-V020-PRODUCT-INSTRUMENT-PERPETUAL-DOMAIN-MODEL
- TVM-RELEASE-V020-PROPOSAL-ARBITRATOR
- TVM-RELEASE-V020-RISKENGINE-COMMON-LAYER
- TVM-RELEASE-V020-RSI-TARGET-EXPOSURE-INTENT
- TVM-RELEASE-V020-SPOT-EXECUTION-ALGORITHM
- TVM-RELEASE-V020-SPOT-PERP-GOLDEN-TRACE-CATALOG
- TVM-RELEASE-V020-SPOT-PORTFOLIO-PROJECTION
- TVM-RELEASE-V020-SPOT-RISK-CHECKS
- TVM-RELEASE-V020-SQLITE-DUCKDB-SPOT-PERP-PROJECTIONS
- TVM-RELEASE-V020-STRATEGY-ACTOR-REGISTRY-BINDING
- TVM-RELEASE-V020-TARGET-EXPOSURE-PRODUCT-AWARE-INTENT
- TVM-RELEASE-V020-TRADERSTRATEGIES-EMA-RSI-ROOT
- TVM-RELEASE-V020-TYPED-MESSAGEBUS-ENVELOPE
- TVM-RELEASE-V020-VERIFY-FAST-RELEASE-GATES
- TVM-RELEASE-V030-BINANCE-ADAPTER-REHEARSAL
- TVM-RELEASE-V030-DASHBOARD-CLI-REHEARSAL-SURFACE
- TVM-RELEASE-V030-DATAENGINE-RUNTIME-REHEARSAL-FLOW
- TVM-RELEASE-V030-EVENT-STORE-REHEARSAL-EVIDENCE
- TVM-RELEASE-V030-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE
- TVM-RELEASE-V030-FINAL-STAGE-AUDIT-RELEASE-DOCS
- TVM-RELEASE-V030-KILL-SWITCH-NOTRADE-ROLLBACK-DRILL
- TVM-RELEASE-V030-OPERATOR-REHEARSAL-RUNBOOK
- TVM-RELEASE-V030-PORTFOLIO-PROJECTION-REHEARSAL
- TVM-RELEASE-V030-RISKENGINE-REHEARSAL-GATE
- TVM-RELEASE-V030-RUNTIME-ENVIRONMENT-CONFIG
- TVM-RELEASE-V030-RUNTIME-REHEARSAL-CONTRACT
- TVM-RELEASE-V030-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW
- TVM-RELEASE-V030-VERIFY-VALIDATION-SUITE
- TVM-RELEASE-V040-BINANCE-DRYRUN-EXECUTIONCLIENT-ADAPTER
- TVM-RELEASE-V040-BINANCE-TESTNET-MODE-BOUNDARY
- TVM-RELEASE-V040-DASHBOARD-CLI-UNIFIED-RUN-SURFACE
- TVM-RELEASE-V040-DATAENGINE-MESSAGEBUS-RUNTIME-STEP
- TVM-RELEASE-V040-EVENTSTORE-RUN-JOURNAL
- TVM-RELEASE-V040-EXECUTIONENGINE-OMS-DRYRUN-LIFECYCLE
- TVM-RELEASE-V040-FINAL-STAGE-AUDIT-RELEASE-DOCS
- TVM-RELEASE-V040-OPERATOR-RUNTIME-REHEARSAL-RUNBOOK
- TVM-RELEASE-V040-PORTFOLIO-REPLAY-PROJECTION
- TVM-RELEASE-V040-REHEARSAL-RUN-CONTEXT-ENVELOPE
- TVM-RELEASE-V040-RISKENGINE-PRETRADE-REHEARSAL-GATE
- TVM-RELEASE-V040-RUNTIME-KERNEL-DRY-RUN-ORCHESTRATOR
- TVM-RELEASE-V040-SHADOW-REPLAY-MODE
- TVM-RELEASE-V040-TRADER-STRATEGY-ACTORS-RUNTIME-STEP
- TVM-RELEASE-V040-UNIFIED-RUNTIME-REHEARSAL-PIPELINE-CONTRACT
- TVM-RELEASE-V040-VERIFY-VALIDATION-SUITE
- TVM-RELEASE-V050-BOUNDARY-PREFLIGHT-CONTRACT
- TVM-RELEASE-V050-CI-HARDENING
- TVM-RELEASE-V050-DASHBOARD-CLI-RUN-OBSERVER
- TVM-RELEASE-V050-DATAENGINE-OPERATIONAL-DRY-RUN-PATH
- TVM-RELEASE-V050-DURABLE-LOCAL-RUN-JOURNAL
- TVM-RELEASE-V050-ENVIRONMENT-ENDPOINT-SECRET-POLICY
- TVM-RELEASE-V050-EXECUTION-OMS-DRY-RUN-LIFECYCLE
- TVM-RELEASE-V050-FINAL-AUDIT-RELEASE-DOCS
- TVM-RELEASE-V050-PORTFOLIO-RUN-JOURNAL-PROJECTION
- TVM-RELEASE-V050-PRECISION-INSTRUMENT-CATALOG
- TVM-RELEASE-V050-RISKENGINE-RUNTIME-RUNNER
- TVM-RELEASE-V050-STRICT-CLI-COMMAND-PARSER
- TVM-RELEASE-V050-TESTNET-READONLY-INTEGRATION-GATE
- TVM-RELEASE-V050-TYPED-RUNTIME-MESSAGEBUS
- TVM-RELEASE-V060-BOUNDARY-NO-PRODUCTION-CONTRACT
- TVM-RELEASE-V060-LOCAL-RUN-JOURNAL-WRITER
- TVM-RELEASE-V060-RUN-MANIFEST-CHECKSUM
- TVM-RELEASE-V060-RUNTIME-SHA256-CHECKSUM
- TVM-RELEASE-V060-DATAENGINE-LOCAL-DRY-RUN-RUNNER
- TVM-RELEASE-V060-STRATEGY-RUNTIME-RUNNER
- TVM-RELEASE-V060-RISKENGINE-RUNTIME-RUNNER
- V060-007-RISKENGINE-RUNTIME-RUNNER
- V060-007-STRATEGY-INTENT-TO-RISK-DECISION
- V060-007-ALLOW-REJECT-BLOCKED-POLICY-EVIDENCE
- V060-007-KILL-SWITCH-NO-TRADE-BLOCKS-OMS
- V060-007-SAME-RUN-JOURNAL-RISK-SEQUENCE
- V060-007-NO-RISK-EXECUTION-PATH
- TVM-RELEASE-V060-EXECUTION-OMS-DRY-RUN-RUNNER
- V060-008-EXECUTION-OMS-DRY-RUN-RUNNER
- V060-008-ALLOWED-RISK-TO-OMS-LIFECYCLE
- V060-008-REJECTED-BLOCKED-NO-SUBMIT
- V060-008-SIMULATED-SUBMIT-NOT-REAL
- V060-008-SAME-RUN-JOURNAL-OMS-SEQUENCE
- V060-008-NO-PRODUCTION-OMS-BROKER-PATH
- TVM-RELEASE-V060-PORTFOLIO-JOURNAL-PROJECTION
- V060-009-PORTFOLIO-JOURNAL-PROJECTION
- V060-009-JOURNAL-REPLAY-TO-PROJECTION-JSON
- V060-009-FIXED-POINT-EXPOSURE-NOTIONAL-QUANTITY
- V060-009-MANIFEST-VALIDATED-PROJECTION-ARTIFACT
- V060-009-NO-BROKER-ACCOUNT-PAYLOAD
- TVM-RELEASE-V060-DASHBOARD-CLI-RUN-DETAIL-OBSERVER
- V060-010-DASHBOARD-CLI-RUN-DETAIL-OBSERVER
- V060-010-ARTIFACT-BACKED-RUN-LIST-STATUS-EVENTS-PROJECTION-RISK
- V060-010-DASHBOARD-READS-SAME-MANIFEST-AS-CLI
- V060-010-MANIFEST-CORRUPTION-GAP-STATE
- V060-010-NO-PRODUCTION-COMMAND-SURFACE
- TVM-RELEASE-V060-TESTNET-READONLY-PROBE
- V060-011-TESTNET-READ-ONLY-PROBE
- V060-011-OPERATOR-CONFIRMED-TESTNET-PROFILE
- V060-011-TESTNET-ENDPOINT-ALLOWLIST-PRODUCTION-REJECTION
- V060-011-SIGNED-ACCOUNT-SNAPSHOT-ARTIFACT
- V060-011-CREDENTIAL-REDACTION-DASHBOARD-CLI
- V060-011-PRIVATE-STREAM-SIMULATED-READMODEL-NO-WEBSOCKET
- V060-011-NO-ORDER-NO-PRODUCTION-BOUNDARY
- TVM-REPORT-EVIDENCE
- TVM-RISK-BLOCKER
- TVM-SIMULATED-EXCHANGE-BACKTEST-PARITY
- TVM-STRATEGY-TRADER-INSTANCE-READINESS
- TVM-SWIFTPM-TARGET-GRAPH-MODULE-SPLIT
- TVM-TARGET-MODULE-PHYSICAL-LAYOUT-SOURCE-MIGRATION
- TVM-TARGETGRAPH-ANCHOR-RETIREMENT-REAL-MODULE-SOURCE-ROOT-MIGRATION
- TVM-WORKBENCH-BETA-READINESS
- Trader Accounts / Coordination compatibility consolidation stage closeout
- Trader Accounts / Coordination compatibility contract
- Trader Accounts source boundary
- Trader coordination boundary
- Trader-owned strategies layout correction 阶段收口
- Trading Validation Matrix
- Workbench read-model-only consumption boundary
- adapter capability guard
- bash checks/run.sh
- broker / real order forbidden guard
- docs/audit/inputs/mtpro-live-execution-control-contract-v1-stage-audit-input.md
- docs/audit/inputs/mtpro-live-monitoring-console-v1-stage-audit-input.md
- docs/audit/inputs/mtpro-live-read-only-readiness-boundary-v1-stage-audit-input.md
- docs/audit/inputs/mtpro-paper-execution-workflow-v1-stage-audit-input.md
- docs/audit/inputs/mtpro-paper-session-runtime-v1-stage-audit-input.md
- docs/audit/inputs/mtpro-trading-validation-and-parity-hardening-stage-audit-input.md
- docs/audit/inputs/mtpro-workbench-beta-readiness-v1-stage-audit-input.md
- fixed target source module layout
- old path drift guard
- production cutover
- production release、notarization、App Store distribution、auto-update、production operations
- testBatchReplayBoundaryDefinesPublicReadOnlyLocalFixtureContract
- testBatchReplayConsistencyRejectsMetadataAndNetworkBoundaryDrift
- testBatchReplayConsistencyRejectsRecordCountOrderingAndChecksumDrift
- testBatchReplayContractBindsMetadataToPublicReadOnlyFixtureBoundary
- testBatchReplayFixtureParityBuildsDeterministicReplayConsistencyEvidence
- testBatchReplayFreshnessReadModelIsCodableAndHidesSchemaAdapterRuntimeSurface
- testBatchReplayFreshnessSummaryAggregatesRetentionEvidenceDeterministically
- testBatchReplayMetadataDefinesDeterministicLocalReplayOperationsEvidence
- testBatchReplayRetentionPolicyComputesFreshStaleExpiredEvidence
- testDashboardShellSnapshotBindsViewModelSectionsForReadOnlyMacOSShell
- testLiveAdapterCapabilityIsolationBoundaryDefinesMTP63GateTwoAsFutureOnly
- testLiveAdapterCapabilityIsolationBoundaryRejectsExecutionAdapterInstantiationBypass
- testLiveBlockedEvidenceKeepsMTP65AllLiveGatesBlocked
- testLiveReadinessDefinesMTP65BlockedReadModelOnlyEvidence
- testLiveReadinessRejectsMTP65CommandSchemaAndLiveCapabilityBypass
- testLiveTradingBlockedEvidenceViewModelAggregatesMTP66ReadModelOnlyEvidence
- testLiveTradingCredentialEndpointBoundaryDefinesMTP62GateOneAsFutureOnly
- testLiveTradingCredentialEndpointBoundaryRejectsSecretSignedAccountAndListenKeyBypass
- testMarketDataReplayProjectionConsistencyLinksEventLogReplayAndSnapshots
- testMarketDataReplayProjectionConsistencySummaryIsCodableDeterministicAndHidesSchema
- testPaperOrderFillAndPortfolioEvidenceCannotUpgradeToRealOrderLifecycle
- testPaperWorkflowEvidenceExplorerTimelineSnapshotAggregatesReadModelOnlyEvidence
- testPublicReadOnlyAdapterCannotInstantiateMTP63LiveAdapterOrExecutionVenueCapability
- testPublicReadOnlyAdapterCannotUpgradeIntoMTP62CredentialOrAccountCapability
- testPublicReadOnlyAdapterCannotUpgradeIntoMTP64RealOrderLifecycleCapability
- testRealOrderLifecycleBoundaryDefinesMTP64GateThreeAsFutureOnly
- testRealOrderLifecycleBoundaryRejectsMTP64ForbiddenCapabilityBypass
- validation matrix closeout

## Test Anchor Backfill

- V020-01
- V020-14
- V020-15
- V020-16
- V020-17
- V020-18
- V020-19
- V020-20
- V020-21
- V020-22
- V020-23
- V020-24
- V020-25
- V020-26
- V020-27
- V020-28
- V020-30
- V020-31
- V020-32
- V020-33
- V020-34
- V020-BINANCE-SPOT-PERP-EMA-RSI-AUTOMATION-GUARD
- V020-BINANCE-SPOT-PERP-EMA-RSI-CONTRACT
- V020-OPERATOR-RUNBOOK
- V020-ROOT-DOCS-BOUNDARY-REFRESH
- V020-ROOT-DOCS-REFRESH
- V020-STAGE-CODE-AUDIT
- V030-01-RUNTIME-REHEARSAL-CONTRACT
- V030-02-INVALID-SAME-MODE
- V030-02-UNSAFE-TRANSITION
- V030-12-CLI-REHEARSAL-SMOKE
- V030-12-COMPLETE-REHEARSAL-CHAIN
- V030-12-PRODUCTION-DISABLED-BOUNDARY
- V030-12-VERIFY-RELEASE-VALIDATION-SUITE
- V030-13-OBSERVE-DASHBOARD-CLI-EVIDENCE
- V030-13-PRODUCTION-DISABLED-PROOF
- V030-13-START-REHEARSAL
- V030-13-STOP-REHEARSAL
- V030-RELEASE-VALIDATION-SUITE
- V040-02-FORBIDDEN-PRODUCTION-RUNTIME
- V040-02-MODULE-EVIDENCE-COVERAGE
- V040-02-PRODUCT-STRATEGY-MODE-IDENTITY
- V040-02-REHEARSAL-RUN-CONTEXT
- V040-02-UNIFIED-EVIDENCE-ENVELOPE
- V040-03-FORBIDDEN-NETWORK-SECRET-PRODUCTION
- V040-03-LOCAL-ONLY-DRY-RUN
- V040-03-ONE-RUNID-STEP-ORDER
- V040-03-RUNTIME-KERNEL-DRY-RUN-ORCHESTRATOR
- V040-04-BINANCE-SPOT-PERP-PRODUCT-IDENTITY
- V040-04-DATAENGINE-MESSAGEBUS-RUNTIME-STEP
- V040-04-FORBIDDEN-NETWORK-SECRET-PRODUCTION
- V040-04-RUN-SCOPED-MARKET-EVENTS
- V040-05-EMA-RSI-RUN-SCOPED-INTENTS
- V040-05-MESSAGEBUS-MARKET-CONSUMPTION
- V040-05-NO-STRATEGY-EXECUTIONCLIENT-PATH
- V040-05-TRADER-STRATEGY-ACTORS-RUNTIME-STEP
- V040-06-ALLOW-REJECT-BLOCK-DECISIONS
- V040-06-EXECUTIONENGINE-RISK-APPROVED-ONLY
- V040-06-KILL-SWITCH-NO-TRADE-GUARDS
- V040-06-RISKENGINE-PRETRADE-REHEARSAL-GATE
- V040-07-EXECUTIONENGINE-OMS-DRYRUN-LIFECYCLE
- V040-07-NO-PRODUCTION-BROKER-CALL
- V040-07-RISK-APPROVED-INTENT-TO-LOCAL-ORDER
- V040-07-RUN-SCOPED-OMS-STATE-REPLAY
- V040-08-BINANCE-DRYRUN-EXECUTIONCLIENT-ADAPTER
- V040-08-NETWORK-PRODUCTION-ORDER-BLOCKED
- V040-08-REQUEST-INTENT-REDACTED-REQUEST-ACK
- V040-08-SPOT-PERP-MAPPING-ONLY
- V040-09-BINANCE-TESTNET-MODE-BOUNDARY
- V040-09-EXPLICIT-MODE-OPERATOR-CONFIRMATION
- V040-09-PRODUCTION-FALLBACK-BLOCKED
- V040-09-TESTNET-ONLY-ENDPOINT-ENVIRONMENT
- V040-14-COMPLETE-UNIFIED-RUNTIME-CHAIN
- V040-14-PRODUCTION-DISABLED-BOUNDARY
- V040-14-SHADOW-REPLAY-SMOKE
- V040-14-TESTNET-DISABLED-BY-DEFAULT
- V040-14-VERIFY-RELEASE-VALIDATION-SUITE
- V040-15-FAILURE-ROLLBACK-NOTRADE-PROOF
- V040-15-GUARDED-TESTNET-PROOF
- V040-15-OBSERVE-DASHBOARD-CLI-EVIDENCE
- V040-15-PRODUCTION-DISABLED-PROOF
- V040-15-SHADOW-REPLAY-FLOW
- V040-15-START-REHEARSAL
- V040-15-STOP-REHEARSAL
- V040-RELEASE-VALIDATION-SUITE
- V050-02-HELP-RUN-STATUS-VERIFY-SHAPE
- V050-02-LEGACY-COMMAND-WHITELIST
- V050-02-NO-PRODUCTION-CLI-SIDE-EFFECT
- V050-02-STRICT-CLI-COMMAND-PARSER
- V050-02-UNKNOWN-COMMAND-FAILS-NONZERO
- V050-14-NO-PRODUCTION-CUTOVER
- V050-14-RUN-JOURNAL-OBSERVER
- V050-14-VALIDATION-SUMMARY

## Source Contract Anchor Backfill

- V010-BINANCE-EMA-RUNTIME-CONTRACT
- V020-02
- V020-03
- V020-04
- V020-05
- V020-06
- V020-07
- V020-08
- V020-09
- V020-10
- V020-11
- V020-12
- V020-13
- V020-29
- V020-FULL-GATE-CHAIN
- V030-01-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY
- V030-01-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-AUDITABLE-GATES
- V030-01-FORBIDDEN-PRODUCTION-CAPABILITIES
- V030-01-ONE-COMMAND-REHEARSAL-SUCCESS-CRITERIA
- V030-01-REHEARSAL-MODES
- V030-02-DRYRUN-TESTNET-SHADOW-PRODUCTION-BLOCKED-MODES
- V030-02-INVALID-ENVIRONMENT-TRANSITION-FAIL-CLOSED
- V030-02-NO-PRODUCTION-ENDPOINT-AUTO-CONNECT
- V030-02-NO-PRODUCTION-SECRET-AUTO-READ
- V030-02-RUNTIME-ENVIRONMENT-CONFIG
- V030-02-SAFE-DEFAULT-MODE
- V030-02-TRANSITION-DRYRUN-TO-PRODUCTION-BLOCKED
- V030-02-TRANSITION-DRYRUN-TO-SHADOW
- V030-02-TRANSITION-DRYRUN-TO-TESTNET
- V030-02-TRANSITION-PRODUCTION-BLOCKED-TO-DRYRUN
- V030-02-TRANSITION-SHADOW-TO-PRODUCTION-BLOCKED
- V030-02-TRANSITION-TESTNET-TO-PRODUCTION-BLOCKED
- V030-02-TRANSITION-TESTNET-TO-SHADOW
- V030-03-DATAENGINE-RUNTIME-REHEARSAL-FLOW
- V030-03-NO-PRODUCTION-ENDPOINT-DEPENDENCY
- V030-03-SPOT-REHEARSAL-PRODUCT-IDENTITY
- V030-03-TRACEABLE-DATAENGINE-REHEARSAL-EVIDENCE
- V030-03-USDM-PERP-REHEARSAL-PRODUCT-IDENTITY
- V030-04-EMA-TARGET-EXPOSURE-INTENT-MESSAGEBUS
- V030-04-NO-STRATEGY-EXECUTIONCLIENT-OR-BINANCE-ADAPTER-ACCESS
- V030-04-RSI-TARGET-EXPOSURE-INTENT-MESSAGEBUS
- V030-04-TRACEABLE-TRADER-STRATEGY-REHEARSAL-EVIDENCE
- V030-04-TRADER-STRATEGY-RUNTIME-REHEARSAL-FLOW
- V030-05
- V030-05-ALLOW-REJECT-LIMIT-EVIDENCE
- V030-05-AUDITABLE-RISK-DECISION-EVIDENCE
- V030-05-KILL-SWITCH-NO-TRADE-REJECT-EVIDENCE
- V030-05-MESSAGEBUS-STRATEGY-INTENT-RISK-INPUT
- V030-05-RISKENGINE-REHEARSAL-GATE
- V030-06
- V030-06-EXECUTIONENGINE-OMS-REHEARSAL-LIFECYCLE
- V030-06-ILLEGAL-TRANSITION-REJECTED
- V030-06-OMS-REPLAY-EVIDENCE
- V030-06-OMS-STATE-COVERAGE
- V030-06-RISK-APPROVED-INTENT-TO-OMS
- V030-07
- V030-07-BINANCE-TESTNET-DRYRUN-ADAPTER-REHEARSAL
- V030-07-DRYRUN-EVIDENCE
- V030-07-NO-RAW-BROKER-PAYLOAD-DASHBOARD
- V030-07-PRODUCTION-ENDPOINT-BLOCKED
- V030-07-SUBMIT-CANCEL-REPLACE-MAPPING
- V030-07-TESTNET-EVIDENCE
- V030-08
- V030-08-APPEND-ONLY-REHEARSAL-EVENTS
- V030-08-CORRELATION-CAUSATION-LINKS
- V030-08-EVENT-STORE-REHEARSAL-EVIDENCE
- V030-08-REPLAY-RECONSTRUCTS-KEY-STATE
- V030-08-STRATEGY-RISK-EXECUTION-OMS-PORTFOLIO-CHAIN
- V030-09
- V030-09-EMA-RSI-ATTRIBUTION
- V030-09-NO-PRODUCTION-ACCOUNT-SYNC
- V030-09-PERP-PORTFOLIO-PROJECTION
- V030-09-PORTFOLIO-PROJECTION-REHEARSAL
- V030-09-SPOT-PORTFOLIO-PROJECTION
- V030-10
- V030-10-COMMANDGATEWAY-ROUTING
- V030-10-DASHBOARD-CLI-REHEARSAL-SURFACE
- V030-10-GATE-FAILURE-REASONS
- V030-10-KILL-SWITCH-NO-TRADE-STATUS
- V030-10-RUN-STATUS-SURFACE
- V030-11
- V030-11-BLOCKED-COMMAND-AUDIT
- V030-11-KILL-SWITCH-BLOCKS-COMMANDS
- V030-11-KILL-SWITCH-NO-TRADE-ROLLBACK-DRILL
- V030-11-NO-TRADE-BLOCKS-COMMANDS
- V030-11-ROLLBACK-EVIDENCE
- V040-01
- V040-01-BINANCE-SPOT-PERP-EMA-RSI-BOUNDARY
- V040-01-DASHBOARD-CLI-UNIFIED-RUN-PROJECTION
- V040-01-DRYRUN-SHADOW-TESTNET-GUARDED-SEMANTICS
- V040-01-FORBIDDEN-PRODUCTION-CAPABILITIES
- V040-01-ONE-RUNID-EVIDENCE-CHAIN
- V040-01-UNIFIED-RUNTIME-REHEARSAL-PIPELINE-CONTRACT
- V040-10-APPEND-ONLY-RUN-EVENTS
- V040-10-DASHBOARD-CLI-PROJECTION-REPLAY
- V040-10-EVENTSTORE-RUN-JOURNAL
- V040-10-NO-PRODUCTION-EVENTSTORE-CUTOVER
- V040-10-RUNID-CORRELATION-CAUSATION-REPLAY
- V040-11-DASHBOARD-CLI-RUNID-CONSUMABLE
- V040-11-PORTFOLIO-REPLAY-PROJECTION
- V040-11-READMODEL-ONLY-NO-ACCOUNT-SYNC
- V040-11-REPLAY-DERIVED-POSITIONS-EXPOSURE
- V040-11-SPOT-PERP-PNL-MARGIN-LIKE-METRICS
- V040-12
- V040-12-ADAPTER-PORTFOLIO-PROJECTION-VISIBLE
- V040-12-BLOCKED-REJECTED-STATE-EXPLANATIONS
- V040-12-DASHBOARD-CLI-UNIFIED-RUN-SURFACE
- V040-12-NO-LIVE-COMMAND-SURFACE
- V040-12-ONE-RUNID-PROJECTION-CONSUMPTION
- V040-13
- V040-13-HISTORICAL-DETERMINISTIC-INPUT
- V040-13-NO-NETWORK-BROKER-CALLS
- V040-13-SAME-RUNID-EVIDENCE-CHAIN-SHAPE
- V040-13-SHADOW-IS-NOT-PRODUCTION-APPROVAL
- V040-13-SHADOW-REPLAY-MODE
- V050-01
- V050-01-BINANCE-SPOT-PERP-EMA-RSI-ONLY
- V050-01-DRYRUN-TESTNET-PRODUCTION-BLOCKED-MODES
- V050-01-FORBIDDEN-PRODUCTION-CAPABILITIES
- V050-01-GUARDED-RUNTIME-FOUNDATION
- V050-01-PREFLIGHT-REQUIREMENTS
- V050-01-RELEASE-BOUNDARY-PREFLIGHT-CONTRACT
- V050-03
- V050-03-DRYRUN-NO-SECRET-NO-ENDPOINT
- V050-03-ENVIRONMENT-PROFILE-ENDPOINT-SECRET-POLICY
- V050-03-PRODUCTION-BLOCKED-FAILS-CLOSED
- V050-03-SECRET-PROFILE-REFERENCE-ONLY
- V050-03-TESTNET-HTTPS-ALLOWLIST-POLICY
- V050-04
- V050-04-BINANCE-SPOT-PERP-INSTRUMENT-FILTERS
- V050-04-FIXED-POINT-MONEY-NOTIONAL-EXPOSURE-PRICE-QUANTITY
- V050-04-PRECISION-PRIMITIVES-INSTRUMENT-CATALOG
- V050-04-STRICT-PRODUCTTYPE-PARSING
- V050-05
- V050-05-RUN-CORRELATION-CAUSATION-CHECKSUM
- V050-05-RUNTIME-EVENT-ENVELOPE
- V050-05-TYPED-EVENT-FAMILIES
- V050-05-TYPED-RUNTIME-MESSAGEBUS-ACTOR
- V050-06
- V050-06-APPEND-ONLY-REPLAY-CURSOR
- V050-06-DURABLE-LOCAL-RUN-JOURNAL
- V050-06-LOCAL-RUN-STORAGE-SHAPE
- V050-06-NO-SECRET-ENDPOINT-LEAKAGE
- V050-06-TYPED-RUNTIME-ENVELOPE-PRESERVATION
- V050-07
- V050-07-DATAENGINE-OPERATIONAL-DRY-RUN-PATH
- V050-07-PUBLIC-MARKET-INPUT-DATACLIENT-DATAENGINE
- V050-07-RUN-SCOPED-MESSAGEBUS-CACHE-PROJECTION
- V050-07-TYPED-DATAENGINE-MARKET-EVENTS
- V050-08
- V050-08-EXPLICIT-TESTNET-PROFILE-REQUIRED
- V050-08-PRODUCTION-BLOCKED-REJECTS-READMODEL-RESOLUTION
- V050-08-REDACTED-EVIDENCE-NO-SUBMIT-PROOF
- V050-08-TESTNET-READ-ONLY-INTEGRATION-GATE
- V050-09
- V050-09-KILL-SWITCH-NO-TRADE-BLOCKS
- V050-09-NOTIONAL-EXPOSURE-POLICY-EVIDENCE
- V050-09-RISKENGINE-RUNTIME-RUNNER
- V050-09-RUN-JOURNAL-REPLAYABLE-RISK-DECISIONS
- V050-09-STRATEGY-INTENT-TO-RISK-DECISION
- V050-10
- V050-10-DRY-RUN-EXECUTION-EVENTS
- V050-10-EXECUTION-OMS-DRY-RUN-LIFECYCLE
- V050-10-REJECTED-BLOCKED-RISK-NO-SUBMIT
- V050-10-RISK-DECISION-TO-OMS-LIFECYCLE
- V050-10-RUN-JOURNAL-REPLAYABLE-OMS-EXECUTION
- V050-11
- V050-11-INSTRUMENT-CATALOG-PRECISION-SOURCE
- V050-11-JOURNAL-REPLAY-DERIVED-POSITION-EXPOSURE
- V050-11-NO-BROKER-ACCOUNT-PAYLOAD
- V050-11-PNL-MARGIN-LIKE-REHEARSAL-METRICS
- V050-11-PORTFOLIO-RUN-JOURNAL-PROJECTION
- V050-12
- V050-12-BLOCKED-REJECTED-BOUNDARY-EVIDENCE
- V050-12-DASHBOARD-CLI-RUN-OBSERVER
- V050-12-DASHBOARD-SECTIONS-CONSUME-RUN-JOURNAL
- V050-12-NO-PRODUCTION-COMMAND-SURFACE
- V050-12-RUNID-STATUS-EVENTS-PROJECTION-RISK
- V050-13
- V050-GENESIS
- V060-001
- V060-001-DOWNSTREAM-QUEUE-ORDER
- V060-001-FORBIDDEN-PRODUCTION-CAPABILITIES
- V060-001-LOCAL-OPERATIONAL-RUNTIME-SCOPE
- V060-001-NO-PRODUCTION-ACCEPTANCE-GATE
- V060-001-RELEASE-BOUNDARY-NO-PRODUCTION-CONTRACT
- V060-002
- V060-002-APPEND-ONLY-EVENTS-JSONL
- V060-002-ATOMIC-PROJECTION-SUMMARY-STATUS-MANIFEST
- V060-002-FAILED-INCOMPLETE-NOT-COMPLETED
- V060-002-LOCAL-RUN-JOURNAL-WRITER
- V060-002-MANIFEST-WRITTEN-LAST
- V060-002-RUN-DIRECTORY-SHAPE
- V060-003
- V060-003-MANIFEST-FINAL-COMPLETION-MARKER
- V060-003-MISSING-CORRUPTED-ARTIFACT-REJECTION
- V060-003-REQUIRED-ARTIFACT-METADATA
- V060-003-RUN-MANIFEST-ARTIFACT-CHECKSUM
- V060-003-SHA256-BYTECOUNT-VALIDATION
- V060-004
- V060-004-CHECKSUM-MISMATCH-FAILS-VALIDATION
- V060-004-FNV-COMPATIBILITY-EVIDENCE
- V060-004-JOURNAL-SHA256-CHAIN
- V060-004-NO-PRODUCTION-AUTHORIZATION
- V060-004-RUNTIME-EVENT-SHA256-CHECKSUM
- V060-005
- V060-005-BINANCE-SPOT-USDM-PERP-BOUNDARY
- V060-005-DATAENGINE-LOCAL-DRY-RUN-RUNNER
- V060-005-DATAENGINE-MARKET-EVENT-JOURNAL-WRITE
- V060-005-LOCAL-FIXTURE-CATALOG-ONLY
- V060-005-NO-NETWORK-SECRET-ORDER
- V060-006
- V060-006-DATAENGINE-CAUSAL-LINK
- V060-006-EMA-RSI-INTENT-EVENTS
- V060-006-NO-STRATEGY-EXECUTION-PATH
- V060-006-SAME-RUN-JOURNAL-SEQUENCE
- V060-006-STRATEGY-RUNTIME-RUNNER

## Closeout Anchor Backfill

- GH-631-CEFR-FINAL-ENVELOPE-RETIREMENT-CONTRACT
- GH-631-RETAINED-ENVELOPE-SOURCE-INVENTORY
- GH-631-REAL-MODULE-OWNER-CLASSIFICATION
- GH-631-RETENTION-REASON-AND-EXIT-PATH
- GH-631-FIRST-EXECUTABLE-CANDIDATE-ONLY
- GH-631-NO-PRODUCTION-AUTHORIZATION
- GH-631-VALIDATION-ANCHORS
- GH-632-MESSAGEBUS-RICH-ROUTING-COMPATIBILITY-CONTRACT
- GH-632-CORE-RICH-ROUTING-COMPATIBILITY-ONLY
- GH-632-MESSAGEBUS-OWNED-ROUTING-CLASSIFICATION
- GH-632-DASHBOARD-CLI-BOUNDARY-HELD
- GH-632-NO-PRODUCTION-AUTHORIZATION
- GH-633-DATAENGINE-SCENARIO-QUALITY-OWNERSHIP-CONTRACT
- GH-633-ACTIVE-DATAENGINE-SCENARIO-QUALITY-SOURCES
- GH-633-CORE-DETERMINISTIC-MATCHING-COMPATIBILITY-ONLY
- GH-633-NO-PRODUCTION-AUTHORIZATION
- GH-634-PORTFOLIO-PARITY-OWNERSHIP-CONTRACT
- GH-634-PORTFOLIO-ACTIVE-PROJECTION-SOURCES
- GH-634-EXECUTION-PARITY-OWNERSHIP-CONTRACT
- GH-634-EXECUTION-ACTIVE-SIMULATED-SOURCES
- GH-634-CORE-PORTFOLIO-EXECUTION-PARITY-COMPATIBILITY-ONLY
- GH-634-CORE-PORTFOLIO-PARITY-COMPATIBILITY-ONLY
- GH-634-CORE-EXECUTION-PARITY-COMPATIBILITY-ONLY
- GH-634-NO-PRODUCTION-AUTHORIZATION
- GH-635-PERSISTENCE-RUNTIME-ENVELOPE-RETIREMENT-CONTRACT
- GH-635-PERSISTENCE-ADAPTER-SHIM-ONLY
- GH-635-RUNTIME-WORKFLOW-SHIM-ONLY
- GH-635-PACKAGE-SOURCE-OVERLAP-GUARD
- GH-635-NO-PRODUCTION-AUTHORIZATION
- GH-636-FINAL-ENVELOPE-RETIREMENT-CLOSEOUT
- GH-636-ISSUE-PR-EVIDENCE-CHAIN
- GH-636-REAL-MODULE-OWNER-MAP-COMPLETE
- GH-636-RETAINED-ENVELOPE-SHIM-MATRIX
- GH-636-AUTOMATION-READINESS-CLOSEOUT
- GH-636-NO-PRODUCTION-CUTOVER-AUTHORIZATION
- GH-636-STAGE-CODE-AUDIT-HANDOFF
- GH-707-VERIFY-V040-RELEASE-VALIDATION-SUITE
- PCHR-01-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-NO-BYPASS
- PCHR-01-COMMANDGATEWAY-REQUIRED
- PCHR-01-EVENT-STORE-REQUIRED
- PCHR-01-EXECUTIONENGINE-REQUIRED
- PCHR-01-NO-ENDPOINT-AUTO-CONNECT
- PCHR-01-NO-SECRET-AUTO-READ
- PCHR-01-OMS-REQUIRED
- PCHR-01-OPERATOR-APPROVAL-AND-GATE-PASS-REQUIRED
- PCHR-01-PRODUCTION-CUTOVER-RUNTIME-HARDENING-CONTRACT
- PCHR-01-PRODUCTION-TRADING-DEFAULT-DISABLED
- PCHR-01-REAL-BROKER-PRODUCTION-ENDPOINT-DEFAULT-OFF
- PCHR-01-RISKENGINE-REQUIRED
- PCHR-02-CREDENTIAL-IDENTITY-PROFILE-REFERENCE
- PCHR-02-CREDENTIAL-REFERENCE-ENVIRONMENT-ISOLATION-RUNTIME
- PCHR-02-DRYRUN-AUTHORIZED-LOCAL-FIXTURE
- PCHR-02-DRYRUN-TESTNET-PRODUCTION-ENVIRONMENT-ISOLATION
- PCHR-02-FUTURE-PRODUCTION-MANUAL-GATE
- PCHR-02-MISSING-AUTHORIZATION-FAIL-CLOSED
- PCHR-02-NO-PRODUCTION-FALLBACK
- PCHR-02-NO-PRODUCTION-SECRET-VALUE-READ
- PCHR-02-PRODUCTION-MISSING-AUTHORIZATION-FAIL-CLOSED
- PCHR-02-TESTNET-AUTHORIZED-REFERENCE
- PCHR-03-AUDIT-CONNECTION-FAILURE-FAIL-CLOSED
- PCHR-03-AUDIT-ENDPOINT-NOT-ALLOWLISTED
- PCHR-03-AUDIT-MISSING-OPERATOR-APPROVAL
- PCHR-03-AUDIT-PRODUCT-TYPE-NOT-ALLOWLISTED
- PCHR-03-AUDIT-VENUE-NOT-ALLOWLISTED
- PCHR-03-CONNECTION-ATTEMPT-AUDIT-EVIDENCE
- PCHR-03-CONNECTION-FAILURE-FAIL-CLOSED
- PCHR-03-ENDPOINT-VENUE-PRODUCT-ALLOWLIST
- PCHR-03-NO-ENDPOINT-FALLBACK-OR-SILENT-CONTINUATION
- PCHR-03-NO-PRODUCTION-ENDPOINT-AUTO-CONNECT
- PCHR-03-OPERATOR-APPROVAL-REQUIRED
- PCHR-03-PRODUCTION-ENDPOINT-CONNECTION-GATE
- PCHR-04-COMMAND-RISK-EXECUTION-OMS-DISPATCH-GATE
- PCHR-04-COMMANDGATEWAY-OPERATOR-APPROVAL
- PCHR-04-DASHBOARD-CLI-NO-DIRECT-EXECUTIONCLIENT
- PCHR-04-EXECUTIONENGINE-RISK-APPROVED-ONLY
- PCHR-04-FAILED-GATE-BLOCKS-COMMAND
- PCHR-04-NO-PRODUCTION-ORDER-AUTHORIZATION
- PCHR-04-OMS-LIFECYCLE-BEFORE-HANDOFF
- PCHR-04-RISKENGINE-KILL-NOTRADE-LIMITS
- PCHR-05-APPEND-ONLY-COMMAND-RISK-OMS-EXECUTION-EVENTS
- PCHR-05-EVENT-IDEMPOTENCY
- PCHR-05-MISSING-AUDIT-BLOCKS-HANDOFF
- PCHR-05-NO-PRODUCTION-ORDER-AUTHORIZATION
- PCHR-05-OMS-EVENT-STORE-PRODUCTION-AUDIT-TRAIL
- PCHR-05-REPLAY-RESTORES-COMMAND-STATE
- PCHR-05-ROLLBACK-REPAIR-EVIDENCE
- PCHR-06-BROKER-SHADOW-DRY-RUN-PRODUCTION-CUTOVER-PROOF
- PCHR-06-DRY-RUN-SHADOW-MODE-MARKED
- PCHR-06-NO-RAW-BROKER-PAYLOAD-DASHBOARD
- PCHR-06-NO-REAL-ORDER-SENT
- PCHR-06-PRODUCTION-LIKE-REQUEST-MAPPING-EVIDENCE
- PCHR-06-PRODUCTION-ORDER-PATH-BLOCKED-BY-DEFAULT
- PCHR-06-SUBMIT-CANCEL-REPLACE-PAYLOAD-AUDIT
- PCHR-07-PRODUCTION-HARDENING-READINESS-CLOSEOUT
- PCHR-07-ISSUE-PR-EVIDENCE-CHAIN
- PCHR-07-PRODUCTION-DEFAULTS-REMAIN-CLOSED
- PCHR-07-COMMAND-RISK-EXECUTION-OMS-EVENTSTORE-GATES-COMPLETE
- PCHR-07-AUTOMATION-READINESS-CLOSEOUT
- PCHR-07-NO-PRODUCTION-CUTOVER-AUTHORIZATION
- PCHR-07-STAGE-CODE-AUDIT-HANDOFF
- TVM-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS
- GH-766-RELEASE-V060-FINAL-AUDIT-ROOT-DOCS
- GH-766-VERIFY-V060-FINAL-AUDIT-ROOT-DOCS
- GH-779-VERIFY-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT
- TVM-RELEASE-V070-NO-ORDER-RUNTIME-SESSION-CONTRACT
- V070-001-NO-ORDER-RUNTIME-SESSION-CONTRACT
- V070-001-ALLOWED-MODES
- V070-001-CANONICAL-MODULE-SEQUENCE
- V070-001-EVIDENCE-ENVELOPE
- V070-001-DOWNSTREAM-QUEUE-ORDER
- V070-001-FORBIDDEN-CAPABILITIES
- TVM-RELEASE-V070-TESTNET-ENDPOINT-POLICY
- GH-780-VERIFY-V070-TESTNET-ENDPOINT-POLICY
- GH-780 Release v0.7.0 Testnet Endpoint Policy Validation
- testGH780BinanceSignedAccountReadConfigurationRejectsNonCanonicalTestnetBaseURLs
- testGH780BinanceSignedAccountReadTransportRejectsURLPathDrift
- canonical Binance Spot testnet base URL: `https://testnet.binance.vision`
- rejected endpoint shapes: http scheme、production hosts、userinfo、path、query、fragment、explicit port
- signed account read transport path drift guard: URL path must stay `/api/v3/account`
- TVM-RELEASE-V070-CLI-RUNTIME-SESSION-SURFACE
- GH-781-VERIFY-V070-CLI-RUNTIME-SESSION-SURFACE
- GH-781 Release v0.7.0 CLI Runtime Session Surface Validation
- testGH781TopLevelCLIRunStatusVerifyUseV070RuntimeSessionSemantics
- top-level `mtpro run/status/verify` active surface: v0.7.0 no-order runtime session
- `mtpro run --mode dry-run`: local no-order session flow mapping, no order submission
- `mtpro status [runID]`: v0.7.0 session / registry state wording, no v0.4 / v0.5 active top-level surface
- `mtpro verify`: v0.7.0 contract / endpoint / CLI / automation gates
- forbidden commands: production mode、submit、cancel、replace fail-closed
- TVM-RELEASE-V070-DASHBOARD-MACOS-GUARDS
- GH-782-VERIFY-V070-DASHBOARD-MACOS-GUARDS
- GH-782 Release v0.7.0 Dashboard macOS Focused Guard Validation
- testGH782DashboardMacOSChecksRunV070FocusedGuards
- `dashboard-macos` required job guard: run `checks/verify-v0.7.0-dashboard-macos-guards.sh` before Dashboard build / smoke
- focused guard coverage: run-detail observer、testnet read-only probe、testnet endpoint policy、CLI runtime-session surface
- forbidden macOS guard scope: no UI trading command、no production endpoint / broker connection、no production secret read、no real order、no production cutover
- TVM-RELEASE-V070-OPERATIONAL-RUN-SESSION
- GH-783-VERIFY-V070-OPERATIONAL-RUN-SESSION
- GH-783 Release v0.7.0 Operational Run Session Validation
- testGH783OperationalRunSessionLifecycleIsDeterministicNoOrderAndRejectsInvalidTransitions
- session states: created、starting、running、stopping、stopped、failed、completed、recovered
- command/event model: start、stop、complete、fail、recover
- evidence envelope: runID-bound, local-dry-run, no-order, production/testnet order flags false
- invalid ordering: reject complete before start, stop before running, recover before failed, production/order authorization drift
- TVM-RELEASE-V070-EVENT-LOG-WRITER-RECOVERY
- GH-784-VERIFY-V070-EVENT-LOG-WRITER-RECOVERY
- GH-784 Release v0.7.0 Event Log Writer Recovery Validation
- testGH784RuntimeEventLogWriterAppendsValidatesAndRecoversPartialLines
- runtime append batch: local `events.jsonl` batch append with local `.events.jsonl.lock`
- checksum evidence: payload event checksum, line checksum, previous line checksum chain
- recovery evidence: deterministic partial-line truncation before append, corrupt complete line validation failure
- duplicate evidence: duplicate eventID rejected from existing journal and same append batch
- forbidden scope: no distributed log service, no broker event ingestion, no production persistence cutover, no production endpoint / broker connection, no production secret read, no real order, no production cutover
- TVM-RELEASE-V070-RUN-REGISTRY-SUPERVISOR
- GH-785-VERIFY-V070-RUN-REGISTRY-SUPERVISOR
- GH-785 Release v0.7.0 Run Registry / Supervisor Validation
- testGH785RunRegistrySupervisorProvidesLocalNoOrderRunManagement
- deterministic registry source: `runs list` / inspect read from local-run-registry-metadata
- state management: archive and recover mutate local metadata only; archived run rejects further mutation
- artifact locations: registry entries expose `.local/mtpro/runs/<runID>/events.jsonl`、projection、summary、status、manifest paths
- CLI observer preparation: `mtpro run/status` use local registry-ready / local-run-registry-state wording
- forbidden scope: no remote run service, no production scheduler, no concurrent production runtime, no production trading authorization, no production endpoint / broker connection, no production secret read, no real order, no production cutover
- TVM-RELEASE-V070-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE
- GH-786-VERIFY-V070-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE
- V070-008-OPERATOR-CONFIRMED-TESTNET-SIGNED-ACCOUNT-READONLY-PROBE
- V070-008-CALL-TIME-CREDENTIAL-RESOLUTION
- V070-008-DETERMINISTIC-FIXTURE-NETWORK-READONLY-SEPARATION
- V070-008-CREDENTIAL-VALUE-REDACTION
- V070-008-PRODUCTION-AND-ORDER-ENDPOINT-REJECTION
- V070-008-NO-ORDER-NO-PRODUCTION-BOUNDARY
- GH-786 Release v0.7.0 Testnet Signed Account Read-only Probe Validation
- testGH786RealBinanceTestnetSignedAccountReadOnlyProbeRequiresOperatorConfirmation
- operator gate: explicit profile、credential reference、canonical Binance Spot testnet endpoint 和 confirmation id are required
- credential boundary: key / secret value is resolved only by provider at artifact call time and never persisted or displayed
- mode separation: deterministic fixture mode and network read-only mode stay distinct in configuration / artifact evidence
- forbidden scope: no production host, no order endpoint, no submit / cancel / replace, no production secret auto-read, no broker endpoint, no production cutover
- TVM-RELEASE-V070-TESTNET-PRIVATE-STREAM-READONLY-PROBE
- GH-787-VERIFY-V070-TESTNET-PRIVATE-STREAM-READONLY-PROBE
- V070-009-OPERATOR-CONFIRMED-TESTNET-PRIVATE-STREAM-READONLY-PROBE
- V070-009-LISTENKEY-LIFECYCLE-OPEN-OBSERVE-CLOSE
- V070-009-LISTENKEY-AND-CREDENTIAL-REDACTION
- V070-009-ACCOUNT-POSITION-BALANCE-READMODEL-EVIDENCE
- V070-009-EXECUTIONREPORT-COMMAND-PATH-REJECTION
- V070-009-NO-ORDER-NO-PRODUCTION-BOUNDARY
- GH-787 Release v0.7.0 Testnet Private Stream Read-only Probe Validation
- testGH787TestnetPrivateStreamReadOnlyProbeOpensObservesAndClosesRedactedListenKey
- operator gate: explicit profile、credential reference、canonical Binance Spot testnet REST / stream endpoint 和 confirmation id are required
- listenKey lifecycle: open / observe / close evidence is persisted with redacted reference only; raw listenKey is not persisted or displayed
- read-model evidence: private stream frames map to account / position / balance read model only
- forbidden scope: no executionReport command path, no production host, no submit / cancel / replace, no production secret auto-read, no broker endpoint, no production cutover
- TVM-RELEASE-V070-DASHBOARD-READONLY-RUN-OPERATIONS
- GH-788-VERIFY-V070-DASHBOARD-READONLY-RUN-OPERATIONS
- V070-010-DASHBOARD-RUN-LIST-DETAILS-STATE-EVIDENCE
- V070-010-LOCAL-DRY-RUN-START-STOP-RECOVER-SAFE-COMMANDS
- V070-010-TESTNET-READONLY-PROBE-STATUS-VISIBILITY
- V070-010-REGISTRY-JOURNAL-READMODEL-ONLY
- V070-010-NO-TRADING-BUTTON-ORDER-FORM-LIVE-COMMAND
- V070-010-NO-ORDER-NO-PRODUCTION-BOUNDARY
- GH-788 Release v0.7.0 Dashboard Read-only Run Operations Validation
- testGH788DashboardReadOnlyRunOperationsSurfaceShowsRegistryJournalAndProbeStatusWithoutCommands
- testGH788DashboardReadOnlyRunOperationsSurfaceIsAnchoredInV070Guards
- Dashboard run operations: run list / detail / state / failure / replay / projection evidence must come from local run registry and journal artifact source identities
- safe local controls: start / stop / recover are local dry-run session visibility only and must not expose order command, live command, production command or production cutover
- testnet probe visibility: GH-786 / GH-787 status is visible only as redacted read-only artifact status; credential value、raw listenKey 和 raw private payload remain hidden
- forbidden scope: no trading button, no order form, no submit / cancel / replace, no broker endpoint, no production endpoint, no production secret auto-read, no production trading, no production cutover
- TVM-RELEASE-V070-LOCAL-RISK-POLICY-CONFIG
- GH-789-VERIFY-V070-LOCAL-RISK-POLICY-CONFIG
- V070-011-LOCAL-RISK-POLICY-FIELDS
- V070-011-RISK-POLICY-ARTIFACTS-REPLAY
- V070-011-KILL-SWITCH-NO-TRADE-BLOCKS-DOWNSTREAM
- V070-011-ALLOWED-SYMBOLS-PRODUCT-TYPES
- V070-011-NO-PRODUCTION-ACCOUNT-DATA
- GH-789 Release v0.7.0 Local Risk Policy Config Validation
- testGH789LocalRiskPolicyConfigPersistsReplayablePolicyAndDecisionEvidence
- local policy fields: maxNotional、maxExposure、killSwitch、noTrade、allowedSymbols 和 allowedProductTypes must be inspectable in persisted policy evidence
- replay evidence: persisted policy / decision artifact paths must replay to the same decision records
- kill switch / no-trade: blocked decisions must suppress OMS lifecycle、ExecutionClient request、broker command 和 production account read
- allowlist: symbols and product types outside local policy must fail closed before decision evidence is accepted
- forbidden scope: no production account data, no broker margin / leverage read, no production secret, no production endpoint / broker, no submit / cancel / replace, no production cutover
- TVM-RELEASE-V070-PORTFOLIO-READONLY-RECONCILIATION
- GH-790-VERIFY-V070-PORTFOLIO-READONLY-RECONCILIATION
- V070-012-JOURNAL-EXPECTED-VS-TESTNET-OBSERVED
- V070-012-DIFF-ARTIFACTS-EXPLAIN-ONLY
- V070-012-NO-CORRECTION-COMMAND
- V070-012-NO-PRODUCTION-ACCOUNT-READ
- V070-012-READONLY-RECONCILIATION-PROJECTION
- GH-790 Release v0.7.0 Portfolio Read-only Reconciliation Validation
- testGH790PortfolioReadOnlyReconciliationExplainsExpectedVsObservedWithoutCommands
- expected state: local run journal Portfolio projection remains the only source of expected position / exposure evidence
- observed state: GH-786 signed account read-only snapshot and GH-787 private stream read model may be mapped into redacted observed state values
- diff artifact: expected vs observed records must explain matched / delta / missing observed state without creating correction commands
- forbidden scope: no broker correction, no account mutation, no production account sync, no real PnL ownership, no trading adjustment command, no production account read, no production cutover
- TVM-RELEASE-V070-CI-RELEASE-VALIDATION-GATE
- GH-791-VERIFY-V070-CI-RELEASE-VALIDATION-GATE
- V070-013-AGGREGATE-FOCUSED-GUARDS
- V070-013-CHECKS-RUN-V070-GATE
- V070-013-PRODUCTION-DISABLED-DEFAULTS
- GH-791 Release v0.7.0 CI / Release Validation Gate
- testGH791ReleaseV070AggregateValidationGateCoversFocusedGuardsAndProductionDisabledDefaults
- aggregate scripts: `checks/verify-v0.7.0.sh` must execute GH-779 through GH-790 focused verifiers
- checks gate: `checks/run.sh` must call `bash checks/verify-v0.7.0.sh` while retaining direct focused verifier coverage
- forbidden scope: no production cutover, no production secret read, no production endpoint / broker connection, no real submit / cancel / replace order
- TVM-RELEASE-V070-FINAL-AUDIT-DOCS-RUNBOOK
- GH-792-VERIFY-V070-FINAL-AUDIT-DOCS-RUNBOOK
- GH-792-RELEASE-V070-FINAL-AUDIT-DOCS-RUNBOOK
- V070-014-VALIDATION-SUMMARY
- audit docs: `docs/audit/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-stage-code-audit.md`
- release notes: `docs/release/mtpro-release-v0.7.0-operator-runtime-session-testnet-read-only-connectivity-notes.md`
- operator runbook: `docs/operators/release-v0.7.0-operator-runtime-session-testnet-readonly-connectivity-runbook.md`
- focused test: `testGH792ReleaseV070FinalAuditDocsAndRunbookCloseCompletedFactsOnly`
- root docs refresh: latest completed release construction scope must be v0.7.0 and Project Closure Count must be `41 / 41 (100%)`
- forbidden scope: GH-792 construction closeout did not publish a tag; later v0.7.0 release publication is a separate gate. no next Project / Issue, no production cutover, no production secret read, no production endpoint / broker connection, no real submit / cancel / replace order

## TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT

- GH-952-VERIFY-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT
- TVM-RELEASE-V0120-READINESS-ASSESSMENT-SESSION-CONTRACT
- V0120-001-READINESS-ASSESSMENT-SESSION-CONTRACT
- V0120-001-EVIDENCE-PROVENANCE-MODEL
- V0120-001-MULTI-ASSESSMENT-HISTORY
- V0120-001-FORBIDDEN-PRODUCTION-CAPABILITIES
- V0120-001-NO-PRODUCTION-CUTOVER
- GH-952 Release v0.12.0 Readiness Assessment Session No-authorization Contract Validation
- testGH952ReleaseV0120ReadinessAssessmentSessionNoAuthorizationContract
- assessment model: assessment sessions are local-only, explicit-input, no-authorization evidence sessions
- provenance model: source release / patch, issue / PR / checks evidence, local artifact path, checksum / hash, validation command and fail-closed classification must be retained
- history model: baseline / follow-up / superseded / blocked / invalid assessments are allowed as append-only evidence lineage
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-V011X-RELEASE-PATCH-FACTS

- GH-953-VERIFY-V0120-V011X-RELEASE-PATCH-FACTS
- TVM-RELEASE-V0120-V011X-RELEASE-PATCH-FACTS
- V0120-002-V0110-PUBLICATION-FACT
- V0120-002-V0111-PATCH-FACT
- V0120-002-CONSTRUCTION-PUBLICATION-CUTOVER-SEPARATION
- V0120-002-NO-PRODUCTION-CUTOVER
- GH-953 Release v0.12.0 v0.11.x Publication / Patch Fact Baseline Validation
- testGH953ReleaseV0120CarriesForwardV011XPublicationAndPatchFacts
- v0.11.0 fact: public GitHub Release URL, tag peeled commit and publication timestamp are fixed baseline evidence
- v0.11.1 patch fact: patch closeout covers #945..#951 and does not create or move any tag / GitHub Release
- gate separation: construction closeout, public release publication, release fact sync / stale wording guard, patch closeout and production cutover remain independent gates
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-READINESS-ASSESSMENT-REGISTRY-STORE

- GH-954-VERIFY-V0120-READINESS-ASSESSMENT-REGISTRY-STORE
- TVM-RELEASE-V0120-READINESS-ASSESSMENT-REGISTRY-STORE
- V0120-003-READINESS-ASSESSMENT-REGISTRY-STORE
- V0120-003-REGISTRY-JSON-PATH
- V0120-003-ASSESSMENT-DIRECTORY-PATH
- V0120-003-CREATE-LIST-INSPECT-ARCHIVE-RECOVER
- V0120-003-COMPARE-READY-METADATA
- V0120-003-NO-PRODUCTION-CUTOVER
- GH-954 Release v0.12.0 Readiness Assessment Registry Store Validation
- testGH954ReadinessAssessmentRegistryStorePersistsLifecycleAndCompareReadyMetadata
- registry path: `.local/mtpro/readiness/registry.json` is the only registry payload path
- assessment paths: `.local/mtpro/readiness/assessments/<assessmentID>/` holds local metadata / provenance / comparison / redacted export path references only
- lifecycle operations: create / list / inspect / archive / recover mutate local metadata and checksum evidence only
- compare-ready state: compare-ready only means local metadata is eligible for later diff / compare, not production readiness or order authorization
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-ASSESSMENT-TRANSACTION-LOCK

- GH-955-VERIFY-V0120-ASSESSMENT-TRANSACTION-LOCK
- TVM-RELEASE-V0120-ASSESSMENT-TRANSACTION-LOCK
- V0120-004-ASSESSMENT-TRANSACTION-LOCK
- V0120-004-TRANSACTION-ID-GENERATION-ID
- V0120-004-STAGING-DIRECTORY-COMMIT-MARKER
- V0120-004-COMPARE-AND-SWAP-MANIFEST
- V0120-004-CRASH-RECOVERY-SEMANTICS
- V0120-004-NO-PRODUCTION-CUTOVER
- GH-955 Release v0.12.0 Assessment Transaction Lock / Generation Control Validation
- testGH955AssessmentTransactionLockControlsGenerationAndCrashRecovery
- assessment lock: `.local/mtpro/readiness/assessments/<assessmentID>/assessment.lock` prevents concurrent writer mixing
- generation control: `transactionID`, `generationID` and `expectedPreviousGenerationID` drive compare-and-swap fail-closed behavior
- staging / commit evidence: staging transaction manifest and commit marker must move into assessment-local compare-and-swap manifest and commit marker on success
- abort / recovery: abort releases lock and removes staging; crash recovery only clears stale staging directories and assessment locks
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-READINESS-MANIFEST-V2

- GH-956-VERIFY-V0120-READINESS-MANIFEST-V2
- TVM-RELEASE-V0120-READINESS-MANIFEST-V2
- V0120-005-READINESS-MANIFEST-V2
- V0120-005-ASSESSMENT-GENERATION-PROVENANCE
- V0120-005-SOURCE-RUN-COMMIT-PROVENANCE
- V0120-005-CANONICAL-ARTIFACT-METADATA
- V0120-005-PRODUCER-VERSION-SCHEMA
- V0120-005-NO-PRODUCTION-CUTOVER
- GH-956 Release v0.12.0 Readiness Manifest V2 / Provenance Schema Validation
- testGH956ReadinessManifestV2RecordsAssessmentGenerationAndProvenance
- manifest path: `.local/mtpro/readiness/assessments/<assessmentID>/manifest-v2.json`
- assessment generation provenance: `assessmentID` and `generationID` bind the manifest to one local assessment generation
- source provenance: `sourceRunIDs` and `sourceCommit` preserve source run lineage and source commit identity
- canonical artifact metadata: `schemaVersion`, `canonicalizationAlgorithm`, `artifactContentType`, `artifactSHA256`, `artifactBytes`, `createdAt` and `producerVersion` must be present and fail closed on invalid source commit, checksum or byte count
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-ARTIFACT-CONTENT-POLICY-REDACTION

- GH-957-VERIFY-V0120-ARTIFACT-CONTENT-POLICY-REDACTION
- TVM-RELEASE-V0120-ARTIFACT-CONTENT-POLICY-REDACTION
- V0120-006-ARTIFACT-CONTENT-POLICY
- V0120-006-JSON-SCHEMA-ALLOWLIST
- V0120-006-FORBIDDEN-FIELD-REJECTION
- V0120-006-RAW-SECRET-LISTENKEY-REJECTION
- V0120-006-ORDER-ENDPOINT-PAYLOAD-REJECTION
- V0120-006-CONTENT-VALIDATION-CHECKSUM
- V0120-006-NO-PRODUCTION-CUTOVER
- GH-957 Release v0.12.0 Artifact Content-policy / Redaction Validator Validation
- testGH957ArtifactContentPolicyRejectsSecretsListenKeysOrdersAndEndpointResponses
- artifact policy schema: `v0.12.0.artifact-content-policy.v1`
- JSON schema allowlist: top-level fields must be within `allowedJSONFields` and all `requiredJSONFields` must be present
- forbidden field rejection: recursive JSON field names must not contain `secret`, `signature`, `listenKey`, `privatePayload`, order payload fields or endpoint response fields
- raw marker rejection: raw artifact bytes must not contain raw secret markers, raw listenKey markers, signed account endpoint paths, order endpoint paths, user data stream endpoint paths, exchange API key headers, production exchange hosts or listenKey query markers
- content validation checksum: accepted artifact content records `contentValidationChecksum` after Manifest V2 `artifactSHA256` is recomputed and matched
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT

- GH-958-VERIFY-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT
- TVM-RELEASE-V0120-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT
- V0120-007-IMMUTABLE-READINESS-BUNDLE-SNAPSHOT
- V0120-007-READINESS-BUNDLE-V2-JSON
- V0120-007-READINESS-BUNDLE-V2-MANIFEST-JSON
- V0120-007-REVIEW-SNAPSHOT-IMMUTABLE
- V0120-007-NEW-GENERATION-ON-CHANGE
- V0120-007-BUNDLE-MANIFEST-CHECKSUM
- V0120-007-NO-PRODUCTION-CUTOVER
- GH-958 Release v0.12.0 Immutable Readiness Bundle Snapshot Validation
- testGH958ImmutableReadinessBundleSnapshotRequiresNewGenerationOnChange
- bundle path: `.local/mtpro/readiness/assessments/<assessmentID>/generations/<generationID>/readiness-bundle-v2.json`
- manifest path: `.local/mtpro/readiness/assessments/<assessmentID>/generations/<generationID>/readiness-bundle-v2.manifest.json`
- review immutability: once `reviewState=in-review` is persisted for a generation, same-generation rewrite must fail closed
- changed input rule: changed artifact snapshot, source run, source commit, producer version or generated content must create a new `generationID`
- checksum evidence: bundle records stable `bundleChecksum`; manifest records stable `manifestChecksum`, `bundleJSONSHA256` and `bundleBytes`
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS

- GH-959-VERIFY-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS
- TVM-RELEASE-V0120-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS
- V0120-008-KILL-SWITCH-NO-TRADE-TRUSTWORTHY-OBSERVATIONS
- V0120-008-OBSERVED-EXPIRES-REVIEWED-SOURCE-EVIDENCE
- V0120-008-DERIVED-FRESHNESS-AND-REVIEW-STATE
- V0120-008-STALE-UNREVIEWED-MISMATCH-FAIL-CLOSED
- V0120-008-APPROVAL-REQUEST-ONLY-NO-CUTOVER
- V0120-008-NO-PRODUCTION-CUTOVER
- GH-959 Release v0.12.0 Kill Switch / No-trade Trustworthy Observations Validation
- testGH959KillSwitchNoTradeTrustworthyObservationsFailClosed
- observation fields: `observedAt`, `expiresAt`, `reviewedAt`, `reviewedBy`, `sourceArtifact`, `sourceChecksum` and `sourceRunID`
- source evidence rules: `sourceArtifact` must be a safe relative local readiness artifact path, `sourceChecksum` must be `sha256:<64 lowercase hex>`, and `sourceRunID` must match the expected review source run ID
- freshness derivation: future observations become `unknown`, expired evidence becomes `stale`, mismatched source artifact / checksum / runID becomes `unavailable`, and only unexpired matching evidence becomes `fresh`
- review derivation: missing review evidence becomes `pending`, out-of-window review evidence becomes `unknown`, mismatched source evidence becomes `unavailable`, and only matching in-window review evidence becomes `reviewed`
- approval boundary: inactive + fresh + reviewed reaches only approval-request eligibility; production cutover, order submission, endpoint / broker connection, secret read and UI command surfaces remain disabled
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-APPROVAL-ROLE-QUORUM-SEPARATION

- GH-960-VERIFY-V0120-APPROVAL-ROLE-QUORUM-SEPARATION
- TVM-RELEASE-V0120-APPROVAL-ROLE-QUORUM-SEPARATION
- V0120-009-APPROVAL-ROLE-QUORUM-SEPARATION
- V0120-009-REQUESTER-REVIEWER-APPROVER-ROLE-POLICY
- V0120-009-QUORUM-SEPARATION-OF-DUTIES
- V0120-009-APPROVAL-EXPIRY-REVOCATION-FAIL-CLOSED
- V0120-009-BUNDLE-CHECKSUM-BINDING
- V0120-009-TRANSITION-CHECKSUM-CHAIN
- V0120-009-NO-PRODUCTION-CUTOVER
- GH-960 Release v0.12.0 Approval Role / Quorum Separation Validation
- testGH960ApprovalRolesQuorumAndBundleBindingFailClosed
- role evidence: `ReleaseV0120ApprovalWorkflowRolePolicy` records requester, reviewers, approvers, revokers and separation of duties
- quorum evidence: `ReleaseV0120ApprovalWorkflowQuorumPolicy` separates reviewer quorum from approver quorum
- checksum evidence: `boundBundleChecksum`, `expectedBundleChecksum` and `transitionChecksumChain` bind approval evidence to immutable bundle and transition history
- fail-closed coverage: requester-as-approver, missing reviewer quorum, missing approver quorum, expired approval, revoked approval, bundle checksum mismatch and transition checksum chain mismatch
- approval boundary: `approvalEvidenceComplete=true` is still local readiness evidence only; production cutover, order submission, endpoint / broker connection, secret read and UI command surfaces remain disabled
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT

- GH-961-VERIFY-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT
- TVM-RELEASE-V0120-SHADOW-PARITY-SOURCE-SNAPSHOT
- V0120-010-SHADOW-PARITY-SOURCE-SNAPSHOT
- V0120-010-SOURCE-RUN-MANIFEST-CHECKSUM
- V0120-010-EVENT-ID-SET-BINDING
- V0120-010-RISK-DECISION-ID-BINDING
- V0120-010-OMS-DRY-RUN-LIFECYCLE-ID-BINDING
- V0120-010-PORTFOLIO-PROJECTION-CHECKSUM-BINDING
- V0120-010-RECONCILIATION-CHECKSUM-BINDING
- V0120-010-NO-PRODUCTION-CUTOVER
- GH-961 Release v0.12.0 Shadow Parity Source Snapshot Validation
- testGH961ShadowParityBindsImmutableSourceRunSnapshot
- source snapshot fields: `sourceRunManifestChecksum`, `eventIDs`, `riskDecisionIDs`, `omsDryRunLifecycleIDs`, `portfolioProjectionChecksum`, `reconciliationChecksum` and `snapshotChecksum`
- binding evidence: `sourceSnapshotBindingHeld=true` proves expected and observed source run snapshots match
- fail-closed evidence: any mutated source run manifest checksum, event ID set, risk decision ID set, OMS dry-run lifecycle ID set, portfolio projection checksum or reconciliation checksum sets `sourceSnapshotMismatch=true` and invalidates the assessment
- approval boundary: shadow parity source snapshot binding remains local dry-run / shadow evidence only; it does not authorize production cutover, order submission, endpoint / broker connection, secret read or UI command surfaces
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-READINESS-ASSESSMENT-DIFF-COMPARE

- GH-962-VERIFY-V0120-READINESS-ASSESSMENT-DIFF-COMPARE
- TVM-RELEASE-V0120-READINESS-ASSESSMENT-DIFF-COMPARE
- V0120-011-READINESS-ASSESSMENT-DIFF-COMPARE
- V0120-011-POLICY-ARTIFACT-RISK-KILL-APPROVAL-SECTIONS
- V0120-011-SOURCE-RUN-EVIDENCE-COMPARISON
- V0120-011-NON-MUTATING-COMPARE
- V0120-011-NO-PRODUCTION-CUTOVER
- GH-962 Release v0.12.0 Readiness Assessment Diff / Compare Validation
- testGH962ReadinessAssessmentDiffCompareIsLocalAndNonMutating
- compare sections: `policy`, `artifacts`, `risk-limits`, `kill-switch-state`, `approval-state` and `source-run-evidence`
- compare input: `ReadinessAssessmentComparisonSnapshot` uses `policyChecksum`, `artifactBundleChecksum`, `riskLimitChecksum`, `killSwitchStateChecksum`, `approvalStateChecksum` and GH-961 `sourceRunSnapshot`
- output evidence: `ReadinessAssessmentComparisonReport` records matched / changed sections, stable `reportChecksum`, `operatorReviewOnly=true` and `compareDoesNotMutateAssessments=true`
- non-mutating evidence: compare does not write registry, does not mutate assessment metadata and does not create approval state
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-ASSESSMENT-CLI-LIFECYCLE

- GH-963-VERIFY-V0120-ASSESSMENT-CLI-LIFECYCLE
- TVM-RELEASE-V0120-ASSESSMENT-CLI-LIFECYCLE
- V0120-012-ASSESSMENT-SCOPED-CLI-LIFECYCLE
- V0120-012-CREATE-BUILD-STATUS-VALIDATE-EXPORT-ARCHIVE
- V0120-012-COMPARE-LOCAL-ASSESSMENTS
- V0120-012-INVALID-ASSESSMENT-ID-FAIL-CLOSED
- V0120-012-LOCAL-REGISTRY-STORE-ONLY
- V0120-012-NO-PRODUCTION-CUTOVER
- GH-963 Release v0.12.0 Assessment-scoped CLI Lifecycle Validation
- testGH963ReadinessAssessmentCLILifecycleUsesLocalRegistryOnly
- CLI commands: `mtpro readiness create`, `build <assessmentID>`, `status <assessmentID>`, `validate <assessmentID>`, `export <assessmentID>`, `archive <assessmentID>` and `compare <baselineAssessmentID> <followUpAssessmentID>`
- local store: `MTPRO_READINESS_ROOT` or `.local/mtpro/readiness`, backed by `ReadinessAssessmentRegistryStore`
- fail-closed evidence: invalid assessment IDs are rejected at `mtpro.readiness.arguments`, and outputs include `invalidAssessmentIDsFailClosed=true`
- output evidence: all commands keep `localRegistryStoreOnly=true`, `boundaryHeld=true`, production capability flags disabled and compare non-mutating / operator-review-only
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-DASHBOARD-ASSESSMENT-HISTORY

- GH-964-VERIFY-V0120-DASHBOARD-ASSESSMENT-HISTORY
- TVM-RELEASE-V0120-DASHBOARD-ASSESSMENT-HISTORY
- V0120-013-DASHBOARD-ASSESSMENT-HISTORY
- V0120-013-ASSESSMENT-LIST-DETAIL-GENERATION-HISTORY
- V0120-013-PROVENANCE-VALIDATION-APPROVAL-COMPARISON
- V0120-013-ADVERSARIAL-CI-GUARD
- V0120-013-NO-PRODUCTION-CUTOVER
- GH-964 Release v0.12.0 Dashboard Assessment History / Adversarial CI Validation
- testGH964DashboardAssessmentHistoryShowsLocalEvidenceAndAdversarialCoverageWithoutCommands
- testGH964DashboardAssessmentHistoryAndAdversarialCIGuardsAreAnchored
- Dashboard surface: `ReleaseV0120DashboardAssessmentHistorySurfaceViewModel`
- shell binding: `releaseV0120AssessmentHistorySurface` and `DashboardReleaseV0120AssessmentHistoryPanel`
- assessment history rows: `assessment-list`, `assessment-detail`, `generation-history`, `provenance`, `validation-status`, `approval-status` and `comparison`
- generation history evidence: three local generation IDs are displayed as redacted readiness assessment evidence
- adversarial CI coverage: `symlink-attack`, `concurrent-build`, `crash-recovery`, `checksum-toctou`, `file-permissions`, `tamper-after-validation` and `macos-dashboard-focused-guard`
- macOS guard: required `dashboard-macos` job runs `checks/verify-v0.12.0-dashboard-macos-guards.sh` before Dashboard build / smoke
- approval boundary: approval status is evidence-only and never converts into production cutover authorization
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK

- GH-965-VERIFY-V0120-FINAL-AUDIT-DOCS-RUNBOOK
- GH-965-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK
- TVM-RELEASE-V0120-FINAL-AUDIT-DOCS-RUNBOOK
- V0120-014-STAGE-CODE-AUDIT
- V0120-014-RELEASE-NOTES
- V0120-014-OPERATOR-RUNBOOK
- V0120-014-ASSESSMENT-REGISTRY-SCHEMA
- V0120-014-MANIFEST-V2-SCHEMA
- V0120-014-PROVENANCE-CONTRACT
- V0120-014-ADVERSARIAL-VALIDATION-SUMMARY
- V0120-014-ROOT-DOCS-REFRESH
- V0120-014-AGGREGATE-VERIFY
- V0120-014-NO-PRODUCTION-CUTOVER
- V0120-014-NO-TAG-OR-RELEASE-MOVE
- GH-965 Release v0.12.0 Final Audit / Docs / Runbook Validation
- testGH965ReleaseV0120FinalAuditDocsRunbookCloseCompletedFactsOnly
- stage audit: `docs/audit/mtpro-release-v0.12.0-readiness-assessment-sessions-stage-code-audit.md`
- release notes: `docs/release/mtpro-release-v0.12.0-readiness-assessment-sessions-notes.md`
- operator runbook: `docs/operators/release-v0.12.0-readiness-assessment-sessions-runbook.md`
- aggregate verifier: `checks/verify-v0.12.0.sh`
- completed queue evidence: #952 through #964 were closed / done before #965 preflight; #965 closes final audit / docs / runbook after its PR reaches required checks success
- PR evidence: PR #973 through PR #985 were merged with required `checks` SUCCESS; the #965 closure PR must be merged before the issue can be labeled done
- root docs refresh evidence: root docs only synchronize completed v0.12.0 readiness assessment facts, not future direction and not production cutover
- assessment registry schema evidence: `.local/mtpro/readiness/registry.json` and `.local/mtpro/readiness/assessments/<assessmentID>/`
- Manifest V2 schema evidence: assessment / generation scoped provenance and checksum metadata
- adversarial validation evidence: content-policy rejection, transaction crash recovery, immutable bundle guard, source snapshot mutation guard, approval quorum fail-closed coverage and Dashboard macOS adversarial CI
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no production OMS, no trading button, no order form, no live command, no tag / release movement, no next Project / Issue promotion

## TVM-RELEASE-V0121-RELEASE-FACT-SYNC-GUARD

- GH-988-VERIFY-V0121-RELEASE-FACT-STALE-WORDING-GUARD
- V0121-001-RELEASE-FACT-SYNC-GUARD
- V0121-001-FOUR-GATE-RELEASE-FLOW
- TVM-RELEASE-V0121-RELEASE-FACT-SYNC-GUARD
- GH-988 Release v0.12.1 Release Fact Sync / Stale Wording Guard Validation
- testGH988ReleaseFactSyncGuardRejectsV0120StalePublicationWording
- release fact: v0.12.0 stable GitHub Release URL `https://github.com/atxinbao/MTPRO/releases/tag/v0.12.0`
- tag fact: v0.12.0 tag peeled commit `25e31afd351db9a372db62222226b0a3db26c93a`
- publication fact: v0.12.0 publication timestamp `2026-06-20T01:11:22Z`
- stale wording evidence: guard rejects `publication pending`, `release pending`, `tag pending`, `no public tag`, `no GitHub Release`, `未创建 release` and `待发布` wording for v0.12.0 unless the line is explicitly scoped to #965 construction closeout
- historical closeout allowance: #965 / GH-965 / `V0120-014-NO-TAG-OR-RELEASE-MOVE` wording remains scoped to construction closeout and does not contradict the public release fact
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no tag rewrite, no release overwrite

## TVM-RELEASE-V0121-SOURCE-COMMIT-PROVENANCE

- GH-989-VERIFY-V0121-SOURCE-COMMIT-PROVENANCE
- V0121-002-SOURCE-COMMIT-PROVENANCE
- V0121-002-PLACEHOLDER-SOURCE-COMMIT-REJECTION
- TVM-RELEASE-V0121-SOURCE-COMMIT-PROVENANCE
- GH-989 Release v0.12.1 Source Commit Provenance Validation
- testGH989ReadinessSourceCommitProvenanceRejectsPlaceholdersAndAcceptsRealCommits
- CLI source: `MTPRO_READINESS_SOURCE_COMMIT` is the explicit source commit input for readiness build
- local fallback: verified local `git rev-parse --verify HEAD` is accepted when explicit source commit is absent
- rejection evidence: fixed placeholder `0123456789abcdef0123456789abcdef01234567`, zero commit and empty provenance cannot pass readiness build / manifest validation
- artifact evidence: accepted source commit is recorded in Manifest V2 and readiness bundle provenance fields
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no tag rewrite, no release overwrite

## TVM-RELEASE-V0121-LOCAL-EVIDENCE-METADATA

- GH-990-VERIFY-V0121-LOCAL-EVIDENCE-METADATA
- V0121-003-LOCAL-EVIDENCE-SOURCERUNID
- V0121-003-ARTIFACT-BYTES-CHECKSUM
- V0121-003-MISSING-LOCAL-EVIDENCE-FAIL-CLOSED
- TVM-RELEASE-V0121-LOCAL-EVIDENCE-METADATA
- GH-990 Release v0.12.1 Local Evidence Metadata Validation
- testGH990ReadinessLocalEvidenceMetadataBindsArtifactsAndSourceRunIDs
- CLI local evidence file: `.local/mtpro/readiness/assessments/<assessmentID>/artifacts/readiness-summary.json`
- source run evidence: Manifest V2 `sourceRunIDs` is derived from the evidence artifact sha256 prefix, not from a synthetic fixed run ID
- artifact metadata evidence: Manifest V2 `artifactSHA256` and `artifactBytes` match the actual local evidence file
- fail-closed evidence: missing or changed local artifact evidence makes readiness validation blocked instead of valid
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no tag rewrite, no release overwrite

## TVM-RELEASE-V0121-COMPARE-FAIL-CLOSED

- GH-991-VERIFY-V0121-COMPARE-FAIL-CLOSED
- V0121-004-READINESS-COMPARE-FAIL-CLOSED
- V0121-004-MISSING-SOURCE-RUN-EVIDENCE
- V0121-004-NO-FABRICATED-COMPARE-EVIDENCE
- TVM-RELEASE-V0121-COMPARE-FAIL-CLOSED
- GH-991 Release v0.12.1 Compare Fail-Closed Validation
- testGH991ReadinessCompareFailsClosedWithoutSourceRunEvidence
- compare-before-build evidence: missing Manifest V2 blocks local compare with an explicit `readinessCompare:missingManifest:<assessmentID>` reason
- source-run evidence input: local compare reads source-run manifest checksum, event IDs, risk decision IDs, OMS dry-run lifecycle IDs, portfolio projection checksum and reconciliation checksum from the redacted local artifact
- no fabricated evidence: compare cannot synthesize sourceRunID, event, risk, OMS or artifact evidence from assessmentID fallback strings
- missing artifact evidence: deleting the local source-run artifact makes compare fail closed before a report is emitted
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no tag rewrite, no release overwrite

## TVM-RELEASE-V0121-JSON-INSPECTION-GUARD

- GH-992-VERIFY-V0121-JSON-INSPECTION-GUARDS
- V0121-005-READINESS-JSON-INSPECTION
- V0121-005-GENERATED-EVIDENCE-PROVENANCE
- V0121-005-PLACEHOLDER-AND-PRODUCTION-FLAG-REJECTION
- GH-992 Release v0.12.1 JSON Inspection Guard Validation
- testGH992ReadinessJSONInspectionGuardsValidateGeneratedEvidence
- focused verifier: `bash checks/verify-v0.12.1-json-inspection-guards.sh`
- inspected evidence: generated registry, manifest-v2, readiness-summary artifact, readiness-bundle-v2, bundle manifest, export output and compare output
- provenance binding: manifest source commit, derived sourceRunID, artifact SHA / byte count, bundle snapshot checksum chain and bundle manifest SHA / byte count must match the generated local files
- rejection cases: placeholder source commit, synthetic sourceRunID, fixed artifact bytes, missing checksum chain and production-enabled flags fail the guard
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0121-PATCH-AUDIT-RELEASE-NOTES

- GH-993-VERIFY-V0121-PATCH-AUDIT-RELEASE-NOTES
- V0121-006-PATCH-AUDIT
- V0121-006-RELEASE-NOTES
- V0121-006-VALIDATION-SUMMARY
- V0121-006-NO-PRODUCTION-CUTOVER
- V0121-006-NO-TAG-OR-RELEASE-MOVE
- GH-993 Release v0.12.1 Patch Audit / Release Notes Validation
- testGH993ReleaseV0121PatchAuditReleaseNotesCloseout
- focused verifier: `bash checks/verify-v0.12.1-patch-audit-release-notes.sh`
- issue evidence: #988, #989, #990, #991, #992 and #993 define the v0.12.1 provenance hardening patch queue
- PR evidence: PR #1006, #1007, #1008, #1009 and #1010 merged with required checks SUCCESS before #993 preflight
- documentation evidence: Stage Code Audit and release notes document release fact sync, source commit provenance, local evidence metadata, compare fail-closed behavior and generated JSON inspection
- forbidden scope: no v0.12.1 tag, no v0.12.1 GitHub Release, no v0.12.0 tag / release movement, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT

- GH-994-VERIFY-V0130-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT
- V0130-001-LOCAL-EVIDENCE-READINESS-ENGINE-CONTRACT
- V0130-001-REAL-LOCAL-EVIDENCE-INTAKE-REQUIRED
- V0130-001-ARTIFACT-POLICY-MANIFEST-BUNDLE-REGISTRY-DIFF-CHAIN
- V0130-001-LIFECYCLE-ORDER-FAIL-CLOSED
- V0130-001-NO-SYNTHETIC-READINESS-DATA
- V0130-001-NO-PRODUCTION-CUTOVER
- GH-994 Release v0.13.0 Local Evidence-driven Readiness Engine Contract Validation
- testGH994ReleaseV0130LocalEvidenceReadinessEngineContract
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: contract-only definition of local evidence root intake, artifact policy validation, manifest provenance binding, immutable bundle, registry lifecycle entry, evidence-level diff / compare, redacted audit export and fail-closed lifecycle order
- dependency evidence: #995 through #1005 remain blocked by #994 until this contract PR is merged and #994 is closed / done
- forbidden scope: no implementation of #995 evidence intake, no synthetic readiness data, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-LOCAL-EVIDENCE-INTAKE-MODEL

- GH-995-VERIFY-V0130-LOCAL-EVIDENCE-INTAKE-MODEL
- V0130-002-LOCAL-EVIDENCE-ROOT-LAYOUT
- V0130-002-RUN-LOGS-EVENT-STREAM-ARTIFACTS-REGISTRY-PRIOR-ASSESSMENTS
- V0130-002-SCHEMA-VALIDATION-DIAGNOSTICS
- V0130-002-MISSING-MALFORMED-FAILS-CLOSED
- V0130-002-NO-PRODUCTION-ENDPOINT-SECRET-ORDER
- V0130-002-READ-ONLY-INTAKE
- GH-995 Release v0.13.0 Local Evidence Intake Model Validation
- testGH995ReleaseV0130LocalEvidenceIntakeModelDiscoversValidRootAndFailsClosed
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: local evidence root discovery and schema validation for run logs / event stream / artifacts / registry / prior assessments; missing root, missing file, malformed JSON / JSONL and forbidden production marker fail closed with actionable diagnostics
- CLI surface: `mtpro readiness intake <evidenceRoot>` reports `intakeValid`, `failClosed`, category states and diagnostics without writing assessment output
- dependency evidence: #996 through #1005 remain blocked by #995 until this intake PR is merged and #995 is closed / done
- forbidden scope: no registry write, no bundle build, no diff / compare, no synthetic sourceRunID / sourceCommit replacement, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-SYNTHETIC-PROVENANCE-REJECTION

- GH-996-VERIFY-V0130-SYNTHETIC-PROVENANCE-REJECTION
- V0130-003-INTAKE-DERIVED-MANIFEST-PROVENANCE
- V0130-003-SOURCECOMMIT-SOURCERUN-ARTIFACT-METADATA
- V0130-003-SYNTHETIC-PROVENANCE-FAILS-CLOSED
- V0130-003-FIXTURE-ONLY-ISOLATION
- V0130-003-NO-PRODUCTION-CUTOVER
- GH-996 Release v0.13.0 Synthetic Provenance Rejection Validation
- testGH996ReleaseV0130ProvenanceBuildRejectsSyntheticAndFixtureEvidence
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: #996 consumes #995 local evidence root and derives normal manifest sourceCommit, sourceRunIDs, artifact bytes and artifact checksums from real local files
- CLI surface: `mtpro readiness build-v013 <assessmentID> <evidenceRoot>` preserves Manifest V2 provenance only after source provenance is local, traceable and non-synthetic
- fail-closed evidence: placeholder sourceCommit, `gh-963-source-run`, `source-run-*` synthetic run IDs, missing artifact file, artifact metadata mismatch and fixture-only evidence are rejected
- dependency evidence: #996, #997, #998, #999 and #1000 are complete; #1001 is the active transaction recovery forensic snapshot gate after fresh WIP=1 preflight
- forbidden scope: no diff / compare, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-BUILD-PIPELINE

- GH-997-VERIFY-V0130-BUILD-PIPELINE
- V0130-004-SCHEMA-CHECKSUM-POLICY-REGISTRY-FLOW
- V0130-004-MANIFEST-BUNDLE-REGISTRY-WRITE
- V0130-004-PROVENANCE-VALIDATION-REPORT
- V0130-004-BUILD-FAILS-CLOSED
- V0130-004-NO-PRODUCTION-CUTOVER
- GH-997 Release v0.13.0 Build Pipeline Validation
- testGH997ReleaseV0130BuildPipelineWritesManifestBundleRegistryAndPolicyReport
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: #997 consumes #995 local evidence root and #996 provenance, then validates schema, raw artifact checksum, content policy, Manifest V2, Bundle V2 and local registry entry consistency
- CLI surface: `mtpro readiness build-v013 <assessmentID> <evidenceRoot>` emits `validationReportChecksum`, writes Manifest V2, writes Bundle V2 and confirms the local registry entry
- fail-closed evidence: schema failure, checksum mismatch, placeholder sourceCommit, synthetic sourceRunID, fixture-only evidence and raw endpoint marker evidence are rejected
- dependency evidence: #997, #998, #999 and #1000 are complete; #1001 is the active transaction recovery forensic snapshot gate after WIP=1 preflight
- forbidden scope: no diff / compare, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-EVIDENCE-CHAIN-VALIDATE

- GH-998-VERIFY-V0130-EVIDENCE-CHAIN-VALIDATE
- V0130-005-REGISTRY-MANIFEST-BUNDLE-CONSISTENCY
- V0130-005-ARTIFACT-POLICY-CHECKSUM-PROVENANCE
- V0130-005-EXPORT-COMPARISON-IDENTITY
- V0130-005-MISSING-STALE-TAMPERED-FAILS-CLOSED
- V0130-005-NO-PRODUCTION-CUTOVER
- GH-998 Release v0.13.0 Evidence-chain Validate Validation
- testGH998ReleaseV0130ValidateRejectsBrokenEvidenceChain
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: #998 consumes the #997 local registry / Manifest V2 / Bundle V2 / bundle manifest output and verifies registry, manifest, bundle, artifact snapshot, content checksum, source provenance and optional export / comparison identity coherence
- CLI surface: `mtpro readiness validate <assessmentID>` emits `evidenceChainCoherent`, `failureReasons`, `bundleBytesMatchManifest`, `artifactSnapshotsMatchManifest`, `contentValidationChecksumsPresent` and `exportComparisonIdentityConsistent`
- fail-closed evidence: missing registry, tampered bundle bytes and artifact snapshot / Manifest V2 checksum mismatch return blocked validation with explicit failure reasons
- dependency evidence: #998 is complete; #999 is the next WIP=1 redacted audit export package gate
- forbidden scope: no diff / compare, no redacted export package, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-REDACTED-AUDIT-EXPORT-PACKAGE

- GH-999-VERIFY-V0130-REDACTED-AUDIT-EXPORT-PACKAGE
- V0130-006-REDACTED-AUDIT-EXPORT-PACKAGE
- V0130-006-COMPLETE-AUDIT-PACKAGE
- V0130-006-EXPORT-CHECKSUMS-MATCH-SOURCE
- V0130-006-MISSING-EVIDENCE-FAILS-CLOSED
- V0130-006-NO-SECRET-PRODUCTION-CUTOVER
- GH-999 Release v0.13.0 Redacted Audit Export Package Validation
- testGH999ReleaseV0130ExportWritesCompleteRedactedAuditPackage
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: #999 consumes #998 coherent evidence-chain output and writes a complete local redacted audit export package with assessment summary, Manifest V2, Bundle V2, validation report, provenance and comparison JSON evidence
- CLI surface: `mtpro readiness export <assessmentID>` emits `packageComplete`, `exportedChecksumsMatchSource`, `evidenceChainCoherent`, `redactedEvidenceOnly`, `noSecretValue`, `noEndpointPayload` and `noOrderPayload`
- fail-closed evidence: missing or tampered evidence chain blocks export before partial package output; exported Manifest V2 and Bundle V2 must match source bytes
- dependency evidence: #999 is complete; #1000 is the next WIP=1 evidence-level diff / compare gate after fresh preflight
- forbidden scope: no diff / compare, no CLI lifecycle ordering, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-EVIDENCE-LEVEL-DIFF

- GH-1000-VERIFY-V0130-EVIDENCE-LEVEL-DIFF
- V0130-007-EVIDENCE-LEVEL-DIFF-COMPARE
- V0130-007-SOURCE-POLICY-RISK-CHECKSUM-PROVENANCE-COMPLETENESS
- V0130-007-BROKEN-EVIDENCE-LINK-BLOCKER
- V0130-007-COMPARISON-EXPORT-VALIDATION
- V0130-007-NO-PRODUCTION-CUTOVER
- GH-1000 Release v0.13.0 Evidence-level Diff Validation
- testGH1000ReleaseV0130CompareBuildsEvidenceLevelDiffAndBlocksBrokenLinks
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: #1000 consumes #998 coherent evidence-chain output and #999 redacted audit export package evidence, then compares source data、policy、risk posture、checksum chain、provenance and evidence completeness
- CLI surface: `mtpro readiness compare <baselineAssessmentID> <followUpAssessmentID>` emits `comparisonFormat=evidence-level-readiness-diff`, `comparisonState`, `comparedSections`, `changedSections`, `unchangedSections`, `blockedSections`, `blockers`, `reportChecksum` and `comparisonMetadataJSONPath`
- fail-closed evidence: broken evidence links, missing bundle bytes, tampered artifact snapshots or stale follow-up inputs produce `comparisonState=blocked` and section-level blockers instead of a normal changed diff
- export validation evidence: comparison metadata remains local, binds baseline and follow-up assessment identity, and keeps `exportComparisonIdentityConsistent=true` after compare
- dependency evidence: #1000 is complete; #1001 is the next WIP=1 transaction recovery forensic snapshot gate after fresh preflight
- forbidden scope: no CLI lifecycle ordering, no generation collision-proofing, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-TRANSACTION-RECOVERY-SNAPSHOT

- GH-1001-VERIFY-V0130-TRANSACTION-RECOVERY-SNAPSHOT
- V0130-008-TRANSACTION-RECOVERY-SNAPSHOT
- V0130-008-STAGING-STATE-INTENDED-COMPLETED-WRITES
- V0130-008-CLEANUP-AUDIT-TRACE
- V0130-008-PARTIAL-WRITES-FAIL-CLOSED
- V0130-008-NO-PRODUCTION-CUTOVER
- GH-1001 Release v0.13.0 Transaction Recovery Forensic Snapshot Validation
- testGH1001ReleaseV0130TransactionRecoverySnapshotExplainsInterruptedAndStaleStaging
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: #1001 writes local `transaction-recovery-snapshot.json` evidence with operation, staging state, intended writes, completed writes, missing writes, cleanup result, cleanup audit trace, stale staging flag and failure reason
- fail-closed evidence: interrupted or stale staging remains forensic evidence; partial writes are not promoted into a normal readiness assessment output
- cleanup evidence: staging cleanup leaves explicit local audit paths so post-failure diagnosis does not rely on guessing
- dependency evidence: #1001 is blocked by #1000; #1002 through #1005 remain blocked by #1001 until this PR is merged and #1001 is closed / done
- forbidden scope: no CLI lifecycle ordering, no generation collision-proofing, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-GENERATION-ID-COLLISION-PROOFING

- GH-1002-VERIFY-V0130-GENERATION-ID-COLLISION-PROOFING
- V0130-009-GENERATION-ID-COLLISION-PROOFING
- V0130-009-SAME-SECOND-GENERATION-IDS
- V0130-009-REGISTRY-LOOKUP-STABILITY
- V0130-009-AUDITABLE-DETERMINISTIC-PREFIX
- V0130-009-NO-PRODUCTION-CUTOVER
- GH-1002 Release v0.13.0 Generation ID Collision-proofing Validation
- testGH1002ReleaseV0130GenerationIDCollisionProofingKeepsRegistryLookupStable
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: #1002 replaces second-level readiness generation IDs with assessmentID / scope / epoch prefix plus collision-resistant deterministic suffix
- same-second evidence: two generations for the same assessment in the same epoch second must produce distinct generation IDs
- registry evidence: registry lookup remains stable by assessmentID and entry checksum while latest Manifest V2 can advance to the newer generation ID
- CLI evidence: readiness build commands use `ReleaseV0130GenerationIDFactory.makeGenerationID(...)` and must not retain `-generation-\(Int(now.timeIntervalSince1970))`
- dependency evidence: #1002 is blocked by #997 and became active only after #1001 closeout; #1003 through #1005 remain blocked by #1002 until this PR is merged and #1002 is closed / done
- forbidden scope: no ordered CLI lifecycle, no fixture suite, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-ORDERED-READINESS-CLI-LIFECYCLE

- GH-1003-VERIFY-V0130-ORDERED-READINESS-CLI-LIFECYCLE
- V0130-010-CREATE-BUILD-VALIDATE-EXPORT-COMPARE-ARCHIVE
- V0130-010-VALIDATION-EXPORT-MARKERS
- V0130-010-BYPASS-MANUAL-FILES-REJECTED
- V0130-010-NO-PRODUCTION-CUTOVER
- GH-1003 Release v0.13.0 Ordered Readiness CLI Lifecycle Validation
- testGH1003ReleaseV0130OrderedReadinessCLILifecycleRequiresMarkersAndNextActions
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: readiness CLI enforces create -> build -> validate -> export -> compare/archive through local `validation-state.json` and `export-state.json` markers
- CLI evidence: validate writes `validationMarkerWritten=true`; export writes `exportMarkerWritten=true`; compare emits `baselineExportMarkerHeld=true`, `followUpValidationMarkerHeld=true` and `lifecycleOrderHeld=true`; invalid order emits `nextRequiredAction`
- fail-closed evidence: export-before-validate, compare-before-follow-up-validate, archive-before-export and stale marker attempts fail closed before writing new success output
- dependency evidence: #1003 is blocked by #1002 and is the active WIP=1 gate; #1004 through #1005 remain blocked by #1003 until this PR is merged and #1003 is closed / done
- forbidden scope: no fixture suite, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

- GH-1004-VERIFY-V0130-LOCAL-EVIDENCE-FIXTURES
- TVM-RELEASE-V0130-LOCAL-EVIDENCE-FIXTURES
- V0130-011-MINIMAL-VALID-LOCAL-EVIDENCE-FIXTURE
- V0130-011-INVALID-TAMPERED-MISSING-FIXTURE-CASES
- V0130-011-BUILD-VALIDATE-EXPORT-COMPARE-RECOVERY-REGRESSION
- V0130-011-FIXTURE-RUNTIME-PATH-SEPARATION
- V0130-011-NO-PRODUCTION-CUTOVER
- GH-1004 Release v0.13.0 Local Evidence Fixtures and Regression Suite Validation
- testGH1004ReleaseV0130LocalEvidenceFixturesAndRegressionSuiteCoversFailClosedFlow
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: static minimal fixture under `Tests/Fixtures/ReleaseV0130LocalEvidence/valid` plus generated invalid/tampered/missing cases
- regression evidence: build / validate / export / compare / recovery paths consume copied fixture data in a temporary runtime store
- fail-closed evidence: missing artifact index, synthetic sourceRunID, placeholder sourceCommit, fixture-only marker and tampered artifact snapshot are rejected
- dependency evidence: #1004 was blocked by #1003 and closed / done after PR #1023 merged with required checks success; #1005 starts only after #1004 closeout, main fast-forward and fresh WIP=1 preflight
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0130-STAGE-AUDIT-RELEASE-DOCS

- GH-1005-VERIFY-V0130-STAGE-AUDIT-RELEASE-DOCS
- V0130-012-STAGE-CODE-AUDIT
- V0130-012-RELEASE-NOTES
- V0130-012-ROOT-DOCS-REFRESH
- V0130-012-VALIDATION-SUMMARY
- V0130-012-NO-PRODUCTION-CUTOVER
- V0130-012-NO-TAG-OR-RELEASE-PUBLICATION
- GH-1005 Release v0.13.0 Stage Audit / Release Docs Validation
- testGH1005ReleaseV0130StageAuditReleaseDocsCloseout
- focused verifier: `bash checks/verify-v0.13.0.sh`
- validation surface: v0.13.0 stage audit and release notes close #994 through #1005 as local evidence-driven readiness engine construction evidence
- queue evidence: #994 through #1004 are closed / done and PR #1012 through #1023 are merged with required checks SUCCESS before #1005 closeout
- boundary evidence: v0.13.0 does not create tag / GitHub Release, does not authorize production cutover, and does not enable testnet or production orders
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0141-GOLDEN-JSON-CONTRACTS

- GH-1062-VERIFY-V0141-GOLDEN-JSON-CONTRACTS
- V0141-004-GOLDEN-JSON-FIXTURES
- V0141-004-DECODE-VALIDATE-MUTATE-FAIL
- V0141-004-CORRUPTED-PAYLOADS-FAIL-CLOSED
- V0141-004-NO-PRODUCTION-CUTOVER
- testGH1062ReleaseV0141GoldenJSONFixturesFailClosedCorruptedV0140Contracts
- focused verifier: `bash checks/verify-v0.14.1-golden-json-contracts.sh`
- validation surface: fixed JSON fixtures for signal pipeline report, OMS local order event and Dashboard read-only surface decode as boundary-held v0.14 artifacts
- fail-closed evidence: mutation tests cover missing evidence ID, wrong stage-kind mapping, illegal lifecycle transition and corrupted production / network boundary fields
- boundary evidence: decode validators rerun initializer contract for lifecycle transition, OMS event and signal pipeline report instead of trusting synthesized Codable output
- dependency evidence: #1062 starts after #1060 and #1061 are closed / done with merged PR evidence and main fast-forward
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0141-DASHBOARD-LOCAL-ARTIFACTS

- GH-1063-VERIFY-V0141-DASHBOARD-LOCAL-ARTIFACTS
- V0141-005-DASHBOARD-LOCAL-READ-MODEL-ARTIFACT
- V0141-005-DECODE-VALIDATE-BEFORE-DISPLAY
- V0141-005-DASHBOARD-READ-ONLY-NO-COMMANDS
- V0141-005-NO-PRODUCTION-CUTOVER
- testGH1063DashboardExecutionSurfaceLoadsLocalReadModelArtifactReadOnly
- testGH1063DashboardLocalArtifactLoaderAnchorsReadOnlyBoundary
- focused verifier: `bash checks/verify-v0.14.1-dashboard-local-artifacts.sh`
- validation surface: Dashboard can load the v0.14 execution surface from a local read-model artifact JSON wrapper after schema、path、sha256 and boundary validation
- fail-closed evidence: invalid relative path, non-canonical checksum, command-surface injection and production-enabled flag injection fail before display
- boundary evidence: loaded surface remains read-only; no Dashboard trading button, no order form, no live command, no submit / cancel / replace, no production cutover
- dependency evidence: #1063 starts after #1062 is closed / done with merged PR evidence and main fast-forward
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no broker connection, no submit / cancel / replace, no testnet order, no production order, no trading button, no order form, no live command

## TVM-RELEASE-V0150-CLI-OPERATOR-FLOW

- GH-1073-VERIFY-V0150-CLI-OPERATOR-FLOW
- V0150-008-EXPLICIT-TESTNET-MODE
- V0150-008-OPERATOR-CONFIRMATION-REQUIRED
- V0150-008-REDACTED-OUTPUT
- V0150-008-NO-PRODUCTION-FALLBACK
- V0150-008-APPEND-ONLY-EVIDENCE-REFERENCE
- V0150-008-NO-PRODUCTION-CUTOVER
- testGH1073ReleaseV0150CLIOperatorFlowRequiresExplicitTestnetConfirmation
- focused verifier: `bash checks/verify-v0.15.0-cli-operator-flow.sh`
- validation surface: `mtpro testnet-execution` requires explicit Spot Testnet mode, exact operator confirmation phrase, intent ID, append-only network event log ID and redacted output.
- fail-closed evidence: missing `--testnet`, wrong confirmation phrase, non-redacted output, unknown action and production fallback flags fail closed before evidence output.
- boundary evidence: CLI prints only redacted evidence handles and keeps raw secret, raw credential, raw order identity, raw broker payload, production endpoint, broker endpoint, production order and production cutover disabled.
- dependency evidence: #1073 starts after #1072 closed / done with merged PR evidence and main fast-forward.
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no raw secret / credential / order identity / broker payload output, no production order, no non-Binance venue, no Futures / USDⓈ-M execution in v0.15.0 MVP.

## TVM-RELEASE-V0160-FAILURE-RECOVERY-WORKFLOW

- GH-1109-VERIFY-V0160-FAILURE-RECOVERY-WORKFLOW
- V0160-009-SUBMIT-SUCCEEDED-ARTIFACT-WRITE-FAILED
- V0160-009-NETWORK-TIMEOUT-POSSIBLE-EXCHANGE-RECEIPT
- V0160-009-CANCEL-UNKNOWN-STATE
- V0160-009-STATUS-QUERY-COMPENSATION-WORKFLOW
- V0160-009-NO-AUTOMATIC-PRODUCTION-RETRY
- V0160-009-NO-PRODUCTION-CUTOVER
- focused verifier: `bash checks/verify-v0.16.0-failure-recovery-workflow.sh`
- focused test: `swift test --filter TargetGraphTests/testGH1109ReleaseV0160FailureRecoveryWorkflowHandlesAmbiguousStatesFailClosed`
- validation surface: local recovery runbook evidence for ambiguous Binance Spot Testnet operator states.
- fail-closed evidence: partial artifact, timeout, unknown cancel state and compensation workflow all require status query compensation, operator review and close-failed-no-retry.
- forbidden scope: no automatic production retry, no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no production order, no trading button, no order form, no live command.

## TVM-RELEASE-V0160-BETA-SAFETY-GUARDS

- GH-1110-VERIFY-V0160-BETA-SAFETY-GUARDS
- V0160-010-MAX-QUANTITY-GUARD
- V0160-010-MAX-ORDERS-PER-RUN-GUARD
- V0160-010-COOLDOWN-GUARD
- V0160-010-SYMBOL-ALLOWLIST-GUARD
- V0160-010-TESTNET-ONLY-CREDENTIAL-PROFILE
- V0160-010-TRANSPORT-PRECHECK-FAILS-CLOSED
- V0160-010-REDACTED-SAFETY-EVIDENCE
- V0160-010-NO-PRODUCTION-CUTOVER
- focused verifier: `bash checks/verify-v0.16.0-beta-safety-guards.sh`
- focused test: `swift test --filter TargetGraphTests/testGH1110ReleaseV0160BetaSafetyGuardsFailClosedBeforeTransport`
- validation surface: submit / cancel / status-query operator flows call `ReleaseV0160BetaSafetyGuard.validate(command:)` before credential resolution or transport.
- fail-closed evidence: over-limit quantity, over-count run, cooldown violation, disallowed symbol and production-like credential env profile fail closed with redacted safety evidence.
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no production order, no trading button, no order form, no live command.

## TVM-RELEASE-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW

- GH-1111-VERIFY-V0160-MANUAL-TESTNET-VALIDATION-WORKFLOW
- V0160-011-MANUAL-WORKFLOW-ONLY
- V0160-011-SUBMIT-STATUS-CANCEL-STATUS-SEQUENCE
- V0160-011-RECONCILIATION-PASSED
- V0160-011-REDACTED-EVIDENCE-BUNDLE
- V0160-011-CHECKSUM-REFERENCES
- V0160-011-NO-PRODUCTION-CREDENTIALS
- V0160-011-NO-PRODUCTION-ENDPOINT
- V0160-011-NO-PRODUCTION-CUTOVER
- focused verifier: `bash checks/verify-v0.16.0-manual-testnet-validation-workflow.sh`
- focused test: `swift test --filter TargetGraphTests/testGH1111ReleaseV0160ManualTestnetValidationWorkflowRequiresRedactedBundle`
- validation surface: manual workflow_dispatch only validates redacted bundle references; it never reads secrets and never runs network execution.
- fail-closed evidence: submit -> status -> cancel -> status -> reconciliation passed sequence and every sha256 checksum reference must be present.
- forbidden scope: no production cutover, no production trading by default, no production secret read, no production endpoint / broker endpoint connection, no production order, no trading button, no order form, no live command.
